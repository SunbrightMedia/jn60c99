/* plate_geom.js -- the geometry of the module plate: placement on the 21 mm grid, cut planning
 * for the printer bed, dovetail joints, watertight meshes, binary STL and a store-only ZIP.
 * Pure functions, no DOM: the page inlines this file, node tests require() it.
 * Frames: PLATE = mm, origin at the panel's top-left seen from the front, +x right, +y DOWN
 * (the same frame as docs/hardware/outlines/*.json). STL = mm, +x right, +y toward the panel's
 * top edge, +z up from the plate's underside (so looking down on the STL shows the front view). */
(function (root) {
  'use strict';
  const node = typeof module !== 'undefined' && module.exports;
  const earcut = node ? require('earcut') : root.earcut;
  const Delaunator = node ? (m => m.default || m)(require('delaunator')) : root.Delaunator;

  const INCH = 25.4;
  const PANEL_W = 19 * INCH;                 // 482.6
  const EAR = (19 - 17.75) * INCH / 2;       // 15.875: rack-ear zone per side, no boards
  const PITCH = 21;                          // the boards' grid
  const HOLE_INSET = 4.25;                   // hole centre to its grid-cell corner (all 15 boards)
  const DEPTHS = [1, 2, 3, 4, 5, 6, 7].map(n => ({ key: n + 'U', label: n + 'U', mm: +(n * 44.45 - 0.79).toFixed(2) }))
    .concat([{ key: 'MAX', label: 'MAX (13 in)', mm: 13 * INCH }]);

  const DEFAULTS = {
    plateT: 3.0,        // plate thickness
    shoulderH: 6.5,     // shoulder top (= board underside) above the plate's top surface
    shoulderD: 7.0,     // shoulder diameter (<= 8: the board corner arc is R4 about the hole)
    footFlare: 0.5,     // extra radius at the shoulder's foot (chamfer into the plate)
    pinD: 3.0,          // pin through the 3.2 mm hole
    pinH: 3.6,          // pin height above the shoulder (board 1.6 + 2.0)
    tabDepth: 7.0, tabNeck: 9.0, tabHead: 13.0, tabSpacing: 45.0,
    clearance: 0.15,    // total gap between two mating joint faces
    maxPiece: 176,      // max piece size on the bed (A1 mini: 180 x 180)
    segs: 48,           // facets per circle
    // front-panel cutouts (see CUTOUTS for the source of each number)
    cutKeyW: 14.0, cutKeyH: 14.0, cutPotD: 7.0, cutSwW: 5.0, cutSwL: 15.0,
    cutBtnW: 13.0, cutBtnL: 17.6, faderTravel: 60.0, faderLeverL: 4.0, faderLeverW: 1.2, faderClear: 0.4,
    minWeb: 1.0, mergeSlots: 1,
    // cap placeholders
    capFaderL: 6.0, capFaderW: 10.0, capKnobD: 15.0, capKey: 18.0, capBtnW: 12.4, capBtnL: 17.0, capLeverD: 4.0,
    labelSize: 5.0,     // panel label font size (mm)
    // lightening holes (honeycomb) in the empty plate
    lighten: 1, ribWidth: 3.5, pillarRib: 5.0, blend: 6.0, ribCurve: 0.09, edgeMargin: 5.0, pillarMargin: 2.0, frameStep: 30.0, maxSpan: 56.0
  };

  /* Front-panel cutout per part kind, in the part's own frame (KiCad footprint frame, y down).
     The centre and angle of every part come from the board files (pcb_outline.py, panel_parts).
     status READ = taken from a drawing; ASSUMED = no drawing yet, measure the part. */
  const CUTOUTS = {
    keyswitch: { label: 'Keyswitch', status: 'READ', shape: p => ({ type: 'rect', w: p.cutKeyW, h: p.cutKeyH }),
      source: 'Kailh PG1511F drawing RHA-PG1511F-004EN: MX-style housing 13.95 x 13.95 below the panel -> 14.0 x 14.0 cutout on the centre post' },
    pot: { label: 'Pot shaft', status: 'READ', shape: p => ({ type: 'circle', d: p.cutPotD }),
      source: 'Alps RK09K1130A70, drawing 7: knurled shaft dia 6 on the line of the two legs -> dia 7 (0.5 per side)' },
    switch: { label: 'Slide switch', status: 'READ', shape: p => ({ type: 'stadium', w: p.cutSwW, h: p.cutSwL }),
      source: 'Footprint F.Fab lever slot 5 x 15 (EasyEDA ground truth TS-23E01AT15), lever dia 4' },
    button: { label: 'PB86-A1 cap', status: 'READ', shape: p => ({ type: 'rect', w: p.cutBtnW, h: p.cutBtnL }),
      source: 'FVWIN PB86-A1 cap 12.4 x 17.0 (footprint silk 12.35 x 17.0) + 0.3 per side' },
    fader: { label: 'Fader slot', status: 'INFERRED',
      shape: p => ({ type: 'stadium', w: p.faderTravel + p.faderLeverL + 2 * p.faderClear, h: p.faderLeverW + 2 * p.faderClear }),
      source: 'Travel 60 (sellers of this exact 75 mm B103 dual: "stroke 60 mm", "4x15 mm shaft"); lever 4.0 x 1.2 (the same lever on the Bourns PTA drawing); slot = travel + lever + clearance each side. Centred on the body: no drawing gives the lever position, so check that the lever stops 30 mm each side of the body centre.' }
  };

  /* ---------- placement ---------- */
  function depthMM(key) { const d = DEPTHS.find(x => x.key === key); return d ? d.mm : DEPTHS[2].mm; }

  function grid(depth) {
    const usable = PANEL_W - 2 * EAR;
    const nx = Math.floor(usable / PITCH + 1e-9), ny = Math.floor(depth / PITCH + 1e-9);
    return { W: PANEL_W, D: depth, ear: EAR, nx, ny, gx0: EAR + (usable - nx * PITCH) / 2, gy0: (depth - ny * PITCH) / 2 };
  }

  // rot = quarter turns clockwise as seen from the front (screen, y down)
  function rotPt(b, rot, x, y) {
    switch (rot & 3) {
      case 0: return [x, y];
      case 1: return [b.h - y, x];
      case 2: return [b.w - x, b.h - y];
      default: return [y, b.w - x];
    }
  }
  function rotMatrix(b, rot) {  // SVG matrix(a b c d e f): x' = a x + c y + e, y' = b x + d y + f
    return [[1, 0, 0, 1, 0, 0], [0, 1, -1, 0, b.h, 0], [-1, 0, 0, -1, b.w, b.h], [0, -1, 1, 0, 0, b.w]][rot & 3];
  }

  // Where an instance sits: its holes on the grid. Returns plate-frame geometry.
  function place(b, inst, g) {
    const rot = inst.rot & 3;
    const W = rot & 1 ? b.h : b.w, H = rot & 1 ? b.w : b.h;
    const holes = b.holes.map(h => rotPt(b, rot, h[0], h[1]));
    const hx = Math.min(...holes.map(p => p[0])), hy = Math.min(...holes.map(p => p[1]));
    const hx1 = Math.max(...holes.map(p => p[0])), hy1 = Math.max(...holes.map(p => p[1]));
    const cellsX = Math.round((hx1 - hx + 2 * HOLE_INSET) / PITCH), cellsY = Math.round((hy1 - hy + 2 * HOLE_INSET) / PITCH);
    const x0 = g.gx0 + inst.cx * PITCH + HOLE_INSET - hx, y0 = g.gy0 + inst.cy * PITCH + HOLE_INSET - hy;
    const m = rotMatrix(b, rot);
    return {
      x0, y0, w: W, h: H, cellsX, cellsY,
      matrix: [m[0], m[1], m[2], m[3], m[4] + x0, m[5] + y0],
      holes: holes.map((p, i) => [p[0] + x0, p[1] + y0, b.holes[i][2]]),
      bbox: [x0, y0, x0 + W, y0 + H],
      poly: b.poly.map(p => { const q = rotPt(b, rot, p[0], p[1]); return [q[0] + x0, q[1] + y0]; })
    };
  }

  function overlap(a, b, gap) {
    gap = gap || 0;
    return a[0] < b[2] - gap && b[0] < a[2] - gap && a[1] < b[3] - gap && b[1] < a[3] - gap;
  }

  // Issues per instance: off the usable area, overlapping, pillars clashing.
  function validate(boards, insts, g, p) {
    const P = insts.map(i => place(boards[i.b], i, g));
    const issues = insts.map(() => []);
    const rf = p.shoulderD / 2 + p.footFlare;
    P.forEach((q, i) => {
      if (q.bbox[0] < g.ear - 1e-6 || q.bbox[2] > g.W - g.ear + 1e-6) issues[i].push('in a rack-ear zone');
      if (q.bbox[1] < -1e-6 || q.bbox[3] > g.D + 1e-6) issues[i].push('past the plate edge');
      q.holes.forEach(h => {
        if (h[1] - rf < 0.4 || h[1] + rf > g.D - 0.4) issues[i].push('a pillar foot reaches the plate edge');
      });
      for (let j = 0; j < P.length; j++) {
        if (j === i) continue;
        if (overlap(q.bbox, P[j].bbox)) issues[i].push('overlaps ' + boards[insts[j].b].name);
        for (const h of q.holes) for (const k of P[j].holes)
          if (Math.hypot(h[0] - k[0], h[1] - k[1]) < 2 * rf + 0.4) { issues[i].push('pillar touches a pillar of ' + boards[insts[j].b].name); break; }
      }
      issues[i] = [...new Set(issues[i])];
    });
    return { placed: P, issues };
  }

  // A board's cutouts in its own frame, axis-aligned (parts turn in 90 degree steps).
  // With p.mergeSlots, cutouts of one kind that would leave less than p.minWeb of metal between
  // them become ONE slot (their bounding box): e.g. the PB86-A1 packs at a 12.5 mm pitch.
  function boardCutouts(b, p) {
    const sh = [];
    for (const [kind, x, y, ang] of (b.parts || [])) {
      const C = CUTOUTS[kind]; if (!C) continue;
      const s = C.shape(p), w = s.type === 'circle' ? s.d : s.w, h = s.type === 'circle' ? s.d : s.h;
      const turned = Math.round(((ang % 180) + 180) % 180) === 90;
      const ex = turned ? h : w, ey = turned ? w : h;
      sh.push({ kind, type: s.type, status: C.status, n: 1, box: [x - ex / 2, y - ey / 2, x + ex / 2, y + ey / 2] });
    }
    if (!p.mergeSlots) return sh;
    const par = sh.map((_, i) => i), f = i => par[i] === i ? i : (par[i] = f(par[i]));
    for (let i = 0; i < sh.length; i++) for (let j = i + 1; j < sh.length; j++)
      if (sh[i].kind === sh[j].kind && gap(sh[i].box, sh[j].box) < p.minWeb) par[f(i)] = f(j);
    const groups = new Map();
    sh.forEach((c, i) => { const r = f(i); groups.set(r, (groups.get(r) || []).concat([c])); });
    return [...groups.values()].map(gr => gr.length === 1 ? gr[0] : {
      kind: gr[0].kind, type: 'rect', status: gr[0].status, n: gr.length,
      box: [Math.min(...gr.map(c => c.box[0])), Math.min(...gr.map(c => c.box[1])), Math.max(...gr.map(c => c.box[2])), Math.max(...gr.map(c => c.box[3]))] });
  }
  function gap(a, b) {      // metal between two boxes (0 when they touch or overlap)
    const dx = Math.max(a[0] - b[2], b[0] - a[2], 0), dy = Math.max(a[1] - b[3], b[1] - a[3], 0);
    return (dx > 0 && dy > 0) ? Math.hypot(dx, dy) : Math.max(dx, dy);
  }

  // Every panel cutout as an axis-aligned box in the plate frame.
  function cutoutBoxes(boards, insts, g, p) {
    const out = [];
    insts.forEach((inst, k) => {
      const m = place(boards[inst.b], inst, g).matrix;
      for (const c of boardCutouts(boards[inst.b], p)) {
        const q = [[c.box[0], c.box[1]], [c.box[2], c.box[3]]].map(([x, y]) => [m[0] * x + m[2] * y + m[4], m[1] * x + m[3] * y + m[5]]);
        out.push(Object.assign({}, c, { inst: k, box: [Math.min(q[0][0], q[1][0]), Math.min(q[0][1], q[1][1]), Math.max(q[0][0], q[1][0]), Math.max(q[0][1], q[1][1])] }));
      }
    });
    return out;
  }

  /* ---------- caps (placeholders; positions from the parts, sizes from params) ----------
     KiCad's footprint angle turns counter-clockwise on screen (y down): the part's own x axis is
     u = (cos a, -sin a), its y axis v = (sin a, cos a). Values per part index k in inst.caps:
     fader 0..1 along the travel, knob 0..1 over 280 degrees (Alps RK09K), switch -1 / 0 / 1. */
  const CAPS = {
    fader: { label: 'Fader cap', source: 'placeholder 6 x 10 for a 4 x 1.2 lever; moves over the travel' },
    pot: { label: 'Knob', source: 'placeholder dia 15 on the 6 mm shaft; 280 degrees (Alps RK09K)' },
    keyswitch: { label: 'Keycap', source: 'MX 1u keycap, 18 x 18 at the base' },
    button: { label: 'PB86-A1 cap', source: 'the part\'s own cap, 12.4 x 17.0 (FVWIN)' },
    switch: { label: 'Switch lever', source: 'lever dia 4 (footprint F.Fab), positions 5 mm apart' }
  };
  function capShapes(b, caps, p) {
    caps = caps || {};
    return (b.parts || []).map(([kind, x, y, ang], k) => {
      const a = ang * Math.PI / 180, u = [Math.cos(a), -Math.sin(a)], v = [Math.sin(a), Math.cos(a)];
      const val = caps[k];
      if (kind === 'fader') {
        const t = val === undefined ? 0.5 : Math.min(1, Math.max(0, val)), d = (t - 0.5) * p.faderTravel;
        return { k, kind, type: 'rect', cx: x + d * u[0], cy: y + d * u[1], w: p.capFaderL, h: p.capFaderW, ang, value: t,
          sweep: { cx: x, cy: y, w: p.faderTravel + p.capFaderL, h: p.capFaderW, ang } };
      }
      if (kind === 'pot') {
        const t = val === undefined ? 0.5 : Math.min(1, Math.max(0, val));
        return { k, kind, type: 'knob', cx: x, cy: y, w: p.capKnobD, h: p.capKnobD, ang, value: t, turn: (t - 0.5) * 280 };
      }
      if (kind === 'keyswitch') return { k, kind, type: 'key', cx: x, cy: y, w: p.capKey, h: p.capKey, ang, value: 0 };
      if (kind === 'button') return { k, kind, type: 'rect', cx: x, cy: y, w: p.capBtnW, h: p.capBtnL, ang, value: 0 };
      if (kind === 'switch') {
        const t = val === undefined ? 0 : Math.max(-1, Math.min(1, Math.round(val)));
        return { k, kind, type: 'lever', cx: x + 5 * t * v[0], cy: y + 5 * t * v[1], w: p.capLeverD, h: p.capLeverD, ang, value: t };
      }
      return null;
    }).filter(Boolean);
  }
  // Plate-frame boxes of every cap over its whole movement (faders: the full sweep), for overlap checks.
  function capBoxes(boards, insts, g, p) {
    const out = [];
    insts.forEach((inst, i) => {
      const m = place(boards[inst.b], inst, g).matrix;
      for (const c of capShapes(boards[inst.b], inst.caps, p)) {
        if (c.kind === 'switch') continue;
        const s = c.sweep || c, a = s.ang * Math.PI / 180, ca = Math.abs(Math.cos(a)), sa = Math.abs(Math.sin(a));
        const ex = s.w * ca + s.h * sa, ey = s.w * sa + s.h * ca;
        const px = m[0] * s.cx + m[2] * s.cy + m[4], py = m[1] * s.cx + m[3] * s.cy + m[5];
        const tx = Math.abs(m[0]) * ex + Math.abs(m[2]) * ey, ty = Math.abs(m[1]) * ex + Math.abs(m[3]) * ey;
        out.push({ inst: i, k: c.k, kind: c.kind, round: c.type === 'knob', box: [px - tx / 2, py - ty / 2, px + tx / 2, py + ty / 2] });
      }
    });
    return out;
  }
  function capOverlaps(boxes) {
    const bad = [];
    for (let i = 0; i < boxes.length; i++) for (let j = i + 1; j < boxes.length; j++) {
      const a = boxes[i], b = boxes[j], A = a.box, B = b.box;
      let hit = A[0] < B[2] && B[0] < A[2] && A[1] < B[3] && B[1] < A[3];
      if (hit && a.round && b.round) hit = Math.hypot((A[0] + A[2] - B[0] - B[2]) / 2, (A[1] + A[3] - B[1] - B[3]) / 2) < (A[2] - A[0] + B[2] - B[0]) / 2;
      if (hit) bad.push([i, j]);
    }
    return bad;
  }

  // Pairs of cutouts with less metal between them than minWeb (mm).
  function cutoutWebs(boxes, minWeb) {
    const bad = [];
    for (let i = 0; i < boxes.length; i++) for (let j = i + 1; j < boxes.length; j++) {
      const a = boxes[i].box, b = boxes[j].box, web = gap(a, b);
      const overlap = a[0] < b[2] && b[0] < a[2] && a[1] < b[3] && b[1] < a[3];
      if (overlap || web < minWeb) bad.push({ i, j, web: overlap ? 0 : web });
    }
    return bad;
  }

  /* ---------- cut planning ---------- */
  // One axis: cut positions in (0, L) so every piece (plus the tab it carries on its far side)
  // fits maxPiece; never inside a forbidden interval; nearest to an even split.
  function planAxis(L, forbidden, p) {
    const t = p.tabDepth, max = p.maxPiece, minPiece = 2 * (p.tabHead + t);
    const ok = x => !forbidden.some(f => x > f[0] && x < f[1]);
    for (let k = Math.max(1, Math.ceil((L - t) / (max - t))); k <= 12; k++) {
      const cuts = []; let prev = 0, fail = false;
      for (let i = 1; i < k; i++) {
        const target = prev + (L - prev) / (k - i + 1);
        const lo = Math.max(prev + minPiece, L - (k - i - 1) * (max - t) - max), hi = Math.min(prev + max - t, L - minPiece);
        let best = null;
        for (let d = 0; d <= Math.max(target - lo, hi - target) + 1e-9 && best === null; d += 0.25)
          for (const x of [target - d, target + d]) if (x >= lo && x <= hi && ok(x)) { best = x; break; }
        if (best === null) { fail = true; break; }
        cuts.push(+best.toFixed(3)); prev = best;
      }
      if (!fail && L - prev <= max + 1e-9) return cuts;
    }
    return null;
  }

  // Tab positions along a cut segment [s0, s1]: away from its ends and from pillars in the band
  // the tabs reach into (pillar coords given along / across the cut, band = [0, t] across).
  function placeTabs(s0, s1, pillarsAlong, p, rAvoid) {
    const end = p.tabHead / 2 + p.tabDepth + 2;
    const a = s0 + end, b = s1 - end;
    if (b < a) return [];
    const n = Math.max(1, Math.round((b - a) / p.tabSpacing) + 1);
    const free = s => pillarsAlong.every(q => Math.abs(q - s) >= p.tabHead / 2 + rAvoid);
    const out = [];
    for (let i = 0; i < n; i++) {
      const s = n === 1 ? (a + b) / 2 : a + (b - a) * i / (n - 1);
      for (let d = 0; d <= p.tabSpacing / 2; d += 0.5) {
        const c = [s - d, s + d].find(x => x >= a && x <= b && free(x) && out.every(o => Math.abs(o - x) >= p.tabHead + 4));
        if (c !== undefined) { out.push(+c.toFixed(3)); break; }
      }
    }
    return out.sort((x, y) => x - y);
  }

  // pillars: [[x, y], ...] in the plate frame
  function planCuts(W, D, pillars, p) {
    const rAvoid = p.shoulderD / 2 + p.footFlare + 1.0 + p.clearance;
    const rows = planAxis(D, pillars.map(q => [q[1] - rAvoid, q[1] + rAvoid]), p);
    if (!rows) return { error: 'No row cut avoids every pillar. Move a board or lower the pillar size.' };
    const ys = [0, ...rows, D];
    const cols = [];
    for (let r = 0; r < ys.length - 1; r++) {
      const band = pillars.filter(q => q[1] > ys[r] - rAvoid && q[1] < ys[r + 1] + rAvoid);
      const c = planAxis(W, band.map(q => [q[0] - rAvoid, q[0] + rAvoid]), p);
      if (!c) return { error: 'No column cut in row ' + (r + 1) + ' avoids every pillar. Move a board.' };
      cols.push(c);
    }
    const warn = [];
    // tabs on vertical cuts: protrude +x into the right piece, band x in [cut, cut + t]
    const tabsV = cols.map((cs, r) => cs.map(x => {
      const near = pillars.filter(q => q[0] > x - rAvoid && q[0] < x + p.tabDepth + rAvoid).map(q => q[1]);
      const tabs = placeTabs(ys[r], ys[r + 1], near, p, rAvoid);
      if (!tabs.length) warn.push('row ' + (r + 1) + ': the cut at x ' + x.toFixed(1) + ' has no joint tab');
      return tabs;
    }));
    // tabs on horizontal cuts: protrude +y into the lower piece; segments between the
    // vertical cuts of BOTH rows next to the cut
    const tabsH = rows.map((y, r) => {
      const xs = [0, ...new Set([...cols[r], ...cols[r + 1]])].sort((a, b) => a - b).concat([W]);
      const near = pillars.filter(q => q[1] > y - rAvoid && q[1] < y + p.tabDepth + rAvoid).map(q => q[0]);
      let all = [];
      for (let i = 0; i < xs.length - 1; i++) all = all.concat(placeTabs(xs[i], xs[i + 1], near, p, rAvoid));
      for (let c = 0; c <= cols[r].length; c++) {          // every upper piece needs one
        const xl = c ? cols[r][c - 1] : 0, xr = c < cols[r].length ? cols[r][c] : W;
        if (!all.some(s => s > xl && s < xr)) warn.push('the cut at y ' + y.toFixed(1) + ' has no tab under piece ' + label(r, c));
      }
      return all;
    });
    return { W, D, rows, ys, cols, tabsV, tabsH, warn };
  }

  function label(r, c) { return String.fromCharCode(65 + r) + (c + 1); }

  /* ---------- piece outlines ---------- */
  // Base outline (no clearance) + per-edge offset; then each cut edge moves c/2 into the piece.
  function pieceOutline(plan, r, c, p) {
    const { W, ys, cols, tabsV, tabsH } = plan;
    const xs = [0, ...cols[r], W];
    const xl = xs[c], xr = xs[c + 1], yt = ys[r], yb = ys[r + 1];
    const t = p.tabDepth, n2 = p.tabNeck / 2, h2 = p.tabHead / 2, d = p.clearance / 2;
    const pts = [], off = [];                       // off[i] = offset of the edge pts[i] -> pts[i+1]
    const add = (x, y, o) => { pts.push([x, y]); off.push(o); };
    const topCut = r > 0, botCut = r < ys.length - 2, leftCut = c > 0, rightCut = c < xs.length - 2;
    // top edge, left -> right (sockets, +y into this piece)
    add(xl, yt, topCut ? d : 0);
    if (topCut) for (const s of tabsH[r - 1].filter(s => s > xl && s < xr))
      { add(s - n2, yt, d); add(s - h2, yt + t, d); add(s + h2, yt + t, d); add(s + n2, yt, d); }
    // right edge, top -> bottom (tabs, +x out of this piece)
    add(xr, yt, rightCut ? d : 0);
    if (rightCut) for (const s of tabsV[r][c])
      { add(xr, s - n2, d); add(xr + t, s - h2, d); add(xr + t, s + h2, d); add(xr, s + n2, d); }
    // bottom edge, right -> left (tabs, +y out of this piece)
    add(xr, yb, botCut ? d : 0);
    if (botCut) for (const s of tabsH[r].filter(s => s > xl && s < xr).reverse())
      { add(s + n2, yb, d); add(s + h2, yb + t, d); add(s - h2, yb + t, d); add(s - n2, yb, d); }
    // left edge, bottom -> top (sockets, +x into this piece)
    add(xl, yb, leftCut ? d : 0);
    if (leftCut) for (const s of tabsV[r][c - 1].slice().reverse())
      { add(xl, s + n2, d); add(xl + t, s + h2, d); add(xl + t, s - h2, d); add(xl, s - n2, d); }
    return { rect: [xl, yt, xr, yb], poly: offsetPoly(pts, off) };
  }

  function area(poly) { let a = 0; for (let i = 0; i < poly.length; i++) { const p = poly[i], q = poly[(i + 1) % poly.length]; a += p[0] * q[1] - q[0] * p[1]; } return a / 2; }

  // Move each edge by its own distance toward the interior; vertices = adjacent lines' intersections.
  function offsetPoly(pts, off) {
    const n = pts.length, s = area(pts) > 0 ? 1 : -1;
    const lines = pts.map((p, i) => {
      const q = pts[(i + 1) % n], L = Math.hypot(q[0] - p[0], q[1] - p[1]);
      const u = [(q[0] - p[0]) / L, (q[1] - p[1]) / L], nr = [-u[1] * s, u[0] * s];   // interior normal
      return { p: [p[0] + nr[0] * off[i], p[1] + nr[1] * off[i]], u };
    });
    return pts.map((_, i) => {
      const A = lines[(i - 1 + n) % n], B = lines[i];
      const cr = A.u[0] * B.u[1] - A.u[1] * B.u[0];
      if (Math.abs(cr) < 1e-12) return B.p.slice();
      const k = ((B.p[0] - A.p[0]) * B.u[1] - (B.p[1] - A.p[1]) * B.u[0]) / cr;
      return [A.p[0] + A.u[0] * k, A.p[1] + A.u[1] * k];
    });
  }

  function buildPieces(plan, pillars, p) {
    const out = [];
    for (let r = 0; r < plan.ys.length - 1; r++) for (let c = 0; c <= plan.cols[r].length; c++) {
      const o = pieceOutline(plan, r, c, p);
      const [xl, yt, xr, yb] = o.rect;
      const xsP = o.poly.map(q => q[0]), ysP = o.poly.map(q => q[1]);
      const bb = [Math.min(...xsP), Math.min(...ysP), Math.max(...xsP), Math.max(...ysP)];
      const pc = { id: label(r, c), r, c, rect: o.rect, poly: o.poly, bbox: bb,
        size: [bb[2] - bb[0], bb[3] - bb[1]],
        pillars: pillars.filter(q => q[0] > xl && q[0] < xr && q[1] > yt && q[1] < yb) };
      pc.holes = lightenHoles(pc, p);
      out.push(pc);
    }
    return out;
  }

  /* Lightening holes, organic. The plate keeps material only where load runs:
       - a solid frame along the piece's outline (p.edgeMargin wide: edges, tabs, sockets),
       - a solid ring round every pillar foot (p.pillarMargin),
       - ribs: each board's pillars joined in a ring (the board's seat), and every pillar joined to its
         nearest neighbours and to the frame (the Gabriel graph of pillars + frame nodes: only short,
         direct links), plus extra nodes where a gap spans more than p.maxSpan. A rib is p.pillarRib
         wide at a pillar and tapers to p.ribWidth elsewhere.
     All of it is merged with a smooth minimum of the two nearest shapes (blend radius p.blend): every
     joint gets a fillet, nothing gets bulk elsewhere, and the holes come out as smooth, organic shapes. The holes are the contours of that field (marching
     squares, 0.5 mm grid), pushed 0.25 mm into the void. Plate frame; each hole is a closed polygon.
     pillars: [x, y, board index]. */
  function lightenHoles(pc, p) {
    if (!p.lighten || !Delaunator) return [];
    p = Object.assign({}, p, { edgeMargin: Math.max(2.5, p.edgeMargin), ribWidth: Math.max(2, p.ribWidth), pillarMargin: Math.max(1, p.pillarMargin), blend: Math.max(0.3, p.blend) });
    const [xl, yt, xr, yb] = pc.rect, rf = p.shoulderD / 2 + p.footFlare, kp = rf + p.pillarMargin;
    const fx0 = xl + p.edgeMargin + (pc.c > 0 ? p.tabDepth : 0), fy0 = yt + p.edgeMargin + (pc.r > 0 ? p.tabDepth : 0);
    const fx1 = xr - p.edgeMargin, fy1 = yb - p.edgeMargin;
    if (fx1 - fx0 < 20 || fy1 - fy0 < 20) return [];
    // nodes: pillars (kind 1), frame (kind 0), extra (kind 2)
    const N = [];
    const add = (x, y, kind, board) => { if (N.every(q => Math.hypot(q.x - x, q.y - y) > 1.5)) N.push({ x, y, kind, board }); };
    // pillars closer than 12 mm (neighbouring boards' corners, 8.5 mm apart) are ONE node of the rib graph,
    // so two boards share one rail instead of two parallel rails with a solid band between them
    const cl = [];
    for (const q of pc.pillars) {
      const c = cl.find(c => c.pts.some(r => Math.hypot(r[0] - q[0], r[1] - q[1]) < 12));
      if (c) c.pts.push(q); else cl.push({ pts: [q] });
    }
    for (const c of cl) {
      const x = c.pts.reduce((t, q) => t + q[0], 0) / c.pts.length, y = c.pts.reduce((t, q) => t + q[1], 0) / c.pts.length;
      N.push({ x, y, kind: 1, boards: [...new Set(c.pts.map(q => q[2]))] });
    }
    const side = (x0, y0, x1, y1) => { const L = Math.hypot(x1 - x0, y1 - y0), n = Math.max(1, Math.round(L / p.frameStep));
      for (let i = 0; i < n; i++) add(x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n, 0); };
    side(fx0, fy0, fx1, fy0); side(fx1, fy0, fx1, fy1); side(fx1, fy1, fx0, fy1); side(fx0, fy1, fx0, fy0);
    let tri;
    // open areas = big empty circles (a Delaunay triangle's circumcircle holds no node): while one is
    // wider than p.maxSpan, put a node at its centre (or the triangle's centroid if that is outside)
    for (let it = 0; it < 150; it++) {
      tri = Delaunator.from(N.map(q => [q.x, q.y])).triangles;
      const cand = [];
      for (let t = 0; t < tri.length; t += 3) {
        const A = N[tri[t]], B = N[tri[t + 1]], C = N[tri[t + 2]];
        const dd = 2 * (A.x * (B.y - C.y) + B.x * (C.y - A.y) + C.x * (A.y - B.y)); if (Math.abs(dd) < 1e-9) continue;
        const a2 = A.x * A.x + A.y * A.y, b2 = B.x * B.x + B.y * B.y, c2 = C.x * C.x + C.y * C.y;
        const ux = (a2 * (B.y - C.y) + b2 * (C.y - A.y) + c2 * (A.y - B.y)) / dd, uy = (a2 * (C.x - B.x) + b2 * (A.x - C.x) + c2 * (B.x - A.x)) / dd;
        const R = Math.hypot(A.x - ux, A.y - uy);
        if (R > p.maxSpan / 2) cand.push([R, (ux > fx0 && ux < fx1 && uy > fy0 && uy < fy1) ? [ux, uy] : [(A.x + B.x + C.x) / 3, (A.y + B.y + C.y) / 3]]);
      }
      cand.sort((a, b) => b[0] - a[0]);
      const n0 = N.length;
      for (const c of cand) { add(c[1][0], c[1][1], 2); if (N.length > n0) break; }   // the widest circle that takes a node
      if (N.length === n0) break;
    }
    tri = Delaunator.from(N.map(q => [q.x, q.y])).triangles;
    // ribs: Gabriel edges (no node inside the circle on the edge as diameter), never frame-to-frame
    const ribs = new Map();
    const addRib = (i, j, seat) => { const k = i < j ? i + ',' + j : j + ',' + i; if (!ribs.has(k) || seat) ribs.set(k, [Math.min(i, j), Math.max(i, j), !!seat]); };
    for (let t = 0; t < tri.length; t += 3) for (let e = 0; e < 3; e++) {
      const i = tri[t + e], j = tri[t + (e + 1) % 3], A = N[i], B = N[j];
      if (A.kind === 0 && B.kind === 0) continue;
      // an open-area node always keeps its links (they are what splits the open area)
      if ((A.kind === 2 || B.kind === 2) && Math.hypot(A.x - B.x, A.y - B.y) <= p.maxSpan) { addRib(i, j); continue; }
      const mx = (A.x + B.x) / 2, my = (A.y + B.y) / 2, r2 = ((A.x - B.x) ** 2 + (A.y - B.y) ** 2) / 4;
      if (N.every((q, k) => k === i || k === j || (q.x - mx) ** 2 + (q.y - my) ** 2 >= r2 - 1e-9)) addRib(i, j);
    }
    const boards = new Map();
    N.forEach((q, i) => { if (q.kind === 1) for (const bd of q.boards) boards.set(bd, (boards.get(bd) || []).concat([i])); });
    for (const ids of boards.values()) {       // the board's seat: its pillars in a ring
      if (ids.length < 2) continue;
      const cx = ids.reduce((t, i) => t + N[i].x, 0) / ids.length, cy = ids.reduce((t, i) => t + N[i].y, 0) / ids.length;
      const ring = ids.slice().sort((a, b) => Math.atan2(N[a].y - cy, N[a].x - cx) - Math.atan2(N[b].y - cy, N[b].x - cx));
      for (let k = 0; k < ring.length; k++) if (ring.length > 2 || k === 0) addRib(ring[k], ring[(k + 1) % ring.length], true);
    }
    const rOf = q => (q.kind === 1 ? p.pillarRib : p.ribWidth) / 2;
    // every rib but a board's seat bows sideways by p.ribCurve of its length (a quadratic curve, side
    // alternating), the way topology-optimised members run; drawn as 8 straight pieces
    const caps = [...ribs.values()].map(([i, j, seat]) => {
      const a = N[i], b = N[j], L = Math.hypot(b.x - a.x, b.y - a.y), bow = seat ? 0 : p.ribCurve * L * ((i * 7 + j * 3) % 2 ? 1 : -1);
      const cx = (a.x + b.x) / 2 - (b.y - a.y) / L * bow, cy = (a.y + b.y) / 2 + (b.x - a.x) / L * bow;
      const pts = []; for (let s = 0; s <= 8; s++) { const t = s / 8, u = 1 - t; pts.push([u * u * a.x + 2 * u * t * cx + t * t * b.x, u * u * a.y + 2 * u * t * cy + t * t * b.y, t]); }
      return { pts, ra: rOf(a), rb: rOf(b) };
    });
    // field on a grid: the two smallest signed distances per cell, joined by a polynomial smooth min
    const h = 0.5, k = p.blend, x0 = pc.bbox[0] - 1, y0 = pc.bbox[1] - 1;
    const W = Math.ceil((pc.bbox[2] - x0 + 1) / h) + 1, H = Math.ceil((pc.bbox[3] - y0 + 1) / h) + 1;
    const D1 = new Float64Array(W * H).fill(1e9), D2 = new Float64Array(W * H).fill(1e9), poly = pc.poly, np = poly.length;
    const reach = k + 2;             // farther than this a shape cannot reach the surface (F = 0)
    const put = (idx, d) => { if (d < D1[idx]) { D2[idx] = D1[idx]; D1[idx] = d; } else if (d < D2[idx]) D2[idx] = d; };
    const splat = (bx0, by0, bx1, by1, dist) => {
      const i0 = Math.max(0, Math.floor((bx0 - reach - x0) / h)), i1 = Math.min(W - 1, Math.ceil((bx1 + reach - x0) / h));
      const j0 = Math.max(0, Math.floor((by0 - reach - y0) / h)), j1 = Math.min(H - 1, Math.ceil((by1 + reach - y0) / h));
      for (let j = j0; j <= j1; j++) for (let i = i0; i <= i1; i++) {
        const d = dist(x0 + i * h, y0 + j * h); if (d < reach) put(j * W + i, d);
      }
    };
    // one rib = ONE shape: the hard min over its 8 pieces (no bulk at their joints). Each piece fills a
    // scratch grid over its own small box; the rib's box is then folded into the two-nearest arrays.
    const R = new Float64Array(W * H).fill(Infinity);
    for (const c of caps) {
      let bi0 = W, bi1 = 0, bj0 = H, bj1 = 0;
      for (let s = 0; s < 8; s++) {
        const A = c.pts[s], B = c.pts[s + 1], vx = B[0] - A[0], vy = B[1] - A[1], L2 = vx * vx + vy * vy;
        const rr = Math.max(c.ra, c.rb) + reach;
        const i0 = Math.max(0, Math.floor((Math.min(A[0], B[0]) - rr - x0) / h)), i1 = Math.min(W - 1, Math.ceil((Math.max(A[0], B[0]) + rr - x0) / h));
        const j0 = Math.max(0, Math.floor((Math.min(A[1], B[1]) - rr - y0) / h)), j1 = Math.min(H - 1, Math.ceil((Math.max(A[1], B[1]) + rr - y0) / h));
        bi0 = Math.min(bi0, i0); bi1 = Math.max(bi1, i1); bj0 = Math.min(bj0, j0); bj1 = Math.max(bj1, j1);
        for (let j = j0; j <= j1; j++) for (let i = i0; i <= i1; i++) {
          const x = x0 + i * h, y = y0 + j * h;
          const u = L2 ? Math.max(0, Math.min(1, ((x - A[0]) * vx + (y - A[1]) * vy) / L2)) : 0, t = A[2] + (B[2] - A[2]) * u;
          const d = Math.hypot(x - A[0] - u * vx, y - A[1] - u * vy) - (c.ra + (c.rb - c.ra) * t), idx = j * W + i;
          if (d < R[idx]) R[idx] = d;
        }
      }
      for (let j = bj0; j <= bj1; j++) for (let i = bi0; i <= bi1; i++) {
        const idx = j * W + i; if (R[idx] < reach) put(idx, R[idx]); R[idx] = Infinity;
      }
    }
    for (const q of pc.pillars) splat(q[0], q[1], q[0], q[1], (x, y) => Math.hypot(x - q[0], y - q[1]) - kp);
    const inside = (x, y) => { let c = false; for (let i = 0, j = np - 1; i < np; j = i++) {
      const a = poly[i], b = poly[j]; if ((a[1] > y) !== (b[1] > y) && x < (b[0] - a[0]) * (y - a[1]) / (b[1] - a[1]) + a[0]) c = !c; } return c; };
    const edgeDist = (x, y) => { let d = Infinity; for (let i = 0; i < np; i++) {
      const a = poly[i], b = poly[(i + 1) % np], vx = b[0] - a[0], vy = b[1] - a[1], L = vx * vx + vy * vy;
      const t = L ? Math.max(0, Math.min(1, ((x - a[0]) * vx + (y - a[1]) * vy) / L)) : 0;
      d = Math.min(d, Math.hypot(x - a[0] - t * vx, y - a[1] - t * vy)); } return d; };
    // the solid frame = everything outside the inner rounded rectangle (fx0..fx1, fy0..fy1): it holds the
    // outline, the tabs, the sockets, and the frame nodes, so no rib ever ends in open space
    // (a rib that did, on the socket sides, left a 2.7 mm tip between two holes -- seen, 2026-10-15)
    const cxr = (fx0 + fx1) / 2, cyr = (fy0 + fy1) / 2, hx = (fx1 - fx0) / 2, hy = (fy1 - fy0) / 2, rr = Math.min(8, hx, hy);
    const F = new Float64Array(W * H), iso = 0.25;
    for (let j = 0; j < H; j++) for (let i = 0; i < W; i++) {
      const idx = j * W + i, x = x0 + i * h, y = y0 + j * h;
      const qx = Math.abs(x - cxr) - (hx - rr), qy = Math.abs(y - cyr) - (hy - rr);
      const sdBox = Math.hypot(Math.max(qx, 0), Math.max(qy, 0)) + Math.min(Math.max(qx, qy), 0) - rr;   // > 0 outside
      if (sdBox >= 0) { F[idx] = -1; continue; }
      if (-sdBox < reach) put(idx, -sdBox);
      const a = D1[idx], b = D2[idx], m = Math.max(k - Math.abs(a - b), 0) / k;
      F[idx] = Math.min(a, b) - m * m * k / 4 - iso;                  // > 0: void (a hole)
    }
    // drop slivers: mean width (2 x area / perimeter) under 3 mm
    const perim = l => l.reduce((t, v, i) => t + Math.hypot(l[(i + 1) % l.length][0] - v[0], l[(i + 1) % l.length][1] - v[1]), 0);
    const holes = marchingSquares(F, W, H, x0, y0, h).map(l => simplify(l, 0.04))
      .filter(l => l.length >= 4 && Math.abs(area(l)) > 25 && 2 * Math.abs(area(l)) / perim(l) >= 3);
    // the contour must keep every margin; any hole that does not is left solid
    const segDist = (x, y, a, b) => { const vx = b[0] - a[0], vy = b[1] - a[1], L = vx * vx + vy * vy;
      const t = L ? Math.max(0, Math.min(1, ((x - a[0]) * vx + (y - a[1]) * vy) / L)) : 0; return Math.hypot(x - a[0] - t * vx, y - a[1] - t * vy); };
    return holes.filter(hole => hole.every(([x, y]) => inside(x, y) && edgeDist(x, y) >= p.edgeMargin - 1e-6) &&
      pc.pillars.every(q => hole.every((v, i) => segDist(q[0], q[1], v, hole[(i + 1) % hole.length]) >= kp - 1e-6)));
  }

  // Closed contours of F > 0 (grid W x H, origin x0, y0, step h). Saddles split by the cell centre.
  function marchingSquares(F, W, H, x0, y0, h) {
    const val = (i, j) => F[j * W + i];
    const pt = (key) => {
      const [t, i, j] = key.split(':'); const a = +i, b = +j;
      if (t === 'h') { const v0 = val(a, b), v1 = val(a + 1, b), u = v0 / (v0 - v1); return [x0 + (a + u) * h, y0 + b * h]; }
      const v0 = val(a, b), v1 = val(a, b + 1), u = v0 / (v0 - v1); return [x0 + a * h, y0 + (b + u) * h];
    };
    const adj = new Map(), link = (p, q) => { (adj.get(p) || adj.set(p, []).get(p)).push(q); (adj.get(q) || adj.set(q, []).get(q)).push(p); };
    for (let j = 0; j < H - 1; j++) for (let i = 0; i < W - 1; i++) {
      const a = val(i, j) > 0, b = val(i + 1, j) > 0, c = val(i + 1, j + 1) > 0, d = val(i, j + 1) > 0;
      const code = (a ? 1 : 0) | (b ? 2 : 0) | (c ? 4 : 0) | (d ? 8 : 0);
      if (code === 0 || code === 15) continue;
      const T = 'h:' + i + ':' + j, B = 'h:' + i + ':' + (j + 1), L = 'v:' + i + ':' + j, R = 'v:' + (i + 1) + ':' + j;
      const centre = (val(i, j) + val(i + 1, j) + val(i + 1, j + 1) + val(i, j + 1)) / 4 > 0;
      switch (code) {
        case 1: case 14: link(L, T); break;
        case 2: case 13: link(T, R); break;
        case 4: case 11: link(R, B); break;
        case 8: case 7: link(B, L); break;
        case 3: case 12: link(L, R); break;
        case 6: case 9: link(T, B); break;
        case 5: if (centre) { link(L, B); link(T, R); } else { link(L, T); link(R, B); } break;
        case 10: if (centre) { link(L, T); link(R, B); } else { link(L, B); link(T, R); } break;
      }
    }
    const seen = new Set(), loops = [];
    for (const start of adj.keys()) {
      if (seen.has(start)) continue;
      const loop = []; let prev = null, cur = start;
      while (cur && !seen.has(cur)) { seen.add(cur); loop.push(pt(cur)); const nx = adj.get(cur).find(q => q !== prev && !seen.has(q)); prev = cur; cur = nx; }
      if (loop.length >= 3) loops.push(loop);
    }
    return loops;
  }

  // Ramer-Douglas-Peucker on a closed loop.
  function simplify(loop, tol) {
    if (loop.length < 8) return loop;
    const rdp = (pts) => {
      if (pts.length < 3) return pts;
      const a = pts[0], b = pts[pts.length - 1], vx = b[0] - a[0], vy = b[1] - a[1], L = Math.hypot(vx, vy) || 1;
      let mi = 0, md = 0;
      for (let i = 1; i < pts.length - 1; i++) { const d = Math.abs((pts[i][0] - a[0]) * vy - (pts[i][1] - a[1]) * vx) / L; if (d > md) { md = d; mi = i; } }
      if (md <= tol) return [a, b];
      const l = rdp(pts.slice(0, mi + 1)), r = rdp(pts.slice(mi));
      return l.slice(0, -1).concat(r);
    };
    const half = loop.length >> 1;
    return rdp(loop.slice(0, half + 1)).slice(0, -1).concat(rdp(loop.slice(half).concat([loop[0]])).slice(0, -1));
  }

  // Signed volume of a closed triangle mesh (mm^3).
  function meshVolume(tri) {
    let v = 0;
    for (let i = 0; i < tri.length; i += 9)
      v += tri[i] * (tri[i + 4] * tri[i + 8] - tri[i + 5] * tri[i + 7]) - tri[i + 1] * (tri[i + 3] * tri[i + 8] - tri[i + 5] * tri[i + 6]) + tri[i + 2] * (tri[i + 3] * tri[i + 7] - tri[i + 4] * tri[i + 6]);
    return v / 6;
  }

  /* ---------- meshes ---------- */
  // Triangles as flat array of 9 numbers each, STL frame, outward winding.
  function pieceMesh(piece, D, p) {
    const T = p.plateT, N = p.segs, tri = [];
    const S = q => [q[0], D - q[1]];                      // plate -> STL (y up)
    let outer = piece.poly.map(S);
    if (area(outer) < 0) outer.reverse();                 // CCW seen from +z
    const rf = p.shoulderD / 2 + p.footFlare, rs = p.shoulderD / 2, rp = p.pinD / 2;
    const ringPts = (cx, cy, r) => { const a = []; for (let j = 0; j < N; j++) { const th = 2 * Math.PI * j / N; a.push([cx + r * Math.cos(th), cy + r * Math.sin(th)]); } return a; };
    const holes = piece.pillars.map(q => { const c = S(q); return { c, ring: ringPts(c[0], c[1], rf) }; });
    const push = (a, b, c) => tri.push(a[0], a[1], a[2], b[0], b[1], b[2], c[0], c[1], c[2]);
    const face = (rings, z, up) => {      // rings[0] outer, rest holes; triangulate and orient
      const flat = [], hi = [], all = [];
      rings.forEach((rg, k) => { if (k) hi.push(all.length); rg.forEach(v => { flat.push(v[0], v[1]); all.push(v); }); });
      const ix = earcut(flat, hi.length ? hi : null);
      // earcut winds all its triangles one way: decide the flip ONCE from the total signed area
      // (a per-triangle test flips zero-area slivers at random and breaks the mesh -- seen, 2026-10-15)
      let tot = 0;
      for (let i = 0; i < ix.length; i += 3) { const a = all[ix[i]], b = all[ix[i + 1]], c = all[ix[i + 2]]; tot += (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]); }
      const flip = (tot > 0) !== up;
      for (let i = 0; i < ix.length; i += 3) {
        let a = all[ix[i]], b = all[ix[i + 1]], c = all[ix[i + 2]];
        if (flip) { const tmp = b; b = c; c = tmp; }
        push([a[0], a[1], z], [b[0], b[1], z], [c[0], c[1], z]);
      }
    };
    // lightening holes: through the plate, CLOCKWISE seen from +z so the wall formula below faces into the hole
    const hex = (piece.holes || []).map(h => { const r = h.map(S); return area(r) > 0 ? r.reverse() : r; });
    face([outer, ...hex], 0, false);
    face([outer, ...holes.map(h => h.ring.slice().reverse()), ...hex], T, true);
    for (const ring of [outer, ...hex]) for (let i = 0; i < ring.length; i++) {
      const a = ring[i], b = ring[(i + 1) % ring.length];
      push([a[0], a[1], 0], [b[0], b[1], 0], [b[0], b[1], T]);
      push([a[0], a[1], 0], [b[0], b[1], T], [a[0], a[1], T]);
    }
    // pillar = one surface of revolution standing on the hole ring
    const zs = T + p.shoulderH, ch = Math.min(0.5, p.pinH / 3);
    const prof = [[rf, T], [rs, T + Math.max(0.01, p.footFlare)], [rs, zs], [rp, zs], [rp, zs + p.pinH - ch], [Math.max(0.2, rp - 0.4), zs + p.pinH]];
    for (const h of holes) {
      const rings = prof.map((pr, k) => k === 0 ? h.ring.map(v => [v[0], v[1], T]) :
        ringPts(h.c[0], h.c[1], pr[0]).map(v => [v[0], v[1], pr[1]]));
      for (let k = 0; k < rings.length - 1; k++) for (let j = 0; j < N; j++) {
        const a = rings[k][j], b = rings[k][(j + 1) % N], c = rings[k + 1][(j + 1) % N], d = rings[k + 1][j];
        push(a, b, c); push(a, c, d);
      }
      const top = rings[rings.length - 1], ctr = [h.c[0], h.c[1], prof[prof.length - 1][1]];
      for (let j = 0; j < N; j++) push(ctr, top[j], top[(j + 1) % N]);
    }
    return tri;
  }

  function stl(tri, name) {
    const n = tri.length / 9, buf = new ArrayBuffer(84 + 50 * n), dv = new DataView(buf);
    const hdr = ('module plate ' + (name || '')).slice(0, 79);
    for (let i = 0; i < hdr.length; i++) dv.setUint8(i, hdr.charCodeAt(i));
    dv.setUint32(80, n, true);
    for (let i = 0, o = 84; i < n; i++, o += 50) {
      const t = tri.slice(i * 9, i * 9 + 9);
      const ux = t[3] - t[0], uy = t[4] - t[1], uz = t[5] - t[2], vx = t[6] - t[0], vy = t[7] - t[1], vz = t[8] - t[2];
      let nx = uy * vz - uz * vy, ny = uz * vx - ux * vz, nz = ux * vy - uy * vx; const L = Math.hypot(nx, ny, nz) || 1;
      dv.setFloat32(o, nx / L, true); dv.setFloat32(o + 4, ny / L, true); dv.setFloat32(o + 8, nz / L, true);
      for (let k = 0; k < 9; k++) dv.setFloat32(o + 12 + 4 * k, t[k], true);
    }
    return new Uint8Array(buf);
  }

  /* ---------- joint test coupons: the same joint code, three clearances ---------- */
  function coupons(p) {
    const out = [];
    for (const dc of [-0.05, 0, 0.05]) {
      const c = Math.max(0, +(p.clearance + dc).toFixed(3));
      const q = Object.assign({}, p, { clearance: c, lighten: 0 });
      const W = 2 * (p.tabHead + p.tabDepth) + 24, D = p.tabHead + 2 * (p.tabDepth + 2) + 12;
      const plan = { W, D, rows: [], ys: [0, D], cols: [[W / 2]], tabsV: [[[D / 2]]], tabsH: [] };
      const pieces = buildPieces(plan, [], q);
      out.push({ clearance: c, pieces: pieces.map(pc => ({ id: pc.id, tri: pieceMesh(pc, D, q) })) });
    }
    return out;
  }

  /* ---------- store-only ZIP ---------- */
  const CRC = (() => { const t = new Uint32Array(256); for (let n = 0; n < 256; n++) { let c = n; for (let k = 0; k < 8; k++) c = c & 1 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1; t[n] = c >>> 0; } return t; })();
  function crc32(u8) { let c = 0xFFFFFFFF; for (let i = 0; i < u8.length; i++) c = CRC[(c ^ u8[i]) & 255] ^ (c >>> 8); return (c ^ 0xFFFFFFFF) >>> 0; }
  function zip(files) {   // files: [{name, data: Uint8Array | string}]
    const enc = s => typeof TextEncoder !== 'undefined' ? new TextEncoder().encode(s) : Buffer.from(s, 'utf8');
    const parts = [], central = []; let off = 0;
    for (const f of files) {
      const data = typeof f.data === 'string' ? enc(f.data) : f.data, name = enc(f.name), crc = crc32(data);
      const h = new DataView(new ArrayBuffer(30));
      h.setUint32(0, 0x04034b50, true); h.setUint16(4, 20, true); h.setUint16(8, 0, true);
      h.setUint16(10, 0, true); h.setUint16(12, 0x21, true);
      h.setUint32(14, crc, true); h.setUint32(18, data.length, true); h.setUint32(22, data.length, true);
      h.setUint16(26, name.length, true);
      parts.push(new Uint8Array(h.buffer), name, data);
      const c = new DataView(new ArrayBuffer(46));
      c.setUint32(0, 0x02014b50, true); c.setUint16(4, 20, true); c.setUint16(6, 20, true);
      c.setUint16(14, 0x21, true); c.setUint32(16, crc, true); c.setUint32(20, data.length, true);
      c.setUint32(24, data.length, true); c.setUint16(28, name.length, true); c.setUint32(42, off, true);
      central.push(new Uint8Array(c.buffer), name);
      off += 30 + name.length + data.length;
    }
    const csize = central.reduce((s, a) => s + a.length, 0);
    const e = new DataView(new ArrayBuffer(22));
    e.setUint32(0, 0x06054b50, true); e.setUint16(8, files.length, true); e.setUint16(10, files.length, true);
    e.setUint32(12, csize, true); e.setUint32(16, off, true);
    const all = parts.concat(central, [new Uint8Array(e.buffer)]);
    const out = new Uint8Array(all.reduce((s, a) => s + a.length, 0)); let k = 0;
    for (const a of all) { out.set(a, k); k += a.length; }
    return out;
  }

  const api = { meshVolume, lightenHoles, marchingSquares, CUTOUTS, CAPS, capShapes, capBoxes, capOverlaps, boardCutouts, cutoutBoxes, cutoutWebs, INCH, PANEL_W, EAR, PITCH, HOLE_INSET, DEPTHS, DEFAULTS, depthMM, grid, place, rotMatrix,
    validate, planCuts, buildPieces, pieceMesh, stl, coupons, zip, crc32, area, label };
  if (typeof module !== 'undefined' && module.exports) module.exports = api; else root.PlateGeom = api;
})(typeof window !== 'undefined' ? window : globalThis);
