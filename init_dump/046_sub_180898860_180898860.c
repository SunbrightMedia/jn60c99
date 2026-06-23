// sub_180898860  @ 0x180898860  (RVA 0x898860)  floats=16
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AA34DC  unk_180AA34DC = 100001.0
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE4FC0  dword_180AE4FC0 = 0.20000000298023224
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5054  dword_180AE5054 = 0.699999988079071
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE50C4  dword_180AE50C4 = 1.100000023841858
//   0x180AE50F8  dword_180AE50F8 = 1.2999999523162842
//   0x180AE5110  dword_180AE5110 = 1.5
//   0x180AE5240  dword_180AE5240 = 2.5
//   0x180AE5270  dword_180AE5270 = 3.0
//   0x180AE5310  dword_180AE5310 = 6.0
//   0x180AE5354  dword_180AE5354 = 9.0
//   0x180AE5428  qword_180AE5428 = 0.0

// Hidden C++ exception states: #wind=1
void __fastcall sub_180898860(
        __int64 a1,
        __int64 a2,
        __int64 a3,
        double a4,
        float a5,
        float a6,
        float a7,
        char a8,
        unsigned int a9,
        char a10,
        unsigned int a11)
{
  float v13; // xmm11_4
  double v14; // xmm7_8
  char v15; // r14
  float v16; // xmm8_4
  float v17; // xmm9_4
  char v18; // dl
  char v19; // ebx^3
  int v20; // edx
  int v21; // r8d
  int v22; // r9d
  float v23; // xmm9_4
  unsigned int *v24; // rax
  _BYTE v25[12]; // [rsp+38h] [rbp-B1h] BYREF
  __int64 v26; // [rsp+48h] [rbp-A1h]
  float v27[6]; // [rsp+50h] [rbp-99h] BYREF
  void *Block; // [rsp+68h] [rbp-81h] BYREF
  __int64 v29; // [rsp+70h] [rbp-79h]
  __int64 v30; // [rsp+78h] [rbp-71h]
  __int64 v31; // [rsp+80h] [rbp-69h]
  char v32; // [rsp+88h] [rbp-61h]

  v26 = -2;
  v13 = a6;
  *(_QWORD *)&v14 = LODWORD(a6);
  *(float *)&v14 = a6 * 0.69999999;
  v15 = a9;
  if ( (_BYTE)a9 )
  {
    if ( (_BYTE)a11 || a10 )
    {
      v16 = 1.1;
      v17 = 1.0;
    }
    else
    {
      v16 = 0.5;
      v17 = 1.0;
    }
  }
  else
  {
    v16 = 0.30000001;
    v17 = 0.5;
  }
  a9 = *(_DWORD *)sub_1808D6630(a3, &a6, 16777472, 0);
  *(double *)v25 = (float)((float)HIBYTE(a9) * v17) + 6.755399441055744e15;
  v18 = -1;
  if ( *(int *)v25 < 255 )
    v18 = v25[0];
  HIBYTE(a9) = v18;
  v19 = v18;
  sub_180157460(v25, a9);
  sub_1801575F0((unsigned int)&a9, v20, v21, v22, v19);
  if ( (_BYTE)a11 || a10 )
    sub_180832B80(&a9, &a11);
  else
    a11 = a9;
  v23 = a7;
  sub_180888CD0(a2, a4, (float)((float)(a7 - *(float *)&v14) * 0.5) + a5, v14, &a11, v16);
  if ( a8 )
  {
    Block = nullptr;
    v29 = 0;
    v32 = 1;
    v30 = 0x3FC000003FC00000LL;
    v31 = 0x4040000040400000LL;
    sub_180179780(&Block, &unk_180AA33E4);
    if ( !HIDWORD(v29) )
    {
      v30 = 0;
      v31 = 0;
      sub_180179780(&Block, &unk_180AA33E4);
    }
    sub_180179780(&Block, &unk_180AA34DC);
    if ( *(float *)&v30 <= 3.0 )
    {
      if ( *((float *)&v30 + 1) < 3.0 )
        HIDWORD(v30) = 1077936128;
    }
    else
    {
      LODWORD(v30) = 1077936128;
    }
    if ( *(float *)&v31 <= 6.0 )
    {
      if ( *((float *)&v31 + 1) < 6.0 )
        HIDWORD(v31) = 1086324736;
    }
    else
    {
      LODWORD(v31) = 1086324736;
    }
    if ( !HIDWORD(v29) )
    {
      v30 = 0;
      v31 = 0;
      sub_180179780(&Block, &unk_180AA33E4);
    }
    sub_180179780(&Block, &unk_180AA34DC);
    if ( *(float *)&v30 <= 6.0 )
    {
      if ( *((float *)&v30 + 1) < 6.0 )
        HIDWORD(v30) = 1086324736;
    }
    else
    {
      LODWORD(v30) = 1086324736;
    }
    if ( *(float *)&v31 <= 0.0 )
    {
      if ( *((float *)&v31 + 1) < 0.0 )
        HIDWORD(v31) = 0;
    }
    else
    {
      LODWORD(v31) = 0;
    }
    v24 = (unsigned int *)sub_1808D6630(a3, &a11, 16803075 - (unsigned int)(v15 != 0), 0);
    sub_180831D50(a2, *v24);
    v27[0] = v13 / 9.0;
    v27[1] = 0.0;
    v27[2] = *(float *)&a4 + 0.0;
    v27[3] = 0.0;
    v27[4] = v23 / 9.0;
    v27[5] = a5 + 0.0;
    *(_DWORD *)v25 = 1075838976;
    *(_QWORD *)&v25[4] = 0;
    sub_180830CE0(a2, &Block, v25, v27);
    HIDWORD(v29) = 0;
    free(Block);
  }
}

