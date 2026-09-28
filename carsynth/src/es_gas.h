/* es_gas.h -- C99 port of engine-sim GasSystem (include/gas_system.h,
 * src/gas_system.cpp, MIT, Ange Yaghi). Same arithmetic, same order. */
#ifndef ES_GAS_H
#define ES_GAS_H

#define ES_AIR_MOLECULAR_MASS 0.02897   /* units::AirMolecularMass, kg/mol */
#define ES_ATM  101325.0
#define ES_C0K  273.15

typedef struct { double p_fuel, p_inert, p_o2; } es_mix;
static const es_mix ES_MIX_DEFAULT = {0.0, 1.0, 0.0};

typedef struct {
    double n_mol, E_k, V, mom[2];
    es_mix mix;
    int    dof;
    double choked_limit, choked_factor;
    double width, height, dx, dy;
} es_gas;

typedef struct {
    double k_flow, dt, direction_x, direction_y;
    double cross0, cross1;
    es_gas *s0, *s1;
} es_flow_params;

void   es_gas_set_geometry(es_gas *g, double w, double h, double dx, double dy);
void   es_gas_initialize(es_gas *g, double P, double V, double T, es_mix mix, int dof);
void   es_gas_reset(es_gas *g, double P, double T, es_mix mix);
void   es_gas_set_volume(es_gas *g, double V);
void   es_gas_change_volume(es_gas *g, double dV);
void   es_gas_change_energy(es_gas *g, double dE);
double es_gas_react(es_gas *g, double n, es_mix mix);
double es_gas_flow_constant(double target, double P, double drop, double T, double hcr);
double es_k_28inH2O(double scfm);
double es_k_carb(double scfm);
double es_gas_flow_rate(double k, double P0, double P1, double T0, double T1,
                        double hcr, double choked_limit, double choked_rate);
double es_gas_lose_n(es_gas *g, double dn, double ek_per_mol);
double es_gas_gain_n(es_gas *g, double dn, double ek_per_mol, es_mix mix);
void   es_gas_dissipate_excess_velocity(es_gas *g);
void   es_gas_update_velocity(es_gas *g, double dt, double beta);
double es_gas_flow(const es_flow_params *p);
double es_gas_flow_env(es_gas *g, double k, double dt, double P_env, double T_env, es_mix mix);

double es_gas_pressure(const es_gas *g);
double es_gas_temperature(const es_gas *g);
double es_gas_dynamic_pressure(const es_gas *g, double dx, double dy);
double es_gas_mass(const es_gas *g);
double es_gas_c(const es_gas *g);
double es_gas_hcr(const es_gas *g);
static inline double es_gas_n(const es_gas *g) { return g->n_mol; }
static inline double es_gas_volume(const es_gas *g) { return g->V; }

#endif
