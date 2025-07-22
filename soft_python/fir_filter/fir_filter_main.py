#!/usr/bin/env python3
"""
FIR Filter Coefficient Generator - Main Application
"""

import customtkinter as ctk
from fir_filter_gui import FIRFilterGUI

def main():
    """Main application entry point"""
    ctk.set_appearance_mode("System")  # Optional: set appearance mode (dark/light/system)
    ctk.set_default_color_theme("blue")  # Optional: set color theme

    root = ctk.CTk()
    app = FIRFilterGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()
##!/usr/bin/env python3
#"""
#FIR Filter Coefficient Generator - Main Application
#"""
#
#import tkinter as tk
#from fir_filter_gui import FIRFilterGUI
#
#def main():
#    """Main application entry point"""
#    root = tk.Tk()
#    app = FIRFilterGUI(root)
#    root.mainloop()
#
#if __name__ == "__main__":
#    main()