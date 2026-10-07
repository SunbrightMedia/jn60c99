"""Oracle-only census (task #36): does IComponent::activateBus change what process() renders, and
what does process() write into a 1-channel (mono) and a 6-channel (5.1) output bus after
setBusArrangements? Same notes on fresh boots; compares the output bits.

    python3 probes/host_api/bus_audio_census.py      (Unicorn only)"""
import os
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H          # noqa: E402

N = 512


def run(active=False, nch=2, arr=None):
    h = H.HostProcess()
    h.start(48000.0, 4096)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]

    def call5(obj, slot, a1, a2, a3, a4):
        rsp = h._top() - 8
        uc.mem_write(rsp + 0x28, struct.pack('<Q', a4 & (2 ** 64 - 1)))
        return h.call(q(q(obj) + 8 * slot), rcx=obj, rdx=a1, r8=a2, r9=a3, count=2_000_000_000)
    if active:
        call5(h.comp, 10, 0, 1, 0, 1)
        call5(h.comp, 10, 1, 0, 0, 1)
    if arr is not None:
        outs = h.alloc_com(8)
        uc.mem_write(outs, struct.pack('<Q', arr))
        call5(h.audio, 3, 0, 0, outs, 1)
    bufs = [h.alloc_com(4 * 4096) for _ in range(nch)]
    for b in bufs:
        uc.mem_write(b, struct.pack('<f', 7.0) * 4096)          # a sentinel: what is not written stays 7.0
    chans = h.alloc_com(8 * nch)
    uc.mem_write(chans, b''.join(struct.pack('<Q', b) for b in bufs))
    uc.mem_write(h._bus, struct.pack('<iiQQ', nch, 0, 0, chans))
    out = []
    ev = [('on', 0, 0, 60, 0.8), ('on', 0, 0, 64, 0.7)]
    for k in range(4):
        h.process(N, events=ev if k == 0 else (), ctx=dict(tempo=120.0, playing=True))
        out.append([bytes(uc.mem_read(b, 4 * N)) for b in bufs])
    return out


def main():
    ref = run()
    act = run(active=True)
    print('activateBus(1) on both buses: output', 'IDENTICAL' if act == ref else 'DIFFERENT')
    mono = run(nch=1, arr=1 << 19)
    print('mono bus (1 channel): channel 0 == stereo L: %s; == stereo R: %s' % (
        [m[0] for m in mono] == [r[0] for r in ref], [m[0] for m in mono] == [r[1] for r in ref]))
    import numpy as np
    L = np.frombuffer(b''.join(r[0] for r in ref), dtype='<f4')
    R = np.frombuffer(b''.join(r[1] for r in ref), dtype='<f4')
    M = np.frombuffer(b''.join(m[0] for m in mono), dtype='<f4')
    nz = np.nonzero(L)[0]
    i = int(nz[0]) if len(nz) else 0
    print('mono samples %d..: M %r | L %r | R %r' % (i, M[i:i + 3].tolist(), L[i:i + 3].tolist(), R[i:i + 3].tolist()))
    for name, cand in (('(L+R)*0.5', (L + R) * np.float32(0.5)), ('L+R', L + R), ('(L+R)/2', (L + R) / np.float32(2)),
                       ('L*0.5+R*0.5', L * np.float32(0.5) + R * np.float32(0.5))):
        print('   mono == %-12s %s' % (name, bool(np.array_equal(M.view('<u4'), cand.astype('<f4').view('<u4')))))
    s51 = run(nch=6, arr=0x3F)
    print('5.1 bus (6 channels): ch0 == L %s, ch1 == R %s, ch2..5 untouched (7.0): %s' % (
        [s[0] for s in s51] == [r[0] for r in ref], [s[1] for s in s51] == [r[1] for r in ref],
        all(blk[c] == struct.pack('<f', 7.0) * N for blk in s51 for c in range(2, 6))))


if __name__ == '__main__':
    main()
