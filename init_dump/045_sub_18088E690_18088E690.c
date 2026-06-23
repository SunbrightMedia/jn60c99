// sub_18088E690  @ 0x18088E690  (RVA 0x88E690)  floats=16
// .rdata float constants referenced by this function:
//   0x180AA33E4  unk_180AA33E4 = 100002.0
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE5120  flt_180AE5120 = 1.5707963705062866
//   0x180AE51E8  flt_180AE51E8 = 2.0
//   0x180AE5270  dword_180AE5270 = 3.0
//   0x180AE5274  flt_180AE5274 = 3.1415927410125732
//   0x180AE52D0  dword_180AE52D0 = 4.0
//   0x180AE52F0  flt_180AE52F0 = 4.71238899230957
//   0x180AE52F4  dword_180AE52F4 = 5.0
//   0x180AE5310  dword_180AE5310 = 6.0
//   0x180AE5328  flt_180AE5328 = 6.2831854820251465
//   0x180AE5350  dword_180AE5350 = 8.0
//   0x180AE5398  dword_180AE5398 = 15.0
//   0x180AE5428  qword_180AE5428 = 0.0
//   0x180AE5570  xmmword_180AE5570 = 1.0

// Hidden C++ exception states: #wind=2
void __fastcall sub_18088E690(__int64 a1, __int64 a2, int a3, int a4, _BYTE **a5, _DWORD *a6, __int64 a7)
{
  void *v10; // rax
  __int64 v11; // rax
  __int64 v12; // rax
  __int64 v13; // rbx
  float v14; // xmm9_4
  float v15; // xmm12_4
  float v16; // xmm8_4
  float v17; // xmm0_4
  float v18; // xmm8_4
  float v19; // xmm15_4
  _BYTE **v20; // rsi
  float v21; // xmm11_4
  float v22; // xmm2_4
  __int64 v23; // rax
  float v24; // xmm2_4
  _BYTE *v25; // rdx
  __int64 i; // r8
  int v27; // ecx
  float v28; // xmm11_4
  float v29; // xmm3_4
  float v30; // xmm6_4
  float v31; // xmm6_4
  float v32; // xmm2_4
  int v33; // edx
  int v34; // r8d
  int v35; // r9d
  int v36; // xmm7_4
  int v37; // edx
  int v38; // r8d
  int v39; // r9d
  int v40; // edx
  int v41; // r8d
  int v42; // r9d
  int v43; // edx
  int v44; // r8d
  int v45; // r9d
  __int64 v46; // rdi
  float v47; // xmm7_4
  char v48; // bl
  char v49; // dl
  __int64 v50; // r8
  __int64 v51; // rcx
  void (*v52)(void); // rdx
  _QWORD *v53; // rcx
  __int64 (__fastcall *v54)(); // r8
  void (__fastcall ***v55)(_QWORD, __int64); // rcx
  __int64 v56; // [rsp+50h] [rbp-B0h] BYREF
  void *Block; // [rsp+58h] [rbp-A8h] BYREF
  __int64 v58; // [rsp+60h] [rbp-A0h]
  __int128 v59; // [rsp+68h] [rbp-98h]
  char v60; // [rsp+78h] [rbp-88h]
  int v61; // [rsp+80h] [rbp-80h] BYREF
  __int64 v62; // [rsp+84h] [rbp-7Ch]
  char v63[4]; // [rsp+8Ch] [rbp-74h] BYREF
  int v64; // [rsp+90h] [rbp-70h]
  double v65; // [rsp+98h] [rbp-68h]
  double v66; // [rsp+A0h] [rbp-60h]
  __int64 v67; // [rsp+A8h] [rbp-58h]
  double v68; // [rsp+B0h] [rbp-50h]
  double v69; // [rsp+B8h] [rbp-48h]
  __int128 v70; // [rsp+C0h] [rbp-40h] BYREF
  __int64 v71; // [rsp+D0h] [rbp-30h]
  __int64 v72; // [rsp+D8h] [rbp-28h]
  char v73; // [rsp+1B8h] [rbp+B8h] BYREF
  unsigned int v74; // [rsp+1C0h] [rbp+C0h]
  unsigned int v75; // [rsp+1C8h] [rbp+C8h]

  v72 = -2;
  v10 = operator new(0x40u);
  v11 = sub_18015C2F0(v10, 0);
  v56 = v11;
  if ( v11 )
  {
    _InterlockedExchangeAdd((volatile signed __int32 *)(v11 + 8), 1u);
    v11 = v56;
  }
  Block = nullptr;
  v58 = 0;
  v59 = 0;
  v60 = 1;
  if ( *(float *)(v11 + 52) == 0.0 )
  {
    v12 = sub_1807D2110(&v56);
    v13 = v56;
    *(float *)(v13 + 52) = (*(float (__fastcall **)(__int64))(*(_QWORD *)v12 + 16LL))(v12);
    v11 = v56;
  }
  v14 = (float)(*(float *)(v11 + 52) * *(float *)(v11 + 40)) - 3.0;
  v15 = fmaxf((float)a3 - 6.0, 0.0);
  v16 = fmaxf((float)((float)a4 - v14) - 3.0, 0.0) * 0.5;
  v17 = v15 * 0.5;
  if ( (float)(v15 * 0.5) >= 5.0 )
    v18 = fminf(v16, 5.0);
  else
    v18 = fminf(v16, v17);
  v19 = v18 + v18;
  v20 = a5;
  if ( !**a5 )
  {
    v21 = 0.0;
    v22 = v15 - v19;
    goto LABEL_22;
  }
  v23 = sub_1807D2110(&v56);
  (*(void (__fastcall **)(__int64, _BYTE **))(*(_QWORD *)v23 + 40LL))(v23, v20);
  v24 = *(float *)(v56 + 48);
  if ( v24 != 0.0 )
  {
    v25 = *v20;
    for ( i = 0; ; ++i )
    {
      while ( 1 )
      {
        v27 = (unsigned __int8)*v25++;
        if ( (v27 & 0x80u) != 0 )
          break;
        if ( !v27 )
        {
          v17 = v17 + (float)((float)(int)i * v24);
          goto LABEL_19;
        }
LABEL_17:
        ++i;
      }
      if ( (*v25 & 0xC0) != 0x80 )
        goto LABEL_17;
      do
        ++v25;
      while ( (*v25 & 0xC0) == 0x80 );
    }
  }
LABEL_19:
  v22 = v15 - v19;
  v28 = fmaxf((float)(v15 - v19) - 8.0, 0.0);
  v29 = (float)(int)ceilf((float)(v17 * *(float *)(v56 + 40)) * *(float *)(v56 + 44)) + 8.0;
  if ( v29 >= 0.0 )
    v21 = fminf(v28, v29);
  else
    v21 = 0.0;
LABEL_22:
  v30 = v18 + 4.0;
  if ( (*a6 & 4) != 0 )
  {
    v30 = (float)((float)(v22 - v21) * 0.5) + v18;
  }
  else if ( (*a6 & 2) != 0 )
  {
    v30 = (float)((float)(v15 - v18) - v21) - 4.0;
  }
  v31 = v30 + 3.0;
  v32 = v31 + v21;
  if ( !HIDWORD(v58) )
  {
    *((float *)&v59 + 1) = v31 + v21;
    *(float *)&v59 = v31 + v21;
    *((float *)&v59 + 2) = v14;
LABEL_35:
    *((float *)&v59 + 3) = v14;
    goto LABEL_36;
  }
  if ( *(float *)&v59 <= v32 )
  {
    if ( v32 > *((float *)&v59 + 1) )
      *((float *)&v59 + 1) = v31 + v21;
  }
  else
  {
    *(float *)&v59 = v31 + v21;
  }
  if ( *((float *)&v59 + 2) > v14 )
  {
    *((float *)&v59 + 2) = v14;
    goto LABEL_36;
  }
  if ( v14 > *((float *)&v59 + 3) )
    goto LABEL_35;
LABEL_36:
  sub_180179780(&Block, &unk_180AA33E4);
  sub_18082B140(&Block);
  *(float *)&v36 = v19 * 0.5;
  if ( (float)(v19 * 0.5) > 0.0 )
    sub_18082A130((int)&Block, v33, v34, v35, v36, 0.0, 0.0, 1.5707964, 0);
  sub_18082B140(&Block);
  if ( *(float *)&v36 > 0.0 )
    sub_18082A130((int)&Block, v37, v38, v39, v36, 0.0, 1.5707964, 3.1415927, 0);
  sub_18082B140(&Block);
  if ( *(float *)&v36 > 0.0 )
    sub_18082A130((int)&Block, v40, v41, v42, v36, 0.0, 3.1415927, 4.712389, 0);
  sub_18082B140(&Block);
  if ( *(float *)&v36 > 0.0 )
    sub_18082A130((int)&Block, v43, v44, v45, v36, 0.0, 4.712389, 6.2831855, 0);
  sub_18082B140(&Block);
  v46 = a7;
  v47 = 1.0;
  if ( (*(_BYTE *)(a7 + 169) & 0x10) != 0 || *(_QWORD *)(a7 + 24) && !(unsigned __int8)sub_1808C7290() )
    v47 = 0.5;
  v74 = *(_DWORD *)sub_1808D6630(v46, &v73, 16798720, 0);
  v65 = (float)((float)HIBYTE(v74) * v47) + 6.755399441055744e15;
  v48 = -1;
  v49 = -1;
  if ( SLODWORD(v65) < 255 )
    v49 = LOBYTE(v65);
  HIBYTE(v74) = v49;
  sub_180831D50(a2, v74);
  v70 = xmmword_180AE5570;
  v71 = 1065353216;
  v61 = 0x40000000;
  v62 = 0;
  sub_180830CE0(a2, &Block, &v61, &v70);
  v75 = *(_DWORD *)sub_1808D6630(v46, v63, 16798736, 0);
  v66 = (float)((float)HIBYTE(v75) * v47) + 6.755399441055744e15;
  if ( SLODWORD(v66) < 255 )
    v48 = LOBYTE(v66);
  HIBYTE(v75) = v48;
  sub_180831D50(a2, v75);
  if ( *(_BYTE *)(a2 + 16) )
  {
    *(_BYTE *)(a2 + 16) = 0;
    v51 = *(_QWORD *)(a2 + 8);
    v52 = *(void (**)(void))(*(_QWORD *)v51 + 104LL);
    if ( (char *)v52 == (char *)sub_180163CA0 )
      sub_18016CBD0(v51 + 8, v52, v50);
    else
      v52();
  }
  v53 = *(_QWORD **)(a2 + 8);
  v54 = *(__int64 (__fastcall **)())(*v53 + 208LL);
  if ( v54 == sub_1801637B0 )
    sub_1808322E0(v53[1] + 112LL, &v56);
  else
    ((void (__fastcall *)(_QWORD *, __int64 *))v54)(v53, &v56);
  v64 = 36;
  v67 = 0x433800000000000FLL;
  v68 = v21 + 6.755399441055744e15;
  v69 = v31 + 6.755399441055744e15;
  sub_1808318C0(a2, (_DWORD)v20, LODWORD(v69), 0, LODWORD(v68), 15, 36, 1);
  HIDWORD(v58) = 0;
  free(Block);
  v55 = (void (__fastcall ***)(_QWORD, __int64))v56;
  if ( v56 )
  {
    if ( _InterlockedExchangeAdd((volatile signed __int32 *)(v56 + 8), 0xFFFFFFFF) == 1 )
      (**v55)(v55, 1);
  }
}

