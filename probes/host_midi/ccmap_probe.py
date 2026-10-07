"""Oracle-only probe (CLAIMS B16): the booted plugin's CC-assign map and MIDI param base.

READ (rva 0x31F4E0): a CC message first looks up the map at core+24 (rva 0x319A60: -1 while
core+24+64 >= 0, the learn slot; else a std::map<int,int> CC -> assignment at core+24+48).
This probe boots the plugin as a host does (host_process_emu) and prints, for the product
start: the learn slot, the map's node count, every (CC, assignment) pair, the assignment
vector's size, and the process() MIDI param base (component +104 = base + 104).
    python3 probes/host_midi/ccmap_probe.py        (Unicorn only)"""
import os
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H            # noqa: E402

h = H.HostProcess()
h.start(48000.0, 512)
uc = h.uc
q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
i32 = lambda a: struct.unpack('<i', uc.mem_read(a, 4))[0]
m = h.core + 24
print('component base 0x%x core 0x%x' % (h.base, h.core))
print('learn slot (core+24+64):', i32(m + 64))
head = q(m + 48)
print('map head 0x%x size(core+24+56) %d' % (head, q(m + 56)))


def walk(n, out):
    if uc.mem_read(n + 25, 1)[0]:
        return
    walk(q(n), out)
    out.append((i32(n + 28), i32(n + 32)))
    walk(q(n + 16), out)


pairs = []
walk(q(head + 8), pairs)
print('pairs (CC, assignment):', pairs)
vb, ve = q(m), q(m + 8)
print('assignment vector: %d entries' % ((ve - vb) // 24))
for k in range((ve - vb) // 24):
    print('  [%d] obj 0x%x +8 0x%x flag %d' % (k, q(vb + 24 * k), q(vb + 24 * k + 8), uc.mem_read(vb + 24 * k + 16, 1)[0]))
for off in (96, 100, 104, 108):
    print('component +%d = %d (0x%x)' % (off, i32(h.base + off), i32(h.base + off) & 0xFFFFFFFF))
print('MIDI param base (core+48): %d (0x%x)' % (i32(h.core + 48), i32(h.core + 48) & 0xFFFFFFFF))
print('core+24..+96 qwords:', ['0x%x' % q(h.core + 24 + 8 * k) for k in range(9)])
