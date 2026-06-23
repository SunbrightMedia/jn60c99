// sub_18087C470  @ 0x18087C470  (RVA 0x87C470)  floats=14
// .rdata float constants referenced by this function:
//   0x180AE4F68  dword_180AE4F68 = 0.01745329238474369
//   0x180AE4FD0  dword_180AE4FD0 = 0.25
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE51E8  flt_180AE51E8 = 2.0
//   0x180AE5218  dword_180AE5218 = 2.25
//   0x180AE5274  flt_180AE5274 = 3.1415927410125732
//   0x180AE52D0  dword_180AE52D0 = 4.0
//   0x180AE5328  flt_180AE5328 = 6.2831854820251465
//   0x180AE53BC  dword_180AE53BC = 22.5
//   0x180AE5448  dword_180AE5448 = 315.0
//   0x180AE544C  dword_180AE544C = 360.0
//   0x180AE5570  xmmword_180AE5570 = 1.0
//   0x180AE57C0  xmmword_180AE57C0 = -0.0

// Hidden C++ exception states: #wind=4
void __fastcall sub_18087C470(__int64 a1, __int64 a2, __int64 a3, _BYTE **a4)
{
  int v7; // edx
  int v8; // ecx
  float v9; // xmm14_4
  float v10; // xmm15_4
  DWORD Time; // eax
  float v12; // xmm8_4
  float v13; // xmm7_4
  float v14; // xmm6_4
  int v15; // edx
  int v16; // r8d
  int v17; // r9d
  int v18; // xmm12_4
  float v19; // xmm10_4
  float v20; // xmm13_4
  int v21; // edx
  int v22; // r8d
  int v23; // r9d
  float v24; // xmm6_4
  float v25; // xmm8_4
  float v26; // xmm7_4
  float v27; // xmm6_4
  float v28; // xmm0_4
  unsigned int *v29; // rax
  char *v30; // rbx
  __int64 *v31; // rax
  __int64 v32; // rcx
  __int64 v33; // r8
  __int64 v34; // rcx
  void (*v35)(void); // rdx
  _QWORD *v36; // rcx
  __int64 (__fastcall *v37)(); // r8
  void (__fastcall ***v38)(_QWORD, __int64); // rcx
  char *v39; // [rsp+58h] [rbp-B0h] BYREF
  __int64 v40; // [rsp+60h] [rbp-A8h] BYREF
  int v41; // [rsp+68h] [rbp-A0h]
  __int64 v42; // [rsp+6Ch] [rbp-9Ch] BYREF
  int v43; // [rsp+74h] [rbp-94h]
  _DWORD v44[4]; // [rsp+78h] [rbp-90h] BYREF
  _DWORD v45[6]; // [rsp+88h] [rbp-80h] BYREF
  void *Block; // [rsp+A0h] [rbp-68h] BYREF
  __int64 v47; // [rsp+A8h] [rbp-60h]
  __int128 v48; // [rsp+B0h] [rbp-58h]
  char v49; // [rsp+C0h] [rbp-48h]
  void *v50; // [rsp+C8h] [rbp-40h] BYREF
  __int64 v51; // [rsp+D0h] [rbp-38h]
  __int128 v52; // [rsp+D8h] [rbp-30h]
  char v53; // [rsp+E8h] [rbp-20h]
  __int128 v54; // [rsp+F0h] [rbp-18h] BYREF
  __int64 v55; // [rsp+100h] [rbp-8h]
  __int128 v56; // [rsp+108h] [rbp+0h] BYREF
  __int64 v57; // [rsp+118h] [rbp+10h]
  __int64 v58; // [rsp+120h] [rbp+18h]
  __int64 v59; // [rsp+1F8h] [rbp+F0h] BYREF
  unsigned int v60; // [rsp+208h] [rbp+100h] BYREF
  char v61; // [rsp+210h] [rbp+108h] BYREF

  v59 = a1;
  v58 = -2;
  sub_1808D6630(a3, &v59, 16783616, 0);
  sub_1808D6630(a3, &v60, 16783872, 0);
  v7 = 0;
  if ( *(_DWORD *)(a3 + 40) - 4 > 0 )
    v7 = *(_DWORD *)(a3 + 40) - 4;
  v8 = 0;
  if ( *(_DWORD *)(a3 + 44) - 4 > 0 )
    v8 = *(_DWORD *)(a3 + 44) - 4;
  v9 = (float)v8;
  v10 = (float)v7;
  Time = timeGetTime();
  if ( Time >= dword_180CB94A4 || Time < dword_180CB94A4 - 1000 )
    _InterlockedExchange(&dword_180CB94A4, Time);
  v12 = (float)(Time / 0xA % 0x168);
  v13 = v12 / 360.0;
  v14 = v12 + 22.5;
  if ( (float)(v12 / 360.0) < 0.25 || v13 >= 0.5 )
  {
    if ( v13 >= 0.5 && v13 <= 1.0 )
    {
      v14 = v14 + 315.0;
      v12 = (float)(v14 - 22.5) - (float)((float)(1.0 - (float)((float)(v13 + v13) - 1.0)) * 315.0);
    }
  }
  else
  {
    v14 = (float)((float)((float)(v13 * 4.0) - 1.0) * 315.0) + v14;
  }
  sub_180831D50(a2, (unsigned int)v59);
  v50 = nullptr;
  v51 = 0;
  v52 = 0;
  v53 = 1;
  *(float *)&v18 = v9 * 0.5;
  v19 = (float)(v9 * 0.5) + 2.0;
  v20 = (float)(v10 * 0.5) + 2.0;
  if ( (float)(v10 * 0.5) > 0.0 )
    sub_18082A130((int)&v50, v15, v16, v17, v18, 0.0, 0.0, 6.2831855, 1);
  v54 = xmmword_180AE5570;
  v55 = 1065353216;
  v40 = 1082130432;
  v41 = 0;
  sub_180830CE0(a2, &v50, &v40, &v54);
  sub_180831D50(a2, v60);
  Block = nullptr;
  v47 = 0;
  v48 = 0;
  v49 = 1;
  v24 = v14 * 0.017453292;
  v25 = v12 * 0.017453292;
  if ( (float)(v10 * 0.5) > 0.0 )
    sub_18082A130((int)&Block, v21, v22, v23, v18, 0.0, v25, v24, 1);
  v26 = (float)(v13 * 3.1415927) * 2.25;
  v27 = cosf(v26);
  v28 = sinf(v26);
  *(float *)v45 = v27;
  *(float *)&v45[1] = -v28;
  *(float *)&v45[2] = (float)((float)(v28 * v19) - (float)(v27 * v20)) + v20;
  *(float *)&v45[3] = v28;
  *(float *)&v45[4] = v27;
  *(float *)&v45[5] = v19 - (float)((float)(v28 * v20) + (float)(v27 * v19));
  sub_180828510(&Block, v45);
  v56 = xmmword_180AE5570;
  v57 = 1065353216;
  v42 = 1082130432;
  v43 = 0;
  sub_180830CE0(a2, &Block, &v42, &v56);
  if ( **a4 )
  {
    v29 = (unsigned int *)sub_1808D6630(a3, &v61, 16777474, 0);
    sub_180831D50(a2, *v29);
    v30 = (char *)operator new(0x40u);
    *((_DWORD *)v30 + 2) = 0;
    *(_QWORD *)v30 = &juce::Font::SharedFontInternal::`vftable';
    *((_QWORD *)v30 + 2) = 0;
    v31 = (__int64 *)sub_1807D2430();
    v32 = *v31;
    *((_QWORD *)v30 + 3) = *v31;
    if ( (*(_DWORD *)(v32 - 16) & 0x30000000) == 0 )
      _InterlockedExchangeAdd((volatile signed __int32 *)(v32 - 16), 1u);
    sub_1800FDCD0(v30 + 32, "Italic");
    *((_DWORD *)v30 + 10) = 1094713344;
    *(_QWORD *)(v30 + 44) = 1065353216;
    *((_DWORD *)v30 + 13) = 0;
    v30[56] = 0;
    v39 = v30;
    _InterlockedExchangeAdd((volatile signed __int32 *)v30 + 2, 1u);
    if ( *(_BYTE *)(a2 + 16) )
    {
      *(_BYTE *)(a2 + 16) = 0;
      v34 = *(_QWORD *)(a2 + 8);
      v35 = *(void (**)(void))(*(_QWORD *)v34 + 104LL);
      if ( (char *)v35 == (char *)sub_180163CA0 )
        sub_18016CBD0(v34 + 8, v35, v33);
      else
        v35();
    }
    v36 = *(_QWORD **)(a2 + 8);
    v37 = *(__int64 (__fastcall **)())(*v36 + 208LL);
    if ( v37 == sub_1801637B0 )
      sub_1808322E0(v36[1] + 112LL, &v39);
    else
      ((void (__fastcall *)(_QWORD *, char **))v37)(v36, &v39);
    v38 = (void (__fastcall ***)(_QWORD, __int64))v39;
    if ( v39 && _InterlockedExchangeAdd((volatile signed __int32 *)v39 + 2, 0xFFFFFFFF) == 1 )
      (**v38)(v38, 1);
    v44[0] = 0x40000000;
    v44[1] = 0x40000000;
    *(float *)&v44[2] = v10;
    *(float *)&v44[3] = v9;
    sub_180821CD0(a2, (_DWORD)a4, (unsigned int)v44, 36, 0);
  }
  HIDWORD(v47) = 0;
  free(Block);
  HIDWORD(v51) = 0;
  free(v50);
}

