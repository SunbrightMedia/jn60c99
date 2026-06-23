// sub_180887890 @ 0x180887890 (RVA 0x887890)  float_ops=58

void __fastcall sub_180887890(
        __int64 a1,
        float a2,
        float a3,
        int a4,
        float a5,
        unsigned __int8 *a6,
        float a7,
        float a8,
        char a9,
        char a10,
        char a11,
        char a12)
{
  float v12; // xmm3_4
  float v14; // xmm12_4
  float v15; // xmm13_4
  int v16; // r14d
  char v17; // r8
  char v18; // dl
  char v19; // cl
  char v20; // al
  int v21; // eax
  __int64 v22; // rdx
  char *v23; // r8
  _OWORD *v24; // rcx
  __int128 *v25; // rax
  __int64 v26; // rdx
  __int64 v27; // rdx
  __int64 v28; // rdx
  float *v29; // rcx
  float v30; // xmm0_4
  int v31; // eax
  __int64 v32; // rdx
  char *v33; // r8
  __int128 *v34; // rcx
  char *v35; // rax
  __int64 v36; // rdx
  int v37; // r9d
  __int64 v38; // rcx
  __int64 (__fastcall *v39)(); // rdx
  float *v40; // rcx
  float v41; // xmm0_4
  char v42; // al
  __int64 v43; // rcx
  __int64 (__fastcall *v44)(); // rdx
  float *v45; // rcx
  float v46; // xmm0_4
  float v47; // xmm2_4
  char v48; // r8
  char v49; // dl
  char v50; // cl
  char v51; // al
  char v52; // di
  int v53; // eax
  __int64 v54; // rdx
  char *v55; // r8
  __int128 *v56; // rcx
  char *v57; // rax
  float *v58; // rcx
  float v59; // xmm0_4
  unsigned int v60; // [rsp+68h] [rbp-A0h]
  __int128 v61; // [rsp+70h] [rbp-98h] BYREF
  __int64 v62; // [rsp+80h] [rbp-88h]
  __int128 v63; // [rsp+88h] [rbp-80h]
  float v64; // [rsp+98h] [rbp-70h] BYREF
  float v65; // [rsp+9Ch] [rbp-6Ch]
  float v66; // [rsp+A0h] [rbp-68h]
  float v67; // [rsp+A4h] [rbp-64h]
  char v68; // [rsp+A8h] [rbp-60h]
  void *Block; // [rsp+B0h] [rbp-58h] BYREF
  __int64 v70; // [rsp+B8h] [rbp-50h]
  int v71; // [rsp+C0h] [rbp-48h]
  __int128 v72; // [rsp+C8h] [rbp-40h] BYREF
  void *v73; // [rsp+D8h] [rbp-30h] BYREF
  __int64 v74; // [rsp+E0h] [rbp-28h]
  __int128 v75; // [rsp+E8h] [rbp-20h]
  char v76; // [rsp+F8h] [rbp-10h]
  _DWORD v77[4]; // [rsp+100h] [rbp-8h] BYREF
  char v78; // [rsp+110h] [rbp+8h]
  void *v79; // [rsp+118h] [rbp+10h] BYREF
  __int64 v80; // [rsp+120h] [rbp+18h]
  void *v81; // [rsp+128h] [rbp+20h] BYREF
  __int64 v82; // [rsp+130h] [rbp+28h]
  __int128 v83; // [rsp+138h] [rbp+30h]
  char v84; // [rsp+148h] [rbp+40h]
  __int64 v85; // [rsp+150h] [rbp+48h]
  int v87; // [rsp+250h] [rbp+148h]
  unsigned int v88; // [rsp+250h] [rbp+148h]

  v85 = -2;
  if ( a7 >= v12 || a7 >= a5 )
    return;
  v71 = (int)a2;
  LODWORD(v72) = (int)a3;
  v14 = a8;
  if ( a8 < 0.0 )
    v14 = fminf(a5 * 0.5, v12 * 0.5);
  v15 = (float)(a5 - (float)(v14 + v14)) + (float)(a5 * 0.75);
  v16 = (int)v15;
  v73 = nullptr;
  v74 = 0;
  v75 = 0;
  v76 = 1;
  v17 = !a10 && !a12;
  v18 = !a9 && !a12;
  v19 = !a10 && !a11;
  v20 = !a9 && !a11;
  sub_18082A940((unsigned int)&v73, v18, v17, a4, LODWORD(a5), LODWORD(v14), LODWORD(v14), v20, v19, v18, v17);
  LOBYTE(v63) = (int)(float)((float)*a6 * 0.83333331);
  BYTE1(v63) = (int)(float)((float)a6[1] * 0.83333331);
  BYTE2(v63) = (int)(float)((float)a6[2] * 0.83333331);
  BYTE3(v63) = a6[3];
  v60 = v63;
  v64 = 0.0;
  v65 = a3;
  v66 = 0.0;
  v67 = a3 + a5;
  v68 = 0;
  Block = nullptr;
  v70 = 0;
  *(_QWORD *)&v61 = 0x3FF0000000000000LL;
  DWORD2(v61) = v63;
  *(_QWORD *)&v63 = 0;
  DWORD2(v63) = v60;
  sub_180171480(&Block, 8);
  v21 = HIDWORD(v70);
  v22 = SHIDWORD(v70);
  v23 = (char *)Block;
  v24 = (char *)Block + 16 * SHIDWORD(v70);
  if ( v24 )
    *v24 = v63;
  HIDWORD(v70) = v21 + 2;
  v25 = (__int128 *)&v23[16 * v22 + 16];
  if ( v25 )
    *v25 = v61;
  v60 = *(_DWORD *)a6;
  *(double *)&v63 = (float)((float)HIBYTE(*(_DWORD *)a6) * 0.30000001) + 6.755399441055744e15;
  v26 = 255;
  if ( (int)v63 < 255 )
    v26 = (unsigned __int8)v63;
  HIBYTE(v60) = v26;
  sub_180832420(&v64, v26, v60);
  sub_180832420(&v64, v27, *(unsigned int *)a6);
  v60 = *(_DWORD *)a6;
  *(double *)&v63 = (float)((float)HIBYTE(*(_DWORD *)a6) * 0.30000001) + 6.755399441055744e15;
  v28 = 255;
  if ( (int)v63 < 255 )
    v28 = (unsigned __int8)v63;
  HIBYTE(v60) = v28;
  sub_180832420(&v64, v28, v60);
  sub_180831B00(a1, &v64);
  if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a1 + 8) + 96LL))(*(_QWORD *)(a1 + 8)) )
  {
    v29 = (float *)v73;
    while ( v29 != (float *)((char *)v73 + 4 * SHIDWORD(v74)) )
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
          v61 = xmmword_180AE5570;
          v62 = 1065353216;
          (*(void (__fastcall **)(_QWORD, void **, __int128 *))(**(_QWORD **)(a1 + 8) + 184LL))(
            *(_QWORD *)(a1 + 8),
            &v73,
            &v61);
          break;
        }
        ++v29;
      }
    }
  }
  free(Block);
  LOBYTE(v60) = (int)(float)((float)*a6 * 0.83333331);
  BYTE1(v60) = (int)(float)((float)a6[1] * 0.83333331);
  BYTE2(v60) = (int)(float)((float)a6[2] * 0.83333331);
  HIBYTE(v60) = a6[3];
  v64 = v15 + a2;
  v65 = (float)(a5 * 0.5) + a3;
  v66 = a2;
  v67 = v65;
  v68 = 1;
  Block = nullptr;
  v70 = 0;
  *(_QWORD *)&v63 = 0x3FF0000000000000LL;
  DWORD2(v63) = v60;
  *(_QWORD *)&v61 = 0;
  DWORD2(v61) = dword_180CB9E34;
  sub_180171480(&Block, 8);
  v31 = HIDWORD(v70);
  v32 = SHIDWORD(v70);
  v33 = (char *)Block;
  v34 = (__int128 *)((char *)Block + 16 * SHIDWORD(v70));
  if ( v34 )
    *v34 = v61;
  HIDWORD(v70) = v31 + 2;
  v35 = &v33[16 * v32 + 16];
  if ( v35 )
    *(_OWORD *)v35 = v63;
  sub_180832420(&v64, v32, (unsigned int)dword_180CB9E34);
  LOBYTE(v60) = (int)(float)((float)*a6 * 0.83333331);
  BYTE1(v60) = (int)(float)((float)a6[1] * 0.83333331);
  BYTE2(v60) = (int)(float)((float)a6[2] * 0.83333331);
  HIBYTE(v60) = a6[3];
  *(double *)&v63 = (float)((float)HIBYTE(v60) * 0.30000001) + 6.755399441055744e15;
  v36 = 255;
  if ( (int)v63 < 255 )
    v36 = (unsigned __int8)v63;
  HIBYTE(v60) = v36;
  sub_180832420(&v64, v36, v60);
  if ( !a9 && !a11 && !a12 )
  {
    if ( *(_BYTE *)(a1 + 16) )
    {
      *(_BYTE *)(a1 + 16) = 0;
      v38 = *(_QWORD *)(a1 + 8);
      v39 = *(__int64 (__fastcall **)())(*(_QWORD *)v38 + 104LL);
      if ( v39 == sub_180163CA0 )
        sub_18016CBD0(v38 + 8, v39, sub_180163CA0);
      else
        ((void (__fastcall *)(__int64, __int64 (__fastcall *)(), __int64 (__fastcall *)()))v39)(v38, v39, sub_180163CA0);
    }
    *(_BYTE *)(a1 + 16) = 1;
    sub_180831B00(a1, &v64);
    sub_1808308D0(a1, v71, v72, v16, (int)a5);
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a1 + 8) + 96LL))(*(_QWORD *)(a1 + 8)) )
    {
      v40 = (float *)v73;
      while ( v40 != (float *)((char *)v73 + 4 * SHIDWORD(v74)) )
      {
        v41 = *v40;
        if ( *v40 == 100002.0 )
        {
          v40 += 3;
        }
        else
        {
          if ( v41 == 100001.0 || v41 == 100003.0 || v41 == 100004.0 )
          {
            v61 = xmmword_180AE5570;
            v62 = 1065353216;
            (*(void (__fastcall **)(_QWORD, void **, __int128 *))(**(_QWORD **)(a1 + 8) + 184LL))(
              *(_QWORD *)(a1 + 8),
              &v73,
              &v61);
            break;
          }
          ++v40;
        }
      }
    }
    sub_180822960(a1);
  }
  v42 = a10;
  if ( a10 )
  {
    if ( a11 )
      goto LABEL_82;
  }
  else
  {
    if ( a11 )
      goto LABEL_82;
    if ( !a12 )
    {
      v64 = (float)(a2 + v12) - v15;
      v66 = a2 + v12;
      if ( *(_BYTE *)(a1 + 16) )
      {
        *(_BYTE *)(a1 + 16) = 0;
        v43 = *(_QWORD *)(a1 + 8);
        v44 = *(__int64 (__fastcall **)())(*(_QWORD *)v43 + 104LL);
        if ( v44 == sub_180163CA0 )
          sub_18016CBD0(v43 + 8, v44, sub_180163CA0);
        else
          ((void (__fastcall *)(__int64, __int64 (__fastcall *)(), __int64 (__fastcall *)()))v44)(
            v43,
            v44,
            sub_180163CA0);
      }
      *(_BYTE *)(a1 + 16) = 1;
      sub_180831B00(a1, &v64);
      sub_1808308D0(a1, v71 + (int)v12 - v16, v72, v16 + 2, (int)a5);
      if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a1 + 8) + 96LL))(*(_QWORD *)(a1 + 8)) )
      {
        v45 = (float *)v73;
        while ( v45 != (float *)((char *)v73 + 4 * SHIDWORD(v74)) )
        {
          v46 = *v45;
          if ( *v45 == 100002.0 )
          {
            v45 += 3;
          }
          else
          {
            if ( v46 == 100001.0 || v46 == 100003.0 || v46 == 100004.0 )
            {
              v61 = xmmword_180AE5570;
              v62 = 1065353216;
              (*(void (__fastcall **)(_QWORD, void **, __int128 *))(**(_QWORD **)(a1 + 8) + 184LL))(
                *(_QWORD *)(a1 + 8),
                &v73,
                &v61);
              break;
            }
            ++v45;
          }
        }
      }
      sub_180822960(a1);
      v42 = 0;
    }
  }
  if ( !a9 )
  {
    v47 = v14 * 0.40000001;
    goto LABEL_83;
  }
