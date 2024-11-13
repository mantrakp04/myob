-- File: /src/icu/icu.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity icu is
    port (
        clk : in std_logic;
        reset : in std_logic;
        -- Instruction input interface
        instr_in : in std_logic_vector(15 downto 0); -- 16-bit instruction input
        instr_valid : in std_logic; -- Input instruction valid signal
        ready_for_instr : out std_logic; -- Ready to accept new instruction
        -- Output control signals
        op_code : out std_logic_vector(3 downto 0);
        target_slice : out std_logic_vector(1 downto 0);
        valid : out std_logic
    );
end icu;

architecture Behavioral of icu is
    -- Constants
    constant QUEUE_DEPTH : integer := 8;
    constant MXM_SLICE : std_logic_vector(1 downto 0) := "00";
    constant VXM_SLICE : std_logic_vector(1 downto 0) := "01";
    constant SXM_SLICE : std_logic_vector(1 downto 0) := "10";
    constant MEM_SLICE : std_logic_vector(1 downto 0) := "11";

    -- Types
    type instruction_t is record
        op : std_logic_vector(3 downto 0);
        slice : std_logic_vector(1 downto 0);
        param : std_logic_vector(9 downto 0);
    end record;

    type queue_t is array (0 to QUEUE_DEPTH - 1) of instruction_t;

    -- State machine type
    type state_t is (IDLE, FETCH, DECODE, EXECUTE, WAIT_COMPLETE);

    -- Signals
    signal current_state, next_state : state_t;
    signal instr_queue : queue_t;
    signal queue_head, queue_tail : unsigned(2 downto 0);
    signal queue_count : unsigned(3 downto 0);
    signal current_instr : instruction_t;
    signal execution_cycles : unsigned(3 downto 0);
    signal busy_slices : std_logic_vector(3 downto 0);

begin
    -- State machine process
    process (clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            queue_head <= (others => '0');
            queue_tail <= (others => '0');
            queue_count <= (others => '0');
            busy_slices <= (others => '0');
            valid <= '0';
            ready_for_instr <= '1';

        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    valid <= '0';
                    if queue_count > 0 then
                        current_state <= FETCH;
                    end if;
                    ready_for_instr <= '1';

                when FETCH =>
                    if queue_count > 0 then
                        current_instr <= instr_queue(to_integer(queue_head));
                        queue_head <= queue_head + 1;
                        queue_count <= queue_count - 1;
                        current_state <= DECODE;
                    else
                        current_state <= IDLE;
                    end if;

                when DECODE =>
                    -- Check if target slice is available
                    if busy_slices(to_integer(unsigned(current_instr.slice))) = '0' then
                        op_code <= current_instr.op;
                        target_slice <= current_instr.slice;
                        valid <= '1';
                        busy_slices(to_integer(unsigned(current_instr.slice))) <= '1';
                        execution_cycles <= unsigned(current_instr.param(3 downto 0));
                        current_state <= EXECUTE;
                    else
                        current_state <= WAIT_COMPLETE;
                    end if;

                when EXECUTE =>
                    if execution_cycles = 0 then
                        busy_slices(to_integer(unsigned(current_instr.slice))) <= '0';
                        valid <= '0';
                        current_state <= IDLE;
                    else
                        execution_cycles <= execution_cycles - 1;
                    end if;

                when WAIT_COMPLETE =>
                    if busy_slices(to_integer(unsigned(current_instr.slice))) = '0' then
                        current_state <= DECODE;
                    end if;
            end case;

            -- Handle instruction input
            if instr_valid = '1' and queue_count < QUEUE_DEPTH then
                instr_queue(to_integer(queue_tail)) <= (
                    op => instr_in(15 downto 12),
                    slice => instr_in(11 downto 10),
                    param => instr_in(9 downto 0)
                    );
                queue_tail <= queue_tail + 1;
                queue_count <= queue_count + 1;
            end if;

            ready_for_instr <= '1' when queue_count < QUEUE_DEPTH else
                               '0';
        end if;
    end process;

end Behavioral;