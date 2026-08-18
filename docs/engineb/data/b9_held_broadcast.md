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
