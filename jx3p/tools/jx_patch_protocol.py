#!/usr/bin/env python3
"""jx_patch_protocol.py -- what the JX-3P's OWN patch load hands its engine (EXECUTED; Unicorn only,
two-process rule), against the recall model the JX port's data was made with (jx_emu.recall).

The plugin as a DAW runs it (jx3p/tools/jx_host_emu.py): boot, one process() block (initialize's 84
records applied), then per factory patch k its patch browser's load (rva 0x335730 = the JUNO's
0x335850, fw_map) of bank record k, and one more process() block of one host sample: the render
driver applies the queued records at offset 0 through the engine's host entry (rva 0x3F9A30), which
looks each id up in its map (rva 0xCE9038: model id -> dispatch id, filled by the first process()),
moves some values (dispatch 20 and 0x299/0x2C3: -100, 22: -12, 0x301: -128; READ), checks the
dispatch id's range (rva 0x3DD7E0) and calls every unit's dispatch (rva 0x3EBB00) with flag 0.
Recorded per patch: the queued records (model id, value) in queue order, and every dispatch call
(unit, dispatch id, flag, value) in call order, grouped by the record that made it.

The model (jx_emu.recall, the JX port's template / recall data): dispatch 740 + pool, the bank's
nibble pair at 2 pool - 8, for the 59 ACTIVE_POOLS in pool order, flag 1, every unit.

Writes scratchpad/jx/patch_protocol.pkl and prints, per patch, how the two differ: dispatch ids only
one side sends, values that differ, the order, the flag.

    python3 -u jx3p/tools/jx_patch_protocol.py [patch ...]      (default: all 64)
"""
import collections
import os
import pickle
import struct
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import jx_bank as B                                    # noqa: E402

ENTRY, DISPATCH = 0x3F9A30, 0x3EBB00
OUT = os.path.join(REPO, 'scratchpad', 'jx', 'patch_protocol.pkl')


def model_list(blob):
    return [(B.POOL_BASE_ID + p, B.pool_value(blob, p)) for p in B.ACTIVE_POOLS]


def main():
    import jx_host_emu as X
    from unicorn import UC_HOOK_CODE
    from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9
    patches = [int(a) for a in sys.argv[1:]] or list(range(64))
    bank = B.bank_bytes()
    t0 = time.time()
    h = X.JXHost()
    h.start(48000.0, 512)
    uc, ib = h.uc, X.J.IB
    log = []

    def on_entry(uc_, a, s, u):
        log.append([uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF, uc_.reg_read(UC_X86_REG_R8) & 0xFFFFFFFF, []])

    def on_disp(uc_, a, s, u):
        rec = (uc_.reg_read(UC_X86_REG_RCX), uc_.reg_read(UC_X86_REG_RDX) & 0xFFFFFFFF,
               uc_.reg_read(UC_X86_REG_R8) & 0xFF, uc_.reg_read(UC_X86_REG_R9) & 0xFFFFFFFF)
        (log[-1][2] if log else orphans).append(rec)
    orphans = []
    uc.hook_add(UC_HOOK_CODE, on_entry, begin=ib + ENTRY, end=ib + ENTRY)
    uc.hook_add(UC_HOOK_CODE, on_disp, begin=ib + DISPATCH, end=ib + DISPATCH)
    uc.ctl_remove_cache(ib, ib + X.J.IMGSZ)
    h.process(512)                                       # initialize's records
    boot = [list(e) for e in log]
    units = sorted({d[0] for e in boot for d in e[2]})
    res = {'units': units, 'boot': boot, 'loads': []}
    print('boot: %d entry calls, %d dispatches, %d units (%.0f s)' % (
        len(boot), sum(len(e[2]) for e in boot), len(units), time.time() - t0), flush=True)
    for k in patches:
        del log[:]
        tail = bank[B.BANK_HEADER + k * B.BANK_STRIDE + B.BANK_BLOB_OFF:B.BANK_HEADER + (k + 1) * B.BANK_STRIDE]
        q = h.load_patch(tail)
        recs = [(kind, off, struct.unpack_from('<I', r, 12)[0], struct.unpack_from('<i', r, 20)[0]) for kind, off, r in q]
        h.process(1)
        calls = [list(e) for e in log]
        res['loads'].append(dict(patch=k, records=recs, calls=calls))
        # the product's (dispatch, value) list: one per record, every unit equal (checked)
        prod, odd = [], 0
        for pid, val, ds in calls:
            per = collections.OrderedDict()
            for unit, did, flag, v in ds:
                per.setdefault((did, flag, v), set()).add(unit)
            for (did, flag, v), us in per.items():
                if us != set(units):
                    odd += 1
                prod.append((did, v, flag, pid, val))
        model = model_list(bank[B.BANK_HEADER + k * B.BANK_STRIDE + B.BANK_BLOB_OFF:])
        pm = {d: v for d, v, *_ in prod}
        mm = dict(model)
        only_p = sorted(set(pm) - set(mm))
        only_m = sorted(set(mm) - set(pm))
        diff = sorted(d for d in set(pm) & set(mm) if pm[d] != mm[d])
        order_p = [d for d, *_ in prod if d in mm]
        order_m = [d for d, _ in model if d in pm]
        flags = sorted({f for _, _, f, _, _ in prod})
        print('patch %2d: %3d records, %3d dispatch kinds; only product %d %s, only model %d %s, value differs %d %s, '
              'same order %s, product flags %s%s' % (
                  k, len(recs), len(prod), len(only_p), only_p[:6], len(only_m), only_m[:6], len(diff),
                  ['d%d %d/%d' % (d, pm[d], mm[d]) for d in diff[:5]], order_p == order_m, flags,
                  ', %d not on every unit' % odd if odd else ''), flush=True)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT + '.partial', 'wb') as fh:
        pickle.dump(res, fh)
    os.replace(OUT + '.partial', OUT)
    print('wrote %s (%.0f s)' % (os.path.relpath(OUT, REPO), time.time() - t0))


if __name__ == '__main__':
    main()
