// sub_1803AB700 @ 0x1803AB700 (RVA 0x3AB700)

__int64 __fastcall sub_1803AB700(__int64 a1, unsigned __int64 a2)
{
  __int64 v4; // rdi
  __m128i *v5; // rsi

  v4 = (*(_QWORD *)(a1 + 8) - *(_QWORD *)a1) / 40LL;
  v5 = (__m128i *)sub_1803AB860(a1, a2);
  sub_1806ADC00(v5, *(const __m128i **)a1, *(_QWORD *)(a1 + 8) - *(_QWORD *)a1);
  return sub_1803AB580(a1, (__int64)v5, v4, a2);
}

