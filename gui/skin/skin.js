// skin.js -- the JUNO-60 plugin's own GUI, drawn from its Script.xml and the
// sprite sheets of its Script folder, playing the C99 port through engine.js.
//
// SOURCE OF EVERY FACT (no hand-placed control):
//   Script.xml (truth/, byte-identical to the plugin's Script folder):
//     positions, sizes, sprite sheets, frame counts and directions, value refs,
//     value ranges and defaults, string and number tables, text writers, panel
//     open conditions (postfix), the keyboard's key rectangles and offsets.
//   The value-tree walk gives each control its parameter id (Roland 7-bit
//   addresses); tools/verify/skin_census.py checks it against the 95 ids the
//   port took from the running plugin.
//   READ from the plugin's code, where a control writes values the XML does not
//   state: the CHORUS buttons and LEDs (rva 0x351410 / 0x3515B0), the keyboard's
//   click velocity and octave shift (rva 0x2D4AA0 / 0x2D4C40).
// NOT YET PORTED (drawn idle): the LFO-rate LED and the output bar graphs (the
//   plugin pushes them from its audio side: vm.vs.dm, extraId), MIDI CC assign,
//   the SYSTEM-8 transfer buttons, writing a patch back into a bank.

import { WasmEngine } from "./engine.js";

const Q = new URLSearchParams(location.search);
const XML_URL = Q.get("xml") || "../../truth/Script.xml";
const IMG_BASE = Q.get("skin") || "../../truth/Script/";
const BANK_URL = Q.get("bank") || "../../truth/presetbankog1.bin";
const HEADER = 23, STRIDE = 20223, NAME = 16;

// ------------------------------------------------------------------ XML helpers
const kids = (e, tag) => Array.from(e.children).filter(c => c.tagName === tag);
const text = (e, tag) => {
  for (const c of e.children) if (c.tagName === tag) return c.textContent.trim();
  return null;
};
const texts = (e, tag) => kids(e, tag).map(c => c.textContent.trim());
const ints = s => s.split(",").map(x => parseInt(x.trim(), 10));
const tableItems = s => {
  const a = s.split(",").map(x => x.trim());
  if (a.length && a[a.length - 1] === "") a.pop();
  return a;
};

// ----------------------------------------------------------- the value tree
// Leaf widths in address units; an untyped leaf (vm.vs) is one unit.
const WIDTH = { int1x7: 1, int2x4: 2, int3x4: 3, int4x4: 4, int8x4: 8 };
const add7 = (base, off) => {          // Roland 7-bit address add, off right-aligned
  const b = base.slice(), o = [0, 0, 0, 0].concat(off).slice(-4);
  let carry = 0;
  for (let i = 3; i >= 0; i--) {
    const s = b[i] + o[i] + carry;
    b[i] = s & 0x7f;
    carry = s >> 7;
  }
  return b;
};
const pid = a => ((a[0] << 21) | (a[1] << 14) | (a[2] << 7) | a[3]) >>> 0;
const unpid = id => [(id >>> 21) & 0x7f, (id >>> 14) & 0x7f, (id >>> 7) & 0x7f, id & 0x7f];
const hexAddr = s => s.split(/\s+/).map(h => parseInt(h, 16));

export function walkTree(root) {
  const st = new Map();
  for (const e of kids(root, "structType")) st.set(text(e, "type"), e);
  const leaves = new Map();
  const walk = (type, base, path) => {
    const d = st.get(type);
    if (!d) return;
    let off = 0;
    for (const c of d.children) {
      if (c.tagName === "value") {
        const t = text(c, "type") || "int1x7";
        const nm = text(c, "name"), a0 = text(c, "address");
        const a = add7(base, a0 ? hexAddr(a0) : [0, 0, off >> 7, off & 0x7f]);
        const key = path + "." + nm;
        if (!leaves.has(key)) {
          const r = text(c, "range");
          const [min, max] = r ? ints(r) : [0, 0];
          leaves.set(key, { name: key, id: pid(a), type: t, w: WIDTH[t] || 0, min, max,
                            def: parseInt(text(c, "default") || "0", 10) });
        }
        if (!a0) off += WIDTH[t] || 0;
      } else if (c.tagName === "struct") {
        const ct = text(c, "type");
        const tn = st.has(ct) ? text(st.get(ct), "name") : null;
        const cn = text(c, "name") || (tn && tn !== "$name" ? tn : ct);
        walk(ct, add7(base, hexAddr(text(c, "address"))), path + "." + cn);
      }
    }
  };
  for (const e of kids(root, "struct")) walk(text(e, "type"), hexAddr(text(e, "address")), text(e, "name"));
  return leaves;
}

// --------------------------------------------------------------- the script
class Script {
  constructor(doc) {
    const r = doc.documentElement;
    this.leaves = walkTree(r);
    this.bitmaps = new Map();
    for (const b of kids(r, "bitmap")) {
      this.bitmaps.set(text(b, "name"), {
        n: parseInt(text(b, "stateCount") || "1", 10),
        dir: parseInt(text(b, "direction") || "0", 10),   // 1: frames side by side
        img: null,
      });
    }
    this.writers = new Map();
    for (const w of kids(r, "textWriter")) {
      const col = s => {
        if (!s) return null;
        const v = s.split(",").filter(x => x.trim() !== "").map(x => parseInt(x, 16));
        return v.length > 3 ? `rgba(${v[0]},${v[1]},${v[2]},${(v[3] / 255).toFixed(3)})` : `rgb(${v[0]},${v[1]},${v[2]})`;
      };
      const face = text(w, "fontFaceName");
      this.writers.set(text(w, "name"), {
        face: !face || face === "DEFAULT" ? "sans-serif" : `${face}, "Liberation Sans", Helvetica, sans-serif`,
        size: parseInt(text(w, "fontHeight") || "14", 10),
        color: col(text(w, "fontColor")) || "#c0c0c0",
        back: col(text(w, "backColor")),
        alignH: text(w, "alignH") || "left",
        alignV: text(w, "alignV") || "top",
      });
    }
    this.strings = new Map();
    for (const t of r.getElementsByTagName("stringTable")) this.strings.set(text(t, "name"), tableItems(text(t, "table") || ""));
    this.numbers = new Map();
    for (const t of r.getElementsByTagName("numberTable"))
      this.numbers.set(text(t, "name"), (text(t, "table") || "").split(",").map(g => g.split("|").map(x => parseInt(x, 10))));
    this.panels = new Map();
    for (const p of kids(r, "panelType")) this.panels.set(text(p, "type"), p);
  }

  // a value ref -> its leaf; "x[i]" is element i of the leaf array x
  resolve(ref) {
    const m = /^(.*)\[(\d+)\]$/.exec(ref);
    if (m) {
      const L = this.leaves.get(m[1]);
      if (!L) return null;
      const i = +m[2];
      return { ...L, name: ref, id: pid(add7(unpid(L.id), [0, 0, (i * L.w) >> 7, (i * L.w) & 0x7f])) };
    }
    return this.leaves.get(ref) || null;
  }
}

