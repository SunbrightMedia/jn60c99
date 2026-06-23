// sub_1803AB580 @ 0x1803AB580 (RVA 0x3AB580)

__int64 __fastcall sub_1803AB580(__int64 a1, __int64 a2, __int64 a3, __int64 a4)
{
  _QWORD *v6; // rcx

  v6 = *(_QWORD **)a1;
  if ( v6 )
  {
    if ( (unsigned __int64)(40 * ((*(_QWORD *)(a1 + 16) - (_QWORD)v6) / 40LL)) >= 0x1000 )
    {
      if ( (unsigned __int64)v6 - *(v6 - 1) - 8 > 0x1F )
        invalid_parameter_noinfo_noreturn();
      v6 = (_QWORD *)*(v6 - 1);
    }
    j_j_free(v6);
  }
  *(_QWORD *)a1 = a2;
  *(_QWORD *)(a1 + 8) = a2 + 40 * a3;
  *(_QWORD *)(a1 + 16) = a2 + 40 * a4;
  return 5 * a4;
}

