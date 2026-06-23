// __acrt_release_locale_ref  @ 0x18071A464  (RVA 0x71A464)
// prototype: __int64(void)
// callees: 0x18071A43C, 0x18071A464
// constants/globals referenced:
//   0x180C955C8 [.data] unk_180C955C8  u32=67  f32=9.388699710976274e-44  f64=3.3e-322

void __fastcall _acrt_release_locale_ref(__int64 a1)
{
  volatile signed __int32 *v1; // rax
  volatile signed __int32 *v2; // rax
  volatile signed __int32 *v3; // rax
  volatile signed __int32 *v4; // rax
  volatile signed __int32 **v5; // rax
  __int64 v6; // r8
  volatile signed __int32 *v7; // rdx

  if ( a1 )
  {
    _InterlockedAdd((volatile signed __int32 *)(a1 + 16), 0xFFFFFFFF);
    v1 = *(volatile signed __int32 **)(a1 + 224);
    if ( v1 )
      _InterlockedAdd(v1, 0xFFFFFFFF);
    v2 = *(volatile signed __int32 **)(a1 + 240);
    if ( v2 )
      _InterlockedAdd(v2, 0xFFFFFFFF);
    v3 = *(volatile signed __int32 **)(a1 + 232);
    if ( v3 )
      _InterlockedAdd(v3, 0xFFFFFFFF);
    v4 = *(volatile signed __int32 **)(a1 + 256);
    if ( v4 )
      _InterlockedAdd(v4, 0xFFFFFFFF);
    v5 = (volatile signed __int32 **)(a1 + 56);
    v6 = 6;
    do
    {
      if ( *(v5 - 2) != (volatile signed __int32 *)&unk_180C955C8 && *v5 )
        _InterlockedAdd(*v5, 0xFFFFFFFF);
      if ( *(v5 - 3) )
      {
        v7 = *(v5 - 1);
        if ( v7 )
          _InterlockedAdd(v7, 0xFFFFFFFF);
      }
      v5 += 4;
      --v6;
    }
    while ( v6 );
    _acrt_locale_release_lc_time_reference(*(_QWORD *)(a1 + 288));
  }
}

