// __std_exception_copy  @ 0x1806AF654  (RVA 0x6AF654)
// prototype: __int64 __fastcall(_QWORD, _QWORD)
// callees: 0x1806AF654, 0x1806BC340, 0x1806EBEE4, 0x1806F4B60

void __fastcall _std_exception_copy(__int64 a1, __int64 a2)
{
  __int64 v4; // rdi
  char *v5; // rax
  char *v6; // rbx

  if ( *(_BYTE *)(a1 + 8) && *(_QWORD *)a1 )
  {
    v4 = -1;
    do
      ++v4;
    while ( *(_BYTE *)(*(_QWORD *)a1 + v4) );
    v5 = (char *)j__malloc_base(v4 + 1);
    v6 = v5;
    if ( v5 )
    {
      strcpy_s_0(v5, v4 + 1, *(const char **)a1);
      *(_BYTE *)(a2 + 8) = 1;
      *(_QWORD *)a2 = v6;
      v6 = nullptr;
    }
    free(v6);
  }
  else
  {
    *(_QWORD *)a2 = *(_QWORD *)a1;
    *(_BYTE *)(a2 + 8) = 0;
  }
}

