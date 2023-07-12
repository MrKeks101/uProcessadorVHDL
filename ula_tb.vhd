library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula_tb is
    end;

architecture a_ula_tb of ula_tb is
    component ula
       port( IN_A : in unsigned(15 downto 0);
             IN_B : in unsigned(15 downto 0);
             select_op : in unsigned(1 downto 0);
             result : out unsigned(15 downto 0)
             );
    end component;
    signal IN_A,IN_B,add,subtract,exclusive,result: unsigned(15 downto 0);
    signal select_op : unsigned(1 downto 0);
    signal compare_equals : std_logic;
           
    begin
        uut: ula port map( IN_A => IN_A, IN_B => IN_B,select_op => select_op,result =>result);
    process
    begin
        IN_A <= "0000000000010010"; -- Testes de adição
        IN_B <= "0000000000000010";
        select_op <= "00";
        wait for 50 ns;
        IN_A <= "0000000000000010";
        IN_B <= "0000000000010010";
        select_op <= "00";
        wait for 50 ns;
        IN_A <= "0000000000000100"; -- Testes de subtração
        IN_B <= "0000000000000010";
        select_op <= "01";
        wait for 50 ns;
        IN_A <= "0000000000000010"; 
        IN_B <= "0000000000000100";
        select_op <= "01";
        wait for 50 ns;
        IN_A <= "0000000000000010"; -- Testes do XOR
        IN_B <= "0000000000000011";
        select_op <= "10";
        wait for 50 ns;
        IN_A <= "0000000000001110"; 
        IN_B <= "0000000000010111";
        select_op <= "10";
        wait for 50 ns;
        IN_A <= "0000000000000110"; -- Testes da comparação equals
        IN_B <= "0000000000000110";
        select_op <= "11";
        wait for 50 ns;
        IN_A <= "0000000000000111";
        IN_B <= "0000000000000110";
        select_op <= "11";
        wait for 50 ns;
        wait;
    end process;
    end architecture;