-- File: /tb/tsp_tb.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tsp_tb is
end tsp_tb;

architecture Behavioral of tsp_tb is
    component tsp_top
        port (
            clk : in std_logic;
            reset : in std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';

    constant CLK_PERIOD : time := 10 ns;

begin
    uut : tsp_top
    port map(
        clk => clk,
        reset => reset
    );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stimulus : process
    begin
        -- Initialize reset
        wait for 20 ns;
        reset <= '0';
        -- Wait for simulation
        wait for 200 ns;
        -- End simulation
        wait;
    end process;
end Behavioral;