#!/usr/bin/env python3
"""pcb_outline.py -- one layered SVG + one JSON per .kicad_pcb, for the case/plate maker.

Usage: python3 tools/hardware/pcb_outline.py INPUT [INPUT...] -o OUTDIR [--tooth]
  INPUT = a .kicad_pcb, a folder (searched recursively) or a .zip of project folders.
Needs KiCad 10 (kicad-cli + the pcbnew Python module); see docs/hardware/outlines/README.md.

Every number comes from KiCad itself: pcbnew's API (outline primitives, holes) and kicad-cli's
SVG plot (silkscreen). Frame: origin = board bounding-box top-left, +x right, +y DOWN (KiCad's),
units mm, viewed from the FRONT (back silk is NOT mirrored: it is where it sits under the board).
Self-check: the kicad-cli Edge.Cuts plot and pcbnew's outline must give the same box (two paths);
--tooth shifts one path by 0.01 mm and the check must then FAIL.
"""
import argparse, json, math, os, re, subprocess, sys, tempfile, zipfile

import pcbnew

GRID = 21.0          # the user's grid pitch (42 = 2 cells)
HOLE_MIN_MM = 2.0    # a hole this big or larger in a MountingHole footprint is a screw hole
NM = 1e6


def mm(v):
    return round(v / NM, 6)


def find_boards(inputs, tmp):
    out = []
    for inp in inputs:
        if inp.endswith('.zip'):
            d = os.path.join(tmp, 'unz%d' % len(out))
            with zipfile.ZipFile(inp) as z:
                z.extractall(d)
            inp = d
        if os.path.isfile(inp):
            out.append(inp)
            continue
        for root, dirs, files in os.walk(inp):
            dirs[:] = [x for x in dirs if not x.endswith('-backups') and not x.startswith('.')]
            for f in files:
                if f.endswith('.kicad_pcb') and not f.startswith('_autosave'):
                    out.append(os.path.join(root, f))
    return sorted(out)


def edge_primitives(board):
    prims = []
    for d in board.GetDrawings():
        if d.GetLayer() != pcbnew.Edge_Cuts or not isinstance(d, pcbnew.PCB_SHAPE):
            continue
        s = d.GetShape()
        p = lambda v: [mm(v.x), mm(v.y)]
        if s == pcbnew.SHAPE_T_SEGMENT:
            prims.append({'type': 'line', 'start': p(d.GetStart()), 'end': p(d.GetEnd())})
        elif s == pcbnew.SHAPE_T_ARC:
            prims.append({'type': 'arc', 'start': p(d.GetStart()), 'mid': p(d.GetArcMid()),
                          'end': p(d.GetEnd()), 'center': p(d.GetCenter()), 'radius': mm(d.GetRadius())})
        elif s == pcbnew.SHAPE_T_CIRCLE:
            prims.append({'type': 'circle', 'center': p(d.GetCenter()), 'radius': mm(d.GetRadius())})
        elif s == pcbnew.SHAPE_T_RECTANGLE:
            prims.append({'type': 'rect', 'start': p(d.GetStart()), 'end': p(d.GetEnd())})
        elif s == pcbnew.SHAPE_T_POLY:
            pts = d.GetPolyShape().Outline(0)
            prims.append({'type': 'poly', 'points': [p(pts.CPoint(i)) for i in range(pts.PointCount())]})
        else:
            prims.append({'type': 'unsupported', 'kicad_shape': int(s)})
    return prims


