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

entity bus2bram is
    generic(
            g_RAM_ADDR_WIDTH     : integer   := 8
     );
   port(
           clk_sys              : in  std_logic;
           -- reg_intf
           addr                 : in   std_logic_vector(g_RAM_ADDR_WIDTH-1 downto 0);
           writeEn              : in   std_logic;
           dataIn               : in   std_logic_vector(31 downto 0);
           readEn               : in   std_logic;
           readRdy              : out  std_logic;
           dataOut              : out  std_logic_vector(31 downto 0)
       );
end bus2bram;



--*****************************************************************************************************************************
-- ARCHITECTURE
--*****************************************************************************************************************************

architecture str of bus2bram is


----------------------------------------------------------------------------
-- COMPONENT DECLARATION
----------------------------------------------------------------------------

component dpram_sc_v2 is
  Generic(
      g_dwidth : integer := 32;
      g_awidth : integer := 8
  );
  Port (


        clk           : in  std_logic;

				Ram_data_wr   : in  std_logic_vector(g_dwidth - 1 downto 0);
				Ram_addr_wr   : in  std_logic_vector(g_awidth - 1 downto 0);
				Ram_wr        : in  std_logic;

				Ram_data_rd   : out std_logic_vector(g_dwidth - 1 downto 0);
				Ram_addr_rd   : in  std_logic_vector(g_awidth - 1 downto 0);
				Ram_rd        : in  std_logic


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


signal s_readEn  : std_logic;




--*****************************************************************************************************************************
-- BEGIN OF ARCHITECTURE
--*****************************************************************************************************************************
begin

----------------------------------------------------------------------------
-- COMPONENT INSTANTIATION
----------------------------------------------------------------------------


u_dpram_sc_v2 : dpram_sc_v2
  Generic map(
      g_dwidth => 32,
      g_awidth => g_RAM_ADDR_WIDTH
  )
  Port map (
    clk           => clk_sys  ,

		Ram_data_wr   => dataIn ,
		Ram_addr_wr   => addr    ,
		Ram_wr        => writeEn ,

		Ram_data_rd   => dataOut  ,
		Ram_addr_rd   => addr    ,
		Ram_rd        => readEn


		);



----------------------------------------------------------------------------
-- COMBINATORIAL LOGIC
----------------------------------------------------------------------------

readRdy <= '1';

----------------------------------------------------------------------------
-- CLOKED PROCESS
----------------------------------------------------------------------------



--  -- generate pulses
--  process(clk_sys,rst_n)
--  begin
--      if(rst_n = '0') then
--      	s_spi_intf_en_d   <= (others => '0');
--  	elsif(clk_sys'event and clk_sys='1') then
--          s_spi_intf_en_d <= s_spi_intf_en_d(0)&s_spi_intf_en;
--      end if;
--  end process;
--  s_sot_p  <= (s_spi_intf_en_d(1)  xor s_spi_intf_en_d(0) ) and s_spi_intf_en_d(1); --falling
--  s_eot_p  <= (s_spi_intf_en_d(1)  xor s_spi_intf_en_d(0) ) and s_spi_intf_en_d(0); --rising













--*****************************************************************************************************************************
-- END OF ARCHITECTURE
--*****************************************************************************************************************************

END str;










