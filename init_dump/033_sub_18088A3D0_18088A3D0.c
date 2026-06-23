// sub_18088A3D0  @ 0x18088A3D0  (RVA 0x88A3D0)  floats=20
// .rdata float constants referenced by this function:
//   0x180AE4F94  dword_180AE4F94 = 0.07999999821186066
//   0x180AE4FB8  dword_180AE4FB8 = 0.15000000596046448
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5030  dword_180AE5030 = 0.6000000238418579
//   0x180AE5054  dword_180AE5054 = 0.699999988079071
//   0x180AE51E8  flt_180AE51E8 = 2.0
//   0x180AE52D0  dword_180AE52D0 = 4.0
//   0x180AE5388  dword_180AE5388 = 14.0
//   0x180AE53B4  dword_180AE53B4 = 21.0
//   0x180AE53B8  dword_180AE53B8 = 22.0
//   0x180AE53F0  dword_180AE53F0 = 43.0
//   0x180AE53FC  dword_180AE53FC = 56.0
//   0x180AE5400  dword_180AE5400 = 57.0
//   0x180AE5440  dword_180AE5440 = 255.99600219726562
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5760  xmmword_180AE5760 = 0.0

// Hidden C++ exception states: #wind=1
void __fastcall sub_18088A3D0(__int64 a1, __int64 a2, int a3, __int64 a4, __int64 a5, _BYTE **a6)
{
  int v6; // r14d
  int v10; // eax
  float v11; // xmm0_4
  int v12; // edx
  int v13; // r8d
  int v14; // edx
  int v15; // r8d
  int v16; // r9d
  int v17; // edx
  int v18; // r8d
  int v19; // r9d
  int v20; // edx
  int v21; // r8d
  int v22; // r9d
  int v23; // eax
  float v24; // xmm0_4
  int v25; // r8d
  int v26; // r9d
  __int64 v27; // rsi
  float *v28; // rdx
  char *v29; // r8
  float v30; // xmm0_4
  unsigned int v31; // [rsp+58h] [rbp-49h] BYREF
  __int64 v32; // [rsp+60h] [rbp-41h]
  _OWORD v33[2]; // [rsp+68h] [rbp-39h] BYREF
  void *Block; // [rsp+88h] [rbp-19h] BYREF
  __int64 v35; // [rsp+90h] [rbp-11h]
  __int128 v36; // [rsp+98h] [rbp-9h]
  char v37; // [rsp+A8h] [rbp+7h]
  unsigned int v38; // [rsp+118h] [rbp+77h]
  unsigned int v39; // [rsp+118h] [rbp+77h]
  unsigned int v40; // [rsp+118h] [rbp+77h]

  v32 = -2;
  v6 = a4;
  LOBYTE(a4) = 1;
  sub_1808D6630(a5, &v31, 16821505, a4);
  if ( **a6 )
  {
    if ( (*(_BYTE *)(a5 + 169) & 0x10) == 0 && (!*(_QWORD *)(a5 + 24) || (unsigned __int8)sub_1808C7290()) )
    {
      v10 = *(_DWORD *)(a5 + 416);
      if ( v10 == 2 )
      {
        v11 = 0.30000001;
      }
      else if ( v10 )
      {
        v11 = 0.15000001;
      }
      else
      {
        v11 = 0.079999998;
      }
      v38 = v31;
      HIBYTE(v38) = (int)(float)(v11 * 255.996);
      sub_1808316B0(a2, v38);
      sub_180831C60(a2);
      sub_180889750(a2, v12, v13, a3, v6, 2, (__int64)&dword_180C9648C, (__int64)&dword_180C96488);
    }
    sub_180831D50(a2, v31);
    sub_180831A60(a2);
    *(_QWORD *)&v33[0] = 3;
    DWORD2(v33[0]) = a3 - 6;
    HIDWORD(v33[0]) = v6;
    sub_180821B50(a2, (_DWORD)a6, (unsigned int)v33, 36, 1, 0);
  }
  else
  {
    Block = nullptr;
    v35 = 0;
    v36 = 0;
    v37 = 1;
    v33[0] = xmmword_180AE5760;
    sub_18082A520(&Block, v33);
    sub_18082AC70((unsigned int)&Block, v14, v15, v16, 1096810496);
    sub_18082AC70((unsigned int)&Block, v17, v18, v19, 1101529088);
    sub_18082AC70((unsigned int)&Block, v20, v21, v22, 1101529088);
    v37 = 0;
    v23 = *(_DWORD *)(a5 + 416);
    if ( v23 == 2 )
    {
      v24 = 0.69999999;
    }
    else if ( v23 )
    {
      v24 = 0.5;
    }
    else
    {
      v24 = 0.30000001;
    }
    v39 = v31;
    HIBYTE(v39) = (int)(float)(v24 * 255.996);
    sub_180831D50(a2, v39);
    v27 = sub_180828260((unsigned int)&Block, (unsigned int)v33, v25, v26, (float)a3 - 4.0, (float)v6 - 4.0, 1, 36);
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
    {
      v28 = (float *)Block;
      v29 = (char *)Block + 4 * SHIDWORD(v35);
      if ( Block != v29 )
      {
        do
        {
          v30 = *v28;
          if ( *v28 == 100002.0 )
          {
            v28 += 2;
          }
          else if ( v30 == 100001.0 || v30 == 100003.0 || v30 == 100004.0 )
          {
            (*(void (__fastcall **)(_QWORD, void **, __int64))(**(_QWORD **)(a2 + 8) + 184LL))(
              *(_QWORD *)(a2 + 8),
              &Block,
              v27);
            break;
          }
          ++v28;
        }
        while ( v28 != (float *)v29 );
      }
    }
    HIDWORD(v35) = 0;
    free(Block);
  }
  if ( qword_180CB8710 == a5 )
  {
    v40 = v31;
    HIBYTE(v40) = 102;
    sub_180831D50(a2, v40);
    sub_180821880(a2, 0, 0, a3, v6, 1);
  }
}

