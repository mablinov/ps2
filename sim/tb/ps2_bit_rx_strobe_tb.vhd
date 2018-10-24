library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_bit_rx_strobe_tb is
end entity;

architecture tb of ps2_bit_rx_strobe_tb is
	signal clk: std_logic := '0';
	signal ps2_clk: std_logic := '0';
	signal rx_bit_strb: std_logic := '0';
begin
	clk <= not clk after 5 ns;

	process
	begin
		ps2_clk <= '0';
		wait for 2 us;
		ps2_clk <= '1';
		wait for 10 ns;
		ps2_clk <= '0';
		wait for 5.5 us;
		ps2_clk <= '1';
		wait for 2 us;
		ps2_clk <= '0';
		wait for 10 ns;
		ps2_clk <= '1';
		wait for 5.5 us;
		ps2_clk <= '0';
		wait;
	end process;
		

	uut: entity work.ps2_bit_rx_strobe(rtl)
	port map (
		clk => clk, en => '1', reset => '0',
		ps2_clk => ps2_clk,
		rx_bit_strb => rx_bit_strb
	);

end architecture;

