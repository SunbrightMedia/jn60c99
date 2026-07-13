#!/usr/bin/env python3
"""bundle_webapp.py — pack the committed jn60c99 web app (gui/web/) into ONE
self-contained HTML file: WASM engine + glue + bank decoder + params + the
factory bank, all inlined (base64 / JS literals). No fetch, no external files —
artifact-CSP-safe. Produces:
  juno-webapp.html       (artifact body: no doctype/html wrapper)
  juno-webapp-local.html (same content wrapped for local browser testing)
The app code itself is the committed source, byte-for-byte except the six
documented seams (imports -> inline, fetch -> literal, wasm fetch ->
instantiateWasm, + embedded-bank button + a __peak probe for headless testing).
"""
import base64, json, re, sys, os

ROOT = "/home/user/jn60c99"
SP = os.path.dirname(os.path.abspath(__file__))
BANK = "/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/ae5e8f1d-presetbankog1.bin"

def rd(p, mode="r"):
    with open(p, mode if mode == "rb" else "r") as f:
        return f.read()

juno_js = rd(f"{ROOT}/gui/web/juno.js")
bank_js = rd(f"{ROOT}/gui/web/bank.js")
index   = rd(f"{ROOT}/gui/web/index.html")
wasm    = rd(f"{ROOT}/gui/web/juno.wasm", "rb")
params  = rd(f"{ROOT}/gui/web/params.json").strip()
bankbin = rd(BANK, "rb")

# --- glue: strip the ES export (module-scope function stays available) ---
assert "export default JunoModule;" in juno_js
juno_js = juno_js.replace("export default JunoModule;", "/* inlined: JunoModule in module scope */")

# --- bank decoder: strip export keyword ---
assert "export function decodeBank" in bank_js
bank_js = bank_js.replace("export function decodeBank", "function decodeBank")

# --- carve up index.html ---
m = re.search(r"<script type=\"module\">\n(.*?)\n</script>\n</html>\n?$", index, re.S)
assert m, "module script not found"
app = m.group(1)

# 1. imports -> inline
assert 'import { decodeBank } from "./bank.js";' in app
app = app.replace('import { decodeBank } from "./bank.js";',
                  "/* decodeBank inlined below (bank.js) */")
assert 'const { default: JunoModule } = await import("./juno.js?v=" + BUILD_VER);' in app
app = app.replace('const { default: JunoModule } = await import("./juno.js?v=" + BUILD_VER);',
                  "/* JunoModule inlined (juno.js) */")

# 2. wasm fetch -> embedded bytes via instantiateWasm
old = 'M = await JunoModule({ locateFile: (path) => path.endsWith(".wasm") ? path + "?v=" + BUILD_VER : path });'
assert old in app
app = app.replace(old, (
    "M = await JunoModule({ instantiateWasm(imports, cb) {\n"
    "    WebAssembly.instantiate(b64bytes(WASM_B64).buffer, imports).then(r => cb(r.instance));\n"
    "    return {};\n"
    "  } });"))

# 3. params.json / param_meta.json fetches -> literals
old = 'const raw = await fetch("params.json").then(r => r.json());'
assert old in app
app = app.replace(old, "const raw = PARAMS_JSON;")
old = 'try { REAL = await fetch("param_meta.json").then(r => r.ok ? r.json() : {}); } catch { REAL = {}; }'
assert old in app
app = app.replace(old, "REAL = {};")

# 4. headless-test probe: track output peak in the audio callback
old = "    for (let i = 0; i < n; i++) { L[i] = clamp1(s[2*i]); R[i] = clamp1(s[2*i+1]); }"
assert old in app
app = app.replace(old, old + "\n"
    "    let pk = 0; for (let i = 0; i < n; i++) { const a = Math.abs(L[i]); if (a > pk) pk = a; }\n"
    "    if (pk > (window.__peak || 0)) window.__peak = pk;   /* test probe */")

# 5. embedded factory bank: decode at boot + a browse button (file upload stays)
old = "boot().catch(e => {"
assert old in app
auto = """function autoBank() {
  const buf = b64bytes(BANK_B64).buffer;
  BANK_RAW = new Uint8Array(buf);
  BANK = decodeBank(buf);
  const btn = document.createElement("button");
  btn.className = "on";
  btn.id = "openbank";
  btn.textContent = "Open factory bank (" + BANK.patch_count + " patches) \\u25b8";
  btn.title = "the embedded factory bank \\u2014 pick a patch, Apply, then play the keys";
  btn.onclick = () => showBank();
  document.querySelector("header .row").appendChild(btn);
  status("ready \\u2014 factory bank embedded (" + BANK.patch_count + " patches): open it, Apply a patch, play the keys");
}
boot().then(autoBank).catch(e => {"""
app = app.replace(old, auto)

# --- assemble ---
b64 = lambda b: base64.b64encode(b).decode()
head = f"""<title>jn60c99 — JUNO-60 C99 synth (in-browser)</title>
"""
# body of original page = everything between </style> ... <script (keep style too)
m2 = re.search(r"(<style>.*?</style>)", index, re.S)
style = m2.group(1)
m3 = re.search(r"</style>\n\n(<header>.*?)<script type=\"module\">", index, re.S)
body = m3.group(1)

script = f"""<script type="module">
/* ---- embedded assets (self-contained: no fetch, artifact-CSP-safe) ---- */
function b64bytes(s) {{
  const bin = atob(s); const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}}
const WASM_B64 = "{b64(wasm)}";
const BANK_B64 = "{b64(bankbin)}";
const PARAMS_JSON = {params};

/* ---- emscripten glue (gui/web/juno.js, verbatim minus the ES export) ---- */
{juno_js}
/* ---- bank decoder (gui/web/bank.js, verbatim minus the export keyword) ---- */
{bank_js}
/* ---- the app (gui/web/index.html module script, six documented seams) ---- */
{app}
</script>"""

artifact = head + style + "\n" + body + script + "\n"
with open(f"{SP}/juno-webapp.html", "w") as f:
    f.write(artifact)
with open(f"{SP}/juno-webapp-local.html", "w") as f:
    f.write("<!doctype html>\n<html lang=\"en\">\n<meta charset=\"utf-8\">\n<body>\n" + artifact + "</body>\n</html>\n")
print(f"bundled: {len(artifact)/1e6:.2f} MB (wasm {len(wasm)//1024} KB, bank {len(bankbin)//1024} KB)")
