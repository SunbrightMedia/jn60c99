"""Oracle-only probe (HOSTPATH_PARITY_SCOPE STEP 1): the plugin's own default
of the SYSTEM "Keyboard Velocity SW" -- the wrapper flag that makes a note-on
play at its own velocity (on) or at a fixed 100 (off; juno_gui_set_kbd_velocity).

READ: the core's setup (rva 0x320420, run inside IComponent::initialize) builds
the 95-entry parameter list, queues its defaults, and sets the flag byte
core+572 = (settings object)->vt[128]() != 0. This probe boots the plugin as a
host does (probes/b6/wrapper_emu.py), watches every write to core+572 from
createInstance on, and reads the byte after initialize and after the
controller is connected (boot_host's remaining steps).
    python3 probes/b6/kbd_vel_default.py      (Unicorn only)"""
import os, sys, struct
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wrapper_emu as W
from unicorn import UC_HOOK_MEM_WRITE
from unicorn.x86_const import UC_X86_REG_RIP


def main():
    w = W.Wrapper()
    uc = w.uc
    assert w.call(W.DLLMAIN, rcx=W.IB, rdx=1, r8=0, count=3_000_000_000) == 1
    assert w.call(W.INITDLL, rcx=W.IB, count=3_000_000_000) & 0xFF == 1
    ap = w.call(W.CREATE_PROC, count=200_000_000)
    base = ap - 272
    core = base + 0x148
    flag = core + 572
    writes = []

    def on_write(uc_, access, addr, size, value, ud):
        if addr <= flag < addr + size:
            writes.append((uc_.reg_read(UC_X86_REG_RIP) - W.IB, (value >> (8 * (flag - addr))) & 0xFF))
    uc.hook_add(UC_HOOK_MEM_WRITE, on_write, begin=flag - 7, end=flag)
    # where the value comes from: rsi->vt[0x40]() (rva 0x320786) gives an object
    # whose vt[0x80]() (rva 0x320794) is the setting; plugin code or a host stub?
    from unicorn import UC_HOOK_CODE
    from unicorn.x86_const import UC_X86_REG_RAX, UC_X86_REG_RDX, UC_X86_REG_RSI
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    where = lambda a: ('image rva 0x%x' % (a - W.IB)) if W.IB <= a < W.IB + W.E.IMGSZ else ('OUTSIDE the image 0x%x' % a)
    trace, objs = [], []

    def at(uc_, addr, size, ud):
        r = addr - W.IB
        if r == 0x320786:
            trace.append('rsi=%s, vt[0x40] -> %s' % (where(uc_.reg_read(UC_X86_REG_RSI)), where(q(uc_.reg_read(UC_X86_REG_RAX) + 0x40))))
        elif r == 0x320794:
            trace.append('settings obj=%s, vt[0x80] -> %s' % (where(uc_.reg_read(UC_X86_REG_RAX)), where(q(uc_.reg_read(UC_X86_REG_RDX) + 0x80))))
            objs.append(uc_.reg_read(UC_X86_REG_RAX))
        elif r == 0x32079A:
            trace.append('vt[0x80] returned eax=%d' % (uc_.reg_read(UC_X86_REG_RAX) & 0xFFFFFFFF))
    for r in (0x320786, 0x320794, 0x32079A):
        uc.hook_add(UC_HOOK_CODE, at, begin=W.IB + r, end=W.IB + r)
    uc.ctl_remove_cache(W.IB, W.IB + W.E.IMGSZ)
    print('after createInstance: core+572 = %d' % uc.mem_read(flag, 1)[0])
    # the rest of boot(): IComponent::initialize with a host context
    w.base, w.comp, w.audio, w.core = base, base + 48, ap, core
    r = w.call(W.IB + 0x34A110, rcx=w.comp, rdx=w.new_obj('hostctx'), count=4_000_000_000) & 0xFFFFFFFF
    assert r == 0, 'initialize -> 0x%x' % r
    print('after initialize:     core+572 = %d' % uc.mem_read(flag, 1)[0])
    print('writes to core+572 (rva of the writing instruction, byte):', ['0x%x=%d' % wv for wv in writes])
    print('init queue: %d events' % len(w.queue()))
    for t in trace:
        print('  ' + t)
    # which setting: the value object's descriptor (its vt[12], as the getter
    # rva 0x2C02E0 calls it) -- print every string a qword of it points to
    def cstr(a, n=96):
        try:
            b = bytes(uc.mem_read(a, n))
        except Exception:
            return None
        t = b.split(b'\0')[0]
        return t.decode('latin1') if len(t) >= 3 and all(32 <= c < 127 for c in t) else None
    for o in objs:
        d = w.vcall(o, 12)
        print('  value object 0x%x, descriptor 0x%x: type %d, sign %d' % (o, d, struct.unpack('<i', uc.mem_read(d + 40, 4))[0],
                                                                     struct.unpack('<i', uc.mem_read(d + 44, 4))[0]))
        for k in range(0, 160, 8):
            for base_ in (o, d):
                v = q(base_ + k)
                t = cstr(v)
                if not t:
                    try:
                        t = cstr(q(v))
                    except Exception:
                        t = None
                if t:
                    print('    %s+%d -> "%s"' % ('obj' if base_ == o else 'desc', k, t[:80]))
    print('files the boot touched:', [f for f in getattr(w, 'fslog', [])][:40])


