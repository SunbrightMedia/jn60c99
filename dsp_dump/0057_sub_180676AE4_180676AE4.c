// sub_180676AE4  @ 0x180676AE4  (RVA 0x676AE4)
// prototype: 
// callees: 
// constants/globals referenced:
//   0x180A86840 [.rdata] aBadArrayNewLen  u32=543449442  f32=1.9344572467196402e-19  f64=2.593454324712013e+161
//   0x180A86830 [.rdata] ??_7bad_array_new_length@std@@6B@  u32=2154261272  f32=-9.497474102971024e-39  f64=3.1863422776e-314

_QWORD *__fastcall sub_180676AE4(_QWORD *a1)
{
  a1[2] = 0;
  a1[1] = "bad array new length";
  *a1 = &std::bad_array_new_length::`vftable';
  return a1;
}

