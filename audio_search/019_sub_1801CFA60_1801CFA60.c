// sub_1801CFA60 @ 0x1801CFA60 (RVA 0x1CFA60)  float_ops=67

double *__fastcall sub_1801CFA60(
        double a1,
        double a2,
        double a3,
        double a4,
        double X,
        char a6,
        char a7,
        double *a8,
        double *a9,
        double *a10,
        double *a11,
        double *a12,
        double *a13)
{
  double v15; // xmm8_8
  double v16; // xmm7_8
  double v17; // xmm0_8
  double v18; // xmm10_8
  double v19; // xmm9_8
  double v20; // xmm6_8
  double v21; // xmm7_8
  double v22; // xmm9_8
  double v23; // xmm6_8
  double v24; // xmm1_8
  double v25; // xmm0_8
  double v26; // xmm0_8
  double v27; // xmm10_8
  double v28; // xmm7_8
  double v29; // xmm2_8
  double v30; // xmm7_8
  double v31; // xmm14_8
  double v32; // xmm9_8
  double v33; // xmm12_8
  double v34; // xmm6_8
  double v35; // xmm0_8
  double v36; // xmm10_8
  double v37; // xmm15_8
  double v38; // xmm0_8
  double v39; // xmm0_8
  double v40; // xmm7_8
  double v41; // xmm0_8
  double v43; // [rsp+E0h] [rbp+8h]
  double v44; // [rsp+E8h] [rbp+10h]

  v15 = (a1 - a3) * 0.5;
  v16 = (a2 - a4) * 0.5;
  v43 = cos(X);
  v17 = sin(X);
  v18 = *a8;
  v19 = v17 * v16;
  v20 = v43 * v16;
  v21 = *a9;
  v22 = v19 + v43 * v15;
  v44 = v17;
  v23 = v20 - v17 * v15;
  v24 = v23 * v23 / (v21 * v21) + v22 * v22 / (v18 * v18);
  if ( v24 > 1.0 )
  {
    v26 = sqrt(v24);
    v27 = v18 * v26;
    v28 = v26;
    v25 = 0.0;
    *a8 = v27;
    v21 = v28 * *a9;
    *a9 = v21;
    v18 = *a8;
  }
  else
  {
    v25 = sqrt(
            fmax(
              (v21 * v21 * (v18 * v18) - v18 * v18 * (v23 * v23) - v21 * v21 * (v22 * v22))
            / (v21 * v21 * (v22 * v22) + v18 * v18 * (v23 * v23)),
              0.0));
    if ( a6 == a7 )
      v25 = -v25;
  }
  v29 = v18 * v23 / v21 * v25;
  v30 = -(v21 * v22 / v18 * v25);
  *a10 = (a1 + a3) * 0.5 + v29 * v43 - v30 * v44;
  *a11 = (a2 + a4) * 0.5 + v29 * v44 + v30 * v43;
  v31 = (v22 - v29) / *a8;
  v32 = (-v22 - v29) / *a8;
  v33 = (v23 - v30) / *a9;
  v34 = (-v23 - v30) / *a9;
  v35 = sub_180700284();
  v36 = -1.0;
  v37 = v35;
  if ( v31 / v35 >= -1.0 )
    v38 = fmin(1.0, v31 / v35);
  else
    v38 = -1.0;
  v39 = acos(v38);
  if ( v33 < 0.0 )
    v39 = -v39;
  *a12 = v39 + 1.570796326794897;
  v40 = (v34 * v33 + v32 * v31) / (sub_180700284() * v37);
  if ( v40 >= -1.0 )
    v36 = fmin(1.0, v40);
  v41 = acos(v36);
  if ( v34 * v31 - v32 * v33 < 0.0 )
    v41 = -v41;
  if ( a7 )
  {
    if ( v41 < 0.0 )
      v41 = v41 + 6.283185307179586;
  }
  else if ( v41 > 0.0 )
  {
    v41 = v41 - 6.283185307179586;
  }
  *a13 = fmod(v41, 6.283185307179586);
  return a13;
}

