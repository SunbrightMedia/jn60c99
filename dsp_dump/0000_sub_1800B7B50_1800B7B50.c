// sub_1800B7B50  @ 0x1800B7B50  (RVA 0xB7B50)
// prototype: 
// callees: 0x1800B7FF0

__int64 __fastcall sub_1800B7B50(__int64 a1, __int64 a2)
{
  *(_QWORD *)(a1 + 24) = 15;
  *(_QWORD *)(a1 + 16) = 0;
  *(_BYTE *)a1 = 0;
  sub_1800B7FF0(a1, a2, 0, -1);
  return a1;
}

