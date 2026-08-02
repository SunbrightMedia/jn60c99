#include <stdio.h>
#include <stdlib.h>
typedef struct juno_ctx juno_ctx;
juno_ctx *juno_gui_create(float,int);
int juno_gui_apply_bank(juno_ctx*,const unsigned char*,int,int);
void juno_gui_note_on(juno_ctx*,int,int);
int juno_gui_render(juno_ctx*,float*,int);
int main(int argc,char**argv){
  int n = argc>1?atoi(argv[1]):1000;
  int nv = argc>2?atoi(argv[2]):8;
  FILE*f=fopen("truth/presetbankog1.bin","rb"); if(!f){perror("bank");return 1;}
  static unsigned char bank[1<<22]; int len=(int)fread(bank,1,sizeof bank,f); fclose(f);
  juno_ctx*c=juno_gui_create(48000.f,0);
  juno_gui_apply_bank(c,bank,len,0);
  for(int i=0;i<nv;i++) juno_gui_note_on(c,48+i*3,100);
  static float out[4096*2];
  /* warm, not measured separately: callgrind counts everything; use n large */
  int left=n; while(left>0){int b=left>2048?2048:left; juno_gui_render(c,out,b); left-=b;}
  printf("rendered %d\n",n);
  return 0;
}
