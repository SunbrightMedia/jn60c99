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
//   --tooth ccedge     the skin's CC assign search counts the right and bottom edges inside (must FAIL;
//                      the search's ORDER is not observable on this panel -- docs/CC_MENU.md rule 4)
//   --tooth ccmods     the skin's CC assign menu opens with Shift held (must FAIL)
//
// Then the CC assign menu (CLAIMS A38; the exe's own is graded against the plugin's handler on
// the plugin's tree by tools/verify/cc_menu_gate.py): per seed, the search at the edges of every
// control it can stop at and at random points (the skin's ccTarget, the exe's ccpick), REAL
// right-button presses (Playwright, with Shift / Ctrl / Alt at times) and the menu's item clicked
// (Learn, Forget -- a greyed one stays open -- or Escape), MIDI CCs through the page's MIDI input,
// audio blocks and drains, and the state (getState's bytes, the CC map included). Compared: the
// menus (the parameter, the CC shown, the labels, enabled), learns, forgets, the calls, the states.
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
const DUMP = arg("--dump", null);
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
    else if (t[0] === "commit" || t[0] === "ui_tick" || t[0] === "pm_notify" || t[0] === "pm_commit") out.push(t[0]);
    else if (t[0] === "queue_record" || t[0] === "pm_set" || t[0] === "zoomfit" || t[0] === "ledshow") out.push(ln);
    else if (t[0] === "cc_learn" || t[0] === "cc_forget") out.push(`${t[0]} ${t[1]}`);
    else if (t[0] === "state") out.push(ln);
    else if (ln.startsWith("# ccpick ") || ln.startsWith("# ccmenu ")) out.push(ln.slice(2));
  }
  return out;
}

