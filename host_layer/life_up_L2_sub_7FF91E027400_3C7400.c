// sub_7FF91E027400 @ rva 0x3C7400

// Hidden C++ exception states: #wind=6
signed __int32 __fastcall sub_7FF91E027400(__int64 a1, __int64 a2, __int64 a3, _QWORD *a4, int a5, unsigned int a6)
{
  __int64 v6; // r15
  int v7; // eax
  __int64 *v8; // rbx
  volatile signed __int32 *v9; // r13
  volatile signed __int32 *v10; // r14
  __int64 *v11; // r12
  __int64 v12; // rdi
  __int64 v13; // r15
  __int64 v14; // rdi
  unsigned int v15; // r14d
  __int64 v16; // r14
  signed __int32 v17; // eax
  HANDLE v18; // rax
  __int64 v19; // r15
  char *v20; // rdx
  char *v21; // rdi
  unsigned __int64 v22; // r9
  unsigned __int64 v23; // rcx
  unsigned __int64 v24; // rdx
  unsigned __int64 v25; // r14
  __int64 v26; // rax
  unsigned __int64 v27; // rcx
  unsigned __int64 v28; // rcx
  char v29; // cl
  __int64 v30; // rbx
  volatile signed __int32 *v31; // rcx
  signed __int32 v32; // eax
  HANDLE v33; // rax
  signed __int32 v34; // ecx
  HANDLE v35; // rax
  _QWORD *v36; // r12
  char *v37; // rdx
  _QWORD *v38; // rdi
  __int64 v39; // r8
  __int64 v40; // r8
  float *v41; // rdx
  __int64 v42; // rdi
  float v43; // xmm1_4
  float *v44; // rax
  unsigned __int64 v45; // rcx
  float v46; // xmm2_4
  float v47; // xmm3_4
  float v48; // xmm0_4
  float v49; // xmm3_4
  float v50; // xmm1_4
  float *v51; // rcx
  __int64 v52; // rax
  float v53; // xmm0_4
  signed __int32 result; // eax
  HANDLE v55; // rax
  _QWORD *v56; // rcx
  int v57; // [rsp+20h] [rbp-E0h]
  __int64 v59; // [rsp+30h] [rbp-D0h] BYREF
  _QWORD *v60; // [rsp+38h] [rbp-C8h]
  volatile signed __int32 *v61; // [rsp+40h] [rbp-C0h]
  _QWORD *v62; // [rsp+48h] [rbp-B8h]
  volatile signed __int32 *v63; // [rsp+50h] [rbp-B0h] BYREF
  char v64; // [rsp+58h] [rbp-A8h]
  __int64 v65; // [rsp+60h] [rbp-A0h] BYREF
  _QWORD v66[4]; // [rsp+70h] [rbp-90h] BYREF
  __int64 v67[10]; // [rsp+90h] [rbp-70h] BYREF
  float *v68; // [rsp+E0h] [rbp-20h] BYREF
  char v69; // [rsp+E8h] [rbp-18h] BYREF

  v66[2] = -2;
  v62 = a4;
  v6 = a1;
  v61 = (volatile signed __int32 *)(a1 + 64);
  sub_7FF91DFAB2A0((volatile signed __int32 *)(a1 + 64));
  v7 = 0;
  v57 = 0;
  v8 = (__int64 *)(v6 + 656);
  v60 = (_QWORD *)(v6 + 104);
  v9 = (volatile signed __int32 *)(v6 + 1208);
  do
  {
    v10 = v9 - 6;
    v11 = v8;
    v12 = 48LL * v7 + v6 + 656;
    v13 = 2;
    do
    {
      sub_7FF91DFA3830(v12, (int)a6, v12);
      *(_QWORD *)v10 = *v11;
      v12 += 24;
      v11 += 3;
      v10 += 2;
      --v13;
    }
    while ( v13 );
    *((_DWORD *)v9 - 2) = a6;
    v14 = *v60;
    v6 = a1;
    v15 = *(_DWORD *)(a1 + 56);
    if ( (*(unsigned int (__fastcall **)(_QWORD))(*(_QWORD *)*v60 + 136LL))(*v60) != v15 )
      (*(void (__fastcall **)(__int64, _QWORD))(*(_QWORD *)v14 + 128LL))(v14, v15);
    v16 = a6;
    sub_7FF91DFB5AB0(v14, a6);
    if ( v57 >= *(_DWORD *)(a1 + 56) )
    {
      v19 = 0;
      while ( 1 )
      {
        v20 = (char *)v8[1];
        v21 = (char *)*v8;
        v22 = (__int64)&v20[-*v8] >> 2;
        v23 = (v8[2] - *v8) >> 2;
        if ( (int)a6 <= v23 )
        {
          if ( (int)a6 <= v22 )
          {
            v20 = &v21[4 * a6];
            v27 = (unsigned __int64)(4LL * (int)a6 + 3) >> 2;
            if ( v21 > v20 )
              v27 = 0;
            if ( !v27 )
              goto LABEL_43;
          }
          else
          {
            v28 = (unsigned __int64)(v20 - v21 + 3) >> 2;
            if ( v21 > v20 )
              v28 = 0;
            if ( v28 )
            {
              while ( v28 )
              {
                *(_DWORD *)v21 = 0;
                v21 += 4;
                --v28;
              }
              v20 = (char *)v8[1];
            }
            if ( a6 == v22 )
              goto LABEL_43;
            v21 = v20;
            v27 = (int)a6 - v22;
            v20 += 4 * v27;
          }
        }
        else
        {
          if ( (unsigned __int64)(int)a6 > 0x3FFFFFFFFFFFFFFFLL )
            std::vector<void *>::_Xlen();
          v24 = v23 >> 1;
          if ( v23 <= 0x3FFFFFFFFFFFFFFFLL - (v23 >> 1) )
          {
            v25 = v24 + v23;
            if ( v24 + v23 < (int)a6 )
              v25 = (int)a6;
          }
          else
          {
            v25 = (int)a6;
          }
          if ( v21 )
          {
            if ( 4 * v23 >= 0x1000 )
            {
              if ( (unsigned __int64)&v21[-*((_QWORD *)v21 - 1) - 8] > 0x1F )
                invalid_parameter_noinfo_noreturn();
              v21 = *((char **)v21 - 1);
            }
            j_j_free(v21);
          }
          *v8 = 0;
          v8[1] = 0;
          v8[2] = 0;
          if ( v25 )
          {
            if ( v25 > 0x3FFFFFFFFFFFFFFFLL )
              std::vector<void *>::_Xlen();
            v26 = sub_7FF91DFA4480(v8, v25);
            *v8 = v26;
            v8[1] = v26;
            v8[2] = *v8 + 4 * v25;
          }
          v20 = (char *)*v8;
          if ( !a6 )
            goto LABEL_43;
          v21 = (char *)*v8;
          v27 = (int)a6;
          v20 += 4 * (int)a6;
        }
        while ( v27 )
        {
          *(_DWORD *)v21 = 0;
          v21 += 4;
          --v27;
        }
LABEL_43:
        v8[1] = (__int64)v20;
        ++v19;
        v8 += 3;
        if ( v19 >= 2 )
        {
          v6 = a1;
          v16 = a6;
          goto LABEL_45;
        }
      }
    }
    sub_7FF91DFAB2A0(v9);
    *((_DWORD *)v9 - 1) = 1;
    sub_7FF91E028440((__int64)(v9 + 4));
    v17 = _InterlockedExchangeAdd(v9, 0x80000000);
    if ( (v17 & 0x40000000) == 0 && v17 != 0x80000000 && !_interlockedbittestandset(v9, 0x1Eu) )
    {
      v18 = sub_7FF91DF66830((__int64)v9);
      SetEvent(v18);
    }
LABEL_45:
    v7 = v57 + 1;
    v57 = v7;
    v9 += 32;
    v60 += 8;
    v8 = v11;
  }
  while ( v7 < 8 );
  v63 = (volatile signed __int32 *)(v6 + 1080);
  v64 = 0;
  if ( v6 == -1080 )
  {
    v56 = sub_7FF91E025BC0(v67);
    sub_7FF91E0256C0((__int64)v56);
  }
  sub_7FF91DFAB2A0((volatile signed __int32 *)(v6 + 1080));
  v29 = 1;
  v64 = 1;
  if ( *(_DWORD *)(v6 + 1072) < *(_DWORD *)(v6 + 56) )
  {
    do
    {
      v65 = 0x7FFFFFFFFFFFFFFFLL;
      sub_7FF91E0252E0(v6 + 1096, (__int64)&v63, (__int64)&v65);
    }
    while ( *(_DWORD *)(v6 + 1072) < *(_DWORD *)(v6 + 56) );
    v29 = v64;
  }
  v30 = 0;
  *(_DWORD *)(v6 + 1072) = 0;
  if ( v29 )
  {
    v31 = v63;
    v32 = _InterlockedExchangeAdd(v63, 0x80000000);
    if ( (v32 & 0x40000000) == 0 && v32 != 0x80000000 && !_interlockedbittestandset(v31, 0x1Eu) )
    {
      v33 = sub_7FF91DF66830((__int64)v31);
      SetEvent(v33);
    }
  }
  v34 = _InterlockedExchangeAdd(v61, 0x80000000);
  if ( (v34 & 0x40000000) == 0 && v34 != 0x80000000 && !_interlockedbittestandset(v61, 0x1Eu) )
  {
    v35 = sub_7FF91DF66830((__int64)v61);
    SetEvent(v35);
  }
  v36 = v62;
  if ( (int)v16 > 0 )
  {
    do
    {
      v37 = &v69;
      v38 = (_QWORD *)(v6 + 680);
      v39 = 8;
      do
      {
        *((_QWORD *)v37 - 1) = v30 + *(v38 - 3);
        *(_QWORD *)v37 = v30 + *v38;
        v38 += 6;
        v37 += 16;
        --v39;
      }
      while ( v39 );
      v66[0] = v30 + *v36;
      v66[1] = v30 + v36[1];
      sub_7FF91DFF8EC0(*(_QWORD *)(a1 + 592), &v68, (__int64)v66);
      v30 += 4;
      --v16;
    }
    while ( v16 );
  }
  v59 = 0;
  v40 = 0;
  v41 = (float *)&v59;
  do
  {
    v42 = 0;
    if ( (int)a6 >= 4LL )
    {
      v43 = *v41;
      v44 = (float *)(v36[v40] + 8LL);
      v45 = ((unsigned __int64)((int)a6 - 4LL) >> 2) + 1;
      v42 = 4 * v45;
      do
      {
        v46 = fmaxf(fabs(*(v44 - 2)), v43);
        v47 = fabs(*(v44 - 1));
        v43 = v46;
        if ( v46 < v47 )
        {
          v46 = v47;
          v43 = v47;
        }
        v48 = fabs(*v44);
        if ( v46 < v48 )
          v43 = v48;
        v49 = fabs(v44[1]);
        if ( fmaxf(v46, v48) < v49 )
          v43 = v49;
        v44 += 4;
        --v45;
      }
      while ( v45 );
      *v41 = v43;
    }
    if ( v42 < (int)a6 )
    {
      v50 = *v41;
      v51 = (float *)(v36[v40] + 4 * v42);
      v52 = (int)a6 - v42;
      do
      {
        v53 = fmaxf(fabs(*v51), v50);
        v50 = v53;
        ++v51;
        --v52;
      }
      while ( v52 );
      *v41 = v53;
    }
    ++v40;
    ++v41;
  }
  while ( v40 < 2 );
  sub_7FF91DFAB2A0((volatile signed __int32 *)(a1 + 16));
  *(float *)(a1 + 32) = fmaxf(*(float *)&v59, *(float *)(a1 + 32));
  *(float *)(a1 + 36) = fmaxf(*(float *)(a1 + 36), *((float *)&v59 + 1));
  result = _InterlockedExchangeAdd((volatile signed __int32 *)(a1 + 16), 0x80000000);
  if ( (result & 0x40000000) == 0
    && result != 0x80000000
    && !_interlockedbittestandset((volatile signed __int32 *)(a1 + 16), 0x1Eu) )
  {
    v55 = sub_7FF91DF66830(a1 + 16);
    return SetEvent(v55);
  }
  return result;
}

