#!/usr/bin/env python3
"""Does the PLUGIN's own render respond to note-on velocity at all?
Render BS Solid through the plugin (Unicorn) at vel 100 and vel 127 and compare
the audio. The port demonstrably responds; if the plugin (as our harness drives
it) does NOT, then our ORACLE is velocity-deaf -- which would mean every
'bit-exact' render A/B has been comparing a velocity-flat reference."""
import sys, struct, numpy as np
sys.path.insert(0,'/home/user/jn60c99/tools/verify')
import e2e_emu as E, real_recall as R, recall_render_ab as RA
BANK='/root/.claude/uploads/89f5fa0d-6fc0-55d6-a056-fe6fb14fdde6/0e8b9cb5-Chillwave.bin'
bank=open(BANK,'rb').read(); leaves=R.leaf_table(); SR=44100.0
f=lambda b: struct.unpack('<f',struct.pack('<I',b))[0]
out={}
for vel in (100,127):
    e=RA.prepare_recall(3,bank,leaves,E,R,SR)
    e.note_on(60,vel)
    Lb,_=e.render(int(SR*0.5),block=512)
    out[vel]=np.array([f(v) for v in Lb]); del e
d=out[100]-out[127]
nd=int(np.sum(out[100]!=out[127]))
print("PLUGIN (oracle) BS Solid, first 0.5 s:")
print("  vel100 peak %.6f   vel127 peak %.6f"%(np.max(np.abs(out[100])),np.max(np.abs(out[127]))))
print("  differing samples: %d / %d   max abs diff %.3e"%(nd,len(d),np.max(np.abs(d))))
print("  VERDICT:", "PLUGIN IS VELOCITY-DEAF under our harness  <== oracle bug"
      if nd==0 else "plugin responds to velocity (oracle fine)")
