; sub_7FF91DFF8EC0 @ rva 0x398EC0

00007FF91DFF8EC0  40 53                       push    rbx
00007FF91DFF8EC2  48 83 EC 20                 sub     rsp, 20h
00007FF91DFF8EC6  80 79 14 00                 cmp     byte ptr [rcx+14h], 0
00007FF91DFF8ECA  48 8B D9                    mov     rbx, rcx
00007FF91DFF8ECD  74 4E                       jz      short loc_7FF91DFF8F1D
00007FF91DFF8ECF  8B 81 08 30 A8 00           mov     eax, [rcx+0A83008h]
00007FF91DFF8ED5  85 C0                       test    eax, eax
00007FF91DFF8ED7  7E 22                       jle     short loc_7FF91DFF8EFB
00007FF91DFF8ED9  FF C8                       dec     eax
00007FF91DFF8EDB  89 81 08 30 A8 00           mov     [rcx+0A83008h], eax
00007FF91DFF8EE1  33 C9                       xor     ecx, ecx
00007FF91DFF8EE3  49 8B 00                    mov     rax, [r8]
00007FF91DFF8EE6  89 08                       mov     [rax], ecx
00007FF91DFF8EE8  49 8B 40 08                 mov     rax, [r8+8]
00007FF91DFF8EEC  89 08                       mov     [rax], ecx
00007FF91DFF8EEE  48 8B CB                    mov     rcx, rbx
00007FF91DFF8EF1  48 83 C4 20                 add     rsp, 20h
00007FF91DFF8EF5  5B                          pop     rbx
00007FF91DFF8EF6  E9 A5 95 02 00              jmp     sub_7FF91E0224A0
00007FF91DFF8EFB  49 8B 00                    mov     rax, [r8]
00007FF91DFF8EFE  33 C9                       xor     ecx, ecx
00007FF91DFF8F00  89 08                       mov     [rax], ecx
00007FF91DFF8F02  49 8B 40 08                 mov     rax, [r8+8]
00007FF91DFF8F06  89 08                       mov     [rax], ecx
00007FF91DFF8F08  48 8B CB                    mov     rcx, rbx
00007FF91DFF8F0B  E8 70 A4 FC FF              call    sub_7FF91DFC3380
00007FF91DFF8F10  48 8B CB                    mov     rcx, rbx
00007FF91DFF8F13  48 83 C4 20                 add     rsp, 20h
00007FF91DFF8F17  5B                          pop     rbx
00007FF91DFF8F18  E9 83 95 02 00              jmp     sub_7FF91E0224A0
00007FF91DFF8F1D  48 83 C4 20                 add     rsp, 20h
00007FF91DFF8F21  5B                          pop     rbx
00007FF91DFF8F22  C3                          retn
