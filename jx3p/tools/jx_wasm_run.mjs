// jx_wasm_run.mjs -- the DELIVERED JX-3P web engine (jx3p/gui/web/jx3p.js + jx3p.wasm) on the page's own
// calls, in node: jx3p_init, jx3p_recall, jx3p_render in 256-sample blocks (the page's ScriptProcessor),
// note on / off. Prints JSON: per patch, the FNV-1a-64 of every block's L and R float bits.
// jx3p/tools/jx_wasm_check.py runs the same calls through a native build and compares.
//   node jx3p/tools/jx_wasm_run.mjs [--dir DIR] [--patches 0,5,20,49]
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, '..', '..');
const ARGS = process.argv.slice(2);
const opt = (k) => { const i = ARGS.indexOf(k); return i >= 0 ? ARGS[i + 1] : null; };
const DIR = path.resolve(opt('--dir') || path.join(REPO, 'jx3p/gui/web'));
const PATCHES = (opt('--patches') || '0,5,20,49').split(',').map(Number);
// idle 24,064: past the 0.5 s start mute + 10 ms fade the plugin's writePatch arms (22,491 at 44100)
const PLAN = [['idle', 24064], ['on', 60, 100], ['render', 12032], ['off', 60], ['render', 4096]];
const N = 256;

const wasmBytes = fs.readFileSync(path.join(DIR, 'jx3p.wasm'));
const { default: Jx3pModule } = await import(pathToFileURL(path.join(DIR, 'jx3p.js')).href);
const M = await Jx3pModule({
  instantiateWasm(imports, cb) {
    const inst = new WebAssembly.Instance(new WebAssembly.Module(wasmBytes), imports);
    cb(inst); return inst.exports;
  },
});
M.FS.writeFile('/jx_template.bin', fs.readFileSync(path.join(REPO, 'jx3p/gen/jx_template.bin')));
M.FS.writeFile('/jx_master_recall.bin', fs.readFileSync(path.join(REPO, 'jx3p/gen/jx_master_recall.bin')));
M.FS.writeFile('/bank.bin', fs.readFileSync(path.join(REPO, 'jx3p/truth/preset_bank_1.bin')));

const MASK = (1n << 64n) - 1n, PRIME = 0x100000001b3n;
function fnv(u8) {
  let h = 0xcbf29ce484222325n;
  for (let i = 0; i < u8.length; i++) { h = (h ^ BigInt(u8[i])) & MASK; h = (h * PRIME) & MASK; }
  return h.toString(16).padStart(16, '0');
}
const pL = M._malloc(N * 4), pR = M._malloc(N * 4);
const out = {};
for (const p of PATCHES) {
  if (!M.ccall('jx3p_init', 'number', ['string', 'string', 'string'],
               ['/jx_template.bin', '/bank.bin', '/jx_master_recall.bin'])) { console.error('init failed'); process.exit(2); }
  M.ccall('jx3p_recall', null, ['number'], [p]);
  const hs = [];
  for (const op of PLAN) {
    if (op[0] === 'on') { M.ccall('jx3p_note_on', null, ['number', 'number'], [op[1], op[2]]); continue; }
    if (op[0] === 'off') { M.ccall('jx3p_note_off', null, ['number'], [op[1]]); continue; }
    for (let done = 0; done < op[1]; done += N) {
      M.ccall('jx3p_render', null, ['number', 'number', 'number'], [pL, pR, N]);
      const mem = M.HEAPF32.buffer;          // the page's build exports HEAPF32 only (build.sh)
      hs.push(fnv(new Uint8Array(mem, pL, 4 * N)) + fnv(new Uint8Array(mem, pR, 4 * N)));
    }
  }
  out[p] = hs;
}
process.stdout.write(JSON.stringify(out));
