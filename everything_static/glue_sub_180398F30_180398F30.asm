; sub_180398F30 @ 0x180398F30 (RVA 0x398F30) size=0x154

0000000180398F30  40 53                       push    rbx
0000000180398F32  48 83 EC 20                 sub     rsp, 20h
0000000180398F36  80 79 14 00                 cmp     byte ptr [rcx+14h], 0
0000000180398F3A  48 8B D9                    mov     rbx, rcx
0000000180398F3D  0F 84 18 01 00 00           jz      loc_18039905B
0000000180398F43  8B 81 08 30 A8 00           mov     eax, [rcx+0A83008h]
0000000180398F49  85 C0                       test    eax, eax
0000000180398F4B  7E 22                       jle     short loc_180398F6F
0000000180398F4D  FF C8                       dec     eax
0000000180398F4F  89 81 08 30 A8 00           mov     [rcx+0A83008h], eax
0000000180398F55  33 C9                       xor     ecx, ecx
0000000180398F57  49 8B 00                    mov     rax, [r8]
0000000180398F5A  89 08                       mov     [rax], ecx
0000000180398F5C  49 8B 40 08                 mov     rax, [r8+8]
0000000180398F60  89 08                       mov     [rax], ecx
0000000180398F62  48 8B CB                    mov     rcx, rbx
0000000180398F65  48 83 C4 20                 add     rsp, 20h
0000000180398F69  5B                          pop     rbx
0000000180398F6A  E9 31 95 02 00              jmp     sub_1803C24A0
0000000180398F6F  49 8B 00                    mov     rax, [r8]
0000000180398F72  33 C9                       xor     ecx, ecx
0000000180398F74  89 08                       mov     [rax], ecx
0000000180398F76  49 8B 40 08                 mov     rax, [r8+8]
0000000180398F7A  89 08                       mov     [rax], ecx
0000000180398F7C  83 FA 07                    cmp     edx, 7; switch 8 cases
0000000180398F7F  0F 87 C9 00 00 00           ja      def_180398F99; jumptable 0000000180398F99 default case
0000000180398F85  48 63 C2                    movsxd  rax, edx
0000000180398F88  48 8D 15 71 70 C6 FF        lea     rdx, cs:180000000h
0000000180398F8F  8B 8C 82 64 90 39 00        mov     ecx, ds:(jpt_180398F99 - 180000000h)[rdx+rax*4]
0000000180398F96  48 03 CA                    add     rcx, rdx
0000000180398F99  FF E1                       jmp     rcx; switch jump
0000000180398F9B  49 8B D0                    mov     rdx, r8; jumptable 0000000180398F99 case 0
0000000180398F9E  48 8B CB                    mov     rcx, rbx
0000000180398FA1  E8 CA 00 FD FF              call    sub_180369070
0000000180398FA6  48 8B CB                    mov     rcx, rbx
0000000180398FA9  48 83 C4 20                 add     rsp, 20h
0000000180398FAD  5B                          pop     rbx
0000000180398FAE  E9 ED 94 02 00              jmp     sub_1803C24A0
0000000180398FB3  49 8B D0                    mov     rdx, r8; jumptable 0000000180398F99 case 1
0000000180398FB6  48 8B CB                    mov     rcx, rbx
0000000180398FB9  E8 42 3E FD FF              call    sub_18036CE00
0000000180398FBE  48 8B CB                    mov     rcx, rbx
0000000180398FC1  48 83 C4 20                 add     rsp, 20h
0000000180398FC5  5B                          pop     rbx
0000000180398FC6  E9 D5 94 02 00              jmp     sub_1803C24A0
0000000180398FCB  49 8B D0                    mov     rdx, r8; jumptable 0000000180398F99 case 2
0000000180398FCE  48 8B CB                    mov     rcx, rbx
0000000180398FD1  E8 BA 7B FD FF              call    sub_180370B90
0000000180398FD6  48 8B CB                    mov     rcx, rbx
0000000180398FD9  48 83 C4 20                 add     rsp, 20h
0000000180398FDD  5B                          pop     rbx
0000000180398FDE  E9 BD 94 02 00              jmp     sub_1803C24A0
0000000180398FE3  49 8B D0                    mov     rdx, r8; jumptable 0000000180398F99 case 3
0000000180398FE6  48 8B CB                    mov     rcx, rbx
0000000180398FE9  E8 12 B9 FD FF              call    sub_180374900
0000000180398FEE  48 8B CB                    mov     rcx, rbx
0000000180398FF1  48 83 C4 20                 add     rsp, 20h
0000000180398FF5  5B                          pop     rbx
0000000180398FF6  E9 A5 94 02 00              jmp     sub_1803C24A0
0000000180398FFB  49 8B D0                    mov     rdx, r8; jumptable 0000000180398F99 case 4
0000000180398FFE  48 8B CB                    mov     rcx, rbx
0000000180399001  E8 8A F6 FD FF              call    sub_180378690
0000000180399006  48 8B CB                    mov     rcx, rbx
0000000180399009  48 83 C4 20                 add     rsp, 20h
000000018039900D  5B                          pop     rbx
000000018039900E  E9 8D 94 02 00              jmp     sub_1803C24A0
0000000180399013  49 8B D0                    mov     rdx, r8; jumptable 0000000180398F99 case 5
0000000180399016  48 8B CB                    mov     rcx, rbx
0000000180399019  E8 02 34 FE FF              call    sub_18037C420
000000018039901E  48 8B CB                    mov     rcx, rbx
0000000180399021  48 83 C4 20                 add     rsp, 20h
0000000180399025  5B                          pop     rbx
0000000180399026  E9 75 94 02 00              jmp     sub_1803C24A0
000000018039902B  49 8B D0                    mov     rdx, r8; jumptable 0000000180398F99 case 6
000000018039902E  48 8B CB                    mov     rcx, rbx
0000000180399031  E8 5A 71 FE FF              call    sub_180380190
0000000180399036  48 8B CB                    mov     rcx, rbx
0000000180399039  48 83 C4 20                 add     rsp, 20h
000000018039903D  5B                          pop     rbx
000000018039903E  E9 5D 94 02 00              jmp     sub_1803C24A0
0000000180399043  49 8B D0                    mov     rdx, r8; jumptable 0000000180398F99 case 7
0000000180399046  48 8B CB                    mov     rcx, rbx
0000000180399049  E8 D2 AE FE FF              call    sub_180383F20
000000018039904E  48 8B CB                    mov     rcx, rbx; jumptable 0000000180398F99 default case
0000000180399051  48 83 C4 20                 add     rsp, 20h
0000000180399055  5B                          pop     rbx
0000000180399056  E9 45 94 02 00              jmp     sub_1803C24A0
000000018039905B  48 83 C4 20                 add     rsp, 20h
000000018039905F  5B                          pop     rbx
0000000180399060  C3                          retn
0000000180399061  0F 1F 00                    align 4
0000000180399064  9B 8F 39 00 B3 8F 39 00 CB 8F 39 00 E3 8F 39 00 FB 8F 39 00 13 90 39 00 2B 90 39 00 43 90 39 00  dd offset loc_180398F9B - 180000000h; jump table for switch statement
