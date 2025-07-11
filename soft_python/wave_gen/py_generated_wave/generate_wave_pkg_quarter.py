import math
import os

# ===========================
# USER CONFIGURATION SECTION
# ===========================
NUM_SAMPLES    = 128       # Number of samples in the first quarter
BIT_RESOLUTION = 13       # Bit resolution (e.g., 8, 10, 12)
WAVE_TYPE      = "sin"    # "sin" or "tri"
MAX_PER_LINE   = 8        # Max values per line in VHDL array
# ===========================

def generate_waveform(samples, resolution, wave_type):
    max_value = (1 << resolution) - 1
    data = []

    for i in range(samples):
        if wave_type == "sin":
            value = math.sin((math.pi / 2) * i / (samples - 1))  # First quarter
        elif wave_type == "tri":
            value = i / (samples - 1)
        else:
            raise ValueError("Unsupported wave type. Use 'sin' or 'tri'.")
        scaled = int(round(value * max_value))
        data.append(scaled)

    return data

def format_vhdl_array(data, resolution, output_path, max_per_line, package_name):
    bits_str = f"{resolution - 1} downto 0"
    max_digits = len(str(max(data)))  # For vec(  NN ) alignment
    vhdl_lines = []

    # Header
    vhdl_lines.append("library IEEE;")
    vhdl_lines.append("use IEEE.STD_LOGIC_1164.ALL;")
    vhdl_lines.append("use IEEE.NUMERIC_STD.ALL;\n")
    vhdl_lines.append(f"package {package_name} is")

    # Type and function
    vhdl_lines.append(f"  constant WAVE_SAMPLES : integer := {len(data)};")
    vhdl_lines.append(f"  type wave_array_t is array (0 to WAVE_SAMPLES - 1) of std_logic_vector({bits_str});")
    vhdl_lines.append("  function vec(x : integer) return std_logic_vector;")
    vhdl_lines.append(f"  constant WAVE_DATA : wave_array_t := (")

    # Data array
    line = "    "
    for idx, val in enumerate(data):
        padded_val = f"{val:>{max_digits}}"
        element = f"vec({padded_val})"
        line += element
        if idx < len(data) - 1:
            line += ", "
        if (idx + 1) % max_per_line == 0 and idx != len(data) - 1:
            vhdl_lines.append(line)
            line = "    "

    if line.strip():
        vhdl_lines.append(line)

    vhdl_lines.append("  );")

    # Function body
    vhdl_lines.append("end package;\n")
    vhdl_lines.append(f"package body {package_name} is")
    vhdl_lines.append("  function vec(x : integer) return std_logic_vector is")
    vhdl_lines.append("  begin")
    vhdl_lines.append(f"    return std_logic_vector(to_unsigned(x, {resolution}));")
    vhdl_lines.append("  end function;")
    vhdl_lines.append(f"end package body {package_name};")

    # Write file
    with open(output_path, "w") as f:
        for l in vhdl_lines:
            f.write(l + "\n")

    print(f"✅ VHDL package '{package_name}' saved to: {output_path}")

def construct_output_info(wave_type, samples, bits):
    base_name = f"{wave_type}_{samples}_sample_{bits}_bit"
    filename = base_name + ".vhd"
    package = base_name + "_pkg"
    return filename, package

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_filename, package_name = construct_output_info(WAVE_TYPE, NUM_SAMPLES, BIT_RESOLUTION)
    output_path = os.path.join(script_dir, output_filename)

    data = generate_waveform(NUM_SAMPLES, BIT_RESOLUTION, WAVE_TYPE)
    format_vhdl_array(data, BIT_RESOLUTION, output_path, MAX_PER_LINE, package_name)

if __name__ == "__main__":
    main()