// _ctrlfp  @ 0x180714B48  (RVA 0x714B48)
// prototype: 
// callees: 0x180714B48, 0x18071CCD0, 0x18071CCE0
// constants/globals referenced:
//   0x180C955D0 [.data] byte_180C955D0  u32=1  f32=1.401298464324817e-45  f64=5e-324

__int64 __fastcall ctrlfp(int a1, int a2)
{
  unsigned int fpsr; // esi
  __int64 v5; // rcx

  fpsr = get_fpsr();
  v5 = a2 & a1 | fpsr & (~(_WORD)a2 | 0xFFFF807F);
  if ( byte_180C955D0 && (((unsigned __int8)(a2 & a1) | fpsr & ((unsigned __int8)~(_BYTE)a2 | 0x7F)) & 0x40) != 0 )
    set_fpsr(v5);
  else
    set_fpsr((unsigned int)v5 & 0xFFFFFFBF);
  return fpsr;
}

