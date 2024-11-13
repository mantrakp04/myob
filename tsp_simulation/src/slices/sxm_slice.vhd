library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity sxm_slice is
    port (
        clk : in std_logic;
        reset : in std_logic;
        -- Data interface
        data_in : in std_logic_vector(10239 downto 0);
        data_valid_in : in std_logic;
        data_out : out std_logic_vector(10239 downto 0);
        data_valid_out : out std_logic;
        -- Control interface
        op_code : in std_logic_vector(3 downto 0);
        shift_amount : in std_logic_vector(5 downto 0);
        ready : out std_logic;
        busy : out std_logic
    );
end sxm_slice;

architecture Behavioral of sxm_slice is
    -- Constants for operation codes
    constant OP_NOP : std_logic_vector(3 downto 0) := "0000";
    constant OP_SHL : std_logic_vector(3 downto 0) := "0001";
    constant OP_SHR : std_logic_vector(3 downto 0) := "0010";
    constant OP_ROL : std_logic_vector(3 downto 0) := "0011";
    constant OP_ROR : std_logic_vector(3 downto 0) := "0100";
    constant OP_BARREL : std_logic_vector(3 downto 0) := "0101";

    -- Pipeline stages
    type pipeline_stage_t is record
        data : std_logic_vector(10239 downto 0);
        valid : std_logic;
        op : std_logic_vector(3 downto 0);
        shift : std_logic_vector(5 downto 0);
    end record;

    signal stage1, stage2 : pipeline_stage_t;
    signal global_busy : std_logic;

begin
    process (clk, reset)
    begin
        if reset = '1' then
            stage1 <= (data => (others => '0'), valid => '0',
                      op => OP_NOP, shift => (others => '0'));
            stage2 <= (data => (others => '0'), valid => '0',
                      op => OP_NOP, shift => (others => '0'));
            data_valid_out <= '0';
            ready <= '1';
            busy <= '0';

        elsif rising_edge(clk) then
            -- Pipeline stage 1: Input registration
            if data_valid_in = '1' and not global_busy then
                stage1.data <= data_in;
                stage1.valid <= '1';
                stage1.op <= op_code;
                stage1.shift <= shift_amount;
                ready <= '0';
                global_busy <= '1';
            end if;

            -- Pipeline stage 2: Shift operation
            stage2 <= stage1;
            if stage2.valid = '1' then
                case stage2.op is
                    when OP_SHL =>
                        data_out <= stage2.data(10239 - to_integer(unsigned(stage2.shift)) downto 0) &
                                    (others => '0');
                    when OP_SHR =>
                        data_out <= (others => '0') &
                                    stage2.data(10239 downto to_integer(unsigned(stage2.shift)));
                    when OP_ROL =>
                        data_out <= stage2.data(10239 - to_integer(unsigned(stage2.shift)) downto 0) &
                                    stage2.data(10239 downto 10240 - to_integer(unsigned(stage2.shift)));
                    when OP_ROR =>
                        data_out <= stage2.data(to_integer(unsigned(stage2.shift)) - 1 downto 0) &
                                    stage2.data(10239 downto to_integer(unsigned(stage2.shift)));
                    when OP_BARREL =>
                        -- Implement barrel shifter logic
                        null;
                    when others =>
                        data_out <= stage2.data;
                end case;
                data_valid_out <= '1';
                global_busy <= '0';
                ready <= '1';
            else
                data_valid_out <= '0';
            end if;
        end if;
    end process;

    busy <= global_busy;
end Behavioral;