if __name__ == '__main__' and sys.argv[1:2] != ['--lifecycle']:
    main()


def lifecycle():
    """which later host calls move the flag: setState with each vm.vs id changed,
    then IAudioProcessor::setupProcessing, IComponent::setActive(1),
    setProcessing(1); every entry into the setup (rva 0x320420) and every write
    to core+572 is logged, and the velSense value object is read back"""
    from unicorn import UC_HOOK_CODE
    w = W.Wrapper()
    uc = w.uc
    w.boot_host(log=lambda s: None)
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    flag = w.core + 572
    log = []
    uc.hook_add(UC_HOOK_MEM_WRITE, lambda uc_, acc, addr, size, value, ud: log.append(
        'write core+572 = %d at rva 0x%x' % ((value >> (8 * (flag - addr))) & 0xFF, uc_.reg_read(UC_X86_REG_RIP) - W.IB))
        if addr <= flag < addr + size else None, begin=flag - 7, end=flag)
    uc.hook_add(UC_HOOK_CODE, lambda uc_, addr, size, ud: log.append('enter setup rva 0x320420'),
                begin=W.IB + 0x320420, end=W.IB + 0x320420)
    uc.ctl_remove_cache(W.IB, W.IB + W.E.IMGSZ)
    st0 = w.get_state()
    n = struct.unpack('>I', st0[:4])[0]
    ent = [list(struct.unpack('>Ii', st0[4 + i:12 + i])) for i in range(0, n, 8)]
    blob = lambda e: struct.pack('>I', 8 * len(e)) + b''.join(struct.pack('>Ii', a, b) for a, b in e)
    print('boot: core+572 = %d; vm.vs entries:' % uc.mem_read(flag, 1)[0],
          ['0x%08X=%d' % (a, b) for a, b in ent if a >= 0x0FFFC000])
    for vid in [a for a, b in ent if a >= 0x0FFFC000 and a != 0x0FFFC00E]:
        for v in (0, 1, 5):
            del log[:]
            e = [[a, (v if a == vid else b)] for a, b in ent]
            r = w.set_state(blob(e))
            print('setState 0x%08X=%d -> ret %d, core+572 = %d %s' % (vid, v, r, uc.mem_read(flag, 1)[0], log))
        w.set_state(blob(ent))
    # the processor lifecycle a host runs before audio
    del log[:]
    setup = w.alloc_com(24)
    uc.mem_write(setup, struct.pack('<iiid', 0, 0, 512, 48000.0))
    print('setupProcessing -> 0x%x' % (w.vcall(w.audio, 7, setup) & 0xFFFFFFFF), log, 'core+572 = %d' % uc.mem_read(flag, 1)[0])
    del log[:]
    print('setActive(1) -> 0x%x' % (w.vcall(w.comp, 11, 1, count=4_000_000_000) & 0xFFFFFFFF), log,
          'core+572 = %d' % uc.mem_read(flag, 1)[0])
    del log[:]
    print('setProcessing(1) -> 0x%x' % (w.vcall(w.audio, 8, 1) & 0xFFFFFFFF), log, 'core+572 = %d' % uc.mem_read(flag, 1)[0])


if __name__ == '__main__' and sys.argv[1:2] == ['--lifecycle']:
    lifecycle()
