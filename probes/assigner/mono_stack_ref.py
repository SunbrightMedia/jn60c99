#!/usr/bin/env python3
"""mono_stack_ref.py — ORACLE side of the seed-15 MONO divergence probe.

fuzz_diff seed 15 diverges on patch 15 ("BS VeloRez Bass", ASSIGN=1 MONO) at
frame 748 -- the FIRST sample after its note burst, so the allocator picks a
different note or voice immediately rather than drifting.

The seed-15 note pattern, extracted from fuzz_diff.gen_script(15):

    on 69/36  on 57/45  on 64/29  on 89/54  on 86/11  on 96/103
    off 96                                   <-- releases the NEWEST note
    on 75/100

That last-two-events shape is what no existing script covers: assigner_ab's
'overlap' releases the OLDER of two, and 'chord' releases a MIDDLE note. Nothing
stacks notes and then releases the NEWEST, which under MONO last-note priority
must fall BACK to the previous newest.

This dumps what the PLUGIN'S OWN allocator does after every event: per voice, the
pitch CV (voice base + 304) and the gate cell (+320). --port replays the same
events through libjuno and diffs those decisions, so a mismatch names the exact
voice and event rather than just "audio differs".

TWO-PROCESS RULE: oracle only. Never imports libjuno.
"""
import sys, os, pickle, struct

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, "tools", "verify"))
import truth

PKL = os.path.join(REPO, "scratchpad", "mono_stack_ref.pkl")

# Exactly fuzz_diff.gen_script(15)'s event prefix, plus a render so the audio
# comparison lines up with the fuzz gate's own frame numbering.
EVENTS = [
    ('on', 69, 36), ('on', 57, 45), ('on', 64, 29),
    ('on', 89, 54), ('on', 86, 11), ('on', 96, 103),
    ('off', 96),
    ('on', 75, 100),
]

# LOAD-BEARING. seed 15 begins with render(747) BEFORE any note. Without it the
# allocator decisions match and the audio is bit-exact for 760 frames -- i.e. the
# MONO note logic is NOT the bug. The 747 idle frames are what make it diverge,
# which points at post-render (warm) state rather than note handling.
PRE_RENDER = 747
PATCH = int(os.environ.get('JUNO_PROBE_PATCH', 15))
NONOTES = os.environ.get('JUNO_PROBE_NONOTES') == '1'
RATE = 44100.0
STRIDE = 10512
NVOICE = 8
NOISE_LO, NOISE_HI = 84272, 84436
MASTER_LO = 84272          # first shared cell (analog-noise block) past the voices
MASTER_HI = 11026432       # highest offset the engine ever touches (measured)


def voice_dump(e):
    """Per-voice (pitch CV, gate) as the plugin's allocator left them.

    Voice v lives at state[v] + v*STRIDE (docs: 'plugin voice v renders at
    state[v]+v*10512, NOT state[v]+0')."""
    out = []
    for v in range(NVOICE):
        base = e.state[v] + v * STRIDE
        cv = struct.unpack("<f", e.uc.mem_read(base + 304, 4))[0]
        gate = struct.unpack("<f", e.uc.mem_read(base + 320, 4))[0]
        # aux DCO-retrigger latch for this voice, read from the SAME unit that
        # renders it (101504 + v*32). This is the cell voice_render consumes.
        aux = struct.unpack("<f", e.uc.mem_read(e.state[v] + 101504 + v * 32, 4))[0]
        # Array B (101520 + v*32). The port's juno_note.c claims note-on writes
        # THIS and not Array A; read both so the claim is testable.
        auxb = struct.unpack("<f", e.uc.mem_read(e.state[v] + 101520 + v * 32, 4))[0]
        out.append((cv, gate, aux, auxb))
    return out


