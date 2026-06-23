// sub_1803AB860 @ 0x1803AB860 (RVA 0x3AB860)

unsigned __int64 __fastcall sub_1803AB860(__int64 a1, unsigned __int64 a2)
{
  unsigned __int64 result; // rax
  size_t v3; // rcx
  void *v4; // rax
  void *v5; // rcx

  result = 40 * a2;
  if ( a2 > 0x666666666666666LL )
  {
    result = -1;
LABEL_4:
    v3 = result + 39;
    if ( result + 39 < result )
      v3 = -1;
    v4 = operator new(v3);
    v5 = v4;
    if ( !v4 )
      invalid_parameter_noinfo_noreturn();
    result = ((unsigned __int64)v4 + 39) & 0xFFFFFFFFFFFFFFE0uLL;
    *(_QWORD *)(result - 8) = v5;
    return result;
  }
  if ( result >= 0x1000 )
    goto LABEL_4;
  if ( result )
    return (unsigned __int64)operator new(40 * a2);
  return result;
}

