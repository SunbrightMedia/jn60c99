#!/usr/bin/env python3
"""LANE C — MASTER call ABI + the per-sample 16-entry pointer array.

Proves, by EXECUTING the plugin's own per-block render sub_7FF91E027400
(rva 0x3C7400) under Unicorn, that:
  (a) the 16 per-voice buffer vectors live at ENGINE+656 stride 24, paired
      (main,sub) per voice in voice order 0..7 -> voice i main = ENGINE+656+48*i,
      voice i sub = ENGINE+680+48*i; the render loop stores their begin pointers
      into work item i at +32 / +40 (item base ENGINE+1152+128*i);
  (b) the master's per-sample 16-entry pointer array is
        arr[2i]   = *(ENGINE+656+48*i) + 4*s   (voice i MAIN)
        arr[2i+1] = *(ENGINE+680+48*i) + 4*s   (voice i SUB)
      i.e. even slots = voice main, odd slots = voice sub, voice order 0..7;
  (c) MASTER_WRAP(0x398EC0) -> 0x363380 reads ONLY the even slots and stores
      arr[2i][0] into masterState + 10672 + 10512*i;
  (d) e2e_emu.build_master_stub (pre-built a2[16], all 16 advanced by 4 per
      sample, outL/outR advanced by 4 per sample) is BIT-EXACT to the plugin's
      own master loop for the same inputs and the same master state.

The thread pool is NEVER engaged: the barrier counter at ENGINE+1072 is
pre-satisfied so 0x3C7400 never enters its condvar wait, and the work items'
render commands go to a pool that has no workers under emulation -> the voice
buffers keep exactly what we put in them, so the master input is controlled.
"""
import os, struct, sys, hashlib
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', 'tools', 'verify'))
import e2e_emu as E
import real_recall as R
import recall_render_ab as RA
from unicorn import UC_PROT_ALL
from unicorn.x86_const import *

RENDER_BLOCK = E.IB + 0x3C7400
SR = 48000.0
B = int(os.environ.get('LANEC_B', '64'))    # block size (samples)
AMP = float(os.environ.get('LANEC_AMP', '0.001'))  # kept in the master's LINEAR region
                                                   # (amp>=1 saturates the output clipper
                                                   #  at 0x3ffd839c and hides ordering)
PATCH = int(os.environ.get('LANEC_PATCH', '2'))

SCRATCH_BASE = 0x800000000
SCRATCH_SIZE = 0x100000


def call6(e, fn, a1, a2, a3, a4, a5, a6):
    """__fastcall with 6 args: rcx,rdx,r8,r9 + [rsp+0x28],[rsp+0x30]."""
    uc = e.uc
    rsp = (E.STACK_BASE + E.STACK_SIZE - 0x10000) & ~0xF
    rsp -= 8
    uc.reg_write(UC_X86_REG_RSP, rsp)
    uc.reg_write(UC_X86_REG_RCX, a1 & (2**64-1))
    uc.reg_write(UC_X86_REG_RDX, a2 & (2**64-1))
    uc.reg_write(UC_X86_REG_R8,  a3 & (2**64-1))
    uc.reg_write(UC_X86_REG_R9,  a4 & (2**64-1))
    RET = E.SCRATCH + 0x5000
    uc.mem_write(rsp, struct.pack("<Q", RET))
    uc.mem_write(rsp + 0x28, struct.pack("<I", a5 & 0xFFFFFFFF) + b"\0\0\0\0")
    uc.mem_write(rsp + 0x30, struct.pack("<I", a6 & 0xFFFFFFFF) + b"\0\0\0\0")
    uc.emu_start(fn, RET, count=0)
    rip = uc.reg_read(UC_X86_REG_RIP)
    if rip != RET:
        raise RuntimeError("call6 stopped at rva 0x%x" % (rip - E.IB))
    return uc.reg_read(UC_X86_REG_RAX)


def q(uc, a):
    return int.from_bytes(uc.mem_read(a, 8), 'little')


def d(uc, a):
    return struct.unpack("<i", uc.mem_read(a, 4))[0]


def f32(x):
    return struct.unpack("<f", struct.pack("<f", x))[0]


