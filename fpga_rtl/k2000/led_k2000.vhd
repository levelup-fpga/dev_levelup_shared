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

entity led_k2000 IS
	generic(
	        g_led_polarity      : std_logic := '1';
			g_data_width 		: integer   := 8;
	 		g_speed_clk_divide 	: integer   := 8
	 );
   PORT(
           clk		     : in std_logic;
           rst_n         : in std_logic;
           led_out       : out std_logic_vector(g_data_width-1 downto 0)
       );
end led_k2000;

ARCHITECTURE behave OF led_k2000 IS



signal s_led_out		: std_logic_vector(g_data_width-1 downto 0);
signal s_shift_RnL      : std_logic;

signal s_cpt_shift      : std_logic_vector(31 downto 0);






BEGIN


process(clk,rst_n)
begin
	if(rst_n = '0')then
		s_cpt_shift    <= (others => '0');
	elsif(clk'event and clk='1') then
		if(s_cpt_shift = g_speed_clk_divide) then
			s_cpt_shift <= (others => '0');
		else
			s_cpt_shift <= s_cpt_shift + 1;
		end if;
	end if;
end process;


process(clk,rst_n)
begin
	if(rst_n = '0')then
		s_shift_RnL    <= '0'; -- shift left
	elsif(clk'event and clk='1') then
		if(s_led_out(s_led_out'left) = '1') then
			s_shift_RnL    <= '1'; -- shift right
		elsif(s_led_out(s_led_out'right) = '1') then
			s_shift_RnL    <= '0'; -- shift left
		end if;
	end if;
end process;


process(clk,rst_n)
begin
	if(rst_n = '0')then
		s_led_out(s_led_out'left downto 1)    <= (others => '0');
		s_led_out(0) <= '1';
	elsif(clk'event and clk='1') then
		if(s_cpt_shift = g_speed_clk_divide) then
			if(s_shift_RnL = '0') then
				s_led_out <= s_led_out(s_led_out'left-1 downto 0) & s_led_out(s_led_out'left);
			elsif(s_shift_RnL = '1') then
				s_led_out <= s_led_out(s_led_out'right) & s_led_out(s_led_out'left downto 1);
			end if;
		end if;
	end if;
end process;


led_out <= s_led_out when g_led_polarity = '1' else not s_led_out;

END behave;










