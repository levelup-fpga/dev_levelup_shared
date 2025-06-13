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

entity pwm_gen IS
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
end pwm_gen;

ARCHITECTURE behave OF pwm_gen IS

constant c_100_PERCENT : integer := 100;

constant c_100_VEC     : std_logic_vector(7 downto 0) := conv_std_logic_vector(100,8);
constant c_000_VEC     : std_logic_vector(7 downto 0) := (others => '0');


signal s_prescale_cpt   : std_logic_vector(log2(g_prescale_div-1) downto 0);
signal s_pwm_cpt        : std_logic_vector(7 downto 0);









BEGIN



process(sys_clk,rst_n)
begin
	if(rst_n = '0')then
		s_prescale_cpt    <= (others => '0');
	elsif(sys_clk'event and sys_clk='1') then
		if(s_prescale_cpt = g_prescale_div-1) then
			s_prescale_cpt <= (others => '0');
		else
			s_prescale_cpt <= s_prescale_cpt + 1;
		end if;
	end if;
end process;


process(sys_clk,rst_n)
begin
	if(rst_n = '0')then
		s_pwm_cpt    <= (others => '0');
	elsif(sys_clk'event and sys_clk='1') then
		if(s_pwm_cpt = c_100_VEC) then
			s_pwm_cpt <= (others => '0');
		elsif(s_prescale_cpt = g_prescale_div-1) then
			s_pwm_cpt <= s_pwm_cpt + 1;
		end if;
	end if;
end process;

process(sys_clk,rst_n)
begin
	if(rst_n = '0')then
		end_of_cycle_p    <= '0';
	elsif(sys_clk'event and sys_clk='1') then
		if(s_pwm_cpt = c_100_PERCENT and s_prescale_cpt = 0) then
			end_of_cycle_p    <= '1';
        else
			end_of_cycle_p    <= '0';
		end if;
	end if;
end process;



process(sys_clk,rst_n)
begin
	if(rst_n = '0')then
		pwm_out <= '0';
	elsif(sys_clk'event and sys_clk='1') then
		if(duty_cycle = c_000_VEC) then
			pwm_out <= '0';
        elsif(duty_cycle = c_100_VEC) then
			pwm_out <= '1';
		elsif(s_pwm_cpt = duty_cycle and s_prescale_cpt = c_000_VEC) then
			pwm_out <= '0';
        elsif(s_pwm_cpt = c_100_VEC  and s_prescale_cpt = c_000_VEC) then
			pwm_out <= '1';
		end if;
	end if;
end process;

END behave;










