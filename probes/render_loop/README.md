What: derived the REAL per-block render structure from the binary (pool work
items, per-sample master, voice-0 LED meter, numVoices==8, SUB-slot null,
noise-block policy, block-size invariance) — the render loop's exoneration.
Cited by: docs/RENDER_LOOP_LOG.md (primary), docs/RENDER_LOOP_SCOPE.md.
Gate born from it: tools/verify/renderstruct_ab.py (in make verify).
