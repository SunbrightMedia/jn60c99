// sub_1808869D0  @ 0x1808869D0  (RVA 0x8869D0)  floats=17
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AA34DC  unk_180AA34DC = 100001.0
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE5088  dword_180AE5088 = 0.8999999761581421
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE5110  dword_180AE5110 = 1.5
//   0x180AE51E8  flt_180AE51E8 = 2.0
//   0x180AE5240  dword_180AE5240 = 2.5
//   0x180AE5270  dword_180AE5270 = 3.0
//   0x180AE5310  dword_180AE5310 = 6.0
//   0x180AE5354  dword_180AE5354 = 9.0
//   0x180AE5440  dword_180AE5440 = 255.99600219726562
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0

// Hidden C++ exception states: #wind=2
void __fastcall sub_1808869D0(
        __int64 a1,
        __int64 a2,
        int a3,
        int a4,
        float a5,
        float a6,
        float a7,
        char a8,
        char a9,
        int a10,
        char a11)
{
  float v11; // xmm3_4
  float v13; // xmm0_4
  float *v14; // rcx
  char *v15; // rdx
  float v16; // xmm0_4
  __int64 v17; // rdx
  void *Block; // [rsp+68h] [rbp-A0h] BYREF
  __int64 v19; // [rsp+70h] [rbp-98h]
  __int64 v20; // [rsp+78h] [rbp-90h]
  __int64 v21; // [rsp+80h] [rbp-88h]
  char v22; // [rsp+88h] [rbp-80h]
  int v23; // [rsp+90h] [rbp-78h] BYREF
  __int64 v24; // [rsp+94h] [rbp-74h]
  float v25[6]; // [rsp+A0h] [rbp-68h] BYREF
  void *v26; // [rsp+B8h] [rbp-50h] BYREF
  __int64 v27; // [rsp+C0h] [rbp-48h]
  __int128 v28; // [rsp+C8h] [rbp-40h]
  char v29; // [rsp+D8h] [rbp-30h]
  __int64 v30; // [rsp+E0h] [rbp-28h]
  unsigned int v31; // [rsp+140h] [rbp+38h]
  unsigned int v32; // [rsp+158h] [rbp+50h]

  v30 = -2;
  v26 = nullptr;
  v27 = 0;
  v28 = 0;
  v29 = 1;
  sub_18082A940((unsigned int)&v26, a2, a3, a4, 1086324736, 1065353216, 1065353216, 1, 1, 1, 1);
  if ( a9 )
  {
    v31 = dword_180C96480;
    if ( a11 )
      v13 = 0.30000001;
    else
      v13 = 0.1;
    HIBYTE(v31) = (int)(float)(v13 * 255.996);
  }
  else
  {
    v31 = dword_180C96490;
    HIBYTE(v31) = 25;
  }
  sub_180831D50(a2, v31);
  v25[0] = a6 / 9.0;
  v25[1] = 0.0;
  v25[2] = v11 + 0.0;
  v25[3] = 0.0;
  v25[4] = a7 / 9.0;
  v25[5] = a5 + 0.0;
  if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
  {
    v14 = (float *)v26;
    v15 = (char *)v26 + 4 * SHIDWORD(v27);
    if ( v26 != v15 )
    {
      do
      {
        v16 = *v14;
        if ( *v14 == 100002.0 )
        {
          v14 += 2;
        }
        else if ( v16 == 100001.0 || v16 == 100003.0 || v16 == 100004.0 )
        {
          (*(void (__fastcall **)(_QWORD, void **, float *))(**(_QWORD **)(a2 + 8) + 184LL))(
            *(_QWORD *)(a2 + 8),
            &v26,
            v25);
          break;
        }
        ++v14;
      }
      while ( v14 != (float *)v15 );
    }
  }
  v32 = dword_180C96488;
  HIBYTE(v32) = -103;
  sub_180831D50(a2, v32);
  v23 = 1063675494;
  v24 = 0;
  sub_180830CE0(a2, &v26, &v23, v25);
  if ( a8 )
  {
    Block = nullptr;
    v19 = 0;
    v22 = 1;
    v20 = 0x3FC000003FC00000LL;
    v21 = 0x4040000040400000LL;
    sub_180179780(&Block, &unk_180AA33E4);
    if ( !HIDWORD(v19) )
    {
      v20 = 0;
      v21 = 0;
      sub_180179780(&Block, &unk_180AA33E4);
    }
    sub_180179780(&Block, &unk_180AA34DC);
    if ( *(float *)&v20 <= 3.0 )
    {
      if ( *((float *)&v20 + 1) < 3.0 )
        HIDWORD(v20) = 1077936128;
    }
    else
    {
      LODWORD(v20) = 1077936128;
    }
    if ( *(float *)&v21 <= 6.0 )
    {
      if ( *((float *)&v21 + 1) < 6.0 )
        HIDWORD(v21) = 1086324736;
    }
    else
    {
      LODWORD(v21) = 1086324736;
    }
    if ( !HIDWORD(v19) )
    {
      v20 = 0;
      v21 = 0;
      sub_180179780(&Block, &unk_180AA33E4);
    }
    sub_180179780(&Block, &unk_180AA34DC);
    if ( *(float *)&v20 <= 6.0 )
    {
      if ( *((float *)&v20 + 1) < 6.0 )
        HIDWORD(v20) = 1086324736;
    }
    else
    {
      LODWORD(v20) = 1086324736;
    }
    if ( *(float *)&v21 <= 0.0 )
    {
      if ( *((float *)&v21 + 1) < 0.0 )
        HIDWORD(v21) = 0;
    }
    else
    {
      LODWORD(v21) = 0;
    }
    v17 = (unsigned int)dword_180C96484;
    if ( a9 )
      v17 = (unsigned int)dword_180C96488;
    sub_180831D50(a2, v17);
    v23 = 1075838976;
    v24 = 0;
    sub_180830CE0(a2, &Block, &v23, v25);
    HIDWORD(v19) = 0;
    free(Block);
  }
  HIDWORD(v27) = 0;
  free(v26);
}

