/* es_func.h -- C99 port of engine-sim Function (src/function.cpp): a sorted
 * sample table read with a triangle filter. Fixed capacity, no malloc. */
#ifndef ES_FUNC_H
#define ES_FUNC_H

#define ES_FUNC_CAP 520

typedef struct {
    double x[ES_FUNC_CAP], y[ES_FUNC_CAP];
    int size;
    double radius;
} es_func;

void   es_func_init(es_func *f, double filter_radius);
void   es_func_add(es_func *f, double x, double y);
double es_func_tri(const es_func *f, double x);
/* harmonic_cam_lobe (scripting/include/actions.h GenerateHarmonicCamLobeNode) */
void   es_func_harmonic_cam_lobe(es_func *f, double duration_at_50_thou, double gamma,
                                 double lift, int steps);
#endif
