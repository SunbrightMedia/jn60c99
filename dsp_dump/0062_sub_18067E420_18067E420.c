// sub_18067E420  @ 0x18067E420  (RVA 0x67E420)
// prototype: 
// callees: 0x18067E420
// constants/globals referenced:
//   0x180C94F20 [.data] dwTlsIndex  u32=4294967295  f32=nan  f64=8.4901051596516e-311
//   0x180934768 [.idata] __imp_TlsGetValue  u32=4294967295  f32=nan  f64=nan

LPVOID sub_18067E420()
{
  if ( dwTlsIndex == -1 )
    return nullptr;
  else
    return TlsGetValue(dwTlsIndex);
}

