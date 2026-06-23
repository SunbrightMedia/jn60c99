// sub_1806AF460  @ 0x1806AF460  (RVA 0x6AF460)
// prototype: 
// callees: 0x1806AF440, 0x1806AF460
// constants/globals referenced:
//   0x180CB6350 [.data] dword_180CB6350  u32=4294967295  f32=nan  f64=nan
//   0x1806AF590 [.text] loc_1806AF590  u32=4048652616  f32=-1.0375732784053614e+30  f64=1.1016292892906176e+188
//   0x1806AF594 [.text] loc_1806AF594  u32=1727615369  f32=5.8868665619744766e+23  f64=-2.2731370582610447e-265
//   0x1806AF597 [.text] loc_1806AF597  u32=4249979238  f32=-1.7407629037152891e+37  f64=-3.6107768157846266e+19
//   0x1806AF59B [.text] loc_1806AF59B  u32=3288289672  f32=-510.636962890625  f64=6.1396736482625736e+84
//   0x1806AF59E [.text] locret_1806AF59E  u32=2303234243  f32=-2.4142190937882828e-33  f64=6.302593194330853e+84
//   0x1806AF5A0 [.text] loc_1806AF5A0  u32=4098984264  f32=-6.640468981794313e+31  f64=-3.2649020617736356e+19
//   0x1806AF5A4 [.text] loc_1806AF5A4  u32=3288093065  f32=-504.6369934082031  f64=-5.6544883560452e+266
//   0x1806AF5A8 [.text] loc_1806AF5A8  u32=4149315912  f32=-4.2499001483483605e+33  f64=-3.6107767745529283e+19
//   0x1806AF5B0 [.text] loc_1806AF5B0  u32=4082207048  f32=-1.6601172454485783e+31  f64=-2.1180726906899595e-265
//   0x1806AF5B4 [.text] loc_1806AF5B4  u32=2298171785  f32=-1.5125681824400439e-33  f64=1.0062955332771038e-232
//   0x1806AF5C0 [.text] loc_1806AF5C0  u32=4065429832  f32=-4.150293113621446e+30  f64=1.1451401162556144e+188
//   0x1806AF5C4 [.text] loc_1806AF5C4  u32=1727680905  f32=5.910478394388825e+23  f64=-3.495485391409149e+19
//   0x1806AF5C7 [.text] loc_1806AF5C7  u32=4266756454  f32=-6.963051614861157e+37  f64=5.21150577201186e-229
//   0x1806AF5CC [.text] loc_1806AF5CC  u32=3272640840  f32=-144.5362548828125  f64=4.391519701287638e+183
//   0x1806AF5D0 [.text] loc_1806AF5D0  u32=1712359752  f32=1.7063829140452446e+23  f64=-5.753087317920182e-270
//   0x1806AF5E0 [.text] loc_1806AF5E0  u32=1712359752  f32=1.7063829140452446e+23  f64=-855493811769641.0
//   0x1806AF5E8 [.text] loc_1806AF5E8  u32=1209043272  f32=148005.125  f64=-855493748855081.0
//   0x180000000 [?]   u32=4294967295  f32=nan  f64=nan
//   0x1806AF52C [.text] jpt_1806AF58B  u32=7009694  f32=9.822673437586884e-39  f64=1.1997329628462057e-306

__int64 __fastcall sub_1806AF460(__m128i *a1, unsigned __int8 a2, unsigned __int64 a3)
{
  __m128i v4; // xmm0
  __m128i *v5; // rcx
  unsigned __int64 v6; // r9
  unsigned __int64 i; // r9
  unsigned __int64 v8; // r8
  __int64 result; // rax
  __int64 v11; // kr18_8
  __int8 *v12; // rcx

  v11 = 0x101010101010101LL * a2;
  v12 = &a1->m128i_i8[a3];
  result = (__int64)a1;
  switch ( a3 )
  {
    case 0uLL:
      return result;
    case 1uLL:
      goto LABEL_16;
    case 2uLL:
      goto LABEL_24;
    case 3uLL:
      goto LABEL_15;
    case 4uLL:
      goto LABEL_18;
    case 5uLL:
      goto LABEL_21;
    case 6uLL:
      goto LABEL_23;
    case 7uLL:
      goto LABEL_14;
    case 8uLL:
      a1->m128i_i64[0] = v11;
      return result;
    case 9uLL:
      *(_QWORD *)(v12 - 9) = v11;
      *(v12 - 1) = v11;
      return result;
    case 0xAuLL:
      a1->m128i_i64[0] = v11;
      a1->m128i_i16[4] = v11;
      return result;
    case 0xBuLL:
      a1->m128i_i64[0] = v11;
      a1->m128i_i16[4] = v11;
      a1->m128i_i8[10] = v11;
      return result;
    case 0xCuLL:
      *(_QWORD *)(v12 - 12) = v11;
LABEL_18:
      *((_DWORD *)v12 - 1) = v11;
      return result;
    case 0xDuLL:
      *(_QWORD *)(v12 - 13) = v11;
LABEL_21:
      *(_DWORD *)(v12 - 5) = v11;
      *(v12 - 1) = v11;
      return result;
    case 0xEuLL:
      *(_QWORD *)(v12 - 14) = v11;
LABEL_23:
      *(_DWORD *)(v12 - 6) = v11;
LABEL_24:
      *((_WORD *)v12 - 1) = v11;
      return result;
    case 0xFuLL:
      *(_QWORD *)(v12 - 15) = v11;
LABEL_14:
      *(_DWORD *)(v12 - 7) = v11;
LABEL_15:
      *(_WORD *)(v12 - 3) = v11;
LABEL_16:
      *(v12 - 1) = v11;
      return result;
    case 0x10uLL:
      a1->m128i_i64[0] = v11;
      a1->m128i_i64[1] = v11;
      return result;
    default:
      v5 = a1;
      v4 = _mm_unpacklo_epi8((__m128i)(unsigned __int64)v11, (__m128i)(unsigned __int64)v11);
      if ( a3 <= 0x80 )
        goto LABEL_7;
      if ( _bittest(&dword_180CB6350, 1u) )
        return sub_1806AF440(a1, a2, a3);
      *a1 = v4;
      v5 = (__m128i *)((unsigned __int64)&a1[1] & 0xFFFFFFFFFFFFFFF0uLL);
      a3 = &a1->m128i_i8[a3] - (__int8 *)v5;
      v6 = a3 >> 7;
      if ( a3 >> 7 )
      {
        do
        {
          *v5 = v4;
          v5[1] = v4;
          v5 += 8;
          v5[-6] = v4;
          v5[-5] = v4;
          --v6;
          v5[-4] = v4;
          v5[-3] = v4;
          v5[-2] = v4;
          v5[-1] = v4;
        }
        while ( v6 );
        a3 &= 0x7Fu;
      }
LABEL_7:
      for ( i = a3 >> 4; i; --i )
        *v5++ = v4;
      v8 = a3 & 0xF;
      if ( v8 )
        *(__m128i *)((char *)v5 + v8 - 16) = v4;
      return (__int64)a1;
  }
}

