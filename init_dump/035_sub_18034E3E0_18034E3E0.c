// sub_18034E3E0  @ 0x18034E3E0  (RVA 0x34E3E0)  floats=18
// .rdata float constants referenced by this function:
//   0x1809380C0  xmmword_1809380C0 = 0.0
//   0x180968368  aFmPatch = 11705620480.0
//   0x180968378  aFmPatch2 = 11705620480.0
//   0x180968388  aFmPatch3 = 11705620480.0
//   0x180968398  aFmPatchName1Ke = 11705620480.0
//   0x1809683B0  aFmPatchLfoLfoR = 11705620480.0
//   0x1809683C8  aFmPatch2LfoLfo = 11705620480.0
//   0x1809683E8  aFmPatchFltVcfC = 11705620480.0
//   0x180968408  aFmPatch2FltVcf = 11705620480.0
//   0x180968428  aFmSystemCom = 749159710720.0
//   0x180968438  aFmSetupArp = 749159710720.0
//   0x180968448  aFmSetupScat = 749159710720.0
//   0x180968458  aFmSynthCom = 749159710720.0
//   0x180968468  aFmSynthComTemp = 749159710720.0
//   0x1809684A8  aDmSystemCom = 749159579648.0
//   0x1809684B8  aDmSetupArp = 749159579648.0
//   0x1809684C8  aDmSetupScat = 749159579648.0
//   0x1809684D8  aDmSynthCom = 749159579648.0

