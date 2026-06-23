// sinf @ 0x1808DB360 (RVA 0x8DB360)  float_ops=76

// local variable allocation has failed, the output may be wrong!
float __cdecl sinf(float X)
{
  __m128d v1; // xmm2
  float v2; // xmm3_4
  unsigned __int64 v3; // r10
  char v4; // r11
  double v5; // xmm4_8
  __m128i v6; // xmm0
  double v7; // xmm2_8
  double v8; // xmm4_8
  unsigned int v9; // eax
  double v10; // xmm2_8
  double v11; // xmm2_8
  unsigned __int64 v46; // rcx
  unsigned __int64 v47; // r11
  unsigned __int64 v49; // rax
  __int64 v50; // rcx
  __int128 v53; // kr00_16
  unsigned __int64 v54; // r8
  unsigned __int64 v55; // r11
  unsigned __int64 v57; // r9
  __int64 v58; // r10
  unsigned __int64 v59; // r10
  unsigned __int64 v60; // rdx
  bool v61; // cf
  unsigned __int64 v62; // rax
  unsigned __int64 v64; // r10
  unsigned __int64 v65; // r11
  __int64 v67; // rcx
  __int64 v68; // r11
  __int64 v69; // rcx
  char v95; // [rsp+20h] [rbp-48h]
  unsigned int v96; // [rsp+30h] [rbp-38h] BYREF
  __int64 v97[6]; // [rsp+38h] [rbp-30h] BYREF

  if ( !dword_180CB79DC )
  {
    v1 = 0;
    if ( (_mm_cvtsi128_si32(*(__m128i *)&X) & 0x7F800000) != 0x7F800000 )
    {
      v2 = X;
      *(double *)&X = X;
      v3 = *(_QWORD *)&X & 0x7FFFFFFFFFFFFFFFLL;
      if ( (*(_QWORD *)&X & 0x7FFFFFFFFFFFFFFFuLL) <= 0x3FE921FB54442D18LL )
      {
        if ( (*(_QWORD *)&X & 0x7FFFFFFFFFFFFFFFuLL) >= 0x3F80000000000000LL )
          return *(double *)&X
               + ((0.000002755731922398589 * (*(double *)&X * *(double *)&X) + -0.0001984126984126984)
                * (*(double *)&X
                 * *(double *)&X
                 * (*(double *)&X
                  * *(double *)&X))
                + 0.008333333333333333 * (*(double *)&X * *(double *)&X)
                + -0.1666666666666667)
               * (*(double *)&X
                * (*(double *)&X
                 * *(double *)&X));
        if ( (*(_QWORD *)&X & 0x7FFFFFFFFFFFFFFFuLL) < 0x3F20000000000000LL )
          return v2;
        *(double *)&X = *(double *)&X - *(double *)&X * *(double *)&X * *(double *)&X * 0.1666666666666667;
        return *(double *)&X;
      }
      v4 = 0;
      if ( *(_QWORD *)&X != v3 )
      {
        v4 = 1;
        *(double *)&X = 0.0 - *(double *)&X;
      }
      if ( v3 >= 0x416E848000000000LL )
      {
        v95 = v4;
        _remainder_piby2d2f_forC(*(_QWORD *)&X, v97, &v96);
        v4 = v95;
        v9 = v96;
      }
      else
      {
        v5 = *(double *)&X;
        v1.m128d_f64[0] = *(double *)&X * 0.6366197723675814 + 0.5;
        v6 = _mm_cvttpd_epi32(v1);
        v7 = _mm_cvtepi32_pd(v6).m128d_f64[0];
        v8 = v5 - 1.570796326734126 * v7;
        v9 = _mm_cvtsi128_si32(v6);
        *(double *)&X = v8 - 6.077100506506192e-11 * v7;
        if ( (__int64)((v3 >> 52) - ((unsigned __int64)(2LL * *(_QWORD *)&X) >> 53)) > 15 )
          *(double *)&X = v8
                        - 6.077100506303966e-11 * v7
                        - (2.022266248795951e-21 * v7
                         - (v8
                          - (v8
                           - 6.077100506303966e-11 * v7)
                          - 6.077100506303966e-11 * v7));
        if ( (unsigned __int64)(2 * COERCE__INT64(v8 - 6.077100506506192e-11 * v7)) >> 53 < 0x3F2 )
        {
          if ( (unsigned __int64)(2 * COERCE__INT64(v8 - 6.077100506506192e-11 * v7)) >> 53 <= 0x3DE )
          {
            if ( (v9 & 1) != 0 )
              *(_QWORD *)&X = 0x3FF0000000000000LL;
          }
          else
          {
            v10 = *(double *)&X * *(double *)&X;
            if ( (v9 & 1) != 0 )
              *(double *)&X = 1.0 - v10 * 0.5;
            else
              *(double *)&X = *(double *)&X - 0.1666666666666667 * *(double *)&X * v10;
          }
          goto Lsinf_sse2_adjust_region;
        }
      }
      v11 = *(double *)&X * *(double *)&X;
      if ( (v9 & 1) != 0 )
        *(double *)&X = -0.5 * v11
                      + 1.0
                      + ((-0.0000002755731922398589 * v11 + 0.0000248015873015873) * (v11 * v11)
                       + -0.001388888888888889 * v11
                       + 0.04166666666666666)
                      * (v11
                       * v11);
      else
        *(double *)&X = *(double *)&X
                      + ((0.000002755731922398589 * v11 + -0.0001984126984126984) * (v11 * v11)
                       + 0.008333333333333333 * v11
                       + -0.1666666666666667)
                      * (*(double *)&X
                       * v11);
Lsinf_sse2_adjust_region:
      if ( (((unsigned __int8)(~v4 & ~(unsigned __int8)(v9 >> 1)) | (unsigned __int8)(v4 & (v9 >> 1))) & 1) == 0 )
        *(double *)&X = 0.0 - *(double *)&X;
      return *(double *)&X;
    }
    return sinf_special();
  }
  __asm { vmovd   eax, xmm0 }
  if ( (_EAX & 0x7F800000) == 0x7F800000 )
    return sinf_special();
  __asm
  {
    vcvtss2sd xmm5, xmm0, xmm0
    vmovq   r9, xmm5
  }
  _R9 = _R9 & 0x7FFFFFFFFFFFFFFFLL;
  if ( _R9 > 0x3FE921FB54442D18LL )
  {
    __asm { vmovq   xmm0, r9 }
    if ( _R9 >= 0x4170008AC0000000LL )
    {
      _R9 = &unk_180AF5060;
      __asm { vmovq   r11, xmm0 }
      v46 = _R11;
      v47 = (_R11 >> 52) - 1023;
      _R10 = 134 - (v47 >> 3);
      v49 = *(_QWORD *)((char *)&unk_180AF5060 + _R10);
      v50 = v46 & 0xFFFFFFFFFFFFFLL | 0x10000000000000LL;
      _R10 += 8;
      __asm { vmovdqu xmm0, xmmword ptr [r9+r10] }
      v53 = v49;
      _RAX = (unsigned __int64)v50 * (unsigned __int128)v49;
      v54 = _RAX;
      __asm { vmovq   rax, xmm0 }
      v55 = v47 & 7;
      _XMM0 = _mm_srli_si128(_XMM0, 8);
      v58 = (*((unsigned __int64 *)&_RAX + 1) + (unsigned __int64)v50 * (unsigned __int128)(unsigned __int64)_RAX) >> 64;
      v57 = (__PAIR128__(v50, v50) * v53) >> 64;
      __asm { vmovq   rax, xmm0 }
      v59 = v50 * _RAX + v58;
      v60 = 0;
      v61 = __CFSHR__(v59, 54 - v55);
      v62 = v59 >> (54 - (unsigned __int8)v55);
      if ( v61 )
      {
        v59 = ~v59;
        v57 = ~v57;
        v54 = ~v54;
        v60 = 0x8000000000000000uLL;
      }
      _EAX = (v61 + (_BYTE)v62) & 3;
      __asm { vmovd   xmm4, eax }
      v64 = v59 << ((unsigned __int8)v55 + 10) >> ((unsigned __int8)v55 + 10);
      v65 = v55 - 54;
      if ( !_BitScanReverse64((unsigned __int64 *)&v67, v64) )
      {
        v64 = v57;
        v57 = v54;
        _BitScanReverse64((unsigned __int64 *)&v67, v64);
        v65 -= 64LL;
      }
      v68 = v67 + v65;
      v69 = v67 - 52;
      if ( v69 < 0 )
      {
        v64 = (v57 >> ((unsigned __int8)v69 + 64)) | (v64 << -(char)v69);
      }
      else if ( v69 )
      {
        v64 >>= v69;
      }
      _R10 = ((v68 + 1023) << 52) | v60 | v64 & 0xFFEFFFFFFFFFFFFFuLL;
      __asm
      {
        vmovq   xmm0, r10
        vmulsd  xmm0, xmm0, cs:qword_180AF3F70
      }
    }
    else
    {
      __asm
      {
        vandpd  xmm1, xmm0, cs:xmmword_180AF3EB0
        vmovapd xmm2, cs:xmmword_180AF3EF0
        vfmadd213sd xmm2, xmm1, cs:qword_180AF3EE0
        vcvttpd2dq xmm2, xmm2
        vpmovsxdq xmm1, xmm2
        vandpd  xmm4, xmm1, cs:xmmword_180AF3ED0
        vshufps xmm1, xmm1, xmm1, 8
        vcvtdq2pd xmm1, xmm1
        vmovdqa xmm2, xmm0
        vfnmadd231sd xmm2, xmm1, cs:qword_180AF3F00
        vmulsd  xmm3, xmm1, cs:qword_180AF3F20
        vsubsd  xmm0, xmm2, xmm3
        vsubsd  xmm2, xmm2, xmm0
        vsubsd  xmm1, xmm2, xmm3
      }
    }
    __asm { vmovq   rax, xmm4 }
    if ( (_RAX & 1) == 1 )
    {
      __asm
      {
        vmovapd xmm2, cs:xmmword_180AF3EC0
        vmulsd  xmm3, xmm0, xmm0
        vfmadd231sd xmm2, xmm3, cs:qword_180AF5010
        vmovsd  xmm1, cs:qword_180AF5028
        vfmadd231sd xmm1, xmm3, cs:qword_180AF5030
        vfmadd213sd xmm1, xmm3, cs:qword_180AF5020
        vfmadd213sd xmm1, xmm3, cs:qword_180AF5018
        vmulsd  xmm3, xmm3, xmm3
        vmovdqa xmm0, xmm2
        vfmadd231sd xmm0, xmm1, xmm3
      }
    }
    else
    {
      __asm
      {
        vmovsd  xmm1, cs:qword_180AF5050
        vmulsd  xmm3, xmm0, xmm0
        vfmadd231sd xmm1, xmm3, cs:qword_180AF5058
        vfmadd213sd xmm1, xmm3, cs:qword_180AF5048
        vfmadd213sd xmm1, xmm3, cs:qword_180AF5040
        vmulsd  xmm3, xmm0, xmm3
        vfmadd231sd xmm0, xmm1, xmm3
      }
    }
    __asm
    {
      vpcmpeqq xmm2, xmm4, cs:xmmword_180AF3F60
      vpcmpeqq xmm3, xmm4, cs:xmmword_180AF3ED0
      vorpd   xmm3, xmm2, xmm3
      vandnpd xmm3, xmm3, cs:xmmword_180AF3EA0
      vxorpd  xmm0, xmm0, xmm3
      vandnpd xmm1, xmm5, cs:xmmword_180AF3EA0
      vxorpd  xmm0, xmm1, xmm0
    }
  }
  else if ( _R9 >= 0x3F80000000000000LL )
  {
    __asm
    {
      vmovapd xmm0, xmm5
      vmovsd  xmm1, cs:qword_180AF5050
      vmulsd  xmm3, xmm0, xmm0
      vfmadd231sd xmm1, xmm3, cs:qword_180AF5058
      vfmadd213sd xmm1, xmm3, cs:qword_180AF5048
      vfmadd213sd xmm1, xmm3, cs:qword_180AF5040
      vmulsd  xmm3, xmm0, xmm3
      vfmadd231sd xmm0, xmm1, xmm3
    }
  }
  else
  {
    if ( _R9 < 0x3F20000000000000LL )
    {
      __asm
      {
        vmovapd xmm1, xmm0
        vmulss  xmm1, xmm0, cs:dword_180AF3FC0
        vaddss  xmm1, xmm1, cs:dword_180AF3FC8
      }
      return X;
    }
    __asm
    {
      vmulsd  xmm1, xmm5, xmm5
      vmulsd  xmm0, xmm1, xmm5
      vfnmadd132sd xmm0, xmm5, cs:qword_180AF3F10
    }
  }
  __asm { vcvtsd2ss xmm0, xmm0, xmm0 }
  return X;
}

