"""The render object's teeth (CLAIMS B13): host_process_gate.py --port against mutated builds of the
port, each a defect the gate must see. Builds each mutant in a temporary directory (the tree is not
touched), loads it in this process only (libjuno only: two-process rule), runs the gate's port check
on the render-object chains (cv*, sil*), prints how many chains each mutant breaks.

    python3 probes/host_render/conv_teeth.py      (needs cc and scratchpad/host_process_ref.pkl)"""
import ctypes
import glob
import os
import shutil
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))

MUTANTS = [
    ('memmove_shift', 'the history shift as a true shift (memmove), not the plugin\'s upward copy',
     'src/juno_conv.c',
     'for (i = 0; i < v15; ++i) b[i] = (i + off < 0) ? 0.0f : b[i + off];',
     'if (off >= 0) memmove(b, b + off, (size_t)v15 * sizeof(float)); else { memmove(b + 1, b, (size_t)(v15 - 1) * sizeof(float)); b[0] = 0.0f; }'),
    ('no_scale', 'the output without the (float)L scale',
     'src/juno_conv.c', 'out[ch][j] = (float)L * sum;', 'out[ch][j] = sum;'),
    ('taps_reversed', 'the backward taps summed before the forward taps',
     'src/juno_conv.c', 'int k = r ? L - r : 0;                 /* the forward taps */',
     'int k = nh;  /* forward taps skipped here, summed after the backward ones below */'),
    ('silence_renders', 'the silence object rendering the engine (identity)',
     'gui/juno_bridge.c', 'kind = c->ro_model ? JUNO_RO_IDENTITY : juno_ro_kind(&c->ro);',
     'kind = c->ro_model ? JUNO_RO_IDENTITY : juno_ro_kind(&c->ro); if (kind == JUNO_RO_SILENCE) kind = JUNO_RO_IDENTITY;'),
]


def build(tmp, name, path, old, new):
    d = os.path.join(tmp, name)
    shutil.copytree(os.path.join(REPO, 'src'), os.path.join(d, 'src'))
    os.makedirs(os.path.join(d, 'gui'))
    shutil.copy(os.path.join(REPO, 'gui', 'juno_bridge.c'), os.path.join(d, 'gui', 'juno_bridge.c'))
    f = os.path.join(d, path)
    s = open(f).read()
    if s.count(old) != 1:
        raise SystemExit('%s: the mutation site is not unique in %s' % (name, path))
    s = s.replace(old, new)
    if name == 'taps_reversed':      # the forward taps after the backward ones
        s = s.replace('            out[ch][j] = (float)L * sum;',
                      '            k = r ? L - r : 0;\n'
                      '            if (k < nh) { int xi = (pos - v35 + k) / L; do { memcpy(&hk, &h[k], 4);'
                      ' sum = sum + x[xi] * hk; k += L; ++xi; } while (k < nh); }\n'
                      '            out[ch][j] = (float)L * sum;')
    open(f, 'w').write(s)
    so = os.path.join(d, 'libjuno.so')
    cmd = ['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC', '-o', so,
           os.path.join(d, 'gui', 'juno_bridge.c')] + sorted(glob.glob(os.path.join(d, 'src', '*.c'))) + ['-lm']
    subprocess.check_call(cmd)
    return so


def main():
    import freshlib
    import host_process_gate as G
    only = [c[0] for c in G.chains() if c[0].startswith(('cv', 'sil'))]
    res = {}
    with tempfile.TemporaryDirectory() as tmp:
        for name, what, path, old, new in MUTANTS:
            so = build(tmp, name, path, old, new)
            freshlib.load = lambda *a, so=so, **k: ctypes.CDLL(so)
            print('--- mutant %s: %s' % (name, what), flush=True)
            res[name] = G.check_port(tooth='mutant', only=only)
    print()
    for name, what, path, old, new in MUTANTS:
        print('%-16s %s (%d chains differ)' % (name, 'BITES' if res[name] else 'DID NOT BITE', res[name]))
    return 0 if all(res.values()) else 1


if __name__ == '__main__':
    sys.exit(main())
