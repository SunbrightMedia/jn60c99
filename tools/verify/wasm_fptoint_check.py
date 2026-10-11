#!/usr/bin/env python3
"""wasm_fptoint_check.py -- a float -> int conversion in the delivered WASM gives x86's result on every input.

The plugin and the native port convert with cvttss2si / cvttsd2si: a NaN, an infinity or a value past the integer's
range gives the "integer indefinite" (INT_MIN / INT64_MIN). WASM's default conversion (the nontrapping-fptoint
feature: trunc_sat) gives 0 for a NaN and saturates a value past the range; without the feature LLVM emits a guarded
conversion whose result is x86's. Three checks (playbook 224):
  1. every emcc command in the app's build script carries -mno-nontrapping-fptoint;
  2. the app rebuilt by its build script's own command plus --profiling-funcs (function names kept) holds a trunc_sat
     instruction only in the libc functions of ALLOWED -- each with the reason its input is never past the range;
  3. a probe of the conversions (NaN, infinities, past the range, in range; f32 / f64 -> i32 / i64) built with the
     app's flags prints exactly what the same probe prints natively (cc, x86-64).
    python3 tools/verify/wasm_fptoint_check.py --app juno|jx
    python3 tools/verify/wasm_fptoint_check.py --app juno|jx --tooth   the same without the flag: the scan must find
                                                                       trunc_sat in the port's own code and the probe
                                                                       must differ
exit 0 = every check holds (or, --tooth, both checks saw the defect); 1 = a failure (listed).
"""
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
FLAG = '-mno-nontrapping-fptoint'
SCRIPT = {'juno': 'gui/web/build.sh', 'jx': 'jx3p/gui/web/build.sh'}
# trunc_sat kept in emscripten's prebuilt libc (compiled with the feature on); never reached past the range:
ALLOWED = {
    'fmt_fp': 'printf of a float -- text for the page, never DSP',
    'lrint': "the JUNO's expf rounding (src/juno_crt_expf.h): its argument is in [-9600, 8192) by the tests above it",
}
PROBE = r'''
#include <stdio.h>
#include <stdint.h>
#include <string.h>
static float f32(uint32_t b) { float f; memcpy(&f, &b, 4); return f; }
static double f64(uint64_t b) { double d; memcpy(&d, &b, 8); return d; }
int main(void)
{
    static const uint32_t F[] = { 0x7FC00000u, 0xFFC00000u, 0x7F800001u, 0x7F800000u, 0xFF800000u, 0x4F000000u,
                                  0xCF000000u, 0x4EFFFFFFu, 0xCF000001u, 0x5F000000u, 0xDF000000u, 0x3FC00000u,
                                  0xBFC00000u, 0x00000001u, 0x80000000u, 0x4F800000u };
    static const uint64_t D[] = { 0x7FF8000000000000ull, 0xFFF8000000000000ull, 0x7FF0000000000001ull,
                                  0x7FF0000000000000ull, 0xFFF0000000000000ull, 0x41E0000000000000ull,
                                  0xC1E0000000200000ull, 0x41DFFFFFFFC00000ull, 0x43E0000000000000ull,
                                  0x3FF8000000000000ull, 0xBFF8000000000000ull };
    unsigned i;
    for (i = 0; i < sizeof F / sizeof F[0]; i++) {
        volatile float x = f32(F[i]);
        printf("f%u %d %lld\n", i, (int)x, (long long)x);
    }
    for (i = 0; i < sizeof D / sizeof D[0]; i++) {
        volatile double x = f64(D[i]);
        printf("d%u %d %lld\n", i, (int)x, (long long)x);
    }
    return 0;
}
'''


def emsdk_prefix():
    """emcc on the PATH, or the SDK named by $EMSDK, or the SDK beside the checkout (docs/REPRODUCE.md's install)"""
    if shutil.which('emcc'):
        return ''
    for d in (os.environ.get('EMSDK'), os.path.join(os.path.dirname(REPO), 'emsdk')):
        if d and os.path.exists(os.path.join(d, 'emsdk_env.sh')):
            return 'source %s >/dev/null 2>&1; ' % os.path.join(d, 'emsdk_env.sh')
    raise SystemExit('REFUSE: no emcc (PATH, $EMSDK, or ../emsdk beside the checkout): the WASM cannot be checked')


def emcc_commands(script):
    """every emcc command of the build script, its continuation lines joined"""
    lines, out, cur = open(os.path.join(REPO, script)).read().split('\n'), [], None
    for ln in lines:
        if cur is None and re.match(r'\s*emcc\s', ln):
            cur = ''
        if cur is not None:
            cur += ln.rstrip('\\').strip() + ' '
            if not ln.rstrip().endswith('\\'):
                out.append(cur.strip())
                cur = None
    return out


