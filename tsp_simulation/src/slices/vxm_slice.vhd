-- File: /src/slices/vxm_slice.vhd
-- Similar structure, focuses on vector arithmetic operations

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity vxm_slice is
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
end vxm_slice;

architecture Behavioral of vxm_slice is
    -- Constants for operation codes
    constant OP_NOP : std_logic_vector(3 downto 0) := "0000";
    constant OP_ADD : std_logic_vector(3 downto 0) := "0001";
    constant OP_SUB : std_logic_vector(3 downto 0) := "0010";
    constant OP_DOTPRD : std_logic_vector(3 downto 0) := "0011";
    constant OP_SCALE : std_logic_vector(3 downto 0) := "0100";

    -- Internal signals
    type tile_array is array (0 to 19) of std_logic_vector(511 downto 0);
    signal tile_inputs, tile_outputs : tile_array;
    signal tile_valid : std_logic_vector(19 downto 0);
    signal tile_ready : std_logic_vector(19 downto 0);
    signal processing_done : std_logic;
    signal global_busy : std_logic;

    component tile
        port (
            clk : in std_logic;
            reset : in std_logic;
            data_in : in std_logic_vector(511 downto 0);
            op_code : in std_logic_vector(3 downto 0);
            data_out : out std_logic_vector(511 downto 0)
        );
    end component;

begin
    -- Split input into tiles
    process (data_in)
    begin
        for i in 0 to 19 loop
            tile_inputs(i) <= data_in((i + 1) * 512 - 1 downto i * 512);
        end loop;
    end process;

    -- Generate tiles
    gen_tiles : for i in 0 to 19 generate
        tile_inst : tile
        port map(
            clk => clk,
            reset => reset,
            data_in => tile_inputs(i),
            op_code => op_code,
            data_out => tile_outputs(i)
        );
    end generate;

    -- Combine tile outputs
    process (tile_outputs)
    begin
        for i in 0 to 19 loop
            data_out((i + 1) * 512 - 1 downto i * 512) <= tile_outputs(i);
        end loop;
    end process;
end Behavioral;