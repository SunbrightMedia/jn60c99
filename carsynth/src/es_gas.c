/* es_gas.c -- C99 port of engine-sim src/gas_system.cpp (MIT, Ange Yaghi).
 * Line-for-line: every expression keeps upstream's order and grouping. */
#include "es_gas.h"
#include "es_math.h"

static double ek_per_mol_T(double T, int dof) { return 0.5 * T * ES_R * dof; }
static double hcr_dof(int dof) { return 1.0 + (2.0 / dof); }
static double choked_flow_limit(int dof)
{
    const double hcr = hcr_dof(dof);
    return es_pow((2.0 / (hcr + 1)), hcr / (hcr - 1));
}
static double choked_flow_rate(int dof)
{
    const double hcr = hcr_dof(dof);
    return es_sqrt(hcr) * es_pow(2 / (hcr + 1), (hcr + 1) / (2 * (hcr - 1)));
}

double es_gas_hcr(const es_gas *g) { return hcr_dof(g->dof); }
double es_gas_mass(const es_gas *g) { return ES_AIR_MOLECULAR_MASS * g->n_mol; }
static double density(const es_gas *g) { return (ES_AIR_MOLECULAR_MASS * g->n_mol) / g->V; }
static double ek_n(const es_gas *g, double n) { return (g->E_k / g->n_mol) * n; }
static double ek_per_mol(const es_gas *g) { return ek_n(g, 1.0); }
static double n_fuel(const es_gas *g) { return g->mix.p_fuel * g->n_mol; }
static double n_inert(const es_gas *g) { return g->mix.p_inert * g->n_mol; }
static double n_o2(const es_gas *g) { return g->mix.p_o2 * g->n_mol; }

double es_gas_pressure(const es_gas *g)
{
    const double volume = g->V;
    return (volume != 0) ? g->E_k / (0.5 * g->dof * volume) : 0;
}
double es_gas_temperature(const es_gas *g)
{
    if (g->n_mol == 0) return 0;
    return g->E_k / (0.5 * g->dof * g->n_mol * ES_R);
}
double es_gas_c(const es_gas *g)
{
    double hcr, sp, rho;
    if (g->n_mol == 0 || g->E_k == 0) return 0;
    hcr = es_gas_hcr(g);
    sp = es_gas_pressure(g);
    rho = density(g);
    return es_sqrt(sp * hcr / rho);
}
static double bulk_ek(const es_gas *g)
{
    const double m = es_gas_mass(g);
    double vx, vy;
    if (m == 0) return 0;
    vx = g->mom[0] / m;
    vy = g->mom[1] / m;
    return 0.5 * m * (vx * vx + vy * vy);
}
static double total_energy(const es_gas *g)
{
    double inv, vx, vy;
    if (g->n_mol == 0) return 0;
    inv = 1 / es_gas_mass(g);
    vx = g->mom[0] * inv;
    vy = g->mom[1] * inv;
    return g->E_k + 0.5 * es_gas_mass(g) * (vx * vx + vy * vy);
}
double es_gas_dynamic_pressure(const es_gas *g, double dx, double dy)
{
    double inv, v, hcr, sp, rho, c2, M2, x, xd;
    if (g->n_mol == 0 || g->E_k == 0) return 0;
    inv = 1 / es_gas_mass(g);
    v = inv * (dx * g->mom[0] + dy * g->mom[1]);
    if (v <= 0) return 0;
    hcr = es_gas_hcr(g);
    sp = es_gas_pressure(g);
    rho = density(g);
    c2 = sp * hcr / rho;
    M2 = v * v / c2;
    x = 1 + ((hcr - 1) / 2) * M2;
    switch (g->dof) {
    case 3: xd = x * x * x * x * x; break;
    case 5: { const double x2 = x * x, x3 = x2 * x; xd = x3 * x3 * x; break; }
    default: xd = x;
    }
    return sp * (es_sqrt(xd) - 1);
}

