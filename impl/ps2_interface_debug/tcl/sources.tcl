set sources { \
	../../../signals/debouncer.vhd \
	../../../signals/strobe_if_changed.vhd \
	../../../ssd/ssd_ctrl.vhd \
	../../ps2_util.vhd \
	../../ps2_bit_rx_strobe.vhd \
	../../ps2_shifter.vhd \
	../../ps2_byte_parser.vhd \
	../../ps2_interface.vhd \
	../../ps2_interface_debug.vhd \
}

set constraints "constraints.xdc"
set top_ent ps2_interface_debug
set part xc7a100tcsg324-1
set outputDir bit

read_vhdl $sources
read_xdc $constraints

