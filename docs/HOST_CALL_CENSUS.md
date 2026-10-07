# HOST_CALL_CENSUS.md -- every call a host makes to the plugin, and what the port does with it

Task #36 (2026-10-07). The JUNO-60 VST3 is a component (IComponent + IAudioProcessor) and an
edit controller (IEditController + IMidiMapping), plus a UI timer and its GUI. This table lists
every call, what the plugin does (EXECUTED in the booted plugin under Unicorn unless marked READ),
and the port's answer with its evidence. "No effect" rows were measured, not assumed.
Probes: probes/host_api/ (vst3_surface_census.py, bus_census.py, bus_audio_census.py,
conductor_probe.py). Ledger rows: PROVENANCE.tsv; claims: docs/CLAIMS.md.

| Call | The plugin | The port | Evidence |
|---|---|---|---|
| createInstance + IComponent::initialize | engine built at 96000 (boot ramps in flight), 6 voices, the 95 defaults, the boot CC map, the model at its defaults | juno_gui_create + juno_gui_plugin_init | A29 boot_gate, A22 state_load_gate, A31, A32 |
| IComponent::setState | count field 4 / 8 bytes by stream length (> 2854: 8); <= 0 -> kResultFalse; a zeroed payload the stream fills; the CC map emptied then refilled; the 95 parameters (value & mask) to the model and the engine, payload order | juno_gui_state_load / _queue_state | A22, A31, A32 (state_save_gate streams chain) |
| IComponent::getState | count + 223 (id, value): the model's 95 values, the 128 CC map entries | juno_gui_state_save | A32 state_save_gate, 357 saves byte-equal |
| IComponent::setActive | the core's setup at the stored host rate, an all-sound-off record | juno_gui_set_active | A28 host_rate_gate |
| IComponent::activateBus | sets the wrapper's bus flags (core + 0x2F8 ...); the render does not read them | nothing | bus_audio_census.py: output bit-equal with and without |
| IComponent::setIoMode | kNotImplemented (0x80004001) | nothing | vst3_surface_census.py |
| IComponent::getBusCount / getBusInfo | 1 audio out "Stereo Out" (2 ch), 1 event in "Event In"; no inputs | the port's API is that: stereo out, note events | vst3_surface_census.py |
| IComponent::getRoutingInfo | kNotImplemented | nothing | vst3_surface_census.py |
| IAudioProcessor::setBusArrangements | accepts mono, stereo, 5.1 (kResultOk) | stereo only | vst3_surface_census.py |
| process() with an output bus below 2 channels (mono) | returns at once: no events, no parameters, no render, the buffer untouched (rva 0x34A380) | not called (a wrapper with a mono bus calls nothing) | A33: midi_ctl_gate silent_calls (mono tooth bites) |
| process() with a 5.1 bus | channels 0 / 1 written (L / R), the rest untouched | stereo only | bus_audio_census.py |
| process() with 0 samples (a flush) | returns at once: its events and parameter changes are dropped | juno_gui_process_ex returns before taking them | A33 (flush mutant bites) |
| IAudioProcessor::canProcessSampleSize | 32-bit only (64 -> kResultFalse) | float | vst3_surface_census.py |
| getLatencySamples / getTailSamples | 0 / 0 | 0 | vst3_surface_census.py |
| IAudioProcessor::setupProcessing | stores host rate and max block; processMode and sample size never read | juno_gui_setup_processing | A28; READ (process never reads +0 / +4) |
| IAudioProcessor::setProcessing | kNotImplemented, no state change | nothing | vst3_surface_census.py |
| process(): note events | note on / off only (velocity (int)(float)(v x 127.0) & 0x7F, vel 0 -> off); other event types ignored | juno_gui_process_ex | A23, A24 |
| process(): parameter queues | the last point; ids below the MIDI base -> engine records; base + 0..127 CC, 128 aftertouch, 129 bend, above -> a zero message | proc_param | A26, A27, A31 |
| process(): transport | tempo (valid flag) used; playing, ppq, loop flags reach empty engine functions (rva 0x34B100 / 0x34B110 / 0x34B120) | tempo only | A24; READ (nullsubs) |
| UI timer (CUiThreadTimer, 50 ms) -> the core's drain (rva 0x320120) | store records of mapped CCs into the model; completes MIDI learn; no engine record | juno_gui_ui_tick (the app's timer) | A32 |
| IEditController::getState / setState | 0 bytes | nothing to save | controller census (2026-10-07) |
| IEditController: parameter list | 209: 79 panel parameters + 130 MIDI-mapping ids (CC 0..127, aftertouch, bend); no bypass, no program-change parameter | src/juno_hostparams.c (the 79) + the MIDI base | controller census |
| IEditController: setParamNormalized, getParamNormalized, string / plain conversions, setComponentState | the controller's display copy; no audio path | the apps' own GUI | controller census (no audio path: READ) |
| IMidiMapping::getMidiControllerAssignment | CC n on any channel -> 0x0FFFC100 + n (128 aftertouch, 129 bend, 130 -> base + 130) | the same ids into juno_gui_process_ex | controller census, A26 |
| The editor (createView): MIDI learn menu, forget, patch browser, engine-rate setting menu | model edits | juno_gui_cc_learn / _forget / _of, juno_gui_load_patch, juno_gui_set_engine_rate_setting, juno_gui_model_set | A32, A22, A30 |
| queryInterface (16 VST3 interfaces tried) | component / processor: IProcessContextRequirements, IConnectionPoint; controller: IUnitInfo (2 units, 0 program lists), IMidiMapping, IEditController2, IConnectionPoint; none answers IProgramListData, IUnitData, IMidiLearn, INoteExpressionController, IKeyswitchController, IAutomationState, IPrefetchableSupport, IAudioPresentationLatency, IXmlRepresentationController, IParameterFunctionName, IInfoListener | no host-side program list: presets come only through setState and the plugin's own patch browser | interface census (2026-10-07) |
| SYSTEM-8 hardware link (Script.xml midiIn / midiOut "SYSTEM-8 CTRL", the setup panel) | the plugin's own OS MIDI ports to Roland hardware (sysex, model 00 00 7E) | NOT PORTED: an OS and hardware feature outside the host contract | READ (Script.xml) |

## Not modeled, by design
- The model's lock and a GUI edit gesture in progress (core+608: a mapped CC then queues no store
  record): the port's GUI edits are atomic.
- The timing of the drain: the plugin's UI thread (asynchronous to audio); the port drains when the
  app calls juno_gui_ui_tick. Equal at equal drain points (A32).
- A setState entry the count cuts short: the plugin reads past its vector (undefined); the port
  skips it.