// a seeded CC assign script over the skin's own controls: c = [{x, y, w, h, cc, drag}] (cc: the
// search stops there; drag: a slider or knob, which a press with modifiers may take)
function ccScript(seed, ctl, W, H) {
  let r = (2246822519 ^ Math.imul(seed, 2654435761)) >>> 0 || 1;
  const rnd = () => { r ^= r << 13; r >>>= 0; r ^= r >>> 17; r ^= r << 5; r >>>= 0; return r; };
  const cc = ctl.filter(c => c.cc), drag = ctl.filter(c => c.drag);
  const inside = c => [c.x + rnd() % c.w, c.y + rnd() % c.h];
  const out = ["set 100 vm.vs.mainZoom", "block", "state"];   // the exe boots at its window's zoom, the page at its URL's
  for (const c of cc)                                  // the edges of every control the search stops at
    for (const [x, y] of [[c.x, c.y], [c.x + c.w - 1, c.y + c.h - 1], [c.x - 1, c.y], [c.x, c.y - 1],
                          [c.x + c.w, c.y + c.h - 1], [c.x + c.w - 1, c.y + c.h]])
      out.push(`ccpick ${x} ${y}`);
  for (let i = 0; i < EVENTS; i++) {
    const k = rnd() % 100;
    if (k < 30) out.push(`ccpick ${rnd() % W} ${rnd() % H}`);
    else if (k < 60) { const [x, y] = inside(cc[rnd() % cc.length]); out.push(`rdown ${x} ${y} 0 ${rnd() % 3}`, "up"); }
    else if (k < 68) {                                 // modifiers: no menu, the press goes to the control
      const [x, y] = inside(drag[rnd() % drag.length]);
      out.push(`rdown ${x} ${y} ${[1, 2, 8, 3, 9][rnd() % 5]} 2`, "up");
    }
    else if (k < 85) out.push(`cc ${rnd() % 120} ${rnd() % 128}`, "block", "tick");
    else if (k < 92) out.push("tick");
    else out.push("state");
  }
  out.push("block", "tick", "state");
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
// the program's screen (its log's "editor CX CY": the virtual screen its windows fit, docs/WINDOW_ZOOM.md):
// the page gets the same one, so both windows convert to the same zooms
await writeFile(join(work, "probe.txt"), "tick\n");
execFileSync(WINE, [join(work, "JUNO-60.exe"), "--kbscript", join(work, "probe.txt")], { cwd: work, env: { ...process.env, WINEDEBUG: "-all" }, timeout: 300000 });
const ed = readFileSync(join(work, "probe.txt.log"), "utf8").split(/\r?\n/).find(l => l.startsWith("editor "));
if (!ed) throw new Error("the program's log has no editor line");
const SCREEN = { width: +ed.split(" ")[1], height: +ed.split(" ")[2] };
const cr = readFileSync(join(work, "probe.txt.log"), "utf8").split(/\r?\n/).find(l => l.startsWith("create "));
const RATE = cr ? +cr.split(" ")[1] : 48000;       // the program's engine rate: the page's too (?rate=)
console.log(`the program's screen: ${SCREEN.width} x ${SCREEN.height}, its rate ${RATE} (the page's too)`);
// the program's banks (make_native.py: the factory bank, then scratchpad/userbanks/*.bin, each named by its
// file) for the page's Patch folder, through its ?banks= manifest; the program's test runs keep the
// factory bank current (its setting PatchManager/BankName), the page gets the same setting
const { readdirSync } = await import("node:fs");
const udir = join(ROOT, "scratchpad", "userbanks");
const manifest = (() => { try { return readdirSync(udir); } catch { return []; } })().filter(f => f.toLowerCase().endsWith(".bin")).sort()
  .map(f => ({ name: f.replace(/\.bin$/i, "").replace(/^~+/, "").trim(), file: "userbanks/" + encodeURIComponent(f) }));
await writeFile(join(ROOT, "scratchpad", "skin_kb_banks.json"), JSON.stringify(manifest));
const PAGE = `/gui/skin/?zoom=100&fresh&rate=${RATE}&banks=${encodeURIComponent("/scratchpad/skin_kb_banks.json")}`;
const setting = () => localStorage.setItem("juno60.PatchManager/BankName", "Factory");

let fails = 0;
for (const seed of SEEDS) {
  const page = await browser.newPage({ viewport: { width: 2000, height: 820 }, screen: SCREEN });
  const errors = [];
  page.on("pageerror", e => errors.push(String(e)));
  await page.addInitScript(setting);
  await page.goto(`http://127.0.0.1:${port}${PAGE}`);
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
    skin.trace = log;                              // the page's own: zoomfit, ledshow, the patch manager's calls
    const tick = E.uiTick.bind(E);
    window.__kbAllow = false;
    E.uiTick = () => { if (window.__kbAllow) { log.push("ui_tick"); tick(); } };
    const mtick = skin.meterTick.bind(skin), ptick = skin.pm.tick.bind(skin.pm);
    skin.meterTick = () => (window.__kbAllow ? mtick() : false);      // the page's own timer held: its
    skin.pm.tick = () => {};                                          // LED and meter reads come from the script
    window.__kbTick = () => { window.__kbAllow = true; E.uiTick(); skin.M.refresh(); skin.meterTick(); window.__kbAllow = false; };
    E.start = () => {};
    const blk = E.M._malloc(8 * 128);
    window.__kbBlock = () => E.fn.render(E.ctx, blk, 128);              // the exe's audio block
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
    else if (t[0] === "patch") await page.evaluate(([i, c]) => window.__skin.skin.scriptedPatch(i, c), [+t[1], t[2] === "1"]);
    else if (t[0] === "note") await page.evaluate(([n, v]) => window.__kbPort.onmidimessage({ data: [0x90, n, v] }), [+t[1], +t[2]]);
    else if (t[0] === "off") await page.evaluate(n => window.__kbPort.onmidimessage({ data: [0x80, n, 64] }), +t[1]);
    else if (t[0] === "tick") await page.evaluate(() => window.__kbTick());
    else if (t[0] === "block") await page.evaluate(() => window.__kbBlock());
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
// ---------------------------------------------------------------- the CC assign menu
let ccFails = 0;
for (const seed of SEEDS) {
  const page = await browser.newPage({ viewport: { width: 2400, height: 1100 }, screen: SCREEN });   // room for a menu at the edge
  const errors = [];
  page.on("pageerror", e => errors.push(String(e)));
  await page.addInitScript(setting);
  await page.goto(`http://127.0.0.1:${port}${PAGE}`);
  await page.waitForFunction(() => window.__skin && window.__skin.skin, null, { timeout: 60000 });
  const geo = await page.evaluate(dump => {
    const { E, skin } = window.__skin;
    const log = window.__kblog = [];
    const wrap = (name, fmt) => { const f = E[name].bind(E); E[name] = (...a) => { log.push(fmt(...a)); return f(...a); }; };
    wrap("keybedWrite", (k, v) => `keybed ${k} ${v}`);
    wrap("commit", () => "commit");
    wrap("set", (id, v) => `model_set ${id >>> 0} ${v | 0}`);
    skin.trace = log;
    wrap("ccLearn", id => `cc_learn ${id >>> 0}`);
    wrap("ccForget", id => `cc_forget ${id >>> 0}`);
    window.__dbg = [];
    if (dump) {                                        // --dump: who closes a menu, what the presses hit
      const cl = skin.closeMenu.bind(skin);
      skin.closeMenu = () => { window.__dbg.push("close " + (new Error().stack || "").split("\n").slice(2, 5).join(" / ")); cl(); };
      document.addEventListener("pointerdown", e => window.__dbg.push("pd " + e.target.className + " " + e.button), true);
      document.addEventListener("click", e => window.__dbg.push("click " + e.target.className), true);
    }
    const cm = skin.ccMenu.bind(skin);
    skin.ccMenu = (ev, t) => {
      const cc = E.ccOf(t.id);
      const m = cm(ev, t);
      log.push(`ccmenu ${t.id >>> 0} ${cc} ` + [...m.children].map(b => `${b.textContent}|${b.classList.contains("off") ? 0 : 1}`).join("|"));
      return m;
    };
    const tick = E.uiTick.bind(E);
    window.__kbAllow = false;
    E.uiTick = () => { if (window.__kbAllow) { log.push("ui_tick"); tick(); } };
    const mtick = skin.meterTick.bind(skin), ptick = skin.pm.tick.bind(skin.pm);
    skin.meterTick = () => (window.__kbAllow ? mtick() : false);      // the page's own timer held: its
    skin.pm.tick = () => {};                                          // LED and meter reads come from the script
    window.__kbTick = () => { window.__kbAllow = true; E.uiTick(); skin.M.refresh(); skin.meterTick(); window.__kbAllow = false; };
    E.start = () => {};
    const blk = E.M._malloc(8 * 128), sb = E.M._malloc(4 + 8 * 256);
    window.__kbBlock = () => E.fn.render(E.ctx, blk, 128);              // the exe's audio block
    window.__kbState = () => {
      const n = E.fn.stateSave(E.ctx, sb, 4 + 8 * 256);
      return "state " + Array.from(new Uint8Array(E.M.HEAPU8.buffer, sb, Math.max(n, 0)), b => b.toString(16).padStart(2, "0")).join("");
    };
    window.__kbPort = { name: "test", onmidimessage: null };
    skin.listen(window.__kbPort);
    const ctl = [];
    for (const c of skin.visible(skin.tree)) {
      const b = skin.bounds(c);
      if (!b || b[2] <= 0 || b[3] <= 0) continue;
      const t = skin.ccTarget(b[0] + (b[2] >> 1), b[1] + (b[3] >> 1));
      ctl.push({ x: b[0], y: b[1], w: b[2], h: b[3], cc: !!t && t.c === c, drag: c.type === "slider" || c.type === "knob" });
    }
    const r = skin.cv.getBoundingClientRect();
    return { ctl, W: skin.cv.width, H: skin.cv.height, left: r.left, top: r.top, sx: r.width / skin.cv.width, sy: r.height / skin.cv.height };
  }, !!DUMP);
  if (TOOTH === "ccedge") await page.evaluate(() => {
    const { skin } = window.__skin;              // the right and bottom edges inside the rectangle
    skin.ccTarget = function (x, y, node = this.tree) {
      if (node.kind !== "panel" || !this.open(node)) return null;
      for (let i = node.items.length - 1; i >= 0; i--) {
        const c = node.items[i];
        if (c.kind !== "control") continue;
        const b = this.bounds(c);
        if (!b || x < b[0] || x > b[0] + b[2] || y < b[1] || y > b[1] + b[3]) continue;
        if (c.type === "label" || c.type === "display" || c.refs.length !== 1) continue;
        const L = this.M.leaf(c.ref);
        if (L && this.E.ccEntry(L.id) >= 0) return { c, id: L.id };
      }
      for (let i = node.items.length - 1; i >= 0; i--) if (node.items[i].kind === "panel") { const t = this.ccTarget(x, y, node.items[i]); if (t) return t; }
      return null;
    };
  });
  if (TOOTH === "ccmods") await page.evaluate(() => {
    const { skin } = window.__skin;              // Shift does not stop the menu
    const d = skin.down.bind(skin);
    skin.down = ev => d(ev.button === 2 && ev.shiftKey ? new Proxy(ev, { get: (o, k) => k === "shiftKey" ? false : (typeof o[k] === "function" ? o[k].bind(o) : o[k]) }) : ev);
  });
  const lines = ccScript(seed, geo.ctl, geo.W, geo.H);
  const cx = x => geo.left + (x + 0.5) * geo.sx, cy = y => geo.top + (y + 0.5) * geo.sy;
  const MODKEYS = [[1, "Shift"], [2, "Control"], [8, "Alt"]];
  let held = null;
  const trace = [];                                    // --dump: the web log's length after each script line
  for (const ln of lines) {
    if (DUMP) trace.push(await page.evaluate(() => window.__kblog.length));
    const t = ln.split(" ");
    if (t[0] === "ccpick") await page.evaluate(([x, y]) => {
      const tt = window.__skin.skin.ccTarget(x, y);
      window.__kblog.push(`ccpick ${x} ${y} ${tt ? tt.id >>> 0 : -1}`);
    }, [+t[1], +t[2]]);
    else if (t[0] === "rdown") {
      const mods = +t[3], item = +t[4];
      await page.mouse.move(cx(+t[1]), cy(+t[2]));
      for (const [bit, key] of MODKEYS) if (mods & bit) await page.keyboard.down(key);
      await page.mouse.down({ button: "right" });
      held = "right";
      const open = await page.evaluate(() => !!window.__skin.skin.menuEl);
      if (open) {
        await page.mouse.up({ button: "right" });
        held = null;
        if (item < 2) {
          const before = DUMP ? await page.evaluate(() => { window.__dbg = []; return window.__kblog.length; }) : 0;
          const el = page.locator(".menu .mi").nth(item);
          await el.click();
          if (DUMP) {                                  // a click that did nothing on an enabled item: why
            const d = await page.evaluate(b => ({ n: window.__kblog.length - b, dbg: window.__dbg, menus: document.querySelectorAll(".menu").length }), before);
            const on = await page.evaluate(i => { const m = window.__skin.skin.menuEl; return m ? !m.children[i].classList.contains("off") : null; }, item);
            if (d.n === 0 && on !== false) console.log("  click on item", item, "did nothing:", JSON.stringify(d).slice(0, 600));
          }
        }
        if (await page.evaluate(() => !!window.__skin.skin.menuEl)) await page.keyboard.press("Escape");
      }
      for (const [bit, key] of MODKEYS) if (mods & bit) await page.keyboard.up(key);
    }
    else if (t[0] === "up") { if (held) { await page.mouse.up({ button: held }); held = null; } }
    else if (t[0] === "cc") await page.evaluate(([n, v]) => window.__kbPort.onmidimessage({ data: [0xb0, n, v] }), [+t[1], +t[2]]);
    else if (t[0] === "set") await page.evaluate(([v, ref]) => window.__skin.skin.M.set(ref, v), [+t[1], t.slice(2).join(" ")]);
    else if (t[0] === "block") await page.evaluate(() => window.__kbBlock());
    else if (t[0] === "tick") await page.evaluate(() => window.__kbTick());
    else if (t[0] === "state") await page.evaluate(() => window.__kblog.push(window.__kbState()));
  }
  const web = await page.evaluate(() => window.__kblog);
  await page.close();
  const sp = join(work, `c${seed}.txt`);
  await writeFile(sp, lines.join("\n") + "\n");
  execFileSync(WINE, [join(work, "JUNO-60.exe"), "--kbscript", sp], { cwd: work, env: { ...process.env, WINEDEBUG: "-all" }, timeout: 300000 });
  const exe = exeCalls(readFileSync(sp + ".log", "utf8"));
  let first = -1;
  for (let i = 0; i < Math.max(exe.length, web.length); i++) if (exe[i] !== web[i]) { first = i; break; }
  if (DUMP && first >= 0) {                    // --dump DIR: both call lists of a failing seed, the script
    await writeFile(join(DUMP, `cc${seed}_exe.txt`), exe.join("\n") + "\n");
    await writeFile(join(DUMP, `cc${seed}_web.txt`), web.join("\n") + "\n");
    await writeFile(join(DUMP, `cc${seed}_script.txt`), lines.map((l, i) => `${trace[i]}\t${l}`).join("\n") + "\n");
  }
  const menus = exe.filter(x => x.startsWith("ccmenu")).length, learns = exe.filter(x => x.startsWith("cc_learn")).length;
  const forgets = exe.filter(x => x.startsWith("cc_forget")).length, picks = exe.filter(x => x.startsWith("ccpick")).length;
  const states = exe.filter(x => x.startsWith("state")), moved = new Set(states).size > 1;
  const ok = first < 0 && !errors.length && menus > 0 && learns > 0 && (TOOTH ? true : moved);
  if (!ok) ccFails++;
  console.log(`${ok ? "ok  " : "FAIL"} CC seed ${seed}: ${lines.length} events, ${picks} searches, ${menus} menus, ${learns} learns, ` +
    `${forgets} forgets, ${states.length} states (${new Set(states).size} distinct)` +
    (first >= 0 ? `; first difference at call ${first}: exe "${(exe[first] || "").slice(0, 120)}" web "${(web[first] || "").slice(0, 120)}"` : "") +
    (errors.length ? `; page errors: ${errors.join(" | ")}` : ""));
}

await browser.close();
srv.close();
await rm(work, { recursive: true, force: true });
if (TOOTH) {                                   // a keyboard tooth fails every keyboard seed, a CC tooth every CC seed
  const n = TOOTH.startsWith("cc") ? ccFails : fails;
  console.log(`skin_kb_check --tooth ${TOOTH}: ${n === SEEDS.length ? "BITES" : "DID NOT BITE"} (${n} of ${SEEDS.length} seeds FAIL)`);
  process.exit(n === SEEDS.length ? 0 : 1);
}
console.log(`skin_kb_check: ${fails || ccFails ? "RED" : "GREEN"} (${SEEDS.length} keyboard seeds, ${SEEDS.length} CC seeds)`);
process.exit(fails || ccFails ? 1 : 0);
