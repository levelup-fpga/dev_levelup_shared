"""
FIR Filter Mathematical Operations and Design Functions
"""

import numpy as np
from scipy import signal
from typing import Tuple, Optional, Union

class FilterDesigner:
    """Class for designing FIR filters"""
    
    @staticmethod
    def validate_parameters(num_coeffs: str, cutoff1: str, cutoff2: str, fs: str) -> Tuple[int, float, Optional[float], float]:
        """
        Validate and return sanitized filter parameters
        
        Args:
            num_coeffs: Number of coefficients as string
            cutoff1: First cutoff frequency as string
            cutoff2: Second cutoff frequency as string (optional)
            fs: Sampling frequency as string
            
        Returns:
            Tuple of (num_coeffs, cutoff1, cutoff2, fs)
        """
        try:
            n_coeffs = int(num_coeffs)
            if n_coeffs < 3:
                n_coeffs = 3
            if n_coeffs % 2 == 0:  # Make odd for better filter properties
                n_coeffs += 1
                
            fc1 = float(cutoff1)
            fc2 = float(cutoff2) if cutoff2 else None
            sampling_freq = float(fs)
            
            # Normalize cutoff frequencies (should be between 0 and 1 for normalized frequency)
            fc1 = max(0.001, min(0.499, fc1))
            if fc2 is not None:
                fc2 = max(0.001, min(0.499, fc2))
                if fc1 >= fc2:
                    fc1, fc2 = fc2, fc1
                    
            return n_coeffs, fc1, fc2, sampling_freq
            
        except ValueError:
            return 51, 0.1, 0.3, 1.0  # Default values
    
    @staticmethod
    def design_filter(filter_type: str, num_coeffs: int, cutoff1: float, 
                     cutoff2: Optional[float] = None, window: str = 'hamming') -> np.ndarray:
        """
        Design FIR filter based on parameters
        
        Args:
            filter_type: Type of filter ('Low Pass', 'High Pass', 'Band Pass', 'Band Stop')
            num_coeffs: Number of filter coefficients
            cutoff1: First cutoff frequency (normalized)
            cutoff2: Second cutoff frequency (normalized, for band filters)
            window: Window function to use
            
        Returns:
            Filter coefficients as numpy array
        """
        try:
            if filter_type == "Low Pass":
                coeffs = signal.firwin(num_coeffs, cutoff1, window=window)
                
            elif filter_type == "High Pass":
                coeffs = signal.firwin(num_coeffs, cutoff1, window=window, pass_zero=False)
                
            elif filter_type == "Band Pass":
                if cutoff2 is None:
                    cutoff2 = cutoff1 + 0.1
                coeffs = signal.firwin(num_coeffs, [cutoff1, cutoff2], window=window, pass_zero=False)
                
            elif filter_type == "Band Stop":
                if cutoff2 is None:
                    cutoff2 = cutoff1 + 0.1
                coeffs = signal.firwin(num_coeffs, [cutoff1, cutoff2], window=window)
                
            else:
                # Default to low pass
                coeffs = signal.firwin(num_coeffs, cutoff1, window=window)
                
            return coeffs
            
        except Exception:
            # Return default low pass filter on error
            return signal.firwin(51, 0.1, window=window)
    
    @staticmethod
    def calculate_frequency_response(coeffs: np.ndarray, fs: float, num_points: int = 1024) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
        """
        Calculate frequency response of filter
        
        Args:
            coeffs: Filter coefficients
            fs: Sampling frequency
            num_points: Number of frequency points to calculate
            
        Returns:
            Tuple of (frequencies, magnitude_db, phase, h_complex)
        """
        w, h = signal.freqz(coeffs, worN=num_points)
        frequencies = w * fs / (2 * np.pi)
        magnitude_db = 20 * np.log10(np.abs(h) + 1e-12)  # Add small value to avoid log(0)
        phase = np.unwrap(np.angle(h))
        
        return frequencies, magnitude_db, phase, h

