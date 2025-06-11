-------------------------------------------------------------------------------
--  Compagny    : levelup-fpga-design
--  Author      : gvr
--  Created     : 10/06/2025
-- based on fifo from Rudolf Usselmann http://www.opencores.org/cores/generic_fifos/
-------------------------------------------------------------------------------


-- Description
-- ===========
--
-- I/Os
-- ----
-- rd_clk	Read Port Clock
-- wr_clk	Write Port Clock
-- rst	low active, either sync. or async. master reset (see below how to select)
-- clr	synchronous clear (just like reset but always synchronous), high active
-- rde	read enable, synchronous, high active
-- wre	read enable, synchronous, high active
-- din	Data Input
-- dout	Data Output
--
-- full	Indicates the FIFO is full (driven at the rising edge of wr_clk)
-- empty	Indicates the FIFO is empty (driven at the rising edge of rd_clk)
--
-- wr_level	indicates the FIFO level:
-- 		2'b00	0-25%	 full
-- 		2'b01	25-50%	 full
-- 		2'b10	50-75%	 full
-- 		2'b11	%75-100% full
--
-- rd_level	indicates the FIFO level:
-- 		2'b00	0-25%	 empty
-- 		2'b01	25-50%	 empty
-- 		2'b10	50-75%	 empty
-- 		2'b11	%75-100% empty
--
-- Status Timing
-- -------------
-- All status outputs are registered. They are asserted immediately
-- as the full/empty condition occurs, however, there is a 2 cycle
-- delay before they are de-asserted once the condition is not true
-- anymore.
--
-- Parameters
-- ----------
-- The FIFO takes 2 parameters:
-- dw	Data bus width
-- aw	Address bus width (Determines the FIFO size by evaluating 2^aw)
--
-- Synthesis Results
-- -----------------
-- In a Spartan 2e a 8 bit wide, 8 entries deep FIFO, takes 97 LUTs and runs
-- at about 113 MHz (IO insertion disabled).
--
-- Misc
-- ----
-- This design assumes you will do appropriate status checking externally.
--
-- IMPORTANT ! writing while the FIFO is full or reading while the FIFO is
-- empty will place the FIFO in an undefined state.



-------------------------------------------------------------------------------
-- DEPENDANCES
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-------------------------------------------------------------------------------
-- DECLARATION DE L'INTERFACE DE L'ENTITE
-------------------------------------------------------------------------------


entity fifo_dc_gray is
generic(
	dw : integer := 16;
	aw : integer := 3
);
port(
	rst         : in  std_logic;
	clr         : in  std_logic;

	wr_clk		: in  std_logic;
	wre         : in  std_logic;
	din         : in  std_logic_vector(dw-1 downto 0);
	full        : out std_logic;
	wr_level    : out std_logic_vector(1 downto 0);

	rd_clk      : in  std_logic;
	rde         : in  std_logic;
	dout        : out std_logic_vector(dw-1 downto 0);
	empty       : out std_logic;
	rd_level    : out std_logic_vector(1 downto 0)
);
end fifo_dc_gray;

-------------------------------------------------------------------------------
-- DECLARATION DE L'ARCHITECTURE
-------------------------------------------------------------------------------

architecture rtl of fifo_dc_gray is

-------------------------------------------------------------------------------
-- DECLARATION D'ENTITES EXTERNES
-------------------------------------------------------------------------------

component dpram_dc is
  Generic(
      g_dwidth : integer := 32;
      g_awidth : integer := 64
  );
  Port (


        		wr_clk        : in  std_logic;
				Ram_data_wr   : in  std_logic_vector(g_dwidth - 1 downto 0);
				Ram_addr_wr   : in  std_logic_vector(g_awidth - 1 downto 0);
				Ram_wr        : in  std_logic;

				rd_clk        : in  std_logic;
				Ram_data_rd   : out std_logic_vector(g_dwidth - 1 downto 0);
				Ram_addr_rd   : in  std_logic_vector(g_awidth - 1 downto 0)


		);
end component;

