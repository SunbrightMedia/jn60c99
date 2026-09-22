import sys, struct, pefile
sys.path.insert(0,'/home/user/jn60c99/jp8/tools'); sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import jp8_bank as B, pe_recon
pe=pefile.PE('/home/user/jn60c99/jp8/truth/JUPITER-8VST3_64bit.vst3'); img=pe.get_memory_mapped_image()
cases={0x4466e3:'DIRECT 0x442750(bool v!=0)',0x4466f8:'DIRECT 0x442bb0(v)',0x446707:'DIRECT 0x442710(v)',0x446713:'DIRECT 0x442c70(v,0)',0x446722:'DIRECT 0x442c40(v,0)',0x446731:'DIRECT 0x442c30(v) THEN dispatch',0x44673d:'v-36',0x446742:'v-100',0x446747:'min(v,1)',0x446751:'min(v,1)?',0x446758:'v (generic)',0x446789:'SKIP (no write)'}
rows=pe_recon.PE('/home/user/jn60c99/jp8/truth/JUPITER-8VST3_64bit.vst3').params(list(range(5223)))['rows']
pools=set(B.POOL_BASE_ID+p for p in B.ACTIVE_POOLS)
from collections import Counter
c=Counter(); bad=[]
for eid in range(0x2c3,0x2c3+0xa5):
    k=img[0x4467e4+eid-0x2c3]; t=struct.unpack_from('<I',img,0x4467b8+4*k)[0]
    lab=cases.get(t,hex(t)); r=rows.get(eid,{})
    inpool=eid in pools
    if inpool:
        c[lab]+=1
        mn=r.get('min'); law='v+%d'%mn if mn else 'v'
        if lab not in ('v (generic)',) or mn:
            print('pool id %d %-22s host-path: %-28s oracle recall: DISPATCH flag0 raw%s  [DB min %s max %s]'%(eid,r.get('name'),lab,('+%d'%mn if mn else ''),mn,r.get('max')))
print('pool ids by host-path case:',dict(c)); print('pool ids total',len(pools),'in 707..871:',sum(1 for p in pools if 0x2c3<=p<0x2c3+0xa5))
