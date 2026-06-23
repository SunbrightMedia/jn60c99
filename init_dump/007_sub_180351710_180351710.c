// sub_180351710  @ 0x180351710  (RVA 0x351710)  floats=38
// .rdata float constants referenced by this function:
//   0x1809380C0  xmmword_1809380C0 = 0.0
//   0x18094A3C0  dword_18094A3C0 = 0.003921568859368563
//   0x1809694B4  dword_1809694B4 = 9.51995048126264e-07
//   0x1809694B8  dword_1809694B8 = 1.3844022760167718e-05
//   0x1809694BC  dword_1809694BC = 0.0001409579999744892
//   0x1809694C0  dword_1809694C0 = 0.0005850030574947596
//   0x1809694C4  dword_1809694C4 = 0.0035156249068677425
//   0x1809694C8  dword_1809694C8 = 0.00392200006172061
//   0x1809694CC  dword_1809694CC = 0.09964045882225037
//   0x1809694D0  dword_1809694D0 = 0.1111111119389534
//   0x1809694E8  qword_1809694E8 = 0.0003679687506519258
//   0x1809694F0  dword_1809694F0 = 5.665767192840576
//   0x1809694F4  dword_1809694F4 = 790.0
//   0x180969540  xmmword_180969540 = 0.015625
//   0x180969550  xmmword_180969550 = 0.0416666679084301
//   0x180969560  xmmword_180969560 = 0.046875
//   0x180969570  xmmword_180969570 = 0.09375
//   0x180969580  xmmword_180969580 = 0.125
//   0x180969590  xmmword_180969590 = 0.0
//   0x1809695A0  xmmword_1809695A0 = 0.25
//   0x1809695B0  xmmword_1809695B0 = 0.3333333432674408
//   0x1809695C0  xmmword_1809695C0 = 0.0
//   0x1809695D0  xmmword_1809695D0 = 0.09420553594827652
//   0x1809695E0  xmmword_1809695E0 = 0.75
//   0x1809695F0  xmmword_1809695F0 = 0.2666666805744171
//   0x180969600  xmmword_180969600 = 0.2682832181453705
//   0x180969610  xmmword_180969610 = 0.5333333611488342
//   0x180969620  xmmword_180969620 = 0.800000011920929
//   0x180969630  xmmword_180969630 = 0.5899525880813599
//   0x180969640  xmmword_180969640 = 2.0
//   0x180AE4F5C  dword_180AE4F5C = 0.00390625
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE5130  flt_180AE5130 = 1.600000023841858
//   0x180AE51A0  dbl_180AE51A0 = 0.0
//   0x180AE5258  dbl_180AE5258 = 0.0
//   0x180AE5358  flt_180AE5358 = 10.0
//   0x180AE53B0  dword_180AE53B0 = 20.0

