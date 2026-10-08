// skin_check.mjs -- the skin GUI (gui/skin/) in headless Chromium, against the C99
// port compiled to WebAssembly (gui/web/juno.wasm).
//
// It serves the repository root (the page reads truth/Script.xml, the sprite
// sheets in truth/Script/ and the factory bank), boots the page, and checks:
//   boot     every sprite sheet of Script.xml loaded; no console error; the
//            factory patch 1 name on the panel's display
//   reach    every control the original panel draws resolves to a leaf of the
//            value tree (none silently dropped)
//   values   a control writes through the plugin's model path: the engine's
//            getState holds the new value -- DCO RANGE buttons, a slider drag,
//            a lever, the CHORUS buttons with the plugin's own rule (rva
//            0x351410: I -> TYPE 2, DEPTH 255, TONE 128; II -> 3; I + II -> 4;
//            OFF -> DEPTH 0), the LEDs (rva 0x3515B0)
//   patch    INC loads patch 2 through the plugin's patch load
//   keys     a click on a key sounds (engine output peak > 0) at the plugin's
//            click velocity (rva 0x2D4AA0)
// The screenshot goes to $SKIN_SHOT (default: the scratchpad).
//
// usage: node tools/verify/skin_check.mjs [--tooth NAME]
//   --tooth chorus   the CHORUS I button writes TYPE 3 (must FAIL)
//   --tooth address  the value-tree walk off by one unit (must FAIL)
//   --tooth swap     two valid parameters exchanged (must FAIL: identity)
import { chromium } from "playwright-core";
import { createServer } from "node:http";
import { readFile } from "node:fs/promises";
import { readFileSync } from "node:fs";
import { dirname, join, extname, normalize } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = normalize(join(dirname(fileURLToPath(import.meta.url)), "..", ".."));
const TOOTH = process.argv.includes("--tooth") ? process.argv[process.argv.indexOf("--tooth") + 1] : null;
const SHOT = process.env.SKIN_SHOT || join(ROOT, "scratchpad", "skin_check.png");
const MIME = { ".html": "text/html", ".js": "text/javascript", ".mjs": "text/javascript", ".wasm": "application/wasm",
               ".png": "image/png", ".xml": "application/xml", ".bin": "application/octet-stream", ".json": "application/json" };

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

const browser = await chromium.launch({ executablePath: "/opt/pw-browsers/chromium",
  args: ["--autoplay-policy=no-user-gesture-required", "--no-sandbox"] });
const page = await browser.newPage({ viewport: { width: 2000, height: 820 } });
const errors = [];
page.on("console", m => { if (m.type() === "error") errors.push(m.text()); });
page.on("pageerror", e => errors.push(String(e)));
await page.goto(`http://127.0.0.1:${port}/gui/skin/?zoom=100`);
await page.waitForFunction(() => window.__skin && window.__skin.skin, null, { timeout: 60000 });
await page.waitForTimeout(400);
// TEETH: defects put into the running page (the product code carries no test hook)
if (TOOTH === "chorus") await page.evaluate(() => {
  const { skin } = window.__skin, orig = skin.chorusPress.bind(skin);
  skin.chorusPress = (c, both) => (c.role === 1 && !both ? (orig(c, both), skin.M.set("fm.PATCH.NAME3.EFFECT TYPE", 3)) : orig(c, both));
});
if (TOOTH === "swap") await page.evaluate(() => {
  // two valid parameters exchanged: the write and the read-back still agree
  const { S } = window.__skin, orig = S.resolve.bind(S);
  const a = "fm.PATCH.FLT.VCF CUTOFF FREQ", b = "fm.PATCH.FLT.VCF RESONANCE";
  S.resolve = r => (r === a ? orig(b) : r === b ? orig(a) : orig(r));
});
if (TOOTH === "address") await page.evaluate(() => {
  const { S } = window.__skin, orig = S.resolve.bind(S);
  S.resolve = r => { const L = orig(r); return L && /^fm\./.test(r) ? { ...L, id: L.id + 1 } : L; };
});

const res = [];
const check = (name, ok, info) => { res.push([name, ok, info]); console.log(`${ok ? "ok  " : "FAIL"} ${name}${info ? "  " + info : ""}`); };

// --- boot
const boot = await page.evaluate(() => {
  const { S, skin, missing } = window.__skin;
  return { missing, nbmp: S.bitmaps.size, name: skin.patchNameText(), status: document.getElementById("status").textContent };
});
check("boot: sprite sheets", boot.missing.length === 0 && boot.nbmp === 30, `${boot.nbmp} declared, missing ${JSON.stringify(boot.missing)}`);
check("boot: patch name", boot.name === "SY Poly Synth", JSON.stringify(boot.name));

