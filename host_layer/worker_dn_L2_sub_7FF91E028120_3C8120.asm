; sub_7FF91E028120 @ rva 0x3C8120

00007FF91E028120  48 8B C4                    mov     rax, rsp
00007FF91E028123  56                          push    rsi
00007FF91E028124  57                          push    rdi
00007FF91E028125  41 56                       push    r14
00007FF91E028127  48 81 EC 60 01 00 00        sub     rsp, 160h
00007FF91E02812E  48 C7 44 24 50 FE FF FF FF  mov     [rsp+178h+var_128], 0FFFFFFFFFFFFFFFEh
00007FF91E028137  48 89 58 18                 mov     [rax+18h], rbx
00007FF91E02813B  48 89 68 20                 mov     [rax+20h], rbp
00007FF91E02813F  48 8B 05 B2 CD 8C 00        mov     rax, cs:__security_cookie
00007FF91E028146  48 33 C4                    xor     rax, rsp
00007FF91E028149  48 89 84 24 50 01 00 00     mov     [rsp+178h+var_28], rax
00007FF91E028151  4C 8B F2                    mov     r14, rdx
00007FF91E028154  48 8B F9                    mov     rdi, rcx
00007FF91E028157  48 89 54 24 40              mov     [rsp+178h+var_138], rdx
00007FF91E02815C  48 89 4C 24 58              mov     [rsp+178h+var_120], rcx
00007FF91E028161  E8 3A 31 F8 FF              call    sub_7FF91DFAB2A0
00007FF91E028166  90                          nop
00007FF91E028167  48 83 7F 30 00              cmp     qword ptr [rdi+30h], 0
00007FF91E02816C  75 37                       jnz     short loc_7FF91E0281A5
00007FF91E02816E  45 33 C9                    xor     r9d, r9d; lpName
00007FF91E028171  33 D2                       xor     edx, edx; lInitialCount
00007FF91E028173  33 C9                       xor     ecx, ecx; lpSemaphoreAttributes
00007FF91E028175  41 B8 FF FF FF 7F           mov     r8d, 7FFFFFFFh; lMaximumCount
00007FF91E02817B  FF 15 27 C7 56 00           call    cs:__imp_CreateSemaphoreA
00007FF91E028181  48 8B D8                    mov     rbx, rax
00007FF91E028184  48 85 C0                    test    rax, rax
00007FF91E028187  0F 84 D2 01 00 00           jz      loc_7FF91E02835F
00007FF91E02818D  48 8B 4F 30                 mov     rcx, [rdi+30h]; hObject
00007FF91E028191  48 8D 41 FF                 lea     rax, [rcx-1]
00007FF91E028195  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E028199  77 06                       ja      short loc_7FF91E0281A1
00007FF91E02819B  FF 15 2F C6 56 00           call    cs:__imp_CloseHandle
00007FF91E0281A1  48 89 5F 30                 mov     [rdi+30h], rbx
00007FF91E0281A5  8B 47 10                    mov     eax, [rdi+10h]
00007FF91E0281A8  FF C0                       inc     eax
00007FF91E0281AA  89 47 10                    mov     [rdi+10h], eax
00007FF91E0281AD  48 8B 47 20                 mov     rax, [rdi+20h]
00007FF91E0281B1  48 39 47 18                 cmp     [rdi+18h], rax
00007FF91E0281B5  74 56                       jz      short loc_7FF91E02820D
00007FF91E0281B7  48 8B 40 F8                 mov     rax, [rax-8]
00007FF91E0281BB  80 78 14 00                 cmp     byte ptr [rax+14h], 0
00007FF91E0281BF  75 4C                       jnz     short loc_7FF91E02820D
00007FF91E0281C1  F0 FF 40 10                 lock inc dword ptr [rax+10h]
00007FF91E0281C5  48 8B 47 20                 mov     rax, [rdi+20h]
00007FF91E0281C9  48 8B 48 F8                 mov     rcx, [rax-8]
00007FF91E0281CD  49 89 0E                    mov     [r14], rcx
00007FF91E0281D0  48 85 C9                    test    rcx, rcx
00007FF91E0281D3  74 04                       jz      short loc_7FF91E0281D9
00007FF91E0281D5  F0 FF 41 18                 lock inc dword ptr [rcx+18h]
00007FF91E0281D9  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E0281DE  F0 0F C1 07                 lock xadd [rdi], eax
00007FF91E0281E2  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E0281E6  72 20                       jb      short loc_7FF91E028208
00007FF91E0281E8  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E0281ED  7E 19                       jle     short loc_7FF91E028208
00007FF91E0281EF  F0 0F BA 2F 1E              lock bts dword ptr [rdi], 1Eh
00007FF91E0281F4  72 12                       jb      short loc_7FF91E028208
00007FF91E0281F6  48 8B CF                    mov     rcx, rdi
00007FF91E0281F9  E8 32 E6 F3 FF              call    sub_7FF91DF66830
00007FF91E0281FE  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E028201  FF 15 E9 C5 56 00           call    cs:__imp_SetEvent
00007FF91E028207  90                          nop
00007FF91E028208  E9 10 01 00 00              jmp     loc_7FF91E02831D
00007FF91E02820D  B9 20 00 00 00              mov     ecx, 20h ; ' '; Size
00007FF91E028212  E8 15 D0 2A 00              call    ??2@YAPEAX_K@Z; operator new(unsigned __int64)
00007FF91E028217  48 8B F0                    mov     rsi, rax
00007FF91E02821A  48 89 44 24 40              mov     [rsp+178h+var_138], rax
00007FF91E02821F  48 85 C0                    test    rax, rax
00007FF91E028222  0F 84 83 00 00 00           jz      loc_7FF91E0282AB
00007FF91E028228  45 33 C9                    xor     r9d, r9d; lpName
00007FF91E02822B  33 D2                       xor     edx, edx; lInitialCount
00007FF91E02822D  33 C9                       xor     ecx, ecx; lpSemaphoreAttributes
00007FF91E02822F  41 B8 FF FF FF 7F           mov     r8d, 7FFFFFFFh; lMaximumCount
00007FF91E028235  FF 15 6D C6 56 00           call    cs:__imp_CreateSemaphoreA
00007FF91E02823B  48 85 C0                    test    rax, rax
00007FF91E02823E  0F 84 2F 01 00 00           jz      loc_7FF91E028373
00007FF91E028244  48 89 06                    mov     [rsi], rax
00007FF91E028247  48 8B 5F 30                 mov     rbx, [rdi+30h]
00007FF91E02824B  FF 15 0F C6 56 00           call    cs:__imp_GetCurrentProcess
00007FF91E028251  48 C7 44 24 48 00 00 00 00  mov     [rsp+178h+TargetHandle], 0
00007FF91E02825A  C7 44 24 30 02 00 00 00     mov     [rsp+178h+dwOptions], 2; dwOptions
00007FF91E028262  C7 44 24 28 00 00 00 00     mov     [rsp+178h+bInheritHandle], 0; bInheritHandle
00007FF91E02826A  C7 44 24 20 00 00 00 00     mov     [rsp+178h+dwDesiredAccess], 0; dwDesiredAccess
00007FF91E028272  4C 8D 4C 24 48              lea     r9, [rsp+178h+TargetHandle]; lpTargetHandle
00007FF91E028277  4C 8B C0                    mov     r8, rax; hTargetProcessHandle
00007FF91E02827A  48 8B D3                    mov     rdx, rbx; hSourceHandle
00007FF91E02827D  48 8B C8                    mov     rcx, rax; hSourceProcessHandle
00007FF91E028280  FF 15 E2 C5 56 00           call    cs:__imp_DuplicateHandle
00007FF91E028286  85 C0                       test    eax, eax
00007FF91E028288  0F 84 BA 00 00 00           jz      loc_7FF91E028348
00007FF91E02828E  48 8B 44 24 48              mov     rax, [rsp+178h+TargetHandle]
00007FF91E028293  48 89 46 08                 mov     [rsi+8], rax
00007FF91E028297  C7 46 10 01 00 00 00        mov     dword ptr [rsi+10h], 1
00007FF91E02829E  C6 46 14 00                 mov     byte ptr [rsi+14h], 0
00007FF91E0282A2  C7 46 18 00 00 00 00        mov     dword ptr [rsi+18h], 0
00007FF91E0282A9  EB 02                       jmp     short loc_7FF91E0282AD
00007FF91E0282AB  33 F6                       xor     esi, esi
00007FF91E0282AD  48 89 74 24 40              mov     [rsp+178h+var_138], rsi
00007FF91E0282B2  48 85 F6                    test    rsi, rsi
00007FF91E0282B5  74 04                       jz      short loc_7FF91E0282BB
00007FF91E0282B7  F0 FF 46 18                 lock inc dword ptr [rsi+18h]
00007FF91E0282BB  48 8B 57 20                 mov     rdx, [rdi+20h]
00007FF91E0282BF  48 39 57 28                 cmp     [rdi+28h], rdx
00007FF91E0282C3  74 13                       jz      short loc_7FF91E0282D8
00007FF91E0282C5  48 89 32                    mov     [rdx], rsi
00007FF91E0282C8  48 85 F6                    test    rsi, rsi
00007FF91E0282CB  74 04                       jz      short loc_7FF91E0282D1
00007FF91E0282CD  F0 FF 46 18                 lock inc dword ptr [rsi+18h]
00007FF91E0282D1  48 83 47 20 08              add     qword ptr [rdi+20h], 8
00007FF91E0282D6  EB 0E                       jmp     short loc_7FF91E0282E6
00007FF91E0282D8  4C 8D 44 24 40              lea     r8, [rsp+178h+var_138]
00007FF91E0282DD  48 8D 4F 18                 lea     rcx, [rdi+18h]
00007FF91E0282E1  E8 8A CD FF FF              call    sub_7FF91E025070
00007FF91E0282E6  48 8B 44 24 40              mov     rax, [rsp+178h+var_138]
00007FF91E0282EB  49 89 06                    mov     [r14], rax
00007FF91E0282EE  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E0282F3  F0 0F C1 07                 lock xadd [rdi], eax
00007FF91E0282F7  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E0282FB  72 20                       jb      short loc_7FF91E02831D
00007FF91E0282FD  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E028302  7E 19                       jle     short loc_7FF91E02831D
00007FF91E028304  F0 0F BA 2F 1E              lock bts dword ptr [rdi], 1Eh
00007FF91E028309  72 12                       jb      short loc_7FF91E02831D
00007FF91E02830B  48 8B CF                    mov     rcx, rdi
00007FF91E02830E  E8 1D E5 F3 FF              call    sub_7FF91DF66830
00007FF91E028313  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E028316  FF 15 D4 C4 56 00           call    cs:__imp_SetEvent
00007FF91E02831C  90                          nop
00007FF91E02831D  49 8B C6                    mov     rax, r14
00007FF91E028320  48 8B 8C 24 50 01 00 00     mov     rcx, [rsp+178h+var_28]
00007FF91E028328  48 33 CC                    xor     rcx, rsp; StackCookie
00007FF91E02832B  E8 F0 D9 2A 00              call    __security_check_cookie
00007FF91E028330  4C 8D 9C 24 60 01 00 00     lea     r11, [rsp+178h+var_18]
00007FF91E028338  49 8B 5B 30                 mov     rbx, [r11+30h]
00007FF91E02833C  49 8B 6B 38                 mov     rbp, [r11+38h]
00007FF91E028340  49 8B E3                    mov     rsp, r11
00007FF91E028343  41 5E                       pop     r14
00007FF91E028345  5F                          pop     rdi
00007FF91E028346  5E                          pop     rsi
00007FF91E028347  C3                          retn
00007FF91E028348  48 8D 8C 24 00 01 00 00     lea     rcx, [rsp+178h+var_78]
00007FF91E028350  E8 BB 32 F3 FF              call    sub_7FF91DF5B610
00007FF91E028355  90                          nop
00007FF91E028356  48 8B C8                    mov     rcx, rax
00007FF91E028359  E8 32 09 F3 FF              call    sub_7FF91DF58C90
00007FF91E02835E  90                          db 90h
00007FF91E02835F  48 8D 4C 24 60              lea     rcx, [rsp+178h+var_118]
00007FF91E028364  E8 A7 32 F3 FF              call    sub_7FF91DF5B610
00007FF91E028369  90                          nop
00007FF91E02836A  48 8B C8                    mov     rcx, rax
00007FF91E02836D  E8 1E 09 F3 FF              call    sub_7FF91DF58C90
00007FF91E028372  90                          db 90h
00007FF91E028373  48 8D 8C 24 B0 00 00 00     lea     rcx, [rsp+178h+var_C8]
00007FF91E02837B  E8 90 32 F3 FF              call    sub_7FF91DF5B610
00007FF91E028380  90                          nop
00007FF91E028381  48 8B C8                    mov     rcx, rax
00007FF91E028384  E8 07 09 F3 FF              call    sub_7FF91DF58C90
00007FF91E028389  CC                          db 0CCh
