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

entity fifo_sc_fwft_32to8 is
  Generic(
      g_ddepth : integer := 9000
  );
  Port (


        		clk           : in  std_logic;
				rst_n		  : in  std_logic;

				-- FIFO SIDE

				Fifo_din      : in  std_logic_vector(31 downto 0);
				Fifo_wr       : in  std_logic;
				Fifo_full     : out std_logic;

				Fifo_dout     : out std_logic_vector(7 downto 0);
				Fifo_rd       : in  std_logic;
				Fifo_empty    : out std_logic;

				Fifo_level    : out std_logic_vector(1 downto 0)

		);
end fifo_sc_fwft_32to8;

-------------------------------------------------------------------------------
-- DECLARATION DE L'ARCHITECTURE
-------------------------------------------------------------------------------

architecture Behavioral of fifo_sc_fwft_32to8 is

-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------


component fifo_sc_fwft is
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


signal s_cpt_4    			: std_logic_vector(1 downto 0);
signal s_Fifo_dout    		: std_logic_vector(31 downto 0);
signal s_Fifo_empty    		: std_logic;
signal s_Fifo_rd     		: std_logic;



-------------------------------------------------------------------------------
-- CORPS DE L'ARCHITECTURE
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- INSTANCIATION DES ENTITES EXTERNES
-------------------------------------------------------------------------------


u_fifo_sc : fifo_sc_fwft
  Generic map(
      g_dwidth => 32 ,
      g_ddepth => g_ddepth
  )
  Port map(


        		clk           => clk    ,
				rst_n		  => rst_n  ,

				-- FIFO SIDE

				Fifo_din      => Fifo_din     ,
				Fifo_wr       => Fifo_wr      ,
				Fifo_full     => Fifo_full    ,

				Fifo_dout     => s_Fifo_dout    ,
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



process(clk,rst_n) -- delay on signals
begin
	if(rst_n = '0')then
		s_cpt_4 	<= "00";
	elsif(clk'event and clk='1') then
		if(Fifo_rd = '1')then
			s_cpt_4 	<= s_cpt_4 + 1;
		end if;
	end if;
end process;

s_Fifo_rd <= Fifo_rd 	when s_cpt_4  = "11" else '0';
Fifo_empty <= '0' 		when s_cpt_4 /= "11" else s_Fifo_empty;



Fifo_dout			<=  s_Fifo_dout(31 downto 24) when s_cpt_4 = "00" else
                        s_Fifo_dout(23 downto 16) when s_cpt_4 = "01" else
                        s_Fifo_dout(15 downto  8) when s_cpt_4 = "10" else
                        s_Fifo_dout( 7 downto  0) when s_cpt_4 = "11" else (others => '0');




end Behavioral;

