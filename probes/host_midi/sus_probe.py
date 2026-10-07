"""Oracle-only probe (CLAIMS B16b): the sustain (CC 64) and all-notes-off (CC 123) paths of the
plugin's own process(), dispatch by dispatch.

Boots the plugin as a host does (tools/verify/host_process_emu.py, product start, host 48000) and
runs a script of blocks (notes and MIDI-mapping parameter points). For every block it logs each
processor dispatch (rva 0x3B9A30: unit, leaf, flag, value) and, after the block, the keyboard
object of units 0 and 8 (route +4, flag8 +8, sustain +9/+10, the arp key lists +16/+532, the key
maps +1048/+1176), the assigner of units 0 and 8 (count +8, mask +12, held mask +80..+95, the
slot bytes +96..+119, +68) and the controller's sustain byte (+12).
    python3 probes/host_midi/sus_probe.py [script]      (Unicorn only)"""
import os
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H            # noqa: E402
from unicorn import UC_HOOK_CODE        # noqa: E402
from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9   # noqa: E402

BASE = 0x0FFFC100
DISPATCH = 0x3B9A30
h = H.HostProcess()
h.start(48000.0, 256)
uc = h.uc
q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
i32 = lambda a: struct.unpack('<i', uc.mem_read(a, 4))[0]
log = []
on = {'v': False}


def hook(uc_, addr, size, ud):
    if not on['v']:
        return
    p = uc_.reg_read(UC_X86_REG_RCX)
    if p in h.proc:
        log.append((h.proc.index(p), uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF,
                    uc_.reg_read(UC_X86_REG_R8) & 0xFF, uc_.reg_read(UC_X86_REG_R9) & 0xFFFFFFFF))


uc.hook_add(UC_HOOK_CODE, hook, begin=H.IB + DISPATCH, end=H.IB + DISPATCH)


def lst(a):
    n = i32(a)
    return [i32(a + 4 + 4 * k) for k in range(max(0, min(n, 128)))]


def kbmap(a):
    b = bytes(uc.mem_read(a, 128))
    return {k: v for k, v in enumerate(b) if v != 0xFF}


def dump(tag):
    for u in (0, 8):
        kb = h.noteobj[u]
        asg = q(kb + 1312)
        ctl = q(h.HOST + 136 + 64 * u)
        b = bytes(uc.mem_read(kb + 4, 9))
        slots = bytes(uc.mem_read(asg + 96, 24))
        print('   u%d kb route %d flag8 %d sus9 %d sus10 %d arp%s latch%s down%s held%s | ctl.sus %d | asg n %d mask 0x%x '
              'held %s +68 0x%x slots %s' % (
                  u, b[0], b[4], b[5], b[6], lst(kb + 16), lst(kb + 532), kbmap(kb + 1048), kbmap(kb + 1176),
                  uc.mem_read(ctl + 12, 1)[0], i32(asg + 8), i32(asg + 12),
                  ['%08x' % (i32(asg + 80 + 4 * k) & 0xFFFFFFFF) for k in range(4)], i32(asg + 68) & 0xFFFFFFFF,
                  ' '.join(slots[3 * k:3 * k + 3].hex() for k in range(8))))


def cc(n, v, off=0):
    return (BASE + n, off, v)


SCRIPTS = {
    'basic': [
        ('on 60 64', [('on', 0, 0, 60, 0.8), ('on', 0, 0, 64, 0.7)], []),
        ('sus on', [], [cc(64, 1.0)]),
        ('off 60 64', [('off', 0, 0, 60, 0.5), ('off', 0, 0, 64, 0.5)], []),
        ('on 67 (all keys up)', [('on', 0, 0, 67, 0.6)], []),
        ('on 60 (67 down)', [('on', 0, 0, 60, 0.6)], []),
        ('off 60', [('off', 0, 0, 60, 0.5)], []),
        ('on 60 again (latched)', [('on', 0, 0, 60, 0.9)], []),
        ('sus off', [], [cc(64, 0.0)]),
        ('cc123', [], [cc(123, 0.0)]),
        ('off 67 60', [('off', 0, 0, 67, 0.5), ('off', 0, 0, 60, 0.5)], []),
    ],
    'key127': [
        ('on 127 50', [('on', 0, 0, 127, 0.8), ('on', 0, 0, 50, 0.8)], []),
        ('sus on', [], [cc(64, 1.0)]),
        ('off 50', [('off', 0, 0, 50, 0.5)], []),
        ('sus off (127 down)', [], [cc(64, 0.0)]),
        ('off 127', [('off', 0, 0, 127, 0.5)], []),
        ('on 127', [('on', 0, 0, 127, 0.8)], []),
    ],
}
name = sys.argv[1] if len(sys.argv) > 1 else 'basic'
h.process(256)
h.snap_all()
dump('start')
for tag, evs, par in SCRIPTS[name]:
    del log[:]
    on['v'] = True
    h.process(256, events=evs, params=par)
    on['v'] = False
    print('== %s: %d dispatches' % (tag, len(log)))
    seen = {}
    for u, leaf, fl, v in log:
        seen.setdefault((leaf, fl, v), []).append(u)
    for (leaf, fl, v), us in sorted(seen.items()):
        if leaf in (312, 313, 314, 315, 316, 317, 318):
            continue
        print('   leaf %d flag %d value %d (0x%x) units %s' % (leaf, fl, v, v, us))
    dump(tag)
