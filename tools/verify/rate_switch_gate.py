#!/usr/bin/env python3
"""rate_switch_gate.py -- AN ENGINE-RATE SWITCH ON A RUNNING ENGINE, plugin vs port (CLAIMS B13b,
docs/HOST_RENDER_LAYER.md). The engine-rate setting (vm.vs.sampleRate) changed while the engine
plays -- a DAW preset or the plugin's own setting: the core's listener sets the rate, the render
driver's next block calls the engine's setSampleRate (rva 0x3C7A20) in place, looks the render
object up again and, found, restarts the tick phase and the note count. READ + EXECUTED
(probes/b13b/): per unit the processor's suspend (rva 0x3B86C0), the effect container's
setSampleRate (rva 0x3BC980: the rate-dependent cells re-applied at the new rate), the state's
(rva 0x3C2770: the records' rate, the constructor's constants, the runtime reset that clears the
voice and effect memories and buffers) and the resume (rva 0x3B8560). The port: setsr_inplace
(gui/juno_bridge.c) with src/recall_ramp.c juno_rr_setsr_*.

The plugin side is its own process() / setState on the booted plugin (tools/verify/
host_process_emu.py); the runner is midi_ctl_gate.py's. Chains (keys held across every switch):
  run48   the default engine (96000) at host 48000, patch 9 (chorus, delay type 1, reverb):
          settings 2 (48000, identity), 3 (44100, converter), 0 (96000), 1 (88200)
  fx      effect types 0..5 and delay types 0..5 set before each switch (the suspend / resume
          and the delay block's re-apply follow both)
  ramps   a switch with ramps in flight: VCF CUTOFF and ENV edits one short block before it, a
          patch load in the block before it, a DELAY TYPE change (voice and delay mutes in flight);
          DCO NOISE up (every unit's noise copy sounds)
  arp     the arp running across switches (the tick grid restarts)
  vc4     voice count 4: units 4..7 stopped through a switch, then 8
  wild    setting 6 (rate 0: no render object, silence) and back to 2; setting 5 (automatic)
  h44     host 44100: settings 3 (identity), 1, 0, 3

  --ref         (Unicorn) writes scratchpad/rate_switch_ref.pkl (.partial, then renamed)
  --port        (libjuno) every sample of both channels must agree
  --port-tooth  the port check must FAIL on: one note one sample late (after the start-up mute)
Mutants of the port's switch: probes/b13b/switch_teeth.py."""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import midi_ctl_gate as G                                   # noqa: E402

REF_PKL = os.environ.get('RATE_SWITCH_REF', os.path.join(REPO, 'scratchpad', 'rate_switch_ref.pkl'))
TITLE = ('AN ENGINE-RATE SWITCH ON A RUNNING ENGINE (CLAIMS B13b): setSampleRate in place -- plugin vs port')
SRATE, VOICES = 0x0FFFC015, 0x0FFFC00E
EFX, DLY = 0x00600258, 0x00600268
CUTOFF, ENV_A, NOISE = 0x0060003A, 0x0060004E, 0x0060002E


