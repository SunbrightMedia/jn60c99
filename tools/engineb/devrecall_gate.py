#!/usr/bin/env python3
"""devrecall_gate.py -- THE DEVICE-RECALL GATE. Runnable standalone.

    python3 tools/engineb/devrecall_gate.py            # both flag sets + teeth
    python3 tools/engineb/devrecall_gate.py --quick    # trunk defaults only
    python3 tools/engineb/devrecall_gate.py --no-teeth

WHAT IT PROVES, and what it does not.

It builds the SAME sources twice. One build addresses the port's flat 11 MB
cell array; the other has JF/JI (and eb_coefs.c's CF, and the raw pointer
casts) rebased onto engine_b/dev/ebdev.h's ~25 KB device array. Both then run
an identical scenario list and their `eb_render_coefs`, `eb_master_coef` and
`eb_render_state` are compared byte for byte.

So it is a complete proof that the address map is CORRECT AND COMPLETE for
everything the scenarios reach, and a proof of NOTHING about Xtensa: both
halves are the same host compiler on the same sources. That limitation is the
2026-08-11 gate's and it has not moved. Not one instruction of recall has
executed on the chip.

THREE THINGS THE 2026-08-11 GATE DID NOT DO, each of which hid a defect:

  * it never issued a NOTE, so it never ran eb_render_state_seed or
    eb_render_events_mirror, so seven per-voice cells were never written and a
    five-cell scatter looked sufficient. It is twelve.
  * it never ran a SEQUENCE, so warm recall was never exercised at all.
  * it never called the publish path, so the publish contract had no gate.

TEETH. A gate that has never been seen to fail is not a gate. Every check
below has a deliberate defect that must make it fail, and any tooth that does
NOT fire is printed as NOT CAUGHT rather than quietly dropped.
"""
import argparse
import os
import re
import shutil
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
BUILD = os.path.join(REPO, 'build', 'devrecall')
REPO_DEV = os.path.join(REPO, 'engine_b', 'dev')
TOOTH_HDR = os.path.join(BUILD, 'toothhdr')     # teeth regenerate HERE, never
                                                # over the checked-in headers
BANK = os.path.join(REPO, 'truth', 'presetbankog1.bin')
CC = os.environ.get('CC', 'cc')
BASE_CFLAGS = ['-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing',
               '-w']

# The two flag sets the gate runs at.
FLAGSETS = [
    ('trunk defaults', []),
    ('shipping fork', ['-DEB_FORK_S3', '-DEB_LFO_SHARED=1', '-DEB_VCF_RES_LUT=256']),
]

