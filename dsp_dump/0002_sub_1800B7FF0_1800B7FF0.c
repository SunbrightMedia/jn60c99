// sub_1800B7FF0  @ 0x1800B7FF0  (RVA 0xB7FF0)
// prototype: __int64 __fastcall(_QWORD, _QWORD, _QWORD, _QWORD)
// callees: 0x1800B7DC0, 0x1800B7FF0, 0x1800B8260, 0x1800B83E0, 0x1800B8400, 0x1806ADC00

_QWORD *__fastcall sub_1800B7FF0(_QWORD *a1, _QWORD *a2, unsigned __int64 a3, unsigned __int64 a4)
{
  unsigned __int64 v4; // rax
  unsigned __int64 v5; // rdi
  _QWORD *v7; // rsi
  _QWORD *v8; // rbx
  unsigned __int64 v9; // rax
  unsigned __int64 v10; // rax
  _QWORD *v11; // rcx
  bool v12; // cf
  _QWORD *v13; // rax

  v4 = a2[2];
  v5 = a4;
  v7 = a2;
  v8 = a1;
  if ( v4 < a3 )
    std::vector<void *>::_Xlen(a2);
  v9 = v4 - a3;
  if ( a4 > v9 )
    v5 = v9;
  if ( a1 == a2 )
  {
    v10 = a3 + v5;
    if ( a1[2] < a3 + v5 )
      std::vector<void *>::_Xlen(a1);
    a1[2] = v10;
    if ( a1[3] >= 0x10u )
      a1 = (_QWORD *)*a1;
    *((_BYTE *)a1 + v10) = 0;
    sub_1800B7DC0(v8, 0, a3);
  }
  else
  {
    if ( v5 == -1 )
      std::vector<void *>::_Xlen();
    if ( a1[3] >= v5 )
    {
      if ( !v5 )
      {
        v12 = a1[3] < 0x10u;
        a1[2] = 0;
        if ( v12 )
          *(_BYTE *)a1 = 0;
        else
          *(_BYTE *)*a1 = 0;
        return v8;
      }
    }
    else
    {
      sub_1800B8400(a1, v5, a1[2]);
      if ( !v5 )
        return v8;
    }
    if ( v7[3] >= 0x10u )
      v7 = (_QWORD *)*v7;
    if ( v8[3] < 0x10u )
      v11 = v8;
    else
      v11 = (_QWORD *)*v8;
    sub_1806ADC00(v11, (char *)v7 + a3, v5);
    v12 = v8[3] < 0x10u;
    v8[2] = v5;
    if ( v12 )
      v13 = v8;
    else
      v13 = (_QWORD *)*v8;
    *((_BYTE *)v13 + v5) = 0;
  }
  return v8;
}

