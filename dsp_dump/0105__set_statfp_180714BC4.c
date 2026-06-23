// _set_statfp  @ 0x180714BC4  (RVA 0x714BC4)
// prototype: 
// callees: 0x18071CCD0, 0x18071CCE0

__int64 __fastcall set_statfp(char a1)
{
  unsigned int fpsr; // eax

  fpsr = get_fpsr();
  return set_fpsr(a1 & 0x3F | fpsr);
}

