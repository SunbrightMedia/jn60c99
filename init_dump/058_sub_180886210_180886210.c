// sub_180886210  @ 0x180886210  (RVA 0x886210)  floats=14
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE4FC0  dword_180AE4FC0 = 0.20000000298023224
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5054  dword_180AE5054 = 0.699999988079071
//   0x180AE5070  dword_180AE5070 = 0.800000011920929
//   0x180AE5088  dword_180AE5088 = 0.8999999761581421
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5488  dword_180AE5488 = 100005.0
//   0x180AE5570  xmmword_180AE5570 = 1.0

// Hidden C++ exception states: #wind=1
void __fastcall sub_180886210(__int64 a1, __int64 a2, __int64 a3, int a4, int a5, int a6, char a7, char a8, char a9)
{
  int v11; // r10d
  int v12; // edx
  float v13; // xmm2_4
  __int64 v14; // rcx
  _DWORD *v15; // rdx
  __int64 v16; // rdx
  float *v17; // rcx
  char *v18; // rdx
  float v19; // xmm0_4
  void *Block; // [rsp+28h] [rbp-61h] BYREF
  __int64 v21; // [rsp+30h] [rbp-59h]
  __int128 v22; // [rsp+38h] [rbp-51h]
  char v23; // [rsp+48h] [rbp-41h]
  __int128 v24; // [rsp+50h] [rbp-39h] BYREF
  __int64 v25; // [rsp+60h] [rbp-29h]
  __int128 v26; // [rsp+68h] [rbp-21h] BYREF
  __int64 v27; // [rsp+78h] [rbp-11h]
  __int64 v28; // [rsp+80h] [rbp-9h]
  unsigned int v29; // [rsp+F8h] [rbp+6Fh]
  unsigned int v30; // [rsp+F8h] [rbp+6Fh]

  v28 = -2;
  v11 = a4 - 2;
  if ( !a7 )
    v11 = a4;
  v12 = a5;
  if ( !a7 )
    v12 = a5 - 2;
  Block = nullptr;
  v21 = 0;
  v22 = 0;
  v23 = 1;
  switch ( a6 )
  {
    case 0:
      *((float *)&v22 + 1) = (float)v11 * 0.5;
      *(float *)&v22 = *((float *)&v22 + 1);
      *((float *)&v22 + 3) = (float)v12 * 0.2;
      *((float *)&v22 + 2) = *((float *)&v22 + 3);
      sub_180179780(&Block, &unk_180AA33E4);
      goto LABEL_14;
    case 1:
      v13 = (float)v11 * 0.80000001;
      break;
    case 2:
      *((float *)&v22 + 1) = (float)v11 * 0.5;
      *(float *)&v22 = *((float *)&v22 + 1);
      *((float *)&v22 + 3) = (float)v12 * 0.80000001;
      *((float *)&v22 + 2) = *((float *)&v22 + 3);
      sub_180179780(&Block, &unk_180AA33E4);
      goto LABEL_14;
    case 3:
      v13 = (float)v11 * 0.2;
      break;
    default:
      goto LABEL_19;
  }
  *((float *)&v22 + 1) = v13;
  *(float *)&v22 = v13;
  *((float *)&v22 + 3) = (float)v12 * 0.5;
  *((float *)&v22 + 2) = *((float *)&v22 + 3);
  sub_180179780(&Block, &unk_180AA33E4);
LABEL_14:
  sub_18082B140(&Block);
  sub_18082B140(&Block);
  if ( HIDWORD(v21) && (SHIDWORD(v21) <= 0 || *((float *)Block + SHIDWORD(v21) - 1) != 100005.0) )
  {
    sub_1801716F0(&Block, (unsigned int)(HIDWORD(v21) + 1));
    v14 = SHIDWORD(v21);
    ++HIDWORD(v21);
    v15 = (char *)Block + 4 * v14;
    if ( v15 )
      *v15 = 1203982976;
  }
LABEL_19:
  if ( a9 )
  {
    v16 = (unsigned int)dword_180C9648C;
  }
  else
  {
    if ( a8 )
    {
      v29 = dword_180C9648C;
      HIBYTE(v29) = -77;
    }
    else
    {
      v29 = *(_DWORD *)sub_1808D6630(a3, &a9, 16778240, 0);
      HIBYTE(v29) = 127;
    }
    v16 = v29;
  }
  sub_180831D50(a2, v16);
  if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
  {
    v17 = (float *)Block;
    v18 = (char *)Block + 4 * SHIDWORD(v21);
    if ( Block != v18 )
    {
      do
      {
        v19 = *v17;
        if ( *v17 == 100002.0 )
        {
          v17 += 2;
        }
        else if ( v19 == 100001.0 || v19 == 100003.0 || v19 == 100004.0 )
        {
          v24 = xmmword_180AE5570;
          v25 = 1065353216;
          (*(void (__fastcall **)(_QWORD, void **, __int128 *))(**(_QWORD **)(a2 + 8) + 184LL))(
            *(_QWORD *)(a2 + 8),
            &Block,
            &v24);
          break;
        }
        ++v17;
      }
      while ( v17 != (float *)v18 );
    }
  }
  v30 = dword_180C96488;
  HIBYTE(v30) = 127;
  sub_180831D50(a2, v30);
  v26 = xmmword_180AE5570;
  v27 = 1065353216;
  *(_QWORD *)&v24 = 1056964608;
  DWORD2(v24) = 0;
  sub_180830CE0(a2, &Block, &v24, &v26);
  HIDWORD(v21) = 0;
  free(Block);
}

