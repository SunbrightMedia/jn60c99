// __std_exception_destroy  @ 0x1806AF6E4  (RVA 0x6AF6E4)
// prototype: __int64 __fastcall(_QWORD)
// callees: 0x1806AF6E4, 0x1806BC340

void __fastcall _std_exception_destroy(__int64 a1)
{
  if ( *(_BYTE *)(a1 + 8) )
    free(*(void **)a1);
  *(_QWORD *)a1 = 0;
  *(_BYTE *)(a1 + 8) = 0;
}

