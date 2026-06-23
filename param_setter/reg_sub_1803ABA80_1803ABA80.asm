; sub_1803ABA80 @ 0x1803ABA80 (RVA 0x3ABA80) size=0x23

00000001803ABA80  48 8B 51 08                 mov     rdx, [rcx+8]
00000001803ABA84  48 B8 67 66 66 66 66 66 66 66  mov     rax, 6666666666666667h
00000001803ABA8E  48 2B 11                    sub     rdx, [rcx]
00000001803ABA91  48 F7 EA                    imul    rdx
00000001803ABA94  48 C1 FA 04                 sar     rdx, 4
00000001803ABA98  48 8B C2                    mov     rax, rdx
00000001803ABA9B  48 C1 E8 3F                 shr     rax, 3Fh
00000001803ABA9F  48 03 C2                    add     rax, rdx
00000001803ABAA2  C3                          retn
