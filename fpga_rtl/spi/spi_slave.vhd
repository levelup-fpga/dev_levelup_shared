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

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
use work.util_pkg.all;


--*****************************************************************************************************************************
-- ENTITY
--*****************************************************************************************************************************

entity spi_slave is
   port(
           rst_n                : in  std_logic;
           sys_clk              : in  std_logic;
           -- combinatorial outputs (sync to sys_clk)
           done_8bit            : out std_logic;
           data_out             : out std_logic_vector(7 downto 0);
           data_in              : in  std_logic_vector(7 downto 0);
           -- SPI interface
           spi_intf_clk         : in  std_logic;                      -- clock of the SPI interface
           spi_intf_en          : in  std_logic;                      -- enable of the SPI interface
           spi_intf_miso        : out std_logic;                      -- Master In Slave Out SPI data line
           spi_intf_mosi        : in std_logic                       -- Master Out Slave In SPI data line
       );
end spi_slave;



--*****************************************************************************************************************************
-- ARCHITECTURE
--*****************************************************************************************************************************

architecture behave of spi_slave is


----------------------------------------------------------------------------
-- COMPONENT DECLARATION
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- TYPES DECLARATION
----------------------------------------------------------------------------

type t_spi_reg is array(127 downto 0) of std_logic_vector(7 downto 0);


----------------------------------------------------------------------------
-- FUNCTIONAL CONSTANT DECLARATION
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- RANGE CONSTANT DECLARATION
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- SIGNAL DECLARATION
----------------------------------------------------------------------------


signal s_cpt_rising     : std_logic_vector (2 downto 0);
signal s_cpt_rising_d   : std_logic_vector (2 downto 0);
signal s_rx_sr          : std_logic_vector (7 downto 0);

signal s_spi_intf_clk_m       : std_logic_vector(2 downto 0);
signal s_spi_intf_en_m        : std_logic_vector(2 downto 0);
signal s_spi_intf_mosi_m      : std_logic_vector(2 downto 0);

signal s_spi_intf_clk_p      : std_logic;








--*****************************************************************************************************************************
-- BEGIN OF ARCHITECTURE
--*****************************************************************************************************************************
begin

----------------------------------------------------------------------------
-- COMPONENT INSTANTIATION
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- COMBINATORIAL LOGIC
---------------------------------------------------------------------------

--done_8bit <= '1' when s_cpt_rising_d = "111" else '0';

process(sys_clk,rst_n) --TODO clean with 'left an shift)
begin
    if(rst_n = '0') then
    	s_spi_intf_clk_m   <= (others => '0');
        s_spi_intf_en_m    <= (others => '0');
        s_spi_intf_mosi_m  <= (others => '0');
	elsif(sys_clk'event and sys_clk='1') then
	    s_spi_intf_clk_m(0)   <= spi_intf_clk ;
        s_spi_intf_en_m(0)    <= spi_intf_en  ;
        s_spi_intf_mosi_m(0)  <= spi_intf_mosi;
        s_spi_intf_clk_m(1)   <= s_spi_intf_clk_m(0) ;
        s_spi_intf_en_m(1)    <= s_spi_intf_en_m(0)  ;
        s_spi_intf_mosi_m(1)  <= s_spi_intf_mosi_m(0);
        s_spi_intf_clk_m(2)   <= s_spi_intf_clk_m(1) ;
        s_spi_intf_en_m(2)    <= s_spi_intf_en_m(1)  ;
        s_spi_intf_mosi_m(2)  <= s_spi_intf_mosi_m(1);
    end if;
end process;

s_spi_intf_clk_p <= (s_spi_intf_clk_m(1) xor s_spi_intf_clk_m(2)) and s_spi_intf_clk_m(1);


process(sys_clk,rst_n)
begin
    if(rst_n = '0') then
    	done_8bit   <= '0';
	elsif(sys_clk'event and sys_clk='1') then
	    if(spi_intf_en = '0' and s_cpt_rising = "000" and s_cpt_rising_d = "111" ) then
	        done_8bit   <= '1';
	    else
	        done_8bit   <= '0';
	    end if;
    end if;
end process;


----------------------------------------------------------------------------
-- CLOKED PROCESS
----------------------------------------------------------------------------

-- CLOCK counter
process(sys_clk,rst_n)
begin
    if(rst_n = '0') then
    	s_cpt_rising   <= (others => '0');
    	s_cpt_rising_d <= (others => '0');
	elsif(sys_clk'event and sys_clk='1') then
        s_cpt_rising_d <= s_cpt_rising;
	    if(s_spi_intf_en_m(1) = '1') then
	        s_cpt_rising   <= (others => '0');
        elsif(s_spi_intf_clk_p = '1') then
            s_cpt_rising <= s_cpt_rising + 1;
	    end if;
    end if;
end process;

-- RX shift register
process(sys_clk,rst_n)
begin
    if(rst_n = '0') then
    	s_rx_sr <= (others => '0');
	elsif(sys_clk'event and sys_clk='1') then
        if(s_spi_intf_clk_p = '1') then
	        s_rx_sr <= s_rx_sr(s_rx_sr'left-1 downto 0)&s_spi_intf_mosi_m(1);
	    end if;
    end if;
end process;

data_out <= s_rx_sr;

spi_intf_miso <= data_in(conv_integer(7-s_cpt_rising));







--*****************************************************************************************************************************
-- END OF ARCHITECTURE
--*****************************************************************************************************************************

END behave;










