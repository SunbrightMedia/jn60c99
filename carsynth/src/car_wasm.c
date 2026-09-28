/* car_wasm.c -- wasm export surface: static buffers + thin calls. */
#include "car.h"

#define CAR_WASM_MAXN 1024
static float bufL[CAR_WASM_MAXN], bufR[CAR_WASM_MAXN];

__attribute__((export_name("init")))    void  w_init(void)                { car_init(); }
__attribute__((export_name("set")))     void  w_set(int p, float v)       { car_set(p, v); }
__attribute__((export_name("on")))      void  w_on(int n, float v)        { car_note_on(n, v); }
__attribute__((export_name("off")))     void  w_off(int n)                { car_note_off(n); }
__attribute__((export_name("meter")))   float w_meter(int w)              { return car_meter(w); }
__attribute__((export_name("bufL")))    float *w_bufL(void)               { return bufL; }
__attribute__((export_name("bufR")))    float *w_bufR(void)               { return bufR; }
__attribute__((export_name("ename")))   const char *w_ename(int i)        { return car_engine_name(i); }
__attribute__((export_name("xname")))   const char *w_xname(int i)        { return car_exhaust_name(i); }
__attribute__((export_name("render")))  void  w_render(int n)
{
    if (n > CAR_WASM_MAXN) n = CAR_WASM_MAXN;
    car_render(bufL, bufR, n);
}
