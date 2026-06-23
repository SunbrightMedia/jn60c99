// sub_180303FD0  @ 0x180303FD0  (RVA 0x303FD0)
// prototype: __int64 __fastcall(_QWORD, _QWORD)
// callees: 0x180303FD0

// Hidden C++ exception states: #wind=4
__int64 __fastcall sub_180303FD0(__int64 a1, __int64 a2)
{
  __int64 v4; // rbx
  __int64 v5; // rcx
  __int64 result; // rax
  __int64 v7; // rcx
  __int64 v8; // [rsp+48h] [rbp+10h] BYREF

  v4 = 0;
  v5 = *(_QWORD *)(a2 + 8);
  if ( v5 )
  {
    v4 = *(_QWORD *)(*(__int64 (__fastcall **)(__int64, __int64 *))(*(_QWORD *)v5 + 40LL))(v5, &v8);
    if ( v4 )
      (*(void (__fastcall **)(__int64))(*(_QWORD *)v4 + 24LL))(v4);
    if ( v8 )
      (*(void (__fastcall **)(__int64))(*(_QWORD *)v8 + 32LL))(v8);
  }
  *(_QWORD *)(a1 + 24) = *(_QWORD *)(a2 + 24);
  *(_DWORD *)(a1 + 32) = *(_DWORD *)(a2 + 32);
  result = *(_QWORD *)(a2 + 16);
  *(_QWORD *)(a1 + 16) = result;
  v7 = *(_QWORD *)(a1 + 8);
  if ( v7 )
    result = (*(__int64 (__fastcall **)(__int64))(*(_QWORD *)v7 + 32LL))(v7);
  *(_QWORD *)(a1 + 8) = v4;
  if ( v4 )
  {
    (*(void (__fastcall **)(__int64))(*(_QWORD *)v4 + 24LL))(v4);
    return (*(__int64 (__fastcall **)(__int64))(*(_QWORD *)v4 + 32LL))(v4);
  }
  return result;
}

