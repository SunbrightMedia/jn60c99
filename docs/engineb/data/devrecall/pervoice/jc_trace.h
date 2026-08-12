#ifndef JC_TRACE_H
#define JC_TRACE_H
#include <stdint.h>
extern unsigned char *jc_base;
extern int jc_on, jc_dev, jc_nscat, jc_auxfold;
extern unsigned jc_scat[32];
extern float jc_scatv[8][32];
extern unsigned long jc_miss, jc_lastmiss;
void *jc_at(unsigned char *p, unsigned long off, const char *file, int line);
void jc_dump(const char *path);
void jc_reset(void);
void jc_sel(int v);
extern unsigned char *jc_tile;
#endif
