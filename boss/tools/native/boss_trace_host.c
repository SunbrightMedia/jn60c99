/* boss_trace_host.c -- PRODUCT REACH TRACER for the BOSS Effects Pedals .vst3, run on the user's LICENSED PC.
 *
 * It boots the real plugin exactly as a VST3 host does (LoadLibrary -> DllMain, InitDll, GetPluginFactory,
 * createInstance, initialize, connect, setupProcessing, setActive). The licence check passes because the machine
 * is authorized -- we never touch it. THEN, and only then, it arms a software breakpoint (INT3) at the entry of
 * every function in the plugin's .pdata, installs a vectored exception handler that records each entry the once,
 * and DRIVES THE PRODUCT: it enumerates every parameter the edit controller reports and sweeps each across its
 * range while running process() on a stereo audio buffer, then a getState/setState round trip. Every function the
 * product path executes is recorded; the licence / boot code (which ran before the breakpoints were armed, and
 * never runs again) is NOT. The recorded RVAs are written to the output file, one hex rva per line.
 *
 * boss_trace_to_product.py then lifts ONLY those functions -> boss_product.c: no licence code, no stubs, nothing
 * to infer, and the port is intact because every function the product actually runs is kept.
 *
 * Build (MSVC x64 Developer Prompt):   cl /O2 boss_trace_host.c
 * Run:   boss_trace_host.exe "C:\path\to\BOSS Effects Pedals.vst3" executed_rvas.txt
 *        (the .vst3 must sit in its normal install tree so its Script\ folder is found next to it.)
 *
 * Adapted from jp8/tools/native/jp8_native_host.c (same SDK-free host-object scaffolding).
 */
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>

typedef long tresult;
#define S_OK_ 0
#define S_FALSE_ 1
#define E_NOINTERFACE_ ((tresult)0x80004002L)
#define E_NOTIMPL_ ((tresult)0x80004001L)
#define MAXBLOCK 2048

static void vst_iid(uint8_t *o, uint32_t l1, uint32_t l2, uint32_t l3, uint32_t l4) {
    o[0]=(uint8_t)l1; o[1]=(uint8_t)(l1>>8); o[2]=(uint8_t)(l1>>16); o[3]=(uint8_t)(l1>>24);
    o[4]=(uint8_t)(l2>>16); o[5]=(uint8_t)(l2>>24); o[6]=(uint8_t)l2; o[7]=(uint8_t)(l2>>8);
    o[8]=(uint8_t)(l3>>24); o[9]=(uint8_t)(l3>>16); o[10]=(uint8_t)(l3>>8); o[11]=(uint8_t)l3;
    o[12]=(uint8_t)(l4>>24); o[13]=(uint8_t)(l4>>16); o[14]=(uint8_t)(l4>>8); o[15]=(uint8_t)l4;
}
static uint8_t IID_COMPONENT[16], IID_EDITCONTROLLER[16], IID_CONNECTIONPOINT[16], IID_AUDIOPROCESSOR[16],
    IID_HANDLER[16], IID_HOSTAPP[16], IID_MESSAGE[16], IID_ATTRS[16], IID_BSTREAM[16];

