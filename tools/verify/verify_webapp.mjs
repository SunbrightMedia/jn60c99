// verify_webapp.mjs — drive the bundled single-file app in headless Chromium:
// boot -> factory bank button appears -> apply patch 5 -> press a piano key ->
// expect real audio (window.__peak > 0) and zero console errors.
import { chromium } from "playwright-core";
import { createServer } from "node:http";
import { readFileSync } from "node:fs";

const SP = "/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad";
const html = readFileSync(`${SP}/juno-webapp-local.html`);
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

await page.click("#openbank");
await page.waitForSelector("#banksel option", { state: "attached", timeout: 5000 });
const nOpts = await page.$$eval("#banksel option", o => o.length);
const patchName = await page.$eval("#banksel option:nth-child(6)", o => o.textContent);
console.log(`bank: ${nOpts} patches; picking:`, patchName.trim());
await page.selectOption("#banksel", "5");
await page.click("#bankdlg button.on");   // Apply to engine
await page.waitForTimeout(200);
console.log("status:", (await page.textContent("#status")).trim());

// press + hold a piano key (mousedown fires note-on + ensureAudio)
await page.dispatchEvent(".key.w", "mousedown");
await page.waitForTimeout(900);
const peak = await page.evaluate(() => window.__peak || 0);
await page.dispatchEvent(".key.w", "mouseup");
console.log("audio peak after keypress:", peak);
console.log("console errors:", errors.length ? errors : "none");

const ok = nOpts === 64 && peak > 1e-3 && errors.length === 0;
console.log(ok ? "\nOK: bundled app boots, loads bank, applies patch, and MAKES SOUND"
               : "\nFAIL");
await browser.close(); srv.close();
process.exit(ok ? 0 : 1);
