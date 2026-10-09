#!/bin/bash
# determinism.sh -- the products built twice give the same bytes, and the committed ones are what the
# sources build (task #62, docs/REPRODUCE.md). libjuno.so, juno.dll (no time stamp, a fixed image
# base), JUNO-60.exe (no time stamp), the WASM (gui/web/juno.wasm + juno.js, copied to docs/).
# It rebuilds the committed juno.dll and WASM in place: run it in a clone (tools/repro/reproduce.sh).
# usage: bash tools/repro/determinism.sh      exit 1 on any difference
set -u
cd "$(dirname "$0")/../.." || exit 2
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
fail=0
same() {   # same NAME A B
  if cmp -s "$2" "$3"; then echo "ok   $1: two builds, the same bytes ($(sha256sum < "$2" | cut -c1-16))"
  else echo "FAIL $1: two builds differ"; fail=1; fi
}
SRCS=$(make -s print-libjuno-srcs)
for i in 1 2; do
  cc -std=c99 -O2 -ffp-contract=off -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers \
     -fno-strict-aliasing -Werror=frame-larger-than=16384 -shared -fPIC -o "$T/libjuno_$i.so" $SRCS -lm || fail=1
done
same libjuno.so "$T/libjuno_1.so" "$T/libjuno_2.so"
for i in 1 2; do
  rm -f juno.dll; make -s juno.dll > /dev/null || fail=1; cp juno.dll "$T/juno_$i.dll"
done
same juno.dll "$T/juno_1.dll" "$T/juno_2.dll"
git diff --quiet -- juno.dll && echo "ok   juno.dll: the committed file is the build" || { echo "FAIL juno.dll: the committed file is not the build"; fail=1; }
for i in 1 2; do
  python3 tools/dist/make_native.py --out "$T/exe$i/JUNO-60.exe" > /dev/null || fail=1
done
same JUNO-60.exe "$T/exe1/JUNO-60.exe" "$T/exe2/JUNO-60.exe"
if command -v emcc > /dev/null; then
  for i in 1 2; do
    bash gui/web/build.sh > "$T/wasm_$i.log" 2>&1 || { echo "FAIL the WASM build (log below)"; tail -5 "$T/wasm_$i.log"; fail=1; }
    cp gui/web/juno.wasm "$T/juno_$i.wasm"; cp gui/web/juno.js "$T/juno_$i.js"
  done
  same juno.wasm "$T/juno_1.wasm" "$T/juno_2.wasm"
  same juno.js "$T/juno_1.js" "$T/juno_2.js"
  git diff --quiet -- gui/web docs/juno.wasm docs/juno.js docs/index.html && echo "ok   the WASM: the committed files are the build" \
    || { echo "FAIL the WASM: the committed files are not the build"; git diff --stat -- gui/web docs; fail=1; }
else
  echo "FAIL emcc not found (source the emsdk environment)"; fail=1
fi
echo "determinism: $([ $fail = 0 ] && echo GREEN || echo RED)"
exit $fail
