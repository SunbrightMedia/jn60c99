#!/usr/bin/env python3
"""jx_zoom_fit_gate.py -- a window's zoom on the JX-3P: the plugin's fit and clamp vs the port's (JX-25; the JUNO-60's
rules, docs/WINDOW_ZOOM.md, CLAIMS A40; jx3p/docs/HOST_LAYER.md 3o).

The JX's panel windows read their zoom through one getter (rva 0x2AA470 = the JUNO's 0x2AA590), which every
coordinate conversion of the window calls: the zoom value (vm.vs.mainZoom for the main window, vm.vs.patchZoom for
the patch window, Script.xml zoomValueRef), at most the window's fit, and the value SET to that (the value object's
own set: no engine record, no host edit). The fit (rva 0x312580 = the JUNO's 0x312750, the same 35 instructions):
the smaller of (cy - 120) * 100 / h and (cx - 40) * 100 / w for the virtual screen cx x cy (GetSystemMetrics 78 /
79) and the panel w x h (jx3p/truth/Script.xml: main 1924 x 704, patch 1668 x 600); the first positive fit stays.

--ref (Unicorn, worker processes): per scenario, the JX plugin booted as a host boots it (jx_host_emu) with
GetSystemMetrics 78 / 79 answered by the scenario's screen, then: its editor opened (createView "editor",
IPlugView::attached); mainZoom set to 25, 62, 100, 150, 200 (the model's set 0x283C90, then the panel trio 0x285200
/ 0x2852A0 / 0x283000) each followed by the main window's own getter (what its next draw calls); [a second screen];
the patch window opened (vm.vs.panelPatch 1, the trio); patchZoom set the same way with the patch window's getter;
mainZoom 200 again; the window closed, [a third screen], opened again; patchZoom 200 again. Recorded per step: every
fit the plugin computed (its window's rectangle, the result, kept or not), mainZoom / patchZoom as getState writes
them, the engine records the step queued and the host edits it made. Harness = plumbing: the screen, the calls.
--port (ctypes, the port's library): the same steps -- a set: jx3p_model_set + jx3p_model_commit; each conversion
the plugin made: jx3p_zoom_get (one kept fit per window) and, when it differs, jx3p_value_set -- and per step the
two zooms (jx3p_model_get), the records queued (jx3p_product_pending) and the host edits (jx3p_host_edits).
--port-tooth: every JX_ZF_TOOTH build of the bridge must FAIL.
exit 0 = EQUAL (or every tooth bites).
"""
import atexit
import ctypes
import os
import pickle
import re
import shutil
import struct
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
SRCS = ['jx3p/gui/jx_bridge.c', 'jx3p/src/jx_recall.c', 'jx3p/src/jx_voice_render.c',
        'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']
REF_PKL = os.path.join(REPO, 'scratchpad', 'jx_zoom', 'zoom_fit_ref.pkl')
MAINZOOM, PATCHZOOM, PANELPATCH = 0x0FFFC008, 0x0FFFC016, 0x0FFFC002
MODEL_SET, TRIO, VALUES = 0x283C90, (0x285200, 0x2852A0, 0x283000), 0x413140   # == the JUNO's 0x283DB0, (0x285320,
                                                       # 0x2853C0, 0x283120), 0x34E170 (fw_map --pair: equal)
FIT, FIT_RET = 0x312580, 0x3125F1                      # the fit's entry and its common return (eax the fit)
ZOOMS = (25, 62, 100, 150, 200)
SCENARIOS = [((0, 0), None, None), ((640, 480), None, None), ((800, 600), None, None), ((1024, 768), None, None),
             ((1280, 720), None, None), ((1366, 768), None, None), ((1600, 900), None, None),
             ((1920, 1080), None, None), ((2560, 1440), None, None), ((3840, 2160), None, None),
             ((3840, 1080), None, None), ((1080, 1920), None, None), ((1993, 1201), None, None),
             ((1920, 1080), (800, 600), (3840, 2160)), ((0, 0), (1920, 1080), (640, 480)),
             ((1024, 768), (3840, 2160), (800, 600))]
TEETH = [(1, 'the margins swapped (40 high, 120 wide)'), (2, 'the larger fit'), (3, 'the fits rounded'),
         (4, 'no fit kept')]
_TMP = []
atexit.register(lambda: [shutil.rmtree(d, ignore_errors=True) for d in _TMP])


def panel_sizes():
    """the JX main and patch panels' sizes (jx3p/truth/Script.xml panelType main / patch): their windows'"""
    x = open(os.path.join(REPO, 'jx3p', 'truth', 'Script.xml'), encoding='utf-8', errors='replace').read()
    out = {}
    for m in re.finditer(r'<panelType>(.*?)</panelType>', x, re.S):
        t, z = re.search(r'<type>([^<]*)</type>', m.group(1)), re.search(r'<size>([^<]*)</size>', m.group(1))
        if t and z and t.group(1).strip() in ('main', 'patch'):
            out[t.group(1).strip()] = tuple(int(v) for v in z.group(1).split(','))
    return out


PANEL = panel_sizes()


