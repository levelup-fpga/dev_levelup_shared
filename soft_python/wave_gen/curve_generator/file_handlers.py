"""
File handling functions for saving samples in different formats
"""

import os
import numpy as np

class FileHandler:
    """Class for handling file operations"""

    def save_samples_txt(self, filename, save_data):
        """
        Save samples in TXT format

        Args:
            filename: Output filename
            save_data: Dictionary containing sample data and metadata
        """
        y_samples_display = save_data['y_samples_display']
        is_virtual_zoom = save_data['is_virtual_zoom']
        y_bottom = save_data['y_bottom']
        y_top = save_data['y_top']

        with open(filename, 'w') as f:
            # Add header to indicate if virtual zoom was applied
            if is_virtual_zoom:
                f.write(f"# Virtual zoom applied: Y_real range [{y_bottom:.6f}, {y_top:.6f}] mapped to [0.0, 1.0]\n")
                f.write("# Sample_Index Y_virtual_value\n")
            else:
                f.write("# Y_real values (no virtual zoom)\n")
                f.write("# Sample_Index Y_real_value\n")

            for i, y_val in enumerate(y_samples_display):
                f.write(f"{i} {y_val:.40g}\n")

    def save_samples_vhdl(self, filename, save_data):
        """
        Save samples in VHDL package format

        Args:
            filename: Output filename
            save_data: Dictionary containing sample data and metadata
        """
        y_samples_display = save_data['y_samples_display']
        num_samples = save_data['num_samples']
        bit_range = save_data['bit_range']
        is_virtual_zoom = save_data['is_virtual_zoom']
        y_bottom = save_data['y_bottom']
        y_top = save_data['y_top']
        curve_type = save_data['curve_type']

        max_value = (1 << bit_range) - 1  # 2^bit_range - 1

        # Convert float values to integers using full bit range
        y_int_values = np.round(y_samples_display * max_value).astype(int)

        # Ensure values are within valid range
        y_int_values = np.clip(y_int_values, 0, max_value)

        # Calculate the maximum possible value for the bit range
        max_possible_value = (2 ** bit_range) - 1
        # Calculate the width needed for the maximum value string
        max_width = len(str(max_possible_value))

        # Create VHDL package
        package_name = os.path.splitext(os.path.basename(filename))[0]

        with open(filename, 'w') as f:
            # Write header
            f.write("-- Generated curve samples\n")
            f.write("-- " + "="*50 + "\n")
            if is_virtual_zoom:
                f.write(f"-- Virtual zoom applied: Y_real range [{y_bottom:.6f}, {y_top:.6f}] mapped to [0.0, 1.0]\n")
            else:
                f.write("-- Y_real values (no virtual zoom)\n")
            f.write(f"-- Curve type: {curve_type}\n")
            f.write(f"-- Number of samples: {num_samples}\n")
            f.write(f"-- Bit range: {bit_range} bits (0 to {max_value})\n")
            f.write("-- " + "="*50 + "\n\n")

            # Write VHDL package declaration
            f.write("library IEEE;\n")
            f.write("use IEEE.STD_LOGIC_1164.ALL;\n")
            f.write("use IEEE.NUMERIC_STD.ALL;\n\n")

            f.write(f"package {package_name}_pkg is\n\n")

            # Define the array type
            f.write(f"    type sample_array_t is array (0 to {num_samples-1}) of std_logic_vector({bit_range-1} downto 0);\n\n")

            # Define the vec function
            f.write(f"    function vec(value : integer) return std_logic_vector;\n\n")

            # Declare the sample array
            f.write(f"    constant SAMPLES : sample_array_t := (\n")

            # Write array values, 8 per line with aligned formatting
            for i in range(0, num_samples, 8):
                f.write("        ")
                line_values = []
                for j in range(min(8, num_samples - i)):
                    idx = i + j
                    # Right-align the integer value within the calculated width
                    aligned_value = str(y_int_values[idx]).rjust(max_width)
                    line_values.append(f"vec({aligned_value})")

                f.write(", ".join(line_values))

                if i + 8 < num_samples:
                    f.write(",")
                f.write("\n")

            f.write("    );\n\n")
            f.write(f"end package {package_name}_pkg;\n\n")

            # Package body with function implementation
            f.write(f"package body {package_name}_pkg is\n\n")
            f.write(f"    function vec(value : integer) return std_logic_vector is\n")
            f.write(f"    begin\n")
            f.write(f"        return std_logic_vector(to_unsigned(value, {bit_range}));\n")
            f.write(f"    end function vec;\n\n")
            f.write(f"end package body {package_name}_pkg;\n")
