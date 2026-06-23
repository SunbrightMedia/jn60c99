// __vcrt_unlock_0  @ 0x18070AC3C  (RVA 0x70AC3C)
// prototype: 
// callees: 
// constants/globals referenced:
//   0x180CB6E40 [.data] unk_180CB6E40  u32=4294967295  f32=nan  f64=nan
//   0x180934928 [.idata] __imp_LeaveCriticalSection  u32=4294967295  f32=nan  f64=nan

void __fastcall _vcrt_unlock_0(int a1)
{
  LeaveCriticalSection((LPCRITICAL_SECTION)&unk_180CB6E40 + a1);
}

