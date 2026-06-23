// sub_180825150 @ 0x180825150 (RVA 0x825150)  float_ops=99

char __fastcall sub_180825150(__int64 a1)
{
  float v2; // xmm10_4
  float v3; // xmm11_4
  float v4; // xmm13_4
  float v5; // xmm14_4
  __int64 v6; // rcx
  float *v7; // rdx
  float v8; // xmm9_4
  float v9; // xmm4_4
  float v10; // xmm3_4
  float *v11; // rax
  bool v12; // zf
  float v13; // xmm2_4
  float v14; // xmm7_4
  float v15; // xmm6_4
  float v16; // xmm0_4
  float v17; // xmm14_4
  float *v18; // rcx
  float *v19; // rcx
  int v20; // eax
  float *v21; // rcx
  float *v22; // rcx
  __int64 v23; // rdx
  _BYTE *v24; // r8
  unsigned __int64 v25; // rdi
  size_t v26; // rdx
  char *v27; // rax
  float v28; // xmm1_4
  float v29; // xmm2_4
  float v30; // xmm7_4
  float v31; // xmm5_4
  float v32; // xmm8_4
  float v33; // xmm6_4
  float v34; // xmm3_4
  float v35; // xmm4_4
  float v36; // xmm0_4
  float *v37; // rax
  float *v38; // rax
  char *v39; // rcx
  __int64 v40; // rdx
  _BYTE *v41; // r8
  unsigned __int64 v42; // rdi
  size_t v43; // rdx
  char *v44; // rax
  float v45; // xmm15_4
  float v46; // xmm13_4
  float v47; // xmm0_4
  float v48; // xmm1_4
  float v49; // xmm8_4
  float v50; // xmm9_4
  float v51; // xmm14_4
  float v52; // xmm4_4
  float v53; // xmm6_4
  float v54; // xmm7_4
  float v55; // xmm5_4
  float v56; // xmm1_4
  float v57; // xmm2_4
  int v59; // xmm0_4
  float *v60; // rdx
  float v61; // [rsp+D0h] [rbp+8h]
  float v62; // [rsp+D8h] [rbp+10h]

  v2 = 0.0;
  v3 = 0.0;
  v4 = 0.0;
  v5 = 0.0;
  *(_DWORD *)a1 = *(_DWORD *)(a1 + 8);
  v61 = 0.0;
  v62 = 0.0;
  *(_DWORD *)(a1 + 4) = *(_DWORD *)(a1 + 12);
  while ( 1 )
  {
    v6 = *(_QWORD *)(a1 + 88);
    if ( v6 == *(_QWORD *)(a1 + 80) )
      break;
    v18 = (float *)(v6 - 4);
    *(_QWORD *)(a1 + 88) = v18;
    v8 = *v18;
    if ( *v18 == 100005.0 )
      goto LABEL_19;
    v19 = v18 - 1;
    *(_QWORD *)(a1 + 88) = v19;
    v20 = *(_DWORD *)v19;
    v21 = v19 - 1;
    *(_DWORD *)(a1 + 8) = v20;
    *(_QWORD *)(a1 + 88) = v21;
    *(float *)(a1 + 12) = *v21;
    if ( v8 == 100003.0 )
    {
      *(_QWORD *)(a1 + 88) = v21 - 1;
      v2 = *(v21 - 1);
      *(_QWORD *)(a1 + 88) = v21 - 2;
      v3 = *(v21 - 2);
      goto LABEL_19;
    }
    if ( v8 == 100004.0 )
    {
      *(_QWORD *)(a1 + 88) = v21 - 1;
      v2 = *(v21 - 1);
      *(_QWORD *)(a1 + 88) = v21 - 2;
      v3 = *(v21 - 2);
      *(_QWORD *)(a1 + 88) = v21 - 3;
      v4 = *(v21 - 3);
      *(_QWORD *)(a1 + 88) = v21 - 4;
      v5 = *(v21 - 4);
LABEL_18:
      v62 = v5;
      v61 = v4;
    }
LABEL_19:
    if ( v8 == 100001.0 )
    {
      ++*(_DWORD *)(a1 + 20);
      *(_BYTE *)(a1 + 16) = *(_QWORD *)(a1 + 88) == *(_QWORD *)(a1 + 80)
                         && (v60 = *(float **)(a1 + 56),
                             v60 != (float *)(**(_QWORD **)(a1 + 24) + 4LL * *(int *)(*(_QWORD *)(a1 + 24) + 12LL)))
                         && *v60 == 100005.0
                         && *(float *)(a1 + 8) == *(float *)(a1 + 68)
                         && *(float *)(a1 + 12) == *(float *)(a1 + 72);
      return 1;
    }
    if ( v8 == 100003.0 )
    {
      v22 = *(float **)(a1 + 88);
      v23 = *(_QWORD *)(a1 + 96);
      v24 = *(_BYTE **)(a1 + 80);
      v25 = ((char *)v22 - v24) >> 2;
      if ( v25 >= v23 - 10 )
      {
        *(_QWORD *)(a1 + 96) = 2 * v23;
        v26 = 8 * v23;
        if ( v24 )
          v27 = (char *)j__realloc_base(v24, v26);
        else
          v27 = (char *)j__malloc_base(v26);
        v22 = (float *)&v27[4 * v25];
        *(_QWORD *)(a1 + 80) = v27;
        *(_QWORD *)(a1 + 88) = v22;
      }
      v28 = *(float *)(a1 + 8);
      v29 = *(float *)(a1 + 12);
      v30 = (float)(v28 + v2) * 0.5;
      v31 = (float)(v28 + *(float *)a1) * 0.5;
      v32 = (float)(v29 + v3) * 0.5;
      v33 = (float)(v29 + *(float *)(a1 + 4)) * 0.5;
      v34 = (float)(v30 + v31) * 0.5;
      v35 = (float)(v32 + v33) * 0.5;
      v36 = *(float *)(a1 + 64);
      *v22 = v3;
      v37 = (float *)(*(_QWORD *)(a1 + 88) + 4LL);
      *(_QWORD *)(a1 + 88) = v37;
      *v37 = v2;
      *(_QWORD *)(a1 + 88) += 4LL;
      v38 = *(float **)(a1 + 88);
      if ( (float)((float)((float)(v35 - v29) * (float)(v35 - v29)) + (float)((float)(v34 - v28) * (float)(v34 - v28))) <= v36 )
      {
        *v38 = 100001.0;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v35;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v34;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(_DWORD **)(a1 + 88) = 1203982464;
      }
      else
      {
        *v38 = v32;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v30;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(_DWORD **)(a1 + 88) = 1203982720;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v35;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v34;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v33;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v31;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(_DWORD **)(a1 + 88) = 1203982720;
      }
      *(_QWORD *)(a1 + 88) += 4LL;
    }
    else if ( v8 == 100004.0 )
    {
      v39 = *(char **)(a1 + 88);
      v40 = *(_QWORD *)(a1 + 96);
      v41 = *(_BYTE **)(a1 + 80);
      v42 = (v39 - v41) >> 2;
      if ( v42 >= v40 - 16 )
      {
        *(_QWORD *)(a1 + 96) = 2 * v40;
        v43 = 8 * v40;
        if ( v41 )
          v44 = (char *)j__realloc_base(v41, v43);
        else
          v44 = (char *)j__malloc_base(v43);
        v39 = &v44[4 * v42];
        *(_QWORD *)(a1 + 80) = v44;
        *(_QWORD *)(a1 + 88) = v39;
      }
      v45 = *(float *)(a1 + 64);
      v46 = (float)(v4 + v2) * 0.5;
      v47 = (float)(*(float *)(a1 + 8) + v2) * 0.5;
      v48 = (float)(*(float *)(a1 + 12) + v3) * 0.5;
      v49 = (float)(*(float *)(a1 + 8) + *(float *)a1) * 0.5;
      v50 = (float)(*(float *)(a1 + 12) + *(float *)(a1 + 4)) * 0.5;
      v51 = (float)(v5 + v3) * 0.5;
      v52 = (float)(v46 + v47) * 0.5;
      v53 = (float)(v47 + v49) * 0.5;
      v54 = (float)(v48 + v50) * 0.5;
      v55 = (float)(v51 + v48) * 0.5;
      if ( (float)((float)((float)(v54 - *(float *)(a1 + 12)) * (float)(v54 - *(float *)(a1 + 12)))
                 + (float)((float)(v53 - *(float *)(a1 + 8)) * (float)(v53 - *(float *)(a1 + 8)))) > v45
        || (float)((float)((float)(v55 - v3) * (float)(v55 - v3)) + (float)((float)(v52 - v2) * (float)(v52 - v2))) > v45 )
      {
        *(float *)v39 = v62;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v61;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v51;
        *(_QWORD *)(a1 + 88) += 4LL;
        v5 = v62;
        **(float **)(a1 + 88) = v46;
        v4 = v61;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v55;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v52;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(_DWORD **)(a1 + 88) = 1203982848;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = (float)(v55 + v54) * 0.5;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = (float)(v52 + v53) * 0.5;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v54;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v53;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v50;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v49;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(_DWORD **)(a1 + 88) = 1203982848;
        *(_QWORD *)(a1 + 88) += 4LL;
      }
      else
      {
        v5 = v62;
        v4 = v61;
        *(float *)v39 = v62;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v61;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(_DWORD **)(a1 + 88) = 1203982464;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v55;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v52;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(_DWORD **)(a1 + 88) = 1203982464;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v54;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(float **)(a1 + 88) = v53;
        *(_QWORD *)(a1 + 88) += 4LL;
        **(_DWORD **)(a1 + 88) = 1203982464;
        *(_QWORD *)(a1 + 88) += 4LL;
      }
    }
    else
    {
      v56 = *(float *)(a1 + 8);
      if ( v8 == 100005.0 )
      {
        v57 = *(float *)(a1 + 68);
        if ( v56 != v57 || *(float *)(a1 + 12) != *(float *)(a1 + 72) )
        {
          *(_DWORD *)(a1 + 4) = *(_DWORD *)(a1 + 12);
          *(_DWORD *)(a1 + 12) = *(_DWORD *)(a1 + 72);
          *(float *)a1 = v56;
          *(float *)(a1 + 8) = v57;
          *(_BYTE *)(a1 + 16) = 1;
          return 1;
        }
      }
      else
      {
        v59 = *(_DWORD *)(a1 + 12);
        *(_DWORD *)(a1 + 4) = v59;
        *(_DWORD *)(a1 + 72) = v59;
        *(float *)a1 = v56;
        *(float *)(a1 + 68) = v56;
        *(_DWORD *)(a1 + 20) = -1;
      }
    }
  }
  v7 = *(float **)(a1 + 56);
  if ( v7 != (float *)(**(_QWORD **)(a1 + 24) + 4LL * *(int *)(*(_QWORD *)(a1 + 24) + 12LL)) )
  {
    v8 = *v7;
    *(_QWORD *)(a1 + 56) = v7 + 1;
    if ( v8 == 100005.0 )
      goto LABEL_19;
    v9 = v7[1];
    *(_QWORD *)(a1 + 56) = v7 + 2;
    *(float *)(a1 + 8) = v9;
    v10 = v7[2];
    v11 = v7 + 3;
    *(_QWORD *)(a1 + 56) = v7 + 3;
    *(float *)(a1 + 12) = v10;
    if ( v8 == 100003.0 )
    {
      v2 = *v11;
      *(_QWORD *)(a1 + 56) = v7 + 4;
      v3 = v7[4];
      v12 = *(_BYTE *)(a1 + 76) == 0;
      *(_QWORD *)(a1 + 56) = v7 + 5;
      if ( v12 )
      {
        *(float *)(a1 + 8) = (float)((float)(v10 * *(float *)(a1 + 36)) + (float)(v9 * *(float *)(a1 + 32)))
                           + *(float *)(a1 + 40);
        *(float *)(a1 + 12) = (float)((float)(v10 * *(float *)(a1 + 48)) + (float)(v9 * *(float *)(a1 + 44)))
                            + *(float *)(a1 + 52);
        v13 = v2 * *(float *)(a1 + 44);
        v2 = (float)((float)(v2 * *(float *)(a1 + 32)) + (float)(v3 * *(float *)(a1 + 36))) + *(float *)(a1 + 40);
        v3 = (float)(v13 + (float)(v3 * *(float *)(a1 + 48))) + *(float *)(a1 + 52);
      }
    }
    else
    {
      if ( v8 == 100004.0 )
      {
        v2 = *v11;
        *(_QWORD *)(a1 + 56) = v7 + 4;
        v3 = v7[4];
        *(_QWORD *)(a1 + 56) = v7 + 5;
        v4 = v7[5];
        *(_QWORD *)(a1 + 56) = v7 + 6;
        v61 = v4;
        v5 = v7[6];
        v12 = *(_BYTE *)(a1 + 76) == 0;
        v62 = v5;
        *(_QWORD *)(a1 + 56) = v7 + 7;
        if ( !v12 )
          goto LABEL_19;
        *(float *)(a1 + 8) = (float)((float)(v10 * *(float *)(a1 + 36)) + (float)(v9 * *(float *)(a1 + 32)))
                           + *(float *)(a1 + 40);
        *(float *)(a1 + 12) = (float)((float)(*(float *)(a1 + 48) * *(float *)(a1 + 12))
                                    + (float)(v9 * *(float *)(a1 + 44)))
                            + *(float *)(a1 + 52);
        v14 = v2 * *(float *)(a1 + 44);
        v15 = *(float *)(a1 + 36) * v5;
        v16 = *(float *)(a1 + 48);
        v2 = (float)((float)(*(float *)(a1 + 32) * v2) + (float)(*(float *)(a1 + 36) * v3)) + *(float *)(a1 + 40);
        v17 = (float)(v4 * *(float *)(a1 + 44)) + (float)(v16 * v5);
        v4 = (float)((float)(*(float *)(a1 + 32) * v4) + v15) + *(float *)(a1 + 40);
        v3 = (float)(v14 + (float)(v16 * v3)) + *(float *)(a1 + 52);
        v5 = v17 + *(float *)(a1 + 52);
        goto LABEL_18;
      }
      if ( !*(_BYTE *)(a1 + 76) )
      {
        *(float *)(a1 + 8) = (float)((float)(v10 * *(float *)(a1 + 36)) + (float)(v9 * *(float *)(a1 + 32)))
                           + *(float *)(a1 + 40);
        *(float *)(a1 + 12) = (float)((float)(v9 * *(float *)(a1 + 44))
                                    + (float)(*(float *)(a1 + 48) * *(float *)(a1 + 12)))
                            + *(float *)(a1 + 52);
      }
    }
    goto LABEL_19;
  }
  return 0;
}

