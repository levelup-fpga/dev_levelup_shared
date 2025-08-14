# explore_mult.py
import math
from typing import List, Tuple

def bit_positions(value: int) -> List[int]:
    if value == 0:
        return []
    return [i for i in range(value.bit_length()) if ((value >> i) & 1) == 1]

def csd_encode(value: int, max_bits: int = 16) -> List[int]:
    if value < 0:
        raise ValueError("csd_encode expects non-negative integer")
    n = value
    out = []
    i = 0
    limit = max_bits + 1
    while (n > 0 or i < 1) and i < limit:
        if (n & 1) == 0:
            out.append(0)
            n >>= 1
        else:
            rem = n & 3
            if rem == 1:
                out.append(1)
                n = (n - 1) >> 1
            else:
                out.append(-1)
                n = (n + 1) >> 1
        i += 1
    while len(out) < limit:
        out.append(0)
    return out

def adder_tree_depth(num_terms: int) -> int:
    if num_terms <= 1:
        return 0
    depth = 0
    n = num_terms
    while n > 1:
        n = (n + 1) // 2
        depth += 1
    return depth

def recommend_stages(num_terms: int, input_width: int) -> int:
    base = adder_tree_depth(num_terms)
    if base <= 1:
        rec = 1
    else:
        if input_width >= 64:
            rec = max(base, 3)
        elif input_width >= 32:
            rec = max(base, 2)
        else:
            rec = base
    return max(1, rec)

def distribute_levels(total_levels: int, stages: int) -> List[int]:
    if stages <= 0:
        raise ValueError("stages must be >= 1")
    if total_levels <= 0:
        return [0] * stages
    base = total_levels // stages
    rem = total_levels % stages
    return [base + (1 if i < rem else 0) for i in range(stages)]

def shift_terms_from_const(const_val: int) -> List[Tuple[int,int]]:
    return [(s, 1) for s in bit_positions(const_val)]

def csd_terms_from_const(const_val: int, const_width: int) -> List[Tuple[int,int]]:
    csd = csd_encode(const_val, max_bits=const_width)
    return [(i, csd[i]) for i in range(len(csd)) if csd[i] != 0]
