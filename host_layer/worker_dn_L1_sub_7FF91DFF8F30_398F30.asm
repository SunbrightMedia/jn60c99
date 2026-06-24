; sub_7FF91DFF8F30 @ rva 0x398F30

00007FF91DFF8F30  40 53                       push    rbx
00007FF91DFF8F32  48 83 EC 20                 sub     rsp, 20h
00007FF91DFF8F36  80 79 14 00                 cmp     byte ptr [rcx+14h], 0
00007FF91DFF8F3A  48 8B D9                    mov     rbx, rcx
00007FF91DFF8F3D  0F 84 18 01 00 00           jz      loc_7FF91DFF905B
00007FF91DFF8F43  8B 81 08 30 A8 00           mov     eax, [rcx+0A83008h]
00007FF91DFF8F49  85 C0                       test    eax, eax
00007FF91DFF8F4B  7E 22                       jle     short loc_7FF91DFF8F6F
00007FF91DFF8F4D  FF C8                       dec     eax
00007FF91DFF8F4F  89 81 08 30 A8 00           mov     [rcx+0A83008h], eax
00007FF91DFF8F55  33 C9                       xor     ecx, ecx
00007FF91DFF8F57  49 8B 00                    mov     rax, [r8]
00007FF91DFF8F5A  89 08                       mov     [rax], ecx
00007FF91DFF8F5C  49 8B 40 08                 mov     rax, [r8+8]
00007FF91DFF8F60  89 08                       mov     [rax], ecx
00007FF91DFF8F62  48 8B CB                    mov     rcx, rbx
00007FF91DFF8F65  48 83 C4 20                 add     rsp, 20h
00007FF91DFF8F69  5B                          pop     rbx
00007FF91DFF8F6A  E9 31 95 02 00              jmp     sub_7FF91E0224A0
00007FF91DFF8F6F  49 8B 00                    mov     rax, [r8]
00007FF91DFF8F72  33 C9                       xor     ecx, ecx
00007FF91DFF8F74  89 08                       mov     [rax], ecx
00007FF91DFF8F76  49 8B 40 08                 mov     rax, [r8+8]
00007FF91DFF8F7A  89 08                       mov     [rax], ecx
00007FF91DFF8F7C  83 FA 07                    cmp     edx, 7; switch 8 cases
00007FF91DFF8F7F  0F 87 C9 00 00 00           ja      def_7FF91DFF8F99; jumptable 00007FF91DFF8F99 default case
00007FF91DFF8F85  48 63 C2                    movsxd  rax, edx
00007FF91DFF8F88  48 8D 15 71 70 C6 FF        lea     rdx, cs:7FF91DC60000h
00007FF91DFF8F8F  8B 8C 82 64 90 39 00        mov     ecx, ds:(jpt_7FF91DFF8F99 - 7FF91DC60000h)[rdx+rax*4]
00007FF91DFF8F96  48 03 CA                    add     rcx, rdx
00007FF91DFF8F99  FF E1                       jmp     rcx; switch jump
00007FF91DFF8F9B  49 8B D0                    mov     rdx, r8; jumptable 00007FF91DFF8F99 case 0
00007FF91DFF8F9E  48 8B CB                    mov     rcx, rbx
00007FF91DFF8FA1  E8 CA 00 FD FF              call    sub_7FF91DFC9070
00007FF91DFF8FA6  48 8B CB                    mov     rcx, rbx
00007FF91DFF8FA9  48 83 C4 20                 add     rsp, 20h
00007FF91DFF8FAD  5B                          pop     rbx
00007FF91DFF8FAE  E9 ED 94 02 00              jmp     sub_7FF91E0224A0
00007FF91DFF8FB3  49 8B D0                    mov     rdx, r8; jumptable 00007FF91DFF8F99 case 1
00007FF91DFF8FB6  48 8B CB                    mov     rcx, rbx
00007FF91DFF8FB9  E8 42 3E FD FF              call    sub_7FF91DFCCE00
00007FF91DFF8FBE  48 8B CB                    mov     rcx, rbx
00007FF91DFF8FC1  48 83 C4 20                 add     rsp, 20h
00007FF91DFF8FC5  5B                          pop     rbx
00007FF91DFF8FC6  E9 D5 94 02 00              jmp     sub_7FF91E0224A0
00007FF91DFF8FCB  49 8B D0                    mov     rdx, r8; jumptable 00007FF91DFF8F99 case 2
00007FF91DFF8FCE  48 8B CB                    mov     rcx, rbx
00007FF91DFF8FD1  E8 BA 7B FD FF              call    sub_7FF91DFD0B90
00007FF91DFF8FD6  48 8B CB                    mov     rcx, rbx
00007FF91DFF8FD9  48 83 C4 20                 add     rsp, 20h
00007FF91DFF8FDD  5B                          pop     rbx
00007FF91DFF8FDE  E9 BD 94 02 00              jmp     sub_7FF91E0224A0
00007FF91DFF8FE3  49 8B D0                    mov     rdx, r8; jumptable 00007FF91DFF8F99 case 3
00007FF91DFF8FE6  48 8B CB                    mov     rcx, rbx
00007FF91DFF8FE9  E8 12 B9 FD FF              call    sub_7FF91DFD4900
00007FF91DFF8FEE  48 8B CB                    mov     rcx, rbx
00007FF91DFF8FF1  48 83 C4 20                 add     rsp, 20h
00007FF91DFF8FF5  5B                          pop     rbx
00007FF91DFF8FF6  E9 A5 94 02 00              jmp     sub_7FF91E0224A0
00007FF91DFF8FFB  49 8B D0                    mov     rdx, r8; jumptable 00007FF91DFF8F99 case 4
00007FF91DFF8FFE  48 8B CB                    mov     rcx, rbx
00007FF91DFF9001  E8 8A F6 FD FF              call    sub_7FF91DFD8690
00007FF91DFF9006  48 8B CB                    mov     rcx, rbx
00007FF91DFF9009  48 83 C4 20                 add     rsp, 20h
00007FF91DFF900D  5B                          pop     rbx
00007FF91DFF900E  E9 8D 94 02 00              jmp     sub_7FF91E0224A0
00007FF91DFF9013  49 8B D0                    mov     rdx, r8; jumptable 00007FF91DFF8F99 case 5
00007FF91DFF9016  48 8B CB                    mov     rcx, rbx
00007FF91DFF9019  E8 02 34 FE FF              call    sub_7FF91DFDC420
00007FF91DFF901E  48 8B CB                    mov     rcx, rbx
00007FF91DFF9021  48 83 C4 20                 add     rsp, 20h
00007FF91DFF9025  5B                          pop     rbx
00007FF91DFF9026  E9 75 94 02 00              jmp     sub_7FF91E0224A0
00007FF91DFF902B  49 8B D0                    mov     rdx, r8; jumptable 00007FF91DFF8F99 case 6
00007FF91DFF902E  48 8B CB                    mov     rcx, rbx
00007FF91DFF9031  E8 5A 71 FE FF              call    sub_7FF91DFE0190
00007FF91DFF9036  48 8B CB                    mov     rcx, rbx
00007FF91DFF9039  48 83 C4 20                 add     rsp, 20h
00007FF91DFF903D  5B                          pop     rbx
00007FF91DFF903E  E9 5D 94 02 00              jmp     sub_7FF91E0224A0
00007FF91DFF9043  49 8B D0                    mov     rdx, r8; jumptable 00007FF91DFF8F99 case 7
00007FF91DFF9046  48 8B CB                    mov     rcx, rbx
00007FF91DFF9049  E8 D2 AE FE FF              call    sub_7FF91DFE3F20
00007FF91DFF904E  48 8B CB                    mov     rcx, rbx; jumptable 00007FF91DFF8F99 default case
00007FF91DFF9051  48 83 C4 20                 add     rsp, 20h
00007FF91DFF9055  5B                          pop     rbx
00007FF91DFF9056  E9 45 94 02 00              jmp     sub_7FF91E0224A0
00007FF91DFF905B  48 83 C4 20                 add     rsp, 20h
00007FF91DFF905F  5B                          pop     rbx
00007FF91DFF9060  C3                          retn
00007FF91DFF9061  0F 1F 00                    align 4
00007FF91DFF9064  9B 8F 39 00 B3 8F 39 00 CB 8F 39 00 E3 8F 39 00 FB 8F 39 00 13 90 39 00 2B 90 39 00 43 90 39 00  dd offset loc_7FF91DFF8F9B - 7FF91DC60000h; jump table for switch statement
