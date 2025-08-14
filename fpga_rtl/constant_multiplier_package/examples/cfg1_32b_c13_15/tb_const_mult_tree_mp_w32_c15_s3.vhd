library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_const_mult_tree_mp_w32_c15_s3 is end entity;
architecture tb of tb_const_mult_tree_mp_w32_c15_s3 is
  signal clk : std_logic := 0;
  signal rst : std_logic := 1;
  signal din : std_logic_vector(31 downto 0) := (others => 0);
  signal dout : std_logic_vector(44 downto 0);
begin
  uut: entity work.const_mult_tree_mp_w32_c15_s3
    port map(clk=>clk, rst=>rst, din=>din, dout=>dout);
  clk_proc: process begin loop clk <= 0; wait for 5 ns; clk <= 1; wait for 5 ns; end loop; end process;
  stim: process
    variable i : integer;
    variable expected : unsigned(44 downto 0);
  begin
    rst <= 1; wait for 20 ns; rst <= 0;
    for i in 0 to 200 loop
      din <= std_logic_vector(to_unsigned(i mod (2**32), 32));
      expected := to_unsigned((i mod (2**32)) * 15, 45);
      wait for 10 ns;
      wait for 3 * 10 ns;
      if dout /= std_logic_vector(expected) then
        report "TB MISMATCH i=" & integerimage(i) & " expected=" & to_hstring(std_logic_vector(expected)) & " got=" & to_hstring(dout) severity error;
      end if;
    end loop;
    report "TB DONE" severity note;
    wait;
  end process;
end architecture;