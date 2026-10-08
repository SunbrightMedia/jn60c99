// engine.js -- the ONE interface between the JUNO-60 skin and a synth engine.
//
// The skin (skin.js) never calls the C port directly: it calls these methods. A
// backend for the bare-metal port (the plug-and-play test API: Web MIDI SysEx or
// Web Serial to the board) implements the same methods and the skin runs
// unchanged. Every method names the plugin path it stands for.
//
//   await init()            boot the plugin as a host does (initialize: six voices,
//                           the 95 parameter-list defaults, the start-up mute)
//   values()   -> Map       the model as getState writes it: id -> value
//   set(id, v) -> bool      a GUI control's model edit (rva 0x283DB0): the store
//                           keeps value & mask, the engine gets it at the next
//                           block; false = not a parameter-list id
//   loadPatch(bank, idx)    the patch browser's load (rva 0x335850)
//   noteOn(n, vel) / noteOff(n)   a key through the wrapper's MIDI intake
//   setTempo(bpm)           the arp / tempo-sync clock when no host runs one
//   uiTick()                the plugin's 50 ms UI-timer drain (rva 0x320120)
//   start()                 open the audio output (a user gesture is needed)
//   peaks() -> [l, r]       output peak since the last call (display only)
//
// WasmEngine: the C99 port compiled to WebAssembly (gui/web/juno.js + juno.wasm,
// the same build `make webapp` gates WASM == native).

export class WasmEngine {
  constructor(base = "../web/") {
    this.base = base;
    this.M = null;
    this.ctx = 0;
    this.audio = null;
    this.node = null;
    this.peak = [0, 0];
    // the monitor fader after the engine (a DAW fader's role): UNISON patches
    // peak near 2.0 in the plugin's own engine, which a browser clips at 1.0
    this.gain = 0.5;
    this.bankPtr = 0;
    this.bankLen = 0;
    this.bankKey = null;
  }

  async init() {
    const { default: JunoModule } = await import(this.base + "juno.js");
    const M = (this.M = await JunoModule({ locateFile: p => this.base + p }));
    const f = (n, r, a) => M.cwrap(n, r, a);
    this.fn = {
      create: f("juno_gui_create", "number", ["number", "number"]),
      pluginInit: f("juno_gui_plugin_init", "number", ["number"]),
      modelSet: f("juno_gui_model_set", "number", ["number", "number", "number"]),
      stateSave: f("juno_gui_state_save", "number", ["number", "number", "number"]),
      loadPatch: f("juno_gui_load_patch", "number", ["number", "number", "number", "number"]),
      noteOn: f("juno_gui_midi_note_on", null, ["number", "number", "number"]),
      noteOff: f("juno_gui_midi_note_off", null, ["number", "number"]),
      setTempo: f("juno_gui_set_tempo", null, ["number", "number"]),
      uiTick: f("juno_gui_ui_tick", null, ["number"]),
      render: f("juno_gui_render", "number", ["number", "number", "number"]),
    };
    // the engine is built for the output device's own rate: nothing resamples
    try {
      this.audio = new (window.AudioContext || window.webkitAudioContext)();
    } catch (e) {
      this.audio = null;
    }
    const sr = this.audio && this.audio.sampleRate > 0 ? this.audio.sampleRate | 0 : 48000;
    this.ctx = this.fn.create(sr, 0);
    if (!this.ctx) throw new Error("engine alloc failed");
    if (!this.fn.pluginInit(this.ctx)) throw new Error("engine init failed");
    this.sr = sr;
    this.stateCap = 4 + 8 * (95 + 128);
    this.statePtr = M._malloc(this.stateCap);
    return this;
  }

  values() {
    const M = this.M, out = new Map();
    const n = this.fn.stateSave(this.ctx, this.statePtr, this.stateCap);
    if (n < 0) return out;
    const dv = new DataView(M.HEAPU8.buffer, this.statePtr, this.stateCap);
    const bytes = dv.getUint32(0, false);
    for (let o = 4; o + 8 <= 4 + bytes; o += 8) out.set(dv.getUint32(o, false), dv.getInt32(o + 4, false));
    return out;
  }

  set(id, v) {
    return this.fn.modelSet(this.ctx, id >>> 0, v | 0) !== 0;
  }

  loadPatch(bank, idx) {
    const M = this.M;
    if (this.bankKey !== bank) {                 // one heap copy per bank
      if (this.bankPtr) M._free(this.bankPtr);
      this.bankPtr = M._malloc(bank.length);
      M.HEAPU8.set(bank, this.bankPtr);
      this.bankLen = bank.length;
      this.bankKey = bank;
    }
    return this.fn.loadPatch(this.ctx, this.bankPtr, this.bankLen, idx);
  }

  noteOn(n, vel) { this.fn.noteOn(this.ctx, n, vel); }
  noteOff(n) { this.fn.noteOff(this.ctx, n); }
  setTempo(bpm) { this.fn.setTempo(this.ctx, bpm); }
  uiTick() { this.fn.uiTick(this.ctx); }

  start() {
    if (!this.audio) this.audio = new (window.AudioContext || window.webkitAudioContext)();
    this.audio.resume();
    if (this.node) return;
    const BLK = 1024, M = this.M;
    const buf = M._malloc(BLK * 2 * 4);
    const node = this.audio.createScriptProcessor(BLK, 0, 2);
    node.onaudioprocess = e => {
      const L = e.outputBuffer.getChannelData(0), R = e.outputBuffer.getChannelData(1);
      const n = L.length;
      this.fn.render(this.ctx, buf, n);
      const s = new Float32Array(M.HEAPF32.buffer, buf, n * 2);
      let pl = this.peak[0], pr = this.peak[1];
      const g = this.gain;
      for (let i = 0; i < n; i++) {
        const l = s[2 * i] * g, r = s[2 * i + 1] * g;
        // the browser's output clips at 1.0; the engine's own samples are untouched
        L[i] = l > 1 ? 1 : l < -1 ? -1 : l;
        R[i] = r > 1 ? 1 : r < -1 ? -1 : r;
        const al = l < 0 ? -l : l, ar = r < 0 ? -r : r;
        if (al > pl) pl = al;
        if (ar > pr) pr = ar;
      }
      this.peak = [pl, pr];
    };
    node.connect(this.audio.destination);
    this.node = node;
  }

  peaks() {
    const p = this.peak;
    this.peak = [0, 0];
    return p;
  }
}