LABEL_82:
  v47 = v14 * 0.40000001;
LABEL_83:
  v81 = nullptr;
  v82 = 0;
  v83 = 0;
  v84 = 1;
  v48 = !v42 && !a12;
  v49 = !a9 && !a12;
  v50 = !v42 && !a11;
  v51 = !a9 && !a11;
  sub_18082A940((unsigned int)&v81, v49, v48, v37, a5 * 0.40000001, LODWORD(v47), LODWORD(v47), v51, v50, v49, v48);
  v52 = -1;
  LOBYTE(v87) = (int)(float)(255.0 - (float)((float)(255 - *a6) * 0.090909094));
  BYTE1(v87) = (int)(float)(255.0 - (float)((float)(255 - a6[1]) * 0.090909094));
  BYTE2(v87) = (int)(float)(255.0 - (float)((float)(255 - a6[2]) * 0.090909094));
  HIBYTE(v87) = a6[3];
  v77[0] = 0;
  *(float *)&v77[1] = (float)(a5 * 0.059999999) + a3;
  v77[2] = 0;
  *(float *)&v77[3] = (float)(a5 * 0.40000001) + a3;
  v78 = 0;
  v79 = nullptr;
  v80 = 0;
  *(_QWORD *)&v72 = 0x3FF0000000000000LL;
  DWORD2(v72) = 0xFFFFFF;
  *(_QWORD *)&v61 = 0;
  DWORD2(v61) = v87;
  sub_180171480(&v79, 8);
  v53 = HIDWORD(v80);
  v54 = SHIDWORD(v80);
  v55 = (char *)v79;
  v56 = (__int128 *)((char *)v79 + 16 * SHIDWORD(v80));
  if ( v56 )
    *v56 = v61;
  HIDWORD(v80) = v53 + 2;
  v57 = &v55[16 * v54 + 16];
  if ( v57 )
    *(_OWORD *)v57 = v72;
  sub_180822410(a1, v77);
  free(v79);
  if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a1 + 8) + 96LL))(*(_QWORD *)(a1 + 8)) )
  {
    v58 = (float *)v81;
    while ( v58 != (float *)((char *)v81 + 4 * SHIDWORD(v82)) )
    {
      v59 = *v58;
      if ( *v58 == 100002.0 )
      {
        v58 += 3;
      }
      else
      {
        if ( v59 == 100001.0 || v59 == 100003.0 || v59 == 100004.0 )
        {
          v61 = xmmword_180AE5570;
          v62 = 1065353216;
          (*(void (__fastcall **)(_QWORD, void **, __int128 *))(**(_QWORD **)(a1 + 8) + 184LL))(
            *(_QWORD *)(a1 + 8),
            &v81,
            &v61);
          break;
        }
        ++v58;
      }
    }
  }
  HIDWORD(v82) = 0;
  free(v81);
  LOBYTE(v88) = (int)(float)((float)*a6 * 0.71428573);
  BYTE1(v88) = (int)(float)((float)a6[1] * 0.71428573);
  BYTE2(v88) = (int)(float)((float)a6[2] * 0.71428573);
  HIBYTE(v88) = a6[3];
  *(double *)&v72 = (float)((float)HIBYTE(v88) * 1.5) + 6.755399441055744e15;
  if ( (int)v72 < 255 )
    v52 = v72;
  HIBYTE(v88) = v52;
  sub_180831D50(a1, v88);
  v61 = xmmword_180AE5570;
  v62 = 1065353216;
  *(float *)&v72 = a7;
  *(_QWORD *)((char *)&v72 + 4) = 0;
  sub_180830CE0(a1, &v73, &v72, &v61);
  free(Block);
  HIDWORD(v74) = 0;
  free(v73);
}

