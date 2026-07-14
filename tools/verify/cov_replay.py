#!/usr/bin/env python3
"""cov_replay.py — exercise the PORT (libjuno_cov.so) through every corpus
scenario, so gcov records which port branches the verified scenario set
reaches. No oracle here: this measures COVERAGE, not correctness (correctness
is proven by fuzz_diff.py / the A/B tests). Port coverage side of the Gate-G3
coverage certificate.

Scenarios replayed:
  1. all 103 fuzz seeds (recall, notes, param edits, arp, render) — the same
     scripts fuzz_diff.py proves bit-exact;
  2. live TEMPO SYNC engage + disengage on every patch (blob-59 both directions);
  3. every chorus mode (0..3) recall;
  4. arp on/off with each mode + octave on the arp patches;
  5. a note x velocity spread + release + re-strike (voice alloc: free/release/steal).

Run:  LIBJUNO=./libjuno_cov.so python3 tools/verify/cov_replay.py
"""
import os, sys, ctypes, struct
sys.path.insert(0, '/home/user/jn60c99/tools/verify')
import fuzz_diff as F
from fuzz_diff import gen_script, BLOBS, ARPS, BANK

LIB = os.environ.get('LIBJUNO', '/home/user/jn60c99/libjuno_cov.so')
lib = ctypes.CDLL(LIB)
lib.juno_gui_create.restype = ctypes.c_void_p
lib.juno_gui_create.argtypes = [ctypes.c_float, ctypes.c_int]
lib.juno_gui_apply_bank.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_on.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_note_off.argtypes = [ctypes.c_void_p, ctypes.c_int]
lib.juno_gui_set_param.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
lib.juno_gui_render.argtypes = [ctypes.c_void_p, ctypes.POINTER(ctypes.c_float), ctypes.c_int]
lib.juno_gui_arp_config.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_float, ctypes.c_float]
lib.juno_gui_set_chorus_mode.argtypes = [ctypes.c_void_p, ctypes.c_int]
for opt in ('juno_gui_destroy',):
    try: getattr(lib, opt).argtypes = [ctypes.c_void_p]
    except AttributeError: pass

BANKB = open(BANK, 'rb').read()

def render(c, n):
    buf = (ctypes.c_float * (2*n))(); lib.juno_gui_render(c, buf, n)

def create(rate, patch, chorus=0, arp=False):
    c = lib.juno_gui_create(ctypes.c_float(rate), chorus)
    lib.juno_gui_apply_bank(c, BANKB, len(BANKB), patch)
    if arp or patch in ARPS:
        lib.juno_gui_arp_config(c, 0, 0, 1, 128.0, 0.6)
    return c

def destroy(c):
    if hasattr(lib, 'juno_gui_destroy'):
        lib.juno_gui_destroy(c)

def replay_event(c, x):
    if x[0] == 'on': lib.juno_gui_note_on(c, x[1], x[2])
    elif x[0] == 'off': lib.juno_gui_note_off(c, x[1])
    elif x[0] == 'param': lib.juno_gui_set_param(c, x[1], x[2])
    else: render(c, x[1])

def scen_fuzz():
    nseed = int(os.environ.get('NSEED', '103'))
    for seed in range(nseed):
        rate, patch, ev, _ = gen_script(seed)
        c = create(rate, patch)
        for x in ev: replay_event(c, x)
        destroy(c)

def scen_temposync():
    for patch in range(64):
        c = create(44100.0, patch)
        lib.juno_gui_note_on(c, 60, 100); render(c, 1000)
        lib.juno_gui_set_param(c, 24, 127); render(c, 1500)   # engage
        lib.juno_gui_set_param(c, 24, 0);   render(c, 1500)   # disengage
        destroy(c)

def scen_chorus():
    for mode in range(4):
        for patch in (0, 20, 40, 60):
            c = create(48000.0, patch, chorus=mode)
            lib.juno_gui_note_on(c, 60, 100); render(c, 800)
            lib.juno_gui_set_chorus_mode(c, (mode + 1) & 3); render(c, 800)
            destroy(c)

