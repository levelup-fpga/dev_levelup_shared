
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
entity spi_test_rambus IS
	generic(
			g_RAM_ADDR_WIDTH     : integer   := 11;
			g_NB_LED_K2000 		: integer   := 8
    );
    PORT(
            clk_50MHz           : in  std_logic                                     ;
            rst_n               : in  std_logic                                     ;

            --spi slave intf 1
            spi_slv_cs           :  in std_logic                                     ;
            spi_slv_clk          :  in std_logic                                     ;
            spi_slv_miso         : out std_logic                                     ;
            spi_slv_mosi         :  in std_logic                                     ;
            --
            --
            ---- misc
            led_k2000_out       : out std_logic_vector(g_NB_LED_K2000-1 downto 0)

       );
end spi_test_rambus;

architecture str of spi_test_rambus is

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES DE TYPAGE
-------------------------------------------------------------------------------





-------------------------------------------------------------------------------
-- DECLARATION DE TYPES ET SOUS TYPES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------


-- RTL GVR IP's --------------------------------------------------------------

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








-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES FONCTIONNELLES
-------------------------------------------------------------------------------

--DONT TOUCH !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

--global
constant c_DATA_WIDTH32         : integer := 32     ;
constant c_HEADER_LENGTH        : integer :=  8     ;
constant c_TRANS_LENGTH         : integer := 15     ;

constant c_MST_AD_WIDTH         : integer := 32                             ;
constant c_NB_SLV_CS            : integer :=  8                             ; --8 is 255 slaves all having 24 bit adressable space
constant c_SLV_ADDR             : integer := c_MST_AD_WIDTH - c_NB_SLV_CS   ;

constant c_SLV00                : integer :=  0;
constant c_SLV01                : integer :=  1;
constant c_SLV02                : integer :=  2;
constant c_SLV03                : integer :=  3;
constant c_SLV04                : integer :=  4;
constant c_SLV05                : integer :=  5;
constant c_SLV06                : integer :=  6;
constant c_SLV07                : integer :=  7;


--DONT TOUCH !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

