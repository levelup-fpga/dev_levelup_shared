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
--
-- PROTOCOL : |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
--
-- BO-B4 are CMD (RWn, Length, Addr) Data are 32 bits
--
--  /------------\/------------\/------------\/------------\/------------\/------------\/------------\/------------\/------------\/------------\/------------\
--  \------------/\------------/\------------/\------------/\------------/\------------/\------------/\------------/\------------/\------------/\------------/
--      B0            B1            Bn            BN+1           Bn+2
--
-- BO[7] = RWN B0[6:0] = Lenth MSB
-- B1    = Length LSB (nb of 32 bit words to be transfered)
-- B2    = TDB1 SPARE
-- B3    = TDB2 SPARE
-- B4    = ADDR3
-- B5    = ADDR2
-- B6    = ADDR1
-- B7    = ADDR0

-- B8    = DATA1[31:24]
-- B9    = DATA1[23:16]
-- B10   = DATA1[15: 8]
-- B11   = DATA1[ 7: 0]

-- B12   = DATA2[31:24]
-- B13   = DATA2[23:16]
-- B14   = DATA2[15: 8]
-- B15   = DATA2[ 7: 0]
--
-- If write all data is received by MOSI
-- If read only B0 to B3 arre received Master keeps sending clock coresponding to data length and slave outputs data on MISO
-- Length is actaualy 2^8 (B1) put BO[6:0] to "000_0000" (future use reserved)
--
-- PROTOCOL : |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-------------------------------------------------------------------------------


--*****************************************************************************************************************************
-- LIBRARY
--*****************************************************************************************************************************

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
use work.util_pkg.all;


--*****************************************************************************************************************************
-- ENTITY
--*****************************************************************************************************************************

