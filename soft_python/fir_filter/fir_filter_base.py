import tkinter as tk
from tkinter import ttk
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure
from scipy import signal

class FIRFilterGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("FIR Filter Coefficient Generator")
        self.root.geometry("1000x700")
        
        # Initialize parameters
        self.filter_type = tk.StringVar(value="Low Pass")
        self.num_coeffs = tk.StringVar(value="51")
        self.cutoff1 = tk.StringVar(value="0.1")
        self.cutoff2 = tk.StringVar(value="0.3")
        self.sampling_freq = tk.StringVar(value="1.0")
        
        self.create_widgets()
        self.update_plot()
        
    def create_widgets(self):
        # Main frame
        main_frame = ttk.Frame(self.root)
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Control panel
        control_frame = ttk.LabelFrame(main_frame, text="Filter Parameters", padding="10")
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
        
        # Initially hide cutoff2 for low/high pass filters
        self.update_cutoff_visibility()
        
        # Coefficient display
        coeff_frame = ttk.LabelFrame(main_frame, text="Filter Coefficients", padding="10")
        coeff_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Text widget with scrollbar for coefficients
        text_frame = ttk.Frame(coeff_frame)
        text_frame.pack(fill=tk.X)
        
        self.coeff_text = tk.Text(text_frame, height=6, wrap=tk.WORD)
        scrollbar = ttk.Scrollbar(text_frame, orient=tk.VERTICAL, command=self.coeff_text.yview)
        self.coeff_text.configure(yscrollcommand=scrollbar.set)
        
        self.coeff_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # Plot frame
        plot_frame = ttk.LabelFrame(main_frame, text="Frequency Response", padding="10")
        plot_frame.pack(fill=tk.BOTH, expand=True)
        
        # Create matplotlib figure
        self.fig = Figure(figsize=(12, 6), dpi=100)
        self.ax1 = self.fig.add_subplot(2, 1, 1)
        self.ax2 = self.fig.add_subplot(2, 1, 2)
        
        self.canvas = FigureCanvasTkAgg(self.fig, master=plot_frame)
        self.canvas.draw()
        self.canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)
        
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
        """Called when any parameter changes"""
        self.update_cutoff_visibility()
        self.root.after(100, self.update_plot)  # Delay to avoid too frequent updates
        
    def validate_parameters(self):
        """Validate and return parameters"""
        try:
            num_coeffs = int(self.num_coeffs.get())
            if num_coeffs < 3:
                num_coeffs = 3
            if num_coeffs % 2 == 0:  # Make odd for better filter properties
                num_coeffs += 1
                
            cutoff1 = float(self.cutoff1.get())
            cutoff2 = float(self.cutoff2.get()) if self.filter_type.get() in ["Band Pass", "Band Stop"] else None
            fs = float(self.sampling_freq.get())
            
            # Normalize cutoff frequencies (should be between 0 and 1 for normalized frequency)
            cutoff1 = max(0.001, min(0.499, cutoff1))
            if cutoff2 is not None:
                cutoff2 = max(0.001, min(0.499, cutoff2))
                if cutoff1 >= cutoff2:
                    cutoff1, cutoff2 = cutoff2, cutoff1
                    
            return num_coeffs, cutoff1, cutoff2, fs
            
        except ValueError:
            return 51, 0.1, 0.3, 1.0  # Default values
    
    def design_filter(self):
        """Design FIR filter based on parameters"""
        num_coeffs, cutoff1, cutoff2, fs = self.validate_parameters()
        filter_type = self.filter_type.get()
        
        try:
            if filter_type == "Low Pass":
                coeffs = signal.firwin(num_coeffs, cutoff1, window='hamming')
                
            elif filter_type == "High Pass":
                coeffs = signal.firwin(num_coeffs, cutoff1, window='hamming', pass_zero=False)
                
            elif filter_type == "Band Pass":
                coeffs = signal.firwin(num_coeffs, [cutoff1, cutoff2], window='hamming', pass_zero=False)
                
            elif filter_type == "Band Stop":
                coeffs = signal.firwin(num_coeffs, [cutoff1, cutoff2], window='hamming')
                
            return coeffs, fs
            
        except Exception as e:
            # Return default low pass filter on error
            return signal.firwin(51, 0.1, window='hamming'), 1.0
    
    def update_plot(self):
        """Update the frequency response plot"""
        coeffs, fs = self.design_filter()
        
        # Update coefficient display
        self.coeff_text.delete(1.0, tk.END)
        coeff_str = "Filter Coefficients:\n"
        for i, coeff in enumerate(coeffs):
            coeff_str += f"h[{i:2d}] = {coeff:12.8f}\n"
        self.coeff_text.insert(1.0, coeff_str)
        
        # Calculate frequency response
        w, h = signal.freqz(coeffs, worN=1024)
        frequencies = w * fs / (2 * np.pi)
        magnitude_db = 20 * np.log10(np.abs(h) + 1e-12)  # Add small value to avoid log(0)
        phase = np.unwrap(np.angle(h))
        
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
        num_coeffs, cutoff1, cutoff2, _ = self.validate_parameters()
        cutoff1_hz = cutoff1 * fs / 2
        
        self.ax1.axvline(cutoff1_hz, color='g', linestyle='--', alpha=0.7, label=f'Cutoff 1: {cutoff1_hz:.3f} Hz')
        if cutoff2 is not None:
            cutoff2_hz = cutoff2 * fs / 2
            self.ax1.axvline(cutoff2_hz, color='g', linestyle='--', alpha=0.7, label=f'Cutoff 2: {cutoff2_hz:.3f} Hz')
        
        self.ax1.legend()
        
        self.fig.tight_layout()
        self.canvas.draw()

def main():
    root = tk.Tk()
    app = FIRFilterGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()