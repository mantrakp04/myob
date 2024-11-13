-- File: /src/slices/mxm_slice.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity mxm_slice is
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
        ready : out std_logic;
        busy : out std_logic
    );
end mxm_slice;

architecture Structural of mxm_slice is
    -- Constants for operation codes
    constant OP_NOP : std_logic_vector(3 downto 0) := "0000";
    constant OP_MUL : std_logic_vector(3 downto 0) := "0001";
    constant OP_ADD : std_logic_vector(3 downto 0) := "0010";
    constant OP_TRANS : std_logic_vector(3 downto 0) := "0011";

    -- Internal signals
    type tile_array is array (0 to 19) of std_logic_vector(511 downto 0);
    signal tile_inputs, tile_outputs : tile_array;
    signal tile_valid : std_logic_vector(19 downto 0);
    signal tile_ready : std_logic_vector(19 downto 0);
    signal global_busy : std_logic;

    component tile
        port (
            clk : in std_logic;
            reset : in std_logic;
            data_in : in std_logic_vector(511 downto 0);
            data_valid_in : in std_logic;
            data_out : out std_logic_vector(511 downto 0);
            data_valid_out : out std_logic;
            op_code : in std_logic_vector(3 downto 0);
            ready : out std_logic
        );
    end component;

begin
    -- Input demultiplexing process
    process (data_in, data_valid_in)
    begin
        for i in 0 to 19 loop
            tile_inputs(i) <= data_in((i + 1) * 512 - 1 downto i * 512);
            tile_valid(i) <= data_valid_in;
        end loop;
    end process;

    -- Generate tiles
    gen_tiles : for i in 0 to 19 generate
        tile_inst : tile
        port map(
            clk => clk,
            reset => reset,
            data_in => tile_inputs(i),
            data_valid_in => tile_valid(i),
            data_out => tile_outputs(i),
            data_valid_out => tile_valid(i),
            op_code => op_code,
            ready => tile_ready(i)
        );
    end generate;

    -- Output multiplexing process
    process (tile_outputs, tile_valid)
    begin
        for i in 0 to 19 loop
            data_out((i + 1) * 512 - 1 downto i * 512) <= tile_outputs(i);
        end loop;
        data_valid_out <= and tile_valid;
    end process;

    -- Status signals
    ready <= and tile_ready;
    busy <= global_busy;

    -- Global busy logic
    process (clk, reset)
    begin
        if reset = '1' then
            global_busy <= '0';
        elsif rising_edge(clk) then
            if data_valid_in = '1' then
                global_busy <= '1';
            elsif data_valid_out = '1' then
                global_busy <= '0';
            end if;
        end if;
    end process;

end Structural;