// postfix condition: operands are integers or value refs
const OPS = {
  "==": (a, b) => a === b, "!=": (a, b) => a !== b, "<": (a, b) => a < b, "<=": (a, b) => a <= b,
  ">": (a, b) => a > b, ">=": (a, b) => a >= b, "&&": (a, b) => a && b, "||": (a, b) => a || b,
};
function evalCond(expr, get) {
  const s = [];
  for (const tok of expr.split(",").map(x => x.trim())) {
    if (tok in OPS) {
      const b = s.pop(), a = s.pop();
      s.push(OPS[tok](a, b));
    } else if (/^-?\d+$/.test(tok)) s.push(parseInt(tok, 10));
    else s.push(get(tok));
  }
  return !!s.pop();
}

// ------------------------------------------------------------------- model
// The engine keeps the plugin's parameter list (getState); ids outside it
// (the view model vm.*, the internal TEMPO) live here, at their defaults.
class Model {
  constructor(script, engine, onSet) {
    this.S = script;
    this.E = engine;
    this.onSet = onSet;
    this.eng = new Map();
    this.local = new Map();
    this.version = 0;
  }
  refresh() {
    const v = this.E.values();
    let changed = v.size !== this.eng.size;
    if (!changed) for (const [k, x] of v) if (this.eng.get(k) !== x) { changed = true; break; }
    if (changed) { this.eng = v; this.version++; }
    return changed;
  }
  leaf(ref) { return this.S.resolve(ref); }
  get(ref) {
    const L = this.leaf(ref);
    if (!L) return 0;
    if (this.eng.has(L.id)) return this.eng.get(L.id);
    if (this.local.has(L.id)) return this.local.get(L.id);
    return L.def;
  }
  // a panel control's edit: the model set (rva 0x283DB0), then the commit every
  // control makes after it (rva 0x2DD100); setBare: the set alone (the patch
  // browser's own set of the patch number, rva 0x338090)
  set(ref, v) { this.setBare(ref, v); this.E.commit(); }
  setBare(ref, v) {
    const L = this.leaf(ref);
    if (!L) return;
    if (L.max > L.min) v = Math.max(L.min, Math.min(L.max, v));
    if (this.E.set(L.id, v)) this.refresh();
    else {
      this.local.set(L.id, v);
      this.version++;
    }
    this.onSet(L, v);
  }
}

// ------------------------------------------------------------ sprite helpers
function frameSize(bm) {
  const im = bm.img;
  return bm.dir === 1 ? [im.width / bm.n, im.height] : [im.width, im.height / bm.n];
}
function drawFrame(g, bm, f, x, y) {
  if (!bm || !bm.img) return;
  const [w, h] = frameSize(bm);
  f = Math.max(0, Math.min(bm.n - 1, f | 0));
  const sx = bm.dir === 1 ? f * w : 0, sy = bm.dir === 1 ? 0 : f * h;
  g.drawImage(bm.img, sx, sy, w, h, x, y, w, h);
}
function drawText(g, wr, s, x, y, w, h) {
  if (!wr) return;
  if (wr.back) { g.fillStyle = wr.back; g.fillRect(x, y, w, h); }
  g.font = `${wr.size}px ${wr.face}`;
  g.fillStyle = wr.color;
  g.textAlign = wr.alignH === "center" ? "center" : wr.alignH === "right" ? "right" : "left";
  g.textBaseline = wr.alignV === "center" ? "middle" : "top";
  const tx = wr.alignH === "center" ? x + w / 2 : wr.alignH === "right" ? x + w : x;
  const ty = wr.alignV === "center" ? y + h / 2 : y;
  g.save();
  g.beginPath(); g.rect(x, y, w, h); g.clip();
  g.fillText(s, tx, ty);
  g.restore();
}

// ------------------------------------------------------------------- the GUI
class Skin {
  constructor(S, E, canvas, status) {
    this.S = S;
    this.E = E;
    this.cv = canvas;
    this.g = canvas.getContext("2d");
    this.status = status;
    this.M = new Model(S, E, (L, v) => this.changed(L, v));
    this.pressed = new Set();     // controls held down by the mouse
    this.kb = { drag: false, key: -1 };   // the keyboard control's drag flag (+48) and held key (+240)
    this.kbStates = new Int32Array(128);  // its note value as last drawn
    this.drag = null;
    this.tip = null;
    this.banks = [];              // [{name, bytes}]
    this.bank = 0;
    this.patch = 0;
    this.patchSel = 0;
    this.noteFlash = 0;
    this.dirty = true;
    this.tree = this.build("main", 0, 0);
    this.patchTree = this.build("patch", 117, 22);   // its own window, over the panel
  }

  // panel tree -> [{panel...}] with absolute positions
  build(type, ox, oy) {
    const p = this.S.panels.get(type);
    const pos = text(p, "position");
    const [px, py] = pos ? ints(pos) : [0, 0];
    const size = text(p, "size");
    const node = {
      kind: "panel", type, x: ox + px, y: oy + py,
      size: size ? ints(size) : null, cond: text(p, "openCondition"),
      bmp: text(p, "bitmapRef"), items: [],
    };
    if (type === "main") { node.x = ox; node.y = oy; }
    for (const c of p.children) {
      if (c.tagName === "panel") node.items.push(this.build(text(c, "type"), node.x, node.y));
      else if (c.tagName === "control") node.items.push(this.control(c, node.x, node.y));
    }
    return node;
  }

  control(el, ox, oy) {
    const pos = text(el, "position");
    const [x, y] = pos ? ints(pos) : [0, 0];
    const c = { kind: "control", type: text(el, "type"), el, x: ox + x, y: oy + y, ox, oy };
    const size = text(el, "size");
    if (size) [c.w, c.h] = ints(size);
    c.refs = texts(el, "valueRef");
    c.ref = c.refs[0] || null;
    c.bmpName = text(el, "bitmapRef");
    c.bmp = c.bmpName ? this.S.bitmaps.get(c.bmpName) : null;
    const pic = text(el, "pictorialBitmapRef");
    if (pic) {
      const [nm, list] = pic.split("//");
      c.pic = this.S.bitmaps.get(nm);
      c.picList = list ? ints(list) : null;
    }
    c.table = text(el, "stringTableRef");
    c.writers = texts(el, "textWriterRef").map(n => this.S.writers.get(n));
    for (const k of ["onValue", "offValue", "offsetValue", "role"]) {
      const v = text(el, k);
      if (v !== null && v !== "") c[k] = parseInt(v, 10);
    }
    const bsr = text(el, "bitmapStateRange");
    if (bsr) c.stateRange = ints(bsr);
    c.clickable = text(el, "clickable") === "1";
    c.fn = text(el, "function");
    c.args = text(el, "arguments");
    const p2 = text(el, "position2");
    if (p2) { const [a, b] = ints(p2); c.x2 = ox + a; c.y2 = oy + b; }
    const tbp = text(el, "tipBarPosition");
    c.tipAt = tbp ? ints(tbp) : null;
    if (c.type === "keyboardX") this.keyboardInit(c);
    if (c.type === "lfoLed") c.frame = 0;
    if (c.type === "barGraphX") {        // CBarGraphControl: its object zeroed (rva 0x34FA60), then Script.xml
      const num = k => parseInt(text(el, k) || "0", 10);
      c.horiz = num("direction") !== 0 ? 1 : 0;
      c.decay = num("decay");
      c.ch = num("ch");
      c.fade = num("fade");
      c.state = 0;
      c.rect = [c.x, c.y, c.x + c.w, c.y + c.h];
      c.blits = [];
    }
    if (c.type === "patchName") {
      const [bx, by] = ints(text(el, "buttonPosition"));
      const [tx, ty] = ints(text(el, "textPosition"));
      const [tw, th] = ints(text(el, "textSize"));
      Object.assign(c, { bx: c.x + bx, by: c.y + by, tx: c.x + tx, ty: c.y + ty, tw, th });
    }
    return c;
  }

