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
entity spi_master_gen_fifo_reg_mm IS
generic (
    g_CLK_DIV : integer := 20;
    g_SPI_CPOL      : std_logic   := '1';
    g_SPI_CPHA      : std_logic   := '1' -- TODO NOT IMPLEMENTED default is '1'
    );
   PORT(
            rst_n           : in std_logic;

            -- system control
            sys_clk         : in  std_logic; --100MHz clock


            reg_addr       : in  std_logic_vector( 1 downto 0);
            reg_wr         : in  std_logic;
            reg_wr_data    : in  std_logic_vector(31 downto 0);
            reg_rd         : in  std_logic;
            reg_rd_dv      : out std_logic;
            reg_rd_data    : out std_logic_vector(31 downto 0);
            irq_done_p     : out std_logic;

            -- spi_bus
            spi_cs          : out std_logic;
            spi_clk         : out std_logic; --10 MHz
            spi_mosi        : out std_logic;
            spi_miso        : in  std_logic

       );
end spi_master_gen_fifo_reg_mm;

architecture rtl of spi_master_gen_fifo_reg_mm is

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES DE TYPAGE
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES FONCTIONNELLES
-------------------------------------------------------------------------------

constant c_REG_0    : std_logic_vector(1 downto 0) := "00"; --cmd
constant c_REG_1    : std_logic_vector(1 downto 0) := "01"; --conf lgt
constant c_REG_2    : std_logic_vector(1 downto 0) := "10"; --status
constant c_REG_3    : std_logic_vector(1 downto 0) := "11"; --data

-------------------------------------------------------------------------------
-- DECLARATION DE TYPES ET SOUS TYPES
-------------------------------------------------------------------------------

type t_reg is array (3 downto 0) of std_logic_vector (31 downto 0);

-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------

component spi_master_gen_fifo IS
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
end component;




-------------------------------------------------------------------------------
-- DECLARATION DES ETATS MACHINE
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- DECLARATION DE SIGNAUX INTERNES
-------------------------------------------------------------------------------

signal s_reg            : t_reg;
alias  a_start          : std_logic                     is s_reg(0)(0);
alias  a_irq_en         : std_logic                     is s_reg(0)(1);

alias  a_tx_lgt         : std_logic_vector(15 downto 0) is s_reg(1)(15 downto 0);
alias  a_rx_lgt         : std_logic_vector(15 downto 0) is s_reg(1)(31 downto 16);

alias  a_busy           : std_logic                     is s_reg(2)(0);
alias  a_tx_full        : std_logic                     is s_reg(2)(8);
alias  a_tx_empty       : std_logic                     is s_reg(2)(9);
alias  a_rx_full        : std_logic                     is s_reg(2)(12);
alias  a_rx_empty       : std_logic                     is s_reg(2)(13);

signal s_fifo_wr_p      : std_logic;
signal s_fifo_rd_p      : std_logic;
signal s_sys_done_p     : std_logic;

-- TODO : Not used signal s_sys_fifo_tx_data : std_logic_vector(7 downto 0);
signal s_sys_fifo_rx_data : std_logic_vector(7 downto 0);


-- just assignations for signal availability for debug puposes, no impact
signal s_spi_clk        : std_logic;
signal s_spi_cs         : std_logic;
signal s_spi_mosi       : std_logic;
signal s_spi_miso       : std_logic;
signal s_reg_wr_data    : std_logic_vector(31 downto 0);
-- TODO : Not used signal s_reg_rd_data    : std_logic_vector(31 downto 0);
signal s_reg_wr         : std_logic;

signal s_reg_addr_d     : std_logic_vector( 1 downto 0);
signal s_reg_rd_d       : std_logic;


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





u_spi_master_gen_fifo : spi_master_gen_fifo
generic map(
    g_CLK_DIV       => g_CLK_DIV,
    g_SPI_CPOL      => g_SPI_CPOL,
    g_SPI_CPHA      => g_SPI_CPHA  -- TODO NOT IMPLEMENTED default is '1'
)
   PORT map(
            rst_n               => rst_n        ,
            sys_clk             => sys_clk      ,

            -- system control

            sys_start_r         => a_start              ,
            sys_tx_lgt          => a_tx_lgt(7 downto 0) ,
            sys_rx_lgt          => a_rx_lgt(7 downto 0) ,
            sys_done_p          => s_sys_done_p         ,
            sys_busy            => a_busy               ,

            sys_fifo_tx_wr_p    => s_fifo_wr_p              ,
            sys_fifo_tx_data    => s_reg_wr_data(7 downto 0)            ,
            sys_fifo_tx_full    => a_tx_full                ,
            sys_fifo_tx_empty   => a_tx_empty               ,

            sys_fifo_rx_rd_p    => s_fifo_rd_p              ,
            sys_fifo_rx_data    => s_sys_fifo_rx_data       ,
            sys_fifo_rx_full    => a_rx_full                ,
            sys_fifo_rx_empty   => a_rx_empty               ,

            -- spi_bus
            spi_cs             => s_spi_cs                    ,
            spi_clk            => s_spi_clk                   ,
            spi_mosi           => s_spi_mosi                  ,
            spi_miso           => s_spi_miso

       );


            spi_cs              <= s_spi_cs   ;
            spi_clk             <= s_spi_clk  ;
            spi_mosi            <= s_spi_mosi ;
            s_spi_miso          <= spi_miso   ;




irq_done_p <= s_sys_done_p when a_irq_en = '1' else '0';




-------------------------------------------------------------------------------
-- PROCESS CLK
-------------------------------------------------------------------------------

-- write in regs ---------------------------
s_reg_wr <= reg_wr;

s_fifo_wr_p         <= s_reg_wr when reg_addr = c_REG_3 else '0';
s_reg_wr_data       <= reg_wr_data;

process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_reg(0)  <= (others =>'0');
        s_reg(1)  <= (others =>'0');
    elsif rising_edge(sys_clk) then
        if(s_reg_wr = '1') then
            case reg_addr is
                when c_REG_0 => s_reg(0) <= s_reg_wr_data;
                when c_REG_1 => s_reg(1) <= s_reg_wr_data;
                when others  => NULL;
            end case;
        end if;
    end if;
end process;



-- read in regs ---------------------------

s_fifo_rd_p         <= reg_rd when reg_addr = c_REG_3 else '0';

reg_rd_data         <= s_reg(0)                     when s_reg_addr_d = c_REG_0 else
                       s_reg(1)                     when s_reg_addr_d = c_REG_1 else
                       s_reg(2)                     when s_reg_addr_d = c_REG_2 else
                       X"000000"&s_sys_fifo_rx_data when s_reg_addr_d = c_REG_3 else (others => '0');



reg_rd_dv           <= s_reg_rd_d;

process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_reg_rd_d   <= '0';
        s_reg_addr_d <= "00";
    elsif rising_edge(sys_clk) then
        s_reg_rd_d   <= reg_rd;
        s_reg_addr_d <= reg_addr;
    end if;
end process;


end rtl;
