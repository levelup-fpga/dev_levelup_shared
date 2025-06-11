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
entity spi_master_gen_fifo IS
   generic (
            g_CLK_DIV : integer := 20;
            g_SPI_CPOL      : std_logic   := '1';
            g_SPI_CPHA      : std_logic   := '1' -- TODO NOT IMPLEMENTED default is '1'
            );
   PORT(
            rst_n           : in std_logic;

            -- system control
            sys_clk         : in  std_logic; --100MHz clock


            sys_start_r     : in  std_logic; -- not taken in acount if spi is busy
            sys_tx_lgt      : in  std_logic_vector(7 downto 0); -- max
            sys_rx_lgt      : in  std_logic_vector(7 downto 0); --
            sys_done_p      : out std_logic;
            sys_busy        : out std_logic;

            sys_fifo_tx_wr_p    : in  std_logic;
            sys_fifo_tx_data    : in  std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p
            sys_fifo_tx_full    : out std_logic;
            sys_fifo_tx_empty   : out std_logic;

            sys_fifo_rx_rd_p    : in  std_logic;
            sys_fifo_rx_data    : out std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p
            sys_fifo_rx_full    : out std_logic;
            sys_fifo_rx_empty   : out std_logic;

            -- spi_bus
            spi_cs          : out std_logic;
            spi_clk         : out std_logic; --10 MHz
            spi_mosi        : out std_logic;
            spi_miso        : in  std_logic

       );
end spi_master_gen_fifo;

architecture rtl of spi_master_gen_fifo is

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES DE TYPAGE
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES FONCTIONNELLES
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- DECLARATION DE TYPES ET SOUS TYPES
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------


component spi_master_gen IS
    generic(
            g_CLK_DIV       : integer     := 20;
            g_SPI_CPOL      : std_logic   := '1';
            g_SPI_CPHA      : std_logic   := '1'; -- TODO NOT IMPLEMENTED default is '1'
            g_spi_max_lgt   : integer     := 8
     );
   PORT(
            rst_n           : in std_logic;

            -- system control
            sys_clk         : in  std_logic; --100MHz clock
            sys_start_p     : in  std_logic; -- not taken in acount if spi is busy
            sys_tx_lgt      : in  std_logic_vector(g_spi_max_lgt-1 downto 0); -- max
            sys_rx_lgt      : in  std_logic_vector(g_spi_max_lgt-1 downto 0); --
            sys_done_p      : out std_logic;
            sys_busy        : out std_logic;

            sys_txd_rd_p        : out std_logic;
            sys_txd             : in  std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p

            sys_rxd_dv_p        : out std_logic;
            sys_rxd             : out std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p

            -- spi_bus
            spi_cs          : out std_logic;
            spi_clk         : out std_logic; --10 MHz
            spi_mosi        : out std_logic;
            spi_miso        : in  std_logic

       );
end component;

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
-- DECLARATION DES ETATS MACHINE
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- DECLARATION DE SIGNAUX INTERNES
-------------------------------------------------------------------------------


signal s_sys_start_r_d    : std_logic;
signal s_sys_start_p      : std_logic;



signal s_sys_txd_rd_p    : std_logic;
signal s_sys_txd         : std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p
signal s_sys_rxd_dv_p    : std_logic;
signal s_sys_rxd         : std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p


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


u_spi_master_gen : spi_master_gen
    generic map(
            g_CLK_DIV       => g_CLK_DIV,
            g_SPI_CPOL      => g_SPI_CPOL,
            g_SPI_CPHA      => g_SPI_CPHA, -- TODO NOT IMPLEMENTED default is '1'
            g_spi_max_lgt   => 8
     )
   PORT map(
            rst_n           => rst_n        ,

            -- system control
            sys_clk         => sys_clk          ,

            sys_start_p     => s_sys_start_p    ,
            sys_tx_lgt      => sys_tx_lgt       ,
            sys_rx_lgt      => sys_rx_lgt       ,
            sys_done_p      => sys_done_p       ,
            sys_busy        => sys_busy         ,

            sys_txd_rd_p    => s_sys_txd_rd_p   ,
            sys_txd         => s_sys_txd        ,
            sys_rxd_dv_p    => s_sys_rxd_dv_p   ,
            sys_rxd         => s_sys_rxd        ,

            -- spi_bus
            spi_cs          => spi_cs           ,
            spi_clk         => spi_clk          ,
            spi_mosi        => spi_mosi         ,
            spi_miso        => spi_miso

       );


u_tx_fifo_sc : fifo_sc
  Generic map(
      g_dwidth => 8 ,
      g_ddepth => 256
  )
  Port  map(


        		clk           => sys_clk          ,
				rst_n		  => rst_n            ,

				-- FIFO SIDE

				Fifo_din      => sys_fifo_tx_data    ,
				Fifo_wr       => sys_fifo_tx_wr_p	 ,
				Fifo_full     => sys_fifo_tx_full    ,

				Fifo_dout     => s_sys_txd           ,
				Fifo_rd       => s_sys_txd_rd_p      ,
				Fifo_empty    => sys_fifo_tx_empty   ,

				Fifo_level    => open
		);


u_rx_fifo_sc : fifo_sc
  Generic map(
      g_dwidth => 8 ,
      g_ddepth => 256
  )
  Port  map(


        		clk           => sys_clk          ,
				rst_n		  => rst_n            ,

				-- FIFO SIDE

				Fifo_din      => s_sys_rxd        ,
				Fifo_wr       => s_sys_rxd_dv_p	  ,
				Fifo_full     => sys_fifo_tx_full ,

				Fifo_dout     => sys_fifo_rx_data    ,
				Fifo_rd       => sys_fifo_rx_rd_p    ,
				Fifo_empty    => sys_fifo_rx_empty   ,

				Fifo_level    => open
		);











-------------------------------------------------------------------------------
-- PROCESS CLK
-------------------------------------------------------------------------------

-- rising edge

process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_sys_start_r_d <= '0';
    elsif rising_edge(sys_clk) then
        s_sys_start_r_d <= sys_start_r;
    end if;
end process;

s_sys_start_p <= (s_sys_start_r_d xor sys_start_r) and sys_start_r;


end rtl;
