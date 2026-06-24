#!/usr/bin/env python3
# parse_param_map.py — recover the parameter ID -> name -> flat-state offset map
# from the registry sub_180388170's disassembly (Hex-Rays returns None on it).
#
# Each parameter registration emits, in order: a `lea reg, aName` (the param name
# string) and a `lea reg, [rdi+OFFSET]` whose result is stored into the 40-byte
# descriptor's +32 slot pointer = &engine_state[OFFSET]. Registration order = the
# parameter ID used everywhere else. The `lea rcx,[rdi+38h]` (offset 56) leas are
# the std::vector push_back target, not parameter slots — filtered out.
#
#   usage: parse_param_map.py <registry.asm> > docs/PARAM_MAP.tsv
import re, sys

def main(path):
    name_re = re.compile(r'lea\s+\w+,\s+a[A-Za-z0-9_]+')
    str_re  = re.compile(r'; "(.*?)"')
    off_re  = re.compile(r'lea\s+\w+,\s+\[rdi\+([0-9A-Fa-f]+)h?\]')
    params, pending = [], '?'
    for ln in open(path):
        if name_re.search(ln):
            m = str_re.search(ln); pending = m.group(1) if m else '?'
        mo = off_re.search(ln)
        if mo:
            off = int(mo.group(1), 16)
            if off == 56:            # vector push_back artifact
                continue
            params.append((len(params), off, pending)); pending = '?'
    print("param_id\toffset\tname")
    for pid, off, name in params:
        print(f"{pid}\t{off}\t{name}")
    sys.stderr.write(f"{len(params)} parameters\n")

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1
         else "chorus_coeffs/coeffgen_sub_180388170_180388170.asm")
