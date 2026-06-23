// sub_180881BA0  @ 0x180881BA0  (RVA 0x881BA0)  floats=14
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE4FD0  dword_180AE4FD0 = 0.25
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE52D0  dword_180AE52D0 = 4.0
//   0x180AE5440  dword_180AE5440 = 255.99600219726562
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5488  dword_180AE5488 = 100005.0
//   0x180AE54F8  dword_180AE54F8 = -2.0
//   0x180AE57C0  xmmword_180AE57C0 = -0.0

// Hidden C++ exception states: #wind=1
void __fastcall sub_180881BA0(__int64 a1, __int64 a2, __int64 a3, int a4, unsigned int a5, char a6)
{
  float v8; // xmm6_4
  __int64 v9; // rcx
  _DWORD *v10; // rdx
  int v11; // eax
  int v12; // r8d
  int v13; // r9d
  float *v14; // rcx
  char *v15; // rdx
  float v16; // xmm0_4
  _BYTE v17[24]; // [rsp+50h] [rbp-41h] BYREF
  void *Block; // [rsp+68h] [rbp-29h] BYREF
  __int64 v19; // [rsp+70h] [rbp-21h]
  __int64 v20; // [rsp+78h] [rbp-19h]
  __int64 v21; // [rsp+80h] [rbp-11h]
  char v22; // [rsp+88h] [rbp-9h]
  int v23; // [rsp+100h] [rbp+6Fh] BYREF

  v23 = a4;
  Block = nullptr;
  v19 = 0;
  v22 = 1;
  v8 = 0.5;
  v20 = 0;
  v21 = 0;
  sub_180179780(&Block, &unk_180AA33E4);
  sub_18082B140(&Block);
  sub_18082B140(&Block);
  if ( HIDWORD(v19) && (SHIDWORD(v19) <= 0 || *((float *)Block + SHIDWORD(v19) - 1) != 100005.0) )
  {
    sub_1801716F0(&Block, (unsigned int)(HIDWORD(v19) + 1));
    v9 = SHIDWORD(v19);
    ++HIDWORD(v19);
    v10 = (char *)Block + 4 * v9;
    if ( v10 )
      *v10 = 1203982976;
  }
  if ( !a6 )
    v8 = 0.30000001;
  a5 = *(_DWORD *)sub_180832B80(&v23, &a6);
  if ( v8 > 0.0 )
  {
    if ( v8 < 1.0 )
      v11 = (int)(float)(v8 * 255.996);
    else
      LOBYTE(v11) = -1;
  }
  else
  {
    LOBYTE(v11) = 0;
  }
  HIBYTE(a5) = v11;
  sub_180831D50(a2, a5);
  ((void (__fastcall *)(_DWORD, _DWORD, _DWORD, _DWORD, _DWORD, _DWORD, char, _DWORD))sub_180828260)(
    (unsigned int)&Block,
    (unsigned int)v17,
    v12,
    v13,
    fmaxf(*(float *)(a3 + 8) - 4.0, 0.0),
    fmaxf(
      (float)((float)-(float)(*(float *)(a3 + 12) * 0.25) - (float)(*(float *)(a3 + 12) * 0.25)) + *(float *)(a3 + 12),
      0.0),
    1,
    36);
  if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
  {
    v14 = (float *)Block;
    v15 = (char *)Block + 4 * SHIDWORD(v19);
    if ( Block != v15 )
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
          (*(void (__fastcall **)(_QWORD, void **, _BYTE *))(**(_QWORD **)(a2 + 8) + 184LL))(
            *(_QWORD *)(a2 + 8),
            &Block,
            v17);
          break;
        }
        ++v14;
      }
      while ( v14 != (float *)v15 );
    }
  }
  HIDWORD(v19) = 0;
  free(Block);
}

