-- waveform_driver.vhd
-- Generates enable pulses and phase increment for waveform_gen,
-- with runtime frequency sweep and waveform selection.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity waveform_driver is
  generic (
    DEFAULT_WAVEFORM : integer := 0
  );
  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;

    -- Control inputs
    start_samples : in  integer := 32;  -- initial samples per period
    min_samples   : in  integer := 16;
    max_samples   : in  integer := 64;
    step_samples  : in  integer := -4;
    change_period : in  integer := 200; -- enable pulses before changing freq
    waveform_sel  : in  integer := DEFAULT_WAVEFORM;

    -- Outputs to waveform_gen
    enable_sig    : out std_logic;
    phase_inc     : out real;
    waveform_sel_o: out integer
  );
end entity waveform_driver;

architecture sim of waveform_driver is
  constant TWO_PI : real := 2.0 * 3.14159265358979323846;

  signal cnt_clk     : integer := 0;
  signal spp_current : integer := 32;
  signal spp_counter : integer := 0;
  signal enable_i    : std_logic := '0';
  signal phase_inc_i : real := TWO_PI / real(32);
begin
  enable_sig     <= enable_i;
  phase_inc      <= phase_inc_i;
  waveform_sel_o <= waveform_sel;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        cnt_clk     <= 0;
        spp_current <= start_samples;
        spp_counter <= 0;
        phase_inc_i <= TWO_PI / real(start_samples);
        enable_i    <= '0';
      else
        if cnt_clk = 0 then
          enable_i <= '1';
          cnt_clk <= cnt_clk + 1;
          spp_counter <= spp_counter + 1;
        elsif cnt_clk = 1 then
          enable_i <= '0';
          cnt_clk <= cnt_clk + 1;
        elsif cnt_clk < spp_current - 1 then
          cnt_clk <= cnt_clk + 1;
        else
          cnt_clk <= 0;
        end if;

        if spp_counter >= change_period then
          spp_counter <= 0;
          spp_current <= spp_current + step_samples;
          if spp_current < min_samples then
            spp_current <= max_samples;
          elsif spp_current > max_samples then
            spp_current <= min_samples;
          end if;
          phase_inc_i <= TWO_PI / real(spp_current);
        end if;
      end if;
    end if;
  end process;
end architecture sim;
