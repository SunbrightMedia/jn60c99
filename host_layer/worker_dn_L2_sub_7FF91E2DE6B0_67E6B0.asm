; sub_7FF91E2DE6B0 @ rva 0x67E6B0

00007FF91E2DE6B0  4C 8B DC                    mov     r11, rsp
00007FF91E2DE6B3  57                          push    rdi
00007FF91E2DE6B4  41 54                       push    r12
00007FF91E2DE6B6  41 55                       push    r13
00007FF91E2DE6B8  41 56                       push    r14
00007FF91E2DE6BA  41 57                       push    r15
00007FF91E2DE6BC  48 81 EC A0 00 00 00        sub     rsp, 0A0h
00007FF91E2DE6C3  49 C7 43 98 FE FF FF FF     mov     qword ptr [r11-68h], 0FFFFFFFFFFFFFFFEh
00007FF91E2DE6CB  49 89 5B 08                 mov     [r11+8], rbx
00007FF91E2DE6CF  49 89 6B 10                 mov     [r11+10h], rbp
00007FF91E2DE6D3  49 89 73 18                 mov     [r11+18h], rsi
00007FF91E2DE6D7  41 0F 29 73 C8              movaps  xmmword ptr [r11-38h], xmm6
00007FF91E2DE6DC  48 8B 05 15 68 61 00        mov     rax, cs:__security_cookie
00007FF91E2DE6E3  48 33 C4                    xor     rax, rsp
00007FF91E2DE6E6  48 89 84 24 88 00 00 00     mov     [rsp+0C8h+var_40], rax
00007FF91E2DE6EE  4C 8B F2                    mov     r14, rdx
00007FF91E2DE6F1  33 C0                       xor     eax, eax
00007FF91E2DE6F3  49 89 43 A8                 mov     [r11-58h], rax
00007FF91E2DE6F7  49 89 43 B0                 mov     [r11-50h], rax
00007FF91E2DE6FB  49 89 43 B8                 mov     [r11-48h], rax
00007FF91E2DE6FF  BA FF FF FF FF              mov     edx, 0FFFFFFFFh
00007FF91E2DE704  44 8B E2                    mov     r12d, edx
00007FF91E2DE707  44 8B FA                    mov     r15d, edx
00007FF91E2DE70A  48 83 F9 FF                 cmp     rcx, 0FFFFFFFFFFFFFFFFh
00007FF91E2DE70E  48 0F 45 C1                 cmovnz  rax, rcx
00007FF91E2DE712  49 89 43 A0                 mov     [r11-60h], rax
00007FF91E2DE716  33 F6                       xor     esi, esi
00007FF91E2DE718  44 8B EE                    mov     r13d, esi
00007FF91E2DE71B  48 83 F9 FF                 cmp     rcx, 0FFFFFFFFFFFFFFFFh
00007FF91E2DE71F  44 0F 44 EA                 cmovz   r13d, edx
00007FF91E2DE723  8B DE                       mov     ebx, esi
00007FF91E2DE725  0F 95 C3                    setnz   bl
00007FF91E2DE728  8B 0D F2 67 61 00           mov     ecx, cs:dwTlsIndex; dwTlsIndex
00007FF91E2DE72E  3B CA                       cmp     ecx, edx
00007FF91E2DE730  75 04                       jnz     short loc_7FF91E2DE736
00007FF91E2DE732  8B EB                       mov     ebp, ebx
00007FF91E2DE734  EB 55                       jmp     short loc_7FF91E2DE78B
00007FF91E2DE736  FF 15 2C 60 2B 00           call    cs:__imp_TlsGetValue
00007FF91E2DE73C  8B EB                       mov     ebp, ebx
00007FF91E2DE73E  48 85 C0                    test    rax, rax
00007FF91E2DE741  74 48                       jz      short loc_7FF91E2DE78B
00007FF91E2DE743  8B 0D D7 67 61 00           mov     ecx, cs:dwTlsIndex; dwTlsIndex
00007FF91E2DE749  49 8B D4                    mov     rdx, r12
00007FF91E2DE74C  41 3B CC                    cmp     ecx, r12d
00007FF91E2DE74F  75 05                       jnz     short loc_7FF91E2DE756
00007FF91E2DE751  48 8B C6                    mov     rax, rsi
00007FF91E2DE754  EB 0F                       jmp     short loc_7FF91E2DE765
00007FF91E2DE756  FF 15 0C 60 2B 00           call    cs:__imp_TlsGetValue
00007FF91E2DE75C  8B 0D BE 67 61 00           mov     ecx, cs:dwTlsIndex; dwTlsIndex
00007FF91E2DE762  49 8B D4                    mov     rdx, r12
00007FF91E2DE765  40 38 70 70                 cmp     [rax+70h], sil
00007FF91E2DE769  74 20                       jz      short loc_7FF91E2DE78B
00007FF91E2DE76B  44 8B E3                    mov     r12d, ebx
00007FF91E2DE76E  3B CA                       cmp     ecx, edx
00007FF91E2DE770  75 05                       jnz     short loc_7FF91E2DE777
00007FF91E2DE772  48 8B C6                    mov     rax, rsi
00007FF91E2DE775  EB 06                       jmp     short loc_7FF91E2DE77D
00007FF91E2DE777  FF 15 EB 5F 2B 00           call    cs:__imp_TlsGetValue
00007FF91E2DE77D  48 8B 48 68                 mov     rcx, [rax+68h]
00007FF91E2DE781  8B C3                       mov     eax, ebx
00007FF91E2DE783  48 89 4C C4 68              mov     [rsp+rax*8+0C8h+Handles], rcx
00007FF91E2DE788  8D 6B 01                    lea     ebp, [rbx+1]
00007FF91E2DE78B  48 8B DE                    mov     rbx, rsi
00007FF91E2DE78E  48 89 5C 24 58              mov     [rsp+0C8h+var_70], rbx
00007FF91E2DE793  48 B9 FF FF FF FF FF FF FF 7F  mov     rcx, 7FFFFFFFFFFFFFFFh
00007FF91E2DE79D  48 BF DB 34 B6 D7 82 DE 1B 43  mov     rdi, 431BDE82D7B634DBh
00007FF91E2DE7A7  49 39 0E                    cmp     [r14], rcx
00007FF91E2DE7AA  0F 84 1D 01 00 00           jz      loc_7FF91E2DE8CD
00007FF91E2DE7B0  48 8D 4C 24 50              lea     rcx, [rsp+0C8h+Frequency]
00007FF91E2DE7B5  E8 86 12 00 00              call    sub_7FF91E2DFA40
00007FF91E2DE7BA  49 8B 0E                    mov     rcx, [r14]
00007FF91E2DE7BD  48 2B 08                    sub     rcx, [rax]
00007FF91E2DE7C0  48 8B C7                    mov     rax, rdi
00007FF91E2DE7C3  78 09                       js      short loc_7FF91E2DE7CE
00007FF91E2DE7C5  48 81 C1 3F 42 0F 00        add     rcx, 0F423Fh
00007FF91E2DE7CC  EB 07                       jmp     short loc_7FF91E2DE7D5
00007FF91E2DE7CE  48 81 C1 C1 BD F0 FF        add     rcx, 0FFFFFFFFFFF0BDC1h
00007FF91E2DE7D5  48 F7 E9                    imul    rcx
00007FF91E2DE7D8  48 8B FA                    mov     rdi, rdx
00007FF91E2DE7DB  48 C1 FF 12                 sar     rdi, 12h
00007FF91E2DE7DF  48 8B C7                    mov     rax, rdi
00007FF91E2DE7E2  48 C1 E8 3F                 shr     rax, 3Fh
00007FF91E2DE7E6  48 03 F8                    add     rdi, rax
00007FF91E2DE7E9  45 33 C0                    xor     r8d, r8d; lpTimerName
00007FF91E2DE7EC  33 D2                       xor     edx, edx; bManualReset
00007FF91E2DE7EE  33 C9                       xor     ecx, ecx; lpTimerAttributes
00007FF91E2DE7F0  FF 15 C2 5E 2B 00           call    cs:__imp_CreateWaitableTimerA
00007FF91E2DE7F6  48 8B D8                    mov     rbx, rax
00007FF91E2DE7F9  48 89 44 24 58              mov     [rsp+0C8h+var_70], rax
00007FF91E2DE7FE  48 85 C0                    test    rax, rax
00007FF91E2DE801  0F 84 BC 00 00 00           jz      loc_7FF91E2DE8C3
00007FF91E2DE807  BE 20 00 00 00              mov     esi, 20h ; ' '
00007FF91E2DE80C  48 81 FF 94 02 00 00        cmp     rdi, 294h
00007FF91E2DE813  7C 1E                       jl      short loc_7FF91E2DE833
00007FF91E2DE815  48 B8 67 66 66 66 66 66 66 66  mov     rax, 6666666666666667h
00007FF91E2DE81F  48 F7 EF                    imul    rdi
00007FF91E2DE822  48 8B F2                    mov     rsi, rdx
00007FF91E2DE825  48 C1 FE 03                 sar     rsi, 3
00007FF91E2DE829  48 8B C6                    mov     rax, rsi
00007FF91E2DE82C  48 C1 E8 3F                 shr     rax, 3Fh
00007FF91E2DE830  48 03 F0                    add     rsi, rax
00007FF91E2DE833  33 C0                       xor     eax, eax
00007FF91E2DE835  48 89 44 24 48              mov     qword ptr [rsp+0C8h+PerformanceCount], rax
00007FF91E2DE83A  48 85 FF                    test    rdi, rdi
00007FF91E2DE83D  7E 0C                       jle     short loc_7FF91E2DE84B
00007FF91E2DE83F  48 69 C7 F0 D8 FF FF        imul    rax, rdi, 0FFFFFFFFFFFFD8F0h
00007FF91E2DE846  48 89 44 24 48              mov     qword ptr [rsp+0C8h+PerformanceCount], rax
00007FF91E2DE84B  48 8B 05 2E 81 63 00        mov     rax, cs:qword_7FF91E916980
00007FF91E2DE852  48 85 C0                    test    rax, rax
00007FF91E2DE855  75 30                       jnz     short loc_7FF91E2DE887
00007FF91E2DE857  48 8D 0D D2 92 40 00        lea     rcx, aKernel32Dll_4; "KERNEL32.DLL"
00007FF91E2DE85E  FF 15 B4 60 2B 00           call    cs:__imp_GetModuleHandleA
00007FF91E2DE864  48 8B C8                    mov     rcx, rax; hModule
00007FF91E2DE867  48 8D 15 AA 92 40 00        lea     rdx, aSetwaitabletim; "SetWaitableTimerEx"
00007FF91E2DE86E  FF 15 9C 60 2B 00           call    cs:__imp_GetProcAddress
00007FF91E2DE874  48 85 C0                    test    rax, rax
00007FF91E2DE877  75 07                       jnz     short loc_7FF91E2DE880
00007FF91E2DE879  48 8D 05 E0 DC FF FF        lea     rax, sub_7FF91E2DC560
00007FF91E2DE880  48 89 05 F9 80 63 00        mov     cs:qword_7FF91E916980, rax
00007FF91E2DE887  89 74 24 30                 mov     [rsp+0C8h+var_98], esi
00007FF91E2DE88B  33 F6                       xor     esi, esi
00007FF91E2DE88D  48 89 74 24 28              mov     [rsp+0C8h+var_A0], rsi
00007FF91E2DE892  48 89 74 24 20              mov     qword ptr [rsp+0C8h+bAlertable], rsi
00007FF91E2DE897  45 33 C9                    xor     r9d, r9d
00007FF91E2DE89A  45 33 C0                    xor     r8d, r8d
00007FF91E2DE89D  48 8D 54 24 48              lea     rdx, [rsp+0C8h+PerformanceCount]
00007FF91E2DE8A2  48 8B CB                    mov     rcx, rbx
00007FF91E2DE8A5  FF D0                       call    rax ; qword_7FF91E916980
00007FF91E2DE8A7  48 B9 FF FF FF FF FF FF FF 7F  mov     rcx, 7FFFFFFFFFFFFFFFh
00007FF91E2DE8B1  85 C0                       test    eax, eax
00007FF91E2DE8B3  74 18                       jz      short loc_7FF91E2DE8CD
00007FF91E2DE8B5  44 8B FD                    mov     r15d, ebp
00007FF91E2DE8B8  8B C5                       mov     eax, ebp
00007FF91E2DE8BA  48 89 5C C4 68              mov     [rsp+rax*8+0C8h+Handles], rbx
00007FF91E2DE8BF  FF C5                       inc     ebp
00007FF91E2DE8C1  EB 0A                       jmp     short loc_7FF91E2DE8CD
00007FF91E2DE8C3  48 B9 FF FF FF FF FF FF FF 7F  mov     rcx, 7FFFFFFFFFFFFFFFh
00007FF91E2DE8CD  BF FF FF FF FF              mov     edi, 0FFFFFFFFh
00007FF91E2DE8D2  44 3B FF                    cmp     r15d, edi
00007FF91E2DE8D5  75 4C                       jnz     short loc_7FF91E2DE923
00007FF91E2DE8D7  49 39 0E                    cmp     [r14], rcx
00007FF91E2DE8DA  74 47                       jz      short loc_7FF91E2DE923
00007FF91E2DE8DC  48 8D 4C 24 50              lea     rcx, [rsp+0C8h+Frequency]
00007FF91E2DE8E1  E8 5A 11 00 00              call    sub_7FF91E2DFA40
00007FF91E2DE8E6  49 8B 0E                    mov     rcx, [r14]
00007FF91E2DE8E9  48 2B 08                    sub     rcx, [rax]
00007FF91E2DE8EC  48 B8 DB 34 B6 D7 82 DE 1B 43  mov     rax, 431BDE82D7B634DBh
00007FF91E2DE8F6  78 09                       js      short loc_7FF91E2DE901
00007FF91E2DE8F8  48 81 C1 3F 42 0F 00        add     rcx, 0F423Fh
00007FF91E2DE8FF  EB 07                       jmp     short loc_7FF91E2DE908
00007FF91E2DE901  48 81 C1 C1 BD F0 FF        add     rcx, 0FFFFFFFFFFF0BDC1h
00007FF91E2DE908  48 F7 E9                    imul    rcx
00007FF91E2DE90B  48 8B FA                    mov     rdi, rdx
00007FF91E2DE90E  48 C1 FF 12                 sar     rdi, 12h
00007FF91E2DE912  48 8B C7                    mov     rax, rdi
00007FF91E2DE915  48 C1 E8 3F                 shr     rax, 3Fh
00007FF91E2DE919  48 03 F8                    add     rdi, rax
00007FF91E2DE91C  48 85 FF                    test    rdi, rdi
00007FF91E2DE91F  48 0F 48 FE                 cmovs   rdi, rsi
00007FF91E2DE923  F2 0F 10 35 45 92 40 00     movsd   xmm6, cs:qword_7FF91E6E7B70
00007FF91E2DE92B  0F 1F 44 00 00              nop     dword ptr [rax+rax+00h]
00007FF91E2DE930  85 ED                       test    ebp, ebp
00007FF91E2DE932  74 4B                       jz      short loc_7FF91E2DE97F
00007FF91E2DE934  89 74 24 20                 mov     [rsp+0C8h+bAlertable], esi; bAlertable
00007FF91E2DE938  44 8B CF                    mov     r9d, edi; dwMilliseconds
00007FF91E2DE93B  45 33 C0                    xor     r8d, r8d; bWaitAll
00007FF91E2DE93E  48 8D 54 24 68              lea     rdx, [rsp+0C8h+Handles]; lpHandles
00007FF91E2DE943  8B CD                       mov     ecx, ebp; nCount
00007FF91E2DE945  FF 15 8D 5D 2B 00           call    cs:__imp_WaitForMultipleObjectsEx
00007FF91E2DE94B  3B C5                       cmp     eax, ebp
00007FF91E2DE94D  73 40                       jnb     short loc_7FF91E2DE98F
00007FF91E2DE94F  41 3B C5                    cmp     eax, r13d
00007FF91E2DE952  0F 84 5A 01 00 00           jz      loc_7FF91E2DEAB2
00007FF91E2DE958  41 3B C4                    cmp     eax, r12d
00007FF91E2DE95B  0F 84 69 01 00 00           jz      loc_7FF91E2DEACA
00007FF91E2DE961  41 3B C7                    cmp     eax, r15d
00007FF91E2DE964  75 29                       jnz     short loc_7FF91E2DE98F
00007FF91E2DE966  48 8D 43 FF                 lea     rax, [rbx-1]
00007FF91E2DE96A  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E2DE96E  77 0A                       ja      short loc_7FF91E2DE97A
00007FF91E2DE970  48 8B CB                    mov     rcx, rbx; hObject
00007FF91E2DE973  FF 15 57 5E 2B 00           call    cs:__imp_CloseHandle
00007FF91E2DE979  90                          nop
00007FF91E2DE97A  E9 FB 00 00 00              jmp     loc_7FF91E2DEA7A
00007FF91E2DE97F  85 FF                       test    edi, edi
00007FF91E2DE981  75 04                       jnz     short loc_7FF91E2DE987
00007FF91E2DE983  33 C9                       xor     ecx, ecx
00007FF91E2DE985  EB 02                       jmp     short loc_7FF91E2DE989
00007FF91E2DE987  8B CF                       mov     ecx, edi; dwMilliseconds
00007FF91E2DE989  FF 15 B1 5E 2B 00           call    cs:__imp_Sleep
00007FF91E2DE98F  B8 FF FF FF FF              mov     eax, 0FFFFFFFFh
00007FF91E2DE994  44 3B F8                    cmp     r15d, eax
00007FF91E2DE997  0F 85 B7 00 00 00           jnz     loc_7FF91E2DEA54
00007FF91E2DE99D  48 B9 FF FF FF FF FF FF FF 7F  mov     rcx, 7FFFFFFFFFFFFFFFh
00007FF91E2DE9A7  49 39 0E                    cmp     [r14], rcx
00007FF91E2DE9AA  0F 84 A4 00 00 00           jz      loc_7FF91E2DEA54
00007FF91E2DE9B0  48 8D 4C 24 50              lea     rcx, [rsp+0C8h+Frequency]; lpFrequency
00007FF91E2DE9B5  FF 15 3D 5A 2B 00           call    cs:__imp_QueryPerformanceFrequency
00007FF91E2DE9BB  85 C0                       test    eax, eax
00007FF91E2DE9BD  75 05                       jnz     short loc_7FF91E2DE9C4
00007FF91E2DE9BF  48 8B C6                    mov     rax, rsi
00007FF91E2DE9C2  EB 55                       jmp     short loc_7FF91E2DEA19
00007FF91E2DE9C4  48 83 7C 24 50 00           cmp     qword ptr [rsp+0C8h+Frequency], 0
00007FF91E2DE9CA  7F 05                       jg      short loc_7FF91E2DE9D1
00007FF91E2DE9CC  48 8B C6                    mov     rax, rsi
00007FF91E2DE9CF  EB 48                       jmp     short loc_7FF91E2DEA19
00007FF91E2DE9D1  8B FE                       mov     edi, esi
00007FF91E2DE9D3  48 8D 4C 24 48              lea     rcx, [rsp+0C8h+PerformanceCount]; lpPerformanceCount
00007FF91E2DE9D8  FF 15 A2 5A 2B 00           call    cs:__imp_QueryPerformanceCounter
00007FF91E2DE9DE  85 C0                       test    eax, eax
00007FF91E2DE9E0  75 16                       jnz     short loc_7FF91E2DE9F8
00007FF91E2DE9E2  FF C7                       inc     edi
00007FF91E2DE9E4  83 FF 03                    cmp     edi, 3
00007FF91E2DE9E7  77 D6                       ja      short loc_7FF91E2DE9BF
00007FF91E2DE9E9  48 8D 4C 24 48              lea     rcx, [rsp+0C8h+PerformanceCount]; lpPerformanceCount
00007FF91E2DE9EE  FF 15 8C 5A 2B 00           call    cs:__imp_QueryPerformanceCounter
00007FF91E2DE9F4  85 C0                       test    eax, eax
00007FF91E2DE9F6  74 EA                       jz      short loc_7FF91E2DE9E2
00007FF91E2DE9F8  0F 57 C9                    xorps   xmm1, xmm1
00007FF91E2DE9FB  F2 48 0F 2A 4C 24 48        cvtsi2sd xmm1, qword ptr [rsp+0C8h+PerformanceCount]
00007FF91E2DEA02  F2 0F 59 CE                 mulsd   xmm1, xmm6
00007FF91E2DEA06  0F 57 C0                    xorps   xmm0, xmm0
00007FF91E2DEA09  F2 48 0F 2A 44 24 50        cvtsi2sd xmm0, qword ptr [rsp+0C8h+Frequency]
00007FF91E2DEA10  F2 0F 5E C8                 divsd   xmm1, xmm0
00007FF91E2DEA14  F2 48 0F 2C C1              cvttsd2si rax, xmm1
00007FF91E2DEA19  49 8B 0E                    mov     rcx, [r14]
00007FF91E2DEA1C  48 2B C8                    sub     rcx, rax
00007FF91E2DEA1F  48 B8 DB 34 B6 D7 82 DE 1B 43  mov     rax, 431BDE82D7B634DBh
00007FF91E2DEA29  78 09                       js      short loc_7FF91E2DEA34
00007FF91E2DEA2B  48 81 C1 3F 42 0F 00        add     rcx, 0F423Fh
00007FF91E2DEA32  EB 07                       jmp     short loc_7FF91E2DEA3B
00007FF91E2DEA34  48 81 C1 C1 BD F0 FF        add     rcx, 0FFFFFFFFFFF0BDC1h
00007FF91E2DEA3B  48 F7 E9                    imul    rcx
00007FF91E2DEA3E  48 8B FA                    mov     rdi, rdx
00007FF91E2DEA41  48 C1 FF 12                 sar     rdi, 12h
00007FF91E2DEA45  48 8B C7                    mov     rax, rdi
00007FF91E2DEA48  48 C1 E8 3F                 shr     rax, 3Fh
00007FF91E2DEA4C  48 03 F8                    add     rdi, rax
00007FF91E2DEA4F  B8 FF FF FF FF              mov     eax, 0FFFFFFFFh
00007FF91E2DEA54  48 3B F8                    cmp     rdi, rax
00007FF91E2DEA57  0F 84 D3 FE FF FF           jz      loc_7FF91E2DE930
00007FF91E2DEA5D  48 85 FF                    test    rdi, rdi
00007FF91E2DEA60  0F 8F CA FE FF FF           jg      loc_7FF91E2DE930
00007FF91E2DEA66  48 8D 43 FF                 lea     rax, [rbx-1]
00007FF91E2DEA6A  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E2DEA6E  77 0A                       ja      short loc_7FF91E2DEA7A
00007FF91E2DEA70  48 8B CB                    mov     rcx, rbx; hObject
00007FF91E2DEA73  FF 15 57 5D 2B 00           call    cs:__imp_CloseHandle
00007FF91E2DEA79  90                          nop
00007FF91E2DEA7A  32 C0                       xor     al, al
00007FF91E2DEA7C  48 8B 8C 24 88 00 00 00     mov     rcx, [rsp+0C8h+var_40]
00007FF91E2DEA84  48 33 CC                    xor     rcx, rsp; StackCookie
00007FF91E2DEA87  E8 94 72 FF FF              call    __security_check_cookie
00007FF91E2DEA8C  4C 8D 9C 24 A0 00 00 00     lea     r11, [rsp+0C8h+var_28]
00007FF91E2DEA94  49 8B 5B 30                 mov     rbx, [r11+30h]
00007FF91E2DEA98  49 8B 6B 38                 mov     rbp, [r11+38h]
00007FF91E2DEA9C  49 8B 73 40                 mov     rsi, [r11+40h]
00007FF91E2DEAA0  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
00007FF91E2DEAA5  49 8B E3                    mov     rsp, r11
00007FF91E2DEAA8  41 5F                       pop     r15
00007FF91E2DEAAA  41 5E                       pop     r14
00007FF91E2DEAAC  41 5D                       pop     r13
00007FF91E2DEAAE  41 5C                       pop     r12
00007FF91E2DEAB0  5F                          pop     rdi
00007FF91E2DEAB1  C3                          retn
00007FF91E2DEAB2  48 8D 43 FF                 lea     rax, [rbx-1]
00007FF91E2DEAB6  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E2DEABA  77 0A                       ja      short loc_7FF91E2DEAC6
00007FF91E2DEABC  48 8B CB                    mov     rcx, rbx; hObject
00007FF91E2DEABF  FF 15 0B 5D 2B 00           call    cs:__imp_CloseHandle
00007FF91E2DEAC5  90                          nop
00007FF91E2DEAC6  B0 01                       mov     al, 1
00007FF91E2DEAC8  EB B2                       jmp     short loc_7FF91E2DEA7C
00007FF91E2DEACA  E8 51 F9 FF FF              call    sub_7FF91E2DE420
00007FF91E2DEACF  48 8D 48 68                 lea     rcx, [rax+68h]
00007FF91E2DEAD3  E8 28 D2 FF FF              call    sub_7FF91E2DBD00
00007FF91E2DEAD8  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E2DEADB  FF 15 37 59 2B 00           call    cs:__imp_ResetEvent
00007FF91E2DEAE1  48 8D 15 80 E3 5B 00        lea     rdx, __TI1?AVthread_interrupted@boost@@; pThrowInfo
00007FF91E2DEAE8  48 8D 4C 24 40              lea     rcx, [rsp+0C8h+pExceptionObject]; pExceptionObject
00007FF91E2DEAED  E8 36 F5 02 00              call    _CxxThrowException
00007FF91E2DEAF2  CC                          db 0CCh
