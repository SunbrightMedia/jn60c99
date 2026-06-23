// sub_1800B8400  @ 0x1800B8400  (RVA 0xB8400)
// prototype: __int64 __fastcall(_QWORD, _QWORD, _QWORD)
// callees: 0x1800B8400, 0x180648140, 0x18067522C, 0x180675FE8, 0x1806ADC00, 0x1806BC26C

_BYTE *__fastcall sub_1800B8400(_QWORD *a1, unsigned __int64 a2, __int64 a3)
{
  __int64 v3; // r14
  _QWORD *v4; // rbx
  unsigned __int64 v5; // rdi
  unsigned __int64 v6; // r8
  unsigned __int64 v7; // rcx
  size_t v8; // rcx
  _QWORD *v9; // rsi
  void *v10; // rax
  _QWORD *v11; // rdx
  unsigned __int64 v12; // rax
  char *v13; // rcx
  char *v14; // rax
  unsigned __int64 v15; // rcx
  _BYTE *result; // rax
  size_t v17; // rcx
  _QWORD *v18; // rax
  void *v19; // rcx

  v3 = a3;
  v4 = a1;
  v5 = a2 | 0xF;
  if ( (a2 | 0xF) == 0xFFFFFFFFFFFFFFFFuLL )
  {
    v5 = a2;
  }
  else
  {
    v6 = a1[3];
    v7 = v6 >> 1;
    if ( v6 >> 1 > v5 / 3 )
    {
      v5 = -2;
      if ( v6 <= -2LL - v7 )
        v5 = v7 + v6;
    }
  }
  v8 = v5 + 1;
  if ( v5 == -1 )
  {
    v9 = nullptr;
  }
  else
  {
    try
    {
      if ( v8 < 0x1000 )
      {
        v9 = operator new(v8);
      }
      else
      {
        if ( v5 + 40 < v5 + 1 )
          Concurrency::cancel_current_task();
        v10 = operator new(v5 + 40);
        v9 = (_QWORD *)(((unsigned __int64)v10 + 39) & 0xFFFFFFFFFFFFFFE0uLL);
        *(v9 - 1) = v10;
      }
    }
    catch ( ... )
    {
      v17 = a2 + 1;
      if ( a2 == -1 )
      {
        v18 = nullptr;
      }
      else if ( v17 < 0x1000 )
      {
        v18 = operator new(v17);
      }
      else
      {
        if ( a2 + 40 < a2 + 1 )
          Concurrency::cancel_current_task();
        v19 = operator new(a2 + 40);
        v18 = (_QWORD *)(((unsigned __int64)v19 + 39) & 0xFFFFFFFFFFFFFFE0uLL);
        *(v18 - 1) = v19;
      }
      v4 = a1;
      v3 = a3;
      v5 = a2;
      v9 = v18;
    }
  }
  if ( v3 )
  {
    if ( v4[3] < 0x10u )
      v11 = v4;
    else
      v11 = (_QWORD *)*v4;
    sub_1806ADC00(v9, v11, v3);
  }
  v12 = v4[3];
  if ( v12 >= 0x10 )
  {
    v13 = (char *)*v4;
    if ( v12 + 1 >= 0x1000 )
    {
      if ( ((unsigned __int8)v13 & 0x1F) != 0 )
        invalid_parameter_noinfo_noreturn();
      v14 = *((char **)v13 - 1);
      if ( v14 >= v13 )
        invalid_parameter_noinfo_noreturn();
      v15 = v13 - v14;
      if ( v15 < 8 )
        invalid_parameter_noinfo_noreturn();
      if ( v15 > 0x27 )
        invalid_parameter_noinfo_noreturn();
      v13 = v14;
    }
    j_free(v13);
  }
  v4[3] = 15;
  v4[2] = 0;
  if ( v4[3] < 0x10u )
    result = v4;
  else
    result = (_BYTE *)*v4;
  *result = 0;
  *v4 = v9;
  v4[3] = v5;
  v4[2] = v3;
  if ( v4[3] >= 0x10u )
    v4 = v9;
  *((_BYTE *)v4 + v3) = 0;
  return result;
}

