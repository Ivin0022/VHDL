library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions

entity i2c is
	port (
		clock 	: IN std_logic;
		reset 	: IN std_logic;
		en    	: IN std_logic;
		r_w   	: IN std_logic;
		reg	  	: IN std_logic_vector(7 downto 0);

		sda_ext : INOUT std_logic;
		scl   	: OUT std_logic
		);
end i2c;

architecture i2c_arc of i2c is

	TYPE machine IS(ready, start, 
					wrt_clk_L, wrt_bit_snd, wrt_clk_H, wrt_nxt_bit, wrt_end, 
					ack_clk_L, ack1, ack_clk_H, ack3, read,
					stop); --needed states

    signal state : machine;
    signal sda : std_logic;
	signal bit_cnt : INTEGER range 0 to 7 := 7;

begin

	sda_ext <= 'Z' WHEN (sda = '1') ELSE '0';
	
	main : process (reset, clock)
	begin
		if (reset = '1') then
			sda <= '1';
			scl <= '1';
		elsif (rising_edge(clock) and (en = '1')) then
			case(state) is
				when ready =>      
					sda <= '1';
					scl <= '1';
					state <= start;

				when start =>     	
					sda <= '0';
					scl <= '1';
					state <= wrt_clk_L;

				when wrt_clk_L =>		
					scl <= '0';
					state <= wrt_bit_snd;
				
				when wrt_bit_snd =>	
					sda <= reg(bit_cnt);
					state <= wrt_clk_H;
					
				when wrt_clk_H =>  
					scl <= '1';
					state <= wrt_nxt_bit;

				when wrt_nxt_bit =>
					if (bit_cnt - 1) >= 0 then
						bit_cnt <= bit_cnt - 1;
						state <= wrt_clk_L;
					else
						bit_cnt <= 7;
						state <= ack_clk_L;
					end if;

				when ack_clk_L =>
					scl <= '0';
					state <= ack1;

				when ack1 =>
					if (r_w = '1') then
						sda <= '0';
					end if;
					state <= ack_clk_H;

				when ack_clk_H =>
					scl <= '1';
					state <= ack3; 

				when ack3 =>
					if (sda_ext = '0') then
						if (r_w = '1') then
							state <= read;
						elsif (r_w = '0') then
							state <= wrt_clk_L; 
						end if;
					else
						state <= stop;
					end if;

				when others =>
					null;
			end case;
		end if;
	end process main;
end i2c_arc;
