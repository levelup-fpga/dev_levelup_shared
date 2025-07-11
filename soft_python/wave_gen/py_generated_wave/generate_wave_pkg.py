import math
from pathlib import Path
import os

# ========== Configuration ==========
NUM_SAMPLES = 2048         # Number of table entries
BIT_RESOLUTION = 12       # Number of output bits
VALUES_PER_LINE = 16       # Max values per VHDL line
PACKAGE_NAME = "sine_2048_sample_12bit"
WAVEFORM = "sine"         # Options: 'sine', 'cosine', 'triangle'
FORMAT = "hex"            # Options: 'hex', 'bin', 'both'
# ===================================

MAX_VALUE = (1 << BIT_RESOLUTION) - 1

def generate_waveform(samples: int, waveform: str):
    data = []
    for i in range(samples):
        angle = 2 * math.pi * i / samples
        if waveform == "sine":
            val = math.sin(angle)
        elif waveform == "cosine":
            val = math.cos(angle)
        elif waveform == "triangle":
            val = 2 * abs(2 * (i / samples - math.floor(i / samples + 0.5))) - 1
        else:
            raise ValueError(f"Unsupported waveform: {waveform}")
        scaled = int((val + 1) * (MAX_VALUE / 2))
        data.append(scaled)
    return data

def to_hex(val: int, width: int):
    digits = (width + 3) // 4
    return f'x"{val:0{digits}X}"'

def to_bin(val: int, width: int):
    return f'"{val:0{width}b}"'

def format_value(val: int, width: int, fmt: str):
    if fmt == "hex":
        return to_hex(val, width)
    elif fmt == "bin":
        return to_bin(val, width)
    elif fmt == "both":
        return f'{to_hex(val, width)}  -- {to_bin(val, width)}'
    else:
        raise ValueError("Invalid format option.")

def generate_vhdl_package(values, bit_width, package_name, fmt):
    slv_type = f"std_logic_vector({bit_width - 1} downto 0)"
    lines = []
    for i in range(0, len(values), VALUES_PER_LINE):
        chunk = values[i:i+VALUES_PER_LINE]
        line = "        " + ", ".join(format_value(val, bit_width, fmt) for val in chunk)
        if i + VALUES_PER_LINE < len(values):
            line += ","
        lines.append(line)

    return f"""library ieee;
use ieee.std_logic_1164.all;

package {package_name} is

    type wave_table_t is array (0 to {len(values) - 1}) of {slv_type};

    constant WAVE_TABLE : wave_table_t := (
{chr(10).join(lines)}
    );

end package;
"""


def write_file(filename: str, content: str):
    script_dir = Path(__file__).parent
    full_path = script_dir / filename
    full_path.write_text(content)
    print(f"[+] Wrote {full_path.name}")

if __name__ == "__main__":
    waveform_data = generate_waveform(NUM_SAMPLES, WAVEFORM)
    pkg_content = generate_vhdl_package(waveform_data, BIT_RESOLUTION, PACKAGE_NAME, FORMAT)

    write_file(PACKAGE_NAME + ".vhd", pkg_content)