  // ------------------------------------------------------------ visibility
  open(node) {
    if (!node.cond) return true;
    return evalCond(node.cond, ref => this.M.get(ref));
  }
  // visible controls in draw order
  visible(node, out = []) {
    if (node.kind === "control") { out.push(node); return out; }
    if (!this.open(node)) return out;
    for (const it of node.items) this.visible(it, out);
    return out;
  }

  // -------------------------------------------------------------- values
  leaf(c) { return c.ref ? this.M.leaf(c.ref) : null; }
  val(c) { return c.ref ? this.M.get(c.ref) : 0; }
  norm(c) {
    const L = this.leaf(c);
    if (!L || L.max === L.min) return 0;
    return (this.val(c) - L.min) / (L.max - L.min);
  }
  // selector position <-> value through the number table of the same name
  position(c) {
    const v = this.val(c), nt = c.table && this.S.numbers.get(c.table);
    if (nt) { const i = nt.findIndex(g => g.includes(v)); return i < 0 ? 0 : i; }
    const L = this.leaf(c);
    return L ? v - L.min : v;
  }
  valueAt(c, pos) {
    const nt = c.table && this.S.numbers.get(c.table);
    if (nt) return nt[Math.max(0, Math.min(nt.length - 1, pos))][0];
    const L = this.leaf(c);
    return (L ? L.min : 0) + pos;
  }
  label(c) {
    const L = this.leaf(c);
    if (!L) return "";
    const v = this.val(c);
    const t = c.table && this.S.strings.get(c.table);
    if (t && t.length) return t[Math.max(0, Math.min(t.length - 1, v - L.min))];
    const s = v + (c.offsetValue || 0);
    const unit = text(c.el, "unit");
    return String(s) + (unit ? " " + unit : "");
  }

  changed(L, v) {
    if (L.name === "fm.SYNTH.COM.TEMPO") this.E.setTempo(40 + v / 10);   // "40.0BPM" + 0.1 per step
    if (L.name === "vm.vs.mainZoom") this.applyZoom();
    if (L.name === "fm.PATCH.CTRL.TEMPO SYNC") this.noteFlash = performance.now();
    this.dirty = true;
  }

  // the LED's and the meters' ticks of the plugin's 50 ms window timer (WM_TIMER -> each
  // open control's slot +96): the LED of the open LFO panel, both meters; true if one changed
  meterTick() {
    let moved = false;
    for (const c of this.visible(this.tree)) {
      if (c.type === "lfoLed" && c.pic) {
        const f = this.E.ledFrame(c.pic.n);
        if (f !== c.frame) { c.frame = f; moved = true; }
      } else if (c.type === "barGraphX") {
        const r = this.E.meterTick(c.ch, c.decay, c.state, c.rect, c.horiz);
        c.state = r.state;
        const b = this.E.barDraw(c.rect, r.fill, c.horiz, c.fade);
        if (JSON.stringify(b) !== JSON.stringify(c.blits)) { c.blits = b; moved = true; }
      }
    }
    return moved;
  }

  // ---------------------------------------------------------------- draw
  draw() {
    const g = this.g;
    g.clearRect(0, 0, this.cv.width, this.cv.height);
    this.drawPanel(this.tree);
    if (this.M.get("vm.vs.panelPatch") === 1) this.drawPatchWindow();
    if (this.tip) this.drawTip();
  }
  drawPanel(node) {
    if (!this.open(node)) return;
    const g = this.g;
    if (node.bmp) {
      const bm = this.S.bitmaps.get(node.bmp);
      if (bm && bm.img) g.drawImage(bm.img, node.x, node.y);
    }
    for (const it of node.items) {
      if (it.kind === "panel") this.drawPanel(it);
      else this.drawControl(it);
    }
  }

  drawControl(c) {
    const g = this.g, held = this.pressed.has(c);
    switch (c.type) {
      case "slider": {
        if (!c.bmp || !c.bmp.img) return;
        const [cw, ch] = frameSize(c.bmp);
        const travel = c.h - ch;
        drawFrame(g, c.bmp, 0, c.x + (c.w - cw) / 2, Math.round(c.y + travel * (1 - this.norm(c))));
        return;
      }
      case "knob": {
        if (!c.bmp || !c.bmp.img) return;
        if (c.bmp.n <= 4) { drawFrame(g, c.bmp, this.position(c), c.x, c.y); return; }   // a lever
        const [s0, s1] = c.stateRange || [0, c.bmp.n - 1];
        drawFrame(g, c.bmp, s0 + Math.round(this.norm(c) * (s1 - s0)), c.x, c.y);
        return;
      }
      case "display": {
        if (c.pic) {
          const v = this.val(c);
          let f;
          if (c.pic === this.S.bitmaps.get("displayNote.png")) {
            const t = text(c.el, "timeout");
            f = v && performance.now() - this.noteFlash < (t ? +t : 0) ? 1 : 0;
            if (f) this.dirty = true;
          } else f = c.picList ? (c.picList[v] || 0) : v;
          drawFrame(g, c.pic, f, c.x, c.y);
        } else if (c.writers[0]) drawText(g, c.writers[0], this.label(c), c.x, c.y, c.w, c.h);
        return;
      }
      case "latchButton": {
        const on = c.onValue !== undefined ? this.val(c) === c.onValue : this.val(c) !== 0;
        drawFrame(g, c.bmp, (on ? 2 : 0) + (held ? 1 : 0), c.x, c.y);
        return;
      }
      case "unlatchButton":
      case "menuButton":
      case "setupButton":
        if (c.fn === "PlugOut") return;            // the SYSTEM-8 PLUG-OUT: not part of this port
        drawFrame(g, c.bmp, held ? 1 : 0, c.x, c.y);
        if (c.type === "setupButton" && c.writers[0]) {
          const [w, h] = frameSize(c.bmp);
          drawText(g, c.writers[0], (c.args || "").split(",").slice(1).join(","), c.x, c.y, w, h);
        }
        return;
      case "ju60UnlatchButton":
        drawFrame(g, c.bmp, held ? 1 : 0, c.x, c.y);
        return;
      case "ju60Led":
        drawFrame(g, c.pic, this.chorusLed(c) ? 1 : 0, c.x, c.y);
        return;
      case "lfoLed":
        drawFrame(g, c.pic, c.frame, c.x, c.y);    // the frame of its last tick (rva 0x325070)
        return;
      case "barGraphX": {                          // its blits (rva 0x31C210), from its last tick
        if (!c.bmp || !c.bmp.img) return;
        for (const [dx, dy, w, h, sx, sy, a] of c.blits) {
          if (w <= 0 || h <= 0) continue;
          g.globalAlpha = a < 0 ? 1 : a / 255;
          g.drawImage(c.bmp.img, sx, sy, w, h, dx, dy, w, h);
        }
        g.globalAlpha = 1;
        return;
      }
      case "patchName": {
        drawFrame(g, c.bmp, held ? 1 : 0, c.bx, c.by);
        drawText(g, c.writers[0], this.patchNameText(), c.tx, c.ty, c.tw, c.th);
        return;
      }
      case "keyboardX":
        this.keyboardDraw(c);
        return;
      default:
        return;                                    // ccAssign, auth*: not drawn
    }
  }