def chains():
    T = (True, 120.0)
    E = lambda n=256, ev=(), par=(): ('blk', n, list(ev), T, list(par))
    on, off = G.ev_on, G.ev_off
    sw = lambda s: [('state', [(SRATE, s)])]
    out = []
    # 1. the default engine through four settings, keys held
    st = [('patch', 9), E(ev=[on(0, 60, 0.8), on(0, 64, 0.7)])] + [E()] * 12
    for s in (2, 3, 0, 1):
        st += sw(s) + [E()] * 8 + [E(ev=[on(10, 67, 0.6)])] + [E()] * 6 + [E(ev=[off(0, 67)])] + [E()] * 4
    st += [E(ev=[off(0, 60), off(0, 64)])] + [E()] * 8
    out.append(('run48', 48000.0, None, st))
    # 2. every effect type and delay type in force at a switch
    st = [('patch', 0), E(ev=[on(0, 57, 0.8), on(0, 64, 0.8)])] + [E()] * 6
    for k, (e, d) in enumerate(((0, 0), (1, 2), (3, 3), (4, 4), (5, 5), (2, 1))):
        st += [('state', [(EFX, e), (DLY, d)])] + [E()] * 10
        st += sw(2 if k % 2 == 0 else 0) + [E()] * 10
    st += [E(ev=[off(0, 57), off(0, 64)])] + [E()] * 6
    out.append(('fx', 48000.0, None, st))
    # 3. ramps in flight at the switch: a cutoff edit, an envelope edit, a patch load, and a DELAY
    #    TYPE change (its mute / unmute ramps every voice's level cells and the delay block, so
    #    the suspend's arms meet ramps in flight); DCO NOISE up, so every unit's noise copy sounds
    st = [('patch', 9), ('state', [(NOISE, 200)]), E(ev=[on(0, 55, 0.9)])] + [E()] * 8
    st += [('state', [(CUTOFF, 40)]), E(64)] + sw(2) + [E()] * 8
    st += [('state', [(DLY, 2)]), E(32)] + sw(3) + [E()] * 8
    st += [('state', [(ENV_A, 200), (CUTOFF, 220)]), E(32)] + sw(0) + [E()] * 8
    st += [('patch', 12), E(64)] + sw(3) + [E(ev=[on(0, 62, 0.7)])] + [E()] * 10
    st += [E(ev=[off(0, 55), off(0, 62)])] + [E()] * 6
    out.append(('ramps', 48000.0, None, st))
    # 4. the arp running across switches
    A = lambda n=256, ev=(): ('blk', n, list(ev), (True, 128.0), [])
    st = [('patch', 1), A(ev=[on(0, 60, 0.8), on(0, 64, 0.8)])] + [A()] * 12
    st += sw(2) + [A()] * 16 + sw(3) + [A()] * 16 + sw(0) + [A()] * 12
    st += [A(ev=[off(0, 60), off(0, 64)])] + [A()] * 4
    out.append(('arp', 44100.0, None, st))
    # 5. stopped units through a switch
    st = [('patch', 9), ('state', [(VOICES, 4)]), E()]
    st += [E(ev=[on(0, k, 0.7) for k in (48, 52, 55, 59)])] + [E()] * 6 + sw(2) + [E()] * 8
    st += [('state', [(VOICES, 8)]), E()] + [E(ev=[on(0, k, 0.7) for k in (62, 65, 69, 72)])] + [E()] * 8
    st += sw(0) + [E()] * 8 + [E(ev=[off(0, k) for k in (48, 52, 55, 59, 62, 65, 69, 72)])] + [E()] * 6
    out.append(('vc4', 48000.0, None, st))
    # 6. rate 0 (setting 6: no render object) and back; the automatic setting
    st = [('patch', 9), E(ev=[on(0, 60, 0.8)])] + [E()] * 6 + sw(6) + [E()] * 4 + sw(2) + [E()] * 8
    st += sw(5) + [E()] * 6 + [E(ev=[off(0, 60)])] + [E()] * 6
    out.append(('wild', 48000.0, None, st))
    # 7. host 44100
    st = [('patch', 33), E(ev=[on(0, 52, 0.8), on(0, 59, 0.8)])] + [E()] * 8
    for s in (3, 1, 0, 3):
        st += sw(s) + [E()] * 8
    st += [E(ev=[off(0, 52), off(0, 59)])] + [E()] * 6
    out.append(('h44', 44100.0, None, st))
    return out


def main():
    a = sys.argv[1:2]
    if a == ['--ref']:
        return G.build_ref(chain_fn=chains, ref_pkl=REF_PKL)
    only = [x[len('--only='):].split(',') for x in sys.argv if x.startswith('--only=')]
    if a == ['--port']:
        return G.check_port(only=only[0] if only else None, ref_pkl=REF_PKL, title=TITLE)
    if a == ['--port-tooth']:
        b = G.check_port(tooth='late_note', only=only[0] if only else None, ref_pkl=REF_PKL, title=TITLE)
        print('\nlate_note      %s (%d chains differ)' % ('BITES' if b else 'DID NOT BITE', b))
        return 0 if b else 1
    print(__doc__)
    return 2


if __name__ == '__main__':
    sys.exit(main())
