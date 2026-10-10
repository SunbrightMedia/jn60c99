#!/usr/bin/env python3
"""jx_guest_export.py -- the plugin's own memory after its boot, as the port's GUEST IMAGE (JX-11; JXG1).

The port holds the plugin's heap in the plugin's own layout, at the plugin's own guest addresses (jx_bridge.c,
JX_GUEST): the lifted parameter system (jx3p/src/jx_lift.c, the plugin's host entry 0x3F9A30 and its reach) and the
transcribed DSP work on the same bytes. This file is what that memory starts from:

  the oracle (tools/verify/jx_emu.py boot(96000, product=True): the plugin's factory HOST, BUILD, SETSR at the
  engine's rate, initialize's records through its own host entry -- the engine a fresh instance holds before its
  first block) -> the WHOLE heap, sparse (nonzero runs); the image pages the lifted code reads (image_pages: the
  dynamic census jx3p/gen/jx_lift_pages.json and a static one of the lifted source); the guest stack the lifted
  calls run on; the HOST's
  address (every other object is found by following the plugin's own pointers from it); the MXCSR the plugin runs
  at; and the factory bank's patch records (jx3p/gen/jx_patch_records.json: what the plugin's patch browser queues
  for each patch, kind 2 = engine parameter records).

  'JXG1' u32 version
  u64 heap_base, heap_len, host, image_base, stack_lo, stack_len, rsp
  u32 mxcsr, f32 engine_rate
  u32 nrun; nrun x { u32 heap offset, u32 len, bytes }
  u32 nrun; nrun x { u32 image rva, u32 len, bytes }
  u32 npatch; npatch x { u32 nrec, nrec x { u32 id, u32 value } }
  u32 crc32 of everything before

    python3 jx3p/tools/jx_guest_export.py [--rate 96000] [--out jx3p/gen/jx_guest_96k.bin]
Writes OUT and OUT.gz (no name, no time: equal bytes every run).
"""
import gzip
import json
import os
import struct
import sys
import zlib

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import jx_emu as J                                    # noqa: E402

STACK_BELOW = 0x20000                                 # guest stack mapped below rsp (census: the calls use < 0x2000)
STACK_ABOVE = 0x1000
GAP = 64                                              # zero gaps shorter than this stay inside a run


def runs(buf, gap=GAP):
    """nonzero runs of buf as (offset, length), zero gaps shorter than gap merged"""
    import re
    out = []
    for m in re.finditer(rb'[^\x00]+', buf):
        s, e = m.span()
        if out and s - (out[-1][0] + out[-1][1]) < gap:
            out[-1][1] = e - out[-1][0]
        else:
            out.append([s, e - s])
    return [tuple(r) for r in out]


