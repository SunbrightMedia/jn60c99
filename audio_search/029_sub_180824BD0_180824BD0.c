// sub_180824BD0 @ 0x180824BD0 (RVA 0x824BD0)  float_ops=57

char __fastcall sub_180824BD0(
        float a1,
        float a2,
        float a3,
        float a4,
        float a5,
        float a6,
        float a7,
        float a8,
        float *a9,
        float *a10,
        float *a11)
{
  float v15; // xmm3_4
  float v16; // xmm1_4
  float v17; // xmm7_4
  float v18; // xmm4_4
  float v19; // xmm8_4
  float v20; // xmm3_4
  float v21; // xmm0_4
  float v22; // xmm1_4
  float v23; // xmm1_4
  float v24; // xmm0_4
  float v25; // xmm3_4
  float v26; // xmm0_4
  float v27; // xmm1_4
  float v28; // xmm5_4
  float v29; // xmm1_4
  float v30; // xmm6_4
  float v31; // xmm5_4
  float v32; // xmm3_4

  if ( a3 == a5 && a4 == a6 )
  {
    *a9 = a3;
    *a10 = a4;
    *a11 = 0.0;
    return 1;
  }
  v15 = a4 - a2;
  v16 = a8 - a6;
  v17 = a7 - a5;
  v18 = a3 - a1;
  v19 = (float)((float)(a8 - a6) * (float)(a3 - a1)) - (float)((float)(a7 - a5) * v15);
  if ( v19 == 0.0 )
  {
    if ( v18 == 0.0 && v15 == 0.0 || v17 == 0.0 && v16 == 0.0 )
      goto LABEL_37;
    if ( v15 == 0.0 )
    {
      if ( v16 != 0.0 )
      {
        v20 = (float)(a2 - a6) / v16;
        v21 = (float)(v20 * v17) + a5;
        *a9 = v21;
        *a10 = a2;
        v22 = (float)(v21 - a3) * (float)(v21 - a3);
        *a11 = v22;
        if ( a3 > a1 == a3 > v21 )
          *a11 = -v22;
        return v20 >= 0.0 && v20 <= 1.0;
      }
    }
    else if ( v16 != 0.0 )
    {
LABEL_23:
      if ( v18 == 0.0 )
      {
        if ( v17 != 0.0 )
        {
          *a9 = a1;
          v25 = (float)(a1 - a5) / v17;
          v26 = (float)(v25 * v16) + a6;
          *a10 = v26;
          v27 = (float)(v26 - a4) * (float)(v26 - a4);
          *a11 = v27;
          if ( a4 > a2 == a4 > v26 )
            *a11 = -v27;
          return v25 >= 0.0 && v25 <= 1.0;
        }
        goto LABEL_31;
      }
      if ( v17 == 0.0 )
      {
LABEL_31:
        if ( v18 != 0.0 )
        {
          *a9 = a5;
          v28 = (float)(a5 - a1) / v18;
          *a10 = (float)(v28 * v15) + a2;
          v29 = (float)((float)(v28 - 1.0) * v15) * (float)((float)(v28 - 1.0) * v15);
          *a11 = v29;
          if ( v28 < 1.0 )
            *a11 = -v29;
          return v28 >= 0.0 && v28 <= 1.0;
        }
      }
LABEL_37:
      *a9 = (float)(a3 + a5) * 0.5;
      *a10 = (float)(a4 + a6) * 0.5;
      *a11 = 0.0;
      return 0;
    }
    if ( v15 != 0.0 )
    {
      v23 = (float)(a6 - a2) / v15;
      *a9 = (float)(v23 * v18) + a1;
      *a10 = a6;
      v24 = (float)((float)(v23 - 1.0) * v18) * (float)((float)(v23 - 1.0) * v18);
      *a11 = v24;
      if ( v23 < 1.0 )
        *a11 = -v24;
      return v23 >= 0.0 && v23 <= 1.0;
    }
    goto LABEL_23;
  }
  v30 = (float)((float)((float)(a2 - a6) * v17) - (float)((float)(a1 - a5) * v16)) / v19;
  *a9 = (float)(v30 * v18) + a1;
  *a10 = (float)(v30 * v15) + a2;
  if ( v30 >= 0.0 && v30 <= 1.0 )
  {
    v31 = (float)((float)((float)(a2 - a6) * v18) - (float)((float)(a1 - a5) * v15)) / v19;
    if ( v31 >= 0.0 && v31 <= 1.0 )
    {
      *a11 = 0.0;
      return 1;
    }
  }
  v32 = (float)((float)(v15 * v15) + (float)(v18 * v18)) * (float)((float)(v30 - 1.0) * (float)(v30 - 1.0));
  *a11 = v32;
  if ( v30 < 1.0 )
    *a11 = -v32;
  return 0;
}

