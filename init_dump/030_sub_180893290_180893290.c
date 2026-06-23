// sub_180893290  @ 0x180893290  (RVA 0x893290)  floats=21
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE4FC0  dword_180AE4FC0 = 0.20000000298023224
//   0x180AE4FCC  dword_180AE4FCC = 0.2499999850988388
//   0x180AE4FE0  dword_180AE4FE0 = 0.30000001192092896
//   0x180AE5008  dword_180AE5008 = 0.44999998807907104
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5024  dword_180AE5024 = 0.550000011920929
//   0x180AE5054  dword_180AE5054 = 0.699999988079071
//   0x180AE5064  dword_180AE5064 = 0.75
//   0x180AE5088  dword_180AE5088 = 0.8999999761581421
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE50E0  dword_180AE50E0 = 1.2000000476837158
//   0x180AE50F8  dword_180AE50F8 = 1.2999999523162842
//   0x180AE5428  qword_180AE5428 = 0.0
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5488  dword_180AE5488 = 100005.0
//   0x180AE54E4  dword_180AE54E4 = -1.0
//   0x180AE5570  xmmword_180AE5570 = 1.0

// Hidden C++ exception states: #wind=1
void __fastcall sub_180893290(
        __int64 a1,
        __int64 a2,
        int a3,
        int a4,
        unsigned int a5,
        int a6,
        int a7,
        int a8,
        int a9,
        double a10)
{
  __int64 v13; // rdi
  unsigned int *v14; // rax
  unsigned int *v15; // rax
  unsigned int *v16; // rax
  __m128 v17; // xmm2
  __m128 v18; // xmm2
  __m128 v19; // xmm2
  char v20; // dl
  float v21; // xmm6_4
  float v22; // xmm9_4
  __int64 i; // rax
  unsigned int v24; // ebx
  int v25; // edx
  int v26; // r8d
  int v27; // r9d
  int v28; // r8d
  int v29; // r9d
  unsigned int v30; // eax
  int v31; // edx
  float v32; // xmm7_4
  float v33; // xmm8_4
  float v34; // xmm9_4
  float v35; // xmm11_4
  float v36; // xmm8_4
  int v37; // edx
  __int64 v38; // rax
  _DWORD *v39; // r8
  float v40; // xmm7_4
  __int64 v41; // rdx
  _DWORD *v42; // rcx
  unsigned int *v43; // rax
  float *v44; // rcx
  char *v45; // rdx
  float v46; // xmm0_4
  _QWORD v47[2]; // [rsp+68h] [rbp-A0h] BYREF
  __m128 v48; // [rsp+78h] [rbp-90h] BYREF
  __int64 v49; // [rsp+88h] [rbp-80h]
  void *Block; // [rsp+98h] [rbp-70h] BYREF
  __int64 v51; // [rsp+A0h] [rbp-68h]
  float v52; // [rsp+A8h] [rbp-60h]
  float v53; // [rsp+ACh] [rbp-5Ch]
  float v54; // [rsp+B0h] [rbp-58h]
  float v55; // [rsp+B4h] [rbp-54h]
  char v56; // [rsp+B8h] [rbp-50h]

  v47[1] = -2;
  v13 = *(_QWORD *)&a10;
  v14 = (unsigned int *)sub_1808D6630(*(_QWORD *)&a10, v47, 16780032, 0);
  sub_1808316B0(a2, *v14);
  if ( (*(_BYTE *)(v13 + 169) & 0x10) != 0
    || *(_QWORD *)(v13 + 24) && !(unsigned __int8)sub_1808C7290()
    || qword_180CB8710 != v13 )
  {
    v16 = (unsigned int *)sub_1808D6630(v13, &a10, 16780288, 0);
    sub_180831D50(a2, *v16);
    v48.m128_u64[1] = __PAIR64__(a4, a3);
    v48.m128_u64[0] = 0;
    v17 = _mm_shuffle_ps(v48, v48, 225);
    v17.m128_f32[0] = (float)0;
    v18 = _mm_shuffle_ps(v17, v17, 198);
    v18.m128_f32[0] = (float)a3;
    v19 = _mm_shuffle_ps(v18, v18, 39);
    v19.m128_f32[0] = (float)a4;
    v48 = _mm_shuffle_ps(v19, v19, 57);
    sub_180821540(a2, &v48);
  }
  else
  {
    v15 = (unsigned int *)sub_1808D6630(v13, &a10, 16781056, 0);
    sub_180831D50(a2, *v15);
    sub_180821880(a2, 0, 0, a3, a4, 2);
  }
  v20 = *(_BYTE *)(v13 + 169) & 0x10;
  if ( v20 || *(_QWORD *)(v13 + 24) && !(unsigned __int8)sub_1808C7290() )
  {
    v21 = 0.30000001;
  }
  else if ( (_BYTE)a5 )
  {
    v21 = 1.2;
  }
  else
  {
    v21 = 0.5;
  }
  if ( v20 || *(_QWORD *)(v13 + 24) && !(unsigned __int8)sub_1808C7290() )
    v22 = 0.5;
  else
    v22 = 1.0;
  for ( i = qword_180CB8710; i != v13 && i; i = *(_QWORD *)(i + 24) )
    ;
  v24 = *(_DWORD *)sub_1808D6630(v13, v47, 16780544, 0);
  sub_180157460(&v48, v24);
  sub_1801575F0((unsigned int)&a10, v25, v26, v27, SHIBYTE(v24));
  if ( (_BYTE)a5 )
  {
    sub_180832B80(&a10, &a5);
    v30 = a5;
  }
  else
  {
    v30 = LODWORD(a10);
  }
  a5 = v30;
  v31 = 255;
  a10 = (float)((float)HIBYTE(v30) * v22) + 6.755399441055744e15;
  if ( SLODWORD(a10) < 255 )
    v31 = LOBYTE(a10);
  HIBYTE(a5) = v31;
  v32 = (float)a9;
  v33 = (float)a8;
  v34 = (float)a7;
  v35 = (float)a6;
  sub_180887890(a2, v31, v28, v29, (float)a9 - (float)(v21 + v21), (__int64)&a5, LODWORD(v21), -1082130432, 1, 1, 1, 1);
  if ( (*(_BYTE *)(v13 + 169) & 0x10) != 0 || *(_QWORD *)(v13 + 24) && !(unsigned __int8)sub_1808C7290() )
    return;
  Block = nullptr;
  v51 = 0;
  v56 = 1;
  v36 = (float)(v33 * 0.5) + v35;
  v53 = v36;
  v52 = v36;
  v55 = (float)(v32 * 0.24999999) + v34;
  v54 = v55;
  sub_180179780(&Block, &unk_180AA33E4);
  sub_18082B140(&Block);
  sub_18082B140(&Block);
  v37 = HIDWORD(v51);
  if ( HIDWORD(v51) && (SHIDWORD(v51) <= 0 || *((float *)Block + SHIDWORD(v51) - 1) != 100005.0) )
  {
    sub_1801716F0(&Block, (unsigned int)(HIDWORD(v51) + 1));
    v38 = SHIDWORD(v51);
    v37 = ++HIDWORD(v51);
    v39 = (char *)Block + 4 * v38;
    if ( v39 )
    {
      *v39 = 1203982976;
      v37 = HIDWORD(v51);
    }
  }
  v40 = (float)(v32 * 0.75) + v34;
  if ( !v37 )
  {
    v53 = v36;
    v52 = v36;
    v54 = v40;
LABEL_45:
    v55 = v40;
    goto LABEL_46;
  }
  if ( v52 <= v36 )
  {
    if ( v36 > v53 )
      v53 = v36;
  }
  else
  {
    v52 = v36;
  }
  if ( v54 > v40 )
  {
    v54 = v40;
    goto LABEL_46;
  }
  if ( v40 > v55 )
    goto LABEL_45;
LABEL_46:
  sub_180179780(&Block, &unk_180AA33E4);
  sub_18082B140(&Block);
  sub_18082B140(&Block);
  if ( HIDWORD(v51) && (SHIDWORD(v51) <= 0 || *((float *)Block + SHIDWORD(v51) - 1) != 100005.0) )
  {
    sub_1801716F0(&Block, (unsigned int)(HIDWORD(v51) + 1));
    v41 = SHIDWORD(v51);
    ++HIDWORD(v51);
    v42 = (char *)Block + 4 * v41;
    if ( v42 )
      *v42 = 1203982976;
  }
  v43 = (unsigned int *)sub_1808D6630(v13, &a5, 16780800, 0);
  sub_180831D50(a2, *v43);
  if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
  {
    v44 = (float *)Block;
    v45 = (char *)Block + 4 * SHIDWORD(v51);
    if ( Block != v45 )
    {
      do
      {
        v46 = *v44;
        if ( *v44 == 100002.0 )
        {
          v44 += 2;
        }
        else if ( v46 == 100001.0 || v46 == 100003.0 || v46 == 100004.0 )
        {
          v48 = (__m128)xmmword_180AE5570;
          v49 = 1065353216;
          (*(void (__fastcall **)(_QWORD, void **, __m128 *))(**(_QWORD **)(a2 + 8) + 184LL))(
            *(_QWORD *)(a2 + 8),
            &Block,
            &v48);
          break;
        }
        ++v44;
      }
      while ( v44 != (float *)v45 );
    }
  }
  HIDWORD(v51) = 0;
  free(Block);
}

