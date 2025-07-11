library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package sin_128_sample_13_bit_pkg is
  constant WAVE_SAMPLES : integer := 128;
  type wave_array_t is array (0 to WAVE_SAMPLES - 1) of std_logic_vector(12 downto 0);
  function vec(x : integer) return std_logic_vector;
  constant WAVE_DATA : wave_array_t := (
    vec(   0), vec( 101), vec( 203), vec( 304), vec( 405), vec( 506), vec( 607), vec( 708), 
    vec( 809), vec( 910), vec(1011), vec(1111), vec(1211), vec(1311), vec(1411), vec(1511), 
    vec(1610), vec(1710), vec(1809), vec(1907), vec(2006), vec(2104), vec(2201), vec(2299), 
    vec(2396), vec(2493), vec(2589), vec(2685), vec(2780), vec(2875), vec(2970), vec(3064), 
    vec(3158), vec(3251), vec(3344), vec(3436), vec(3528), vec(3619), vec(3710), vec(3800), 
    vec(3889), vec(3978), vec(4066), vec(4154), vec(4241), vec(4327), vec(4413), vec(4498), 
    vec(4582), vec(4666), vec(4749), vec(4831), vec(4912), vec(4993), vec(5073), vec(5152), 
    vec(5231), vec(5308), vec(5385), vec(5461), vec(5536), vec(5610), vec(5683), vec(5756), 
    vec(5828), vec(5898), vec(5968), vec(6037), vec(6105), vec(6172), vec(6238), vec(6304), 
    vec(6368), vec(6431), vec(6493), vec(6554), vec(6615), vec(6674), vec(6732), vec(6789), 
    vec(6846), vec(6901), vec(6955), vec(7008), vec(7060), vec(7110), vec(7160), vec(7209), 
    vec(7256), vec(7303), vec(7348), vec(7392), vec(7435), vec(7477), vec(7518), vec(7558), 
    vec(7596), vec(7634), vec(7670), vec(7705), vec(7738), vec(7771), vec(7803), vec(7833), 
    vec(7862), vec(7890), vec(7916), vec(7942), vec(7966), vec(7989), vec(8011), vec(8031), 
    vec(8050), vec(8069), vec(8085), vec(8101), vec(8115), vec(8128), vec(8140), vec(8151), 
    vec(8160), vec(8168), vec(8175), vec(8181), vec(8185), vec(8188), vec(8190), vec(8191)
  );
end package;

package body sin_128_sample_13_bit_pkg is
  function vec(x : integer) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(x, 13));
  end function;
end package body sin_128_sample_13_bit_pkg;
