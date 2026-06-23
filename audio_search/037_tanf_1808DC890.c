// tanf @ 0x1808DC890 (RVA 0x8DC890)  float_ops=49

// local variable allocation has failed, the output may be wrong!
float __cdecl tanf(float X)
{
  double v1; // xmm5_8
  double v2; // r9
  __m128d v3; // xmm2
  __m128d v4; // xmm4
  double v5; // xmm1_8
  __m128i v6; // xmm4
  double v7; // xmm0_8
  unsigned __int64 v8; // r10
  __int64 v9; // rcx
  __m128i v10; // xmm0
  __int64 v11; // r8
  __int64 v12; // r11
  unsigned __int64 v13; // r9
  __int64 v14; // r10
  unsigned __int128 v15; // kr10_16
  unsigned __int64 v16; // rdx
  bool v17; // cf
  unsigned __int64 v18; // r10
  __int64 v19; // r11
  bool v20; // zf
  __int64 v21; // rcx
  __int64 v22; // r11
  __int64 v23; // rcx
  unsigned __int64 v59; // rcx
  unsigned __int64 v60; // r11
  unsigned __int64 v62; // rax
  __int64 v63; // rcx
  __int128 v66; // kr00_16
  unsigned __int64 v67; // r8
  unsigned __int64 v68; // r11
  unsigned __int64 v70; // r9
  __int64 v71; // r10
  unsigned __int64 v72; // r10
  unsigned __int64 v73; // rdx
  bool v74; // cf
  unsigned __int64 v75; // rax
  unsigned __int64 v77; // r10
  unsigned __int64 v78; // r11
  __int64 v79; // rcx
  __int64 v80; // r11
  __int64 v81; // rcx

  if ( !dword_180CB79DC )
  {
    if ( (_mm_cvtsi128_si32(*(__m128i *)&X) & 0x7F800000) != 0x7F800000 )
    {
      v1 = X;
      v2 = fabs(X);
      if ( *(__int64 *)&v2 > 0x3FE921FB54442D18LL )
      {
        if ( *(__int64 *)&v2 >= 0x4160000000000000LL )
        {
          v8 = 134 - ((unsigned __int64)((*(_QWORD *)&v2 >> 52) - 1023LL) >> 3);
          v9 = *(_QWORD *)&v2 & 0xFFFFFFFFFFFFFLL | 0x10000000000000LL;
          v10 = _mm_loadu_si128((const __m128i *)((char *)&unk_180AF5060 + v8 + 8));
          v11 = v9 * *(_QWORD *)((char *)&unk_180AF5060 + v8);
          v12 = ((*(_QWORD *)&v2 >> 52) - 1023LL) & 7;
          v15 = __PAIR128__(
                  v9 * _mm_srli_si128(v10, 8).m128i_u64[0],
                  ((unsigned __int64)v9 * (unsigned __int128)*(unsigned __int64 *)((char *)&unk_180AF5060 + v8)) >> 64)
              + (unsigned __int64)v9 * (unsigned __int128)v10.m128i_u64[0];
          v14 = *((_QWORD *)&v15 + 1);
          v13 = v15;
          v16 = 0;
          v17 = __CFSHR__(*((_QWORD *)&v15 + 1), 54 - v12);
          if ( v17 )
          {
            v14 = ~*((_QWORD *)&v15 + 1);
            v13 = ~(_QWORD)v15;
            v11 = ~v11;
            v16 = 0x8000000000000000uLL;
          }
          v6 = _mm_cvtsi32_si128((v17 + (unsigned __int8)(*((_QWORD *)&v15 + 1) >> (54 - (unsigned __int8)v12))) & 3);
          v18 = (unsigned __int64)(v14 << ((unsigned __int8)v12 + 10)) >> ((unsigned __int8)v12 + 10);
          v19 = v12 - 54;
          v20 = !_BitScanReverse64((unsigned __int64 *)&v21, v18);
          if ( v20 )
          {
            v18 = v13;
            v13 = v11;
            _BitScanReverse64((unsigned __int64 *)&v21, v18);
            v19 -= 64;
          }
          v22 = v21 + v19;
          v23 = v21 - 52;
          if ( v23 < 0 )
          {
            v18 = (v13 >> ((unsigned __int8)v23 + 64)) | (v18 << -(char)v23);
          }
          else if ( v23 )
          {
            v18 >>= v23;
          }
          v7 = COERCE_DOUBLE(((v22 + 1023) << 52) | v16 | v18 & 0xFFEFFFFFFFFFFFFFuLL) * 1.570796326794897;
        }
        else
        {
          v3.m128d_f64[1] = 0.6366197723675814;
          v3.m128d_f64[0] = 0.6366197723675814 * fabs(v2) + 0.5;
          v4 = (__m128d)_mm_cvttpd_epi32(v3);
          v5 = _mm_cvtepi32_pd((__m128i)v4).m128d_f64[0];
          v6 = (__m128i)_mm_and_pd(v4, (__m128d)xmmword_180AF4880);
          v7 = v2 - v5 * 1.570796326734126 - v5 * 6.077100506506192e-11;
        }
        *(double *)&X = v7
                      + v7
                      * v7
                      * v7
                      * ((-0.01720324804714817 * (v7 * v7) + 0.3852960712639954)
                       / ((0.01844239256901656 * (v7 * v7) + -0.5139650547885454) * (v7 * v7) + 1.155888214346884));
        if ( (_mm_cvtsi128_si32(v6) & 1) == 1 )
          *(double *)&X = -1.0 / *(double *)&X;
        return COERCE_DOUBLE(*(_QWORD *)&X ^ *(_QWORD *)&v1 & 0x8000000000000000uLL);
      }
      else
      {
        if ( *(__int64 *)&v2 >= 0x3F20000000000000LL )
          return v1
               + v1
               * v1
               * v1
               * ((-0.01720324804714817 * (v1 * v1) + 0.3852960712639954)
                / ((0.01844239256901656 * (v1 * v1) + -0.5139650547885454) * (v1 * v1) + 1.155888214346884));
        if ( *(__int64 *)&v2 < 0x3E40000000000000LL )
          return X;
        *(double *)&X = v1 * v1 * v1 * 0.3333333333333333 + v1;
        return *(double *)&X;
      }
    }
    return tanf_special();
  }
  __asm { vmovd   eax, xmm0 }
  if ( (_EAX & 0x7F800000) == 0x7F800000 )
    return tanf_special();
  __asm
  {
    vcvtss2sd xmm5, xmm0, xmm0
    vmovq   r9, xmm5
  }
  _R9 = _R9 & 0x7FFFFFFFFFFFFFFFLL;
  if ( _R9 > 0x3FE921FB54442D18LL )
  {
    __asm { vmovq   xmm0, r9 }
    if ( _R9 >= 0x41E921FB40000000LL )
    {
      _R9 = &unk_180AF5060;
      __asm { vmovq   r11, xmm0 }
      v59 = _R11;
      v60 = (_R11 >> 52) - 1023;
      _R10 = 134 - (v60 >> 3);
      v62 = *(_QWORD *)((char *)&unk_180AF5060 + _R10);
      v63 = v59 & 0xFFFFFFFFFFFFFLL | 0x10000000000000LL;
      _R10 += 8;
      __asm { vmovdqu xmm0, xmmword ptr [r9+r10] }
      v66 = v62;
      _RAX = (unsigned __int64)v63 * (unsigned __int128)v62;
      v67 = _RAX;
      __asm { vmovq   rax, xmm0 }
      v68 = v60 & 7;
      __asm { vpsrldq xmm0, xmm0, 8 }
      v71 = (*((unsigned __int64 *)&_RAX + 1) + (unsigned __int64)v63 * (unsigned __int128)(unsigned __int64)_RAX) >> 64;
      v70 = (__PAIR128__(v63, v63) * v66) >> 64;
      __asm { vmovq   rax, xmm0 }
      v72 = v63 * _RAX + v71;
      v73 = 0;
      v74 = __CFSHR__(v72, 54 - v68);
      v75 = v72 >> (54 - (unsigned __int8)v68);
      if ( v74 )
      {
        v72 = ~v72;
        v70 = ~v70;
        v67 = ~v67;
        v73 = 0x8000000000000000uLL;
      }
      _EAX = (v74 + (_BYTE)v75) & 3;
      __asm { vmovd   xmm4, eax }
      v77 = v72 << ((unsigned __int8)v68 + 10) >> ((unsigned __int8)v68 + 10);
      v78 = v68 - 54;
      v20 = !_BitScanReverse64((unsigned __int64 *)&v79, v77);
      if ( v20 )
      {
        v77 = v70;
        v70 = v67;
        _BitScanReverse64((unsigned __int64 *)&v79, v77);
        v78 -= 64LL;
      }
      v80 = v79 + v78;
      v81 = v79 - 52;
      if ( v81 < 0 )
      {
        v77 = (v70 >> ((unsigned __int8)v81 + 64)) | (v77 << -(char)v81);
      }
      else if ( v81 )
      {
        v77 >>= v81;
      }
      _R10 = ((v80 + 1023) << 52) | v73 | v77 & 0xFFEFFFFFFFFFFFFFuLL;
      __asm
      {
        vmovq   xmm0, r10
        vmulsd  xmm0, xmm0, cs:qword_180AF4918
      }
    }
    else
    {
      __asm
      {
        vandpd  xmm1, xmm0, cs:xmmword_180AF4860
        vmovapd xmm2, cs:xmmword_180AF4870
        vfmadd213sd xmm2, xmm1, cs:qword_180AF4900
        vcvttpd2dq xmm2, xmm2
        vpmovsxdq xmm1, xmm2
        vandpd  xmm4, xmm1, cs:xmmword_180AF4880
        vshufps xmm1, xmm1, xmm1, 8
        vcvtdq2pd xmm1, xmm1
        vmovdqa xmm2, xmm0
        vfnmadd231sd xmm2, xmm1, cs:qword_180AF4908
        vmulsd  xmm3, xmm1, cs:qword_180AF4910
        vsubsd  xmm0, xmm2, xmm3
        vsubsd  xmm2, xmm2, xmm0
        vsubsd  xmm1, xmm2, xmm3
      }
    }
    __asm
    {
      vandpd  xmm2, xmm4, cs:xmmword_180AF4890
      vmovd   eax, xmm2
      vmulsd  xmm1, xmm0, xmm0
      vmovsd  xmm3, cs:qword_180AF48B8
      vfmadd213sd xmm3, xmm1, cs:qword_180AF48B0
      vmovsd  xmm2, cs:qword_180AF48D0
      vfmadd213sd xmm2, xmm1, cs:qword_180AF48C8
      vfmadd213sd xmm2, xmm1, cs:qword_180AF48C0
      vdivsd  xmm3, xmm3, xmm2
      vmulsd  xmm1, xmm1, xmm0
      vfmadd231sd xmm0, xmm1, xmm3
    }
    if ( _EAX == 1 )
    {
      __asm
      {
        vmovq   xmm3, cs:qword_180AF4920
        vdivsd  xmm0, xmm3, xmm0
      }
    }
    __asm
    {
      vandpd  xmm5, xmm5, cs:xmmword_180AF48A0
      vxorpd  xmm0, xmm0, xmm5
      vcvtsd2ss xmm0, xmm0, xmm0
    }
  }
  else
  {
    if ( _R9 >= 0x3F20000000000000LL )
    {
      __asm
      {
        vmovsd  xmm0, xmm5, xmm5
        vmulsd  xmm1, xmm0, xmm0
        vmovsd  xmm3, cs:qword_180AF48B8
        vfmadd213sd xmm3, xmm1, cs:qword_180AF48B0
        vmovsd  xmm2, cs:qword_180AF48D0
        vfmadd213sd xmm2, xmm1, cs:qword_180AF48C8
        vfmadd213sd xmm2, xmm1, cs:qword_180AF48C0
        vdivsd  xmm3, xmm3, xmm2
        vmulsd  xmm1, xmm1, xmm0
        vfmadd231sd xmm0, xmm1, xmm3
      }
    }
    else
    {
      if ( _R9 < 0x3E40000000000000LL )
      {
        __asm
        {
          vmulss  xmm1, xmm0, cs:dword_180AF4938
          vaddss  xmm1, xmm1, cs:dword_180AF4948
        }
        return X;
      }
      __asm
      {
        vmulsd  xmm2, xmm5, xmm5
        vmulsd  xmm0, xmm2, xmm5
        vfmadd132sd xmm0, xmm5, cs:qword_180AF48E8
      }
    }
    __asm { vcvtsd2ss xmm0, xmm0, xmm0 }
  }
  return X;
}

