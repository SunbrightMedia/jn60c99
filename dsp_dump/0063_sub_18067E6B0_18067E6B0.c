// sub_18067E6B0  @ 0x18067E6B0  (RVA 0x67E6B0)
// prototype: __int64 __fastcall(_QWORD, _QWORD)
// callees: 0x180675D20, 0x18067BD00, 0x18067E420, 0x18067E6B0, 0x18067FA40, 0x1806AE028
// constants/globals referenced:
//   0x180C94EF8 [.data] __security_cookie  u32=769630770  f32=2.5424194000089884e-11  f64=2.3683975271087e-310
//   0x180C94F20 [.data] dwTlsIndex  u32=4294967295  f32=nan  f64=8.4901051596516e-311
//   0x180934768 [.idata] __imp_TlsGetValue  u32=4294967295  f32=nan  f64=nan
//   0x1809346B8 [.idata] __imp_CreateWaitableTimerA  u32=4294967295  f32=nan  f64=nan
//   0xFF0000000002DE99 [?]   u32=4294967295  f32=nan  f64=nan
//   0x180CB6980 [.data] qword_180CB6980  u32=4294967295  f32=nan  f64=nan
//   0x180A87B30 [.rdata] aKernel32Dll_4  u32=1314014539  f32=881939136.0  f64=7.158001001640079e-67
//   0x180934918 [.idata] __imp_GetModuleHandleA  u32=4294967295  f32=nan  f64=nan
//   0x180A87B18 [.rdata] aSetwaitabletim  u32=1467245907  f32=268716021383168.0  f64=2.869694243973313e+161
//   0x180934910 [.idata] __imp_GetProcAddress  u32=4294967295  f32=nan  f64=nan
//   0x18067C560 [.text] sub_18067C560  u32=807683271  f32=5.976059092027697e-10  f64=3.99048557e-315
//   0x180A87B70 [.rdata] qword_180A87B70  u32=0  f32=0.0  f64=1000000000.0
//   0x1809346D8 [.idata] __imp_WaitForMultipleObjectsEx  u32=4294967295  f32=nan  f64=nan
//   0x1809347D0 [.idata] __imp_CloseHandle  u32=4294967295  f32=nan  f64=nan
//   0x180934840 [.idata] __imp_Sleep  u32=4294967295  f32=nan  f64=nan
//   0x1809343F8 [.idata] __imp_QueryPerformanceFrequency  u32=4294967295  f32=nan  f64=nan
//   0x180934480 [.idata] __imp_QueryPerformanceCounter  u32=4294967295  f32=nan  f64=nan
//   0x180934418 [.idata] __imp_ResetEvent  u32=4294967295  f32=nan  f64=nan
//   0x180C3CE68 [.rdata] __TI1?AVthread_interrupted@boost@@  u32=0  f32=0.0  f64=0.0

