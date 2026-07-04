#!/usr/bin/env python3
"""juno_web.py — localhost web GUI for the JUNO-60 C99 port.

A zero-dependency web app: Python stdlib HTTP server bridging to the engine
(juno.dll on Windows / libjuno.so elsewhere, via ctypes — the same bridge the
Tk GUI uses) and serving gui/index.html. Runs straight from a repo checkout:

    python3 gui/juno_web.py            # serves http://localhost:8765, opens browser
    python3 gui/juno_web.py --port 9000 --no-browser
    python3 gui/juno_web.py --selftest # headless API check (no browser/server)

Every mapped parameter (docs/COEFF_PARAM_MAP.md) becomes a slider or toggle; a
small piano triggers the (not-yet-ported) note gate; patches load/save as JSON;
render-to-WAV plays in the browser. Ranges: see param_meta() — real positions
(captured factory patch), heuristic *bounds* until tools/extract_param_meta.py
dumps the plugin's real range table into gui/param_meta.json.
"""
import ctypes, json, os, re, struct, sys, io, wave, argparse, webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GUI = os.path.join(ROOT, "gui")
LIB = os.path.join(ROOT, "juno.dll" if sys.platform == "win32" else "libjuno.so")
MAP = os.path.join(ROOT, "docs", "COEFF_PARAM_MAP.md")
PRESET_DIR = os.path.join(ROOT, "presets")
META_JSON = os.path.join(GUI, "param_meta.json")   # optional real-range override
SAMPLE_RATE = 96000

# ------------------------------------------------------------ engine bridge

class Engine:
    def __init__(self):
        if not os.path.exists(LIB):
            raise RuntimeError("%s not found — %s" % (LIB,
                "juno.dll ships prebuilt; re-download the branch or `make dll`"
                if sys.platform == "win32" else "build it first: `make gui`"))
        lib = ctypes.CDLL(LIB)
        lib.juno_gui_create.restype = ctypes.c_void_p
        lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
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

    def set(self, off, v):  self.lib.juno_gui_set(self.ctx, int(off), ctypes.c_float(v))
    def get(self, off):     return float(self.lib.juno_gui_get(self.ctx, int(off)))
    def factory(self):      self.lib.juno_gui_recall_factory(self.ctx)
    def chorus(self, m):    self.lib.juno_gui_set_chorus_mode(self.ctx, int(m))
    def gate(self, v):      self.lib.juno_gui_gate(self.ctx, ctypes.c_float(v))

    def render_wav_bytes(self, nframes):
        buf = (ctypes.c_float * (2 * nframes))()
        full = self.lib.juno_gui_render(self.ctx, buf, nframes)
        bio = io.BytesIO()
        with wave.open(bio, "wb") as w:
            w.setnchannels(2); w.setsampwidth(2); w.setframerate(SAMPLE_RATE)
            pcm = bytearray()
            for f in buf:
                s = max(-1.0, min(1.0, f))
                pcm += struct.pack("<h", int(s * 32767))
            w.writeframes(bytes(pcm))
        return bio.getvalue(), full

# --------------------------------------------------------------- param map

_SWITCH = re.compile(r"\b(sw|on/?off|onoff|mute|enable|bypass|sync|reset|"
                     r"trig|initialize|use iir|stereo sw|tap sw|low cut sw|"
                     r"high cut sw)\b", re.I)
_BIPOLAR = re.compile(r"\b(tune|detune|bend|offset|ofst|phase|pan|vel.*offset)\b", re.I)

def section_of(off):
    for lim, name in ((84000, "Voice"), (85000, "Master/Voices"),
                      (91000, "Drive/OD/DS"), (96000, "FX Chorus A (91k)"),
                      (101000, "FX Chorus B (96k)"), (102000, "Output"),
                      (110000, "Delay/HighCut"), (5000000, "Delay 2"),
                      (6400000, "Chorus I"), (6450000, "Flanger"),
                      (6500000, "FX"), (10700000, "Chorus II")):
        if off < lim:
            return name
    return "Reverb Ecf"

def parse_map():
    params = []
    seen = set()
    with open(MAP, encoding="utf-8") as f:
        for line in f:
            m = re.match(r"\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|", line)
            if m and m.group(1).isdigit():
                off = int(m.group(1))
                if off not in seen:
                    seen.add(off); params.append((off, m.group(2)))
    return sorted(params)

def param_meta(engine):
    """Per-parameter UI descriptor. Positions (`value`) are the REAL captured
    factory values read from the engine; min/max/kind are heuristic UNTIL a real
    range table is present in gui/param_meta.json (from tools/extract_param_meta.py).
    """
    real = {}
    if os.path.exists(META_JSON):
        try:
            real = {int(k): v for k, v in json.load(open(META_JSON)).items()}
        except Exception:
            real = {}
    out = []
    for off, name in parse_map():
        val = engine.get(off)
        if off in real:                       # authoritative range from the dump
            r = real[off]
            lo, hi = float(r["min"]), float(r["max"])
            kind = r.get("kind", "cont")
            authoritative = True
        elif _SWITCH.search(name):
            lo, hi, kind, authoritative = 0.0, 1.0, "switch", False
        else:
            authoritative = False
            if _BIPOLAR.search(name):
                span = max(1.0, abs(val) * 1.25)
                lo, hi, kind = -span, span, "cont"
            else:
                lo, hi, kind = 0.0, max(1.0, abs(val) * 1.25), "cont"
        out.append({"off": off, "name": name, "section": section_of(off),
                    "kind": kind, "min": lo, "max": hi, "value": val,
                    "authoritative": authoritative})
    return out

# --------------------------------------------------------------- presets

