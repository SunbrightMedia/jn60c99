import collections
STRIDE=10512;T0=176;T1=176+8*10512;AUX0=101504;AUXS=32;AUX1=AUX0+8*AUXS
def load(p):
    d={}
    for ln in open(p):
        q=ln.rstrip('\n').split('\t'); d.setdefault(int(q[0]),set()).update(q[1:])
    return d
def cls(a):
    if T0<=a<T1: v=(a-T0)//STRIDE; return ('MAIN',v,a-v*STRIDE)
    if AUX0<=a<AUX1: v=(a-AUX0)//AUXS; return ('AUX',v,a-v*AUXS)
    return ('OTHER',None,a)
RN=load('u_recall_note.txt'); EB=load('u_ebread.txt')
def phase(site):
    f,l=site.rsplit(':',1); l=int(l)
    if f=='eb_coefs.c':
        return 'BUILD' if l<320 else ('SEED' if l<361 else 'MIRROR')
    if f=='juno_note.c': return 'NOTE'
    if f=='juno_apply.c': return 'RECALL'
    return f
rec=collections.defaultdict(lambda: {'ph':collections.defaultdict(set),'sites':collections.defaultdict(set),'v':set()})
for src in (RN,EB):
    for a,ss in src.items():
        k,v,o=cls(a)
        if k=='OTHER': continue
        r=rec[(k,o)]; r['v'].add(v)
        for s in ss:
            p=phase(s); r['ph'][p].add(v); r['sites'][p].add(s)
div={}
for ln in open('u_div.txt'):
    o,fl=ln.split('\t'); div[int(o)]=fl.strip()
print("TOTAL distinct per-voice offsets touched by RECALL+NOTE+BUILD+SEED+MIRROR:",len(rec))
byph=collections.Counter()
for k,r in rec.items():
    for p in r['ph']: byph[p]+=1
print("per phase:",dict(byph))
print()
hdr="off\tkind\tvoices\tdiv(c,n,r)\tphases\tsites"
print(hdr)
for (k,o) in sorted(rec, key=lambda x:(x[0],x[1])):
    r=rec[(k,o)]
    vs=''.join(str(x) for x in sorted(r['v']))
    d=div.get(o,'---') if k=='MAIN' else '?'
    ph=','.join("%s[%s]"%(p,''.join(str(x) for x in sorted(r['ph'][p]))) for p in sorted(r['ph']))
    st=';'.join(sorted(set(s for p in r['sites'] for s in r['sites'][p])))
    print("%d\t%s\t%s\t%s\t%s\t%s"%(o,k,vs,d,ph,st))
