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

	TYPE machine IS(ready, start, command1, command2, command3, command4, command_end, 
								  ack, ack2, ack3, ack4,
								  msg1, msg2, msg3, msg4, msg_end, stop); --needed states
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
					state <= command1;

				when command1 =>		
					scl <= '0';
					state <= command2;
				
				when command2 =>	
					sda <= reg(bit_cnt);
					state <= command3;
					
				when command3 =>  
					scl <= '1';
					state <= command4;

				when command4 =>
					if (bit_cnt - 1) >= 0 then
						bit_cnt <= bit_cnt - 1;
						state <= command1;
					else
						bit_cnt <= 7;
						state <= command_end;
					end if;

				when command_end =>
					scl <= '0';
					state <= ack;

				when ack =>
					sda <= sda_ext;
					state <= ack2;

				when ack2 =>
					scl <= '1';
					state <= ack3; 

				when ack3 =>
					state <= ack4; 

				when ack4 =>
					scl <= '0';
					state <= msg1; 

				when msg1 =>		
					scl <= '0';
					state <= msg2;
				
				when msg2 =>	
					sda <= reg(bit_cnt);
					state <= msg3;
					
				when msg3 =>  
					scl <= '1';
					state <= msg4;

				when msg4 =>
					if (bit_cnt - 1) >= 0 then
						bit_cnt <= bit_cnt - 1;
						state <= msg1;
					else
						bit_cnt <= 7;
						state <= msg_end;
					end if;

				when msg_end =>
					scl <= '0';
					state <= stop;

				when others =>
					null;
			end case;
		end if;
	end process main;
end i2c_arc;
