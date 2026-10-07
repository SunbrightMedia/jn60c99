"""Oracle-only probe (CLAIMS B14): what the arp controller's TYPE / STEP / SW setters (rva
0x3C4E50 / 0x3C49B0 / 0x3C49F0, the host entry's dedicated setters for 831..835) change in unit
0's CKbdArp (engine+112) and keyboard object (engine+120), in the controller (engine+136) and its
apply object (controller+40, rva 0x3C0E90 / 0x3C0EC0), and in every unit's engine state, while
the arp runs with a key held. Byte diff of each region around each call. --boot prints the
controller and apply fields after boot and after two patch loads.

    python3 probes/host_render/arp_cfg_probe.py [--boot]      (Unicorn only)"""
import os
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H      # noqa: E402
import e2e_emu as E               # noqa: E402

h = H.HostProcess()
h.start(48000.0, 4096, setting=2)
q = lambda a: struct.unpack('<Q', h.uc.mem_read(a, 8))[0]
i32 = lambda a: struct.unpack('<i', h.uc.mem_read(a, 4))[0]
arp, kb, ctrl = q(h.HOST + 112), q(h.HOST + 120), q(h.HOST + 136)
apply_ = q(ctrl + 40)


def fields(tag):
    print('%-22s ctrl on %d type %d step %d +12 %d depth %d stype %d | apply +24 %d +28 %d +32 %d +36 %d | '
          'arp +4076 %d +40 %d +3476 %d +3472 %d | kb +4 %d +5 %d +6 %d +9 %d +10 %d' % (
              tag, h.uc.mem_read(ctrl, 1)[0], i32(ctrl + 4), i32(ctrl + 8), h.uc.mem_read(ctrl + 12, 1)[0],
              i32(ctrl + 16), i32(ctrl + 20), i32(apply_ + 24), i32(apply_ + 28), i32(apply_ + 32),
              i32(apply_ + 36), i32(arp + 4076), h.uc.mem_read(arp + 40, 1)[0], i32(arp + 3476), i32(arp + 3472),
              *[h.uc.mem_read(kb + k, 1)[0] for k in (4, 5, 6, 9, 10)]))


bank = E.bank_bytes()
if '--boot' in sys.argv:
    fields('after start')
    h.process(512)
    fields('after block 0')
    for p in (1, 33, 0, 41):
        rec = bank[E.HEADER + p * E.STRIDE: E.HEADER + (p + 1) * E.STRIDE]
        h.load_patch(rec[16:])
        h.process(512)
        fields('patch %d loaded' % p)
    sys.exit(0)
h.process(512)
h.snap_all()
rec = bank[E.HEADER + 1 * E.STRIDE: E.HEADER + 2 * E.STRIDE]
h.load_patch(rec[16:])
h.process(512, events=[('on', 0, 0, 60, 0.8), ('on', 5, 0, 64, 0.8), ('on', 9, 0, 67, 0.8)], ctx=dict(tempo=120.0, playing=True))
for _ in range(9):
    h.process(512, ctx=dict(tempo=120.0, playing=True))


def snap():
    return [bytes(h.uc.mem_read(arp, 4100)), bytes(h.uc.mem_read(kb, 2000)), bytes(h.uc.mem_read(ctrl, 64)),
            bytes(h.uc.mem_read(apply_, 40))] + [bytes(h.uc.mem_read(h.state[u], E.STATE_SZ)) for u in range(9)]


def diff(tag, a, b):
    for nm, x, y in zip(['arp', 'kb', 'ctrl', 'apply'] + ['unit%d' % u for u in range(9)], a, b):
        d = [k for k in range(0, len(x), 4) if x[k:k + 4] != y[k:k + 4]]
        if d or not nm.startswith('unit'):
            print('%-14s %-5s %d dwords changed: %s' % (tag, nm, len(d), ' '.join(
                '+%d:%s->%s' % (k, x[k:k + 4].hex(), y[k:k + 4].hex()) for k in d[:24])))


fields('running')
for tag, fn, val in (('TYPE 0->2', 0x3C4E50, 2), ('STEP 1->2', 0x3C49B0, 2), ('TYPE 2->1', 0x3C4E50, 1),
                     ('TYPE 1->1', 0x3C4E50, 1), ('SW 1->0', 0x3C49F0, 0), ('TYPE 1->0 off', 0x3C4E50, 0),
                     ('SW 0->1', 0x3C49F0, 1)):
    a = snap()
    h.call(E.IB + fn, rcx=ctrl, rdx=val, r8=0, count=50_000_000)
    b = snap()
    diff(tag, a, b)
    fields(tag)
