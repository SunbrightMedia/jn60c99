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
//   zoomGet(win, value, cx, cy, w, h) -> zoom
//                           a window's coordinate conversion (rva 0x2AA590): its zoom value,
//                           at most the window's fit to the screen cx x cy (rva 0x312750, the
//                           first positive fit kept per window); the caller sets the value
//                           to the result when it differs (docs/WINDOW_ZOOM.md)
//   modelGet(id)            the model's value of a state entry (getState's)
//   patchManager(io, dirs)  the plugin's patch manager (CLAIMS A39, docs/PATCH_MANAGER.md) on
//                           this engine: its files and dialogs from `io` (PatchManager below)
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

  // rate: the engine's rate when given (a check runs the page at its program's), else the output's
  async init(rate = 0) {
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
      zoomGet: f("juno_gui_zoom_get", "number", ["number", "number", "number", "number", "number", "number"]),
      modelGet: f("juno_gui_model_get", "number", ["number", "number"]),
      record: f("juno_gui_record", "number", ["number", "number", "number"]),
      queueRecord: f("juno_gui_queue_record", "number", ["number", "number", "number"]),
    };
    // the engine is built for the output device's own rate: nothing resamples
    try {
      this.audio = new (window.AudioContext || window.webkitAudioContext)();
    } catch (e) {
      this.audio = null;
    }
    const sr = rate > 0 ? rate | 0 : this.audio && this.audio.sampleRate > 0 ? this.audio.sampleRate | 0 : 48000;
    this.ctx = this.fn.create(sr, 0);
    if (!this.ctx) throw new Error("engine alloc failed");
    if (!this.fn.pluginInit(this.ctx)) throw new Error("engine init failed");
    this.sr = sr;
    this.stateCap = 4 + 8 * (95 + 128);
    this.statePtr = M._malloc(this.stateCap);
    this.BLITS = 256;                            // a bar draws 1 + fade blits (Script.xml: fade 10)
    this.rectPtr = M._malloc(4 * (8 + 7 * this.BLITS));   // rect[4], fill[4], blits[7 x BLITS]
    this.zfit = M._malloc(8);                    // each window's kept fit (main, patch)
    M.HEAP32.set([0, 0], this.zfit >> 2);
    return this;
  }

  zoomGet(win, value, cx, cy, w, h) {
    return this.fn.zoomGet(value | 0, cx | 0, cy | 0, w | 0, h | 0, this.zfit + 4 * (win ? 1 : 0));
  }
  modelGet(id) { return this.fn.modelGet(this.ctx, id >>> 0); }
  patchManager(io, dirs) { return new PatchManager(this, io, dirs); }

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

