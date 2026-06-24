// sub_7FF91DF5B530 @ rva 0x2FB530

__int64 __fastcall sub_7FF91DF5B530(__int64 a1, int a2, __int64 a3)
{
  __int128 v5; // [rsp+20h] [rbp-28h]
  __int64 v6; // [rsp+30h] [rbp-18h] BYREF
  char v7; // [rsp+38h] [rbp-10h]

  LODWORD(v5) = a2;
  v6 = a3;
  v7 = 1;
  *((_QWORD *)&v5 + 1) = &off_7FF91E5A8050;
  BYTE4(v5) = a2 != 0;
  *(_QWORD *)a1 = &std::exception::`vftable';
  *(_QWORD *)(a1 + 8) = 0;
  *(_QWORD *)(a1 + 16) = 0;
  _std_exception_copy(&v6);
  *(_OWORD *)(a1 + 24) = v5;
  *(_QWORD *)(a1 + 56) = 0;
  *(_QWORD *)(a1 + 64) = 15;
  *(_BYTE *)(a1 + 40) = 0;
  *(_QWORD *)a1 = &boost::thread_exception::`vftable';
  return a1;
}

