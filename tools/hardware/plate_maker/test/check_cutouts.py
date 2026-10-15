#!/usr/bin/env python3
"""check_cutouts.py CUTOUTS_DRAWN.json -- grade the panel cutouts the PAGE drew against the KiCad
files themselves: pcbnew finds each panel part in docs/hardware/user_boards/pcb_2026-09-22, this
script places it with its own placement code, and every drawn cutout must sit there (0.01 mm)
with the right extent. Run in its own process (pcbnew)."""
import json, math, os, sys
import pcbnew
HERE = os.path.dirname(os.path.abspath(__file__))
PCB = os.path.join(HERE, '../../../../docs/hardware/user_boards/pcb_2026-09-22')
d = json.load(open(sys.argv[1])); lay = d['layout']; P = lay['params']
W, ear = 19 * 25.4, 1.25 * 25.4 / 2
D = 13 * 25.4 if lay['depth'] == 'MAX' else int(lay['depth'][:-1]) * 44.45 - 0.79
usable = W - 2 * ear; nx = int(usable // 21 + 1e-9); ny = int(D // 21 + 1e-9)
gx0, gy0 = ear + (usable - nx * 21) / 2, (D - ny * 21) / 2
# size (along footprint x, along footprint y) per kind, from the page's own parameters
SIZE = {'keyswitch': (P['cutKeyW'], P['cutKeyH']), 'pot': (P['cutPotD'], P['cutPotD']), 'switch': (P['cutSwW'], P['cutSwL']),
        'button': (P['cutBtnW'], P['cutBtnL']), 'fader': (P['cutFaderL'], P['cutFaderW'])}
cache = {}
def parts_of(name):
    if name in cache: return cache[name]
    b = pcbnew.LoadBoard(os.path.join(PCB, name, name + '.kicad_pcb'))
    ps = pcbnew.SHAPE_POLY_SET(); b.GetBoardPolygonOutlines(ps, False); bb = ps.BBox()
    x0, y0, w, h = bb.GetX() / 1e6, bb.GetY() / 1e6, bb.GetWidth() / 1e6, bb.GetHeight() / 1e6
    holes = [(p.GetPosition().x / 1e6 - x0, p.GetPosition().y / 1e6 - y0) for fp in b.Footprints() if 'MountingHole' in str(fp.GetFPID().GetLibItemName()) for p in fp.Pads()]
    out = []
    for fp in b.Footprints():
        n = str(fp.GetFPID().GetLibItemName()); pads = list(fp.Pads())
        if 'CPG1511' in n: k = 'keyswitch'; c = [p.GetPosition() for p in pads if p.GetDrillSize().x > 3e6][0]; c = (c.x / 1e6, c.y / 1e6)
        elif 'RK09K' in n: k = 'pot'; q = [p.GetPosition() for p in pads if p.GetNumber() in ('4', '5')]; c = ((q[0].x + q[1].x) / 2e6, (q[0].y + q[1].y) / 2e6)
        elif 'SW_Slide' in n: k = 'switch'; c = (fp.GetPosition().x / 1e6, fp.GetPosition().y / 1e6)
        elif 'PB_86' in n: k = 'button'; c = (fp.GetPosition().x / 1e6, fp.GetPosition().y / 1e6)
        elif 'Fader' in n: k = 'fader'; c = (fp.GetPosition().x / 1e6, fp.GetPosition().y / 1e6)
        else: continue
        out.append((k, c[0] - x0, c[1] - y0, fp.GetOrientationDegrees() % 180))
    cache[name] = (w, h, holes, out); return cache[name]
exp = []
for i in lay['boards']:
    w, h, holes, parts = parts_of(i['name'])
    for (k, x, y, ang) in parts:
        sx, sy = SIZE[k]
        if round(ang) % 180 == 90: sx, sy = sy, sx
        pts, ww, hh = holes + [(x, y)], w, h
        for _ in range(i['rot']):
            pts = [(hh - py, px) for px, py in pts]; ww, hh = hh, ww
            sx, sy = sy, sx
        hs, (px, py) = pts[:-1], pts[-1]
        ox = gx0 + i['cx'] * 21 + 4.25 - min(p[0] for p in hs); oy = gy0 + i['cy'] * 21 + 4.25 - min(p[1] for p in hs)
        exp.append((i['id'], k, px + ox, py + oy, sx, sy))
got = d['cutouts']; fails = 0
for e in exp:
    m = [g for g in got if g['inst'] == e[0] and math.hypot(g['x'] - e[2], g['y'] - e[3]) < 0.01]
    if len(m) != 1 or abs(m[0]['w'] - e[4]) > 0.01 or abs(m[0]['h'] - e[5]) > 0.01:
        fails += 1; print('FAIL', e, m[:1])
if len(got) != len(exp): fails += 1; print('FAIL drawn %d cutouts, expected %d' % (len(got), len(exp)))
kinds = sorted({e[1] for e in exp}); rots = sorted({i['rot'] for i in lay['boards']})
print('%d cutouts checked, kinds %s, board turns %s' % (len(exp), kinds, rots))
print('RESULT', 'FAIL' if fails else 'PASS'); sys.exit(1 if fails else 0)
