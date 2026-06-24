; sub_7FF91E028390 @ rva 0x3C8390

00007FF91E028390  40 53                       push    rbx
00007FF91E028392  48 81 EC 90 00 00 00        sub     rsp, 90h
00007FF91E028399  48 C7 44 24 20 FE FF FF FF  mov     [rsp+98h+var_78], 0FFFFFFFFFFFFFFFEh
00007FF91E0283A2  48 8B 05 4F CB 8C 00        mov     rax, cs:__security_cookie
00007FF91E0283A9  48 33 C4                    xor     rax, rsp
00007FF91E0283AC  48 89 84 24 80 00 00 00     mov     [rsp+98h+var_18], rax
00007FF91E0283B4  48 8B D9                    mov     rbx, rcx
00007FF91E0283B7  48 8B 09                    mov     rcx, [rcx]
00007FF91E0283BA  48 85 C9                    test    rcx, rcx
00007FF91E0283BD  74 48                       jz      short loc_7FF91E028407
00007FF91E0283BF  80 7B 08 00                 cmp     byte ptr [rbx+8], 0
00007FF91E0283C3  75 22                       jnz     short loc_7FF91E0283E7
00007FF91E0283C5  E8 D6 2E F8 FF              call    sub_7FF91DFAB2A0
00007FF91E0283CA  C6 43 08 01                 mov     byte ptr [rbx+8], 1
00007FF91E0283CE  48 8B 8C 24 80 00 00 00     mov     rcx, [rsp+98h+var_18]
00007FF91E0283D6  48 33 CC                    xor     rcx, rsp; StackCookie
00007FF91E0283D9  E8 42 D9 2A 00              call    __security_check_cookie
00007FF91E0283DE  48 81 C4 90 00 00 00        add     rsp, 90h
00007FF91E0283E5  5B                          pop     rbx
00007FF91E0283E6  C3                          retn
00007FF91E0283E7  4C 8D 05 62 6F 61 00        lea     r8, aBoostUniqueLoc_0; "boost unique_lock owns already the mute"...
00007FF91E0283EE  BA 24 00 00 00              mov     edx, 24h ; '$'
00007FF91E0283F3  48 8D 4C 24 30              lea     rcx, [rsp+98h+var_68]
00007FF91E0283F8  E8 C3 D7 FF FF              call    sub_7FF91E025BC0
00007FF91E0283FD  90                          nop
00007FF91E0283FE  48 8B C8                    mov     rcx, rax
00007FF91E028401  E8 BA D2 FF FF              call    sub_7FF91E0256C0
00007FF91E028406  90                          db 90h
00007FF91E028407  4C 8D 05 FA 6E 61 00        lea     r8, aBoostUniqueLoc; "boost unique_lock has no mutex"
00007FF91E02840E  BA 01 00 00 00              mov     edx, 1
00007FF91E028413  48 8D 4C 24 30              lea     rcx, [rsp+98h+var_68]
00007FF91E028418  E8 A3 D7 FF FF              call    sub_7FF91E025BC0
00007FF91E02841D  90                          nop
00007FF91E02841E  48 8B C8                    mov     rcx, rax
00007FF91E028421  E8 9A D2 FF FF              call    sub_7FF91E0256C0
00007FF91E028426  CC                          db 0CCh
