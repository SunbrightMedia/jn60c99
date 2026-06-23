// sub_1801F2CF0  @ 0x1801F2CF0  (RVA 0x1F2CF0)  floats=14
// .rdata float constants referenced by this function:
//   0x180AE4F9C  dword_180AE4F9C = 0.10000000149011612
//   0x180AE4FB8  dword_180AE4FB8 = 0.15000000596046448
//   0x180AE4FC0  dword_180AE4FC0 = 0.20000000298023224
//   0x180AE4FF8  dword_180AE4FF8 = 0.4000000059604645
//   0x180AE500C  dword_180AE500C = 0.5
//   0x180AE5030  dword_180AE5030 = 0.6000000238418579
//   0x180AE5070  dword_180AE5070 = 0.800000011920929
//   0x180AE50B4  dword_180AE50B4 = 1.0
//   0x180AE5110  dword_180AE5110 = 1.5
//   0x180AE5478  dword_180AE5478 = 100001.0
//   0x180AE547C  dword_180AE547C = 100002.0
//   0x180AE5480  dword_180AE5480 = 100003.0
//   0x180AE5484  dword_180AE5484 = 100004.0
//   0x180AE5570  xmmword_180AE5570 = 1.0

// Hidden C++ exception states: #wind=1
void __fastcall sub_1801F2CF0(__int64 a1, __int64 a2, __int64 a3, __int64 a4)
{
  int v6; // edi
  int v7; // esi
  unsigned int *v8; // rax
  __int64 v9; // rax
  int v10; // edx
  int v11; // r8d
  int v12; // r9d
  float v13; // xmm0_4
  unsigned int *v14; // rax
  int v15; // r8d
  int v16; // r15d
  int v17; // r8d
  int v18; // r9d
  __m128 v19; // xmm11
  __m128 v20; // xmm1
  float v21; // xmm2_4
  float v22; // xmm3_4
  float v23; // xmm4_4
  __m128 v24; // xmm8
  float v25; // xmm12_4
  float v26; // xmm9_4
  float v27; // xmm10_4
  __m128 v28; // xmm9
  __m128 v29; // xmm1
  __m128 v30; // xmm1
  __m128 v31; // xmm1
  __m128 v32; // xmm8
  __m128 v33; // xmm8
  __m128 v34; // xmm8
  int v35; // r8d
  int v36; // r9d
  float *v37; // rcx
  char *v38; // rdx
  float v39; // xmm0_4
  _QWORD v40[3]; // [rsp+40h] [rbp-91h] BYREF
  int v41; // [rsp+58h] [rbp-79h]
  int v42; // [rsp+5Ch] [rbp-75h]
  void *Block; // [rsp+68h] [rbp-69h] BYREF
  __int64 v44; // [rsp+70h] [rbp-61h]
  __int128 v45; // [rsp+78h] [rbp-59h]
  char v46; // [rsp+88h] [rbp-49h]
  char v47; // [rsp+138h] [rbp+67h] BYREF

  v6 = *(_DWORD *)(a1 + 40);
  v7 = *(_DWORD *)(a1 + 44);
  if ( *(_BYTE *)(a1 + 516) )
  {
    LOBYTE(a4) = 1;
    v8 = (unsigned int *)sub_1808D6630(a1, &v47, 16790032, a4);
    sub_180831D50(a2, *v8);
    v9 = _RTDynamicCast(
           *(_QWORD *)(a1 + 24),
           0,
           &juce::Component `RTTI Type Descriptor',
           &juce::Toolbar `RTTI Type Descriptor',
           0);
    if ( v9 && *(_BYTE *)(v9 + 216) )
      v13 = (float)v7 * 0.2;
    else
      v13 = (float)v7 * 0.80000001;
    sub_180821A80(a2, v10, v11, v12, LODWORD(v13));
  }
  if ( *(_DWORD *)(a1 + 460) && !*(_BYTE *)(a1 + 516) )
  {
    LOBYTE(a4) = 1;
    v14 = (unsigned int *)sub_1808D6630(a1, &v47, 16790032, a4);
    sub_180831D50(a2, *v14);
    v15 = 2;
    v16 = 2;
    if ( (v6 - 3) / 2 < 2 )
      v16 = (v6 - 3) / 2;
    if ( (v7 - 3) / 2 < 2 )
      v15 = (v7 - 3) / 2;
    sub_180821880(a2, v16, v15, v6 - 2 * v16, v7 - 2 * v15, 1);
    if ( *(float *)(a1 + 512) <= 0.0 )
    {
      if ( (unsigned __int8)sub_18084FE50(a1) )
      {
        v19 = (__m128)COERCE_UNSIGNED_INT((float)v6);
        v20 = v19;
        v20.m128_f32[0] = v19.m128_f32[0] * 0.5;
        v21 = (float)v7 * 0.40000001;
        v22 = v19.m128_f32[0] * 0.5;
        v23 = (float)v16 + (float)v16;
        v24 = v20;
        v25 = (float)v7 * 0.60000002;
        v26 = v19.m128_f32[0] * 0.5;
        v27 = (float)v7 - v23;
      }
      else
      {
        v28 = (__m128)COERCE_UNSIGNED_INT((float)v6);
        v20 = v28;
        v20.m128_f32[0] = v28.m128_f32[0] * 0.40000001;
        v19.m128_f32[0] = (float)v7;
        v21 = (float)v7 * 0.5;
        v22 = (float)v16 + (float)v16;
        v23 = v21;
        v24 = v28;
        v24.m128_f32[0] = v28.m128_f32[0] * 0.60000002;
        v25 = v21;
        v26 = v28.m128_f32[0] - v22;
        v27 = v21;
      }
      Block = nullptr;
      v44 = 0;
      v45 = 0;
      v46 = 1;
      v29 = _mm_shuffle_ps(v20, v20, 225);
      v29.m128_f32[0] = v21;
      v30 = _mm_shuffle_ps(v29, v29, 198);
      v30.m128_f32[0] = v22;
      v31 = _mm_shuffle_ps(v30, v30, 39);
      v31.m128_f32[0] = v23;
      *(__m128 *)&v40[1] = _mm_shuffle_ps(v31, v31, 57);
      sub_180829800((unsigned int)&Block, (unsigned int)&v40[1], v17, v18, v19.m128_f32[0] * 0.2);
      v32 = _mm_shuffle_ps(v24, v24, 225);
      v32.m128_f32[0] = v25;
      v33 = _mm_shuffle_ps(v32, v32, 198);
      v33.m128_f32[0] = v26;
      v34 = _mm_shuffle_ps(v33, v33, 39);
      v34.m128_f32[0] = v27;
      *(__m128 *)&v40[1] = _mm_shuffle_ps(v34, v34, 57);
      sub_180829800((unsigned int)&Block, (unsigned int)&v40[1], v35, v36, v19.m128_f32[0] * 0.2);
      if ( !(*(unsigned __int8 (__fastcall **)(_QWORD))(**(_QWORD **)(a2 + 8) + 96LL))(*(_QWORD *)(a2 + 8)) )
      {
        v37 = (float *)Block;
        v38 = (char *)Block + 4 * SHIDWORD(v44);
        if ( Block != v38 )
        {
          do
          {
            v39 = *v37;
            if ( *v37 == 100002.0 )
            {
              v37 += 2;
            }
            else if ( v39 == 100001.0 || v39 == 100003.0 || v39 == 100004.0 )
            {
              *(_OWORD *)&v40[1] = xmmword_180AE5570;
              v41 = 1065353216;
              v42 = 0;
              (*(void (__fastcall **)(_QWORD, void **, _QWORD *))(**(_QWORD **)(a2 + 8) + 184LL))(
                *(_QWORD *)(a2 + 8),
                &Block,
                &v40[1]);
              break;
            }
            ++v37;
          }
          while ( v37 != (float *)v38 );
        }
      }
      HIDWORD(v44) = 0;
      free(Block);
    }
  }
}