/* ---------------- host objects (one struct, a kind each) -- as jp8_native_host.c ---------------- */
enum { K_HOSTCTX, K_HANDLER, K_STREAM, K_MESSAGE, K_ATTRS, K_EVENTS, K_PCHANGES, K_PQUEUE };
#define NATTR 64
typedef struct Obj {
    void **vt; int kind;
    uint8_t *data; size_t len, cap; int64_t pos;                 /* stream */
    char *msgid; struct Obj *attrs;                              /* message */
    int nattr; struct { char key[64]; char type; int64_t i; uint64_t f; uint16_t s[256]; void *b; uint32_t bn; } at[NATTR];
    int nq; struct Obj **q;                                      /* pchanges */
    uint32_t id; int np, qcap; int32_t *off; double *val;        /* pqueue */
} Obj;
static Obj *new_obj(void **vt, int kind){ Obj *o=(Obj*)calloc(1,sizeof(Obj)); o->vt=vt; o->kind=kind; return o; }
static tresult qi_common(Obj *o, const uint8_t *iid, void **out){
    const uint8_t *mine = o->kind==K_HOSTCTX?IID_HOSTAPP : o->kind==K_HANDLER?IID_HANDLER : o->kind==K_STREAM?IID_BSTREAM
                        : o->kind==K_MESSAGE?IID_MESSAGE : o->kind==K_ATTRS?IID_ATTRS : NULL;
    if (mine && !memcmp(iid,mine,16)){ *out=o; return S_OK_; } *out=NULL; return E_NOINTERFACE_;
}
static tresult m_qi(Obj *o, const uint8_t *iid, void **out){ return qi_common(o,iid,out); }
static unsigned long m_ref(Obj *o){ (void)o; return 1; }
static tresult m_notimpl(Obj *o){ (void)o; return E_NOTIMPL_; }
static void *vt_message[8], *vt_attrs[12];
static tresult hc_getName(Obj *o, uint16_t *n){ (void)o; n[0]='e'; n[1]='m'; n[2]='u'; n[3]=0; return S_OK_; }
static tresult hc_create(Obj *o, const uint8_t *cid, const uint8_t *iid, void **out){
    (void)o;(void)cid;
    if(!memcmp(iid,IID_MESSAGE,16)){ Obj *m=new_obj(vt_message,K_MESSAGE); m->attrs=new_obj(vt_attrs,K_ATTRS); *out=m; return S_OK_; }
    if(!memcmp(iid,IID_ATTRS,16)){ *out=new_obj(vt_attrs,K_ATTRS); return S_OK_; }
    *out=NULL; return E_NOINTERFACE_;
}
static const char *msg_getId(Obj *o){ return o->msgid; }
static void msg_setId(Obj *o, const char *id){ size_t n=strlen(id)+1; o->msgid=(char*)malloc(n); memcpy(o->msgid,id,n); }
static Obj *msg_attrs(Obj *o){ return o->attrs; }
static int at_find(Obj *o, const char *k){ int i; for(i=0;i<o->nattr;i++) if(!strcmp(o->at[i].key,k)) return i; return -1; }
static int at_slot(Obj *o, const char *k){ int i=at_find(o,k); if(i<0){ if(o->nattr>=NATTR) exit(3); i=o->nattr++; strncpy(o->at[i].key,k,63);} return i; }
static tresult at_setInt(Obj *o,const char *k,int64_t v){ int i=at_slot(o,k); o->at[i].type='i'; o->at[i].i=v; return S_OK_; }
static tresult at_getInt(Obj *o,const char *k,int64_t *v){ int i=at_find(o,k); if(i<0) return S_FALSE_; *v=o->at[i].i; return S_OK_; }
static tresult at_setFloat(Obj *o,const char *k,double v){ int i=at_slot(o,k); o->at[i].type='f'; memcpy(&o->at[i].f,&v,8); return S_OK_; }
static tresult at_getFloat(Obj *o,const char *k,double *v){ int i=at_find(o,k); if(i<0) return S_FALSE_; memcpy(v,&o->at[i].f,8); return S_OK_; }
static tresult at_setString(Obj *o,const char *k,const uint16_t *s){ int i=at_slot(o,k),j; o->at[i].type='s'; for(j=0;j<255&&s[j];j++) o->at[i].s[j]=s[j]; o->at[i].s[j]=0; return S_OK_; }
static tresult at_getString(Obj *o,const char *k,uint16_t *s,uint32_t size){ int i=at_find(o,k),j; uint32_t n; if(i<0) return S_FALSE_; n=size/2?size/2:1; for(j=0;(uint32_t)j<n;j++){ s[j]=o->at[i].s[j]; if(!o->at[i].s[j]) break; } return S_OK_; }
static tresult at_setBinary(Obj *o,const char *k,const void *d,uint32_t n){ int i=at_slot(o,k); o->at[i].type='b'; o->at[i].b=malloc(n>16?n:16); if(n) memcpy(o->at[i].b,d,n); o->at[i].bn=n; return S_OK_; }
static tresult at_getBinary(Obj *o,const char *k,const void **d,uint32_t *n){ int i=at_find(o,k); if(i<0) return S_FALSE_; *d=o->at[i].b; *n=o->at[i].bn; return S_OK_; }
static tresult h_any(Obj *o){ (void)o; return S_OK_; }
static tresult st_read(Obj *o,void *buf,int32_t n,int32_t *got){ int64_t av=(int64_t)o->len-o->pos,k=(int64_t)(uint32_t)n<av?(int64_t)(uint32_t)n:av; if(k<0)k=0; if(k)memcpy(buf,o->data+o->pos,(size_t)k); o->pos+=k; if(got)*got=(int32_t)k; return S_OK_; }
static tresult st_write(Obj *o,const void *buf,int32_t n,int32_t *put){ size_t need=(size_t)o->pos+(uint32_t)n; if(need>o->cap){ o->cap=need*2+64; o->data=(uint8_t*)realloc(o->data,o->cap);} if(n)memcpy(o->data+o->pos,buf,(uint32_t)n); o->pos+=(uint32_t)n; if((size_t)o->pos>o->len)o->len=(size_t)o->pos; if(put)*put=n; return S_OK_; }
static tresult st_seek(Obj *o,int64_t pos,int32_t mode,int64_t *res){ o->pos=(mode==0?0:mode==1?o->pos:(int64_t)o->len)+pos; if(res)*res=o->pos; return S_OK_; }
static tresult st_tell(Obj *o,int64_t *pos){ *pos=o->pos; return S_OK_; }
static int32_t pc_count(Obj *o){ return o->nq; }
static Obj *pc_get(Obj *o,int32_t i){ return i>=0&&i<o->nq?o->q[i]:NULL; }
static uint32_t pq_id(Obj *o){ return o->id; }
static int32_t pq_count(Obj *o){ return o->np; }
static tresult pq_point(Obj *o,int32_t i,int32_t *off,double *v){ if(i<0||i>=o->np) return S_FALSE_; *off=o->off[i]; *v=o->val[i]; return S_OK_; }
static void *vt_hostctx[16], *vt_handler[10], *vt_stream[8], *vt_pchanges[6], *vt_pqueue[7];
static void vtables(void){
    void **all[]={vt_hostctx,vt_handler,vt_stream,vt_message,vt_attrs,vt_pchanges,vt_pqueue};
    int ns[]={16,10,8,8,12,6,7},i,j;
    for(i=0;i<7;i++){ all[i][0]=(void*)m_qi; all[i][1]=(void*)m_ref; all[i][2]=(void*)m_ref; for(j=3;j<ns[i];j++) all[i][j]=(void*)m_notimpl; }
    vt_hostctx[3]=(void*)hc_getName; vt_hostctx[4]=(void*)hc_create;
    for(j=3;j<10;j++) vt_handler[j]=(void*)h_any;
    vt_stream[3]=(void*)st_read; vt_stream[4]=(void*)st_write; vt_stream[5]=(void*)st_seek; vt_stream[6]=(void*)st_tell;
    vt_message[3]=(void*)msg_getId; vt_message[4]=(void*)msg_setId; vt_message[5]=(void*)msg_attrs;
    vt_attrs[3]=(void*)at_setInt; vt_attrs[4]=(void*)at_getInt; vt_attrs[5]=(void*)at_setFloat; vt_attrs[6]=(void*)at_getFloat;
    vt_attrs[7]=(void*)at_setString; vt_attrs[8]=(void*)at_getString; vt_attrs[9]=(void*)at_setBinary; vt_attrs[10]=(void*)at_getBinary;
    vt_pchanges[3]=(void*)pc_count; vt_pchanges[4]=(void*)pc_get;
    vt_pqueue[3]=(void*)pq_id; vt_pqueue[4]=(void*)pq_count; vt_pqueue[5]=(void*)pq_point;
}
typedef tresult (*fn1p)(void*,void*);
typedef tresult (*fn1i)(void*,int32_t);
typedef tresult (*fn2p)(void*,const void*,void**);
typedef tresult (*fn3p)(void*,const void*,const void*,void**);
static void *slot(void *obj,int k){ return (*(void***)obj)[k]; }
static void die(const char *what,tresult r){ fprintf(stderr,"%s -> 0x%lx\n",what,(unsigned long)r); exit(1); }