def image_pages():
    """the image pages the port's guest image carries: the union of
      the dynamic census (jx3p/gen/jx_lift_pages.json: the pages the lifted calls touched over the reach runs),
      every data address the lifted source names (a 0x18xxxxxxx literal in .rdata / .data) and the page after it
      (an indexed table may run on),
      every switch table of a lifted function (its jmp-reg site's table load, entries read as the lifter reads
      them), and every live class's vtable (jx3p/gen/jx_lift_roots.json).
    On Linux the port makes every other page of the image block no-access (jx_bridge.c): a read the census missed
    crashes the gate that made it, never reads zeros."""
    import re
    import capstone
    from capstone import x86
    img = bytes(J.IMG)
    src = open(os.path.join(REPO, 'jx3p', 'src', 'jx_lift.c')).read()
    pages = set(json.load(open(os.path.join(REPO, 'jx3p', 'gen', 'jx_lift_pages.json')))['image'])
    for m in re.findall(r'\b0x(18[0-9a-f]{7})ULL\b', src):
        r = int(m, 16) - J.IB
        if 0x96B000 <= r < J.IMGSZ:
            pages.update({r & ~0xFFF, (r + 15) & ~0xFFF, ((r & ~0xFFF) + 0x1000)})
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    md.detail = True
    for site in sorted(set(int(x, 16) for x in re.findall(r'/\*([0-9a-f]+) jmp r[a-z0-9]+\*/', src))):
        ins = list(md.disasm(img[site - 16:site + 2], J.IB + site - 16))
        for k in range(len(ins)):           # decode from every start that lands on the site
            seq = list(md.disasm(img[site - 16 + k:site + 2], J.IB + site - 16 + k))
            if seq and seq[-1].address - J.IB == site and len(seq) >= 3:
                mov = seq[-3]
                if mov.mnemonic == 'mov' and len(mov.operands) == 2 and mov.operands[1].type == x86.X86_OP_MEM and \
                        mov.operands[1].mem.scale == 4:
                    tbl = mov.operands[1].mem.disp
                    n = 0
                    while n < 1024:
                        e = struct.unpack_from('<I', img, tbl + 4 * n)[0]
                        if not (0x1000 <= e < 0x96B000) or abs(e - site) > 0x40000:
                            break
                        n += 1
                    for a in range(tbl & ~0xFFF, tbl + 4 * n + 1, 0x1000):
                        pages.add(a & ~0xFFF)
                break
    for c in json.load(open(os.path.join(REPO, 'jx3p', 'gen', 'jx_lift_roots.json')))['classes']:
        v = int(c['vtable'], 16)
        for a in range(v - 8, v + 8 * c['slots'], 8):
            pages.add(a & ~0xFFF)
    return sorted(p for p in pages if 0x1000 <= p < J.IMGSZ)


def control_raw(jx):
    """the 36 control objects as the plugin holds them, every byte (the port's guest memory holds the same, at
    the same addresses): per unit its note manager (0x7A8 from HOST+0x78+0x40 u), note store (its +0x518, 0xFF0)
    and assigner (its +0x520, 0xB0); then the nine parameter objects (0x700)"""
    uc = jx.uc
    rq = lambda a: int.from_bytes(uc.mem_read(a, 8), 'little')
    out = []
    for i in range(9):
        u = rq(jx.HOST + 0x78 + 0x40 * i)
        out += [bytes(uc.mem_read(u, 0x7A8)), bytes(uc.mem_read(rq(u + 0x518), 0xFF0)),
                bytes(uc.mem_read(rq(u + 0x520), 0xB0))]
    for i in range(9):
        out.append(bytes(uc.mem_read(jx.proc[i], 0x700)))
    return out


