// skin_pm_run.mjs -- plays a patch manager gate's command script into the web page's patch window
// (gui/skin: the patch manager compiled into the WASM) and writes its log in JUNO-60.exe's
// --pm-script form, for tools/verify/skin_pm_check.py to grade against THE PLUGIN'S run.
//
// usage: node tools/verify/skin_pm_run.mjs RUN.json OUT.log
// RUN.json (skin_pm_check.py): { setup: URL of the folders' setup (?pmsetup=), rate, watch: [the folders
//   the log lists], ops: [{ full: 0|1, answers: [[kind, value], ...], cmd: [...] }] }
// Before each command the window is open (its PATCH button, as JUNO-60.exe's script does); the commands
// go through the page's own code as JUNO-60.exe's go through the program's: a key through the list's key
// handler (skin.patchKey), a button through skin.action, the list's mouse through the manager's mouse
// with the page's capture (patchMove / patchUp), the bank name's mouse through the manager's, a model set
// without a commit, a save, the timer. The dialogs take the script's answers (skin.answers). After each
// command: the dialogs and file changes in order, the model calls, the manager's whole state, every file
// of the watched folders -- the hashes SHA-1, 16 hex digits (computed in the page: plumbing).
import { chromium } from "playwright-core";
import { createServer } from "node:http";
import { readFile, writeFile } from "node:fs/promises";
import { readFileSync } from "node:fs";
import { dirname, join, extname, normalize } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = normalize(join(dirname(fileURLToPath(import.meta.url)), "..", ".."));
const MIME = { ".html": "text/html", ".js": "text/javascript", ".mjs": "text/javascript", ".wasm": "application/wasm",
               ".png": "image/png", ".xml": "application/xml", ".bin": "application/octet-stream", ".json": "application/json" };
const run = JSON.parse(readFileSync(process.argv[2], "utf8"));
const OUT = process.argv[3];

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
const page = await browser.newPage({ viewport: { width: 2000, height: 820 }, screen: { width: 1920, height: 1080 } });
const errors = [];
page.on("pageerror", e => errors.push(String(e)));
page.on("console", m => { if (m.type() === "error") errors.push("console: " + m.text()); });
await page.goto(`http://127.0.0.1:${port}/gui/skin/?fresh&zoom=100&rate=${run.rate}&pmsetup=${encodeURIComponent(run.setup)}`);
await page.waitForFunction(() => window.__skin && window.__skin.skin, null, { timeout: 120000 });