-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES DE TYPAGE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DE TYPES ET SOUS TYPES
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- DECLARATION DE CONSTANTES FONCTIONNELLES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DES ETATS MACHINE
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- DECLARATION DE SIGNAUX INTERNES
-------------------------------------------------------------------------------

signal wp_bin             : std_logic_vector(aw downto 0);
signal wp_gray            : std_logic_vector(aw downto 0);
signal rp_bin             : std_logic_vector(aw downto 0);
signal rp_gray            : std_logic_vector(aw downto 0);
signal wp_s               : std_logic_vector(aw downto 0);
signal rp_s               : std_logic_vector(aw downto 0);
signal wp_bin_next        : std_logic_vector(aw downto 0);
signal wp_gray_next       : std_logic_vector(aw downto 0);
signal rp_bin_next        : std_logic_vector(aw downto 0);
signal rp_gray_next       : std_logic_vector(aw downto 0);
signal wp_bin_x           : std_logic_vector(aw downto 0);
signal rp_bin_x           : std_logic_vector(aw downto 0);

signal d1           : std_logic_vector(aw-1 downto 0);
signal d2           : std_logic_vector(aw-1 downto 0);

signal rd_rst      : std_logic;
signal wr_rst      : std_logic;
signal rd_rst_r    : std_logic;
signal wr_rst_r    : std_logic;
signal rd_clr      : std_logic;
signal wr_clr      : std_logic;
signal rd_clr_r    : std_logic;
signal wr_clr_r    : std_logic;

signal s_full      : std_logic;
signal s_empty     : std_logic;

-- for level indicators
signal wp_bin_xr : std_logic_vector(aw-1 downto 0);
signal rp_bin_xr : std_logic_vector(aw-1 downto 0);
signal full_rc   : std_logic;
signal full_wc   : std_logic;



-------------------------------------------------------------------------------
-- CORPS DE L'ARCHITECTURE
-------------------------------------------------------------------------------

begin

-------------------------------------------------------------------------------
-- INSTANCIATION DES ENTITES EXTERNES
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- SIGNAUX CONSTANTS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- PROCESS CLK
-------------------------------------------------------------------------------


