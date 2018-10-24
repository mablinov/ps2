library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_shifter_inst_tb is
end;

architecture tb of ps2_shifter_inst_tb is
	constant p: time := 10 ns;
	signal clk: std_logic := '0';
	
	signal ps2_clk: std_logic := '1';
	signal ps2_data: std_logic := '0';
		
	signal dig_en: std_logic_vector(7 downto 0) := X"00";
	signal seg_cs: std_logic_vector(7 downto 0) := X"00";
	
	procedure send_ps2_packet(constant p: in std_logic_vector(10 downto 0);
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
			ps2data <= p(0);
			wait for tb;
			ps2clk <= '0';
			wait for ta;
			ps2data <= '0';
			wait for pp/2-ta;
		end loop;
		
		ps2clk <= '1';		
		
	end procedure;
begin
	clk <= not clk after p/2;
	
	testbench: process
	begin
		wait for p*2;
		
		send_ps2_packet("11111111111", ps2_clk, ps2_data);
		
		wait;
	end process;
	
	uut: entity work.ps2_shifter_inst(rtl)
	port map (
		clk => clk,
		ps2_clk => ps2_clk,
		ps2_data => ps2_data,
		
		dig_en => dig_en,
		seg_cs => seg_cs
	);
	
end architecture;

