// _free_base  @ 0x18070FB50  (RVA 0x70FB50)
// prototype: void __cdecl(void *Block)
// callees: 0x1806EC7C4, 0x1806EC87C, 0x18070FB50
// constants/globals referenced:
//   0x180CB7A70 [.data] hHeap  u32=4294967295  f32=nan  f64=nan
//   0x1809347E0 [.idata] __imp_HeapFree  u32=4294967295  f32=nan  f64=nan
//   0x1809347B8 [.idata] __imp_GetLastError  u32=4294967295  f32=nan  f64=nan

void __cdecl free_base(void *Block)
{
  int *v1; // rbx
  DWORD LastError; // eax

  if ( Block )
  {
    if ( !HeapFree(hHeap, 0, Block) )
    {
      v1 = errno();
      LastError = GetLastError();
      *v1 = _acrt_errno_from_os_error(LastError);
    }
  }
}

