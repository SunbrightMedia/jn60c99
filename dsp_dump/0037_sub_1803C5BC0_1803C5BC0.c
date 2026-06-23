// sub_1803C5BC0  @ 0x1803C5BC0  (RVA 0x3C5BC0)
// prototype: 
// callees: 0x1802FB530
// constants/globals referenced:
//   0x1809DF1C0 [.rdata] ??_7lock_error@boost@@6B@  u32=2151442192  f32=-5.5471016281622187e-39  f64=3.184949467e-314

_QWORD *__fastcall sub_1803C5BC0(_QWORD *a1, int a2, __int64 a3)
{
  sub_1802FB530((__int64)a1, a2, a3);
  *a1 = &boost::lock_error::`vftable';
  return a1;
}

