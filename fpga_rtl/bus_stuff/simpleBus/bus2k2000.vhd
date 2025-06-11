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

--*****************************************************************************************************************************
-- LIBRARY
--*****************************************************************************************************************************

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;


--*****************************************************************************************************************************
-- ENTITY
--*****************************************************************************************************************************

entity bus2k2000 is
    generic(
            g_LED_WIDTH        : integer   := 8
     );
   port(
           rst_n                : in  std_logic;
           clk_sys              : in  std_logic;
           -- reg_intf
           addr                 : in   std_logic_vector(1 downto 0);
           writeEn              : in   std_logic;
           dataIn               : in   std_logic_vector(31 downto 0);
           readEn               : in   std_logic;
           readRdy              : out  std_logic;
           dataOut              : out  std_logic_vector(31 downto 0);
           -- SPI interface
           led_out              : out std_logic_vector(g_LED_WIDTH-1 downto 0)             -- Master Out Slave In SPI data line
       );
end bus2k2000;



--*****************************************************************************************************************************
-- ARCHITECTURE
--*****************************************************************************************************************************

architecture str of bus2k2000 is


----------------------------------------------------------------------------
-- COMPONENT DECLARATION
----------------------------------------------------------------------------


component led_k2000_reg_rw IS
    generic(
            g_data_width        : integer   := 8
     );
   PORT(
           clk           : in std_logic;
           rst_n         : in std_logic;

           reg_addr       : in  std_logic_vector( 1 downto 0);
           reg_wr         : in  std_logic;
           reg_wr_data    : in  std_logic_vector(31 downto 0);
           reg_rd         : in  std_logic;
           reg_rd_dv      : out std_logic;
           reg_rd_data    : out std_logic_vector(31 downto 0);

           led_out       : out std_logic_vector(g_data_width-1 downto 0)
       );
end component;



----------------------------------------------------------------------------
-- TYPES DECLARATION
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- FUNCTIONAL CONSTANT DECLARATION
----------------------------------------------------------------------------



----------------------------------------------------------------------------
-- RANGE CONSTANT DECLARATION
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- SIGNAL DECLARATION
----------------------------------------------------------------------------


--*****************************************************************************************************************************
-- BEGIN OF ARCHITECTURE
--*****************************************************************************************************************************
begin

----------------------------------------------------------------------------
-- COMPONENT INSTANTIATION
----------------------------------------------------------------------------

u_led_k2000_reg_rw : led_k2000_reg_rw
    generic map(
            g_data_width        => g_LED_WIDTH
     )
   port map(
           clk            => clk_sys    ,
           rst_n          => rst_n      ,

           reg_addr       => addr       ,
           reg_wr         => writeEn    ,
           reg_wr_data    => dataIn     ,
           reg_rd         => readEn     ,
           reg_rd_dv      => open       ,
           reg_rd_data    => dataOut    ,

           led_out        => led_out
       );




----------------------------------------------------------------------------
-- COMBINATORIAL LOGIC
----------------------------------------------------------------------------

readRdy <= '1';

----------------------------------------------------------------------------
-- CLOKED PROCESS
----------------------------------------------------------------------------










--*****************************************************************************************************************************
-- END OF ARCHITECTURE
--*****************************************************************************************************************************

END str;










