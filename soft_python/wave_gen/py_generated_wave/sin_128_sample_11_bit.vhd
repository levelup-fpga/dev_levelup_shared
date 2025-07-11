library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package sin_128_sample_11_bit_pkg is
  constant WAVE_SAMPLES : integer := 128;
  type wave_array_t is array (0 to WAVE_SAMPLES - 1) of std_logic_vector(10 downto 0);
  function vec(x : integer) return std_logic_vector;
  constant WAVE_DATA : wave_array_t := (
    vec(   0), vec(  25), vec(  51), vec(  76), vec( 101), vec( 127), vec( 152), vec( 177), 
    vec( 202), vec( 227), vec( 253), vec( 278), vec( 303), vec( 328), vec( 353), vec( 378), 
    vec( 402), vec( 427), vec( 452), vec( 477), vec( 501), vec( 526), vec( 550), vec( 574), 
    vec( 599), vec( 623), vec( 647), vec( 671), vec( 695), vec( 719), vec( 742), vec( 766), 
    vec( 789), vec( 812), vec( 836), vec( 859), vec( 882), vec( 904), vec( 927), vec( 950), 
    vec( 972), vec( 994), vec(1016), vec(1038), vec(1060), vec(1081), vec(1103), vec(1124), 
    vec(1145), vec(1166), vec(1187), vec(1207), vec(1228), vec(1248), vec(1268), vec(1288), 
    vec(1307), vec(1327), vec(1346), vec(1365), vec(1383), vec(1402), vec(1420), vec(1438), 
    vec(1456), vec(1474), vec(1492), vec(1509), vec(1526), vec(1542), vec(1559), vec(1575), 
    vec(1591), vec(1607), vec(1623), vec(1638), vec(1653), vec(1668), vec(1682), vec(1697), 
    vec(1711), vec(1725), vec(1738), vec(1751), vec(1764), vec(1777), vec(1789), vec(1802), 
    vec(1813), vec(1825), vec(1836), vec(1847), vec(1858), vec(1869), vec(1879), vec(1889), 
    vec(1898), vec(1908), vec(1917), vec(1925), vec(1934), vec(1942), vec(1950), vec(1957), 
    vec(1965), vec(1972), vec(1978), vec(1985), vec(1991), vec(1996), vec(2002), vec(2007), 
    vec(2012), vec(2016), vec(2021), vec(2024), vec(2028), vec(2031), vec(2034), vec(2037), 
    vec(2039), vec(2041), vec(2043), vec(2044), vec(2046), vec(2046), vec(2047), vec(2047)
  );
end package;

package body sin_128_sample_11_bit_pkg is
  function vec(x : integer) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(x, 11));
  end function;
end package body sin_128_sample_11_bit_pkg;
