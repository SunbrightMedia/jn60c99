// sub_180886DD0  @ 0x180886DD0  (RVA 0x886DD0)  floats=21
// .rdata float constants referenced by this function:
//   0x180AE4F88  dword_180AE4F88 = 0.06800000369548798
//   0x180AE4FC8  dword_180AE4FC8 = 0.2409999966621399
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE4FF8  dword_180AE4FF8 = 0.4000000059604645
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5030  dword_180AE5030 = 0.6000000238418579
//   0x180AE5050  dword_180AE5050 = 0.6909999847412109
//   0x180AE505C  dword_180AE505C = 0.7142857313156128
//   0x180AE508C  dword_180AE508C = 0.9090908765792847
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE5100  dword_180AE5100 = 1.399999976158142
//   0x180AE51E8  flt_180AE51E8 = 2.0
//   0x180AE52D0  dword_180AE52D0 = 4.0
//   0x180AE5428  qword_180AE5428 = 0.0
//   0x180AE543C  dword_180AE543C = 255.0
//   0x180AE5440  dword_180AE5440 = 255.99600219726562
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5570  xmmword_180AE5570 = 1.0

// Hidden C++ exception states: #wind=1
void __fastcall sub_180886DD0(__int64 a1, __int64 a2, __int64 a3, _DWORD *a4, char a5, char a6)
{
  float v8; // xmm4_4
  float v9; // xmm6_4
  double v10; // rcx
  double v11; // rax
  int v12; // xmm8_4
  int v13; // edx
  int v14; // r8d
  int v15; // r9d
  float v16; // xmm0_4
  int v17; // ebx
  unsigned int v18; // ebx
  float *v19; // rcx
  char *v20; // rdx
  float v21; // xmm0_4
  __int16 v22; // r15
  __int16 v23; // r14
  float v24; // xmm0_4
  int v25; // eax
  unsigned int v26; // edx
  int v27; // edi
  int v28; // r9d
  int v29; // eax
  __int128 v30; // [rsp+68h] [rbp-79h] BYREF
  __int64 v31; // [rsp+78h] [rbp-69h]
  void *Block; // [rsp+80h] [rbp-61h] BYREF
  __int64 v33; // [rsp+88h] [rbp-59h]
  __int128 v34; // [rsp+90h] [rbp-51h]
  char v35; // [rsp+A0h] [rbp-41h]
  __int128 v36; // [rsp+A8h] [rbp-39h] BYREF
  __int64 v37; // [rsp+B8h] [rbp-29h]
  __int64 v38; // [rsp+C0h] [rbp-21h]
  double v39; // [rsp+140h] [rbp+5Fh] BYREF
  double v40; // [rsp+148h] [rbp+67h]

  v38 = -2;
  v8 = (float)*(int *)(a3 + 44);
  v9 = 0.40000001;
  v40 = (float)(v8 * 0.40000001) + 6.755399441055744e15;
  v39 = (float)((float)*(int *)(a3 + 40) * 0.40000001) + 6.755399441055744e15;
  v10 = v39;
  v11 = v40;
  if ( SLODWORD(v11) < SLODWORD(v39) )
    LODWORD(v10) = LODWORD(v11);
  Block = nullptr;
  v33 = 0;
  v34 = 0;
  v35 = 1;
  v12 = 0x40000000;
  ((void (__fastcall *)(_DWORD, _DWORD, _DWORD, _DWORD, _DWORD, _DWORD, _DWORD, char, char, char, char))sub_18082A940)(
    (unsigned int)&Block,
    a2,
    a3,
    (_DWORD)a4,
    v8 - 4.0,
    (float)SLODWORD(v10),
    (float)SLODWORD(v10),
    1,
    1,
    1,
    1);
  sub_180157460(&v30, (unsigned int)*a4);
  sub_1801575F0((unsigned int)&v39, v13, v14, v15, HIBYTE(*a4));
  if ( !a5 )
  {
    v18 = LODWORD(v39);
    goto LABEL_11;
  }
  if ( a6 )
  {
    LOBYTE(v40) = (int)(float)(255.0 - (float)((float)(255 - LOBYTE(v39)) * 0.71428573));
    BYTE1(v40) = (int)(float)(255.0 - (float)((float)(255 - BYTE1(v39)) * 0.71428573));
    v16 = 255.0 - (float)((float)(255 - BYTE2(v39)) * 0.71428573);
  }
  else
  {
    v17 = LODWORD(v39);
    if ( *(float *)(sub_180157460(&v30, LODWORD(v39)) + 8) <= 0.5 )
    {
      LOBYTE(v39) = (int)(float)(255.0 - (float)((float)(255 - (unsigned __int8)v17) * 0.90909088));
      BYTE1(v39) = (int)(float)(255.0 - (float)((float)(255 - BYTE1(v17)) * 0.90909088));
      BYTE2(v39) = (int)(float)(255.0 - (float)((float)(255 - BYTE2(v17)) * 0.90909088));
      BYTE3(v39) = HIBYTE(v17);
      v18 = LODWORD(v39);
      goto LABEL_11;
    }
    LOBYTE(v40) = (int)(float)((float)(unsigned __int8)v17 * 0.90909088);
    BYTE1(v40) = (int)(float)((float)BYTE1(v39) * 0.90909088);
    v16 = (float)BYTE2(v39) * 0.90909088;
  }
  BYTE2(v40) = (int)v16;
  BYTE3(v40) = BYTE3(v39);
  v18 = LODWORD(v40);
  LODWORD(v39) = LODWORD(v40);
LABEL_11:
  sub_180831D50(a2, v18);
  if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
  {
    v19 = (float *)Block;
    v20 = (char *)Block + 4 * SHIDWORD(v33);
    if ( Block != v20 )
    {
      do
      {
        v21 = *v19;
        if ( *v19 == 100002.0 )
        {
          v19 += 2;
        }
        else if ( v21 == 100001.0 || v21 == 100003.0 || v21 == 100004.0 )
        {
          v30 = xmmword_180AE5570;
          v31 = 1065353216;
          (*(void (__fastcall **)(_QWORD, void **, __int128 *))(**(_QWORD **)(a2 + 8) + 184LL))(
            *(_QWORD *)(a2 + 8),
            &Block,
            &v30);
          break;
        }
        ++v19;
      }
      while ( v19 != (float *)v20 );
    }
  }
  if ( a5 )
    v9 = 0.60000002;
  v22 = BYTE2(v39);
  v23 = BYTE1(v39);
  v24 = sqrtf(
          (float)((float)((float)((float)((float)BYTE1(v39) / 255.0) * (float)((float)BYTE1(v39) / 255.0)) * 0.69099998)
                + (float)((float)((float)((float)BYTE2(v39) / 255.0) * (float)((float)BYTE2(v39) / 255.0)) * 0.241))
        + (float)((float)((float)((float)(unsigned __int8)v18 / 255.0) * (float)((float)(unsigned __int8)v18 / 255.0))
                * 0.068000004));
  v25 = dword_180C9648C;
  if ( v24 >= 0.5 )
    v25 = dword_180C96488;
  LODWORD(v40) = v25;
  BYTE3(v40) = -1;
  if ( BYTE3(v39) )
  {
    v26 = 255 - HIBYTE(LODWORD(v40));
    v27 = 255 - ((int)(v26 * (255 - BYTE3(v39))) >> 8);
    if ( v27 > 0 )
    {
      v28 = (int)(BYTE3(v39) * v26) / v27;
      LOBYTE(v39) = LOBYTE(v40) + ((unsigned __int16)(v28 * ((unsigned __int8)v18 - LOBYTE(v40))) >> 8);
      BYTE1(v39) = BYTE1(v40) + ((unsigned __int16)(v28 * (v23 - BYTE1(v40))) >> 8);
      BYTE2(v39) = BYTE2(v40) + ((unsigned __int16)(v28 * (v22 - BYTE2(v40))) >> 8);
      BYTE3(v39) = -1 - ((unsigned __int16)(v26 * (255 - BYTE3(v39))) >> 8);
      v18 = LODWORD(v39);
    }
  }
  else
  {
    v18 = LODWORD(v40);
  }
  LODWORD(v39) = v18;
  if ( v9 > 0.0 )
  {
    if ( v9 < 1.0 )
      v29 = (int)(float)(v9 * 255.996);
    else
      LOBYTE(v29) = -1;
  }
  else
  {
    LOBYTE(v29) = 0;
  }
  BYTE3(v39) = v29;
  sub_180831D50(a2, LODWORD(v39));
  v36 = xmmword_180AE5570;
  v37 = 1065353216;
  if ( !a5 )
    v12 = 1068708659;
  LODWORD(v30) = v12;
  *(_QWORD *)((char *)&v30 + 4) = 0;
  sub_180830CE0(a2, &Block, &v30, &v36);
  HIDWORD(v33) = 0;
  free(Block);
}

