// sub_1803C5070  @ 0x1803C5070  (RVA 0x3C5070)
// prototype: 
// callees: 0x1803C5070, 0x1803C5CF0, 0x1803C7FB0, 0x18067522C, 0x180675268, 0x1806BC26C

__int64 __fastcall sub_1803C5070(unsigned __int64 *a1, _QWORD *a2, __int64 *a3)
{
  _QWORD *v4; // rbx
  __int64 v6; // r14
  __int64 v7; // rax
  unsigned __int64 v8; // r13
  unsigned __int64 v9; // rcx
  unsigned __int64 v10; // rdx
  unsigned __int64 v11; // rax
  size_t v12; // rcx
  unsigned __int64 v13; // rdx
  size_t v14; // rcx
  void *v15; // rax
  unsigned __int64 v16; // rdi
  void *v17; // rax
  __int64 v18; // r12
  __int64 *v19; // rcx
  __int64 v20; // rax
  _QWORD *v21; // r8
  _QWORD *v22; // rcx
  unsigned __int64 v23; // r9
  unsigned __int64 v24; // r8
  unsigned __int64 v25; // rcx
  _QWORD *v26; // rbx
  _QWORD *v27; // r14
  __int64 result; // rax
  unsigned __int64 v29; // [rsp+20h] [rbp-58h]
  __int64 v30; // [rsp+28h] [rbp-50h]
  _QWORD *v31; // [rsp+30h] [rbp-48h]
  unsigned __int64 v33; // [rsp+98h] [rbp+20h]

  v4 = a2;
  v6 = (__int64)((__int64)a2 - *a1) >> 3;
  v7 = (__int64)(a1[1] - *a1) >> 3;
  if ( v7 == 0x1FFFFFFFFFFFFFFFLL )
    std::vector<void *>::_Xlen();
  v8 = v7 + 1;
  v9 = (__int64)(a1[2] - *a1) >> 3;
  v10 = v9 >> 1;
  if ( v9 <= 0x1FFFFFFFFFFFFFFFLL - (v9 >> 1) )
  {
    v11 = v10 + v9;
    if ( v10 + v9 < v8 )
      v11 = v8;
  }
  else
  {
    v11 = v7 + 1;
  }
  v29 = v11;
  v12 = 8 * v11;
  v30 = 8 * v11;
  v13 = 8 * v11;
  if ( v11 <= 0x1FFFFFFFFFFFFFFFLL )
  {
    if ( v12 < 0x1000 )
    {
      if ( v12 )
      {
        v17 = operator new(v12);
        v16 = (unsigned __int64)v17;
      }
      else
      {
        v16 = 0;
      }
      goto LABEL_16;
    }
  }
  else
  {
    v13 = -1;
  }
  v14 = v13 + 39;
  if ( v13 + 39 < v13 )
    v14 = -1;
  v15 = operator new(v14);
  if ( !v15 )
    invalid_parameter_noinfo_noreturn();
  v16 = ((unsigned __int64)v15 + 39) & 0xFFFFFFFFFFFFFFE0uLL;
  *(_QWORD *)(v16 - 8) = v15;
LABEL_16:
  v18 = 8 * v6;
  v19 = (__int64 *)(8 * v6 + v16);
  v31 = v19 + 1;
  try
  {
    v20 = *a3;
    *v19 = *a3;
    if ( v20 )
      _InterlockedIncrement((volatile signed __int32 *)(v20 + 24));
    v33 = 8 * v6 + v16;
    v21 = (_QWORD *)a1[1];
    v22 = (_QWORD *)*a1;
    if ( v4 == v21 )
    {
      if ( v22 != v21 )
      {
        v23 = v16 - (_QWORD)v22;
        do
        {
          *(_QWORD *)((char *)v22 + v23) = *v22;
          *v22++ = 0;
        }
        while ( v22 != v21 );
      }
    }
    else
    {
      if ( v22 != v4 )
      {
        v24 = v16 - (_QWORD)v22;
        do
        {
          *(_QWORD *)((char *)v22 + v24) = *v22;
          *v22++ = 0;
        }
        while ( v22 != v4 );
        v21 = (_QWORD *)a1[1];
      }
      v33 = v16;
      if ( v4 != v21 )
      {
        v25 = v16 + v18 - (_QWORD)v4;
        do
        {
          *(_QWORD *)((char *)v4 + v25 + 8) = *v4;
          *v4++ = 0;
        }
        while ( v4 != v21 );
      }
    }
    v26 = (_QWORD *)*a1;
    if ( *a1 )
    {
      v27 = (_QWORD *)a1[1];
      if ( v26 != v27 )
      {
        do
          sub_1803C5CF0(v26++);
        while ( v26 != v27 );
        v26 = (_QWORD *)*a1;
      }
      if ( ((a1[2] - (_QWORD)v26) & 0xFFFFFFFFFFFFFFF8uLL) >= 0x1000 )
      {
        if ( (unsigned __int64)v26 - *(v26 - 1) - 8 > 0x1F )
          invalid_parameter_noinfo_noreturn();
        v26 = (_QWORD *)*(v26 - 1);
      }
      j_j_free(v26);
    }
    *a1 = v16;
    a1[1] = v16 + 8 * v8;
    a1[2] = v16 + v30;
    result = v18 + *a1;
  }
  catch ( ... )
  {
    sub_1803C7F70(a1, v33, v31);
    sub_1803C80D0(a1, v16, v29);
    throw;
  }
  return result;
}

