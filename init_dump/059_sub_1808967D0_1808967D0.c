// sub_1808967D0  @ 0x1808967D0  (RVA 0x8967D0)  floats=14
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
void __fastcall sub_1808967D0(
        __int64 a1,
        __int64 a2,
        __int64 a3,
        int a4,
        int a5,
        int a6,
        int a7,
        int a8,
        unsigned int a9)
{
  float v11; // xmm2_4
  __int64 v12; // rcx
  _DWORD *v13; // rdx
  __int64 v14; // rax
  unsigned int *v15; // rax
  float *v16; // rcx
  char *v17; // rdx
  float v18; // xmm0_4
  void *Block; // [rsp+28h] [rbp-61h] BYREF
  __int64 v20; // [rsp+30h] [rbp-59h]
  __int128 v21; // [rsp+38h] [rbp-51h]
  char v22; // [rsp+48h] [rbp-41h]
  __int128 v23; // [rsp+50h] [rbp-39h] BYREF
  __int64 v24; // [rsp+60h] [rbp-29h]
  __int128 v25; // [rsp+68h] [rbp-21h] BYREF
  __int64 v26; // [rsp+78h] [rbp-11h]
  __int64 v27; // [rsp+80h] [rbp-9h]

  v27 = -2;
  Block = nullptr;
  v20 = 0;
  v21 = 0;
  v22 = 1;
  switch ( a6 )
  {
    case 0:
      *((float *)&v21 + 1) = (float)a4 * 0.5;
      *(float *)&v21 = *((float *)&v21 + 1);
      *((float *)&v21 + 3) = (float)a5 * 0.2;
      *((float *)&v21 + 2) = *((float *)&v21 + 3);
      sub_180179780(&Block, &unk_180AA33E4);
      goto LABEL_10;
    case 1:
      v11 = (float)a4 * 0.80000001;
      break;
    case 2:
      *((float *)&v21 + 1) = (float)a4 * 0.5;
      *(float *)&v21 = *((float *)&v21 + 1);
      *((float *)&v21 + 3) = (float)a5 * 0.80000001;
      *((float *)&v21 + 2) = *((float *)&v21 + 3);
      sub_180179780(&Block, &unk_180AA33E4);
      goto LABEL_10;
    case 3:
      v11 = (float)a4 * 0.2;
      break;
    default:
      goto LABEL_15;
  }
  *((float *)&v21 + 1) = v11;
  *(float *)&v21 = v11;
  *((float *)&v21 + 3) = (float)a5 * 0.5;
  *((float *)&v21 + 2) = *((float *)&v21 + 3);
  sub_180179780(&Block, &unk_180AA33E4);
LABEL_10:
  sub_18082B140(&Block);
  sub_18082B140(&Block);
  if ( HIDWORD(v20) && (SHIDWORD(v20) <= 0 || *((float *)Block + SHIDWORD(v20) - 1) != 100005.0) )
  {
    sub_1801716F0(&Block, (unsigned int)(HIDWORD(v20) + 1));
    v12 = SHIDWORD(v20);
    ++HIDWORD(v20);
    v13 = (char *)Block + 4 * v12;
    if ( v13 )
      *v13 = 1203982976;
  }
LABEL_15:
  if ( (_BYTE)a9 )
  {
    v14 = sub_1808D6630(a3, &a9, 16778240, 0);
    v15 = (unsigned int *)sub_180832B80(v14, &a6);
  }
  else
  {
    v15 = (unsigned int *)sub_1808D6630(a3, &a9, 16778240, 0);
  }
  sub_180831D50(a2, *v15);
  if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
  {
    v16 = (float *)Block;
    v17 = (char *)Block + 4 * SHIDWORD(v20);
    if ( Block != v17 )
    {
      do
      {
        v18 = *v16;
        if ( *v16 == 100002.0 )
        {
          v16 += 2;
        }
        else if ( v18 == 100001.0 || v18 == 100003.0 || v18 == 100004.0 )
        {
          v23 = xmmword_180AE5570;
          v24 = 1065353216;
          (*(void (__fastcall **)(_QWORD, void **, __int128 *))(**(_QWORD **)(a2 + 8) + 184LL))(
            *(_QWORD *)(a2 + 8),
            &Block,
            &v23);
          break;
        }
        ++v16;
      }
      while ( v16 != (float *)v17 );
    }
  }
  a9 = 0x80000000;
  sub_180831D50(a2, 0x80000000LL);
  v25 = xmmword_180AE5570;
  v26 = 1065353216;
  *(_QWORD *)&v23 = 1056964608;
  DWORD2(v23) = 0;
  sub_180830CE0(a2, &Block, &v23, &v25);
  HIDWORD(v20) = 0;
  free(Block);
}

