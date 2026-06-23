// _malloc_base  @ 0x180712F74  (RVA 0x712F74)
// prototype: void *__cdecl(size_t Size)
// callees: 0x1806EC87C, 0x18070C39C, 0x180712F74, 0x1807227A8
// constants/globals referenced:
//   0x180CB7A70 [.data] hHeap  u32=4294967295  f32=nan  f64=nan
//   0x1809347D8 [.idata] __imp_HeapAlloc  u32=4294967295  f32=nan  f64=nan

void *__cdecl malloc_base(size_t Size)
{
  size_t v1; // rbx
  void *result; // rax

  v1 = Size;
  if ( Size > 0xFFFFFFFFFFFFFFE0uLL )
  {
LABEL_9:
    *errno() = 12;
    return nullptr;
  }
  else
  {
    if ( !Size )
      v1 = 1;
    while ( 1 )
    {
      result = HeapAlloc(hHeap, 0, v1);
      if ( result )
        break;
      if ( !(unsigned int)sub_1807227A8() || !callnewh(v1) )
        goto LABEL_9;
    }
  }
  return result;
}

