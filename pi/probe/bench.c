/* bench.c — steady-state render cost, for callgrind. Fills all 8 voices with a
 * busy patch and renders M frames in one call (as the I2S callback does).
 * Run under callgrind at M and 2M; (Ir(2M)-Ir(M))/M cancels setup and gives
 * exact retired instructions per stereo sample. usage: bench <bank> <M> [patch] */
#include <stdio.h>
#include <stdlib.h>
void *juno_gui_create(float,int);
int   juno_gui_apply_bank(void*,const char*,int,int);
void  juno_gui_note_on(void*,int,int);
int   juno_gui_render(void*,float*,int);
int main(int argc,char**argv){
    if(argc<3){fprintf(stderr,"need bank M\n");return 2;}
    FILE*f=fopen(argv[1],"rb");fseek(f,0,SEEK_END);long len=ftell(f);fseek(f,0,SEEK_SET);
    unsigned char*bank=malloc(len);if(fread(bank,1,len,f)!=(size_t)len)return 2;fclose(f);
    int M=atoi(argv[2]); int patch=argc>3?atoi(argv[3]):0;
    void*c=juno_gui_create(48000.0f,0);
    juno_gui_apply_bank(c,(const char*)bank,(int)len,patch);
    int notes[8]={48,52,55,60,64,67,72,76};
    for(int i=0;i<8;i++) juno_gui_note_on(c,notes[i],100);   /* fill all voices */
    float*buf=malloc(sizeof(float)*2*M);
    juno_gui_render(c,buf,M);                                /* the measured work */
    /* keep buf live so the render is not optimised away */
    double s=0; for(int i=0;i<2*M;i++) s+=buf[i];
    fprintf(stderr,"sink %g\n",s);
    return 0;
}
