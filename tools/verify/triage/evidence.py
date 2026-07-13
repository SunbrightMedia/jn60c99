#!/usr/bin/env python3
"""Seed-70 residual: evidence around the introducing event (ev23 = blob-59 TEMPO
SYNC flip, byte 139, @frame 9175). Replays ev[:23] (everything up to the flip,
fuzz_diff conventions VERBATIM), then:
  1. baseline full-state diff  (plugin unit-8 vs port flat state)
  2. plugin write-set of dispatch idx 803 val 139 on all 9 units + snap_all
     (UC_HOOK_MEM_WRITE, per unit) ; port write-set of juno_gui_set_param(24,139)
     (full 12MB pre/post snapshot diff)
  3. post-flip full-state diff; introduced mismatches = post-set minus pre-set
"""
import sys, struct, ctypes
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import fuzz_diff as F
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE

lib = F.lib
BLOBS = F.BLOBS
STATE = 12 * 1024 * 1024

rate, patch, EV, total = F.gen_script(70)
assert (rate, patch) == (48000.0, 15)
PRE = EV[:23]          # events before the flip (last render ends @9175)
FLIP_ROW, FLIP_BYTE = EV[23][1], EV[23][2]
assert (BLOBS[FLIP_ROW], FLIP_BYTE) == (59, 139)

# ---------------- plugin ----------------
e = E.E2E(); e.build(rate); e.snap_all(); E.recall_patch(e, patch)
e.snap_all(); e.clear_latch(); e.set_ftz()
for x in PRE:
    if x[0] == 'on': e.note_on(x[1], x[2])
    elif x[0] == 'off': e.note_off(x[1])
    elif x[0] == 'param':
        for u in range(9):
            try: e.dispatch(u, BLOBS[x[1]] + 744, x[2])
            except RuntimeError: pass
        e.snap_all()
    else:
        e.render(x[1])

def plug_state(u):
    out = b''
    for off in range(0, STATE, 0x400000):
        out += bytes(e.uc.mem_read(e.state[u] + off, min(0x400000, STATE - off)))
    return out

# write hooks on all 9 unit states
writes = []            # (unit, off, old_bits, new_bits, size)
capture = [False]
def mk_hook(u, base):
    def h(uc, access, addr, size, value, user):
        if not capture[0]: return
        old = bytes(uc.mem_read(addr, size))
        writes.append((u, addr - base, int.from_bytes(old, 'little'),
                       value & ((1 << (8*size)) - 1), size))
    return h
for u in range(9):
    st = e.state[u]
    e.uc.hook_add(UC_HOOK_MEM_WRITE, mk_hook(u, st), begin=st, end=st + E.STATE_SZ)

plug_pre = plug_state(8)

writes.clear(); capture[0] = True
for u in range(9):
    try: e.dispatch(u, BLOBS[FLIP_ROW] + 744, FLIP_BYTE)
    except RuntimeError: pass
disp_writes = list(writes)
writes.clear()
e.snap_all()           # harness convention (settles any armed ramps)
capture[0] = False
snap_writes = list(writes)

plug_post = plug_state(8)

# ---------------- port ----------------
bank = open(F.BANK, 'rb').read()
c = lib.juno_gui_create(ctypes.c_float(rate), 0)
lib.juno_gui_apply_bank(c, bank, len(bank), patch)
for x in PRE:
    if x[0] == 'on': lib.juno_gui_note_on(c, x[1], x[2])
    elif x[0] == 'off': lib.juno_gui_note_off(c, x[1])
    elif x[0] == 'param': lib.juno_gui_set_param(c, x[1], x[2])
    else:
        n = x[1]; buf = (ctypes.c_float * (2*n))(); lib.juno_gui_render(c, buf, n)

st_ptr = ctypes.cast(ctypes.c_void_p(c), ctypes.POINTER(ctypes.c_uint64))[0]
def port_state():
    return ctypes.string_at(st_ptr, STATE)

port_pre = port_state()
lib.juno_gui_set_param(c, FLIP_ROW, FLIP_BYTE)
port_post = port_state()

# ---------------- reports ----------------
def diff_states(a, b):
    """4-byte cells where a != b -> {off: (bits_a, bits_b)}"""
    out = {}
    ua = memoryview(a); ub = memoryview(b)
    for off in range(0, STATE, 4):
        if ua[off:off+4] != ub[off:off+4]:
            out[off] = (int.from_bytes(ua[off:off+4], 'little'),
                        int.from_bytes(ub[off:off+4], 'little'))
    return out

print("=== plugin dispatch(idx 803, val 139) raw writes ===")
for u, off, old, new, size in disp_writes:
    tag = " *" if u == 8 else ""
    print(f"  u{u} off={off:8d} old={old:0{2*size}x} new={new:0{2*size}x} sz={size}{tag}")
print(f"  total {len(disp_writes)}")
print("=== snap_all writes after dispatch (unit 8 only shown) ===")
for u, off, old, new, size in snap_writes:
    if u == 8:
        print(f"  u8 off={off:8d} old={old:0{2*size}x} new={new:0{2*size}x} sz={size}")
print(f"  total(all units) {len(snap_writes)}")

port_wr = {}
va = memoryview(port_pre); vb = memoryview(port_post)
for off in range(0, STATE, 4):
    if va[off:off+4] != vb[off:off+4]:
        port_wr[off] = (int.from_bytes(va[off:off+4], 'little'),
                        int.from_bytes(vb[off:off+4], 'little'))
print("=== port set_param(row 24, 139) state delta ===")
for off, (o, n) in sorted(port_wr.items()):
    print(f"  off={off:8d} old={o:08x} new={n:08x}")

pre_mm  = diff_states(plug_pre,  port_pre)
post_mm = diff_states(plug_post, port_post)
intro = {off: post_mm[off] for off in post_mm if off not in pre_mm or pre_mm[off] != post_mm[off]}
print(f"=== baseline (pre-flip) unit8-vs-port mismatched cells: {len(pre_mm)} ===")
shown = 0
for off, (p, q) in sorted(pre_mm.items()):
    if 4297000 <= off < 4300000 or 102000 <= off < 103000 or 6395000 <= off < 6397000:
        print(f"  [dly] off={off:8d} plug={p:08x} port={q:08x}")
    else:
        shown += 1
print(f"  (+{shown} mismatches outside delay regions — count only)")
print(f"=== INTRODUCED by flip (post minus pre): {len(intro)} cells ===")
for off, (p, q) in sorted(intro.items()):
    b = pre_mm.get(off)
    print(f"  off={off:8d} plug={p:08x} port={q:08x}   (pre: {'match' if b is None else f'{b[0]:08x}/{b[1]:08x}'})")

# key delay-2 cells snapshot both sides post-flip
KEY = [4297440, 4297456, 4297472, 4297488, 4297504, 4297520, 4297536, 4297584,
       4297760, 4297792, 4297808, 4297824, 4297840, 4297856, 4297872, 4297888,
       4298000, 4298016, 4298032, 4298048, 4298064, 4298080, 6395248, 6395252,
       102352, 11022348]
print("=== key cells post-flip (plug u8 / port) ===")
for off in KEY:
    p = int.from_bytes(plug_post[off:off+4], 'little')
    q = int.from_bytes(port_post[off:off+4], 'little')
    mark = "  <-- MISMATCH" if p != q else ""
    print(f"  off={off:8d} plug={p:08x} port={q:08x}{mark}")
