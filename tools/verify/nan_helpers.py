#!/usr/bin/env python3
"""nan_helpers.py -- the leaf helpers the render functions call, graded alone on the values a NaN gate needs.

nan_sites.py grades every relation and min / max of the two render functions, and nan_ab.py a NaN in live cells;
neither sees inside a helper called from them. The plugin's helpers decide on NaN with their own flag tests (the
JUNO's wrap to [-1, 1) at rva 0x368F30: `comiss x, -1.0; jae` falls through on NaN and computes fmod of it, where the
port returned the NaN as it was) and with their own CRT (fmod, expf, tanf: a NaN's payload and sign). Each helper is
called ALONE: in the plugin (Unicorn: its own machine code at its rva, the argument in xmm0, the oracle's MXCSR) and in
the port (the C function), on quiet / signalling / negative NaNs and payloads, the infinities, both zeros, denormals,
the boundaries the helpers test and random values and bit patterns -- every output bit equal (playbooks 219, 222).

Two processes (the two-process rule): --oracle writes the plugin's outputs as JSON; the port's process compares.

    python3 tools/verify/nan_helpers.py --port-of juno|jx [--n 400]
    python3 tools/verify/nan_helpers.py --port-of juno|jx --tooth   the port's wrap to [-1, 1) as it was before the
                                                                 rewrite (its `x < -1` in C's form): must differ
    python3 tools/verify/nan_helpers.py --port-of juno|jx --tooth-mode   the oracle at the CPU's reset MXCSR (no DAZ):
                                                                 must differ -- the oracle's mode is live
exit 0 = every helper equal on every input (or, --tooth, the defect seen); 1 = a difference (listed).
"""
import ctypes
import json
import os
import random
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)

# (the port's C function, the plugin's rva, argument and result type: f float, d double). fmodf2 is the CRT's
# fmodf with the 2.0f every render-file call passes (xmm1): the plugin's statically linked CRT against the port's libm
HELPERS = {
    'juno': [('juno_wrap24', 0x368D60, 'f'), ('juno_triangle', 0x368FC0, 'f'), ('juno_pitch_poly', 0x368DC0, 'd'),
             ('juno_wrap_unit', 0x368F30, 'f'), ('juno_wrap_hi', 0x368F90, 'f'),
             ('juno_expf_6EF740', 0x6EF740, 'f'), ('fmodf2', 0x6EF4D8, 'f')],
    'jx': [('jx_h_3A2010', 0x3A2010, 'd'), ('jx_h_3A2180', 0x3A2180, 'f'), ('jx_h_3A2210', 0x3A2210, 'f'),
           ('jx_h_3A9950', 0x3A9950, 'f'), ('jx_h_3A21E0', 0x3A21E0, 'f'), ('jx_h_expf_722EA0', 0x722EA0, 'f'),
           ('jx_h_tanf_725150', 0x725150, 'f'), ('fmodf2', 0x724EE8, 'f')],
}
MXCSR = 0x9FC0                  # the plugin's DSP mode; Unicorn honours DAZ, never FTZ (playbook 220)
TWO = 0x40000000                # 2.0f, fmodf's second argument


