// sub_1808821E0  @ 0x1808821E0  (RVA 0x8821E0)  floats=15
// .rdata float constants referenced by this function:
//   0x180AE4F88  dword_180AE4F88 = 0.06800000369548798
//   0x180AE4FC8  dword_180AE4FC8 = 0.2409999966621399
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5050  dword_180AE5050 = 0.6909999847412109
//   0x180AE5070  dword_180AE5070 = 0.800000011920929
//   0x180AE5080  dword_180AE5080 = 0.8333333134651184
//   0x180AE508C  dword_180AE508C = 0.9090908765792847
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE5120  flt_180AE5120 = 1.5707963705062866
//   0x180AE51A0  dbl_180AE51A0 = 0.0
//   0x180AE5428  qword_180AE5428 = 0.0
//   0x180AE543C  dword_180AE543C = 255.0
//   0x180AE54E8  dword_180AE54E8 = -1.5707963705062866
//   0x180AE5570  xmmword_180AE5570 = 1.0

// Hidden C++ exception states: #wind=3
void __fastcall sub_1808821E0(__int64 a1, __int64 a2, __int64 a3, char a4, char a5)
{
  __int64 v7; // rdx
  int v8; // r12d
  int v9; // r10d
  __int64 v10; // r8
  __int64 v11; // rdx
  unsigned int v12; // edi
  _QWORD *v13; // rax
  char v14; // si
  unsigned __int64 v15; // r13
  unsigned __int64 v16; // rbx
  int v17; // rax^4
  int v18; // rcx^4
  float v19; // xmm5_4
  float v20; // xmm3_4
  int v21; // eax
  __int64 v22; // rdx
  char *v23; // r8
  _OWORD *v24; // rcx
  __m128 *v25; // rax
  __m128 v26; // xmm6
  unsigned int *v27; // rax
  int v28; // eax
  unsigned __int64 v29; // rbx
  int v30; // esi
  __int64 v31; // rdx
  int v32; // r13d
  unsigned int v33; // ebx
  int v34; // ecx
  int v35; // eax
  int v36; // eax
  __int64 v37; // rcx
  float v38; // xmm6_4
  __int16 v39; // r13
  __int16 v40; // si
  float v41; // xmm0_4
  int v42; // eax
  char v43; // r10
  unsigned int v44; // edx
  int v45; // r11d
  int v46; // r9d
  unsigned int v47; // ebx
  __int64 v48; // rdi
  __int64 v49; // rsi
  _QWORD *v50; // rax
  char v51; // di
  unsigned int v52; // r13d
  unsigned int *v53; // rax
  int v54; // edx
  int v55; // r8d
  float v56; // xmm10_4
  float v57; // xmm11_4
  __m128 v58; // xmm7
  float v59; // xmm6_4
  float v60; // xmm8_4
  float v61; // xmm9_4
  __int64 v62; // r8
  float *v63; // rax
  __m128 v64; // xmm3
  __m128 v65; // xmm1
  __m128 v66; // xmm1
  __m128 v67; // xmm1
  __m128 v68; // xmm0
  __m128 v69; // xmm0
  __int64 v70; // rcx
  void (*v71)(void); // rdx
  __m128 v72; // [rsp+30h] [rbp-D0h] BYREF
  __m128 v73; // [rsp+40h] [rbp-C0h] BYREF
  __m128 v74; // [rsp+60h] [rbp-A0h] BYREF
  __m128 v75; // [rsp+70h] [rbp-90h] BYREF
  unsigned __int64 v76; // [rsp+80h] [rbp-80h]
  _DWORD v77[4]; // [rsp+88h] [rbp-78h] BYREF
  char v78; // [rsp+98h] [rbp-68h]
  void *Block; // [rsp+A0h] [rbp-60h] BYREF
  __int64 v80; // [rsp+A8h] [rbp-58h]
  void *v81; // [rsp+B0h] [rbp-50h] BYREF
  __int64 v82; // [rsp+B8h] [rbp-48h]
  __int64 v83; // [rsp+C0h] [rbp-40h]
  int v84; // [rsp+C8h] [rbp-38h]
  __int128 v85; // [rsp+D0h] [rbp-30h]
  __int64 v86; // [rsp+E0h] [rbp-20h]
  unsigned int v88; // [rsp+1C8h] [rbp+C8h] BYREF
  double v89; // [rsp+1D0h] [rbp+D0h] BYREF
  char v90; // [rsp+1D8h] [rbp+D8h]

  v90 = a4;
  v86 = -2;
  sub_18089F800(a2, &v72);
  v7 = *(_QWORD *)(a2 + 456);
  v8 = *(_DWORD *)(v7 + 248);
  v9 = *(_DWORD *)(v7 + 244) - 1;
  v10 = v9;
  if ( v9 < 0 )
  {
LABEL_4:
    v9 = -1;
  }
  else
  {
    while ( **(_QWORD **)(*(_QWORD *)(v7 + 232) + 8 * v10) != a2 )
    {
      --v9;
      if ( --v10 < 0 )
        goto LABEL_4;
    }
  }
  if ( (unsigned int)v9 < *(_DWORD *)(v7 + 244) && (v11 = *(_QWORD *)(*(_QWORD *)(v7 + 232) + 8LL * v9)) != 0 )
    v12 = *(_DWORD *)(v11 + 16);
  else
    v12 = dword_180CB9E34;
  v88 = v12;
  v13 = (_QWORD *)sub_1807A9D30(a2 + 424, &v74);
  v14 = (*(__int64 (__fastcall **)(_QWORD, _QWORD *))(*(_QWORD *)*v13 + 40LL))(*v13, v13 + 1);
  (*(void (__fastcall **)(unsigned __int64, __int8 *))(*(_QWORD *)v74.m128_u64[0] + 176LL))(
    v74.m128_u64[0],
    &v74.m128_i8[8]);
  v15 = v72.m128_u64[1];
  v16 = v72.m128_u64[0];
  if ( v14 )
  {
    sub_180831D50(a3, v12);
    goto LABEL_26;
  }
  v74.m128_u64[0] = 0;
  v89 = 0.0;
  if ( !v8 )
  {
    LODWORD(v89) = v72.m128_i32[0];
    HIDWORD(v89) = v72.m128_i32[3] + v72.m128_i32[1];
LABEL_20:
    v18 = HIDWORD(v89);
    v74.m128_u64[0] = v72.m128_u64[0];
    v17 = v72.m128_i32[1];
    goto LABEL_21;
  }
  if ( v8 != 1 )
  {
    if ( v8 != 2 )
    {
      if ( v8 == 3 )
      {
        LODWORD(v89) = v72.m128_i32[0] + v72.m128_i32[2];
        HIDWORD(v89) = v72.m128_i32[1];
        v17 = v72.m128_i32[1];
        *(double *)v74.m128_u64 = v89;
        v18 = v72.m128_i32[1];
        v89 = *(double *)v72.m128_u64;
      }
      else
      {
        v17 = v74.m128_i32[1];
        v18 = HIDWORD(v89);
      }
      goto LABEL_21;
    }
    LODWORD(v89) = v72.m128_i32[0] + v72.m128_i32[2];
    HIDWORD(v89) = v72.m128_i32[1];
    goto LABEL_20;
  }
  LODWORD(v89) = v72.m128_i32[0];
  HIDWORD(v89) = v72.m128_i32[3] + v72.m128_i32[1];
  v17 = v72.m128_i32[3] + v72.m128_i32[1];
  *(double *)v74.m128_u64 = v89;
  v18 = v72.m128_i32[1];
  v89 = *(double *)v72.m128_u64;
LABEL_21:
  v19 = (float)SLODWORD(v89);
  LOBYTE(v89) = (int)(float)((float)(unsigned __int8)v12 * 0.90909088);
  BYTE1(v89) = (int)(float)((float)BYTE1(v88) * 0.90909088);
  BYTE2(v89) = (int)(float)((float)BYTE2(v88) * 0.90909088);
  BYTE3(v89) = HIBYTE(v88);
  v20 = (float)v74.m128_i32[0];
  v74.m128_i8[0] = (int)(float)(255.0 - (float)((float)(255 - (unsigned __int8)v12) * 0.83333331));
  v74.m128_i8[1] = (int)(float)(255.0 - (float)((float)(255 - BYTE1(v88)) * 0.83333331));
  v74.m128_i8[2] = (int)(float)(255.0 - (float)((float)(255 - BYTE2(v88)) * 0.83333331));
  v74.m128_i8[3] = HIBYTE(v88);
  *(float *)v77 = v20;
  *(float *)&v77[1] = (float)v17;
  *(float *)&v77[2] = v19;
  *(float *)&v77[3] = (float)v18;
  v78 = 0;
  Block = nullptr;
  v80 = 0;
  v73.m128_u64[0] = 0x3FF0000000000000LL;
  v73.m128_i32[2] = LODWORD(v89);
  *(_QWORD *)&v85 = 0;
  DWORD2(v85) = v74.m128_i32[0];
  sub_180171480(&Block, 8);
  v21 = HIDWORD(v80);
  v22 = SHIDWORD(v80);
  v23 = (char *)Block;
  v24 = (char *)Block + 16 * SHIDWORD(v80);
  if ( v24 )
    *v24 = v85;
  HIDWORD(v80) = v21 + 2;
  v25 = (__m128 *)&v23[16 * v22 + 16];
  if ( v25 )
    *v25 = v73;
  sub_180822410(a3, v77);
  free(Block);
LABEL_26:
  v26 = v72;
  v73 = v72;
  (*(void (__fastcall **)(_QWORD, __m128 *, _QWORD))(**(_QWORD **)(a3 + 8) + 168LL))(*(_QWORD *)(a3 + 8), &v73, 0);
  v27 = (unsigned int *)sub_1808D6630(a2, &v89, 16799762, 0);
  sub_180831D50(a3, *v27);
  v74 = v26;
  v28 = 1;
  if ( v8 == 1 )
  {
    v30 = v74.m128_i32[3];
    v31 = v74.m128_u32[1];
    LODWORD(v89) = v74.m128_i32[1];
  }
  else
  {
    v72.m128_i32[0] = v16;
    v29 = HIDWORD(v16);
    *(unsigned __int64 *)((char *)v72.m128_u64 + 4) = __PAIR64__(v15, v29);
    if ( SHIDWORD(v15) < 1 )
      v28 = HIDWORD(v15);
    v72.m128_i32[3] = v28;
    LODWORD(v89) = v28 + v29;
    v30 = HIDWORD(v15) - v28;
    v73 = v72;
    (*(void (__fastcall **)(_QWORD, __m128 *, _QWORD))(**(_QWORD **)(a3 + 8) + 168LL))(*(_QWORD *)(a3 + 8), &v73, 0);
    v31 = LODWORD(v89);
  }
  v32 = v74.m128_i32[2];
  v33 = v74.m128_i32[0];
  if ( v8 )
  {
    v34 = 1;
    if ( v30 < 1 )
      v34 = v30;
    v72.m128_i32[0] = v74.m128_i32[0];
    v72.m128_i32[1] = v30 + v31 - v34;
    v72.m128_u64[1] = __PAIR64__(v34, v74.m128_u32[2]);
    v30 -= v34;
    v73 = v72;
    (*(void (__fastcall **)(_QWORD, __m128 *, _QWORD))(**(_QWORD **)(a3 + 8) + 168LL))(*(_QWORD *)(a3 + 8), &v73, 0);
  }
  if ( v8 != 3 )
  {
    v72.m128_u64[0] = __PAIR64__(LODWORD(v89), v33);
    v35 = 1;
    if ( v32 < 1 )
      v35 = v32;
    v72.m128_u64[1] = __PAIR64__(v30, v35);
    v33 += v35;
    v32 -= v35;
    v73 = v72;
    (*(void (__fastcall **)(_QWORD, __m128 *, _QWORD))(**(_QWORD **)(a3 + 8) + 168LL))(*(_QWORD *)(a3 + 8), &v73, 0);
  }
  if ( v8 != 2 )
  {
    v36 = 1;
    if ( v32 < 1 )
      v36 = v32;
    v72.m128_i32[0] = v32 + v33 - v36;
    *(unsigned __int64 *)((char *)v72.m128_u64 + 4) = __PAIR64__(v36, LODWORD(v89));
    v72.m128_i32[3] = v30;
    v73 = v72;
    (*(void (__fastcall **)(_QWORD, __m128 *, _QWORD))(**(_QWORD **)(a3 + 8) + 168LL))(*(_QWORD *)(a3 + 8), &v73, 0);
  }
  if ( (*(_BYTE *)(a2 + 169) & 0x10) != 0
    || (v37 = *(_QWORD *)(a2 + 24)) != 0 && !(unsigned __int8)sub_1808C7290(v37, v31) )
  {
    v38 = 0.30000001;
  }
  else if ( v90 || a5 )
  {
    v38 = 1.0;
  }
  else
  {
    v38 = 0.80000001;
  }
  v39 = BYTE2(v88);
  v40 = BYTE1(v88);
  v41 = sqrtf(
          (float)((float)((float)((float)((float)BYTE1(v88) / 255.0) * (float)((float)BYTE1(v88) / 255.0)) * 0.69099998)
                + (float)((float)((float)((float)BYTE2(v88) / 255.0) * (float)((float)BYTE2(v88) / 255.0)) * 0.241))
        + (float)((float)((float)((float)(unsigned __int8)v12 / 255.0) * (float)((float)(unsigned __int8)v12 / 255.0))
                * 0.068000004));
  v42 = dword_180C9648C;
  if ( v41 >= 0.5 )
    v42 = dword_180C96488;
  LODWORD(v89) = v42;
  BYTE3(v89) = -1;
  v43 = -1;
  if ( HIBYTE(v88) )
  {
    v44 = 255 - HIBYTE(LODWORD(v89));
    v45 = 255 - ((int)(v44 * (255 - HIBYTE(v88))) >> 8);
    if ( v45 > 0 )
    {
      v46 = (int)(HIBYTE(v88) * v44) / v45;
      LOBYTE(v88) = LOBYTE(v89) + ((unsigned __int16)(v46 * ((unsigned __int8)v12 - LOBYTE(v89))) >> 8);
      BYTE1(v88) = BYTE1(v89) + ((unsigned __int16)(v46 * (v40 - BYTE1(v89))) >> 8);
      BYTE2(v88) = BYTE2(v89) + ((unsigned __int16)(v46 * (v39 - BYTE2(v89))) >> 8);
      HIBYTE(v88) = -1 - ((unsigned __int16)(v44 * (255 - HIBYTE(v88))) >> 8);
      v12 = v88;
    }
  }
  else
  {
    v12 = LODWORD(v89);
  }
  v88 = v12;
  v89 = (float)((float)HIBYTE(v12) * v38) + 6.755399441055744e15;
  if ( SLODWORD(v89) < 255 )
    v43 = LOBYTE(v89);
  HIBYTE(v88) = v43;
  v47 = v88;
  v48 = *(_QWORD *)(a2 + 24);
  if ( v48 )
  {
    while ( 1 )
    {
      v49 = _RTDynamicCast(
              v48,
              0,
              &juce::Component `RTTI Type Descriptor',
              &juce::TabbedButtonBar `RTTI Type Descriptor',
              0);
      if ( v49 )
        break;
      v48 = *(_QWORD *)(v48 + 24);
      if ( !v48 )
        goto LABEL_70;
    }
    v50 = (_QWORD *)sub_1807A9D30(a2 + 424, &v73);
    v51 = (*(__int64 (__fastcall **)(_QWORD, _QWORD *))(*(_QWORD *)*v50 + 40LL))(*v50, v50 + 1);
    (*(void (__fastcall **)(unsigned __int64, unsigned __int16 *))(*(_QWORD *)v73.m128_u64[0] + 176LL))(
      v73.m128_u64[0],
      &v73.m128_u16[4]);
    v52 = 16799763;
    if ( v51 )
      v52 = 16799765;
    if ( (unsigned __int8)sub_1808CA3E0(v49, v52) )
    {
      v53 = (unsigned int *)sub_1808D6630(v49, &v88, v52, 0);
    }
    else
    {
      if ( !(unsigned __int8)sub_180899E10(a1 - 120, v52) )
        goto LABEL_70;
      v53 = (unsigned int *)sub_180899F20(a1 - 120, &v88, v52);
    }
    v47 = *v53;
  }
LABEL_70:
  v73 = 0;
  v72 = 0;
  sub_18089F900(a2, &v73, &v72);
  v56 = (float)v72.m128_i32[3];
  v57 = (float)v72.m128_i32[2];
  v58 = (__m128)COERCE_UNSIGNED_INT((float)v72.m128_i32[1]);
  v59 = (float)v72.m128_i32[0];
  v60 = (float)v72.m128_i32[2];
  v61 = (float)v72.m128_i32[3];
  if ( (unsigned int)(*(_DWORD *)(*(_QWORD *)(a2 + 456) + 248LL) - 2) <= 1 )
  {
    v60 = (float)v72.m128_i32[3];
    v61 = (float)v72.m128_i32[2];
  }
  v81 = nullptr;
  v82 = 0;
  v83 = 0;
  v84 = 9;
  sub_180882C50(a2, v54, v55, v47, (__int64)&v81);
  v75 = (__m128)xmmword_180AE5570;
  v76 = 1065353216;
  if ( v8 >= 0 )
  {
    if ( v8 <= 1 )
    {
      v58.m128_f32[0] = v58.m128_f32[0] + 0.0;
      v73.m128_u64[0] = 1065353216;
      v73.m128_i32[3] = 0;
      v69 = _mm_shuffle_ps(v73, v73, 210);
      v69.m128_f32[0] = v59 + 0.0;
      v75 = _mm_shuffle_ps(v69, v69, 201);
      v68 = (__m128)0x3F800000u;
    }
    else
    {
      if ( v8 == 2 )
      {
        v58.m128_f32[0] = v58.m128_f32[0] + v56;
      }
      else
      {
        if ( v8 != 3 )
          goto LABEL_81;
        v59 = v59 + v57;
      }
      v63 = (float *)sub_18082DEB0(&v75, &v73);
      v58.m128_f32[0] = v58.m128_f32[0] + v63[5];
      v64 = (__m128)*((unsigned int *)v63 + 4);
      v65 = _mm_shuffle_ps((__m128)*(unsigned int *)v63, (__m128)*(unsigned int *)v63, 225);
      v65.m128_f32[0] = v63[1];
      v66 = _mm_shuffle_ps(v65, v65, 198);
      v66.m128_f32[0] = v59 + v63[2];
      v67 = _mm_shuffle_ps(v66, v66, 39);
      v67.m128_f32[0] = v63[3];
      v75 = _mm_shuffle_ps(v67, v67, 57);
      v68 = v64;
    }
    v76 = _mm_unpacklo_ps(v68, v58).m128_u64[0];
  }
LABEL_81:
  if ( *(_BYTE *)(a3 + 16) )
  {
    *(_BYTE *)(a3 + 16) = 0;
    v70 = *(_QWORD *)(a3 + 8);
    v71 = *(void (**)(void))(*(_QWORD *)v70 + 104LL);
    if ( (char *)v71 == (char *)sub_180163CA0 )
      sub_18016CBD0(v70 + 8, v71, v62);
    else
      v71();
  }
  (*(void (__fastcall **)(_QWORD, __m128 *))(**(_QWORD **)(a3 + 8) + 24LL))(*(_QWORD *)(a3 + 8), &v75);
  v72.m128_u64[0] = 0;
  v72.m128_u64[1] = __PAIR64__(LODWORD(v61), LODWORD(v60));
  sub_180833340(&v81, a3, &v72);
  sub_1801700E0(&v81);
  HIDWORD(v82) = 0;
  free(v81);
}

