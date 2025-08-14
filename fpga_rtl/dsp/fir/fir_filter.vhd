-- fir_filter.vhd
-- VHDL-93 synthesizable FIR filter (Phase 2)
-- Outputs are synthesized only when enabled by SEL_OUT bits.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter is
  generic (
    DATA_WIDTH              : integer := 16;
    COEF_WIDTH              : integer := 16;
    N_TAPS                  : integer := 8;
    PIPELINED               : boolean := true;

    -- Phase 2 controls:
    SEL_OUT                 : std_logic_vector(2 downto 0) := "111";
      -- SEL_OUT(0) -> data_out_full
      -- SEL_OUT(1) -> data_out_scaled
      -- SEL_OUT(2) -> data_out_scaled_each_tap

    SAT_MODE_SCALED         : boolean := true;  -- true -> saturate for data_out_scaled, false -> truncate
    SAT_MODE_SCALED_EACH    : boolean := true   -- true -> saturate for data_out_scaled_each_tap, false -> truncate
  );

  -- declare concrete constrained array types using generics (allowed in VHDL-93 entity declarative region)
  type coef_array_t is array (0 to N_TAPS-1) of signed(COEF_WIDTH-1 downto 0);

  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    data_in_valid : in  std_logic;
    data_in   : in  signed(DATA_WIDTH-1 downto 0);
    coefs     : in  coef_array_t;

    data_out_full           : out signed(DATA_WIDTH + COEF_WIDTH + integer(ceil(log2(real(N_TAPS)))) - 1 downto 0);
    data_out_scaled         : out signed(DATA_WIDTH-1 downto 0);
    data_out_scaled_each_tap: out signed(DATA_WIDTH-1 downto 0);
    valid_out               : out std_logic
  );
end entity fir_filter;

architecture rtl of fir_filter is
  -- derived widths
  constant PROD_WIDTH : integer := DATA_WIDTH + COEF_WIDTH;
  constant ACC_EXTRA  : integer := (N_TAPS > 1) ? integer(ceil(log2(real(N_TAPS)))) : 0;
  constant ACC_WIDTH  : integer := PROD_WIDTH + ACC_EXTRA;

  -- local types
  type tap_array_t      is array (0 to N_TAPS-1) of signed(DATA_WIDTH-1 downto 0);
  type prod_array_t     is array (0 to N_TAPS-1) of signed(PROD_WIDTH-1 downto 0);
  type prod_scaled_t    is array (0 to N_TAPS-1) of signed(DATA_WIDTH-1 downto 0);
  type acc_stage_array  is array (0 to N_TAPS)   of signed(ACC_WIDTH-1 downto 0);

  -- signals
  signal taps            : tap_array_t := (others => (others => '0'));
  signal prods           : prod_array_t := (others => (others => '0'));
  signal prods_scaled    : prod_scaled_t := (others => (others => '0'));

  signal acc_stage       : acc_stage_array := (others => (others => '0'));
  signal acc_final       : signed(ACC_WIDTH-1 downto 0) := (others => '0');

  signal acc_stage_each  : acc_stage_array := (others => (others => '0'));
  signal acc_final_each  : signed(ACC_WIDTH-1 downto 0) := (others => '0');

  -- valid pipeline
  constant VALID_LAT : integer := N_TAPS + 1 + ( (N_TAPS>1) ? integer(ceil(log2(real(N_TAPS)))) : 0 );
  signal valid_pipe    : std_logic_vector(0 to VALID_LAT-1) := (others => '0');

  -- saturation limits for DATA_WIDTH
  constant MAX_DATA : signed(DATA_WIDTH-1 downto 0) := to_signed(2**(DATA_WIDTH-1)-1, DATA_WIDTH);
  constant MIN_DATA : signed(DATA_WIDTH-1 downto 0) := to_signed(- (2**(DATA_WIDTH-1)), DATA_WIDTH);

  -- helper function: saturate value 'inp' of arbitrary width into signed of w bits
  function sat_to_width(inp : signed; w : integer) return signed is
    variable outv : signed(w-1 downto 0);
    variable maxv : signed(inp'length-1 downto 0) := resize(to_signed(2**(w-1)-1, w), inp'length);
    variable minv : signed(inp'length-1 downto 0) := resize(to_signed(- (2**(w-1)), w), inp'length);
  begin
    if inp > maxv then
      outv := to_signed(2**(w-1)-1, w);
    elsif inp < minv then
      outv := to_signed(- (2**(w-1)), w);
    else
      outv := resize(inp, w);
    end if;
    return outv;
  end function sat_to_width;

