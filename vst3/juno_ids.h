// juno_ids.h — stable component/controller UIDs and parameter ids for the
// JUNO-60 C99-engine VST3 wrapper. The audio engine itself is the bit-exact
// transcription in ../src; this layer is the Steinberg VST3 binding only.
#pragma once
#include "pluginterfaces/base/funknown.h"
#include "pluginterfaces/vst/vsttypes.h"

namespace Juno {

// Freshly-generated UIDs for THIS port (not the Roland product's IDs — this is an
// independent reimplementation; do not impersonate the original plugin's CIDs).
static const Steinberg::FUID kProcessorUID (0x4A554E36, 0x30504F52, 0x54656E67, 0x696E6541);
static const Steinberg::FUID kControllerUID(0x4A554E36, 0x30435452, 0x4C656467, 0x69727941);

// Parameter ids. The first N are the panel params enumerated by
// juno_synth_num_params(); program (preset) selection sits above them.
enum {
    kParamPanelBase = 0,         // [0 .. juno_synth_num_params()-1]
    kParamProgram   = 10000,     // preset/program index within the factory bank
    kNumPrograms    = 64
};

} // namespace Juno