  patchNameText() {
    let s = "";
    for (let i = 0; i < 8; i++) {
      const w = this.M.get(`fm.PATCH.NAME0.name[${i}]`) & 0xffff;
      s += String.fromCharCode((w >> 8) & 0xff || 32, w & 0xff || 32);
    }
    return s.replace(/\s+$/, "");
  }

  // the CHORUS LEDs (rva 0x3515B0): I lit for TYPE 2 or 4, II for 3 or 4, DEPTH > 0
  chorusLed(c) {
    const t = this.M.get("fm.PATCH.NAME3.EFFECT TYPE"), d = this.M.get("fm.PATCH.EFX.EFFECT DEPTH");
    if (c.role === 1) return (t === 2 || t === 4) && d > 0;
    if (c.role === 2) return (t === 3 || t === 4) && d > 0;
    return false;
  }

  // the CHORUS buttons (rva 0x351410): OFF sets DEPTH 0 when a JUNO chorus is in
  // force; I / II set TYPE 2 / 3 (4 with the other one held), DEPTH 255, TONE 128
  chorusPress(c, both) {
    const T = "fm.PATCH.NAME3.EFFECT TYPE", D = "fm.PATCH.EFX.EFFECT DEPTH", N = "fm.PATCH.NAME3.EFFECT TONE";
    if (c.role === 0) {
      const t = this.M.get(T);
      if (t >= 2 && t <= 4) this.M.set(D, 0);
      return;
    }
    this.M.set(T, both ? 4 : c.role === 1 ? 2 : 3);
    this.M.set(D, 255);
    this.M.set(N, 128);
  }

  drawTip() {
    const g = this.g, t = this.tip;
    g.font = "18px Arial, 'Liberation Sans', sans-serif";
    const w = g.measureText(t.s).width + 16, h = 26;
    const x = Math.round(t.x - w / 2), y = Math.round(t.y - h - 4);
    g.fillStyle = "rgba(0,0,0,0.82)";
    g.fillRect(x, y, w, h);
    g.fillStyle = "#f0f0f0";
    g.textAlign = "center";
    g.textBaseline = "middle";
    g.fillText(t.s, x + w / 2, y + h / 2);
  }

  // ------------------------------------------------------------ keyboard
  // the plugin's layout (rva 0x2D45E0): keyRange low..high (the parser keeps high + 1);
  // the white keys -- the first and the last key always, else C D E F G A B -- one width /
  // their count apart; the first key draws chromaticRect 12, the last 13; a black key sits
  // at the right edge of the key before it, plus its chromaticOffset, less half its width
  keyboardInit(c) {
    const kr = ints(text(c.el, "keyRange"));
    const rects = {};
    for (const s of texts(c.el, "chromaticRect")) {
      const [k, state, x0, y0, x1, y1] = ints(s);
      (rects[k] = rects[k] || [])[state] = [x0, y0, x1 - x0, y1 - y0];
    }
    const offs = {};
    for (const s of texts(c.el, "chromaticOffset")) { const [k, o] = ints(s); offs[k] = o; }
    const lo = kr[0], hi = kr[1] + 1;
    let white = 0;
    for (let n = lo; n < hi; n++) {
      const pc = n % 12;
      white += (n === lo || n === hi - 1) ? 1 : (pc > 4 ? pc % 2 === 1 : (pc & 1) === 0) ? 1 : 0;
    }
    const step = Math.trunc(c.w / white);
    const keys = [];
    let acc = 0;
    for (let n = lo; n < hi; n++) {
      const shape = n === lo ? 12 : n === hi - 1 ? 13 : n % 12;
      const isWhite = shape > 11 ? true : shape > 4 ? (shape & 1) === 1 : (shape & 1) === 0;
      const [, , w, h] = rects[shape][0];
      let x;
      if (isWhite) { x = c.x + acc; acc += step; }
      else { const p = keys[keys.length - 1]; x = p.x + p.w + (offs[shape] || 0) - Math.trunc(w / 2); }
      keys.push({ n, black: !isWhite, shape, x, y: c.y, w, h });
    }
    c.keys = keys;
    c.rects = rects;
  }
  // key i down when the note value's state of i + 12 x OCTAVE SHIFT is above 0 (rva 0x2D3E20)
  keyboardDraw(c) {
    const g = this.g, bm = c.bmp;
    if (!bm || !bm.img) return;
    const shift = this.M.get("fm.PATCH.NAME1.OCTAVE SHIFT");
    for (let i = 0; i < 128; i++) this.kbStates[i] = this.E.keybedState(i);
    for (const k of c.keys) {
      const n = k.n + 12 * shift;
      const down = n >= 0 && n <= 127 && this.kbStates[n] > 0;
      const [sx, sy, w, h] = c.rects[k.shape][down ? 1 : 0];
      g.drawImage(bm.img, sx, sy, w, h, k.x, k.y, w, h);
    }
    if (shift && c.writers[0]) drawText(g, c.writers[0], "OCTAVE " + (shift > 0 ? "+" : "") + shift, c.x + 4, c.y + 4, 150, 26);
  }
  // the key at a point and the velocity there (rva 0x2D4AA0): the point clamped into the
  // control; from the lowest key: a next key overlapping this one's right edge (a black key)
  // if the point is in it, else this key if the point is left of its right edge, else on
  // (past a black key that missed); velocity 1016 x (y - top) / height / 7 in 1..127
  keyHit(c, px, py) {
    const x = Math.max(c.x, Math.min(c.x + c.w - 1, px)), y = Math.max(c.y, Math.min(c.y + c.h - 1, py));
    let i = 0, k = c.keys[0];
    while (i < c.keys.length - 1) {
      const cur = c.keys[i], nx = c.keys[i + 1];
      let missed = false;
      k = cur;
      if (nx.x < cur.x + cur.w) {
        if (nx.x <= x && nx.y <= y && x < nx.x + nx.w && y < nx.y + nx.h) { k = nx; break; }
        missed = true;
      }
      if (x < cur.x + cur.w) break;
      i += missed ? 2 : 1;
      k = c.keys[Math.min(i, c.keys.length - 1)];
    }
    return { n: k.n, vel: this.keyVelocity(k, y) };
  }
  keyVelocity(k, y) {
    const v = Math.trunc(Math.trunc(1016 * (y - k.y) / k.h) / 7);
    return v < 1 ? 1 : v > 127 ? 127 : v;
  }
  kbNote(n) { return n + 12 * this.M.get("fm.PATCH.NAME1.OCTAVE SHIFT"); }
  // the send (rva 0x2D47E0): a press at vm.ks.onVel when set (0), a release at
  // -vm.ks.offVel (64): the Script.xml defaults, no control of this panel changes them
  kbSend(key, v) {
    const r = v <= 0 ? -64 : 0;
    this.E.keybedWrite(key, r ? r : v);
    this.dirty = true;
  }
  // a press (rva 0x2D4920): a note in the shifted key range other than the held key; with
  // KEY HOLD off, or without Shift, every key above 0 is released first; then the note
  kbPress(c, note, vel, shift) {
    if (note < 0 || note > 127 || note < this.kbNote(c.keys[0].n) || note >= this.kbNote(c.keys[c.keys.length - 1].n + 1) ||
        this.kb.key === note) return;
    this.E.start();
    if (!this.M.get("fm.PATCH.NAME1.KEY HOLD") || !shift)
      for (let i = 0; i < 128; i++) if (this.E.keybedState(i) > 0) this.kbSend(i, -vel);
    this.kbSend(note, vel);
    this.kb.key = note;
  }
  // the release (rva 0x2D48A0): the held key unless KEY HOLD is on
  kbRelease(vel) {
    if (this.kb.key >= 0 && !this.M.get("fm.PATCH.NAME1.KEY HOLD")) this.kbSend(this.kb.key, -vel);
    this.kb.key = -1;
  }