# ---------------------------------------------------------------- the fork
#
# The device build is the port's own sources with every state access rebased.
# The edits are textual and MECHANICAL, and each one is checked to have
# applied -- a rewrite that silently matched nothing is how a device build
# ends up half-rebased and crashing on a wild pointer, which is what happened
# the first time this was attempted. DESIGN_full.md 1.5 names all 17 raw-cast
# sites; they are the `RAW` entries below.
FORK = [
    ('src/juno_engine.h', [
        ('#define JF(st, off)  (*(float   *)((unsigned char *)(st) + (off)))   /* float  */\n'
         '#define JI(st, off)  (*(int32_t *)((unsigned char *)(st) + (off)))   /* int32  */',
         '#include "ebdev.h"\n'
         '#define JF(st, off)  (*(float   *)ebdev_at((unsigned long)(off)))\n'
         '#define JI(st, off)  (*(int32_t *)ebdev_at((unsigned long)(off)))'),
    ]),
    ('src/delay_recall.c', [
        ('#include "juno_engine.h"', '#include "juno_engine.h"\n#include "ebdev.h"'),
        (r'RE:\*\(int32_t \*\)\(state \+ ([A-Z_0-9]+)\)',
         r'*(int32_t *)ebdev_at((unsigned long)(\1))'),
    ]),
    ('src/effect_modes.c', [
        ('#include "juno_engine.h"', '#include "juno_engine.h"\n#include "ebdev.h"'),
        ('*(uint32_t *)(state + tbl[i].off)', '*(uint32_t *)ebdev_at((unsigned long)tbl[i].off)'),
        ('*(int32_t *)(state + JUNO_PROG_EFX)', '*(int32_t *)ebdev_at((unsigned long)(JUNO_PROG_EFX))'),
    ]),
    ('src/reverb_recall.c', [
        ('#include "juno_engine.h"', '#include "juno_engine.h"\n#include "ebdev.h"'),
        ('*(int32_t *)(state + 10759872)', '*(int32_t *)ebdev_at((unsigned long)(10759872))'),
    ]),
    ('src/juno_driver.c', [
        ('#include "juno_engine.h"', '#include "juno_engine.h"\n#include "ebdev.h"'),
        ('p39  = (int32_t *)(st + JUNO_PROG_DLY);',
         'p39  = (int32_t *)ebdev_at((unsigned long)(JUNO_PROG_DLY));'),
        ('p551 = (int32_t *)(st + JUNO_PROG_EFX);',
         'p551 = (int32_t *)ebdev_at((unsigned long)(JUNO_PROG_EFX));'),
        ('memcpy(st + 136, &base, sizeof(void *));',
         'memcpy(ebdev_at(136u), &base, sizeof(void *));'),
        # seed_voices IS the broadcast on the device: the voice blocks are not
        # contiguous, so the memcpy has nothing to copy. Rewriting it here --
        # rather than just not calling it -- keeps the two halves' driver code
        # textually parallel, so a future caller cannot get a silent no-op.
        ('        memcpy(st + block + (unsigned)v * JUNO_VOICE_MAIN_STRIDE,\n'
         '               st + block, JUNO_VOICE_MAIN_STRIDE);',
         '        (void)v;\n    ebdev_broadcast_scatter();'),
        ('memcpy(nblk, st + JUNO_NOISE_BLOCK_OFF, JUNO_NOISE_BLOCK_LEN);',
         'memcpy(nblk, ebdev_at(JUNO_NOISE_BLOCK_OFF), JUNO_NOISE_BLOCK_LEN);'),
        ('memcpy(st + JUNO_NOISE_BLOCK_OFF, nblk, JUNO_NOISE_BLOCK_LEN);',
         'memcpy(ebdev_at(JUNO_NOISE_BLOCK_OFF), nblk, JUNO_NOISE_BLOCK_LEN);'),
    ]),
    ('engine_b/eb_coefs.c', [
        ('#define VBASE(b, v)  ((const unsigned char *)(b) + (unsigned)(v) * 10512u)\n'
         '#define CF(p, off)   (*(const float *)((const unsigned char *)(p) + (off)))',
         '#include "ebdev.h"\n'
         '/* the per-voice read: poke voice v\'s SCATTER into the shared tile, then\n'
         ' * read the tile. The twelve scatter cells are the only ones that differ\n'
         ' * between voices; everything else in the block is voice-invariant and one\n'
         ' * tile is exact for it (MEASURED: 0 of 8 divergent over 192 cases). */\n'
         '#define VBASE(b, v)  (ebdev_voice_select((v)), (const unsigned char *)EBDEV_S.v0)\n'
         '#define CF(p, off)   (*(const float *)(((const unsigned char *)(p) == (const unsigned char *)EBDEV_S.v0) \\\n'
         '                       ? (const void *)((const unsigned char *)(p) + (off))                            \\\n'
         '                       : (const void *)ebdev_at((unsigned long)(off))))'),
        ('*(float *)(base + aux) = 0.0f;', '*(float *)ebdev_at(aux) = 0.0f;'),
    ]),
    ('engine_b/eb_master_coefs.c', [
        ('#define CF(p, off)  (*(const float *)((const unsigned char *)(p) + (off)))\n'
         '#define CI(p, off)  (*(const int32_t *)((const unsigned char *)(p) + (off)))',
         '#include "ebdev.h"\n'
         '#define CF(p, off)  (*(const float *)ebdev_at((unsigned long)(off)))\n'
         '#define CI(p, off)  (*(const int32_t *)ebdev_at((unsigned long)(off)))'),
        ('(const int32_t *)(base + 11022064)', '(const int32_t *)ebdev_at(11022064u)'),
    ]),
    ('engine_b/eb_chorus_shim.c', [
        ('#include "eb_chorus_shim.h"', '#include "eb_chorus_shim.h"\n#include "ebdev.h"'),
        ('    float f; memcpy(&f, b + off, 4); return f;',
         '    float f; (void)b; memcpy(&f, ebdev_at((unsigned long)off), 4); return f;'),
        ('    int32_t i; memcpy(&i, b + off, 4); return i;',
         '    int32_t i; (void)b; memcpy(&i, ebdev_at((unsigned long)off), 4); return i;'),
    ]),
]

# Sources both halves compile. engine_b/eb_render.c and friends are NOT here:
# the gate builds coefficients and state, it does not render.
SRC_DIRS = ['src', 'engine_b']


def sh(cmd, **kw):
    r = subprocess.run(cmd, capture_output=True, text=True, **kw)
    return r


