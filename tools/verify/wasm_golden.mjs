// wasm_golden.mjs — drive the DELIVERED WASM engine (gui/web/juno.wasm) through the
// same 44.1 kHz golden corpus as the native/Teensy test and verify each scenario's
// FNV-1a-64 output hash. The golden hashes are generated from the native build,
// which is bit-exact to the plugin (docs/CLAIMS.md), so a match proves the delivered
// browser artifact reproduces the plugin bit-for-bit. Self-contained: reconstructs a
// minimal 1-patch bank from each scenario's embedded 704-byte record — no bank file.
//
// Run: node tools/verify/wasm_golden.mjs   (after gui/web/build.sh)
//
// --script FILE: replay an op list of API calls (the web app's own flow, written
// with the native hashes by tools/verify/wasm_product_gate.py) and compare the
// FNV-1a-64 of every render. --dir DIR: the juno.js/juno.wasm to load (default
// gui/web). WASM_SCRIPT_TOOTH=no_init|apply_bank changes the flow (gate teeth).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, '..', '..');
const ARGS = process.argv.slice(2);
const opt = (k) => { const i = ARGS.indexOf(k); return i >= 0 ? ARGS[i + 1] : null; };
const DIR = path.resolve(opt('--dir') || path.join(REPO, 'gui/web'));

const wasmBytes = fs.readFileSync(path.join(DIR, 'juno.wasm'));
const { default: JunoModule } = await import(pathToFileURL(path.join(DIR, 'juno.js')).href);
const Module = await JunoModule({
  instantiateWasm(imports, cb) {
    const inst = new WebAssembly.Instance(new WebAssembly.Module(wasmBytes), imports);
    cb(inst); return inst.exports;
  },
});

if (opt('--script')) process.exit(runScript(JSON.parse(fs.readFileSync(opt('--script'), 'utf8'))));
const scen = JSON.parse(fs.readFileSync(path.join(HERE, 'teensy_golden.json'), 'utf8'));

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

// FNV-1a-64 in two 32-bit halves (prime 2^40 + 0x1b3)
function fnvHex(u8) {
  let hi = 0xcbf29ce4, lo = 0x84222325;
  for (let i = 0; i < u8.length; i++) {
    lo = (lo ^ u8[i]) >>> 0;
    const a = lo * 0x1b3;
    const carry = Math.floor(a / 4294967296);
    hi = (Math.imul(hi, 0x1b3) + carry + (lo << 8)) >>> 0;
    lo = a >>> 0;
  }
  return hi.toString(16).padStart(8, '0') + lo.toString(16).padStart(8, '0');
}

function runScript(sc) {
  const N = 'number';
  const F = {
    create: Module.cwrap('juno_gui_create', N, [N, N]),
    plugin_init: Module.cwrap('juno_gui_plugin_init', N, [N]),
    load: Module.cwrap('juno_gui_load_patch', N, [N, N, N, N]),
    apply: Module.cwrap('juno_gui_apply_bank', N, [N, N, N, N]),
    vel_sw: Module.cwrap('juno_gui_set_kbd_velocity', null, [N, N]),
    warmup: Module.cwrap('juno_gui_warmup', null, [N, N]),
    tempo: Module.cwrap('juno_gui_set_tempo', null, [N, N]),
    on: Module.cwrap('juno_gui_note_on', null, [N, N, N]),
    off: Module.cwrap('juno_gui_note_off', null, [N, N]),
    mon: Module.cwrap('juno_gui_midi_note_on', null, [N, N, N]),
    moff: Module.cwrap('juno_gui_midi_note_off', null, [N, N]),
    host: Module.cwrap('juno_gui_host_set', null, [N, N, N]),
    arp: Module.cwrap('juno_gui_arp_config', null, [N, N, N, N, N, N]),
    render: Module.cwrap('juno_gui_render', N, [N, N, N]),
  };
  const tooth = process.env.WASM_SCRIPT_TOOTH || '';
  const bank = fs.readFileSync(sc.bank);
  const bankPtr = Module._malloc(bank.length);
  Module.HEAPU8.set(bank, bankPtr);
  let bad = 0;
  for (const ch of sc.chains) {
    let c = 0, k = 0, first = -1;
    for (const op of ch.ops) {
      switch (op[0]) {
        case 'create': c = F.create(op[1], 0); break;
        case 'vel_sw': F.vel_sw(c, op[1]); break;
        case 'plugin_init': if (tooth !== 'no_init') F.plugin_init(c); break;
        case 'warmup': F.warmup(c, op[1]); break;
        case 'load': (tooth === 'apply_bank' ? F.apply : F.load)(c, bankPtr, bank.length, op[1]); break;
        case 'tempo': F.tempo(c, op[1]); break;
        case 'on': F.on(c, op[1], op[2]); break;
        case 'off': F.off(c, op[1]); break;
        case 'mon': F.mon(c, op[1], op[2]); break;
        case 'moff': F.moff(c, op[1]); break;
        case 'host': F.host(c, op[1], op[2]); break;
        case 'arp': F.arp(c, op[1], op[2], op[3], op[4], op[5]); break;
        case 'render': {
          const out = Module._malloc(8 * op[1]);
          F.render(c, out, op[1]);
          const h = fnvHex(new Uint8Array(Module.HEAPU8.buffer, out, 8 * op[1]));
          Module._free(out);
          if (h !== ch.hashes[k] && first < 0) first = k;
          k++;
          break;
        }
        default: throw new Error('unknown op ' + op[0]);
      }
    }
    if (first < 0 && k === ch.hashes.length)
      console.log(`OK:   ${ch.name.padEnd(12)} ${k} renders bit-exact vs native`);
    else {
      console.log(`FAIL: ${ch.name.padEnd(12)} render ${first} of ${k} differs from native`);
      bad++;
    }
  }
  Module._free(bankPtr);
  if (bad) { console.log(`FAIL: ${bad}/${sc.chains.length} chains diverged`); return 1; }
  console.log(`ALL OK: ${sc.chains.length}/${sc.chains.length} chains, every render bit-exact vs native`);
  return 0;
}
