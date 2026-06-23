// sub_180879A10 @ 0x180879A10 (RVA 0x879A10)  float_ops=47

// Hidden C++ exception states: #wind=2
void __fastcall sub_180879A10(
        __int64 a1,
        __int64 a2,
        int a3,
        int a4,
        int a5,
        int a6,
        float a7,
        float a8,
        float a9,
        int a10,
        __int64 a11)
{
  __int64 v15; // rdi
  unsigned int v16; // r10d
  unsigned int *v17; // rax
  unsigned int v18; // ecx
  int v19; // ebx
  _QWORD *v20; // rcx
  __int64 (__fastcall *v21)(); // r8
  int v22; // edx
  int v23; // ecx
  int v24; // eax
  float v25; // xmm13_4
  float v26; // xmm12_4
  float v27; // xmm7_4
  int v28; // ebx
  float v29; // xmm0_4
  float v30; // xmm8_4
  unsigned int *v31; // rax
  __m128 v32; // xmm6
  float v33; // xmm14_4
  __int64 v34; // rcx
  unsigned int v35; // eax
  float v36; // xmm10_4
  __m128 v37; // xmm9
  unsigned int v38; // eax
  __int64 (__fastcall *v39)(); // r8
  unsigned int v40; // eax
  int v41; // eax
  int v42; // eax
  int v43; // esi
  unsigned int *v44; // rax
  unsigned int *v45; // rax
  float v46; // xmm0_4
  __m128 v47; // xmm6
  __m128 v48; // xmm6
  __m128 v49; // xmm6
  int v50; // r8d
  int v51; // r9d
  unsigned int v52; // ecx
  int v53; // ecx
  int v54; // r8d
  int v55; // r9d
  int v56; // ecx
  int v57; // r8d
  int v58; // r9d
  __m128 v59; // [rsp+50h] [rbp-B0h] BYREF
  float v60; // [rsp+60h] [rbp-A0h]
  _BYTE v61[4]; // [rsp+64h] [rbp-9Ch] BYREF
  void *Block; // [rsp+68h] [rbp-98h] BYREF
  __int64 v63; // [rsp+70h] [rbp-90h]
  __int128 v64; // [rsp+78h] [rbp-88h]
  char v65; // [rsp+88h] [rbp-78h]
  __m128 v66; // [rsp+90h] [rbp-70h] BYREF
  __int64 v67; // [rsp+A0h] [rbp-60h]
  void *v68; // [rsp+B0h] [rbp-50h] BYREF
  __int64 v69; // [rsp+B8h] [rbp-48h]
  float v70; // [rsp+C0h] [rbp-40h]
  float v71; // [rsp+C4h] [rbp-3Ch]
  float v72; // [rsp+C8h] [rbp-38h]
  float v73; // [rsp+CCh] [rbp-34h]
  char v74; // [rsp+D0h] [rbp-30h]
  __int64 v75; // [rsp+D8h] [rbp-28h]

  v75 = -2;
  v15 = a11;
  v16 = *(_DWORD *)(*(_QWORD *)(a11 + 512) + 32LL);
  if ( v16 - 2 <= 1 )
  {
    v17 = (unsigned int *)sub_1808D6630(a11, &a11, 16782096, 0);
    sub_180831D50(a2, *v17);
    v18 = *(_DWORD *)(*(_QWORD *)(v15 + 512) + 32LL);
    if ( v18 <= 0xB && (v19 = 2565, _bittest(&v19, v18)) )
    {
      v59.m128_f32[0] = (float)a3;
      v59.m128_f32[1] = (float)a4 + 0.5;
      v59.m128_f32[2] = a7 - (float)a3;
      v59.m128_f32[3] = (float)a6 - 1.0;
    }
    else
    {
      v59.m128_f32[0] = (float)a3 + 0.5;
      v59.m128_f32[1] = a7;
      v59.m128_f32[2] = (float)a5 - 1.0;
      v59.m128_f32[3] = (float)((float)a6 - a7) + (float)a4;
    }
    v66 = v59;
    v20 = *(_QWORD **)(a2 + 8);
    v21 = *(__int64 (__fastcall **)())(*v20 + 160LL);
    if ( v21 == sub_1801638B0 )
      sub_18016E830(v20[1], &v59);
    else
      ((void (__fastcall *)(_QWORD *, __m128 *))v21)(v20, &v66);
    return;
  }
  LOBYTE(a11) = (unsigned int)(a10 - 11) <= 1;
  v22 = 2561;
  if ( v16 <= 0xB && _bittest(&v22, v16) )
  {
    v23 = a6;
    v24 = a6;
  }
  else
  {
    v24 = a5;
    v23 = a6;
  }
  v25 = (float)v23;
  v26 = fminf((float)v24 * 0.25, 6.0);
  if ( v16 <= 0xB && _bittest(&v22, v16) )
    v27 = (float)(v25 * 0.5) + (float)a4;
  else
    v27 = (float)(a4 + v23);
  v28 = 2565;
  if ( v16 <= 0xB && _bittest(&v28, v16) )
  {
    v29 = (float)a3;
    v30 = (float)a3;
  }
  else
  {
    v29 = (float)a3;
    v30 = (float)((float)a5 * 0.5) + (float)a3;
  }
  v60 = v29;
  v68 = nullptr;
  v69 = 0;
  v74 = 1;
  v71 = v30;
  v70 = v30;
  v73 = v27;
  v72 = v27;
  sub_180179780(&v68, &unk_180AA33E4);
  sub_18082B140(&v68);
  v31 = (unsigned int *)sub_1808D6630(v15, v61, 16781824, 0);
  sub_180831D50(a2, *v31);
  v66 = (__m128)xmmword_180AE5570;
  v67 = 1065353216;
  v59.m128_f32[0] = v26;
  *(unsigned __int64 *)((char *)v59.m128_u64 + 4) = 0x200000001LL;
  sub_180830CE0(a2, &v68, &v59, &v66);
  Block = nullptr;
  v63 = 0;
  v64 = 0;
  v65 = 1;
  v32 = 0;
  v33 = 0.0;
  if ( (unsigned int)(a10 - 9) > 1 && !(_BYTE)a11 )
  {
    v34 = *(_QWORD *)(v15 + 512);
    v35 = *(_DWORD *)(v34 + 32);
    v36 = a7;
    if ( v35 <= 0xB && _bittest(&v28, v35) )
    {
      v37 = (__m128)LODWORD(a7);
    }
    else
    {
      v37 = (__m128)COERCE_UNSIGNED_INT((float)a5);
      v37.m128_f32[0] = (float)(v37.m128_f32[0] * 0.5) + v60;
    }
    if ( v35 <= 0xB && _bittest(&v28, v35) )
      v36 = (float)(v25 * 0.5) + (float)a4;
    goto LABEL_52;
  }
  v34 = *(_QWORD *)(v15 + 512);
  v38 = *(_DWORD *)(v34 + 32);
  if ( v38 <= 0xB && _bittest(&v28, v38) )
  {
    v27 = a8;
    v30 = a8;
  }
  else
  {
    v30 = (float)a5 * 0.5;
    v27 = a8;
  }
  if ( v38 <= 0xB && _bittest(&v28, v38) )
  {
    v27 = v25 * 0.5;
    v36 = v25 * 0.5;
  }
  else
  {
    v36 = v25 * 0.5;
  }
  if ( (_BYTE)a11 )
  {
    v33 = a7;
    if ( v38 <= 0xB && _bittest(&v28, v38) )
    {
      v32 = (__m128)LODWORD(a7);
    }
    else
    {
      v32 = (__m128)COERCE_UNSIGNED_INT((float)a5);
      v32.m128_f32[0] = v32.m128_f32[0] * 0.5;
    }
    if ( v38 > 0xB )
      goto LABEL_48;
    if ( _bittest(&v28, v38) )
      v33 = v25 * 0.5;
  }
  if ( v38 > 0xB || !_bittest(&v28, v38) )
  {
LABEL_48:
    v37 = (__m128)COERCE_UNSIGNED_INT((float)a5);
    v37.m128_f32[0] = v37.m128_f32[0] * 0.5;
    goto LABEL_49;
  }
  v37 = (__m128)LODWORD(a9);
LABEL_49:
  if ( v38 > 0xB || !_bittest(&v28, v38) )
    v36 = a9;
LABEL_52:
  v39 = *(__int64 (__fastcall **)())(*(_QWORD *)a1 + 32LL);
  if ( v39 == sub_18087A300 )
  {
    v40 = *(_DWORD *)(v34 + 32);
    if ( v40 <= 0xB && _bittest(&v28, v40) )
      v41 = *(_DWORD *)(v15 + 44);
    else
      v41 = *(_DWORD *)(v15 + 40);
    v42 = (int)(float)((float)v41 * 0.5);
    v43 = 12;
    if ( v42 < 12 )
      v43 = v42;
    goto LABEL_59;
  }
  v43 = ((__int64 (__fastcall *)(__int64, __int64))v39)(a1, v15);
  if ( !HIDWORD(v63) )
  {
LABEL_59:
    *(_QWORD *)((char *)&v64 + 4) = __PAIR64__(LODWORD(v27), LODWORD(v30));
    *(float *)&v64 = v30;
LABEL_67:
    *((float *)&v64 + 3) = v27;
    goto LABEL_68;
  }
  if ( *(float *)&v64 <= v30 )
  {
    if ( v30 > *((float *)&v64 + 1) )
      *((float *)&v64 + 1) = v30;
  }
  else
  {
    *(float *)&v64 = v30;
  }
  if ( *((float *)&v64 + 2) > v27 )
  {
    *((float *)&v64 + 2) = v27;
    goto LABEL_68;
  }
  if ( v27 > *((float *)&v64 + 3) )
    goto LABEL_67;
LABEL_68:
  sub_180179780(&Block, &unk_180AA33E4);
  sub_18082B140(&Block);
  v44 = (unsigned int *)sub_1808D6630(v15, v61, 16782096, 0);
  sub_180831D50(a2, *v44);
  v66 = (__m128)xmmword_180AE5570;
  v67 = 1065353216;
  v59.m128_f32[0] = v26;
  *(unsigned __int64 *)((char *)v59.m128_u64 + 4) = 0x200000001LL;
  sub_180830CE0(a2, &Block, &v59, &v66);
  if ( (unsigned int)(a10 - 9) <= 1 )
    goto LABEL_72;
  v45 = (unsigned int *)sub_1808D6630(v15, v61, 16782080, 0);
  sub_180831D50(a2, *v45);
  if ( !(_BYTE)a11 )
  {
    v32 = v37;
    v33 = v36;
  }
  v46 = (float)v43 * 0.5;
  v32.m128_f32[0] = v32.m128_f32[0] - v46;
  v47 = _mm_shuffle_ps(v32, v32, 225);
  v47.m128_f32[0] = v33 - v46;
  v48 = _mm_shuffle_ps(v47, v47, 198);
  v48.m128_f32[0] = (float)v43;
  v49 = _mm_shuffle_ps(v48, v48, 39);
  v49.m128_f32[0] = (float)v43;
  v66 = _mm_shuffle_ps(v49, v49, 57);
  sub_180821410(a2, &v66);
  if ( (_BYTE)a11 )
  {
LABEL_72:
    sub_1808D6630(v15, &a11, 16782080, 0);
    v52 = *(_DWORD *)(*(_QWORD *)(v15 + 512) + 32LL);
    if ( v52 <= 0xB && _bittest(&v28, v52) )
    {
      sub_180879350(v52, a2, v50, v51, v26 + v26, (__int64)&a11, 2);
      sub_180879350(v53, a2, v54, v55, v26 + v26, (__int64)&a11, 4);
    }
    else
    {
      sub_180879350(v52, a2, v50, v51, v26 + v26, (__int64)&a11, 1);
      sub_180879350(v56, a2, v57, v58, v26 + v26, (__int64)&a11, 3);
    }
  }
  HIDWORD(v63) = 0;
  free(Block);
  HIDWORD(v69) = 0;
  free(v68);
}

