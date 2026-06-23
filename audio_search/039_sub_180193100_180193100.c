// sub_180193100 @ 0x180193100 (RVA 0x193100)  float_ops=46

signed __int64 __fastcall sub_180193100(_QWORD *a1, __int64 *a2)
{
  signed __int64 result; // rax
  _DWORD *v3; // r12
  int v4; // r15d
  _DWORD *v5; // rcx
  _DWORD *v7; // r13
  int v8; // r9d
  int v9; // r9d
  int *v10; // r13
  __int64 v11; // rdx
  int v12; // ebp
  int v13; // edi
  float v14; // xmm1_4
  int v15; // r9d
  float v16; // xmm0_4
  float v17; // xmm1_4
  int v18; // eax
  int v19; // r12d
  int v20; // r15d
  int v21; // esi
  int v22; // eax
  int v23; // edi
  __int64 v24; // r14
  double v25; // xmm5_8
  __int64 v26; // rbp
  double v27; // xmm0_8
  unsigned int v28; // edx
  unsigned int v29; // r9d
  double v30; // xmm0_8
  unsigned int v31; // edx
  double v32; // xmm0_8
  unsigned int v33; // r9d
  unsigned int *v34; // r10
  int v35; // ecx
  unsigned int v36; // r8d
  unsigned int v37; // r9d
  int v38; // esi
  int v39; // r15d
  unsigned int *v40; // rbp
  __int64 v41; // r14
  __int64 v42; // rdi
  double v43; // xmm1_8
  double v44; // xmm0_8
  double v45; // xmm1_8
  unsigned int v46; // r9d
  double v47; // xmm0_8
  unsigned int v48; // r8d
  int v49; // ecx
  unsigned int v50; // r9d
  unsigned int v51; // r8d
  __int64 v52; // r14
  __int64 v53; // rdi
  double v54; // xmm1_8
  double v55; // xmm0_8
  double v56; // xmm1_8
  unsigned int v57; // edx
  double v58; // xmm0_8
  unsigned int v59; // r9d
  int v60; // ecx
  unsigned int v61; // r9d
  unsigned int v62; // r8d
  int v63; // ebp
  __int64 v64; // r14
  double v65; // xmm5_8
  __int64 v66; // rsi
  int v67; // edi
  double v68; // xmm0_8
  unsigned int v69; // edx
  unsigned int v70; // r9d
  double v71; // xmm0_8
  unsigned int v72; // edx
  double v73; // xmm0_8
  unsigned int v74; // r9d
  unsigned int *v75; // r10
  int v76; // ecx
  unsigned int v77; // r8d
  unsigned int v78; // r9d
  int i; // [rsp+20h] [rbp-68h]
  _DWORD *v80; // [rsp+28h] [rbp-60h]
  __int64 v81; // [rsp+30h] [rbp-58h]
  __int64 v82; // [rsp+38h] [rbp-50h]
  _UNKNOWN *retaddr; // [rsp+88h] [rbp+0h] BYREF
  int v85; // [rsp+A0h] [rbp+18h]
  int v86; // [rsp+A8h] [rbp+20h]

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
    v80 = v5;
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
      v86 = v15;
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
          v85 = v18;
          if ( v18 >> 8 == v13 >> 8 )
          {
            v22 = v18 - v13;
            v13 = v85;
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
                  v32 = sqrt(v27) * *((double *)a2 + 5) + 6.755399441055744e15;
                  if ( SLODWORD(v32) < (int)v26 )
                    LODWORD(v26) = LODWORD(v32);
                  v31 = *(_DWORD *)(v24 + 4LL * (int)v26);
                }
                else
                {
                  v31 = *(_DWORD *)(v24 + 4 * v26);
                }
                v29 = v23 * ((v31 >> 8) & 0xFF00FF);
                v28 = (v23 * (v31 & 0xFF00FF)) >> 8;
              }
              else if ( v27 < v25 )
              {
                v30 = sqrt(v27) * *((double *)a2 + 5) + 6.755399441055744e15;
                if ( SLODWORD(v30) < (int)v26 )
                  LODWORD(v26) = LODWORD(v30);
                v28 = *(_DWORD *)(v24 + 4LL * (int)v26);
                v29 = v28;
              }
              else
              {
                v28 = *(_DWORD *)(v24 + 4 * v26);
                v29 = v28;
              }
              v33 = (v29 >> 8) & 0xFF00FF;
              v34 = (unsigned int *)(a2[15] + v21 * *(_DWORD *)(a2[14] + 16));
              v35 = 256 - HIWORD(v33);
              v36 = (v28 & 0xFF00FF) + (((v35 * (*v34 & 0xFF00FF)) >> 8) & 0xFF00FF);
              v37 = (((v35 * ((*v34 >> 8) & 0xFF00FF)) >> 8) & 0xFF00FF) + v33;
              result = (v37 >> 8) & 0xFF00FF;
              *v34 = ((v37 << 8) | ((256 - (_DWORD)result) << 8))
                   ^ ((v36 | (256 - ((v36 >> 8) & 0xFF00FF)))
                    ^ ((v37 << 8) | ((256 - ((v37 >> 8) & 0xFF00FF)) << 8)))
                   & 0xFF00FF;
            }
            if ( v19 > 0 )
            {
              v38 = v21 + 1;
              v39 = v20 - v38;
              if ( v39 > 0 )
              {
                v40 = (unsigned int *)(a2[15] + v38 * *(_DWORD *)(a2[14] + 16));
                if ( v19 >= 255 )
                {
                  v81 = *(int *)(a2[14] + 16);
                  do
                  {
                    v52 = *a2;
                    v53 = *((int *)a2 + 2);
                    v54 = (double)v38 * *((double *)a2 + 8) + *((double *)a2 + 9);
                    v55 = (double)v38 * *((double *)a2 + 7) + *((double *)a2 + 10);
                    v56 = v54 * v54 + v55 * v55;
                    if ( v56 < *((double *)a2 + 4) )
                    {
                      v58 = sqrt(v56) * *((double *)a2 + 5) + 6.755399441055744e15;
                      if ( SLODWORD(v58) < (int)v53 )
                        LODWORD(v53) = LODWORD(v58);
                      v57 = *(_DWORD *)(v52 + 4LL * (int)v53);
                    }
                    else
                    {
                      v57 = *(_DWORD *)(v52 + 4 * v53);
                    }
                    v59 = (v57 >> 8) & 0xFF00FF;
                    ++v38;
                    --v39;
                    v60 = 256 - HIWORD(v59);
                    v61 = (((v60 * ((*v40 >> 8) & 0xFF00FF)) >> 8) & 0xFF00FF) + v59;
                    v62 = (v57 & 0xFF00FF) + (((v60 * (*v40 & 0xFF00FF)) >> 8) & 0xFF00FF);
                    result = (v61 >> 8) & 0xFF00FF;
                    *v40 = ((v61 << 8) | ((256 - (_DWORD)result) << 8))
                         ^ ((v62 | (256 - ((v62 >> 8) & 0xFF00FF)))
                          ^ ((v61 << 8) | ((256 - ((v61 >> 8) & 0xFF00FF)) << 8)))
                         & 0xFF00FF;
                    v40 = (unsigned int *)((char *)v40 + v81);
                  }
                  while ( v39 > 0 );
                }
                else
                {
                  v82 = *(int *)(a2[14] + 16);
                  do
                  {
                    v41 = *a2;
                    v42 = *((int *)a2 + 2);
                    v43 = (double)v38 * *((double *)a2 + 8) + *((double *)a2 + 9);
                    v44 = (double)v38 * *((double *)a2 + 7) + *((double *)a2 + 10);
                    v45 = v43 * v43 + v44 * v44;
                    if ( v45 < *((double *)a2 + 4) )
                    {
                      v47 = sqrt(v45) * *((double *)a2 + 5) + 6.755399441055744e15;
                      if ( SLODWORD(v47) < (int)v42 )
                        LODWORD(v42) = LODWORD(v47);
                      v46 = *(_DWORD *)(v41 + 4LL * (int)v42);
                    }
                    else
                    {
                      v46 = *(_DWORD *)(v41 + 4 * v42);
                    }
                    ++v38;
                    --v39;
                    v48 = ((v19 * ((v46 >> 8) & 0xFF00FF)) >> 8) & 0xFF00FF;
                    v49 = 256 - HIWORD(v48);
                    v50 = (((v49 * (*v40 & 0xFF00FF)) >> 8) & 0xFF00FF) + (((v19 * (v46 & 0xFF00FF)) >> 8) & 0xFF00FF);
                    v51 = (((v49 * ((*v40 >> 8) & 0xFF00FF)) >> 8) & 0xFF00FF) + v48;
                    result = (v51 >> 8) & 0xFF00FF;
                    *v40 = ((v51 << 8) | ((256 - (_DWORD)result) << 8))
                         ^ ((v50 | (256 - ((v50 >> 8) & 0xFF00FF)))
                          ^ ((v51 << 8) | ((256 - ((v51 >> 8) & 0xFF00FF)) << 8)))
                         & 0xFF00FF;
                    v40 = (unsigned int *)((char *)v40 + v82);
                  }
                  while ( v39 > 0 );
                }
              }
            }
            v13 = v85;
            v15 = v86;
            v12 = v19 * (unsigned __int8)v85;
          }
          v86 = --v15;
        }
        while ( v15 >= 0 );
        v4 = i;
        v3 = a1;
      }
      v63 = v12 >> 8;
      if ( v63 > 0 )
      {
        v64 = *a2;
        v65 = *((double *)a2 + 4);
        v66 = *((int *)a2 + 2);
        v67 = v13 >> 8;
        v68 = (*((double *)a2 + 8) * (double)v67 + *((double *)a2 + 9))
            * (*((double *)a2 + 8) * (double)v67 + *((double *)a2 + 9))
            + (*((double *)a2 + 7) * (double)v67 + *((double *)a2 + 10))
            * (*((double *)a2 + 7) * (double)v67 + *((double *)a2 + 10));
        if ( v63 < 255 )
        {
          if ( v68 < v65 )
          {
            v73 = sqrt(v68) * *((double *)a2 + 5) + 6.755399441055744e15;
            if ( SLODWORD(v73) < (int)v66 )
              LODWORD(v66) = LODWORD(v73);
            v72 = *(_DWORD *)(v64 + 4LL * (int)v66);
          }
          else
          {
            v72 = *(_DWORD *)(v64 + 4 * v66);
          }
          v70 = v63 * ((v72 >> 8) & 0xFF00FF);
          v69 = (v63 * (v72 & 0xFF00FF)) >> 8;
        }
        else if ( v68 < v65 )
        {
          v71 = sqrt(v68) * *((double *)a2 + 5) + 6.755399441055744e15;
          if ( SLODWORD(v71) < (int)v66 )
            LODWORD(v66) = LODWORD(v71);
          v69 = *(_DWORD *)(v64 + 4LL * (int)v66);
          v70 = v69;
        }
        else
        {
          v69 = *(_DWORD *)(v64 + 4 * v66);
          v70 = v69;
        }
        v74 = (v70 >> 8) & 0xFF00FF;
        v75 = (unsigned int *)(a2[15] + v67 * *(_DWORD *)(a2[14] + 16));
        v76 = 256 - HIWORD(v74);
        v77 = (v69 & 0xFF00FF) + (((v76 * (*v75 & 0xFF00FF)) >> 8) & 0xFF00FF);
        v78 = (((v76 * ((*v75 >> 8) & 0xFF00FF)) >> 8) & 0xFF00FF) + v74;
        result = (v78 >> 8) & 0xFF00FF;
        *v75 = ((v78 << 8) | ((256 - (_DWORD)result) << 8))
             ^ ((v77 | (256 - ((v77 >> 8) & 0xFF00FF)))
              ^ ((v78 << 8) | ((256 - ((v78 >> 8) & 0xFF00FF)) << 8)))
             & 0xFF00FF;
      }
      v5 = v80;
    }
    ++v4;
  }
  return result;
}

