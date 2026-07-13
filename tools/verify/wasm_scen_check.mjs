// wasm_scen_check.mjs — verify the DELIVERED WASM carries the phase-2 fixes:
//   Scenario B (retrigger)  vs cached plugin scenB_plug_p13/43.bin  (bit-exact)
//   Scenario E (live param) vs cached plugin out/plug_<P>_{L,R}.bin  (bit-exact)
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
const noteOff  = Module.cwrap('juno_gui_note_off',null,['number','number']);
const setParam = Module.cwrap('juno_gui_set_param','number',['number','number','number']);
const render   = Module.cwrap('juno_gui_render','number',['number','number','number']);
const bank = fs.readFileSync(BANK);
const bankPtr = Module._malloc(bank.length); Module.HEAPU8.set(bank, bankPtr);

function renderInto(ctx, n, L, R) {
  const p = Module._malloc(4*2*n); render(ctx, p, n);
  const u = new Uint32Array(Module.HEAPU8.buffer, p, 2*n);
  for (let i=0;i<n;i++){ L.push(u[2*i]); R.push(u[2*i+1]); }
  Module._free(p);
}

// ---- Scenario B (retrigger), patches 13 & 43 ----
console.log('=== Scenario B retrigger (WASM vs cached plugin) ===');
const SEQB = [['on',60,105,6000],['off',60,0,24000],['on',60,105,6000],['off',60,0,3000],['on',60,40,6000]];
for (const p of [13,43]) {
  const ctx = create(48000.0, 0); applyBank(ctx, bankPtr, bank.length, p);
  const L=[],R=[];
  for (const [ev,n,v,r] of SEQB){ if(ev==='on')noteOn(ctx,n,v); else noteOff(ctx,n); renderInto(ctx,r,L,R); }
  const data = fs.readFileSync(path.join(SCR, `scenB_plug_p${p}.bin`));
  const N = L.length; const Lp = new Uint32Array(data.buffer.slice(0,4*N)); const Rp = new Uint32Array(data.buffer.slice(4*N,8*N));
  let nd=0, first=-1; for (let i=0;i<N;i++) if(L[i]!==Lp[i]||R[i]!==Rp[i]){ nd++; if(first<0)first=i; }
  console.log(`  patch ${p}: ${N} frames diffs=${nd}  ${nd?('FIRST@'+first):'BIT-EXACT'}`);
}

// ---- Scenario E (live param), patch 13 ----
console.log('=== Scenario E live param move (WASM vs cached plugin) ===');
const OUT = path.join(SCR,'out');
const CASES = [['VCF_CUTOFF',0,200],['VCF_RES',1,60],['DCO_SAW',17,40],['ENV1_ATK',6,180],
  ['ENV2_ATK',10,140],['VCA_LEVEL',16,180],['VCA_TONE',14,220],['ENV2_REL',11,200],['ENV1_SUS',8,60]];
let allok=true;
for (const [name,idx,byte] of CASES) {
  const ctx = create(48000.0, 0); applyBank(ctx, bankPtr, bank.length, 13);
  noteOn(ctx,60,105); const L=[],R=[]; renderInto(ctx,3000,L,R);
  setParam(ctx, idx, byte); renderInto(ctx,6000,L,R);
  const lp = new Uint32Array(fs.readFileSync(path.join(OUT,`plug_${name}_L.bin`)).buffer.slice(0));
  const rp = new Uint32Array(fs.readFileSync(path.join(OUT,`plug_${name}_R.bin`)).buffer.slice(0));
  const N = Math.min(lp.length, L.length); let nd=0, first=-1;
  for (let i=0;i<N;i++) if(L[i]!==lp[i]||R[i]!==rp[i]){ nd++; if(first<0)first=i; }
  if(nd) allok=false;
  console.log(`  ${name.padEnd(12)} idx${String(idx).padStart(2)} b${String(byte).padStart(3)}: ${N} frames diffs=${nd}  ${nd?('FIRST@'+first):'BIT-EXACT'}`);
}
console.log('\n' + (allok?'SCENARIO E: ALL 9 BIT-EXACT in WASM':'SCENARIO E: SOME DIVERGENT'));
