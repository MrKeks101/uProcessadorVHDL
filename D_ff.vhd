library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity D_ff is
    port(
        clock     : in std_logic;
        reset     : in std_logic;
        write_en  : in std_logic;
        D         : in std_logic;
        Q         : out std_logic
    );
end entity;

architecture a_D_ff of D_ff is
begin
    process(clock, reset)
    begin
        if reset='1' then 
            Q <= '0';
        elsif rising_edge(clock) then 
            if write_en = '1' then 
                Q <= D;
            end if;
        end if;
    end process;
end architecture;