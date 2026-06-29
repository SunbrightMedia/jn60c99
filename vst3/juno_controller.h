// juno_controller.h — VST3 edit controller: exposes the JUNO-60 panel params +
// the program list to the host. No custom view (host generic editor).
#pragma once
#include "public.sdk/source/vst/vsteditcontroller.h"

namespace Juno {

class Controller : public Steinberg::Vst::EditControllerEx1 {
public:
    static Steinberg::FUnknown* createInstance(void*) {
        return (Steinberg::Vst::IEditController*)new Controller();
    }
    Steinberg::tresult PLUGIN_API initialize(Steinberg::FUnknown* context) SMTG_OVERRIDE;
    Steinberg::tresult PLUGIN_API setComponentState(Steinberg::IBStream* state) SMTG_OVERRIDE;
};

} // namespace Juno