def main():
    bank = E.bank_bytes()
    leaves = R.leaf_table()
    print("building + running the plugin's OWN complete recall for patch %d (%s) @ %g Hz"
          % (PATCH, E.patch_name(bank, PATCH), SR))
    e = RA.prepare_recall(PATCH, bank, leaves, E, R, SR)
    uc = e.uc
    H = e.HOST
    uc.mem_map(SCRATCH_BASE, SCRATCH_SIZE, UC_PROT_ALL)
    uc.mem_write(SCRATCH_BASE, b"\0" * SCRATCH_SIZE)

    print("\n=== STRUCTURAL ===")
    print("ENGINE(a1) = 0x%x" % H)
    print("*(ENGINE+56)   voiceCount   = %d" % d(uc, H + 56))
    print("*(ENGINE+1072) doneCounter  = %d" % d(uc, H + 1072))
    print("*(ENGINE+592)  masterState  = 0x%x   (e2e state[8] = 0x%x)  MATCH=%s"
          % (q(uc, H + 592), e.state[8], q(uc, H + 592) == e.state[8]))
    assert all(q(uc, H + 80 + 64*i) == e.state[i] for i in range(9))
    print("state[i]  @ ENGINE+80+64i : CONFIRMED i=0..8")
    assert all(q(uc, H + 104 + 64*i) == e.assign[i] for i in range(9))
    print("assign[i] @ ENGINE+104+64i: CONFIRMED i=0..8")

    print("\n-- work item +24 (unit state ptr) vs e2e state[i]  (item = ENGINE+1152+128*i) --")
    for i in range(8):
        it = H + 1152 + 128*i
        v = q(uc, it + 24)
        print("  item%d @0x%x  +8=0x%-11x(ENGINE) +16=0x%-11x(ENGINE+1072) +24=0x%-11x state[%d]=0x%-11x %s"
              % (i, it, q(uc, it + 8), q(uc, it + 16), v, i, e.state[i],
                 "OK" if v == e.state[i] else "MISMATCH"))

    outL = SCRATCH_BASE + 0x1000
    outR = SCRATCH_BASE + 0x2000
    a4 = SCRATCH_BASE
    uc.mem_write(a4, struct.pack("<QQ", outL, outR))

    # The harness's ENGINE block is bump-allocated + zeroed and only BUILD (0x3C68D0)
    # runs; the CWaveGen CONSTRUCTOR 0x3C5A50 -- which is what sets *(a1+56) = 8 --
    # is never called, so voiceCount reads 0 and 0x3C7400 would take its
    # "i >= voiceCount -> ZERO the buffers, do not render" arm for all 8 voices.
    # Restore the constructor's own literal so the real RENDER arm is exercised.
    print("\nvoiceCount as built = %d ; forcing to 8 (ctor 0x3C5A50 literal, READ)"
          % d(uc, H + 56))
    uc.mem_write(H + 56, struct.pack("<i", 8))
    vc = 8

    # ---- CALL 1: resizes/allocates the 16 per-voice vectors, fills the work items
    uc.mem_write(H + 1072, struct.pack("<i", vc))
    call6(e, RENDER_BLOCK, H, 0, 0, a4, 0, B)
    print("call#1 of 0x3C7400 (block=%d) OK; faults=%d" % (B, e.faults))

    print("\n-- TABLE: ENGINE+656+48i / ENGINE+680+48i  vs  work-item +32 / +40 --")
    print("  i | main vec@      begin         | sub vec@       begin         |"
          " item+32       item+40       |m s bs")
    rows = []
    all_ok = True
    for i in range(8):
        vm_addr = H + 656 + 48*i
        vs_addr = H + 680 + 48*i
        pm, ps = q(uc, vm_addr), q(uc, vs_addr)
        it = H + 1152 + 128*i
        i32, i40, bs = q(uc, it + 32), q(uc, it + 40), d(uc, it + 48)
        mok, sok = (pm == i32), (ps == i40)
        all_ok &= mok and sok and (bs == B)
        rows.append((i, vm_addr, pm, vs_addr, ps, i32, i40, bs))
        print("  %d | 0x%09x 0x%09x | 0x%09x 0x%09x | 0x%09x 0x%09x |%d %d %d"
              % (i, vm_addr, pm, vs_addr, ps, i32, i40, int(mok), int(sok), bs))
    print("POINTER IDENTITY + ORDER: %s ; 16 distinct buffers: %s"
          % ("ALL OK" if all_ok else "*** MISMATCH ***",
             len(set([r[2] for r in rows] + [r[4] for r in rows])) == 16))

    MS = e.state[8]
    S0 = bytes(uc.mem_read(MS, E.STATE_SZ))
    print("master state snapshot %d bytes sha=%s"
          % (len(S0), hashlib.sha256(S0).hexdigest()[:16]))

    def sentinel(slot, s, amp):
        return amp * ((slot + 1) * 0.0117 + s * 0.00031)

    def fill(amp, order=None, swap=False):
        """order: list of 8 voice indices used for the EVEN slots; swap: main<->sub."""
        for i in range(8):
            pm, ps = rows[i][2], rows[i][4]
            uc.mem_write(pm, struct.pack("<%df" % B, *[sentinel(2*i, s, amp) for s in range(B)]))
            uc.mem_write(ps, struct.pack("<%df" % B, *[sentinel(2*i+1, s, amp) for s in range(B)]))

    def plugin_run(amp):
        uc.mem_write(MS, S0)
        fill(amp)
        uc.mem_write(outL, b"\0" * (4*B)); uc.mem_write(outR, b"\0" * (4*B))
        uc.mem_write(H + 1072, struct.pack("<i", vc))
        call6(e, RENDER_BLOCK, H, 0, 0, a4, 0, B)
        L = list(struct.unpack("<%dI" % B, uc.mem_read(outL, 4*B)))
        Rr = list(struct.unpack("<%dI" % B, uc.mem_read(outR, 4*B)))
        cells = [struct.unpack("<f", uc.mem_read(MS + 10672 + 10512*i, 4))[0] for i in range(8)]
        return L, Rr, cells

    def oracle_run(a2bytes, amp):
        uc.mem_write(MS, S0)
        fill(amp)
        uc.mem_write(outL, b"\0" * (4*B)); uc.mem_write(outR, b"\0" * (4*B))
        uc.mem_write(E.PB_MASTER,
                     struct.pack("<QQQQ", MS, outL, outR, B) + b"\0"*16 + a2bytes)
        e._run(e.SMASTER)
        L = list(struct.unpack("<%dI" % B, uc.mem_read(outL, 4*B)))
        Rr = list(struct.unpack("<%dI" % B, uc.mem_read(outR, 4*B)))
        cells = [struct.unpack("<f", uc.mem_read(MS + 10672 + 10512*i, 4))[0] for i in range(8)]
        return L, Rr, cells

    pL, pR, pcells = plugin_run(AMP)

    print("\n=== (c) masterState+10672+10512*i after the plugin master loop (last sample s=%d) ==="
          % (B-1))
    map_ok = True
    for i in range(8):
        wmain, wsub = f32(sentinel(2*i, B-1, AMP)), f32(sentinel(2*i+1, B-1, AMP))
        got = pcells[i]
        tag = ("MAIN(voice %d)" % i) if got == wmain else \
              ("SUB(voice %d)" % i) if got == wsub else "?? UNKNOWN"
        map_ok &= (got == wmain)
        print("  cell[%d] @+%-6d = %.9g  main=%.9g sub=%.9g -> %s"
              % (i, 10672 + 10512*i, got, wmain, wsub, tag))
    print("EVEN SLOT == VOICE MAIN, VOICE ORDER 0..7 : %s"
          % ("CONFIRMED" if map_ok else "*** DIVERGENCE ***"))

    # sensitivity control: a different input must give a different output
    zL, zR, _ = plugin_run(0.0)
    hL, hR, _ = plugin_run(AMP*7.0)
    print("\nINPUT SENSITIVITY of the plugin master loop:")
    print("  amp=0        L[0..3] = %s" % [hex(x) for x in zL[:4]])
    print("  amp=%-8g L[0..3] = %s" % (AMP, [hex(x) for x in pL[:4]]))
    print("  amp=%-8g L[0..3] = %s" % (AMP*7, [hex(x) for x in hL[:4]]))
    print("  amp0 != amp : %s   amp != 7*amp : %s   varies over s : %s"
          % (zL != pL, pL != hL, len(set(pL)) > 1))

    a2_ref = b"".join(struct.pack("<Q", x) for pair in
                      ((rows[v][2], rows[v][4]) for v in range(8)) for x in pair)
    oL, oR, ocells = oracle_run(a2_ref, AMP)

    print("\n=== (d) BIT COMPARE  plugin 0x3C7400 master loop  vs  e2e_emu build_master_stub ===")
    print("  s |  plugin L    oracle L  |  plugin R    oracle R")
    nbad = 0
    for s in range(B):
        bad = (pL[s] != oL[s]) or (pR[s] != oR[s])
        nbad += bad
        if s < 8 or bad:
            print("  %d | 0x%08x 0x%08x | 0x%08x 0x%08x %s"
                  % (s, pL[s], oL[s], pR[s], oR[s], "<<< DIFF" if bad else ""))
    print("per-voice input cells equal: %s" % (pcells == ocells))
    print("BIT-EXACT: %s   (%d/%d samples differ)" % (nbad == 0, nbad, B))

    print("\n=== NEGATIVE CONTROLS (must all DIFFER, else the test is blind) ===")
    a2_swap = b"".join(struct.pack("<Q", x) for pair in
                       ((rows[v][4], rows[v][2]) for v in range(8)) for x in pair)
    sL, _, scells = oracle_run(a2_swap, AMP)
    print("  main<->sub swapped     : L differs in %d/%d, cells differ: %s"
          % (sum(1 for s in range(B) if sL[s] != pL[s]), B, scells != pcells))
    a2_rev = b"".join(struct.pack("<Q", x) for pair in
                      ((rows[v][2], rows[v][4]) for v in range(7, -1, -1)) for x in pair)
    rL, _, rcells = oracle_run(a2_rev, AMP)
    print("  voice order reversed   : L differs in %d/%d, cells differ: %s"
          % (sum(1 for s in range(B) if rL[s] != pL[s]), B, rcells != pcells))
    # out advance: freeze the oracle's out pointers (no +4 per sample) is not
    # expressible through the stub, so instead shift the input phase by one sample
    a2_off = b"".join(struct.pack("<Q", x + 4) for pair in
                      ((rows[v][2], rows[v][4]) for v in range(8)) for x in pair)
    fL, _, fcells = oracle_run(a2_off, AMP)
    print("  a2 pre-advanced by 1 s : L differs in %d/%d, cells differ: %s"
          % (sum(1 for s in range(B) if fL[s] != pL[s]), B, fcells != pcells))
    # cross-MIX-GROUP permutation (0<->2): the mixer sums voice PAIRS
    # (0,1)*g0 (2,3)*g1 (4,5)*g2 (6,7)*g3, so a pair-symmetric permutation such as
    # a full reversal can cancel at the output; 0<->2 moves a voice between groups.
    perm = [2, 1, 0, 3, 4, 5, 6, 7]
    a2_p = b"".join(struct.pack("<Q", x) for pair in
                    ((rows[v][2], rows[v][4]) for v in perm) for x in pair)
    xL, _, xcells = oracle_run(a2_p, AMP)
    print("  voices 0<->2 swapped   : L differs in %d/%d, cells differ: %s"
          % (sum(1 for s in range(B) if xL[s] != pL[s]), B, xcells != pcells))

    # ---- (c2) are the ODD slots (voice SUB buffers) read at all by the master?
    uc.mem_write(MS, S0)
    fill(AMP)
    for i in range(8):
        uc.mem_write(rows[i][4], struct.pack("<%df" % B, *([1e20] * B)))
    uc.mem_write(outL, b"\0" * (4*B)); uc.mem_write(outR, b"\0" * (4*B))
    uc.mem_write(H + 1072, struct.pack("<i", vc))
    call6(e, RENDER_BLOCK, H, 0, 0, a4, 0, B)
    gL = list(struct.unpack("<%dI" % B, uc.mem_read(outL, 4*B)))
    gR = list(struct.unpack("<%dI" % B, uc.mem_read(outR, 4*B)))
    print("\nODD-SLOT (voice SUB buffer) INFLUENCE: odd slots set to 1e20 ->"
          " L identical: %s  R identical: %s" % (gL == pL, gR == pR))

    print("\nmaster mix gains read from masterState (0x363380 operands):")
    for off in (84448, 84464, 84480, 84496, 84512):
        print("   +%-6d = %.9g" % (off, struct.unpack("<f", uc.mem_read(MS + off, 4))[0]))

    print("\nfaults=%d unhandled=%s" % (e.faults, dict(e.unhandled)))


if __name__ == "__main__":
    main()
