library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity const_mult_tree_cs_w32_c312_s4 is
  port (clk : in std_logic; rst : in std_logic;
        din : in std_logic_vector(31 downto 0);
        dout : out std_logic_vector(46 downto 0));
end entity;

architecture rtl of const_mult_tree_cs_w32_c312_s4 is
  signal din_u : unsigned(31 downto 0);
  signal leaf_0 : unsigned(46 downto 0);
  signal leaf_1 : unsigned(46 downto 0);
  signal leaf_2 : unsigned(46 downto 0);
  signal add_l1_0 : unsigned(46 downto 0);
  signal add_l1_0_r : unsigned(46 downto 0); -- registered at stage 0
  signal copy_l1_1 : unsigned(46 downto 0);
  signal copy_l1_1_r : unsigned(46 downto 0); -- registered at stage 0
  signal add_l2_0 : unsigned(46 downto 0);
  signal add_l2_0_r : unsigned(46 downto 0); -- registered at stage 3

begin
  din_u <= unsigned(din);

  -- combinational assignments
  leaf_0 <= (0 - shift_left(unsigned(din_u), 3));
  leaf_1 <= shift_left(unsigned(din_u), 6);
  leaf_2 <= shift_left(unsigned(din_u), 8);
  add_l1_0 <= leaf_0 + leaf_1;
  copy_l1_1 <= leaf_2;
  add_l2_0 <= add_l1_0_r + copy_l1_1_r;

  -- pipeline registers
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = 1 then
        add_l1_0_r <= (others => 0);
        copy_l1_1_r <= (others => 0);
        add_l2_0_r <= (others => 0);
      else
        add_l1_0_r <= add_l1_0;
        copy_l1_1_r <= copy_l1_1;
        add_l2_0_r <= add_l2_0;
      end if;
    end if;
  end process;

  dout <= std_logic_vector(add_l2_0_r);
end architecture;