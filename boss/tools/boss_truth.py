#!/usr/bin/env python3
"""boss_truth.py -- the single source of ground-truth paths for the BOSS Effects
Pedals port (the twin of tools/verify/truth.py).

THE ONLY TRUTH is the Roland Cloud "BOSS Effects Pedals" VST3 binary in
boss/truth/, with its Script folder (Script.xml + the other XML, TextCodeTable.dat,
Initial.bin, BX00_DATA.BIN, the GUI art) in boss/truth/Script/ and the factory
presets (Preset<model>.bin) in boss/truth/Preset/, all as the user supplied them.
Every BOSS tool resolves them through here -- never a hardcoded path.

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

VST3       = os.path.join(TRUTH_DIR, 'BOSS_Effects_Pedals.vst3')
SCRIPT_DIR = os.path.join(TRUTH_DIR, 'Script')
SCRIPT_XML = os.path.join(SCRIPT_DIR, 'Script.xml')
TEXT_CODE  = os.path.join(SCRIPT_DIR, 'TextCodeTable.dat')
INITIAL    = os.path.join(SCRIPT_DIR, 'Initial.bin')
BX00_DATA  = os.path.join(SCRIPT_DIR, 'BX00_DATA.BIN')
PRESET_DIR = os.path.join(TRUTH_DIR, 'Preset')
SUMS       = os.path.join(TRUTH_DIR, 'SHA256SUMS')


def preset(model):
    """The factory preset file of one pedal model, e.g. preset('DS1')."""
    return os.path.join(PRESET_DIR, 'Preset%s.bin' % model.upper().replace('-', ''))


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
    for p in (VST3, SCRIPT_XML, TEXT_CODE, INITIAL, BX00_DATA, SUMS):
        if not os.path.exists(p):
            raise SystemExit("ground truth missing: %s\n(truth dir %s, or set $BOSS_TRUTH)"
                             % (p, TRUTH_DIR))


def _tooth():
    """The check must FAIL on one flipped byte (a scratch copy; truth untouched)."""
    with tempfile.TemporaryDirectory() as t:
        shutil.copytree(TRUTH_DIR, t, dirs_exist_ok=True)
        dst = os.path.join(t, os.path.basename(VST3))
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
    n = sum(1 for l in open(SUMS) if l.strip())
    print("OK  %d files pinned; %s  %s" % (n, os.path.basename(VST3), _sha256(VST3)))
    if '--tooth' in sys.argv:
        if not _tooth():
            raise SystemExit("TOOTH FAILED: a flipped byte passed verify()")
        print("TOOTH bites: one flipped byte -> mismatch")
