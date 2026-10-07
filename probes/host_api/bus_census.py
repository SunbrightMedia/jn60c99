"""Oracle-only census (task #36): what IComponent::activateBus changes in the wrapper core, and what
the plugin's process() writes into an output bus of 1 (mono) and 6 (5.1) channels after
setBusArrangements, against the stereo bus every gate uses.

    python3 probes/host_api/bus_census.py      (Unicorn only)"""
import os
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H          # noqa: E402


def main():
    h = H.HostProcess()
    h.start(48000.0, 4096)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]

    def call5(obj, slot, a1, a2, a3, a4):
        rsp = h._top() - 8
        uc.mem_write(rsp + 0x28, struct.pack('<Q', a4 & (2 ** 64 - 1)))
        return h.call(q(q(obj) + 8 * slot), rcx=obj, rdx=a1, r8=a2, r9=a3, count=2_000_000_000)

    base = bytes(uc.mem_read(h.core - 0x148, 0x2000))
    for mt, d, nm in ((0, 1, 'audio out'), (1, 0, 'event in')):
        call5(h.comp, 10, mt, d, 0, 1)
        now = bytes(uc.mem_read(h.core - 0x148, 0x2000))
        diff = [i for i in range(0, 0x2000, 4) if now[i:i + 4] != base[i:i + 4]]
        print('activateBus(%s, 1): changed dwords at wrapper base +%s' % (nm, [hex(x) for x in diff[:12]]))
        for x in diff[:6]:
            print('   +0x%x: %08x -> %08x' % (x, struct.unpack_from('<I', base, x)[0], struct.unpack_from('<I', now, x)[0]))
        base = now
    print('process() bus fields used by the oracle:', [n for n in dir(h) if 'bus' in n.lower()][:10])


if __name__ == '__main__':
    main()
