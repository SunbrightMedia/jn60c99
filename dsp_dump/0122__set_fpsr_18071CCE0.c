// _set_fpsr  @ 0x18071CCE0  (RVA 0x71CCE0)
// prototype: __int64 __fastcall(_QWORD)
// callees: 

void __fastcall set_fpsr(unsigned int a1)
{
  _mm_setcsr(a1);
}

