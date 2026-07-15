#!/usr/bin/env python3
"""bridge_vecB_parammap.py -- ATTACK VECTOR B (executed under Unicorn).

Goal: UNBLOCK the object-graph stall by running the plugin's OWN init that
populates the VST3 param-id -> internal-index std::map at global 0xcb0e18, then
drive the value-tree per-param apply node 0x3C7AE0 with a KNOWN param-id read
back FROM the plugin-populated map and watch for the slot-11 setter (proc vtable
offset 0x58, rva 0x3B9A30) firing with rdx==760 (DCO RANGE) and feet
(state[u]+3840) changing.

Everything here is pure Unicorn plumbing (memory + register wiring). The map is
populated by the plugin's own CRT-static init sub_7FF91DD0D5A0 (rva 0xAD5A0),
the only non-dtor referencer of 0xcb0e18 besides the apply node. Param-ids are
READ FROM that plugin-built map, never hand-mapped.
"""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE
from unicorn.x86_const import *

IB       = E.IB
SETTER   = IB + 0x3B9A30     # proc vtable slot 11 (offset 0x58)
APPLY    = IB + 0x3C7AE0     # CWaveGen vtable slot 14 -- value-tree per-param apply
POPULATE = IB + 0xAD5A0      # CRT static init that builds table & inserts into map
MAP_G    = IB + 0xCB0E18     # global holding pointer to the std::map object
FEET_OFF = 3840

def u64(uc, a): return int.from_bytes(uc.mem_read(a, 8), 'little')
def u32(uc, a): return struct.unpack('<I', uc.mem_read(a, 4))[0]

