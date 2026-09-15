/* bare_stubs.c — minimal glibc stubs the aarch64-linux-gnu toolchain expects.
 *
 * Circle upstream builds AArch64 with the bare-metal aarch64-none-elf-
 * toolchain, whose libgcc has no OS dependencies. We build with
 * aarch64-linux-gnu- (the toolchain available here); its libgcc ships an
 * ELF init constructor (lse-init.o -> init_have_lse_atomics) that probes the
 * CPU's HWCAP for Large-System-Extension atomics by calling glibc's
 * __getauxval. There is no glibc — and no auxv — on bare metal.
 *
 * Returning 0 means "no HWCAP bits set", so libgcc falls back to the portable
 * load-exclusive/store-exclusive atomic sequences, which are correct on every
 * ARMv8 core (Cortex-A53 included). This single stub is what lets the
 * linux-gnu toolchain link a bare-metal Circle image. */
unsigned long __getauxval (unsigned long type)
{
	(void) type;
	return 0;
}
