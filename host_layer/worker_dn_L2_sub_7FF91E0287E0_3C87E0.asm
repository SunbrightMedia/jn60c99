; sub_7FF91E0287E0 @ rva 0x3C87E0

00007FF91E0287E0  40 53                       push    rbx
00007FF91E0287E2  48 81 EC E0 00 00 00        sub     rsp, 0E0h
00007FF91E0287E9  48 C7 44 24 20 FE FF FF FF  mov     [rsp+0E8h+var_C8], 0FFFFFFFFFFFFFFFEh
00007FF91E0287F2  48 8B 05 FF C6 8C 00        mov     rax, cs:__security_cookie
00007FF91E0287F9  48 33 C4                    xor     rax, rsp
00007FF91E0287FC  48 89 84 24 D0 00 00 00     mov     [rsp+0E8h+var_18], rax
00007FF91E028804  48 8B D9                    mov     rbx, rcx
00007FF91E028807  48 8B 09                    mov     rcx, [rcx]
00007FF91E02880A  48 85 C9                    test    rcx, rcx
00007FF91E02880D  74 71                       jz      short loc_7FF91E028880
00007FF91E02880F  80 7B 08 00                 cmp     byte ptr [rbx+8], 0
00007FF91E028813  74 48                       jz      short loc_7FF91E02885D
00007FF91E028815  B8 00 00 00 80              mov     eax, 80000000h
00007FF91E02881A  F0 0F C1 01                 lock xadd [rcx], eax
00007FF91E02881E  0F BA E0 1E                 bt      eax, 1Eh
00007FF91E028822  72 1C                       jb      short loc_7FF91E028840
00007FF91E028824  3D 00 00 00 80              cmp     eax, 80000000h
00007FF91E028829  7E 15                       jle     short loc_7FF91E028840
00007FF91E02882B  F0 0F BA 29 1E              lock bts dword ptr [rcx], 1Eh
00007FF91E028830  72 0E                       jb      short loc_7FF91E028840
00007FF91E028832  E8 F9 DF F3 FF              call    sub_7FF91DF66830
00007FF91E028837  48 8B C8                    mov     rcx, rax; hEvent
00007FF91E02883A  FF 15 B0 BF 56 00           call    cs:__imp_SetEvent
00007FF91E028840  C6 43 08 00                 mov     byte ptr [rbx+8], 0
00007FF91E028844  48 8B 8C 24 D0 00 00 00     mov     rcx, [rsp+0E8h+var_18]
00007FF91E02884C  48 33 CC                    xor     rcx, rsp; StackCookie
00007FF91E02884F  E8 CC D4 2A 00              call    __security_check_cookie
00007FF91E028854  48 81 C4 E0 00 00 00        add     rsp, 0E0h
00007FF91E02885B  5B                          pop     rbx
00007FF91E02885C  C3                          retn
00007FF91E02885D  4C 8D 05 C4 6A 61 00        lea     r8, aBoostUniqueLoc_1; "boost unique_lock doesn't own the mutex"
00007FF91E028864  BA 01 00 00 00              mov     edx, 1
00007FF91E028869  48 8D 8C 24 80 00 00 00     lea     rcx, [rsp+0E8h+var_68]
00007FF91E028871  E8 4A D3 FF FF              call    sub_7FF91E025BC0
00007FF91E028876  90                          nop
00007FF91E028877  48 8B C8                    mov     rcx, rax
00007FF91E02887A  E8 41 CE FF FF              call    sub_7FF91E0256C0
00007FF91E02887F  90                          align 20h
00007FF91E028880  4C 8D 05 81 6A 61 00        lea     r8, aBoostUniqueLoc; "boost unique_lock has no mutex"
00007FF91E028887  BA 01 00 00 00              mov     edx, 1
00007FF91E02888C  48 8D 4C 24 30              lea     rcx, [rsp+0E8h+var_B8]
00007FF91E028891  E8 2A D3 FF FF              call    sub_7FF91E025BC0
00007FF91E028896  90                          nop
00007FF91E028897  48 8B C8                    mov     rcx, rax
00007FF91E02889A  E8 21 CE FF FF              call    sub_7FF91E0256C0
00007FF91E02889F  CC                          align 20h
