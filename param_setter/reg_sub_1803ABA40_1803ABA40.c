// sub_1803ABA40 @ 0x1803ABA40 (RVA 0x3ABA40)

__int64 __fastcall sub_1803ABA40(__int64 a1, __int64 a2)
{
  __int64 v3; // rdx
  __int64 result; // rax

  v3 = *(_QWORD *)(a1 + 8);
  if ( *(_QWORD *)(a1 + 16) == v3 )
    return sub_180387CB0(a1, v3, a2);
  *(_OWORD *)v3 = *(_OWORD *)a2;
  *(_OWORD *)(v3 + 16) = *(_OWORD *)(a2 + 16);
  *(_QWORD *)(v3 + 32) = *(_QWORD *)(a2 + 32);
  *(_QWORD *)(a1 + 8) += 40LL;
  return result;
}

