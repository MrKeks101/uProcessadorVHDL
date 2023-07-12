library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end;

architecture a_top_level_tb of top_level_tb is
    component top_level
        port(
            clock           : in std_logic;
            rst           : in std_logic;
			PC_out_data     : out unsigned(6 downto 0);
        	rom_data        : out unsigned(17 downto 0);
        	ULA_out_data    : out unsigned(15 downto 0)
            );
    end component;
    
	--signal finished         : std_logic := '0';
    signal clock, reset, finished 	: std_logic;
	signal PC_out_data 				: unsigned(6 downto 0);
	signal rom_data 				: unsigned(17 downto 0);
	signal ULA_out_data 			: unsigned(15 downto 0);
    constant period_time 			: time		:= 10 ns;

begin
    uut: top_level port map(clock 			=> clock,           
                        rst 			=> reset,
						PC_out_data  	=> PC_out_data,  
						rom_data 	 	=> rom_data, 					
						ULA_out_data 	=> ULA_out_data);

    reset_global: process
	begin	
		reset <= '1';
		wait for period_time;
		reset <= '0';
		wait;
	end process reset_global;

    sim_time_proc: process
	begin 
		wait for period_time * 10000;
		finished <= '1';
		wait;
	end process sim_time_proc;

    clk_proc: process
	begin 
		while finished /= '1' loop
			clock <= '0';
			wait for period_time/2;
			clock <= '1';
			wait for period_time/2;
		end loop;
		wait;
	end process clk_proc;
	
end architecture;    