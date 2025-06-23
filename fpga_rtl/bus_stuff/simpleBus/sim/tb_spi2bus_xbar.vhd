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
use work.util_pkg.all;



-------------------------------------------------------------------------------
-- ENTITY INTERFACE
-------------------------------------------------------------------------------

entity tb_spi2bus_xbar is
end tb_spi2bus_xbar;

-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------

architecture sim of tb_spi2bus_xbar is

-------------------------------------------------------------------------------
-- COMPONENT DECLARATION
-------------------------------------------------------------------------------


component spi_master_gen_fifo_reg_mm IS
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

component bus2k2000 is
    generic(
            g_LED_WIDTH        : integer   := 8
     );
   port(
           rst_n                : in  std_logic;
           clk_sys              : in  std_logic;
           -- reg_intf
           addr                 : in   std_logic_vector(1 downto 0);
           writeEn              : in   std_logic;
           dataIn               : in   std_logic_vector(31 downto 0);
           readEn               : in   std_logic;
           readRdy              : out  std_logic;
           dataOut              : out  std_logic_vector(31 downto 0);
           -- SPI interface
           led_out              : out std_logic_vector(g_LED_WIDTH-1 downto 0)             -- Master Out Slave In SPI data line
       );
end component;


component busXbar is
    generic (
        g_NB_SLV_CS : integer := 3 ; -- number of slaves MSB CS : will use MSB's as Chhip select
                                    -- '1' = 2 slaves, '2' = 4 slaves, '3' = 8 slaves ect etc
        g_MST_ADDRW : integer := 32 -- master addr width -- TODO #1 : assert if not in range
    );
    port (
        -- Master interface
        clk       : in  std_logic;
        rst       : in  std_logic;

        mst_addr      : in  std_logic_vector(g_MST_ADDRW -1 downto 0);
        mst_data_out  : in  std_logic_vector(31 downto 0);
        mst_data_in   : out std_logic_vector(31 downto 0);
        mst_rd        : in  std_logic;
        mst_wr        : in  std_logic;
        mst_ready     : out std_logic;

        -- Slave interfaces
        slv_addr     : out std_logic_vector((g_MST_ADDRW - g_NB_SLV_CS -1) downto 0); -- TODO #1 : assert if not in range
        slv_data_in  : out std_logic_vector(31 downto 0); -- from master
        slv_data_out : in  std_logic_vector((g_NB_SLV_CS*32)-1 downto 0); -- to master
        slv_rd       : out std_logic_vector(g_NB_SLV_CS-1 downto 0);
        slv_wr       : out std_logic_vector(g_NB_SLV_CS-1 downto 0);
        slv_ready    : in  std_logic_vector(g_NB_SLV_CS-1 downto 0)
    );
end component;

-------------------------------------------------------------------------------
-- TYPING CONSTANT DECLARATION
-------------------------------------------------------------------------------






-------------------------------------------------------------------------------
-- FUNCTIONAL CONSTANT DECLAATION
-------------------------------------------------------------------------------

--DONT TOUCH !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

--global
constant c_DATA_WIDTH32         : integer := 32;
constant c_HEADER_LENGTH        : integer :=  8;
constant c_TRANS_LENGTH         : integer := 15;


constant c_MST_AD_WIDTH         : integer := 32;
constant c_NB_SLV_CS            : integer :=  8; --8 is 255 slaves all having 24 bit adressable space
constant c_SLV_ADDR             : integer := c_MST_AD_WIDTH - c_NB_SLV_CS;

constant c_SLV00                : integer :=  0;
constant c_SLV01                : integer :=  1;
constant c_SLV02                : integer :=  2;
constant c_SLV03                : integer :=  3;
constant c_SLV04                : integer :=  4;
constant c_SLV05                : integer :=  5;
constant c_SLV06                : integer :=  6;
constant c_SLV07                : integer :=  7;

constant c_MAX_DATA             : integer := 1024; -- TODO adjust or not it is just for TB : should depend on c_MST_AD_WIDTH and c_NB_SLV_CS
                                                   -- 1024 is well under 2**(c_MST_AD_WIDTH-c_NB_SLV_CS) ......


