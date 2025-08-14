
# gen_vhdl.py - cleaned version
from pathlib import Path
from typing import List, Tuple
import os
import graphviz

class Node:
    def __init__(self, name: str, expr: str = None, left: 'Node' = None, right: 'Node' = None, level: int = 0):
        self.name = name
        self.expr = expr
        self.left = left
        self.right = right
        self.level = level
        self.registered_stage = None

def build_adder_tree(terms: List[Tuple[int,int]], use_csd: bool) -> List[List[Node]]:
    levels = []
    leaves = []
    for idx, (shift, sign) in enumerate(terms):
        base_expr = "shift_left(unsigned(din_u), {})".format(shift)
        expr = "(0 - {})".format(base_expr) if use_csd and sign == -1 else base_expr
        leaves.append(Node(name="leaf_{}".format(idx), expr=expr, level=0))
    if not leaves:
        leaves.append(Node(name="leaf_0", expr="(others => '0')", level=0))
    levels.append(leaves)
    current = leaves
    lvl = 1
    while len(current) > 1:
        next_level = []
        i = 0
        pair_idx = 0
        while i < len(current):
            if i + 1 < len(current):
                l = current[i]
                r = current[i+1]
                node = Node(name="add_l{}_{}".format(lvl, pair_idx), left=l, right=r, level=lvl)
                next_level.append(node)
                pair_idx += 1
                i += 2
            else:
                src = current[i]
                node = Node(name="copy_l{}_{}".format(lvl, pair_idx), left=src, right=None, level=lvl)
                next_level.append(node)
                pair_idx += 1
                i += 1
        levels.append(next_level)
        current = next_level
        lvl += 1
    return levels

def mark_register_boundaries(levels: List[List[Node]], levels_per_stage: List[int]):
    cum = 0
    boundaries = []
    for st_idx, lv in enumerate(levels_per_stage):
        cum += lv
        boundaries.append((cum, st_idx))
    boundaries = [(b, s) for (b, s) in boundaries if 0 <= b <= (len(levels)-1)]
    for (b, st_idx) in boundaries:
        if b < 0 or b >= len(levels):
            continue
        for node in levels[b]:
            node.registered_stage = st_idx
    return boundaries

def emit_vhdl(levels: List[List[Node]], in_width: int, const_width: int, const_val: int,
              levels_per_stage: List[int], out_dir: str, entity_base: str):
    OUT_WIDTH = in_width + const_width
    all_nodes = [n for lvl in levels for n in lvl]
    Path(out_dir).mkdir(parents=True, exist_ok=True)
    entity = entity_base
    lines = []
    lines.append('library ieee;')
    lines.append('use ieee.std_logic_1164.all;')
    lines.append('use ieee.numeric_std.all;')
    lines.append('')
    lines.append('entity {} is'.format(entity))
    lines.append('  port (clk : in std_logic; rst : in std_logic;')
    lines.append('        din : in std_logic_vector({} downto 0);'.format(in_width-1))
    lines.append('        dout : out std_logic_vector({} downto 0));'.format(OUT_WIDTH-1))
    lines.append('end entity;')
    lines.append('')
    lines.append('architecture rtl of {} is'.format(entity))
    lines.append('  signal din_u : unsigned({} downto 0);'.format(in_width-1))
    for n in all_nodes:
        lines.append('  signal {} : unsigned({} downto 0);'.format(n.name, OUT_WIDTH-1))
        if n.registered_stage is not None:
            lines.append('  signal {}_r : unsigned({} downto 0); -- registered at stage {}'.format(n.name, OUT_WIDTH-1, n.registered_stage))
    lines.append('')
    lines.append('begin')
    lines.append('  din_u <= unsigned(din);')
    lines.append('')
    lines.append('  -- combinational assignments')
    for lvl_idx, lvl in enumerate(levels):
        for n in lvl:
            if lvl_idx == 0:
                lines.append('  {} <= {};'.format(n.name, n.expr))
            else:
                if n.left is not None:
                    left_sig = '{}_r'.format(n.left.name) if (n.left.registered_stage is not None) else n.left.name
                else:
                    left_sig = "(others => '0')"
                if n.right is not None:
                    right_sig = '{}_r'.format(n.right.name) if (n.right.registered_stage is not None) else n.right.name
                    lines.append('  {} <= {} + {};'.format(n.name, left_sig, right_sig))
                else:
                    lines.append('  {} <= {};'.format(n.name, left_sig))
    lines.append('')
    lines.append('  -- pipeline registers')
    lines.append('  process(clk)')
    lines.append('  begin')
    lines.append('    if rising_edge(clk) then')
    lines.append('      if rst = ''1'' then')
    for n in all_nodes:
        if n.registered_stage is not None:
            lines.append('        {}_r <= (others => ''0'');'.format(n.name))
    lines.append('      else')
    for n in all_nodes:
        if n.registered_stage is not None:
            lines.append('        {}_r <= {};'.format(n.name, n.name))
    lines.append('      end if;')
    lines.append('    end if;')
    lines.append('  end process;')
    lines.append('')
    top = levels[-1][0]
    top_sig = '{}_r'.format(top.name) if top.registered_stage is not None else top.name
    lines.append('  dout <= std_logic_vector({});'.format(top_sig))
    lines.append('end architecture;')
    out_path = Path(out_dir) / (entity + '.vhd')
    out_path.write_text('\n'.join(lines))
    return out_path

