#!/usr/bin/env python3
"""zoom_fit_gate.py -- a window's zoom: the plugin's fit and clamp vs the port's (docs/WINDOW_ZOOM.md).

The plugin's panel windows read their zoom through one getter (rva 0x2AA590), which every
coordinate conversion of the window calls (rva 0x2AC0F0..0x2AC55E: a draw, an invalidation, a hit
test): the zoom value (vm.vs.mainZoom for the main window, vm.vs.patchZoom for the patch window,
Script.xml zoomValueRef), at most the window's fit, and the value SET to that. The fit (rva
0x312750): the smaller of (cy - 120) * 100 / h and (cx - 40) * 100 / w for the virtual screen
cx x cy (GetSystemMetrics 78 / 79) and the panel w x h; the first positive fit stays (+0x13c).

--ref (Unicorn): per scenario, the plugin booted as a host boots it (host_process_emu) with
GetSystemMetrics 78 / 79 answered by the scenario's screen, then: its editor opened
(IEditController::createView "editor", IPlugView::attached); mainZoom set to 25, 62, 100, 150, 200
(the model's set, the panel trio) each followed by the main window's own getter (what its next
draw calls); [a second screen, for the kept fit]; the patch window opened (vm.vs.panelPatch 1, the
panel trio); patchZoom set the same way with the patch window's getter; mainZoom 200 once more.
Recorded per step: every fit the plugin computed (its window's rectangle and the result) and
mainZoom / patchZoom as getState writes them. Harness = plumbing: the screen answer, the calls.
--port (libjuno): the same steps through juno_gui_zoom_fit / juno_gui_zoom_get (one fit kept per
window, the panels' Script.xml sizes) and the port's model store (juno_gui_model_set / _get), value
for value; the plugin's rectangles must be the Script.xml sizes the port uses.
--port-tooth: every ZF_TOOTH build of the bridge must FAIL (TEETH).
"""
import os
import pickle
import struct
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
REF_PKL = os.path.join(REPO, 'scratchpad', 'zoom_fit_ref.pkl')
MAINZOOM, PATCHZOOM = 0x0FFFC008, 0x0FFFC016
from pm_common import panel_sizes  # noqa: E402
PANEL = dict(zip(('main', 'patch'), panel_sizes()))      # Script.xml panelType main / patch: size
ZOOMS = (25, 62, 100, 150, 200)
# (first screen, second screen or None): odd sizes, an empty one (no screen: the fit is negative and
# never kept), portrait, two monitors side by side, and screens that change under a running editor
SCENARIOS = [((0, 0), None, None), ((640, 480), None, None), ((800, 600), None, None), ((1024, 768), None, None),
             ((1280, 720), None, None), ((1366, 768), None, None), ((1600, 900), None, None),
             ((1920, 1080), None, None), ((2560, 1440), None, None), ((3840, 2160), None, None),
             ((3840, 1080), None, None), ((1080, 1920), None, None), ((1993, 1201), None, None),
             ((1920, 1080), (800, 600), (3840, 2160)), ((0, 0), (1920, 1080), (640, 480)),
             ((1024, 768), (3840, 2160), (800, 600))]
TEETH = [(1, 'the margins swapped (40 high, 120 wide)'), (2, 'the larger fit'), (3, 'the fits rounded'),
         (4, 'no fit kept')]