// Hidden C++ exception states: #wind=5
__int64 __fastcall sub_180351710(__int64 *a1, __int64 a2)
{
  __int64 v4; // rax
  void *v5; // rcx
  __int64 i; // r15
  __int64 v7; // rcx
  __int64 v8; // r14
  __int64 v9; // r8
  unsigned int v10; // ecx
  __int64 v11; // rax
  void *v12; // rcx
  unsigned __int8 v13; // bl
  __int64 v14; // rax
  __int64 v15; // rax
  __int64 v16; // rax
  __int64 v17; // rax
  int k; // r9d
  int v19; // ebx
  int v20; // edi
  float v21; // xmm1_4
  int v22; // r10d
  __int64 v23; // r9
  signed int v24; // ecx
  float v25; // xmm0_4
  int m; // r9d
  float v27; // xmm0_4
  float v28; // xmm0_4
  float v29; // xmm3_4
  float v30; // xmm2_4
  float v31; // xmm3_4
  float v32; // xmm2_4
  float v33; // xmm6_4
  int j; // ebx
  float v35; // xmm0_4
  void *v36; // rcx
  void *v37; // rcx
  _QWORD v39[3]; // [rsp+28h] [rbp-E0h] BYREF
  __int64 v40; // [rsp+40h] [rbp-C8h]
  _QWORD v41[2]; // [rsp+48h] [rbp-C0h] BYREF
  _QWORD v42[2]; // [rsp+58h] [rbp-B0h]
  __m128i v43; // [rsp+68h] [rbp-A0h] BYREF
  __m128i si128; // [rsp+78h] [rbp-90h]
  __m128i v45; // [rsp+88h] [rbp-80h]
  __m128i v46; // [rsp+98h] [rbp-70h]
  _OWORD v47[5]; // [rsp+A8h] [rbp-60h]

  v42[1] = -2;
  v4 = sub_18033BC80(qword_180CB05B8, &v43, 0);
  sub_18032B990(v41, *(_QWORD *)(v4 + 16), v39);
  if ( si128.m128i_i64[1] >= 0x10uLL )
  {
    v5 = (void *)v43.m128i_i64[0];
    if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
    {
      v5 = *(void **)(v43.m128i_i64[0] - 8);
      if ( (unsigned __int64)(v43.m128i_i64[0] - (_QWORD)v5 - 8) > 0x1F )
        invalid_parameter_noinfo_noreturn();
    }
    j_j_free(v5);
  }
  si128 = _mm_load_si128((const __m128i *)&xmmword_1809380C0);
  v43.m128i_i8[0] = 0;
  sub_18032B990(&v39[1], 222, v39);
  if ( !(unsigned __int8)sub_1803F1330(a2, v41) || !(unsigned __int8)sub_1803F1330(a2, &v39[1]) )
  {
    v13 = 0;
    goto LABEL_102;
  }
  for ( i = 0; i < 31; ++i )
  {
    v7 = dword_180C44290[2 * i];
    v8 = dword_180C44294[2 * i];
    v9 = *(_BYTE *)(v39[1] + v7 + 1) & 0xF | (16 * (*(_BYTE *)(v39[1] + v7) & 0xFu));
    switch ( (int)v7 )
    {
      case 4:
        *(_BYTE *)(v8 + *a1) = (unsigned int)v9 >> 4;
        *(_BYTE *)(*a1 + v8 + 1) = v9 & 0xF;
        v27 = (float)(int)v9 * 0.0039215689;
        *((float *)v39 + 1) = v27;
        *(_BYTE *)(*a1 + 652) = LODWORD(v27) >> 28;
        *(_BYTE *)(*a1 + 653) = HIBYTE(v27) & 0xF;
        *(_BYTE *)(*a1 + 654) = (LODWORD(v27) >> 20) & 0xF;
        *(_BYTE *)(*a1 + 655) = BYTE2(v27) & 0xF;
        *(_BYTE *)(*a1 + 656) = (LODWORD(v27) >> 12) & 0xF;
        *(_BYTE *)(*a1 + 657) = BYTE1(v27) & 0xF;
        *(_BYTE *)(*a1 + 658) = (LODWORD(v27) >> 4) & 0xF;
        *(_BYTE *)(*a1 + 659) = LOBYTE(v27) & 0xF;
        continue;
      case 18:
        LOBYTE(v9) = (*(_BYTE *)(v39[1] + v7 + 1) & 0xF | (16 * (*(_BYTE *)(v39[1] + v7) & 0xF))) + 2;
        *(_BYTE *)(*a1 + 33) = v9;
        continue;
      case 20:
      case 54:
      case 56:
        goto LABEL_9;
      case 26:
      case 28:
        v14 = *a1;
        if ( !(_DWORD)v9 )
          goto LABEL_33;
        *(_BYTE *)(v8 + v14) = 10;
        *(_BYTE *)(*a1 + v8 + 1) = 13;
        continue;
      case 30:
        if ( !*(_WORD *)(v39[1] + 34LL) )
          goto LABEL_32;
        v29 = (float)(int)v9 * 0.0039220001;
        v9 = 0;
        do
        {
          if ( (int)v9 > 128 )
            v30 = (float)((float)((float)((float)(0.00058500306 - (float)((float)(int)v9 * 0.00000095199505))
                                        * (float)(int)v9)
                                - 0.099640459)
                        * (float)(int)v9)
                + 5.6657672;
          else
            v30 = (float)(int)v9 * 0.00390625;
          if ( v30 >= v29 )
            break;
          v9 = (unsigned int)(v9 + 1);
        }
        while ( (int)v9 < 256 );
        if ( (int)v9 >= 255 )
          v9 = 255;
        LOBYTE(v10) = ((int)v9 >> 4) & 0xF;
        goto LABEL_11;
      case 32:
        v31 = powf((float)(int)v9, 1.6) * 0.000140958;
        v9 = 0;
        do
        {
          if ( (int)v9 > 128 )
            v32 = (float)((float)((float)((float)(0.00058500306 - (float)((float)(int)v9 * 0.00000095199505))
                                        * (float)(int)v9)
                                - 0.099640459)
                        * (float)(int)v9)
                + 5.6657672;
          else
            v32 = (float)(int)v9 * 0.00390625;
          if ( v32 >= v31 )
            break;
          v9 = (unsigned int)(v9 + 1);
        }
        while ( (int)v9 < 256 );
        if ( (int)v9 >= 255 )
          v9 = 255;
        LOBYTE(v10) = ((int)v9 >> 4) & 0xF;
        goto LABEL_11;
      case 46:
        *(_BYTE *)(v8 + *a1) = (unsigned int)v9 >> 4;
        *(_BYTE *)(*a1 + v8 + 1) = v9 & 0xF;
        v28 = (float)(int)v9 * 0.0039215689;
        *((float *)v39 + 1) = v28;
        *(_BYTE *)(*a1 + 1854) = LODWORD(v28) >> 28;
        *(_BYTE *)(*a1 + 1855) = HIBYTE(v28) & 0xF;
        *(_BYTE *)(*a1 + 1856) = (LODWORD(v28) >> 20) & 0xF;
        *(_BYTE *)(*a1 + 1857) = BYTE2(v28) & 0xF;
        *(_BYTE *)(*a1 + 1858) = (LODWORD(v28) >> 12) & 0xF;
        *(_BYTE *)(*a1 + 1859) = BYTE1(v28) & 0xF;
        *(_BYTE *)(*a1 + 1860) = (LODWORD(v28) >> 4) & 0xF;
        *(_BYTE *)(*a1 + 1861) = LOBYTE(v28) & 0xF;
        continue;
      case 52:
        if ( *(_BYTE *)(v39[1] + 51LL) )
        {
LABEL_9:
          v9 = ((unsigned int)v9 >> 1) + 128;
LABEL_10:
          v10 = (unsigned int)v9 >> 4;
LABEL_11:
          *(_BYTE *)(v8 + *a1) = v10;
          LOBYTE(v9) = v9 & 0xF;
          *(_BYTE *)(*a1 + v8 + 1) = v9;
        }
        else
        {
          *(_BYTE *)(v8 + *a1) = (((255 - (int)v9) / 2 + 1) >> 4) & 0xF;
          *(_BYTE *)(*a1 + v8 + 1) = ((255 - (int)v9) / 2 + 1) & 0xF;
        }
        continue;
      case 68:
        v15 = *a1;
        if ( (_DWORD)v9 )
          *(_BYTE *)(v15 + 475) = 0;
        else
          *(_BYTE *)(v15 + 475) = 2;
        continue;
      case 70:
        v33 = log10f((float)((float)((float)(int)v9 * (float)(int)v9) * 0.000013844023) + 0.1) * 20.0;
        for ( j = 0; j < 256; ++j )
        {
          v35 = (float)((float)(powf(10.0, (double)j * 0.00392156862745098) - 1.0) * 0.11111111) * 4.1349;
          if ( j == 128 )
            v35 = 1.0;
          if ( (float)(log10f(v35) * 20.0) >= v33 )
            break;
        }
        if ( j >= 255 )
          j = 255;
        *(_BYTE *)(v8 + *a1) = (j >> 4) & 0xF;
        *(_BYTE *)(*a1 + v8 + 1) = j & 0xF;
        continue;
      case 100:
        v16 = *a1;
        if ( (_DWORD)v9 )
        {
          if ( (unsigned int)v9 > 3 )
            v9 = 3;
          LOBYTE(v9) = v9 + 1;
          *(_BYTE *)(v16 + 619) = v9;
          *(_BYTE *)(*a1 + 626) = 7;
          *(_BYTE *)(*a1 + 627) = 15;
          *(_BYTE *)(*a1 + 100) = 15;
          *(_BYTE *)(*a1 + 101) = 15;
        }
        else
        {
          *(_BYTE *)(v16 + 100) = 0;
          *(_BYTE *)(*a1 + 101) = 0;
        }
        continue;
      case 102:
        if ( !*(_WORD *)(v39[1] + 110LL) )
          goto LABEL_32;
        v43 = (__m128i)xmmword_180969590;
        si128 = (__m128i)xmmword_1809695D0;
        v45 = (__m128i)xmmword_180969600;
        v46 = (__m128i)xmmword_180969630;
        for ( k = 0; k < 256; ++k )
        {
          if ( (float)((float)k * 0.00390625) >= *(float *)&v43.m128i_i32[v9] )
            break;
        }
        if ( k >= 255 )
          k = 255;
        *(_BYTE *)(v8 + *a1) = (k >> 4) & 0xF;
        *(_BYTE *)(*a1 + v8 + 1) = k & 0xF;
        continue;
      case 104:
        if ( !*(_WORD *)(v39[1] + 130LL) )
        {
          v43 = _mm_load_si128((const __m128i *)&xmmword_180969500);
          si128 = _mm_load_si128((const __m128i *)&xmmword_180969510);
          v45 = _mm_load_si128((const __m128i *)&xmmword_180969520);
          v46 = _mm_load_si128((const __m128i *)&xmmword_180969530);
          v19 = 0;
          v20 = v43.m128i_i32[v9];
          do
          {
            v21 = (pow(10.0, (float)((float)v19 * 0.0039215689)) - 1.0) * 0.1111111111111111;
            if ( (int)(float)((float)(v21 * 790.0) + 10.0) >= v20 )
              break;
            ++v19;
          }
          while ( v19 < 256 );
          goto LABEL_45;
        }
        v43 = (__m128i)xmmword_1809695A0;
        si128 = (__m128i)xmmword_180969570;
        v45 = (__m128i)xmmword_180969550;
        v46 = (__m128i)xmmword_180969540;
        v47[0] = xmmword_180969640;
        v47[1] = xmmword_1809695E0;
        v47[2] = xmmword_1809695B0;
        v47[3] = xmmword_180969580;
        v47[4] = xmmword_180969560;
        v19 = 0;
        v22 = 3825;
        v23 = (unsigned int)v9;
        break;
      case 106:
        v43 = (__m128i)xmmword_1809695C0;
        si128 = (__m128i)xmmword_1809695F0;
        v45 = (__m128i)xmmword_180969610;
        v46 = (__m128i)xmmword_180969620;
        for ( m = 0; m < 256; ++m )
        {
          if ( (float)((float)m * 0.0035156249) >= *(float *)&v43.m128i_i32[v9] )
            break;
        }
        if ( m >= 255 )
          m = 255;
        *(_BYTE *)(v8 + *a1) = (m >> 4) & 0xF;
        *(_BYTE *)(*a1 + v8 + 1) = m & 0xF;
        *(_BYTE *)(*a1 + 3043) = 3;
        *(_BYTE *)(*a1 + 3062) = 0;
        *(_BYTE *)(*a1 + 3063) = 0;
        *(_BYTE *)(*a1 + 3064) = 0;
        *(_BYTE *)(*a1 + 3065) = 0;
        *(_BYTE *)(*a1 + 3066) = 0;
        *(_BYTE *)(*a1 + 3067) = 0;
        *(_BYTE *)(*a1 + 3068) = 0;
        *(_BYTE *)(*a1 + 3069) = 12;
        *(_BYTE *)(*a1 + 3070) = 0;
        *(_BYTE *)(*a1 + 3071) = 0;
        *(_BYTE *)(*a1 + 3072) = 0;
        *(_BYTE *)(*a1 + 3073) = 0;
        *(_BYTE *)(*a1 + 3074) = 0;
        *(_BYTE *)(*a1 + 3075) = 0;
        *(_BYTE *)(*a1 + 3076) = 0;
        *(_BYTE *)(*a1 + 3077) = 3;
        continue;
      case 122:
        if ( *(_WORD *)(v39[1] + 120LL) )
          goto LABEL_10;
LABEL_32:
        v14 = *a1;
LABEL_33:
        *(_BYTE *)(v8 + v14) = 0;
        v17 = *a1;
        goto LABEL_34;
      case 126:
        *(_BYTE *)(v8 + *a1) = 0;
        v17 = *a1;
        if ( (_DWORD)v9 == 2 )
        {
          *(_BYTE *)(v17 + v8 + 1) = 1;
        }
        else if ( (_DWORD)v9 == 3 )
        {
          *(_BYTE *)(v17 + v8 + 1) = 2;
        }
        else
        {
LABEL_34:
          *(_BYTE *)(v17 + v8 + 1) = 0;
        }
        continue;
      default:
        goto LABEL_10;
    }
    do
    {
      v24 = ((int)((unsigned __int64)(2155905153LL * v22) >> 32) >> 7)
          + ((unsigned int)((unsigned __int64)(2155905153LL * v22) >> 32) >> 31)
          + 3;
      if ( v24 > 19 )
        v24 = 19;
      if ( (unsigned int)v9 <= 0xA )
      {
        if ( *(float *)&v43.m128i_i32[v9] == *((float *)v47 + v24) )
          break;
        v23 = (unsigned int)v9;
        goto LABEL_58;
      }
      if ( (unsigned int)v9 > 0xD )
      {
        v25 = *((float *)&v41[1] + v23);
      }
      else
      {
        v23 = (unsigned int)v9;
        v25 = *((float *)v42 + v9 + 1);
      }
      if ( v25 == *((float *)v47 + v24) )
        break;
LABEL_58:
      ++v19;
      v22 -= 15;
    }
    while ( v22 > -15 );
LABEL_45:
    if ( v19 >= 255 )
      v19 = 255;
    *(_BYTE *)(v8 + *a1) = (v19 >> 4) & 0xF;
    *(_BYTE *)(*a1 + v8 + 1) = v19 & 0xF;
  }
  v11 = sub_1803F1790(&v43, v41, v9, 3);
  sub_18033CDA0(a1, v11, 0);
  if ( si128.m128i_i64[1] >= 0x10uLL )
  {
    v12 = (void *)v43.m128i_i64[0];
    if ( (unsigned __int64)(si128.m128i_i64[1] + 1) >= 0x1000 )
    {
      v12 = *(void **)(v43.m128i_i64[0] - 8);
      if ( (unsigned __int64)(v43.m128i_i64[0] - (_QWORD)v12 - 8) > 0x1F )
        invalid_parameter_noinfo_noreturn();
    }
    j_j_free(v12);
  }
  v13 = 1;
LABEL_102:
  v36 = (void *)v39[1];
  if ( v39[1] )
  {
    if ( (unsigned __int64)(v40 - v39[1]) >= 0x1000 )
    {
      v36 = *(void **)(v39[1] - 8LL);
      if ( (unsigned __int64)(v39[1] - (_QWORD)v36 - 8LL) > 0x1F )
        invalid_parameter_noinfo_noreturn();
    }
    j_j_free(v36);
    *(_OWORD *)&v39[1] = 0;
    v40 = 0;
  }
  v37 = (void *)v41[0];
  if ( v41[0] )
  {
    if ( v42[0] - v41[0] >= 0x1000u )
    {
      v37 = *(void **)(v41[0] - 8LL);
      if ( (unsigned __int64)(v41[0] - (_QWORD)v37 - 8LL) > 0x1F )
        invalid_parameter_noinfo_noreturn();
    }
    j_j_free(v37);
  }
  return v13;
}

