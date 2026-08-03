#!/bin/bash
# run.sh -- run harness.elf under Espressif QEMU (esp32s3) with icount and
# parse the printed table into per-call / per-sample instruction counts.
#
# Under -icount shift=0 the CCOUNT special register advances once per executed
# instruction, so every figure is 'QEMU-executed instructions', NOT cycles.
set -e
cd "$(dirname "$0")/../../.."          # repo root

QEMU=/tmp/claude-0/-home-user-jn60c99/851980e2-931d-52da-bb74-16fb8562b242/scratchpad/qemu/bin/qemu-system-xtensa
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
cal_calls, cal_tot = reg["cal"]
cal = cal_tot / cal_calls
print("calibration span (empty rsr..rsr): %.2f instr, subtracted per call" % cal)
print()
print("%-12s %9s %14s %10s %6s %14s" %
      ("function", "calls", "instr/call", "(gross)", "/samp", "instr/sample"))
roll = 0.0
for name, rate in RATE.items():
    calls, tot = reg[name]
    gross = tot / calls
    net = gross - cal
    per_sample = net * rate
    roll += per_sample
    print("%-12s %9d %14.1f %10.1f %6d %14.0f" %
          (name, calls, net, gross, rate, per_sample))
print("%-12s %s" % ("", "-" * 55))
print("%-12s %40s %14.0f" % ("ROLL-UP", "", roll))
tcalls, ttot = reg["sample_total"]
print("%-12s %55.0f  (incl. %d measurement spans/sample of harness glue)" %
      ("sample_total", ttot / tcalls, sum(RATE.values()) + 2))
for m in re.finditer(r"SINK (\S+) (0x[0-9a-f]+)( SANITY-FAIL)?", txt):
    if m.group(3):
        print("SANITY FAIL:", m.group(1))
if "=EBQ FAIL=" in txt:
    print("!! SANITY GUARD FIRED -- numbers above are from a (partly) silent"
          " engine, do not report them")
    sys.exit(1)
EOF
