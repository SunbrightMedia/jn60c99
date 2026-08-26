#!/bin/bash
# run.sh -- run harness.elf under Espressif QEMU (esp32s3) with icount and
# parse the printed table into per-call / per-sample instruction counts.
#
# THE COUNTER SCALE. Under -icount shift=0 virtual time advances 1 ns per
# executed instruction, and this machine's CPU clock is modeled at 40 MHz, so
# CCOUNT advances once per 25 INSTRUCTIONS -- not once per instruction, which
# harness.c's own comment claims and which is WRONG. Evidence, both re-checked
# by this script on every run:
#   * the CAL region measures an empty rsr..rsr span at ~0.04 ticks. At one
#     tick per instruction an empty span could not read below 1.
#   * CHECK below compares four branch-light functions against their STATIC
#     instruction counts from the ELF. They agree within call overhead only if
#     the scale is 25.
# If a future QEMU build changes the modeled clock, CHECK goes loud.
set -e
cd "$(dirname "$0")/../../.."          # repo root

# QEMU path: prefer the idf-installed tool (survives scratchpad clearing, which
# is what broke this rig on 2026-08-26 -- the old hardcoded scratchpad path was
# gone and the run.log was three weeks stale). Install with:
#   python3 $IDF_PATH/tools/idf_tools.py install qemu-xtensa
QEMU=${QEMU:-$(ls /root/.espressif/tools/qemu-xtensa/*/qemu/bin/qemu-system-xtensa 2>/dev/null | head -1)}
[ -x "$QEMU" ] || { echo "QEMU NOT FOUND -- run: python3 \$IDF_PATH/tools/idf_tools.py install qemu-xtensa"; exit 2; }
ELF=tools/engineb/qemu/harness.elf
LOG=tools/engineb/qemu/run.log

timeout 570 "$QEMU" -M esp32s3 -nographic \
    -icount shift=0,align=off,sleep=off \
    -kernel "$ELF" > "$LOG" 2>&1 || true

if ! grep -q "=EBQ DONE=" "$LOG"; then
    echo "HARNESS DID NOT COMPLETE -- last output:"
    tail -20 "$LOG"
    exit 1
fi

python3 - "$LOG" <<'EOF'
import sys, re

RATE = {  # calls per sample, 8 voices (the engine's real invocation counts)
    "env": 16, "cvgate": 8, "modcv": 8, "pitch_dbl": 8, "vcf_cv": 8,
    "dco_step4": 8, "decim": 8, "nsvf": 8, "vcf": 8, "vca": 8,
    "noise_lfsr": 1, "chorus": 1, "delay": 1, "reverb": 1,
}
txt = open(sys.argv[1]).read()
reg = {}
for m in re.finditer(r"REGION (\S+) CALLS (\d+) TOT (\d+)", txt):
    reg[m.group(1)] = (int(m.group(2)), int(m.group(3)))
SCALE = 25.0        # CCOUNT ticks -> executed instructions; see the note above
cal_calls, cal_tot = reg["cal"]
cal = cal_tot / cal_calls * SCALE
print("counter scale: %g instructions per CCOUNT tick" % SCALE)
print("calibration span (empty rsr..rsr): %.2f instr, subtracted per call" % cal)
print()
print("%-12s %9s %14s %10s %6s %14s" %
      ("function", "calls", "instr/call", "(gross)", "/samp", "instr/sample"))
roll = 0.0
for name, rate in RATE.items():
    calls, tot = reg[name]
    gross = tot / calls * SCALE
    net = gross - cal
    per_sample = net * rate
    roll += per_sample
    print("%-12s %9d %14.1f %10.1f %6d %14.0f" %
          (name, calls, net, gross, rate, per_sample))
print("%-12s %s" % ("", "-" * 55))
print("%-12s %40s %14.0f" % ("ROLL-UP", "", roll))
tcalls, ttot = reg["sample_total"]
print("%-12s %55.0f  (incl. %d measurement spans/sample of harness glue)" %
      ("sample_total", ttot / tcalls * SCALE, sum(RATE.values()) + 2))

# SCALE CROSS-CHECK: branch-free leaf functions must land within call overhead
# of their static size. If the scale were 1, these would read ~25x too small.
import subprocess, os
elf = "tools/engineb/qemu/harness.elf"
od = subprocess.run(["xtensa-esp32s3-elf-objdump", "-d", elf],
                    capture_output=True, env=dict(os.environ, PATH=os.environ["PATH"]))
static = {}
cur = None
for line in od.stdout.decode(errors="replace").split("\n"):
    m = re.match(r"^[0-9a-f]+ <(\w+)>:", line)
    if m:
        cur = m.group(1); static[cur] = 0; continue
    if cur and re.match(r"^\s+[0-9a-f]+:\s", line):
        static[cur] += 1
print()
print("SCALE CHECK -- branch-light leaves: measured vs static ELF size")
for fn, reg_name in (("eb_env_tick", "env"), ("eb_decim_tick", "decim"),
                     ("eb_cvgate", "cvgate"), ("eb_nsvf_tick", "nsvf")):
    if fn not in static:
        continue
    calls, tot = reg[reg_name]
    meas = tot / calls * SCALE - cal
    ok = "ok" if 0.6 * static[fn] <= meas <= 2.5 * static[fn] + 40 else "** OFF **"
    print("  %-16s measured %7.0f   static %5d   %s" % (fn, meas, static[fn], ok))
for m in re.finditer(r"SINK (\S+) (0x[0-9a-f]+)( SANITY-FAIL)?", txt):
    if m.group(3):
        print("SANITY FAIL:", m.group(1))
if "=EBQ FAIL=" in txt:
    print("!! SANITY GUARD FIRED -- numbers above are from a (partly) silent"
          " engine, do not report them")
    sys.exit(1)
EOF
