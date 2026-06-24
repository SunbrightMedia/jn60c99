; sub_7FF91E0252E0 @ rva 0x3C52E0

00007FF91E0252E0  48 8B C4                    mov     rax, rsp
00007FF91E0252E3  56                          push    rsi
00007FF91E0252E4  57                          push    rdi
00007FF91E0252E5  41 56                       push    r14
00007FF91E0252E7  48 83 EC 50                 sub     rsp, 50h
00007FF91E0252EB  48 C7 40 B8 FE FF FF FF     mov     qword ptr [rax-48h], 0FFFFFFFFFFFFFFFEh
00007FF91E0252F3  48 89 58 10                 mov     [rax+10h], rbx
00007FF91E0252F7  48 89 68 18                 mov     [rax+18h], rbp
00007FF91E0252FB  4D 8B F0                    mov     r14, r8
00007FF91E0252FE  48 8B EA                    mov     rbp, rdx
00007FF91E025301  48 8B D9                    mov     rbx, rcx
00007FF91E025304  48 89 50 D0                 mov     [rax-30h], rdx
00007FF91E025308  C6 40 D8 00                 mov     byte ptr [rax-28h], 0
00007FF91E02530C  48 8D 50 08                 lea     rdx, [rax+8]
00007FF91E025310  E8 0B 2E 00 00              call    sub_7FF91E028120
00007FF91E025315  48 8B 38                    mov     rdi, [rax]
00007FF91E025318  48 89 7C 24 28              mov     [rsp+68h+var_40], rdi
00007FF91E02531D  48 C7 00 00 00 00 00        mov     qword ptr [rax], 0
00007FF91E025324  48 89 5C 24 30              mov     [rsp+68h+var_38], rbx
00007FF91E025329  48 8B 5C 24 70              mov     rbx, [rsp+68h+Block]
00007FF91E02532E  48 85 DB                    test    rbx, rbx
00007FF91E025331  74 4D                       jz      short loc_7FF91E025380
00007FF91E025333  B8 FF FF FF FF              mov     eax, 0FFFFFFFFh
00007FF91E025338  F0 0F C1 43 18              lock xadd [rbx+18h], eax
00007FF91E02533D  83 F8 01                    cmp     eax, 1
00007FF91E025340  75 39                       jnz     short loc_7FF91E02537B
00007FF91E025342  48 85 DB                    test    rbx, rbx
00007FF91E025345  74 34                       jz      short loc_7FF91E02537B
00007FF91E025347  48 8B 4B 08                 mov     rcx, [rbx+8]; hObject
00007FF91E02534B  48 8D 41 FF                 lea     rax, [rcx-1]
00007FF91E02534F  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E025353  77 06                       ja      short loc_7FF91E02535B
00007FF91E025355  FF 15 75 F4 56 00           call    cs:__imp_CloseHandle
00007FF91E02535B  48 8B 0B                    mov     rcx, [rbx]; hObject
00007FF91E02535E  48 8D 41 FF                 lea     rax, [rcx-1]
00007FF91E025362  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E025366  77 06                       ja      short loc_7FF91E02536E
00007FF91E025368  FF 15 62 F4 56 00           call    cs:__imp_CloseHandle
00007FF91E02536E  BA 20 00 00 00              mov     edx, 20h ; ' '
00007FF91E025373  48 8B CB                    mov     rcx, rbx; Block
00007FF91E025376  E8 ED FE 2A 00              call    j_j_free
00007FF91E02537B  48 8B 7C 24 28              mov     rdi, [rsp+68h+var_40]
00007FF91E025380  48 8B CD                    mov     rcx, rbp
00007FF91E025383  E8 58 34 00 00              call    sub_7FF91E0287E0
00007FF91E025388  40 B6 01                    mov     sil, 1
00007FF91E02538B  40 88 74 24 40              mov     [rsp+68h+var_28], sil
00007FF91E025390  49 8B D6                    mov     rdx, r14
00007FF91E025393  48 8B 0F                    mov     rcx, [rdi]
00007FF91E025396  E8 15 93 2B 00              call    sub_7FF91E2DE6B0
00007FF91E02539B  84 C0                       test    al, al
00007FF91E02539D  74 31                       jz      short loc_7FF91E0253D0
00007FF91E02539F  45 33 C0                    xor     r8d, r8d; bAlertable
00007FF91E0253A2  33 D2                       xor     edx, edx; dwMilliseconds
00007FF91E0253A4  48 8B 4F 08                 mov     rcx, [rdi+8]; hHandle
00007FF91E0253A8  FF 15 8A F5 56 00           call    cs:__imp_WaitForSingleObjectEx
00007FF91E0253AE  85 C0                       test    eax, eax
00007FF91E0253B0  75 DE                       jnz     short loc_7FF91E025390
00007FF91E0253B2  48 8D 4C 24 28              lea     rcx, [rsp+68h+var_40]
00007FF91E0253B7  E8 E4 32 00 00              call    sub_7FF91E0286A0
00007FF91E0253BC  48 8B CD                    mov     rcx, rbp
00007FF91E0253BF  E8 CC 2F 00 00              call    sub_7FF91E028390
00007FF91E0253C4  40 32 F6                    xor     sil, sil
00007FF91E0253C7  40 88 74 24 40              mov     [rsp+68h+var_28], sil
00007FF91E0253CC  B3 01                       mov     bl, 1
00007FF91E0253CE  EB 02                       jmp     short loc_7FF91E0253D2
00007FF91E0253D0  32 DB                       xor     bl, bl
00007FF91E0253D2  48 8D 4C 24 28              lea     rcx, [rsp+68h+var_40]
00007FF91E0253D7  E8 C4 32 00 00              call    sub_7FF91E0286A0
00007FF91E0253DC  90                          nop
00007FF91E0253DD  48 8D 4C 24 28              lea     rcx, [rsp+68h+var_40]
00007FF91E0253E2  E8 09 09 00 00              call    sub_7FF91E025CF0
00007FF91E0253E7  90                          nop
00007FF91E0253E8  40 84 F6                    test    sil, sil
00007FF91E0253EB  74 08                       jz      short loc_7FF91E0253F5
00007FF91E0253ED  48 8B CD                    mov     rcx, rbp
00007FF91E0253F0  E8 9B 2F 00 00              call    sub_7FF91E028390
00007FF91E0253F5  0F B6 C3                    movzx   eax, bl
00007FF91E0253F8  48 8B 5C 24 78              mov     rbx, [rsp+68h+arg_8]
00007FF91E0253FD  48 8B AC 24 80 00 00 00     mov     rbp, [rsp+68h+arg_10]
00007FF91E025405  48 83 C4 50                 add     rsp, 50h
00007FF91E025409  41 5E                       pop     r14
00007FF91E02540B  5F                          pop     rdi
00007FF91E02540C  5E                          pop     rsi
00007FF91E02540D  C3                          retn