// Hidden C++ exception states: #wind=2
char __fastcall sub_18067E6B0(char *a1, _QWORD *a2)
{
  char *v3; // rax
  int v4; // r12d
  int v5; // r15d
  int v6; // r13d
  BOOL v7; // ebx
  DWORD v8; // ebp
  DWORD v9; // ecx
  _BYTE *Value; // rax
  _QWORD *v11; // rax
  char *WaitableTimerA; // rbx
  __int64 v13; // rcx
  __int64 v14; // rcx
  __int64 v15; // rdi
  __int64 v16; // rsi
  FARPROC ProcAddress; // rax
  HMODULE ModuleHandleA; // rax
  __int64 v19; // rdi
  __int64 v20; // rcx
  __int64 v21; // rcx
  DWORD v22; // eax
  DWORD v23; // ecx
  __int64 v24; // rax
  int v25; // edi
  __int64 v26; // rcx
  __int64 v27; // rcx
  LPVOID v29; // rax
  void *v30; // rax
  char pExceptionObject; // [rsp+40h] [rbp-88h] BYREF
  LARGE_INTEGER PerformanceCount; // [rsp+48h] [rbp-80h] BYREF
  LARGE_INTEGER Frequency; // [rsp+50h] [rbp-78h] BYREF
  char *v34; // [rsp+58h] [rbp-70h]
  __int64 v35; // [rsp+60h] [rbp-68h]
  HANDLE Handles[4]; // [rsp+68h] [rbp-60h] BYREF

  v35 = -2;
  v3 = nullptr;
  memset(&Handles[1], 0, 24);
  v4 = -1;
  v5 = -1;
  if ( a1 != (char *)-1LL )
    v3 = a1;
  Handles[0] = v3;
  v6 = 0;
  if ( a1 == (char *)-1LL )
    v6 = -1;
  v7 = a1 + 1 != nullptr;
  if ( dwTlsIndex == -1 )
  {
    v8 = a1 + 1 != nullptr;
  }
  else
  {
    v8 = a1 + 1 != nullptr;
    if ( TlsGetValue(dwTlsIndex) )
    {
      v9 = dwTlsIndex;
      if ( dwTlsIndex == -1 )
      {
        Value = nullptr;
      }
      else
      {
        Value = TlsGetValue(dwTlsIndex);
        v9 = dwTlsIndex;
      }
      if ( Value[112] )
      {
        v4 = v7;
        if ( v9 == -1 )
          v11 = nullptr;
        else
          v11 = TlsGetValue(v9);
        Handles[v7] = (HANDLE)v11[13];
        v8 = v7 + 1;
      }
    }
  }
  WaitableTimerA = nullptr;
  v34 = nullptr;
  if ( *a2 != 0x7FFFFFFFFFFFFFFFLL )
  {
    v13 = *a2 - *(_QWORD *)sub_18067FA40(&Frequency);
    v14 = v13 < 0 ? v13 - 999999 : v13 + 999999;
    v15 = v14 / 1000000;
    WaitableTimerA = (char *)CreateWaitableTimerA(nullptr, 0, nullptr);
    v34 = WaitableTimerA;
    if ( WaitableTimerA )
    {
      LODWORD(v16) = 32;
      if ( v15 >= 660 )
        v16 = v15 / 20;
      PerformanceCount.QuadPart = 0;
      if ( v15 > 0 )
        PerformanceCount.QuadPart = -10000 * v15;
      ProcAddress = (FARPROC)qword_180CB6980;
      if ( !qword_180CB6980 )
      {
        ModuleHandleA = GetModuleHandleA("KERNEL32.DLL");
        ProcAddress = GetProcAddress(ModuleHandleA, "SetWaitableTimerEx");
        if ( !ProcAddress )
          ProcAddress = (FARPROC)sub_18067C560;
        qword_180CB6980 = (__int64)ProcAddress;
      }
      if ( ((unsigned int (__fastcall *)(char *, LARGE_INTEGER *, _QWORD, _QWORD, _QWORD, _QWORD, _DWORD))ProcAddress)(
             WaitableTimerA,
             &PerformanceCount,
             0,
             0,
             0,
             0,
             v16) )
      {
        v5 = v8;
        Handles[v8++] = WaitableTimerA;
      }
    }
  }
  v19 = 0xFFFFFFFFLL;
  if ( v5 == -1 && *a2 != 0x7FFFFFFFFFFFFFFFLL )
  {
    v20 = *a2 - *(_QWORD *)sub_18067FA40(&Frequency);
    v21 = v20 < 0 ? v20 - 999999 : v20 + 999999;
    v19 = v21 / 1000000;
    if ( v21 / 1000000 < 0 )
      v19 = 0;
  }
  while ( 1 )
  {
    if ( !v8 )
    {
      if ( (_DWORD)v19 )
        v23 = v19;
      else
        v23 = 0;
      Sleep(v23);
      goto LABEL_50;
    }
    v22 = WaitForMultipleObjectsEx(v8, Handles, 0, v19, 0);
    if ( v22 >= v8 )
      goto LABEL_50;
    if ( v22 == v6 )
      break;
    if ( v22 == v4 )
    {
      v29 = sub_18067E420();
      v30 = (void *)sub_18067BD00((__int64)v29 + 104);
      ResetEvent(v30);
      throw (boost::thread_interrupted *)&pExceptionObject;
    }
    if ( v22 == v5 )
    {
      if ( (unsigned __int64)(WaitableTimerA - 1) <= 0xFFFFFFFFFFFFFFFDuLL )
        CloseHandle(WaitableTimerA);
      return 0;
    }
LABEL_50:
    if ( v5 == -1 && *a2 != 0x7FFFFFFFFFFFFFFFLL )
    {
      if ( !QueryPerformanceFrequency(&Frequency) )
        goto LABEL_53;
      if ( Frequency.QuadPart > 0 )
      {
        v25 = 0;
        if ( QueryPerformanceCounter(&PerformanceCount) )
        {
LABEL_59:
          v24 = (unsigned int)(int)((double)(int)PerformanceCount.LowPart * 1000000000.0 / (double)(int)Frequency.LowPart);
        }
        else
        {
          while ( (unsigned int)++v25 <= 3 )
          {
            if ( QueryPerformanceCounter(&PerformanceCount) )
              goto LABEL_59;
          }
LABEL_53:
          v24 = 0;
        }
      }
      else
      {
        v24 = 0;
      }
      v26 = *a2 - v24;
      if ( v26 < 0 )
        v27 = v26 - 999999;
      else
        v27 = v26 + 999999;
      v19 = v27 / 1000000;
    }
    if ( v19 <= 0 )
    {
      if ( (unsigned __int64)(WaitableTimerA - 1) <= 0xFFFFFFFFFFFFFFFDuLL )
        CloseHandle(WaitableTimerA);
      return 0;
    }
  }
  if ( (unsigned __int64)(WaitableTimerA - 1) <= 0xFFFFFFFFFFFFFFFDuLL )
    CloseHandle(WaitableTimerA);
  return 1;
}

