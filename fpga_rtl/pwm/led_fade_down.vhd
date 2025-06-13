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
use work.util_pkg.all;

-- generic data width to serial data with 8 bit header and 8 bit CRC

entity led_fade_down IS
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
end led_fade_down;

ARCHITECTURE behave OF led_fade_down IS


component pwm_gen IS
	generic(
	        g_prescale_div   : integer := 5 --output-pwm frequency = 100*(clk_frequency/g_prescale_cycles)
	 );
   PORT(
           sys_clk         : in std_logic;
           rst_n           : in std_logic;
           duty_cycle      : in std_logic_vector(7 downto 0); --accomodates integer range 0 to 100;
           end_of_cycle_p  : out std_logic; -- indicates an end of cycle, can be used tu update duty cycle in sync
           pwm_out         : out std_logic
       );
end component;



constant c_100_VEC     : std_logic_vector(7 downto 0) := conv_std_logic_vector(100,8);
constant c_000_VEC     : std_logic_vector(7 downto 0) := (others => '0');

signal s_fade_step_cpt  : std_logic_vector(log2(g_fade_step_cpt-1) downto 0);
signal s_dec_fade_p		: std_logic;
signal s_duty_cycle      : std_logic_vector(7 downto 0); --accomodates integer range 0 to 100;
signal s_end_of_cycle_p  : std_logic; -- indicates an end of cycle, can be used tu update duty cycle in sync









BEGIN


u_pwm_gen : pwm_gen
	generic map(
	        g_prescale_div  => g_prescale_div
	 )
   PORT map(
           sys_clk         => sys_clk   		,
           rst_n           => rst_n     		,
           duty_cycle      => s_duty_cycle 		,
           end_of_cycle_p  => s_end_of_cycle_p	,
           pwm_out         => led_out
       );



process(sys_clk,rst_n)
begin
	if(rst_n = '0')then
		s_fade_step_cpt    <= (others => '0');
	elsif(sys_clk'event and sys_clk='1') then
		if(led_in = '1') then
			s_fade_step_cpt    <= (others => '0');
		elsif(s_end_of_cycle_p = '1') then
			if(s_fade_step_cpt = g_fade_step_cpt)then
				s_fade_step_cpt    <= (others => '0');
			else
				s_fade_step_cpt <= s_fade_step_cpt + '1';
			end if;
		end if;
	end if;
end process;

process(sys_clk,rst_n)
begin
	if(rst_n = '0')then
		s_dec_fade_p    <= '0';
	elsif(sys_clk'event and sys_clk='1') then
		if(s_end_of_cycle_p = '1' and s_fade_step_cpt = g_fade_step_cpt-1) then
			s_dec_fade_p    <= '1';
		else
			s_dec_fade_p    <= '0';
		end if;
	end if;
end process;

process(sys_clk,rst_n)
begin
	if(rst_n = '0')then
		s_duty_cycle    <= (others => '0');
	elsif(sys_clk'event and sys_clk='1') then
		if(led_in = '1') then
			s_duty_cycle    <= c_100_VEC;
		elsif(s_dec_fade_p = '1' and s_duty_cycle /= c_000_VEC) then
			s_duty_cycle    <= s_duty_cycle - '1';
		end if;
	end if;
end process;



END behave;










