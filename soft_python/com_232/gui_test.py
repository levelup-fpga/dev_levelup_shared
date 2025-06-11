##-----------------------------------------------------------------------------
##  Compagny    : levelup-fpga-design
##  Author      : gvr
##  Created     : 10/06/2025
##
##  Copyright (c) 2025 levelup-fpga-design
##
##  This file is part of the levelup-fpga-design distibuted sources.
##
##  License:
##    - Free to use, modify, and distribute for **non-commercial** purposes.
##    - For **commercial** use, you must obtain a license by contacting:
##        contact@levelup-fpga.fr or directly at gvanroyen@levelup-fpga.fr
##
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
##  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
##  DEALINGS IN THE SOFTWARE.
##-----------------------------------------------------------------------------

import tkinter as tk
from tkinter import messagebox

class App(tk.Tk):
    def __init__(self):
        super().__init__()

        self.title("Advanced Tkinter GUI")
        self.geometry("400x300")

        # Menu
        menubar = tk.Menu(self)
        filemenu = tk.Menu(menubar, tearoff=0)
        filemenu.add_command(label="Exit", command=self.quit)
        menubar.add_cascade(label="File", menu=filemenu)
        self.config(menu=menubar)

        # Container for multiple frames
        self.container = tk.Frame(self)
        self.container.pack(fill="both", expand=True)

        # Dictionary to keep track of frames
        self.frames = {}
        for F in (HomePage, FormPage):
            frame = F(parent=self.container, controller=self)
            self.frames[F] = frame
            frame.grid(row=0, column=0, sticky="nsew")

        self.show_frame(HomePage)

    def show_frame(self, page_class):
        frame = self.frames[page_class]
        frame.tkraise()

# Home Page Frame
class HomePage(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller

        label = tk.Label(self, text="Welcome to the Home Page", font=("Helvetica", 16))
        label.pack(pady=20)

        go_button = tk.Button(self, text="Go to Form", command=lambda: controller.show_frame(FormPage))
        go_button.pack()

# Form Page Frame
class FormPage(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller

        tk.Label(self, text="User Form", font=("Helvetica", 14)).grid(row=0, column=0, columnspan=2, pady=10)

        tk.Label(self, text="Name:").grid(row=1, column=0, sticky="e")
        self.name_entry = tk.Entry(self)
        self.name_entry.grid(row=1, column=1, padx=10)

        tk.Label(self, text="Age:").grid(row=2, column=0, sticky="e")
        self.age_entry = tk.Entry(self)
        self.age_entry.grid(row=2, column=1, padx=10)

        submit_btn = tk.Button(self, text="Submit", command=self.submit_form)
        submit_btn.grid(row=3, column=0, columnspan=2, pady=10)

        back_btn = tk.Button(self, text="Back to Home", command=lambda: controller.show_frame(HomePage))
        back_btn.grid(row=4, column=0, columnspan=2)

    def submit_form(self):
        name = self.name_entry.get()
        age = self.age_entry.get()
        if name and age:
            messagebox.showinfo("Form Submitted", f"Hello {name}, age {age}!")
        else:
            messagebox.showwarning("Incomplete", "Please fill in all fields.")

# Run the app
if __name__ == "__main__":
    app = App()
    app.mainloop()