def make_tree(dev, flags, hdr=None):
    """Copy src/ + engine_b/ into a build dir; apply the fork if dev.

    `hdr` overrides where the two GENERATED headers come from. The teeth use
    it to generate a broken map into a scratch directory instead of writing
    over engine_b/dev/. That is not tidiness: on 2026-08-12 an unrelated
    process committed this repo while a tooth had the 12-cell scatter header
    temporarily replaced by an 11-cell one, and the tooth-damaged file went in
    as `eeda697`. A gate that briefly corrupts checked-in generated files WILL
    eventually have that corruption snapshotted."""
    root = os.path.join(BUILD, ('dev' if dev else 'host') + '_' + flags)
    if os.path.exists(root):
        shutil.rmtree(root)
    os.makedirs(root)
    files = []
    for d in SRC_DIRS:
        for fn in sorted(os.listdir(os.path.join(REPO, d))):
            if fn.endswith('.c') or fn.endswith('.h'):
                shutil.copy(os.path.join(REPO, d, fn), os.path.join(root, fn))
                if fn.endswith('.c'):
                    files.append(fn)
    for fn in ('ebdev.h', 'ebdev.c', 'ebdev_seg.h', 'ebdev_map.h',
               'eb_recall.h', 'eb_recall.c'):
        srcdir = REPO_DEV
        if hdr and fn in ('ebdev_seg.h', 'ebdev_map.h') \
                and os.path.exists(os.path.join(hdr, fn)):
            srcdir = hdr
        shutil.copy(os.path.join(srcdir, fn), os.path.join(root, fn))
    if dev:
        files.append('ebdev.c')
        files.append('eb_recall.c')
    if dev:
        for path, edits in FORK:
            fn = os.path.basename(path)
            p = os.path.join(root, fn)
            txt = open(p).read()
            for old, new in edits:
                if old.startswith('RE:'):
                    txt, n = re.subn(old[3:], new, txt)
                    if n == 0:
                        sys.exit('FORK PATCH MISSED (regex): %s :: %s' % (fn, old))
                else:
                    if old not in txt:
                        sys.exit('FORK PATCH MISSED: %s :: %r' % (fn, old[:60]))
                    txt = txt.replace(old, new)
            open(p, 'w').write(txt)
        # nothing may still reach the flat array
        for fn in ('delay_recall.c', 'effect_modes.c', 'reverb_recall.c',
                   'juno_driver.c', 'eb_coefs.c', 'eb_master_coefs.c'):
            txt = open(os.path.join(root, fn)).read()
            for pat in (r'\*\(\s*(?:const\s+)?(?:float|int32_t|uint32_t)\s*\*\s*\)\s*\(\s*(?:state|st|base)\s*\+',):
                m = re.search(pat, txt)
                if m:
                    sys.exit('FORK INCOMPLETE: %s still has a raw cast at %d'
                             % (fn, m.start()))
    # drop the .c files that pull in things the gate does not need and that
    # would drag the whole render path in
    # engine_b/ holds a handful of standalone probe mains beside the engine;
    # they are not engine sources and several refuse to compile without their
    # own -D. juno_ftz.c is the port's flush-to-zero sweep, not recall.
    drop = {'engineb_stub.c'}
    files = [f for f in files if not f.startswith('test_')]
    files = [f for f in files if f not in drop]
    return root, files


def build(dev, tag, cflags, extra=(), hdr=None):
    root, files = make_tree(dev, tag, hdr)
    out = os.path.join(BUILD, ('gate_dev_' if dev else 'gate_host_') + tag)
    cmd = [CC] + BASE_CFLAGS + list(cflags) + list(extra)
    if dev:
        cmd += ['-DGATE_DEV']
    cmd += ['-I' + root, '-o', out,
            os.path.join(HERE, 'devrecall', 'gate.c')] + \
           [os.path.join(root, f) for f in files] + ['-lm']
    r = sh(cmd)
    if r.returncode:
        print(r.stdout[-4000:]); print(r.stderr[-6000:])
        sys.exit('BUILD FAILED (%s %s)' % ('dev' if dev else 'host', tag))
    return out


def run(binpath, outbin, bootbin, case=None):
    cmd = [binpath, BANK, outbin, bootbin]
    if case is not None:
        cmd.append(str(case))
    r = sh(cmd, cwd=BUILD)          # devrecall_miss.txt lands in build/, not the repo
    return r.returncode, r.stdout + r.stderr


def first_diff(a, b):
    n = min(len(a), len(b))
    for i in range(n):
        if a[i] != b[i]:
            return i
    return -1 if len(a) == len(b) else n


def compare(hostbin, devbin, rec, ncase):
    A = open(hostbin, 'rb').read()
    B = open(devbin, 'rb').read()
    if len(A) != len(B):
        return None, 'SIZE MISMATCH host %d dev %d' % (len(A), len(B))
    bad = []
    for c in range(ncase):
        s = c * rec
        if A[s:s + rec] != B[s:s + rec]:
            bad.append(c)
    return bad, ''


SEQ = ['cold', 'warm A->B', 'warm A->edit->B']


def case_name(c, nseq, nrate, npatch):
    trial = c // (nseq * nrate * npatch)
    c2 = c % (nseq * nrate * npatch)
    seq = c2 // (nrate * npatch)
    c3 = c2 % (nrate * npatch)
    r = c3 // npatch
    p = c3 % npatch
    return '%s bank, %s, rate %d, patch %d' % (
        'factory' if trial == 0 else 'synthetic', SEQ[seq],
        [44100, 48000, 96000][r], p)


