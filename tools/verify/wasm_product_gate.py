#!/usr/bin/env python3
"""wasm_product_gate.py -- the web app's OWN call sequence, native vs the
delivered WASM (gui/web/juno.wasm), every render compared.

The app (gui/web/index.html) boots the engine as the plugin does
(juno_gui_create, juno_gui_plugin_init, a 4 s warm-up), loads presets as the
plugin's patch browser does (juno_gui_load_patch, then the host tempo), plays
notes, and moves panel parameters through the host entry (juno_gui_host_set;
the arp row's switch / mode / range are ARPEGGIO SW / TYPE / STEP host edits,
plus juno_gui_arp_config for the host-side tempo and gate); the skin's MIDI input
(juno_gui_host_param: CC, aftertouch and bend as the DAW maps them) and its CC
assign menu (juno_gui_cc_learn / _forget, the UI-timer drain, the state). Those native paths
are graded against the plugin by state_load_gate.py (A22) and
host_edit_gate.py (A20); this gate grades the DELIVERED artifact against them:
the same op list runs through libjuno.so (this process, ctypes) and through
the WASM (node, tools/verify/wasm_golden.mjs --script), and the FNV-1a-64 of
every render must agree -- and of every UI-timer tick after it: the LED's frame,
both meters' states, fills and blits (CLAIMS A37; the dB scale is each build's
own log10, emscripten's and glibc's). wasm_golden.mjs with no argument is the isolation
control: the 44.1 kHz recall corpus whose hashes the native build made.

The harness is plumbing: an op list of API calls, no plugin logic.

    python3 tools/verify/wasm_product_gate.py           (run gui/web/build.sh first)
    python3 tools/verify/wasm_product_gate.py --tooth   (needs emcc on PATH)
    python3 tools/verify/wasm_product_gate.py --native-only   (the native side + reach)

REACH: every chain must be audible natively -- half its renders, and the
render after its first key, above 1e-3 (every chain starts on an ordinary
patch): the gate once passed while the app's first note after start-up was
silent -- native and WASM agreed on the silence (the warm-up skipped the
voice-count sync).

TOOTH (--tooth): a WASM built from a mutated bridge (the patch load reversed),
the app flow without juno_gui_plugin_init, the load as the recall model
(juno_gui_apply_bank), a WASM with another meter floor, a WASM whose MIDI CC
value is one off, and a native bridge whose
warm-up renders nothing (the reach guard) must each FAIL; the control must PASS."""
import ctypes, glob, json, os, shutil, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import truth, freshlib

WEB = os.path.join(REPO, 'gui', 'web')
SCRATCH = os.path.join(REPO, 'scratchpad')
MJS = os.path.join(HERE, 'wasm_golden.mjs')


def wasm_stale(web):
    """the delivered juno.wasm must be newer than every engine source and the build script"""
    w = os.path.join(web, 'juno.wasm')
    if not os.path.exists(w):
        return 'missing'
    srcs = (glob.glob(os.path.join(REPO, 'src', '*.[ch]')) +
            [os.path.join(REPO, 'gui', 'juno_bridge.c'), os.path.join(WEB, 'build.sh')])
    newer = [os.path.relpath(s, REPO) for s in srcs if os.path.getmtime(s) > os.path.getmtime(w)]
    return ', '.join(newer[:5]) if newer else None


