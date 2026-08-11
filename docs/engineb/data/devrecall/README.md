# Device-recall evidence, preserved from the scratchpad

The 2026-08-11 workflow built and ran a device-recall gate in a scratchpad
directory. A scratchpad dies with the container. These are the load-bearing
artifacts, copied into the repo so the result can be re-derived.

Read `../../DEVICE_RECALL.md` FIRST. Both refuters returned BROKEN.

| file | what it is |
|---|---|
| `DESIGN_full.md` | the design, verbatim |
| `REFUTATIONS_full.md` | both refutations, verbatim, with their fatal/optimistic/unread/missing lists |
| `ebdev.h` / `ebdev.c` | the device cell array and `ebdev_at()` |
| `ebdev_seg.h` | the 31-segment table |
| `ebdev_map.h` | the literal binary-search chain. GCC folds it to ONE load at a constant offset. An array loop does not fold -- that is why this file is generated and not a `for`. |
| `gate_host.c` / `gate_dev.c` | the two halves of the 384-case gate |
| `touched.txt` | the 343 cells recall touches, from an executed trace |
| `static_extra.txt` | the static scan's extra candidates (the cold segments) |
| `recread.txt` | cells recall READS as well as writes |
| `probes/warm.c`, `probes/warm2.c` | **the refutation that matters.** Warm recall != cold recall: 24/64 and 41/64. |
| `probes/rings.c` | ring lengths are ONE set over the whole bank and a randomised bank |
| `probes/foldtest.c` | the 4-instruction Xtensa fold |
| `probes/resdep.c` | no parameter moves the resonance table |
| `probes/sz.c` | the measured struct sizes |
| `probes/probe*.c`, `probes/rdprobe.c` | the cell traces |

The forked `src/` tree the gate was built against is NOT copied. It is a
verbatim copy of the port with `JF`/`JI` redirected and 17 raw pointer casts
rewritten; `DESIGN_full.md` section 1.5 names every one of the 17 sites.
