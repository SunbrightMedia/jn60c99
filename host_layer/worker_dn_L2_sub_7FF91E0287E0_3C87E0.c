// sub_7FF91E0287E0 @ rva 0x3C87E0

// Hidden C++ exception states: #wind=2
signed __int32 __fastcall sub_7FF91E0287E0(__int64 a1)
{
  volatile signed __int32 *v2; // rcx
  signed __int32 result; // eax
  HANDLE v4; // rax
  _QWORD *v5; // rax
  _QWORD *v6; // rcx
  _QWORD v7[10]; // [rsp+30h] [rbp-B8h] BYREF
  _QWORD v8[10]; // [rsp+80h] [rbp-68h] BYREF

  v2 = *(volatile signed __int32 **)a1;
  if ( !v2 )
  {
    v6 = sub_7FF91E025BC0(v7);
    sub_7FF91E0256C0((__int64)v6);
  }
  if ( !*(_BYTE *)(a1 + 8) )
  {
    v5 = sub_7FF91E025BC0(v8);
    sub_7FF91E0256C0((__int64)v5);
  }
  result = _InterlockedExchangeAdd(v2, 0x80000000);
  if ( (result & 0x40000000) == 0 && result != 0x80000000 && !_interlockedbittestandset(v2, 0x1Eu) )
  {
    v4 = sub_7FF91DF66830((__int64)v2);
    result = SetEvent(v4);
  }
  *(_BYTE *)(a1 + 8) = 0;
  return result;
}