def sizing():
    """THE ARRAY SIZE, COMPILED not arithmetic.

    `sizeof(ebdev_state)` is printed by the gate at NV=8 because that is what
    the host half runs. The device runs SIX voices, so the number that matters
    is not on the gate's own output path -- it is measured here by compiling
    ebdev.c at each voice count and printing the compiler's own sizeof. Doing
    it by hand is exactly the subtraction this project has been told is not a
    measurement."""
    print('\n' + '=' * 74)
    print('THE DEVICE CELL ARRAY')
    print('=' * 74)
    src = os.path.join(BUILD, 'size.c')
    open(src, 'w').write(
        '#include <stdio.h>\n#include "ebdev.h"\n'
        'int main(void){\n'
        '  printf("NV=%d  ebdev_state = %u B  (tile %u + segments %u + '
        'scatter %dx%d floats = %u + header %u)\\n",\n'
        '     EBDEV_NV, (unsigned)sizeof(ebdev_state), EBDEV_VTILE,\n'
        '     EBDEV_SEGBYTES, EBDEV_NV, EBDEV_NSCAT,\n'
        '     (unsigned)(EBDEV_NV*EBDEV_NSCAT*4),\n'
        '     (unsigned)(sizeof(ebdev_state)-EBDEV_VTILE-EBDEV_SEGBYTES'
        '-EBDEV_NV*EBDEV_NSCAT*4));\n'
        '  printf("      map selftest (chain vs table, exhaustive): %ld '
        'disagreements\\n", ebdev_selftest());\n'
        '  return ebdev_selftest()!=0;}\n')
    bad = 0
    for nv in (6, 8):
        exe = os.path.join(BUILD, 'size%d' % nv)
        r = sh([CC, '-std=c99', '-O2', '-w', '-DEBDEV_NV=%d' % nv,
                '-I' + os.path.join(REPO, 'engine_b', 'dev'),
                '-o', exe, src, os.path.join(REPO, 'engine_b/dev/ebdev.c')])
        if r.returncode:
            print(r.stderr[-1500:]); bad = 1; continue
        r = sh([exe])
        print(r.stdout.strip())
        bad |= r.returncode
    print('For scale: replicating the whole voice block per voice instead of '
          'the\nscatter is %u B at NV=6 and %u B at NV=8 -- 2.8x.'
          % (10688 * 6 + 19180 + 16, 10688 * 8 + 19180 + 16))
    return bad


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--quick', action='store_true', help='trunk defaults only')
    ap.add_argument('--no-teeth', action='store_true')
    ap.add_argument('--keep', action='store_true')
    ap.add_argument('--patch-scan', action='store_true',
                    help='re-measure the recall-affecting record positions '
                         '(~10 min) and check eb_patch.c carries every one')
    a = ap.parse_args()

    if not os.path.exists(BANK):
        sys.exit('no bank at %s' % BANK)
    os.makedirs(BUILD, exist_ok=True)

    # the generated headers must be current or the gate is proving a stale map
    r = sh([sys.executable, os.path.join(HERE, 'gen_devcells.py'), '--check'])
    print(r.stdout.strip() or r.stderr.strip())
    if r.returncode:
        sys.exit('ebdev_seg.h / ebdev_map.h are STALE -- run gen_devcells.py')

    flagsets = FLAGSETS[:1] if a.quick else FLAGSETS
    overall = 0
    for name, cflags in flagsets:
        tag = name.split()[0]
        print('\n' + '=' * 74)
        print('FLAGS: %s   %s' % (name, ' '.join(cflags) or '(none)'))
        print('=' * 74)
        t0 = time.time()
        hb = build(False, tag, cflags)
        db = build(True, tag, cflags, extra=['-DEBDEV_INSTRUMENT'])
        ds = build(True, tag + '_ship', cflags)        # the inline-chain build
        boot = os.path.join(BUILD, 'boot_%s.bin' % tag)
        ho = os.path.join(BUILD, 'host_%s.bin' % tag)
        do = os.path.join(BUILD, 'dev_%s.bin' % tag)
        so = os.path.join(BUILD, 'ship_%s.bin' % tag)

        rc, out = run(hb, ho, boot)
        print(out.strip())
        if rc:
            sys.exit('host half failed')
        m = re.search(r'= (\d+) B/case', out)
        rec = int(m.group(1))
        ncase = int(re.search(r'(\d+) cases', out).group(1))

        rc, out = run(db, do, boot)
        print(out.strip())
        devfail = rc
        rc2, out2 = run(ds, so, boot)
        print('SHIPPING (inline-chain) half:', out2.strip().splitlines()[0]
              if out2.strip() else '(no output)')
        for ln in out2.strip().splitlines():
            if 'SELFTEST' in ln or 'UNMAPPED' in ln or 'cell array' in ln:
                print('   ' + ln)

        bad, err = compare(ho, do, rec, ncase)
        if err:
            print(err); overall = 1; continue
        bad2, err2 = compare(ho, so, rec, ncase)

        print('-' * 74)
        if not bad and not bad2 and not devfail and not rc2:
            print('*** BIT-IDENTICAL over %d cases (instrumented AND shipping map) ***'
                  % ncase)
        else:
            overall = 1
            print('*** FAILED: %d of %d cases differ (instrumented map) ***'
                  % (len(bad), ncase))
            print('*** FAILED: %d of %d cases differ (shipping map) ***'
                  % (len(bad2), ncase))
            for c in (bad or bad2)[:8]:
                A = open(ho, 'rb').read()[c * rec:(c + 1) * rec]
                B = open(do if bad else so, 'rb').read()[c * rec:(c + 1) * rec]
                print('   case %d (%s) first differing byte %d'
                      % (c, case_name(c, 3, 3, 64), first_diff(A, B)))
        print('elapsed %.0fs' % (time.time() - t0))

        # ------------------------------------------ the publish contract (D3)
        rc3, out3 = run(ds, so, boot, case='publish')
        print(out3.strip())
        if rc3:
            overall = 1

        # ---------------------------------------------------------- the D1 fact
        warm_vs_cold(ho, rec)
        overall |= et2_check(tag, cflags, ho, boot, rec)

        if a.quick:
            break

    overall |= sizing()
    overall |= patch_check(a.patch_scan)

    if not a.no_teeth:
        overall |= teeth()

    print('\n' + '=' * 74)
    print('DEVRECALL GATE: %s' % ('PASS' if overall == 0 else 'FAIL'))
    return overall


