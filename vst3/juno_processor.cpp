// juno_processor.cpp — see juno_processor.h.
#include "juno_processor.h"
#include "juno_ids.h"
#include "pluginterfaces/vst/ivstparameterchanges.h"
#include "pluginterfaces/vst/ivstevents.h"
#include "base/source/fstreamer.h"
#include <cstdlib>

using namespace Steinberg;
using namespace Steinberg::Vst;

namespace Juno {

// The factory bank shipped with the plugin. In a real bundle this lives in the
// plugin's Resources; override at build time (-DJUNO_FACTORY_BANK=\"...\") or at
// runtime via the JUNO_FACTORY_BANK environment variable.
#ifndef JUNO_FACTORY_BANK
#define JUNO_FACTORY_BANK "refs/preset_banks/bank1.bin"
#endif

static const char* factoryBankPath() {
    const char* env = std::getenv("JUNO_FACTORY_BANK");
    return (env && *env) ? env : JUNO_FACTORY_BANK;
}

Processor::Processor() { setControllerClass(kControllerUID); }
Processor::~Processor() { if (fSynth) juno_synth_destroy(fSynth); }

tresult PLUGIN_API Processor::initialize(FUnknown* context) {
    tresult r = AudioEffect::initialize(context);
    if (r != kResultOk) return r;
    // Instrument: stereo audio output + one event input, no audio input.
    addAudioOutput(STR16("Stereo Out"), SpeakerArr::kStereo);
    addEventInput(STR16("MIDI In"), 1);
    return kResultOk;
}

tresult PLUGIN_API Processor::terminate() { return AudioEffect::terminate(); }

tresult PLUGIN_API Processor::setupProcessing(ProcessSetup& setup) {
    fSampleRate = setup.sampleRate;
    if (fSynth) { juno_synth_set_sample_rate(fSynth, fSampleRate); loadProgram(fProgram); }
    return AudioEffect::setupProcessing(setup);
}

tresult PLUGIN_API Processor::setActive(TBool state) {
    if (state) {
        if (!fSynth) fSynth = juno_synth_create_sr(fSampleRate);
        loadProgram(fProgram);
    } else if (fSynth) {
        juno_synth_all_notes_off(fSynth);
    }
    return AudioEffect::setActive(state);
}

void Processor::loadProgram(int program) {
    if (!fSynth) return;
    if (program < 0) program = 0; else if (program >= kNumPrograms) program = kNumPrograms - 1;
    fProgram = program;
    juno_synth_load_preset(fSynth, factoryBankPath(), program, nullptr);
}

tresult PLUGIN_API Processor::setBusArrangements(SpeakerArrangement* inputs, int32 numIns,
                                                 SpeakerArrangement* outputs, int32 numOuts) {
    if (numIns == 0 && numOuts == 1 && outputs[0] == SpeakerArr::kStereo)
        return AudioEffect::setBusArrangements(inputs, numIns, outputs, numOuts);
    return kResultFalse;
}

tresult PLUGIN_API Processor::canProcessSampleSize(int32 symbolicSampleSize) {
    return (symbolicSampleSize == kSample32) ? kResultTrue : kResultFalse;
}

void Processor::applyParameterChanges(IParameterChanges* changes) {
    if (!changes || !fSynth) return;
    int32 n = changes->getParameterCount();
    for (int32 i = 0; i < n; ++i) {
        IParamValueQueue* q = changes->getParameterData(i);
        if (!q) continue;
        int32 count = q->getPointCount();
        if (count <= 0) continue;
        int32 off; ParamValue val;
        if (q->getPoint(count - 1, off, val) != kResultOk) continue; // last value in block
        ParamID id = q->getParameterId();
        if (id == kParamProgram) {
            loadProgram((int)(val * (kNumPrograms - 1) + 0.5));
        } else if ((int)id < juno_synth_num_params()) {
            juno_synth_set_param(fSynth, (int)id, (float)val);
        }
    }
}

void Processor::handleEvents(IEventList* events) {
    if (!events || !fSynth) return;
    int32 n = events->getEventCount();
    for (int32 i = 0; i < n; ++i) {
        Event e;
        if (events->getEvent(i, e) != kResultOk) continue;
        switch (e.type) {
            case Event::kNoteOnEvent:
                if (e.noteOn.velocity <= 0.f) juno_synth_note_off(fSynth, e.noteOn.pitch);
                else juno_synth_note_on(fSynth, e.noteOn.pitch, (int)(e.noteOn.velocity * 127.f + 0.5f));
                break;
            case Event::kNoteOffEvent:
                juno_synth_note_off(fSynth, e.noteOff.pitch);
                break;
            default: break;
        }
    }
}

tresult PLUGIN_API Processor::process(ProcessData& data) {
    applyParameterChanges(data.inputParameterChanges);
    handleEvents(data.inputEvents);

    if (data.numOutputs < 1 || data.numSamples <= 0)
        return kResultOk;

    float* outL = data.outputs[0].channelBuffers32[0];
    float* outR = data.outputs[0].channelBuffers32[1];
    if (!fSynth) {
        for (int32 i = 0; i < data.numSamples; ++i) { outL[i] = 0.f; outR[i] = 0.f; }
        data.outputs[0].silenceFlags = 0x3;
        return kResultOk;
    }
    juno_synth_process(fSynth, outL, outR, data.numSamples);
    data.outputs[0].silenceFlags = 0;
    return kResultOk;
}

// State: store program index (+ a version tag). Panel-param overrides are driven
// live by the host's automation; the program defines the patch.
tresult PLUGIN_API Processor::getState(IBStream* state) {
    IBStreamer s(state, kLittleEndian);
    s.writeInt32(1);            // version
    s.writeInt32(fProgram);
    return kResultOk;
}

tresult PLUGIN_API Processor::setState(IBStream* state) {
    IBStreamer s(state, kLittleEndian);
    int32 version = 0, program = 0;
    if (!s.readInt32(version)) return kResultFalse;
    if (!s.readInt32(program)) return kResultFalse;
    fProgram = program;
    if (fSynth) loadProgram(fProgram);
    return kResultOk;
}

} // namespace Juno
