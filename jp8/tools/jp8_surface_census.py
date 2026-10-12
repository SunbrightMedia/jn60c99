#!/usr/bin/env python3
"""jp8_surface_census.py -- the JUNO-60's VST3 surface census (probes/host_api/vst3_surface_census.py, task #36) run on
the JUPITER-8: the booted plugin under its host oracle (jp8_host_emu.JP8Host, started at 48000 / 4096), every
IComponent and IAudioProcessor call besides the ones the gates drive (initialize, setState, getState, setActive,
setupProcessing, process): the return value and, for the calls that could change the engine, whether the wrapper core
and the nine units' state blocks change. Oracle only (Unicorn), plumbing only.
usage: python3 jp8/tools/jp8_surface_census.py"""
import os
import sys
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(REPO, 'probes', 'host_api'))
os.environ.setdefault('JP8_EMU_QUIET', '1')
import jp8_host_emu as X            # noqa: E402
import vst3_surface_census as V     # noqa: E402

h = X.JP8Host()
h.start(48000.0, 4096)
for n, v in V.census(h):
    print('%-44s %s' % (n, v))