class QuantizationUtils:
    """Utilities for quantizing filter coefficients"""
    
    @staticmethod
    def quantize_coefficients(coeffs: np.ndarray, bit_width: int, signed: bool = True) -> Tuple[np.ndarray, np.ndarray, float]:
        """
        Quantize coefficients to fixed-point representation
        
        Args:
            coeffs: Original floating-point coefficients
            bit_width: Number of bits for quantization
            signed: True for signed, False for unsigned quantization
            
        Returns:
            Tuple of (quantized_coeffs, integer_values, scale_factor)
        """
        if bit_width < 1:
            bit_width = 1
        if bit_width > 32:
            bit_width = 32
            
        if signed:
            # Signed quantization: -(2^(n-1)) to (2^(n-1) - 1)
            max_val = 2**(bit_width - 1) - 1
            min_val = -(2**(bit_width - 1))
        else:
            # Unsigned quantization: 0 to (2^n - 1)
            max_val = 2**bit_width - 1
            min_val = 0
        
        # Find the scaling factor to use the full range
        coeff_max = np.max(np.abs(coeffs))
        if coeff_max == 0:
            scale_factor = 1.0
        else:
            if signed:
                scale_factor = max_val / coeff_max
            else:
                # For unsigned, we need to handle negative coefficients
                coeff_min = np.min(coeffs)
                coeff_range = np.max(coeffs) - coeff_min
                if coeff_range == 0:
                    scale_factor = 1.0
                else:
                    scale_factor = max_val / coeff_range
        
        # Scale and quantize
        if signed:
            scaled_coeffs = coeffs * scale_factor
        else:
            # For unsigned, shift to positive range first
            coeff_min = np.min(coeffs)
            shifted_coeffs = coeffs - coeff_min
            scaled_coeffs = shifted_coeffs * scale_factor
        
        # Round to nearest integer and clip to valid range
        integer_values = np.round(scaled_coeffs).astype(np.int32)
        integer_values = np.clip(integer_values, min_val, max_val)
        
        # Convert back to floating point
        if signed:
            quantized_coeffs = integer_values.astype(np.float64) / scale_factor
        else:
            quantized_coeffs = integer_values.astype(np.float64) / scale_factor + coeff_min
        
        return quantized_coeffs, integer_values, scale_factor
    
    @staticmethod
    def format_integer_values(integer_values: np.ndarray, bit_width: int, signed: bool, format_type: str = 'decimal') -> str:
        """
        Format integer values in different representations
        
        Args:
            integer_values: Integer coefficient values
            bit_width: Bit width used for quantization
            signed: Whether values are signed
            format_type: 'decimal', 'hex', 'binary', or 'verilog'
            
        Returns:
            Formatted string representation
        """
        output = []
        
        for i, val in enumerate(integer_values):
            if format_type == 'decimal':
                output.append(f"coeff[{i:2d}] = {val:d}")
                
            elif format_type == 'hex':
                if signed and val < 0:
                    # Two's complement for negative values
                    val_unsigned = (1 << bit_width) + val
                else:
                    val_unsigned = val
                hex_width = (bit_width + 3) // 4  # Round up to nearest hex digit
                output.append(f"coeff[{i:2d}] = 0x{val_unsigned:0{hex_width}X}")
                
            elif format_type == 'binary':
                if signed and val < 0:
                    # Two's complement for negative values
                    val_unsigned = (1 << bit_width) + val
                else:
                    val_unsigned = val
                output.append(f"coeff[{i:2d}] = {val_unsigned:0{bit_width}b}")
                
            elif format_type == 'verilog':
                if signed and val < 0:
                    val_unsigned = (1 << bit_width) + val
                else:
                    val_unsigned = val
                output.append(f"coeff[{i:2d}] = {bit_width}'h{val_unsigned:0{(bit_width+3)//4}X};")
        
        return '\n'.join(output)
    
    @staticmethod
    def calculate_quantization_error(original: np.ndarray, quantized: np.ndarray) -> Tuple[float, float, float]:
        """
        Calculate quantization error metrics
        
        Args:
            original: Original coefficients
            quantized: Quantized coefficients
            
        Returns:
            Tuple of (mse, snr_db, max_error)
        """
        error = original - quantized
        mse = np.mean(error**2)
        
        if mse == 0:
            snr_db = float('inf')
        else:
            signal_power = np.mean(original**2)
            snr_db = 10 * np.log10(signal_power / mse) if signal_power > 0 else 0
        
        max_error = np.max(np.abs(error))
        
        return mse, snr_db, max_error