def plugin_run(scn):
    """one scenario through the JX plugin (a worker: Unicorn only)"""
    sys.path.insert(0, HERE)
    import jx_host_emu as X
    H = X.H
    h = X.JXHost()
    h.start(48000.0, 4096)
    uc = h.uc
    q = lambda a: struct.unpack('<Q', uc.mem_read(a, 8))[0]
    i32 = lambda a: struct.unpack('<i', uc.mem_read(a, 4))[0]
    fits = []
    size_kind = {v: k for k, v in PANEL.items()}

    def on_entry(uc_, addr, size, ud):                    # the fit's entry: the window; its kept fit (> 0)
        ud[0] = uc_.reg_read(H.UC_X86_REG_RCX)
        ud[1] = i32(ud[0] + 0x13c) > 0

    def on_fit(uc_, addr, size, ud):                      # its common return: eax the fit
        r = [i32(ud[0] + 0x18 + 4 * k) for k in range(4)]
        w, hh = r[2] - r[0], r[3] - r[1]
        f = struct.unpack('<i', struct.pack('<I', uc_.reg_read(H.UC_X86_REG_RAX) & 0xFFFFFFFF))[0]
        fits.append((size_kind.get((w, hh), '%dx%d' % (w, hh)), w, hh, f, ud[1]))
    this = [0, False]
    uc.hook_add(H.UC_HOOK_CODE, on_entry, this, begin=X.IB + FIT, end=X.IB + FIT)
    uc.hook_add(H.UC_HOOK_CODE, on_fit, this, begin=X.IB + FIT_RET, end=X.IB + FIT_RET)
    model = q(q(h.core + 8))
    vo = h.call(X.IB + VALUES, rcx=model)
    pmo = h.call(q(q(vo) + 0x60), rcx=vo)                 # patchManager's value object (vs + 4)
    vsbase = q(pmo + 0x18) - 4
    obj = {}
    for k in range(-2, 16):                               # the vs value objects lie 0x28 apart, in vs order
        o = pmo + k * 0x28
        obj[q(o + 0x18) - vsbase] = o
    if not (obj.get(2) == pmo - 2 * 0x28 and 0x08 in obj and 0x16 in obj):
        raise RuntimeError('the vs value objects are not where the JUNO keeps them')

    def zooms():
        s = h.get_state()
        n = struct.unpack('>I', s[:4])[0] // 8
        d = dict(struct.unpack('>Ii', s[4 + 8 * k: 12 + 8 * k]) for k in range(n))
        return d.get(MAINZOOM), d.get(PATCHZOOM)

    def mset(off, v):                                     # a panel control's set and the trio
        h.call(X.IB + MODEL_SET, rcx=model, rdx=obj[off], r8=v & 0xFFFFFFFF, r9=1, count=500_000_000)
        for rva in TRIO:
            h.call(X.IB + rva, rcx=model, count=500_000_000)
    steps = []
    mark = [len(h.queue()), len(h.edits)]

    def step(label):
        qq = h.queue()
        new = [(kind, struct.unpack_from('<I', r, 12)[0], struct.unpack_from('<i', r, 20)[0]) if kind == 2 else
               (kind, r[8], r[9], r[10]) for kind, off, r in qq[mark[0]:]]
        steps.append((label, list(fits), zooms(), new, [tuple(e) for e in h.edits[mark[1]:]]))
        mark[:] = [len(qq), len(h.edits)]
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
    with mp.get_context('spawn').Pool(3) as pool:
        runs = pool.map(plugin_run, SCENARIOS, chunksize=1)
    ref = {'scenarios': SCENARIOS, 'runs': runs, 'panel': PANEL}
    os.makedirs(os.path.dirname(REF_PKL), exist_ok=True)
    pickle.dump(ref, open(REF_PKL + '.partial', 'wb'))
    os.replace(REF_PKL + '.partial', REF_PKL)
    nfit = sum(len(st[1]) for _, steps in runs for st in steps)
    print('jx_zoom_fit_gate --ref: %d scenarios, %d steps, %d fits computed -> %s' % (
        len(runs), sum(len(steps) for _, steps in runs), nfit, REF_PKL))
    return 0


def build_lib(tooth=0):
    d = tempfile.mkdtemp(prefix='jxzoom_')
    _TMP.append(d)
    so = os.path.join(d, 'libjx_t%d.so' % tooth)
    subprocess.check_call(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                           '-DJX_ZF_TOOTH=%d' % tooth, '-o', so] + [os.path.join(REPO, s) for s in SRCS] + ['-lm'])
    return so


