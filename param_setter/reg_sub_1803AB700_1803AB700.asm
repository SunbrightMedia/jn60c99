; sub_1803AB700 @ 0x1803AB700 (RVA 0x3AB700) size=0x8C

00000001803AB700  48 89 54 24 10              mov     [rsp+arg_8], rdx
00000001803AB705  48 89 4C 24 08              mov     [rsp+arg_0], rcx
00000001803AB70A  56                          push    rsi
00000001803AB70B  57                          push    rdi
00000001803AB70C  41 56                       push    r14
00000001803AB70E  48 83 EC 30                 sub     rsp, 30h
00000001803AB712  48 C7 44 24 20 FE FF FF FF  mov     [rsp+48h+var_28], 0FFFFFFFFFFFFFFFEh
00000001803AB71B  48 89 5C 24 68              mov     [rsp+48h+arg_18], rbx
00000001803AB720  4C 8B F2                    mov     r14, rdx
00000001803AB723  48 8B D9                    mov     rbx, rcx
00000001803AB726  4C 8B 41 08                 mov     r8, [rcx+8]
00000001803AB72A  4C 2B 01                    sub     r8, [rcx]
00000001803AB72D  48 B8 67 66 66 66 66 66 66 66  mov     rax, 6666666666666667h
00000001803AB737  49 F7 E8                    imul    r8
00000001803AB73A  48 8B FA                    mov     rdi, rdx
00000001803AB73D  48 C1 FF 04                 sar     rdi, 4
00000001803AB741  48 8B C7                    mov     rax, rdi
00000001803AB744  48 C1 E8 3F                 shr     rax, 3Fh
00000001803AB748  48 03 F8                    add     rdi, rax
00000001803AB74B  49 8B D6                    mov     rdx, r14
00000001803AB74E  E8 0D 01 00 00              call    sub_1803AB860
00000001803AB753  48 8B F0                    mov     rsi, rax
00000001803AB756  48 89 44 24 60              mov     [rsp+48h+arg_10], rax
00000001803AB75B  4C 8B 43 08                 mov     r8, [rbx+8]
00000001803AB75F  48 8B 13                    mov     rdx, [rbx]
00000001803AB762  4C 2B C2                    sub     r8, rdx
00000001803AB765  48 8B C8                    mov     rcx, rax
00000001803AB768  E8 93 24 30 00              call    sub_1806ADC00
00000001803AB76D  90                          nop
00000001803AB76E  4D 8B CE                    mov     r9, r14
00000001803AB771  4C 8B C7                    mov     r8, rdi
00000001803AB774  48 8B D6                    mov     rdx, rsi
00000001803AB777  48 8B CB                    mov     rcx, rbx
00000001803AB77A  48 8B 5C 24 68              mov     rbx, [rsp+48h+arg_18]
00000001803AB77F  48 83 C4 30                 add     rsp, 30h
00000001803AB783  41 5E                       pop     r14
00000001803AB785  5F                          pop     rdi
00000001803AB786  5E                          pop     rsi
00000001803AB787  E9 F4 FD FF FF              jmp     sub_1803AB580
