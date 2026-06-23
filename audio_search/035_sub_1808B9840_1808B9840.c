// sub_1808B9840 @ 0x1808B9840 (RVA 0x8B9840)  float_ops=50

float *__fastcall sub_1808B9840(__int64 a1, float *a2)
{
  __int64 v3; // rsi
  _QWORD *v4; // rdi
  __int64 v5; // r14
  __int64 v6; // rax
  __int64 v7; // rcx
  __m128 *v8; // rax
  unsigned __int64 v9; // xmm11_8
  float *v10; // rax
  float v11; // xmm8_4
  float v12; // xmm2_4
  float v13; // xmm4_4
  float v14; // xmm5_4
  float v15; // xmm9_4
  float v16; // xmm7_4
  float v17; // xmm6_4
  float v18; // xmm1_4
  float v19; // xmm3_4
  float v20; // xmm0_4
  float v21; // xmm6_4
  float v22; // xmm14_4
  float v23; // xmm8_4
  float v24; // xmm13_4
  __m128 v25; // xmm10
  float v26; // xmm1_4
  float v27; // xmm14_4
  float v28; // xmm15_4
  float v29; // xmm4_4
  float v30; // xmm5_4
  __m128 v31; // xmm0
  float v32; // xmm11_4
  float v33; // xmm0_4
  float v34; // xmm10_4
  float v35; // xmm10_4
  float v36; // xmm1_4
  float v37; // xmm1_4
  float v38; // xmm11_4
  float v39; // xmm10_4
  __m128 v40; // xmm0
  __m128 v41; // xmm0
  __m128 *v42; // rax
  __m128 v43; // xmm0
  float v44; // xmm6_4
  float v45; // xmm8_4
  float v46; // xmm9_4
  float v47; // xmm4_4
  __int128 v49; // [rsp+38h] [rbp-D0h]
  __m128 v50; // [rsp+48h] [rbp-C0h]
  __m128 v51; // [rsp+58h] [rbp-B0h] BYREF
  char v52[16]; // [rsp+68h] [rbp-A0h] BYREF
  char v53[32]; // [rsp+78h] [rbp-90h] BYREF
  unsigned __int64 v54; // [rsp+98h] [rbp-70h]

  *(_QWORD *)a2 = 0;
  v3 = 0;
  *((_QWORD *)a2 + 1) = 0;
  v4 = *(_QWORD **)(a1 + 64);
  v5 = *(int *)(a1 + 76) & 0x1FFFFFFFFFFFFFFFLL;
  if ( v4 > &v4[*(int *)(a1 + 76)] )
    v5 = 0;
  if ( v5 )
  {
    do
    {
      v6 = _RTDynamicCast(*v4, 0, &juce::Component `RTTI Type Descriptor', &juce::Drawable `RTTI Type Descriptor', 0);
      v7 = v6;
      if ( v6 )
      {
        v8 = *(__m128 **)(v6 + 56);
        if ( v8 )
        {
          v25 = *v8;
          v9 = v8[1].m128_u64[0];
          v10 = (float *)(*(__int64 (__fastcall **)(__int64, char *))(*(_QWORD *)v7 + 360LL))(v7, v52);
          v54 = v9;
          v11 = _mm_shuffle_ps(v25, v25, 85).m128_f32[0];
          v12 = v10[1];
          v13 = *v10 + v10[2];
          v14 = v25.m128_f32[0] * *v10;
          v15 = v12 + v10[3];
          v16 = _mm_shuffle_ps(v25, v25, 170).m128_f32[0];
          v17 = _mm_shuffle_ps(v25, v25, 255).m128_f32[0];
          v25.m128_f32[0] = v25.m128_f32[0] * v13;
          v18 = v11 * v12;
          v19 = v17 * *v10;
          v20 = *(float *)&v9 * v12;
          v21 = v17 * v13;
          v22 = (float)(v11 * v12) + v14;
          *(float *)&v9 = *(float *)&v9 * v15;
          v23 = v11 * v15;
          v24 = (float)(v25.m128_f32[0] + v18) + v16;
          v25.m128_f32[0] = (float)(v25.m128_f32[0] + v23) + v16;
          v26 = (float)(v23 + v14) + v16;
          v27 = v22 + v16;
          v28 = (float)(v20 + v19) + *((float *)&v9 + 1);
          v29 = (float)(v21 + v20) + *((float *)&v9 + 1);
          v30 = (float)(*(float *)&v9 + v19) + *((float *)&v9 + 1);
          v31 = v25;
          v32 = (float)(*(float *)&v9 + v21) + *((float *)&v9 + 1);
          if ( v24 <= v26 )
            v33 = fminf(v25.m128_f32[0], v24);
          else
            v33 = fminf(v25.m128_f32[0], v26);
          v31.m128_f32[0] = fminf(v33, v27);
          if ( v26 <= v24 )
            v34 = fmaxf(v25.m128_f32[0], v24);
          else
            v34 = fmaxf(v25.m128_f32[0], v26);
          v35 = fmaxf(v34, v27);
          if ( v29 <= v30 )
            v36 = fminf(v32, v29);
          else
            v36 = fminf(v32, v30);
          v37 = fminf(v36, v28);
          if ( v30 <= v29 )
            v38 = fmaxf(v32, v29);
          else
            v38 = fmaxf(v32, v30);
          v39 = v35 - v31.m128_f32[0];
          v40 = _mm_shuffle_ps(v31, v31, 225);
          v40.m128_f32[0] = v37;
          v41 = _mm_shuffle_ps(v40, v40, 198);
          v42 = &v51;
          v41.m128_f32[0] = v39;
          v43 = _mm_shuffle_ps(v41, v41, 39);
          v43.m128_f32[0] = fmaxf(v38, v28) - v37;
          v51 = _mm_shuffle_ps(v43, v43, 57);
        }
        else
        {
          v42 = (__m128 *)(*(__int64 (__fastcall **)(__int64, char *))(*(_QWORD *)v7 + 360LL))(v7, v53);
        }
        v50 = *v42;
        v44 = _mm_shuffle_ps(v50, v50, 170).m128_f32[0];
        if ( v44 <= 0.0 || v50.m128_f32[3] <= 0.0 )
        {
          v49 = *(_OWORD *)a2;
        }
        else
        {
          v45 = a2[2];
          if ( v45 <= 0.0 || (v46 = a2[3], v46 <= 0.0) )
          {
            *(_QWORD *)&v49 = v50.m128_u64[0];
            *((_QWORD *)&v49 + 1) = __PAIR64__(v50.m128_u32[3], LODWORD(v44));
          }
          else
          {
            v47 = a2[1];
            *(_QWORD *)&v49 = __PAIR64__(
                                COERCE_UNSIGNED_INT(fminf(v50.m128_f32[1], v47)),
                                COERCE_UNSIGNED_INT(fminf(v50.m128_f32[0], *a2)));
            *((float *)&v49 + 2) = fmaxf(v50.m128_f32[0] + v44, *a2 + v45) - *(float *)&v49;
            *((float *)&v49 + 3) = fmaxf(v50.m128_f32[1] + v50.m128_f32[3], v47 + v46) - *((float *)&v49 + 1);
          }
        }
        *(_OWORD *)a2 = v49;
      }
      ++v4;
      ++v3;
    }
    while ( v3 != v5 );
  }
  return a2;
}

