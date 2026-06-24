// sub_7FF91DF5B610 @ rva 0x2FB610

__int64 __fastcall sub_7FF91DF5B610(__int64 a1)
{
  __int128 v3; // [rsp+20h] [rbp-28h]
  const char *v4; // [rsp+30h] [rbp-18h] BYREF
  char v5; // [rsp+38h] [rbp-10h]

  LODWORD(v3) = 11;
  BYTE4(v3) = 1;
  *((_QWORD *)&v3 + 1) = &off_7FF91E5A8050;
  v5 = 1;
  *(_QWORD *)a1 = &std::exception::`vftable';
  *(_QWORD *)(a1 + 8) = 0;
  *(_QWORD *)(a1 + 16) = 0;
  v4 = "boost::thread_resource_error";
  _std_exception_copy(&v4);
  *(_OWORD *)(a1 + 24) = v3;
  *(_QWORD *)(a1 + 56) = 0;
  *(_QWORD *)(a1 + 64) = 15;
  *(_BYTE *)(a1 + 40) = 0;
  *(_QWORD *)a1 = &boost::thread_resource_error::`vftable';
  return a1;
}

