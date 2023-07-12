library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_machine is
    port(
        clk:    in std_logic;
        rst:    in std_logic;
        state:  out unsigned(1 downto 0)
    );
end entity;

architecture a_state_machine of state_machine is
    signal state_signal: unsigned(1 downto 0);
begin
    process(clk,rst)
    begin
        if rst='1' then
            state_signal <= "00";
        elsif rising_edge(clk) then
            if state_signal = "10" then
                state_signal <= "00";
            else
                state_signal <= state_signal + 1;
        end if;
    end if;
    end process;

    state <= state_signal;
end architecture a_state_machine;