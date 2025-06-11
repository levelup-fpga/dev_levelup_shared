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

entity tb_sc is
end tb_sc;

-------------------------------------------------------------------------------
-- DECLARATION DE L'ARCHITECTURE
-------------------------------------------------------------------------------

architecture Behavioral of tb_sc is

-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------


component fifo_sc is
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

				Fifo_level    : out std_logic_vector(1 downto 0)
		);
end component;


component binary2gray is
  Generic(
      g_dwidth : integer := 8
  );
  Port (
				Binary        : in  std_logic_vector(g_dwidth - 1 downto 0);
				Gray          : out std_logic_vector(g_dwidth - 1 downto 0)
		);
end component;

component gray2binary is
  Generic(
      g_dwidth : integer := 8
  );
  Port (
				Gray          : in  std_logic_vector(g_dwidth - 1 downto 0);
				Binary        : out std_logic_vector(g_dwidth - 1 downto 0)
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

constant c_bingray : integer := 20;

-------------------------------------------------------------------------------
-- DECLARATION DES ETATS MACHINE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DE SIGNAUX INTERNES
-------------------------------------------------------------------------------

signal s_clk           : std_logic := '0';
signal s_rst_n				 : std_logic;
signal s_Fifo_din      : std_logic_vector(7 downto 0);
signal s_Fifo_wr       : std_logic;
signal s_Fifo_full     : std_logic;
signal s_Fifo_dout     : std_logic_vector(7 downto 0);
signal s_Fifo_rd       : std_logic;
signal s_Fifo_empty    : std_logic;

signal s_Fifo_level    : std_logic_vector(1 downto 0);



signal s_cpt_in     : std_logic_vector(c_bingray - 1 downto 0);
signal s_cpt_out    : std_logic_vector(c_bingray - 1 downto 0);
signal s_cpt_gray   : std_logic_vector(c_bingray - 1 downto 0);

-------------------------------------------------------------------------------
-- CORPS DE L'ARCHITECTURE
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- INSTANCIATION DES ENTITES EXTERNES
-------------------------------------------------------------------------------


u_binary2gray : binary2gray
  Generic map(
      g_dwidth => c_bingray
  )
  Port map (
			Binary => s_cpt_in,
      Gray   => s_cpt_gray
		);


u_gray2binary : gray2binary
  Generic map(
      g_dwidth => c_bingray
  )
  Port map (
				Gray   => s_cpt_gray,
				Binary => s_cpt_out
		);


process(s_clk,s_rst_n)
begin
	if(s_rst_n='0')then
		s_cpt_in <= (others => '0');
	elsif(s_clk'event and s_clk='1') then
	  s_cpt_in <= s_cpt_in + 1;
	end if;
end process;










uut : fifo_sc
  Generic map(
      g_dwidth => 8,
      g_ddepth => 18
  )
  Port map (

        clk           =>  s_clk       ,
				rst_n				  =>  s_rst_n			,

				Fifo_din      =>  s_Fifo_din  ,
				Fifo_wr       =>  s_Fifo_wr   ,
				Fifo_full     =>  s_Fifo_full ,

				Fifo_dout     =>  s_Fifo_dout ,
				Fifo_rd       =>  s_Fifo_rd   ,
				Fifo_empty    =>  s_Fifo_empty ,
				Fifo_level    =>  s_Fifo_level
		);


-------------------------------------------------------------------------------
-- SIGNAUX CONSTANTS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- PROCESS CLK
-------------------------------------------------------------------------------

s_clk <= not s_clk after 20 ns;
s_rst_n <= '0', '1' after 500 ns;


--Write in fifo -------------------------------------------------------------------
process(s_clk,s_rst_n)
begin
	if(s_rst_n='0')then
		s_Fifo_wr  <= '0';
		s_Fifo_din <= (others => '0');
	elsif(s_clk'event and s_clk='1') then
	  if(s_Fifo_full = '0') then
		  s_Fifo_wr <= '1';
		  s_Fifo_din <= s_Fifo_din + '1';
		else
		  s_Fifo_wr <= '0';
		end if;
	end if;
end process;




end Behavioral;

