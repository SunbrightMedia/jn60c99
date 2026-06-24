// sub_7FF91E028440 @ rva 0x3C8440

// Hidden C++ exception states: #wind=1
signed __int32 __fastcall sub_7FF91E028440(__int64 a1)
{
  signed __int32 result; // eax
  int v3; // eax
  void *v4; // rax
  __int64 *v5; // rsi
  __int64 *v6; // rbx
  __int64 v7; // rax
  __int64 *i; // rdi
  __int64 *j; // r14
  __int64 v10; // rax
  __int64 v11; // rbx
  char *v12; // rcx
  __int64 *v13; // r14
  __int64 v14; // rax
  __int64 v15; // rbx
  char *v16; // rcx
  __int64 *k; // rbx
  void *v18; // rax

  result = *(_DWORD *)(a1 + 16);
  if ( result )
  {
    sub_7FF91DFAB2A0(a1);
    v3 = *(_DWORD *)(a1 + 16);
    if ( v3 )
    {
      *(_DWORD *)(a1 + 16) = v3 - 1;
      ReleaseSemaphore(*(HANDLE *)(a1 + 48), 1, nullptr);
      v5 = *(__int64 **)(a1 + 32);
      v6 = *(__int64 **)(a1 + 24);
      if ( v6 != v5 )
      {
        do
        {
          v7 = *v6;
          *(_BYTE *)(v7 + 20) = 1;
          ReleaseSemaphore(*(HANDLE *)v7, 1, nullptr);
          ++v6;
        }
        while ( v6 != v5 );
        v5 = *(__int64 **)(a1 + 32);
      }
      for ( i = *(__int64 **)(a1 + 24); i != v5; ++i )
      {
        if ( !*(_DWORD *)(*i + 16) )
          break;
      }
      if ( i != v5 )
      {
        for ( j = i + 1; j != v5; ++j )
        {
          if ( *(_DWORD *)(*j + 16) )
          {
            v10 = *j;
            *j = 0;
            v11 = *i;
            *i = v10;
            if ( v11 && _InterlockedExchangeAdd((volatile signed __int32 *)(v11 + 24), 0xFFFFFFFF) == 1 )
            {
              v12 = *(char **)(v11 + 8);
              if ( (unsigned __int64)(v12 - 1) <= 0xFFFFFFFFFFFFFFFDuLL )
                CloseHandle(v12);
              if ( (unsigned __int64)(*(_QWORD *)v11 - 1LL) <= 0xFFFFFFFFFFFFFFFDuLL )
                CloseHandle(*(HANDLE *)v11);
              j_j_free((void *)v11);
            }
            ++i;
          }
        }
        if ( i != v5 )
        {
          v13 = *(__int64 **)(a1 + 32);
          if ( v5 != v13 )
          {
            do
            {
              v14 = *v5;
              *v5 = 0;
              v15 = *i;
              *i = v14;
              if ( v15 && _InterlockedExchangeAdd((volatile signed __int32 *)(v15 + 24), 0xFFFFFFFF) == 1 )
              {
                v16 = *(char **)(v15 + 8);
                if ( (unsigned __int64)(v16 - 1) <= 0xFFFFFFFFFFFFFFFDuLL )
                  CloseHandle(v16);
                if ( (unsigned __int64)(*(_QWORD *)v15 - 1LL) <= 0xFFFFFFFFFFFFFFFDuLL )
                  CloseHandle(*(HANDLE *)v15);
                j_j_free((void *)v15);
              }
              ++i;
              ++v5;
            }
            while ( v5 != v13 );
            v13 = *(__int64 **)(a1 + 32);
          }
          for ( k = i; k != v13; ++k )
            sub_7FF91E025CF0(k);
          *(_QWORD *)(a1 + 32) = i;
        }
      }
      result = _InterlockedExchangeAdd((volatile signed __int32 *)a1, 0x80000000);
      if ( (result & 0x40000000) == 0
        && result != 0x80000000
        && !_interlockedbittestandset((volatile signed __int32 *)a1, 0x1Eu) )
      {
        v18 = (void *)sub_7FF91DF66830(a1);
        return SetEvent(v18);
      }
    }
    else
    {
      result = _InterlockedExchangeAdd((volatile signed __int32 *)a1, 0x80000000);
      if ( (result & 0x40000000) == 0
        && result != 0x80000000
        && !_interlockedbittestandset((volatile signed __int32 *)a1, 0x1Eu) )
      {
        v4 = (void *)sub_7FF91DF66830(a1);
        return SetEvent(v4);
      }
    }
  }
  return result;
}

