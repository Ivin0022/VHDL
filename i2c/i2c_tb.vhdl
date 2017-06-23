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
		clock 	: IN std_logic;
		reset 	: IN std_logic;
		en   	: IN std_logic;
		r_w   	: IN std_logic;
		reg	  	: IN std_logic_vector(7 downto 0);

		sda_ext : INOUT std_logic;
		scl   	: OUT std_logic
	);
	end component;

	signal tb_clock, tb_reset, tb_en, tb_r_w : std_logic;
	signal tb_sda, tb_scl : std_logic;
	signal tb_reg	: std_logic_vector(7 downto 0) := x"aa";

	signal clk_cnt : integer range 0 to 9 := 0;
	signal ack : std_logic;
	constant max_clock : integer := (100);

begin

  UUT: i2c port map (tb_clock, tb_reset, tb_en, tb_r_w, tb_reg, tb_sda, tb_scl);

  tb_sda <= '0' when ((clk_cnt = 9) and (tb_scl = '0')) else 'H';

  clk_gen: process
  begin

  	tb_reset <= '1'; 
	wait for 2 ns;
	tb_reset <= '0';
	wait for 1 ns;

	tb_reg <= x"aa";

	tb_en <= '1';
	tb_r_w <= tb_reg(0);


    for i in 0 to max_clock loop

    	--if ((clk_cnt = 9) and (tb_scl = '0')) then
    	--	tb_sda <= '0';
    	--else
    	--	tb_sda <= 'H';
    	--end if;

	    tb_clock <= '1';
	    wait for 0.5 ns;
	    tb_clock <= '0';
	    wait for 0.5 ns;

	end loop;
    wait;
  end process clk_gen;

  clk_countr : process (tb_scl)
  begin
    if (falling_edge(tb_scl)) then
  		if ((clk_cnt + 1) <= 9) then
	  		clk_cnt <= clk_cnt + 1;
	  	else
	  		clk_cnt <= 1;		
  		end if;
    end if;
  end process clk_countr;


end tb;