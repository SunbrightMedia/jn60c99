// sub_1800C16B0  @ 0x1800C16B0  (RVA 0xC16B0)
// prototype: 
// callees: 
// constants/globals referenced:
//   0x180AC2E00 [.rdata] aBadAllocation  u32=543449442  f32=1.9344572467196402e-19  f64=5.386691410895717e+228
//   0x180947C98 [.rdata] ??_7bad_alloc@std@@6B@  u32=2148275936  f32=-1.1102319577029807e-39  f64=3.1833851287e-314

_QWORD *__fastcall sub_1800C16B0(_QWORD *a1)
{
  a1[2] = 0;
  a1[1] = "bad allocation";
  *a1 = &std::bad_alloc::`vftable';
  return a1;
}

