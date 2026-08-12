#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "juno_engine.h"
#include "juno_apply.h"
#include "juno_driver.h"
#include "juno_note.h"
#include "jc_trace.h"
#include "eb_coefs.h"

static unsigned char *ST;
static eb_render_coefs  RC;
static eb_render_state  RS;
static struct juno_host_shim SH;

/* divergence bitmaps over the voice-0 block [0,10688) in 4-byte cells */
#define NC (10688/4)
static unsigned char div_cold[NC], div_note[NC], div_render[NC];
static unsigned char auxdiv_cold, auxdiv_note;

static void mark(unsigned char *m)
{
    unsigned c;
    for (c = 176/4; c < NC; ++c) {
        unsigned off = c*4, v;
        unsigned a0 = *(unsigned*)(ST + off);
        for (v = 1; v < 8; ++v)
            if (*(unsigned*)(ST + off + v*10512u) != a0) { m[c] = 1; break; }
    }
}

static void boot(int rate)
{
    memset(ST,0,JUNO_STATE_BYTES);
    juno_chorus_init(ST);
    *(float*)(ST+16) = (float)rate;
    juno_engine_init(ST);
    juno_engine_prepare(ST);
    juno_driver_attach_host(ST,&SH,2);
}
static void recall(const unsigned char *bank,int p,int rate)
{
    juno_bank_apply(ST, bank, p);
    juno_driver_seed_voices(ST);
    juno_apply_unison_spread(ST, juno_bank_assign(bank,p));
    juno_apply_condition(ST, juno_bank_condition(bank,p));
    juno_apply_lfo_tempo(ST, juno_bank_lfo_rate_byte(bank,p), 128.0f);
}
static void notes(void)
{
    int v;
    for (v=0; v<8; ++v) {
        juno_note_on(ST, v, 36+v*5, 40+v*11);
        juno_note_broadcast_held(ST, 1);
    }
    juno_note_retrig(ST, 2);
    juno_note_porta_gate(ST, 4, 1, 0.0f);
    juno_note_porta_gate(ST, 5, 0, 1.0f);
    juno_note_velocity(ST, 6, 77);
    juno_note_glide(ST, 7, 61);
    juno_note_off(ST, 3);
}

int main(int argc, char **argv)
{
    FILE *f = fopen(argv[1], "rb");
    long bl; unsigned char *bank, *wb;
    int p,r,c,v,s,trial;
    int rates[3]={44100,48000,96000};
    fseek(f,0,SEEK_END); bl=ftell(f); fseek(f,0,SEEK_SET);
    bank=malloc(bl); if(fread(bank,1,bl,f)!=(size_t)bl) return 1; fclose(f);
    wb=malloc(bl);
    ST=malloc(JUNO_STATE_BYTES);
    jc_reset(); jc_base=ST;

    srand(4242);
    /* --------- PHASE R over the whole bank, 3 rates, factory + synthetic ---- */
    for (trial=0; trial<2; ++trial) {
      memcpy(wb,bank,bl);
      if (trial) for(p=0;p<64;++p){unsigned char*rec=wb+23+p*20223; long i;
                    for(i=16;i<20223;++i) rec[i]=(unsigned char)(rand()&0xFF);}
      for (r=0;r<3;++r) for (p=0;p<64;++p) {
        jc_on=0; boot(rates[r]);
        jc_on=1; recall(wb,p,rates[r]); jc_on=0;
        mark(div_cold);
        jc_on=1; notes(); jc_on=0;
        mark(div_note);
      }
    }
    jc_dump("u_recall_note.txt"); jc_reset();

    /* --------- PHASE C/S/M over the bank ---------- */
    for (r=0;r<3;++r) for (p=0;p<64;++p) {
        jc_on=0; boot(rates[r]); recall(bank,p,rates[r]); notes();
        jc_on=1;
        eb_render_coefs_build(ST,&RC);
        eb_render_state_seed(ST,&RS);
        eb_render_events_mirror(ST,&RS);
        jc_on=0;
    }
    jc_dump("u_ebread.txt"); jc_reset();

    /* --------- divergence after RENDER (the port's own audio path) --------- */
    jc_on=0;
    boot(44100); recall(bank,3,44100); notes();
    { float L,R; for (s=0;s<600;++s) juno_driver_render_sample(ST,&L,&R); }
    mark(div_render);

    { FILE*o=fopen("u_div.txt","w");
      for (c=176/4;c<NC;++c)
        if (div_cold[c]||div_note[c]||div_render[c])
            fprintf(o,"%u\t%d%d%d\n", c*4, div_cold[c],div_note[c],div_render[c]);
      fclose(o); }
    /* aux */
    { FILE*o=fopen("u_aux.txt","w");
      unsigned a0=*(unsigned*)(ST+101504); int d=0;
      for(v=1;v<8;++v) if(*(unsigned*)(ST+101504+32u*v)!=a0) d=1;
      fprintf(o,"aux101504 divergent_after_render=%d\n",d); fclose(o);}
    printf("done\n");
    (void)argc;
    return 0;
}
