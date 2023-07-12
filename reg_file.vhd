library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
    port( clock      : in std_logic;
    rst      : in std_logic;
    wr_en    : in std_logic;
    select_regA : in unsigned(2 downto 0);
    select_regB : in unsigned(2 downto 0);
    RegWrite : in unsigned(2 downto 0);
    data_in  : in unsigned(15 downto 0);
    data_out_A : out unsigned(15 downto 0);
    data_out_B : out unsigned(15 downto 0)
    );
end entity;

architecture a_reg_file of reg_file is
    component reg16bits is
        port(clock      : in std_logic;
        rst      : in std_logic;
        wr_en    : in std_logic;
        data_in  : in unsigned(15 downto 0);
        data_out : out unsigned(15 downto 0)
        );
    end component;

    signal out_reg0,out_reg1,out_reg2,out_reg3,out_reg4,out_reg5,out_reg6,out_reg7 : unsigned(15 downto 0);
    signal wr_en1,wr_en2,wr_en3,wr_en4,wr_en5,wr_en6,wr_en7 : std_logic;

begin
    reg16bits0 : reg16bits port map(clock => clock,rst => '1',wr_en => '0',data_in => data_in, data_out => out_reg0);
    reg16bits1 : reg16bits port map(clock => clock,rst => rst, wr_en => wr_en1, data_in => data_in, data_out => out_reg1);
    reg16bits2 : reg16bits port map(clock => clock,rst => rst, wr_en => wr_en2, data_in => data_in, data_out => out_reg2);
    reg16bits3 : reg16bits port map(clock => clock,rst => rst, wr_en => wr_en3, data_in => data_in, data_out => out_reg3);
    reg16bits4 : reg16bits port map(clock => clock,rst => rst, wr_en => wr_en4, data_in => data_in, data_out => out_reg4);
    reg16bits5 : reg16bits port map(clock => clock,rst => rst, wr_en => wr_en5, data_in => data_in, data_out => out_reg5);
    reg16bits6 : reg16bits port map(clock => clock,rst => rst, wr_en => wr_en6, data_in => data_in, data_out => out_reg6);
    reg16bits7 : reg16bits port map(clock => clock,rst => rst, wr_en => wr_en7, data_in => data_in, data_out => out_reg7);

    data_out_A <= out_reg0 when select_regA="000" else
                  out_reg1 when select_regA="001" else
                  out_reg2 when select_regA="010" else
                  out_reg3 when select_regA="011" else
                  out_reg4 when select_regA="100" else
                  out_reg5 when select_regA="101" else
                  out_reg6 when select_regA="110" else
                  out_reg7 when select_regA="111" else
                    "0000000000000000";
    
    data_out_B <=   out_reg0 when select_regB="000" else
                    out_reg1 when select_regB="001" else
                    out_reg2 when select_regB="010" else
                    out_reg3 when select_regB="011" else
                    out_reg4 when select_regB="100" else
                    out_reg5 when select_regB="101" else
                    out_reg6 when select_regB="110" else
                    out_reg7 when select_regB="111" else
                    "0000000000000000";
    
    wr_en1 <= wr_en when RegWrite="001" else
    '0';
    wr_en2 <= wr_en when RegWrite="010" else
    '0';
    wr_en3 <= wr_en when RegWrite="011" else
    '0';
    wr_en4 <= wr_en when RegWrite="100" else
    '0';
    wr_en5 <= wr_en when RegWrite="101" else
    '0';
    wr_en6 <= wr_en when RegWrite="110" else
    '0';
    wr_en7 <= wr_en when RegWrite="111" else
    '0';
end architecture;


