library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ps2_util.all;

entity ps2_interface_test is
	port (
		clk: in std_logic;
		ps2_clk, ps2_data: in std_logic;
		seg_cs, dig_en: out std_logic_vector(7 downto 0) := X"00"
	);
end;

architecture rtl of ps2_interface_test is
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
	
	constant PS2_KEYS: natural := ps2_keycode_T'pos(ps2_keycode_T'right);
	constant PS2_MAX_ID: natural := PS2_KEYS + 1;

	signal kp_count: natural range 0 to 2 ** 8 - 1 := 0;
	signal kp_index: natural range 0 to PS2_MAX_ID := 0;
	
	-- 7-Segment display interface signals
	signal d7, d6, d5, d4, d3, d2, d1, d0: std_logic_vector(7 downto 0) := X"00";
	
	-- PS2 Interface signals
	signal keycode: ps2_keycode_T := PS2_KEY_UNKNOWN;
	signal kc_strobe, make, err: std_logic := '0';

	signal kp_count_slv: std_logic_vector(7 downto 0) := X"00";
	signal kp_index_slv: std_logic_vector(7 downto 0) := X"00";

begin

	kp_index <= ps2_keycode_T'pos( keycode );

	kp_count_slv <= std_logic_vector(to_unsigned(kp_count, 8));
	kp_index_slv <= std_logic_vector(to_unsigned(kp_index, 8));

	main: process (clk, kp_count, kp_index, kc_strobe, make, err,
		kp_count_slv, kp_index_slv)
	begin
	
		if rising_edge(clk) then
			if kc_strobe = '1' then
				d7 <= hex(kp_count_slv(7 downto 4));
				d6 <= hex(kp_count_slv(3 downto 0));
				d5 <= hex("000" & make);
				d4 <= hex("000" & err);
				d3 <= hex(kp_index_slv(7 downto 4));
				d2 <= hex(kp_index_slv(3 downto 0));
				
				if kp_count = 2 ** 8 - 1 then
					kp_count <= 0;
				else
					kp_count <= kp_count + 1;
				end if;
			end if;
		end if;
	end process;

	ps2_intf: entity work.ps2_interface(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		
		ps2_clk => ps2_clk,
		ps2_data => ps2_data,
		
		keycode => keycode,
		kc_strobe => kc_strobe,
		make => make,
		err => err
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

