// wasm_golden.mjs — drive the DELIVERED WASM engine (gui/web/juno.wasm) through the
// same 44.1 kHz golden corpus as the native/Teensy test and verify each scenario's
// FNV-1a-64 output hash. The golden hashes are generated from the native build,
// which is bit-exact to the plugin (docs/CLAIMS.md), so a match proves the delivered
// browser artifact reproduces the plugin bit-for-bit. Self-contained: reconstructs a
// minimal 1-patch bank from each scenario's embedded 704-byte record — no bank file.
//
// Run: node tools/verify/wasm_golden.mjs   (after gui/web/build.sh)
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, '..', '..');
const scen = JSON.parse(fs.readFileSync(path.join(HERE, 'teensy_golden.json'), 'utf8'));

const wasmBytes = fs.readFileSync(path.join(REPO, 'gui/web/juno.wasm'));
const { default: JunoModule } = await import(path.join(REPO, 'gui/web/juno.js'));
const Module = await JunoModule({
  instantiateWasm(imports, cb) {
    const inst = new WebAssembly.Instance(new WebAssembly.Module(wasmBytes), imports);
    cb(inst); return inst.exports;
  },
});

const create   = Module.cwrap('juno_gui_create', 'number', ['number', 'number']);
const applyBank= Module.cwrap('juno_gui_apply_bank', 'number', ['number', 'number', 'number', 'number']);
const noteOn   = Module.cwrap('juno_gui_note_on', null, ['number', 'number', 'number']);
const noteOff  = Module.cwrap('juno_gui_note_off', null, ['number', 'number']);
const render   = Module.cwrap('juno_gui_render', 'number', ['number', 'number', 'number']);

const HEADER = 23, STRIDE = 20223, BLOB = 16;
const FNV_PRIME = 0x100000001b3n, MASK = (1n << 64n) - 1n;

function fnvBytes(h, u8) {
  for (let i = 0; i < u8.length; i++) { h = (h ^ BigInt(u8[i])) & MASK; h = (h * FNV_PRIME) & MASK; }
  return h;
}

let bad = 0;
for (const s of scen) {
  // minimal 1-patch bank
  const bank = new Uint8Array(HEADER + STRIDE);
  bank[0] = 0x4b; // 'K'
  bank.set(Uint8Array.from(s.blob), HEADER + BLOB);
  const bankPtr = Module._malloc(bank.length);
  Module.HEAPU8.set(bank, bankPtr);

  const ctx = create(44100.0, 0);
  applyBank(ctx, bankPtr, bank.length, 0);

  let h = 0xcbf29ce484222325n, cur = 0;
  const doRender = (n) => {
    const outPtr = Module._malloc(4 * 2 * n);
    render(ctx, outPtr, n);
    const bytes = new Uint8Array(Module.HEAPU8.buffer, outPtr, 4 * 2 * n);
    h = fnvBytes(h, bytes);
    Module._free(outPtr);
  };
  for (const [at, kind, note, vel] of s.events) {
    if (at > cur) { doRender(at - cur); cur = at; }
    if (kind === 1) noteOn(ctx, note, vel); else noteOff(ctx, note);
  }
  if (s.nframes > cur) doRender(s.nframes - cur);
  Module._free(bankPtr);

  const got = h.toString(16).padStart(16, '0');
  if (got === s.hash) {
    console.log(`OK:   ${s.name.padEnd(14)} patch ${String(s.patch).padStart(2)}  hash ${got}`);
  } else {
    console.log(`FAIL: ${s.name.padEnd(14)} patch ${String(s.patch).padStart(2)}  got ${got}  want ${s.hash}`);
    bad++;
  }
}
if (bad) { console.log(`FAIL: ${bad}/${scen.length} WASM golden scenarios diverged`); process.exit(1); }
console.log(`ALL OK: ${scen.length}/${scen.length} WASM golden scenarios bit-exact vs native/plugin`);
