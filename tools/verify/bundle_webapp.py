#!/usr/bin/env python3
"""bundle_webapp.py — pack the web app into a single self-contained HTML file
(no fetch, no imports: artifact-CSP-safe), in two variants:

  tools/verify/juno-webapp.html        artifact body (starts at <title>; the
                                       claude.ai Artifact publisher wraps it in
                                       its own doctype/head/body skeleton)
  tools/verify/juno-webapp-local.html  standalone (adds the doctype/html/body
                                       prefix) — served by verify_webapp.mjs to
                                       headless Chromium for the E2E check

Inputs (all from the current tree — run gui/web/build.sh first so juno.js /
juno.wasm are fresh): gui/web/index.html + juno.js + juno.wasm + bank.js, and
the factory bank via tools/verify/truth.py (never a hardcoded path).

Every transformation anchors on an EXACT string from index.html and fails
loudly if the anchor is missing or ambiguous, so UI drift can't silently
produce a broken bundle. The __peak probe is test plumbing for
verify_webapp.mjs (audible-output assertion), not a UI feature.
"""
import base64, json, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import truth   # factory bank path + checksum authority

# Optional extra banks baked into the bundle for evaluation (NOT part of the port):
#   --extra-bank Name=/abs/path/to/bank.bin   (repeatable)
# Each adds an "Open <Name> bank" button next to the factory one. The bank files
# themselves are NOT committed; passing none produces the standard factory-only app.
EXTRA_BANKS = []
_args = sys.argv[1:]
while _args:
    a = _args.pop(0)
    if a == '--extra-bank':
        if not _args or '=' not in _args[0]:
            raise SystemExit('bundle_webapp: --extra-bank needs Name=/path/to/bank.bin')
        name, path = _args.pop(0).split('=', 1)
        if not os.path.exists(path):
            raise SystemExit('bundle_webapp: extra bank not found: %s' % path)
        EXTRA_BANKS.append((name, path))
    else:
        raise SystemExit('bundle_webapp: unknown argument %r' % a)

def rd(path, mode='r'):
    with open(path, mode if 'b' in mode else 'r', encoding=None if 'b' in mode else 'utf-8') as f:
        return f.read()

def b64(path):
    return base64.b64encode(rd(path, 'rb')).decode('ascii')

def replace_once(hay, needle, repl, what):
    n = hay.count(needle)
    if n != 1:
        raise SystemExit("bundle_webapp: anchor %r for %s found %d times (want exactly 1) — "
                         "index.html drifted; update the anchor" % (needle[:60], what, n))
    return hay.replace(needle, repl)

idx = rd(os.path.join(ROOT, 'gui/web/index.html'))

# 1. strip the standalone prologue: keep from <title> on (artifact variant)
t = idx.find('<title>')
if t < 0: raise SystemExit('bundle_webapp: no <title> in index.html')
page = idx[t:]

# 2. embedded assets replace the bank.js module import
juno_js = rd(os.path.join(ROOT, 'gui/web/juno.js'))
if not juno_js.rstrip().endswith('export default JunoModule;'):
    raise SystemExit('bundle_webapp: juno.js tail is not "export default JunoModule;" — emcc output shape changed')
juno_inline = juno_js.rstrip()[:-len('export default JunoModule;')].rstrip()

bank_js = rd(os.path.join(ROOT, 'gui/web/bank.js'))
if bank_js.count('export ') != 1:
    raise SystemExit('bundle_webapp: bank.js should contain exactly one "export "')
bank_inline = bank_js.replace('export ', '', 1)

assets = (
    '/* ---- embedded assets (self-contained: no fetch, artifact-CSP-safe) ---- */\n'
    'function b64bytes(s) {\n'
    '  const bin = atob(s); const out = new Uint8Array(bin.length);\n'
    '  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);\n'
    '  return out;\n'
    '}\n'
    'const WASM_B64 = "%s";\n'
    'const BANK_B64 = "%s";\n'
    '/* extra evaluation banks (bundler --extra-bank; empty in the standard build) */\n'
    'const EXTRA_BANKS = %s;\n'
    '\n'
    '/* ---- emscripten glue (gui/web/juno.js, verbatim minus the ES export) ---- */\n'
    '%s\n'
    '\n'
    '/* ---- bank decoder (gui/web/bank.js, verbatim minus the export keyword) ---- */\n'
    '%s\n'
) % (b64(os.path.join(ROOT, 'gui/web/juno.wasm')), b64(truth.BANK),
     json.dumps([{'name': n, 'b64': b64(p)} for n, p in EXTRA_BANKS]),
     juno_inline, bank_inline)

page = replace_once(page, 'import { decodeBank } from "./bank.js";', assets, 'embedded assets')

