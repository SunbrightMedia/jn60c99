#!/bin/bash
# esp32_check.sh -- the device firmware rebuilt from this tree with the pinned ESP-IDF (task #62,
# docs/REPRODUCE.md). The pin: esp32s3/dependencies.lock (idf 6.1.0); a different IDF is refused.
# Nothing committed is touched: every build goes to a temporary directory with its own sdkconfig
# (a copy of the committed one, or generated from sdkconfig.defaults as the recipe does), and the
# end checks that esp32s3/ is unchanged.
#   chain_gate  the retired device JUNO recall's own proof at its last commit (8cb8e141, a worktree):
#               tools/engineb/chain_gate.sh (host cc) -- the answer key esp32s3/main/gen/ regenerated
#               equal to that commit's, and the CHAIN4 sum-law gate with its teeth
#   default     esp32s3/ as `idf.py build` builds it: main/juno_s3_main.c, the fork evaluator vectors
#               and the cycle regions (esp32s3/flash/README.md)
#   chain4      the last JUNO images (esp32s3/flash/chain4/pos1-4): tools/engineb/build_chain4.sh's
#               recipe, out of tree (CHAIN4_BUILD)
#   knobtest    esp32s3/knobtest (the user's knob and OLED test, no synth; flash/knobtest)
#   minisynth   esp32s3/midi_square (the bench synth with the JUNO FX stage, the user's build of
#               2026-10-07), and its emulator build (-DMSQ_QEMU, a timer plays the DMA) run in
#               Espressif's QEMU: its boot self-test must print "SELFTEST: PASS"
#   repro x2    esp32s3/ and the MINISYNTH with CONFIG_APP_REPRODUCIBLE_BUILD, each built twice --
#               from this tree and from a copy of it at another path: the same bytes (the app, the
#               bootloader, the partition table), so an image does not depend on where it was built
# What it does not do: rebuild the committed images byte for byte -- they are records of bench runs,
# built with the IDF of their day, with time stamps -- or run anything on a chip (the device's own
# results are its logs: CLAUDE.md SHIP LAW). esp32s3/LISTEN.md's first recipe (no recall) no longer
# builds (its embedded blob predates eb_render_state's growth; stated in docs/REPRODUCE.md).
# usage: bash tools/repro/esp32_check.sh      (ESP-IDF at $IDF_PATH or /home/user/esp-idf, qemu-xtensa
#        from idf_tools.py; exit 1 on any failure)
set -u
R=$(cd "$(dirname "$0")/../.." && pwd)
IDF=${IDF_PATH:-/home/user/esp-idf}
[ -f "$IDF/export.sh" ] || { echo "FAIL no ESP-IDF at $IDF (CLAUDE.md BUILD & GIT: clone v6.1 + ./install.sh esp32s3)"; exit 1; }
export IDF_PYTHON_CHECK_CONSTRAINTS=no
cd "$IDF" && . ./export.sh > /dev/null 2>&1 || { echo "FAIL $IDF/export.sh"; exit 1; }   # it finds IDF_PATH from $PWD
cd "$R/esp32s3" || exit 1
fail=0
want=$(awk '/^  idf:/{f=1} f && /version:/{print $2; exit}' dependencies.lock)
have=$(idf.py --version 2>/dev/null | sed -n 's/^ESP-IDF v\([0-9][0-9.]*\).*/\1/p')
case "$have" in *.*.*) ;; ?*) have=$have.0 ;; esac
if [ "$have" != "$want" ]; then echo "FAIL ESP-IDF $have, the pin is $want (esp32s3/dependencies.lock)"; exit 1; fi
echo "ok   ESP-IDF $have == the pin (esp32s3/dependencies.lock)"
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
# a reproducible image's version: the commit (IDF's default is `git describe` of the checkout, so a
# copy of the tree without .git would stamp another version)
VER=$(git -C "$R" rev-parse --short=12 HEAD)
BEFORE=$(git -C "$R" status --porcelain -- esp32s3)
ONLY=${ESP32_CHECK_ONLY:-}          # e.g. ESP32_CHECK_ONLY=repro: one part (default: every part)
want() { [ -z "$ONLY" ] || [ "$ONLY" = "$1" ]; }
errors() { grep -E "error:|undefined reference|FAILED:" "$1" | head -12; tail -3 "$1"; }

