// sub_1801561B0 @ 0x1801561B0 (RVA 0x1561B0)  float_ops=58

__int64 __fastcall sub_1801561B0(__int64 a1, __int64 a2, float *a3, __int64 a4, int a5)
{
  int v6; // ecx
  float v7; // xmm10_4
  float v8; // xmm9_4
  __m128 v10; // xmm11
  __m128 v11; // xmm12
  float v12; // xmm11_4
  float v13; // xmm6_4
  float v14; // xmm7_4
  double v15; // xmm3_8
  float v16; // xmm14_4
  float v17; // xmm13_4
  __m128 v18; // xmm8
  float v19; // xmm5_4
  float v20; // xmm3_4
  float v21; // xmm7_4
  float v22; // xmm0_4
  float v23; // xmm4_4
  float v24; // xmm1_4
  float *v25; // rax
  double v26; // xmm5_8
  float v27; // xmm0_4
  float v28; // xmm2_4
  int v29; // ecx
  double v30; // rax
  float v31; // xmm0_4
  double v32; // xmm4_8
  double v33; // xmm3_8
  double v34; // xmm1_8
  double v35; // xmm4_8
  float v37[4]; // [rsp+20h] [rbp-A8h] BYREF
  double v38; // [rsp+D0h] [rbp+8h] BYREF

  v6 = a5;
  *(_QWORD *)a1 = a4;
  *(_DWORD *)(a1 + 8) = v6;
  v7 = *(float *)(a2 + 8);
  v8 = *(float *)(a2 + 12);
  v38 = *(double *)a2;
  if ( a3[1] == 0.0 && a3[2] == 0.0 && a3[3] == 0.0 && a3[5] == 0.0 && *a3 == 1.0 && a3[4] == 1.0 )
  {
    v10.m128_i32[0] = HIDWORD(v38);
    v11.m128_i32[0] = LODWORD(v38);
  }
  else
  {
    v12 = *(float *)&v38;
    v13 = *((float *)&v38 + 1) - v8;
    v14 = *(float *)&v38 - v7;
    v15 = sub_180700284();
    if ( v15 > 0.0 )
    {
      v16 = (float)((float)((float)(v14 * 0.0) - (float)(v13 * 100.0)) / v15) + v7;
      v17 = (float)((float)((float)(v13 * 0.0) + (float)(v14 * 100.0)) / v15) + v8;
    }
    else
    {
      v16 = v7;
      v17 = v8;
    }
    v18 = (__m128)*(unsigned int *)a3;
    v11 = v18;
    v19 = a3[2];
    v20 = a3[5];
    v21 = a3[3];
    v11.m128_f32[0] = v18.m128_f32[0] * v12;
    v10 = (__m128)LODWORD(v21);
    v11.m128_f32[0] = (float)(v11.m128_f32[0] + (float)(a3[1] * *((float *)&v38 + 1))) + v19;
    v22 = a3[1];
    v10.m128_f32[0] = (float)((float)(v21 * *(float *)&v38) + (float)(a3[4] * *((float *)&v38 + 1))) + v20;
    v23 = a3[4] * v17;
    v24 = (float)((float)(v21 * v7) + (float)(a3[4] * v8)) + v20;
    v37[0] = (float)((float)(*a3 * v7) + (float)(v22 * v8)) + v19;
    v37[2] = (float)((float)(v18.m128_f32[0] * v16) + (float)(v22 * v17)) + v19;
    v37[1] = v24;
    v37[3] = (float)((float)(v21 * v16) + v23) + v20;
    v25 = (float *)sub_180169E70(v37, &v38, _mm_unpacklo_ps(v11, v10).m128_u64[0]);
    v6 = *(_DWORD *)(a1 + 8);
    v7 = *v25;
    v8 = v25[1];
  }
  v26 = (float)(v11.m128_f32[0] - v7);
  v27 = fabs(v26);
  *(_BYTE *)(a1 + 40) = v27 < 0.001;
  v28 = fabs((float)(v10.m128_f32[0] - v8));
  v29 = v6 << 12;
  *(_BYTE *)(a1 + 41) = v28 < 0.001;
  if ( v27 >= 0.001 )
  {
    v32 = (double)v29;
    if ( v28 >= 0.001 )
    {
      v33 = (float)(v8 - v10.m128_f32[0]) / v26;
      v34 = v10.m128_f32[0] - v11.m128_f32[0] / v33;
      *(double *)(a1 + 32) = v34;
      v35 = v32 / (v33 * v34 - (v8 * v33 - v7)) + 6.755399441055744e15;
      v38 = v35;
      *(_DWORD *)(a1 + 20) = LODWORD(v35);
      *(double *)(a1 + 24) = (double)SLODWORD(v35) * v33;
      return a1;
    }
    v38 = v32 / (float)(v7 - v11.m128_f32[0]) + 6.755399441055744e15;
    v30 = v38;
    v31 = (float)SLODWORD(v38) * v11.m128_f32[0];
  }
  else
  {
    v38 = (double)v29 / (float)(v8 - v10.m128_f32[0]) + 6.755399441055744e15;
    v30 = v38;
    v31 = (float)SLODWORD(v38) * v10.m128_f32[0];
  }
  *(_DWORD *)(a1 + 20) = LODWORD(v30);
  v38 = v31 + 6.755399441055744e15;
  *(_DWORD *)(a1 + 16) = LODWORD(v38);
  return a1;
}

