#!/usr/bin/env python3
"""Scenario C plugin side: cold chord + voice steal on patch 0, Unicorn oracle.
Canonical cold sequence: build -> snap_all -> recall -> snap_all -> clear_latch
-> set_ftz -> events. Caches (L,R) bit streams + segment map to pickle."""
import sys, struct, pickle, time
sys.path.insert(0, '/home/user/jn60c99/scratchpad/oracle')
import e2e_emu as E

OUT = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad/scenC_plugin.pkl'

t0 = time.time()
e = E.E2E(); e.build(48000)
e.snap_all()
leaves = E.load_leaves(); bank = E.bank_bytes()
errs = E.recall_patch(e, 0, leaves, bank)
e.snap_all(); e.clear_latch(); e.set_ftz()
print("recall errs=%d  patch0 name=%r  t=%.1fs" % (errs, E.patch_name(bank, 0), time.time()-t0), flush=True)

L = []; R = []
segments = []  # (label, start_frame, end_frame)

def rend(n, label):
    s = len(L)
    l, r = e.render(n)
    L.extend(l); R.extend(r)
    segments.append((label, s, len(L)))
    print("rendered %-28s frames %d..%d  t=%.1fs" % (label, s, len(L), time.time()-t0), flush=True)

# (1) chord
e.note_on(60, 100); e.note_on(64, 100); e.note_on(67, 100)
rend(6000, "after chord 60,64,67")

# (2) add notes one at a time
for nt in (48, 50, 52, 53, 55, 57):
    e.note_on(nt, 100)
    rend(500, "after note_on %d" % nt)

# (3) tail
rend(6000, "final tail")

with open(OUT, 'wb') as f:
    pickle.dump(dict(L=L, R=R, segments=segments, errs=errs), f)
print("saved %d frames to %s  total t=%.1fs" % (len(L), OUT, time.time()-t0), flush=True)
