"""Oracle-only census (task #36: every host call the plugin answers): the booted plugin's IComponent
and IAudioProcessor methods besides the ones the gates already drive (initialize, setState,
getState, setActive, setupProcessing, process). For each: the return value and, for the calls that
could change the engine, whether the wrapper core's and the nine engine units' first bytes change.

    python3 probes/host_api/vst3_surface_census.py      (Unicorn only)"""
import os
import struct
import sys
import zlib

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import host_process_emu as H          # noqa: E402
import e2e_emu as E                   # noqa: E402

# IComponent (IPluginBase 3..4): 5 getControllerClassId, 6 setIoMode, 7 getBusCount, 8 getBusInfo,
# 9 getRoutingInfo, 10 activateBus, 11 setActive, 12 setState, 13 getState
# IAudioProcessor: 3 setBusArrangements, 4 getBusArrangement, 5 canProcessSampleSize,
# 6 getLatencySamples, 7 setupProcessing, 8 setProcessing, 9 process, 10 getTailSamples
K_SPEAKER_M = 1 << 19


def main():
    h = H.HostProcess()
    h.start(48000.0, 4096)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    u32 = lambda r: r & 0xFFFFFFFF

    def fn(obj, slot):
        return q(q(obj) + 8 * slot)

    def call5(obj, slot, a1, a2, a3, a4):
        """Win64: the fifth argument at [rsp + 0x28] at entry (the helper puts the return address at
        [top - 8] and starts there)"""
        rsp = h._top() - 8
        uc.mem_write(rsp + 0x28, struct.pack('<Q', a4 & (2 ** 64 - 1)))
        return h.call(fn(obj, slot), rcx=obj, rdx=a1, r8=a2, r9=a3, count=2_000_000_000)

    def snap():
        parts = [bytes(uc.mem_read(h.core, 0x400))]
        for u in range(9):
            parts.append(bytes(uc.mem_read(h.state[u], 0x200)))
        return zlib.crc32(b''.join(parts))

    rows = []
    for ss in (0, 1):
        rows.append(('canProcessSampleSize(%s)' % ('kSample32', 'kSample64')[ss], '0x%x' % u32(h.vcall(h.audio, 5, ss))))
    rows.append(('getLatencySamples()', '%d' % u32(h.vcall(h.audio, 6))))
    rows.append(('getTailSamples()', '0x%x' % u32(h.vcall(h.audio, 10))))
    info = h.alloc_com(0x120)
    for mt, mn in ((0, 'kAudio'), (1, 'kEvent')):
        for d, dn in ((0, 'kInput'), (1, 'kOutput')):
            n = u32(h.vcall(h.comp, 7, mt, d))
            rows.append(('getBusCount(%s, %s)' % (mn, dn), '%d' % n))
            for i in range(n):
                uc.mem_write(info, b'\0' * 0x120)
                r = u32(call5(h.comp, 8, mt, d, i, info))
                mt_, d_, cc = struct.unpack('<iii', uc.mem_read(info, 12))
                name = bytes(uc.mem_read(info + 12, 256)).decode('utf-16-le').split('\0')[0]
                bt, fl = struct.unpack('<iI', uc.mem_read(info + 268, 8))
                rows.append(('  getBusInfo(%s, %s, %d)' % (mn, dn, i), '0x%x: channels %d, name %r, busType %d, flags 0x%x' % (r, cc, name, bt, fl)))
    arr = h.alloc_com(8)
    for d, dn in ((0, 'kInput'), (1, 'kOutput')):
        uc.mem_write(arr, b'\0' * 8)
        r = u32(h.vcall(h.audio, 4, d, 0, arr))
        rows.append(('getBusArrangement(%s, 0)' % dn, '0x%x, arrangement 0x%x' % (r, q(arr))))
    outs = h.alloc_com(8)
    for name, a in (('mono kSpeakerM', K_SPEAKER_M), ('stereo L|R', 3), ('5.1', 0x3F), ('stereo again', 3)):
        uc.mem_write(outs, struct.pack('<Q', a))
        r = u32(call5(h.audio, 3, 0, 0, outs, 1))
        uc.mem_write(arr, b'\0' * 8)
        h.vcall(h.audio, 4, 1, 0, arr)
        rows.append(('setBusArrangements(no in, out %s)' % name, '0x%x -> output arrangement now 0x%x' % (r, q(arr))))
    for mode in (0, 1, 2):
        rows.append(('setIoMode(%d)' % mode, '0x%x' % u32(h.vcall(h.comp, 6, mode))))
    for on in (0, 1):
        a = snap()
        r = u32(h.vcall(h.audio, 8, on))
        rows.append(('setProcessing(%d)' % on, '0x%x, core / units %s' % (r, 'unchanged' if snap() == a else 'CHANGED')))
    for mt, d, nm in ((0, 1, 'audio out'), (1, 0, 'event in')):
        for state in (0, 1):
            a = snap()
            r = u32(call5(h.comp, 10, mt, d, 0, state))
            rows.append(('activateBus(%s 0, %d)' % (nm, state), '0x%x, core / units %s' % (r, 'unchanged' if snap() == a else 'CHANGED')))
    ri = h.alloc_com(16)
    ro = h.alloc_com(16)
    rows.append(('getRoutingInfo()', '0x%x' % u32(h.vcall(h.comp, 9, ri, ro))))
    for n, v in rows:
        print('%-44s %s' % (n, v))


if __name__ == '__main__':
    main()
