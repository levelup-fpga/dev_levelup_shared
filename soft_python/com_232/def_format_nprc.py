##-----------------------------------------------------------------------------
##  Compagny    : levelup-fpga-design
##  Author      : gvr
##  Created     : 10/06/2025
##
##  Copyright (c) 2025 levelup-fpga-design
##
##  This file is part of the levelup-fpga-design distibuted sources.
##
##  License:
##    - Free to use, modify, and distribute for **non-commercial** purposes.
##    - For **commercial** use, you must obtain a license by contacting:
##        contact@levelup-fpga.fr or directly at gvanroyen@levelup-fpga.fr
##
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
##  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
##  DEALINGS IN THE SOFTWARE.
##-----------------------------------------------------------------------------

#All basic functions for data formating, usefull for "OSI"_LVL3 but independent of any related HW constant dictated features
#NPRC : No   Protocol Related Constants

#TODO_AFTER_DEBUG !!!!!!!!!!!!!!: remove prints and send an error (loss of time) => ALL!!!!!!!!!!!!

def int_to_0xhex32(value):
    try:
        if isinstance(value, str):
            if not value.lower().startswith("0x"):
                raise ValueError("String must start with '0x'.")
            value = int(value, 16)
        elif not isinstance(value, int):
            raise TypeError("Value must be an integer or '0x'-prefixed hex string.")

        if not (0 <= value <= 0xFFFFFFFF):
            raise ValueError("Value must be a 32-bit unsigned integer (0 to 0xFFFFFFFF).")

        return f"0x{value:08X}"
    except (ValueError, TypeError) as e:
        print(f"❌ {e}")
        return None


def int_to_hex32(value):
    if not (0 <= value <= 0xFFFFFFFF):
        raise ValueError("Value must be a 32-bit unsigned integer (0 to 0xFFFFFFFF).")
    return f"{value:08X}"


def strip_0x_prefix(hex_str):
    if not hex_str.lower().startswith("0x"):
        raise ValueError("Input must start with '0x'")
    return hex_str[2:].upper()






def print_hex_array_grid(hex_array, columns):
    if not hex_array or columns <= 0:
        print("❌ Invalid parameters.")
        return

    col_width = 12
    print(f"\n📦 Displaying {len(hex_array)} values in {columns}-column format:\n")
    print("     " + "".join(f"{f'C{c:02}':^{col_width}}" for c in range(columns)))
    print("    " + "-" * (col_width * columns))

    for i in range(0, len(hex_array), columns):
        row = "".join(f"{val:>{col_width}}" for val in hex_array[i:i+columns])
        print(f"R{i // columns:02} |{row}")




def build_SPI_headerN1_cmd_length(RWn, Length):
    # Check Length fits in 15 bits
    if Length > 0x7FFF:
        print(f"❌ Length {Length} exceeds 15-bit maximum (0x7FFF).")
        return None

    msb = 1 if RWn else 0
    upper_16 = (msb << 15) | Length
    lower_16 = 0xDEAD

    full_value = (upper_16 << 16) | lower_16
    hex_str = f"0x{full_value:08X}"

    return hex_str



def build_SPI_headerN2_ss_addr(chip_sel, addr):
    # Mask inputs to proper bit widths
    chip_sel &= 0xFF       # 8 bits
    addr &= 0xFFFFFF       # 24 bits

    # Combine chip_sel as MSB and addr as LSB
    result = (chip_sel << 24) | addr

    # Format as 8-digit uppercase hex with '0x' prefix
    hex_str = f"0x{result:08X}"
    return hex_str


def build_SPI_rawdata_wrcmd_buffer(chip_sel, addr, str_data_array):
    raw_string_array = []
    raw_string_array.append(build_SPI_headerN1_cmd_length(False,len(str_data_array)))
    raw_string_array.append(build_SPI_headerN2_ss_addr(chip_sel, addr))
    raw_string_array.extend(str_data_array)
    return raw_string_array

def build_SPI_rawdata_rdcmd_buffer(chip_sel, addr, length):
    raw_string_array = []
    raw_string_array.append(build_SPI_headerN1_cmd_length(True,length))
    raw_string_array.append(build_SPI_headerN2_ss_addr(chip_sel, addr))
    for i in range(length):
        raw_string_array.append("0x00000000") #dummy to generate clk for eading on spi line
    return raw_string_array