  // ------------------------------------------------------------ hit tests
  bounds(c) {
    switch (c.type) {
      case "slider": case "keyboardX": return [c.x, c.y, c.w, c.h];
      case "patchName": { const [w, h] = frameSize(c.bmp); return [c.bx, c.by, w, h]; }
      default:
        if (c.bmp && c.bmp.img) { const [w, h] = frameSize(c.bmp); return [c.x, c.y, w, h]; }
        if (c.w) return [c.x, c.y, c.w, c.h];
        return null;
    }
  }
  hit(x, y) {
    const list = this.visible(this.tree);
    for (let i = list.length - 1; i >= 0; i--) {
      const c = list[i];
      if (c.type === "display" || c.type === "ju60Led" || c.type === "lfoLed") continue;
      if (c.fn === "PlugOut") continue;
      const b = this.bounds(c);
      if (b && x >= b[0] && x < b[0] + b[2] && y >= b[1] && y < b[1] + b[3]) return c;
    }
    return null;
  }

  // ------------------------------------------------------------ pointer
  // the panel pixel under the pointer: whole pixels, as the plugin's controls get them (its
  // hit tests and the click velocity are integer arithmetic, rva 0x2D4AA0)
  point(ev) {
    const r = this.cv.getBoundingClientRect();
    return [Math.floor((ev.clientX - r.left) * (this.cv.width / r.width)),
            Math.floor((ev.clientY - r.top) * (this.cv.height / r.height))];
  }
  down(ev) {
    const [x, y] = this.point(ev);
    if (ev.button === 1) return;                 // the middle button: the plugin's window passes none
    if (ev.button === 2 && !ev.shiftKey && !ev.ctrlKey && !ev.altKey && this.M.get("vm.vs.panelPatch") !== 1) {
      const t = this.ccTarget(x, y);
      if (t) { this.ccMenu(ev, t); return; }
    }
    // any other press -- a right one too: the panel's controls do not test the button (rva 0x2AAAF0)
    if (this.M.get("vm.vs.panelPatch") === 1 && this.patchDown(x, y, ev)) return;
    const c = this.hit(x, y);
    if (!c) return;
    this.cv.setPointerCapture(ev.pointerId);
    this.E.start();
    const L = this.leaf(c);
    this.drag = { c, x, y, v: L ? this.val(c) : 0, acc: 0, moved: false };
    switch (c.type) {
      case "slider": {
        const [, ch] = frameSize(c.bmp);
        const travel = c.h - ch, capY = c.y + travel * (1 - this.norm(c));
        if (L && (y < capY || y > capY + ch)) {     // a click off the cap moves it there
          const nv = L.min + Math.round((1 - (y - c.y - ch / 2) / travel) * (L.max - L.min));
          this.M.set(c.ref, nv);
          this.drag.v = this.val(c);
        }
        this.showTip(c);
        break;
      }
      case "knob":
        if (c.bmp.n <= 4 && c.clickable) {
          const n = this.S.numbers.get(c.table)?.length || (L ? L.max - L.min + 1 : c.bmp.n);
          this.M.set(c.ref, this.valueAt(c, (this.position(c) + 1) % Math.min(n, c.bmp.n)));
          this.drag = null;
        }
        this.showTip(c);
        break;
      case "latchButton":
        this.pressed.add(c);
        if (c.onValue !== undefined && c.offValue !== undefined && c.onValue !== c.offValue)
          this.M.set(c.ref, this.val(c) === c.onValue ? c.offValue : c.onValue);
        else if (c.onValue !== undefined) this.M.set(c.ref, c.onValue);
        else this.M.set(c.ref, this.val(c) ? 0 : 1);
        break;
      case "unlatchButton":
        this.pressed.add(c);
        this.action(c.fn, c.args);
        break;
      case "menuButton":
        this.pressed.add(c);
        this.optionMenu(ev);
        break;
      case "setupButton":
        this.pressed.add(c);
        this.midiMenu(ev, c.fn);
        break;
      case "ju60UnlatchButton":
        this.pressed.add(c);
        this.chorusPress(c, ev.shiftKey || this.partnerHeld(c));
        break;
      case "patchName":
        this.pressed.add(c);
        break;
      case "keyboardX": {                // the control's mouse handler (rva 0x2D41F0): down
        const h = this.keyHit(c, x, y);
        this.kb.drag = true;
        this.kbPress(c, this.kbNote(h.n), h.vel, ev.shiftKey);
        break;
      }
    }
    this.dirty = true;
  }
  partnerHeld(c) {
    for (const p of this.pressed) if (p !== c && p.type === "ju60UnlatchButton" && p.role && p.role !== c.role) return true;
    return false;
  }
  move(ev) {
    const d = this.drag;
    if (!d) return;
    const [x, y] = this.point(ev);
    const c = d.c, L = this.leaf(c), fine = ev.shiftKey ? 0.1 : 1;
    if (c.type === "slider" && L) {
      const [, ch] = frameSize(c.bmp);
      d.acc += ((d.y - y) / (c.h - ch)) * (L.max - L.min) * fine;
      d.y = y;
      this.M.set(c.ref, Math.round(d.v + d.acc));
      this.showTip(c);
    } else if (c.type === "knob" && L) {
      if (c.bmp.n <= 4) {                      // a lever: one position per 20 px
        const steps = Math.trunc((d.y - y) / 20);
        if (steps) { this.M.set(c.ref, this.valueAt(c, this.position(c) + Math.sign(steps))); d.y = y; }
      } else {
        d.acc += ((d.y - y) / 200) * (L.max - L.min) * fine;
        d.y = y;
        this.M.set(c.ref, Math.round(d.v + d.acc));
      }
      this.showTip(c);
    } else if (c.type === "ju60UnlatchButton" && c.x2 !== undefined) {
      // the second area (position2) is the partner's: slide onto it for I + II
      const [w, h] = frameSize(c.bmp);
      if (x >= c.x2 && x < c.x2 + w && y >= c.y2 && y < c.y2 + h && !d.both) {
        d.both = true;
        this.chorusPress(c, true);
      }
    } else if (c.type === "keyboardX" && this.kb.drag) {   // a move while it drags
      const h = this.keyHit(c, x, y);
      this.kbPress(c, this.kbNote(h.n), h.vel, ev.shiftKey);
    }
    this.dirty = true;
  }
  up(ev) {
    const d = this.drag;
    if (d && d.c.type === "keyboardX" && this.kb.drag) {   // up: the drag ends, the key released
      const [x, y] = this.point(ev);
      this.kb.drag = false;
      this.kbRelease(this.keyHit(d.c, x, y).vel);
    }
    this.drag = null;
    this.pressed.clear();
    this.tip = null;
    this.dirty = true;
  }
  wheel(ev) {
    const [x, y] = this.point(ev);
    const c = this.hit(x, y);
    if (c && c.type === "keyboardX" && c.writers[0]) {     // the keyboard's wheel (rva 0x2D4420)
      ev.preventDefault();
      this.M.set("fm.PATCH.NAME1.OCTAVE SHIFT", this.M.get("fm.PATCH.NAME1.OCTAVE SHIFT") + (ev.deltaY < 0 ? 1 : -1));
      this.dirty = true;
      return;
    }
    if (!c || !(c.type === "slider" || c.type === "knob") || !this.leaf(c)) return;
    ev.preventDefault();
    if (c.type === "knob" && c.bmp.n <= 4) this.M.set(c.ref, this.valueAt(c, this.position(c) + (ev.deltaY < 0 ? 1 : -1)));
    else this.M.set(c.ref, this.val(c) + (ev.deltaY < 0 ? 1 : -1));
    this.showTip(c);
    clearTimeout(this.tipTimer);
    this.tipTimer = setTimeout(() => { this.tip = null; this.dirty = true; }, 800);
    this.dirty = true;
  }
  dblclick(ev) {
    const [x, y] = this.point(ev);
    const c = this.hit(x, y);
    if (!c || !(c.type === "slider" || (c.type === "knob" && c.bmp.n > 4))) return;
    const L = this.leaf(c);
    if (L) this.M.set(c.ref, L.def);
    this.dirty = true;
  }
  showTip(c) {
    const [w] = c.bmp && c.bmp.img ? frameSize(c.bmp) : [c.w || 0];
    const [dx, dy] = c.tipAt || [0, 0];
    this.tip = { s: this.label(c), x: c.x + (c.w || w) / 2 + dx, y: c.y + dy };
  }

