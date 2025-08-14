




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

entity tb_full_cycle_rom is
end tb_full_cycle_rom;

-------------------------------------------------------------------------------
-- ARCHITECTURE DECLARATION
-------------------------------------------------------------------------------

architecture sim of tb_full_cycle_rom is

-------------------------------------------------------------------------------
-- COMPONENT DECLARATION
-------------------------------------------------------------------------------

component full_cycle_rom IS
    generic(
        g_ADDR_WIDTH : integer := 10; -- bit width of ROM address bus
        g_DATA_WIDTH : integer := 16; -- bit width of ROM data bus

        -- relative path of memory image file
        --g_MEM_IMG_FILENAME : string := "coef_cpt.txt"
        g_MEM_IMG_FILENAME : string := ""
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

constant c_ADDR_WIDTH : integer := 13; -- bit width of ROM address bus
constant c_DATA_WIDTH : integer := 16; -- bit width of ROM data bus
--constant c_MEM_IMG_FILENAME : string := "";
constant c_MEM_IMG_FILENAME : string := "../gen_coef/coef_sin_8192.txt";

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

signal s_rom_rd          : std_logic;
signal s_rom_dout        : std_logic_vector(c_DATA_WIDTH-1 downto 0);
signal s_rom_dfirst      : std_logic;
signal s_rom_dlast       : std_logic;



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

u_full_cycle_rom : full_cycle_rom
    generic map(
        g_ADDR_WIDTH => c_ADDR_WIDTH ,
        g_DATA_WIDTH => c_DATA_WIDTH ,
        g_MEM_IMG_FILENAME  => c_MEM_IMG_FILENAME
     )
   PORT map(
            rst_n           => s_rst_n ,

            -- system control
            sys_clk         => s_sys_clk ,

            rom_rd          => s_rom_rd     ,
            rom_dout        => s_rom_dout   ,
            rom_dfirst      => s_rom_dfirst ,
            rom_dlast       => s_rom_dlast

       );


s_rom_rd <= '1';


p_sys_cmd : process
begin

    wait for c_RST_DURATION*100;
    s_stop_condition <= true;


end process p_sys_cmd;



end sim;

