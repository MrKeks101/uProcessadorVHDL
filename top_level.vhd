library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    port (
        clock, rst: in std_logic;
        ULA_out_data : out unsigned(15 downto 0);
        rom_data     : out unsigned(17 downto 0);
        PC_out_data : out unsigned(6 downto 0)
    );
end entity;


architecture a_top_level of top_level is
    component ula is
        port(
            select_op      : in unsigned(1 downto 0);
            IN_A, IN_B: in unsigned(15 downto 0);
            carry_sum,carry_sub : out std_logic;
            result  : out unsigned(15 downto 0)
        );
    end component;

    component reg_file is
        port(
            clock:       in std_logic;
            rst:       in std_logic;
            wr_en:     in std_logic;
            select_regA:   in unsigned(2 downto 0);
            select_regB:   in unsigned(2 downto 0);
            RegWrite:   in unsigned(2 downto 0);
            data_in:   in unsigned(15 downto 0);
            data_out_A:  out unsigned(15 downto 0);
            data_out_B:  out unsigned(15 downto 0)
        );
    end component;

    component mux2_1 is
        port(   
            op              : in std_logic;
            in0,in1        : in unsigned(15 downto 0);
            output          : out unsigned(15 downto 0)
        );
    end component;

    component pc is
        port(clock      : in std_logic;
        rst      : in std_logic;
        wr_en    : in std_logic;
        data_in  : in unsigned(6 downto 0);
        data_out : out unsigned(6 downto 0)
        );
    end component;

    component control_unit is
        port(clk, rst, flag_zero,flag_not_zero,carry_sbc,flag_less : in std_logic;
        selec_regFile_input,ula_inputB,is_zero,is_not_zero,is_less, not_jp_instruction,ram_write_enable : out std_logic;
        rom_data : in unsigned(17 downto 0);
        const : out unsigned(15 downto 0);
        ram_data_in : out unsigned(15 downto 0);
        regA_out,regB_out,ula_out : in unsigned(15 downto 0);
        PC_data_out : in unsigned(6 downto 0); -- Saída do PC
        PC_data_in,ram_address  : out unsigned(6 downto 0); -- Dado atual do PC
        selec_regA      : out unsigned(2 downto 0);
        selec_regB      : out unsigned(2 downto 0);
        selec_regWrite  : out unsigned(2 downto 0); 
        wr_enable, pc_wr_enable : out std_logic;
        ula_select_op            : out unsigned(1 downto 0)
    );
    end component;

    component rom is 
    port(
        clk       : in std_logic;
        address  : in unsigned(6 downto 0);
        data_out      : out unsigned(17 downto 0)
    );
    end component;

    component ram is
        port(
            clock       : in std_logic;
            write_en    : in std_logic;
            address     : in unsigned (6 downto 0);
            data_in     : in unsigned (15 downto 0);
            data_out    : out unsigned (15 downto 0)
        );
        end component;

    component D_ff is
        port(
            clock       : in std_logic;
            reset       : in std_logic;
            write_en    : in std_logic;
            D           : in std_logic;
            Q           : out std_logic
        );
        end component;

        -------------------Sinais---------------------
    
    -- Sinais de saída do banco de Regs
    -- (Reg File outA -> ULA inA) (Reg File outB -> Mux inA)
    signal regOutA_ulaA, regOutB_SIG : unsigned(15 downto 0);

    -- Sinais de seleção de registrador
    -- (Control Unit -> Register File)
    signal selec_regA_SIG, selec_regB_SIG, selec_regWrite_SIG : unsigned(2 downto 0);

    -- (Mux output -> ULA inB)
    signal muxOut_ulaB : unsigned(15 downto 0);
    
    -- Sinal da constante (Control Unit -> ULA)
    signal const_SIG : unsigned(15 downto 0);

    -- Sinal da ROM (ROM -> Control Unit)
    signal rom_data_SIG : unsigned(17 downto 0);

    -- Sinais de dado da RAM
    signal ram_write_en_SIG : std_logic;
    signal ram_data_in_SIG  : unsigned(15 downto 0);
    signal ram_data_out_SIG : unsigned(15 downto 0);
    signal ram_address_SIG  : unsigned(6 downto 0);

    signal selec_regFile_input_SIG : std_logic;

    signal regFile_input : unsigned(15 downto 0);

    -- Instrução do PC (PC <-> Control Unit)
    signal PC_data_in_SIG, PC_data_out_SIG : unsigned(6 downto 0);

    -- Sinais do tipo write_enable
    -- (Control Unit -> Reg File) (Control Unit -> PC) (Control Unit)
    signal write_en_SIG, PC_write_en_SIG : std_logic;

    -- Sinais de flag usando FFs 
    signal update_flag_ff : std_logic;
    signal is_zero_SIG, is_not_zero_SIG, is_less_SIG  : std_logic;
    signal flag_zero_SIG, flag_not_zero_SIG, flag_less_SIG : std_logic;

    -- Seleção de operação da ULA
    -- (Control Unit -> ULA)
    signal ULA_selec_op_SIG : unsigned(1 downto 0); 

    -- Seleção da entrada B da ULA
    -- (Control Unit -> Mux)
    signal ULA_inputB_SIG : std_logic;

    signal ULA_output : unsigned(15 downto 0);

    signal carry_subt_SIG   : std_logic;
    signal carry_sum_SIG    : std_logic;
