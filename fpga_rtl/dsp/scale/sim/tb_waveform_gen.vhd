-- tb_waveform_gen.vhd
-- Simple testbench: changes waveform and frequency at runtime for visual inspection in QuestSim.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_waveform_gen is
end entity;

architecture tb of tb_waveform_gen is
  constant SAMPLE_WIDTH_C : integer := 12;
  constant SAMPLE_RATE_C  : real := 48000.0;

  signal clk       : std_logic := '0';
  signal rst_n     : std_logic := '0';
  signal enable    : std_logic := '1';
  signal wfs       : integer := 0;
  signal freq_hz   : real := 1000.0;
  signal sample_out: std_logic_vector(SAMPLE_WIDTH_C-1 downto 0);

  constant CLK_PERIOD_NS : time := real(1.0e9 / SAMPLE_RATE_C) * 1 ns;
begin

  UUT: entity work.waveform_gen
    generic map (
      SAMPLE_WIDTH    => SAMPLE_WIDTH_C,
      SAMPLE_RATE     => SAMPLE_RATE_C,
      DEFAULT_WAVEFORM=> 0,
      SIGNED_OUTPUT   => true  -- set false for unsigned mode
    )
    port map (
      clk          => clk,
      rst_n        => rst_n,
      enable       => enable,
      waveform_sel => wfs,
      freq_hz      => freq_hz,
      sample_out   => sample_out
    );

  -- Clock generation
  clk_proc : process
  begin
    while now < 50 ms loop
      clk <= '0'; wait for CLK_PERIOD_NS/2;
      clk <= '1'; wait for CLK_PERIOD_NS/2;
    end loop;
    wait;
  end process;

  -- Stimulus: cycle waveform and frequency every few ms
  stim_proc : process
    variable sample_count : integer := 0;
  begin
    rst_n <= '0';
    wait for 2*CLK_PERIOD_NS;
    rst_n <= '1';

    while now < 50 ms loop
      wait until rising_edge(clk);
      sample_count := sample_count + 1;

      -- Change waveform every 480 samples (~10 ms at 48 kHz)
      if sample_count mod 480 = 0 then
        wfs <= (wfs + 1) mod 4;
      end if;

      -- Change frequency every 240 samples (~5 ms)
      if sample_count mod 240 = 0 then
        if freq_hz < 5000.0 then
          freq_hz <= freq_hz + 1000.0;
        else
          freq_hz <= 500.0;  -- reset to low
        end if;
      end if;
    end loop;
    wait;
  end process;
end architecture tb;
