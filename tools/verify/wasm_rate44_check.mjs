// wasm_rate44_check.mjs — verify the DELIVERED WASM carries the 44.1 kHz rate-arm
// fix: cold 8000-frame render at 44100 vs the cached plugin refs (rate44_plug.pkl
// was pickled by python; instead use the raw plugin dumps re-exported as .bin).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, '../..');
const SCR = '/tmp/claude-0/-home-user-jn60c99/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/scratchpad';
const BANK = '/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin';

const wasmBytes = fs.readFileSync(path.join(REPO, 'gui/web/juno.wasm'));
const { default: JunoModule } = await import(path.join(REPO, 'gui/web/juno.js'));
const Module = await JunoModule({ instantiateWasm(imports, cb) {
  const inst = new WebAssembly.Instance(new WebAssembly.Module(wasmBytes), imports); cb(inst); return inst.exports; }});
const create   = Module.cwrap('juno_gui_create','number',['number','number']);
const applyBank= Module.cwrap('juno_gui_apply_bank','number',['number','number','number','number']);
const noteOn   = Module.cwrap('juno_gui_note_on', null,['number','number','number']);
const render   = Module.cwrap('juno_gui_render','number',['number','number','number']);
const bank = fs.readFileSync(BANK);
const bankPtr = Module._malloc(bank.length); Module.HEAPU8.set(bank, bankPtr);

const N = 8000;
for (const p of [13, 0, 43, 53]) {
  const ref = fs.readFileSync(path.join(SCR, `rate44_plug_p${p}.bin`));
  const Lp = new Uint32Array(ref.buffer.slice(0, 4*N));
  const Rp = new Uint32Array(ref.buffer.slice(4*N, 8*N));
  const ctx = create(44100.0, 0);
  applyBank(ctx, bankPtr, bank.length, p);
  noteOn(ctx, 60, 105);
  const out = Module._malloc(4*2*N); render(ctx, out, N);
  const u = new Uint32Array(Module.HEAPU8.buffer, out, 2*N);
  let nd = 0, first = -1;
  for (let i = 0; i < N; i++) if (u[2*i] !== Lp[i] || u[2*i+1] !== Rp[i]) { nd++; if (first < 0) first = i; }
  Module._free(out);
  console.log(`  patch ${p} @44100: ${nd === 0 ? 'BIT-EXACT over ' + N + ' frames' : 'diffs=' + nd + ' FIRST@' + first}`);
}
