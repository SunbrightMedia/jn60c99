; sub_7FF91E025CF0 @ rva 0x3C5CF0

00007FF91E025CF0  40 53                       push    rbx
00007FF91E025CF2  48 83 EC 20                 sub     rsp, 20h
00007FF91E025CF6  48 8B 19                    mov     rbx, [rcx]
00007FF91E025CF9  48 85 DB                    test    rbx, rbx
00007FF91E025CFC  74 4D                       jz      short loc_7FF91E025D4B
00007FF91E025CFE  B8 FF FF FF FF              mov     eax, 0FFFFFFFFh
00007FF91E025D03  F0 0F C1 43 18              lock xadd [rbx+18h], eax
00007FF91E025D08  83 F8 01                    cmp     eax, 1
00007FF91E025D0B  75 3E                       jnz     short loc_7FF91E025D4B
00007FF91E025D0D  48 85 DB                    test    rbx, rbx
00007FF91E025D10  74 39                       jz      short loc_7FF91E025D4B
00007FF91E025D12  48 8B 4B 08                 mov     rcx, [rbx+8]; hObject
00007FF91E025D16  48 8D 41 FF                 lea     rax, [rcx-1]
00007FF91E025D1A  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E025D1E  77 06                       ja      short loc_7FF91E025D26
00007FF91E025D20  FF 15 AA EA 56 00           call    cs:__imp_CloseHandle
00007FF91E025D26  48 8B 0B                    mov     rcx, [rbx]; hObject
00007FF91E025D29  48 8D 41 FF                 lea     rax, [rcx-1]
00007FF91E025D2D  48 83 F8 FD                 cmp     rax, 0FFFFFFFFFFFFFFFDh
00007FF91E025D31  77 06                       ja      short loc_7FF91E025D39
00007FF91E025D33  FF 15 97 EA 56 00           call    cs:__imp_CloseHandle
00007FF91E025D39  BA 20 00 00 00              mov     edx, 20h ; ' '
00007FF91E025D3E  48 8B CB                    mov     rcx, rbx; Block
00007FF91E025D41  48 83 C4 20                 add     rsp, 20h
00007FF91E025D45  5B                          pop     rbx
00007FF91E025D46  E9 1D F5 2A 00              jmp     j_j_free
00007FF91E025D4B  48 83 C4 20                 add     rsp, 20h
00007FF91E025D4F  5B                          pop     rbx
00007FF91E025D50  C3                          retn
