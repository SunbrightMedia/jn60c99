// wcsncmp  @ 0x18070EF14  (RVA 0x70EF14)
// prototype: int __cdecl(const wchar_t *String1, const wchar_t *String2, size_t MaxCount)
// callees: 0x18070EF14

int __cdecl wcsncmp(const wchar_t *String1, const wchar_t *String2, size_t MaxCount)
{
  if ( !MaxCount )
    return 0;
  while ( --MaxCount && *String1 && *String1 == *String2 )
  {
    ++String1;
    ++String2;
  }
  return *String1 - *String2;
}

