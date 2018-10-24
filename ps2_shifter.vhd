library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_shifter is
	port (
		clk, en, reset: in std_logic;
		ps2_data: in std_logic;
		rx_bit_strb: in std_logic;

		rx_ps2_packet: out std_logic := '0';

		ps2_start_bit: out std_logic := '0';
		ps2_byte: out std_logic_vector(7 downto 0) := X"00";
		ps2_parity: out std_logic := '0';
		ps2_stop: out std_logic := '0'
	);
end entity;

architecture rtl of ps2_shifter is
	signal int_rx_ps2_packet: std_logic := '0';

	signal ps2_packet: std_logic_vector(0 to 10) := (others => '0');
	signal bit_count: natural range 0 to ps2_packet'length - 1 := 0;
begin
	rx_ps2_packet <= int_rx_ps2_packet;
	
	ps2_start_bit <= ps2_packet(10);
	ps2_byte(0) <= ps2_packet(9);
	ps2_byte(1) <= ps2_packet(8);
	ps2_byte(2) <= ps2_packet(7);
	ps2_byte(3) <= ps2_packet(6);
	ps2_byte(4) <= ps2_packet(5);
	ps2_byte(5) <= ps2_packet(4);
	ps2_byte(6) <= ps2_packet(3);
	ps2_byte(7) <= ps2_packet(2);

	ps2_parity <= ps2_packet(1);
	ps2_stop <= ps2_packet(0);
	
	shift_data_in: process (clk, en, reset, rx_bit_strb, ps2_packet, ps2_data) is
	begin
		if rising_edge(clk) then
		
			if reset = '1' then
				ps2_packet <= (others => '0');
				
			elsif en = '1' then
				if rx_bit_strb = '1' then
					ps2_packet(1 to 10) <= ps2_packet(0 to 9);
					ps2_packet(0) <= ps2_data;
				end if;
			end if;
			
		end if;
	end process;
	
	count_data: process (clk, en, reset, rx_bit_strb, bit_count) is
	begin
		if rising_edge(clk) then
		
			if reset = '1' then
				bit_count <= 0;
			
			elsif en = '1' then
				if rx_bit_strb = '1' then
					if bit_count = ps2_packet'length - 1 then
						bit_count <= 0;
					else
						bit_count <= bit_count + 1;
					end if;
				end if;
			end if;
			
		end if;
	end process;
	
	assert_int_rx_ps2_packet: process (clk, bit_count, rx_bit_strb) is
	begin
		if rising_edge(clk) then
			if bit_count = ps2_packet'length - 1 and rx_bit_strb = '1' then
				int_rx_ps2_packet <= '1';
			else
				int_rx_ps2_packet <= '0';
			end if;			
		end if;
	end process;
					
end architecture;

