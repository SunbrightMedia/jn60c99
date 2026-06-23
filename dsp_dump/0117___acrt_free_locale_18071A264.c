// __acrt_free_locale  @ 0x18071A264  (RVA 0x71A264)
// prototype: __int64 __fastcall(void *Block)
// callees: 0x18070FB50, 0x180719040, 0x1807196B4, 0x18071A264, 0x18071A404
// constants/globals referenced:
//   0x180C95160 [.data] off_180C95160  u32=2160677376  f32=-1.848835078511934e-38  f64=3.189512254e-314
//   0x180C955C8 [.data] unk_180C955C8  u32=67  f32=9.388699710976274e-44  f64=3.3e-322

void __fastcall _acrt_free_locale(char *Block)
{
  _UNKNOWN **v1; // rax
  _DWORD *v3; // rax
  _DWORD *v4; // rcx
  _DWORD *v5; // rcx
  _DWORD *v6; // rax
  void **v7; // rsi
  __int64 v8; // rbp
  _DWORD **v9; // rdi
  _DWORD *v10; // rcx
  _DWORD *v11; // rcx

  v1 = *((_UNKNOWN ***)Block + 31);
  if ( v1 )
  {
    if ( v1 != &off_180C95160 )
    {
      v3 = *((_DWORD **)Block + 28);
      if ( v3 )
      {
        if ( !*v3 )
        {
          v4 = *((_DWORD **)Block + 30);
          if ( v4 && !*v4 )
          {
            free_base(v4);
            _free_lconv_mon(*((_QWORD **)Block + 31));
          }
          v5 = *((_DWORD **)Block + 29);
          if ( v5 && !*v5 )
          {
            free_base(v5);
            _free_lconv_num(*((_QWORD *)Block + 31));
          }
          free_base(*((void **)Block + 28));
          free_base(*((void **)Block + 31));
        }
      }
    }
  }
  v6 = *((_DWORD **)Block + 32);
  if ( v6 && !*v6 )
  {
    free_base((void *)(*((_QWORD *)Block + 33) - 254LL));
    free_base((void *)(*((_QWORD *)Block + 34) - 128LL));
    free_base((void *)(*((_QWORD *)Block + 35) - 128LL));
    free_base(*((void **)Block + 32));
  }
  _acrt_locale_free_lc_time_if_unreferenced(*((void **)Block + 36));
  v7 = (void **)(Block + 296);
  v8 = 6;
  v9 = (_DWORD **)(Block + 56);
  do
  {
    if ( *(v9 - 2) != (_DWORD *)&unk_180C955C8 )
    {
      v10 = *v9;
      if ( *v9 )
      {
        if ( !*v10 )
        {
          free_base(v10);
          free_base(*v7);
        }
      }
    }
    if ( *(v9 - 3) )
    {
      v11 = *(v9 - 1);
      if ( v11 )
      {
        if ( !*v11 )
          free_base(v11);
      }
    }
    ++v7;
    v9 += 4;
    --v8;
  }
  while ( v8 );
  free_base(Block);
}

