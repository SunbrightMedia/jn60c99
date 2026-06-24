; sub_7FF91E026F00 @ rva 0x3C6F00

00007FF91E026F00  48 8B C4                    mov     rax, rsp
00007FF91E026F03  56                          push    rsi
00007FF91E026F04  57                          push    rdi
00007FF91E026F05  41 54                       push    r12
00007FF91E026F07  41 56                       push    r14
00007FF91E026F09  41 57                       push    r15
00007FF91E026F0B  48 81 EC B0 00 00 00        sub     rsp, 0B0h
00007FF91E026F12  48 C7 44 24 40 FE FF FF FF  mov     [rsp+0D8h+var_98], 0FFFFFFFFFFFFFFFEh
00007FF91E026F1B  48 89 58 18                 mov     [rax+18h], rbx
00007FF91E026F1F  48 89 68 20                 mov     [rax+20h], rbp
00007FF91E026F23  48 8B 05 CE DF 8C 00        mov     rax, cs:__security_cookie
00007FF91E026F2A  48 33 C4                    xor     rax, rsp
00007FF91E026F2D  48 89 84 24 A0 00 00 00     mov     [rsp+0D8h+var_38], rax
00007FF91E026F35  8B EA                       mov     ebp, edx
00007FF91E026F37  48 8B F9                    mov     rdi, rcx
00007FF91E026F3A  48 8D 4C 24 38              lea     rcx, [rsp+0D8h+var_A0]
00007FF91E026F3F  E8 CC 3D F8 FF              call    sub_7FF91DFAAD10
00007FF91E026F44  90                          nop
00007FF91E026F45  4C 8D 77 38                 lea     r14, [rdi+38h]
00007FF91E026F49  49 8B C6                    mov     rax, r14
00007FF91E026F4C  48 89 44 24 20              mov     [rsp+0D8h+var_B8], rax
00007FF91E026F51  C6 44 24 28 00              mov     [rsp+0D8h+var_B0], 0
00007FF91E026F56  4D 85 F6                    test    r14, r14
00007FF91E026F59  0F 84 F7 01 00 00           jz      loc_7FF91E027156
00007FF91E026F5F  49 BF FF FF FF FF FF FF FF 7F  mov     r15, 7FFFFFFFFFFFFFFFh
00007FF91E026F69  45 33 E4                    xor     r12d, r12d
00007FF91E026F6C  0F 1F 40 00                 nop     dword ptr [rax+00h]
00007FF91E026F70  48 8B C8                    mov     rcx, rax
00007FF91E026F73  E8 28 43 F8 FF              call    sub_7FF91DFAB2A0
00007FF91E026F78  B1 01                       mov     cl, 1
00007FF91E026F7A  88 4C 24 28                 mov     [rsp+0D8h+var_B0], cl
00007FF91E026F7E  8B 47 34                    mov     eax, [rdi+34h]
00007FF91E026F81  85 C0                       test    eax, eax
00007FF91E026F83  75 2F                       jnz     short loc_7FF91E026FB4
00007FF91E026F85  66 66 66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00007FF91E026F90  4C 89 7C 24 30              mov     [rsp+0D8h+var_A8], r15
00007FF91E026F95  4C 8D 44 24 30              lea     r8, [rsp+0D8h+var_A8]
00007FF91E026F9A  48 8D 54 24 20              lea     rdx, [rsp+0D8h+var_B8]
00007FF91E026F9F  48 8D 4F 48                 lea     rcx, [rdi+48h]
00007FF91E026FA3  E8 38 E3 FF FF              call    sub_7FF91E0252E0
00007FF91E026FA8  8B 47 34                    mov     eax, [rdi+34h]
00007FF91E026FAB  85 C0                       test    eax, eax
00007FF91E026FAD  74 E1                       jz      short loc_7FF91E026F90
00007FF91E026FAF  0F B6 4C 24 28              movzx   ecx, [rsp+0D8h+var_B0]
00007FF91E026FB4  83 F8 01                    cmp     eax, 1
00007FF91E026FB7  0F 85 E2 00 00 00           jnz     loc_7FF91E02709F
00007FF91E026FBD  41 8B DC                    mov     ebx, r12d
00007FF91E026FC0  39 5F 30                    cmp     [rdi+30h], ebx
00007FF91E026FC3  7E 39                       jle     short loc_7FF91E026FFE
00007FF91E026FC5  66 66 66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00007FF91E026FD0  4C 8D 47 20                 lea     r8, [rdi+20h]
00007FF91E026FD4  8B D5                       mov     edx, ebp
00007FF91E026FD6  48 8B 4F 18                 mov     rcx, [rdi+18h]
00007FF91E026FDA  E8 51 1F FD FF              call    sub_7FF91DFF8F30
00007FF91E026FDF  48 83 47 20 04              add     qword ptr [rdi+20h], 4
00007FF91E026FE4  48 83 47 28 04              add     qword ptr [rdi+28h], 4
00007FF91E026FE9  85 ED                       test    ebp, ebp
00007FF91E026FEB  75 0A                       jnz     short loc_7FF91E026FF7
00007FF91E026FED  48 8B 4F 08                 mov     rcx, [rdi+8]
00007FF91E026FF1  48 8B 01                    mov     rax, [rcx]
00007FF91E026FF4  FF 50 68                    call    qword ptr [rax+68h]
00007FF91E026FF7  FF C3                       inc     ebx
00007FF91E026FF9  3B 5F 30                    cmp     ebx, [rdi+30h]
00007FF91E026FFC  7C D2                       jl      short loc_7FF91E026FD0
00007FF91E026FFE  44 89 67 34                 mov     [rdi+34h], r12d
00007FF91E027002  48 8B 5F 10                 mov     rbx, [rdi+10h]
00007FF91E027006  48 8D 4B 08                 lea     rcx, [rbx+8]
00007FF91E02700A  E8 91 42 F8 FF              call    sub_7FF91DFAB2A0
00007FF91E02700F  48 8B 47 10                 mov     rax, [rdi+10h]
00007FF91E027013  FF 00                       inc     dword ptr [rax]
00007FF91E027015  48 8B 4F 10                 mov     rcx, [rdi+10h]
00007FF91E027019  48 83 C1 18                 add     rcx, 18h
00007FF91E02701D  E8 1E 14 00 00              call    sub_7FF91E028440
00007FF91E027022  90                          nop
00007FF91E027023  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E027028  F0 0F C1 43 08              lock xadd [rbx+8], eax
00007FF91E02702D  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E027031  72 22                       jb      short loc_7FF91E027055
00007FF91E027033  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E027038  7E 1B                       jle     short loc_7FF91E027055
00007FF91E02703A  F0 0F BA 6B 08 1E           lock bts dword ptr [rbx+8], 1Eh
00007FF91E027040  72 13                       jb      short loc_7FF91E027055
00007FF91E027042  48 8D 4B 08                 lea     rcx, [rbx+8]
00007FF91E027046  E8 E5 F7 F3 FF              call    sub_7FF91DF66830
00007FF91E02704B  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E02704E  FF 15 9C D7 56 00           call    cs:__imp_SetEvent
00007FF91E027054  90                          nop
00007FF91E027055  80 7C 24 28 00              cmp     [rsp+0D8h+var_B0], 0
00007FF91E02705A  74 31                       jz      short loc_7FF91E02708D
00007FF91E02705C  48 8B 4C 24 20              mov     rcx, [rsp+0D8h+var_B8]
00007FF91E027061  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E027066  F0 0F C1 01                 lock xadd [rcx], eax
00007FF91E02706A  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E02706E  72 1D                       jb      short loc_7FF91E02708D
00007FF91E027070  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E027075  7E 16                       jle     short loc_7FF91E02708D
00007FF91E027077  F0 0F BA 29 1E              lock bts dword ptr [rcx], 1Eh
00007FF91E02707C  72 0F                       jb      short loc_7FF91E02708D
00007FF91E02707E  E8 AD F7 F3 FF              call    sub_7FF91DF66830
00007FF91E027083  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E027086  FF 15 64 D7 56 00           call    cs:__imp_SetEvent
00007FF91E02708C  90                          nop
00007FF91E02708D  49 8B C6                    mov     rax, r14
00007FF91E027090  48 89 44 24 20              mov     [rsp+0D8h+var_B8], rax
00007FF91E027095  C6 44 24 28 00              mov     [rsp+0D8h+var_B0], 0
00007FF91E02709A  E9 D1 FE FF FF              jmp     loc_7FF91E026F70
00007FF91E02709F  83 F8 02                    cmp     eax, 2
00007FF91E0270A2  74 47                       jz      short loc_7FF91E0270EB
00007FF91E0270A4  84 C9                       test    cl, cl
00007FF91E0270A6  74 31                       jz      short loc_7FF91E0270D9
00007FF91E0270A8  48 8B 4C 24 20              mov     rcx, [rsp+0D8h+var_B8]
00007FF91E0270AD  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E0270B2  F0 0F C1 01                 lock xadd [rcx], eax
00007FF91E0270B6  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E0270BA  72 1D                       jb      short loc_7FF91E0270D9
00007FF91E0270BC  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E0270C1  7E 16                       jle     short loc_7FF91E0270D9
00007FF91E0270C3  F0 0F BA 29 1E              lock bts dword ptr [rcx], 1Eh
00007FF91E0270C8  72 0F                       jb      short loc_7FF91E0270D9
00007FF91E0270CA  E8 61 F7 F3 FF              call    sub_7FF91DF66830
00007FF91E0270CF  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E0270D2  FF 15 18 D7 56 00           call    cs:__imp_SetEvent
00007FF91E0270D8  90                          nop
00007FF91E0270D9  49 8B C6                    mov     rax, r14
00007FF91E0270DC  48 89 44 24 20              mov     [rsp+0D8h+var_B8], rax
00007FF91E0270E1  C6 44 24 28 00              mov     [rsp+0D8h+var_B0], 0
00007FF91E0270E6  E9 85 FE FF FF              jmp     loc_7FF91E026F70
00007FF91E0270EB  84 C9                       test    cl, cl
00007FF91E0270ED  74 31                       jz      short loc_7FF91E027120
00007FF91E0270EF  48 8B 4C 24 20              mov     rcx, [rsp+0D8h+var_B8]
00007FF91E0270F4  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E0270F9  F0 0F C1 01                 lock xadd [rcx], eax
00007FF91E0270FD  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E027101  72 1D                       jb      short loc_7FF91E027120
00007FF91E027103  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E027108  7E 16                       jle     short loc_7FF91E027120
00007FF91E02710A  F0 0F BA 29 1E              lock bts dword ptr [rcx], 1Eh
00007FF91E02710F  72 0F                       jb      short loc_7FF91E027120
00007FF91E027111  E8 1A F7 F3 FF              call    sub_7FF91DF66830
00007FF91E027116  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E027119  FF 15 D1 D6 56 00           call    cs:__imp_SetEvent
00007FF91E02711F  90                          nop
00007FF91E027120  48 8D 4C 24 38              lea     rcx, [rsp+0D8h+var_A0]
00007FF91E027125  E8 86 3C F8 FF              call    sub_7FF91DFAADB0
00007FF91E02712A  48 8B 8C 24 A0 00 00 00     mov     rcx, [rsp+0D8h+var_38]
00007FF91E027132  48 33 CC                    xor     rcx, rsp; StackCookie
00007FF91E027135  E8 E6 EB 2A 00              call    __security_check_cookie
00007FF91E02713A  4C 8D 9C 24 B0 00 00 00     lea     r11, [rsp+0D8h+var_28]
00007FF91E027142  49 8B 5B 40                 mov     rbx, [r11+40h]
00007FF91E027146  49 8B 6B 48                 mov     rbp, [r11+48h]
00007FF91E02714A  49 8B E3                    mov     rsp, r11
00007FF91E02714D  41 5F                       pop     r15
00007FF91E02714F  41 5E                       pop     r14
00007FF91E027151  41 5C                       pop     r12
00007FF91E027153  5F                          pop     rdi
00007FF91E027154  5E                          pop     rsi
00007FF91E027155  C3                          retn
00007FF91E027156  4C 8D 05 AB 81 61 00        lea     r8, aBoostUniqueLoc; "boost unique_lock has no mutex"
00007FF91E02715D  BA 01 00 00 00              mov     edx, 1
00007FF91E027162  48 8D 4C 24 50              lea     rcx, [rsp+0D8h+var_88]
00007FF91E027167  E8 54 EA FF FF              call    sub_7FF91E025BC0
00007FF91E02716C  90                          nop
00007FF91E02716D  48 8B C8                    mov     rcx, rax
00007FF91E027170  E8 4B E5 FF FF              call    sub_7FF91E0256C0
00007FF91E027175  CC                          db 0CCh
