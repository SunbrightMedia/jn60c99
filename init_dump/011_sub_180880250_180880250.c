// sub_180880250  @ 0x180880250  (RVA 0x880250)  floats=23
// .rdata float constants referenced by this function:
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE4FC0  dword_180AE4FC0 = 0.20000000298023224
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE4FF8  dword_180AE4FF8 = 0.4000000059604645
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5030  dword_180AE5030 = 0.6000000238418579
//   0x180AE5054  dword_180AE5054 = 0.699999988079071
//   0x180AE508C  dword_180AE508C = 0.9090908765792847
//   0x180AE50B4  dword_180AE50B4 = 1.0
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
void __fastcall sub_180880250(__int64 a1, __int64 a2, int a3, __int64 a4, __int64 a5, _BYTE **a6)
{
  int v6; // r15d
  int v10; // eax
  float v11; // xmm0_4
  __m128 v12; // xmm2
  __m128 v13; // xmm2
  __m128 v14; // xmm3
  __m128 v15; // xmm3
  int v16; // edx
  int v17; // r8d
  int v18; // r9d
  int v19; // edx
  int v20; // r8d
  int v21; // r9d
  int v22; // edx
  int v23; // r8d
  int v24; // r9d
  int v25; // eax
  float v26; // xmm2_4
  int v27; // eax
  int v28; // r8d
  int v29; // r9d
  __int64 v30; // rsi
  float *v31; // rdx
  char *v32; // r8
  float v33; // xmm0_4
  unsigned int v34; // [rsp+48h] [rbp-49h] BYREF
  __int64 v35; // [rsp+50h] [rbp-41h]
  __m128 v36; // [rsp+58h] [rbp-39h] BYREF
  void *Block; // [rsp+78h] [rbp-19h] BYREF
  __int64 v38; // [rsp+80h] [rbp-11h]
  __int128 v39; // [rsp+88h] [rbp-9h]
  char v40; // [rsp+98h] [rbp+7h]
  unsigned int v41; // [rsp+108h] [rbp+77h]
  unsigned int v42; // [rsp+108h] [rbp+77h]
  unsigned int v43; // [rsp+108h] [rbp+77h]

  v35 = -2;
  v6 = a4;
  LOBYTE(a4) = 1;
  sub_1808D6630(a5, &v34, 16821505, a4);
  if ( **a6 )
  {
    if ( (*(_BYTE *)(a5 + 169) & 0x10) == 0 && (!*(_QWORD *)(a5 + 24) || (unsigned __int8)sub_1808C7290()) )
    {
      v10 = *(_DWORD *)(a5 + 416);
      if ( v10 == 2 )
      {
        v11 = 0.40000001;
      }
      else if ( v10 )
      {
        v11 = 0.2;
      }
      else
      {
        v11 = 0.1;
      }
      v41 = v34;
      HIBYTE(v41) = (int)(float)(v11 * 255.996);
      sub_180831D50(a2, v41);
      v36.m128_u64[0] = 0;
      v12 = _mm_shuffle_ps(v36, v36, 210);
      v12.m128_f32[0] = (float)*(int *)(a5 + 40);
      v13 = _mm_shuffle_ps(v12, v12, 39);
      v13.m128_f32[0] = (float)*(int *)(a5 + 44);
      v36 = _mm_shuffle_ps(v13, v13, 57);
      sub_180820F90(a2, &v36);
      v36.m128_u64[0] = 0;
      v14 = _mm_shuffle_ps(v36, v36, 210);
      v14.m128_f32[0] = (float)*(int *)(a5 + 40);
      v15 = _mm_shuffle_ps(v14, v14, 39);
      v15.m128_f32[0] = (float)*(int *)(a5 + 44);
      v36 = _mm_shuffle_ps(v15, v15, 57);
      sub_180820E30(a2, &v36);
    }
    sub_180831D50(a2, v34);
    sub_180831A60(a2);
    v36.m128_u64[0] = 4;
    v36.m128_i32[2] = a3 - 8;
    v36.m128_i32[3] = v6;
    sub_180821B50(a2, (_DWORD)a6, (unsigned int)&v36, 36, 1, 0);
  }
  else
  {
    Block = nullptr;
    v38 = 0;
    v39 = 0;
    v40 = 1;
    v36 = (__m128)xmmword_180AE5760;
    sub_18082A520(&Block, &v36);
    sub_18082AC70((unsigned int)&Block, v16, v17, v18, 1096810496);
    sub_18082AC70((unsigned int)&Block, v19, v20, v21, 1101529088);
    sub_18082AC70((unsigned int)&Block, v22, v23, v24, 1101529088);
    v40 = 0;
    v25 = *(_DWORD *)(a5 + 416);
    if ( v25 == 2 )
    {
      v26 = 0.69999999;
    }
    else if ( v25 )
    {
      v26 = 0.5;
    }
    else
    {
      v26 = 0.30000001;
    }
    if ( v26 > 0.0 )
    {
      if ( v26 < 1.0 )
        v27 = (int)(float)(v26 * 255.996);
      else
        LOBYTE(v27) = -1;
    }
    else
    {
      LOBYTE(v27) = 0;
    }
    HIBYTE(v42) = v27;
    LOBYTE(v42) = (int)(float)((float)(unsigned __int8)v34 * 0.90909088);
    BYTE1(v42) = (int)(float)((float)BYTE1(v34) * 0.90909088);
    BYTE2(v42) = (int)(float)((float)BYTE2(v34) * 0.90909088);
    sub_180831D50(a2, v42);
    v30 = sub_180828260((unsigned int)&Block, (unsigned int)&v36, v28, v29, (float)a3 - 4.0, (float)v6 - 4.0, 1, 36);
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
    {
      v31 = (float *)Block;
      v32 = (char *)Block + 4 * SHIDWORD(v38);
      if ( Block != v32 )
      {
        do
        {
          v33 = *v31;
          if ( *v31 == 100002.0 )
          {
            v31 += 2;
          }
          else if ( v33 == 100001.0 || v33 == 100003.0 || v33 == 100004.0 )
          {
            (*(void (__fastcall **)(_QWORD, void **, __int64))(**(_QWORD **)(a2 + 8) + 184LL))(
              *(_QWORD *)(a2 + 8),
              &Block,
              v30);
            break;
          }
          ++v31;
        }
        while ( v31 != (float *)v32 );
      }
    }
    HIDWORD(v38) = 0;
    free(Block);
  }
  if ( qword_180CB8710 == a5 )
  {
    v43 = v34;
    HIBYTE(v43) = 102;
    sub_180831D50(a2, v43);
    sub_180821880(a2, 0, 0, a3, v6, 1);
  }
}

