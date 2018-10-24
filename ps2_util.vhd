library ieee;
use ieee.std_logic_1164.all;

package ps2_util is
	type ps2_keycode_T is (
		-- Normal set:
		PS2_KEY_A, PS2_KEY_B, PS2_KEY_C, PS2_KEY_D, PS2_KEY_E,
		PS2_KEY_F, PS2_KEY_G, PS2_KEY_H, PS2_KEY_I, PS2_KEY_J,
		PS2_KEY_K, PS2_KEY_L, PS2_KEY_M, PS2_KEY_N, PS2_KEY_O,
		PS2_KEY_P, PS2_KEY_Q, PS2_KEY_R, PS2_KEY_S, PS2_KEY_T,
		PS2_KEY_U, PS2_KEY_V, PS2_KEY_W, PS2_KEY_X, PS2_KEY_Y,
		PS2_KEY_Z,
		
		PS2_KEY_0, PS2_KEY_1, PS2_KEY_2, PS2_KEY_3, PS2_KEY_4, PS2_KEY_5,
		PS2_KEY_6, PS2_KEY_7, PS2_KEY_8, PS2_KEY_9,
		
		PS2_KEY_F1, PS2_KEY_F2, PS2_KEY_F3, PS2_KEY_F4, PS2_KEY_F5,
		PS2_KEY_F6, PS2_KEY_F7, PS2_KEY_F8, PS2_KEY_F9, PS2_KEY_F10,
		PS2_KEY_F11, PS2_KEY_F12,
		
		-- Extended set:
		PS2_KEY_ARROW_UP, PS2_KEY_ARROW_LEFT, PS2_KEY_ARROW_DOWN,
		PS2_KEY_ARROW_RIGHT,
		
		PS2_KEY_UNKNOWN
	);

	function get_keycode(b: std_logic_vector(7 downto 0)) return ps2_keycode_T;
	function get_ext_keycode(b: std_logic_vector(7 downto 0)) return ps2_keycode_T;
end package;

package body ps2_util is
	function get_keycode(b: std_logic_vector(7 downto 0)) return ps2_keycode_T is
	begin
		case b is
			when X"1C" => return PS2_KEY_A;
			when X"32" => return PS2_KEY_B;
			when X"21" => return PS2_KEY_C;
			when X"23" => return PS2_KEY_D;
			when X"24" => return PS2_KEY_E;
			when X"2b" => return PS2_KEY_F;
			when X"34" => return PS2_KEY_G;
			when X"33" => return PS2_KEY_H;
			when X"43" => return PS2_KEY_I;
			when X"3B" => return PS2_KEY_J;
			when X"42" => return PS2_KEY_K;
			when X"4B" => return PS2_KEY_L;
			when X"3A" => return PS2_KEY_M;
			when X"31" => return PS2_KEY_N;
			when X"44" => return PS2_KEY_O;
			when X"4D" => return PS2_KEY_P;
			when X"15" => return PS2_KEY_Q;
			when X"2D" => return PS2_KEY_R;
			when X"1B" => return PS2_KEY_S;
			when X"2C" => return PS2_KEY_T;
			when X"3C" => return PS2_KEY_U;
			when X"2A" => return PS2_KEY_V;
			when X"1D" => return PS2_KEY_W;
			when X"22" => return PS2_KEY_X;
			when X"35" => return PS2_KEY_Y;
			when X"1A" => return PS2_KEY_Z;
			
			when X"05" => return PS2_KEY_F1;
			when X"06" => return PS2_KEY_F2;
			when X"04" => return PS2_KEY_F3;
			when X"0C" => return PS2_KEY_F4;
			when X"03" => return PS2_KEY_F5;
			when X"0B" => return PS2_KEY_F6;
			when X"83" => return PS2_KEY_F7;
			when X"0A" => return PS2_KEY_F8;
			when X"01" => return PS2_KEY_F9;
			when X"09" => return PS2_KEY_F10;
			when X"78" => return PS2_KEY_F11;
			when X"07" => return PS2_KEY_F12;
			
			when X"45" => return PS2_KEY_0;
			when X"16" => return PS2_KEY_1;
			when X"1e" => return PS2_KEY_2;
			when X"26" => return PS2_KEY_3;
			when X"25" => return PS2_KEY_4;
			when X"2e" => return PS2_KEY_5;
			when X"36" => return PS2_KEY_6;
			when X"3d" => return PS2_KEY_7;
			when X"3e" => return PS2_KEY_8;
			when X"46" => return PS2_KEY_9;
	
			when others => return PS2_KEY_UNKNOWN;
		end case;
	end function;

	function get_ext_keycode(b: std_logic_vector(7 downto 0)) return ps2_keycode_T is
	begin
		case b is
			when X"75" => return PS2_KEY_ARROW_UP;
			when X"6B" => return PS2_KEY_ARROW_LEFT;
			when X"72" => return PS2_KEY_ARROW_DOWN;
			when X"74" => return PS2_KEY_ARROW_RIGHT;
	
			when others => return PS2_KEY_UNKNOWN;
		end case;
	end function;
end package body;

