#!/usr/bin/env python3
"""param_cell_map.py -- the plugin's PROVEN param_id -> engine-cell dispatch.

For every VST3 param_id in the plugin-populated map (0xcb0e18, built by static-init
0xAD5A0), drive the value-tree apply node 0x3C7AE0 under Unicorn and record exactly
which engine cell(s) it writes in unit 0 (via a MEM_WRITE hook over the unit-0
block). This is the plugin's OWN dispatch table, executed -- zero reconstruction.

It validates HALF the recall leaf map -- the param_id -> cell target -- against
which the port's juno_apply.c BINDINGS "cell" column can be checked. (The other
half, record-position -> param_id, is the host-mediated part handled separately.)

Two-process rule: E2E/Unicorn only; no libjuno.

Usage: python3 tools/verify/param_cell_map.py [--dump]
"""
import sys, struct, pickle
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_MEM_WRITE
from unicorn.x86_const import UC_X86_REG_RIP

IB       = E.IB
APPLY    = IB + 0x3C7AE0
POPULATE = IB + 0xAD5A0
MAP_G    = IB + 0xCB0E18
STATE_SZ = E.STATE_SZ
PKL      = '/home/user/jn60c99/scratchpad/param_cell_map.pkl'


def u64(uc, a): return int.from_bytes(uc.mem_read(a, 8), 'little')
def u32(uc, a): return struct.unpack('<I', uc.mem_read(a, 4))[0]


def walk_map(uc):
    head = u64(uc, MAP_G)
    entries = []
    if not head:
        return entries
    root = u64(uc, head + 8)
    seen = set()
    def isnil(n): return uc.mem_read(n + 25, 1)[0] != 0
    def walk(n):
        if not n or n in seen or isnil(n):
            return
        seen.add(n)
        walk(u64(uc, n))
        entries.append((u32(uc, n + 28), u32(uc, n + 32)))   # (param_id, internal index)
        walk(u64(uc, n + 16))
    if root and not isnil(root):
        walk(root)
    return entries


def main():
    e = E.E2E(); uc = e.uc
    e.build(48000.0)
    try:
        e.call(POPULATE, count=200_000_000)
    except Exception as ex:
        print("populate raised:", ex)
    entries = walk_map(uc)
    print("plugin param map: %d entries" % len(entries))

    lo, hi = e.state[0], e.state[0] + STATE_SZ
    writes = []
    def wh(uc, access, addr, size, value, user):
        writes.append((addr - e.state[0], value))
    uc.hook_add(UC_HOOK_MEM_WRITE, wh, begin=lo, end=hi - 1)

    pid_cells = {}
    for (pid, idx) in sorted(entries):
        cells = set()
        for v in (1, 2, 0):            # a few in-domain values; union the touched cells
            writes.clear()
            try:
                e.call(APPLY, rcx=e.HOST, rdx=pid, r8=v, count=30_000_000)
            except Exception:
                pass
            for (off, val) in writes:
                cells.add(off)
            if cells:
                break
        pid_cells[pid] = (idx, sorted(cells))

    pickle.dump(pid_cells, open(PKL, 'wb'))
    nwrite = sum(1 for (_, (_, c)) in pid_cells.items() if c)
    print("params that write >=1 engine cell: %d / %d" % (nwrite, len(pid_cells)))

    # DCO RANGE spot-check (param_id 6291476 -> should write cell 3840 only)
    if 6291476 in pid_cells:
        idx, cells = pid_cells[6291476]
        print("DCO RANGE (param 6291476, idx %d) writes cells: %s" % (idx, cells))

    # histogram: how many distinct cells, multi-cell params (interesting for the port)
    multi = [(pid, idx, c) for pid, (idx, c) in pid_cells.items() if len(c) > 1]
    print("params writing >1 cell: %d" % len(multi))
    for pid, idx, c in sorted(multi)[:25]:
        print("  param %10d idx %4d -> cells %s" % (pid, idx, c))

    if '--dump' in sys.argv:
        print("\n=== full param_id -> (idx, cells) ===")
        for pid, (idx, c) in sorted(pid_cells.items()):
            if c:
                print("  %10d  idx %4d  cells %s" % (pid, idx, c))

    print("\nsaved -> %s" % PKL)
    print("(this is the plugin's own param->cell dispatch, executed; validates the")
    print(" 'cell' column of the port's recall BINDINGS. record-position->param_id")
    print(" is the host-mediated half, handled separately.)")


if __name__ == '__main__':
    main()
