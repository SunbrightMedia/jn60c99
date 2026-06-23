// __acrt_errno_from_os_error  @ 0x1806EC7C4  (RVA 0x6EC7C4)
// prototype: 
// callees: 0x1806EC7C4
// constants/globals referenced:
//   0x180A8EC50 [.rdata] dword_180A8EC50  u32=1  f32=1.401298464324817e-45  f64=4.66839074017e-313

__int64 __fastcall _acrt_errno_from_os_error(int a1)
{
  __int64 v1; // rax
  unsigned int *v2; // rdx
  __int64 result; // rax

  v1 = 0;
  v2 = dword_180A8EC50;
  do
  {
    if ( a1 == *v2 )
      return dword_180A8EC50[2 * v1 + 1];
    v1 = (unsigned int)(v1 + 1);
    v2 += 2;
  }
  while ( (unsigned int)v1 < 0x2D );
  if ( (unsigned int)(a1 - 19) <= 0x11 )
    return 13;
  result = 22;
  if ( (unsigned int)(a1 - 188) <= 0xE )
    return 8;
  return result;
}