def wrap_record(jx, u):
    """unit u's wrapper + ramp records as the plugin holds them, in the compared form (jx_bridge.c
    jx3p_wrap_dump): the start-mute count [st+0xAAC308], the flag [st+0x14], the active ids ([st+0x70],
    [st+0x78]), then per slot of [st+0x58] its target as an offset in the unit (0xFFFFFFFF: none) and its
    bytes +8..+0x27"""
    uc = jx.uc
    rq = lambda a: int.from_bytes(uc.mem_read(a, 8), 'little')
    st = jx.state[u]
    latch = struct.unpack('<i', uc.mem_read(st + 0xAAC308, 4))[0]
    flag = uc.mem_read(st + 0x14, 1)[0]
    arr, b0, e0 = rq(st + 0x58), rq(st + 0x70), rq(st + 0x78)
    ids = list(struct.unpack('<%di' % ((e0 - b0) // 4), uc.mem_read(b0, e0 - b0))) if e0 > b0 else []
    nslot = (max(ids) + 1) if ids else 0
    rec = struct.pack('<iBxxxI', latch, flag, len(ids))
    rec += struct.pack('<%di' % len(ids), *ids) if ids else b''
    rec += struct.pack('<I', nslot)
    for i in range(nslot):
        sl = bytes(uc.mem_read(arr + 40 * i, 40))
        tgt = struct.unpack('<Q', sl[:8])[0]
        rec += struct.pack('<I', (tgt - st if tgt else 0xFFFFFFFF) & 0xFFFFFFFF) + sl[8:]
    return rec


def host_record(jx):
    """the engine HOST's cells the render reads: +0x38 voices, +0x860 gain, +0x864 step, +0x868 samples left,
    +0x86C delay, +0x870 fade time, +8 the engine rate (28 bytes, jx_bridge.c jx3p_host's layout)"""
    r = lambda off, n: bytes(jx.uc.mem_read(jx.HOST + off, n))
    return r(0x38, 4) + r(0x860, 20) + r(8, 4)


def guest_file(rate_k, tmp=None):
    """the committed guest image for an engine rate (44 or 96): the raw file, or the .gz inflated into tmp"""
    raw = os.path.join(REPO, 'jx3p', 'gen', 'jx_guest_%dk.bin' % rate_k)
    if os.path.exists(raw):
        return raw
    import tempfile
    dst = os.path.join(tmp or tempfile.mkdtemp(), 'jx_guest_%dk.bin' % rate_k)
    with gzip.open(raw + '.gz', 'rb') as f:
        open(dst, 'wb').write(f.read())
    return dst


def main():
    a = sys.argv[1:]
    opt = lambda k, d: a[a.index(k) + 1] if k in a else d
    rate = float(opt('--rate', '96000'))
    out = opt('--out', os.path.join(REPO, 'jx3p', 'gen', 'jx_guest_%dk.bin' % int(rate // 1000)))
    img_pages = image_pages()
    jx = J.JX().boot(rate, snap=False, product=True)
    uc = jx.uc
    heap_len = ((jx.heap + 0xFFF) & ~0xFFF) - J.HEAP_BASE
    heap = bytes(uc.mem_read(J.HEAP_BASE, heap_len))
    rsp = (J.STACK_BASE + J.STACK_SIZE - 0x10000) & ~0xF
    mx = getattr(jx, '_mxcsr', 0x1F80)
    body = b'JXG1' + struct.pack('<I', 1)
    body += struct.pack('<7Q', J.HEAP_BASE, heap_len, jx.HOST, J.IB, rsp - STACK_BELOW, STACK_BELOW + STACK_ABOVE, rsp)
    body += struct.pack('<If', mx, rate)
    hr = runs(heap)
    body += struct.pack('<I', len(hr))
    for off, ln in hr:
        body += struct.pack('<II', off, ln) + heap[off:off + ln]
    # the image pages, consecutive pages merged into one run, as the booted plugin holds them (its static
    # initializers wrote .data)
    img = img_pages
    ir = []
    for rva in img:
        if ir and ir[-1][0] + ir[-1][1] == rva:
            ir[-1][1] += 0x1000
        else:
            ir.append([rva, 0x1000])
    body += struct.pack('<I', len(ir))
    for rva, ln in ir:
        body += struct.pack('<II', rva, ln) + bytes(uc.mem_read(J.IB + rva, ln))
    recs = J.JX.records()['patches']
    body += struct.pack('<I', len(recs))
    for p in recs:
        kv = [(pid, val & 0xFFFFFFFF) for kind, pid, val in p if kind == 2]
        body += struct.pack('<I', len(kv)) + b''.join(struct.pack('<II', pid, v) for pid, v in kv)
    body += struct.pack('<I', zlib.crc32(body) & 0xFFFFFFFF)
    open(out, 'wb').write(body)
    with open(out + '.gz', 'wb') as fh, gzip.GzipFile(filename='', mode='wb', compresslevel=9, fileobj=fh,
                                                     mtime=0) as gz:
        gz.write(body)
    print('guest image: heap 0x%x bytes in %d runs (%d bytes), %d image pages in %d runs, %d patches; '
          '%d bytes (%d gz) -> %s' % (heap_len, len(hr), sum(n for _, n in hr), len(img), len(ir), len(recs),
                                      len(body), os.path.getsize(out + '.gz'), out))
    return 0


if __name__ == '__main__':
    sys.exit(main())
