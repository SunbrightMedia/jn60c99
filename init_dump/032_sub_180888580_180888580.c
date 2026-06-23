// sub_180888580  @ 0x180888580  (RVA 0x888580)  floats=20
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE4F8C  dword_180AE4F8C = 0.07000000029802322
//   0x180AE4FC0  dword_180AE4FC0 = 0.20000000298023224
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5030  dword_180AE5030 = 0.6000000238418579
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE5120  flt_180AE5120 = 1.5707963705062866
//   0x180AE5158  dbl_180AE5158 = 0.0
//   0x180AE51A0  dbl_180AE51A0 = 0.0
//   0x180AE5428  qword_180AE5428 = 0.0
//   0x180AE543C  dword_180AE543C = 255.0
//   0x180AE5440  dword_180AE5440 = 255.99600219726562
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5488  dword_180AE5488 = 100005.0
//   0x180AE5570  xmmword_180AE5570 = 1.0
//   0x180AE57C0  xmmword_180AE57C0 = -0.0

void __fastcall sub_180888580(__int64 a1, float a2, float a3, float a4, unsigned int *a5, float a6, int a7)
{
  float v9; // xmm14_4
  float v10; // xmm12_4
  __int64 v11; // rcx
  _DWORD *v12; // rdx
  float v13; // xmm13_4
  float v14; // xmm6_4
  float v15; // xmm7_4
  float v16; // xmm0_4
  unsigned int *v17; // rdi
  unsigned int v18; // r9d
  double v19; // xmm1_8
  char v20; // r8
  char v21; // dl
  int v22; // eax
  __int64 v23; // rdx
  char *v24; // r8
  _OWORD *v25; // rcx
  __int128 *v26; // rax
  unsigned int *v27; // rax
  __int64 v28; // rdx
  float *v29; // rcx
  float v30; // xmm0_4
  float v31; // xmm1_4
  int v32; // eax
  int v33; // ecx
  __int64 v34; // rdx
  char *v35; // r8
  __int128 *v36; // rax
  char *v37; // rax
  __int64 v38; // rdx
  float v39; // xmm10_4
  float v40; // xmm0_4
  int v41; // eax
  float *v42; // rcx
  float v43; // xmm0_4
  float v44; // xmm0_4
  int v45; // eax
  __int128 v46; // [rsp+28h] [rbp-E0h] BYREF
  __int64 v47; // [rsp+38h] [rbp-D0h]
  float v48; // [rsp+40h] [rbp-C8h] BYREF
  float v49; // [rsp+44h] [rbp-C4h]
  float v50; // [rsp+48h] [rbp-C0h]
  float v51; // [rsp+4Ch] [rbp-BCh]
  __int64 v52; // [rsp+50h] [rbp-B8h]
  void *Block; // [rsp+58h] [rbp-B0h] BYREF
  __int64 v54; // [rsp+60h] [rbp-A8h]
  __int64 v55; // [rsp+68h] [rbp-A0h]
  _BYTE v56[12]; // [rsp+70h] [rbp-98h] BYREF
  void *v57; // [rsp+80h] [rbp-88h] BYREF
  __int64 v58; // [rsp+88h] [rbp-80h]
  float v59; // [rsp+90h] [rbp-78h]
  float v60; // [rsp+94h] [rbp-74h]
  float v61; // [rsp+98h] [rbp-70h]
  float v62; // [rsp+9Ch] [rbp-6Ch]
  char v63; // [rsp+A0h] [rbp-68h]
  __int128 v64; // [rsp+A8h] [rbp-60h]
  __int64 v65; // [rsp+B8h] [rbp-50h]
  unsigned int v66; // [rsp+180h] [rbp+78h] BYREF

  v65 = -2;
  v9 = a6;
  if ( a6 < a4 )
  {
    v57 = nullptr;
    v58 = 0;
    v63 = 1;
    v10 = (float)(a4 * 0.5) + a2;
    v60 = v10;
    v59 = v10;
    v62 = a3;
    v61 = a3;
    sub_180179780(&v57, &unk_180AA33E4);
    sub_18082B140(&v57);
    sub_18082B140(&v57);
    sub_18082B140(&v57);
    sub_18082B140(&v57);
    if ( HIDWORD(v58) && (SHIDWORD(v58) <= 0 || *((float *)v57 + SHIDWORD(v58) - 1) != 100005.0) )
    {
      sub_1801716F0(&v57, (unsigned int)(HIDWORD(v58) + 1));
      v11 = SHIDWORD(v58);
      ++HIDWORD(v58);
      v12 = (char *)v57 + 4 * v11;
      if ( v12 )
        *v12 = 1203982976;
    }
    v13 = (float)(a4 * 0.5) + a3;
    v14 = (float)a7 * 1.5707964;
    v15 = cosf(v14);
    v16 = sinf(v14);
    *(float *)&v46 = v15;
    *((float *)&v46 + 1) = -v16;
    *((float *)&v46 + 2) = (float)((float)(v16 * v13) - (float)(v15 * v10)) + v10;
    *((float *)&v46 + 3) = v16;
    *(float *)&v47 = v15;
    *((float *)&v47 + 1) = v13 - (float)((float)(v16 * v10) + (float)(v15 * v13));
    sub_180828510(&v57, &v46);
    v17 = a5;
    v18 = *a5;
    v66 = v18;
    v19 = (float)((float)HIBYTE(v18) * 0.30000001) + 6.755399441055744e15;
    *(double *)v56 = v19;
    v20 = -1;
    v21 = -1;
    if ( SLODWORD(v19) < 255 )
      v21 = LOBYTE(v19);
    HIBYTE(v66) = v21;
    LODWORD(v55) = v18;
    *(double *)v56 = (float)((float)HIBYTE(v18) * 0.30000001) + 6.755399441055744e15;
    if ( SLODWORD(v19) < 255 )
      v20 = LOBYTE(v19);
    BYTE3(v55) = v20;
    v48 = 0.0;
    v49 = a3;
    v50 = 0.0;
    v51 = a3 + a4;
    LOBYTE(v52) = 0;
    Block = nullptr;
    v54 = 0;
    *(_QWORD *)&v46 = 0x3FF0000000000000LL;
    DWORD2(v46) = *(_DWORD *)sub_180832CD0(&dword_180C9648C, &v66, v66);
    *(_QWORD *)&v64 = 0;
    DWORD2(v64) = *(_DWORD *)sub_180832CD0(&dword_180C9648C, v56, (unsigned int)v55);
    sub_180171480(&Block, 8);
    v22 = HIDWORD(v54);
    v23 = SHIDWORD(v54);
    v24 = (char *)Block;
    v25 = (char *)Block + 16 * SHIDWORD(v54);
    if ( v25 )
      *v25 = v64;
    HIDWORD(v54) = v22 + 2;
    v26 = (__int128 *)&v24[16 * v23 + 16];
    if ( v26 )
      *v26 = v46;
    v27 = (unsigned int *)sub_180832CD0(&dword_180C9648C, &v66, *v17);
    sub_180832420(&v48, v28, *v27);
    sub_180831B00(a1, &v48);
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a1 + 8) + 96LL))(*(_QWORD *)(a1 + 8)) )
    {
      v29 = (float *)v57;
      while ( v29 != (float *)((char *)v57 + 4 * SHIDWORD(v58)) )
      {
        v30 = *v29;
        if ( *v29 == 100002.0 )
        {
          v29 += 3;
        }
        else
        {
          if ( v30 == 100001.0 || v30 == 100003.0 || v30 == 100004.0 )
          {
            v46 = xmmword_180AE5570;
            v47 = 1065353216;
            (*(void (__fastcall **)(_QWORD, void **, __int128 *))(**(_QWORD **)(a1 + 8) + 184LL))(
              *(_QWORD *)(a1 + 8),
              &v57,
              &v46);
            break;
          }
          ++v29;
        }
      }
    }
    free(Block);
    v31 = (float)((float)*((unsigned __int8 *)v17 + 3) / 255.0) * (float)(v9 * 0.5);
    v66 = dword_180C96488;
    if ( v31 > 0.0 )
    {
      if ( v31 < 1.0 )
        v32 = (int)(float)(v31 * 255.996);
      else
        LOBYTE(v32) = -1;
    }
    else
    {
      LOBYTE(v32) = 0;
    }
    HIBYTE(v66) = v32;
    v48 = v10;
    v49 = (float)(a4 * 0.5) + a3;
    v50 = a2 - (float)(a4 * 0.2);
    v51 = v49;
    LOBYTE(v52) = 1;
    Block = nullptr;
    v54 = 0;
    *(_QWORD *)&v64 = 0x3FF0000000000000LL;
    DWORD2(v64) = v66;
    *(_QWORD *)&v46 = 0;
    DWORD2(v46) = dword_180CB9E34;
    sub_180171480(&Block, 8);
    v33 = HIDWORD(v54);
    v34 = SHIDWORD(v54);
    v35 = (char *)Block;
    v36 = (__int128 *)((char *)Block + 16 * SHIDWORD(v54));
    if ( v36 )
      *v36 = v46;
    HIDWORD(v54) = v33 + 2;
    v37 = &v35[16 * v34 + 16];
    if ( v37 )
      *(_OWORD *)v37 = v64;
    sub_180832420(&v48, v34, (unsigned int)dword_180CB9E34);
    v39 = a6;
    v40 = a6 * 0.07;
    a6 = *(float *)&dword_180C96488;
    if ( v40 > 0.0 )
    {
      if ( v40 < 1.0 )
        v41 = (int)(float)(v40 * 255.996);
      else
        LOBYTE(v41) = -1;
    }
    else
    {
      LOBYTE(v41) = 0;
    }
    HIBYTE(a6) = v41;
    sub_180832420(&v48, v38, LODWORD(a6));
    sub_180831B00(a1, &v48);
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a1 + 8) + 96LL))(*(_QWORD *)(a1 + 8)) )
    {
      v42 = (float *)v57;
      while ( v42 != (float *)((char *)v57 + 4 * SHIDWORD(v58)) )
      {
        v43 = *v42;
        if ( *v42 == 100002.0 )
        {
          v42 += 3;
        }
        else
        {
          if ( v43 == 100001.0 || v43 == 100003.0 || v43 == 100004.0 )
          {
            v46 = xmmword_180AE5570;
            v47 = 1065353216;
            (*(void (__fastcall **)(_QWORD, void **, __int128 *))(**(_QWORD **)(a1 + 8) + 184LL))(
              *(_QWORD *)(a1 + 8),
              &v57,
              &v46);
            break;
          }
          ++v42;
        }
      }
    }
    v44 = (float)((float)*((unsigned __int8 *)v17 + 3) / 255.0) * 0.5;
    a6 = *(float *)&dword_180C96488;
    if ( v44 > 0.0 )
    {
      if ( v44 < 1.0 )
        v45 = (int)(float)(v44 * 255.996);
      else
        LOBYTE(v45) = -1;
    }
    else
    {
      LOBYTE(v45) = 0;
    }
    HIBYTE(a6) = v45;
    sub_180831D50(a1, LODWORD(a6));
    v46 = xmmword_180AE5570;
    v47 = 1065353216;
    *(float *)v56 = v39;
    *(_QWORD *)&v56[4] = 0;
    sub_180830CE0(a1, &v57, v56, &v46);
    free(Block);
    HIDWORD(v58) = 0;
    free(v57);
  }
}

