-- tb_fir_filter.vhd
-- VHDL-93 testbench (impure functions + textio) for the Phase 2 fir_filter
-- The file read format expected (coefs.txt):
--   First line: DATA_WIDTH=<n> COEF_WIDTH=<m>
--   Then N lines, each a coefficient (hex without 0x OR decimal signed)
-- Example:
--   DATA_WIDTH=13 COEF_WIDTH=13
--   000C
--   0007
--   FFF5
--   ...
--
-- Place coefs.txt in the working directory (or change COEF_FILE below).

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

package tb_file_io is
  type signed_dyn is array (natural range <>) of signed;
  impure function get_header(file_name : in string) return integer_vector;
  impure function count_taps(file_name : in string) return integer;
  impure function read_coefs(file_name : in string; cw : in integer) return signed_dyn;
end package;

package body tb_file_io is

  -- trim helper
  impure function trimtok(s : in string) return string is
    variable out : string(1 to s'length);
    variable k : integer := 0;
    variable ch : character;
  begin
    for i in s'range loop
      ch := s(i);
      if ch /= ' ' and ch /= X"0A" and ch /= X"0D" then
        k := k + 1;
        out(k) := ch;
      end if;
    end loop;
    if k = 0 then return (others => ' '); else return out(1 to k); end if;
  end function;

  -- parse token like "DATA_WIDTH=13"
  impure function parse_after_eq(tok : in string) return integer is
    variable pos : integer := 0;
    for i in tok'range loop
      if tok(i) = '=' then pos := i; exit; end if;
    end loop;
    if pos = 0 then return 0; end if;
    variable out : string(1 to tok'length - pos);
    variable k : integer := 0;
    for j in pos+1 to tok'length loop
      if tok(j) = ' ' then exit; end if;
      k := k + 1; out(k) := tok(j);
    end loop;
    variable v : integer;
    read(out(1 to k), v);
    return v;
  end function;

  impure function get_header(file_name : in string) return integer_vector is
    file f : text open read_mode is file_name;
    variable L : line;
    variable t1, t2 : string(1 to 256);
    variable s1, s2 : string(1 to 256);
    variable ret : integer_vector(1 to 2);
  begin
    if endfile(f) then
      assert false report "coefs file empty: " & file_name severity failure;
    end if;
    readline(f, L);
    read(L, t1);
    read(L, t2);
    s1 := trimtok(t1);
    s2 := trimtok(t2);
    ret(1) := parse_after_eq(s1);
    ret(2) := parse_after_eq(s2);
    file_close(f);
    return ret;
  end function;

  impure function count_taps(file_name : in string) return integer is
    file f : text open read_mode is file_name;
    variable L : line;
    variable cnt : integer := 0;
    variable tok : string(1 to 256);
  begin
    if endfile(f) then
      assert false report "coefs file empty: " & file_name severity failure;
    end if;
    readline(f, L); -- header
    while not endfile(f) loop
      readline(f, L);
      read(L, tok);
      cnt := cnt + 1;
    end loop;
    file_close(f);
    return cnt;
  end function;

  -- convert token (hex or decimal) to signed of cw bits
  impure function token_to_signed(tok : in string; cw : in integer) return signed is
    variable t : string(1 to tok'length);
    variable len : integer := 0;
    variable ch : character;
    variable acc_u : unsigned(127 downto 0) := (others => '0');
    variable nib : integer;
    variable outv : signed(cw-1 downto 0) := (others => '0');
  begin
    for i in tok'range loop
      ch := tok(i);
      if ch /= ' ' and ch /= X"0A" and ch /= X"0D" then
        len := len + 1; t(len) := ch;
      end if;
    end loop;
    if len = 0 then
      return (others => '0');
    end if;

    if (t(1) = '-') or (t(1) >= '0' and t(1) <= '9') then
      variable neg : boolean := false;
      variable start : integer := 1;
      variable dec : integer := 0;
      if t(1) = '-' then neg := true; start := 2; end if;
      for i in start to len loop
        dec := dec * 10 + (character'pos(t(i)) - character'pos('0'));
      end loop;
      if neg then dec := -dec; end if;
      if dec < -(2**(cw-1)) or dec > (2**(cw-1)-1) then
        assert false report "Decimal coef out of range for COEF_WIDTH=" & integer'image(cw) severity failure;
      end if;
      outv := to_signed(dec, cw);
      return outv;
    else
      acc_u := (others => '0');
      for i in 1 to len loop
        ch := t(i);
        if ch >= '0' and ch <= '9' then
          nib := character'pos(ch) - character'pos('0');
        elsif ch >= 'A' and ch <= 'F' then
          nib := 10 + character'pos(ch) - character'pos('A');
        elsif ch >= 'a' and ch <= 'f' then
          nib := 10 + character'pos(ch) - character'pos('a');
        else
          nib := 0;
        end if;
        acc_u := shift_left(acc_u, 4) + to_unsigned(nib, acc_u'length);
      end loop;
      if len*4 > cw then
        assert false report "Hex coef too wide for COEF_WIDTH=" & integer'image(cw) severity failure;
      end if;
      variable lowbits : unsigned(cw-1 downto 0);
      lowbits := acc_u(cw-1 downto 0);
      outv := signed(lowbits);
      return outv;
    end if;
  end function;

  impure function read_coefs(file_name : in string; cw : in integer) return signed_dyn is
    variable n : integer := count_taps(file_name);
    variable ret : signed_dyn(0 to n-1);
    file f : text open read_mode is file_name;
    variable L : line;
    variable tok : string(1 to 256);
    variable idx : integer := 0;
  begin
    if endfile(f) then
      assert false report "coefs file empty" severity failure;
    end if;
    readline(f, L); -- header
    while not endfile(f) loop
      readline(f, L);
      read(L, tok);
      ret(idx) := token_to_signed(tok, cw);
      idx := idx + 1;
    end loop;
    file_close(f);
    return ret;
  end function;

end package body tb_file_io;

-- Testbench entity
entity tb_fir_filter is
end entity;

architecture sim of tb_fir_filter is
  constant COEF_FILE : string := "coefs.txt";

  -- read file at elaboration time
  constant hdr : integer_vector := get_header(COEF_FILE);
  constant FILE_DATA_WIDTH : integer := hdr(1);
  constant FILE_COEF_WIDTH : integer := hdr(2);
  constant FILE_N_TAPS : integer := count_taps(COEF_FILE);
  constant COEFS : signed_dyn(0 to FILE_N_TAPS-1) := read_coefs(COEF_FILE, FILE_COEF_WIDTH);

  -- TB settings
  constant SEL_OUT_TB : std_logic_vector(2 downto 0) := "111";
  constant SAT_MODE_SCALED_TB : boolean := true;
  constant SAT_MODE_SCALED_EACH_TB : boolean := true;
  constant PIPELINED_TB : boolean := true;

  constant CLK_PERIOD : time := 20 ns;
  constant SINE_FREQ_HZ : real := 1000.0;
  constant FS_HZ : real := 48000.0;

  -- DUT signals sized with file-derived constants
  signal clk : std_logic := '0';
  signal rst_n : std_logic := '0';
  signal data_in_valid : std_logic := '0';
  signal data_in : signed(FILE_DATA_WIDTH-1 downto 0) := (others => '0');

  -- concrete coef signal type
  type coef_sig_t is array (0 to FILE_N_TAPS-1) of signed(FILE_COEF_WIDTH-1 downto 0);
  signal coef_sig : coef_sig_t;

  signal data_out_full   : signed((FILE_DATA_WIDTH + FILE_COEF_WIDTH + integer(ceil(log2(real(FILE_N_TAPS)))))-1 downto 0);
  signal data_out_scaled : signed(FILE_DATA_WIDTH-1 downto 0);
  signal data_out_scaled_each_tap : signed(FILE_DATA_WIDTH-1 downto 0);
  signal valid_out : std_logic;

begin
  -- copy coefficients into the concrete port signal once at start
  init_coefs: process
  begin
    for i in 0 to FILE_N_TAPS-1 loop
      coef_sig(i) <= COEFS(i);
    end loop;
    wait;
  end process;

  -- instantiate FIR with generics determined from file
  dut: entity work.fir_filter
    generic map (
      DATA_WIDTH => FILE_DATA_WIDTH,
      COEF_WIDTH => FILE_COEF_WIDTH,
      N_TAPS     => FILE_N_TAPS,
      PIPELINED  => PIPELINED_TB,
      SEL_OUT    => SEL_OUT_TB,
      SAT_MODE_SCALED => SAT_MODE_SCALED_TB,
      SAT_MODE_SCALED_EACH => SAT_MODE_SCALED_EACH_TB
    )
    port map (
      clk => clk,
      rst_n => rst_n,
      data_in_valid => data_in_valid,
      data_in => data_in,
      coefs => coef_sig,
      data_out_full => data_out_full,
      data_out_scaled => data_out_scaled,
      data_out_scaled_each_tap => data_out_scaled_each_tap,
      valid_out => valid_out
    );

  -- clock
  clk_proc: process
  begin
    while true loop
      clk <= '0'; wait for CLK_PERIOD/2;
      clk <= '1'; wait for CLK_PERIOD/2;
    end loop;
  end process;

  -- stimulus: reset then sinewave, print when valid_out asserted
  stim: process
    variable t : real := 0.0;
    variable amplitude : real := 2.0**(FILE_DATA_WIDTH-1) - 1.0;
    variable sample_real : real;
    variable sample_int : integer;
  begin
    rst_n <= '0';
    data_in_valid <= '0';
    wait for 100 ns;
    rst_n <= '1';
    wait for 100 ns;

    while now < 5 ms loop
      sample_real := sin(2.0 * math_pi * SINE_FREQ_HZ * t) * amplitude;
      sample_int := integer(round(sample_real));
      data_in <= to_signed(sample_int, FILE_DATA_WIDTH);
      data_in_valid <= '1';
      t := t + 1.0 / FS_HZ;
      wait for CLK_PERIOD;
      if valid_out = '1' then
        report "time=" & time'image(now) &
               " full=" & integer'image(to_integer(data_out_full)) &
               " scaled=" & integer'image(to_integer(data_out_scaled)) &
               " scaled_each=" & integer'image(to_integer(data_out_scaled_each_tap));
      end if;
    end loop;

    data_in_valid <= '0';
    wait for 100 * CLK_PERIOD;
    assert false report "End of TB" severity note;
    wait;
  end process;

end architecture sim;
