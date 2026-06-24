; sub_7FF91E0286A0 @ rva 0x3C86A0

00007FF91E0286A0  40 57                       push    rdi
00007FF91E0286A2  48 83 EC 30                 sub     rsp, 30h
00007FF91E0286A6  48 C7 44 24 20 FE FF FF FF  mov     [rsp+38h+var_18], 0FFFFFFFFFFFFFFFEh
00007FF91E0286AF  48 89 5C 24 40              mov     [rsp+38h+arg_0], rbx
00007FF91E0286B4  48 89 74 24 48              mov     [rsp+38h+arg_8], rsi
00007FF91E0286B9  48 8B F1                    mov     rsi, rcx
00007FF91E0286BC  48 83 39 00                 cmp     qword ptr [rcx], 0
00007FF91E0286C0  0F 84 95 00 00 00           jz      loc_7FF91E02875B
00007FF91E0286C6  48 8B 79 08                 mov     rdi, [rcx+8]
00007FF91E0286CA  48 8B CF                    mov     rcx, rdi
00007FF91E0286CD  E8 CE 2B F8 FF              call    sub_7FF91DFAB2A0
00007FF91E0286D2  48 8B 06                    mov     rax, [rsi]
00007FF91E0286D5  F0 FF 48 10                 lock dec dword ptr [rax+10h]
00007FF91E0286D9  48 8B 1E                    mov     rbx, [rsi]
00007FF91E0286DC  48 C7 06 00 00 00 00        mov     qword ptr [rsi], 0
00007FF91E0286E3  48 85 DB                    test    rbx, rbx
00007FF91E0286E6  74 44                       jz      short loc_7FF91E02872C
00007FF91E0286E8  B8 FF FF FF FF              mov     eax, 0FFFFFFFFh
00007FF91E0286ED  F0 0F C1 43 18              lock xadd [rbx+18h], eax
00007FF91E0286F2  83 F8 01                    cmp     eax, 1
00007FF91E0286F5  75 35                       jnz     short loc_7FF91E02872C
00007FF91E0286F7  48 8B 4B 08                 mov     rcx, [rbx+8]; hObject
00007FF91E0286FB  48 8D 41 FF                 lea     rax, [rcx-1]
00007FF91E0286FF  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E028703  77 06                       ja      short loc_7FF91E02870B
00007FF91E028705  FF 15 C5 C0 56 00           call    cs:__imp_CloseHandle
00007FF91E02870B  48 8B 0B                    mov     rcx, [rbx]; hObject
00007FF91E02870E  48 8D 41 FF                 lea     rax, [rcx-1]
00007FF91E028712  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E028716  77 06                       ja      short loc_7FF91E02871E
00007FF91E028718  FF 15 B2 C0 56 00           call    cs:__imp_CloseHandle
00007FF91E02871E  BA 20 00 00 00              mov     edx, 20h ; ' '
00007FF91E028723  48 8B CB                    mov     rcx, rbx; Block
00007FF91E028726  E8 3D CB 2A 00              call    j_j_free
00007FF91E02872B  90                          nop
00007FF91E02872C  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E028731  F0 0F C1 07                 lock xadd [rdi], eax
00007FF91E028735  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E028739  72 20                       jb      short loc_7FF91E02875B
00007FF91E02873B  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E028740  7E 19                       jle     short loc_7FF91E02875B
00007FF91E028742  F0 0F BA 2F 1E              lock bts dword ptr [rdi], 1Eh
00007FF91E028747  72 12                       jb      short loc_7FF91E02875B
00007FF91E028749  48 8B CF                    mov     rcx, rdi
00007FF91E02874C  E8 DF E0 F3 FF              call    sub_7FF91DF66830
00007FF91E028751  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E028754  FF 15 96 C0 56 00           call    cs:__imp_SetEvent
00007FF91E02875A  90                          nop
00007FF91E02875B  48 8B 5C 24 40              mov     rbx, [rsp+38h+arg_0]
00007FF91E028760  48 8B 74 24 48              mov     rsi, [rsp+38h+arg_8]
00007FF91E028765  48 83 C4 30                 add     rsp, 30h
00007FF91E028769  5F                          pop     rdi
00007FF91E02876A  C3                          retn
