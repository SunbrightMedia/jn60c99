/* play_sqarpg_arp.c — SQ Dynamic ARPG: hold a C-major chord, let the faithful
 * CArpeggio (src/arp.c) sequence it on the captured SQ ARPG voice (voice 0).
 * The arp plays one note at a time, so it works within the single-voice limit.
 *
 *   chord held 0.5s..2.5s; ~1/16 steps; UP mode; voice = captured SQ ARPG coeffs.
 */
#include "../src/juno_engine.h"
#include "../src/juno_driver.h"
#include "../src/arp.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdint.h>

void juno_runtime_coeffs_apply(unsigned char*);
void juno_overlay_patch(unsigned char*);

static void wav(const char*p,float*L,float*R,int n,int sr){FILE*f=fopen(p,"wb");int db=n*4,br=sr*4;unsigned u;unsigned short s;
 fwrite("RIFF",1,4,f);u=36+db;fwrite(&u,4,1,f);fwrite("WAVE",1,4,f);fwrite("fmt ",1,4,f);u=16;fwrite(&u,4,1,f);s=1;fwrite(&s,2,1,f);s=2;fwrite(&s,2,1,f);
 u=sr;fwrite(&u,4,1,f);u=br;fwrite(&u,4,1,f);s=4;fwrite(&s,2,1,f);s=16;fwrite(&s,2,1,f);fwrite("data",1,4,f);u=db;fwrite(&u,4,1,f);
 for(int i=0;i<n;i++){float l=L[i],r=R[i];if(l>1)l=1;if(l<-1)l=-1;if(r>1)r=1;if(r<-1)r=-1;short a=(short)lrintf(l*32767),b=(short)lrintf(r*32767);fwrite(&a,2,1,f);fwrite(&b,2,1,f);}fclose(f);}

static int g_arpnote=-1;
static void on_on(void*ud,int n,int v,int k){(void)ud;(void)v;(void)k;g_arpnote=n;}
static void on_off(void*ud,int n,int v){(void)ud;(void)n;(void)v;}

int main(int argc,char**argv){
    const char*out=argc>1?argv[1]:"/tmp/sqarpg_arp.wav";
    const int SR=96000;
    unsigned char*st=malloc(JUNO_STATE_BYTES);memset(st,0,JUNO_STATE_BYTES);
    juno_chorus_init(st);juno_engine_init(st);juno_runtime_coeffs_apply(st);juno_overlay_patch(st);
    static struct juno_host_shim sh;memset(&sh,0,sizeof sh);juno_driver_attach_host(st,&sh,2);

    /* --- faithful arp: hold C-E-G, UP, one octave (just the 3 notes cycling) --- */
    juno_arp arp; juno_arp_callbacks cb={on_on,on_off,NULL};
    juno_arp_init(&arp,&cb); unsigned char*a=arp.st;
    *(int8_t*)(a+3054)=1; *(int8_t*)(a+3055)=1;            /* 1 cell/step, advance each scan */
    *(uint16_t*)(a+610)=1; *(uint8_t*)(a+996)=0x01; *(uint16_t*)(a+996+2)=1;
    juno_arp_note_on(&arp,60,100); juno_arp_note_on(&arp,64,100); juno_arp_note_on(&arp,67,100);
    juno_arp_set_mode(&arp,15); juno_arp_set_range(&arp,1); juno_arp_set_running(&arp,1);

    int start=SR/2, step=SR/8, gate=(int)(step*0.7);   /* STEP=1 ~ 1/16 @120bpm (1/8 ran too slow per A/B) */
    int arp_end=start+2*SR, N=start+2*SR+SR, idx=0;
    float*L=malloc(4*N),*R=malloc(4*N);
    int next_step=start, cur=-1, gate_off=-1, nsteps=0;
    for(int i=0;i<N;i++){
        if(i>=start && i<arp_end && i>=next_step){
            juno_arp_scan(&arp);                 /* emit next UP note via callback */
            if(g_arpnote>=0){
                if(cur>=0) juno_note_off(st,0);
                juno_note_on(st,0,g_arpnote); cur=g_arpnote; gate_off=i+gate; nsteps++;
            }
            next_step+=step;
        }
        if(gate_off>=0 && i==gate_off && cur>=0){ juno_note_off(st,0); cur=-1; gate_off=-1; }
        if(i==arp_end && cur>=0){ juno_note_off(st,0); cur=-1; }
        float l=0,r=0; juno_driver_render_sample(st,&l,&r); L[idx]=l;R[idx]=r;idx++;
    }
    float pk=0;double sm=0;for(int i=0;i<idx;i++){if(fabsf(L[i])>pk)pk=fabsf(L[i]);sm+=(double)L[i]*L[i];}
    wav(out,L,R,idx,SR);
    printf("SQ ARPG arp -> %s  (%.2fs) %d arp steps, peak=%.3f rms=%.4f\n",out,(double)idx/SR,nsteps,pk,sqrt(sm/idx));
    return 0;
}
