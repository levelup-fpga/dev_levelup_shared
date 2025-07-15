"""
Mathematical curve generation functions
"""

import numpy as np

class CurveMath:
    """Class containing all mathematical functions for curve generation"""

    def generate_curve(self, x, curve_params):
        """
        Generate curve based on parameters

        Args:
            x: Input x values (numpy array)
            curve_params: Dictionary containing curve parameters
                - curve_type: Type of curve ('sin', 'sinc', 'square', 'triangle')
                - frequency: Frequency parameter
                - phase: Phase parameter (for sin curve)
                - overshoot: Boolean for overshoot (for square curve)
                - overshoot_harmonics: Number of harmonics for overshoot

        Returns:
            y: Normalized curve values (0-1 range)
        """
        curve_type = curve_params['curve_type']
        frequency = curve_params['frequency']

        if curve_type == "sin":
            y = self._generate_sin(x, frequency, curve_params['phase'])
        elif curve_type == "sinc":
            y = self._generate_sinc(x, frequency)
        elif curve_type == "square":
            y = self._generate_square(x, frequency, curve_params['overshoot'],
                                    curve_params['overshoot_harmonics'])
        elif curve_type == "triangle":
            y = self._generate_triangle(x, frequency)
        else:
            raise ValueError(f"Unknown curve type: {curve_type}")

        return self._normalize_curve(y)

    def _generate_sin(self, x, frequency, phase):
        """Generate sine wave"""
        return np.sin(2 * np.pi * frequency * x + phase)

    def _generate_sinc(self, x, frequency):
        """Generate sinc function: sin(πx)/(πx)"""
        return np.sinc(frequency * x)

    def _generate_square(self, x, frequency, overshoot, overshoot_harmonics):
        """Generate square wave with optional overshoot"""
        if overshoot:
            # Square wave using Fourier series with odd harmonics (Gibbs phenomenon)
            n_terms = overshoot_harmonics
            y = np.zeros_like(x)

            # Sum odd harmonics to create square wave with overshoot
            for n in range(1, n_terms + 1):
                harmonic_order = 2 * n - 1  # Odd harmonics: 1, 3, 5, 7, ...
                y += (4 / np.pi) * (1 / harmonic_order) * np.sin(2 * np.pi * harmonic_order * frequency * x)

            return y
        else:
            # Perfect square wave without overshoot
            return np.sign(np.sin(2 * np.pi * frequency * x))

    def _generate_triangle(self, x, frequency):
        """Generate triangle wave"""
        return 2 * np.abs(2 * (frequency * x - np.floor(frequency * x + 0.5))) - 1

    def _normalize_curve(self, y):
        """Normalize curve to 0-1 range"""
        y_min, y_max = np.min(y), np.max(y)
        if y_max != y_min:
            return (y - y_min) / (y_max - y_min)
        else:
            return np.ones_like(y) * 0.5