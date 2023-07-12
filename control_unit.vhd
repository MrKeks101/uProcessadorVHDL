library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
    port(
        clk, rst, flag_zero,flag_not_zero,carry_sbc,flag_less : in std_logic;

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
end entity;

architecture a_control_unit of control_unit is
    component state_machine is
        port(
            clk,rst : in std_logic;
            state : out unsigned(1 downto 0)
        );
    end component;

    signal opcode : unsigned(3 downto 0);
    signal state_signal : unsigned(1 downto 0);
    signal jp_address : unsigned(6 downto 0);
    signal jp_en : std_logic;

    signal jp_condition : unsigned(1 downto 0); -- Recebe a parte da instrução que checa a condiçaõ de jump

    constant fetch_state        : unsigned(1 downto 0) := "00";
    constant decode_state       : unsigned(1 downto 0) := "01";
    constant execution_state    : unsigned(1 downto 0) := "10";

    --Instruções
    constant nop_opcode     : unsigned(3 downto 0) := "0000";   -- NOP
    constant load_opcode    : unsigned(3 downto 0) := "0001";   -- LDA <reg>, <value>
    constant copy_opcode    : unsigned(3 downto 0) := "0010";   -- TAX <reg>, <reg>
    constant add_opcode     : unsigned(3 downto 0) := "0011";   -- ADC <reg>, <reg>
    constant subt_opcode    : unsigned(3 downto 0) := "0100";   -- SBC <reg>, <reg>
    constant cmp_opcode     : unsigned(3 downto 0) := "0101";   -- CMP <reg>, <reg>
    constant loadRAM_opcode : unsigned(3 downto 0) := "0111";   -- LDA <address>, <reg>
    constant readRAM_opcode : unsigned(3 downto 0) := "1000";   -- LDX <reg>, <reg>
    constant jmpa_opcode    : unsigned(3 downto 0) := "1101";   -- BEQ <condition code>, <address>
    constant jmpr_opcode    : unsigned(3 downto 0) := "1110";   -- JMP <condition code>, <value>
    constant jmps_opcode    : unsigned(3 downto 0) := "1111";   -- JSR <address>

    -- ULA
    constant sum_operation  : unsigned(1 downto 0) := "00";
    constant subt_operation : unsigned(1 downto 0) := "01";
    constant less_operation : unsigned(1 downto 0) := "10";
    constant dif_operation  : unsigned(1 downto 0) := "11";

    constant equal_zero  : unsigned(1 downto 0) := "01";
    constant not_zero    : unsigned(1 downto 0) := "10";
    constant less        : unsigned(1 downto 0) := "11";

    constant selec_const     : std_logic := '0';
    constant selec_mux_regB  : std_logic := '1';

begin
    state_machine1 : state_machine port map(
        clk => clk,
        rst => rst,
        state => state_signal
    );

---------------------------------- Ciclo Fetch -------------------------------------------
    pc_wr_enable <= '1' when state_signal = fetch_state else
        '0';


----------------------------------Ciclo Decode------------------------------------------
    opcode <= rom_data(15 downto 12);

    ram_address <= rom_data(9 downto 3) when (opcode = loadRAM_opcode and rom_data(11 downto 10) = "00") else
                   regA_out(6 downto 0) when (opcode = loadRAM_opcode and rom_data(11 downto 10) = "01") else
                   regB_out(6 downto 0) when (opcode = readRAM_opcode) else
                   "0000000";

    ram_data_in <= regB_out when (opcode = loadRAM_opcode) else
                "0000000000000000";

                ---------- Prepara condição para o jump
    jp_condition <= rom_data(11 downto 10) when (opcode = jmpa_opcode or opcode = jmpr_opcode) else
                   "00";

    ---------------------------Endereço do jump---------------
    jp_address <= rom_data(6 downto 0)  when (opcode = jmps_opcode or opcode = jmpa_opcode) else
                   (rom_data(6 downto 0) + PC_data_out) when (opcode = jmpr_opcode) else
                   "0000000";

    jp_en <= '1' when (opcode = jmps_opcode or ((opcode = jmpa_opcode or opcode = jmpr_opcode) and 
                   ((flag_zero = '1' and jp_condition = equal_zero)   or
                    (flag_not_zero = '1' and jp_condition = not_zero) or
                    (flag_less = '1' and jp_condition = less)))) else
                     '0';   

    ula_select_op <= sum_operation when opcode = load_opcode else
                    sum_operation when opcode = add_opcode  else
                    subt_operation when opcode = subt_opcode  else
                    less_operation when opcode = cmp_opcode else
                    "00";

                    -------------------Ciclo Execute----------------------------------------------

    selec_regA <= "000" when (opcode = load_opcode or opcode = copy_opcode) else
        rom_data(5 downto 3)  when (opcode = loadRAM_opcode and rom_data(11 downto 10) = "01")  else
        rom_data(11 downto 9) when (opcode = add_opcode or opcode = subt_opcode or opcode = cmp_opcode) else 
        "000";
                                                    
    selec_regB <= rom_data(8 downto 6) when (opcode = copy_opcode) or 
        (opcode = add_opcode)  or
        (opcode = subt_opcode) or
        (opcode = cmp_opcode)  or
        (opcode = readRAM_opcode) else
        rom_data(2 downto 0) when (opcode = loadRAM_opcode) else 
        "000";
                                  
                                      -- Concatena constante para entrar na ULA
    const <= "0000000" & rom_data(8 downto 0) when rom_data(8) = '0' else 
            "1111111" & rom_data(8 downto 0); 
                                  
    selec_regWrite <= rom_data(11 downto 9);
                                  
    PC_data_in <= PC_data_out + "0000001" when jp_en = '0' else
            jp_address when jp_en = '1';
                                      
    -- Decide se o input dá ULA será do regB ou constante             
    ula_inputB <= selec_const when opcode = load_opcode else
                selec_mux_regB;

    wr_enable <= '1' when (state_signal = execution_state and ((opcode = load_opcode) or 
                                                            (opcode = copy_opcode) or 
                                                            (opcode = add_opcode)  or 
                                                            (opcode = subt_opcode) or 
                                                            (opcode = readRAM_opcode))) else
                '0';

    ram_write_enable <= '1' when (state_signal = execution_state and (opcode = loadRAM_opcode)) else
                    '0';
    
    -- Decide se o input no banco de registradores virá da ULA ou da RAM
    selec_regFile_input <= '1' when (opcode = readRAM_opcode) else
                            '0';

    ----- Sinais que permitem o uso das jump conditions -----
    is_zero <= '1' when (((opcode = add_opcode)  or 
                        (opcode = subt_opcode)) and ula_out = "0000000000000000") else
                '0';
    
    is_not_zero <= '0' when (((opcode = add_opcode)  or 
                            (opcode = subt_opcode)) and ula_out = "0000000000000000") else
                    '1';

    is_less <= '1' when ((opcode = cmp_opcode) and carry_sbc = '1') else
                '0';
    -----------------------------Flag que só ativa se for instrução de jump------------------------------------

    not_jp_instruction <= '1' when (state_signal = execution_state and ((opcode = load_opcode) or 
                                                                    (opcode = copy_opcode) or 
                                                                    (opcode = add_opcode)  or 
                                                                    (opcode = subt_opcode) or
                                                                    (opcode = cmp_opcode)  or
                                                                    (opcode = nop_opcode))) else
                            '0';                                                    
    

end architecture;