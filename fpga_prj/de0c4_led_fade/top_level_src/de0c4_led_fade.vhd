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
LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
use work.util_pkg.all;



-------------------------------------------------------------------------------
-- DECLARATION DE L'INTERFACE DE L'ENTITE
-------------------------------------------------------------------------------
entity de0c4_led_fade IS
    PORT(
            clk_50MHz           : in  std_logic                                     ;
            rst_n               : in  std_logic                                     ;
            ---- misc
			led8_ext0        : out std_logic_vector(7 downto 0);
            led8_ext1        : out std_logic_vector(7 downto 0);
            led8_pcb0        : out std_logic_vector(7 downto 0)

       );
end de0c4_led_fade;

architecture str of de0c4_led_fade is

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES DE TYPAGE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DE TYPES ET SOUS TYPES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------


component pll_alt IS
	PORT
	(
		inclk0		: in  std_logic  := '0'     ;
		c0		    : out std_logic             ;
		c1		    : out std_logic
	);
END component;


component led_k2000_fade_down IS
	generic(
	        g_led_polarity          : std_logic := '1';
		g_data_width 		: integer   := 8;
	 	g_speed_clk_divide 	: integer   := 8;
	        g_prescale_div          : integer := 5;
		g_fade_step_cpt         : integer := 5
	 );
   PORT(
           clk		 : in std_logic;
           rst_n         : in std_logic;
           led_out       : out std_logic_vector(g_data_width-1 downto 0)
       );
end component;



-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES FONCTIONNELLES
-------------------------------------------------------------------------------

--DONT TOUCH !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


-------------------------------------------------------------------------------
-- TYPES AND SUB TYPES DECLARATION
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DE SIGNAUX INTERNES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- SIGNAL DECLARATION
-------------------------------------------------------------------------------


-- global TODO seperate to add and test skew resistance -----------------------------------
constant c_data_width 		     : integer   := 8  ;
--constant c_speed_clk_divide 	 : integer   :=   25_000_000; -- TOD0 add ref to calc this generix (1sec = sysclk/c_speed_clk_divide) :25_000_000 with 50MHz => 0.5 sec
constant c_speed_clk_divide 	 : integer   :=   10_000_000; -- TOD0 add ref to calc this generix (1sec = sysclk/c_speed_clk_divide) :25_000_000 with 50MHz => 0.5 sec
constant c_prescale_div_1        : integer   :=          200; --should be aroun 500k to 1500 max 4M (Hz) related to c_speed_clk_divide and actal clk frequency
constant c_fade_step_cpt_1       : integer   :=           10; --should be defined or related by params above and juste be a "dime time prolongation"
constant c_prescale_div_2        : integer   :=           50; --should be aroun 500k to 1500 max 4M (Hz) related to c_speed_clk_divide and actal clk frequency
constant c_fade_step_cpt_2       : integer   :=           50; --should be defined or related by params above and juste be a "dime time prolongation"

--examples: ----------------------
-- @CLK = 50MHz


signal s_clk_100MHz         : std_logic;
signal s_clk_050MHz         : std_logic;



-------------------------------------------------------------------------------
-- CORPS DE L'ARCHITECTURE
-------------------------------------------------------------------------------


begin

-------------------------------------------------------------------------------
-- SIGNAUX CONSTANTS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- INSTANCIATION DES ENTITES EXTERNES
-------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
-- ETHERNET --------------------------------------------------------------------------------------------------


u_pll_alt : pll_alt
port map(

		inclk0	             => clk_50MHz        ,
		c0		     => s_clk_100MHz     ,
		c1		     => s_clk_050MHz
	);

uext0_led_k2000_fade_down : led_k2000_fade_down
	generic map(
	        g_led_polarity           => '0'        , --=>'1' ,
		g_data_width 	         => c_data_width 	   , --=> 8  ,
	 	g_speed_clk_divide       => c_speed_clk_divide    , --=> 30000000,
	        g_prescale_div           => c_prescale_div_2        ,  --
		g_fade_step_cpt          => c_fade_step_cpt_2         --
	 )
   PORT map(
           clk		 => s_clk_050MHz ,
           rst_n         => rst_n        ,
           led_out       => led8_ext0
       );


uext1_led_k2000_fade_down : led_k2000_fade_down
	generic map(
	        g_led_polarity           => '0'        , --=>'1' ,
		g_data_width 	         => c_data_width 	   , --=> 8  ,
	 	g_speed_clk_divide       => c_speed_clk_divide    , --=> 30000000,
	        g_prescale_div           => c_prescale_div_2        ,  --
		g_fade_step_cpt          => c_fade_step_cpt_2         --
	 )
   PORT map(
           clk		 => s_clk_050MHz ,
           rst_n         => rst_n        ,
           led_out       => led8_ext1
       );


upcb0_led_k2000_fade_down : led_k2000_fade_down
	generic map(
	        g_led_polarity           => '1'        , --=>'1' ,
		g_data_width 	         => c_data_width 	   , --=> 8  ,
	 	g_speed_clk_divide       => c_speed_clk_divide    , --=> 30000000,
	        g_prescale_div           => c_prescale_div_1        ,  --
		g_fade_step_cpt          => c_fade_step_cpt_1         --
	 )
   PORT map(
           clk		 => s_clk_050MHz ,
           rst_n         => rst_n        ,
           led_out       => led8_pcb0
       );


end str;
