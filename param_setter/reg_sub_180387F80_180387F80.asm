; sub_180387F80 @ 0x180387F80 (RVA 0x387F80) size=0x168

0000000180387F80  48 89 4C 24 08              mov     [rsp+arg_0], rcx
0000000180387F85  53                          push    rbx
0000000180387F86  56                          push    rsi
0000000180387F87  57                          push    rdi
0000000180387F88  41 54                       push    r12
0000000180387F8A  41 55                       push    r13
0000000180387F8C  41 56                       push    r14
0000000180387F8E  41 57                       push    r15
0000000180387F90  48 83 EC 30                 sub     rsp, 30h
0000000180387F94  48 C7 44 24 20 FE FF FF FF  mov     [rsp+68h+var_48], 0FFFFFFFFFFFFFFFEh
0000000180387F9D  4D 8B E8                    mov     r13, r8
0000000180387FA0  4C 8B FA                    mov     r15, rdx
0000000180387FA3  48 8B F9                    mov     rdi, rcx
0000000180387FA6  4C 8B 11                    mov     r10, [rcx]
0000000180387FA9  4C 8B CA                    mov     r9, rdx
0000000180387FAC  4D 2B CA                    sub     r9, r10
0000000180387FAF  49 BB 67 66 66 66 66 66 66 66  mov     r11, 6666666666666667h
0000000180387FB9  49 8B C3                    mov     rax, r11
0000000180387FBC  49 F7 E9                    imul    r9
0000000180387FBF  4C 8B E2                    mov     r12, rdx
0000000180387FC2  49 C1 FC 04                 sar     r12, 4
0000000180387FC6  49 8B C4                    mov     rax, r12
0000000180387FC9  48 C1 E8 3F                 shr     rax, 3Fh
0000000180387FCD  4C 03 E0                    add     r12, rax
0000000180387FD0  48 8B 49 08                 mov     rcx, [rcx+8]
0000000180387FD4  49 2B CA                    sub     rcx, r10
0000000180387FD7  49 8B C3                    mov     rax, r11
0000000180387FDA  48 F7 E9                    imul    rcx
0000000180387FDD  48 C1 FA 04                 sar     rdx, 4
0000000180387FE1  48 8B C2                    mov     rax, rdx
0000000180387FE4  48 C1 E8 3F                 shr     rax, 3Fh
0000000180387FE8  48 03 D0                    add     rdx, rax
0000000180387FEB  49 B8 66 66 66 66 66 66 66 06  mov     r8, 666666666666666h
0000000180387FF5  49 3B D0                    cmp     rdx, r8
0000000180387FF8  0F 84 E4 00 00 00           jz      loc_1803880E2
0000000180387FFE  4C 8D 72 01                 lea     r14, [rdx+1]
0000000180388002  48 8B 4F 10                 mov     rcx, [rdi+10h]
0000000180388006  49 2B CA                    sub     rcx, r10
0000000180388009  49 8B C3                    mov     rax, r11
000000018038800C  48 F7 E9                    imul    rcx
000000018038800F  48 C1 FA 04                 sar     rdx, 4
0000000180388013  48 8B C2                    mov     rax, rdx
0000000180388016  48 C1 E8 3F                 shr     rax, 3Fh
000000018038801A  48 03 D0                    add     rdx, rax
000000018038801D  48 8B C2                    mov     rax, rdx
0000000180388020  48 D1 E8                    shr     rax, 1
0000000180388023  4C 2B C0                    sub     r8, rax
0000000180388026  49 3B D0                    cmp     rdx, r8
0000000180388029  76 05                       jbe     short loc_180388030
000000018038802B  49 8B DE                    mov     rbx, r14
000000018038802E  EB 0B                       jmp     short loc_18038803B
0000000180388030  48 8D 1C 10                 lea     rbx, [rax+rdx]
0000000180388034  49 3B DE                    cmp     rbx, r14
0000000180388037  49 0F 42 DE                 cmovb   rbx, r14
000000018038803B  48 89 5C 24 78              mov     [rsp+68h+arg_8], rbx
0000000180388040  48 8B D3                    mov     rdx, rbx
0000000180388043  48 8B CF                    mov     rcx, rdi
0000000180388046  E8 15 38 02 00              call    sub_1803AB860
000000018038804B  48 8B F0                    mov     rsi, rax
000000018038804E  48 89 84 24 88 00 00 00     mov     [rsp+68h+arg_18], rax
0000000180388056  4B 8D 0C A4                 lea     rcx, [r12+r12*4]
000000018038805A  4C 8D 24 CD 00 00 00 00     lea     r12, ds:0[rcx*8]
0000000180388062  41 0F 10 45 00              movups  xmm0, xmmword ptr [r13+0]
0000000180388067  41 0F 11 04 04              movups  xmmword ptr [r12+rax], xmm0
000000018038806C  41 0F 10 4D 10              movups  xmm1, xmmword ptr [r13+10h]
0000000180388071  41 0F 11 4C 04 10           movups  xmmword ptr [r12+rax+10h], xmm1
0000000180388077  F2 41 0F 10 45 20           movsd   xmm0, qword ptr [r13+20h]
000000018038807D  F2 41 0F 11 44 04 20        movsd   qword ptr [r12+rax+20h], xmm0
0000000180388084  4C 8B 47 08                 mov     r8, [rdi+8]
0000000180388088  48 8B 17                    mov     rdx, [rdi]
000000018038808B  48 8B C8                    mov     rcx, rax
000000018038808E  4D 3B F8                    cmp     r15, r8
0000000180388091  75 05                       jnz     short loc_180388098
0000000180388093  4C 2B C2                    sub     r8, rdx
0000000180388096  EB 1D                       jmp     short loc_1803880B5
0000000180388098  4D 8B C7                    mov     r8, r15
000000018038809B  4C 2B C2                    sub     r8, rdx
000000018038809E  E8 5D 5B 32 00              call    sub_1806ADC00
00000001803880A3  4C 8B 47 08                 mov     r8, [rdi+8]
00000001803880A7  49 8D 4C 24 28              lea     rcx, [r12+28h]
00000001803880AC  48 03 CE                    add     rcx, rsi
00000001803880AF  4D 2B C7                    sub     r8, r15
00000001803880B2  49 8B D7                    mov     rdx, r15
00000001803880B5  E8 46 5B 32 00              call    sub_1806ADC00
00000001803880BA  90                          nop
00000001803880BB  4C 8B CB                    mov     r9, rbx
00000001803880BE  4D 8B C6                    mov     r8, r14
00000001803880C1  48 8B D6                    mov     rdx, rsi
00000001803880C4  48 8B CF                    mov     rcx, rdi
00000001803880C7  E8 B4 34 02 00              call    sub_1803AB580
00000001803880CC  48 8B 07                    mov     rax, [rdi]
00000001803880CF  49 03 C4                    add     rax, r12
00000001803880D2  48 83 C4 30                 add     rsp, 30h
00000001803880D6  41 5F                       pop     r15
00000001803880D8  41 5E                       pop     r14
00000001803880DA  41 5D                       pop     r13
00000001803880DC  41 5C                       pop     r12
00000001803880DE  5F                          pop     rdi
00000001803880DF  5E                          pop     rsi
00000001803880E0  5B                          pop     rbx
00000001803880E1  C3                          retn
00000001803880E2  E8 39 37 02 00              call    ?_Xlen@?$vector@PEAXV?$allocator@PEAX@std@@@std@@IEBAXXZ_85; std::vector<void *>::_Xlen(void)
00000001803880E7  CC                          db 0CCh
