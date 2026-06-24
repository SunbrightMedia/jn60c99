; sub_7FF91E00BA00 @ rva 0x3ABA00

00007FF91E00BA00  4C 8B C2                    mov     r8, rdx
00007FF91E00BA03  48 8B 51 08                 mov     rdx, [rcx+8]
00007FF91E00BA07  48 39 51 10                 cmp     [rcx+10h], rdx
00007FF91E00BA0B  74 21                       jz      short loc_7FF91E00BA2E
00007FF91E00BA0D  41 0F 10 00                 movups  xmm0, xmmword ptr [r8]
00007FF91E00BA11  0F 11 02                    movups  xmmword ptr [rdx], xmm0
00007FF91E00BA14  41 0F 10 48 10              movups  xmm1, xmmword ptr [r8+10h]
00007FF91E00BA19  0F 11 4A 10                 movups  xmmword ptr [rdx+10h], xmm1
00007FF91E00BA1D  F2 41 0F 10 40 20           movsd   xmm0, qword ptr [r8+20h]
00007FF91E00BA23  F2 0F 11 42 20              movsd   qword ptr [rdx+20h], xmm0
00007FF91E00BA28  48 83 41 08 28              add     qword ptr [rcx+8], 28h ; '('
00007FF91E00BA2D  C3                          retn
00007FF91E00BA2E  E9 4D C5 FD FF              jmp     sub_7FF91DFE7F80
