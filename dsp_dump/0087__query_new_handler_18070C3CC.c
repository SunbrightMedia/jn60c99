// _query_new_handler  @ 0x18070C3CC  (RVA 0x70C3CC)
// prototype: _PNH __cdecl()
// callees: 0x18070ABE8, 0x18070AC3C
// constants/globals referenced:
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x180CB7078 [.data] qword_180CB7078  u32=4294967295  f32=nan  f64=nan

_PNH __cdecl query_new_handler()
{
  int (__cdecl *v0)(size_t); // rbx

  _vcrt_lock_0(0);
  v0 = (int (__cdecl *)(size_t))__ROR8__(qword_180CB7078 ^ _security_cookie, _security_cookie & 0x3F);
  _vcrt_unlock_0(0);
  return v0;
}

