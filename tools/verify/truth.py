#!/usr/bin/env python3
"""truth.py -- the single source of ground-truth paths.

THE ONLY TRUTH is the original Roland Cloud JUNO-60 (JU-06A) VST3 binary and its
companion schema/bank. They live in the repo's truth/ folder. Every gate resolves
them through here -- never a hardcoded absolute path -- so a fresh checkout (or a
recycled container) reproduces every proof without editing 30-odd files.

Resolution order:
  1. $JUNO_TRUTH (a directory) if set -- lets you point at files kept outside git.
  2. <repo>/truth/  (computed relative to this file: tools/verify/ -> ../../truth).

Filenames are canonical: JUNO60.vst3, Script.xml, presetbankog1.bin.
truth/SHA256SUMS pins the exact bytes; call verify() to assert them.
"""
import os, hashlib

_HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(_HERE, '..', '..'))
TRUTH_DIR = os.environ.get('JUNO_TRUTH') or os.path.join(REPO, 'truth')

VST3       = os.path.join(TRUTH_DIR, 'JUNO60.vst3')
SCRIPT_XML = os.path.join(TRUTH_DIR, 'Script.xml')
BANK       = os.path.join(TRUTH_DIR, 'presetbankog1.bin')
SUMS       = os.path.join(TRUTH_DIR, 'SHA256SUMS')


def _sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1 << 20), b''):
            h.update(chunk)
    return h.hexdigest()


def verify():
    """Assert the ground-truth bytes match truth/SHA256SUMS. Returns True or raises."""
    want = {}
    with open(SUMS) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            digest, name = line.split(None, 1)
            want[name.strip()] = digest
    for name, digest in want.items():
        got = _sha256(os.path.join(TRUTH_DIR, name))
        if got != digest:
            raise RuntimeError("ground-truth mismatch for %s\n  want %s\n  got  %s\n"
                               "  (truth dir: %s)" % (name, digest, got, TRUTH_DIR))
    return True


def require():
    """Fail loudly if the ground truth is missing (fresh clone w/o binaries)."""
    for p in (VST3, SCRIPT_XML, BANK):
        if not os.path.exists(p):
            raise SystemExit(
                "ground truth missing: %s\n"
                "Put the JUNO-60 VST3 + Script.xml + presetbankog1.bin in %s\n"
                "(or set $JUNO_TRUTH). See truth/README.md." % (p, TRUTH_DIR))


if __name__ == '__main__':
    require()
    verify()
    print("ground truth OK (%s)" % TRUTH_DIR)
    for k in ('VST3', 'SCRIPT_XML', 'BANK'):
        print("  %-10s %s" % (k, globals()[k]))
