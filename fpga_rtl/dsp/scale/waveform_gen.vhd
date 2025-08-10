-- waveform_gen.vhd
-- Simulation-only waveform generator (sine, triangle, saw, square)
-- Advances phase by a runtime-supplied increment when enable = '1'.
-- Outputs are signed or unsigned (std_logic_vector).

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity waveform_gen is
  generic (
    SAMPLE_WIDTH   : integer := 12;
    DEFAULT_WAVEFORM : integer := 0;
    SIGNED_OUTPUT  : boolean := false
  );
  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;             -- active low reset
    enable        : in  std_logic := '1';      -- sample update enable
    waveform_sel  : in  integer := DEFAULT_WAVEFORM; -- runtime waveform select
    phase_inc     : in  real;                  -- phase increment (radians per sample)
    sample_out    : out std_logic_vector(SAMPLE_WIDTH-1 downto 0)
  );
end entity waveform_gen;

architecture behavioral of waveform_gen is
  constant TWO_PI : real := 2.0 * 3.14159265358979323846;
  signal phase    : real := 0.0;

  constant MAX_UNSIGNED_INT : integer := 2**SAMPLE_WIDTH - 1;
  constant MAX_SIGNED_INT   : integer := 2**(SAMPLE_WIDTH-1) - 1;
  constant MIN_SIGNED_INT   : integer := -2**(SAMPLE_WIDTH-1);
begin

  process(clk)
    variable val_real     : real;
    variable scaled_real  : real;
    variable scaled_int   : integer;
    variable phase_next   : real;
    variable wf           : integer;
  begin
    if rising_edge(clk) then
      if rst_n = '0' then
        phase <= 0.0;
        sample_out <= (others => '0');
      else
        if enable = '1' then
          -- waveform selection check
          if waveform_sel < 0 or waveform_sel > 3 then
            wf := DEFAULT_WAVEFORM;
          else
            wf := waveform_sel;
          end if;

          -- update phase
          phase_next := phase + phase_inc;
          if phase_next >= TWO_PI then
            phase_next := phase_next - TWO_PI * floor(phase_next / TWO_PI);
          elsif phase_next < 0.0 then
            phase_next := phase_next + TWO_PI * (1.0 + floor(-phase_next / TWO_PI));
          end if;
          phase <= phase_next;

          -- compute waveform in [-1, +1]
          case wf is
            when 0 =>  -- SINE
              val_real := sin(phase);
            when 1 =>  -- TRIANGLE
              if phase < 3.14159265358979323846 then
                val_real := -1.0 + (2.0 * phase / 3.14159265358979323846);
              else
                val_real := 3.0 - (2.0 * phase / 3.14159265358979323846);
              end if;
            when 2 =>  -- SAW
              val_real := -1.0 + (phase / 3.14159265358979323846);
            when 3 =>  -- SQUARE
              if sin(phase) >= 0.0 then
                val_real := 1.0;
              else
                val_real := -1.0;
              end if;
            when others =>
              val_real := 0.0;
          end case;

          -- scale
          if SIGNED_OUTPUT then
            scaled_real := val_real * real(MAX_SIGNED_INT);
            if scaled_real > real(MAX_SIGNED_INT) then
              scaled_real := real(MAX_SIGNED_INT);
            elsif scaled_real < real(MIN_SIGNED_INT) then
              scaled_real := real(MIN_SIGNED_INT);
            end if;
            scaled_int := integer(round(scaled_real));
            sample_out <= std_logic_vector(to_signed(scaled_int, SAMPLE_WIDTH));
          else
            scaled_real := (val_real + 1.0) / 2.0 * real(MAX_UNSIGNED_INT);
            if scaled_real < 0.0 then
              scaled_real := 0.0;
            elsif scaled_real > real(MAX_UNSIGNED_INT) then
              scaled_real := real(MAX_UNSIGNED_INT);
            end if;
            scaled_int := integer(round(scaled_real));
            sample_out <= std_logic_vector(to_unsigned(scaled_int, SAMPLE_WIDTH));
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture behavioral;
