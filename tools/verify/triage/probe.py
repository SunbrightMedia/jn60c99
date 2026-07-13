#!/usr/bin/env python3
"""probe.py — dual-side census + state microscope at the introducing event.

usage: probe.py <seed> <k_intro> <render_window> [master_from_rel]

Runs both sides through ev[:k_intro] (proven-clean prefix), snapshots state,
applies event k_intro on both sides, reports every NEW diverging state cell
(baseline-masked), plus a dual-side voice census before/after the event.
Then renders sample-by-sample for render_window samples, reporting the first
new voice-cell diff and the first audio diff (master range checked each sample
from master_from_rel onward).
"""
import sys, struct
import numpy as np
from ft3 import PluginRun, PortRun, gen_script, STRIDE, AUX0, f32

S = STRIDE

def snap_all(side):
    """dict region -> bytes"""
    d = {}
    for v in range(8):
        blk, aux = side.snap_voice_block(v)
        d[f'voice{v}'] = blk
        d[f'aux{v}'] = aux
    d['master'] = side.snap_master(84448, 0xA83010)
    d['head'] = side.snap_head()
    return d

# extend runners with exact-block snapshots
def _plug_voice_block(self, v):
    e = self.e
    blk = bytes(e.uc.mem_read(e.state[v] + v*S + 176, S))
    aux = bytes(e.uc.mem_read(e.state[v] + AUX0 + 32*v, 32))
    return blk, aux
def _plug_head(self):
    return bytes(self.e.uc.mem_read(self.e.state[8], 176))
def _port_voice_block(self, v):
    import ctypes
    blk = ctypes.string_at(self.stp + v*S + 176, S)
    aux = ctypes.string_at(self.stp + AUX0 + 32*v, 32)
    return blk, aux
def _port_head(self):
    import ctypes
    return ctypes.string_at(self.stp, 176)
PluginRun.snap_voice_block = _plug_voice_block
PluginRun.snap_head = _plug_head
PortRun.snap_voice_block = _port_voice_block
PortRun.snap_head = _port_head

def diff_mask(a, b):
    ua = np.frombuffer(a, dtype=np.uint32); ub = np.frombuffer(b, dtype=np.uint32)
    return np.nonzero(ua != ub)[0]

def region_base(name):
    if name.startswith('voice'): return int(name[5:])*S + 176
    if name.startswith('aux'):   return AUX0 + 32*int(name[3:])
    if name == 'master':         return 84448
    return 0

def report_new_diffs(plug, port, baseline, tag, limit=16):
    out = []
    for reg in plug:
        base = region_base(reg)
        idx = diff_mask(plug[reg], port[reg])
        new = sorted(set(idx.tolist()) - baseline[reg])
        if not new: continue
        ua = np.frombuffer(plug[reg], dtype=np.uint32)
        ub = np.frombuffer(port[reg], dtype=np.uint32)
        for i in new[:limit]:
            off = base + 4*i
            out.append(f"  [{tag}] {reg} off {off} (voice-rel {off % S if reg.startswith('voice') else '-'}): "
                       f"plug {ua[i]:08x} ({f32(ua[i]):.9g})  port {ub[i]:08x} ({f32(ub[i]):.9g})")
        if len(new) > limit:
            out.append(f"  [{tag}] {reg}: ... {len(new)-limit} more new diffs")
    return out

def census_str(c):
    lines = [f"    {c['side']} mode={c.get('mode','-')} lru={c.get('lru','-')}"]
    sounding = 0
    for v, w in enumerate(c['voices']):
        audible = any(abs(x) > 1e-7 for x in w['envs'])
        snd = (w['gate'] or (w.get('gate_cell',0) or 0) > 0) or audible
        if snd: sounding += 1
        lines.append(f"      v{v}: note={w['note']:4} gate={w['gate']:3} rel={w['rel']} "
                     f"gate_cell={w['gate_cell']:.3g} mcv={w['mcv']:.6g} latch={w['latch']:.1f} "
                     f"envs=[{', '.join('%.6g'%x for x in w['envs'])}] {'SOUNDING' if snd else ''}")
    lines.append(f"    -> sounding voices: {sounding}")
    return "\n".join(lines)