// Hidden C++ exception states: #wind=34
void __fastcall sub_18034E3E0(__int64 a1)
{
  int i; // r14d
  int j; // esi
  int k; // ebx
  _QWORD *v5; // rdx
  void *v6; // rcx
  void *v7; // rcx
  int m; // r14d
  int n; // esi
  int ii; // ebx
  _QWORD *v11; // rdx
  void *v12; // rcx
  void *v13; // rcx
  void *v14; // rcx
  void *v15; // rcx
  _QWORD v16[2]; // [rsp+38h] [rbp-48h] BYREF
  __m128i si128; // [rsp+48h] [rbp-38h]
  _QWORD v18[2]; // [rsp+58h] [rbp-28h] BYREF
  __int64 v19; // [rsp+68h] [rbp-18h]
  unsigned __int64 v20; // [rsp+70h] [rbp-10h]

  sub_18027D390();
  v19 = 0;
  v20 = 15;
  LOBYTE(v18[0]) = 0;
  sub_18027A590(v18, "fm.PATCH", 8);
  for ( i = 0; i < 1; ++i )
  {
    for ( j = 0; j < 1; ++j )
    {
      for ( k = 0; k < 1; ++k )
      {
        si128.m128i_i64[0] = 0;
        si128.m128i_i64[1] = 15;
        LOBYTE(v16[0]) = 0;
        v5 = v18;
        if ( v20 >= 0x10 )
          v5 = (_QWORD *)v18[0];
        sub_18027A590(v16, v5, v19);
        sub_18027D3A0(a1, v16, a1 + 16, (unsigned int)(i + k + j));
        if ( si128.m128i_i64[1] >= 0x10uLL )
        {
          v6 = (void *)v16[0];
          if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
          {
            v6 = *(void **)(v16[0] - 8LL);
            if ( (unsigned __int64)(v16[0] - (_QWORD)v6 - 8LL) > 0x1F )
              invalid_parameter_noinfo_noreturn();
          }
          j_j_free(v6);
        }
      }
    }
  }
  if ( v20 >= 0x10 )
  {
    v7 = (void *)v18[0];
    if ( v20 + 1 >= 0x1000 )
    {
      v7 = *(void **)(v18[0] - 8LL);
      if ( (unsigned __int64)(v18[0] - (_QWORD)v7 - 8LL) > 0x1F )
        invalid_parameter_noinfo_noreturn();
    }
    j_j_free(v7);
  }
  v19 = 0;
  v20 = 15;
  LOBYTE(v18[0]) = 0;
  sub_18027A590(v18, "fm.PATCH2", 9);
  for ( m = 0; m < 1; ++m )
  {
    for ( n = 0; n < 1; ++n )
    {
      for ( ii = 0; ii < 1; ++ii )
      {
        si128.m128i_i64[0] = 0;
        si128.m128i_i64[1] = 15;
        LOBYTE(v16[0]) = 0;
        v11 = v18;
        if ( v20 >= 0x10 )
          v11 = (_QWORD *)v18[0];
        sub_18027A590(v16, v11, v19);
        sub_18027D3A0(a1, v16, a1 + 24, (unsigned int)(m + ii + n));
        if ( si128.m128i_i64[1] >= 0x10uLL )
        {
          v12 = (void *)v16[0];
          if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
          {
            v12 = *(void **)(v16[0] - 8LL);
            if ( (unsigned __int64)(v16[0] - (_QWORD)v12 - 8LL) > 0x1F )
              invalid_parameter_noinfo_noreturn();
          }
          j_j_free(v12);
        }
      }
    }
  }
  if ( v20 >= 0x10 )
  {
    v13 = (void *)v18[0];
    if ( v20 + 1 >= 0x1000 )
    {
      v13 = *(void **)(v18[0] - 8LL);
      if ( (unsigned __int64)(v18[0] - (_QWORD)v13 - 8LL) > 0x1F )
        invalid_parameter_noinfo_noreturn();
    }
    j_j_free(v13);
  }
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.PATCH3", 9);
  sub_18034D870(a1, (unsigned int)v16, a1 + 32, 1, 1, 1);
  if ( si128.m128i_i64[1] >= 0x10uLL )
  {
    v14 = (void *)v16[0];
    if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
    {
      v14 = *(void **)(v16[0] - 8LL);
      if ( (unsigned __int64)(v16[0] - (_QWORD)v14 - 8LL) > 0x1F )
        invalid_parameter_noinfo_noreturn();
    }
    j_j_free(v14);
  }
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.PATCH.NAME1.KEY HOLD", 23);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 40, 1, 1, 1);
  if ( si128.m128i_i64[1] >= 0x10uLL )
  {
    v15 = (void *)v16[0];
    if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
    {
      v15 = *(void **)(v16[0] - 8LL);
      if ( (unsigned __int64)(v16[0] - (_QWORD)v15 - 8LL) > 0x1F )
        invalid_parameter_noinfo_noreturn();
    }
    j_j_free(v15);
  }
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.PATCH.LFO.LFO RATE", 21);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 48, 1, 1, 1);
  if ( si128.m128i_i64[1] >= 0x10uLL )
    std::allocator<char>::deallocate(v16, v16[0], si128.m128i_i64[1] + 1);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.PATCH2.LFO.LFO RATE H", 24);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 56, 1, 1, 1);
  if ( si128.m128i_i64[1] >= 0x10uLL )
    std::allocator<char>::deallocate(v16, v16[0], si128.m128i_i64[1] + 1);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.PATCH.FLT.VCF CUTOFF FREQ", 28);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 64, 1, 1, 1);
  if ( si128.m128i_i64[1] >= 0x10uLL )
    std::allocator<char>::deallocate(v16, v16[0], si128.m128i_i64[1] + 1);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.PATCH2.FLT.VCF CUTOFF FREQ H", 31);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 72, 1, 1, 1);
  if ( si128.m128i_i64[1] >= 0x10uLL )
    std::allocator<char>::deallocate(v16, v16[0], si128.m128i_i64[1] + 1);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.SYSTEM.COM", 13);
  sub_18034D870(a1, (unsigned int)v16, a1 + 80, 1, 1, 1);
  if ( si128.m128i_i64[1] >= 0x10uLL )
    std::allocator<char>::deallocate(v16, v16[0], si128.m128i_i64[1] + 1);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.SETUP.ARP", 12);
  sub_18034D870(a1, (unsigned int)v16, a1 + 88, 1, 1, 1);
  if ( si128.m128i_i64[1] >= 0x10uLL )
    std::allocator<char>::deallocate(v16, v16[0], si128.m128i_i64[1] + 1);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.SETUP.SCAT", 13);
  sub_18034D870(a1, (unsigned int)v16, a1 + 96, 1, 1, 1);
  if ( si128.m128i_i64[1] >= 0x10uLL )
    std::allocator<char>::deallocate(v16, v16[0], si128.m128i_i64[1] + 1);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.SYNTH.COM", 12);
  sub_18034D870(a1, (unsigned int)v16, a1 + 104, 1, 1, 1);
  if ( si128.m128i_i64[1] >= 0x10uLL )
    std::allocator<char>::deallocate(v16, v16[0], si128.m128i_i64[1] + 1);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.SYNTH.COM.TEMPO", 18);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 112, 1, 1, 1);
  if ( si128.m128i_i64[1] >= 0x10uLL )
    std::allocator<char>::deallocate(v16, v16[0], si128.m128i_i64[1] + 1);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.usrX", 7);
  sub_18034D870(a1, (unsigned int)v16, a1 + 120, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.usr2X", 8);
  sub_18034D870(a1, (unsigned int)v16, a1 + 128, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "fm.usr3X", 8);
  sub_18034D870(a1, (unsigned int)v16, a1 + 136, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "dm.SYSTEM.COM", 13);
  sub_18034D870(a1, (unsigned int)v16, a1 + 144, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "dm.SETUP.ARP", 12);
  sub_18034D870(a1, (unsigned int)v16, a1 + 152, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "dm.SETUP.SCAT", 13);
  sub_18034D870(a1, (unsigned int)v16, a1 + 160, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "dm.SYNTH.COM", 12);
  sub_18034D870(a1, (unsigned int)v16, a1 + 168, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "ms.ch[0].note", 13);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 176, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "vm.vs.velSense", 14);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 184, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "vm.vs.sampleRate", 16);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 192, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "vm.vs.bankId", 12);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 200, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "vm.vs.patchId", 13);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 208, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "vm.vs.patchManager", 18);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 216, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "vm.vs.patchListMain", 19);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 224, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "vm.vs.patchListSub", 18);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 232, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "vm.vs.setup", 11);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 240, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "vm.vs.writePatch", 16);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 248, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "vm.vs.activation", 16);
  sub_18034DCB0(a1, (unsigned int)v16, a1 + 256, 1, 1, 1);
  sub_1800B7A90(v16);
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  LOBYTE(v16[0]) = 0;
  sub_18027A590(v16, "vm.vstCc", 8);
  sub_18034D870(a1, (unsigned int)v16, a1 + 264, 1, 1, 1);
  sub_1800B7A90(v16);
}

