// sub_1802F3E00  @ 0x1802F3E00  (RVA 0x2F3E00)
// prototype: 
// callees: 0x1800B7B50, 0x1802F3E00, 0x1802F9E80, 0x180303FD0, 0x180675268, 0x180675D20, 0x1806AF654, 0x1806AF6E4, 0x1806BC26C
// constants/globals referenced:
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x180939680 [.rdata] ??_7exception@std@@6B@  u32=2148275808  f32=-1.1100525914995471e-39  f64=3.1833850655e-314
//   0x180948090 [.rdata] ??_7system_error@system@boost@@6B@  u32=2150624576  f32=-4.401377582954819e-39  f64=3.184545511e-314
//   0x1809487C0 [.rdata] ??_7?$error_info_injector@Vthread_resource_error@boost@@@exception_detail@boost@@6B@  u32=2150622128  f32=-4.397947204314152e-39  f64=3.1845443016e-314
//   0x1809487D8 [.rdata] ??_7?$error_info_injector@Vthread_resource_error@boost@@@exception_detail@boost@@6B@_0  u32=2150620628  f32=-4.3958452566176647e-39  f64=3.1845435605e-314
//   0x180948878 [.rdata] unk_180948878  u32=4294967184  f32=nan  f64=3.6073928391e-313
//   0x180945AD0 [.rdata] ??_7clone_base@exception_detail@boost@@6B@  u32=2154492236  f32=-9.821123601485341e-39  f64=3.186456389e-314
//   0x1809487E8 [.rdata] ??_7?$clone_impl@U?$error_info_injector@Vthread_resource_error@boost@@@exception_detail@boost@@@exception_detail@boost@@6B@  u32=2150621408  f32=-4.396938269419838e-39  f64=3.184543946e-314
//   0x180948800 [.rdata] ??_7?$clone_impl@U?$error_info_injector@Vthread_resource_error@boost@@@exception_detail@boost@@@exception_detail@boost@@6B@_0  u32=2150620556  f32=-4.395744363128233e-39  f64=3.184543525e-314
//   0x180948810 [.rdata] ??_7?$clone_impl@U?$error_info_injector@Vthread_resource_error@boost@@@exception_detail@boost@@@exception_detail@boost@@6B@_1  u32=2150644448  f32=-4.429224186037882e-39  f64=3.184555329e-314
//   0x180948838 [.rdata] ??_7?$wrapexcept@Vthread_resource_error@boost@@@boost@@6B@  u32=2150623072  f32=-4.3992700300644745e-39  f64=3.184544768e-314
//   0x180948850 [.rdata] ??_7?$wrapexcept@Vthread_resource_error@boost@@@boost@@6B@_0  u32=2150621000  f32=-4.3963665396463935e-39  f64=3.1845437443e-314
//   0x180948860 [.rdata] ??_7?$wrapexcept@Vthread_resource_error@boost@@@boost@@6B@_1  u32=2150644448  f32=-4.429224186037882e-39  f64=3.184555329e-314
//   0x180947E98 [.rdata] ??_7exception@boost@@6B@  u32=2154492236  f32=-9.821123601485341e-39  f64=3.186456389e-314

// Hidden C++ exception states: #wind=6
_QWORD *__fastcall sub_1802F3E00(_QWORD *a1, __int64 a2)
{
  __int64 v4; // rcx
  char v5; // al
  __int64 v6; // rcx
  void *v7; // rcx
  void **v9; // [rsp+48h] [rbp-49h] BYREF
  _QWORD v10[2]; // [rsp+50h] [rbp-41h] BYREF
  __int128 v11; // [rsp+60h] [rbp-31h]
  _QWORD v12[3]; // [rsp+70h] [rbp-21h] BYREF
  unsigned __int64 v13; // [rsp+88h] [rbp-9h]
  void **v14; // [rsp+90h] [rbp-1h] BYREF
  __int128 v15; // [rsp+98h] [rbp+7h]
  __int64 v16; // [rsp+A8h] [rbp+17h]
  int v17; // [rsp+B0h] [rbp+1Fh]

  v10[0] = 0;
  v10[1] = 0;
  _std_exception_copy(a2 + 8, v10);
  v9 = &boost::system::system_error::`vftable';
  v11 = *(_OWORD *)(a2 + 24);
  sub_1800B7B50((__int64)v12, a2 + 40);
  v15 = 0;
  v16 = 0;
  v17 = -1;
  v9 = &boost::exception_detail::error_info_injector<boost::thread_resource_error>::`vftable';
  v14 = &boost::exception_detail::error_info_injector<boost::thread_resource_error>::`vftable';
  a1[14] = &unk_180948878;
  a1[16] = &boost::exception_detail::clone_base::`vftable';
  sub_1802F9E80(a1, &v9);
  *a1 = &boost::exception_detail::clone_impl<boost::exception_detail::error_info_injector<boost::thread_resource_error>>::`vftable';
  a1[9] = &boost::exception_detail::clone_impl<boost::exception_detail::error_info_injector<boost::thread_resource_error>>::`vftable';
  *(_QWORD *)((char *)a1 + *(int *)(a1[14] + 4LL) + 112) = &boost::exception_detail::clone_impl<boost::exception_detail::error_info_injector<boost::thread_resource_error>>::`vftable';
  *(_DWORD *)((char *)a1 + *(int *)(a1[14] + 4LL) + 108) = *(_DWORD *)(a1[14] + 4LL) - 16;
  sub_180303FD0(a1 + 9, &v14);
  *a1 = &boost::wrapexcept<boost::thread_resource_error>::`vftable';
  a1[9] = &boost::wrapexcept<boost::thread_resource_error>::`vftable';
  *(_QWORD *)((char *)a1 + *(int *)(a1[14] + 4LL) + 112) = &boost::wrapexcept<boost::thread_resource_error>::`vftable';
  v4 = *(int *)(a1[14] + 4LL);
  *(_DWORD *)((char *)a1 + v4 + 108) = v4 - 16;
  v9 = &boost::exception_detail::error_info_injector<boost::thread_resource_error>::`vftable';
  v14 = &boost::exception::`vftable';
  if ( (_QWORD)v15 )
  {
    v5 = (*(__int64 (__fastcall **)(_QWORD))(*(_QWORD *)v15 + 32LL))(v15);
    v6 = v15;
    if ( v5 )
      v6 = 0;
    *(_QWORD *)&v15 = v6;
  }
  v9 = &boost::system::system_error::`vftable';
  if ( v13 >= 0x10 )
  {
    v7 = (void *)v12[0];
    if ( v13 + 1 >= 0x1000 )
    {
      v7 = *(void **)(v12[0] - 8LL);
      if ( (unsigned __int64)(v12[0] - (_QWORD)v7 - 8LL) > 0x1F )
        invalid_parameter_noinfo_noreturn();
    }
    j_j_free(v7);
  }
  v12[2] = 0;
  v13 = 15;
  LOBYTE(v12[0]) = 0;
  v9 = &std::exception::`vftable';
  _std_exception_destroy(v10);
  return a1;
}

