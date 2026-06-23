// sub_1803C8390  @ 0x1803C8390  (RVA 0x3C8390)
// prototype: __int64 __fastcall(_QWORD)
// callees: 0x18034B2A0, 0x1803C56C0, 0x1803C5BC0, 0x1803C8390, 0x180675D20
// constants/globals referenced:
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x1809DF350 [.rdata] aBoostUniqueLoc_0  u32=1936682850  f32=1.8970002151729668e+31  f64=1.221884167539612e+224
//   0x1809DF308 [.rdata] aBoostUniqueLoc  u32=1936682850  f32=1.8970002151729668e+31  f64=1.221884167539612e+224

// Hidden C++ exception states: #wind=2
void __fastcall sub_1803C8390(__int64 a1)
{
  volatile signed __int32 *v2; // rcx
  _QWORD *v3; // rax
  _QWORD *v4; // rcx
  _QWORD v5[10]; // [rsp+30h] [rbp-68h] BYREF

  v2 = *(volatile signed __int32 **)a1;
  if ( !v2 )
  {
    v4 = sub_1803C5BC0(v5, 1, (__int64)"boost unique_lock has no mutex");
    sub_1803C56C0((__int64)v4);
  }
  if ( *(_BYTE *)(a1 + 8) )
  {
    v3 = sub_1803C5BC0(v5, 36, (__int64)"boost unique_lock owns already the mutex");
    sub_1803C56C0((__int64)v3);
  }
  sub_18034B2A0(v2);
  *(_BYTE *)(a1 + 8) = 1;
}

