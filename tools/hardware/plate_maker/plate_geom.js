/* plate_geom.js -- the geometry of the module plate: placement on the 21 mm grid, cut planning
 * for the printer bed, dovetail joints, watertight meshes, binary STL and a store-only ZIP.
 * Pure functions, no DOM: the page inlines this file, node tests require() it.
 * Frames: PLATE = mm, origin at the panel's top-left seen from the front, +x right, +y DOWN
 * (the same frame as docs/hardware/outlines/*.json). STL = mm, +x right, +y toward the panel's
 * top edge, +z up from the plate's underside (so looking down on the STL shows the front view). */
(function (root) {
  'use strict';
  const earcut = (typeof module !== 'undefined' && module.exports) ? require('earcut') : root.earcut;

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
    labelSize: 5.0      // panel label font size (mm)
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
      out.push({ id: label(r, c), r, c, rect: o.rect, poly: o.poly, bbox: bb,
        size: [bb[2] - bb[0], bb[3] - bb[1]],
        pillars: pillars.filter(q => q[0] > xl && q[0] < xr && q[1] > yt && q[1] < yb) });
    }
    return out;
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
      for (let i = 0; i < ix.length; i += 3) {
        let a = all[ix[i]], b = all[ix[i + 1]], c = all[ix[i + 2]];
        const cz = (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]);
        if ((cz > 0) !== up) { const tmp = b; b = c; c = tmp; }
        push([a[0], a[1], z], [b[0], b[1], z], [c[0], c[1], z]);
      }
    };
    face([outer], 0, false);
    face([outer, ...holes.map(h => h.ring.slice().reverse())], T, true);
    for (let i = 0; i < outer.length; i++) {
      const a = outer[i], b = outer[(i + 1) % outer.length];
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
      const q = Object.assign({}, p, { clearance: c });
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

  const api = { CUTOUTS, CAPS, capShapes, capBoxes, capOverlaps, boardCutouts, cutoutBoxes, cutoutWebs, INCH, PANEL_W, EAR, PITCH, HOLE_INSET, DEPTHS, DEFAULTS, depthMM, grid, place, rotMatrix,
    validate, planCuts, buildPieces, pieceMesh, stl, coupons, zip, crc32, area, label };
  if (typeof module !== 'undefined' && module.exports) module.exports = api; else root.PlateGeom = api;
})(typeof window !== 'undefined' ? window : globalThis);
