#!/usr/bin/env python3
"""shadow_bounds_gate.py -- prove the PORT-OWNED SHADOW CELLS can never
false-fail a port-vs-plugin comparison.

WHY IT EXISTS (2026-08-15). src/juno_engine.h now declares two cells the
PLUGIN DOES NOT HAVE:

    JUNO_PREV_EFX  11022400   previous EFFECT TYPE leaf (rec 634)
    JUNO_PREV_DLY  11022416   previous DELAY  TYPE leaf (rec 650)

They exist because several recall arms are gated on the type IN FORCE BEFORE
the recall (src/chorus_recall.c), and the plugin's own routing cells cannot
answer that: they are clamped and are not written at all at type >= 6.

THE RISK, AND IT IS THE ONLY ONE. The port's state array is the port's own
memory; the plugin never sees it, so the shadow cannot change what the plugin
does. A shadow can hurt in EXACTLY one way: if a gate reads port[off] and
plugin[off] at an offset the port now writes and the plugin never does, the
gate goes red on a cell that is not a defect. That is a gate-integrity claim,
not a DSP claim, so it is checked HERE, statically, over the gates themselves.

The plugin's engine object is operator new(0xA83010) = 11,022,352 bytes
(tools/verify/e2e_emu.py selects allocations of that exact size). The shadow
window starts 48 bytes past its end. This gate asserts:

  1. recall_fullstate_diff.offsets() -- the compared set every whole-state A/B
     and warm_recall_gate.py uses -- contains NO offset in the shadow window.
  2. The three declared comparison bounds in tools/verify/ are all <= the
     plugin object size: coldstate_ab.MEANINGFUL, port_writeset.SZ,
     recall_fullstate_diff.STATE_SZ.
  3. No .py under tools/verify/ or tools/engineb/ mentions an integer literal
     inside the shadow window (i.e. nobody has started comparing one).
  4. The device cell map covers both shadow cells, so an -DEB_DECELLS build
     cannot alias them onto the shared 8-byte miss SINK.
  5. The baked device boot image was generated FROM that same cell map. Adding
     the shadow cells grew EBDEV_SEGBYTES and the image had to grow with it;
     nothing enforced that they move together, and eb_devseq_boot_cells slices
     the image by SEGBYTES without checking, so a stale image boots the board on
     a mis-sliced state.

Constants 2 and 3 are read TEXTUALLY, not by import: importing port_writeset
would ctypes-load libjuno.so, and this file must stay safe to run beside an
oracle process (CLAUDE.md two-process rule).

SEEN TO FAIL -- run it with the tooth:
    JUNO_SHADOW_TOOTH=region python3 tools/verify/shadow_bounds_gate.py
        injects a bogus REGION (11022390, 11022410) -> check 1 must go RED
    JUNO_SHADOW_TOOTH=bound  python3 tools/verify/shadow_bounds_gate.py
        raises the declared object size past the shadow -> check 2 must go RED
    JUNO_SHADOW_TOOTH=drift  python3 tools/verify/shadow_bounds_gate.py
        moves EBDEV_SEGBYTES without a regenerated image -> check 5 must go RED

EXIT 0 = GREEN, 1 = RED.
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import recall_fullstate_diff as FS               # noqa: E402  pure, no engine

ROOT = FS.ROOT
OBJ_SZ = 0xA83010                                # 11022352, operator new size
SHADOW = {'JUNO_PREV_EFX': 11022400, 'JUNO_PREV_DLY': 11022416}
WIN_LO = min(SHADOW.values())
WIN_HI = max(SHADOW.values()) + 16                # 11022432, one cell grid past
TOOTH = os.environ.get('JUNO_SHADOW_TOOTH', '')


def hdr(n, s):
    print('\n--- check %d: %s' % (n, s))


def check_defines():
    """The offsets this gate protects come from src/juno_engine.h, not from a
    number typed here. A moved #define must move the gate with it."""
    hdr(0, 'the two #defines still say what this gate assumes')
    txt = open(os.path.join(ROOT, 'src', 'juno_engine.h')).read()
    ok = True
    for name, want in sorted(SHADOW.items()):
        m = re.search(r'#define\s+%s\s+(\d+)u?' % name, txt)
        got = int(m.group(1)) if m else None
        print('    %-14s src says %-12s gate assumes %d' % (name, got, want))
        if got != want:
            ok = False
    if not ok:
        print('    RED: src/juno_engine.h and this gate disagree.')
    return ok


