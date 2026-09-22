#include <stdint.h>
static inline float fmin_ss(float a, float b){return (a < b) ? a : b;}
static inline float fmax_ss(float a, float b){return (a > b) ? a : b;}
volatile float x,y,z; void f(void){ z=fmin_ss(x,y); } void g(void){ z=fmax_ss(x,y);} float h(float a,float b){return (a<b)?a:b;}
