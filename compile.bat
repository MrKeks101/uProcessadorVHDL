ECHO OFF

ghdl -a control_unit.vhd
ghdl -a D_ff.vhd
ghdl -a mux2_1.vhd
ghdl -a mux4_1.vhd
ghdl -a pc.vhd
ghdl -a ram.vhd
ghdl -a reg_file.vhd
ghdl -a reg16bits.vhd
ghdl -a rom.vhd
ghdl -a state_machine.vhd
ghdl -a ula.vhd
ghdl -a top_level.vhd

PAUSE