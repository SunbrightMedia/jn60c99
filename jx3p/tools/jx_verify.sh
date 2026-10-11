#!/bin/sh
# jx_verify.sh -- the JX-3P PORT FINISH LINE. One command, self-proving, every
# fact re-derived from the checksummed binary. Green here == the port is done
# for what it covers; the coverage is stated plainly at the end.
#
# Two proven halves, tied together:
#   A. RECALL   -- the plugin's OWN patch load (2026-10-10, playbook 197): the
#                  oracle drive (initialize's and the patch browser's records
#                  through the engine's own host entry) equals the booted plugin
#                  word for word (jx_recall_product_check.py), and the port's
#                  recall equals that drive in every window, all 64 patches
#                  (jx_recall_data_gate.py). The old pool-model LUT gate
#                  (jx_recall_gate.sh) graded a model and is no gate.
#   B. RENDER   -- integration A/B: recall(oracle) -> note-on(oracle) -> the
#                  FULL per-sample chain (8 voice arms + master) in C vs the
#                  plugin's own arms+master, byte-exact on the seam, L/R, and
#                  every final state word. Run across 3 host rates and a long
#                  block so no rate- or time-dependent divergence hides.
#
# Two-process rule honoured (Unicorn oracle and ctypes port never share a
# process). Per-patch process-and-delete keeps the disk flat.
#
#   C. CLOCK + PRODUCT (2026-10-10, JX-7) -- the engine's clock tick and the
#                  note store's step machine against the plugin's own tick and
#                  note entries, every control object after every event: factory
#                  patches, variants of the plugin's own patch load for every step
#                  mode the product reaches, and all 19 modes through the plugin's
#                  own setter (jx_tick_gate.py); then the plugin's own process()
#                  -- its render driver, the 96 kHz engine, its render object --
#                  against the port's product path, block for block at three host
#                  rates, notes at block starts and inside blocks (jx_product_gate.py).
#
#   D. HOST LAYER (2026-10-10, JX-8 .. JX-18) -- the host tempo, the engine-rate
#                  setting, a fresh instance in the plugin's order, the DAW state
#                  (getState / setState, the CC map), the UI timer, KEY HOLD, MIDI
#                  learn, the patch browser on any bank, the editor's set and the
#                  host's round trip: each against the booted plugin's own calls
#                  (GATES 3d, 3e, 3f).
#
#   E. THE EDITOR'S LOGIC (2026-10-11, JX-22, JX-25) -- the window zoom and the
#                  level meters against the plugin's own code, its editor attached
#                  (GATE 3h).
#
# What this does NOT cover, stated so "green" is not read wider than it is
# (jx3p/docs/SCOPE_AUDIT.md is the full table, row 20 open; docs/GATE_PARITY.tsv
# the gate classes still owed): the editor's GRAPHICS -- the panel is not drawn
# (no JX art in truth/), so neither the CC assign menu's search on the panel nor
# the bank name control's presses run; their models are graded (3f, 3h).
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
WORK=${JX_VERIFY_WORK:-$(mktemp -d)}
mkdir -p "$WORK"
RATES=${JX_VERIFY_RATES:-"44100 48000 96000"}
N=${JX_VERIFY_N:-64}          # samples per patch (long block: crosses LFO/env edges)
WARM=${JX_VERIFY_WARM:-6}
PATCHES=${JX_VERIFY_PATCHES:-"$(seq 0 63)"}
echo "[jx verify] work dir $WORK  rates=$RATES  n=$N warm=$WARM"

echo "=== JX GATE S: THE SOURCES (ISO C99 in a generic and the native configuration; no approximation marker) ==="
# the port must stand on ISO C99 alone: gcc -std=c99 -pedantic-errors and a scan of the live code (2026-10-11: the
# lifted mul / div and the voice helpers used __int128, a builtin and x86 asm -- none of them C99)
python3 "$REPO/tools/verify/c99_gate.py"
python3 "$REPO/tools/verify/c99_gate.py" --self-test         # an __int128, a builtin, a POSIX header must be seen
# ... and the C99 that replaced them computes what they did: the 128-bit products and quotients, the bit scans and the
# two float-to-int conversions against GCC's __int128 / builtins and the SSE2 instructions, ~20 M cases (playbook 218)
python3 "$REPO/tools/verify/c99_helpers_check.py"
python3 "$REPO/tools/verify/c99_helpers_check.py" --self-test   # five planted mutations, each must be seen
python3 "$REPO/tools/verify/approx_audit.py" --jx