def check_regions():
    hdr(1, 'the compared set excludes the shadow window')
    regions = list(FS.REGIONS)
    if TOOTH == 'region':
        regions.append((11022390, 11022410))
        print('    TOOTH: injected bogus REGION (11022390, 11022410)')
    offs = set()
    for a, b in regions:
        offs.update(range(a & ~3, b, 4))
    bad = sorted(o for o in offs if WIN_LO <= o < WIN_HI)
    print('    %d compared cells, highest %d' % (len(offs), max(offs)))
    print('    shadow window [%d, %d): %d compared cells inside'
          % (WIN_LO, WIN_HI, len(bad)))
    if bad:
        print('    RED: %s' % bad[:8])
    return not bad


BOUNDS = [
    ('coldstate_ab.py', r'^MEANINGFUL\s*=\s*(\d+)'),
    ('port_writeset.py', r'^SZ\s*=\s*(0x[0-9a-fA-F]+|\d+)'),
    ('recall_fullstate_diff.py', r'^STATE_SZ\s*=\s*(0x[0-9a-fA-F]+|\d+)'),
]


def check_bounds():
    hdr(2, 'every declared comparison bound stops at or below the object end')
    ok = True
    for fn, pat in BOUNDS:
        txt = open(os.path.join(ROOT, 'tools', 'verify', fn)).read()
        m = re.search(pat, txt, re.M)
        if not m:
            print('    %-28s BOUND NOT FOUND -- pattern %s' % (fn, pat))
            ok = False
            continue
        v = int(m.group(1), 0)
        if TOOTH == 'bound' and fn == 'coldstate_ab.py':
            v = WIN_HI
            print('    TOOTH: pretending %s declares %d' % (fn, v))
        print('    %-28s %-12d %s %d' % (fn, v, '<=' if v <= OBJ_SZ else '> ',
                                         OBJ_SZ))
        if v > OBJ_SZ:
            ok = False
    if not ok:
        print('    RED: a gate compares past the plugin object.')
    return ok


def check_literals():
    hdr(3, 'no gate mentions an offset inside the shadow window')
    me = os.path.basename(__file__)
    hits = []
    for sub in ('tools/verify', 'tools/engineb'):
        d = os.path.join(ROOT, sub)
        for name in sorted(os.listdir(d)):
            if not name.endswith('.py') or name == me:
                continue
            p = os.path.join(d, name)
            for ln, line in enumerate(open(p, errors='replace'), 1):
                for lit in re.findall(r'\b\d{8,9}\b', line):
                    if WIN_LO <= int(lit) < WIN_HI:
                        hits.append((sub + '/' + name, ln, lit))
    print('    scanned tools/verify + tools/engineb; %d hit(s)' % len(hits))
    for h in hits:
        print('    RED: %s:%d mentions %s' % h)
    return not hits


def check_devmap():
    hdr(4, 'the device cell map covers both shadow cells')
    txt = open(os.path.join(ROOT, 'engine_b', 'dev', 'ebdev_seg.h')).read()
    segs = [(int(a), int(b)) for a, b in
            re.findall(r'\{\s*(\d+)u,\s*(\d+)u,\s*\d+u\s*\}', txt)]
    ok = True
    for name, off in sorted(SHADOW.items()):
        inside = any(lo <= off < hi for lo, hi in segs)
        print('    %-14s %d  %s' % (name, off,
                                    'mapped' if inside else 'NOT MAPPED'))
        if not inside:
            ok = False
    if not ok:
        print('    RED: an -DEB_DEVCELLS build would alias these onto the '
              'shared miss SINK. Add them to '
              'docs/engineb/data/devrecall/static_extra.txt and re-run '
              'tools/engineb/gen_devcells.py + tools/engineb/devboot/'
              'make_boot.py.')
    return ok


