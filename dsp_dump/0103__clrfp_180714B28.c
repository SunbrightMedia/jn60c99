// _clrfp  @ 0x180714B28  (RVA 0x714B28)
// prototype: __int64(void)
// callees: 0x18071CCD0, 0x18071CCEA

__int64 clrfp()
{
  __int64 v0; // rbx

  v0 = get_fpsr() & 0x3F;
  fclrf();
  return (unsigned int)v0;
}

