// sub_18015A9C0 @ 0x18015A9C0 (RVA 0x15A9C0)  float_ops=51

void __fastcall sub_18015A9C0(float *a1, float a2, __int64 a3)
{
  float v5; // xmm7_4
  float v7; // xmm11_4
  float v8; // xmm12_4
  float v9; // xmm10_4
  float v10; // xmm9_4
  float v11; // xmm2_4
  float v12; // xmm3_4
  float v13; // xmm1_4
  float v14; // xmm3_4
  __m128 v15; // xmm0
  __m128 v16; // xmm0
  __m128 v17; // xmm0
  void *v18; // rdi
  int v19; // edx
  int v20; // r8d
  int v21; // r9d
  __int32 v22; // r10d
  char v23; // r11
  __int64 v24; // rcx
  _DWORD *v25; // rdx
  float v26; // xmm3_4
  float v27; // xmm0_4
  float v28; // xmm1_4
  float v29; // xmm0_4
  float v30; // xmm3_4
  __int128 v31; // xmm0
  __m128 v32; // [rsp+48h] [rbp-C0h] BYREF
  __int128 v33; // [rsp+58h] [rbp-B0h]
  int v34; // [rsp+68h] [rbp-A0h]
  int v35; // [rsp+70h] [rbp-98h] BYREF
  __int128 v36; // [rsp+74h] [rbp-94h]
  __int64 v37; // [rsp+84h] [rbp-84h]
  __int64 v38; // [rsp+90h] [rbp-78h]
  void *v39; // [rsp+98h] [rbp-70h]

  v5 = a1[8];
  if ( *a1 == a2 )
  {
    v7 = a1[6];
  }
  else
  {
    v7 = a1[6];
    v8 = a1[7];
    *a1 = a2;
    v32.m128_f32[0] = v8;
    v9 = floorf((float)(v5 * a2) + 0.5) / a2;
    v10 = floorf((float)(v8 * a2) + 0.30000001) / a2;
    v11 = 0.89999998;
    v12 = (float)(v10 - (float)(floorf((float)(v7 * a2) + 0.5) / a2)) / (float)(v8 - v7);
    if ( v12 >= 0.89999998 )
      v13 = fminf(1.1, v12);
    else
      v13 = 0.89999998;
    v32.m128_f32[1] = v13;
    v14 = (float)(v9 - v10) / (float)(v5 - v8);
    if ( v14 >= 0.89999998 )
      v11 = fminf(1.1, v14);
    v15 = _mm_shuffle_ps(v32, v32, 147);
    v15.m128_f32[0] = v11;
    *(float *)&v33 = v9 - (float)(v11 * v5);
    v16 = _mm_shuffle_ps(v15, v15, 39);
    v16.m128_f32[0] = v10 - (float)(v13 * v8);
    v17 = _mm_shuffle_ps(v16, v16, 201);
    *(__m128 *)(a1 + 1) = v17;
    a1[5] = v9 - (float)(v11 * v5);
    v32 = v17;
  }
  if ( (float)((float)(3.0 / a2) + v7) > v5 )
    return;
  v18 = *(void **)a3;
  v32 = 0u;
  v37 = 0;
  v33 = 0;
  LOBYTE(v34) = 1;
  v35 = 0;
  v36 = 0;
  v38 = a3;
  v39 = v18;
  if ( !(unsigned __int8)sub_180825C10(&v35) )
    goto LABEL_49;
  do
  {
    switch ( v35 )
    {
      case 0:
        if ( a1[1] <= *((float *)&v36 + 1) )
          v30 = (float)(*((float *)&v36 + 1) * a1[4]) + a1[5];
        else
          v30 = (float)(*((float *)&v36 + 1) * a1[2]) + a1[3];
        if ( !v21 )
        {
          *(_QWORD *)((char *)&v33 + 4) = __PAIR64__(LODWORD(v30), v36);
          LODWORD(v33) = v36;
LABEL_45:
          *((float *)&v33 + 3) = v30;
          goto LABEL_46;
        }
        if ( *(float *)&v33 <= *(float *)&v36 )
        {
          if ( *(float *)&v36 > *((float *)&v33 + 1) )
            DWORD1(v33) = v36;
        }
        else
        {
          LODWORD(v33) = v36;
        }
        if ( *((float *)&v33 + 2) <= v30 )
        {
          if ( v30 > *((float *)&v33 + 3) )
            goto LABEL_45;
        }
        else
        {
          *((float *)&v33 + 2) = v30;
        }
LABEL_46:
        sub_180179780(&v32, &unk_180AA33E4);
        break;
      case 1:
        sub_18082B140(&v32);
        break;
      case 2:
        if ( a1[1] <= *((float *)&v36 + 3) )
          v29 = (float)(*((float *)&v36 + 3) * a1[4]) + a1[5];
        else
          v29 = (float)(*((float *)&v36 + 3) * a1[2]) + a1[3];
        sub_18082B050((unsigned int)&v32, v19, v20, v21, LODWORD(v29));
        break;
      case 3:
        v26 = a1[1];
        if ( v26 <= *((float *)&v37 + 1) )
          v27 = (float)(*((float *)&v37 + 1) * a1[4]) + a1[5];
        else
          v27 = (float)(*((float *)&v37 + 1) * a1[2]) + a1[3];
        if ( v26 <= *((float *)&v36 + 3) )
          v28 = (float)(*((float *)&v36 + 3) * a1[4]) + a1[5];
        else
          v28 = (float)(*((float *)&v36 + 3) * a1[2]) + a1[3];
        sub_18082AED0((unsigned int)&v32, v19, v20, v21, LODWORD(v28), v37, LODWORD(v27));
        break;
      default:
        if ( v35 == 4 && v21 && (v21 <= 0 || *(float *)(v32.m128_u64[0] + 4LL * (v21 - 1)) != 100005.0) )
        {
          sub_1801716F0(&v32, (unsigned int)(v21 + 1));
          v24 = v32.m128_i32[3]++;
          v25 = (_DWORD *)(v32.m128_u64[0] + 4 * v24);
          if ( v25 )
            *v25 = 1203982976;
        }
        break;
    }
  }
  while ( (unsigned __int8)sub_180825C10(&v35) );
  v18 = *(void **)a3;
  v23 = v34;
  v22 = v32.m128_i32[2];
LABEL_49:
  v31 = v33;
  *(_QWORD *)a3 = v32.m128_u64[0];
  *(_DWORD *)(a3 + 8) = v22;
  *(_DWORD *)(a3 + 12) = v21;
  *(_OWORD *)(a3 + 16) = v31;
  *(_BYTE *)(a3 + 32) = v23;
  free(v18);
}

