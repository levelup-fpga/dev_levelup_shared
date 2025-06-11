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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity busXbar is
    generic (
        g_NB_SLV_CS : integer := 3;  -- number of slaves MSB CS : will use MSB's as Chhip select
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
        slv_addr     : out std_logic_vector((g_MST_ADDRW-g_NB_SLV_CS -1) downto 0); -- TODO #1 : assert if not in range
        slv_data_in  : out std_logic_vector(31 downto 0); -- from master
        slv_data_out : in  std_logic_vector((g_NB_SLV_CS*32)-1 downto 0); -- to master
        slv_rd       : out std_logic_vector(g_NB_SLV_CS-1 downto 0);
        slv_wr       : out std_logic_vector(g_NB_SLV_CS-1 downto 0);
        slv_ready    : in  std_logic_vector(g_NB_SLV_CS-1 downto 0)
    );
end entity;

architecture rtl of busXbar is


    signal s_sel : std_logic_vector(g_NB_SLV_CS-1 downto 0) ;

    signal s_addr_i  : std_logic_vector(15 downto 0);
    signal s_data_i  : std_logic_vector(31 downto 0);


begin

    s_sel <= mst_addr(mst_addr'left downto mst_addr'left - g_NB_SLV_CS + 1) ;
    --process(clk)
    --begin
    --    if rising_edge(clk) then
    --        -- Simple decoder based on upper address bits
    --        sel <= to_integer(unsigned(addr(31 downto 30))); -- 2 MSBs select among 4 slaves
    --                                                          -- TODO #1 adjust to nb slaves
    --    end if;
    --end process;

    -- Generate signals to slaves
    slv_addr     <= mst_addr(g_MST_ADDRW- g_NB_SLV_CS-1 downto 0);
    slv_data_in  <= mst_data_out;
    gen_slave_rw : for i in 0 to g_NB_SLV_CS-1 generate
    begin
        slv_rd(i) <= mst_rd when s_sel = std_logic_vector(to_unsigned(i,g_NB_SLV_CS)) else '0';
        slv_wr(i) <= mst_wr when s_sel = std_logic_vector(to_unsigned(i,g_NB_SLV_CS)) else '0';
    end generate;


    process(slv_data_out)
    begin
        mst_data_in <= (others => '0');
        for i in 0 to g_NB_SLV_CS-1 loop
            if s_sel = std_logic_vector(to_unsigned(i,g_NB_SLV_CS)) then
                mst_data_in <= slv_data_out((i+1)*32-1 downto i*32);
            end if;
        end loop;
    end process;

    --gen_slave_data : for i in 0 to g_NB_SLV_CS-1 generate
    --begin
    --    mst_data_in <= slv_data_out((i+1)*32-1 downto i*32);
    --end generate;

end architecture;
