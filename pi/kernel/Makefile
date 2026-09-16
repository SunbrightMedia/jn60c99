#
# Makefile — JUNO bare-metal kernel (Circle, BCM2837 / Pi 3 family, AArch64)
#
# Circle lives beside us as a pinned submodule (../circle). Configure it once
# with `../circle/configure -r 3 -p aarch64-linux-gnu-` and build its library
# (`make -C ../circle/lib`) before building here. Output: kernel8.img — the
# same image boots a real Pi 3A+ and QEMU raspi3ap.
#
CIRCLEHOME = ../circle

# PLAY mode (real-time I2S audio) is selected with `make JUNO_PLAY=1`; the
# default is the GATE image (bit-exact probe) that runs under QEMU.
ifdef JUNO_PLAY
DEFINE += -DJUNO_PLAY
endif
ifdef JUNO_SPLIT
DEFINE += -DJUNO_SPLIT
endif
ifdef JUNO_SILENCE
DEFINE += -DJUNO_SILENCE
endif
# Detector-reach: inject one split fault (see juno_forkjoin.cpp). Default 0.
ifdef JS_MUT
DEFINE += -DJS_MUT=$(JS_MUT)
endif
# Silence-probe seen-to-fail: force a held note so the probe must verdict STUCK.
ifdef JUNO_SIL_STUCK
DEFINE += -DJUNO_SIL_STUCK
endif

# Kernel glue objects (built with Circle's flags — no DSP math here).
OBJS	= main.o kernel.o juno_probe.o juno_sound.o juno_split.o juno_forkjoin.o \
	  juno_silence.o juno_panel.o juno_midi.o bank_blob.o bare_stubs.o

# Circle's own I2S sound driver (libsound) + core. --start-group resolves refs.
LIBS	= $(CIRCLEHOME)/lib/sound/libsound.a \
	  $(CIRCLEHOME)/lib/libcircle.a

# The engine (built separately with the PROVEN bit-exact flags by
# ../build_engine.sh). Its own bare_libm.o supplies the exact math, so no glibc
# libm is linked. Placed in Circle's --start-group so cross-refs resolve.
EXTRALIBS = build/libjunoengine.a

include $(CIRCLEHOME)/Rules.mk

-include $(DEPS)
