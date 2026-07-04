#!/usr/bin/env python3
"""juno_gui.py — barebones test GUI for the JUNO-60 C99 port.

Latches onto the engine through gui/juno_bridge.c (libjuno.so, ctypes).
Parameter set = every named coefficient in docs/COEFF_PARAM_MAP.md (the
sub_180388170 registry parse); control is the plugin's own mechanism — a raw
float store to the state offset, native units, no curves.

Features (deliberately minimal):
  * all mapped parameters, grouped by engine section, filterable by name
  * edit a value + Enter to write it; changed-from-loaded rows highlighted
  * patch recall: save/load JSON patches (presets/*.json) + factory recall
    (the captured "PD The Juno Pad" patch built into the port)
  * render N samples to a WAV for offline listening (no audio backend)
  * gate poke button — EXPERIMENTAL: real note-on path not yet ported, so
    this is expected to stay silent (docs/CONTROL_LAYER.md)

Usage:  make gui && python3 gui/juno_gui.py
        python3 gui/juno_gui.py --selftest   (headless bridge check, no Tk)
"""
import ctypes, json, os, re, struct, sys, wave

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LIB = os.path.join(ROOT, "libjuno.so")
MAP = os.path.join(ROOT, "docs", "COEFF_PARAM_MAP.md")
PRESET_DIR = os.path.join(ROOT, "presets")
SAMPLE_RATE = 96000  # captured patch is 96 kHz (docs/PORT_STATUS.md)

# ---------------------------------------------------------------- engine

class Engine:
    def __init__(self):
        lib = ctypes.CDLL(LIB)
        lib.juno_gui_create.restype = ctypes.c_void_p
        lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
        lib.juno_gui_destroy.argtypes = [ctypes.c_void_p]
        lib.juno_gui_set.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_float]
        lib.juno_gui_get.restype = ctypes.c_float
        lib.juno_gui_get.argtypes = [ctypes.c_void_p, ctypes.c_int]
        lib.juno_gui_recall_factory.argtypes = [ctypes.c_void_p]
        lib.juno_gui_set_chorus_mode.argtypes = [ctypes.c_void_p, ctypes.c_int]
        lib.juno_gui_gate.argtypes = [ctypes.c_void_p, ctypes.c_float]
        lib.juno_gui_render.restype = ctypes.c_int
        lib.juno_gui_render.argtypes = [ctypes.c_void_p,
                                        ctypes.POINTER(ctypes.c_float), ctypes.c_int]
        self.lib = lib
        self.ctx = lib.juno_gui_create(ctypes.c_float(SAMPLE_RATE), 0)
        if not self.ctx:
            raise RuntimeError("engine alloc failed")

    def set(self, off, v):  self.lib.juno_gui_set(self.ctx, off, ctypes.c_float(v))
    def get(self, off):     return self.lib.juno_gui_get(self.ctx, off)
    def recall_factory(self): self.lib.juno_gui_recall_factory(self.ctx)
    def chorus_mode(self, m): self.lib.juno_gui_set_chorus_mode(self.ctx, m)
    def gate(self, v):      self.lib.juno_gui_gate(self.ctx, ctypes.c_float(v))

    def render_wav(self, path, nframes):
        buf = (ctypes.c_float * (2 * nframes))()
        full = self.lib.juno_gui_render(self.ctx, buf, nframes)
        with wave.open(path, "wb") as w:
            w.setnchannels(2); w.setsampwidth(2); w.setframerate(SAMPLE_RATE)
            pcm = bytearray()
            for f in buf:
                s = max(-1.0, min(1.0, f))
                pcm += struct.pack("<h", int(s * 32767))
            w.writeframes(bytes(pcm))
        return full

# ------------------------------------------------------------- param map

