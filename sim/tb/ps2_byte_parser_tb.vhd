library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ps2_util.all;

entity ps2_byte_parser_tb is
end;

architecture tb of ps2_byte_parser_tb is
	constant p: time := 10 ns;
	signal clk: std_logic := '1';
	
	signal byte: std_logic_vector(7 downto 0) := X"00";
	signal rx_strobe: std_logic := '0';
	
	procedure send_byte(signal byte: out std_logic_vector(7 downto 0);
		signal rx_strobe: out std_logic;
		constant data: in std_logic_vector(7 downto 0)) is
	begin
		byte <= data;
		rx_strobe <= '1';
		wait for p;
		
		byte <= X"00";
		rx_strobe <= '0';
	end procedure;
begin

	clk <= not clk after p/2;
	
	testbench: process
	begin
		wait for 2*p;
		
		-- Literal "1" make code
		send_byte(byte, rx_strobe, X"16");
		wait for 2*p;
		
		-- Literal "A" make code
		send_byte(byte, rx_strobe, X"1c");
		wait for 2*p;
		
		-- Literal "0" make code
		send_byte(byte, rx_strobe, X"45");
		wait for 2*p;
		
		-- Literal "1" break code
		send_byte(byte, rx_strobe, X"F0");
		wait for 2*p;
		send_byte(byte, rx_strobe, X"16");
		wait for 3*p;
		
		-- Up arrow make code
		send_byte(byte, rx_strobe, X"E0");
		wait for p;
		send_byte(byte, rx_strobe, X"75");
		wait for p * 3;
		
		-- Up arrow break code
		send_byte(byte, rx_strobe, X"E0");
		wait for p;
		send_byte(byte, rx_strobe, X"F0");
		wait for p;
		send_byte(byte, rx_strobe, X"75");
		wait for p*3;
		
		-- Down arrow make code
		send_byte(byte, rx_strobe, X"E0");
		wait for p;
		send_byte(byte, rx_strobe, X"72");
		wait for p * 3;
		
		-- Down arrow break code
		send_byte(byte, rx_strobe, X"E0");
		wait for p;
		send_byte(byte, rx_strobe, X"F0");
		wait for p;
		send_byte(byte, rx_strobe, X"72");
		
		wait;
	end process;

	uut: entity work.ps2_byte_parser(rtl)
	port map (
		clk => clk,
		byte => byte,
		rx_strobe => rx_strobe,
		
		keycode => open,
		kc_strobe => open,
		make => open,
		err => open
	);

end;

