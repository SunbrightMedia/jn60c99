#!/usr/bin/env python3
"""hostmod_gate.py -- #112 LIVE MODULATION layer gate.

The plugin's dispatch indices 312..317 are no-ops in the patch-RECALL role and, in
the HOST role, apply a signed percentage offset over a front-panel parameter's
recalled base byte, then re-drive that parameter's own setter with the result:

    312 -> VCF CUTOFF FREQ (779)     315 -> DCO PWM DEPTH (758)
    313 -> HPF CUTOFF FREQ (782)     316 -> PORTAMENTO    (798)
    314 -> VCF RESONANCE   (781)     317 -> EFFECT DEPTH  (794)

This gate proves src/juno_mod.c's juno_mod_byte() IS the plugin's own computation,
by OBSERVING the byte the plugin passes to the base setter. The reference hooks the
base parameter's own setter (its rva, resolved from the proc vtable) while driving
the plugin's modulation setter, and records the 3rd argument -- the plugin's own
modulated byte. Nothing is inverted, curated or fitted.

Anti-circularity: the port never chooses the coordinates; the oracle enumerates
every (slot, base, offset) itself. Two-process rule: --ref is Unicorn only, --port
is ctypes-libjuno only; they meet through a pickle.

  python3 tools/verify/hostmod_gate.py --ref [--full]
  python3 tools/verify/hostmod_gate.py --port
"""
import sys, os, pickle

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import truth

SP = '/home/user/jn60c99/scratchpad'
REF = SP + '/hostmod_ref.pkl'

#            slot, mod idx, base idx, base setter's proc-vtable byte offset
SLOTS = [(0, 312, 779, 2144), (1, 313, 782, 2160), (2, 314, 781, 2152),
         (3, 315, 758, 2088), (4, 316, 798, 2288), (5, 317, 794, 2256)]
SR = 48000.0


def coords(full):
    bases = list(range(256)) if full else list(range(0, 256, 5)) + [255]
    offs = list(range(-100, 101)) if full else list(range(-100, 101, 5)) + [-1, 1]
    return sorted(set(bases)), sorted(set(offs))


# ------------------------------------------------------------------ oracle -------
def build_ref():
    import e2e_emu as E
    import real_recall as R
    from unicorn import UC_HOOK_CODE
    from unicorn.x86_const import UC_X86_REG_R8

    full = '--full' in sys.argv
    bases, offs = coords(full)
    IB = E.IB
    DISPATCH = IB + 0x3B9A30
    PROC_VT = 0x9C3018

    e = E.E2E(); uc = e.uc
    # resolve each base parameter's own setter address from the proc vtable
    setter_rva = {}
    for (slot, mod, base, vtoff) in SLOTS:
        v = int.from_bytes(E.IMG[PROC_VT + vtoff: PROC_VT + vtoff + 8], 'little')
        setter_rva[slot] = v - IB
    print('base setters:', {s: hex(r) for s, r in setter_rva.items()})

    seen = {'slot': None, 'vals': []}
    def hk(uc_, addr, size, user):
        if seen['slot'] is None: return
        if addr == IB + setter_rva[seen['slot']]:
            seen['vals'].append(uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF)
    for r in set(setter_rva.values()):
        uc.hook_add(UC_HOOK_CODE, hk, begin=IB + r, end=IB + r)
    e.build(SR); e.snap_all()

    out = {}
    for (slot, mod, base_idx, _vt) in SLOTS:
        n = 0
        for b in bases:
            # set the base parameter through the plugin's own recall role
            seen['slot'] = None
            R.wr_desc(e, base_idx, b)
            for u in range(9):
                e.call(DISPATCH, rcx=e.proc[u], rdx=base_idx, r8=1, r9=b,
                       count=200_000_000)
            for off in offs:
                seen['slot'] = slot; seen['vals'] = []
                R.wr_desc(e, mod, off & 0xFFFFFFFF)
                e.call(DISPATCH, rcx=e.proc[0], rdx=mod, r8=0,
                       r9=off & 0xFFFFFFFF, count=200_000_000)
                seen['slot'] = None
                if seen['vals']:
                    out[(slot, b, off)] = seen['vals'][0]
                    n += 1
        print('  slot %d (mod %d -> base %d): %d observations' % (slot, mod, base_idx, n))
    os.makedirs(SP, exist_ok=True)
    pickle.dump({'obs': out, 'bases': bases, 'offs': offs, 'full': full},
                open(REF, 'wb'))
    print('wrote %s (%d observations)' % (REF, len(out)))
    return 0


# -------------------------------------------------------------------- port -------
def run_port_and_diff():
    import ctypes
    if not os.path.exists(REF):
        print('hostmod_gate: missing %s -- run --ref first' % REF); return 1
    ref = pickle.load(open(REF, 'rb'))
    obs = ref['obs']
    if not obs:
        print('hostmod_gate: RED -- reference is EMPTY (oracle observed no setter calls)')
        return 1
    lib = ctypes.CDLL('/home/user/jn60c99/libjuno.so')
    lib.juno_mod_byte.argtypes = [ctypes.c_int, ctypes.c_int]
    lib.juno_mod_byte.restype = ctypes.c_int

    total = mm = 0; bad = []
    for (slot, b, off), want in sorted(obs.items()):
        got = lib.juno_mod_byte(b, off)
        total += 1
        if got != want:
            mm += 1
            if len(bad) < 12: bad.append((slot, b, off, want, got))
    if mm == 0:
        print('HOST-MODULATION: PROVEN  (%d comparisons over %d slots x %d bases x %d offsets, '
              '0 mismatch%s)' % (total, len(SLOTS), len(ref['bases']), len(ref['offs']),
                                 ', EXHAUSTIVE' if ref.get('full') else ''))
        return 0
    print('HOST-MODULATION: RED  (%d/%d mismatches)' % (mm, total))
    for (slot, b, off, want, got) in bad:
        print('  RED slot %d base %d off %d: plugin %d, port %d' % (slot, b, off, want, got))
    return 1


def main():
    if '--ref' in sys.argv: return build_ref()
    if '--port' in sys.argv: return run_port_and_diff()
    print('usage: hostmod_gate.py --ref [--full] | --port'); return 2


if __name__ == '__main__':
    sys.exit(main())
