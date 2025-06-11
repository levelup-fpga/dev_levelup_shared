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


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; -- for conv_std_logic_vector()
use ieee.std_logic_unsigned.all;



-------------------------------------------------------------------------------
-- ENTITY INTERFACE
-------------------------------------------------------------------------------

entity tb_spi_master_gen_fifo_reg_mm is
end tb_spi_master_gen_fifo_reg_mm;

-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------

architecture sim of tb_spi_master_gen_fifo_reg_mm is

-------------------------------------------------------------------------------
-- COMPONENT DECLARATION
-------------------------------------------------------------------------------


component spi_master_gen_fifo_reg_mm IS
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
end component;


component spi2bus is
   generic (
           g_MST_AD_WIDTH : integer := 32 -- max 32
   );
   port(
           rst_n                : in  std_logic;
           clk_sys              : in  std_logic;
           -- reg_intf
           addr                 : out  std_logic_vector(31 downto 0);
           writeEn              : out  std_logic;
           dataOut              : out  std_logic_vector(31 downto 0);
           readEn               : out  std_logic;
           dataIn               : in   std_logic_vector(31 downto 0);

           -- SPI interface
           spi_intf_clk         : in  std_logic;                      -- clock of the SPI interface
           spi_intf_en          : in  std_logic;                      -- enable of the SPI interface
           spi_intf_miso        : out std_logic;                      -- Master In Slave Out SPI data line
           spi_intf_mosi        : in std_logic                       -- Master Out Slave In SPI data line
       );
end component;

