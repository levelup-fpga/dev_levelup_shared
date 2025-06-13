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




-------------------------------------------------------------------------------
-- DEPENDANCES
-------------------------------------------------------------------------------

library IEEE;

LIBRARY IEEE ;
USE ieee.std_logic_1164.all ;
USE ieee.std_logic_arith.all ;
USE ieee.std_logic_unsigned.all ;

use STD.textio.all;
use ieee.std_logic_textio.all;



-------------------------------------------------------------------------------
-- ENTITY INTERFACE
-------------------------------------------------------------------------------

entity tb_led_fade_down is
end tb_led_fade_down;

-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------

architecture sim of tb_led_fade_down is

-------------------------------------------------------------------------------
-- COMPONENT DECLARATION
-------------------------------------------------------------------------------


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




-------------------------------------------------------------------------------
-- TYPING CONSTANT DECLARATION
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- TYPES AND SUB TYPES DECLARATION
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- FUNCTIONAL CONSTANT DECLAATION
-------------------------------------------------------------------------------

constant c_GBL_CLK_PERIOD       : time :=  10 ns;
constant c_RST_DURATION         : time :=  10 us;

constant c_WAIT                 : time :=  20 ms;
constant c_PRESCALE_DIV         : integer := 50; --output-pwm frequency = 100*(clk_frequency/g_prescale_cycles)
constant c_FADE_STEP_CPT        : integer := 2; --number of pwm cycles before changing fade level (level is between 0 to 100% brighness)


-------------------------------------------------------------------------------
-- STATE DECLARATIONS FOR FSM
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- SIGNAL DECLARATION
-------------------------------------------------------------------------------


-- global TODO seperate to add and test skew resistance -----------------------------------


signal s_stop_condition  : boolean := false;


signal s_rst_n           : std_logic := '0';
signal s_sys_clk         : std_logic := '0';

signal s_led_in          : std_logic;
signal s_led_out         : std_logic;


-------------------------------------------------------------------------------
-- CORPS DE L'ARCHITECTURE
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- ENTITY INSTANCIATION
-------------------------------------------------------------------------------







-------------------------------------------------------------------------------
-- TB DRIVE SIGNALS
-------------------------------------------------------------------------------


-- clock and reset ---------------------------------------------------

s_rst_n    <= '0', '1' after c_RST_DURATION;

s_sys_clk <= not s_sys_clk after c_GBL_CLK_PERIOD/2;


u_led_fade_down : led_fade_down
	generic map(
	        g_prescale_div   => c_PRESCALE_DIV  ,
			g_fade_step_cpt  => c_FADE_STEP_CPT
	 )
   PORT map(
           sys_clk         => s_sys_clk   ,
           rst_n           => s_rst_n     ,
		   led_in          => s_led_in    ,
           led_out         => s_led_out
   );


p_sys_cmd : process
begin

    s_led_in <= '0';

    wait until rising_edge(s_sys_clk) and s_rst_n = '1';

    s_led_in <= '1'       ; wait until rising_edge(s_sys_clk);s_led_in <= '0';
    wait for c_WAIT     ;wait until rising_edge(s_sys_clk);

    s_led_in <= '1'       ; wait until rising_edge(s_sys_clk);s_led_in <= '0';
    wait for c_WAIT     ;wait until rising_edge(s_sys_clk);

    s_led_in <= '1'       ; wait until rising_edge(s_sys_clk);s_led_in <= '0';
    wait for c_WAIT     ;wait until rising_edge(s_sys_clk);


    s_stop_condition <= true;


end process p_sys_cmd;




end sim;

