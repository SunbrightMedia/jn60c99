"""Oracle-only census (CLAIMS B14): what the engine's tempo entry (CWaveGen vt+176, rva 0x3C7F10:
leaf 375, flag 0, value T = tempo x 10, every unit) writes on unit 0 -- every ramped set (cell,
time index, value), immediate set and direct write (as probes/host/host_census_mt.py logs host
edits), and every curve lookup -- after the plugin's recall of a patch, for several T. Then the
same patch's recall WITH the tempo already stored, to see which recalled cells read it.

    python3 probes/host_render/tempo_census.py [patch ...]      (Unicorn only)"""
import os
import struct
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import e2e_emu as E                      # noqa: E402
import real_recall as R                  # noqa: E402
import recall_render_ab as RR            # noqa: E402
from unicorn import UC_HOOK_CODE, UC_HOOK_MEM_WRITE           # noqa: E402
from unicorn.x86_const import (UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8,   # noqa: E402
                               UC_X86_REG_RIP, UC_X86_REG_XMM2, UC_X86_REG_XMM3)

TEMPO, POPULATE = E.IB + 0x3C7F10, E.IB + 0xAD5A0
WRAP, IMM, CURVE = 0x3C2920, 0x3C2750, 0x356380
f32 = lambda b: struct.unpack('<f', struct.pack('<I', b))[0]


def main():
    patches = [int(a) for a in sys.argv[1:] if a.isdigit()] or [9, 1, 33, 41]
    bank = E.bank_bytes()
    if '--types' in sys.argv:
        # patch 9's record with DELAY TYPE (record 650/651) 0..5 and TEMPO SYNC (blob 59) off/on
        base = bytearray(bank[E.HEADER + 9 * E.STRIDE: E.HEADER + 10 * E.STRIDE])
        recs = []
        for dt in range(6):
            for sy in (0, 1):
                r = bytearray(base)
                r[650], r[651] = (dt >> 4) & 0xF, dt & 0xF
                r[16 + 2 * 59], r[16 + 2 * 59 + 1] = (sy >> 4) & 0xF, sy & 0xF
                recs.append(bytes(r))
        bank = bytes(bank[:E.HEADER]) + b''.join(recs)
        patches = list(range(len(recs)))
    lt = R.leaf_table()
    e = E.E2E()
    ev, cv, cur = [], [], {'on': False}

    def hook(uc_, addr, size, ud):
        if not cur['on'] or uc_.reg_read(UC_X86_REG_RCX) != e.state[0]:
            return
        rva = addr - E.IB
        di = uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF
        desc = int.from_bytes(uc_.mem_read(e.state[0] + 0x38, 8), 'little') + 40 * di
        cell = int.from_bytes(uc_.mem_read(desc + 0x20, 8), 'little') - e.state[0]
        if rva == WRAP:
            typ = int.from_bytes(uc_.mem_read(desc + 0xC, 4), 'little')
            ev.append(('R' if typ == 1 else 'N', cell, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF,
                       uc_.reg_read(UC_X86_REG_XMM3) & 0xFFFFFFFF))
        else:
            ev.append(('I', cell, None, uc_.reg_read(UC_X86_REG_XMM2) & 0xFFFFFFFF))

    def chook(uc_, addr, size, ud):
        if cur['on']:
            cv.append((uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF))

    def whook(uc_, access, addr, size, value, ud):
        if cur['on'] and uc_.reg_read(UC_X86_REG_RIP) - E.IB != 0x3C2763:
            ev.append(('W', addr - e.state[0], size, value))
    e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + WRAP, end=E.IB + WRAP)
    e.uc.hook_add(UC_HOOK_CODE, hook, begin=E.IB + IMM, end=E.IB + IMM)
    e.uc.hook_add(UC_HOOK_CODE, chook, begin=E.IB + CURVE, end=E.IB + CURVE)
    e.build(48000.0)
    e.snap_all()
    e.call(POPULATE, count=200_000_000)
    e.uc.hook_add(UC_HOOK_MEM_WRITE, whook, begin=e.state[0] + 176, end=e.state[0] + E.STATE_SZ - 1)
    for p in patches:
        blob = E.patch_blob(bank, p)
        print('=== patch %d %s: TEMPO SYNC %d, DELAY TIME %d, LFO RATE %d, DELAY TYPE (rec 650) %d' % (
            p, E.patch_name(bank, p), E.dec(blob, 2 * 59), E.dec(blob, 2 * 53), E.dec(blob, 2 * 8),
            ((bank[E.HEADER + p * E.STRIDE + 650] & 0xF) << 4) | (bank[E.HEADER + p * E.STRIDE + 651] & 0xF)))
        RR.apply_recall(e, p, bank, lt, E, R)
        for T in ((1280, 973, 1285) if '--types' in sys.argv else (1280, 1200, 973, 1285, 3000, 400)):
            del ev[:]
            del cv[:]
            cur['on'] = True
            e.call(TEMPO, rcx=e.HOST, rdx=T, count=60_000_000)
            cur['on'] = False
            sets = [('%s %d t%s %s' % (k, c, t, ('%.7g' % f32(v)) if k != 'W' else '%d:%x' % (t, v))) for k, c, t, v in ev
                    if not (k == 'W' and c in (4448, 4456))]
            print('  T=%4d: %d sets/writes, curves %s' % (T, len(sets), sorted(set(cv))[:8]))
            for s_ in sets[:24]:
                print('      ' + s_)
        e.call(TEMPO, rcx=e.HOST, rdx=1280, count=60_000_000)
        e.snap_all()


if __name__ == '__main__':
    main()