def port_worker(so, out):
    """the port's side of every scenario (a worker: ctypes only)"""
    sys.path.insert(0, HERE)
    import jx_guest
    lib = ctypes.CDLL(so)
    I = ctypes.c_int
    lib.jx3p_product_init.argtypes = [ctypes.c_char_p, ctypes.c_char_p, I]
    lib.jx3p_model_get.restype = ctypes.c_int32
    lib.jx3p_model_get.argtypes = [ctypes.c_uint32]
    lib.jx3p_model_set.argtypes = [ctypes.c_uint32, ctypes.c_int32]
    lib.jx3p_value_set.argtypes = [ctypes.c_uint32, ctypes.c_int32]
    lib.jx3p_zoom_get.argtypes = [I, I, I, I, I, ctypes.POINTER(I)]
    img = jx_guest.path(96).encode()
    bank = os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin').encode()
    ref = pickle.load(open(REF_PKL, 'rb'))
    pend = (ctypes.c_int * (5 * 1024))()
    eid, ev = (ctypes.c_uint32 * 512)(), (ctypes.c_double * 512)()
    runs = []
    for scn, steps in ref['runs']:
        if lib.jx3p_product_init(img, bank, 48000) < 0:
            raise SystemExit('jx3p_product_init failed')
        n0 = lib.jx3p_product_pending(pend, 5 * 1024)     # initialize's records, queued for the first block
        lib.jx3p_host_edits(eid, ev, None, 512)
        screen = list(scn[0])
        cache = {'main': I(0), 'patch': I(0)}
        get = lambda i: lib.jx3p_model_get(i)
        port = []
        for label, fits, _, _, _ in steps:
            t = label.split()
            if t[0] == 'screen':
                screen[:] = [int(x) for x in t[1].split('x')]
            elif t[0] in ('main', 'patch') and t[1].isdigit():         # a zoom set ('... again' too)
                lib.jx3p_model_set(MAINZOOM if t[0] == 'main' else PATCHZOOM, int(t[1]))
                lib.jx3p_model_commit()
            elif t[0] in ('open', 'reopen', 'close'):
                lib.jx3p_model_set(PANELPATCH, 0 if t[0] == 'close' else 1)
                lib.jx3p_model_commit()
            got = []
            for kind, w, hh, f, kept in fits:           # each conversion the plugin made in this step
                if kind in PANEL:
                    zid = MAINZOOM if kind == 'main' else PATCHZOOM
                    v = get(zid)
                    before = cache[kind].value
                    z = lib.jx3p_zoom_get(v, screen[0], screen[1], PANEL[kind][0], PANEL[kind][1],
                                          ctypes.byref(cache[kind]))
                    got.append((before > 0, cache[kind].value))
                    if z != v:
                        lib.jx3p_value_set(zid, z)
            n = lib.jx3p_product_pending(pend, 5 * 1024)
            recs = [(pend[5 * i], pend[5 * i + 3] & 0xFFFFFFFF, pend[5 * i + 4]) if pend[5 * i] == 2 else
                    (pend[5 * i], pend[5 * i + 2], pend[5 * i + 3], pend[5 * i + 4]) for i in range(n0, n)]
            n0 = n
            ne = lib.jx3p_host_edits(eid, ev, None, 512)
            port.append((label, (get(MAINZOOM), get(PATCHZOOM)), got, recs,
                         [(eid[i], ev[i]) for i in range(ne)]))
        runs.append(port)
    pickle.dump(runs, open(out, 'wb'))


def check_port(tooth=0, quiet=False):
    so = build_lib(tooth)
    out = os.path.join(os.path.dirname(so), 'port.pkl')
    subprocess.check_call([sys.executable, os.path.abspath(__file__), '--port-worker', so, out])
    runs = pickle.load(open(out, 'rb'))
    ref = pickle.load(open(REF_PKL, 'rb'))
    if ref['panel'] != PANEL:
        raise SystemExit('the reference was made with other panel sizes: run --ref')
    bad = nsteps = nfits = 0
    for (scn, steps), port in zip(ref['runs'], runs):
        for (label, fits, zp, qp, ep), (_, zq, got, qq, eq) in zip(steps, port):
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
            if [tuple(r) for r in qp] != [tuple(r) for r in qq]:
                bad += 1
                if not quiet:
                    print('FAIL %s %s: the engine records, plugin %s, port %s' % (scn, label, qp, qq))
            if [(a, round(b, 9)) for a, b in ep] != [(a, round(b, 9)) for a, b in eq]:
                bad += 1
                if not quiet:
                    print('FAIL %s %s: the host edits, plugin %s, port %s' % (scn, label, ep, eq))
    if not quiet:
        nrec = sum(len(st[3]) for _, steps in ref['runs'] for st in steps)
        print('jx_zoom_fit_gate --port: %d scenarios, %d steps, %d fits, %d engine records: %s' % (
            len(ref['runs']), nsteps, nfits, nrec, 'EQUAL' if not bad else '%d DIFFER' % bad))
    return bad


def main():
    a = sys.argv[1:]
    if a[:1] == ['--port-worker']:
        port_worker(a[1], a[2])
        return 0
    if a[:1] == ['--ref']:
        return build_ref()
    if a[:1] == ['--port']:
        bad = check_port()
        print('jx_zoom_fit_gate: %s' % ('GREEN' if not bad else 'RED'))
        return 1 if bad else 0
    if a[:1] == ['--port-tooth']:
        res = []
        for n, what in TEETH:
            b = check_port(n, quiet=True)
            print('tooth %d %-44s %s (%d differ)' % (n, what, 'BITES' if b else 'DID NOT BITE', b))
            res.append(b)
        return 0 if all(res) else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
