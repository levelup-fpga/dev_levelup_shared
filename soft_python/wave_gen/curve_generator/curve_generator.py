"""
Interactive Curve Generator - Main GUI Class
"""

import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure
import os
import datetime

from curve_math import CurveMath
from file_handlers import FileHandler

class CurveGenerator:
    def __init__(self, root):
        self.root = root
        self.root.title("Interactive Curve Generator")
        self.root.geometry("1000x700")

        # Initialize variables
        self.curve_type = tk.StringVar(value="sin")
        self.x_start = tk.DoubleVar(value=0.0)
        self.x_stop = tk.DoubleVar(value=10.0)
        self.frequency = tk.DoubleVar(value=1.0)
        self.phase = tk.DoubleVar(value=0.0)
        self.overshoot = tk.BooleanVar(value=False)
        self.overshoot_harmonics = tk.IntVar(value=3)
        self.num_samples = tk.IntVar(value=100)
        self.y_bottom = tk.DoubleVar(value=0.0)
        self.y_top = tk.DoubleVar(value=1.0)
        self.is_virtual_zoom = False  # Track if we're using virtual zoom
        self.output_format = tk.StringVar(value="txt")
        self.bit_range = tk.IntVar(value=8)

        # Initialize math and file handler
        self.curve_math = CurveMath()
        self.file_handler = FileHandler()

        self.setup_ui()
        self.update_plot()

    def setup_ui(self):
        # Main frame
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # Control panel
        control_frame = ttk.LabelFrame(main_frame, text="Controls", padding=10)
        control_frame.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 10))

        # Curve type selection
        ttk.Label(control_frame, text="Curve Type:").pack(anchor=tk.W)
        self.curve_combo = ttk.Combobox(control_frame, textvariable=self.curve_type,
                                       values=["sin", "sinc", "square", "triangle"],
                                       state="readonly", width=15)
        self.curve_combo.pack(pady=(0, 10))
        self.curve_combo.bind("<<ComboboxSelected>>", self.on_curve_change)

        # X-axis range
        ttk.Label(control_frame, text="X-axis Range:").pack(anchor=tk.W)
        x_frame = ttk.Frame(control_frame)
        x_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Label(x_frame, text="Start:").pack(side=tk.LEFT)
        self.x_start_entry = ttk.Entry(x_frame, textvariable=self.x_start, width=8)
        self.x_start_entry.pack(side=tk.LEFT, padx=(5, 10))
        self.x_start_entry.bind("<KeyRelease>", self.on_parameter_change)

        ttk.Label(x_frame, text="Stop:").pack(side=tk.LEFT)
        self.x_stop_entry = ttk.Entry(x_frame, textvariable=self.x_stop, width=8)
        self.x_stop_entry.pack(side=tk.LEFT, padx=(5, 0))
        self.x_stop_entry.bind("<KeyRelease>", self.on_parameter_change)

        # Frequency
        ttk.Label(control_frame, text="Frequency:").pack(anchor=tk.W)
        self.freq_entry = ttk.Entry(control_frame, textvariable=self.frequency, width=15)
        self.freq_entry.pack(pady=(0, 10))
        self.freq_entry.bind("<KeyRelease>", self.on_parameter_change)

        # Y-axis range (virtual zoom)
        ttk.Label(control_frame, text="Y-axis Range (Zoom):").pack(anchor=tk.W)
        y_frame = ttk.Frame(control_frame)
        y_frame.pack(fill=tk.X, pady=(0, 10))

        ttk.Label(y_frame, text="Bottom:").pack(side=tk.LEFT)
        self.y_bottom_entry = ttk.Entry(y_frame, textvariable=self.y_bottom, width=6)
        self.y_bottom_entry.pack(side=tk.LEFT, padx=(5, 10))
        self.y_bottom_entry.bind("<KeyRelease>", self.on_parameter_change)

        ttk.Label(y_frame, text="Top:").pack(side=tk.LEFT)
        self.y_top_entry = ttk.Entry(y_frame, textvariable=self.y_top, width=6)
        self.y_top_entry.pack(side=tk.LEFT, padx=(5, 0))
        self.y_top_entry.bind("<KeyRelease>", self.on_parameter_change)

        # Phase (only for sin)
        ttk.Label(control_frame, text="Phase:").pack(anchor=tk.W)
        self.phase_entry = ttk.Entry(control_frame, textvariable=self.phase, width=15)
        self.phase_entry.pack(pady=(0, 10))
        self.phase_entry.bind("<KeyRelease>", self.on_parameter_change)

        # Overshoot (only for square)
        self.overshoot_check = ttk.Checkbutton(control_frame, text="Overshoot",
                                              variable=self.overshoot,
                                              command=self.on_overshoot_change)
        self.overshoot_check.pack(anchor=tk.W, pady=(0, 5))

        # Overshoot harmonics (only for square)
        ttk.Label(control_frame, text="Overshoot Harmonics:").pack(anchor=tk.W)
        self.harmonics_entry = ttk.Entry(control_frame, textvariable=self.overshoot_harmonics, width=15)
        self.harmonics_entry.pack(pady=(0, 10))
        self.harmonics_entry.bind("<KeyRelease>", self.on_parameter_change)

        # Sampling section
        sampling_frame = ttk.LabelFrame(control_frame, text="Sampling", padding=5)
        sampling_frame.pack(fill=tk.X, pady=(10, 0))

        ttk.Label(sampling_frame, text="Number of Samples:").pack(anchor=tk.W)
        ttk.Entry(sampling_frame, textvariable=self.num_samples, width=15).pack(pady=(0, 5))

        # Output format selection
        ttk.Label(sampling_frame, text="Output Format:").pack(anchor=tk.W)
        format_frame = ttk.Frame(sampling_frame)
        format_frame.pack(fill=tk.X, pady=(0, 5))

        ttk.Radiobutton(format_frame, text="TXT", variable=self.output_format,
                       value="txt", command=self.on_format_change).pack(side=tk.LEFT)
        ttk.Radiobutton(format_frame, text="VHDL", variable=self.output_format,
                       value="vhd", command=self.on_format_change).pack(side=tk.LEFT, padx=(10, 0))

        # Bit range for VHDL
        bit_frame = ttk.Frame(sampling_frame)
        bit_frame.pack(fill=tk.X, pady=(0, 5))

        ttk.Label(bit_frame, text="Bit Range:").pack(side=tk.LEFT)
        self.bit_range_entry = ttk.Entry(bit_frame, textvariable=self.bit_range, width=8)
        self.bit_range_entry.pack(side=tk.LEFT, padx=(5, 0))

        ttk.Button(sampling_frame, text="Save Samples", command=self.save_samples).pack(fill=tk.X)

        # Plot frame
        plot_frame = ttk.Frame(main_frame)
        plot_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)

        # Create matplotlib figure
        self.fig = Figure(figsize=(8, 6), dpi=100)
        self.ax = self.fig.add_subplot(111)
        self.canvas = FigureCanvasTkAgg(self.fig, plot_frame)
        self.canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)

        # Update parameter states
        self.update_parameter_states()
        self.update_format_states()

    def on_curve_change(self, event=None):
        self.update_parameter_states()
        self.update_plot()

    def on_format_change(self):
        self.update_format_states()

    def update_format_states(self):
        """Enable/disable bit range entry based on output format"""
        if self.output_format.get() == "vhd":
            self.bit_range_entry.config(state="normal")
        else:
            self.bit_range_entry.config(state="disabled")

    def on_overshoot_change(self):
        self.update_parameter_states()
        self.update_plot()

    def on_parameter_change(self, event=None):
        self.update_plot()

    def apply_virtual_zoom(self, y_real):
        """Apply virtual zoom transformation to real Y values"""
        y_bottom = self.y_bottom.get()
        y_top = self.y_top.get()

        if y_top <= y_bottom:
            return y_real

        # Check if we're using virtual zoom
        self.is_virtual_zoom = not (y_bottom == 0.0 and y_top == 1.0)

        if self.is_virtual_zoom:
            # Map the range [y_bottom, y_top] to [0.0, 1.0]
            y_virtual = (y_real - y_bottom) / (y_top - y_bottom)
            # Clamp values to [0.0, 1.0] range
            y_virtual = np.clip(y_virtual, 0.0, 1.0)
            return y_virtual
        else:
            return y_real

    def update_parameter_states(self):
        curve = self.curve_type.get()

        # Phase only for sin
        if curve == "sin":
            self.phase_entry.config(state="normal")
        else:
            self.phase_entry.config(state="disabled")

        # Overshoot only for square
        if curve == "square":
            self.overshoot_check.config(state="normal")
            if self.overshoot.get():
                self.harmonics_entry.config(state="normal")
            else:
                self.harmonics_entry.config(state="disabled")
        else:
            self.overshoot_check.config(state="disabled")
            self.harmonics_entry.config(state="disabled")

    def generate_curve(self, x):
        """Generate curve using CurveMath class"""
        curve_params = {
            'curve_type': self.curve_type.get(),
            'frequency': self.frequency.get(),
            'phase': self.phase.get(),
            'overshoot': self.overshoot.get(),
            'overshoot_harmonics': self.overshoot_harmonics.get()
        }
        return self.curve_math.generate_curve(x, curve_params)

    def update_plot(self):
        try:
            x_start = self.x_start.get()
            x_stop = self.x_stop.get()
            y_bottom = self.y_bottom.get()
            y_top = self.y_top.get()

            if x_stop <= x_start or y_top <= y_bottom:
                return

            # Generate high-resolution curve for display
            x = np.linspace(x_start, x_stop, 1000)
            y_real = self.generate_curve(x)

            # Apply virtual zoom transformation
            y_display = self.apply_virtual_zoom(y_real)

            # Clear and plot
            self.ax.clear()
            self.ax.plot(x, y_display, 'b-', linewidth=2)
            self.ax.set_xlabel('X')

            # Set Y-axis label based on zoom state
            if self.is_virtual_zoom:
                self.ax.set_ylabel('Y_virtual')
            else:
                self.ax.set_ylabel('Y_real')

            self.ax.set_title(f'{self.curve_type.get().title()} Curve')
            self.ax.grid(True, alpha=0.3)

            # Always display Y-axis from 0.0 to 1.0
            self.ax.set_ylim(0.0, 1.0)

            # Show sample points if reasonable number
            if self.num_samples.get() <= 200:
                x_samples = np.linspace(x_start, x_stop, self.num_samples.get())
                y_samples_real = self.generate_curve(x_samples)
                y_samples_display = self.apply_virtual_zoom(y_samples_real)

                # Only show sample points that are within the 0.0-1.0 range after transformation
                visible_mask = (y_samples_display >= 0.0) & (y_samples_display <= 1.0)
                if np.any(visible_mask):
                    self.ax.plot(x_samples[visible_mask], y_samples_display[visible_mask], 'ro', markersize=3, alpha=0.7)

            self.canvas.draw()

        except (ValueError, tk.TclError):
            # Handle invalid input gracefully
            pass

    def save_samples(self):
        try:
            x_start = self.x_start.get()
            x_stop = self.x_stop.get()
            num_samples = self.num_samples.get()
            bit_range = self.bit_range.get()

            if x_stop <= x_start or num_samples <= 0:
                messagebox.showerror("Error", "Invalid parameters for sampling")
                return

            if self.output_format.get() == "vhd" and (bit_range <= 0 or bit_range > 32):
                messagebox.showerror("Error", "Bit range must be between 1 and 32")
                return

            # Generate sample points
            x_samples = np.linspace(x_start, x_stop, num_samples)
            y_samples_real = self.generate_curve(x_samples)

            # Apply virtual zoom transformation to match displayed data
            y_samples_display = self.apply_virtual_zoom(y_samples_real)

            # Convert to float128 for maximum precision
            y_samples_display = y_samples_display.astype(np.float128)

            # Determine file extension and filter
            if self.output_format.get() == "vhd":
                default_ext = ".vhd"
                file_types = [("VHDL files", "*.vhd"), ("All files", "*.*")]
            else:
                default_ext = ".txt"
                file_types = [("Text files", "*.txt"), ("All files", "*.*")]

            # Get current timestamp
            current_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

            # Create prefilled filename based on file type
            if default_ext == ".vhd":
                prefilled_filename = f"{current_time}_{num_samples}_{bit_range}.vhd"
            elif default_ext == ".txt":
                prefilled_filename = f"{current_time}_{num_samples}.txt"
            else:
                # Fallback for other extensions
                prefilled_filename = f"{current_time}_{num_samples}_{bit_range}{default_ext}"

            # Ask for save location with prefilled filename
            filename = filedialog.asksaveasfilename(
                defaultextension=default_ext,
                filetypes=file_types,
                title="Save Samples",
                initialvalue=prefilled_filename
            )

            if filename:
                # Prepare data for file handler
                save_data = {
                    'y_samples_display': y_samples_display,
                    'num_samples': num_samples,
                    'bit_range': bit_range,
                    'is_virtual_zoom': self.is_virtual_zoom,
                    'y_bottom': self.y_bottom.get(),
                    'y_top': self.y_top.get(),
                    'curve_type': self.curve_type.get()
                }

                if self.output_format.get() == "vhd":
                    self.file_handler.save_samples_vhdl(filename, save_data)
                    format_info = f" as VHDL ({bit_range}-bit)"
                else:
                    self.file_handler.save_samples_txt(filename, save_data)
                    format_info = " as TXT"

                zoom_info = " (virtual zoom applied)" if self.is_virtual_zoom else " (real values)"
                messagebox.showinfo("Success", f"Saved {num_samples} samples{format_info}{zoom_info} to {os.path.basename(filename)}")

        except Exception as e:
            messagebox.showerror("Error", f"Failed to save samples: {str(e)}")