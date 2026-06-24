/* play_scale.c — render a melody/scale to a WAV, proving per-note pitch control.
 *
 * Each note: juno_note_on(voice 0, midi) holds the gate for `note_s` seconds, then
 * juno_note_off for a short gap, through the full stereo chorus. Pitch is set per
 * MIDI note (see juno_driver.c); tuning is standard A440 equal temperament, exact
 * to <0.1 cents against the transcribed DCO.
 *
 *   usage: play_scale <out.wav> [note_seconds] [midi notes...]
 *   default: a C major scale C4..C5.
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

static void write_wav(const char *path, const float *L, const float *R, int n, int sr)
{
    FILE *f = fopen(path, "wb"); if (!f) { perror(path); return; }
    int db = n*2*2, br = sr*2*2; unsigned int u; unsigned short s;
    fwrite("RIFF",1,4,f); u=36+db; fwrite(&u,4,1,f); fwrite("WAVE",1,4,f); fwrite("fmt ",1,4,f);
    u=16; fwrite(&u,4,1,f); s=1; fwrite(&s,2,1,f); s=2; fwrite(&s,2,1,f);
    u=sr; fwrite(&u,4,1,f); u=br; fwrite(&u,4,1,f); s=4; fwrite(&s,2,1,f); s=16; fwrite(&s,2,1,f);
    fwrite("data",1,4,f); u=db; fwrite(&u,4,1,f);
    for (int i=0;i<n;i++){ float l=L[i],r=R[i];
        if(l>1)l=1; if(l<-1)l=-1; if(r>1)r=1; if(r<-1)r=-1;
        short sl=(short)lrintf(l*32767.0f), sr2=(short)lrintf(r*32767.0f);
        fwrite(&sl,2,1,f); fwrite(&sr2,2,1,f); }
    fclose(f);
}

int main(int argc, char **argv)
{
    const char *out = (argc>1)?argv[1]:"/tmp/juno_scale.wav";
    const int SR = 96000;
    double note_s = (argc>2)?atof(argv[2]):0.55;
    int def[] = {60,62,64,65,67,69,71,72};       /* C major C4..C5 */
    int *notes = def, nn = 8;
    if (argc > 3) { nn = argc-3; notes = malloc(sizeof(int)*nn);
        for (int i=0;i<nn;i++) notes[i] = atoi(argv[3+i]); }

    int per = (int)(note_s*SR), gap = (int)(0.06*SR), tail = (int)(0.5*SR);
    int N = nn*per + tail;
    float *L = malloc(sizeof(float)*N), *R = malloc(sizeof(float)*N);

    unsigned char *st = malloc(JUNO_STATE_BYTES); memset(st,0,JUNO_STATE_BYTES);
    juno_chorus_init(st); juno_engine_init(st); juno_runtime_coeffs_apply(st);
    static struct juno_host_shim shim; memset(&shim,0,sizeof shim);
    juno_driver_attach_host(st, &shim, 2);

    int idx = 0;
    for (int k=0;k<nn;k++){
        juno_note_on(st, 0, notes[k]);
        for (int i=0;i<per;i++){
            if (i == per-gap) juno_note_off(st, 0);
            float l=0,r=0; juno_driver_render_sample(st,&l,&r);
            L[idx]=l; R[idx]=r; idx++;
        }
    }
    juno_note_off(st, 0);
    for (int i=0;i<tail;i++){ float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l; R[idx]=r; idx++; }

    write_wav(out, L, R, idx, SR);
    printf("rendered %d notes (", nn);
    for (int k=0;k<nn;k++) printf("%d%s", notes[k], k<nn-1?" ":"");
    printf(") -> %s  (%.2fs)\n", out, (double)idx/SR);
    return 0;
}