def section_of(off):
    for lim, name in ((84000, "Voice"), (85000, "Master/Voices"),
                      (91000, "Drive/OD/DS"), (96000, "FX Chorus A (91k)"),
                      (101000, "FX Chorus B (96k)"), (102000, "Output"),
                      (110000, "Delay/HighCut (102k)"), (5000000, "Delay 2 (4.29M)"),
                      (6400000, "Chorus I (6.39M)"), (6450000, "Flanger (6.43M)"),
                      (6500000, "FX (6.49M)"), (10700000, "Chorus II (10.69M)")):
        if off < lim:
            return name
    return "Reverb Ecf (10.75M)"

def load_param_map():
    """Parse docs/COEFF_PARAM_MAP.md table rows -> [(offset, name)]."""
    params = []
    with open(MAP) as f:
        for line in f:
            m = re.match(r"\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|", line)
            if m and m.group(1).isdigit():
                params.append((int(m.group(1)), m.group(2)))
    # unique by offset, sorted; duplicate names are distinct params
    return sorted(dict(params).items())

# --------------------------------------------------------------- presets

def save_preset(engine, params, path):
    data = {str(off): engine.get(off) for off, _ in params}
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        json.dump(data, f, indent=0)

def load_preset(engine, path):
    with open(path) as f:
        data = json.load(f)
    for off, v in data.items():
        engine.set(int(off), float(v))

# -------------------------------------------------------------- selftest

def selftest():
    eng = Engine()
    params = load_param_map()
    assert len(params) > 300, "param map parse too small: %d" % len(params)
    cutoff = eng.get(6736)
    eng.set(6736, 0.5); assert abs(eng.get(6736) - 0.5) < 1e-6
    eng.recall_factory(); assert abs(eng.get(6736) - cutoff) < 1e-6
    p = os.path.join(PRESET_DIR, "_selftest.json")
    save_preset(eng, params, p)
    eng.set(6736, 0.9); load_preset(eng, p); os.remove(p)
    assert abs(eng.get(6736) - cutoff) < 1e-6
    wavp = os.path.join(ROOT, "gui", "_selftest.wav")
    full = eng.render_wav(wavp, 512); os.remove(wavp)
    print("selftest OK: %d params, cutoff=%g, render path=%s"
          % (len(params), cutoff, "master/chorus" if full else "dry"))

# -------------------------------------------------------------------- UI