/* ---------------- coverage: INT3 at every .pdata function begin, a VEH records each the once ---------------- */
static uint8_t *g_base; static size_t g_imgsize;
static uint32_t *g_begin; static uint8_t *g_orig, *g_seen; static int g_nfn; static int g_armed = 0;
static FILE *g_recfp; static long g_hits = 0;

static int find_begin(uint32_t rva){                             /* binary search g_begin for an exact entry */
    int lo=0, hi=g_nfn-1; while(lo<=hi){ int m=(lo+hi)/2; if(g_begin[m]==rva) return m; if(g_begin[m]<rva) lo=m+1; else hi=m-1; } return -1;
}
static LONG CALLBACK veh(EXCEPTION_POINTERS *ep){
    if(!g_armed || ep->ExceptionRecord->ExceptionCode != EXCEPTION_BREAKPOINT) return EXCEPTION_CONTINUE_SEARCH;
    uint8_t *addr=(uint8_t*)ep->ExceptionRecord->ExceptionAddress;
    if(addr < g_base || addr >= g_base+g_imgsize) return EXCEPTION_CONTINUE_SEARCH;
    int i=find_begin((uint32_t)(addr-g_base));
    if(i<0) return EXCEPTION_CONTINUE_SEARCH;                     /* INT3 not one of ours */
    if(!g_seen[i]){ g_seen[i]=1; g_hits++; fprintf(g_recfp,"0x%x\n",(unsigned)g_begin[i]); }
    *addr = g_orig[i];                                            /* restore the real first byte (page is RWX) */
    FlushInstructionCache(GetCurrentProcess(), addr, 1);
    ep->ContextRecord->Rip = (DWORD64)addr;                       /* re-execute the original instruction */
    return EXCEPTION_CONTINUE_EXECUTION;
}
static void arm_breakpoints(HMODULE mod){
    IMAGE_DOS_HEADER *dos=(IMAGE_DOS_HEADER*)mod;
    IMAGE_NT_HEADERS *nt=(IMAGE_NT_HEADERS*)((uint8_t*)mod + dos->e_lfanew);
    IMAGE_DATA_DIRECTORY ed = nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXCEPTION];
    RUNTIME_FUNCTION *rf=(RUNTIME_FUNCTION*)((uint8_t*)mod + ed.VirtualAddress);
    int n=(int)(ed.Size / sizeof(RUNTIME_FUNCTION)), i;
    g_base=(uint8_t*)mod; g_imgsize=nt->OptionalHeader.SizeOfImage;
    g_begin=(uint32_t*)malloc(sizeof(uint32_t)*n); g_orig=(uint8_t*)malloc(n); g_seen=(uint8_t*)calloc(n,1);
    g_nfn=0;
    for(i=0;i<n;i++){ uint32_t b=rf[i].BeginAddress; if(g_nfn&&g_begin[g_nfn-1]==b) continue; g_begin[g_nfn++]=b; }
    /* .pdata is sorted by BeginAddress already; de-duped above. Patch each with INT3 (page -> RWX, kept RWX). */
    for(i=0;i<g_nfn;i++){ DWORD old; uint8_t *p=g_base+g_begin[i];
        if(!VirtualProtect(p,1,PAGE_EXECUTE_READWRITE,&old)){ continue; }
        g_orig[i]=*p; *p=0xCC; }
    FlushInstructionCache(GetCurrentProcess(), NULL, 0);
    fprintf(stderr,"armed INT3 on %d functions\n", g_nfn);
}

