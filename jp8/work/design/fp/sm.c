#include "jp8_cpu.h"
void t_mul(CPU *c) { XF(1,0) = JP8_MULSS(XF(1,0), MF(0x180b572a0ULL)); }
void t_add(CPU *c) { XF(1,0) = JP8_ADDSS(XF(1,0), XF(2,0)); }