def preset_list():
    if not os.path.isdir(PRESET_DIR):
        return []
    return sorted(f[:-5] for f in os.listdir(PRESET_DIR) if f.endswith(".json"))

def preset_save(engine, name):
    os.makedirs(PRESET_DIR, exist_ok=True)
    data = {str(off): engine.get(off) for off, _ in parse_map()}
    safe = re.sub(r"[^\w.-]", "_", name) or "patch"
    with open(os.path.join(PRESET_DIR, safe + ".json"), "w") as f:
        json.dump(data, f, indent=0)
    return safe

def preset_load(engine, name):
    safe = re.sub(r"[^\w.-]", "_", name)
    with open(os.path.join(PRESET_DIR, safe + ".json")) as f:
        data = json.load(f)
    for off, v in data.items():
        engine.set(int(off), float(v))

# ------------------------------------------------------------ HTTP server

class Handler(BaseHTTPRequestHandler):
    engine = None  # set in serve()

    def log_message(self, *a):  # quiet
        pass

    def _send(self, code, body, ctype="application/json"):
        if isinstance(body, str):
            body = body.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _json_body(self):
        n = int(self.headers.get("Content-Length", 0))
        return json.loads(self.rfile.read(n) or b"{}")

    def do_GET(self):
        eng = self.engine
        if self.path == "/" or self.path.startswith("/index"):
            with open(os.path.join(GUI, "index.html"), "rb") as f:
                return self._send(200, f.read(), "text/html; charset=utf-8")
        if self.path == "/favicon.ico":
            return self._send(204, b"", "image/x-icon")
        if self.path == "/api/params":
            return self._send(200, json.dumps({
                "params": param_meta(eng), "presets": preset_list(),
                "sample_rate": SAMPLE_RATE}))
        if self.path.startswith("/api/render"):
            m = re.search(r"frames=(\d+)", self.path)
            frames = int(m.group(1)) if m else SAMPLE_RATE // 2
            frames = max(1, min(frames, SAMPLE_RATE * 4))
            body, _ = eng.render_wav_bytes(frames)
            return self._send(200, body, "audio/wav")
        return self._send(404, json.dumps({"error": "not found"}))

    def do_POST(self):
        eng = self.engine
        try:
            b = self._json_body()
        except Exception as e:
            return self._send(400, json.dumps({"error": str(e)}))
        p = self.path
        if p == "/api/set":
            eng.set(b["off"], float(b["value"]))
            return self._send(200, json.dumps({"off": b["off"], "value": eng.get(b["off"])}))
        if p == "/api/gate":
            eng.gate(float(b.get("value", 0.0)))
            return self._send(200, json.dumps({"ok": True}))
        if p == "/api/note":
            # note-on: write pitch (UNCONFIRMED (note-60)/12 octave mapping) +
            # the voice-0 gate edge. Silent until the ramp-gate path (unit #1)
            # is ported — see docs/CONTROL_LAYER.md.
            note = int(b.get("note", 60))
            if b.get("on"):
                eng.set(4448, (note - 60) / 12.0)   # pitch offset, octave units
                eng.gate(1.0)
            else:
                eng.gate(0.0)
            return self._send(200, json.dumps({"note": note, "on": bool(b.get("on"))}))
        if p == "/api/chorus":
            eng.chorus(int(b.get("mode", 0)))
            return self._send(200, json.dumps({"ok": True}))
        if p == "/api/factory":
            eng.factory()
            return self._send(200, json.dumps({"params": param_meta(eng)}))
        if p == "/api/preset/load":
            preset_load(eng, b["name"])
            return self._send(200, json.dumps({"params": param_meta(eng)}))
        if p == "/api/preset/save":
            name = preset_save(eng, b["name"])
            return self._send(200, json.dumps({"saved": name, "presets": preset_list()}))
        return self._send(404, json.dumps({"error": "not found"}))

def serve(port, open_browser):
    Handler.engine = Engine()
    httpd = ThreadingHTTPServer(("127.0.0.1", port), Handler)
    url = "http://localhost:%d/" % port
    print("juno_web serving %s  (Ctrl-C to stop)" % url)
    print("  engine: %s  |  %d params" % (os.path.basename(LIB), len(parse_map())))
    if open_browser:
        try: webbrowser.open(url)
        except Exception: pass
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nstopped")

# --------------------------------------------------------------- selftest

def selftest():
    eng = Engine()
    meta = param_meta(eng)
    assert len(meta) > 300, "meta too small: %d" % len(meta)
    cutoff = eng.get(6736)
    eng.set(6736, 0.5); assert abs(eng.get(6736) - 0.5) < 1e-6
    eng.factory(); assert abs(eng.get(6736) - cutoff) < 1e-6
    name = preset_save(eng, "_webselftest")
    eng.set(6736, 0.9); preset_load(eng, name)
    os.remove(os.path.join(PRESET_DIR, name + ".json"))
    assert abs(eng.get(6736) - cutoff) < 1e-6
    wav, full = eng.render_wav_bytes(256)
    assert wav[:4] == b"RIFF" and len(wav) > 1000
    switches = sum(1 for m in meta if m["kind"] == "switch")
    print("web selftest OK: %d params (%d switches), cutoff=%g, render=%s, wav=%dB"
          % (len(meta), switches, cutoff, "master/chorus" if full else "dry", len(wav)))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", type=int, default=8765)
    ap.add_argument("--no-browser", action="store_true")
    ap.add_argument("--selftest", action="store_true")
    a = ap.parse_args()
    if a.selftest:
        selftest()
    else:
        serve(a.port, not a.no_browser)

if __name__ == "__main__":
    main()
