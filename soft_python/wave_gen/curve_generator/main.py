"""
Interactive Curve Generator - Main Application Entry Point
"""

import tkinter as tk
from curve_generator import CurveGenerator

def main():
    root = tk.Tk()
    app = CurveGenerator(root)
    root.mainloop()

if __name__ == "__main__":
    main()
