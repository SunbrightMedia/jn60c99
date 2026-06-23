// sub_180888CD0  @ 0x180888CD0  (RVA 0x888CD0)  floats=18
// .rdata float constants referenced by this function:
//   0x180AE4F80  dword_180AE4F80 = 0.05000000074505806
//   0x180AE4F84  dword_180AE4F84 = 0.05999999865889549
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE4FC0  dword_180AE4FC0 = 0.20000000298023224
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE4FF8  dword_180AE4FF8 = 0.4000000059604645
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5030  dword_180AE5030 = 0.6000000238418579
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE51A0  dbl_180AE51A0 = 0.0
//   0x180AE5428  qword_180AE5428 = 0.0
//   0x180AE543C  dword_180AE543C = 255.0
//   0x180AE5440  dword_180AE5440 = 255.99600219726562
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5570  xmmword_180AE5570 = 1.0

// local variable allocation has failed, the output may be wrong!
void __fastcall sub_180888CD0(__int64 a1, double a2, float a3, double a4, unsigned int *a5, float a6)
{
  float v6; // xmm11_4
  __m128 v7; // xmm6
  __m128 v9; // xmm0
  __m128 v10; // xmm0
  __m128 v11; // xmm0
  unsigned int *v12; // rdi
  unsigned int v13; // r9d
  double v14; // xmm1_8
  char v15; // r8
  char v16; // dl
  int v17; // eax
  __int64 v18; // rdx
  char *v19; // r8
  _OWORD *v20; // rcx
  __m128 *v21; // rax
  unsigned int *v22; // rax
  __int64 v23; // rdx
  float *v24; // rcx
  float v25; // xmm0_4
  int v26; // ecx
  __int64 v27; // rdx
  char *v28; // r8
  __m128 *v29; // rax
  char *v30; // rax
  __m128 v31; // xmm3
  __m128 v32; // xmm3
  __m128 v33; // xmm3
  float v34; // xmm1_4
  int v35; // eax
  int v36; // eax
  __int64 v37; // rdx
  char *v38; // r8
  __m128 *v39; // rcx
  char *v40; // rax
  __int64 v41; // rdx
  float v42; // xmm0_4
  int v43; // eax
  float *v44; // rcx
  float v45; // xmm0_4
  float v46; // xmm0_4
  int v47; // eax
  __m128 v48; // xmm6
  __m128 v49; // xmm6
  __m128 v50; // xmm6
  float v51; // [rsp+20h] [rbp-E0h] BYREF
  float v52; // [rsp+24h] [rbp-DCh]
  __int32 v53; // [rsp+28h] [rbp-D8h]
  float v54; // [rsp+2Ch] [rbp-D4h]
  char v55; // [rsp+30h] [rbp-D0h]
  void *Block; // [rsp+38h] [rbp-C8h] BYREF
  __int64 v57; // [rsp+40h] [rbp-C0h]
  __m128 v58; // [rsp+48h] [rbp-B8h] BYREF
  __m128 v59; // [rsp+60h] [rbp-A0h] BYREF
  __int64 v60; // [rsp+70h] [rbp-90h]
  unsigned int v61; // [rsp+80h] [rbp-80h]
  __int128 v62; // [rsp+88h] [rbp-78h]
  void *v63; // [rsp+98h] [rbp-68h] BYREF
  __int64 v64; // [rsp+A0h] [rbp-60h]
  __int128 v65; // [rsp+A8h] [rbp-58h]
  char v66; // [rsp+B8h] [rbp-48h]
  __int64 v67; // [rsp+C0h] [rbp-40h]
  unsigned int v68; // [rsp+1A8h] [rbp+A8h] BYREF

  v67 = -2;
  v6 = *(float *)&a4;
  v7 = *(__m128 *)&a2;
  if ( a6 < *(float *)&a4 )
  {
    v63 = nullptr;
    v64 = 0;
    v65 = 0;
    v66 = 1;
    v9 = _mm_shuffle_ps(*(__m128 *)&a2, *(__m128 *)&a2, 225);
    v9.m128_f32[0] = a3;
    v10 = _mm_shuffle_ps(v9, v9, 198);
    v10.m128_f32[0] = *(float *)&a4;
    v11 = _mm_shuffle_ps(v10, v10, 39);
    v11.m128_f32[0] = *(float *)&a4;
    v58 = _mm_shuffle_ps(v11, v11, 57);
    v59 = v58;
    sub_18082A520(&v63, &v59);
    v12 = a5;
    v13 = *a5;
    v68 = v13;
    v14 = (float)((float)HIBYTE(v13) * 0.30000001) + 6.755399441055744e15;
    *(double *)v58.m128_u64 = v14;
    v15 = -1;
    v16 = -1;
    if ( SLODWORD(v14) < 255 )
      v16 = LOBYTE(v14);
    HIBYTE(v68) = v16;
    v61 = v13;
    *(double *)v58.m128_u64 = (float)((float)HIBYTE(v13) * 0.30000001) + 6.755399441055744e15;
    if ( SLODWORD(v14) < 255 )
      v15 = LOBYTE(v14);
    HIBYTE(v61) = v15;
    v51 = 0.0;
    v52 = a3;
    v53 = 0;
    v54 = a3 + *(float *)&a4;
    v55 = 0;
    Block = nullptr;
    v57 = 0;
    v59.m128_u64[0] = 0x3FF0000000000000LL;
    v59.m128_i32[2] = *(_DWORD *)sub_180832CD0(&dword_180C9648C, &v68, v68);
    *(_QWORD *)&v62 = 0;
    DWORD2(v62) = *(_DWORD *)sub_180832CD0(&dword_180C9648C, &v58, v61);
    sub_180171480(&Block, 8);
    v17 = HIDWORD(v57);
    v18 = SHIDWORD(v57);
    v19 = (char *)Block;
    v20 = (char *)Block + 16 * SHIDWORD(v57);
    if ( v20 )
      *v20 = v62;
    HIDWORD(v57) = v17 + 2;
    v21 = (__m128 *)&v19[16 * v18 + 16];
    if ( v21 )
      *v21 = v59;
    v22 = (unsigned int *)sub_180832CD0(&dword_180C9648C, &v68, *v12);
    sub_180832420(&v51, v23, *v22);
    sub_180831B00(a1, &v51);
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a1 + 8) + 96LL))(*(_QWORD *)(a1 + 8)) )
    {
      v24 = (float *)v63;
      while ( v24 != (float *)((char *)v63 + 4 * SHIDWORD(v64)) )
      {
        v25 = *v24;
        if ( *v24 == 100002.0 )
        {
          v24 += 3;
        }
        else
        {
          if ( v25 == 100001.0 || v25 == 100003.0 || v25 == 100004.0 )
          {
            v59 = (__m128)xmmword_180AE5570;
            v60 = 1065353216;
            (*(void (__fastcall **)(_QWORD, void **, __m128 *))(**(_QWORD **)(a1 + 8) + 184LL))(
              *(_QWORD *)(a1 + 8),
              &v63,
              &v59);
            break;
          }
          ++v24;
        }
      }
    }
    free(Block);
    v51 = 0.0;
    v52 = (float)(*(float *)&a4 * 0.059999999) + a3;
    v53 = 0;
    v54 = (float)(*(float *)&a4 * 0.30000001) + a3;
    v55 = 0;
    Block = nullptr;
    v57 = 0;
    *(_QWORD *)&v62 = 0x3FF0000000000000LL;
    DWORD2(v62) = 0xFFFFFF;
    v59.m128_u64[0] = 0;
    v59.m128_i32[2] = dword_180C9648C;
    sub_180171480(&Block, 8);
    v26 = HIDWORD(v57);
    v27 = SHIDWORD(v57);
    v28 = (char *)Block;
    v29 = (__m128 *)((char *)Block + 16 * SHIDWORD(v57));
    if ( v29 )
      *v29 = v59;
    HIDWORD(v57) = v26 + 2;
    v30 = &v28[16 * v27 + 16];
    if ( v30 )
      *(_OWORD *)v30 = v62;
    sub_180822410(a1, &v51);
    free(Block);
    *(float *)&a4 = (float)(*(float *)&a4 * 0.2) + v7.m128_f32[0];
    v31 = _mm_shuffle_ps(*(__m128 *)&a4, *(__m128 *)&a4, 225);
    v31.m128_f32[0] = (float)(v6 * 0.050000001) + a3;
    v32 = _mm_shuffle_ps(v31, v31, 198);
    v32.m128_f32[0] = v6 * 0.60000002;
    v33 = _mm_shuffle_ps(v32, v32, 39);
    v33.m128_f32[0] = v6 * 0.40000001;
    v59 = _mm_shuffle_ps(v33, v33, 57);
    sub_180821410(a1, &v59);
    v34 = (float)((float)*((unsigned __int8 *)v12 + 3) / 255.0) * (float)(a6 * 0.5);
    v68 = dword_180C96488;
    if ( v34 > 0.0 )
    {
      if ( v34 < 1.0 )
        v35 = (int)(float)(v34 * 255.996);
      else
        LOBYTE(v35) = -1;
    }
    else
    {
      LOBYTE(v35) = 0;
    }
    HIBYTE(v68) = v35;
    v51 = (float)(v6 * 0.5) + v7.m128_f32[0];
    v52 = (float)(v6 * 0.5) + a3;
    v53 = v7.m128_i32[0];
    v54 = v52;
    v55 = 1;
    Block = nullptr;
    v57 = 0;
    *(_QWORD *)&v62 = 0x3FF0000000000000LL;
    DWORD2(v62) = v68;
    v59.m128_u64[0] = 0;
    v59.m128_i32[2] = dword_180CB9E34;
    sub_180171480(&Block, 8);
    v36 = HIDWORD(v57);
    v37 = SHIDWORD(v57);
    v38 = (char *)Block;
    v39 = (__m128 *)((char *)Block + 16 * SHIDWORD(v57));
    if ( v39 )
      *v39 = v59;
    HIDWORD(v57) = v36 + 2;
    v40 = &v38[16 * v37 + 16];
    if ( v40 )
      *(_OWORD *)v40 = v62;
    sub_180832420(&v51, v37, (unsigned int)dword_180CB9E34);
    v42 = a6 * 0.1;
    a6 = *(float *)&dword_180C96488;
    if ( v42 > 0.0 )
    {
      if ( v42 < 1.0 )
        v43 = (int)(float)(v42 * 255.996);
      else
        LOBYTE(v43) = -1;
    }
    else
    {
      LOBYTE(v43) = 0;
    }
    HIBYTE(a6) = v43;
    sub_180832420(&v51, v41, LODWORD(a6));
    sub_180831B00(a1, &v51);
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a1 + 8) + 96LL))(*(_QWORD *)(a1 + 8)) )
    {
      v44 = (float *)v63;
      while ( v44 != (float *)((char *)v63 + 4 * SHIDWORD(v64)) )
      {
        v45 = *v44;
        if ( *v44 == 100002.0 )
        {
          v44 += 3;
        }
        else
        {
          if ( v45 == 100001.0 || v45 == 100003.0 || v45 == 100004.0 )
          {
            v59 = (__m128)xmmword_180AE5570;
            v60 = 1065353216;
            (*(void (__fastcall **)(_QWORD, void **, __m128 *))(**(_QWORD **)(a1 + 8) + 184LL))(
              *(_QWORD *)(a1 + 8),
              &v63,
              &v59);
            break;
          }
          ++v44;
        }
      }
    }
    v46 = (float)((float)*((unsigned __int8 *)v12 + 3) / 255.0) * 0.5;
    a6 = *(float *)&dword_180C96488;
    if ( v46 > 0.0 )
    {
      if ( v46 < 1.0 )
        v47 = (int)(float)(v46 * 255.996);
      else
        LOBYTE(v47) = -1;
    }
    else
    {
      LOBYTE(v47) = 0;
    }
    HIBYTE(a6) = v47;
    sub_180831D50(a1, LODWORD(a6));
    v48 = _mm_shuffle_ps(v7, v7, 225);
    v48.m128_f32[0] = a3;
    v49 = _mm_shuffle_ps(v48, v48, 198);
    v49.m128_f32[0] = v6;
    v50 = _mm_shuffle_ps(v49, v49, 39);
    v50.m128_f32[0] = v6;
    v59 = _mm_shuffle_ps(v50, v50, 57);
    sub_180821140(a1, &v59);
    free(Block);
    HIDWORD(v64) = 0;
    free(v63);
  }
}

