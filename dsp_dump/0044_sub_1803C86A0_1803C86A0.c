// sub_1803C86A0  @ 0x1803C86A0  (RVA 0x3C86A0)
// prototype: __int64 __fastcall(_QWORD)
// callees: 0x180306830, 0x18034B2A0, 0x1803C86A0, 0x180675268
// constants/globals referenced:
//   0x1809347D0 [.idata] __imp_CloseHandle  u32=4294967295  f32=nan  f64=nan
//   0x1809347F0 [.idata] __imp_SetEvent  u32=4294967295  f32=nan  f64=nan

// Hidden C++ exception states: #wind=1
void __fastcall sub_1803C86A0(_QWORD *a1)
{
  volatile signed __int32 *v2; // rdi
  __int64 v3; // rbx
  char *v4; // rcx
  signed __int32 v5; // eax
  HANDLE v6; // rax

  if ( *a1 )
  {
    v2 = (volatile signed __int32 *)a1[1];
    sub_18034B2A0(v2);
    _InterlockedDecrement((volatile signed __int32 *)(*a1 + 16LL));
    v3 = *a1;
    *a1 = 0;
    if ( v3 && _InterlockedExchangeAdd((volatile signed __int32 *)(v3 + 24), 0xFFFFFFFF) == 1 )
    {
      v4 = *(char **)(v3 + 8);
      if ( (unsigned __int64)(v4 - 1) <= 0xFFFFFFFFFFFFFFFDuLL )
        CloseHandle(v4);
      if ( (unsigned __int64)(*(_QWORD *)v3 - 1LL) <= 0xFFFFFFFFFFFFFFFDuLL )
        CloseHandle(*(HANDLE *)v3);
      j_j_free((void *)v3);
    }
    v5 = _InterlockedExchangeAdd(v2, 0x80000000);
    if ( (v5 & 0x40000000) == 0 && v5 != 0x80000000 && !_interlockedbittestandset(v2, 0x1Eu) )
    {
      v6 = sub_180306830((__int64)v2);
      SetEvent(v6);
    }
  }
}

