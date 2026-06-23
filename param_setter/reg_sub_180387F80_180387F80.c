// sub_180387F80 @ 0x180387F80 (RVA 0x387F80)

__int64 __fastcall sub_180387F80(const __m128i **a1, const __m128i *a2, __m128i *a3)
{
  const __m128i *v6; // r10
  __int64 v7; // r12
  signed __int64 v8; // rcx
  unsigned __int64 v9; // r14
  unsigned __int64 v10; // rdx
  unsigned __int64 v11; // rax
  __int64 v12; // rbx
  __m128i *v13; // rsi
  __int64 v14; // r12
  const __m128i *v15; // r8
  const __m128i *v16; // rdx
  __m128i *v17; // rcx
  unsigned __int64 v18; // r8

  v6 = *a1;
  v7 = ((char *)a2 - (char *)*a1) / 40;
  v8 = (char *)a1[1] - (char *)*a1;
  if ( v8 / 40 == 0x666666666666666LL )
    std::vector<void *>::_Xlen(v8);
  v9 = v8 / 40 + 1;
  v10 = ((char *)a1[2] - (char *)v6) / 40;
  v11 = v10 >> 1;
  if ( v10 <= 0x666666666666666LL - (v10 >> 1) )
  {
    v12 = v11 + v10;
    if ( v11 + v10 < v9 )
      v12 = v8 / 40 + 1;
  }
  else
  {
    v12 = v8 / 40 + 1;
  }
  v13 = (__m128i *)sub_1803AB860(a1, v12);
  v14 = 40 * v7;
  *(__m128i *)((char *)v13 + v14) = *a3;
  *(__m128i *)((char *)v13 + v14 + 16) = a3[1];
  v13[2].m128i_i64[(unsigned __int64)v14 / 8] = a3[2].m128i_i64[0];
  v15 = a1[1];
  v16 = *a1;
  v17 = v13;
  if ( a2 == v15 )
  {
    v18 = (char *)v15 - (char *)v16;
  }
  else
  {
    sub_1806ADC00(v13, v16, (char *)a2 - (char *)v16);
    v17 = (__m128i *)((char *)v13 + v14 + 40);
    v18 = (char *)a1[1] - (char *)a2;
    v16 = a2;
  }
  sub_1806ADC00(v17, v16, v18);
  sub_1803AB580(a1, v13, v9, v12, -2);
  return (__int64)*a1 + v14;
}

