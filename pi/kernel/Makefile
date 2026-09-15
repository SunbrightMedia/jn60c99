#
# Makefile — JUNO bare-metal kernel (Circle, BCM2837 / Pi 3 family, AArch64)
#
# Circle lives beside us as a pinned submodule (../circle). Configure it once
# with `../circle/configure -r 3 -p aarch64-linux-gnu-` and build its library
# (`make -C ../circle/lib`) before building here. Output: kernel8.img — the
# same image boots a real Pi 3A+ and QEMU raspi3ap.
#
CIRCLEHOME = ../circle

# Kernel glue objects (built with Circle's flags — no DSP math here).
OBJS	= main.o kernel.o juno_probe.o bank_blob.o bare_stubs.o

LIBS	= $(CIRCLEHOME)/lib/libcircle.a

# The engine (built separately with the PROVEN bit-exact flags by
# ../build_engine.sh). Its own bare_libm.o supplies the exact math, so no glibc
# libm is linked. Placed in Circle's --start-group so cross-refs resolve.
EXTRALIBS = build/libjunoengine.a

include $(CIRCLEHOME)/Rules.mk

-include $(DEPS)
