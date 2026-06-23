; sub_1803C24A0 @ 0x1803C24A0 (RVA 0x3C24A0) size=0x72

00000001803C24A0  48 89 5C 24 10              mov     [rsp+arg_8], rbx
00000001803C24A5  57                          push    rdi
00000001803C24A6  48 83 EC 20                 sub     rsp, 20h
00000001803C24AA  48 8B 59 70                 mov     rbx, [rcx+70h]
00000001803C24AE  48 8B F9                    mov     rdi, rcx
00000001803C24B1  48 3B 59 78                 cmp     rbx, [rcx+78h]
00000001803C24B5  74 50                       jz      short loc_1803C2507
00000001803C24B7  48 89 74 24 30              mov     [rsp+28h+arg_0], rsi
00000001803C24BC  48 8D 73 04                 lea     rsi, [rbx+4]
00000001803C24C0  48 63 03                    movsxd  rax, dword ptr [rbx]
00000001803C24C3  48 8D 0C 80                 lea     rcx, [rax+rax*4]
00000001803C24C7  48 8B 47 58                 mov     rax, [rdi+58h]
00000001803C24CB  48 8D 0C C8                 lea     rcx, [rax+rcx*8]
00000001803C24CF  E8 2C 09 00 00              call    sub_1803C2E00
00000001803C24D4  84 C0                       test    al, al
00000001803C24D6  75 19                       jnz     short loc_1803C24F1
00000001803C24D8  4C 8B 47 78                 mov     r8, [rdi+78h]
00000001803C24DC  48 8B D6                    mov     rdx, rsi
00000001803C24DF  4C 2B C6                    sub     r8, rsi
00000001803C24E2  48 8B CB                    mov     rcx, rbx
00000001803C24E5  E8 16 B7 2E 00              call    sub_1806ADC00
00000001803C24EA  48 83 47 78 FC              add     qword ptr [rdi+78h], 0FFFFFFFFFFFFFFFCh
00000001803C24EF  EB 08                       jmp     short loc_1803C24F9
00000001803C24F1  48 83 C3 04                 add     rbx, 4
00000001803C24F5  48 83 C6 04                 add     rsi, 4
00000001803C24F9  48 8B 47 78                 mov     rax, [rdi+78h]
00000001803C24FD  48 3B D8                    cmp     rbx, rax
00000001803C2500  75 BE                       jnz     short loc_1803C24C0
00000001803C2502  48 8B 74 24 30              mov     rsi, [rsp+28h+arg_0]
00000001803C2507  48 8B 5C 24 38              mov     rbx, [rsp+28h+arg_8]
00000001803C250C  48 83 C4 20                 add     rsp, 20h
00000001803C2510  5F                          pop     rdi
00000001803C2511  C3                          retn