// ------------------------------------------------------------------ the patch manager
// The plugin's patch manager (gui/juno_pm.c, CLAIMS A39), compiled into the same module: the
// page gives it its files and dialogs (`io`, synchronous; a page that must ask the user first
// asks before the call and answers from what it got), the engine gives it the model -- the
// record image (rva 0x335990), a record's load (the patch browser's, rva 0x335850), the model's
// set / notify / commit. Strings cross as bytes (Latin-1), as the plugin's ANSI calls take them.
//   io.read(path) -> Uint8Array | null          io.write(path, bytes) -> bool
//   io.remove(path) -> bool   io.move(from, to) -> bool   io.exists(path) -> bool
//   io.list(dir) -> [names] | null (the folder's order: NTFS's)
//   io.text(what, offered) -> string | null (0 a patch's name, 1 a bank's)
//   io.menu(items, checked) -> index | -1      io.confirm(msg) -> bool (2, 3, 37, 38)
//   io.openFiles(title, ext) -> [first path, then names] | null
//   io.saveFile(title, suggested) -> path | null
//   io.onCall(kind, ...) (optional): every model call ("set", id, v, flag), ("notify"),
//   ("commit"), ("load", body) -- the checks' log; the page's notify hook (LED shows)
export class PatchManager {
  constructor(E, io, dirs) {
    const M = (this.M = E.M);
    this.E = E;
    this.io = io;
    const f = (n, r, a) => M.cwrap(n, r, a);
    const P = "number";
    this.fn = {
      create: f("juno_pm_create", P, [P, P, P, P, P, P]),
      attach: f("juno_pm_attach", P, [P]),
      initialize: f("juno_pm_initialize", null, [P]),
      pref: f("juno_pm_pref", P, [P]),
      setPref: f("juno_pm_set_pref", null, [P, P]),
      detach: f("juno_pm_detach", null, [P]),
      tick: f("juno_pm_tick", null, [P]),
      saveAll: f("juno_pm_save_all", P, [P]),
      key: f("juno_pm_key", P, [P, P, P, P]),
      func: f("juno_pm_func", P, [P, P, P]),
      select: f("juno_pm_select", P, [P, P]),
      mouse: f("juno_pm_mouse", P, [P, P, P, P, P]),
      bankMouse: f("juno_pm_bank_mouse", P, [P, P, P, P, P, P]),
      drag: f("juno_pm_drag", null, [P, P, P]),
      viewValues: f("juno_pm_view_values", null, [P, P, P, P]),
      nbanks: f("juno_pm_nbanks", P, [P]),
      curBank: f("juno_pm_cur_bank", P, [P]),
      cur: f("juno_pm_cur", P, [P, P]),
      sel: f("juno_pm_sel", P, [P]),
      value: f("juno_pm_value", P, [P, P]),
      setValue: f("juno_pm_set_value", null, [P, P, P]),
      bankName: f("juno_pm_bank_name", P, [P, P]),
      patchName: f("juno_pm_patch_name", P, [P, P, P, P]),
      number: f("juno_pm_number", P, [P, P, P]),
      format: f("juno_pm_format", P, []),
      loadFormat: f("juno_pm_load_format", null, [P]),
      body: f("juno_pm_body", P, [P, P, P]),
      hist: f("juno_pm_hist", P, [P, P, P]),
      clip: f("juno_pm_clip", P, [P]),
      stateInfo: f("juno_pm_state_info", P, [P, P, P, P, P, P]),
      stateRec: f("juno_pm_state_rec", P, [P, P, P, P]),
    };
    this.scratch = M._malloc(64);
    this.text = M._malloc(1024);
    const cb = (fn, sig) => M.addFunction(fn, sig);
    const cs = p => this.cstr(p);
    const fns = [
      0,                                                         // u
      cb((u, path, lenp) => {                                    // read
        const d = io.read(cs(path));
        if (!d) return 0;
        const p = M._malloc(d.length + 1);
        M.HEAPU8.set(d, p);
        M.HEAP32[lenp >> 2] = d.length;
        return p;
      }, "iiii"),
      cb((u, path, data, n) => (io.write(cs(path), M.HEAPU8.slice(data, data + n)) ? 1 : 0), "iiiii"),
      cb((u, path) => (io.remove(cs(path)) ? 1 : 0), "iii"),
      cb((u, a, b) => (io.move(cs(a), cs(b)) ? 1 : 0), "iiii"),
      cb((u, path) => (io.exists(cs(path)) ? 1 : 0), "iii"),
      cb((u, dir, np) => {                                       // list
        const names = io.list(cs(dir));
        M.HEAP32[np >> 2] = 0;
        if (!names) return 0;
        const arr = M._malloc(4 * Math.max(1, names.length));
        names.forEach((nm, k) => { M.HEAP32[(arr >> 2) + k] = this.allocStr(nm); });
        M.HEAP32[np >> 2] = names.length;
        return arr;
      }, "iiii"),
      cb((u, what, offered, out, cap) => {                       // text
        const t = io.text(what, cs(offered));
        if (t === null || t === undefined) return 0;
        this.writeStr(t, out, cap);
        return 1;
      }, "iiiiii"),
      cb((u, items, checked, n) => {                             // menu
        const it = [], ck = [];
        for (let k = 0; k < n; k++) {
          it.push(cs(M.HEAP32[(items >> 2) + k]));
          ck.push(M.HEAP32[(checked >> 2) + k] !== 0);
        }
        const r = io.menu(it, ck);
        return r === null || r === undefined || r < 0 || r >= n ? -1 : r | 0;
      }, "iiiii"),
      cb((u, msg) => (io.confirm(msg) ? 1 : 0), "iii"),
      cb((u, title, ext, pathsp, np) => {                        // open_files
        const ps = io.openFiles(cs(title), cs(ext));
        if (!ps || !ps.length) return 0;
        const arr = M._malloc(4 * ps.length);
        ps.forEach((x, k) => { M.HEAP32[(arr >> 2) + k] = this.allocStr(x); });
        M.HEAP32[pathsp >> 2] = arr;
        M.HEAP32[np >> 2] = ps.length;
        return 1;
      }, "iiiiii"),
      cb((u, title, sug, out, cap) => {                          // save_file
        const t = io.saveFile(cs(title), cs(sug));
        if (t === null || t === undefined) return 0;
        this.writeStr(t, out, cap);
        return 1;
      }, "iiiiii"),
      cb((u, out, cap) => E.fn.record(E.ctx, out, cap), "iiii"), // record (rva 0x335990)
      cb((u, body, n) => {                                       // load (rva 0x335850)
        if (io.onCall) io.onCall("load", M.HEAPU8.slice(body, body + n));
        E.fn.queueRecord(E.ctx, body, n);
        return 1;
      }, "iiii"),
      cb((u, op, id, v, flag) => {                               // model: get, set, notify, commit
        id >>>= 0;
        if (op === 0) return E.fn.modelGet(E.ctx, id);
        if (op === 1) {
          if (io.onCall) io.onCall("set", id, v, flag);
          return E.fn.modelSet(E.ctx, id, v);
        }
        if (op === 2) { if (io.onCall) io.onCall("notify"); return 0; }
        if (io.onCall) io.onCall("commit");
        E.fn.commit(E.ctx);
        return 0;
      }, "iiiiii"),
    ];
    const iop = M._malloc(4 * fns.length);
    M.HEAP32.set(fns, iop >> 2);
    const d = dirs || {};
    const a = [d.data, d.patch, d.old, d.script].map(x => this.allocStr(x || ""));
    this.pm = this.fn.create(E.ctx, iop, a[0], a[1], a[2], a[3]);
    a.forEach(p => M._free(p));
    M._free(iop);
    if (!this.pm) throw new Error("patch manager alloc failed");
  }

