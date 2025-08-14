# main.py
import argparse
from pathlib import Path
from explore_mult import shift_terms_from_const, csd_terms_from_const, adder_tree_depth, recommend_stages, distribute_levels
from gen_vhdl import gen_variant

def parse_args():
    p = argparse.ArgumentParser(description='Generate VHDL multiplier variants and diagrams.')
    p.add_argument('--in-width', type=int, choices=[8,16,32,64], required=True)
    p.add_argument('--const', type=int, required=True)
    p.add_argument('--const-width', type=int, choices=range(8,17), default=12)
    p.add_argument('--stages', type=int, default=1)
    p.add_argument('--outdir', type=str, default='generated')
    return p.parse_args()

def main():
    args = parse_args()
    IN_W = args.in_width
    CONST = args.const
    CONST_W = args.const_width
    STAGES = args.stages
    OUT = Path(args.outdir)
    OUT.mkdir(parents=True, exist_ok=True)
    shift_terms = shift_terms_from_const(CONST)
    n_terms_shift = len(shift_terms)
    depth_shift = adder_tree_depth(n_terms_shift)
    rec_shift = recommend_stages(n_terms_shift, IN_W)
    levels_shift = distribute_levels(depth_shift, STAGES)
    print(f'Shift-add: terms={n_terms_shift} depth={depth_shift} recommended={rec_shift} levels_per_stage={levels_shift}')
    basename_mp = f'const_mult_tree_mp_w{IN_W}_c{CONST}_s{STAGES}'
    vhd_mp, tb_mp, svg_mp = gen_variant(IN_W, CONST_W, CONST, STAGES, levels_shift, str(OUT), basename_mp, use_csd=False)
    print('Wrote:', vhd_mp, tb_mp, svg_mp)
    csd_terms = csd_terms_from_const(CONST, CONST_W)
    n_terms_csd = len(csd_terms)
    depth_csd = adder_tree_depth(n_terms_csd)
    rec_csd = recommend_stages(n_terms_csd, IN_W)
    levels_csd = distribute_levels(depth_csd, STAGES)
    print(f'CSD: terms={n_terms_csd} depth={depth_csd} recommended={rec_csd} levels_per_stage={levels_csd}')
    basename_cs = f'const_mult_tree_cs_w{IN_W}_c{CONST}_s{STAGES}'
    vhd_cs, tb_cs, svg_cs = gen_variant(IN_W, CONST_W, CONST, STAGES, levels_csd, str(OUT), basename_cs, use_csd=True)
    print('Wrote:', vhd_cs, tb_cs, svg_cs)
    print('Done. Files in:', OUT.resolve())

if __name__ == '__main__':
    main()
