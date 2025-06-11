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
entity de0c4_spi2bus IS
	generic(
                        g_RAM_ADDR_WIDTH     : integer   := 10; -- 2^10 =1024
			g_DBG_SPI_MAP        : integer   := 1   -- 0 = debug all '0', 1 spi_1 (fast), 2 = spi_2 (slow)
    );
    PORT(
            clk_50MHz           : in  std_logic                                     ;
            rst_n               : in  std_logic                                     ;



            --spi slave intf
            spi_slv1_33IOT_cs           :  in std_logic                                     ;
            spi_slv1_33IOT_clk          :  in std_logic                                     ;
            spi_slv1_33IOT_miso         : out std_logic                                     ;
            spi_slv1_33IOT_mosi         :  in std_logic                                     ;


            --spi slave intf
            spi_slv2_R2040_cs           :  in std_logic                                     ;
            spi_slv2_R2040_clk          :  in std_logic                                     ;
            spi_slv2_R2040_miso         : out std_logic                                     ;
            spi_slv2_R2040_mosi         :  in std_logic                                     ;


            --spi master intf
            spi_mst3_MLOOP_cs           : out std_logic                                     ;
            spi_mst3_MLOOP_clk          : out std_logic                                     ;
            spi_mst3_MLOOP_miso         :  in std_logic                                     ;
            spi_mst3_MLOOP_mosi         : out std_logic                                     ;

            --spi slave intf
            spi_slv3_MLOOP_cs           :  in std_logic                                     ;
            spi_slv3_MLOOP_clk          :  in std_logic                                     ;
            spi_slv3_MLOOP_miso         : out std_logic                                     ;
            spi_slv3_MLOOP_mosi         :  in std_logic                                     ;


				--spi slave intf 2
            spi_dbg_cs           : out std_logic                                     ;
            spi_dbg_clk          : out std_logic                                     ;
            spi_dbg_miso         : out std_logic                                     ;
            spi_dbg_mosi         : out std_logic                                     ;

            ---- misc
            led8_ext0        : out std_logic_vector(7 downto 0);
            led8_ext1        : out std_logic_vector(7 downto 0);
            led8_pcb0        : out std_logic_vector(7 downto 0)

       );
end de0c4_spi2bus;

architecture str of de0c4_spi2bus is

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




component spi_test_rambus IS
	generic(
                        g_RAM_ADDR_WIDTH     : integer   := 11;
			g_NB_LED_K2000 	     : integer   := 8
    );
    PORT(
            clk_50MHz           : in  std_logic                                     ;
            rst_n               : in  std_logic                                     ;

            --spi slave intf 1
            spi_slv_cs           :  in std_logic                                     ;
            spi_slv_clk          :  in std_logic                                     ;
            spi_slv_miso         : out std_logic                                     ;
            spi_slv_mosi         :  in std_logic                                     ;
            --
            --
            ---- misc
            led_k2000_out       : out std_logic_vector(g_NB_LED_K2000-1 downto 0)

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



attribute keep : boolean;

signal s_clk_100MHz         : std_logic;
signal s_clk_050MHz         : std_logic;


signal s_spi_slv3_cs           : std_logic  ;
signal s_spi_slv3_clk          : std_logic  ;
signal s_spi_slv3_miso         : std_logic  ;
signal s_spi_slv3_mosi         : std_logic  ;

signal s_spi_slv2_cs           : std_logic  ;
signal s_spi_slv2_clk          : std_logic  ;
signal s_spi_slv2_miso         : std_logic  ;
signal s_spi_slv2_mosi         : std_logic  ;


signal s_spi_slv1_cs           : std_logic  ;
signal s_spi_slv1_clk          : std_logic  ;
signal s_spi_slv1_miso         : std_logic  ;
signal s_spi_slv1_mosi         : std_logic  ;

signal s_led8_ext0             : std_logic_vector(7 downto 0)  ;
signal s_led8_ext1             : std_logic_vector(7 downto 0)  ;





attribute keep of s_clk_100MHz       : signal is true;
attribute keep of s_clk_050MHz       : signal is true;
attribute keep of s_spi_slv3_cs         : signal is true;
attribute keep of s_spi_slv3_clk        : signal is true;
attribute keep of s_spi_slv3_miso       : signal is true;
attribute keep of s_spi_slv3_mosi       : signal is true;
attribute keep of s_spi_slv2_cs         : signal is true;
attribute keep of s_spi_slv2_clk        : signal is true;
attribute keep of s_spi_slv2_miso       : signal is true;
attribute keep of s_spi_slv2_mosi       : signal is true;
attribute keep of s_spi_slv1_cs         : signal is true;
attribute keep of s_spi_slv1_clk        : signal is true;
attribute keep of s_spi_slv1_miso       : signal is true;
attribute keep of s_spi_slv1_mosi       : signal is true;




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
		c0		                => s_clk_100MHz     ,
		c1		                => s_clk_050MHz
	);