  // --------------------------------------------------- functions and menus
  action(fn, args) {
    if (fn === "ManagePatch" && (args === "inc" || args === "dec")) {
      const b = this.banks[this.bank];
      if (!b) return;
      this.loadPatch((this.patch + (args === "inc" ? 1 : 63)) % 64, true);
    } else if (fn === "ManagePatch" && args === "load") {
      this.loadPatch(this.patchSel, true);
    } else if (fn === "ManagePatchBank" && (args === "inc" || args === "dec")) {
      if (!this.banks.length) return;
      this.bank = (this.bank + (args === "inc" ? 1 : this.banks.length - 1)) % this.banks.length;
      this.dirty = true;
    } else if (fn === "ManagePatchBank" && args === "import") {
      this.importBank();
    } else if (fn === "ManagePatchBank" && args === "export") {
      const b = this.banks[this.bank];
      if (!b) return;
      const a = document.createElement("a");
      a.href = URL.createObjectURL(new Blob([b.bytes]));
      a.download = b.name + ".bin";
      a.click();
    } else if (fn === "Help" || fn === "About") {
      this.status(fn === "About" ? "JUNO-60: the plugin's own GUI (Script.xml) on the C99 port" :
        "Drag knobs and sliders up/down (shift: fine), double-click: default, wheel: one step. " +
        "CHORUS I + II: hold shift, or slide from I onto II. Keys: lower = louder.");
    } else {
      this.status(`${fn} ${args || ""}: not part of this port (SYSTEM-8 link / bank writing)`);
    }
  }

  // the patch browser's load (rva 0x338090: the patch, its set of the patch number); the
  // ManagePatch buttons' handler then commits (rva 0x322E60), the list does not (rva 0x3278C0)
  loadPatch(idx, commit = false) {
    const b = this.banks[this.bank];
    if (!b) return;
    this.E.loadPatch(b.bytes, idx);
    this.patch = this.patchSel = idx;
    this.M.setBare("vm.vs.patchId", idx);
    if (commit) this.E.commit();
    this.M.refresh();
    this.status(`${b.name}: ${idx + 1} ${this.patchNameText()}`);
    this.dirty = true;
  }

  addBank(name, bytes) {
    const magic = new TextDecoder().decode(bytes.slice(0, 16));
    if (magic !== "KoaBankFile00003" || bytes.length < HEADER + 64 * STRIDE) throw new Error(name + ": not a JUNO-60 bank");
    this.banks.push({ name, bytes });
    return this.banks.length - 1;
  }
  importBank() {
    const inp = document.createElement("input");
    inp.type = "file";
    inp.accept = ".bin";
    inp.onchange = async () => {
      const f = inp.files[0];
      if (!f) return;
      try {
        this.bank = this.addBank(f.name.replace(/\.bin$/i, ""), new Uint8Array(await f.arrayBuffer()));
        this.status(`bank ${this.banks[this.bank].name} loaded: 64 patches`);
        this.dirty = true;
      } catch (e) { this.status(String(e)); }
    };
    inp.click();
  }
  bankNames(b) {
    const out = [];
    for (let i = 0; i < 64; i++) {
      const r = b.bytes.subarray(HEADER + i * STRIDE, HEADER + i * STRIDE + NAME);
      out.push(String.fromCharCode(...Array.from(r, x => (x >= 32 && x < 127 ? x : 32))).replace(/\s+$/, ""));
    }
    return out;
  }

