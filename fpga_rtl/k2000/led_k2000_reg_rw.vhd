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
entity led_k2000_reg_rw IS
    generic(
            g_data_width        : integer   := 8
     );
   PORT(
           clk           : in std_logic;
           rst_n         : in std_logic;

           reg_addr       : in  std_logic_vector( 1 downto 0);
           reg_wr         : in  std_logic;
           reg_wr_data    : in  std_logic_vector(31 downto 0);
           reg_rd         : in  std_logic;
           reg_rd_dv      : out std_logic;
           reg_rd_data    : out std_logic_vector(31 downto 0);

           led_out       : out std_logic_vector(g_data_width-1 downto 0)
       );
end led_k2000_reg_rw;

architecture rtl of led_k2000_reg_rw is

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES DE TYPAGE
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES FONCTIONNELLES
-------------------------------------------------------------------------------


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


signal s_reg            : t_reg;
alias  a_led_mode       : std_logic_vector(1 downto 0)  is s_reg(0)(1 downto 0);
alias  a_led_pol        : std_logic                     is s_reg(0)(8);

alias  a_led_value  : std_logic_vector(31 downto 0) is s_reg(1);
alias  a_cpt_match  : std_logic_vector(31 downto 0) is s_reg(2);
--signal s_cpt_match  : std_logic_vector(31 downto 0);


signal s_cpt_shift      : std_logic_vector(31 downto 0);

signal s_led_out_k2000  : std_logic_vector(g_data_width-1 downto 0);
signal s_shift_RnL      : std_logic;

signal s_led_out_cpt    : std_logic_vector(g_data_width-1 downto 0);

signal s_led_out        : std_logic_vector(g_data_width-1 downto 0);



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


-- write in regs and memory ---------------------------

process(clk,rst_n) begin
    if(rst_n = '0') then
        s_reg(0)  <= X"00000000"; -- k2000 positive led
        s_reg(1)  <= X"55555555";
        s_reg(2)  <= conv_std_logic_vector(30000000,32);
        s_reg(3)  <= (others =>'0');
    elsif rising_edge(clk) then
      if(reg_wr = '1') then
          s_reg(conv_integer(reg_addr)) <= reg_wr_data;
        end if;
    end if;
end process;


-- read in regs and memory ---------------------------

process(clk,rst_n) begin
    if(rst_n = '0') then
        reg_rd_data  <= X"00000000";
        reg_rd_dv    <= '0';
    elsif rising_edge(clk) then
        reg_rd_dv  <= reg_rd;
        if(reg_rd = '1') then
          reg_rd_data <= s_reg(conv_integer(reg_addr));
        end if;
    end if;
end process;




-- cpt_shift --------------------------------------

process(clk,rst_n)
begin
    if(rst_n = '0')then
        s_cpt_shift    <= (others => '0');
        --s_cpt_match    <= (others => '0');
    elsif(clk'event and clk='1') then
        --s_cpt_match <= a_cpt_match;
        if(s_cpt_shift = a_cpt_match or reg_wr = '1') then
            s_cpt_shift <= (others => '0');
        else
            s_cpt_shift <= s_cpt_shift + 1;
        end if;
    end if;
end process;

-- k2000 shift --------------------------------------

process(clk,rst_n)
begin
    if(rst_n = '0')then
        s_shift_RnL    <= '0'; -- shift left
    elsif(clk'event and clk='1') then
        if(s_led_out_k2000(s_led_out_k2000'left) = '1') then
            s_shift_RnL    <= '1'; -- shift right
        elsif(s_led_out_k2000(s_led_out_k2000'right) = '1') then
            s_shift_RnL    <= '0'; -- shift left
        end if;
    end if;
end process;


process(clk,rst_n)
begin
    if(rst_n = '0')then
        s_led_out_k2000(s_led_out'left downto 1)    <= (others => '0');
        s_led_out_k2000(0) <= '1';
    elsif(clk'event and clk='1') then
        if(s_cpt_shift = a_cpt_match) then
            if(s_shift_RnL = '0') then
                s_led_out_k2000 <= s_led_out_k2000(s_led_out_k2000'left-1 downto 0) & s_led_out_k2000(s_led_out_k2000'left);
            elsif(s_shift_RnL = '1') then
                s_led_out_k2000 <= s_led_out_k2000(s_led_out_k2000'right) & s_led_out_k2000(s_led_out_k2000'left downto 1);
            end if;
        end if;
    end if;
end process;

-- basic_cpt --------------------------------------

process(clk,rst_n)
begin
    if(rst_n = '0')then
        s_led_out_cpt   <= (others => '0');
    elsif(clk'event and clk='1') then
        if(s_cpt_shift = a_cpt_match) then
            s_led_out_cpt <= s_led_out_cpt + 1;
        end if;
    end if;
end process;


-- mux outputs

s_led_out <=    s_led_out_k2000 when a_led_mode = "00" else
                s_led_out_cpt   when a_led_mode = "01" else
                a_led_value(g_data_width-1 downto 0);

led_out <= s_led_out when a_led_pol = '0' else not s_led_out;


end rtl;