  // strings as bytes (Latin-1): the plugin's names and paths are its ANSI code page's
  cstr(p) {
    if (!p) return null;
    const H = this.M.HEAPU8;
    let e = p;
    while (H[e]) e++;
    let s = "";
    for (let k = p; k < e; k++) s += String.fromCharCode(H[k]);
    return s;
  }
  allocStr(s) {
    const p = this.M._malloc(s.length + 1);
    this.writeStr(s, p, s.length + 1);
    return p;
  }
  writeStr(s, p, cap) {
    const H = this.M.HEAPU8;
    const n = Math.min(s.length, cap - 1);
    for (let k = 0; k < n; k++) { const c = s.charCodeAt(k); H[p + k] = c < 256 ? c : 0x3f; }
    H[p + n] = 0;
  }
  bytes(p, n) { return p ? this.M.HEAPU8.slice(p, p + n) : null; }

  attach() { return this.fn.attach(this.pm); }
  initialize() { this.fn.initialize(this.pm); }
  detach() { this.fn.detach(this.pm); }
  tick() { this.fn.tick(this.pm); }
  saveAll() { return this.fn.saveAll(this.pm); }
  pref() { return this.cstr(this.fn.pref(this.pm)); }
  setPref(name) {
    if (name === null || name === undefined) { this.fn.setPref(this.pm, 0); return; }
    const p = this.allocStr(name);
    this.fn.setPref(this.pm, p);
    this.M._free(p);
  }
  loadFormat(text) {
    if (text === null || text === undefined) { this.fn.loadFormat(0); return; }
    const p = this.allocStr(text);
    this.fn.loadFormat(p);
    this.M._free(p);
  }
  format() { return this.fn.format(); }
  // the list's key (rva 0x3278C0): {handled, close}
  key(code, flags) {
    const r = this.fn.key(this.pm, code, flags, this.scratch);
    return { handled: r !== 0, close: this.M.HEAP32[this.scratch >> 2] !== 0 };
  }
  func(fn, args) {
    const a = this.allocStr(fn), b = this.allocStr(args);
    const r = this.fn.func(this.pm, a, b);
    this.M._free(a); this.M._free(b);
    return r;
  }
  select(i) { return this.fn.select(this.pm, i); }
  mouse(type, x, y, rect) {
    this.M.HEAP32.set(rect, this.scratch >> 2);
    return this.fn.mouse(this.pm, type, x, y, this.scratch);
  }
  bankMouse(type, x, y, rect, button) {
    this.M.HEAP32.set(rect, this.scratch >> 2);
    if (button) this.M.HEAP32.set(button, (this.scratch >> 2) + 4);
    return this.fn.bankMouse(this.pm, type, x, y, this.scratch, button ? this.scratch + 16 : 0);
  }
  drag() {
    this.fn.drag(this.pm, this.scratch, this.scratch + 4);
    return [this.M.HEAP32[this.scratch >> 2], this.M.HEAP32[(this.scratch >> 2) + 1]];
  }
  viewValues() {
    this.fn.viewValues(this.pm, this.scratch, this.scratch + 4, this.scratch + 8);
    const H = this.M.HEAP32, k = this.scratch >> 2;
    return [H[k], H[k + 1], H[k + 2]];
  }
  nbanks() { return this.fn.nbanks(this.pm); }
  curBank() { return this.fn.curBank(this.pm); }
  cur(sub) { return this.fn.cur(this.pm, sub ? 1 : 0); }
  sel() { return this.fn.sel(this.pm); }
  value(id) { return this.fn.value(this.pm, id >>> 0); }
  setValue(id, v) { this.fn.setValue(this.pm, id >>> 0, v | 0); }
  bankName(b) { return this.cstr(this.fn.bankName(this.pm, b)); }
  patchName(b, i) { return this.fn.patchName(this.pm, b, i, this.text) ? this.cstr(this.text) : null; }
  number(i) { return this.fn.number(i, this.text, 64) > 0 ? this.cstr(this.text) : ""; }
  body(b, i) { return this.bytes(this.fn.body(this.pm, b, i), 20207); }
  hist(b) {
    const n = this.fn.hist(this.pm, b, this.scratch);
    return [n, this.M.HEAP32[this.scratch >> 2]];
  }
  clip() { return this.bytes(this.fn.clip(this.pm), 20207); }
  stateInfo(b, i) {
    if (!this.fn.stateInfo(this.pm, b, i, this.scratch, this.scratch + 4, this.scratch + 8)) return null;
    const H = this.M.HEAP32, k = this.scratch >> 2;
    return { name: this.cstr(H[k]), view: H[k + 1], edit: this.bytes(H[k + 2], 20207) };
  }
  stateRec(b, i, k) { return this.bytes(this.fn.stateRec(this.pm, b, i, k), 20207); }
  // the view's record image (the serializer, rva 0x335990)
  record() {
    const p = this.M._malloc(20207);
    const n = this.E.fn.record(this.E.ctx, p, 20207);
    const r = this.M.HEAPU8.slice(p, p + Math.max(n, 0));
    this.M._free(p);
    return r;
  }
}
