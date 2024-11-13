-- File: /src/lanes/lane.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity lane is
    port (
        clk : in std_logic;
        reset : in std_logic;
        -- Data interface
        data_in : in std_logic_vector(31 downto 0);
        data_valid_in : in std_logic;
        data_out : out std_logic_vector(31 downto 0);
        data_valid_out : out std_logic;
        -- Control interface
        op_code : in std_logic_vector(3 downto 0);
        ready : out std_logic;
        -- Status flags
        zero_flag : out std_logic;
        overflow_flag : out std_logic
    );
end lane;

architecture Behavioral of lane is
    -- Constants for operation codes
    constant OP_NOP : std_logic_vector(3 downto 0) := "0000";
    constant OP_ADD : std_logic_vector(3 downto 0) := "0001";
    constant OP_SUB : std_logic_vector(3 downto 0) := "0010";
    constant OP_MUL : std_logic_vector(3 downto 0) := "0011";
    constant OP_DIV : std_logic_vector(3 downto 0) := "0100";
    constant OP_AND : std_logic_vector(3 downto 0) := "0101";
    constant OP_OR : std_logic_vector(3 downto 0) := "0110";
    constant OP_XOR : std_logic_vector(3 downto 0) := "0111";
    constant OP_SHL : std_logic_vector(3 downto 0) := "1000";
    constant OP_SHR : std_logic_vector(3 downto 0) := "1001";
    constant OP_COMP : std_logic_vector(3 downto 0) := "1010";

    -- Pipeline stages
    type pipeline_stage_t is record
        data : std_logic_vector(31 downto 0);
        valid : std_logic;
        op : std_logic_vector(3 downto 0);
    end record;

    signal stage1, stage2, stage3 : pipeline_stage_t;

    -- Internal signals
    signal result_data : std_logic_vector(31 downto 0);
    signal result_valid : std_logic;
    signal mult_result : std_logic_vector(63 downto 0);
    signal div_result : std_logic_vector(31 downto 0);
    signal div_remainder : std_logic_vector(31 downto 0);
    signal div_by_zero : std_logic;

begin
    -- Pipeline process
    process (clk, reset)
    begin
        if reset = '1' then
            stage1 <= (data => (others => '0'), valid => '0', op => OP_NOP);
            stage2 <= (data => (others => '0'), valid => '0', op => OP_NOP);
            stage3 <= (data => (others => '0'), valid => '0', op => OP_NOP);
            data_valid_out <= '0';
            ready <= '1';
            zero_flag <= '0';
            overflow_flag <= '0';

        elsif rising_edge(clk) then
            -- Stage 1: Input Registration
            if data_valid_in = '1' then
                stage1.data <= data_in;
                stage1.valid <= '1';
                stage1.op <= op_code;
            else
                stage1.valid <= '0';
            end if;

            -- Stage 2: Operation Execution
            stage2 <= stage1;

            -- Stage 3: Result Processing
            stage3 <= stage2;

            -- Output Stage
            if stage3.valid = '1' then
                case stage3.op is
                    when OP_ADD =>
                        result_data <= std_logic_vector(unsigned(stage3.data) + 1);
                        overflow_flag <= '0';

                    when OP_SUB =>
                        result_data <= std_logic_vector(unsigned(stage3.data) - 1);
                        overflow_flag <= '0';

                    when OP_MUL =>
                        mult_result <= std_logic_vector(unsigned(stage3.data) * unsigned(stage2.data));
                        result_data <= mult_result(31 downto 0);
                        overflow_flag <= '1' when mult_result(63 downto 32) /= x"00000000" else
                                         '0';

                    when OP_DIV =>
                        if unsigned(stage2.data) /= 0 then
                            div_result <= std_logic_vector(unsigned(stage3.data) / unsigned(stage2.data));
                            div_remainder <= std_logic_vector(unsigned(stage3.data) mod unsigned(stage2.data));
                            result_data <= div_result;
                            div_by_zero <= '0';
                        else
                            div_by_zero <= '1';
                            result_data <= (others => '1'); -- Max value on division by zero
                        end if;

                    when OP_AND =>
                        result_data <= stage3.data and stage2.data;

                    when OP_OR =>
                        result_data <= stage3.data or stage2.data;

                    when OP_XOR =>
                        result_data <= stage3.data xor stage2.data;

                    when OP_SHL =>
                        result_data <= std_logic_vector(shift_left(unsigned(stage3.data), 1));

                    when OP_SHR =>
                        result_data <= std_logic_vector(shift_right(unsigned(stage3.data), 1));

                    when OP_COMP =>
                        result_data <= std_logic_vector(not unsigned(stage3.data));

                    when others => -- OP_NOP
                        result_data <= stage3.data;
                end case;

                -- Set zero flag
                zero_flag <= '1' when result_data = x"00000000" else
                             '0';

                -- Output valid data
                data_out <= result_data;
                data_valid_out <= '1';
            else
                data_valid_out <= '0';
            end if;

            -- Ready signal logic
            ready <= '1' when stage2.valid = '0' else
                     '0';
        end if;
    end process;

end Behavioral;