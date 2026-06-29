// juno_factory.cpp — VST3 module entry point + plugin factory registration.
#include "public.sdk/source/main/pluginfactory.h"
#include "pluginterfaces/vst/ivstcomponent.h"
#include "pluginterfaces/vst/ivstaudioprocessor.h"
#include "pluginterfaces/vst/ivsteditcontroller.h"

#include "juno_ids.h"
#include "juno_processor.h"
#include "juno_controller.h"

#define JUNO_VENDOR   "JUNO-60 C99 Port"
#define JUNO_URL      ""
#define JUNO_EMAIL    ""
#define JUNO_VERSION  "1.0.0"

using namespace Steinberg;
using namespace Steinberg::Vst;

BEGIN_FACTORY_DEF(JUNO_VENDOR, JUNO_URL, JUNO_EMAIL)

    DEF_CLASS2(INLINE_UID_FROM_FUID(Juno::kProcessorUID),
               PClassInfo::kManyInstances,
               kVstAudioEffectClass,
               "JUNO-60 C99",
               Vst::kDistributable,
               PlugType::kInstrumentSynth,   // it's an instrument
               JUNO_VERSION,
               kVstVersionString,
               Juno::Processor::createInstance)

    DEF_CLASS2(INLINE_UID_FROM_FUID(Juno::kControllerUID),
               PClassInfo::kManyInstances,
               kVstComponentControllerClass,
               "JUNO-60 C99 Controller",
               0,
               "",
               JUNO_VERSION,
               kVstVersionString,
               Juno::Controller::createInstance)

END_FACTORY
