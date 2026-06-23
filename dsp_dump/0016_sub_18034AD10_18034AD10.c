// sub_18034AD10  @ 0x18034AD10  (RVA 0x34AD10)
// prototype: 
// callees: 

int *__fastcall sub_18034AD10(int *a1)
{
  *a1 = _mm_getcsr() & 0x8000;
  a1[1] = _mm_getcsr() & 0x40;
  _mm_setcsr(_mm_getcsr() | 0x8000);
  _mm_setcsr(_mm_getcsr() | 0x40);
  return a1;
}

