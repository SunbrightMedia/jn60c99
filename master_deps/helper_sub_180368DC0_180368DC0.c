// sub_180368DC0 @ 0x180368DC0 (RVA 0x368DC0)

double __fastcall sub_180368DC0(double a1)
{
  double v1; // xmm11_8
  double v2; // xmm2_8
  double *v3; // rax
  double v4; // xmm4_8
  double v5; // xmm6_8
  double v6; // xmm8_8

  v1 = fmin(fmax(a1, -20.0), 8.9);
  v2 = v1 * v1 * v1;
  v3 = (double *)((char *)&unk_1809894E0 + 208 * (int)(v1 + 20.0));
  v4 = v2 * v1 * v1;
  v5 = v4 * v1 * v1;
  v6 = v5 * v1 * v1;
  return v1 * v3[2]
       + *v3
       + v1 * v1 * v3[4]
       + v2 * v3[6]
       + v2 * v1 * v3[8]
       + v4 * v3[10]
       + v4 * v1 * v3[12]
       + v5 * v3[14]
       + v5 * v1 * v3[16]
       + v6 * v3[18]
       + v6 * v1 * v3[20]
       + v6 * v1 * v1 * v3[22]
       + v6 * v1 * v1 * v1 * v3[24];
}

