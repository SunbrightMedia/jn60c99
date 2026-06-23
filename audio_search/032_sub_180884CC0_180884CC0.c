// sub_180884CC0 @ 0x180884CC0 (RVA 0x884CC0)  float_ops=52

__int64 __fastcall sub_180884CC0(
        __int64 a1,
        __int64 a2,
        int a3,
        int a4,
        int a5,
        int a6,
        float a7,
        float a8,
        float a9,
        unsigned int a10,
        __int64 a11)
{
  __int64 v11; // rsi
  unsigned int *v15; // rax
  unsigned int v16; // r14d
  unsigned int *v17; // rax
  __int64 v18; // rcx
  unsigned int *v19; // rax
  char v20; // dl
  __int64 result; // rax
  float v22; // xmm6_4
  unsigned int *v23; // rax
  char v24; // dl
  unsigned int v25; // ecx
  int v26; // eax
  int v27; // r12d
  double v28; // rax
  int v29; // ecx
  float v30; // xmm6_4
  float v31; // xmm7_4
  int v32; // edx
  int v33; // r8d
  int v34; // r9d
  int v35; // eax
  bool v36; // zf
  int v37; // ebx
  unsigned int v38; // edi
  float v39; // xmm7_4
  int v40; // edx
  int v41; // r8d
  int v42; // r9d
  int v43; // esi
  float v44; // xmm6_4
  int v45; // edx
  int v46; // r8d
  int v47; // r9d
  double v48; // [rsp+50h] [rbp-79h] BYREF
  double v49; // [rsp+58h] [rbp-71h] BYREF
  int v50; // [rsp+60h] [rbp-69h]
  int v51; // [rsp+64h] [rbp-65h]
  int v52; // [rsp+68h] [rbp-61h] BYREF
  int v53; // [rsp+6Ch] [rbp-5Dh]
  int v54; // [rsp+70h] [rbp-59h]
  int v55; // [rsp+74h] [rbp-55h]

  v11 = a11;
  v15 = (unsigned int *)sub_1808D6630(a11, &v48, 16781824, 0);
  sub_1808316B0(a2, *v15);
  v16 = a10;
  if ( a10 == 2 )
  {
    v17 = (unsigned int *)sub_1808D6630(v11, &a10, 16782080, 0);
    sub_180831D50(a2, *v17);
    v18 = *(_QWORD *)(a2 + 8);
    v49 = COERCE_DOUBLE(__PAIR64__(a4, a3));
    v50 = (int)a7 - a3;
    v51 = a6;
    (*(void (__fastcall **)(__int64, double *, _QWORD))(*(_QWORD *)v18 + 168LL))(v18, &v49, 0);
    v19 = (unsigned int *)sub_1808D6630(v11, &v48, 16782336, 0);
    v20 = -1;
    a10 = *v19;
    v49 = (float)((float)HIBYTE(a10) * 0.5) + 6.755399441055744e15;
    if ( SLODWORD(v49) < 255 )
      v20 = LOBYTE(v49);
    HIBYTE(a10) = v20;
    sub_180831D50(a2, a10);
    return sub_180821880(a2, a3, a4, (int)a7 - a3, a6, 1);
  }
  else
  {
    if ( (*(_BYTE *)(v11 + 169) & 0x10) != 0 || *(_QWORD *)(v11 + 24) && !(unsigned __int8)sub_1808C7290() )
      v22 = 0.30000001;
    else
      v22 = 1.0;
    v23 = (unsigned int *)sub_1808D6630(v11, &v48, 16782096, 0);
    v24 = -1;
    a10 = *v23;
    v49 = (float)((float)HIBYTE(a10) * v22) + 6.755399441055744e15;
    if ( SLODWORD(v49) < 255 )
      v24 = LOBYTE(v49);
    HIBYTE(a10) = v24;
    sub_180831D50(a2, a10);
    v25 = *(_DWORD *)(*(_QWORD *)(v11 + 512) + 32LL);
    if ( v25 <= 0xB && (v26 = 2565, _bittest(&v26, v25)) )
    {
      v27 = a6;
      v54 = a5;
      v52 = a3;
      v48 = (float)((float)a6 * 0.2) + 6.755399441055744e15;
      v55 = LODWORD(v48);
      v49 = (float)((float)a6 * 0.60000002) + 6.755399441055744e15;
      v53 = a4 + LODWORD(v49);
    }
    else
    {
      v27 = a6;
      v53 = a4;
      v55 = a6;
      v48 = (float)((float)a5 * 0.2) + 6.755399441055744e15;
      v28 = v48;
      v49 = (float)((float)((float)a5 * 0.5) - fminf((float)a5 * 0.1, 3.0)) + 6.755399441055744e15;
      v52 = a3 + LODWORD(v49);
      v29 = 4;
      if ( SLODWORD(v28) < 4 )
        v29 = LODWORD(v28);
      v54 = v29;
    }
    (*(void (__fastcall **)(_QWORD, int *, _QWORD))(**(_QWORD **)(a2 + 8) + 168LL))(*(_QWORD *)(a2 + 8), &v52, 0);
    v30 = 0.34999999;
    v31 = 0.69999999;
    if ( (*(_BYTE *)(v11 + 169) & 0x10) == 0 && (!*(_QWORD *)(v11 + 24) || (unsigned __int8)sub_1808C7290()) )
    {
      if ( (unsigned __int8)sub_1808C6DD0(v11) )
        v30 = 1.0;
      else
        v30 = 0.69999999;
    }
    LODWORD(v48) = *(_DWORD *)sub_1808D6630(v11, &a10, 16782080, 0);
    if ( v30 > 0.0 )
    {
      if ( v30 < 1.0 )
        v35 = (int)(float)(v30 * 255.996);
      else
        LOBYTE(v35) = -1;
    }
    else
    {
      LOBYTE(v35) = 0;
    }
    v36 = (*(_BYTE *)(v11 + 169) & 0x10) == 0;
    BYTE3(v48) = v35;
    if ( !v36 || *(_QWORD *)(v11 + 24) && !(unsigned __int8)sub_1808C7290() )
      v31 = 0.34999999;
    v37 = LODWORD(v48);
    a10 = dword_180C96488;
    HIBYTE(a10) = (int)(float)(v31 * 255.996);
    v38 = a10;
    if ( ((v16 - 10) & 0xFFFFFFFD) != 0 )
    {
      result = v16 - 9;
      if ( (result & 0xFFFFFFFD) == 0 )
      {
        v39 = (float)((float)v27 * 0.89999998) + (float)a4;
        sub_180885350(a2, v32, v33, v34, LODWORD(v39), LODWORD(a8), LODWORD(v39), LODWORD(v48), a10);
        result = sub_180885350(a2, v40, v41, v42, LODWORD(v39), a9 + 7.0, LODWORD(v39), v37, v38);
      }
      v43 = a5;
    }
    else
    {
      v43 = a5;
      v44 = (float)((float)((float)a5 * 0.5) + (float)a3) - fminf((float)a5 * 0.40000001, 8.0);
      sub_180885350(a2, v32, v33, v34, a8 - 7.0, LODWORD(v44), LODWORD(a8), LODWORD(v48), a10);
      result = sub_180885350(a2, v45, v46, v47, LODWORD(a9), LODWORD(v44), a9 + 7.0, v37, v38);
    }
    if ( !v16 || v16 == 11 )
    {
      return sub_180885350(
               a2,
               v32,
               v33,
               v34,
               (float)((float)v27 * 0.2) + (float)a4,
               a7 + 7.0,
               (float)((float)v27 * 0.2) + (float)a4,
               v37,
               v38);
    }
    else if ( v16 == 1 || v16 == 12 )
    {
      return sub_180885350(
               a2,
               v32,
               v33,
               v34,
               a7 - 7.0,
               fminf((float)v43 * 0.40000001, 8.0) + (float)((float)((float)v43 * 0.5) + (float)a3),
               a7 + 7.0,
               v37,
               v38);
    }
  }
  return result;
}

