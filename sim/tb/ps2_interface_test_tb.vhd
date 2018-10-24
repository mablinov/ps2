library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ps2_util.all;

entity ps2_interface_test_tb is
end;

architecture tb of ps2_interface_test_tb is

	procedure send_byte(constant byte: in std_logic_vector(7 downto 0);
		signal ps2_clk: out std_logic;
		signal ps2_data: out std_logic)
	is
		constant p: time := 60.00 us;
		constant tb: time := 10.00 us;
		constant ta: time := 10.00 us;
	begin
		-- First, send start bit
		ps2_clk <= '1';
		wait for p/2-tb;
		ps2_data <= '0';

		wait for tb;
		ps2_clk <= '0';
		wait for ta;

		wait for p/2-ta;
		
		-- Now send bits
		
		for i in 0 to 7 loop
			ps2_clk <= '1';
			wait for p/2-tb;
			ps2_data <= byte(i);
			wait for tb;
			ps2_clk <= '0';
			wait for ta;
			ps2_data <= '0';
			wait for p/2-ta;
		end loop;
		
		-- Now send parity and stop bits (FIXME: parity is just '1' always.)
		for i in 0 to 1 loop
			ps2_clk <= '1';
			wait for p/2-tb;
			ps2_data <= '1';
			wait for tb;
			ps2_clk <= '0';
			wait for ta;
			ps2_data <= '0';
			wait for p/2-ta;
		end loop;
		
		-- Done.
		ps2_clk <= '1';
	end procedure;
	
	constant p: time := 10 ns;
	signal clk: std_logic := '0';
	signal ps2_clk: std_logic := '1';
	signal ps2_data: std_logic := '0';
	signal seg_cs, dig_en: std_logic_vector(7 downto 0) := X"00";
begin

	clk <= not clk after p/2;

	testbench: process
	begin
		wait for 2*p;
		-- Send literal "A"
		send_byte(X"1C", ps2_clk, ps2_data);
		wait for 300 us;
		
		-- Send literal "A"
		send_byte(X"45", ps2_clk, ps2_data);
		wait for 300 us;
		
		-- Send break literal "1"
		send_byte(X"F0", ps2_clk, ps2_data);
		wait for 100 us;
		send_byte(X"16", ps2_clk, ps2_data);
		wait for 300 us;

		-- Send literal "Up arrow"
		send_byte(X"E0", ps2_clk, ps2_data);
		wait for 100 us;
		send_byte(X"75", ps2_clk, ps2_data);
		wait for 300 us;

		-- Send break literal "Up arrow"
		send_byte(X"E0", ps2_clk, ps2_data);
		wait for 100 us;
		send_byte(X"F0", ps2_clk, ps2_data);
		wait for 100 us;
		send_byte(X"75", ps2_clk, ps2_data);
		wait for 300 us;
		
		wait;
		
	end process;

	uut: entity work.ps2_interface_test(rtl)
	port map (
		clk => clk,
		ps2_clk => ps2_clk, ps2_data => ps2_data,
		seg_cs => seg_cs,
		dig_en => dig_en
	);

end;

