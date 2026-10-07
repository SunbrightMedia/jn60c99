/* host_edit.c -- the plugin's HOST-ROLE parameter edits (CLAIMS B7). See
 * host_edit.h. */
#include "host_edit.h"

#ifndef EB_DEVCELLS
#include "juno_engine.h"
#include "recall_ramp.h"
#include "delay_recall.h"      /* juno_lfx1_value */
#include "host_ramp_table.h"
#include "juno_curve.h"
#include <string.h>

#define NPARAMS ((int)(sizeof(JH_PARAMS) / sizeof(JH_PARAMS[0])))

int juno_host_edit_known(int hp)
{
    return hp >= 0 && hp < NPARAMS && JH_PARAMS[hp].feat != 0xFFFFu;
}

static int clamp6(int v) { return v < 0 ? 0 : v > 5 ? 5 : v; }

/* the mixed-radix key, features in the generator's order (JH_F_*) */
static long key_index(const jh_param *p, const juno_host_feat *f)
{
    long idx = 0;
    int span = p->hi - p->lo + 1;
    static const int ETC[6] = { 0, 1, 2, 2, 2, 3 };
    if (p->feat & JH_F_ET)    idx = idx * 6 + clamp6(f->et);
    if (p->feat & JH_F_DT)    idx = idx * 6 + clamp6(f->dt);
    if (p->feat & JH_F_FROM)  { if (f->from < p->lo || f->from > p->hi) return -1; idx = idx * span + (f->from - p->lo); }
    if (p->feat & JH_F_TO)    { if (f->to < p->lo || f->to > p->hi) return -1; idx = idx * span + (f->to - p->lo); }
    if (p->feat & JH_F_DON1)  idx = idx * 2 + (f->don1 != 0);
    if (p->feat & JH_F_RON0)  idx = idx * 2 + (f->ron0 != 0);
    if (p->feat & JH_F_RON1)  idx = idx * 2 + (f->ron1 != 0);
    if (p->feat & JH_F_PL)    idx = idx * 2 + (f->pl != 0);
    if (p->feat & JH_F_ARPON) idx = idx * 2 + (f->arpon != 0);
    if (p->feat & JH_F_ETC)   idx = idx * 4 + ETC[clamp6(f->et)];
    return (idx >= 0 && idx < (long)p->nprog) ? idx : -1;
}

static const jh_prog *prog_of(int hp, const juno_host_feat *f)
{
    const jh_param *p;
    long idx;
    if (!juno_host_edit_known(hp)) return 0;
    p = &JH_PARAMS[hp];
    idx = key_index(p, f);
    if (idx < 0 || JH_PROGS[p->prog0 + (uint32_t)idx].count == JH_NONE) return 0;
    return &JH_PROGS[p->prog0 + (uint32_t)idx];
}

int juno_host_edit_covered(int hp, const juno_host_feat *f) { return prog_of(hp, f) != 0; }

/* The VCF CUTOFF setter's host-role ramp time (rva 0x3597F0, READ; EXECUTED
 * by the census: a step of 3 -> index 6, of 1 -> 12): the bigger the step,
 * the shorter the glide, never under index 5 (24 ms). */
static int cutoff_time(const juno_host_feat *f)
{
    int d = f->to - f->from, t;
    if (d < 0) d = -d;
    if (d > 5) d = 5;
    t = 3 * (5 - d);
    return t < 5 ? 5 : t;
}

/* The arpeggiator's refresh runs only while the PROCESSOR's arp is on (a
 * host ARPEGGIO SW edit moves that state; a recall does not), and the switch
 * runs it only when it turns the arp on (EXECUTED; src/host_ramp_table.h). */
static int gated_off(int hp, const juno_host_feat *f)
{
    switch (JH_PARAMS[hp].gate) {
    case JH_G_ARP_ON:      return !f->arpon;
    case JH_G_ARP_TURN_ON: return f->arpon || f->to == 0;
    default:               return 0;
    }
}

/* The arp refresh's cutoff re-send (leaf 312, rva 0x3B9990): the VCF CUTOFF
 * setter in the host role, so the step law runs from the object's last value
 * to the stored byte, which becomes the last value (rva 0x3597F0). */
static int cutoff_resend_time(unsigned char *st, int byte)
{
    int d = byte - juno_rr_cut_last(st), t;
    if (d < 0) d = -d;
    if (d > 5) d = 5;
    t = 3 * (5 - d);
    return t < 5 ? 5 : t;
}

int juno_host_edit(unsigned char *st, const unsigned char *settled, int hp, const juno_host_feat *f)
{
    const jh_prog *pg = prog_of(hp, f);
    uint32_t k;
    int Hr = (int)JF(st, 16), resend_t = -1;
    if (!pg) return -1;
    if (gated_off(hp, f)) return 0;
    if (Hr <= 0) Hr = 96000;
    for (k = 0; k < pg->count; ++k) {
        const jh_op *o = &JH_OPS[pg->first + k];
        uint32_t bits;
        float v;
        int t = o->t;
        switch (o->src) {
        case JH_ZERO: bits = 0u; break;
        case JH_ONE:  bits = 0x3f800000u; break;
        case JH_OFF:  v = juno_lfx1_value(Hr, 0); memcpy(&bits, &v, 4); break;
        case JH_TAP2: bits = juno_rr_tap2_bits(st); break;
        case JH_HOSTV: bits = (uint32_t)f->to; break;   /* the host's value itself (H leaves) */
        case JH_CURVE: v = juno_curve(o->pad, f->to); memcpy(&bits, &v, 4); break;   /* MASTER TUNE: curve 55 */
        default:      memcpy(&bits, settled + o->cell, 4); break;   /* JH_REC */
        }
        if (t & 0x80) t = cutoff_time(f);
        if (t & 0x40) {                     /* every voice's object: one law, one last value */
            if (resend_t < 0) resend_t = cutoff_resend_time(st, f->cutbyte);
            t = resend_t;
        }
        if (o->kind == JH_RAMP) {
            memcpy(&v, &bits, 4);
            juno_rr_arm(st, o->cell, v, t);
        } else {
            memcpy(st + o->cell, &bits, 4);   /* immediate set / direct write */
        }
    }
    if (resend_t >= 0) juno_rr_set_cut_last(st, f->cutbyte);
    return (int)pg->count;
}

#else   /* EB_DEVCELLS */
int juno_host_edit_known(int hp) { (void)hp; return 0; }
int juno_host_edit_covered(int hp, const juno_host_feat *f) { (void)hp; (void)f; return 0; }
int juno_host_edit(unsigned char *st, const unsigned char *settled, int hp, const juno_host_feat *f)
{ (void)st; (void)settled; (void)hp; (void)f; return -1; }
#endif
