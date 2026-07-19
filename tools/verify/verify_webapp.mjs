// verify_webapp.mjs — drive the bundled single-file app in headless Chromium:
// boot -> factory bank button appears -> apply patch 5 -> press a piano key ->
// expect real audio (window.__peak > 0) and zero console errors.
import { chromium } from "playwright-core";
import { createServer } from "node:http";
import { readFileSync } from "node:fs";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";

// The bundler (bundle_webapp.py) writes juno-webapp-local.html next to itself in
// tools/verify — read that fresh output, not a stale scratchpad copy.
const HERE = dirname(fileURLToPath(import.meta.url));
const html = readFileSync(`${HERE}/juno-webapp-local.html`);
const srv = createServer((req, res) => { res.setHeader("content-type", "text/html"); res.end(html); });
await new Promise(r => srv.listen(8931, r));

const browser = await chromium.launch({
  executablePath: "/opt/pw-browsers/chromium",
  args: ["--autoplay-policy=no-user-gesture-required", "--no-sandbox"],
});
const page = await browser.newPage();
const errors = [];
page.on("console", m => { if (m.type() === "error") errors.push(m.text()); });
page.on("pageerror", e => errors.push(String(e)));

await page.goto("http://127.0.0.1:8931/");
await page.waitForSelector("#openbank", { timeout: 30000 });
const meta = await page.textContent("#meta");
console.log("boot meta:", meta.trim());

// --- resizable-ArrayBuffer regression guards (the boot-killing TypeError class) ---
// (1) the shipped engine glue must not opt into the resizable heap path at all;
// (2) the page's TextDecoder shim must decode a view over a genuinely resizable
//     ArrayBuffer — the exact operation that threw in end-user browsers whose
//     TextDecoder rejects resizable buffers (headless CI Chromium lacks
//     toResizableBuffer, so only these two checks cover that environment here).
const rab = await page.evaluate(() => {
  const out = { glueHasToResizable: /toResizableBuffer/.test(document.documentElement.innerHTML) };
  // the shim marks itself — this proves it is INSTALLED, which a lenient-decoder
  // browser (like headless CI Chromium) could not otherwise distinguish
  out.shimInstalled = TextDecoder.prototype.decode.__junoRabShim === true;
  try {
    const b = new ArrayBuffer(24, { maxByteLength: 64 });
    new Uint8Array(b).set([...Array(24)].map((_, i) => 65 + (i % 26)));
    out.shimDecodesResizable = new TextDecoder().decode(new Uint8Array(b, 0, 20)).length === 20;
  } catch (e) { out.shimDecodesResizable = false; out.err = String(e); }
  return out;
});
console.log("resizable-AB guards:", JSON.stringify(rab));
const rabOK = !rab.glueHasToResizable && rab.shimInstalled === true && rab.shimDecodesResizable === true;

await page.click("#openbank");
await page.waitForSelector("#banksel option", { state: "attached", timeout: 5000 });
const nOpts = await page.$$eval("#banksel option", o => o.length);
const patchName = await page.$eval("#banksel option:nth-child(6)", o => o.textContent);
console.log(`bank: ${nOpts} patches; picking:`, patchName.trim());
await page.selectOption("#banksel", "5");
await page.click("#bankdlg button.on");   // Apply to engine
await page.waitForTimeout(200);
console.log("status:", (await page.textContent("#status")).trim());

// --- front-panel controls: rendered, sectioned, and reflecting patch 5's bytes ---
const nRows = await page.$$eval("main#list .p", r => r.length);
const nSecs = await page.$$eval("main#list .sec", r => r.map(e => e.textContent));
console.log(`panel: ${nRows} controls in ${nSecs.length} sections:`, nSecs.join(" | "));
// every control's number box must hold an integer in 0..255, and the panel must not
// be all-zero (patch 5 loaded real bytes)
const vals = await page.$$eval("main#list .p input[type=number]", ins => ins.map(i => +i.value));
const swVals = await page.$$eval("main#list .p button.sw", bs => bs.map(b => b.textContent));
const allByte = vals.every(v => Number.isInteger(v) && v >= 0 && v <= 255);
const nonZero = vals.filter(v => v > 0).length;
console.log(`  numeric controls: ${vals.length} (all 0..255: ${allByte}, non-zero: ${nonZero}); switches: ${swVals.join(",") || "none"}`);
// move the first slider and confirm the model commits (no throw, value persists)
await page.$eval("main#list .p input[type=range]", r => { r.value = 200; r.dispatchEvent(new Event("change")); });
await page.waitForTimeout(50);
const moved = await page.$eval("main#list .p input[type=number]", i => +i.value);
console.log("  first slider set to 200 ->", moved);
// a >16-char param name must have survived UTF8ToString intact (the TextDecoder
// path is only taken for strings longer than 16 bytes — short names can render
// fine while every long name throws, which is exactly the user-reported failure)
const longName = await page.$$eval("main#list .p label", ls =>
  ls.map(l => l.title.split("  ")[0]).find(t => t.length > 16) || "");
console.log(`  >16-char param name rendered: "${longName}"`);
const panelOK = nRows >= 21 && nSecs.length >= 6 && allByte && nonZero >= 5 && moved === 200
  && longName.length > 16;

// press + hold a piano key (mousedown fires note-on + ensureAudio)
await page.dispatchEvent(".key.w", "mousedown");
await page.waitForTimeout(900);
const peak = await page.evaluate(() => window.__peak || 0);
await page.dispatchEvent(".key.w", "mouseup");
console.log("audio peak after keypress:", peak);
console.log("console errors:", errors.length ? errors : "none");

const ok = nOpts === 64 && peak > 1e-3 && errors.length === 0 && panelOK && rabOK;
console.log(ok ? "\nOK: bundled app boots, loads bank, applies patch, panel reflects patch bytes, and MAKES SOUND"
               : `\nFAIL (bank=${nOpts===64} audio=${peak>1e-3} noErrors=${errors.length===0} panel=${panelOK} resizableAB=${rabOK})`);
await browser.close(); srv.close();
process.exit(ok ? 0 : 1);