def main():
    import e2e_emu as E
    import real_recall as R
    import recall_render_ab as RA

    bank = E.bank_bytes()
    leaves = R.leaf_table()
    e = RA.prepare_recall(PATCH, bank, leaves, E, R, RATE)
    mode = e.rd_i32(e.assign[0] + 16)
    legato = e.rd_i32(e.assign[0] + 20)
    print("patch %d  ASSIGN=%d  LEGATO=%d  rate %g" % (PATCH, mode, legato, RATE))

    # The idle pre-render that the fuzz script starts with.
    if PRE_RENDER:
        e.render(PRE_RENDER, block=PRE_RENDER)
    trace = [("init", voice_dump(e))]
    print("  %-10s " % "AFTER PRE" + "  ".join(
        "v%d[g%.0f A%.0f B%.0f]" % (v, g, a, b) for v, (cv, g, a, b) in enumerate(trace[0][1])))
    for ev in (EVENTS if not NONOTES else []):
        if ev[0] == 'on':
            e.note_on(ev[1], ev[2]); tag = "on %d/%d" % (ev[1], ev[2])
        else:
            e.note_off(ev[1]); tag = "off %d" % ev[1]
        trace.append((tag, voice_dump(e)))
        print("  %-10s " % tag + "  ".join(
            "v%d[g%.0f A%.0f B%.0f]" % (v, g, a, b) for v, (cv, g, a, b) in enumerate(trace[-1][1])))

    # FULL per-voice state snapshot BEFORE the post-note render. The allocator
    # decisions already match, so whatever differs must be here. Voice v lives at
    # state[v] + v*STRIDE.
    vblocks = [bytes(e.uc.mem_read(e.state[v] + v * STRIDE, STRIDE))
               for v in range(NVOICE)]

    # MASTER/shared region. The oracle renders the master from unit 8; the port
    # keeps master and voices in ONE state. Compare only >=MASTER_LO so unit 8's
    # dead voice-block copies cannot produce false positives.
    master = bytes(e.uc.mem_read(e.state[8] + MASTER_LO, MASTER_HI - MASTER_LO))

    # The shared analog-noise LFSR (84272..84436) is stepped by the VOICE units,
    # not the master. Comparing the port against unit 8 there is meaningless --
    # unit 8's copy is dead. Capture units 0..7's copies so the port can be
    # compared against something that actually runs.
    noise = [bytes(e.uc.mem_read(e.state[v] + NOISE_LO, NOISE_HI - NOISE_LO))
             for v in range(NVOICE)]

    # Frame 0 of the post-note render MATCHES and frame 1 differs, so the first
    # rendered sample is where state first moves apart. Snapshot everything again
    # after exactly one frame: the cell that differs here is the origin.
    L1, R1 = e.render(1, block=1)
    after1 = {
        'v': [bytes(e.uc.mem_read(e.state[v] + v * STRIDE, STRIDE)) for v in range(NVOICE)],
        'noise': [bytes(e.uc.mem_read(e.state[v] + NOISE_LO, NOISE_HI - NOISE_LO))
                  for v in range(NVOICE)],
        'master': bytes(e.uc.mem_read(e.state[8] + MASTER_LO, MASTER_HI - MASTER_LO)),
        'L1': L1, 'R1': R1,
    }

    # 748 frames covers the fuzz gate's divergence point with margin.
    L, Rr = e.render(759, block=759)
    pickle.dump({'mode': mode, 'legato': legato, 'trace': trace, 'pre': PRE_RENDER,
                 'vblocks': vblocks, 'master': master, 'noise': noise, 'after1': after1,
                 'noise_lo': NOISE_LO, 'noise_hi': NOISE_HI,
                 'master_lo': MASTER_LO, 'master_hi': MASTER_HI,
                 'L': L, 'R': Rr, 'events': EVENTS, 'nonotes': NONOTES, 'patch': PATCH, 'rate': RATE},
                open(PKL, 'wb'))
    print("-> %s" % PKL)
    return 0


if __name__ == '__main__':
    truth.require()
    sys.exit(main())
