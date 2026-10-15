#!/usr/bin/env python3
"""build.py -- make plate_maker.html (one self-contained page) from app.html + plate_geom.js +
the board outlines in docs/hardware/outlines/ (KiCad-derived, see its README).

Usage: python3 tools/hardware/plate_maker/build.py
The silkscreen of each board is cut out of its outline SVG (layers silk_front / silk_back) and
embedded as an SVG data URI, recoloured to white silk."""
import base64, json, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, '../../../docs/hardware/outlines'))
SILK = '#F3F1E8'


def layer(svg, lid, nxt):
    m = re.search(r'<g id="%s"[^>]*>(.*?)</g>\s*<g id="%s"' % (lid, nxt), svg, re.S)
    if not m:
        raise SystemExit('layer %s not found' % lid)
    return m.group(1)


def data_uri(body, w, h):
    body = body.replace('#000000', SILK)
    s = ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %g %g" width="%g" height="%g">%s</svg>'
         % (w, h, w, h, body))
    return 'data:image/svg+xml;base64,' + base64.b64encode(s.encode()).decode()


def main():
    boards = []
    for e in json.load(open(os.path.join(OUT, 'index.json'))):
        j = json.load(open(os.path.join(OUT, e['name'] + '.json')))
        svg = open(os.path.join(OUT, e['name'] + '.svg')).read()
        w, h = j['width'], j['height']
        boards.append({
            'name': j['name'], 'w': w, 'h': h,
            'holes': [[x['x'], x['y'], x['diameter']] for x in j['holes']],
            'poly': [[round(a, 3), round(b, 3)] for a, b in j['outline_polygon']],
            'parts': [[q['kind'], q['x'], q['y'], q['angle']] for q in j.get('panel_parts', []) if not q['back']],
            'silkF': data_uri(layer(svg, 'silk_front', 'edge'), w, h),
            'silkB': data_uri(layer(svg, 'silk_back', 'silk_front'), w, h),
        })
    boards.sort(key=lambda b: b['name'].lower())
    page = open(os.path.join(HERE, 'app.html')).read()
    geom = open(os.path.join(HERE, 'plate_geom.js')).read()
    page = page.replace('/*@GEOM@*/', geom).replace('/*@BOARDS@*/null', json.dumps(boards, separators=(',', ':')))
    for tag in ('/*@GEOM@*/', '/*@BOARDS@*/'):
        assert tag not in page
    dst = os.path.join(HERE, 'plate_maker.html')
    open(dst, 'w').write(page)
    print('%s: %d boards, %.2f MB' % (dst, len(boards), len(page) / 1e6))


if __name__ == '__main__':
    main()