def warm_vs_cold(hostbin, rec):
    """How order-dependent is the PORT itself? Measured off the host half's own
    output, so it costs nothing and it is the D1 number in the gate."""
    A = open(hostbin, 'rb').read()
    npatch, nrate, nseq = 64, 3, 3
    per_seq = nrate * npatch
    nrc, nmc = 10564, 1704
    print('D1  THE PORT IS ORDER-DEPENDENT. Measured here, on the host half\'s own')
    print('    output: patch A then patch B is not patch B alone. The device')
    print('    recalls WARM, so the gate\'s reference for a warm case is the same')
    print('    SEQUENCE on the host -- never a cold recall of the same patch.')
    for trial, tname in ((0, 'factory'), (1, 'synthetic')):
        base = trial * nseq * per_seq
        for seq, sname in ((1, 'warm A->B', ), (2, 'warm A->edit->B')):
            d = [0, 0, 0, 0]
            for i in range(per_seq):
                c0, c1 = base + i, base + seq * per_seq + i
                a = A[c0 * rec:(c0 + 1) * rec]
                b = A[c1 * rec:(c1 + 1) * rec]
                if a != b:
                    d[0] += 1
                if a[:nrc] != b[:nrc]:
                    d[1] += 1
                if a[nrc:nrc + nmc] != b[nrc:nrc + nmc]:
                    d[2] += 1
                if a[nrc + nmc:] != b[nrc + nmc:]:
                    d[3] += 1
            print('    %-10s %-16s any %3d/%d  render_coefs %3d  master_coef %3d'
                  '  render_state %3d' % (tname, sname, d[0], per_seq,
                                          d[1], d[2], d[3]))


def et2_check(tag, cflags, hostbin, boot, rec):
    """THE PORT DEFECT D1 TURNED UP, and its own tooth.

    src/chorus_recall.c wrote the chorus LFO rate cell 91152 for EFFECT TYPE 3
    and 4 and NOT for EFFECT TYPE 2, while the plugin's own EFFECT TYPE setter
    writes 0.96f/H for type 2 (PROVEN by isolated dispatch of index 873 under
    Unicorn, four rates -- probes/iso873.py, rates873.py). From a cold engine
    the missing write is the IDENTITY, which is why every gate in this repo
    passed; warm, after a chorus II patch, a chorus I patch keeps chorus II's
    LFO rate, 1.71x too fast, and master_render.c:2783 reads it every sample.

    This builds the host half with the fix REMOVED and requires exactly two
    things, which together are the whole claim:
       COLD  cases IDENTICAL  -- the fix cannot disturb the 57/57 seal
       WARM  cases DIFFER     -- the fix is not decoration
    The second is the tooth for the first."""
    print('-' * 74)
    hb2 = build(False, tag + '_noet2', cflags, extra=['-DJUNO_TOOTH_NO_ET2_LFO'])
    out2 = os.path.join(BUILD, 'host_noet2_%s.bin' % tag)
    rc, _ = run(hb2, out2, os.path.join(BUILD, 'boot_noet2_%s.bin' % tag))
    if rc:
        print('D1-FIX: could not build the no-fix control'); return 1
    A = open(hostbin, 'rb').read()
    B = open(out2, 'rb').read()
    per_seq = 3 * 64
    cold = warm = 0
    for trial in (0, 1):
        base = trial * 3 * per_seq
        for i in range(per_seq):
            c = base + i
            if A[c * rec:(c + 1) * rec] != B[c * rec:(c + 1) * rec]:
                cold += 1
            for seq in (1, 2):
                c = base + seq * per_seq + i
                if A[c * rec:(c + 1) * rec] != B[c * rec:(c + 1) * rec]:
                    warm += 1
    print('D1-FIX  src/chorus_recall.c EFFECT TYPE 2 now writes cell 91152:')
    print('        COLD cases changed by the fix: %d of %d   (must be 0 -- the'
          ' seal)' % (cold, 2 * per_seq))
    print('        WARM cases changed by the fix: %d of %d   (must be > 0 -- the'
          ' tooth)' % (warm, 4 * per_seq))
    ok = (cold == 0 and warm > 0)
    print('        %s' % ('ok' if ok else '*** FAILED ***'))
    return 0 if ok else 1


