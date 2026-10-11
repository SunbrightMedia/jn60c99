#!/usr/bin/env python3
"""jx_patch_manager_gate.py -- the JX-3P's patch window: the plugin's patch manager vs the port's (JX-24; jx3p/docs/
HOST_LAYER.md 3r). The JUNO-60's gate (tools/verify/patch_manager_gate.py, CLAIMS A39) run on the JX:

PLUGIN  jx3p/tools/jx_pm_emu.py -- the JX plugin booted (jx_host_emu), its own key handler, mouse handler, button
        functions, save, timer tick on its own list control, the dialogs answered by the script, a writable file
        system holding the JX's folders and files (the factory bank jx3p/truth/preset_bank_1.bin)
PORT    gui/juno_pm.c built with the JX bridge (jx3p/gui/jx_pm_glue.c, -DJPM_PRODUCT="PG-JX3P"): the same commands,
        the same files and answers
Compared after every command, as the JUNO's: every bank's every history state, the cursors, the selection, the
clipboard, the number format, the autosave counter, the view's record image and values, the window's values, the
dialogs asked, the file operations, every file, the model calls. The bank name control's mouse is left out: its
button's frame is the art's (SCOPE_AUDIT row 20); its rename and menu are reached by Ctrl+W / Ctrl+B.

usage: jx_patch_manager_gate.py [--seed N] [--steps N] [--tooth N]
"""
import ctypes
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import patch_manager_gate as G                                 # noqa: E402

MOD = 'C:\\Program Files\\Common Files\\VST3\\JX-3P.vst3\\Contents\\x86_64-win'
G.DATA = 'C:\\ProgramData\\Roland Cloud\\JX-3P'
G.PATCH = MOD + '\\Patch'
G.OLD = 'C:\\ProgramData\\Roland\\JX-3P'
G.SCRIPT = MOD + '\\Script'
G.WATCH = [G.DATA, G.PATCH, G.OLD, G.DESK]
G.LIST = (331, 35, 1615, 515)                  # jx3p/truth/Script.xml panel patch: control patch 331,35 size 1284,480
G.BANKNAME = (54, 33, 303, 63)                 # patchBankName 54,33 size 249,30
G.BANKBTN = None                               # its button: a frame of buttonArrowR.png -- the art's
G.BAD_HDR = b'KoaBankFile00003PG-JX3P'
G.FACTORY_PATH = os.path.join(REPO, 'jx3p', 'truth', 'preset_bank_1.bin')
G.REF_TAG = 'jx_'
G.GATE_SCRIPT = os.path.abspath(__file__)
LIBDIR = os.path.join(REPO, 'scratchpad', 'jx_pm')
SRCS = ['jx3p/gui/jx_pm_glue.c', 'gui/juno_pm.c', 'jx3p/gui/jx_bridge.c',
        'jx3p/src/jx_voice_render.c', 'jx3p/src/jx_voice_helpers.c', 'jx3p/src/jx_master_render.c', 'jx3p/src/jx_ftz.c']


def lib_path(tooth):
    return os.path.join(LIBDIR, 'libjx_pm%s.so' % ('_t%s' % tooth if tooth else ''))


def build(tooth=None):
    os.makedirs(LIBDIR, exist_ok=True)
    out = lib_path(tooth)
    r = subprocess.run(['cc', '-std=c99', '-O2', '-ffp-contract=off', '-fno-strict-aliasing', '-shared', '-fPIC',
                        '-DJPM_PRODUCT="PG-JX3P"', '-o', out] + (['-DPM_TOOTH=%s' % tooth] if tooth else []) +
                       [os.path.join(REPO, s) for s in SRCS] + ['-lm'], capture_output=True, text=True)
    if r.returncode:
        raise SystemExit('the JX patch manager build failed: ' + r.stderr[-2000:])
    return out


def port_init(L):
    """the port booted as the plugin boots (jx3p_product_init on the 96 kHz guest image); the bridge is one
    instance: no context"""
    import jx_guest
    L.jx3p_product_init.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_int]
    if L.jx3p_product_init(jx_guest.path(96).encode(), G.FACTORY_PATH.encode(), 48000) < 0:
        raise SystemExit('jx3p_product_init failed')
    return None


G.PORT_LIB = lib_path
G.PORT_INIT = port_init
G.TOOTH_BUILD = build

if __name__ == '__main__':
    if '--plugin' in sys.argv:
        import jx_pm_emu
        G.PM_EMU = jx_pm_emu.M
    elif '--port' not in sys.argv:
        build()                                # the port's library from the current sources
    sys.exit(G.main())
