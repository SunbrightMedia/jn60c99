# B9 — why a note burst is 7.9x its plan: the HELD broadcast, and it is CORRECT
2026-08-18, established by READING (static), no board time. Every claim below
is READ unless marked; the arithmetic is INFERRED and the board's NB: line is
what will confirm or refute it.

## 1. THE CHAIN, END TO END
  * eb_alloc.c:178 and :225 -- EVERY note-on AND EVERY note-off emits
    EB_EV_HELD. Not some. Every one, in every assign mode.
  * eb_devseq.c:122 -- EB_EV_HELD sets the touched mask to ~0u:
        EB_DEVSEQ_TOUCHED |= (ev[i].kind == EB_EV_HELD) ? ~0u : (1u << voice);
  * so EB_DEVSEQ_TOUCHED IS ALWAYS ALL EIGHT VOICES, on every note event.
  * eb_recall_build_voices(&REC, ~0u) therefore rebuilds all eight voices --
    which IS the full voice build, measured at 1,124,609 cycles on the
    RECALL: burst-split line, plus the ~20 KB shadow copy.

    1.12 M + copy ~= the 1.06-1.27 M b8 measured. THE 7.9x IS FULLY EXPLAINED.

FINAL_GUIDE C4's "~135,000 cycles" assumed the allocator names ONE voice. It
does name one -- and then the broadcast widens the mask to all eight. The plan
number was not measured, and nothing between the plan and b8 measured it.

## 2. IT IS CORRECT, NOT A DEFECT -- so it may not simply be narrowed
Cell 1856 is a REAL per-voice coefficient input:
  * src/juno_note.c:220 juno_note_broadcast_held writes cell 1856 on EVERY
    voice (JF(st, VBASE(v) + 1856) = f), measured from the plugin's own event
    handling under Unicorn;
  * eb_coefs.c:298 reads it -- q->k1856 = CF(a1, 1856) -- into the LFO coef;
  * eb_lfo.c:136 reads k1856 per sample.
So when the broadcast value changes, all eight voices' coefficients really do
change, and rebuilding all eight is the right answer. The mask is honest.

## 3. THE LEVER: THE BROADCAST IS A NO-OP MOST OF THE TIME
juno_note.c:204-211 states the semantics exactly: 1856 = (held-note count > 0).
  * note-on writes 1.0 to all voices -- but if a key is ALREADY held it was
    already 1.0, so nothing changed;
  * note-off writes 0.0 to all voices ONLY when no key remains held; releasing
    one note of a chord leaves it 1.0 everywhere.
So the broadcast only MOVES a coefficient on the 0->1 and 1->0 transitions --
the first key down and the last key up. Every note in between (legato, adding
to a held chord, releasing part of one) rebuilds seven voices whose k1856 is
unchanged and whose every other cell is untouched.

PROPOSED, NOT DONE: track the previous any_held state where the broadcast is
issued, and widen the mask to ~0u only when it actually transitions. Typical
notes then touch one voice (~140,000) instead of eight (~1.12 M) -- which is
the ~135,000 the plan assumed, arrived at honestly.
MUST BE GATED: chunk_gate.py already compares against eb_recall_build_voices
over all 256 masks; this needs the same treatment against a run that always
broadcasts, plus a tooth that holds a chord and requires the mask to STAY
narrow, and one that presses the first key and requires it to WIDEN.

## 4. ⚠ WHAT THIS MEANS FOR THE O2b CHUNKING JUST BUILT
With the mask always ~0u, a chunked note is 1 (events) + 8 (voices) +
1 (check) = TEN BLOCKS = 58 ms of key latency. That is not a keyboard.
Fable 5 flagged the latency risk at 2-4 blocks; the real figure is worse
because the mask is always full.

So O2b's chunking is correct and INSUFFICIENT ON ITS OWN. The order is:
  1. narrow the mask (section 3) -- 8 voices -> 1, gated;
  2. then the chunking costs 1 + 1 + 1 = 3 blocks = 17 ms, and folding the
     check into the last voice step makes it 2 blocks = 12 ms;
  3. only then is the note path both deadline-safe AND playable.
Shipping the chunking without the narrowing trades 18 missed deadlines for
58 ms of key latency, which is a bad trade and not what rule 3 intends --
"latency degrades" means the CHANGE arrives late, not that the instrument
feels broken.

## 5. REVIEW NOTES (Fable 5, 2026-08-18) — three additions before the fix
  a. THE ARITHMETIC HAS A WRINKLE. b8's low reading (1.06 M) sits BELOW the
     full voice build (1.12 M) plus the copy. Probably cache warmth; the NB:
     ev=/vb= split is what settles it. The explanation is NEAR-CERTAIN, not
     closed, until nv= prints 8 and vb= matches.
  b. THE TRANSITION TRACKER MUST RESYNC AT PATCH RECALL. Reseed rewrites cell
     1856; a stale tracker skips a needed widen and seven voices carry a wrong
     k1856 into the LFO — audible, invisible to a chord test. Required tooth:
     after a patch change, the first note-on WIDENS.
  c. THE FIRST KEY AFTER SILENCE STILL WIDENS TO EIGHT — ten blocks, 58 ms —
     and that is the most audible note there is. Narrowing fixes legato and
     chords, not the first strike. That case needs its own design answer (a
     second publish, or a measured acceptance), stated rather than silent.

## 6. THE NARROWING WAS BUILT, GATED, AND REFUSED BY ITS OWN GATE (2026-08-18)
IMPLEMENTED as section 3 proposed -- read cell 1856 rather than track state, so
a patch reseed cannot leave a stale flag (Fable 5's objection b, eliminated by
construction rather than by a tooth). Then gated. THE GATE SAID NO.