// --- reach: every value ref of the original face resolves
const reach = await page.evaluate(() => {
  const { S, skin } = window.__skin;
  const all = [], bad = [];
  const walk = n => { if (n.kind === "control") all.push(n); else n.items.forEach(walk); };
  const orig = skin.tree.items.find(n => n.type === "orig");
  walk(orig);
  for (const c of all) for (const r of c.refs) {
    if (/^(ms|vm\.ks)\./.test(r)) continue;          // the MIDI state and the keyboard's own view values
    if (!S.resolve(r)) bad.push(r);
  }
  return { n: all.length, bad };
});
check("reach: original panel refs resolve", reach.bad.length === 0, `${reach.n} controls; unresolved ${JSON.stringify(reach.bad)}`);

// --- identity: an INDEPENDENT witness of the address walk. The port's own
// tables, from the running plugin (probes/b6: the parameter list's ids and the
// id -> host parameter map), name every state id; each control's id must name
// the same parameter as its value ref's leaf.
const stateTab = readFileSync(join(ROOT, "src", "juno_state_tables.h"), "utf8").split("JUNO_PATCH_EV[")[0];
const hostNames = [...readFileSync(join(ROOT, "src", "juno_hostparams.c"), "utf8")
  .matchAll(/\{"([^"]+)"\s*,"[^"]*"\s*,\s*\d+,\s*\d+,/g)].map(m => m[1].trim());