def plugin_run(scn):
    """one scenario through the plugin (a worker: Unicorn only)"""
    import host_process_emu as H
    from unicorn import UC_HOOK_CODE
    from unicorn.x86_const import UC_X86_REG_RCX, UC_X86_REG_RAX
    h = H.HostProcess()
    h.start(48000.0, 4096)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    i32 = lambda a: struct.unpack('<i', uc.mem_read(a, 4))[0]
    fits = []
    size_kind = {v: k for k, v in PANEL.items()}

    def on_entry(uc_, addr, size, ud):                    # rva 0x312750: the window; its kept fit (> 0)
        ud[0] = uc_.reg_read(UC_X86_REG_RCX)
        ud[1] = i32(ud[0] + 0x13c) > 0

    def on_fit(uc_, addr, size, ud):                      # rva 0x3127C1: both paths, eax the fit
        r = [i32(ud[0] + 0x18 + 4 * k) for k in range(4)]
        w, hh = r[2] - r[0], r[3] - r[1]
        f = struct.unpack('<i', struct.pack('<I', uc_.reg_read(UC_X86_REG_RAX) & 0xFFFFFFFF))[0]
        fits.append((size_kind.get((w, hh), '%dx%d' % (w, hh)), w, hh, f, ud[1]))
    this = [0, False]
    uc.hook_add(UC_HOOK_CODE, on_entry, this, begin=H.IB + 0x312750, end=H.IB + 0x312750)
    uc.hook_add(UC_HOOK_CODE, on_fit, this, begin=H.IB + 0x3127C1, end=H.IB + 0x3127C1)
    model = q(q(h.core + 8))
    vo = h.call(H.IB + 0x34E170, rcx=model)
    pmo = h.call(q(q(vo) + 0x60), rcx=vo)                 # patchManager's value object (vs + 4)
    vsbase = q(pmo + 0x18) - 4
    obj = {}
    for k in range(-2, 16):                               # the vs value objects lie 0x28 apart, in vs order
        o = pmo + k * 0x28
        obj[q(o + 0x18) - vsbase] = o
    assert obj[2] == pmo - 2 * 0x28 and 0x08 in obj and 0x16 in obj

    def zooms():
        s = h.get_state()
        n = struct.unpack('>I', s[:4])[0] // 8
        d = dict(struct.unpack('>Ii', s[4 + 8 * k: 12 + 8 * k]) for k in range(n))
        return d.get(MAINZOOM), d.get(PATCHZOOM)

    def mset(off, v):                                     # a panel control's set and the trio
        h.call(H.IB + 0x283DB0, rcx=model, rdx=obj[off], r8=v & 0xFFFFFFFF, r9=1)
        for rva in (0x285320, 0x2853C0, 0x283120):
            h.call(H.IB + rva, rcx=model, count=500_000_000)
    steps = []

    def step(label):
        steps.append((label, list(fits), zooms()))
        del fits[:]

    def screen(sc):
        h.screen = {0x4E: sc[0], 0x4F: sc[1]}
        step('screen %dx%d' % tuple(sc))
    step('boot')
    h.attach_editor(*scn[0])                              # createView + attached: the main window lays out
    step('attach')
    for z in ZOOMS:
        mset(0x08, z)
        h.window_conv(PANEL['main'])                      # the main window's next draw
        step('main %d' % z)
    if scn[1]:
        screen(scn[1])
    mset(0x02, 1)                                         # the PATCH button: the patch window opens
    step('open')
    for z in ZOOMS:
        mset(0x16, z)
        h.window_conv(PANEL['patch'])
        step('patch %d' % z)
    mset(0x08, 200)
    h.window_conv(PANEL['main'])
    step('main 200 again')
    mset(0x02, 0)                                         # the window closes
    step('close')
    if scn[2]:
        screen(scn[2])
    mset(0x02, 1)                                         # and opens again
    step('reopen')
    mset(0x16, 200)
    h.window_conv(PANEL['patch'])
    step('patch 200 again')
    return scn, steps


def build_ref():
    import multiprocessing as mp
    import truth
    truth.verify()
    with mp.get_context('spawn').Pool(4) as pool:
        runs = pool.map(plugin_run, SCENARIOS, chunksize=1)
    ref = {'scenarios': SCENARIOS, 'runs': runs, 'panel': PANEL}
    part = REF_PKL + '.partial'
    pickle.dump(ref, open(part, 'wb'))
    os.replace(part, REF_PKL)
    nfit = sum(len(f) for _, st in runs for _, f, _ in st)
    print('zoom_fit_gate --ref: %d scenarios, %d steps, %d fits computed -> %s' % (
        len(runs), sum(len(st) for _, st in runs), nfit, REF_PKL))
    return 0