def main():
    e = E.E2E()
    uc = e.uc

    # ---- setter-entry observer: MUST be installed BEFORE build(), because
    #      build() fires the setter 44694x (defaults) and JIT-caches its
    #      translation block; a CODE hook added later never retrofits the
    #      cached block. (MEM_WRITE hooks are exempt from this and fire anyway.)
    setter_hits = []
    def setter_hook(uc, address, size, user):
        if address != SETTER: return
        setter_hits.append((uc.reg_read(UC_X86_REG_RCX),
                            uc.reg_read(UC_X86_REG_RDX),
                            uc.reg_read(UC_X86_REG_R8),
                            uc.reg_read(UC_X86_REG_R9)))
    uc.hook_add(UC_HOOK_CODE, setter_hook, begin=SETTER, end=SETTER)

    e.build(48000.0)
    print("setter fired %d times during build() (defaults) -- confirms hook live"
          % len(setter_hits))

    # ---- baseline feet ----
    base_feet = [u32(uc, e.state[u] + FEET_OFF) for u in range(9)]
    print("baseline feet[u] (expect 0x3f800000 = 1.0):",
          [hex(x) for x in base_feet])

    feet_writes = []
    def feet_hook(uc, access, address, size, value, user):
        feet_writes.append((uc.reg_read(UC_X86_REG_RIP) - IB, address, value, size))
    for u in range(9):
        lo = e.state[u] + FEET_OFF
        uc.hook_add(UC_HOOK_MEM_WRITE, feet_hook, begin=lo, end=lo + 3)

    apply_hits = []
    def apply_hook(uc, address, size, user):
        if address != APPLY: return
        apply_hits.append((uc.reg_read(UC_X86_REG_RCX),
                           uc.reg_read(UC_X86_REG_RDX),
                           uc.reg_read(UC_X86_REG_R9)))
    uc.hook_add(UC_HOOK_CODE, apply_hook, begin=APPLY, end=APPLY)

    # ---- map state BEFORE population ----
    map_obj_before = u64(uc, MAP_G)
    print("\nmap global [0xcb0e18] BEFORE populate =", hex(map_obj_before))

    # ---- CONTROL: drive apply node while map is EMPTY (the stall baseline) ----
    setter_hits.clear(); feet_writes.clear()
    try:
        e.call(APPLY, rcx=e.HOST, rdx=6291476, r8=4, count=50_000_000)
    except Exception as ex:
        print("pre-populate APPLY raised:", ex)
    print("CONTROL (empty map): APPLY -> setter fired %d, feet writes %d"
          % (len(setter_hits), len(feet_writes)))

    # ---- run the plugin's OWN populate init (0xAD5A0) ----
    populated = False
    try:
        e.call(POPULATE, count=200_000_000)
        populated = True
        print("populate init 0xAD5A0 returned cleanly")
    except Exception as ex:
        print("populate init 0xAD5A0 raised:", ex)
        # even on partial run, the map may already be built; continue to inspect

    # Map object is inline at 0xcb0e18: [ _Myhead(sentinel node ptr), _Mysize ].
    head = u64(uc, MAP_G)                 # sentinel node pointer
    size = u64(uc, MAP_G + 8)             # _Mysize
    print("map global [0xcb0e18] AFTER  populate: _Myhead=%#x  _Mysize=%d"
          % (head, size))

    # ---- walk the plugin-populated std::map (node: L@+0,P@+8,R@+16,isnil@+25,
    #      key@+28, val@+32) ----
    entries = []
    if head:
        root = u64(uc, head + 8)          # _Myhead->_Parent = tree root
        print("tree root=%#x" % root)
        seen = set()
        def isnil(n): return uc.mem_read(n + 25, 1)[0] != 0
        def walk(n):
            if not n or n in seen or isnil(n): return
            seen.add(n)
            walk(u64(uc, n))             # left
            entries.append((u32(uc, n + 28), u32(uc, n + 32)))
            walk(u64(uc, n + 16))        # right
        if root and not isnil(root):
            walk(root)
    print("map entries recovered: %d" % len(entries))

    # find internal-index 760 (DCO RANGE) among plugin-populated values
    to760 = [k for (k, v) in entries if v == 760]
    vals_present = sorted({v for (k, v) in entries})
    print("distinct internal-index values in map: %d  (760 present? %s)"
          % (len(vals_present), 760 in vals_present))
    if entries:
        print("  sample entries (param_id -> idx):",
              [(k, v) for (k, v) in sorted(entries)[:12]])
    print("param-id(s) mapping to internal index 760:", to760)

    # ---- MECHANISM PROOF (U3): drive apply node with a param-id from the map ----
    print("\n=== MECHANISM PROOF (U3): drive apply node 0x3C7AE0 ===")
    if to760:
        pid = to760[0]
        setter_hits.clear(); feet_writes.clear(); apply_hits.clear()
        DCO_RANGE_VALUE = 4          # setter case 760 stores 2^(v-3): 4 -> 2.0
        print("calling APPLY(HOST, param_id=%d, value=%d)" % (pid, DCO_RANGE_VALUE))
        try:
            e.call(APPLY, rcx=e.HOST, rdx=pid, r8=DCO_RANGE_VALUE, count=50_000_000)
            # NB: APPLY is __fastcall(a1,a2,a3): rcx=a1(host), edx=a2(pid), r8d=a3(val)
        except Exception as ex:
            print("APPLY raised:", ex)
        print("apply-node entries:", apply_hits)
        rdx760 = [h for h in setter_hits if h[1] == 760]
        print("setter fired %d times; with rdx==760: %d" % (len(setter_hits), len(rdx760)))
        if setter_hits[:12]:
            print("  setter hits (rcx,rdx,r8,r9):",
                  [(hex(a), b, c, d) for (a, b, c, d) in setter_hits[:12]])
        print("feet writes during APPLY:",
              [(hex(r), hex(a), hex(v)) for (r, a, v, s) in feet_writes])
        after = [u32(uc, e.state[u] + FEET_OFF) for u in range(9)]
        print("feet[u] AFTER apply:", [hex(x) for x in after])
    else:
        print("internal index 760 is NOT a value in the plugin-populated map ->")
        print("the VST3 param path (apply node) never routes to DCO RANGE feet.")

    # ---- also try a3=3 -> feet should be 1.0, and a3=5 -> 4.0 to prove formula ----
    if to760:
        pid = to760[0]
        for v, exp in ((2, '0.5'), (3, '1.0'), (5, '4.0')):
            setter_hits.clear(); feet_writes.clear()
            try:
                e.call(APPLY, rcx=e.HOST, rdx=pid, r8=v, count=50_000_000)
            except Exception as ex:
                print("APPLY(v=%d) raised: %s" % (v, ex)); continue
            f = u32(uc, e.state[0] + FEET_OFF)
            print("APPLY value=%d -> feet[0]=%s (expect 2^(v-3)=%s)"
                  % (v, hex(f), exp))

    # ---- honest note on the real record->apply bridge for patch 62 ----
    print("\n=== patch-62 real-record path ===")
    print("The apply node consumes a VST3 param-id. Mapping a parsed record's")
    print("blob position to that param-id is exactly the leaf/descriptor table")
    print("(reconstruction) which is forbidden. The programmer container global")
    print("0x8B05B8 has NO rip-relative reader in .text, and the apply node is")
    print("reachable only via CWaveGen vtable slot 14 (VST3-host driven). No")
    print("plugin-internal record->paramid->apply function was located, so the")
    print("real patch-62 feet value is NOT settled by THIS vector (honest stall).")
    print("What IS proven: whether index 760 is even a routable map value (above).")

if __name__ == '__main__':
    main()
