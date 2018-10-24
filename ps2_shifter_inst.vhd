library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_shifter_inst is
	port (
		clk: in std_logic;
		ps2_clk, ps2_data: in std_logic;
		
		dig_en: out std_logic_vector(7 downto 0);
		seg_cs: out std_logic_vector(7 downto 0)
	);
end;

architecture rtl of ps2_shifter_inst is

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

	signal d7, d6, d5, d4, d3, d2, d1, d0: std_logic_vector(7 downto 0) := X"00";

	-- PS2 signals
	signal rx_bit_strb: std_logic := '0';
	
	signal rx_ps2_packet: std_logic := '0';
	signal ps2_start_bit: std_logic := '0';
	signal ps2_byte: std_logic_vector(7 downto 0) := X"00";
	signal ps2_parity: std_logic := '0';
	signal ps2_stop: std_logic := '0';
begin

	d7 <= hex(X"0");
	d6 <= hex(X"0");
	d5 <= hex(X"0");
	
	set_digits: process (clk, ps2_start_bit, ps2_byte, ps2_parity, ps2_stop,
		rx_ps2_packet) is
	begin
		if rising_edge(clk) then
			if rx_ps2_packet = '1' then
				d4 <= hex("000" & ps2_start_bit);
				d3 <= hex(ps2_byte(7 downto 4));
				d2 <= hex(ps2_byte(3 downto 0));
				d1 <= hex("000" & ps2_parity);
				d0 <= hex("000" & ps2_stop);
			end if;
		end if;
	end process;

	ssd_ctrl_inst: entity work.ssd_ctrl(rtl)
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

	ps2_brs_inst: entity work.ps2_bit_rx_strobe(rtl)
	generic map (
		DELAY => 16
	)
	port map (
		clk => clk, en => '1', reset => '0',
		ps2_clk => ps2_clk,
		rx_bit_strb => rx_bit_strb
	);

	ps2_shifter_inst: entity work.ps2_shifter(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		
		ps2_data => ps2_data,
		rx_bit_strb => rx_bit_strb,
		rx_ps2_packet => rx_ps2_packet,
		
		ps2_start_bit => ps2_start_bit,
		ps2_byte => ps2_byte,
		ps2_parity => ps2_parity,
		ps2_stop => ps2_stop
	);
end;

