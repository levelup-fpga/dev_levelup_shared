
--------------------------------------------------------------------------------
-- Company      :   LevelUp FPGA Design
-- Engineer     :   Guillaume VANROYEN
--
-- Create Date  :   23/03/2025
-- Module Name  :   full_cycle_rom
-- Project Name :   NA
-- Description  :   rom with init file to generate signals
--
-- Dependencies :   NA
--
--
--
-- Revision
-- v1 -- 20/03/2023 -- creation
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- DEPENDANCES
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

library std;
use std.textio.all;


-------------------------------------------------------------------------------
-- DECLARATION DE L'INTERFACE DE L'ENTITE
-------------------------------------------------------------------------------
entity full_cycle_rom IS
    generic(
        g_ADDR_WIDTH : integer := 13; -- bit width of ROM address bus
        g_DATA_WIDTH : integer := 16; -- bit width of ROM data bus

        -- relative path of memory image file
        --g_MEM_IMG_FILENAME : string := "../coef_cpt.txt" --OK
        g_MEM_IMG_FILENAME : string := "../wave_rom_lut/gen_coef/coef_sin_8192.txt" --OK (need to go back up then back to dir... ./ does not work)
        --g_MEM_IMG_FILENAME : string := "coef_cpt.txt" --KO
        --g_MEM_IMG_FILENAME : string := "" --OK Symplifies to counter also if the coef file is a counter generated file using no BRAM
     );
   PORT(
            rst_n           : in std_logic;

            -- system control
            sys_clk         : in  std_logic; --100MHz clock

            rom_rd          : in  std_logic;
            rom_dout        : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
            rom_dfirst      : out std_logic;
            rom_dlast       : out std_logic

       );
end full_cycle_rom;


architecture rtl of full_cycle_rom is

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES DE TYPAGE
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES FONCTIONNELLES
-------------------------------------------------------------------------------

constant c_ADDR_FIRST    : std_logic_vector(g_ADDR_WIDTH downto 0) := (others => '0'); --cmd
constant c_ADDR_LAST     : std_logic_vector(g_ADDR_WIDTH downto 0) := (others => '1'); --cmd

-------------------------------------------------------------------------------
-- DECLARATION DE TYPES ET SOUS TYPES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------


component rom is
    generic (
        g_ADDR_WIDTH : integer := 4; -- bit width of ROM address bus
        g_DATA_WIDTH : integer := 4; -- bit width of ROM data bus

        -- relative path of memory image file
        g_MEM_IMG_FILENAME : string := "../data/mem_img/linear_4_4.txt"
    );
    port (
        i_clk : in std_logic; -- clock signal

        i_re   : in  std_logic; -- read enable
        i_addr : in  std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- address bus
        o_data : out std_logic_vector(g_DATA_WIDTH - 1 downto 0) -- output data bus
    );
end component;



-------------------------------------------------------------------------------
-- DECLARATION DES ETATS MACHINE
-------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- DECLARATION DE SIGNAUX INTERNES
-------------------------------------------------------------------------------

signal s_addr           : std_logic_vector(g_ADDR_WIDTH - 1 downto 0); -- address bus




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
u_rom : rom
    generic map(
        g_ADDR_WIDTH => g_ADDR_WIDTH,
        g_DATA_WIDTH => g_DATA_WIDTH,

        -- relative path of memory image file
        g_MEM_IMG_FILENAME => g_MEM_IMG_FILENAME
    )
    port map(
        i_clk  => sys_clk,

        i_re   => rom_rd,
        i_addr => s_addr,
        o_data => rom_dout
    );




-------------------------------------------------------------------------------
-- PROCESS CLK
-------------------------------------------------------------------------------

-- write in regs ---------------------------

process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        s_addr    <= (others =>'0');
    elsif rising_edge(sys_clk) then
        if(rom_rd = '1') then
            s_addr <= s_addr + 1;
        end if;
    end if;
end process;

process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        rom_dfirst    <= '0';
    elsif rising_edge(sys_clk) then
        if(s_addr = c_ADDR_FIRST) then
            rom_dfirst <= '1';
        else
            rom_dfirst <= '0';
        end if;
    end if;
end process;

process(sys_clk,rst_n) begin
    if(rst_n = '0') then
        rom_dlast     <= '0';
    elsif rising_edge(sys_clk) then
        if(s_addr = c_ADDR_LAST) then
            rom_dlast <= '1';
        else
            rom_dlast <= '0';
        end if;
    end if;
end process;



end rtl;
