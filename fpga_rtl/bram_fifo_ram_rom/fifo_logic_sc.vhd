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

entity fifo_logic_sc is


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
end fifo_logic_sc;

-------------------------------------------------------------------------------
-- DECLARATION DE L'ARCHITECTURE
-------------------------------------------------------------------------------

architecture Behavioral of fifo_logic_sc is

-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES DE TYPAGE
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- DECLARATION DE TYPES ET SOUS TYPES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES FONCTIONNELLES
-------------------------------------------------------------------------------

constant c_all1  : std_logic_vector(log2(g_ddepth)-1 downto 0) := (others => '1');

-------------------------------------------------------------------------------
-- DECLARATION DES ETATS MACHINE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DE SIGNAUX INTERNES
-------------------------------------------------------------------------------


signal s_fifo_full     : std_logic;
signal s_fifo_empty    : std_logic;

signal s_ram_cpt_wr    : std_logic_vector(log2(g_ddepth) downto 0);
alias  a_ram_loop_wr   : std_logic                                    is s_ram_cpt_wr(s_ram_cpt_wr'left);
alias  a_ram_addr_wr   : std_logic_vector(log2(g_ddepth)-1 downto 0)  is s_ram_cpt_wr(s_ram_cpt_wr'left-1 downto 0);
signal s_ram_addr_wr_d : std_logic_vector(log2(g_ddepth)-1 downto 0);


signal s_ram_cpt_rd    : std_logic_vector(log2(g_ddepth) downto 0);
alias  a_ram_loop_rd   : std_logic                                    is s_ram_cpt_rd(s_ram_cpt_rd'left);
alias  a_ram_addr_rd   : std_logic_vector(log2(g_ddepth)-1 downto 0)  is s_ram_cpt_rd(s_ram_cpt_rd'left-1 downto 0);

signal s_fifo_level    : std_logic_vector(log2(g_ddepth)-1 downto 0);





-------------------------------------------------------------------------------
-- CORPS DE L'ARCHITECTURE
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- INSTANCIATION DES ENTITES EXTERNES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- SIGNAUX CONSTANTS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- PROCESS CLK
-------------------------------------------------------------------------------


Ram_addr_wr <= a_ram_addr_wr;
Ram_addr_rd <= a_ram_addr_rd;

Fifo_dout    <= Ram_data_rd;
Ram_data_wr  <= Fifo_din;

Ram_wr       <= Fifo_wr and (not s_fifo_full);
Ram_rd       <= Fifo_rd and (not s_fifo_empty);


s_fifo_empty <= '1' when ((a_ram_loop_rd  = a_ram_loop_wr) and (a_ram_addr_rd = a_ram_addr_wr)) else '0';
s_fifo_full  <= '1' when ((a_ram_loop_rd /= a_ram_loop_wr) and (a_ram_addr_rd = a_ram_addr_wr)) else '0';

Fifo_full <= s_fifo_full;
Fifo_empty <= s_fifo_empty;






--Lock last write location -------------------------------------------------------------------
process(clk,rst_n)
begin
	if(rst_n='0')then
		s_ram_addr_wr_d <= (others => '0');
	elsif(clk'event and clk='1') then
	  if(Fifo_wr = '1' and s_fifo_full = '0') then
	    s_ram_addr_wr_d <= a_ram_addr_wr;
	  end if;
	end if;
end process;


--Write counter -------------------------------------------------------------------
process(clk,rst_n)
begin
	if(rst_n='0')then
		s_ram_cpt_wr <= (others => '0');
	elsif(clk'event and clk='1') then
	  if(Fifo_wr = '1' and s_fifo_full = '0') then
		  s_ram_cpt_wr <= s_ram_cpt_wr + 1;
		end if;
	end if;
end process;

--Read counter -------------------------------------------------------------------
process(clk,rst_n)
begin
	if(rst_n='0')then
		s_ram_cpt_rd <= (others => '0');
	elsif(clk'event and clk='1') then
	  if(Fifo_rd = '1' and s_fifo_empty = '0') then
		  s_ram_cpt_rd <= s_ram_cpt_rd + 1;
		end if;
	end if;
end process;


--Level counter -------------------------------------------------------------------
process(clk,rst_n)
begin
	if(rst_n='0')then
		s_fifo_level <= (others => '0');
	elsif(clk'event and clk='1') then
	  if(s_ram_addr_wr_d >= a_ram_addr_rd) then
		  s_fifo_level <= s_ram_addr_wr_d - a_ram_addr_rd;
		else
		  s_fifo_level <= c_all1 - s_ram_addr_wr_d + a_ram_addr_rd;
		end if;
	end if;
end process;

Fifo_level <= s_fifo_level(s_fifo_level'left downto s_fifo_level'left-1);





end Behavioral;

