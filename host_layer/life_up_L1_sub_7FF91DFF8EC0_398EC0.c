// sub_7FF91DFF8EC0 @ rva 0x398EC0

void __fastcall sub_7FF91DFF8EC0(__int64 a1, float **a2, __int64 a3)
{
  int v4; // eax

  if ( *(_BYTE *)(a1 + 20) )
  {
    v4 = *(_DWORD *)(a1 + 11022344);
    if ( v4 <= 0 )
    {
      **(_DWORD **)a3 = 0;
      **(_DWORD **)(a3 + 8) = 0;
      sub_7FF91DFC3380(a1, a2, (float **)a3);
      sub_7FF91E0224A0((_QWORD *)a1);
    }
    else
    {
      *(_DWORD *)(a1 + 11022344) = v4 - 1;
      **(_DWORD **)a3 = 0;
      **(_DWORD **)(a3 + 8) = 0;
      sub_7FF91E0224A0((_QWORD *)a1);
    }
  }
}

