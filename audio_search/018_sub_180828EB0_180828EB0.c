// sub_180828EB0 @ 0x180828EB0 (RVA 0x828EB0)  float_ops=73

void __fastcall sub_180828EB0(__int64 a1, float *a2, float *a3, __int64 a4, int a5, int a6)
{
  float v9; // xmm7_4
  float v10; // xmm6_4
  float v11; // xmm15_4
  float v12; // xmm14_4
  float v13; // xmm2_4
  float v14; // xmm13_4
  float v15; // xmm3_4
  float v16; // xmm12_4
  float v17; // xmm3_4
  int v19; // edx
  int v20; // r8d
  int v21; // r9d
  float v22; // xmm8_4
  int v23; // xmm9_4
  float v24; // xmm1_4
  int v25; // edx
  int v26; // r8d
  int v27; // r9d
  float v28; // xmm2_4
  int v29; // edx
  int v30; // r8d
  int v31; // r9d
  int v32; // edx
  int v33; // r8d
  int v34; // r9d
  __int64 v35; // rdx
  __int64 v36; // rcx
  _DWORD *v37; // rdx
  float v38; // [rsp+118h] [rbp+10h]
  int v40; // [rsp+130h] [rbp+28h]
  float v41; // [rsp+138h] [rbp+30h]

  v9 = a2[2] * 0.5;
  v10 = a2[3] * 0.5;
  v11 = fminf(v9, *(float *)&a5);
  v12 = fminf(v10, *(float *)&a5);
  *(float *)&v40 = v12 + v12;
  sub_18082B220();
  v13 = fminf(v11 + *(float *)&a6, v9 - 1.0);
  v14 = *a2 - (float)-v13;
  v15 = -fminf(v12 + *(float *)&a6, v10 - 1.0);
  v16 = a2[1] - v15;
  v38 = fmaxf((float)(v15 + v15) + a2[3], 0.0);
  v17 = a3[1];
  v41 = fmaxf((float)((float)-v13 - v13) + a2[2], 0.0);
  if ( *(float *)&a4 >= v14
    && *((float *)&a4 + 1) >= v17
    && (float)(v14 + v41) > *(float *)&a4
    && (float)((float)(a2[1] - v17) + v17) > *((float *)&a4 + 1) )
  {
    sub_18082B140(a1);
    sub_18082B140(a1);
    sub_18082B140(a1);
  }
  sub_18082B140(a1);
  v22 = (float)(v11 + v11) * 0.5;
  *(float *)&v23 = *(float *)&v40 * 0.5;
  if ( v22 > 0.0 )
    sub_18082A130(a1, v19, v20, v21, COERCE_INT(*(float *)&v40 * 0.5), 0.0, 0.0, 1.5707964, 0);
  v24 = *a2 + a2[2];
  if ( *(float *)&a4 >= v24
    && *((float *)&a4 + 1) >= v16
    && (float)((float)((float)(a3[2] + *a3) - v24) + v24) > *(float *)&a4
    && (float)(v16 + v38) > *((float *)&a4 + 1) )
  {
    sub_18082B140(a1);
    sub_18082B140(a1);
    sub_18082B140(a1);
  }
  sub_18082B140(a1);
  if ( v22 > 0.0 )
    sub_18082A130(a1, v25, v26, v27, v23, 0.0, 1.5707964, 3.1415927, 0);
  v28 = a2[1] + a2[3];
  if ( *(float *)&a4 >= v14
    && *((float *)&a4 + 1) >= v28
    && (float)(v14 + v41) > *(float *)&a4
    && (float)((float)((float)(a3[3] + a3[1]) - v28) + v28) > *((float *)&a4 + 1) )
  {
    sub_18082B140(a1);
    sub_18082B140(a1);
    sub_18082B140(a1);
  }
  sub_18082B140(a1);
  if ( v22 > 0.0 )
    sub_18082A130(a1, v29, v30, v31, v23, 0.0, 3.1415927, 4.712389, 0);
  if ( *(float *)&a4 >= *a3
    && *((float *)&a4 + 1) >= v16
    && (float)((float)(*a2 - *a3) + *a3) > *(float *)&a4
    && (float)(v16 + v38) > *((float *)&a4 + 1) )
  {
    sub_18082B140(a1);
    sub_18082B140(a1);
    sub_18082B140(a1);
  }
  sub_18082B140(a1);
  if ( v22 > 0.0 )
    sub_18082A130(a1, v32, v33, v34, v23, 0.0, 4.712389, 6.2331853, 0);
  v35 = *(int *)(a1 + 12);
  if ( (_DWORD)v35 && ((int)v35 <= 0 || *(float *)(*(_QWORD *)a1 + 4 * v35 - 4) != 100005.0) )
  {
    sub_1801716F0(a1, (unsigned int)(v35 + 1));
    v36 = *(int *)(a1 + 12);
    *(_DWORD *)(a1 + 12) = v36 + 1;
    v37 = (_DWORD *)(*(_QWORD *)a1 + 4 * v36);
    if ( v37 )
      *v37 = 1203982976;
  }
}

