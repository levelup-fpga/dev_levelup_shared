library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_scale_bits_flex is
end entity;

architecture sim of tb_scale_bits_flex is

  --------------------------------------------------------------------
  -- Test constants
  --------------------------------------------------------------------
  constant N           : positive := 8;
  constant M           : positive := 12;
  constant PIPELINE    : positive := 3;
  constant USE_SINE    : boolean  := true;  -- true = sine wave, false = ramp

  --------------------------------------------------------------------
  -- Clock and reset
  --------------------------------------------------------------------
  signal clk       : std_logic := '0';
  signal rst       : std_logic := '1';

  --------------------------------------------------------------------
  -- Input data sources
  --------------------------------------------------------------------
  signal din_sin_signed     : std_logic_vector(N-1 downto 0) := (others => '0');
  signal din_sin_unsigned   : std_logic_vector(N-1 downto 0) := (others => '0');

  signal din_ramp_signed    : std_logic_vector(N-1 downto 0) := (others => '0');
  signal din_ramp_unsigned  : std_logic_vector(N-1 downto 0) := (others => '0');

  --------------------------------------------------------------------
  -- Selected data to drive DUTs
  --------------------------------------------------------------------
  signal din_signed         : std_logic_vector(N-1 downto 0) := (others => '0');
  signal din_unsigned       : std_logic_vector(N-1 downto 0) := (others => '0');
  signal din_valid          : std_logic := '0';

  --------------------------------------------------------------------
  -- Outputs
  --------------------------------------------------------------------
  signal dout_signed    : std_logic_vector(M-1 downto 0);
  signal dout_unsigned  : std_logic_vector(M-1 downto 0);
  signal dout_valid_s   : std_logic;
  signal dout_valid_u   : std_logic;

  --------------------------------------------------------------------
  -- Simulation control
  --------------------------------------------------------------------
  constant CLK_PERIOD : time := 10 ns;
  signal sample_count  : integer := 0;

begin

  --------------------------------------------------------------------
  -- Clock generation
  --------------------------------------------------------------------
  clk_process : process
  begin
    clk <= '0';
    wait for CLK_PERIOD / 2;
    clk <= '1';
    wait for CLK_PERIOD / 2;
  end process;

  --------------------------------------------------------------------
  -- Reset release
  --------------------------------------------------------------------
  process
  begin
    rst <= '1';
    wait for 50 ns;
    rst <= '0';
    wait;
  end process;

  --------------------------------------------------------------------
  -- Sine wave generator
  --------------------------------------------------------------------
  sine_proc : process(clk)
    variable rad      : real;
    variable sine_val : real;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        din_sin_signed   <= (others => '0');
        din_sin_unsigned <= (others => '0');
      else
        rad      := 2.0 * math_pi * real(sample_count) / 64.0; -- 64 samples/period
        sine_val := sin(rad);
        -- Signed sine wave
        din_sin_signed   <= std_logic_vector(to_signed(
                              integer(sine_val * (2.0**(N-1) - 1)), N));
        -- Unsigned sine wave (offset)
        din_sin_unsigned <= std_logic_vector(to_unsigned(
                              integer((sine_val * (2.0**(N-1) - 1)) + 2.0**(N-1)), N));
      end if;
    end if;
  end process;

  --------------------------------------------------------------------
  -- Ramp generator
  --------------------------------------------------------------------
  ramp_proc : process(clk)
    variable ramp_val : integer;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        din_ramp_signed   <= (others => '0');
        din_ramp_unsigned <= (others => '0');
      else
        ramp_val := sample_count mod (2**N);
        -- Signed ramp
        din_ramp_signed   <= std_logic_vector(to_signed(ramp_val - 2**(N-1), N));
        -- Unsigned ramp
        din_ramp_unsigned <= std_logic_vector(to_unsigned(ramp_val, N));
      end if;
    end if;
  end process;

  --------------------------------------------------------------------
  -- Input selection and valid signal
  --------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        sample_count <= 0;
        din_valid    <= '0';
        din_signed   <= (others => '0');
        din_unsigned <= (others => '0');
      else
        din_valid <= '1';
        if USE_SINE then
          din_signed   <= din_sin_signed;
          din_unsigned <= din_sin_unsigned;
        else
          din_signed   <= din_ramp_signed;
          din_unsigned <= din_ramp_unsigned;
        end if;
        sample_count <= sample_count + 1;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------
  -- Instance 1: Signed mode
  --------------------------------------------------------------------
  uut_signed : entity work.scale_bits_flex
    generic map (
      N           => N,
      M           => M,
      SIGNED_MODE => true,
      PIPELINE    => PIPELINE
    )
    port map (
      clk        => clk,
      rst        => rst,
      din        => din_signed,
      din_valid  => din_valid,
      dout       => dout_signed,
      dout_valid => dout_valid_s
    );

  --------------------------------------------------------------------
  -- Instance 2: Unsigned mode
  --------------------------------------------------------------------
  uut_unsigned : entity work.scale_bits_flex
    generic map (
      N           => N,
      M           => M,
      SIGNED_MODE => false,
      PIPELINE    => PIPELINE
    )
    port map (
      clk        => clk,
      rst        => rst,
      din        => din_unsigned,
      din_valid  => din_valid,
      dout       => dout_unsigned,
      dout_valid => dout_valid_u
    );

  --------------------------------------------------------------------
  -- Simulation stop
  --------------------------------------------------------------------
  end_sim : process
  begin
    wait for 5 ms;
    assert false report "Simulation finished" severity failure;
  end process;

end architecture;