echo "=== JX GATE 0/5: THE DRIVE GATE (playbook 87/88/89/90) ==="
# Every defect that cost this port days was a DRIVE defect, invisible to an
# A/B gate because both sides shared it. These teeth check the drive itself:
# the ABI ledger against the machine code, the boot fingerprint against its
# recorded value, the bank decode census (with its tooth), and that the
# shipped template and aux come from ONE boot.
python3 "$HERE/jx_drive_gate.py"
python3 "$HERE/jx_drive_gate.py" --tooth                  # the base match RED on the heap after initialize's records
echo "=== JX GATE 1/5: RECALL ON THE PLUGIN'S OWN PATCH LOAD (playbook 197) ==="
python3 "$HERE/jx_recall_product_check.py" 0 49          # the drive == the booted plugin, every unit, word for word
python3 "$HERE/jx_recall_product_check.py" --tooth       # one record left out must be seen
python3 "$HERE/jx_recall_data_gate.py"                   # the port's recall == the drive, every window, 64/64
python3 "$HERE/jx_recall_data_gate.py" --patches 0,20 --tooth

echo "=== JX GATE 2/5: INTEGRATION RENDER A/B (voice+master, C == plugin) ==="
cc -O2 -fno-strict-aliasing -ffp-contract=off -shared -fPIC \
   -o "$WORK/libjxengine.so" \
   "$REPO/jx3p/src/jx_voice_render.c" "$REPO/jx3p/src/jx_voice_helpers.c" \
   "$REPO/jx3p/src/jx_master_render.c" "$REPO/jx3p/src/jx_ftz.c" -lm
fails=0
for sr in $RATES; do
  spass=0
  for p in $PATCHES; do
    rm -rf "$WORK/ab"
    if ! python3 "$HERE/ab_render_emu.py" "$WORK/ab" "$p" "$N" "$WARM" "$sr" >/dev/null 2>&1; then
      echo "  sr=$sr p=$p ORACLE FAIL"; fails=$((fails+1)); continue
    fi
    if python3 "$HERE/ab_render_c.py" "$WORK/ab" "$WORK/libjxengine.so" "$N" 2>&1 \
        | grep -q "1/1 patches EXACTLY 0"; then
      spass=$((spass+1))
    else
      echo "  sr=$sr p=$p RENDER FAIL"; fails=$((fails+1))
    fi
  done
  echo "  rate $sr: $spass/$(echo $PATCHES | wc -w) EXACTLY 0"
done
rm -rf "$WORK/ab"
if [ "$fails" -ne 0 ]; then
  echo "[jx verify] FAIL -- $fails patch/rate cases not EXACTLY 0"; exit 1
