library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_shifter_tb is
end entity;

architecture tb of ps2_shifter_tb is

	procedure send_packet(constant p: in std_logic_vector(0 to 10);
		signal ps2clk: out std_logic;
		signal ps2data: out std_logic)
	is
		constant pp: time := 60.00 us;
		constant tb: time := 10.00 us;
		constant ta: time := 10.00 us;
	begin
		for i in 0 to 10 loop
			ps2clk <= '1';
			wait for pp/2-tb;
			ps2data <= p(i);
			wait for tb;
			ps2clk <= '0';
			wait for ta;
			ps2data <= '0';
			wait for pp/2-ta;
		end loop;
		
		ps2clk <= '1';		
	end procedure;

	signal clk: std_logic := '1';
	
	signal ps2_clk: std_logic := '1';
	signal ps2_data: std_logic := '0';
	signal rx_bit_strb: std_logic := '0';
begin

	clk <= not clk after 5 ns;

	testbench: process
	begin
		send_packet("10011010101", ps2_clk, ps2_data);
		wait for 10 us;
		send_packet("00000011111", ps2_clk, ps2_data);
		wait for 10 us;
		send_packet("11111100000", ps2_clk, ps2_data);
		wait;
	end process;

	uut: entity work.ps2_shifter(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		ps2_data => ps2_data,
		rx_bit_strb => rx_bit_strb,
		
		rx_ps2_packet => open,
		
		ps2_start_bit => open,
		ps2_byte => open,
		ps2_parity => open,
		ps2_stop => open
	);

	pbrs: entity work.ps2_bit_rx_strobe(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		ps2_clk => ps2_clk,
		rx_bit_strb => rx_bit_strb
	);

end architecture;