-- peripheral addr range (no worry's, CS is managed by Xbar)
constant c_LED_ADDR_WIDTH       : integer   := 2;
--constant c_LED_WIDTH            : integer   := 4;



-------------------------------------------------------------------------------
-- TYPES AND SUB TYPES DECLARATION
-------------------------------------------------------------------------------

type t_data_from_xbar is array (c_NB_SLV_CS-1 downto 0) of std_logic_vector(31 downto 0);
signal s_slv_data_out_array : t_data_from_xbar := (others => (others => '0'))   ;


-------------------------------------------------------------------------------
-- DECLARATION DE SIGNAUX INTERNES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- SIGNAL DECLARATION
-------------------------------------------------------------------------------


-- global TODO seperate to add and test skew resistance -----------------------------------

signal s_spi_cs             :  std_logic;
signal s_spi_clk            :  std_logic; --TDB_MAX MHz for 50MHz FPGA sys_clk
signal s_spi_mosi           :  std_logic;
signal s_spi_miso           :  std_logic;



signal s_mst_addr           : std_logic_vector(c_MST_AD_WIDTH-1 downto 0)   ;
signal s_mst_readEn         : std_logic                                     ;
signal s_mst_dataIn         : std_logic_vector(c_DATA_WIDTH32-1 downto 0)   ;
signal s_mst_writeEn        : std_logic                                     ;
signal s_mst_dataOut        : std_logic_vector(c_DATA_WIDTH32-1 downto 0)   ;


signal s_slv_addr           : std_logic_vector((c_MST_AD_WIDTH-c_NB_SLV_CS -1)  downto 0);
signal s_slv_data_in        : std_logic_vector(c_DATA_WIDTH32-1                 downto 0); -- from master
signal s_slv_data_out       : std_logic_vector((c_NB_SLV_CS*32)-1               downto 0); -- to master
signal s_slv_rd             : std_logic_vector(c_NB_SLV_CS-1                    downto 0);
signal s_slv_wr             : std_logic_vector(c_NB_SLV_CS-1                    downto 0);
signal s_slv_ready          : std_logic_vector(c_NB_SLV_CS-1                    downto 0);












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

--------------------------------------------------------------------------------------------------------------
-- ETHERNET --------------------------------------------------------------------------------------------------




u_spi2bus : spi2bus
   generic map (
           g_MST_AD_WIDTH       => c_MST_AD_WIDTH
   )
   port map(
            rst_n               => rst_n            ,
            clk_sys             => clk_50MHz        ,
           -- reg_intf
           addr                 => s_mst_addr       ,
           writeEn              => s_mst_writeEn    ,
           dataOut              => s_mst_dataOut    ,
           readEn               => s_mst_readEn     ,
           dataIn               => s_mst_dataIn     ,
           -- SPI interface
           spi_intf_clk         => s_spi_clk        ,
           spi_intf_en          => s_spi_cs         ,
           spi_intf_miso        => s_spi_miso       ,
           spi_intf_mosi        => s_spi_mosi
       );

-- for debug or rerouting to output to scope real timing
s_spi_clk   <= spi_slv_clk      ;
s_spi_cs    <= spi_slv_cs       ;
spi_slv_miso    <= s_spi_miso   ;
s_spi_mosi  <= spi_slv_mosi     ;



u_busXbar : busXbar
    generic map (
        g_NB_SLV_CS => c_NB_SLV_CS  ,
        g_MST_ADDRW => c_MST_AD_WIDTH
    )
    port map (
        -- Master interface
        clk       => rst_n ,
        rst       => clk_50MHz  ,

        mst_addr      => s_mst_addr     ,
        mst_data_out  => s_mst_dataOut  ,
        mst_data_in   => s_mst_dataIn   ,
        mst_rd        => s_mst_readEn   ,
        mst_wr        => s_mst_writeEn  ,
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



u1_bus2bram : bus2bram
    generic map(
            g_RAM_ADDR_WIDTH    => g_RAM_ADDR_WIDTH
     )
   port map(
           clk_sys              => clk_50MHz                             ,
           -- reg_intf
           addr                 => s_slv_addr(g_RAM_ADDR_WIDTH-1 downto 0)  ,
           writeEn              => s_slv_wr(c_SLV01)                        ,
           dataIn               => s_slv_data_in                            ,
           readEn               => s_slv_rd(c_SLV01)                        ,
           readRdy              => open                                     ,
           dataOut              => s_slv_data_out_array(c_SLV01)
       );


u2_bus2bram : bus2bram
    generic map(
            g_RAM_ADDR_WIDTH    => g_RAM_ADDR_WIDTH
     )
   port map(
           clk_sys              => clk_50MHz                             ,
           -- reg_intf
           addr                 => s_slv_addr(g_RAM_ADDR_WIDTH-1 downto 0)  ,
           writeEn              => s_slv_wr(c_SLV02)                        ,
           dataIn               => s_slv_data_in                            ,
           readEn               => s_slv_rd(c_SLV02)                        ,
           readRdy              => open                                     ,
           dataOut              => s_slv_data_out_array(c_SLV02)
       );



u_bus2k2000 : bus2k2000
    generic map(
            g_LED_WIDTH         => g_NB_LED_K2000

     )
   port map(
            rst_n               => rst_n            ,
            clk_sys             => clk_50MHz     ,
           -- reg_intf
           addr                 => s_slv_addr(c_LED_ADDR_WIDTH-1 downto 0)  ,
           writeEn              => s_slv_wr(c_SLV03)                        ,
           dataIn               => s_slv_data_in                            ,
           readEn               => s_slv_rd(c_SLV03)                        ,
           readRdy              => open                                     ,
           dataOut              => s_slv_data_out_array(c_SLV03)            ,
           -- SPI interface
           led_out              => led_k2000_out
       );




end str;