--// Reset Logic ------------------------------------------
process(rd_clk,rst)
begin
	if(rst = '0') then
		rd_rst 		<= '0';
		rd_rst_r 	<= '0';
	elsif(rd_clk'event and rd_clk='1') then
	  if(rd_rst_r = '1') then
	  	rd_rst 		<= '1';
	  end if;
	  rd_rst_r <= '1';
	end if;
end process;

process(wr_clk,rst)
begin
	if(rst = '0') then
		wr_rst 		<= '0';
		wr_rst_r 	<= '0';
	elsif(wr_clk'event and wr_clk='1') then
	  if(wr_rst_r = '1') then
	  	wr_rst 		<= '1';
	  end if;
	  wr_rst_r <= '1';
	end if;
end process;

process(rd_clk,clr)
begin
	if(clr = '1') then
		rd_clr 		<= '1';
		rd_clr_r 	<= '1';
	elsif(rd_clk'event and rd_clk='1') then
	  if(rd_clr_r = '0') then
	  	rd_clr 		<= '0';
	  end if;
	  rd_clr_r <= '0';
	end if;
end process;

process(wr_clk,clr)
begin
	if(clr = '1') then
		wr_clr 		<= '1';
		wr_clr_r 	<= '1';
	elsif(wr_clk'event and wr_clk='1') then
	  if(wr_clr_r = '0') then
	  	wr_clr 		<= '0';
	  end if;
	  wr_clr_r <= '0';
	end if;
end process;




--// Memory Block ------------------------------------



u_dpram_dc : dpram_dc
  Generic map(
      g_dwidth => dw ,
      g_awidth => aw
  )
  Port map(


        		wr_clk        =>  wr_clk ,
				Ram_data_wr   =>  din ,
				Ram_addr_wr   =>  wp_bin(aw-1 downto 0) ,
				Ram_wr        =>  wre ,

				rd_clk        =>  rd_clk ,
				Ram_data_rd   =>  dout ,
				Ram_addr_rd   =>  rp_bin(aw-1 downto 0)


		);



--// Read/Write Pointers Logic -----------------------------


process(wr_clk)
begin
	if(wr_clk'event and wr_clk='1') then
	  	if(wr_rst = '0') then
	  		wp_bin  <= (others => '0');
	  		wp_gray <= (others => '0');
	  	elsif(wr_clr = '1') then
	  		wp_bin <= (others => '0');
	  		wp_gray <= (others => '0');
	  	elsif(wre = '1') then
	  		wp_bin  <= wp_bin_next;
	  		wp_gray <= wp_gray_next;
	  	end if;
	end if;
end process;

wp_bin_next  <= wp_bin + 1;
wp_gray_next <= wp_bin_next xor ('0' & wp_bin_next(aw downto 1));



process(rd_clk)
begin
	if(rd_clk'event and rd_clk='1') then
		if(rd_rst = '0') then
	  		rp_bin  <= (others => '0');
	  		rp_gray <= (others => '0');
	  	elsif(rd_clr = '1') then
	  		rp_bin <= (others => '0');
	  		rp_gray <= (others => '0');
	  	elsif(rde = '1') then
	  		rp_bin  <= rp_bin_next;
	  		rp_gray <= rp_gray_next;
	  	end if;
	end if;
end process;

rp_bin_next  <= rp_bin + 1;
rp_gray_next <= rp_bin_next xor ('0' & rp_bin_next(aw downto 1));


--// Synchronization Logic


process(wr_clk)
begin
	if(wr_clk'event and wr_clk='1') then
		rp_s <= rp_gray;
	end if;
end process;

process(rd_clk)
begin
	if(rd_clk'event and rd_clk='1') then
		wp_s <= wp_gray;
	end if;
end process;


--// Registered Full & Empty Flags


wp_bin_x <= wp_s xor ('0' & wp_bin_x(aw downto 1));	-- convert gray to binary
rp_bin_x <= rp_s xor ('0' & rp_bin_x(aw downto 1));	-- convert gray to binary

process(rd_clk)
begin
	if(rd_clk'event and rd_clk='1') then
		if( (wp_s = rp_gray) or ( rde = '1' and (wp_s = rp_gray_next)) ) then
			s_empty <= '1';
		else
			s_empty <= '0';
		end if;
	end if;
end process;

empty <= s_empty;

process(wr_clk)
begin
	if(wr_clk'event and wr_clk='1') then
		if(  ((wp_bin(aw-1 downto 0) = rp_bin_x(aw-1 downto 0)) and (wp_bin(aw) /= rp_bin_x(aw))) or
		( (wre = '1') and (wp_bin_next(aw-1 downto 0) = rp_bin_x(aw-1 downto 0)) and (wp_bin_next(aw) /= rp_bin_x(aw)) ) ) then
			s_full <= '1';
		else
			s_full <= '0';
		end if;
	end if;
end process;

full <= s_full;

-- Registered Level Indicators


process(wr_clk)
begin
	if(wr_clk'event and wr_clk='1') then
		full_wc  	<= s_full;
		rp_bin_xr 	<=   (not rp_bin_x(aw-1 downto 0)) + 1;
		d1 			<= wp_bin(aw-1 downto 0) + rp_bin_xr(aw-1 downto 0);
		wr_level <= (d1(aw-1) or s_full or full_wc ) & (d1(aw-2) or s_full or full_wc);
	end if;
end process;


process(rd_clk)
begin
	if(rd_clk'event and rd_clk='1') then
		wp_bin_xr 	<=  not wp_bin_x(aw-1 downto 0);
		d2 			<= rp_bin(aw-1 downto 0) + wp_bin_xr(aw-1 downto 0);
		full_rc 	<= s_full;
		if(full_rc = '1') then
			rd_level <= (others => '0');
		else
			rd_level <= (d2(aw-1) or s_empty)&(d2(aw-2) or s_empty);
		end if;
	end if;
end process;


end rtl;