def scen_arp():
    for patch in sorted(ARPS):
        for mode in range(3):
            for octv in (1, 2, 3):
                c = lib.juno_gui_create(ctypes.c_float(44100.0), 0)
                lib.juno_gui_apply_bank(c, BANKB, len(BANKB), patch)
                lib.juno_gui_arp_config(c, 1, mode, octv, 128.0, 0.6)
                lib.juno_gui_note_on(c, 48, 100); lib.juno_gui_note_on(c, 55, 100)
                lib.juno_gui_note_on(c, 60, 100); render(c, 4000)
                lib.juno_gui_arp_config(c, 0, mode, octv, 128.0, 0.6); render(c, 500)
                destroy(c)

def scen_voicealloc():
    for patch in (5, 31, 61, 63):
        c = create(44100.0, patch)
        # fill all 8 + steal (9th) + release + re-strike
        for i, note in enumerate(range(48, 60)):
            lib.juno_gui_note_on(c, note, 60 + i); render(c, 40)
        for note in (48, 50, 52):
            lib.juno_gui_note_off(c, note); render(c, 40)
        lib.juno_gui_note_on(c, 48, 90); render(c, 200)   # re-strike (persistent binding)
        for note in range(48, 60): lib.juno_gui_note_off(c, note)
        render(c, 2000)
        destroy(c)

def scen_dsp_params():
    """Live-edit every DSP row (0..21) across its full byte range on several base
    patches + a range of notes, rendering each — drives the voice_render DCO /
    ENV / VCF / VCA branches gated on those cells. Port-side coverage only."""
    for patch in (5, 20, 31, 45, 61, 63):
        for row in range(22):
            for byte in (0, 32, 64, 96, 128, 160, 192, 224, 255):
                c = create(44100.0, patch)
                lib.juno_gui_set_param(c, row, byte)
                for note in (36, 60, 84):
                    lib.juno_gui_note_on(c, note, 100)
                render(c, 600)
                lib.juno_gui_note_off(c, 60)
                render(c, 600)
                destroy(c)

def scen_synth_discrete():
    """Apply synthetic patches with out-of-factory DISCRETE mode bytes (DCO
    range/waveform, sub/noise type, LFO variation/routing, octave shift) and
    render extreme notes — drives the discrete voice_render branches."""
    import e2e_emu as _E
    H, S, BO = _E.HEADER, _E.STRIDE, _E.BLOB_OFF
    base_bank = bytearray(_E.bank_bytes())
    DISC = [(36,(0,1,2,3)),(42,(0,1,2,3)),(60,(0,1,2,3)),(62,(0,1,2,3)),
            (64,(0,1,2)),(322,(0,1,2,3)),(578,(0,1,2,3)),(530,(0,1,2)),
            (538,(0,1)),(474,(0,1,2)),(354,(0,1,2)),(362,(0,1,2)),(370,(0,1,2))]
    for rb, vals in DISC:
        for v in vals:
            b = bytearray(base_bank)
            off = H + 5 * S + BO + rb
            b[off] = (v >> 4) & 0xF; b[off+1] = v & 0xF
            bb = bytes(b)
            c = lib.juno_gui_create(ctypes.c_float(44100.0), 0)
            lib.juno_gui_apply_bank(c, bb, len(bb), 5)
            for note in (24, 36, 60, 84, 96):
                lib.juno_gui_note_on(c, note, 100); render(c, 500)
            destroy(c)

def main():
    scen_fuzz();      print("fuzz corpus replayed", flush=True)
    scen_dsp_params();print("DSP param sweep replayed", flush=True)
    scen_synth_discrete(); print("synthetic discrete-mode patches replayed", flush=True)
    scen_temposync(); print("tempo-sync engage/disengage replayed (64 patches)", flush=True)
    scen_chorus();    print("chorus modes replayed", flush=True)
    scen_arp();       print("arp scenarios replayed", flush=True)
    scen_voicealloc();print("voice-alloc scenarios replayed", flush=True)
    print("DONE — gcov data flushes on exit", flush=True)

if __name__ == '__main__':
    main()
