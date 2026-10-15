#!/usr/bin/env python3
"""check_cases.py CASEDIR -- grade make_cases.js's STLs with code that shares nothing with plate_geom.js:
trimesh (mesh health), shapely (joint gaps, coverage), and hole positions recomputed here from the
KiCad-derived JSON + each board's (cell, rotation). Exit 1 on any failure."""
import json, math, os, sys
import numpy as np, trimesh
from shapely.geometry import Polygon, box, Point
from shapely.ops import unary_union

D_ = sys.argv[1]
OUT = os.path.join(os.path.dirname(__file__), '../../../../docs/hardware/outlines')
if D_.endswith('.zip'):
    # a zip saved by the page itself: its layout.json + STLs; the depth recomputed here from its key
    import zipfile, tempfile
    tmp = tempfile.mkdtemp(); zipfile.ZipFile(D_).extractall(tmp)
    lay = json.load(open(os.path.join(tmp, 'layout.json')))
    dk = lay['depth']; D = 13 * 25.4 if dk == 'MAX' else int(dk[:-1]) * 44.45 - 0.79
    stls = sorted(f for f in os.listdir(tmp) if f.endswith('.stl'))
    man = [{'depth': dk, 'W': 19 * 25.4, 'D': D, 'params': lay['params'], 'insts': lay['boards'],
            'files': [{'file': f, 'id': f.rsplit('_', 1)[1][:-4], 'size': None} for f in stls]}]
    D_ = tmp
else:
    man = json.load(open(os.path.join(D_, 'manifest.json')))
fails = []
def bad(msg): fails.append(msg); print('FAIL', msg)

