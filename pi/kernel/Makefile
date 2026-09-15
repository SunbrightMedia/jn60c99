#
# Makefile — JUNO bare-metal kernel (Circle, BCM2837 / Pi 3 family, AArch64)
#
# Circle lives beside us as a pinned submodule (../circle). Configure it once
# with `../circle/configure -r 3 -p aarch64-linux-gnu-` and build its library
# (`make -C ../circle/lib`) before building here. Output: kernel8.img — the
# same image boots a real Pi 3A+ and QEMU raspi3ap.
#
CIRCLEHOME = ../circle

OBJS	= main.o kernel.o bare_stubs.o

LIBS	= $(CIRCLEHOME)/lib/libcircle.a

include $(CIRCLEHOME)/Rules.mk

-include $(DEPS)