tools/engineb/held_gate.py runs press-A, press-B-while-held, release-B,
release-A across patches 0, 5 and 21, and after every batch compares the LIVE
coefficients against a full rebuild from the CURRENT cells:

    patch  0   all four steps PASS, narrows on the two middle steps
    patch 21   all four steps PASS, narrows on the two middle steps
    patch  5   THREE STEPS FAIL -- 14 bytes of 18,788 differ, and
               "a WIDE build from the same start MATCHES the full rebuild"

That last line is the verdict: the mask is the cause. Narrowing drops a voice
whose coefficients genuinely changed. Section 3's reasoning -- 1856 only moves
on the first key down and the last key up -- is TRUE (the gate prints all eight
voices reading 1.0) and NOT SUFFICIENT. Something else a note does reaches
other voices, and cell 1856 was never the whole story.

WHERE TO LOOK NEXT, from the gate's own evidence: patch 5 is the only one of
the three that narrows on its FIRST key (the recall left 1856 at 1.0, so no
widen resyncs it) and the only one whose allocator names voice 0 rather than
voice 6 -- i.e. it is MONO, and MONO emits GLIDE, RETRIG and PORTA_GATE where
POLY does not. Those three event kinds are the difference between a passing
patch and a failing one.

SHIPPED STATE: the unconditional widen, behind #ifdef EB_DEVSEQ_NARROW_HELD
(default OFF). The idea is worth 7.9x and is not deleted; the gate now states
exactly what must be true before it can be switched on, and refuses it until
then. held_gate.py PASSES on the shipped path -- which is itself worth having,
because it proves the widen is correct rather than merely conservative.

⚠ SO THE 58 ms LATENCY OF §4 STANDS, AND O2b MUST NOT SHIP ALONE.
The note burst is chunked and correct, but at eight voices a key press is ten
blocks. The remaining options, none yet chosen:
  a. fix the narrowing (find what MONO moves, extend the mask honestly);
  b. derive the mask from WHICH CELLS WERE WRITTEN rather than from event
     kinds -- ebdev already has the hook to track dirty scatter indices;
  c. publish the allocated voice after ONE step and the rest later, so the key
     sounds immediately and the other seven catch up;
  d. keep the burst whole for notes and accept the deadline miss.
(c) is the one that matches rule 3 best -- the note arrives on time and the
change completes late -- but it needs a second publish path and its own gate.

## 7. THREE HYPOTHESES TESTED AND ELIMINATED (2026-08-18, same day)
Fable 5 challenged §6's verdict as PLAUSIBLE rather than PROVEN, on the ground
that the gate might be measuring its own side effects. Each candidate was made
into a check rather than argued about. All three are now closed.

  a. "THE REFERENCE IS DESTRUCTIVE." Proposed mechanism: eb_coefs_voice
     consumes the aux-edge cell, so the second build sees different inputs.
     TESTED -- held_gate.c now builds the reference TWICE from unchanged cells
     and compares, on every patch, before anything else runs.
     RESULT: "reference build is idempotent" on patches 0, 5 and 21.
     The named mechanism is also not in the path: the aux-edge reads are in
     eb_render_state_seed and eb_render_events_mirror, neither of which this
     gate calls. HYPOTHESIS REFUTED.

  b. "THE FAILURE IS AN ARTIFACT." TESTED by re-running with the narrowing
     compiled ON (HELD_NARROW=1) after the idempotency check was in place.
     RESULT: patch 5 still fails, identically -- first differing byte 6418 of
     18,788, 14 bytes, on all three narrow steps, every run. Deterministic.
     HYPOTHESIS REFUTED.

  c. "ONE VOICE IS MISSING FROM THE MASK." TESTED -- the gate now adds each
     absent voice to the mask one at a time and reports which repairs it.
     RESULT: "no single added voice repairs it -- more than one voice moved."
     HYPOTHESIS REFUTED, and this is the most informative of the three: the
     narrowing is not short by one voice, so no small correction to the event
     mask will fix it.

## 8. WHAT IS ACTUALLY KNOWN, AND WHAT IS NOT
KNOWN (executed): the reference is idempotent; the failure is deterministic and
byte-identical across runs; a WIDE build from the same starting point matches
ground truth; more than one voice is stale; all eight voices' cell 1856 read
1.0 at the moment of failure; patches 0 and 21 pass and patch 5 does not;
patch 5 is the only one of the three whose allocator names voice 0 rather than
voice 6, i.e. the only non-POLY one.

NOT KNOWN: which cell a note writes that reaches more than one voice. The
leading candidate is the DEVICE CELL MODEL itself -- ebdev gives every voice
its own storage for exactly TWELVE scatter cells and SHARES everything else
through one tile that ebdev_voice_select swaps per build. Any note write that
lands outside those twelve is therefore seen by every voice. Every write in
juno_note_on, _glide, _retrig, _porta_gate and _off that this session checked
IS a scatter cell (304, 320, 592, 1856, 6864, 9680, 9824), so the write that
escapes has not been found. THAT IS THE NEXT SESSION'S FIRST QUESTION, and the
gate can now answer it: instrument ebdev_at to log non-scatter writes during
eb_devseq_events on patch 5.

⚠ THE SHIP DECISION IS UNCHANGED AND DOES NOT DEPEND ON ANY OF THIS. The
unconditional widen is measured-correct on all three patches; it is what ships;
the narrowing stays behind EB_DEVSEQ_NARROW_HELD, default off, and may not be
enabled until held_gate.py is green with HELD_NARROW=1.
