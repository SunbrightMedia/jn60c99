; sub_180374900 @ 0x180374900 (RVA 0x374900) size=0x3D8C

0000000180374900  48 8B C4                    mov     rax, rsp
0000000180374903  48 89 58 10                 mov     [rax+10h], rbx
0000000180374907  57                          push    rdi
0000000180374908  48 81 EC C0 00 00 00        sub     rsp, 0C0h
000000018037490F  F3 0F 10 A1 70 7C 00 00     movss   xmm4, dword ptr [rcx+7C70h]
0000000180374917  48 8B FA                    mov     rdi, rdx
000000018037491A  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
000000018037491E  48 8B D9                    mov     rbx, rcx
0000000180374921  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
0000000180374925  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
000000018037492A  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
000000018037492F  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
0000000180374934  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
0000000180374939  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
000000018037493E  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
0000000180374944  F3 44 0F 10 2D 67 07 77 00  movss   xmm13, cs:dword_180AE50B4
000000018037494D  44 0F 2E A9 E0 8C 01 00     ucomiss xmm13, dword ptr [rcx+18CE0h]
0000000180374955  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
000000018037495B  45 0F 57 F6                 xorps   xmm14, xmm14
000000018037495F  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
0000000180374969  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
000000018037496F  75 16                       jnz     short loc_180374987
0000000180374971  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
000000018037497A  0F 57 E4                    xorps   xmm4, xmm4
000000018037497D  C7 81 70 7C 00 00 00 00 00 00  mov     dword ptr [rcx+7C70h], 0
0000000180374987  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
000000018037498F  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
0000000180374997  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
000000018037499F  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
00000001803749A7  F3 0F 59 05 15 64 61 00     mulss   xmm0, cs:dword_18098ADC4
00000001803749AF  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
00000001803749B7  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
00000001803749BF  F3 0F 2C D0                 cvttss2si edx, xmm0
00000001803749C3  85 D2                       test    edx, edx
00000001803749C5  75 07                       jnz     short loc_1803749CE
00000001803749C7  BA 01 00 00 00              mov     edx, 1
00000001803749CC  EB 24                       jmp     short loc_1803749F2
00000001803749CE  8B C2                       mov     eax, edx
00000001803749D0  25 00 00 20 00              and     eax, 200000h
00000001803749D5  0F BA E2 17                 bt      edx, 17h
00000001803749D9  73 08                       jnb     short loc_1803749E3
00000001803749DB  85 C0                       test    eax, eax
00000001803749DD  75 0C                       jnz     short loc_1803749EB
00000001803749DF  03 D2                       add     edx, edx
00000001803749E1  EB 0F                       jmp     short loc_1803749F2
00000001803749E3  85 C0                       test    eax, eax
00000001803749E5  74 04                       jz      short loc_1803749EB
00000001803749E7  03 D2                       add     edx, edx
00000001803749E9  EB 07                       jmp     short loc_1803749F2
00000001803749EB  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
00000001803749F2  F3 0F 10 9B 00 7C 00 00     movss   xmm3, dword ptr [rbx+7C00h]
00000001803749FA  8B C2                       mov     eax, edx
00000001803749FC  F3 0F 10 B3 E0 7B 00 00     movss   xmm6, dword ptr [rbx+7BE0h]
0000000180374A04  25 FF FF FF 00              and     eax, 0FFFFFFh
0000000180374A09  F3 44 0F 10 83 A0 7C 00 00  movss   xmm8, dword ptr [rbx+7CA0h]
0000000180374A12  8B CA                       mov     ecx, edx
0000000180374A14  F3 0F 10 BB B0 7C 00 00     movss   xmm7, dword ptr [rbx+7CB0h]
0000000180374A1C  81 CA 00 00 00 FF           or      edx, 0FF000000h
0000000180374A22  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180374A26  81 E1 00 00 00 01           and     ecx, 1000000h
0000000180374A2C  C7 83 E0 7C 00 00 00 00 00 00  mov     dword ptr [rbx+7CE0h], 0
0000000180374A36  F3 0F 11 9B 10 7C 00 00     movss   dword ptr [rbx+7C10h], xmm3
0000000180374A3E  45 0F 57 D2                 xorps   xmm10, xmm10
0000000180374A42  0F 44 D0                    cmovz   edx, eax
0000000180374A45  F3 0F 11 B3 F0 7B 00 00     movss   dword ptr [rbx+7BF0h], xmm6
0000000180374A4D  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
0000000180374A53  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
0000000180374A59  8B 83 20 7D 00 00           mov     eax, [rbx+7D20h]
0000000180374A5F  66 0F 6E C2                 movd    xmm0, edx
0000000180374A63  0F 5B C0                    cvtdq2ps xmm0, xmm0
0000000180374A66  89 83 30 7D 00 00           mov     [rbx+7D30h], eax
0000000180374A6C  F3 0F 11 A3 90 7C 00 00     movss   dword ptr [rbx+7C90h], xmm4
0000000180374A74  F3 0F 59 05 F4 61 61 00     mulss   xmm0, cs:dword_18098AC70
0000000180374A7C  F3 44 0F 11 83 C0 7C 00 00  movss   dword ptr [rbx+7CC0h], xmm8
0000000180374A85  F3 0F 11 BB D0 7C 00 00     movss   dword ptr [rbx+7CD0h], xmm7
0000000180374A8D  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
0000000180374A95  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
0000000180374A9D  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
0000000180374AA5  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180374AA9  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
0000000180374AB1  F3 0F 5C CA                 subss   xmm1, xmm2
0000000180374AB5  F3 0F 10 93 40 7C 00 00     movss   xmm2, dword ptr [rbx+7C40h]
0000000180374ABD  F3 0F 11 93 50 7C 00 00     movss   dword ptr [rbx+7C50h], xmm2
0000000180374AC5  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180374AC9  F3 0F 10 83 20 7C 00 00     movss   xmm0, dword ptr [rbx+7C20h]
0000000180374AD1  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180374AD5  F3 0F 11 83 30 7C 00 00     movss   dword ptr [rbx+7C30h], xmm0
0000000180374ADD  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180374AE1  0F 28 C2                    movaps  xmm0, xmm2
0000000180374AE4  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
0000000180374AEC  F3 0F 10 8B 60 7C 00 00     movss   xmm1, dword ptr [rbx+7C60h]
0000000180374AF4  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180374AF8  F3 0F 59 F2                 mulss   xmm6, xmm2
0000000180374AFC  F3 0F 11 8B 80 7C 00 00     movss   dword ptr [rbx+7C80h], xmm1
0000000180374B04  F3 0F 11 93 F0 7C 00 00     movss   dword ptr [rbx+7CF0h], xmm2
0000000180374B0C  F3 0F 5C F0                 subss   xmm6, xmm0
0000000180374B10  0F 28 C4                    movaps  xmm0, xmm4
0000000180374B13  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180374B17  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180374B1B  F3 0F 58 F1                 addss   xmm6, xmm1
0000000180374B1F  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180374B23  F3 0F 11 B3 00 7D 00 00     movss   dword ptr [rbx+7D00h], xmm6
0000000180374B2B  F3 0F 11 9B 10 7D 00 00     movss   dword ptr [rbx+7D10h], xmm3
0000000180374B33  0F 28 CB                    movaps  xmm1, xmm3
0000000180374B36  F3 0F 58 9B 50 7D 00 00     addss   xmm3, dword ptr [rbx+7D50h]
0000000180374B3E  41 0F 2F DE                 comiss  xmm3, xmm14
0000000180374B42  72 05                       jb      short loc_180374B49
0000000180374B44  0F 57 C0                    xorps   xmm0, xmm0
0000000180374B47  EB 03                       jmp     short loc_180374B4C
0000000180374B49  0F 5A C3                    cvtps2pd xmm0, xmm3
0000000180374B4C  41 0F 2E CE                 ucomiss xmm1, xmm14
0000000180374B50  F3 44 0F 10 3D 8B 09 77 00  movss   xmm15, cs:dword_180AE54E4
0000000180374B59  75 06                       jnz     short loc_180374B61
0000000180374B5B  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180374B5F  EB 04                       jmp     short loc_180374B65
0000000180374B61  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
0000000180374B65  41 0F 2F EE                 comiss  xmm5, xmm14
0000000180374B69  F3 0F 11 AB 20 7D 00 00     movss   dword ptr [rbx+7D20h], xmm5
0000000180374B71  73 06                       jnb     short loc_180374B79
0000000180374B73  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180374B77  EB 06                       jmp     short loc_180374B7F
0000000180374B79  76 04                       jbe     short loc_180374B7F
0000000180374B7B  41 0F 28 ED                 movaps  xmm5, xmm13
0000000180374B7F  F3 0F 10 83 90 7D 00 00     movss   xmm0, dword ptr [rbx+7D90h]
0000000180374B87  F3 41 0F 58 ED              addss   xmm5, xmm13
0000000180374B8C  F3 0F 10 93 30 7E 00 00     movss   xmm2, dword ptr [rbx+7E30h]
0000000180374B94  F3 0F 10 8B A0 7D 00 00     movss   xmm1, dword ptr [rbx+7DA0h]
0000000180374B9C  8B 83 60 7D 00 00           mov     eax, [rbx+7D60h]
0000000180374BA2  0F 28 D9                    movaps  xmm3, xmm1
0000000180374BA5  F3 0F 10 A3 F0 7D 00 00     movss   xmm4, dword ptr [rbx+7DF0h]
0000000180374BAD  F3 0F 58 9B 40 7E 00 00     addss   xmm3, dword ptr [rbx+7E40h]
0000000180374BB5  F2 44 0F 10 25 E2 05 77 00  movsd   xmm12, cs:dbl_180AE51A0
0000000180374BBE  F3 0F 11 AB 40 7D 00 00     movss   dword ptr [rbx+7D40h], xmm5
0000000180374BC6  F3 0F 11 AB 60 7D 00 00     movss   dword ptr [rbx+7D60h], xmm5
0000000180374BCE  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180374BD2  89 83 70 7D 00 00           mov     [rbx+7D70h], eax
0000000180374BD8  F3 0F 11 A3 00 7E 00 00     movss   dword ptr [rbx+7E00h], xmm4
0000000180374BE0  F3 0F 5C E8                 subss   xmm5, xmm0
0000000180374BE4  0F 28 C2                    movaps  xmm0, xmm2
0000000180374BE7  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180374BEB  F3 0F 10 8B D0 7D 00 00     movss   xmm1, dword ptr [rbx+7DD0h]
0000000180374BF3  F3 0F 58 83 50 7E 00 00     addss   xmm0, dword ptr [rbx+7E50h]
0000000180374BFB  F3 41 0F 58 ED              addss   xmm5, xmm13
0000000180374C00  F3 0F 5E C8                 divss   xmm1, xmm0
0000000180374C04  F3 0F 10 83 60 7E 00 00     movss   xmm0, dword ptr [rbx+7E60h]
0000000180374C0C  F3 0F 59 AB 80 7D 00 00     mulss   xmm5, dword ptr [rbx+7D80h]
0000000180374C14  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180374C18  F3 0F 10 93 C0 7D 00 00     movss   xmm2, dword ptr [rbx+7DC0h]
0000000180374C20  F3 0F 11 AB 10 7E 00 00     movss   dword ptr [rbx+7E10h], xmm5
0000000180374C28  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180374C2C  F3 0F 10 8B E0 7D 00 00     movss   xmm1, dword ptr [rbx+7DE0h]
0000000180374C34  F3 0F 58 D6                 addss   xmm2, xmm6
0000000180374C38  F3 0F 5C D4                 subss   xmm2, xmm4
0000000180374C3C  F3 0F 11 93 C0 7D 00 00     movss   dword ptr [rbx+7DC0h], xmm2
0000000180374C44  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180374C48  F3 0F 11 93 D0 7D 00 00     movss   dword ptr [rbx+7DD0h], xmm2
0000000180374C50  F3 0F 58 D4                 addss   xmm2, xmm4
0000000180374C54  F3 0F 5C E6                 subss   xmm4, xmm6
0000000180374C58  0F 54 25 31 0B 77 00        andps   xmm4, cs:xmmword_180AE5790
0000000180374C5F  F3 0F 5C C4                 subss   xmm0, xmm4
0000000180374C63  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180374C67  0F 83 E8 00 00 00           jnb     loc_180374D55
0000000180374C6D  0F 57 C9                    xorps   xmm1, xmm1
0000000180374C70  0F 5A C1                    cvtps2pd xmm0, xmm1
0000000180374C73  41 0F 2E EE                 ucomiss xmm5, xmm14
0000000180374C77  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180374C7B  0F 28 C8                    movaps  xmm1, xmm0
0000000180374C7E  F3 0F 11 83 E0 7D 00 00     movss   dword ptr [rbx+7DE0h], xmm0
0000000180374C86  F3 0F 59 CE                 mulss   xmm1, xmm6
0000000180374C8A  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180374C8E  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180374C92  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180374C96  75 03                       jnz     short loc_180374C9B
0000000180374C98  0F 28 CE                    movaps  xmm1, xmm6
0000000180374C9B  8B 83 A0 7E 00 00           mov     eax, [rbx+7EA0h]
0000000180374CA1  48 8D 0D 58 B3 C8 FF        lea     rcx, cs:180000000h
0000000180374CA8  F3 0F 59 BB 90 7E 00 00     mulss   xmm7, dword ptr [rbx+7E90h]
0000000180374CB0  89 83 B0 7E 00 00           mov     [rbx+7EB0h], eax
0000000180374CB6  F3 44 0F 59 83 80 7E 00 00  mulss   xmm8, dword ptr [rbx+7E80h]
0000000180374CBF  F3 0F 10 83 C0 7F 00 00     movss   xmm0, dword ptr [rbx+7FC0h]
0000000180374CC7  F3 0F 10 93 C0 7E 00 00     movss   xmm2, dword ptr [rbx+7EC0h]
0000000180374CCF  F3 44 0F 10 8B 20 7F 00 00  movss   xmm9, dword ptr [rbx+7F20h]
0000000180374CD8  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180374CDD  F3 44 0F 10 83 00 7F 00 00  movss   xmm8, dword ptr [rbx+7F00h]
0000000180374CE6  F3 0F 2C C0                 cvttss2si eax, xmm0
0000000180374CEA  F3 0F 11 BB A0 7E 00 00     movss   dword ptr [rbx+7EA0h], xmm7
0000000180374CF2  F3 0F 10 BB E0 7E 00 00     movss   xmm7, dword ptr [rbx+7EE0h]
0000000180374CFA  F3 0F 11 8B F0 7D 00 00     movss   dword ptr [rbx+7DF0h], xmm1
0000000180374D02  F3 0F 11 8B 20 7E 00 00     movss   dword ptr [rbx+7E20h], xmm1
0000000180374D0A  F3 0F 10 8B 80 7F 00 00     movss   xmm1, dword ptr [rbx+7F80h]
0000000180374D12  F3 0F 11 BB F0 7E 00 00     movss   dword ptr [rbx+7EF0h], xmm7
0000000180374D1A  F3 0F 11 93 D0 7E 00 00     movss   dword ptr [rbx+7ED0h], xmm2
0000000180374D22  F3 44 0F 11 83 10 7F 00 00  movss   dword ptr [rbx+7F10h], xmm8
0000000180374D2B  F3 44 0F 11 8B 30 7F 00 00  movss   dword ptr [rbx+7F30h], xmm9
0000000180374D34  F3 0F 11 8B 90 7F 00 00     movss   dword ptr [rbx+7F90h], xmm1
0000000180374D3C  83 F8 E0                    cmp     eax, 0FFFFFFE0h
0000000180374D3F  7D 2F                       jge     short loc_180374D70
0000000180374D41  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
0000000180374D46  F7 D0                       not     eax
0000000180374D48  48 98                       cdqe
0000000180374D4A  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
0000000180374D53  EB 47                       jmp     short loc_180374D9C
0000000180374D55  F3 0F 58 8B 70 7E 00 00     addss   xmm1, dword ptr [rbx+7E70h]
0000000180374D5D  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180374D61  0F 82 09 FF FF FF           jb      loc_180374C70
0000000180374D67  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180374D6B  E9 03 FF FF FF              jmp     loc_180374C73
0000000180374D70  83 F8 20                    cmp     eax, 20h ; ' '
0000000180374D73  7E 07                       jle     short loc_180374D7C
0000000180374D75  B8 20 00 00 00              mov     eax, 20h ; ' '
0000000180374D7A  EB 15                       jmp     short loc_180374D91
0000000180374D7C  85 C0                       test    eax, eax
0000000180374D7E  79 0F                       jns     short loc_180374D8F
0000000180374D80  F7 D0                       not     eax
0000000180374D82  48 98                       cdqe
0000000180374D84  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
0000000180374D8D  EB 0D                       jmp     short loc_180374D9C
0000000180374D8F  7E 0B                       jle     short loc_180374D9C
0000000180374D91  48 98                       cdqe
0000000180374D93  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
0000000180374D9C  0F 57 05 1D 0A 77 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180374DA3  F3 0F 2C C0                 cvttss2si eax, xmm0
0000000180374DA7  83 F8 E0                    cmp     eax, 0FFFFFFE0h
0000000180374DAA  7D 14                       jge     short loc_180374DC0
0000000180374DAC  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
0000000180374DB1  F7 D0                       not     eax
0000000180374DB3  48 98                       cdqe
0000000180374DB5  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
0000000180374DBE  EB 2C                       jmp     short loc_180374DEC
0000000180374DC0  83 F8 20                    cmp     eax, 20h ; ' '
0000000180374DC3  7E 07                       jle     short loc_180374DCC
0000000180374DC5  B8 20 00 00 00              mov     eax, 20h ; ' '
0000000180374DCA  EB 15                       jmp     short loc_180374DE1
0000000180374DCC  85 C0                       test    eax, eax
0000000180374DCE  79 0F                       jns     short loc_180374DDF
0000000180374DD0  F7 D0                       not     eax
0000000180374DD2  48 98                       cdqe
0000000180374DD4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
0000000180374DDD  EB 0D                       jmp     short loc_180374DEC
0000000180374DDF  7E 0B                       jle     short loc_180374DEC
0000000180374DE1  48 98                       cdqe
0000000180374DE3  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
0000000180374DEC  F3 0F 10 83 40 7F 00 00     movss   xmm0, dword ptr [rbx+7F40h]
0000000180374DF4  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180374DF8  F3 0F 59 93 B0 7F 00 00     mulss   xmm2, dword ptr [rbx+7FB0h]
0000000180374E00  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180374E04  F3 0F 10 8B 70 7F 00 00     movss   xmm1, dword ptr [rbx+7F70h]
0000000180374E0C  F3 0F 11 93 80 7F 00 00     movss   dword ptr [rbx+7F80h], xmm2
0000000180374E14  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180374E18  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180374E1C  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180374E20  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180374E24  41 0F 2F D6                 comiss  xmm2, xmm14
0000000180374E28  76 05                       jbe     short loc_180374E2F
0000000180374E2A  0F 5A C2                    cvtps2pd xmm0, xmm2
0000000180374E2D  EB 03                       jmp     short loc_180374E32
0000000180374E2F  0F 57 C0                    xorps   xmm0, xmm0
0000000180374E32  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
0000000180374E36  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180374E3A  72 06                       jb      short loc_180374E42
0000000180374E3C  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180374E40  EB 03                       jmp     short loc_180374E45
0000000180374E42  0F 5A C1                    cvtps2pd xmm0, xmm1
0000000180374E45  F3 0F 10 B3 50 7F 00 00     movss   xmm6, dword ptr [rbx+7F50h]
0000000180374E4D  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180374E51  F3 0F 59 83 E0 7F 00 00     mulss   xmm0, dword ptr [rbx+7FE0h]; X
0000000180374E59  E8 E2 A8 37 00              call    expf
0000000180374E5E  F3 0F 59 83 D0 7F 00 00     mulss   xmm0, dword ptr [rbx+7FD0h]
0000000180374E66  0F 28 CE                    movaps  xmm1, xmm6
0000000180374E69  8B 83 50 81 00 00           mov     eax, [rbx+8150h]
0000000180374E6F  F3 0F 59 8B 60 7F 00 00     mulss   xmm1, dword ptr [rbx+7F60h]
0000000180374E77  89 83 60 81 00 00           mov     [rbx+8160h], eax
0000000180374E7D  F3 0F 58 83 F0 7F 00 00     addss   xmm0, dword ptr [rbx+7FF0h]
0000000180374E85  8B 83 70 81 00 00           mov     eax, [rbx+8170h]
0000000180374E8B  F3 0F 10 9B 10 81 00 00     movss   xmm3, dword ptr [rbx+8110h]
0000000180374E93  F3 0F 59 BB A0 82 00 00     mulss   xmm7, dword ptr [rbx+82A0h]
0000000180374E9B  89 83 80 81 00 00           mov     [rbx+8180h], eax
0000000180374EA1  8B 83 90 81 00 00           mov     eax, [rbx+8190h]
0000000180374EA7  F3 0F 10 93 00 81 00 00     movss   xmm2, dword ptr [rbx+8100h]
0000000180374EAF  F3 0F 10 A3 30 81 00 00     movss   xmm4, dword ptr [rbx+8130h]
0000000180374EB7  F3 0F 59 F0                 mulss   xmm6, xmm0
0000000180374EBB  89 83 A0 81 00 00           mov     [rbx+81A0h], eax
0000000180374EC1  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
0000000180374EC7  F3 0F 11 9B 20 81 00 00     movss   dword ptr [rbx+8120h], xmm3
0000000180374ECF  F3 0F 5C CE                 subss   xmm1, xmm6
0000000180374ED3  F3 0F 11 93 10 81 00 00     movss   dword ptr [rbx+8110h], xmm2
0000000180374EDB  F3 0F 11 A3 40 81 00 00     movss   dword ptr [rbx+8140h], xmm4
0000000180374EE3  F3 44 0F 11 83 D0 80 00 00  movss   dword ptr [rbx+80D0h], xmm8
0000000180374EEC  F3 44 0F 11 8B E0 80 00 00  movss   dword ptr [rbx+80E0h], xmm9
0000000180374EF5  89 83 C0 80 00 00           mov     [rbx+80C0h], eax
0000000180374EFB  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180374EFF  F3 0F 10 83 70 82 00 00     movss   xmm0, dword ptr [rbx+8270h]
0000000180374F07  F3 0F 58 F8                 addss   xmm7, xmm0
0000000180374F0B  F3 0F 11 83 60 82 00 00     movss   dword ptr [rbx+8260h], xmm0
0000000180374F13  F3 0F 11 8B A0 7F 00 00     movss   dword ptr [rbx+7FA0h], xmm1
0000000180374F1B  41 0F 2F FF                 comiss  xmm7, xmm15
0000000180374F1F  73 06                       jnb     short loc_180374F27
0000000180374F21  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180374F25  EB 05                       jmp     short loc_180374F2C
0000000180374F27  F3 41 0F 5D FD              minss   xmm7, xmm13
0000000180374F2C  F3 0F 59 0D 8C 5E 61 00     mulss   xmm1, cs:dword_18098ADC0
0000000180374F34  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180374F38  F3 0F 10 B3 80 83 00 00     movss   xmm6, dword ptr [rbx+8380h]
0000000180374F40  F3 0F 5C C3                 subss   xmm0, xmm3
0000000180374F44  F3 0F 11 BB 00 81 00 00     movss   dword ptr [rbx+8100h], xmm7
0000000180374F4C  F3 0F 5D F1                 minss   xmm6, xmm1
0000000180374F50  F3 0F 59 83 B0 82 00 00     mulss   xmm0, dword ptr [rbx+82B0h]
0000000180374F58  F3 0F 58 C3                 addss   xmm0, xmm3
0000000180374F5C  41 0F 2F C7                 comiss  xmm0, xmm15
0000000180374F60  73 06                       jnb     short loc_180374F68
0000000180374F62  41 0F 28 C7                 movaps  xmm0, xmm15
0000000180374F66  EB 05                       jmp     short loc_180374F6D
0000000180374F68  F3 41 0F 5D C5              minss   xmm0, xmm13
0000000180374F6D  F3 0F 59 B3 90 83 00 00     mulss   xmm6, dword ptr [rbx+8390h]
0000000180374F75  F3 0F 5C D7                 subss   xmm2, xmm7
0000000180374F79  F3 0F 11 B3 B0 81 00 00     movss   dword ptr [rbx+81B0h], xmm6
0000000180374F81  F3 0F 58 F4                 addss   xmm6, xmm4
0000000180374F85  41 0F 2F D6                 comiss  xmm2, xmm14
0000000180374F89  73 03                       jnb     short loc_180374F8E
0000000180374F8B  0F 57 C0                    xorps   xmm0, xmm0
0000000180374F8E  F3 0F 10 8B 80 82 00 00     movss   xmm1, dword ptr [rbx+8280h]
0000000180374F96  F3 44 0F 10 9B C0 80 00 00  movss   xmm11, dword ptr [rbx+80C0h]
0000000180374F9F  F3 0F 11 83 10 81 00 00     movss   dword ptr [rbx+8110h], xmm0
0000000180374FA7  F3 0F 58 83 10 84 00 00     addss   xmm0, dword ptr [rbx+8410h]
0000000180374FAF  72 04                       jb      short loc_180374FB5
0000000180374FB1  41 0F 28 CD                 movaps  xmm1, xmm13
0000000180374FB5  F3 0F 59 83 00 84 00 00     mulss   xmm0, dword ptr [rbx+8400h]
0000000180374FBD  41 0F 28 FB                 movaps  xmm7, xmm11
0000000180374FC1  F3 0F 10 93 60 81 00 00     movss   xmm2, dword ptr [rbx+8160h]
0000000180374FC9  F3 0F 59 F1                 mulss   xmm6, xmm1
0000000180374FCD  F3 0F 5C FA                 subss   xmm7, xmm2
0000000180374FD1  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180374FD5  F3 0F 59 B3 90 82 00 00     mulss   xmm6, dword ptr [rbx+8290h]
0000000180374FDD  76 05                       jbe     short loc_180374FE4
0000000180374FDF  0F 5A C8                    cvtps2pd xmm1, xmm0
0000000180374FE2  EB 03                       jmp     short loc_180374FE7
0000000180374FE4  0F 57 C9                    xorps   xmm1, xmm1
0000000180374FE7  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180374FEB  F3 0F 59 BB D0 84 00 00     mulss   xmm7, dword ptr [rbx+84D0h]
0000000180374FF3  F3 44 0F 10 0D EC 01 77 00  movss   xmm9, cs:flt_180AE51E8
0000000180374FFC  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
0000000180375000  F3 0F 58 FA                 addss   xmm7, xmm2
0000000180375004  F3 0F 11 BB 50 81 00 00     movss   dword ptr [rbx+8150h], xmm7
000000018037500C  F3 0F 11 83 F0 80 00 00     movss   dword ptr [rbx+80F0h], xmm0
0000000180375014  41 0F 28 C3                 movaps  xmm0, xmm11
0000000180375018  F3 0F 59 BB C0 84 00 00     mulss   xmm7, dword ptr [rbx+84C0h]
0000000180375020  F3 0F 10 8B 40 83 00 00     movss   xmm1, dword ptr [rbx+8340h]
0000000180375028  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037502C  F3 0F 59 F9                 mulss   xmm7, xmm1
0000000180375030  F3 0F 5C F8                 subss   xmm7, xmm0
0000000180375034  F3 0F 10 83 40 81 00 00     movss   xmm0, dword ptr [rbx+8140h]
000000018037503C  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
0000000180375045  F3 41 0F 58 FB              addss   xmm7, xmm11
000000018037504A  76 1B                       jbe     short loc_180375067
000000018037504C  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180375051  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180375055  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180375058  E8 7B A4 37 00              call    fmodf
000000018037505D  0F 28 F0                    movaps  xmm6, xmm0
0000000180375060  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180375065  EB 1F                       jmp     short loc_180375086
0000000180375067  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037506B  73 19                       jnb     short loc_180375086
000000018037506D  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180375072  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180375076  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180375079  E8 5A A4 37 00              call    fmodf
000000018037507E  0F 28 F0                    movaps  xmm6, xmm0
0000000180375081  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180375086  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
000000018037508F  0F 28 C6                    movaps  xmm0, xmm6
0000000180375092  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180375096  F3 44 0F 10 83 80 81 00 00  movss   xmm8, dword ptr [rbx+8180h]
000000018037509F  F3 0F 11 B3 30 81 00 00     movss   dword ptr [rbx+8130h], xmm6
00000001803750A7  F3 0F 59 BB B0 84 00 00     mulss   xmm7, dword ptr [rbx+84B0h]
00000001803750AF  F3 0F 58 83 20 84 00 00     addss   xmm0, dword ptr [rbx+8420h]
00000001803750B7  F3 0F 11 BB B0 80 00 00     movss   dword ptr [rbx+80B0h], xmm7
00000001803750BF  73 0A                       jnb     short loc_1803750CB
00000001803750C1  41 0F 2F F6                 comiss  xmm6, xmm14
00000001803750C5  76 04                       jbe     short loc_1803750CB
00000001803750C7  45 0F 28 C3                 movaps  xmm8, xmm11
00000001803750CB  41 0F 2F C5                 comiss  xmm0, xmm13
00000001803750CF  76 15                       jbe     short loc_1803750E6
00000001803750D1  F3 41 0F 58 C5              addss   xmm0, xmm13; X
00000001803750D6  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803750DA  E8 F9 A3 37 00              call    fmodf
00000001803750DF  F3 41 0F 5C C5              subss   xmm0, xmm13
00000001803750E4  EB 19                       jmp     short loc_1803750FF
00000001803750E6  41 0F 2F C7                 comiss  xmm0, xmm15
00000001803750EA  73 13                       jnb     short loc_1803750FF
00000001803750EC  F3 41 0F 5C C5              subss   xmm0, xmm13; X
00000001803750F1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803750F5  E8 DE A3 37 00              call    fmodf
00000001803750FA  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803750FF  F3 44 0F 10 1D B8 06 77 00  movss   xmm11, dword ptr cs:xmmword_180AE57C0
0000000180375108  F3 44 0F 11 83 70 81 00 00  movss   dword ptr [rbx+8170h], xmm8
0000000180375111  F3 0F 59 83 60 84 00 00     mulss   xmm0, dword ptr [rbx+8460h]
0000000180375119  F3 44 0F 59 83 A0 84 00 00  mulss   xmm8, dword ptr [rbx+84A0h]
0000000180375122  F3 0F 58 83 E0 84 00 00     addss   xmm0, dword ptr [rbx+84E0h]
000000018037512A  F3 0F 11 83 C0 81 00 00     movss   dword ptr [rbx+81C0h], xmm0
0000000180375132  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180375136  F3 44 0F 11 83 10 82 00 00  movss   dword ptr [rbx+8210h], xmm8
000000018037513F  44 0F 28 C6                 movaps  xmm8, xmm6
0000000180375143  F3 44 0F 58 83 40 84 00 00  addss   xmm8, dword ptr [rbx+8440h]
000000018037514C  F3 0F 11 83 D0 81 00 00     movss   dword ptr [rbx+81D0h], xmm0
0000000180375154  45 0F 2F C5                 comiss  xmm8, xmm13
0000000180375158  76 1D                       jbe     short loc_180375177
000000018037515A  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018037515F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180375163  41 0F 28 C0                 movaps  xmm0, xmm8; X
0000000180375167  E8 6C A3 37 00              call    fmodf
000000018037516C  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180375170  F3 45 0F 5C C5              subss   xmm8, xmm13
0000000180375175  EB 21                       jmp     short loc_180375198
0000000180375177  45 0F 2F C7                 comiss  xmm8, xmm15
000000018037517B  73 1B                       jnb     short loc_180375198
000000018037517D  F3 45 0F 5C C5              subss   xmm8, xmm13
0000000180375182  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180375186  41 0F 28 C0                 movaps  xmm0, xmm8; X
000000018037518A  E8 49 A3 37 00              call    fmodf
000000018037518F  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180375193  F3 45 0F 58 C5              addss   xmm8, xmm13
0000000180375198  0F 28 FE                    movaps  xmm7, xmm6
000000018037519B  F3 0F 58 BB 30 84 00 00     addss   xmm7, dword ptr [rbx+8430h]
00000001803751A3  41 0F 2F FD                 comiss  xmm7, xmm13
00000001803751A7  76 1B                       jbe     short loc_1803751C4
00000001803751A9  F3 41 0F 58 FD              addss   xmm7, xmm13
00000001803751AE  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803751B2  0F 28 C7                    movaps  xmm0, xmm7; X
00000001803751B5  E8 1E A3 37 00              call    fmodf
00000001803751BA  0F 28 F8                    movaps  xmm7, xmm0
00000001803751BD  F3 41 0F 5C FD              subss   xmm7, xmm13
00000001803751C2  EB 1F                       jmp     short loc_1803751E3
00000001803751C4  41 0F 2F FF                 comiss  xmm7, xmm15
00000001803751C8  73 19                       jnb     short loc_1803751E3
00000001803751CA  F3 41 0F 5C FD              subss   xmm7, xmm13
00000001803751CF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803751D3  0F 28 C7                    movaps  xmm0, xmm7; X
00000001803751D6  E8 FD A2 37 00              call    fmodf
00000001803751DB  0F 28 F8                    movaps  xmm7, xmm0
00000001803751DE  F3 41 0F 58 FD              addss   xmm7, xmm13
00000001803751E3  41 0F 28 C0                 movaps  xmm0, xmm8
00000001803751E7  E8 D4 3D FF FF              call    sub_180368FC0
00000001803751EC  F3 0F 58 BB F0 84 00 00     addss   xmm7, dword ptr [rbx+84F0h]
00000001803751F4  F3 0F 59 83 80 84 00 00     mulss   xmm0, dword ptr [rbx+8480h]
00000001803751FC  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180375200  73 06                       jnb     short loc_180375208
0000000180375202  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180375206  EB 06                       jmp     short loc_18037520E
0000000180375208  76 04                       jbe     short loc_18037520E
000000018037520A  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037520E  F3 0F 58 B3 50 84 00 00     addss   xmm6, dword ptr [rbx+8450h]
0000000180375216  F3 0F 11 83 F0 81 00 00     movss   dword ptr [rbx+81F0h], xmm0
000000018037521E  F3 0F 11 BB 50 82 00 00     movss   dword ptr [rbx+8250h], xmm7
0000000180375226  F3 0F 59 BB 70 84 00 00     mulss   xmm7, dword ptr [rbx+8470h]
000000018037522E  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180375232  F3 0F 58 BB 00 85 00 00     addss   xmm7, dword ptr [rbx+8500h]
000000018037523A  76 1B                       jbe     short loc_180375257
000000018037523C  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180375241  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180375245  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180375248  E8 8B A2 37 00              call    fmodf
000000018037524D  0F 28 F0                    movaps  xmm6, xmm0
0000000180375250  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180375255  EB 1F                       jmp     short loc_180375276
0000000180375257  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037525B  73 19                       jnb     short loc_180375276
000000018037525D  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180375262  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180375266  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180375269  E8 6A A2 37 00              call    fmodf
000000018037526E  0F 28 F0                    movaps  xmm6, xmm0
0000000180375271  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180375276  0F 54 35 13 05 77 00        andps   xmm6, cs:xmmword_180AE5790
000000018037527D  F3 0F 11 BB E0 81 00 00     movss   dword ptr [rbx+81E0h], xmm7
0000000180375285  0F 28 E6                    movaps  xmm4, xmm6
0000000180375288  F3 0F 10 9B 20 83 00 00     movss   xmm3, dword ptr [rbx+8320h]
0000000180375290  0F 28 D6                    movaps  xmm2, xmm6
0000000180375293  F3 0F 59 93 B0 83 00 00     mulss   xmm2, dword ptr [rbx+83B0h]
000000018037529B  F3 0F 59 9B 10 82 00 00     mulss   xmm3, dword ptr [rbx+8210h]
00000001803752A3  F3 0F 58 93 A0 83 00 00     addss   xmm2, dword ptr [rbx+83A0h]
00000001803752AB  F3 0F 10 8B 10 83 00 00     movss   xmm1, dword ptr [rbx+8310h]
00000001803752B3  F3 0F 59 8B D0 81 00 00     mulss   xmm1, dword ptr [rbx+81D0h]
00000001803752BB  F3 0F 59 E6                 mulss   xmm4, xmm6
00000001803752BF  0F 28 C4                    movaps  xmm0, xmm4
00000001803752C2  F3 0F 59 E6                 mulss   xmm4, xmm6
00000001803752C6  F3 0F 59 83 C0 83 00 00     mulss   xmm0, dword ptr [rbx+83C0h]
00000001803752CE  F3 0F 59 F4                 mulss   xmm6, xmm4
00000001803752D2  F3 0F 59 A3 D0 83 00 00     mulss   xmm4, dword ptr [rbx+83D0h]
00000001803752DA  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803752DE  F3 0F 59 B3 E0 83 00 00     mulss   xmm6, dword ptr [rbx+83E0h]
00000001803752E6  F3 0F 10 83 00 83 00 00     movss   xmm0, dword ptr [rbx+8300h]
00000001803752EE  F3 0F 59 83 C0 81 00 00     mulss   xmm0, dword ptr [rbx+81C0h]
00000001803752F6  F3 0F 58 E2                 addss   xmm4, xmm2
00000001803752FA  F3 0F 58 D8                 addss   xmm3, xmm0
00000001803752FE  F3 0F 58 F4                 addss   xmm6, xmm4
0000000180375302  F3 0F 10 A3 E0 82 00 00     movss   xmm4, dword ptr [rbx+82E0h]
000000018037530A  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037530E  F3 0F 58 B3 F0 83 00 00     addss   xmm6, dword ptr [rbx+83F0h]
0000000180375316  F3 0F 59 B3 90 84 00 00     mulss   xmm6, dword ptr [rbx+8490h]
000000018037531E  F3 0F 11 B3 00 82 00 00     movss   dword ptr [rbx+8200h], xmm6
0000000180375326  F3 0F 59 A3 F0 81 00 00     mulss   xmm4, dword ptr [rbx+81F0h]
000000018037532E  F3 0F 10 8B C0 82 00 00     movss   xmm1, dword ptr [rbx+82C0h]
0000000180375336  F3 0F 10 83 F0 82 00 00     movss   xmm0, dword ptr [rbx+82F0h]
000000018037533E  F3 0F 59 83 E0 81 00 00     mulss   xmm0, dword ptr [rbx+81E0h]
0000000180375346  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037534A  F3 0F 10 93 50 83 00 00     movss   xmm2, dword ptr [rbx+8350h]
0000000180375352  0F 28 D9                    movaps  xmm3, xmm1
0000000180375355  F3 0F 59 9B F0 80 00 00     mulss   xmm3, dword ptr [rbx+80F0h]
000000018037535D  F3 0F 59 B3 D0 82 00 00     mulss   xmm6, dword ptr [rbx+82D0h]
0000000180375365  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180375369  F3 0F 10 83 30 83 00 00     movss   xmm0, dword ptr [rbx+8330h]
0000000180375371  F3 0F 5C D9                 subss   xmm3, xmm1
0000000180375375  F3 0F 59 83 B0 80 00 00     mulss   xmm0, dword ptr [rbx+80B0h]
000000018037537D  F3 0F 58 E6                 addss   xmm4, xmm6
0000000180375381  F3 41 0F 58 DD              addss   xmm3, xmm13
0000000180375386  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037538A  F3 0F 11 9B 20 82 00 00     movss   dword ptr [rbx+8220h], xmm3
0000000180375392  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180375396  F3 0F 11 A3 40 82 00 00     movss   dword ptr [rbx+8240h], xmm4
000000018037539E  F3 0F 10 8B 60 83 00 00     movss   xmm1, dword ptr [rbx+8360h]
00000001803753A6  F3 0F 59 8B D0 80 00 00     mulss   xmm1, dword ptr [rbx+80D0h]
00000001803753AE  F3 0F 10 83 70 83 00 00     movss   xmm0, dword ptr [rbx+8370h]
00000001803753B6  F3 0F 59 83 E0 80 00 00     mulss   xmm0, dword ptr [rbx+80E0h]
00000001803753BE  F3 0F 59 D4                 mulss   xmm2, xmm4
00000001803753C2  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803753C6  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803753CA  F3 0F 11 8B 30 82 00 00     movss   dword ptr [rbx+8230h], xmm1
00000001803753D2  F3 0F 10 83 40 82 00 00     movss   xmm0, dword ptr [rbx+8240h]
00000001803753DA  8B 83 50 82 00 00           mov     eax, [rbx+8250h]
00000001803753E0  89 83 10 85 00 00           mov     [rbx+8510h], eax
00000001803753E6  F3 0F 11 83 20 85 00 00     movss   dword ptr [rbx+8520h], xmm0
00000001803753EE  44 0F 2F B3 50 82 00 00     comiss  xmm14, dword ptr [rbx+8250h]
00000001803753F6  F3 0F 10 8B 60 7D 00 00     movss   xmm1, dword ptr [rbx+7D60h]
00000001803753FE  F3 0F 10 93 30 85 00 00     movss   xmm2, dword ptr [rbx+8530h]
0000000180375406  73 06                       jnb     short loc_18037540E
0000000180375408  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037540C  EB 03                       jmp     short loc_180375411
000000018037540E  0F 57 C0                    xorps   xmm0, xmm0
0000000180375411  41 0F 2E D6                 ucomiss xmm2, xmm14
0000000180375415  75 04                       jnz     short loc_18037541B
0000000180375417  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037541B  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037541F  F3 0F 11 8B 40 85 00 00     movss   dword ptr [rbx+8540h], xmm1
0000000180375427  8B 83 50 85 00 00           mov     eax, [rbx+8550h]
000000018037542D  89 83 60 85 00 00           mov     [rbx+8560h], eax
0000000180375433  8B 83 80 85 00 00           mov     eax, [rbx+8580h]
0000000180375439  89 83 90 85 00 00           mov     [rbx+8590h], eax
000000018037543F  8B 83 70 85 00 00           mov     eax, [rbx+8570h]
0000000180375445  89 83 80 85 00 00           mov     [rbx+8580h], eax
000000018037544B  8B 83 A0 85 00 00           mov     eax, [rbx+85A0h]
0000000180375451  89 83 B0 85 00 00           mov     [rbx+85B0h], eax
0000000180375457  8B 83 D0 85 00 00           mov     eax, [rbx+85D0h]
000000018037545D  89 83 E0 85 00 00           mov     [rbx+85E0h], eax
0000000180375463  F3 0F 10 83 80 86 00 00     movss   xmm0, dword ptr [rbx+8680h]
000000018037546B  F3 0F 58 8B 60 86 00 00     addss   xmm1, dword ptr [rbx+8660h]
0000000180375473  F3 0F 59 83 90 85 00 00     mulss   xmm0, dword ptr [rbx+8590h]
000000018037547B  41 0F 2F CE                 comiss  xmm1, xmm14
000000018037547F  F3 0F 58 83 60 85 00 00     addss   xmm0, dword ptr [rbx+8560h]
0000000180375487  73 06                       jnb     short loc_18037548F
0000000180375489  45 0F 28 C5                 movaps  xmm8, xmm13
000000018037548D  EB 04                       jmp     short loc_180375493
000000018037548F  45 0F 57 C0                 xorps   xmm8, xmm8
0000000180375493  41 0F 28 ED                 movaps  xmm5, xmm13
0000000180375497  F3 41 0F 5C E8              subss   xmm5, xmm8
000000018037549C  0F 28 FD                    movaps  xmm7, xmm5
000000018037549F  F3 0F 59 F8                 mulss   xmm7, xmm0
00000001803754A3  F3 0F 11 BB 70 85 00 00     movss   dword ptr [rbx+8570h], xmm7
00000001803754AB  0F 28 E7                    movaps  xmm4, xmm7
00000001803754AE  F3 0F 10 9B 50 86 00 00     movss   xmm3, dword ptr [rbx+8650h]
00000001803754B6  F3 0F 10 93 A0 86 00 00     movss   xmm2, dword ptr [rbx+86A0h]
00000001803754BE  0F 28 CB                    movaps  xmm1, xmm3
00000001803754C1  F3 0F 59 8B C0 86 00 00     mulss   xmm1, dword ptr [rbx+86C0h]
00000001803754C9  0F 28 C2                    movaps  xmm0, xmm2
00000001803754CC  F3 0F 58 A3 70 86 00 00     addss   xmm4, dword ptr [rbx+8670h]
00000001803754D4  F3 0F 5C BB 80 85 00 00     subss   xmm7, dword ptr [rbx+8580h]
00000001803754DC  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803754E0  41 0F 2F E6                 comiss  xmm4, xmm14
00000001803754E4  F3 0F 5C C8                 subss   xmm1, xmm0
00000001803754E8  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803754EC  F3 0F 11 8B C0 85 00 00     movss   dword ptr [rbx+85C0h], xmm1
00000001803754F4  72 06                       jb      short loc_1803754FC
00000001803754F6  41 0F 28 F5                 movaps  xmm6, xmm13
00000001803754FA  EB 03                       jmp     short loc_1803754FF
00000001803754FC  0F 57 F6                    xorps   xmm6, xmm6
00000001803754FF  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180375503  F3 0F 10 83 20 86 00 00     movss   xmm0, dword ptr [rbx+8620h]
000000018037550B  73 03                       jnb     short loc_180375510
000000018037550D  0F 28 F5                    movaps  xmm6, xmm5
0000000180375510  F3 0F 59 83 A0 86 00 00     mulss   xmm0, dword ptr [rbx+86A0h]
0000000180375518  0F 28 DD                    movaps  xmm3, xmm5
000000018037551B  F3 0F 10 93 10 86 00 00     movss   xmm2, dword ptr [rbx+8610h]
0000000180375523  F3 44 0F 10 0D 30 FA 76 00  movss   xmm9, cs:dword_180AE4F5C
000000018037552C  F3 0F 59 D8                 mulss   xmm3, xmm0
0000000180375530  F3 0F 11 B3 80 85 00 00     movss   dword ptr [rbx+8580h], xmm6
0000000180375538  F3 0F 10 8B B0 86 00 00     movss   xmm1, dword ptr [rbx+86B0h]
0000000180375540  F3 0F 10 BB 30 86 00 00     movss   xmm7, dword ptr [rbx+8630h]
0000000180375548  0F 28 C1                    movaps  xmm0, xmm1
000000018037554B  F3 0F 10 A3 B0 85 00 00     movss   xmm4, dword ptr [rbx+85B0h]
0000000180375553  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180375557  F3 41 0F 59 F9              mulss   xmm7, xmm9
000000018037555C  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180375560  F3 41 0F 59 D1              mulss   xmm2, xmm9
0000000180375565  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180375569  F3 0F 59 FE                 mulss   xmm7, xmm6
000000018037556D  F3 0F 5C C6                 subss   xmm0, xmm6
0000000180375571  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180375575  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180375579  0F 28 CB                    movaps  xmm1, xmm3
000000018037557C  F3 0F 5C CC                 subss   xmm1, xmm4
0000000180375580  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180375584  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180375588  F3 0F 58 FA                 addss   xmm7, xmm2
000000018037558C  76 0B                       jbe     short loc_180375599
000000018037558E  0F 28 DC                    movaps  xmm3, xmm4
0000000180375591  F3 0F 58 9B C0 85 00 00     addss   xmm3, dword ptr [rbx+85C0h]
0000000180375599  F3 0F 10 83 A0 86 00 00     movss   xmm0, dword ptr [rbx+86A0h]
00000001803755A1  F3 0F 10 A3 60 85 00 00     movss   xmm4, dword ptr [rbx+8560h]
00000001803755A9  F3 0F 5D C3                 minss   xmm0, xmm3
00000001803755AD  F3 0F 11 83 A0 85 00 00     movss   dword ptr [rbx+85A0h], xmm0
00000001803755B5  F3 0F 10 8B E0 85 00 00     movss   xmm1, dword ptr [rbx+85E0h]
00000001803755BD  F3 0F 10 9B 40 86 00 00     movss   xmm3, dword ptr [rbx+8640h]
00000001803755C5  F3 0F 59 AB 90 86 00 00     mulss   xmm5, dword ptr [rbx+8690h]
00000001803755CD  F3 41 0F 59 D9              mulss   xmm3, xmm9
00000001803755D2  F3 0F 59 F0                 mulss   xmm6, xmm0
00000001803755D6  F3 0F 10 83 D0 86 00 00     movss   xmm0, dword ptr [rbx+86D0h]
00000001803755DE  F3 41 0F 59 D8              mulss   xmm3, xmm8
00000001803755E3  0F 28 D0                    movaps  xmm2, xmm0
00000001803755E6  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803755EA  F3 0F 58 EE                 addss   xmm5, xmm6
00000001803755EE  F3 0F 59 D7                 mulss   xmm2, xmm7
00000001803755F2  F3 0F 5C EC                 subss   xmm5, xmm4
00000001803755F6  F3 0F 5C D0                 subss   xmm2, xmm0
00000001803755FA  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803755FE  F3 0F 11 93 D0 85 00 00     movss   dword ptr [rbx+85D0h], xmm2
0000000180375606  F3 44 0F 59 C2              mulss   xmm8, xmm2
000000018037560B  F3 41 0F 5C D8              subss   xmm3, xmm8
0000000180375610  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180375614  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180375618  F3 0F 58 DC                 addss   xmm3, xmm4
000000018037561C  F3 0F 11 9B 50 85 00 00     movss   dword ptr [rbx+8550h], xmm3
0000000180375624  F3 0F 59 9B E0 86 00 00     mulss   xmm3, dword ptr [rbx+86E0h]
000000018037562C  F3 0F 59 9B F0 86 00 00     mulss   xmm3, dword ptr [rbx+86F0h]
0000000180375634  0F 28 C3                    movaps  xmm0, xmm3
0000000180375637  F3 0F 59 83 00 87 00 00     mulss   xmm0, dword ptr [rbx+8700h]
000000018037563F  F3 0F 11 9B F0 85 00 00     movss   dword ptr [rbx+85F0h], xmm3
0000000180375647  F3 0F 11 83 00 86 00 00     movss   dword ptr [rbx+8600h], xmm0
000000018037564F  44 0F 2F B3 50 82 00 00     comiss  xmm14, dword ptr [rbx+8250h]
0000000180375657  F3 0F 10 8B 60 7D 00 00     movss   xmm1, dword ptr [rbx+7D60h]
000000018037565F  F3 0F 10 93 10 87 00 00     movss   xmm2, dword ptr [rbx+8710h]
0000000180375667  73 06                       jnb     short loc_18037566F
0000000180375669  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037566D  EB 03                       jmp     short loc_180375672
000000018037566F  0F 57 C0                    xorps   xmm0, xmm0
0000000180375672  41 0F 2E D6                 ucomiss xmm2, xmm14
0000000180375676  75 04                       jnz     short loc_18037567C
0000000180375678  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037567C  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180375680  F3 0F 11 8B 20 87 00 00     movss   dword ptr [rbx+8720h], xmm1
0000000180375688  8B 83 30 87 00 00           mov     eax, [rbx+8730h]
000000018037568E  89 83 40 87 00 00           mov     [rbx+8740h], eax
0000000180375694  8B 83 60 87 00 00           mov     eax, [rbx+8760h]
000000018037569A  89 83 70 87 00 00           mov     [rbx+8770h], eax
00000001803756A0  8B 83 50 87 00 00           mov     eax, [rbx+8750h]
00000001803756A6  89 83 60 87 00 00           mov     [rbx+8760h], eax
00000001803756AC  8B 83 80 87 00 00           mov     eax, [rbx+8780h]
00000001803756B2  89 83 90 87 00 00           mov     [rbx+8790h], eax
00000001803756B8  8B 83 B0 87 00 00           mov     eax, [rbx+87B0h]
00000001803756BE  89 83 C0 87 00 00           mov     [rbx+87C0h], eax
00000001803756C4  F3 0F 10 83 60 88 00 00     movss   xmm0, dword ptr [rbx+8860h]
00000001803756CC  F3 0F 58 8B 40 88 00 00     addss   xmm1, dword ptr [rbx+8840h]
00000001803756D4  F3 0F 59 83 70 87 00 00     mulss   xmm0, dword ptr [rbx+8770h]
00000001803756DC  41 0F 2F CE                 comiss  xmm1, xmm14
00000001803756E0  F3 0F 58 83 40 87 00 00     addss   xmm0, dword ptr [rbx+8740h]
00000001803756E8  73 06                       jnb     short loc_1803756F0
00000001803756EA  45 0F 28 C5                 movaps  xmm8, xmm13
00000001803756EE  EB 04                       jmp     short loc_1803756F4
00000001803756F0  45 0F 57 C0                 xorps   xmm8, xmm8
00000001803756F4  41 0F 28 ED                 movaps  xmm5, xmm13
00000001803756F8  F3 41 0F 5C E8              subss   xmm5, xmm8
00000001803756FD  0F 28 F5                    movaps  xmm6, xmm5
0000000180375700  F3 0F 59 F0                 mulss   xmm6, xmm0
0000000180375704  F3 0F 11 B3 50 87 00 00     movss   dword ptr [rbx+8750h], xmm6
000000018037570C  0F 28 E6                    movaps  xmm4, xmm6
000000018037570F  F3 0F 10 9B 30 88 00 00     movss   xmm3, dword ptr [rbx+8830h]
0000000180375717  F3 0F 10 93 80 88 00 00     movss   xmm2, dword ptr [rbx+8880h]
000000018037571F  0F 28 CB                    movaps  xmm1, xmm3
0000000180375722  F3 0F 59 8B A0 88 00 00     mulss   xmm1, dword ptr [rbx+88A0h]
000000018037572A  0F 28 C2                    movaps  xmm0, xmm2
000000018037572D  F3 0F 58 A3 50 88 00 00     addss   xmm4, dword ptr [rbx+8850h]
0000000180375735  F3 0F 5C B3 60 87 00 00     subss   xmm6, dword ptr [rbx+8760h]
000000018037573D  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180375741  41 0F 2F E6                 comiss  xmm4, xmm14
0000000180375745  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180375749  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037574D  F3 0F 11 8B A0 87 00 00     movss   dword ptr [rbx+87A0h], xmm1
0000000180375755  72 06                       jb      short loc_18037575D
0000000180375757  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037575B  EB 03                       jmp     short loc_180375760
000000018037575D  0F 57 FF                    xorps   xmm7, xmm7
0000000180375760  41 0F 2F F6                 comiss  xmm6, xmm14
0000000180375764  F3 0F 10 83 00 88 00 00     movss   xmm0, dword ptr [rbx+8800h]
000000018037576C  73 03                       jnb     short loc_180375771
000000018037576E  0F 28 FD                    movaps  xmm7, xmm5
0000000180375771  F3 0F 59 83 80 88 00 00     mulss   xmm0, dword ptr [rbx+8880h]
0000000180375779  0F 28 DD                    movaps  xmm3, xmm5
000000018037577C  F3 0F 10 93 F0 87 00 00     movss   xmm2, dword ptr [rbx+87F0h]
0000000180375784  F3 0F 11 BB 60 87 00 00     movss   dword ptr [rbx+8760h], xmm7
000000018037578C  F3 0F 10 8B 90 88 00 00     movss   xmm1, dword ptr [rbx+8890h]
0000000180375794  F3 0F 10 B3 10 88 00 00     movss   xmm6, dword ptr [rbx+8810h]
000000018037579C  F3 0F 10 A3 90 87 00 00     movss   xmm4, dword ptr [rbx+8790h]
00000001803757A4  F3 0F 59 D8                 mulss   xmm3, xmm0
00000001803757A8  0F 28 C1                    movaps  xmm0, xmm1
00000001803757AB  F3 0F 59 C5                 mulss   xmm0, xmm5
00000001803757AF  F3 41 0F 59 F1              mulss   xmm6, xmm9
00000001803757B4  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803757B8  F3 41 0F 59 D1              mulss   xmm2, xmm9
00000001803757BD  41 0F 28 C5                 movaps  xmm0, xmm13
00000001803757C1  F3 0F 59 F7                 mulss   xmm6, xmm7
00000001803757C5  F3 0F 5C C7                 subss   xmm0, xmm7
00000001803757C9  F3 0F 58 D9                 addss   xmm3, xmm1
00000001803757CD  F3 0F 59 E8                 mulss   xmm5, xmm0
00000001803757D1  0F 28 CB                    movaps  xmm1, xmm3
00000001803757D4  F3 0F 5C CC                 subss   xmm1, xmm4
00000001803757D8  F3 0F 59 D5                 mulss   xmm2, xmm5
00000001803757DC  41 0F 2F CE                 comiss  xmm1, xmm14
00000001803757E0  F3 0F 58 F2                 addss   xmm6, xmm2
00000001803757E4  76 0B                       jbe     short loc_1803757F1
00000001803757E6  0F 28 DC                    movaps  xmm3, xmm4
00000001803757E9  F3 0F 58 9B A0 87 00 00     addss   xmm3, dword ptr [rbx+87A0h]
00000001803757F1  F3 0F 10 A3 40 87 00 00     movss   xmm4, dword ptr [rbx+8740h]
00000001803757F9  F3 0F 10 83 80 88 00 00     movss   xmm0, dword ptr [rbx+8880h]
0000000180375801  F3 0F 5D C3                 minss   xmm0, xmm3
0000000180375805  F3 0F 11 83 80 87 00 00     movss   dword ptr [rbx+8780h], xmm0
000000018037580D  F3 0F 59 AB 70 88 00 00     mulss   xmm5, dword ptr [rbx+8870h]
0000000180375815  F3 0F 10 8B C0 87 00 00     movss   xmm1, dword ptr [rbx+87C0h]
000000018037581D  F3 0F 10 9B 20 88 00 00     movss   xmm3, dword ptr [rbx+8820h]
0000000180375825  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180375829  F3 0F 10 83 B0 88 00 00     movss   xmm0, dword ptr [rbx+88B0h]
0000000180375831  0F 28 D0                    movaps  xmm2, xmm0
0000000180375834  F3 41 0F 59 D9              mulss   xmm3, xmm9
0000000180375839  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037583D  F3 0F 58 EF                 addss   xmm5, xmm7
0000000180375841  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180375846  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037584A  F3 0F 5C EC                 subss   xmm5, xmm4
000000018037584E  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180375852  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180375856  F3 0F 11 93 B0 87 00 00     movss   dword ptr [rbx+87B0h], xmm2
000000018037585E  F3 44 0F 59 C2              mulss   xmm8, xmm2
0000000180375863  F3 41 0F 5C D8              subss   xmm3, xmm8
0000000180375868  F3 0F 58 DA                 addss   xmm3, xmm2
000000018037586C  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180375870  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180375874  F3 0F 11 9B 30 87 00 00     movss   dword ptr [rbx+8730h], xmm3
000000018037587C  F3 0F 59 9B C0 88 00 00     mulss   xmm3, dword ptr [rbx+88C0h]
0000000180375884  F3 0F 59 9B D0 88 00 00     mulss   xmm3, dword ptr [rbx+88D0h]
000000018037588C  0F 28 C3                    movaps  xmm0, xmm3
000000018037588F  F3 0F 59 83 E0 88 00 00     mulss   xmm0, dword ptr [rbx+88E0h]
0000000180375897  F3 0F 11 9B D0 87 00 00     movss   dword ptr [rbx+87D0h], xmm3
000000018037589F  F3 0F 11 83 E0 87 00 00     movss   dword ptr [rbx+87E0h], xmm0
00000001803758A7  8B 83 F0 88 00 00           mov     eax, [rbx+88F0h]
00000001803758AD  89 83 00 89 00 00           mov     [rbx+8900h], eax
00000001803758B3  8B 83 10 89 00 00           mov     eax, [rbx+8910h]
00000001803758B9  89 83 20 89 00 00           mov     [rbx+8920h], eax
00000001803758BF  F3 0F 10 83 20 7E 00 00     movss   xmm0, dword ptr [rbx+7E20h]
00000001803758C7  F3 44 0F 10 83 A0 7E 00 00  movss   xmm8, dword ptr [rbx+7EA0h]
00000001803758D0  8B 83 50 89 00 00           mov     eax, [rbx+8950h]
00000001803758D6  89 83 60 89 00 00           mov     [rbx+8960h], eax
00000001803758DC  F3 0F 59 83 30 89 00 00     mulss   xmm0, dword ptr [rbx+8930h]
00000001803758E4  F3 44 0F 59 83 40 89 00 00  mulss   xmm8, dword ptr [rbx+8940h]
00000001803758ED  F3 44 0F 58 C0              addss   xmm8, xmm0
00000001803758F2  F3 44 0F 11 83 50 89 00 00  movss   dword ptr [rbx+8950h], xmm8
00000001803758FB  F3 0F 10 BB 30 82 00 00     movss   xmm7, dword ptr [rbx+8230h]
0000000180375903  F3 0F 10 8B F0 85 00 00     movss   xmm1, dword ptr [rbx+85F0h]
000000018037590B  F3 0F 10 93 D0 87 00 00     movss   xmm2, dword ptr [rbx+87D0h]
0000000180375913  F3 0F 10 83 20 7E 00 00     movss   xmm0, dword ptr [rbx+7E20h]
000000018037591B  8B 83 10 89 00 00           mov     eax, [rbx+8910h]
0000000180375921  89 83 90 89 00 00           mov     [rbx+8990h], eax
0000000180375927  F3 0F 11 83 A0 89 00 00     movss   dword ptr [rbx+89A0h], xmm0
000000018037592F  F3 0F 10 A3 E0 8A 00 00     movss   xmm4, dword ptr [rbx+8AE0h]
0000000180375937  F3 0F 11 8B 70 89 00 00     movss   dword ptr [rbx+8970h], xmm1
000000018037593F  F3 0F 11 93 80 89 00 00     movss   dword ptr [rbx+8980h], xmm2
0000000180375947  F3 0F 10 AB C0 8A 00 00     movss   xmm5, dword ptr [rbx+8AC0h]
000000018037594F  F3 0F 59 FC                 mulss   xmm7, xmm4
0000000180375953  F3 0F 59 A3 40 82 00 00     mulss   xmm4, dword ptr [rbx+8240h]
000000018037595B  F3 0F 11 A3 B0 89 00 00     movss   dword ptr [rbx+89B0h], xmm4
0000000180375963  F3 0F 10 8B 40 8A 00 00     movss   xmm1, dword ptr [rbx+8A40h]
000000018037596B  F3 0F 10 93 40 8B 00 00     movss   xmm2, dword ptr [rbx+8B40h]
0000000180375973  0F 28 D9                    movaps  xmm3, xmm1
0000000180375976  F3 0F 59 BB F0 8A 00 00     mulss   xmm7, dword ptr [rbx+8AF0h]
000000018037597E  0F 28 C2                    movaps  xmm0, xmm2
0000000180375981  F3 0F 10 B3 00 8B 00 00     movss   xmm6, dword ptr [rbx+8B00h]
0000000180375989  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037598D  F3 0F 59 F7                 mulss   xmm6, xmm7
0000000180375991  F3 0F 59 EC                 mulss   xmm5, xmm4
0000000180375995  F3 0F 59 AB D0 8A 00 00     mulss   xmm5, dword ptr [rbx+8AD0h]
000000018037599D  F3 0F 11 AB D0 89 00 00     movss   dword ptr [rbx+89D0h], xmm5
00000001803759A5  F3 0F 58 F5                 addss   xmm6, xmm5
00000001803759A9  F3 0F 59 9B 90 89 00 00     mulss   xmm3, dword ptr [rbx+8990h]
00000001803759B1  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803759B5  F3 0F 10 83 50 8A 00 00     movss   xmm0, dword ptr [rbx+8A50h]
00000001803759BD  F3 0F 58 DA                 addss   xmm3, xmm2
00000001803759C1  F3 0F 59 9B 50 8B 00 00     mulss   xmm3, dword ptr [rbx+8B50h]
00000001803759C9  F3 0F 11 9B E0 89 00 00     movss   dword ptr [rbx+89E0h], xmm3
00000001803759D1  F3 0F 10 8B 20 8B 00 00     movss   xmm1, dword ptr [rbx+8B20h]
00000001803759D9  F3 0F 59 8B 80 89 00 00     mulss   xmm1, dword ptr [rbx+8980h]
00000001803759E1  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803759E5  F3 0F 58 F0                 addss   xmm6, xmm0
00000001803759E9  F3 0F 10 83 10 8B 00 00     movss   xmm0, dword ptr [rbx+8B10h]
00000001803759F1  F3 0F 59 83 70 89 00 00     mulss   xmm0, dword ptr [rbx+8970h]
00000001803759F9  F3 0F 10 9B B0 89 00 00     movss   xmm3, dword ptr [rbx+89B0h]
0000000180375A01  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180375A05  F3 0F 10 83 30 8A 00 00     movss   xmm0, dword ptr [rbx+8A30h]
0000000180375A0D  F3 0F 59 8B 30 8B 00 00     mulss   xmm1, dword ptr [rbx+8B30h]
0000000180375A15  F3 0F 58 CE                 addss   xmm1, xmm6
0000000180375A19  F3 41 0F 58 C8              addss   xmm1, xmm8
0000000180375A1E  F3 0F 58 8B A0 8A 00 00     addss   xmm1, dword ptr [rbx+8AA0h]
0000000180375A26  F3 0F 58 8B B0 8A 00 00     addss   xmm1, dword ptr [rbx+8AB0h]
0000000180375A2E  F3 0F 11 8B F0 89 00 00     movss   dword ptr [rbx+89F0h], xmm1
0000000180375A36  F3 0F 11 83 00 8A 00 00     movss   dword ptr [rbx+8A00h], xmm0
0000000180375A3E  F3 0F 59 9B 70 8B 00 00     mulss   xmm3, dword ptr [rbx+8B70h]
0000000180375A46  F3 0F 10 83 70 8A 00 00     movss   xmm0, dword ptr [rbx+8A70h]
0000000180375A4E  F3 0F 59 83 70 89 00 00     mulss   xmm0, dword ptr [rbx+8970h]
0000000180375A56  F3 0F 58 9B 80 8B 00 00     addss   xmm3, dword ptr [rbx+8B80h]
0000000180375A5E  F3 0F 10 8B 80 8A 00 00     movss   xmm1, dword ptr [rbx+8A80h]
0000000180375A66  F3 0F 59 8B 80 89 00 00     mulss   xmm1, dword ptr [rbx+8980h]
0000000180375A6E  F3 0F 10 93 D0 89 00 00     movss   xmm2, dword ptr [rbx+89D0h]
0000000180375A76  F3 0F 59 9B 60 8A 00 00     mulss   xmm3, dword ptr [rbx+8A60h]
0000000180375A7E  F3 0F 58 93 A0 89 00 00     addss   xmm2, dword ptr [rbx+89A0h]
0000000180375A86  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180375A8A  F3 0F 58 93 E0 89 00 00     addss   xmm2, dword ptr [rbx+89E0h]
0000000180375A92  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180375A96  F3 0F 58 9B 90 8A 00 00     addss   xmm3, dword ptr [rbx+8A90h]
0000000180375A9E  F3 0F 59 9B 60 8B 00 00     mulss   xmm3, dword ptr [rbx+8B60h]
0000000180375AA6  F3 0F 11 9B 10 8A 00 00     movss   dword ptr [rbx+8A10h], xmm3
0000000180375AAE  F3 0F 11 93 20 8A 00 00     movss   dword ptr [rbx+8A20h], xmm2
0000000180375AB6  F3 0F 10 83 A0 8B 00 00     movss   xmm0, dword ptr [rbx+8BA0h]
0000000180375ABE  8B 83 90 8B 00 00           mov     eax, [rbx+8B90h]
0000000180375AC4  89 83 C0 8B 00 00           mov     [rbx+8BC0h], eax
0000000180375ACA  F3 0F 11 83 D0 8B 00 00     movss   dword ptr [rbx+8BD0h], xmm0
0000000180375AD2  8B 83 B0 8B 00 00           mov     eax, [rbx+8BB0h]
0000000180375AD8  89 83 E0 8B 00 00           mov     [rbx+8BE0h], eax
0000000180375ADE  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
0000000180375AE6  8B 83 00 8C 00 00           mov     eax, [rbx+8C00h]
0000000180375AEC  89 83 10 8C 00 00           mov     [rbx+8C10h], eax
0000000180375AF2  F3 0F 10 93 F0 8B 00 00     movss   xmm2, dword ptr [rbx+8BF0h]
0000000180375AFA  F3 0F 11 93 00 8C 00 00     movss   dword ptr [rbx+8C00h], xmm2
0000000180375B02  0F 28 C2                    movaps  xmm0, xmm2
0000000180375B05  0F 28 DA                    movaps  xmm3, xmm2
0000000180375B08  F3 0F 59 9B 20 8C 00 00     mulss   xmm3, dword ptr [rbx+8C20h]
0000000180375B10  F3 0F 58 9B 10 8C 00 00     addss   xmm3, dword ptr [rbx+8C10h]
0000000180375B18  F3 0F 11 9B 00 8C 00 00     movss   dword ptr [rbx+8C00h], xmm3
0000000180375B20  F3 0F 59 83 30 8C 00 00     mulss   xmm0, dword ptr [rbx+8C30h]
0000000180375B28  F3 0F 58 C3                 addss   xmm0, xmm3
0000000180375B2C  F3 0F 59 9B 60 8C 00 00     mulss   xmm3, dword ptr [rbx+8C60h]
0000000180375B34  F3 0F 5C E0                 subss   xmm4, xmm0
0000000180375B38  0F 28 CC                    movaps  xmm1, xmm4
0000000180375B3B  F3 0F 59 8B 20 8C 00 00     mulss   xmm1, dword ptr [rbx+8C20h]
0000000180375B43  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180375B47  F3 0F 11 8B F0 8B 00 00     movss   dword ptr [rbx+8BF0h], xmm1
0000000180375B4F  F3 0F 59 8B 50 8C 00 00     mulss   xmm1, dword ptr [rbx+8C50h]
0000000180375B57  F3 0F 59 A3 40 8C 00 00     mulss   xmm4, dword ptr [rbx+8C40h]
0000000180375B5F  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180375B63  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180375B67  F3 0F 11 A3 10 8C 00 00     movss   dword ptr [rbx+8C10h], xmm4
0000000180375B6F  8B 83 40 94 00 00           mov     eax, [rbx+9440h]
0000000180375B75  89 83 50 94 00 00           mov     [rbx+9450h], eax
0000000180375B7B  F3 0F 10 8B 60 94 00 00     movss   xmm1, dword ptr [rbx+9460h]
0000000180375B83  F3 0F 11 8B 70 94 00 00     movss   dword ptr [rbx+9470h], xmm1
0000000180375B8B  F3 0F 59 8B 00 89 00 00     mulss   xmm1, dword ptr [rbx+8900h]
0000000180375B93  F3 0F 10 83 50 94 00 00     movss   xmm0, dword ptr [rbx+9450h]
0000000180375B9B  F3 0F 59 83 10 8C 00 00     mulss   xmm0, dword ptr [rbx+8C10h]
0000000180375BA3  F3 0F 11 8B 80 94 00 00     movss   dword ptr [rbx+9480h], xmm1
0000000180375BAB  F3 0F 11 83 90 94 00 00     movss   dword ptr [rbx+9490h], xmm0
0000000180375BB3  8B 83 C0 94 00 00           mov     eax, [rbx+94C0h]
0000000180375BB9  89 83 D0 94 00 00           mov     [rbx+94D0h], eax
0000000180375BBF  F3 0F 59 8B A0 94 00 00     mulss   xmm1, dword ptr [rbx+94A0h]
0000000180375BC7  F3 0F 59 83 B0 94 00 00     mulss   xmm0, dword ptr [rbx+94B0h]
0000000180375BCF  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180375BD3  F3 0F 11 83 C0 94 00 00     movss   dword ptr [rbx+94C0h], xmm0
0000000180375BDB  8B 83 E0 94 00 00           mov     eax, [rbx+94E0h]
0000000180375BE1  89 83 F0 94 00 00           mov     [rbx+94F0h], eax
0000000180375BE7  8B 83 00 95 00 00           mov     eax, [rbx+9500h]
0000000180375BED  89 83 10 95 00 00           mov     [rbx+9510h], eax
0000000180375BF3  8B 83 20 95 00 00           mov     eax, [rbx+9520h]
0000000180375BF9  89 83 30 95 00 00           mov     [rbx+9530h], eax
0000000180375BFF  8B 83 40 95 00 00           mov     eax, [rbx+9540h]
0000000180375C05  89 83 50 95 00 00           mov     [rbx+9550h], eax
0000000180375C0B  F3 0F 10 8B 70 95 00 00     movss   xmm1, dword ptr [rbx+9570h]
0000000180375C13  F3 0F 10 93 80 95 00 00     movss   xmm2, dword ptr [rbx+9580h]
0000000180375C1B  0F 28 E1                    movaps  xmm4, xmm1
0000000180375C1E  F3 0F 59 A3 E0 94 00 00     mulss   xmm4, dword ptr [rbx+94E0h]
0000000180375C26  0F 28 C2                    movaps  xmm0, xmm2
0000000180375C29  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180375C2D  F3 0F 5C E0                 subss   xmm4, xmm0
0000000180375C31  F3 0F 58 E2                 addss   xmm4, xmm2
0000000180375C35  0F 28 DC                    movaps  xmm3, xmm4
0000000180375C38  0F 28 CC                    movaps  xmm1, xmm4
0000000180375C3B  F3 0F 59 8B A0 95 00 00     mulss   xmm1, dword ptr [rbx+95A0h]
0000000180375C43  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180375C47  F3 0F 58 8B 90 95 00 00     addss   xmm1, dword ptr [rbx+9590h]
0000000180375C4F  0F 28 C3                    movaps  xmm0, xmm3
0000000180375C52  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180375C56  F3 0F 59 83 B0 95 00 00     mulss   xmm0, dword ptr [rbx+95B0h]
0000000180375C5E  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180375C62  0F 28 C3                    movaps  xmm0, xmm3
0000000180375C65  F3 0F 59 9B C0 95 00 00     mulss   xmm3, dword ptr [rbx+95C0h]
0000000180375C6D  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180375C71  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180375C75  F3 0F 59 83 D0 95 00 00     mulss   xmm0, dword ptr [rbx+95D0h]
0000000180375C7D  F3 0F 58 C3                 addss   xmm0, xmm3
0000000180375C81  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180375C85  76 05                       jbe     short loc_180375C8C
0000000180375C87  0F 5A C0                    cvtps2pd xmm0, xmm0
0000000180375C8A  EB 03                       jmp     short loc_180375C8F
0000000180375C8C  0F 57 C0                    xorps   xmm0, xmm0
0000000180375C8F  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
0000000180375C93  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180375C97  73 04                       jnb     short loc_180375C9D
0000000180375C99  44 0F 5A E1                 cvtps2pd xmm12, xmm1
0000000180375C9D  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
0000000180375CA2  F3 0F 11 83 60 95 00 00     movss   dword ptr [rbx+9560h], xmm0
0000000180375CAA  8B 83 E0 95 00 00           mov     eax, [rbx+95E0h]
0000000180375CB0  89 83 F0 95 00 00           mov     [rbx+95F0h], eax
0000000180375CB6  F3 0F 10 8B 00 96 00 00     movss   xmm1, dword ptr [rbx+9600h]
0000000180375CBE  F3 0F 11 8B 10 96 00 00     movss   dword ptr [rbx+9610h], xmm1
0000000180375CC6  F3 0F 10 83 20 96 00 00     movss   xmm0, dword ptr [rbx+9620h]
0000000180375CCE  F3 0F 11 83 30 96 00 00     movss   dword ptr [rbx+9630h], xmm0
0000000180375CD6  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180375CDA  F3 0F 59 8B 40 96 00 00     mulss   xmm1, dword ptr [rbx+9640h]
0000000180375CE2  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180375CE6  F3 0F 11 8B 20 96 00 00     movss   dword ptr [rbx+9620h], xmm1
0000000180375CEE  F3 0F 10 8B 20 7E 00 00     movss   xmm1, dword ptr [rbx+7E20h]
0000000180375CF6  F3 0F 10 83 A0 7E 00 00     movss   xmm0, dword ptr [rbx+7EA0h]
0000000180375CFE  8B 83 70 96 00 00           mov     eax, [rbx+9670h]
0000000180375D04  89 83 80 96 00 00           mov     [rbx+9680h], eax
0000000180375D0A  F3 0F 59 83 60 96 00 00     mulss   xmm0, dword ptr [rbx+9660h]
0000000180375D12  F3 0F 59 8B 50 96 00 00     mulss   xmm1, dword ptr [rbx+9650h]
0000000180375D1A  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180375D1E  F3 0F 11 83 70 96 00 00     movss   dword ptr [rbx+9670h], xmm0
0000000180375D26  8B 83 90 96 00 00           mov     eax, [rbx+9690h]
0000000180375D2C  89 83 B0 96 00 00           mov     [rbx+96B0h], eax
0000000180375D32  F3 0F 10 9B A0 96 00 00     movss   xmm3, dword ptr [rbx+96A0h]
0000000180375D3A  F3 0F 11 9B C0 96 00 00     movss   dword ptr [rbx+96C0h], xmm3
0000000180375D42  F3 0F 10 8B B0 96 00 00     movss   xmm1, dword ptr [rbx+96B0h]
0000000180375D4A  F3 0F 10 93 F0 85 00 00     movss   xmm2, dword ptr [rbx+85F0h]
0000000180375D52  0F 28 C1                    movaps  xmm0, xmm1
0000000180375D55  F3 0F 59 83 D0 87 00 00     mulss   xmm0, dword ptr [rbx+87D0h]
0000000180375D5D  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180375D61  F3 0F 5C C1                 subss   xmm0, xmm1
0000000180375D65  0F 28 CB                    movaps  xmm1, xmm3
0000000180375D68  F3 0F 59 8B 20 95 00 00     mulss   xmm1, dword ptr [rbx+9520h]
0000000180375D70  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180375D74  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180375D78  F3 0F 5C CB                 subss   xmm1, xmm3
0000000180375D7C  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180375D80  F3 0F 11 8B D0 96 00 00     movss   dword ptr [rbx+96D0h], xmm1
0000000180375D88  F3 0F 10 9B 30 82 00 00     movss   xmm3, dword ptr [rbx+8230h]
0000000180375D90  F3 0F 10 83 E0 96 00 00     movss   xmm0, dword ptr [rbx+96E0h]
0000000180375D98  F3 0F 11 83 F0 96 00 00     movss   dword ptr [rbx+96F0h], xmm0
0000000180375DA0  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180375DA4  0F 28 CB                    movaps  xmm1, xmm3
0000000180375DA7  F3 0F 59 8B 00 97 00 00     mulss   xmm1, dword ptr [rbx+9700h]
0000000180375DAF  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180375DB3  F3 0F 10 83 20 97 00 00     movss   xmm0, dword ptr [rbx+9720h]
0000000180375DBB  F3 0F 11 8B E0 96 00 00     movss   dword ptr [rbx+96E0h], xmm1
0000000180375DC3  F3 0F 59 9B 10 97 00 00     mulss   xmm3, dword ptr [rbx+9710h]
0000000180375DCB  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180375DCF  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180375DD3  F3 0F 11 9B F0 96 00 00     movss   dword ptr [rbx+96F0h], xmm3
0000000180375DDB  F3 0F 10 83 30 97 00 00     movss   xmm0, dword ptr [rbx+9730h]
0000000180375DE3  F3 0F 10 BB 40 82 00 00     movss   xmm7, dword ptr [rbx+8240h]
0000000180375DEB  F3 0F 11 83 40 97 00 00     movss   dword ptr [rbx+9740h], xmm0
0000000180375DF3  F3 0F 5C F8                 subss   xmm7, xmm0
0000000180375DF7  0F 28 CF                    movaps  xmm1, xmm7
0000000180375DFA  F3 0F 59 8B 50 97 00 00     mulss   xmm1, dword ptr [rbx+9750h]
0000000180375E02  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180375E06  F3 0F 10 83 70 97 00 00     movss   xmm0, dword ptr [rbx+9770h]
0000000180375E0E  F3 0F 11 8B 30 97 00 00     movss   dword ptr [rbx+9730h], xmm1
0000000180375E16  F3 0F 59 BB 60 97 00 00     mulss   xmm7, dword ptr [rbx+9760h]
0000000180375E1E  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180375E22  F3 0F 58 F8                 addss   xmm7, xmm0
0000000180375E26  F3 0F 11 BB 40 97 00 00     movss   dword ptr [rbx+9740h], xmm7
0000000180375E2E  F3 0F 10 A3 F0 96 00 00     movss   xmm4, dword ptr [rbx+96F0h]
0000000180375E36  F3 0F 10 AB D0 96 00 00     movss   xmm5, dword ptr [rbx+96D0h]
0000000180375E3E  F3 0F 10 B3 70 96 00 00     movss   xmm6, dword ptr [rbx+9670h]
0000000180375E46  F3 44 0F 10 8B 00 95 00 00  movss   xmm9, dword ptr [rbx+9500h]
0000000180375E4F  8B 83 20 96 00 00           mov     eax, [rbx+9620h]
0000000180375E55  89 83 80 97 00 00           mov     [rbx+9780h], eax
0000000180375E5B  F3 44 0F 11 8B 90 97 00 00  movss   dword ptr [rbx+9790h], xmm9
0000000180375E64  F3 0F 10 83 B0 97 00 00     movss   xmm0, dword ptr [rbx+97B0h]
0000000180375E6C  F3 0F 10 93 C0 97 00 00     movss   xmm2, dword ptr [rbx+97C0h]
0000000180375E74  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180375E78  0F 28 DA                    movaps  xmm3, xmm2
0000000180375E7B  F3 0F 59 9B 40 95 00 00     mulss   xmm3, dword ptr [rbx+9540h]
0000000180375E83  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180375E87  0F 28 C2                    movaps  xmm0, xmm2
0000000180375E8A  F3 0F 59 C7                 mulss   xmm0, xmm7
0000000180375E8E  44 0F 28 C3                 movaps  xmm8, xmm3
0000000180375E92  F3 44 0F 5C C0              subss   xmm8, xmm0
0000000180375E97  F3 44 0F 58 C7              addss   xmm8, xmm7
0000000180375E9C  F3 44 0F 59 83 F0 97 00 00  mulss   xmm8, dword ptr [rbx+97F0h]
0000000180375EA5  F3 0F 10 8B D0 97 00 00     movss   xmm1, dword ptr [rbx+97D0h]
0000000180375EAD  F3 0F 58 B3 70 98 00 00     addss   xmm6, dword ptr [rbx+9870h]
0000000180375EB5  F3 44 0F 59 83 00 98 00 00  mulss   xmm8, dword ptr [rbx+9800h]
0000000180375EBE  F3 0F 59 AB 10 98 00 00     mulss   xmm5, dword ptr [rbx+9810h]
0000000180375EC6  F3 0F 59 B3 20 98 00 00     mulss   xmm6, dword ptr [rbx+9820h]
0000000180375ECE  F3 44 0F 59 C9              mulss   xmm9, xmm1
0000000180375ED3  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180375ED7  F3 0F 58 F5                 addss   xmm6, xmm5
0000000180375EDB  F3 0F 5C DA                 subss   xmm3, xmm2
0000000180375EDF  F3 0F 10 93 50 98 00 00     movss   xmm2, dword ptr [rbx+9850h]
0000000180375EE7  0F 28 C2                    movaps  xmm0, xmm2
0000000180375EEA  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180375EEE  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180375EF2  F3 44 0F 5C C8              subss   xmm9, xmm0
0000000180375EF7  F3 0F 10 83 40 98 00 00     movss   xmm0, dword ptr [rbx+9840h]
0000000180375EFF  F3 0F 58 83 80 97 00 00     addss   xmm0, dword ptr [rbx+9780h]
0000000180375F07  F3 0F 59 9B E0 97 00 00     mulss   xmm3, dword ptr [rbx+97E0h]
0000000180375F0F  F3 0F 59 83 80 98 00 00     mulss   xmm0, dword ptr [rbx+9880h]
0000000180375F17  F3 44 0F 58 CA              addss   xmm9, xmm2
0000000180375F1C  F3 44 0F 58 C3              addss   xmm8, xmm3
0000000180375F21  F3 0F 59 83 30 98 00 00     mulss   xmm0, dword ptr [rbx+9830h]
0000000180375F29  F3 44 0F 59 8B 60 98 00 00  mulss   xmm9, dword ptr [rbx+9860h]
0000000180375F32  F3 44 0F 58 C6              addss   xmm8, xmm6
0000000180375F37  F3 44 0F 58 C8              addss   xmm9, xmm0
0000000180375F3C  F3 45 0F 58 C8              addss   xmm9, xmm8
0000000180375F41  F3 44 0F 11 8B A0 97 00 00  movss   dword ptr [rbx+97A0h], xmm9
0000000180375F4A  F3 0F 10 BB 60 95 00 00     movss   xmm7, dword ptr [rbx+9560h]
0000000180375F52  F3 44 0F 10 83 F0 95 00 00  movss   xmm8, dword ptr [rbx+95F0h]
0000000180375F5B  8B 83 C0 98 00 00           mov     eax, [rbx+98C0h]
0000000180375F61  89 83 D0 98 00 00           mov     [rbx+98D0h], eax
0000000180375F67  F3 0F 10 83 B0 98 00 00     movss   xmm0, dword ptr [rbx+98B0h]
0000000180375F6F  F3 0F 11 83 C0 98 00 00     movss   dword ptr [rbx+98C0h], xmm0
0000000180375F77  44 0F 2E AB 00 99 00 00     ucomiss xmm13, dword ptr [rbx+9900h]
0000000180375F7F  0F 85 8F 02 00 00           jnz     loc_180376214
0000000180375F85  F3 0F 10 8B 50 99 00 00     movss   xmm1, dword ptr [rbx+9950h]
0000000180375F8D  F3 0F 10 B3 D0 98 00 00     movss   xmm6, dword ptr [rbx+98D0h]
0000000180375F95  0F 28 D1                    movaps  xmm2, xmm1
0000000180375F98  F3 0F 59 CE                 mulss   xmm1, xmm6
0000000180375F9C  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180375FA0  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180375FA4  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180375FA8  F3 0F 58 F2                 addss   xmm6, xmm2
0000000180375FAC  F3 0F 11 B3 C0 98 00 00     movss   dword ptr [rbx+98C0h], xmm6
0000000180375FB4  F3 0F 59 B3 40 99 00 00     mulss   xmm6, dword ptr [rbx+9940h]
0000000180375FBC  F3 0F 58 B3 E0 98 00 00     addss   xmm6, dword ptr [rbx+98E0h]
0000000180375FC4  E8 97 2D FF FF              call    sub_180368D60
0000000180375FC9  F3 0F 11 83 B0 98 00 00     movss   dword ptr [rbx+98B0h], xmm0
0000000180375FD1  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180375FD5  F3 0F 59 8B A0 99 00 00     mulss   xmm1, dword ptr [rbx+99A0h]
0000000180375FDD  41 0F 28 D5                 movaps  xmm2, xmm13
0000000180375FE1  F3 41 0F 5C D0              subss   xmm2, xmm8
0000000180375FE6  F3 0F 58 8B F0 98 00 00     addss   xmm1, dword ptr [rbx+98F0h]
0000000180375FEE  F3 0F 59 93 60 99 00 00     mulss   xmm2, dword ptr [rbx+9960h]
0000000180375FF6  F3 0F 11 8B A0 98 00 00     movss   dword ptr [rbx+98A0h], xmm1
0000000180375FFE  F3 44 0F 59 8B 30 99 00 00  mulss   xmm9, dword ptr [rbx+9930h]
0000000180376007  F3 0F 59 BB 10 99 00 00     mulss   xmm7, dword ptr [rbx+9910h]
000000018037600F  F3 0F 10 83 70 99 00 00     movss   xmm0, dword ptr [rbx+9970h]
0000000180376017  F3 0F 5D C2                 minss   xmm0, xmm2
000000018037601B  F3 44 0F 58 CF              addss   xmm9, xmm7
0000000180376020  F3 44 0F 58 CE              addss   xmm9, xmm6
0000000180376025  F3 44 0F 58 C8              addss   xmm9, xmm0
000000018037602A  F3 44 0F 58 8B 20 99 00 00  addss   xmm9, dword ptr [rbx+9920h]
0000000180376033  F3 44 0F 5D 8B 80 99 00 00  minss   xmm9, dword ptr [rbx+9980h]
000000018037603C  F3 44 0F 5F 8B 90 99 00 00  maxss   xmm9, dword ptr [rbx+9990h]
0000000180376045  F3 44 0F 59 8B C0 99 00 00  mulss   xmm9, dword ptr [rbx+99C0h]
000000018037604E  F3 44 0F 58 8B D0 99 00 00  addss   xmm9, dword ptr [rbx+99D0h]
0000000180376057  41 0F 28 C9                 movaps  xmm1, xmm9
000000018037605B  F3 0F 2C C9                 cvttss2si ecx, xmm1
000000018037605F  81 F9 00 00 00 80           cmp     ecx, 80000000h
0000000180376065  74 1E                       jz      short loc_180376085
0000000180376067  66 0F 6E C1                 movd    xmm0, ecx
000000018037606B  0F 5B C0                    cvtdq2ps xmm0, xmm0
000000018037606E  0F 2E C1                    ucomiss xmm0, xmm1
0000000180376071  74 12                       jz      short loc_180376085
0000000180376073  0F 14 C9                    unpcklps xmm1, xmm1
0000000180376076  0F 50 C1                    movmskps eax, xmm1
0000000180376079  83 E0 01                    and     eax, 1
000000018037607C  2B C8                       sub     ecx, eax
000000018037607E  66 0F 6E C9                 movd    xmm1, ecx
0000000180376082  0F 5B C9                    cvtdq2ps xmm1, xmm1
0000000180376085  F3 44 0F 5C C9              subss   xmm9, xmm1
000000018037608A  0F 28 C1                    movaps  xmm0, xmm1; X
000000018037608D  41 0F 28 F1                 movaps  xmm6, xmm9
0000000180376091  F3 41 0F 59 F1              mulss   xmm6, xmm9
0000000180376096  F3 0F 59 35 32 EF 76 00     mulss   xmm6, cs:dword_180AE4FD0
000000018037609E  E8 9D 96 37 00              call    expf
00000001803760A3  0F 28 E0                    movaps  xmm4, xmm0
00000001803760A6  41 0F 28 D1                 movaps  xmm2, xmm9
00000001803760AA  F3 0F 59 93 90 9A 00 00     mulss   xmm2, dword ptr [rbx+9A90h]
00000001803760B2  41 0F 28 C9                 movaps  xmm1, xmm9
00000001803760B6  F3 0F 59 8B 70 9A 00 00     mulss   xmm1, dword ptr [rbx+9A70h]
00000001803760BE  41 0F 28 C1                 movaps  xmm0, xmm9
00000001803760C2  F3 0F 58 93 80 9A 00 00     addss   xmm2, dword ptr [rbx+9A80h]
00000001803760CA  F3 0F 59 83 50 9A 00 00     mulss   xmm0, dword ptr [rbx+9A50h]
00000001803760D2  F3 0F 59 D6                 mulss   xmm2, xmm6
00000001803760D6  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803760DA  F3 0F 58 93 60 9A 00 00     addss   xmm2, dword ptr [rbx+9A60h]
00000001803760E2  F3 0F 59 D6                 mulss   xmm2, xmm6
00000001803760E6  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803760EA  41 0F 28 C1                 movaps  xmm0, xmm9
00000001803760EE  F3 0F 59 83 30 9A 00 00     mulss   xmm0, dword ptr [rbx+9A30h]
00000001803760F6  F3 0F 58 93 40 9A 00 00     addss   xmm2, dword ptr [rbx+9A40h]
00000001803760FE  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180376102  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180376106  41 0F 28 C1                 movaps  xmm0, xmm9
000000018037610A  F3 0F 59 83 10 9A 00 00     mulss   xmm0, dword ptr [rbx+9A10h]
0000000180376112  F3 44 0F 59 8B F0 99 00 00  mulss   xmm9, dword ptr [rbx+99F0h]
000000018037611B  F3 0F 58 93 20 9A 00 00     addss   xmm2, dword ptr [rbx+9A20h]
0000000180376123  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180376127  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037612B  F3 0F 58 93 00 9A 00 00     addss   xmm2, dword ptr [rbx+9A00h]
0000000180376133  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180376137  F3 41 0F 58 D1              addss   xmm2, xmm9
000000018037613C  F3 41 0F 58 D5              addss   xmm2, xmm13
0000000180376141  F3 0F 59 E2                 mulss   xmm4, xmm2
0000000180376145  F3 0F 59 A3 E0 99 00 00     mulss   xmm4, dword ptr [rbx+99E0h]
000000018037614D  0F 28 DC                    movaps  xmm3, xmm4
0000000180376150  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180376154  0F 28 CB                    movaps  xmm1, xmm3
0000000180376157  44 0F 28 C3                 movaps  xmm8, xmm3
000000018037615B  F3 44 0F 59 83 30 9B 00 00  mulss   xmm8, dword ptr [rbx+9B30h]
0000000180376164  0F 28 C3                    movaps  xmm0, xmm3
0000000180376167  F3 0F 59 83 F0 9A 00 00     mulss   xmm0, dword ptr [rbx+9AF0h]
000000018037616F  0F 28 D3                    movaps  xmm2, xmm3
0000000180376172  F3 44 0F 58 83 10 9B 00 00  addss   xmm8, dword ptr [rbx+9B10h]
000000018037617B  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037617F  F3 0F 58 83 D0 9A 00 00     addss   xmm0, dword ptr [rbx+9AD0h]
0000000180376187  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037618B  F3 44 0F 59 C2              mulss   xmm8, xmm2
0000000180376190  F3 44 0F 58 C0              addss   xmm8, xmm0
0000000180376195  0F 28 C1                    movaps  xmm0, xmm1
0000000180376198  F3 0F 59 8B B0 9A 00 00     mulss   xmm1, dword ptr [rbx+9AB0h]
00000001803761A0  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803761A4  F3 44 0F 59 C0              mulss   xmm8, xmm0
00000001803761A9  0F 28 C3                    movaps  xmm0, xmm3
00000001803761AC  F3 0F 59 83 E0 9A 00 00     mulss   xmm0, dword ptr [rbx+9AE0h]
00000001803761B4  F3 44 0F 58 C1              addss   xmm8, xmm1
00000001803761B9  0F 28 CB                    movaps  xmm1, xmm3
00000001803761BC  F3 0F 59 8B 20 9B 00 00     mulss   xmm1, dword ptr [rbx+9B20h]
00000001803761C4  F3 0F 59 9B A0 9A 00 00     mulss   xmm3, dword ptr [rbx+9AA0h]
00000001803761CC  F3 0F 58 8B 00 9B 00 00     addss   xmm1, dword ptr [rbx+9B00h]
00000001803761D4  F3 44 0F 58 C4              addss   xmm8, xmm4
00000001803761D9  F3 0F 59 CA                 mulss   xmm1, xmm2
00000001803761DD  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803761E1  F3 0F 58 8B C0 9A 00 00     addss   xmm1, dword ptr [rbx+9AC0h]
00000001803761E9  F3 0F 59 CA                 mulss   xmm1, xmm2
00000001803761ED  F3 0F 58 CB                 addss   xmm1, xmm3
00000001803761F1  F3 41 0F 58 CD              addss   xmm1, xmm13
00000001803761F6  F3 44 0F 5E C1              divss   xmm8, xmm1
00000001803761FB  41 0F 28 C0                 movaps  xmm0, xmm8
00000001803761FF  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180376204  F3 44 0F 5E C0              divss   xmm8, xmm0
0000000180376209  F3 44 0F 11 83 90 98 00 00  movss   dword ptr [rbx+9890h], xmm8
0000000180376212  EB 09                       jmp     short loc_18037621D
0000000180376214  F3 44 0F 10 83 90 98 00 00  movss   xmm8, dword ptr [rbx+9890h]
000000018037621D  8B 83 A0 9B 00 00           mov     eax, [rbx+9BA0h]
0000000180376223  F3 0F 10 8B C0 94 00 00     movss   xmm1, dword ptr [rbx+94C0h]
000000018037622B  F3 44 0F 10 8B A0 98 00 00  movss   xmm9, dword ptr [rbx+98A0h]
0000000180376234  89 83 B0 9B 00 00           mov     [rbx+9BB0h], eax
000000018037623A  8B 83 90 9B 00 00           mov     eax, [rbx+9B90h]
0000000180376240  89 83 A0 9B 00 00           mov     [rbx+9BA0h], eax
0000000180376246  8B 83 80 9B 00 00           mov     eax, [rbx+9B80h]
000000018037624C  89 83 90 9B 00 00           mov     [rbx+9B90h], eax
0000000180376252  8B 83 70 9B 00 00           mov     eax, [rbx+9B70h]
0000000180376258  89 83 80 9B 00 00           mov     [rbx+9B80h], eax
000000018037625E  8B 83 60 9B 00 00           mov     eax, [rbx+9B60h]
0000000180376264  89 83 70 9B 00 00           mov     [rbx+9B70h], eax
000000018037626A  8B 83 50 9B 00 00           mov     eax, [rbx+9B50h]
0000000180376270  89 83 60 9B 00 00           mov     [rbx+9B60h], eax
0000000180376276  8B 83 40 9B 00 00           mov     eax, [rbx+9B40h]
000000018037627C  89 83 50 9B 00 00           mov     [rbx+9B50h], eax
0000000180376282  8B 83 80 9C 00 00           mov     eax, [rbx+9C80h]
0000000180376288  89 83 90 9C 00 00           mov     [rbx+9C90h], eax
000000018037628E  8B 83 70 9C 00 00           mov     eax, [rbx+9C70h]
0000000180376294  89 83 80 9C 00 00           mov     [rbx+9C80h], eax
000000018037629A  8B 83 60 9C 00 00           mov     eax, [rbx+9C60h]
00000001803762A0  89 83 70 9C 00 00           mov     [rbx+9C70h], eax
00000001803762A6  8B 83 50 9C 00 00           mov     eax, [rbx+9C50h]
00000001803762AC  89 83 60 9C 00 00           mov     [rbx+9C60h], eax
00000001803762B2  8B 83 40 9C 00 00           mov     eax, [rbx+9C40h]
00000001803762B8  89 83 50 9C 00 00           mov     [rbx+9C50h], eax
00000001803762BE  8B 83 30 9C 00 00           mov     eax, [rbx+9C30h]
00000001803762C4  89 83 40 9C 00 00           mov     [rbx+9C40h], eax
00000001803762CA  8B 83 20 9C 00 00           mov     eax, [rbx+9C20h]
00000001803762D0  89 83 30 9C 00 00           mov     [rbx+9C30h], eax
00000001803762D6  8B 83 00 9D 00 00           mov     eax, [rbx+9D00h]
00000001803762DC  89 83 10 9D 00 00           mov     [rbx+9D10h], eax
00000001803762E2  8B 83 F0 9C 00 00           mov     eax, [rbx+9CF0h]
00000001803762E8  89 83 00 9D 00 00           mov     [rbx+9D00h], eax
00000001803762EE  8B 83 E0 9C 00 00           mov     eax, [rbx+9CE0h]
00000001803762F4  89 83 F0 9C 00 00           mov     [rbx+9CF0h], eax
00000001803762FA  8B 83 D0 9C 00 00           mov     eax, [rbx+9CD0h]
0000000180376300  89 83 E0 9C 00 00           mov     [rbx+9CE0h], eax
0000000180376306  8B 83 C0 9C 00 00           mov     eax, [rbx+9CC0h]
000000018037630C  89 83 D0 9C 00 00           mov     [rbx+9CD0h], eax
0000000180376312  8B 83 B0 9C 00 00           mov     eax, [rbx+9CB0h]
0000000180376318  89 83 C0 9C 00 00           mov     [rbx+9CC0h], eax
000000018037631E  8B 83 A0 9C 00 00           mov     eax, [rbx+9CA0h]
0000000180376324  89 83 B0 9C 00 00           mov     [rbx+9CB0h], eax
000000018037632A  8B 83 80 9D 00 00           mov     eax, [rbx+9D80h]
0000000180376330  89 83 90 9D 00 00           mov     [rbx+9D90h], eax
0000000180376336  8B 83 70 9D 00 00           mov     eax, [rbx+9D70h]
000000018037633C  89 83 80 9D 00 00           mov     [rbx+9D80h], eax
0000000180376342  8B 83 60 9D 00 00           mov     eax, [rbx+9D60h]
0000000180376348  89 83 70 9D 00 00           mov     [rbx+9D70h], eax
000000018037634E  8B 83 50 9D 00 00           mov     eax, [rbx+9D50h]
0000000180376354  89 83 60 9D 00 00           mov     [rbx+9D60h], eax
000000018037635A  8B 83 40 9D 00 00           mov     eax, [rbx+9D40h]
0000000180376360  89 83 50 9D 00 00           mov     [rbx+9D50h], eax
0000000180376366  8B 83 30 9D 00 00           mov     eax, [rbx+9D30h]
000000018037636C  89 83 40 9D 00 00           mov     [rbx+9D40h], eax
0000000180376372  8B 83 20 9D 00 00           mov     eax, [rbx+9D20h]
0000000180376378  89 83 30 9D 00 00           mov     [rbx+9D30h], eax
000000018037637E  8B 83 00 9E 00 00           mov     eax, [rbx+9E00h]
0000000180376384  89 83 10 9E 00 00           mov     [rbx+9E10h], eax
000000018037638A  8B 83 F0 9D 00 00           mov     eax, [rbx+9DF0h]
0000000180376390  89 83 00 9E 00 00           mov     [rbx+9E00h], eax
0000000180376396  8B 83 E0 9D 00 00           mov     eax, [rbx+9DE0h]
000000018037639C  89 83 F0 9D 00 00           mov     [rbx+9DF0h], eax
00000001803763A2  8B 83 D0 9D 00 00           mov     eax, [rbx+9DD0h]
00000001803763A8  89 83 E0 9D 00 00           mov     [rbx+9DE0h], eax
00000001803763AE  8B 83 C0 9D 00 00           mov     eax, [rbx+9DC0h]
00000001803763B4  89 83 D0 9D 00 00           mov     [rbx+9DD0h], eax
00000001803763BA  8B 83 B0 9D 00 00           mov     eax, [rbx+9DB0h]
00000001803763C0  89 83 C0 9D 00 00           mov     [rbx+9DC0h], eax
00000001803763C6  8B 83 A0 9D 00 00           mov     eax, [rbx+9DA0h]
00000001803763CC  89 83 B0 9D 00 00           mov     [rbx+9DB0h], eax
00000001803763D2  8B 83 20 9E 00 00           mov     eax, [rbx+9E20h]
00000001803763D8  89 83 30 9E 00 00           mov     [rbx+9E30h], eax
00000001803763DE  F3 0F 10 83 40 9E 00 00     movss   xmm0, dword ptr [rbx+9E40h]
00000001803763E6  F3 0F 11 83 50 9E 00 00     movss   dword ptr [rbx+9E50h], xmm0
00000001803763EE  44 0F 2E AB 90 9E 00 00     ucomiss xmm13, dword ptr [rbx+9E90h]
00000001803763F6  0F 85 49 09 00 00           jnz     loc_180376D45
00000001803763FC  F3 0F 59 8B E0 9E 00 00     mulss   xmm1, dword ptr [rbx+9EE0h]
0000000180376404  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180376408  41 0F 28 F1                 movaps  xmm6, xmm9
000000018037640C  41 0F 28 F8                 movaps  xmm7, xmm8
0000000180376410  F3 0F 59 B3 00 9F 00 00     mulss   xmm6, dword ptr [rbx+9F00h]
0000000180376418  F3 41 0F 59 F8              mulss   xmm7, xmm8
000000018037641D  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180376422  F3 0F 59 F1                 mulss   xmm6, xmm1
0000000180376426  0F 28 C8                    movaps  xmm1, xmm0
0000000180376429  F3 0F 59 8B D0 9E 00 00     mulss   xmm1, dword ptr [rbx+9ED0h]
0000000180376431  F3 0F 58 F1                 addss   xmm6, xmm1
0000000180376435  E8 26 29 FF FF              call    sub_180368D60
000000018037643A  F3 0F 11 83 40 9E 00 00     movss   dword ptr [rbx+9E40h], xmm0
0000000180376442  41 0F 28 DD                 movaps  xmm3, xmm13
0000000180376446  F3 0F 11 B3 20 9E 00 00     movss   dword ptr [rbx+9E20h], xmm6
000000018037644E  41 0F 28 C0                 movaps  xmm0, xmm8
0000000180376452  F3 0F 59 FF                 mulss   xmm7, xmm7
0000000180376456  F3 41 0F 58 C0              addss   xmm0, xmm8
000000018037645B  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037645F  F3 41 0F 59 F9              mulss   xmm7, xmm9
0000000180376464  F3 0F 5C F0                 subss   xmm6, xmm0
0000000180376468  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037646D  F3 0F 5E DF                 divss   xmm3, xmm7
0000000180376471  F3 0F 11 9B 70 9E 00 00     movss   dword ptr [rbx+9E70h], xmm3
0000000180376479  0F 28 E3                    movaps  xmm4, xmm3
000000018037647C  F3 0F 10 8B 20 9E 00 00     movss   xmm1, dword ptr [rbx+9E20h]
0000000180376484  F3 0F 10 AB 30 9E 00 00     movss   xmm5, dword ptr [rbx+9E30h]
000000018037648C  F3 41 0F 59 E1              mulss   xmm4, xmm9
0000000180376491  F3 0F 11 A3 60 9E 00 00     movss   dword ptr [rbx+9E60h], xmm4
0000000180376499  F3 0F 59 AB 30 9F 00 00     mulss   xmm5, dword ptr [rbx+9F30h]
00000001803764A1  F3 0F 10 93 A0 9B 00 00     movss   xmm2, dword ptr [rbx+9BA0h]
00000001803764A9  F3 0F 59 8B 40 9F 00 00     mulss   xmm1, dword ptr [rbx+9F40h]
00000001803764B1  F3 0F 10 83 B0 9B 00 00     movss   xmm0, dword ptr [rbx+9BB0h]
00000001803764B9  F3 0F 11 93 10 9C 00 00     movss   dword ptr [rbx+9C10h], xmm2
00000001803764C1  F3 0F 59 93 60 A0 00 00     mulss   xmm2, dword ptr [rbx+0A060h]
00000001803764C9  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803764CD  F3 0F 59 83 70 A0 00 00     mulss   xmm0, dword ptr [rbx+0A070h]
00000001803764D5  F3 0F 59 EB                 mulss   xmm5, xmm3
00000001803764D9  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803764DD  F3 0F 59 D4                 mulss   xmm2, xmm4
00000001803764E1  F3 0F 5C EA                 subss   xmm5, xmm2
00000001803764E5  41 0F 2F EF                 comiss  xmm5, xmm15
00000001803764E9  73 06                       jnb     short loc_1803764F1
00000001803764EB  41 0F 28 EF                 movaps  xmm5, xmm15
00000001803764EF  EB 05                       jmp     short loc_1803764F6
00000001803764F1  F3 41 0F 5D ED              minss   xmm5, xmm13
00000001803764F6  0F 28 CD                    movaps  xmm1, xmm5
00000001803764F9  0F 28 C5                    movaps  xmm0, xmm5
00000001803764FC  F3 0F 59 83 10 9F 00 00     mulss   xmm0, dword ptr [rbx+9F10h]
0000000180376504  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180376508  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037650C  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180376510  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180376514  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180376518  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037651C  F3 0F 11 AB C0 9B 00 00     movss   dword ptr [rbx+9BC0h], xmm5
0000000180376524  0F 28 D5                    movaps  xmm2, xmm5
0000000180376527  F3 0F 58 AB 50 9B 00 00     addss   xmm5, dword ptr [rbx+9B50h]
000000018037652F  F3 0F 10 9B 60 9B 00 00     movss   xmm3, dword ptr [rbx+9B60h]
0000000180376537  0F 28 C3                    movaps  xmm0, xmm3
000000018037653A  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037653E  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180376542  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180376546  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018037654A  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037654E  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376552  0F 28 C6                    movaps  xmm0, xmm6
0000000180376555  F3 0F 11 A3 D0 9B 00 00     movss   dword ptr [rbx+9BD0h], xmm4
000000018037655D  F3 0F 10 8B 70 9B 00 00     movss   xmm1, dword ptr [rbx+9B70h]
0000000180376565  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180376569  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037656D  0F 28 C1                    movaps  xmm0, xmm1
0000000180376570  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180376574  F3 0F 58 EC                 addss   xmm5, xmm4
0000000180376578  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037657C  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180376580  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180376584  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180376588  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037658C  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180376590  0F 28 C6                    movaps  xmm0, xmm6
0000000180376593  F3 0F 11 9B E0 9B 00 00     movss   dword ptr [rbx+9BE0h], xmm3
000000018037659B  F3 0F 10 AB 80 9B 00 00     movss   xmm5, dword ptr [rbx+9B80h]
00000001803765A3  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803765A7  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803765AB  0F 28 C5                    movaps  xmm0, xmm5
00000001803765AE  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803765B2  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803765B6  F3 0F 58 D9                 addss   xmm3, xmm1
00000001803765BA  41 0F 28 C8                 movaps  xmm1, xmm8
00000001803765BE  F3 0F 59 CC                 mulss   xmm1, xmm4
00000001803765C2  41 0F 28 E0                 movaps  xmm4, xmm8
00000001803765C6  F3 0F 59 D3                 mulss   xmm2, xmm3
00000001803765CA  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803765CE  0F 28 C6                    movaps  xmm0, xmm6
00000001803765D1  F3 0F 11 93 F0 9B 00 00     movss   dword ptr [rbx+9BF0h], xmm2
00000001803765D9  F3 0F 58 EA                 addss   xmm5, xmm2
00000001803765DD  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803765E1  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803765E5  F3 41 0F 59 E8              mulss   xmm5, xmm8
00000001803765EA  0F 28 C6                    movaps  xmm0, xmm6
00000001803765ED  F3 0F 59 83 90 9B 00 00     mulss   xmm0, dword ptr [rbx+9B90h]
00000001803765F5  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803765F9  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803765FD  0F 28 C6                    movaps  xmm0, xmm6
0000000180376600  F3 0F 59 E1                 mulss   xmm4, xmm1
0000000180376604  F3 0F 11 AB 00 9C 00 00     movss   dword ptr [rbx+9C00h], xmm5
000000018037660C  F3 0F 10 93 F0 9B 00 00     movss   xmm2, dword ptr [rbx+9BF0h]
0000000180376614  F3 0F 59 93 B0 9E 00 00     mulss   xmm2, dword ptr [rbx+9EB0h]
000000018037661C  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180376620  F3 0F 59 AB C0 9E 00 00     mulss   xmm5, dword ptr [rbx+9EC0h]
0000000180376628  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037662C  F3 0F 10 83 A0 9E 00 00     movss   xmm0, dword ptr [rbx+9EA0h]
0000000180376634  F3 0F 59 83 E0 9B 00 00     mulss   xmm0, dword ptr [rbx+9BE0h]
000000018037663C  F3 0F 58 D5                 addss   xmm2, xmm5
0000000180376640  F3 0F 10 AB 30 9E 00 00     movss   xmm5, dword ptr [rbx+9E30h]
0000000180376648  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037664C  F3 0F 11 93 A0 9D 00 00     movss   dword ptr [rbx+9DA0h], xmm2
0000000180376654  F3 0F 58 AB 20 9E 00 00     addss   xmm5, dword ptr [rbx+9E20h]
000000018037665C  F3 0F 10 83 10 9C 00 00     movss   xmm0, dword ptr [rbx+9C10h]
0000000180376664  F3 0F 59 AB 50 9F 00 00     mulss   xmm5, dword ptr [rbx+9F50h]
000000018037666C  F3 0F 59 AB 70 9E 00 00     mulss   xmm5, dword ptr [rbx+9E70h]
0000000180376674  F3 0F 11 A3 10 9C 00 00     movss   dword ptr [rbx+9C10h], xmm4
000000018037667C  F3 0F 59 A3 60 A0 00 00     mulss   xmm4, dword ptr [rbx+0A060h]
0000000180376684  F3 0F 59 83 70 A0 00 00     mulss   xmm0, dword ptr [rbx+0A070h]
000000018037668C  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376690  F3 0F 59 A3 60 9E 00 00     mulss   xmm4, dword ptr [rbx+9E60h]
0000000180376698  F3 0F 5C EC                 subss   xmm5, xmm4
000000018037669C  41 0F 2F EF                 comiss  xmm5, xmm15
00000001803766A0  73 06                       jnb     short loc_1803766A8
00000001803766A2  41 0F 28 EF                 movaps  xmm5, xmm15
00000001803766A6  EB 05                       jmp     short loc_1803766AD
00000001803766A8  F3 41 0F 5D ED              minss   xmm5, xmm13
00000001803766AD  0F 28 CD                    movaps  xmm1, xmm5
00000001803766B0  0F 28 C5                    movaps  xmm0, xmm5
00000001803766B3  F3 0F 59 83 10 9F 00 00     mulss   xmm0, dword ptr [rbx+9F10h]
00000001803766BB  41 0F 28 E0                 movaps  xmm4, xmm8
00000001803766BF  F3 0F 59 CD                 mulss   xmm1, xmm5
00000001803766C3  F3 0F 59 CD                 mulss   xmm1, xmm5
00000001803766C7  F3 0F 59 CD                 mulss   xmm1, xmm5
00000001803766CB  F3 0F 59 C8                 mulss   xmm1, xmm0
00000001803766CF  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803766D3  F3 0F 10 8B C0 9B 00 00     movss   xmm1, dword ptr [rbx+9BC0h]
00000001803766DB  F3 0F 11 AB C0 9B 00 00     movss   dword ptr [rbx+9BC0h], xmm5
00000001803766E3  0F 28 D5                    movaps  xmm2, xmm5
00000001803766E6  F3 0F 10 9B D0 9B 00 00     movss   xmm3, dword ptr [rbx+9BD0h]
00000001803766EE  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803766F2  0F 28 C3                    movaps  xmm0, xmm3
00000001803766F5  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803766F9  F3 0F 59 E5                 mulss   xmm4, xmm5
00000001803766FD  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180376701  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180376705  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180376709  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037670D  0F 28 C6                    movaps  xmm0, xmm6
0000000180376710  F3 0F 11 A3 D0 9B 00 00     movss   dword ptr [rbx+9BD0h], xmm4
0000000180376718  F3 0F 10 8B E0 9B 00 00     movss   xmm1, dword ptr [rbx+9BE0h]
0000000180376720  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180376724  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180376728  0F 28 C1                    movaps  xmm0, xmm1
000000018037672B  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037672F  F3 0F 58 EC                 addss   xmm5, xmm4
0000000180376733  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180376737  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037673B  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037673F  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180376743  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180376747  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037674B  0F 28 C6                    movaps  xmm0, xmm6
000000018037674E  F3 0F 11 9B E0 9B 00 00     movss   dword ptr [rbx+9BE0h], xmm3
0000000180376756  F3 0F 10 AB F0 9B 00 00     movss   xmm5, dword ptr [rbx+9BF0h]
000000018037675E  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180376762  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376766  0F 28 C5                    movaps  xmm0, xmm5
0000000180376769  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037676D  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180376771  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180376775  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180376779  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037677D  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180376781  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180376785  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180376789  0F 28 C6                    movaps  xmm0, xmm6
000000018037678C  F3 0F 11 93 F0 9B 00 00     movss   dword ptr [rbx+9BF0h], xmm2
0000000180376794  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180376798  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037679C  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803767A0  F3 41 0F 59 E8              mulss   xmm5, xmm8
00000001803767A5  0F 28 C6                    movaps  xmm0, xmm6
00000001803767A8  F3 0F 59 83 00 9C 00 00     mulss   xmm0, dword ptr [rbx+9C00h]
00000001803767B0  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803767B4  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803767B8  0F 28 C6                    movaps  xmm0, xmm6
00000001803767BB  F3 0F 59 E1                 mulss   xmm4, xmm1
00000001803767BF  F3 0F 11 AB 00 9C 00 00     movss   dword ptr [rbx+9C00h], xmm5
00000001803767C7  F3 0F 10 93 F0 9B 00 00     movss   xmm2, dword ptr [rbx+9BF0h]
00000001803767CF  F3 0F 59 93 B0 9E 00 00     mulss   xmm2, dword ptr [rbx+9EB0h]
00000001803767D7  F3 0F 10 8B 20 9E 00 00     movss   xmm1, dword ptr [rbx+9E20h]
00000001803767DF  F3 0F 59 C5                 mulss   xmm0, xmm5
00000001803767E3  F3 0F 59 AB C0 9E 00 00     mulss   xmm5, dword ptr [rbx+9EC0h]
00000001803767EB  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803767EF  F3 0F 10 83 A0 9E 00 00     movss   xmm0, dword ptr [rbx+9EA0h]
00000001803767F7  F3 0F 59 83 E0 9B 00 00     mulss   xmm0, dword ptr [rbx+9BE0h]
00000001803767FF  F3 0F 58 D5                 addss   xmm2, xmm5
0000000180376803  F3 0F 10 AB 30 9E 00 00     movss   xmm5, dword ptr [rbx+9E30h]
000000018037680B  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037680F  F3 0F 11 93 20 9D 00 00     movss   dword ptr [rbx+9D20h], xmm2
0000000180376817  F3 0F 59 AB 40 9F 00 00     mulss   xmm5, dword ptr [rbx+9F40h]
000000018037681F  F3 0F 59 8B 30 9F 00 00     mulss   xmm1, dword ptr [rbx+9F30h]
0000000180376827  F3 0F 10 83 10 9C 00 00     movss   xmm0, dword ptr [rbx+9C10h]
000000018037682F  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180376833  F3 0F 59 AB 70 9E 00 00     mulss   xmm5, dword ptr [rbx+9E70h]
000000018037683B  F3 0F 11 A3 10 9C 00 00     movss   dword ptr [rbx+9C10h], xmm4
0000000180376843  F3 0F 59 A3 60 A0 00 00     mulss   xmm4, dword ptr [rbx+0A060h]
000000018037684B  F3 0F 59 83 70 A0 00 00     mulss   xmm0, dword ptr [rbx+0A070h]
0000000180376853  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376857  F3 0F 59 A3 60 9E 00 00     mulss   xmm4, dword ptr [rbx+9E60h]
000000018037685F  F3 0F 5C EC                 subss   xmm5, xmm4
0000000180376863  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180376867  73 06                       jnb     short loc_18037686F
0000000180376869  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037686D  EB 05                       jmp     short loc_180376874
000000018037686F  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180376874  0F 28 CD                    movaps  xmm1, xmm5
0000000180376877  0F 28 C5                    movaps  xmm0, xmm5
000000018037687A  F3 0F 59 83 10 9F 00 00     mulss   xmm0, dword ptr [rbx+9F10h]
0000000180376882  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180376886  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037688A  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037688E  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180376892  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180376896  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037689A  F3 0F 10 8B C0 9B 00 00     movss   xmm1, dword ptr [rbx+9BC0h]
00000001803768A2  F3 0F 11 AB C0 9B 00 00     movss   dword ptr [rbx+9BC0h], xmm5
00000001803768AA  0F 28 D5                    movaps  xmm2, xmm5
00000001803768AD  F3 0F 10 9B D0 9B 00 00     movss   xmm3, dword ptr [rbx+9BD0h]
00000001803768B5  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803768B9  0F 28 C3                    movaps  xmm0, xmm3
00000001803768BC  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803768C0  F3 0F 59 E5                 mulss   xmm4, xmm5
00000001803768C4  41 0F 28 E8                 movaps  xmm5, xmm8
00000001803768C8  F3 0F 59 EA                 mulss   xmm5, xmm2
00000001803768CC  41 0F 28 D0                 movaps  xmm2, xmm8
00000001803768D0  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803768D4  0F 28 C6                    movaps  xmm0, xmm6
00000001803768D7  F3 0F 11 A3 D0 9B 00 00     movss   dword ptr [rbx+9BD0h], xmm4
00000001803768DF  F3 0F 10 8B E0 9B 00 00     movss   xmm1, dword ptr [rbx+9BE0h]
00000001803768E7  F3 0F 59 C4                 mulss   xmm0, xmm4
00000001803768EB  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803768EF  0F 28 C1                    movaps  xmm0, xmm1
00000001803768F2  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803768F6  F3 0F 58 EC                 addss   xmm5, xmm4
00000001803768FA  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803768FE  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180376902  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180376906  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037690A  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037690E  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180376912  0F 28 C6                    movaps  xmm0, xmm6
0000000180376915  F3 0F 11 9B E0 9B 00 00     movss   dword ptr [rbx+9BE0h], xmm3
000000018037691D  F3 0F 10 AB F0 9B 00 00     movss   xmm5, dword ptr [rbx+9BF0h]
0000000180376925  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180376929  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037692D  0F 28 C5                    movaps  xmm0, xmm5
0000000180376930  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180376934  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180376938  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037693C  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180376940  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180376944  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180376948  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037694C  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180376950  0F 28 C6                    movaps  xmm0, xmm6
0000000180376953  F3 0F 11 93 F0 9B 00 00     movss   dword ptr [rbx+9BF0h], xmm2
000000018037695B  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037695F  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180376963  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180376967  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018037696C  0F 28 C6                    movaps  xmm0, xmm6
000000018037696F  F3 0F 59 83 00 9C 00 00     mulss   xmm0, dword ptr [rbx+9C00h]
0000000180376977  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037697B  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037697F  0F 28 C6                    movaps  xmm0, xmm6
0000000180376982  F3 0F 59 D9                 mulss   xmm3, xmm1
0000000180376986  F3 0F 11 AB 00 9C 00 00     movss   dword ptr [rbx+9C00h], xmm5
000000018037698E  F3 0F 10 8B F0 9B 00 00     movss   xmm1, dword ptr [rbx+9BF0h]
0000000180376996  F3 0F 59 8B B0 9E 00 00     mulss   xmm1, dword ptr [rbx+9EB0h]
000000018037699E  F3 0F 59 C5                 mulss   xmm0, xmm5
00000001803769A2  F3 0F 59 AB C0 9E 00 00     mulss   xmm5, dword ptr [rbx+9EC0h]
00000001803769AA  F3 0F 58 D8                 addss   xmm3, xmm0
00000001803769AE  F3 0F 10 83 A0 9E 00 00     movss   xmm0, dword ptr [rbx+9EA0h]
00000001803769B6  F3 0F 59 83 E0 9B 00 00     mulss   xmm0, dword ptr [rbx+9BE0h]
00000001803769BE  F3 0F 58 CD                 addss   xmm1, xmm5
00000001803769C2  F3 0F 10 AB 20 9E 00 00     movss   xmm5, dword ptr [rbx+9E20h]
00000001803769CA  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803769CE  F3 0F 11 8B A0 9C 00 00     movss   dword ptr [rbx+9CA0h], xmm1
00000001803769D6  F3 0F 59 AB 20 9F 00 00     mulss   xmm5, dword ptr [rbx+9F20h]
00000001803769DE  F3 0F 10 83 10 9C 00 00     movss   xmm0, dword ptr [rbx+9C10h]
00000001803769E6  F3 0F 59 AB 70 9E 00 00     mulss   xmm5, dword ptr [rbx+9E70h]
00000001803769EE  F3 0F 11 9B A0 9B 00 00     movss   dword ptr [rbx+9BA0h], xmm3
00000001803769F6  F3 0F 59 9B 60 A0 00 00     mulss   xmm3, dword ptr [rbx+0A060h]
00000001803769FE  F3 0F 59 83 70 A0 00 00     mulss   xmm0, dword ptr [rbx+0A070h]
0000000180376A06  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180376A0A  F3 0F 59 9B 60 9E 00 00     mulss   xmm3, dword ptr [rbx+9E60h]
0000000180376A12  F3 0F 5C EB                 subss   xmm5, xmm3
0000000180376A16  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180376A1A  73 06                       jnb     short loc_180376A22
0000000180376A1C  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180376A20  EB 05                       jmp     short loc_180376A27
0000000180376A22  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180376A27  0F 28 CD                    movaps  xmm1, xmm5
0000000180376A2A  0F 28 C5                    movaps  xmm0, xmm5
0000000180376A2D  F3 0F 59 83 10 9F 00 00     mulss   xmm0, dword ptr [rbx+9F10h]
0000000180376A35  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180376A39  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180376A3D  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180376A41  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180376A45  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180376A49  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180376A4D  F3 0F 11 AB 40 9B 00 00     movss   dword ptr [rbx+9B40h], xmm5
0000000180376A55  0F 28 D5                    movaps  xmm2, xmm5
0000000180376A58  F3 0F 58 AB C0 9B 00 00     addss   xmm5, dword ptr [rbx+9BC0h]
0000000180376A60  F3 0F 10 9B D0 9B 00 00     movss   xmm3, dword ptr [rbx+9BD0h]
0000000180376A68  0F 28 C3                    movaps  xmm0, xmm3
0000000180376A6B  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180376A6F  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180376A73  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180376A77  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180376A7B  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180376A7F  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376A83  0F 28 C6                    movaps  xmm0, xmm6
0000000180376A86  F3 0F 11 A3 50 9B 00 00     movss   dword ptr [rbx+9B50h], xmm4
0000000180376A8E  F3 0F 10 8B E0 9B 00 00     movss   xmm1, dword ptr [rbx+9BE0h]
0000000180376A96  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180376A9A  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180376A9E  0F 28 C1                    movaps  xmm0, xmm1
0000000180376AA1  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180376AA5  F3 0F 58 EC                 addss   xmm5, xmm4
0000000180376AA9  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180376AAD  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180376AB1  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180376AB5  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180376AB9  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180376ABD  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180376AC1  0F 28 C6                    movaps  xmm0, xmm6
0000000180376AC4  F3 0F 11 9B 60 9B 00 00     movss   dword ptr [rbx+9B60h], xmm3
0000000180376ACC  F3 0F 10 AB F0 9B 00 00     movss   xmm5, dword ptr [rbx+9BF0h]
0000000180376AD4  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180376AD8  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376ADC  0F 28 C5                    movaps  xmm0, xmm5
0000000180376ADF  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180376AE3  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180376AE7  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180376AEB  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180376AEF  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180376AF3  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180376AF7  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180376AFB  0F 28 C6                    movaps  xmm0, xmm6
0000000180376AFE  F3 0F 11 93 70 9B 00 00     movss   dword ptr [rbx+9B70h], xmm2
0000000180376B06  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180376B0A  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180376B0E  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180376B12  F3 41 0F 59 E8              mulss   xmm5, xmm8
0000000180376B17  0F 28 C6                    movaps  xmm0, xmm6
0000000180376B1A  F3 0F 59 83 00 9C 00 00     mulss   xmm0, dword ptr [rbx+9C00h]
0000000180376B22  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180376B26  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180376B2A  F3 44 0F 59 C1              mulss   xmm8, xmm1
0000000180376B2F  F3 0F 11 AB 80 9B 00 00     movss   dword ptr [rbx+9B80h], xmm5
0000000180376B37  F3 0F 10 9B 60 9B 00 00     movss   xmm3, dword ptr [rbx+9B60h]
0000000180376B3F  F3 0F 59 F5                 mulss   xmm6, xmm5
0000000180376B43  F3 44 0F 58 C6              addss   xmm8, xmm6
0000000180376B48  F3 44 0F 11 83 90 9B 00 00  movss   dword ptr [rbx+9B90h], xmm8
0000000180376B51  F3 0F 10 83 B0 9E 00 00     movss   xmm0, dword ptr [rbx+9EB0h]
0000000180376B59  F3 0F 59 83 70 9B 00 00     mulss   xmm0, dword ptr [rbx+9B70h]
0000000180376B61  F3 0F 59 AB C0 9E 00 00     mulss   xmm5, dword ptr [rbx+9EC0h]
0000000180376B69  F3 0F 59 9B A0 9E 00 00     mulss   xmm3, dword ptr [rbx+9EA0h]
0000000180376B71  F3 0F 10 A3 60 9C 00 00     movss   xmm4, dword ptr [rbx+9C60h]
0000000180376B79  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180376B7D  F3 0F 58 EB                 addss   xmm5, xmm3
0000000180376B81  F3 0F 11 AB 20 9C 00 00     movss   dword ptr [rbx+9C20h], xmm5
0000000180376B89  F3 0F 58 A3 D0 9D 00 00     addss   xmm4, dword ptr [rbx+9DD0h]
0000000180376B91  F3 0F 10 83 E0 9C 00 00     movss   xmm0, dword ptr [rbx+9CE0h]
0000000180376B99  F3 0F 58 83 50 9D 00 00     addss   xmm0, dword ptr [rbx+9D50h]
0000000180376BA1  F3 0F 10 8B 60 9D 00 00     movss   xmm1, dword ptr [rbx+9D60h]
0000000180376BA9  F3 0F 58 8B D0 9C 00 00     addss   xmm1, dword ptr [rbx+9CD0h]
0000000180376BB1  F3 0F 59 A3 50 A0 00 00     mulss   xmm4, dword ptr [rbx+0A050h]
0000000180376BB9  F3 0F 59 83 40 A0 00 00     mulss   xmm0, dword ptr [rbx+0A040h]
0000000180376BC1  F3 0F 59 8B 30 A0 00 00     mulss   xmm1, dword ptr [rbx+0A030h]
0000000180376BC9  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376BCD  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180376BD1  F3 0F 10 83 50 9C 00 00     movss   xmm0, dword ptr [rbx+9C50h]
0000000180376BD9  F3 0F 58 83 E0 9D 00 00     addss   xmm0, dword ptr [rbx+9DE0h]
0000000180376BE1  F3 0F 10 8B C0 9D 00 00     movss   xmm1, dword ptr [rbx+9DC0h]
0000000180376BE9  F3 0F 58 8B 70 9C 00 00     addss   xmm1, dword ptr [rbx+9C70h]
0000000180376BF1  F3 0F 58 AB 10 9E 00 00     addss   xmm5, dword ptr [rbx+9E10h]
0000000180376BF9  F3 0F 59 83 20 A0 00 00     mulss   xmm0, dword ptr [rbx+0A020h]
0000000180376C01  F3 0F 59 8B 10 A0 00 00     mulss   xmm1, dword ptr [rbx+0A010h]
0000000180376C09  F3 0F 59 AB 60 9F 00 00     mulss   xmm5, dword ptr [rbx+9F60h]
0000000180376C11  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376C15  F3 0F 10 83 40 9D 00 00     movss   xmm0, dword ptr [rbx+9D40h]
0000000180376C1D  F3 0F 58 83 F0 9C 00 00     addss   xmm0, dword ptr [rbx+9CF0h]
0000000180376C25  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180376C29  F3 0F 10 8B 70 9D 00 00     movss   xmm1, dword ptr [rbx+9D70h]
0000000180376C31  F3 0F 58 8B C0 9C 00 00     addss   xmm1, dword ptr [rbx+9CC0h]
0000000180376C39  F3 0F 59 83 00 A0 00 00     mulss   xmm0, dword ptr [rbx+0A000h]
0000000180376C41  F3 0F 59 8B F0 9F 00 00     mulss   xmm1, dword ptr [rbx+9FF0h]
0000000180376C49  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376C4D  F3 0F 10 83 F0 9D 00 00     movss   xmm0, dword ptr [rbx+9DF0h]
0000000180376C55  F3 0F 58 83 40 9C 00 00     addss   xmm0, dword ptr [rbx+9C40h]
0000000180376C5D  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180376C61  F3 0F 10 8B B0 9D 00 00     movss   xmm1, dword ptr [rbx+9DB0h]
0000000180376C69  F3 0F 59 83 E0 9F 00 00     mulss   xmm0, dword ptr [rbx+9FE0h]
0000000180376C71  F3 0F 58 8B 80 9C 00 00     addss   xmm1, dword ptr [rbx+9C80h]
0000000180376C79  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376C7D  F3 0F 10 83 30 9D 00 00     movss   xmm0, dword ptr [rbx+9D30h]
0000000180376C85  F3 0F 58 83 00 9D 00 00     addss   xmm0, dword ptr [rbx+9D00h]
0000000180376C8D  F3 0F 59 8B D0 9F 00 00     mulss   xmm1, dword ptr [rbx+9FD0h]
0000000180376C95  F3 0F 59 83 C0 9F 00 00     mulss   xmm0, dword ptr [rbx+9FC0h]
0000000180376C9D  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180376CA1  F3 0F 10 8B 80 9D 00 00     movss   xmm1, dword ptr [rbx+9D80h]
0000000180376CA9  F3 0F 58 8B B0 9C 00 00     addss   xmm1, dword ptr [rbx+9CB0h]
0000000180376CB1  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376CB5  F3 0F 10 83 00 9E 00 00     movss   xmm0, dword ptr [rbx+9E00h]
0000000180376CBD  F3 0F 59 8B B0 9F 00 00     mulss   xmm1, dword ptr [rbx+9FB0h]
0000000180376CC5  F3 0F 58 83 30 9C 00 00     addss   xmm0, dword ptr [rbx+9C30h]
0000000180376CCD  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180376CD1  F3 0F 10 8B A0 9D 00 00     movss   xmm1, dword ptr [rbx+9DA0h]
0000000180376CD9  F3 0F 58 8B 90 9C 00 00     addss   xmm1, dword ptr [rbx+9C90h]
0000000180376CE1  F3 0F 59 83 A0 9F 00 00     mulss   xmm0, dword ptr [rbx+9FA0h]
0000000180376CE9  F3 0F 59 8B 90 9F 00 00     mulss   xmm1, dword ptr [rbx+9F90h]
0000000180376CF1  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376CF5  F3 0F 10 83 20 9D 00 00     movss   xmm0, dword ptr [rbx+9D20h]
0000000180376CFD  F3 0F 58 83 10 9D 00 00     addss   xmm0, dword ptr [rbx+9D10h]
0000000180376D05  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180376D09  F3 0F 10 8B 90 9D 00 00     movss   xmm1, dword ptr [rbx+9D90h]
0000000180376D11  F3 0F 59 83 80 9F 00 00     mulss   xmm0, dword ptr [rbx+9F80h]
0000000180376D19  F3 0F 58 8B A0 9C 00 00     addss   xmm1, dword ptr [rbx+9CA0h]
0000000180376D21  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376D25  F3 0F 59 8B 70 9F 00 00     mulss   xmm1, dword ptr [rbx+9F70h]
0000000180376D2D  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180376D31  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180376D35  F3 0F 59 A3 F0 9E 00 00     mulss   xmm4, dword ptr [rbx+9EF0h]
0000000180376D3D  F3 0F 11 A3 80 9E 00 00     movss   dword ptr [rbx+9E80h], xmm4
0000000180376D45  8B 83 80 A0 00 00           mov     eax, [rbx+0A080h]
0000000180376D4B  89 83 90 A0 00 00           mov     [rbx+0A090h], eax
0000000180376D51  F3 0F 10 83 B0 A0 00 00     movss   xmm0, dword ptr [rbx+0A0B0h]
0000000180376D59  8B 83 A0 A0 00 00           mov     eax, [rbx+0A0A0h]
0000000180376D5F  89 83 D0 A0 00 00           mov     [rbx+0A0D0h], eax
0000000180376D65  F3 0F 11 83 E0 A0 00 00     movss   dword ptr [rbx+0A0E0h], xmm0
0000000180376D6D  8B 83 C0 A0 00 00           mov     eax, [rbx+0A0C0h]
0000000180376D73  89 83 F0 A0 00 00           mov     [rbx+0A0F0h], eax
0000000180376D79  F3 0F 10 93 00 A1 00 00     movss   xmm2, dword ptr [rbx+0A100h]
0000000180376D81  F3 0F 11 93 10 A1 00 00     movss   dword ptr [rbx+0A110h], xmm2
0000000180376D89  F3 0F 10 83 20 A1 00 00     movss   xmm0, dword ptr [rbx+0A120h]
0000000180376D91  F3 0F 11 83 30 A1 00 00     movss   dword ptr [rbx+0A130h], xmm0
0000000180376D99  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180376D9D  F3 0F 59 93 40 A1 00 00     mulss   xmm2, dword ptr [rbx+0A140h]
0000000180376DA5  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180376DA9  F3 0F 11 93 20 A1 00 00     movss   dword ptr [rbx+0A120h], xmm2
0000000180376DB1  F3 0F 10 83 E0 A0 00 00     movss   xmm0, dword ptr [rbx+0A0E0h]
0000000180376DB9  F3 0F 10 8B F0 A0 00 00     movss   xmm1, dword ptr [rbx+0A0F0h]
0000000180376DC1  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180376DC5  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180376DC9  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180376DCD  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180376DD1  F3 0F 11 93 50 A1 00 00     movss   dword ptr [rbx+0A150h], xmm2
0000000180376DD9  F3 0F 10 8B 60 A1 00 00     movss   xmm1, dword ptr [rbx+0A160h]
0000000180376DE1  F3 0F 11 8B 70 A1 00 00     movss   dword ptr [rbx+0A170h], xmm1
0000000180376DE9  F3 0F 10 83 80 A1 00 00     movss   xmm0, dword ptr [rbx+0A180h]
0000000180376DF1  0F 28 D8                    movaps  xmm3, xmm0
0000000180376DF4  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180376DF8  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180376DFC  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180376E00  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180376E04  41 0F 2F DE                 comiss  xmm3, xmm14
0000000180376E08  76 05                       jbe     short loc_180376E0F
0000000180376E0A  0F 5A C3                    cvtps2pd xmm0, xmm3
0000000180376E0D  EB 03                       jmp     short loc_180376E12
0000000180376E0F  0F 57 C0                    xorps   xmm0, xmm0
0000000180376E12  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180376E16  F3 0F 11 83 60 A1 00 00     movss   dword ptr [rbx+0A160h], xmm0
0000000180376E1E  F3 0F 10 8B 90 A1 00 00     movss   xmm1, dword ptr [rbx+0A190h]
0000000180376E26  F3 0F 11 8B A0 A1 00 00     movss   dword ptr [rbx+0A1A0h], xmm1
0000000180376E2E  F3 0F 10 93 B0 A1 00 00     movss   xmm2, dword ptr [rbx+0A1B0h]
0000000180376E36  F3 0F 11 93 C0 A1 00 00     movss   dword ptr [rbx+0A1C0h], xmm2
0000000180376E3E  F3 0F 10 83 D0 A1 00 00     movss   xmm0, dword ptr [rbx+0A1D0h]
0000000180376E46  0F 28 D8                    movaps  xmm3, xmm0
0000000180376E49  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180376E4D  F3 0F 59 D9                 mulss   xmm3, xmm1
0000000180376E51  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180376E55  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180376E59  41 0F 2F DE                 comiss  xmm3, xmm14
0000000180376E5D  76 05                       jbe     short loc_180376E64
0000000180376E5F  0F 5A C3                    cvtps2pd xmm0, xmm3
0000000180376E62  EB 03                       jmp     short loc_180376E67
0000000180376E64  0F 57 C0                    xorps   xmm0, xmm0
0000000180376E67  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180376E6B  F3 0F 11 83 B0 A1 00 00     movss   dword ptr [rbx+0A1B0h], xmm0
0000000180376E73  F3 0F 10 AB E0 A1 00 00     movss   xmm5, dword ptr [rbx+0A1E0h]
0000000180376E7B  F3 0F 10 B3 60 7D 00 00     movss   xmm6, dword ptr [rbx+7D60h]
0000000180376E83  0F 28 E5                    movaps  xmm4, xmm5
0000000180376E86  F3 0F 11 AB F0 A1 00 00     movss   dword ptr [rbx+0A1F0h], xmm5
0000000180376E8E  0F 28 C5                    movaps  xmm0, xmm5
0000000180376E91  F3 0F 59 A3 40 A2 00 00     mulss   xmm4, dword ptr [rbx+0A240h]
0000000180376E99  0F 28 DD                    movaps  xmm3, xmm5
0000000180376E9C  F3 0F 58 83 10 A2 00 00     addss   xmm0, dword ptr [rbx+0A210h]
0000000180376EA4  F3 0F 58 9B 30 A2 00 00     addss   xmm3, dword ptr [rbx+0A230h]
0000000180376EAC  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180376EB0  73 06                       jnb     short loc_180376EB8
0000000180376EB2  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180376EB6  EB 05                       jmp     short loc_180376EBD
0000000180376EB8  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180376EBD  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180376EC1  72 1B                       jb      short loc_180376EDE
0000000180376EC3  F3 0F 10 83 20 A2 00 00     movss   xmm0, dword ptr [rbx+0A220h]
0000000180376ECB  0F 28 D8                    movaps  xmm3, xmm0
0000000180376ECE  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180376ED2  F3 0F 59 DE                 mulss   xmm3, xmm6
0000000180376ED6  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180376EDA  F3 0F 58 DD                 addss   xmm3, xmm5
0000000180376EDE  41 0F 2E F6                 ucomiss xmm6, xmm14
0000000180376EE2  F3 0F 10 8B 60 A2 00 00     movss   xmm1, dword ptr [rbx+0A260h]
0000000180376EEA  0F 28 D4                    movaps  xmm2, xmm4
0000000180376EED  F3 0F 59 93 50 A2 00 00     mulss   xmm2, dword ptr [rbx+0A250h]
0000000180376EF5  0F 28 C1                    movaps  xmm0, xmm1
0000000180376EF8  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180376EFC  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180376F00  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180376F04  0F 28 C2                    movaps  xmm0, xmm2
0000000180376F07  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180376F0B  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180376F0F  F3 0F 5C C2                 subss   xmm0, xmm2
0000000180376F13  F3 0F 58 C5                 addss   xmm0, xmm5
0000000180376F17  74 03                       jz      short loc_180376F1C
0000000180376F19  0F 28 C3                    movaps  xmm0, xmm3
0000000180376F1C  F3 0F 11 83 00 A2 00 00     movss   dword ptr [rbx+0A200h], xmm0
0000000180376F24  F3 0F 11 83 E0 A1 00 00     movss   dword ptr [rbx+0A1E0h], xmm0
0000000180376F2C  F3 0F 10 BB 80 9E 00 00     movss   xmm7, dword ptr [rbx+9E80h]
0000000180376F34  F3 0F 10 B3 F0 85 00 00     movss   xmm6, dword ptr [rbx+85F0h]
0000000180376F3C  F3 0F 10 9B F0 95 00 00     movss   xmm3, dword ptr [rbx+95F0h]
0000000180376F44  F3 0F 10 83 D0 87 00 00     movss   xmm0, dword ptr [rbx+87D0h]
0000000180376F4C  F3 0F 10 8B 80 A0 00 00     movss   xmm1, dword ptr [rbx+0A080h]
0000000180376F54  8B 83 A0 A2 00 00           mov     eax, [rbx+0A2A0h]
0000000180376F5A  89 83 B0 A2 00 00           mov     [rbx+0A2B0h], eax
0000000180376F60  8B 83 C0 A2 00 00           mov     eax, [rbx+0A2C0h]
0000000180376F66  89 83 D0 A2 00 00           mov     [rbx+0A2D0h], eax
0000000180376F6C  F3 0F 11 83 70 A2 00 00     movss   dword ptr [rbx+0A270h], xmm0
0000000180376F74  F3 0F 11 8B 80 A2 00 00     movss   dword ptr [rbx+0A280h], xmm1
0000000180376F7C  F3 0F 59 9B 90 A3 00 00     mulss   xmm3, dword ptr [rbx+0A390h]
0000000180376F84  F3 0F 10 A3 B0 A2 00 00     movss   xmm4, dword ptr [rbx+0A2B0h]
0000000180376F8C  F3 0F 10 93 F0 A2 00 00     movss   xmm2, dword ptr [rbx+0A2F0h]
0000000180376F94  F3 0F 11 9B 90 A2 00 00     movss   dword ptr [rbx+0A290h], xmm3
0000000180376F9C  0F 28 DF                    movaps  xmm3, xmm7
0000000180376F9F  F3 0F 59 B3 00 A3 00 00     mulss   xmm6, dword ptr [rbx+0A300h]
0000000180376FA7  F3 0F 5C DC                 subss   xmm3, xmm4
0000000180376FAB  F3 0F 59 93 00 A2 00 00     mulss   xmm2, dword ptr [rbx+0A200h]
0000000180376FB3  F3 0F 10 8B 10 A3 00 00     movss   xmm1, dword ptr [rbx+0A310h]
0000000180376FBB  0F 28 C3                    movaps  xmm0, xmm3
0000000180376FBE  F3 0F 59 83 30 A3 00 00     mulss   xmm0, dword ptr [rbx+0A330h]
0000000180376FC6  F3 0F 58 F2                 addss   xmm6, xmm2
0000000180376FCA  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180376FCE  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180376FD2  F3 0F 11 A3 A0 A2 00 00     movss   dword ptr [rbx+0A2A0h], xmm4
0000000180376FDA  F3 0F 59 8B 70 A2 00 00     mulss   xmm1, dword ptr [rbx+0A270h]
0000000180376FE2  F3 0F 10 93 20 A3 00 00     movss   xmm2, dword ptr [rbx+0A320h]
0000000180376FEA  F3 0F 59 9B A0 A3 00 00     mulss   xmm3, dword ptr [rbx+0A3A0h]
0000000180376FF2  F3 0F 59 A3 B0 A3 00 00     mulss   xmm4, dword ptr [rbx+0A3B0h]
0000000180376FFA  F3 0F 58 F1                 addss   xmm6, xmm1
0000000180376FFE  0F 28 CA                    movaps  xmm1, xmm2
0000000180377001  F3 0F 59 8B 80 A2 00 00     mulss   xmm1, dword ptr [rbx+0A280h]
0000000180377009  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037700D  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180377011  F3 0F 5C CA                 subss   xmm1, xmm2
0000000180377015  F3 0F 58 CE                 addss   xmm1, xmm6
0000000180377019  F3 0F 10 B3 40 A3 00 00     movss   xmm6, dword ptr [rbx+0A340h]
0000000180377021  F3 0F 5C C6                 subss   xmm0, xmm6
0000000180377025  F3 0F 59 8B 70 A3 00 00     mulss   xmm1, dword ptr [rbx+0A370h]
000000018037702D  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180377031  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180377035  76 05                       jbe     short loc_18037703C
0000000180377037  0F 5A C1                    cvtps2pd xmm0, xmm1
000000018037703A  EB 03                       jmp     short loc_18037703F
000000018037703C  0F 57 C0                    xorps   xmm0, xmm0
000000018037703F  F3 0F 10 93 60 A3 00 00     movss   xmm2, dword ptr [rbx+0A360h]
0000000180377047  F3 0F 10 A3 50 A3 00 00     movss   xmm4, dword ptr [rbx+0A350h]
000000018037704F  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
0000000180377053  F3 0F 10 83 90 A2 00 00     movss   xmm0, dword ptr [rbx+0A290h]
000000018037705B  F3 0F 59 AB 80 A3 00 00     mulss   xmm5, dword ptr [rbx+0A380h]
0000000180377063  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180377068  F3 0F 59 F3                 mulss   xmm6, xmm3
000000018037706C  F3 0F 10 9B D0 A2 00 00     movss   xmm3, dword ptr [rbx+0A2D0h]
0000000180377074  F3 0F 58 F7                 addss   xmm6, xmm7
0000000180377078  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018037707C  F3 0F 10 83 C0 A3 00 00     movss   xmm0, dword ptr [rbx+0A3C0h]
0000000180377084  0F 28 C8                    movaps  xmm1, xmm0
0000000180377087  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037708B  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018037708F  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180377093  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180377097  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037709B  F3 0F 11 9B C0 A2 00 00     movss   dword ptr [rbx+0A2C0h], xmm3
00000001803770A3  F3 0F 59 E3                 mulss   xmm4, xmm3
00000001803770A7  F3 0F 58 E2                 addss   xmm4, xmm2
00000001803770AB  F3 0F 59 E5                 mulss   xmm4, xmm5
00000001803770AF  F3 0F 59 A3 D0 A3 00 00     mulss   xmm4, dword ptr [rbx+0A3D0h]
00000001803770B7  F3 0F 11 A3 E0 A2 00 00     movss   dword ptr [rbx+0A2E0h], xmm4
00000001803770BF  8B 83 F0 A3 00 00           mov     eax, [rbx+0A3F0h]
00000001803770C5  89 83 00 A4 00 00           mov     [rbx+0A400h], eax
00000001803770CB  8B 83 E0 A3 00 00           mov     eax, [rbx+0A3E0h]
00000001803770D1  89 83 F0 A3 00 00           mov     [rbx+0A3F0h], eax
00000001803770D7  F3 0F 10 83 00 A4 00 00     movss   xmm0, dword ptr [rbx+0A400h]
00000001803770DF  F3 0F 10 8B 10 A4 00 00     movss   xmm1, dword ptr [rbx+0A410h]
00000001803770E7  F3 0F 5C E0                 subss   xmm4, xmm0
00000001803770EB  F3 0F 11 A3 E0 A3 00 00     movss   dword ptr [rbx+0A3E0h], xmm4
00000001803770F3  F3 0F 59 CC                 mulss   xmm1, xmm4
00000001803770F7  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803770FB  F3 0F 11 8B F0 A3 00 00     movss   dword ptr [rbx+0A3F0h], xmm1
0000000180377103  F3 0F 10 93 E0 A3 00 00     movss   xmm2, dword ptr [rbx+0A3E0h]
000000018037710B  F3 0F 10 B3 D0 A0 00 00     movss   xmm6, dword ptr [rbx+0A0D0h]
0000000180377113  0F 28 C2                    movaps  xmm0, xmm2
0000000180377116  41 0F 2F F6                 comiss  xmm6, xmm14
000000018037711A  8B 83 40 A4 00 00           mov     eax, [rbx+0A440h]
0000000180377120  89 83 50 A4 00 00           mov     [rbx+0A450h], eax
0000000180377126  8B 83 30 A4 00 00           mov     eax, [rbx+0A430h]
000000018037712C  89 83 40 A4 00 00           mov     [rbx+0A440h], eax
0000000180377132  8B 83 20 A4 00 00           mov     eax, [rbx+0A420h]
0000000180377138  89 83 30 A4 00 00           mov     [rbx+0A430h], eax
000000018037713E  F3 0F 11 93 20 A4 00 00     movss   dword ptr [rbx+0A420h], xmm2
0000000180377146  F3 0F 59 83 70 A4 00 00     mulss   xmm0, dword ptr [rbx+0A470h]
000000018037714E  F3 0F 10 A3 30 A4 00 00     movss   xmm4, dword ptr [rbx+0A430h]
0000000180377156  F3 0F 10 8B 90 A4 00 00     movss   xmm1, dword ptr [rbx+0A490h]
000000018037715E  0F 28 EC                    movaps  xmm5, xmm4
0000000180377161  F3 0F 59 8B 40 A4 00 00     mulss   xmm1, dword ptr [rbx+0A440h]
0000000180377169  F3 0F 59 AB 80 A4 00 00     mulss   xmm5, dword ptr [rbx+0A480h]
0000000180377171  F3 0F 59 A3 B0 A4 00 00     mulss   xmm4, dword ptr [rbx+0A4B0h]
0000000180377179  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037717D  0F 28 C2                    movaps  xmm0, xmm2
0000000180377180  F3 0F 59 83 A0 A4 00 00     mulss   xmm0, dword ptr [rbx+0A4A0h]
0000000180377188  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037718C  F3 0F 10 8B C0 A4 00 00     movss   xmm1, dword ptr [rbx+0A4C0h]
0000000180377194  F3 0F 59 8B 50 A4 00 00     mulss   xmm1, dword ptr [rbx+0A450h]
000000018037719C  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803771A0  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803771A4  76 05                       jbe     short loc_1803771AB
00000001803771A6  0F 5A C6                    cvtps2pd xmm0, xmm6
00000001803771A9  EB 03                       jmp     short loc_1803771AE
00000001803771AB  0F 57 C0                    xorps   xmm0, xmm0
00000001803771AE  0F 2F 35 0B E3 76 00        comiss  xmm6, cs:dword_180AE54C0
00000001803771B5  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00000001803771B9  F3 0F 11 AB 30 A4 00 00     movss   dword ptr [rbx+0A430h], xmm5
00000001803771C1  0F 28 D8                    movaps  xmm3, xmm0
00000001803771C4  F3 0F 11 A3 40 A4 00 00     movss   dword ptr [rbx+0A440h], xmm4
00000001803771CC  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803771D0  F3 0F 59 DD                 mulss   xmm3, xmm5
00000001803771D4  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803771D8  0F 28 C6                    movaps  xmm0, xmm6
00000001803771DB  41 0F 57 C3                 xorps   xmm0, xmm11
00000001803771DF  F3 0F 58 DA                 addss   xmm3, xmm2
00000001803771E3  73 09                       jnb     short loc_1803771EE
00000001803771E5  45 0F 57 D2                 xorps   xmm10, xmm10
00000001803771E9  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
00000001803771EE  41 0F 2F F6                 comiss  xmm6, xmm14
00000001803771F2  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
00000001803771F7  0F 28 C8                    movaps  xmm1, xmm0
00000001803771FA  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803771FE  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180377202  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180377206  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037720A  72 03                       jb      short loc_18037720F
000000018037720C  0F 28 D3                    movaps  xmm2, xmm3
000000018037720F  F3 0F 11 93 60 A4 00 00     movss   dword ptr [rbx+0A460h], xmm2
0000000180377217  F3 0F 59 93 60 A1 00 00     mulss   xmm2, dword ptr [rbx+0A160h]
000000018037721F  F3 0F 11 93 D0 A4 00 00     movss   dword ptr [rbx+0A4D0h], xmm2
0000000180377227  F3 0F 59 93 B0 A1 00 00     mulss   xmm2, dword ptr [rbx+0A1B0h]
000000018037722F  F3 0F 11 93 E0 A4 00 00     movss   dword ptr [rbx+0A4E0h], xmm2
0000000180377237  F3 0F 10 83 90 8C 00 00     movss   xmm0, dword ptr [rbx+8C90h]
000000018037723F  F3 0F 58 83 F0 89 00 00     addss   xmm0, dword ptr [rbx+89F0h]
0000000180377247  44 0F 5A E0                 cvtps2pd xmm12, xmm0
000000018037724B  F2 44 0F 5F 25 54 3A 61 00  maxsd   xmm12, cs:qword_18098ACA8
0000000180377254  F2 44 0F 5D 25 33 3A 61 00  minsd   xmm12, cs:qword_18098AC90
000000018037725D  41 0F 28 CC                 movaps  xmm1, xmm12
0000000180377261  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180377265  F2 0F 58 05 FB DF 76 00     addsd   xmm0, cs:qword_180AE5268
000000018037726D  F2 41 0F 59 CC              mulsd   xmm1, xmm12
0000000180377272  41 0F 28 FC                 movaps  xmm7, xmm12
0000000180377276  F2 0F 2C C0                 cvttsd2si eax, xmm0
000000018037727A  0F 28 D1                    movaps  xmm2, xmm1
000000018037727D  48 63 C8                    movsxd  rcx, eax
0000000180377280  F2 41 0F 59 D4              mulsd   xmm2, xmm12
0000000180377285  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
000000018037728C  0F 28 DA                    movaps  xmm3, xmm2
000000018037728F  F2 41 0F 59 DC              mulsd   xmm3, xmm12
0000000180377294  48 8D 0D 45 22 61 00        lea     rcx, unk_1809894E0
000000018037729B  48 03 C1                    add     rax, rcx
000000018037729E  0F 28 E3                    movaps  xmm4, xmm3
00000001803772A1  F2 41 0F 59 E4              mulsd   xmm4, xmm12
00000001803772A6  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
00000001803772AB  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
00000001803772B0  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
00000001803772B5  0F 28 EC                    movaps  xmm5, xmm4
00000001803772B8  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
00000001803772BC  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
00000001803772C1  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
00000001803772C6  F2 0F 58 F9                 addsd   xmm7, xmm1
00000001803772CA  F2 41 0F 59 EC              mulsd   xmm5, xmm12
00000001803772CF  F2 0F 58 FA                 addsd   xmm7, xmm2
00000001803772D3  0F 28 F5                    movaps  xmm6, xmm5
00000001803772D6  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
00000001803772DB  F2 41 0F 59 F4              mulsd   xmm6, xmm12
00000001803772E0  F2 0F 58 FB                 addsd   xmm7, xmm3
00000001803772E4  44 0F 28 C6                 movaps  xmm8, xmm6
00000001803772E8  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
00000001803772ED  F2 0F 58 FC                 addsd   xmm7, xmm4
00000001803772F1  F2 45 0F 59 C4              mulsd   xmm8, xmm12
00000001803772F6  F2 0F 58 FD                 addsd   xmm7, xmm5
00000001803772FA  45 0F 28 C8                 movaps  xmm9, xmm8
00000001803772FE  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
0000000180377307  F2 45 0F 59 CC              mulsd   xmm9, xmm12
000000018037730C  F2 0F 58 FE                 addsd   xmm7, xmm6
0000000180377310  45 0F 28 D1                 movaps  xmm10, xmm9
0000000180377314  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
000000018037731D  F2 41 0F 58 F8              addsd   xmm7, xmm8
0000000180377322  F2 45 0F 59 D4              mulsd   xmm10, xmm12
0000000180377327  F2 41 0F 58 F9              addsd   xmm7, xmm9
000000018037732C  45 0F 28 DA                 movaps  xmm11, xmm10
0000000180377330  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
0000000180377339  F2 45 0F 59 DC              mulsd   xmm11, xmm12
000000018037733E  F2 41 0F 58 FA              addsd   xmm7, xmm10
0000000180377343  41 0F 28 C3                 movaps  xmm0, xmm11
0000000180377347  F2 45 0F 59 DC              mulsd   xmm11, xmm12
000000018037734C  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
0000000180377354  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
000000018037735D  F2 0F 58 F8                 addsd   xmm7, xmm0
0000000180377361  F2 41 0F 58 FB              addsd   xmm7, xmm11
0000000180377366  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
000000018037736A  F3 0F 5D 1D 26 39 61 00     minss   xmm3, cs:dword_18098AC98
0000000180377372  F3 0F 5F 1D 36 39 61 00     maxss   xmm3, cs:dword_18098ACB0
000000018037737A  F3 0F 59 9B 00 8A 00 00     mulss   xmm3, dword ptr [rbx+8A00h]
0000000180377382  F3 0F 11 9B 70 8C 00 00     movss   dword ptr [rbx+8C70h], xmm3
000000018037738A  8B 83 10 8E 00 00           mov     eax, [rbx+8E10h]
0000000180377390  F3 0F 10 AB F0 89 00 00     movss   xmm5, dword ptr [rbx+89F0h]
0000000180377398  F3 0F 10 83 C0 8B 00 00     movss   xmm0, dword ptr [rbx+8BC0h]
00000001803773A0  F3 0F 10 8B D0 8B 00 00     movss   xmm1, dword ptr [rbx+8BD0h]
00000001803773A8  F3 0F 10 93 E0 8B 00 00     movss   xmm2, dword ptr [rbx+8BE0h]
00000001803773B0  89 83 20 8E 00 00           mov     [rbx+8E20h], eax
00000001803773B6  8B 83 30 8E 00 00           mov     eax, [rbx+8E30h]
00000001803773BC  89 83 40 8E 00 00           mov     [rbx+8E40h], eax
00000001803773C2  8B 83 E0 8E 00 00           mov     eax, [rbx+8EE0h]
00000001803773C8  89 83 F0 8E 00 00           mov     [rbx+8EF0h], eax
00000001803773CE  8B 83 D0 8E 00 00           mov     eax, [rbx+8ED0h]
00000001803773D4  89 83 E0 8E 00 00           mov     [rbx+8EE0h], eax
00000001803773DA  8B 83 C0 8E 00 00           mov     eax, [rbx+8EC0h]
00000001803773E0  89 83 D0 8E 00 00           mov     [rbx+8ED0h], eax
00000001803773E6  8B 83 B0 8E 00 00           mov     eax, [rbx+8EB0h]
00000001803773EC  89 83 C0 8E 00 00           mov     [rbx+8EC0h], eax
00000001803773F2  8B 83 A0 8E 00 00           mov     eax, [rbx+8EA0h]
00000001803773F8  89 83 B0 8E 00 00           mov     [rbx+8EB0h], eax
00000001803773FE  8B 83 90 8E 00 00           mov     eax, [rbx+8E90h]
0000000180377404  89 83 A0 8E 00 00           mov     [rbx+8EA0h], eax
000000018037740A  8B 83 80 8E 00 00           mov     eax, [rbx+8E80h]
0000000180377410  89 83 90 8E 00 00           mov     [rbx+8E90h], eax
0000000180377416  8B 83 60 8F 00 00           mov     eax, [rbx+8F60h]
000000018037741C  89 83 70 8F 00 00           mov     [rbx+8F70h], eax
0000000180377422  8B 83 50 8F 00 00           mov     eax, [rbx+8F50h]
0000000180377428  89 83 60 8F 00 00           mov     [rbx+8F60h], eax
000000018037742E  8B 83 40 8F 00 00           mov     eax, [rbx+8F40h]
0000000180377434  89 83 50 8F 00 00           mov     [rbx+8F50h], eax
000000018037743A  8B 83 30 8F 00 00           mov     eax, [rbx+8F30h]
0000000180377440  89 83 40 8F 00 00           mov     [rbx+8F40h], eax
0000000180377446  8B 83 20 8F 00 00           mov     eax, [rbx+8F20h]
000000018037744C  89 83 30 8F 00 00           mov     [rbx+8F30h], eax
0000000180377452  8B 83 10 8F 00 00           mov     eax, [rbx+8F10h]
0000000180377458  89 83 20 8F 00 00           mov     [rbx+8F20h], eax
000000018037745E  8B 83 00 8F 00 00           mov     eax, [rbx+8F00h]
0000000180377464  89 83 10 8F 00 00           mov     [rbx+8F10h], eax
000000018037746A  8B 83 E0 8F 00 00           mov     eax, [rbx+8FE0h]
0000000180377470  89 83 F0 8F 00 00           mov     [rbx+8FF0h], eax
0000000180377476  8B 83 D0 8F 00 00           mov     eax, [rbx+8FD0h]
000000018037747C  89 83 E0 8F 00 00           mov     [rbx+8FE0h], eax
0000000180377482  8B 83 C0 8F 00 00           mov     eax, [rbx+8FC0h]
0000000180377488  89 83 D0 8F 00 00           mov     [rbx+8FD0h], eax
000000018037748E  8B 83 B0 8F 00 00           mov     eax, [rbx+8FB0h]
0000000180377494  89 83 C0 8F 00 00           mov     [rbx+8FC0h], eax
000000018037749A  8B 83 A0 8F 00 00           mov     eax, [rbx+8FA0h]
00000001803774A0  89 83 B0 8F 00 00           mov     [rbx+8FB0h], eax
00000001803774A6  8B 83 90 8F 00 00           mov     eax, [rbx+8F90h]
00000001803774AC  89 83 A0 8F 00 00           mov     [rbx+8FA0h], eax
00000001803774B2  8B 83 80 8F 00 00           mov     eax, [rbx+8F80h]
00000001803774B8  89 83 90 8F 00 00           mov     [rbx+8F90h], eax
00000001803774BE  8B 83 60 90 00 00           mov     eax, [rbx+9060h]
00000001803774C4  89 83 70 90 00 00           mov     [rbx+9070h], eax
00000001803774CA  8B 83 50 90 00 00           mov     eax, [rbx+9050h]
00000001803774D0  89 83 60 90 00 00           mov     [rbx+9060h], eax
00000001803774D6  8B 83 40 90 00 00           mov     eax, [rbx+9040h]
00000001803774DC  89 83 50 90 00 00           mov     [rbx+9050h], eax
00000001803774E2  8B 83 30 90 00 00           mov     eax, [rbx+9030h]
00000001803774E8  89 83 40 90 00 00           mov     [rbx+9040h], eax
00000001803774EE  8B 83 20 90 00 00           mov     eax, [rbx+9020h]
00000001803774F4  89 83 30 90 00 00           mov     [rbx+9030h], eax
00000001803774FA  8B 83 10 90 00 00           mov     eax, [rbx+9010h]
0000000180377500  89 83 20 90 00 00           mov     [rbx+9020h], eax
0000000180377506  8B 83 00 90 00 00           mov     eax, [rbx+9000h]
000000018037750C  89 83 10 90 00 00           mov     [rbx+9010h], eax
0000000180377512  8B 83 A0 90 00 00           mov     eax, [rbx+90A0h]
0000000180377518  89 83 B0 90 00 00           mov     [rbx+90B0h], eax
000000018037751E  8B 83 90 90 00 00           mov     eax, [rbx+9090h]
0000000180377524  89 83 A0 90 00 00           mov     [rbx+90A0h], eax
000000018037752A  F3 0F 11 83 B0 8D 00 00     movss   dword ptr [rbx+8DB0h], xmm0
0000000180377532  F3 0F 11 8B C0 8D 00 00     movss   dword ptr [rbx+8DC0h], xmm1
000000018037753A  F3 0F 58 AB D0 93 00 00     addss   xmm5, dword ptr [rbx+93D0h]
0000000180377542  F3 0F 59 9B D0 90 00 00     mulss   xmm3, dword ptr [rbx+90D0h]
000000018037754A  F3 0F 10 83 C0 90 00 00     movss   xmm0, dword ptr [rbx+90C0h]
0000000180377552  F3 0F 11 93 D0 8D 00 00     movss   dword ptr [rbx+8DD0h], xmm2
000000018037755A  F3 0F 10 93 F0 90 00 00     movss   xmm2, dword ptr [rbx+90F0h]
0000000180377562  F3 0F 59 AB E0 93 00 00     mulss   xmm5, dword ptr [rbx+93E0h]
000000018037756A  F3 0F 5F D3                 maxss   xmm2, xmm3
000000018037756E  F3 0F 58 AB C0 93 00 00     addss   xmm5, dword ptr [rbx+93C0h]
0000000180377576  F3 0F 11 93 E0 8D 00 00     movss   dword ptr [rbx+8DE0h], xmm2
000000018037757E  F3 0F 58 83 10 8A 00 00     addss   xmm0, dword ptr [rbx+8A10h]
0000000180377586  41 0F 2F EE                 comiss  xmm5, xmm14
000000018037758A  F3 0F 11 83 00 8E 00 00     movss   dword ptr [rbx+8E00h], xmm0
0000000180377592  76 05                       jbe     short loc_180377599
0000000180377594  0F 5A C5                    cvtps2pd xmm0, xmm5
0000000180377597  EB 03                       jmp     short loc_18037759C
0000000180377599  0F 57 C0                    xorps   xmm0, xmm0
000000018037759C  F3 0F 10 0D B8 D9 76 00     movss   xmm1, cs:dword_180AE4F5C
00000001803775A4  F3 44 0F 10 15 3B DC 76 00  movss   xmm10, cs:flt_180AE51E8
00000001803775AD  F3 0F 5E CA                 divss   xmm1, xmm2
00000001803775B1  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00000001803775B5  F3 0F 11 8B F0 8D 00 00     movss   dword ptr [rbx+8DF0h], xmm1
00000001803775BD  F3 0F 11 83 80 90 00 00     movss   dword ptr [rbx+9080h], xmm0
00000001803775C5  F3 0F 10 B3 40 8E 00 00     movss   xmm6, dword ptr [rbx+8E40h]
00000001803775CD  F3 0F 10 8B 20 8E 00 00     movss   xmm1, dword ptr [rbx+8E20h]
00000001803775D5  F3 0F 11 B3 60 8D 00 00     movss   dword ptr [rbx+8D60h], xmm6
00000001803775DD  F3 0F 58 F2                 addss   xmm6, xmm2
00000001803775E1  F3 0F 11 8B 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm1
00000001803775E9  41 0F 2F F5                 comiss  xmm6, xmm13
00000001803775ED  76 1B                       jbe     short loc_18037760A
00000001803775EF  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803775F4  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00000001803775F8  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803775FB  E8 D8 7E 37 00              call    fmodf
0000000180377600  0F 28 F0                    movaps  xmm6, xmm0
0000000180377603  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180377608  EB 1F                       jmp     short loc_180377629
000000018037760A  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037760E  73 19                       jnb     short loc_180377629
0000000180377610  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180377615  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180377619  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037761C  E8 B7 7E 37 00              call    fmodf
0000000180377621  0F 28 F0                    movaps  xmm6, xmm0
0000000180377624  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180377629  F3 44 0F 10 25 DA D9 76 00  movss   xmm12, cs:dword_180AE500C
0000000180377632  0F 28 C6                    movaps  xmm0, xmm6
0000000180377635  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037763A  F3 0F 11 B3 50 8D 00 00     movss   dword ptr [rbx+8D50h], xmm6
0000000180377642  0F 28 FE                    movaps  xmm7, xmm6
0000000180377645  F3 0F 59 BB 40 91 00 00     mulss   xmm7, dword ptr [rbx+9140h]
000000018037764D  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180377652  E8 69 19 FF FF              call    sub_180368FC0
0000000180377657  F3 44 0F 10 1D E4 DD 76 00  movss   xmm11, cs:dword_180AE5444
0000000180377660  0F 28 E8                    movaps  xmm5, xmm0
0000000180377663  F3 41 0F 59 EB              mulss   xmm5, xmm11
0000000180377668  F3 0F 59 AB F0 8D 00 00     mulss   xmm5, dword ptr [rbx+8DF0h]
0000000180377670  F3 0F 59 AB 10 91 00 00     mulss   xmm5, dword ptr [rbx+9110h]
0000000180377678  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037767C  73 06                       jnb     short loc_180377684
000000018037767E  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180377682  EB 05                       jmp     short loc_180377689
0000000180377684  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180377689  F3 0F 59 AB E0 90 00 00     mulss   xmm5, dword ptr [rbx+90E0h]
0000000180377691  0F 28 D5                    movaps  xmm2, xmm5
0000000180377694  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180377698  0F 28 CA                    movaps  xmm1, xmm2
000000018037769B  0F 28 C2                    movaps  xmm0, xmm2
000000018037769E  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00000001803776A6  0F 28 DA                    movaps  xmm3, xmm2
00000001803776A9  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803776AD  0F 28 E2                    movaps  xmm4, xmm2
00000001803776B0  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
00000001803776B8  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
00000001803776C0  F3 0F 59 DD                 mulss   xmm3, xmm5
00000001803776C4  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
00000001803776CC  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803776D0  0F 28 C3                    movaps  xmm0, xmm3
00000001803776D3  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
00000001803776DB  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803776DF  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803776E3  F3 0F 10 8B 00 8E 00 00     movss   xmm1, dword ptr [rbx+8E00h]
00000001803776EB  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803776EF  0F 28 C1                    movaps  xmm0, xmm1
00000001803776F2  F3 0F 58 C6                 addss   xmm0, xmm6
00000001803776F6  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803776FA  41 0F 2F C6                 comiss  xmm0, xmm14
00000001803776FE  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180377702  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180377706  F3 0F 11 A3 50 8E 00 00     movss   dword ptr [rbx+8E50h], xmm4
000000018037770E  72 07                       jb      short loc_180377717
0000000180377710  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180377715  EB 05                       jmp     short loc_18037771C
0000000180377717  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037771C  0F 28 F0                    movaps  xmm6, xmm0
000000018037771F  73 06                       jnb     short loc_180377727
0000000180377721  41 0F 28 F7                 movaps  xmm6, xmm15
0000000180377725  EB 06                       jmp     short loc_18037772D
0000000180377727  76 04                       jbe     short loc_18037772D
0000000180377729  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037772D  F3 44 0F 10 83 50 8D 00 00  movss   xmm8, dword ptr [rbx+8D50h]
0000000180377736  F3 0F 59 B3 50 91 00 00     mulss   xmm6, dword ptr [rbx+9150h]
000000018037773E  F3 0F 5E C1                 divss   xmm0, xmm1
0000000180377742  E8 79 18 FF FF              call    sub_180368FC0
0000000180377747  0F 28 E0                    movaps  xmm4, xmm0
000000018037774A  F3 0F 10 83 00 91 00 00     movss   xmm0, dword ptr [rbx+9100h]
0000000180377752  44 0F 2F C0                 comiss  xmm8, xmm0
0000000180377756  72 18                       jb      short loc_180377770
0000000180377758  0F 2F 83 60 8D 00 00        comiss  xmm0, dword ptr [rbx+8D60h]
000000018037775F  76 0F                       jbe     short loc_180377770
0000000180377761  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
0000000180377769  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018037776E  EB 08                       jmp     short loc_180377778
0000000180377770  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
0000000180377778  0F 2F 3D 51 DB 76 00        comiss  xmm7, cs:dword_180AE52D0
000000018037777F  F3 0F 59 A3 F0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DF0h]
0000000180377787  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018037778C  F3 0F 59 A3 20 91 00 00     mulss   xmm4, dword ptr [rbx+9120h]
0000000180377794  72 03                       jb      short loc_180377799
0000000180377796  0F 57 FF                    xorps   xmm7, xmm7
0000000180377799  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037779D  73 06                       jnb     short loc_1803777A5
000000018037779F  41 0F 28 E7                 movaps  xmm4, xmm15
00000001803777A3  EB 05                       jmp     short loc_1803777AA
00000001803777A5  F3 41 0F 5D E5              minss   xmm4, xmm13
00000001803777AA  F3 0F 11 BB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm7
00000001803777B2  F3 41 0F 58 F8              addss   xmm7, xmm8
00000001803777B7  F3 0F 59 A3 E0 90 00 00     mulss   xmm4, dword ptr [rbx+90E0h]
00000001803777BF  0F 28 D4                    movaps  xmm2, xmm4
00000001803777C2  F3 41 0F 58 FD              addss   xmm7, xmm13
00000001803777C7  F3 0F 59 D4                 mulss   xmm2, xmm4
00000001803777CB  0F 28 C2                    movaps  xmm0, xmm2
00000001803777CE  F3 41 0F 59 FC              mulss   xmm7, xmm12
00000001803777D3  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803777D7  0F 28 DA                    movaps  xmm3, xmm2
00000001803777DA  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803777DE  44 0F 28 CA                 movaps  xmm9, xmm2
00000001803777E2  F3 44 0F 59 8B B0 92 00 00  mulss   xmm9, dword ptr [rbx+92B0h]
00000001803777EB  F3 41 0F 5C FD              subss   xmm7, xmm13
00000001803777F0  0F 28 CA                    movaps  xmm1, xmm2
00000001803777F3  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00000001803777FB  F3 44 0F 58 8B A0 92 00 00  addss   xmm9, dword ptr [rbx+92A0h]
0000000180377804  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
000000018037780C  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180377811  0F 28 C3                    movaps  xmm0, xmm3
0000000180377814  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
000000018037781C  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180377821  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377825  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037782A  0F 28 C7                    movaps  xmm0, xmm7
000000018037782D  0F 54 05 5C DF 76 00        andps   xmm0, cs:xmmword_180AE5790
0000000180377834  0F 57 05 85 DF 76 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037783B  F3 44 0F 58 CB              addss   xmm9, xmm3
0000000180377840  F3 44 0F 58 CC              addss   xmm9, xmm4
0000000180377845  F3 44 0F 59 CE              mulss   xmm9, xmm6
000000018037784A  F3 44 0F 11 8B 60 8E 00 00  movss   dword ptr [rbx+8E60h], xmm9
0000000180377853  E8 68 17 FF FF              call    sub_180368FC0
0000000180377858  41 0F 2F FE                 comiss  xmm7, xmm14
000000018037785C  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180377860  F3 45 0F 58 C5              addss   xmm8, xmm13
0000000180377865  73 06                       jnb     short loc_18037786D
0000000180377867  41 0F 28 FF                 movaps  xmm7, xmm15
000000018037786B  EB 06                       jmp     short loc_180377873
000000018037786D  76 04                       jbe     short loc_180377873
000000018037786F  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180377873  F3 44 0F 59 83 F0 8D 00 00  mulss   xmm8, dword ptr [rbx+8DF0h]
000000018037787C  F3 0F 59 BB 60 91 00 00     mulss   xmm7, dword ptr [rbx+9160h]
0000000180377884  F3 44 0F 59 05 0B 34 61 00  mulss   xmm8, cs:dword_18098AC98
000000018037788D  F3 44 0F 59 83 30 91 00 00  mulss   xmm8, dword ptr [rbx+9130h]
0000000180377896  45 0F 2F C7                 comiss  xmm8, xmm15
000000018037789A  73 06                       jnb     short loc_1803778A2
000000018037789C  45 0F 28 C7                 movaps  xmm8, xmm15
00000001803778A0  EB 05                       jmp     short loc_1803778A7
00000001803778A2  F3 45 0F 5D C5              minss   xmm8, xmm13
00000001803778A7  F3 44 0F 59 83 E0 90 00 00  mulss   xmm8, dword ptr [rbx+90E0h]
00000001803778B0  F3 44 0F 59 8B C0 8D 00 00  mulss   xmm9, dword ptr [rbx+8DC0h]
00000001803778B9  F3 0F 10 B3 50 8D 00 00     movss   xmm6, dword ptr [rbx+8D50h]
00000001803778C1  41 0F 28 D0                 movaps  xmm2, xmm8
00000001803778C5  F3 0F 10 AB 70 8D 00 00     movss   xmm5, dword ptr [rbx+8D70h]
00000001803778CD  F3 41 0F 59 D0              mulss   xmm2, xmm8
00000001803778D2  0F 28 C2                    movaps  xmm0, xmm2
00000001803778D5  0F 28 DA                    movaps  xmm3, xmm2
00000001803778D8  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803778DC  0F 28 E2                    movaps  xmm4, xmm2
00000001803778DF  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
00000001803778E7  0F 28 CA                    movaps  xmm1, xmm2
00000001803778EA  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
00000001803778F2  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
00000001803778FA  F3 41 0F 59 D8              mulss   xmm3, xmm8
00000001803778FF  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
0000000180377907  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037790B  0F 28 C3                    movaps  xmm0, xmm3
000000018037790E  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
0000000180377916  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037791A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037791E  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180377922  F3 0F 10 83 50 8E 00 00     movss   xmm0, dword ptr [rbx+8E50h]
000000018037792A  F3 0F 59 83 B0 8D 00 00     mulss   xmm0, dword ptr [rbx+8DB0h]
0000000180377932  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180377936  F3 41 0F 58 C1              addss   xmm0, xmm9
000000018037793B  F3 41 0F 58 E0              addss   xmm4, xmm8
0000000180377940  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180377944  F3 0F 59 A3 D0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DD0h]
000000018037794C  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180377950  F3 0F 11 A3 80 8E 00 00     movss   dword ptr [rbx+8E80h], xmm4
0000000180377958  F3 0F 11 B3 60 8D 00 00     movss   dword ptr [rbx+8D60h], xmm6
0000000180377960  F3 0F 11 AB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm5
0000000180377968  F3 0F 58 B3 E0 8D 00 00     addss   xmm6, dword ptr [rbx+8DE0h]
0000000180377970  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180377974  76 1B                       jbe     short loc_180377991
0000000180377976  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037797B  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037797F  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180377982  E8 51 7B 37 00              call    fmodf
0000000180377987  0F 28 F0                    movaps  xmm6, xmm0
000000018037798A  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037798F  EB 1F                       jmp     short loc_1803779B0
0000000180377991  41 0F 2F F7                 comiss  xmm6, xmm15
0000000180377995  73 19                       jnb     short loc_1803779B0
0000000180377997  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037799C  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00000001803779A0  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803779A3  E8 30 7B 37 00              call    fmodf
00000001803779A8  0F 28 F0                    movaps  xmm6, xmm0
00000001803779AB  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803779B0  0F 28 C6                    movaps  xmm0, xmm6
00000001803779B3  F3 0F 11 B3 50 8D 00 00     movss   dword ptr [rbx+8D50h], xmm6
00000001803779BB  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803779C0  0F 28 FE                    movaps  xmm7, xmm6
00000001803779C3  F3 0F 59 BB 40 91 00 00     mulss   xmm7, dword ptr [rbx+9140h]
00000001803779CB  F3 41 0F 59 C4              mulss   xmm0, xmm12
00000001803779D0  E8 EB 15 FF FF              call    sub_180368FC0
00000001803779D5  0F 28 E8                    movaps  xmm5, xmm0
00000001803779D8  F3 41 0F 59 EB              mulss   xmm5, xmm11
00000001803779DD  F3 0F 59 AB F0 8D 00 00     mulss   xmm5, dword ptr [rbx+8DF0h]
00000001803779E5  F3 0F 59 AB 10 91 00 00     mulss   xmm5, dword ptr [rbx+9110h]
00000001803779ED  41 0F 2F EF                 comiss  xmm5, xmm15
00000001803779F1  73 06                       jnb     short loc_1803779F9
00000001803779F3  41 0F 28 EF                 movaps  xmm5, xmm15
00000001803779F7  EB 05                       jmp     short loc_1803779FE
00000001803779F9  F3 41 0F 5D ED              minss   xmm5, xmm13
00000001803779FE  F3 0F 59 AB E0 90 00 00     mulss   xmm5, dword ptr [rbx+90E0h]
0000000180377A06  0F 28 D5                    movaps  xmm2, xmm5
0000000180377A09  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180377A0D  0F 28 CA                    movaps  xmm1, xmm2
0000000180377A10  0F 28 C2                    movaps  xmm0, xmm2
0000000180377A13  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
0000000180377A1B  0F 28 DA                    movaps  xmm3, xmm2
0000000180377A1E  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377A22  0F 28 E2                    movaps  xmm4, xmm2
0000000180377A25  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
0000000180377A2D  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
0000000180377A35  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180377A39  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
0000000180377A41  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180377A45  0F 28 C3                    movaps  xmm0, xmm3
0000000180377A48  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
0000000180377A50  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180377A54  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377A58  F3 0F 10 8B 00 8E 00 00     movss   xmm1, dword ptr [rbx+8E00h]
0000000180377A60  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180377A64  0F 28 C1                    movaps  xmm0, xmm1
0000000180377A67  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180377A6B  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180377A6F  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180377A73  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180377A77  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180377A7B  F3 0F 11 A3 50 8E 00 00     movss   dword ptr [rbx+8E50h], xmm4
0000000180377A83  72 07                       jb      short loc_180377A8C
0000000180377A85  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180377A8A  EB 05                       jmp     short loc_180377A91
0000000180377A8C  F3 41 0F 5C CD              subss   xmm1, xmm13
0000000180377A91  0F 28 F0                    movaps  xmm6, xmm0
0000000180377A94  73 06                       jnb     short loc_180377A9C
0000000180377A96  41 0F 28 F7                 movaps  xmm6, xmm15
0000000180377A9A  EB 06                       jmp     short loc_180377AA2
0000000180377A9C  76 04                       jbe     short loc_180377AA2
0000000180377A9E  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180377AA2  F3 44 0F 10 83 50 8D 00 00  movss   xmm8, dword ptr [rbx+8D50h]
0000000180377AAB  F3 0F 59 B3 50 91 00 00     mulss   xmm6, dword ptr [rbx+9150h]
0000000180377AB3  F3 0F 5E C1                 divss   xmm0, xmm1
0000000180377AB7  E8 04 15 FF FF              call    sub_180368FC0
0000000180377ABC  0F 28 E0                    movaps  xmm4, xmm0
0000000180377ABF  F3 0F 10 83 00 91 00 00     movss   xmm0, dword ptr [rbx+9100h]
0000000180377AC7  44 0F 2F C0                 comiss  xmm8, xmm0
0000000180377ACB  72 18                       jb      short loc_180377AE5
0000000180377ACD  0F 2F 83 60 8D 00 00        comiss  xmm0, dword ptr [rbx+8D60h]
0000000180377AD4  76 0F                       jbe     short loc_180377AE5
0000000180377AD6  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
0000000180377ADE  F3 41 0F 58 FA              addss   xmm7, xmm10
0000000180377AE3  EB 08                       jmp     short loc_180377AED
0000000180377AE5  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
0000000180377AED  0F 2F 3D DC D7 76 00        comiss  xmm7, cs:dword_180AE52D0
0000000180377AF4  F3 0F 59 A3 F0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DF0h]
0000000180377AFC  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180377B01  F3 0F 59 A3 20 91 00 00     mulss   xmm4, dword ptr [rbx+9120h]
0000000180377B09  72 03                       jb      short loc_180377B0E
0000000180377B0B  0F 57 FF                    xorps   xmm7, xmm7
0000000180377B0E  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180377B12  73 06                       jnb     short loc_180377B1A
0000000180377B14  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180377B18  EB 05                       jmp     short loc_180377B1F
0000000180377B1A  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180377B1F  F3 0F 11 BB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm7
0000000180377B27  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180377B2C  F3 0F 59 A3 E0 90 00 00     mulss   xmm4, dword ptr [rbx+90E0h]
0000000180377B34  0F 28 D4                    movaps  xmm2, xmm4
0000000180377B37  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180377B3C  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180377B40  0F 28 C2                    movaps  xmm0, xmm2
0000000180377B43  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180377B48  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377B4C  0F 28 DA                    movaps  xmm3, xmm2
0000000180377B4F  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180377B53  44 0F 28 CA                 movaps  xmm9, xmm2
0000000180377B57  F3 44 0F 59 8B B0 92 00 00  mulss   xmm9, dword ptr [rbx+92B0h]
0000000180377B60  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180377B65  0F 28 CA                    movaps  xmm1, xmm2
0000000180377B68  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
0000000180377B70  F3 44 0F 58 8B A0 92 00 00  addss   xmm9, dword ptr [rbx+92A0h]
0000000180377B79  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
0000000180377B81  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180377B86  0F 28 C3                    movaps  xmm0, xmm3
0000000180377B89  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
0000000180377B91  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180377B96  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377B9A  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180377B9F  0F 28 C7                    movaps  xmm0, xmm7
0000000180377BA2  0F 54 05 E7 DB 76 00        andps   xmm0, cs:xmmword_180AE5790
0000000180377BA9  0F 57 05 10 DC 76 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180377BB0  F3 44 0F 58 CB              addss   xmm9, xmm3
0000000180377BB5  F3 44 0F 58 CC              addss   xmm9, xmm4
0000000180377BBA  F3 44 0F 59 CE              mulss   xmm9, xmm6
0000000180377BBF  F3 44 0F 11 8B 60 8E 00 00  movss   dword ptr [rbx+8E60h], xmm9
0000000180377BC8  E8 F3 13 FF FF              call    sub_180368FC0
0000000180377BCD  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180377BD1  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180377BD5  F3 45 0F 58 C5              addss   xmm8, xmm13
0000000180377BDA  73 06                       jnb     short loc_180377BE2
0000000180377BDC  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180377BE0  EB 06                       jmp     short loc_180377BE8
0000000180377BE2  76 04                       jbe     short loc_180377BE8
0000000180377BE4  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180377BE8  F3 44 0F 59 83 F0 8D 00 00  mulss   xmm8, dword ptr [rbx+8DF0h]
0000000180377BF1  F3 0F 59 BB 60 91 00 00     mulss   xmm7, dword ptr [rbx+9160h]
0000000180377BF9  F3 44 0F 59 05 96 30 61 00  mulss   xmm8, cs:dword_18098AC98
0000000180377C02  F3 44 0F 59 83 30 91 00 00  mulss   xmm8, dword ptr [rbx+9130h]
0000000180377C0B  45 0F 2F C7                 comiss  xmm8, xmm15
0000000180377C0F  73 06                       jnb     short loc_180377C17
0000000180377C11  45 0F 28 C7                 movaps  xmm8, xmm15
0000000180377C15  EB 05                       jmp     short loc_180377C1C
0000000180377C17  F3 45 0F 5D C5              minss   xmm8, xmm13
0000000180377C1C  F3 44 0F 59 83 E0 90 00 00  mulss   xmm8, dword ptr [rbx+90E0h]
0000000180377C25  F3 44 0F 59 8B C0 8D 00 00  mulss   xmm9, dword ptr [rbx+8DC0h]
0000000180377C2E  F3 0F 10 B3 50 8D 00 00     movss   xmm6, dword ptr [rbx+8D50h]
0000000180377C36  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180377C3A  F3 0F 10 AB 70 8D 00 00     movss   xmm5, dword ptr [rbx+8D70h]
0000000180377C42  F3 41 0F 59 D0              mulss   xmm2, xmm8
0000000180377C47  0F 28 C2                    movaps  xmm0, xmm2
0000000180377C4A  0F 28 DA                    movaps  xmm3, xmm2
0000000180377C4D  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377C51  0F 28 E2                    movaps  xmm4, xmm2
0000000180377C54  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
0000000180377C5C  0F 28 CA                    movaps  xmm1, xmm2
0000000180377C5F  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
0000000180377C67  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
0000000180377C6F  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180377C74  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
0000000180377C7C  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180377C80  0F 28 C3                    movaps  xmm0, xmm3
0000000180377C83  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
0000000180377C8B  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180377C8F  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377C93  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180377C97  F3 0F 10 83 50 8E 00 00     movss   xmm0, dword ptr [rbx+8E50h]
0000000180377C9F  F3 0F 59 83 B0 8D 00 00     mulss   xmm0, dword ptr [rbx+8DB0h]
0000000180377CA7  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180377CAB  F3 41 0F 58 C1              addss   xmm0, xmm9
0000000180377CB0  F3 41 0F 58 E0              addss   xmm4, xmm8
0000000180377CB5  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180377CB9  F3 0F 59 A3 D0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DD0h]
0000000180377CC1  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180377CC5  F3 0F 11 A3 00 8F 00 00     movss   dword ptr [rbx+8F00h], xmm4
0000000180377CCD  F3 0F 11 B3 60 8D 00 00     movss   dword ptr [rbx+8D60h], xmm6
0000000180377CD5  F3 0F 11 AB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm5
0000000180377CDD  F3 0F 58 B3 E0 8D 00 00     addss   xmm6, dword ptr [rbx+8DE0h]
0000000180377CE5  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180377CE9  76 1B                       jbe     short loc_180377D06
0000000180377CEB  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180377CF0  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180377CF4  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180377CF7  E8 DC 77 37 00              call    fmodf
0000000180377CFC  0F 28 F0                    movaps  xmm6, xmm0
0000000180377CFF  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180377D04  EB 1F                       jmp     short loc_180377D25
0000000180377D06  41 0F 2F F7                 comiss  xmm6, xmm15
0000000180377D0A  73 19                       jnb     short loc_180377D25
0000000180377D0C  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180377D11  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180377D15  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180377D18  E8 BB 77 37 00              call    fmodf
0000000180377D1D  0F 28 F0                    movaps  xmm6, xmm0
0000000180377D20  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180377D25  0F 28 C6                    movaps  xmm0, xmm6
0000000180377D28  F3 0F 11 B3 50 8D 00 00     movss   dword ptr [rbx+8D50h], xmm6
0000000180377D30  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180377D35  0F 28 FE                    movaps  xmm7, xmm6
0000000180377D38  F3 0F 59 BB 40 91 00 00     mulss   xmm7, dword ptr [rbx+9140h]
0000000180377D40  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180377D45  E8 76 12 FF FF              call    sub_180368FC0
0000000180377D4A  0F 28 E8                    movaps  xmm5, xmm0
0000000180377D4D  F3 41 0F 59 EB              mulss   xmm5, xmm11
0000000180377D52  F3 0F 59 AB F0 8D 00 00     mulss   xmm5, dword ptr [rbx+8DF0h]
0000000180377D5A  F3 0F 59 AB 10 91 00 00     mulss   xmm5, dword ptr [rbx+9110h]
0000000180377D62  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180377D66  73 06                       jnb     short loc_180377D6E
0000000180377D68  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180377D6C  EB 05                       jmp     short loc_180377D73
0000000180377D6E  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180377D73  F3 0F 59 AB E0 90 00 00     mulss   xmm5, dword ptr [rbx+90E0h]
0000000180377D7B  0F 28 D5                    movaps  xmm2, xmm5
0000000180377D7E  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180377D82  0F 28 CA                    movaps  xmm1, xmm2
0000000180377D85  0F 28 C2                    movaps  xmm0, xmm2
0000000180377D88  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
0000000180377D90  0F 28 DA                    movaps  xmm3, xmm2
0000000180377D93  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377D97  0F 28 E2                    movaps  xmm4, xmm2
0000000180377D9A  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
0000000180377DA2  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
0000000180377DAA  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180377DAE  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
0000000180377DB6  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180377DBA  0F 28 C3                    movaps  xmm0, xmm3
0000000180377DBD  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
0000000180377DC5  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180377DC9  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377DCD  F3 0F 10 8B 00 8E 00 00     movss   xmm1, dword ptr [rbx+8E00h]
0000000180377DD5  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180377DD9  0F 28 C1                    movaps  xmm0, xmm1
0000000180377DDC  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180377DE0  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180377DE4  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180377DE8  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180377DEC  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180377DF0  F3 0F 11 A3 50 8E 00 00     movss   dword ptr [rbx+8E50h], xmm4
0000000180377DF8  72 07                       jb      short loc_180377E01
0000000180377DFA  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180377DFF  EB 05                       jmp     short loc_180377E06
0000000180377E01  F3 41 0F 5C CD              subss   xmm1, xmm13
0000000180377E06  0F 28 F0                    movaps  xmm6, xmm0
0000000180377E09  73 06                       jnb     short loc_180377E11
0000000180377E0B  41 0F 28 F7                 movaps  xmm6, xmm15
0000000180377E0F  EB 06                       jmp     short loc_180377E17
0000000180377E11  76 04                       jbe     short loc_180377E17
0000000180377E13  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180377E17  F3 44 0F 10 83 50 8D 00 00  movss   xmm8, dword ptr [rbx+8D50h]
0000000180377E20  F3 0F 59 B3 50 91 00 00     mulss   xmm6, dword ptr [rbx+9150h]
0000000180377E28  F3 0F 5E C1                 divss   xmm0, xmm1
0000000180377E2C  E8 8F 11 FF FF              call    sub_180368FC0
0000000180377E31  0F 28 E0                    movaps  xmm4, xmm0
0000000180377E34  F3 0F 10 83 00 91 00 00     movss   xmm0, dword ptr [rbx+9100h]
0000000180377E3C  44 0F 2F C0                 comiss  xmm8, xmm0
0000000180377E40  72 18                       jb      short loc_180377E5A
0000000180377E42  0F 2F 83 60 8D 00 00        comiss  xmm0, dword ptr [rbx+8D60h]
0000000180377E49  76 0F                       jbe     short loc_180377E5A
0000000180377E4B  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
0000000180377E53  F3 41 0F 58 FA              addss   xmm7, xmm10
0000000180377E58  EB 08                       jmp     short loc_180377E62
0000000180377E5A  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
0000000180377E62  0F 2F 3D 67 D4 76 00        comiss  xmm7, cs:dword_180AE52D0
0000000180377E69  F3 0F 59 A3 F0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DF0h]
0000000180377E71  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180377E76  F3 0F 59 A3 20 91 00 00     mulss   xmm4, dword ptr [rbx+9120h]
0000000180377E7E  72 03                       jb      short loc_180377E83
0000000180377E80  0F 57 FF                    xorps   xmm7, xmm7
0000000180377E83  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180377E87  73 06                       jnb     short loc_180377E8F
0000000180377E89  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180377E8D  EB 05                       jmp     short loc_180377E94
0000000180377E8F  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180377E94  F3 0F 11 BB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm7
0000000180377E9C  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180377EA1  F3 0F 59 A3 E0 90 00 00     mulss   xmm4, dword ptr [rbx+90E0h]
0000000180377EA9  0F 28 D4                    movaps  xmm2, xmm4
0000000180377EAC  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180377EB1  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180377EB5  0F 28 C2                    movaps  xmm0, xmm2
0000000180377EB8  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180377EBD  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377EC1  0F 28 DA                    movaps  xmm3, xmm2
0000000180377EC4  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180377EC8  44 0F 28 CA                 movaps  xmm9, xmm2
0000000180377ECC  F3 44 0F 59 8B B0 92 00 00  mulss   xmm9, dword ptr [rbx+92B0h]
0000000180377ED5  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180377EDA  0F 28 CA                    movaps  xmm1, xmm2
0000000180377EDD  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
0000000180377EE5  F3 44 0F 58 8B A0 92 00 00  addss   xmm9, dword ptr [rbx+92A0h]
0000000180377EEE  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
0000000180377EF6  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180377EFB  0F 28 C3                    movaps  xmm0, xmm3
0000000180377EFE  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
0000000180377F06  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180377F0B  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377F0F  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180377F14  0F 28 C7                    movaps  xmm0, xmm7
0000000180377F17  0F 54 05 72 D8 76 00        andps   xmm0, cs:xmmword_180AE5790
0000000180377F1E  0F 57 05 9B D8 76 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180377F25  F3 44 0F 58 CB              addss   xmm9, xmm3
0000000180377F2A  F3 44 0F 58 CC              addss   xmm9, xmm4
0000000180377F2F  F3 44 0F 59 CE              mulss   xmm9, xmm6
0000000180377F34  F3 44 0F 11 8B 60 8E 00 00  movss   dword ptr [rbx+8E60h], xmm9
0000000180377F3D  E8 7E 10 FF FF              call    sub_180368FC0
0000000180377F42  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180377F46  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180377F4A  F3 45 0F 58 C5              addss   xmm8, xmm13
0000000180377F4F  73 06                       jnb     short loc_180377F57
0000000180377F51  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180377F55  EB 06                       jmp     short loc_180377F5D
0000000180377F57  76 04                       jbe     short loc_180377F5D
0000000180377F59  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180377F5D  F3 44 0F 59 83 F0 8D 00 00  mulss   xmm8, dword ptr [rbx+8DF0h]
0000000180377F66  F3 0F 59 BB 60 91 00 00     mulss   xmm7, dword ptr [rbx+9160h]
0000000180377F6E  F3 44 0F 59 05 21 2D 61 00  mulss   xmm8, cs:dword_18098AC98
0000000180377F77  F3 44 0F 59 83 30 91 00 00  mulss   xmm8, dword ptr [rbx+9130h]
0000000180377F80  45 0F 2F C7                 comiss  xmm8, xmm15
0000000180377F84  73 06                       jnb     short loc_180377F8C
0000000180377F86  45 0F 28 C7                 movaps  xmm8, xmm15
0000000180377F8A  EB 05                       jmp     short loc_180377F91
0000000180377F8C  F3 45 0F 5D C5              minss   xmm8, xmm13
0000000180377F91  F3 44 0F 59 83 E0 90 00 00  mulss   xmm8, dword ptr [rbx+90E0h]
0000000180377F9A  F3 44 0F 59 8B C0 8D 00 00  mulss   xmm9, dword ptr [rbx+8DC0h]
0000000180377FA3  F3 0F 10 B3 50 8D 00 00     movss   xmm6, dword ptr [rbx+8D50h]
0000000180377FAB  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180377FAF  F3 0F 10 AB 70 8D 00 00     movss   xmm5, dword ptr [rbx+8D70h]
0000000180377FB7  F3 41 0F 59 D0              mulss   xmm2, xmm8
0000000180377FBC  0F 28 C2                    movaps  xmm0, xmm2
0000000180377FBF  0F 28 DA                    movaps  xmm3, xmm2
0000000180377FC2  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180377FC6  0F 28 E2                    movaps  xmm4, xmm2
0000000180377FC9  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
0000000180377FD1  0F 28 CA                    movaps  xmm1, xmm2
0000000180377FD4  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
0000000180377FDC  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
0000000180377FE4  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180377FE9  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
0000000180377FF1  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180377FF5  0F 28 C3                    movaps  xmm0, xmm3
0000000180377FF8  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
0000000180378000  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180378004  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180378008  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037800C  F3 0F 10 83 50 8E 00 00     movss   xmm0, dword ptr [rbx+8E50h]
0000000180378014  F3 0F 59 83 B0 8D 00 00     mulss   xmm0, dword ptr [rbx+8DB0h]
000000018037801C  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180378020  F3 41 0F 58 C1              addss   xmm0, xmm9
0000000180378025  F3 41 0F 58 E0              addss   xmm4, xmm8
000000018037802A  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037802E  F3 0F 59 A3 D0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DD0h]
0000000180378036  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037803A  F3 0F 11 A3 80 8F 00 00     movss   dword ptr [rbx+8F80h], xmm4
0000000180378042  F3 0F 11 B3 60 8D 00 00     movss   dword ptr [rbx+8D60h], xmm6
000000018037804A  F3 0F 11 AB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm5
0000000180378052  F3 0F 58 B3 E0 8D 00 00     addss   xmm6, dword ptr [rbx+8DE0h]
000000018037805A  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037805E  76 1B                       jbe     short loc_18037807B
0000000180378060  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180378065  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180378069  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037806C  E8 67 74 37 00              call    fmodf
0000000180378071  0F 28 F0                    movaps  xmm6, xmm0
0000000180378074  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180378079  EB 1F                       jmp     short loc_18037809A
000000018037807B  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037807F  73 19                       jnb     short loc_18037809A
0000000180378081  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180378086  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037808A  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037808D  E8 46 74 37 00              call    fmodf
0000000180378092  0F 28 F0                    movaps  xmm6, xmm0
0000000180378095  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037809A  0F 28 C6                    movaps  xmm0, xmm6
000000018037809D  F3 0F 11 B3 50 8D 00 00     movss   dword ptr [rbx+8D50h], xmm6
00000001803780A5  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803780AA  0F 28 FE                    movaps  xmm7, xmm6
00000001803780AD  F3 0F 59 BB 40 91 00 00     mulss   xmm7, dword ptr [rbx+9140h]
00000001803780B5  F3 41 0F 59 C4              mulss   xmm0, xmm12
00000001803780BA  E8 01 0F FF FF              call    sub_180368FC0
00000001803780BF  0F 28 E8                    movaps  xmm5, xmm0
00000001803780C2  F3 41 0F 59 EB              mulss   xmm5, xmm11
00000001803780C7  F3 0F 59 AB F0 8D 00 00     mulss   xmm5, dword ptr [rbx+8DF0h]
00000001803780CF  F3 0F 59 AB 10 91 00 00     mulss   xmm5, dword ptr [rbx+9110h]
00000001803780D7  41 0F 2F EF                 comiss  xmm5, xmm15
00000001803780DB  73 06                       jnb     short loc_1803780E3
00000001803780DD  41 0F 28 EF                 movaps  xmm5, xmm15
00000001803780E1  EB 05                       jmp     short loc_1803780E8
00000001803780E3  F3 41 0F 5D ED              minss   xmm5, xmm13
00000001803780E8  F3 0F 59 AB E0 90 00 00     mulss   xmm5, dword ptr [rbx+90E0h]
00000001803780F0  0F 28 D5                    movaps  xmm2, xmm5
00000001803780F3  F3 0F 59 D5                 mulss   xmm2, xmm5
00000001803780F7  0F 28 CA                    movaps  xmm1, xmm2
00000001803780FA  0F 28 C2                    movaps  xmm0, xmm2
00000001803780FD  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
0000000180378105  0F 28 DA                    movaps  xmm3, xmm2
0000000180378108  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037810C  0F 28 E2                    movaps  xmm4, xmm2
000000018037810F  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
0000000180378117  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
000000018037811F  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180378123  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
000000018037812B  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037812F  0F 28 C3                    movaps  xmm0, xmm3
0000000180378132  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
000000018037813A  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037813E  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180378142  F3 0F 10 8B 00 8E 00 00     movss   xmm1, dword ptr [rbx+8E00h]
000000018037814A  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037814E  0F 28 C1                    movaps  xmm0, xmm1
0000000180378151  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180378155  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180378159  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037815D  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180378161  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180378165  F3 0F 11 A3 50 8E 00 00     movss   dword ptr [rbx+8E50h], xmm4
000000018037816D  72 07                       jb      short loc_180378176
000000018037816F  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180378174  EB 05                       jmp     short loc_18037817B
0000000180378176  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037817B  0F 28 F0                    movaps  xmm6, xmm0
000000018037817E  73 06                       jnb     short loc_180378186
0000000180378180  41 0F 28 F7                 movaps  xmm6, xmm15
0000000180378184  EB 06                       jmp     short loc_18037818C
0000000180378186  76 04                       jbe     short loc_18037818C
0000000180378188  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037818C  F3 44 0F 10 83 50 8D 00 00  movss   xmm8, dword ptr [rbx+8D50h]
0000000180378195  F3 0F 59 B3 50 91 00 00     mulss   xmm6, dword ptr [rbx+9150h]
000000018037819D  F3 0F 5E C1                 divss   xmm0, xmm1
00000001803781A1  E8 1A 0E FF FF              call    sub_180368FC0
00000001803781A6  0F 28 E0                    movaps  xmm4, xmm0
00000001803781A9  F3 0F 10 83 00 91 00 00     movss   xmm0, dword ptr [rbx+9100h]
00000001803781B1  44 0F 2F C0                 comiss  xmm8, xmm0
00000001803781B5  72 18                       jb      short loc_1803781CF
00000001803781B7  0F 2F 83 60 8D 00 00        comiss  xmm0, dword ptr [rbx+8D60h]
00000001803781BE  76 0F                       jbe     short loc_1803781CF
00000001803781C0  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
00000001803781C8  F3 41 0F 58 FA              addss   xmm7, xmm10
00000001803781CD  EB 08                       jmp     short loc_1803781D7
00000001803781CF  F3 0F 10 BB 70 8D 00 00     movss   xmm7, dword ptr [rbx+8D70h]
00000001803781D7  0F 2F 3D F2 D0 76 00        comiss  xmm7, cs:dword_180AE52D0
00000001803781DE  F3 0F 59 A3 F0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DF0h]
00000001803781E6  F3 41 0F 59 E3              mulss   xmm4, xmm11
00000001803781EB  F3 0F 59 A3 20 91 00 00     mulss   xmm4, dword ptr [rbx+9120h]
00000001803781F3  72 03                       jb      short loc_1803781F8
00000001803781F5  0F 57 FF                    xorps   xmm7, xmm7
00000001803781F8  41 0F 2F E7                 comiss  xmm4, xmm15
00000001803781FC  73 06                       jnb     short loc_180378204
00000001803781FE  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180378202  EB 05                       jmp     short loc_180378209
0000000180378204  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180378209  F3 0F 11 BB 70 8D 00 00     movss   dword ptr [rbx+8D70h], xmm7
0000000180378211  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180378216  F3 0F 59 A3 E0 90 00 00     mulss   xmm4, dword ptr [rbx+90E0h]
000000018037821E  0F 28 D4                    movaps  xmm2, xmm4
0000000180378221  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180378226  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037822A  0F 28 C2                    movaps  xmm0, xmm2
000000018037822D  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180378232  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180378236  0F 28 DA                    movaps  xmm3, xmm2
0000000180378239  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037823D  44 0F 28 C2                 movaps  xmm8, xmm2
0000000180378241  F3 44 0F 59 83 B0 92 00 00  mulss   xmm8, dword ptr [rbx+92B0h]
000000018037824A  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037824F  0F 28 CA                    movaps  xmm1, xmm2
0000000180378252  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
000000018037825A  F3 44 0F 58 83 A0 92 00 00  addss   xmm8, dword ptr [rbx+92A0h]
0000000180378263  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
000000018037826B  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180378270  0F 28 C3                    movaps  xmm0, xmm3
0000000180378273  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
000000018037827B  F3 44 0F 58 C1              addss   xmm8, xmm1
0000000180378280  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180378284  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180378289  0F 28 C7                    movaps  xmm0, xmm7
000000018037828C  0F 54 05 FD D4 76 00        andps   xmm0, cs:xmmword_180AE5790
0000000180378293  0F 57 05 26 D5 76 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037829A  F3 44 0F 58 C3              addss   xmm8, xmm3
000000018037829F  F3 44 0F 58 C4              addss   xmm8, xmm4
00000001803782A4  F3 44 0F 59 C6              mulss   xmm8, xmm6
00000001803782A9  F3 44 0F 11 83 60 8E 00 00  movss   dword ptr [rbx+8E60h], xmm8
00000001803782B2  E8 09 0D FF FF              call    sub_180368FC0
00000001803782B7  41 0F 2F FE                 comiss  xmm7, xmm14
00000001803782BB  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803782C0  73 06                       jnb     short loc_1803782C8
00000001803782C2  41 0F 28 FF                 movaps  xmm7, xmm15
00000001803782C6  EB 06                       jmp     short loc_1803782CE
00000001803782C8  76 04                       jbe     short loc_1803782CE
00000001803782CA  41 0F 28 FD                 movaps  xmm7, xmm13
00000001803782CE  F3 0F 59 83 F0 8D 00 00     mulss   xmm0, dword ptr [rbx+8DF0h]
00000001803782D6  F3 0F 59 BB 60 91 00 00     mulss   xmm7, dword ptr [rbx+9160h]
00000001803782DE  F3 0F 59 05 B2 29 61 00     mulss   xmm0, cs:dword_18098AC98
00000001803782E6  F3 0F 59 83 30 91 00 00     mulss   xmm0, dword ptr [rbx+9130h]
00000001803782EE  41 0F 2F C7                 comiss  xmm0, xmm15
00000001803782F2  72 09                       jb      short loc_1803782FD
00000001803782F4  44 0F 28 F8                 movaps  xmm15, xmm0
00000001803782F8  F3 45 0F 5D FD              minss   xmm15, xmm13
00000001803782FD  F3 44 0F 59 BB E0 90 00 00  mulss   xmm15, dword ptr [rbx+90E0h]
0000000180378306  F3 44 0F 59 83 C0 8D 00 00  mulss   xmm8, dword ptr [rbx+8DC0h]
000000018037830F  F3 0F 10 AB 50 8D 00 00     movss   xmm5, dword ptr [rbx+8D50h]
0000000180378317  41 0F 28 D7                 movaps  xmm2, xmm15
000000018037831B  F3 0F 10 B3 70 8D 00 00     movss   xmm6, dword ptr [rbx+8D70h]
0000000180378323  F3 41 0F 59 D7              mulss   xmm2, xmm15
0000000180378328  0F 28 CA                    movaps  xmm1, xmm2
000000018037832B  0F 28 C2                    movaps  xmm0, xmm2
000000018037832E  F3 0F 59 8B 90 92 00 00     mulss   xmm1, dword ptr [rbx+9290h]
0000000180378336  0F 28 DA                    movaps  xmm3, xmm2
0000000180378339  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037833D  0F 28 E2                    movaps  xmm4, xmm2
0000000180378340  F3 0F 58 8B 80 92 00 00     addss   xmm1, dword ptr [rbx+9280h]
0000000180378348  F3 0F 59 A3 B0 92 00 00     mulss   xmm4, dword ptr [rbx+92B0h]
0000000180378350  F3 41 0F 59 DF              mulss   xmm3, xmm15
0000000180378355  F3 0F 58 A3 A0 92 00 00     addss   xmm4, dword ptr [rbx+92A0h]
000000018037835D  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180378361  0F 28 C3                    movaps  xmm0, xmm3
0000000180378364  F3 0F 59 9B 70 92 00 00     mulss   xmm3, dword ptr [rbx+9270h]
000000018037836C  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180378370  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180378374  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180378378  F3 0F 10 83 50 8E 00 00     movss   xmm0, dword ptr [rbx+8E50h]
0000000180378380  F3 0F 59 83 B0 8D 00 00     mulss   xmm0, dword ptr [rbx+8DB0h]
0000000180378388  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037838C  F3 41 0F 58 C0              addss   xmm0, xmm8
0000000180378391  F3 41 0F 58 E7              addss   xmm4, xmm15
0000000180378396  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037839A  F3 0F 59 A3 D0 8D 00 00     mulss   xmm4, dword ptr [rbx+8DD0h]
00000001803783A2  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803783A6  F3 0F 11 A3 00 90 00 00     movss   dword ptr [rbx+9000h], xmm4
00000001803783AE  F3 0F 10 93 70 90 00 00     movss   xmm2, dword ptr [rbx+9070h]
00000001803783B6  F3 0F 11 AB 30 8E 00 00     movss   dword ptr [rbx+8E30h], xmm5
00000001803783BE  F3 0F 11 B3 10 8E 00 00     movss   dword ptr [rbx+8E10h], xmm6
00000001803783C6  F3 0F 10 83 80 8F 00 00     movss   xmm0, dword ptr [rbx+8F80h]
00000001803783CE  F3 0F 58 83 70 8F 00 00     addss   xmm0, dword ptr [rbx+8F70h]
00000001803783D6  F3 0F 10 8B 00 90 00 00     movss   xmm1, dword ptr [rbx+9000h]
00000001803783DE  F3 0F 58 8B F0 8E 00 00     addss   xmm1, dword ptr [rbx+8EF0h]
00000001803783E6  F3 0F 10 AB F0 8F 00 00     movss   xmm5, dword ptr [rbx+8FF0h]
00000001803783EE  F3 0F 58 AB 00 8F 00 00     addss   xmm5, dword ptr [rbx+8F00h]
00000001803783F6  F3 0F 59 83 90 91 00 00     mulss   xmm0, dword ptr [rbx+9190h]
00000001803783FE  F3 0F 59 8B A0 91 00 00     mulss   xmm1, dword ptr [rbx+91A0h]
0000000180378406  F3 0F 59 AB 80 91 00 00     mulss   xmm5, dword ptr [rbx+9180h]
000000018037840E  F3 0F 58 93 80 8E 00 00     addss   xmm2, dword ptr [rbx+8E80h]
0000000180378416  F3 0F 59 93 70 91 00 00     mulss   xmm2, dword ptr [rbx+9170h]
000000018037841E  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180378422  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180378426  F3 0F 10 83 60 90 00 00     movss   xmm0, dword ptr [rbx+9060h]
000000018037842E  F3 0F 58 83 90 8E 00 00     addss   xmm0, dword ptr [rbx+8E90h]
0000000180378436  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037843A  F3 0F 10 8B E0 8F 00 00     movss   xmm1, dword ptr [rbx+8FE0h]
0000000180378442  F3 0F 59 83 B0 91 00 00     mulss   xmm0, dword ptr [rbx+91B0h]
000000018037844A  F3 0F 58 8B 10 8F 00 00     addss   xmm1, dword ptr [rbx+8F10h]
0000000180378452  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180378456  F3 0F 10 83 90 8F 00 00     movss   xmm0, dword ptr [rbx+8F90h]
000000018037845E  F3 0F 58 83 60 8F 00 00     addss   xmm0, dword ptr [rbx+8F60h]
0000000180378466  F3 0F 59 8B C0 91 00 00     mulss   xmm1, dword ptr [rbx+91C0h]
000000018037846E  F3 0F 59 83 D0 91 00 00     mulss   xmm0, dword ptr [rbx+91D0h]
0000000180378476  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037847A  F3 0F 10 8B 10 90 00 00     movss   xmm1, dword ptr [rbx+9010h]
0000000180378482  F3 0F 58 8B E0 8E 00 00     addss   xmm1, dword ptr [rbx+8EE0h]
000000018037848A  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037848E  F3 0F 10 83 50 90 00 00     movss   xmm0, dword ptr [rbx+9050h]
0000000180378496  F3 0F 59 8B E0 91 00 00     mulss   xmm1, dword ptr [rbx+91E0h]
000000018037849E  F3 0F 58 83 A0 8E 00 00     addss   xmm0, dword ptr [rbx+8EA0h]
00000001803784A6  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803784AA  F3 0F 10 8B 20 8F 00 00     movss   xmm1, dword ptr [rbx+8F20h]
00000001803784B2  F3 0F 58 8B D0 8F 00 00     addss   xmm1, dword ptr [rbx+8FD0h]
00000001803784BA  F3 0F 59 83 F0 91 00 00     mulss   xmm0, dword ptr [rbx+91F0h]
00000001803784C2  F3 0F 59 8B 00 92 00 00     mulss   xmm1, dword ptr [rbx+9200h]
00000001803784CA  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803784CE  F3 0F 10 83 A0 8F 00 00     movss   xmm0, dword ptr [rbx+8FA0h]
00000001803784D6  F3 0F 58 83 50 8F 00 00     addss   xmm0, dword ptr [rbx+8F50h]
00000001803784DE  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803784E2  F3 0F 10 8B D0 8E 00 00     movss   xmm1, dword ptr [rbx+8ED0h]
00000001803784EA  F3 0F 59 83 10 92 00 00     mulss   xmm0, dword ptr [rbx+9210h]
00000001803784F2  F3 0F 58 8B 20 90 00 00     addss   xmm1, dword ptr [rbx+9020h]
00000001803784FA  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803784FE  F3 0F 10 83 40 90 00 00     movss   xmm0, dword ptr [rbx+9040h]
0000000180378506  F3 0F 59 8B 20 92 00 00     mulss   xmm1, dword ptr [rbx+9220h]
000000018037850E  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180378512  F3 0F 58 83 B0 8E 00 00     addss   xmm0, dword ptr [rbx+8EB0h]
000000018037851A  F3 0F 10 93 A0 90 00 00     movss   xmm2, dword ptr [rbx+90A0h]
0000000180378522  F3 0F 10 8B C0 8F 00 00     movss   xmm1, dword ptr [rbx+8FC0h]
000000018037852A  0F 28 E2                    movaps  xmm4, xmm2
000000018037852D  F3 0F 59 A3 A0 93 00 00     mulss   xmm4, dword ptr [rbx+93A0h]
0000000180378535  F3 0F 59 83 30 92 00 00     mulss   xmm0, dword ptr [rbx+9230h]
000000018037853D  F3 0F 58 A3 B0 90 00 00     addss   xmm4, dword ptr [rbx+90B0h]
0000000180378545  F3 0F 58 8B 30 8F 00 00     addss   xmm1, dword ptr [rbx+8F30h]
000000018037854D  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180378551  F3 0F 10 83 B0 8F 00 00     movss   xmm0, dword ptr [rbx+8FB0h]
0000000180378559  F3 0F 58 83 40 8F 00 00     addss   xmm0, dword ptr [rbx+8F40h]
0000000180378561  F3 0F 59 8B 40 92 00 00     mulss   xmm1, dword ptr [rbx+9240h]
0000000180378569  F3 0F 59 83 50 92 00 00     mulss   xmm0, dword ptr [rbx+9250h]
0000000180378571  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180378575  F3 0F 10 8B 30 90 00 00     movss   xmm1, dword ptr [rbx+9030h]
000000018037857D  F3 0F 58 8B C0 8E 00 00     addss   xmm1, dword ptr [rbx+8EC0h]
0000000180378585  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180378589  0F 28 C2                    movaps  xmm0, xmm2
000000018037858C  F3 0F 59 8B 60 92 00 00     mulss   xmm1, dword ptr [rbx+9260h]
0000000180378594  F3 0F 11 A3 A0 90 00 00     movss   dword ptr [rbx+90A0h], xmm4
000000018037859C  F3 0F 59 83 B0 93 00 00     mulss   xmm0, dword ptr [rbx+93B0h]
00000001803785A4  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803785A8  F3 0F 58 C4                 addss   xmm0, xmm4
00000001803785AC  0F 28 DD                    movaps  xmm3, xmm5
00000001803785AF  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803785B3  0F 28 C3                    movaps  xmm0, xmm3
00000001803785B6  F3 0F 59 83 A0 93 00 00     mulss   xmm0, dword ptr [rbx+93A0h]
00000001803785BE  F3 0F 58 C2                 addss   xmm0, xmm2
00000001803785C2  F3 0F 11 83 90 90 00 00     movss   dword ptr [rbx+9090h], xmm0
00000001803785CA  F3 0F 10 93 F0 93 00 00     movss   xmm2, dword ptr [rbx+93F0h]
00000001803785D2  F3 0F 59 9B 80 90 00 00     mulss   xmm3, dword ptr [rbx+9080h]
00000001803785DA  F3 0F 5C E3                 subss   xmm4, xmm3
00000001803785DE  F3 0F 59 E2                 mulss   xmm4, xmm2
00000001803785E2  F3 0F 59 D5                 mulss   xmm2, xmm5
00000001803785E6  F3 0F 5C E2                 subss   xmm4, xmm2
00000001803785EA  F3 0F 58 E5                 addss   xmm4, xmm5
00000001803785EE  F3 0F 11 A3 70 8E 00 00     movss   dword ptr [rbx+8E70h], xmm4
00000001803785F6  F3 0F 11 A3 F0 88 00 00     movss   dword ptr [rbx+88F0h], xmm4
00000001803785FE  44 0F 2E AB E0 8C 01 00     ucomiss xmm13, dword ptr [rbx+18CE0h]
0000000180378606  75 28                       jnz     short loc_180378630
0000000180378608  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
0000000180378611  F3 0F 11 83 70 7C 00 00     movss   dword ptr [rbx+7C70h], xmm0
0000000180378619  C7 83 E0 8C 01 00 00 00 00 00  mov     dword ptr [rbx+18CE0h], 0
0000000180378623  0F 1F 40 00                 nop     dword ptr [rax+00h]
0000000180378627  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
0000000180378630  8B 83 E0 A4 00 00           mov     eax, [rbx+0A4E0h]
0000000180378636  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
000000018037863E  48 8B 0F                    mov     rcx, [rdi]
0000000180378641  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
0000000180378646  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
000000018037864B  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
0000000180378650  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
0000000180378655  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
000000018037865A  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
000000018037865F  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
0000000180378664  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
0000000180378669  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
000000018037866F  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
0000000180378675  89 01                       mov     [rcx], eax
0000000180378677  8B 83 E0 A4 00 00           mov     eax, [rbx+0A4E0h]
000000018037867D  48 8B 4F 08                 mov     rcx, [rdi+8]
0000000180378681  49 8B 5B 18                 mov     rbx, [r11+18h]
0000000180378685  89 01                       mov     [rcx], eax
0000000180378687  49 8B E3                    mov     rsp, r11
000000018037868A  5F                          pop     rdi
000000018037868B  C3                          retn
