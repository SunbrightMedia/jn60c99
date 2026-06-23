// sub_18087D480  @ 0x18087D480  (RVA 0x87D480)  floats=15
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5088  dword_180AE5088 = 0.8999999761581421
//   0x180AE51E8  flt_180AE51E8 = 2.0
//   0x180AE52D0  dword_180AE52D0 = 4.0
//   0x180AE52F4  dword_180AE52F4 = 5.0
//   0x180AE53DC  dword_180AE53DC = 30.0
//   0x180AE5470  dword_180AE5470 = 10000.0
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5488  dword_180AE5488 = 100005.0
//   0x180AE5570  xmmword_180AE5570 = 1.0

// Hidden C++ exception states: #wind=5
__int64 __fastcall sub_18087D480(__int64 a1, __int64 a2, int *a3, __int64 a4, __int64 a5)
{
  unsigned int *v9; // rax
  float v10; // xmm2_4
  float v11; // xmm0_4
  __m128 v12; // xmm1
  __m128 v13; // xmm1
  __int64 v14; // r8
  int v15; // ecx
  int v16; // edi
  int v17; // r15d
  __int64 v18; // rcx
  void (*v19)(void); // rdx
  _QWORD *v20; // rcx
  __int64 (__fastcall *v21)(); // r8
  unsigned int *v22; // rax
  float v23; // xmm12_4
  __m128 v24; // xmm1
  __m128 v25; // xmm1
  int v26; // edi
  int v27; // r8d
  int v28; // edx
  int v29; // ebx
  float v30; // xmm8_4
  float v31; // xmm9_4
  __int64 v32; // rcx
  _DWORD *v33; // rdx
  __int64 v34; // rbx
  void *v35; // r9
  unsigned int v36; // r8d
  unsigned int v37; // edx
  void *v38; // rcx
  unsigned int v39; // edi
  unsigned int v40; // r14d
  float v41; // xmm6_4
  __m128 v42; // xmm0
  __m128 v43; // xmm0
  __m128 v44; // xmm0
  _DWORD *v45; // rax
  _DWORD *v46; // rbx
  float v47; // xmm6_4
  __int64 *v48; // rax
  __int64 v49; // rcx
  int v50; // eax
  int v51; // r9d
  void *v52; // rcx
  void (__fastcall ***v53)(_QWORD, __int64); // rcx
  float *v54; // rcx
  char *v55; // rdx
  float v56; // xmm0_4
  unsigned int *v57; // rax
  __int64 (__fastcall *v58)(); // rdx
  int v59; // eax
  __m128 v60; // xmm2
  __m128 v61; // xmm2
  __m128 v62; // xmm2
  void *Block; // [rsp+58h] [rbp-B0h] BYREF
  unsigned __int64 v65; // [rsp+60h] [rbp-A8h]
  __int128 v66; // [rsp+68h] [rbp-A0h]
  __int64 v67; // [rsp+78h] [rbp-90h]
  void *v68[2]; // [rsp+80h] [rbp-88h] BYREF
  _DWORD *v69; // [rsp+90h] [rbp-78h] BYREF
  __m128 v70; // [rsp+98h] [rbp-70h]
  __int128 v71; // [rsp+A8h] [rbp-60h]
  __m128 v72; // [rsp+B8h] [rbp-50h]
  char v73[4]; // [rsp+C8h] [rbp-40h] BYREF
  char v74[4]; // [rsp+CCh] [rbp-3Ch] BYREF
  int v75; // [rsp+D0h] [rbp-38h]
  char v76[4]; // [rsp+D4h] [rbp-34h] BYREF
  float v77; // [rsp+D8h] [rbp-30h]
  float v78; // [rsp+DCh] [rbp-2Ch]
  __int64 v79; // [rsp+E0h] [rbp-28h] BYREF
  __m128 v80; // [rsp+E8h] [rbp-20h]
  __int128 v81; // [rsp+108h] [rbp+0h] BYREF
  void *v82; // [rsp+118h] [rbp+10h]
  unsigned int v83; // [rsp+120h] [rbp+18h]
  unsigned int v84; // [rsp+124h] [rbp+1Ch]
  __int128 v85; // [rsp+128h] [rbp+20h] BYREF
  __int64 v86; // [rsp+138h] [rbp+30h]
  __int64 v87; // [rsp+140h] [rbp+38h]
  float v88; // [rsp+148h] [rbp+40h]
  void *v89; // [rsp+150h] [rbp+48h]
  __m128 v90; // [rsp+158h] [rbp+50h] BYREF
  __int128 v91; // [rsp+168h] [rbp+60h] BYREF
  __m128 v92; // [rsp+178h] [rbp+70h] BYREF
  __m128 v93; // [rsp+188h] [rbp+80h] BYREF
  __m128 v94; // [rsp+198h] [rbp+90h] BYREF
  void *v95; // [rsp+1A8h] [rbp+A0h] BYREF
  int v96; // [rsp+1B4h] [rbp+ACh]
  int v97; // [rsp+1D4h] [rbp+CCh]

  v87 = -2;
  v9 = (unsigned int *)sub_1808D6630(a3, v73, 16783392, 0);
  sub_180831D50(a2, *v9);
  v10 = (float)a3[11];
  v11 = (float)a3[10];
  v70.m128_u64[0] = 0;
  v12 = _mm_shuffle_ps(v70, v70, 210);
  v12.m128_f32[0] = v11;
  v13 = _mm_shuffle_ps(v12, v12, 39);
  v13.m128_f32[0] = v10;
  v70 = _mm_shuffle_ps(v13, v13, 57);
  v90 = v70;
  sub_180820E30(a2, &v90);
  v15 = a3[11];
  v16 = 0;
  if ( a3[10] - 2 > 0 )
    v16 = a3[10] - 2;
  v17 = 0;
  if ( v15 - 2 > 0 )
    v17 = v15 - 2;
  *(_QWORD *)&v71 = 0x100000001LL;
  *((_QWORD *)&v71 + 1) = __PAIR64__(v17, v16);
  v81 = v71;
  if ( *(_BYTE *)(a2 + 16) )
  {
    *(_BYTE *)(a2 + 16) = 0;
    v18 = *(_QWORD *)(a2 + 8);
    v19 = *(void (**)(void))(*(_QWORD *)v18 + 104LL);
    if ( (char *)v19 == (char *)sub_180163CA0 )
      sub_18016CBD0(v18 + 8, v19, v14);
    else
      v19();
  }
  v20 = *(_QWORD **)(a2 + 8);
  v21 = *(__int64 (__fastcall **)())(*v20 + 40LL);
  if ( v21 == sub_180163E30 )
  {
    v91 = v81;
    sub_18016F550(v20[1], &v91);
  }
  else
  {
    ((void (__fastcall *)(_QWORD *, __int128 *))v21)(v20, &v81);
  }
  v22 = (unsigned int *)sub_1808D6630(a3, v74, 16783360, 0);
  sub_180831D50(a2, *v22);
  v23 = (float)v16;
  v72.m128_u64[0] = 0x3F8000003F800000LL;
  v24 = _mm_shuffle_ps(v72, v72, 210);
  v24.m128_f32[0] = (float)v16;
  v25 = _mm_shuffle_ps(v24, v24, 39);
  v25.m128_f32[0] = (float)v17;
  v72 = _mm_shuffle_ps(v25, v25, 57);
  v92 = v72;
  sub_180820F90(a2, &v92);
  v26 = 0;
  v27 = 130;
  if ( v17 + 20 < 130 )
    v27 = v17 + 20;
  if ( (a3[107] > 0 || a3[83] > 2) && *(_DWORD *)(a4 + 12) + 50 < v27 )
    v27 = *(_DWORD *)(a4 + 12) + 50;
  v28 = v27 / -10;
  v97 = v27 / -10;
  v29 = a3[58];
  if ( v29 )
  {
    Block = nullptr;
    v65 = 0;
    v66 = 0;
    LOBYTE(v67) = 1;
    v30 = (float)v27;
    if ( v29 == 2 )
    {
      v88 = (float)v28;
      v77 = (float)(v30 * 0.5) + (float)v28;
      v31 = (float)v28;
      v78 = (float)v28;
      *((float *)&v66 + 1) = v77;
      *(float *)&v66 = v77;
      *((float *)&v66 + 3) = (float)v28;
      *((float *)&v66 + 2) = (float)v28;
      sub_180179780(&Block, &unk_180AA33E4);
      sub_18082B140(&Block);
      sub_18082B140(&Block);
      if ( HIDWORD(v65) && (SHIDWORD(v65) <= 0 || *((float *)Block + HIDWORD(v65) - 1) != 100005.0) )
      {
        sub_1801716F0(&Block, (unsigned int)(HIDWORD(v65) + 1));
        v32 = SHIDWORD(v65);
        ++HIDWORD(v65);
        v33 = (char *)Block + 4 * v32;
        if ( v33 )
          *v33 = 1203982976;
      }
      v34 = sub_180827240(&Block, &v95);
      if ( &Block != (void **)v34 )
      {
        v82 = *(void **)v34;
        v35 = v82;
        *(_QWORD *)v34 = 0;
        v83 = *(_DWORD *)(v34 + 8);
        v36 = v83;
        v84 = *(_DWORD *)(v34 + 12);
        v37 = v84;
        *(_QWORD *)(v34 + 8) = 0;
        v38 = Block;
        v89 = Block;
        Block = v35;
        v65 = __PAIR64__(v37, v36);
        free(v38);
      }
      v66 = *(_OWORD *)(v34 + 16);
      LOBYTE(v67) = *(_BYTE *)(v34 + 32);
      v96 = 0;
      free(v95);
      v39 = 1727998464;
      v40 = 33;
    }
    else
    {
      v39 = 1711321273;
      v41 = (float)v28;
      v42 = _mm_shuffle_ps((__m128)COERCE_UNSIGNED_INT((float)v28), (__m128)COERCE_UNSIGNED_INT((float)v28), 225);
      v42.m128_f32[0] = (float)v28;
      v43 = _mm_shuffle_ps(v42, v42, 198);
      v43.m128_f32[0] = v30;
      v44 = _mm_shuffle_ps(v43, v43, 39);
      v44.m128_f32[0] = v30;
      v80 = _mm_shuffle_ps(v44, v44, 57);
      v93 = v80;
      sub_18082A520(&Block, &v93);
      v31 = v41;
      v40 = 63;
      if ( v29 == 3 )
        v40 = 105;
    }
    v68[0] = nullptr;
    v68[1] = nullptr;
    sub_180170950(v68, 200);
    v45 = operator new(0x40u);
    v46 = v45;
    v47 = 0.1;
    if ( (float)(v30 * 0.89999998) >= 0.1 )
      v47 = fminf(10000.0, v30 * 0.89999998);
    v45[2] = 0;
    *(_QWORD *)v45 = &juce::Font::SharedFontInternal::`vftable';
    *((_QWORD *)v45 + 2) = 0;
    v48 = (__int64 *)sub_1807D2430();
    v49 = *v48;
    *((_QWORD *)v46 + 3) = *v48;
    if ( (*(_DWORD *)(v49 - 16) & 0x30000000) == 0 )
      _InterlockedExchangeAdd((volatile signed __int32 *)(v49 - 16), 1u);
    sub_1800FDCD0(v46 + 8, "Bold");
    *((float *)v46 + 10) = v47;
    *(_QWORD *)(v46 + 11) = 1065353216;
    v46[13] = 0;
    *((_BYTE *)v46 + 56) = 0;
    v69 = v46;
    _InterlockedExchangeAdd(v46 + 2, 1u);
    v50 = sub_180766B20(&v79, v40);
    v75 = 36;
    sub_180832FD0((unsigned int)v68, (unsigned int)&v69, v50, v51, LODWORD(v31), LODWORD(v30), LODWORD(v30), 36, 0, 0);
    v52 = (void *)(v79 - 16);
    if ( (*(_DWORD *)(v79 - 16) & 0x30000000) == 0
      && !_InterlockedExchangeAdd((volatile signed __int32 *)v52, 0xFFFFFFFF) )
    {
      j_j_free_0(v52);
    }
    v53 = (void (__fastcall ***)(_QWORD, __int64))v69;
    if ( v69 && _InterlockedExchangeAdd(v69 + 2, 0xFFFFFFFF) == 1 )
      (**v53)(v53, 1);
    sub_1807CE070(v68, &Block);
    LOBYTE(v67) = 0;
    sub_180831D50(a2, v39);
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
    {
      v54 = (float *)Block;
      v55 = (char *)Block + 4 * SHIDWORD(v65);
      if ( Block != v55 )
      {
        do
        {
          v56 = *v54;
          if ( *v54 == 100002.0 )
          {
            v54 += 2;
          }
          else if ( v56 == 100001.0 || v56 == 100003.0 || v56 == 100004.0 )
          {
            v85 = xmmword_180AE5570;
            v86 = 1065353216;
            (*(void (__fastcall **)(_QWORD, void **, __int128 *))(**(_QWORD **)(a2 + 8) + 184LL))(
              *(_QWORD *)(a2 + 8),
              &Block,
              &v85);
            break;
          }
          ++v54;
        }
        while ( v54 != (float *)v55 );
      }
    }
    v26 = 80;
    sub_180146ED0(v68);
    free(v68[0]);
    HIDWORD(v65) = 0;
    free(Block);
  }
  v57 = (unsigned int *)sub_1808D6630(a3, v76, 16783376, 0);
  sub_180831D50(a2, *v57);
  v58 = *(__int64 (__fastcall **)())(*(_QWORD *)a1 + 40LL);
  if ( v58 == sub_18087D470 )
    v59 = 40;
  else
    v59 = ((__int64 (__fastcall *)(__int64))v58)(a1);
  v60 = _mm_shuffle_ps(
          (__m128)COERCE_UNSIGNED_INT((float)(v26 + 1)),
          (__m128)COERCE_UNSIGNED_INT((float)(v26 + 1)),
          225);
  v60.m128_f32[0] = 30.0;
  v61 = _mm_shuffle_ps(v60, v60, 198);
  v61.m128_f32[0] = v23;
  v62 = _mm_shuffle_ps(v61, v61, 39);
  v62.m128_f32[0] = (float)(v17 - v59 - 20);
  v94 = _mm_shuffle_ps(v62, v62, 57);
  return sub_180833340(a5, a2, &v94);
}