build() {   # build NAME DIR CONFIG(tree|repro|defaults|repro-defaults|qemu) [idf.py -D args]
  local n=$1 dir=$2 cfg=$3; shift 3
  case "$cfg" in
    tree)  cp "$dir/sdkconfig" "$T/$n.sdkconfig" ;;
    repro) sed -e 's/^# CONFIG_APP_REPRODUCIBLE_BUILD is not set$/CONFIG_APP_REPRODUCIBLE_BUILD=y/' \
               -e 's/^# CONFIG_APP_PROJECT_VER_FROM_CONFIG is not set$/CONFIG_APP_PROJECT_VER_FROM_CONFIG=y/' "$dir/sdkconfig" > "$T/$n.sdkconfig"
           echo "CONFIG_APP_PROJECT_VER=\"$VER\"" >> "$T/$n.sdkconfig"
           grep -qx 'CONFIG_APP_REPRODUCIBLE_BUILD=y' "$T/$n.sdkconfig" && grep -qx 'CONFIG_APP_PROJECT_VER_FROM_CONFIG=y' "$T/$n.sdkconfig" \
             || { echo "FAIL $n: no REPRODUCIBLE_BUILD / PROJECT_VER_FROM_CONFIG line to set"; fail=1; return 1; } ;;
    repro-defaults) printf 'CONFIG_APP_REPRODUCIBLE_BUILD=y\nCONFIG_APP_PROJECT_VER_FROM_CONFIG=y\nCONFIG_APP_PROJECT_VER="%s"\n' "$VER" > "$T/repro.defaults"
           set -- -DSDKCONFIG_DEFAULTS="sdkconfig.defaults;$T/repro.defaults" "$@" ;;
    qemu)  set -- -DSDKCONFIG_DEFAULTS="sdkconfig.defaults;sdkconfig.qemu" "$@" ;;
  esac
  local t0=$(date +%s)
  if (cd "$dir" && idf.py -B "$T/$n" -DSDKCONFIG="$T/$n.sdkconfig" "$@" build) > "$T/$n.log" 2>&1; then
    local app=$(ls "$T/$n"/*.bin 2>/dev/null | grep -v -e bootloader -e partition | head -1)
    echo "ok   $n: built in $(( $(date +%s) - t0 )) s, $(basename "$app") $(stat -c %s "$app") bytes (${dir#$R/} $*)"
  else
    echo "FAIL $n: the build failed (${dir#$R/} $*):"; errors "$T/$n.log"; fail=1; return 1
  fi
}
same() {    # same A B: the three images of two builds
  local f
  for f in "$(cd "$T/$1" && ls *.bin | grep -v -e bootloader -e partition | head -1)" bootloader/bootloader.bin partition_table/partition-table.bin; do
    if [ -f "$T/$1/$f" ] && cmp -s "$T/$1/$f" "$T/$2/$f"; then
      echo "ok   $1 = $2: $f, the same bytes ($(sha256sum < "$T/$1/$f" | cut -c1-16))"
    else
      echo "FAIL $1 != $2: $f differs"; fail=1
    fi
  done
}

# THE DEVICE JUNO RECALL'S OWN PROOF, AT ITS OWN COMMIT. That track (CHAIN4, multi-board) was retired
# on 2026-09-23 (CLAUDE.md ONE BOARD); its last commit is DEVICE_JUNO below. There, in a worktree,
# tools/engineb/chain_gate.sh regenerates the device answer key (esp32s3/main/gen/) -- it must equal
# that commit's -- and runs the CHAIN4 sum-law gate with its five teeth (host cc, no IDF). At HEAD the
# trunk has moved on (docs/REPRODUCE.md: the generator reports the compact format one byte short and
# a changed boot image); HEAD's firmware build below proves only that the recall firmware still builds.
if want history; then
DEVICE_JUNO=8cb8e1416aae4b6d902b549b925248e946db2be4
t0=$(date +%s)
if git -C "$R" worktree add -q --detach "$T/hist" "$DEVICE_JUNO" > "$T/chain_gate.log" 2>&1 \
   && sh "$T/hist/tools/engineb/chain_gate.sh" >> "$T/chain_gate.log" 2>&1 && grep -q "CHAIN GATE GREEN" "$T/chain_gate.log"; then
  echo "ok   chain_gate at ${DEVICE_JUNO:0:8} (the device JUNO track's last commit): CHAIN GATE GREEN, its teeth bite ($(( $(date +%s) - t0 )) s)"
  if git -C "$T/hist" diff --quiet -- esp32s3/main/gen; then
    echo "ok   esp32s3/main/gen at ${DEVICE_JUNO:0:8}: the answer key regenerated, the same bytes as that commit"
  else
    echo "FAIL esp32s3/main/gen at ${DEVICE_JUNO:0:8}: the regenerated answer key differs:"; git -C "$T/hist" diff --stat -- esp32s3/main/gen; fail=1
  fi
else
  echo "FAIL chain_gate at ${DEVICE_JUNO:0:8}:"; errors "$T/chain_gate.log"; fail=1
fi
git -C "$R" worktree remove --force "$T/hist" > /dev/null 2>&1; git -C "$R" worktree prune
fi
if want builds; then
build default "$R/esp32s3" tree
t0=$(date +%s)
if CHAIN4_BUILD="$T/chain4" bash "$R/tools/engineb/build_chain4.sh" 1 2 3 4 > "$T/chain4.log" 2>&1; then
  echo "ok   chain4: positions 1-4 built in $(( $(date +%s) - t0 )) s ($(cd "$T/chain4/out" && stat -c '%n %s' pos*/juno_s3.bin | tr '\n' ' '))"