void es_gas_set_geometry(es_gas *g, double w, double h, double dx, double dy)
{
    g->width = w; g->height = h; g->dx = dx; g->dy = dy;
}
void es_gas_initialize(es_gas *g, double P, double V, double T, es_mix mix, int dof)
{
    g->dof = dof;
    g->n_mol = P * V / (ES_R * T);
    g->V = V;
    g->E_k = T * (0.5 * dof * g->n_mol * ES_R);
    g->mix = mix;
    g->mom[0] = g->mom[1] = 0;
    g->choked_limit = choked_flow_limit(dof);
    g->choked_factor = choked_flow_rate(dof);
}
void es_gas_reset(es_gas *g, double P, double T, es_mix mix)
{
    g->n_mol = P * g->V / (ES_R * T);
    g->E_k = T * (0.5 * g->dof * g->n_mol * ES_R);
    g->mix = mix;
    g->mom[0] = g->mom[1] = 0;
}
void es_gas_change_volume(es_gas *g, double dV)
{
    const double V = g->V;
    const double L = es_pow(V + dV, 1 / 3.0);
    const double sa = (L * L);
    const double dL = -dV / sa;
    const double W = dL * es_gas_pressure(g) * sa;
    g->V += dV;
    g->E_k += W;
}
void es_gas_set_volume(es_gas *g, double V) { es_gas_change_volume(g, V - g->V); }
void es_gas_change_energy(es_gas *g, double dE) { g->E_k += dE; }

double es_gas_react(es_gas *g, double n, es_mix mix)
{
    const double l_n_fuel = mix.p_fuel * n;
    const double l_n_o2 = mix.p_o2 * n;
    const double s_fuel = n_fuel(g), s_o2 = n_o2(g), s_inert = n_inert(g), s_n = g->n_mol;
    const double ideal_o2_ratio = 25.0 / 2;
    const double ideal_fuel_ratio = 2.0 / 25;
    const double out_in = (16.0 + 18.0) / (25 + 2);
    const double ideal_fuel_n = ideal_fuel_ratio * l_n_o2;
    const double ideal_o2_n = ideal_o2_ratio * l_n_fuel;
    const double a_fuel = es_fmin(es_fmin(s_fuel, l_n_fuel), ideal_fuel_n);
    const double a_o2 = es_fmin(es_fmin(s_o2, l_n_o2), ideal_o2_n);
    const double reactants = a_fuel + a_o2;
    const double products = out_in * reactants;
    const double dn = products - reactants;
    const double nf = s_fuel - a_fuel, no = s_o2 - a_o2, ni = s_inert + products;
    const double nn = s_n + dn;
    g->n_mol += dn;
    if (nn != 0) {
        g->mix.p_fuel = nf / nn;
        g->mix.p_inert = ni / nn;
        g->mix.p_o2 = no / nn;
    } else {
        g->mix.p_fuel = g->mix.p_inert = g->mix.p_o2 = 0;
    }
    return a_fuel;
}

double es_gas_flow_constant(double target, double P, double drop, double T, double hcr)
{
    const double T_0 = T, p_0 = P, p_T = P - drop;
    const double lim = es_pow((2.0 / (hcr + 1)), hcr / (hcr - 1));
    const double r = p_T / p_0;
    double fr;
    if (r <= lim) {
        fr = es_sqrt(hcr);
        fr *= es_pow(2 / (hcr + 1), (hcr + 1) / (2 * (hcr - 1)));
    } else {
        fr = (2 * hcr) / (hcr - 1);
        fr *= (1 - es_pow(r, (hcr - 1) / hcr));
        fr = es_sqrt(fr);
        fr *= es_pow(r, 1 / hcr);
    }
    fr *= p_0 / es_sqrt(ES_R * T_0);
    return target / fr;
}
/* units::scfm = 0.002641 lbmol/min; lbmol = 453.59237 mol */
#define ES_SCFM (0.002641 * 453.59237 / 60.0)
#define ES_INHG 3386.3886666666713
double es_k_28inH2O(double scfm)
{
    return es_gas_flow_constant(scfm * ES_SCFM, ES_ATM, 28.0 * (ES_INHG * 0.0734824),
                                25.0 + ES_C0K, hcr_dof(5));
}
double es_k_carb(double scfm)
{
    return es_gas_flow_constant(scfm * ES_SCFM, ES_ATM, 1.5 * ES_INHG, 25.0 + ES_C0K, hcr_dof(5));
}

double es_gas_flow_rate(double k, double P0, double P1, double T0, double T1,
                        double hcr, double lim, double choked)
{
    double dir, T_0, p_0, p_T, r, fr = 0;
    if (k == 0) return 0;
    if (P0 > P1) { dir = 1.0; T_0 = T0; p_0 = P0; p_T = P1; }
    else         { dir = -1.0; T_0 = T1; p_0 = P1; p_T = P0; }
    r = p_T / p_0;
    if (r <= lim) {
        fr = choked;
        fr /= es_sqrt(ES_R * T_0);
    } else {
        const double s = es_pow(r, 1 / hcr);
        fr = (2 * hcr) / (hcr - 1);
        fr *= s * (s - r);
        fr = es_sqrt(es_fmax(fr, 0.0) / (ES_R * T_0));
    }
    fr *= dir * p_0;
    return fr * k;
}

