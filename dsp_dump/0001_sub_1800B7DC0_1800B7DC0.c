// sub_1800B7DC0  @ 0x1800B7DC0  (RVA 0xB7DC0)
// prototype: 
// callees: 0x1800B7DC0, 0x1800B83E0, 0x1806ADC00

_QWORD *__fastcall sub_1800B7DC0(_QWORD *a1, unsigned __int64 a2, unsigned __int64 a3)
{
  unsigned __int64 v3; // rdi
  _QWORD *v6; // rax
  unsigned __int64 v7; // rdi
  bool v8; // cf

  v3 = a1[2];
  if ( v3 < a2 )
    std::vector<void *>::_Xlen();
  if ( v3 - a2 > a3 )
  {
    if ( a3 )
    {
      if ( a1[3] < 0x10u )
        v6 = a1;
      else
        v6 = (_QWORD *)*a1;
      v7 = v3 - a3;
      if ( v7 != a2 )
        sub_1806ADC00((char *)v6 + a2, (char *)v6 + a2 + a3, v7 - a2);
      v8 = a1[3] < 0x10u;
      a1[2] = v7;
      if ( !v8 )
      {
        *(_BYTE *)(*a1 + v7) = 0;
        return a1;
      }
      *((_BYTE *)a1 + v7) = 0;
    }
    return a1;
  }
  else
  {
    a1[2] = a2;
    if ( a1[3] < 0x10u )
    {
      *((_BYTE *)a1 + a2) = 0;
      return a1;
    }
    else
    {
      *(_BYTE *)(*a1 + a2) = 0;
      return a1;
    }
  }
}