def bash(cmd, **kw):
    return subprocess.run(['bash', '-c', emsdk_prefix() + cmd], cwd=REPO, capture_output=True, text=True, **kw)


def scan(app, tmp, flag):
    """the app's first emcc command, its output redirected, function names kept: trunc_sat per function"""
    cmd = emcc_commands(SCRIPT[app])[0]
    cmd = re.sub(r'-o\s+\S+', '--profiling-funcs -o %s/app.js' % tmp, cmd)
    if not flag:
        cmd = cmd.replace(FLAG, '')
    r = bash(cmd)
    if r.returncode:
        raise SystemExit('REFUSE: the app did not build:\n' + r.stderr[-2000:])
    # binaryen's disassembler: in the SDK's upstream/bin, one level above emcc's own directory
    r = bash('"$(dirname "$(command -v emcc)")/../bin/wasm-dis" %s/app.wasm' % tmp)
    if r.returncode:
        raise SystemExit('REFUSE: wasm-dis failed: ' + r.stderr[-500:])
    found, fn = {}, None
    for ln in r.stdout.split('\n'):
        m = re.match(r'\s*\(func \$(\S+)', ln)
        if m:
            fn = m.group(1)
        if 'trunc_sat' in ln:
            found[fn] = found.get(fn, 0) + 1
    return found


def probe(tmp, flag):
    c = os.path.join(tmp, 'probe.c')
    open(c, 'w').write(PROBE)
    nat = os.path.join(tmp, 'probe')
    subprocess.run(['cc', '-std=c99', '-O2', '-o', nat, c], check=True)
    want = subprocess.run([nat], capture_output=True, text=True, check=True).stdout
    r = bash('emcc -std=c99 -O2 -ffp-contract=off -fno-strict-aliasing %s -o %s/probe.js %s && node %s/probe.js'
             % (FLAG if flag else '', tmp, c, tmp))
    if r.returncode:
        raise SystemExit('REFUSE: the probe did not build or run:\n' + r.stderr[-2000:])
    got = r.stdout
    return [(w, g) for w, g in zip(want.split('\n'), got.split('\n')) if w != g] + \
        ([('lines', 'differ')] if len(want.split('\n')) != len(got.split('\n')) else [])


def main():
    a = sys.argv[1:]
    app = a[a.index('--app') + 1] if '--app' in a else 'juno'
    tooth = '--tooth' in a
    tmp = tempfile.mkdtemp(prefix='fptoint_')
    try:
        bad = []
        cmds = emcc_commands(SCRIPT[app])
        if not cmds:
            raise SystemExit('REFUSE: no emcc command in %s' % SCRIPT[app])
        miss = [k for k, c in enumerate(cmds) if FLAG not in c.split()]
        print('  %s: %d emcc commands, %s' % (SCRIPT[app], len(cmds), 'every one with ' + FLAG if not miss else
                                             'WITHOUT the flag: command(s) %s' % miss))
        bad += ['flag'] if miss else []
        found = scan(app, tmp, not tooth)
        port = {f: n for f, n in found.items() if f not in ALLOWED}
        print('  trunc_sat by function: %s' % (', '.join('%s %d' % kv for kv in sorted(found.items())) or 'none'))
        for f in sorted(set(found) & set(ALLOWED)):
            print('    %s allowed: %s' % (f, ALLOWED[f]))
        if port:
            print('  trunc_sat OUTSIDE the allowed libc functions: %s' % ', '.join(sorted(port)))
            bad.append('scan')
        diff = probe(tmp, not tooth)
        print('  probe (NaN, infinities, past the range, in range): %s' % (
            'WASM == x86 on every line' if not diff else '%d lines differ, first: x86 %r WASM %r' % (
                len(diff), diff[0][0], diff[0][1])))
        bad += ['probe'] if diff else []
    finally:
        shutil.rmtree(tmp, True)
    if tooth:
        ok = 'scan' in bad and 'probe' in bad
        print('wasm_fptoint_check --tooth (%s): %s' % (app, 'BITES (the scan and the probe see the default)' if ok
                                                       else 'DID NOT BITE (%s)' % (bad or 'nothing seen')))
        return 0 if ok else 1
    print('wasm_fptoint_check %s: %s' % (app, 'every float -> int conversion is x86\'s' if not bad else
                                         'FAIL (%s)' % ', '.join(bad)))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
