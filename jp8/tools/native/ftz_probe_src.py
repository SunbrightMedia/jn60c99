#!/usr/bin/env python3
"""ftz_probe_src.py -- writes the FTZ PROBE's two sources (scope row 23; ftz_probe.sh builds and runs them):
  <out>/jp8_cpu.h       jp8/src/jp8_cpu.h with a counter: every denormal RESULT made while the guest's MXCSR has FTZ
                        (inside the plugin's ScopedNoDenormals), whatever the software mode then does with it; and the
                        results that round to the smallest normal only through gradual underflow (x86 flushes those
                        too: jp8_sz_f / jp8_sz_d). The lift includes "jp8_cpu.h" from its own folder, so only the lift's
                        object sees this copy; jp8_rt.c and jp8_host.c keep the shipped header (no struct changes).
  <out>/render_probe.c  jp8/apps/jp8_render.c with the block number for the counter's first hit, and the guest image
                        and heap written to <out.wav>.mem after the drive.
Measurement only: a scratch build, never shipped. Every anchor is asserted -- a changed source stops this, loudly.
    python3 jp8/tools/native/ftz_probe_src.py <out dir>"""
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(os.path.dirname(HERE)))


def sub(s, old, new, what):
    if s.count(old) != 1:
        sys.exit('ftz_probe_src: the anchor for %s is found %d times' % (what, s.count(old)))
    return s.replace(old, new)


def header(src):
    s = open(src).read()
    a = 'extern JP8_TLS uint32_t jp8_daz_off, jp8_ftz_off;\n'
    s = sub(s, a, a + '''/* FTZ PROBE (jp8/tools/native/ftz_probe_src.py): denormal results while the guest's FTZ bit is set */
#include <stdio.h>
static JP8_TLS uint32_t jp8_probe_gftz;
static unsigned long long jp8_probe_n, jp8_probe_nmin, jp8_probe_first = ~0ULL;
extern unsigned long long jp8_probe_block;
__attribute__((destructor)) static void jp8_probe_report(void) {
    fprintf(stderr, "FTZPROBE denormal results under the guest FTZ: %llu (+%llu min-rounding); first in block %lld\\n",
            jp8_probe_n, jp8_probe_nmin, jp8_probe_first == ~0ULL ? -1LL : (long long)jp8_probe_first); }
static inline void jp8_probe_hit(void) { jp8_probe_n++; if (jp8_probe_first == ~0ULL) jp8_probe_first = jp8_probe_block; }
''', 'the flush modes')
    s = sub(s, 'static inline float jp8_ftzf(float x) { uint32_t u = jp8_fb(x); return',
            'static inline float jp8_ftzf(float x) { uint32_t u = jp8_fb(x); if (jp8_probe_gftz && !(u & 0x7F800000u) '
            '&& (u & 0x007FFFFFu)) jp8_probe_hit(); return', 'jp8_ftzf')
    s = sub(s, 'static inline double jp8_ftzd(double x) { uint64_t u = jp8_db(x); return',
            'static inline double jp8_ftzd(double x) { uint64_t u = jp8_db(x); if (jp8_probe_gftz && !(u & '
            '0x7FF0000000000000ULL) && (u & 0x000FFFFFFFFFFFFFULL)) jp8_probe_hit(); return', 'jp8_ftzd')
    s = sub(s, 'static inline float jp8_sz_f(float r) { return', 'static inline float jp8_sz_f(float r) { jp8_probe_nmin++; return', 'jp8_sz_f')
    s = sub(s, 'static inline double jp8_sz_d(double r) { return', 'static inline double jp8_sz_d(double r) { jp8_probe_nmin++; return', 'jp8_sz_d')
    a = '    jp8_daz_off = !(c->mxcsr & 0x40u);\n'
    s = sub(s, a, a + '    jp8_probe_gftz = (c->mxcsr & 0x8000u) != 0;\n', 'jp8_fpenv')
    return s


def render(src):
    s = open(src).read()
    s = sub(s, '#include "jp8h.h"\n', '#include "jp8h.h"\nunsigned long long jp8_probe_block = ~0ULL;   /* FTZ PROBE: the block in process() */\n', 'the include')
    a = '        if ((rc = jp8h_process(n, ev, ne, par, np, NULL, outl, outr)))'
    s = sub(s, a, '        jp8_probe_block++;\n' + a, 'the process call')
    a = '    fclose(wav);\n    if (plan) fclose(plan);\n'
    s = sub(s, a, a + '''    {   /* FTZ PROBE: the guest image and heap after the drive, raw, to <out.wav>.mem */
        char mp[4096]; FILE *mf; uint64_t top = jp8h_heap_top();
        snprintf(mp, sizeof mp, "%s.mem", argv[5]); mf = fopen(mp, "wb");
        if (!mf) { fprintf(stderr, "cannot write %s\\n", mp); return 1; }
        fwrite(jp8h_guest(0x180000000ULL, 0xDE7000), 1, 0xDE7000, mf);
        fwrite(jp8h_guest(0x310000000ULL, (size_t)(top - 0x310000000ULL)), 1, (size_t)(top - 0x310000000ULL), mf);
        fclose(mf);
    }
''', 'the end of the render')
    return s


if __name__ == '__main__':
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    out = sys.argv[1]; os.makedirs(out, exist_ok=True)
    open(os.path.join(out, 'jp8_cpu.h'), 'w').write(header(os.path.join(REPO, 'jp8', 'src', 'jp8_cpu.h')))
    open(os.path.join(out, 'render_probe.c'), 'w').write(render(os.path.join(REPO, 'jp8', 'apps', 'jp8_render.c')))
    print('ftz_probe_src: wrote %s/jp8_cpu.h and %s/render_probe.c' % (out, out))
