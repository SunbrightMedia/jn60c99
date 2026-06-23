// sub_1808855F0  @ 0x1808855F0  (RVA 0x8855F0)  floats=15
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE4FB4  dword_180AE4FB4 = 0.1499999761581421
//   0x180AE4FC0  dword_180AE4FC0 = 0.20000000298023224
//   0x180AE5008  dword_180AE5008 = 0.44999998807907104
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5024  dword_180AE5024 = 0.550000011920929
//   0x180AE5070  dword_180AE5070 = 0.800000011920929
//   0x180AE5084  dword_180AE5084 = 0.8500000238418579
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5488  dword_180AE5488 = 100005.0
//   0x180AE5570  xmmword_180AE5570 = 1.0

// Hidden C++ exception states: #wind=1
void __fastcall sub_1808855F0(
        __int64 a1,
        __int64 a2,
        int a3,
        int a4,
        char a5,
        int a6,
        int a7,
        int a8,
        int a9,
        __int64 a10)
{
  __int64 v13; // r15
  unsigned int *v14; // rax
  __int64 v15; // r8
  unsigned int v16; // esi
  unsigned int *v17; // rax
  int v18; // r12d
  int v19; // r13d
  unsigned int *v20; // rax
  __m128 v21; // xmm3
  __m128 v22; // xmm3
  __m128 v23; // xmm3
  __int64 v24; // rdx
  __int64 v25; // rcx
  float v26; // xmm7_4
  float v27; // xmm8_4
  int v28; // edx
  __int64 v29; // rax
  _DWORD *v30; // r8
  float v31; // xmm7_4
  __int64 v32; // rcx
  _DWORD *v33; // r9
  unsigned int *v34; // rax
  float *v35; // rcx
  char *v36; // rdx
  float v37; // xmm0_4
  __m128 v38; // [rsp+38h] [rbp-A9h] BYREF
  __int64 v39; // [rsp+48h] [rbp-99h]
  void *Block; // [rsp+58h] [rbp-89h] BYREF
  __int64 v41; // [rsp+60h] [rbp-81h]
  float v42; // [rsp+68h] [rbp-79h]
  float v43; // [rsp+6Ch] [rbp-75h]
  float v44; // [rsp+70h] [rbp-71h]
  float v45; // [rsp+74h] [rbp-6Dh]
  char v46; // [rsp+78h] [rbp-69h]
  char v47; // [rsp+128h] [rbp+47h] BYREF

  v13 = a10;
  v14 = (unsigned int *)sub_1808D6630(a10, &v47, 16780032, 0);
  sub_1808316B0(a2, *v14);
  v15 = 16780032;
  v16 = 16780544;
  if ( a5 )
    v15 = 16780544;
  v17 = (unsigned int *)sub_1808D6630(v13, &v47, v15, 0);
  sub_180831D50(a2, *v17);
  v18 = a6;
  v38.m128_u64[0] = __PAIR64__(a7, a6);
  v19 = a7;
  v38.m128_u64[1] = __PAIR64__(a9, a8);
  (*(void (__fastcall **)(_QWORD, __m128 *, _QWORD))(**(_QWORD **)(a2 + 8) + 168LL))(*(_QWORD *)(a2 + 8), &v38, 0);
  v20 = (unsigned int *)sub_1808D6630(v13, &a6, 16780288, 0);
  sub_180831D50(a2, *v20);
  v38.m128_u64[0] = 0;
  v38.m128_u64[1] = __PAIR64__(a4, a3);
  v21 = _mm_shuffle_ps(v38, v38, 225);
  v21.m128_f32[0] = (float)0;
  v22 = _mm_shuffle_ps(v21, v21, 198);
  v22.m128_f32[0] = (float)a3;
  v23 = _mm_shuffle_ps(v22, v22, 39);
  v23.m128_f32[0] = (float)a4;
  v38 = _mm_shuffle_ps(v23, v23, 57);
  sub_180821540(a2, &v38);
  if ( (*(_BYTE *)(v13 + 169) & 0x10) != 0 )
    return;
  v25 = *(_QWORD *)(v13 + 24);
  if ( v25 )
  {
    if ( !(unsigned __int8)sub_1808C7290(v25, v24) )
      return;
  }
  Block = nullptr;
  v41 = 0;
  v46 = 1;
  v26 = (float)a9;
  v27 = (float)((float)a8 * 0.5) + (float)v18;
  v43 = v27;
  v42 = v27;
  v45 = (float)((float)a9 * 0.14999998) + (float)v19;
  v44 = v45;
  sub_180179780(&Block, &unk_180AA33E4);
  sub_18082B140(&Block);
  sub_18082B140(&Block);
  v28 = HIDWORD(v41);
  if ( HIDWORD(v41) && (SHIDWORD(v41) <= 0 || *((float *)Block + SHIDWORD(v41) - 1) != 100005.0) )
  {
    sub_1801716F0(&Block, (unsigned int)(HIDWORD(v41) + 1));
    v29 = SHIDWORD(v41);
    v28 = ++HIDWORD(v41);
    v30 = (char *)Block + 4 * v29;
    if ( v30 )
    {
      *v30 = 1203982976;
      v28 = HIDWORD(v41);
    }
  }
  v31 = (float)(v26 * 0.85000002) + (float)v19;
  if ( !v28 )
  {
    v43 = v27;
    v42 = v27;
    v44 = v31;
LABEL_20:
    v45 = v31;
    goto LABEL_21;
  }
  if ( v42 <= v27 )
  {
    if ( v27 > v43 )
      v43 = v27;
  }
  else
  {
    v42 = v27;
  }
  if ( v44 <= v31 )
  {
    if ( v31 > v45 )
      goto LABEL_20;
  }
  else
  {
    v44 = v31;
  }
LABEL_21:
  sub_180179780(&Block, &unk_180AA33E4);
  sub_18082B140(&Block);
  sub_18082B140(&Block);
  if ( HIDWORD(v41) && (SHIDWORD(v41) <= 0 || *((float *)Block + SHIDWORD(v41) - 1) != 100005.0) )
  {
    sub_1801716F0(&Block, (unsigned int)(HIDWORD(v41) + 1));
    v32 = SHIDWORD(v41);
    ++HIDWORD(v41);
    v33 = (char *)Block + 4 * v32;
    if ( v33 )
      *v33 = 1203982976;
  }
  if ( a5 )
    v16 = 16780032;
  v34 = (unsigned int *)sub_1808D6630(v13, &a5, v16, 0);
  sub_180831D50(a2, *v34);
  if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
  {
    v35 = (float *)Block;
    v36 = (char *)Block + 4 * SHIDWORD(v41);
    if ( Block != v36 )
    {
      do
      {
        v37 = *v35;
        if ( *v35 == 100002.0 )
        {
          v35 += 2;
        }
        else if ( v37 == 100001.0 || v37 == 100003.0 || v37 == 100004.0 )
        {
          v38 = (__m128)xmmword_180AE5570;
          v39 = 1065353216;
          (*(void (__fastcall **)(_QWORD, void **, __m128 *))(**(_QWORD **)(a2 + 8) + 184LL))(
            *(_QWORD *)(a2 + 8),
            &Block,
            &v38);
          break;
        }
        ++v35;
      }
      while ( v35 != (float *)v36 );
    }
  }
  HIDWORD(v41) = 0;
  free(Block);
}

