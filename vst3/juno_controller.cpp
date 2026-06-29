// juno_controller.cpp — see juno_controller.h.
#include "juno_controller.h"
#include "juno_ids.h"
#include "pluginterfaces/base/ustring.h"
#include "base/source/fstreamer.h"

extern "C" {
#include "../host/juno_synth.h"
}

using namespace Steinberg;
using namespace Steinberg::Vst;

namespace Juno {

tresult PLUGIN_API Controller::initialize(FUnknown* context) {
    tresult r = EditControllerEx1::initialize(context);
    if (r != kResultOk) return r;

    // Panel params: one continuous 0..1 automatable parameter per engine knob.
    int n = juno_synth_num_params();
    for (int i = 0; i < n; ++i) {
        UString256 title;
        title.fromAscii(juno_synth_param_name(i));
        parameters.addParameter(title, nullptr, 0 /*continuous*/, 0.5,
                                ParameterInfo::kCanAutomate, (ParamID)(kParamPanelBase + i));
    }

    // Program (preset) selector as a stepped list parameter.
    StringListParameter* prog = new StringListParameter(
        STR16("Program"), kParamProgram, nullptr,
        ParameterInfo::kCanAutomate | ParameterInfo::kIsList | ParameterInfo::kIsProgramChange);
    for (int p = 0; p < kNumPrograms; ++p) {
        char16 buf[32]; UString(buf, 32).printInt((int64)p); // host shows index; names come from the bank
        prog->appendString(buf);
    }
    parameters.addParameter(prog);
    return kResultOk;
}

tresult PLUGIN_API Controller::setComponentState(IBStream* state) {
    if (!state) return kResultFalse;
    IBStreamer s(state, kLittleEndian);
    int32 version = 0, program = 0;
    if (!s.readInt32(version)) return kResultFalse;
    if (!s.readInt32(program)) return kResultFalse;
    if (auto* p = parameters.getParameter(kParamProgram))
        setParamNormalized(kParamProgram, p->toNormalized((ParamValue)program));
    return kResultOk;
}

} // namespace Juno
