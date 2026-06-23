// sub_1802FB610  @ 0x1802FB610  (RVA 0x2FB610)
// prototype: 
// callees: 0x1806AF654
// constants/globals referenced:
//   0x180948050 [.rdata] off_180948050  u32=2157215688  f32=-1.3637492706747693e-38  f64=3.187801953e-314
//   0x180939680 [.rdata] ??_7exception@std@@6B@  u32=2148275808  f32=-1.1100525914995471e-39  f64=3.1833850655e-314
//   0x1809480D0 [.rdata] aBoostThreadRes  u32=1936682850  f32=1.8970002151729668e+31  f64=7.511508920180635e+251
//   0x1809480C0 [.rdata] ??_7thread_resource_error@boost@@6B@  u32=2150624768  f32=-4.4016466322599694e-39  f64=3.184545606e-314

__int64 __fastcall sub_1802FB610(__int64 a1)
{
  __int128 v3; // [rsp+20h] [rbp-28h]
  const char *v4; // [rsp+30h] [rbp-18h] BYREF
  char v5; // [rsp+38h] [rbp-10h]

  LODWORD(v3) = 11;
  BYTE4(v3) = 1;
  *((_QWORD *)&v3 + 1) = &off_180948050;
  v5 = 1;
  *(_QWORD *)a1 = &std::exception::`vftable';
  *(_QWORD *)(a1 + 8) = 0;
  *(_QWORD *)(a1 + 16) = 0;
  v4 = "boost::thread_resource_error";
  _std_exception_copy(&v4, a1 + 8);
  *(_OWORD *)(a1 + 24) = v3;
  *(_QWORD *)(a1 + 56) = 0;
  *(_QWORD *)(a1 + 64) = 15;
  *(_BYTE *)(a1 + 40) = 0;
  *(_QWORD *)a1 = &boost::thread_resource_error::`vftable';
  return a1;
}

