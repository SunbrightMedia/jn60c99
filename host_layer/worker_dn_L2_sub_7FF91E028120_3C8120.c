// sub_7FF91E028120 @ rva 0x3C8120

// Hidden C++ exception states: #wind=9
_QWORD *__fastcall sub_7FF91E028120(__int64 a1, _QWORD *a2)
{
  HANDLE SemaphoreA; // rbx
  char *v5; // rcx
  __int64 v6; // rax
  __int64 v7; // rax
  __int64 v8; // rcx
  signed __int32 v9; // eax
  HANDLE v10; // rax
  void *v11; // rsi
  HANDLE v12; // rax
  void *v13; // rbx
  HANDLE CurrentProcess; // rax
  _QWORD *v15; // rdx
  signed __int32 v16; // eax
  HANDLE v17; // rax
  __int64 v19; // rcx
  __int64 v20; // rcx
  __int64 v21; // rcx
  _QWORD *v22; // [rsp+40h] [rbp-138h] BYREF
  HANDLE TargetHandle[3]; // [rsp+48h] [rbp-130h] BYREF
  _BYTE v24[80]; // [rsp+60h] [rbp-118h] BYREF
  _BYTE v25[80]; // [rsp+B0h] [rbp-C8h] BYREF
  _BYTE v26[80]; // [rsp+100h] [rbp-78h] BYREF

  TargetHandle[1] = (HANDLE)-2LL;
  v22 = a2;
  TargetHandle[2] = (HANDLE)a1;
  sub_7FF91DFAB2A0((volatile signed __int32 *)a1);
  if ( !*(_QWORD *)(a1 + 48) )
  {
    SemaphoreA = CreateSemaphoreA(nullptr, 0, 0x7FFFFFFF, nullptr);
    if ( !SemaphoreA )
    {
      v20 = sub_7FF91DF5B610(v24);
      sub_7FF91DF58C90(v20);
    }
    v5 = *(char **)(a1 + 48);
    if ( (unsigned __int64)(v5 - 1) <= 0xFFFFFFFFFFFFFFFDuLL )
      CloseHandle(v5);
    *(_QWORD *)(a1 + 48) = SemaphoreA;
  }
  ++*(_DWORD *)(a1 + 16);
  v6 = *(_QWORD *)(a1 + 32);
  if ( *(_QWORD *)(a1 + 24) == v6 || (v7 = *(_QWORD *)(v6 - 8), *(_BYTE *)(v7 + 20)) )
  {
    v11 = operator new(0x20u);
    v22 = v11;
    if ( v11 )
    {
      v12 = CreateSemaphoreA(nullptr, 0, 0x7FFFFFFF, nullptr);
      if ( !v12 )
      {
        v21 = sub_7FF91DF5B610(v25);
        sub_7FF91DF58C90(v21);
      }
      *(_QWORD *)v11 = v12;
      v13 = *(void **)(a1 + 48);
      CurrentProcess = GetCurrentProcess();
      TargetHandle[0] = nullptr;
      if ( !DuplicateHandle(CurrentProcess, v13, CurrentProcess, TargetHandle, 0, 0, 2u) )
      {
        v19 = sub_7FF91DF5B610(v26);
        sub_7FF91DF58C90(v19);
      }
      *((HANDLE *)v11 + 1) = TargetHandle[0];
      *((_DWORD *)v11 + 4) = 1;
      *((_BYTE *)v11 + 20) = 0;
      *((_DWORD *)v11 + 6) = 0;
    }
    else
    {
      v11 = nullptr;
    }
    v22 = v11;
    if ( v11 )
      _InterlockedIncrement((volatile signed __int32 *)v11 + 6);
    v15 = *(_QWORD **)(a1 + 32);
    if ( *(_QWORD **)(a1 + 40) == v15 )
    {
      sub_7FF91E025070(a1 + 24, v15, &v22);
    }
    else
    {
      *v15 = v11;
      if ( v11 )
        _InterlockedIncrement((volatile signed __int32 *)v11 + 6);
      *(_QWORD *)(a1 + 32) += 8LL;
    }
    *a2 = v22;
    v16 = _InterlockedExchangeAdd((volatile signed __int32 *)a1, 0x80000000);
    if ( (v16 & 0x40000000) == 0
      && v16 != 0x80000000
      && !_interlockedbittestandset((volatile signed __int32 *)a1, 0x1Eu) )
    {
      v17 = sub_7FF91DF66830(a1);
      SetEvent(v17);
    }
  }
  else
  {
    _InterlockedIncrement((volatile signed __int32 *)(v7 + 16));
    v8 = *(_QWORD *)(*(_QWORD *)(a1 + 32) - 8LL);
    *a2 = v8;
    if ( v8 )
      _InterlockedIncrement((volatile signed __int32 *)(v8 + 24));
    v9 = _InterlockedExchangeAdd((volatile signed __int32 *)a1, 0x80000000);
    if ( (v9 & 0x40000000) == 0 && v9 != 0x80000000 && !_interlockedbittestandset((volatile signed __int32 *)a1, 0x1Eu) )
    {
      v10 = sub_7FF91DF66830(a1);
      SetEvent(v10);
    }
  }
  return a2;
}