begin
  ----------------------------------------------------------------------------
  -- Input shift registers (one register per tap) - synthesizable
  ----------------------------------------------------------------------------
  gen_taps: for i in 0 to N_TAPS-1 generate
    signal tap_reg : signed(DATA_WIDTH-1 downto 0);
  begin
    process(clk, rst_n)
    begin
      if rst_n = '0' then
        tap_reg <= (others => '0');
      elsif rising_edge(clk) then
        if data_in_valid = '1' then
          if i = 0 then
            tap_reg <= data_in;
          else
            tap_reg <= taps(i-1);
          end if;
        end if;
      end if;
    end process;
    taps(i) <= tap_reg;
  end generate;

  ----------------------------------------------------------------------------
  -- Valid pipeline (simple shift register)
  ----------------------------------------------------------------------------
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      valid_pipe <= (others => '0');
    elsif rising_edge(clk) then
      valid_pipe(0) <= data_in_valid;
      for k in 1 to VALID_LAT-1 loop
        valid_pipe(k) <= valid_pipe(k-1);
      end loop;
    end if;
  end process;
  valid_out <= valid_pipe(VALID_LAT-1);

  ----------------------------------------------------------------------------
  -- Multipliers: produce full products (registered)
  ----------------------------------------------------------------------------
  gen_mult: for i in 0 to N_TAPS-1 generate
  begin
    proc_mult: process(clk, rst_n)
    begin
      if rst_n = '0' then
        prods(i) <= (others => '0');
      elsif rising_edge(clk) then
        if data_in_valid = '1' then
          prods(i) <= resize(taps(i), PROD_WIDTH) * resize(coefs(i), PROD_WIDTH);
        end if;
      end if;
    end process;
  end generate;

  ----------------------------------------------------------------------------
  -- If scaled-each-tap output is enabled (SEL_OUT(2)='1'), compute scaled per-tap products.
  -- Otherwise tie scaled-products to zero (generate).
  ----------------------------------------------------------------------------
  gen_each_on: if SEL_OUT(2) = '1' generate
    gen_each_scaled: for i in 0 to N_TAPS-1 generate
    begin
      proc_scale_each: process(clk, rst_n)
      begin
        if rst_n = '0' then
          prods_scaled(i) <= (others => '0');
        elsif rising_edge(clk) then
          if data_in_valid = '1' then
            if SAT_MODE_SCALED_EACH then
              prods_scaled(i) <= sat_to_width(prods(i), DATA_WIDTH);
            else
              prods_scaled(i) <= resize(prods(i), DATA_WIDTH);
            end if;
          end if;
        end if;
      end process;
    end generate;
  end generate;

  gen_each_off: if SEL_OUT(2) /= '1' generate
  begin
    -- keep prods_scaled zero registered to avoid combinational loops
    proc_each_off: process(clk, rst_n)
    begin
      if rst_n = '0' then
        prods_scaled <= (others => (others => '0'));
      elsif rising_edge(clk) then
        prods_scaled <= (others => (others => '0'));
      end if;
    end process;
  end generate;

  ----------------------------------------------------------------------------
  -- Determine whether we need the full-precision accumulator:
  -- If either data_out_full (SEL_OUT(0)) or data_out_scaled (SEL_OUT(1)) is requested,
  -- we must compute the full accumulator. Use generate conditioned on (SEL_OUT(0)='1' or SEL_OUT(1)='1').
  ----------------------------------------------------------------------------
  gen_need_full_acc: if (SEL_OUT(0) = '1' or SEL_OUT(1) = '1') generate
    -- pipelined or non-pipelined accumulation of full products
    gen_full_pipelined: if PIPELINED generate
      -- a straightforward registered running sum chain (one register per tap)
      gen_acc_regs: for i in 0 to N_TAPS-1 generate
        signal acc_reg : signed(ACC_WIDTH-1 downto 0);
      begin
        proc_acc_reg: process(clk, rst_n)
        begin
          if rst_n = '0' then
            acc_reg <= (others => '0');
          elsif rising_edge(clk) then
            if data_in_valid = '1' then
              if i = 0 then
                acc_reg <= resize(prods(0), ACC_WIDTH);
              else
                acc_reg <= acc_reg + resize(prods(i), ACC_WIDTH);
              end if;
            end if;
          end if;
        end process;
        acc_stage(i+1) <= acc_reg;
      end generate;

      proc_acc_final_reg: process(clk, rst_n)
      begin
        if rst_n = '0' then
          acc_final <= (others => '0');
        elsif rising_edge(clk) then
          if data_in_valid = '1' then
            acc_final <= acc_stage(N_TAPS);
          end if;
        end if;
      end process;
    end generate;

    gen_full_nopipe: if not PIPELINED generate
      signal sum_comb : signed(ACC_WIDTH-1 downto 0);
    begin
      comb_proc: process(all)
        variable s : signed(ACC_WIDTH-1 downto 0);
      begin
        s := (others => '0');
        for i in 0 to N_TAPS-1 loop
          s := s + resize(prods(i), ACC_WIDTH);
        end loop;
        sum_comb <= s;
      end process;

      reg_final_np: process(clk, rst_n)
      begin
        if rst_n = '0' then
          acc_final <= (others => '0');
        elsif rising_edge(clk) then
          if data_in_valid = '1' then
            acc_final <= sum_comb;
          end if;
        end if;
      end process;
    end generate;
  end generate;

  gen_no_full_acc: if not (SEL_OUT(0) = '1' or SEL_OUT(1) = '1') generate
  begin
    -- tie acc_final to zero if not needed
    proc_no_full: process(clk, rst_n)
    begin
      if rst_n = '0' then
        acc_final <= (others => '0');
      elsif rising_edge(clk) then
        acc_final <= (others => '0');
      end if;
    end process;
  end generate;

  ----------------------------------------------------------------------------
  -- data_out_full (only synthesized if SEL_OUT(0)='1')
  ----------------------------------------------------------------------------
  gen_out_full_on: if SEL_OUT(0) = '1' generate
  begin
    data_out_full <= acc_final;
  end generate;
  gen_out_full_off: if SEL_OUT(0) /= '1' generate
  begin
    data_out_full <= (others => '0');
  end generate;

  ----------------------------------------------------------------------------
  -- data_out_scaled (only synthesized if SEL_OUT(1)='1')
  -- scaling method controlled by SAT_MODE_SCALED
  ----------------------------------------------------------------------------
  gen_out_scaled_on: if SEL_OUT(1) = '1' generate
    gen_scale_sat: if SAT_MODE_SCALED generate
    begin
      proc_scale_sat: process(acc_final)
      begin
        data_out_scaled <= sat_to_width(acc_final, DATA_WIDTH);
      end process;
    end generate;
    gen_scale_trunc: if not SAT_MODE_SCALED generate
    begin
      proc_scale_trunc: process(acc_final)
      begin
        data_out_scaled <= resize(acc_final, DATA_WIDTH);
      end process;
    end generate;
  end generate;

  gen_out_scaled_off: if SEL_OUT(1) /= '1' generate
  begin
    data_out_scaled <= (others => '0');
  end generate;

  ----------------------------------------------------------------------------
  -- data_out_scaled_each_tap (only synthesized if SEL_OUT(2)='1')
  -- uses prods_scaled and accumulates them (pipelined or not)
  ----------------------------------------------------------------------------
  gen_out_each_on: if SEL_OUT(2) = '1' generate
    gen_each_pipelined: if PIPELINED generate
      gen_acc_each_regs: for i in 0 to N_TAPS-1 generate
        signal acc_reg_e : signed(ACC_WIDTH-1 downto 0);
      begin
        proc_acc_e: process(clk, rst_n)
        begin
          if rst_n = '0' then
            acc_reg_e <= (others => '0');
          elsif rising_edge(clk) then
            if data_in_valid = '1' then
              if i = 0 then
                acc_reg_e <= resize(prods_scaled(0), ACC_WIDTH);
              else
                acc_reg_e <= acc_reg_e + resize(prods_scaled(i), ACC_WIDTH);
              end if;
            end if;
          end if;
        end process;
        acc_stage_each(i+1) <= acc_reg_e;
      end generate;

      proc_acc_final_each: process(clk, rst_n)
      begin
        if rst_n = '0' then
          acc_final_each <= (others => '0');
        elsif rising_edge(clk) then
          if data_in_valid = '1' then
            acc_final_each <= acc_stage_each(N_TAPS);
          end if;
        end if;
      end process;
    end generate;

    gen_each_nopipe: if not PIPELINED generate
      signal sum_comb_e : signed(ACC_WIDTH-1 downto 0);
    begin
      comb_e_proc: process(all)
        variable se : signed(ACC_WIDTH-1 downto 0);
      begin
        se := (others => '0');
        for i in 0 to N_TAPS-1 loop
          se := se + resize(prods_scaled(i), ACC_WIDTH);
        end loop;
        sum_comb_e <= se;
      end process;

      proc_final_e_np: process(clk, rst_n)
      begin
        if rst_n = '0' then
          acc_final_each <= (others => '0');
        elsif rising_edge(clk) then
          if data_in_valid = '1' then
            acc_final_each <= sum_comb_e;
          end if;
        end if;
      end process;
    end generate;

    -- scaling final each-tap accumulator to DATA_WIDTH using SAT_MODE_SCALED_EACH
    gen_each_scale_sat: if SAT_MODE_SCALED_EACH generate
    begin
      proc_each_scale_sat: process(acc_final_each)
      begin
        data_out_scaled_each_tap <= sat_to_width(acc_final_each, DATA_WIDTH);
      end process;
    end generate;

    gen_each_scale_trunc: if not SAT_MODE_SCALED_EACH generate
    begin
      proc_each_scale_trunc: process(acc_final_each)
      begin
        data_out_scaled_each_tap <= resize(acc_final_each, DATA_WIDTH);
      end process;
    end generate;
  end generate;

  gen_out_each_off: if SEL_OUT(2) /= '1' generate
  begin
    data_out_scaled_each_tap <= (others => '0');
  end generate;

end architecture rtl;
