"""Oracle-only census (CLAIMS B6): what the plugin's OWN patch load (its GUI
"ManagePatch load" command, rva 0x322E60 -> patch manager rva 0x338090 ->
rva 0x335850) hands the engine.

READ: rva 0x335850 raises the model's marker 2*slot, builds the patch's leaf
list (rva 0x352CA0) and walks it depth first (rva 0x338330), setting every
leaf from the patch bytes at its running offset (the serialized width of each
leaf), then the marker 2*slot+1. Each model set reaches the core's listener
(rva 0x347050), which queues an engine event like setState's.

This probe boots the plugin as a host does (probes/b6/wrapper_emu.py), then
calls rva 0x335850 directly with a patch vector holding bank record k's bytes
after its 16-byte name (the plugin's own bank file, truth/: the leaf walk
starts with SYS_COM, Local SW / Master Tune (SYSTEM-1) / MASTER TUNE = 01 0a
06 04 in every factory record), the model of the component's serializer
(IComponent + 280, its +8), slot 0 and flag 0 (the handler's "load"), and
records the engine queue and the host-handler calls. A run that leaves the
image (a call through a null pointer) stops and is reported. Also: the model's
own serialization of the patch tree (rva 0x335990, the "save" half: the same
leaf list, each struct's bytes) at boot -- the default record -- and after each
load (the round trip), and the parameter map (id -> dispatch index) the host
entry walks.
Writes scratchpad/b6/patch_load_census.pkl.
    python3 probes/b6/patch_load_census.py [patch ...]      (Unicorn only)"""
import os, sys, struct, pickle, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wrapper_emu as W

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import truth
OUT = os.path.join(REPO, 'scratchpad', 'b6', 'patch_load_census.pkl')
HEADER, STRIDE = 23, 20223
LOAD = 0x335850
NAME = 16


def decode(q):
    return [(kind, off, struct.unpack_from('<I', rec, 12)[0], struct.unpack_from('<i', rec, 20)[0]) for kind, off, rec in q]


