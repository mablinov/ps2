library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_bit_rx_strobe is
	generic (
		DELAY: positive := 2 ** 9
	);
	port (
		clk, en, reset: in std_logic;
		ps2_clk: in std_logic;
		rx_bit_strb: out std_logic := '0'
	);
end entity;

architecture behavioural of ps2_bit_rx_strobe is
	type state is (ClkLow, ClkHigh);
	
	signal int_rx_bit_strb: std_logic := '0';
	signal state_current, state_next: state := ClkHigh;
	signal counter: natural range 0 to DELAY - 1 := 0;
begin
	rx_bit_strb <= int_rx_bit_strb;

	register_current_state: process(clk, en, reset, state_next) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state_current <= ClkHigh;
			elsif en = '1' then
				state_current <= state_next;
			end if;
		end if;
	end process;
	
	eval_next_state: process(state_current, ps2_clk, counter) is
	begin
		case state_current is
			when ClkHigh =>
				if ps2_clk = '0' and counter = DELAY - 1 then
					state_next <= ClkLow;
				else
					state_next <= ClkHigh;
				end if;

			when ClkLow =>
				if ps2_clk = '1' and counter = DELAY - 1 then
					state_next <= ClkHigh;
				else
					state_next <= ClkLow;
				end if;
	
		end case;
	end process;
	
	register_counter: process(clk, en, reset, ps2_clk, state_current, counter) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				counter <= 0;
				
			elsif en = '1' then

				case state_current is
					when ClkHigh =>
						if ps2_clk = '0' then
							if counter = DELAY - 1 then
								counter <= 0;
							else
								counter <= counter + 1;
							end if;
						else
							counter <= 0;
						end if;
					
					when ClkLow =>
						if ps2_clk = '1' then
							if counter = DELAY - 1 then
								counter <= 0;
							else
								counter <= counter + 1;
							end if;
						else 
							counter <= 0;
						end if;
				end case;
				
			end if;
		end if;
		
	end process;
	
	register_strobe: process(clk, en, reset, ps2_clk, state_current, counter) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				int_rx_bit_strb <= '0';
			elsif en = '1' then
				if state_current = ClkHigh and ps2_clk = '0' and
					counter = DELAY - 1
				  then
					int_rx_bit_strb <= '1';
				else
					int_rx_bit_strb <= '0';
				end if;
			end if;
		end if;
	end process;

end architecture;

