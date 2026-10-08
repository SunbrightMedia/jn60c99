// skin_kb_check.mjs -- the web skin's panel keyboard (gui/skin/skin.js) against
// JUNO-60.exe's (gui/win/juno60_win.c): the same seeded panel scripts through both
// programs' own input handlers, the same engine calls required, in order.
//
// The exe's keyboard is graded against the plugin itself on the calls it makes
// (tools/dist/exe_oracle_check.py, CLAIMS C6); the mapping from a mouse event to
// those calls is READ from the plugin's GUI code (docs/KEY_HOLD.md rule 10) and
// written twice, in C and in JavaScript. This check holds the two copies equal:
// mouse down / drag / up with and without Shift (inside, in the gaps, past the
// edges), the wheel, KEY HOLD and OCTAVE SHIFT edits, patch loads from the
// buttons (commit) and the list (no commit), MIDI notes, the UI timer.
//
// The skin runs in headless Chromium on the WASM port with REAL pointer events
// (Playwright's mouse and Shift key); its own 50 ms timer is held so the drains
// come only from the script, and its audio output is not opened (rendering
// changes none of the logged calls). The exe runs the script with --kbscript
// under Wine (or on Windows) and logs its engine calls. Compared: keybed writes,
// commits, model sets, patch loads (the index), drains.
//
// usage: node tools/verify/skin_kb_check.mjs --exe PATH [--seeds 1,2,...] [--events N]
//                                            [--tooth NAME]
//   --tooth velocity   the skin's click velocity one step higher (must FAIL)
//   --tooth hold       the skin's press never releases the other keys (must FAIL)
//   --tooth gap        the skin's hit test gives a gap to the key before it (must FAIL)
import { chromium } from "playwright-core";
import { createServer } from "node:http";
import { readFile, writeFile, mkdtemp, copyFile, rm } from "node:fs/promises";
import { readFileSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { tmpdir } from "node:os";
import { dirname, join, extname, normalize } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = normalize(join(dirname(fileURLToPath(import.meta.url)), "..", ".."));
const arg = (k, d) => process.argv.includes(k) ? process.argv[process.argv.indexOf(k) + 1] : d;
const EXE = arg("--exe", join(ROOT, "scratchpad", "dist", "JUNO-60.exe"));
const SEEDS = arg("--seeds", "1,2,3,4,5,6,7,8").split(",").map(Number);
const EVENTS = +arg("--events", "300");
const TOOTH = arg("--tooth", null);
const WINE = process.env.WINE || "/usr/lib/wine/wine64";
const MIME = { ".html": "text/html", ".js": "text/javascript", ".mjs": "text/javascript", ".wasm": "application/wasm",
               ".png": "image/png", ".xml": "application/xml", ".bin": "application/octet-stream", ".json": "application/json" };

// a seeded script over the keyboard control's rectangle (xorshift32, as the exe's --play)
function script(seed, kb) {
  let r = (2463534242 ^ Math.imul(seed, 2654435761)) >>> 0 || 1;
  const rnd = () => { r ^= r << 13; r >>>= 0; r ^= r >>> 17; r ^= r << 5; r >>>= 0; return r; };
  const out = ["block"];
  let down = false, hold = 0, oct = 0, held = [];
  const inside = () => [kb.x + rnd() % kb.w, kb.y + rnd() % kb.h];
  const around = () => [kb.x - 30 + rnd() % (kb.w + 60), kb.y - 10 + rnd() % (kb.h + 20)];
  for (let i = 0; i < EVENTS; i++) {
    const k = rnd() % 100;
    if (!down && k < 25) { const [x, y] = inside(); out.push(`down ${x} ${y} ${rnd() % 4 === 0 ? 1 : 0}`); down = true; }
    else if (down && k < 45) { const [x, y] = around(); out.push(`move ${x} ${y} ${rnd() % 4 === 0 ? 1 : 0}`); }
    else if (down && k < 60) { out.push("up"); down = false; }
    else if (!down && k < 64) { const [x, y] = inside(); out.push(`wheel ${x} ${y} ${rnd() & 1}`); }
    else if (k < 70) { hold = hold ? 0 : 1; out.push(`set ${hold} fm.PATCH.NAME1.KEY HOLD`); }
    else if (k < 73) { oct = (rnd() % 5) - 2; out.push(`set ${oct} fm.PATCH.NAME1.OCTAVE SHIFT`); }
    else if (k < 77) { out.push(`patch ${rnd() % 64} ${rnd() & 1}`, "block"); hold = 0; }
    else if (k < 85 && held.length < 6) { const n = 36 + rnd() % 61; held.push(n); out.push(`note ${n} ${1 + rnd() % 127}`, "block"); }
    else if (k < 90 && held.length) { out.push(`off ${held.splice(rnd() % held.length, 1)[0]}`, "block"); }
    else out.push("tick");
  }
  if (down) out.push("up");
  out.push("tick");
  return out;
}

// the compared calls of an exe log (after its "# kbscript" marker)
function exeCalls(log) {
  const lines = log.split(/\r?\n/);          // the exe writes its log in text mode (CR LF)
  const at = lines.indexOf("# kbscript");
  if (at < 0) throw new Error("no # kbscript marker in the exe's log");
  const out = [];
  for (const ln of lines.slice(at + 1)) {
    const t = ln.split(" ");
    if (t[0] === "keybed" || t[0] === "model_set") out.push(`${t[0]} ${t[1]} ${t[2]}`);
    else if (t[0] === "commit" || t[0] === "ui_tick") out.push(t[0]);
    else if (t[0] === "queue_patch") out.push(`patch ${t[1]}`);
  }
  return out;
}

const srv = createServer(async (req, res) => {
  const path = normalize(join(ROOT, decodeURIComponent(new URL(req.url, "http://x").pathname)));
  if (!path.startsWith(ROOT)) { res.statusCode = 403; return res.end(); }
  try {
    const p = path.endsWith("/") ? join(path, "index.html") : path;
    const body = await readFile(p);
    res.setHeader("content-type", MIME[extname(p)] || "application/octet-stream");
    res.end(body);
  } catch { res.statusCode = 404; res.end(); }
});
await new Promise(r => srv.listen(0, "127.0.0.1", r));
const port = srv.address().port;
const browser = await chromium.launch({ executablePath: "/opt/pw-browsers/chromium", args: ["--no-sandbox"] });
const work = await mkdtemp(join(tmpdir(), "skin_kb_"));
await copyFile(EXE, join(work, "JUNO-60.exe"));

let fails = 0;
for (const seed of SEEDS) {
  const page = await browser.newPage({ viewport: { width: 2000, height: 820 } });
  const errors = [];
  page.on("pageerror", e => errors.push(String(e)));
  await page.goto(`http://127.0.0.1:${port}/gui/skin/?zoom=100`);
  await page.waitForFunction(() => window.__skin && window.__skin.skin, null, { timeout: 60000 });
  // plumbing only: the calls logged as the exe logs them, the page's own UI timer held,
  // no audio device; the product code is not changed
  const kb = await page.evaluate(() => {
    const { E, skin } = window.__skin;
    const log = window.__kblog = [];
    const wrap = (name, fmt) => { const f = E[name].bind(E); E[name] = (...a) => { log.push(fmt(...a)); return f(...a); }; };
    wrap("keybedWrite", (k, v) => `keybed ${k} ${v}`);
    wrap("commit", () => "commit");
    wrap("set", (id, v) => `model_set ${id >>> 0} ${v | 0}`);
    wrap("loadPatch", (b, i) => `patch ${i}`);
    const tick = E.uiTick.bind(E);
    window.__kbAllow = false;
    E.uiTick = () => { if (window.__kbAllow) { log.push("ui_tick"); tick(); } };
    window.__kbTick = () => { window.__kbAllow = true; E.uiTick(); window.__kbAllow = false; skin.M.refresh(); };
    E.start = () => {};
    window.__kbPort = { name: "test", onmidimessage: null };
    skin.listen(window.__kbPort);
    const k = skin.visible(skin.tree).find(x => x.type === "keyboardX");
    const r = skin.cv.getBoundingClientRect();
    return { x: k.x, y: k.y, w: k.w, h: k.h, left: r.left, top: r.top, sx: r.width / skin.cv.width, sy: r.height / skin.cv.height };
  });
  if (TOOTH) await page.evaluate(t => {
    const { skin } = window.__skin;
    if (t === "velocity") { const f = skin.keyVelocity.bind(skin); skin.keyVelocity = (k, y) => Math.min(127, f(k, y) + 1); }
    if (t === "hold") { const p = skin.kbPress.bind(skin);   // the release of the other keys never sent
      skin.kbPress = (c, n, v, sh) => { const g = skin.E.keybedState; skin.E.keybedState = () => 0; p(c, n, v, sh); skin.E.keybedState = g; }; }
    if (t === "gap") { const h = skin.keyHit.bind(skin); skin.keyHit = (c, x, y) => { const a = h(c, x, y), b = h(c, x - 2, y); return b.n < a.n ? b : a; }; }
  }, TOOTH);
  const lines = script(seed, kb);
  let shift = false;
  const setShift = async s => { if (s !== shift) { s ? await page.keyboard.down("Shift") : await page.keyboard.up("Shift"); shift = s; } };
  const cx = x => kb.left + (x + 0.5) * kb.sx, cy = y => kb.top + (y + 0.5) * kb.sy;
  for (const ln of lines) {
    const t = ln.split(" ");
    if (t[0] === "down") { await setShift(false); await page.mouse.move(cx(+t[1]), cy(+t[2])); await setShift(t[3] === "1"); await page.mouse.down(); }
    else if (t[0] === "move") { await setShift(t[3] === "1"); await page.mouse.move(cx(+t[1]), cy(+t[2])); }
    else if (t[0] === "up") { await setShift(false); await page.mouse.up(); }
    else if (t[0] === "wheel") { await setShift(false); await page.mouse.move(cx(+t[1]), cy(+t[2])); await page.mouse.wheel(0, t[3] === "1" ? -100 : 100); }
    else if (t[0] === "set") await page.evaluate(([v, ref]) => window.__skin.skin.M.set(ref, v), [+t[1], t.slice(2).join(" ")]);
    else if (t[0] === "patch") await page.evaluate(([i, c]) => window.__skin.skin.loadPatch(i, c), [+t[1], t[2] === "1"]);
    else if (t[0] === "note") await page.evaluate(([n, v]) => window.__kbPort.onmidimessage({ data: [0x90, n, v] }), [+t[1], +t[2]]);
    else if (t[0] === "off") await page.evaluate(n => window.__kbPort.onmidimessage({ data: [0x80, n, 64] }), +t[1]);
    else if (t[0] === "tick") await page.evaluate(() => window.__kbTick());
  }
  const web = await page.evaluate(() => window.__kblog);
  await page.close();
  const sp = join(work, `s${seed}.txt`);
  await writeFile(sp, lines.join("\n") + "\n");
  execFileSync(WINE, [join(work, "JUNO-60.exe"), "--kbscript", sp], { cwd: work, env: { ...process.env, WINEDEBUG: "-all" }, timeout: 300000 });
  const exe = exeCalls(readFileSync(sp + ".log", "utf8"));
  let first = -1;
  for (let i = 0; i < Math.max(exe.length, web.length); i++) if (exe[i] !== web[i]) { first = i; break; }
  const ok = first < 0 && !errors.length && exe.some(x => x.startsWith("keybed"));
  if (!ok) fails++;
  const nk = exe.filter(x => x.startsWith("keybed")).length;
  console.log(`${ok ? "ok  " : "FAIL"} seed ${seed}: ${lines.length} events, ${exe.length} calls (${nk} keybed writes)` +
    (first >= 0 ? `; first difference at call ${first}: exe "${exe[first]}" web "${web[first]}"` : "") +
    (errors.length ? `; page errors: ${errors.join(" | ")}` : ""));
}
await browser.close();
srv.close();
await rm(work, { recursive: true, force: true });
if (TOOTH) {
  console.log(`skin_kb_check --tooth ${TOOTH}: ${fails === SEEDS.length ? "BITES" : "DID NOT BITE"} (${fails} of ${SEEDS.length} seeds FAIL)`);
  process.exit(fails === SEEDS.length ? 0 : 1);
}
console.log(`skin_kb_check: ${fails ? "RED" : "GREEN"} (${SEEDS.length} seeds)`);
process.exit(fails ? 1 : 0);
