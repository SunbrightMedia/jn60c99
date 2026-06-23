; sub_7FF91DFD4900 @ 0x7FF91DFD4900 (RVA 0x7FF79DFD4900)

00007FF91DFD4900  48 8B C4                    mov     rax, rsp
00007FF91DFD4903  48 89 58 10                 mov     [rax+10h], rbx
00007FF91DFD4907  57                          push    rdi
00007FF91DFD4908  48 81 EC C0 00 00 00        sub     rsp, 0C0h
00007FF91DFD490F  F3 0F 10 A1 70 7C 00 00     movss   xmm4, dword ptr [rcx+7C70h]
00007FF91DFD4917  48 8B FA                    mov     rdi, rdx
00007FF91DFD491A  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
00007FF91DFD491E  48 8B D9                    mov     rbx, rcx
00007FF91DFD4921  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
00007FF91DFD4925  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00007FF91DFD492A  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00007FF91DFD492F  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00007FF91DFD4934  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00007FF91DFD4939  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00007FF91DFD493E  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00007FF91DFD4944  F3 44 0F 10 2D 67 07 77 00  movss   xmm13, cs:dword_7FF91E7450B4
00007FF91DFD494D  44 0F 2E A9 E0 8C 01 00     ucomiss xmm13, dword ptr [rcx+18CE0h]
00007FF91DFD4955  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00007FF91DFD495B  45 0F 57 F6                 xorps   xmm14, xmm14
00007FF91DFD495F  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
00007FF91DFD4969  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00007FF91DFD496F  75 16                       jnz     short loc_7FF91DFD4987
00007FF91DFD4971  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
00007FF91DFD497A  0F 57 E4                    xorps   xmm4, xmm4
00007FF91DFD497D  C7 81 70 7C 00 00 00 00 00 00  mov     dword ptr [rcx+7C70h], 0
00007FF91DFD4987  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
00007FF91DFD498F  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
00007FF91DFD4997  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
00007FF91DFD499F  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
00007FF91DFD49A7  F3 0F 59 05 15 64 61 00     mulss   xmm0, cs:dword_7FF91E5EADC4
00007FF91DFD49AF  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
00007FF91DFD49B7  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
00007FF91DFD49BF  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFD49C3  85 D2                       test    edx, edx
00007FF91DFD49C5  75 07                       jnz     short loc_7FF91DFD49CE
00007FF91DFD49C7  BA 01 00 00 00              mov     edx, 1
00007FF91DFD49CC  EB 24                       jmp     short loc_7FF91DFD49F2
00007FF91DFD49CE  8B C2                       mov     eax, edx
00007FF91DFD49D0  25 00 00 20 00              and     eax, 200000h
00007FF91DFD49D5  0F BA E2 17                 bt      edx, 17h
00007FF91DFD49D9  73 08                       jnb     short loc_7FF91DFD49E3
00007FF91DFD49DB  85 C0                       test    eax, eax
00007FF91DFD49DD  75 0C                       jnz     short loc_7FF91DFD49EB
00007FF91DFD49DF  03 D2                       add     edx, edx
00007FF91DFD49E1  EB 0F                       jmp     short loc_7FF91DFD49F2
00007FF91DFD49E3  85 C0                       test    eax, eax
00007FF91DFD49E5  74 04                       jz      short loc_7FF91DFD49EB
00007FF91DFD49E7  03 D2                       add     edx, edx
00007FF91DFD49E9  EB 07                       jmp     short loc_7FF91DFD49F2
00007FF91DFD49EB  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
00007FF91DFD49F2  F3 0F 10 9B 00 7C 00 00     movss   xmm3, dword ptr [rbx+7C00h]
00007FF91DFD49FA  8B C2                       mov     eax, edx
00007FF91DFD49FC  F3 0F 10 B3 E0 7B 00 00     movss   xmm6, dword ptr [rbx+7BE0h]
00007FF91DFD4A04  25 FF FF FF 00              and     eax, 0FFFFFFh
00007FF91DFD4A09  F3 44 0F 10 83 A0 7C 00 00  movss   xmm8, dword ptr [rbx+7CA0h]
00007FF91DFD4A12  8B CA                       mov     ecx, edx
00007FF91DFD4A14  F3 0F 10 BB B0 7C 00 00     movss   xmm7, dword ptr [rbx+7CB0h]
00007FF91DFD4A1C  81 CA 00 00 00 FF           or      edx, 0FF000000h
00007FF91DFD4A22  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD4A26  81 E1 00 00 00 01           and     ecx, 1000000h
00007FF91DFD4A2C  C7 83 E0 7C 00 00 00 00 00 00  mov     dword ptr [rbx+7CE0h], 0
00007FF91DFD4A36  F3 0F 11 9B 10 7C 00 00     movss   dword ptr [rbx+7C10h], xmm3
00007FF91DFD4A3E  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFD4A42  0F 44 D0                    cmovz   edx, eax
00007FF91DFD4A45  F3 0F 11 B3 F0 7B 00 00     movss   dword ptr [rbx+7BF0h], xmm6
00007FF91DFD4A4D  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
00007FF91DFD4A53  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
00007FF91DFD4A59  8B 83 20 7D 00 00           mov     eax, [rbx+7D20h]
00007FF91DFD4A5F  66 0F 6E C2                 movd    xmm0, edx
00007FF91DFD4A63  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFD4A66  89 83 30 7D 00 00           mov     [rbx+7D30h], eax
00007FF91DFD4A6C  F3 0F 11 A3 90 7C 00 00     movss   dword ptr [rbx+7C90h], xmm4
00007FF91DFD4A74  F3 0F 59 05 F4 61 61 00     mulss   xmm0, cs:dword_7FF91E5EAC70
00007FF91DFD4A7C  F3 44 0F 11 83 C0 7C 00 00  movss   dword ptr [rbx+7CC0h], xmm8
00007FF91DFD4A85  F3 0F 11 BB D0 7C 00 00     movss   dword ptr [rbx+7CD0h], xmm7
00007FF91DFD4A8D  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
00007FF91DFD4A95  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
00007FF91DFD4A9D  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
00007FF91DFD4AA5  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD4AA9  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
00007FF91DFD4AB1  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFD4AB5  F3 0F 10 93 40 7C 00 00     movss   xmm2, dword ptr [rbx+7C40h]
00007FF91DFD4ABD  F3 0F 11 93 50 7C 00 00     movss   dword ptr [rbx+7C50h], xmm2
00007FF91DFD4AC5  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD4AC9  F3 0F 10 83 20 7C 00 00     movss   xmm0, dword ptr [rbx+7C20h]
00007FF91DFD4AD1  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD4AD5  F3 0F 11 83 30 7C 00 00     movss   dword ptr [rbx+7C30h], xmm0
00007FF91DFD4ADD  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFD4AE1  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD4AE4  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
00007FF91DFD4AEC  F3 0F 10 8B 60 7C 00 00     movss   xmm1, dword ptr [rbx+7C60h]
00007FF91DFD4AF4  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD4AF8  F3 0F 59 F2                 mulss   xmm6, xmm2
00007FF91DFD4AFC  F3 0F 11 8B 80 7C 00 00     movss   dword ptr [rbx+7C80h], xmm1
00007FF91DFD4B04  F3 0F 11 93 F0 7C 00 00     movss   dword ptr [rbx+7CF0h], xmm2
00007FF91DFD4B0C  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFD4B10  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFD4B13  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD4B17  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD4B1B  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFD4B1F  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD4B23  F3 0F 11 B3 00 7D 00 00     movss   dword ptr [rbx+7D00h], xmm6
00007FF91DFD4B2B  F3 0F 11 9B 10 7D 00 00     movss   dword ptr [rbx+7D10h], xmm3
00007FF91DFD4B33  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD4B36  F3 0F 58 9B 50 7D 00 00     addss   xmm3, dword ptr [rbx+7D50h]
00007FF91DFD4B3E  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFD4B42  72 05                       jb      short loc_7FF91DFD4B49
00007FF91DFD4B44  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD4B47  EB 03                       jmp     short loc_7FF91DFD4B4C
00007FF91DFD4B49  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFD4B4C  41 0F 2E CE                 ucomiss xmm1, xmm14
00007FF91DFD4B50  F3 44 0F 10 3D 8B 09 77 00  movss   xmm15, cs:dword_7FF91E7454E4
00007FF91DFD4B59  75 06                       jnz     short loc_7FF91DFD4B61
00007FF91DFD4B5B  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD4B5F  EB 04                       jmp     short loc_7FF91DFD4B65
00007FF91DFD4B61  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFD4B65  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFD4B69  F3 0F 11 AB 20 7D 00 00     movss   dword ptr [rbx+7D20h], xmm5
00007FF91DFD4B71  73 06                       jnb     short loc_7FF91DFD4B79
00007FF91DFD4B73  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD4B77  EB 06                       jmp     short loc_7FF91DFD4B7F
00007FF91DFD4B79  76 04                       jbe     short loc_7FF91DFD4B7F
00007FF91DFD4B7B  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFD4B7F  F3 0F 10 83 90 7D 00 00     movss   xmm0, dword ptr [rbx+7D90h]
00007FF91DFD4B87  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFD4B8C  F3 0F 10 93 30 7E 00 00     movss   xmm2, dword ptr [rbx+7E30h]
00007FF91DFD4B94  F3 0F 10 8B A0 7D 00 00     movss   xmm1, dword ptr [rbx+7DA0h]
00007FF91DFD4B9C  8B 83 60 7D 00 00           mov     eax, [rbx+7D60h]
00007FF91DFD4BA2  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFD4BA5  F3 0F 10 A3 F0 7D 00 00     movss   xmm4, dword ptr [rbx+7DF0h]
00007FF91DFD4BAD  F3 0F 58 9B 40 7E 00 00     addss   xmm3, dword ptr [rbx+7E40h]
00007FF91DFD4BB5  F2 44 0F 10 25 E2 05 77 00  movsd   xmm12, cs:dbl_7FF91E7451A0
00007FF91DFD4BBE  F3 0F 11 AB 40 7D 00 00     movss   dword ptr [rbx+7D40h], xmm5
00007FF91DFD4BC6  F3 0F 11 AB 60 7D 00 00     movss   dword ptr [rbx+7D60h], xmm5
00007FF91DFD4BCE  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFD4BD2  89 83 70 7D 00 00           mov     [rbx+7D70h], eax
00007FF91DFD4BD8  F3 0F 11 A3 00 7E 00 00     movss   dword ptr [rbx+7E00h], xmm4
00007FF91DFD4BE0  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFD4BE4  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD4BE7  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD4BEB  F3 0F 10 8B D0 7D 00 00     movss   xmm1, dword ptr [rbx+7DD0h]
00007FF91DFD4BF3  F3 0F 58 83 50 7E 00 00     addss   xmm0, dword ptr [rbx+7E50h]
00007FF91DFD4BFB  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFD4C00  F3 0F 5E C8                 divss   xmm1, xmm0
00007FF91DFD4C04  F3 0F 10 83 60 7E 00 00     movss   xmm0, dword ptr [rbx+7E60h]
00007FF91DFD4C0C  F3 0F 59 AB 80 7D 00 00     mulss   xmm5, dword ptr [rbx+7D80h]
00007FF91DFD4C14  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD4C18  F3 0F 10 93 C0 7D 00 00     movss   xmm2, dword ptr [rbx+7DC0h]
00007FF91DFD4C20  F3 0F 11 AB 10 7E 00 00     movss   dword ptr [rbx+7E10h], xmm5
00007FF91DFD4C28  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFD4C2C  F3 0F 10 8B E0 7D 00 00     movss   xmm1, dword ptr [rbx+7DE0h]
00007FF91DFD4C34  F3 0F 58 D6                 addss   xmm2, xmm6
00007FF91DFD4C38  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFD4C3C  F3 0F 11 93 C0 7D 00 00     movss   dword ptr [rbx+7DC0h], xmm2
00007FF91DFD4C44  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD4C48  F3 0F 11 93 D0 7D 00 00     movss   dword ptr [rbx+7DD0h], xmm2
00007FF91DFD4C50  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFD4C54  F3 0F 5C E6                 subss   xmm4, xmm6
00007FF91DFD4C58  0F 54 25 31 0B 77 00        andps   xmm4, cs:xmmword_7FF91E745790
00007FF91DFD4C5F  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFD4C63  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD4C67  0F 83 E8 00 00 00           jnb     loc_7FF91DFD4D55
00007FF91DFD4C6D  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFD4C70  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFD4C73  41 0F 2E EE                 ucomiss xmm5, xmm14
00007FF91DFD4C77  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD4C7B  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFD4C7E  F3 0F 11 83 E0 7D 00 00     movss   dword ptr [rbx+7DE0h], xmm0
00007FF91DFD4C86  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFD4C8A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD4C8E  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD4C92  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD4C96  75 03                       jnz     short loc_7FF91DFD4C9B
00007FF91DFD4C98  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFD4C9B  8B 83 A0 7E 00 00           mov     eax, [rbx+7EA0h]
00007FF91DFD4CA1  48 8D 0D 58 B3 C8 FF        lea     rcx, cs:7FF91DC60000h
00007FF91DFD4CA8  F3 0F 59 BB 90 7E 00 00     mulss   xmm7, dword ptr [rbx+7E90h]
00007FF91DFD4CB0  89 83 B0 7E 00 00           mov     [rbx+7EB0h], eax
00007FF91DFD4CB6  F3 44 0F 59 83 80 7E 00 00  mulss   xmm8, dword ptr [rbx+7E80h]
00007FF91DFD4CBF  F3 0F 10 83 C0 7F 00 00     movss   xmm0, dword ptr [rbx+7FC0h]
00007FF91DFD4CC7  F3 0F 10 93 C0 7E 00 00     movss   xmm2, dword ptr [rbx+7EC0h]
00007FF91DFD4CCF  F3 44 0F 10 8B 20 7F 00 00  movss   xmm9, dword ptr [rbx+7F20h]
00007FF91DFD4CD8  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD4CDD  F3 44 0F 10 83 00 7F 00 00  movss   xmm8, dword ptr [rbx+7F00h]
00007FF91DFD4CE6  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFD4CEA  F3 0F 11 BB A0 7E 00 00     movss   dword ptr [rbx+7EA0h], xmm7
00007FF91DFD4CF2  F3 0F 10 BB E0 7E 00 00     movss   xmm7, dword ptr [rbx+7EE0h]
00007FF91DFD4CFA  F3 0F 11 8B F0 7D 00 00     movss   dword ptr [rbx+7DF0h], xmm1
00007FF91DFD4D02  F3 0F 11 8B 20 7E 00 00     movss   dword ptr [rbx+7E20h], xmm1
00007FF91DFD4D0A  F3 0F 10 8B 80 7F 00 00     movss   xmm1, dword ptr [rbx+7F80h]
00007FF91DFD4D12  F3 0F 11 BB F0 7E 00 00     movss   dword ptr [rbx+7EF0h], xmm7
00007FF91DFD4D1A  F3 0F 11 93 D0 7E 00 00     movss   dword ptr [rbx+7ED0h], xmm2
00007FF91DFD4D22  F3 44 0F 11 83 10 7F 00 00  movss   dword ptr [rbx+7F10h], xmm8
00007FF91DFD4D2B  F3 44 0F 11 8B 30 7F 00 00  movss   dword ptr [rbx+7F30h], xmm9
00007FF91DFD4D34  F3 0F 11 8B 90 7F 00 00     movss   dword ptr [rbx+7F90h], xmm1
00007FF91DFD4D3C  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFD4D3F  7D 2F                       jge     short loc_7FF91DFD4D70
00007FF91DFD4D41  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFD4D46  F7 D0                       not     eax
00007FF91DFD4D48  48 98                       cdqe
00007FF91DFD4D4A  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD4D53  EB 47                       jmp     short loc_7FF91DFD4D9C
00007FF91DFD4D55  F3 0F 58 8B 70 7E 00 00     addss   xmm1, dword ptr [rbx+7E70h]
00007FF91DFD4D5D  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFD4D61  0F 82 09 FF FF FF           jb      loc_7FF91DFD4C70
00007FF91DFD4D67  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFD4D6B  E9 03 FF FF FF              jmp     loc_7FF91DFD4C73
00007FF91DFD4D70  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFD4D73  7E 07                       jle     short loc_7FF91DFD4D7C
00007FF91DFD4D75  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFD4D7A  EB 15                       jmp     short loc_7FF91DFD4D91
00007FF91DFD4D7C  85 C0                       test    eax, eax
00007FF91DFD4D7E  79 0F                       jns     short loc_7FF91DFD4D8F
00007FF91DFD4D80  F7 D0                       not     eax
00007FF91DFD4D82  48 98                       cdqe
00007FF91DFD4D84  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD4D8D  EB 0D                       jmp     short loc_7FF91DFD4D9C
00007FF91DFD4D8F  7E 0B                       jle     short loc_7FF91DFD4D9C
00007FF91DFD4D91  48 98                       cdqe
00007FF91DFD4D93  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFD4D9C  0F 57 05 1D 0A 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD4DA3  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFD4DA7  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFD4DAA  7D 14                       jge     short loc_7FF91DFD4DC0
00007FF91DFD4DAC  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFD4DB1  F7 D0                       not     eax
00007FF91DFD4DB3  48 98                       cdqe
00007FF91DFD4DB5  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD4DBE  EB 2C                       jmp     short loc_7FF91DFD4DEC
00007FF91DFD4DC0  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFD4DC3  7E 07                       jle     short loc_7FF91DFD4DCC
00007FF91DFD4DC5  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFD4DCA  EB 15                       jmp     short loc_7FF91DFD4DE1
00007FF91DFD4DCC  85 C0                       test    eax, eax
00007FF91DFD4DCE  79 0F                       jns     short loc_7FF91DFD4DDF
00007FF91DFD4DD0  F7 D0                       not     eax
00007FF91DFD4DD2  48 98                       cdqe
00007FF91DFD4DD4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD4DDD  EB 0D                       jmp     short loc_7FF91DFD4DEC
00007FF91DFD4DDF  7E 0B                       jle     short loc_7FF91DFD4DEC
00007FF91DFD4DE1  48 98                       cdqe
00007FF91DFD4DE3  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFD4DEC  F3 0F 10 83 40 7F 00 00     movss   xmm0, dword ptr [rbx+7F40h]
00007FF91DFD4DF4  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFD4DF8  F3 0F 59 93 B0 7F 00 00     mulss   xmm2, dword ptr [rbx+7FB0h]
00007FF91DFD4E00  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD4E04  F3 0F 10 8B 70 7F 00 00     movss   xmm1, dword ptr [rbx+7F70h]
00007FF91DFD4E0C  F3 0F 11 93 80 7F 00 00     movss   dword ptr [rbx+7F80h], xmm2
00007FF91DFD4E14  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD4E18  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD4E1C  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD4E20  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD4E24  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFD4E28  76 05                       jbe     short loc_7FF91DFD4E2F
00007FF91DFD4E2A  0F 5A C2                    cvtps2pd xmm0, xmm2
00007FF91DFD4E2D  EB 03                       jmp     short loc_7FF91DFD4E32
00007FF91DFD4E2F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD4E32  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFD4E36  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFD4E3A  72 06                       jb      short loc_7FF91DFD4E42
00007FF91DFD4E3C  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFD4E40  EB 03                       jmp     short loc_7FF91DFD4E45
00007FF91DFD4E42  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFD4E45  F3 0F 10 B3 50 7F 00 00     movss   xmm6, dword ptr [rbx+7F50h]
00007FF91DFD4E4D  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD4E51  F3 0F 59 83 E0 7F 00 00     mulss   xmm0, dword ptr [rbx+7FE0h]; X
00007FF91DFD4E59  E8 E2 A8 37 00              call    expf
00007FF91DFD4E5E  F3 0F 59 83 D0 7F 00 00     mulss   xmm0, dword ptr [rbx+7FD0h]
00007FF91DFD4E66  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFD4E69  8B 83 50 81 00 00           mov     eax, [rbx+8150h]
00007FF91DFD4E6F  F3 0F 59 8B 60 7F 00 00     mulss   xmm1, dword ptr [rbx+7F60h]
00007FF91DFD4E77  89 83 60 81 00 00           mov     [rbx+8160h], eax
00007FF91DFD4E7D  F3 0F 58 83 F0 7F 00 00     addss   xmm0, dword ptr [rbx+7FF0h]
00007FF91DFD4E85  8B 83 70 81 00 00           mov     eax, [rbx+8170h]
00007FF91DFD4E8B  F3 0F 10 9B 10 81 00 00     movss   xmm3, dword ptr [rbx+8110h]
00007FF91DFD4E93  F3 0F 59 BB A0 82 00 00     mulss   xmm7, dword ptr [rbx+82A0h]
00007FF91DFD4E9B  89 83 80 81 00 00           mov     [rbx+8180h], eax
00007FF91DFD4EA1  8B 83 90 81 00 00           mov     eax, [rbx+8190h]
00007FF91DFD4EA7  F3 0F 10 93 00 81 00 00     movss   xmm2, dword ptr [rbx+8100h]
00007FF91DFD4EAF  F3 0F 10 A3 30 81 00 00     movss   xmm4, dword ptr [rbx+8130h]
00007FF91DFD4EB7  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFD4EBB  89 83 A0 81 00 00           mov     [rbx+81A0h], eax
00007FF91DFD4EC1  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
00007FF91DFD4EC7  F3 0F 11 9B 20 81 00 00     movss   dword ptr [rbx+8120h], xmm3
00007FF91DFD4ECF  F3 0F 5C CE                 subss   xmm1, xmm6
00007FF91DFD4ED3  F3 0F 11 93 10 81 00 00     movss   dword ptr [rbx+8110h], xmm2
00007FF91DFD4EDB  F3 0F 11 A3 40 81 00 00     movss   dword ptr [rbx+8140h], xmm4
00007FF91DFD4EE3  F3 44 0F 11 83 D0 80 00 00  movss   dword ptr [rbx+80D0h], xmm8
00007FF91DFD4EEC  F3 44 0F 11 8B E0 80 00 00  movss   dword ptr [rbx+80E0h], xmm9
00007FF91DFD4EF5  89 83 C0 80 00 00           mov     [rbx+80C0h], eax
00007FF91DFD4EFB  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD4EFF  F3 0F 10 83 70 82 00 00     movss   xmm0, dword ptr [rbx+8270h]
00007FF91DFD4F07  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFD4F0B  F3 0F 11 83 60 82 00 00     movss   dword ptr [rbx+8260h], xmm0
00007FF91DFD4F13  F3 0F 11 8B A0 7F 00 00     movss   dword ptr [rbx+7FA0h], xmm1
00007FF91DFD4F1B  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFD4F1F  73 06                       jnb     short loc_7FF91DFD4F27
00007FF91DFD4F21  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD4F25  EB 05                       jmp     short loc_7FF91DFD4F2C
00007FF91DFD4F27  F3 41 0F 5D FD              minss   xmm7, xmm13
00007FF91DFD4F2C  F3 0F 59 0D 8C 5E 61 00     mulss   xmm1, cs:dword_7FF91E5EADC0
00007FF91DFD4F34  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD4F38  F3 0F 10 B3 80 83 00 00     movss   xmm6, dword ptr [rbx+8380h]
00007FF91DFD4F40  F3 0F 5C C3                 subss   xmm0, xmm3
00007FF91DFD4F44  F3 0F 11 BB 00 81 00 00     movss   dword ptr [rbx+8100h], xmm7
00007FF91DFD4F4C  F3 0F 5D F1                 minss   xmm6, xmm1
00007FF91DFD4F50  F3 0F 59 83 B0 82 00 00     mulss   xmm0, dword ptr [rbx+82B0h]
00007FF91DFD4F58  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFD4F5C  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFD4F60  73 06                       jnb     short loc_7FF91DFD4F68
00007FF91DFD4F62  41 0F 28 C7                 movaps  xmm0, xmm15
00007FF91DFD4F66  EB 05                       jmp     short loc_7FF91DFD4F6D
00007FF91DFD4F68  F3 41 0F 5D C5              minss   xmm0, xmm13
00007FF91DFD4F6D  F3 0F 59 B3 90 83 00 00     mulss   xmm6, dword ptr [rbx+8390h]
00007FF91DFD4F75  F3 0F 5C D7                 subss   xmm2, xmm7
00007FF91DFD4F79  F3 0F 11 B3 B0 81 00 00     movss   dword ptr [rbx+81B0h], xmm6
00007FF91DFD4F81  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFD4F85  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFD4F89  73 03                       jnb     short loc_7FF91DFD4F8E
00007FF91DFD4F8B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD4F8E  F3 0F 10 8B 80 82 00 00     movss   xmm1, dword ptr [rbx+8280h]
00007FF91DFD4F96  F3 44 0F 10 9B C0 80 00 00  movss   xmm11, dword ptr [rbx+80C0h]
00007FF91DFD4F9F  F3 0F 11 83 10 81 00 00     movss   dword ptr [rbx+8110h], xmm0
00007FF91DFD4FA7  F3 0F 58 83 10 84 00 00     addss   xmm0, dword ptr [rbx+8410h]
00007FF91DFD4FAF  72 04                       jb      short loc_7FF91DFD4FB5
00007FF91DFD4FB1  41 0F 28 CD                 movaps  xmm1, xmm13
00007FF91DFD4FB5  F3 0F 59 83 00 84 00 00     mulss   xmm0, dword ptr [rbx+8400h]
00007FF91DFD4FBD  41 0F 28 FB                 movaps  xmm7, xmm11
00007FF91DFD4FC1  F3 0F 10 93 60 81 00 00     movss   xmm2, dword ptr [rbx+8160h]
00007FF91DFD4FC9  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFD4FCD  F3 0F 5C FA                 subss   xmm7, xmm2
00007FF91DFD4FD1  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD4FD5  F3 0F 59 B3 90 82 00 00     mulss   xmm6, dword ptr [rbx+8290h]
00007FF91DFD4FDD  76 05                       jbe     short loc_7FF91DFD4FE4
00007FF91DFD4FDF  0F 5A C8                    cvtps2pd xmm1, xmm0
00007FF91DFD4FE2  EB 03                       jmp     short loc_7FF91DFD4FE7
00007FF91DFD4FE4  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFD4FE7  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD4FEB  F3 0F 59 BB D0 84 00 00     mulss   xmm7, dword ptr [rbx+84D0h]
00007FF91DFD4FF3  F3 44 0F 10 0D EC 01 77 00  movss   xmm9, cs:flt_7FF91E7451E8
00007FF91DFD4FFC  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
00007FF91DFD5000  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFD5004  F3 0F 11 BB 50 81 00 00     movss   dword ptr [rbx+8150h], xmm7
00007FF91DFD500C  F3 0F 11 83 F0 80 00 00     movss   dword ptr [rbx+80F0h], xmm0
00007FF91DFD5014  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFD5018  F3 0F 59 BB C0 84 00 00     mulss   xmm7, dword ptr [rbx+84C0h]
00007FF91DFD5020  F3 0F 10 8B 40 83 00 00     movss   xmm1, dword ptr [rbx+8340h]
00007FF91DFD5028  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD502C  F3 0F 59 F9                 mulss   xmm7, xmm1
00007FF91DFD5030  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFD5034  F3 0F 10 83 40 81 00 00     movss   xmm0, dword ptr [rbx+8140h]
00007FF91DFD503C  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
00007FF91DFD5045  F3 41 0F 58 FB              addss   xmm7, xmm11
00007FF91DFD504A  76 1B                       jbe     short loc_7FF91DFD5067
00007FF91DFD504C  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD5051  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD5055  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD5058  E8 7B A4 37 00              call    fmodf
00007FF91DFD505D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD5060  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD5065  EB 1F                       jmp     short loc_7FF91DFD5086
00007FF91DFD5067  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD506B  73 19                       jnb     short loc_7FF91DFD5086
00007FF91DFD506D  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD5072  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD5076  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD5079  E8 5A A4 37 00              call    fmodf
00007FF91DFD507E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD5081  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD5086  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
00007FF91DFD508F  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD5092  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD5096  F3 44 0F 10 83 80 81 00 00  movss   xmm8, dword ptr [rbx+8180h]
00007FF91DFD509F  F3 0F 11 B3 30 81 00 00     movss   dword ptr [rbx+8130h], xmm6
00007FF91DFD50A7  F3 0F 59 BB B0 84 00 00     mulss   xmm7, dword ptr [rbx+84B0h]
00007FF91DFD50AF  F3 0F 58 83 20 84 00 00     addss   xmm0, dword ptr [rbx+8420h]
00007FF91DFD50B7  F3 0F 11 BB B0 80 00 00     movss   dword ptr [rbx+80B0h], xmm7
00007FF91DFD50BF  73 0A                       jnb     short loc_7FF91DFD50CB
00007FF91DFD50C1  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFD50C5  76 04                       jbe     short loc_7FF91DFD50CB
00007FF91DFD50C7  45 0F 28 C3                 movaps  xmm8, xmm11
00007FF91DFD50CB  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFD50CF  76 15                       jbe     short loc_7FF91DFD50E6
00007FF91DFD50D1  F3 41 0F 58 C5              addss   xmm0, xmm13; X
00007FF91DFD50D6  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD50DA  E8 F9 A3 37 00              call    fmodf
00007FF91DFD50DF  F3 41 0F 5C C5              subss   xmm0, xmm13
00007FF91DFD50E4  EB 19                       jmp     short loc_7FF91DFD50FF
00007FF91DFD50E6  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFD50EA  73 13                       jnb     short loc_7FF91DFD50FF
00007FF91DFD50EC  F3 41 0F 5C C5              subss   xmm0, xmm13; X
00007FF91DFD50F1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD50F5  E8 DE A3 37 00              call    fmodf
00007FF91DFD50FA  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD50FF  F3 44 0F 10 1D B8 06 77 00  movss   xmm11, dword ptr cs:xmmword_7FF91E7457C0
00007FF91DFD5108  F3 44 0F 11 83 70 81 00 00  movss   dword ptr [rbx+8170h], xmm8
00007FF91DFD5111  F3 0F 59 83 60 84 00 00     mulss   xmm0, dword ptr [rbx+8460h]
00007FF91DFD5119  F3 44 0F 59 83 A0 84 00 00  mulss   xmm8, dword ptr [rbx+84A0h]
00007FF91DFD5122  F3 0F 58 83 E0 84 00 00     addss   xmm0, dword ptr [rbx+84E0h]
00007FF91DFD512A  F3 0F 11 83 C0 81 00 00     movss   dword ptr [rbx+81C0h], xmm0
00007FF91DFD5132  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFD5136  F3 44 0F 11 83 10 82 00 00  movss   dword ptr [rbx+8210h], xmm8
00007FF91DFD513F  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFD5143  F3 44 0F 58 83 40 84 00 00  addss   xmm8, dword ptr [rbx+8440h]
00007FF91DFD514C  F3 0F 11 83 D0 81 00 00     movss   dword ptr [rbx+81D0h], xmm0
00007FF91DFD5154  45 0F 2F C5                 comiss  xmm8, xmm13
00007FF91DFD5158  76 1D                       jbe     short loc_7FF91DFD5177
00007FF91DFD515A  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD515F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD5163  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFD5167  E8 6C A3 37 00              call    fmodf
00007FF91DFD516C  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD5170  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFD5175  EB 21                       jmp     short loc_7FF91DFD5198
00007FF91DFD5177  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFD517B  73 1B                       jnb     short loc_7FF91DFD5198
00007FF91DFD517D  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFD5182  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD5186  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFD518A  E8 49 A3 37 00              call    fmodf
00007FF91DFD518F  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD5193  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD5198  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD519B  F3 0F 58 BB 30 84 00 00     addss   xmm7, dword ptr [rbx+8430h]
00007FF91DFD51A3  41 0F 2F FD                 comiss  xmm7, xmm13
00007FF91DFD51A7  76 1B                       jbe     short loc_7FF91DFD51C4
00007FF91DFD51A9  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD51AE  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD51B2  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFD51B5  E8 1E A3 37 00              call    fmodf
00007FF91DFD51BA  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFD51BD  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD51C2  EB 1F                       jmp     short loc_7FF91DFD51E3
00007FF91DFD51C4  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFD51C8  73 19                       jnb     short loc_7FF91DFD51E3
00007FF91DFD51CA  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD51CF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD51D3  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFD51D6  E8 FD A2 37 00              call    fmodf
00007FF91DFD51DB  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFD51DE  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD51E3  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFD51E7  E8 D4 3D FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD51EC  F3 0F 58 BB F0 84 00 00     addss   xmm7, dword ptr [rbx+84F0h]
00007FF91DFD51F4  F3 0F 59 83 80 84 00 00     mulss   xmm0, dword ptr [rbx+8480h]
00007FF91DFD51FC  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD5200  73 06                       jnb     short loc_7FF91DFD5208
00007FF91DFD5202  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD5206  EB 06                       jmp     short loc_7FF91DFD520E
00007FF91DFD5208  76 04                       jbe     short loc_7FF91DFD520E
00007FF91DFD520A  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD520E  F3 0F 58 B3 50 84 00 00     addss   xmm6, dword ptr [rbx+8450h]
00007FF91DFD5216  F3 0F 11 83 F0 81 00 00     movss   dword ptr [rbx+81F0h], xmm0
00007FF91DFD521E  F3 0F 11 BB 50 82 00 00     movss   dword ptr [rbx+8250h], xmm7
00007FF91DFD5226  F3 0F 59 BB 70 84 00 00     mulss   xmm7, dword ptr [rbx+8470h]
00007FF91DFD522E  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD5232  F3 0F 58 BB 00 85 00 00     addss   xmm7, dword ptr [rbx+8500h]
00007FF91DFD523A  76 1B                       jbe     short loc_7FF91DFD5257
00007FF91DFD523C  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD5241  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD5245  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD5248  E8 8B A2 37 00              call    fmodf
00007FF91DFD524D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD5250  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD5255  EB 1F                       jmp     short loc_7FF91DFD5276
00007FF91DFD5257  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD525B  73 19                       jnb     short loc_7FF91DFD5276
00007FF91DFD525D  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD5262  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD5266  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD5269  E8 6A A2 37 00              call    fmodf
00007FF91DFD526E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD5271  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD5276  0F 54 35 13 05 77 00        andps   xmm6, cs:xmmword_7FF91E745790
00007FF91DFD527D  F3 0F 11 BB E0 81 00 00     movss   dword ptr [rbx+81E0h], xmm7
00007FF91DFD5285  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFD5288  F3 0F 10 9B 20 83 00 00     movss   xmm3, dword ptr [rbx+8320h]
00007FF91DFD5290  0F 28 D6                    movaps  xmm2, xmm6
00007FF91DFD5293  F3 0F 59 93 B0 83 00 00     mulss   xmm2, dword ptr [rbx+83B0h]
00007FF91DFD529B  F3 0F 59 9B 10 82 00 00     mulss   xmm3, dword ptr [rbx+8210h]
00007FF91DFD52A3  F3 0F 58 93 A0 83 00 00     addss   xmm2, dword ptr [rbx+83A0h]
00007FF91DFD52AB  F3 0F 10 8B 10 83 00 00     movss   xmm1, dword ptr [rbx+8310h]
00007FF91DFD52B3  F3 0F 59 8B D0 81 00 00     mulss   xmm1, dword ptr [rbx+81D0h]
00007FF91DFD52BB  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFD52BF  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFD52C2  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFD52C6  F3 0F 59 83 C0 83 00 00     mulss   xmm0, dword ptr [rbx+83C0h]
00007FF91DFD52CE  F3 0F 59 F4                 mulss   xmm6, xmm4
00007FF91DFD52D2  F3 0F 59 A3 D0 83 00 00     mulss   xmm4, dword ptr [rbx+83D0h]
00007FF91DFD52DA  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD52DE  F3 0F 59 B3 E0 83 00 00     mulss   xmm6, dword ptr [rbx+83E0h]
00007FF91DFD52E6  F3 0F 10 83 00 83 00 00     movss   xmm0, dword ptr [rbx+8300h]
00007FF91DFD52EE  F3 0F 59 83 C0 81 00 00     mulss   xmm0, dword ptr [rbx+81C0h]
00007FF91DFD52F6  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFD52FA  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD52FE  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFD5302  F3 0F 10 A3 E0 82 00 00     movss   xmm4, dword ptr [rbx+82E0h]
00007FF91DFD530A  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD530E  F3 0F 58 B3 F0 83 00 00     addss   xmm6, dword ptr [rbx+83F0h]
00007FF91DFD5316  F3 0F 59 B3 90 84 00 00     mulss   xmm6, dword ptr [rbx+8490h]
00007FF91DFD531E  F3 0F 11 B3 00 82 00 00     movss   dword ptr [rbx+8200h], xmm6
00007FF91DFD5326  F3 0F 59 A3 F0 81 00 00     mulss   xmm4, dword ptr [rbx+81F0h]
00007FF91DFD532E  F3 0F 10 8B C0 82 00 00     movss   xmm1, dword ptr [rbx+82C0h]
00007FF91DFD5336  F3 0F 10 83 F0 82 00 00     movss   xmm0, dword ptr [rbx+82F0h]
00007FF91DFD533E  F3 0F 59 83 E0 81 00 00     mulss   xmm0, dword ptr [rbx+81E0h]
00007FF91DFD5346  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD534A  F3 0F 10 93 50 83 00 00     movss   xmm2, dword ptr [rbx+8350h]
00007FF91DFD5352  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFD5355  F3 0F 59 9B F0 80 00 00     mulss   xmm3, dword ptr [rbx+80F0h]
00007FF91DFD535D  F3 0F 59 B3 D0 82 00 00     mulss   xmm6, dword ptr [rbx+82D0h]
00007FF91DFD5365  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD5369  F3 0F 10 83 30 83 00 00     movss   xmm0, dword ptr [rbx+8330h]
00007FF91DFD5371  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFD5375  F3 0F 59 83 B0 80 00 00     mulss   xmm0, dword ptr [rbx+80B0h]
00007FF91DFD537D  F3 0F 58 E6                 addss   xmm4, xmm6
00007FF91DFD5381  F3 41 0F 58 DD              addss   xmm3, xmm13
00007FF91DFD5386  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD538A  F3 0F 11 9B 20 82 00 00     movss   dword ptr [rbx+8220h], xmm3
00007FF91DFD5392  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD5396  F3 0F 11 A3 40 82 00 00     movss   dword ptr [rbx+8240h], xmm4
00007FF91DFD539E  F3 0F 10 8B 60 83 00 00     movss   xmm1, dword ptr [rbx+8360h]
00007FF91DFD53A6  F3 0F 59 8B D0 80 00 00     mulss   xmm1, dword ptr [rbx+80D0h]
00007FF91DFD53AE  F3 0F 10 83 70 83 00 00     movss   xmm0, dword ptr [rbx+8370h]
00007FF91DFD53B6  F3 0F 59 83 E0 80 00 00     mulss   xmm0, dword ptr [rbx+80E0h]
00007FF91DFD53BE  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD53C2  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD53C6  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD53CA  F3 0F 11 8B 30 82 00 00     movss   dword ptr [rbx+8230h], xmm1
00007FF91DFD53D2  F3 0F 10 83 40 82 00 00     movss   xmm0, dword ptr [rbx+8240h]
00007FF91DFD53DA  8B 83 50 82 00 00           mov     eax, [rbx+8250h]
00007FF91DFD53E0  89 83 10 85 00 00           mov     [rbx+8510h], eax
00007FF91DFD53E6  F3 0F 11 83 20 85 00 00     movss   dword ptr [rbx+8520h], xmm0
00007FF91DFD53EE  44 0F 2F B3 50 82 00 00     comiss  xmm14, dword ptr [rbx+8250h]
00007FF91DFD53F6  F3 0F 10 8B 60 7D 00 00     movss   xmm1, dword ptr [rbx+7D60h]
00007FF91DFD53FE  F3 0F 10 93 30 85 00 00     movss   xmm2, dword ptr [rbx+8530h]
00007FF91DFD5406  73 06                       jnb     short loc_7FF91DFD540E
00007FF91DFD5408  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD540C  EB 03                       jmp     short loc_7FF91DFD5411
00007FF91DFD540E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD5411  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFD5415  75 04                       jnz     short loc_7FF91DFD541B
00007FF91DFD5417  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD541B  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD541F  F3 0F 11 8B 40 85 00 00     movss   dword ptr [rbx+8540h], xmm1
00007FF91DFD5427  8B 83 50 85 00 00           mov     eax, [rbx+8550h]
00007FF91DFD542D  89 83 60 85 00 00           mov     [rbx+8560h], eax
00007FF91DFD5433  8B 83 80 85 00 00           mov     eax, [rbx+8580h]
00007FF91DFD5439  89 83 90 85 00 00           mov     [rbx+8590h], eax
00007FF91DFD543F  8B 83 70 85 00 00           mov     eax, [rbx+8570h]
00007FF91DFD5445  89 83 80 85 00 00           mov     [rbx+8580h], eax
00007FF91DFD544B  8B 83 A0 85 00 00           mov     eax, [rbx+85A0h]
00007FF91DFD5451  89 83 B0 85 00 00           mov     [rbx+85B0h], eax
00007FF91DFD5457  8B 83 D0 85 00 00           mov     eax, [rbx+85D0h]
00007FF91DFD545D  89 83 E0 85 00 00           mov     [rbx+85E0h], eax
00007FF91DFD5463  F3 0F 10 83 80 86 00 00     movss   xmm0, dword ptr [rbx+8680h]
00007FF91DFD546B  F3 0F 58 8B 60 86 00 00     addss   xmm1, dword ptr [rbx+8660h]
00007FF91DFD5473  F3 0F 59 83 90 85 00 00     mulss   xmm0, dword ptr [rbx+8590h]
00007FF91DFD547B  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD547F  F3 0F 58 83 60 85 00 00     addss   xmm0, dword ptr [rbx+8560h]
00007FF91DFD5487  73 06                       jnb     short loc_7FF91DFD548F
00007FF91DFD5489  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFD548D  EB 04                       jmp     short loc_7FF91DFD5493
00007FF91DFD548F  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFD5493  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFD5497  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFD549C  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFD549F  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFD54A3  F3 0F 11 BB 70 85 00 00     movss   dword ptr [rbx+8570h], xmm7
00007FF91DFD54AB  0F 28 E7                    movaps  xmm4, xmm7
00007FF91DFD54AE  F3 0F 10 9B 50 86 00 00     movss   xmm3, dword ptr [rbx+8650h]
00007FF91DFD54B6  F3 0F 10 93 A0 86 00 00     movss   xmm2, dword ptr [rbx+86A0h]
00007FF91DFD54BE  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD54C1  F3 0F 59 8B C0 86 00 00     mulss   xmm1, dword ptr [rbx+86C0h]
00007FF91DFD54C9  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD54CC  F3 0F 58 A3 70 86 00 00     addss   xmm4, dword ptr [rbx+8670h]
00007FF91DFD54D4  F3 0F 5C BB 80 85 00 00     subss   xmm7, dword ptr [rbx+8580h]
00007FF91DFD54DC  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD54E0  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFD54E4  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD54E8  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD54EC  F3 0F 11 8B C0 85 00 00     movss   dword ptr [rbx+85C0h], xmm1
00007FF91DFD54F4  72 06                       jb      short loc_7FF91DFD54FC
00007FF91DFD54F6  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD54FA  EB 03                       jmp     short loc_7FF91DFD54FF
00007FF91DFD54FC  0F 57 F6                    xorps   xmm6, xmm6
00007FF91DFD54FF  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD5503  F3 0F 10 83 20 86 00 00     movss   xmm0, dword ptr [rbx+8620h]
00007FF91DFD550B  73 03                       jnb     short loc_7FF91DFD5510
00007FF91DFD550D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFD5510  F3 0F 59 83 A0 86 00 00     mulss   xmm0, dword ptr [rbx+86A0h]
00007FF91DFD5518  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFD551B  F3 0F 10 93 10 86 00 00     movss   xmm2, dword ptr [rbx+8610h]
00007FF91DFD5523  F3 44 0F 10 0D 30 FA 76 00  movss   xmm9, cs:dword_7FF91E744F5C
00007FF91DFD552C  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFD5530  F3 0F 11 B3 80 85 00 00     movss   dword ptr [rbx+8580h], xmm6
00007FF91DFD5538  F3 0F 10 8B B0 86 00 00     movss   xmm1, dword ptr [rbx+86B0h]
00007FF91DFD5540  F3 0F 10 BB 30 86 00 00     movss   xmm7, dword ptr [rbx+8630h]
00007FF91DFD5548  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD554B  F3 0F 10 A3 B0 85 00 00     movss   xmm4, dword ptr [rbx+85B0h]
00007FF91DFD5553  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD5557  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFD555C  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD5560  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFD5565  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD5569  F3 0F 59 FE                 mulss   xmm7, xmm6
00007FF91DFD556D  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFD5571  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD5575  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFD5579  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD557C  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFD5580  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD5584  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD5588  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFD558C  76 0B                       jbe     short loc_7FF91DFD5599
00007FF91DFD558E  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD5591  F3 0F 58 9B C0 85 00 00     addss   xmm3, dword ptr [rbx+85C0h]
00007FF91DFD5599  F3 0F 10 83 A0 86 00 00     movss   xmm0, dword ptr [rbx+86A0h]
00007FF91DFD55A1  F3 0F 10 A3 60 85 00 00     movss   xmm4, dword ptr [rbx+8560h]
00007FF91DFD55A9  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFD55AD  F3 0F 11 83 A0 85 00 00     movss   dword ptr [rbx+85A0h], xmm0
00007FF91DFD55B5  F3 0F 10 8B E0 85 00 00     movss   xmm1, dword ptr [rbx+85E0h]
00007FF91DFD55BD  F3 0F 10 9B 40 86 00 00     movss   xmm3, dword ptr [rbx+8640h]
00007FF91DFD55C5  F3 0F 59 AB 90 86 00 00     mulss   xmm5, dword ptr [rbx+8690h]
00007FF91DFD55CD  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFD55D2  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFD55D6  F3 0F 10 83 D0 86 00 00     movss   xmm0, dword ptr [rbx+86D0h]
00007FF91DFD55DE  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD55E3  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFD55E6  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD55EA  F3 0F 58 EE                 addss   xmm5, xmm6
00007FF91DFD55EE  F3 0F 59 D7                 mulss   xmm2, xmm7
00007FF91DFD55F2  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFD55F6  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD55FA  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD55FE  F3 0F 11 93 D0 85 00 00     movss   dword ptr [rbx+85D0h], xmm2
00007FF91DFD5606  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFD560B  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFD5610  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD5614  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD5618  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD561C  F3 0F 11 9B 50 85 00 00     movss   dword ptr [rbx+8550h], xmm3
00007FF91DFD5624  F3 0F 59 9B E0 86 00 00     mulss   xmm3, dword ptr [rbx+86E0h]
00007FF91DFD562C  F3 0F 59 9B F0 86 00 00     mulss   xmm3, dword ptr [rbx+86F0h]
00007FF91DFD5634  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD5637  F3 0F 59 83 00 87 00 00     mulss   xmm0, dword ptr [rbx+8700h]
00007FF91DFD563F  F3 0F 11 9B F0 85 00 00     movss   dword ptr [rbx+85F0h], xmm3
00007FF91DFD5647  F3 0F 11 83 00 86 00 00     movss   dword ptr [rbx+8600h], xmm0
00007FF91DFD564F  44 0F 2F B3 50 82 00 00     comiss  xmm14, dword ptr [rbx+8250h]
00007FF91DFD5657  F3 0F 10 8B 60 7D 00 00     movss   xmm1, dword ptr [rbx+7D60h]
00007FF91DFD565F  F3 0F 10 93 10 87 00 00     movss   xmm2, dword ptr [rbx+8710h]
00007FF91DFD5667  73 06                       jnb     short loc_7FF91DFD566F
00007FF91DFD5669  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD566D  EB 03                       jmp     short loc_7FF91DFD5672
00007FF91DFD566F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD5672  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFD5676  75 04                       jnz     short loc_7FF91DFD567C
00007FF91DFD5678  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD567C  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD5680  F3 0F 11 8B 20 87 00 00     movss   dword ptr [rbx+8720h], xmm1
00007FF91DFD5688  8B 83 30 87 00 00           mov     eax, [rbx+8730h]
00007FF91DFD568E  89 83 40 87 00 00           mov     [rbx+8740h], eax
00007FF91DFD5694  8B 83 60 87 00 00           mov     eax, [rbx+8760h]
00007FF91DFD569A  89 83 70 87 00 00           mov     [rbx+8770h], eax
00007FF91DFD56A0  8B 83 50 87 00 00           mov     eax, [rbx+8750h]
00007FF91DFD56A6  89 83 60 87 00 00           mov     [rbx+8760h], eax
00007FF91DFD56AC  8B 83 80 87 00 00           mov     eax, [rbx+8780h]
00007FF91DFD56B2  89 83 90 87 00 00           mov     [rbx+8790h], eax
00007FF91DFD56B8  8B 83 B0 87 00 00           mov     eax, [rbx+87B0h]
00007FF91DFD56BE  89 83 C0 87 00 00           mov     [rbx+87C0h], eax
00007FF91DFD56C4  F3 0F 10 83 60 88 00 00     movss   xmm0, dword ptr [rbx+8860h]
00007FF91DFD56CC  F3 0F 58 8B 40 88 00 00     addss   xmm1, dword ptr [rbx+8840h]
00007FF91DFD56D4  F3 0F 59 83 70 87 00 00     mulss   xmm0, dword ptr [rbx+8770h]
00007FF91DFD56DC  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD56E0  F3 0F 58 83 40 87 00 00     addss   xmm0, dword ptr [rbx+8740h]
00007FF91DFD56E8  73 06                       jnb     short loc_7FF91DFD56F0
00007FF91DFD56EA  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFD56EE  EB 04                       jmp     short loc_7FF91DFD56F4
00007FF91DFD56F0  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFD56F4  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFD56F8  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFD56FD  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFD5700  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFD5704  F3 0F 11 B3 50 87 00 00     movss   dword ptr [rbx+8750h], xmm6
00007FF91DFD570C  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFD570F  F3 0F 10 9B 30 88 00 00     movss   xmm3, dword ptr [rbx+8830h]
00007FF91DFD5717  F3 0F 10 93 80 88 00 00     movss   xmm2, dword ptr [rbx+8880h]
00007FF91DFD571F  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD5722  F3 0F 59 8B A0 88 00 00     mulss   xmm1, dword ptr [rbx+88A0h]
00007FF91DFD572A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD572D  F3 0F 58 A3 50 88 00 00     addss   xmm4, dword ptr [rbx+8850h]
00007FF91DFD5735  F3 0F 5C B3 60 87 00 00     subss   xmm6, dword ptr [rbx+8760h]
00007FF91DFD573D  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD5741  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFD5745  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD5749  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD574D  F3 0F 11 8B A0 87 00 00     movss   dword ptr [rbx+87A0h], xmm1
00007FF91DFD5755  72 06                       jb      short loc_7FF91DFD575D
00007FF91DFD5757  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD575B  EB 03                       jmp     short loc_7FF91DFD5760
00007FF91DFD575D  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD5760  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFD5764  F3 0F 10 83 00 88 00 00     movss   xmm0, dword ptr [rbx+8800h]
00007FF91DFD576C  73 03                       jnb     short loc_7FF91DFD5771
00007FF91DFD576E  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFD5771  F3 0F 59 83 80 88 00 00     mulss   xmm0, dword ptr [rbx+8880h]
00007FF91DFD5779  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFD577C  F3 0F 10 93 F0 87 00 00     movss   xmm2, dword ptr [rbx+87F0h]
00007FF91DFD5784  F3 0F 11 BB 60 87 00 00     movss   dword ptr [rbx+8760h], xmm7
00007FF91DFD578C  F3 0F 10 8B 90 88 00 00     movss   xmm1, dword ptr [rbx+8890h]
00007FF91DFD5794  F3 0F 10 B3 10 88 00 00     movss   xmm6, dword ptr [rbx+8810h]
00007FF91DFD579C  F3 0F 10 A3 90 87 00 00     movss   xmm4, dword ptr [rbx+8790h]
00007FF91DFD57A4  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFD57A8  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD57AB  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD57AF  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFD57B4  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD57B8  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFD57BD  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD57C1  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFD57C5  F3 0F 5C C7                 subss   xmm0, xmm7
00007FF91DFD57C9  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD57CD  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFD57D1  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD57D4  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFD57D8  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD57DC  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD57E0  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFD57E4  76 0B                       jbe     short loc_7FF91DFD57F1
00007FF91DFD57E6  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD57E9  F3 0F 58 9B A0 87 00 00     addss   xmm3, dword ptr [rbx+87A0h]
00007FF91DFD57F1  F3 0F 10 A3 40 87 00 00     movss   xmm4, dword ptr [rbx+8740h]
00007FF91DFD57F9  F3 0F 10 83 80 88 00 00     movss   xmm0, dword ptr [rbx+8880h]
00007FF91DFD5801  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFD5805  F3 0F 11 83 80 87 00 00     movss   dword ptr [rbx+8780h], xmm0
00007FF91DFD580D  F3 0F 59 AB 70 88 00 00     mulss   xmm5, dword ptr [rbx+8870h]
00007FF91DFD5815  F3 0F 10 8B C0 87 00 00     movss   xmm1, dword ptr [rbx+87C0h]
00007FF91DFD581D  F3 0F 10 9B 20 88 00 00     movss   xmm3, dword ptr [rbx+8820h]
00007FF91DFD5825  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFD5829  F3 0F 10 83 B0 88 00 00     movss   xmm0, dword ptr [rbx+88B0h]
00007FF91DFD5831  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFD5834  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFD5839  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD583D  F3 0F 58 EF                 addss   xmm5, xmm7
00007FF91DFD5841  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD5846  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD584A  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFD584E  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD5852  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD5856  F3 0F 11 93 B0 87 00 00     movss   dword ptr [rbx+87B0h], xmm2
00007FF91DFD585E  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFD5863  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFD5868  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD586C  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD5870  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD5874  F3 0F 11 9B 30 87 00 00     movss   dword ptr [rbx+8730h], xmm3
00007FF91DFD587C  F3 0F 59 9B C0 88 00 00     mulss   xmm3, dword ptr [rbx+88C0h]
00007FF91DFD5884  F3 0F 59 9B D0 88 00 00     mulss   xmm3, dword ptr [rbx+88D0h]
00007FF91DFD588C  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD588F  F3 0F 59 83 E0 88 00 00     mulss   xmm0, dword ptr [rbx+88E0h]
00007FF91DFD5897  F3 0F 11 9B D0 87 00 00     movss   dword ptr [rbx+87D0h], xmm3
00007FF91DFD589F  F3 0F 11 83 E0 87 00 00     movss   dword ptr [rbx+87E0h], xmm0
00007FF91DFD58A7  8B 83 F0 88 00 00           mov     eax, [rbx+88F0h]
00007FF91DFD58AD  89 83 00 89 00 00           mov     [rbx+8900h], eax
00007FF91DFD58B3  8B 83 10 89 00 00           mov     eax, [rbx+8910h]
00007FF91DFD58B9  89 83 20 89 00 00           mov     [rbx+8920h], eax
00007FF91DFD58BF  F3 0F 10 83 20 7E 00 00     movss   xmm0, dword ptr [rbx+7E20h]
00007FF91DFD58C7  F3 44 0F 10 83 A0 7E 00 00  movss   xmm8, dword ptr [rbx+7EA0h]
00007FF91DFD58D0  8B 83 50 89 00 00           mov     eax, [rbx+8950h]
00007FF91DFD58D6  89 83 60 89 00 00           mov     [rbx+8960h], eax
00007FF91DFD58DC  F3 0F 59 83 30 89 00 00     mulss   xmm0, dword ptr [rbx+8930h]
00007FF91DFD58E4  F3 44 0F 59 83 40 89 00 00  mulss   xmm8, dword ptr [rbx+8940h]
00007FF91DFD58ED  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFD58F2  F3 44 0F 11 83 50 89 00 00  movss   dword ptr [rbx+8950h], xmm8
00007FF91DFD58FB  F3 0F 10 BB 30 82 00 00     movss   xmm7, dword ptr [rbx+8230h]
00007FF91DFD5903  F3 0F 10 8B F0 85 00 00     movss   xmm1, dword ptr [rbx+85F0h]
00007FF91DFD590B  F3 0F 10 93 D0 87 00 00     movss   xmm2, dword ptr [rbx+87D0h]
00007FF91DFD5913  F3 0F 10 83 20 7E 00 00     movss   xmm0, dword ptr [rbx+7E20h]
00007FF91DFD591B  8B 83 10 89 00 00           mov     eax, [rbx+8910h]
00007FF91DFD5921  89 83 90 89 00 00           mov     [rbx+8990h], eax
00007FF91DFD5927  F3 0F 11 83 A0 89 00 00     movss   dword ptr [rbx+89A0h], xmm0
00007FF91DFD592F  F3 0F 10 A3 E0 8A 00 00     movss   xmm4, dword ptr [rbx+8AE0h]
00007FF91DFD5937  F3 0F 11 8B 70 89 00 00     movss   dword ptr [rbx+8970h], xmm1
00007FF91DFD593F  F3 0F 11 93 80 89 00 00     movss   dword ptr [rbx+8980h], xmm2
00007FF91DFD5947  F3 0F 10 AB C0 8A 00 00     movss   xmm5, dword ptr [rbx+8AC0h]
00007FF91DFD594F  F3 0F 59 FC                 mulss   xmm7, xmm4
00007FF91DFD5953  F3 0F 59 A3 40 82 00 00     mulss   xmm4, dword ptr [rbx+8240h]
00007FF91DFD595B  F3 0F 11 A3 B0 89 00 00     movss   dword ptr [rbx+89B0h], xmm4
00007FF91DFD5963  F3 0F 10 8B 40 8A 00 00     movss   xmm1, dword ptr [rbx+8A40h]
00007FF91DFD596B  F3 0F 10 93 40 8B 00 00     movss   xmm2, dword ptr [rbx+8B40h]
00007FF91DFD5973  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFD5976  F3 0F 59 BB F0 8A 00 00     mulss   xmm7, dword ptr [rbx+8AF0h]
00007FF91DFD597E  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD5981  F3 0F 10 B3 00 8B 00 00     movss   xmm6, dword ptr [rbx+8B00h]
00007FF91DFD5989  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD598D  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFD5991  F3 0F 59 EC                 mulss   xmm5, xmm4
00007FF91DFD5995  F3 0F 59 AB D0 8A 00 00     mulss   xmm5, dword ptr [rbx+8AD0h]
00007FF91DFD599D  F3 0F 11 AB D0 89 00 00     movss   dword ptr [rbx+89D0h], xmm5
00007FF91DFD59A5  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFD59A9  F3 0F 59 9B 90 89 00 00     mulss   xmm3, dword ptr [rbx+8990h]
00007FF91DFD59B1  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD59B5  F3 0F 10 83 50 8A 00 00     movss   xmm0, dword ptr [rbx+8A50h]
00007FF91DFD59BD  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD59C1  F3 0F 59 9B 50 8B 00 00     mulss   xmm3, dword ptr [rbx+8B50h]
00007FF91DFD59C9  F3 0F 11 9B E0 89 00 00     movss   dword ptr [rbx+89E0h], xmm3
00007FF91DFD59D1  F3 0F 10 8B 20 8B 00 00     movss   xmm1, dword ptr [rbx+8B20h]
00007FF91DFD59D9  F3 0F 59 8B 80 89 00 00     mulss   xmm1, dword ptr [rbx+8980h]
00007FF91DFD59E1  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD59E5  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFD59E9  F3 0F 10 83 10 8B 00 00     movss   xmm0, dword ptr [rbx+8B10h]
00007FF91DFD59F1  F3 0F 59 83 70 89 00 00     mulss   xmm0, dword ptr [rbx+8970h]
00007FF91DFD59F9  F3 0F 10 9B B0 89 00 00     movss   xmm3, dword ptr [rbx+89B0h]
00007FF91DFD5A01  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD5A05  F3 0F 10 83 30 8A 00 00     movss   xmm0, dword ptr [rbx+8A30h]
00007FF91DFD5A0D  F3 0F 59 8B 30 8B 00 00     mulss   xmm1, dword ptr [rbx+8B30h]
00007FF91DFD5A15  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFD5A19  F3 41 0F 58 C8              addss   xmm1, xmm8
00007FF91DFD5A1E  F3 0F 58 8B A0 8A 00 00     addss   xmm1, dword ptr [rbx+8AA0h]
00007FF91DFD5A26  F3 0F 58 8B B0 8A 00 00     addss   xmm1, dword ptr [rbx+8AB0h]
00007FF91DFD5A2E  F3 0F 11 8B F0 89 00 00     movss   dword ptr [rbx+89F0h], xmm1
00007FF91DFD5A36  F3 0F 11 83 00 8A 00 00     movss   dword ptr [rbx+8A00h], xmm0
00007FF91DFD5A3E  F3 0F 59 9B 70 8B 00 00     mulss   xmm3, dword ptr [rbx+8B70h]
00007FF91DFD5A46  F3 0F 10 83 70 8A 00 00     movss   xmm0, dword ptr [rbx+8A70h]
00007FF91DFD5A4E  F3 0F 59 83 70 89 00 00     mulss   xmm0, dword ptr [rbx+8970h]
00007FF91DFD5A56  F3 0F 58 9B 80 8B 00 00     addss   xmm3, dword ptr [rbx+8B80h]
00007FF91DFD5A5E  F3 0F 10 8B 80 8A 00 00     movss   xmm1, dword ptr [rbx+8A80h]
00007FF91DFD5A66  F3 0F 59 8B 80 89 00 00     mulss   xmm1, dword ptr [rbx+8980h]
00007FF91DFD5A6E  F3 0F 10 93 D0 89 00 00     movss   xmm2, dword ptr [rbx+89D0h]
00007FF91DFD5A76  F3 0F 59 9B 60 8A 00 00     mulss   xmm3, dword ptr [rbx+8A60h]
00007FF91DFD5A7E  F3 0F 58 93 A0 89 00 00     addss   xmm2, dword ptr [rbx+89A0h]
00007FF91DFD5A86  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD5A8A  F3 0F 58 93 E0 89 00 00     addss   xmm2, dword ptr [rbx+89E0h]
00007FF91DFD5A92  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD5A96  F3 0F 58 9B 90 8A 00 00     addss   xmm3, dword ptr [rbx+8A90h]
00007FF91DFD5A9E  F3 0F 59 9B 60 8B 00 00     mulss   xmm3, dword ptr [rbx+8B60h]
00007FF91DFD5AA6  F3 0F 11 9B 10 8A 00 00     movss   dword ptr [rbx+8A10h], xmm3
00007FF91DFD5AAE  F3 0F 11 93 20 8A 00 00     movss   dword ptr [rbx+8A20h], xmm2
00007FF91DFD5AB6  F3 0F 10 83 A0 8B 00 00     movss   xmm0, dword ptr [rbx+8BA0h]
00007FF91DFD5ABE  8B 83 90 8B 00 00           mov     eax, [rbx+8B90h]
00007FF91DFD5AC4  89 83 C0 8B 00 00           mov     [rbx+8BC0h], eax
00007FF91DFD5ACA  F3 0F 11 83 D0 8B 00 00     movss   dword ptr [rbx+8BD0h], xmm0
00007FF91DFD5AD2  8B 83 B0 8B 00 00           mov     eax, [rbx+8BB0h]
00007FF91DFD5AD8  89 83 E0 8B 00 00           mov     [rbx+8BE0h], eax
00007FF91DFD5ADE  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
00007FF91DFD5AE6  8B 83 00 8C 00 00           mov     eax, [rbx+8C00h]
00007FF91DFD5AEC  89 83 10 8C 00 00           mov     [rbx+8C10h], eax
00007FF91DFD5AF2  F3 0F 10 93 F0 8B 00 00     movss   xmm2, dword ptr [rbx+8BF0h]
00007FF91DFD5AFA  F3 0F 11 93 00 8C 00 00     movss   dword ptr [rbx+8C00h], xmm2
00007FF91DFD5B02  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD5B05  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD5B08  F3 0F 59 9B 20 8C 00 00     mulss   xmm3, dword ptr [rbx+8C20h]
00007FF91DFD5B10  F3 0F 58 9B 10 8C 00 00     addss   xmm3, dword ptr [rbx+8C10h]
00007FF91DFD5B18  F3 0F 11 9B 00 8C 00 00     movss   dword ptr [rbx+8C00h], xmm3
00007FF91DFD5B20  F3 0F 59 83 30 8C 00 00     mulss   xmm0, dword ptr [rbx+8C30h]
00007FF91DFD5B28  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFD5B2C  F3 0F 59 9B 60 8C 00 00     mulss   xmm3, dword ptr [rbx+8C60h]
00007FF91DFD5B34  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFD5B38  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFD5B3B  F3 0F 59 8B 20 8C 00 00     mulss   xmm1, dword ptr [rbx+8C20h]
00007FF91DFD5B43  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD5B47  F3 0F 11 8B F0 8B 00 00     movss   dword ptr [rbx+8BF0h], xmm1
00007FF91DFD5B4F  F3 0F 59 8B 50 8C 00 00     mulss   xmm1, dword ptr [rbx+8C50h]
00007FF91DFD5B57  F3 0F 59 A3 40 8C 00 00     mulss   xmm4, dword ptr [rbx+8C40h]
00007FF91DFD5B5F  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD5B63  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD5B67  F3 0F 11 A3 10 8C 00 00     movss   dword ptr [rbx+8C10h], xmm4
00007FF91DFD5B6F  8B 83 40 94 00 00           mov     eax, [rbx+9440h]
00007FF91DFD5B75  89 83 50 94 00 00           mov     [rbx+9450h], eax
00007FF91DFD5B7B  F3 0F 10 8B 60 94 00 00     movss   xmm1, dword ptr [rbx+9460h]
00007FF91DFD5B83  F3 0F 11 8B 70 94 00 00     movss   dword ptr [rbx+9470h], xmm1
00007FF91DFD5B8B  F3 0F 59 8B 00 89 00 00     mulss   xmm1, dword ptr [rbx+8900h]
00007FF91DFD5B93  F3 0F 10 83 50 94 00 00     movss   xmm0, dword ptr [rbx+9450h]
00007FF91DFD5B9B  F3 0F 59 83 10 8C 00 00     mulss   xmm0, dword ptr [rbx+8C10h]
00007FF91DFD5BA3  F3 0F 11 8B 80 94 00 00     movss   dword ptr [rbx+9480h], xmm1
00007FF91DFD5BAB  F3 0F 11 83 90 94 00 00     movss   dword ptr [rbx+9490h], xmm0
00007FF91DFD5BB3  8B 83 C0 94 00 00           mov     eax, [rbx+94C0h]
00007FF91DFD5BB9  89 83 D0 94 00 00           mov     [rbx+94D0h], eax
00007FF91DFD5BBF  F3 0F 59 8B A0 94 00 00     mulss   xmm1, dword ptr [rbx+94A0h]
00007FF91DFD5BC7  F3 0F 59 83 B0 94 00 00     mulss   xmm0, dword ptr [rbx+94B0h]
00007FF91DFD5BCF  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFD5BD3  F3 0F 11 83 C0 94 00 00     movss   dword ptr [rbx+94C0h], xmm0
00007FF91DFD5BDB  8B 83 E0 94 00 00           mov     eax, [rbx+94E0h]
00007FF91DFD5BE1  89 83 F0 94 00 00           mov     [rbx+94F0h], eax
00007FF91DFD5BE7  8B 83 00 95 00 00           mov     eax, [rbx+9500h]
00007FF91DFD5BED  89 83 10 95 00 00           mov     [rbx+9510h], eax
00007FF91DFD5BF3  8B 83 20 95 00 00           mov     eax, [rbx+9520h]
00007FF91DFD5BF9  89 83 30 95 00 00           mov     [rbx+9530h], eax
00007FF91DFD5BFF  8B 83 40 95 00 00           mov     eax, [rbx+9540h]
00007FF91DFD5C05  89 83 50 95 00 00           mov     [rbx+9550h], eax
00007FF91DFD5C0B  F3 0F 10 8B 70 95 00 00     movss   xmm1, dword ptr [rbx+9570h]
00007FF91DFD5C13  F3 0F 10 93 80 95 00 00     movss   xmm2, dword ptr [rbx+9580h]
00007FF91DFD5C1B  0F 28 E1                    movaps  xmm4, xmm1
00007FF91DFD5C1E  F3 0F 59 A3 E0 94 00 00     mulss   xmm4, dword ptr [rbx+94E0h]
00007FF91DFD5C26  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD5C29  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD5C2D  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFD5C31  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFD5C35  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD5C38  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFD5C3B  F3 0F 59 8B A0 95 00 00     mulss   xmm1, dword ptr [rbx+95A0h]
00007FF91DFD5C43  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD5C47  F3 0F 58 8B 90 95 00 00     addss   xmm1, dword ptr [rbx+9590h]
00007FF91DFD5C4F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD5C52  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD5C56  F3 0F 59 83 B0 95 00 00     mulss   xmm0, dword ptr [rbx+95B0h]
00007FF91DFD5C5E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD5C62  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD5C65  F3 0F 59 9B C0 95 00 00     mulss   xmm3, dword ptr [rbx+95C0h]
00007FF91DFD5C6D  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD5C71  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD5C75  F3 0F 59 83 D0 95 00 00     mulss   xmm0, dword ptr [rbx+95D0h]
00007FF91DFD5C7D  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFD5C81  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD5C85  76 05                       jbe     short loc_7FF91DFD5C8C
00007FF91DFD5C87  0F 5A C0                    cvtps2pd xmm0, xmm0
00007FF91DFD5C8A  EB 03                       jmp     short loc_7FF91DFD5C8F
00007FF91DFD5C8C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD5C8F  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFD5C93  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFD5C97  73 04                       jnb     short loc_7FF91DFD5C9D
00007FF91DFD5C99  44 0F 5A E1                 cvtps2pd xmm12, xmm1
00007FF91DFD5C9D  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
00007FF91DFD5CA2  F3 0F 11 83 60 95 00 00     movss   dword ptr [rbx+9560h], xmm0
00007FF91DFD5CAA  8B 83 E0 95 00 00           mov     eax, [rbx+95E0h]
00007FF91DFD5CB0  89 83 F0 95 00 00           mov     [rbx+95F0h], eax
00007FF91DFD5CB6  F3 0F 10 8B 00 96 00 00     movss   xmm1, dword ptr [rbx+9600h]
00007FF91DFD5CBE  F3 0F 11 8B 10 96 00 00     movss   dword ptr [rbx+9610h], xmm1
00007FF91DFD5CC6  F3 0F 10 83 20 96 00 00     movss   xmm0, dword ptr [rbx+9620h]
00007FF91DFD5CCE  F3 0F 11 83 30 96 00 00     movss   dword ptr [rbx+9630h], xmm0
00007FF91DFD5CD6  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD5CDA  F3 0F 59 8B 40 96 00 00     mulss   xmm1, dword ptr [rbx+9640h]
00007FF91DFD5CE2  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD5CE6  F3 0F 11 8B 20 96 00 00     movss   dword ptr [rbx+9620h], xmm1
00007FF91DFD5CEE  F3 0F 10 8B 20 7E 00 00     movss   xmm1, dword ptr [rbx+7E20h]
00007FF91DFD5CF6  F3 0F 10 83 A0 7E 00 00     movss   xmm0, dword ptr [rbx+7EA0h]
00007FF91DFD5CFE  8B 83 70 96 00 00           mov     eax, [rbx+9670h]
00007FF91DFD5D04  89 83 80 96 00 00           mov     [rbx+9680h], eax
00007FF91DFD5D0A  F3 0F 59 83 60 96 00 00     mulss   xmm0, dword ptr [rbx+9660h]
00007FF91DFD5D12  F3 0F 59 8B 50 96 00 00     mulss   xmm1, dword ptr [rbx+9650h]
00007FF91DFD5D1A  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFD5D1E  F3 0F 11 83 70 96 00 00     movss   dword ptr [rbx+9670h], xmm0
00007FF91DFD5D26  8B 83 90 96 00 00           mov     eax, [rbx+9690h]
00007FF91DFD5D2C  89 83 B0 96 00 00           mov     [rbx+96B0h], eax
00007FF91DFD5D32  F3 0F 10 9B A0 96 00 00     movss   xmm3, dword ptr [rbx+96A0h]
00007FF91DFD5D3A  F3 0F 11 9B C0 96 00 00     movss   dword ptr [rbx+96C0h], xmm3
00007FF91DFD5D42  F3 0F 10 8B B0 96 00 00     movss   xmm1, dword ptr [rbx+96B0h]
00007FF91DFD5D4A  F3 0F 10 93 F0 85 00 00     movss   xmm2, dword ptr [rbx+85F0h]
00007FF91DFD5D52  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD5D55  F3 0F 59 83 D0 87 00 00     mulss   xmm0, dword ptr [rbx+87D0h]
00007FF91DFD5D5D  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD5D61  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFD5D65  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD5D68  F3 0F 59 8B 20 95 00 00     mulss   xmm1, dword ptr [rbx+9520h]
00007FF91DFD5D70  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD5D74  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFD5D78  F3 0F 5C CB                 subss   xmm1, xmm3
00007FF91DFD5D7C  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD5D80  F3 0F 11 8B D0 96 00 00     movss   dword ptr [rbx+96D0h], xmm1
00007FF91DFD5D88  F3 0F 10 9B 30 82 00 00     movss   xmm3, dword ptr [rbx+8230h]
00007FF91DFD5D90  F3 0F 10 83 E0 96 00 00     movss   xmm0, dword ptr [rbx+96E0h]
00007FF91DFD5D98  F3 0F 11 83 F0 96 00 00     movss   dword ptr [rbx+96F0h], xmm0
00007FF91DFD5DA0  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD5DA4  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD5DA7  F3 0F 59 8B 00 97 00 00     mulss   xmm1, dword ptr [rbx+9700h]
00007FF91DFD5DAF  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD5DB3  F3 0F 10 83 20 97 00 00     movss   xmm0, dword ptr [rbx+9720h]
00007FF91DFD5DBB  F3 0F 11 8B E0 96 00 00     movss   dword ptr [rbx+96E0h], xmm1
00007FF91DFD5DC3  F3 0F 59 9B 10 97 00 00     mulss   xmm3, dword ptr [rbx+9710h]
00007FF91DFD5DCB  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD5DCF  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD5DD3  F3 0F 11 9B F0 96 00 00     movss   dword ptr [rbx+96F0h], xmm3
00007FF91DFD5DDB  F3 0F 10 83 30 97 00 00     movss   xmm0, dword ptr [rbx+9730h]
00007FF91DFD5DE3  F3 0F 10 BB 40 82 00 00     movss   xmm7, dword ptr [rbx+8240h]
00007FF91DFD5DEB  F3 0F 11 83 40 97 00 00     movss   dword ptr [rbx+9740h], xmm0
00007FF91DFD5DF3  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFD5DF7  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFD5DFA  F3 0F 59 8B 50 97 00 00     mulss   xmm1, dword ptr [rbx+9750h]
00007FF91DFD5E02  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD5E06  F3 0F 10 83 70 97 00 00     movss   xmm0, dword ptr [rbx+9770h]
00007FF91DFD5E0E  F3 0F 11 8B 30 97 00 00     movss   dword ptr [rbx+9730h], xmm1
00007FF91DFD5E16  F3 0F 59 BB 60 97 00 00     mulss   xmm7, dword ptr [rbx+9760h]
00007FF91DFD5E1E  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD5E22  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFD5E26  F3 0F 11 BB 40 97 00 00     movss   dword ptr [rbx+9740h], xmm7
00007FF91DFD5E2E  F3 0F 10 A3 F0 96 00 00     movss   xmm4, dword ptr [rbx+96F0h]
00007FF91DFD5E36  F3 0F 10 AB D0 96 00 00     movss   xmm5, dword ptr [rbx+96D0h]
00007FF91DFD5E3E  F3 0F 10 B3 70 96 00 00     movss   xmm6, dword ptr [rbx+9670h]
00007FF91DFD5E46  F3 44 0F 10 8B 00 95 00 00  movss   xmm9, dword ptr [rbx+9500h]
00007FF91DFD5E4F  8B 83 20 96 00 00           mov     eax, [rbx+9620h]
00007FF91DFD5E55  89 83 80 97 00 00           mov     [rbx+9780h], eax
00007FF91DFD5E5B  F3 44 0F 11 8B 90 97 00 00  movss   dword ptr [rbx+9790h], xmm9
00007FF91DFD5E64  F3 0F 10 83 B0 97 00 00     movss   xmm0, dword ptr [rbx+97B0h]
00007FF91DFD5E6C  F3 0F 10 93 C0 97 00 00     movss   xmm2, dword ptr [rbx+97C0h]
00007FF91DFD5E74  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFD5E78  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD5E7B  F3 0F 59 9B 40 95 00 00     mulss   xmm3, dword ptr [rbx+9540h]
00007FF91DFD5E83  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD5E87  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD5E8A  F3 0F 59 C7                 mulss   xmm0, xmm7
00007FF91DFD5E8E  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFD5E92  F3 44 0F 5C C0              subss   xmm8, xmm0
00007FF91DFD5E97  F3 44 0F 58 C7              addss   xmm8, xmm7
00007FF91DFD5E9C  F3 44 0F 59 83 F0 97 00 00  mulss   xmm8, dword ptr [rbx+97F0h]
00007FF91DFD5EA5  F3 0F 10 8B D0 97 00 00     movss   xmm1, dword ptr [rbx+97D0h]
00007FF91DFD5EAD  F3 0F 58 B3 70 98 00 00     addss   xmm6, dword ptr [rbx+9870h]
00007FF91DFD5EB5  F3 44 0F 59 83 00 98 00 00  mulss   xmm8, dword ptr [rbx+9800h]
00007FF91DFD5EBE  F3 0F 59 AB 10 98 00 00     mulss   xmm5, dword ptr [rbx+9810h]
00007FF91DFD5EC6  F3 0F 59 B3 20 98 00 00     mulss   xmm6, dword ptr [rbx+9820h]
00007FF91DFD5ECE  F3 44 0F 59 C9              mulss   xmm9, xmm1
00007FF91DFD5ED3  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD5ED7  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFD5EDB  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFD5EDF  F3 0F 10 93 50 98 00 00     movss   xmm2, dword ptr [rbx+9850h]
00007FF91DFD5EE7  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD5EEA  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD5EEE  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD5EF2  F3 44 0F 5C C8              subss   xmm9, xmm0
00007FF91DFD5EF7  F3 0F 10 83 40 98 00 00     movss   xmm0, dword ptr [rbx+9840h]
00007FF91DFD5EFF  F3 0F 58 83 80 97 00 00     addss   xmm0, dword ptr [rbx+9780h]
00007FF91DFD5F07  F3 0F 59 9B E0 97 00 00     mulss   xmm3, dword ptr [rbx+97E0h]
00007FF91DFD5F0F  F3 0F 59 83 80 98 00 00     mulss   xmm0, dword ptr [rbx+9880h]
00007FF91DFD5F17  F3 44 0F 58 CA              addss   xmm9, xmm2
00007FF91DFD5F1C  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFD5F21  F3 0F 59 83 30 98 00 00     mulss   xmm0, dword ptr [rbx+9830h]
00007FF91DFD5F29  F3 44 0F 59 8B 60 98 00 00  mulss   xmm9, dword ptr [rbx+9860h]
00007FF91DFD5F32  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFD5F37  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFD5F3C  F3 45 0F 58 C8              addss   xmm9, xmm8
00007FF91DFD5F41  F3 44 0F 11 8B A0 97 00 00  movss   dword ptr [rbx+97A0h], xmm9
00007FF91DFD5F4A  F3 0F 10 BB 60 95 00 00     movss   xmm7, dword ptr [rbx+9560h]
00007FF91DFD5F52  F3 44 0F 10 83 F0 95 00 00  movss   xmm8, dword ptr [rbx+95F0h]
00007FF91DFD5F5B  8B 83 C0 98 00 00           mov     eax, [rbx+98C0h]
00007FF91DFD5F61  89 83 D0 98 00 00           mov     [rbx+98D0h], eax
00007FF91DFD5F67  F3 0F 10 83 B0 98 00 00     movss   xmm0, dword ptr [rbx+98B0h]
00007FF91DFD5F6F  F3 0F 11 83 C0 98 00 00     movss   dword ptr [rbx+98C0h], xmm0
00007FF91DFD5F77  44 0F 2E AB 00 99 00 00     ucomiss xmm13, dword ptr [rbx+9900h]
00007FF91DFD5F7F  0F 85 8F 02 00 00           jnz     loc_7FF91DFD6214
00007FF91DFD5F85  F3 0F 10 8B 50 99 00 00     movss   xmm1, dword ptr [rbx+9950h]
00007FF91DFD5F8D  F3 0F 10 B3 D0 98 00 00     movss   xmm6, dword ptr [rbx+98D0h]
00007FF91DFD5F95  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFD5F98  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFD5F9C  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD5FA0  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFD5FA4  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFD5FA8  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFD5FAC  F3 0F 11 B3 C0 98 00 00     movss   dword ptr [rbx+98C0h], xmm6
00007FF91DFD5FB4  F3 0F 59 B3 40 99 00 00     mulss   xmm6, dword ptr [rbx+9940h]
00007FF91DFD5FBC  F3 0F 58 B3 E0 98 00 00     addss   xmm6, dword ptr [rbx+98E0h]
00007FF91DFD5FC4  E8 97 2D FF FF              call    sub_7FF91DFC8D60
00007FF91DFD5FC9  F3 0F 11 83 B0 98 00 00     movss   dword ptr [rbx+98B0h], xmm0
00007FF91DFD5FD1  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFD5FD5  F3 0F 59 8B A0 99 00 00     mulss   xmm1, dword ptr [rbx+99A0h]
00007FF91DFD5FDD  41 0F 28 D5                 movaps  xmm2, xmm13
00007FF91DFD5FE1  F3 41 0F 5C D0              subss   xmm2, xmm8
00007FF91DFD5FE6  F3 0F 58 8B F0 98 00 00     addss   xmm1, dword ptr [rbx+98F0h]
00007FF91DFD5FEE  F3 0F 59 93 60 99 00 00     mulss   xmm2, dword ptr [rbx+9960h]
00007FF91DFD5FF6  F3 0F 11 8B A0 98 00 00     movss   dword ptr [rbx+98A0h], xmm1
00007FF91DFD5FFE  F3 44 0F 59 8B 30 99 00 00  mulss   xmm9, dword ptr [rbx+9930h]
00007FF91DFD6007  F3 0F 59 BB 10 99 00 00     mulss   xmm7, dword ptr [rbx+9910h]
00007FF91DFD600F  F3 0F 10 83 70 99 00 00     movss   xmm0, dword ptr [rbx+9970h]
00007FF91DFD6017  F3 0F 5D C2                 minss   xmm0, xmm2
00007FF91DFD601B  F3 44 0F 58 CF              addss   xmm9, xmm7
00007FF91DFD6020  F3 44 0F 58 CE              addss   xmm9, xmm6
00007FF91DFD6025  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFD602A  F3 44 0F 58 8B 20 99 00 00  addss   xmm9, dword ptr [rbx+9920h]
00007FF91DFD6033  F3 44 0F 5D 8B 80 99 00 00  minss   xmm9, dword ptr [rbx+9980h]
00007FF91DFD603C  F3 44 0F 5F 8B 90 99 00 00  maxss   xmm9, dword ptr [rbx+9990h]
00007FF91DFD6045  F3 44 0F 59 8B C0 99 00 00  mulss   xmm9, dword ptr [rbx+99C0h]
00007FF91DFD604E  F3 44 0F 58 8B D0 99 00 00  addss   xmm9, dword ptr [rbx+99D0h]
00007FF91DFD6057  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFD605B  F3 0F 2C C9                 cvttss2si ecx, xmm1
00007FF91DFD605F  81 F9 00 00 00 80           cmp     ecx, 80000000h
00007FF91DFD6065  74 1E                       jz      short loc_7FF91DFD6085
00007FF91DFD6067  66 0F 6E C1                 movd    xmm0, ecx
00007FF91DFD606B  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFD606E  0F 2E C1                    ucomiss xmm0, xmm1
00007FF91DFD6071  74 12                       jz      short loc_7FF91DFD6085
00007FF91DFD6073  0F 14 C9                    unpcklps xmm1, xmm1
00007FF91DFD6076  0F 50 C1                    movmskps eax, xmm1
00007FF91DFD6079  83 E0 01                    and     eax, 1
00007FF91DFD607C  2B C8                       sub     ecx, eax
00007FF91DFD607E  66 0F 6E C9                 movd    xmm1, ecx
00007FF91DFD6082  0F 5B C9                    cvtdq2ps xmm1, xmm1
00007FF91DFD6085  F3 44 0F 5C C9              subss   xmm9, xmm1
00007FF91DFD608A  0F 28 C1                    movaps  xmm0, xmm1; X
00007FF91DFD608D  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFD6091  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFD6096  F3 0F 59 35 32 EF 76 00     mulss   xmm6, cs:dword_7FF91E744FD0
00007FF91DFD609E  E8 9D 96 37 00              call    expf
00007FF91DFD60A3  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD60A6  41 0F 28 D1                 movaps  xmm2, xmm9
00007FF91DFD60AA  F3 0F 59 93 90 9A 00 00     mulss   xmm2, dword ptr [rbx+9A90h]
00007FF91DFD60B2  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFD60B6  F3 0F 59 8B 70 9A 00 00     mulss   xmm1, dword ptr [rbx+9A70h]
00007FF91DFD60BE  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFD60C2  F3 0F 58 93 80 9A 00 00     addss   xmm2, dword ptr [rbx+9A80h]
00007FF91DFD60CA  F3 0F 59 83 50 9A 00 00     mulss   xmm0, dword ptr [rbx+9A50h]
00007FF91DFD60D2  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD60D6  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD60DA  F3 0F 58 93 60 9A 00 00     addss   xmm2, dword ptr [rbx+9A60h]
00007FF91DFD60E2  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD60E6  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD60EA  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFD60EE  F3 0F 59 83 30 9A 00 00     mulss   xmm0, dword ptr [rbx+9A30h]
00007FF91DFD60F6  F3 0F 58 93 40 9A 00 00     addss   xmm2, dword ptr [rbx+9A40h]
00007FF91DFD60FE  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD6102  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD6106  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFD610A  F3 0F 59 83 10 9A 00 00     mulss   xmm0, dword ptr [rbx+9A10h]
00007FF91DFD6112  F3 44 0F 59 8B F0 99 00 00  mulss   xmm9, dword ptr [rbx+99F0h]
00007FF91DFD611B  F3 0F 58 93 20 9A 00 00     addss   xmm2, dword ptr [rbx+9A20h]
00007FF91DFD6123  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD6127  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD612B  F3 0F 58 93 00 9A 00 00     addss   xmm2, dword ptr [rbx+9A00h]
00007FF91DFD6133  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD6137  F3 41 0F 58 D1              addss   xmm2, xmm9
00007FF91DFD613C  F3 41 0F 58 D5              addss   xmm2, xmm13
00007FF91DFD6141  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFD6145  F3 0F 59 A3 E0 99 00 00     mulss   xmm4, dword ptr [rbx+99E0h]
00007FF91DFD614D  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD6150  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD6154  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD6157  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFD615B  F3 44 0F 59 83 30 9B 00 00  mulss   xmm8, dword ptr [rbx+9B30h]
00007FF91DFD6164  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD6167  F3 0F 59 83 F0 9A 00 00     mulss   xmm0, dword ptr [rbx+9AF0h]
00007FF91DFD616F  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFD6172  F3 44 0F 58 83 10 9B 00 00  addss   xmm8, dword ptr [rbx+9B10h]
00007FF91DFD617B  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD617F  F3 0F 58 83 D0 9A 00 00     addss   xmm0, dword ptr [rbx+9AD0h]
00007FF91DFD6187  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD618B  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFD6190  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFD6195  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD6198  F3 0F 59 8B B0 9A 00 00     mulss   xmm1, dword ptr [rbx+9AB0h]
00007FF91DFD61A0  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD61A4  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFD61A9  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD61AC  F3 0F 59 83 E0 9A 00 00     mulss   xmm0, dword ptr [rbx+9AE0h]
00007FF91DFD61B4  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFD61B9  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD61BC  F3 0F 59 8B 20 9B 00 00     mulss   xmm1, dword ptr [rbx+9B20h]
00007FF91DFD61C4  F3 0F 59 9B A0 9A 00 00     mulss   xmm3, dword ptr [rbx+9AA0h]
00007FF91DFD61CC  F3 0F 58 8B 00 9B 00 00     addss   xmm1, dword ptr [rbx+9B00h]
00007FF91DFD61D4  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFD61D9  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD61DD  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD61E1  F3 0F 58 8B C0 9A 00 00     addss   xmm1, dword ptr [rbx+9AC0h]
00007FF91DFD61E9  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD61ED  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFD61F1  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD61F6  F3 44 0F 5E C1              divss   xmm8, xmm1
00007FF91DFD61FB  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFD61FF  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD6204  F3 44 0F 5E C0              divss   xmm8, xmm0
00007FF91DFD6209  F3 44 0F 11 83 90 98 00 00  movss   dword ptr [rbx+9890h], xmm8
00007FF91DFD6212  EB 09                       jmp     short loc_7FF91DFD621D
00007FF91DFD6214  F3 44 0F 10 83 90 98 00 00  movss   xmm8, dword ptr [rbx+9890h]
00007FF91DFD621D  8B 83 A0 9B 00 00           mov     eax, [rbx+9BA0h]
00007FF91DFD6223  F3 0F 10 8B C0 94 00 00     movss   xmm1, dword ptr [rbx+94C0h]
00007FF91DFD622B  F3 44 0F 10 8B A0 98 00 00  movss   xmm9, dword ptr [rbx+98A0h]
00007FF91DFD6234  89 83 B0 9B 00 00           mov     [rbx+9BB0h], eax
00007FF91DFD623A  8B 83 90 9B 00 00           mov     eax, [rbx+9B90h]
00007FF91DFD6240  89 83 A0 9B 00 00           mov     [rbx+9BA0h], eax
00007FF91DFD6246  8B 83 80 9B 00 00           mov     eax, [rbx+9B80h]
00007FF91DFD624C  89 83 90 9B 00 00           mov     [rbx+9B90h], eax
00007FF91DFD6252  8B 83 70 9B 00 00           mov     eax, [rbx+9B70h]
00007FF91DFD6258  89 83 80 9B 00 00           mov     [rbx+9B80h], eax
00007FF91DFD625E  8B 83 60 9B 00 00           mov     eax, [rbx+9B60h]
00007FF91DFD6264  89 83 70 9B 00 00           mov     [rbx+9B70h], eax
00007FF91DFD626A  8B 83 50 9B 00 00           mov     eax, [rbx+9B50h]
00007FF91DFD6270  89 83 60 9B 00 00           mov     [rbx+9B60h], eax
00007FF91DFD6276  8B 83 40 9B 00 00           mov     eax, [rbx+9B40h]
00007FF91DFD627C  89 83 50 9B 00 00           mov     [rbx+9B50h], eax
00007FF91DFD6282  8B 83 80 9C 00 00           mov     eax, [rbx+9C80h]
00007FF91DFD6288  89 83 90 9C 00 00           mov     [rbx+9C90h], eax
00007FF91DFD628E  8B 83 70 9C 00 00           mov     eax, [rbx+9C70h]
00007FF91DFD6294  89 83 80 9C 00 00           mov     [rbx+9C80h], eax
00007FF91DFD629A  8B 83 60 9C 00 00           mov     eax, [rbx+9C60h]
00007FF91DFD62A0  89 83 70 9C 00 00           mov     [rbx+9C70h], eax
00007FF91DFD62A6  8B 83 50 9C 00 00           mov     eax, [rbx+9C50h]
00007FF91DFD62AC  89 83 60 9C 00 00           mov     [rbx+9C60h], eax
00007FF91DFD62B2  8B 83 40 9C 00 00           mov     eax, [rbx+9C40h]
00007FF91DFD62B8  89 83 50 9C 00 00           mov     [rbx+9C50h], eax
00007FF91DFD62BE  8B 83 30 9C 00 00           mov     eax, [rbx+9C30h]
00007FF91DFD62C4  89 83 40 9C 00 00           mov     [rbx+9C40h], eax
00007FF91DFD62CA  8B 83 20 9C 00 00           mov     eax, [rbx+9C20h]
00007FF91DFD62D0  89 83 30 9C 00 00           mov     [rbx+9C30h], eax
00007FF91DFD62D6  8B 83 00 9D 00 00           mov     eax, [rbx+9D00h]
00007FF91DFD62DC  89 83 10 9D 00 00           mov     [rbx+9D10h], eax
00007FF91DFD62E2  8B 83 F0 9C 00 00           mov     eax, [rbx+9CF0h]
00007FF91DFD62E8  89 83 00 9D 00 00           mov     [rbx+9D00h], eax
00007FF91DFD62EE  8B 83 E0 9C 00 00           mov     eax, [rbx+9CE0h]
00007FF91DFD62F4  89 83 F0 9C 00 00           mov     [rbx+9CF0h], eax
00007FF91DFD62FA  8B 83 D0 9C 00 00           mov     eax, [rbx+9CD0h]
00007FF91DFD6300  89 83 E0 9C 00 00           mov     [rbx+9CE0h], eax
00007FF91DFD6306  8B 83 C0 9C 00 00           mov     eax, [rbx+9CC0h]
00007FF91DFD630C  89 83 D0 9C 00 00           mov     [rbx+9CD0h], eax
00007FF91DFD6312  8B 83 B0 9C 00 00           mov     eax, [rbx+9CB0h]
00007FF91DFD6318  89 83 C0 9C 00 00           mov     [rbx+9CC0h], eax
00007FF91DFD631E  8B 83 A0 9C 00 00           mov     eax, [rbx+9CA0h]
00007FF91DFD6324  89 83 B0 9C 00 00           mov     [rbx+9CB0h], eax
00007FF91DFD632A  8B 83 80 9D 00 00           mov     eax, [rbx+9D80h]
00007FF91DFD6330  89 83 90 9D 00 00           mov     [rbx+9D90h], eax
00007FF91DFD6336  8B 83 70 9D 00 00           mov     eax, [rbx+9D70h]
00007FF91DFD633C  89 83 80 9D 00 00           mov     [rbx+9D80h], eax
00007FF91DFD6342  8B 83 60 9D 00 00           mov     eax, [rbx+9D60h]
00007FF91DFD6348  89 83 70 9D 00 00           mov     [rbx+9D70h], eax
00007FF91DFD634E  8B 83 50 9D 00 00           mov     eax, [rbx+9D50h]
00007FF91DFD6354  89 83 60 9D 00 00           mov     [rbx+9D60h], eax
00007FF91DFD635A  8B 83 40 9D 00 00           mov     eax, [rbx+9D40h]
00007FF91DFD6360  89 83 50 9D 00 00           mov     [rbx+9D50h], eax
00007FF91DFD6366  8B 83 30 9D 00 00           mov     eax, [rbx+9D30h]
00007FF91DFD636C  89 83 40 9D 00 00           mov     [rbx+9D40h], eax
00007FF91DFD6372  8B 83 20 9D 00 00           mov     eax, [rbx+9D20h]
00007FF91DFD6378  89 83 30 9D 00 00           mov     [rbx+9D30h], eax
00007FF91DFD637E  8B 83 00 9E 00 00           mov     eax, [rbx+9E00h]
00007FF91DFD6384  89 83 10 9E 00 00           mov     [rbx+9E10h], eax
00007FF91DFD638A  8B 83 F0 9D 00 00           mov     eax, [rbx+9DF0h]
00007FF91DFD6390  89 83 00 9E 00 00           mov     [rbx+9E00h], eax
00007FF91DFD6396  8B 83 E0 9D 00 00           mov     eax, [rbx+9DE0h]
00007FF91DFD639C  89 83 F0 9D 00 00           mov     [rbx+9DF0h], eax
00007FF91DFD63A2  8B 83 D0 9D 00 00           mov     eax, [rbx+9DD0h]
00007FF91DFD63A8  89 83 E0 9D 00 00           mov     [rbx+9DE0h], eax
00007FF91DFD63AE  8B 83 C0 9D 00 00           mov     eax, [rbx+9DC0h]
00007FF91DFD63B4  89 83 D0 9D 00 00           mov     [rbx+9DD0h], eax
00007FF91DFD63BA  8B 83 B0 9D 00 00           mov     eax, [rbx+9DB0h]
00007FF91DFD63C0  89 83 C0 9D 00 00           mov     [rbx+9DC0h], eax
00007FF91DFD63C6  8B 83 A0 9D 00 00           mov     eax, [rbx+9DA0h]
00007FF91DFD63CC  89 83 B0 9D 00 00           mov     [rbx+9DB0h], eax
00007FF91DFD63D2  8B 83 20 9E 00 00           mov     eax, [rbx+9E20h]
00007FF91DFD63D8  89 83 30 9E 00 00           mov     [rbx+9E30h], eax
00007FF91DFD63DE  F3 0F 10 83 40 9E 00 00     movss   xmm0, dword ptr [rbx+9E40h]
00007FF91DFD63E6  F3 0F 11 83 50 9E 00 00     movss   dword ptr [rbx+9E50h], xmm0
00007FF91DFD63EE  44 0F 2E AB 90 9E 00 00     ucomiss xmm13, dword ptr [rbx+9E90h]
00007FF91DFD63F6  0F 85 49 09 00 00           jnz     loc_7FF91DFD6D45
00007FF91DFD63FC  F3 0F 59 8B E0 9E 00 00     mulss   xmm1, dword ptr [rbx+9EE0h]
00007FF91DFD6404  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFD6408  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFD640C  41 0F 28 F8                 movaps  xmm7, xmm8
00007FF91DFD6410  F3 0F 59 B3 00 9F 00 00     mulss   xmm6, dword ptr [rbx+9F00h]
00007FF91DFD6418  F3 41 0F 59 F8              mulss   xmm7, xmm8
00007FF91DFD641D  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD6422  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFD6426  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFD6429  F3 0F 59 8B D0 9E 00 00     mulss   xmm1, dword ptr [rbx+9ED0h]
00007FF91DFD6431  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFD6435  E8 26 29 FF FF              call    sub_7FF91DFC8D60
00007FF91DFD643A  F3 0F 11 83 40 9E 00 00     movss   dword ptr [rbx+9E40h], xmm0
00007FF91DFD6442  41 0F 28 DD                 movaps  xmm3, xmm13
00007FF91DFD6446  F3 0F 11 B3 20 9E 00 00     movss   dword ptr [rbx+9E20h], xmm6
00007FF91DFD644E  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFD6452  F3 0F 59 FF                 mulss   xmm7, xmm7
00007FF91DFD6456  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFD645B  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD645F  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFD6464  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFD6468  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD646D  F3 0F 5E DF                 divss   xmm3, xmm7
00007FF91DFD6471  F3 0F 11 9B 70 9E 00 00     movss   dword ptr [rbx+9E70h], xmm3
00007FF91DFD6479  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFD647C  F3 0F 10 8B 20 9E 00 00     movss   xmm1, dword ptr [rbx+9E20h]
00007FF91DFD6484  F3 0F 10 AB 30 9E 00 00     movss   xmm5, dword ptr [rbx+9E30h]
00007FF91DFD648C  F3 41 0F 59 E1              mulss   xmm4, xmm9
00007FF91DFD6491  F3 0F 11 A3 60 9E 00 00     movss   dword ptr [rbx+9E60h], xmm4
00007FF91DFD6499  F3 0F 59 AB 30 9F 00 00     mulss   xmm5, dword ptr [rbx+9F30h]
00007FF91DFD64A1  F3 0F 10 93 A0 9B 00 00     movss   xmm2, dword ptr [rbx+9BA0h]
00007FF91DFD64A9  F3 0F 59 8B 40 9F 00 00     mulss   xmm1, dword ptr [rbx+9F40h]
00007FF91DFD64B1  F3 0F 10 83 B0 9B 00 00     movss   xmm0, dword ptr [rbx+9BB0h]
00007FF91DFD64B9  F3 0F 11 93 10 9C 00 00     movss   dword ptr [rbx+9C10h], xmm2
00007FF91DFD64C1  F3 0F 59 93 60 A0 00 00     mulss   xmm2, dword ptr [rbx+0A060h]
00007FF91DFD64C9  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD64CD  F3 0F 59 83 70 A0 00 00     mulss   xmm0, dword ptr [rbx+0A070h]
00007FF91DFD64D5  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFD64D9  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD64DD  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD64E1  F3 0F 5C EA                 subss   xmm5, xmm2
00007FF91DFD64E5  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD64E9  73 06                       jnb     short loc_7FF91DFD64F1
00007FF91DFD64EB  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD64EF  EB 05                       jmp     short loc_7FF91DFD64F6
00007FF91DFD64F1  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD64F6  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFD64F9  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD64FC  F3 0F 59 83 10 9F 00 00     mulss   xmm0, dword ptr [rbx+9F10h]
00007FF91DFD6504  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD6508  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD650C  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD6510  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD6514  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD6518  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD651C  F3 0F 11 AB C0 9B 00 00     movss   dword ptr [rbx+9BC0h], xmm5
00007FF91DFD6524  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD6527  F3 0F 58 AB 50 9B 00 00     addss   xmm5, dword ptr [rbx+9B50h]
00007FF91DFD652F  F3 0F 10 9B 60 9B 00 00     movss   xmm3, dword ptr [rbx+9B60h]
00007FF91DFD6537  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD653A  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD653E  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD6542  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFD6546  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFD654A  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD654E  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6552  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD6555  F3 0F 11 A3 D0 9B 00 00     movss   dword ptr [rbx+9BD0h], xmm4
00007FF91DFD655D  F3 0F 10 8B 70 9B 00 00     movss   xmm1, dword ptr [rbx+9B70h]
00007FF91DFD6565  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD6569  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD656D  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD6570  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD6574  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFD6578  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD657C  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFD6580  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD6584  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD6588  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD658C  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD6590  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD6593  F3 0F 11 9B E0 9B 00 00     movss   dword ptr [rbx+9BE0h], xmm3
00007FF91DFD659B  F3 0F 10 AB 80 9B 00 00     movss   xmm5, dword ptr [rbx+9B80h]
00007FF91DFD65A3  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD65A7  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD65AB  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD65AE  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD65B2  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD65B6  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD65BA  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFD65BE  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD65C2  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD65C6  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD65CA  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD65CE  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD65D1  F3 0F 11 93 F0 9B 00 00     movss   dword ptr [rbx+9BF0h], xmm2
00007FF91DFD65D9  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFD65DD  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD65E1  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD65E5  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFD65EA  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD65ED  F3 0F 59 83 90 9B 00 00     mulss   xmm0, dword ptr [rbx+9B90h]
00007FF91DFD65F5  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD65F9  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD65FD  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD6600  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFD6604  F3 0F 11 AB 00 9C 00 00     movss   dword ptr [rbx+9C00h], xmm5
00007FF91DFD660C  F3 0F 10 93 F0 9B 00 00     movss   xmm2, dword ptr [rbx+9BF0h]
00007FF91DFD6614  F3 0F 59 93 B0 9E 00 00     mulss   xmm2, dword ptr [rbx+9EB0h]
00007FF91DFD661C  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD6620  F3 0F 59 AB C0 9E 00 00     mulss   xmm5, dword ptr [rbx+9EC0h]
00007FF91DFD6628  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD662C  F3 0F 10 83 A0 9E 00 00     movss   xmm0, dword ptr [rbx+9EA0h]
00007FF91DFD6634  F3 0F 59 83 E0 9B 00 00     mulss   xmm0, dword ptr [rbx+9BE0h]
00007FF91DFD663C  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFD6640  F3 0F 10 AB 30 9E 00 00     movss   xmm5, dword ptr [rbx+9E30h]
00007FF91DFD6648  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD664C  F3 0F 11 93 A0 9D 00 00     movss   dword ptr [rbx+9DA0h], xmm2
00007FF91DFD6654  F3 0F 58 AB 20 9E 00 00     addss   xmm5, dword ptr [rbx+9E20h]
00007FF91DFD665C  F3 0F 10 83 10 9C 00 00     movss   xmm0, dword ptr [rbx+9C10h]
00007FF91DFD6664  F3 0F 59 AB 50 9F 00 00     mulss   xmm5, dword ptr [rbx+9F50h]
00007FF91DFD666C  F3 0F 59 AB 70 9E 00 00     mulss   xmm5, dword ptr [rbx+9E70h]
00007FF91DFD6674  F3 0F 11 A3 10 9C 00 00     movss   dword ptr [rbx+9C10h], xmm4
00007FF91DFD667C  F3 0F 59 A3 60 A0 00 00     mulss   xmm4, dword ptr [rbx+0A060h]
00007FF91DFD6684  F3 0F 59 83 70 A0 00 00     mulss   xmm0, dword ptr [rbx+0A070h]
00007FF91DFD668C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6690  F3 0F 59 A3 60 9E 00 00     mulss   xmm4, dword ptr [rbx+9E60h]
00007FF91DFD6698  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFD669C  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD66A0  73 06                       jnb     short loc_7FF91DFD66A8
00007FF91DFD66A2  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD66A6  EB 05                       jmp     short loc_7FF91DFD66AD
00007FF91DFD66A8  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD66AD  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFD66B0  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD66B3  F3 0F 59 83 10 9F 00 00     mulss   xmm0, dword ptr [rbx+9F10h]
00007FF91DFD66BB  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD66BF  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD66C3  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD66C7  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD66CB  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD66CF  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD66D3  F3 0F 10 8B C0 9B 00 00     movss   xmm1, dword ptr [rbx+9BC0h]
00007FF91DFD66DB  F3 0F 11 AB C0 9B 00 00     movss   dword ptr [rbx+9BC0h], xmm5
00007FF91DFD66E3  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD66E6  F3 0F 10 9B D0 9B 00 00     movss   xmm3, dword ptr [rbx+9BD0h]
00007FF91DFD66EE  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD66F2  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD66F5  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD66F9  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD66FD  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFD6701  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFD6705  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD6709  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD670D  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD6710  F3 0F 11 A3 D0 9B 00 00     movss   dword ptr [rbx+9BD0h], xmm4
00007FF91DFD6718  F3 0F 10 8B E0 9B 00 00     movss   xmm1, dword ptr [rbx+9BE0h]
00007FF91DFD6720  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD6724  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD6728  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD672B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD672F  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFD6733  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD6737  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFD673B  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD673F  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD6743  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD6747  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD674B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD674E  F3 0F 11 9B E0 9B 00 00     movss   dword ptr [rbx+9BE0h], xmm3
00007FF91DFD6756  F3 0F 10 AB F0 9B 00 00     movss   xmm5, dword ptr [rbx+9BF0h]
00007FF91DFD675E  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD6762  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6766  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD6769  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD676D  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD6771  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD6775  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFD6779  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD677D  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD6781  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD6785  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD6789  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD678C  F3 0F 11 93 F0 9B 00 00     movss   dword ptr [rbx+9BF0h], xmm2
00007FF91DFD6794  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFD6798  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD679C  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD67A0  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFD67A5  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD67A8  F3 0F 59 83 00 9C 00 00     mulss   xmm0, dword ptr [rbx+9C00h]
00007FF91DFD67B0  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD67B4  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD67B8  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD67BB  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFD67BF  F3 0F 11 AB 00 9C 00 00     movss   dword ptr [rbx+9C00h], xmm5
00007FF91DFD67C7  F3 0F 10 93 F0 9B 00 00     movss   xmm2, dword ptr [rbx+9BF0h]
00007FF91DFD67CF  F3 0F 59 93 B0 9E 00 00     mulss   xmm2, dword ptr [rbx+9EB0h]
00007FF91DFD67D7  F3 0F 10 8B 20 9E 00 00     movss   xmm1, dword ptr [rbx+9E20h]
00007FF91DFD67DF  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD67E3  F3 0F 59 AB C0 9E 00 00     mulss   xmm5, dword ptr [rbx+9EC0h]
00007FF91DFD67EB  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD67EF  F3 0F 10 83 A0 9E 00 00     movss   xmm0, dword ptr [rbx+9EA0h]
00007FF91DFD67F7  F3 0F 59 83 E0 9B 00 00     mulss   xmm0, dword ptr [rbx+9BE0h]
00007FF91DFD67FF  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFD6803  F3 0F 10 AB 30 9E 00 00     movss   xmm5, dword ptr [rbx+9E30h]
00007FF91DFD680B  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD680F  F3 0F 11 93 20 9D 00 00     movss   dword ptr [rbx+9D20h], xmm2
00007FF91DFD6817  F3 0F 59 AB 40 9F 00 00     mulss   xmm5, dword ptr [rbx+9F40h]
00007FF91DFD681F  F3 0F 59 8B 30 9F 00 00     mulss   xmm1, dword ptr [rbx+9F30h]
00007FF91DFD6827  F3 0F 10 83 10 9C 00 00     movss   xmm0, dword ptr [rbx+9C10h]
00007FF91DFD682F  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD6833  F3 0F 59 AB 70 9E 00 00     mulss   xmm5, dword ptr [rbx+9E70h]
00007FF91DFD683B  F3 0F 11 A3 10 9C 00 00     movss   dword ptr [rbx+9C10h], xmm4
00007FF91DFD6843  F3 0F 59 A3 60 A0 00 00     mulss   xmm4, dword ptr [rbx+0A060h]
00007FF91DFD684B  F3 0F 59 83 70 A0 00 00     mulss   xmm0, dword ptr [rbx+0A070h]
00007FF91DFD6853  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6857  F3 0F 59 A3 60 9E 00 00     mulss   xmm4, dword ptr [rbx+9E60h]
00007FF91DFD685F  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFD6863  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD6867  73 06                       jnb     short loc_7FF91DFD686F
00007FF91DFD6869  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD686D  EB 05                       jmp     short loc_7FF91DFD6874
00007FF91DFD686F  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD6874  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFD6877  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD687A  F3 0F 59 83 10 9F 00 00     mulss   xmm0, dword ptr [rbx+9F10h]
00007FF91DFD6882  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD6886  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD688A  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD688E  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD6892  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD6896  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD689A  F3 0F 10 8B C0 9B 00 00     movss   xmm1, dword ptr [rbx+9BC0h]
00007FF91DFD68A2  F3 0F 11 AB C0 9B 00 00     movss   dword ptr [rbx+9BC0h], xmm5
00007FF91DFD68AA  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD68AD  F3 0F 10 9B D0 9B 00 00     movss   xmm3, dword ptr [rbx+9BD0h]
00007FF91DFD68B5  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD68B9  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD68BC  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD68C0  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD68C4  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFD68C8  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFD68CC  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD68D0  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD68D4  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD68D7  F3 0F 11 A3 D0 9B 00 00     movss   dword ptr [rbx+9BD0h], xmm4
00007FF91DFD68DF  F3 0F 10 8B E0 9B 00 00     movss   xmm1, dword ptr [rbx+9BE0h]
00007FF91DFD68E7  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD68EB  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD68EF  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD68F2  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD68F6  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFD68FA  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD68FE  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFD6902  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD6906  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD690A  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD690E  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD6912  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD6915  F3 0F 11 9B E0 9B 00 00     movss   dword ptr [rbx+9BE0h], xmm3
00007FF91DFD691D  F3 0F 10 AB F0 9B 00 00     movss   xmm5, dword ptr [rbx+9BF0h]
00007FF91DFD6925  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD6929  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD692D  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD6930  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD6934  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD6938  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD693C  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFD6940  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD6944  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD6948  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFD694C  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD6950  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD6953  F3 0F 11 93 F0 9B 00 00     movss   dword ptr [rbx+9BF0h], xmm2
00007FF91DFD695B  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFD695F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD6963  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD6967  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFD696C  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD696F  F3 0F 59 83 00 9C 00 00     mulss   xmm0, dword ptr [rbx+9C00h]
00007FF91DFD6977  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD697B  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD697F  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD6982  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFD6986  F3 0F 11 AB 00 9C 00 00     movss   dword ptr [rbx+9C00h], xmm5
00007FF91DFD698E  F3 0F 10 8B F0 9B 00 00     movss   xmm1, dword ptr [rbx+9BF0h]
00007FF91DFD6996  F3 0F 59 8B B0 9E 00 00     mulss   xmm1, dword ptr [rbx+9EB0h]
00007FF91DFD699E  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD69A2  F3 0F 59 AB C0 9E 00 00     mulss   xmm5, dword ptr [rbx+9EC0h]
00007FF91DFD69AA  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD69AE  F3 0F 10 83 A0 9E 00 00     movss   xmm0, dword ptr [rbx+9EA0h]
00007FF91DFD69B6  F3 0F 59 83 E0 9B 00 00     mulss   xmm0, dword ptr [rbx+9BE0h]
00007FF91DFD69BE  F3 0F 58 CD                 addss   xmm1, xmm5
00007FF91DFD69C2  F3 0F 10 AB 20 9E 00 00     movss   xmm5, dword ptr [rbx+9E20h]
00007FF91DFD69CA  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD69CE  F3 0F 11 8B A0 9C 00 00     movss   dword ptr [rbx+9CA0h], xmm1
00007FF91DFD69D6  F3 0F 59 AB 20 9F 00 00     mulss   xmm5, dword ptr [rbx+9F20h]
00007FF91DFD69DE  F3 0F 10 83 10 9C 00 00     movss   xmm0, dword ptr [rbx+9C10h]
00007FF91DFD69E6  F3 0F 59 AB 70 9E 00 00     mulss   xmm5, dword ptr [rbx+9E70h]
00007FF91DFD69EE  F3 0F 11 9B A0 9B 00 00     movss   dword ptr [rbx+9BA0h], xmm3
00007FF91DFD69F6  F3 0F 59 9B 60 A0 00 00     mulss   xmm3, dword ptr [rbx+0A060h]
00007FF91DFD69FE  F3 0F 59 83 70 A0 00 00     mulss   xmm0, dword ptr [rbx+0A070h]
00007FF91DFD6A06  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD6A0A  F3 0F 59 9B 60 9E 00 00     mulss   xmm3, dword ptr [rbx+9E60h]
00007FF91DFD6A12  F3 0F 5C EB                 subss   xmm5, xmm3
00007FF91DFD6A16  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD6A1A  73 06                       jnb     short loc_7FF91DFD6A22
00007FF91DFD6A1C  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD6A20  EB 05                       jmp     short loc_7FF91DFD6A27
00007FF91DFD6A22  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD6A27  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFD6A2A  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD6A2D  F3 0F 59 83 10 9F 00 00     mulss   xmm0, dword ptr [rbx+9F10h]
00007FF91DFD6A35  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD6A39  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD6A3D  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD6A41  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD6A45  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD6A49  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD6A4D  F3 0F 11 AB 40 9B 00 00     movss   dword ptr [rbx+9B40h], xmm5
00007FF91DFD6A55  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD6A58  F3 0F 58 AB C0 9B 00 00     addss   xmm5, dword ptr [rbx+9BC0h]
00007FF91DFD6A60  F3 0F 10 9B D0 9B 00 00     movss   xmm3, dword ptr [rbx+9BD0h]
00007FF91DFD6A68  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD6A6B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD6A6F  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD6A73  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFD6A77  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFD6A7B  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD6A7F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6A83  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD6A86  F3 0F 11 A3 50 9B 00 00     movss   dword ptr [rbx+9B50h], xmm4
00007FF91DFD6A8E  F3 0F 10 8B E0 9B 00 00     movss   xmm1, dword ptr [rbx+9BE0h]
00007FF91DFD6A96  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD6A9A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD6A9E  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD6AA1  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD6AA5  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFD6AA9  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD6AAD  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFD6AB1  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD6AB5  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD6AB9  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD6ABD  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD6AC1  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD6AC4  F3 0F 11 9B 60 9B 00 00     movss   dword ptr [rbx+9B60h], xmm3
00007FF91DFD6ACC  F3 0F 10 AB F0 9B 00 00     movss   xmm5, dword ptr [rbx+9BF0h]
00007FF91DFD6AD4  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD6AD8  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6ADC  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD6ADF  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD6AE3  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD6AE7  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD6AEB  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFD6AEF  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD6AF3  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD6AF7  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD6AFB  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD6AFE  F3 0F 11 93 70 9B 00 00     movss   dword ptr [rbx+9B70h], xmm2
00007FF91DFD6B06  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFD6B0A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD6B0E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD6B12  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFD6B17  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD6B1A  F3 0F 59 83 00 9C 00 00     mulss   xmm0, dword ptr [rbx+9C00h]
00007FF91DFD6B22  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD6B26  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD6B2A  F3 44 0F 59 C1              mulss   xmm8, xmm1
00007FF91DFD6B2F  F3 0F 11 AB 80 9B 00 00     movss   dword ptr [rbx+9B80h], xmm5
00007FF91DFD6B37  F3 0F 10 9B 60 9B 00 00     movss   xmm3, dword ptr [rbx+9B60h]
00007FF91DFD6B3F  F3 0F 59 F5                 mulss   xmm6, xmm5
00007FF91DFD6B43  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFD6B48  F3 44 0F 11 83 90 9B 00 00  movss   dword ptr [rbx+9B90h], xmm8
00007FF91DFD6B51  F3 0F 10 83 B0 9E 00 00     movss   xmm0, dword ptr [rbx+9EB0h]
00007FF91DFD6B59  F3 0F 59 83 70 9B 00 00     mulss   xmm0, dword ptr [rbx+9B70h]
00007FF91DFD6B61  F3 0F 59 AB C0 9E 00 00     mulss   xmm5, dword ptr [rbx+9EC0h]
00007FF91DFD6B69  F3 0F 59 9B A0 9E 00 00     mulss   xmm3, dword ptr [rbx+9EA0h]
00007FF91DFD6B71  F3 0F 10 A3 60 9C 00 00     movss   xmm4, dword ptr [rbx+9C60h]
00007FF91DFD6B79  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD6B7D  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFD6B81  F3 0F 11 AB 20 9C 00 00     movss   dword ptr [rbx+9C20h], xmm5
00007FF91DFD6B89  F3 0F 58 A3 D0 9D 00 00     addss   xmm4, dword ptr [rbx+9DD0h]
00007FF91DFD6B91  F3 0F 10 83 E0 9C 00 00     movss   xmm0, dword ptr [rbx+9CE0h]
00007FF91DFD6B99  F3 0F 58 83 50 9D 00 00     addss   xmm0, dword ptr [rbx+9D50h]
00007FF91DFD6BA1  F3 0F 10 8B 60 9D 00 00     movss   xmm1, dword ptr [rbx+9D60h]
00007FF91DFD6BA9  F3 0F 58 8B D0 9C 00 00     addss   xmm1, dword ptr [rbx+9CD0h]
00007FF91DFD6BB1  F3 0F 59 A3 50 A0 00 00     mulss   xmm4, dword ptr [rbx+0A050h]
00007FF91DFD6BB9  F3 0F 59 83 40 A0 00 00     mulss   xmm0, dword ptr [rbx+0A040h]
00007FF91DFD6BC1  F3 0F 59 8B 30 A0 00 00     mulss   xmm1, dword ptr [rbx+0A030h]
00007FF91DFD6BC9  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6BCD  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD6BD1  F3 0F 10 83 50 9C 00 00     movss   xmm0, dword ptr [rbx+9C50h]
00007FF91DFD6BD9  F3 0F 58 83 E0 9D 00 00     addss   xmm0, dword ptr [rbx+9DE0h]
00007FF91DFD6BE1  F3 0F 10 8B C0 9D 00 00     movss   xmm1, dword ptr [rbx+9DC0h]
00007FF91DFD6BE9  F3 0F 58 8B 70 9C 00 00     addss   xmm1, dword ptr [rbx+9C70h]
00007FF91DFD6BF1  F3 0F 58 AB 10 9E 00 00     addss   xmm5, dword ptr [rbx+9E10h]
00007FF91DFD6BF9  F3 0F 59 83 20 A0 00 00     mulss   xmm0, dword ptr [rbx+0A020h]
00007FF91DFD6C01  F3 0F 59 8B 10 A0 00 00     mulss   xmm1, dword ptr [rbx+0A010h]
00007FF91DFD6C09  F3 0F 59 AB 60 9F 00 00     mulss   xmm5, dword ptr [rbx+9F60h]
00007FF91DFD6C11  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6C15  F3 0F 10 83 40 9D 00 00     movss   xmm0, dword ptr [rbx+9D40h]
00007FF91DFD6C1D  F3 0F 58 83 F0 9C 00 00     addss   xmm0, dword ptr [rbx+9CF0h]
00007FF91DFD6C25  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD6C29  F3 0F 10 8B 70 9D 00 00     movss   xmm1, dword ptr [rbx+9D70h]
00007FF91DFD6C31  F3 0F 58 8B C0 9C 00 00     addss   xmm1, dword ptr [rbx+9CC0h]
00007FF91DFD6C39  F3 0F 59 83 00 A0 00 00     mulss   xmm0, dword ptr [rbx+0A000h]
00007FF91DFD6C41  F3 0F 59 8B F0 9F 00 00     mulss   xmm1, dword ptr [rbx+9FF0h]
00007FF91DFD6C49  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6C4D  F3 0F 10 83 F0 9D 00 00     movss   xmm0, dword ptr [rbx+9DF0h]
00007FF91DFD6C55  F3 0F 58 83 40 9C 00 00     addss   xmm0, dword ptr [rbx+9C40h]
00007FF91DFD6C5D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD6C61  F3 0F 10 8B B0 9D 00 00     movss   xmm1, dword ptr [rbx+9DB0h]
00007FF91DFD6C69  F3 0F 59 83 E0 9F 00 00     mulss   xmm0, dword ptr [rbx+9FE0h]
00007FF91DFD6C71  F3 0F 58 8B 80 9C 00 00     addss   xmm1, dword ptr [rbx+9C80h]
00007FF91DFD6C79  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6C7D  F3 0F 10 83 30 9D 00 00     movss   xmm0, dword ptr [rbx+9D30h]
00007FF91DFD6C85  F3 0F 58 83 00 9D 00 00     addss   xmm0, dword ptr [rbx+9D00h]
00007FF91DFD6C8D  F3 0F 59 8B D0 9F 00 00     mulss   xmm1, dword ptr [rbx+9FD0h]
00007FF91DFD6C95  F3 0F 59 83 C0 9F 00 00     mulss   xmm0, dword ptr [rbx+9FC0h]
00007FF91DFD6C9D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD6CA1  F3 0F 10 8B 80 9D 00 00     movss   xmm1, dword ptr [rbx+9D80h]
00007FF91DFD6CA9  F3 0F 58 8B B0 9C 00 00     addss   xmm1, dword ptr [rbx+9CB0h]
00007FF91DFD6CB1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6CB5  F3 0F 10 83 00 9E 00 00     movss   xmm0, dword ptr [rbx+9E00h]
00007FF91DFD6CBD  F3 0F 59 8B B0 9F 00 00     mulss   xmm1, dword ptr [rbx+9FB0h]
00007FF91DFD6CC5  F3 0F 58 83 30 9C 00 00     addss   xmm0, dword ptr [rbx+9C30h]
00007FF91DFD6CCD  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD6CD1  F3 0F 10 8B A0 9D 00 00     movss   xmm1, dword ptr [rbx+9DA0h]
00007FF91DFD6CD9  F3 0F 58 8B 90 9C 00 00     addss   xmm1, dword ptr [rbx+9C90h]
00007FF91DFD6CE1  F3 0F 59 83 A0 9F 00 00     mulss   xmm0, dword ptr [rbx+9FA0h]
00007FF91DFD6CE9  F3 0F 59 8B 90 9F 00 00     mulss   xmm1, dword ptr [rbx+9F90h]
00007FF91DFD6CF1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6CF5  F3 0F 10 83 20 9D 00 00     movss   xmm0, dword ptr [rbx+9D20h]
00007FF91DFD6CFD  F3 0F 58 83 10 9D 00 00     addss   xmm0, dword ptr [rbx+9D10h]
00007FF91DFD6D05  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD6D09  F3 0F 10 8B 90 9D 00 00     movss   xmm1, dword ptr [rbx+9D90h]
00007FF91DFD6D11  F3 0F 59 83 80 9F 00 00     mulss   xmm0, dword ptr [rbx+9F80h]
00007FF91DFD6D19  F3 0F 58 8B A0 9C 00 00     addss   xmm1, dword ptr [rbx+9CA0h]
00007FF91DFD6D21  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6D25  F3 0F 59 8B 70 9F 00 00     mulss   xmm1, dword ptr [rbx+9F70h]
00007FF91DFD6D2D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD6D31  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD6D35  F3 0F 59 A3 F0 9E 00 00     mulss   xmm4, dword ptr [rbx+9EF0h]
00007FF91DFD6D3D  F3 0F 11 A3 80 9E 00 00     movss   dword ptr [rbx+9E80h], xmm4
00007FF91DFD6D45  8B 83 80 A0 00 00           mov     eax, [rbx+0A080h]
00007FF91DFD6D4B  89 83 90 A0 00 00           mov     [rbx+0A090h], eax
00007FF91DFD6D51  F3 0F 10 83 B0 A0 00 00     movss   xmm0, dword ptr [rbx+0A0B0h]
00007FF91DFD6D59  8B 83 A0 A0 00 00           mov     eax, [rbx+0A0A0h]
00007FF91DFD6D5F  89 83 D0 A0 00 00           mov     [rbx+0A0D0h], eax
00007FF91DFD6D65  F3 0F 11 83 E0 A0 00 00     movss   dword ptr [rbx+0A0E0h], xmm0
00007FF91DFD6D6D  8B 83 C0 A0 00 00           mov     eax, [rbx+0A0C0h]
00007FF91DFD6D73  89 83 F0 A0 00 00           mov     [rbx+0A0F0h], eax
00007FF91DFD6D79  F3 0F 10 93 00 A1 00 00     movss   xmm2, dword ptr [rbx+0A100h]
00007FF91DFD6D81  F3 0F 11 93 10 A1 00 00     movss   dword ptr [rbx+0A110h], xmm2
00007FF91DFD6D89  F3 0F 10 83 20 A1 00 00     movss   xmm0, dword ptr [rbx+0A120h]
00007FF91DFD6D91  F3 0F 11 83 30 A1 00 00     movss   dword ptr [rbx+0A130h], xmm0
00007FF91DFD6D99  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD6D9D  F3 0F 59 93 40 A1 00 00     mulss   xmm2, dword ptr [rbx+0A140h]
00007FF91DFD6DA5  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD6DA9  F3 0F 11 93 20 A1 00 00     movss   dword ptr [rbx+0A120h], xmm2
00007FF91DFD6DB1  F3 0F 10 83 E0 A0 00 00     movss   xmm0, dword ptr [rbx+0A0E0h]
00007FF91DFD6DB9  F3 0F 10 8B F0 A0 00 00     movss   xmm1, dword ptr [rbx+0A0F0h]
00007FF91DFD6DC1  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD6DC5  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD6DC9  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD6DCD  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD6DD1  F3 0F 11 93 50 A1 00 00     movss   dword ptr [rbx+0A150h], xmm2
00007FF91DFD6DD9  F3 0F 10 8B 60 A1 00 00     movss   xmm1, dword ptr [rbx+0A160h]
00007FF91DFD6DE1  F3 0F 11 8B 70 A1 00 00     movss   dword ptr [rbx+0A170h], xmm1
00007FF91DFD6DE9  F3 0F 10 83 80 A1 00 00     movss   xmm0, dword ptr [rbx+0A180h]
00007FF91DFD6DF1  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFD6DF4  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD6DF8  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFD6DFC  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD6E00  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD6E04  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFD6E08  76 05                       jbe     short loc_7FF91DFD6E0F
00007FF91DFD6E0A  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFD6E0D  EB 03                       jmp     short loc_7FF91DFD6E12
00007FF91DFD6E0F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD6E12  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD6E16  F3 0F 11 83 60 A1 00 00     movss   dword ptr [rbx+0A160h], xmm0
00007FF91DFD6E1E  F3 0F 10 8B 90 A1 00 00     movss   xmm1, dword ptr [rbx+0A190h]
00007FF91DFD6E26  F3 0F 11 8B A0 A1 00 00     movss   dword ptr [rbx+0A1A0h], xmm1
00007FF91DFD6E2E  F3 0F 10 93 B0 A1 00 00     movss   xmm2, dword ptr [rbx+0A1B0h]
00007FF91DFD6E36  F3 0F 11 93 C0 A1 00 00     movss   dword ptr [rbx+0A1C0h], xmm2
00007FF91DFD6E3E  F3 0F 10 83 D0 A1 00 00     movss   xmm0, dword ptr [rbx+0A1D0h]
00007FF91DFD6E46  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFD6E49  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD6E4D  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFD6E51  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD6E55  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD6E59  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFD6E5D  76 05                       jbe     short loc_7FF91DFD6E64
00007FF91DFD6E5F  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFD6E62  EB 03                       jmp     short loc_7FF91DFD6E67
00007FF91DFD6E64  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD6E67  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD6E6B  F3 0F 11 83 B0 A1 00 00     movss   dword ptr [rbx+0A1B0h], xmm0
00007FF91DFD6E73  F3 0F 10 AB E0 A1 00 00     movss   xmm5, dword ptr [rbx+0A1E0h]
00007FF91DFD6E7B  F3 0F 10 B3 60 7D 00 00     movss   xmm6, dword ptr [rbx+7D60h]
00007FF91DFD6E83  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFD6E86  F3 0F 11 AB F0 A1 00 00     movss   dword ptr [rbx+0A1F0h], xmm5
00007FF91DFD6E8E  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD6E91  F3 0F 59 A3 40 A2 00 00     mulss   xmm4, dword ptr [rbx+0A240h]
00007FF91DFD6E99  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFD6E9C  F3 0F 58 83 10 A2 00 00     addss   xmm0, dword ptr [rbx+0A210h]
00007FF91DFD6EA4  F3 0F 58 9B 30 A2 00 00     addss   xmm3, dword ptr [rbx+0A230h]
00007FF91DFD6EAC  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD6EB0  73 06                       jnb     short loc_7FF91DFD6EB8
00007FF91DFD6EB2  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD6EB6  EB 05                       jmp     short loc_7FF91DFD6EBD
00007FF91DFD6EB8  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD6EBD  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD6EC1  72 1B                       jb      short loc_7FF91DFD6EDE
00007FF91DFD6EC3  F3 0F 10 83 20 A2 00 00     movss   xmm0, dword ptr [rbx+0A220h]
00007FF91DFD6ECB  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFD6ECE  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD6ED2  F3 0F 59 DE                 mulss   xmm3, xmm6
00007FF91DFD6ED6  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD6EDA  F3 0F 58 DD                 addss   xmm3, xmm5
00007FF91DFD6EDE  41 0F 2E F6                 ucomiss xmm6, xmm14
00007FF91DFD6EE2  F3 0F 10 8B 60 A2 00 00     movss   xmm1, dword ptr [rbx+0A260h]
00007FF91DFD6EEA  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD6EED  F3 0F 59 93 50 A2 00 00     mulss   xmm2, dword ptr [rbx+0A250h]
00007FF91DFD6EF5  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD6EF8  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD6EFC  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD6F00  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD6F04  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD6F07  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD6F0B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD6F0F  F3 0F 5C C2                 subss   xmm0, xmm2
00007FF91DFD6F13  F3 0F 58 C5                 addss   xmm0, xmm5
00007FF91DFD6F17  74 03                       jz      short loc_7FF91DFD6F1C
00007FF91DFD6F19  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD6F1C  F3 0F 11 83 00 A2 00 00     movss   dword ptr [rbx+0A200h], xmm0
00007FF91DFD6F24  F3 0F 11 83 E0 A1 00 00     movss   dword ptr [rbx+0A1E0h], xmm0
00007FF91DFD6F2C  F3 0F 10 BB 80 9E 00 00     movss   xmm7, dword ptr [rbx+9E80h]
00007FF91DFD6F34  F3 0F 10 B3 F0 85 00 00     movss   xmm6, dword ptr [rbx+85F0h]
00007FF91DFD6F3C  F3 0F 10 9B F0 95 00 00     movss   xmm3, dword ptr [rbx+95F0h]
00007FF91DFD6F44  F3 0F 10 83 D0 87 00 00     movss   xmm0, dword ptr [rbx+87D0h]
00007FF91DFD6F4C  F3 0F 10 8B 80 A0 00 00     movss   xmm1, dword ptr [rbx+0A080h]
00007FF91DFD6F54  8B 83 A0 A2 00 00           mov     eax, [rbx+0A2A0h]
00007FF91DFD6F5A  89 83 B0 A2 00 00           mov     [rbx+0A2B0h], eax
00007FF91DFD6F60  8B 83 C0 A2 00 00           mov     eax, [rbx+0A2C0h]
00007FF91DFD6F66  89 83 D0 A2 00 00           mov     [rbx+0A2D0h], eax
00007FF91DFD6F6C  F3 0F 11 83 70 A2 00 00     movss   dword ptr [rbx+0A270h], xmm0
00007FF91DFD6F74  F3 0F 11 8B 80 A2 00 00     movss   dword ptr [rbx+0A280h], xmm1
00007FF91DFD6F7C  F3 0F 59 9B 90 A3 00 00     mulss   xmm3, dword ptr [rbx+0A390h]
00007FF91DFD6F84  F3 0F 10 A3 B0 A2 00 00     movss   xmm4, dword ptr [rbx+0A2B0h]
00007FF91DFD6F8C  F3 0F 10 93 F0 A2 00 00     movss   xmm2, dword ptr [rbx+0A2F0h]
00007FF91DFD6F94  F3 0F 11 9B 90 A2 00 00     movss   dword ptr [rbx+0A290h], xmm3
00007FF91DFD6F9C  0F 28 DF                    movaps  xmm3, xmm7
00007FF91DFD6F9F  F3 0F 59 B3 00 A3 00 00     mulss   xmm6, dword ptr [rbx+0A300h]
00007FF91DFD6FA7  F3 0F 5C DC                 subss   xmm3, xmm4
00007FF91DFD6FAB  F3 0F 59 93 00 A2 00 00     mulss   xmm2, dword ptr [rbx+0A200h]
00007FF91DFD6FB3  F3 0F 10 8B 10 A3 00 00     movss   xmm1, dword ptr [rbx+0A310h]
00007FF91DFD6FBB  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD6FBE  F3 0F 59 83 30 A3 00 00     mulss   xmm0, dword ptr [rbx+0A330h]
00007FF91DFD6FC6  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFD6FCA  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD6FCE  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD6FD2  F3 0F 11 A3 A0 A2 00 00     movss   dword ptr [rbx+0A2A0h], xmm4
00007FF91DFD6FDA  F3 0F 59 8B 70 A2 00 00     mulss   xmm1, dword ptr [rbx+0A270h]
00007FF91DFD6FE2  F3 0F 10 93 20 A3 00 00     movss   xmm2, dword ptr [rbx+0A320h]
00007FF91DFD6FEA  F3 0F 59 9B A0 A3 00 00     mulss   xmm3, dword ptr [rbx+0A3A0h]
00007FF91DFD6FF2  F3 0F 59 A3 B0 A3 00 00     mulss   xmm4, dword ptr [rbx+0A3B0h]
00007FF91DFD6FFA  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFD6FFE  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD7001  F3 0F 59 8B 80 A2 00 00     mulss   xmm1, dword ptr [rbx+0A280h]
00007FF91DFD7009  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD700D  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD7011  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFD7015  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFD7019  F3 0F 10 B3 40 A3 00 00     movss   xmm6, dword ptr [rbx+0A340h]
00007FF91DFD7021  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFD7025  F3 0F 59 8B 70 A3 00 00     mulss   xmm1, dword ptr [rbx+0A370h]
00007FF91DFD702D  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFD7031  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD7035  76 05                       jbe     short loc_7FF91DFD703C
00007FF91DFD7037  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFD703A  EB 03                       jmp     short loc_7FF91DFD703F
00007FF91DFD703C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD703F  F3 0F 10 93 60 A3 00 00     movss   xmm2, dword ptr [rbx+0A360h]
00007FF91DFD7047  F3 0F 10 A3 50 A3 00 00     movss   xmm4, dword ptr [rbx+0A350h]
00007FF91DFD704F  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFD7053  F3 0F 10 83 90 A2 00 00     movss   xmm0, dword ptr [rbx+0A290h]
00007FF91DFD705B  F3 0F 59 AB 80 A3 00 00     mulss   xmm5, dword ptr [rbx+0A380h]
00007FF91DFD7063  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD7068  F3 0F 59 F3                 mulss   xmm6, xmm3
00007FF91DFD706C  F3 0F 10 9B D0 A2 00 00     movss   xmm3, dword ptr [rbx+0A2D0h]
00007FF91DFD7074  F3 0F 58 F7                 addss   xmm6, xmm7
00007FF91DFD7078  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFD707C  F3 0F 10 83 C0 A3 00 00     movss   xmm0, dword ptr [rbx+0A3C0h]
00007FF91DFD7084  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFD7087  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD708B  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFD708F  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD7093  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD7097  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD709B  F3 0F 11 9B C0 A2 00 00     movss   dword ptr [rbx+0A2C0h], xmm3
00007FF91DFD70A3  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFD70A7  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFD70AB  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD70AF  F3 0F 59 A3 D0 A3 00 00     mulss   xmm4, dword ptr [rbx+0A3D0h]
00007FF91DFD70B7  F3 0F 11 A3 E0 A2 00 00     movss   dword ptr [rbx+0A2E0h], xmm4
00007FF91DFD70BF  8B 83 F0 A3 00 00           mov     eax, [rbx+0A3F0h]
00007FF91DFD70C5  89 83 00 A4 00 00           mov     [rbx+0A400h], eax
00007FF91DFD70CB  8B 83 E0 A3 00 00           mov     eax, [rbx+0A3E0h]
00007FF91DFD70D1  89 83 F0 A3 00 00           mov     [rbx+0A3F0h], eax
00007FF91DFD70D7  F3 0F 10 83 00 A4 00 00     movss   xmm0, dword ptr [rbx+0A400h]
00007FF91DFD70DF  F3 0F 10 8B 10 A4 00 00     movss   xmm1, dword ptr [rbx+0A410h]
00007FF91DFD70E7  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFD70EB  F3 0F 11 A3 E0 A3 00 00     movss   dword ptr [rbx+0A3E0h], xmm4
00007FF91DFD70F3  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD70F7  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD70FB  F3 0F 11 8B F0 A3 00 00     movss   dword ptr [rbx+0A3F0h], xmm1
00007FF91DFD7103  F3 0F 10 93 E0 A3 00 00     movss   xmm2, dword ptr [rbx+0A3E0h]
00007FF91DFD710B  F3 0F 10 B3 D0 A0 00 00     movss   xmm6, dword ptr [rbx+0A0D0h]
00007FF91DFD7113  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD7116  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFD711A  8B 83 40 A4 00 00           mov     eax, [rbx+0A440h]
00007FF91DFD7120  89 83 50 A4 00 00           mov     [rbx+0A450h], eax
00007FF91DFD7126  8B 83 30 A4 00 00           mov     eax, [rbx+0A430h]
00007FF91DFD712C  89 83 40 A4 00 00           mov     [rbx+0A440h], eax
00007FF91DFD7132  8B 83 20 A4 00 00           mov     eax, [rbx+0A420h]
00007FF91DFD7138  89 83 30 A4 00 00           mov     [rbx+0A430h], eax
00007FF91DFD713E  F3 0F 11 93 20 A4 00 00     movss   dword ptr [rbx+0A420h], xmm2
00007FF91DFD7146  F3 0F 59 83 70 A4 00 00     mulss   xmm0, dword ptr [rbx+0A470h]
00007FF91DFD714E  F3 0F 10 A3 30 A4 00 00     movss   xmm4, dword ptr [rbx+0A430h]
00007FF91DFD7156  F3 0F 10 8B 90 A4 00 00     movss   xmm1, dword ptr [rbx+0A490h]
00007FF91DFD715E  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFD7161  F3 0F 59 8B 40 A4 00 00     mulss   xmm1, dword ptr [rbx+0A440h]
00007FF91DFD7169  F3 0F 59 AB 80 A4 00 00     mulss   xmm5, dword ptr [rbx+0A480h]
00007FF91DFD7171  F3 0F 59 A3 B0 A4 00 00     mulss   xmm4, dword ptr [rbx+0A4B0h]
00007FF91DFD7179  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD717D  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD7180  F3 0F 59 83 A0 A4 00 00     mulss   xmm0, dword ptr [rbx+0A4A0h]
00007FF91DFD7188  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD718C  F3 0F 10 8B C0 A4 00 00     movss   xmm1, dword ptr [rbx+0A4C0h]
00007FF91DFD7194  F3 0F 59 8B 50 A4 00 00     mulss   xmm1, dword ptr [rbx+0A450h]
00007FF91DFD719C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD71A0  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD71A4  76 05                       jbe     short loc_7FF91DFD71AB
00007FF91DFD71A6  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFD71A9  EB 03                       jmp     short loc_7FF91DFD71AE
00007FF91DFD71AB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD71AE  0F 2F 35 0B E3 76 00        comiss  xmm6, cs:dword_7FF91E7454C0
00007FF91DFD71B5  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD71B9  F3 0F 11 AB 30 A4 00 00     movss   dword ptr [rbx+0A430h], xmm5
00007FF91DFD71C1  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFD71C4  F3 0F 11 A3 40 A4 00 00     movss   dword ptr [rbx+0A440h], xmm4
00007FF91DFD71CC  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD71D0  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD71D4  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD71D8  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD71DB  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFD71DF  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD71E3  73 09                       jnb     short loc_7FF91DFD71EE
00007FF91DFD71E5  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFD71E9  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
00007FF91DFD71EE  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFD71F2  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
00007FF91DFD71F7  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFD71FA  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD71FE  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD7202  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD7206  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD720A  72 03                       jb      short loc_7FF91DFD720F
00007FF91DFD720C  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFD720F  F3 0F 11 93 60 A4 00 00     movss   dword ptr [rbx+0A460h], xmm2
00007FF91DFD7217  F3 0F 59 93 60 A1 00 00     mulss   xmm2, dword ptr [rbx+0A160h]
00007FF91DFD721F  F3 0F 11 93 D0 A4 00 00     movss   dword ptr [rbx+0A4D0h], xmm2
00007FF91DFD7227  F3 0F 59 93 B0 A1 00 00     mulss   xmm2, dword ptr [rbx+0A1B0h]
00007FF91DFD722F  F3 0F 11 93 E0 A4 00 00     movss   dword ptr [rbx+0A4E0h], xmm2
00007FF91DFD7237  F3 0F 10 83 90 8C 00 00     movss   xmm0, dword ptr [rbx+8C90h]
00007FF91DFD723F  F3 0F 58 83 F0 89 00 00     addss   xmm0, dword ptr [rbx+89F0h]
00007FF91DFD7247  44 0F 5A E0                 cvtps2pd xmm12, xmm0
00007FF91DFD724B  F2 44 0F 5F 25 54 3A 61 00  maxsd   xmm12, cs:qword_7FF91E5EACA8
00007FF91DFD7254  F2 44 0F 5D 25 33 3A 61 00  minsd   xmm12, cs:qword_7FF91E5EAC90
00007FF91DFD725D  41 0F 28 CC                 movaps  xmm1, xmm12
00007FF91DFD7261  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFD7265  F2 0F 58 05 FB DF 76 00     addsd   xmm0, cs:qword_7FF91E745268
00007FF91DFD726D  F2 41 0F 59 CC              mulsd   xmm1, xmm12
00007FF91DFD7272  41 0F 28 FC                 movaps  xmm7, xmm12
00007FF91DFD7276  F2 0F 2C C0                 cvttsd2si eax, xmm0
00007FF91DFD727A  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFD727D  48 63 C8                    movsxd  rcx, eax
00007FF91DFD7280  F2 41 0F 59 D4              mulsd   xmm2, xmm12
00007FF91DFD7285  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
00007FF91DFD728C  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD728F  F2 41 0F 59 DC              mulsd   xmm3, xmm12
00007FF91DFD7294  48 8D 0D 45 22 61 00        lea     rcx, unk_7FF91E5E94E0
00007FF91DFD729B  48 03 C1                    add     rax, rcx
00007FF91DFD729E  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFD72A1  F2 41 0F 59 E4              mulsd   xmm4, xmm12
00007FF91DFD72A6  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
00007FF91DFD72AB  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
00007FF91DFD72B0  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
00007FF91DFD72B5  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFD72B8  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
00007FF91DFD72BC  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
00007FF91DFD72C1  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
00007FF91DFD72C6  F2 0F 58 F9                 addsd   xmm7, xmm1
00007FF91DFD72CA  F2 41 0F 59 EC              mulsd   xmm5, xmm12
00007FF91DFD72CF  F2 0F 58 FA                 addsd   xmm7, xmm2
00007FF91DFD72D3  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFD72D6  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
00007FF91DFD72DB  F2 41 0F 59 F4              mulsd   xmm6, xmm12
00007FF91DFD72E0  F2 0F 58 FB                 addsd   xmm7, xmm3
00007FF91DFD72E4  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFD72E8  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
00007FF91DFD72ED  F2 0F 58 FC                 addsd   xmm7, xmm4
00007FF91DFD72F1  F2 45 0F 59 C4              mulsd   xmm8, xmm12
00007FF91DFD72F6  F2 0F 58 FD                 addsd   xmm7, xmm5
00007FF91DFD72FA  45 0F 28 C8                 movaps  xmm9, xmm8
00007FF91DFD72FE  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
00007FF91DFD7307  F2 45 0F 59 CC              mulsd   xmm9, xmm12
00007FF91DFD730C  F2 0F 58 FE                 addsd   xmm7, xmm6
00007FF91DFD7310  45 0F 28 D1                 movaps  xmm10, xmm9
00007FF91DFD7314  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
00007FF91DFD731D  F2 41 0F 58 F8              addsd   xmm7, xmm8
00007FF91DFD7322  F2 45 0F 59 D4              mulsd   xmm10, xmm12
00007FF91DFD7327  F2 41 0F 58 F9              addsd   xmm7, xmm9
00007FF91DFD732C  45 0F 28 DA                 movaps  xmm11, xmm10
00007FF91DFD7330  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
00007FF91DFD7339  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFD733E  F2 41 0F 58 FA              addsd   xmm7, xmm10
00007FF91DFD7343  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFD7347  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFD734C  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
00007FF91DFD7354  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
00007FF91DFD735D  F2 0F 58 F8                 addsd   xmm7, xmm0
00007FF91DFD7361  F2 41 0F 58 FB              addsd   xmm7, xmm11
00007FF91DFD7366  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
00007FF91DFD736A  F3 0F 5D 1D 26 39 61 00     minss   xmm3, cs:dword_7FF91E5EAC98
00007FF91DFD7372  F3 0F 5F 1D 36 39 61 00     maxss   xmm3, cs:dword_7FF91E5EACB0
00007FF91DFD737A  F3 0F 59 9B 00 8A 00 00     mulss   xmm3, dword ptr [rbx+8A00h]
00007FF91DFD7382  F3 0F 11 9B 70 8C 00 00     movss   dword ptr [rbx+8C70h], xmm3
00007FF91DFD738A  8B 83 10 8E 00 00           mov     eax, [rbx+8E10h]
00007FF91DFD7390  F3 0F 10 AB F0 89 00 00     movss   xmm5, dword ptr [rbx+89F0h]
00007FF91DFD7398  F3 0F 10 83 C0 8B 00 00     movss   xmm0, dword ptr [rbx+8BC0h]
00007FF91DFD73A0  F3 0F 10 8B D0 8B 00 00     movss   xmm1, dword ptr [rbx+8BD0h]
00007FF91DFD73A8  F3 0F 10 93 E0 8B 00 00     movss   xmm2, dword ptr [rbx+8BE0h]
00007FF91DFD73B0  89 83 20 8E 00 00           mov     [rbx+8E20h], eax
00007FF91DFD73B6  8B 83 30 8E 00 00           mov     eax, [rbx+8E30h]
00007FF91DFD73BC  89 83 40 8E 00 00           mov     [rbx+8E40h], eax
00007FF91DFD73C2  8B 83 E0 8E 00 00           mov     eax, [rbx+8EE0h]
00007FF91DFD73C8  89 83 F0 8E 00 00           mov     [rbx+8EF0h], eax
00007FF91DFD73CE  8B 83 D0 8E 00 00           mov     eax, [rbx+8ED0h]
00007FF91DFD73D4  89 83 E0 8E 00 00           mov     [rbx+8EE0h], eax
00007FF91DFD73DA  8B 83 C0 8E 00 00           mov     eax, [rbx+8EC0h]
00007FF91DFD73E0  89 83 D0 8E 00 00           mov     [rbx+8ED0h], eax
00007FF91DFD73E6  8B 83 B0 8E 00 00           mov     eax, [rbx+8EB0h]
00007FF91DFD73EC  89 83 C0 8E 00 00           mov     [rbx+8EC0h], eax
00007FF91DFD73F2  8B 83 A0 8E 00 00           mov     eax, [rbx+8EA0h]
00007FF91DFD73F8  89 83 B0 8E 00 00           mov     [rbx+8EB0h], eax
00007FF91DFD73FE  8B 83 90 8E 00 00           mov     eax, [rbx+8E90h]
00007FF91DFD7404  89 83 A0 8E 00 00           mov     [rbx+8EA0h], eax
00007FF91DFD740A  8B 83 80 8E 00 00           mov     eax, [rbx+8E80h]
00007FF91DFD7410  89 83 90 8E 00 00           mov     [rbx+8E90h], eax
00007FF91DFD7416  8B 83 60 8F 00 00           mov     eax, [rbx+8F60h]
00007FF91DFD741C  89 83 70 8F 00 00           mov     [rbx+8F70h], eax
00007FF91DFD7422  8B 83 50 8F 00 00           mov     eax, [rbx+8F50h]
00007FF91DFD7428  89 83 60 8F 00 00           mov     [rbx+8F60h], eax
00007FF91DFD742E  8B 83 40 8F 00 00           mov     eax, [rbx+8F40h]
00007FF91DFD7434  89 83 50 8F 00 00           mov     [rbx+8F50h], eax
00007FF91DFD743A  8B 83 30 8F 00 00           mov     eax, [rbx+8F30h]
00007FF91DFD7440  89 83 40 8F 00 00           mov     [rbx+8F40h], eax
00007FF91DFD7446  8B 83 20 8F 00 00           mov     eax, [rbx+8F20h]
00007FF91DFD744C  89 83 30 8F 00 00           mov     [rbx+8F30h], eax
00007FF91DFD7452  8B 83 10 8F 00 00           mov     eax, [rbx+8F10h]
00007FF91DFD7458  89 83 20 8F 00 00           mov     [rbx+8F20h], eax
00007FF91DFD745E  8B 83 00 8F 00 00           mov     eax, [rbx+8F00h]
00007FF91DFD7464  89 83 10 8F 00 00           mov     [rbx+8F10h], eax
00007FF91DFD746A  8B 83 E0 8F 00 00           mov     eax, [rbx+8FE0h]
00007FF91DFD7470  89 83 F0 8F 00 00           mov     [rbx+8FF0h], eax
00007FF91DFD7476  8B 83 D0 8F 00 00           mov     eax, [rbx+8FD0h]
00007FF91DFD747C  89 83 E0 8F 00 00           mov     [rbx+8FE0h], eax
00007FF91DFD7482  8B 83 C0 8F 00 00           mov     eax, [rbx+8FC0h]
00007FF91DFD7488  89 83 D0 8F 00 00           mov     [rbx+8FD0h], eax
00007FF91DFD748E  8B 83 B0 8F 00 00           mov     eax, [rbx+8FB0h]
00007FF91DFD7494  89 83 C0 8F 00 00           mov     [rbx+8FC0h], eax
00007FF91DFD749A  8B 83 A0 8F 00 00           mov     eax, [rbx+8FA0h]
00007FF91DFD74A0  89 83 B0 8F 00 00           mov     [rbx+8FB0h], eax
00007FF91DFD74A6  8B 83 90 8F 00 00           mov     eax, [rbx+8F90h]
00007FF91DFD74AC  89 83 A0 8F 00 00           mov     [rbx+8FA0h], eax
00007FF91DFD74B2  8B 83 80 8F 00 00           mov     eax, [rbx+8F80h]
00007FF91DFD74B8  89 83 90 8F 00 00           mov     [rbx+8F90h], eax
00007FF91DFD74BE  8B 83 60 90 00 00           mov     eax, [rbx+9060h]
00007FF91DFD74C4  89 83 70 90 00 00           mov     [rbx+9070h], eax
00007FF91DFD74CA  8B 83 50 90 00 00           mov     eax, [rbx+9050h]
00007FF91DFD74D0  89 83 60 90 00 00           mov     [rbx+9060h], eax
00007FF91DFD74D6  8B 83 40 90 00 00           mov     eax, [rbx+9040h]
00007FF91DFD74DC  89 83 50 90 00 00           mov     [rbx+9050h], eax
00007FF91DFD74E2  8B 83 30 90 00 00           mov     eax, [rbx+9030h]
00007FF91DFD74E8  89 83 40 90 00 00           mov     [rbx+9040h], eax
00007FF91DFD74EE  8B 83 20 90 00 00           mov     eax, [rbx+9020h]
00007FF91DFD74F4  89 83 30 90 00 00           mov     [rbx+9030h], eax
00007FF91DFD74FA  8B 83 10 90 00 00           mov     eax, [rbx+9010h]
00007FF91DFD7500  89 83 20 90 00 00           mov     [rbx+9020h], eax
00007FF91DFD7506  8B 83 00 90 00 00           mov     eax, [rbx+9000h]
00007FF91DFD750C  89 83 10 90 00 00           mov     [rbx+9010h], eax
00007FF91DFD7512  8B 83 A0 90 00 00           mov     eax, [rbx+90A0h]
00007FF91DFD7518  89 83 B0 90 00 00           mov     [rbx+90B0h], eax
00007FF91DFD751E  8B 83 90 90 00 00           mov     eax, [rbx+9090h]
00007FF91DFD7524  89 83 A0 90 00 00           mov     [rbx+90A0h], eax
00007FF91DFD752A  F3 0F 11 83 B0 8D 00 00     movss   dword ptr [rbx+8DB0h], xmm0
00007FF91DFD7532  F3 0F 11 8B C0 8D 00 00     movss   dword ptr [rbx+8DC0h], xmm1
00007FF91DFD753A  F3 0F 58 AB D0 93 00 00     addss   xmm5, dword ptr [rbx+93D0h]
00007FF91DFD7542  F3 0F 59 9B D0 90 00 00     mulss   xmm3, dword ptr [rbx+90D0h]
00007FF91DFD754A  F3 0F 10 83 C0 90 00 00     movss   xmm0, dword ptr [rbx+90C0h]
00007FF91DFD7552  F3 0F 11 93 D0 8D 00 00     movss   dword ptr [rbx+8DD0h], xmm2
00007FF91DFD755A  F3 0F 10 93 F0 90 00 00     movss   xmm2, dword ptr [rbx+90F0h]
00007FF91DFD7562  F3 0F 59 AB E0 93 00 00     mulss   xmm5, dword ptr [rbx+93E0h]
00007FF91DFD756A  F3 0F 5F D3                 maxss   xmm2, xmm3
00007FF91DFD756E  F3 0F 58 AB C0 93 00 00     addss   xmm5, dword ptr [rbx+93C0h]
00007FF91DFD7576  F3 0F 11 93 E0 8D 00 00     movss   dword ptr [rbx+8DE0h], xmm2
00007FF91DFD757E  F3 0F 58 83 10 8A 00 00     addss   xmm0, dword ptr [rbx+8A10h]
00007FF91DFD7586  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFD758A  F3 0F 11 83 00 8E 00 00     movss   dword ptr [rbx+8E00h], xmm0
00007FF91DFD7592  76 05                       jbe     short loc_7FF91DFD7599
00007FF91DFD7594  0F 5A C5                    cvtps2pd xmm0, xmm5
00007FF91DFD7597  EB 03                       jmp     short loc_7FF91DFD759C
00007FF91DFD7599  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD759C  F3 0F 10 0D B8 D9 76 00     movss   xmm1, cs:dword_7FF91E744F5C
00007FF91DFD75A4  F3 44 0F 10 15 3B DC 76 00  movss   xmm10, cs:flt_7FF91E7451E8
00007FF91DFD75AD  F3 0F 5E CA                 divss   xmm1, xmm2
00007FF91DFD75B1  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD75B5  F3 0F 11 8B F0 8D 00 00     movss   dword ptr [rbx+8DF0h], xmm1
00007FF91DFD75BD  F3 0F 11 83 80 90 00 00     movss   dword ptr [rbx+9080h], xmm0
00007FF91DFD75C5  F3 0F 10 B3 40 8E 00 00     movss   xmm6, dword ptr [rbx+8E40h]
00007FF91DFD75CD  F3 0F 10 8B 20 8E 00 00     movss   xmm1, dword ptr [rbx+8E20h]
00007FF91DFD75D5  F3 0F 11 B3 60 8D 00 00     movss   dword ptr [rbx+8D60h], xmm6
00007FF91DFD75DD  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFD75E1  F3 0F 11 8B 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm1
00007FF91DFD75E9  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD75ED  76 1B                       jbe     short loc_7FF91DFD760A
00007FF91DFD75EF  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD75F4  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD75F8  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD75FB  E8 D8 7E 37 00              call    fmodf
00007FF91DFD7600  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD7603  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD7608  EB 1F                       jmp     short loc_7FF91DFD7629
00007FF91DFD760A  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD760E  73 19                       jnb     short loc_7FF91DFD7629
00007FF91DFD7610  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD7615  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD7619  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD761C  E8 B7 7E 37 00              call    fmodf
00007FF91DFD7621  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD7624  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD7629  F3 44 0F 10 25 DA D9 76 00  movss   xmm12, cs:dword_7FF91E74500C
00007FF91DFD7632  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD7635  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD763A  F3 0F 11 B3 50 8D 00 00     movss   dword ptr [rbx+8D50h], xmm6
00007FF91DFD7642  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD7645  F3 0F 59 BB 40 91 00 00     mulss   xmm7, dword ptr [rbx+9140h]
00007FF91DFD764D  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFD7652  E8 69 19 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD7657  F3 44 0F 10 1D E4 DD 76 00  movss   xmm11, cs:dword_7FF91E745444
00007FF91DFD7660  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFD7663  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFD7668  F3 0F 59 AB F0 8D 00 00     mulss   xmm5, dword ptr [rbx+8DF0h]
00007FF91DFD7670  F3 0F 59 AB 10 91 00 00     mulss   xmm5, dword ptr [rbx+9110h]
00007FF91DFD7678  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD767C  73 06                       jnb     short loc_7FF91DFD7684
00007FF91DFD767E  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD7682  EB 05                       jmp     short loc_7FF91DFD7689
00007FF91DFD7684  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD7689  F3 0F 59 AB E0 90 00 00     mulss   xmm5, dword ptr [rbx+90E0h]
00007FF91DFD7691  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD7694  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD7698  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD769B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD769E  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD76A6  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD76A9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD76AD  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD76B0  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
00007FF91DFD76B8  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD76C0  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD76C4  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
00007FF91DFD76CC  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD76D0  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD76D3  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD76DB  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD76DF  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD76E3  F3 0F 10 8B 00 8E 00 00     movss   xmm1, dword ptr [rbx+8E00h]
00007FF91DFD76EB  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD76EF  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD76F2  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFD76F6  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD76FA  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD76FE  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD7702  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD7706  F3 0F 11 A3 50 8E 00 00     movss   dword ptr [rbx+8E50h], xmm4
00007FF91DFD770E  72 07                       jb      short loc_7FF91DFD7717
00007FF91DFD7710  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD7715  EB 05                       jmp     short loc_7FF91DFD771C
00007FF91DFD7717  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFD771C  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD771F  73 06                       jnb     short loc_7FF91DFD7727
00007FF91DFD7721  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFD7725  EB 06                       jmp     short loc_7FF91DFD772D
00007FF91DFD7727  76 04                       jbe     short loc_7FF91DFD772D
00007FF91DFD7729  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD772D  F3 44 0F 10 83 50 8D 00 00  movss   xmm8, dword ptr [rbx+8D50h]
00007FF91DFD7736  F3 0F 59 B3 50 91 00 00     mulss   xmm6, dword ptr [rbx+9150h]
00007FF91DFD773E  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFD7742  E8 79 18 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD7747  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD774A  F3 0F 10 83 00 91 00 00     movss   xmm0, dword ptr [rbx+9100h]
00007FF91DFD7752  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFD7756  72 18                       jb      short loc_7FF91DFD7770
00007FF91DFD7758  0F 2F 83 60 8D 00 00        comiss  xmm0, dword ptr [rbx+8D60h]
00007FF91DFD775F  76 0F                       jbe     short loc_7FF91DFD7770
00007FF91DFD7761  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
00007FF91DFD7769  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFD776E  EB 08                       jmp     short loc_7FF91DFD7778
00007FF91DFD7770  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
00007FF91DFD7778  0F 2F 3D 51 DB 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFD777F  F3 0F 59 A3 F0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DF0h]
00007FF91DFD7787  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFD778C  F3 0F 59 A3 20 91 00 00     mulss   xmm4, dword ptr [rbx+9120h]
00007FF91DFD7794  72 03                       jb      short loc_7FF91DFD7799
00007FF91DFD7796  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD7799  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD779D  73 06                       jnb     short loc_7FF91DFD77A5
00007FF91DFD779F  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD77A3  EB 05                       jmp     short loc_7FF91DFD77AA
00007FF91DFD77A5  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD77AA  F3 0F 11 BB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm7
00007FF91DFD77B2  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD77B7  F3 0F 59 A3 E0 90 00 00     mulss   xmm4, dword ptr [rbx+90E0h]
00007FF91DFD77BF  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD77C2  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD77C7  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD77CB  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD77CE  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFD77D3  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD77D7  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD77DA  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD77DE  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFD77E2  F3 44 0F 59 8B B0 92 00 00  mulss   xmm9, dword ptr [rbx+92B0h]
00007FF91DFD77EB  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD77F0  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD77F3  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD77FB  F3 44 0F 58 8B A0 92 00 00  addss   xmm9, dword ptr [rbx+92A0h]
00007FF91DFD7804  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD780C  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD7811  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD7814  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD781C  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFD7821  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7825  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD782A  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD782D  0F 54 05 5C DF 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFD7834  0F 57 05 85 DF 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD783B  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFD7840  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFD7845  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFD784A  F3 44 0F 11 8B 60 8E 00 00  movss   dword ptr [rbx+8E60h], xmm9
00007FF91DFD7853  E8 68 17 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD7858  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD785C  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD7860  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD7865  73 06                       jnb     short loc_7FF91DFD786D
00007FF91DFD7867  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD786B  EB 06                       jmp     short loc_7FF91DFD7873
00007FF91DFD786D  76 04                       jbe     short loc_7FF91DFD7873
00007FF91DFD786F  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD7873  F3 44 0F 59 83 F0 8D 00 00  mulss   xmm8, dword ptr [rbx+8DF0h]
00007FF91DFD787C  F3 0F 59 BB 60 91 00 00     mulss   xmm7, dword ptr [rbx+9160h]
00007FF91DFD7884  F3 44 0F 59 05 0B 34 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFD788D  F3 44 0F 59 83 30 91 00 00  mulss   xmm8, dword ptr [rbx+9130h]
00007FF91DFD7896  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFD789A  73 06                       jnb     short loc_7FF91DFD78A2
00007FF91DFD789C  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFD78A0  EB 05                       jmp     short loc_7FF91DFD78A7
00007FF91DFD78A2  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFD78A7  F3 44 0F 59 83 E0 90 00 00  mulss   xmm8, dword ptr [rbx+90E0h]
00007FF91DFD78B0  F3 44 0F 59 8B C0 8D 00 00  mulss   xmm9, dword ptr [rbx+8DC0h]
00007FF91DFD78B9  F3 0F 10 B3 50 8D 00 00     movss   xmm6, dword ptr [rbx+8D50h]
00007FF91DFD78C1  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD78C5  F3 0F 10 AB 70 8D 00 00     movss   xmm5, dword ptr [rbx+8D70h]
00007FF91DFD78CD  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFD78D2  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD78D5  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD78D8  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD78DC  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD78DF  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
00007FF91DFD78E7  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD78EA  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD78F2  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
00007FF91DFD78FA  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD78FF  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD7907  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD790B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD790E  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD7916  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD791A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD791E  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD7922  F3 0F 10 83 50 8E 00 00     movss   xmm0, dword ptr [rbx+8E50h]
00007FF91DFD792A  F3 0F 59 83 B0 8D 00 00     mulss   xmm0, dword ptr [rbx+8DB0h]
00007FF91DFD7932  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD7936  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFD793B  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFD7940  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD7944  F3 0F 59 A3 D0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DD0h]
00007FF91DFD794C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD7950  F3 0F 11 A3 80 8E 00 00     movss   dword ptr [rbx+8E80h], xmm4
00007FF91DFD7958  F3 0F 11 B3 60 8D 00 00     movss   dword ptr [rbx+8D60h], xmm6
00007FF91DFD7960  F3 0F 11 AB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm5
00007FF91DFD7968  F3 0F 58 B3 E0 8D 00 00     addss   xmm6, dword ptr [rbx+8DE0h]
00007FF91DFD7970  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD7974  76 1B                       jbe     short loc_7FF91DFD7991
00007FF91DFD7976  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD797B  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD797F  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD7982  E8 51 7B 37 00              call    fmodf
00007FF91DFD7987  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD798A  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD798F  EB 1F                       jmp     short loc_7FF91DFD79B0
00007FF91DFD7991  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD7995  73 19                       jnb     short loc_7FF91DFD79B0
00007FF91DFD7997  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD799C  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD79A0  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD79A3  E8 30 7B 37 00              call    fmodf
00007FF91DFD79A8  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD79AB  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD79B0  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD79B3  F3 0F 11 B3 50 8D 00 00     movss   dword ptr [rbx+8D50h], xmm6
00007FF91DFD79BB  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD79C0  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD79C3  F3 0F 59 BB 40 91 00 00     mulss   xmm7, dword ptr [rbx+9140h]
00007FF91DFD79CB  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFD79D0  E8 EB 15 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD79D5  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFD79D8  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFD79DD  F3 0F 59 AB F0 8D 00 00     mulss   xmm5, dword ptr [rbx+8DF0h]
00007FF91DFD79E5  F3 0F 59 AB 10 91 00 00     mulss   xmm5, dword ptr [rbx+9110h]
00007FF91DFD79ED  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD79F1  73 06                       jnb     short loc_7FF91DFD79F9
00007FF91DFD79F3  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD79F7  EB 05                       jmp     short loc_7FF91DFD79FE
00007FF91DFD79F9  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD79FE  F3 0F 59 AB E0 90 00 00     mulss   xmm5, dword ptr [rbx+90E0h]
00007FF91DFD7A06  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD7A09  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD7A0D  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD7A10  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD7A13  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD7A1B  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD7A1E  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7A22  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD7A25  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
00007FF91DFD7A2D  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD7A35  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD7A39  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
00007FF91DFD7A41  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD7A45  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD7A48  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD7A50  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD7A54  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7A58  F3 0F 10 8B 00 8E 00 00     movss   xmm1, dword ptr [rbx+8E00h]
00007FF91DFD7A60  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD7A64  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD7A67  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFD7A6B  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD7A6F  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD7A73  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD7A77  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD7A7B  F3 0F 11 A3 50 8E 00 00     movss   dword ptr [rbx+8E50h], xmm4
00007FF91DFD7A83  72 07                       jb      short loc_7FF91DFD7A8C
00007FF91DFD7A85  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD7A8A  EB 05                       jmp     short loc_7FF91DFD7A91
00007FF91DFD7A8C  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFD7A91  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD7A94  73 06                       jnb     short loc_7FF91DFD7A9C
00007FF91DFD7A96  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFD7A9A  EB 06                       jmp     short loc_7FF91DFD7AA2
00007FF91DFD7A9C  76 04                       jbe     short loc_7FF91DFD7AA2
00007FF91DFD7A9E  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD7AA2  F3 44 0F 10 83 50 8D 00 00  movss   xmm8, dword ptr [rbx+8D50h]
00007FF91DFD7AAB  F3 0F 59 B3 50 91 00 00     mulss   xmm6, dword ptr [rbx+9150h]
00007FF91DFD7AB3  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFD7AB7  E8 04 15 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD7ABC  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD7ABF  F3 0F 10 83 00 91 00 00     movss   xmm0, dword ptr [rbx+9100h]
00007FF91DFD7AC7  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFD7ACB  72 18                       jb      short loc_7FF91DFD7AE5
00007FF91DFD7ACD  0F 2F 83 60 8D 00 00        comiss  xmm0, dword ptr [rbx+8D60h]
00007FF91DFD7AD4  76 0F                       jbe     short loc_7FF91DFD7AE5
00007FF91DFD7AD6  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
00007FF91DFD7ADE  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFD7AE3  EB 08                       jmp     short loc_7FF91DFD7AED
00007FF91DFD7AE5  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
00007FF91DFD7AED  0F 2F 3D DC D7 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFD7AF4  F3 0F 59 A3 F0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DF0h]
00007FF91DFD7AFC  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFD7B01  F3 0F 59 A3 20 91 00 00     mulss   xmm4, dword ptr [rbx+9120h]
00007FF91DFD7B09  72 03                       jb      short loc_7FF91DFD7B0E
00007FF91DFD7B0B  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD7B0E  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD7B12  73 06                       jnb     short loc_7FF91DFD7B1A
00007FF91DFD7B14  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD7B18  EB 05                       jmp     short loc_7FF91DFD7B1F
00007FF91DFD7B1A  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD7B1F  F3 0F 11 BB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm7
00007FF91DFD7B27  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD7B2C  F3 0F 59 A3 E0 90 00 00     mulss   xmm4, dword ptr [rbx+90E0h]
00007FF91DFD7B34  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD7B37  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD7B3C  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD7B40  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD7B43  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFD7B48  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7B4C  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD7B4F  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD7B53  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFD7B57  F3 44 0F 59 8B B0 92 00 00  mulss   xmm9, dword ptr [rbx+92B0h]
00007FF91DFD7B60  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD7B65  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD7B68  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD7B70  F3 44 0F 58 8B A0 92 00 00  addss   xmm9, dword ptr [rbx+92A0h]
00007FF91DFD7B79  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD7B81  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD7B86  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD7B89  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD7B91  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFD7B96  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7B9A  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD7B9F  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD7BA2  0F 54 05 E7 DB 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFD7BA9  0F 57 05 10 DC 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD7BB0  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFD7BB5  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFD7BBA  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFD7BBF  F3 44 0F 11 8B 60 8E 00 00  movss   dword ptr [rbx+8E60h], xmm9
00007FF91DFD7BC8  E8 F3 13 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD7BCD  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD7BD1  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD7BD5  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD7BDA  73 06                       jnb     short loc_7FF91DFD7BE2
00007FF91DFD7BDC  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD7BE0  EB 06                       jmp     short loc_7FF91DFD7BE8
00007FF91DFD7BE2  76 04                       jbe     short loc_7FF91DFD7BE8
00007FF91DFD7BE4  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD7BE8  F3 44 0F 59 83 F0 8D 00 00  mulss   xmm8, dword ptr [rbx+8DF0h]
00007FF91DFD7BF1  F3 0F 59 BB 60 91 00 00     mulss   xmm7, dword ptr [rbx+9160h]
00007FF91DFD7BF9  F3 44 0F 59 05 96 30 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFD7C02  F3 44 0F 59 83 30 91 00 00  mulss   xmm8, dword ptr [rbx+9130h]
00007FF91DFD7C0B  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFD7C0F  73 06                       jnb     short loc_7FF91DFD7C17
00007FF91DFD7C11  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFD7C15  EB 05                       jmp     short loc_7FF91DFD7C1C
00007FF91DFD7C17  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFD7C1C  F3 44 0F 59 83 E0 90 00 00  mulss   xmm8, dword ptr [rbx+90E0h]
00007FF91DFD7C25  F3 44 0F 59 8B C0 8D 00 00  mulss   xmm9, dword ptr [rbx+8DC0h]
00007FF91DFD7C2E  F3 0F 10 B3 50 8D 00 00     movss   xmm6, dword ptr [rbx+8D50h]
00007FF91DFD7C36  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD7C3A  F3 0F 10 AB 70 8D 00 00     movss   xmm5, dword ptr [rbx+8D70h]
00007FF91DFD7C42  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFD7C47  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD7C4A  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD7C4D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7C51  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD7C54  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
00007FF91DFD7C5C  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD7C5F  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD7C67  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
00007FF91DFD7C6F  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD7C74  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD7C7C  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD7C80  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD7C83  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD7C8B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD7C8F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7C93  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD7C97  F3 0F 10 83 50 8E 00 00     movss   xmm0, dword ptr [rbx+8E50h]
00007FF91DFD7C9F  F3 0F 59 83 B0 8D 00 00     mulss   xmm0, dword ptr [rbx+8DB0h]
00007FF91DFD7CA7  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD7CAB  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFD7CB0  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFD7CB5  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD7CB9  F3 0F 59 A3 D0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DD0h]
00007FF91DFD7CC1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD7CC5  F3 0F 11 A3 00 8F 00 00     movss   dword ptr [rbx+8F00h], xmm4
00007FF91DFD7CCD  F3 0F 11 B3 60 8D 00 00     movss   dword ptr [rbx+8D60h], xmm6
00007FF91DFD7CD5  F3 0F 11 AB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm5
00007FF91DFD7CDD  F3 0F 58 B3 E0 8D 00 00     addss   xmm6, dword ptr [rbx+8DE0h]
00007FF91DFD7CE5  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD7CE9  76 1B                       jbe     short loc_7FF91DFD7D06
00007FF91DFD7CEB  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD7CF0  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD7CF4  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD7CF7  E8 DC 77 37 00              call    fmodf
00007FF91DFD7CFC  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD7CFF  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD7D04  EB 1F                       jmp     short loc_7FF91DFD7D25
00007FF91DFD7D06  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD7D0A  73 19                       jnb     short loc_7FF91DFD7D25
00007FF91DFD7D0C  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD7D11  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD7D15  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD7D18  E8 BB 77 37 00              call    fmodf
00007FF91DFD7D1D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD7D20  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD7D25  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD7D28  F3 0F 11 B3 50 8D 00 00     movss   dword ptr [rbx+8D50h], xmm6
00007FF91DFD7D30  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD7D35  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD7D38  F3 0F 59 BB 40 91 00 00     mulss   xmm7, dword ptr [rbx+9140h]
00007FF91DFD7D40  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFD7D45  E8 76 12 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD7D4A  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFD7D4D  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFD7D52  F3 0F 59 AB F0 8D 00 00     mulss   xmm5, dword ptr [rbx+8DF0h]
00007FF91DFD7D5A  F3 0F 59 AB 10 91 00 00     mulss   xmm5, dword ptr [rbx+9110h]
00007FF91DFD7D62  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD7D66  73 06                       jnb     short loc_7FF91DFD7D6E
00007FF91DFD7D68  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD7D6C  EB 05                       jmp     short loc_7FF91DFD7D73
00007FF91DFD7D6E  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD7D73  F3 0F 59 AB E0 90 00 00     mulss   xmm5, dword ptr [rbx+90E0h]
00007FF91DFD7D7B  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD7D7E  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD7D82  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD7D85  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD7D88  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD7D90  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD7D93  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7D97  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD7D9A  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
00007FF91DFD7DA2  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD7DAA  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD7DAE  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
00007FF91DFD7DB6  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD7DBA  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD7DBD  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD7DC5  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD7DC9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7DCD  F3 0F 10 8B 00 8E 00 00     movss   xmm1, dword ptr [rbx+8E00h]
00007FF91DFD7DD5  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD7DD9  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD7DDC  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFD7DE0  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD7DE4  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD7DE8  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD7DEC  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD7DF0  F3 0F 11 A3 50 8E 00 00     movss   dword ptr [rbx+8E50h], xmm4
00007FF91DFD7DF8  72 07                       jb      short loc_7FF91DFD7E01
00007FF91DFD7DFA  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD7DFF  EB 05                       jmp     short loc_7FF91DFD7E06
00007FF91DFD7E01  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFD7E06  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD7E09  73 06                       jnb     short loc_7FF91DFD7E11
00007FF91DFD7E0B  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFD7E0F  EB 06                       jmp     short loc_7FF91DFD7E17
00007FF91DFD7E11  76 04                       jbe     short loc_7FF91DFD7E17
00007FF91DFD7E13  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD7E17  F3 44 0F 10 83 50 8D 00 00  movss   xmm8, dword ptr [rbx+8D50h]
00007FF91DFD7E20  F3 0F 59 B3 50 91 00 00     mulss   xmm6, dword ptr [rbx+9150h]
00007FF91DFD7E28  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFD7E2C  E8 8F 11 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD7E31  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD7E34  F3 0F 10 83 00 91 00 00     movss   xmm0, dword ptr [rbx+9100h]
00007FF91DFD7E3C  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFD7E40  72 18                       jb      short loc_7FF91DFD7E5A
00007FF91DFD7E42  0F 2F 83 60 8D 00 00        comiss  xmm0, dword ptr [rbx+8D60h]
00007FF91DFD7E49  76 0F                       jbe     short loc_7FF91DFD7E5A
00007FF91DFD7E4B  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
00007FF91DFD7E53  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFD7E58  EB 08                       jmp     short loc_7FF91DFD7E62
00007FF91DFD7E5A  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
00007FF91DFD7E62  0F 2F 3D 67 D4 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFD7E69  F3 0F 59 A3 F0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DF0h]
00007FF91DFD7E71  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFD7E76  F3 0F 59 A3 20 91 00 00     mulss   xmm4, dword ptr [rbx+9120h]
00007FF91DFD7E7E  72 03                       jb      short loc_7FF91DFD7E83
00007FF91DFD7E80  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD7E83  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD7E87  73 06                       jnb     short loc_7FF91DFD7E8F
00007FF91DFD7E89  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD7E8D  EB 05                       jmp     short loc_7FF91DFD7E94
00007FF91DFD7E8F  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD7E94  F3 0F 11 BB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm7
00007FF91DFD7E9C  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD7EA1  F3 0F 59 A3 E0 90 00 00     mulss   xmm4, dword ptr [rbx+90E0h]
00007FF91DFD7EA9  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD7EAC  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD7EB1  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD7EB5  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD7EB8  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFD7EBD  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7EC1  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD7EC4  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD7EC8  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFD7ECC  F3 44 0F 59 8B B0 92 00 00  mulss   xmm9, dword ptr [rbx+92B0h]
00007FF91DFD7ED5  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD7EDA  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD7EDD  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD7EE5  F3 44 0F 58 8B A0 92 00 00  addss   xmm9, dword ptr [rbx+92A0h]
00007FF91DFD7EEE  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD7EF6  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD7EFB  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD7EFE  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD7F06  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFD7F0B  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7F0F  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD7F14  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD7F17  0F 54 05 72 D8 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFD7F1E  0F 57 05 9B D8 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD7F25  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFD7F2A  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFD7F2F  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFD7F34  F3 44 0F 11 8B 60 8E 00 00  movss   dword ptr [rbx+8E60h], xmm9
00007FF91DFD7F3D  E8 7E 10 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD7F42  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD7F46  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD7F4A  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD7F4F  73 06                       jnb     short loc_7FF91DFD7F57
00007FF91DFD7F51  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD7F55  EB 06                       jmp     short loc_7FF91DFD7F5D
00007FF91DFD7F57  76 04                       jbe     short loc_7FF91DFD7F5D
00007FF91DFD7F59  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD7F5D  F3 44 0F 59 83 F0 8D 00 00  mulss   xmm8, dword ptr [rbx+8DF0h]
00007FF91DFD7F66  F3 0F 59 BB 60 91 00 00     mulss   xmm7, dword ptr [rbx+9160h]
00007FF91DFD7F6E  F3 44 0F 59 05 21 2D 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFD7F77  F3 44 0F 59 83 30 91 00 00  mulss   xmm8, dword ptr [rbx+9130h]
00007FF91DFD7F80  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFD7F84  73 06                       jnb     short loc_7FF91DFD7F8C
00007FF91DFD7F86  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFD7F8A  EB 05                       jmp     short loc_7FF91DFD7F91
00007FF91DFD7F8C  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFD7F91  F3 44 0F 59 83 E0 90 00 00  mulss   xmm8, dword ptr [rbx+90E0h]
00007FF91DFD7F9A  F3 44 0F 59 8B C0 8D 00 00  mulss   xmm9, dword ptr [rbx+8DC0h]
00007FF91DFD7FA3  F3 0F 10 B3 50 8D 00 00     movss   xmm6, dword ptr [rbx+8D50h]
00007FF91DFD7FAB  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD7FAF  F3 0F 10 AB 70 8D 00 00     movss   xmm5, dword ptr [rbx+8D70h]
00007FF91DFD7FB7  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFD7FBC  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD7FBF  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD7FC2  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD7FC6  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD7FC9  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
00007FF91DFD7FD1  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD7FD4  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD7FDC  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
00007FF91DFD7FE4  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD7FE9  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD7FF1  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD7FF5  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD7FF8  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD8000  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD8004  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD8008  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD800C  F3 0F 10 83 50 8E 00 00     movss   xmm0, dword ptr [rbx+8E50h]
00007FF91DFD8014  F3 0F 59 83 B0 8D 00 00     mulss   xmm0, dword ptr [rbx+8DB0h]
00007FF91DFD801C  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD8020  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFD8025  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFD802A  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD802E  F3 0F 59 A3 D0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DD0h]
00007FF91DFD8036  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD803A  F3 0F 11 A3 80 8F 00 00     movss   dword ptr [rbx+8F80h], xmm4
00007FF91DFD8042  F3 0F 11 B3 60 8D 00 00     movss   dword ptr [rbx+8D60h], xmm6
00007FF91DFD804A  F3 0F 11 AB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm5
00007FF91DFD8052  F3 0F 58 B3 E0 8D 00 00     addss   xmm6, dword ptr [rbx+8DE0h]
00007FF91DFD805A  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD805E  76 1B                       jbe     short loc_7FF91DFD807B
00007FF91DFD8060  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD8065  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD8069  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD806C  E8 67 74 37 00              call    fmodf
00007FF91DFD8071  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD8074  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD8079  EB 1F                       jmp     short loc_7FF91DFD809A
00007FF91DFD807B  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD807F  73 19                       jnb     short loc_7FF91DFD809A
00007FF91DFD8081  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD8086  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD808A  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD808D  E8 46 74 37 00              call    fmodf
00007FF91DFD8092  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD8095  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD809A  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD809D  F3 0F 11 B3 50 8D 00 00     movss   dword ptr [rbx+8D50h], xmm6
00007FF91DFD80A5  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD80AA  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD80AD  F3 0F 59 BB 40 91 00 00     mulss   xmm7, dword ptr [rbx+9140h]
00007FF91DFD80B5  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFD80BA  E8 01 0F FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD80BF  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFD80C2  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFD80C7  F3 0F 59 AB F0 8D 00 00     mulss   xmm5, dword ptr [rbx+8DF0h]
00007FF91DFD80CF  F3 0F 59 AB 10 91 00 00     mulss   xmm5, dword ptr [rbx+9110h]
00007FF91DFD80D7  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD80DB  73 06                       jnb     short loc_7FF91DFD80E3
00007FF91DFD80DD  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD80E1  EB 05                       jmp     short loc_7FF91DFD80E8
00007FF91DFD80E3  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD80E8  F3 0F 59 AB E0 90 00 00     mulss   xmm5, dword ptr [rbx+90E0h]
00007FF91DFD80F0  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD80F3  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD80F7  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD80FA  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD80FD  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD8105  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD8108  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD810C  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD810F  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
00007FF91DFD8117  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD811F  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD8123  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
00007FF91DFD812B  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD812F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD8132  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD813A  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD813E  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD8142  F3 0F 10 8B 00 8E 00 00     movss   xmm1, dword ptr [rbx+8E00h]
00007FF91DFD814A  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD814E  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD8151  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFD8155  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD8159  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD815D  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD8161  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD8165  F3 0F 11 A3 50 8E 00 00     movss   dword ptr [rbx+8E50h], xmm4
00007FF91DFD816D  72 07                       jb      short loc_7FF91DFD8176
00007FF91DFD816F  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD8174  EB 05                       jmp     short loc_7FF91DFD817B
00007FF91DFD8176  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFD817B  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD817E  73 06                       jnb     short loc_7FF91DFD8186
00007FF91DFD8180  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFD8184  EB 06                       jmp     short loc_7FF91DFD818C
00007FF91DFD8186  76 04                       jbe     short loc_7FF91DFD818C
00007FF91DFD8188  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD818C  F3 44 0F 10 83 50 8D 00 00  movss   xmm8, dword ptr [rbx+8D50h]
00007FF91DFD8195  F3 0F 59 B3 50 91 00 00     mulss   xmm6, dword ptr [rbx+9150h]
00007FF91DFD819D  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFD81A1  E8 1A 0E FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD81A6  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD81A9  F3 0F 10 83 00 91 00 00     movss   xmm0, dword ptr [rbx+9100h]
00007FF91DFD81B1  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFD81B5  72 18                       jb      short loc_7FF91DFD81CF
00007FF91DFD81B7  0F 2F 83 60 8D 00 00        comiss  xmm0, dword ptr [rbx+8D60h]
00007FF91DFD81BE  76 0F                       jbe     short loc_7FF91DFD81CF
00007FF91DFD81C0  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
00007FF91DFD81C8  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFD81CD  EB 08                       jmp     short loc_7FF91DFD81D7
00007FF91DFD81CF  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
00007FF91DFD81D7  0F 2F 3D F2 D0 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFD81DE  F3 0F 59 A3 F0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DF0h]
00007FF91DFD81E6  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFD81EB  F3 0F 59 A3 20 91 00 00     mulss   xmm4, dword ptr [rbx+9120h]
00007FF91DFD81F3  72 03                       jb      short loc_7FF91DFD81F8
00007FF91DFD81F5  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD81F8  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD81FC  73 06                       jnb     short loc_7FF91DFD8204
00007FF91DFD81FE  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD8202  EB 05                       jmp     short loc_7FF91DFD8209
00007FF91DFD8204  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD8209  F3 0F 11 BB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm7
00007FF91DFD8211  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD8216  F3 0F 59 A3 E0 90 00 00     mulss   xmm4, dword ptr [rbx+90E0h]
00007FF91DFD821E  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD8221  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD8226  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD822A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD822D  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFD8232  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD8236  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD8239  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD823D  44 0F 28 C2                 movaps  xmm8, xmm2
00007FF91DFD8241  F3 44 0F 59 83 B0 92 00 00  mulss   xmm8, dword ptr [rbx+92B0h]
00007FF91DFD824A  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD824F  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD8252  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD825A  F3 44 0F 58 83 A0 92 00 00  addss   xmm8, dword ptr [rbx+92A0h]
00007FF91DFD8263  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD826B  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFD8270  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD8273  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD827B  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFD8280  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD8284  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFD8289  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD828C  0F 54 05 FD D4 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFD8293  0F 57 05 26 D5 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD829A  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFD829F  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFD82A4  F3 44 0F 59 C6              mulss   xmm8, xmm6
00007FF91DFD82A9  F3 44 0F 11 83 60 8E 00 00  movss   dword ptr [rbx+8E60h], xmm8
00007FF91DFD82B2  E8 09 0D FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD82B7  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD82BB  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD82C0  73 06                       jnb     short loc_7FF91DFD82C8
00007FF91DFD82C2  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD82C6  EB 06                       jmp     short loc_7FF91DFD82CE
00007FF91DFD82C8  76 04                       jbe     short loc_7FF91DFD82CE
00007FF91DFD82CA  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD82CE  F3 0F 59 83 F0 8D 00 00     mulss   xmm0, dword ptr [rbx+8DF0h]
00007FF91DFD82D6  F3 0F 59 BB 60 91 00 00     mulss   xmm7, dword ptr [rbx+9160h]
00007FF91DFD82DE  F3 0F 59 05 B2 29 61 00     mulss   xmm0, cs:dword_7FF91E5EAC98
00007FF91DFD82E6  F3 0F 59 83 30 91 00 00     mulss   xmm0, dword ptr [rbx+9130h]
00007FF91DFD82EE  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFD82F2  72 09                       jb      short loc_7FF91DFD82FD
00007FF91DFD82F4  44 0F 28 F8                 movaps  xmm15, xmm0
00007FF91DFD82F8  F3 45 0F 5D FD              minss   xmm15, xmm13
00007FF91DFD82FD  F3 44 0F 59 BB E0 90 00 00  mulss   xmm15, dword ptr [rbx+90E0h]
00007FF91DFD8306  F3 44 0F 59 83 C0 8D 00 00  mulss   xmm8, dword ptr [rbx+8DC0h]
00007FF91DFD830F  F3 0F 10 AB 50 8D 00 00     movss   xmm5, dword ptr [rbx+8D50h]
00007FF91DFD8317  41 0F 28 D7                 movaps  xmm2, xmm15
00007FF91DFD831B  F3 0F 10 B3 70 8D 00 00     movss   xmm6, dword ptr [rbx+8D70h]
00007FF91DFD8323  F3 41 0F 59 D7              mulss   xmm2, xmm15
00007FF91DFD8328  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD832B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD832E  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00007FF91DFD8336  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD8339  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD833D  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD8340  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00007FF91DFD8348  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
00007FF91DFD8350  F3 41 0F 59 DF              mulss   xmm3, xmm15
00007FF91DFD8355  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
00007FF91DFD835D  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD8361  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD8364  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00007FF91DFD836C  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD8370  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD8374  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD8378  F3 0F 10 83 50 8E 00 00     movss   xmm0, dword ptr [rbx+8E50h]
00007FF91DFD8380  F3 0F 59 83 B0 8D 00 00     mulss   xmm0, dword ptr [rbx+8DB0h]
00007FF91DFD8388  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD838C  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFD8391  F3 41 0F 58 E7              addss   xmm4, xmm15
00007FF91DFD8396  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD839A  F3 0F 59 A3 D0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DD0h]
00007FF91DFD83A2  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD83A6  F3 0F 11 A3 00 90 00 00     movss   dword ptr [rbx+9000h], xmm4
00007FF91DFD83AE  F3 0F 10 93 70 90 00 00     movss   xmm2, dword ptr [rbx+9070h]
00007FF91DFD83B6  F3 0F 11 AB 30 8E 00 00     movss   dword ptr [rbx+8E30h], xmm5
00007FF91DFD83BE  F3 0F 11 B3 10 8E 00 00     movss   dword ptr [rbx+8E10h], xmm6
00007FF91DFD83C6  F3 0F 10 83 80 8F 00 00     movss   xmm0, dword ptr [rbx+8F80h]
00007FF91DFD83CE  F3 0F 58 83 70 8F 00 00     addss   xmm0, dword ptr [rbx+8F70h]
00007FF91DFD83D6  F3 0F 10 8B 00 90 00 00     movss   xmm1, dword ptr [rbx+9000h]
00007FF91DFD83DE  F3 0F 58 8B F0 8E 00 00     addss   xmm1, dword ptr [rbx+8EF0h]
00007FF91DFD83E6  F3 0F 10 AB F0 8F 00 00     movss   xmm5, dword ptr [rbx+8FF0h]
00007FF91DFD83EE  F3 0F 58 AB 00 8F 00 00     addss   xmm5, dword ptr [rbx+8F00h]
00007FF91DFD83F6  F3 0F 59 83 90 91 00 00     mulss   xmm0, dword ptr [rbx+9190h]
00007FF91DFD83FE  F3 0F 59 8B A0 91 00 00     mulss   xmm1, dword ptr [rbx+91A0h]
00007FF91DFD8406  F3 0F 59 AB 80 91 00 00     mulss   xmm5, dword ptr [rbx+9180h]
00007FF91DFD840E  F3 0F 58 93 80 8E 00 00     addss   xmm2, dword ptr [rbx+8E80h]
00007FF91DFD8416  F3 0F 59 93 70 91 00 00     mulss   xmm2, dword ptr [rbx+9170h]
00007FF91DFD841E  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFD8422  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD8426  F3 0F 10 83 60 90 00 00     movss   xmm0, dword ptr [rbx+9060h]
00007FF91DFD842E  F3 0F 58 83 90 8E 00 00     addss   xmm0, dword ptr [rbx+8E90h]
00007FF91DFD8436  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD843A  F3 0F 10 8B E0 8F 00 00     movss   xmm1, dword ptr [rbx+8FE0h]
00007FF91DFD8442  F3 0F 59 83 B0 91 00 00     mulss   xmm0, dword ptr [rbx+91B0h]
00007FF91DFD844A  F3 0F 58 8B 10 8F 00 00     addss   xmm1, dword ptr [rbx+8F10h]
00007FF91DFD8452  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD8456  F3 0F 10 83 90 8F 00 00     movss   xmm0, dword ptr [rbx+8F90h]
00007FF91DFD845E  F3 0F 58 83 60 8F 00 00     addss   xmm0, dword ptr [rbx+8F60h]
00007FF91DFD8466  F3 0F 59 8B C0 91 00 00     mulss   xmm1, dword ptr [rbx+91C0h]
00007FF91DFD846E  F3 0F 59 83 D0 91 00 00     mulss   xmm0, dword ptr [rbx+91D0h]
00007FF91DFD8476  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD847A  F3 0F 10 8B 10 90 00 00     movss   xmm1, dword ptr [rbx+9010h]
00007FF91DFD8482  F3 0F 58 8B E0 8E 00 00     addss   xmm1, dword ptr [rbx+8EE0h]
00007FF91DFD848A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD848E  F3 0F 10 83 50 90 00 00     movss   xmm0, dword ptr [rbx+9050h]
00007FF91DFD8496  F3 0F 59 8B E0 91 00 00     mulss   xmm1, dword ptr [rbx+91E0h]
00007FF91DFD849E  F3 0F 58 83 A0 8E 00 00     addss   xmm0, dword ptr [rbx+8EA0h]
00007FF91DFD84A6  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD84AA  F3 0F 10 8B 20 8F 00 00     movss   xmm1, dword ptr [rbx+8F20h]
00007FF91DFD84B2  F3 0F 58 8B D0 8F 00 00     addss   xmm1, dword ptr [rbx+8FD0h]
00007FF91DFD84BA  F3 0F 59 83 F0 91 00 00     mulss   xmm0, dword ptr [rbx+91F0h]
00007FF91DFD84C2  F3 0F 59 8B 00 92 00 00     mulss   xmm1, dword ptr [rbx+9200h]
00007FF91DFD84CA  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD84CE  F3 0F 10 83 A0 8F 00 00     movss   xmm0, dword ptr [rbx+8FA0h]
00007FF91DFD84D6  F3 0F 58 83 50 8F 00 00     addss   xmm0, dword ptr [rbx+8F50h]
00007FF91DFD84DE  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD84E2  F3 0F 10 8B D0 8E 00 00     movss   xmm1, dword ptr [rbx+8ED0h]
00007FF91DFD84EA  F3 0F 59 83 10 92 00 00     mulss   xmm0, dword ptr [rbx+9210h]
00007FF91DFD84F2  F3 0F 58 8B 20 90 00 00     addss   xmm1, dword ptr [rbx+9020h]
00007FF91DFD84FA  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD84FE  F3 0F 10 83 40 90 00 00     movss   xmm0, dword ptr [rbx+9040h]
00007FF91DFD8506  F3 0F 59 8B 20 92 00 00     mulss   xmm1, dword ptr [rbx+9220h]
00007FF91DFD850E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD8512  F3 0F 58 83 B0 8E 00 00     addss   xmm0, dword ptr [rbx+8EB0h]
00007FF91DFD851A  F3 0F 10 93 A0 90 00 00     movss   xmm2, dword ptr [rbx+90A0h]
00007FF91DFD8522  F3 0F 10 8B C0 8F 00 00     movss   xmm1, dword ptr [rbx+8FC0h]
00007FF91DFD852A  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD852D  F3 0F 59 A3 A0 93 00 00     mulss   xmm4, dword ptr [rbx+93A0h]
00007FF91DFD8535  F3 0F 59 83 30 92 00 00     mulss   xmm0, dword ptr [rbx+9230h]
00007FF91DFD853D  F3 0F 58 A3 B0 90 00 00     addss   xmm4, dword ptr [rbx+90B0h]
00007FF91DFD8545  F3 0F 58 8B 30 8F 00 00     addss   xmm1, dword ptr [rbx+8F30h]
00007FF91DFD854D  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD8551  F3 0F 10 83 B0 8F 00 00     movss   xmm0, dword ptr [rbx+8FB0h]
00007FF91DFD8559  F3 0F 58 83 40 8F 00 00     addss   xmm0, dword ptr [rbx+8F40h]
00007FF91DFD8561  F3 0F 59 8B 40 92 00 00     mulss   xmm1, dword ptr [rbx+9240h]
00007FF91DFD8569  F3 0F 59 83 50 92 00 00     mulss   xmm0, dword ptr [rbx+9250h]
00007FF91DFD8571  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD8575  F3 0F 10 8B 30 90 00 00     movss   xmm1, dword ptr [rbx+9030h]
00007FF91DFD857D  F3 0F 58 8B C0 8E 00 00     addss   xmm1, dword ptr [rbx+8EC0h]
00007FF91DFD8585  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD8589  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD858C  F3 0F 59 8B 60 92 00 00     mulss   xmm1, dword ptr [rbx+9260h]
00007FF91DFD8594  F3 0F 11 A3 A0 90 00 00     movss   dword ptr [rbx+90A0h], xmm4
00007FF91DFD859C  F3 0F 59 83 B0 93 00 00     mulss   xmm0, dword ptr [rbx+93B0h]
00007FF91DFD85A4  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD85A8  F3 0F 58 C4                 addss   xmm0, xmm4
00007FF91DFD85AC  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFD85AF  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD85B3  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD85B6  F3 0F 59 83 A0 93 00 00     mulss   xmm0, dword ptr [rbx+93A0h]
00007FF91DFD85BE  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFD85C2  F3 0F 11 83 90 90 00 00     movss   dword ptr [rbx+9090h], xmm0
00007FF91DFD85CA  F3 0F 10 93 F0 93 00 00     movss   xmm2, dword ptr [rbx+93F0h]
00007FF91DFD85D2  F3 0F 59 9B 80 90 00 00     mulss   xmm3, dword ptr [rbx+9080h]
00007FF91DFD85DA  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFD85DE  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFD85E2  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD85E6  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFD85EA  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD85EE  F3 0F 11 A3 70 8E 00 00     movss   dword ptr [rbx+8E70h], xmm4
00007FF91DFD85F6  F3 0F 11 A3 F0 88 00 00     movss   dword ptr [rbx+88F0h], xmm4
00007FF91DFD85FE  44 0F 2E AB E0 8C 01 00     ucomiss xmm13, dword ptr [rbx+18CE0h]
00007FF91DFD8606  75 28                       jnz     short loc_7FF91DFD8630
00007FF91DFD8608  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
00007FF91DFD8611  F3 0F 11 83 70 7C 00 00     movss   dword ptr [rbx+7C70h], xmm0
00007FF91DFD8619  C7 83 E0 8C 01 00 00 00 00 00  mov     dword ptr [rbx+18CE0h], 0
00007FF91DFD8623  0F 1F 40 00                 nop     dword ptr [rax+00h]
00007FF91DFD8627  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00007FF91DFD8630  8B 83 E0 A4 00 00           mov     eax, [rbx+0A4E0h]
00007FF91DFD8636  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
00007FF91DFD863E  48 8B 0F                    mov     rcx, [rdi]
00007FF91DFD8641  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
00007FF91DFD8646  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
00007FF91DFD864B  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
00007FF91DFD8650  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
00007FF91DFD8655  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
00007FF91DFD865A  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
00007FF91DFD865F  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
00007FF91DFD8664  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
00007FF91DFD8669  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
00007FF91DFD866F  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
00007FF91DFD8675  89 01                       mov     [rcx], eax
00007FF91DFD8677  8B 83 E0 A4 00 00           mov     eax, [rbx+0A4E0h]
00007FF91DFD867D  48 8B 4F 08                 mov     rcx, [rdi+8]
00007FF91DFD8681  49 8B 5B 18                 mov     rbx, [r11+18h]
00007FF91DFD8685  89 01                       mov     [rcx], eax
00007FF91DFD8687  49 8B E3                    mov     rsp, r11
00007FF91DFD868A  5F                          pop     rdi
00007FF91DFD868B  C3                          retn