begin
    reg_file_pm: reg_file port map(
        data_in       => regFile_input, 
        select_regA       => selec_regA_SIG, 
        select_regB       => selec_regB_SIG, 
        RegWrite   => selec_regWrite_SIG, 
        data_out_A         => regOutA_ulaA,
        data_out_B         => regOutB_SIG,
        wr_en         => write_en_SIG, 
        clock            => clock, 
        rst            => rst
    );

    ula_pm: ula port map(IN_A           => regOutA_ulaA, 
                         IN_B           => muxOut_ulaB, 
                         result      => ULA_output, 
                         select_op      => ULA_selec_op_SIG,
                         carry_sum     => carry_sum_SIG,
                         carry_sub    => carry_subt_SIG);

    mux_ULA_inputB_pm: mux2_1 port map(in0        => const_SIG, 
                                    in1        => regOutB_SIG, 
                                    output   => muxOut_ulaB, 
                                    op      => ULA_inputB_SIG);

    mux_regFile_data_input_pm: mux2_1 port map(in0         => ULA_output,
                                                in1         => ram_data_out_SIG,
                                                output    => regFile_input,
                                                op       => selec_regFile_input_SIG);

    Dff_flag_zero_pm: D_ff port map(clock   => clock, -- FFs que controlam as flags zero,not_zero e less
                                    reset    => rst,         
                                    write_en   => update_flag_ff,
                                    D    => is_zero_SIG,
                                    Q     => flag_zero_SIG);

    Dff_flag_not_zero_pm: D_ff port map(clock      => clock,
                                        reset      => rst, 
                                        write_en   => update_flag_ff,
                                        D       => is_not_zero_SIG,
                                        Q       => flag_not_zero_SIG);

    Dff_flag_less_pm: D_ff port map(clock    => clock,
                                    reset       => rst,
                                    write_en    => update_flag_ff,
                                    D      => is_less_SIG,
                                    Q      => flag_less_SIG);

    pc_pm: pc port map(clock  => clock,
    rst       => rst,
    wr_en    => PC_write_en_SIG,
    data_in     => PC_data_in_SIG,
    data_out    => PC_data_out_SIG);

    rom_pm : rom port map(
        clk => clock,
        address => PC_data_out_SIG,
        data_out => rom_data_SIG
    );

    ram_pm: ram port map(clock      => clock,
                         write_en   => ram_write_en_SIG,
                         address    => ram_address_SIG,
                         data_in    => ram_data_in_SIG,
                         data_out   => ram_data_out_SIG);

    control_unit_pm: control_unit port map(clk               => clock,
                                            rst               => rst,
                                            rom_data            => rom_data_SIG,
                                            ram_data_in         => ram_data_in_SIG,
                                            ram_address         => ram_address_SIG,
                                            ram_write_enable        => ram_write_en_SIG,
                                            selec_regFile_input => selec_regFile_input_SIG,
                                            regA_out            => regOutA_ulaA,
                                            regB_out            => regOutB_SIG,
                                            ula_out             => ULA_output,     
                                            ula_inputB          => ULA_inputB_SIG,      
                                            ula_select_op        => ULA_selec_op_SIG,   
                                            PC_data_out         => PC_data_out_SIG, 
                                            PC_data_in          => PC_data_in_SIG, 
                                            flag_zero           => flag_zero_SIG,      
                                            flag_not_zero       => flag_not_zero_SIG,  
                                            flag_less           => flag_less_SIG,
                                            is_zero             => is_zero_SIG,        
                                            is_not_zero         => is_not_zero_SIG,     
                                            is_less             => is_less_SIG,                                                    
                                            selec_regA          => selec_regA_SIG,    
                                            selec_regB          => selec_regB_SIG,     
                                            selec_regWrite      => selec_regWrite_SIG, 
                                            not_jp_instruction => update_flag_ff,
                                            carry_sbc          => carry_subt_SIG,
                                            const               => const_SIG,
                                            wr_enable            => write_en_SIG,    
                                            pc_wr_enable         => PC_write_en_SIG);

    PC_out_data <= PC_data_out_SIG;
    rom_data <= rom_data_SIG;    
    ULA_out_data <= ULA_output;
end architecture;