fi
echo "=== JX GATE 3/5: FULL CHAIN (shipping entry path, reach 12000) ==="
JX_FULL_SKIP_DERIVE=1 sh "$HERE/jx_full_gate.sh"
echo "=== JX GATE 3b: THE MASTER, EVERY SAMPLE OF STATE (64 patches + the mode variants + tooth; playbook 198) ==="
# every unit's state, the 36 control objects and L/R per 256-sample chunk over 4,096 idle + a note +
# 12,000, against the plugin; the variants set the two effect-mode cells to the values no factory
# patch holds, through the plugin's own host entry; the tooth puts the decompile's lost argument back
python3 "$HERE/jx_master_bisect.py" --gate 12000
# the same at the product's 96 kHz engine (JX-19): the voices take branches the 44.1 kHz engine does not -- a voice
# filter's history that no audio gate sees (the mutation reach found it: playbook 208)
python3 "$HERE/jx_master_bisect.py" --rate 96000 --gate 4000
# (JX-26d) seeded polyphony -- chords, up to 10 keys held over six voices (steals), re-strikes -- every unit and
# control object right after each chunk's events and after its render; its tooth: the port's keys a semitone up
python3 "$HERE/jx_master_bisect.py" --script 1,2,3,4 --patches 0,5,20,49 24000
python3 "$HERE/jx_master_bisect.py" --rate 96000 --script 5,6 --patches 0,34 12000
python3 "$HERE/jx_master_bisect.py" --script 2 --patches 0 --tooth-key 6000
# every voice-mode value no factory patch holds (Script.xml's ranges), and each effect type at each value with
# every effect parameter at 0, 128 and 255 -- rendered, every unit's state per chunk
python3 "$HERE/jx_master_bisect.py" --modes 4000
python3 "$HERE/jx_master_bisect.py" --fxrender 4000
echo "=== JX GATE 3c: THE CLOCK TICK AND THE STEP MACHINE (every control object after every event; JX-7) ==="
# 5 factory patches x 1,500 events, 12 variants of the plugin's own patch load (every step mode the
# product reaches: a REFUSE if one is missing), all 19 modes through the plugin's own setter; the port's tick,
# note entries and setter are the plugin's own, lifted (JX-12b); the tooth drops the step clock's increment
# (inc at 0x3EFE5E) from the lifted source
python3 "$HERE/jx_tick_gate.py"
python3 "$HERE/jx_tick_gate.py" --tooth --patches 34,61 --variants '34:+0x600120=8' --no-setmode \
        --events 300 --variant-events 300
echo "=== JX GATE 3d: THE PRODUCT PATH (the plugin's own process(): render driver, 96 kHz engine, render object) ==="
python3 "$HERE/jx_product_gate.py" --patches 0,34,61,20
python3 "$HERE/jx_product_gate.py" --exact --patches 34,61 --on 0.61 --off 0.93 --secs 1.2
python3 "$HERE/jx_product_gate.py" --tooth --patches 0                 # no render object: every rate differs
python3 "$HERE/jx_product_gate.py" --tooth-clock --patches 34,61       # the first key does not restart the clock
python3 "$HERE/jx_product_gate.py" --rates 88200,192000 --patches 0,61  # the other rates of the render object
python3 "$HERE/jx_product_gate.py" --rates 32000 --patches 0 --expect-silent   # outside its table: silence, both
# polyphony: chords, up to 10 keys (more than the six voices), re-strikes, several events at one sample
python3 "$HERE/jx_product_gate.py" --poly 1,2 --patches 0,61 --on 0.55 --secs 2.0
python3 "$HERE/jx_product_gate.py" --tooth-voices --rates 48000 --patches 0 --poly 1 --on 0.55 --secs 2.0
# WARM patch changes (JX-11): the plugin's patch browser loads another patch on the running engine, a key held
python3 "$HERE/jx_product_gate.py" --rates 48000,96000 --patches 0,34 --on 0.3 --off 2.0 --secs 2.4 --recall '20@0.9'
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0,34 --on 0.3 --off 2.0 --secs 2.4 --recall '61@0.9'   # to the arpeggiator, a key held
python3 "$HERE/jx_product_gate.py" --tooth-recall --rates 48000 --patches 0 --on 0.3 --off 2.0 --secs 2.4 --recall '20@0.9'
# HOST AUTOMATION (JX-11d): seeded VST3 parameter queues through process() -- the driver's id map and value law
# (jx3p/src/jx_midi_tables.h, from the booted plugin: --check rebuilds it from two boots) and the lifted host entry
python3 "$HERE/jx_gen_midi_tables.py" --check
python3 "$HERE/jx_product_gate.py" --rates 44100,96000 --patches 0 --on 0.6 --off 2.0 --secs 2.4 --edits 1,2
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 34 --on 0.6 --off 2.0 --secs 2.4 --edits 3
python3 "$HERE/jx_product_gate.py" --tooth-edits --rates 48000 --patches 0 --on 0.6 --off 2.0 --secs 2.4 --edits 1
python3 "$HERE/jx_product_gate.py" --tooth-law --rates 48000 --patches 0 --on 0.6 --off 2.0 --secs 2.4 --edits 1
# THE MIDI CONTROLLERS (JX-12): seeded MIDI-mapping points (sustain, all notes off, mod, expression, mapped and
# ignored CCs, bend, aftertouch) with seeded polyphony -- process()'s conversion and push, the driver's dispatch,
# the engine's CC and bend entries (lifted)
python3 "$HERE/jx_product_gate.py" --rates 48000,96000 --patches 0 --poly 1 --ctl 1 --on 0.55 --secs 2.4
python3 "$HERE/jx_product_gate.py" --rates 44100 --patches 61,34 --poly 2 --ctl 2 --on 0.55 --secs 2.4
python3 "$HERE/jx_product_gate.py" --tooth-ctl --rates 48000 --patches 0 --poly 1 --ctl 1 --on 0.55 --secs 2.4
# HOST BLOCK SIZES (JX-13): the JUNO's set -- 64, 600, 128 and single-sample blocks -- through process()
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0 --block 64 --poly 1 --on 0.55 --secs 1.6
python3 "$HERE/jx_product_gate.py" --rates 44100 --patches 61 --block 600 --poly 2 --ctl 2 --on 0.55 --secs 1.6
python3 "$HERE/jx_product_gate.py" --rates 96000 --patches 61 --block 128 --poly 1 --on 0.55 --secs 1.2
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 34 --block 1 --exact --on 0.5213 --off 0.6007 --secs 0.65
# LONG RENDERS (JX-14): 6 s through process() -- effect tails after a short note, a long note
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 5,49 --on 0.55 --off 1.0 --secs 6.0
python3 "$HERE/jx_product_gate.py" --rates 44100 --patches 40 --on 0.55 --off 5.0 --secs 6.0
# THE NOTE MODES (JX-12b): legato (no factory patch sets it), the assign modes, portamento and the arpeggiator set
# at the start through process(), with seeded polyphony and controllers -- the plugin's own note path, lifted
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0,34 --poly 3 --ctl 3 --on 0.55 --secs 2.4 \
        --set '600062=1;600064=0.5,600062=1;600064=1;600060=0.5,600062=1,600064=1;600108=1,600062=1'
