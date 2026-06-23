// sub_180881670  @ 0x180881670  (RVA 0x881670)  floats=16
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE4FCC  dword_180AE4FCC = 0.2499999850988388
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE5008  dword_180AE5008 = 0.44999998807907104
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5024  dword_180AE5024 = 0.550000011920929
//   0x180AE5054  dword_180AE5054 = 0.699999988079071
//   0x180AE5064  dword_180AE5064 = 0.75
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE5428  qword_180AE5428 = 0.0
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5488  dword_180AE5488 = 100005.0
//   0x180AE5570  xmmword_180AE5570 = 1.0

// Hidden C++ exception states: #wind=1
void __fastcall sub_180881670(
        __int64 a1,
        __int64 a2,
        int a3,
        int a4,
        int a5,
        int a6,
        int a7,
        unsigned int a8,
        int a9,
        double a10)
{
  __int64 v13; // rbx
  unsigned int *v14; // rax
  float v15; // xmm9_4
  unsigned int *v16; // rax
  unsigned int *v17; // rax
  __m128 v18; // xmm2
  __m128 v19; // xmm2
  __m128 v20; // xmm2
  float v21; // xmm7_4
  float v22; // xmm10_4
  float v23; // xmm8_4
  int v24; // edx
  __int64 v25; // rax
  _DWORD *v26; // r8
  float v27; // xmm7_4
  __int64 v28; // rcx
  _DWORD *v29; // rdx
  char v30; // dl
  float *v31; // rcx
  char *v32; // rdx
  float v33; // xmm0_4
  __m128 v34; // [rsp+48h] [rbp-A9h] BYREF
  __int64 v35; // [rsp+58h] [rbp-99h]
  void *Block; // [rsp+68h] [rbp-89h] BYREF
  __int64 v37; // [rsp+70h] [rbp-81h]
  float v38; // [rsp+78h] [rbp-79h]
  float v39; // [rsp+7Ch] [rbp-75h]
  float v40; // [rsp+80h] [rbp-71h]
  float v41; // [rsp+84h] [rbp-6Dh]
  char v42; // [rsp+88h] [rbp-69h]
  char v43; // [rsp+130h] [rbp+3Fh] BYREF

  v13 = *(_QWORD *)&a10;
  v14 = (unsigned int *)sub_1808D6630(*(_QWORD *)&a10, &v43, 16780032, 0);
  sub_1808316B0(a2, *v14);
  v15 = 1.0;
  if ( (*(_BYTE *)(v13 + 169) & 0x10) != 0
    || *(_QWORD *)(v13 + 24) && !(unsigned __int8)sub_1808C7290()
    || qword_180CB8710 != v13 )
  {
    v17 = (unsigned int *)sub_1808D6630(v13, &a10, 16780288, 0);
    sub_180831D50(a2, *v17);
    v34.m128_u64[1] = __PAIR64__(a4, a3);
    v34.m128_u64[0] = 0;
    v18 = _mm_shuffle_ps(v34, v34, 225);
    v18.m128_f32[0] = (float)0;
    v19 = _mm_shuffle_ps(v18, v18, 198);
    v19.m128_f32[0] = (float)a3;
    v20 = _mm_shuffle_ps(v19, v19, 39);
    v20.m128_f32[0] = (float)a4;
    v34 = _mm_shuffle_ps(v20, v20, 57);
    sub_180821540(a2, &v34);
  }
  else
  {
    v16 = (unsigned int *)sub_1808D6630(v13, &a10, 16781056, 0);
    sub_180831D50(a2, *v16);
    sub_180821880(a2, 0, 0, a3, a4, 2);
  }
  Block = nullptr;
  v37 = 0;
  v42 = 1;
  v21 = (float)a9;
  v22 = (float)a7;
  v23 = (float)((float)(int)a8 * 0.5) + (float)a6;
  v39 = v23;
  v38 = v23;
  v41 = (float)((float)a9 * 0.24999999) + (float)a7;
  v40 = v41;
  sub_180179780(&Block, &unk_180AA33E4);
  sub_18082B140(&Block);
  sub_18082B140(&Block);
  v24 = HIDWORD(v37);
  if ( HIDWORD(v37) && (SHIDWORD(v37) <= 0 || *((float *)Block + SHIDWORD(v37) - 1) != 100005.0) )
  {
    sub_1801716F0(&Block, (unsigned int)(HIDWORD(v37) + 1));
    v25 = SHIDWORD(v37);
    v24 = ++HIDWORD(v37);
    v26 = (char *)Block + 4 * v25;
    if ( v26 )
    {
      *v26 = 1203982976;
      v24 = HIDWORD(v37);
    }
  }
  v27 = (float)(v21 * 0.75) + v22;
  if ( !v24 )
  {
    v39 = v23;
    v38 = v23;
    v40 = v27;
LABEL_21:
    v41 = v27;
    goto LABEL_22;
  }
  if ( v38 <= v23 )
  {
    if ( v23 > v39 )
      v39 = v23;
  }
  else
  {
    v38 = v23;
  }
  if ( v40 > v27 )
  {
    v40 = v27;
    goto LABEL_22;
  }
  if ( v27 > v41 )
    goto LABEL_21;
LABEL_22:
  sub_180179780(&Block, &unk_180AA33E4);
  sub_18082B140(&Block);
  sub_18082B140(&Block);
  if ( HIDWORD(v37) && (SHIDWORD(v37) <= 0 || *((float *)Block + SHIDWORD(v37) - 1) != 100005.0) )
  {
    sub_1801716F0(&Block, (unsigned int)(HIDWORD(v37) + 1));
    v28 = SHIDWORD(v37);
    ++HIDWORD(v37);
    v29 = (char *)Block + 4 * v28;
    if ( v29 )
      *v29 = 1203982976;
  }
  if ( (*(_BYTE *)(v13 + 169) & 0x10) != 0 || *(_QWORD *)(v13 + 24) && !(unsigned __int8)sub_1808C7290() )
    v15 = 0.30000001;
  a8 = *(_DWORD *)sub_1808D6630(v13, &a6, 16780800, 0);
  a10 = (float)((float)HIBYTE(a8) * v15) + 6.755399441055744e15;
  v30 = -1;
  if ( SLODWORD(a10) < 255 )
    v30 = LOBYTE(a10);
  HIBYTE(a8) = v30;
  sub_180831D50(a2, a8);
  if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
  {
    v31 = (float *)Block;
    v32 = (char *)Block + 4 * SHIDWORD(v37);
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
          v34 = (__m128)xmmword_180AE5570;
          v35 = 1065353216;
          (*(void (__fastcall **)(_QWORD, void **, __m128 *))(**(_QWORD **)(a2 + 8) + 184LL))(
            *(_QWORD *)(a2 + 8),
            &Block,
            &v34);
          break;
        }
        ++v31;
      }
      while ( v31 != (float *)v32 );
    }
  }
  HIDWORD(v37) = 0;
  free(Block);
}

