// ??2@YAPEAX_K@Z  @ 0x18067522C  (RVA 0x67522C)
// prototype: void *__fastcall(size_t Size)
// callees: 0x18067522C, 0x180676B5C, 0x180676B7C, 0x1806EBEE4, 0x18070C39C

void *__fastcall operator new(size_t Size)
{
  size_t i; // rbx
  void *result; // rax

  for ( i = Size; ; Size = i )
  {
    result = j__malloc_base(Size);
    if ( result )
      break;
    if ( !callnewh(i) )
    {
      if ( i != -1 )
        Concurrency::cancel_current_task();
      Concurrency::cancel_current_task();
    }
  }
  return result;
}

