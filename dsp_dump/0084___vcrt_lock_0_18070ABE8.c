// __vcrt_lock_0  @ 0x18070ABE8  (RVA 0x70ABE8)
// prototype: 
// callees: 
// constants/globals referenced:
//   0x180CB6E40 [.data] unk_180CB6E40  u32=4294967295  f32=nan  f64=nan
//   0x180934920 [.idata] __imp_EnterCriticalSection  u32=4294967295  f32=nan  f64=nan

void __fastcall _vcrt_lock_0(int a1)
{
  EnterCriticalSection((LPCRITICAL_SECTION)&unk_180CB6E40 + a1);
}