def patch_check(rescan):
    """EB_PATCH_BYTES and the record-position net (engine_b/eb_patch.c).

    Cheap half, always: compile and run eb_patch_selftest() +
    eb_patch_record_coverage(), which assert that every record position in
    EB_RECALL_POS[] is carried by the 133-byte format.

    Expensive half, --patch-scan: RE-MEASURE that list from the port itself and
    fail if it has moved. Without this the list is a checked-in claim; with it,
    it is a measurement."""
    print('\n' + '=' * 74)
    print('THE COMPACT PATCH FORMAT')
    print('=' * 74)
    src = os.path.join(BUILD, 'patchchk.c')
    open(src, 'w').write(
        '#include <stdio.h>\n#include "eb_patch.h"\n'
        'int main(void){int m[128],n,i;'
        'printf("EB_PATCH_BYTES = %d\\n", EB_PATCH_BYTES);'
        'n=eb_patch_record_coverage(m,128);'
        'printf("recall-affecting record positions NOT carried: %d\\n", n);'
        'for(i=0;i<n&&i<20;i++) printf("   MISSING record %d\\n", m[i]);'
        'printf("eb_patch_selftest = %d\\n", eb_patch_selftest());'
        'n=eb_patch_coverage(m,128);'
        'printf("parameters located but not carried: %d\\n", n);'
        'return eb_patch_selftest()!=0;}\n')
    exe = os.path.join(BUILD, 'patchchk')
    r = sh([CC, '-std=c99', '-O2', '-w', '-I' + os.path.join(REPO, 'engine_b'),
            '-o', exe, src, os.path.join(REPO, 'engine_b', 'eb_patch.c')])
    if r.returncode:
        print(r.stderr[-2000:]); return 1
    r = sh([exe])
    print(r.stdout.strip())
    bad = r.returncode

    # -------------------------------------------------------------- the tooth
    # THE 2026-08-11 GATE'S THIRD TOOTH, in its post-fix form. Then it was
    # "set the five uncarried record bytes to non-factory values" and the
    # answer was 8,807 differing bytes -- a MEASUREMENT that the format was
    # short. The format now carries them, so the same defect has to be planted
    # the other way round: take one of the late bytes back OUT and require the
    # net to say so. Without this, "NOT carried: 0" is a claim that has never
    # been seen to be anything else.
    ebdir = os.path.join(REPO, 'engine_b')
    tdir = os.path.join(BUILD, 'patch_tooth')
    os.makedirs(tdir, exist_ok=True)
    pc = open(os.path.join(ebdir, 'eb_patch.c')).read()
    ph = open(os.path.join(ebdir, 'eb_patch.h')).read()
    m = re.search(r'const uint16_t eb_patch_offsets\[EB_PATCH_BYTES\] = \{(.*?)\};',
                  pc, re.S)
    nb = re.search(r'#define EB_PATCH_BYTES\s+(\d+)', ph)
    if not m or not nb:
        print('old-3 patch-format tooth: SKIPPED (eb_patch source shape changed)')
        bad = 1
    else:
        for drop, what in ((3270, 'CHORUS PRE DELAY, record 3286'),
                           (490, 'BEND GAIN, record 506')):
            label = 'old-3  drop blob byte %d (%s)' % (drop, what)
            keep = [int(x) for x in re.findall(r'\d+', m.group(1))]
            if drop not in keep:
                print('%-74s SKIPPED (not in the format)' % label)
                bad = 1
                continue
            keep.remove(drop)
            body = ',\n  '.join(', '.join('%d' % v for v in keep[i:i + 12])
                                for i in range(0, len(keep), 12))
            open(os.path.join(tdir, 'eb_patch.c'), 'w').write(
                pc[:m.start()]
                + 'const uint16_t eb_patch_offsets[EB_PATCH_BYTES] = {\n  '
                + body + '\n};' + pc[m.end():])
            open(os.path.join(tdir, 'eb_patch.h'), 'w').write(
                ph[:nb.start()] + '#define EB_PATCH_BYTES   %d' % len(keep)
                + ph[nb.end():])
            texe = os.path.join(BUILD, 'patchchk_tooth')
            rr = sh([CC, '-std=c99', '-O2', '-w', '-I' + tdir, '-I' + ebdir,
                     '-o', texe, src, os.path.join(tdir, 'eb_patch.c')])
            if rr.returncode:
                print('%-74s SKIPPED (build failed)' % label)
                print(rr.stderr[-800:])
                bad = 1
                continue
            rr = sh([texe])
            g = re.search(r'NOT carried: (\d+)', rr.stdout)
            nmiss = int(g.group(1)) if g else 0
            caught = bool(nmiss) and bool(rr.returncode)
            print('%-74s %s (%d position%s reported missing)'
                  % (label, 'CAUGHT' if caught else 'NOT CAUGHT',
                     nmiss, '' if nmiss == 1 else 's'))
            if not caught:
                bad = 1

    if rescan:
        hb = build(False, 'scan', [])
        pos = os.path.join(BUILD, 'recall_positions.txt')
        rc, out = run(hb, pos, os.path.join(BUILD, 'boot_scan.bin'), case='scan')
        print(out.strip())
        measured = sorted(int(x) for x in open(pos))
        tab = open(os.path.join(REPO, 'engine_b/eb_patch.c')).read()
        m = re.search(r'static const short EB_RECALL_POS\[\] = \{(.*?)\};', tab, re.S)
        listed = sorted(int(x) for x in re.findall(r'\d+', m.group(1)))
        if measured != listed:
            print('*** EB_RECALL_POS[] IS STALE: measured %d, listed %d ***'
                  % (len(measured), len(listed)))
            print('    only measured: %s' % sorted(set(measured) - set(listed))[:20])
            print('    only listed:   %s' % sorted(set(listed) - set(measured))[:20])
            bad = 1
        else:
            print('EB_RECALL_POS[] matches the re-measured set (%d positions)'
                  % len(measured))
    else:
        print('(EB_RECALL_POS[] not re-measured this run -- pass --patch-scan)')
    return bad


