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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use STD.textio.all;
use ieee.std_logic_textio.all;



-------------------------------------------------------------------------------
-- ENTITY INTERFACE
-------------------------------------------------------------------------------

entity tb_spi_master_gen is
end tb_spi_master_gen;

-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------

architecture sim of tb_spi_master_gen is

-------------------------------------------------------------------------------
-- COMPONENT DECLARATION
-------------------------------------------------------------------------------


component spi_master_gen is
    generic( --TODO CPOL and CPHA, actual IS "11"
        g_CLK_DIV       : integer     := 20;
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

            sys_txd_rd_p    : out std_logic;
            sys_txd         : in  std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p

            sys_rxd_dv_p    : out std_logic;
            sys_rxd         : out std_logic_vector(7 downto 0); -- is valid on dv_p

            -- spi_bus
            spi_cs          : out std_logic;
            spi_clk         : out std_logic; --10 MHz
            spi_mosi        : out std_logic;
            spi_miso        : in  std_logic

       );
end component;




-------------------------------------------------------------------------------
-- TYPING CONSTANT DECLARATION
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- TYPES AND SUB TYPES DECLARATION
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- FUNCTIONAL CONSTANT DECLAATION
-------------------------------------------------------------------------------

constant c_GBL_CLK_PERIOD       : time :=  25 ns; --40MHz
constant c_RST_DURATION         : time :=  10 us;

constant c_CLK_DIV              : integer := 20;
constant c_SPI_MAX_LGT          : integer := 8;



-------------------------------------------------------------------------------
-- STATE DECLARATIONS FOR FSM
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- SIGNAL DECLARATION
-------------------------------------------------------------------------------


-- global TODO seperate to add and test skew resistance -----------------------------------


signal s_stop_condition  : boolean := false;


signal s_rst_n           : std_logic := '0';
signal s_sys_clk         : std_logic := '0'; --100MHz clock
signal s_sys_start_p     : std_logic; -- not taken in acount if spi is busy

signal s_sys_tx_lgt      : std_logic_vector(c_SPI_MAX_LGT-1 downto 0); -- max 256,
signal s_sys_rx_lgt      : std_logic_vector(c_SPI_MAX_LGT-1 downto 0); -- max 256,


signal s_sys_done_p      : std_logic;
signal s_sys_busy        : std_logic;
signal s_sys_txd_rd_p    : std_logic;
signal s_sys_txd         : std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p
signal s_sys_rxd_dv_p    : std_logic;
signal s_sys_rxd         : std_logic_vector(7 downto 0); -- is valid on dv_p
signal s_spi_cs          : std_logic;
signal s_spi_clk         : std_logic; --10 MHz
signal s_spi_mosi        : std_logic;
signal s_spi_miso        : std_logic;




--            rst_n           : in std_logic;
--            sys_clk         : in  std_logic; --100MHz clock
--            sys_start_p     : in  std_logic; -- not taken in acount if spi is busy
--            sys_cmd         : in  std_logic_vector(7 downto 0); -- RW + reg addr (first byte sent on spi)
--            sys_trans_lgt   : in  std_logic_vector(g_spi_max_lgt-1 downto 0); -- max 256, must include cmd byte (to transfer 4 bytes must be
--            sys_txd         : in  std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p
--
--            spi_miso        : in  std_logic

-------------------------------------------------------------------------------
-- CORPS DE L'ARCHITECTURE
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- ENTITY INSTANCIATION
-------------------------------------------------------------------------------







-------------------------------------------------------------------------------
-- TB DRIVE SIGNALS
-------------------------------------------------------------------------------


-- clock and reset ---------------------------------------------------

s_rst_n    <= '0', '1' after c_RST_DURATION;

s_sys_clk <= not s_sys_clk after c_GBL_CLK_PERIOD/2;


u_spi_master_gen : spi_master_gen
    generic map( --TODO CPOL and CPHA, actual IS "11"
            g_CLK_DIV       => c_CLK_DIV        ,
            g_spi_max_lgt   => c_SPI_MAX_LGT
     )
   PORT MAP(
            rst_n           => s_rst_n           , --: in std_logic;
            sys_clk         => s_sys_clk         , --: in  std_logic; --100MHz clock

            sys_start_p     => s_sys_start_p     , --: in  std_logic; -- not taken in acount if spi is busy
            sys_tx_lgt      => s_sys_tx_lgt      ,
            sys_rx_lgt      => s_sys_rx_lgt      ,
            sys_done_p      => s_sys_done_p      , --: out std_logic;
            sys_busy        => s_sys_busy        , --: out std_logic;

            sys_txd_rd_p    => s_sys_txd_rd_p    , --: out std_logic;
            sys_txd         => s_sys_txd         , --: in  std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p
            sys_rxd_dv_p    => s_sys_rxd_dv_p    , --: out std_logic;
            sys_rxd         => s_sys_rxd         , --: out std_logic_vector(7 downto 0); -- is valid on dv_p

            spi_cs          => s_spi_cs          , --: out std_logic;
            spi_clk         => s_spi_clk         , --: out std_logic; --10 MHz
            spi_mosi        => s_spi_mosi        , --: out std_logic;
            spi_miso        => s_spi_miso          --: in  std_logic

       );





s_spi_miso <= '1';


p_sys_cmd : process
begin

    s_sys_start_p     <= '0';
    s_sys_tx_lgt      <= X"00";
    s_sys_rx_lgt      <= X"00";

    wait until rising_edge(s_sys_clk) and s_rst_n = '1';

    s_sys_start_p    <= '1';
    s_sys_tx_lgt      <= X"03";
    s_sys_rx_lgt      <= X"03";
    wait until rising_edge(s_sys_clk);s_sys_start_p     <= '0';s_sys_tx_lgt      <= X"00";s_sys_tx_lgt      <= X"00";
    wait until rising_edge(s_sys_clk) and s_sys_done_p = '1';


    s_sys_start_p    <= '1';
    s_sys_tx_lgt      <= X"02";
    s_sys_rx_lgt      <= X"01";
    wait until rising_edge(s_sys_clk);s_sys_start_p     <= '0';s_sys_tx_lgt      <= X"00";s_sys_tx_lgt      <= X"00";
    wait until rising_edge(s_sys_clk) and s_sys_done_p = '1';


    s_sys_start_p    <= '1';
    s_sys_tx_lgt      <= X"05";
    s_sys_rx_lgt      <= X"00";
    wait until rising_edge(s_sys_clk);s_sys_start_p     <= '0';s_sys_tx_lgt      <= X"00";s_sys_tx_lgt      <= X"00";
    wait until rising_edge(s_sys_clk) and s_sys_done_p = '1';



    wait for c_RST_DURATION;
    s_stop_condition <= true;


end process p_sys_cmd;



p_rd_tx_data : process
begin

    s_sys_txd  <= X"00";
    wait until rising_edge(s_sys_clk) and s_sys_txd_rd_p = '1';
    s_sys_txd  <= X"91"; wait until rising_edge(s_sys_clk);s_sys_txd  <= X"00";


    s_sys_txd  <= X"00";
    wait until rising_edge(s_sys_clk) and s_sys_txd_rd_p = '1';
    s_sys_txd  <= X"55"; wait until rising_edge(s_sys_clk);s_sys_txd  <= X"00";

    s_sys_txd  <= X"00";
    wait until rising_edge(s_sys_clk) and s_sys_txd_rd_p = '1';
    s_sys_txd  <= X"29"; wait until rising_edge(s_sys_clk);s_sys_txd  <= X"00";


end process p_rd_tx_data;







end sim;