def plot_layers(pcb, tmp):
    d = tempfile.mkdtemp(dir=tmp)
    r = subprocess.run(['kicad-cli', 'pcb', 'export', 'svg', '-l', 'Edge.Cuts,F.Silkscreen,B.Silkscreen',
                        '--mode-multi', '--page-size-mode', '1', '--exclude-drawing-sheet',
                        '--black-and-white', '--drill-shape-opt', '0', '-o', d, pcb],
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit('kicad-cli failed on %s:\n%s' % (pcb, r.stdout + r.stderr))
    got = {}
    for f in os.listdir(d):
        for key, tag in (('edge', 'Edge_Cuts'), ('silk_front', 'F_Silkscreen'), ('silk_back', 'B_Silkscreen')):
            if f.endswith('-%s.svg' % tag):
                got[key] = open(os.path.join(d, f)).read()
    return got


def svg_body(svg):
    """The drawing groups of a kicad-cli SVG (page coordinates in mm, viewBox 0 0 W H)."""
    if not re.search(r'viewBox="0\.0000 0\.0000 [\d.]+ [\d.]+"', svg):
        sys.exit('unexpected kicad-cli SVG frame (viewBox) -- the mm frame assumption no longer holds')
    i = svg.index('</desc>') + len('</desc>')
    return svg[i:svg.rindex('</svg>')].strip()


def svg_path_box(svg):
    xs, ys = [], []
    for d in re.findall(r'<path d="([^"]+)"', svg):
        # endpoints only: for M/L the pairs; for A the last pair of each arc command
        for cmd, args in re.findall(r'([MLA])([^MLA]*)', d):
            v = [float(x) for x in args.split()]
            pts = [v[-2:]] if cmd == 'A' else [v[i:i + 2] for i in range(0, len(v) - 1, 2)]
            for x, y in pts:
                xs.append(x); ys.append(y)
    return (min(xs), min(ys), max(xs), max(ys)) if xs else None


def grid_fit(size):
    n = max(1, round(size / GRID))
    return {'cells': n, 'cell_mm': n * GRID, 'margin_per_side_mm': round((n * GRID - size) / 2, 4)}


def process(pcb, outdir, tmp, tooth):
    name = os.path.splitext(os.path.basename(pcb))[0]
    board = pcbnew.LoadBoard(pcb)
    if board is None:
        sys.exit('pcbnew could not load %s (KiCad version too old for the file?)' % pcb)
    ps = pcbnew.SHAPE_POLY_SET()
    if not board.GetBoardPolygonOutlines(ps, False) or ps.OutlineCount() != 1:
        sys.exit('%s: the Edge.Cuts outline is not ONE closed shape' % name)
    bb = ps.BBox()
    x0, y0, w, h = mm(bb.GetX()), mm(bb.GetY()), mm(bb.GetWidth()), mm(bb.GetHeight())

    holes, notes = [], []
    for fp in board.Footprints():
        lib = str(fp.GetFPID().GetLibItemName())
        for p in fp.Pads():
            ds = p.GetDrillSize()
            if ds.x <= 0:
                continue
            if 'MountingHole' in lib and ds.x >= HOLE_MIN_MM * NM:
                if ds.x != ds.y:
                    notes.append('%s: slotted hole %.3fx%.3f' % (fp.GetReference(), mm(ds.x), mm(ds.y)))
                pos = p.GetPosition()
                holes.append({'ref': fp.GetReference(), 'x': round(mm(pos.x) - x0, 6), 'y': round(mm(pos.y) - y0, 6),
                              'diameter': mm(ds.x), 'plated': p.GetAttribute() != pcbnew.PAD_ATTRIB_NPTH,
                              'footprint': lib})
    holes.sort(key=lambda hh: (round(hh['y'], 3), hh['x']))
    if len(holes) != 4:
        notes.append('expected 4 mounting holes, found %d' % len(holes))

    layers = plot_layers(pcb, tmp)
    ebox = svg_path_box(layers['edge'])
    shift = 0.01 if tooth else 0.0
    if ebox is None or max(abs(ebox[0] + shift - x0), abs(ebox[1] - y0),
                           abs(ebox[2] + shift - (x0 + w)), abs(ebox[3] - (y0 + h))) > 0.002:
        sys.exit('%s: SELF-CHECK FAILED: kicad-cli edge box %s (+%.2f mm tooth shift) != pcbnew box %s'
                 % (name, ebox, shift, (x0, y0, x0 + w, y0 + h)))

    prims = edge_primitives(board)
    for pr in prims:
        for k in ('start', 'mid', 'end', 'center'):
            if k in pr:
                pr[k] = [round(pr[k][0] - x0, 6), round(pr[k][1] - y0, 6)]
        if 'points' in pr:
            pr['points'] = [[round(a - x0, 6), round(b - y0, 6)] for a, b in pr['points']]
    if any(pr['type'] == 'unsupported' for pr in prims):
        notes.append('Edge.Cuts has a shape type this tool does not export (see edge_primitives)')
    o = ps.Outline(0)
    poly = [[round(mm(o.CPoint(i).x) - x0, 4), round(mm(o.CPoint(i).y) - y0, 4)] for i in range(o.PointCount())]

    info = {'name': name, 'source': os.path.basename(pcb), 'kicad_version': pcbnew.Version(),
            'frame': 'mm; origin = board bbox top-left; +x right, +y down; seen from the front',
            'kicad_origin_mm': [x0, y0], 'width': w, 'height': h,
            'grid': {'pitch_mm': GRID, 'x': grid_fit(w), 'y': grid_fit(h)},
            'thickness': mm(board.GetDesignSettings().GetBoardThickness()),
            'holes': holes, 'edge_primitives': prims, 'outline_polygon': poly, 'notes': notes}

    t = 'translate(%.4f %.4f)' % (-x0, -y0)
    hole_svg = '\n'.join('<circle cx="%.4f" cy="%.4f" r="%.4f" data-ref="%s"/>' % (hh['x'], hh['y'], hh['diameter'] / 2, hh['ref'])
                         for hh in holes)
    lay = lambda lid, label, body, style='': (
        '<g id="%s" inkscape:groupmode="layer" inkscape:label="%s"%s>\n%s\n</g>' % (lid, label, style, body))
    svg = '\n'.join([
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"',
        '  width="%.4fmm" height="%.4fmm" viewBox="0 0 %.4f %.4f" data-board="%s">' % (w, h, w, h, name),
        '<title>%s</title>' % name,
        lay('silk_back', 'Silkscreen back (not mirrored)', '<g transform="%s">%s</g>' % (t, svg_body(layers['silk_back'])),
            ' style="opacity:0.5"'),
        lay('silk_front', 'Silkscreen front', '<g transform="%s">%s</g>' % (t, svg_body(layers['silk_front']))),
        lay('edge', 'Board edge', '<g transform="%s">%s</g>' % (t, svg_body(layers['edge']))),
        lay('holes', 'Mounting holes', hole_svg, ' style="fill:none;stroke:#000;stroke-width:0.05"'),
        '</svg>', ''])
    with open(os.path.join(outdir, name + '.svg'), 'w') as f:
        f.write(svg)
    with open(os.path.join(outdir, name + '.json'), 'w') as f:
        json.dump(info, f, indent=1)
    return info


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('inputs', nargs='+')
    ap.add_argument('-o', '--outdir', required=True)
    ap.add_argument('--tooth', action='store_true', help='shift one path 0.01 mm: the self-check must fail')
    a = ap.parse_args()
    os.makedirs(a.outdir, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        boards = find_boards(a.inputs, tmp)
        names = [os.path.basename(b) for b in boards]
        dup = sorted({n for n in names if names.count(n) > 1})
        if dup:
            sys.exit('two files with the same board name: %s -- remove the stale one' % dup)
        index = []
        for pcb in boards:
            i = process(pcb, a.outdir, tmp, a.tooth)
            index.append({k: i[k] for k in ('name', 'width', 'height', 'grid', 'notes')} |
                         {'holes': [[hh['x'], hh['y'], hh['diameter']] for hh in i['holes']]})
            print('%-28s %7.3f x %7.3f mm  grid %dx%d  margin x %.3f y %.3f  holes %d %s' % (
                i['name'], i['width'], i['height'], i['grid']['x']['cells'], i['grid']['y']['cells'],
                i['grid']['x']['margin_per_side_mm'], i['grid']['y']['margin_per_side_mm'], len(i['holes']),
                ('NOTES: ' + '; '.join(i['notes'])) if i['notes'] else ''))
        with open(os.path.join(a.outdir, 'index.json'), 'w') as f:
            json.dump(index, f, indent=1)


if __name__ == '__main__':
    main()
