library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;  -- for sin(), pi, etc.

entity tb_scale_bits_flex is
end entity;

architecture sim of tb_scale_bits_flex is

  -- Test configuration
  constant N           : positive := 5;
  constant M           : positive := 7;
  constant PIPELINE    : natural  := 2;
  constant CLK_PERIOD  : time := 10 ns;
  constant SAMPLES     : natural := 64; -- number of sine samples per period
  constant c_NUM_PERIODE     : natural := 5; -- number of sine samples per period

  -- Clock and reset
  signal clk        : std_logic := '0';
  signal rst        : std_logic := '1';

  -- DUT signals

  signal din_sin_s    : std_logic_vector(N-1 downto 0);
  signal din_sin_u    : std_logic_vector(N-1 downto 0);

  signal din_valid  : std_logic := '0';

  signal din1        : std_logic_vector(N-1 downto 0);
  signal dout1       : std_logic_vector(M-1 downto 0);
  signal dout1_valid : std_logic;

  signal din2        : std_logic_vector(N-1 downto 0);
  signal dout2       : std_logic_vector(M-1 downto 0);
  signal dout2_valid : std_logic;



  signal s_stop_condition  : boolean := false;

begin

  --------------------------------------------------------------------
  -- Clock generator
  --------------------------------------------------------------------
  clk <= not clk after CLK_PERIOD/2;

  --------------------------------------------------------------------
  -- DUT instantiation
  --------------------------------------------------------------------
  uut1: entity work.scale_bits_flex
    generic map (
      N           => N,
      M           => M,
      SIGNED_MODE => true,
      PIPELINE    => PIPELINE
    )
    port map (
      clk        => clk,
      rst        => rst,
      din        => din1,
      din_valid  => din_valid,
      dout       => dout1,
      dout_valid => dout1_valid
    );


  uut2: entity work.scale_bits_flex
    generic map (
      N           => N,
      M           => M,
      SIGNED_MODE => false,
      PIPELINE    => PIPELINE
    )
    port map (
      clk        => clk,
      rst        => rst,
      din        => din2,
      din_valid  => din_valid,
      dout       => dout2,
      dout_valid => dout2_valid
    );




    din1 <= din_sin_s;
    din2 <= din_sin_u;

  --------------------------------------------------------------------
  -- Reset process
  --------------------------------------------------------------------
  process
  begin
    rst <= '1';
    wait for 3*CLK_PERIOD;
    rst <= '0';
    wait;
  end process;

  --------------------------------------------------------------------
  -- Sine wave stimulus
  --------------------------------------------------------------------
  process
    variable i         : integer := 0;
    variable radians   : real;
    variable amplitude : real := 2.0**(N-1) - 1.0; -- max signed amplitude
    variable sample    : integer;
  begin
    wait until rst = '0';
    wait until rising_edge(clk);
    din_valid <= '1';

    for cycle in 0 to c_NUM_PERIODE loop  -- generate a few cycles


      for i in 0 to SAMPLES-1 loop
        radians := 2.0 * math_pi * real(i) / real(SAMPLES);
        sample  := integer(round(amplitude * sin(radians)));

        din_sin_s <= std_logic_vector(to_signed(sample, N));
        din_sin_u <= std_logic_vector(to_unsigned(sample + integer(amplitude), N));

        wait until rising_edge(clk);
      end loop;



    end loop;

    din_valid <= '0';
    wait for 10*CLK_PERIOD;

    report "Simulation finished." severity note;
    s_stop_condition <= true;


    --wait;
  end process;

end architecture sim;