u_spi_slv1_test_rambus : spi_test_rambus
	generic map(
                        g_RAM_ADDR_WIDTH    => g_RAM_ADDR_WIDTH ,
			g_NB_LED_K2000 	    => 8
    )
    port map(
            clk_50MHz           => s_clk_100MHz ,
            rst_n               => rst_n        ,

            --spi slave intf 1
            spi_slv_cs            => s_spi_slv1_cs      ,
            spi_slv_clk           => s_spi_slv1_clk     ,
            spi_slv_miso          => s_spi_slv1_miso    ,
            spi_slv_mosi          => s_spi_slv1_mosi    ,
            --
            --
            ---- misc
            led_k2000_out     => s_led8_ext0
       );
-- for debug or rerouting to output to scope real timing
s_spi_slv1_clk          <= spi_slv1_33IOT_clk      ;
s_spi_slv1_cs           <= spi_slv1_33IOT_cs       ;
spi_slv1_33IOT_miso     <= s_spi_slv1_miso         ;
s_spi_slv1_mosi         <= spi_slv1_33IOT_mosi     ;



u_spi_slv2_test_rambus : spi_test_rambus
	generic map(
                        g_RAM_ADDR_WIDTH    => g_RAM_ADDR_WIDTH ,
			g_NB_LED_K2000 	    => 8
    )
    port map(
            clk_50MHz           => s_clk_100MHz ,
            rst_n               => rst_n        ,

            --spi slave intf 1
            spi_slv_cs            => s_spi_slv2_cs      ,
            spi_slv_clk           => s_spi_slv2_clk     ,
            spi_slv_miso          => s_spi_slv2_miso    ,
            spi_slv_mosi          => s_spi_slv2_mosi    ,
            --
            --
            ---- misc
            led_k2000_out     => s_led8_ext1

       );
       led8_ext0 <= not s_led8_ext0;
-- for debug or rerouting to output to scope real timing
s_spi_slv2_clk          <= spi_slv2_R2040_clk      ;
s_spi_slv2_cs           <= spi_slv2_R2040_cs       ;
spi_slv2_R2040_miso     <= s_spi_slv2_miso         ;
s_spi_slv2_mosi         <= spi_slv2_R2040_mosi     ;


u_spi_slv3_test_rambus : spi_test_rambus
	generic map(
                        g_RAM_ADDR_WIDTH    => g_RAM_ADDR_WIDTH ,
			g_NB_LED_K2000 	    => 8
    )
    port map(
            clk_50MHz           => s_clk_100MHz ,
            rst_n               => rst_n        ,

            --spi slave intf 1
            spi_slv_cs            => s_spi_slv3_cs      ,
            spi_slv_clk           => s_spi_slv3_clk     ,
            spi_slv_miso          => s_spi_slv3_miso    ,
            spi_slv_mosi          => s_spi_slv3_mosi    ,
            --
            --
            ---- misc
            led_k2000_out     => led8_pcb0

       );
       led8_ext1 <= not s_led8_ext1;
-- for debug or rerouting to output to scope real timing
s_spi_slv3_clk          <= spi_slv3_MLOOP_clk      ;
s_spi_slv3_cs           <= spi_slv3_MLOOP_cs       ;
spi_slv3_MLOOP_miso     <= s_spi_slv3_miso         ;
s_spi_slv3_mosi         <= spi_slv3_MLOOP_mosi     ;


--spi master intf
spi_mst3_MLOOP_cs           <= '1';
spi_mst3_MLOOP_clk          <= '1';
spi_mst3_MLOOP_mosi         <= spi_mst3_MLOOP_miso;


--debug to not interfear with actuan onbord signals (errors above 10M)

process(s_clk_100MHz)
begin
	if(s_clk_100MHz'event and s_clk_100MHz='1') then
	  if(g_DBG_SPI_MAP = 1) then
		  spi_dbg_clk          <= s_spi_slv2_clk		;
		  spi_dbg_cs           <= s_spi_slv2_cs		;
		  spi_dbg_mosi         <= s_spi_slv2_mosi  	;
		  spi_dbg_miso         <= s_spi_slv2_miso	;
	  elsif(g_DBG_SPI_MAP = 2) then
		  spi_dbg_clk          <= s_spi_slv1_clk		;
		  spi_dbg_cs           <= s_spi_slv1_cs		;
		  spi_dbg_mosi         <= s_spi_slv1_mosi  	;
		  spi_dbg_miso         <= s_spi_slv1_miso	;
	  else
		  spi_dbg_clk          <= '0'    			;
		  spi_dbg_cs           <= '0'    			;
		  spi_dbg_mosi         <= '0'    			;
		  spi_dbg_miso         <= '0'    			;

		end if;
	end if;
end process;





end str;
