#!/usr/bin/env python3
"""jn_host_mem_ref.py -- L5 (init) ORACLE side: the JUNO host oracle (host_process_emu.HostProcess) booted to the
template cut (boot_host) and then setup(48000, 512) -- setupProcessing, setActive(1), the blocks' host objects. It
dumps the memory the lifted junoh_init must reproduce byte for byte: the image (globals the setup wrote), the heap up
to the bump pointer, the host-object arena up to com_next, and the scalars. Unicorn only (two-process rule: never with
a ctypes libjuno in one process). usage: python3 tools/lift/jn_host_mem_ref.py <outdir>"""
import sys
import os
import json

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
sys.path.insert(0, os.path.join(REPO, 'probes', 'b6'))
os.environ.setdefault('JP8_EMU_QUIET', '1')
import host_process_emu as H                                        # noqa: E402
E = H.E
IB = E.IB
COM = H.W.COM


def main():
    outdir = sys.argv[1]
    os.makedirs(outdir, exist_ok=True)
    h = H.HostProcess()
    h.boot_host(log=lambda s: None)
    h.setup(48000.0, 512)
    uc = h.uc

    def dump(name, base, size):
        open(os.path.join(outdir, name), 'wb').write(bytes(uc.mem_read(base, size)))

    dump('image.bin', IB, E.IMGSZ)
    dump('heap.bin', E.HEAP_BASE, h.heap - E.HEAP_BASE)
    dump('com.bin', COM, h.com_next - COM)
    meta = dict(heap_top=h.heap, com_next=h.com_next, core=h.core, comp=h.comp, audio=h.audio, ctrl=h.ctrl,
                IB=IB, IMGSZ=E.IMGSZ, HEAP_BASE=E.HEAP_BASE, COM=COM)
    json.dump(meta, open(os.path.join(outdir, 'meta.json'), 'w'))
    print('oracle setup: heap_top 0x%x (%d KB), com_next 0x%x (%d KB), image %d MB -> %s'
          % (h.heap, (h.heap - E.HEAP_BASE) // 1024, h.com_next, (h.com_next - COM) // 1024, E.IMGSZ // (1 << 20), outdir))


if __name__ == '__main__':
    main()
