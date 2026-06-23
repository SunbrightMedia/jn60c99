// sub_1803C2E00  @ 0x1803C2E00  (RVA 0x3C2E00)
// prototype: __int64 __fastcall(_QWORD)
// callees: 0x1803C2E00

char __fastcall sub_1803C2E00(__int64 a1)
{
  float v1; // xmm0_4
  float *v2; // rax
  float v3; // xmm2_4
  float v4; // xmm1_4

  if ( *(_BYTE *)(a1 + 28) )
  {
    if ( ++*(_DWORD *)(a1 + 36) < *(_DWORD *)(a1 + 32) )
      return 1;
    v1 = *(float *)(a1 + 8) + *(float *)(a1 + 12);
    v2 = *(float **)a1;
    *(_DWORD *)(a1 + 36) = 0;
    *(float *)(a1 + 12) = v1;
    *v2 = v1 + *(float *)(a1 + 16);
    v3 = **(float **)a1;
    v4 = *(float *)(a1 + 20);
    if ( *(float *)(a1 + 8) <= 0.0 )
    {
      if ( v3 > v4 )
        return 1;
    }
    else if ( v3 < v4 )
    {
      return 1;
    }
    **(float **)a1 = v4;
    *(_DWORD *)(a1 + 12) = 0;
    *(_BYTE *)(a1 + 28) = 0;
  }
  return 0;
}

