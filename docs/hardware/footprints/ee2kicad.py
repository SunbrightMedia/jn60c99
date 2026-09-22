#!/usr/bin/env python3
"""Mechanical EasyEDA-Std footprint JSON -> KiCad 8 .kicad_mod, plus the two TS-22E01 pins.
Units: EasyEDA Std = 10 mil = 0.254 mm, origin (head.x, head.y). Y is down in both tools."""
import json, re, sys, math
src, dst = sys.argv[1], sys.argv[2]
J = json.load(open(src)); ox, oy = J['head']['x'], J['head']['y']; U = 0.254
mm = lambda v: round(v*U, 4)
X = lambda x: mm(float(x)-ox); Y = lambda y: mm(float(y)-oy)
LAYER = {'3': 'F.SilkS', '12': 'F.Fab'}
pads, gfx = [], []
for s in J['shape']:
    f = s.split('~')
    if f[0] == 'PAD':
        shape, x, y, w, h, layer, net, num, hr = f[1], f[2], f[3], f[4], f[5], f[6], f[7], f[8], float(f[9])
        hl = float(f[13]) if f[13] else 0.0
        hp = f[14].split() if f[14] else []
        assert layer == '11', 'not a through-hole pad'
        if shape == 'ELLIPSE':
            assert hl == 0 and f[4] == f[5]
            pads.append(dict(num=num or 'MP', shape='circle', x=X(x), y=Y(y), sx=mm(float(w)), sy=mm(float(h)), dx=mm(2*hr), dy=None, src=f[12]))
        elif shape == 'OVAL':
            # slot: total length hl, width 2*hr; orientation from the hole end points
            x1, y1, x2, y2 = map(float, hp); vertical = abs(x1-x2) < 1e-6
            assert abs(math.hypot(x2-x1, y2-y1) - (hl-2*hr)) < 0.01, 'slot geometry'
            dx, dy = (mm(2*hr), mm(hl)) if vertical else (mm(hl), mm(2*hr))
            pads.append(dict(num=num or 'MP', shape='oval', x=X(x), y=Y(y), sx=mm(float(w)), sy=mm(float(h)), dx=dx, dy=dy, src=f[12]))
        else: raise SystemExit('unhandled pad shape '+shape)
    elif f[0] == 'TRACK':
        w, layer, pts = float(f[1]), f[2], list(map(float, f[4].split()))
        for i in range(0, len(pts)-2, 2):
            gfx.append(('line', LAYER[layer], mm(w), X(pts[i]), Y(pts[i+1]), X(pts[i+2]), Y(pts[i+3])))
    elif f[0] == 'ARC':
        w, layer, path = float(f[1]), f[2], f[4]
        m = re.match(r'M([\d.]+),([\d.]+) A([\d.]+),([\d.]+) 0 (\d) (\d) ([\d.]+),([\d.]+)', path)
        x1, y1, rx, ry, large, sweep, x2, y2 = m.groups(); x1, y1, rx, x2, y2 = map(float, (x1, y1, rx, x2, y2))
        chord = math.hypot(x2-x1, y2-y1); assert abs(chord-2*rx) < 0.01, 'only semicircles handled'
        cx, cy = (x1+x2)/2, (y1+y2)/2
        # mid point: perpendicular to the chord; sweep=1 is clockwise on screen (y down)
        ux, uy = (x2-x1)/chord, (y2-y1)/chord
        nx, ny = (-uy, ux) if sweep == '1' else (uy, -ux)   # clockwise: rotate chord dir by -90 in y-down coords
        mx, my = cx - nx*rx, cy - ny*rx
        gfx.append(('arc', LAYER[layer], mm(w), X(x1), Y(y1), X(mx), Y(my), X(x2), Y(y2)))
    elif f[0] == 'CIRCLE':
        cx, cy, r, w, layer = float(f[1]), float(f[2]), float(f[3]), float(f[4]), f[5]
        gfx.append(('circle', LAYER[layer], mm(w), X(cx), Y(cy), mm(r)))
    else: raise SystemExit('unhandled shape '+f[0])
