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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use STD.textio.all;
use ieee.std_logic_textio.all;



-------------------------------------------------------------------------------
-- ENTITY INTERFACE
-------------------------------------------------------------------------------

entity tb_pwm_gen is
end tb_pwm_gen;

-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------

architecture sim of tb_pwm_gen is

-------------------------------------------------------------------------------
-- COMPONENT DECLARATION
-------------------------------------------------------------------------------


component pwm_gen is
	generic(
	        g_prescale_div   : integer := 5 --output-pwm frequency = 100*(clk_frequency/g_prescale_cycles)
	 );
   PORT(
           sys_clk         : in std_logic;
           rst_n           : in std_logic;
           duty_cycle      : in integer range 0 to 100;
           end_of_cycle_p  : out std_logic; -- indicates an end of cycle, can be used tu update duty cycle in sync
           pwm_out         : out std_logic
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

constant c_WAIT                 : time :=  1 ms;
constant c_PRESCALE_DIV         : integer := 10; --output-pwm frequency = 100*(clk_frequency/g_prescale_cycles)


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
signal s_duty_cycle      : integer   := 0  ;
signal s_end_of_cycle_p  : std_logic := '0';
signal s_pwm_out         : std_logic := '0';



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


u_pwm_gen : pwm_gen
	generic map(
	        g_prescale_div   => c_PRESCALE_DIV --output-pwm frequency = 100*(clk_frequency/g_prescale_cycles)
	 )
   PORT map(
           sys_clk        => s_sys_clk    ,
           rst_n          => s_rst_n      ,
           duty_cycle     => s_duty_cycle ,
		   end_of_cycle_p => s_end_of_cycle_p,
           pwm_out        => s_pwm_out
       );




p_sys_cmd : process
begin

    s_duty_cycle <= 5;

    wait until rising_edge(s_sys_clk) and s_rst_n = '1';
    wait for c_WAIT;wait until rising_edge(s_sys_clk);
	s_duty_cycle <= 5;
	wait for c_WAIT;wait until rising_edge(s_sys_clk);
	s_duty_cycle <= 0;
	wait for c_WAIT;wait until rising_edge(s_sys_clk);
	s_duty_cycle <= 25;
	wait for c_WAIT;wait until rising_edge(s_sys_clk);
	s_duty_cycle <= 1;
	wait for c_WAIT;wait until rising_edge(s_sys_clk);
	s_duty_cycle <= 2;
	wait for c_WAIT;wait until rising_edge(s_sys_clk);
	s_duty_cycle <= 3;
	wait for c_WAIT;wait until rising_edge(s_sys_clk);
	s_duty_cycle <= 50;
	wait for c_WAIT;wait until rising_edge(s_sys_clk);
	s_duty_cycle <= 99;
	wait for c_WAIT;wait until rising_edge(s_sys_clk);
	s_duty_cycle <= 75;
	wait for c_WAIT;wait until rising_edge(s_sys_clk);
	s_duty_cycle <= 100;
	wait for c_WAIT;wait until rising_edge(s_sys_clk);




    s_stop_condition <= true;


end process p_sys_cmd;




end sim;

