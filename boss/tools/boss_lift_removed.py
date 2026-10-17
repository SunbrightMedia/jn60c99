#!/usr/bin/env python3
"""boss_lift_removed.py -- the full lift with the LICENCE functions removed. Same as boss_lift_all.py, but the
rvas in boss/src/boss_license_map.tsv are passed to the lifter as --replace: each becomes an empty leaf stub
(its body is never lifted) and a discover STOP (its exclusive callee subtree is not walked), so the licence
code drops out while callers still link. Output: boss/src/boss_lift_removed.c. Run via tools/run_job.sh.
"""
import os
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import boss_truth as T                                                  # noqa: E402

os.environ['LIFT_BIN'] = T.VST3
sys.path.insert(0, os.path.join(REPO, 'jp8', 'tools'))
import jp8_lift as J                                                    # noqa: E402
import pefile                                                           # noqa: E402

t0 = time.time()
pe = pefile.PE(T.VST3)
roots = sorted(set(f.struct.BeginAddress for f in pe.DIRECTORY_ENTRY_EXCEPTION))

remove = set()
for line in open(os.path.join(REPO, 'boss', 'src', 'boss_license_map.tsv')):
    cell = line.split('\t', 1)[0].strip()
    if cell.startswith('0x'):
        remove.add(int(cell, 16))
print('removing %d licence functions (stub + stop)' % len(remove), flush=True)

roots = [r for r in roots if r not in remove]                          # do not seed the licence funcs as roots
funcs = J.discover(roots, {}, remove)                                  # remove = discover STOPs
for r in remove:
    funcs[r] = dict(insns={}, targets=set(), ijmp={}, replace=True)    # empty leaf stub entry
print('[%5.0fs] discovered %d functions' % (time.time() - t0, len(funcs)), flush=True)

src = J.Lifter(funcs, 'boss', replace=remove).lift()
out_c = os.path.join(REPO, 'boss', 'src', 'boss_lift_removed.c')
open(out_c, 'w').write(src)
print('[%5.0fs] wrote %s (%.1f MB, %d lines); %d functions, %d stubbed' % (
    time.time() - t0, out_c, len(src) / 1e6, src.count('\n'), len(funcs), len(remove)), flush=True)
print('DONE', flush=True)
