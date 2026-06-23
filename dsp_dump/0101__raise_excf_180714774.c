// _raise_excf  @ 0x180714774  (RVA 0x714774)
// prototype: 
// callees: 0x180714464

__int64 __fastcall raise_excf(ULONG_PTR a1, _QWORD *a2, char a3, __int16 a4, _DWORD *a5, _DWORD *a6)
{
  return raise_exc_ex(a1, a2, a3, a4, a5, a6, 1);
}

