/* juno_master_gate.c — the master/chorus "coefficients ready" gate.
 *
 * juno_driver_render_sample runs the full master + BBD chorus only when the
 * parameter-applied coefficients have been seeded (otherwise the master's output
 * saturator collapses to silence, so the safe fallback is the dry voice sum).
 *
 * Originally this gate was answered by the memory-capture file (it reported
 * "loaded" iff its captured table was non-empty). That coupled the product to the
 * capture. The gate is now a simple flag raised by whichever seed ran — the
 * capture-free seed (juno_capture_free_seed) OR the legacy capture
 * (juno_runtime_coeffs_apply) — so the product links and runs with the capture
 * file entirely absent. */

static int g_juno_master_ready = 0;

void juno_master_gate_set(int ready) { g_juno_master_ready = ready ? 1 : 0; }

int juno_runtime_coeffs_loaded(void) { return g_juno_master_ready; }
