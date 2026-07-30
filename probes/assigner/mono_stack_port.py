#!/usr/bin/env python3
"""mono_stack_port.py — PORT side of the seed-15 MONO divergence probe.

Replays the exact event list from mono_stack_ref.py through libjuno and diffs the
allocator's decisions (per-voice pitch CV + gate) against the plugin's, so a
mismatch names the voice and the event instead of just "audio differs".

TWO-PROCESS RULE: loads libjuno; never imports e2e_emu.
"""
import sys, os, pickle, struct, ctypes

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import truth

PKL = os.path.join(REPO, "scratchpad", "mono_stack_ref.pkl")
STRIDE = 10512
NVOICE = 8


def note_name(cv):
    """The engine's pitch CV is 1 V/oct-ish; report the nearest MIDI note so the
    trace is readable. Calibrated from the ref dump: note 69 -> 4.7499,
    note 57 -> 3.7502  =>  12 semitones per 1.0 CV, note = (cv-4.7499)*12 + 69."""
    return (cv - 4.7499) * 12.0 + 69.0


def main():
    d = pickle.load(open(PKL, 'rb'))
    lib = ctypes.CDLL(os.path.join(REPO, 'libjuno.so'))
    lib.juno_gui_create.restype = ctypes.c_void_p
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p,
                                        ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lib.juno_gui_render.argtypes = [ctypes.c_void_p,
                                    ctypes.POINTER(ctypes.c_float), ctypes.c_int]
    # Read engine cells through the port's OWN existing accessor (the same one
    # port_state_dump.py uses) rather than adding API just for a probe.
    lib.juno_gui_peek.restype = ctypes.c_uint
    lib.juno_gui_peek.argtypes = [ctypes.c_void_p, ctypes.c_int]

    bank = open(truth.BANK, 'rb').read()
    c = lib.juno_gui_create(ctypes.c_float(d['rate']), 0)
    lib.juno_gui_apply_bank(c, bank, len(bank), d['patch'])
    f32 = lambda u: struct.unpack('<f', struct.pack('<I', u))[0]

    pre = d.get('pre', 0)
    if pre:
        pbuf = (ctypes.c_float * (2 * pre))()
        lib.juno_gui_render(c, pbuf, pre)

    def dump():
        out = []
        for v in range(NVOICE):
            base = v * STRIDE
            cv = f32(lib.juno_gui_peek(c, base + 304))
            g = f32(lib.juno_gui_peek(c, base + 320))
            out.append((cv, g))
        return out

    print("patch %d  plugin ASSIGN=%d LEGATO=%d  rate %g"
          % (d['patch'], d['mode'], d['legato'], d['rate']))
    print("%-10s %-34s %-34s" % ("event", "PLUGIN v0 (cv -> note)", "PORT v0 (cv -> note)"))

    bad = 0
    ref_trace = d['trace']
    # ref_trace[0] is 'init'; events start at index 1
    for i, ev in enumerate(d['events'] if not d.get('nonotes') else []):
        if ev[0] == 'on':
            lib.juno_gui_note_on(c, ev[1], ev[2]); tag = "on %d/%d" % (ev[1], ev[2])
        else:
            lib.juno_gui_note_off(c, ev[1]); tag = "off %d" % ev[1]
        pv = dump()
        rv = ref_trace[i + 1][1]
        same = all(struct.pack('<f', a[0]) == struct.pack('<f', b[0])
                   and struct.pack('<f', a[1]) == struct.pack('<f', b[1])
                   for a, b in zip(pv, rv))
        if not same:
            bad += 1
        print("%-10s %7.4f -> %6.2f  g%.2f      %7.4f -> %6.2f  g%.2f   %s"
              % (tag, rv[0][0], note_name(rv[0][0]), rv[0][1],
                 pv[0][0], note_name(pv[0][0]), pv[0][1],
                 "" if same else "*** DIFFERS ***"))
        if not same:
            for v in range(NVOICE):
                if pv[v] != rv[v]:
                    print("        voice %d: plugin cv=%.6f g=%.3f   port cv=%.6f g=%.3f"
                          % (v, rv[v][0], rv[v][1], pv[v][0], pv[v][1]))

    # Same snapshot, port side. Any differing offset IS the bug's coordinate.
    vb = d.get('vblocks')
    if vb:
        print()
        total = 0
        for v in range(NVOICE):
            ref = vb[v]
            diffs = []
            # Offsets <176 are the C++ object header (vtable/refcount) plus the
            # master's output scratch at +32/+36. Audio-inert and known to differ
            # between one-state port and 9-unit oracle -- coldstate_ab excludes
            # them for the same reason. Anything >=176 is real engine state.
            hdr = 0
            for off in range(0, STRIDE, 4):
                pu = lib.juno_gui_peek(c, v * STRIDE + off)
                ru = struct.unpack('<I', ref[off:off+4])[0]
                if pu != ru:
                    if off < 176: hdr += 1
                    else: diffs.append((off, ru, pu))
            total += len(diffs)
            if diffs or hdr:
                print("voice %d: %d REAL differing cells (+%d benign header <176)"
                      % (v, len(diffs), hdr))
                for off, ru, pu in diffs[:12]:
                    print("   +%-6d plugin %08x (%-12.6g)  port %08x (%-12.6g)"
                          % (off, ru, f32(ru), pu, f32(pu)))
                if len(diffs) > 12:
                    print("   ... %d more" % (len(diffs) - 12))
        print("per-voice state: %d REAL differing cells total" % total)

    nz = d.get('noise')
    if nz:
        lo, hi = d['noise_lo'], d['noise_hi']
        print()
        same_units = all(nz[v] == nz[0] for v in range(NVOICE))
        print("plugin noise block: units 0..7 %s"
              % ("all IDENTICAL to each other" if same_units else "DIFFER from each other"))
        pb = b''.join(struct.pack('<I', lib.juno_gui_peek(c, off))
                      for off in range(lo, hi, 4))
        nd = sum(1 for i in range(0, len(pb), 4) if pb[i:i+4] != nz[0][i:i+4])
        print("port noise block vs plugin unit 0: %d / %d cells differ"
              % (nd, len(pb)//4))
        if nd:
            for i in range(0, len(pb), 4):
                if pb[i:i+4] != nz[0][i:i+4]:
                    ru = struct.unpack('<I', nz[0][i:i+4])[0]
                    pu = struct.unpack('<I', pb[i:i+4])[0]
                    print("   +%-6d plugin %08x (%-12.6g)  port %08x (%-12.6g)"
                          % (lo+i, ru, f32(ru), pu, f32(pu)))

    m = d.get('master')
    if m:
        lo, hi = d['master_lo'], d['master_hi']
        # Trim to the engine's REAL state. juno_engine.h: highest cell +11022344;
        # anything above is slack in our 12 MB allocation (port calloc'd to 0,
        # oracle holds the plugin allocator's heap garbage) and is not signal.
        hi = min(hi, 11022352)
        # Regions where a one-state port and a 9-unit oracle MUST differ, each
        # already audited elsewhere -- listed explicitly so nothing is hidden by
        # accident:
        BENIGN = [
            (84272, 84436,  "shared analog-noise LFSR: per-unit; oracle unit 8 never steps it"),
            (101472, 101792, "aux one-shot array 101504+v*32: per-VOICE; unit 8's copies dead at 1.0"),
            (102544, 102548, "audited-inert FX-recall default (coldstate_ab exclusion)"),
            (10759360, 10759364, "audited-inert FX-recall default"),
            (10759472, 10759476, "audited-inert FX-recall default"),
            (10759840, 10759844, "audited-inert FX-recall default"),
            (11022344, 11022348, "warmup-mute latch the port never needs"),
        ]
        def why(off):
            for a, b, txt in BENIGN:
                if a <= off < b: return txt
            return None
        print("\nscanning master/shared region [%d, %d) ..." % (lo, hi))
        runs, cur, ndiff = [], None, 0
        for off in range(lo, hi, 4):
            ru = struct.unpack('<I', m[off-lo:off-lo+4])[0]
            pu = lib.juno_gui_peek(c, off)
            if pu != ru:
                ndiff += 1
                if cur and off == cur[1] + 4: cur[1] = off
                else:
                    cur = [off, off]; runs.append(cur)
        expl = [r for r in runs if why(r[0])]
        real = [r for r in runs if not why(r[0])]
        print("master/shared: %d differing cells in %d run(s)  ->  %d explained, %d UNEXPLAINED"
              % (ndiff, len(runs), len(expl), len(real)))
        for a, b in real:
            ra = struct.unpack('<I', m[a-lo:a-lo+4])[0]
            pa = lib.juno_gui_peek(c, a)
            print("   UNEXPLAINED [%8d .. %8d] %4d cells  plugin %08x (%-12.6g) port %08x (%-12.6g)"
                  % (a, b, (b-a)//4+1, ra, f32(ra), pa, f32(pa)))
        if not real:
            print("   -> every differing cell is in an audited benign region.")

    a1 = d.get('after1')
    if a1:
        b1 = (ctypes.c_float * 2)()
        lib.juno_gui_render(c, b1, 1)
        bits1 = lambda f: struct.unpack('<I', struct.pack('<f', f))[0]
        print("\nframe 0 output: plugin L=%08x  port L=%08x  %s"
              % (a1['L1'][0], bits1(b1[0]),
                 "MATCH" if a1['L1'][0] == bits1(b1[0]) else "DIFFER"))
        tot = 0
        for v in range(NVOICE):
            ref = a1['v'][v]
            bad = [off for off in range(176, STRIDE, 4)
                   if lib.juno_gui_peek(c, v * STRIDE + off)
                      != struct.unpack('<I', ref[off:off+4])[0]]
            if bad:
                tot += len(bad)
                print("  AFTER 1 FRAME voice %d: %d cells differ, first at +%d"
                      % (v, len(bad), bad[0]))
                for off in bad[:8]:
                    ru = struct.unpack('<I', ref[off:off+4])[0]
                    pu = lib.juno_gui_peek(c, v * STRIDE + off)
                    print("      +%-6d plugin %08x (%-12.6g)  port %08x (%-12.6g)"
                          % (off, ru, f32(ru), pu, f32(pu)))
        nb = [off for off in range(d['noise_lo'], d['noise_hi'], 4)
              if lib.juno_gui_peek(c, off)
                 != struct.unpack('<I', a1['noise'][0][off-d['noise_lo']:off-d['noise_lo']+4])[0]]
        print("  AFTER 1 FRAME noise block vs unit 0: %d cells differ" % len(nb))
        print("  AFTER 1 FRAME per-voice total: %d cells differ" % tot)

    n = len(d['L'])
    buf = (ctypes.c_float * (2 * n))()
    lib.juno_gui_render(c, buf, n)
    bits = lambda f: struct.unpack('<I', struct.pack('<f', f))[0]
    dl = sum(1 for i in range(n) if bits(buf[2 * i]) != d['L'][i])
    first = next((i for i in range(n) if bits(buf[2 * i]) != d['L'][i]), None)
    print("\naudio: %d/%d L samples differ%s"
          % (dl, n, "" if first is None else ", first @ frame %d" % first))
    print("VERDICT: %s" % ("allocator decisions MATCH" if bad == 0
                           else "allocator DIVERGES at %d event(s)" % bad))
    return 1 if (bad or dl) else 0


if __name__ == '__main__':
    truth.require()
    sys.exit(main())
