-------------------------------------------------------------------------------
--  Compagny    : levelup-fpga-design
--  Author      : gvr
--  Created     : 10/06/2025
--
--  Copyright (c) 2025 levelup-fpga-design
--
--  This file is part of the levelup-fpga-design distibuted sources.
--
--  License:
--    - Free to use, modify, and distribute for **non-commercial** purposes.
--    - For **commercial** use, you must obtain a license by contacting:
--        contact@levelup-fpga.fr or directly at gvanroyen@levelup-fpga.fr
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
--  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
--  DEALINGS IN THE SOFTWARE.
-------------------------------------------------------------------------------



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;


package util_pkg is





function one_hot_to_binary (One_Hot : std_logic_vector ; size    : natural ) return std_logic_vector;
function log2( i : natural) return integer;
function or_vector(vector : std_logic_vector) return std_logic;
--function ipv4str_to_32slv(ip_string : string) return std_logic_vector;--TODO "192.168.0.1"=> X"C0A80001"

end;


package body util_pkg is


  function one_hot_to_binary (
    One_Hot : std_logic_vector ;
    size    : natural
  ) return std_logic_vector is

    variable Bin_Vec_Var : std_logic_vector(size-1 downto 0);

  begin

    Bin_Vec_Var := (others => '0');

    for I in One_Hot'range loop
      if One_Hot(I) = '1' then
        Bin_Vec_Var := Bin_Vec_Var or std_logic_vector(to_unsigned(I,size));
      end if;
    end loop;
    return Bin_Vec_Var;
  end function;


function or_vector(vector : std_logic_vector) return std_logic is
    variable result : std_logic := '0';
begin
    for i in vector'range loop
        result := result or vector(i);
    end loop;
    return result;
end function;




function log2( i : natural) return integer is
    variable temp    : integer := i;
    variable ret_val : integer := 0;
  begin
    while temp > 1 loop
      ret_val := ret_val + 1;
      temp    := temp / 2;
    end loop;
    return ret_val;
end function;




end package body;
