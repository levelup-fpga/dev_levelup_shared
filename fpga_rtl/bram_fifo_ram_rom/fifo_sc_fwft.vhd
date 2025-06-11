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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.util_pkg.all;

-------------------------------------------------------------------------------
-- DECLARATION DE L'INTERFACE DE L'ENTITE
-------------------------------------------------------------------------------

entity fifo_sc_fwft is
  Generic(
      g_dwidth : integer := 32;
      g_ddepth : integer := 9000
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
end fifo_sc_fwft;

-------------------------------------------------------------------------------
-- DECLARATION DE L'ARCHITECTURE
-------------------------------------------------------------------------------

architecture Behavioral of fifo_sc_fwft is

-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------


component fifo_sc is
  Generic(
      g_dwidth : integer := 32;
      g_ddepth : integer := 9000
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


signal s_Fifo_empty    		: std_logic;
signal s_dout_valid    		: std_logic;
signal s_Fifo_rd     		: std_logic;



-------------------------------------------------------------------------------
-- CORPS DE L'ARCHITECTURE
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- INSTANCIATION DES ENTITES EXTERNES
-------------------------------------------------------------------------------


u_fifo_sc : fifo_sc
  Generic map(
      g_dwidth => g_dwidth ,
      g_ddepth => g_ddepth
  )
  Port map(


        		clk           => clk    ,
				rst_n		  => rst_n  ,

				-- FIFO SIDE

				Fifo_din      => Fifo_din     ,
				Fifo_wr       => Fifo_wr      ,
				Fifo_full     => Fifo_full    ,

				Fifo_dout     => Fifo_dout    ,
				Fifo_rd       => s_Fifo_rd      ,
				Fifo_empty    => s_Fifo_empty   ,

				Fifo_level    => Fifo_level

		);

-------------------------------------------------------------------------------
-- SIGNAUX CONSTANTS
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- PROCESS CLK
-------------------------------------------------------------------------------


s_Fifo_rd 	<= not(s_Fifo_empty) and (not s_dout_valid or Fifo_rd);
Fifo_empty 	<= not s_dout_valid;

process(clk,rst_n) -- delay on signals
begin
	if(rst_n = '0')then
		s_dout_valid 	<= '0';
	elsif(clk'event and clk='1') then
		if(s_Fifo_rd = '1')then
			s_dout_valid 	<= '1';
		elsif(Fifo_rd = '1')then
			s_dout_valid 	<= '0';
		end if;
	end if;
end process;


end Behavioral;

