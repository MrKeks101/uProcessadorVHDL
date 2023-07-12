library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg16bits_tb is
    end;

architecture a_reg16bits_tb of reg16bits_tb is
    component reg16bits
    port( clock      : in std_logic;
          rst      : in std_logic;
          wr_en    : in std_logic;
          data_in  : in unsigned(15 downto 0);
          data_out : out unsigned(15 downto 0)
    );
    end component;
    
    constant period_time : time := 100 ns;
    signal finished      : std_logic := '0';
    signal clk,reset     : std_logic;
begin
    uut : reg16bits port map()
