// sub_7FF91DFAAD10 @ rva 0x34AD10

int *__fastcall sub_7FF91DFAAD10(int *a1)
{
  *a1 = _mm_getcsr() & 0x8000;
  a1[1] = _mm_getcsr() & 0x40;
  _mm_setcsr(_mm_getcsr() | 0x8000);
  _mm_setcsr(_mm_getcsr() | 0x40);
  return a1;
}