  // the OPTION menu (menuButton): the view-model values it lists
  optionMenu(ev) {
    const m = this.menu(ev);
    const row = (label, ref, items) => {
      const L = this.M.leaf(ref);
      if (!L) return;
      const h = document.createElement("div");
      h.className = "mh";
      h.textContent = label;
      m.appendChild(h);
      for (const [v, s] of items) {
        const b = document.createElement("div");
        b.className = "mi" + (this.M.get(ref) === v ? " on" : "");
        b.textContent = s;
        b.onclick = () => { this.M.set(ref, v); this.closeMenu(); this.dirty = true; };
        m.appendChild(b);
      }
    };
    row("Panel", "vm.vs.mode", [[0, "Original"], [1, "SYSTEM-8 layout"]]);
    row("Voices", "vm.vs.voiceCount", [2, 3, 4, 5, 6, 7, 8].map(v => [v, String(v)]));
    // the engine-rate setting indexes the plugin's table (rva 0x94AB80)
    row("Engine rate", "vm.vs.sampleRate", [[0, "96 kHz"], [1, "88.2 kHz"], [2, "48 kHz"], [3, "44.1 kHz"]]);
    row("Zoom", "vm.vs.mainZoom", [50, 62, 75, 100, 125, 150].map(v => [v, v + "%"]));
  }
  midiMenu(ev, fn) {
    const m = this.menu(ev);
    if (!this.midi) { m.textContent = "Web MIDI not available here"; return; }
    const list = fn === "midiOut" ? [...this.midi.outputs.values()] : [...this.midi.inputs.values()];
    if (!list.length) m.textContent = "no MIDI ports";
    for (const p of list) {
      const b = document.createElement("div");
      b.className = "mi";
      b.textContent = p.name;
      b.onclick = () => { if (fn !== "midiOut") this.listen(p); this.closeMenu(); };
      m.appendChild(b);
    }
  }
  menu(ev) {
    this.closeMenu();
    const m = document.createElement("div");
    m.className = "menu";
    m.style.left = ev.clientX + "px";
    m.style.top = ev.clientY + "px";
    document.body.appendChild(m);
    this.menuEl = m;
    // a press outside closes the menu -- registered after the press that opened it, and only while
    // this menu is the open one (a late timer once closed the next menu on its own item's press)
    setTimeout(() => {
      if (this.menuEl !== m) return;
      document.addEventListener("pointerdown", this.menuOff = e => { if (this.menuEl === m && !m.contains(e.target)) this.closeMenu(); });
    }, 0);
    document.addEventListener("keydown", this.menuKey = e => { if (this.menuEl === m && e.key === "Escape") this.closeMenu(); });
    return m;
  }
  closeMenu() {
    if (this.menuEl) this.menuEl.remove();
    if (this.menuOff) document.removeEventListener("pointerdown", this.menuOff);
    if (this.menuKey) document.removeEventListener("keydown", this.menuKey);
    this.menuEl = this.menuOff = this.menuKey = null;
  }

  // ------------------------------------------------------- the CC assign control
  // The main panel's last control (Script.xml ccAssign, rva 0x31D420): a panel offers a
  // mouse message to its controls from the last, then to its open panels from the last
  // (rva 0x2AAAF0), so a right-button press or double click with no Shift, Ctrl or Alt
  // (the message's flags exactly 4, rva 0x411DB0) reaches it first. It looks for the
  // control under the press the same way (rva 0x31D270): a control that holds the point,
  // is not a label or a display and has exactly one value (rva 0x31D7F0), whose parameter
  // has a CC map record (rva 0x319B10). Found: the menu, and the press goes no further.
  ccTarget(x, y, node = this.tree) {
    if (node.kind !== "panel" || !this.open(node)) return null;
    const it = node.items;
    for (let i = it.length - 1; i >= 0; i--) {
      const c = it[i];
      if (c.kind !== "control") continue;
      const b = this.bounds(c);
      if (!b || x < b[0] || x >= b[0] + b[2] || y < b[1] || y >= b[1] + b[3]) continue;
      if (c.type === "label" || c.type === "display" || c.refs.length !== 1) continue;
      const L = this.M.leaf(c.ref);
      if (L && this.E.ccEntry(L.id) >= 0) return { c, id: L.id };
    }
    for (let i = it.length - 1; i >= 0; i--) {
      if (it[i].kind !== "panel") continue;
      const t = this.ccTarget(x, y, it[i]);
      if (t) return t;
    }
    return null;
  }
  // its menu: "Learn MIDI CC" (the learn waits for the first CC below 120 the UI timer
  // drains, rva 0x31AA40); "Forget MIDI CC #n" while a CC drives the parameter (rva
  // 0x3192E0), greyed and without a number when none does or a learn waits (rva 0x319B70)
  ccMenu(ev, t) {
    const m = this.menu(ev);
    const cc = this.E.ccOf(t.id);
    const item = (label, on, fn) => {
      const b = document.createElement("div");
      b.className = "mi" + (on ? "" : " off");
      b.textContent = label;
      if (on) b.onclick = () => { fn(); this.closeMenu(); this.dirty = true; };
      m.appendChild(b);
    };
    item("Learn MIDI CC", true, () => this.E.ccLearn(t.id));
    item(cc >= 0 ? `Forget MIDI CC #${cc}` : "Forget MIDI CC", cc >= 0, () => this.E.ccForget(t.id));
    return m;
  }

