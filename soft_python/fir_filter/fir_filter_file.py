"""
File I/O utilities for FIR Filter application
"""

import json
import numpy as np
from typing import Dict, Any, Optional, Tuple
from datetime import datetime
import tkinter as tk
from tkinter import filedialog, messagebox

class FilterFileManager:
    """Handles saving and loading filter configurations and coefficients"""
    
    @staticmethod
    def save_filter_config(filter_params: Dict[str, Any], coeffs: np.ndarray, 
                          quantized_coeffs: Optional[np.ndarray] = None,
                          integer_values: Optional[np.ndarray] = None,
                          quantization_params: Optional[Dict[str, Any]] = None) -> bool:
        """
        Save filter configuration to JSON file
        
        Args:
            filter_params: Dictionary of filter parameters
            coeffs: Original floating-point coefficients
            quantized_coeffs: Quantized coefficients (optional)
            integer_values: Integer representation (optional)
            quantization_params: Quantization parameters (optional)
            
        Returns:
            True if saved successfully, False otherwise
        """
        try:
            filename = filedialog.asksaveasfilename(
                defaultextension=".json",
                filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
                title="Save Filter Configuration"
            )
            
            if not filename:
                return False
                
            save_data = {
                "metadata": {
                    "created_date": datetime.now().isoformat(),
                    "application": "FIR Filter Coefficient Generator",
                    "version": "1.0"
                },
                "filter_parameters": filter_params,
                "coefficients": {
                    "floating_point": coeffs.tolist(),
                    "count": len(coeffs)
                }
            }
            
            # Add quantization data if available
            if quantized_coeffs is not None and integer_values is not None:
                save_data["coefficients"]["quantized"] = {
                    "floating_point": quantized_coeffs.tolist(),
                    "integer_values": integer_values.tolist(),
                    "quantization_parameters": quantization_params
                }
            
            with open(filename, 'w') as f:
                json.dump(save_data, f, indent=2)
            
            messagebox.showinfo("Success", f"Filter configuration saved to:\n{filename}")
            return True
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to save file:\n{str(e)}")
            return False
    
    @staticmethod
    def load_filter_config() -> Optional[Tuple[Dict[str, Any], np.ndarray, Optional[Dict[str, Any]]]]:
        """
        Load filter configuration from JSON file
        
        Returns:
            Tuple of (filter_params, coefficients, quantization_data) or None if failed
        """
        try:
            filename = filedialog.askopenfilename(
                filetypes=[("JSON files", "*.json"), ("All files", "*.*")],
                title="Load Filter Configuration"
            )
            
            if not filename:
                return None
                
            with open(filename, 'r') as f:
                data = json.load(f)
            
            filter_params = data.get("filter_parameters", {})
            coeffs = np.array(data["coefficients"]["floating_point"])
            
            quantization_data = None
            if "quantized" in data["coefficients"]:
                quantization_data = data["coefficients"]["quantized"]
            
            messagebox.showinfo("Success", f"Filter configuration loaded from:\n{filename}")
            return filter_params, coeffs, quantization_data
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to load file:\n{str(e)}")
            return None
    
    @staticmethod
    def export_coefficients(coeffs: np.ndarray, format_type: str = "c_array", 
                          integer_values: Optional[np.ndarray] = None,
                          bit_width: int = 16, signed: bool = True,
                          variable_name: str = "filter_coeffs") -> bool:
        """
        Export coefficients in various formats
        
        Args:
            coeffs: Coefficients to export
            format_type: Export format ('c_array', 'matlab', 'python', 'verilog', 'csv')
            integer_values: Integer representation for fixed-point export
            bit_width: Bit width for fixed-point formats
            signed: Whether values are signed
            variable_name: Variable name to use in generated code
            
        Returns:
            True if exported successfully, False otherwise
        """
        try:
            filename = filedialog.asksaveasfilename(
                defaultextension=FilterFileManager._get_extension(format_type),
                filetypes=FilterFileManager._get_filetypes(format_type),
                title="Export Coefficients"
            )
            
            if not filename:
                return False
            
            content = FilterFileManager._generate_export_content(
                coeffs, format_type, integer_values, bit_width, signed, variable_name
            )
            
            with open(filename, 'w') as f:
                f.write(content)
            
            messagebox.showinfo("Success", f"Coefficients exported to:\n{filename}")
            return True
            
        except Exception as e:
            messagebox.showerror("Error", f"Failed to export coefficients:\n{str(e)}")
            return False
    
    @staticmethod
    def _get_extension(format_type: str) -> str:
        """Get file extension for format type"""
        extensions = {
            "c_array": ".h",
            "matlab": ".m",
            "python": ".py",
            "verilog": ".v",
            "csv": ".csv"
        }
        return extensions.get(format_type, ".txt")
    
    @staticmethod
    def _get_filetypes(format_type: str):
        """Get file type filters for format"""
        filetypes = {
            "c_array": [("C Header files", "*.h"), ("All files", "*.*")],
            "matlab": [("MATLAB files", "*.m"), ("All files", "*.*")],
            "python": [("Python files", "*.py"), ("All files", "*.*")],
            "verilog": [("Verilog files", "*.v"), ("All files", "*.*")],
            "csv": [("CSV files", "*.csv"), ("All files", "*.*")]
        }
        return filetypes.get(format_type, [("All files", "*.*")])
    
    @staticmethod
    def _generate_export_content(coeffs: np.ndarray, format_type: str,
                               integer_values: Optional[np.ndarray] = None,
                               bit_width: int = 16, signed: bool = True,
                               variable_name: str = "filter_coeffs") -> str:
        """Generate export content based on format type"""
        
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        if format_type == "c_array":
            return FilterFileManager._generate_c_array(coeffs, integer_values, bit_width, signed, variable_name, timestamp)
        elif format_type == "matlab":
            return FilterFileManager._generate_matlab(coeffs, variable_name, timestamp)
        elif format_type == "python":
            return FilterFileManager._generate_python(coeffs, variable_name, timestamp)
        elif format_type == "verilog":
            return FilterFileManager._generate_verilog(coeffs, integer_values, bit_width, signed, variable_name, timestamp)
        elif format_type == "csv":
            return FilterFileManager._generate_csv(coeffs, integer_values)
        else:
            return str(coeffs.tolist())
    
    @staticmethod
    def _generate_c_array(coeffs: np.ndarray, integer_values: Optional[np.ndarray],
                         bit_width: int, signed: bool, variable_name: str, timestamp: str) -> str:
        """Generate C array format"""
        content = f"/* FIR Filter Coefficients\n * Generated: {timestamp}\n * Length: {len(coeffs)}\n */\n\n"
        
        if integer_values is not None:
            # Fixed-point representation
            data_type = f"int{bit_width}_t" if signed else f"uint{bit_width}_t"
            content += f"#include <stdint.h>\n\n"
            content += f"const {data_type} {variable_name}[{len(integer_values)}] = {{\n"
            
            for i in range(0, len(integer_values), 8):
                line = "    "
                for j in range(i, min(i + 8, len(integer_values))):
                    line += f"{integer_values[j]:6d}"
                    if j < len(integer_values) - 1:
                        line += ","
                    if j < min(i + 7, len(integer_values) - 1):
                        line += " "
                content += line + "\n"
            content += "};\n"
        else:
            # Floating-point representation
            content += f"const double {variable_name}[{len(coeffs)}] = {{\n"
            for i in range(0, len(coeffs), 4):
                line = "    "
                for j in range(i, min(i + 4, len(coeffs))):
                    line += f"{coeffs[j]:15.10f}"
                    if j < len(coeffs) - 1:
                        line += ","
                    if j < min(i + 3, len(coeffs) - 1):
                        line += " "
                content += line + "\n"
            content += "};\n"
        
        return content
    
    @staticmethod
    def _generate_matlab(coeffs: np.ndarray, variable_name: str, timestamp: str) -> str:
        """Generate MATLAB format"""
        content = f"% FIR Filter Coefficients\n% Generated: {timestamp}\n% Length: {len(coeffs)}\n\n"
        content += f"{variable_name} = [\n"
        
        for i in range(0, len(coeffs), 4):
            line = "    "
            for j in range(i, min(i + 4, len(coeffs))):
                line += f"{coeffs[j]:15.10f}"
                if j < len(coeffs) - 1:
                    line += ","
                if j < min(i + 3, len(coeffs) - 1):
                    line += "  "
            content += line + "\n"
        
        content += "];\n"
        return content
    
    @staticmethod
    def _generate_python(coeffs: np.ndarray, variable_name: str, timestamp: str) -> str:
        """Generate Python format"""
        content = f"# FIR Filter Coefficients\n# Generated: {timestamp}\n# Length: {len(coeffs)}\n\n"
        content += f"import numpy as np\n\n"
        content += f"{variable_name} = np.array([\n"
        
        for i in range(0, len(coeffs), 4):
            line = "    "
            for j in range(i, min(i + 4, len(coeffs))):
                line += f"{coeffs[j]:15.10f}"
                if j < len(coeffs) - 1:
                    line += ","
                if j < min(i + 3, len(coeffs) - 1):
                    line += "  "
            content += line + "\n"
        
        content += "])\n"
        return content
    
    @staticmethod
    def _generate_verilog(coeffs: np.ndarray, integer_values: Optional[np.ndarray],
                         bit_width: int, signed: bool, variable_name: str, timestamp: str) -> str:
        """Generate Verilog format"""
        content = f"// FIR Filter Coefficients\n// Generated: {timestamp}\n// Length: {len(coeffs)}\n"
        content += f"// Bit width: {bit_width}, Signed: {signed}\n\n"
        
        if integer_values is not None:
            content += f"parameter COEFF_WIDTH = {bit_width};\n"
            content += f"parameter NUM_COEFFS = {len(integer_values)};\n\n"
            
            sign_str = "signed" if signed else ""
            content += f"reg {sign_str} [COEFF_WIDTH-1:0] {variable_name} [0:NUM_COEFFS-1];\n\n"
            content += "initial begin\n"
            
            for i, val in enumerate(integer_values):
                if signed and val < 0:
                    val_unsigned = (1 << bit_width) + val
                else:
                    val_unsigned = val
                hex_width = (bit_width + 3) // 4
                content += f"    {variable_name}[{i:2d}] = {bit_width}'h{val_unsigned:0{hex_width}X};\n"
            
            content += "end\n"
        else:
            content += "// Floating-point coefficients (convert to fixed-point for hardware)\n"
            for i, coeff in enumerate(coeffs):
                content += f"// {variable_name}[{i:2d}] = {coeff:15.10f}\n"
        
        return content
    
    @staticmethod
    def _generate_csv(coeffs: np.ndarray, integer_values: Optional[np.ndarray]) -> str:
        """Generate CSV format"""
        content = "Index,Floating_Point"
        if integer_values is not None:
            content += ",Integer_Value"
        content += "\n"
        
        for i, coeff in enumerate(coeffs):
            content += f"{i},{coeff:.10f}"
            if integer_values is not None:
                content += f",{integer_values[i]}"
            content += "\n"
        
        return content