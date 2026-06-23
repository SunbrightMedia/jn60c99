// _callnewh  @ 0x18070C39C  (RVA 0x70C39C)
// prototype: int __cdecl(size_t Size)
// callees: 0x18070C39C, 0x18070C3CC, 0x1808DDDD0
// constants/globals referenced:
//   0x180935658 [.rdata] __guard_dispatch_icall_fptr  u32=2156781008  f32=-1.302837629027498e-38  f64=3.1875871926e-314

int __cdecl callnewh(size_t Size)
{
  _PNH new_handler; // rax

  new_handler = query_new_handler();
  return new_handler && ((unsigned int (__fastcall *)(size_t))new_handler)(Size);
}

