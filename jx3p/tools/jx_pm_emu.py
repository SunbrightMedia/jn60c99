#!/usr/bin/env python3
"""jx_pm_emu.py -- the JX-3P's patch manager (its patch window's librarian) driven in the booted plugin (JX-24;
jx3p/docs/HOST_LAYER.md 3r). PLUMBING ONLY: tools/verify/patch_manager_emu.py (the JUNO-60's, CLAIMS A39) loaded a
second time with the JX's PROFILE below, on the JX host oracle (jx_host_emu: its wrapper, host process and JXHost).

Every address is the JX twin of the JUNO's (jx3p/tools/fw_map.py): the functions -- the list's key and mouse
handlers, the buttons' functions, the manager, the save, the tick, the model's set / notify / commit, the record
load and the serializer, the controls' registrations, the record index, the view's values, the bank name refresh,
the text edit and message services -- equal in their normalized code (70 of 77 at -0x120; the rest found by their
code); the two vtables by the mouse handlers in their slot 9; the data (the number format, the menu service's
override pointer) by the same instruction of the twin function. Without the JX art the controls' images are blank
ones of the Script.xml geometry (no PNG sizes).

USE (Unicorn only)    import jx_pm_emu; P = jx_pm_emu.M.PlugPM(files=[...])
"""
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'tools', 'verify'))
import jx_host_emu as X                                        # noqa: E402

D = -0x120                                                     # the shifted region's offset (JX = JUNO + D)
PM_PROFILE = dict(
    H=X.H, W=X.W, HOST=X.JXHost,
    HEAP=(0x310000000, 0x320000000),                           # the JX's heap is larger: searched to its top
    LIST_VT=0x99F958, BANKNAME_VT=0x99FC40, MENU_OVERRIDE=0xCEA428,
    KEY_ACTION=0x3277A0, MOUSE=0x327C50, MP_FN=0x322D40, MPB_FN=0x323EB0,
    TEXTEDIT=0x2AD3E0, MESSAGE=0x2926F0, PM_GET=0x330BF0, SAVE_ALL=0x336EB0, TICK=0x32F160,
    FORMAT_G=0xC7BB50, BANK_MOUSE=0x33EF80,
    SET=0x283C90, NOTIFY=0x2852A0, COMMIT=0x283000, RLOAD=0x335730,
    REG_LIST=0x3307A0, REG_BANK=0x330790, REC_ID=0x319B30, VALUES=0x413140,
    TRIO=(0x285200, 0x2852A0, 0x283000), BANK_REFRESH=0x33F410, SERIALIZE=0x335870,
    CODE=tuple((a + D, b + D) for a, b in ((0x322E60, 0x324900), (0x3262C0, 0x326330), (0x3278C0, 0x328550),
                                           (0x32C000, 0x335850), (0x335990, 0x33F600))),
    OLD_DIR='C:\\ProgramData\\Roland\\JX-3P',
    PNG=None,                                                  # no JX art: the wrapper's blank geometry
)


def _load(name, path, **inject):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    mod.__dict__.update(inject)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


M = _load('jx_patch_manager_emu', os.path.join(REPO, 'tools', 'verify', 'patch_manager_emu.py'), PM_PROFILE=PM_PROFILE)

if __name__ == '__main__':
    import time
    t0 = time.time()
    P = M.PlugPM(files=[])
    print('booted %.0fs: manager 0x%x, list 0x%x, bank name 0x%x, view 0x%x; window %s; banks %d' % (
        time.time() - t0, P.pm, P.lst, P.bnc, P.view, P.window(), len(P.snapshot(False)['banks'])))
