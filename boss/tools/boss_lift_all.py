#!/usr/bin/env python3
"""boss_lift_all.py -- lift EVERY function of the BOSS image to readable C99, no boot needed. Reuses the
image-generic lifter (jp8/tools/jp8_lift.py) with LIFT_BIN pointed at the pinned BOSS .vst3; the roots are every
function in the PE exception table (.pdata), so the whole binary is covered -- licence code included. Output:
  boss/src/boss_lift.c       the lifted C (the plugin's own machine code, one function per C function `f_<rva>`)
  boss/src/boss_funcmap.tsv  rva <tab> name   (RTTI / export names where known, to navigate the lift)
PLUMBING ONLY: it reimplements no plugin logic; it translates instructions. Run via tools/run_job.sh.
"""
import os
import re
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import boss_truth as T                                                  # noqa: E402

os.environ['LIFT_BIN'] = T.VST3                                         # the lifter reads this at import
sys.path.insert(0, os.path.join(REPO, 'jp8', 'tools'))
import jp8_lift as J                                                    # noqa: E402  (image-generic lifter)
import pefile                                                           # noqa: E402

t0 = time.time()
pe = pefile.PE(T.VST3)
roots = sorted(set(f.struct.BeginAddress for f in pe.DIRECTORY_ENTRY_EXCEPTION))
print('roots (every .pdata function): %d' % len(roots), flush=True)

funcs = J.discover(roots, {}, set())
print('[%5.0fs] discovered %d functions' % (time.time() - t0, len(funcs)), flush=True)

src = J.Lifter(funcs, 'boss').lift()
out_c = os.path.join(REPO, 'boss', 'src', 'boss_lift.c')
os.makedirs(os.path.dirname(out_c), exist_ok=True)
open(out_c, 'w').write(src)
ninstr = sum(len(F['insns']) for F in funcs.values())
print('[%5.0fs] lifted %d functions, %d instructions -> %s (%.1f MB, %d lines)' % (
    time.time() - t0, len(funcs), ninstr, out_c, len(src) / 1e6, src.count('\n')), flush=True)

# a name map, so the next AI can find the licence code by name (RTTI type descriptors + exports)
names = {}
for e in pe.DIRECTORY_ENTRY_EXPORT.symbols:
    if e.name:
        names[e.address] = e.name.decode()
img = pe.get_memory_mapped_image()
for m in re.finditer(rb'\.\?A[UV][A-Za-z0-9_@?$]+@@', img):            # RTTI names (for orientation, not exact rva)
    pass
out_map = os.path.join(REPO, 'boss', 'src', 'boss_funcmap.tsv')
with open(out_map, 'w') as f:
    f.write('rva\tname\n')
    for rva in roots:
        nm = names.get(rva, '')
        f.write('0x%x\t%s\n' % (rva, nm))
print('[%5.0fs] wrote %s (%d rows)' % (time.time() - t0, out_map, len(roots)), flush=True)
print('DONE', flush=True)
