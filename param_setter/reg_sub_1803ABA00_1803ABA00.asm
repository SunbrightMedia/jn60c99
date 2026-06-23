; sub_1803ABA00 @ 0x1803ABA00 (RVA 0x3ABA00) size=0x33

00000001803ABA00  4C 8B C2                    mov     r8, rdx
00000001803ABA03  48 8B 51 08                 mov     rdx, [rcx+8]
00000001803ABA07  48 39 51 10                 cmp     [rcx+10h], rdx
00000001803ABA0B  74 21                       jz      short loc_1803ABA2E
00000001803ABA0D  41 0F 10 00                 movups  xmm0, xmmword ptr [r8]
00000001803ABA11  0F 11 02                    movups  xmmword ptr [rdx], xmm0
00000001803ABA14  41 0F 10 48 10              movups  xmm1, xmmword ptr [r8+10h]
00000001803ABA19  0F 11 4A 10                 movups  xmmword ptr [rdx+10h], xmm1
00000001803ABA1D  F2 41 0F 10 40 20           movsd   xmm0, qword ptr [r8+20h]
00000001803ABA23  F2 0F 11 42 20              movsd   qword ptr [rdx+20h], xmm0
00000001803ABA28  48 83 41 08 28              add     qword ptr [rcx+8], 28h ; '('
00000001803ABA2D  C3                          retn
00000001803ABA2E  E9 4D C5 FD FF              jmp     sub_180387F80
