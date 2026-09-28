#!/bin/sh
# jp8_lift_gate.sh -- the lifted-code differential gate (PORT_PIPELINE step 5), on DRIVE2 (S3_STATUS D7: factory-built
# HOST, HOSTPARAM recall, no snap). JP8_LIFT_LAYER=render (layer 1: VOICE_WRAP x8 + MASTER_WRAP per sample + NOTEON/NOTEOFF),
# recall (layer 2: a recall through HOSTPARAM + the walker) or boot (layer 3: factory, BUILD, SETSR, host_init, recall).
# 1. lift the binary (jp8_lift.py) and build; 2. oracle replay (Unicorn, process A) writes dumps + words + the oracle's own
# recorded calls; 3. C twin (process B) replays the same calls on the same addresses and compares EXACTLY 0; 4. the tooth:
# the same lift with ONE addss turned into subss (jp8_lift_seq.TOOTH per layer) must FAIL.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(cd "$HERE/../.." && pwd)"; OUT="$REPO/build/jp8_lift"; mkdir -p "$OUT"
DYN="$OUT/dynreach_d2.json"; DYNB="$OUT/dynreach_boot_d2.json"; LAYER="${JP8_LIFT_LAYER:-render}"; REF="$OUT/ref_d2_$LAYER"; export JP8_LIFT_LAYER="$LAYER"
ROOTS=$(python3 -c "import sys; sys.path.insert(0,'$HERE'); import jp8_lift_seq as Q; print(Q.ROOTS)")
TOOTH=$(python3 -c "import sys; sys.path.insert(0,'$HERE'); import jp8_lift_seq as Q; print(Q.TOOTH)")
CFLAGS="-std=gnu99 -O1 -ffp-contract=off -fno-strict-aliasing -fwrapv -w -fPIC -shared -I$REPO/jp8/src"
echo "=== 0. dynamic reach (indirect targets) ==="
[ -f "$DYN" ] || python3 "$HERE/jp8_dynreach.py" "$DYN" 2,63,10,0,24 64 --recall 0
[ -f "$DYNB" ] || python3 "$HERE/jp8_dynreach.py" "$DYNB" 2,63 64 --recall 5 --boot
echo "=== 1. lift + build ==="
python3 "$HERE/jp8_lift.py" "$REPO/jp8/src/jp8_lift.c" $ROOTS --dyn "$DYN" --dyn "$DYNB" --alloc 0x6F5B04 --name all
cc $CFLAGS -o "$OUT/libjp8lift.so" "$REPO/jp8/src/jp8_lift.c" "$REPO/jp8/src/jp8_rt.c" -lm
echo "=== 2. oracle replay (Unicorn) ==="
[ -n "${JP8_LIFT_SKIP_EMU:-}" ] && [ -f "$REF/p02/words.bin" ] || python3 "$HERE/jp8_lift_emu.py" "$REF"
echo "=== 3. C twin ==="
python3 "$HERE/jp8_lift_c.py" "$REF" "$OUT/libjp8lift.so"
echo "=== 4. the tooth ==="
python3 "$HERE/jp8_lift.py" "$OUT/jp8_lift_tooth.c" $ROOTS --dyn "$DYN" --dyn "$DYNB" --alloc 0x6F5B04 --name all --tooth $TOOTH > /dev/null
cc $CFLAGS -o "$OUT/libjp8lift_tooth.so" "$OUT/jp8_lift_tooth.c" "$REPO/jp8/src/jp8_rt.c" -lm
if python3 "$HERE/jp8_lift_c.py" "$REF" "$OUT/libjp8lift_tooth.so" > "$OUT/tooth.log" 2>&1; then
    echo "*** THE TOOTH DID NOT BITE ***"; exit 1
fi
echo "tooth bites: $(grep -m1 'oracle .* C ' "$OUT/tooth.log")"
grep "A/B" "$OUT/tooth.log"
echo "JP8 LIFT GATE ($LAYER, drive2) GREEN"
