import struct
from fractions import Fraction as F
def dbits(x): return struct.unpack("<Q",struct.pack("<d",x))[0]
FMIN=F(1,2**126)
x4=FMIN-F(1,2**150)+F(1,2**170)   # exact double? check representable
d4=float(x4); assert F(d4)==x4, "T4 not exact"
# (name, op, mxcsr, a_bits(float), b_bits(float), d_bits(double for cvtsd2ss))
V=[("T1 mul tie below min","mulss",0x3F7FFFFF,0x00800000,0),
   ("T2 mul (1-2^-46)min","mulss",0x32800001,0x0D7FFFFE,0),
   ("T3 div exact min-2^-150","divss",0x0D7FFFFF,0x4C800000,0),
   ("T4 cvtsd2ss min-2^-150+2^-170","cvtsd2ss",0,0,dbits(d4)),
   ("T5 minss(0, denorm)","minss",0x00000000,0x00000001,0),
   ("T6 maxss(-0, denorm)","maxss",0x80000000,0x00400000,0),
   ("T7 addss denorm+denorm","addss",0x00400000,0x00400000,0),
   ("T8 mulss 1/3*1/3 flags","mulss",0x3EAAAAAB,0x3EAAAAAB,0),
   ("T9 comiss denorm vs 0 (ZF)","comiss",0x00000001,0x00000000,0),
   ("T10 mul denorm*2^100","mulss",0x00000001,0x71800000,0),
   ("T11 minss(denorm, 1.0)","minss",0x00000001,0x3F800000,0)]