def emit_tb(entity_base: str, in_width: int, const_val: int, const_width: int, pipeline_latency: int, out_dir: str):
    OUT_WIDTH = in_width + const_width
    tb_name = 'tb_{}'.format(entity_base)
    lines = []
    lines.append('library ieee;')
    lines.append('use ieee.std_logic_1164.all;')
    lines.append('use ieee.numeric_std.all;')
    lines.append('')
    lines.append('entity {} is end entity;'.format(tb_name))
    lines.append('architecture tb of {} is'.format(tb_name))
    lines.append('  signal clk : std_logic := ''0'';')
    lines.append('  signal rst : std_logic := ''1'';')
    lines.append('  signal din : std_logic_vector({} downto 0) := (others => ''0'');'.format(in_width-1))
    lines.append('  signal dout : std_logic_vector({} downto 0);'.format(OUT_WIDTH-1))
    lines.append('begin')
    lines.append('  uut: entity work.{}'.format(entity_base))
    lines.append('    port map(clk=>clk, rst=>rst, din=>din, dout=>dout);')
    lines.append('  clk_proc: process begin loop clk <= ''0''; wait for 5 ns; clk <= ''1''; wait for 5 ns; end loop; end process;')
    lines.append('  stim: process')
    lines.append('    variable i : integer;')
    lines.append('    variable expected : unsigned({} downto 0);'.format(OUT_WIDTH-1))
    lines.append('  begin')
    lines.append('    rst <= ''1''; wait for 20 ns; rst <= ''0'';')
    lines.append('    for i in 0 to 200 loop')
    lines.append('      din <= std_logic_vector(to_unsigned(i mod (2**{}), {}));'.format(in_width, in_width))
    lines.append('      expected := to_unsigned((i mod (2**{})) * {}, {});'.format(in_width, const_val, OUT_WIDTH))
    lines.append('      wait for 10 ns;')
    lines.append('      wait for {} * 10 ns;'.format(pipeline_latency))
    lines.append('      if dout /= std_logic_vector(expected) then')
    lines.append('        report "TB MISMATCH i=" & integer''image(i) & " expected=" & to_hstring(std_logic_vector(expected)) & " got=" & to_hstring(dout) severity error;')
    lines.append('      end if;')
    lines.append('    end loop;')
    lines.append('    report "TB DONE" severity note;')
    lines.append('    wait;')
    lines.append('  end process;')
    lines.append('end architecture;')
    tb_path = Path(out_dir) / (tb_name + ".vhd")
    tb_path.write_text("\n".join(lines))
    return tb_path

def generate_diagram(levels: List[List[Node]], out_dir: str, basename: str):
    dot = graphviz.Digraph(comment='adder tree pipeline')
    dot.attr(rankdir='LR')
    dot.attr('node', shape='box', style='filled', color='lightyellow')
    Path(out_dir).mkdir(parents=True, exist_ok=True)
    for lvl_idx, lvl in enumerate(levels):
        with dot.subgraph(name=f"cluster_lvl_{lvl_idx}") as c:
            c.attr(rank='same')
            c.attr(label=f"Level {lvl_idx}")
            for n in lvl:
                label = n.name
                if lvl_idx == 0:
                    label += '\n' + n.expr.replace('shift_left(unsigned(din_u),', '<<')[:40]
                else:
                    if n.left and n.right:
                        label += f'\nadd({n.left.name},{n.right.name})'
                    else:
                        label += f'\ncopy({n.left.name})'
                if n.registered_stage is not None:
                    label += f'\n[REG S{n.registered_stage}]'
                c.node(n.name, label)
    for lvl_idx in range(len(levels)-1):
        for parent in levels[lvl_idx+1]:
            for child in (parent.left, parent.right):
                if child is None:
                    continue
                if child.registered_stage is not None:
                    reg_name = f"{child.name}_reg_s{child.registered_stage}_l{child.level}"
                    dot.node(reg_name, f"REG\nS{child.registered_stage}", shape='box', style='filled', color='lightgrey')
                    dot.edge(child.name, reg_name)
                    dot.edge(reg_name, parent.name)
                else:
                    dot.edge(child.name, parent.name)
    top = levels[-1][0]
    out_name = 'DOUT'
    dot.node(out_name, 'DOUT', shape='box', style='filled', color='lightblue')
    if top.registered_stage is not None:
        reg_top = f"{top.name}_reg_s{top.registered_stage}_l{top.level}"
        dot.node(reg_top, f"REG\nS{top.registered_stage}", shape='box', style='filled', color='lightgrey')
        dot.edge(top.name, reg_top)
        dot.edge(reg_top, out_name)
    else:
        dot.edge(top.name, out_name)
    svg_path = Path(out_dir) / (basename + '.svg')
    dot.render(filename=str(Path(out_dir) / basename), format='svg', cleanup=True)
    return svg_path

def gen_variant(in_w:int, const_w:int, const_val:int, stages:int, levels_per_stage:List[int], out_dir:str, basename:str, use_csd:bool=False):
    from explore_mult import bit_positions, csd_encode
    if use_csd:
        csd = csd_encode(const_val, max_bits=const_w)
        terms = [(i, csd[i]) for i in range(len(csd)) if csd[i] != 0]
    else:
        bits = bit_positions(const_val)
        terms = [(b, 1) for b in bits]
    if not terms:
        terms = [(0,1)]
    levels = build_adder_tree(terms, use_csd)
    mark_register_boundaries(levels, levels_per_stage)
    ent_name = basename
    vhd = emit_vhdl(levels, in_w, const_w, const_val, levels_per_stage, out_dir, ent_name)
    latency = len(levels_per_stage)
    tb = emit_tb(ent_name, in_w, const_val, const_w, latency, out_dir)
    svg = generate_diagram(levels, out_dir, basename + '_diagram')
    return vhd, tb, svg