def expected_holes(case):
    """Spec, written independently: rotate the board by quarter turns clockwise (front view, y
    down), put its top-left hole 4.25 mm from its cell corner, the grid centred between the ears."""
    W, D, ear = 19 * 25.4, case['D'], 1.25 * 25.4 / 2
    usable = W - 2 * ear; nx = int(usable // 21 + 1e-9); ny = int(D // 21 + 1e-9)
    gx0, gy0 = ear + (usable - nx * 21) / 2, (D - ny * 21) / 2
    out = []
    for i in case['insts']:
        j = json.load(open(os.path.join(OUT, i['name'] + '.json')))
        w, h = j['width'], j['height']
        pts = [(hh['x'], hh['y']) for hh in j['holes']]
        for _ in range(i['rot']):             # one clockwise quarter turn: (x, y) -> (H - y, x)
            pts = [(h - y, x) for x, y in pts]; w, h = h, w
        mx, my = min(p[0] for p in pts), min(p[1] for p in pts)
        ox, oy = gx0 + i['cx'] * 21 + 4.25 - mx, gy0 + i['cy'] * 21 + 4.25 - my
        bb = (ox, oy, ox + w, oy + h)
        if bb[0] < ear - 1e-6 or bb[2] > W - ear + 1e-6 or bb[1] < -1e-6 or bb[3] > D + 1e-6:
            bad('%s %s: board outside the usable area %s' % (case['depth'], i['name'], bb))
        out += [(x + ox, D - (y + oy)) for x, y in pts]   # STL frame
    return out

for case in man:
    p, D, W = case['params'], case['D'], case['W']
    zt = p['plateT'] + p['shoulderH'] + p['pinH']
    exp = expected_holes(case)
    secs, tops = {}, []
    for f in case['files']:
        m = trimesh.load(os.path.join(D_, f['file']), process=True)
        tag = '%s %s' % (case['depth'], f['id'])
        if not m.is_watertight: bad(tag + ': not watertight')
        if not m.is_winding_consistent: bad(tag + ': winding inconsistent')
        if m.volume <= 0: bad(tag + ': volume <= 0 (inside out)')
        if m.body_count != 1: bad(tag + ': %d bodies (pillars not joined to the plate?)' % m.body_count)
        ext = m.bounds[1] - m.bounds[0]
        if ext[0] > p['maxPiece'] + 1e-6 or ext[1] > p['maxPiece'] + 1e-6: bad(tag + ': %.2f x %.2f over the bed limit' % tuple(ext[:2]))
        if f['size'] and max(abs(ext[0] - f['size'][0]), abs(ext[1] - f['size'][1])) > 1e-3: bad(tag + ': size report differs from the mesh')
        if m.bounds[0][2] != 0: bad(tag + ': underside not at z 0')
        sec = m.section(plane_origin=[0, 0, p['plateT'] / 2], plane_normal=[0, 0, 1])
        polys = sec.to_2D()[0].polygons_full if sec is not None else []
        T = sec.to_2D()[1] if sec is not None else None
        # back to world xy
        polys = [Polygon([tuple((T @ [x, y, 0, 1])[:2]) for x, y in pg.exterior.coords]) for pg in polys]
        if len(polys) != 1: bad(tag + ': plate section has %d parts' % len(polys))
        secs[f['id']] = polys[0] if polys else Polygon()
        v = m.vertices[np.isclose(m.vertices[:, 2], zt, atol=1e-4)]
        if len(v):
            # cluster top vertices (pins are > 8 mm apart)
            cl = []
            for q in v:
                for c in cl:
                    if math.hypot(q[0] - c[0][0], q[1] - c[0][1]) < 3: c.append(q); break
                else: cl.append([q])
            for c in cl:
                c = np.array(c); tops.append((c[:, 0].mean(), c[:, 1].mean(), f['id']))
    # every expected hole has exactly one pillar, at the right place
    for e in exp:
        hits = [t for t in tops if math.hypot(t[0] - e[0], t[1] - e[1]) < 0.01]
        if len(hits) != 1: bad('%s: hole at %.3f,%.3f has %d pillars' % (case['depth'], e[0], e[1], len(hits)))
    if len(tops) != len(exp): bad('%s: %d pillars for %d holes' % (case['depth'], len(tops), len(exp)))
    rf = p['shoulderD'] / 2 + p['footFlare']
    for t in tops:
        s = secs[t[2]]
        if s.exterior.distance(Point(t[0], t[1])) < rf + 0.5: bad('%s %s: pillar foot at %.1f,%.1f too near a cut' % (case['depth'], t[2], t[0], t[1]))
    # joints: no overlap, gap = clearance on every shared cut, nothing missing
    ids = list(secs); c = p['clearance']; adj = 0
    for i in range(len(ids)):
        for k in range(i + 1, len(ids)):
            a, b = secs[ids[i]], secs[ids[k]]
            if a.intersection(b).area > 1e-6: bad('%s %s/%s overlap' % (case['depth'], ids[i], ids[k]))
            d = a.distance(b)
            if d < c + 0.05:
                adj += 1
                if abs(d - c) > 2e-3: bad('%s %s/%s gap %.4f, want %.4f' % (case['depth'], ids[i], ids[k], d, c))
                # the gap must be c along the whole joint: the two outlines grown by c/2 must meet but not overlap much
                ov = a.buffer(c / 2 + 1e-4, join_style=2).intersection(b.buffer(c / 2 + 1e-4, join_style=2)).area
                if ov <= 0: bad('%s %s/%s do not meet' % (case['depth'], ids[i], ids[k]))
    plate = box(0, 0, W, D)
    hole = plate.difference(unary_union([s.buffer(c / 2 + 1e-3, join_style=2) for s in secs.values()])).area
    if hole > 0.5: bad('%s: %.2f mm^2 of the plate not covered by any piece' % (case['depth'], hole))
    out_ = unary_union(list(secs.values())).difference(plate).area
    if out_ > 0.01: bad('%s: pieces reach outside the plate by %.4f mm^2' % (case['depth'], out_))
    print('  outside-plate area %.6f mm^2 (float32 rounding of the STL)' % out_)
    print('%-4s %d pieces, %d joints, %d pillars checked, max %.1f mm' % (case['depth'], len(ids), adj, len(tops),
          max(max(f['size']) if f['size'] else 0 for f in case['files'])))

# coupons: each pair mates with its own clearance
import glob, re
for f in sorted(glob.glob(os.path.join(D_, 'coupon_c*_A1.stl'))):
    c = float(re.search(r'coupon_c([\d.]+)_', f).group(1))
    pr = [trimesh.load(x) for x in (f, f.replace('_A1', '_A2'))]
    for m in pr:
        if not (m.is_watertight and m.volume > 0): bad(os.path.basename(f) + ': coupon mesh bad')
    s = [Polygon(m.section([0, 0, 1], [0, 0, 0]).to_2D()[0].polygons_full[0].exterior.coords) for m in pr]
    # to_planar keeps xy for a z-plane section up to a translation; use world coords instead
    s = []
    for m in pr:
        sec = m.section(plane_origin=[0, 0, 1], plane_normal=[0, 0, 1]); pl, T = sec.to_2D()
        s.append(Polygon([tuple((T @ [x, y, 0, 1])[:2]) for x, y in pl.polygons_full[0].exterior.coords]))
    d = s[0].distance(s[1])
    if abs(d - c) > 2e-3: bad('coupon %.2f: gap %.4f' % (c, d))
    else: print('coupon clearance %.2f: gap %.4f OK' % (c, d))
print('RESULT', 'FAIL (%d)' % len(fails) if fails else 'PASS')
sys.exit(1 if fails else 0)