def _def(relpath, name):
    txt = open(os.path.join(ROOT, relpath)).read()
    m = re.search(r'^\s*#define\s+%s\s+(0x[0-9a-fA-F]+|\d+)u?\b' % name, txt, re.M)
    return int(m.group(1), 0) if m else None


def check_bootimage():
    """CHECK 5 -- the baked boot image and the cell map must move TOGETHER.

    Adding the two shadow cells to the device map grew EBDEV_SEGBYTES, and the
    baked image esp32s3/main/gen/ebdev_boot.h had to grow by the same amount.
    NOTHING ENFORCED THAT. engine_b/dev/eb_devseq.c eb_devseq_boot_cells
    validates only nv, then memcpys EBDEV_VTILE, then EBDEV_SEGBYTES, then the
    scatter rows straight out of the image -- so an image regenerated at a
    different SEGBYTES is copied at the WRONG STRIDE and the board boots with a
    silently mis-sliced state. That is the loudest possible defect (wrong audio)
    reached by the quietest possible route (a stale generated header).

    The law is tools/engineb/devboot/bootgen.c:91 verbatim:
        BOOT_BYTES == VTILE + SEGBYTES + BOOT_NV * NSCAT * 4
    read from the two generated headers, never typed here, so a regenerated map
    with a forgotten image regeneration is RED before it can be flashed.

    It lives in THIS file rather than a new one because it is the same claim as
    check 4 -- "the device really carries these cells" -- one step further along:
    check 4 says the map covers them, check 5 says the image the map slices was
    built from that same map.
    """
    hdr(5, 'the baked boot image matches the cell map it was gathered through')
    seg = 'engine_b/dev/ebdev_seg.h'
    boot = 'esp32s3/main/gen/ebdev_boot.h'
    vtile = _def(seg, 'EBDEV_VTILE')
    segb = _def(seg, 'EBDEV_SEGBYTES')
    nscat = _def(seg, 'EBDEV_NSCAT')
    nv = _def(boot, 'EBDEV_BOOT_NV')
    got = _def(boot, 'EBDEV_BOOT_BYTES')
    if None in (vtile, segb, nscat, nv, got):
        print('    RED: could not read %s / %s' % (seg, boot))
        return False
    if TOOTH == 'drift':
        segb += 68
        print('    TOOTH: pretending EBDEV_SEGBYTES moved to %d without a '
              'regenerated image' % segb)
    want = vtile + segb + nv * nscat * 4
    print('    tile %u + segments %u + scatter %dx%d floats %u = %d'
          % (vtile, segb, nv, nscat, nv * nscat * 4, want))
    print('    %-28s declares %d' % ('EBDEV_BOOT_BYTES', got))
    ok = (want == got)
    # the array's own declared length, so a #define edited without the payload
    # (or the reverse) is caught too
    txt = open(os.path.join(ROOT, boot)).read()
    m = re.search(r'ebdev_boot\[\s*\d+\s*\]\[\s*(\d+)\s*\]', txt)
    arr = int(m.group(1)) if m else None
    print('    %-28s declares %s' % ('static ebdev_boot[][]', arr))
    if arr != got:
        ok = False
    if not ok:
        print('    RED: the boot image was NOT regenerated from this cell map. '
              'Re-run tools/engineb/gen_devcells.py then '
              'tools/engineb/devboot/make_boot.py; flashing this pair would '
              'slice the state at the wrong stride '
              '(engine_b/dev/eb_devseq.c eb_devseq_boot_cells).')
    return ok


def main():
    print('=== SHADOW BOUNDS GATE ===')
    print('plugin object end %d (0x%X); shadow window [%d, %d)'
          % (OBJ_SZ, OBJ_SZ, WIN_LO, WIN_HI))
    if TOOTH:
        print('TOOTH ACTIVE: %s' % TOOTH)
    ok = all([check_defines(), check_regions(), check_bounds(),
              check_literals(), check_devmap(), check_bootimage()])
    print('\nVERDICT: %s' % ('GREEN' if ok else 'RED'))
    return 0 if ok else 1


if __name__ == '__main__':
    raise SystemExit(main())