# THE ARPEGGIATOR SWITCHED BY THE HOST WITH KEYS HELD (a point at its own sample inside its block), on and off
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0,34 --poly 2 --on 0.55 --secs 2.4 \
        --set '600108=1@0.9,600108=0@1.6;600108=0@0.9,600108=1@1.6'
# PATCH CHANGES IN FAST SUCCESSION (JX-16): three loads between two blocks, at the block of the key's note-on
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0 --on 0.9 --off 2.0 --secs 2.4 --recall '20@0.9,61@0.9,5@0.9'
python3 "$HERE/jx_product_gate.py" --rates 96000 --patches 34 --on 0.6 --off 2.0 --secs 2.4 --recall '61@0.9,0@0.95,34@1.0'
# A USER'S BANK (JX-16): records of random bytes loaded through the patch browser with keys held -- the audio graded
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0 --poly 1 --on 0.55 --secs 2.4 --recall 'r3@0.7,r14@1.4'
python3 "$HERE/jx_product_gate.py" --tooth-recall --rates 48000 --patches 0 --poly 1 --on 0.55 --secs 2.4 --recall 'r3@0.7'
# THE HOST TEMPO (JX-8): the ProcessContext's tempo -- the render driver's clock period and the engine's tempo entry
# (vt+0xB0, LIFTED: every unit's dispatch 375) -- fixed, changing inside the run, and no valid tempo
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 33,34 --on 0.55 --off 2.0 --secs 2.4 \
        --tempo '120;95.5@0,140@1.2;x@0,200@0.7,x@1.5'
python3 "$HERE/jx_product_gate.py" --tooth-tempo --rates 48000 --patches 34 --on 0.55 --off 2.0 --secs 2.4 --tempo '95.5@0,140@1.2'
# (JX-26c) A HOST-RATE CHANGE ON THE RUNNING INSTANCE: setActive(false), setupProcessing(rate), setActive(true) --
# identity, converters, silence and back, keys held; a setActive at one rate with the arpeggiator running; the
# engine-rate settings 2 and automatic; tooth: the port's setActive dropped
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0 --on 0.55 --off 3.2 --secs 3.4 \
        --rerate '44100@60,96000@120,88200@180,22050@240,48000@290'
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 34 --poly 1 --on 0.55 --secs 2.4 \
        --rerate '48000@100;44100@100' --state 'r2@0;r5@0'
