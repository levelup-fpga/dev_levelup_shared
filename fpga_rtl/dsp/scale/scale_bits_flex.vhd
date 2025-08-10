library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity scale_bits_flex is
  generic (
    N           : positive := 8;    -- input width
    M           : positive := 12;   -- output width
    SIGNED_MODE : boolean  := false; -- true = signed, false = unsigned
    PIPELINE    : positive := 1      -- number of pipeline stages, minimum 1
  );
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    din        : in  std_logic_vector(N-1 downto 0);
    din_valid  : in  std_logic;
    dout       : out std_logic_vector(M-1 downto 0);
    dout_valid : out std_logic
  );
end entity scale_bits_flex;

architecture rtl of scale_bits_flex is

  -- Internal numeric signals
  signal din_s  : signed(N-1 downto 0)   := (others => '0');
  signal din_u  : unsigned(N-1 downto 0) := (others => '0');

  signal dout_s : signed(M-1 downto 0)   := (others => '0');
  signal dout_u : unsigned(M-1 downto 0) := (others => '0');

  -- Internal combined output before pipeline
  signal dout_comb : std_logic_vector(M-1 downto 0) := (others => '0');

  -- Fixed-size array types based on PIPELINE (minimum 1 stage)
  type data_array  is array (0 to PIPELINE-1) of std_logic_vector(M-1 downto 0);
  type valid_array is array (0 to PIPELINE-1) of std_logic;

  signal data_pipe  : data_array  := (others => (others => '0'));
  signal valid_pipe : valid_array := (others => '0');

begin

  ------------------------------------------------------------------
  -- Input type casting
  ------------------------------------------------------------------
  signed_input_gen : if SIGNED_MODE generate
    din_s <= signed(din);
    din_u <= (others => '0');  -- unused
  end generate;

  unsigned_input_gen : if not SIGNED_MODE generate
    din_u <= unsigned(din);
    din_s <= (others => '0');  -- unused
  end generate;

  ------------------------------------------------------------------
  -- Scaling logic for SIGNED mode
  ------------------------------------------------------------------
  signed_scale_gen : if SIGNED_MODE generate
    upsize_signed : if M > N generate
      dout_s <= shift_left(resize(din_s, M), M - N);
    end generate;

    downsize_signed : if M < N generate
      dout_s <= shift_right(resize(din_s, M), N - M);
    end generate;

    same_size_signed : if M = N generate
      dout_s <= din_s;
    end generate;

    dout_u <= (others => '0');  -- unused
  end generate;

  ------------------------------------------------------------------
  -- Scaling logic for UNSIGNED mode
  ------------------------------------------------------------------
  unsigned_scale_gen : if not SIGNED_MODE generate
    upsize_unsigned : if M > N generate
      dout_u <= shift_left(resize(din_u, M), M - N);
    end generate;

    downsize_unsigned : if M < N generate
      dout_u <= shift_right(resize(din_u, M), N - M);
    end generate;

    same_size_unsigned : if M = N generate
      dout_u <= din_u;
    end generate;

    dout_s <= (others => '0');  -- unused
  end generate;

  ------------------------------------------------------------------
  -- Output selection before pipeline
  ------------------------------------------------------------------
  dout_comb <= std_logic_vector(dout_s) when SIGNED_MODE else std_logic_vector(dout_u);

  ------------------------------------------------------------------
  -- Pipeline registers
  ------------------------------------------------------------------
  process(clk, rst)
  begin
    if rst = '1' then
      data_pipe  <= (others => (others => '0'));
      valid_pipe <= (others => '0');
    elsif rising_edge(clk) then
      -- First stage gets combinational result
      data_pipe(0)  <= dout_comb;
      valid_pipe(0) <= din_valid;

      -- Remaining stages shift data/valid
      for i in 1 to PIPELINE-1 loop
        data_pipe(i)  <= data_pipe(i-1);
        valid_pipe(i) <= valid_pipe(i-1);
      end loop;
    end if;
  end process;

  ------------------------------------------------------------------
  -- Outputs
  ------------------------------------------------------------------
  dout       <= data_pipe(PIPELINE-1);
  dout_valid <= valid_pipe(PIPELINE-1);

end architecture rtl;
