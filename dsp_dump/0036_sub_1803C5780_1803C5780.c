// sub_1803C5780  @ 0x1803C5780  (RVA 0x3C5780)
// prototype: __int64 __fastcall(_QWORD, _QWORD)
// callees: 0x1802FB4B0, 0x1803C5780
// constants/globals referenced:
//   0x1809DF1C0 [.rdata] ??_7lock_error@boost@@6B@  u32=2151442192  f32=-5.5471016281622187e-39  f64=3.184949467e-314
//   0x180947E98 [.rdata] ??_7exception@boost@@6B@  u32=2154492236  f32=-9.821123601485341e-39  f64=3.186456389e-314
//   0x1809DF388 [.rdata] ??_7?$error_info_injector@Vlock_error@boost@@@exception_detail@boost@@6B@  u32=2151441648  f32=-5.546339321797626e-39  f64=3.1849491983e-314
//   0x1809DF3A0 [.rdata] ??_7?$error_info_injector@Vlock_error@boost@@@exception_detail@boost@@6B@_0  u32=2151441516  f32=-5.546154350400335e-39  f64=3.184949133e-314

// Hidden C++ exception states: #wind=1
__int64 __fastcall sub_1803C5780(__int64 a1, __int64 a2)
{
  __int64 v4; // rcx

  sub_1802FB4B0(a1, a2);
  *(_QWORD *)a1 = &boost::lock_error::`vftable';
  *(_QWORD *)(a1 + 72) = &boost::exception::`vftable';
  v4 = *(_QWORD *)(a2 + 80);
  *(_QWORD *)(a1 + 80) = v4;
  if ( v4 )
    (*(void (__fastcall **)(__int64))(*(_QWORD *)v4 + 24LL))(v4);
  *(_QWORD *)(a1 + 88) = *(_QWORD *)(a2 + 88);
  *(_QWORD *)(a1 + 96) = *(_QWORD *)(a2 + 96);
  *(_DWORD *)(a1 + 104) = *(_DWORD *)(a2 + 104);
  *(_QWORD *)a1 = &boost::exception_detail::error_info_injector<boost::lock_error>::`vftable';
  *(_QWORD *)(a1 + 72) = &boost::exception_detail::error_info_injector<boost::lock_error>::`vftable';
  return a1;
}