const log = await page.evaluate(run => {
  const { skin, E, pm, files } = window.__skin;
  // ---- plumbing: SHA-1 (its first 8 bytes in hex), a string's bytes as "=HEX" or "-"
  const K = [0x5A827999, 0x6ED9EBA1, 0x8F1BBCDC, 0xCA62C1D6];
  const sha16 = bytes => {
    if (!bytes) bytes = new Uint8Array(0);
    const n = bytes.length, nb = ((n + 9 + 63) >> 6) << 6, m = new Uint8Array(nb);
    m.set(bytes);
    m[n] = 0x80;
    const dv = new DataView(m.buffer);
    dv.setUint32(nb - 4, (n * 8) >>> 0);
    dv.setUint32(nb - 8, Math.floor(n / 0x20000000));
    let h0 = 0x67452301, h1 = 0xEFCDAB89, h2 = 0x98BADCFE, h3 = 0x10325476, h4 = 0xC3D2E1F0;
    const w = new Uint32Array(80);
    for (let o = 0; o < nb; o += 64) {
      for (let i = 0; i < 16; i++) w[i] = dv.getUint32(o + 4 * i);
      for (let i = 16; i < 80; i++) { const x = w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16]; w[i] = (x << 1) | (x >>> 31); }
      let a = h0, b = h1, c = h2, d = h3, e = h4;
      for (let i = 0; i < 80; i++) {
        const f = i < 20 ? (b & c) | (~b & d) : i < 40 ? b ^ c ^ d : i < 60 ? (b & c) | (b & d) | (c & d) : b ^ c ^ d;
        const t = (((a << 5) | (a >>> 27)) + f + e + K[(i / 20) | 0] + w[i]) | 0;
        e = d; d = c; c = (b << 30) | (b >>> 2); b = a; a = t;
      }
      h0 = (h0 + a) | 0; h1 = (h1 + b) | 0; h2 = (h2 + c) | 0; h3 = (h3 + d) | 0; h4 = (h4 + e) | 0;
    }
    return [h0, h1].map(x => (x >>> 0).toString(16).padStart(8, "0")).join("");
  };
  const hexstr = s => s === null || s === undefined ? "-" : "=" + Array.from(s, ch => (ch.charCodeAt(0) & 255).toString(16).padStart(2, "0")).join("");
  const hexbytes = h => { const b = new Uint8Array(h.length >> 1); for (let i = 0; i < b.length; i++) b[i] = parseInt(h.substr(2 * i, 2), 16); return b; };
  const out = [];
  const digest = full => {
    const [vb, vp, tk] = pm.viewValues();
    out.push(`cur ${pm.curBank()} ${pm.cur(1)} sel ${pm.sel()} clip ${sha16(pm.clip())} fmt ${pm.format()} tick ${tk} ` +
             `view ${sha16(pm.record())} values ${vb} ${vp} win ${pm.value(0x0FFFC002)} ${pm.value(0x0FFFC004)} ` +
             `${pm.value(0x0FFFC005)} ${pm.value(0x0FFFC006)}`);
    for (let b = 0; b < pm.nbanks(); b++) {
      const [n, cur] = pm.hist(b);
      out.push(`bank ${cur} ${n}`);
      for (let i = 0; i < n; i++) {
        const si = pm.stateInfo(b, i);
        let l = `st ${hexstr(si.name)} ${si.view} ${sha16(si.edit)}`;
        if (full || i === cur) for (let k = 0; k < 64; k++) l += " " + sha16(pm.stateRec(b, i, k));
        out.push(l);
      }
    }
    run.watch.forEach((d, i) => {
      for (const nm of files.list(d)) {
        const data = files.read(d + "/" + nm);
        if (data) out.push(`file ${i} ${hexstr(nm)} ${sha16(data)}`);
      }
    });
    out.push("end");
  };
  // the dialogs, file changes and model calls of a command, in their order, in the program's lines
  const ev = [];
  skin.trace = ev;
  files.log = ev;
  const flush = () => {
    for (const e of ev) {
      if (typeof e === "string") {
        const t = e.split(" ");
        if (t[0] === "queue_record") out.push("call load " + sha16(hexbytes(t[1])));
        else if (t[0] === "pm_set") out.push(`call set ${t[1]} ${t[2]} ${t[3]}`);
        else if (t[0] === "pm_notify") out.push("call notify");
        else if (t[0] === "pm_commit") out.push("call commit");
      } else if (e[0] === "write") out.push("fw " + hexstr(e[1]));
      else if (e[0] === "delete") out.push("fd " + hexstr(e[1]));
      else if (e[0] === "move") out.push("fm " + hexstr(e[1]) + " " + hexstr(e[2]));
      else if (e[0] === "text") out.push("text " + hexstr(e[1]) + " " + hexstr(e[2]));
      else if (e[0] === "menu") out.push(`menu ${e[3]}` + e[1].map((it, k) => ` ${e[2][k] ? 1 : 0}${hexstr(it)}`).join(""));
      else if (e[0] === "box") { if (e[1] !== 38) out.push(`message ${e[1]}`); out.push(`box ${e[1] === 38 ? 0x31 : 0x30}`); }
      else if (e[0] === "fdopen") out.push(`fdopen ${e[1] ? e[1].length : -1}` + (e[1] || []).map(p => " " + hexstr(p)).join(""));
      else if (e[0] === "fdsave") out.push("fdsave " + hexstr(e[1]) + " " + hexstr(e[2]));
    }
    ev.length = 0;
  };
  const keyName = { 0x20: " ", 0x100: "ArrowUp", 0x101: "ArrowDown", 0x102: "ArrowLeft", 0x103: "ArrowRight",
                    0x108: "Enter", 0x109: "Escape", 0x10B: "Delete" };
  const T = skin.patchTree;
  // --tooth (skin_pm_check.py): a defect in the page's own code, which the check must see
  if (run.tooth === "keys") {                                 // the list's up and down keys exchanged
    const pk = skin.patchKey.bind(skin);
    skin.patchKey = e => pk({ ...e, key: e.key === "ArrowUp" ? "ArrowDown" : e.key === "ArrowDown" ? "ArrowUp" : e.key });
  }
  if (run.tooth === "capture") skin.patchMove = () => false;  // a drag's moves lost
  if (run.tooth === "button") skin.pwButton = () => null;     // the bank name's button unknown: no rename there
  out.push("boot");
  ev.length = 0;
  digest(1);
  for (const op of run.ops) {
    if (pm.value(0x0FFFC002) !== 1) skin.M.set("vm.vs.panelPatch", 1);    // the PATCH button
    ev.length = 0;
    skin.answers = op.answers.map(a => [a[0], a[1]]);
    out.push("op");
    const c = op.cmd;
    if (c[0] === "key") {
      const code = c[1], fl = c[2];
      const key = keyName[code] !== undefined ? keyName[code] : String.fromCharCode(code).toLowerCase();
      skin.patchKey({ key, shiftKey: !!(fl & 1), ctrlKey: !!(fl & 2), metaKey: false });
    } else if (c[0] === "func") skin.action(c[1], c[2]);
    else if (c[0] === "mouse") {
      const lr = skin.pwRect("patch");
      for (const [t, x, y] of c[1]) {
        const X = x + T.x, Y = y + T.y;                         // the plugin panel's point in the page's frame
        if (t === 0 || t === 2) { if (skin.pmCall(() => pm.mouse(t, X, Y, lr))) skin.pmCap = true; }
        else if (t === 3) skin.patchMove(X, Y);
        else if (t === 1) skin.patchUp(X, Y);
      }
    } else if (c[0] === "bank") {
      const br = skin.pwRect("patchBankName"), bt = skin.pwButton();
      for (const [t, x, y] of c[1]) skin.pmCall(() => pm.bankMouse(t, x + T.x, y + T.y, br, bt));
    } else if (c[0] === "set") { E.fn.modelSet(E.ctx, c[1] >>> 0, c[2] | 0); skin.M.refresh(); }   // no commit
    else if (c[0] === "save") pm.saveAll();
    else if (c[0] === "tick") for (let k = 0; k < c[1]; k++) pm.tick();
    flush();
    out.push("state");
    digest(op.full);
    skin.answers = null;                                       // the unused answers go
  }
  return out;
}, run);
await writeFile(OUT, log.join("\n") + "\n");
await browser.close();
srv.close();
if (errors.length) { console.error("page errors: " + errors.slice(0, 5).join(" | ")); process.exit(1); }
