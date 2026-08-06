/* Which DELAY arm do the 64 factory patches actually select?
 *
 * The engine is PRICED at the worst arm -- DELAY type 5, 1,979 instructions --
 * because exactly one arm runs and a budget must cover the worst. Nobody has
 * ever counted what a typical patch selects, and the spread between the arms
 * is 1,659 instructions in a chain whose MEASURED cycles-per-instruction is
 * 2.36. That is 3,915 cycles, more than a third of the whole two-core budget.
 */
#include <stdio.h>
#include <stdlib.h>
#include "juno_apply.h"
int main(int argc, char **argv)
{
    FILE *f = fopen(argv[1], "rb");
    static unsigned char bank[1 << 20];
    size_t n = fread(bank, 1, sizeof bank, f);
    int cnt[8] = {0}, p, np;
    (void)argc;
    np = juno_bank_num_patches(bank, (unsigned long)n);
    for (p = 0; p < np; ++p) {
        int t = -1;
        if (juno_bank_delay_modes(bank, p, NULL, NULL, &t) && t >= 0 && t < 8)
            cnt[t]++;
    }
    printf("patches=%d  DELAY TYPE:", np);
    for (p = 0; p < 8; ++p) if (cnt[p]) printf("  type%d=%d", p, cnt[p]);
    printf("\n");
    return 0;
}
