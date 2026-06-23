// sub_1803C6F00  @ 0x1803C6F00  (RVA 0x3C6F00)
// prototype: 
// *** AUDIO ROOT ***
// callees: 0x180306830, 0x18034AD10, 0x18034ADB0, 0x18034B2A0, 0x180398F30, 0x1803C52E0, 0x1803C56C0, 0x1803C5BC0, 0x1803C6F00, 0x1803C8440, 0x180675D20
// constants/globals referenced:
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x1809347F0 [.idata] __imp_SetEvent  u32=4294967295  f32=nan  f64=nan
//   0x1809DF308 [.rdata] aBoostUniqueLoc  u32=1936682850  f32=1.8970002151729668e+31  f64=1.221884167539612e+224

// Hidden C++ exception states: #wind=7
__int64 __fastcall sub_1803C6F00(__int64 a1, int a2)
{
  volatile signed __int32 *v4; // rax
  char v5; // cl
  int v6; // eax
  int i; // ebx
  __int64 v8; // rbx
  signed __int32 v9; // eax
  HANDLE v10; // rax
  volatile signed __int32 *v11; // rcx
  signed __int32 v12; // eax
  HANDLE v13; // rax
  volatile signed __int32 *v14; // rcx
  signed __int32 v15; // eax
  HANDLE v16; // rax
  volatile signed __int32 *v17; // rcx
  signed __int32 v18; // eax
  HANDLE v19; // rax
  _QWORD *v21; // rcx
  volatile signed __int32 *v22; // [rsp+20h] [rbp-B8h] BYREF
  char v23; // [rsp+28h] [rbp-B0h]
  __int64 v24; // [rsp+30h] [rbp-A8h] BYREF
  int v25; // [rsp+38h] [rbp-A0h] BYREF
  __int64 v26; // [rsp+40h] [rbp-98h]
  _QWORD v27[10]; // [rsp+50h] [rbp-88h] BYREF

  v26 = -2;
  sub_18034AD10(&v25);
  v4 = (volatile signed __int32 *)(a1 + 56);
  v22 = (volatile signed __int32 *)(a1 + 56);
  v23 = 0;
  if ( a1 == -56 )
  {
    v21 = sub_1803C5BC0(v27, 1, (__int64)"boost unique_lock has no mutex");
    sub_1803C56C0((__int64)v21);
  }
  while ( 1 )
  {
    while ( 1 )
    {
      sub_18034B2A0(v4);
      v5 = 1;
      v23 = 1;
      v6 = *(_DWORD *)(a1 + 52);
      if ( !v6 )
      {
        do
        {
          v24 = 0x7FFFFFFFFFFFFFFFLL;
          sub_1803C52E0(a1 + 72, (__int64)&v22, (__int64)&v24);
          v6 = *(_DWORD *)(a1 + 52);
        }
        while ( !v6 );
        v5 = v23;
      }
      if ( v6 != 1 )
        break;
      for ( i = 0; i < *(_DWORD *)(a1 + 48); ++i )
      {
        sub_180398F30(*(_QWORD *)(a1 + 24), a2, (_DWORD **)(a1 + 32));
        *(_QWORD *)(a1 + 32) += 4LL;
        *(_QWORD *)(a1 + 40) += 4LL;
        if ( !a2 )
          (*(void (__fastcall **)(_QWORD))(**(_QWORD **)(a1 + 8) + 104LL))(*(_QWORD *)(a1 + 8));
      }
      *(_DWORD *)(a1 + 52) = 0;
      v8 = *(_QWORD *)(a1 + 16);
      sub_18034B2A0((volatile signed __int32 *)(v8 + 8));
      ++**(_DWORD **)(a1 + 16);
      sub_1803C8440(*(_QWORD *)(a1 + 16) + 24LL);
      v9 = _InterlockedExchangeAdd((volatile signed __int32 *)(v8 + 8), 0x80000000);
      if ( (v9 & 0x40000000) == 0
        && v9 != 0x80000000
        && !_interlockedbittestandset((volatile signed __int32 *)(v8 + 8), 0x1Eu) )
      {
        v10 = sub_180306830(v8 + 8);
        SetEvent(v10);
      }
      if ( v23 )
      {
        v11 = v22;
        v12 = _InterlockedExchangeAdd(v22, 0x80000000);
        if ( (v12 & 0x40000000) == 0 && v12 != 0x80000000 && !_interlockedbittestandset(v11, 0x1Eu) )
        {
          v13 = sub_180306830((__int64)v11);
          SetEvent(v13);
        }
      }
      v4 = (volatile signed __int32 *)(a1 + 56);
      v22 = (volatile signed __int32 *)(a1 + 56);
      v23 = 0;
    }
    if ( v6 == 2 )
      break;
    if ( v5 )
    {
      v14 = v22;
      v15 = _InterlockedExchangeAdd(v22, 0x80000000);
      if ( (v15 & 0x40000000) == 0 && v15 != 0x80000000 && !_interlockedbittestandset(v14, 0x1Eu) )
      {
        v16 = sub_180306830((__int64)v14);
        SetEvent(v16);
      }
    }
    v4 = (volatile signed __int32 *)(a1 + 56);
    v22 = (volatile signed __int32 *)(a1 + 56);
    v23 = 0;
  }
  if ( v5 )
  {
    v17 = v22;
    v18 = _InterlockedExchangeAdd(v22, 0x80000000);
    if ( (v18 & 0x40000000) == 0 && v18 != 0x80000000 && !_interlockedbittestandset(v17, 0x1Eu) )
    {
      v19 = sub_180306830((__int64)v17);
      SetEvent(v19);
    }
  }
  return sub_18034ADB0(&v25);
}

