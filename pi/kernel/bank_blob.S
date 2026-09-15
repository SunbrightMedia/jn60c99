// bank_blob.S — embed the factory bank into the image (no filesystem on bare
// metal). build_engine.sh copies truth/presetbankog1.bin next to this file as
// bank.bin (gitignored) and assembles with its dir on the include path, so the
// same bytes the host reference used are compiled into the kernel.
	.section .rodata
	.balign 8
	.global juno_bank_blob
juno_bank_blob:
	.incbin "bank.bin"
	.global juno_bank_blob_end
juno_bank_blob_end:
