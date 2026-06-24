// sub_7FF91E0224A0 @ rva 0x3C24A0

void __fastcall sub_7FF91E0224A0(_QWORD *a1)
{
  int *v1; // rbx
  int *v3; // rsi

  v1 = (int *)a1[14];
  if ( v1 != (int *)a1[15] )
  {
    v3 = v1 + 1;
    do
    {
      if ( sub_7FF91E022E00(a1[11] + 40LL * *v1) )
      {
        ++v1;
        ++v3;
      }
      else
      {
        sub_7FF91E30DC00(v1, v3, a1[15] - (_QWORD)v3);
        a1[15] -= 4LL;
      }
    }
    while ( v1 != (int *)a1[15] );
  }
}