def fnv1a64(b):
    h = 0xcbf29ce484222325
    for x in b:
        h = ((h ^ x) * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF
    return '%016x' % h


def host_table(lib):
    n = lib.juno_gui_host_count()
    return [(lib.juno_gui_host_name(i).decode(), lib.juno_gui_host_min(i), lib.juno_gui_host_max(i))
            for i in range(n)]


def chains(H):
    """the app's flows; H = [(name, min, max)] of the host parameters"""
    idx = {n: i for i, (n, lo, hi) in enumerate(H)}

    def boot(rate):
        # as the app: plugin_init (the switch ON, as the plugin's start-up), then
        # the page's velocity switch (default ON), then the warm-up
        return [['create', rate], ['plugin_init'], ['vel_sw', 1], ['warmup', rate * 4]]

    def chord(root, n, vel=100):
        # the app's keys enter through the wrapper's MIDI path (juno_gui_midi_note_on)
        return [['mon', root, vel], ['render', n], ['mon', root + 4, vel], ['mon', root + 7, vel]]

    def release(root):
        return [['moff', root], ['moff', root + 4], ['moff', root + 7]]

    out = []
    for name, rate, patches in (('loads_48000', 48000, range(64)), ('loads_44100', 44100, range(0, 64, 3)),
                                ('loads_96000', 96000, range(0, 64, 9))):
        ops = boot(rate)
        ops += chord(60, rate // 5) + [['render', rate // 5]] + release(60) + [['render', rate // 2]]
        held = None
        for j, k in enumerate(patches):
            root = 48 + (k * 5) % 24
            ops += [['load', k], ['tempo', 120]] + chord(root, rate // 10) + [['render', rate // 10]]
            if held is not None:    # the chord held across this load is let go now
                ops += release(held)
                held = None
            if j % 8 == 7:          # every 8th chord is held across the next load
                held = root
            else:
                ops += release(root) + [['render', rate // 10]]
        if held is not None:
            ops += release(held)
        ops += chord(55, rate // 10, 37) + [['render', rate // 10]] + release(55) + [['render', rate // 10]]
        ops += [['vel_sw', 0]] + chord(55, rate // 10, 37) + [['render', rate // 10]] + release(55) + [['render', rate]]
        out.append({'name': name, 'ops': ops})
    # the panel: every host parameter to its min, max and middle with a chord held
    for name, rate, patch in (('panel_48000', 48000, 12), ('panel_44100', 44100, 40)):
        ops = boot(rate) + [['load', patch], ['tempo', 120]] + chord(60, 600)
        for i, (n, lo, hi) in enumerate(H):
            for v in (lo, hi, (lo + hi) // 2):
                ops += [['host', i, v], ['tempo', 120], ['render', 1200]]
        ops += release(60) + [['render', rate]]
        out.append({'name': name, 'ops': ops})
    # the arp row: switch on with keys held, change mode and range, run, switch off
    sw, ty, st = idx['ARPEGGIO SW'], idx['ARPEGGIO TYPE'], idx['ARPEGGIO STEP']
    ops = boot(48000) + [['load', 5], ['tempo', 120]] + chord(57, 2400) + [['render', 2400]]
    for on, t, s, mode, octv in ((1, 0, 0, 0, 1), (1, 2, 1, 1, 2), (1, 1, 2, 2, 3), (0, 1, 2, 2, 3), (1, 1, 2, 2, 3)):
        ops += [['host', ty, t], ['host', st, s], ['host', sw, on], ['arp', on, mode, octv, 120.0, 0.6],
                ['render', 48000]]
    ops += release(57) + [['render', 24000],
            ['host', sw, 0], ['arp', 0, 2, 3, 120.0, 0.6], ['render', 24000]]
    out.append({'name': 'arp_48000', 'ops': ops})
    # the skin's MIDI input (DAW mapping: CC n -> base + n, aftertouch + 128, bend + 129) and its CC
    # assign menu (CLAIMS A38): learns that take a CC at the drain, the CC moving its parameter, the
    # mod wheel, the pedal, bend, aftertouch, a forget, CC 123, a panel edit; the state after
    ops = boot(48000) + [['load', 21], ['tempo', 120]] + chord(48, 2400) + [['render', 2400]]
    for pid, cc in ((6291518, 20), (6291514, 21), (6291460, 22), (6291524, 1)):
        ops += [['learn', pid], ['hcc', cc, 64], ['render', 960], ['uitick'], ['render', 960], ['state']]
        for v in (0, 127, 33):
            ops += [['hcc', cc, v], ['render', 960], ['uitick'], ['render', 960]]
    ops += [['hcc', 64, 127], ['hat', 90], ['hbend', 12000], ['render', 4800], ['uitick']] + release(48)
    ops += [['render', 4800], ['hcc', 64, 0], ['hbend', 8192], ['render', 4800], ['uitick'], ['state']]
    ops += [['forget', 6291518], ['hcc', 20, 0], ['render', 960], ['uitick'], ['render', 960]]
    ops += [['model', 6291514, 40], ['commit']] + chord(55, 2400) + [['render', 2400], ['hcc', 123, 0],
                                                                     ['render', 4800], ['uitick'], ['state']]
    out.append({'name': 'midi_cc_48000', 'ops': ops})
    # the app's 50 ms UI timer after every render: the LED's and both meters' ticks (CLAIMS A37)
    for ch in out:
        ops = []
        for op in ch['ops']:
            ops.append(op)
            if op[0] == 'render':
                ops.append(['meter'])
        ch['ops'] = ops
    return out


# the meters as Script.xml places them (functionUpperOrig at 56,0: barGraphL / barGraphR at
# 1516,52 / 1516,69, 228 x 10, direction 1, decay 8, fade 10) and the LED's 24 frames
METER_RECT = ((1572, 52, 1800, 62), (1572, 69, 1800, 79))
LED_FRAMES, DECAY, FADE, BLITS = 24, 8, 10, 64


def meter_tick(lib, c, st):
    """one tick of the app's LED and meters: their ints, in order (st: the meters' states)"""
    out = [lib.juno_gui_lfo_led_frame(c, LED_FRAMES)]
    fill = (ctypes.c_int * 4)()
    blits = (ctypes.c_int * (7 * BLITS))()
    for ch in (0, 1):
        rect = (ctypes.c_int * 4)(*METER_RECT[ch])
        st[ch] = lib.juno_gui_meter_tick(c, ch, DECAY, st[ch], rect, 1, fill)
        nb = min(lib.juno_gui_bar_draw(rect, fill, 1, FADE, blits, BLITS), BLITS)
        out += [st[ch]] + list(fill) + [nb] + list(blits[:7 * nb])
    return out


def run_native(lib, bank, chain):
    c, hashes, sound, first = None, [], [], None
    st, frames, lit = [0, 0], set(), 0
    for op in chain['ops']:
        k = op[0]
        if k == 'meter':
            v = meter_tick(lib, c, st)
            hashes.append(fnv1a64(b''.join(x.to_bytes(4, 'little', signed=True) for x in v)))
            frames.add(v[0])
            lit += st[0] > 0
            continue
        if k == 'create':
            c = lib.juno_gui_create(ctypes.c_float(op[1]), 0)
            st = [0, 0]
        elif k == 'vel_sw':
            lib.juno_gui_set_kbd_velocity(c, op[1])
        elif k == 'plugin_init':
            lib.juno_gui_plugin_init(c)
        elif k == 'warmup':
            lib.juno_gui_warmup(c, op[1])
        elif k == 'load':
            lib.juno_gui_load_patch(c, bank, len(bank), op[1])
        elif k == 'tempo':
            lib.juno_gui_set_tempo(c, ctypes.c_float(op[1]))
        elif k == 'on':
            lib.juno_gui_note_on(c, op[1], op[2])
        elif k == 'off':
            lib.juno_gui_note_off(c, op[1])
        elif k == 'mon':
            lib.juno_gui_midi_note_on(c, op[1], op[2])
            if first is None:
                first = len(sound)          # the render after the chain's first key
        elif k == 'moff':
            lib.juno_gui_midi_note_off(c, op[1])
        elif k == 'host':
            lib.juno_gui_host_set(c, op[1], op[2])
        elif k == 'arp':
            lib.juno_gui_arp_config(c, op[1], op[2], op[3], ctypes.c_float(op[4]), ctypes.c_float(op[5]))
        elif k in ('hcc', 'hat', 'hbend'):          # the skin's MIDI input (engine.js midiIn)
            base = lib.juno_gui_midi_base()
            lib.juno_gui_host_param(c, base + op[1] if k == 'hcc' else base + (128 if k == 'hat' else 129), 0,
                                    op[2] / 127 if k == 'hcc' else op[1] / 127 if k == 'hat' else op[1] / 16383)
        elif k == 'learn':
            lib.juno_gui_cc_learn(c, op[1])
        elif k == 'forget':
            lib.juno_gui_cc_forget(c, op[1])
        elif k == 'uitick':
            lib.juno_gui_ui_tick(c)
        elif k == 'model':
            lib.juno_gui_model_set(c, op[1], op[2])
        elif k == 'commit':
            lib.juno_gui_commit(c)
        elif k == 'state':
            buf = ctypes.create_string_buffer(4 + 8 * 256)
            n = lib.juno_gui_state_save(c, buf, len(buf))
            hashes.append(fnv1a64(buf.raw[:max(n, 0)]))
            continue
        elif k == 'render':
            buf = (ctypes.c_float * (2 * op[1]))()
            lib.juno_gui_render(c, buf, op[1])
            hashes.append(fnv1a64(bytes(buf)))
            sound.append(max(max(buf), -min(buf)))
        else:
            raise SystemExit('unknown op %r' % (op,))
    lib.juno_gui_destroy(c)
    chain['peaks'] = sound
    chain['first'] = sound[first] if first is not None and first < len(sound) else 0.0
    chain['meters'] = (len(frames), lit)
    return hashes


def load_lib():
    lib = ctypes.CDLL(freshlib.check())
    V = ctypes.c_void_p
    lib.juno_gui_create.restype = V
    lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
    for f, a in (('juno_gui_set_kbd_velocity', [V, ctypes.c_int]), ('juno_gui_plugin_init', [V]),
                 ('juno_gui_warmup', [V, ctypes.c_int]),
                 ('juno_gui_load_patch', [V, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]),
                 ('juno_gui_set_tempo', [V, ctypes.c_float]),
                 ('juno_gui_note_on', [V, ctypes.c_int, ctypes.c_int]), ('juno_gui_note_off', [V, ctypes.c_int]),
                 ('juno_gui_midi_note_on', [V, ctypes.c_int, ctypes.c_int]), ('juno_gui_midi_note_off', [V, ctypes.c_int]),
                 ('juno_gui_host_set', [V, ctypes.c_int, ctypes.c_int]),
                 ('juno_gui_arp_config', [V, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_float, ctypes.c_float]),
                 ('juno_gui_render', [V, ctypes.POINTER(ctypes.c_float), ctypes.c_int]),
                 ('juno_gui_destroy', [V]), ('juno_gui_host_min', [ctypes.c_int]),
                 ('juno_gui_host_max', [ctypes.c_int]), ('juno_gui_lfo_led_frame', [V, ctypes.c_int]),
                 ('juno_gui_meter_tick', [V, ctypes.c_int, ctypes.c_int, ctypes.c_int, V, ctypes.c_int, V]),
                 ('juno_gui_bar_draw', [V, V, ctypes.c_int, ctypes.c_int, V, ctypes.c_int]),
                 ('juno_gui_host_param', [V, ctypes.c_uint32, ctypes.c_int, ctypes.c_double]),
                 ('juno_gui_cc_learn', [V, ctypes.c_uint32]), ('juno_gui_cc_forget', [V, ctypes.c_uint32]),
                 ('juno_gui_ui_tick', [V]), ('juno_gui_model_set', [V, ctypes.c_uint32, ctypes.c_int32]),
                 ('juno_gui_commit', [V]), ('juno_gui_state_save', [V, V, ctypes.c_int])):
        getattr(lib, f).argtypes = a
    lib.juno_gui_midi_base.restype = ctypes.c_uint32
    lib.juno_gui_host_name.restype = ctypes.c_char_p
    lib.juno_gui_host_name.argtypes = [ctypes.c_int]
    return lib


AUDIBLE = 1e-3      # REACH, not a grade: identical silence proves nothing


def make_script():
    """the op lists and the native hashes, written for the WASM side; returns
    (path, reach) -- reach is False when a chain is mostly silent natively"""
    lib = load_lib()
    bank = open(truth.BANK, 'rb').read()
    sc = {'bank': truth.BANK, 'chains': chains(host_table(lib))}
    reach = True
    for ch in sc['chains']:
        ch['hashes'] = run_native(lib, bank, ch)
        pk, f1 = ch.pop('peaks'), ch.pop('first')
        nf, lit = ch.pop('meters')
        aud = sum(p > AUDIBLE for p in pk)
        ok = aud * 2 >= len(pk) and f1 > AUDIBLE
        mok = nf >= 2 and lit * 4 >= len(pk)       # REACH of the meters: the LED moves, the bar lights
        reach &= ok and mok
        print('native %-12s %3d ops, %3d renders, %3d audible (peak %.3g, first key %.3g); LED %d frames, '
              'meter lit at %d ticks%s' % (
                  ch['name'], len(ch['ops']), len(pk), aud, max(pk), f1, nf, lit, '' if ok and mok else
                  '  REACH: silent -- comparing silence proves nothing'), flush=True)
    os.makedirs(SCRATCH, exist_ok=True)
    path = os.path.join(SCRATCH, 'wasm_product_script.json')
    json.dump(sc, open(path, 'w'))
    return path, reach


def run_wasm(script, web=WEB, tooth=None):
    env = dict(os.environ)
    env.pop('WASM_SCRIPT_TOOTH', None)
    if tooth:
        env['WASM_SCRIPT_TOOTH'] = tooth
    r = subprocess.run(['node', MJS, '--script', script, '--dir', web], env=env, capture_output=True, text=True)
    print((r.stdout + r.stderr).rstrip())
    return r.returncode


def check(native_only=False):
    if not native_only:
        st = wasm_stale(WEB)
        if st:
            print('STALE-GUARD: gui/web/juno.wasm is older than: %s -- run gui/web/build.sh first' % st)
            return 1
    script, reach = make_script()
    rc = 0 if native_only else run_wasm(script)
    print('=== WASM PRODUCT PATH: the app\'s own calls, native vs the delivered WASM, every render ===')
    print('GATE: %s' % ('PASS' if rc == 0 and reach else 'FAIL'))
    return 0 if rc == 0 and reach else 1


def mutant_wasm(name, rel, old, new):
    """a WASM built by gui/web/build.sh from a tree whose `rel` carries one edit"""
    d = os.path.join(SCRATCH, 'wasm_tooth_' + name)
    if os.path.exists(d):
        shutil.rmtree(d)
    for sub in ('src', 'gui'):
        shutil.copytree(os.path.join(REPO, sub), os.path.join(d, sub), symlinks=True)
    os.makedirs(os.path.join(d, 'docs'))
    shutil.copy(os.path.join(REPO, 'docs', 'COEFF_PARAM_MAP.md'), os.path.join(d, 'docs'))
    p = os.path.join(d, rel)
    s = open(p).read()
    if s.count(old) != 1:
        raise SystemExit('TOOTH %s: anchor occurs %d times -- the tooth is stale' % (name, s.count(old)))
    open(p, 'w').write(s.replace(old, new))
    r = subprocess.run(['bash', os.path.join(d, 'gui', 'web', 'build.sh')], capture_output=True, text=True)
    if r.returncode:
        raise SystemExit('TOOTH %s: the mutant WASM does not build\n%s' % (name, (r.stdout + r.stderr)[-2000:]))
    return os.path.join(d, 'gui', 'web')


def tooth():
    if shutil.which('emcc') is None:
        print('--tooth needs emcc on PATH (source emsdk_env.sh)')
        return 2
    script, reach = make_script()
    res = [('reach', 'every chain audible natively', reach, 'PASS')]
    print('--- control: wasm_golden.mjs, the recall corpus the native build hashed (must PASS)')
    r = subprocess.run(['node', MJS, '--dir', WEB], capture_output=True, text=True)
    print(r.stdout.rstrip().splitlines()[-1] if r.stdout.strip() else r.stderr[-500:])
    res.append(('control', 'the isolation control: the proven recall corpus', r.returncode == 0, 'PASS'))
    web = mutant_wasm('patch_reversed', 'gui/juno_bridge.c',
                      '    for (k = 0; k < JUNO_PATCH_EV_N; ++k) {\n        int32_t v = rec_value(r, &JUNO_PATCH_EV[k]);\n',
                      '    for (k = JUNO_PATCH_EV_N - 1; k >= 0; --k) {\n        int32_t v = rec_value(r, &JUNO_PATCH_EV[k]);\n')
    print('--- tooth wasm_patch_reversed')
    res.append(('wasm_patch_reversed', 'a WASM built from other source (the patch load reversed)', run_wasm(script, web) == 1, 'BITES'))
    web = mutant_wasm('meter_floor', 'gui/juno_bridge.c',
                      '    if (!(peak >= 0.001f)) d = 0.001;\n#endif',
                      '    if (!(peak >= 0.002f)) d = 0.002;\n#endif')
    print('--- tooth wasm_meter_floor')
    res.append(('wasm_meter_floor', 'a WASM whose meter floor is 0.002 (the LED and meter ticks are graded)',
                run_wasm(script, web) == 1, 'BITES'))
    web = mutant_wasm('cc_value', 'gui/juno_bridge.c',
                      '            if (d < 128u) { m[0] = 0xB0; m[1] = (unsigned char)d; m[2] = b; }',
                      '            if (d < 128u) { m[0] = 0xB0; m[1] = (unsigned char)d; m[2] = (unsigned char)(b ^ 1); }')
    print('--- tooth wasm_cc_value')
    res.append(('wasm_cc_value', 'a WASM whose MIDI CC value is one off (the skin\'s MIDI input and CC menu are graded)',
                run_wasm(script, web) == 1, 'BITES'))
    for t, what in (('no_init', 'the app without juno_gui_plugin_init (the engine after BUILD)'),
                    ('apply_bank', 'the load as the recall model (juno_gui_apply_bank)')):
        print('--- tooth flow_%s' % t)
        res.append(('flow_' + t, what, run_wasm(script, WEB, t) == 1, 'BITES'))
    # the reach guard: a native bridge whose warm-up renders nothing leaves the app's first key
    # silent after start-up (the defect this guard was added for: the warm-up then skipped the
    # voice-count sync; since A25 the warm-up is the product's own render, so the tooth is the
    # warm-up gone)
    from tooth_tree import run_tooth
    print('--- tooth reach_warm_none')
    src = open(os.path.join(REPO, 'gui', 'juno_bridge.c')).read()
    anchor = '    while (nsamples > 0) {\n        int b = nsamples > 512 ? 512 : nsamples;\n'
    if src.count(anchor) != 1:
        raise SystemExit('TOOTH reach_warm_none: anchor occurs %d times -- the tooth is stale' % src.count(anchor))
    rc = run_tooth('wasm_reach_warm', [('gui/juno_bridge.c', anchor,
                   '    while (0) {\n        int b = nsamples > 512 ? 512 : nsamples;\n')],
                   ['tools/verify/wasm_product_gate.py', '--native-only'], tail=1500)
    res.append(('reach_warm_none', 'the warm-up rendering nothing: the first key after start-up silent', rc == 0, 'BITES'))
    print()
    for n, what, ok, word in res:
        print('%-22s %-12s %s' % (n, word if ok else 'FAILED', what))
    return 0 if all(ok for n, w, ok, word in res) else 1


if __name__ == '__main__':
    a = sys.argv[1:2]
    sys.exit(tooth() if a == ['--tooth'] else check(native_only=a == ['--native-only']))
