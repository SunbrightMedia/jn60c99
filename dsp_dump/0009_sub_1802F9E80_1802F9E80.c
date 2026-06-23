// sub_1802F9E80  @ 0x1802F9E80  (RVA 0x2F9E80)
// prototype: __int64 __fastcall(_QWORD, _QWORD)
// callees: 0x1802F9E80, 0x1802FB4B0
// constants/globals referenced:
//   0x1809480C0 [.rdata] ??_7thread_resource_error@boost@@6B@  u32=2150624768  f32=-4.4016466322599694e-39  f64=3.184545606e-314
//   0x180947E98 [.rdata] ??_7exception@boost@@6B@  u32=2154492236  f32=-9.821123601485341e-39  f64=3.186456389e-314
//   0x1809487C0 [.rdata] ??_7?$error_info_injector@Vthread_resource_error@boost@@@exception_detail@boost@@6B@  u32=2150622128  f32=-4.397947204314152e-39  f64=3.1845443016e-314
//   0x1809487D8 [.rdata] ??_7?$error_info_injector@Vthread_resource_error@boost@@@exception_detail@boost@@6B@_0  u32=2150620628  f32=-4.3958452566176647e-39  f64=3.1845435605e-314

// Hidden C++ exception states: #wind=1
__int64 __fastcall sub_1802F9E80(__int64 a1, __int64 a2)
{
  __int64 v4; // rcx

  sub_1802FB4B0(a1);
  *(_QWORD *)a1 = &boost::thread_resource_error::`vftable';
  *(_QWORD *)(a1 + 72) = &boost::exception::`vftable';
  v4 = *(_QWORD *)(a2 + 80);
  *(_QWORD *)(a1 + 80) = v4;
  if ( v4 )
    (*(void (__fastcall **)(__int64))(*(_QWORD *)v4 + 24LL))(v4);
  *(_QWORD *)(a1 + 88) = *(_QWORD *)(a2 + 88);
  *(_QWORD *)(a1 + 96) = *(_QWORD *)(a2 + 96);
  *(_DWORD *)(a1 + 104) = *(_DWORD *)(a2 + 104);
  *(_QWORD *)a1 = &boost::exception_detail::error_info_injector<boost::thread_resource_error>::`vftable';
  *(_QWORD *)(a1 + 72) = &boost::exception_detail::error_info_injector<boost::thread_resource_error>::`vftable';
  return a1;
}

