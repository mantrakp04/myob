-- File: /src/slices/mem_slice.vhd
-- Simulates memory read/write operations

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity mem_slice is
    port (
        clk : in std_logic;
        reset : in std_logic;
        data_in : in std_logic_vector(10239 downto 0);
        op_code : in std_logic_vector(3 downto 0);
        addr : in std_logic_vector(7 downto 0);
        write_en : in std_logic;
        data_out : out std_logic_vector(10239 downto 0)
    );
end mem_slice;

architecture Behavioral of mem_slice is
    type memory_array is array (0 to 255) of std_logic_vector(10239 downto 0);
    signal memory : memory_array;
begin
    process (clk, reset)
    begin
        if reset = '1' then
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            -- Constants for operation codes
            constant OP_NOP : std_logic_vector(3 downto 0) := "