python3 "$HERE/jx_product_gate.py" --tooth-rerate --rates 48000 --patches 0 --on 0.55 --off 3.2 --secs 3.4 \
        --rerate '44100@60,96000@120,88200@180,22050@240,48000@290'
# THE VOICE COUNT changed while notes sound (the DAW state's 0x0FFFC00E: 4, 8, 3, 2), seeded polyphony
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0,34 --poly 1,2 --on 0.55 --secs 2.4 \
        --state 's0FFFC00E=4@0.8,s0FFFC00E=8@1.2,s0FFFC00E=3@1.6,s0FFFC00E=2@2.0'
# THE WRAPPER'S VELOCITY RULES: velocity 0 (a note-off at 64), the edges, MIDI channels 1 and 10; and after a
# setState of velSense 0 (not in the state list: nothing changes)
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0,5 --vel --on 0.55 --secs 1.8
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0 --vel --on 0.55 --secs 1.8 --state 's0FFFC00D=0@0.2'
# THE JUNO-60's OTHER HOST RATES (rate_sweep_gate.py's 18). The render object's table (src/conv_tables.h) holds nine
# host rates: 11025 22050 44100 48000 88200 96000 176400 192000 384000. Outside it, and at 11025 / 22050 (kind-2
# entries; EXECUTED 2026-10-11: the plugin's process() is silent 3 s after a key), silent -- both:
python3 "$HERE/jx_product_gate.py" --rates 8000,11025,16000,22050,32000,37800,47999,50000,64000,96001,352800 \
        --patches 0 --on 0.55 --secs 1.0 --expect-silent
# ... and at 176400 / 384000 the plugin sounds (EXECUTED): every sample equal
python3 "$HERE/jx_product_gate.py" --rates 176400,384000 --patches 0 --on 0.55 --secs 1.0
# EVERY FACTORY PATCH through process() (the JUNO-60's bank_product_gate), each with TEMPO SYNC engaged and
# released under the held note at a host tempo (script_ab's A5)
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0-63 --on 0.55 --off 1.4 --secs 1.6 \
        --set '60006A=1@0.8,60006A=0@1.2' --tempo '140@0'
# THE DAW STATE through process() (JX-17): seeded setState payloads between blocks; THE ENGINE-RATE SETTING (JX-15) on
# the running engine (setSampleRate, LIFTED) and before the first block -- the plugin switches the rate BEFORE
# initialize's records (JX-15b: the guest image holds none, jx3p_product_init queues them)
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0 --poly 1 --on 0.55 --secs 2.0 \
        --state '2@0.3,3@1.2;r2@0.8;r3@0.8,r0@1.4;5@0,6@0.9;r2@0;r3@0;r1@0;r0@0;r4@0'
