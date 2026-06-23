// __acrt_getptd_noexit  @ 0x18070FA0C  (RVA 0x70FA0C)
// prototype: __int64(void)
// callees: 0x18070F344, 0x18070FA0C, 0x18070FB50, 0x18070FB90, 0x180710B7C, 0x180710BC4
// constants/globals referenced:
//   0x1809347B8 [.idata] __imp_GetLastError  u32=4294967295  f32=nan  f64=nan
//   0x180C95400 [.data] dword_180C95400  u32=4294967295  f32=nan  f64=2.1219957905e-314
//   0x180934858 [.idata] __imp_SetLastError  u32=4294967295  f32=nan  f64=nan

__int64 _acrt_getptd_noexit()
{
  DWORD LastError; // eax
  DWORD v1; // ecx
  DWORD v2; // ebx
  __int64 Value; // rax
  struct __acrt_ptd *v4; // rdi
  struct __acrt_ptd *v5; // rsi
  struct __acrt_ptd *v6; // rax
  struct __acrt_ptd *v7; // rcx

  LastError = GetLastError();
  v1 = dword_180C95400;
  v2 = LastError;
  if ( dword_180C95400 == -1 )
  {
LABEL_6:
    if ( !(unsigned int)_acrt_FlsSetValue(v1, (LPVOID)0xFFFFFFFFFFFFFFFFLL) )
      goto LABEL_4;
    v6 = (struct __acrt_ptd *)calloc_base(1u, 0x3C8u);
    v4 = v6;
    if ( v6 )
    {
      if ( (unsigned int)_acrt_FlsSetValue(dword_180C95400, v6) )
      {
        construct_ptd_array(v4);
        free_base(nullptr);
        goto LABEL_13;
      }
      _acrt_FlsSetValue(dword_180C95400, nullptr);
      v7 = v4;
    }
    else
    {
      _acrt_FlsSetValue(dword_180C95400, nullptr);
      v7 = nullptr;
    }
    free_base(v7);
    goto LABEL_4;
  }
  Value = _acrt_FlsGetValue();
  v4 = (struct __acrt_ptd *)Value;
  if ( !Value )
  {
    v1 = dword_180C95400;
    goto LABEL_6;
  }
  if ( Value != -1 )
  {
LABEL_13:
    v5 = v4;
    goto LABEL_14;
  }
LABEL_4:
  v4 = nullptr;
  v5 = nullptr;
LABEL_14:
  SetLastError(v2);
  return (unsigned __int64)v5 & -(__int64)(v4 != nullptr);
}

