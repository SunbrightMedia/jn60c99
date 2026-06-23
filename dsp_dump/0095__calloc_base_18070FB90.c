// _calloc_base  @ 0x18070FB90  (RVA 0x70FB90)
// prototype: void *__cdecl(size_t Count, size_t Size)
// callees: 0x1806EC87C, 0x18070C39C, 0x18070FB90, 0x1807227A8
// constants/globals referenced:
//   0x180CB7A70 [.data] hHeap  u32=4294967295  f32=nan  f64=nan
//   0x1809347D8 [.idata] __imp_HeapAlloc  u32=4294967295  f32=nan  f64=nan

void *__cdecl calloc_base(size_t Count, size_t Size)
{
  SIZE_T v2; // rbx
  void *result; // rax

  if ( Count && 0xFFFFFFFFFFFFFFE0uLL / Count < Size )
  {
LABEL_10:
    *errno() = 12;
    return nullptr;
  }
  else
  {
    v2 = Size * Count;
    if ( !(Size * Count) )
      v2 = 1;
    while ( 1 )
    {
      result = HeapAlloc(hHeap, 8u, v2);
      if ( result )
        break;
      if ( !(unsigned int)sub_1807227A8() || !callnewh(v2) )
        goto LABEL_10;
    }
  }
  return result;
}

