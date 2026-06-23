// _fclrf  @ 0x18071CCEA  (RVA 0x71CCEA)
// prototype: __int64(void)
// callees: 

void fclrf()
{
  _mm_setcsr(_mm_getcsr() & 0xFFFFFFC0);
}

