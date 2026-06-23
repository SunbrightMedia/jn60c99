// sub_18034B2A0  @ 0x18034B2A0  (RVA 0x34B2A0)
// prototype: 
// callees: 0x180306830, 0x18034B2A0
// constants/globals referenced:
//   0x180934938 [.idata] __imp_WaitForSingleObjectEx  u32=4294967295  f32=nan  f64=nan

void __fastcall sub_18034B2A0(volatile signed __int32 *a1)
{
  signed __int32 i; // edx
  signed __int32 j; // ebx
  signed __int32 v4; // eax
  HANDLE v5; // rsi
  unsigned int v6; // ecx
  signed __int32 v7; // eax

  if ( _interlockedbittestandset(a1, 0x1Fu) )
  {
    for ( i = *a1; ; i = v4 )
    {
      j = i + 1;
      if ( i >= 0 )
        j = i | 0x80000000;
      v4 = _InterlockedCompareExchange(a1, j, i);
      if ( i == v4 )
        break;
    }
    if ( i >= 0 )
      j = i;
    if ( j < 0 )
    {
      v5 = sub_180306830((__int64)a1);
      do
      {
        if ( !WaitForSingleObjectEx(v5, 0xFFFFFFFF, 0) )
        {
          for ( j = j & 0x3FFFFFFF | 0x40000000; ; j = v7 )
          {
            v6 = j >= 0 ? (j - 1) | 0x80000000 : j;
            v7 = _InterlockedCompareExchange(a1, v6 & 0xBFFFFFFF, j);
            if ( j == v7 )
              break;
          }
        }
      }
      while ( j < 0 );
    }
  }
}

