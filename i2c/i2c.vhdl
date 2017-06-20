library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions

entity i2c is
	port (
		clock : IN std_logic;
		reset : IN std_logic;
		en   	: IN std_logic;
		r_w   : IN std_logic;
		reg	  : INOUT std_logic_vector(7 downto 0);

		scl   : OUT std_logic;
		sda   : INOUT std_logic
	);
end i2c;

architecture i2c_arc of i2c is

begin

	reg <= x"aa";
	main : process (reset, clock)
	begin
	  if (reset = '1') then
	    sda <= '1';
	    scl <= '1';
	  elsif (rising_edge(clock)) then
 			sda <= not sda;
	    scl <= not scl;
	  end if;

	end process main;
end i2c_arc;