Constant Multiplier Generator Package

Contents:
- main.py
- explore_mult.py
- gen_vhdl.py
- gui.py
- examples/ (generated outputs for example configurations)
- README.txt (this file)
- README.pdf (same info in PDF)

Dependencies:
- Python 3.8+
- graphviz system package (for rendering SVG diagrams)
  - Debian/Ubuntu: sudo apt-get install -y graphviz
  - macOS (homebrew): brew install graphviz
  - Windows: install Graphviz and add 'dot' to PATH
- Python package: graphviz
  - pip install graphviz

Usage (CLI):
python3 main.py --in-width 16 --const 301 --const-width 12 --stages 3 --outdir ./generated

Usage (GUI):
python3 gui.py

What it generates:
- Synthesizable VHDL-93 RTL for constant multiplication (shift/add and CSD variants)
- Self-checking testbenches (tb_*.vhd)
- SVG diagrams showing adder-tree and pipeline registers (aligned by level)
- Both schematic-only and annotated diagrams are produced (when possible)

Specifications satisfied:
- Input is unsigned std_logic_vector width 8,16,32,64
- Constant multiplier is unsigned, width 8..16 bits
- Multiplication decomposed to shifts and adds (CSD variant uses signed adds/subtracts)
- Pipeline registers inserted exactly at adder-tree level boundaries as per requested stages
- Output always registered; pipeline stages >= 1 enforced by user interface

Example configs included in 'examples/' folder:
1) const_width=13, const=15, input_width=32
2) const_width=15, const=312, input_width=32
3) const_width=16, const=1251, input_width=64

Notes:
- If Graphviz 'dot' is not available, SVG rendering may fail; .dot files will be present.
- The VHDL is verbose (one signal per node) to make verification easier.