  // ------------------------------------------------- the patch manager window
  drawPatchWindow() {
    const g = this.g;
    g.fillStyle = "rgba(0,0,0,0.55)";
    g.fillRect(0, 0, this.cv.width, this.cv.height);
    this.drawPanelForce(this.patchTree);
    const b = this.banks[this.bank];
    for (const c of this.patchTree.items) {
      if (c.type === "patchBankName") {
        const [bx, by] = ints(text(c.el, "buttonPosition"));
        const [tx, ty] = ints(text(c.el, "textPosition"));
        drawFrame(g, c.bmp, 0, c.x + bx, c.y + by);
        drawText(g, c.writers[0], b ? b.name : "(no bank)", c.x + tx, c.y + ty, c.w - tx, c.h - ty);
      }
      if (c.type === "patch" && b) {
        const names = this.bankNames(b);
        const cols = 4, rows = 16, cw = c.w / cols, rh = c.h / rows;
        for (let i = 0; i < 64; i++) {
          const x = c.x + Math.floor(i / rows) * cw, y = c.y + (i % rows) * rh;
          const wr = i === this.patchSel ? c.writers[1] : c.writers[0];
          drawText(g, { ...wr, alignV: "center" }, `${String(i + 1).padStart(2, "0")} ${names[i]}`, x + 8, y, cw - 12, rh);
        }
      }
    }
  }
  drawPanelForce(node) {
    const g = this.g;
    if (node.bmp) { const bm = this.S.bitmaps.get(node.bmp); if (bm && bm.img) g.drawImage(bm.img, node.x, node.y); }
    for (const c of node.items) {
      if (c.kind !== "control") continue;
      if (c.type === "unlatchButton") {
        if (c.args === "sendUser" || c.args === "getUser") continue;   // SYSTEM-8 transfer
        drawFrame(g, c.bmp, this.pressed.has(c) ? 1 : 0, c.x, c.y);
      }
    }
  }
  patchDown(x, y, ev) {
    const t = this.patchTree;
    for (const c of t.items) {
      if (c.kind !== "control") continue;
      if (c.type === "patch") {
        if (x >= c.x && x < c.x + c.w && y >= c.y && y < c.y + c.h) {
          const cols = 4, rows = 16;
          const i = Math.floor((x - c.x) / (c.w / cols)) * rows + Math.floor((y - c.y) / (c.h / rows));
          if (i >= 0 && i < 64) {
            this.patchSel = i;
            if (ev.detail >= 2) this.loadPatch(i);   // double click: read the patch
          }
          this.dirty = true;
          return true;
        }
      } else if (c.type === "unlatchButton" && c.bmp && c.bmp.img) {
        if (c.args === "sendUser" || c.args === "getUser") continue;
        const [w, h] = frameSize(c.bmp);
        if (x >= c.x && x < c.x + w && y >= c.y && y < c.y + h) {
          this.pressed.add(c);
          this.action(c.fn, c.args);
          this.dirty = true;
          return true;
        }
      }
    }
    const [w, h] = this.patchTree.size;
    if (x < t.x || y < t.y || x >= t.x + w || y >= t.y + h) {
      this.M.set("vm.vs.panelPatch", 0);           // a click outside closes the window
      this.dirty = true;
      return true;
    }
    return true;
  }

  // ------------------------------------------------------------ MIDI in
  listen(port) {
    if (this.port) this.port.onmidimessage = null;
    this.port = port;
    port.onmidimessage = e => {
      const [st, d1, d2] = e.data, cmd = st & 0xf0;
      if (cmd === 0x90 && d2 > 0) this.E.start();
      if (cmd >= 0x80 && cmd <= 0xe0 && cmd !== 0xa0 && cmd !== 0xc0) this.E.midiIn(st, d1, d2 | 0);
      this.dirty = true;
    };
    this.status("MIDI in: " + port.name);
  }

  applyZoom() {
    const z = Math.max(25, Math.min(200, this.M.get("vm.vs.mainZoom"))) / 100;
    this.cv.style.width = Math.round(this.cv.width * z) + "px";
    this.cv.style.height = Math.round(this.cv.height * z) + "px";
  }
}

// --------------------------------------------------------------------- boot
async function loadImage(url) {
  const im = new Image();
  im.src = url;
  await im.decode();
  return im;
}

export async function boot(canvas, status) {
  status("loading the plugin's Script.xml…");
  const xml = await (await fetch(XML_URL)).text();
  const doc = new DOMParser().parseFromString(xml, "application/xml");
  if (doc.getElementsByTagName("parsererror").length) throw new Error("Script.xml: parse error");
  const S = new Script(doc);
  status("loading the sprite sheets…");
  await Promise.all([...S.bitmaps.entries()].map(async ([name, bm]) => {
    try { bm.img = await loadImage(IMG_BASE + name); } catch (e) { bm.img = null; bm.err = String(e); }
  }));
  const missing = [...S.bitmaps.entries()].filter(([, b]) => !b.img).map(([n]) => n);
  status("starting the engine…");
  const E = await new WasmEngine().init();
  const [w, h] = ints(text(S.panels.get("main"), "size"));
  canvas.width = w;
  canvas.height = h;
  const skin = new Skin(S, E, canvas, status);
  skin.M.refresh();
  if (Q.has("zoom")) skin.M.set("vm.vs.mainZoom", +Q.get("zoom"));
  skin.applyZoom();
  try {
    const bytes = new Uint8Array(await (await fetch(BANK_URL)).arrayBuffer());
    skin.addBank("Factory", bytes);
    skin.loadPatch(0);
  } catch (e) { status("no factory bank: " + e); }
  // ?banks=<manifest>: more banks for the patch window, [{name, file}] with
  // each file relative to the manifest (the user's own banks: input, never truth)
  if (Q.get("banks")) {
    try {
      const url = new URL(Q.get("banks"), location.href);
      for (const b of await (await fetch(url)).json()) {
        try { skin.addBank(b.name, new Uint8Array(await (await fetch(new URL(b.file, url))).arrayBuffer())); }
        catch (e) { console.warn("bank " + b.name + ": " + e); }
      }
    } catch (e) { console.warn("banks: " + e); }
  }
  E.setTempo(40 + skin.M.get("fm.SYNTH.COM.TEMPO") / 10);
  canvas.addEventListener("pointerdown", e => skin.down(e));
  canvas.addEventListener("contextmenu", e => e.preventDefault());   // the right button is the panel's
  canvas.addEventListener("pointermove", e => skin.move(e));
  canvas.addEventListener("pointerup", e => skin.up(e));
  canvas.addEventListener("pointercancel", e => skin.up(e));
  canvas.addEventListener("wheel", e => skin.wheel(e), { passive: false });
  canvas.addEventListener("dblclick", e => skin.dblclick(e));
  // the plugin's UI timer: every 50 ms the drain (rva 0x320120), then a redraw
  // of what changed in the model
  setInterval(() => {               // the plugin's UI timer: the drain, then what changed
    E.uiTick();
    let kb = false;
    for (let i = 0; i < 128 && !kb; i++) kb = (E.keybedState(i) > 0) !== (skin.kbStates[i] > 0);
    if (skin.M.refresh() || kb) skin.dirty = true;
    if (skin.meterTick()) skin.dirty = true;
  }, 50);
  const frame = () => {
    if (skin.dirty) { skin.dirty = false; skin.draw(); }
    requestAnimationFrame(frame);
  };
  requestAnimationFrame(frame);
  if (navigator.requestMIDIAccess) {
    navigator.requestMIDIAccess({ sysex: false }).then(a => {
      skin.midi = a;
      const first = [...a.inputs.values()][0];
      if (first) skin.listen(first);
    }).catch(() => {});
  }
  if (missing.length) status("missing sprite sheets: " + missing.join(", "));
  else status("ready -- click a key or a control (audio starts on the first click)");
  window.__skin = { S, E, skin, missing };
  return skin;
}