def main():
    bank = open(truth.BANK, 'rb').read()
    if sys.argv[1:2] == ['--craft']:
        # records whose bytes carry bits a nibble field does not: the decode law
        # (each byte of record 0 after the name OR-ed with a pattern)
        out = OUT.replace('.pkl', '_craft.pkl')
        base = bytearray(bank[HEADER:HEADER + STRIDE])
        recs = []
        for pat in (0x10, 0x30, 0x70, 0xF0, 0x80):
            r = bytearray(base)
            for i in range(NAME, STRIDE):
                r[i] |= pat
            recs.append(bytes(r))
        # and bytes that change with their position (no two offsets alike)
        for mul, add in ((29, 7), (53, 101), (197, 3)):
            r = bytearray(base)
            for i in range(NAME, STRIDE):
                r[i] = (i * mul + add + (i >> 8) * 17) & 0xFF
            recs.append(bytes(r))
        bank = bank[:HEADER] + b''.join(recs)
        patches = list(range(len(recs)))
    else:
        out = OUT
        patches = [int(x) for x in sys.argv[1:]] or list(range(64))
    t0 = time.time()
    w = W.Wrapper(); uc = w.uc
    w.boot()
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    fac = w.call(W.FACTORY, count=100_000_000)
    buf = w.alloc_com(0x40)
    uc.mem_write(buf, bytes.fromhex('c74480f256663d4c9cfcecce62993ffd') + W.IID_IEDITCONTROLLER)
    assert w.vcall(fac, 6, buf, buf + 16, buf + 0x30) & 0xFFFFFFFF == 0
    ctrl = q(buf + 0x30)
    assert w.vcall(ctrl, 3, w.new_obj('hostctx'), count=4_000_000_000) & 0xFFFFFFFF == 0

    def qi(obj, iid):
        uc.mem_write(buf, iid)
        assert w.vcall(obj, 0, buf, buf + 0x30) & 0xFFFFFFFF == 0
        return q(buf + 0x30)
    cp_p, cp_c = qi(w.comp, W.IID_ICONNECTIONPOINT), qi(ctrl, W.IID_ICONNECTIONPOINT)
    assert w.vcall(cp_p, 3, cp_c) & 0xFFFFFFFF == 0 and w.vcall(cp_c, 3, cp_p) & 0xFFFFFFFF == 0
    assert w.vcall(ctrl, 16, w.new_obj('handler')) & 0xFFFFFFFF == 0
    model_pp = q(w.comp + 280 + 8)
    from unicorn import UC_HOOK_BLOCK
    IMG_END = W.IB + W.E.IMGSZ
    RET = W.E.SCRATCH + 0x5000

    def guard(uc_, addr, size, ud):
        if not (W.IB <= addr < IMG_END or W.E.STUB_BASE <= addr < W.E.STUB_BASE + 0x100000 or addr == RET):
            print('  left the image at 0x%x' % addr, flush=True)
            uc_.emu_stop()
    uc.hook_add(UC_HOOK_BLOCK, guard)
    # the leaf walk's set-from-bytes call (rva 0x3383CD: r14 -> running offset,
    # rsi = the leaf's serialized width, rdi = the leaf) and its return (0x3383D2):
    # which record bytes each queued event came from
    from unicorn import UC_HOOK_CODE
    from unicorn.x86_const import UC_X86_REG_R14, UC_X86_REG_RSI, UC_X86_REG_RDI
    walk = []
    cur = {'data': 0}

    def pre(uc_, addr, size, ud):
        off = struct.unpack('<i', uc_.mem_read(uc_.reg_read(UC_X86_REG_R14), 4))[0]
        wd = uc_.reg_read(UC_X86_REG_RSI) & 0xFFFFFFFF
        walk.append([off, wd, bytes(uc_.mem_read(cur['data'] + off, wd)).hex(), len(w.queue()), None])

    def post(uc_, addr, size, ud):
        walk[-1][4] = len(w.queue())
    uc.hook_add(UC_HOOK_CODE, pre, begin=W.IB + 0x3383CD, end=W.IB + 0x3383CD)
    uc.hook_add(UC_HOOK_CODE, post, begin=W.IB + 0x3383D2, end=W.IB + 0x3383D2)
    uc.ctl_remove_cache(W.IB, IMG_END)
    res = {'boot_s': time.time() - t0, 'init_queue': decode(w.queue()), 'loads': []}

    def save():
        vec = w.alloc_com(24)
        uc.mem_write(vec, bytes(24))
        w.call(W.IB + 0x335990, rcx=model_pp, rdx=vec, r8=0, r9=0, count=4_000_000_000)
        b, e = q(vec), q(vec + 8)
        return bytes(uc.mem_read(b, e - b))
    pid_of = {}

    def walkmap(n, seen=set()):
        if not n or n in seen or uc.mem_read(n + 25, 1)[0]:
            return
        seen.add(n); walkmap(q(n))
        pid, idx = struct.unpack('<II', uc.mem_read(n + 28, 8)); pid_of[pid] = idx
        walkmap(q(n + 16))
    walkmap(q(q(W.IB + 0xCB0E18) + 8))
    res['pid_to_dispatch'] = dict(pid_of)
    res['state0'] = w.get_state()
    res['default_bytes'] = save()
    # as a host does after connecting (and as state_load_census.py did): the
    # controller takes the component's state
    assert w.vcall(ctrl, 5, w.stream(res['state0']), count=4_000_000_000) & 0xFFFFFFFF == 0
    c600 = q(w.core + 600)
    print('core+600 = 0x%x, its vtable +0x78/+0x80/+0x88 = %s' % (c600, [hex(q(q(c600) + o)) for o in (0x78, 0x80, 0x88)] if c600 else None), flush=True)
    for k in patches:
        rec = bank[HEADER + k * STRIDE + NAME: HEADER + (k + 1) * STRIDE]
        data = w.alloc_com(len(rec) + 16)
        uc.mem_write(data, rec)
        cur['data'] = data
        del walk[:]
        vec = w.alloc_com(24)
        uc.mem_write(vec, struct.pack('<QQQ', data, data + len(rec), data + len(rec)))
        n0, e0 = len(w.queue()), len(w.edits)
        err = None
        try:
            w.call(W.IB + LOAD, rcx=vec, rdx=model_pp, r8=0, r9=0, count=4_000_000_000)
        except Exception as ex:
            err = repr(ex)[:200]
        qq = decode(w.queue())[n0:]
        res['loads'].append(dict(patch=k, err=err, queue=qq, edits=list(w.edits[e0:]), state=w.get_state(),
                                 walk=[(o, wd, hx, a - n0, b - n0 if b is not None else None) for o, wd, hx, a, b in walk],
                                 name_off=NAME, saved=save()))
        print('patch %2d: %3d engine events, %3d handler calls%s' % (k, len(qq), len(w.edits) - e0, ' ERR ' + err if err else ''))
    pickle.dump(res, open(out, 'wb'))
    print('wrote', out, '(%.0fs)' % (time.time() - t0))


if __name__ == '__main__':
    main()
