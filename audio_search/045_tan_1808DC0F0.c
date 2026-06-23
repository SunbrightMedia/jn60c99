// tan @ 0x1808DC0F0 (RVA 0x8DC0F0)  float_ops=45

// local variable allocation has failed, the output may be wrong!
double __cdecl tan(double X)
{
  __int64 v1; // rcx
  unsigned __int64 v4; // rcx
  int v5; // r8d
  double v6; // xmm6_8
  int v7; // r8d
  double v8; // xmm3_8
  double v9; // xmm2_8
  double v10; // xmm6_8
  unsigned __int64 v11; // rdx
  double v12; // xmm1_8
  double v13; // xmm1_8
  char v14; // r8
  int v15; // r10d
  __int64 v17; // rdx
  char v40; // cf
  char v41; // zf
  char v42; // al

  if ( !dword_180CB79DC )
  {
    v4 = *(_QWORD *)&X & 0x7FFFFFFFFFFFFFFFLL;
    if ( (*(_QWORD *)&X & 0x7FFFFFFFFFFFFFFFuLL) > 0x3FE921FB54442D18LL )
    {
      if ( v4 < 0x7FF0000000000000LL )
      {
        v5 = 0;
        v6 = fabs(X);
        if ( v6 >= 500000.0 )
        {
          X = v6;
          v14 = _remainder_piby2_forAsm();
        }
        else
        {
          if ( v4 > 0x400F6A7A2955385ELL )
          {
            if ( v4 > 0x401C463ABECCB2BBLL )
            {
              v7 = (int)(v6 * 0.6366197723675814 + 0.5);
            }
            else
            {
              LOBYTE(v5) = v4 > 0x4015FDBBE9BBA775LL;
              v7 = v5 + 3;
            }
          }
          else
          {
            LOBYTE(v5) = v4 > 0x4002D97C7F3321D2LL;
            v7 = v5 + 1;
          }
          v8 = (double)v7;
          v9 = (double)v7 * 6.077100506506192e-11;
          v10 = v6 - (double)v7 * 1.570796326734126;
          v11 = (v4 >> 52) - ((*(_QWORD *)&v10 >> 52) & 0x7FFLL);
          if ( v11 > 0xF )
          {
            v12 = v10;
            v10 = v10 - v8 * 6.077100506303966e-11;
            v9 = v8 * 2.022266248795951e-21 - (v12 - v10 - v8 * 6.077100506303966e-11);
            if ( v11 > 0x30 )
            {
              v13 = v10;
              v10 = v10 - v8 * 2.022266248711166e-21;
              v9 = v8 * 8.4784276603689e-32 - (v13 - v10 - v8 * 2.022266248711166e-21);
            }
          }
          v14 = v7 & 3;
          X = v10 - v9;
        }
        tan_piby4(v4, v11, v14 & 1);
        if ( v15 )
          return -X;
      }
      else
      {
        return tan_special(v4, *(_QWORD *)&X);
      }
    }
    else if ( v4 >= 0x3F20000000000000LL )
    {
      return tan_piby4(v4, *(_QWORD *)&X, 0);
    }
    else if ( v4 >= 0x3E40000000000000LL )
    {
      return X * X * X * 0.3333333333333333 + X;
    }
    return X;
  }
  __asm { vmovq   r9, xmm0 }
  v17 = _R9;
  _R9 = _R9 & 0x7FFFFFFFFFFFFFFFLL;
  if ( (unsigned __int64)_R9 < 0x3FE921FB54442D18LL )
  {
    __asm
    {
      vmovsd  xmm5, cs:qword_180AF47A0
      vmovsd  xmm6, cs:qword_180AF47B0
      vxorpd  xmm1, xmm1, xmm1
      vxorpd  xmm7, xmm7, xmm7
    }
    if ( (unsigned __int64)_R9 > 0x3FE5C28F5C28F5C3LL )
    {
      if ( X < 0.0 )
      {
        __asm
        {
          vmovsd  xmm7, cs:qword_180AF4830
          vaddsd  xmm0, xmm5, xmm0
          vaddsd  xmm0, xmm0, xmm6
        }
      }
      else
      {
        __asm
        {
          vmovsd  xmm7, cs:qword_180AF4828
          vsubsd  xmm0, xmm5, xmm0
          vaddsd  xmm0, xmm0, xmm6
        }
      }
    }
    else if ( _R9 < 0x3E40000000000000LL )
    {
      if ( X != 0.0 )
      {
        __asm
        {
          vmulsd  xmm1, xmm0, cs:qword_180AF4840
          vaddsd  xmm1, xmm0, cs:qword_180AF4828
        }
      }
      goto Ltan_fma3_ext_piby4_zero;
    }
    __asm
    {
      vmovsd  xmm4, cs:qword_180AF4780
      vmovsd  xmm3, cs:qword_180AF4740
      vmulsd  xmm2, xmm0, xmm0
      vfmadd213sd xmm4, xmm2, cs:qword_180AF4770
      vfmadd213sd xmm3, xmm2, cs:qword_180AF4730
      vfmadd213sd xmm4, xmm2, cs:qword_180AF4760
      vfmadd213sd xmm3, xmm2, cs:qword_180AF4720
      vfmadd213sd xmm4, xmm2, cs:qword_180AF4750
      vdivsd  xmm3, xmm3, xmm4
      vmulsd  xmm3, xmm3, xmm2
      vfmadd132sd xmm0, xmm0, xmm3
    }
    if ( *(double *)&_XMM7 != 0.0 )
    {
      __asm
      {
        vmovsd  xmm3, cs:qword_180AF4828
        vaddsd  xmm4, xmm0, cs:qword_180AF4828
        vdivsd  xmm6, xmm0, xmm4
        vfnmadd231sd xmm3, xmm6, cs:qword_180AF4838
        vmulsd  xmm0, xmm3, xmm7
      }
    }
Ltan_fma3_ext_piby4_zero:
    __asm
    {
      vmovdqa xmm7, [rsp+88h+var_58]
      vmovdqa xmm6, [rsp+88h+var_68]
    }
    return X;
  }
  if ( (unsigned __int64)_R9 >= 0x7FF0000000000000LL )
  {
    tan_special(v1, v17);
    __asm
    {
      vmovdqa xmm7, [rsp+88h+var_58]
      vmovdqa xmm6, [rsp+88h+var_68]
    }
  }
  else
  {
    __asm
    {
      vmovapd [rsp+88h+var_48], xmm0
      vmovq   xmm0, r9
    }
    if ( _R9 >= 0x417312D000000000LL )
      v42 = _remainder_piby2_fma3(v1, v17);
    else
      *(double *)&_XMM0 = _remainder_piby2_fma3_bdl(v1, v17);
    __asm
    {
      vmovsd  xmm5, cs:qword_180AF47A0
      vmovsd  xmm6, cs:qword_180AF47B0
      vxorpd  xmm7, xmm7, xmm7
      vcomisd xmm0, cs:qword_180AF4810
    }
    if ( v40 | v41 )
    {
      __asm { vcomisd xmm0, cs:qword_180AF4818 }
      if ( v40 )
      {
        __asm
        {
          vmovsd  xmm7, cs:qword_180AF4830
          vaddsd  xmm0, xmm5, xmm0
          vaddsd  xmm2, xmm6, xmm1
          vaddsd  xmm0, xmm0, xmm2
          vxorps  xmm1, xmm1, xmm1
        }
      }
    }
    else
    {
      __asm
      {
        vmovsd  xmm7, cs:qword_180AF4828
        vsubsd  xmm0, xmm5, xmm0
        vsubsd  xmm2, xmm6, xmm1
        vaddsd  xmm0, xmm0, xmm2
        vxorps  xmm1, xmm1, xmm1
      }
    }
    __asm
    {
      vmulsd  xmm2, xmm0, xmm0
      vmulsd  xmm5, xmm1, xmm0
      vfmadd132sd xmm5, xmm2, cs:qword_180AF4838
      vmovsd  xmm2, cs:qword_180AF4740
      vfmadd213sd xmm2, xmm5, cs:qword_180AF4730
      vfmadd213sd xmm2, xmm5, cs:qword_180AF4720
      vmovsd  xmm4, cs:qword_180AF4780
      vfmadd213sd xmm4, xmm5, cs:qword_180AF4770
      vfmadd213sd xmm4, xmm5, cs:qword_180AF4760
      vfmadd213sd xmm4, xmm5, cs:qword_180AF4750
      vdivsd  xmm2, xmm2, xmm4
      vmulsd  xmm2, xmm2, xmm5
      vfmadd213sd xmm2, xmm0, xmm1
      vaddsd  xmm1, xmm0, xmm2
      vxorpd  xmm6, xmm6, xmm6
      vcomisd xmm7, xmm6
    }
    if ( v41 )
    {
      if ( (v42 & 1) != 0 )
      {
        __asm
        {
          vandpd  xmm7, xmm1, cs:xmmword_180AF4790
          vsubsd  xmm4, xmm7, xmm0
          vsubsd  xmm4, xmm2, xmm4
          vmovsd  xmm2, cs:qword_180AF4830
          vdivsd  xmm2, xmm2, xmm1
          vandpd  xmm5, xmm2, cs:xmmword_180AF4790
          vfmadd213sd xmm7, xmm5, cs:qword_180AF4828
          vfmadd231sd xmm7, xmm4, xmm5
          vfmadd213sd xmm7, xmm2, xmm5
          vmovapd xmm1, xmm7
        }
      }
    }
    else
    {
      __asm
      {
        vaddsd  xmm6, xmm1, xmm1
        vmovsd  xmm4, cs:qword_180AF4828
        vaddsd  xmm2, xmm1, xmm4
        vsubsd  xmm5, xmm1, xmm4
      }
      if ( (v42 & 1) != 0 )
      {
        __asm
        {
          vsubsd  xmm2, xmm1, xmm4
          vdivsd  xmm2, xmm1, xmm2
          vfmsub132sd xmm2, xmm4, cs:qword_180AF4838
          vmulsd  xmm1, xmm2, xmm7
        }
      }
      else
      {
        __asm
        {
          vaddsd  xmm2, xmm1, xmm4
          vdivsd  xmm2, xmm1, xmm2
          vfnmadd132sd xmm2, xmm4, cs:qword_180AF4838
          vmulsd  xmm1, xmm2, xmm7
        }
      }
    }
    __asm
    {
      vmovapd xmm0, xmm1
      vmovapd xmm1, [rsp+88h+var_48]
      vandpd  xmm1, xmm1, cs:xmmword_180AF46D0
      vxorpd  xmm0, xmm0, xmm1
      vmovdqa xmm7, [rsp+88h+var_58]
      vmovdqa xmm6, [rsp+88h+var_68]
    }
  }
  return X;
}

