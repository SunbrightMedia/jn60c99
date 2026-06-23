; sub_1803ABA40 @ 0x1803ABA40 (RVA 0x3ABA40) size=0x33

00000001803ABA40  4C 8B C2                    mov     r8, rdx
00000001803ABA43  48 8B 51 08                 mov     rdx, [rcx+8]
00000001803ABA47  48 39 51 10                 cmp     [rcx+10h], rdx
00000001803ABA4B  74 21                       jz      short loc_1803ABA6E
00000001803ABA4D  41 0F 10 00                 movups  xmm0, xmmword ptr [r8]
00000001803ABA51  0F 11 02                    movups  xmmword ptr [rdx], xmm0
00000001803ABA54  41 0F 10 48 10              movups  xmm1, xmmword ptr [r8+10h]
00000001803ABA59  0F 11 4A 10                 movups  xmmword ptr [rdx+10h], xmm1
00000001803ABA5D  F2 41 0F 10 40 20           movsd   xmm0, qword ptr [r8+20h]
00000001803ABA63  F2 0F 11 42 20              movsd   qword ptr [rdx+20h], xmm0
00000001803ABA68  48 83 41 08 28              add     qword ptr [rcx+8], 28h ; '('
00000001803ABA6D  C3                          retn
00000001803ABA6E  E9 3D C2 FD FF              jmp     sub_180387CB0
