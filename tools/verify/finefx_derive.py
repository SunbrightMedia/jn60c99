#!/usr/bin/env python3
"""Pillar-1 fix (#116) — proof-driven derivation of the fine-FX param laws.
For each fine delay/chorus/reverb filter+level param, in every FX context its
port applier will run in, sweep all 256 byte values under Unicorn and record the
exact coefficient each writes to each cell. Output: finefx_laws.pkl
  { param_name -> { ctx -> { cell -> [256 uint32 coefficients] } } }
This is the plugin's OWN setter executed on its OWN state (PROVEN provenance),
covenant-clean. Oracle-only (Unicorn). Contexts recall a real FX-active patch
via load_leaves + force the effect type, matching how delay/chorus/reverb_recall
route in the port."""
import sys, struct, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E

SP  = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad'
OUT = SP + '/finefx_laws.pkl'
CW  = SP + '/chillwave.bin'
SZ  = 0xA83010
EFFECT_TYPE, DELAY_TYPE, REVERB_TYPE = 873, 875, 876

# param -> dispatch idx (from coverage_leaves.tsv)
PARAMS = {
    'DELAY HIGH CUT': 1180, 'DELAY DIRECT LEVEL': 1181, 'DELAY LF DAMP': 1182,
    'DELAY HF DAMP': 1184, 'DELAY HF DAMP FREQ': 1185, 'DELAY LF DAMP FREQ': 1183,
    'CHORUS HIGH CUT': 1212, 'CHORUS LOW CUT': 1211, 'CHORUS PRE DELAY': 1210,
    'REVERB PRE DELAY': 1323, 'REVERB LOW CUT': 1324, 'REVERB HIGH CUT': 1325,
    'REVERB DENSITY': 1326, 'REVERB DIRECT LEVEL': 1327,
    'EFFECT DEPTH': 794, 'REVERB LEVEL': 795,
}
# which contexts each param family needs (recall patch, effect type, reverb type)
facbank = E.bank_bytes(); cwbank = open(CW, 'rb').read()
std = E.load_leaves()
# CTX: (label, which, patch, force_effect_type, force_reverb_type)
CTXS = [
    ('dly_t0', 'fac', 13, 0, None),    # delay type 0 (slot-1, 102xxx region)
    ('dly_t1', 'fac', 13, None, None), # delay as-recalled (patch 13 native)
    ('cho_I',  'fac', 0,  2, None),    # chorus I
    ('cho_II', 'fac', 11, 3, None),    # chorus II
    ('rev',    'fac', 20, 2, 2),       # reverb active
    ('flang',  'cw',  32, 4, None),    # flanger
    ('mfx',    'fac', 7,  5, None),    # mode 5
]

def make_ctx(which, patch, et, rt):
    e = E.E2E(); e.build(48000.0); e.snap_all()
    bank = facbank if which == 'fac' else cwbank
    blob = E.patch_blob(bank, patch)
    for (p, nm, disp, bb) in std:
        for u in range(9):
            try: e.dispatch(u, disp, E.dec(blob, bb))
            except RuntimeError: pass
    for u in range(9):
        if et is not None:
            try: e.dispatch(u, EFFECT_TYPE, et)
            except RuntimeError: pass
        if rt is not None:
            try: e.dispatch(u, REVERB_TYPE, rt)
            except RuntimeError: pass
    e.snap_all()
    return e

def rd(e, off): return struct.unpack('<I', e.uc.mem_read(e.state[0] + off, 4))[0]

laws = {nm: {} for nm in PARAMS}
for (label, which, patch, et, rt) in CTXS:
    e = make_ctx(which, patch, et, rt)
    base = e.state[0]; lo, hi = base, base + SZ
    # locate cells: dispatch 0 vs 255, diff (cheap — only 2 full reads per param)
    for nm, disp in PARAMS.items():
        a = bytes(e.uc.mem_read(base, SZ))
        for u in range(9):
            try: e.dispatch(u, disp, 0)
            except RuntimeError: pass
        b0 = bytes(e.uc.mem_read(base, SZ))
        for u in range(9):
            try: e.dispatch(u, disp, 255)
            except RuntimeError: pass
        b1 = bytes(e.uc.mem_read(base, SZ))
        cells = [o for o in range(0, SZ, 4) if b0[o:o+4] != b1[o:o+4]]
        if not cells:
            continue
        # sweep 256 values, record each cell's coefficient
        tbl = {c: [] for c in cells}
        for v in range(256):
            for u in range(9):
                try: e.dispatch(u, disp, v)
                except RuntimeError: pass
            for c in cells:
                tbl[c].append(rd(e, c))
        laws[nm][label] = tbl
    sys.stderr.write("ctx %s done\n" % label); sys.stderr.flush()

pickle.dump(laws, open(OUT, 'wb'))
for nm in PARAMS:
    ctxs = {k: list(v.keys()) for k, v in laws[nm].items()}
    print("%-20s -> %s" % (nm, ctxs))
print("wrote", OUT)
