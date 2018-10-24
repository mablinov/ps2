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

architecture rtl of ps2_bit_rx_strobe is
	signal ps2_clk_db: std_logic := '0';
	signal ps2_clk_db_s: std_logic := '0';
begin
	rx_bit_strb <= (not ps2_clk_db) and ps2_clk_db_s;

	debouncer_ps2_clk_inst: entity work.debouncer(rtl)
	generic map (
		sampling_cycles => DELAY
	) port map (
		clk => clk, en => en, reset => reset,
		in_sig => ps2_clk,
		out_sig => ps2_clk_db
	);

	strober_ps2_clk_inst: entity work.strobe_if_changed(rtl)
	port map (
		clk => clk, en => en, reset => reset,
		in_sig => ps2_clk_db,
		strb => ps2_clk_db_s
	);
end;