double es_gas_lose_n(es_gas *g, double dn, double e)
{
    g->E_k -= e * dn;
    g->n_mol -= dn;
    if (g->n_mol < 0) g->n_mol = 0;
    return dn;
}
double es_gas_gain_n(es_gas *g, double dn, double e, es_mix mix)
{
    const double next = g->n_mol + dn, cur = g->n_mol;
    g->E_k += dn * e;
    g->n_mol = next;
    if (next != 0) {
        g->mix.p_fuel = (g->mix.p_fuel * cur + dn * mix.p_fuel) / next;
        g->mix.p_inert = (g->mix.p_inert * cur + dn * mix.p_inert) / next;
        g->mix.p_o2 = (g->mix.p_o2 * cur + dn * mix.p_o2) / next;
    } else {
        g->mix.p_fuel = g->mix.p_inert = g->mix.p_o2 = 0;
    }
    return -dn;
}

void es_gas_dissipate_excess_velocity(es_gas *g)
{
    double vx, vy, v2, c, c2, k;
    if (g->n_mol == 0) { vx = vy = 0; }
    else { vx = g->mom[0] / es_gas_mass(g); vy = g->mom[1] / es_gas_mass(g); }
    v2 = vx * vx + vy * vy;
    if (v2 == 0) return;          /* upstream returns here too; skips the sqrt */
    c = es_gas_c(g);
    c2 = c * c;
    if (c2 >= v2) return;
    k = es_sqrt(c2 / v2);
    g->mom[0] *= k;
    g->mom[1] *= k;
    g->E_k += 0.5 * es_gas_mass(g) * (v2 - c2);
    if (g->E_k < 0) g->E_k = 0;
}

void es_gas_update_velocity(es_gas *g, double dt, double beta)
{
    double depth, dmx = 0, dmy = 0, p0, p1, p2, p3, s0, s1, s2, s3, m, inv, v0x, v0y, v1x, v1y;
    if (g->n_mol == 0) return;
    depth = g->V / (g->width * g->height);
    p0 = es_gas_dynamic_pressure(g, g->dx, g->dy);
    p1 = es_gas_dynamic_pressure(g, -g->dx, -g->dy);
    p2 = es_gas_dynamic_pressure(g, g->dy, g->dx);
    p3 = es_gas_dynamic_pressure(g, -g->dy, -g->dx);
    s0 = p0 * (g->height * depth);
    s1 = p1 * (g->height * depth);
    s2 = p2 * (g->width * depth);
    s3 = p3 * (g->width * depth);
    dmx += s0 * g->dx; dmy += s0 * g->dy;
    dmx -= s1 * g->dx; dmy -= s1 * g->dy;
    dmx += s2 * g->dy; dmy += s2 * g->dx;
    dmx -= s3 * g->dy; dmy -= s3 * g->dx;
    m = es_gas_mass(g);
    inv = 1 / m;
    v0x = g->mom[0] * inv; v0y = g->mom[1] * inv;
    g->mom[0] -= dmx * dt * beta;
    g->mom[1] -= dmy * dt * beta;
    v1x = g->mom[0] * inv; v1y = g->mom[1] * inv;
    g->E_k -= 0.5 * m * (v1x * v1x - v0x * v0x);
    g->E_k -= 0.5 * m * (v1y * v1y - v0y * v0y);
    if (g->E_k < 0) g->E_k = 0;
}

