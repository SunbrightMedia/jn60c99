; sub_180370B90 @ 0x180370B90 (RVA 0x370B90) size=0x3D6D

0000000180370B90  48 8B C4                    mov     rax, rsp
0000000180370B93  48 89 58 10                 mov     [rax+10h], rbx
0000000180370B97  57                          push    rdi
0000000180370B98  48 81 EC C0 00 00 00        sub     rsp, 0C0h
0000000180370B9F  F3 0F 10 A1 60 53 00 00     movss   xmm4, dword ptr [rcx+5360h]
0000000180370BA7  48 8B FA                    mov     rdi, rdx
0000000180370BAA  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
0000000180370BAE  48 8B D9                    mov     rbx, rcx
0000000180370BB1  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
0000000180370BB5  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
0000000180370BBA  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
0000000180370BBF  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
0000000180370BC4  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
0000000180370BC9  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
0000000180370BCE  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
0000000180370BD4  F3 44 0F 10 2D D7 44 77 00  movss   xmm13, cs:dword_180AE50B4
0000000180370BDD  44 0F 2E A9 C0 8C 01 00     ucomiss xmm13, dword ptr [rcx+18CC0h]
0000000180370BE5  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
0000000180370BEB  45 0F 57 F6                 xorps   xmm14, xmm14
0000000180370BEF  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
0000000180370BF9  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
0000000180370BFF  75 16                       jnz     short loc_180370C17
0000000180370C01  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
0000000180370C0A  0F 57 E4                    xorps   xmm4, xmm4
0000000180370C0D  C7 81 60 53 00 00 00 00 00 00  mov     dword ptr [rcx+5360h], 0
0000000180370C17  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
0000000180370C1F  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
0000000180370C27  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
0000000180370C2F  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
0000000180370C37  F3 0F 59 05 85 A1 61 00     mulss   xmm0, cs:dword_18098ADC4
0000000180370C3F  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
0000000180370C47  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
0000000180370C4F  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180370C53  85 D2                       test    edx, edx
0000000180370C55  75 07                       jnz     short loc_180370C5E
0000000180370C57  BA 01 00 00 00              mov     edx, 1
0000000180370C5C  EB 24                       jmp     short loc_180370C82
0000000180370C5E  8B C2                       mov     eax, edx
0000000180370C60  25 00 00 20 00              and     eax, 200000h
0000000180370C65  0F BA E2 17                 bt      edx, 17h
0000000180370C69  73 08                       jnb     short loc_180370C73
0000000180370C6B  85 C0                       test    eax, eax
0000000180370C6D  75 0C                       jnz     short loc_180370C7B
0000000180370C6F  03 D2                       add     edx, edx
0000000180370C71  EB 0F                       jmp     short loc_180370C82
0000000180370C73  85 C0                       test    eax, eax
0000000180370C75  74 04                       jz      short loc_180370C7B
0000000180370C77  03 D2                       add     edx, edx
0000000180370C79  EB 07                       jmp     short loc_180370C82
0000000180370C7B  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
0000000180370C82  F3 0F 10 9B F0 52 00 00     movss   xmm3, dword ptr [rbx+52F0h]
0000000180370C8A  8B C2                       mov     eax, edx
0000000180370C8C  F3 0F 10 B3 D0 52 00 00     movss   xmm6, dword ptr [rbx+52D0h]
0000000180370C94  25 FF FF FF 00              and     eax, 0FFFFFFh
0000000180370C99  F3 44 0F 10 83 90 53 00 00  movss   xmm8, dword ptr [rbx+5390h]
0000000180370CA2  8B CA                       mov     ecx, edx
0000000180370CA4  F3 0F 10 BB A0 53 00 00     movss   xmm7, dword ptr [rbx+53A0h]
0000000180370CAC  81 CA 00 00 00 FF           or      edx, 0FF000000h
0000000180370CB2  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180370CB6  81 E1 00 00 00 01           and     ecx, 1000000h
0000000180370CBC  C7 83 D0 53 00 00 00 00 00 00  mov     dword ptr [rbx+53D0h], 0
0000000180370CC6  F3 0F 11 9B 00 53 00 00     movss   dword ptr [rbx+5300h], xmm3
0000000180370CCE  45 0F 57 D2                 xorps   xmm10, xmm10
0000000180370CD2  0F 44 D0                    cmovz   edx, eax
0000000180370CD5  F3 0F 11 B3 E0 52 00 00     movss   dword ptr [rbx+52E0h], xmm6
0000000180370CDD  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
0000000180370CE3  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
0000000180370CE9  8B 83 10 54 00 00           mov     eax, [rbx+5410h]
0000000180370CEF  66 0F 6E C2                 movd    xmm0, edx
0000000180370CF3  0F 5B C0                    cvtdq2ps xmm0, xmm0
0000000180370CF6  89 83 20 54 00 00           mov     [rbx+5420h], eax
0000000180370CFC  F3 0F 11 A3 80 53 00 00     movss   dword ptr [rbx+5380h], xmm4
0000000180370D04  F3 0F 59 05 64 9F 61 00     mulss   xmm0, cs:dword_18098AC70
0000000180370D0C  F3 44 0F 11 83 B0 53 00 00  movss   dword ptr [rbx+53B0h], xmm8
0000000180370D15  F3 0F 11 BB C0 53 00 00     movss   dword ptr [rbx+53C0h], xmm7
0000000180370D1D  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
0000000180370D25  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
0000000180370D2D  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
0000000180370D35  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180370D39  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
0000000180370D41  F3 0F 5C CA                 subss   xmm1, xmm2
0000000180370D45  F3 0F 10 93 30 53 00 00     movss   xmm2, dword ptr [rbx+5330h]
0000000180370D4D  F3 0F 11 93 40 53 00 00     movss   dword ptr [rbx+5340h], xmm2
0000000180370D55  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180370D59  F3 0F 10 83 10 53 00 00     movss   xmm0, dword ptr [rbx+5310h]
0000000180370D61  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180370D65  F3 0F 11 83 20 53 00 00     movss   dword ptr [rbx+5320h], xmm0
0000000180370D6D  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180370D71  0F 28 C2                    movaps  xmm0, xmm2
0000000180370D74  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
0000000180370D7C  F3 0F 10 8B 50 53 00 00     movss   xmm1, dword ptr [rbx+5350h]
0000000180370D84  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180370D88  F3 0F 59 F2                 mulss   xmm6, xmm2
0000000180370D8C  F3 0F 11 8B 70 53 00 00     movss   dword ptr [rbx+5370h], xmm1
0000000180370D94  F3 0F 11 93 E0 53 00 00     movss   dword ptr [rbx+53E0h], xmm2
0000000180370D9C  F3 0F 5C F0                 subss   xmm6, xmm0
0000000180370DA0  0F 28 C4                    movaps  xmm0, xmm4
0000000180370DA3  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180370DA7  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180370DAB  F3 0F 58 F1                 addss   xmm6, xmm1
0000000180370DAF  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180370DB3  F3 0F 11 B3 F0 53 00 00     movss   dword ptr [rbx+53F0h], xmm6
0000000180370DBB  F3 0F 11 9B 00 54 00 00     movss   dword ptr [rbx+5400h], xmm3
0000000180370DC3  0F 28 CB                    movaps  xmm1, xmm3
0000000180370DC6  F3 0F 58 9B 40 54 00 00     addss   xmm3, dword ptr [rbx+5440h]
0000000180370DCE  41 0F 2F DE                 comiss  xmm3, xmm14
0000000180370DD2  72 05                       jb      short loc_180370DD9
0000000180370DD4  0F 57 C0                    xorps   xmm0, xmm0
0000000180370DD7  EB 03                       jmp     short loc_180370DDC
0000000180370DD9  0F 5A C3                    cvtps2pd xmm0, xmm3
0000000180370DDC  41 0F 2E CE                 ucomiss xmm1, xmm14
0000000180370DE0  F3 44 0F 10 3D FB 46 77 00  movss   xmm15, cs:dword_180AE54E4
0000000180370DE9  75 06                       jnz     short loc_180370DF1
0000000180370DEB  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180370DEF  EB 04                       jmp     short loc_180370DF5
0000000180370DF1  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
0000000180370DF5  41 0F 2F EE                 comiss  xmm5, xmm14
0000000180370DF9  F3 0F 11 AB 10 54 00 00     movss   dword ptr [rbx+5410h], xmm5
0000000180370E01  73 06                       jnb     short loc_180370E09
0000000180370E03  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180370E07  EB 06                       jmp     short loc_180370E0F
0000000180370E09  76 04                       jbe     short loc_180370E0F
0000000180370E0B  41 0F 28 ED                 movaps  xmm5, xmm13
0000000180370E0F  F3 0F 10 83 80 54 00 00     movss   xmm0, dword ptr [rbx+5480h]
0000000180370E17  F3 41 0F 58 ED              addss   xmm5, xmm13
0000000180370E1C  F3 0F 10 93 20 55 00 00     movss   xmm2, dword ptr [rbx+5520h]
0000000180370E24  F3 0F 10 8B 90 54 00 00     movss   xmm1, dword ptr [rbx+5490h]
0000000180370E2C  8B 83 50 54 00 00           mov     eax, [rbx+5450h]
0000000180370E32  0F 28 D9                    movaps  xmm3, xmm1
0000000180370E35  F3 0F 10 A3 E0 54 00 00     movss   xmm4, dword ptr [rbx+54E0h]
0000000180370E3D  F3 0F 58 9B 30 55 00 00     addss   xmm3, dword ptr [rbx+5530h]
0000000180370E45  F2 44 0F 10 25 52 43 77 00  movsd   xmm12, cs:dbl_180AE51A0
0000000180370E4E  F3 0F 11 AB 30 54 00 00     movss   dword ptr [rbx+5430h], xmm5
0000000180370E56  F3 0F 11 AB 50 54 00 00     movss   dword ptr [rbx+5450h], xmm5
0000000180370E5E  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180370E62  89 83 60 54 00 00           mov     [rbx+5460h], eax
0000000180370E68  F3 0F 11 A3 F0 54 00 00     movss   dword ptr [rbx+54F0h], xmm4
0000000180370E70  F3 0F 5C E8                 subss   xmm5, xmm0
0000000180370E74  0F 28 C2                    movaps  xmm0, xmm2
0000000180370E77  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180370E7B  F3 0F 10 8B C0 54 00 00     movss   xmm1, dword ptr [rbx+54C0h]
0000000180370E83  F3 0F 58 83 40 55 00 00     addss   xmm0, dword ptr [rbx+5540h]
0000000180370E8B  F3 41 0F 58 ED              addss   xmm5, xmm13
0000000180370E90  F3 0F 5E C8                 divss   xmm1, xmm0
0000000180370E94  F3 0F 10 83 50 55 00 00     movss   xmm0, dword ptr [rbx+5550h]
0000000180370E9C  F3 0F 59 AB 70 54 00 00     mulss   xmm5, dword ptr [rbx+5470h]
0000000180370EA4  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180370EA8  F3 0F 10 93 B0 54 00 00     movss   xmm2, dword ptr [rbx+54B0h]
0000000180370EB0  F3 0F 11 AB 00 55 00 00     movss   dword ptr [rbx+5500h], xmm5
0000000180370EB8  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180370EBC  F3 0F 10 8B D0 54 00 00     movss   xmm1, dword ptr [rbx+54D0h]
0000000180370EC4  F3 0F 58 D6                 addss   xmm2, xmm6
0000000180370EC8  F3 0F 5C D4                 subss   xmm2, xmm4
0000000180370ECC  F3 0F 11 93 B0 54 00 00     movss   dword ptr [rbx+54B0h], xmm2
0000000180370ED4  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180370ED8  F3 0F 11 93 C0 54 00 00     movss   dword ptr [rbx+54C0h], xmm2
0000000180370EE0  F3 0F 58 D4                 addss   xmm2, xmm4
0000000180370EE4  F3 0F 5C E6                 subss   xmm4, xmm6
0000000180370EE8  0F 54 25 A1 48 77 00        andps   xmm4, cs:xmmword_180AE5790
0000000180370EEF  F3 0F 5C C4                 subss   xmm0, xmm4
0000000180370EF3  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180370EF7  0F 83 E8 00 00 00           jnb     loc_180370FE5
0000000180370EFD  0F 57 C9                    xorps   xmm1, xmm1
0000000180370F00  0F 5A C1                    cvtps2pd xmm0, xmm1
0000000180370F03  41 0F 2E EE                 ucomiss xmm5, xmm14
0000000180370F07  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180370F0B  0F 28 C8                    movaps  xmm1, xmm0
0000000180370F0E  F3 0F 11 83 D0 54 00 00     movss   dword ptr [rbx+54D0h], xmm0
0000000180370F16  F3 0F 59 CE                 mulss   xmm1, xmm6
0000000180370F1A  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180370F1E  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180370F22  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180370F26  75 03                       jnz     short loc_180370F2B
0000000180370F28  0F 28 CE                    movaps  xmm1, xmm6
0000000180370F2B  8B 83 90 55 00 00           mov     eax, [rbx+5590h]
0000000180370F31  48 8D 0D C8 F0 C8 FF        lea     rcx, cs:180000000h
0000000180370F38  F3 0F 59 BB 80 55 00 00     mulss   xmm7, dword ptr [rbx+5580h]
0000000180370F40  89 83 A0 55 00 00           mov     [rbx+55A0h], eax
0000000180370F46  F3 44 0F 59 83 70 55 00 00  mulss   xmm8, dword ptr [rbx+5570h]
0000000180370F4F  F3 0F 10 83 B0 56 00 00     movss   xmm0, dword ptr [rbx+56B0h]
0000000180370F57  F3 0F 10 93 B0 55 00 00     movss   xmm2, dword ptr [rbx+55B0h]
0000000180370F5F  F3 44 0F 10 8B 10 56 00 00  movss   xmm9, dword ptr [rbx+5610h]
0000000180370F68  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180370F6D  F3 44 0F 10 83 F0 55 00 00  movss   xmm8, dword ptr [rbx+55F0h]
0000000180370F76  F3 0F 2C C0                 cvttss2si eax, xmm0
0000000180370F7A  F3 0F 11 BB 90 55 00 00     movss   dword ptr [rbx+5590h], xmm7
0000000180370F82  F3 0F 10 BB D0 55 00 00     movss   xmm7, dword ptr [rbx+55D0h]
0000000180370F8A  F3 0F 11 8B E0 54 00 00     movss   dword ptr [rbx+54E0h], xmm1
0000000180370F92  F3 0F 11 8B 10 55 00 00     movss   dword ptr [rbx+5510h], xmm1
0000000180370F9A  F3 0F 10 8B 70 56 00 00     movss   xmm1, dword ptr [rbx+5670h]
0000000180370FA2  F3 0F 11 BB E0 55 00 00     movss   dword ptr [rbx+55E0h], xmm7
0000000180370FAA  F3 0F 11 93 C0 55 00 00     movss   dword ptr [rbx+55C0h], xmm2
0000000180370FB2  F3 44 0F 11 83 00 56 00 00  movss   dword ptr [rbx+5600h], xmm8
0000000180370FBB  F3 44 0F 11 8B 20 56 00 00  movss   dword ptr [rbx+5620h], xmm9
0000000180370FC4  F3 0F 11 8B 80 56 00 00     movss   dword ptr [rbx+5680h], xmm1
0000000180370FCC  83 F8 E0                    cmp     eax, 0FFFFFFE0h
0000000180370FCF  7D 2F                       jge     short loc_180371000
0000000180370FD1  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
0000000180370FD6  F7 D0                       not     eax
0000000180370FD8  48 98                       cdqe
0000000180370FDA  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
0000000180370FE3  EB 47                       jmp     short loc_18037102C
0000000180370FE5  F3 0F 58 8B 60 55 00 00     addss   xmm1, dword ptr [rbx+5560h]
0000000180370FED  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180370FF1  0F 82 09 FF FF FF           jb      loc_180370F00
0000000180370FF7  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180370FFB  E9 03 FF FF FF              jmp     loc_180370F03
0000000180371000  83 F8 20                    cmp     eax, 20h ; ' '
0000000180371003  7E 07                       jle     short loc_18037100C
0000000180371005  B8 20 00 00 00              mov     eax, 20h ; ' '
000000018037100A  EB 15                       jmp     short loc_180371021
000000018037100C  85 C0                       test    eax, eax
000000018037100E  79 0F                       jns     short loc_18037101F
0000000180371010  F7 D0                       not     eax
0000000180371012  48 98                       cdqe
0000000180371014  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018037101D  EB 0D                       jmp     short loc_18037102C
000000018037101F  7E 0B                       jle     short loc_18037102C
0000000180371021  48 98                       cdqe
0000000180371023  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
000000018037102C  0F 57 05 8D 47 77 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180371033  F3 0F 2C C0                 cvttss2si eax, xmm0
0000000180371037  83 F8 E0                    cmp     eax, 0FFFFFFE0h
000000018037103A  7D 14                       jge     short loc_180371050
000000018037103C  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
0000000180371041  F7 D0                       not     eax
0000000180371043  48 98                       cdqe
0000000180371045  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018037104E  EB 2C                       jmp     short loc_18037107C
0000000180371050  83 F8 20                    cmp     eax, 20h ; ' '
0000000180371053  7E 07                       jle     short loc_18037105C
0000000180371055  B8 20 00 00 00              mov     eax, 20h ; ' '
000000018037105A  EB 15                       jmp     short loc_180371071
000000018037105C  85 C0                       test    eax, eax
000000018037105E  79 0F                       jns     short loc_18037106F
0000000180371060  F7 D0                       not     eax
0000000180371062  48 98                       cdqe
0000000180371064  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018037106D  EB 0D                       jmp     short loc_18037107C
000000018037106F  7E 0B                       jle     short loc_18037107C
0000000180371071  48 98                       cdqe
0000000180371073  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
000000018037107C  F3 0F 10 83 30 56 00 00     movss   xmm0, dword ptr [rbx+5630h]
0000000180371084  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180371088  F3 0F 59 93 A0 56 00 00     mulss   xmm2, dword ptr [rbx+56A0h]
0000000180371090  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180371094  F3 0F 10 8B 60 56 00 00     movss   xmm1, dword ptr [rbx+5660h]
000000018037109C  F3 0F 11 93 70 56 00 00     movss   dword ptr [rbx+5670h], xmm2
00000001803710A4  F3 0F 59 D0                 mulss   xmm2, xmm0
00000001803710A8  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803710AC  F3 0F 5C D0                 subss   xmm2, xmm0
00000001803710B0  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803710B4  41 0F 2F D6                 comiss  xmm2, xmm14
00000001803710B8  76 05                       jbe     short loc_1803710BF
00000001803710BA  0F 5A C2                    cvtps2pd xmm0, xmm2
00000001803710BD  EB 03                       jmp     short loc_1803710C2
00000001803710BF  0F 57 C0                    xorps   xmm0, xmm0
00000001803710C2  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00000001803710C6  41 0F 2F CD                 comiss  xmm1, xmm13
00000001803710CA  72 06                       jb      short loc_1803710D2
00000001803710CC  41 0F 28 C4                 movaps  xmm0, xmm12
00000001803710D0  EB 03                       jmp     short loc_1803710D5
00000001803710D2  0F 5A C1                    cvtps2pd xmm0, xmm1
00000001803710D5  F3 0F 10 B3 40 56 00 00     movss   xmm6, dword ptr [rbx+5640h]
00000001803710DD  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00000001803710E1  F3 0F 59 83 D0 56 00 00     mulss   xmm0, dword ptr [rbx+56D0h]; X
00000001803710E9  E8 52 E6 37 00              call    expf
00000001803710EE  F3 0F 59 83 C0 56 00 00     mulss   xmm0, dword ptr [rbx+56C0h]
00000001803710F6  0F 28 CE                    movaps  xmm1, xmm6
00000001803710F9  8B 83 40 58 00 00           mov     eax, [rbx+5840h]
00000001803710FF  F3 0F 59 8B 50 56 00 00     mulss   xmm1, dword ptr [rbx+5650h]
0000000180371107  89 83 50 58 00 00           mov     [rbx+5850h], eax
000000018037110D  F3 0F 58 83 E0 56 00 00     addss   xmm0, dword ptr [rbx+56E0h]
0000000180371115  8B 83 60 58 00 00           mov     eax, [rbx+5860h]
000000018037111B  F3 0F 10 9B 00 58 00 00     movss   xmm3, dword ptr [rbx+5800h]
0000000180371123  F3 0F 59 BB 90 59 00 00     mulss   xmm7, dword ptr [rbx+5990h]
000000018037112B  89 83 70 58 00 00           mov     [rbx+5870h], eax
0000000180371131  8B 83 80 58 00 00           mov     eax, [rbx+5880h]
0000000180371137  F3 0F 10 93 F0 57 00 00     movss   xmm2, dword ptr [rbx+57F0h]
000000018037113F  F3 0F 10 A3 20 58 00 00     movss   xmm4, dword ptr [rbx+5820h]
0000000180371147  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018037114B  89 83 90 58 00 00           mov     [rbx+5890h], eax
0000000180371151  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
0000000180371157  F3 0F 11 9B 10 58 00 00     movss   dword ptr [rbx+5810h], xmm3
000000018037115F  F3 0F 5C CE                 subss   xmm1, xmm6
0000000180371163  F3 0F 11 93 00 58 00 00     movss   dword ptr [rbx+5800h], xmm2
000000018037116B  F3 0F 11 A3 30 58 00 00     movss   dword ptr [rbx+5830h], xmm4
0000000180371173  F3 44 0F 11 83 C0 57 00 00  movss   dword ptr [rbx+57C0h], xmm8
000000018037117C  F3 44 0F 11 8B D0 57 00 00  movss   dword ptr [rbx+57D0h], xmm9
0000000180371185  89 83 B0 57 00 00           mov     [rbx+57B0h], eax
000000018037118B  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037118F  F3 0F 10 83 60 59 00 00     movss   xmm0, dword ptr [rbx+5960h]
0000000180371197  F3 0F 58 F8                 addss   xmm7, xmm0
000000018037119B  F3 0F 11 83 50 59 00 00     movss   dword ptr [rbx+5950h], xmm0
00000001803711A3  F3 0F 11 8B 90 56 00 00     movss   dword ptr [rbx+5690h], xmm1
00000001803711AB  41 0F 2F FF                 comiss  xmm7, xmm15
00000001803711AF  73 06                       jnb     short loc_1803711B7
00000001803711B1  41 0F 28 FF                 movaps  xmm7, xmm15
00000001803711B5  EB 05                       jmp     short loc_1803711BC
00000001803711B7  F3 41 0F 5D FD              minss   xmm7, xmm13
00000001803711BC  F3 0F 59 0D FC 9B 61 00     mulss   xmm1, cs:dword_18098ADC0
00000001803711C4  41 0F 28 C5                 movaps  xmm0, xmm13
00000001803711C8  F3 0F 10 B3 70 5A 00 00     movss   xmm6, dword ptr [rbx+5A70h]
00000001803711D0  F3 0F 5C C3                 subss   xmm0, xmm3
00000001803711D4  F3 0F 11 BB F0 57 00 00     movss   dword ptr [rbx+57F0h], xmm7
00000001803711DC  F3 0F 5D F1                 minss   xmm6, xmm1
00000001803711E0  F3 0F 59 83 A0 59 00 00     mulss   xmm0, dword ptr [rbx+59A0h]
00000001803711E8  F3 0F 58 C3                 addss   xmm0, xmm3
00000001803711EC  41 0F 2F C7                 comiss  xmm0, xmm15
00000001803711F0  73 06                       jnb     short loc_1803711F8
00000001803711F2  41 0F 28 C7                 movaps  xmm0, xmm15
00000001803711F6  EB 05                       jmp     short loc_1803711FD
00000001803711F8  F3 41 0F 5D C5              minss   xmm0, xmm13
00000001803711FD  F3 0F 59 B3 80 5A 00 00     mulss   xmm6, dword ptr [rbx+5A80h]
0000000180371205  F3 0F 5C D7                 subss   xmm2, xmm7
0000000180371209  F3 0F 11 B3 A0 58 00 00     movss   dword ptr [rbx+58A0h], xmm6
0000000180371211  F3 0F 58 F4                 addss   xmm6, xmm4
0000000180371215  41 0F 2F D6                 comiss  xmm2, xmm14
0000000180371219  73 03                       jnb     short loc_18037121E
000000018037121B  0F 57 C0                    xorps   xmm0, xmm0
000000018037121E  F3 0F 10 8B 70 59 00 00     movss   xmm1, dword ptr [rbx+5970h]
0000000180371226  F3 44 0F 10 9B B0 57 00 00  movss   xmm11, dword ptr [rbx+57B0h]
000000018037122F  F3 0F 11 83 00 58 00 00     movss   dword ptr [rbx+5800h], xmm0
0000000180371237  F3 0F 58 83 00 5B 00 00     addss   xmm0, dword ptr [rbx+5B00h]
000000018037123F  72 04                       jb      short loc_180371245
0000000180371241  41 0F 28 CD                 movaps  xmm1, xmm13
0000000180371245  F3 0F 59 83 F0 5A 00 00     mulss   xmm0, dword ptr [rbx+5AF0h]
000000018037124D  41 0F 28 FB                 movaps  xmm7, xmm11
0000000180371251  F3 0F 10 93 50 58 00 00     movss   xmm2, dword ptr [rbx+5850h]
0000000180371259  F3 0F 59 F1                 mulss   xmm6, xmm1
000000018037125D  F3 0F 5C FA                 subss   xmm7, xmm2
0000000180371261  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180371265  F3 0F 59 B3 80 59 00 00     mulss   xmm6, dword ptr [rbx+5980h]
000000018037126D  76 05                       jbe     short loc_180371274
000000018037126F  0F 5A C8                    cvtps2pd xmm1, xmm0
0000000180371272  EB 03                       jmp     short loc_180371277
0000000180371274  0F 57 C9                    xorps   xmm1, xmm1
0000000180371277  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037127B  F3 0F 59 BB C0 5B 00 00     mulss   xmm7, dword ptr [rbx+5BC0h]
0000000180371283  F3 44 0F 10 0D 5C 3F 77 00  movss   xmm9, cs:flt_180AE51E8
000000018037128C  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
0000000180371290  F3 0F 58 FA                 addss   xmm7, xmm2
0000000180371294  F3 0F 11 BB 40 58 00 00     movss   dword ptr [rbx+5840h], xmm7
000000018037129C  F3 0F 11 83 E0 57 00 00     movss   dword ptr [rbx+57E0h], xmm0
00000001803712A4  41 0F 28 C3                 movaps  xmm0, xmm11
00000001803712A8  F3 0F 59 BB B0 5B 00 00     mulss   xmm7, dword ptr [rbx+5BB0h]
00000001803712B0  F3 0F 10 8B 30 5A 00 00     movss   xmm1, dword ptr [rbx+5A30h]
00000001803712B8  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803712BC  F3 0F 59 F9                 mulss   xmm7, xmm1
00000001803712C0  F3 0F 5C F8                 subss   xmm7, xmm0
00000001803712C4  F3 0F 10 83 30 58 00 00     movss   xmm0, dword ptr [rbx+5830h]
00000001803712CC  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
00000001803712D5  F3 41 0F 58 FB              addss   xmm7, xmm11
00000001803712DA  76 1B                       jbe     short loc_1803712F7
00000001803712DC  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803712E1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803712E5  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803712E8  E8 EB E1 37 00              call    fmodf
00000001803712ED  0F 28 F0                    movaps  xmm6, xmm0
00000001803712F0  F3 41 0F 5C F5              subss   xmm6, xmm13
00000001803712F5  EB 1F                       jmp     short loc_180371316
00000001803712F7  41 0F 2F F7                 comiss  xmm6, xmm15
00000001803712FB  73 19                       jnb     short loc_180371316
00000001803712FD  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180371302  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180371306  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180371309  E8 CA E1 37 00              call    fmodf
000000018037130E  0F 28 F0                    movaps  xmm6, xmm0
0000000180371311  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180371316  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
000000018037131F  0F 28 C6                    movaps  xmm0, xmm6
0000000180371322  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180371326  F3 44 0F 10 83 70 58 00 00  movss   xmm8, dword ptr [rbx+5870h]
000000018037132F  F3 0F 11 B3 20 58 00 00     movss   dword ptr [rbx+5820h], xmm6
0000000180371337  F3 0F 59 BB A0 5B 00 00     mulss   xmm7, dword ptr [rbx+5BA0h]
000000018037133F  F3 0F 58 83 10 5B 00 00     addss   xmm0, dword ptr [rbx+5B10h]
0000000180371347  F3 0F 11 BB A0 57 00 00     movss   dword ptr [rbx+57A0h], xmm7
000000018037134F  73 0A                       jnb     short loc_18037135B
0000000180371351  41 0F 2F F6                 comiss  xmm6, xmm14
0000000180371355  76 04                       jbe     short loc_18037135B
0000000180371357  45 0F 28 C3                 movaps  xmm8, xmm11
000000018037135B  41 0F 2F C5                 comiss  xmm0, xmm13
000000018037135F  76 15                       jbe     short loc_180371376
0000000180371361  F3 41 0F 58 C5              addss   xmm0, xmm13; X
0000000180371366  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018037136A  E8 69 E1 37 00              call    fmodf
000000018037136F  F3 41 0F 5C C5              subss   xmm0, xmm13
0000000180371374  EB 19                       jmp     short loc_18037138F
0000000180371376  41 0F 2F C7                 comiss  xmm0, xmm15
000000018037137A  73 13                       jnb     short loc_18037138F
000000018037137C  F3 41 0F 5C C5              subss   xmm0, xmm13; X
0000000180371381  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180371385  E8 4E E1 37 00              call    fmodf
000000018037138A  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037138F  F3 44 0F 10 1D 28 44 77 00  movss   xmm11, dword ptr cs:xmmword_180AE57C0
0000000180371398  F3 44 0F 11 83 60 58 00 00  movss   dword ptr [rbx+5860h], xmm8
00000001803713A1  F3 0F 59 83 50 5B 00 00     mulss   xmm0, dword ptr [rbx+5B50h]
00000001803713A9  F3 44 0F 59 83 90 5B 00 00  mulss   xmm8, dword ptr [rbx+5B90h]
00000001803713B2  F3 0F 58 83 D0 5B 00 00     addss   xmm0, dword ptr [rbx+5BD0h]
00000001803713BA  F3 0F 11 83 B0 58 00 00     movss   dword ptr [rbx+58B0h], xmm0
00000001803713C2  41 0F 57 C3                 xorps   xmm0, xmm11
00000001803713C6  F3 44 0F 11 83 00 59 00 00  movss   dword ptr [rbx+5900h], xmm8
00000001803713CF  44 0F 28 C6                 movaps  xmm8, xmm6
00000001803713D3  F3 44 0F 58 83 30 5B 00 00  addss   xmm8, dword ptr [rbx+5B30h]
00000001803713DC  F3 0F 11 83 C0 58 00 00     movss   dword ptr [rbx+58C0h], xmm0
00000001803713E4  45 0F 2F C5                 comiss  xmm8, xmm13
00000001803713E8  76 1D                       jbe     short loc_180371407
00000001803713EA  F3 45 0F 58 C5              addss   xmm8, xmm13
00000001803713EF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803713F3  41 0F 28 C0                 movaps  xmm0, xmm8; X
00000001803713F7  E8 DC E0 37 00              call    fmodf
00000001803713FC  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180371400  F3 45 0F 5C C5              subss   xmm8, xmm13
0000000180371405  EB 21                       jmp     short loc_180371428
0000000180371407  45 0F 2F C7                 comiss  xmm8, xmm15
000000018037140B  73 1B                       jnb     short loc_180371428
000000018037140D  F3 45 0F 5C C5              subss   xmm8, xmm13
0000000180371412  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180371416  41 0F 28 C0                 movaps  xmm0, xmm8; X
000000018037141A  E8 B9 E0 37 00              call    fmodf
000000018037141F  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180371423  F3 45 0F 58 C5              addss   xmm8, xmm13
0000000180371428  0F 28 FE                    movaps  xmm7, xmm6
000000018037142B  F3 0F 58 BB 20 5B 00 00     addss   xmm7, dword ptr [rbx+5B20h]
0000000180371433  41 0F 2F FD                 comiss  xmm7, xmm13
0000000180371437  76 1B                       jbe     short loc_180371454
0000000180371439  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037143E  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180371442  0F 28 C7                    movaps  xmm0, xmm7; X
0000000180371445  E8 8E E0 37 00              call    fmodf
000000018037144A  0F 28 F8                    movaps  xmm7, xmm0
000000018037144D  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180371452  EB 1F                       jmp     short loc_180371473
0000000180371454  41 0F 2F FF                 comiss  xmm7, xmm15
0000000180371458  73 19                       jnb     short loc_180371473
000000018037145A  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037145F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180371463  0F 28 C7                    movaps  xmm0, xmm7; X
0000000180371466  E8 6D E0 37 00              call    fmodf
000000018037146B  0F 28 F8                    movaps  xmm7, xmm0
000000018037146E  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180371473  41 0F 28 C0                 movaps  xmm0, xmm8
0000000180371477  E8 44 7B FF FF              call    sub_180368FC0
000000018037147C  F3 0F 58 BB E0 5B 00 00     addss   xmm7, dword ptr [rbx+5BE0h]
0000000180371484  F3 0F 59 83 70 5B 00 00     mulss   xmm0, dword ptr [rbx+5B70h]
000000018037148C  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180371490  73 06                       jnb     short loc_180371498
0000000180371492  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180371496  EB 06                       jmp     short loc_18037149E
0000000180371498  76 04                       jbe     short loc_18037149E
000000018037149A  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037149E  F3 0F 58 B3 40 5B 00 00     addss   xmm6, dword ptr [rbx+5B40h]
00000001803714A6  F3 0F 11 83 E0 58 00 00     movss   dword ptr [rbx+58E0h], xmm0
00000001803714AE  F3 0F 11 BB 40 59 00 00     movss   dword ptr [rbx+5940h], xmm7
00000001803714B6  F3 0F 59 BB 60 5B 00 00     mulss   xmm7, dword ptr [rbx+5B60h]
00000001803714BE  41 0F 2F F5                 comiss  xmm6, xmm13
00000001803714C2  F3 0F 58 BB F0 5B 00 00     addss   xmm7, dword ptr [rbx+5BF0h]
00000001803714CA  76 1B                       jbe     short loc_1803714E7
00000001803714CC  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803714D1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803714D5  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803714D8  E8 FB DF 37 00              call    fmodf
00000001803714DD  0F 28 F0                    movaps  xmm6, xmm0
00000001803714E0  F3 41 0F 5C F5              subss   xmm6, xmm13
00000001803714E5  EB 1F                       jmp     short loc_180371506
00000001803714E7  41 0F 2F F7                 comiss  xmm6, xmm15
00000001803714EB  73 19                       jnb     short loc_180371506
00000001803714ED  F3 41 0F 5C F5              subss   xmm6, xmm13
00000001803714F2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803714F6  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803714F9  E8 DA DF 37 00              call    fmodf
00000001803714FE  0F 28 F0                    movaps  xmm6, xmm0
0000000180371501  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180371506  0F 54 35 83 42 77 00        andps   xmm6, cs:xmmword_180AE5790
000000018037150D  F3 0F 11 BB D0 58 00 00     movss   dword ptr [rbx+58D0h], xmm7
0000000180371515  0F 28 E6                    movaps  xmm4, xmm6
0000000180371518  F3 0F 10 9B 10 5A 00 00     movss   xmm3, dword ptr [rbx+5A10h]
0000000180371520  0F 28 D6                    movaps  xmm2, xmm6
0000000180371523  F3 0F 59 93 A0 5A 00 00     mulss   xmm2, dword ptr [rbx+5AA0h]
000000018037152B  F3 0F 59 9B 00 59 00 00     mulss   xmm3, dword ptr [rbx+5900h]
0000000180371533  F3 0F 58 93 90 5A 00 00     addss   xmm2, dword ptr [rbx+5A90h]
000000018037153B  F3 0F 10 8B 00 5A 00 00     movss   xmm1, dword ptr [rbx+5A00h]
0000000180371543  F3 0F 59 8B C0 58 00 00     mulss   xmm1, dword ptr [rbx+58C0h]
000000018037154B  F3 0F 59 E6                 mulss   xmm4, xmm6
000000018037154F  0F 28 C4                    movaps  xmm0, xmm4
0000000180371552  F3 0F 59 E6                 mulss   xmm4, xmm6
0000000180371556  F3 0F 59 83 B0 5A 00 00     mulss   xmm0, dword ptr [rbx+5AB0h]
000000018037155E  F3 0F 59 F4                 mulss   xmm6, xmm4
0000000180371562  F3 0F 59 A3 C0 5A 00 00     mulss   xmm4, dword ptr [rbx+5AC0h]
000000018037156A  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037156E  F3 0F 59 B3 D0 5A 00 00     mulss   xmm6, dword ptr [rbx+5AD0h]
0000000180371576  F3 0F 10 83 F0 59 00 00     movss   xmm0, dword ptr [rbx+59F0h]
000000018037157E  F3 0F 59 83 B0 58 00 00     mulss   xmm0, dword ptr [rbx+58B0h]
0000000180371586  F3 0F 58 E2                 addss   xmm4, xmm2
000000018037158A  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037158E  F3 0F 58 F4                 addss   xmm6, xmm4
0000000180371592  F3 0F 10 A3 D0 59 00 00     movss   xmm4, dword ptr [rbx+59D0h]
000000018037159A  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037159E  F3 0F 58 B3 E0 5A 00 00     addss   xmm6, dword ptr [rbx+5AE0h]
00000001803715A6  F3 0F 59 B3 80 5B 00 00     mulss   xmm6, dword ptr [rbx+5B80h]
00000001803715AE  F3 0F 11 B3 F0 58 00 00     movss   dword ptr [rbx+58F0h], xmm6
00000001803715B6  F3 0F 59 A3 E0 58 00 00     mulss   xmm4, dword ptr [rbx+58E0h]
00000001803715BE  F3 0F 10 8B B0 59 00 00     movss   xmm1, dword ptr [rbx+59B0h]
00000001803715C6  F3 0F 10 83 E0 59 00 00     movss   xmm0, dword ptr [rbx+59E0h]
00000001803715CE  F3 0F 59 83 D0 58 00 00     mulss   xmm0, dword ptr [rbx+58D0h]
00000001803715D6  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803715DA  F3 0F 10 93 40 5A 00 00     movss   xmm2, dword ptr [rbx+5A40h]
00000001803715E2  0F 28 D9                    movaps  xmm3, xmm1
00000001803715E5  F3 0F 59 9B E0 57 00 00     mulss   xmm3, dword ptr [rbx+57E0h]
00000001803715ED  F3 0F 59 B3 C0 59 00 00     mulss   xmm6, dword ptr [rbx+59C0h]
00000001803715F5  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803715F9  F3 0F 10 83 20 5A 00 00     movss   xmm0, dword ptr [rbx+5A20h]
0000000180371601  F3 0F 5C D9                 subss   xmm3, xmm1
0000000180371605  F3 0F 59 83 A0 57 00 00     mulss   xmm0, dword ptr [rbx+57A0h]
000000018037160D  F3 0F 58 E6                 addss   xmm4, xmm6
0000000180371611  F3 41 0F 58 DD              addss   xmm3, xmm13
0000000180371616  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037161A  F3 0F 11 9B 10 59 00 00     movss   dword ptr [rbx+5910h], xmm3
0000000180371622  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180371626  F3 0F 11 A3 30 59 00 00     movss   dword ptr [rbx+5930h], xmm4
000000018037162E  F3 0F 10 8B 60 5A 00 00     movss   xmm1, dword ptr [rbx+5A60h]
0000000180371636  F3 0F 59 8B D0 57 00 00     mulss   xmm1, dword ptr [rbx+57D0h]
000000018037163E  F3 0F 10 83 50 5A 00 00     movss   xmm0, dword ptr [rbx+5A50h]
0000000180371646  F3 0F 59 83 C0 57 00 00     mulss   xmm0, dword ptr [rbx+57C0h]
000000018037164E  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180371652  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180371656  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037165A  F3 0F 11 8B 20 59 00 00     movss   dword ptr [rbx+5920h], xmm1
0000000180371662  F3 0F 10 83 30 59 00 00     movss   xmm0, dword ptr [rbx+5930h]
000000018037166A  8B 83 40 59 00 00           mov     eax, [rbx+5940h]
0000000180371670  89 83 00 5C 00 00           mov     [rbx+5C00h], eax
0000000180371676  F3 0F 11 83 10 5C 00 00     movss   dword ptr [rbx+5C10h], xmm0
000000018037167E  44 0F 2F B3 40 59 00 00     comiss  xmm14, dword ptr [rbx+5940h]
0000000180371686  F3 0F 10 8B 50 54 00 00     movss   xmm1, dword ptr [rbx+5450h]
000000018037168E  F3 0F 10 93 20 5C 00 00     movss   xmm2, dword ptr [rbx+5C20h]
0000000180371696  73 06                       jnb     short loc_18037169E
0000000180371698  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037169C  EB 03                       jmp     short loc_1803716A1
000000018037169E  0F 57 C0                    xorps   xmm0, xmm0
00000001803716A1  41 0F 2E D6                 ucomiss xmm2, xmm14
00000001803716A5  75 04                       jnz     short loc_1803716AB
00000001803716A7  41 0F 28 C5                 movaps  xmm0, xmm13
00000001803716AB  F3 0F 59 C8                 mulss   xmm1, xmm0
00000001803716AF  F3 0F 11 8B 30 5C 00 00     movss   dword ptr [rbx+5C30h], xmm1
00000001803716B7  8B 83 40 5C 00 00           mov     eax, [rbx+5C40h]
00000001803716BD  89 83 50 5C 00 00           mov     [rbx+5C50h], eax
00000001803716C3  8B 83 70 5C 00 00           mov     eax, [rbx+5C70h]
00000001803716C9  89 83 80 5C 00 00           mov     [rbx+5C80h], eax
00000001803716CF  8B 83 60 5C 00 00           mov     eax, [rbx+5C60h]
00000001803716D5  89 83 70 5C 00 00           mov     [rbx+5C70h], eax
00000001803716DB  8B 83 90 5C 00 00           mov     eax, [rbx+5C90h]
00000001803716E1  89 83 A0 5C 00 00           mov     [rbx+5CA0h], eax
00000001803716E7  8B 83 C0 5C 00 00           mov     eax, [rbx+5CC0h]
00000001803716ED  89 83 D0 5C 00 00           mov     [rbx+5CD0h], eax
00000001803716F3  F3 0F 10 83 70 5D 00 00     movss   xmm0, dword ptr [rbx+5D70h]
00000001803716FB  F3 0F 58 8B 50 5D 00 00     addss   xmm1, dword ptr [rbx+5D50h]
0000000180371703  F3 0F 59 83 80 5C 00 00     mulss   xmm0, dword ptr [rbx+5C80h]
000000018037170B  41 0F 2F CE                 comiss  xmm1, xmm14
000000018037170F  F3 0F 58 83 50 5C 00 00     addss   xmm0, dword ptr [rbx+5C50h]
0000000180371717  73 06                       jnb     short loc_18037171F
0000000180371719  45 0F 28 C5                 movaps  xmm8, xmm13
000000018037171D  EB 04                       jmp     short loc_180371723
000000018037171F  45 0F 57 C0                 xorps   xmm8, xmm8
0000000180371723  41 0F 28 ED                 movaps  xmm5, xmm13
0000000180371727  F3 41 0F 5C E8              subss   xmm5, xmm8
000000018037172C  0F 28 FD                    movaps  xmm7, xmm5
000000018037172F  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180371733  F3 0F 11 BB 60 5C 00 00     movss   dword ptr [rbx+5C60h], xmm7
000000018037173B  0F 28 E7                    movaps  xmm4, xmm7
000000018037173E  F3 0F 10 9B 40 5D 00 00     movss   xmm3, dword ptr [rbx+5D40h]
0000000180371746  F3 0F 10 93 90 5D 00 00     movss   xmm2, dword ptr [rbx+5D90h]
000000018037174E  0F 28 CB                    movaps  xmm1, xmm3
0000000180371751  F3 0F 59 8B B0 5D 00 00     mulss   xmm1, dword ptr [rbx+5DB0h]
0000000180371759  0F 28 C2                    movaps  xmm0, xmm2
000000018037175C  F3 0F 58 A3 60 5D 00 00     addss   xmm4, dword ptr [rbx+5D60h]
0000000180371764  F3 0F 5C BB 70 5C 00 00     subss   xmm7, dword ptr [rbx+5C70h]
000000018037176C  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180371770  41 0F 2F E6                 comiss  xmm4, xmm14
0000000180371774  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180371778  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037177C  F3 0F 11 8B B0 5C 00 00     movss   dword ptr [rbx+5CB0h], xmm1
0000000180371784  72 06                       jb      short loc_18037178C
0000000180371786  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037178A  EB 03                       jmp     short loc_18037178F
000000018037178C  0F 57 F6                    xorps   xmm6, xmm6
000000018037178F  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180371793  F3 0F 10 83 10 5D 00 00     movss   xmm0, dword ptr [rbx+5D10h]
000000018037179B  73 03                       jnb     short loc_1803717A0
000000018037179D  0F 28 F5                    movaps  xmm6, xmm5
00000001803717A0  F3 0F 59 83 90 5D 00 00     mulss   xmm0, dword ptr [rbx+5D90h]
00000001803717A8  0F 28 DD                    movaps  xmm3, xmm5
00000001803717AB  F3 0F 10 93 00 5D 00 00     movss   xmm2, dword ptr [rbx+5D00h]
00000001803717B3  F3 44 0F 10 0D A0 37 77 00  movss   xmm9, cs:dword_180AE4F5C
00000001803717BC  F3 0F 59 D8                 mulss   xmm3, xmm0
00000001803717C0  F3 0F 11 B3 70 5C 00 00     movss   dword ptr [rbx+5C70h], xmm6
00000001803717C8  F3 0F 10 8B A0 5D 00 00     movss   xmm1, dword ptr [rbx+5DA0h]
00000001803717D0  F3 0F 10 BB 20 5D 00 00     movss   xmm7, dword ptr [rbx+5D20h]
00000001803717D8  0F 28 C1                    movaps  xmm0, xmm1
00000001803717DB  F3 0F 10 A3 A0 5C 00 00     movss   xmm4, dword ptr [rbx+5CA0h]
00000001803717E3  F3 0F 59 C5                 mulss   xmm0, xmm5
00000001803717E7  F3 41 0F 59 F9              mulss   xmm7, xmm9
00000001803717EC  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803717F0  F3 41 0F 59 D1              mulss   xmm2, xmm9
00000001803717F5  41 0F 28 C5                 movaps  xmm0, xmm13
00000001803717F9  F3 0F 59 FE                 mulss   xmm7, xmm6
00000001803717FD  F3 0F 5C C6                 subss   xmm0, xmm6
0000000180371801  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180371805  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180371809  0F 28 CB                    movaps  xmm1, xmm3
000000018037180C  F3 0F 5C CC                 subss   xmm1, xmm4
0000000180371810  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180371814  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180371818  F3 0F 58 FA                 addss   xmm7, xmm2
000000018037181C  76 0B                       jbe     short loc_180371829
000000018037181E  0F 28 DC                    movaps  xmm3, xmm4
0000000180371821  F3 0F 58 9B B0 5C 00 00     addss   xmm3, dword ptr [rbx+5CB0h]
0000000180371829  F3 0F 10 83 90 5D 00 00     movss   xmm0, dword ptr [rbx+5D90h]
0000000180371831  F3 0F 10 A3 50 5C 00 00     movss   xmm4, dword ptr [rbx+5C50h]
0000000180371839  F3 0F 5D C3                 minss   xmm0, xmm3
000000018037183D  F3 0F 11 83 90 5C 00 00     movss   dword ptr [rbx+5C90h], xmm0
0000000180371845  F3 0F 10 8B D0 5C 00 00     movss   xmm1, dword ptr [rbx+5CD0h]
000000018037184D  F3 0F 10 9B 30 5D 00 00     movss   xmm3, dword ptr [rbx+5D30h]
0000000180371855  F3 0F 59 AB 80 5D 00 00     mulss   xmm5, dword ptr [rbx+5D80h]
000000018037185D  F3 41 0F 59 D9              mulss   xmm3, xmm9
0000000180371862  F3 0F 59 F0                 mulss   xmm6, xmm0
0000000180371866  F3 0F 10 83 C0 5D 00 00     movss   xmm0, dword ptr [rbx+5DC0h]
000000018037186E  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180371873  0F 28 D0                    movaps  xmm2, xmm0
0000000180371876  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037187A  F3 0F 58 EE                 addss   xmm5, xmm6
000000018037187E  F3 0F 59 D7                 mulss   xmm2, xmm7
0000000180371882  F3 0F 5C EC                 subss   xmm5, xmm4
0000000180371886  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037188A  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037188E  F3 0F 11 93 C0 5C 00 00     movss   dword ptr [rbx+5CC0h], xmm2
0000000180371896  F3 44 0F 59 C2              mulss   xmm8, xmm2
000000018037189B  F3 41 0F 5C D8              subss   xmm3, xmm8
00000001803718A0  F3 0F 58 DA                 addss   xmm3, xmm2
00000001803718A4  F3 0F 59 DD                 mulss   xmm3, xmm5
00000001803718A8  F3 0F 58 DC                 addss   xmm3, xmm4
00000001803718AC  F3 0F 11 9B 40 5C 00 00     movss   dword ptr [rbx+5C40h], xmm3
00000001803718B4  F3 0F 59 9B D0 5D 00 00     mulss   xmm3, dword ptr [rbx+5DD0h]
00000001803718BC  F3 0F 59 9B E0 5D 00 00     mulss   xmm3, dword ptr [rbx+5DE0h]
00000001803718C4  0F 28 C3                    movaps  xmm0, xmm3
00000001803718C7  F3 0F 59 83 F0 5D 00 00     mulss   xmm0, dword ptr [rbx+5DF0h]
00000001803718CF  F3 0F 11 9B E0 5C 00 00     movss   dword ptr [rbx+5CE0h], xmm3
00000001803718D7  F3 0F 11 83 F0 5C 00 00     movss   dword ptr [rbx+5CF0h], xmm0
00000001803718DF  44 0F 2F B3 40 59 00 00     comiss  xmm14, dword ptr [rbx+5940h]
00000001803718E7  F3 0F 10 8B 50 54 00 00     movss   xmm1, dword ptr [rbx+5450h]
00000001803718EF  F3 0F 10 93 00 5E 00 00     movss   xmm2, dword ptr [rbx+5E00h]
00000001803718F7  73 06                       jnb     short loc_1803718FF
00000001803718F9  41 0F 28 C5                 movaps  xmm0, xmm13
00000001803718FD  EB 03                       jmp     short loc_180371902
00000001803718FF  0F 57 C0                    xorps   xmm0, xmm0
0000000180371902  41 0F 2E D6                 ucomiss xmm2, xmm14
0000000180371906  75 04                       jnz     short loc_18037190C
0000000180371908  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037190C  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180371910  F3 0F 11 8B 10 5E 00 00     movss   dword ptr [rbx+5E10h], xmm1
0000000180371918  8B 83 20 5E 00 00           mov     eax, [rbx+5E20h]
000000018037191E  89 83 30 5E 00 00           mov     [rbx+5E30h], eax
0000000180371924  8B 83 50 5E 00 00           mov     eax, [rbx+5E50h]
000000018037192A  89 83 60 5E 00 00           mov     [rbx+5E60h], eax
0000000180371930  8B 83 40 5E 00 00           mov     eax, [rbx+5E40h]
0000000180371936  89 83 50 5E 00 00           mov     [rbx+5E50h], eax
000000018037193C  8B 83 70 5E 00 00           mov     eax, [rbx+5E70h]
0000000180371942  89 83 80 5E 00 00           mov     [rbx+5E80h], eax
0000000180371948  8B 83 A0 5E 00 00           mov     eax, [rbx+5EA0h]
000000018037194E  89 83 B0 5E 00 00           mov     [rbx+5EB0h], eax
0000000180371954  F3 0F 10 83 50 5F 00 00     movss   xmm0, dword ptr [rbx+5F50h]
000000018037195C  F3 0F 58 8B 30 5F 00 00     addss   xmm1, dword ptr [rbx+5F30h]
0000000180371964  F3 0F 59 83 60 5E 00 00     mulss   xmm0, dword ptr [rbx+5E60h]
000000018037196C  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180371970  F3 0F 58 83 30 5E 00 00     addss   xmm0, dword ptr [rbx+5E30h]
0000000180371978  73 06                       jnb     short loc_180371980
000000018037197A  45 0F 28 C5                 movaps  xmm8, xmm13
000000018037197E  EB 04                       jmp     short loc_180371984
0000000180371980  45 0F 57 C0                 xorps   xmm8, xmm8
0000000180371984  41 0F 28 ED                 movaps  xmm5, xmm13
0000000180371988  F3 41 0F 5C E8              subss   xmm5, xmm8
000000018037198D  0F 28 F5                    movaps  xmm6, xmm5
0000000180371990  F3 0F 59 F0                 mulss   xmm6, xmm0
0000000180371994  F3 0F 11 B3 40 5E 00 00     movss   dword ptr [rbx+5E40h], xmm6
000000018037199C  0F 28 E6                    movaps  xmm4, xmm6
000000018037199F  F3 0F 10 9B 20 5F 00 00     movss   xmm3, dword ptr [rbx+5F20h]
00000001803719A7  F3 0F 10 93 70 5F 00 00     movss   xmm2, dword ptr [rbx+5F70h]
00000001803719AF  0F 28 CB                    movaps  xmm1, xmm3
00000001803719B2  F3 0F 59 8B 90 5F 00 00     mulss   xmm1, dword ptr [rbx+5F90h]
00000001803719BA  0F 28 C2                    movaps  xmm0, xmm2
00000001803719BD  F3 0F 58 A3 40 5F 00 00     addss   xmm4, dword ptr [rbx+5F40h]
00000001803719C5  F3 0F 5C B3 50 5E 00 00     subss   xmm6, dword ptr [rbx+5E50h]
00000001803719CD  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803719D1  41 0F 2F E6                 comiss  xmm4, xmm14
00000001803719D5  F3 0F 5C C8                 subss   xmm1, xmm0
00000001803719D9  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803719DD  F3 0F 11 8B 90 5E 00 00     movss   dword ptr [rbx+5E90h], xmm1
00000001803719E5  72 06                       jb      short loc_1803719ED
00000001803719E7  41 0F 28 FD                 movaps  xmm7, xmm13
00000001803719EB  EB 03                       jmp     short loc_1803719F0
00000001803719ED  0F 57 FF                    xorps   xmm7, xmm7
00000001803719F0  41 0F 2F F6                 comiss  xmm6, xmm14
00000001803719F4  F3 0F 10 83 F0 5E 00 00     movss   xmm0, dword ptr [rbx+5EF0h]
00000001803719FC  73 03                       jnb     short loc_180371A01
00000001803719FE  0F 28 FD                    movaps  xmm7, xmm5
0000000180371A01  F3 0F 59 83 70 5F 00 00     mulss   xmm0, dword ptr [rbx+5F70h]
0000000180371A09  0F 28 DD                    movaps  xmm3, xmm5
0000000180371A0C  F3 0F 10 93 E0 5E 00 00     movss   xmm2, dword ptr [rbx+5EE0h]
0000000180371A14  F3 0F 11 BB 50 5E 00 00     movss   dword ptr [rbx+5E50h], xmm7
0000000180371A1C  F3 0F 10 8B 80 5F 00 00     movss   xmm1, dword ptr [rbx+5F80h]
0000000180371A24  F3 0F 10 B3 00 5F 00 00     movss   xmm6, dword ptr [rbx+5F00h]
0000000180371A2C  F3 0F 10 A3 80 5E 00 00     movss   xmm4, dword ptr [rbx+5E80h]
0000000180371A34  F3 0F 59 D8                 mulss   xmm3, xmm0
0000000180371A38  0F 28 C1                    movaps  xmm0, xmm1
0000000180371A3B  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180371A3F  F3 41 0F 59 F1              mulss   xmm6, xmm9
0000000180371A44  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180371A48  F3 41 0F 59 D1              mulss   xmm2, xmm9
0000000180371A4D  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180371A51  F3 0F 59 F7                 mulss   xmm6, xmm7
0000000180371A55  F3 0F 5C C7                 subss   xmm0, xmm7
0000000180371A59  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180371A5D  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180371A61  0F 28 CB                    movaps  xmm1, xmm3
0000000180371A64  F3 0F 5C CC                 subss   xmm1, xmm4
0000000180371A68  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180371A6C  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180371A70  F3 0F 58 F2                 addss   xmm6, xmm2
0000000180371A74  76 0B                       jbe     short loc_180371A81
0000000180371A76  0F 28 DC                    movaps  xmm3, xmm4
0000000180371A79  F3 0F 58 9B 90 5E 00 00     addss   xmm3, dword ptr [rbx+5E90h]
0000000180371A81  F3 0F 10 A3 30 5E 00 00     movss   xmm4, dword ptr [rbx+5E30h]
0000000180371A89  F3 0F 10 83 70 5F 00 00     movss   xmm0, dword ptr [rbx+5F70h]
0000000180371A91  F3 0F 5D C3                 minss   xmm0, xmm3
0000000180371A95  F3 0F 11 83 70 5E 00 00     movss   dword ptr [rbx+5E70h], xmm0
0000000180371A9D  F3 0F 59 AB 60 5F 00 00     mulss   xmm5, dword ptr [rbx+5F60h]
0000000180371AA5  F3 0F 10 8B B0 5E 00 00     movss   xmm1, dword ptr [rbx+5EB0h]
0000000180371AAD  F3 0F 10 9B 10 5F 00 00     movss   xmm3, dword ptr [rbx+5F10h]
0000000180371AB5  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180371AB9  F3 0F 10 83 A0 5F 00 00     movss   xmm0, dword ptr [rbx+5FA0h]
0000000180371AC1  0F 28 D0                    movaps  xmm2, xmm0
0000000180371AC4  F3 41 0F 59 D9              mulss   xmm3, xmm9
0000000180371AC9  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180371ACD  F3 0F 58 EF                 addss   xmm5, xmm7
0000000180371AD1  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180371AD6  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180371ADA  F3 0F 5C EC                 subss   xmm5, xmm4
0000000180371ADE  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180371AE2  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180371AE6  F3 0F 11 93 A0 5E 00 00     movss   dword ptr [rbx+5EA0h], xmm2
0000000180371AEE  F3 44 0F 59 C2              mulss   xmm8, xmm2
0000000180371AF3  F3 41 0F 5C D8              subss   xmm3, xmm8
0000000180371AF8  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180371AFC  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180371B00  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180371B04  F3 0F 11 9B 20 5E 00 00     movss   dword ptr [rbx+5E20h], xmm3
0000000180371B0C  F3 0F 59 9B B0 5F 00 00     mulss   xmm3, dword ptr [rbx+5FB0h]
0000000180371B14  F3 0F 59 9B C0 5F 00 00     mulss   xmm3, dword ptr [rbx+5FC0h]
0000000180371B1C  0F 28 C3                    movaps  xmm0, xmm3
0000000180371B1F  F3 0F 59 83 D0 5F 00 00     mulss   xmm0, dword ptr [rbx+5FD0h]
0000000180371B27  F3 0F 11 9B C0 5E 00 00     movss   dword ptr [rbx+5EC0h], xmm3
0000000180371B2F  F3 0F 11 83 D0 5E 00 00     movss   dword ptr [rbx+5ED0h], xmm0
0000000180371B37  8B 83 E0 5F 00 00           mov     eax, [rbx+5FE0h]
0000000180371B3D  89 83 F0 5F 00 00           mov     [rbx+5FF0h], eax
0000000180371B43  8B 83 00 60 00 00           mov     eax, [rbx+6000h]
0000000180371B49  89 83 10 60 00 00           mov     [rbx+6010h], eax
0000000180371B4F  F3 0F 10 83 10 55 00 00     movss   xmm0, dword ptr [rbx+5510h]
0000000180371B57  F3 44 0F 10 83 90 55 00 00  movss   xmm8, dword ptr [rbx+5590h]
0000000180371B60  8B 83 40 60 00 00           mov     eax, [rbx+6040h]
0000000180371B66  89 83 50 60 00 00           mov     [rbx+6050h], eax
0000000180371B6C  F3 0F 59 83 20 60 00 00     mulss   xmm0, dword ptr [rbx+6020h]
0000000180371B74  F3 44 0F 59 83 30 60 00 00  mulss   xmm8, dword ptr [rbx+6030h]
0000000180371B7D  F3 44 0F 58 C0              addss   xmm8, xmm0
0000000180371B82  F3 44 0F 11 83 40 60 00 00  movss   dword ptr [rbx+6040h], xmm8
0000000180371B8B  F3 0F 10 BB 20 59 00 00     movss   xmm7, dword ptr [rbx+5920h]
0000000180371B93  F3 0F 10 8B E0 5C 00 00     movss   xmm1, dword ptr [rbx+5CE0h]
0000000180371B9B  F3 0F 10 93 C0 5E 00 00     movss   xmm2, dword ptr [rbx+5EC0h]
0000000180371BA3  F3 0F 10 83 10 55 00 00     movss   xmm0, dword ptr [rbx+5510h]
0000000180371BAB  8B 83 00 60 00 00           mov     eax, [rbx+6000h]
0000000180371BB1  89 83 80 60 00 00           mov     [rbx+6080h], eax
0000000180371BB7  F3 0F 11 83 90 60 00 00     movss   dword ptr [rbx+6090h], xmm0
0000000180371BBF  F3 0F 10 A3 D0 61 00 00     movss   xmm4, dword ptr [rbx+61D0h]
0000000180371BC7  F3 0F 11 8B 60 60 00 00     movss   dword ptr [rbx+6060h], xmm1
0000000180371BCF  F3 0F 11 93 70 60 00 00     movss   dword ptr [rbx+6070h], xmm2
0000000180371BD7  F3 0F 10 AB B0 61 00 00     movss   xmm5, dword ptr [rbx+61B0h]
0000000180371BDF  F3 0F 59 FC                 mulss   xmm7, xmm4
0000000180371BE3  F3 0F 59 A3 30 59 00 00     mulss   xmm4, dword ptr [rbx+5930h]
0000000180371BEB  F3 0F 11 A3 A0 60 00 00     movss   dword ptr [rbx+60A0h], xmm4
0000000180371BF3  F3 0F 10 8B 30 61 00 00     movss   xmm1, dword ptr [rbx+6130h]
0000000180371BFB  F3 0F 10 93 30 62 00 00     movss   xmm2, dword ptr [rbx+6230h]
0000000180371C03  0F 28 D9                    movaps  xmm3, xmm1
0000000180371C06  F3 0F 59 BB E0 61 00 00     mulss   xmm7, dword ptr [rbx+61E0h]
0000000180371C0E  0F 28 C2                    movaps  xmm0, xmm2
0000000180371C11  F3 0F 10 B3 F0 61 00 00     movss   xmm6, dword ptr [rbx+61F0h]
0000000180371C19  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180371C1D  F3 0F 59 F7                 mulss   xmm6, xmm7
0000000180371C21  F3 0F 59 EC                 mulss   xmm5, xmm4
0000000180371C25  F3 0F 59 AB C0 61 00 00     mulss   xmm5, dword ptr [rbx+61C0h]
0000000180371C2D  F3 0F 11 AB C0 60 00 00     movss   dword ptr [rbx+60C0h], xmm5
0000000180371C35  F3 0F 58 F5                 addss   xmm6, xmm5
0000000180371C39  F3 0F 59 9B 80 60 00 00     mulss   xmm3, dword ptr [rbx+6080h]
0000000180371C41  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180371C45  F3 0F 10 83 40 61 00 00     movss   xmm0, dword ptr [rbx+6140h]
0000000180371C4D  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180371C51  F3 0F 59 9B 40 62 00 00     mulss   xmm3, dword ptr [rbx+6240h]
0000000180371C59  F3 0F 11 9B D0 60 00 00     movss   dword ptr [rbx+60D0h], xmm3
0000000180371C61  F3 0F 10 8B 10 62 00 00     movss   xmm1, dword ptr [rbx+6210h]
0000000180371C69  F3 0F 59 8B 70 60 00 00     mulss   xmm1, dword ptr [rbx+6070h]
0000000180371C71  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180371C75  F3 0F 58 F0                 addss   xmm6, xmm0
0000000180371C79  F3 0F 10 83 00 62 00 00     movss   xmm0, dword ptr [rbx+6200h]
0000000180371C81  F3 0F 59 83 60 60 00 00     mulss   xmm0, dword ptr [rbx+6060h]
0000000180371C89  F3 0F 10 9B A0 60 00 00     movss   xmm3, dword ptr [rbx+60A0h]
0000000180371C91  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180371C95  F3 0F 10 83 20 61 00 00     movss   xmm0, dword ptr [rbx+6120h]
0000000180371C9D  F3 0F 59 8B 20 62 00 00     mulss   xmm1, dword ptr [rbx+6220h]
0000000180371CA5  F3 0F 58 CE                 addss   xmm1, xmm6
0000000180371CA9  F3 41 0F 58 C8              addss   xmm1, xmm8
0000000180371CAE  F3 0F 58 8B 90 61 00 00     addss   xmm1, dword ptr [rbx+6190h]
0000000180371CB6  F3 0F 58 8B A0 61 00 00     addss   xmm1, dword ptr [rbx+61A0h]
0000000180371CBE  F3 0F 11 8B E0 60 00 00     movss   dword ptr [rbx+60E0h], xmm1
0000000180371CC6  F3 0F 11 83 F0 60 00 00     movss   dword ptr [rbx+60F0h], xmm0
0000000180371CCE  F3 0F 59 9B 60 62 00 00     mulss   xmm3, dword ptr [rbx+6260h]
0000000180371CD6  F3 0F 10 83 60 61 00 00     movss   xmm0, dword ptr [rbx+6160h]
0000000180371CDE  F3 0F 59 83 60 60 00 00     mulss   xmm0, dword ptr [rbx+6060h]
0000000180371CE6  F3 0F 58 9B 70 62 00 00     addss   xmm3, dword ptr [rbx+6270h]
0000000180371CEE  F3 0F 10 8B 70 61 00 00     movss   xmm1, dword ptr [rbx+6170h]
0000000180371CF6  F3 0F 59 8B 70 60 00 00     mulss   xmm1, dword ptr [rbx+6070h]
0000000180371CFE  F3 0F 10 93 C0 60 00 00     movss   xmm2, dword ptr [rbx+60C0h]
0000000180371D06  F3 0F 59 9B 50 61 00 00     mulss   xmm3, dword ptr [rbx+6150h]
0000000180371D0E  F3 0F 58 93 90 60 00 00     addss   xmm2, dword ptr [rbx+6090h]
0000000180371D16  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180371D1A  F3 0F 58 93 D0 60 00 00     addss   xmm2, dword ptr [rbx+60D0h]
0000000180371D22  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180371D26  F3 0F 58 9B 80 61 00 00     addss   xmm3, dword ptr [rbx+6180h]
0000000180371D2E  F3 0F 59 9B 50 62 00 00     mulss   xmm3, dword ptr [rbx+6250h]
0000000180371D36  F3 0F 11 9B 00 61 00 00     movss   dword ptr [rbx+6100h], xmm3
0000000180371D3E  F3 0F 11 93 10 61 00 00     movss   dword ptr [rbx+6110h], xmm2
0000000180371D46  F3 0F 10 83 90 62 00 00     movss   xmm0, dword ptr [rbx+6290h]
0000000180371D4E  8B 83 80 62 00 00           mov     eax, [rbx+6280h]
0000000180371D54  89 83 B0 62 00 00           mov     [rbx+62B0h], eax
0000000180371D5A  F3 0F 11 83 C0 62 00 00     movss   dword ptr [rbx+62C0h], xmm0
0000000180371D62  8B 83 A0 62 00 00           mov     eax, [rbx+62A0h]
0000000180371D68  89 83 D0 62 00 00           mov     [rbx+62D0h], eax
0000000180371D6E  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
0000000180371D76  8B 83 F0 62 00 00           mov     eax, [rbx+62F0h]
0000000180371D7C  89 83 00 63 00 00           mov     [rbx+6300h], eax
0000000180371D82  F3 0F 10 93 E0 62 00 00     movss   xmm2, dword ptr [rbx+62E0h]
0000000180371D8A  F3 0F 11 93 F0 62 00 00     movss   dword ptr [rbx+62F0h], xmm2
0000000180371D92  0F 28 C2                    movaps  xmm0, xmm2
0000000180371D95  0F 28 DA                    movaps  xmm3, xmm2
0000000180371D98  F3 0F 59 9B 10 63 00 00     mulss   xmm3, dword ptr [rbx+6310h]
0000000180371DA0  F3 0F 58 9B 00 63 00 00     addss   xmm3, dword ptr [rbx+6300h]
0000000180371DA8  F3 0F 11 9B F0 62 00 00     movss   dword ptr [rbx+62F0h], xmm3
0000000180371DB0  F3 0F 59 83 20 63 00 00     mulss   xmm0, dword ptr [rbx+6320h]
0000000180371DB8  F3 0F 58 C3                 addss   xmm0, xmm3
0000000180371DBC  F3 0F 59 9B 50 63 00 00     mulss   xmm3, dword ptr [rbx+6350h]
0000000180371DC4  F3 0F 5C E0                 subss   xmm4, xmm0
0000000180371DC8  0F 28 CC                    movaps  xmm1, xmm4
0000000180371DCB  F3 0F 59 8B 10 63 00 00     mulss   xmm1, dword ptr [rbx+6310h]
0000000180371DD3  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180371DD7  F3 0F 11 8B E0 62 00 00     movss   dword ptr [rbx+62E0h], xmm1
0000000180371DDF  F3 0F 59 8B 40 63 00 00     mulss   xmm1, dword ptr [rbx+6340h]
0000000180371DE7  F3 0F 59 A3 30 63 00 00     mulss   xmm4, dword ptr [rbx+6330h]
0000000180371DEF  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180371DF3  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180371DF7  F3 0F 11 A3 00 63 00 00     movss   dword ptr [rbx+6300h], xmm4
0000000180371DFF  8B 83 30 6B 00 00           mov     eax, [rbx+6B30h]
0000000180371E05  89 83 40 6B 00 00           mov     [rbx+6B40h], eax
0000000180371E0B  F3 0F 10 8B 50 6B 00 00     movss   xmm1, dword ptr [rbx+6B50h]
0000000180371E13  F3 0F 11 8B 60 6B 00 00     movss   dword ptr [rbx+6B60h], xmm1
0000000180371E1B  F3 0F 59 8B F0 5F 00 00     mulss   xmm1, dword ptr [rbx+5FF0h]
0000000180371E23  F3 0F 10 83 40 6B 00 00     movss   xmm0, dword ptr [rbx+6B40h]
0000000180371E2B  F3 0F 59 83 00 63 00 00     mulss   xmm0, dword ptr [rbx+6300h]
0000000180371E33  F3 0F 11 8B 70 6B 00 00     movss   dword ptr [rbx+6B70h], xmm1
0000000180371E3B  F3 0F 11 83 80 6B 00 00     movss   dword ptr [rbx+6B80h], xmm0
0000000180371E43  8B 83 B0 6B 00 00           mov     eax, [rbx+6BB0h]
0000000180371E49  89 83 C0 6B 00 00           mov     [rbx+6BC0h], eax
0000000180371E4F  F3 0F 59 8B 90 6B 00 00     mulss   xmm1, dword ptr [rbx+6B90h]
0000000180371E57  F3 0F 59 83 A0 6B 00 00     mulss   xmm0, dword ptr [rbx+6BA0h]
0000000180371E5F  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180371E63  F3 0F 11 83 B0 6B 00 00     movss   dword ptr [rbx+6BB0h], xmm0
0000000180371E6B  8B 83 D0 6B 00 00           mov     eax, [rbx+6BD0h]
0000000180371E71  89 83 E0 6B 00 00           mov     [rbx+6BE0h], eax
0000000180371E77  8B 83 F0 6B 00 00           mov     eax, [rbx+6BF0h]
0000000180371E7D  89 83 00 6C 00 00           mov     [rbx+6C00h], eax
0000000180371E83  8B 83 10 6C 00 00           mov     eax, [rbx+6C10h]
0000000180371E89  89 83 20 6C 00 00           mov     [rbx+6C20h], eax
0000000180371E8F  8B 83 30 6C 00 00           mov     eax, [rbx+6C30h]
0000000180371E95  89 83 40 6C 00 00           mov     [rbx+6C40h], eax
0000000180371E9B  F3 0F 10 8B 60 6C 00 00     movss   xmm1, dword ptr [rbx+6C60h]
0000000180371EA3  F3 0F 10 93 70 6C 00 00     movss   xmm2, dword ptr [rbx+6C70h]
0000000180371EAB  0F 28 E1                    movaps  xmm4, xmm1
0000000180371EAE  F3 0F 59 A3 D0 6B 00 00     mulss   xmm4, dword ptr [rbx+6BD0h]
0000000180371EB6  0F 28 C2                    movaps  xmm0, xmm2
0000000180371EB9  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180371EBD  F3 0F 5C E0                 subss   xmm4, xmm0
0000000180371EC1  F3 0F 58 E2                 addss   xmm4, xmm2
0000000180371EC5  0F 28 DC                    movaps  xmm3, xmm4
0000000180371EC8  0F 28 CC                    movaps  xmm1, xmm4
0000000180371ECB  F3 0F 59 8B 90 6C 00 00     mulss   xmm1, dword ptr [rbx+6C90h]
0000000180371ED3  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180371ED7  F3 0F 58 8B 80 6C 00 00     addss   xmm1, dword ptr [rbx+6C80h]
0000000180371EDF  0F 28 C3                    movaps  xmm0, xmm3
0000000180371EE2  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180371EE6  F3 0F 59 83 A0 6C 00 00     mulss   xmm0, dword ptr [rbx+6CA0h]
0000000180371EEE  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180371EF2  0F 28 C3                    movaps  xmm0, xmm3
0000000180371EF5  F3 0F 59 9B B0 6C 00 00     mulss   xmm3, dword ptr [rbx+6CB0h]
0000000180371EFD  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180371F01  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180371F05  F3 0F 59 83 C0 6C 00 00     mulss   xmm0, dword ptr [rbx+6CC0h]
0000000180371F0D  F3 0F 58 C3                 addss   xmm0, xmm3
0000000180371F11  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180371F15  76 05                       jbe     short loc_180371F1C
0000000180371F17  0F 5A C0                    cvtps2pd xmm0, xmm0
0000000180371F1A  EB 03                       jmp     short loc_180371F1F
0000000180371F1C  0F 57 C0                    xorps   xmm0, xmm0
0000000180371F1F  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
0000000180371F23  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180371F27  73 04                       jnb     short loc_180371F2D
0000000180371F29  44 0F 5A E1                 cvtps2pd xmm12, xmm1
0000000180371F2D  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
0000000180371F32  F3 0F 11 83 50 6C 00 00     movss   dword ptr [rbx+6C50h], xmm0
0000000180371F3A  8B 83 D0 6C 00 00           mov     eax, [rbx+6CD0h]
0000000180371F40  89 83 E0 6C 00 00           mov     [rbx+6CE0h], eax
0000000180371F46  F3 0F 10 8B F0 6C 00 00     movss   xmm1, dword ptr [rbx+6CF0h]
0000000180371F4E  F3 0F 11 8B 00 6D 00 00     movss   dword ptr [rbx+6D00h], xmm1
0000000180371F56  F3 0F 10 83 10 6D 00 00     movss   xmm0, dword ptr [rbx+6D10h]
0000000180371F5E  F3 0F 11 83 20 6D 00 00     movss   dword ptr [rbx+6D20h], xmm0
0000000180371F66  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180371F6A  F3 0F 59 8B 30 6D 00 00     mulss   xmm1, dword ptr [rbx+6D30h]
0000000180371F72  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180371F76  F3 0F 11 8B 10 6D 00 00     movss   dword ptr [rbx+6D10h], xmm1
0000000180371F7E  F3 0F 10 8B 10 55 00 00     movss   xmm1, dword ptr [rbx+5510h]
0000000180371F86  F3 0F 10 83 90 55 00 00     movss   xmm0, dword ptr [rbx+5590h]
0000000180371F8E  8B 83 60 6D 00 00           mov     eax, [rbx+6D60h]
0000000180371F94  89 83 70 6D 00 00           mov     [rbx+6D70h], eax
0000000180371F9A  F3 0F 59 83 50 6D 00 00     mulss   xmm0, dword ptr [rbx+6D50h]
0000000180371FA2  F3 0F 59 8B 40 6D 00 00     mulss   xmm1, dword ptr [rbx+6D40h]
0000000180371FAA  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180371FAE  F3 0F 11 83 60 6D 00 00     movss   dword ptr [rbx+6D60h], xmm0
0000000180371FB6  8B 83 80 6D 00 00           mov     eax, [rbx+6D80h]
0000000180371FBC  89 83 A0 6D 00 00           mov     [rbx+6DA0h], eax
0000000180371FC2  F3 0F 10 9B 90 6D 00 00     movss   xmm3, dword ptr [rbx+6D90h]
0000000180371FCA  F3 0F 11 9B B0 6D 00 00     movss   dword ptr [rbx+6DB0h], xmm3
0000000180371FD2  F3 0F 10 8B A0 6D 00 00     movss   xmm1, dword ptr [rbx+6DA0h]
0000000180371FDA  F3 0F 10 93 E0 5C 00 00     movss   xmm2, dword ptr [rbx+5CE0h]
0000000180371FE2  0F 28 C1                    movaps  xmm0, xmm1
0000000180371FE5  F3 0F 59 83 C0 5E 00 00     mulss   xmm0, dword ptr [rbx+5EC0h]
0000000180371FED  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180371FF1  F3 0F 5C C1                 subss   xmm0, xmm1
0000000180371FF5  0F 28 CB                    movaps  xmm1, xmm3
0000000180371FF8  F3 0F 59 8B 10 6C 00 00     mulss   xmm1, dword ptr [rbx+6C10h]
0000000180372000  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180372004  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180372008  F3 0F 5C CB                 subss   xmm1, xmm3
000000018037200C  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180372010  F3 0F 11 8B C0 6D 00 00     movss   dword ptr [rbx+6DC0h], xmm1
0000000180372018  F3 0F 10 9B 20 59 00 00     movss   xmm3, dword ptr [rbx+5920h]
0000000180372020  F3 0F 10 83 D0 6D 00 00     movss   xmm0, dword ptr [rbx+6DD0h]
0000000180372028  F3 0F 11 83 E0 6D 00 00     movss   dword ptr [rbx+6DE0h], xmm0
0000000180372030  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180372034  0F 28 CB                    movaps  xmm1, xmm3
0000000180372037  F3 0F 59 8B F0 6D 00 00     mulss   xmm1, dword ptr [rbx+6DF0h]
000000018037203F  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180372043  F3 0F 10 83 10 6E 00 00     movss   xmm0, dword ptr [rbx+6E10h]
000000018037204B  F3 0F 11 8B D0 6D 00 00     movss   dword ptr [rbx+6DD0h], xmm1
0000000180372053  F3 0F 59 9B 00 6E 00 00     mulss   xmm3, dword ptr [rbx+6E00h]
000000018037205B  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037205F  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180372063  F3 0F 11 9B E0 6D 00 00     movss   dword ptr [rbx+6DE0h], xmm3
000000018037206B  F3 0F 10 83 20 6E 00 00     movss   xmm0, dword ptr [rbx+6E20h]
0000000180372073  F3 0F 10 BB 30 59 00 00     movss   xmm7, dword ptr [rbx+5930h]
000000018037207B  F3 0F 11 83 30 6E 00 00     movss   dword ptr [rbx+6E30h], xmm0
0000000180372083  F3 0F 5C F8                 subss   xmm7, xmm0
0000000180372087  0F 28 CF                    movaps  xmm1, xmm7
000000018037208A  F3 0F 59 8B 40 6E 00 00     mulss   xmm1, dword ptr [rbx+6E40h]
0000000180372092  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180372096  F3 0F 10 83 60 6E 00 00     movss   xmm0, dword ptr [rbx+6E60h]
000000018037209E  F3 0F 11 8B 20 6E 00 00     movss   dword ptr [rbx+6E20h], xmm1
00000001803720A6  F3 0F 59 BB 50 6E 00 00     mulss   xmm7, dword ptr [rbx+6E50h]
00000001803720AE  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803720B2  F3 0F 58 F8                 addss   xmm7, xmm0
00000001803720B6  F3 0F 11 BB 30 6E 00 00     movss   dword ptr [rbx+6E30h], xmm7
00000001803720BE  F3 0F 10 A3 E0 6D 00 00     movss   xmm4, dword ptr [rbx+6DE0h]
00000001803720C6  F3 0F 10 AB C0 6D 00 00     movss   xmm5, dword ptr [rbx+6DC0h]
00000001803720CE  F3 0F 10 B3 60 6D 00 00     movss   xmm6, dword ptr [rbx+6D60h]
00000001803720D6  F3 44 0F 10 8B F0 6B 00 00  movss   xmm9, dword ptr [rbx+6BF0h]
00000001803720DF  8B 83 10 6D 00 00           mov     eax, [rbx+6D10h]
00000001803720E5  89 83 70 6E 00 00           mov     [rbx+6E70h], eax
00000001803720EB  F3 44 0F 11 8B 80 6E 00 00  movss   dword ptr [rbx+6E80h], xmm9
00000001803720F4  F3 0F 10 83 A0 6E 00 00     movss   xmm0, dword ptr [rbx+6EA0h]
00000001803720FC  F3 0F 10 93 B0 6E 00 00     movss   xmm2, dword ptr [rbx+6EB0h]
0000000180372104  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180372108  0F 28 DA                    movaps  xmm3, xmm2
000000018037210B  F3 0F 59 9B 30 6C 00 00     mulss   xmm3, dword ptr [rbx+6C30h]
0000000180372113  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180372117  0F 28 C2                    movaps  xmm0, xmm2
000000018037211A  F3 0F 59 C7                 mulss   xmm0, xmm7
000000018037211E  44 0F 28 C3                 movaps  xmm8, xmm3
0000000180372122  F3 44 0F 5C C0              subss   xmm8, xmm0
0000000180372127  F3 44 0F 58 C7              addss   xmm8, xmm7
000000018037212C  F3 44 0F 59 83 E0 6E 00 00  mulss   xmm8, dword ptr [rbx+6EE0h]
0000000180372135  F3 0F 10 8B C0 6E 00 00     movss   xmm1, dword ptr [rbx+6EC0h]
000000018037213D  F3 0F 58 B3 60 6F 00 00     addss   xmm6, dword ptr [rbx+6F60h]
0000000180372145  F3 44 0F 59 83 F0 6E 00 00  mulss   xmm8, dword ptr [rbx+6EF0h]
000000018037214E  F3 0F 59 AB 00 6F 00 00     mulss   xmm5, dword ptr [rbx+6F00h]
0000000180372156  F3 0F 59 B3 10 6F 00 00     mulss   xmm6, dword ptr [rbx+6F10h]
000000018037215E  F3 44 0F 59 C9              mulss   xmm9, xmm1
0000000180372163  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180372167  F3 0F 58 F5                 addss   xmm6, xmm5
000000018037216B  F3 0F 5C DA                 subss   xmm3, xmm2
000000018037216F  F3 0F 10 93 40 6F 00 00     movss   xmm2, dword ptr [rbx+6F40h]
0000000180372177  0F 28 C2                    movaps  xmm0, xmm2
000000018037217A  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037217E  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180372182  F3 44 0F 5C C8              subss   xmm9, xmm0
0000000180372187  F3 0F 10 83 30 6F 00 00     movss   xmm0, dword ptr [rbx+6F30h]
000000018037218F  F3 0F 58 83 70 6E 00 00     addss   xmm0, dword ptr [rbx+6E70h]
0000000180372197  F3 0F 59 9B D0 6E 00 00     mulss   xmm3, dword ptr [rbx+6ED0h]
000000018037219F  F3 0F 59 83 70 6F 00 00     mulss   xmm0, dword ptr [rbx+6F70h]
00000001803721A7  F3 44 0F 58 CA              addss   xmm9, xmm2
00000001803721AC  F3 44 0F 58 C3              addss   xmm8, xmm3
00000001803721B1  F3 0F 59 83 20 6F 00 00     mulss   xmm0, dword ptr [rbx+6F20h]
00000001803721B9  F3 44 0F 59 8B 50 6F 00 00  mulss   xmm9, dword ptr [rbx+6F50h]
00000001803721C2  F3 44 0F 58 C6              addss   xmm8, xmm6
00000001803721C7  F3 44 0F 58 C8              addss   xmm9, xmm0
00000001803721CC  F3 45 0F 58 C8              addss   xmm9, xmm8
00000001803721D1  F3 44 0F 11 8B 90 6E 00 00  movss   dword ptr [rbx+6E90h], xmm9
00000001803721DA  F3 0F 10 BB 50 6C 00 00     movss   xmm7, dword ptr [rbx+6C50h]
00000001803721E2  F3 44 0F 10 83 E0 6C 00 00  movss   xmm8, dword ptr [rbx+6CE0h]
00000001803721EB  8B 83 B0 6F 00 00           mov     eax, [rbx+6FB0h]
00000001803721F1  89 83 C0 6F 00 00           mov     [rbx+6FC0h], eax
00000001803721F7  F3 0F 10 83 A0 6F 00 00     movss   xmm0, dword ptr [rbx+6FA0h]
00000001803721FF  F3 0F 11 83 B0 6F 00 00     movss   dword ptr [rbx+6FB0h], xmm0
0000000180372207  44 0F 2E AB F0 6F 00 00     ucomiss xmm13, dword ptr [rbx+6FF0h]
000000018037220F  0F 85 7D 02 00 00           jnz     loc_180372492
0000000180372215  F3 0F 10 8B 40 70 00 00     movss   xmm1, dword ptr [rbx+7040h]
000000018037221D  F3 0F 10 B3 C0 6F 00 00     movss   xmm6, dword ptr [rbx+6FC0h]
0000000180372225  0F 28 D1                    movaps  xmm2, xmm1
0000000180372228  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018037222C  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180372230  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180372234  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180372238  F3 0F 58 F2                 addss   xmm6, xmm2
000000018037223C  F3 0F 11 B3 B0 6F 00 00     movss   dword ptr [rbx+6FB0h], xmm6
0000000180372244  F3 0F 59 B3 30 70 00 00     mulss   xmm6, dword ptr [rbx+7030h]
000000018037224C  F3 0F 58 B3 D0 6F 00 00     addss   xmm6, dword ptr [rbx+6FD0h]
0000000180372254  E8 07 6B FF FF              call    sub_180368D60
0000000180372259  F3 0F 11 83 A0 6F 00 00     movss   dword ptr [rbx+6FA0h], xmm0
0000000180372261  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180372265  F3 0F 59 8B 90 70 00 00     mulss   xmm1, dword ptr [rbx+7090h]
000000018037226D  41 0F 28 D5                 movaps  xmm2, xmm13
0000000180372271  F3 41 0F 5C D0              subss   xmm2, xmm8
0000000180372276  F3 0F 58 8B E0 6F 00 00     addss   xmm1, dword ptr [rbx+6FE0h]
000000018037227E  F3 0F 59 93 50 70 00 00     mulss   xmm2, dword ptr [rbx+7050h]
0000000180372286  F3 0F 11 8B 90 6F 00 00     movss   dword ptr [rbx+6F90h], xmm1
000000018037228E  F3 0F 59 BB 00 70 00 00     mulss   xmm7, dword ptr [rbx+7000h]
0000000180372296  F3 44 0F 59 8B 20 70 00 00  mulss   xmm9, dword ptr [rbx+7020h]
000000018037229F  F3 0F 10 83 60 70 00 00     movss   xmm0, dword ptr [rbx+7060h]
00000001803722A7  F3 0F 5D C2                 minss   xmm0, xmm2
00000001803722AB  F3 41 0F 58 F9              addss   xmm7, xmm9
00000001803722B0  F3 0F 58 FE                 addss   xmm7, xmm6
00000001803722B4  F3 0F 58 F8                 addss   xmm7, xmm0
00000001803722B8  F3 0F 58 BB 10 70 00 00     addss   xmm7, dword ptr [rbx+7010h]
00000001803722C0  F3 0F 5D BB 70 70 00 00     minss   xmm7, dword ptr [rbx+7070h]
00000001803722C8  F3 0F 5F BB 80 70 00 00     maxss   xmm7, dword ptr [rbx+7080h]
00000001803722D0  F3 0F 59 BB B0 70 00 00     mulss   xmm7, dword ptr [rbx+70B0h]
00000001803722D8  F3 0F 58 BB C0 70 00 00     addss   xmm7, dword ptr [rbx+70C0h]
00000001803722E0  0F 28 CF                    movaps  xmm1, xmm7
00000001803722E3  F3 0F 2C C9                 cvttss2si ecx, xmm1
00000001803722E7  81 F9 00 00 00 80           cmp     ecx, 80000000h
00000001803722ED  74 1E                       jz      short loc_18037230D
00000001803722EF  66 0F 6E C1                 movd    xmm0, ecx
00000001803722F3  0F 5B C0                    cvtdq2ps xmm0, xmm0
00000001803722F6  0F 2E C1                    ucomiss xmm0, xmm1
00000001803722F9  74 12                       jz      short loc_18037230D
00000001803722FB  0F 14 C9                    unpcklps xmm1, xmm1
00000001803722FE  0F 50 C1                    movmskps eax, xmm1
0000000180372301  83 E0 01                    and     eax, 1
0000000180372304  2B C8                       sub     ecx, eax
0000000180372306  66 0F 6E C9                 movd    xmm1, ecx
000000018037230A  0F 5B C9                    cvtdq2ps xmm1, xmm1
000000018037230D  F3 0F 5C F9                 subss   xmm7, xmm1
0000000180372311  0F 28 C1                    movaps  xmm0, xmm1; X
0000000180372314  0F 28 F7                    movaps  xmm6, xmm7
0000000180372317  F3 0F 59 F7                 mulss   xmm6, xmm7
000000018037231B  F3 0F 59 35 AD 2C 77 00     mulss   xmm6, cs:dword_180AE4FD0
0000000180372323  E8 18 D4 37 00              call    expf
0000000180372328  0F 28 E0                    movaps  xmm4, xmm0
000000018037232B  0F 28 D7                    movaps  xmm2, xmm7
000000018037232E  F3 0F 59 93 80 71 00 00     mulss   xmm2, dword ptr [rbx+7180h]
0000000180372336  0F 28 CF                    movaps  xmm1, xmm7
0000000180372339  F3 0F 59 8B 60 71 00 00     mulss   xmm1, dword ptr [rbx+7160h]
0000000180372341  0F 28 C7                    movaps  xmm0, xmm7
0000000180372344  F3 0F 58 93 70 71 00 00     addss   xmm2, dword ptr [rbx+7170h]
000000018037234C  F3 0F 59 83 40 71 00 00     mulss   xmm0, dword ptr [rbx+7140h]
0000000180372354  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180372358  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037235C  F3 0F 58 93 50 71 00 00     addss   xmm2, dword ptr [rbx+7150h]
0000000180372364  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180372368  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037236C  0F 28 C7                    movaps  xmm0, xmm7
000000018037236F  F3 0F 59 83 20 71 00 00     mulss   xmm0, dword ptr [rbx+7120h]
0000000180372377  F3 0F 58 93 30 71 00 00     addss   xmm2, dword ptr [rbx+7130h]
000000018037237F  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180372383  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180372387  0F 28 C7                    movaps  xmm0, xmm7
000000018037238A  F3 0F 59 83 00 71 00 00     mulss   xmm0, dword ptr [rbx+7100h]
0000000180372392  F3 0F 59 BB E0 70 00 00     mulss   xmm7, dword ptr [rbx+70E0h]
000000018037239A  F3 0F 58 93 10 71 00 00     addss   xmm2, dword ptr [rbx+7110h]
00000001803723A2  F3 0F 59 D6                 mulss   xmm2, xmm6
00000001803723A6  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803723AA  F3 0F 58 93 F0 70 00 00     addss   xmm2, dword ptr [rbx+70F0h]
00000001803723B2  F3 0F 59 D6                 mulss   xmm2, xmm6
00000001803723B6  F3 0F 58 D7                 addss   xmm2, xmm7
00000001803723BA  F3 41 0F 58 D5              addss   xmm2, xmm13
00000001803723BF  F3 0F 59 E2                 mulss   xmm4, xmm2
00000001803723C3  F3 0F 59 A3 D0 70 00 00     mulss   xmm4, dword ptr [rbx+70D0h]
00000001803723CB  0F 28 DC                    movaps  xmm3, xmm4
00000001803723CE  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803723D2  0F 28 CB                    movaps  xmm1, xmm3
00000001803723D5  44 0F 28 C3                 movaps  xmm8, xmm3
00000001803723D9  F3 44 0F 59 83 20 72 00 00  mulss   xmm8, dword ptr [rbx+7220h]
00000001803723E2  0F 28 C3                    movaps  xmm0, xmm3
00000001803723E5  F3 0F 59 83 E0 71 00 00     mulss   xmm0, dword ptr [rbx+71E0h]
00000001803723ED  0F 28 D3                    movaps  xmm2, xmm3
00000001803723F0  F3 44 0F 58 83 00 72 00 00  addss   xmm8, dword ptr [rbx+7200h]
00000001803723F9  F3 0F 59 CC                 mulss   xmm1, xmm4
00000001803723FD  F3 0F 58 83 C0 71 00 00     addss   xmm0, dword ptr [rbx+71C0h]
0000000180372405  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180372409  F3 44 0F 59 C2              mulss   xmm8, xmm2
000000018037240E  F3 44 0F 58 C0              addss   xmm8, xmm0
0000000180372413  0F 28 C1                    movaps  xmm0, xmm1
0000000180372416  F3 0F 59 8B A0 71 00 00     mulss   xmm1, dword ptr [rbx+71A0h]
000000018037241E  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180372422  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180372427  0F 28 C3                    movaps  xmm0, xmm3
000000018037242A  F3 0F 59 83 D0 71 00 00     mulss   xmm0, dword ptr [rbx+71D0h]
0000000180372432  F3 44 0F 58 C1              addss   xmm8, xmm1
0000000180372437  0F 28 CB                    movaps  xmm1, xmm3
000000018037243A  F3 0F 59 8B 10 72 00 00     mulss   xmm1, dword ptr [rbx+7210h]
0000000180372442  F3 0F 59 9B 90 71 00 00     mulss   xmm3, dword ptr [rbx+7190h]
000000018037244A  F3 0F 58 8B F0 71 00 00     addss   xmm1, dword ptr [rbx+71F0h]
0000000180372452  F3 44 0F 58 C4              addss   xmm8, xmm4
0000000180372457  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018037245B  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037245F  F3 0F 58 8B B0 71 00 00     addss   xmm1, dword ptr [rbx+71B0h]
0000000180372467  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018037246B  F3 0F 58 CB                 addss   xmm1, xmm3
000000018037246F  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180372474  F3 44 0F 5E C1              divss   xmm8, xmm1
0000000180372479  41 0F 28 C0                 movaps  xmm0, xmm8
000000018037247D  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180372482  F3 44 0F 5E C0              divss   xmm8, xmm0
0000000180372487  F3 44 0F 11 83 80 6F 00 00  movss   dword ptr [rbx+6F80h], xmm8
0000000180372490  EB 09                       jmp     short loc_18037249B
0000000180372492  F3 44 0F 10 83 80 6F 00 00  movss   xmm8, dword ptr [rbx+6F80h]
000000018037249B  8B 83 90 72 00 00           mov     eax, [rbx+7290h]
00000001803724A1  F3 0F 10 8B B0 6B 00 00     movss   xmm1, dword ptr [rbx+6BB0h]
00000001803724A9  F3 44 0F 10 8B 90 6F 00 00  movss   xmm9, dword ptr [rbx+6F90h]
00000001803724B2  89 83 A0 72 00 00           mov     [rbx+72A0h], eax
00000001803724B8  8B 83 80 72 00 00           mov     eax, [rbx+7280h]
00000001803724BE  89 83 90 72 00 00           mov     [rbx+7290h], eax
00000001803724C4  8B 83 70 72 00 00           mov     eax, [rbx+7270h]
00000001803724CA  89 83 80 72 00 00           mov     [rbx+7280h], eax
00000001803724D0  8B 83 60 72 00 00           mov     eax, [rbx+7260h]
00000001803724D6  89 83 70 72 00 00           mov     [rbx+7270h], eax
00000001803724DC  8B 83 50 72 00 00           mov     eax, [rbx+7250h]
00000001803724E2  89 83 60 72 00 00           mov     [rbx+7260h], eax
00000001803724E8  8B 83 40 72 00 00           mov     eax, [rbx+7240h]
00000001803724EE  89 83 50 72 00 00           mov     [rbx+7250h], eax
00000001803724F4  8B 83 30 72 00 00           mov     eax, [rbx+7230h]
00000001803724FA  89 83 40 72 00 00           mov     [rbx+7240h], eax
0000000180372500  8B 83 70 73 00 00           mov     eax, [rbx+7370h]
0000000180372506  89 83 80 73 00 00           mov     [rbx+7380h], eax
000000018037250C  8B 83 60 73 00 00           mov     eax, [rbx+7360h]
0000000180372512  89 83 70 73 00 00           mov     [rbx+7370h], eax
0000000180372518  8B 83 50 73 00 00           mov     eax, [rbx+7350h]
000000018037251E  89 83 60 73 00 00           mov     [rbx+7360h], eax
0000000180372524  8B 83 40 73 00 00           mov     eax, [rbx+7340h]
000000018037252A  89 83 50 73 00 00           mov     [rbx+7350h], eax
0000000180372530  8B 83 30 73 00 00           mov     eax, [rbx+7330h]
0000000180372536  89 83 40 73 00 00           mov     [rbx+7340h], eax
000000018037253C  8B 83 20 73 00 00           mov     eax, [rbx+7320h]
0000000180372542  89 83 30 73 00 00           mov     [rbx+7330h], eax
0000000180372548  8B 83 10 73 00 00           mov     eax, [rbx+7310h]
000000018037254E  89 83 20 73 00 00           mov     [rbx+7320h], eax
0000000180372554  8B 83 F0 73 00 00           mov     eax, [rbx+73F0h]
000000018037255A  89 83 00 74 00 00           mov     [rbx+7400h], eax
0000000180372560  8B 83 E0 73 00 00           mov     eax, [rbx+73E0h]
0000000180372566  89 83 F0 73 00 00           mov     [rbx+73F0h], eax
000000018037256C  8B 83 D0 73 00 00           mov     eax, [rbx+73D0h]
0000000180372572  89 83 E0 73 00 00           mov     [rbx+73E0h], eax
0000000180372578  8B 83 C0 73 00 00           mov     eax, [rbx+73C0h]
000000018037257E  89 83 D0 73 00 00           mov     [rbx+73D0h], eax
0000000180372584  8B 83 B0 73 00 00           mov     eax, [rbx+73B0h]
000000018037258A  89 83 C0 73 00 00           mov     [rbx+73C0h], eax
0000000180372590  8B 83 A0 73 00 00           mov     eax, [rbx+73A0h]
0000000180372596  89 83 B0 73 00 00           mov     [rbx+73B0h], eax
000000018037259C  8B 83 90 73 00 00           mov     eax, [rbx+7390h]
00000001803725A2  89 83 A0 73 00 00           mov     [rbx+73A0h], eax
00000001803725A8  8B 83 70 74 00 00           mov     eax, [rbx+7470h]
00000001803725AE  89 83 80 74 00 00           mov     [rbx+7480h], eax
00000001803725B4  8B 83 60 74 00 00           mov     eax, [rbx+7460h]
00000001803725BA  89 83 70 74 00 00           mov     [rbx+7470h], eax
00000001803725C0  8B 83 50 74 00 00           mov     eax, [rbx+7450h]
00000001803725C6  89 83 60 74 00 00           mov     [rbx+7460h], eax
00000001803725CC  8B 83 40 74 00 00           mov     eax, [rbx+7440h]
00000001803725D2  89 83 50 74 00 00           mov     [rbx+7450h], eax
00000001803725D8  8B 83 30 74 00 00           mov     eax, [rbx+7430h]
00000001803725DE  89 83 40 74 00 00           mov     [rbx+7440h], eax
00000001803725E4  8B 83 20 74 00 00           mov     eax, [rbx+7420h]
00000001803725EA  89 83 30 74 00 00           mov     [rbx+7430h], eax
00000001803725F0  8B 83 10 74 00 00           mov     eax, [rbx+7410h]
00000001803725F6  89 83 20 74 00 00           mov     [rbx+7420h], eax
00000001803725FC  8B 83 F0 74 00 00           mov     eax, [rbx+74F0h]
0000000180372602  89 83 00 75 00 00           mov     [rbx+7500h], eax
0000000180372608  8B 83 E0 74 00 00           mov     eax, [rbx+74E0h]
000000018037260E  89 83 F0 74 00 00           mov     [rbx+74F0h], eax
0000000180372614  8B 83 D0 74 00 00           mov     eax, [rbx+74D0h]
000000018037261A  89 83 E0 74 00 00           mov     [rbx+74E0h], eax
0000000180372620  8B 83 C0 74 00 00           mov     eax, [rbx+74C0h]
0000000180372626  89 83 D0 74 00 00           mov     [rbx+74D0h], eax
000000018037262C  8B 83 B0 74 00 00           mov     eax, [rbx+74B0h]
0000000180372632  89 83 C0 74 00 00           mov     [rbx+74C0h], eax
0000000180372638  8B 83 A0 74 00 00           mov     eax, [rbx+74A0h]
000000018037263E  89 83 B0 74 00 00           mov     [rbx+74B0h], eax
0000000180372644  8B 83 90 74 00 00           mov     eax, [rbx+7490h]
000000018037264A  89 83 A0 74 00 00           mov     [rbx+74A0h], eax
0000000180372650  8B 83 10 75 00 00           mov     eax, [rbx+7510h]
0000000180372656  89 83 20 75 00 00           mov     [rbx+7520h], eax
000000018037265C  F3 0F 10 83 30 75 00 00     movss   xmm0, dword ptr [rbx+7530h]
0000000180372664  F3 0F 11 83 40 75 00 00     movss   dword ptr [rbx+7540h], xmm0
000000018037266C  44 0F 2E AB 80 75 00 00     ucomiss xmm13, dword ptr [rbx+7580h]
0000000180372674  0F 85 49 09 00 00           jnz     loc_180372FC3
000000018037267A  F3 0F 59 8B D0 75 00 00     mulss   xmm1, dword ptr [rbx+75D0h]
0000000180372682  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180372686  41 0F 28 F1                 movaps  xmm6, xmm9
000000018037268A  41 0F 28 F8                 movaps  xmm7, xmm8
000000018037268E  F3 0F 59 B3 F0 75 00 00     mulss   xmm6, dword ptr [rbx+75F0h]
0000000180372696  F3 41 0F 59 F8              mulss   xmm7, xmm8
000000018037269B  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803726A0  F3 0F 59 F1                 mulss   xmm6, xmm1
00000001803726A4  0F 28 C8                    movaps  xmm1, xmm0
00000001803726A7  F3 0F 59 8B C0 75 00 00     mulss   xmm1, dword ptr [rbx+75C0h]
00000001803726AF  F3 0F 58 F1                 addss   xmm6, xmm1
00000001803726B3  E8 A8 66 FF FF              call    sub_180368D60
00000001803726B8  F3 0F 11 83 30 75 00 00     movss   dword ptr [rbx+7530h], xmm0
00000001803726C0  41 0F 28 DD                 movaps  xmm3, xmm13
00000001803726C4  F3 0F 11 B3 10 75 00 00     movss   dword ptr [rbx+7510h], xmm6
00000001803726CC  41 0F 28 C0                 movaps  xmm0, xmm8
00000001803726D0  F3 0F 59 FF                 mulss   xmm7, xmm7
00000001803726D4  F3 41 0F 58 C0              addss   xmm0, xmm8
00000001803726D9  41 0F 28 F5                 movaps  xmm6, xmm13
00000001803726DD  F3 41 0F 59 F9              mulss   xmm7, xmm9
00000001803726E2  F3 0F 5C F0                 subss   xmm6, xmm0
00000001803726E6  F3 41 0F 58 FD              addss   xmm7, xmm13
00000001803726EB  F3 0F 5E DF                 divss   xmm3, xmm7
00000001803726EF  F3 0F 11 9B 60 75 00 00     movss   dword ptr [rbx+7560h], xmm3
00000001803726F7  0F 28 E3                    movaps  xmm4, xmm3
00000001803726FA  F3 0F 10 8B 10 75 00 00     movss   xmm1, dword ptr [rbx+7510h]
0000000180372702  F3 0F 10 AB 20 75 00 00     movss   xmm5, dword ptr [rbx+7520h]
000000018037270A  F3 41 0F 59 E1              mulss   xmm4, xmm9
000000018037270F  F3 0F 11 A3 50 75 00 00     movss   dword ptr [rbx+7550h], xmm4
0000000180372717  F3 0F 59 AB 20 76 00 00     mulss   xmm5, dword ptr [rbx+7620h]
000000018037271F  F3 0F 10 93 90 72 00 00     movss   xmm2, dword ptr [rbx+7290h]
0000000180372727  F3 0F 59 8B 30 76 00 00     mulss   xmm1, dword ptr [rbx+7630h]
000000018037272F  F3 0F 10 83 A0 72 00 00     movss   xmm0, dword ptr [rbx+72A0h]
0000000180372737  F3 0F 11 93 00 73 00 00     movss   dword ptr [rbx+7300h], xmm2
000000018037273F  F3 0F 59 93 50 77 00 00     mulss   xmm2, dword ptr [rbx+7750h]
0000000180372747  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037274B  F3 0F 59 83 60 77 00 00     mulss   xmm0, dword ptr [rbx+7760h]
0000000180372753  F3 0F 59 EB                 mulss   xmm5, xmm3
0000000180372757  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037275B  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037275F  F3 0F 5C EA                 subss   xmm5, xmm2
0000000180372763  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180372767  73 06                       jnb     short loc_18037276F
0000000180372769  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037276D  EB 05                       jmp     short loc_180372774
000000018037276F  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180372774  0F 28 CD                    movaps  xmm1, xmm5
0000000180372777  0F 28 C5                    movaps  xmm0, xmm5
000000018037277A  F3 0F 59 83 00 76 00 00     mulss   xmm0, dword ptr [rbx+7600h]
0000000180372782  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180372786  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037278A  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037278E  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180372792  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180372796  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037279A  F3 0F 11 AB B0 72 00 00     movss   dword ptr [rbx+72B0h], xmm5
00000001803727A2  0F 28 D5                    movaps  xmm2, xmm5
00000001803727A5  F3 0F 58 AB 40 72 00 00     addss   xmm5, dword ptr [rbx+7240h]
00000001803727AD  F3 0F 10 9B 50 72 00 00     movss   xmm3, dword ptr [rbx+7250h]
00000001803727B5  0F 28 C3                    movaps  xmm0, xmm3
00000001803727B8  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803727BC  F3 0F 59 E5                 mulss   xmm4, xmm5
00000001803727C0  41 0F 28 E8                 movaps  xmm5, xmm8
00000001803727C4  F3 0F 59 EA                 mulss   xmm5, xmm2
00000001803727C8  41 0F 28 D0                 movaps  xmm2, xmm8
00000001803727CC  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803727D0  0F 28 C6                    movaps  xmm0, xmm6
00000001803727D3  F3 0F 11 A3 C0 72 00 00     movss   dword ptr [rbx+72C0h], xmm4
00000001803727DB  F3 0F 10 8B 60 72 00 00     movss   xmm1, dword ptr [rbx+7260h]
00000001803727E3  F3 0F 59 C4                 mulss   xmm0, xmm4
00000001803727E7  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803727EB  0F 28 C1                    movaps  xmm0, xmm1
00000001803727EE  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803727F2  F3 0F 58 EC                 addss   xmm5, xmm4
00000001803727F6  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803727FA  41 0F 28 D8                 movaps  xmm3, xmm8
00000001803727FE  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180372802  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180372806  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037280A  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037280E  0F 28 C6                    movaps  xmm0, xmm6
0000000180372811  F3 0F 11 9B D0 72 00 00     movss   dword ptr [rbx+72D0h], xmm3
0000000180372819  F3 0F 10 AB 70 72 00 00     movss   xmm5, dword ptr [rbx+7270h]
0000000180372821  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180372825  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372829  0F 28 C5                    movaps  xmm0, xmm5
000000018037282C  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180372830  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180372834  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180372838  41 0F 28 C8                 movaps  xmm1, xmm8
000000018037283C  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180372840  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180372844  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180372848  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037284C  0F 28 C6                    movaps  xmm0, xmm6
000000018037284F  F3 0F 11 93 E0 72 00 00     movss   dword ptr [rbx+72E0h], xmm2
0000000180372857  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037285B  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037285F  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180372863  F3 41 0F 59 E8              mulss   xmm5, xmm8
0000000180372868  0F 28 C6                    movaps  xmm0, xmm6
000000018037286B  F3 0F 59 83 80 72 00 00     mulss   xmm0, dword ptr [rbx+7280h]
0000000180372873  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180372877  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037287B  0F 28 C6                    movaps  xmm0, xmm6
000000018037287E  F3 0F 59 E1                 mulss   xmm4, xmm1
0000000180372882  F3 0F 11 AB F0 72 00 00     movss   dword ptr [rbx+72F0h], xmm5
000000018037288A  F3 0F 10 93 E0 72 00 00     movss   xmm2, dword ptr [rbx+72E0h]
0000000180372892  F3 0F 59 93 A0 75 00 00     mulss   xmm2, dword ptr [rbx+75A0h]
000000018037289A  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037289E  F3 0F 59 AB B0 75 00 00     mulss   xmm5, dword ptr [rbx+75B0h]
00000001803728A6  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803728AA  F3 0F 10 83 90 75 00 00     movss   xmm0, dword ptr [rbx+7590h]
00000001803728B2  F3 0F 59 83 D0 72 00 00     mulss   xmm0, dword ptr [rbx+72D0h]
00000001803728BA  F3 0F 58 D5                 addss   xmm2, xmm5
00000001803728BE  F3 0F 10 AB 20 75 00 00     movss   xmm5, dword ptr [rbx+7520h]
00000001803728C6  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803728CA  F3 0F 11 93 90 74 00 00     movss   dword ptr [rbx+7490h], xmm2
00000001803728D2  F3 0F 58 AB 10 75 00 00     addss   xmm5, dword ptr [rbx+7510h]
00000001803728DA  F3 0F 10 83 00 73 00 00     movss   xmm0, dword ptr [rbx+7300h]
00000001803728E2  F3 0F 59 AB 40 76 00 00     mulss   xmm5, dword ptr [rbx+7640h]
00000001803728EA  F3 0F 59 AB 60 75 00 00     mulss   xmm5, dword ptr [rbx+7560h]
00000001803728F2  F3 0F 11 A3 00 73 00 00     movss   dword ptr [rbx+7300h], xmm4
00000001803728FA  F3 0F 59 A3 50 77 00 00     mulss   xmm4, dword ptr [rbx+7750h]
0000000180372902  F3 0F 59 83 60 77 00 00     mulss   xmm0, dword ptr [rbx+7760h]
000000018037290A  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037290E  F3 0F 59 A3 50 75 00 00     mulss   xmm4, dword ptr [rbx+7550h]
0000000180372916  F3 0F 5C EC                 subss   xmm5, xmm4
000000018037291A  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037291E  73 06                       jnb     short loc_180372926
0000000180372920  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180372924  EB 05                       jmp     short loc_18037292B
0000000180372926  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037292B  0F 28 CD                    movaps  xmm1, xmm5
000000018037292E  0F 28 C5                    movaps  xmm0, xmm5
0000000180372931  F3 0F 59 83 00 76 00 00     mulss   xmm0, dword ptr [rbx+7600h]
0000000180372939  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037293D  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180372941  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180372945  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180372949  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037294D  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180372951  F3 0F 10 8B B0 72 00 00     movss   xmm1, dword ptr [rbx+72B0h]
0000000180372959  F3 0F 11 AB B0 72 00 00     movss   dword ptr [rbx+72B0h], xmm5
0000000180372961  0F 28 D5                    movaps  xmm2, xmm5
0000000180372964  F3 0F 10 9B C0 72 00 00     movss   xmm3, dword ptr [rbx+72C0h]
000000018037296C  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180372970  0F 28 C3                    movaps  xmm0, xmm3
0000000180372973  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180372977  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037297B  41 0F 28 E8                 movaps  xmm5, xmm8
000000018037297F  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180372983  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180372987  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037298B  0F 28 C6                    movaps  xmm0, xmm6
000000018037298E  F3 0F 11 A3 C0 72 00 00     movss   dword ptr [rbx+72C0h], xmm4
0000000180372996  F3 0F 10 8B D0 72 00 00     movss   xmm1, dword ptr [rbx+72D0h]
000000018037299E  F3 0F 59 C4                 mulss   xmm0, xmm4
00000001803729A2  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803729A6  0F 28 C1                    movaps  xmm0, xmm1
00000001803729A9  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803729AD  F3 0F 58 EC                 addss   xmm5, xmm4
00000001803729B1  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803729B5  41 0F 28 D8                 movaps  xmm3, xmm8
00000001803729B9  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803729BD  41 0F 28 E0                 movaps  xmm4, xmm8
00000001803729C1  F3 0F 59 E5                 mulss   xmm4, xmm5
00000001803729C5  F3 0F 58 D8                 addss   xmm3, xmm0
00000001803729C9  0F 28 C6                    movaps  xmm0, xmm6
00000001803729CC  F3 0F 11 9B D0 72 00 00     movss   dword ptr [rbx+72D0h], xmm3
00000001803729D4  F3 0F 10 AB E0 72 00 00     movss   xmm5, dword ptr [rbx+72E0h]
00000001803729DC  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803729E0  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803729E4  0F 28 C5                    movaps  xmm0, xmm5
00000001803729E7  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803729EB  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803729EF  F3 0F 58 D9                 addss   xmm3, xmm1
00000001803729F3  41 0F 28 C8                 movaps  xmm1, xmm8
00000001803729F7  F3 0F 59 CC                 mulss   xmm1, xmm4
00000001803729FB  41 0F 28 E0                 movaps  xmm4, xmm8
00000001803729FF  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180372A03  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180372A07  0F 28 C6                    movaps  xmm0, xmm6
0000000180372A0A  F3 0F 11 93 E0 72 00 00     movss   dword ptr [rbx+72E0h], xmm2
0000000180372A12  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180372A16  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180372A1A  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180372A1E  F3 41 0F 59 E8              mulss   xmm5, xmm8
0000000180372A23  0F 28 C6                    movaps  xmm0, xmm6
0000000180372A26  F3 0F 59 83 F0 72 00 00     mulss   xmm0, dword ptr [rbx+72F0h]
0000000180372A2E  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180372A32  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180372A36  0F 28 C6                    movaps  xmm0, xmm6
0000000180372A39  F3 0F 59 E1                 mulss   xmm4, xmm1
0000000180372A3D  F3 0F 11 AB F0 72 00 00     movss   dword ptr [rbx+72F0h], xmm5
0000000180372A45  F3 0F 10 93 E0 72 00 00     movss   xmm2, dword ptr [rbx+72E0h]
0000000180372A4D  F3 0F 59 93 A0 75 00 00     mulss   xmm2, dword ptr [rbx+75A0h]
0000000180372A55  F3 0F 10 8B 10 75 00 00     movss   xmm1, dword ptr [rbx+7510h]
0000000180372A5D  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180372A61  F3 0F 59 AB B0 75 00 00     mulss   xmm5, dword ptr [rbx+75B0h]
0000000180372A69  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372A6D  F3 0F 10 83 90 75 00 00     movss   xmm0, dword ptr [rbx+7590h]
0000000180372A75  F3 0F 59 83 D0 72 00 00     mulss   xmm0, dword ptr [rbx+72D0h]
0000000180372A7D  F3 0F 58 D5                 addss   xmm2, xmm5
0000000180372A81  F3 0F 10 AB 20 75 00 00     movss   xmm5, dword ptr [rbx+7520h]
0000000180372A89  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180372A8D  F3 0F 11 93 10 74 00 00     movss   dword ptr [rbx+7410h], xmm2
0000000180372A95  F3 0F 59 AB 30 76 00 00     mulss   xmm5, dword ptr [rbx+7630h]
0000000180372A9D  F3 0F 59 8B 20 76 00 00     mulss   xmm1, dword ptr [rbx+7620h]
0000000180372AA5  F3 0F 10 83 00 73 00 00     movss   xmm0, dword ptr [rbx+7300h]
0000000180372AAD  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180372AB1  F3 0F 59 AB 60 75 00 00     mulss   xmm5, dword ptr [rbx+7560h]
0000000180372AB9  F3 0F 11 A3 00 73 00 00     movss   dword ptr [rbx+7300h], xmm4
0000000180372AC1  F3 0F 59 A3 50 77 00 00     mulss   xmm4, dword ptr [rbx+7750h]
0000000180372AC9  F3 0F 59 83 60 77 00 00     mulss   xmm0, dword ptr [rbx+7760h]
0000000180372AD1  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372AD5  F3 0F 59 A3 50 75 00 00     mulss   xmm4, dword ptr [rbx+7550h]
0000000180372ADD  F3 0F 5C EC                 subss   xmm5, xmm4
0000000180372AE1  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180372AE5  73 06                       jnb     short loc_180372AED
0000000180372AE7  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180372AEB  EB 05                       jmp     short loc_180372AF2
0000000180372AED  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180372AF2  0F 28 CD                    movaps  xmm1, xmm5
0000000180372AF5  0F 28 C5                    movaps  xmm0, xmm5
0000000180372AF8  F3 0F 59 83 00 76 00 00     mulss   xmm0, dword ptr [rbx+7600h]
0000000180372B00  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180372B04  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180372B08  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180372B0C  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180372B10  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180372B14  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180372B18  F3 0F 10 8B B0 72 00 00     movss   xmm1, dword ptr [rbx+72B0h]
0000000180372B20  F3 0F 11 AB B0 72 00 00     movss   dword ptr [rbx+72B0h], xmm5
0000000180372B28  0F 28 D5                    movaps  xmm2, xmm5
0000000180372B2B  F3 0F 10 9B C0 72 00 00     movss   xmm3, dword ptr [rbx+72C0h]
0000000180372B33  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180372B37  0F 28 C3                    movaps  xmm0, xmm3
0000000180372B3A  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180372B3E  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180372B42  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180372B46  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180372B4A  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180372B4E  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372B52  0F 28 C6                    movaps  xmm0, xmm6
0000000180372B55  F3 0F 11 A3 C0 72 00 00     movss   dword ptr [rbx+72C0h], xmm4
0000000180372B5D  F3 0F 10 8B D0 72 00 00     movss   xmm1, dword ptr [rbx+72D0h]
0000000180372B65  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180372B69  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180372B6D  0F 28 C1                    movaps  xmm0, xmm1
0000000180372B70  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180372B74  F3 0F 58 EC                 addss   xmm5, xmm4
0000000180372B78  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180372B7C  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180372B80  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180372B84  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180372B88  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180372B8C  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180372B90  0F 28 C6                    movaps  xmm0, xmm6
0000000180372B93  F3 0F 11 9B D0 72 00 00     movss   dword ptr [rbx+72D0h], xmm3
0000000180372B9B  F3 0F 10 AB E0 72 00 00     movss   xmm5, dword ptr [rbx+72E0h]
0000000180372BA3  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180372BA7  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372BAB  0F 28 C5                    movaps  xmm0, xmm5
0000000180372BAE  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180372BB2  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180372BB6  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180372BBA  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180372BBE  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180372BC2  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180372BC6  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180372BCA  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180372BCE  0F 28 C6                    movaps  xmm0, xmm6
0000000180372BD1  F3 0F 11 93 E0 72 00 00     movss   dword ptr [rbx+72E0h], xmm2
0000000180372BD9  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180372BDD  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180372BE1  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180372BE5  F3 41 0F 59 E8              mulss   xmm5, xmm8
0000000180372BEA  0F 28 C6                    movaps  xmm0, xmm6
0000000180372BED  F3 0F 59 83 F0 72 00 00     mulss   xmm0, dword ptr [rbx+72F0h]
0000000180372BF5  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180372BF9  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180372BFD  0F 28 C6                    movaps  xmm0, xmm6
0000000180372C00  F3 0F 59 D9                 mulss   xmm3, xmm1
0000000180372C04  F3 0F 11 AB F0 72 00 00     movss   dword ptr [rbx+72F0h], xmm5
0000000180372C0C  F3 0F 10 8B E0 72 00 00     movss   xmm1, dword ptr [rbx+72E0h]
0000000180372C14  F3 0F 59 8B A0 75 00 00     mulss   xmm1, dword ptr [rbx+75A0h]
0000000180372C1C  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180372C20  F3 0F 59 AB B0 75 00 00     mulss   xmm5, dword ptr [rbx+75B0h]
0000000180372C28  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180372C2C  F3 0F 10 83 90 75 00 00     movss   xmm0, dword ptr [rbx+7590h]
0000000180372C34  F3 0F 59 83 D0 72 00 00     mulss   xmm0, dword ptr [rbx+72D0h]
0000000180372C3C  F3 0F 58 CD                 addss   xmm1, xmm5
0000000180372C40  F3 0F 10 AB 10 75 00 00     movss   xmm5, dword ptr [rbx+7510h]
0000000180372C48  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180372C4C  F3 0F 11 8B 90 73 00 00     movss   dword ptr [rbx+7390h], xmm1
0000000180372C54  F3 0F 59 AB 10 76 00 00     mulss   xmm5, dword ptr [rbx+7610h]
0000000180372C5C  F3 0F 10 83 00 73 00 00     movss   xmm0, dword ptr [rbx+7300h]
0000000180372C64  F3 0F 59 AB 60 75 00 00     mulss   xmm5, dword ptr [rbx+7560h]
0000000180372C6C  F3 0F 11 9B 90 72 00 00     movss   dword ptr [rbx+7290h], xmm3
0000000180372C74  F3 0F 59 9B 50 77 00 00     mulss   xmm3, dword ptr [rbx+7750h]
0000000180372C7C  F3 0F 59 83 60 77 00 00     mulss   xmm0, dword ptr [rbx+7760h]
0000000180372C84  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180372C88  F3 0F 59 9B 50 75 00 00     mulss   xmm3, dword ptr [rbx+7550h]
0000000180372C90  F3 0F 5C EB                 subss   xmm5, xmm3
0000000180372C94  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180372C98  73 06                       jnb     short loc_180372CA0
0000000180372C9A  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180372C9E  EB 05                       jmp     short loc_180372CA5
0000000180372CA0  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180372CA5  0F 28 CD                    movaps  xmm1, xmm5
0000000180372CA8  0F 28 C5                    movaps  xmm0, xmm5
0000000180372CAB  F3 0F 59 83 00 76 00 00     mulss   xmm0, dword ptr [rbx+7600h]
0000000180372CB3  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180372CB7  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180372CBB  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180372CBF  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180372CC3  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180372CC7  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180372CCB  F3 0F 11 AB 30 72 00 00     movss   dword ptr [rbx+7230h], xmm5
0000000180372CD3  0F 28 D5                    movaps  xmm2, xmm5
0000000180372CD6  F3 0F 58 AB B0 72 00 00     addss   xmm5, dword ptr [rbx+72B0h]
0000000180372CDE  F3 0F 10 9B C0 72 00 00     movss   xmm3, dword ptr [rbx+72C0h]
0000000180372CE6  0F 28 C3                    movaps  xmm0, xmm3
0000000180372CE9  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180372CED  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180372CF1  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180372CF5  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180372CF9  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180372CFD  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372D01  0F 28 C6                    movaps  xmm0, xmm6
0000000180372D04  F3 0F 11 A3 40 72 00 00     movss   dword ptr [rbx+7240h], xmm4
0000000180372D0C  F3 0F 10 8B D0 72 00 00     movss   xmm1, dword ptr [rbx+72D0h]
0000000180372D14  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180372D18  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180372D1C  0F 28 C1                    movaps  xmm0, xmm1
0000000180372D1F  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180372D23  F3 0F 58 EC                 addss   xmm5, xmm4
0000000180372D27  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180372D2B  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180372D2F  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180372D33  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180372D37  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180372D3B  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180372D3F  0F 28 C6                    movaps  xmm0, xmm6
0000000180372D42  F3 0F 11 9B 50 72 00 00     movss   dword ptr [rbx+7250h], xmm3
0000000180372D4A  F3 0F 10 AB E0 72 00 00     movss   xmm5, dword ptr [rbx+72E0h]
0000000180372D52  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180372D56  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372D5A  0F 28 C5                    movaps  xmm0, xmm5
0000000180372D5D  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180372D61  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180372D65  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180372D69  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180372D6D  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180372D71  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180372D75  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180372D79  0F 28 C6                    movaps  xmm0, xmm6
0000000180372D7C  F3 0F 11 93 60 72 00 00     movss   dword ptr [rbx+7260h], xmm2
0000000180372D84  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180372D88  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180372D8C  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180372D90  F3 41 0F 59 E8              mulss   xmm5, xmm8
0000000180372D95  0F 28 C6                    movaps  xmm0, xmm6
0000000180372D98  F3 0F 59 83 F0 72 00 00     mulss   xmm0, dword ptr [rbx+72F0h]
0000000180372DA0  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180372DA4  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180372DA8  F3 44 0F 59 C1              mulss   xmm8, xmm1
0000000180372DAD  F3 0F 11 AB 70 72 00 00     movss   dword ptr [rbx+7270h], xmm5
0000000180372DB5  F3 0F 10 9B 50 72 00 00     movss   xmm3, dword ptr [rbx+7250h]
0000000180372DBD  F3 0F 59 F5                 mulss   xmm6, xmm5
0000000180372DC1  F3 44 0F 58 C6              addss   xmm8, xmm6
0000000180372DC6  F3 44 0F 11 83 80 72 00 00  movss   dword ptr [rbx+7280h], xmm8
0000000180372DCF  F3 0F 10 83 A0 75 00 00     movss   xmm0, dword ptr [rbx+75A0h]
0000000180372DD7  F3 0F 59 83 60 72 00 00     mulss   xmm0, dword ptr [rbx+7260h]
0000000180372DDF  F3 0F 59 AB B0 75 00 00     mulss   xmm5, dword ptr [rbx+75B0h]
0000000180372DE7  F3 0F 59 9B 90 75 00 00     mulss   xmm3, dword ptr [rbx+7590h]
0000000180372DEF  F3 0F 10 A3 50 73 00 00     movss   xmm4, dword ptr [rbx+7350h]
0000000180372DF7  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180372DFB  F3 0F 58 EB                 addss   xmm5, xmm3
0000000180372DFF  F3 0F 11 AB 10 73 00 00     movss   dword ptr [rbx+7310h], xmm5
0000000180372E07  F3 0F 58 A3 C0 74 00 00     addss   xmm4, dword ptr [rbx+74C0h]
0000000180372E0F  F3 0F 10 83 D0 73 00 00     movss   xmm0, dword ptr [rbx+73D0h]
0000000180372E17  F3 0F 58 83 40 74 00 00     addss   xmm0, dword ptr [rbx+7440h]
0000000180372E1F  F3 0F 10 8B 50 74 00 00     movss   xmm1, dword ptr [rbx+7450h]
0000000180372E27  F3 0F 58 8B C0 73 00 00     addss   xmm1, dword ptr [rbx+73C0h]
0000000180372E2F  F3 0F 59 A3 40 77 00 00     mulss   xmm4, dword ptr [rbx+7740h]
0000000180372E37  F3 0F 59 83 30 77 00 00     mulss   xmm0, dword ptr [rbx+7730h]
0000000180372E3F  F3 0F 59 8B 20 77 00 00     mulss   xmm1, dword ptr [rbx+7720h]
0000000180372E47  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372E4B  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180372E4F  F3 0F 10 83 40 73 00 00     movss   xmm0, dword ptr [rbx+7340h]
0000000180372E57  F3 0F 58 83 D0 74 00 00     addss   xmm0, dword ptr [rbx+74D0h]
0000000180372E5F  F3 0F 10 8B B0 74 00 00     movss   xmm1, dword ptr [rbx+74B0h]
0000000180372E67  F3 0F 58 8B 60 73 00 00     addss   xmm1, dword ptr [rbx+7360h]
0000000180372E6F  F3 0F 58 AB 00 75 00 00     addss   xmm5, dword ptr [rbx+7500h]
0000000180372E77  F3 0F 59 83 10 77 00 00     mulss   xmm0, dword ptr [rbx+7710h]
0000000180372E7F  F3 0F 59 8B 00 77 00 00     mulss   xmm1, dword ptr [rbx+7700h]
0000000180372E87  F3 0F 59 AB 50 76 00 00     mulss   xmm5, dword ptr [rbx+7650h]
0000000180372E8F  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372E93  F3 0F 10 83 30 74 00 00     movss   xmm0, dword ptr [rbx+7430h]
0000000180372E9B  F3 0F 58 83 E0 73 00 00     addss   xmm0, dword ptr [rbx+73E0h]
0000000180372EA3  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180372EA7  F3 0F 10 8B 60 74 00 00     movss   xmm1, dword ptr [rbx+7460h]
0000000180372EAF  F3 0F 58 8B B0 73 00 00     addss   xmm1, dword ptr [rbx+73B0h]
0000000180372EB7  F3 0F 59 83 F0 76 00 00     mulss   xmm0, dword ptr [rbx+76F0h]
0000000180372EBF  F3 0F 59 8B E0 76 00 00     mulss   xmm1, dword ptr [rbx+76E0h]
0000000180372EC7  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372ECB  F3 0F 10 83 E0 74 00 00     movss   xmm0, dword ptr [rbx+74E0h]
0000000180372ED3  F3 0F 58 83 30 73 00 00     addss   xmm0, dword ptr [rbx+7330h]
0000000180372EDB  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180372EDF  F3 0F 10 8B A0 74 00 00     movss   xmm1, dword ptr [rbx+74A0h]
0000000180372EE7  F3 0F 59 83 D0 76 00 00     mulss   xmm0, dword ptr [rbx+76D0h]
0000000180372EEF  F3 0F 58 8B 70 73 00 00     addss   xmm1, dword ptr [rbx+7370h]
0000000180372EF7  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372EFB  F3 0F 10 83 20 74 00 00     movss   xmm0, dword ptr [rbx+7420h]
0000000180372F03  F3 0F 58 83 F0 73 00 00     addss   xmm0, dword ptr [rbx+73F0h]
0000000180372F0B  F3 0F 59 8B C0 76 00 00     mulss   xmm1, dword ptr [rbx+76C0h]
0000000180372F13  F3 0F 59 83 B0 76 00 00     mulss   xmm0, dword ptr [rbx+76B0h]
0000000180372F1B  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180372F1F  F3 0F 10 8B 70 74 00 00     movss   xmm1, dword ptr [rbx+7470h]
0000000180372F27  F3 0F 58 8B A0 73 00 00     addss   xmm1, dword ptr [rbx+73A0h]
0000000180372F2F  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372F33  F3 0F 10 83 F0 74 00 00     movss   xmm0, dword ptr [rbx+74F0h]
0000000180372F3B  F3 0F 59 8B A0 76 00 00     mulss   xmm1, dword ptr [rbx+76A0h]
0000000180372F43  F3 0F 58 83 20 73 00 00     addss   xmm0, dword ptr [rbx+7320h]
0000000180372F4B  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180372F4F  F3 0F 10 8B 90 74 00 00     movss   xmm1, dword ptr [rbx+7490h]
0000000180372F57  F3 0F 58 8B 80 73 00 00     addss   xmm1, dword ptr [rbx+7380h]
0000000180372F5F  F3 0F 59 83 90 76 00 00     mulss   xmm0, dword ptr [rbx+7690h]
0000000180372F67  F3 0F 59 8B 80 76 00 00     mulss   xmm1, dword ptr [rbx+7680h]
0000000180372F6F  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372F73  F3 0F 10 83 10 74 00 00     movss   xmm0, dword ptr [rbx+7410h]
0000000180372F7B  F3 0F 58 83 00 74 00 00     addss   xmm0, dword ptr [rbx+7400h]
0000000180372F83  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180372F87  F3 0F 10 8B 80 74 00 00     movss   xmm1, dword ptr [rbx+7480h]
0000000180372F8F  F3 0F 59 83 70 76 00 00     mulss   xmm0, dword ptr [rbx+7670h]
0000000180372F97  F3 0F 58 8B 90 73 00 00     addss   xmm1, dword ptr [rbx+7390h]
0000000180372F9F  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180372FA3  F3 0F 59 8B 60 76 00 00     mulss   xmm1, dword ptr [rbx+7660h]
0000000180372FAB  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180372FAF  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180372FB3  F3 0F 59 A3 E0 75 00 00     mulss   xmm4, dword ptr [rbx+75E0h]
0000000180372FBB  F3 0F 11 A3 70 75 00 00     movss   dword ptr [rbx+7570h], xmm4
0000000180372FC3  8B 83 70 77 00 00           mov     eax, [rbx+7770h]
0000000180372FC9  89 83 80 77 00 00           mov     [rbx+7780h], eax
0000000180372FCF  F3 0F 10 83 A0 77 00 00     movss   xmm0, dword ptr [rbx+77A0h]
0000000180372FD7  8B 83 90 77 00 00           mov     eax, [rbx+7790h]
0000000180372FDD  89 83 C0 77 00 00           mov     [rbx+77C0h], eax
0000000180372FE3  F3 0F 11 83 D0 77 00 00     movss   dword ptr [rbx+77D0h], xmm0
0000000180372FEB  8B 83 B0 77 00 00           mov     eax, [rbx+77B0h]
0000000180372FF1  89 83 E0 77 00 00           mov     [rbx+77E0h], eax
0000000180372FF7  F3 0F 10 93 F0 77 00 00     movss   xmm2, dword ptr [rbx+77F0h]
0000000180372FFF  F3 0F 11 93 00 78 00 00     movss   dword ptr [rbx+7800h], xmm2
0000000180373007  F3 0F 10 83 10 78 00 00     movss   xmm0, dword ptr [rbx+7810h]
000000018037300F  F3 0F 11 83 20 78 00 00     movss   dword ptr [rbx+7820h], xmm0
0000000180373017  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037301B  F3 0F 59 93 30 78 00 00     mulss   xmm2, dword ptr [rbx+7830h]
0000000180373023  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180373027  F3 0F 11 93 10 78 00 00     movss   dword ptr [rbx+7810h], xmm2
000000018037302F  F3 0F 10 83 D0 77 00 00     movss   xmm0, dword ptr [rbx+77D0h]
0000000180373037  F3 0F 10 8B E0 77 00 00     movss   xmm1, dword ptr [rbx+77E0h]
000000018037303F  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180373043  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180373047  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037304B  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037304F  F3 0F 11 93 40 78 00 00     movss   dword ptr [rbx+7840h], xmm2
0000000180373057  F3 0F 10 8B 50 78 00 00     movss   xmm1, dword ptr [rbx+7850h]
000000018037305F  F3 0F 11 8B 60 78 00 00     movss   dword ptr [rbx+7860h], xmm1
0000000180373067  F3 0F 10 83 70 78 00 00     movss   xmm0, dword ptr [rbx+7870h]
000000018037306F  0F 28 D8                    movaps  xmm3, xmm0
0000000180373072  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180373076  F3 0F 59 DA                 mulss   xmm3, xmm2
000000018037307A  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037307E  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180373082  41 0F 2F DE                 comiss  xmm3, xmm14
0000000180373086  76 05                       jbe     short loc_18037308D
0000000180373088  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018037308B  EB 03                       jmp     short loc_180373090
000000018037308D  0F 57 C0                    xorps   xmm0, xmm0
0000000180373090  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180373094  F3 0F 11 83 50 78 00 00     movss   dword ptr [rbx+7850h], xmm0
000000018037309C  F3 0F 10 8B 80 78 00 00     movss   xmm1, dword ptr [rbx+7880h]
00000001803730A4  F3 0F 11 8B 90 78 00 00     movss   dword ptr [rbx+7890h], xmm1
00000001803730AC  F3 0F 10 93 A0 78 00 00     movss   xmm2, dword ptr [rbx+78A0h]
00000001803730B4  F3 0F 11 93 B0 78 00 00     movss   dword ptr [rbx+78B0h], xmm2
00000001803730BC  F3 0F 10 83 C0 78 00 00     movss   xmm0, dword ptr [rbx+78C0h]
00000001803730C4  0F 28 D8                    movaps  xmm3, xmm0
00000001803730C7  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803730CB  F3 0F 59 D9                 mulss   xmm3, xmm1
00000001803730CF  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803730D3  F3 0F 58 DA                 addss   xmm3, xmm2
00000001803730D7  41 0F 2F DE                 comiss  xmm3, xmm14
00000001803730DB  76 05                       jbe     short loc_1803730E2
00000001803730DD  0F 5A C3                    cvtps2pd xmm0, xmm3
00000001803730E0  EB 03                       jmp     short loc_1803730E5
00000001803730E2  0F 57 C0                    xorps   xmm0, xmm0
00000001803730E5  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00000001803730E9  F3 0F 11 83 A0 78 00 00     movss   dword ptr [rbx+78A0h], xmm0
00000001803730F1  F3 0F 10 AB D0 78 00 00     movss   xmm5, dword ptr [rbx+78D0h]
00000001803730F9  F3 0F 10 B3 50 54 00 00     movss   xmm6, dword ptr [rbx+5450h]
0000000180373101  0F 28 E5                    movaps  xmm4, xmm5
0000000180373104  F3 0F 11 AB E0 78 00 00     movss   dword ptr [rbx+78E0h], xmm5
000000018037310C  0F 28 C5                    movaps  xmm0, xmm5
000000018037310F  F3 0F 59 A3 30 79 00 00     mulss   xmm4, dword ptr [rbx+7930h]
0000000180373117  0F 28 DD                    movaps  xmm3, xmm5
000000018037311A  F3 0F 58 83 00 79 00 00     addss   xmm0, dword ptr [rbx+7900h]
0000000180373122  F3 0F 58 9B 20 79 00 00     addss   xmm3, dword ptr [rbx+7920h]
000000018037312A  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037312E  73 06                       jnb     short loc_180373136
0000000180373130  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180373134  EB 05                       jmp     short loc_18037313B
0000000180373136  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037313B  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037313F  72 1B                       jb      short loc_18037315C
0000000180373141  F3 0F 10 83 10 79 00 00     movss   xmm0, dword ptr [rbx+7910h]
0000000180373149  0F 28 D8                    movaps  xmm3, xmm0
000000018037314C  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180373150  F3 0F 59 DE                 mulss   xmm3, xmm6
0000000180373154  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180373158  F3 0F 58 DD                 addss   xmm3, xmm5
000000018037315C  41 0F 2E F6                 ucomiss xmm6, xmm14
0000000180373160  F3 0F 10 8B 50 79 00 00     movss   xmm1, dword ptr [rbx+7950h]
0000000180373168  0F 28 D4                    movaps  xmm2, xmm4
000000018037316B  F3 0F 59 93 40 79 00 00     mulss   xmm2, dword ptr [rbx+7940h]
0000000180373173  0F 28 C1                    movaps  xmm0, xmm1
0000000180373176  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037317A  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037317E  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180373182  0F 28 C2                    movaps  xmm0, xmm2
0000000180373185  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180373189  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037318D  F3 0F 5C C2                 subss   xmm0, xmm2
0000000180373191  F3 0F 58 C5                 addss   xmm0, xmm5
0000000180373195  74 03                       jz      short loc_18037319A
0000000180373197  0F 28 C3                    movaps  xmm0, xmm3
000000018037319A  F3 0F 11 83 F0 78 00 00     movss   dword ptr [rbx+78F0h], xmm0
00000001803731A2  F3 0F 11 83 D0 78 00 00     movss   dword ptr [rbx+78D0h], xmm0
00000001803731AA  F3 0F 10 BB 70 75 00 00     movss   xmm7, dword ptr [rbx+7570h]
00000001803731B2  F3 0F 10 B3 E0 5C 00 00     movss   xmm6, dword ptr [rbx+5CE0h]
00000001803731BA  F3 0F 10 9B E0 6C 00 00     movss   xmm3, dword ptr [rbx+6CE0h]
00000001803731C2  F3 0F 10 83 C0 5E 00 00     movss   xmm0, dword ptr [rbx+5EC0h]
00000001803731CA  F3 0F 10 8B 70 77 00 00     movss   xmm1, dword ptr [rbx+7770h]
00000001803731D2  8B 83 90 79 00 00           mov     eax, [rbx+7990h]
00000001803731D8  89 83 A0 79 00 00           mov     [rbx+79A0h], eax
00000001803731DE  8B 83 B0 79 00 00           mov     eax, [rbx+79B0h]
00000001803731E4  89 83 C0 79 00 00           mov     [rbx+79C0h], eax
00000001803731EA  F3 0F 11 83 60 79 00 00     movss   dword ptr [rbx+7960h], xmm0
00000001803731F2  F3 0F 11 8B 70 79 00 00     movss   dword ptr [rbx+7970h], xmm1
00000001803731FA  F3 0F 59 9B 80 7A 00 00     mulss   xmm3, dword ptr [rbx+7A80h]
0000000180373202  F3 0F 10 A3 A0 79 00 00     movss   xmm4, dword ptr [rbx+79A0h]
000000018037320A  F3 0F 10 93 E0 79 00 00     movss   xmm2, dword ptr [rbx+79E0h]
0000000180373212  F3 0F 11 9B 80 79 00 00     movss   dword ptr [rbx+7980h], xmm3
000000018037321A  0F 28 DF                    movaps  xmm3, xmm7
000000018037321D  F3 0F 59 B3 F0 79 00 00     mulss   xmm6, dword ptr [rbx+79F0h]
0000000180373225  F3 0F 5C DC                 subss   xmm3, xmm4
0000000180373229  F3 0F 59 93 F0 78 00 00     mulss   xmm2, dword ptr [rbx+78F0h]
0000000180373231  F3 0F 10 8B 00 7A 00 00     movss   xmm1, dword ptr [rbx+7A00h]
0000000180373239  0F 28 C3                    movaps  xmm0, xmm3
000000018037323C  F3 0F 59 83 20 7A 00 00     mulss   xmm0, dword ptr [rbx+7A20h]
0000000180373244  F3 0F 58 F2                 addss   xmm6, xmm2
0000000180373248  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037324C  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180373250  F3 0F 11 A3 90 79 00 00     movss   dword ptr [rbx+7990h], xmm4
0000000180373258  F3 0F 59 8B 60 79 00 00     mulss   xmm1, dword ptr [rbx+7960h]
0000000180373260  F3 0F 10 93 10 7A 00 00     movss   xmm2, dword ptr [rbx+7A10h]
0000000180373268  F3 0F 59 9B 90 7A 00 00     mulss   xmm3, dword ptr [rbx+7A90h]
0000000180373270  F3 0F 59 A3 A0 7A 00 00     mulss   xmm4, dword ptr [rbx+7AA0h]
0000000180373278  F3 0F 58 F1                 addss   xmm6, xmm1
000000018037327C  0F 28 CA                    movaps  xmm1, xmm2
000000018037327F  F3 0F 59 8B 70 79 00 00     mulss   xmm1, dword ptr [rbx+7970h]
0000000180373287  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037328B  F3 0F 58 DC                 addss   xmm3, xmm4
000000018037328F  F3 0F 5C CA                 subss   xmm1, xmm2
0000000180373293  F3 0F 58 CE                 addss   xmm1, xmm6
0000000180373297  F3 0F 10 B3 30 7A 00 00     movss   xmm6, dword ptr [rbx+7A30h]
000000018037329F  F3 0F 5C C6                 subss   xmm0, xmm6
00000001803732A3  F3 0F 59 8B 60 7A 00 00     mulss   xmm1, dword ptr [rbx+7A60h]
00000001803732AB  F3 0F 59 F8                 mulss   xmm7, xmm0
00000001803732AF  41 0F 2F CE                 comiss  xmm1, xmm14
00000001803732B3  76 05                       jbe     short loc_1803732BA
00000001803732B5  0F 5A C1                    cvtps2pd xmm0, xmm1
00000001803732B8  EB 03                       jmp     short loc_1803732BD
00000001803732BA  0F 57 C0                    xorps   xmm0, xmm0
00000001803732BD  F3 0F 10 93 50 7A 00 00     movss   xmm2, dword ptr [rbx+7A50h]
00000001803732C5  F3 0F 10 A3 40 7A 00 00     movss   xmm4, dword ptr [rbx+7A40h]
00000001803732CD  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00000001803732D1  F3 0F 10 83 80 79 00 00     movss   xmm0, dword ptr [rbx+7980h]
00000001803732D9  F3 0F 59 AB 70 7A 00 00     mulss   xmm5, dword ptr [rbx+7A70h]
00000001803732E1  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803732E6  F3 0F 59 F3                 mulss   xmm6, xmm3
00000001803732EA  F3 0F 10 9B C0 79 00 00     movss   xmm3, dword ptr [rbx+79C0h]
00000001803732F2  F3 0F 58 F7                 addss   xmm6, xmm7
00000001803732F6  F3 0F 59 F0                 mulss   xmm6, xmm0
00000001803732FA  F3 0F 10 83 B0 7A 00 00     movss   xmm0, dword ptr [rbx+7AB0h]
0000000180373302  0F 28 C8                    movaps  xmm1, xmm0
0000000180373305  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180373309  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018037330D  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180373311  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180373315  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180373319  F3 0F 11 9B B0 79 00 00     movss   dword ptr [rbx+79B0h], xmm3
0000000180373321  F3 0F 59 E3                 mulss   xmm4, xmm3
0000000180373325  F3 0F 58 E2                 addss   xmm4, xmm2
0000000180373329  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037332D  F3 0F 59 A3 C0 7A 00 00     mulss   xmm4, dword ptr [rbx+7AC0h]
0000000180373335  F3 0F 11 A3 D0 79 00 00     movss   dword ptr [rbx+79D0h], xmm4
000000018037333D  8B 83 E0 7A 00 00           mov     eax, [rbx+7AE0h]
0000000180373343  89 83 F0 7A 00 00           mov     [rbx+7AF0h], eax
0000000180373349  8B 83 D0 7A 00 00           mov     eax, [rbx+7AD0h]
000000018037334F  89 83 E0 7A 00 00           mov     [rbx+7AE0h], eax
0000000180373355  F3 0F 10 83 F0 7A 00 00     movss   xmm0, dword ptr [rbx+7AF0h]
000000018037335D  F3 0F 10 8B 00 7B 00 00     movss   xmm1, dword ptr [rbx+7B00h]
0000000180373365  F3 0F 5C E0                 subss   xmm4, xmm0
0000000180373369  F3 0F 11 A3 D0 7A 00 00     movss   dword ptr [rbx+7AD0h], xmm4
0000000180373371  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180373375  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180373379  F3 0F 11 8B E0 7A 00 00     movss   dword ptr [rbx+7AE0h], xmm1
0000000180373381  F3 0F 10 93 D0 7A 00 00     movss   xmm2, dword ptr [rbx+7AD0h]
0000000180373389  F3 0F 10 B3 C0 77 00 00     movss   xmm6, dword ptr [rbx+77C0h]
0000000180373391  0F 28 C2                    movaps  xmm0, xmm2
0000000180373394  41 0F 2F F6                 comiss  xmm6, xmm14
0000000180373398  8B 83 30 7B 00 00           mov     eax, [rbx+7B30h]
000000018037339E  89 83 40 7B 00 00           mov     [rbx+7B40h], eax
00000001803733A4  8B 83 20 7B 00 00           mov     eax, [rbx+7B20h]
00000001803733AA  89 83 30 7B 00 00           mov     [rbx+7B30h], eax
00000001803733B0  8B 83 10 7B 00 00           mov     eax, [rbx+7B10h]
00000001803733B6  89 83 20 7B 00 00           mov     [rbx+7B20h], eax
00000001803733BC  F3 0F 11 93 10 7B 00 00     movss   dword ptr [rbx+7B10h], xmm2
00000001803733C4  F3 0F 59 83 60 7B 00 00     mulss   xmm0, dword ptr [rbx+7B60h]
00000001803733CC  F3 0F 10 A3 20 7B 00 00     movss   xmm4, dword ptr [rbx+7B20h]
00000001803733D4  F3 0F 10 8B 80 7B 00 00     movss   xmm1, dword ptr [rbx+7B80h]
00000001803733DC  0F 28 EC                    movaps  xmm5, xmm4
00000001803733DF  F3 0F 59 8B 30 7B 00 00     mulss   xmm1, dword ptr [rbx+7B30h]
00000001803733E7  F3 0F 59 AB 70 7B 00 00     mulss   xmm5, dword ptr [rbx+7B70h]
00000001803733EF  F3 0F 59 A3 A0 7B 00 00     mulss   xmm4, dword ptr [rbx+7BA0h]
00000001803733F7  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803733FB  0F 28 C2                    movaps  xmm0, xmm2
00000001803733FE  F3 0F 59 83 90 7B 00 00     mulss   xmm0, dword ptr [rbx+7B90h]
0000000180373406  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037340A  F3 0F 10 8B B0 7B 00 00     movss   xmm1, dword ptr [rbx+7BB0h]
0000000180373412  F3 0F 59 8B 40 7B 00 00     mulss   xmm1, dword ptr [rbx+7B40h]
000000018037341A  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037341E  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180373422  76 05                       jbe     short loc_180373429
0000000180373424  0F 5A C6                    cvtps2pd xmm0, xmm6
0000000180373427  EB 03                       jmp     short loc_18037342C
0000000180373429  0F 57 C0                    xorps   xmm0, xmm0
000000018037342C  0F 2F 35 8D 20 77 00        comiss  xmm6, cs:dword_180AE54C0
0000000180373433  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180373437  F3 0F 11 AB 20 7B 00 00     movss   dword ptr [rbx+7B20h], xmm5
000000018037343F  0F 28 D8                    movaps  xmm3, xmm0
0000000180373442  F3 0F 11 A3 30 7B 00 00     movss   dword ptr [rbx+7B30h], xmm4
000000018037344A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037344E  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180373452  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180373456  0F 28 C6                    movaps  xmm0, xmm6
0000000180373459  41 0F 57 C3                 xorps   xmm0, xmm11
000000018037345D  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180373461  73 09                       jnb     short loc_18037346C
0000000180373463  45 0F 57 D2                 xorps   xmm10, xmm10
0000000180373467  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
000000018037346C  41 0F 2F F6                 comiss  xmm6, xmm14
0000000180373470  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
0000000180373475  0F 28 C8                    movaps  xmm1, xmm0
0000000180373478  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037347C  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180373480  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180373484  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180373488  72 03                       jb      short loc_18037348D
000000018037348A  0F 28 D3                    movaps  xmm2, xmm3
000000018037348D  F3 0F 11 93 50 7B 00 00     movss   dword ptr [rbx+7B50h], xmm2
0000000180373495  F3 0F 59 93 50 78 00 00     mulss   xmm2, dword ptr [rbx+7850h]
000000018037349D  F3 0F 11 93 C0 7B 00 00     movss   dword ptr [rbx+7BC0h], xmm2
00000001803734A5  F3 0F 59 93 A0 78 00 00     mulss   xmm2, dword ptr [rbx+78A0h]
00000001803734AD  F3 0F 11 93 D0 7B 00 00     movss   dword ptr [rbx+7BD0h], xmm2
00000001803734B5  F3 0F 10 83 80 63 00 00     movss   xmm0, dword ptr [rbx+6380h]
00000001803734BD  F3 0F 58 83 E0 60 00 00     addss   xmm0, dword ptr [rbx+60E0h]
00000001803734C5  44 0F 5A E0                 cvtps2pd xmm12, xmm0
00000001803734C9  F2 44 0F 5F 25 D6 77 61 00  maxsd   xmm12, cs:qword_18098ACA8
00000001803734D2  F2 44 0F 5D 25 B5 77 61 00  minsd   xmm12, cs:qword_18098AC90
00000001803734DB  41 0F 28 CC                 movaps  xmm1, xmm12
00000001803734DF  41 0F 28 C4                 movaps  xmm0, xmm12
00000001803734E3  F2 0F 58 05 7D 1D 77 00     addsd   xmm0, cs:qword_180AE5268
00000001803734EB  F2 41 0F 59 CC              mulsd   xmm1, xmm12
00000001803734F0  41 0F 28 FC                 movaps  xmm7, xmm12
00000001803734F4  F2 0F 2C C0                 cvttsd2si eax, xmm0
00000001803734F8  0F 28 D1                    movaps  xmm2, xmm1
00000001803734FB  48 63 C8                    movsxd  rcx, eax
00000001803734FE  F2 41 0F 59 D4              mulsd   xmm2, xmm12
0000000180373503  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
000000018037350A  0F 28 DA                    movaps  xmm3, xmm2
000000018037350D  F2 41 0F 59 DC              mulsd   xmm3, xmm12
0000000180373512  48 8D 0D C7 5F 61 00        lea     rcx, unk_1809894E0
0000000180373519  48 03 C1                    add     rax, rcx
000000018037351C  0F 28 E3                    movaps  xmm4, xmm3
000000018037351F  F2 41 0F 59 E4              mulsd   xmm4, xmm12
0000000180373524  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
0000000180373529  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
000000018037352E  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
0000000180373533  0F 28 EC                    movaps  xmm5, xmm4
0000000180373536  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
000000018037353A  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
000000018037353F  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
0000000180373544  F2 0F 58 F9                 addsd   xmm7, xmm1
0000000180373548  F2 41 0F 59 EC              mulsd   xmm5, xmm12
000000018037354D  F2 0F 58 FA                 addsd   xmm7, xmm2
0000000180373551  0F 28 F5                    movaps  xmm6, xmm5
0000000180373554  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
0000000180373559  F2 41 0F 59 F4              mulsd   xmm6, xmm12
000000018037355E  F2 0F 58 FB                 addsd   xmm7, xmm3
0000000180373562  44 0F 28 C6                 movaps  xmm8, xmm6
0000000180373566  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
000000018037356B  F2 0F 58 FC                 addsd   xmm7, xmm4
000000018037356F  F2 45 0F 59 C4              mulsd   xmm8, xmm12
0000000180373574  F2 0F 58 FD                 addsd   xmm7, xmm5
0000000180373578  45 0F 28 C8                 movaps  xmm9, xmm8
000000018037357C  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
0000000180373585  F2 45 0F 59 CC              mulsd   xmm9, xmm12
000000018037358A  F2 0F 58 FE                 addsd   xmm7, xmm6
000000018037358E  45 0F 28 D1                 movaps  xmm10, xmm9
0000000180373592  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
000000018037359B  F2 41 0F 58 F8              addsd   xmm7, xmm8
00000001803735A0  F2 45 0F 59 D4              mulsd   xmm10, xmm12
00000001803735A5  F2 41 0F 58 F9              addsd   xmm7, xmm9
00000001803735AA  45 0F 28 DA                 movaps  xmm11, xmm10
00000001803735AE  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
00000001803735B7  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00000001803735BC  F2 41 0F 58 FA              addsd   xmm7, xmm10
00000001803735C1  41 0F 28 C3                 movaps  xmm0, xmm11
00000001803735C5  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00000001803735CA  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
00000001803735D2  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
00000001803735DB  F2 0F 58 F8                 addsd   xmm7, xmm0
00000001803735DF  F2 41 0F 58 FB              addsd   xmm7, xmm11
00000001803735E4  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
00000001803735E8  F3 0F 5D 1D A8 76 61 00     minss   xmm3, cs:dword_18098AC98
00000001803735F0  F3 0F 5F 1D B8 76 61 00     maxss   xmm3, cs:dword_18098ACB0
00000001803735F8  F3 0F 59 9B F0 60 00 00     mulss   xmm3, dword ptr [rbx+60F0h]
0000000180373600  F3 0F 11 9B 60 63 00 00     movss   dword ptr [rbx+6360h], xmm3
0000000180373608  8B 83 00 65 00 00           mov     eax, [rbx+6500h]
000000018037360E  F3 0F 10 AB E0 60 00 00     movss   xmm5, dword ptr [rbx+60E0h]
0000000180373616  F3 0F 10 83 B0 62 00 00     movss   xmm0, dword ptr [rbx+62B0h]
000000018037361E  F3 0F 10 8B C0 62 00 00     movss   xmm1, dword ptr [rbx+62C0h]
0000000180373626  F3 0F 10 93 D0 62 00 00     movss   xmm2, dword ptr [rbx+62D0h]
000000018037362E  89 83 10 65 00 00           mov     [rbx+6510h], eax
0000000180373634  8B 83 20 65 00 00           mov     eax, [rbx+6520h]
000000018037363A  89 83 30 65 00 00           mov     [rbx+6530h], eax
0000000180373640  8B 83 D0 65 00 00           mov     eax, [rbx+65D0h]
0000000180373646  89 83 E0 65 00 00           mov     [rbx+65E0h], eax
000000018037364C  8B 83 C0 65 00 00           mov     eax, [rbx+65C0h]
0000000180373652  89 83 D0 65 00 00           mov     [rbx+65D0h], eax
0000000180373658  8B 83 B0 65 00 00           mov     eax, [rbx+65B0h]
000000018037365E  89 83 C0 65 00 00           mov     [rbx+65C0h], eax
0000000180373664  8B 83 A0 65 00 00           mov     eax, [rbx+65A0h]
000000018037366A  89 83 B0 65 00 00           mov     [rbx+65B0h], eax
0000000180373670  8B 83 90 65 00 00           mov     eax, [rbx+6590h]
0000000180373676  89 83 A0 65 00 00           mov     [rbx+65A0h], eax
000000018037367C  8B 83 80 65 00 00           mov     eax, [rbx+6580h]
0000000180373682  89 83 90 65 00 00           mov     [rbx+6590h], eax
0000000180373688  8B 83 70 65 00 00           mov     eax, [rbx+6570h]
000000018037368E  89 83 80 65 00 00           mov     [rbx+6580h], eax
0000000180373694  8B 83 50 66 00 00           mov     eax, [rbx+6650h]
000000018037369A  89 83 60 66 00 00           mov     [rbx+6660h], eax
00000001803736A0  8B 83 40 66 00 00           mov     eax, [rbx+6640h]
00000001803736A6  89 83 50 66 00 00           mov     [rbx+6650h], eax
00000001803736AC  8B 83 30 66 00 00           mov     eax, [rbx+6630h]
00000001803736B2  89 83 40 66 00 00           mov     [rbx+6640h], eax
00000001803736B8  8B 83 20 66 00 00           mov     eax, [rbx+6620h]
00000001803736BE  89 83 30 66 00 00           mov     [rbx+6630h], eax
00000001803736C4  8B 83 10 66 00 00           mov     eax, [rbx+6610h]
00000001803736CA  89 83 20 66 00 00           mov     [rbx+6620h], eax
00000001803736D0  8B 83 00 66 00 00           mov     eax, [rbx+6600h]
00000001803736D6  89 83 10 66 00 00           mov     [rbx+6610h], eax
00000001803736DC  8B 83 F0 65 00 00           mov     eax, [rbx+65F0h]
00000001803736E2  89 83 00 66 00 00           mov     [rbx+6600h], eax
00000001803736E8  8B 83 D0 66 00 00           mov     eax, [rbx+66D0h]
00000001803736EE  89 83 E0 66 00 00           mov     [rbx+66E0h], eax
00000001803736F4  8B 83 C0 66 00 00           mov     eax, [rbx+66C0h]
00000001803736FA  89 83 D0 66 00 00           mov     [rbx+66D0h], eax
0000000180373700  8B 83 B0 66 00 00           mov     eax, [rbx+66B0h]
0000000180373706  89 83 C0 66 00 00           mov     [rbx+66C0h], eax
000000018037370C  8B 83 A0 66 00 00           mov     eax, [rbx+66A0h]
0000000180373712  89 83 B0 66 00 00           mov     [rbx+66B0h], eax
0000000180373718  8B 83 90 66 00 00           mov     eax, [rbx+6690h]
000000018037371E  89 83 A0 66 00 00           mov     [rbx+66A0h], eax
0000000180373724  8B 83 80 66 00 00           mov     eax, [rbx+6680h]
000000018037372A  89 83 90 66 00 00           mov     [rbx+6690h], eax
0000000180373730  8B 83 70 66 00 00           mov     eax, [rbx+6670h]
0000000180373736  89 83 80 66 00 00           mov     [rbx+6680h], eax
000000018037373C  8B 83 50 67 00 00           mov     eax, [rbx+6750h]
0000000180373742  89 83 60 67 00 00           mov     [rbx+6760h], eax
0000000180373748  8B 83 40 67 00 00           mov     eax, [rbx+6740h]
000000018037374E  89 83 50 67 00 00           mov     [rbx+6750h], eax
0000000180373754  8B 83 30 67 00 00           mov     eax, [rbx+6730h]
000000018037375A  89 83 40 67 00 00           mov     [rbx+6740h], eax
0000000180373760  8B 83 20 67 00 00           mov     eax, [rbx+6720h]
0000000180373766  89 83 30 67 00 00           mov     [rbx+6730h], eax
000000018037376C  8B 83 10 67 00 00           mov     eax, [rbx+6710h]
0000000180373772  89 83 20 67 00 00           mov     [rbx+6720h], eax
0000000180373778  8B 83 00 67 00 00           mov     eax, [rbx+6700h]
000000018037377E  89 83 10 67 00 00           mov     [rbx+6710h], eax
0000000180373784  8B 83 F0 66 00 00           mov     eax, [rbx+66F0h]
000000018037378A  89 83 00 67 00 00           mov     [rbx+6700h], eax
0000000180373790  8B 83 90 67 00 00           mov     eax, [rbx+6790h]
0000000180373796  89 83 A0 67 00 00           mov     [rbx+67A0h], eax
000000018037379C  8B 83 80 67 00 00           mov     eax, [rbx+6780h]
00000001803737A2  89 83 90 67 00 00           mov     [rbx+6790h], eax
00000001803737A8  F3 0F 11 83 A0 64 00 00     movss   dword ptr [rbx+64A0h], xmm0
00000001803737B0  F3 0F 11 8B B0 64 00 00     movss   dword ptr [rbx+64B0h], xmm1
00000001803737B8  F3 0F 58 AB C0 6A 00 00     addss   xmm5, dword ptr [rbx+6AC0h]
00000001803737C0  F3 0F 59 9B C0 67 00 00     mulss   xmm3, dword ptr [rbx+67C0h]
00000001803737C8  F3 0F 10 83 B0 67 00 00     movss   xmm0, dword ptr [rbx+67B0h]
00000001803737D0  F3 0F 11 93 C0 64 00 00     movss   dword ptr [rbx+64C0h], xmm2
00000001803737D8  F3 0F 10 93 E0 67 00 00     movss   xmm2, dword ptr [rbx+67E0h]
00000001803737E0  F3 0F 59 AB D0 6A 00 00     mulss   xmm5, dword ptr [rbx+6AD0h]
00000001803737E8  F3 0F 5F D3                 maxss   xmm2, xmm3
00000001803737EC  F3 0F 58 AB B0 6A 00 00     addss   xmm5, dword ptr [rbx+6AB0h]
00000001803737F4  F3 0F 11 93 D0 64 00 00     movss   dword ptr [rbx+64D0h], xmm2
00000001803737FC  F3 0F 58 83 00 61 00 00     addss   xmm0, dword ptr [rbx+6100h]
0000000180373804  41 0F 2F EE                 comiss  xmm5, xmm14
0000000180373808  F3 0F 11 83 F0 64 00 00     movss   dword ptr [rbx+64F0h], xmm0
0000000180373810  76 05                       jbe     short loc_180373817
0000000180373812  0F 5A C5                    cvtps2pd xmm0, xmm5
0000000180373815  EB 03                       jmp     short loc_18037381A
0000000180373817  0F 57 C0                    xorps   xmm0, xmm0
000000018037381A  F3 0F 10 0D 3A 17 77 00     movss   xmm1, cs:dword_180AE4F5C
0000000180373822  F3 44 0F 10 15 BD 19 77 00  movss   xmm10, cs:flt_180AE51E8
000000018037382B  F3 0F 5E CA                 divss   xmm1, xmm2
000000018037382F  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180373833  F3 0F 11 8B E0 64 00 00     movss   dword ptr [rbx+64E0h], xmm1
000000018037383B  F3 0F 11 83 70 67 00 00     movss   dword ptr [rbx+6770h], xmm0
0000000180373843  F3 0F 10 B3 30 65 00 00     movss   xmm6, dword ptr [rbx+6530h]
000000018037384B  F3 0F 10 8B 10 65 00 00     movss   xmm1, dword ptr [rbx+6510h]
0000000180373853  F3 0F 11 B3 50 64 00 00     movss   dword ptr [rbx+6450h], xmm6
000000018037385B  F3 0F 58 F2                 addss   xmm6, xmm2
000000018037385F  F3 0F 11 8B 60 64 00 00     movss   dword ptr [rbx+6460h], xmm1
0000000180373867  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037386B  76 1B                       jbe     short loc_180373888
000000018037386D  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180373872  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180373876  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180373879  E8 5A BC 37 00              call    fmodf
000000018037387E  0F 28 F0                    movaps  xmm6, xmm0
0000000180373881  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180373886  EB 1F                       jmp     short loc_1803738A7
0000000180373888  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037388C  73 19                       jnb     short loc_1803738A7
000000018037388E  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180373893  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180373897  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037389A  E8 39 BC 37 00              call    fmodf
000000018037389F  0F 28 F0                    movaps  xmm6, xmm0
00000001803738A2  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803738A7  F3 44 0F 10 25 5C 17 77 00  movss   xmm12, cs:dword_180AE500C
00000001803738B0  0F 28 C6                    movaps  xmm0, xmm6
00000001803738B3  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803738B8  F3 0F 11 B3 40 64 00 00     movss   dword ptr [rbx+6440h], xmm6
00000001803738C0  0F 28 FE                    movaps  xmm7, xmm6
00000001803738C3  F3 0F 59 BB 30 68 00 00     mulss   xmm7, dword ptr [rbx+6830h]
00000001803738CB  F3 41 0F 59 C4              mulss   xmm0, xmm12
00000001803738D0  E8 EB 56 FF FF              call    sub_180368FC0
00000001803738D5  F3 44 0F 10 1D 66 1B 77 00  movss   xmm11, cs:dword_180AE5444
00000001803738DE  0F 28 E8                    movaps  xmm5, xmm0
00000001803738E1  F3 41 0F 59 EB              mulss   xmm5, xmm11
00000001803738E6  F3 0F 59 AB E0 64 00 00     mulss   xmm5, dword ptr [rbx+64E0h]
00000001803738EE  F3 0F 59 AB 00 68 00 00     mulss   xmm5, dword ptr [rbx+6800h]
00000001803738F6  41 0F 2F EF                 comiss  xmm5, xmm15
00000001803738FA  73 06                       jnb     short loc_180373902
00000001803738FC  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180373900  EB 05                       jmp     short loc_180373907
0000000180373902  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180373907  F3 0F 59 AB D0 67 00 00     mulss   xmm5, dword ptr [rbx+67D0h]
000000018037390F  0F 28 D5                    movaps  xmm2, xmm5
0000000180373912  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180373916  0F 28 CA                    movaps  xmm1, xmm2
0000000180373919  0F 28 C2                    movaps  xmm0, xmm2
000000018037391C  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
0000000180373924  0F 28 DA                    movaps  xmm3, xmm2
0000000180373927  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037392B  0F 28 E2                    movaps  xmm4, xmm2
000000018037392E  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
0000000180373936  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
000000018037393E  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180373942  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
000000018037394A  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037394E  0F 28 C3                    movaps  xmm0, xmm3
0000000180373951  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
0000000180373959  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037395D  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180373961  F3 0F 10 8B F0 64 00 00     movss   xmm1, dword ptr [rbx+64F0h]
0000000180373969  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037396D  0F 28 C1                    movaps  xmm0, xmm1
0000000180373970  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180373974  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180373978  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037397C  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180373980  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180373984  F3 0F 11 A3 40 65 00 00     movss   dword ptr [rbx+6540h], xmm4
000000018037398C  72 07                       jb      short loc_180373995
000000018037398E  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180373993  EB 05                       jmp     short loc_18037399A
0000000180373995  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037399A  0F 28 F0                    movaps  xmm6, xmm0
000000018037399D  73 06                       jnb     short loc_1803739A5
000000018037399F  41 0F 28 F7                 movaps  xmm6, xmm15
00000001803739A3  EB 06                       jmp     short loc_1803739AB
00000001803739A5  76 04                       jbe     short loc_1803739AB
00000001803739A7  41 0F 28 F5                 movaps  xmm6, xmm13
00000001803739AB  F3 44 0F 10 83 40 64 00 00  movss   xmm8, dword ptr [rbx+6440h]
00000001803739B4  F3 0F 59 B3 40 68 00 00     mulss   xmm6, dword ptr [rbx+6840h]
00000001803739BC  F3 0F 5E C1                 divss   xmm0, xmm1
00000001803739C0  E8 FB 55 FF FF              call    sub_180368FC0
00000001803739C5  0F 28 E0                    movaps  xmm4, xmm0
00000001803739C8  F3 0F 10 83 F0 67 00 00     movss   xmm0, dword ptr [rbx+67F0h]
00000001803739D0  44 0F 2F C0                 comiss  xmm8, xmm0
00000001803739D4  72 18                       jb      short loc_1803739EE
00000001803739D6  0F 2F 83 50 64 00 00        comiss  xmm0, dword ptr [rbx+6450h]
00000001803739DD  76 0F                       jbe     short loc_1803739EE
00000001803739DF  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00000001803739E7  F3 41 0F 58 FA              addss   xmm7, xmm10
00000001803739EC  EB 08                       jmp     short loc_1803739F6
00000001803739EE  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00000001803739F6  0F 2F 3D D3 18 77 00        comiss  xmm7, cs:dword_180AE52D0
00000001803739FD  F3 0F 59 A3 E0 64 00 00     mulss   xmm4, dword ptr [rbx+64E0h]
0000000180373A05  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180373A0A  F3 0F 59 A3 10 68 00 00     mulss   xmm4, dword ptr [rbx+6810h]
0000000180373A12  72 03                       jb      short loc_180373A17
0000000180373A14  0F 57 FF                    xorps   xmm7, xmm7
0000000180373A17  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180373A1B  73 06                       jnb     short loc_180373A23
0000000180373A1D  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180373A21  EB 05                       jmp     short loc_180373A28
0000000180373A23  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180373A28  F3 0F 11 BB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm7
0000000180373A30  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180373A35  F3 0F 59 A3 D0 67 00 00     mulss   xmm4, dword ptr [rbx+67D0h]
0000000180373A3D  0F 28 D4                    movaps  xmm2, xmm4
0000000180373A40  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180373A45  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180373A49  0F 28 C2                    movaps  xmm0, xmm2
0000000180373A4C  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180373A51  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180373A55  0F 28 DA                    movaps  xmm3, xmm2
0000000180373A58  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180373A5C  44 0F 28 CA                 movaps  xmm9, xmm2
0000000180373A60  F3 44 0F 59 8B A0 69 00 00  mulss   xmm9, dword ptr [rbx+69A0h]
0000000180373A69  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180373A6E  0F 28 CA                    movaps  xmm1, xmm2
0000000180373A71  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
0000000180373A79  F3 44 0F 58 8B 90 69 00 00  addss   xmm9, dword ptr [rbx+6990h]
0000000180373A82  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
0000000180373A8A  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180373A8F  0F 28 C3                    movaps  xmm0, xmm3
0000000180373A92  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
0000000180373A9A  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180373A9F  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180373AA3  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180373AA8  0F 28 C7                    movaps  xmm0, xmm7
0000000180373AAB  0F 54 05 DE 1C 77 00        andps   xmm0, cs:xmmword_180AE5790
0000000180373AB2  0F 57 05 07 1D 77 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180373AB9  F3 44 0F 58 CB              addss   xmm9, xmm3
0000000180373ABE  F3 44 0F 58 CC              addss   xmm9, xmm4
0000000180373AC3  F3 44 0F 59 CE              mulss   xmm9, xmm6
0000000180373AC8  F3 44 0F 11 8B 50 65 00 00  movss   dword ptr [rbx+6550h], xmm9
0000000180373AD1  E8 EA 54 FF FF              call    sub_180368FC0
0000000180373AD6  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180373ADA  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180373ADE  F3 45 0F 58 C5              addss   xmm8, xmm13
0000000180373AE3  73 06                       jnb     short loc_180373AEB
0000000180373AE5  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180373AE9  EB 06                       jmp     short loc_180373AF1
0000000180373AEB  76 04                       jbe     short loc_180373AF1
0000000180373AED  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180373AF1  F3 44 0F 59 83 E0 64 00 00  mulss   xmm8, dword ptr [rbx+64E0h]
0000000180373AFA  F3 0F 59 BB 50 68 00 00     mulss   xmm7, dword ptr [rbx+6850h]
0000000180373B02  F3 44 0F 59 05 8D 71 61 00  mulss   xmm8, cs:dword_18098AC98
0000000180373B0B  F3 44 0F 59 83 20 68 00 00  mulss   xmm8, dword ptr [rbx+6820h]
0000000180373B14  45 0F 2F C7                 comiss  xmm8, xmm15
0000000180373B18  73 06                       jnb     short loc_180373B20
0000000180373B1A  45 0F 28 C7                 movaps  xmm8, xmm15
0000000180373B1E  EB 05                       jmp     short loc_180373B25
0000000180373B20  F3 45 0F 5D C5              minss   xmm8, xmm13
0000000180373B25  F3 44 0F 59 83 D0 67 00 00  mulss   xmm8, dword ptr [rbx+67D0h]
0000000180373B2E  F3 44 0F 59 8B B0 64 00 00  mulss   xmm9, dword ptr [rbx+64B0h]
0000000180373B37  F3 0F 10 B3 40 64 00 00     movss   xmm6, dword ptr [rbx+6440h]
0000000180373B3F  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180373B43  F3 0F 10 AB 60 64 00 00     movss   xmm5, dword ptr [rbx+6460h]
0000000180373B4B  F3 41 0F 59 D0              mulss   xmm2, xmm8
0000000180373B50  0F 28 C2                    movaps  xmm0, xmm2
0000000180373B53  0F 28 DA                    movaps  xmm3, xmm2
0000000180373B56  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180373B5A  0F 28 E2                    movaps  xmm4, xmm2
0000000180373B5D  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
0000000180373B65  0F 28 CA                    movaps  xmm1, xmm2
0000000180373B68  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
0000000180373B70  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
0000000180373B78  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180373B7D  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
0000000180373B85  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180373B89  0F 28 C3                    movaps  xmm0, xmm3
0000000180373B8C  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
0000000180373B94  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180373B98  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180373B9C  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180373BA0  F3 0F 10 83 40 65 00 00     movss   xmm0, dword ptr [rbx+6540h]
0000000180373BA8  F3 0F 59 83 A0 64 00 00     mulss   xmm0, dword ptr [rbx+64A0h]
0000000180373BB0  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180373BB4  F3 41 0F 58 C1              addss   xmm0, xmm9
0000000180373BB9  F3 41 0F 58 E0              addss   xmm4, xmm8
0000000180373BBE  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180373BC2  F3 0F 59 A3 C0 64 00 00     mulss   xmm4, dword ptr [rbx+64C0h]
0000000180373BCA  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180373BCE  F3 0F 11 A3 70 65 00 00     movss   dword ptr [rbx+6570h], xmm4
0000000180373BD6  F3 0F 11 B3 50 64 00 00     movss   dword ptr [rbx+6450h], xmm6
0000000180373BDE  F3 0F 11 AB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm5
0000000180373BE6  F3 0F 58 B3 D0 64 00 00     addss   xmm6, dword ptr [rbx+64D0h]
0000000180373BEE  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180373BF2  76 1B                       jbe     short loc_180373C0F
0000000180373BF4  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180373BF9  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180373BFD  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180373C00  E8 D3 B8 37 00              call    fmodf
0000000180373C05  0F 28 F0                    movaps  xmm6, xmm0
0000000180373C08  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180373C0D  EB 1F                       jmp     short loc_180373C2E
0000000180373C0F  41 0F 2F F7                 comiss  xmm6, xmm15
0000000180373C13  73 19                       jnb     short loc_180373C2E
0000000180373C15  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180373C1A  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180373C1E  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180373C21  E8 B2 B8 37 00              call    fmodf
0000000180373C26  0F 28 F0                    movaps  xmm6, xmm0
0000000180373C29  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180373C2E  0F 28 C6                    movaps  xmm0, xmm6
0000000180373C31  F3 0F 11 B3 40 64 00 00     movss   dword ptr [rbx+6440h], xmm6
0000000180373C39  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180373C3E  0F 28 FE                    movaps  xmm7, xmm6
0000000180373C41  F3 0F 59 BB 30 68 00 00     mulss   xmm7, dword ptr [rbx+6830h]
0000000180373C49  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180373C4E  E8 6D 53 FF FF              call    sub_180368FC0
0000000180373C53  0F 28 E8                    movaps  xmm5, xmm0
0000000180373C56  F3 41 0F 59 EB              mulss   xmm5, xmm11
0000000180373C5B  F3 0F 59 AB E0 64 00 00     mulss   xmm5, dword ptr [rbx+64E0h]
0000000180373C63  F3 0F 59 AB 00 68 00 00     mulss   xmm5, dword ptr [rbx+6800h]
0000000180373C6B  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180373C6F  73 06                       jnb     short loc_180373C77
0000000180373C71  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180373C75  EB 05                       jmp     short loc_180373C7C
0000000180373C77  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180373C7C  F3 0F 59 AB D0 67 00 00     mulss   xmm5, dword ptr [rbx+67D0h]
0000000180373C84  0F 28 D5                    movaps  xmm2, xmm5
0000000180373C87  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180373C8B  0F 28 CA                    movaps  xmm1, xmm2
0000000180373C8E  0F 28 C2                    movaps  xmm0, xmm2
0000000180373C91  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
0000000180373C99  0F 28 DA                    movaps  xmm3, xmm2
0000000180373C9C  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180373CA0  0F 28 E2                    movaps  xmm4, xmm2
0000000180373CA3  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
0000000180373CAB  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
0000000180373CB3  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180373CB7  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
0000000180373CBF  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180373CC3  0F 28 C3                    movaps  xmm0, xmm3
0000000180373CC6  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
0000000180373CCE  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180373CD2  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180373CD6  F3 0F 10 8B F0 64 00 00     movss   xmm1, dword ptr [rbx+64F0h]
0000000180373CDE  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180373CE2  0F 28 C1                    movaps  xmm0, xmm1
0000000180373CE5  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180373CE9  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180373CED  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180373CF1  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180373CF5  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180373CF9  F3 0F 11 A3 40 65 00 00     movss   dword ptr [rbx+6540h], xmm4
0000000180373D01  72 07                       jb      short loc_180373D0A
0000000180373D03  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180373D08  EB 05                       jmp     short loc_180373D0F
0000000180373D0A  F3 41 0F 5C CD              subss   xmm1, xmm13
0000000180373D0F  0F 28 F0                    movaps  xmm6, xmm0
0000000180373D12  73 06                       jnb     short loc_180373D1A
0000000180373D14  41 0F 28 F7                 movaps  xmm6, xmm15
0000000180373D18  EB 06                       jmp     short loc_180373D20
0000000180373D1A  76 04                       jbe     short loc_180373D20
0000000180373D1C  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180373D20  F3 44 0F 10 83 40 64 00 00  movss   xmm8, dword ptr [rbx+6440h]
0000000180373D29  F3 0F 59 B3 40 68 00 00     mulss   xmm6, dword ptr [rbx+6840h]
0000000180373D31  F3 0F 5E C1                 divss   xmm0, xmm1
0000000180373D35  E8 86 52 FF FF              call    sub_180368FC0
0000000180373D3A  0F 28 E0                    movaps  xmm4, xmm0
0000000180373D3D  F3 0F 10 83 F0 67 00 00     movss   xmm0, dword ptr [rbx+67F0h]
0000000180373D45  44 0F 2F C0                 comiss  xmm8, xmm0
0000000180373D49  72 18                       jb      short loc_180373D63
0000000180373D4B  0F 2F 83 50 64 00 00        comiss  xmm0, dword ptr [rbx+6450h]
0000000180373D52  76 0F                       jbe     short loc_180373D63
0000000180373D54  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
0000000180373D5C  F3 41 0F 58 FA              addss   xmm7, xmm10
0000000180373D61  EB 08                       jmp     short loc_180373D6B
0000000180373D63  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
0000000180373D6B  0F 2F 3D 5E 15 77 00        comiss  xmm7, cs:dword_180AE52D0
0000000180373D72  F3 0F 59 A3 E0 64 00 00     mulss   xmm4, dword ptr [rbx+64E0h]
0000000180373D7A  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180373D7F  F3 0F 59 A3 10 68 00 00     mulss   xmm4, dword ptr [rbx+6810h]
0000000180373D87  72 03                       jb      short loc_180373D8C
0000000180373D89  0F 57 FF                    xorps   xmm7, xmm7
0000000180373D8C  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180373D90  73 06                       jnb     short loc_180373D98
0000000180373D92  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180373D96  EB 05                       jmp     short loc_180373D9D
0000000180373D98  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180373D9D  F3 0F 11 BB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm7
0000000180373DA5  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180373DAA  F3 0F 59 A3 D0 67 00 00     mulss   xmm4, dword ptr [rbx+67D0h]
0000000180373DB2  0F 28 D4                    movaps  xmm2, xmm4
0000000180373DB5  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180373DBA  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180373DBE  0F 28 C2                    movaps  xmm0, xmm2
0000000180373DC1  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180373DC6  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180373DCA  0F 28 DA                    movaps  xmm3, xmm2
0000000180373DCD  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180373DD1  44 0F 28 CA                 movaps  xmm9, xmm2
0000000180373DD5  F3 44 0F 59 8B A0 69 00 00  mulss   xmm9, dword ptr [rbx+69A0h]
0000000180373DDE  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180373DE3  0F 28 CA                    movaps  xmm1, xmm2
0000000180373DE6  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
0000000180373DEE  F3 44 0F 58 8B 90 69 00 00  addss   xmm9, dword ptr [rbx+6990h]
0000000180373DF7  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
0000000180373DFF  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180373E04  0F 28 C3                    movaps  xmm0, xmm3
0000000180373E07  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
0000000180373E0F  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180373E14  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180373E18  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180373E1D  0F 28 C7                    movaps  xmm0, xmm7
0000000180373E20  0F 54 05 69 19 77 00        andps   xmm0, cs:xmmword_180AE5790
0000000180373E27  0F 57 05 92 19 77 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180373E2E  F3 44 0F 58 CB              addss   xmm9, xmm3
0000000180373E33  F3 44 0F 58 CC              addss   xmm9, xmm4
0000000180373E38  F3 44 0F 59 CE              mulss   xmm9, xmm6
0000000180373E3D  F3 44 0F 11 8B 50 65 00 00  movss   dword ptr [rbx+6550h], xmm9
0000000180373E46  E8 75 51 FF FF              call    sub_180368FC0
0000000180373E4B  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180373E4F  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180373E53  F3 45 0F 58 C5              addss   xmm8, xmm13
0000000180373E58  73 06                       jnb     short loc_180373E60
0000000180373E5A  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180373E5E  EB 06                       jmp     short loc_180373E66
0000000180373E60  76 04                       jbe     short loc_180373E66
0000000180373E62  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180373E66  F3 44 0F 59 83 E0 64 00 00  mulss   xmm8, dword ptr [rbx+64E0h]
0000000180373E6F  F3 0F 59 BB 50 68 00 00     mulss   xmm7, dword ptr [rbx+6850h]
0000000180373E77  F3 44 0F 59 05 18 6E 61 00  mulss   xmm8, cs:dword_18098AC98
0000000180373E80  F3 44 0F 59 83 20 68 00 00  mulss   xmm8, dword ptr [rbx+6820h]
0000000180373E89  45 0F 2F C7                 comiss  xmm8, xmm15
0000000180373E8D  73 06                       jnb     short loc_180373E95
0000000180373E8F  45 0F 28 C7                 movaps  xmm8, xmm15
0000000180373E93  EB 05                       jmp     short loc_180373E9A
0000000180373E95  F3 45 0F 5D C5              minss   xmm8, xmm13
0000000180373E9A  F3 44 0F 59 83 D0 67 00 00  mulss   xmm8, dword ptr [rbx+67D0h]
0000000180373EA3  F3 44 0F 59 8B B0 64 00 00  mulss   xmm9, dword ptr [rbx+64B0h]
0000000180373EAC  F3 0F 10 B3 40 64 00 00     movss   xmm6, dword ptr [rbx+6440h]
0000000180373EB4  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180373EB8  F3 0F 10 AB 60 64 00 00     movss   xmm5, dword ptr [rbx+6460h]
0000000180373EC0  F3 41 0F 59 D0              mulss   xmm2, xmm8
0000000180373EC5  0F 28 C2                    movaps  xmm0, xmm2
0000000180373EC8  0F 28 DA                    movaps  xmm3, xmm2
0000000180373ECB  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180373ECF  0F 28 E2                    movaps  xmm4, xmm2
0000000180373ED2  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
0000000180373EDA  0F 28 CA                    movaps  xmm1, xmm2
0000000180373EDD  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
0000000180373EE5  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
0000000180373EED  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180373EF2  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
0000000180373EFA  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180373EFE  0F 28 C3                    movaps  xmm0, xmm3
0000000180373F01  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
0000000180373F09  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180373F0D  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180373F11  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180373F15  F3 0F 10 83 40 65 00 00     movss   xmm0, dword ptr [rbx+6540h]
0000000180373F1D  F3 0F 59 83 A0 64 00 00     mulss   xmm0, dword ptr [rbx+64A0h]
0000000180373F25  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180373F29  F3 41 0F 58 C1              addss   xmm0, xmm9
0000000180373F2E  F3 41 0F 58 E0              addss   xmm4, xmm8
0000000180373F33  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180373F37  F3 0F 59 A3 C0 64 00 00     mulss   xmm4, dword ptr [rbx+64C0h]
0000000180373F3F  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180373F43  F3 0F 11 A3 F0 65 00 00     movss   dword ptr [rbx+65F0h], xmm4
0000000180373F4B  F3 0F 11 B3 50 64 00 00     movss   dword ptr [rbx+6450h], xmm6
0000000180373F53  F3 0F 11 AB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm5
0000000180373F5B  F3 0F 58 B3 D0 64 00 00     addss   xmm6, dword ptr [rbx+64D0h]
0000000180373F63  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180373F67  76 1B                       jbe     short loc_180373F84
0000000180373F69  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180373F6E  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180373F72  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180373F75  E8 5E B5 37 00              call    fmodf
0000000180373F7A  0F 28 F0                    movaps  xmm6, xmm0
0000000180373F7D  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180373F82  EB 1F                       jmp     short loc_180373FA3
0000000180373F84  41 0F 2F F7                 comiss  xmm6, xmm15
0000000180373F88  73 19                       jnb     short loc_180373FA3
0000000180373F8A  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180373F8F  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180373F93  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180373F96  E8 3D B5 37 00              call    fmodf
0000000180373F9B  0F 28 F0                    movaps  xmm6, xmm0
0000000180373F9E  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180373FA3  0F 28 C6                    movaps  xmm0, xmm6
0000000180373FA6  F3 0F 11 B3 40 64 00 00     movss   dword ptr [rbx+6440h], xmm6
0000000180373FAE  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180373FB3  0F 28 FE                    movaps  xmm7, xmm6
0000000180373FB6  F3 0F 59 BB 30 68 00 00     mulss   xmm7, dword ptr [rbx+6830h]
0000000180373FBE  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180373FC3  E8 F8 4F FF FF              call    sub_180368FC0
0000000180373FC8  0F 28 E8                    movaps  xmm5, xmm0
0000000180373FCB  F3 41 0F 59 EB              mulss   xmm5, xmm11
0000000180373FD0  F3 0F 59 AB E0 64 00 00     mulss   xmm5, dword ptr [rbx+64E0h]
0000000180373FD8  F3 0F 59 AB 00 68 00 00     mulss   xmm5, dword ptr [rbx+6800h]
0000000180373FE0  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180373FE4  73 06                       jnb     short loc_180373FEC
0000000180373FE6  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180373FEA  EB 05                       jmp     short loc_180373FF1
0000000180373FEC  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180373FF1  F3 0F 59 AB D0 67 00 00     mulss   xmm5, dword ptr [rbx+67D0h]
0000000180373FF9  0F 28 D5                    movaps  xmm2, xmm5
0000000180373FFC  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180374000  0F 28 CA                    movaps  xmm1, xmm2
0000000180374003  0F 28 C2                    movaps  xmm0, xmm2
0000000180374006  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
000000018037400E  0F 28 DA                    movaps  xmm3, xmm2
0000000180374011  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180374015  0F 28 E2                    movaps  xmm4, xmm2
0000000180374018  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
0000000180374020  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
0000000180374028  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037402C  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
0000000180374034  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180374038  0F 28 C3                    movaps  xmm0, xmm3
000000018037403B  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
0000000180374043  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180374047  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037404B  F3 0F 10 8B F0 64 00 00     movss   xmm1, dword ptr [rbx+64F0h]
0000000180374053  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180374057  0F 28 C1                    movaps  xmm0, xmm1
000000018037405A  F3 0F 58 C6                 addss   xmm0, xmm6
000000018037405E  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180374062  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180374066  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037406A  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037406E  F3 0F 11 A3 40 65 00 00     movss   dword ptr [rbx+6540h], xmm4
0000000180374076  72 07                       jb      short loc_18037407F
0000000180374078  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018037407D  EB 05                       jmp     short loc_180374084
000000018037407F  F3 41 0F 5C CD              subss   xmm1, xmm13
0000000180374084  0F 28 F0                    movaps  xmm6, xmm0
0000000180374087  73 06                       jnb     short loc_18037408F
0000000180374089  41 0F 28 F7                 movaps  xmm6, xmm15
000000018037408D  EB 06                       jmp     short loc_180374095
000000018037408F  76 04                       jbe     short loc_180374095
0000000180374091  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180374095  F3 44 0F 10 83 40 64 00 00  movss   xmm8, dword ptr [rbx+6440h]
000000018037409E  F3 0F 59 B3 40 68 00 00     mulss   xmm6, dword ptr [rbx+6840h]
00000001803740A6  F3 0F 5E C1                 divss   xmm0, xmm1
00000001803740AA  E8 11 4F FF FF              call    sub_180368FC0
00000001803740AF  0F 28 E0                    movaps  xmm4, xmm0
00000001803740B2  F3 0F 10 83 F0 67 00 00     movss   xmm0, dword ptr [rbx+67F0h]
00000001803740BA  44 0F 2F C0                 comiss  xmm8, xmm0
00000001803740BE  72 18                       jb      short loc_1803740D8
00000001803740C0  0F 2F 83 50 64 00 00        comiss  xmm0, dword ptr [rbx+6450h]
00000001803740C7  76 0F                       jbe     short loc_1803740D8
00000001803740C9  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00000001803740D1  F3 41 0F 58 FA              addss   xmm7, xmm10
00000001803740D6  EB 08                       jmp     short loc_1803740E0
00000001803740D8  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
00000001803740E0  0F 2F 3D E9 11 77 00        comiss  xmm7, cs:dword_180AE52D0
00000001803740E7  F3 0F 59 A3 E0 64 00 00     mulss   xmm4, dword ptr [rbx+64E0h]
00000001803740EF  F3 41 0F 59 E3              mulss   xmm4, xmm11
00000001803740F4  F3 0F 59 A3 10 68 00 00     mulss   xmm4, dword ptr [rbx+6810h]
00000001803740FC  72 03                       jb      short loc_180374101
00000001803740FE  0F 57 FF                    xorps   xmm7, xmm7
0000000180374101  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180374105  73 06                       jnb     short loc_18037410D
0000000180374107  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037410B  EB 05                       jmp     short loc_180374112
000000018037410D  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180374112  F3 0F 11 BB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm7
000000018037411A  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018037411F  F3 0F 59 A3 D0 67 00 00     mulss   xmm4, dword ptr [rbx+67D0h]
0000000180374127  0F 28 D4                    movaps  xmm2, xmm4
000000018037412A  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037412F  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180374133  0F 28 C2                    movaps  xmm0, xmm2
0000000180374136  F3 41 0F 59 FC              mulss   xmm7, xmm12
000000018037413B  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037413F  0F 28 DA                    movaps  xmm3, xmm2
0000000180374142  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180374146  44 0F 28 CA                 movaps  xmm9, xmm2
000000018037414A  F3 44 0F 59 8B A0 69 00 00  mulss   xmm9, dword ptr [rbx+69A0h]
0000000180374153  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180374158  0F 28 CA                    movaps  xmm1, xmm2
000000018037415B  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
0000000180374163  F3 44 0F 58 8B 90 69 00 00  addss   xmm9, dword ptr [rbx+6990h]
000000018037416C  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
0000000180374174  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180374179  0F 28 C3                    movaps  xmm0, xmm3
000000018037417C  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
0000000180374184  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180374189  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037418D  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180374192  0F 28 C7                    movaps  xmm0, xmm7
0000000180374195  0F 54 05 F4 15 77 00        andps   xmm0, cs:xmmword_180AE5790
000000018037419C  0F 57 05 1D 16 77 00        xorps   xmm0, cs:xmmword_180AE57C0
00000001803741A3  F3 44 0F 58 CB              addss   xmm9, xmm3
00000001803741A8  F3 44 0F 58 CC              addss   xmm9, xmm4
00000001803741AD  F3 44 0F 59 CE              mulss   xmm9, xmm6
00000001803741B2  F3 44 0F 11 8B 50 65 00 00  movss   dword ptr [rbx+6550h], xmm9
00000001803741BB  E8 00 4E FF FF              call    sub_180368FC0
00000001803741C0  41 0F 2F FE                 comiss  xmm7, xmm14
00000001803741C4  44 0F 28 C0                 movaps  xmm8, xmm0
00000001803741C8  F3 45 0F 58 C5              addss   xmm8, xmm13
00000001803741CD  73 06                       jnb     short loc_1803741D5
00000001803741CF  41 0F 28 FF                 movaps  xmm7, xmm15
00000001803741D3  EB 06                       jmp     short loc_1803741DB
00000001803741D5  76 04                       jbe     short loc_1803741DB
00000001803741D7  41 0F 28 FD                 movaps  xmm7, xmm13
00000001803741DB  F3 44 0F 59 83 E0 64 00 00  mulss   xmm8, dword ptr [rbx+64E0h]
00000001803741E4  F3 0F 59 BB 50 68 00 00     mulss   xmm7, dword ptr [rbx+6850h]
00000001803741EC  F3 44 0F 59 05 A3 6A 61 00  mulss   xmm8, cs:dword_18098AC98
00000001803741F5  F3 44 0F 59 83 20 68 00 00  mulss   xmm8, dword ptr [rbx+6820h]
00000001803741FE  45 0F 2F C7                 comiss  xmm8, xmm15
0000000180374202  73 06                       jnb     short loc_18037420A
0000000180374204  45 0F 28 C7                 movaps  xmm8, xmm15
0000000180374208  EB 05                       jmp     short loc_18037420F
000000018037420A  F3 45 0F 5D C5              minss   xmm8, xmm13
000000018037420F  F3 44 0F 59 83 D0 67 00 00  mulss   xmm8, dword ptr [rbx+67D0h]
0000000180374218  F3 44 0F 59 8B B0 64 00 00  mulss   xmm9, dword ptr [rbx+64B0h]
0000000180374221  F3 0F 10 B3 40 64 00 00     movss   xmm6, dword ptr [rbx+6440h]
0000000180374229  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037422D  F3 0F 10 AB 60 64 00 00     movss   xmm5, dword ptr [rbx+6460h]
0000000180374235  F3 41 0F 59 D0              mulss   xmm2, xmm8
000000018037423A  0F 28 C2                    movaps  xmm0, xmm2
000000018037423D  0F 28 DA                    movaps  xmm3, xmm2
0000000180374240  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180374244  0F 28 E2                    movaps  xmm4, xmm2
0000000180374247  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
000000018037424F  0F 28 CA                    movaps  xmm1, xmm2
0000000180374252  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
000000018037425A  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
0000000180374262  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180374267  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
000000018037426F  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180374273  0F 28 C3                    movaps  xmm0, xmm3
0000000180374276  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
000000018037427E  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180374282  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180374286  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037428A  F3 0F 10 83 40 65 00 00     movss   xmm0, dword ptr [rbx+6540h]
0000000180374292  F3 0F 59 83 A0 64 00 00     mulss   xmm0, dword ptr [rbx+64A0h]
000000018037429A  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037429E  F3 41 0F 58 C1              addss   xmm0, xmm9
00000001803742A3  F3 41 0F 58 E0              addss   xmm4, xmm8
00000001803742A8  F3 0F 59 E7                 mulss   xmm4, xmm7
00000001803742AC  F3 0F 59 A3 C0 64 00 00     mulss   xmm4, dword ptr [rbx+64C0h]
00000001803742B4  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803742B8  F3 0F 11 A3 70 66 00 00     movss   dword ptr [rbx+6670h], xmm4
00000001803742C0  F3 0F 11 B3 50 64 00 00     movss   dword ptr [rbx+6450h], xmm6
00000001803742C8  F3 0F 11 AB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm5
00000001803742D0  F3 0F 58 B3 D0 64 00 00     addss   xmm6, dword ptr [rbx+64D0h]
00000001803742D8  41 0F 2F F5                 comiss  xmm6, xmm13
00000001803742DC  76 1B                       jbe     short loc_1803742F9
00000001803742DE  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803742E3  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00000001803742E7  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803742EA  E8 E9 B1 37 00              call    fmodf
00000001803742EF  0F 28 F0                    movaps  xmm6, xmm0
00000001803742F2  F3 41 0F 5C F5              subss   xmm6, xmm13
00000001803742F7  EB 1F                       jmp     short loc_180374318
00000001803742F9  41 0F 2F F7                 comiss  xmm6, xmm15
00000001803742FD  73 19                       jnb     short loc_180374318
00000001803742FF  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180374304  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180374308  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037430B  E8 C8 B1 37 00              call    fmodf
0000000180374310  0F 28 F0                    movaps  xmm6, xmm0
0000000180374313  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180374318  0F 28 C6                    movaps  xmm0, xmm6
000000018037431B  F3 0F 11 B3 40 64 00 00     movss   dword ptr [rbx+6440h], xmm6
0000000180374323  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180374328  0F 28 FE                    movaps  xmm7, xmm6
000000018037432B  F3 0F 59 BB 30 68 00 00     mulss   xmm7, dword ptr [rbx+6830h]
0000000180374333  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180374338  E8 83 4C FF FF              call    sub_180368FC0
000000018037433D  0F 28 E8                    movaps  xmm5, xmm0
0000000180374340  F3 41 0F 59 EB              mulss   xmm5, xmm11
0000000180374345  F3 0F 59 AB E0 64 00 00     mulss   xmm5, dword ptr [rbx+64E0h]
000000018037434D  F3 0F 59 AB 00 68 00 00     mulss   xmm5, dword ptr [rbx+6800h]
0000000180374355  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180374359  73 06                       jnb     short loc_180374361
000000018037435B  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037435F  EB 05                       jmp     short loc_180374366
0000000180374361  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180374366  F3 0F 59 AB D0 67 00 00     mulss   xmm5, dword ptr [rbx+67D0h]
000000018037436E  0F 28 D5                    movaps  xmm2, xmm5
0000000180374371  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180374375  0F 28 CA                    movaps  xmm1, xmm2
0000000180374378  0F 28 C2                    movaps  xmm0, xmm2
000000018037437B  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
0000000180374383  0F 28 DA                    movaps  xmm3, xmm2
0000000180374386  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037438A  0F 28 E2                    movaps  xmm4, xmm2
000000018037438D  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
0000000180374395  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
000000018037439D  F3 0F 59 DD                 mulss   xmm3, xmm5
00000001803743A1  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
00000001803743A9  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803743AD  0F 28 C3                    movaps  xmm0, xmm3
00000001803743B0  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00000001803743B8  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803743BC  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803743C0  F3 0F 10 8B F0 64 00 00     movss   xmm1, dword ptr [rbx+64F0h]
00000001803743C8  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803743CC  0F 28 C1                    movaps  xmm0, xmm1
00000001803743CF  F3 0F 58 C6                 addss   xmm0, xmm6
00000001803743D3  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803743D7  41 0F 2F C6                 comiss  xmm0, xmm14
00000001803743DB  F3 0F 58 E5                 addss   xmm4, xmm5
00000001803743DF  F3 0F 59 E7                 mulss   xmm4, xmm7
00000001803743E3  F3 0F 11 A3 40 65 00 00     movss   dword ptr [rbx+6540h], xmm4
00000001803743EB  72 07                       jb      short loc_1803743F4
00000001803743ED  F3 41 0F 58 CD              addss   xmm1, xmm13
00000001803743F2  EB 05                       jmp     short loc_1803743F9
00000001803743F4  F3 41 0F 5C CD              subss   xmm1, xmm13
00000001803743F9  0F 28 F0                    movaps  xmm6, xmm0
00000001803743FC  73 06                       jnb     short loc_180374404
00000001803743FE  41 0F 28 F7                 movaps  xmm6, xmm15
0000000180374402  EB 06                       jmp     short loc_18037440A
0000000180374404  76 04                       jbe     short loc_18037440A
0000000180374406  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037440A  F3 44 0F 10 83 40 64 00 00  movss   xmm8, dword ptr [rbx+6440h]
0000000180374413  F3 0F 59 B3 40 68 00 00     mulss   xmm6, dword ptr [rbx+6840h]
000000018037441B  F3 0F 5E C1                 divss   xmm0, xmm1
000000018037441F  E8 9C 4B FF FF              call    sub_180368FC0
0000000180374424  0F 28 E0                    movaps  xmm4, xmm0
0000000180374427  F3 0F 10 83 F0 67 00 00     movss   xmm0, dword ptr [rbx+67F0h]
000000018037442F  44 0F 2F C0                 comiss  xmm8, xmm0
0000000180374433  72 18                       jb      short loc_18037444D
0000000180374435  0F 2F 83 50 64 00 00        comiss  xmm0, dword ptr [rbx+6450h]
000000018037443C  76 0F                       jbe     short loc_18037444D
000000018037443E  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
0000000180374446  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018037444B  EB 08                       jmp     short loc_180374455
000000018037444D  F3 0F 10 BB 60 64 00 00     movss   xmm7, dword ptr [rbx+6460h]
0000000180374455  0F 2F 3D 74 0E 77 00        comiss  xmm7, cs:dword_180AE52D0
000000018037445C  F3 0F 59 A3 E0 64 00 00     mulss   xmm4, dword ptr [rbx+64E0h]
0000000180374464  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180374469  F3 0F 59 A3 10 68 00 00     mulss   xmm4, dword ptr [rbx+6810h]
0000000180374471  72 03                       jb      short loc_180374476
0000000180374473  0F 57 FF                    xorps   xmm7, xmm7
0000000180374476  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037447A  73 06                       jnb     short loc_180374482
000000018037447C  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180374480  EB 05                       jmp     short loc_180374487
0000000180374482  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180374487  F3 0F 11 BB 60 64 00 00     movss   dword ptr [rbx+6460h], xmm7
000000018037448F  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180374494  F3 0F 59 A3 D0 67 00 00     mulss   xmm4, dword ptr [rbx+67D0h]
000000018037449C  0F 28 D4                    movaps  xmm2, xmm4
000000018037449F  F3 41 0F 58 FD              addss   xmm7, xmm13
00000001803744A4  F3 0F 59 D4                 mulss   xmm2, xmm4
00000001803744A8  0F 28 C2                    movaps  xmm0, xmm2
00000001803744AB  F3 41 0F 59 FC              mulss   xmm7, xmm12
00000001803744B0  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803744B4  0F 28 DA                    movaps  xmm3, xmm2
00000001803744B7  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803744BB  44 0F 28 C2                 movaps  xmm8, xmm2
00000001803744BF  F3 44 0F 59 83 A0 69 00 00  mulss   xmm8, dword ptr [rbx+69A0h]
00000001803744C8  F3 41 0F 5C FD              subss   xmm7, xmm13
00000001803744CD  0F 28 CA                    movaps  xmm1, xmm2
00000001803744D0  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00000001803744D8  F3 44 0F 58 83 90 69 00 00  addss   xmm8, dword ptr [rbx+6990h]
00000001803744E1  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00000001803744E9  F3 44 0F 59 C0              mulss   xmm8, xmm0
00000001803744EE  0F 28 C3                    movaps  xmm0, xmm3
00000001803744F1  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00000001803744F9  F3 44 0F 58 C1              addss   xmm8, xmm1
00000001803744FE  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180374502  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180374507  0F 28 C7                    movaps  xmm0, xmm7
000000018037450A  0F 54 05 7F 12 77 00        andps   xmm0, cs:xmmword_180AE5790
0000000180374511  0F 57 05 A8 12 77 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180374518  F3 44 0F 58 C3              addss   xmm8, xmm3
000000018037451D  F3 44 0F 58 C4              addss   xmm8, xmm4
0000000180374522  F3 44 0F 59 C6              mulss   xmm8, xmm6
0000000180374527  F3 44 0F 11 83 50 65 00 00  movss   dword ptr [rbx+6550h], xmm8
0000000180374530  E8 8B 4A FF FF              call    sub_180368FC0
0000000180374535  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180374539  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037453E  73 06                       jnb     short loc_180374546
0000000180374540  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180374544  EB 06                       jmp     short loc_18037454C
0000000180374546  76 04                       jbe     short loc_18037454C
0000000180374548  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037454C  F3 0F 59 83 E0 64 00 00     mulss   xmm0, dword ptr [rbx+64E0h]
0000000180374554  F3 0F 59 BB 50 68 00 00     mulss   xmm7, dword ptr [rbx+6850h]
000000018037455C  F3 0F 59 05 34 67 61 00     mulss   xmm0, cs:dword_18098AC98
0000000180374564  F3 0F 59 83 20 68 00 00     mulss   xmm0, dword ptr [rbx+6820h]
000000018037456C  41 0F 2F C7                 comiss  xmm0, xmm15
0000000180374570  72 09                       jb      short loc_18037457B
0000000180374572  44 0F 28 F8                 movaps  xmm15, xmm0
0000000180374576  F3 45 0F 5D FD              minss   xmm15, xmm13
000000018037457B  F3 44 0F 59 BB D0 67 00 00  mulss   xmm15, dword ptr [rbx+67D0h]
0000000180374584  F3 44 0F 59 83 B0 64 00 00  mulss   xmm8, dword ptr [rbx+64B0h]
000000018037458D  F3 0F 10 AB 40 64 00 00     movss   xmm5, dword ptr [rbx+6440h]
0000000180374595  41 0F 28 D7                 movaps  xmm2, xmm15
0000000180374599  F3 0F 10 B3 60 64 00 00     movss   xmm6, dword ptr [rbx+6460h]
00000001803745A1  F3 41 0F 59 D7              mulss   xmm2, xmm15
00000001803745A6  0F 28 CA                    movaps  xmm1, xmm2
00000001803745A9  0F 28 C2                    movaps  xmm0, xmm2
00000001803745AC  F3 0F 59 8B 80 69 00 00     mulss   xmm1, dword ptr [rbx+6980h]
00000001803745B4  0F 28 DA                    movaps  xmm3, xmm2
00000001803745B7  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803745BB  0F 28 E2                    movaps  xmm4, xmm2
00000001803745BE  F3 0F 58 8B 70 69 00 00     addss   xmm1, dword ptr [rbx+6970h]
00000001803745C6  F3 0F 59 A3 A0 69 00 00     mulss   xmm4, dword ptr [rbx+69A0h]
00000001803745CE  F3 41 0F 59 DF              mulss   xmm3, xmm15
00000001803745D3  F3 0F 58 A3 90 69 00 00     addss   xmm4, dword ptr [rbx+6990h]
00000001803745DB  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803745DF  0F 28 C3                    movaps  xmm0, xmm3
00000001803745E2  F3 0F 59 9B 60 69 00 00     mulss   xmm3, dword ptr [rbx+6960h]
00000001803745EA  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803745EE  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803745F2  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803745F6  F3 0F 10 83 40 65 00 00     movss   xmm0, dword ptr [rbx+6540h]
00000001803745FE  F3 0F 59 83 A0 64 00 00     mulss   xmm0, dword ptr [rbx+64A0h]
0000000180374606  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037460A  F3 41 0F 58 C0              addss   xmm0, xmm8
000000018037460F  F3 41 0F 58 E7              addss   xmm4, xmm15
0000000180374614  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180374618  F3 0F 59 A3 C0 64 00 00     mulss   xmm4, dword ptr [rbx+64C0h]
0000000180374620  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180374624  F3 0F 11 A3 F0 66 00 00     movss   dword ptr [rbx+66F0h], xmm4
000000018037462C  F3 0F 10 93 60 67 00 00     movss   xmm2, dword ptr [rbx+6760h]
0000000180374634  F3 0F 11 AB 20 65 00 00     movss   dword ptr [rbx+6520h], xmm5
000000018037463C  F3 0F 11 B3 00 65 00 00     movss   dword ptr [rbx+6500h], xmm6
0000000180374644  F3 0F 10 83 70 66 00 00     movss   xmm0, dword ptr [rbx+6670h]
000000018037464C  F3 0F 58 83 60 66 00 00     addss   xmm0, dword ptr [rbx+6660h]
0000000180374654  F3 0F 10 8B F0 66 00 00     movss   xmm1, dword ptr [rbx+66F0h]
000000018037465C  F3 0F 58 8B E0 65 00 00     addss   xmm1, dword ptr [rbx+65E0h]
0000000180374664  F3 0F 10 AB E0 66 00 00     movss   xmm5, dword ptr [rbx+66E0h]
000000018037466C  F3 0F 58 AB F0 65 00 00     addss   xmm5, dword ptr [rbx+65F0h]
0000000180374674  F3 0F 59 83 80 68 00 00     mulss   xmm0, dword ptr [rbx+6880h]
000000018037467C  F3 0F 59 8B 90 68 00 00     mulss   xmm1, dword ptr [rbx+6890h]
0000000180374684  F3 0F 59 AB 70 68 00 00     mulss   xmm5, dword ptr [rbx+6870h]
000000018037468C  F3 0F 58 93 70 65 00 00     addss   xmm2, dword ptr [rbx+6570h]
0000000180374694  F3 0F 59 93 60 68 00 00     mulss   xmm2, dword ptr [rbx+6860h]
000000018037469C  F3 0F 58 EA                 addss   xmm5, xmm2
00000001803746A0  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803746A4  F3 0F 10 83 50 67 00 00     movss   xmm0, dword ptr [rbx+6750h]
00000001803746AC  F3 0F 58 83 80 65 00 00     addss   xmm0, dword ptr [rbx+6580h]
00000001803746B4  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803746B8  F3 0F 10 8B D0 66 00 00     movss   xmm1, dword ptr [rbx+66D0h]
00000001803746C0  F3 0F 59 83 A0 68 00 00     mulss   xmm0, dword ptr [rbx+68A0h]
00000001803746C8  F3 0F 58 8B 00 66 00 00     addss   xmm1, dword ptr [rbx+6600h]
00000001803746D0  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803746D4  F3 0F 10 83 80 66 00 00     movss   xmm0, dword ptr [rbx+6680h]
00000001803746DC  F3 0F 58 83 50 66 00 00     addss   xmm0, dword ptr [rbx+6650h]
00000001803746E4  F3 0F 59 8B B0 68 00 00     mulss   xmm1, dword ptr [rbx+68B0h]
00000001803746EC  F3 0F 59 83 C0 68 00 00     mulss   xmm0, dword ptr [rbx+68C0h]
00000001803746F4  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803746F8  F3 0F 10 8B 00 67 00 00     movss   xmm1, dword ptr [rbx+6700h]
0000000180374700  F3 0F 58 8B D0 65 00 00     addss   xmm1, dword ptr [rbx+65D0h]
0000000180374708  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037470C  F3 0F 10 83 40 67 00 00     movss   xmm0, dword ptr [rbx+6740h]
0000000180374714  F3 0F 59 8B D0 68 00 00     mulss   xmm1, dword ptr [rbx+68D0h]
000000018037471C  F3 0F 58 83 90 65 00 00     addss   xmm0, dword ptr [rbx+6590h]
0000000180374724  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180374728  F3 0F 10 8B 10 66 00 00     movss   xmm1, dword ptr [rbx+6610h]
0000000180374730  F3 0F 58 8B C0 66 00 00     addss   xmm1, dword ptr [rbx+66C0h]
0000000180374738  F3 0F 59 83 E0 68 00 00     mulss   xmm0, dword ptr [rbx+68E0h]
0000000180374740  F3 0F 59 8B F0 68 00 00     mulss   xmm1, dword ptr [rbx+68F0h]
0000000180374748  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037474C  F3 0F 10 83 90 66 00 00     movss   xmm0, dword ptr [rbx+6690h]
0000000180374754  F3 0F 58 83 40 66 00 00     addss   xmm0, dword ptr [rbx+6640h]
000000018037475C  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180374760  F3 0F 10 8B C0 65 00 00     movss   xmm1, dword ptr [rbx+65C0h]
0000000180374768  F3 0F 59 83 00 69 00 00     mulss   xmm0, dword ptr [rbx+6900h]
0000000180374770  F3 0F 58 8B 10 67 00 00     addss   xmm1, dword ptr [rbx+6710h]
0000000180374778  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037477C  F3 0F 10 83 30 67 00 00     movss   xmm0, dword ptr [rbx+6730h]
0000000180374784  F3 0F 59 8B 10 69 00 00     mulss   xmm1, dword ptr [rbx+6910h]
000000018037478C  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180374790  F3 0F 58 83 A0 65 00 00     addss   xmm0, dword ptr [rbx+65A0h]
0000000180374798  F3 0F 10 93 90 67 00 00     movss   xmm2, dword ptr [rbx+6790h]
00000001803747A0  F3 0F 10 8B B0 66 00 00     movss   xmm1, dword ptr [rbx+66B0h]
00000001803747A8  0F 28 E2                    movaps  xmm4, xmm2
00000001803747AB  F3 0F 59 A3 90 6A 00 00     mulss   xmm4, dword ptr [rbx+6A90h]
00000001803747B3  F3 0F 59 83 20 69 00 00     mulss   xmm0, dword ptr [rbx+6920h]
00000001803747BB  F3 0F 58 A3 A0 67 00 00     addss   xmm4, dword ptr [rbx+67A0h]
00000001803747C3  F3 0F 58 8B 20 66 00 00     addss   xmm1, dword ptr [rbx+6620h]
00000001803747CB  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803747CF  F3 0F 10 83 A0 66 00 00     movss   xmm0, dword ptr [rbx+66A0h]
00000001803747D7  F3 0F 58 83 30 66 00 00     addss   xmm0, dword ptr [rbx+6630h]
00000001803747DF  F3 0F 59 8B 30 69 00 00     mulss   xmm1, dword ptr [rbx+6930h]
00000001803747E7  F3 0F 59 83 40 69 00 00     mulss   xmm0, dword ptr [rbx+6940h]
00000001803747EF  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803747F3  F3 0F 10 8B 20 67 00 00     movss   xmm1, dword ptr [rbx+6720h]
00000001803747FB  F3 0F 58 8B B0 65 00 00     addss   xmm1, dword ptr [rbx+65B0h]
0000000180374803  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180374807  0F 28 C2                    movaps  xmm0, xmm2
000000018037480A  F3 0F 59 8B 50 69 00 00     mulss   xmm1, dword ptr [rbx+6950h]
0000000180374812  F3 0F 11 A3 90 67 00 00     movss   dword ptr [rbx+6790h], xmm4
000000018037481A  F3 0F 59 83 A0 6A 00 00     mulss   xmm0, dword ptr [rbx+6AA0h]
0000000180374822  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180374826  F3 0F 58 C4                 addss   xmm0, xmm4
000000018037482A  0F 28 DD                    movaps  xmm3, xmm5
000000018037482D  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180374831  0F 28 C3                    movaps  xmm0, xmm3
0000000180374834  F3 0F 59 83 90 6A 00 00     mulss   xmm0, dword ptr [rbx+6A90h]
000000018037483C  F3 0F 58 C2                 addss   xmm0, xmm2
0000000180374840  F3 0F 11 83 80 67 00 00     movss   dword ptr [rbx+6780h], xmm0
0000000180374848  F3 0F 10 93 E0 6A 00 00     movss   xmm2, dword ptr [rbx+6AE0h]
0000000180374850  F3 0F 59 9B 70 67 00 00     mulss   xmm3, dword ptr [rbx+6770h]
0000000180374858  F3 0F 5C E3                 subss   xmm4, xmm3
000000018037485C  F3 0F 59 E2                 mulss   xmm4, xmm2
0000000180374860  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180374864  F3 0F 5C E2                 subss   xmm4, xmm2
0000000180374868  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037486C  F3 0F 11 A3 60 65 00 00     movss   dword ptr [rbx+6560h], xmm4
0000000180374874  F3 0F 11 A3 E0 5F 00 00     movss   dword ptr [rbx+5FE0h], xmm4
000000018037487C  44 0F 2E AB C0 8C 01 00     ucomiss xmm13, dword ptr [rbx+18CC0h]
0000000180374884  75 1B                       jnz     short loc_1803748A1
0000000180374886  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
000000018037488F  F3 0F 11 83 60 53 00 00     movss   dword ptr [rbx+5360h], xmm0
0000000180374897  C7 83 C0 8C 01 00 00 00 00 00  mov     dword ptr [rbx+18CC0h], 0
00000001803748A1  8B 83 D0 7B 00 00           mov     eax, [rbx+7BD0h]
00000001803748A7  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
00000001803748AF  48 8B 0F                    mov     rcx, [rdi]
00000001803748B2  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
00000001803748B7  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
00000001803748BC  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
00000001803748C1  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
00000001803748C6  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
00000001803748CB  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
00000001803748D0  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
00000001803748D5  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
00000001803748DA  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
00000001803748E0  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
00000001803748E6  89 01                       mov     [rcx], eax
00000001803748E8  8B 83 D0 7B 00 00           mov     eax, [rbx+7BD0h]
00000001803748EE  48 8B 4F 08                 mov     rcx, [rdi+8]
00000001803748F2  49 8B 5B 18                 mov     rbx, [r11+18h]
00000001803748F6  89 01                       mov     [rcx], eax
00000001803748F8  49 8B E3                    mov     rsp, r11
00000001803748FB  5F                          pop     rdi
00000001803748FC  C3                          retn
