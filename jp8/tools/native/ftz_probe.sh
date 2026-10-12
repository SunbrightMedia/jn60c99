#!/bin/sh
# ftz_probe.sh -- MEASURES what the oracle's missing FTZ could hide (scope row 23). The plugin runs process() at
# MXCSR FTZ + DAZ (its ScopedNoDenormals); a PC flushes a denormal RESULT there, Unicorn 2.1.4 never does. The render
# CLI is built three times from the committed lift with software floats and the probe header (ftz_probe_src.py: a
# counter of the denormal results made while the guest's FTZ is on, and the guest image + heap dumped after the drive):
#   pc       JP8_SOFTFP=2                            the PC's rules: DAZ on inputs, FTZ on results
#   oracle   JP8_SOFTFP=1                            Unicorn's rules: DAZ on inputs, a denormal result kept
#   noflush  JP8_SOFTFP=2 -DJP8_SOFTFP_TOOTH_NOFLUSH  THE TOOTH: neither -- denormals reach the arithmetic
# Each renders the same drive. pc == oracle (every output word, every byte of image + heap after the drive) means the
# flush is UNOBSERVABLE on this drive: every denormal result is read as zero under DAZ or overwritten. The tooth must
# differ (sound or memory), or the comparison sees nothing.
#   sh jp8/tools/native/ftz_probe.sh <patch> <in.mid> [rate=48000] [tail seconds=4] [outdir=build/jp8_ftz]
# (three builds of ~3.5 min, then ~5 s of CPU per second of audio each: software floats are slow.)
# exit 0 = pc == oracle and the tooth bites; 1 = the flush is observable on this drive (the report says where).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../../.." && pwd)"
P="$1"; MID="$2"; R="${3:-48000}"; TAIL="${4:-4}"; OUT="${5:-$REPO/build/jp8_ftz}"
[ -n "$P" ] && [ -f "$MID" ] || { echo "usage: ftz_probe.sh <patch> <in.mid> [rate] [tail] [outdir]"; exit 2; }
mkdir -p "$OUT"
python3 "$HERE/ftz_probe_src.py" "$OUT/src"
F="-std=c99 -ffp-contract=off -fno-strict-aliasing -fwrapv -DJP8_RELOC -DJP8_FLAT -DJP8_GS_BASE=0x580000000ULL"
F="$F -I$REPO/jp8/src -O2 -DJP8_RELOC_CHECK=0 -DJP8_MQ="
python3 "$REPO/jp8/tools/jp8_fast.py" "$REPO/jp8/src/jp8_host_lift.c" "$OUT/lift_fast.c" > /dev/null
python3 "$REPO/jp8/tools/jp8_xlane.py" "$OUT/lift_fast.c" "$OUT/lift_xl.c" > /dev/null
build() {   # build <name> <flags...>: the lift's folder holds the probe header, so the lift sees it
    n="$1"; shift; mkdir -p "$OUT/$n"
    cp "$OUT/src/jp8_cpu.h" "$OUT/$n/jp8_cpu.h"; cp "$OUT/lift_xl.c" "$OUT/$n/lift_xl.c"
    cc $F "$@" -w -c -o "$OUT/$n/lift.o" "$OUT/$n/lift_xl.c"
    cc $F "$@" -c -o "$OUT/$n/rt.o" "$REPO/jp8/src/jp8_rt.c"
    cc $F "$@" -c -o "$OUT/$n/host.o" "$REPO/jp8/src/jp8_host.c"
    cc $F "$@" -c -o "$OUT/$n/render.o" "$OUT/src/render_probe.c"
    cc -o "$OUT/$n/jp8_render" "$OUT/$n/render.o" "$OUT/$n/lift.o" "$OUT/$n/rt.o" "$OUT/$n/host.o" -lm
}
build pc -DJP8_SOFTFP=2 & build oracle -DJP8_SOFTFP=1 & build noflush -DJP8_SOFTFP=2 -DJP8_SOFTFP_TOOTH_NOFLUSH & wait
for n in pc oracle noflush; do [ -x "$OUT/$n/jp8_render" ] || { echo "the $n build failed"; exit 2; }; done
gunzip -c "$REPO/jp8/gen/jp8h_template.bin.gz" > "$OUT/jp8h_template.bin"
for n in pc oracle noflush; do
    "$OUT/$n/jp8_render" "$OUT/jp8h_template.bin" "$REPO/jp8/truth/1_Preset.bin" "$P" "$MID" "$OUT/$n.wav" "$R" "$TAIL" > "$OUT/$n.log" 2>&1 &
done
wait
for n in pc oracle noflush; do grep -q FTZPROBE "$OUT/$n.log" || { tail -n 3 "$OUT/$n.log"; echo "the $n render failed"; exit 2; }; done
python3 - "$OUT" "$P" "$R" <<'EOF'
import sys, re
out, patch, rate = sys.argv[1], sys.argv[2], sys.argv[3]
def words(p, skip):
    b = open(p, 'rb').read()[skip:]
    return memoryview(b).cast('I') if len(b) % 4 == 0 else None
rep = {}
for n in ('pc', 'oracle', 'noflush'):
    m = re.search(r'FTZPROBE denormal results under the guest FTZ: (\d+) \(\+(\d+) min-rounding\); first in block (-?\d+)',
                  open('%s/%s.log' % (out, n)).read())
    rep[n] = tuple(int(x) for x in m.groups())
    print('%-8s %d denormal results under the guest FTZ (+%d min-rounding), the first in block %d' % ((n,) + rep[n]))
def diff(a, b, what):
    wa, wb = words('%s/%s' % (out, a), what[1]), words('%s/%s' % (out, b), what[1])
    if len(wa) != len(wb): return 'sizes differ (%d / %d words)' % (len(wa), len(wb))
    d = [i for i in range(len(wa)) if wa[i] != wb[i]] if bytes(wa) != bytes(wb) else []
    return len(d), (d[0] if d else None), (wa[d[0]] if d else None), (wb[d[0]] if d else None)
res = {}
for x, y in (('pc', 'oracle'), ('pc', 'noflush')):
    s = diff(x + '.wav', y + '.wav', ('wav', 44)); m = diff(x + '.wav.mem', y + '.wav.mem', ('mem', 0))
    res[(x, y)] = (s, m)
    print('%s vs %s: sound %s words differ; memory (image + heap) %s words differ%s' % (x, y, s[0], m[0],
          '' if not m[0] else ' -- the first at word %d: %08x / %08x' % (m[1], m[2], m[3])))
pc_or = res[('pc', 'oracle')]; tooth = res[('pc', 'noflush')]
bites = tooth[0][0] or tooth[1][0]
print('the tooth (no DAZ, no FTZ) %s' % ('bites: the comparison sees denormals that reach the arithmetic' if bites else
      'DID NOT BITE -- the comparison sees nothing'))
if not bites: sys.exit(2)
if pc_or[0][0] or pc_or[1][0]:
    print('FTZ PROBE (patch %s at %s Hz): THE FLUSH IS OBSERVABLE on this drive -- the PC and the oracle differ' % (patch, rate)); sys.exit(1)
print('FTZ PROBE (patch %s at %s Hz): %d denormal results under FTZ, and the flush is UNOBSERVABLE: the PC\'s rules and '
      'the oracle\'s give the same sound and the same memory' % (patch, rate, rep['pc'][0]))
EOF
