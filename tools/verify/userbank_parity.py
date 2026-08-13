#!/usr/bin/env python3
"""userbank_parity.py -- run the PORT'S OWN parity gates over a USER's banks.

WHY THIS EXISTS. Every parity claim in this repo is against ONE bank: the 64
factory patches in truth/presetbankog1.bin. That bank is a sample, not the
space. A parameter combination no factory patch reaches has never been through
recall or render on either side, and "bit-exact 64/64" says nothing about it.

The user supplied twelve banks of their own. Each is a full 64-patch
`KoaBankFile00003` / `PG-JU60` file -- byte-for-byte the same container as the
factory bank, header verified -- so the PLUGIN'S OWN parser handles them and no
new decoding is written. That matters: real_bank_parse.py documents a second,
transform-heavy parser that is the WRONG one for this container and produces
plausible garbage. Nothing here chooses a parser; the plugin does.

WHAT IT RUNS, per bank, against src/ -- the FROZEN BIT-EXACT PORT, not the fork:

  recall_gate        the port's cold post-recall state vs the PLUGIN'S OWN
                     recall enumerator, 67 voice cells, all 64 patches.
  recall_render_ab   full render A/B vs the plugin executed under Unicorn.
                     Bit-exact or it fails.

HOW IT POINTS THE GATES AT A DIFFERENT BANK. tools/verify/truth.py already
supports $JUNO_TRUTH. Each bank gets a scratch truth directory holding symlinks
to the REAL vst3 and Script.xml plus that bank as `presetbankog1.bin`, and a
SHA256SUMS regenerated for it so verify() still asserts the bytes it is given.

⚠ THE USER'S BANKS ARE NOT GROUND TRUTH AND MUST NOT BECOME IT. truth/ stays
exactly as it is. These directories live in scratchpad/, are never committed,
and the plugin binary they point at is the same one, by symlink, so there is no
second copy to drift. A bank is INPUT to the gate; the plugin is the oracle.

⚠ AND THE COVENANT IS UNAFFECTED. A bank file is plugin DATA, the same class as
truth/presetbankog1.bin and Script.xml -- it is read, executed through the
plugin's own parser, and never used to derive a coefficient. No audio capture is
involved anywhere in this tool.
"""
import os
import subprocess
import sys
import hashlib
import glob

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SCRATCH = os.path.join(REPO, 'scratchpad')
BANKDIR = os.path.join(SCRATCH, 'userbanks')

sys.path.insert(0, HERE)
import truth  # noqa: E402


def sha(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for b in iter(lambda: f.read(1 << 20), b''):
            h.update(b)
    return h.hexdigest()


def make_truthdir(bank):
    """A truth directory for ONE bank. Symlinks the real plugin; copies nothing
    that could drift."""
    name = os.path.splitext(os.path.basename(bank))[0]
    d = os.path.join(SCRATCH, 'truthdirs', name)
    os.makedirs(d, exist_ok=True)
    for src, dst in ((truth.VST3, 'JUNO60.vst3'),
                     (truth.SCRIPT_XML, 'Script.xml')):
        link = os.path.join(d, dst)
        if os.path.islink(link) or os.path.exists(link):
            os.remove(link)
        os.symlink(os.path.abspath(src), link)
    blink = os.path.join(d, 'presetbankog1.bin')
    if os.path.islink(blink) or os.path.exists(blink):
        os.remove(blink)
    os.symlink(os.path.abspath(bank), blink)
    with open(os.path.join(d, 'SHA256SUMS'), 'w') as f:
        for fn in ('JUNO60.vst3', 'Script.xml', 'presetbankog1.bin'):
            f.write('%s  %s\n' % (sha(os.path.join(d, fn)), fn))
    return d, name


def run(cmd, env, log):
    with open(log, 'ab') as lf:
        lf.write(b'\n$ ' + ' '.join(cmd).encode() + b'\n')
        lf.flush()
        return subprocess.call(cmd, cwd=REPO, env=env, stdout=lf, stderr=lf)


def one_bank(bank, rates):
    d, name = make_truthdir(bank)
    env = dict(os.environ)
    env['JUNO_TRUTH'] = d
    # Per-bank scratch names, so one bank's reference can never be read as
    # another's. A stale pickle silently passing is the exact failure this
    # project has already had twice.
    env['JUNO_SCRATCH_TAG'] = name
    log = os.path.join(SCRATCH, 'userparity_%s.log' % name)
    open(log, 'wb').close()

    results = {}
    # ⚠ BOTH SIDES, EVERY BANK. The first run of this driver regenerated the
    # PLUGIN reference for the new bank and left scratchpad/port_state.pkl from
    # the FACTORY bank -- so it compared Chillwave against the factory patches
    # and reported 51 mismatched cells on nearly every patch. That is not a
    # finding, it is the stale-pickle trap this project has already paid for
    # twice (see CLAUDE.md's stale-artifact warnings). A parity driver that
    # refreshes one side of a comparison is worse than no driver.
    rc = run(['python3', 'tools/verify/plugin_recall_ref.py'], env, log)
    results['recall_ref'] = rc
    rp = run(['python3', 'tools/verify/port_state_dump.py'], env, log)
    results['port_dump'] = rp
    if rc == 0 and rp == 0:
        results['recall_gate'] = run(
            ['python3', 'tools/verify/recall_gate.py'], env, log)
    for sr in rates:
        e = dict(env)
        e['JUNO_RENDER_SR'] = str(sr)
        e['JUNO_RENDER_REF_PKL'] = os.path.join(
            SCRATCH, 'render_ref_%s_%d.pkl' % (name, sr))
        r = run(['python3', 'tools/verify/recall_render_ab.py', '--ref'], e, log)
        if r == 0:
            r = run(['python3', 'tools/verify/recall_render_ab.py', '--port'],
                    e, log)
        results['render_%d' % sr] = r
    return name, results, log


def main():
    banks = sorted(glob.glob(os.path.join(BANKDIR, '*.bin')))
    if not banks:
        print('no banks in %s' % BANKDIR)
        return 2
    only = None
    rates = [44100]
    argv = sys.argv[1:]
    if '--only' in argv:
        only = argv[argv.index('--only') + 1]
    if '--rates' in argv:
        rates = [int(x) for x in argv[argv.index('--rates') + 1].split(',')]
    if only:
        banks = [b for b in banks if only in b]

    print('=== USER BANK PARITY -- against src/, the FROZEN BIT-EXACT PORT ===')
    print('banks: %d   patches: %d   rates: %s'
          % (len(banks), 64 * len(banks), rates))
    print('The oracle is the PLUGIN executed under Unicorn. A bank is input.\n')

    bad = 0
    for b in banks:
        name, res, log = one_bank(b, rates)
        verdict = 'PASS' if all(v == 0 for v in res.values()) else 'FAIL'
        if verdict == 'FAIL':
            bad += 1
        print('%-34s %s   %s' % (name, verdict,
                                 ' '.join('%s=%d' % (k, v)
                                          for k, v in sorted(res.items()))))
        print('    log: %s' % log)

    print('\n%d of %d banks FAILED' % (bad, len(banks)))
    print('A FAILING PATCH IS A FINDING, NOT NECESSARILY A DEFECT IN THE GATE:')
    print('the factory bank is a sample of the parameter space, and a')
    print('combination it never reaches has never been tested on either side.')
    return 1 if bad else 0


if __name__ == '__main__':
    raise SystemExit(main())
