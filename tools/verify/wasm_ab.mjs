// wasm_ab.mjs — drive the ACTUAL built WASM engine (gui/web/juno.wasm) through the
// browser play-path (create -> apply_bank -> note_on -> render) and diff its stereo
// master output sample-for-sample against the plugin's own captured master_l/master_r.
// This proves the DELIVERED artifact — not just the native lib — matches the plugin.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, '../..');
const BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin';
const CAPDIR = path.join(HERE, 'idstate64');

const wasmBytes = fs.readFileSync(path.join(REPO, 'gui/web/juno.wasm'));
const { default: JunoModule } = await import(path.join(REPO, 'gui/web/juno.js'));

const Module = await JunoModule({
  instantiateWasm(imports, cb) {
    const mod = new WebAssembly.Module(wasmBytes);
    const inst = new WebAssembly.Instance(mod, imports);
    cb(inst);
    return inst.exports;
  },
});

const create   = Module.cwrap('juno_gui_create', 'number', ['number', 'number']);
const applyBank= Module.cwrap('juno_gui_apply_bank', 'number', ['number', 'number', 'number', 'number']);
const noteOn   = Module.cwrap('juno_gui_note_on', null, ['number', 'number', 'number']);
const arpCfg   = Module.cwrap('juno_gui_arp_config', null, ['number','number','number','number','number','number']);
const render   = Module.cwrap('juno_gui_render', 'number', ['number', 'number', 'number']);

const arpOff = process.argv.includes('arpoff');
const bank = fs.readFileSync(BANK);
const bankPtr = Module._malloc(bank.length);
Module.HEAPU8.set(bank, bankPtr);

let exact = 0, total = 0, off = 0;
const rows = [];
for (let p = 0; p < 64; p++) {
  const lp = path.join(CAPDIR, `master_l_p${p}.bin`);
  const rp = path.join(CAPDIR, `master_r_p${p}.bin`);
  if (!fs.existsSync(lp) || !fs.existsSync(rp)) continue;
  const pl = new Uint32Array(fs.readFileSync(lp).buffer.slice(0));
  const pr = new Uint32Array(fs.readFileSync(rp).buffer.slice(0));
  const N = pl.length; total++;

  const ctx = create(48000.0, 0);
  applyBank(ctx, bankPtr, bank.length, p);
  if (arpOff) arpCfg(ctx, 0, 0, 1, 120.0, 0.6);
  noteOn(ctx, 60, 105);
  const outPtr = Module._malloc(4 * 2 * N);
  render(ctx, outPtr, N);
  // read back interleaved L,R floats as raw u32 for exact bit compare
  const outU32 = new Uint32Array(Module.HEAPU8.buffer, outPtr, 2 * N);
  const outF32 = new Float32Array(Module.HEAPU8.buffer, outPtr, 2 * N);
  const plF = new Float32Array(pl.buffer);
  let dl = 0, dr = 0, sp = 0, so = 0;
  for (let i = 0; i < N; i++) {
    if (outU32[2*i]   !== pl[i]) dl++;
    if (outU32[2*i+1] !== pr[i]) dr++;
    sp += plF[i]*plF[i]; so += outF32[2*i]*outF32[2*i];
  }
  const ratio = sp > 0 ? Math.sqrt(so/N)/Math.sqrt(sp/N) : 0;
  Module._free(outPtr);
  if (dl === 0 && dr === 0) exact++;
  else { const aud = ratio < 0.99 || ratio > 1.01; if (aud) off++;
    rows.push(`${String(p).padStart(3)}  L${String(dl).padStart(5)} R${String(dr).padStart(5)}  ratio ${ratio.toFixed(3)}${aud?'  <-- AUDIBLE':''}`); }
}
if (rows.length) console.log(rows.join('\n'));
console.log(`\nWASM BROWSER-PATH A/B${arpOff?' (arp-off)':''}: ${exact}/${total} bit-exact vs plugin master; ${off} audibly off`);
