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


-------------------------------------------------------------------------------
-- DECLARATION DE L'INTERFACE DE L'ENTITE
-------------------------------------------------------------------------------
entity spi_master_gen IS
    generic(
        g_CLK_DIV       : integer     := 10; -- SPI Periode = sys_clk periode*2*g_CLK_DIV (10 is lowest at this level (TODO test), must be even number)
                                             -- TODO set sample : @10 = periode x20 : @20 periode x40
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

            sys_txd_rd_p    : out std_logic;
            sys_txd         : in  std_logic_vector(7 downto 0); -- must be valid 1 clock cycle after rd_p

            sys_rxd_dv_p    : out std_logic;
            sys_rxd         : out std_logic_vector(7 downto 0); -- is valid on dv_p

            -- spi_bus
            spi_cs          : out std_logic;
            spi_clk         : out std_logic;
            spi_mosi        : out std_logic;
            spi_miso        : in  std_logic

       );
end spi_master_gen;

architecture rtl of spi_master_gen is

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES DE TYPAGE
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES FONCTIONNELLES
-------------------------------------------------------------------------------

--fixed do not modify
constant c_CLK_DIV_CPT_LGT          : integer := 32; --overkill to acomodate testing
constant c_CLK_FULL_PERIODE         : std_logic_vector(c_CLK_DIV_CPT_LGT-1 downto 0) := conv_std_logic_vector(g_CLK_DIV,c_CLK_DIV_CPT_LGT);
constant c_CLK_HALF_PERIODE         : std_logic_vector(c_CLK_DIV_CPT_LGT-1 downto 0) := '0'&c_CLK_FULL_PERIODE(c_CLK_FULL_PERIODE'left downto 1); --div by 2

constant c_PERIODE                  : std_logic_vector(c_CLK_DIV_CPT_LGT-1 downto 0) := c_CLK_FULL_PERIODE - '1';
constant c_HALF_PERIODE             : std_logic_vector(c_CLK_DIV_CPT_LGT-1 downto 0) := c_CLK_HALF_PERIODE - '1';

constant c_8BIT_CPT_LGT             : integer := 4; -- will loopback
constant c_8BIT_SENT                : std_logic_vector(c_8BIT_CPT_LGT-1 downto 0) := X"8";
constant c_CPT8B_SHIFT_TX           : integer := 0; -- dont shift on first falling edge, data already present (cmd) or load new one (txd)
constant c_READ_NEXT_DATA           : std_logic_vector(c_8BIT_CPT_LGT-1 downto 0) := X"6"; -- could be any during previous 8bit transfer, 6 last possible..


constant c_CPTCLK_SHIFT_TX          : integer := conv_integer(c_HALF_PERIODE); -- when to shift right ts shift reg (falling edge)
constant c_CPTCLK_LAST_TX_SHIFT     : integer := c_CPTCLK_SHIFT_TX - 1;
constant c_CPTCLK_SHIFT_RX          : integer := g_CLK_DIV - 1; -- when to shift right ts shift reg (falling edge)

-- to tune for dev
constant c_RD_P_DELAY               : integer := g_CLK_DIV + 3; -- TODO : to tune


-- --OK to modify (optimise)
-- -- delay on cs, spi tranferts and busy
constant c_START_P_D_LGT   : integer := 40;
constant c_START_SPI_OK    : integer := 8;--5
constant c_START_CS_OK     : integer := 2;

constant c_STOP_CS         : integer := 12;
constant c_STOP_DONE       : integer := 15;




-------------------------------------------------------------------------------
-- DECLARATION DE TYPES ET SOUS TYPES
-------------------------------------------------------------------------------

type t_reg is array (3 downto 0) of std_logic_vector (31 downto 0);

-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- DECLARATION DES ETATS MACHINE
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- DECLARATION DE SIGNAUX INTERNES
-------------------------------------------------------------------------------


signal s_start_p_d   : std_logic_vector(c_START_P_D_LGT-1 downto 0);
signal s_sys_busy_d  : std_logic_vector(c_START_P_D_LGT-1 downto 0);


signal s_mem_sys_tx_lgt   : std_logic_vector(g_spi_max_lgt-1 downto 0); -- max 256, must include cmd byte (to transfer 4 bytes must be set to 5)
signal s_mem_sys_rx_lgt   : std_logic_vector(g_spi_max_lgt-1 downto 0); -- max 256, must include cmd byte (to transfer 4 bytes must be set to 5)


-- counters -------------------
--Pspi = Period SPI
signal s_cpt_Pspi      : std_logic_vector(c_CLK_DIV_CPT_LGT-1 downto 0);
signal s_cpt_Pspi_rst  : std_logic;
signal s_cpt_Pspi_en   : std_logic;
signal s_cpt_Pspi_p    : std_logic;
signal s_cpt_halfe_Pspi_p     : std_logic;

signal s_cpt_8bit       : std_logic_vector(c_8BIT_CPT_LGT-1 downto 0);
signal s_cpt_8bit_rst   : std_logic;
signal s_cpt_8bit_en    : std_logic;
signal s_cpt_8bit_p     : std_logic;


signal s_cpt_tx_en      : std_logic;
signal s_cpt_tx_lgt     : std_logic_vector(g_spi_max_lgt-1 downto 0);
signal s_cpt_tx_rd_p    : std_logic;
signal s_cpt_tx_rd_p_d  : std_logic_vector(c_RD_P_DELAY -1 downto 0);

signal s_cpt_rx_en      : std_logic;
signal s_cpt_rx_lgt     : std_logic_vector(g_spi_max_lgt-1 downto 0);



signal s_txd_sr         : std_logic_vector(7 downto 0);
signal s_txd_fs         : std_logic; --first shift

signal s_rxd_sr         : std_logic_vector(7 downto 0);


signal s_spi_clk        : std_logic;
signal s_spi_cs         : std_logic;

signal s_sys_done_p     : std_logic;
signal s_sys_busy       : std_logic;

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

-------------------------------------------------------------------------------
-- PROCESS CLK
-------------------------------------------------------------------------------



-----------------------------------------------------
------MEM & DELAYS-----------------------------------
-----------------------------------------------------

process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_start_p_d     <= (others => '0');
        s_sys_busy_d    <= (others => '0');
        s_cpt_tx_rd_p_d <= (others => '0');
    elsif rising_edge(sys_clk) then
        s_start_p_d     <= s_start_p_d(s_start_p_d'left-1 downto 0)&sys_start_p;
        s_sys_busy_d    <= s_sys_busy_d(s_sys_busy_d'left-1 downto 0)&s_sys_busy;
        s_cpt_tx_rd_p_d <= s_cpt_tx_rd_p_d(s_cpt_tx_rd_p_d'left-1 downto 0)&s_cpt_tx_rd_p;
    end if;
end process;

-- memorise data_lgt to be sent
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_mem_sys_tx_lgt <= (others => '0');
        s_mem_sys_rx_lgt <= (others => '0');
    elsif rising_edge(sys_clk) then
        if(sys_start_p = '1') then
            s_mem_sys_tx_lgt <= sys_tx_lgt;
            s_mem_sys_rx_lgt <= sys_rx_lgt;
        end if;
    end if;
end process;



-----------------------------------------------------
------TX DATA----------------------------------------
-----------------------------------------------------


-- en tx
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_cpt_tx_en <= '0';
    elsif rising_edge(sys_clk) then
        if(s_start_p_d(c_START_SPI_OK) = '1') then
            s_cpt_tx_en <= '1';
        elsif(s_cpt_tx_lgt = s_mem_sys_tx_lgt) then
            s_cpt_tx_en <= '0';
        end if;
    end if;
end process;

-- count tx
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_cpt_tx_lgt <= (others => '0');
    elsif rising_edge(sys_clk) then
        if(s_start_p_d(c_START_SPI_OK) = '1') then
            s_cpt_tx_lgt <= (others => '0');
        elsif(s_cpt_tx_en = '1' and s_cpt_8bit_p = '1' and s_cpt_tx_lgt /= (s_mem_sys_tx_lgt)) then
            s_cpt_tx_lgt <= s_cpt_tx_lgt + '1';
        end if;
    end if;
end process;


-- load tx shift register
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_cpt_tx_rd_p <= '0';
    elsif rising_edge(sys_clk) then
        if((s_cpt_Pspi_p = '1' and s_cpt_8bit = c_READ_NEXT_DATA and s_cpt_tx_en = '1' and s_cpt_tx_lgt < (s_mem_sys_tx_lgt-1)) or (sys_start_p = '1')) then -- TODO implements substracor, maybe extract from process
            s_cpt_tx_rd_p <= '1';
        else
            s_cpt_tx_rd_p <= '0';
        end if;
    end if;
end process;

sys_txd_rd_p <= s_cpt_tx_rd_p_d(c_RD_P_DELAY-2);

-- shift tx sr
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_txd_sr <= (others => '0');
        s_txd_fs <= '0';
    elsif rising_edge(sys_clk) then
        if(s_cpt_tx_rd_p_d(c_RD_P_DELAY-1) = '1') then
            s_txd_sr    <= sys_txd;
        elsif( (s_cpt_Pspi = c_CPTCLK_SHIFT_TX and s_cpt_8bit  /= c_CPT8B_SHIFT_TX)
              or (s_cpt_tx_lgt = s_mem_sys_tx_lgt and s_cpt_Pspi = c_CPTCLK_LAST_TX_SHIFT)) then
            s_txd_sr <= s_txd_sr(s_txd_sr'left-1 downto 0) & '0';
        end if;
    end if;
end process;










-----------------------------------------------------
------RX DATA----------------------------------------
-----------------------------------------------------

-- always rx shift register on rising
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_rxd_sr    <= (others => '0');
    elsif rising_edge(sys_clk) then
        if( s_cpt_Pspi  = c_CPTCLK_SHIFT_RX) then
            s_rxd_sr <= s_rxd_sr(s_rxd_sr'left-1 downto 0) & spi_miso;
        end if;
    end if;
end process;

-- en rx
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_cpt_rx_en <= '0';
    elsif rising_edge(sys_clk) then
        if(s_cpt_tx_lgt = s_mem_sys_tx_lgt and s_cpt_tx_en = '1') then
            s_cpt_rx_en <= '1';
        elsif(s_cpt_rx_lgt = s_mem_sys_rx_lgt) then
            s_cpt_rx_en <= '0';
        end if;
    end if;
end process;

-- count rx
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_cpt_rx_lgt <= (others => '0');
    elsif rising_edge(sys_clk) then
        if(s_start_p_d(c_START_SPI_OK) = '1') then
            s_cpt_rx_lgt <= (others => '0');
        elsif(s_cpt_rx_en = '1' and s_cpt_8bit_p = '1' and s_cpt_rx_lgt /= s_mem_sys_rx_lgt) then
            s_cpt_rx_lgt <= s_cpt_rx_lgt + '1';
        end if;
    end if;
end process;

-- data read from spi to sys
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        sys_rxd_dv_p <= '0';
        sys_rxd      <= (others => '0');
    elsif rising_edge(sys_clk) then
        if(s_cpt_8bit_p = '1' and s_cpt_rx_en = '1') then
            sys_rxd_dv_p <= '1';
            sys_rxd      <= s_rxd_sr;
        else
            sys_rxd_dv_p <= '0';
            sys_rxd      <= (others => '0');
        end if;
    end if;
end process;



-- busy and done

process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_sys_busy <= '0';
    elsif rising_edge(sys_clk) then
        if(s_cpt_rx_en = '1' or s_cpt_tx_en = '1') then
            s_sys_busy <= '1';
        else
            s_sys_busy <= '0';
        end if;
    end if;
end process;

sys_busy <= s_sys_busy;


--signal s_sys_done_p     : std_logic;
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_sys_done_p <= '0';
    elsif rising_edge(sys_clk) then
        if(s_sys_busy_d(c_STOP_DONE) = '0' and s_sys_busy_d(c_STOP_DONE+1) = '1') then
            s_sys_done_p <= '1';
        else
            s_sys_done_p <= '0';
        end if;
    end if;
end process;

sys_done_p <= s_sys_done_p;



-- SPI signals

process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_spi_clk <= '1';
    elsif rising_edge(sys_clk) then
        if(s_cpt_tx_lgt = s_mem_sys_tx_lgt and s_cpt_rx_lgt = s_mem_sys_rx_lgt) then
            s_spi_clk <= '1';
        elsif(s_cpt_halfe_Pspi_p = '1') then
            s_spi_clk <= not s_spi_clk;
        end if;
    end if;
end process;

spi_clk <= s_spi_clk when g_SPI_CPOL = '1' else not s_spi_clk;

process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_spi_cs <= '1';
    elsif rising_edge(sys_clk) then
        if(s_start_p_d(c_START_CS_OK) = '1') then
            s_spi_cs <= '0';
        elsif(s_sys_busy_d(c_STOP_CS) = '0' and s_sys_busy_d(c_STOP_CS+1) = '1') then -- TODO : maybe add delay
            s_spi_cs <= '1';
        end if;
    end if;
end process;

spi_cs <= s_spi_cs;


spi_mosi <= s_txd_sr(7);



-- count 10Mhz related --------------------------------------------




-- enable counter
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_cpt_Pspi_en <= '0';
    elsif rising_edge(sys_clk) then
        if(s_start_p_d(c_START_SPI_OK) = '1') then --Could stop when transfer done
            s_cpt_Pspi_en <= '1';
        elsif(s_sys_done_p = '1') then
            s_cpt_Pspi_en <= '0';
        end if;
    end if;
end process;

s_cpt_Pspi_rst <= s_start_p_d(c_START_SPI_OK);

-- count 10MHz for spi transfers (sys_clk is 100Mhz)
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_cpt_Pspi <= (others => '0');
    elsif rising_edge(sys_clk) then
        if(s_cpt_Pspi_rst = '1' or s_cpt_Pspi = c_PERIODE) then --Could stop when transfer done
            s_cpt_Pspi <= (others => '0');
        elsif(s_cpt_Pspi_en = '1') then
            s_cpt_Pspi <= s_cpt_Pspi + '1';
        end if;
    end if;
end process;

-- pulse for half and full 10MHz periode
s_cpt_Pspi_p <= '1' when s_cpt_Pspi = c_PERIODE                                   else '0';
s_cpt_halfe_Pspi_p  <= '1' when s_cpt_Pspi = c_HALF_PERIODE or s_cpt_Pspi = c_PERIODE   else '0';




------count 8 bit related----------------------------------------

-- enable counter
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_cpt_8bit_en <= '0';
    elsif rising_edge(sys_clk) then
        if(s_start_p_d(c_START_SPI_OK) = '1') then
            s_cpt_8bit_en <= '1';
        elsif(s_sys_done_p = '1') then
            s_cpt_8bit_en <= '0';
        end if;
    end if;
end process;

s_cpt_8bit_rst <= s_start_p_d(c_START_SPI_OK);

-- count number of bits sent (8 per byte...)
process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_cpt_8bit <= (others => '0');
    elsif rising_edge(sys_clk) then
        if(s_cpt_8bit_rst = '1' or s_cpt_8bit = c_8BIT_SENT) then
            s_cpt_8bit <= (others => '0');
        elsif(s_cpt_8bit_en = '1' and s_cpt_Pspi_p = '1') then
            s_cpt_8bit <= s_cpt_8bit + '1';
        end if;
    end if;
end process;

s_cpt_8bit_p <= '1' when s_cpt_8bit = c_8BIT_SENT else '0';








end rtl;
