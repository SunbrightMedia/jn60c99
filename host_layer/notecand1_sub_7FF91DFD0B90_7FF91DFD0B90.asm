; sub_7FF91DFD0B90 @ 0x7FF91DFD0B90 (RVA 0x7FF79DFD0B90)

00007FF91DFD0B90  48 8B C4                    mov     rax, rsp
00007FF91DFD0B93  48 89 58 10                 mov     [rax+10h], rbx
00007FF91DFD0B97  57                          push    rdi
00007FF91DFD0B98  48 81 EC C0 00 00 00        sub     rsp, 0C0h
00007FF91DFD0B9F  F3 0F 10 A1 60 53 00 00     movss   xmm4, dword ptr [rcx+5360h]
00007FF91DFD0BA7  48 8B FA                    mov     rdi, rdx
00007FF91DFD0BAA  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
00007FF91DFD0BAE  48 8B D9                    mov     rbx, rcx
00007FF91DFD0BB1  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
00007FF91DFD0BB5  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00007FF91DFD0BBA  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00007FF91DFD0BBF  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00007FF91DFD0BC4  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00007FF91DFD0BC9  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00007FF91DFD0BCE  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00007FF91DFD0BD4  F3 44 0F 10 2D D7 44 77 00  movss   xmm13, cs:dword_7FF91E7450B4
00007FF91DFD0BDD  44 0F 2E A9 C0 8C 01 00     ucomiss xmm13, dword ptr [rcx+18CC0h]
00007FF91DFD0BE5  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00007FF91DFD0BEB  45 0F 57 F6                 xorps   xmm14, xmm14
00007FF91DFD0BEF  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
00007FF91DFD0BF9  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00007FF91DFD0BFF  75 16                       jnz     short loc_7FF91DFD0C17
00007FF91DFD0C01  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
00007FF91DFD0C0A  0F 57 E4                    xorps   xmm4, xmm4
00007FF91DFD0C0D  C7 81 60 53 00 00 00 00 00 00  mov     dword ptr [rcx+5360h], 0
00007FF91DFD0C17  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
00007FF91DFD0C1F  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
00007FF91DFD0C27  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
00007FF91DFD0C2F  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
00007FF91DFD0C37  F3 0F 59 05 85 A1 61 00     mulss   xmm0, cs:dword_7FF91E5EADC4
00007FF91DFD0C3F  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
00007FF91DFD0C47  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
00007FF91DFD0C4F  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFD0C53  85 D2                       test    edx, edx
00007FF91DFD0C55  75 07                       jnz     short loc_7FF91DFD0C5E
00007FF91DFD0C57  BA 01 00 00 00              mov     edx, 1
00007FF91DFD0C5C  EB 24                       jmp     short loc_7FF91DFD0C82
00007FF91DFD0C5E  8B C2                       mov     eax, edx
00007FF91DFD0C60  25 00 00 20 00              and     eax, 200000h
00007FF91DFD0C65  0F BA E2 17                 bt      edx, 17h
00007FF91DFD0C69  73 08                       jnb     short loc_7FF91DFD0C73
00007FF91DFD0C6B  85 C0                       test    eax, eax
00007FF91DFD0C6D  75 0C                       jnz     short loc_7FF91DFD0C7B
00007FF91DFD0C6F  03 D2                       add     edx, edx
00007FF91DFD0C71  EB 0F                       jmp     short loc_7FF91DFD0C82
00007FF91DFD0C73  85 C0                       test    eax, eax
00007FF91DFD0C75  74 04                       jz      short loc_7FF91DFD0C7B
00007FF91DFD0C77  03 D2                       add     edx, edx
00007FF91DFD0C79  EB 07                       jmp     short loc_7FF91DFD0C82
00007FF91DFD0C7B  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
00007FF91DFD0C82  F3 0F 10 9B F0 52 00 00     movss   xmm3, dword ptr [rbx+52F0h]
00007FF91DFD0C8A  8B C2                       mov     eax, edx
00007FF91DFD0C8C  F3 0F 10 B3 D0 52 00 00     movss   xmm6, dword ptr [rbx+52D0h]
00007FF91DFD0C94  25 FF FF FF 00              and     eax, 0FFFFFFh
00007FF91DFD0C99  F3 44 0F 10 83 90 53 00 00  movss   xmm8, dword ptr [rbx+5390h]
00007FF91DFD0CA2  8B CA                       mov     ecx, edx
00007FF91DFD0CA4  F3 0F 10 BB A0 53 00 00     movss   xmm7, dword ptr [rbx+53A0h]
00007FF91DFD0CAC  81 CA 00 00 00 FF           or      edx, 0FF000000h
00007FF91DFD0CB2  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD0CB6  81 E1 00 00 00 01           and     ecx, 1000000h
00007FF91DFD0CBC  C7 83 D0 53 00 00 00 00 00 00  mov     dword ptr [rbx+53D0h], 0
00007FF91DFD0CC6  F3 0F 11 9B 00 53 00 00     movss   dword ptr [rbx+5300h], xmm3
00007FF91DFD0CCE  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFD0CD2  0F 44 D0                    cmovz   edx, eax
00007FF91DFD0CD5  F3 0F 11 B3 E0 52 00 00     movss   dword ptr [rbx+52E0h], xmm6
00007FF91DFD0CDD  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
00007FF91DFD0CE3  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
00007FF91DFD0CE9  8B 83 10 54 00 00           mov     eax, [rbx+5410h]
00007FF91DFD0CEF  66 0F 6E C2                 movd    xmm0, edx
00007FF91DFD0CF3  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFD0CF6  89 83 20 54 00 00           mov     [rbx+5420h], eax
00007FF91DFD0CFC  F3 0F 11 A3 80 53 00 00     movss   dword ptr [rbx+5380h], xmm4
00007FF91DFD0D04  F3 0F 59 05 64 9F 61 00     mulss   xmm0, cs:dword_7FF91E5EAC70
00007FF91DFD0D0C  F3 44 0F 11 83 B0 53 00 00  movss   dword ptr [rbx+53B0h], xmm8
00007FF91DFD0D15  F3 0F 11 BB C0 53 00 00     movss   dword ptr [rbx+53C0h], xmm7
00007FF91DFD0D1D  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
00007FF91DFD0D25  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
00007FF91DFD0D2D  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
00007FF91DFD0D35  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD0D39  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
00007FF91DFD0D41  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFD0D45  F3 0F 10 93 30 53 00 00     movss   xmm2, dword ptr [rbx+5330h]
00007FF91DFD0D4D  F3 0F 11 93 40 53 00 00     movss   dword ptr [rbx+5340h], xmm2
00007FF91DFD0D55  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD0D59  F3 0F 10 83 10 53 00 00     movss   xmm0, dword ptr [rbx+5310h]
00007FF91DFD0D61  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD0D65  F3 0F 11 83 20 53 00 00     movss   dword ptr [rbx+5320h], xmm0
00007FF91DFD0D6D  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFD0D71  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD0D74  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
00007FF91DFD0D7C  F3 0F 10 8B 50 53 00 00     movss   xmm1, dword ptr [rbx+5350h]
00007FF91DFD0D84  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD0D88  F3 0F 59 F2                 mulss   xmm6, xmm2
00007FF91DFD0D8C  F3 0F 11 8B 70 53 00 00     movss   dword ptr [rbx+5370h], xmm1
00007FF91DFD0D94  F3 0F 11 93 E0 53 00 00     movss   dword ptr [rbx+53E0h], xmm2
00007FF91DFD0D9C  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFD0DA0  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFD0DA3  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD0DA7  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD0DAB  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFD0DAF  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD0DB3  F3 0F 11 B3 F0 53 00 00     movss   dword ptr [rbx+53F0h], xmm6
00007FF91DFD0DBB  F3 0F 11 9B 00 54 00 00     movss   dword ptr [rbx+5400h], xmm3
00007FF91DFD0DC3  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD0DC6  F3 0F 58 9B 40 54 00 00     addss   xmm3, dword ptr [rbx+5440h]
00007FF91DFD0DCE  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFD0DD2  72 05                       jb      short loc_7FF91DFD0DD9
00007FF91DFD0DD4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD0DD7  EB 03                       jmp     short loc_7FF91DFD0DDC
00007FF91DFD0DD9  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFD0DDC  41 0F 2E CE                 ucomiss xmm1, xmm14
00007FF91DFD0DE0  F3 44 0F 10 3D FB 46 77 00  movss   xmm15, cs:dword_7FF91E7454E4
00007FF91DFD0DE9  75 06                       jnz     short loc_7FF91DFD0DF1
00007FF91DFD0DEB  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD0DEF  EB 04                       jmp     short loc_7FF91DFD0DF5
00007FF91DFD0DF1  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFD0DF5  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFD0DF9  F3 0F 11 AB 10 54 00 00     movss   dword ptr [rbx+5410h], xmm5
00007FF91DFD0E01  73 06                       jnb     short loc_7FF91DFD0E09
00007FF91DFD0E03  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD0E07  EB 06                       jmp     short loc_7FF91DFD0E0F
00007FF91DFD0E09  76 04                       jbe     short loc_7FF91DFD0E0F
00007FF91DFD0E0B  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFD0E0F  F3 0F 10 83 80 54 00 00     movss   xmm0, dword ptr [rbx+5480h]
00007FF91DFD0E17  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFD0E1C  F3 0F 10 93 20 55 00 00     movss   xmm2, dword ptr [rbx+5520h]
00007FF91DFD0E24  F3 0F 10 8B 90 54 00 00     movss   xmm1, dword ptr [rbx+5490h]
00007FF91DFD0E2C  8B 83 50 54 00 00           mov     eax, [rbx+5450h]
00007FF91DFD0E32  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFD0E35  F3 0F 10 A3 E0 54 00 00     movss   xmm4, dword ptr [rbx+54E0h]
00007FF91DFD0E3D  F3 0F 58 9B 30 55 00 00     addss   xmm3, dword ptr [rbx+5530h]
00007FF91DFD0E45  F2 44 0F 10 25 52 43 77 00  movsd   xmm12, cs:dbl_7FF91E7451A0
00007FF91DFD0E4E  F3 0F 11 AB 30 54 00 00     movss   dword ptr [rbx+5430h], xmm5
00007FF91DFD0E56  F3 0F 11 AB 50 54 00 00     movss   dword ptr [rbx+5450h], xmm5
00007FF91DFD0E5E  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFD0E62  89 83 60 54 00 00           mov     [rbx+5460h], eax
00007FF91DFD0E68  F3 0F 11 A3 F0 54 00 00     movss   dword ptr [rbx+54F0h], xmm4
00007FF91DFD0E70  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFD0E74  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD0E77  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD0E7B  F3 0F 10 8B C0 54 00 00     movss   xmm1, dword ptr [rbx+54C0h]
00007FF91DFD0E83  F3 0F 58 83 40 55 00 00     addss   xmm0, dword ptr [rbx+5540h]
00007FF91DFD0E8B  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFD0E90  F3 0F 5E C8                 divss   xmm1, xmm0
00007FF91DFD0E94  F3 0F 10 83 50 55 00 00     movss   xmm0, dword ptr [rbx+5550h]
00007FF91DFD0E9C  F3 0F 59 AB 70 54 00 00     mulss   xmm5, dword ptr [rbx+5470h]
00007FF91DFD0EA4  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD0EA8  F3 0F 10 93 B0 54 00 00     movss   xmm2, dword ptr [rbx+54B0h]
00007FF91DFD0EB0  F3 0F 11 AB 00 55 00 00     movss   dword ptr [rbx+5500h], xmm5
00007FF91DFD0EB8  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFD0EBC  F3 0F 10 8B D0 54 00 00     movss   xmm1, dword ptr [rbx+54D0h]
00007FF91DFD0EC4  F3 0F 58 D6                 addss   xmm2, xmm6
00007FF91DFD0EC8  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFD0ECC  F3 0F 11 93 B0 54 00 00     movss   dword ptr [rbx+54B0h], xmm2
00007FF91DFD0ED4  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD0ED8  F3 0F 11 93 C0 54 00 00     movss   dword ptr [rbx+54C0h], xmm2
00007FF91DFD0EE0  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFD0EE4  F3 0F 5C E6                 subss   xmm4, xmm6
00007FF91DFD0EE8  0F 54 25 A1 48 77 00        andps   xmm4, cs:xmmword_7FF91E745790
00007FF91DFD0EEF  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFD0EF3  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD0EF7  0F 83 E8 00 00 00           jnb     loc_7FF91DFD0FE5
00007FF91DFD0EFD  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFD0F00  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFD0F03  41 0F 2E EE                 ucomiss xmm5, xmm14
00007FF91DFD0F07  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD0F0B  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFD0F0E  F3 0F 11 83 D0 54 00 00     movss   dword ptr [rbx+54D0h], xmm0
00007FF91DFD0F16  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFD0F1A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD0F1E  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD0F22  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD0F26  75 03                       jnz     short loc_7FF91DFD0F2B
00007FF91DFD0F28  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFD0F2B  8B 83 90 55 00 00           mov     eax, [rbx+5590h]
00007FF91DFD0F31  48 8D 0D C8 F0 C8 FF        lea     rcx, cs:7FF91DC60000h
00007FF91DFD0F38  F3 0F 59 BB 80 55 00 00     mulss   xmm7, dword ptr [rbx+5580h]
00007FF91DFD0F40  89 83 A0 55 00 00           mov     [rbx+55A0h], eax
00007FF91DFD0F46  F3 44 0F 59 83 70 55 00 00  mulss   xmm8, dword ptr [rbx+5570h]
00007FF91DFD0F4F  F3 0F 10 83 B0 56 00 00     movss   xmm0, dword ptr [rbx+56B0h]
00007FF91DFD0F57  F3 0F 10 93 B0 55 00 00     movss   xmm2, dword ptr [rbx+55B0h]
00007FF91DFD0F5F  F3 44 0F 10 8B 10 56 00 00  movss   xmm9, dword ptr [rbx+5610h]
00007FF91DFD0F68  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD0F6D  F3 44 0F 10 83 F0 55 00 00  movss   xmm8, dword ptr [rbx+55F0h]
00007FF91DFD0F76  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFD0F7A  F3 0F 11 BB 90 55 00 00     movss   dword ptr [rbx+5590h], xmm7
00007FF91DFD0F82  F3 0F 10 BB D0 55 00 00     movss   xmm7, dword ptr [rbx+55D0h]
00007FF91DFD0F8A  F3 0F 11 8B E0 54 00 00     movss   dword ptr [rbx+54E0h], xmm1
00007FF91DFD0F92  F3 0F 11 8B 10 55 00 00     movss   dword ptr [rbx+5510h], xmm1
00007FF91DFD0F9A  F3 0F 10 8B 70 56 00 00     movss   xmm1, dword ptr [rbx+5670h]
00007FF91DFD0FA2  F3 0F 11 BB E0 55 00 00     movss   dword ptr [rbx+55E0h], xmm7
00007FF91DFD0FAA  F3 0F 11 93 C0 55 00 00     movss   dword ptr [rbx+55C0h], xmm2
00007FF91DFD0FB2  F3 44 0F 11 83 00 56 00 00  movss   dword ptr [rbx+5600h], xmm8
00007FF91DFD0FBB  F3 44 0F 11 8B 20 56 00 00  movss   dword ptr [rbx+5620h], xmm9
00007FF91DFD0FC4  F3 0F 11 8B 80 56 00 00     movss   dword ptr [rbx+5680h], xmm1
00007FF91DFD0FCC  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFD0FCF  7D 2F                       jge     short loc_7FF91DFD1000
00007FF91DFD0FD1  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFD0FD6  F7 D0                       not     eax
00007FF91DFD0FD8  48 98                       cdqe
00007FF91DFD0FDA  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD0FE3  EB 47                       jmp     short loc_7FF91DFD102C
00007FF91DFD0FE5  F3 0F 58 8B 60 55 00 00     addss   xmm1, dword ptr [rbx+5560h]
00007FF91DFD0FED  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFD0FF1  0F 82 09 FF FF FF           jb      loc_7FF91DFD0F00
00007FF91DFD0FF7  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFD0FFB  E9 03 FF FF FF              jmp     loc_7FF91DFD0F03
00007FF91DFD1000  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFD1003  7E 07                       jle     short loc_7FF91DFD100C
00007FF91DFD1005  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFD100A  EB 15                       jmp     short loc_7FF91DFD1021
00007FF91DFD100C  85 C0                       test    eax, eax
00007FF91DFD100E  79 0F                       jns     short loc_7FF91DFD101F
00007FF91DFD1010  F7 D0                       not     eax
00007FF91DFD1012  48 98                       cdqe
00007FF91DFD1014  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD101D  EB 0D                       jmp     short loc_7FF91DFD102C
00007FF91DFD101F  7E 0B                       jle     short loc_7FF91DFD102C
00007FF91DFD1021  48 98                       cdqe
00007FF91DFD1023  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFD102C  0F 57 05 8D 47 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD1033  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFD1037  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFD103A  7D 14                       jge     short loc_7FF91DFD1050
00007FF91DFD103C  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFD1041  F7 D0                       not     eax
00007FF91DFD1043  48 98                       cdqe
00007FF91DFD1045  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD104E  EB 2C                       jmp     short loc_7FF91DFD107C
00007FF91DFD1050  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFD1053  7E 07                       jle     short loc_7FF91DFD105C
00007FF91DFD1055  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFD105A  EB 15                       jmp     short loc_7FF91DFD1071
00007FF91DFD105C  85 C0                       test    eax, eax
00007FF91DFD105E  79 0F                       jns     short loc_7FF91DFD106F
00007FF91DFD1060  F7 D0                       not     eax
00007FF91DFD1062  48 98                       cdqe
00007FF91DFD1064  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD106D  EB 0D                       jmp     short loc_7FF91DFD107C
00007FF91DFD106F  7E 0B                       jle     short loc_7FF91DFD107C
00007FF91DFD1071  48 98                       cdqe
00007FF91DFD1073  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFD107C  F3 0F 10 83 30 56 00 00     movss   xmm0, dword ptr [rbx+5630h]
00007FF91DFD1084  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFD1088  F3 0F 59 93 A0 56 00 00     mulss   xmm2, dword ptr [rbx+56A0h]
00007FF91DFD1090  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD1094  F3 0F 10 8B 60 56 00 00     movss   xmm1, dword ptr [rbx+5660h]
00007FF91DFD109C  F3 0F 11 93 70 56 00 00     movss   dword ptr [rbx+5670h], xmm2
00007FF91DFD10A4  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD10A8  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD10AC  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD10B0  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD10B4  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFD10B8  76 05                       jbe     short loc_7FF91DFD10BF
00007FF91DFD10BA  0F 5A C2                    cvtps2pd xmm0, xmm2
00007FF91DFD10BD  EB 03                       jmp     short loc_7FF91DFD10C2
00007FF91DFD10BF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD10C2  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFD10C6  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFD10CA  72 06                       jb      short loc_7FF91DFD10D2
00007FF91DFD10CC  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFD10D0  EB 03                       jmp     short loc_7FF91DFD10D5
00007FF91DFD10D2  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFD10D5  F3 0F 10 B3 40 56 00 00     movss   xmm6, dword ptr [rbx+5640h]
00007FF91DFD10DD  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD10E1  F3 0F 59 83 D0 56 00 00     mulss   xmm0, dword ptr [rbx+56D0h]; X
00007FF91DFD10E9  E8 52 E6 37 00              call    expf
00007FF91DFD10EE  F3 0F 59 83 C0 56 00 00     mulss   xmm0, dword ptr [rbx+56C0h]
00007FF91DFD10F6  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFD10F9  8B 83 40 58 00 00           mov     eax, [rbx+5840h]
00007FF91DFD10FF  F3 0F 59 8B 50 56 00 00     mulss   xmm1, dword ptr [rbx+5650h]
00007FF91DFD1107  89 83 50 58 00 00           mov     [rbx+5850h], eax
00007FF91DFD110D  F3 0F 58 83 E0 56 00 00     addss   xmm0, dword ptr [rbx+56E0h]
00007FF91DFD1115  8B 83 60 58 00 00           mov     eax, [rbx+5860h]
00007FF91DFD111B  F3 0F 10 9B 00 58 00 00     movss   xmm3, dword ptr [rbx+5800h]
00007FF91DFD1123  F3 0F 59 BB 90 59 00 00     mulss   xmm7, dword ptr [rbx+5990h]
00007FF91DFD112B  89 83 70 58 00 00           mov     [rbx+5870h], eax
00007FF91DFD1131  8B 83 80 58 00 00           mov     eax, [rbx+5880h]
00007FF91DFD1137  F3 0F 10 93 F0 57 00 00     movss   xmm2, dword ptr [rbx+57F0h]
00007FF91DFD113F  F3 0F 10 A3 20 58 00 00     movss   xmm4, dword ptr [rbx+5820h]
00007FF91DFD1147  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFD114B  89 83 90 58 00 00           mov     [rbx+5890h], eax
00007FF91DFD1151  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
00007FF91DFD1157  F3 0F 11 9B 10 58 00 00     movss   dword ptr [rbx+5810h], xmm3
00007FF91DFD115F  F3 0F 5C CE                 subss   xmm1, xmm6
00007FF91DFD1163  F3 0F 11 93 00 58 00 00     movss   dword ptr [rbx+5800h], xmm2
00007FF91DFD116B  F3 0F 11 A3 30 58 00 00     movss   dword ptr [rbx+5830h], xmm4
00007FF91DFD1173  F3 44 0F 11 83 C0 57 00 00  movss   dword ptr [rbx+57C0h], xmm8
00007FF91DFD117C  F3 44 0F 11 8B D0 57 00 00  movss   dword ptr [rbx+57D0h], xmm9
00007FF91DFD1185  89 83 B0 57 00 00           mov     [rbx+57B0h], eax
00007FF91DFD118B  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD118F  F3 0F 10 83 60 59 00 00     movss   xmm0, dword ptr [rbx+5960h]
00007FF91DFD1197  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFD119B  F3 0F 11 83 50 59 00 00     movss   dword ptr [rbx+5950h], xmm0
00007FF91DFD11A3  F3 0F 11 8B 90 56 00 00     movss   dword ptr [rbx+5690h], xmm1
00007FF91DFD11AB  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFD11AF  73 06                       jnb     short loc_7FF91DFD11B7
00007FF91DFD11B1  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD11B5  EB 05                       jmp     short loc_7FF91DFD11BC
00007FF91DFD11B7  F3 41 0F 5D FD              minss   xmm7, xmm13
00007FF91DFD11BC  F3 0F 59 0D FC 9B 61 00     mulss   xmm1, cs:dword_7FF91E5EADC0
00007FF91DFD11C4  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD11C8  F3 0F 10 B3 70 5A 00 00     movss   xmm6, dword ptr [rbx+5A70h]
00007FF91DFD11D0  F3 0F 5C C3                 subss   xmm0, xmm3
00007FF91DFD11D4  F3 0F 11 BB F0 57 00 00     movss   dword ptr [rbx+57F0h], xmm7
00007FF91DFD11DC  F3 0F 5D F1                 minss   xmm6, xmm1
00007FF91DFD11E0  F3 0F 59 83 A0 59 00 00     mulss   xmm0, dword ptr [rbx+59A0h]
00007FF91DFD11E8  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFD11EC  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFD11F0  73 06                       jnb     short loc_7FF91DFD11F8
00007FF91DFD11F2  41 0F 28 C7                 movaps  xmm0, xmm15
00007FF91DFD11F6  EB 05                       jmp     short loc_7FF91DFD11FD
00007FF91DFD11F8  F3 41 0F 5D C5              minss   xmm0, xmm13
00007FF91DFD11FD  F3 0F 59 B3 80 5A 00 00     mulss   xmm6, dword ptr [rbx+5A80h]
00007FF91DFD1205  F3 0F 5C D7                 subss   xmm2, xmm7
00007FF91DFD1209  F3 0F 11 B3 A0 58 00 00     movss   dword ptr [rbx+58A0h], xmm6
00007FF91DFD1211  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFD1215  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFD1219  73 03                       jnb     short loc_7FF91DFD121E
00007FF91DFD121B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD121E  F3 0F 10 8B 70 59 00 00     movss   xmm1, dword ptr [rbx+5970h]
00007FF91DFD1226  F3 44 0F 10 9B B0 57 00 00  movss   xmm11, dword ptr [rbx+57B0h]
00007FF91DFD122F  F3 0F 11 83 00 58 00 00     movss   dword ptr [rbx+5800h], xmm0
00007FF91DFD1237  F3 0F 58 83 00 5B 00 00     addss   xmm0, dword ptr [rbx+5B00h]
00007FF91DFD123F  72 04                       jb      short loc_7FF91DFD1245
00007FF91DFD1241  41 0F 28 CD                 movaps  xmm1, xmm13
00007FF91DFD1245  F3 0F 59 83 F0 5A 00 00     mulss   xmm0, dword ptr [rbx+5AF0h]
00007FF91DFD124D  41 0F 28 FB                 movaps  xmm7, xmm11
00007FF91DFD1251  F3 0F 10 93 50 58 00 00     movss   xmm2, dword ptr [rbx+5850h]
00007FF91DFD1259  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFD125D  F3 0F 5C FA                 subss   xmm7, xmm2
00007FF91DFD1261  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD1265  F3 0F 59 B3 80 59 00 00     mulss   xmm6, dword ptr [rbx+5980h]
00007FF91DFD126D  76 05                       jbe     short loc_7FF91DFD1274
00007FF91DFD126F  0F 5A C8                    cvtps2pd xmm1, xmm0
00007FF91DFD1272  EB 03                       jmp     short loc_7FF91DFD1277
00007FF91DFD1274  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFD1277  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD127B  F3 0F 59 BB C0 5B 00 00     mulss   xmm7, dword ptr [rbx+5BC0h]
00007FF91DFD1283  F3 44 0F 10 0D 5C 3F 77 00  movss   xmm9, cs:flt_7FF91E7451E8
00007FF91DFD128C  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
00007FF91DFD1290  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFD1294  F3 0F 11 BB 40 58 00 00     movss   dword ptr [rbx+5840h], xmm7
00007FF91DFD129C  F3 0F 11 83 E0 57 00 00     movss   dword ptr [rbx+57E0h], xmm0
00007FF91DFD12A4  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFD12A8  F3 0F 59 BB B0 5B 00 00     mulss   xmm7, dword ptr [rbx+5BB0h]
00007FF91DFD12B0  F3 0F 10 8B 30 5A 00 00     movss   xmm1, dword ptr [rbx+5A30h]
00007FF91DFD12B8  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD12BC  F3 0F 59 F9                 mulss   xmm7, xmm1
00007FF91DFD12C0  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFD12C4  F3 0F 10 83 30 58 00 00     movss   xmm0, dword ptr [rbx+5830h]
00007FF91DFD12CC  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
00007FF91DFD12D5  F3 41 0F 58 FB              addss   xmm7, xmm11
00007FF91DFD12DA  76 1B                       jbe     short loc_7FF91DFD12F7
00007FF91DFD12DC  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD12E1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD12E5  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD12E8  E8 EB E1 37 00              call    fmodf
00007FF91DFD12ED  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD12F0  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD12F5  EB 1F                       jmp     short loc_7FF91DFD1316
00007FF91DFD12F7  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD12FB  73 19                       jnb     short loc_7FF91DFD1316
00007FF91DFD12FD  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD1302  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD1306  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD1309  E8 CA E1 37 00              call    fmodf
00007FF91DFD130E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD1311  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD1316  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
00007FF91DFD131F  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD1322  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD1326  F3 44 0F 10 83 70 58 00 00  movss   xmm8, dword ptr [rbx+5870h]
00007FF91DFD132F  F3 0F 11 B3 20 58 00 00     movss   dword ptr [rbx+5820h], xmm6
00007FF91DFD1337  F3 0F 59 BB A0 5B 00 00     mulss   xmm7, dword ptr [rbx+5BA0h]
00007FF91DFD133F  F3 0F 58 83 10 5B 00 00     addss   xmm0, dword ptr [rbx+5B10h]
00007FF91DFD1347  F3 0F 11 BB A0 57 00 00     movss   dword ptr [rbx+57A0h], xmm7
00007FF91DFD134F  73 0A                       jnb     short loc_7FF91DFD135B
00007FF91DFD1351  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFD1355  76 04                       jbe     short loc_7FF91DFD135B
00007FF91DFD1357  45 0F 28 C3                 movaps  xmm8, xmm11
00007FF91DFD135B  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFD135F  76 15                       jbe     short loc_7FF91DFD1376
00007FF91DFD1361  F3 41 0F 58 C5              addss   xmm0, xmm13; X
00007FF91DFD1366  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD136A  E8 69 E1 37 00              call    fmodf
00007FF91DFD136F  F3 41 0F 5C C5              subss   xmm0, xmm13
00007FF91DFD1374  EB 19                       jmp     short loc_7FF91DFD138F
00007FF91DFD1376  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFD137A  73 13                       jnb     short loc_7FF91DFD138F
00007FF91DFD137C  F3 41 0F 5C C5              subss   xmm0, xmm13; X
00007FF91DFD1381  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD1385  E8 4E E1 37 00              call    fmodf
00007FF91DFD138A  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD138F  F3 44 0F 10 1D 28 44 77 00  movss   xmm11, dword ptr cs:xmmword_7FF91E7457C0
00007FF91DFD1398  F3 44 0F 11 83 60 58 00 00  movss   dword ptr [rbx+5860h], xmm8
00007FF91DFD13A1  F3 0F 59 83 50 5B 00 00     mulss   xmm0, dword ptr [rbx+5B50h]
00007FF91DFD13A9  F3 44 0F 59 83 90 5B 00 00  mulss   xmm8, dword ptr [rbx+5B90h]
00007FF91DFD13B2  F3 0F 58 83 D0 5B 00 00     addss   xmm0, dword ptr [rbx+5BD0h]
00007FF91DFD13BA  F3 0F 11 83 B0 58 00 00     movss   dword ptr [rbx+58B0h], xmm0
00007FF91DFD13C2  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFD13C6  F3 44 0F 11 83 00 59 00 00  movss   dword ptr [rbx+5900h], xmm8
00007FF91DFD13CF  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFD13D3  F3 44 0F 58 83 30 5B 00 00  addss   xmm8, dword ptr [rbx+5B30h]
00007FF91DFD13DC  F3 0F 11 83 C0 58 00 00     movss   dword ptr [rbx+58C0h], xmm0
00007FF91DFD13E4  45 0F 2F C5                 comiss  xmm8, xmm13
00007FF91DFD13E8  76 1D                       jbe     short loc_7FF91DFD1407
00007FF91DFD13EA  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD13EF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD13F3  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFD13F7  E8 DC E0 37 00              call    fmodf
00007FF91DFD13FC  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD1400  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFD1405  EB 21                       jmp     short loc_7FF91DFD1428
00007FF91DFD1407  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFD140B  73 1B                       jnb     short loc_7FF91DFD1428
00007FF91DFD140D  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFD1412  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD1416  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFD141A  E8 B9 E0 37 00              call    fmodf
00007FF91DFD141F  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD1423  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD1428  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD142B  F3 0F 58 BB 20 5B 00 00     addss   xmm7, dword ptr [rbx+5B20h]
00007FF91DFD1433  41 0F 2F FD                 comiss  xmm7, xmm13
00007FF91DFD1437  76 1B                       jbe     short loc_7FF91DFD1454
00007FF91DFD1439  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD143E  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD1442  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFD1445  E8 8E E0 37 00              call    fmodf
00007FF91DFD144A  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFD144D  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD1452  EB 1F                       jmp     short loc_7FF91DFD1473
00007FF91DFD1454  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFD1458  73 19                       jnb     short loc_7FF91DFD1473
00007FF91DFD145A  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD145F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD1463  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFD1466  E8 6D E0 37 00              call    fmodf
00007FF91DFD146B  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFD146E  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD1473  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFD1477  E8 44 7B FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD147C  F3 0F 58 BB E0 5B 00 00     addss   xmm7, dword ptr [rbx+5BE0h]
00007FF91DFD1484  F3 0F 59 83 70 5B 00 00     mulss   xmm0, dword ptr [rbx+5B70h]
00007FF91DFD148C  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD1490  73 06                       jnb     short loc_7FF91DFD1498
00007FF91DFD1492  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD1496  EB 06                       jmp     short loc_7FF91DFD149E
00007FF91DFD1498  76 04                       jbe     short loc_7FF91DFD149E
00007FF91DFD149A  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD149E  F3 0F 58 B3 40 5B 00 00     addss   xmm6, dword ptr [rbx+5B40h]
00007FF91DFD14A6  F3 0F 11 83 E0 58 00 00     movss   dword ptr [rbx+58E0h], xmm0
00007FF91DFD14AE  F3 0F 11 BB 40 59 00 00     movss   dword ptr [rbx+5940h], xmm7
00007FF91DFD14B6  F3 0F 59 BB 60 5B 00 00     mulss   xmm7, dword ptr [rbx+5B60h]
00007FF91DFD14BE  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD14C2  F3 0F 58 BB F0 5B 00 00     addss   xmm7, dword ptr [rbx+5BF0h]
00007FF91DFD14CA  76 1B                       jbe     short loc_7FF91DFD14E7
00007FF91DFD14CC  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD14D1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD14D5  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD14D8  E8 FB DF 37 00              call    fmodf
00007FF91DFD14DD  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD14E0  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD14E5  EB 1F                       jmp     short loc_7FF91DFD1506
00007FF91DFD14E7  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD14EB  73 19                       jnb     short loc_7FF91DFD1506
00007FF91DFD14ED  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD14F2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD14F6  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD14F9  E8 DA DF 37 00              call    fmodf
00007FF91DFD14FE  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD1501  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD1506  0F 54 35 83 42 77 00        andps   xmm6, cs:xmmword_7FF91E745790
00007FF91DFD150D  F3 0F 11 BB D0 58 00 00     movss   dword ptr [rbx+58D0h], xmm7
00007FF91DFD1515  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFD1518  F3 0F 10 9B 10 5A 00 00     movss   xmm3, dword ptr [rbx+5A10h]
00007FF91DFD1520  0F 28 D6                    movaps  xmm2, xmm6
00007FF91DFD1523  F3 0F 59 93 A0 5A 00 00     mulss   xmm2, dword ptr [rbx+5AA0h]
00007FF91DFD152B  F3 0F 59 9B 00 59 00 00     mulss   xmm3, dword ptr [rbx+5900h]
00007FF91DFD1533  F3 0F 58 93 90 5A 00 00     addss   xmm2, dword ptr [rbx+5A90h]
00007FF91DFD153B  F3 0F 10 8B 00 5A 00 00     movss   xmm1, dword ptr [rbx+5A00h]
00007FF91DFD1543  F3 0F 59 8B C0 58 00 00     mulss   xmm1, dword ptr [rbx+58C0h]
00007FF91DFD154B  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFD154F  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFD1552  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFD1556  F3 0F 59 83 B0 5A 00 00     mulss   xmm0, dword ptr [rbx+5AB0h]
00007FF91DFD155E  F3 0F 59 F4                 mulss   xmm6, xmm4
00007FF91DFD1562  F3 0F 59 A3 C0 5A 00 00     mulss   xmm4, dword ptr [rbx+5AC0h]
00007FF91DFD156A  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD156E  F3 0F 59 B3 D0 5A 00 00     mulss   xmm6, dword ptr [rbx+5AD0h]
00007FF91DFD1576  F3 0F 10 83 F0 59 00 00     movss   xmm0, dword ptr [rbx+59F0h]
00007FF91DFD157E  F3 0F 59 83 B0 58 00 00     mulss   xmm0, dword ptr [rbx+58B0h]
00007FF91DFD1586  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFD158A  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD158E  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFD1592  F3 0F 10 A3 D0 59 00 00     movss   xmm4, dword ptr [rbx+59D0h]
00007FF91DFD159A  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD159E  F3 0F 58 B3 E0 5A 00 00     addss   xmm6, dword ptr [rbx+5AE0h]
00007FF91DFD15A6  F3 0F 59 B3 80 5B 00 00     mulss   xmm6, dword ptr [rbx+5B80h]
00007FF91DFD15AE  F3 0F 11 B3 F0 58 00 00     movss   dword ptr [rbx+58F0h], xmm6
00007FF91DFD15B6  F3 0F 59 A3 E0 58 00 00     mulss   xmm4, dword ptr [rbx+58E0h]
00007FF91DFD15BE  F3 0F 10 8B B0 59 00 00     movss   xmm1, dword ptr [rbx+59B0h]
00007FF91DFD15C6  F3 0F 10 83 E0 59 00 00     movss   xmm0, dword ptr [rbx+59E0h]
00007FF91DFD15CE  F3 0F 59 83 D0 58 00 00     mulss   xmm0, dword ptr [rbx+58D0h]
00007FF91DFD15D6  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD15DA  F3 0F 10 93 40 5A 00 00     movss   xmm2, dword ptr [rbx+5A40h]
00007FF91DFD15E2  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFD15E5  F3 0F 59 9B E0 57 00 00     mulss   xmm3, dword ptr [rbx+57E0h]
00007FF91DFD15ED  F3 0F 59 B3 C0 59 00 00     mulss   xmm6, dword ptr [rbx+59C0h]
00007FF91DFD15F5  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD15F9  F3 0F 10 83 20 5A 00 00     movss   xmm0, dword ptr [rbx+5A20h]
00007FF91DFD1601  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFD1605  F3 0F 59 83 A0 57 00 00     mulss   xmm0, dword ptr [rbx+57A0h]
00007FF91DFD160D  F3 0F 58 E6                 addss   xmm4, xmm6
00007FF91DFD1611  F3 41 0F 58 DD              addss   xmm3, xmm13
00007FF91DFD1616  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD161A  F3 0F 11 9B 10 59 00 00     movss   dword ptr [rbx+5910h], xmm3
00007FF91DFD1622  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD1626  F3 0F 11 A3 30 59 00 00     movss   dword ptr [rbx+5930h], xmm4
00007FF91DFD162E  F3 0F 10 8B 60 5A 00 00     movss   xmm1, dword ptr [rbx+5A60h]
00007FF91DFD1636  F3 0F 59 8B D0 57 00 00     mulss   xmm1, dword ptr [rbx+57D0h]
00007FF91DFD163E  F3 0F 10 83 50 5A 00 00     movss   xmm0, dword ptr [rbx+5A50h]
00007FF91DFD1646  F3 0F 59 83 C0 57 00 00     mulss   xmm0, dword ptr [rbx+57C0h]
00007FF91DFD164E  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD1652  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD1656  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD165A  F3 0F 11 8B 20 59 00 00     movss   dword ptr [rbx+5920h], xmm1
00007FF91DFD1662  F3 0F 10 83 30 59 00 00     movss   xmm0, dword ptr [rbx+5930h]
00007FF91DFD166A  8B 83 40 59 00 00           mov     eax, [rbx+5940h]
00007FF91DFD1670  89 83 00 5C 00 00           mov     [rbx+5C00h], eax
00007FF91DFD1676  F3 0F 11 83 10 5C 00 00     movss   dword ptr [rbx+5C10h], xmm0
00007FF91DFD167E  44 0F 2F B3 40 59 00 00     comiss  xmm14, dword ptr [rbx+5940h]
00007FF91DFD1686  F3 0F 10 8B 50 54 00 00     movss   xmm1, dword ptr [rbx+5450h]
00007FF91DFD168E  F3 0F 10 93 20 5C 00 00     movss   xmm2, dword ptr [rbx+5C20h]
00007FF91DFD1696  73 06                       jnb     short loc_7FF91DFD169E
00007FF91DFD1698  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD169C  EB 03                       jmp     short loc_7FF91DFD16A1
00007FF91DFD169E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD16A1  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFD16A5  75 04                       jnz     short loc_7FF91DFD16AB
00007FF91DFD16A7  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD16AB  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD16AF  F3 0F 11 8B 30 5C 00 00     movss   dword ptr [rbx+5C30h], xmm1
00007FF91DFD16B7  8B 83 40 5C 00 00           mov     eax, [rbx+5C40h]
00007FF91DFD16BD  89 83 50 5C 00 00           mov     [rbx+5C50h], eax
00007FF91DFD16C3  8B 83 70 5C 00 00           mov     eax, [rbx+5C70h]
00007FF91DFD16C9  89 83 80 5C 00 00           mov     [rbx+5C80h], eax
00007FF91DFD16CF  8B 83 60 5C 00 00           mov     eax, [rbx+5C60h]
00007FF91DFD16D5  89 83 70 5C 00 00           mov     [rbx+5C70h], eax
00007FF91DFD16DB  8B 83 90 5C 00 00           mov     eax, [rbx+5C90h]
00007FF91DFD16E1  89 83 A0 5C 00 00           mov     [rbx+5CA0h], eax
00007FF91DFD16E7  8B 83 C0 5C 00 00           mov     eax, [rbx+5CC0h]
00007FF91DFD16ED  89 83 D0 5C 00 00           mov     [rbx+5CD0h], eax
00007FF91DFD16F3  F3 0F 10 83 70 5D 00 00     movss   xmm0, dword ptr [rbx+5D70h]
00007FF91DFD16FB  F3 0F 58 8B 50 5D 00 00     addss   xmm1, dword ptr [rbx+5D50h]
00007FF91DFD1703  F3 0F 59 83 80 5C 00 00     mulss   xmm0, dword ptr [rbx+5C80h]
00007FF91DFD170B  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD170F  F3 0F 58 83 50 5C 00 00     addss   xmm0, dword ptr [rbx+5C50h]
00007FF91DFD1717  73 06                       jnb     short loc_7FF91DFD171F
00007FF91DFD1719  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFD171D  EB 04                       jmp     short loc_7FF91DFD1723
00007FF91DFD171F  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFD1723  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFD1727  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFD172C  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFD172F  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFD1733  F3 0F 11 BB 60 5C 00 00     movss   dword ptr [rbx+5C60h], xmm7
00007FF91DFD173B  0F 28 E7                    movaps  xmm4, xmm7
00007FF91DFD173E  F3 0F 10 9B 40 5D 00 00     movss   xmm3, dword ptr [rbx+5D40h]
00007FF91DFD1746  F3 0F 10 93 90 5D 00 00     movss   xmm2, dword ptr [rbx+5D90h]
00007FF91DFD174E  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD1751  F3 0F 59 8B B0 5D 00 00     mulss   xmm1, dword ptr [rbx+5DB0h]
00007FF91DFD1759  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD175C  F3 0F 58 A3 60 5D 00 00     addss   xmm4, dword ptr [rbx+5D60h]
00007FF91DFD1764  F3 0F 5C BB 70 5C 00 00     subss   xmm7, dword ptr [rbx+5C70h]
00007FF91DFD176C  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD1770  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFD1774  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD1778  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD177C  F3 0F 11 8B B0 5C 00 00     movss   dword ptr [rbx+5CB0h], xmm1
00007FF91DFD1784  72 06                       jb      short loc_7FF91DFD178C
00007FF91DFD1786  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD178A  EB 03                       jmp     short loc_7FF91DFD178F
00007FF91DFD178C  0F 57 F6                    xorps   xmm6, xmm6
00007FF91DFD178F  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD1793  F3 0F 10 83 10 5D 00 00     movss   xmm0, dword ptr [rbx+5D10h]
00007FF91DFD179B  73 03                       jnb     short loc_7FF91DFD17A0
00007FF91DFD179D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFD17A0  F3 0F 59 83 90 5D 00 00     mulss   xmm0, dword ptr [rbx+5D90h]
00007FF91DFD17A8  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFD17AB  F3 0F 10 93 00 5D 00 00     movss   xmm2, dword ptr [rbx+5D00h]
00007FF91DFD17B3  F3 44 0F 10 0D A0 37 77 00  movss   xmm9, cs:dword_7FF91E744F5C
00007FF91DFD17BC  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFD17C0  F3 0F 11 B3 70 5C 00 00     movss   dword ptr [rbx+5C70h], xmm6
00007FF91DFD17C8  F3 0F 10 8B A0 5D 00 00     movss   xmm1, dword ptr [rbx+5DA0h]
00007FF91DFD17D0  F3 0F 10 BB 20 5D 00 00     movss   xmm7, dword ptr [rbx+5D20h]
00007FF91DFD17D8  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD17DB  F3 0F 10 A3 A0 5C 00 00     movss   xmm4, dword ptr [rbx+5CA0h]
00007FF91DFD17E3  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD17E7  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFD17EC  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD17F0  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFD17F5  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD17F9  F3 0F 59 FE                 mulss   xmm7, xmm6
00007FF91DFD17FD  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFD1801  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD1805  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFD1809  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD180C  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFD1810  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD1814  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD1818  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFD181C  76 0B                       jbe     short loc_7FF91DFD1829
00007FF91DFD181E  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD1821  F3 0F 58 9B B0 5C 00 00     addss   xmm3, dword ptr [rbx+5CB0h]
00007FF91DFD1829  F3 0F 10 83 90 5D 00 00     movss   xmm0, dword ptr [rbx+5D90h]
00007FF91DFD1831  F3 0F 10 A3 50 5C 00 00     movss   xmm4, dword ptr [rbx+5C50h]
00007FF91DFD1839  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFD183D  F3 0F 11 83 90 5C 00 00     movss   dword ptr [rbx+5C90h], xmm0
00007FF91DFD1845  F3 0F 10 8B D0 5C 00 00     movss   xmm1, dword ptr [rbx+5CD0h]
00007FF91DFD184D  F3 0F 10 9B 30 5D 00 00     movss   xmm3, dword ptr [rbx+5D30h]
00007FF91DFD1855  F3 0F 59 AB 80 5D 00 00     mulss   xmm5, dword ptr [rbx+5D80h]
00007FF91DFD185D  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFD1862  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFD1866  F3 0F 10 83 C0 5D 00 00     movss   xmm0, dword ptr [rbx+5DC0h]
00007FF91DFD186E  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD1873  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFD1876  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD187A  F3 0F 58 EE                 addss   xmm5, xmm6
00007FF91DFD187E  F3 0F 59 D7                 mulss   xmm2, xmm7
00007FF91DFD1882  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFD1886  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD188A  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD188E  F3 0F 11 93 C0 5C 00 00     movss   dword ptr [rbx+5CC0h], xmm2
00007FF91DFD1896  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFD189B  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFD18A0  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD18A4  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD18A8  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD18AC  F3 0F 11 9B 40 5C 00 00     movss   dword ptr [rbx+5C40h], xmm3
00007FF91DFD18B4  F3 0F 59 9B D0 5D 00 00     mulss   xmm3, dword ptr [rbx+5DD0h]
00007FF91DFD18BC  F3 0F 59 9B E0 5D 00 00     mulss   xmm3, dword ptr [rbx+5DE0h]
00007FF91DFD18C4  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD18C7  F3 0F 59 83 F0 5D 00 00     mulss   xmm0, dword ptr [rbx+5DF0h]
00007FF91DFD18CF  F3 0F 11 9B E0 5C 00 00     movss   dword ptr [rbx+5CE0h], xmm3
00007FF91DFD18D7  F3 0F 11 83 F0 5C 00 00     movss   dword ptr [rbx+5CF0h], xmm0
00007FF91DFD18DF  44 0F 2F B3 40 59 00 00     comiss  xmm14, dword ptr [rbx+5940h]
00007FF91DFD18E7  F3 0F 10 8B 50 54 00 00     movss   xmm1, dword ptr [rbx+5450h]
00007FF91DFD18EF  F3 0F 10 93 00 5E 00 00     movss   xmm2, dword ptr [rbx+5E00h]
00007FF91DFD18F7  73 06                       jnb     short loc_7FF91DFD18FF
00007FF91DFD18F9  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD18FD  EB 03                       jmp     short loc_7FF91DFD1902
00007FF91DFD18FF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD1902  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFD1906  75 04                       jnz     short loc_7FF91DFD190C
00007FF91DFD1908  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD190C  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD1910  F3 0F 11 8B 10 5E 00 00     movss   dword ptr [rbx+5E10h], xmm1
00007FF91DFD1918  8B 83 20 5E 00 00           mov     eax, [rbx+5E20h]
00007FF91DFD191E  89 83 30 5E 00 00           mov     [rbx+5E30h], eax
00007FF91DFD1924  8B 83 50 5E 00 00           mov     eax, [rbx+5E50h]
00007FF91DFD192A  89 83 60 5E 00 00           mov     [rbx+5E60h], eax
00007FF91DFD1930  8B 83 40 5E 00 00           mov     eax, [rbx+5E40h]
00007FF91DFD1936  89 83 50 5E 00 00           mov     [rbx+5E50h], eax
00007FF91DFD193C  8B 83 70 5E 00 00           mov     eax, [rbx+5E70h]
00007FF91DFD1942  89 83 80 5E 00 00           mov     [rbx+5E80h], eax
00007FF91DFD1948  8B 83 A0 5E 00 00           mov     eax, [rbx+5EA0h]
00007FF91DFD194E  89 83 B0 5E 00 00           mov     [rbx+5EB0h], eax
00007FF91DFD1954  F3 0F 10 83 50 5F 00 00     movss   xmm0, dword ptr [rbx+5F50h]
00007FF91DFD195C  F3 0F 58 8B 30 5F 00 00     addss   xmm1, dword ptr [rbx+5F30h]
00007FF91DFD1964  F3 0F 59 83 60 5E 00 00     mulss   xmm0, dword ptr [rbx+5E60h]
00007FF91DFD196C  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD1970  F3 0F 58 83 30 5E 00 00     addss   xmm0, dword ptr [rbx+5E30h]
00007FF91DFD1978  73 06                       jnb     short loc_7FF91DFD1980
00007FF91DFD197A  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFD197E  EB 04                       jmp     short loc_7FF91DFD1984
00007FF91DFD1980  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFD1984  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFD1988  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFD198D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFD1990  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFD1994  F3 0F 11 B3 40 5E 00 00     movss   dword ptr [rbx+5E40h], xmm6
00007FF91DFD199C  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFD199F  F3 0F 10 9B 20 5F 00 00     movss   xmm3, dword ptr [rbx+5F20h]
00007FF91DFD19A7  F3 0F 10 93 70 5F 00 00     movss   xmm2, dword ptr [rbx+5F70h]
00007FF91DFD19AF  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD19B2  F3 0F 59 8B 90 5F 00 00     mulss   xmm1, dword ptr [rbx+5F90h]
00007FF91DFD19BA  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD19BD  F3 0F 58 A3 40 5F 00 00     addss   xmm4, dword ptr [rbx+5F40h]
00007FF91DFD19C5  F3 0F 5C B3 50 5E 00 00     subss   xmm6, dword ptr [rbx+5E50h]
00007FF91DFD19CD  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD19D1  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFD19D5  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD19D9  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD19DD  F3 0F 11 8B 90 5E 00 00     movss   dword ptr [rbx+5E90h], xmm1
00007FF91DFD19E5  72 06                       jb      short loc_7FF91DFD19ED
00007FF91DFD19E7  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD19EB  EB 03                       jmp     short loc_7FF91DFD19F0
00007FF91DFD19ED  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD19F0  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFD19F4  F3 0F 10 83 F0 5E 00 00     movss   xmm0, dword ptr [rbx+5EF0h]
00007FF91DFD19FC  73 03                       jnb     short loc_7FF91DFD1A01
00007FF91DFD19FE  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFD1A01  F3 0F 59 83 70 5F 00 00     mulss   xmm0, dword ptr [rbx+5F70h]
00007FF91DFD1A09  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFD1A0C  F3 0F 10 93 E0 5E 00 00     movss   xmm2, dword ptr [rbx+5EE0h]
00007FF91DFD1A14  F3 0F 11 BB 50 5E 00 00     movss   dword ptr [rbx+5E50h], xmm7
00007FF91DFD1A1C  F3 0F 10 8B 80 5F 00 00     movss   xmm1, dword ptr [rbx+5F80h]
00007FF91DFD1A24  F3 0F 10 B3 00 5F 00 00     movss   xmm6, dword ptr [rbx+5F00h]
00007FF91DFD1A2C  F3 0F 10 A3 80 5E 00 00     movss   xmm4, dword ptr [rbx+5E80h]
00007FF91DFD1A34  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFD1A38  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD1A3B  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD1A3F  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFD1A44  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD1A48  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFD1A4D  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD1A51  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFD1A55  F3 0F 5C C7                 subss   xmm0, xmm7
00007FF91DFD1A59  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD1A5D  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFD1A61  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD1A64  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFD1A68  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD1A6C  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD1A70  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFD1A74  76 0B                       jbe     short loc_7FF91DFD1A81
00007FF91DFD1A76  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD1A79  F3 0F 58 9B 90 5E 00 00     addss   xmm3, dword ptr [rbx+5E90h]
00007FF91DFD1A81  F3 0F 10 A3 30 5E 00 00     movss   xmm4, dword ptr [rbx+5E30h]
00007FF91DFD1A89  F3 0F 10 83 70 5F 00 00     movss   xmm0, dword ptr [rbx+5F70h]
00007FF91DFD1A91  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFD1A95  F3 0F 11 83 70 5E 00 00     movss   dword ptr [rbx+5E70h], xmm0
00007FF91DFD1A9D  F3 0F 59 AB 60 5F 00 00     mulss   xmm5, dword ptr [rbx+5F60h]
00007FF91DFD1AA5  F3 0F 10 8B B0 5E 00 00     movss   xmm1, dword ptr [rbx+5EB0h]
00007FF91DFD1AAD  F3 0F 10 9B 10 5F 00 00     movss   xmm3, dword ptr [rbx+5F10h]
00007FF91DFD1AB5  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFD1AB9  F3 0F 10 83 A0 5F 00 00     movss   xmm0, dword ptr [rbx+5FA0h]
00007FF91DFD1AC1  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFD1AC4  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFD1AC9  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD1ACD  F3 0F 58 EF                 addss   xmm5, xmm7
00007FF91DFD1AD1  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD1AD6  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD1ADA  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFD1ADE  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD1AE2  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD1AE6  F3 0F 11 93 A0 5E 00 00     movss   dword ptr [rbx+5EA0h], xmm2
00007FF91DFD1AEE  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFD1AF3  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFD1AF8  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD1AFC  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD1B00  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD1B04  F3 0F 11 9B 20 5E 00 00     movss   dword ptr [rbx+5E20h], xmm3
00007FF91DFD1B0C  F3 0F 59 9B B0 5F 00 00     mulss   xmm3, dword ptr [rbx+5FB0h]
00007FF91DFD1B14  F3 0F 59 9B C0 5F 00 00     mulss   xmm3, dword ptr [rbx+5FC0h]
00007FF91DFD1B1C  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD1B1F  F3 0F 59 83 D0 5F 00 00     mulss   xmm0, dword ptr [rbx+5FD0h]
00007FF91DFD1B27  F3 0F 11 9B C0 5E 00 00     movss   dword ptr [rbx+5EC0h], xmm3
00007FF91DFD1B2F  F3 0F 11 83 D0 5E 00 00     movss   dword ptr [rbx+5ED0h], xmm0
00007FF91DFD1B37  8B 83 E0 5F 00 00           mov     eax, [rbx+5FE0h]
00007FF91DFD1B3D  89 83 F0 5F 00 00           mov     [rbx+5FF0h], eax
00007FF91DFD1B43  8B 83 00 60 00 00           mov     eax, [rbx+6000h]
00007FF91DFD1B49  89 83 10 60 00 00           mov     [rbx+6010h], eax
00007FF91DFD1B4F  F3 0F 10 83 10 55 00 00     movss   xmm0, dword ptr [rbx+5510h]
00007FF91DFD1B57  F3 44 0F 10 83 90 55 00 00  movss   xmm8, dword ptr [rbx+5590h]
00007FF91DFD1B60  8B 83 40 60 00 00           mov     eax, [rbx+6040h]
00007FF91DFD1B66  89 83 50 60 00 00           mov     [rbx+6050h], eax
00007FF91DFD1B6C  F3 0F 59 83 20 60 00 00     mulss   xmm0, dword ptr [rbx+6020h]
00007FF91DFD1B74  F3 44 0F 59 83 30 60 00 00  mulss   xmm8, dword ptr [rbx+6030h]
00007FF91DFD1B7D  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFD1B82  F3 44 0F 11 83 40 60 00 00  movss   dword ptr [rbx+6040h], xmm8
00007FF91DFD1B8B  F3 0F 10 BB 20 59 00 00     movss   xmm7, dword ptr [rbx+5920h]
00007FF91DFD1B93  F3 0F 10 8B E0 5C 00 00     movss   xmm1, dword ptr [rbx+5CE0h]
00007FF91DFD1B9B  F3 0F 10 93 C0 5E 00 00     movss   xmm2, dword ptr [rbx+5EC0h]
00007FF91DFD1BA3  F3 0F 10 83 10 55 00 00     movss   xmm0, dword ptr [rbx+5510h]
00007FF91DFD1BAB  8B 83 00 60 00 00           mov     eax, [rbx+6000h]
00007FF91DFD1BB1  89 83 80 60 00 00           mov     [rbx+6080h], eax
00007FF91DFD1BB7  F3 0F 11 83 90 60 00 00     movss   dword ptr [rbx+6090h], xmm0
00007FF91DFD1BBF  F3 0F 10 A3 D0 61 00 00     movss   xmm4, dword ptr [rbx+61D0h]
00007FF91DFD1BC7  F3 0F 11 8B 60 60 00 00     movss   dword ptr [rbx+6060h], xmm1
00007FF91DFD1BCF  F3 0F 11 93 70 60 00 00     movss   dword ptr [rbx+6070h], xmm2
00007FF91DFD1BD7  F3 0F 10 AB B0 61 00 00     movss   xmm5, dword ptr [rbx+61B0h]
00007FF91DFD1BDF  F3 0F 59 FC                 mulss   xmm7, xmm4
00007FF91DFD1BE3  F3 0F 59 A3 30 59 00 00     mulss   xmm4, dword ptr [rbx+5930h]
00007FF91DFD1BEB  F3 0F 11 A3 A0 60 00 00     movss   dword ptr [rbx+60A0h], xmm4
00007FF91DFD1BF3  F3 0F 10 8B 30 61 00 00     movss   xmm1, dword ptr [rbx+6130h]
00007FF91DFD1BFB  F3 0F 10 93 30 62 00 00     movss   xmm2, dword ptr [rbx+6230h]
00007FF91DFD1C03  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFD1C06  F3 0F 59 BB E0 61 00 00     mulss   xmm7, dword ptr [rbx+61E0h]
00007FF91DFD1C0E  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD1C11  F3 0F 10 B3 F0 61 00 00     movss   xmm6, dword ptr [rbx+61F0h]
00007FF91DFD1C19  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD1C1D  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFD1C21  F3 0F 59 EC                 mulss   xmm5, xmm4
00007FF91DFD1C25  F3 0F 59 AB C0 61 00 00     mulss   xmm5, dword ptr [rbx+61C0h]
00007FF91DFD1C2D  F3 0F 11 AB C0 60 00 00     movss   dword ptr [rbx+60C0h], xmm5
00007FF91DFD1C35  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFD1C39  F3 0F 59 9B 80 60 00 00     mulss   xmm3, dword ptr [rbx+6080h]
00007FF91DFD1C41  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD1C45  F3 0F 10 83 40 61 00 00     movss   xmm0, dword ptr [rbx+6140h]
00007FF91DFD1C4D  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD1C51  F3 0F 59 9B 40 62 00 00     mulss   xmm3, dword ptr [rbx+6240h]
00007FF91DFD1C59  F3 0F 11 9B D0 60 00 00     movss   dword ptr [rbx+60D0h], xmm3
00007FF91DFD1C61  F3 0F 10 8B 10 62 00 00     movss   xmm1, dword ptr [rbx+6210h]
00007FF91DFD1C69  F3 0F 59 8B 70 60 00 00     mulss   xmm1, dword ptr [rbx+6070h]
00007FF91DFD1C71  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD1C75  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFD1C79  F3 0F 10 83 00 62 00 00     movss   xmm0, dword ptr [rbx+6200h]
00007FF91DFD1C81  F3 0F 59 83 60 60 00 00     mulss   xmm0, dword ptr [rbx+6060h]
00007FF91DFD1C89  F3 0F 10 9B A0 60 00 00     movss   xmm3, dword ptr [rbx+60A0h]
00007FF91DFD1C91  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD1C95  F3 0F 10 83 20 61 00 00     movss   xmm0, dword ptr [rbx+6120h]
00007FF91DFD1C9D  F3 0F 59 8B 20 62 00 00     mulss   xmm1, dword ptr [rbx+6220h]
00007FF91DFD1CA5  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFD1CA9  F3 41 0F 58 C8              addss   xmm1, xmm8
00007FF91DFD1CAE  F3 0F 58 8B 90 61 00 00     addss   xmm1, dword ptr [rbx+6190h]
00007FF91DFD1CB6  F3 0F 58 8B A0 61 00 00     addss   xmm1, dword ptr [rbx+61A0h]
00007FF91DFD1CBE  F3 0F 11 8B E0 60 00 00     movss   dword ptr [rbx+60E0h], xmm1
00007FF91DFD1CC6  F3 0F 11 83 F0 60 00 00     movss   dword ptr [rbx+60F0h], xmm0
00007FF91DFD1CCE  F3 0F 59 9B 60 62 00 00     mulss   xmm3, dword ptr [rbx+6260h]
00007FF91DFD1CD6  F3 0F 10 83 60 61 00 00     movss   xmm0, dword ptr [rbx+6160h]
00007FF91DFD1CDE  F3 0F 59 83 60 60 00 00     mulss   xmm0, dword ptr [rbx+6060h]
00007FF91DFD1CE6  F3 0F 58 9B 70 62 00 00     addss   xmm3, dword ptr [rbx+6270h]
00007FF91DFD1CEE  F3 0F 10 8B 70 61 00 00     movss   xmm1, dword ptr [rbx+6170h]
00007FF91DFD1CF6  F3 0F 59 8B 70 60 00 00     mulss   xmm1, dword ptr [rbx+6070h]
00007FF91DFD1CFE  F3 0F 10 93 C0 60 00 00     movss   xmm2, dword ptr [rbx+60C0h]
00007FF91DFD1D06  F3 0F 59 9B 50 61 00 00     mulss   xmm3, dword ptr [rbx+6150h]
00007FF91DFD1D0E  F3 0F 58 93 90 60 00 00     addss   xmm2, dword ptr [rbx+6090h]
00007FF91DFD1D16  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD1D1A  F3 0F 58 93 D0 60 00 00     addss   xmm2, dword ptr [rbx+60D0h]
00007FF91DFD1D22  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD1D26  F3 0F 58 9B 80 61 00 00     addss   xmm3, dword ptr [rbx+6180h]
00007FF91DFD1D2E  F3 0F 59 9B 50 62 00 00     mulss   xmm3, dword ptr [rbx+6250h]
00007FF91DFD1D36  F3 0F 11 9B 00 61 00 00     movss   dword ptr [rbx+6100h], xmm3
00007FF91DFD1D3E  F3 0F 11 93 10 61 00 00     movss   dword ptr [rbx+6110h], xmm2
00007FF91DFD1D46  F3 0F 10 83 90 62 00 00     movss   xmm0, dword ptr [rbx+6290h]
00007FF91DFD1D4E  8B 83 80 62 00 00           mov     eax, [rbx+6280h]
00007FF91DFD1D54  89 83 B0 62 00 00           mov     [rbx+62B0h], eax
00007FF91DFD1D5A  F3 0F 11 83 C0 62 00 00     movss   dword ptr [rbx+62C0h], xmm0
00007FF91DFD1D62  8B 83 A0 62 00 00           mov     eax, [rbx+62A0h]
00007FF91DFD1D68  89 83 D0 62 00 00           mov     [rbx+62D0h], eax
00007FF91DFD1D6E  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
00007FF91DFD1D76  8B 83 F0 62 00 00           mov     eax, [rbx+62F0h]
00007FF91DFD1D7C  89 83 00 63 00 00           mov     [rbx+6300h], eax
00007FF91DFD1D82  F3 0F 10 93 E0 62 00 00     movss   xmm2, dword ptr [rbx+62E0h]
00007FF91DFD1D8A  F3 0F 11 93 F0 62 00 00     movss   dword ptr [rbx+62F0h], xmm2
00007FF91DFD1D92  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD1D95  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD1D98  F3 0F 59 9B 10 63 00 00     mulss   xmm3, dword ptr [rbx+6310h]
00007FF91DFD1DA0  F3 0F 58 9B 00 63 00 00     addss   xmm3, dword ptr [rbx+6300h]
00007FF91DFD1DA8  F3 0F 11 9B F0 62 00 00     movss   dword ptr [rbx+62F0h], xmm3
00007FF91DFD1DB0  F3 0F 59 83 20 63 00 00     mulss   xmm0, dword ptr [rbx+6320h]
00007FF91DFD1DB8  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFD1DBC  F3 0F 59 9B 50 63 00 00     mulss   xmm3, dword ptr [rbx+6350h]
00007FF91DFD1DC4  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFD1DC8  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFD1DCB  F3 0F 59 8B 10 63 00 00     mulss   xmm1, dword ptr [rbx+6310h]
00007FF91DFD1DD3  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD1DD7  F3 0F 11 8B E0 62 00 00     movss   dword ptr [rbx+62E0h], xmm1
00007FF91DFD1DDF  F3 0F 59 8B 40 63 00 00     mulss   xmm1, dword ptr [rbx+6340h]
00007FF91DFD1DE7  F3 0F 59 A3 30 63 00 00     mulss   xmm4, dword ptr [rbx+6330h]
00007FF91DFD1DEF  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD1DF3  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD1DF7  F3 0F 11 A3 00 63 00 00     movss   dword ptr [rbx+6300h], xmm4
00007FF91DFD1DFF  8B 83 30 6B 00 00           mov     eax, [rbx+6B30h]
00007FF91DFD1E05  89 83 40 6B 00 00           mov     [rbx+6B40h], eax
00007FF91DFD1E0B  F3 0F 10 8B 50 6B 00 00     movss   xmm1, dword ptr [rbx+6B50h]
00007FF91DFD1E13  F3 0F 11 8B 60 6B 00 00     movss   dword ptr [rbx+6B60h], xmm1
00007FF91DFD1E1B  F3 0F 59 8B F0 5F 00 00     mulss   xmm1, dword ptr [rbx+5FF0h]
00007FF91DFD1E23  F3 0F 10 83 40 6B 00 00     movss   xmm0, dword ptr [rbx+6B40h]
00007FF91DFD1E2B  F3 0F 59 83 00 63 00 00     mulss   xmm0, dword ptr [rbx+6300h]
00007FF91DFD1E33  F3 0F 11 8B 70 6B 00 00     movss   dword ptr [rbx+6B70h], xmm1
00007FF91DFD1E3B  F3 0F 11 83 80 6B 00 00     movss   dword ptr [rbx+6B80h], xmm0
00007FF91DFD1E43  8B 83 B0 6B 00 00           mov     eax, [rbx+6BB0h]
00007FF91DFD1E49  89 83 C0 6B 00 00           mov     [rbx+6BC0h], eax
00007FF91DFD1E4F  F3 0F 59 8B 90 6B 00 00     mulss   xmm1, dword ptr [rbx+6B90h]
00007FF91DFD1E57  F3 0F 59 83 A0 6B 00 00     mulss   xmm0, dword ptr [rbx+6BA0h]
00007FF91DFD1E5F  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFD1E63  F3 0F 11 83 B0 6B 00 00     movss   dword ptr [rbx+6BB0h], xmm0
00007FF91DFD1E6B  8B 83 D0 6B 00 00           mov     eax, [rbx+6BD0h]
00007FF91DFD1E71  89 83 E0 6B 00 00           mov     [rbx+6BE0h], eax
00007FF91DFD1E77  8B 83 F0 6B 00 00           mov     eax, [rbx+6BF0h]
00007FF91DFD1E7D  89 83 00 6C 00 00           mov     [rbx+6C00h], eax
00007FF91DFD1E83  8B 83 10 6C 00 00           mov     eax, [rbx+6C10h]
00007FF91DFD1E89  89 83 20 6C 00 00           mov     [rbx+6C20h], eax
00007FF91DFD1E8F  8B 83 30 6C 00 00           mov     eax, [rbx+6C30h]
00007FF91DFD1E95  89 83 40 6C 00 00           mov     [rbx+6C40h], eax
00007FF91DFD1E9B  F3 0F 10 8B 60 6C 00 00     movss   xmm1, dword ptr [rbx+6C60h]
00007FF91DFD1EA3  F3 0F 10 93 70 6C 00 00     movss   xmm2, dword ptr [rbx+6C70h]
00007FF91DFD1EAB  0F 28 E1                    movaps  xmm4, xmm1
00007FF91DFD1EAE  F3 0F 59 A3 D0 6B 00 00     mulss   xmm4, dword ptr [rbx+6BD0h]
00007FF91DFD1EB6  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD1EB9  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD1EBD  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFD1EC1  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFD1EC5  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD1EC8  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFD1ECB  F3 0F 59 8B 90 6C 00 00     mulss   xmm1, dword ptr [rbx+6C90h]
00007FF91DFD1ED3  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD1ED7  F3 0F 58 8B 80 6C 00 00     addss   xmm1, dword ptr [rbx+6C80h]
00007FF91DFD1EDF  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD1EE2  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD1EE6  F3 0F 59 83 A0 6C 00 00     mulss   xmm0, dword ptr [rbx+6CA0h]
00007FF91DFD1EEE  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD1EF2  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD1EF5  F3 0F 59 9B B0 6C 00 00     mulss   xmm3, dword ptr [rbx+6CB0h]
00007FF91DFD1EFD  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD1F01  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD1F05  F3 0F 59 83 C0 6C 00 00     mulss   xmm0, dword ptr [rbx+6CC0h]
00007FF91DFD1F0D  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFD1F11  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD1F15  76 05                       jbe     short loc_7FF91DFD1F1C
00007FF91DFD1F17  0F 5A C0                    cvtps2pd xmm0, xmm0
00007FF91DFD1F1A  EB 03                       jmp     short loc_7FF91DFD1F1F
00007FF91DFD1F1C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD1F1F  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFD1F23  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFD1F27  73 04                       jnb     short loc_7FF91DFD1F2D
00007FF91DFD1F29  44 0F 5A E1                 cvtps2pd xmm12, xmm1
00007FF91DFD1F2D  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
00007FF91DFD1F32  F3 0F 11 83 50 6C 00 00     movss   dword ptr [rbx+6C50h], xmm0
00007FF91DFD1F3A  8B 83 D0 6C 00 00           mov     eax, [rbx+6CD0h]
00007FF91DFD1F40  89 83 E0 6C 00 00           mov     [rbx+6CE0h], eax
00007FF91DFD1F46  F3 0F 10 8B F0 6C 00 00     movss   xmm1, dword ptr [rbx+6CF0h]
00007FF91DFD1F4E  F3 0F 11 8B 00 6D 00 00     movss   dword ptr [rbx+6D00h], xmm1
00007FF91DFD1F56  F3 0F 10 83 10 6D 00 00     movss   xmm0, dword ptr [rbx+6D10h]
00007FF91DFD1F5E  F3 0F 11 83 20 6D 00 00     movss   dword ptr [rbx+6D20h], xmm0
00007FF91DFD1F66  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD1F6A  F3 0F 59 8B 30 6D 00 00     mulss   xmm1, dword ptr [rbx+6D30h]
00007FF91DFD1F72  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD1F76  F3 0F 11 8B 10 6D 00 00     movss   dword ptr [rbx+6D10h], xmm1
00007FF91DFD1F7E  F3 0F 10 8B 10 55 00 00     movss   xmm1, dword ptr [rbx+5510h]
00007FF91DFD1F86  F3 0F 10 83 90 55 00 00     movss   xmm0, dword ptr [rbx+5590h]
00007FF91DFD1F8E  8B 83 60 6D 00 00           mov     eax, [rbx+6D60h]
00007FF91DFD1F94  89 83 70 6D 00 00           mov     [rbx+6D70h], eax
00007FF91DFD1F9A  F3 0F 59 83 50 6D 00 00     mulss   xmm0, dword ptr [rbx+6D50h]
00007FF91DFD1FA2  F3 0F 59 8B 40 6D 00 00     mulss   xmm1, dword ptr [rbx+6D40h]
00007FF91DFD1FAA  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFD1FAE  F3 0F 11 83 60 6D 00 00     movss   dword ptr [rbx+6D60h], xmm0
00007FF91DFD1FB6  8B 83 80 6D 00 00           mov     eax, [rbx+6D80h]
00007FF91DFD1FBC  89 83 A0 6D 00 00           mov     [rbx+6DA0h], eax
00007FF91DFD1FC2  F3 0F 10 9B 90 6D 00 00     movss   xmm3, dword ptr [rbx+6D90h]
00007FF91DFD1FCA  F3 0F 11 9B B0 6D 00 00     movss   dword ptr [rbx+6DB0h], xmm3
00007FF91DFD1FD2  F3 0F 10 8B A0 6D 00 00     movss   xmm1, dword ptr [rbx+6DA0h]
00007FF91DFD1FDA  F3 0F 10 93 E0 5C 00 00     movss   xmm2, dword ptr [rbx+5CE0h]
00007FF91DFD1FE2  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD1FE5  F3 0F 59 83 C0 5E 00 00     mulss   xmm0, dword ptr [rbx+5EC0h]
00007FF91DFD1FED  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD1FF1  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFD1FF5  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD1FF8  F3 0F 59 8B 10 6C 00 00     mulss   xmm1, dword ptr [rbx+6C10h]
00007FF91DFD2000  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD2004  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFD2008  F3 0F 5C CB                 subss   xmm1, xmm3
00007FF91DFD200C  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD2010  F3 0F 11 8B C0 6D 00 00     movss   dword ptr [rbx+6DC0h], xmm1
00007FF91DFD2018  F3 0F 10 9B 20 59 00 00     movss   xmm3, dword ptr [rbx+5920h]
00007FF91DFD2020  F3 0F 10 83 D0 6D 00 00     movss   xmm0, dword ptr [rbx+6DD0h]
00007FF91DFD2028  F3 0F 11 83 E0 6D 00 00     movss   dword ptr [rbx+6DE0h], xmm0
00007FF91DFD2030  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD2034  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD2037  F3 0F 59 8B F0 6D 00 00     mulss   xmm1, dword ptr [rbx+6DF0h]
00007FF91DFD203F  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD2043  F3 0F 10 83 10 6E 00 00     movss   xmm0, dword ptr [rbx+6E10h]
00007FF91DFD204B  F3 0F 11 8B D0 6D 00 00     movss   dword ptr [rbx+6DD0h], xmm1
00007FF91DFD2053  F3 0F 59 9B 00 6E 00 00     mulss   xmm3, dword ptr [rbx+6E00h]
00007FF91DFD205B  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD205F  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD2063  F3 0F 11 9B E0 6D 00 00     movss   dword ptr [rbx+6DE0h], xmm3
00007FF91DFD206B  F3 0F 10 83 20 6E 00 00     movss   xmm0, dword ptr [rbx+6E20h]
00007FF91DFD2073  F3 0F 10 BB 30 59 00 00     movss   xmm7, dword ptr [rbx+5930h]
00007FF91DFD207B  F3 0F 11 83 30 6E 00 00     movss   dword ptr [rbx+6E30h], xmm0
00007FF91DFD2083  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFD2087  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFD208A  F3 0F 59 8B 40 6E 00 00     mulss   xmm1, dword ptr [rbx+6E40h]
00007FF91DFD2092  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD2096  F3 0F 10 83 60 6E 00 00     movss   xmm0, dword ptr [rbx+6E60h]
00007FF91DFD209E  F3 0F 11 8B 20 6E 00 00     movss   dword ptr [rbx+6E20h], xmm1
00007FF91DFD20A6  F3 0F 59 BB 50 6E 00 00     mulss   xmm7, dword ptr [rbx+6E50h]
00007FF91DFD20AE  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD20B2  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFD20B6  F3 0F 11 BB 30 6E 00 00     movss   dword ptr [rbx+6E30h], xmm7
00007FF91DFD20BE  F3 0F 10 A3 E0 6D 00 00     movss   xmm4, dword ptr [rbx+6DE0h]
00007FF91DFD20C6  F3 0F 10 AB C0 6D 00 00     movss   xmm5, dword ptr [rbx+6DC0h]
00007FF91DFD20CE  F3 0F 10 B3 60 6D 00 00     movss   xmm6, dword ptr [rbx+6D60h]
00007FF91DFD20D6  F3 44 0F 10 8B F0 6B 00 00  movss   xmm9, dword ptr [rbx+6BF0h]
00007FF91DFD20DF  8B 83 10 6D 00 00           mov     eax, [rbx+6D10h]
00007FF91DFD20E5  89 83 70 6E 00 00           mov     [rbx+6E70h], eax
00007FF91DFD20EB  F3 44 0F 11 8B 80 6E 00 00  movss   dword ptr [rbx+6E80h], xmm9
00007FF91DFD20F4  F3 0F 10 83 A0 6E 00 00     movss   xmm0, dword ptr [rbx+6EA0h]
00007FF91DFD20FC  F3 0F 10 93 B0 6E 00 00     movss   xmm2, dword ptr [rbx+6EB0h]
00007FF91DFD2104  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFD2108  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD210B  F3 0F 59 9B 30 6C 00 00     mulss   xmm3, dword ptr [rbx+6C30h]
00007FF91DFD2113  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD2117  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD211A  F3 0F 59 C7                 mulss   xmm0, xmm7
00007FF91DFD211E  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFD2122  F3 44 0F 5C C0              subss   xmm8, xmm0
00007FF91DFD2127  F3 44 0F 58 C7              addss   xmm8, xmm7
00007FF91DFD212C  F3 44 0F 59 83 E0 6E 00 00  mulss   xmm8, dword ptr [rbx+6EE0h]
00007FF91DFD2135  F3 0F 10 8B C0 6E 00 00     movss   xmm1, dword ptr [rbx+6EC0h]
00007FF91DFD213D  F3 0F 58 B3 60 6F 00 00     addss   xmm6, dword ptr [rbx+6F60h]
00007FF91DFD2145  F3 44 0F 59 83 F0 6E 00 00  mulss   xmm8, dword ptr [rbx+6EF0h]
00007FF91DFD214E  F3 0F 59 AB 00 6F 00 00     mulss   xmm5, dword ptr [rbx+6F00h]
00007FF91DFD2156  F3 0F 59 B3 10 6F 00 00     mulss   xmm6, dword ptr [rbx+6F10h]
00007FF91DFD215E  F3 44 0F 59 C9              mulss   xmm9, xmm1
00007FF91DFD2163  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD2167  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFD216B  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFD216F  F3 0F 10 93 40 6F 00 00     movss   xmm2, dword ptr [rbx+6F40h]
00007FF91DFD2177  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD217A  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD217E  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD2182  F3 44 0F 5C C8              subss   xmm9, xmm0
00007FF91DFD2187  F3 0F 10 83 30 6F 00 00     movss   xmm0, dword ptr [rbx+6F30h]
00007FF91DFD218F  F3 0F 58 83 70 6E 00 00     addss   xmm0, dword ptr [rbx+6E70h]
00007FF91DFD2197  F3 0F 59 9B D0 6E 00 00     mulss   xmm3, dword ptr [rbx+6ED0h]
00007FF91DFD219F  F3 0F 59 83 70 6F 00 00     mulss   xmm0, dword ptr [rbx+6F70h]
00007FF91DFD21A7  F3 44 0F 58 CA              addss   xmm9, xmm2
00007FF91DFD21AC  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFD21B1  F3 0F 59 83 20 6F 00 00     mulss   xmm0, dword ptr [rbx+6F20h]
00007FF91DFD21B9  F3 44 0F 59 8B 50 6F 00 00  mulss   xmm9, dword ptr [rbx+6F50h]
00007FF91DFD21C2  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFD21C7  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFD21CC  F3 45 0F 58 C8              addss   xmm9, xmm8
00007FF91DFD21D1  F3 44 0F 11 8B 90 6E 00 00  movss   dword ptr [rbx+6E90h], xmm9
00007FF91DFD21DA  F3 0F 10 BB 50 6C 00 00     movss   xmm7, dword ptr [rbx+6C50h]
00007FF91DFD21E2  F3 44 0F 10 83 E0 6C 00 00  movss   xmm8, dword ptr [rbx+6CE0h]
00007FF91DFD21EB  8B 83 B0 6F 00 00           mov     eax, [rbx+6FB0h]
00007FF91DFD21F1  89 83 C0 6F 00 00           mov     [rbx+6FC0h], eax
00007FF91DFD21F7  F3 0F 10 83 A0 6F 00 00     movss   xmm0, dword ptr [rbx+6FA0h]
00007FF91DFD21FF  F3 0F 11 83 B0 6F 00 00     movss   dword ptr [rbx+6FB0h], xmm0
00007FF91DFD2207  44 0F 2E AB F0 6F 00 00     ucomiss xmm13, dword ptr [rbx+6FF0h]
00007FF91DFD220F  0F 85 7D 02 00 00           jnz     loc_7FF91DFD2492
00007FF91DFD2215  F3 0F 10 8B 40 70 00 00     movss   xmm1, dword ptr [rbx+7040h]
00007FF91DFD221D  F3 0F 10 B3 C0 6F 00 00     movss   xmm6, dword ptr [rbx+6FC0h]
00007FF91DFD2225  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFD2228  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFD222C  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD2230  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFD2234  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFD2238  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFD223C  F3 0F 11 B3 B0 6F 00 00     movss   dword ptr [rbx+6FB0h], xmm6
00007FF91DFD2244  F3 0F 59 B3 30 70 00 00     mulss   xmm6, dword ptr [rbx+7030h]
00007FF91DFD224C  F3 0F 58 B3 D0 6F 00 00     addss   xmm6, dword ptr [rbx+6FD0h]
00007FF91DFD2254  E8 07 6B FF FF              call    sub_7FF91DFC8D60
00007FF91DFD2259  F3 0F 11 83 A0 6F 00 00     movss   dword ptr [rbx+6FA0h], xmm0
00007FF91DFD2261  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFD2265  F3 0F 59 8B 90 70 00 00     mulss   xmm1, dword ptr [rbx+7090h]
00007FF91DFD226D  41 0F 28 D5                 movaps  xmm2, xmm13
00007FF91DFD2271  F3 41 0F 5C D0              subss   xmm2, xmm8
00007FF91DFD2276  F3 0F 58 8B E0 6F 00 00     addss   xmm1, dword ptr [rbx+6FE0h]
00007FF91DFD227E  F3 0F 59 93 50 70 00 00     mulss   xmm2, dword ptr [rbx+7050h]
00007FF91DFD2286  F3 0F 11 8B 90 6F 00 00     movss   dword ptr [rbx+6F90h], xmm1
00007FF91DFD228E  F3 0F 59 BB 00 70 00 00     mulss   xmm7, dword ptr [rbx+7000h]
00007FF91DFD2296  F3 44 0F 59 8B 20 70 00 00  mulss   xmm9, dword ptr [rbx+7020h]
00007FF91DFD229F  F3 0F 10 83 60 70 00 00     movss   xmm0, dword ptr [rbx+7060h]
00007FF91DFD22A7  F3 0F 5D C2                 minss   xmm0, xmm2
00007FF91DFD22AB  F3 41 0F 58 F9              addss   xmm7, xmm9
00007FF91DFD22B0  F3 0F 58 FE                 addss   xmm7, xmm6
00007FF91DFD22B4  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFD22B8  F3 0F 58 BB 10 70 00 00     addss   xmm7, dword ptr [rbx+7010h]
00007FF91DFD22C0  F3 0F 5D BB 70 70 00 00     minss   xmm7, dword ptr [rbx+7070h]
00007FF91DFD22C8  F3 0F 5F BB 80 70 00 00     maxss   xmm7, dword ptr [rbx+7080h]
00007FF91DFD22D0  F3 0F 59 BB B0 70 00 00     mulss   xmm7, dword ptr [rbx+70B0h]
00007FF91DFD22D8  F3 0F 58 BB C0 70 00 00     addss   xmm7, dword ptr [rbx+70C0h]
00007FF91DFD22E0  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFD22E3  F3 0F 2C C9                 cvttss2si ecx, xmm1
00007FF91DFD22E7  81 F9 00 00 00 80           cmp     ecx, 80000000h
00007FF91DFD22ED  74 1E                       jz      short loc_7FF91DFD230D
00007FF91DFD22EF  66 0F 6E C1                 movd    xmm0, ecx
00007FF91DFD22F3  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFD22F6  0F 2E C1                    ucomiss xmm0, xmm1
00007FF91DFD22F9  74 12                       jz      short loc_7FF91DFD230D
00007FF91DFD22FB  0F 14 C9                    unpcklps xmm1, xmm1
00007FF91DFD22FE  0F 50 C1                    movmskps eax, xmm1
00007FF91DFD2301  83 E0 01                    and     eax, 1
00007FF91DFD2304  2B C8                       sub     ecx, eax
00007FF91DFD2306  66 0F 6E C9                 movd    xmm1, ecx
00007FF91DFD230A  0F 5B C9                    cvtdq2ps xmm1, xmm1
00007FF91DFD230D  F3 0F 5C F9                 subss   xmm7, xmm1
00007FF91DFD2311  0F 28 C1                    movaps  xmm0, xmm1; X
00007FF91DFD2314  0F 28 F7                    movaps  xmm6, xmm7
00007FF91DFD2317  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFD231B  F3 0F 59 35 AD 2C 77 00     mulss   xmm6, cs:dword_7FF91E744FD0
00007FF91DFD2323  E8 18 D4 37 00              call    expf
00007FF91DFD2328  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD232B  0F 28 D7                    movaps  xmm2, xmm7
00007FF91DFD232E  F3 0F 59 93 80 71 00 00     mulss   xmm2, dword ptr [rbx+7180h]
00007FF91DFD2336  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFD2339  F3 0F 59 8B 60 71 00 00     mulss   xmm1, dword ptr [rbx+7160h]
00007FF91DFD2341  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD2344  F3 0F 58 93 70 71 00 00     addss   xmm2, dword ptr [rbx+7170h]
00007FF91DFD234C  F3 0F 59 83 40 71 00 00     mulss   xmm0, dword ptr [rbx+7140h]
00007FF91DFD2354  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD2358  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD235C  F3 0F 58 93 50 71 00 00     addss   xmm2, dword ptr [rbx+7150h]
00007FF91DFD2364  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD2368  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD236C  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD236F  F3 0F 59 83 20 71 00 00     mulss   xmm0, dword ptr [rbx+7120h]
00007FF91DFD2377  F3 0F 58 93 30 71 00 00     addss   xmm2, dword ptr [rbx+7130h]
00007FF91DFD237F  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD2383  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD2387  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD238A  F3 0F 59 83 00 71 00 00     mulss   xmm0, dword ptr [rbx+7100h]
00007FF91DFD2392  F3 0F 59 BB E0 70 00 00     mulss   xmm7, dword ptr [rbx+70E0h]
00007FF91DFD239A  F3 0F 58 93 10 71 00 00     addss   xmm2, dword ptr [rbx+7110h]
00007FF91DFD23A2  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD23A6  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD23AA  F3 0F 58 93 F0 70 00 00     addss   xmm2, dword ptr [rbx+70F0h]
00007FF91DFD23B2  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD23B6  F3 0F 58 D7                 addss   xmm2, xmm7
00007FF91DFD23BA  F3 41 0F 58 D5              addss   xmm2, xmm13
00007FF91DFD23BF  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFD23C3  F3 0F 59 A3 D0 70 00 00     mulss   xmm4, dword ptr [rbx+70D0h]
00007FF91DFD23CB  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD23CE  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD23D2  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD23D5  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFD23D9  F3 44 0F 59 83 20 72 00 00  mulss   xmm8, dword ptr [rbx+7220h]
00007FF91DFD23E2  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD23E5  F3 0F 59 83 E0 71 00 00     mulss   xmm0, dword ptr [rbx+71E0h]
00007FF91DFD23ED  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFD23F0  F3 44 0F 58 83 00 72 00 00  addss   xmm8, dword ptr [rbx+7200h]
00007FF91DFD23F9  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD23FD  F3 0F 58 83 C0 71 00 00     addss   xmm0, dword ptr [rbx+71C0h]
00007FF91DFD2405  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD2409  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFD240E  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFD2413  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD2416  F3 0F 59 8B A0 71 00 00     mulss   xmm1, dword ptr [rbx+71A0h]
00007FF91DFD241E  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD2422  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFD2427  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD242A  F3 0F 59 83 D0 71 00 00     mulss   xmm0, dword ptr [rbx+71D0h]
00007FF91DFD2432  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFD2437  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD243A  F3 0F 59 8B 10 72 00 00     mulss   xmm1, dword ptr [rbx+7210h]
00007FF91DFD2442  F3 0F 59 9B 90 71 00 00     mulss   xmm3, dword ptr [rbx+7190h]
00007FF91DFD244A  F3 0F 58 8B F0 71 00 00     addss   xmm1, dword ptr [rbx+71F0h]
00007FF91DFD2452  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFD2457  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD245B  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD245F  F3 0F 58 8B B0 71 00 00     addss   xmm1, dword ptr [rbx+71B0h]
00007FF91DFD2467  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD246B  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFD246F  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD2474  F3 44 0F 5E C1              divss   xmm8, xmm1
00007FF91DFD2479  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFD247D  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD2482  F3 44 0F 5E C0              divss   xmm8, xmm0
00007FF91DFD2487  F3 44 0F 11 83 80 6F 00 00  movss   dword ptr [rbx+6F80h], xmm8
00007FF91DFD2490  EB 09                       jmp     short loc_7FF91DFD249B
00007FF91DFD2492  F3 44 0F 10 83 80 6F 00 00  movss   xmm8, dword ptr [rbx+6F80h]
00007FF91DFD249B  8B 83 90 72 00 00           mov     eax, [rbx+7290h]
00007FF91DFD24A1  F3 0F 10 8B B0 6B 00 00     movss   xmm1, dword ptr [rbx+6BB0h]
00007FF91DFD24A9  F3 44 0F 10 8B 90 6F 00 00  movss   xmm9, dword ptr [rbx+6F90h]
00007FF91DFD24B2  89 83 A0 72 00 00           mov     [rbx+72A0h], eax
00007FF91DFD24B8  8B 83 80 72 00 00           mov     eax, [rbx+7280h]
00007FF91DFD24BE  89 83 90 72 00 00           mov     [rbx+7290h], eax
00007FF91DFD24C4  8B 83 70 72 00 00           mov     eax, [rbx+7270h]
00007FF91DFD24CA  89 83 80 72 00 00           mov     [rbx+7280h], eax
00007FF91DFD24D0  8B 83 60 72 00 00           mov     eax, [rbx+7260h]
00007FF91DFD24D6  89 83 70 72 00 00           mov     [rbx+7270h], eax
00007FF91DFD24DC  8B 83 50 72 00 00           mov     eax, [rbx+7250h]
00007FF91DFD24E2  89 83 60 72 00 00           mov     [rbx+7260h], eax
00007FF91DFD24E8  8B 83 40 72 00 00           mov     eax, [rbx+7240h]
00007FF91DFD24EE  89 83 50 72 00 00           mov     [rbx+7250h], eax
00007FF91DFD24F4  8B 83 30 72 00 00           mov     eax, [rbx+7230h]
00007FF91DFD24FA  89 83 40 72 00 00           mov     [rbx+7240h], eax
00007FF91DFD2500  8B 83 70 73 00 00           mov     eax, [rbx+7370h]
00007FF91DFD2506  89 83 80 73 00 00           mov     [rbx+7380h], eax
00007FF91DFD250C  8B 83 60 73 00 00           mov     eax, [rbx+7360h]
00007FF91DFD2512  89 83 70 73 00 00           mov     [rbx+7370h], eax
00007FF91DFD2518  8B 83 50 73 00 00           mov     eax, [rbx+7350h]
00007FF91DFD251E  89 83 60 73 00 00           mov     [rbx+7360h], eax
00007FF91DFD2524  8B 83 40 73 00 00           mov     eax, [rbx+7340h]
00007FF91DFD252A  89 83 50 73 00 00           mov     [rbx+7350h], eax
00007FF91DFD2530  8B 83 30 73 00 00           mov     eax, [rbx+7330h]
00007FF91DFD2536  89 83 40 73 00 00           mov     [rbx+7340h], eax
00007FF91DFD253C  8B 83 20 73 00 00           mov     eax, [rbx+7320h]
00007FF91DFD2542  89 83 30 73 00 00           mov     [rbx+7330h], eax
00007FF91DFD2548  8B 83 10 73 00 00           mov     eax, [rbx+7310h]
00007FF91DFD254E  89 83 20 73 00 00           mov     [rbx+7320h], eax
00007FF91DFD2554  8B 83 F0 73 00 00           mov     eax, [rbx+73F0h]
00007FF91DFD255A  89 83 00 74 00 00           mov     [rbx+7400h], eax
00007FF91DFD2560  8B 83 E0 73 00 00           mov     eax, [rbx+73E0h]
00007FF91DFD2566  89 83 F0 73 00 00           mov     [rbx+73F0h], eax
00007FF91DFD256C  8B 83 D0 73 00 00           mov     eax, [rbx+73D0h]
00007FF91DFD2572  89 83 E0 73 00 00           mov     [rbx+73E0h], eax
00007FF91DFD2578  8B 83 C0 73 00 00           mov     eax, [rbx+73C0h]
00007FF91DFD257E  89 83 D0 73 00 00           mov     [rbx+73D0h], eax
00007FF91DFD2584  8B 83 B0 73 00 00           mov     eax, [rbx+73B0h]
00007FF91DFD258A  89 83 C0 73 00 00           mov     [rbx+73C0h], eax
00007FF91DFD2590  8B 83 A0 73 00 00           mov     eax, [rbx+73A0h]
00007FF91DFD2596  89 83 B0 73 00 00           mov     [rbx+73B0h], eax
00007FF91DFD259C  8B 83 90 73 00 00           mov     eax, [rbx+7390h]
00007FF91DFD25A2  89 83 A0 73 00 00           mov     [rbx+73A0h], eax
00007FF91DFD25A8  8B 83 70 74 00 00           mov     eax, [rbx+7470h]
00007FF91DFD25AE  89 83 80 74 00 00           mov     [rbx+7480h], eax
00007FF91DFD25B4  8B 83 60 74 00 00           mov     eax, [rbx+7460h]
00007FF91DFD25BA  89 83 70 74 00 00           mov     [rbx+7470h], eax
00007FF91DFD25C0  8B 83 50 74 00 00           mov     eax, [rbx+7450h]
00007FF91DFD25C6  89 83 60 74 00 00           mov     [rbx+7460h], eax
00007FF91DFD25CC  8B 83 40 74 00 00           mov     eax, [rbx+7440h]
00007FF91DFD25D2  89 83 50 74 00 00           mov     [rbx+7450h], eax
00007FF91DFD25D8  8B 83 30 74 00 00           mov     eax, [rbx+7430h]
00007FF91DFD25DE  89 83 40 74 00 00           mov     [rbx+7440h], eax
00007FF91DFD25E4  8B 83 20 74 00 00           mov     eax, [rbx+7420h]
00007FF91DFD25EA  89 83 30 74 00 00           mov     [rbx+7430h], eax
00007FF91DFD25F0  8B 83 10 74 00 00           mov     eax, [rbx+7410h]
00007FF91DFD25F6  89 83 20 74 00 00           mov     [rbx+7420h], eax
00007FF91DFD25FC  8B 83 F0 74 00 00           mov     eax, [rbx+74F0h]
00007FF91DFD2602  89 83 00 75 00 00           mov     [rbx+7500h], eax
00007FF91DFD2608  8B 83 E0 74 00 00           mov     eax, [rbx+74E0h]
00007FF91DFD260E  89 83 F0 74 00 00           mov     [rbx+74F0h], eax
00007FF91DFD2614  8B 83 D0 74 00 00           mov     eax, [rbx+74D0h]
00007FF91DFD261A  89 83 E0 74 00 00           mov     [rbx+74E0h], eax
00007FF91DFD2620  8B 83 C0 74 00 00           mov     eax, [rbx+74C0h]
00007FF91DFD2626  89 83 D0 74 00 00           mov     [rbx+74D0h], eax
00007FF91DFD262C  8B 83 B0 74 00 00           mov     eax, [rbx+74B0h]
00007FF91DFD2632  89 83 C0 74 00 00           mov     [rbx+74C0h], eax
00007FF91DFD2638  8B 83 A0 74 00 00           mov     eax, [rbx+74A0h]
00007FF91DFD263E  89 83 B0 74 00 00           mov     [rbx+74B0h], eax
00007FF91DFD2644  8B 83 90 74 00 00           mov     eax, [rbx+7490h]
00007FF91DFD264A  89 83 A0 74 00 00           mov     [rbx+74A0h], eax
00007FF91DFD2650  8B 83 10 75 00 00           mov     eax, [rbx+7510h]
00007FF91DFD2656  89 83 20 75 00 00           mov     [rbx+7520h], eax
00007FF91DFD265C  F3 0F 10 83 30 75 00 00     movss   xmm0, dword ptr [rbx+7530h]
00007FF91DFD2664  F3 0F 11 83 40 75 00 00     movss   dword ptr [rbx+7540h], xmm0
00007FF91DFD266C  44 0F 2E AB 80 75 00 00     ucomiss xmm13, dword ptr [rbx+7580h]
00007FF91DFD2674  0F 85 49 09 00 00           jnz     loc_7FF91DFD2FC3
00007FF91DFD267A  F3 0F 59 8B D0 75 00 00     mulss   xmm1, dword ptr [rbx+75D0h]
00007FF91DFD2682  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFD2686  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFD268A  41 0F 28 F8                 movaps  xmm7, xmm8
00007FF91DFD268E  F3 0F 59 B3 F0 75 00 00     mulss   xmm6, dword ptr [rbx+75F0h]
00007FF91DFD2696  F3 41 0F 59 F8              mulss   xmm7, xmm8
00007FF91DFD269B  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD26A0  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFD26A4  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFD26A7  F3 0F 59 8B C0 75 00 00     mulss   xmm1, dword ptr [rbx+75C0h]
00007FF91DFD26AF  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFD26B3  E8 A8 66 FF FF              call    sub_7FF91DFC8D60
00007FF91DFD26B8  F3 0F 11 83 30 75 00 00     movss   dword ptr [rbx+7530h], xmm0
00007FF91DFD26C0  41 0F 28 DD                 movaps  xmm3, xmm13
00007FF91DFD26C4  F3 0F 11 B3 10 75 00 00     movss   dword ptr [rbx+7510h], xmm6
00007FF91DFD26CC  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFD26D0  F3 0F 59 FF                 mulss   xmm7, xmm7
00007FF91DFD26D4  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFD26D9  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD26DD  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFD26E2  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFD26E6  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD26EB  F3 0F 5E DF                 divss   xmm3, xmm7
00007FF91DFD26EF  F3 0F 11 9B 60 75 00 00     movss   dword ptr [rbx+7560h], xmm3
00007FF91DFD26F7  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFD26FA  F3 0F 10 8B 10 75 00 00     movss   xmm1, dword ptr [rbx+7510h]
00007FF91DFD2702  F3 0F 10 AB 20 75 00 00     movss   xmm5, dword ptr [rbx+7520h]
00007FF91DFD270A  F3 41 0F 59 E1              mulss   xmm4, xmm9
00007FF91DFD270F  F3 0F 11 A3 50 75 00 00     movss   dword ptr [rbx+7550h], xmm4
00007FF91DFD2717  F3 0F 59 AB 20 76 00 00     mulss   xmm5, dword ptr [rbx+7620h]
00007FF91DFD271F  F3 0F 10 93 90 72 00 00     movss   xmm2, dword ptr [rbx+7290h]
00007FF91DFD2727  F3 0F 59 8B 30 76 00 00     mulss   xmm1, dword ptr [rbx+7630h]
00007FF91DFD272F  F3 0F 10 83 A0 72 00 00     movss   xmm0, dword ptr [rbx+72A0h]
00007FF91DFD2737  F3 0F 11 93 00 73 00 00     movss   dword ptr [rbx+7300h], xmm2
00007FF91DFD273F  F3 0F 59 93 50 77 00 00     mulss   xmm2, dword ptr [rbx+7750h]
00007FF91DFD2747  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD274B  F3 0F 59 83 60 77 00 00     mulss   xmm0, dword ptr [rbx+7760h]
00007FF91DFD2753  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFD2757  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD275B  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD275F  F3 0F 5C EA                 subss   xmm5, xmm2
00007FF91DFD2763  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD2767  73 06                       jnb     short loc_7FF91DFD276F
00007FF91DFD2769  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD276D  EB 05                       jmp     short loc_7FF91DFD2774
00007FF91DFD276F  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD2774  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFD2777  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD277A  F3 0F 59 83 00 76 00 00     mulss   xmm0, dword ptr [rbx+7600h]
00007FF91DFD2782  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD2786  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD278A  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD278E  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD2792  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD2796  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD279A  F3 0F 11 AB B0 72 00 00     movss   dword ptr [rbx+72B0h], xmm5
00007FF91DFD27A2  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD27A5  F3 0F 58 AB 40 72 00 00     addss   xmm5, dword ptr [rbx+7240h]
00007FF91DFD27AD  F3 0F 10 9B 50 72 00 00     movss   xmm3, dword ptr [rbx+7250h]
00007FF91DFD27B5  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD27B8  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD27BC  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD27C0  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFD27C4  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFD27C8  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD27CC  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD27D0  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD27D3  F3 0F 11 A3 C0 72 00 00     movss   dword ptr [rbx+72C0h], xmm4
00007FF91DFD27DB  F3 0F 10 8B 60 72 00 00     movss   xmm1, dword ptr [rbx+7260h]
00007FF91DFD27E3  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD27E7  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD27EB  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD27EE  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD27F2  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFD27F6  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD27FA  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFD27FE  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD2802  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD2806  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD280A  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD280E  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2811  F3 0F 11 9B D0 72 00 00     movss   dword ptr [rbx+72D0h], xmm3
00007FF91DFD2819  F3 0F 10 AB 70 72 00 00     movss   xmm5, dword ptr [rbx+7270h]
00007FF91DFD2821  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD2825  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2829  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD282C  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD2830  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD2834  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD2838  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFD283C  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD2840  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD2844  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD2848  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD284C  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD284F  F3 0F 11 93 E0 72 00 00     movss   dword ptr [rbx+72E0h], xmm2
00007FF91DFD2857  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFD285B  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD285F  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD2863  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFD2868  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD286B  F3 0F 59 83 80 72 00 00     mulss   xmm0, dword ptr [rbx+7280h]
00007FF91DFD2873  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD2877  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD287B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD287E  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFD2882  F3 0F 11 AB F0 72 00 00     movss   dword ptr [rbx+72F0h], xmm5
00007FF91DFD288A  F3 0F 10 93 E0 72 00 00     movss   xmm2, dword ptr [rbx+72E0h]
00007FF91DFD2892  F3 0F 59 93 A0 75 00 00     mulss   xmm2, dword ptr [rbx+75A0h]
00007FF91DFD289A  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD289E  F3 0F 59 AB B0 75 00 00     mulss   xmm5, dword ptr [rbx+75B0h]
00007FF91DFD28A6  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD28AA  F3 0F 10 83 90 75 00 00     movss   xmm0, dword ptr [rbx+7590h]
00007FF91DFD28B2  F3 0F 59 83 D0 72 00 00     mulss   xmm0, dword ptr [rbx+72D0h]
00007FF91DFD28BA  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFD28BE  F3 0F 10 AB 20 75 00 00     movss   xmm5, dword ptr [rbx+7520h]
00007FF91DFD28C6  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD28CA  F3 0F 11 93 90 74 00 00     movss   dword ptr [rbx+7490h], xmm2
00007FF91DFD28D2  F3 0F 58 AB 10 75 00 00     addss   xmm5, dword ptr [rbx+7510h]
00007FF91DFD28DA  F3 0F 10 83 00 73 00 00     movss   xmm0, dword ptr [rbx+7300h]
00007FF91DFD28E2  F3 0F 59 AB 40 76 00 00     mulss   xmm5, dword ptr [rbx+7640h]
00007FF91DFD28EA  F3 0F 59 AB 60 75 00 00     mulss   xmm5, dword ptr [rbx+7560h]
00007FF91DFD28F2  F3 0F 11 A3 00 73 00 00     movss   dword ptr [rbx+7300h], xmm4
00007FF91DFD28FA  F3 0F 59 A3 50 77 00 00     mulss   xmm4, dword ptr [rbx+7750h]
00007FF91DFD2902  F3 0F 59 83 60 77 00 00     mulss   xmm0, dword ptr [rbx+7760h]
00007FF91DFD290A  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD290E  F3 0F 59 A3 50 75 00 00     mulss   xmm4, dword ptr [rbx+7550h]
00007FF91DFD2916  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFD291A  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD291E  73 06                       jnb     short loc_7FF91DFD2926
00007FF91DFD2920  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD2924  EB 05                       jmp     short loc_7FF91DFD292B
00007FF91DFD2926  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD292B  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFD292E  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD2931  F3 0F 59 83 00 76 00 00     mulss   xmm0, dword ptr [rbx+7600h]
00007FF91DFD2939  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD293D  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD2941  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD2945  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD2949  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD294D  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD2951  F3 0F 10 8B B0 72 00 00     movss   xmm1, dword ptr [rbx+72B0h]
00007FF91DFD2959  F3 0F 11 AB B0 72 00 00     movss   dword ptr [rbx+72B0h], xmm5
00007FF91DFD2961  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD2964  F3 0F 10 9B C0 72 00 00     movss   xmm3, dword ptr [rbx+72C0h]
00007FF91DFD296C  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD2970  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD2973  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD2977  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD297B  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFD297F  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFD2983  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD2987  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD298B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD298E  F3 0F 11 A3 C0 72 00 00     movss   dword ptr [rbx+72C0h], xmm4
00007FF91DFD2996  F3 0F 10 8B D0 72 00 00     movss   xmm1, dword ptr [rbx+72D0h]
00007FF91DFD299E  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD29A2  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD29A6  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD29A9  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD29AD  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFD29B1  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD29B5  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFD29B9  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD29BD  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD29C1  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD29C5  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD29C9  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD29CC  F3 0F 11 9B D0 72 00 00     movss   dword ptr [rbx+72D0h], xmm3
00007FF91DFD29D4  F3 0F 10 AB E0 72 00 00     movss   xmm5, dword ptr [rbx+72E0h]
00007FF91DFD29DC  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD29E0  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD29E4  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD29E7  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD29EB  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD29EF  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD29F3  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFD29F7  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD29FB  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD29FF  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD2A03  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD2A07  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2A0A  F3 0F 11 93 E0 72 00 00     movss   dword ptr [rbx+72E0h], xmm2
00007FF91DFD2A12  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFD2A16  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD2A1A  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD2A1E  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFD2A23  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2A26  F3 0F 59 83 F0 72 00 00     mulss   xmm0, dword ptr [rbx+72F0h]
00007FF91DFD2A2E  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD2A32  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD2A36  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2A39  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFD2A3D  F3 0F 11 AB F0 72 00 00     movss   dword ptr [rbx+72F0h], xmm5
00007FF91DFD2A45  F3 0F 10 93 E0 72 00 00     movss   xmm2, dword ptr [rbx+72E0h]
00007FF91DFD2A4D  F3 0F 59 93 A0 75 00 00     mulss   xmm2, dword ptr [rbx+75A0h]
00007FF91DFD2A55  F3 0F 10 8B 10 75 00 00     movss   xmm1, dword ptr [rbx+7510h]
00007FF91DFD2A5D  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD2A61  F3 0F 59 AB B0 75 00 00     mulss   xmm5, dword ptr [rbx+75B0h]
00007FF91DFD2A69  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2A6D  F3 0F 10 83 90 75 00 00     movss   xmm0, dword ptr [rbx+7590h]
00007FF91DFD2A75  F3 0F 59 83 D0 72 00 00     mulss   xmm0, dword ptr [rbx+72D0h]
00007FF91DFD2A7D  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFD2A81  F3 0F 10 AB 20 75 00 00     movss   xmm5, dword ptr [rbx+7520h]
00007FF91DFD2A89  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD2A8D  F3 0F 11 93 10 74 00 00     movss   dword ptr [rbx+7410h], xmm2
00007FF91DFD2A95  F3 0F 59 AB 30 76 00 00     mulss   xmm5, dword ptr [rbx+7630h]
00007FF91DFD2A9D  F3 0F 59 8B 20 76 00 00     mulss   xmm1, dword ptr [rbx+7620h]
00007FF91DFD2AA5  F3 0F 10 83 00 73 00 00     movss   xmm0, dword ptr [rbx+7300h]
00007FF91DFD2AAD  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD2AB1  F3 0F 59 AB 60 75 00 00     mulss   xmm5, dword ptr [rbx+7560h]
00007FF91DFD2AB9  F3 0F 11 A3 00 73 00 00     movss   dword ptr [rbx+7300h], xmm4
00007FF91DFD2AC1  F3 0F 59 A3 50 77 00 00     mulss   xmm4, dword ptr [rbx+7750h]
00007FF91DFD2AC9  F3 0F 59 83 60 77 00 00     mulss   xmm0, dword ptr [rbx+7760h]
00007FF91DFD2AD1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2AD5  F3 0F 59 A3 50 75 00 00     mulss   xmm4, dword ptr [rbx+7550h]
00007FF91DFD2ADD  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFD2AE1  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD2AE5  73 06                       jnb     short loc_7FF91DFD2AED
00007FF91DFD2AE7  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD2AEB  EB 05                       jmp     short loc_7FF91DFD2AF2
00007FF91DFD2AED  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD2AF2  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFD2AF5  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD2AF8  F3 0F 59 83 00 76 00 00     mulss   xmm0, dword ptr [rbx+7600h]
00007FF91DFD2B00  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD2B04  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD2B08  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD2B0C  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD2B10  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD2B14  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD2B18  F3 0F 10 8B B0 72 00 00     movss   xmm1, dword ptr [rbx+72B0h]
00007FF91DFD2B20  F3 0F 11 AB B0 72 00 00     movss   dword ptr [rbx+72B0h], xmm5
00007FF91DFD2B28  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD2B2B  F3 0F 10 9B C0 72 00 00     movss   xmm3, dword ptr [rbx+72C0h]
00007FF91DFD2B33  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD2B37  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD2B3A  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD2B3E  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD2B42  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFD2B46  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFD2B4A  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD2B4E  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2B52  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2B55  F3 0F 11 A3 C0 72 00 00     movss   dword ptr [rbx+72C0h], xmm4
00007FF91DFD2B5D  F3 0F 10 8B D0 72 00 00     movss   xmm1, dword ptr [rbx+72D0h]
00007FF91DFD2B65  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD2B69  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD2B6D  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD2B70  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD2B74  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFD2B78  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD2B7C  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFD2B80  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD2B84  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD2B88  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD2B8C  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD2B90  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2B93  F3 0F 11 9B D0 72 00 00     movss   dword ptr [rbx+72D0h], xmm3
00007FF91DFD2B9B  F3 0F 10 AB E0 72 00 00     movss   xmm5, dword ptr [rbx+72E0h]
00007FF91DFD2BA3  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD2BA7  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2BAB  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD2BAE  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD2BB2  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD2BB6  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD2BBA  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFD2BBE  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD2BC2  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD2BC6  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFD2BCA  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD2BCE  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2BD1  F3 0F 11 93 E0 72 00 00     movss   dword ptr [rbx+72E0h], xmm2
00007FF91DFD2BD9  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFD2BDD  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD2BE1  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD2BE5  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFD2BEA  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2BED  F3 0F 59 83 F0 72 00 00     mulss   xmm0, dword ptr [rbx+72F0h]
00007FF91DFD2BF5  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD2BF9  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD2BFD  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2C00  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFD2C04  F3 0F 11 AB F0 72 00 00     movss   dword ptr [rbx+72F0h], xmm5
00007FF91DFD2C0C  F3 0F 10 8B E0 72 00 00     movss   xmm1, dword ptr [rbx+72E0h]
00007FF91DFD2C14  F3 0F 59 8B A0 75 00 00     mulss   xmm1, dword ptr [rbx+75A0h]
00007FF91DFD2C1C  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD2C20  F3 0F 59 AB B0 75 00 00     mulss   xmm5, dword ptr [rbx+75B0h]
00007FF91DFD2C28  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD2C2C  F3 0F 10 83 90 75 00 00     movss   xmm0, dword ptr [rbx+7590h]
00007FF91DFD2C34  F3 0F 59 83 D0 72 00 00     mulss   xmm0, dword ptr [rbx+72D0h]
00007FF91DFD2C3C  F3 0F 58 CD                 addss   xmm1, xmm5
00007FF91DFD2C40  F3 0F 10 AB 10 75 00 00     movss   xmm5, dword ptr [rbx+7510h]
00007FF91DFD2C48  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD2C4C  F3 0F 11 8B 90 73 00 00     movss   dword ptr [rbx+7390h], xmm1
00007FF91DFD2C54  F3 0F 59 AB 10 76 00 00     mulss   xmm5, dword ptr [rbx+7610h]
00007FF91DFD2C5C  F3 0F 10 83 00 73 00 00     movss   xmm0, dword ptr [rbx+7300h]
00007FF91DFD2C64  F3 0F 59 AB 60 75 00 00     mulss   xmm5, dword ptr [rbx+7560h]
00007FF91DFD2C6C  F3 0F 11 9B 90 72 00 00     movss   dword ptr [rbx+7290h], xmm3
00007FF91DFD2C74  F3 0F 59 9B 50 77 00 00     mulss   xmm3, dword ptr [rbx+7750h]
00007FF91DFD2C7C  F3 0F 59 83 60 77 00 00     mulss   xmm0, dword ptr [rbx+7760h]
00007FF91DFD2C84  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD2C88  F3 0F 59 9B 50 75 00 00     mulss   xmm3, dword ptr [rbx+7550h]
00007FF91DFD2C90  F3 0F 5C EB                 subss   xmm5, xmm3
00007FF91DFD2C94  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD2C98  73 06                       jnb     short loc_7FF91DFD2CA0
00007FF91DFD2C9A  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD2C9E  EB 05                       jmp     short loc_7FF91DFD2CA5
00007FF91DFD2CA0  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD2CA5  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFD2CA8  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD2CAB  F3 0F 59 83 00 76 00 00     mulss   xmm0, dword ptr [rbx+7600h]
00007FF91DFD2CB3  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD2CB7  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD2CBB  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD2CBF  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFD2CC3  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD2CC7  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD2CCB  F3 0F 11 AB 30 72 00 00     movss   dword ptr [rbx+7230h], xmm5
00007FF91DFD2CD3  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD2CD6  F3 0F 58 AB B0 72 00 00     addss   xmm5, dword ptr [rbx+72B0h]
00007FF91DFD2CDE  F3 0F 10 9B C0 72 00 00     movss   xmm3, dword ptr [rbx+72C0h]
00007FF91DFD2CE6  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD2CE9  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD2CED  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD2CF1  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFD2CF5  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFD2CF9  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD2CFD  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2D01  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2D04  F3 0F 11 A3 40 72 00 00     movss   dword ptr [rbx+7240h], xmm4
00007FF91DFD2D0C  F3 0F 10 8B D0 72 00 00     movss   xmm1, dword ptr [rbx+72D0h]
00007FF91DFD2D14  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD2D18  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD2D1C  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD2D1F  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD2D23  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFD2D27  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD2D2B  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFD2D2F  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD2D33  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFD2D37  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD2D3B  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD2D3F  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2D42  F3 0F 11 9B 50 72 00 00     movss   dword ptr [rbx+7250h], xmm3
00007FF91DFD2D4A  F3 0F 10 AB E0 72 00 00     movss   xmm5, dword ptr [rbx+72E0h]
00007FF91DFD2D52  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD2D56  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2D5A  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD2D5D  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD2D61  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD2D65  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD2D69  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFD2D6D  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD2D71  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD2D75  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD2D79  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2D7C  F3 0F 11 93 60 72 00 00     movss   dword ptr [rbx+7260h], xmm2
00007FF91DFD2D84  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFD2D88  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD2D8C  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD2D90  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFD2D95  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD2D98  F3 0F 59 83 F0 72 00 00     mulss   xmm0, dword ptr [rbx+72F0h]
00007FF91DFD2DA0  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD2DA4  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD2DA8  F3 44 0F 59 C1              mulss   xmm8, xmm1
00007FF91DFD2DAD  F3 0F 11 AB 70 72 00 00     movss   dword ptr [rbx+7270h], xmm5
00007FF91DFD2DB5  F3 0F 10 9B 50 72 00 00     movss   xmm3, dword ptr [rbx+7250h]
00007FF91DFD2DBD  F3 0F 59 F5                 mulss   xmm6, xmm5
00007FF91DFD2DC1  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFD2DC6  F3 44 0F 11 83 80 72 00 00  movss   dword ptr [rbx+7280h], xmm8
00007FF91DFD2DCF  F3 0F 10 83 A0 75 00 00     movss   xmm0, dword ptr [rbx+75A0h]
00007FF91DFD2DD7  F3 0F 59 83 60 72 00 00     mulss   xmm0, dword ptr [rbx+7260h]
00007FF91DFD2DDF  F3 0F 59 AB B0 75 00 00     mulss   xmm5, dword ptr [rbx+75B0h]
00007FF91DFD2DE7  F3 0F 59 9B 90 75 00 00     mulss   xmm3, dword ptr [rbx+7590h]
00007FF91DFD2DEF  F3 0F 10 A3 50 73 00 00     movss   xmm4, dword ptr [rbx+7350h]
00007FF91DFD2DF7  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD2DFB  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFD2DFF  F3 0F 11 AB 10 73 00 00     movss   dword ptr [rbx+7310h], xmm5
00007FF91DFD2E07  F3 0F 58 A3 C0 74 00 00     addss   xmm4, dword ptr [rbx+74C0h]
00007FF91DFD2E0F  F3 0F 10 83 D0 73 00 00     movss   xmm0, dword ptr [rbx+73D0h]
00007FF91DFD2E17  F3 0F 58 83 40 74 00 00     addss   xmm0, dword ptr [rbx+7440h]
00007FF91DFD2E1F  F3 0F 10 8B 50 74 00 00     movss   xmm1, dword ptr [rbx+7450h]
00007FF91DFD2E27  F3 0F 58 8B C0 73 00 00     addss   xmm1, dword ptr [rbx+73C0h]
00007FF91DFD2E2F  F3 0F 59 A3 40 77 00 00     mulss   xmm4, dword ptr [rbx+7740h]
00007FF91DFD2E37  F3 0F 59 83 30 77 00 00     mulss   xmm0, dword ptr [rbx+7730h]
00007FF91DFD2E3F  F3 0F 59 8B 20 77 00 00     mulss   xmm1, dword ptr [rbx+7720h]
00007FF91DFD2E47  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2E4B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD2E4F  F3 0F 10 83 40 73 00 00     movss   xmm0, dword ptr [rbx+7340h]
00007FF91DFD2E57  F3 0F 58 83 D0 74 00 00     addss   xmm0, dword ptr [rbx+74D0h]
00007FF91DFD2E5F  F3 0F 10 8B B0 74 00 00     movss   xmm1, dword ptr [rbx+74B0h]
00007FF91DFD2E67  F3 0F 58 8B 60 73 00 00     addss   xmm1, dword ptr [rbx+7360h]
00007FF91DFD2E6F  F3 0F 58 AB 00 75 00 00     addss   xmm5, dword ptr [rbx+7500h]
00007FF91DFD2E77  F3 0F 59 83 10 77 00 00     mulss   xmm0, dword ptr [rbx+7710h]
00007FF91DFD2E7F  F3 0F 59 8B 00 77 00 00     mulss   xmm1, dword ptr [rbx+7700h]
00007FF91DFD2E87  F3 0F 59 AB 50 76 00 00     mulss   xmm5, dword ptr [rbx+7650h]
00007FF91DFD2E8F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2E93  F3 0F 10 83 30 74 00 00     movss   xmm0, dword ptr [rbx+7430h]
00007FF91DFD2E9B  F3 0F 58 83 E0 73 00 00     addss   xmm0, dword ptr [rbx+73E0h]
00007FF91DFD2EA3  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD2EA7  F3 0F 10 8B 60 74 00 00     movss   xmm1, dword ptr [rbx+7460h]
00007FF91DFD2EAF  F3 0F 58 8B B0 73 00 00     addss   xmm1, dword ptr [rbx+73B0h]
00007FF91DFD2EB7  F3 0F 59 83 F0 76 00 00     mulss   xmm0, dword ptr [rbx+76F0h]
00007FF91DFD2EBF  F3 0F 59 8B E0 76 00 00     mulss   xmm1, dword ptr [rbx+76E0h]
00007FF91DFD2EC7  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2ECB  F3 0F 10 83 E0 74 00 00     movss   xmm0, dword ptr [rbx+74E0h]
00007FF91DFD2ED3  F3 0F 58 83 30 73 00 00     addss   xmm0, dword ptr [rbx+7330h]
00007FF91DFD2EDB  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD2EDF  F3 0F 10 8B A0 74 00 00     movss   xmm1, dword ptr [rbx+74A0h]
00007FF91DFD2EE7  F3 0F 59 83 D0 76 00 00     mulss   xmm0, dword ptr [rbx+76D0h]
00007FF91DFD2EEF  F3 0F 58 8B 70 73 00 00     addss   xmm1, dword ptr [rbx+7370h]
00007FF91DFD2EF7  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2EFB  F3 0F 10 83 20 74 00 00     movss   xmm0, dword ptr [rbx+7420h]
00007FF91DFD2F03  F3 0F 58 83 F0 73 00 00     addss   xmm0, dword ptr [rbx+73F0h]
00007FF91DFD2F0B  F3 0F 59 8B C0 76 00 00     mulss   xmm1, dword ptr [rbx+76C0h]
00007FF91DFD2F13  F3 0F 59 83 B0 76 00 00     mulss   xmm0, dword ptr [rbx+76B0h]
00007FF91DFD2F1B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD2F1F  F3 0F 10 8B 70 74 00 00     movss   xmm1, dword ptr [rbx+7470h]
00007FF91DFD2F27  F3 0F 58 8B A0 73 00 00     addss   xmm1, dword ptr [rbx+73A0h]
00007FF91DFD2F2F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2F33  F3 0F 10 83 F0 74 00 00     movss   xmm0, dword ptr [rbx+74F0h]
00007FF91DFD2F3B  F3 0F 59 8B A0 76 00 00     mulss   xmm1, dword ptr [rbx+76A0h]
00007FF91DFD2F43  F3 0F 58 83 20 73 00 00     addss   xmm0, dword ptr [rbx+7320h]
00007FF91DFD2F4B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD2F4F  F3 0F 10 8B 90 74 00 00     movss   xmm1, dword ptr [rbx+7490h]
00007FF91DFD2F57  F3 0F 58 8B 80 73 00 00     addss   xmm1, dword ptr [rbx+7380h]
00007FF91DFD2F5F  F3 0F 59 83 90 76 00 00     mulss   xmm0, dword ptr [rbx+7690h]
00007FF91DFD2F67  F3 0F 59 8B 80 76 00 00     mulss   xmm1, dword ptr [rbx+7680h]
00007FF91DFD2F6F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2F73  F3 0F 10 83 10 74 00 00     movss   xmm0, dword ptr [rbx+7410h]
00007FF91DFD2F7B  F3 0F 58 83 00 74 00 00     addss   xmm0, dword ptr [rbx+7400h]
00007FF91DFD2F83  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD2F87  F3 0F 10 8B 80 74 00 00     movss   xmm1, dword ptr [rbx+7480h]
00007FF91DFD2F8F  F3 0F 59 83 70 76 00 00     mulss   xmm0, dword ptr [rbx+7670h]
00007FF91DFD2F97  F3 0F 58 8B 90 73 00 00     addss   xmm1, dword ptr [rbx+7390h]
00007FF91DFD2F9F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD2FA3  F3 0F 59 8B 60 76 00 00     mulss   xmm1, dword ptr [rbx+7660h]
00007FF91DFD2FAB  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD2FAF  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD2FB3  F3 0F 59 A3 E0 75 00 00     mulss   xmm4, dword ptr [rbx+75E0h]
00007FF91DFD2FBB  F3 0F 11 A3 70 75 00 00     movss   dword ptr [rbx+7570h], xmm4
00007FF91DFD2FC3  8B 83 70 77 00 00           mov     eax, [rbx+7770h]
00007FF91DFD2FC9  89 83 80 77 00 00           mov     [rbx+7780h], eax
00007FF91DFD2FCF  F3 0F 10 83 A0 77 00 00     movss   xmm0, dword ptr [rbx+77A0h]
00007FF91DFD2FD7  8B 83 90 77 00 00           mov     eax, [rbx+7790h]
00007FF91DFD2FDD  89 83 C0 77 00 00           mov     [rbx+77C0h], eax
00007FF91DFD2FE3  F3 0F 11 83 D0 77 00 00     movss   dword ptr [rbx+77D0h], xmm0
00007FF91DFD2FEB  8B 83 B0 77 00 00           mov     eax, [rbx+77B0h]
00007FF91DFD2FF1  89 83 E0 77 00 00           mov     [rbx+77E0h], eax
00007FF91DFD2FF7  F3 0F 10 93 F0 77 00 00     movss   xmm2, dword ptr [rbx+77F0h]
00007FF91DFD2FFF  F3 0F 11 93 00 78 00 00     movss   dword ptr [rbx+7800h], xmm2
00007FF91DFD3007  F3 0F 10 83 10 78 00 00     movss   xmm0, dword ptr [rbx+7810h]
00007FF91DFD300F  F3 0F 11 83 20 78 00 00     movss   dword ptr [rbx+7820h], xmm0
00007FF91DFD3017  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD301B  F3 0F 59 93 30 78 00 00     mulss   xmm2, dword ptr [rbx+7830h]
00007FF91DFD3023  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD3027  F3 0F 11 93 10 78 00 00     movss   dword ptr [rbx+7810h], xmm2
00007FF91DFD302F  F3 0F 10 83 D0 77 00 00     movss   xmm0, dword ptr [rbx+77D0h]
00007FF91DFD3037  F3 0F 10 8B E0 77 00 00     movss   xmm1, dword ptr [rbx+77E0h]
00007FF91DFD303F  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD3043  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD3047  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD304B  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD304F  F3 0F 11 93 40 78 00 00     movss   dword ptr [rbx+7840h], xmm2
00007FF91DFD3057  F3 0F 10 8B 50 78 00 00     movss   xmm1, dword ptr [rbx+7850h]
00007FF91DFD305F  F3 0F 11 8B 60 78 00 00     movss   dword ptr [rbx+7860h], xmm1
00007FF91DFD3067  F3 0F 10 83 70 78 00 00     movss   xmm0, dword ptr [rbx+7870h]
00007FF91DFD306F  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFD3072  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD3076  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFD307A  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD307E  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD3082  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFD3086  76 05                       jbe     short loc_7FF91DFD308D
00007FF91DFD3088  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFD308B  EB 03                       jmp     short loc_7FF91DFD3090
00007FF91DFD308D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD3090  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD3094  F3 0F 11 83 50 78 00 00     movss   dword ptr [rbx+7850h], xmm0
00007FF91DFD309C  F3 0F 10 8B 80 78 00 00     movss   xmm1, dword ptr [rbx+7880h]
00007FF91DFD30A4  F3 0F 11 8B 90 78 00 00     movss   dword ptr [rbx+7890h], xmm1
00007FF91DFD30AC  F3 0F 10 93 A0 78 00 00     movss   xmm2, dword ptr [rbx+78A0h]
00007FF91DFD30B4  F3 0F 11 93 B0 78 00 00     movss   dword ptr [rbx+78B0h], xmm2
00007FF91DFD30BC  F3 0F 10 83 C0 78 00 00     movss   xmm0, dword ptr [rbx+78C0h]
00007FF91DFD30C4  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFD30C7  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD30CB  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFD30CF  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD30D3  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD30D7  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFD30DB  76 05                       jbe     short loc_7FF91DFD30E2
00007FF91DFD30DD  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFD30E0  EB 03                       jmp     short loc_7FF91DFD30E5
00007FF91DFD30E2  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD30E5  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD30E9  F3 0F 11 83 A0 78 00 00     movss   dword ptr [rbx+78A0h], xmm0
00007FF91DFD30F1  F3 0F 10 AB D0 78 00 00     movss   xmm5, dword ptr [rbx+78D0h]
00007FF91DFD30F9  F3 0F 10 B3 50 54 00 00     movss   xmm6, dword ptr [rbx+5450h]
00007FF91DFD3101  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFD3104  F3 0F 11 AB E0 78 00 00     movss   dword ptr [rbx+78E0h], xmm5
00007FF91DFD310C  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFD310F  F3 0F 59 A3 30 79 00 00     mulss   xmm4, dword ptr [rbx+7930h]
00007FF91DFD3117  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFD311A  F3 0F 58 83 00 79 00 00     addss   xmm0, dword ptr [rbx+7900h]
00007FF91DFD3122  F3 0F 58 9B 20 79 00 00     addss   xmm3, dword ptr [rbx+7920h]
00007FF91DFD312A  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD312E  73 06                       jnb     short loc_7FF91DFD3136
00007FF91DFD3130  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD3134  EB 05                       jmp     short loc_7FF91DFD313B
00007FF91DFD3136  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD313B  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD313F  72 1B                       jb      short loc_7FF91DFD315C
00007FF91DFD3141  F3 0F 10 83 10 79 00 00     movss   xmm0, dword ptr [rbx+7910h]
00007FF91DFD3149  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFD314C  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD3150  F3 0F 59 DE                 mulss   xmm3, xmm6
00007FF91DFD3154  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD3158  F3 0F 58 DD                 addss   xmm3, xmm5
00007FF91DFD315C  41 0F 2E F6                 ucomiss xmm6, xmm14
00007FF91DFD3160  F3 0F 10 8B 50 79 00 00     movss   xmm1, dword ptr [rbx+7950h]
00007FF91DFD3168  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD316B  F3 0F 59 93 40 79 00 00     mulss   xmm2, dword ptr [rbx+7940h]
00007FF91DFD3173  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD3176  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD317A  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD317E  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD3182  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD3185  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD3189  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFD318D  F3 0F 5C C2                 subss   xmm0, xmm2
00007FF91DFD3191  F3 0F 58 C5                 addss   xmm0, xmm5
00007FF91DFD3195  74 03                       jz      short loc_7FF91DFD319A
00007FF91DFD3197  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD319A  F3 0F 11 83 F0 78 00 00     movss   dword ptr [rbx+78F0h], xmm0
00007FF91DFD31A2  F3 0F 11 83 D0 78 00 00     movss   dword ptr [rbx+78D0h], xmm0
00007FF91DFD31AA  F3 0F 10 BB 70 75 00 00     movss   xmm7, dword ptr [rbx+7570h]
00007FF91DFD31B2  F3 0F 10 B3 E0 5C 00 00     movss   xmm6, dword ptr [rbx+5CE0h]
00007FF91DFD31BA  F3 0F 10 9B E0 6C 00 00     movss   xmm3, dword ptr [rbx+6CE0h]
00007FF91DFD31C2  F3 0F 10 83 C0 5E 00 00     movss   xmm0, dword ptr [rbx+5EC0h]
00007FF91DFD31CA  F3 0F 10 8B 70 77 00 00     movss   xmm1, dword ptr [rbx+7770h]
00007FF91DFD31D2  8B 83 90 79 00 00           mov     eax, [rbx+7990h]
00007FF91DFD31D8  89 83 A0 79 00 00           mov     [rbx+79A0h], eax
00007FF91DFD31DE  8B 83 B0 79 00 00           mov     eax, [rbx+79B0h]
00007FF91DFD31E4  89 83 C0 79 00 00           mov     [rbx+79C0h], eax
00007FF91DFD31EA  F3 0F 11 83 60 79 00 00     movss   dword ptr [rbx+7960h], xmm0
00007FF91DFD31F2  F3 0F 11 8B 70 79 00 00     movss   dword ptr [rbx+7970h], xmm1
00007FF91DFD31FA  F3 0F 59 9B 80 7A 00 00     mulss   xmm3, dword ptr [rbx+7A80h]
00007FF91DFD3202  F3 0F 10 A3 A0 79 00 00     movss   xmm4, dword ptr [rbx+79A0h]
00007FF91DFD320A  F3 0F 10 93 E0 79 00 00     movss   xmm2, dword ptr [rbx+79E0h]
00007FF91DFD3212  F3 0F 11 9B 80 79 00 00     movss   dword ptr [rbx+7980h], xmm3
00007FF91DFD321A  0F 28 DF                    movaps  xmm3, xmm7
00007FF91DFD321D  F3 0F 59 B3 F0 79 00 00     mulss   xmm6, dword ptr [rbx+79F0h]
00007FF91DFD3225  F3 0F 5C DC                 subss   xmm3, xmm4
00007FF91DFD3229  F3 0F 59 93 F0 78 00 00     mulss   xmm2, dword ptr [rbx+78F0h]
00007FF91DFD3231  F3 0F 10 8B 00 7A 00 00     movss   xmm1, dword ptr [rbx+7A00h]
00007FF91DFD3239  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD323C  F3 0F 59 83 20 7A 00 00     mulss   xmm0, dword ptr [rbx+7A20h]
00007FF91DFD3244  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFD3248  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD324C  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD3250  F3 0F 11 A3 90 79 00 00     movss   dword ptr [rbx+7990h], xmm4
00007FF91DFD3258  F3 0F 59 8B 60 79 00 00     mulss   xmm1, dword ptr [rbx+7960h]
00007FF91DFD3260  F3 0F 10 93 10 7A 00 00     movss   xmm2, dword ptr [rbx+7A10h]
00007FF91DFD3268  F3 0F 59 9B 90 7A 00 00     mulss   xmm3, dword ptr [rbx+7A90h]
00007FF91DFD3270  F3 0F 59 A3 A0 7A 00 00     mulss   xmm4, dword ptr [rbx+7AA0h]
00007FF91DFD3278  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFD327C  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD327F  F3 0F 59 8B 70 79 00 00     mulss   xmm1, dword ptr [rbx+7970h]
00007FF91DFD3287  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD328B  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD328F  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFD3293  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFD3297  F3 0F 10 B3 30 7A 00 00     movss   xmm6, dword ptr [rbx+7A30h]
00007FF91DFD329F  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFD32A3  F3 0F 59 8B 60 7A 00 00     mulss   xmm1, dword ptr [rbx+7A60h]
00007FF91DFD32AB  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFD32AF  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD32B3  76 05                       jbe     short loc_7FF91DFD32BA
00007FF91DFD32B5  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFD32B8  EB 03                       jmp     short loc_7FF91DFD32BD
00007FF91DFD32BA  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD32BD  F3 0F 10 93 50 7A 00 00     movss   xmm2, dword ptr [rbx+7A50h]
00007FF91DFD32C5  F3 0F 10 A3 40 7A 00 00     movss   xmm4, dword ptr [rbx+7A40h]
00007FF91DFD32CD  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFD32D1  F3 0F 10 83 80 79 00 00     movss   xmm0, dword ptr [rbx+7980h]
00007FF91DFD32D9  F3 0F 59 AB 70 7A 00 00     mulss   xmm5, dword ptr [rbx+7A70h]
00007FF91DFD32E1  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD32E6  F3 0F 59 F3                 mulss   xmm6, xmm3
00007FF91DFD32EA  F3 0F 10 9B C0 79 00 00     movss   xmm3, dword ptr [rbx+79C0h]
00007FF91DFD32F2  F3 0F 58 F7                 addss   xmm6, xmm7
00007FF91DFD32F6  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFD32FA  F3 0F 10 83 B0 7A 00 00     movss   xmm0, dword ptr [rbx+7AB0h]
00007FF91DFD3302  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFD3305  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD3309  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFD330D  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD3311  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD3315  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD3319  F3 0F 11 9B B0 79 00 00     movss   dword ptr [rbx+79B0h], xmm3
00007FF91DFD3321  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFD3325  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFD3329  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFD332D  F3 0F 59 A3 C0 7A 00 00     mulss   xmm4, dword ptr [rbx+7AC0h]
00007FF91DFD3335  F3 0F 11 A3 D0 79 00 00     movss   dword ptr [rbx+79D0h], xmm4
00007FF91DFD333D  8B 83 E0 7A 00 00           mov     eax, [rbx+7AE0h]
00007FF91DFD3343  89 83 F0 7A 00 00           mov     [rbx+7AF0h], eax
00007FF91DFD3349  8B 83 D0 7A 00 00           mov     eax, [rbx+7AD0h]
00007FF91DFD334F  89 83 E0 7A 00 00           mov     [rbx+7AE0h], eax
00007FF91DFD3355  F3 0F 10 83 F0 7A 00 00     movss   xmm0, dword ptr [rbx+7AF0h]
00007FF91DFD335D  F3 0F 10 8B 00 7B 00 00     movss   xmm1, dword ptr [rbx+7B00h]
00007FF91DFD3365  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFD3369  F3 0F 11 A3 D0 7A 00 00     movss   dword ptr [rbx+7AD0h], xmm4
00007FF91DFD3371  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD3375  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD3379  F3 0F 11 8B E0 7A 00 00     movss   dword ptr [rbx+7AE0h], xmm1
00007FF91DFD3381  F3 0F 10 93 D0 7A 00 00     movss   xmm2, dword ptr [rbx+7AD0h]
00007FF91DFD3389  F3 0F 10 B3 C0 77 00 00     movss   xmm6, dword ptr [rbx+77C0h]
00007FF91DFD3391  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD3394  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFD3398  8B 83 30 7B 00 00           mov     eax, [rbx+7B30h]
00007FF91DFD339E  89 83 40 7B 00 00           mov     [rbx+7B40h], eax
00007FF91DFD33A4  8B 83 20 7B 00 00           mov     eax, [rbx+7B20h]
00007FF91DFD33AA  89 83 30 7B 00 00           mov     [rbx+7B30h], eax
00007FF91DFD33B0  8B 83 10 7B 00 00           mov     eax, [rbx+7B10h]
00007FF91DFD33B6  89 83 20 7B 00 00           mov     [rbx+7B20h], eax
00007FF91DFD33BC  F3 0F 11 93 10 7B 00 00     movss   dword ptr [rbx+7B10h], xmm2
00007FF91DFD33C4  F3 0F 59 83 60 7B 00 00     mulss   xmm0, dword ptr [rbx+7B60h]
00007FF91DFD33CC  F3 0F 10 A3 20 7B 00 00     movss   xmm4, dword ptr [rbx+7B20h]
00007FF91DFD33D4  F3 0F 10 8B 80 7B 00 00     movss   xmm1, dword ptr [rbx+7B80h]
00007FF91DFD33DC  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFD33DF  F3 0F 59 8B 30 7B 00 00     mulss   xmm1, dword ptr [rbx+7B30h]
00007FF91DFD33E7  F3 0F 59 AB 70 7B 00 00     mulss   xmm5, dword ptr [rbx+7B70h]
00007FF91DFD33EF  F3 0F 59 A3 A0 7B 00 00     mulss   xmm4, dword ptr [rbx+7BA0h]
00007FF91DFD33F7  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD33FB  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD33FE  F3 0F 59 83 90 7B 00 00     mulss   xmm0, dword ptr [rbx+7B90h]
00007FF91DFD3406  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD340A  F3 0F 10 8B B0 7B 00 00     movss   xmm1, dword ptr [rbx+7BB0h]
00007FF91DFD3412  F3 0F 59 8B 40 7B 00 00     mulss   xmm1, dword ptr [rbx+7B40h]
00007FF91DFD341A  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD341E  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD3422  76 05                       jbe     short loc_7FF91DFD3429
00007FF91DFD3424  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFD3427  EB 03                       jmp     short loc_7FF91DFD342C
00007FF91DFD3429  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD342C  0F 2F 35 8D 20 77 00        comiss  xmm6, cs:dword_7FF91E7454C0
00007FF91DFD3433  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD3437  F3 0F 11 AB 20 7B 00 00     movss   dword ptr [rbx+7B20h], xmm5
00007FF91DFD343F  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFD3442  F3 0F 11 A3 30 7B 00 00     movss   dword ptr [rbx+7B30h], xmm4
00007FF91DFD344A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD344E  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD3452  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD3456  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD3459  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFD345D  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD3461  73 09                       jnb     short loc_7FF91DFD346C
00007FF91DFD3463  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFD3467  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
00007FF91DFD346C  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFD3470  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
00007FF91DFD3475  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFD3478  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD347C  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD3480  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD3484  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD3488  72 03                       jb      short loc_7FF91DFD348D
00007FF91DFD348A  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFD348D  F3 0F 11 93 50 7B 00 00     movss   dword ptr [rbx+7B50h], xmm2
00007FF91DFD3495  F3 0F 59 93 50 78 00 00     mulss   xmm2, dword ptr [rbx+7850h]
00007FF91DFD349D  F3 0F 11 93 C0 7B 00 00     movss   dword ptr [rbx+7BC0h], xmm2
00007FF91DFD34A5  F3 0F 59 93 A0 78 00 00     mulss   xmm2, dword ptr [rbx+78A0h]
00007FF91DFD34AD  F3 0F 11 93 D0 7B 00 00     movss   dword ptr [rbx+7BD0h], xmm2
00007FF91DFD34B5  F3 0F 10 83 80 63 00 00     movss   xmm0, dword ptr [rbx+6380h]
00007FF91DFD34BD  F3 0F 58 83 E0 60 00 00     addss   xmm0, dword ptr [rbx+60E0h]
00007FF91DFD34C5  44 0F 5A E0                 cvtps2pd xmm12, xmm0
00007FF91DFD34C9  F2 44 0F 5F 25 D6 77 61 00  maxsd   xmm12, cs:qword_7FF91E5EACA8
00007FF91DFD34D2  F2 44 0F 5D 25 B5 77 61 00  minsd   xmm12, cs:qword_7FF91E5EAC90
00007FF91DFD34DB  41 0F 28 CC                 movaps  xmm1, xmm12
00007FF91DFD34DF  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFD34E3  F2 0F 58 05 7D 1D 77 00     addsd   xmm0, cs:qword_7FF91E745268
00007FF91DFD34EB  F2 41 0F 59 CC              mulsd   xmm1, xmm12
00007FF91DFD34F0  41 0F 28 FC                 movaps  xmm7, xmm12
00007FF91DFD34F4  F2 0F 2C C0                 cvttsd2si eax, xmm0
00007FF91DFD34F8  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFD34FB  48 63 C8                    movsxd  rcx, eax
00007FF91DFD34FE  F2 41 0F 59 D4              mulsd   xmm2, xmm12
00007FF91DFD3503  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
00007FF91DFD350A  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD350D  F2 41 0F 59 DC              mulsd   xmm3, xmm12
00007FF91DFD3512  48 8D 0D C7 5F 61 00        lea     rcx, unk_7FF91E5E94E0
00007FF91DFD3519  48 03 C1                    add     rax, rcx
00007FF91DFD351C  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFD351F  F2 41 0F 59 E4              mulsd   xmm4, xmm12
00007FF91DFD3524  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
00007FF91DFD3529  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
00007FF91DFD352E  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
00007FF91DFD3533  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFD3536  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
00007FF91DFD353A  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
00007FF91DFD353F  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
00007FF91DFD3544  F2 0F 58 F9                 addsd   xmm7, xmm1
00007FF91DFD3548  F2 41 0F 59 EC              mulsd   xmm5, xmm12
00007FF91DFD354D  F2 0F 58 FA                 addsd   xmm7, xmm2
00007FF91DFD3551  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFD3554  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
00007FF91DFD3559  F2 41 0F 59 F4              mulsd   xmm6, xmm12
00007FF91DFD355E  F2 0F 58 FB                 addsd   xmm7, xmm3
00007FF91DFD3562  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFD3566  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
00007FF91DFD356B  F2 0F 58 FC                 addsd   xmm7, xmm4
00007FF91DFD356F  F2 45 0F 59 C4              mulsd   xmm8, xmm12
00007FF91DFD3574  F2 0F 58 FD                 addsd   xmm7, xmm5
00007FF91DFD3578  45 0F 28 C8                 movaps  xmm9, xmm8
00007FF91DFD357C  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
00007FF91DFD3585  F2 45 0F 59 CC              mulsd   xmm9, xmm12
00007FF91DFD358A  F2 0F 58 FE                 addsd   xmm7, xmm6
00007FF91DFD358E  45 0F 28 D1                 movaps  xmm10, xmm9
00007FF91DFD3592  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
00007FF91DFD359B  F2 41 0F 58 F8              addsd   xmm7, xmm8
00007FF91DFD35A0  F2 45 0F 59 D4              mulsd   xmm10, xmm12
00007FF91DFD35A5  F2 41 0F 58 F9              addsd   xmm7, xmm9
00007FF91DFD35AA  45 0F 28 DA                 movaps  xmm11, xmm10
00007FF91DFD35AE  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
00007FF91DFD35B7  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFD35BC  F2 41 0F 58 FA              addsd   xmm7, xmm10
00007FF91DFD35C1  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFD35C5  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFD35CA  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
00007FF91DFD35D2  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
00007FF91DFD35DB  F2 0F 58 F8                 addsd   xmm7, xmm0
00007FF91DFD35DF  F2 41 0F 58 FB              addsd   xmm7, xmm11
00007FF91DFD35E4  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
00007FF91DFD35E8  F3 0F 5D 1D A8 76 61 00     minss   xmm3, cs:dword_7FF91E5EAC98
00007FF91DFD35F0  F3 0F 5F 1D B8 76 61 00     maxss   xmm3, cs:dword_7FF91E5EACB0
00007FF91DFD35F8  F3 0F 59 9B F0 60 00 00     mulss   xmm3, dword ptr [rbx+60F0h]
00007FF91DFD3600  F3 0F 11 9B 60 63 00 00     movss   dword ptr [rbx+6360h], xmm3
00007FF91DFD3608  8B 83 00 65 00 00           mov     eax, [rbx+6500h]
00007FF91DFD360E  F3 0F 10 AB E0 60 00 00     movss   xmm5, dword ptr [rbx+60E0h]
00007FF91DFD3616  F3 0F 10 83 B0 62 00 00     movss   xmm0, dword ptr [rbx+62B0h]
00007FF91DFD361E  F3 0F 10 8B C0 62 00 00     movss   xmm1, dword ptr [rbx+62C0h]
00007FF91DFD3626  F3 0F 10 93 D0 62 00 00     movss   xmm2, dword ptr [rbx+62D0h]
00007FF91DFD362E  89 83 10 65 00 00           mov     [rbx+6510h], eax
00007FF91DFD3634  8B 83 20 65 00 00           mov     eax, [rbx+6520h]
00007FF91DFD363A  89 83 30 65 00 00           mov     [rbx+6530h], eax
00007FF91DFD3640  8B 83 D0 65 00 00           mov     eax, [rbx+65D0h]
00007FF91DFD3646  89 83 E0 65 00 00           mov     [rbx+65E0h], eax
00007FF91DFD364C  8B 83 C0 65 00 00           mov     eax, [rbx+65C0h]
00007FF91DFD3652  89 83 D0 65 00 00           mov     [rbx+65D0h], eax
00007FF91DFD3658  8B 83 B0 65 00 00           mov     eax, [rbx+65B0h]
00007FF91DFD365E  89 83 C0 65 00 00           mov     [rbx+65C0h], eax
00007FF91DFD3664  8B 83 A0 65 00 00           mov     eax, [rbx+65A0h]
00007FF91DFD366A  89 83 B0 65 00 00           mov     [rbx+65B0h], eax
00007FF91DFD3670  8B 83 90 65 00 00           mov     eax, [rbx+6590h]
00007FF91DFD3676  89 83 A0 65 00 00           mov     [rbx+65A0h], eax
00007FF91DFD367C  8B 83 80 65 00 00           mov     eax, [rbx+6580h]
00007FF91DFD3682  89 83 90 65 00 00           mov     [rbx+6590h], eax
00007FF91DFD3688  8B 83 70 65 00 00           mov     eax, [rbx+6570h]
00007FF91DFD368E  89 83 80 65 00 00           mov     [rbx+6580h], eax
00007FF91DFD3694  8B 83 50 66 00 00           mov     eax, [rbx+6650h]
00007FF91DFD369A  89 83 60 66 00 00           mov     [rbx+6660h], eax
00007FF91DFD36A0  8B 83 40 66 00 00           mov     eax, [rbx+6640h]
00007FF91DFD36A6  89 83 50 66 00 00           mov     [rbx+6650h], eax
00007FF91DFD36AC  8B 83 30 66 00 00           mov     eax, [rbx+6630h]
00007FF91DFD36B2  89 83 40 66 00 00           mov     [rbx+6640h], eax
00007FF91DFD36B8  8B 83 20 66 00 00           mov     eax, [rbx+6620h]
00007FF91DFD36BE  89 83 30 66 00 00           mov     [rbx+6630h], eax
00007FF91DFD36C4  8B 83 10 66 00 00           mov     eax, [rbx+6610h]
00007FF91DFD36CA  89 83 20 66 00 00           mov     [rbx+6620h], eax
00007FF91DFD36D0  8B 83 00 66 00 00           mov     eax, [rbx+6600h]
00007FF91DFD36D6  89 83 10 66 00 00           mov     [rbx+6610h], eax
00007FF91DFD36DC  8B 83 F0 65 00 00           mov     eax, [rbx+65F0h]
00007FF91DFD36E2  89 83 00 66 00 00           mov     [rbx+6600h], eax
00007FF91DFD36E8  8B 83 D0 66 00 00           mov     eax, [rbx+66D0h]
00007FF91DFD36EE  89 83 E0 66 00 00           mov     [rbx+66E0h], eax
00007FF91DFD36F4  8B 83 C0 66 00 00           mov     eax, [rbx+66C0h]
00007FF91DFD36FA  89 83 D0 66 00 00           mov     [rbx+66D0h], eax
00007FF91DFD3700  8B 83 B0 66 00 00           mov     eax, [rbx+66B0h]
00007FF91DFD3706  89 83 C0 66 00 00           mov     [rbx+66C0h], eax
00007FF91DFD370C  8B 83 A0 66 00 00           mov     eax, [rbx+66A0h]
00007FF91DFD3712  89 83 B0 66 00 00           mov     [rbx+66B0h], eax
00007FF91DFD3718  8B 83 90 66 00 00           mov     eax, [rbx+6690h]
00007FF91DFD371E  89 83 A0 66 00 00           mov     [rbx+66A0h], eax
00007FF91DFD3724  8B 83 80 66 00 00           mov     eax, [rbx+6680h]
00007FF91DFD372A  89 83 90 66 00 00           mov     [rbx+6690h], eax
00007FF91DFD3730  8B 83 70 66 00 00           mov     eax, [rbx+6670h]
00007FF91DFD3736  89 83 80 66 00 00           mov     [rbx+6680h], eax
00007FF91DFD373C  8B 83 50 67 00 00           mov     eax, [rbx+6750h]
00007FF91DFD3742  89 83 60 67 00 00           mov     [rbx+6760h], eax
00007FF91DFD3748  8B 83 40 67 00 00           mov     eax, [rbx+6740h]
00007FF91DFD374E  89 83 50 67 00 00           mov     [rbx+6750h], eax
00007FF91DFD3754  8B 83 30 67 00 00           mov     eax, [rbx+6730h]
00007FF91DFD375A  89 83 40 67 00 00           mov     [rbx+6740h], eax
00007FF91DFD3760  8B 83 20 67 00 00           mov     eax, [rbx+6720h]
00007FF91DFD3766  89 83 30 67 00 00           mov     [rbx+6730h], eax
00007FF91DFD376C  8B 83 10 67 00 00           mov     eax, [rbx+6710h]
00007FF91DFD3772  89 83 20 67 00 00           mov     [rbx+6720h], eax
00007FF91DFD3778  8B 83 00 67 00 00           mov     eax, [rbx+6700h]
00007FF91DFD377E  89 83 10 67 00 00           mov     [rbx+6710h], eax
00007FF91DFD3784  8B 83 F0 66 00 00           mov     eax, [rbx+66F0h]
00007FF91DFD378A  89 83 00 67 00 00           mov     [rbx+6700h], eax
00007FF91DFD3790  8B 83 90 67 00 00           mov     eax, [rbx+6790h]
00007FF91DFD3796  89 83 A0 67 00 00           mov     [rbx+67A0h], eax
00007FF91DFD379C  8B 83 80 67 00 00           mov     eax, [rbx+6780h]
00007FF91DFD37A2  89 83 90 67 00 00           mov     [rbx+6790h], eax
00007FF91DFD37A8  F3 0F 11 83 A0 64 00 00     movss   dword ptr [rbx+64A0h], xmm0
00007FF91DFD37B0  F3 0F 11 8B B0 64 00 00     movss   dword ptr [rbx+64B0h], xmm1
00007FF91DFD37B8  F3 0F 58 AB C0 6A 00 00     addss   xmm5, dword ptr [rbx+6AC0h]
00007FF91DFD37C0  F3 0F 59 9B C0 67 00 00     mulss   xmm3, dword ptr [rbx+67C0h]
00007FF91DFD37C8  F3 0F 10 83 B0 67 00 00     movss   xmm0, dword ptr [rbx+67B0h]
00007FF91DFD37D0  F3 0F 11 93 C0 64 00 00     movss   dword ptr [rbx+64C0h], xmm2
00007FF91DFD37D8  F3 0F 10 93 E0 67 00 00     movss   xmm2, dword ptr [rbx+67E0h]
00007FF91DFD37E0  F3 0F 59 AB D0 6A 00 00     mulss   xmm5, dword ptr [rbx+6AD0h]
00007FF91DFD37E8  F3 0F 5F D3                 maxss   xmm2, xmm3
00007FF91DFD37EC  F3 0F 58 AB B0 6A 00 00     addss   xmm5, dword ptr [rbx+6AB0h]
00007FF91DFD37F4  F3 0F 11 93 D0 64 00 00     movss   dword ptr [rbx+64D0h], xmm2
00007FF91DFD37FC  F3 0F 58 83 00 61 00 00     addss   xmm0, dword ptr [rbx+6100h]
00007FF91DFD3804  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFD3808  F3 0F 11 83 F0 64 00 00     movss   dword ptr [rbx+64F0h], xmm0
00007FF91DFD3810  76 05                       jbe     short loc_7FF91DFD3817
00007FF91DFD3812  0F 5A C5                    cvtps2pd xmm0, xmm5
00007FF91DFD3815  EB 03                       jmp     short loc_7FF91DFD381A
00007FF91DFD3817  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD381A  F3 0F 10 0D 3A 17 77 00     movss   xmm1, cs:dword_7FF91E744F5C
00007FF91DFD3822  F3 44 0F 10 15 BD 19 77 00  movss   xmm10, cs:flt_7FF91E7451E8
00007FF91DFD382B  F3 0F 5E CA                 divss   xmm1, xmm2
00007FF91DFD382F  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD3833  F3 0F 11 8B E0 64 00 00     movss   dword ptr [rbx+64E0h], xmm1
00007FF91DFD383B  F3 0F 11 83 70 67 00 00     movss   dword ptr [rbx+6770h], xmm0
00007FF91DFD3843  F3 0F 10 B3 30 65 00 00     movss   xmm6, dword ptr [rbx+6530h]
00007FF91DFD384B  F3 0F 10 8B 10 65 00 00     movss   xmm1, dword ptr [rbx+6510h]
00007FF91DFD3853  F3 0F 11 B3 50 64 00 00     movss   dword ptr [rbx+6450h], xmm6
00007FF91DFD385B  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFD385F  F3 0F 11 8B 60 64 00 00     movss   dword ptr [rbx+6460h], xmm1
00007FF91DFD3867  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD386B  76 1B                       jbe     short loc_7FF91DFD3888
00007FF91DFD386D  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD3872  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD3876  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD3879  E8 5A BC 37 00              call    fmodf
00007FF91DFD387E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD3881  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD3886  EB 1F                       jmp     short loc_7FF91DFD38A7
00007FF91DFD3888  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD388C  73 19                       jnb     short loc_7FF91DFD38A7
00007FF91DFD388E  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD3893  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD3897  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD389A  E8 39 BC 37 00              call    fmodf
00007FF91DFD389F  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD38A2  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD38A7  F3 44 0F 10 25 5C 17 77 00  movss   xmm12, cs:dword_7FF91E74500C
00007FF91DFD38B0  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD38B3  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD38B8  F3 0F 11 B3 40 64 00 00     movss   dword ptr [rbx+6440h], xmm6
00007FF91DFD38C0  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD38C3  F3 0F 59 BB 30 68 00 00     mulss   xmm7, dword ptr [rbx+6830h]
00007FF91DFD38CB  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFD38D0  E8 EB 56 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD38D5  F3 44 0F 10 1D 66 1B 77 00  movss   xmm11, cs:dword_7FF91E745444
00007FF91DFD38DE  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFD38E1  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFD38E6  F3 0F 59 AB E0 64 00 00     mulss   xmm5, dword ptr [rbx+64E0h]
00007FF91DFD38EE  F3 0F 59 AB 00 68 00 00     mulss   xmm5, dword ptr [rbx+6800h]
00007FF91DFD38F6  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD38FA  73 06                       jnb     short loc_7FF91DFD3902
00007FF91DFD38FC  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD3900  EB 05                       jmp     short loc_7FF91DFD3907
00007FF91DFD3902  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD3907  F3 0F 59 AB D0 67 00 00     mulss   xmm5, dword ptr [rbx+67D0h]
00007FF91DFD390F  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD3912  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD3916  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD3919  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD391C  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD3924  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD3927  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD392B  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD392E  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
00007FF91DFD3936  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD393E  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD3942  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
00007FF91DFD394A  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD394E  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD3951  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD3959  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD395D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD3961  F3 0F 10 8B F0 64 00 00     movss   xmm1, dword ptr [rbx+64F0h]
00007FF91DFD3969  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD396D  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD3970  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFD3974  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD3978  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD397C  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD3980  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD3984  F3 0F 11 A3 40 65 00 00     movss   dword ptr [rbx+6540h], xmm4
00007FF91DFD398C  72 07                       jb      short loc_7FF91DFD3995
00007FF91DFD398E  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD3993  EB 05                       jmp     short loc_7FF91DFD399A
00007FF91DFD3995  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFD399A  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD399D  73 06                       jnb     short loc_7FF91DFD39A5
00007FF91DFD399F  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFD39A3  EB 06                       jmp     short loc_7FF91DFD39AB
00007FF91DFD39A5  76 04                       jbe     short loc_7FF91DFD39AB
00007FF91DFD39A7  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD39AB  F3 44 0F 10 83 40 64 00 00  movss   xmm8, dword ptr [rbx+6440h]
00007FF91DFD39B4  F3 0F 59 B3 40 68 00 00     mulss   xmm6, dword ptr [rbx+6840h]
00007FF91DFD39BC  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFD39C0  E8 FB 55 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD39C5  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD39C8  F3 0F 10 83 F0 67 00 00     movss   xmm0, dword ptr [rbx+67F0h]
00007FF91DFD39D0  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFD39D4  72 18                       jb      short loc_7FF91DFD39EE
00007FF91DFD39D6  0F 2F 83 50 64 00 00        comiss  xmm0, dword ptr [rbx+6450h]
00007FF91DFD39DD  76 0F                       jbe     short loc_7FF91DFD39EE
00007FF91DFD39DF  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00007FF91DFD39E7  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFD39EC  EB 08                       jmp     short loc_7FF91DFD39F6
00007FF91DFD39EE  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00007FF91DFD39F6  0F 2F 3D D3 18 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFD39FD  F3 0F 59 A3 E0 64 00 00     mulss   xmm4, dword ptr [rbx+64E0h]
00007FF91DFD3A05  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFD3A0A  F3 0F 59 A3 10 68 00 00     mulss   xmm4, dword ptr [rbx+6810h]
00007FF91DFD3A12  72 03                       jb      short loc_7FF91DFD3A17
00007FF91DFD3A14  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD3A17  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD3A1B  73 06                       jnb     short loc_7FF91DFD3A23
00007FF91DFD3A1D  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD3A21  EB 05                       jmp     short loc_7FF91DFD3A28
00007FF91DFD3A23  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD3A28  F3 0F 11 BB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm7
00007FF91DFD3A30  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD3A35  F3 0F 59 A3 D0 67 00 00     mulss   xmm4, dword ptr [rbx+67D0h]
00007FF91DFD3A3D  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD3A40  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD3A45  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD3A49  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD3A4C  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFD3A51  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD3A55  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD3A58  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD3A5C  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFD3A60  F3 44 0F 59 8B A0 69 00 00  mulss   xmm9, dword ptr [rbx+69A0h]
00007FF91DFD3A69  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD3A6E  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD3A71  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD3A79  F3 44 0F 58 8B 90 69 00 00  addss   xmm9, dword ptr [rbx+6990h]
00007FF91DFD3A82  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD3A8A  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD3A8F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD3A92  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD3A9A  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFD3A9F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD3AA3  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD3AA8  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD3AAB  0F 54 05 DE 1C 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFD3AB2  0F 57 05 07 1D 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD3AB9  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFD3ABE  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFD3AC3  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFD3AC8  F3 44 0F 11 8B 50 65 00 00  movss   dword ptr [rbx+6550h], xmm9
00007FF91DFD3AD1  E8 EA 54 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD3AD6  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD3ADA  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD3ADE  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD3AE3  73 06                       jnb     short loc_7FF91DFD3AEB
00007FF91DFD3AE5  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD3AE9  EB 06                       jmp     short loc_7FF91DFD3AF1
00007FF91DFD3AEB  76 04                       jbe     short loc_7FF91DFD3AF1
00007FF91DFD3AED  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD3AF1  F3 44 0F 59 83 E0 64 00 00  mulss   xmm8, dword ptr [rbx+64E0h]
00007FF91DFD3AFA  F3 0F 59 BB 50 68 00 00     mulss   xmm7, dword ptr [rbx+6850h]
00007FF91DFD3B02  F3 44 0F 59 05 8D 71 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFD3B0B  F3 44 0F 59 83 20 68 00 00  mulss   xmm8, dword ptr [rbx+6820h]
00007FF91DFD3B14  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFD3B18  73 06                       jnb     short loc_7FF91DFD3B20
00007FF91DFD3B1A  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFD3B1E  EB 05                       jmp     short loc_7FF91DFD3B25
00007FF91DFD3B20  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFD3B25  F3 44 0F 59 83 D0 67 00 00  mulss   xmm8, dword ptr [rbx+67D0h]
00007FF91DFD3B2E  F3 44 0F 59 8B B0 64 00 00  mulss   xmm9, dword ptr [rbx+64B0h]
00007FF91DFD3B37  F3 0F 10 B3 40 64 00 00     movss   xmm6, dword ptr [rbx+6440h]
00007FF91DFD3B3F  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD3B43  F3 0F 10 AB 60 64 00 00     movss   xmm5, dword ptr [rbx+6460h]
00007FF91DFD3B4B  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFD3B50  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD3B53  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD3B56  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD3B5A  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD3B5D  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
00007FF91DFD3B65  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD3B68  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD3B70  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
00007FF91DFD3B78  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD3B7D  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD3B85  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD3B89  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD3B8C  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD3B94  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD3B98  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD3B9C  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD3BA0  F3 0F 10 83 40 65 00 00     movss   xmm0, dword ptr [rbx+6540h]
00007FF91DFD3BA8  F3 0F 59 83 A0 64 00 00     mulss   xmm0, dword ptr [rbx+64A0h]
00007FF91DFD3BB0  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD3BB4  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFD3BB9  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFD3BBE  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD3BC2  F3 0F 59 A3 C0 64 00 00     mulss   xmm4, dword ptr [rbx+64C0h]
00007FF91DFD3BCA  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD3BCE  F3 0F 11 A3 70 65 00 00     movss   dword ptr [rbx+6570h], xmm4
00007FF91DFD3BD6  F3 0F 11 B3 50 64 00 00     movss   dword ptr [rbx+6450h], xmm6
00007FF91DFD3BDE  F3 0F 11 AB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm5
00007FF91DFD3BE6  F3 0F 58 B3 D0 64 00 00     addss   xmm6, dword ptr [rbx+64D0h]
00007FF91DFD3BEE  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD3BF2  76 1B                       jbe     short loc_7FF91DFD3C0F
00007FF91DFD3BF4  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD3BF9  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD3BFD  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD3C00  E8 D3 B8 37 00              call    fmodf
00007FF91DFD3C05  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD3C08  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD3C0D  EB 1F                       jmp     short loc_7FF91DFD3C2E
00007FF91DFD3C0F  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD3C13  73 19                       jnb     short loc_7FF91DFD3C2E
00007FF91DFD3C15  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD3C1A  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD3C1E  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD3C21  E8 B2 B8 37 00              call    fmodf
00007FF91DFD3C26  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD3C29  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD3C2E  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD3C31  F3 0F 11 B3 40 64 00 00     movss   dword ptr [rbx+6440h], xmm6
00007FF91DFD3C39  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD3C3E  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD3C41  F3 0F 59 BB 30 68 00 00     mulss   xmm7, dword ptr [rbx+6830h]
00007FF91DFD3C49  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFD3C4E  E8 6D 53 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD3C53  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFD3C56  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFD3C5B  F3 0F 59 AB E0 64 00 00     mulss   xmm5, dword ptr [rbx+64E0h]
00007FF91DFD3C63  F3 0F 59 AB 00 68 00 00     mulss   xmm5, dword ptr [rbx+6800h]
00007FF91DFD3C6B  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD3C6F  73 06                       jnb     short loc_7FF91DFD3C77
00007FF91DFD3C71  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD3C75  EB 05                       jmp     short loc_7FF91DFD3C7C
00007FF91DFD3C77  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD3C7C  F3 0F 59 AB D0 67 00 00     mulss   xmm5, dword ptr [rbx+67D0h]
00007FF91DFD3C84  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD3C87  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD3C8B  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD3C8E  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD3C91  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD3C99  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD3C9C  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD3CA0  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD3CA3  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
00007FF91DFD3CAB  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD3CB3  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD3CB7  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
00007FF91DFD3CBF  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD3CC3  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD3CC6  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD3CCE  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD3CD2  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD3CD6  F3 0F 10 8B F0 64 00 00     movss   xmm1, dword ptr [rbx+64F0h]
00007FF91DFD3CDE  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD3CE2  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD3CE5  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFD3CE9  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD3CED  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD3CF1  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD3CF5  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD3CF9  F3 0F 11 A3 40 65 00 00     movss   dword ptr [rbx+6540h], xmm4
00007FF91DFD3D01  72 07                       jb      short loc_7FF91DFD3D0A
00007FF91DFD3D03  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD3D08  EB 05                       jmp     short loc_7FF91DFD3D0F
00007FF91DFD3D0A  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFD3D0F  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD3D12  73 06                       jnb     short loc_7FF91DFD3D1A
00007FF91DFD3D14  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFD3D18  EB 06                       jmp     short loc_7FF91DFD3D20
00007FF91DFD3D1A  76 04                       jbe     short loc_7FF91DFD3D20
00007FF91DFD3D1C  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD3D20  F3 44 0F 10 83 40 64 00 00  movss   xmm8, dword ptr [rbx+6440h]
00007FF91DFD3D29  F3 0F 59 B3 40 68 00 00     mulss   xmm6, dword ptr [rbx+6840h]
00007FF91DFD3D31  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFD3D35  E8 86 52 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD3D3A  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD3D3D  F3 0F 10 83 F0 67 00 00     movss   xmm0, dword ptr [rbx+67F0h]
00007FF91DFD3D45  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFD3D49  72 18                       jb      short loc_7FF91DFD3D63
00007FF91DFD3D4B  0F 2F 83 50 64 00 00        comiss  xmm0, dword ptr [rbx+6450h]
00007FF91DFD3D52  76 0F                       jbe     short loc_7FF91DFD3D63
00007FF91DFD3D54  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00007FF91DFD3D5C  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFD3D61  EB 08                       jmp     short loc_7FF91DFD3D6B
00007FF91DFD3D63  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00007FF91DFD3D6B  0F 2F 3D 5E 15 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFD3D72  F3 0F 59 A3 E0 64 00 00     mulss   xmm4, dword ptr [rbx+64E0h]
00007FF91DFD3D7A  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFD3D7F  F3 0F 59 A3 10 68 00 00     mulss   xmm4, dword ptr [rbx+6810h]
00007FF91DFD3D87  72 03                       jb      short loc_7FF91DFD3D8C
00007FF91DFD3D89  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD3D8C  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD3D90  73 06                       jnb     short loc_7FF91DFD3D98
00007FF91DFD3D92  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD3D96  EB 05                       jmp     short loc_7FF91DFD3D9D
00007FF91DFD3D98  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD3D9D  F3 0F 11 BB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm7
00007FF91DFD3DA5  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD3DAA  F3 0F 59 A3 D0 67 00 00     mulss   xmm4, dword ptr [rbx+67D0h]
00007FF91DFD3DB2  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD3DB5  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD3DBA  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD3DBE  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD3DC1  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFD3DC6  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD3DCA  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD3DCD  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD3DD1  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFD3DD5  F3 44 0F 59 8B A0 69 00 00  mulss   xmm9, dword ptr [rbx+69A0h]
00007FF91DFD3DDE  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD3DE3  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD3DE6  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD3DEE  F3 44 0F 58 8B 90 69 00 00  addss   xmm9, dword ptr [rbx+6990h]
00007FF91DFD3DF7  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD3DFF  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD3E04  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD3E07  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD3E0F  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFD3E14  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD3E18  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD3E1D  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD3E20  0F 54 05 69 19 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFD3E27  0F 57 05 92 19 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD3E2E  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFD3E33  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFD3E38  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFD3E3D  F3 44 0F 11 8B 50 65 00 00  movss   dword ptr [rbx+6550h], xmm9
00007FF91DFD3E46  E8 75 51 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD3E4B  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD3E4F  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD3E53  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD3E58  73 06                       jnb     short loc_7FF91DFD3E60
00007FF91DFD3E5A  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD3E5E  EB 06                       jmp     short loc_7FF91DFD3E66
00007FF91DFD3E60  76 04                       jbe     short loc_7FF91DFD3E66
00007FF91DFD3E62  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD3E66  F3 44 0F 59 83 E0 64 00 00  mulss   xmm8, dword ptr [rbx+64E0h]
00007FF91DFD3E6F  F3 0F 59 BB 50 68 00 00     mulss   xmm7, dword ptr [rbx+6850h]
00007FF91DFD3E77  F3 44 0F 59 05 18 6E 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFD3E80  F3 44 0F 59 83 20 68 00 00  mulss   xmm8, dword ptr [rbx+6820h]
00007FF91DFD3E89  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFD3E8D  73 06                       jnb     short loc_7FF91DFD3E95
00007FF91DFD3E8F  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFD3E93  EB 05                       jmp     short loc_7FF91DFD3E9A
00007FF91DFD3E95  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFD3E9A  F3 44 0F 59 83 D0 67 00 00  mulss   xmm8, dword ptr [rbx+67D0h]
00007FF91DFD3EA3  F3 44 0F 59 8B B0 64 00 00  mulss   xmm9, dword ptr [rbx+64B0h]
00007FF91DFD3EAC  F3 0F 10 B3 40 64 00 00     movss   xmm6, dword ptr [rbx+6440h]
00007FF91DFD3EB4  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD3EB8  F3 0F 10 AB 60 64 00 00     movss   xmm5, dword ptr [rbx+6460h]
00007FF91DFD3EC0  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFD3EC5  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD3EC8  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD3ECB  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD3ECF  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD3ED2  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
00007FF91DFD3EDA  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD3EDD  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD3EE5  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
00007FF91DFD3EED  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD3EF2  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD3EFA  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD3EFE  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD3F01  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD3F09  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD3F0D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD3F11  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD3F15  F3 0F 10 83 40 65 00 00     movss   xmm0, dword ptr [rbx+6540h]
00007FF91DFD3F1D  F3 0F 59 83 A0 64 00 00     mulss   xmm0, dword ptr [rbx+64A0h]
00007FF91DFD3F25  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD3F29  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFD3F2E  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFD3F33  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD3F37  F3 0F 59 A3 C0 64 00 00     mulss   xmm4, dword ptr [rbx+64C0h]
00007FF91DFD3F3F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD3F43  F3 0F 11 A3 F0 65 00 00     movss   dword ptr [rbx+65F0h], xmm4
00007FF91DFD3F4B  F3 0F 11 B3 50 64 00 00     movss   dword ptr [rbx+6450h], xmm6
00007FF91DFD3F53  F3 0F 11 AB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm5
00007FF91DFD3F5B  F3 0F 58 B3 D0 64 00 00     addss   xmm6, dword ptr [rbx+64D0h]
00007FF91DFD3F63  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD3F67  76 1B                       jbe     short loc_7FF91DFD3F84
00007FF91DFD3F69  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD3F6E  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD3F72  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD3F75  E8 5E B5 37 00              call    fmodf
00007FF91DFD3F7A  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD3F7D  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD3F82  EB 1F                       jmp     short loc_7FF91DFD3FA3
00007FF91DFD3F84  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD3F88  73 19                       jnb     short loc_7FF91DFD3FA3
00007FF91DFD3F8A  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD3F8F  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD3F93  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD3F96  E8 3D B5 37 00              call    fmodf
00007FF91DFD3F9B  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD3F9E  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD3FA3  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD3FA6  F3 0F 11 B3 40 64 00 00     movss   dword ptr [rbx+6440h], xmm6
00007FF91DFD3FAE  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD3FB3  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD3FB6  F3 0F 59 BB 30 68 00 00     mulss   xmm7, dword ptr [rbx+6830h]
00007FF91DFD3FBE  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFD3FC3  E8 F8 4F FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD3FC8  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFD3FCB  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFD3FD0  F3 0F 59 AB E0 64 00 00     mulss   xmm5, dword ptr [rbx+64E0h]
00007FF91DFD3FD8  F3 0F 59 AB 00 68 00 00     mulss   xmm5, dword ptr [rbx+6800h]
00007FF91DFD3FE0  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD3FE4  73 06                       jnb     short loc_7FF91DFD3FEC
00007FF91DFD3FE6  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD3FEA  EB 05                       jmp     short loc_7FF91DFD3FF1
00007FF91DFD3FEC  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD3FF1  F3 0F 59 AB D0 67 00 00     mulss   xmm5, dword ptr [rbx+67D0h]
00007FF91DFD3FF9  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD3FFC  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD4000  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD4003  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD4006  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD400E  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD4011  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD4015  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD4018  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
00007FF91DFD4020  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD4028  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD402C  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
00007FF91DFD4034  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD4038  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD403B  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD4043  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD4047  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD404B  F3 0F 10 8B F0 64 00 00     movss   xmm1, dword ptr [rbx+64F0h]
00007FF91DFD4053  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD4057  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD405A  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFD405E  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD4062  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD4066  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD406A  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD406E  F3 0F 11 A3 40 65 00 00     movss   dword ptr [rbx+6540h], xmm4
00007FF91DFD4076  72 07                       jb      short loc_7FF91DFD407F
00007FF91DFD4078  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD407D  EB 05                       jmp     short loc_7FF91DFD4084
00007FF91DFD407F  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFD4084  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD4087  73 06                       jnb     short loc_7FF91DFD408F
00007FF91DFD4089  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFD408D  EB 06                       jmp     short loc_7FF91DFD4095
00007FF91DFD408F  76 04                       jbe     short loc_7FF91DFD4095
00007FF91DFD4091  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD4095  F3 44 0F 10 83 40 64 00 00  movss   xmm8, dword ptr [rbx+6440h]
00007FF91DFD409E  F3 0F 59 B3 40 68 00 00     mulss   xmm6, dword ptr [rbx+6840h]
00007FF91DFD40A6  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFD40AA  E8 11 4F FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD40AF  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD40B2  F3 0F 10 83 F0 67 00 00     movss   xmm0, dword ptr [rbx+67F0h]
00007FF91DFD40BA  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFD40BE  72 18                       jb      short loc_7FF91DFD40D8
00007FF91DFD40C0  0F 2F 83 50 64 00 00        comiss  xmm0, dword ptr [rbx+6450h]
00007FF91DFD40C7  76 0F                       jbe     short loc_7FF91DFD40D8
00007FF91DFD40C9  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00007FF91DFD40D1  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFD40D6  EB 08                       jmp     short loc_7FF91DFD40E0
00007FF91DFD40D8  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00007FF91DFD40E0  0F 2F 3D E9 11 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFD40E7  F3 0F 59 A3 E0 64 00 00     mulss   xmm4, dword ptr [rbx+64E0h]
00007FF91DFD40EF  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFD40F4  F3 0F 59 A3 10 68 00 00     mulss   xmm4, dword ptr [rbx+6810h]
00007FF91DFD40FC  72 03                       jb      short loc_7FF91DFD4101
00007FF91DFD40FE  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD4101  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD4105  73 06                       jnb     short loc_7FF91DFD410D
00007FF91DFD4107  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD410B  EB 05                       jmp     short loc_7FF91DFD4112
00007FF91DFD410D  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD4112  F3 0F 11 BB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm7
00007FF91DFD411A  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD411F  F3 0F 59 A3 D0 67 00 00     mulss   xmm4, dword ptr [rbx+67D0h]
00007FF91DFD4127  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD412A  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD412F  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD4133  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD4136  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFD413B  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD413F  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD4142  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD4146  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFD414A  F3 44 0F 59 8B A0 69 00 00  mulss   xmm9, dword ptr [rbx+69A0h]
00007FF91DFD4153  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD4158  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD415B  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD4163  F3 44 0F 58 8B 90 69 00 00  addss   xmm9, dword ptr [rbx+6990h]
00007FF91DFD416C  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD4174  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD4179  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD417C  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD4184  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFD4189  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD418D  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD4192  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD4195  0F 54 05 F4 15 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFD419C  0F 57 05 1D 16 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD41A3  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFD41A8  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFD41AD  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFD41B2  F3 44 0F 11 8B 50 65 00 00  movss   dword ptr [rbx+6550h], xmm9
00007FF91DFD41BB  E8 00 4E FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD41C0  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD41C4  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD41C8  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD41CD  73 06                       jnb     short loc_7FF91DFD41D5
00007FF91DFD41CF  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD41D3  EB 06                       jmp     short loc_7FF91DFD41DB
00007FF91DFD41D5  76 04                       jbe     short loc_7FF91DFD41DB
00007FF91DFD41D7  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD41DB  F3 44 0F 59 83 E0 64 00 00  mulss   xmm8, dword ptr [rbx+64E0h]
00007FF91DFD41E4  F3 0F 59 BB 50 68 00 00     mulss   xmm7, dword ptr [rbx+6850h]
00007FF91DFD41EC  F3 44 0F 59 05 A3 6A 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFD41F5  F3 44 0F 59 83 20 68 00 00  mulss   xmm8, dword ptr [rbx+6820h]
00007FF91DFD41FE  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFD4202  73 06                       jnb     short loc_7FF91DFD420A
00007FF91DFD4204  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFD4208  EB 05                       jmp     short loc_7FF91DFD420F
00007FF91DFD420A  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFD420F  F3 44 0F 59 83 D0 67 00 00  mulss   xmm8, dword ptr [rbx+67D0h]
00007FF91DFD4218  F3 44 0F 59 8B B0 64 00 00  mulss   xmm9, dword ptr [rbx+64B0h]
00007FF91DFD4221  F3 0F 10 B3 40 64 00 00     movss   xmm6, dword ptr [rbx+6440h]
00007FF91DFD4229  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD422D  F3 0F 10 AB 60 64 00 00     movss   xmm5, dword ptr [rbx+6460h]
00007FF91DFD4235  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFD423A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD423D  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD4240  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD4244  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD4247  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
00007FF91DFD424F  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD4252  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD425A  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
00007FF91DFD4262  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD4267  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD426F  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD4273  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD4276  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD427E  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD4282  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD4286  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD428A  F3 0F 10 83 40 65 00 00     movss   xmm0, dword ptr [rbx+6540h]
00007FF91DFD4292  F3 0F 59 83 A0 64 00 00     mulss   xmm0, dword ptr [rbx+64A0h]
00007FF91DFD429A  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD429E  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFD42A3  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFD42A8  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD42AC  F3 0F 59 A3 C0 64 00 00     mulss   xmm4, dword ptr [rbx+64C0h]
00007FF91DFD42B4  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD42B8  F3 0F 11 A3 70 66 00 00     movss   dword ptr [rbx+6670h], xmm4
00007FF91DFD42C0  F3 0F 11 B3 50 64 00 00     movss   dword ptr [rbx+6450h], xmm6
00007FF91DFD42C8  F3 0F 11 AB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm5
00007FF91DFD42D0  F3 0F 58 B3 D0 64 00 00     addss   xmm6, dword ptr [rbx+64D0h]
00007FF91DFD42D8  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD42DC  76 1B                       jbe     short loc_7FF91DFD42F9
00007FF91DFD42DE  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD42E3  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD42E7  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD42EA  E8 E9 B1 37 00              call    fmodf
00007FF91DFD42EF  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD42F2  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD42F7  EB 1F                       jmp     short loc_7FF91DFD4318
00007FF91DFD42F9  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD42FD  73 19                       jnb     short loc_7FF91DFD4318
00007FF91DFD42FF  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD4304  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD4308  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD430B  E8 C8 B1 37 00              call    fmodf
00007FF91DFD4310  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD4313  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD4318  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD431B  F3 0F 11 B3 40 64 00 00     movss   dword ptr [rbx+6440h], xmm6
00007FF91DFD4323  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD4328  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD432B  F3 0F 59 BB 30 68 00 00     mulss   xmm7, dword ptr [rbx+6830h]
00007FF91DFD4333  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFD4338  E8 83 4C FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD433D  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFD4340  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFD4345  F3 0F 59 AB E0 64 00 00     mulss   xmm5, dword ptr [rbx+64E0h]
00007FF91DFD434D  F3 0F 59 AB 00 68 00 00     mulss   xmm5, dword ptr [rbx+6800h]
00007FF91DFD4355  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD4359  73 06                       jnb     short loc_7FF91DFD4361
00007FF91DFD435B  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD435F  EB 05                       jmp     short loc_7FF91DFD4366
00007FF91DFD4361  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD4366  F3 0F 59 AB D0 67 00 00     mulss   xmm5, dword ptr [rbx+67D0h]
00007FF91DFD436E  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD4371  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD4375  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD4378  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD437B  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD4383  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD4386  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD438A  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD438D  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
00007FF91DFD4395  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD439D  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD43A1  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
00007FF91DFD43A9  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD43AD  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD43B0  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD43B8  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD43BC  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD43C0  F3 0F 10 8B F0 64 00 00     movss   xmm1, dword ptr [rbx+64F0h]
00007FF91DFD43C8  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD43CC  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD43CF  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFD43D3  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD43D7  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD43DB  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD43DF  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD43E3  F3 0F 11 A3 40 65 00 00     movss   dword ptr [rbx+6540h], xmm4
00007FF91DFD43EB  72 07                       jb      short loc_7FF91DFD43F4
00007FF91DFD43ED  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD43F2  EB 05                       jmp     short loc_7FF91DFD43F9
00007FF91DFD43F4  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFD43F9  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD43FC  73 06                       jnb     short loc_7FF91DFD4404
00007FF91DFD43FE  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFD4402  EB 06                       jmp     short loc_7FF91DFD440A
00007FF91DFD4404  76 04                       jbe     short loc_7FF91DFD440A
00007FF91DFD4406  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD440A  F3 44 0F 10 83 40 64 00 00  movss   xmm8, dword ptr [rbx+6440h]
00007FF91DFD4413  F3 0F 59 B3 40 68 00 00     mulss   xmm6, dword ptr [rbx+6840h]
00007FF91DFD441B  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFD441F  E8 9C 4B FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD4424  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD4427  F3 0F 10 83 F0 67 00 00     movss   xmm0, dword ptr [rbx+67F0h]
00007FF91DFD442F  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFD4433  72 18                       jb      short loc_7FF91DFD444D
00007FF91DFD4435  0F 2F 83 50 64 00 00        comiss  xmm0, dword ptr [rbx+6450h]
00007FF91DFD443C  76 0F                       jbe     short loc_7FF91DFD444D
00007FF91DFD443E  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00007FF91DFD4446  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFD444B  EB 08                       jmp     short loc_7FF91DFD4455
00007FF91DFD444D  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00007FF91DFD4455  0F 2F 3D 74 0E 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFD445C  F3 0F 59 A3 E0 64 00 00     mulss   xmm4, dword ptr [rbx+64E0h]
00007FF91DFD4464  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFD4469  F3 0F 59 A3 10 68 00 00     mulss   xmm4, dword ptr [rbx+6810h]
00007FF91DFD4471  72 03                       jb      short loc_7FF91DFD4476
00007FF91DFD4473  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD4476  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD447A  73 06                       jnb     short loc_7FF91DFD4482
00007FF91DFD447C  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD4480  EB 05                       jmp     short loc_7FF91DFD4487
00007FF91DFD4482  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD4487  F3 0F 11 BB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm7
00007FF91DFD448F  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD4494  F3 0F 59 A3 D0 67 00 00     mulss   xmm4, dword ptr [rbx+67D0h]
00007FF91DFD449C  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD449F  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD44A4  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD44A8  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD44AB  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFD44B0  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD44B4  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD44B7  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD44BB  44 0F 28 C2                 movaps  xmm8, xmm2
00007FF91DFD44BF  F3 44 0F 59 83 A0 69 00 00  mulss   xmm8, dword ptr [rbx+69A0h]
00007FF91DFD44C8  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD44CD  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD44D0  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD44D8  F3 44 0F 58 83 90 69 00 00  addss   xmm8, dword ptr [rbx+6990h]
00007FF91DFD44E1  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD44E9  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFD44EE  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD44F1  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD44F9  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFD44FE  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD4502  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFD4507  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD450A  0F 54 05 7F 12 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFD4511  0F 57 05 A8 12 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD4518  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFD451D  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFD4522  F3 44 0F 59 C6              mulss   xmm8, xmm6
00007FF91DFD4527  F3 44 0F 11 83 50 65 00 00  movss   dword ptr [rbx+6550h], xmm8
00007FF91DFD4530  E8 8B 4A FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD4535  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD4539  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD453E  73 06                       jnb     short loc_7FF91DFD4546
00007FF91DFD4540  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD4544  EB 06                       jmp     short loc_7FF91DFD454C
00007FF91DFD4546  76 04                       jbe     short loc_7FF91DFD454C
00007FF91DFD4548  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD454C  F3 0F 59 83 E0 64 00 00     mulss   xmm0, dword ptr [rbx+64E0h]
00007FF91DFD4554  F3 0F 59 BB 50 68 00 00     mulss   xmm7, dword ptr [rbx+6850h]
00007FF91DFD455C  F3 0F 59 05 34 67 61 00     mulss   xmm0, cs:dword_7FF91E5EAC98
00007FF91DFD4564  F3 0F 59 83 20 68 00 00     mulss   xmm0, dword ptr [rbx+6820h]
00007FF91DFD456C  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFD4570  72 09                       jb      short loc_7FF91DFD457B
00007FF91DFD4572  44 0F 28 F8                 movaps  xmm15, xmm0
00007FF91DFD4576  F3 45 0F 5D FD              minss   xmm15, xmm13
00007FF91DFD457B  F3 44 0F 59 BB D0 67 00 00  mulss   xmm15, dword ptr [rbx+67D0h]
00007FF91DFD4584  F3 44 0F 59 83 B0 64 00 00  mulss   xmm8, dword ptr [rbx+64B0h]
00007FF91DFD458D  F3 0F 10 AB 40 64 00 00     movss   xmm5, dword ptr [rbx+6440h]
00007FF91DFD4595  41 0F 28 D7                 movaps  xmm2, xmm15
00007FF91DFD4599  F3 0F 10 B3 60 64 00 00     movss   xmm6, dword ptr [rbx+6460h]
00007FF91DFD45A1  F3 41 0F 59 D7              mulss   xmm2, xmm15
00007FF91DFD45A6  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD45A9  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD45AC  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00007FF91DFD45B4  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD45B7  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD45BB  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD45BE  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00007FF91DFD45C6  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
00007FF91DFD45CE  F3 41 0F 59 DF              mulss   xmm3, xmm15
00007FF91DFD45D3  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
00007FF91DFD45DB  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD45DF  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD45E2  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00007FF91DFD45EA  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD45EE  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD45F2  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD45F6  F3 0F 10 83 40 65 00 00     movss   xmm0, dword ptr [rbx+6540h]
00007FF91DFD45FE  F3 0F 59 83 A0 64 00 00     mulss   xmm0, dword ptr [rbx+64A0h]
00007FF91DFD4606  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD460A  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFD460F  F3 41 0F 58 E7              addss   xmm4, xmm15
00007FF91DFD4614  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD4618  F3 0F 59 A3 C0 64 00 00     mulss   xmm4, dword ptr [rbx+64C0h]
00007FF91DFD4620  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD4624  F3 0F 11 A3 F0 66 00 00     movss   dword ptr [rbx+66F0h], xmm4
00007FF91DFD462C  F3 0F 10 93 60 67 00 00     movss   xmm2, dword ptr [rbx+6760h]
00007FF91DFD4634  F3 0F 11 AB 20 65 00 00     movss   dword ptr [rbx+6520h], xmm5
00007FF91DFD463C  F3 0F 11 B3 00 65 00 00     movss   dword ptr [rbx+6500h], xmm6
00007FF91DFD4644  F3 0F 10 83 70 66 00 00     movss   xmm0, dword ptr [rbx+6670h]
00007FF91DFD464C  F3 0F 58 83 60 66 00 00     addss   xmm0, dword ptr [rbx+6660h]
00007FF91DFD4654  F3 0F 10 8B F0 66 00 00     movss   xmm1, dword ptr [rbx+66F0h]
00007FF91DFD465C  F3 0F 58 8B E0 65 00 00     addss   xmm1, dword ptr [rbx+65E0h]
00007FF91DFD4664  F3 0F 10 AB E0 66 00 00     movss   xmm5, dword ptr [rbx+66E0h]
00007FF91DFD466C  F3 0F 58 AB F0 65 00 00     addss   xmm5, dword ptr [rbx+65F0h]
00007FF91DFD4674  F3 0F 59 83 80 68 00 00     mulss   xmm0, dword ptr [rbx+6880h]
00007FF91DFD467C  F3 0F 59 8B 90 68 00 00     mulss   xmm1, dword ptr [rbx+6890h]
00007FF91DFD4684  F3 0F 59 AB 70 68 00 00     mulss   xmm5, dword ptr [rbx+6870h]
00007FF91DFD468C  F3 0F 58 93 70 65 00 00     addss   xmm2, dword ptr [rbx+6570h]
00007FF91DFD4694  F3 0F 59 93 60 68 00 00     mulss   xmm2, dword ptr [rbx+6860h]
00007FF91DFD469C  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFD46A0  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD46A4  F3 0F 10 83 50 67 00 00     movss   xmm0, dword ptr [rbx+6750h]
00007FF91DFD46AC  F3 0F 58 83 80 65 00 00     addss   xmm0, dword ptr [rbx+6580h]
00007FF91DFD46B4  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD46B8  F3 0F 10 8B D0 66 00 00     movss   xmm1, dword ptr [rbx+66D0h]
00007FF91DFD46C0  F3 0F 59 83 A0 68 00 00     mulss   xmm0, dword ptr [rbx+68A0h]
00007FF91DFD46C8  F3 0F 58 8B 00 66 00 00     addss   xmm1, dword ptr [rbx+6600h]
00007FF91DFD46D0  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD46D4  F3 0F 10 83 80 66 00 00     movss   xmm0, dword ptr [rbx+6680h]
00007FF91DFD46DC  F3 0F 58 83 50 66 00 00     addss   xmm0, dword ptr [rbx+6650h]
00007FF91DFD46E4  F3 0F 59 8B B0 68 00 00     mulss   xmm1, dword ptr [rbx+68B0h]
00007FF91DFD46EC  F3 0F 59 83 C0 68 00 00     mulss   xmm0, dword ptr [rbx+68C0h]
00007FF91DFD46F4  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD46F8  F3 0F 10 8B 00 67 00 00     movss   xmm1, dword ptr [rbx+6700h]
00007FF91DFD4700  F3 0F 58 8B D0 65 00 00     addss   xmm1, dword ptr [rbx+65D0h]
00007FF91DFD4708  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD470C  F3 0F 10 83 40 67 00 00     movss   xmm0, dword ptr [rbx+6740h]
00007FF91DFD4714  F3 0F 59 8B D0 68 00 00     mulss   xmm1, dword ptr [rbx+68D0h]
00007FF91DFD471C  F3 0F 58 83 90 65 00 00     addss   xmm0, dword ptr [rbx+6590h]
00007FF91DFD4724  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD4728  F3 0F 10 8B 10 66 00 00     movss   xmm1, dword ptr [rbx+6610h]
00007FF91DFD4730  F3 0F 58 8B C0 66 00 00     addss   xmm1, dword ptr [rbx+66C0h]
00007FF91DFD4738  F3 0F 59 83 E0 68 00 00     mulss   xmm0, dword ptr [rbx+68E0h]
00007FF91DFD4740  F3 0F 59 8B F0 68 00 00     mulss   xmm1, dword ptr [rbx+68F0h]
00007FF91DFD4748  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD474C  F3 0F 10 83 90 66 00 00     movss   xmm0, dword ptr [rbx+6690h]
00007FF91DFD4754  F3 0F 58 83 40 66 00 00     addss   xmm0, dword ptr [rbx+6640h]
00007FF91DFD475C  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD4760  F3 0F 10 8B C0 65 00 00     movss   xmm1, dword ptr [rbx+65C0h]
00007FF91DFD4768  F3 0F 59 83 00 69 00 00     mulss   xmm0, dword ptr [rbx+6900h]
00007FF91DFD4770  F3 0F 58 8B 10 67 00 00     addss   xmm1, dword ptr [rbx+6710h]
00007FF91DFD4778  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD477C  F3 0F 10 83 30 67 00 00     movss   xmm0, dword ptr [rbx+6730h]
00007FF91DFD4784  F3 0F 59 8B 10 69 00 00     mulss   xmm1, dword ptr [rbx+6910h]
00007FF91DFD478C  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD4790  F3 0F 58 83 A0 65 00 00     addss   xmm0, dword ptr [rbx+65A0h]
00007FF91DFD4798  F3 0F 10 93 90 67 00 00     movss   xmm2, dword ptr [rbx+6790h]
00007FF91DFD47A0  F3 0F 10 8B B0 66 00 00     movss   xmm1, dword ptr [rbx+66B0h]
00007FF91DFD47A8  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD47AB  F3 0F 59 A3 90 6A 00 00     mulss   xmm4, dword ptr [rbx+6A90h]
00007FF91DFD47B3  F3 0F 59 83 20 69 00 00     mulss   xmm0, dword ptr [rbx+6920h]
00007FF91DFD47BB  F3 0F 58 A3 A0 67 00 00     addss   xmm4, dword ptr [rbx+67A0h]
00007FF91DFD47C3  F3 0F 58 8B 20 66 00 00     addss   xmm1, dword ptr [rbx+6620h]
00007FF91DFD47CB  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD47CF  F3 0F 10 83 A0 66 00 00     movss   xmm0, dword ptr [rbx+66A0h]
00007FF91DFD47D7  F3 0F 58 83 30 66 00 00     addss   xmm0, dword ptr [rbx+6630h]
00007FF91DFD47DF  F3 0F 59 8B 30 69 00 00     mulss   xmm1, dword ptr [rbx+6930h]
00007FF91DFD47E7  F3 0F 59 83 40 69 00 00     mulss   xmm0, dword ptr [rbx+6940h]
00007FF91DFD47EF  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD47F3  F3 0F 10 8B 20 67 00 00     movss   xmm1, dword ptr [rbx+6720h]
00007FF91DFD47FB  F3 0F 58 8B B0 65 00 00     addss   xmm1, dword ptr [rbx+65B0h]
00007FF91DFD4803  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD4807  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD480A  F3 0F 59 8B 50 69 00 00     mulss   xmm1, dword ptr [rbx+6950h]
00007FF91DFD4812  F3 0F 11 A3 90 67 00 00     movss   dword ptr [rbx+6790h], xmm4
00007FF91DFD481A  F3 0F 59 83 A0 6A 00 00     mulss   xmm0, dword ptr [rbx+6AA0h]
00007FF91DFD4822  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD4826  F3 0F 58 C4                 addss   xmm0, xmm4
00007FF91DFD482A  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFD482D  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD4831  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD4834  F3 0F 59 83 90 6A 00 00     mulss   xmm0, dword ptr [rbx+6A90h]
00007FF91DFD483C  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFD4840  F3 0F 11 83 80 67 00 00     movss   dword ptr [rbx+6780h], xmm0
00007FF91DFD4848  F3 0F 10 93 E0 6A 00 00     movss   xmm2, dword ptr [rbx+6AE0h]
00007FF91DFD4850  F3 0F 59 9B 70 67 00 00     mulss   xmm3, dword ptr [rbx+6770h]
00007FF91DFD4858  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFD485C  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFD4860  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD4864  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFD4868  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD486C  F3 0F 11 A3 60 65 00 00     movss   dword ptr [rbx+6560h], xmm4
00007FF91DFD4874  F3 0F 11 A3 E0 5F 00 00     movss   dword ptr [rbx+5FE0h], xmm4
00007FF91DFD487C  44 0F 2E AB C0 8C 01 00     ucomiss xmm13, dword ptr [rbx+18CC0h]
00007FF91DFD4884  75 1B                       jnz     short loc_7FF91DFD48A1
00007FF91DFD4886  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
00007FF91DFD488F  F3 0F 11 83 60 53 00 00     movss   dword ptr [rbx+5360h], xmm0
00007FF91DFD4897  C7 83 C0 8C 01 00 00 00 00 00  mov     dword ptr [rbx+18CC0h], 0
00007FF91DFD48A1  8B 83 D0 7B 00 00           mov     eax, [rbx+7BD0h]
00007FF91DFD48A7  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
00007FF91DFD48AF  48 8B 0F                    mov     rcx, [rdi]
00007FF91DFD48B2  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
00007FF91DFD48B7  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
00007FF91DFD48BC  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
00007FF91DFD48C1  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
00007FF91DFD48C6  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
00007FF91DFD48CB  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
00007FF91DFD48D0  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
00007FF91DFD48D5  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
00007FF91DFD48DA  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
00007FF91DFD48E0  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
00007FF91DFD48E6  89 01                       mov     [rcx], eax
00007FF91DFD48E8  8B 83 D0 7B 00 00           mov     eax, [rbx+7BD0h]
00007FF91DFD48EE  48 8B 4F 08                 mov     rcx, [rdi+8]
00007FF91DFD48F2  49 8B 5B 18                 mov     rbx, [r11+18h]
00007FF91DFD48F6  89 01                       mov     [rcx], eax
00007FF91DFD48F8  49 8B E3                    mov     rsp, r11
00007FF91DFD48FB  5F                          pop     rdi
00007FF91DFD48FC  C3                          retn
