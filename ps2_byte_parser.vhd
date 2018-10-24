library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ps2_util.all;

entity ps2_byte_parser is
	port (
		clk: in std_logic;
		byte: in std_logic_vector(7 downto 0);
		rx_strobe: in std_logic;
		
		keycode: out ps2_keycode_T := PS2_KEY_UNKNOWN;
		kc_strobe: out std_logic := '0';
		make: out std_logic := '0';
		err: out std_logic := '0'
	);
end;

architecture rtl of ps2_byte_parser is
	type ps2_parse_state is (
		PARSE_BYTE_1,
		PARSE_SIMPLE_BREAK,
		PARSE_EXTENDED_BREAK,
		PARSE_BYTE_2
	);

	signal PS, NS: ps2_parse_state := PARSE_BYTE_1;
	
	-- Combinatorial process intercommunication signals
	signal ps2_keycode: ps2_keycode_T := PS2_KEY_UNKNOWN;
	signal got_keycode: std_logic := '0';
	signal got_make_keycode: std_logic := '1';
	signal got_error: std_logic := '0';
begin

	register_next_state: process (clk, NS, rx_strobe) is
	begin
		if rising_edge(clk) then
			if rx_strobe = '1' then
				PS <= NS;
			end if;
		end if;
	end process;

	register_outputs: process (clk, rx_strobe, got_keycode, ps2_keycode,
		got_make_keycode, got_error) is
	begin
		if rising_edge(clk) then
			if rx_strobe = '1' and (got_keycode or got_error) = '1' then
				kc_strobe <= '1';
				
				keycode <= ps2_keycode;
				make <= got_make_keycode;
				err <= got_error;
			else
				kc_strobe <= '0';
			
			end if;
		end if;
	end process;
	
	ps2_byte_parser: process (PS, byte, rx_strobe) is
	begin
	
	-- Set the defaults
		got_keycode <= '0';
		got_make_keycode <= '1';
		got_error <= '0';
		ps2_keycode <= PS2_KEY_UNKNOWN;
	
	case PS is
		when PARSE_BYTE_1 =>
			if byte = X"F0" then
				-- Have a simple break code
				NS <= PARSE_SIMPLE_BREAK;
				
			elsif byte = X"E0" then
				-- have an extended make or extended break code
				NS <= PARSE_BYTE_2;
			
			elsif get_keycode(byte) /= PS2_KEY_UNKNOWN then
				-- Have a simple make code, e.g. 1D (make "W")
				NS <= PARSE_BYTE_1;
				got_keycode <= '1';
			
				ps2_keycode <= get_keycode(byte);
			
			else
				-- Error
				NS <= PARSE_BYTE_1;
				got_error <= '1';
			end if;
			
		when PARSE_SIMPLE_BREAK =>
			if get_keycode(byte) /= PS2_KEY_UNKNOWN then
				-- Have a simple break code, e.g. F016 (break "1")
				NS <= PARSE_BYTE_1;
				got_keycode <= '1';
				got_make_keycode <= '0';
			
				ps2_keycode <= get_keycode(byte);
			
			else
				-- Error
				NS <= PARSE_BYTE_1;
				got_error <= '1';
		
			end if;
		
		when PARSE_BYTE_2 =>
			if byte = X"F0" then
				-- Have an extended break, e.g. E0F071 (break "DEL")
				NS <= PARSE_EXTENDED_BREAK;
		
			elsif get_ext_keycode(byte) /= PS2_KEY_UNKNOWN then
				-- Have an extended make, e.g. E06B (make "Left arrow")
				NS <= PARSE_BYTE_1;
				got_keycode <= '1';
			
				ps2_keycode <= get_ext_keycode(byte);
		
			else
				-- Error
				NS <= PARSE_BYTE_1;
				got_error <= '1';
		
			end if;
		
		when PARSE_EXTENDED_BREAK =>
			if get_ext_keycode(byte) /= PS2_KEY_UNKNOWN then
				-- Have an extended break, e.g. E0F071 (break "DEL")
				NS <= PARSE_BYTE_1;
				got_keycode <= '1';
			
				ps2_keycode <= get_ext_keycode(byte);
				got_make_keycode <= '0';
		
			else
				-- Error
				NS <= PARSE_BYTE_1;
				got_error <= '1';
	
			end if;

	end case;
	end process;
end;