def inputs(kind, n):
    """the special values, then random ones (a fixed seed): 32-bit patterns for float, 64-bit for double"""
    if kind == 'f':
        sp = [0x7FC00000, 0xFFC00000, 0x7F800001, 0x7FC12345, 0xFFC54321, 0x7F800000, 0xFF800000, 0, 0x80000000,
              0x00000001, 0x007FFFFF, 0x80000001, 0x00800000, 0x80800000, 0x3F800000, 0xBF800000, 0x3F800001,
              0x3F7FFFFF, 0xBF800001, 0xBF7FFFFF, 0x40000000, 0xC0000000, 0x40400000, 0xC0400000, 0x3F000000,
              0x7149F2CA, 0xF149F2CA, 0x7F7FFFFF, 0xFF7FFFFF, 0x41A00000, 0xC1A00000, 0x4B000000, 0xCB000000,
              0x4B800000, 0xCB800000, 0x42B20000, 0xC2B20000, 0x42C80000, 0xC2C80000]
        r = random.Random(222)
        sp += [struct.unpack('<I', struct.pack('<f', r.uniform(-4.0, 4.0)))[0] for _ in range(n // 2)]
        sp += [r.getrandbits(32) for _ in range(n // 2)]
        return sp
    sp = [0x7FF8000000000000, 0xFFF8000000000000, 0x7FF0000000000001, 0x7FF8000000012345, 0x7FF0000000000000,
          0xFFF0000000000000, 0, 0x8000000000000000, 1, 0x000FFFFFFFFFFFFF, 0x3FF0000000000000, 0xBFF0000000000000,
          0x4034000000000000, 0xC034000000000000, 0x4021CCCCCCCCCCCD, 0xC021CCCCCCCCCCCD, 0x40219999A0000000]
    r = random.Random(222)
    sp += [struct.unpack('<Q', struct.pack('<d', r.uniform(-25.0, 12.0)))[0] for _ in range(n // 2)]
    sp += [r.getrandbits(64) for _ in range(n // 2)]
    return sp


def oracle(port, n, mxcsr=MXCSR):
    from unicorn.x86_const import UC_X86_REG_XMM0, UC_X86_REG_XMM1, UC_X86_REG_MXCSR
    if port == 'juno':
        import e2e_emu as E
        e = E.E2E()
        IB = E.IB
    else:
        import jx_emu as J
        e = J.JX()
        IB = J.IB
    e._mxcsr = mxcsr                                    # the JX emulator's call() writes MXCSR from this field
    out = {}
    for name, rva, kind in HELPERS[port]:
        res = []
        for x in inputs(kind, n):
            e.uc.reg_write(UC_X86_REG_MXCSR, mxcsr)     # the JUNO emulator's call() leaves the register as set here
            e.uc.reg_write(UC_X86_REG_XMM0, x)
            e.uc.reg_write(UC_X86_REG_XMM1, TWO)
            e.call(IB + rva, count=2_000_000)
            y = e.uc.reg_read(UC_X86_REG_XMM0)
            res.append(y & (0xFFFFFFFF if kind == 'f' else 0xFFFFFFFFFFFFFFFF))
        out[name] = res
    return out


def shim_text(port):
    """bits in, bits out: each helper behind a wrapper that passes its argument and result as raw 32 / 64-bit
    words -- no conversion between the caller and the helper (a float -> double conversion quiets a signalling
    NaN)"""
    head = ('#include <stdint.h>\n#include <string.h>\n#include "juno_dsp.h"\n#include "juno_crt_expf.h"\n'
            if port == 'juno' else '#include <stdint.h>\n#include <string.h>\n#include "jx_voice_helpers.h"\n')
    out = [head, '#include <math.h>\nstatic float fmodf2(float x) { return fmodf(x, 2.0f); }\n']
    for name, rva, kind in HELPERS[port]:
        if kind == 'f':
            out.append('uint32_t nanh_%s(uint32_t x) { float f, y; memcpy(&f, &x, 4); y = %s(f); '
                       'memcpy(&x, &y, 4); return x; }\n' % (name, name))
        else:
            out.append('uint64_t nanh_%s(uint64_t x) { double f, y; memcpy(&f, &x, 8); y = %s(f); '
                       'memcpy(&x, &y, 8); return x; }\n' % (name, name))
    return ''.join(out)


def port_lib(port, tmp, tooth):
    """the port's helpers in a library of their own (their own C99 files) with the bits-only wrappers"""
    if port == 'juno':
        src = os.path.join(REPO, 'src', 'juno_dsp.c')
        if tooth:                                  # the port's wrap to [-1, 1) as it was: C's `<` (playbook 219)
            text = open(src).read()
            new = '    if (!(x >= -1.0f)) return fmodf(x - 1.0f, 2.0f) + 1.0f;     /* `comiss x, -1; jae`: NaN takes the fmod */\n'
            old = '    if (x < -1.0f) return fmodf(x - 1.0f, 2.0f) + 1.0f;\n'
            if text.count(new) != 1:
                raise SystemExit('REFUSE --tooth: juno_wrap_unit is not in its rewritten form')
            src = os.path.join(tmp, 'juno_dsp.c')
            open(src, 'w').write(text.replace(new, old))
        files, inc = [src], ['-I', os.path.join(REPO, 'src')]
    else:
        src = os.path.join(REPO, 'jx3p', 'src', 'jx_voice_helpers.c')
        if tooth:                                  # the JX wrap to [-1, 1) as it was: C's `<`
            text = open(src).read()
            new, old = '  if ( !(result >= -1.0f) )\n', '  if ( result < -1.0f )\n'
            if text.count(new) != 1:
                raise SystemExit('REFUSE --tooth: jx_h_3A2180 is not in its rewritten form')
            src = os.path.join(tmp, 'jx_voice_helpers.c')
            open(src, 'w').write(text.replace(new, old))
        files, inc = [src], ['-I', os.path.join(REPO, 'jx3p', 'src')]
    shim = os.path.join(tmp, 'shim.c')
    open(shim, 'w').write(shim_text(port))
    so = os.path.join(tmp, 'libnanh.so')
    r = subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-frounding-math', '-fsignaling-nans', '-fno-strict-aliasing', '-shared', '-fPIC', '-w'] +
                       inc + ['-o', so] + files + [shim, '-lm'], capture_output=True, text=True)
    if r.returncode:
        raise SystemExit('REFUSE: the helpers did not build:\n' + r.stderr[-2000:])
    return ctypes.CDLL(so)


def set_oracle_mode():
    """DAZ on, FTZ off -- the oracle's mode (a libc call would not reach MXCSR: one SSE intrinsic library)"""
    # the port's own switch lives in juno_ftz.c / jx_ftz.c; for a helper alone the MXCSR is set here through a tiny
    # library, so the comparison runs in the oracle's mode whatever the process inherited
    tmp = tempfile.mkdtemp(prefix='nanh_mx_')
    c = os.path.join(tmp, 'mx.c')
    open(c, 'w').write('#include <xmmintrin.h>\nvoid nanh_mx(unsigned v) { _mm_setcsr(v); }\n')
    so = os.path.join(tmp, 'libmx.so')
    subprocess.run(['cc', '-O2', '-shared', '-fPIC', '-o', so, c], check=True)
    ctypes.CDLL(so).nanh_mx(0x1F80 | 0x0040)        # all exceptions masked, DAZ on, FTZ off
    shutil.rmtree(tmp, True)


def main():
    a = sys.argv[1:]
    opt = lambda k, d=None: a[a.index(k) + 1] if k in a else d
    port, n = opt('--port-of', 'juno'), int(opt('--n', '400'))
    if a[:1] == ['--oracle']:
        json.dump(oracle(a[1], int(a[2]), int(a[3])), sys.stdout)
        return 0
    tooth = '--tooth' in a
    mode = '--tooth-mode' in a
    o = subprocess.run([sys.executable, __file__, '--oracle', port, str(n), str(0x1F80 if mode else MXCSR)],
                       capture_output=True, text=True)
    if o.returncode:
        raise SystemExit('oracle failed: ' + o.stderr[-2000:])
    ref = json.loads(o.stdout)
    tmp = tempfile.mkdtemp(prefix='nanh_')
    try:
        lib = port_lib(port, tmp, tooth)
        set_oracle_mode()
        bad = 0
        for name, rva, kind in HELPERS[port]:
            xs = inputs(kind, n)
            f = getattr(lib, 'nanh_' + name)
            t = ctypes.c_uint32 if kind == 'f' else ctypes.c_uint64
            f.restype, f.argtypes = t, [t]
            ys = [f(x) for x in xs]
            diff = [(x, r, y) for x, r, y in zip(xs, ref[name], ys) if r != y]
            w = 8 if kind == 'f' else 16
            print('  %-20s rva 0x%06X  %d inputs: %s' % (name, rva, len(xs), 'EQUAL' if not diff else
                                                           '%d DIFFER' % len(diff)))
            for x, r, y in diff[:6]:
                print('      in %0*x  plugin %0*x  port %0*x' % (w, x, w, r, w, y))
            bad += bool(diff)
    finally:
        shutil.rmtree(tmp, True)
    if tooth or mode:
        print('nan_helpers %s: %s' % ('--tooth' if tooth else '--tooth-mode',
                                      'BITES (%d helpers differ)' % bad if bad else 'DID NOT BITE'))
        return 0 if bad else 1
    print('nan_helpers %s: %d helpers, %s' % (port, len(HELPERS[port]), 'every output bit equal' if not bad else
                                              '%d DIFFER' % bad))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
