#!/usr/bin/env python3
"""jn_zoom_seq.py -- L5's editor + window-zoom drive (docs/JUNO_LIFT.md), shared by the oracle side (jn_zoom_ref.py)
and the lifted side (jn_zoom_c.py): the steps of tools/verify/zoom_fit_gate.py's plugin_run -- the editor opened on a
virtual screen (IEditController::createView "editor", IPlugView::attached), mainZoom set to 25 / 62 / 100 / 150 / 200
through the panel (the model's set + the commit trio) each followed by the main window's own zoom getter, a second
screen, the patch window opened (vm.vs.panelPatch 1), patchZoom set the same way, the window closed, a third screen,
reopened. Every step records the getter's zoom, mainZoom / patchZoom as getState writes them, and the end-state
digest (image + heap + host arena).
A step: ('attach', cx, cy) | ('screen', cx, cy) | ('mset', vs_offset, value) | ('conv', 'main' | 'patch') | ('mark', label)"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))

MAINZOOM, PATCHZOOM = 0x0FFFC008, 0x0FFFC016
VO_GET = 0x34E170                        # the model's value-object list (zoom_fit_gate.py)
MODEL_SET, TRIO = 0x283DB0, (0x285320, 0x2853C0, 0x283120)
ZOOMS = (25, 62, 100, 150, 200)
SCENARIOS = [((1920, 1080), None, None), ((800, 600), None, None), ((1920, 1080), (800, 600), (3840, 2160)),
             ((0, 0), (1920, 1080), (640, 480))]


def panel_sizes():
    from pm_common import panel_sizes as ps                       # Script.xml's main / patch panel sizes
    return dict(zip(('main', 'patch'), ps()))


def steps(scn):
    s = [('mark', 'boot'), ('attach',) + tuple(scn[0]), ('mark', 'attach')]
    for z in ZOOMS:
        s += [('mset', 0x08, z), ('conv', 'main'), ('mark', 'main %d' % z)]
    if scn[1]:
        s += [('screen',) + tuple(scn[1]), ('mark', 'screen %dx%d' % tuple(scn[1]))]
    s += [('mset', 0x02, 1), ('mark', 'open')]
    for z in ZOOMS:
        s += [('mset', 0x16, z), ('conv', 'patch'), ('mark', 'patch %d' % z)]
    s += [('mset', 0x08, 200), ('conv', 'main'), ('mark', 'main 200 again'), ('mset', 0x02, 0), ('mark', 'close')]
    if scn[2]:
        s += [('screen',) + tuple(scn[2]), ('mark', 'screen %dx%d' % tuple(scn[2]))]
    s += [('mset', 0x02, 1), ('mark', 'reopen'), ('mset', 0x16, 200), ('conv', 'patch'), ('mark', 'patch 200 again')]
    return s


def zooms_of(state):
    """mainZoom / patchZoom from getState's bytes (the plugin's own stream: n*8 then (id, value) big-endian)"""
    import struct
    n = struct.unpack('>I', state[:4])[0] // 8
    d = dict(struct.unpack('>Ii', state[4 + 8 * k: 12 + 8 * k]) for k in range(n))
    return d.get(MAINZOOM), d.get(PATCHZOOM)


def value_objects(q, call, model):
    """the vs value objects by their vs offset (zoom_fit_gate.py): the list getter, the patchManager's object (vs+4)
    through its vt+0x60, then 0x28 apart in vs order; q reads a guest qword, call(target, rcx) runs plugin code"""
    vo = call(VO_GET, model)
    pmo = call(q(q(vo) + 0x60), vo, absolute=True)
    vsbase = q(pmo + 0x18) - 4
    obj = {}
    for k in range(-2, 16):
        o = pmo + k * 0x28
        obj[q(o + 0x18) - vsbase] = o
    if not (obj.get(2) == pmo - 2 * 0x28 and 0x08 in obj and 0x16 in obj):
        raise RuntimeError('the vs value objects are not where zoom_fit_gate found them')
    return obj
