// _statfp  @ 0x180714BE4  (RVA 0x714BE4)
// prototype: __int64(void)
// callees: 0x18071CCD0

__int64 statfp()
{
  return get_fpsr() & 0x3F;
}

