// sub_7FF91DF66830 @ rva 0x306830

// Hidden C++ exception states: #wind=1
HANDLE __fastcall sub_7FF91DF66830(__int64 a1)
{
  HANDLE result; // rax
  signed __int64 v3; // rbx
  __int64 v4; // rcx
  _BYTE v5[80]; // [rsp+30h] [rbp-68h] BYREF

  result = *(HANDLE *)(a1 + 8);
  if ( !result )
  {
    result = CreateEventA(nullptr, 0, 0, nullptr);
    if ( !result )
    {
      v4 = sub_7FF91DF5B610(v5);
      sub_7FF91DF58C90(v4);
    }
    v3 = _InterlockedCompareExchange64((volatile signed __int64 *)(a1 + 8), (signed __int64)result, 0);
    if ( v3 )
    {
      CloseHandle(result);
      return (HANDLE)v3;
    }
  }
  return result;
}

