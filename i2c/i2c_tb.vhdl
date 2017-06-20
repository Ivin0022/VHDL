library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;        -- for addition & counting
use ieee.numeric_std.all;               -- for type conversions
use ieee.math_real.all;                 -- for the ceiling and log constant calculation functions

entity testbench is
	--empty
end testbench;

architecture tb of testbench is
	component i2c is
	port (
		clock : IN std_logic;
		reset : IN std_logic;
		en   	: IN std_logic;
		r_w   : IN std_logic;
		reg	  : INOUT std_logic_vector(7 downto 0);

		scl   : OUT std_logic;
		sda   : INOUT std_logic
	);
	end component;

	signal tb_clock, tb_reset, tb_en, tb_r_w : std_logic;
	signal tb_scl, tb_sda : std_logic;
	signal tb_reg	: std_logic_vector(7 downto 0);

begin

	UUT: i2c port map (tb_clock, tb_reset, tb_en, tb_r_w, tb_reg, tb_scl, tb_sda);

	clk_gen: process
  begin
    for i in 0 to 3 loop
      tb_clock <= '0';
      wait for 0.5 ns;
      tb_clock <= '1';
      wait for 0.5 ns;
		end loop;
    wait;
  end process clk_gen;



end tb;