def main():
    seed, k, win = int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3])
    master_from = int(sys.argv[4]) if len(sys.argv) > 4 else 0
    rate, patch, ev, _ = gen_script(seed)
    print(f"seed {seed} rate={rate} patch={patch}; introducing event [{k}] = {ev[k]}", flush=True)
    P = PluginRun(rate, patch); Q = PortRun(rate, patch)
    for x in ev[:k]:
        P.do(x); Q.do(x)
    print("== census BEFORE event ==")
    print(census_str(P.census())); print(census_str(Q.census()))
    plug0, port0 = snap_all(P), snap_all(Q)
    baseline = {r: set(diff_mask(plug0[r], port0[r]).tolist()) for r in plug0}
    print("baseline pre-event diffs per region:",
          {r: len(baseline[r]) for r in baseline if baseline[r]}, flush=True)
    # apply the introducing event on both sides
    P.do(ev[k]); Q.do(ev[k])
    print("== census AFTER event ==")
    print(census_str(P.census())); print(census_str(Q.census()))
    plug1, port1 = snap_all(P), snap_all(Q)
    lines = report_new_diffs(plug1, port1, baseline, "post-event")
    print("== NEW state diffs immediately after the introducing event ==")
    print("\n".join(lines) if lines else "  (none — states still bit-identical)", flush=True)
    # what did the event itself write on each side? (self-vs-self before/after)
    for nm, s0, s1 in (("plugin", plug0, plug1), ("port", port0, port1)):
        w = []
        for reg in s0:
            base = region_base(reg)
            idx = diff_mask(s0[reg], s1[reg])
            u0 = np.frombuffer(s0[reg], dtype=np.uint32); u1 = np.frombuffer(s1[reg], dtype=np.uint32)
            for i in idx.tolist()[:40]:
                w.append(f"    {nm} wrote {reg} off {base+4*i} "
                         f"(rel {(base+4*i) % S if reg.startswith('voice') else '-'}): "
                         f"{u0[i]:08x} ({f32(u0[i]):.9g}) -> {u1[i]:08x} ({f32(u1[i]):.9g})")
        print(f"== cells written by the event on {nm}: {len(w)}")
        print("\n".join(w[:60]), flush=True)
    # sample-by-sample render microscope
    print(f"== per-sample microscope ({win} samples) ==", flush=True)
    audio_div = None
    for s in range(win):
        P.do(('render', 1), block=1); Q.do(('render', 1))
        i = len(P.L) - 1
        adiff = (P.L[i] != Q.L[i]) or (P.R[i] != Q.R[i])
        pv, qv = {}, {}
        for v in range(8):
            b, a = P.snap_voice_block(v); pv[f'voice{v}'], pv[f'aux{v}'] = b, a
            b, a = Q.snap_voice_block(v); qv[f'voice{v}'], qv[f'aux{v}'] = b, a
        if s >= master_from:
            pv['master'] = P.snap_master(84448, 0xA83010)
            qv['master'] = Q.snap_master(84448, 0xA83010)
        lines = report_new_diffs(pv, qv, baseline, f"rel+{s+1}", limit=8)
        if lines:
            print(f"  --- sample rel+{s+1}: FIRST new state diffs ---")
            print("\n".join(lines), flush=True)
            for reg in pv: baseline[reg] = baseline.get(reg, set()) | set(diff_mask(pv[reg], qv[reg]).tolist())
        if adiff and audio_div is None:
            audio_div = s + 1
            print(f"  --- sample rel+{s+1}: AUDIO DIVERGES "
                  f"plugL={P.L[i]:08x} portL={Q.L[i]:08x} plugR={P.R[i]:08x} portR={Q.R[i]:08x}", flush=True)
            if s + 8 < win: win = s + 8   # a few samples beyond, then stop
    print(f"done. audio_div_rel={audio_div}")
    Q.close()

if __name__ == '__main__':
    main()