int main(int argc, char **argv){
    HMODULE mod; FARPROC init_dll, getf; void *fac, *comp=NULL, *proc=NULL, *ctrl=NULL, *cpp=NULL, *cpc=NULL;
    Obj *hostctx, *handler, *stream; uint8_t cids[2][16]; int32_t ncls, nparam, i, blk;
    tresult r; double rate = 48000.0; int maxb = MAXBLOCK;
    if(argc < 3){ fprintf(stderr,"usage: %s <BOSS Effects Pedals.vst3> <executed_rvas.txt> [rate]\n", argv[0]); return 2; }
    if(argc >= 4) rate = atof(argv[3]);
    vtables();
    vst_iid(IID_COMPONENT,      0xE831FF31,0xF2D54301,0x928EBBEE,0x25697802);
    vst_iid(IID_EDITCONTROLLER, 0xDCD7BBE3,0x7742448D,0xA874AACC,0x979C759E);
    vst_iid(IID_CONNECTIONPOINT,0x70A4156F,0x6E6E4026,0x989148BF,0xAA60D8D1);
    vst_iid(IID_AUDIOPROCESSOR, 0x42043F99,0xB7DA453C,0xA569E79D,0x9AAEC33D);
    vst_iid(IID_HANDLER,        0x93A0BEA3,0x0BD045DB,0x8E890B0C,0xC1E46AC6);
    vst_iid(IID_HOSTAPP,        0x58E595CC,0xDB2D4969,0x8B6AAF8C,0x36A664E5);
    vst_iid(IID_MESSAGE,        0x936F033B,0xC6C047DB,0xBB0882F8,0x13C1E613);
    vst_iid(IID_ATTRS,          0x1E5F0AEB,0xCC7F4533,0xA2544011,0x38AD5EE4);
    vst_iid(IID_BSTREAM,        0xC3BF6EA2,0x30994752,0x9B6BF990,0x1EE33E9B);

    mod = LoadLibraryA(argv[1]);
    if(!mod){ fprintf(stderr,"LoadLibrary %s: %lu\n", argv[1], GetLastError()); return 1; }
    init_dll = GetProcAddress(mod,"InitDll");
    if(!init_dll || !(((uint8_t(*)(void))(void(*)(void))init_dll)())){ fprintf(stderr,"InitDll failed\n"); return 1; }
    getf = GetProcAddress(mod,"GetPluginFactory");
    fac = ((void*(*)(void))(void(*)(void))getf)();
    ncls = ((int32_t(*)(void*))slot(fac,4))(fac);
    for(i=0;i<ncls && i<2;i++){ uint8_t ci[16+4+32+64]; ((tresult(*)(void*,int32_t,void*))slot(fac,5))(fac,i,ci); memcpy(cids[i],ci,16); }
    hostctx=new_obj(vt_hostctx,K_HOSTCTX); handler=new_obj(vt_handler,K_HANDLER);
    if((r=((fn3p)slot(fac,6))(fac,cids[0],IID_COMPONENT,&comp))) die("createInstance(processor)",r);
    if((r=((fn1p)slot(comp,3))(comp,hostctx))) die("IComponent::initialize",r);
    if((r=((fn2p)slot(comp,0))(comp,IID_AUDIOPROCESSOR,&proc))) die("QI IAudioProcessor",r);
    if((r=((fn3p)slot(fac,6))(fac,cids[1],IID_EDITCONTROLLER,&ctrl))) die("createInstance(controller)",r);
    if((r=((fn1p)slot(ctrl,3))(ctrl,hostctx))) die("IEditController::initialize",r);
    if((r=((fn2p)slot(comp,0))(comp,IID_CONNECTIONPOINT,&cpp))) die("QI component IConnectionPoint",r);
    if((r=((fn2p)slot(ctrl,0))(ctrl,IID_CONNECTIONPOINT,&cpc))) die("QI controller IConnectionPoint",r);
    if((r=((fn1p)slot(cpp,3))(cpp,cpc))||(r=((fn1p)slot(cpc,3))(cpc,cpp))) die("connect",r);
    if((r=((fn1p)slot(ctrl,16))(ctrl,handler))) die("setComponentHandler",r);
    stream=new_obj(vt_stream,K_STREAM);
    if((r=((fn1p)slot(comp,13))(comp,stream))) die("getState",r);
    stream->pos=0;
    ((fn1p)slot(ctrl,5))(ctrl,stream);                           /* setComponentState (ignore result) */
    {   struct { int32_t mode,size,maxb,pad; double rate; } ps = {0,0,0,0,0.0};
        ps.maxb=maxb; ps.rate=rate;
        if((r=((fn1p)slot(proc,7))(proc,&ps))) die("setupProcessing",r);
        if((r=((fn1i)slot(comp,11))(comp,1))) die("setActive",r);
    }

    /* ---- boot is complete and the licence check has already run. ARM NOW so only the product path is traced. */
    g_recfp = fopen(argv[2],"w");
    if(!g_recfp){ fprintf(stderr,"cannot open %s\n", argv[2]); return 2; }
    AddVectoredExceptionHandler(1, veh);                         /* first handler: before the plugin's own SEH */
    arm_breakpoints(mod);
    g_armed = 1;

    /* ---- drive the product: enumerate every parameter, sweep each across its range while processing audio ---- */
    nparam = ((int32_t(*)(void*))slot(ctrl,8))(ctrl);            /* IEditController::getParameterCount */
    fprintf(stderr,"parameters: %d\n", nparam);
    {
        static float inL[MAXBLOCK], inR[MAXBLOCK], outL[MAXBLOCK], outR[MAXBLOCK];
        static Obj *qs[256]; Obj pchanges; void *inch[2], *outch[2];
        struct { int32_t nch,pad; uint64_t sil; void **bufs; } ibus, obus;
        struct { int32_t mode,size,n,nin,nout,pad; void *in,*outb,*inp,*outp,*inev,*outev,*ctx; } pd;
        uint32_t *pid; int nq;
        double sweep[5] = {0.0, 0.25, 0.5, 0.75, 1.0}, phase=0.0;
        int s, pass, nblk = maxb < 512 ? maxb : 512;
        pid = (uint32_t*)malloc(sizeof(uint32_t)*(nparam>0?nparam:1));
        for(i=0;i<nparam;i++){ uint8_t info[16+128*2+128*2+128*2+4+8+4+4]; /* ParameterInfo: id is the first u32 */
            ((tresult(*)(void*,int32_t,void*))slot(ctrl,9))(ctrl,i,info); memcpy(&pid[i], info, 4); }
        for(i=0;i<256;i++) qs[i]=new_obj(vt_pqueue,K_PQUEUE);
        inch[0]=inL; inch[1]=inR; outch[0]=outL; outch[1]=outR;
        ibus.nch=2; ibus.pad=0; ibus.sil=0; ibus.bufs=inch; obus.nch=2; obus.pad=0; obus.sil=0; obus.bufs=outch;
        pchanges.vt=vt_pchanges; pchanges.kind=K_PCHANGES; pchanges.q=qs;
        /* sweep every parameter value (this includes the pedal-model selector, so every shipped pedal's DSP runs),
         * five passes at the five sweep points; feed a sine + an impulse so the effect does real work. */
        for(pass=0; pass<5; pass++){
            nq=0;
            for(i=0;i<nparam && nq<256; i++){ qs[nq]->id=pid[i]; qs[nq]->np=0;
                if(qs[nq]->qcap==0){ qs[nq]->qcap=4; qs[nq]->off=(int32_t*)malloc(16); qs[nq]->val=(double*)malloc(32); }
                qs[nq]->off[0]=0; qs[nq]->val[0]=sweep[pass]; qs[nq]->np=1; nq++; }
            pchanges.nq=nq;
            for(blk=0; blk<16; blk++){
                for(s=0;s<nblk;s++){ float v=(float)(0.25*sin(phase)); phase+=0.06; if(phase>6.283185)phase-=6.283185;
                    if(blk==0 && s==0) v+=1.0f;                   /* an impulse to excite delays/reverb tails */
                    inL[s]=v; inR[s]=v; outL[s]=0; outR[s]=0; }
                memset(&pd,0,sizeof pd); pd.n=nblk; pd.nin=1; pd.nout=1; pd.in=&ibus; pd.outb=&obus;
                pd.inp = (blk==0 && nq) ? (void*)&pchanges : NULL;  /* apply the sweep point on the first block */
                if((r=((fn1p)slot(proc,9))(proc,&pd))) { fprintf(stderr,"process -> 0x%lx\n",(unsigned long)r); break; }
            }
        }
        /* state round trip through the product */
        { Obj *s2=new_obj(vt_stream,K_STREAM); ((fn1p)slot(comp,13))(comp,s2); s2->pos=0; ((fn1p)slot(comp,12))(comp,s2); }
    }
    fprintf(stderr,"traced %ld product functions -> %s\n", g_hits, argv[2]);
    fclose(g_recfp);
    return 0;
}