# 3. module load -> instantiateWasm from the embedded bytes
page = replace_once(
    page,
    'const { default: JunoModule } = await import("./juno.js?v=" + BUILD_VER);\n'
    '  M = await JunoModule({ locateFile: (path) => path.endsWith(".wasm") ? path + "?v=" + BUILD_VER : path });',
    '/* JunoModule inlined (juno.js) */\n'
    '  M = await JunoModule({ instantiateWasm(imports, cb) {\n'
    '    WebAssembly.instantiate(b64bytes(WASM_B64).buffer, imports).then(r => cb(r.instance));\n'
    '    return {};\n'
    '  } });',
    'module load shim')

# 4. __peak test probe in the audio callback (verify_webapp.mjs asserts real audio)
page = replace_once(
    page,
    'for (let i = 0; i < n; i++) { L[i] = clamp1(s[2*i] * g); R[i] = clamp1(s[2*i+1] * g); }',
    'for (let i = 0; i < n; i++) { L[i] = clamp1(s[2*i] * g); R[i] = clamp1(s[2*i+1] * g); }\n'
    '    let pk = 0; for (let i = 0; i < n; i++) { const a = Math.abs(L[i]); if (a > pk) pk = a; }\n'
    '    if (pk > (window.__peak || 0)) window.__peak = pk;   /* test probe */',
    '__peak probe')

# 5. boot -> boot + embedded factory bank auto-load
page = replace_once(
    page,
    'boot().then(initMIDI).catch(e => { status("ERROR: "+e); $("#warn").textContent = e; console.error(e); });',
    'function autoBank() {\n'
    '  const buf = b64bytes(BANK_B64).buffer;\n'
    '  BANK_RAW = new Uint8Array(buf);\n'
    '  BANK = decodeBank(buf);\n'
    '  const btn = document.createElement("button");\n'
    '  btn.className = "on";\n'
    '  btn.id = "openbank";\n'
    '  btn.textContent = "Open factory bank (" + BANK.patch_count + " patches) \\u25b8";\n'
    '  btn.title = "the embedded factory bank \\u2014 pick a patch, Apply, then play the keys";\n'
    '  btn.onclick = () => {          /* re-select factory bytes: an extra bank may be active */\n'
    '    const b = b64bytes(BANK_B64).buffer;\n'
    '    BANK = decodeBank(b);\n'
    '    BANK_RAW = new Uint8Array(b);\n'
    '    showBank();\n'
    '  };\n'
    '  document.querySelector("header .row").appendChild(btn);\n'
    '  // Extra evaluation banks (bundler --extra-bank): one button each; selecting\n'
    '  // one swaps BANK/BANK_RAW (validated first) and opens the patch picker.\n'
    '  for (const xb of EXTRA_BANKS) {\n'
    '    const xbtn = document.createElement("button");\n'
    '    xbtn.id = "openbank_" + xb.name.replace(/\\W+/g, "_");\n'
    '    xbtn.textContent = "Open " + xb.name + " bank \\u25b8";\n'
    '    xbtn.title = "embedded evaluation bank \\u2014 for testing, not part of the port";\n'
    '    xbtn.onclick = () => {\n'
    '      const b = b64bytes(xb.b64).buffer;\n'
    '      BANK = decodeBank(b);            /* validate before retaining */\n'
    '      BANK_RAW = new Uint8Array(b);\n'
    '      showBank();\n'
    '      status(xb.name + " bank selected (" + BANK.patch_count + " patches) \\u2014 pick a patch, Apply, then play");\n'
    '    };\n'
    '    document.querySelector("header .row").appendChild(xbtn);\n'
    '  }\n'
    '  // Load patch 0 so the front-panel sliders show a real patch\'s bytes out of the box.\n'
    '  applyPatchIndex(0);\n'
    '  status("ready \\u2014 factory bank embedded (" + BANK.patch_count + " patches): patch 0 loaded, '
    'tweak the sliders or open the bank to pick another, then play the piano keys");\n'
    '}\n'
    'boot().then(initMIDI).then(autoBank).catch(e => { status("ERROR: "+e); $("#warn").textContent = e; console.error(e); });',
    'autoBank tail')

# 6. drop the trailing </html> (the artifact wrapper closes the document)
page = page.rstrip()
if page.endswith('</html>'):
    page = page[:-len('</html>')].rstrip() + '\n'

art = os.path.join(HERE, 'juno-webapp.html')
loc = os.path.join(HERE, 'juno-webapp-local.html')
with open(art, 'w', encoding='utf-8') as f:
    f.write(page)
with open(loc, 'w', encoding='utf-8') as f:
    f.write('<!doctype html>\n<html lang="en">\n<meta charset="utf-8">\n<body>\n' + page)
print('bundled: %s (%d bytes) + -local variant' % (art, len(page)))
