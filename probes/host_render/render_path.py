"""Oracle-only probe (docs/HOST_RENDER_LAYER.md): the plugin's HOST render layer.

Boots the plugin as a host does (probes/b6/wrapper_emu.py), optionally sets the
plugin's internal-rate setting vm.vs.sampleRate (id 0x0FFFC015, Script.xml
range 0..3, default 0) through setState, runs setupProcessing(host rate, 512)
and setActive(1), then calls the plugin's own IAudioProcessor::process (rva
0x34A380) for three 512-sample blocks with a ProcessContext tempo of 128.5 BPM
(kTempoValid | kPlaying). Logged, by hooks: the engine's setSampleRate (vt+24,
rva 0x3C7A20) and its render (vt+56, rva 0x3C7400, whose body is SKIPPED: its
worker threads are not emulated here -- this probe only traces the call
chain), the core's render paths (rva 0x344270 identity, 0x343E30 rate
converter, 0x344280 silence), the arp tick (vt+184, rva 0x3C6750) and the
tempo entry (vt+176, rva 0x3C7F10).

    python3 probes/host_render/render_path.py <host rate> [setting index]
e.g. 48000 (default setting: engine 96000 + converter), 48000 2 (engine 48000,
identity), 96000 (identity), 44100 / 44100 3."""
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import wrapper_emu as W                                     # noqa: E402
from unicorn import UC_HOOK_CODE                            # noqa: E402
from unicorn.x86_const import UC_X86_REG_RSP, UC_X86_REG_RIP, UC_X86_REG_XMM1   # noqa: E402

E = W.E
IB = E.IB
SAMPLERATE_ID = 0x0FFFC015          # vm.vs.sampleRate (address 21 of the vm.vs block)


def main():
    host_sr = float(sys.argv[1]) if len(sys.argv) > 1 else 48000.0
    setting = int(sys.argv[2]) if len(sys.argv) > 2 else None
    w = W.Wrapper()
    w.boot_host(log=lambda s: None)
    uc = w.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    i32 = lambda a: struct.unpack('<i', uc.mem_read(a, 4))[0]
    log = []

    def h_setsr(uc_, addr, size, ud):
        x = uc_.reg_read(UC_X86_REG_XMM1) & 0xFFFFFFFF
        log.append('engine setSampleRate(%.1f)' % struct.unpack('<f', struct.pack('<I', x))[0])

    def h_render(uc_, addr, size, ud):
        rsp = uc_.reg_read(UC_X86_REG_RSP)
        log.append('engine render n=%d' % struct.unpack('<i', uc_.mem_read(rsp + 0x30, 4))[0])
        uc_.reg_write(UC_X86_REG_RIP, q(rsp))
        uc_.reg_write(UC_X86_REG_RSP, rsp + 8)

    def tag(name):
        return lambda uc_, addr, size, ud: log.append(name)
    uc.hook_add(UC_HOOK_CODE, h_setsr, begin=IB + 0x3C7A20, end=IB + 0x3C7A20)
    uc.hook_add(UC_HOOK_CODE, h_render, begin=IB + 0x3C7400, end=IB + 0x3C7400)
    for r, nm in ((0x344270, 'path IDENTITY'), (0x343E30, 'path CONVERTER'), (0x344280, 'path SILENCE'),
                  (0x3C6750, 'arp tick'), (0x3C7F10, 'tempo entry')):
        uc.hook_add(UC_HOOK_CODE, tag(nm), begin=IB + r, end=IB + r)
    uc.ctl_remove_cache(IB, IB + E.IMGSZ)
    core = w.core

    def fields(tag_):
        cv = q(core + 96)
        print('%-22s engine rate (core+104) %d, host rate (core+108) %d, wanted engine rate (core+588) %d; '
              'render object {%d, %d, %d, %d} fn rva 0x%x' % (
                  tag_, i32(core + 104), i32(core + 108), i32(core + 588),
                  *struct.unpack('<iiii', uc.mem_read(cv, 16)), q(cv + 24) - IB))
    st = w.get_state()
    n = struct.unpack('>I', st[:4])[0]
    ent = [list(struct.unpack('>Ii', st[4 + i:12 + i])) for i in range(0, n, 8)]
    print('vm.vs entries in the plugin\'s getState:', ['0x%08X=%d' % (a, b) for a, b in ent if 0x0FFFC000 <= a < 0x10000000])
    fields('after boot')
    if setting is not None:
        e2 = [[a, (setting if a == SAMPLERATE_ID else b)] for a, b in ent]
        blob = struct.pack('>I', 8 * len(e2)) + b''.join(struct.pack('>Ii', a, b) for a, b in e2)
        print('setState(vm.vs.sampleRate = %d) -> %d %s' % (setting, w.set_state(blob), log)); del log[:]
        fields('after setState')
    setup = w.alloc_com(24)
    uc.mem_write(setup, struct.pack('<iii4xd', 0, 0, 512, host_sr))
    print('setupProcessing(%g) -> 0x%x %s' % (host_sr, w.vcall(w.audio, 7, setup, count=4_000_000_000) & 0xFFFFFFFF, log)); del log[:]
    print('setActive(1) -> 0x%x %s' % (w.vcall(w.comp, 11, 1, count=4_000_000_000) & 0xFFFFFFFF, log)); del log[:]
    fields('after setActive')
    N = 512
    bufL, bufR = w.alloc_com(4 * N), w.alloc_com(4 * N)
    chans = w.alloc_com(16)
    uc.mem_write(chans, struct.pack('<QQ', bufL, bufR))
    bus = w.alloc_com(24)
    uc.mem_write(bus, struct.pack('<iiQQ', 2, 0, 0, chans))
    ctx = w.alloc_com(160)
    uc.mem_write(ctx, b'\0' * 160)
    uc.mem_write(ctx, struct.pack('<I', 0x400 | 2))           # kTempoValid | kPlaying
    uc.mem_write(ctx + 8, struct.pack('<d', host_sr))
    uc.mem_write(ctx + 72, struct.pack('<d', 128.5))           # tempo
    pd = w.alloc_com(96)
    uc.mem_write(pd, b'\0' * 96)
    uc.mem_write(pd, struct.pack('<iiiii4xQQ', 0, 0, N, 0, 1, 0, bus))
    uc.mem_write(pd + 72, struct.pack('<Q', ctx))
    for blk in range(3):
        r = w.vcall(w.audio, 9, pd, count=4_000_000_000) & 0xFFFFFFFF
        print('process block %d -> 0x%x %s' % (blk, r, log)); del log[:]
    fields('after 3 blocks')
    print('tempo the driver keeps (core+580) %d; arp tick phase (core+560) %d' % (i32(core + 580), q(core + 560)))


if __name__ == '__main__':
    main()