entity spi2bus is
   generic (
           g_MST_AD_WIDTH : integer := 32 -- max 32
   );
   port(
           rst_n                : in  std_logic;
           clk_sys              : in  std_logic;
           -- reg_intf
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
end spi2bus;



--*****************************************************************************************************************************
-- ARCHITECTURE
--*****************************************************************************************************************************

architecture behave of spi2bus is


----------------------------------------------------------------------------
-- COMPONENT DECLARATION
----------------------------------------------------------------------------

component spi_slave is
   port(
           rst_n                : in  std_logic;
           sys_clk              : in  std_logic;
           -- combinatorial outputs (sync to spi_clk)
           done_8bit            : out std_logic;
           data_out             : out std_logic_vector(7 downto 0);
           data_in              : in  std_logic_vector(7 downto 0);
           -- SPI interface
           spi_intf_clk         : in  std_logic;                      -- clock of the SPI interface
           spi_intf_en          : in  std_logic;                      -- enable of the SPI interface
           spi_intf_miso        : out std_logic;                      -- Master In Slave Out SPI data line
           spi_intf_mosi        : in std_logic                       -- Master Out Slave In SPI data line
       );
end component;



----------------------------------------------------------------------------
-- TYPES DECLARATION
----------------------------------------------------------------------------

type t_spi_reg is array(127 downto 0) of std_logic_vector(7 downto 0);


----------------------------------------------------------------------------
-- FUNCTIONAL CONSTANT DECLARATION
----------------------------------------------------------------------------

constant c_CMD_RANGE : integer := 3;

constant c_RXN1_POS  : std_logic_vector(2 downto 0) := "000";
constant c_LGT0_POS  : std_logic_vector(2 downto 0) := "001";
constant c_TDB1_POS  : std_logic_vector(2 downto 0) := "010";
constant c_TDB0_POS  : std_logic_vector(2 downto 0) := "011";
constant c_ADR3_POS  : std_logic_vector(2 downto 0) := "100";
constant c_ADR2_POS  : std_logic_vector(2 downto 0) := "101";
constant c_ADR1_POS  : std_logic_vector(2 downto 0) := "110";
constant c_ADR0_POS  : std_logic_vector(2 downto 0) := "111";

----------------------------------------------------------------------------
-- RANGE CONSTANT DECLARATION
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- SIGNAL DECLARATION
----------------------------------------------------------------------------


attribute keep : boolean;

signal s_done_8bit            : std_logic;
signal s_done_8bit_d          : std_logic_vector(3 downto 0);
signal s_data_out             : std_logic_vector(7 downto 0);
signal s_data_in              : std_logic_vector(7 downto 0);

signal s_spi_intf_en_d        : std_logic_vector(1 downto 0);

signal s_sot_p                : std_logic; -- start of spi transfert
signal s_eot_p                : std_logic; -- end of spi transfert

signal s_trans_rwn           : std_logic;
signal s_trans_nb_32words    : std_logic_vector(14 downto 0); --TODO : use constants
signal s_trans_nb_8words     : std_logic_vector(15 downto 0); --TOD0 : use constants
signal s_trans_base_reg_addr : std_logic_vector(15 downto 0); --TOD0 : use constants

signal s_cnt_nb_8t           : std_logic_vector(15 downto 0); ---TOD0 : use constants- not 14 because 4 words are transmited to configure transfers


signal s_dataOut  : std_logic_vector(31 downto 0);
signal s_addr    : std_logic_vector(31 downto 0);
signal s_writeEn  : std_logic;
signal s_readEn  : std_logic;

signal s_spi_intf_clk         :  std_logic;                      -- clock of the SPI interface
signal s_spi_intf_en          :  std_logic;                      -- enable of the SPI interface
signal s_spi_intf_miso        :  std_logic;                      -- Master In Slave Out SPI data line
signal s_spi_intf_mosi        : std_logic ;                      -- Master Out Slave In SPI data line


attribute keep of  s_done_8bit : signal is true;
attribute keep of  s_data_out : signal is true;
attribute keep of  s_data_in : signal is true;

attribute keep of  s_spi_intf_clk : signal is true;
attribute keep of  s_spi_intf_en : signal is true;
attribute keep of  s_spi_intf_miso : signal is true;
attribute keep of  s_spi_intf_mosi : signal is true;




--*****************************************************************************************************************************
-- BEGIN OF ARCHITECTURE
--*****************************************************************************************************************************
begin

----------------------------------------------------------------------------
-- COMPONENT INSTANTIATION
----------------------------------------------------------------------------

u_spi_slave : spi_slave
   port map(
           rst_n                => rst_n,
           sys_clk              => clk_sys,
           -- combinatorial outputs (sync to spi_clk)
           done_8bit            => s_done_8bit ,
           data_out             => s_data_out  ,
           data_in              => s_data_in   ,
           -- SPI interface
           spi_intf_clk         => s_spi_intf_clk  ,
           spi_intf_en          => s_spi_intf_en   ,
           spi_intf_miso        => s_spi_intf_miso ,
           spi_intf_mosi        => s_spi_intf_mosi
       );


s_spi_intf_clk  <= spi_intf_clk  ;
s_spi_intf_en   <= spi_intf_en   ;
spi_intf_miso   <= s_spi_intf_miso ;
s_spi_intf_mosi <= spi_intf_mosi ;




----------------------------------------------------------------------------
-- COMBINATORIAL LOGIC
----------------------------------------------------------------------------



----------------------------------------------------------------------------
-- CLOKED PROCESS
----------------------------------------------------------------------------



-- generate pulses
process(clk_sys,rst_n)
begin
    if(rst_n = '0') then
    	s_spi_intf_en_d   <= (others => '0');
	elsif(clk_sys'event and clk_sys='1') then
        s_spi_intf_en_d <= s_spi_intf_en_d(0)&s_spi_intf_en;
    end if;
end process;
s_sot_p  <= (s_spi_intf_en_d(1)  xor s_spi_intf_en_d(0) ) and s_spi_intf_en_d(1); --falling
s_eot_p  <= (s_spi_intf_en_d(1)  xor s_spi_intf_en_d(0) ) and s_spi_intf_en_d(0); --rising



-- count 8 bit transfers
process(clk_sys,rst_n)
begin
    if(rst_n = '0') then
    	s_cnt_nb_8t   <= (others => '0');
	elsif(clk_sys'event and clk_sys='1') then
        if(s_sot_p = '1' or s_eot_p = '1')then
            s_cnt_nb_8t   <= (others => '0');
        elsif(s_done_8bit = '1')then
            s_cnt_nb_8t   <= s_cnt_nb_8t + '1';
        end if;
    end if;
end process;


-- PARAMS (RW + ADDR) ------------------------------------------------------------------

-- mem spi transmition params (rw, length)
process(clk_sys,rst_n)
begin
    if(rst_n = '0') then
    	s_trans_rwn           <=  '0';
    	s_trans_nb_32words    <= (others => '0');
    	s_trans_base_reg_addr <= (others => '0');
        s_trans_nb_8words     <= (others => '0');
	elsif(clk_sys'event and clk_sys='1') then
        --find beter implementation and extend s_tran_nb_8words to right size(s_trans_nb_32words is trimed) TODO USE CONSTANTS
        s_trans_nb_8words <= (s_trans_nb_32words(12 downto 0) & "00")+conv_std_logic_vector(7,16); --TODO USE CONSTANTS (shift by two = mul by 4
        if(s_done_8bit = '1' and s_cnt_nb_8t(15 downto c_CMD_RANGE) = "000000000000")then
            case s_cnt_nb_8t(c_CMD_RANGE-1 downto 0) is
              when c_RXN1_POS =>
                s_trans_rwn                         <= s_data_out(7);
                s_trans_nb_32words(14 downto 8)     <= s_data_out(6 downto 0);

              when c_LGT0_POS =>
                s_trans_nb_32words(7 DOWNTO 0)      <= s_data_out;

              -- add TDB HERE

              when others => NULL;
            end case;
        end if;
    end if;
end process;

process(clk_sys,rst_n)
begin
    if(rst_n = '0') then
    	s_addr <= (others => '0');
    	addr <= (others => '0');
	elsif(clk_sys'event and clk_sys='1') then

	    addr <= s_addr(g_MST_AD_WIDTH-1 downto 0); -- TODO check if not greater then...

        if(s_done_8bit = '1')then
            if(s_cnt_nb_8t(15 downto c_CMD_RANGE) = "000000000000")then
                case s_cnt_nb_8t(c_CMD_RANGE-1 downto 0) is
                    when c_ADR3_POS =>
                        s_addr(31 DOWNTO 24)  <= s_data_out;

                    when c_ADR2_POS =>
                        s_addr(23 DOWNTO 16)  <= s_data_out;

                    when c_ADR1_POS =>
                        s_addr(15 DOWNTO 8)  <= s_data_out;

                    when c_ADR0_POS =>
                        s_addr(7 DOWNTO 0)  <= s_data_out;
                    when others => NULL;
                end case;
            elsif(s_cnt_nb_8t(1 downto 0) = "11")then  -- when all header is memed auto increment addr
                s_addr <= s_addr +'1'; --TODO check if not greater then g_MST_AD_WIDTH ...  with error assert
            end if;
        end if;


    end if;
end process;


-- WRITE ------------------------------------------------------------------

-- mem spi transmition data
process(clk_sys,rst_n)
begin
    if(rst_n = '0') then
    	s_dataOut <= (others => '0');
	elsif(clk_sys'event and clk_sys='1') then
        if(s_done_8bit = '1' and s_cnt_nb_8t(15 downto c_CMD_RANGE) /= "0000000000000")then
            case s_cnt_nb_8t(1 downto 0) is
              when "00" =>
                s_dataOut(31 downto 24) <= s_data_out;
              when "01" =>
                s_dataOut(23 downto 16) <= s_data_out;
              when "10" =>
                s_dataOut(15 downto  8) <= s_data_out;
              when "11" =>
                s_dataOut( 7 downto  0) <= s_data_out;
              when others => NULL;
            end case;
        end if;
    end if;
end process;

-- gen write enable
process(clk_sys,rst_n)
begin
    if(rst_n = '0') then
    	s_writeEn <= '0';
	elsif(clk_sys'event and clk_sys='1') then
        if(s_done_8bit = '1' and s_cnt_nb_8t(15 downto c_CMD_RANGE) /= "0000000000000" and s_cnt_nb_8t(1 downto 0) = "11" and s_trans_rwn = '0')then
            s_writeEn <= '1';
        else
            s_writeEn <= '0';
        end if;
    end if;
end process;


dataOut <= s_dataOut;
writeEn <= s_writeEn;





-- READ ------------------------------------------------------------------

-- gen read enable
process(clk_sys,rst_n)
begin
    if(rst_n = '0') then
    	s_readEn <= '0';
    	readEn <= '0';
	elsif(clk_sys'event and clk_sys='1') then
	    readEn <= s_readEn;
        --TODO see to optimise test condition
        if(s_done_8bit = '1'and  s_cnt_nb_8t >= X"0007" and s_cnt_nb_8t /= s_trans_nb_8words and s_cnt_nb_8t(1 downto 0) = "11" and s_trans_rwn = '1')then
            s_readEn <= '1';
        else
            s_readEn <= '0';
        end if;
    end if;
end process;

 -- mux input data
process(clk_sys,rst_n)
begin
    if(rst_n = '0') then
    	s_data_in <= (others => '0');
        s_done_8bit_d <= (others => '0');
	elsif(clk_sys'event and clk_sys='1') then
        s_done_8bit_d <= s_done_8bit_d(s_done_8bit_d'left-1 downto 0)&s_done_8bit;
        if(s_done_8bit_d(2) = '1' and s_trans_rwn = '1' and s_cnt_nb_8t > X"0007")then   -- TODO may optimise using match on msb not >
        --s_done_8bit_d(2) = s_rd_p delayed by one (slave responds one clk after read is received)
            case s_cnt_nb_8t(1 downto 0) is
                when          "00" => s_data_in <= dataIn(31 downto 24);
                when          "01" => s_data_in <= dataIn(23 downto 16);
                when          "10" => s_data_in <= dataIn(15 downto  8);
                when          "11" => s_data_in <= dataIn( 7 downto  0);
                when others        => NULL;
            end case;
        end if;
    end if;
end process;

--s_data_in <= dataIn(31 downto 24) when s_cnt_nb_8t(1 downto 0) = "00" else
--             dataIn(23 downto 16) when s_cnt_nb_8t(1 downto 0) = "01" else
--             dataIn(15 downto  8) when s_cnt_nb_8t(1 downto 0) = "10" else
--             dataIn( 7 downto  0) when s_cnt_nb_8t(1 downto 0) = "11" else
--             (others => '0');














--*****************************************************************************************************************************
-- END OF ARCHITECTURE
--*****************************************************************************************************************************

END behave;










