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

void juno_tb_set_cells(const int *cells, int n)
{
    int i;
    if (n > 64) n = 64;
    for (i = 0; i < n; i++) juno_tb_cells[i] = cells[i];
    juno_tb_ncells = n;
}
