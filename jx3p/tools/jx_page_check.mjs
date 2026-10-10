// jx_page_check.mjs -- the DELIVERED JX-3P page (jx3p/gui/web/index.html with its jx3p.js / .wasm and data) in
// headless Chromium: it boots ('engine ready'), Start audio opens the product path (jx3p_product_open at the
// AudioContext's rate), a held key sounds (the page's peak > 0), patch 35 (factory 34: the arpeggiator) plays
// with a key held, and nothing reaches the console as an error. jx_wasm_check.py grades the engine's samples;
// this grades the page's wiring around it (fetch + inflate, the event queue, the block call).
//   node jx3p/tools/jx_page_check.mjs [--dir jx3p/gui/web]      exit 0 = every check passed
//   node jx3p/tools/jx_page_check.mjs --tooth data|keys          the server breaks the page -- the guest
//        image missing (404) | the keys queue nothing -- and the check must go RED (exit 0 = it did)
import { chromium } from 'playwright-core';
import { createServer } from 'node:http';
import { readFileSync, existsSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ARGS = process.argv.slice(2);
const DIR = path.resolve(ARGS.includes('--dir') ? ARGS[ARGS.indexOf('--dir') + 1] : path.join(HERE, '../gui/web'));
const TOOTH = ARGS.includes('--tooth') ? ARGS[ARGS.indexOf('--tooth') + 1] : null;
const TYPES = { '.html': 'text/html', '.js': 'text/javascript', '.wasm': 'application/wasm', '.gz': 'application/gzip' };
const srv = createServer((req, res) => {
  const f = path.join(DIR, decodeURIComponent(req.url.split('?')[0]).replace(/^\/$/, '/index.html'));
  if (!f.startsWith(DIR) || !existsSync(f) || (TOOTH === 'data' && /jx_guest/.test(f))) {
    res.statusCode = 404; res.end(); return;
  }
  res.setHeader('content-type', TYPES[path.extname(f)] || 'application/octet-stream');
  let body = readFileSync(f);
  if (TOOTH === 'keys' && f.endsWith('index.html'))
    body = body.toString().replace('if (ctx) queue.push([0, 0, n, 100]);', '');
  res.end(body);
});
await new Promise(r => srv.listen(8937, r));
const browser = await chromium.launch({
  executablePath: '/opt/pw-browsers/chromium',
  args: ['--autoplay-policy=no-user-gesture-required', '--no-sandbox'],
});
const page = await browser.newPage();
const errors = [];
page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
page.on('pageerror', e => errors.push(String(e)));
const fails = [];
// "sounds": a played key peaks near 0.25; with no key the output still carries the plugin's own idle
// signal -- residue near 1e-13, and up to 0.00064 on patch 0 after the start (the first --tooth keys run
// passed "peak > 0" on exactly that) -- so the bar is -40 dBFS
const LOUD = 1e-2;
const check = (ok, what) => { console.log(`  ${ok ? 'ok  ' : 'FAIL'} ${what}`); if (!ok) fails.push(what); };
try {
  await page.goto('http://127.0.0.1:8937/');
  await page.waitForFunction(() => /engine ready/.test(document.getElementById('status').textContent), null, { timeout: 60000 });
  check(true, 'boot: ' + (await page.textContent('#status')).trim());
  await page.click('#power');
  await page.waitForFunction(() => /audio running/.test(document.getElementById('status').textContent), null, { timeout: 20000 });
  const st = (await page.textContent('#status')).trim();
  const rate = await page.evaluate(() => window.__rate), kind = await page.evaluate(() => window.__kind);
  check([44100, 48000, 96000].includes(rate) && kind >= 0 && kind <= 1, `audio: ${st} (render object kind ${kind})`);
  await page.waitForTimeout(800);                            // past the 0.5 s start mute
  await page.evaluate(() => { window.__peak = 0; });
  await page.keyboard.down('a');                             // key 48
  await page.waitForTimeout(600);
  const pk = await page.evaluate(() => window.__peak);
  await page.keyboard.up('a');
  check(pk > LOUD, `a held key sounds (peak ${pk})`);
  await page.selectOption('#patch', '34');                   // factory patch 34: ARPEGGIO on
  await page.waitForTimeout(800);                            // its patch load mutes 0.5 s
  await page.evaluate(() => { window.__peak = 0; });
  await page.keyboard.down('d'); await page.keyboard.down('g');
  await page.waitForTimeout(800);
  const pk2 = await page.evaluate(() => window.__peak);
  await page.keyboard.up('d'); await page.keyboard.up('g');
  check(pk2 > LOUD, `patch 34 (the arpeggiator) sounds with two keys held (peak ${pk2})`);
} catch (e) {
  fails.push(String(e)); console.log('  FAIL ' + e);
}
check(errors.length === 0, `console errors: ${errors.length}${errors.length ? ' -- ' + errors.slice(0, 3).join(' | ') : ''}`);
await browser.close(); srv.close();
if (TOOTH) {
  console.log(`jx_page_check --tooth ${TOOTH}: ${fails.length ? 'BITES (' + fails.length + ' checks failed)' : 'DID NOT BITE'}`);
  process.exit(fails.length ? 0 : 1);
}
console.log(`jx_page_check: ${fails.length ? 'RED' : 'GREEN'}`);
process.exit(fails.length ? 1 : 0);
