library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ps2_util.all;

entity ps2_interface_debug is
	port (
		clk: in std_logic;
		ps2_clk, ps2_data: in std_logic;
		seg_cs, dig_en: out std_logic_vector(7 downto 0) := X"00"
	);
end;

architecture rtl of ps2_interface_debug is
	constant en: std_logic := '1';
	constant reset: std_logic := '0';
	
	function hex(arg: std_logic_vector(3 downto 0)) return std_logic_vector is
		variable seg_cs: std_logic_vector(7 downto 0) := X"00";
	begin
		case arg is
			when "0000" => seg_cs := "11111100";
			when "0001" => seg_cs := "01100000";
			when "0010" => seg_cs := "11011010";
			when "0011" => seg_cs := "11110010";
			when "0100" => seg_cs := "01100110";
			when "0101" => seg_cs := "10110110";
			when "0110" => seg_cs := "10111110";
			when "0111" => seg_cs := "11100000";
			when "1000" => seg_cs := "11111110";
			when "1001" => seg_cs := "11100110";
			when "1010" => seg_cs := "11101110";
			when "1011" => seg_cs := "00111110";
			when "1100" => seg_cs := "10011100";
			when "1101" => seg_cs := "01111010";
			when "1110" => seg_cs := "10011110";
			when "1111" => seg_cs := "10001110";
			when others => seg_cs := "00000010";
		end case;
		
		return seg_cs;
	end function;
	
	signal keycode: ps2_keycode_T := PS2_KEY_UNKNOWN;
	signal kc_strobe: std_logic := '0';
	signal make: std_logic := '0';
	signal err: std_logic := '0';
	
	signal digit_counter: natural range 0 to 3 := 0;
	
	-- 7-Segment display interface signals
	signal d7, d6, d5, d4, d3, d2, d1, d0: std_logic_vector(7 downto 0) := X"00";
	
	-- PS2 Interface intercommunication signals
	signal ps2_byte: std_logic_vector(7 downto 0) := X"00";
	signal rx_bit_strb: std_logic := '0';
	signal rx_ps2_packet: std_logic := '0';
begin

	set_digit: process (clk, rx_ps2_packet, digit_counter, ps2_byte) is
	begin
		if rising_edge(clk) then
			if rx_ps2_packet = '1' then
				
				case digit_counter is
				when 0 =>
					d7 <= hex(ps2_byte(7 downto 4));
					d6 <= hex(ps2_byte(3 downto 0));
				when 1 =>
					d5 <= hex(ps2_byte(7 downto 4));
					d4 <= hex(ps2_byte(3 downto 0));
				when 2 =>
					d3 <= hex(ps2_byte(7 downto 4));
					d2 <= hex(ps2_byte(3 downto 0));
				when 3 =>
					d1 <= hex(ps2_byte(7 downto 4));
					d0 <= hex(ps2_byte(3 downto 0));
				end case;
			
			end if;
		end if;
	end process;

	inc_ctr: process (clk, kc_strobe, digit_counter, rx_ps2_packet) is
	begin
		if rising_edge(clk) then
			if kc_strobe = '1' then
				digit_counter <= 0;
			
			elsif rx_ps2_packet = '1' then
				if digit_counter = 3 then
					digit_counter <= 0;
				else
					digit_counter <= digit_counter + 1;
				end if;
			end if;
		end if;
	end process;

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

	ssd_intf: entity work.ssd_ctrl(rtl)
	port map (
		clk => clk,
		d7 => d7,
		d6 => d6,
		d5 => d5,
		d4 => d4,
		d3 => d3,
		d2 => d2,
		d1 => d1,
		d0 => d0,
		dig_en => dig_en,
		seg_cs => seg_cs
	);
end;

