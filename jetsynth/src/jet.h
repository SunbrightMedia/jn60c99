/* jet.h -- JETSYNTH: a turbofan engine you play.
 *
 * Source spectra come from pyNA (MIT; NASA ANOPP methods, gated against NASA's
 * STCA verification data) baked into gen/jet_tables.h. FX are the JUNO-60
 * port's own chorus / delay / reverb (engine_b), driven by coefficient sets the
 * proven recall built (gen/jet_fx_coefs.h).
 *
 * Seven controls, every one 0..1. They are coupled on purpose:
 *   THROTTLE  power lever. The engine does not follow it directly -- the SPOOL
 *             does, and every sound source reads the spool state.
 *   SPOOL     spool response time (0.25 s .. 12 s). Scaled by SIZE (a bigger
 *             engine has more rotor inertia); spools up slower than down.
 *   SPEED     flight Mach 0 .. 0.4. Reduces jet noise (relative velocity),
 *             Doppler-shifts every tone by ANGLE, convective amplification.
 *   ANGLE     listener angle from the inlet axis, 0 (front) .. 180 (behind).
 *             Front: fan whine + buzz-saw. Behind: jet roar.
 *   DISTANCE  15 m .. 800 m. Spreading + sea-level air absorption (highs die
 *             first). Also raises the FX sends: far = more air, more room.
 *   SIZE      engine scale 0.5x .. 2x. Rotor and jet frequencies scale 1/size
 *             (geometric similarity), level +20 log size, core does not move.
 *   SPACE     amount of JUNO chorus (air turbulence), delay (echo) and reverb.
 *   CHARACTER real engine (0) .. movie engine (1). Raises the fan whine and
 *             buzz-saw above the roar (at the source they sit 15-40 dB under
 *             it), and adds jet crackle (power- and aft-angle-dependent),
 *             sub rumble, large-eddy pulsing and a compressor whine.
 * Plus one performance input, BOOST (0/1): while held, the throttle target is
 * full power -- a drum-like hit whose attack is set by SPOOL.
 */
#ifndef JET_H
#define JET_H

enum {
    JET_THROTTLE, JET_SPOOL, JET_SPEED, JET_ANGLE, JET_DISTANCE, JET_SIZE,
    JET_SPACE, JET_BOOST, JET_CHARACTER, JET_NPARAM
};

void  jet_init(float sample_rate);
void  jet_set(int param, float v01);
float jet_get(int param);
/* Render n stereo frames into L and R. */
void  jet_render(float *L, float *R, int n);
/* Telemetry for a UI: 0 spool state (TS), 1 fan rpm, 2 BPF heard (Hz),
 * 3 tip Mach, 4 output peak (last block). */
float jet_meter(int which);

#endif
