-- File: /src/tsp_top.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity tsp_top is
    port (
        clk : in std_logic;
        reset : in std_logic
    );
end tsp_top;

architecture Structural of tsp_top is
    component icu
        port (
            clk : in std_logic;
            reset : in std_logic;
            op_code : out std_logic_vector(3 downto 0);
            target_slice : out std_logic_vector(1 downto 0);
            valid : out std_logic
        );
    end component;

    component mxm_slice
        port (
            clk : in std_logic;
            reset : in std_logic;
            data_in : in std_logic_vector(10239 downto 0);
            op_code : in std_logic_vector(3 downto 0);
            data_out : out std_logic_vector(10239 downto 0)
        );
    end component;

    -- Declare other slices similarly

    signal op_code : std_logic_vector(3 downto 0);
    signal target_slice : std_logic_vector(1 downto 0);
    signal valid : std_logic;

    -- Signals for data between slices
    signal mxm_data_in : std_logic_vector(10239 downto 0);
    signal mxm_data_out : std_logic_vector(10239 downto 0);

begin
    icu_inst : icu
    port map(
        clk => clk,
        reset => reset,
        op_code => op_code,
        target_slice => target_slice,
        valid => valid
    );

    mxm_slice_inst : mxm_slice
    port map(
        clk => clk,
        reset => reset,
        data_in => mxm_data_in,
        op_code => op_code,
        data_out => mxm_data_out
    );

    -- Connect other slices based on target_slice and valid signals

end Structural;