const idName = {};
for (const m of stateTab.matchAll(/\{ 0x([0-9A-F]+)u, (-?\d+|JUNO_SE_\w+), /g))
  if (/^\d+$/.test(m[2])) idName[parseInt(m[1], 16)] = hostNames[+m[2]];
const ident = await page.evaluate(idName => {
  const { S, skin } = window.__skin;
  const all = [];
  const walk = n => { if (n.kind === "control") all.push(n); else n.items.forEach(walk); };
  walk(skin.tree.items.find(n => n.type === "orig"));
  let named = 0;
  const bad = [];
  for (const c of all) for (const r of c.refs) {
    const L = S.resolve(r);
    if (!L || !(L.id in idName)) continue;
    named++;
    const leafName = r.split(".").pop();
    if (idName[L.id] !== leafName) bad.push(`${r} -> 0x${L.id.toString(16)} = ${idName[L.id]}`);
  }
  return { named, bad };
}, idName);
check("identity: control ids name the same parameter (port tables)", ident.bad.length === 0 && ident.named >= 80,
      `${ident.named} refs on host parameters; mismatched ${JSON.stringify(ident.bad.slice(0, 4))}`);

// helpers in the page: the engine's getState value of a ref; click a control
const vals = refs => page.evaluate(rs => {
  const { S, E } = window.__skin, v = E.values();
  return Object.fromEntries(rs.map(r => [r, v.get(S.resolve(r).id)]));
}, refs);
async function clickControl(pred, opts = {}) {
  const box = await page.evaluate(src => {
    const { skin } = window.__skin;
    const f = new Function("c", "return " + src);
    const c = skin.visible(skin.tree).find(x => f(x));
    if (!c) return null;
    const b = skin.bounds(c), r = skin.cv.getBoundingClientRect(), k = r.width / skin.cv.width;
    return { x: r.left + (b[0] + b[2] / 2) * k, y: r.top + (b[1] + b[3] / 2) * k, k, b };
  }, pred);
  if (!box) throw new Error("no control: " + pred);
  if (opts.shift) await page.keyboard.down("Shift");
  await page.mouse.move(box.x, box.y);
  await page.mouse.down();
  if (opts.dragY) { await page.mouse.move(box.x, box.y + opts.dragY, { steps: 8 }); }
  await page.mouse.up();
  if (opts.shift) await page.keyboard.up("Shift");
  await page.waitForTimeout(60);
  return box;
}

// --- DCO RANGE: the radio buttons (onValue)
await clickControl(`c.type==="latchButton" && c.ref==="fm.PATCH.OSC1.DCO RANGE" && c.onValue===5`);
let v = await vals(["fm.PATCH.OSC1.DCO RANGE"]);
check("values: DCO RANGE 2' button", v["fm.PATCH.OSC1.DCO RANGE"] === 5, JSON.stringify(v));
// --- a slider drag (VCF CUTOFF FREQ): 60 px up raises it
const before = (await vals(["fm.PATCH.FLT.VCF CUTOFF FREQ"]))["fm.PATCH.FLT.VCF CUTOFF FREQ"];
await clickControl(`c.type==="slider" && c.ref==="fm.PATCH.FLT.VCF CUTOFF FREQ"`, { dragY: -40 });
const after = (await vals(["fm.PATCH.FLT.VCF CUTOFF FREQ"]))["fm.PATCH.FLT.VCF CUTOFF FREQ"];
check("values: VCF CUTOFF slider drag", after !== before, `${before} -> ${after}`);
// --- a lever (LFO KEY TRIG): a click flips it
const kt0 = (await vals(["fm.PATCH.LFO.LFO KEY TRIG"]))["fm.PATCH.LFO.LFO KEY TRIG"];
await clickControl(`c.type==="knob" && c.ref==="fm.PATCH.LFO.LFO KEY TRIG"`);
const kt1 = (await vals(["fm.PATCH.LFO.LFO KEY TRIG"]))["fm.PATCH.LFO.LFO KEY TRIG"];
check("values: LFO KEY TRIG lever", kt1 === 1 - kt0, `${kt0} -> ${kt1}`);

// --- CHORUS (rva 0x351410 / 0x3515B0)
const FX = ["fm.PATCH.NAME3.EFFECT TYPE", "fm.PATCH.EFX.EFFECT DEPTH", "fm.PATCH.NAME3.EFFECT TONE"];
const leds = () => page.evaluate(() => {
  const { skin } = window.__skin;
  return skin.visible(skin.tree).filter(c => c.type === "ju60Led").map(c => skin.chorusLed(c) ? 1 : 0);
});
await clickControl(`c.type==="ju60UnlatchButton" && c.role===1`);
v = await vals(FX);
check("chorus: I", v[FX[0]] === 2 && v[FX[1]] === 255 && v[FX[2]] === 128, JSON.stringify(v) + " leds " + JSON.stringify(await leds()));
check("chorus: I LEDs", JSON.stringify(await leds()) === "[1,0]");
await clickControl(`c.type==="ju60UnlatchButton" && c.role===2`);
v = await vals(FX);
check("chorus: II", v[FX[0]] === 3 && v[FX[1]] === 255, JSON.stringify(v));
await clickControl(`c.type==="ju60UnlatchButton" && c.role===1`, { shift: true });
v = await vals(FX);
check("chorus: I + II", v[FX[0]] === 4, JSON.stringify(v) + " leds " + JSON.stringify(await leds()));
check("chorus: I + II LEDs", JSON.stringify(await leds()) === "[1,1]");
await clickControl(`c.type==="ju60UnlatchButton" && c.role===0`);
v = await vals(FX);
check("chorus: OFF", v[FX[0]] === 4 && v[FX[1]] === 0, JSON.stringify(v) + " leds " + JSON.stringify(await leds()));
check("chorus: OFF LEDs", JSON.stringify(await leds()) === "[0,0]");

// --- the screenshot (before the patch change, so the edits above show)
await page.screenshot({ path: SHOT, clip: await page.evaluate(() => {
  const r = document.getElementById("panel").getBoundingClientRect();
  return { x: r.left, y: r.top, width: r.width, height: r.height };
}) });

// --- patch INC: the plugin's patch load of record 2
await clickControl(`c.type==="unlatchButton" && c.fn==="ManagePatch" && c.args==="inc"`);
const name2 = await page.evaluate(() => window.__skin.skin.patchNameText());
check("patch: INC loads patch 2", name2 === "SQ Dynamic ARPG", JSON.stringify(name2));

// --- a key: the engine sounds
await page.evaluate(() => window.__skin.E.peaks());
const kb = await page.evaluate(() => {
  const { skin } = window.__skin;
  const c = skin.visible(skin.tree).find(x => x.type === "keyboardX");
  const k = c.keys.find(k => k.n === 60);
  const r = skin.cv.getBoundingClientRect(), s = r.width / skin.cv.width;
  return { x: r.left + (k.x + k.w / 2) * s, y: r.top + (k.y + k.h * 0.9) * s, vel: skin.keyVelocity(k, k.y + k.h * 0.9) };
});
await page.mouse.move(kb.x, kb.y);
await page.mouse.down();
await page.waitForTimeout(700);
const peak = await page.evaluate(() => window.__skin.E.peaks());
await page.mouse.up();
check("keys: middle C sounds", Math.max(...peak) > 0, `peak ${peak.map(x => x.toFixed(4))} vel ${kb.vel}`);

check("console: no errors", errors.length === 0, JSON.stringify(errors.slice(0, 3)));
await browser.close();
srv.close();
const bad = res.filter(r => !r[1]).length;
console.log(`\n=== SKIN GUI (the plugin's Script.xml + sprite sheets on the C99 port): ${res.length - bad}/${res.length} ===`);
console.log("screenshot:", SHOT);
console.log(`GATE: ${bad ? "FAIL" : "PASS"}`);
process.exit(bad ? 1 : 0);
