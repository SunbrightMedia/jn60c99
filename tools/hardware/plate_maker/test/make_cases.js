// make_cases.js OUTDIR [--tooth] -- builds plates from the real board outlines with plate_geom.js
// and writes STLs + a manifest for check_cases.py (the independent checker).
// --tooth: one piece's joint gets NO clearance; the checker must then fail.
const fs = require('fs'), path = require('path');
const G = require('../plate_geom.js');
const out = process.argv[2], tooth = process.argv.includes('--tooth');
// --tooth-holes: holes cut with smaller margins and ribs than the manifest claims; the checker must fail
const toothHoles = process.argv.includes('--tooth-holes'), noHoles = process.argv.includes('--no-holes');
const dir = path.join(__dirname, '../../../../docs/hardware/outlines');
const boards = JSON.parse(fs.readFileSync(path.join(dir, 'index.json'))).map(e => {
  const j = JSON.parse(fs.readFileSync(path.join(dir, e.name + '.json')));
  return { name: j.name, w: j.width, h: j.height, holes: j.holes.map(h => [h.x, h.y, h.diameter]), poly: j.outline_polygon };
});
function autoPlace(depthKey, rots) {
  const g = G.grid(G.depthMM(depthKey)), p = G.DEFAULTS, insts = [];
  boards.forEach((b, bi) => {
    const rot = rots ? rots[bi % rots.length] : 0;
    for (let cy = 0; cy < g.ny; cy++) for (let cx = 0; cx < g.nx; cx++) {
      const inst = { b: bi, cx, cy, rot };
      if (!G.validate(boards, insts.concat([inst]), g, p).issues.some(x => x.length)) { insts.push(inst); return; }
    }
  });
  return { g, insts };
}
fs.mkdirSync(out, { recursive: true });
const cases = [['MAX', null], ['3U', null], ['7U', [0, 1, 2, 3]], ['1U', null]];
const manifest = [];
for (const [dk, rots] of cases) {
  const { g, insts } = autoPlace(dk, rots), p = Object.assign({}, G.DEFAULTS);
  const v = G.validate(boards, insts, g, p);
  const pillars = v.placed.flatMap(q => q.holes.map(h => [h[0], h[1]]));
  const plan = G.planCuts(g.W, g.D, pillars, p);
  if (plan.error) throw new Error(dk + ': ' + plan.error);
  const pieces = G.buildPieces(plan, pillars, toothHoles ? Object.assign({}, p, { edgeMargin: 2.5, pillarMargin: 1, ribWidth: 2 }) : noHoles ? Object.assign({}, p, { lighten: 0 }) : p);
  if (tooth) {   // sabotage: first piece built with zero clearance
    const p0 = Object.assign({}, p, { clearance: 0 });
    pieces[0] = G.buildPieces(plan, pillars, p0)[0];
  }
  const files = [];
  for (const pc of pieces) {
    const f = `${dk}_${pc.id}.stl`;
    fs.writeFileSync(path.join(out, f), G.stl(G.pieceMesh(pc, g.D, p), pc.id));
    files.push({ file: f, id: pc.id, r: pc.r, c: pc.c, rect: pc.rect, size: pc.size });
  }
  manifest.push({ depth: dk, W: g.W, D: g.D, ear: g.ear, params: p, plan: { rows: plan.rows, cols: plan.cols, warn: plan.warn },
    // independent expectation: placement as data (board, cell, rot) -- the checker recomputes holes itself
    insts: insts.map(i => ({ name: boards[i.b].name, cx: i.cx, cy: i.cy, rot: i.rot })), grid: g, files });
  console.log(dk, 'D', g.D, 'boards', insts.length, 'pieces', pieces.length, pieces.map(x => x.id + ' ' + x.size.map(s => s.toFixed(1)).join('x')).join(', '), plan.warn.join('; '));
}
const cp = G.coupons(G.DEFAULTS);
cp.forEach(c => c.pieces.forEach(pc => fs.writeFileSync(path.join(out, `coupon_c${c.clearance.toFixed(2)}_${pc.id}.stl`), G.stl(pc.tri))));
fs.writeFileSync(path.join(out, 'manifest.json'), JSON.stringify(manifest, null, 1));
