// sub_1807CBD40 @ 0x1807CBD40 (RVA 0x7CBD40)  float_ops=55

// Hidden C++ exception states: #wind=1
void __fastcall sub_1807CBD40(unsigned int *a1, __int64 a2, int *a3)
{
  unsigned int v6; // r9d
  int v7; // ecx
  __int64 v8; // rdx
  char *v9; // r8
  _OWORD *v10; // rax
  char *v11; // rax
  float v12; // xmm6_4
  __int64 v13; // rdx
  double v14; // rax
  float v15; // xmm4_4
  float v16; // xmm2_4
  float v17; // xmm3_4
  float v18; // xmm11_4
  float v19; // xmm0_4
  unsigned int v20; // xmm6_4
  unsigned int v21; // xmm10_4
  float v22; // xmm9_4
  float v23; // xmm13_4
  float v24; // xmm0_4
  float v25; // xmm14_4
  float v26; // xmm15_4
  unsigned int v27; // xmm8_4
  float v28; // xmm12_4
  float v29; // xmm11_4
  _QWORD *v30; // rcx
  __int64 (__fastcall *v31)(); // r8
  float v32; // xmm8_4
  float v33; // xmm6_4
  float v34; // xmm11_4
  float v35; // xmm10_4
  _QWORD *v36; // rcx
  __int64 (__fastcall *v37)(); // r8
  _QWORD *v38; // rcx
  __int64 (__fastcall *v39)(); // r8
  _QWORD *v40; // rcx
  __int64 (__fastcall *v41)(); // r8
  _QWORD *v42; // rcx
  __int64 (__fastcall *v43)(); // r8
  _QWORD *v44; // rcx
  __int64 (__fastcall *v45)(); // r8
  float v46; // xmm9_4
  float v47; // xmm7_4
  _QWORD *v48; // rcx
  __int64 (__fastcall *v49)(); // r8
  _QWORD *v50; // rcx
  __int64 (__fastcall *v51)(); // r8
  _QWORD *v52; // rcx
  __int64 (__fastcall *v53)(); // r8
  __int128 v54; // [rsp+28h] [rbp-E0h] BYREF
  __int128 v55; // [rsp+38h] [rbp-D0h] BYREF
  __int64 v56; // [rsp+48h] [rbp-C0h]
  void *Block; // [rsp+50h] [rbp-B8h] BYREF
  __int64 v58; // [rsp+58h] [rbp-B0h]
  __int128 v59; // [rsp+68h] [rbp-A0h] BYREF
  unsigned int v60; // [rsp+78h] [rbp-90h]
  float v61; // [rsp+7Ch] [rbp-8Ch]
  float v62; // [rsp+80h] [rbp-88h]
  __int128 v63; // [rsp+84h] [rbp-84h]
  __int64 v64; // [rsp+98h] [rbp-70h]
  unsigned int v65; // [rsp+178h] [rbp+70h]
  unsigned int v66; // [rsp+178h] [rbp+70h]
  float v67; // [rsp+178h] [rbp+70h]
  float v68; // [rsp+188h] [rbp+80h]
  float v69; // [rsp+190h] [rbp+88h]

  v64 = -2;
  v65 = *a1;
  v6 = *a1;
  HIBYTE(v65) = 0;
  v55 = 0;
  LOBYTE(v56) = 0;
  Block = nullptr;
  v58 = 0;
  *(_QWORD *)&v59 = 0x3FF0000000000000LL;
  DWORD2(v59) = v65;
  *(_QWORD *)&v54 = 0;
  DWORD2(v54) = v6;
  sub_180171480(&Block, 8);
  v7 = HIDWORD(v58);
  v8 = SHIDWORD(v58);
  v9 = (char *)Block;
  v10 = (char *)Block + 16 * SHIDWORD(v58);
  if ( v10 )
    *v10 = v54;
  HIDWORD(v58) = v7 + 2;
  v11 = &v9[16 * v8 + 16];
  if ( v11 )
    *(_OWORD *)v11 = v59;
  v12 = 0.050000001;
  do
  {
    v66 = *a1;
    v13 = 255;
    v14 = (float)((float)HIBYTE(*a1) * (float)(v12 * v12)) + 6.755399441055744e15;
    if ( SLODWORD(v14) < 255 )
      v13 = LOBYTE(v14);
    HIBYTE(v66) = v13;
    sub_180832420(&v55, v13, v66);
    v12 = v12 + 0.1;
  }
  while ( v12 < 1.0 );
  v15 = (float)(int)a1[1];
  v61 = v15 + (float)(v15 * 0.5);
  v16 = (float)(int)a1[3];
  v17 = -(float)(v15 * 0.5);
  *((_QWORD *)&v63 + 1) = __PAIR64__(
                            COERCE_UNSIGNED_INT(fmaxf((float)(v17 - (float)(v15 * 0.5)) + (float)a3[3], 0.0)),
                            COERCE_UNSIGNED_INT(fmaxf((float)(v17 - (float)(v15 * 0.5)) + (float)a3[2], 0.0)));
  *((float *)&v63 + 1) = (float)((float)a3[1] - v17) + v16;
  *(float *)&v63 = (float)((float)*a3 - v17) + (float)(int)a1[2];
  v18 = fmaxf((float)(v61 + v61) + *((float *)&v63 + 2), 0.0);
  v19 = fmaxf((float)(v61 + v61) + *((float *)&v63 + 3), 0.0);
  *(float *)&v20 = *((float *)&v63 + 1) - v61;
  v67 = *((float *)&v63 + 1) - v61;
  *(float *)&v21 = *(float *)&v63 - v61;
  v69 = *(float *)&v63 - v61;
  v22 = fminf(v19, v61);
  v23 = (float)(*((float *)&v63 + 1) - v61) + v22;
  v24 = v19 - v22;
  v25 = fminf(v24, v61);
  v26 = (float)(v24 + v23) - v25;
  v62 = v24 - v25;
  *(float *)&v27 = fminf(v18, v61);
  v60 = v27;
  v28 = *(float *)&v27 + (float)(*(float *)&v63 - v61);
  v29 = v18 - *(float *)&v27;
  *(float *)&v55 = v28;
  *((float *)&v55 + 1) = v23;
  v68 = (float)(*(float *)&v27 * 0.0) + (float)(*(float *)&v63 - v61);
  *((float *)&v55 + 2) = v68;
  *((float *)&v55 + 3) = v23;
  LOBYTE(v56) = 1;
  sub_180831B00(a2, &v55);
  *(_QWORD *)&v54 = __PAIR64__(v20, v21);
  *((_QWORD *)&v54 + 1) = __PAIR64__(LODWORD(v22), v27);
  v30 = *(_QWORD **)(a2 + 8);
  v31 = *(__int64 (__fastcall **)())(*v30 + 160LL);
  if ( v31 == sub_1801638B0 )
  {
    v59 = v54;
    sub_18016E830(v30[1], &v59);
  }
  else
  {
    ((void (__fastcall *)(_QWORD *, __int128 *))v31)(v30, &v54);
  }
  v32 = fminf(v29, v61);
  v33 = (float)(v29 + v28) - v32;
  v34 = v29 - v32;
  v35 = v32 * 0.0;
  *(float *)&v55 = (float)(v32 * 0.0) + v33;
  *((float *)&v55 + 1) = v23;
  *((float *)&v55 + 2) = v33 + v32;
  *((float *)&v55 + 3) = v23;
  LOBYTE(v56) = 1;
  sub_180831B00(a2, &v55);
  *(_QWORD *)&v54 = __PAIR64__(LODWORD(v67), LODWORD(v33));
  *((_QWORD *)&v54 + 1) = __PAIR64__(LODWORD(v22), LODWORD(v32));
  v36 = *(_QWORD **)(a2 + 8);
  v37 = *(__int64 (__fastcall **)())(*v36 + 160LL);
  if ( v37 == sub_1801638B0 )
  {
    v59 = v54;
    sub_18016E830(v36[1], &v59);
  }
  else
  {
    ((void (__fastcall *)(_QWORD *, __int128 *))v37)(v36, &v54);
  }
  *(float *)&v55 = (float)(v34 * 0.0) + v28;
  *((float *)&v55 + 1) = v23;
  *((float *)&v55 + 2) = *(float *)&v55;
  *((float *)&v55 + 3) = (float)(v22 * 0.0) + v67;
  LOBYTE(v56) = 0;
  sub_180831B00(a2, &v55);
  *(_QWORD *)&v54 = __PAIR64__(LODWORD(v67), LODWORD(v28));
  *((_QWORD *)&v54 + 1) = __PAIR64__(LODWORD(v22), LODWORD(v34));
  v38 = *(_QWORD **)(a2 + 8);
  v39 = *(__int64 (__fastcall **)())(*v38 + 160LL);
  if ( v39 == sub_1801638B0 )
  {
    v59 = v54;
    sub_18016E830(v38[1], &v59);
  }
  else
  {
    ((void (__fastcall *)(_QWORD *, __int128 *))v39)(v38, &v54);
  }
  *(float *)&v55 = v28;
  *((float *)&v55 + 1) = (float)(v25 * 0.0) + v26;
  *((float *)&v55 + 2) = v68;
  *((float *)&v55 + 3) = *((float *)&v55 + 1);
  LOBYTE(v56) = 1;
  sub_180831B00(a2, &v55);
  *(float *)&v54 = v69;
  *((float *)&v54 + 1) = (float)(v24 + v23) - v25;
  *((_QWORD *)&v54 + 1) = __PAIR64__(LODWORD(v25), v60);
  v40 = *(_QWORD **)(a2 + 8);
  v41 = *(__int64 (__fastcall **)())(*v40 + 160LL);
  if ( v41 == sub_1801638B0 )
  {
    v59 = v54;
    sub_18016E830(v40[1], &v59);
  }
  else
  {
    ((void (__fastcall *)(_QWORD *, __int128 *))v41)(v40, &v54);
  }
  *(float *)&v55 = v35 + v33;
  *((float *)&v55 + 1) = (float)(v25 * 0.0) + v26;
  *((float *)&v55 + 2) = v33 + v32;
  *((float *)&v55 + 3) = *((float *)&v55 + 1);
  LOBYTE(v56) = 1;
  sub_180831B00(a2, &v55);
  *(float *)&v54 = v33;
  *((float *)&v54 + 1) = (float)(v24 + v23) - v25;
  *((_QWORD *)&v54 + 1) = __PAIR64__(LODWORD(v25), LODWORD(v32));
  v42 = *(_QWORD **)(a2 + 8);
  v43 = *(__int64 (__fastcall **)())(*v42 + 160LL);
  if ( v43 == sub_1801638B0 )
  {
    v59 = v54;
    sub_18016E830(v42[1], &v59);
  }
  else
  {
    ((void (__fastcall *)(_QWORD *, __int128 *))v43)(v42, &v54);
  }
  *(float *)&v55 = (float)(v34 * 0.0) + v28;
  *((float *)&v55 + 1) = (float)(v25 * 0.0) + v26;
  *((float *)&v55 + 2) = *(float *)&v55;
  *((float *)&v55 + 3) = v26 + v25;
  LOBYTE(v56) = 0;
  sub_180831B00(a2, &v55);
  *(float *)&v54 = v28;
  *((float *)&v54 + 1) = (float)(v24 + v23) - v25;
  *((_QWORD *)&v54 + 1) = __PAIR64__(LODWORD(v25), LODWORD(v34));
  v44 = *(_QWORD **)(a2 + 8);
  v45 = *(__int64 (__fastcall **)())(*v44 + 160LL);
  if ( v45 == sub_1801638B0 )
  {
    v59 = v54;
    sub_18016E830(v44[1], &v59);
  }
  else
  {
    ((void (__fastcall *)(_QWORD *, __int128 *))v45)(v44, &v54);
  }
  v46 = v62;
  v47 = (float)(v62 * 0.0) + v23;
  *(float *)&v55 = v28;
  *((float *)&v55 + 1) = v47;
  *((float *)&v55 + 2) = v68;
  *((float *)&v55 + 3) = v47;
  LOBYTE(v56) = 0;
  sub_180831B00(a2, &v55);
  *(_QWORD *)&v54 = __PAIR64__(LODWORD(v23), LODWORD(v69));
  *((_QWORD *)&v54 + 1) = __PAIR64__(LODWORD(v46), v60);
  v48 = *(_QWORD **)(a2 + 8);
  v49 = *(__int64 (__fastcall **)())(*v48 + 160LL);
  if ( v49 == sub_1801638B0 )
  {
    v59 = v54;
    sub_18016E830(v48[1], &v59);
  }
  else
  {
    ((void (__fastcall *)(_QWORD *, __int128 *))v49)(v48, &v54);
  }
  *(float *)&v55 = v35 + v33;
  *((float *)&v55 + 1) = v47;
  *((float *)&v55 + 2) = v33 + v32;
  *((float *)&v55 + 3) = v47;
  LOBYTE(v56) = 0;
  sub_180831B00(a2, &v55);
  *(_QWORD *)&v54 = __PAIR64__(LODWORD(v23), LODWORD(v33));
  *((_QWORD *)&v54 + 1) = __PAIR64__(LODWORD(v46), LODWORD(v32));
  v50 = *(_QWORD **)(a2 + 8);
  v51 = *(__int64 (__fastcall **)())(*v50 + 160LL);
  if ( v51 == sub_1801638B0 )
  {
    v59 = v54;
    sub_18016E830(v50[1], &v59);
  }
  else
  {
    ((void (__fastcall *)(_QWORD *, __int128 *))v51)(v50, &v54);
  }
  sub_180831D50(a2, *a1);
  v54 = v63;
  v52 = *(_QWORD **)(a2 + 8);
  v53 = *(__int64 (__fastcall **)())(*v52 + 160LL);
  if ( v53 == sub_1801638B0 )
  {
    v59 = v54;
    sub_18016E830(v52[1], &v59);
  }
  else
  {
    ((void (__fastcall *)(_QWORD *, __int128 *))v53)(v52, &v54);
  }
  free(Block);
}