double es_gas_flow(const es_flow_params *p)
{
    es_gas *src, *snk;
    double sP, kP, dx, dy, sX, kX, dir, P_0, P_1, flow, fraction, fvol, fmass;
    double sM, invS, kM, invK, cS, cK, sm0x, sm0y, km0x, km0y;

    P_0 = es_gas_pressure(p->s0) + es_gas_dynamic_pressure(p->s0, p->direction_x, p->direction_y);
    P_1 = es_gas_pressure(p->s1) + es_gas_dynamic_pressure(p->s1, -p->direction_x, -p->direction_y);
    if (P_0 > P_1) {
        dx = p->direction_x; dy = p->direction_y; src = p->s0; snk = p->s1;
        sP = P_0; kP = P_1; sX = p->cross0; kX = p->cross1; dir = 1.0;
    } else {
        dx = -p->direction_x; dy = -p->direction_y; src = p->s1; snk = p->s0;
        sP = P_1; kP = P_0; sX = p->cross1; kX = p->cross0; dir = -1.0;
    }
    flow = p->dt * es_gas_flow_rate(p->k_flow, sP, kP, es_gas_temperature(src),
                                    es_gas_temperature(snk), es_gas_hcr(src),
                                    src->choked_limit, src->choked_factor);
    /* upstream computes pressureEquilibriumMaxFlow(sink) here and never uses it */
    flow = es_clamp(flow, 0.0, 0.9 * src->n_mol);
    fraction = flow / src->n_mol;
    fvol = fraction * src->V;
    fmass = fraction * es_gas_mass(src);

    if (flow != 0) {
        const double bs0 = bulk_ek(src), bk0 = bulk_ek(snk);
        const double e = ek_per_mol(src);
        double dpx, dpy, bs1, bk1;
        es_gas_gain_n(snk, flow, e, src->mix);
        es_gas_lose_n(src, flow, e);
        dpx = src->mom[0] * fraction;
        dpy = src->mom[1] * fraction;
        src->mom[0] -= dpx; src->mom[1] -= dpy;
        snk->mom[0] += dpx; snk->mom[1] += dpy;
        bs1 = bulk_ek(src); bk1 = bulk_ek(snk);
        snk->E_k -= ((bs1 + bk1) - (bs0 + bk0));
    }

    sM = es_gas_mass(src); invS = 1 / sM;
    kM = es_gas_mass(snk); invK = 1 / kM;
    cS = es_gas_c(src); cK = es_gas_c(snk);
    sm0x = src->mom[0]; sm0y = src->mom[1];
    km0x = snk->mom[0]; km0y = snk->mom[1];

    if (kX != 0) {
        const double v = es_clamp((fvol / kX) / p->dt, 0.0, cK);
        snk->mom[0] += v * dx * fmass;
        snk->mom[1] += v * dy * fmass;
    }
    if (sX != 0 && sM != 0) {
        const double v = es_clamp((fvol / sX) / p->dt, 0.0, cS);
        src->mom[0] += v * dx * fmass;
        src->mom[1] += v * dy * fmass;
    }
    if (sM != 0) {
        const double v0x = sm0x * invS, v0y = sm0y * invS;
        const double v1x = src->mom[0] * invS, v1y = src->mom[1] * invS;
        src->E_k -= 0.5 * sM * (v1x * v1x - v0x * v0x);
        src->E_k -= 0.5 * sM * (v1y * v1y - v0y * v0y);
    }
    if (kM > 0) {
        const double v0x = km0x * invK, v0y = km0y * invK;
        const double v1x = snk->mom[0] * invK, v1y = snk->mom[1] * invK;
        snk->E_k -= 0.5 * kM * (v1x * v1x - v0x * v0x);
        snk->E_k -= 0.5 * kM * (v1y * v1y - v0y * v0y);
    }
    if (snk->E_k < 0) snk->E_k = 0;
    if (src->E_k < 0) src->E_k = 0;
    return flow * dir;
}

static double eq_max_flow_env(const es_gas *g, double P_env, double T_env)
{
    if (es_gas_pressure(g) > P_env)
        return -(P_env * (0.5 * g->dof * g->V) - g->E_k) / ek_per_mol(g);
    else {
        const double e_env = 0.5 * T_env * ES_R * g->dof;
        return -(P_env * (0.5 * g->dof * g->V) - g->E_k) / e_env;
    }
}

double es_gas_flow_env(es_gas *g, double k, double dt, double P_env, double T_env, es_mix mix)
{
    const double maxFlow = eq_max_flow_env(g, P_env, T_env);
    double flow = dt * es_gas_flow_rate(k, es_gas_pressure(g), P_env, es_gas_temperature(g),
                                        T_env, es_gas_hcr(g), g->choked_limit, g->choked_factor);
    if (es_fabs(flow) > es_fabs(maxFlow)) flow = maxFlow;
    if (flow < 0) {
        const double b0 = bulk_ek(g);
        double b1;
        es_gas_gain_n(g, -flow, ek_per_mol_T(T_env, g->dof), mix);
        b1 = bulk_ek(g);
        g->E_k += (b1 - b0);
    } else {
        const double n0 = g->n_mol;
        es_gas_lose_n(g, flow, ek_per_mol(g));
        g->mom[0] -= (flow / n0) * g->mom[0];
        g->mom[1] -= (flow / n0) * g->mom[1];
    }
    return flow;
}
