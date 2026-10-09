#!/bin/bash
# reproduce.sh [COMMIT] [DIR] -- every JUNO-60 C99 result rebuilt and re-verified from a FRESH CLONE
# (task #62, docs/REPRODUCE.md). Nothing is carried over: the clone has no scratchpad, so every gate
# reference is rebuilt from the plugin (truth/, checksummed); the user's banks are the one local input
# (linked, checked against tools/repro/userbanks.sha256, never committed).
#
# Stages, each logged to DIR/logs/STAGE.log, each with its exit code and time in DIR/REPORT:
#   clone        git clone of this repository at COMMIT (default HEAD) into DIR (default under $HOME,
#                so Node finds a node_modules there; else `npm ci` runs in the clone)
#   inputs       truth/ checksums (tools/verify/truth.py) + the user's banks against their manifest
#   doctor       tools/repro/doctor.sh: every required tool
#   test static verify native webapp engineb     the make targets (verify: every reference rebuilt,
#                its teeth, the early proofs; static: the ledger census)
#   regen        tools/repro/regen_check.py: every generated table rebuilt from the plugin, byte-equal
#   determinism  libjuno.so, juno.dll, the WASM and JUNO-60.exe built twice: equal; the committed
#                juno.dll and WASM equal to the build
#   pi           the Pi track's gate (pi/run_qemu.sh) when its toolchain is present (doctor: opt)
#   esp32        tools/repro/esp32_check.sh when ESP-IDF is present (doctor: opt): the retired device
#                JUNO gate at its own commit; the firmware builds with the pinned IDF and the MINISYNTH
#                self-test in QEMU; reproducible images equal from two paths
#   tree         no committed file changed by any stage above
# Exit 0 only when every stage passed (a skipped optional stage is reported, not failed).
#
# Long: about 10 hours on 4 cores. Run it as a job: sh tools/run_job.sh repro bash tools/repro/reproduce.sh
set -u
SRC=$(cd "$(dirname "$0")/../.." && pwd)
COMMIT=${1:-$(git -C "$SRC" rev-parse HEAD)}
DIR=${2:-$HOME/juno60_repro}
BANKS=${JUNO_USERBANKS:-$SRC/scratchpad/userbanks}
rm -rf "$DIR"
mkdir -p "$DIR.logs" || exit 2
LOGS="$DIR.logs"; REPORT="$LOGS/REPORT"
: > "$REPORT"
fail=0

stage() {   # stage NAME CMD... : run, log, record
  local name=$1; shift
  local t0=$(date +%s)
  echo "=== STAGE $name ($(date -u +%FT%TZ))"
  ( "$@" ) > "$LOGS/$name.log" 2>&1
  local r=$?
  local dt=$(( $(date +%s) - t0 ))
  printf '%-12s exit %-3s %6d s\n' "$name" "$r" "$dt" | tee -a "$REPORT"
  tail -3 "$LOGS/$name.log" | sed 's/^/    /'
  [ $r = 0 ] || fail=1
  return $r
}
skip() { printf '%-12s SKIPPED     (%s)\n' "$1" "$2" | tee -a "$REPORT"; }

stage clone sh -c "git clone -q '$SRC' '$DIR' && cd '$DIR' && git checkout -q --detach '$COMMIT' && \
  git submodule update --init -q pi/circle 2>/dev/null; echo commit \$(git rev-parse HEAD) tree \$(git rev-parse HEAD^{tree})" || { cat "$REPORT"; exit 1; }
cd "$DIR" || exit 1
mkdir -p scratchpad && ln -s "$BANKS" scratchpad/userbanks
[ -f /home/user/emsdk/emsdk_env.sh ] && source /home/user/emsdk/emsdk_env.sh > /dev/null 2>&1
node -e "import('playwright-core').then(()=>process.exit(0),()=>process.exit(1))" --input-type=module 2>/dev/null || npm ci --ignore-scripts > "$LOGS/npm.log" 2>&1

stage inputs sh -c "python3 tools/verify/truth.py && grep -v '^#' tools/repro/userbanks.sha256 | sha256sum -c --quiet && echo 'the user banks: 11 equal to the manifest'"
stage doctor bash tools/repro/doctor.sh || { cat "$REPORT"; exit 1; }
for t in test static verify native webapp engineb; do stage "$t" make "$t"; done
stage regen python3 tools/repro/regen_check.py
stage determinism bash tools/repro/determinism.sh
if command -v qemu-system-aarch64 > /dev/null && command -v aarch64-linux-gnu-g++ > /dev/null && [ -f pi/circle/Rules.mk ]; then
  stage pi sh pi/run_qemu.sh raspi3ap
else
  skip pi "no aarch64 cross g++ / qemu-system-aarch64 / Circle"
fi
if [ -f "${IDF_PATH:-/home/user/esp-idf}/export.sh" ]; then
  stage esp32 bash tools/repro/esp32_check.sh
else
  skip esp32 "no ESP-IDF (CLAUDE.md BUILD & GIT: clone v6.1 + ./install.sh esp32s3)"
fi
stage tree sh -c "git status --porcelain --untracked-files=no | tee /dev/stderr | wc -l | grep -qx 0"
echo
echo "=== REPORT (commit $COMMIT, $(date -u +%FT%TZ))"
cat "$REPORT"
echo "reproduce: $([ $fail = 0 ] && echo GREEN || echo RED)"
exit $fail
