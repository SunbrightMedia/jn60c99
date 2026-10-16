#!/usr/bin/env python3
"""boss_truth.py -- the single source of ground-truth paths for the BOSS Effects
Pedals port (the twin of tools/verify/truth.py).

THE ONLY TRUTH is the Roland Cloud "BOSS Effects Pedals" VST3 binary in
boss/truth/. Every BOSS tool resolves it through here -- never a hardcoded path.

Resolution order:
  1. $BOSS_TRUTH (a directory) if set.
  2. <repo>/boss/truth/  (relative to this file: boss/tools/ -> ../truth).

boss/truth/SHA256SUMS pins the exact bytes; verify() asserts them.
`python3 boss/tools/boss_truth.py` verifies; `--tooth` proves the check bites
(one flipped byte in a scratch copy must fail).
"""
import os, sys, hashlib, shutil, tempfile

_HERE = os.path.dirname(os.path.abspath(__file__))
TRUTH_DIR = os.environ.get('BOSS_TRUTH') or os.path.join(_HERE, '..', 'truth')
TRUTH_DIR = os.path.abspath(TRUTH_DIR)

VST3 = os.path.join(TRUTH_DIR, 'BOSS_Effects_Pedals.vst3')
SUMS = os.path.join(TRUTH_DIR, 'SHA256SUMS')


def _sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def verify(truth_dir=None):
    """Assert every file in SHA256SUMS matches. Returns True or raises."""
    d = truth_dir or TRUTH_DIR
    want = {}
    with open(os.path.join(d, 'SHA256SUMS')) as f:
        for line in f:
            if line.strip():
                digest, name = line.split(None, 1)
                want[name.strip()] = digest
    if not want:
        raise RuntimeError("SHA256SUMS is empty (truth dir: %s)" % d)
    for name, digest in want.items():
        got = _sha256(os.path.join(d, name))
        if got != digest:
            raise RuntimeError("ground-truth mismatch for %s\n  want %s\n  got  %s\n"
                               "  (truth dir: %s)" % (name, digest, got, d))
    return True


def require():
    """Fail loudly if the ground truth is missing."""
    if not os.path.exists(VST3):
        raise SystemExit("ground truth missing: %s\nPut BOSS_Effects_Pedals.vst3 in %s "
                         "(or set $BOSS_TRUTH)." % (VST3, TRUTH_DIR))


def _tooth():
    """The check must FAIL on one flipped byte (a scratch copy; truth untouched)."""
    with tempfile.TemporaryDirectory() as t:
        shutil.copy(SUMS, t)
        dst = os.path.join(t, os.path.basename(VST3))
        shutil.copy(VST3, dst)
        with open(dst, 'r+b') as f:
            f.seek(0x1000)
            b = f.read(1)
            f.seek(0x1000)
            f.write(bytes([b[0] ^ 1]))
        try:
            verify(t)
        except RuntimeError:
            return True
    return False


if __name__ == '__main__':
    require()
    verify()
    print("OK  %s  %s" % (os.path.basename(VST3), _sha256(VST3)))
    if '--tooth' in sys.argv:
        if not _tooth():
            raise SystemExit("TOOTH FAILED: a flipped byte passed verify()")
        print("TOOTH bites: one flipped byte -> mismatch")
