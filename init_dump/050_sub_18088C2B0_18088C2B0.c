// sub_18088C2B0  @ 0x18088C2B0  (RVA 0x88C2B0)  floats=15
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5044  dword_180AE5044 = 0.625
//   0x180AE5070  dword_180AE5070 = 0.800000011920929
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE51E8  flt_180AE51E8 = 2.0
//   0x180AE5428  qword_180AE5428 = 0.0
//   0x180AE5470  dword_180AE5470 = 10000.0
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5488  dword_180AE5488 = 100005.0
//   0x180AE54E0  dword_180AE54E0 = -0.800000011920929

// Hidden C++ exception states: #wind=3
__int64 __fastcall sub_18088C2B0(
        __int64 a1,
        __int64 a2,
        __int64 a3,
        int a4,
        int a5,
        int a6,
        int a7,
        char a8,
        int a9,
        char a10)
{
  __int64 v13; // rdx
  char v14; // dl
  int v15; // ebx
  int v16; // esi
  int v17; // r14d
  __int64 v18; // rcx
  _DWORD *v19; // rdx
  int v20; // r9d
  int v21; // eax
  int v22; // r8d
  int v23; // eax
  int v24; // edx
  int v25; // ecx
  float *v26; // rcx
  char *v27; // rdx
  float v28; // xmm0_4
  unsigned int *v29; // rax
  float v30; // xmm7_4
  _DWORD *v31; // rax
  _DWORD *v32; // rbx
  float v33; // xmm6_4
  __int64 *v34; // rax
  __int64 v35; // rcx
  void (__fastcall ***v36)(_QWORD, __int64); // rcx
  unsigned int v38; // [rsp+48h] [rbp-B9h] BYREF
  unsigned int v39; // [rsp+4Ch] [rbp-B5h]
  void *Block; // [rsp+50h] [rbp-B1h] BYREF
  __int64 v41; // [rsp+58h] [rbp-A9h]
  __int64 v42; // [rsp+60h] [rbp-A1h]
  __int64 v43; // [rsp+68h] [rbp-99h]
  __int64 v44; // [rsp+70h] [rbp-91h]
  _DWORD *v45; // [rsp+78h] [rbp-89h] BYREF
  __int128 v46; // [rsp+88h] [rbp-79h]
  double v47; // [rsp+98h] [rbp-69h]
  __int64 v48; // [rsp+A0h] [rbp-61h]
  __int128 v49; // [rsp+A8h] [rbp-59h] BYREF
  _BYTE v50[80]; // [rsp+B8h] [rbp-49h] BYREF

  v48 = -2;
  sub_1808D6630(a3, &v38, 16791600, 0);
  if ( (_BYTE)a9 )
  {
    v13 = v38;
  }
  else
  {
    if ( !a8 )
      goto LABEL_8;
    v39 = v38;
    v47 = (float)((float)HIBYTE(v38) * 0.625) + 6.755399441055744e15;
    v14 = -1;
    if ( SLODWORD(v47) < 255 )
      v14 = LOBYTE(v47);
    HIBYTE(v39) = v14;
    v13 = v39;
  }
  sub_1808316B0(a2, v13);
LABEL_8:
  v15 = 0;
  if ( a6 - 8 > 0 )
    v15 = a6 - 8;
  v16 = 0;
  v17 = a7;
  if ( a7 > 0 )
    v16 = a7;
  *(_QWORD *)&v46 = 4;
  *((_QWORD *)&v46 + 1) = __PAIR64__(v16, v15);
  if ( (a10 & 0x60) != 0 )
  {
    Block = nullptr;
    v41 = 0;
    LOBYTE(v44) = 1;
    v42 = 0;
    v43 = 0;
    sub_180179780(&Block, &unk_180AA33E4);
    sub_18082B140(&Block);
    sub_18082B140(&Block);
    if ( HIDWORD(v41) && (SHIDWORD(v41) <= 0 || *((float *)Block + HIDWORD(v41) - 1) != 100005.0) )
    {
      sub_1801716F0(&Block, (unsigned int)(HIDWORD(v41) + 1));
      v18 = SHIDWORD(v41);
      ++HIDWORD(v41);
      v19 = (char *)Block + 4 * v18;
      if ( v19 )
        *v19 = 1203982976;
    }
    a9 = -1728053248;
    sub_180831D50(a2, 2566914048LL);
    v21 = v17 / 2;
    if ( v15 < v17 / 2 )
      v21 = v15;
    v22 = v15 - v21;
    DWORD2(v46) = v15 - v21;
    v23 = v21 - 4;
    v24 = 0;
    if ( v23 > 0 )
      v24 = v23;
    v25 = 0;
    if ( v16 - 4 > 0 )
      v25 = v16 - 4;
    ((void (__fastcall *)(_DWORD, _DWORD, _DWORD, _DWORD, _DWORD, _DWORD, char, _DWORD))sub_180828260)(
      (unsigned int)&Block,
      (unsigned int)v50,
      v22,
      v20,
      (float)v24,
      (float)v25,
      1,
      36);
    if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
    {
      v26 = (float *)Block;
      v27 = (char *)Block + 4 * SHIDWORD(v41);
      if ( Block != v27 )
      {
        do
        {
          v28 = *v26;
          if ( *v26 == 100002.0 )
          {
            v26 += 2;
          }
          else if ( v28 == 100001.0 || v28 == 100003.0 || v28 == 100004.0 )
          {
            (*(void (__fastcall **)(_QWORD, void **, _BYTE *))(**(_QWORD **)(a2 + 8) + 184LL))(
              *(_QWORD *)(a2 + 8),
              &Block,
              v50);
            break;
          }
          ++v26;
        }
        while ( v26 != (float *)v27 );
      }
    }
    HIDWORD(v41) = 0;
    free(Block);
  }
  v29 = (unsigned int *)sub_1808D6630(a3, &a6, 16791552, 0);
  sub_180831D50(a2, *v29);
  v30 = (float)v17 * 0.5;
  v31 = operator new(0x40u);
  v32 = v31;
  v33 = 0.1;
  if ( v30 >= 0.1 )
    v33 = fminf(10000.0, v30);
  v31[2] = 0;
  *(_QWORD *)v31 = &juce::Font::SharedFontInternal::`vftable';
  *((_QWORD *)v31 + 2) = 0;
  v34 = (__int64 *)sub_1807D2430();
  v35 = *v34;
  *((_QWORD *)v32 + 3) = *v34;
  if ( (*(_DWORD *)(v35 - 16) & 0x30000000) == 0 )
    _InterlockedExchangeAdd((volatile signed __int32 *)(v35 - 16), 1u);
  sub_1800FDCD0(v32 + 8, "Bold");
  *((float *)v32 + 10) = v33;
  *(_QWORD *)(v32 + 11) = 1065353216;
  v32[13] = 0;
  *((_BYTE *)v32 + 56) = 0;
  v45 = v32;
  _InterlockedExchangeAdd(v32 + 2, 1u);
  sub_1808319D0(a2, &v45);
  v36 = (void (__fastcall ***)(_QWORD, __int64))v45;
  if ( v45 && _InterlockedExchangeAdd(v45 + 2, 0xFFFFFFFF) == 1 )
    (**v36)(v36, 1);
  v49 = v46;
  return sub_180821B50(a2, a4, (unsigned int)&v49, 33, 1, 0);
}

