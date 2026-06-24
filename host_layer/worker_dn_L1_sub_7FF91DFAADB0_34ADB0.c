// sub_7FF91DFAADB0 @ rva 0x34ADB0

__int64 __fastcall sub_7FF91DFAADB0(_DWORD *a1)
{
  int v1; // et0

  _mm_setcsr(*a1 | _mm_getcsr() & 0xFFFF7FFF);
  v1 = _mm_getcsr();
  _mm_setcsr(a1[1] | v1 & 0xFFFFFFBF);
  return a1[1] | v1 & 0xFFFFFFBF;
}

