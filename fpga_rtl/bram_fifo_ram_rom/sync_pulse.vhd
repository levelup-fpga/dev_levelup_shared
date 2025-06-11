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


-------------------------------------------------------------------------------:
-- DEPENDANCES
-------------------------------------------------------------------------------:


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-------------------------------------------------------------------------------:
-- DECLARATION DE L'INTERFACE DE L'ENTITE                                      :
-------------------------------------------------------------------------------:
ENTITY sync_pulse IS
PORT
(
   rst  : IN std_logic;
   clka : IN std_logic;
   ina  : IN std_logic;
   clkb : IN std_logic;
   outb : OUT std_logic
);
END sync_pulse;

-------------------------------------------------------------------------------:
-- ARCHITECTURE DE L'ENTITE                                                    :
-------------------------------------------------------------------------------:
ARCHITECTURE archi OF sync_pulse IS

-------------------------------------------------------------------------------:
-- DECLARATION DE TYPEs                                                        :
-------------------------------------------------------------------------------:

-------------------------------------------------------------------------------:
-- DECLARATION D'ENTITES EXTERNES                                              :
-------------------------------------------------------------------------------:

-------------------------------------------------------------------------------:
-- DECLARATION DES ETATS MACHINE                                               :
-------------------------------------------------------------------------------:

-------------------------------------------------------------------------------:
-- DECLARATION DE SIGNAUX INTERNES                                             :
-------------------------------------------------------------------------------:

constant c_SYNC_LENGTH : integer := 2;


signal s_clkb_pulse_detected      : std_logic;
signal s_clkb_pulse_detected_sync : std_logic_vector(2 downto 0);
signal s_clkb_pulse_detected_safe : std_logic;
signal s_clkb_pulse_detected_safe_d : std_logic;

signal s_clka_holded_pulse             : std_logic;
signal s_clka_holded_pulse_sync        : std_logic_vector(2 downto 0);
signal s_clka_holded_pulse_safe        : std_logic;
signal s_clka_holded_pulse_safe_d        : std_logic;

signal s_ina_d                    : std_logic;

-------------------------------------------------------------------------------:
-- CORPS DE L'ARCHITECTURE                                                     :
-------------------------------------------------------------------------------:
BEGIN

-------------------------------------------------------------------------------:
-- SIGNAUX CONSTANTS                                                           :
-------------------------------------------------------------------------------:

-------------------------------------------------------------------------------:
-- INSTANCIATION D'ENTITES EXTERNES                                            :
-------------------------------------------------------------------------------:

-------------------------------------------------------------------------------:
-- MACHINE D'ETAT                                                              :
-------------------------------------------------------------------------------:

-------------------------------------------------------------------------------:
-- SORTIES ACTIVEES PAR LA MACHINE D'ETAT                                      :
-------------------------------------------------------------------------------:

-------------------------------------------------------------------------------:
-- PROCESSUS ASYNCHRONES                                                       :
-------------------------------------------------------------------------------:

-------------------------------------------------------------------------------:
-- PROCESSUS SYNCHRONES                                                        :
-------------------------------------------------------------------------------:

PROCESS (rst, clka) -- holde ina pulse
BEGIN
   IF (rst = '1') THEN
       s_clka_holded_pulse          <= '0';
       s_ina_d                      <= '0';
       s_clkb_pulse_detected_safe_d <= '0';
   ELSIF rising_edge(clka) THEN
       s_ina_d                      <= ina;
       s_clkb_pulse_detected_safe_d <= s_clkb_pulse_detected_safe;
      if(ina = '1' and s_ina_d = '0') then
          s_clka_holded_pulse <= '1';
      elsif( s_clkb_pulse_detected_safe = '1' and s_clkb_pulse_detected_safe_d = '0') then
          s_clka_holded_pulse <= '0';
      end if;
   END IF;
END PROCESS;

PROCESS (rst, clka) -- resynck pulse detected ok signal to clka
BEGIN
   IF (rst = '1') THEN
       s_clkb_pulse_detected_sync <= (others => '0');
       s_clkb_pulse_detected_safe <= '0';
   ELSIF rising_edge(clka) THEN
       s_clkb_pulse_detected_sync(0)          <= s_clkb_pulse_detected;
       s_clkb_pulse_detected_sync(c_SYNC_LENGTH-1 downto 1) <= s_clkb_pulse_detected_sync(c_SYNC_LENGTH-2 downto 0);
       s_clkb_pulse_detected_safe             <= s_clkb_pulse_detected_sync(c_SYNC_LENGTH-1);
   END IF;
END PROCESS;


PROCESS (rst, clkb) -- resynck holded pulse  signal to clkb
BEGIN
   IF (rst = '1') THEN
       s_clka_holded_pulse_sync <= (others => '0');
       s_clka_holded_pulse_safe <= '0';
   ELSIF rising_edge(clkb) THEN
       s_clka_holded_pulse_sync(0)          <= s_clka_holded_pulse;
       s_clka_holded_pulse_sync(c_SYNC_LENGTH - 1 downto 1) <= s_clka_holded_pulse_sync(c_SYNC_LENGTH -2 downto 0);
       s_clka_holded_pulse_safe             <= s_clka_holded_pulse_sync(c_SYNC_LENGTH-1);
   END IF;
END PROCESS;



PROCESS (rst, clkb) -- detect ina pulse and generate output pulse
BEGIN
   IF (rst = '1') THEN
       outb                         <= '0';
       s_clka_holded_pulse_safe_d   <= '0';
       s_clkb_pulse_detected        <= '0';
   ELSIF rising_edge(clkb) THEN
       s_clka_holded_pulse_safe_d <= s_clka_holded_pulse_safe;
      if(s_clka_holded_pulse_safe = '1' and s_clka_holded_pulse_safe_d = '0') then
          outb                <= '1';
          s_clkb_pulse_detected <= '1';
      elsif( s_clka_holded_pulse_safe = '0') then
          s_clkb_pulse_detected        <= '0';
          outb                         <= '0';
      else
          outb                         <= '0';
      end if;
   END IF;
END PROCESS;




END archi;