else
  echo "FAIL chain4: tools/engineb/build_chain4.sh 1 2 3 4 failed:"; errors "$T/chain4.log"; fail=1
fi
build knobtest "$R/esp32s3/knobtest" defaults
build minisynth "$R/esp32s3/midi_square" defaults
if build minisynth_qemu "$R/esp32s3/midi_square" qemu -DMSQ_QEMU=1; then
  Q=$(ls /root/.espressif/tools/qemu-xtensa/*/qemu/bin/qemu-system-xtensa 2>/dev/null | head -1)
  if [ -z "$Q" ]; then
    echo "FAIL minisynth self-test: no qemu-system-xtensa (python3 \$IDF_PATH/tools/idf_tools.py install qemu-xtensa)"; fail=1
  else
    (cd "$T/minisynth_qemu" && python -m esptool --chip esp32s3 merge-bin --fill-flash-size 8MB -o "$T/msq_q.bin" @flash_args > /dev/null 2>&1)
    timeout 60 "$Q" -nographic -machine esp32s3 -m 32M -drive file="$T/msq_q.bin",if=mtd,format=raw \
      -serial file:"$T/msq_q.log" -monitor none > /dev/null 2>&1
    grep -E "^SELFTEST" "$T/msq_q.log" | sed 's/^/     /'
    if grep -qx "SELFTEST: PASS" <(tr -d '\r' < "$T/msq_q.log"); then echo "ok   minisynth self-test in QEMU: SELFTEST: PASS"
    else echo "FAIL minisynth self-test in QEMU: no 'SELFTEST: PASS' (log ends:)"; tail -5 "$T/msq_q.log"; fail=1; fi
  fi
fi
fi
if want repro; then
# the same sources at another path (every tracked file the firmware builds read)
mkdir -p "$T/copy"
(cd "$R" && git ls-files -z -- esp32s3 engine_b src tools event | tar --null -T - -cf -) | tar -xf - -C "$T/copy"
build repro1 "$R/esp32s3" repro
build repro2 "$T/copy/esp32s3" repro
same repro1 repro2
build mrepro1 "$R/esp32s3/midi_square" repro-defaults
build mrepro2 "$T/copy/esp32s3/midi_square" repro-defaults
same mrepro1 mrepro2
fi
if [ "$(git -C "$R" status --porcelain -- esp32s3)" != "$BEFORE" ]; then
  echo "FAIL the builds changed esp32s3/:"; git -C "$R" status --porcelain -- esp32s3; fail=1
else
  echo "ok   esp32s3/ unchanged by the builds"
fi
echo "esp32_check: $([ $fail = 0 ] && echo GREEN || echo RED)"
exit $fail
