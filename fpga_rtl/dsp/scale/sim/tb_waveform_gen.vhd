-- tb_waveform_gen.vhd
-- Testbench with waveform_gen and waveform_driver instantiated at same level.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_waveform_gen is
end entity;

architecture tb of tb_waveform_gen is
  constant SAMPLE_WIDTH_C : integer := 12;

  signal clk           : std_logic := '0';
  signal rst_n         : std_logic := '0';
  signal enable_sig    : std_logic;
  signal phase_inc     : real;
  signal waveform_sel  : integer;
  signal sample_out    : std_logic_vector(SAMPLE_WIDTH_C-1 downto 0);

  -- Driver control
  signal start_samples : integer := 32;
  signal min_samples   : integer := 16;
  signal max_samples   : integer := 64;
  signal step_samples  : integer := -4;
  signal change_period : integer := 50;
  signal wave_ctrl     : integer := 0;

begin
  -- Waveform driver
  DRIVER: entity work.waveform_driver
    port map (
      clk            => clk,
      rst_n          => rst_n,
      start_samples  => start_samples,
      min_samples    => min_samples,
      max_samples    => max_samples,
      step_samples   => step_samples,
      change_period  => change_period,
      waveform_sel   => wave_ctrl,
      enable_sig     => enable_sig,
      phase_inc      => phase_inc,
      waveform_sel_o => waveform_sel
    );

  -- Waveform generator
  GEN: entity work.waveform_gen
    generic map (
      SAMPLE_WIDTH    => SAMPLE_WIDTH_C,
      DEFAULT_WAVEFORM=> 0,
      SIGNED_OUTPUT   => true
    )
    port map (
      clk          => clk,
      rst_n        => rst_n,
      enable       => enable_sig,
      waveform_sel => waveform_sel,
      phase_inc    => phase_inc,
      sample_out   => sample_out
    );

  -- Clock generation
  clk_proc: process
  begin
    while now < 5 ms loop
      clk <= '0'; wait for 5 ns;
      clk <= '1'; wait for 5 ns;
    end loop;
    wait;
  end process;

  -- Stimulus
  stim_proc: process
  begin
    rst_n <= '0';
    wait for 50 ns;
    rst_n <= '1';

    wait for 1 ms; wave_ctrl <= 1; -- triangle
    wait for 1 ms; wave_ctrl <= 2; -- saw
    wait for 1 ms; wave_ctrl <= 3; -- square
    wait for 1 ms; wave_ctrl <= 0; -- sine

    wait for 1 ms;
    step_samples <= 2;     -- slower frequency sweep
    change_period <= 100;  -- change less often

    wait for 2 ms;
    wave_ctrl <= 1; -- triangle again

    wait;
  end process;
end architecture tb;
