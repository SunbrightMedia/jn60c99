// sub_180195AE0 @ 0x180195AE0 (RVA 0x195AE0)  float_ops=46

signed __int64 __fastcall sub_180195AE0(_QWORD *a1, __int64 *a2)
{
  signed __int64 result; // rax
  _DWORD *v3; // r13
  int v4; // ebp
  _DWORD *v5; // rcx
  _DWORD *v7; // r9
  int v8; // r12d
  int v9; // r12d
  int *v10; // r9
  __int64 v11; // rdx
  int v12; // esi
  int v13; // r14d
  float v14; // xmm1_4
  int v15; // r12d
  float v16; // xmm0_4
  float v17; // xmm1_4
  int v18; // r13d
  int v19; // eax
  int v20; // edi
  int v21; // ebp
  int v22; // eax
  int v23; // r14d
  __int64 v24; // r15
  double v25; // xmm5_8
  __int64 v26; // rsi
  double v27; // xmm0_8
  unsigned int v28; // r8d
  int v29; // ecx
  double v30; // xmm0_8
  unsigned int v31; // r8d
  double v32; // xmm0_8
  _BYTE *v33; // rdx
  int v34; // edi
  int v35; // ebp
  _BYTE *v36; // rsi
  int v37; // r12d
  __int64 v38; // r13
  __int64 v39; // r15
  __int64 v40; // r14
  double v41; // xmm1_8
  double v42; // xmm0_8
  double v43; // xmm1_8
  unsigned int v44; // edx
  double v45; // xmm0_8
  __int64 v46; // r12
  __int64 v47; // r15
  __int64 v48; // r14
  double v49; // xmm1_8
  double v50; // xmm0_8
  double v51; // xmm1_8
  unsigned int v52; // edx
  double v53; // xmm0_8
  int v54; // esi
  __int64 v55; // r15
  double v56; // xmm5_8
  __int64 v57; // rdi
  int v58; // r14d
  double v59; // xmm0_8
  unsigned int v60; // r8d
  int v61; // ecx
  double v62; // xmm0_8
  unsigned int v63; // r8d
  double v64; // xmm0_8
  _BYTE *v65; // rdx
  int i; // [rsp+20h] [rbp-68h]
  int v67; // [rsp+24h] [rbp-64h]
  _DWORD *v68; // [rsp+28h] [rbp-60h]
  int *v69; // [rsp+38h] [rbp-50h]
  _UNKNOWN *retaddr; // [rsp+88h] [rbp+0h] BYREF
  int v72; // [rsp+A0h] [rbp+18h]
  int v73; // [rsp+A8h] [rbp+20h]

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
    v68 = v5;
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
      v72 = v15;
      v16 = v14 * *((float *)a2 + 23);
      v17 = (float)(v14 * *((float *)a2 + 26)) + *((float *)a2 + 27);
      *((double *)a2 + 9) = (float)(v16 + *((float *)a2 + 24)) - *((double *)a2 + 2);
      *((double *)a2 + 10) = v17 - *((double *)a2 + 3);
      if ( v15 >= 0 )
      {
        do
        {
          v18 = v10[1];
          v19 = v10[2];
          v10 += 2;
          v20 = v13 >> 8;
          v21 = v19 >> 8;
          v67 = v18;
          v69 = v10;
          v73 = v19;
          if ( v19 >> 8 == v13 >> 8 )
          {
            v22 = v19 - v13;
            v13 = v73;
            result = (unsigned int)(v18 * v22);
            v12 += result;
          }
          else
          {
            result = (unsigned __int8)v13;
            v23 = (v12 + v18 * (256 - (unsigned __int8)v13)) >> 8;
            if ( v23 > 0 )
            {
              v24 = *a2;
              v25 = *((double *)a2 + 4);
              v26 = *((int *)a2 + 2);
              v27 = (*((double *)a2 + 8) * (double)v20 + *((double *)a2 + 9))
                  * (*((double *)a2 + 8) * (double)v20 + *((double *)a2 + 9))
                  + (*((double *)a2 + 7) * (double)v20 + *((double *)a2 + 10))
                  * (*((double *)a2 + 7) * (double)v20 + *((double *)a2 + 10));
              if ( v23 < 255 )
              {
                if ( v27 < v25 )
                {
                  v32 = sqrt(v27) * *((double *)a2 + 5) + 6.755399441055744e15;
                  if ( SLODWORD(v32) < (int)v26 )
                    LODWORD(v26) = LODWORD(v32);
                  v31 = *(_DWORD *)(v24 + 4LL * (int)v26);
                }
                else
                {
                  v31 = *(_DWORD *)(v24 + 4 * v26);
                }
                v29 = *(_DWORD *)(a2[14] + 16);
                v28 = (unsigned int)((v23 + 1) * HIBYTE(v31)) >> 8;
              }
              else if ( v27 < v25 )
              {
                v30 = sqrt(v27) * *((double *)a2 + 5) + 6.755399441055744e15;
                if ( SLODWORD(v30) < (int)v26 )
                  LODWORD(v26) = LODWORD(v30);
                v28 = HIBYTE(*(_DWORD *)(v24 + 4LL * (int)v26));
                v29 = *(_DWORD *)(a2[14] + 16);
              }
              else
              {
                v28 = HIBYTE(*(_DWORD *)(v24 + 4 * v26));
                v29 = *(_DWORD *)(a2[14] + 16);
              }
              v33 = (_BYTE *)(a2[15] + v20 * v29);
              result = (unsigned __int8)*v33;
              *v33 = v28 + ((unsigned __int16)(result * (256 - v28)) >> 8);
            }
            if ( v18 > 0 )
            {
              v34 = v20 + 1;
              v35 = v21 - v34;
              if ( v35 > 0 )
              {
                v36 = (_BYTE *)(a2[15] + v34 * *(_DWORD *)(a2[14] + 16));
                if ( v18 >= 255 )
                {
                  v46 = *(int *)(a2[14] + 16);
                  do
                  {
                    v47 = *a2;
                    v48 = *((int *)a2 + 2);
                    v49 = (double)v34 * *((double *)a2 + 8) + *((double *)a2 + 9);
                    v50 = (double)v34 * *((double *)a2 + 7) + *((double *)a2 + 10);
                    v51 = v49 * v49 + v50 * v50;
                    if ( v51 < *((double *)a2 + 4) )
                    {
                      v53 = sqrt(v51) * *((double *)a2 + 5) + 6.755399441055744e15;
                      if ( SLODWORD(v53) < (int)v48 )
                        LODWORD(v48) = LODWORD(v53);
                      v52 = *(_DWORD *)(v47 + 4LL * (int)v48);
                    }
                    else
                    {
                      v52 = *(_DWORD *)(v47 + 4 * v48);
                    }
                    result = (unsigned __int8)*v36;
                    ++v34;
                    --v35;
                    *v36 = HIBYTE(v52) + ((unsigned __int16)(result * (256 - HIBYTE(v52))) >> 8);
                    v36 += v46;
                  }
                  while ( v35 > 0 );
                }
                else
                {
                  v37 = v18 + 1;
                  v38 = *(int *)(a2[14] + 16);
                  do
                  {
                    v39 = *a2;
                    v40 = *((int *)a2 + 2);
                    v41 = (double)v34 * *((double *)a2 + 8) + *((double *)a2 + 9);
                    v42 = (double)v34 * *((double *)a2 + 7) + *((double *)a2 + 10);
                    v43 = v41 * v41 + v42 * v42;
                    if ( v43 < *((double *)a2 + 4) )
                    {
                      v45 = sqrt(v43) * *((double *)a2 + 5) + 6.755399441055744e15;
                      if ( SLODWORD(v45) < (int)v40 )
                        LODWORD(v40) = LODWORD(v45);
                      v44 = *(_DWORD *)(v39 + 4LL * (int)v40);
                    }
                    else
                    {
                      v44 = *(_DWORD *)(v39 + 4 * v40);
                    }
                    result = (unsigned __int8)*v36;
                    ++v34;
                    --v35;
                    *v36 = ((unsigned __int16)(v37 * HIBYTE(v44)) >> 8)
                         + ((unsigned __int16)(result * (256 - ((unsigned int)(v37 * HIBYTE(v44)) >> 8))) >> 8);
                    v36 += v38;
                  }
                  while ( v35 > 0 );
                  v18 = v67;
                }
                v15 = v72;
              }
            }
            v13 = v73;
            v10 = v69;
            v12 = v18 * (unsigned __int8)v73;
          }
          v72 = --v15;
        }
        while ( v15 >= 0 );
        v4 = i;
        v3 = a1;
      }
      v54 = v12 >> 8;
      if ( v54 > 0 )
      {
        v55 = *a2;
        v56 = *((double *)a2 + 4);
        v57 = *((int *)a2 + 2);
        v58 = v13 >> 8;
        v59 = (*((double *)a2 + 8) * (double)v58 + *((double *)a2 + 9))
            * (*((double *)a2 + 8) * (double)v58 + *((double *)a2 + 9))
            + (*((double *)a2 + 7) * (double)v58 + *((double *)a2 + 10))
            * (*((double *)a2 + 7) * (double)v58 + *((double *)a2 + 10));
        if ( v54 < 255 )
        {
          if ( v59 < v56 )
          {
            v64 = sqrt(v59) * *((double *)a2 + 5) + 6.755399441055744e15;
            if ( SLODWORD(v64) < (int)v57 )
              LODWORD(v57) = LODWORD(v64);
            v63 = *(_DWORD *)(v55 + 4LL * (int)v57);
          }
          else
          {
            v63 = *(_DWORD *)(v55 + 4 * v57);
          }
          v61 = *(_DWORD *)(a2[14] + 16);
          v60 = (unsigned int)((v54 + 1) * HIBYTE(v63)) >> 8;
        }
        else if ( v59 < v56 )
        {
          v62 = sqrt(v59) * *((double *)a2 + 5) + 6.755399441055744e15;
          if ( SLODWORD(v62) < (int)v57 )
            LODWORD(v57) = LODWORD(v62);
          v60 = HIBYTE(*(_DWORD *)(v55 + 4LL * (int)v57));
          v61 = *(_DWORD *)(a2[14] + 16);
        }
        else
        {
          v60 = HIBYTE(*(_DWORD *)(v55 + 4 * v57));
          v61 = *(_DWORD *)(a2[14] + 16);
        }
        v65 = (_BYTE *)(a2[15] + v58 * v61);
        result = (unsigned __int8)*v65;
        *v65 = v60 + ((unsigned __int16)(result * (256 - v60)) >> 8);
      }
      v5 = v68;
    }
    ++v4;
  }
  return result;
}

