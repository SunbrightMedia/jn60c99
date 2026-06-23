// __acrt_has_user_matherr  @ 0x180722728  (RVA 0x722728)
// prototype: __int64(void)
// callees: 
// constants/globals referenced:
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x180CB7A78 [.data] qword_180CB7A78  u32=4294967295  f32=nan  f64=nan

bool _acrt_has_user_matherr()
{
  return __ROR8__(qword_180CB7A78 ^ _security_cookie, _security_cookie & 0x3F) != 0;
}

