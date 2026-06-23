// sub_1802FB4B0  @ 0x1802FB4B0  (RVA 0x2FB4B0)
// prototype: __int64 __fastcall(_QWORD)
// callees: 0x1800B7B50, 0x1806AF654
// constants/globals referenced:
//   0x180939680 [.rdata] ??_7exception@std@@6B@  u32=2148275808  f32=-1.1100525914995471e-39  f64=3.1833850655e-314
//   0x180948090 [.rdata] ??_7system_error@system@boost@@6B@  u32=2150624576  f32=-4.401377582954819e-39  f64=3.184545511e-314
//   0x1809480A8 [.rdata] ??_7thread_exception@boost@@6B@  u32=2150624704  f32=-4.4015569491582526e-39  f64=3.1845455743e-314

// Hidden C++ exception states: #wind=1
__int64 __fastcall sub_1802FB4B0(__int64 a1, __int64 a2)
{
  *(_QWORD *)a1 = &std::exception::`vftable';
  *(_QWORD *)(a1 + 8) = 0;
  *(_QWORD *)(a1 + 16) = 0;
  _std_exception_copy(a2 + 8, a1 + 8);
  *(_QWORD *)a1 = &boost::system::system_error::`vftable';
  *(_OWORD *)(a1 + 24) = *(_OWORD *)(a2 + 24);
  sub_1800B7B50(a1 + 40, a2 + 40);
  *(_QWORD *)a1 = &boost::thread_exception::`vftable';
  return a1;
}

