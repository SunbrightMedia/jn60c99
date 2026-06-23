// sub_1801D8E00  @ 0x1801D8E00  (RVA 0x1D8E00)  floats=14
// .rdata float constants referenced by this function:
//   0x180AE4FC0  dword_180AE4FC0 = 0.20000000298023224
//   0x180AE4FD4  dword_180AE4FD4 = 0.2721000015735626
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5024  dword_180AE5024 = 0.550000011920929
//   0x180AE5030  dword_180AE5030 = 0.6000000238418579
//   0x180AE5040  dword_180AE5040 = 0.6209999918937683
//   0x180AE5048  dword_180AE5048 = 0.6474000215530396
//   0x180AE504C  dword_180AE504C = 0.6499999761581421
//   0x180AE505C  dword_180AE505C = 0.7142857313156128
//   0x180AE50A8  dword_180AE50A8 = 0.9563000202178955
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE50C8  dword_180AE50C8 = 1.1069999933242798
//   0x180AE5150  dword_180AE5150 = 1.7045999765396118
//   0x180AE543C  dword_180AE543C = 255.0

// Hidden C++ exception states: #wind=1
__int64 __fastcall sub_1801D8E00(__int64 a1, __int64 a2, char a3, char a4)
{
  unsigned int v8; // ebx
  __int64 v9; // rdi
  __int64 v10; // rax
  __m128 v11; // xmm10
  float v12; // xmm11_4
  float v13; // xmm8_4
  float v14; // xmm8_4
  __m128 v15; // xmm9
  float v16; // xmm12_4
  __m128 v17; // xmm0
  __m128 v18; // xmm0
  __m128 v19; // xmm0
  __int64 v20; // r8
  __int64 v21; // rdx
  unsigned int v22; // r8d
  int v23; // r9d
  __int64 v24; // rcx
  __m128 v25; // xmm9
  __m128 v26; // xmm9
  __m128 v27; // xmm9
  _QWORD *v28; // rax
  char v29; // bl
  int v30; // r8d
  int v31; // r9d
  __int64 v32; // rcx
  __int64 v33; // rbx
  __int64 v34; // rdi
  __int64 result; // rax
  __m128 v36; // [rsp+58h] [rbp-79h] BYREF
  _OWORD v37[10]; // [rsp+68h] [rbp-69h] BYREF
  unsigned int v38; // [rsp+150h] [rbp+7Fh] BYREF

  v8 = dword_180C96484;
  v9 = *(_QWORD *)(a1 + 24);
  if ( v9 )
  {
    while ( 1 )
    {
      v10 = _RTDynamicCast(
              v9,
              0,
              &juce::Component `RTTI Type Descriptor',
              &juce::ResizableWindow `RTTI Type Descriptor',
              0);
      if ( v10 )
        break;
      v9 = *(_QWORD *)(v9 + 24);
      if ( !v9 )
        goto LABEL_6;
    }
    sub_1808D6630(v10, &v38, 16799488, 0);
    v8 = v38;
  }
LABEL_6:
  v11 = (__m128)COERCE_UNSIGNED_INT((float)*(int *)(a1 + 40));
  v11.m128_f32[0] = v11.m128_f32[0] * 0.5;
  v12 = (float)*(int *)(a1 + 44) * 0.5;
  if ( a4 )
    v13 = 0.60000002;
  else
    v13 = 0.64999998;
  v14 = v13 * fminf(v12, v11.m128_f32[0]);
  sub_180831D50(a2, v8);
  v15 = v11;
  v15.m128_f32[0] = v11.m128_f32[0] - v14;
  v16 = v14 + v14;
  v17 = _mm_shuffle_ps(v15, v15, 225);
  v17.m128_f32[0] = v12 - v14;
  v18 = _mm_shuffle_ps(v17, v17, 198);
  v18.m128_f32[0] = v14 + v14;
  v19 = _mm_shuffle_ps(v18, v18, 39);
  v19.m128_f32[0] = v14 + v14;
  v36 = _mm_shuffle_ps(v19, v19, 57);
  sub_180821410(a2, &v36);
  sub_180157890(v37, v8, *(unsigned int *)(a1 + 456));
  sub_180157890(&v36, (unsigned int)v20, v20);
  if ( (float)fabs((float)(*(float *)v37 - v36.m128_f32[0])) < 0.60000002 )
  {
    sub_1808306B0((unsigned int)&v38, v21, v22, v23, v36.m128_i32[3]);
    v22 = v38;
  }
  if ( (*(_BYTE *)(a1 + 169) & 0x10) != 0
    || (v24 = *(_QWORD *)(a1 + 24)) != 0 && !(unsigned __int8)sub_1808C7290(v24, v21) )
  {
    v38 = v22;
    HIBYTE(v38) = -103;
  }
  else
  {
    if ( !a3 )
      goto LABEL_18;
    LOBYTE(v38) = (int)(float)(255.0 - (float)((float)(255 - (unsigned __int8)v22) * 0.71428573));
    BYTE1(v38) = (int)(float)(255.0 - (float)((float)(255 - BYTE1(v22)) * 0.71428573));
    BYTE2(v38) = (int)(float)(255.0 - (float)((float)(255 - BYTE2(v22)) * 0.71428573));
    HIBYTE(v38) = HIBYTE(v22);
  }
  v22 = v38;
LABEL_18:
  sub_180831D50(a2, v22);
  v25 = _mm_shuffle_ps(v15, v15, 225);
  v25.m128_f32[0] = v12 - v14;
  v26 = _mm_shuffle_ps(v25, v25, 198);
  v26.m128_f32[0] = v16;
  v27 = _mm_shuffle_ps(v26, v26, 39);
  v27.m128_f32[0] = v16;
  v36 = _mm_shuffle_ps(v27, v27, 57);
  v37[0] = v36;
  sub_180821140(a2, v37);
  v28 = (_QWORD *)sub_1807A9D30(a1 + 424, &v36);
  v29 = (*(__int64 (__fastcall **)(_QWORD, _QWORD *))(*(_QWORD *)*v28 + 40LL))(*v28, v28 + 1);
  (*(void (__fastcall **)(unsigned __int64, __int8 *))(*(_QWORD *)v36.m128_u64[0] + 176LL))(
    v36.m128_u64[0],
    &v36.m128_i8[8]);
  v32 = 464;
  if ( v29 )
    v32 = 504;
  v33 = v32 + a1;
  v34 = sub_180828260((int)v32 + (int)a1, (unsigned int)v37, v30, v31, v16 * 0.55000001, v16 * 0.55000001, 1, 36);
  result = (*(__int64 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8));
  if ( !(_BYTE)result )
  {
    result = sub_18082B340(v33);
    if ( !(_BYTE)result )
      return (*(__int64 (__fastcall **)(_QWORD, __int64, __int64))(**(_QWORD **)(a2 + 8) + 184LL))(
               *(_QWORD *)(a2 + 8),
               v33,
               v34);
  }
  return result;
}

