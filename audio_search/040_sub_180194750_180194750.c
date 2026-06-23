// sub_180194750 @ 0x180194750 (RVA 0x194750)  float_ops=46

signed __int64 __fastcall sub_180194750(_QWORD *a1, __int64 *a2)
{
  signed __int64 result; // rax
  _DWORD *v3; // r13
  int v4; // r12d
  _DWORD *v5; // rcx
  _DWORD *v7; // r9
  int v8; // r15d
  int v9; // r15d
  int *v10; // r9
  __int64 v11; // rdx
  int v12; // ebp
  int v13; // edi
  float v14; // xmm1_4
  int v15; // r15d
  float v16; // xmm0_4
  float v17; // xmm1_4
  int v18; // eax
  int v19; // r13d
  int v20; // r12d
  int v21; // esi
  int v22; // eax
  int v23; // edi
  __int64 v24; // r14
  double v25; // xmm5_8
  __int64 v26; // rbp
  double v27; // xmm0_8
  unsigned int v28; // r10d
  double v29; // xmm0_8
  int v30; // r8d
  unsigned __int8 *v31; // r9
  unsigned int v32; // ecx
  unsigned int v33; // edx
  unsigned int v34; // eax
  unsigned int v35; // r10d
  double v36; // xmm0_8
  unsigned int v37; // edx
  int v38; // ecx
  unsigned int v39; // r8d
  unsigned int v40; // edx
  int v41; // esi
  int v42; // r12d
  __int64 v43; // rbp
  unsigned __int8 *v44; // r14
  __int64 v45; // r15
  __int64 v46; // rdi
  double v47; // xmm1_8
  double v48; // xmm0_8
  double v49; // xmm1_8
  unsigned int v50; // r9d
  double v51; // xmm0_8
  unsigned int v52; // edx
  int v53; // ecx
  unsigned int v54; // r8d
  unsigned int v55; // edx
  __int64 v56; // r15
  __int64 v57; // rdi
  double v58; // xmm1_8
  double v59; // xmm0_8
  double v60; // xmm1_8
  unsigned int v61; // r9d
  double v62; // xmm0_8
  int v63; // r8d
  unsigned int v64; // ecx
  unsigned int v65; // edx
  int v66; // ebp
  __int64 v67; // r14
  double v68; // xmm5_8
  __int64 v69; // rsi
  int v70; // edi
  double v71; // xmm0_8
  unsigned int v72; // r10d
  double v73; // xmm0_8
  int v74; // r8d
  unsigned __int8 *v75; // r9
  unsigned int v76; // ecx
  unsigned int v77; // edx
  unsigned int v78; // eax
  unsigned int v79; // r10d
  double v80; // xmm0_8
  unsigned int v81; // edx
  int v82; // ecx
  unsigned int v83; // r8d
  unsigned int v84; // edx
  int i; // [rsp+20h] [rbp-68h]
  _DWORD *v86; // [rsp+28h] [rbp-60h]
  int *v87; // [rsp+38h] [rbp-50h]
  _UNKNOWN *retaddr; // [rsp+88h] [rbp+0h] BYREF
  int v90; // [rsp+A0h] [rbp+18h]
  int v91; // [rsp+A8h] [rbp+20h]

  result = (signed __int64)&retaddr;
  v3 = a1;
  v4 = 0;
  v5 = (_DWORD *)*a1;
  for ( i = 0; v4 < v3[5]; i = v4 )
  {
    result = (int)v3[7];
    v7 = v5;
    v8 = *v5;
    v5 += result;
    v9 = v8 - 1;
    v86 = v5;
    if ( v9 > 0 )
    {
      v10 = v7 + 1;
      v11 = a2[14];
      v12 = 0;
      v13 = *v10;
      result = (unsigned int)((v4 + v3[3]) * *(_DWORD *)(v11 + 12));
      v14 = (float)(v4 + v3[3]);
      v15 = v9 - 1;
      a2[15] = *(_QWORD *)v11 + (int)result;
      v90 = v15;
      v16 = v14 * *((float *)a2 + 23);
      v17 = (float)(v14 * *((float *)a2 + 26)) + *((float *)a2 + 27);
      *((double *)a2 + 9) = (float)(v16 + *((float *)a2 + 24)) - *((double *)a2 + 2);
      *((double *)a2 + 10) = v17 - *((double *)a2 + 3);
      if ( v15 >= 0 )
      {
        do
        {
          v18 = v10[2];
          v19 = v10[1];
          v10 += 2;
          v20 = v18 >> 8;
          v21 = v13 >> 8;
          v87 = v10;
          v91 = v18;
          if ( v18 >> 8 == v13 >> 8 )
          {
            v22 = v18 - v13;
            v13 = v91;
            result = (unsigned int)(v19 * v22);
            v12 += result;
          }
          else
          {
            result = (unsigned __int8)v13;
            v23 = (v12 + v19 * (256 - (unsigned __int8)v13)) >> 8;
            if ( v23 > 0 )
            {
              v24 = *a2;
              v25 = *((double *)a2 + 4);
              v26 = *((int *)a2 + 2);
              v27 = (*((double *)a2 + 8) * (double)v21 + *((double *)a2 + 9))
                  * (*((double *)a2 + 8) * (double)v21 + *((double *)a2 + 9))
                  + (*((double *)a2 + 7) * (double)v21 + *((double *)a2 + 10))
                  * (*((double *)a2 + 7) * (double)v21 + *((double *)a2 + 10));
              if ( v23 < 255 )
              {
                if ( v27 < v25 )
                {
                  v36 = sqrt(v27) * *((double *)a2 + 5) + 6.755399441055744e15;
                  if ( SLODWORD(v36) < (int)v26 )
                    LODWORD(v26) = LODWORD(v36);
                  v35 = *(_DWORD *)(v24 + 4LL * (int)v26);
                }
                else
                {
                  v35 = *(_DWORD *)(v24 + 4 * v26);
                }
                v37 = ((v23 * ((v35 >> 8) & 0xFF00FF)) >> 8) & 0xFF00FF;
                v31 = (unsigned __int8 *)(a2[15] + v21 * *(_DWORD *)(a2[14] + 16));
                v38 = 256 - HIWORD(v37);
                v39 = v37 + ((v38 * (unsigned int)v31[1]) >> 8);
                v40 = (((v23 * (v35 & 0xFF00FF)) >> 8) & 0xFF00FF)
                    + (((unsigned int)(v38 * (*v31 | (v31[2] << 16))) >> 8) & 0xFF00FF);
                *v31 = v40 | -BYTE1(v40);
                v31[1] = v39 | -BYTE1(v39);
                v34 = (v40 | (256 - ((v40 >> 8) & 0xFF00FF))) & 0xFF00FF;
              }
              else
              {
                if ( v27 < v25 )
                {
                  v29 = sqrt(v27) * *((double *)a2 + 5) + 6.755399441055744e15;
                  if ( SLODWORD(v29) < (int)v26 )
                    LODWORD(v26) = LODWORD(v29);
                  v28 = *(_DWORD *)(v24 + 4LL * (int)v26);
                }
                else
                {
                  v28 = *(_DWORD *)(v24 + 4 * v26);
                }
                v30 = 256 - HIBYTE(v28);
                v31 = (unsigned __int8 *)(a2[15] + v21 * *(_DWORD *)(a2[14] + 16));
                v32 = v30 * v31[1];
                v33 = (((v28 & 0xFF00FF) + (((unsigned int)(v30 * (*v31 | (v31[2] << 16))) >> 8) & 0xFF00FF))
                     | (256
                      - ((((v28 & 0xFF00FF) + (((unsigned int)(v30 * (*v31 | (v31[2] << 16))) >> 8) & 0xFF00FF)) >> 8)
                       & 0xFF00FF)))
                    & 0xFF00FF;
                *v31 = (v28 + ((unsigned __int16)((256 - HIBYTE(v28)) * *v31) >> 8))
                     | -((unsigned __int16)((unsigned __int8)v28
                                          + (unsigned __int8)((unsigned __int16)((256 - HIBYTE(v28)) * *v31) >> 8)) >> 8);
                v31[1] = (BYTE1(v28) + BYTE1(v32))
                       | -((unsigned __int16)(BYTE1(v28) + (unsigned __int16)(v32 >> 8)) >> 8);
                v34 = v33;
              }
              result = HIWORD(v34);
              v31[2] = result;
            }
            if ( v19 > 0 )
            {
              v41 = v21 + 1;
              v42 = v20 - v41;
              if ( v42 > 0 )
              {
                v43 = *(int *)(a2[14] + 16);
                v44 = (unsigned __int8 *)(a2[15] + v41 * *(_DWORD *)(a2[14] + 16));
                if ( v19 >= 255 )
                {
                  do
                  {
                    v56 = *a2;
                    v57 = *((int *)a2 + 2);
                    v58 = (double)v41 * *((double *)a2 + 8) + *((double *)a2 + 9);
                    v59 = (double)v41 * *((double *)a2 + 7) + *((double *)a2 + 10);
                    v60 = v58 * v58 + v59 * v59;
                    if ( v60 < *((double *)a2 + 4) )
                    {
                      v62 = sqrt(v60) * *((double *)a2 + 5) + 6.755399441055744e15;
                      if ( SLODWORD(v62) < (int)v57 )
                        LODWORD(v57) = LODWORD(v62);
                      v61 = *(_DWORD *)(v56 + 4LL * (int)v57);
                    }
                    else
                    {
                      v61 = *(_DWORD *)(v56 + 4 * v57);
                    }
                    v63 = 256 - HIBYTE(v61);
                    ++v41;
                    --v42;
                    v64 = v63 * v44[1];
                    v65 = (((v61 & 0xFF00FF) + (((unsigned int)(v63 * (*v44 | (v44[2] << 16))) >> 8) & 0xFF00FF))
                         | (256
                          - ((((v61 & 0xFF00FF) + (((unsigned int)(v63 * (*v44 | (v44[2] << 16))) >> 8) & 0xFF00FF)) >> 8)
                           & 0xFF00FF)))
                        & 0xFF00FF;
                    *v44 = (v61 + ((unsigned __int16)((256 - HIBYTE(v61)) * *v44) >> 8))
                         | -((unsigned __int16)((unsigned __int8)v61
                                              + (unsigned __int8)((unsigned __int16)((256 - HIBYTE(v61)) * *v44) >> 8)) >> 8);
                    v44[1] = (BYTE1(v61) + BYTE1(v64))
                           | -((unsigned __int16)(BYTE1(v61) + (unsigned __int16)(v64 >> 8)) >> 8);
                    result = HIWORD(v65);
                    v44[2] = BYTE2(v65);
                    v44 += v43;
                  }
                  while ( v42 > 0 );
                }
                else
                {
                  do
                  {
                    v45 = *a2;
                    v46 = *((int *)a2 + 2);
                    v47 = (double)v41 * *((double *)a2 + 8) + *((double *)a2 + 9);
                    v48 = (double)v41 * *((double *)a2 + 7) + *((double *)a2 + 10);
                    v49 = v47 * v47 + v48 * v48;
                    if ( v49 < *((double *)a2 + 4) )
                    {
                      v51 = sqrt(v49) * *((double *)a2 + 5) + 6.755399441055744e15;
                      if ( SLODWORD(v51) < (int)v46 )
                        LODWORD(v46) = LODWORD(v51);
                      v50 = *(_DWORD *)(v45 + 4LL * (int)v46);
                    }
                    else
                    {
                      v50 = *(_DWORD *)(v45 + 4 * v46);
                    }
                    ++v41;
                    --v42;
                    v52 = ((v19 * ((v50 >> 8) & 0xFF00FF)) >> 8) & 0xFF00FF;
                    v53 = 256 - HIWORD(v52);
                    v54 = v52 + ((v53 * (unsigned int)v44[1]) >> 8);
                    v55 = (((v19 * (v50 & 0xFF00FF)) >> 8) & 0xFF00FF)
                        + (((unsigned int)(v53 * (*v44 | (v44[2] << 16))) >> 8) & 0xFF00FF);
                    *v44 = v55 | -BYTE1(v55);
                    v44[1] = v54 | -BYTE1(v54);
                    result = ((v55 | (256 - ((v55 >> 8) & 0xFF00FF))) & 0xFF00FF) >> 16;
                    v44[2] = ((v55 | (256 - ((v55 >> 8) & 0xFF00FF))) & 0xFF00FF) >> 16;
                    v44 += v43;
                  }
                  while ( v42 > 0 );
                }
                v15 = v90;
              }
            }
            v13 = v91;
            v10 = v87;
            v12 = v19 * (unsigned __int8)v91;
          }
          v90 = --v15;
        }
        while ( v15 >= 0 );
        v4 = i;
        v3 = a1;
      }
      v66 = v12 >> 8;
      if ( v66 > 0 )
      {
        v67 = *a2;
        v68 = *((double *)a2 + 4);
        v69 = *((int *)a2 + 2);
        v70 = v13 >> 8;
        v71 = (*((double *)a2 + 8) * (double)v70 + *((double *)a2 + 9))
            * (*((double *)a2 + 8) * (double)v70 + *((double *)a2 + 9))
            + (*((double *)a2 + 7) * (double)v70 + *((double *)a2 + 10))
            * (*((double *)a2 + 7) * (double)v70 + *((double *)a2 + 10));
        if ( v66 < 255 )
        {
          if ( v71 < v68 )
          {
            v80 = sqrt(v71) * *((double *)a2 + 5) + 6.755399441055744e15;
            if ( SLODWORD(v80) < (int)v69 )
              LODWORD(v69) = LODWORD(v80);
            v79 = *(_DWORD *)(v67 + 4LL * (int)v69);
          }
          else
          {
            v79 = *(_DWORD *)(v67 + 4 * v69);
          }
          v81 = ((v66 * ((v79 >> 8) & 0xFF00FF)) >> 8) & 0xFF00FF;
          v75 = (unsigned __int8 *)(a2[15] + v70 * *(_DWORD *)(a2[14] + 16));
          v82 = 256 - HIWORD(v81);
          v83 = v81 + ((v82 * (unsigned int)v75[1]) >> 8);
          v84 = (((v66 * (v79 & 0xFF00FF)) >> 8) & 0xFF00FF)
              + (((unsigned int)(v82 * (*v75 | (v75[2] << 16))) >> 8) & 0xFF00FF);
          *v75 = v84 | -BYTE1(v84);
          v75[1] = v83 | -BYTE1(v83);
          v78 = (v84 | (256 - ((v84 >> 8) & 0xFF00FF))) & 0xFF00FF;
        }
        else
        {
          if ( v71 < v68 )
          {
            v73 = sqrt(v71) * *((double *)a2 + 5) + 6.755399441055744e15;
            if ( SLODWORD(v73) < (int)v69 )
              LODWORD(v69) = LODWORD(v73);
            v72 = *(_DWORD *)(v67 + 4LL * (int)v69);
          }
          else
          {
            v72 = *(_DWORD *)(v67 + 4 * v69);
          }
          v74 = 256 - HIBYTE(v72);
          v75 = (unsigned __int8 *)(a2[15] + v70 * *(_DWORD *)(a2[14] + 16));
          v76 = v74 * v75[1];
          v77 = (((v72 & 0xFF00FF) + (((unsigned int)(v74 * (*v75 | (v75[2] << 16))) >> 8) & 0xFF00FF))
               | (256
                - ((((v72 & 0xFF00FF) + (((unsigned int)(v74 * (*v75 | (v75[2] << 16))) >> 8) & 0xFF00FF)) >> 8)
                 & 0xFF00FF)))
              & 0xFF00FF;
          *v75 = (v72 + ((unsigned __int16)((256 - HIBYTE(v72)) * *v75) >> 8))
               | -((unsigned __int16)((unsigned __int8)v72
                                    + (unsigned __int8)((unsigned __int16)((256 - HIBYTE(v72)) * *v75) >> 8)) >> 8);
          v75[1] = (BYTE1(v72) + BYTE1(v76)) | -((unsigned __int16)(BYTE1(v72) + (unsigned __int16)(v76 >> 8)) >> 8);
          v78 = v77;
        }
        result = HIWORD(v78);
        v75[2] = result;
      }
      v5 = v86;
    }
    ++v4;
  }
  return result;
}

