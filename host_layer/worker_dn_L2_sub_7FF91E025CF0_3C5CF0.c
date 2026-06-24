// sub_7FF91E025CF0 @ rva 0x3C5CF0

void __fastcall sub_7FF91E025CF0(__int64 *a1)
{
  __int64 v1; // rbx
  char *v2; // rcx

  v1 = *a1;
  if ( *a1 && _InterlockedExchangeAdd((volatile signed __int32 *)(v1 + 24), 0xFFFFFFFF) == 1 && v1 )
  {
    v2 = *(char **)(v1 + 8);
    if ( (unsigned __int64)(v2 - 1) <= 0xFFFFFFFFFFFFFFFDuLL )
      CloseHandle(v2);
    if ( (unsigned __int64)(*(_QWORD *)v1 - 1LL) <= 0xFFFFFFFFFFFFFFFDuLL )
      CloseHandle(*(HANDLE *)v1);
    j_j_free((void *)v1);
  }
}

