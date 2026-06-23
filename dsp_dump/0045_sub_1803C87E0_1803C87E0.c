// sub_1803C87E0  @ 0x1803C87E0  (RVA 0x3C87E0)
// prototype: __int64 __fastcall(_QWORD)
// callees: 0x180306830, 0x1803C56C0, 0x1803C5BC0, 0x1803C87E0, 0x180675D20
// constants/globals referenced:
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x1809347F0 [.idata] __imp_SetEvent  u32=4294967295  f32=nan  f64=nan
//   0x1809DF328 [.rdata] aBoostUniqueLoc_1  u32=1936682850  f32=1.8970002151729668e+31  f64=1.221884167539612e+224
//   0x1809DF308 [.rdata] aBoostUniqueLoc  u32=1936682850  f32=1.8970002151729668e+31  f64=1.221884167539612e+224

// Hidden C++ exception states: #wind=2
signed __int32 __fastcall sub_1803C87E0(__int64 a1)
{
  volatile signed __int32 *v2; // rcx
  signed __int32 result; // eax
  HANDLE v4; // rax
  _QWORD *v5; // rax
  _QWORD *v6; // rcx
  _QWORD v7[10]; // [rsp+30h] [rbp-B8h] BYREF
  _QWORD v8[10]; // [rsp+80h] [rbp-68h] BYREF

  v2 = *(volatile signed __int32 **)a1;
  if ( !v2 )
  {
    v6 = sub_1803C5BC0(v7, 1, (__int64)"boost unique_lock has no mutex");
    sub_1803C56C0((__int64)v6);
  }
  if ( !*(_BYTE *)(a1 + 8) )
  {
    v5 = sub_1803C5BC0(v8, 1, (__int64)"boost unique_lock doesn't own the mutex");
    sub_1803C56C0((__int64)v5);
  }
  result = _InterlockedExchangeAdd(v2, 0x80000000);
  if ( (result & 0x40000000) == 0 && result != 0x80000000 && !_interlockedbittestandset(v2, 0x1Eu) )
  {
    v4 = sub_180306830((__int64)v2);
    result = SetEvent(v4);
  }
  *(_BYTE *)(a1 + 8) = 0;
  return result;
}

