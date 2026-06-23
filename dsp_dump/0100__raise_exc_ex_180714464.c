// _raise_exc_ex  @ 0x180714464  (RVA 0x714464)
// prototype: 
// callees: 0x180714464, 0x180714B28, 0x180714BE4
// constants/globals referenced:
//   0x1809347B0 [.idata] __imp_RaiseException  u32=4294967295  f32=nan  f64=nan

__int64 __fastcall raise_exc_ex(ULONG_PTR a1, _QWORD *a2, char a3, __int16 a4, _DWORD *a5, _DWORD *a6, int a7)
{
  DWORD v9; // edi
  char v10; // al
  __int64 v11; // rax
  _DWORD *v12; // rsi
  _DWORD *v13; // rcx
  int v14; // eax
  __int64 result; // rax
  ULONG_PTR Arguments; // [rsp+30h] [rbp+10h] BYREF

  Arguments = a1;
  v9 = -1073741811;
  *(_DWORD *)(a1 + 4) = 0;
  *(_DWORD *)(Arguments + 8) = 0;
  *(_DWORD *)(Arguments + 12) = 0;
  if ( (a3 & 0x10) != 0 )
  {
    v9 = -1073741681;
    *(_DWORD *)(Arguments + 4) |= 1u;
  }
  if ( (a3 & 2) != 0 )
  {
    v9 = -1073741677;
    *(_DWORD *)(Arguments + 4) |= 2u;
  }
  if ( (a3 & 1) != 0 )
  {
    v9 = -1073741679;
    *(_DWORD *)(Arguments + 4) |= 4u;
  }
  if ( (a3 & 4) != 0 )
  {
    v9 = -1073741682;
    *(_DWORD *)(Arguments + 4) |= 8u;
  }
  if ( (a3 & 8) != 0 )
  {
    v9 = -1073741680;
    *(_DWORD *)(Arguments + 4) |= 0x10u;
  }
  *(_DWORD *)(Arguments + 8) ^= (*(_DWORD *)(Arguments + 8) ^ ~(16 * (*a2 >> 7))) & 0x10;
  *(_DWORD *)(Arguments + 8) ^= (*(_DWORD *)(Arguments + 8) ^ ~(8 * (*a2 >> 9))) & 8;
  *(_DWORD *)(Arguments + 8) ^= (*(_DWORD *)(Arguments + 8) ^ ~(4 * (*a2 >> 10))) & 4;
  *(_DWORD *)(Arguments + 8) ^= (*(_DWORD *)(Arguments + 8) ^ ~(2 * (*a2 >> 11))) & 2;
  *(_DWORD *)(Arguments + 8) ^= (*(_DWORD *)(Arguments + 8) ^ ~(*(_DWORD *)a2 >> 12)) & 1;
  v10 = statfp();
  if ( (v10 & 1) != 0 )
    *(_DWORD *)(Arguments + 12) |= 0x10u;
  if ( (v10 & 4) != 0 )
    *(_DWORD *)(Arguments + 12) |= 8u;
  if ( (v10 & 8) != 0 )
    *(_DWORD *)(Arguments + 12) |= 4u;
  if ( (v10 & 0x10) != 0 )
    *(_DWORD *)(Arguments + 12) |= 2u;
  if ( (v10 & 0x20) != 0 )
    *(_DWORD *)(Arguments + 12) |= 1u;
  v11 = *(_DWORD *)a2 & 0x6000LL;
  if ( v11 )
  {
    switch ( v11 )
    {
      case 8192LL:
        *(_DWORD *)Arguments &= ~2u;
        *(_DWORD *)Arguments |= 1u;
        break;
      case 16384LL:
        *(_DWORD *)Arguments &= ~1u;
        *(_DWORD *)Arguments |= 2u;
        break;
      case 24576LL:
        *(_DWORD *)Arguments |= 3u;
        break;
    }
  }
  else
  {
    *(_DWORD *)Arguments &= 0xFFFFFFFC;
  }
  *(_DWORD *)Arguments &= 0xFFFE001F;
  *(_DWORD *)Arguments |= 32 * (a4 & 0xFFF);
  v12 = a6;
  *(_DWORD *)(Arguments + 32) |= 1u;
  if ( a7 )
  {
    *(_DWORD *)(Arguments + 32) &= 0xFFFFFFE1;
    *(_DWORD *)(Arguments + 16) = *a5;
    *(_DWORD *)(Arguments + 96) |= 1u;
    *(_DWORD *)(Arguments + 96) &= 0xFFFFFFE1;
    *(_DWORD *)(Arguments + 80) = *v12;
  }
  else
  {
    *(_DWORD *)(Arguments + 32) = *(_DWORD *)(Arguments + 32) & 0xFFFFFFE1 | 2;
    *(_QWORD *)(Arguments + 16) = *(_QWORD *)a5;
    *(_DWORD *)(Arguments + 96) |= 1u;
    *(_DWORD *)(Arguments + 96) = *(_DWORD *)(Arguments + 96) & 0xFFFFFFE1 | 2;
    *(_QWORD *)(Arguments + 80) = *(_QWORD *)v12;
  }
  clrfp();
  RaiseException(v9, 0, 1u, &Arguments);
  v13 = (_DWORD *)Arguments;
  v14 = *(_DWORD *)(Arguments + 8);
  if ( (v14 & 0x10) != 0 )
  {
    *a2 &= ~0x80uLL;
    v14 = v13[2];
  }
  if ( (v14 & 8) != 0 )
  {
    *a2 &= ~0x200uLL;
    v14 = v13[2];
  }
  if ( (v14 & 4) != 0 )
  {
    *a2 &= ~0x400uLL;
    v14 = v13[2];
  }
  if ( (v14 & 2) != 0 )
  {
    *a2 &= ~0x800uLL;
    v14 = v13[2];
  }
  if ( (v14 & 1) != 0 )
    *a2 &= ~0x1000uLL;
  if ( (*v13 & 3) != 0 )
  {
    switch ( *v13 & 3 )
    {
      case 1:
        *a2 &= ~0x4000uLL;
        *a2 |= 0x2000uLL;
        break;
      case 2:
        *a2 &= ~0x2000uLL;
        *a2 |= 0x4000uLL;
        break;
      case 3:
        *a2 |= 0x6000uLL;
        break;
    }
  }
  else
  {
    *a2 &= 0xFFFFFFFFFFFF9FFFuLL;
  }
  if ( a7 )
  {
    result = (unsigned int)v13[20];
    *v12 = result;
  }
  else
  {
    result = *((_QWORD *)v13 + 10);
    *(_QWORD *)v12 = result;
  }
  return result;
}

