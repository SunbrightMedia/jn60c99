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
//   keybedWrite(key, v)     the panel keyboard's write into its note value (rva
//                           0x2D47E0: v > 0 a press, else a release; a change only)
//   keybedState(key)        that value's state of a key (down above 0)
//   commit()                the commit a panel control makes after its set
//   setTempo(bpm)           the arp / tempo-sync clock when no host runs one
//   uiTick()                the plugin's 50 ms UI-timer drain (rva 0x320120)
//   start()                 open the audio output (a user gesture is needed)
//   ledFrame(n)             the LFO LED's tick (rva 0x325070): the engine's LED store
//                           read (rva 0x3C7180), the frame of a bitmap of n frames
//   meterTick(ch, decay, state, rect, horiz) -> {state, fill}
//                           a level meter's tick (rva 0x31C450): channel ch's peak
//                           read (rva 0x34AF70), the new state, the bar's fill rect
//   barDraw(rect, fill, horiz, fade) -> [[dx, dy, w, h, sx, sy, alpha], ...]
//                           what the bar draws (rva 0x31C210): alpha -1 a plain blit
//   ccEntry(id)             the CC map's record of a parameter (rva 0x319B10), -1 none
//   ccOf(id)                the CC a control shows (rva 0x319B70), -1 none or while a
//                           learn waits
//   ccLearn(id) / ccForget(id)  the CC assign menu's items (rva 0x31AA40 / 0x3192E0)
//   midiIn(status, d1, d2)  a MIDI message as a DAW gives it to the plugin: a note through
//                           the wrapper's MIDI intake; CC n, channel aftertouch and pitch bend
//                           as MIDI-mapping parameter points (base + n, + 128, + 129) that
//                           process() takes (rva 0x34A380) at the next block
//   peaks() -> [l, r]       the page's output peak since the last call, after the
//                           monitor fader (the checks' witness that the page sounds;
//                           not the plugin's meters, which meterTick reads)
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
      keybedWrite: f("juno_gui_keybed_write", "number", ["number", "number", "number"]),
      keybedState: f("juno_gui_keybed_state", "number", ["number", "number"]),
      commit: f("juno_gui_commit", null, ["number"]),
      render: f("juno_gui_render", "number", ["number", "number", "number"]),
      ledFrame: f("juno_gui_lfo_led_frame", "number", ["number", "number"]),
      meterTick: f("juno_gui_meter_tick", "number",
                   ["number", "number", "number", "number", "number", "number", "number"]),
      barDraw: f("juno_gui_bar_draw", "number", ["number", "number", "number", "number", "number", "number"]),
      ccEntry: f("juno_gui_cc_entry", "number", ["number"]),
      ccOf: f("juno_gui_cc_of", "number", ["number", "number"]),
      ccLearn: f("juno_gui_cc_learn", "number", ["number", "number"]),
      ccForget: f("juno_gui_cc_forget", "number", ["number", "number"]),
      hostParam: f("juno_gui_host_param", null, ["number", "number", "number", "number"]),
      midiBase: f("juno_gui_midi_base", "number", []),
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
    this.BLITS = 256;                            // a bar draws 1 + fade blits (Script.xml: fade 10)
    this.rectPtr = M._malloc(4 * (8 + 7 * this.BLITS));   // rect[4], fill[4], blits[7 x BLITS]
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
  midiIn(st, d1, d2) {
    const cmd = st & 0xf0, base = this.fn.midiBase() >>> 0;
    if (cmd === 0x90 && d2 > 0) this.noteOn(d1, d2);
    else if (cmd === 0x80 || cmd === 0x90) this.noteOff(d1);
    else if (cmd === 0xb0) this.fn.hostParam(this.ctx, base + d1, 0, d2 / 127);
    else if (cmd === 0xd0) this.fn.hostParam(this.ctx, base + 128, 0, d1 / 127);
    else if (cmd === 0xe0) this.fn.hostParam(this.ctx, base + 129, 0, (d1 | (d2 << 7)) / 16383);
  }
  setTempo(bpm) { this.fn.setTempo(this.ctx, bpm); }
  uiTick() { this.fn.uiTick(this.ctx); }
  ledFrame(n) { return this.fn.ledFrame(this.ctx, n); }
  meterTick(ch, decay, state, rect, horiz) {
    new Int32Array(this.M.HEAPU8.buffer, this.rectPtr, 4).set(rect);
    const st = this.fn.meterTick(this.ctx, ch, decay, state, this.rectPtr, horiz, this.rectPtr + 16);
    return { state: st, fill: Array.from(new Int32Array(this.M.HEAPU8.buffer, this.rectPtr + 16, 4)) };
  }
  barDraw(rect, fill, horiz, fade) {
    const W = new Int32Array(this.M.HEAPU8.buffer, this.rectPtr, 8);
    W.set(rect, 0);
    W.set(fill, 4);
    const n = Math.min(this.fn.barDraw(this.rectPtr, this.rectPtr + 16, horiz, fade, this.rectPtr + 32, this.BLITS), this.BLITS);
    const I = new Int32Array(this.M.HEAPU8.buffer, this.rectPtr + 32, 7 * this.BLITS);
    const out = [];
    for (let i = 0; i < n; i++) out.push(Array.from(I.subarray(7 * i, 7 * i + 7)));
    return out;
  }
  ccEntry(id) { return this.fn.ccEntry(id >>> 0); }
  ccOf(id) { return this.fn.ccOf(this.ctx, id >>> 0); }
  ccLearn(id) { return this.fn.ccLearn(this.ctx, id >>> 0); }
  ccForget(id) { return this.fn.ccForget(this.ctx, id >>> 0); }
  keybedWrite(key, v) { return this.fn.keybedWrite(this.ctx, key, v); }
  keybedState(key) { return this.fn.keybedState(this.ctx, key); }
  commit() { this.fn.commit(this.ctx); }

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
