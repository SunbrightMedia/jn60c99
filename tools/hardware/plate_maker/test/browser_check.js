// browser_check.js OUTDIR -- drive plate_maker.html in headless Chromium: render, drag, rotate,
// export. CDN scripts are served from local node_modules (same pinned versions).
// Needs: playwright-core, earcut@2.2.4, three@0.128.0 on NODE_PATH; Chromium at /opt/pw-browsers.
const fs = require('fs'), path = require('path');
const { chromium } = require('playwright-core');
const out = process.argv[2]; fs.mkdirSync(out, { recursive: true });
const nm = p => require.resolve(p);
const page_html = fs.readFileSync(path.join(__dirname, '../plate_maker.html'), 'utf8');
const wrapped = '<!doctype html><html><head><meta charset=utf8><meta name=viewport content="width=device-width,initial-scale=1,viewport-fit=cover"></head><body>' + page_html + '</body></html>';
const file = path.join(out, 'page.html'); fs.writeFileSync(file, wrapped);
(async () => {
  const exe = fs.readdirSync('/opt/pw-browsers').filter(d => d.startsWith('chromium-')).map(d => `/opt/pw-browsers/${d}/chrome-linux/chrome`)[0];
  const browser = await chromium.launch({ executablePath: exe, args: ['--no-sandbox', '--use-gl=swiftshader', '--enable-unsafe-swiftshader'] });
  const errs = [];
  async function open(opts) {
    const ctx = await browser.newContext(Object.assign({ acceptDownloads: true }, opts));
    const page = await ctx.newPage();
    page.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
    page.on('pageerror', e => errs.push(String(e)));
    await page.route('https://cdn.jsdelivr.net/npm/earcut@2.2.4/dist/earcut.min.js', r => r.fulfill({ path: nm('earcut/dist/earcut.min.js'), contentType: 'text/javascript' }));
    await page.route('https://cdn.jsdelivr.net/npm/delaunator@5.0.1/delaunator.min.js', r => r.fulfill({ path: nm('delaunator/delaunator.min.js'), contentType: 'text/javascript' }));
    await page.route('https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js', r => r.fulfill({ path: nm('three/build/three.min.js'), contentType: 'text/javascript' }));
    await page.route('https://fonts.googleapis.com/**', r => r.fulfill({ body: '', contentType: 'text/css' }));
    await page.goto('file://' + file); await page.waitForTimeout(800);
    return { ctx, page };
  }
  const { page } = await open({ viewport: { width: 1400, height: 1100 } });
  const st = () => page.evaluate(() => ({ n: __plate.S.insts.length, pieces: __plate.derived.pieces.length, bad: __plate.derived.bad,
    insts: __plate.S.insts.map(i => [__plate.BOARDS[i.b].name, i.cx, i.cy, i.rot]) }));
  let s0 = await st(); console.log('start', s0.n, 'boards', s0.pieces, 'pieces', 'bad', s0.bad);
  await page.waitForTimeout(800);
  const mass = await page.evaluate(() => ({ total: document.getElementById('massTotal').textContent, holes: __plate.derived.pieces.reduce((t, p) => t + p.holes.length, 0), cells: [...document.querySelectorAll('#pieceTable [data-mass]')].map(e => e.textContent) }));
  console.log('lightening holes', mass.holes, '| PLA per piece', mass.cells.join(','), 'g | total', mass.total, 'g', mass.holes > 0 && +mass.total > 0 && mass.cells.every(c => +c > 0) ? 'OK' : 'FAIL');
  await page.screenshot({ path: path.join(out, 'desktop_light.png'), fullPage: true });
  // drag the first board two cells right and one down
  const g = page.locator('#panel .board').first();
  const box = await g.boundingBox();
  const mm = await page.evaluate(() => { const r = document.getElementById('panel').getBoundingClientRect(); return r.width / (482.6 + 8); });
  const before = (await st()).insts[0];
  // pick an empty target: find any cell shift that the app reports as valid later; just test the move itself
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
  await page.mouse.down(); await page.mouse.move(box.x + box.width / 2 + 42 * mm, box.y + box.height / 2 + 21 * mm, { steps: 8 }); await page.mouse.up();
  const after = (await st()).insts[0];
  console.log('drag', before, '->', after, (after[1] - before[1] === 2 && after[2] - before[2] === 1) ? 'OK' : 'FAIL');
  await page.keyboard.press('r'); const rot = (await st()).insts[0][3]; console.log('rotate', rot === (before[3] + 1) % 4 ? 'OK' : 'FAIL');
  await page.keyboard.press('r'); await page.keyboard.press('r'); await page.keyboard.press('r');
  // put the board back
  await page.evaluate(b => { const i = __plate.S.insts[0]; i.cx = b[1]; i.cy = b[2]; i.rot = b[3]; }, before);
  await page.locator('#vGrid').click(); await page.locator('#vGrid').click();   // redraw through a UI path
  await page.evaluate(() => document.getElementById('depths').querySelector('button:last-child').click());
  s0 = await st(); console.log('after restore', s0.n, 'boards, bad', s0.bad);
  for (const [btn, name] of [['#bStl', 'app_plate.zip'], ['#bCoupon', 'app_coupons.zip'], ['#bSvg', 'app_layout.svg']]) {
    const [dl] = await Promise.all([page.waitForEvent('download', { timeout: 20000 }), page.click(btn)]);
    await dl.saveAs(path.join(out, name)); console.log('saved', name, fs.statSync(path.join(out, name)).size, 'bytes');
  }
  await page.waitForTimeout(600);
  await page.screenshot({ path: path.join(out, 'desktop_light_after.png'), fullPage: true });
  // cutouts as drawn: turn some boards, then read every cutout's centre and extent in panel mm
  const cut = await page.evaluate(() => {
    const S = __plate.S, B = __plate.BOARDS;
    S.insts.forEach((i, k) => { const n = B[i.b].name; if (n === 'FaderBoard' && k % 2) i.rot = 1; if (n === 'PotentiometerPack1') i.rot = 3; if (n === 'buttonpack2') i.rot = 2; if (n === 'SwitchBoard') i.rot = 1; });
    __plate.refresh();
    const svg = document.getElementById('panel'), inv = svg.getScreenCTM().inverse();
    const pts = [];
    svg.querySelectorAll('.cutout').forEach(e => {
      const bb = e.getBBox(), m = inv.multiply(e.getScreenCTM());
      const corners = [[bb.x, bb.y], [bb.x + bb.width, bb.y], [bb.x, bb.y + bb.height], [bb.x + bb.width, bb.y + bb.height]].map(([x, y]) => [m.a * x + m.c * y + m.e, m.b * x + m.d * y + m.f]);
      const xs = corners.map(c => c[0]), ys = corners.map(c => c[1]);
      const inst = +e.closest('.board').dataset.id;
      pts.push({ inst, x: (Math.min(...xs) + Math.max(...xs)) / 2, y: (Math.min(...ys) + Math.max(...ys)) / 2, w: Math.max(...xs) - Math.min(...xs), h: Math.max(...ys) - Math.min(...ys) });
    });
    return { layout: { depth: S.depth, params: S.params, boards: S.insts.map(i => ({ id: i.id, name: B[i.b].name, cx: i.cx, cy: i.cy, rot: i.rot })) }, cutouts: pts };
  });
  fs.writeFileSync(path.join(out, 'cutouts_drawn.json'), JSON.stringify(cut));
  console.log('cutouts drawn', cut.cutouts.length);
  await page.locator('#vBoards').click(); await page.waitForTimeout(200);
  await page.locator('#panel').screenshot({ path: path.join(out, 'cutouts_only.png') });
  await page.locator('#vBoards').click();
  // ---- selection, rotation drift, group moves (fresh example layout) ----
  await page.evaluate(() => { localStorage.clear(); }); await page.reload(); await page.waitForTimeout(800);
  const toScreen = (x, y) => page.evaluate(([x, y]) => { const svg = document.getElementById('panel'), m = svg.getScreenCTM(); return [m.a * x + m.c * y + m.e, m.b * x + m.d * y + m.f]; }, [x, y]);
  const pos = () => page.evaluate(() => __plate.S.insts.map(i => [i.id, i.cx, i.cy, i.rot]));
  const g0 = await page.evaluate(() => __plate.derived.g);
  // a board whose cell counts differ by an odd number (buttonpack3, 5 x 2): its centre falls between
  // cells after each turn -- the old code drifted one cell per 4 turns. 40 turns.
  const fId = await page.evaluate(() => __plate.S.insts.find(i => __plate.BOARDS[i.b].name === 'buttonpack3').id);
  await page.evaluate(id => { __plate.S.sel = [id]; __plate.refresh(); }, fId);
  const fst = (await pos()).find(q => q[0] === fId);
  let drift = 'OK';
  for (let n = 1; n <= 40; n++) {
    await page.keyboard.press('r');
    const q = (await pos()).find(q => q[0] === fId), ok = await page.evaluate(id => { const k = __plate.S.insts.findIndex(i => i.id === id), b = __plate.derived.v.placed[k].bbox, g = __plate.derived.g; return b[0] >= 0 && b[2] <= g.W && b[1] >= 0 && b[3] <= g.D; }, fId);
    if (!ok) drift = 'FAIL (off the panel after ' + n + ' turns)';
    if (n % 4 === 0 && (q[1] !== fst[1] || q[2] !== fst[2] || q[3] !== fst[3])) drift = 'FAIL (moved after ' + n + ' turns: ' + q + ' vs ' + fst + ')';
  }
  console.log('40 turns of one board', drift);
  // box select: drag over an empty start point across the upper boards
  const a = await toScreen(g0.gx0 + 2, g0.D - 4), b = await toScreen(g0.gx0 + 150, 60);
  await page.mouse.move(a[0], a[1]); await page.mouse.down(); await page.mouse.move(b[0], b[1], { steps: 8 }); await page.mouse.up();
  const sel = await page.evaluate(() => __plate.S.sel.slice());
  const want = await page.evaluate(([x0, y0, x1, y1]) => __plate.S.insts.filter((i, k) => { const q = __plate.derived.v.placed[k].bbox; return q[0] < x1 && x0 < q[2] && q[1] < y1 && y0 < q[3]; }).map(i => i.id), [g0.gx0 + 2, 60, g0.gx0 + 150, g0.D - 4]);
  console.log('box select', sel.length, 'boards', sel.length >= 2 && sel.sort().join() === want.sort().join() ? 'OK' : 'FAIL ' + sel + ' vs ' + want);
  // group: 4 turns -> every board back where it started
  const before4 = JSON.stringify((await pos()).filter(q => sel.includes(q[0])));
  for (let n = 0; n < 4; n++) await page.keyboard.press('r');
  const after4 = JSON.stringify((await pos()).filter(q => sel.includes(q[0])));
  console.log('group of', sel.length, '4 turns', before4 === after4 ? 'OK' : 'FAIL ' + before4 + ' -> ' + after4);
  // group drag: grab one selected board, move one cell down -> all move together
  const pre = (await pos()).filter(q => sel.includes(q[0]));
  const bx = await page.evaluate(id => { const r = [...document.querySelectorAll('#panel .board')].find(e => +e.dataset.id === id).querySelector('.pcb').getBoundingClientRect(); return [r.x + 4, r.y + r.height / 2]; }, sel[0]);
  const mmPx = await page.evaluate(() => document.getElementById('panel').getScreenCTM().a);
  await page.mouse.move(bx[0], bx[1]); await page.mouse.down(); await page.mouse.move(bx[0], bx[1] + 21 * mmPx, { steps: 5 }); await page.mouse.up();
  const post = (await pos()).filter(q => sel.includes(q[0]));
  const deltas = new Set(post.map((q, k) => (q[1] - pre[k][1]) + ',' + (q[2] - pre[k][2])));
  console.log('group drag delta', [...deltas].join(' '), deltas.size === 1 && [...deltas][0] === '0,1' ? 'OK' : 'FAIL');
  // arrows never push a board off the grid
  await page.keyboard.press('Escape');
  await page.evaluate(id => { __plate.S.sel = [id]; __plate.refresh(); }, fId);
  for (let n = 0; n < 40; n++) await page.keyboard.press('ArrowLeft');
  const fl = (await pos()).find(q => q[0] === fId);
  console.log('40 x left arrow -> cell x', fl[1], fl[1] === 0 ? 'OK (stops at the edge)' : 'FAIL');

  // ---- caps, in the Panel view, on a fresh example layout ----
  await page.evaluate(() => { localStorage.clear(); }); await page.reload(); await page.waitForTimeout(800);
  await page.click('#mPanel'); await page.waitForTimeout(300);
  await page.screenshot({ path: path.join(out, 'panel_view.png'), fullPage: false });
  const panelPt = (sel, n) => page.evaluate(([sel, n]) => {     // centre of the n-th element, in panel mm
    const svg = document.getElementById('panel'), inv = svg.getScreenCTM().inverse();
    const e = svg.querySelectorAll(sel)[n]; if (!e) return null;
    const b = e.getBBox(), m = inv.multiply(e.getScreenCTM());
    const x = b.x + b.width / 2, y = b.y + b.height / 2;
    return [m.a * x + m.c * y + m.e, m.b * x + m.d * y + m.f];
  }, [sel, n]);
  const scr = (sel, n) => page.evaluate(([sel, n]) => { const r = document.querySelectorAll(sel)[n].getBoundingClientRect(); return [r.x + r.width / 2, r.y + r.height / 2]; }, [sel, n]);
  // centres at rest = cutout centres (cutouts are oracle-checked)
  let restOk = true;
  for (const kind of ['fader', 'knob', 'key']) {
    const n = await page.evaluate(k => document.querySelectorAll('#panel .cap-' + k).length, kind);
    for (let i = 0; i < n; i++) {
      const c = await panelPt('#panel .cap-' + kind + ' .body', i);
      const holes = await page.evaluate(() => { const svg = document.getElementById('panel'), inv = svg.getScreenCTM().inverse(); return [...svg.querySelectorAll('.cutout')].map(e => { const b = e.getBBox(), m = inv.multiply(e.getScreenCTM()), x = b.x + b.width / 2, y = b.y + b.height / 2; return [m.a * x + m.c * y + m.e, m.b * x + m.d * y + m.f]; }); });
      if (!holes.some(h => Math.hypot(h[0] - c[0], h[1] - c[1]) < 0.01)) { restOk = false; console.log('cap off its cutout', kind, i, c); }
    }
  }
  console.log('caps at rest on their cutouts', restOk ? 'OK' : 'FAIL');
  // fader: drag past both ends -> exactly the travel apart
  const f0 = await scr('#panel .cap-fader', 0);
  await page.mouse.move(f0[0], f0[1]); await page.mouse.down(); await page.mouse.move(f0[0], f0[1] - 400, { steps: 6 }); await page.mouse.up();
  const pA = await panelPt('#panel .cap-fader .body', 0);
  const f1 = await scr('#panel .cap-fader', 0);
  await page.mouse.move(f1[0], f1[1]); await page.mouse.down(); await page.mouse.move(f1[0], f1[1] + 800, { steps: 10 }); await page.mouse.up();
  const pB = await panelPt('#panel .cap-fader .body', 0);
  const travel = Math.hypot(pA[0] - pB[0], pA[1] - pB[1]);
  console.log('fader end to end', travel.toFixed(4), Math.abs(travel - 60) < 0.01 ? 'OK' : 'FAIL');
  // knob: drag round past the stop -> clamped to 0 or 1
  const k0 = await scr('#panel .cap-knob', 0);
  await page.mouse.move(k0[0], k0[1]); await page.mouse.down();
  for (const [dx, dy] of [[0, -30], [30, 0], [0, 30], [-5, 30]]) await page.mouse.move(k0[0] + dx, k0[1] + dy, { steps: 4 });
  await page.mouse.up();
  const kv = await page.evaluate(() => { const i = __plate.S.insts.find(i => __plate.BOARDS[i.b].parts.some(p => p[0] === 'pot')); return i.caps; });
  const kval = Object.values(kv)[0];
  console.log('knob turned clockwise past its stop ->', kval, kval === 1 ? 'OK' : 'FAIL');
  // key: pressed while held
  const kk = await scr('#panel .cap-key', 0);
  await page.mouse.move(kk[0], kk[1]); await page.mouse.down();
  const held = await page.evaluate(() => document.querySelectorAll('#panel .cap-key.pressed').length);
  await page.mouse.up();
  const released = await page.evaluate(() => document.querySelectorAll('#panel .cap-key.pressed').length);
  console.log('key press', held === 1 && released === 0 ? 'OK' : 'FAIL');
  // switch: click cycles 0 -> 1 -> -1
  const sw = await scr('#panel .cap-lever', 0);
  const vals = [];
  for (let i = 0; i < 2; i++) { const p = await scr('#panel .cap-lever', 0); await page.mouse.click(p[0], p[1]); vals.push(await page.evaluate(() => { const i = __plate.S.insts.find(i => __plate.BOARDS[i.b].parts.some(p => p[0] === 'switch')); return Object.values(i.caps)[0]; })); }
  console.log('switch positions', vals.join(','), vals.join(',') === '1,-1' ? 'OK' : 'FAIL');
  await page.screenshot({ path: path.join(out, 'panel_view_moved.png'), fullPage: false });
  // labels, recomputed here: CNTRL centred between the board's top edge and the top of each fader
  // slot / switch slot / knob (measured from its drawn cap) / button pack row; numbers 1..n centred
  // between each button cap's bottom and the board's bottom edge, left to right
  const lab = await page.evaluate(() => {
    const P = __plate, svg = document.getElementById('panel'), g = P.derived.g, size = P.S.params.labelSize, inv = svg.getScreenCTM().inverse();
    const labels = [...svg.querySelectorAll('#labels .lbl')].map(t => { const b = t.getBBox(); return { x: +t.getAttribute('x'), base: +t.getAttribute('y'), a: t.getAttribute('text-anchor'), txt: t.textContent, top: b.y, bot: b.y + b.height }; });
    const want = [];   // [inst, x, partEdge, top?, text]
    P.G.cutoutBoxes(P.BOARDS, P.S.insts, g, P.S.params).filter(c => c.kind === 'fader' || c.kind === 'switch').forEach(c => want.push([c.inst, (c.box[0] + c.box[2]) / 2, c.box[1], true, 'CNTRL']));
    const drawn = sel => [...svg.querySelectorAll(sel)].map(e => { const b = e.getBBox(), m = inv.multiply(e.getScreenCTM());
      const pts = [[b.x, b.y], [b.x + b.width, b.y + b.height]].map(([x, y]) => [m.a * x + m.c * y + m.e, m.b * x + m.d * y + m.f]);
      return { k: P.S.insts.findIndex(i => i.id === +e.closest('.board').dataset.id), x0: Math.min(pts[0][0], pts[1][0]), x1: Math.max(pts[0][0], pts[1][0]), y0: Math.min(pts[0][1], pts[1][1]), y1: Math.max(pts[0][1], pts[1][1]) }; });
    // knobs turn, so take the centre and the radius (a turned circle's box corners overstate its top)
    [...svg.querySelectorAll('.cap-knob .body')].forEach(e => { const m = inv.multiply(e.getScreenCTM()), r = +e.getAttribute('r');
      want.push([P.S.insts.findIndex(i => i.id === +e.closest('.board').dataset.id), m.e, m.f - r, true, 'CNTRL']); });
    const btn = drawn('.cap-button .body'), packs = [...new Set(btn.map(c => c.k))];
    packs.forEach(k => { const l = btn.filter(c => c.k === k).sort((a, b) => a.x0 - b.x0);
      want.push([k, (Math.min(...l.map(c => c.x0)) + Math.max(...l.map(c => c.x1))) / 2, Math.min(...l.map(c => c.y0)), true, 'CNTRL']);
      l.forEach((c, n) => want.push([k, (c.x0 + c.x1) / 2, c.y1, false, String(n + 1)])); });
    const res = want.map(([k, x, edge, top, txt]) => { const bb = P.derived.v.placed[k].bbox, mid = top ? (bb[1] + edge) / 2 : (bb[3] + edge) / 2;
      const l = labels.find(l => Math.abs(l.x - x) < 0.01 && l.txt === txt && Math.abs(l.base - (mid + 0.717 * size / 2)) < 0.01);
      return !!l && l.a === 'middle' && (top ? (l.top >= bb[1] - 0.5 && l.bot <= edge + 0.5) : (l.top >= edge - 0.5 && l.bot <= bb[3] + 0.5)); });
    window.__labbad = want.filter((w, i) => !res[i]).map(w => [P.BOARDS[P.S.insts[w[0]].b].name, ...w.slice(1)]).concat(labels.filter(l => /^[0-9]+$/.test(l.txt) || true).slice(0, 0));
    return { badItems: window.__labbad, n: labels.length, want: want.length, bad: res.filter(r => !r).length, nums: labels.filter(l => /^[0-9]+$/.test(l.txt)).length, switches: svg.querySelectorAll('.cap-lever').length };
  });
  if (lab.bad) console.log('  wrong:', JSON.stringify(lab.badItems));
  console.log('labels', lab.n, 'expected', lab.want, '(numbers', lab.nums + ', switches', lab.switches + '), wrong', lab.bad, lab.n === lab.want && lab.bad === 0 && lab.nums > 0 && lab.switches > 0 ? 'OK' : 'FAIL');
  await page.click('#vLabels'); const nl = await page.evaluate(() => document.querySelectorAll('#labels .lbl').length); await page.click('#vLabels');
  await page.click('#vEdges'); const es = await page.evaluate(() => getComputedStyle(document.querySelector('#panel .board .hitbox')).stroke); await page.click('#vEdges');
  const es2 = await page.evaluate(() => getComputedStyle(document.querySelector('#panel .board .hitbox')).stroke);
  console.log('labels off ->', nl, '| edges off ->', es, '| on ->', es2, nl === 0 && es === 'none' && es2 !== 'none' ? 'OK' : 'FAIL');
  const fsz = await page.evaluate(() => { const b = document.querySelector('#panel .cap-fader .body').getBBox(); return [b.width, b.height]; });
  console.log('fader cap', fsz.join(' x '), fsz[0] === 6 && fsz[1] === 10 ? 'OK' : 'FAIL');
  await page.screenshot({ path: path.join(out, 'panel_labels.png'), fullPage: false });
  const capsSaved = await page.evaluate(() => JSON.parse(localStorage.getItem('module-plate-maker-v1')).boards.filter(b => b.caps).length);
  console.log('caps saved in layout', capsSaved > 0 ? 'OK' : 'FAIL');
  const d = await open({ viewport: { width: 1400, height: 1100 }, colorScheme: 'dark' });
  await d.page.screenshot({ path: path.join(out, 'desktop_dark.png'), fullPage: true });
  const ph = await open({ viewport: { width: 390, height: 800 }, deviceScaleFactor: 2 });
  await ph.page.screenshot({ path: path.join(out, 'phone.png'), fullPage: true });
  const hscroll = await ph.page.evaluate(() => document.documentElement.scrollWidth > window.innerWidth + 1);
  console.log('phone horizontal page scroll', hscroll ? 'FAIL' : 'OK');
  console.log('console errors', errs.length ? errs : 'none');
  await browser.close();
})().catch(e => { console.error(e); process.exit(1); });
