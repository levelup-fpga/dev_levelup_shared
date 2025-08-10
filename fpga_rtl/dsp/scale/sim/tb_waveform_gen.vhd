-- tb_waveform_gen.vhd
-- Testbench instantiating waveform_driver and waveform_gen for simulation.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_waveform_gen is
end entity;

architecture tb of tb_waveform_gen is
  constant SAMPLE_WIDTH_C : integer := 12;

  signal clk          : std_logic := '0';
  signal rst_n        : std_logic := '0';
  signal sample_out   : std_logic_vector(SAMPLE_WIDTH_C-1 downto 0);

  -- Control signals for waveform_driver
  signal waveform_sel  : integer := 0;
  signal start_samples : integer := 32;
  signal min_samples   : integer := 16;
  signal max_samples   : integer := 64;
  signal step_samples  : integer := -4;
  signal change_period : integer := 50;

begin
  -- Instantiate waveform_driver
  DUT: entity work.waveform_driver
    generic map (
      SAMPLE_WIDTH     => SAMPLE_WIDTH_C,
      DEFAULT_WAVEFORM => 0,
      SIGNED_OUTPUT    => true
    )
    port map (
      clk           => clk,
      rst_n         => rst_n,
      waveform_sel  => waveform_sel,
      start_samples => start_samples,
      min_samples   => min_samples,
      max_samples   => max_samples,
      step_samples  => step_samples,
      change_period => change_period,
      sample_out    => sample_out
    );

  -- Clock process (100 MHz)
  clk_proc : process
  begin
    while now < 5 ms loop
      clk <= '0'; wait for 5 ns;
      clk <= '1'; wait for 5 ns;
    end loop;
    wait;
  end process;

  -- Stimulus
  stim_proc : process
  begin
    -- Reset
    rst_n <= '0';
    wait for 50 ns;
    rst_n <= '1';

    -- Change waveform every 1 ms
    wait for 1 ms; waveform_sel <= 1; -- Triangle
    wait for 1 ms; waveform_sel <= 2; -- Saw
    wait for 1 ms; waveform_sel <= 3; -- Square
    wait for 1 ms; waveform_sel <= 0; -- Sine

    wait for 1 ms;
    -- Modify sweep settings mid-sim
    step_samples <= 2;    -- increase samples per period (lower frequency)
    change_period <= 100; -- slower sweep

    wait for 2 ms;
    waveform_sel <= 1; -- Triangle again

    wait;
  end process;
end architecture tb;
