// sub_1801FC350 @ 0x1801FC350 (RVA 0x1FC350)  float_ops=78

__int64 __fastcall sub_1801FC350(__int64 a1, int a2)
{
  double v2; // xmm2_8
  double v5; // xmm5_8
  __int64 v6; // rbx
  double v7; // xmm9_8
  double v8; // xmm3_8
  double v9; // xmm4_8
  int v10; // r9d
  int v11; // edi
  char v12; // dl
  double **v13; // r8
  unsigned int v14; // eax
  __int64 v15; // rcx
  double *v16; // rax
  double v17; // xmm0_8
  double v18; // xmm0_8
  double v19; // rax
  double *v20; // rax
  double v21; // xmm0_8
  double v22; // xmm0_8
  double v23; // rax
  double *v24; // rax
  double v25; // xmm0_8
  double v26; // xmm0_8
  double v27; // rax
  double *v28; // rax
  double v29; // xmm0_8
  double v30; // xmm0_8
  double v31; // rax
  char v32; // r8
  __int64 v33; // rdx
  __int64 v34; // rcx
  double *v35; // rax
  double v36; // xmm0_8
  double v37; // xmm0_8
  double v38; // rax
  double v39; // xmm2_8
  bool v40; // r10
  unsigned __int8 v41; // r8
  int v42; // r9d
  __int64 v43; // rdx
  float *v44; // rax
  float v45; // xmm0_4
  float v46; // xmm1_4
  char v47; // cl
  double v48; // xmm5_8
  float v49; // xmm4_4
  float v50; // xmm3_4
  float v51; // xmm0_4
  double v52; // xmm2_8
  double v53; // xmm0_8
  double v54; // xmm1_8
  double v55; // xmm0_8
  float v56; // xmm4_4
  float v57; // xmm3_4
  float v58; // xmm0_4
  double v59; // xmm2_8
  double v60; // xmm0_8
  double v61; // xmm1_8

  v2 = *(double *)(a1 + 32);
  v5 = 0.0;
  v6 = 32LL * a2;
  v7 = 0.0;
  v8 = 0.0;
  v9 = 0.0;
  v10 = 0;
  v11 = *(_DWORD *)(v6 + *(_QWORD *)(a1 + 64));
  if ( v11 >= 4 )
  {
    v12 = *(_BYTE *)(a1 + 28);
    v13 = (double **)(*(_QWORD *)(a1 + 56) + 16LL + 8LL * a2 * *(_DWORD *)(a1 + 24));
    v14 = ((unsigned int)(v11 - 4) >> 2) + 1;
    v15 = v14;
    v10 = 4 * v14;
    do
    {
      v16 = *(v13 - 2);
      if ( *((_BYTE *)v16 + 72) )
      {
        if ( v12 )
          v17 = v16[3] + v16[1] + v16[4];
        else
          v17 = v16[5] + v16[2] + v16[6];
        v2 = v2 - v17;
      }
      else
      {
        if ( v12 )
          v18 = v16[3] + v16[1] + v16[4];
        else
          v18 = v16[5] + v16[2] + v16[6];
        v19 = *v16;
        v5 = v5 + v18;
        v8 = v8 + *(float *)(*(_QWORD *)&v19 + 36LL);
        v9 = v9 + *(float *)(*(_QWORD *)&v19 + 40LL);
      }
      v20 = *(v13 - 1);
      if ( *((_BYTE *)v20 + 72) )
      {
        if ( v12 )
          v21 = v20[3] + v20[1] + v20[4];
        else
          v21 = v20[5] + v20[2] + v20[6];
        v2 = v2 - v21;
      }
      else
      {
        if ( v12 )
          v22 = v20[3] + v20[1] + v20[4];
        else
          v22 = v20[5] + v20[2] + v20[6];
        v23 = *v20;
        v5 = v5 + v22;
        v8 = v8 + *(float *)(*(_QWORD *)&v23 + 36LL);
        v9 = v9 + *(float *)(*(_QWORD *)&v23 + 40LL);
      }
      v24 = *v13;
      if ( *((_BYTE *)*v13 + 72) )
      {
        if ( v12 )
          v25 = v24[3] + v24[1] + v24[4];
        else
          v25 = v24[5] + v24[2] + v24[6];
        v2 = v2 - v25;
      }
      else
      {
        if ( v12 )
          v26 = v24[3] + v24[1] + v24[4];
        else
          v26 = v24[5] + v24[2] + v24[6];
        v27 = *v24;
        v5 = v5 + v26;
        v8 = v8 + *(float *)(*(_QWORD *)&v27 + 36LL);
        v9 = v9 + *(float *)(*(_QWORD *)&v27 + 40LL);
      }
      v28 = v13[1];
      if ( *((_BYTE *)v28 + 72) )
      {
        if ( v12 )
          v29 = v28[3] + v28[1] + v28[4];
        else
          v29 = v28[5] + v28[2] + v28[6];
        v2 = v2 - v29;
      }
      else
      {
        if ( v12 )
          v30 = v28[3] + v28[1] + v28[4];
        else
          v30 = v28[5] + v28[2] + v28[6];
        v31 = *v28;
        v5 = v5 + v30;
        v8 = v8 + *(float *)(*(_QWORD *)&v31 + 36LL);
        v9 = v9 + *(float *)(*(_QWORD *)&v31 + 40LL);
      }
      v13 += 4;
      --v15;
    }
    while ( v15 );
  }
  if ( v10 < v11 )
  {
    v32 = *(_BYTE *)(a1 + 28);
    v33 = *(_QWORD *)(a1 + 56) + 8LL * (v10 + a2 * *(_DWORD *)(a1 + 24));
    v34 = (unsigned int)(v11 - v10);
    do
    {
      v35 = *(double **)v33;
      if ( *(_BYTE *)(*(_QWORD *)v33 + 72LL) )
      {
        if ( v32 )
          v36 = v35[3] + v35[1] + v35[4];
        else
          v36 = v35[5] + v35[2] + v35[6];
        v2 = v2 - v36;
      }
      else
      {
        if ( v32 )
          v37 = v35[3] + v35[1] + v35[4];
        else
          v37 = v35[5] + v35[2] + v35[6];
        v38 = *v35;
        v5 = v5 + v37;
        v8 = v8 + *(float *)(*(_QWORD *)&v38 + 36LL);
        v9 = v9 + *(float *)(*(_QWORD *)&v38 + 40LL);
      }
      v33 += 8;
      --v34;
    }
    while ( v34 );
  }
  v39 = v2 - v5;
  v40 = v39 > 0.0;
  if ( v39 <= 0.0 )
  {
    if ( v9 != 0.0 )
      v7 = v39 / v9;
  }
  else if ( v8 != 0.0 )
  {
    v7 = v39 / v8;
  }
  v41 = 1;
  v42 = 0;
  if ( v11 > 0 )
  {
    while ( 1 )
    {
      v43 = *(_QWORD *)(*(_QWORD *)(a1 + 56) + 8LL * (v42 + *(_DWORD *)(a1 + 24) * a2));
      if ( !*(_BYTE *)(v43 + 72) )
        break;
LABEL_102:
      if ( ++v42 >= v11 )
        return v41;
    }
    v44 = *(float **)v43;
    if ( v40 )
      v45 = v44[9];
    else
      v45 = v44[10];
    v46 = v44[11];
    v47 = 0;
    v48 = v45 * v7;
    if ( *(_BYTE *)(a1 + 28) )
    {
      if ( v46 <= 0.0 )
      {
        v46 = v44[13];
        if ( v46 == -1.0 )
          v46 = v44[14];
      }
      v49 = v44[14];
      if ( v49 == -1.0 || v49 <= v46 )
      {
        v51 = v44[15];
        v50 = v51;
        if ( v51 == -1.0 || v46 <= v51 )
          v51 = v46;
      }
      else
      {
        v50 = v44[15];
        v51 = v44[14];
      }
      v52 = v51;
      if ( v50 == -1.0 )
      {
        v53 = v52 + v48;
      }
      else
      {
        v54 = v50;
        v53 = v52 + v48;
        if ( v52 + v48 > v50 )
        {
          *(_BYTE *)(v43 + 72) = 1;
LABEL_80:
          *(double *)(v43 + 8) = v54;
          v55 = *(double *)(v43 + 24) + v54 + *(double *)(v43 + 32);
LABEL_99:
          if ( !v47 )
            v41 = 0;
          *(double *)(v6 + *(_QWORD *)(a1 + 64) + 24) = v55 + *(double *)(v6 + *(_QWORD *)(a1 + 64) + 24);
          goto LABEL_102;
        }
      }
      if ( v52 == -1.0 || (v54 = v49, v49 <= v53) )
      {
        v47 = 1;
        v54 = v53;
      }
      else
      {
        *(_BYTE *)(v43 + 72) = 1;
      }
      goto LABEL_80;
    }
    if ( v46 <= 0.0 )
    {
      v46 = v44[16];
      if ( v46 == -1.0 )
        v46 = v44[17];
    }
    v56 = v44[17];
    if ( v56 == -1.0 || v56 <= v46 )
    {
      v58 = v44[18];
      v57 = v58;
      if ( v58 == -1.0 || v46 <= v58 )
        v58 = v46;
    }
    else
    {
      v57 = v44[18];
      v58 = v44[17];
    }
    v59 = v58;
    if ( v57 == -1.0 )
    {
      v60 = v59 + v48;
    }
    else
    {
      v61 = v57;
      v60 = v59 + v48;
      if ( v59 + v48 > v57 )
      {
        *(_BYTE *)(v43 + 72) = 1;
LABEL_98:
        *(double *)(v43 + 16) = v61;
        v55 = *(double *)(v43 + 40) + v61 + *(double *)(v43 + 48);
        goto LABEL_99;
      }
    }
    if ( v59 == -1.0 || (v61 = v56, v56 <= v60) )
    {
      v47 = 1;
      v61 = v60;
    }
    else
    {
      *(_BYTE *)(v43 + 72) = 1;
    }
    goto LABEL_98;
  }
  return v41;
}