-- spi master regs
constant c_SPI_MASTER_REG_ADDR  : integer := 2;

-- BE CAREFULL ;-) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

constant c_GBL_CLK_PERIOD       : time :=  25 ns; --40MHz
constant c_CLK_DIV              : integer := 70;
constant c_SPI_CPOL             : std_logic   := '1';
constant c_SPI_CPHA             : std_logic   := '1'; -- TODO NOT IMPLEMENTED default is '1'
constant c_RST_DURATION         : time :=  10 us;

-- DESIGN DEPENDENT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- peripheral addr range (no worry's, CS is managed by Xbar)
constant c_RAM_ADDR_WIDTH       : integer := 10;
constant c_LED_ADDR_WIDTH       : integer := 2;


--misc
constant c_LED_WIDTH        : integer   := 8;

-------------------------------------------------------------------------------
-- TYPES AND SUB TYPES DECLARATION
-------------------------------------------------------------------------------

type t_data_from_xbar is array (c_NB_SLV_CS-1 downto 0) of std_logic_vector(31 downto 0);
signal s_slv_data_out_array : t_data_from_xbar := (others => (others => '0'));


type t_data32_array   is array(c_MAX_DATA-1 downto 0) of std_logic_vector(31 downto 0);
signal s_tx_data32    : t_data32_array;
signal s_rx_data32    : t_data32_array;

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

signal s_reg_addr           :  std_logic_vector( c_SPI_MASTER_REG_ADDR-1  downto 0);
signal s_reg_wr             :  std_logic;
signal s_reg_wr_data        :  std_logic_vector(c_DATA_WIDTH32-1 downto 0);
signal s_reg_rd             :  std_logic;
signal s_reg_rd_dv          :  std_logic;
signal s_reg_rd_data        :  std_logic_vector(c_DATA_WIDTH32-1 downto 0);
signal s_irq_done_p         :  std_logic;

signal s_spi_cs             :  std_logic;
signal s_spi_clk            :  std_logic; --10 MHz
signal s_spi_mosi           :  std_logic;
signal s_spi_miso           :  std_logic;





signal s_addr                 : std_logic_vector(c_MST_AD_WIDTH-1 downto 0);
signal s_readEn               : std_logic;
signal s_dataIn               : std_logic_vector(c_DATA_WIDTH32-1 downto 0);
signal s_writeEn              : std_logic;
signal s_dataOut              : std_logic_vector(c_DATA_WIDTH32-1 downto 0);


signal s_slv_addr      : std_logic_vector((c_MST_AD_WIDTH-c_NB_SLV_CS -1) downto 0);
signal s_slv_data_in   : std_logic_vector(c_DATA_WIDTH32-1 downto 0); -- from master
signal s_slv_data_out  : std_logic_vector((c_NB_SLV_CS*32)-1 downto 0); -- to master
signal s_slv_rd        : std_logic_vector(c_NB_SLV_CS-1 downto 0);
signal s_slv_wr        : std_logic_vector(c_NB_SLV_CS-1 downto 0);
signal s_slv_ready     : std_logic_vector(c_NB_SLV_CS-1 downto 0);


signal s_led_out       : std_logic_vector(c_LED_WIDTH-1 downto 0);             -- Master Out Slave In SPI data line


-- - ----------------------------------------------------------------------------
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


u_spi_master_gen_fifo_reg_mm : spi_master_gen_fifo_reg_mm
generic map(
    g_CLK_DIV       => c_CLK_DIV,
    g_SPI_CPOL      => c_SPI_CPOL,
    g_SPI_CPHA      => c_SPI_CPHA  -- TODO NOT IMPLEMENTED default is '1'
)
   PORT map(
            rst_n               => s_rst_n ,
            sys_clk             => s_sys_clk  ,


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


u_spi2bus : spi2bus
   generic map (
           g_MST_AD_WIDTH => c_MST_AD_WIDTH
   )
   port map(
            rst_n               => s_rst_n ,
            clk_sys             => s_sys_clk  ,
           -- reg_intf
           addr                 => s_addr    ,
           writeEn              => s_writeEn ,
           dataOut              => s_dataOut ,
           readEn               => s_readEn  ,
           dataIn               => s_dataIn  ,
           -- SPI interface
           spi_intf_clk         => s_spi_clk,
           spi_intf_en          => s_spi_cs,
           spi_intf_miso        => s_spi_miso,
           spi_intf_mosi        => s_spi_mosi
       );




u1_bus2bram : bus2bram
    generic map(
            g_RAM_ADDR_WIDTH     =>  c_RAM_ADDR_WIDTH
     )
   port map(
           clk_sys              => s_sys_clk  ,
           -- reg_intf
           addr                 => s_slv_addr(c_RAM_ADDR_WIDTH-1 downto 0)    ,
           writeEn              => s_slv_wr(c_SLV01) ,
           dataIn               => s_slv_data_in  ,
           readEn               => s_slv_rd(c_SLV01)  ,
           readRdy              => open      ,
           dataOut              => s_slv_data_out_array(c_SLV01)
       );

u2_bus2bram : bus2bram
    generic map(
            g_RAM_ADDR_WIDTH     =>  c_RAM_ADDR_WIDTH
     )
   port map(
           clk_sys              => s_sys_clk  ,
           -- reg_intf
           addr                 => s_slv_addr(c_RAM_ADDR_WIDTH-1 downto 0)    ,
           writeEn              => s_slv_wr(c_SLV02) ,
           dataIn               => s_slv_data_in  ,
           readEn               => s_slv_rd(c_SLV02)  ,
           readRdy              => open      ,
           dataOut              => s_slv_data_out_array(c_SLV02)
       );



u_bus2k2000 : bus2k2000
    generic map(
            g_LED_WIDTH        => c_LED_WIDTH
     )
   port map(
           rst_n                => s_rst_n ,
           clk_sys              => s_sys_clk  ,
           -- reg_intf
           addr                 => s_slv_addr(c_LED_ADDR_WIDTH-1 downto 0)    ,
           writeEn              => s_slv_wr(c_SLV03) ,
           dataIn               => s_slv_data_in  ,
           readEn               => s_slv_rd(c_SLV03)  ,
           readRdy              => open      ,
           dataOut              => s_slv_data_out_array(c_SLV03),
           -- SPI interface
           led_out              => s_led_out
       );


u_busXbar : busXbar
    generic map (
        g_NB_SLV_CS => c_NB_SLV_CS  ,
        g_MST_ADDRW => c_MST_AD_WIDTH
    )
    port map (
        -- Master interface
        clk       => s_rst_n ,
        rst       => s_sys_clk  ,

        mst_addr      => s_addr     ,
        mst_data_out  => s_dataOut  ,
        mst_data_in   => s_dataIn   ,
        mst_rd        => s_readEn   ,
        mst_wr        => s_writeEn  ,
        mst_ready     => open       ,

        -- Slave interfaces
        slv_addr      => s_slv_addr      ,
        slv_data_in   => s_slv_data_in   ,
        slv_data_out  => s_slv_data_out  ,
        slv_rd        => s_slv_rd        ,
        slv_wr        => s_slv_wr        ,
        slv_ready     => (others => '1')
    );

    gen_slv_array : for i in 0 to c_NB_SLV_CS-1 generate
    begin
        s_slv_data_out((i+1)*32-1 downto i*32) <= s_slv_data_out_array(i);
    end generate;


















p_sys_cmd : process



        procedure proc_wr_32to8 (
            txd_32  : in std_logic_vector(31 downto 0)
        ) is
        begin
            loop_32to8_id : for i in 3 downto 0  loop
                s_reg_wr_data   <= X"000000"&txd_32(i*8+7 downto i*8);
                wait until rising_edge(s_sys_clk); -- write data (= data)
            end loop;
        end proc_wr_32to8;




        --spi master config (all regs ar 32 bit exept dat (32 bit access but only LSB byte used in data fifo))
        procedure proc_data_transfer(
            rWn                 : in  string                                        ; --R or W
            slaveSel            : in  integer;--std_logic_vector(c_NB_SLV_CS-1    downto 0)   ; -- (SS)
            baseAddr            : in  std_logic_vector(c_SLV_ADDR-1     downto 0)   ; -- (32bit-SS)
            transLgt            : in  integer                                         --(nb of 32 bit words to be transfered max 2**16 Bytes on tx and 2**16 Bytes on rx
        ) is
            variable v_rwn              : std_logic;
            variable v_rx_lgt           : integer;
            variable v_tx_lgt           : integer;
            variable v_32bit_data       : integer;
            variable v_08bit_data       : integer;

        begin

            --Compute tmp variables ********************************************************************************
            if(rWn = "R")then
                v_rwn := '1';
                v_rx_lgt := (transLgt*4);
                v_tx_lgt := c_HEADER_LENGTH;
            else
                v_rwn := '0';
                v_rx_lgt := 0;
                v_tx_lgt := c_HEADER_LENGTH+transLgt*4; --TOCHECK
            end if;



            --"RE-RESET SPI MASTER ACCESS" ********************************************************************************
            wait until rising_edge(s_sys_clk);
            s_reg_addr      <= "00"         ;
            s_reg_wr        <= '0'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= X"00000000"  ;



            --write in spi master tx fifo (8bit values @"11") ******************************************************************
            -- start write and selec fifo_wr reg addr -------------------------
            wait until rising_edge(s_sys_clk);
            s_reg_wr        <= '1'          ;  -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            s_reg_rd        <= '0'          ;  -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            s_reg_addr      <= "11"         ;  -- "11" = WR FIFO ADDR in spi master (TODO => make constants in pkg or elsewhere)


            -- write header ------------------------------------------------
            proc_wr_32to8(v_rwn & conv_std_logic_vector(transLgt, c_TRANS_LENGTH) & X"5555"); -- X"5555" is spare fields : TBD
            -- write SS+ADDR
            proc_wr_32to8(conv_std_logic_vector(slaveSel,c_NB_SLV_CS)&baseAddr);
            --write data
            loop_tx_id : for i in 0 to transLgt-1  loop
                if(rWn = "W") then
                    proc_wr_32to8(s_tx_data32(i));
                else
                    proc_wr_32to8(X"00000000");
                end if;
            end loop;


            --write in spi rx/tx length register ---------------------------------------------------------------
            s_reg_wr        <= '0';
            wait until rising_edge(s_sys_clk); -- set rx/tx byte lgt for spi transfer
            s_reg_wr        <= '1';
            s_reg_addr      <= "01"          ;
            s_reg_wr_data   <= conv_std_logic_vector((v_rx_lgt), 16)&conv_std_logic_vector(v_tx_lgt, 16)  ;
            wait until rising_edge(s_sys_clk); -- set rx/tx byte lgt for spi transfer
            s_reg_wr        <= '0';
            wait until rising_edge(s_sys_clk);
            s_reg_wr        <= '1';
            s_reg_addr      <= "00"         ;
            s_reg_wr_data   <= X"00000003"; -- start + irqen
            wait until rising_edge(s_sys_clk); -- set rx/tx byte lgt for spi transfer
            s_reg_wr        <= '0';
            wait until rising_edge(s_sys_clk);
            s_reg_wr        <= '1';
            s_reg_wr_data   <= X"00000002"; -- nstart + irqen



            --"STOP SPI MASTER ACCESS" -------------------------------------------------------------------------
            wait until rising_edge(s_sys_clk);
            s_reg_addr      <= "00"         ;
            s_reg_wr        <= '0'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= X"00000000"  ;

            --read data if transfer is "R" type
            wait until rising_edge(s_sys_clk) and s_irq_done_p = '1';


            if(rWn = "R") then
                s_reg_addr      <= "11"         ;
                s_reg_wr        <= '0'          ;
                s_reg_rd        <= '1'          ;
                wait until rising_edge(s_sys_clk);
                loop_rx_id : for i in 0 to transLgt-1  loop
                    s_rx_data32(i) <= s_reg_rd_data;
                end loop;
                wait until rising_edge(s_sys_clk);
            end if;

            --"STOP SPI MASTER ACCESS" -------------------------------------------------------------------------
            wait until rising_edge(s_sys_clk);
            s_reg_addr      <= "00"         ;
            s_reg_wr        <= '0'          ;
            s_reg_rd        <= '0'          ;
            s_reg_wr_data   <= X"00000000"  ;

        end proc_data_transfer;













begin




    --reset all --------------------------------------------------------

    s_reg_addr      <= "00"         ;
    s_reg_wr        <= '0'          ;
    s_reg_rd        <= '0'          ;
    s_reg_wr_data   <= X"00000000"  ;

    wait until rising_edge(s_sys_clk) and s_rst_n = '1';


    --K2000 :
    --R0 =   [8]        polarity
    --       [1:0] "00" = k2000  "01" = cpt "otherts" = fixed
    --R1 =   ['']       fixed value
    --R1 =   ['']       frequency
    s_tx_data32(0) <= X"00000100";
    proc_data_transfer("W",c_SLV03,X"000002",1);
    wait for c_RST_DURATION;
    s_tx_data32(0) <= X"00000001";
    proc_data_transfer("W",c_SLV03,X"000000",1);
    wait for c_RST_DURATION;
    s_tx_data32(0) <= X"00000002";
    s_tx_data32(1) <= X"00000055";
    proc_data_transfer("W",c_SLV03,X"000000",2);
    wait for c_RST_DURATION;
    s_tx_data32(0) <= X"00000002";
    s_tx_data32(1) <= X"000000AA";
    proc_data_transfer("W",c_SLV03,X"000000",2);
    wait for c_RST_DURATION;
    s_tx_data32(0) <= X"00000000";
    proc_data_transfer("W",c_SLV03,X"000000",1);












    --fill data to send
    s_tx_data32(0) <= X"DA010101";
    s_tx_data32(1) <= X"DA020202";
    s_tx_data32(2) <= X"DA030303";
    s_tx_data32(3) <= X"DA040404";
    s_tx_data32(4) <= X"DA050505";
    s_tx_data32(5) <= X"DA060606";
    s_tx_data32(6) <= X"DA060606";
    s_tx_data32(7) <= X"DA070707";
    s_tx_data32(8) <= X"DA080808";
    wait until rising_edge(s_sys_clk);

    proc_data_transfer("W",c_SLV01,X"000002",5);
    proc_data_transfer("R",c_SLV01,X"000002",3); --TODO : BUG IN SPI MASTER/TB_PROC : TO fix (first read ok next write ko) most likly in tb procedures ...
    proc_data_transfer("W",c_SLV01,X"0000A0",8);
    proc_data_transfer("R",c_SLV01,X"0000A0",3); --TODO : BUG IN SPI MASTER/TB_PROC : to fix (first read ok next write ko)

    --proc_data_transfer("W",c_SLV01,X"000002",5);
    --proc_data_transfer("W",c_SLV01,X"0000A0",8);
    --proc_data_transfer("R",c_SLV01,X"000001",20); --TODO : BUG IN SPI MASTER/TB_PROC : to fix (first read ok next write ko)




   --fill data to send
    s_tx_data32(0) <= X"DB010101";
    s_tx_data32(1) <= X"DB020202";
    s_tx_data32(2) <= X"DB030303";
    s_tx_data32(3) <= X"DB040404";
    s_tx_data32(4) <= X"DB050505";
    s_tx_data32(5) <= X"DB060606";
    s_tx_data32(6) <= X"DB060606";
    s_tx_data32(7) <= X"DB070707";
    s_tx_data32(8) <= X"DB080808";
    wait until rising_edge(s_sys_clk);

    proc_data_transfer("W",c_SLV01,X"000001",8);
    proc_data_transfer("R",c_SLV01,X"000001",8);
    wait for c_RST_DURATION*6;



    -- end of test----------------------------------------------------
    --wait until rising_edge(s_sys_clk) and s_irq_done_p = '1';
    wait for c_RST_DURATION*4;
    --assert false report "Test: OK" severity failure;
    s_stop_condition <= true;

end process p_sys_cmd;



end sim;
