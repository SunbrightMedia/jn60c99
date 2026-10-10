#!/bin/bash
# reproduce.sh [COMMIT] [DIR] -- every JUNO-60 C99 result rebuilt and re-verified from a FRESH CLONE
# (task #62, docs/REPRODUCE.md). Nothing is carried over: the clone has no scratchpad, so every gate
# reference is rebuilt from the plugin (truth/, checksummed); the user's banks are the one local input
# (linked, checked against tools/repro/userbanks.sha256, never committed).
#
# Stages, each logged to DIR/logs/STAGE.log, each with its exit code and time in DIR/REPORT:
#   clone        git clone of this repository at COMMIT (default HEAD) into DIR (default: next to this
#                tree, so Node finds the same node_modules; else `npm ci` runs in the clone); the Pi's
#                Circle submodule from this tree's copy when it has one (the pinned commit, offline)
#   inputs       truth/ checksums (tools/verify/truth.py) + the user's banks against their manifest
#   doctor       tools/repro/doctor.sh: every required tool
#   test static verify native webapp engineb     the make targets (verify: every reference rebuilt,
#                its teeth, the early proofs; static: the ledger census)
#   regen        tools/repro/regen_check.py: every generated table rebuilt from the plugin, byte-equal
#   determinism  libjuno.so, juno.dll, the WASM and JUNO-60.exe built twice: equal; the committed
#                juno.dll and WASM equal to the build
#   pi           the Pi track's gate (pi/run_qemu.sh) when its toolchain is present (doctor: opt)
#   esp32        tools/repro/esp32_check.sh when ESP-IDF is present (doctor: opt): the retired device
#                JUNO gate and its O1-O3 suites at its own commit; the firmware builds with the pinned IDF
#                and the MINISYNTH self-test in QEMU; reproducible images equal from two paths. Without
#                the IDF: stage device, the history part alone (host cc), and esp32 reported skipped
#   tree         no committed file changed by any stage above
# Exit 0 only when every stage passed (a skipped optional stage is reported, not failed).
#
# reproduce.sh --resume [COMMIT] [DIR] -- continue a run that died (a container restart kills every
# job: verify_a35 and repro2 died so): the same clone, which must be at COMMIT (default: the clone's
# own); a stage that passed is kept, every other stage runs again; inputs and doctor always run again
# (the container may have changed); REPORT says when the run resumed.
#
# Long: about 10 hours on 4 cores. Run it as a job: sh tools/run_job.sh repro bash tools/repro/reproduce.sh
set -u
RESUME=0
[ "${1:-}" = "--resume" ] && { RESUME=1; shift; }
SRC=$(cd "$(dirname "$0")/../.." && pwd)
DIR=${2:-$(dirname "$SRC")/juno60_repro}
BANKS=${JUNO_USERBANKS:-$SRC/scratchpad/userbanks}
LOGS="$DIR.logs"; REPORT="$LOGS/REPORT"
if [ $RESUME = 1 ]; then
  [ -d "$DIR/.git" ] && [ -f "$REPORT" ] || { echo "resume: no earlier run in $DIR (or no $REPORT)"; exit 2; }
  COMMIT=$(git -C "$DIR" rev-parse HEAD)
  if [ -n "${1:-}" ] && [ "$(git -C "$SRC" rev-parse "$1^{commit}" 2>/dev/null)" != "$COMMIT" ]; then
    echo "resume: $DIR is at $COMMIT, not $1"; exit 2
  fi
  grep -E '^([a-z0-9]+ +exit 0 |resumed )' "$REPORT" | grep -vE '^(inputs|doctor) ' > "$REPORT.kept"
  mv "$REPORT.kept" "$REPORT"
  echo "resumed      $(date -u +%FT%TZ) at $COMMIT: $(grep -c ' exit 0 ' "$REPORT") stage(s) kept" | tee -a "$REPORT"
else
  COMMIT=${1:-$(git -C "$SRC" rev-parse HEAD)}
  rm -rf "$DIR"
  mkdir -p "$LOGS" || exit 2
  : > "$REPORT"
fi
fail=0

stage() {   # stage NAME CMD... : run, log, record
  local name=$1; shift
  if [ $RESUME = 1 ] && [ "$name" != inputs ] && [ "$name" != doctor ] && grep -qE "^$name +exit 0 " "$REPORT"; then
    echo "=== STAGE $name: passed before the resume (kept)"
    return 0
  fi
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
skip() {   # skip NAME WHY (a stage that passed before a resume stays kept)
  if [ $RESUME = 1 ] && grep -qE "^$1 +exit 0 " "$REPORT"; then echo "=== STAGE $1: passed before the resume (kept)"; return 0; fi
  printf '%-12s SKIPPED     (%s)\n' "$1" "$2" | tee -a "$REPORT"
}

stage clone sh -c "git clone -q '$SRC' '$DIR' && cd '$DIR' && git checkout -q --detach '$COMMIT' || exit 1; \
  if [ -e '$SRC/pi/circle/.git' ]; then git config submodule.pi/circle.url '$SRC/pi/circle'; fi; \
  git -c protocol.file.allow=always submodule update --init -q pi/circle 2>/dev/null; \
  echo commit \$(git rev-parse HEAD) tree \$(git rev-parse HEAD^{tree}) \
       circle \$([ -f pi/circle/Rules.mk ] && git -C pi/circle rev-parse --short HEAD || echo absent)" || { cat "$REPORT"; exit 1; }
cd "$DIR" || exit 1
mkdir -p scratchpad && ln -sfn "$BANKS" scratchpad/userbanks
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
else                       # the device track's own proofs need only the host compiler
  stage device env ESP32_CHECK_ONLY=history bash tools/repro/esp32_check.sh
  skip esp32 "the firmware builds: no ESP-IDF (CLAUDE.md BUILD & GIT: clone v6.1 + ./install.sh esp32s3)"
fi
stage tree sh -c "git status --porcelain --untracked-files=no | tee /dev/stderr | wc -l | grep -qx 0"
echo
echo "=== REPORT (commit $COMMIT, $(date -u +%FT%TZ))"
cat "$REPORT"
echo "reproduce: $([ $fail = 0 ] && echo GREEN || echo RED)"
exit $fail
