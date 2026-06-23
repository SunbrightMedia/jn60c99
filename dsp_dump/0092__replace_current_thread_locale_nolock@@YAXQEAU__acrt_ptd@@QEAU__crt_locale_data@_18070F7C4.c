// ?replace_current_thread_locale_nolock@@YAXQEAU__acrt_ptd@@QEAU__crt_locale_data@@@Z  @ 0x18070F7C4  (RVA 0x70F7C4)
// prototype: void __fastcall(struct __acrt_ptd *const, struct __crt_locale_data *const)
// callees: 0x18070F7C4, 0x18071A1D8, 0x18071A264, 0x18071A464
// constants/globals referenced:
//   0x180CB79C8 [.data] qword_180CB79C8  u32=4294967295  f32=nan  f64=nan
//   0x180C95460 [.data] off_180C95460  u32=2158565232  f32=-1.5528606641486464e-38  f64=3.1884687164e-314

void __fastcall replace_current_thread_locale_nolock(struct __acrt_ptd *const a1, struct __crt_locale_data *const a2)
{
  wchar_t **v4; // rcx

  if ( *((_QWORD *)a1 + 18) )
  {
    _acrt_release_locale_ref();
    v4 = *((wchar_t ***)a1 + 18);
    if ( v4 != (wchar_t **)qword_180CB79C8 && v4 != &off_180C95460 && !*((_DWORD *)v4 + 4) )
      _acrt_free_locale(v4);
  }
  *((_QWORD *)a1 + 18) = a2;
  if ( a2 )
    _acrt_add_locale_ref(a2);
}

