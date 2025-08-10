library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;  -- for sin(), pi, etc.

entity tb_scale_bits_flex is
end entity;

architecture sim of tb_scale_bits_flex is

  -- Test configuration

  constant c_SIGNED_MODE1 : boolean  := true;
  constant c_N1           : positive := 8;
  constant c_M1           : positive := 6;

  constant c_SIGNED_MODE2 : boolean  := true;
  constant c_N2           : positive := 19;
  constant c_M2           : positive := 7;



  constant PIPELINE    : natural  := 2;


  constant CLK_PERIOD  : time := 10 ns;
  constant SAMPLES     : natural := 64; -- number of sine samples per period
  constant c_NUM_PERIODE     : natural := 5; -- number of sine samples per period

  -- Clock and reset
  signal clk        : std_logic := '0';
  signal rst        : std_logic := '1';

  -- DUT signals



  signal din1_valid  : std_logic := '0';
  signal din1_sin_s  : std_logic_vector(c_N1-1 downto 0);
  signal din1_sin_u  : std_logic_vector(c_N1-1 downto 0);
  signal din1        : std_logic_vector(c_N1-1 downto 0);
  signal dout1       : std_logic_vector(c_M1-1 downto 0);
  signal dout1_valid : std_logic;

  signal din2_valid  : std_logic := '0';
  signal din2_sin_s  : std_logic_vector(c_N2-1 downto 0);
  signal din2_sin_u  : std_logic_vector(c_N2-1 downto 0);
  signal din2        : std_logic_vector(c_N2-1 downto 0);
  signal dout2       : std_logic_vector(c_M2-1 downto 0);
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
      N           => c_N1,
      M           => c_M1,
      SIGNED_MODE => c_SIGNED_MODE1,
      PIPELINE    => PIPELINE
    )
    port map (
      clk        => clk,
      rst        => rst,
      din        => din1,
      din_valid  => din1_valid,
      dout       => dout1,
      dout_valid => dout1_valid
    );



  din1 <= din1_sin_s;

  uut2: entity work.scale_bits_flex
    generic map (
      N           => c_N2,
      M           => c_M2,
      SIGNED_MODE => c_SIGNED_MODE2,
      PIPELINE    => PIPELINE
    )
    port map (
      clk        => clk,
      rst        => rst,
      din        => din2,
      din_valid  => din2_valid,
      dout       => dout2,
      dout_valid => dout2_valid
    );

    din2 <= din2_sin_s;




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

    variable v_amplitude1 : real := 2.0**(c_N1-1) - 1.0; -- max signed amplitude
    variable v_amplitude2 : real := 2.0**(c_N2-1) - 1.0; -- max signed amplitude
    variable v_sample1    : integer;
    variable v_sample2    : integer;

  begin
    wait until rst = '0';
    wait until rising_edge(clk);
    din1_valid <= '1';
    din2_valid <= '1';

    for cycle in 0 to c_NUM_PERIODE loop  -- generate a few cycles


      for i in 0 to SAMPLES-1 loop
        radians := 2.0 * math_pi * real(i) / real(SAMPLES);
        v_sample1  := integer(round(v_amplitude1 * sin(radians)));
        v_sample2  := integer(round(v_amplitude2 * sin(radians)));

        din1_sin_s <= std_logic_vector(to_signed(v_sample1, c_N1));
        din1_sin_u <= std_logic_vector(to_unsigned(v_sample1 + integer(v_amplitude1), c_N1));

        din2_sin_s <= std_logic_vector(to_signed(v_sample2, c_N2));
        din2_sin_u <= std_logic_vector(to_unsigned(v_sample2 + integer(v_amplitude2), c_N2));

        wait until rising_edge(clk);
      end loop;



    end loop;

    din1_valid <= '1';
    din2_valid <= '1';
    wait for 10*CLK_PERIOD;

    report "Simulation finished." severity note;
    s_stop_condition <= true;


    --wait;
  end process;

end architecture sim;
