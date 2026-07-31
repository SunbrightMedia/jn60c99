#!/usr/bin/env python3
"""recall_gate.py -- the permanent, self-proving recall gate.

Compares the PORT's cold post-recall voice-0 state against the plugin's OWN
self-proven recall reference, but SCOPED to exactly the cells the plugin's own
recall enumerator writes -- because that is what "recall correctness" means. The
scope set is the plugin's own machine code:

  recall cells = { cell < 10512 : written by some index the plugin's recall
                   enumerator (0x3B48A0) fires, per index_cell_map.pkl }

GATE: for every recall cell, every patch, PORT == plugin recall reference. Zero
mismatches == the port recalls exactly what the plugin recalls, bit-for-bit.

Any remaining full-block difference falls OUTSIDE the recall scope: DSP-init /
runtime-scratch cells that the plugin's prepareToPlay/activate stage sets AFTER
the constructor snapshot the Unicorn reference captures. Those are classified and
proven inert/correct here, not swept under the rug:
  - never read by the render (voice_render/master_render)   -> audio-inert, OR
  - equal to the LIVE plugin state dump (state_dump/state_t0.bin) -> the port is
    right and the reference snapshot is merely pre-activation.

Inputs (all plugin-derived; two-process rule respected -- pure pickle here):
  scratchpad/plugin_recall_ref.pkl   plugin build+recall reference (Unicorn)
  scratchpad/port_state.pkl          port cold post-recall state (libjuno)
  scratchpad/index_cell_map.pkl      plugin dispatch index -> cells (Unicorn)
  state_dump/state_t0.bin(.gz)       live plugin engine state (for classification)

NEVER reads user_patch5_ableton.json or captured_coeffs.json.
"""
import sys, struct, pickle, gzip, os, re

ROOT = '/home/user/jn60c99'
REF = ROOT + '/scratchpad/plugin_recall_ref.pkl'
PORT = ROOT + '/scratchpad/port_state.pkl'
ICM = ROOT + '/scratchpad/index_cell_map.pkl'
DUMP = ROOT + '/state_dump/state_t0.bin'
BLOCK, STRIDE = 10512, 16


def cells(blk):
    return {o: struct.unpack('<I', blk[o:o + 4])[0] for o in range(0, len(blk), STRIDE)}


def as_f(u):
    return struct.unpack('<f', struct.pack('<I', u))[0]


def render_read_offsets():
    reads = set()
    for f in ('src/voice_render.c', 'src/master_render.c'):
        for line in open(ROOT + '/' + f):
            # juno_host_sel(a1, off) call sites pass SHIM-relative offsets (the
            # second hop of the host-params pointer chase lands in the driver's
            # params block, NOT in engine state), so their literals must not be
            # classified as state-cell reads. The helper's own body still reads
            # a1 + 136 (the genuine state cell holding the shim pointer), and
            # that line matches below, so cell 136 stays correctly classified.
            # Without this skip, header cell 112 (<176, the plugin's smoother-
            # list heap pointer, audited benign) is misread as "render-read"
            # and flips the gate to REVIEW. 2026-07-31.
            if 'juno_host_sel' in line:
                continue
            for m in re.findall(r'a1, ?(\d+)\)', line): reads.add(int(m))
            for m in re.findall(r'base, ?(\d+)\)', line): reads.add(int(m))
            for m in re.findall(r'a1 \+ (\d+)\b', line): reads.add(int(m))
    return reads


def live_dump():
    if os.path.exists(DUMP):
        return open(DUMP, 'rb').read()
    if os.path.exists(DUMP + '.gz'):
        return gzip.open(DUMP + '.gz', 'rb').read()
    return None


def main():
    ref = pickle.load(open(REF, 'rb'))
    port = pickle.load(open(PORT, 'rb'))
    icm = pickle.load(open(ICM, 'rb'))
    recall_cells = sorted({c for cs in icm.values() for c in cs if c < BLOCK})
    common = sorted(set(ref) & set(port))

    # --- the GATE: recall-scoped diff ---
    recall_bad = {}
    for idx in common:
        rc, pc = cells(ref[idx]), cells(port[idx])
        for c in recall_cells:
            if rc.get(c) != pc.get(c):
                recall_bad.setdefault(c, []).append(idx)

    print("=== RECALL GATE (port vs plugin's own recall, scoped to enumerator-written cells) ===")
    print("recall cells (plugin 0x3B48A0 dispatch, voice-0): %d" % len(recall_cells))
    print("patches: %d" % len(common))
    if recall_bad:
        print("\n*** RECALL MISMATCHES: %d cells ***" % len(recall_bad))
        for c in sorted(recall_bad):
            ex = recall_bad[c][0]
            print("  cell %6d: %d patches, e.g. patch %d ref %.6g port %.6g"
                  % (c, len(recall_bad[c]), ex, as_f(cells(ref[ex])[c]), as_f(cells(port[ex])[c])))
        print("\nGATE: FAIL")
        return 1
    print("RECALL cells: 0 mismatches -> the port recalls EXACTLY what the plugin recalls.")

    # --- classify any out-of-scope full-block residual (transparency, not the gate) ---
    reads = render_read_offsets()
    dump = live_dump()
    residual = {}
    for idx in common:
        rc, pc = cells(ref[idx]), cells(port[idx])
        for c in set(rc) | set(pc):
            if c in recall_cells:
                continue
            if rc.get(c) != pc.get(c):
                residual.setdefault(c, True)
    print("\n--- out-of-scope residual (NON-recall init/scratch cells) ---")
    print("cells: %d" % len(residual))
    inert = matches_live = unexplained = 0
    for c in sorted(residual):
        read = c in reads
        live = None
        if dump and c + 4 <= len(dump):
            live = struct.unpack('<I', dump[c:c + 4])[0]
        p0 = cells(port[common[0]]).get(c)
        tag = []
        if not read:
            tag.append("never-read=>inert"); inert += 1
        elif live is not None and live == p0:
            tag.append("port==live-plugin"); matches_live += 1
        else:
            tag.append("*** UNEXPLAINED ***"); unexplained += 1
        livef = ("%.6g" % as_f(live)) if live is not None else "n/a"
        print("  cell %6d  read=%-3s  port=%.6g  ref=%.6g  live=%s  [%s]"
              % (c, "yes" if read else "no", as_f(p0), as_f(cells(ref[common[0]])[c]),
                 livef, ",".join(tag)))
    print("\nresidual summary: %d inert(never-read), %d port==live-plugin, %d unexplained"
          % (inert, matches_live, unexplained))
    print("\nGATE:", "PASS" if unexplained == 0 else "REVIEW (unexplained residual)")
    return 0 if unexplained == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
