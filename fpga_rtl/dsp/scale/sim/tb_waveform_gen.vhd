-- tb_waveform_gen.vhd
-- Testbench: pulses enable at different rates to simulate external sample timing.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_waveform_gen is
end entity;

architecture tb of tb_waveform_gen is
  constant SAMPLE_WIDTH_C : integer := 12;

  signal clk       : std_logic := '0';
  signal rst_n     : std_logic := '0';
  signal enable    : std_logic := '0';
  signal wfs       : integer := 0;
  signal sample_out: std_logic_vector(SAMPLE_WIDTH_C-1 downto 0);

  -- 10 ns clock
  constant CLK_PERIOD : time := 10 ns;

  -- Counter to generate enable pulses
  signal cnt : integer := 0;
begin

  UUT: entity work.waveform_gen
    generic map (
      SAMPLE_WIDTH       => SAMPLE_WIDTH_C,
      SAMPLES_PER_PERIOD => 32,   -- 32 samples for one full cycle
      DEFAULT_WAVEFORM   => 0,
      SIGNED_OUTPUT      => true
    )
    port map (
      clk          => clk,
      rst_n        => rst_n,
      enable       => enable,
      waveform_sel => wfs,
      sample_out   => sample_out
    );

  -- Clock generation
  clk_proc : process
  begin
    while now < 5 ms loop
      clk <= '0'; wait for CLK_PERIOD/2;
      clk <= '1'; wait for CLK_PERIOD/2;
    end loop;
    wait;
  end process;

  -- Enable pulse generation + waveform change
  stim_proc : process
  begin
    rst_n <= '0';
    wait for 50 ns;
    rst_n <= '1';

    while now < 5 ms loop
      wait until rising_edge(clk);

      -- Generate enable pulse every 4 clock cycles
      if cnt = 3 then
        enable <= '1';
        cnt <= 0;
      else
        enable <= '0';
        cnt <= cnt + 1;
      end if;

      -- Change waveform every 200 enable pulses
      if (now / CLK_PERIOD) mod (200*4) = 0 then
        wfs <= (wfs + 1) mod 4;
      end if;
    end loop;
    wait;
  end process;
end architecture tb;
