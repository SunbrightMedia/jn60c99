// _get_fpsr  @ 0x18071CCD0  (RVA 0x71CCD0)
// prototype: __int64(void)
// callees: 

__int64 get_fpsr()
{
  return (unsigned int)_mm_getcsr();
}