# ============================================================== THE TEETH
#
# Two families.
#
#   MAP teeth      break the address map or the per-voice scatter and require
#                  the 1,152-case identity comparison to FAIL.
#   PUBLISH teeth  compile eb_recall.c with one step omitted and require the
#                  publish-contract assertions to FAIL.
#
# A tooth that does not fire is printed NOT CAUGHT and fails the gate. A tooth
# that cannot fire is worse than no tooth, because it reads as coverage: this
# project has already been bitten three times by a planted defect that its own
# harness could not reach.
#
# ⚠ A TOOTH THAT FIRES FOR THE WRONG REASON IS THE SAME DISEASE, and this one
# was caught here. The host half gathers its boot image THROUGH the generated
# EBDEV_SEGTAB, so a tooth that regenerates the map and rebuilds only the
# DEVICE half makes the two halves exchange a differently-packed boot image
# -- and then every 'gen' tooth "passes" on a layout mismatch while proving
# nothing about the map. Every 'gen' tooth below therefore rebuilds BOTH
# halves and regenerates the reference. It cost the honest answer on old-5b:
# with both halves rebuilt, deleting a COLD segment is NOT caught.
MAP_TEETH = [
    ('a1  route cell 320 (the ADSR gate) through the SHARED TILE -- defect 2',
     {'scat_drop': 320}),
    ('a2  route the note-path PITCH cell 304 through the shared tile',
     {'scat_drop': 304}),
    ('a3  route the recall-time CONDITION cell 5520 through the shared tile',
     {'scat_drop': 5520}),
    ('old-4  route voice 0\'s scatter through the tile (the 2026-08-11 tooth)',
     {'scat0_in_tile': 1}),
    ('old-1a move ONE HOT segment (84272) by 4 bytes in the port space',
     {'gen': ['--shift-seg', '84272:4']}),
    ('old-1b move every segment boundary (regenerate at gap 64)',
     {'gen': ['--gap', '64'], 'blind': 1, 'why':
      'EXPECTED, and it is a finding rather than a miss. --gap only decides\n'
      '       how much DEAD SPACE between touched cells is carried; the'
      ' segments\n       are built FROM the cell list, so every touched cell'
      ' stays covered at\n       any gap. The 2026-08-11 gate called this'
      ' tooth "move one hot segment"\n       and it was firing on the boot-image'
      ' packing. old-1a is the real form.'}),
    ('old-2  flip ONE ULP in ONE scatter cell (5520) on voice 3',
     {'define': 'GATE_TOOTH_ULP'}),
    ('old-5a delete a HOT segment (84272, the shared noise block)',
     {'gen': ['--drop-seg', '84272']}),
    ('old-5b delete a COLD segment (131072) -- EXPECTED BLIND, see below',
     {'gen': ['--drop-seg', '131072'], 'blind': 1}),
    ('new  skip the scat[0]->scat[v] broadcast at recall',
     {'define': 'GATE_TOOTH_NOBCAST'}),
]

PUBLISH_TEETH = [
    ('b  omit the dco_live_seeded clear -- the BISECTED INSTRUMENT',
     'EB_RECALL_TOOTH_NODCO'),
    ('   omit the gate_cell320 refresh', 'EB_RECALL_TOOTH_NOGATE'),
    ('   omit the aux one-shot consume', 'EB_RECALL_TOOTH_NOAUX'),
    ('   omit the reverb wipe + pending taps', 'EB_RECALL_TOOTH_NOREV'),
    ('   omit the delay route latch', 'EB_RECALL_TOOTH_NOROUTE'),
    ('   omit the pointer swap', 'EB_RECALL_TOOTH_NOSWAP'),
]