def check_port(libpath=None, quiet=False):
    import ctypes
    if libpath is None:
        import freshlib
        lib = freshlib.load()
    else:
        lib = ctypes.CDLL(libpath)
    V, I = ctypes.c_void_p, ctypes.c_int
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [ctypes.c_float, I]
    lib.juno_gui_plugin_init.argtypes = [V]
    lib.juno_gui_model_get.restype = ctypes.c_int32
    lib.juno_gui_model_get.argtypes = [V, ctypes.c_uint32]
    lib.juno_gui_model_set.argtypes = [V, ctypes.c_uint32, ctypes.c_int32]
    lib.juno_gui_zoom_fit.argtypes = [I, I, I, I]
    lib.juno_gui_zoom_get.argtypes = [I, I, I, I, I, ctypes.POINTER(I)]
    lib.juno_gui_destroy.argtypes = [V]
    ref = pickle.load(open(REF_PKL, 'rb'))
    bad = 0
    nsteps = nfits = 0
    for scn, steps in ref['runs']:
        c = lib.juno_gui_create(48000.0, 0)
        lib.juno_gui_plugin_init(c)
        screen = list(scn[0])
        cache = {'main': I(0), 'patch': I(0)}
        get = lambda i: lib.juno_gui_model_get(c, i)

        port = []
        for label, fits, _ in steps:
            t = label.split()
            if t[0] == 'screen':
                screen[:] = [int(x) for x in t[1].split('x')]
            elif t[0] in ('main', 'patch') and t[1].isdigit():         # a zoom set ('... again' too)
                lib.juno_gui_model_set(c, MAINZOOM if t[0] == 'main' else PATCHZOOM, int(t[1]))
            got = []
            for kind, w, hh, f, kept in fits:           # each conversion the plugin made in this step
                if kind in PANEL:
                    v = get(MAINZOOM if kind == 'main' else PATCHZOOM)
                    before = cache[kind].value
                    z = lib.juno_gui_zoom_get(v, screen[0], screen[1], PANEL[kind][0], PANEL[kind][1],
                                              ctypes.byref(cache[kind]))
                    got.append((before > 0, cache[kind].value))     # the fit it used: kept, or computed now
                    if z != v:
                        lib.juno_gui_model_set(c, MAINZOOM if kind == 'main' else PATCHZOOM, z)
            port.append((label, (get(MAINZOOM), get(PATCHZOOM)), got))
        lib.juno_gui_destroy(c)
        for (label, fits, zp), (_, zq, got) in zip(steps, port):
            nsteps += 1
            k = 0
            for kind, w, hh, f, kept in fits:
                nfits += 1
                if PANEL.get(kind) != (w, hh):
                    bad += 1
                    if not quiet:
                        print('FAIL %s %s: the plugin fitted a %dx%d window, not a Script.xml panel' % (scn, label, w, hh))
                    continue
                pk, pf = got[k]
                k += 1
                if (pk, pf) != (kept, f):
                    bad += 1
                    if not quiet:
                        print('FAIL %s %s: the %s fit, plugin %d%s, port %d%s' % (
                            scn, label, kind, f, ' (kept)' if kept else '', pf, ' (kept)' if pk else ''))
            if tuple(zp) != tuple(zq):
                bad += 1
                if not quiet:
                    print('FAIL %s %s: mainZoom, patchZoom plugin %s, port %s' % (scn, label, zp, zq))
    if not quiet:
        print('zoom_fit_gate --port: %d scenarios, %d steps, %d fits: %s' % (
            len(ref['runs']), nsteps, nfits, 'EQUAL' if not bad else '%d DIFFER' % bad))
    return bad


def tooth_lib(n):
    work = os.path.join(REPO, 'scratchpad', 'zoom_fit_teeth')
    os.makedirs(work, exist_ok=True)
    out = os.path.join(work, 'libjuno_t%d.so' % n)
    src = os.path.join(REPO, 'src')
    subprocess.check_call(['gcc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                           '-DZF_TOOTH=%d' % n, '-o', out, os.path.join(REPO, 'gui', 'juno_bridge.c')] +
                          sorted(os.path.join(src, f) for f in os.listdir(src) if f.endswith('.c')) + ['-lm'])
    return out


def main():
    a = sys.argv[1:2]
    if a == ['--ref']:
        return build_ref()
    if a == ['--port']:
        bad = check_port()
        print('GATE: %s' % ('FAIL' if bad else 'PASS'))
        return 1 if bad else 0
    if a == ['--port-tooth']:
        res = []
        for n, what in TEETH:
            b = check_port(tooth_lib(n), quiet=True)
            print('tooth %d %-44s %s (%d differ)' % (n, what, 'BITES' if b else 'DID NOT BITE', b))
            res.append(b)
        return 0 if all(res) else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
