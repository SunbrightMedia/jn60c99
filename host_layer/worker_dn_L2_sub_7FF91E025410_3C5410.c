// sub_7FF91E025410 @ rva 0x3C5410

// Hidden C++ exception states: #wind=6
_QWORD *__fastcall sub_7FF91E025410(_QWORD *a1, __int64 a2)
{
  __int64 v4; // rcx
  char v5; // al
  __int64 v6; // rcx
  void *v7; // rcx
  void **v9; // [rsp+48h] [rbp-49h] BYREF
  _QWORD v10[2]; // [rsp+50h] [rbp-41h] BYREF
  __int128 v11; // [rsp+60h] [rbp-31h]
  _QWORD v12[3]; // [rsp+70h] [rbp-21h] BYREF
  unsigned __int64 v13; // [rsp+88h] [rbp-9h]
  void **v14; // [rsp+90h] [rbp-1h] BYREF
  __int128 v15; // [rsp+98h] [rbp+7h]
  __int64 v16; // [rsp+A8h] [rbp+17h]
  int v17; // [rsp+B0h] [rbp+1Fh]

  v10[0] = 0;
  v10[1] = 0;
  _std_exception_copy(a2 + 8);
  v9 = &boost::system::system_error::`vftable';
  v11 = *(_OWORD *)(a2 + 24);
  sub_7FF91DD17B50(v12, a2 + 40);
  v15 = 0;
  v16 = 0;
  v17 = -1;
  v9 = &boost::exception_detail::error_info_injector<boost::lock_error>::`vftable';
  v14 = &boost::exception_detail::error_info_injector<boost::lock_error>::`vftable';
  a1[14] = &unk_7FF91E63F440;
  a1[16] = &boost::exception_detail::clone_base::`vftable';
  sub_7FF91E025780(a1, &v9);
  *a1 = &boost::exception_detail::clone_impl<boost::exception_detail::error_info_injector<boost::lock_error>>::`vftable';
  a1[9] = &boost::exception_detail::clone_impl<boost::exception_detail::error_info_injector<boost::lock_error>>::`vftable';
  *(_QWORD *)((char *)a1 + *(int *)(a1[14] + 4LL) + 112) = &boost::exception_detail::clone_impl<boost::exception_detail::error_info_injector<boost::lock_error>>::`vftable';
  *(_DWORD *)((char *)a1 + *(int *)(a1[14] + 4LL) + 108) = *(_DWORD *)(a1[14] + 4LL) - 16;
  sub_7FF91DF63FD0(a1 + 9, &v14);
  *a1 = &boost::wrapexcept<boost::lock_error>::`vftable';
  a1[9] = &boost::wrapexcept<boost::lock_error>::`vftable';
  *(_QWORD *)((char *)a1 + *(int *)(a1[14] + 4LL) + 112) = &boost::wrapexcept<boost::lock_error>::`vftable';
  v4 = *(int *)(a1[14] + 4LL);
  *(_DWORD *)((char *)a1 + v4 + 108) = v4 - 16;
  v9 = &boost::exception_detail::error_info_injector<boost::lock_error>::`vftable';
  v14 = &boost::exception::`vftable';
  if ( (_QWORD)v15 )
  {
    v5 = (*(__int64 (__fastcall **)(_QWORD))(*(_QWORD *)v15 + 32LL))(v15);
    v6 = v15;
    if ( v5 )
      v6 = 0;
    *(_QWORD *)&v15 = v6;
  }
  v9 = &boost::system::system_error::`vftable';
  if ( v13 >= 0x10 )
  {
    v7 = (void *)v12[0];
    if ( v13 + 1 >= 0x1000 )
    {
      v7 = *(void **)(v12[0] - 8LL);
      if ( (unsigned __int64)(v12[0] - (_QWORD)v7 - 8LL) > 0x1F )
        invalid_parameter_noinfo_noreturn();
    }
    j_j_free(v7);
  }
  v12[2] = 0;
  v13 = 15;
  LOBYTE(v12[0]) = 0;
  v9 = &std::exception::`vftable';
  _std_exception_destroy(v10);
  return a1;
}