def teeth():
    print('\n' + '=' * 74)
    print('TEETH')
    print('=' * 74)
    bad = 0
    tag = 'trunk'
    hb = build(False, tag, [])
    boot = os.path.join(BUILD, 'boot_%s.bin' % tag)
    ho = os.path.join(BUILD, 'host_%s.bin' % tag)
    rc, out = run(hb, ho, boot)
    rec = int(re.search(r'= (\d+) B/case', out).group(1))
    ncase = int(re.search(r'(\d+) cases', out).group(1))

    # Broken maps are generated into a SCRATCH directory. See make_tree().
    if os.path.exists(TOOTH_HDR):
        shutil.rmtree(TOOTH_HDR)
    os.makedirs(TOOTH_HDR)

    # (c) the SEQUENCE tooth: measured off the host half's own output. If a warm
    # case is not different from the cold reference, the whole sequence
    # extension is decoration and every warm PASS is vacuous.
    A = open(ho, 'rb').read()
    per_seq = 3 * 64
    d = sum(1 for i in range(per_seq)
            if A[i * rec:(i + 1) * rec]
            != A[(per_seq + i) * rec:(per_seq + i + 1) * rec])
    print('%-74s %s (%d of %d)'
          % ('c  compare a WARM sequence against a COLD reference',
             'CAUGHT' if d else 'NOT CAUGHT', d, per_seq))
    if not d:
        bad = 1

    for name, how in MAP_TEETH:
        ref_h, ref_boot, hdr = ho, boot, None
        for f in os.listdir(TOOTH_HDR):
            os.remove(os.path.join(TOOTH_HDR, f))
        try:
            if 'gen' in how:
                r = sh([sys.executable, os.path.join(HERE, 'gen_devcells.py'),
                        '--out', TOOTH_HDR] + how['gen'])
                if r.returncode:
                    print('%-74s SKIPPED (generator failed)' % name); continue
                hdr = TOOTH_HDR
            if 'scat_drop' in how:
                src = open(os.path.join(HERE, 'gen_devcells.py')).read()
                m = re.search(r'SCATTER = \[(.*?)\]', src, re.S)
                keep = [x.strip() for x in m.group(1).split(',') if x.strip()]
                keep = [x for x in keep if int(x) != how['scat_drop']]
                src = (src[:m.start()] + 'SCATTER = [' + ', '.join(keep) + ']'
                       + src[m.end():])
                tmp = os.path.join(BUILD, 'gen_tooth.py')
                open(tmp, 'w').write(src)
                r = sh([sys.executable, tmp, '--out', TOOTH_HDR])
                if r.returncode:
                    print('%-74s SKIPPED (generator failed)' % name); continue
                hdr = TOOTH_HDR
            if hdr:
                # REBUILD THE HOST HALF TOO. It gathers the boot image THROUGH
                # EBDEV_SEGTAB / EBDEV_SCATTAB, so a tooth that regenerates the
                # headers and rebuilds only the DEVICE half makes the two
                # halves exchange a differently-packed boot image, and then it
                # "fires" on that and proves nothing about the map. MEASURED:
                # with the host half left stale, deleting a segment the gate
                # itself reports COLD came back CAUGHT. See the note above
                # MAP_TEETH.
                th = build(False, 'tooth_h', [], hdr=hdr)
                ref_h = os.path.join(BUILD, 'host_tooth.bin')
                ref_boot = os.path.join(BUILD, 'boot_tooth.bin')
                rc, _ = run(th, ref_h, ref_boot)
                if rc:
                    print('%-74s SKIPPED (host half refused)' % name); continue
            extra = []
            if 'define' in how:
                extra = ['-D' + how['define']]
            if 'scat0_in_tile' in how:
                extra = ['-DEBDEV_TOOTH_SCAT0_IN_TILE']
            db = build(True, 'tooth', [], extra=extra + ['-DEBDEV_INSTRUMENT'],
                       hdr=hdr)
            do = os.path.join(BUILD, 'tooth.bin')
            rc, out = run(db, do, ref_boot)
            diff, err = compare(ref_h, do, rec, ncase)
            if err:
                print('%-74s CAUGHT (%s)' % (name, err)); continue
            n = len(diff)
            caught = bool(n) or bool(rc)
            print('%-74s %s (%d of %d cases%s)'
                  % (name, 'CAUGHT' if caught else 'NOT CAUGHT', n, ncase,
                     ', dev half refused' if rc else ''))
            if how.get('blind'):
                # THE HONEST TOOTH. Printed, never dropped: a tooth that cannot
                # fire reads as coverage, which is how three planted defects in
                # this project were reported green. If one of these ever DOES
                # fire, the reason recorded here was wrong and the gate says so.
                if caught:
                    print('       ^ THIS WAS EXPECTED NOT TO FIRE AND IT DID.'
                          ' The recorded reason is wrong.')
                    bad = 1
                else:
                    print('       ^ ' + how.get('why',
                          'EXPECTED. This measures the gate\'s blind spot, not'
                          ' the map: 18 of 32 segments are\n       never'
                          ' reached by any scenario, they cost 4,272 B, and'
                          ' deleting one\n       therefore cannot be'
                          ' detected. The 2026-08-11 gate said so too.'))
            elif not caught:
                bad = 1
        finally:
            for f in os.listdir(TOOTH_HDR):
                os.remove(os.path.join(TOOTH_HDR, f))

    # ------------------------------------------------------- publish teeth
    ds = build(True, 'trunk_ship', [])
    rc, out = run(ds, os.path.join(BUILD, 'pub.bin'), boot, case='publish')
    nchk = re.search(r'PUBLISH CONTRACT: (\d+) of (\d+)', out)
    print('%-74s %s' % ('publish contract, no tooth (control)',
                        'ok %s/%s' % (nchk.group(1), nchk.group(2)) if nchk else 'NO OUTPUT'))
    if rc:
        bad = 1
    for name, define in PUBLISH_TEETH:
        db = build(True, 'ptooth', [], extra=['-D' + define])
        rc, out = run(db, os.path.join(BUILD, 'pub.bin'), boot, case='publish')
        m = re.search(r'PUBLISH CONTRACT: (\d+) of (\d+)', out)
        nfail = (int(m.group(2)) - int(m.group(1))) if m else -1
        print('%-74s %s (%d checks failed)'
              % (name, 'CAUGHT' if rc else 'NOT CAUGHT', nfail))
        if not rc:
            bad = 1
    return bad


if __name__ == '__main__':
    sys.exit(main())
