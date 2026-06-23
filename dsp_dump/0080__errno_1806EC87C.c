// _errno  @ 0x1806EC87C  (RVA 0x6EC87C)
// prototype: int *__cdecl()
// callees: 0x1806EC87C, 0x18070FA0C
// constants/globals referenced:
//   0x180C95210 [.data] unk_180C95210  u32=12  f32=1.6815581571897805e-44  f64=1.69759663337e-313

int *__cdecl errno()
{
  __int64 v0; // rax

  v0 = _acrt_getptd_noexit();
  if ( v0 )
    return (int *)(v0 + 32);
  else
    return (int *)&unk_180C95210;
}

