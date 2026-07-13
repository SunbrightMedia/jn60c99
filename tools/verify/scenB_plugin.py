#!/usr/bin/env python3
"""Scenario B (note lifecycle) — PLUGIN side under Unicorn.
Canonical cold sequence: build -> snap_all -> recall -> snap_all -> clear_latch
-> set_ftz, then the lifecycle event script. Dumps L then R uint32 streams.
Usage: scenB_plugin.py <patch> <outfile>
"""
import sys, struct, time
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E

patch = int(sys.argv[1]); out = sys.argv[2]
SR = 48000

t0 = time.time()
e = E.E2E(); e.build(SR)
print("build done %.1fs" % (time.time()-t0), flush=True)
e.snap_all()
leaves = E.load_leaves(); bank = E.bank_bytes()
errs = E.recall_patch(e, patch, leaves, bank)
e.snap_all(); e.clear_latch(); e.set_ftz()
print("recall done (errs=%d, name=%r) %.1fs" % (errs, E.patch_name(bank, patch), time.time()-t0), flush=True)

L = []; R = []
def seg(n):
    l, r = e.render(n)
    L.extend(l); R.extend(r)
    print("rendered seg n=%d total=%d t=%.1fs" % (n, len(L), time.time()-t0), flush=True)

e.note_on(60, 105); seg(6000)      # frames 0..5999
e.note_off(60);     seg(24000)     # frames 6000..29999 (tail)
e.note_on(60, 105); seg(6000)      # frames 30000..35999 (retrigger)
e.note_off(60);     seg(3000)      # frames 36000..38999
e.note_on(60, 40);  seg(6000)      # frames 39000..44999 (soft vel)

with open(out, 'wb') as f:
    f.write(struct.pack("<%dI" % len(L), *L))
    f.write(struct.pack("<%dI" % len(R), *R))
print("DONE frames=%d errs=%d elapsed=%.1fs" % (len(L), errs, time.time()-t0), flush=True)
