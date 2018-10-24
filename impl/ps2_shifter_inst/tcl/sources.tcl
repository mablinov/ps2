set sources { \
	../../ps2_bit_rx_strobe.vhd \
	../../ps2_shifter.vhd \
	../../../mmanip/debouncer.vhd \
	../../../mmanip/strobe_if_changed.vhd \
	../../../mmanip/ssd_ctrl.vhd \
	../../ps2_shifter_inst.vhd \
}

set constraints "constraints.xdc"
set top_ent ps2_shifter_inst
set part xc7a100tcsg324-1
set outputDir bit

read_vhdl $sources
read_xdc $constraints

