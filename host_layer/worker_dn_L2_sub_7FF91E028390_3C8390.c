// sub_7FF91E028390 @ rva 0x3C8390

// Hidden C++ exception states: #wind=2
void __fastcall sub_7FF91E028390(__int64 a1)
{
  volatile signed __int32 *v2; // rcx
  _QWORD *v3; // rax
  _QWORD *v4; // rcx
  _QWORD v5[10]; // [rsp+30h] [rbp-68h] BYREF

  v2 = *(volatile signed __int32 **)a1;
  if ( !v2 )
  {
    v4 = sub_7FF91E025BC0(v5);
    sub_7FF91E0256C0((__int64)v4);
  }
  if ( *(_BYTE *)(a1 + 8) )
  {
    v3 = sub_7FF91E025BC0(v5);
    sub_7FF91E0256C0((__int64)v3);
  }
  sub_7FF91DFAB2A0(v2);
  *(_BYTE *)(a1 + 8) = 1;
}