python3 "$HERE/jx_product_gate.py" --rates 44100 --patches 34 --poly 1 --on 0.55 --secs 2.0 --state 'r3@0;r2@0;r1@0.6'
python3 "$HERE/jx_product_gate.py" --rates 48000 --patches 0 --on 0.55 --secs 1.0 --state 'r6@0' --expect-silent  # a setting past the rates
python3 "$HERE/jx_product_gate.py" --tooth-state --rates 48000 --patches 0 --poly 1 --on 0.55 --secs 2.0 --state '2@0.3;r2@0'
echo "=== JX GATE 3e: THE PARAMETER SYSTEM, LIFTED (the plugin's host entry vs the lifted C twin, the whole heap; JX-11) ==="
# the engine running (a patch, a key held, 2048 samples); the plugin's host entry 0x3F9A30 and its lifted twin
# (jx_lift.py: the JP8 lifter on the JX binary, the oracle's dynamic reach) take the same calls; every return
# value and the whole heap compared
python3 "$HERE/jx_lift_gate.py" --relift                          # warm loads of 5, 34, 40, 62 onto patch 0
python3 "$HERE/jx_lift_gate.py" --base 34 --loads 0,61,50         # ... onto the arpeggiator patch
python3 "$HERE/jx_lift_gate.py" --loads sweep                     # every id x 13 values, a heap checkpoint per id
python3 "$HERE/jx_lift_gate.py" --loads modes                     # every patch at every effect type (records 65, 67)
python3 "$HERE/jx_lift_gate.py" --loads settings                  # the host settings 0x0FFFC000..1F (quality among them)
python3 "$HERE/jx_lift_gate.py" --loads 5 --tooth 35D29F          # one multiply made a divide: must be seen
# the render driver's kind-0 targets (JX-12): CC, bend, the empty entries and the note entries, a heap checkpoint
# after every call
python3 "$HERE/jx_lift_gate.py" --loads ctl
python3 "$HERE/jx_lift_gate.py" --base 34 --loads ctl
python3 "$HERE/jx_lift_gate.py" --loads ctl --tooth-skip 86         # a sustain release dropped: must be seen
# the note entries under every assign mode, legato, portamento and ARPEGGIO setting; the clock tick under all 19
# step modes (JX-12b), a heap checkpoint after every script step
python3 "$HERE/jx_lift_gate.py" --loads notes
python3 "$HERE/jx_lift_gate.py" --base 34 --loads notes
python3 "$HERE/jx_lift_gate.py" --base 34 --loads tick
python3 "$HERE/jx_lift_gate.py" --loads notes --tooth-skip 148      # a legato note-on dropped: must be seen
python3 "$HERE/jx_lift_gate.py" --base 34 --loads tick --tooth-skip 1132   # one tick of step mode 7 dropped
# the tempo entry under every effect mode (JX-8), setSampleRate on the running engine (JX-15), and a FRESH instance's
# first block -- the rate switch the setting asks for, initialize's records, the patch load (JX-15b) -- at the
# product's 96 kHz engine and the 44.1 kHz one
python3 "$HERE/jx_lift_gate.py" --loads tempo
python3 "$HERE/jx_lift_gate.py" --base 34 --loads tempo
python3 "$HERE/jx_lift_gate.py" --loads rate
python3 "$HERE/jx_lift_gate.py" --base 34 --loads rate
for b in boot boot44 boot88 boot31 bootat44; do python3 "$HERE/jx_lift_gate.py" --loads $b; done
python3 "$HERE/jx_lift_gate.py" --base 34 --loads boot48
python3 "$HERE/jx_lift_gate.py" --base 34 --loads boot32
python3 "$HERE/jx_lift_gate.py" --loads tempo --tooth-skip 152      # a tempo call dropped: must be seen
python3 "$HERE/jx_lift_gate.py" --loads rate --tooth-skip 12        # a setSampleRate dropped: must be seen
python3 "$HERE/jx_lift_gate.py" --loads boot --tooth-skip 164       # initialize's writePatch dropped: must be seen
# (JX-26b) the JUNO-60's exhaustive, random-state and note x velocity spaces through the lifted entries: a DIGEST of
# every heap page each call wrote, the whole heap after each id / set; each reference made once, its tooth on it
python3 "$HERE/jx_lift_gate.py" --tooth-skip 80                     # the warm chain: a heap checkpoint per patch
python3 "$HERE/jx_lift_gate.py" --loads random --keep
python3 "$HERE/jx_lift_gate.py" --loads random --tooth-skip w
python3 "$HERE/jx_lift_gate.py" --base 34 --loads random2
python3 "$HERE/jx_lift_gate.py" --loads notevel --keep
python3 "$HERE/jx_lift_gate.py" --loads notevel --tooth-skip w
python3 "$HERE/jx_lift_gate.py" --loads exhaustive --keep
python3 "$HERE/jx_lift_gate.py" --loads exhaustive --tooth-skip w
python3 "$HERE/jx_lift_gate.py" --loads fxmodes --keep
python3 "$HERE/jx_lift_gate.py" --loads fxmodes --tooth-skip w
python3 "$HERE/jx_lift_gate.py" --base 34 --loads fxmodes
echo "=== JX GATE 3f: THE DAW STATE, THE UI TIMER, THE PATCH BROWSER (JX-16, JX-17) ==="
# the tables from the booted plugin again (Unicorn, each its own process) and the committed ones equal to them
python3 "$HERE/jx_state_census.py" >/dev/null
python3 "$HERE/jx_model_census.py" >/dev/null                     # the editor's set (JX-18)
python3 "$HERE/jx_gen_state_tables.py" --check
python3 "$HERE/jx_patch_census.py" >/dev/null
python3 "$HERE/jx_gen_patch_tables.py" --check
# getState / setState, the CC map, the UI timer's drain, KEY HOLD, MIDI learn, the editor's set and the host's
# round trip: every save, queued record and host edit
python3 "$HERE/jx_state_gate.py"
python3 "$HERE/jx_state_gate.py" --mutants
# the patch browser's load of any record (the factory bank, random bytes, a bank file): records, saves, samples
python3 "$HERE/jx_patch_gate.py"
python3 "$HERE/jx_patch_gate.py" --tooth --chains 0,1
echo "=== JX GATE 3h: THE EDITOR'S LOGIC (zoom, meters, the record image, the patch window: JX-22, JX-24, JX-25) ==="
# the plugin's editor attached under the oracle (its GUI from jx3p/truth/Script.xml, blank images): every fit its
# windows' getter computes on 16 screens, both zooms and the engine records after every step
python3 "$HERE/jx_zoom_fit_gate.py" --ref
python3 "$HERE/jx_zoom_fit_gate.py" --port
python3 "$HERE/jx_zoom_fit_gate.py" --port-tooth
# the meters: the engine's peaks (the JX's own loop), the read, the tick and the draw on edge inputs, and the
# meters read in the running plugin through process()
python3 "$HERE/jx_meter_gate.py"
python3 "$HERE/jx_meter_gate.py" --tooth --reuse
# the model's record image (JX-24): the plugin's serializer after the boot, 738 sets, loads and setStates; the
# committed boot image equal to the one the plugin makes now; the port's image after every step
python3 "$HERE/jx_record_census.py" >/dev/null
python3 "$HERE/jx_gen_record_tables.py" --check
python3 "$HERE/jx_record_gate.py"
python3 "$HERE/jx_record_gate.py" --tooth
# the patch window (JX-24): the JUNO-60's patch manager gate on the JX plugin's own manager (jx_pm_emu.py) and the
# port (gui/juno_pm.c on the JX bridge); its teeth are the JUNO's PM_TOOTH set
rm -f "$REPO"/scratchpad/jx_patch_manager_ref2_*.pkl     # every reference made from the plugin in this run
for sp in 9:40 1:200 5:200 100:150; do
  python3 "$HERE/jx_patch_manager_gate.py" --seed ${sp%%:*} --steps ${sp##*:} | grep -v '^REACH'
done
# the JUNO's teeth (gui/juno_pm.c PM_TOOTH), each on a seed where it bites; 18 and 19 are the bank name control's
# presses (its button is the art's: SCOPE_AUDIT row 20) and cannot bite here
for ts in 1:9:40 2:1:200 3:9:40 4:1:200 5:1:200 6:9:40 7:9:40 8:100:150 9:9:40 10:9:40 11:9:40 12:9:40 13:9:40 \
          14:9:40 15:9:40 16:1:200 17:9:40; do
  t=${ts%%:*}; r=${ts#*:}
  python3 "$HERE/jx_patch_manager_gate.py" --seed ${r%%:*} --steps ${r##*:} --tooth $t | tail -1
done
echo "=== JX GATE 3i: SEEDS, NaN, RAMPS, TABLES (the JUNO-60's gate classes the JX lacked: docs/GATE_PARITY.tsv, JX-26e) ==="
# the seeded fuzz of the render (patch x rate x warm x notes), its tooth a slip in a voice helper every voice runs
sh "$HERE/fuzz_gate.sh" 0 24
sh "$HERE/fuzz_gate.sh" --tooth 0 4
# a NaN in live DSP cells -- moved ones and read-only parameters, the chorus clamp's inputs always -- every sample and
# unit state; the tooth puts the decompile's ordered compare back at the clamp
python3 "$HERE/jx_nan_ab.py" --seeds 1,2 --cells 16
python3 "$HERE/jx_nan_ab.py" --tooth --seeds 1 --cells 4
# EVERY compare and min / max of the two transcribed render functions mapped to the plugin's own instruction by
# execution (64 patches and the variants no patch holds, key down and up): a NaN reads TRUE for < <= after comiss,
# minss returns its second operand -- 0 sites may be graded wrong (playbook 219); the tooth plants the decompiler's
# form back at every site written in the machine's
python3 "$REPO/tools/verify/nan_sites.py" --port-of jx --func voice --patches 0-63 --frames 256 --release 512 --variants modes
python3 "$REPO/tools/verify/nan_sites.py" --port-of jx --func master --patches 0-63 --frames 256 --release 512 --variants fx
python3 "$REPO/tools/verify/nan_sites.py" --port-of jx --func voice --patches 5,34 --frames 256 --release 512 --tooth
# the product's ramp sweep and slot tick (jx_bridge.c) on random list shapes; the tooth advances the retire cursor
sh "$HERE/ramp_walk_gate.sh" 400 "1 2 3 4 5"
sh "$HERE/ramp_walk_gate.sh" --tooth 200 "1 2"
# the engine-rate setting table: the committed header == the booted plugin's; the render object's tables == the
# JUNO-60's (src/juno_conv.c), its tooth one coefficient bit
python3 "$HERE/jx_conv_tables.py" --check
python3 "$HERE/jx_conv_tables.py" --tooth
echo "=== JX GATE 3g: THE MUTATION REACH (docs/PORT_COMPLETENESS_CHARTER.md section 4) ==="
# one plausible slip per part of the port, in lines that run (gcov), the library rebuilt, one fast gate on the
# mutated tree: every mutation must be KILLED. It edits the tree it runs in (one file at a time, restored):
# run make verify-jx3p from a snapshot (tools/snap_tree.sh)
python3 "$HERE/jx_mutation_gate.py"
echo "=== JX GATE 4/5: LISTEN PROOFS (oracle + C twin, dry + master) ==="
python3 "$HERE/jx_listen.py" 0 48,60,72 2>/dev/null
python3 "$HERE/jx_listen.py" 5 48,60,72 --master 2>/dev/null
python3 "$HERE/jx_listen_c.py" "$REPO/build/jx_full_ab/libjx3p.so" 0,20,49,35 48,60,72
python3 "$HERE/jx_listen_c.py" "$REPO/build/jx_full_ab/libjx3p.so" 5,20 48,60,72 --master
echo "=== JX GATE 5/5: THE DELIVERED WEB ENGINE (WASM == native on the page's product-path calls, playbook 196) ==="
if command -v node >/dev/null 2>&1; then
  python3 "$HERE/jx_wasm_check.py" --patches "$(seq -s, 0 63)"   # 3 host rates, events inside blocks
  python3 "$HERE/jx_wasm_check.py" --tooth
  node "$HERE/jx_page_check.mjs"                                 # the page itself, headless Chromium
  node "$HERE/jx_page_check.mjs" --tooth keys
  node "$HERE/jx_page_check.mjs" --tooth data
else
  echo "[jx verify] FAIL -- no node: the delivered WASM cannot be graded"; exit 1
fi
echo "=== JX GATE 6: THE LEDGERS (every file's origin and proof; every JUNO gate class's JX twin) ==="
python3 "$HERE/jx_provenance.py"
python3 "$HERE/jx_provenance.py" --self-test
python3 "$REPO/tools/verify/gate_parity.py"
python3 "$REPO/tools/verify/gate_parity.py" --self-test
echo "[jx verify] GREEN -- recall 64/64 + render 64/64 x $(echo $RATES | wc -w) rates, all EXACTLY 0; the clock and every step mode == the plugin's; process() == the product path at 3 host rates; the web engine == native"
