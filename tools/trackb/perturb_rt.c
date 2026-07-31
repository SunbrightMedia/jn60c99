/* perturb_rt.c — runtime-selectable observability perturbation (Track B gate #3).
 *
 * Only ever linked into the throwaway probe library built by
 * tools/trackb/observability.py, never into libjuno.so or juno_cand.so.
 *
 * WHY RUNTIME AND NOT -D. Classifying every per-voice cell one at a time needs
 * one experiment per cell. With a compile-time cell list that is one full
 * rebuild per cell (~4 s each, ~600 cells). With the list in a global the whole
 * sweep needs ONE build and the per-cell cost collapses to the renders.
 *
 * The list is empty by default, so a probe build that is never told which cells
 * to perturb behaves exactly like the unperturbed engine -- which is the state
 * observability.py asserts against before trusting any "invisible" result,
 * because "the perturbation did nothing" and "the perturbation never happened"
 * look identical in the output and must not be confused.
 */
int juno_tb_cells[64];
int juno_tb_ncells = 0;
/* Which hook SITE fires. Site 0 is the tail of the render (measures CARRIAGE
 * across the sample boundary); sites >=1 sit at module boundaries inside the
 * render, and measure the question a rewrite actually needs answered -- if this
 * module's outputs were slightly wrong, would anything downstream notice, in
 * this same sample? A cell consumed and discarded within the sample is invisible
 * at site 0 by construction, so site 0 UNDERSTATES module observability. */
int juno_tb_site = 0;

/* The perturbation itself: v' = v*MUL + ADD, both settable at runtime.
 *
 * WHY IT IS NOT ONE FIXED TINY NUDGE. Two different jobs need two different
 * perturbations and conflating them under-reports:
 *   CLASSIFICATION ("does this cell matter at all") wants the LARGEST
 *     perturbation that is still a perturbation, because a false "invisible" is
 *     the dangerous direction -- it is the licence to drop a value into a
 *     register. Default 1.001 / 1e-6.
 *   CALIBRATION ("how many dB is a 2-ULP error worth") wants the tiny one:
 *     1.00000012 / 0.
 * Measured, and the reason this exists: with v*1.00000012f + 1e-20f the GATE
 * cell 560 read NOT-CARRIED at every site -- the 1e-20 term is annihilated by
 * the first multiply and flushed. With an additive 1.0f it changes 83996 of
 * 84000 samples. The additive floor must survive FTZ and a multiply by an O(1)
 * coefficient, and 1e-20 does not. */
float juno_tb_mul = 1.001f;
float juno_tb_add = 1e-6f;

void juno_tb_set_cells(const int *cells, int n)
{
    int i;
    if (n > 64) n = 64;
    for (i = 0; i < n; i++) juno_tb_cells[i] = cells[i];
    juno_tb_ncells = n;
}

void juno_tb_set_site(int site) { juno_tb_site = site; }

void juno_tb_set_gain(float mul, float add) { juno_tb_mul = mul; juno_tb_add = add; }
