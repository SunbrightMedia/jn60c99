// sub_1808466F0 @ 0x1808466F0 (RVA 0x8466F0)  float_ops=46

__int64 __fastcall sub_1808466F0(__int64 a1, _OWORD *a2, int *a3)
{
  int v5; // eax
  __int64 v6; // rdx
  int v7; // esi
  int v8; // r12d
  int v9; // r10d
  unsigned int v10; // ebx
  int v11; // r8d
  __m128i v12; // xmm3
  float v13; // xmm7_4
  unsigned int v14; // r9d
  __m128i v15; // xmm11
  float v16; // xmm6_4
  int v17; // eax
  __m128 v18; // xmm5
  float v19; // xmm0_4
  float v20; // xmm8_4
  float v21; // xmm2_4
  float v22; // xmm3_4
  float v23; // xmm11_4
  __int64 v24; // r14
  int v25; // ecx
  int v26; // edx
  __m128i v27; // xmm10
  int v28; // eax
  int v29; // r8d
  bool v30; // zf
  int v31; // r9d
  float *v32; // rdi
  int v33; // ecx
  unsigned int v34; // eax
  float v35; // xmm9_4
  __m128 v36; // xmm4
  __m128 v37; // xmm1
  float v38; // xmm3_4
  __m128i v39; // xmm0
  float *v40; // rbx
  __m128i v41; // xmm7
  int v42; // eax
  int v43; // eax
  __m128 v44; // xmm7
  __m128 v45; // xmm6
  __m128 v46; // xmm15
  float v47; // xmm13_4
  float v48; // xmm11_4
  float v49; // xmm2_4
  float v50; // xmm1_4
  float v51; // xmm14_4
  float v52; // xmm10_4
  float v53; // xmm5_4
  float v54; // xmm4_4
  float v55; // xmm2_4
  float v56; // xmm1_4
  float v57; // xmm8_4
  float v58; // xmm8_4
  float v59; // xmm3_4
  float v60; // xmm9_4
  float v61; // xmm8_4
  float v62; // xmm9_4
  float v63; // xmm12_4
  __m128 v64; // xmm10
  int v65; // edx
  int v66; // ecx
  __m128 v67; // xmm11
  int v68; // edx
  int v69; // ecx
  int v70; // edx
  int v71; // ecx
  float v73; // [rsp+30h] [rbp-D0h]
  _BYTE v74[8]; // [rsp+38h] [rbp-C8h] BYREF
  __int64 v75; // [rsp+40h] [rbp-C0h]
  int v76; // [rsp+48h] [rbp-B8h]
  int v77; // [rsp+4Ch] [rbp-B4h]
  float v78[7]; // [rsp+50h] [rbp-B0h] BYREF
  float v79; // [rsp+6Ch] [rbp-94h]
  float v80; // [rsp+70h] [rbp-90h]
  __int32 v81; // [rsp+74h] [rbp-8Ch]
  unsigned __int64 v82; // [rsp+78h] [rbp-88h] BYREF
  float v83; // [rsp+80h] [rbp-80h]
  float v84; // [rsp+84h] [rbp-7Ch]
  float v85; // [rsp+88h] [rbp-78h]
  float v86; // [rsp+8Ch] [rbp-74h]
  float v87; // [rsp+90h] [rbp-70h]
  float v88; // [rsp+94h] [rbp-6Ch]
  float v89; // [rsp+98h] [rbp-68h]
  float v90; // [rsp+9Ch] [rbp-64h]
  float v91; // [rsp+A0h] [rbp-60h]
  float v92; // [rsp+A4h] [rbp-5Ch]
  __int32 v93; // [rsp+A8h] [rbp-58h]
  float v94; // [rsp+ACh] [rbp-54h]
  float v95; // [rsp+190h] [rbp+90h]
  float v96; // [rsp+198h] [rbp+98h]
  float v97; // [rsp+1A0h] [rbp+A0h]
  float v98; // [rsp+1A8h] [rbp+A8h]

  *(_OWORD *)(a1 + 272) = *a2;
  *(_OWORD *)(a1 + 256) = *(_OWORD *)a3;
  v5 = sub_180846F60();
  v6 = *(_QWORD *)(a1 + 200);
  v7 = 0;
  v75 = 0;
  v8 = 2 * v5 + *(_DWORD *)(v6 + 40);
  v9 = *(_DWORD *)(a1 + 272);
  v77 = 2 * v5 + *(_DWORD *)(v6 + 44);
  v76 = v8;
  v10 = v8 / 2;
  v11 = *(_DWORD *)(a1 + 280);
  v12 = _mm_cvtsi32_si128(v8 / 2 - 2 * v5);
  v13 = (float)v5 - *(float *)(a1 + 296);
  v14 = *(_DWORD *)(a1 + 276);
  v15 = _mm_cvtsi32_si128(v77 / 2 - 2 * v5);
  v16 = (float)v9;
  v17 = *(_DWORD *)(a1 + 284);
  v18 = (__m128)COERCE_UNSIGNED_INT((float)(v9 + v11 / 2));
  v78[4] = (float)v9;
  v19 = (float)(int)(v14 + v17);
  v20 = (float)(int)(v14 + v17 / 2);
  v21 = (float)(v9 + v11);
  v78[3] = v20;
  v78[5] = v20;
  v78[0] = (float)(v9 + v11 / 2);
  v78[1] = v19;
  v78[2] = v21;
  v78[6] = v78[0];
  v22 = _mm_cvtepi32_ps(v12).m128_f32[0];
  v23 = _mm_cvtepi32_ps(v15).m128_f32[0];
  v24 = 4;
  v25 = a3[2] - 2 * (v8 / 2);
  v26 = a3[3] - 2 * (v77 / 2);
  v27 = _mm_cvtsi32_si128(v14);
  v28 = *a3;
  v29 = v77 / 2 + a3[1];
  v30 = a3[2] == 2 * (v8 / 2);
  v31 = 0;
  v32 = v78;
  if ( v25 >= 0 && !v30 )
    v31 = v25;
  v33 = 0;
  if ( v26 > 0 )
    v33 = v26;
  v34 = v10 + v28;
  v35 = v18.m128_f32[0];
  v96 = 1000000000.0;
  v36 = (__m128)COERCE_UNSIGNED_INT((float)(v77 / 2));
  v73 = (float)(v77 / 2);
  v36.m128_f32[0] = v73 - v13;
  v18.m128_f32[0] = v18.m128_f32[0] + v22;
  v37 = v36;
  v93 = v18.m128_i32[0];
  v37.m128_f32[0] = (float)(v73 - v13) + v19;
  v79 = _mm_cvtepi32_ps(v27).m128_f32[0];
  v80 = v35 - v22;
  v91 = v35 - v22;
  v38 = (float)v33;
  v82 = _mm_unpacklo_ps(v18, v37).m128_u64[0];
  v39 = _mm_cvtsi32_si128(v10);
  v40 = (float *)&v82;
  v81 = v37.m128_i32[0];
  v98 = _mm_cvtepi32_ps(v39).m128_f32[0];
  v37.m128_f32[0] = v98 - v13;
  v92 = v79 - (float)(v73 - v13);
  v41 = _mm_cvtsi32_si128(v34);
  v42 = *(_DWORD *)(a1 + 284);
  v94 = v79 - v36.m128_f32[0];
  v95 = (float)v33;
  v43 = *(_DWORD *)(a1 + 276) + v42 / 2;
  v87 = v16 - v37.m128_f32[0];
  v89 = v16 - v37.m128_f32[0];
  v83 = v37.m128_f32[0] + v21;
  v85 = v37.m128_f32[0] + v21;
  v97 = (float)v43;
  v84 = v20 - v23;
  v86 = v20 + v23;
  v88 = v20 - v23;
  v90 = v20 + v23;
  v44 = _mm_cvtepi32_ps(v41);
  v45 = (__m128)COERCE_UNSIGNED_INT((float)v29);
  v46 = (__m128)COERCE_UNSIGNED_INT((float)v31);
  do
  {
    v47 = *v40;
    v48 = v40[1];
    if ( v44.m128_f32[0] <= *v40 )
      v49 = fminf(v46.m128_f32[0] + v44.m128_f32[0], v47);
    else
      v49 = v44.m128_f32[0];
    if ( v45.m128_f32[0] <= v48 )
      v50 = fminf(v38 + v45.m128_f32[0], v48);
    else
      v50 = v45.m128_f32[0];
    v51 = *(v40 - 2);
    v52 = *(v40 - 1);
    if ( v44.m128_f32[0] <= v51 )
      v53 = fminf(v46.m128_f32[0] + v44.m128_f32[0], v51);
    else
      v53 = v44.m128_f32[0];
    if ( v45.m128_f32[0] <= v52 )
      v54 = fminf(v38 + v45.m128_f32[0], v52);
    else
      v54 = v45.m128_f32[0];
    v55 = v49 - v53;
    v56 = v50 - v54;
    v57 = (float)(v56 * v56) + (float)(v55 * v55);
    if ( v57 > 0.0 )
    {
      v59 = (float)((float)((float)(v97 - v54) * v56) + (float)((float)(v78[0] - v53) * v55)) / v57;
      if ( v59 >= 0.0 )
        v58 = fminf(1.0, v59);
      else
        v58 = 0.0;
    }
    else
    {
      v58 = 0.0;
    }
    v60 = v58;
    v61 = (float)(v58 * v56) + v54;
    v62 = (float)(v60 * v55) + v53;
    v38 = v95;
    v63 = hypotf(v62 - *v32, v61 - v32[1]);
    if ( (v51 < v44.m128_f32[0]
       || v52 < v45.m128_f32[0]
       || (float)(v46.m128_f32[0] + v44.m128_f32[0]) <= v51
       || (float)(v95 + v45.m128_f32[0]) <= v52)
      && (v47 < v44.m128_f32[0]
       || v48 < v45.m128_f32[0]
       || (float)(v46.m128_f32[0] + v44.m128_f32[0]) <= v47
       || (float)(v95 + v45.m128_f32[0]) <= v48) )
    {
      v64 = v46;
      v64.m128_f32[0] = v46.m128_f32[0] + v44.m128_f32[0];
      if ( (unsigned __int8)sub_180171D60(
                              *((_QWORD *)v40 - 1),
                              *(_QWORD *)v40,
                              _mm_unpacklo_ps(v44, v45).m128_u32[0],
                              _mm_unpacklo_ps(v64, v45).m128_u32[0],
                              (__int64)v74)
        || (v67 = (__m128)LODWORD(v95),
            v67.m128_f32[0] = v95 + v45.m128_f32[0],
            (unsigned __int8)sub_180171D60(
                               v66,
                               v65,
                               _mm_unpacklo_ps(v64, v45).m128_u32[0],
                               _mm_unpacklo_ps(v64, v67).m128_u32[0],
                               (__int64)v74))
        || (unsigned __int8)sub_180171D60(
                              v69,
                              v68,
                              _mm_unpacklo_ps(v64, v67).m128_u32[0],
                              _mm_unpacklo_ps(v44, v67).m128_u32[0],
                              (__int64)v74) )
      {
        v38 = v95;
      }
      else
      {
        v38 = v95;
        if ( !(unsigned __int8)sub_180171D60(
                                 v71,
                                 v70,
                                 _mm_unpacklo_ps(v44, v67).m128_u32[0],
                                 _mm_unpacklo_ps(v44, v45).m128_u32[0],
                                 (__int64)v74) )
          v63 = v63 + 1000.0;
      }
    }
    if ( v96 > v63 )
    {
      v96 = v63;
      *(_QWORD *)(a1 + 248) = *(_QWORD *)v32;
      v7 = (int)(float)(v62 - v98);
      HIDWORD(v75) = (int)(float)(v61 - v73);
    }
    v40 += 4;
    v32 += 2;
    --v24;
  }
  while ( v24 );
  LODWORD(v75) = v7;
  return sub_1808D7910(a1, v7, HIDWORD(v75), v8, v77);
}

