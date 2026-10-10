// jx_wasm_run.mjs -- the DELIVERED JX-3P web engine (jx3p/gui/web/jx3p.js + jx3p.wasm) on the page's own
// calls, in node: jx3p_init on the 96 kHz data, jx3p_recall, jx3p_product_open(host rate), then
// jx3p_product_block per 256-sample block with that block's events (the page's ScriptProcessor and its
// queue; JX-10). Prints JSON: per patch, the FNV-1a-64 of every block's L and R float bits.
// jx3p/tools/jx_wasm_check.py builds the plan (--plan FILE: {"rate": R, "blocks": [[[off, type, key, vel],
// ...], ...]}) and runs the same calls through a native build.
//   node jx3p/tools/jx_wasm_run.mjs --plan FILE [--dir DIR] [--patches 0,5,20,49]
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { fileURLToPath, pathToFileURL } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, '..', '..');
const ARGS = process.argv.slice(2);
const opt = (k) => { const i = ARGS.indexOf(k); return i >= 0 ? ARGS[i + 1] : null; };
const DIR = path.resolve(opt('--dir') || path.join(REPO, 'jx3p/gui/web'));
const PATCHES = (opt('--patches') || '0,5,20,49').split(',').map(Number);
const PLAN = JSON.parse(fs.readFileSync(opt('--plan'), 'utf8'));
const N = 256, QMAX = 128;

const wasmBytes = fs.readFileSync(path.join(DIR, 'jx3p.wasm'));
const { default: Jx3pModule } = await import(pathToFileURL(path.join(DIR, 'jx3p.js')).href);
const M = await Jx3pModule({
  instantiateWasm(imports, cb) {
    const inst = new WebAssembly.Instance(new WebAssembly.Module(wasmBytes), imports);
    cb(inst); return inst.exports;
  },
});
// the page's own data files: the 96 kHz template and recall data, as the page fetches them (.gz)
const gz = (f) => zlib.gunzipSync(fs.readFileSync(path.join(REPO, 'jx3p/gen', f)));
M.FS.writeFile('/jx_template.bin', gz('jx_template_96k.bin.gz'));
M.FS.writeFile('/jx_master_recall.bin', gz('jx_master_recall_96k.bin.gz'));
M.FS.writeFile('/bank.bin', fs.readFileSync(path.join(REPO, 'jx3p/truth/preset_bank_1.bin')));

const MASK = (1n << 64n) - 1n, PRIME = 0x100000001b3n;
function fnv(u8) {
  let h = 0xcbf29ce484222325n;
  for (let i = 0; i < u8.length; i++) { h = (h ^ BigInt(u8[i])) & MASK; h = (h * PRIME) & MASK; }
  return h.toString(16).padStart(16, '0');
}
const pL = M._malloc(N * 4), pR = M._malloc(N * 4), pEv = M._malloc(QMAX * 16);
const out = {};
for (const p of PATCHES) {
  if (!M.ccall('jx3p_init', 'number', ['string', 'string', 'string'],
               ['/jx_template.bin', '/bank.bin', '/jx_master_recall.bin'])) { console.error('init failed'); process.exit(2); }
  M.ccall('jx3p_recall', null, ['number'], [p]);
  if (M.ccall('jx3p_product_open', 'number', ['number'], [PLAN.rate]) < 0) { console.error('open failed'); process.exit(2); }
  const hs = [];
  for (const evs of PLAN.blocks) {
    const v = new Int32Array(M.HEAPF32.buffer, pEv, QMAX * 4);   // the page's build exports HEAPF32 only
    evs.forEach((e, i) => v.set(e, 4 * i));
    M.ccall('jx3p_product_block', 'number', ['number', 'number', 'number', 'number', 'number'],
            [pL, pR, N, pEv, evs.length]);
    const mem = M.HEAPF32.buffer;
    hs.push(fnv(new Uint8Array(mem, pL, 4 * N)) + fnv(new Uint8Array(mem, pR, 4 * N)));
  }
  out[p] = hs;
}
process.stdout.write(JSON.stringify(out));
