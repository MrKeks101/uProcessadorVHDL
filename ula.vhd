library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    port( IN_A : in unsigned(15 downto 0); -- Declaração das duas entradas de 16 bits
          IN_B : in unsigned(15 downto 0);
          select_op : in unsigned(1 downto 0);
          carry_sum : out std_logic; -- Flag de carry para soma 
          carry_sub : out std_logic;  -- Flag de carry para subtração
          result : out unsigned(15 downto 0) -- Saída de 16 bits
          );
end entity;

architecture a_ula of ula is
    component mux4_1 is
        port(
            selec       : in unsigned(1 downto 0);
            inA         : in unsigned(15 downto 0);
            inB         : in unsigned(15 downto 0);
            inC         : in unsigned(15 downto 0);
            inD         : in unsigned(15 downto 0);
            data_out    : out unsigned(15 downto 0)
        );
    end component;

	signal sum_op, subt_op, less_op, dif_op : unsigned(16 downto 0);

    constant ZERO: unsigned(16 downto 0) := "00000000000000000";
    constant ONE: unsigned(16 downto 0) := "00000000000000001";
	
    begin
        mux: mux4_1 port map(
            selec => select_op,
            inA => sum_op(15 downto 0),
            inB => subt_op(15 downto 0),
            inC => less_op(15 downto 0),
            inD => dif_op(15 downto 0),
            data_out => result
        );
        
        --  operation   code
            
        --  inA + inB   00
        --  inA - inB   01
        --  inA < inB  10
        --  inA /= inB  11

        sum_op <= ('0' & IN_A) + ('0' & IN_B);
        
        subt_op <= ('0' & IN_A) - ('0' & IN_B);

        less_op <= ONE when (('0' & IN_A) < ('0' & IN_B)) else ZERO;

        dif_op <= ONE when (('0' & IN_A) /= ('0' & IN_B)) else ZERO;

        carry_sum <= sum_op(16);

        carry_sub <= '0' when IN_B <= IN_A else 
                      '1';
end architecture;