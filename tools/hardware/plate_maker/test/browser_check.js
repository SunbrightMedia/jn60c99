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
    await page.route('https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js', r => r.fulfill({ path: nm('three/build/three.min.js'), contentType: 'text/javascript' }));
    await page.route('https://fonts.googleapis.com/**', r => r.fulfill({ body: '', contentType: 'text/css' }));
    await page.goto('file://' + file); await page.waitForTimeout(800);
    return { ctx, page };
  }
  const { page } = await open({ viewport: { width: 1400, height: 1100 } });
  const st = () => page.evaluate(() => ({ n: __plate.S.insts.length, pieces: __plate.derived.pieces.length, bad: __plate.derived.bad,
    insts: __plate.S.insts.map(i => [__plate.BOARDS[i.b].name, i.cx, i.cy, i.rot]) }));
  let s0 = await st(); console.log('start', s0.n, 'boards', s0.pieces, 'pieces', 'bad', s0.bad);
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
