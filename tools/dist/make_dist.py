#!/usr/bin/env python3
"""make_dist.py -- the desktop zip: the synth with the plugin's own panel, for the
USER'S OWN machine. It holds Roland's artwork (truth/Script/) and the user's banks:
never publish it, never commit it (it is written to scratchpad/, gitignored).

  JUNO-60/JUNO-60.exe            the starter (tools/dist/launcher.c, cross-compiled):
                                 a web server on 127.0.0.1 only + the browser
  JUNO-60/JUNO-60 (Python).bat   the same with Python's own server (if Windows
                                 blocks the unsigned .exe)
  JUNO-60/README.txt
  JUNO-60/app/gui/skin/          the plugin's GUI (index.html, skin.js, engine.js)
  JUNO-60/app/gui/web/           the C99 port as WebAssembly (juno.js, juno.wasm)
  JUNO-60/app/truth/             Script.xml, Script/*.png, the factory bank
  JUNO-60/app/banks/             the user's banks (scratchpad/userbanks) + banks.json

USAGE  python3 tools/dist/make_dist.py   ->  scratchpad/dist/JUNO-60_C99.zip
"""
import json
import os
import shutil
import subprocess
import sys
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import truth  # noqa: E402

OUT = os.path.join(REPO, 'scratchpad', 'dist')
STAGE = os.path.join(OUT, 'JUNO-60')
ZIP = os.path.join(OUT, 'JUNO-60_C99.zip')

BAT = r"""@echo off
rem JUNO-60 with Python's own web server (use this if Windows blocks JUNO-60.exe).
rem Needs Python 3 on the PATH. Close the server window to quit.
cd /d "%~dp0app"
start "JUNO-60 server (close to quit)" /min python -m http.server 8061 --bind 127.0.0.1
timeout /t 2 /nobreak >nul
start "" "http://127.0.0.1:8061/gui/skin/?zoom=75&banks=../../banks/banks.json"
"""

README = """JUNO-60 -- the C99 port with the plugin's own panel
=====================================================

START
1. Unpack the WHOLE zip into a folder.
2. Double-click JUNO-60.exe. Your browser opens the synth.
   Keep the small black window open while you play. Close it to quit.
3. Click a key or a control. The sound starts on the first click.

If Windows shows "Windows protected your PC": click "More info", then
"Run anyway". (The program is not signed. It is a small web server that
only this computer can reach: 127.0.0.1.)
If you do not want to run the .exe: double-click "JUNO-60 (Python).bat".
It needs Python 3 (you have it for esptool).

Use Chrome or Edge. They have Web MIDI: the synth plays from the first MIDI
keyboard it finds (SETTING > MIDI CTRL Input selects another one).

PLAY
- Knobs and sliders: drag up or down. Shift: fine steps. Mouse wheel: one
  step. Double-click: the default value.
- Levers: click.
- Keys: a click lower on a key plays louder (the plugin's own rule).
- CHORUS: OFF, I, II. For I + II: hold Shift and click I or II, or press I
  and slide onto II.
- PATCH: DEC / INC step through the bank. PATCH opens the patch window:
  click a patch, double-click (or READ) to load it. The arrows next to the
  bank name change the bank: Factory, then your banks. LOAD reads another
  .bin bank file. SAVE writes the bank to a file.
- OPTION: voices (2..8, the plugin's default is 6), engine rate, zoom.

WHAT IT IS
- The sound engine is the C99 port of the Roland Cloud JUNO-60 plugin,
  compiled to WebAssembly. It is bit-exact to the plugin in every test
  of the repository (make verify).
- The panel is drawn from the plugin's own Script.xml and its own sprite
  sheets. Every control writes through the plugin's own model path.

NOT IN THIS VERSION
- The LFO LED and the output meters do not move yet.
- The MIDI CC assign menu, and WRITE / RENAME / NEW / DELETE of patches.
- The SYSTEM-8 buttons (SEND / GET / PLUG-OUT): not part of this port.

PRIVATE
This folder holds Roland's artwork and your own banks. It is for your
own use. Do not share or upload it.
"""


def build_exe(path):
    cc = shutil.which('x86_64-w64-mingw32-gcc')
    if not cc:
        raise SystemExit('x86_64-w64-mingw32-gcc not found (apt-get install mingw-w64)')
    subprocess.check_call([cc, '-O2', '-s', '-Wall', '-o', path, os.path.join(HERE, 'launcher.c'),
                           '-lws2_32', '-lshell32'])


def main():
    truth.verify()                                   # the pinned bytes, artwork included
    if os.path.exists(STAGE):
        shutil.rmtree(STAGE)
    app = os.path.join(STAGE, 'app')
    copies = [(os.path.join(REPO, 'gui', 'skin', f), os.path.join(app, 'gui', 'skin', f))
              for f in ('index.html', 'skin.js', 'engine.js')]
    copies += [(os.path.join(REPO, 'gui', 'web', f), os.path.join(app, 'gui', 'web', f))
               for f in ('juno.js', 'juno.wasm')]
    copies += [(truth.SCRIPT_XML, os.path.join(app, 'truth', 'Script.xml')),
               (truth.BANK, os.path.join(app, 'truth', 'presetbankog1.bin'))]
    sdir = os.path.join(truth.TRUTH_DIR, 'Script')
    copies += [(os.path.join(sdir, f), os.path.join(app, 'truth', 'Script', f))
               for f in sorted(os.listdir(sdir)) if f.endswith('.png')]
    for src, dst in copies:
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        shutil.copyfile(src, dst)
    banks = []
    udir = os.path.join(REPO, 'scratchpad', 'userbanks')
    if os.path.isdir(udir):
        os.makedirs(os.path.join(app, 'banks'), exist_ok=True)
        for f in sorted(os.listdir(udir)):
            if not f.lower().endswith('.bin'):
                continue
            name = os.path.splitext(f)[0].lstrip('~').strip()
            dst = name + '.bin'
            shutil.copyfile(os.path.join(udir, f), os.path.join(app, 'banks', dst))
            banks.append({'name': name, 'file': dst})
    os.makedirs(os.path.join(app, 'banks'), exist_ok=True)
    with open(os.path.join(app, 'banks', 'banks.json'), 'w') as f:
        json.dump(banks, f, indent=1)
    build_exe(os.path.join(STAGE, 'JUNO-60.exe'))
    with open(os.path.join(STAGE, 'JUNO-60 (Python).bat'), 'w', newline='\r\n') as f:
        f.write(BAT)
    with open(os.path.join(STAGE, 'README.txt'), 'w', newline='\r\n') as f:
        f.write(README)
    if os.path.exists(ZIP):
        os.remove(ZIP)
    with zipfile.ZipFile(ZIP, 'w', zipfile.ZIP_DEFLATED) as z:
        for root, _, files in os.walk(STAGE):
            for fn in sorted(files):
                p = os.path.join(root, fn)
                z.write(p, os.path.relpath(p, OUT))
    print('banks: %d user + Factory' % len(banks))
    print('wrote %s (%d bytes)' % (ZIP, os.path.getsize(ZIP)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