def main():
    import tkinter as tk
    from tkinter import ttk, filedialog, messagebox, simpledialog

    eng = Engine()
    params = load_param_map()

    root = tk.Tk()
    root.title("jn60c99 test panel — %d params @ %d Hz" % (len(params), SAMPLE_RATE))
    root.geometry("760x800")

    # -- top bar: patch recall + utilities
    bar = ttk.Frame(root); bar.pack(fill="x", padx=4, pady=4)
    rows = {}  # off -> (entry_var, entry_widget, loaded_value)

    def refresh_all():
        for off, (var, ent, _) in rows.items():
            v = eng.get(off)
            var.set("%.9g" % v)
            rows[off] = (var, ent, v)
            ent.config(bg="white")

    def do_factory():
        eng.recall_factory(); refresh_all()

    def do_save():
        name = simpledialog.askstring("Save patch", "Patch name:")
        if name:
            save_preset(eng, params, os.path.join(PRESET_DIR, name + ".json"))

    def do_load():
        p = filedialog.askopenfilename(initialdir=PRESET_DIR,
                                       filetypes=[("patch", "*.json")])
        if p:
            load_preset(eng, p); refresh_all()

    def do_render():
        n = simpledialog.askinteger("Render", "Frames (@96kHz):",
                                    initialvalue=SAMPLE_RATE)
        if n:
            out = os.path.join(ROOT, "gui", "render.wav")
            full = eng.render_wav(out, n)
            messagebox.showinfo("Render", "%s\npath: %s" %
                                (out, "master/chorus" if full else "dry fallback"))

    def do_gate(v):
        eng.gate(v)

    for txt, cmd in (("Factory patch", do_factory), ("Save patch…", do_save),
                     ("Load patch…", do_load), ("Render WAV…", do_render)):
        ttk.Button(bar, text=txt, command=cmd).pack(side="left", padx=2)
    ttk.Button(bar, text="Gate 1", command=lambda: do_gate(1.0)).pack(side="left", padx=2)
    ttk.Button(bar, text="Gate 0", command=lambda: do_gate(0.0)).pack(side="left")
    ttk.Label(bar, text="chorus:").pack(side="left", padx=(8, 0))
    cm = tk.IntVar(value=0)
    for m in (0, 1, 2):
        ttk.Radiobutton(bar, text=str(m), variable=cm, value=m,
                        command=lambda: eng.chorus_mode(cm.get())).pack(side="left")

    warn = ttk.Label(root, foreground="#a00", text=
        "note-on path not ported yet (voice 0 only) — param edits & patch "
        "recall are live; Gate alone stays silent. See docs/CONTROL_LAYER.md")
    warn.pack(fill="x", padx=4)

    # -- filter box
    fbar = ttk.Frame(root); fbar.pack(fill="x", padx=4)
    ttk.Label(fbar, text="filter:").pack(side="left")
    fvar = tk.StringVar()
    ttk.Entry(fbar, textvariable=fvar).pack(side="left", fill="x", expand=True)

    # -- scrollable parameter list
    canvas = tk.Canvas(root, highlightthickness=0)
    vsb = ttk.Scrollbar(root, orient="vertical", command=canvas.yview)
    inner = ttk.Frame(canvas)
    inner.bind("<Configure>",
               lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
    canvas.create_window((0, 0), window=inner, anchor="nw")
    canvas.configure(yscrollcommand=vsb.set)
    canvas.pack(side="left", fill="both", expand=True, padx=4, pady=4)
    vsb.pack(side="right", fill="y")
    canvas.bind_all("<Button-4>", lambda e: canvas.yview_scroll(-3, "units"))
    canvas.bind_all("<Button-5>", lambda e: canvas.yview_scroll(3, "units"))
    canvas.bind_all("<MouseWheel>",
                    lambda e: canvas.yview_scroll(-1 if e.delta > 0 else 1, "units"))

    def build_rows(filter_text=""):
        for w in inner.winfo_children():
            w.destroy()
        rows.clear()
        ft = filter_text.lower()
        r, last_sec = 0, None
        for off, name in params:
            if ft and ft not in name.lower() and ft not in str(off):
                continue
            sec = section_of(off)
            if sec != last_sec:
                ttk.Label(inner, text="— %s —" % sec,
                          font=("TkDefaultFont", 9, "bold")
                          ).grid(row=r, column=0, columnspan=3, sticky="w",
                                 pady=(6, 1))
                r += 1; last_sec = sec
            ttk.Label(inner, text=name, width=28, anchor="w"
                      ).grid(row=r, column=0, sticky="w")
            ttk.Label(inner, text="@%d" % off, width=10, anchor="w",
                      foreground="#888").grid(row=r, column=1)
            v = eng.get(off)
            var = tk.StringVar(value="%.9g" % v)
            ent = tk.Entry(inner, textvariable=var, width=16)
            ent.grid(row=r, column=2, sticky="w")
            rows[off] = (var, ent, v)

            def commit(_ev, off=off):
                var, ent, loaded = rows[off]
                try:
                    val = float(var.get())
                except ValueError:
                    ent.config(bg="#fbb"); return
                eng.set(off, val)
                var.set("%.9g" % eng.get(off))
                ent.config(bg="#ffd" if abs(val - loaded) > 1e-12 else "white")
            ent.bind("<Return>", commit)
            r += 1

    build_rows()
    fvar.trace_add("write", lambda *_: build_rows(fvar.get()))
    root.mainloop()

if __name__ == "__main__":
    if "--selftest" in sys.argv:
        selftest()
    else:
        main()
