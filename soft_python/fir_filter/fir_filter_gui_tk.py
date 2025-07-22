"""
FIR Filter Coefficient Generator - Main GUI Implementation
"""

import tkinter as tk
from tkinter import ttk, messagebox
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure

from fir_filter_math import FilterDesigner, QuantizationUtils
from fir_filter_file import FilterFileManager

class FIRFilterGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("FIR Filter Coefficient Generator")
        self.root.geometry("1200x800")

        # Initialize filter designer and file manager
        self.filter_designer = FilterDesigner()
        self.file_manager = FilterFileManager()

        # Initialize parameters
        self.filter_type = tk.StringVar(value="Low Pass")
        self.num_coeffs = tk.StringVar(value="51")
        self.cutoff1 = tk.StringVar(value="0.1")
        self.cutoff2 = tk.StringVar(value="0.3")
        self.sampling_freq = tk.StringVar(value="1.0")

        # Quantization parameters
        self.bit_width = tk.StringVar(value="16")
        self.signed_var = tk.BooleanVar(value=True)
        self.quantization_enabled = tk.BooleanVar(value=False)
        self.export_format = tk.StringVar(value="decimal")

        # Current coefficients
        self.current_coeffs = None
        self.current_quantized_coeffs = None
        self.current_integer_values = None
        self.current_scale_factor = None

        self.create_widgets()
        self.update_plot()

    def create_widgets(self):
        """Create all GUI widgets"""
        # Main frame with notebook for tabs
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

        # Create notebook for tabs
        self.notebook = ttk.Notebook(main_frame)
        self.notebook.pack(fill=tk.BOTH, expand=True)

        # Filter Design Tab
        self.design_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.design_frame, text="Filter Design")

        # Quantization Tab
        self.quantization_frame = ttk.Frame(self.notebook)
        self.notebook.add(self.quantization_frame, text="Quantization")

        self.create_design_tab()
        self.create_quantization_tab()

        # Bind tab change event
        self.notebook.bind("<<NotebookTabChanged>>", self.on_tab_changed)

    def create_design_tab(self):
        """Create filter design tab"""
        # Control panel
        control_frame = ttk.LabelFrame(self.design_frame, text="Filter Parameters", padding="10")
        control_frame.pack(fill=tk.X, pady=(0, 10))

        # Filter type dropdown
        ttk.Label(control_frame, text="Filter Type:").grid(row=0, column=0, sticky=tk.W, padx=(0, 10))
        filter_combo = ttk.Combobox(control_frame, textvariable=self.filter_type,
                                   values=["Low Pass", "High Pass", "Band Pass", "Band Stop"],
                                   state="readonly", width=15)
        filter_combo.grid(row=0, column=1, padx=(0, 20))
        filter_combo.bind('<<ComboboxSelected>>', self.on_parameter_change)

        # Number of coefficients
        ttk.Label(control_frame, text="Number of Coefficients:").grid(row=0, column=2, sticky=tk.W, padx=(0, 10))
        coeffs_entry = ttk.Entry(control_frame, textvariable=self.num_coeffs, width=10)
        coeffs_entry.grid(row=0, column=3, padx=(0, 20))
        coeffs_entry.bind('<KeyRelease>', self.on_parameter_change)

        # Sampling frequency
        ttk.Label(control_frame, text="Sampling Freq (Hz):").grid(row=0, column=4, sticky=tk.W, padx=(0, 10))
        fs_entry = ttk.Entry(control_frame, textvariable=self.sampling_freq, width=10)
        fs_entry.grid(row=0, column=5)
        fs_entry.bind('<KeyRelease>', self.on_parameter_change)

        # Cutoff frequencies
        ttk.Label(control_frame, text="Cutoff 1 (normalized):").grid(row=1, column=0, sticky=tk.W, padx=(0, 10), pady=(10, 0))
        cutoff1_entry = ttk.Entry(control_frame, textvariable=self.cutoff1, width=15)
        cutoff1_entry.grid(row=1, column=1, pady=(10, 0), padx=(0, 20))
        cutoff1_entry.bind('<KeyRelease>', self.on_parameter_change)

        self.cutoff2_label = ttk.Label(control_frame, text="Cutoff 2 (normalized):")
        self.cutoff2_label.grid(row=1, column=2, sticky=tk.W, padx=(0, 10), pady=(10, 0))
        self.cutoff2_entry = ttk.Entry(control_frame, textvariable=self.cutoff2, width=15)
        self.cutoff2_entry.grid(row=1, column=3, pady=(10, 0), padx=(0, 20))
        self.cutoff2_entry.bind('<KeyRelease>', self.on_parameter_change)

        # File operations
        file_frame = ttk.Frame(control_frame)
        file_frame.grid(row=1, column=4, columnspan=2, pady=(10, 0), sticky=tk.E)

        ttk.Button(file_frame, text="Save Config", command=self.save_config, width=12).pack(side=tk.LEFT, padx=(0, 5))
        ttk.Button(file_frame, text="Load Config", command=self.load_config, width=12).pack(side=tk.LEFT)

        # Initially hide cutoff2 for low/high pass filters
        self.update_cutoff_visibility()

        # Coefficient display
        coeff_frame = ttk.LabelFrame(self.design_frame, text="Filter Coefficients", padding="10")
        coeff_frame.pack(fill=tk.X, pady=(0, 10))

        # Text widget with scrollbar for coefficients
        text_frame = ttk.Frame(coeff_frame)
        text_frame.pack(fill=tk.X)

        self.coeff_text = tk.Text(text_frame, height=6, wrap=tk.WORD, font=('Consolas', 10))
        scrollbar = ttk.Scrollbar(text_frame, orient=tk.VERTICAL, command=self.coeff_text.yview)
        self.coeff_text.configure(yscrollcommand=scrollbar.set)

        self.coeff_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        # Plot frame
        plot_frame = ttk.LabelFrame(self.design_frame, text="Frequency Response", padding="10")
        plot_frame.pack(fill=tk.BOTH, expand=True)

        # Create matplotlib figure
        self.fig = Figure(figsize=(12, 6), dpi=100)
        self.ax1 = self.fig.add_subplot(2, 1, 1)
        self.ax2 = self.fig.add_subplot(2, 1, 2)

        self.canvas = FigureCanvasTkAgg(self.fig, master=plot_frame)
        self.canvas.draw()
        self.canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)

    def create_quantization_tab(self):
        """Create quantization tab"""
        # Quantization control panel
        quant_control_frame = ttk.LabelFrame(self.quantization_frame, text="Quantization Parameters", padding="10")
        quant_control_frame.pack(fill=tk.X, pady=(0, 10))

        # Enable quantization checkbox
        ttk.Checkbutton(quant_control_frame, text="Enable Quantization",
                       variable=self.quantization_enabled,
                       command=self.on_quantization_change).grid(row=0, column=0, sticky=tk.W, padx=(0, 20))

        # Bit width
        ttk.Label(quant_control_frame, text="Bit Width:").grid(row=0, column=1, sticky=tk.W, padx=(0, 10))
        bit_width_spin = ttk.Spinbox(quant_control_frame, textvariable=self.bit_width,
                                    from_=1, to=32, width=8)
        bit_width_spin.grid(row=0, column=2, padx=(0, 20))
        bit_width_spin.bind('<KeyRelease>', self.on_quantization_change)
        bit_width_spin.bind('<<Increment>>', self.on_quantization_change)
        bit_width_spin.bind('<<Decrement>>', self.on_quantization_change)

        # Signed/Unsigned
        ttk.Checkbutton(quant_control_frame, text="Signed",
                       variable=self.signed_var,
                       command=self.on_quantization_change).grid(row=0, column=3, sticky=tk.W, padx=(0, 20))

        # Export format
        ttk.Label(quant_control_frame, text="Display Format:").grid(row=1, column=0, sticky=tk.W, padx=(0, 10), pady=(10, 0))
        format_combo = ttk.Combobox(quant_control_frame, textvariable=self.export_format,
                                   values=["decimal", "hex", "binary", "verilog"],
                                   state="readonly", width=12)
        format_combo.grid(row=1, column=1, columnspan=2, pady=(10, 0), sticky=tk.W)
        format_combo.bind('<<ComboboxSelected>>', self.on_quantization_change)

        # Export buttons
        export_frame = ttk.Frame(quant_control_frame)
        export_frame.grid(row=1, column=3, columnspan=2, pady=(10, 0), sticky=tk.E)

        ttk.Button(export_frame, text="Export C", command=lambda: self.export_coeffs("c_array"), width=10).pack(side=tk.LEFT, padx=(0, 5))
        ttk.Button(export_frame, text="Export MATLAB", command=lambda: self.export_coeffs("matlab"), width=12).pack(side=tk.LEFT, padx=(0, 5))
        ttk.Button(export_frame, text="Export Verilog", command=lambda: self.export_coeffs("verilog"), width=12).pack(side=tk.LEFT)

        # Quantization info frame
        info_frame = ttk.LabelFrame(self.quantization_frame, text="Quantization Information", padding="10")
        info_frame.pack(fill=tk.X, pady=(0, 10))

        self.info_text = tk.Text(info_frame, height=4, wrap=tk.WORD, font=('Consolas', 10))
        info_scrollbar = ttk.Scrollbar(info_frame, orient=tk.VERTICAL, command=self.info_text.yview)
        self.info_text.configure(yscrollcommand=info_scrollbar.set)

        self.info_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        info_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        # Quantized coefficient display
        quant_coeff_frame = ttk.LabelFrame(self.quantization_frame, text="Quantized Coefficients", padding="10")
        quant_coeff_frame.pack(fill=tk.BOTH, expand=True)

        self.quant_coeff_text = tk.Text(quant_coeff_frame, wrap=tk.WORD, font=('Consolas', 9))
        quant_scrollbar = ttk.Scrollbar(quant_coeff_frame, orient=tk.VERTICAL, command=self.quant_coeff_text.yview)
        self.quant_coeff_text.configure(yscrollcommand=quant_scrollbar.set)

        self.quant_coeff_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        quant_scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

    def update_cutoff_visibility(self):
        """Show/hide second cutoff frequency based on filter type"""
        filter_type = self.filter_type.get()
        if filter_type in ["Band Pass", "Band Stop"]:
            self.cutoff2_label.grid()
            self.cutoff2_entry.grid()
        else:
            self.cutoff2_label.grid_remove()
            self.cutoff2_entry.grid_remove()

    def on_parameter_change(self, event=None):
        """Called when any filter parameter changes"""
        self.update_cutoff_visibility()
        self.root.after(100, self.update_plot)  # Delay to avoid too frequent updates

    def on_quantization_change(self, event=None):
        """Called when quantization parameters change"""
        self.root.after(100, self.update_quantization)

    def on_tab_changed(self, event=None):
        """Called when tab changes"""
        if self.notebook.tab(self.notebook.select(), "text") == "Quantization":
            self.update_quantization()

    def update_plot(self):
        """Update the frequency response plot"""
        # Get validated parameters
        num_coeffs, cutoff1, cutoff2, fs = self.filter_designer.validate_parameters(
            self.num_coeffs.get(), self.cutoff1.get(), self.cutoff2.get(), self.sampling_freq.get()
        )

        # Design filter
        self.current_coeffs = self.filter_designer.design_filter(
            self.filter_type.get(), num_coeffs, cutoff1, cutoff2
        )

        # Update coefficient display
        self.coeff_text.delete(1.0, tk.END)
        coeff_str = f"Filter Coefficients (Length: {len(self.current_coeffs)}):\n"
        for i, coeff in enumerate(self.current_coeffs):
            coeff_str += f"h[{i:2d}] = {coeff:12.8f}\n"
        self.coeff_text.insert(1.0, coeff_str)

        # Calculate frequency response
        frequencies, magnitude_db, phase, _ = self.filter_designer.calculate_frequency_response(
            self.current_coeffs, fs
        )

        # Clear and plot magnitude response
        self.ax1.clear()
        self.ax1.plot(frequencies, magnitude_db, 'b-', linewidth=2)
        self.ax1.set_xlabel('Frequency (Hz)')
        self.ax1.set_ylabel('Magnitude (dB)')
        self.ax1.set_title(f'{self.filter_type.get()} Filter - Frequency Response')
        self.ax1.grid(True, alpha=0.3)
        self.ax1.set_xlim(0, fs/2)

        # Plot phase response
        self.ax2.clear()
        self.ax2.plot(frequencies, phase, 'r-', linewidth=2)
        self.ax2.set_xlabel('Frequency (Hz)')
        self.ax2.set_ylabel('Phase (radians)')
        self.ax2.set_title('Phase Response')
        self.ax2.grid(True, alpha=0.3)
        self.ax2.set_xlim(0, fs/2)

        # Add cutoff frequency indicators
        cutoff1_hz = cutoff1 * fs / 2
        self.ax1.axvline(cutoff1_hz, color='g', linestyle='--', alpha=0.7, label=f'Cutoff 1: {cutoff1_hz:.3f} Hz')
        if cutoff2 is not None:
            cutoff2_hz = cutoff2 * fs / 2
            self.ax1.axvline(cutoff2_hz, color='g', linestyle='--', alpha=0.7, label=f'Cutoff 2: {cutoff2_hz:.3f} Hz')

        self.ax1.legend()

        self.fig.tight_layout()
        self.canvas.draw()

        # Update quantization if enabled
        if self.quantization_enabled.get():
            self.update_quantization()

    def update_quantization(self):
        """Update quantization display"""
        if self.current_coeffs is None:
            return

        if not self.quantization_enabled.get():
            self.info_text.delete(1.0, tk.END)
            self.info_text.insert(1.0, "Quantization disabled")
            self.quant_coeff_text.delete(1.0, tk.END)
            self.quant_coeff_text.insert(1.0, "Enable quantization to see quantized coefficients")
            return

        try:
            bit_width = int(self.bit_width.get())
            signed = self.signed_var.get()

            # Quantize coefficients
            self.current_quantized_coeffs, self.current_integer_values, self.current_scale_factor = \
                QuantizationUtils.quantize_coefficients(self.current_coeffs, bit_width, signed)

            # Calculate quantization error
            mse, snr_db, max_error = QuantizationUtils.calculate_quantization_error(
                self.current_coeffs, self.current_quantized_coeffs
            )

            # Update info display
            self.info_text.delete(1.0, tk.END)
            info_str = f"Quantization Info:\n"
            info_str += f"Bit Width: {bit_width}, Signed: {signed}\n"
            info_str += f"Scale Factor: {self.current_scale_factor:.6f}\n"
            info_str += f"MSE: {mse:.2e}, SNR: {snr_db:.2f} dB, Max Error: {max_error:.6f}"
            self.info_text.insert(1.0, info_str)

            # Update quantized coefficients display
            self.quant_coeff_text.delete(1.0, tk.END)
            format_type = self.export_format.get()

            if format_type == "decimal":
                formatted_coeffs = QuantizationUtils.format_integer_values(
                    self.current_integer_values, bit_width, signed, "decimal"
                )
            elif format_type == "hex":
                formatted_coeffs = QuantizationUtils.format_integer_values(
                    self.current_integer_values, bit_width, signed, "hex"
                )
            elif format_type == "binary":
                formatted_coeffs = QuantizationUtils.format_integer_values(
                    self.current_integer_values, bit_width, signed, "binary"
                )
            elif format_type == "verilog":
                formatted_coeffs = QuantizationUtils.format_integer_values(
                    self.current_integer_values, bit_width, signed, "verilog"
                )

            self.quant_coeff_text.insert(1.0, f"Quantized Coefficients ({format_type} format):\n\n{formatted_coeffs}")

        except ValueError:
            self.info_text.delete(1.0, tk.END)
            self.info_text.insert(1.0, "Invalid quantization parameters")
            self.quant_coeff_text.delete(1.0, tk.END)
            self.quant_coeff_text.insert(1.0, "Fix quantization parameters")

    def save_config(self):
        """Save filter configuration"""
        if self.current_coeffs is None:
            messagebox.showwarning("Warning", "No filter coefficients to save")
            return

        filter_params = {
            "filter_type": self.filter_type.get(),
            "num_coeffs": self.num_coeffs.get(),
            "cutoff1": self.cutoff1.get(),
            "cutoff2": self.cutoff2.get(),
            "sampling_freq": self.sampling_freq.get()
        }

        quantization_params = None
        if self.quantization_enabled.get() and self.current_integer_values is not None:
            quantization_params = {
                "enabled": True,
                "bit_width": int(self.bit_width.get()),
                "signed": self.signed_var.get(),
                "scale_factor": self.current_scale_factor
            }

        self.file_manager.save_filter_config(
            filter_params, self.current_coeffs,
            self.current_quantized_coeffs, self.current_integer_values, quantization_params
        )

    def load_config(self):
        """Load filter configuration"""
        result = self.file_manager.load_filter_config()
        if result is None:
            return

        filter_params, coeffs, quantization_data = result

        # Update GUI parameters
        if "filter_type" in filter_params:
            self.filter_type.set(filter_params["filter_type"])
        if "num_coeffs" in filter_params:
            self.num_coeffs.set(filter_params["num_coeffs"])
        if "cutoff1" in filter_params:
            self.cutoff1.set(filter_params["cutoff1"])
        if "cutoff2" in filter_params:
            self.cutoff2.set(filter_params["cutoff2"])
        if "sampling_freq" in filter_params:
            self.sampling_freq.set(filter_params["sampling_freq"])

        # Load quantization data if available
        if quantization_data and quantization_data.get("quantization_parameters"):
            quant_params = quantization_data["quantization_parameters"]
            self.quantization_enabled.set(quant_params.get("enabled", False))
            self.bit_width.set(str(quant_params.get("bit_width", 16)))
            self.signed_var.set(quant_params.get("signed", True))

            self.current_quantized_coeffs = np.array(quantization_data["floating_point"])
            self.current_integer_values = np.array(quantization_data["integer_values"])
            self.current_scale_factor = quant_params.get("scale_factor", 1.0)

        # Update display
        self.update_plot()

    def export_coeffs(self, format_type):
        """Export coefficients in specified format"""
        if self.current_coeffs is None:
            messagebox.showwarning("Warning", "No filter coefficients to export")
            return

        try:
            bit_width = int(self.bit_width.get()) if self.quantization_enabled.get() else 16
            signed = self.signed_var.get()

            integer_values = self.current_integer_values if self.quantization_enabled.get() else None

            self.file_manager.export_coefficients(
                self.current_coeffs, format_type, integer_values, bit_width, signed
            )
        except ValueError:
            messagebox.showerror("Error", "Invalid bit width parameter")