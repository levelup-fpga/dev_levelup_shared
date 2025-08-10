-- waveform_driver.vhd
-- Simulation-only driver that generates enable pulses and phase increment
-- for waveform_gen, with runtime frequency and waveform control.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity waveform_driver is
  generic (
    SAMPLE_WIDTH     : integer := 12;
    DEFAULT_WAVEFORM : integer := 0;
    SIGNED_OUTPUT    : boolean := true
  );
  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;

    -- Control inputs
    waveform_sel  : in  integer := DEFAULT_WAVEFORM; -- waveform index 0..3
    start_samples : in  integer := 32;               -- initial samples per period
    min_samples   : in  integer := 16;
    max_samples   : in  integer := 64;
    step_samples  : in  integer := -4;
    change_period : in  integer := 200;              -- enable pulses before changing frequency

    -- Output from waveform_gen
    sample_out    : out std_logic_vector(SAMPLE_WIDTH-1 downto 0)
  );
end entity waveform_driver;

architecture sim of waveform_driver is
  constant TWO_PI : real := 2.0 * 3.14159265358979323846;

  signal enable_sig  : std_logic := '0';
  signal cnt_clk     : integer := 0;
  signal cnt_enable  : integer := 0;
  signal spp_current : integer := start_samples;
  signal spp_counter : integer := 0;
  signal phase_inc   : real := TWO_PI / real(start_samples);

begin
  -- Instance of waveform_gen
  GEN: entity work.waveform_gen
    generic map (
      SAMPLE_WIDTH    => SAMPLE_WIDTH,
      DEFAULT_WAVEFORM=> DEFAULT_WAVEFORM,
      SIGNED_OUTPUT   => SIGNED_OUTPUT
    )
    port map (
      clk          => clk,
      rst_n        => rst_n,
      enable       => enable_sig,
      waveform_sel => waveform_sel,
      phase_inc    => phase_inc,
      sample_out   => sample_out
    );

  -- Enable pulse generation and frequency sweep
  enable_proc : process(clk)
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        cnt_clk     <= 0;
        cnt_enable  <= 0;
        spp_current <= start_samples;
        spp_counter <= 0;
        phase_inc   <= TWO_PI / real(start_samples);
        enable_sig  <= '0';
      else
        if cnt_clk = 0 then
          enable_sig <= '1';
          cnt_clk <= cnt_clk + 1;
          cnt_enable <= cnt_enable + 1;
          spp_counter <= spp_counter + 1;
        elsif cnt_clk = 1 then
          enable_sig <= '0';
          cnt_clk <= cnt_clk + 1;
        elsif cnt_clk < spp_current - 1 then
          cnt_clk <= cnt_clk + 1;
        else
          cnt_clk <= 0;
        end if;

        -- Frequency change
        if spp_counter >= change_period then
          spp_counter <= 0;
          spp_current <= spp_current + step_samples;
          if spp_current < min_samples then
            spp_current <= max_samples;
          elsif spp_current > max_samples then
            spp_current <= min_samples;
          end if;
          phase_inc <= TWO_PI / real(spp_current);
        end if;
      end if;
    end if;
  end process;
end architecture sim;
