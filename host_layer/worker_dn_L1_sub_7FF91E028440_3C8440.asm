; sub_7FF91E028440 @ rva 0x3C8440

00007FF91E028440  40 57                       push    rdi
00007FF91E028442  41 56                       push    r14
00007FF91E028444  41 57                       push    r15
00007FF91E028446  48 83 EC 30                 sub     rsp, 30h
00007FF91E02844A  48 C7 44 24 20 FE FF FF FF  mov     [rsp+48h+var_28], 0FFFFFFFFFFFFFFFEh
00007FF91E028453  48 89 5C 24 50              mov     [rsp+48h+arg_0], rbx
00007FF91E028458  48 89 6C 24 58              mov     [rsp+48h+arg_8], rbp
00007FF91E02845D  48 89 74 24 60              mov     [rsp+48h+arg_10], rsi
00007FF91E028462  48 8B E9                    mov     rbp, rcx
00007FF91E028465  8B 41 10                    mov     eax, [rcx+10h]
00007FF91E028468  85 C0                       test    eax, eax
00007FF91E02846A  0F 84 08 02 00 00           jz      loc_7FF91E028678
00007FF91E028470  E8 2B 2E F8 FF              call    sub_7FF91DFAB2A0
00007FF91E028475  90                          nop
00007FF91E028476  8B 45 10                    mov     eax, [rbp+10h]
00007FF91E028479  85 C0                       test    eax, eax
00007FF91E02847B  75 37                       jnz     short loc_7FF91E0284B4
00007FF91E02847D  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E028482  F0 0F C1 45 00              lock xadd [rbp+0], eax
00007FF91E028487  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E02848B  72 22                       jb      short loc_7FF91E0284AF
00007FF91E02848D  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E028492  7E 1B                       jle     short loc_7FF91E0284AF
00007FF91E028494  F0 0F BA 6D 00 1E           lock bts dword ptr [rbp+0], 1Eh
00007FF91E02849A  72 13                       jb      short loc_7FF91E0284AF
00007FF91E02849C  48 8B CD                    mov     rcx, rbp
00007FF91E02849F  E8 8C E3 F3 FF              call    sub_7FF91DF66830
00007FF91E0284A4  90                          nop
00007FF91E0284A5  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E0284A8  FF 15 42 C3 56 00           call    cs:__imp_SetEvent
00007FF91E0284AE  90                          nop
00007FF91E0284AF  E9 C4 01 00 00              jmp     loc_7FF91E028678
00007FF91E0284B4  FF C8                       dec     eax
00007FF91E0284B6  89 45 10                    mov     [rbp+10h], eax
00007FF91E0284B9  45 33 C0                    xor     r8d, r8d; lpPreviousCount
00007FF91E0284BC  41 8D 50 01                 lea     edx, [r8+1]; lReleaseCount
00007FF91E0284C0  48 8B 4D 30                 mov     rcx, [rbp+30h]; hSemaphore
00007FF91E0284C4  FF 15 E6 C3 56 00           call    cs:__imp_ReleaseSemaphore
00007FF91E0284CA  90                          nop
00007FF91E0284CB  48 8B 75 20                 mov     rsi, [rbp+20h]
00007FF91E0284CF  48 8B 5D 18                 mov     rbx, [rbp+18h]
00007FF91E0284D3  48 3B DE                    cmp     rbx, rsi
00007FF91E0284D6  74 2D                       jz      short loc_7FF91E028505
00007FF91E0284D8  0F 1F 84 00 00 00 00 00     nop     dword ptr [rax+rax+00000000h]
00007FF91E0284E0  48 8B 03                    mov     rax, [rbx]
00007FF91E0284E3  C6 40 14 01                 mov     byte ptr [rax+14h], 1
00007FF91E0284E7  45 33 C0                    xor     r8d, r8d; lpPreviousCount
00007FF91E0284EA  41 8D 50 01                 lea     edx, [r8+1]; lReleaseCount
00007FF91E0284EE  48 8B 08                    mov     rcx, [rax]; hSemaphore
00007FF91E0284F1  FF 15 B9 C3 56 00           call    cs:__imp_ReleaseSemaphore
00007FF91E0284F7  90                          nop
00007FF91E0284F8  48 83 C3 08                 add     rbx, 8
00007FF91E0284FC  48 3B DE                    cmp     rbx, rsi
00007FF91E0284FF  75 DF                       jnz     short loc_7FF91E0284E0
00007FF91E028501  48 8B 75 20                 mov     rsi, [rbp+20h]
00007FF91E028505  48 8B 7D 18                 mov     rdi, [rbp+18h]
00007FF91E028509  48 3B FE                    cmp     rdi, rsi
00007FF91E02850C  74 15                       jz      short loc_7FF91E028523
00007FF91E02850E  66 90                       xchg    ax, ax
00007FF91E028510  48 8B 07                    mov     rax, [rdi]
00007FF91E028513  8B 48 10                    mov     ecx, [rax+10h]
00007FF91E028516  85 C9                       test    ecx, ecx
00007FF91E028518  74 09                       jz      short loc_7FF91E028523
00007FF91E02851A  48 83 C7 08                 add     rdi, 8
00007FF91E02851E  48 3B FE                    cmp     rdi, rsi
00007FF91E028521  75 ED                       jnz     short loc_7FF91E028510
00007FF91E028523  45 33 FF                    xor     r15d, r15d
00007FF91E028526  48 3B FE                    cmp     rdi, rsi
00007FF91E028529  0F 84 17 01 00 00           jz      loc_7FF91E028646
00007FF91E02852F  4C 8D 77 08                 lea     r14, [rdi+8]
00007FF91E028533  4C 3B F6                    cmp     r14, rsi
00007FF91E028536  74 76                       jz      short loc_7FF91E0285AE
00007FF91E028538  0F 1F 84 00 00 00 00 00     nop     dword ptr [rax+rax+00000000h]
00007FF91E028540  49 8B 06                    mov     rax, [r14]
00007FF91E028543  8B 48 10                    mov     ecx, [rax+10h]
00007FF91E028546  85 C9                       test    ecx, ecx
00007FF91E028548  74 5B                       jz      short loc_7FF91E0285A5
00007FF91E02854A  49 8B 06                    mov     rax, [r14]
00007FF91E02854D  4D 89 3E                    mov     [r14], r15
00007FF91E028550  48 8B 1F                    mov     rbx, [rdi]
00007FF91E028553  48 89 07                    mov     [rdi], rax
00007FF91E028556  48 85 DB                    test    rbx, rbx
00007FF91E028559  74 46                       jz      short loc_7FF91E0285A1
00007FF91E02855B  B8 FF FF FF FF              mov     eax, 0FFFFFFFFh
00007FF91E028560  F0 0F C1 43 18              lock xadd [rbx+18h], eax
00007FF91E028565  83 F8 01                    cmp     eax, 1
00007FF91E028568  75 37                       jnz     short loc_7FF91E0285A1
00007FF91E02856A  48 8B 4B 08                 mov     rcx, [rbx+8]; hObject
00007FF91E02856E  48 8D 41 FF                 lea     rax, [rcx-1]
00007FF91E028572  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E028576  77 07                       ja      short loc_7FF91E02857F
00007FF91E028578  FF 15 52 C2 56 00           call    cs:__imp_CloseHandle
00007FF91E02857E  90                          nop
00007FF91E02857F  48 8B 0B                    mov     rcx, [rbx]; hObject
00007FF91E028582  48 8D 41 FF                 lea     rax, [rcx-1]
00007FF91E028586  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E02858A  77 07                       ja      short loc_7FF91E028593
00007FF91E02858C  FF 15 3E C2 56 00           call    cs:__imp_CloseHandle
00007FF91E028592  90                          nop
00007FF91E028593  BA 20 00 00 00              mov     edx, 20h ; ' '
00007FF91E028598  48 8B CB                    mov     rcx, rbx; Block
00007FF91E02859B  E8 C8 CC 2A 00              call    j_j_free
00007FF91E0285A0  90                          nop
00007FF91E0285A1  48 83 C7 08                 add     rdi, 8
00007FF91E0285A5  49 83 C6 08                 add     r14, 8
00007FF91E0285A9  4C 3B F6                    cmp     r14, rsi
00007FF91E0285AC  75 92                       jnz     short loc_7FF91E028540
00007FF91E0285AE  48 3B FE                    cmp     rdi, rsi
00007FF91E0285B1  0F 84 8F 00 00 00           jz      loc_7FF91E028646
00007FF91E0285B7  4C 8B 75 20                 mov     r14, [rbp+20h]
00007FF91E0285BB  49 3B F6                    cmp     rsi, r14
00007FF91E0285BE  74 68                       jz      short loc_7FF91E028628
00007FF91E0285C0  48 8B 06                    mov     rax, [rsi]
00007FF91E0285C3  4C 89 3E                    mov     [rsi], r15
00007FF91E0285C6  48 8B 1F                    mov     rbx, [rdi]
00007FF91E0285C9  48 89 07                    mov     [rdi], rax
00007FF91E0285CC  48 85 DB                    test    rbx, rbx
00007FF91E0285CF  74 46                       jz      short loc_7FF91E028617
00007FF91E0285D1  B8 FF FF FF FF              mov     eax, 0FFFFFFFFh
00007FF91E0285D6  F0 0F C1 43 18              lock xadd [rbx+18h], eax
00007FF91E0285DB  83 F8 01                    cmp     eax, 1
00007FF91E0285DE  75 37                       jnz     short loc_7FF91E028617
00007FF91E0285E0  48 8B 4B 08                 mov     rcx, [rbx+8]; hObject
00007FF91E0285E4  48 8D 41 FF                 lea     rax, [rcx-1]
00007FF91E0285E8  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E0285EC  77 07                       ja      short loc_7FF91E0285F5
00007FF91E0285EE  FF 15 DC C1 56 00           call    cs:__imp_CloseHandle
00007FF91E0285F4  90                          nop
00007FF91E0285F5  48 8B 0B                    mov     rcx, [rbx]; hObject
00007FF91E0285F8  48 8D 41 FF                 lea     rax, [rcx-1]
00007FF91E0285FC  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E028600  77 07                       ja      short loc_7FF91E028609
00007FF91E028602  FF 15 C8 C1 56 00           call    cs:__imp_CloseHandle
00007FF91E028608  90                          nop
00007FF91E028609  BA 20 00 00 00              mov     edx, 20h ; ' '
00007FF91E02860E  48 8B CB                    mov     rcx, rbx; Block
00007FF91E028611  E8 52 CC 2A 00              call    j_j_free
00007FF91E028616  90                          nop
00007FF91E028617  48 83 C7 08                 add     rdi, 8
00007FF91E02861B  48 83 C6 08                 add     rsi, 8
00007FF91E02861F  49 3B F6                    cmp     rsi, r14
00007FF91E028622  75 9C                       jnz     short loc_7FF91E0285C0
00007FF91E028624  4C 8B 75 20                 mov     r14, [rbp+20h]
00007FF91E028628  48 8B DF                    mov     rbx, rdi
00007FF91E02862B  49 3B FE                    cmp     rdi, r14
00007FF91E02862E  74 12                       jz      short loc_7FF91E028642
00007FF91E028630  48 8B CB                    mov     rcx, rbx
00007FF91E028633  E8 B8 D6 FF FF              call    sub_7FF91E025CF0
00007FF91E028638  90                          nop
00007FF91E028639  48 83 C3 08                 add     rbx, 8
00007FF91E02863D  49 3B DE                    cmp     rbx, r14
00007FF91E028640  75 EE                       jnz     short loc_7FF91E028630
00007FF91E028642  48 89 7D 20                 mov     [rbp+20h], rdi
00007FF91E028646  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E02864B  F0 0F C1 45 00              lock xadd [rbp+0], eax
00007FF91E028650  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E028654  72 22                       jb      short loc_7FF91E028678
00007FF91E028656  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E02865B  7E 1B                       jle     short loc_7FF91E028678
00007FF91E02865D  F0 0F BA 6D 00 1E           lock bts dword ptr [rbp+0], 1Eh
00007FF91E028663  72 13                       jb      short loc_7FF91E028678
00007FF91E028665  48 8B CD                    mov     rcx, rbp
00007FF91E028668  E8 C3 E1 F3 FF              call    sub_7FF91DF66830
00007FF91E02866D  90                          nop
00007FF91E02866E  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E028671  FF 15 79 C1 56 00           call    cs:__imp_SetEvent
00007FF91E028677  90                          nop
00007FF91E028678  48 8B 5C 24 50              mov     rbx, [rsp+48h+arg_0]
00007FF91E02867D  48 8B 6C 24 58              mov     rbp, [rsp+48h+arg_8]
00007FF91E028682  48 8B 74 24 60              mov     rsi, [rsp+48h+arg_10]
00007FF91E028687  48 83 C4 30                 add     rsp, 30h
00007FF91E02868B  41 5F                       pop     r15
00007FF91E02868D  41 5E                       pop     r14
00007FF91E02868F  5F                          pop     rdi
00007FF91E028690  C3                          retn
