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

entity tb_spi_master_gen_fifo is
end tb_spi_master_gen_fifo;

-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------

architecture sim of tb_spi_master_gen_fifo is

-------------------------------------------------------------------------------
-- COMPONENT DECLARATION
-------------------------------------------------------------------------------


component spi_master_gen_fifo IS
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

            sys_fifo_rx_rd_p    : in  std_logic;
            sys_fifo_rx_data    : out std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p
            sys_fifo_rx_empty   : out std_logic;

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

-------------------------------------------------------------------------------
-- STATE DECLARATIONS FOR FSM
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- SIGNAL DECLARATION
-------------------------------------------------------------------------------


-- global TODO seperate to add and test skew resistance -----------------------------------


signal s_stop_condition  : boolean := false;

signal s_rst_n              :  std_logic := '0';
signal s_sys_clk            :  std_logic := '0'; --100MHz clock
signal s_sys_tx_lgt         :  std_logic_vector(7 downto 0);
signal s_sys_rx_lgt         :  std_logic_vector(7 downto 0);
signal s_sys_start_r        :  std_logic; -- start on rising edge (equivalent to pulse _p but acomodates for "long pulses" issued by system)
signal s_sys_done_p         :  std_logic;
signal s_sys_busy           :  std_logic;
signal s_sys_fifo_tx_wr_p   :  std_logic;
signal s_sys_fifo_tx_data   :  std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p
signal s_sys_fifo_tx_full   :  std_logic;
signal s_sys_fifo_rx_rd_p   :  std_logic;
signal s_sys_fifo_rx_data   :  std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p
signal s_sys_fifo_rx_empty  :  std_logic;
signal s_spi_cs             :  std_logic;
signal s_spi_clk            :  std_logic; --10 MHz
signal s_spi_mosi           :  std_logic;
signal s_spi_miso           :  std_logic;



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


u_spi_master_gen_fifo : spi_master_gen_fifo
   PORT map(
            rst_n               => s_rst_n ,
            sys_clk             => s_sys_clk  ,


            sys_tx_lgt          => s_sys_tx_lgt          ,
            sys_rx_lgt          => s_sys_rx_lgt          ,

            sys_start_r         => s_sys_start_r         ,
            sys_done_p          => s_sys_done_p          ,
            sys_busy            => s_sys_busy            ,

            sys_fifo_tx_wr_p    => s_sys_fifo_tx_wr_p    ,
            sys_fifo_tx_data    => s_sys_fifo_tx_data    ,
            sys_fifo_tx_full    => s_sys_fifo_tx_full    ,

            sys_fifo_rx_rd_p    => s_sys_fifo_rx_rd_p    ,
            sys_fifo_rx_data    => s_sys_fifo_rx_data    ,
            sys_fifo_rx_empty   => s_sys_fifo_rx_empty   ,

            -- spi_bus
            spi_cs              => s_spi_cs               ,
            spi_clk             => s_spi_clk              ,
            spi_mosi            => s_spi_mosi             ,
            spi_miso            => s_spi_miso

       );




s_spi_miso <= '1';

s_sys_fifo_rx_rd_p <= not s_sys_fifo_rx_empty;

p_sys_cmd : process
begin

    --reset all -----------

    s_sys_start_r    <= '0';
    s_sys_tx_lgt     <= X"00";
    s_sys_rx_lgt     <= X"00";

    s_sys_fifo_tx_wr_p  <= '0';
    s_sys_fifo_tx_data  <= X"00";

    wait until rising_edge(s_sys_clk) and s_rst_n = '1';



    --fill fifo with 2 bytes
    s_sys_fifo_tx_wr_p  <= '1';
    s_sys_fifo_tx_data  <= X"91";
    wait until rising_edge(s_sys_clk);
    s_sys_fifo_tx_wr_p  <= '1';
    s_sys_fifo_tx_data  <= X"55";
    wait until rising_edge(s_sys_clk);
    s_sys_fifo_tx_wr_p  <= '0';
    s_sys_fifo_tx_data  <= X"00";



    -- send 2 bytes
    s_sys_start_r    <= '1';
    s_sys_tx_lgt     <= X"02";
    s_sys_rx_lgt     <= X"00";
    wait until rising_edge(s_sys_clk);s_sys_start_r<= '0';s_sys_tx_lgt<= X"00";s_sys_rx_lgt<= X"00";


    wait until rising_edge(s_sys_clk) and s_sys_done_p = '1';



    -- send 2 bytes read 3 bytes

    s_sys_start_r    <= '1';
    s_sys_tx_lgt     <= X"02";
    s_sys_rx_lgt     <= X"03";
    wait until rising_edge(s_sys_clk);s_sys_start_r<= '0';s_sys_tx_lgt<= X"00";s_sys_rx_lgt<= X"00";

    wait until rising_edge(s_sys_clk) and s_sys_done_p = '1';

    --read fifo content (TODO)
    --while fifo not empty read etc..




    -- end of test
    wait for c_RST_DURATION;

    --assert false report "Test: OK" severity failure;
    s_stop_condition <= true;

end process p_sys_cmd;









end sim;

