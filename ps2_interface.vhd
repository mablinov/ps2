library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ps2_util.all;

entity ps2_interface is
	port (
		clk, en, reset: in std_logic;
		ps2_clk: in std_logic;
		ps2_data: in std_logic;

		keycode: out ps2_keycode_T := PS2_KEY_UNKNOWN;
		kc_strobe: out std_logic := '0';
		make: out std_logic := '0';
		err: out std_logic := '0'
	);
end;

architecture rtl of ps2_interface is
	signal ps2_byte: std_logic_vector(7 downto 0) := X"00";
	signal rx_bit_strb: std_logic := '0';
	signal rx_ps2_packet: std_logic := '0';
begin
	ps2_bp_inst: entity work.ps2_byte_parser(rtl)
	port map (
		clk => clk,
		byte => ps2_byte,
		rx_strobe => rx_ps2_packet,
		
		keycode => keycode,
		kc_strobe => kc_strobe,
		make => make,
		err => err
	);
	
	ps2_s_inst: entity work.ps2_shifter(rtl)
	port map (
		clk => clk, en => en, reset => reset,
		ps2_data => ps2_data,
		rx_bit_strb => rx_bit_strb,
		
		rx_ps2_packet => rx_ps2_packet,
		
		ps2_start_bit => open,
		ps2_byte => ps2_byte,
		ps2_parity => open,
		ps2_stop => open
	);
	
	ps2_brs_inst: entity work.ps2_bit_rx_strobe(rtl)
	generic map (
		DELAY => 2 ** 8
	) port map (
		clk => clk, en => en, reset => reset,
		ps2_clk => ps2_clk,
		rx_bit_strb => rx_bit_strb
	);
end;