component bus2bram is
    generic(
            g_RAM_ADDR_WIDTH     : integer   := 8
     );
   port(
           clk_sys              : in  std_logic;
           -- reg_intf
           addr                 : in   std_logic_vector(g_RAM_ADDR_WIDTH-1 downto 0);
           writeEn              : in   std_logic;
           dataIn               : in   std_logic_vector(31 downto 0);
           readEn               : in   std_logic;
           readRdy              : out  std_logic;
           dataOut              : out  std_logic_vector(31 downto 0)
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

constant c_MST_SYS_CLK_PERIOD   : time :=  25 ns;
constant c_SLV_SYS_CLK_PERIOD   : time :=  25 ns;
constant c_RST_DURATION         : time :=  10 us;

constant   c_MST_AD_WIDTH       : integer := 32; -- max 32
constant   c_RAM_ADDR_WIDTH     : integer :=  8;



-------------------------------------------------------------------------------
-- STATE DECLARATIONS FOR FSM
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- SIGNAL DECLARATION
-------------------------------------------------------------------------------


-- global TODO seperate to add and test skew resistance -----------------------------------


signal s_stop_condition  : boolean := false;

signal s_rst_n              :  std_logic := '0';
signal s_mst_sys_clk        :  std_logic := '0'; --100MHz clock
signal s_slv_sys_clk        :  std_logic := '0'; --100MHz clock

signal s_reg_addr           :  std_logic_vector( 1 downto 0);
signal s_reg_wr             :  std_logic;
signal s_reg_wr_data        :  std_logic_vector(31 downto 0);
signal s_reg_rd             :  std_logic;
signal s_reg_rd_dv          :  std_logic;
signal s_reg_rd_data        :  std_logic_vector(31 downto 0);
signal s_irq_done_p         :  std_logic;

signal s_spi_cs             :  std_logic;
signal s_spi_clk            :  std_logic; --10 MHz
signal s_spi_mosi           :  std_logic;
signal s_spi_miso           :  std_logic;




 --signal s_addr               :  std_logic_vector(g_RAM_ADDR_WIDTH-1 downto 0);
 signal s_addr               :  std_logic_vector(31 downto 0);
 signal s_writeEn            :  std_logic;
 signal s_dataIn             :  std_logic_vector(31 downto 0);
 signal s_readEn             :  std_logic;
 signal s_readRdy            :  std_logic;
 signal s_dataOut            :  std_logic_vector(31 downto 0);



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

s_mst_sys_clk <= not s_mst_sys_clk after c_MST_SYS_CLK_PERIOD/2;
s_slv_sys_clk <= not s_slv_sys_clk after c_SLV_SYS_CLK_PERIOD/2;



u_spi2bus : spi2bus
   generic map(
           g_MST_AD_WIDTH       => c_MST_AD_WIDTH
   )
   port map(
           rst_n               => s_rst_n    ,
           clk_sys             => s_mst_sys_clk  ,
           -- reg_intf
           addr                 => s_addr     ,
           writeEn              => s_writeEn  ,
           dataOut              => s_dataOut  ,
           readEn               => s_readEn   ,
           dataIn               => s_dataIn   ,

           -- SPI interface
           spi_intf_clk         => s_spi_clk   ,
           spi_intf_en          => s_spi_cs    ,
           spi_intf_miso        => s_spi_miso  ,
           spi_intf_mosi        => s_spi_mosi
   );


u_bus2bram : bus2bram
    generic map(
            g_RAM_ADDR_WIDTH     => 8
     )
    port map(
           clk_sys              => s_slv_sys_clk  ,
           -- reg_intf
           addr                 => s_addr(c_RAM_ADDR_WIDTH-1 downto 0)      ,
           writeEn              => s_writeEn   ,
           dataIn               => s_dataOut   ,
           readEn               => s_readEn    ,
           readRdy              => open        ,
           dataOut              => s_dataIn
       );




u_spi_master_gen_fifo_reg_mm : spi_master_gen_fifo_reg_mm
   PORT map(
            rst_n               => s_rst_n ,
            sys_clk             => s_slv_sys_clk  ,


            reg_addr            => s_reg_addr             ,
            reg_wr              => s_reg_wr               ,
            reg_wr_data         => s_reg_wr_data          ,
            reg_rd              => s_reg_rd               ,
            reg_rd_dv           => s_reg_rd_dv            ,
            reg_rd_data         => s_reg_rd_data          ,
            irq_done_p          => s_irq_done_p           ,

            -- spi_bus
            spi_cs              => s_spi_cs               ,
            spi_clk             => s_spi_clk              ,
            spi_mosi            => s_spi_mosi             ,
            spi_miso            => s_spi_miso

       );



p_sys_cmd : process


        -- procedure declaration for this process ----------------------------

        procedure proc_set_conf(
            tx_lgt : in integer;
            rx_lgt : in integer
        ) is
        begin
            wait until rising_edge(s_mst_sys_clk);
            s_reg_addr      <= "01"         ;
            s_reg_wr        <= '1'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= conv_std_logic_vector(rx_lgt, 16)&conv_std_logic_vector(tx_lgt, 16)  ;
            wait until rising_edge(s_mst_sys_clk);
            s_reg_addr      <= "00"         ;
            s_reg_wr        <= '0'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= X"00000000"  ;
            wait until rising_edge(s_mst_sys_clk);
        end proc_set_conf;

        procedure proc_wr_txd(
            txd  : in std_logic_vector(7 downto 0)
        ) is
        begin
            wait until rising_edge(s_mst_sys_clk);
            s_reg_addr      <= "11"         ;
            s_reg_wr        <= '1'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= X"000000"&txd;
            wait until rising_edge(s_mst_sys_clk);
            s_reg_addr      <= "00"         ;
            s_reg_wr        <= '0'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= X"00000000"  ;
            wait until rising_edge(s_mst_sys_clk);
        end proc_wr_txd;

        procedure proc_rd_rxd is
        begin
            wait until rising_edge(s_mst_sys_clk);
            s_reg_addr      <= "11"         ;
            s_reg_wr        <= '0'          ;
            s_reg_rd        <= '1'          ;
            s_reg_wr_data   <= X"00000000"  ;
            wait until rising_edge(s_mst_sys_clk);
            s_reg_addr      <= "00"         ;
            s_reg_wr        <= '0'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= X"00000000"  ;
            wait until rising_edge(s_mst_sys_clk);
        end proc_rd_rxd;

        procedure proc_start_transfer is
        begin
            wait until rising_edge(s_mst_sys_clk);
            s_reg_addr      <= "00"         ;
            s_reg_wr        <= '1'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= X"00000003"; -- start + irqen
            wait until rising_edge(s_mst_sys_clk);
            s_reg_addr      <= "00"         ;
            s_reg_wr        <= '0'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= X"00000000"  ;
            wait until rising_edge(s_mst_sys_clk);
            s_reg_addr      <= "00"         ;
            s_reg_wr        <= '1'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= X"00000002"; -- nstart + irqen
            wait until rising_edge(s_mst_sys_clk);
            s_reg_addr      <= "00"         ;
            s_reg_wr        <= '0'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= X"00000000"  ;
            wait until rising_edge(s_mst_sys_clk);
        end proc_start_transfer;

begin

    --reset all --------------------------------------------------------

    s_reg_addr      <= "00"         ;
    s_reg_wr        <= '0'          ;
    s_reg_rd        <= '0'          ;
    s_reg_wr_data   <= X"00000000"  ;

    wait until rising_edge(s_mst_sys_clk) and s_rst_n = '1';


    -- TR1 ============================================================
    -- configure and start spi transfers ------------------------------
    proc_wr_txd(X"00"); --RWn
    proc_wr_txd(X"02"); --2x32bit data
    proc_wr_txd(X"55");
    proc_wr_txd(X"55");

    proc_wr_txd(X"00"); -- addr
    proc_wr_txd(X"00");
    proc_wr_txd(X"00");
    proc_wr_txd(X"02"); -- addr

    proc_wr_txd(X"DE");
    proc_wr_txd(X"AD");
    proc_wr_txd(X"BE");
    proc_wr_txd(X"AF");

    proc_wr_txd(X"C0");
    proc_wr_txd(X"1D");
    proc_wr_txd(X"CA");
    proc_wr_txd(X"FE");


    proc_set_conf(16,0);

    proc_start_transfer;
    wait until rising_edge(s_mst_sys_clk) and s_irq_done_p = '1';
    wait until rising_edge(s_mst_sys_clk);

    -- configure and start spi transfers ------------------------------
    proc_wr_txd(X"80"); --RWn
    proc_wr_txd(X"02"); --2x32bit data
    proc_wr_txd(X"55");
    proc_wr_txd(X"55");

    proc_wr_txd(X"00"); -- addr
    proc_wr_txd(X"00");
    proc_wr_txd(X"00");
    proc_wr_txd(X"02"); -- addr


    proc_set_conf(8,8);

    proc_start_transfer;
    wait until rising_edge(s_mst_sys_clk) and s_irq_done_p = '1';
    proc_rd_rxd;
    proc_rd_rxd;
    proc_rd_rxd;
    proc_rd_rxd;

    proc_rd_rxd;
    proc_rd_rxd;
    proc_rd_rxd;
    proc_rd_rxd;


    -- TR2 ============================================================
    -- configure and start spi transfers ------------------------------
    proc_wr_txd(X"00"); --RWn
    proc_wr_txd(X"03"); --2x32bit data
    proc_wr_txd(X"55");
    proc_wr_txd(X"55");

    proc_wr_txd(X"00"); -- addr
    proc_wr_txd(X"00");
    proc_wr_txd(X"00");
    proc_wr_txd(X"01"); -- addr



    proc_wr_txd(X"D1");
    proc_wr_txd(X"01");
    proc_wr_txd(X"01");
    proc_wr_txd(X"01");

    proc_wr_txd(X"D2");
    proc_wr_txd(X"02");
    proc_wr_txd(X"02");
    proc_wr_txd(X"02");

    proc_wr_txd(X"D3");
    proc_wr_txd(X"03");
    proc_wr_txd(X"03");
    proc_wr_txd(X"03");


    proc_set_conf(20,0);

    proc_start_transfer;
    wait until rising_edge(s_mst_sys_clk) and s_irq_done_p = '1';

    -- configure and start spi transfers ------------------------------
    proc_wr_txd(X"80"); --RWn
    proc_wr_txd(X"03"); --2x32bit data
    proc_wr_txd(X"55");
    proc_wr_txd(X"55");

    proc_wr_txd(X"00"); -- addr
    proc_wr_txd(X"00");
    proc_wr_txd(X"00");
    proc_wr_txd(X"01"); -- addr


    proc_set_conf(8,12);

    proc_start_transfer;
    wait until rising_edge(s_mst_sys_clk) and s_irq_done_p = '1';
    proc_rd_rxd;
    proc_rd_rxd;
    proc_rd_rxd;
    proc_rd_rxd;

    proc_rd_rxd;
    proc_rd_rxd;
    proc_rd_rxd;
    proc_rd_rxd;

    proc_rd_rxd;
    proc_rd_rxd;
    proc_rd_rxd;
    proc_rd_rxd;






    -- end of test----------------------------------------------------
    wait for c_RST_DURATION;
    --assert false report "Test: OK" severity failure;
    s_stop_condition <= true;

end process p_sys_cmd;









end sim;

