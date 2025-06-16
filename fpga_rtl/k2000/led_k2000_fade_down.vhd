-------------------------------------------------------------------------------
--  Compagny    : levelup-fpga-design
--  Author      : gvr
--  Created     : 10/06/2025
--
--  Copyright (c) 2025 levelup-fpga-design
--
--  This file is part of the levelup-fpga-design distibuted sources.
--
--  License:
--    - Free to use, modify, and distribute for **non-commercial** purposes.
--    - For **commercial** use, you must obtain a license by contacting:
--        contact@levelup-fpga.fr or directly at gvanroyen@levelup-fpga.fr
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
--  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
--  DEALINGS IN THE SOFTWARE.
-------------------------------------------------------------------------------

LIBRARY IEEE ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_arith.all ;
USE ieee.std_logic_unsigned.all ;

-- generic data width to serial data with 8 bit header and 8 bit CRC

entity led_k2000_fade_down IS
	generic(
	        g_led_polarity      : std_logic := '1';
			g_data_width 		: integer   := 8;
	 		g_speed_clk_divide 	: integer   := 8;
	        g_prescale_div   : integer := 5; --output-pwm frequency = 100*(clk_frequency/g_prescale_cycles)
			g_fade_step_cpt  : integer := 5  --number of pwm cycles before changing fade level (level is between 0 to 100% brighness)
	 );
   PORT(
           clk		     : in std_logic;
           rst_n         : in std_logic;
           led_out       : out std_logic_vector(g_data_width-1 downto 0)
       );
end led_k2000_fade_down;

ARCHITECTURE behave OF led_k2000_fade_down IS


component led_k2000 IS
	generic(
	        g_led_polarity      : std_logic := '1';
			g_data_width 		: integer   := 8;
	 		g_speed_clk_divide 	: integer   := 8
	 );
   PORT(
           clk		 : in std_logic;
           rst_n         : in std_logic;
           led_out       : out std_logic_vector(g_data_width-1 downto 0)
       );
end component;

component led_fade_down IS
	generic(
	        g_prescale_div   : integer := 5; --output-pwm frequency = 100*(clk_frequency/g_prescale_cycles)
			g_fade_step_cpt  : integer := 5  --number of pwm cycles before changing fade level (level is between 0 to 100% brighness)
	 );
   PORT(
           sys_clk         : in std_logic;
           rst_n           : in std_logic;
		   led_in          : in std_logic;
           led_out         : out std_logic -- faded output led
       );
end component;


signal s_led_std        	: std_logic_vector(g_data_width-1 downto 0);






BEGIN



u1_led_k2000 : led_k2000
	generic map(
	        g_led_polarity       => g_led_polarity        , --=>'1' ,
		g_data_width 	         => g_data_width 	   , --=> 8  ,
	 	g_speed_clk_divide       => g_speed_clk_divide     --=> 30000000,
	 )
   PORT map(
           clk		     => clk ,
           rst_n         => rst_n        ,
           led_out       => s_led_std
       );



uN_led_fade_down : for i in 0 to g_data_width-1 generate

    u_led_fade_down : led_fade_down
    	generic map(
    	        g_prescale_div  => g_prescale_div  , -- : integer := 5, --output-pwm frequency = 100*(clk_frequency/g_prescale_cycles)
    			g_fade_step_cpt => g_fade_step_cpt   -- : integer := 5  --number of pwm cycles before changing fade level (level is between 0 to 100% brighness)
 	 )
       PORT map(
            sys_clk	      => clk ,
            rst_n         => rst_n        ,
    		led_in        => s_led_std(i),
            led_out       => led_out(i)
           );

end generate uN_led_fade_down;

END behave;