truth_pads = [dict(p) for p in pads]
# THE TWO ADDED PINS (TS-22E01): same style as the truth's signal pads, at y = -2.5 mm, between 1A/A and 1B/B.
ref = next(p for p in pads if p['num'] == 'A'); refB = next(p for p in pads if p['num'] == 'B')
for num, base in (('4A', ref), ('4B', refB)):
    pads.append(dict(num=num, shape='circle', x=base['x'], y=-2.5, sx=base['sx'], sy=base['sy'], dx=base['dx'], dy=None, src='ADDED'))
name = 'SW_Slide_Daier_TS-22E01_TS-23E01_Universal_v3'
out = ['(footprint "%s"' % name, '\t(version 20240108)', '\t(generator "ee2kicad")', '\t(layer "F.Cu")',
 '\t(descr "GROUND TRUTH = EasyEDA user footprint TS-23E01AT15 - DP3T TOGGLE (uuid 049d1afee5f74202a17ce9fccec31389, contributor Nick Graham), converted mechanically (10 mil = 0.254 mm, origin 4000/3000): 8 signal pads 1.5 mm round / 1.0 mm drill (1A A 2A 3A at x -2.6, y -5/0/+2.5/+5; 1B B 2B 3B at x +2.6), 4 bracket-leg slots 2x3 mm pad, 0.8x1.7 mm slot, at (+/-5.5, +/-10.0), silk 12.6x23, fab stadium 5x15 + lever circle d4. ADDED for the Daier TS-22E01 (2-pos, 6 pins, centred -2.5/0/+2.5): pads 4A and 4B at y = -2.5, same size as the signal pads. Universal grid per row: -5 / -2.5 / 0 / +2.5 / +5. TS-23E01 uses 1A A 2A 3A (+B row); TS-22E01 uses 4A A 2A (+B row). Bracket legs are numbered MP (unnumbered in the source) so they can be tied to GND. Courtyard, reference and value are KiCad additions.")',
 '\t(tags "slide switch DPDT 2P2T 2P3T lever Daier TS-22E01 TS-23E01 TS-22E01AT15 TS-23E01AT15 universal easyeda")',
 '\t(attr through_hole)',
 '\t(fp_text reference "SW" (at 0 -12.7) (layer "F.SilkS") (effects (font (size 1 1) (thickness 0.15))))',
 '\t(fp_text value "TS-22E01/TS-23E01" (at 0 12.7) (layer "F.Fab") (effects (font (size 1 1) (thickness 0.15))))',
 '\t(fp_text user "${REFERENCE}" (at 0 9) (layer "F.Fab") (effects (font (size 0.8 0.8) (thickness 0.12))))']
for g in gfx:
    if g[0] == 'line': out.append('\t(fp_line (start %s %s) (end %s %s) (stroke (width %s) (type default)) (layer "%s"))' % (g[3], g[4], g[5], g[6], g[2], g[1]))
    elif g[0] == 'arc': out.append('\t(fp_arc (start %s %s) (mid %s %s) (end %s %s) (stroke (width %s) (type default)) (layer "%s"))' % (g[3], g[4], g[5], g[6], g[7], g[8], g[2], g[1]))
    elif g[0] == 'circle': out.append('\t(fp_circle (center %s %s) (end %s %s) (stroke (width %s) (type default)) (fill none) (layer "%s"))' % (g[3], g[4], g[3]+g[5], g[4], g[2], g[1]))
out.append('\t(fp_rect (start -6.8 -11.8) (end 6.8 11.8) (stroke (width 0.05) (type default)) (fill none) (layer "F.CrtYd"))')
for p in pads:
    drill = '(drill %s)' % p['dx'] if p['shape'] == 'circle' else '(drill oval %s %s)' % (p['dx'], p['dy'])
    out.append('\t(pad "%s" thru_hole %s (at %s %s) (size %s %s) %s (layers "*.Cu" "*.Mask") (remove_unused_layers no))' % (p['num'], p['shape'], p['x'], p['y'], p['sx'], p['sy'], drill))
out.append(')')
open(dst, 'w').write('\n'.join(out) + '\n')
json.dump(dict(truth=truth_pads, added=pads[len(truth_pads):], gfx=gfx), open(dst + '.check.json', 'w'), indent=1)
print('wrote', dst, len(truth_pads), 'truth pads +', len(pads)-len(truth_pads), 'added;', len(gfx), 'graphics')
