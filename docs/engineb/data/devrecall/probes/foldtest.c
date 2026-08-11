#include "ebdev.h"
ebdev_state EBS_;
#define JF(st,off) (*(float*)ebdev_at((unsigned long)(off)))
float read_cold_const(void){ return JF(0, 6736); }     /* voice tile */
float read_seg_const(void){ return JF(0, 10693072); }  /* deep segment */
void  write_seg_const(float v){ JF(0, 4297792) = v; }
float read_runtime(unsigned long o){ return JF(0, o); }
