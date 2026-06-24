; sub_7FF91E0224A0 @ rva 0x3C24A0

00007FF91E0224A0  48 89 5C 24 10              mov     [rsp+arg_8], rbx
00007FF91E0224A5  57                          push    rdi
00007FF91E0224A6  48 83 EC 20                 sub     rsp, 20h
00007FF91E0224AA  48 8B 59 70                 mov     rbx, [rcx+70h]
00007FF91E0224AE  48 8B F9                    mov     rdi, rcx
00007FF91E0224B1  48 3B 59 78                 cmp     rbx, [rcx+78h]
00007FF91E0224B5  74 50                       jz      short loc_7FF91E022507
00007FF91E0224B7  48 89 74 24 30              mov     [rsp+28h+arg_0], rsi
00007FF91E0224BC  48 8D 73 04                 lea     rsi, [rbx+4]
00007FF91E0224C0  48 63 03                    movsxd  rax, dword ptr [rbx]
00007FF91E0224C3  48 8D 0C 80                 lea     rcx, [rax+rax*4]
00007FF91E0224C7  48 8B 47 58                 mov     rax, [rdi+58h]
00007FF91E0224CB  48 8D 0C C8                 lea     rcx, [rax+rcx*8]
00007FF91E0224CF  E8 2C 09 00 00              call    sub_7FF91E022E00
00007FF91E0224D4  84 C0                       test    al, al
00007FF91E0224D6  75 19                       jnz     short loc_7FF91E0224F1
00007FF91E0224D8  4C 8B 47 78                 mov     r8, [rdi+78h]
00007FF91E0224DC  48 8B D6                    mov     rdx, rsi
00007FF91E0224DF  4C 2B C6                    sub     r8, rsi
00007FF91E0224E2  48 8B CB                    mov     rcx, rbx
00007FF91E0224E5  E8 16 B7 2E 00              call    sub_7FF91E30DC00
00007FF91E0224EA  48 83 47 78 FC              add     qword ptr [rdi+78h], 0FFFFFFFFFFFFFFFCh
00007FF91E0224EF  EB 08                       jmp     short loc_7FF91E0224F9
00007FF91E0224F1  48 83 C3 04                 add     rbx, 4
00007FF91E0224F5  48 83 C6 04                 add     rsi, 4
00007FF91E0224F9  48 8B 47 78                 mov     rax, [rdi+78h]
00007FF91E0224FD  48 3B D8                    cmp     rbx, rax
00007FF91E022500  75 BE                       jnz     short loc_7FF91E0224C0
00007FF91E022502  48 8B 74 24 30              mov     rsi, [rsp+28h+arg_0]
00007FF91E022507  48 8B 5C 24 38              mov     rbx, [rsp+28h+arg_8]
00007FF91E02250C  48 83 C4 20                 add     rsp, 20h
00007FF91E022510  5F                          pop     rdi
00007FF91E022511  C3                          retn
