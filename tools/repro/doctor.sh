#!/bin/bash
# doctor.sh -- every tool the JUNO-60 C99 results need, its version, and the line that installs it
# (task #62, docs/REPRODUCE.md). Exit 0: every REQUIRED tool present. OPTIONAL tools (the device
# tracks) are listed with what they gate. Run before anything else; tools/repro/reproduce.sh does.
# usage: bash tools/repro/doctor.sh [--quiet]
cd "$(dirname "$0")/../.." || exit 2
[ -f /home/user/emsdk/emsdk_env.sh ] && source /home/user/emsdk/emsdk_env.sh >/dev/null 2>&1
miss=0
row() {   # row REQ|OPT NAME VERSION-OR-EMPTY INSTALL WHAT
  if [ -n "$3" ]; then printf "  ok   %-26s %s\n" "$2" "$3"
  elif [ "$1" = REQ ]; then printf "  MISS %-26s needed by %s -- install: %s\n" "$2" "$5" "$4"; miss=1
  else printf "  opt  %-26s absent (gates %s) -- install: %s\n" "$2" "$5" "$4"; fi
}
v() { "$@" 2>&1 | head -1; }
row REQ gcc "$(command -v gcc >/dev/null && v gcc --version)" "apt-get install build-essential" "src/, tests, libjuno.so"
row REQ make "$(command -v make >/dev/null && v make --version)" "apt-get install make" "everything"
row REQ python3 "$(command -v python3 >/dev/null && v python3 --version)" "apt-get install python3 (3.11)" "every gate"
for m in unicorn capstone numpy pefile; do
  row REQ "python: $m" "$(python3 -c "import $m; print(getattr($m,'__version__','?'))" 2>/dev/null)" "pip install -r tools/repro/requirements.txt" "the oracle (Unicorn) and the gates"
done
row REQ node "$(command -v node >/dev/null && v node --version)" "apt-get install nodejs (22)" "the web checks"
row REQ "node: playwright-core" "$(node -e "import('playwright-core').then(m=>console.log('present'),()=>{})" --input-type=module 2>/dev/null)" "npm ci (package.json + package-lock.json at the repository root)" "the web checks"
row REQ chromium "$(ls /opt/pw-browsers/chromium* -d 2>/dev/null | head -1)" "a Playwright Chromium at /opt/pw-browsers (npx playwright install chromium)" "the web checks"
row REQ emcc "$(command -v emcc >/dev/null && v emcc --version)" "emsdk: git clone https://github.com/emscripten-core/emsdk /home/user/emsdk && ./emsdk install 6.0.11 && ./emsdk activate 6.0.11" "make webapp (the WASM)"
row REQ "mingw-w64" "$(command -v x86_64-w64-mingw32-gcc >/dev/null && v x86_64-w64-mingw32-gcc --version)" "apt-get install mingw-w64" "make native (JUNO-60.exe), juno.dll"
row REQ "wine64" "$([ -x /usr/lib/wine/wine64 ] && v /usr/lib/wine/wine64 --version)" "apt-get install wine64" "make native (the program's checks)"
row REQ "qemu-arm-static" "$(command -v qemu-arm-static >/dev/null && v qemu-arm-static --version)" "apt-get install qemu-user-static" "make verify (the ARM golden)"
row REQ "arm-linux-gnueabihf-gcc" "$(command -v arm-linux-gnueabihf-gcc >/dev/null && v arm-linux-gnueabihf-gcc --version)" "apt-get install gcc-arm-linux-gnueabihf" "make verify (the ARM golden)"
row REQ "arm-none-eabi-gcc" "$(command -v arm-none-eabi-gcc >/dev/null && v arm-none-eabi-gcc --version)" "apt-get install gcc-arm-none-eabi" "make verify (the bare-metal M7 compile)"
row OPT "python: scipy" "$(python3 -c 'import scipy; print(scipy.__version__)' 2>/dev/null)" "pip install scipy" "tools/engineb/gen_c6_halfband.py (a generator)"
row OPT "ESP-IDF (idf.py)" "$( [ -f "${IDF_PATH:-/home/user/esp-idf}/export.sh" ] && (cd "${IDF_PATH:-/home/user/esp-idf}" && git describe --tags 2>/dev/null || echo present) )" "CLAUDE.md BUILD & GIT: clone v6.1 + install.sh esp32s3" "the esp32 stage (tools/repro/esp32_check.sh)"
row OPT "qemu-system-xtensa" "$(ls /root/.espressif/tools/qemu-xtensa/*/qemu/bin/qemu-system-xtensa 2>/dev/null | head -1)" "python3 \$IDF_PATH/tools/idf_tools.py install qemu-xtensa" "the esp32 stage (the MINISYNTH self-test)"
row OPT "qemu-system-aarch64" "$(command -v qemu-system-aarch64 >/dev/null && v qemu-system-aarch64 --version)" "apt-get install qemu-system-arm" "the Pi track (pi/)"
row OPT "aarch64-linux-gnu-gcc" "$(command -v aarch64-linux-gnu-gcc >/dev/null && v aarch64-linux-gnu-gcc --version)" "apt-get install gcc-aarch64-linux-gnu" "the Pi track (pi/)"
if [ $miss = 0 ]; then echo "doctor: every required tool present"; else echo "doctor: MISSING required tools (above)"; fi
exit $miss
