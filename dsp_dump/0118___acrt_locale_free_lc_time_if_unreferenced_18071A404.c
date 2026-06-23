// __acrt_locale_free_lc_time_if_unreferenced  @ 0x18071A404  (RVA 0x71A404)
// prototype: __int64 __fastcall(void *Block)
// callees: 0x18070FB50, 0x180719EF8, 0x18071A404
// constants/globals referenced:
//   0x180A92AD0 [.rdata] off_180A92AD0  u32=2158570896  f32=-1.55365435959884e-38  f64=3.188471515e-314

void __fastcall _acrt_locale_free_lc_time_if_unreferenced(void **Block)
{
  if ( Block && Block != (void **)&off_180A92AD0 && !*((_DWORD *)Block + 87) )
  {
    _acrt_locale_free_time(Block);
    free_base(Block);
  }
}

