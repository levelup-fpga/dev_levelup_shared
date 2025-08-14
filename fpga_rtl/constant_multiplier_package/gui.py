# gui.py
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import subprocess, sys, os
from pathlib import Path

PY = sys.executable
MAIN_PY = Path(__file__).parent / 'main.py'

class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title('Const Mult VHDL Generator')
        self.geometry('820x600')
        self._build_ui()

    def _build_ui(self):
        frm = ttk.Frame(self, padding=12)
        frm.pack(fill=tk.BOTH, expand=True)
        row = 0
        ttk.Label(frm, text='Input width:').grid(column=0, row=row, sticky=tk.W)
        self.in_width = tk.IntVar(value=16)
        cb = ttk.Combobox(frm, textvariable=self.in_width, values=[8,16,32,64], width=6)
        cb.grid(column=1, row=row, sticky=tk.W)
        ttk.Label(frm, text='Constant (decimal):').grid(column=2, row=row, sticky=tk.W, padx=(10,0))
        self.const_val = tk.IntVar(value=301)
        ttk.Entry(frm, textvariable=self.const_val, width=10).grid(column=3, row=row, sticky=tk.W)
        ttk.Label(frm, text='Const width:').grid(column=4, row=row, sticky=tk.W, padx=(10,0))
        self.const_w = tk.IntVar(value=12)
        ttk.Combobox(frm, textvariable=self.const_w, values=list(range(8,17)), width=6).grid(column=5, row=row, sticky=tk.W)
        row += 1
        ttk.Label(frm, text='Pipeline stages:').grid(column=0, row=row, sticky=tk.W, pady=(8,0))
        self.stages = tk.IntVar(value=3)
        ttk.Spinbox(frm, from_=1, to=16, textvariable=self.stages, width=6).grid(column=1, row=row, sticky=tk.W, pady=(8,0))
        ttk.Label(frm, text='Output dir:').grid(column=2, row=row, sticky=tk.W, padx=(10,0))
        self.outdir = tk.StringVar(value=str(Path.cwd() / 'generated'))
        ttk.Entry(frm, textvariable=self.outdir, width=30).grid(column=3, row=row, sticky=tk.W, columnspan=2)
        ttk.Button(frm, text='Browse...', command=self._browse).grid(column=5, row=row, sticky=tk.W)
        row += 1
        ttk.Button(frm, text='Run Generator', command=self._run).grid(column=0, row=row, pady=(12,0))
        ttk.Button(frm, text='Open Output Dir', command=self._open_outdir).grid(column=1, row=row, pady=(12,0))
        row += 1
        ttk.Label(frm, text='Generator output:').grid(column=0, row=row, sticky=tk.W, pady=(12,0))
        row += 1
        self.txt = tk.Text(frm, wrap=tk.NONE, height=22)
        self.txt.grid(column=0, row=row, columnspan=6, sticky='nsew')
        frm.rowconfigure(row, weight=1)
        frm.columnconfigure(3, weight=1)
        xsb = ttk.Scrollbar(frm, orient=tk.HORIZONTAL, command=self.txt.xview)
        xsb.grid(column=0, row=row+1, columnspan=6, sticky='ew')
        ysb = ttk.Scrollbar(frm, orient=tk.VERTICAL, command=self.txt.yview)
        ysb.grid(column=6, row=row, sticky='ns')
        self.txt.configure(xscrollcommand=xsb.set, yscrollcommand=ysb.set)

    def _browse(self):
        d = filedialog.askdirectory(initialdir=str(Path.cwd()))
        if d:
            self.outdir.set(d)

    def _open_outdir(self):
        d = Path(self.outdir.get())
        if not d.exists():
            messagebox.showerror('Folder not found', f'{d} does not exist')
            return
        if sys.platform.startswith('darwin'):
            subprocess.run(['open', d])
        elif os.name == 'nt':
            os.startfile(d)
        else:
            subprocess.run(['xdg-open', d])

    def _run(self):
        cmd = [
            PY, str(MAIN_PY),
            '--in-width', str(self.in_width.get()),
            '--const', str(self.const_val.get()),
            '--const-width', str(self.const_w.get()),
            '--stages', str(self.stages.get()),
            '--outdir', str(self.outdir.get())
        ]
        self.txt.delete(1.0, tk.END)
        self.txt.insert(tk.END, 'Running: ' + ' '.join(cmd) + '\\n\\n')
        self.update()
        try:
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        except Exception as e:
            self.txt.insert(tk.END, 'Failed to start generator: ' + str(e) + '\\n')
            return
        for line in proc.stdout:
            self.txt.insert(tk.END, line)
            self.txt.see(tk.END)
            self.update()
        proc.wait()
        self.txt.insert(tk.END, f'\\nProcess exited with code {proc.returncode}\\n')
        self.txt.see(tk.END)

if __name__ == '__main__':
    App().mainloop()
