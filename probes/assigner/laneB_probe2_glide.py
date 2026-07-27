#!/usr/bin/env python3
"""LANE B probe 2 — THE DECISIVE MEASUREMENT.

Two overlapping notes on Chillwave #4 'BS Glide' (PORTAMENTO 65, LEGATO 0,
ASSIGN MODE 2), delivered through the plugin's own note path, with the per-sample
pitch-CV trajectory of every rendered voice recorded.

Two modes, chosen by argv[1]:
  hostpath  — after recall, call the assigner notify the HOST param path calls:
              0x3549B0(assign[u], 4)  (rva 0x3C7AE0 loop, insn 0x3c7c9d).
              That refreshes assigner+16 (ASSIGN MODE) / +20 (LEGATO).
  gatepath  — do NOT call it (what e2e_emu / recall_render_ab / the port do today):
              the assigner keeps its power-on cache mode=0 (POLY), legato=0.

Cells tracked, per RENDERED voice v (unit v, voice v -> state[v] + v*10512 + off):
  +304  M.CV      note-CV target written by the assigner (param 433+v)
  +704  glide out portamento integrator output (voice_render 0x...: JF(704)=v56)
  +320  M.Gate    binary gate

Also hooks the assigner's own param forwarder 0x355AC0 (assigner vtbl+72 ->
proc setter) to log every (paramId, value) the allocator emits.

Oracle-only (Unicorn). Never loads libjuno.
"""
import sys, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import e2e_emu as E
import real_recall as R
import recall_render_ab as RRA
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RDX, UC_X86_REG_R8, UC_X86_REG_R9

import truth
CW = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
SR = 48000.0
MODE = sys.argv[1] if len(sys.argv) > 1 else 'hostpath'
PATCH = int(sys.argv[2]) if len(sys.argv) > 2 else 4
BANKSEL = sys.argv[3] if len(sys.argv) > 3 else 'chillwave'
TABLE = (len(sys.argv) > 4 and sys.argv[4] == 'table')
NOTE1, NOTE2, VEL = 60, 67, 105
STRIDE = 10512
IB = E.IB
NOTIFY = IB + 0x3549B0      # assigner vtbl+8  paramChanged(self, cat)
FWD    = IB + 0x355AC0      # assigner vtbl+72 -> proc setter(paramId, value)

BLK   = 48                  # 1 ms at 48 kHz
PRE   = 100                 # blocks rendered with note1 only  (100 ms)
POST  = 300                 # blocks rendered after note2      (300 ms)

bank = open(CW if BANKSEL == 'chillwave' else truth.BANK, 'rb').read()
leaves = R.leaf_table()
e = RRA.prepare_recall(PATCH, bank, leaves, E, R, SR)
uc = e.uc
def i32(a): return struct.unpack('<i', uc.mem_read(a, 4))[0]
def f32(a): return struct.unpack('<f', uc.mem_read(a, 4))[0]

nm_base = RRA.__dict__  # unused; keep import tidy
base = 23 + PATCH * 20223
pname = ''.join(chr(c) if 32 <= c < 127 else ' ' for c in bank[base:base+16]).strip()
print("patch %d %r   mode=%s  SR=%g  notes %d -> %d vel %d"
      % (PATCH, pname, MODE, SR, NOTE1, NOTE2, VEL))

if MODE == 'hostpath':
    for u in range(9):
        e.call(NOTIFY, rcx=e.assign[u], rdx=4)
print("assigner caches after %s: " % MODE
      + " ".join("u%d(mode=%d,leg=%d)" % (u, i32(e.assign[u] + 16), i32(e.assign[u] + 20))
                 for u in range(3)))

# ---- log the allocator's own param emissions -----------------------------
ev = []
tag = ['init']
def fwd_hook(u_, addr, size, user):
    this = u_.reg_read(UC_X86_REG_RCX)
    if this != e.assign[0]:      # unit 0 only, they are identical
        return
    ev.append((tag[0], u_.reg_read(UC_X86_REG_R8) & 0xffffffff,
               u_.reg_read(UC_X86_REG_R9) & 0xffffffff))
h = uc.hook_add(UC_HOOK_CODE, fwd_hook, begin=FWD, end=FWD)

def snap():
    return [(f32(e.state[v] + v*STRIDE + 304),
             f32(e.state[v] + v*STRIDE + 704),
             f32(e.state[v] + v*STRIDE + 320)) for v in range(8)]

tag[0] = 'note_on(%d)' % NOTE1
e.note_on(NOTE1, VEL)
print("\nassigner voice table after note1 (unit0 +96, note/gate/rel per voice):",
      list(uc.mem_read(e.assign[0] + 96, 24)))
print("after note1: CV/glide/gate per rendered voice:")
for v, (cv, gl, gt) in enumerate(snap()):
    print("   v%d  CV=%.6f  glide=%.6f  gate=%.1f" % (v, cv, gl, gt))

traj = []
for b in range(PRE):
    e.render(BLK, block=BLK)
    traj.append((b * BLK, snap()))

tag[0] = 'note_on(%d)' % NOTE2
e.note_on(NOTE2, VEL)
print("\nassigner voice table after note2:", list(uc.mem_read(e.assign[0] + 96, 24)))
print("after note2: CV/glide/gate per rendered voice:")
for v, (cv, gl, gt) in enumerate(snap()):
    print("   v%d  CV=%.6f  glide=%.6f  gate=%.1f" % (v, cv, gl, gt))
t0 = PRE * BLK
for b in range(POST):
    e.render(BLK, block=BLK)
    traj.append((t0 + b * BLK, snap()))
uc.hook_del(h)

print("\n=== allocator param emissions (unit 0, assigner vtbl+72 -> proc setter) ===")
for (t, pid, val) in ev:
    kind = ('NOTE CV 433+%d' % (pid - 433)) if 433 <= pid <= 440 else \
           ('GATE 450+%d' % (pid - 450)) if 450 <= pid <= 457 else \
           ('RESET 467+%d' % (pid - 467)) if 467 <= pid <= 474 else 'param %d' % pid
    print("   %-14s %-16s value=%d" % (t, kind, val))

print("\n=== per-voice pitch trajectory, ms after note2 (glide integrator @+704) ===")
print("ms      " + "  ".join("v%d_glide  v%d_CV " % (v, v) for v in range(8)))
for (smp, s) in (traj if TABLE else []):
    ms = (smp - t0) / 48.0
    if ms < -8 or ms > 300: continue
    if abs(ms - round(ms)) > 1e-6: continue
    if not (ms in (-2.0, -1.0) or (0 <= ms <= 40) or (ms <= 300 and ms % 10 == 0)):
        continue
    print("%7.1f " % ms + "  ".join("%9.6f %9.6f" % (s[v][1], s[v][0]) for v in range(8)))

# compact verdict numbers
def gl(v, ms):
    i = min(range(len(traj)), key=lambda k: abs((traj[k][0] - t0) / 48.0 - ms))
    return traj[i][1][v][1]
print("\n=== VERDICT DATA ===")
for v in range(8):
    pre = gl(v, -1.0); a0 = gl(v, 0.0); a5 = gl(v, 5.0); a50 = gl(v, 50.0); a300 = gl(v, 297.0)
    moved = abs(a300 - pre) > 1e-7
    ramp = moved and abs(a0 - pre) < 0.5 * abs(a300 - pre)
    print("  v%d  pre=%.6f  t0=%.6f  t5ms=%.6f  t50ms=%.6f  t297ms=%.6f  moved=%s  ramped=%s"
          % (v, pre, a0, a5, a50, a300, moved, ramp))
print("faults:", e.faults)
