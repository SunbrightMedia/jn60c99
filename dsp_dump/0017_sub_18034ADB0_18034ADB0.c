// sub_18034ADB0  @ 0x18034ADB0  (RVA 0x34ADB0)
// prototype: 
// callees: 

__int64 __fastcall sub_18034ADB0(_DWORD *a1)
{
  int v1; // et0

  _mm_setcsr(*a1 | _mm_getcsr() & 0xFFFF7FFF);
  v1 = _mm_getcsr();
  _mm_setcsr(a1[1] | v1 & 0xFFFFFFBF);
  return a1[1] | v1 & 0xFFFFFFBF;
}

