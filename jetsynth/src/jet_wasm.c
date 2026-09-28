/* jet_wasm.c -- the wasm export surface: static audio buffers + thin calls. */
#include "jet.h"

#define JET_WASM_MAXN 1024
static float bufL[JET_WASM_MAXN], bufR[JET_WASM_MAXN];

__attribute__((export_name("init")))   void  w_init(float sr)       { jet_init(sr); }
__attribute__((export_name("set")))    void  w_set(int p, float v)  { jet_set(p, v); }
__attribute__((export_name("meter")))  float w_meter(int w)         { return jet_meter(w); }
__attribute__((export_name("bufL")))   float *w_bufL(void)          { return bufL; }
__attribute__((export_name("bufR")))   float *w_bufR(void)          { return bufR; }
__attribute__((export_name("render"))) void  w_render(int n)
{
    if (n > JET_WASM_MAXN) n = JET_WASM_MAXN;
    jet_render(bufL, bufR, n);
}
