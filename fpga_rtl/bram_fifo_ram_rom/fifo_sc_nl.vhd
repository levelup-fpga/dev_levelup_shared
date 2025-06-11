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
-- same as fifo_sc but removed util_pkg ang log (_nl = no log)
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- DEPENDANCES
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.util_pkg.all;

-------------------------------------------------------------------------------
-- DECLARATION DE L'INTERFACE DE L'ENTITE
-------------------------------------------------------------------------------

entity fifo_sc_nl is
  Generic(
      g_dwidth : integer := 32;
      g_awidth : integer := 8
  );
  Port (


        		clk           : in  std_logic;
				rst_n		  : in  std_logic;

				-- FIFO SIDE

				Fifo_din      : in  std_logic_vector(g_dwidth - 1 downto 0);
				Fifo_wr       : in  std_logic;
				Fifo_full     : out std_logic;

				Fifo_dout     : out std_logic_vector(g_dwidth - 1 downto 0);
				Fifo_rd       : in  std_logic;
				Fifo_empty    : out std_logic;

				Fifo_level    : out std_logic_vector(1 downto 0)

		);
end fifo_sc;

-------------------------------------------------------------------------------
-- DECLARATION DE L'ARCHITECTURE
-------------------------------------------------------------------------------

architecture Behavioral of fifo_sc is

-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------


component fifo_logic_sc is
  Generic(
      g_dwidth : integer := 8;
      g_ddepth : integer := 50
  );
  Port (
        clk           : in  std_logic;
				rst_n				  : in  std_logic;

				-- FIFO SIDE
				Fifo_din      : in  std_logic_vector(g_dwidth - 1 downto 0);
				Fifo_wr       : in  std_logic;
				Fifo_full     : out std_logic;

				Fifo_dout     : out std_logic_vector(g_dwidth - 1 downto 0);
				Fifo_rd       : in  std_logic;
				Fifo_empty    : out std_logic;

				Fifo_level    : out std_logic_vector(1 downto 0);

				-- RAM SIDE
				Ram_data_wr   : out std_logic_vector(g_dwidth - 1 downto 0);
				Ram_addr_wr   : out std_logic_vector(log2(g_ddepth) - 1 downto 0);
				Ram_wr        : out std_logic;

				Ram_data_rd   : in  std_logic_vector(g_dwidth - 1 downto 0);
				Ram_addr_rd   : out std_logic_vector(log2(g_ddepth) - 1 downto 0);
				Ram_rd        : out std_logic
		);
end component;


component dpram_sc is
  Generic(
      g_dwidth : integer := 8;
      g_ddepth : integer := 50
  );
  Port (
        clk           : in  std_logic;
				rst_n				  : in  std_logic;				-- unused

				Ram_data_wr   : in  std_logic_vector(g_dwidth - 1 downto 0);
				Ram_addr_wr   : in  std_logic_vector(log2(g_ddepth) - 1 downto 0);
				Ram_wr        : in  std_logic;

				Ram_data_rd   : out std_logic_vector(g_dwidth - 1 downto 0);
				Ram_addr_rd   : in  std_logic_vector(log2(g_ddepth) - 1 downto 0);
				Ram_rd        : in  std_logic
		);
end component;

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES DE TYPAGE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DE TYPES ET SOUS TYPES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES FONCTIONNELLES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DES ETATS MACHINE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DE SIGNAUX INTERNES
-------------------------------------------------------------------------------

signal s_Ram_data_wr   : std_logic_vector(g_dwidth - 1 downto 0);
signal s_Ram_addr_wr   : std_logic_vector(log2(g_ddepth) - 1 downto 0);
signal s_Ram_wr        : std_logic;
signal s_Ram_data_rd   : std_logic_vector(g_dwidth - 1 downto 0);
signal s_Ram_addr_rd   : std_logic_vector(log2(g_ddepth) - 1 downto 0);
signal s_Ram_rd        : std_logic;

-------------------------------------------------------------------------------
-- CORPS DE L'ARCHITECTURE
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- INSTANCIATION DES ENTITES EXTERNES
-------------------------------------------------------------------------------


u_fifo_logic_sc : fifo_logic_sc
  Generic map(
      g_dwidth    => g_dwidth ,
      g_ddepth    => g_ddepth
  )
  Port map (
        clk           =>  clk        ,
				rst_n				  =>  rst_n			 ,

				Fifo_din      =>  Fifo_din   ,
				Fifo_wr       =>  Fifo_wr    ,
				Fifo_full     =>  Fifo_full  ,

				Fifo_dout     =>  Fifo_dout  ,
				Fifo_rd       =>  Fifo_rd    ,
				Fifo_empty    =>  Fifo_empty ,

				Fifo_level    =>  Fifo_level ,

				Ram_data_wr   =>  s_Ram_data_wr ,
				Ram_addr_wr   =>  s_Ram_addr_wr ,
				Ram_wr        =>  s_Ram_wr      ,

				Ram_data_rd   =>  s_Ram_data_rd ,
				Ram_addr_rd   =>  s_Ram_addr_rd ,
				Ram_rd        =>  s_Ram_rd
		);


u_dpram_sc : dpram_sc
  Generic map(
      g_dwidth   =>  g_dwidth ,
      g_ddepth   =>  g_ddepth
  )
  Port map(
        clk           =>  clk   ,
				rst_n				  =>  rst_n ,

				Ram_data_wr   =>  s_Ram_data_wr ,
				Ram_addr_wr   =>  s_Ram_addr_wr ,
				Ram_wr        =>  s_Ram_wr      ,

				Ram_data_rd   =>  s_Ram_data_rd ,
				Ram_addr_rd   =>  s_Ram_addr_rd ,
				Ram_rd        =>  s_Ram_rd
		);


-------------------------------------------------------------------------------
-- SIGNAUX CONSTANTS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- PROCESS CLK
-------------------------------------------------------------------------------

end Behavioral;

