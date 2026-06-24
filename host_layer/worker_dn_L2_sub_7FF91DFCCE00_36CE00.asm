; sub_7FF91DFCCE00 @ rva 0x36CE00

00007FF91DFCCE00  48 8B C4                    mov     rax, rsp
00007FF91DFCCE03  48 89 58 10                 mov     [rax+10h], rbx
00007FF91DFCCE07  57                          push    rdi
00007FF91DFCCE08  48 81 EC C0 00 00 00        sub     rsp, 0C0h
00007FF91DFCCE0F  F3 0F 10 A1 50 2A 00 00     movss   xmm4, dword ptr [rcx+2A50h]
00007FF91DFCCE17  48 8B FA                    mov     rdi, rdx
00007FF91DFCCE1A  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
00007FF91DFCCE1E  48 8B D9                    mov     rbx, rcx
00007FF91DFCCE21  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
00007FF91DFCCE25  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00007FF91DFCCE2A  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00007FF91DFCCE2F  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00007FF91DFCCE34  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00007FF91DFCCE39  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00007FF91DFCCE3E  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00007FF91DFCCE44  F3 44 0F 10 2D 67 82 77 00  movss   xmm13, cs:dword_7FF91E7450B4
00007FF91DFCCE4D  44 0F 2E A9 A0 8C 01 00     ucomiss xmm13, dword ptr [rcx+18CA0h]
00007FF91DFCCE55  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00007FF91DFCCE5B  45 0F 57 F6                 xorps   xmm14, xmm14
00007FF91DFCCE5F  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
00007FF91DFCCE69  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00007FF91DFCCE6F  75 16                       jnz     short loc_7FF91DFCCE87
00007FF91DFCCE71  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
00007FF91DFCCE7A  0F 57 E4                    xorps   xmm4, xmm4
00007FF91DFCCE7D  C7 81 50 2A 00 00 00 00 00 00  mov     dword ptr [rcx+2A50h], 0
00007FF91DFCCE87  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
00007FF91DFCCE8F  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
00007FF91DFCCE97  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
00007FF91DFCCE9F  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
00007FF91DFCCEA7  F3 0F 59 05 15 DF 61 00     mulss   xmm0, cs:dword_7FF91E5EADC4
00007FF91DFCCEAF  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
00007FF91DFCCEB7  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
00007FF91DFCCEBF  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFCCEC3  85 D2                       test    edx, edx
00007FF91DFCCEC5  75 07                       jnz     short loc_7FF91DFCCECE
00007FF91DFCCEC7  BA 01 00 00 00              mov     edx, 1
00007FF91DFCCECC  EB 24                       jmp     short loc_7FF91DFCCEF2
00007FF91DFCCECE  8B C2                       mov     eax, edx
00007FF91DFCCED0  25 00 00 20 00              and     eax, 200000h
00007FF91DFCCED5  0F BA E2 17                 bt      edx, 17h
00007FF91DFCCED9  73 08                       jnb     short loc_7FF91DFCCEE3
00007FF91DFCCEDB  85 C0                       test    eax, eax
00007FF91DFCCEDD  75 0C                       jnz     short loc_7FF91DFCCEEB
00007FF91DFCCEDF  03 D2                       add     edx, edx
00007FF91DFCCEE1  EB 0F                       jmp     short loc_7FF91DFCCEF2
00007FF91DFCCEE3  85 C0                       test    eax, eax
00007FF91DFCCEE5  74 04                       jz      short loc_7FF91DFCCEEB
00007FF91DFCCEE7  03 D2                       add     edx, edx
00007FF91DFCCEE9  EB 07                       jmp     short loc_7FF91DFCCEF2
00007FF91DFCCEEB  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
00007FF91DFCCEF2  F3 0F 10 9B E0 29 00 00     movss   xmm3, dword ptr [rbx+29E0h]
00007FF91DFCCEFA  8B C2                       mov     eax, edx
00007FF91DFCCEFC  F3 0F 10 B3 C0 29 00 00     movss   xmm6, dword ptr [rbx+29C0h]
00007FF91DFCCF04  25 FF FF FF 00              and     eax, 0FFFFFFh
00007FF91DFCCF09  F3 44 0F 10 83 80 2A 00 00  movss   xmm8, dword ptr [rbx+2A80h]
00007FF91DFCCF12  8B CA                       mov     ecx, edx
00007FF91DFCCF14  F3 0F 10 BB 90 2A 00 00     movss   xmm7, dword ptr [rbx+2A90h]
00007FF91DFCCF1C  81 CA 00 00 00 FF           or      edx, 0FF000000h
00007FF91DFCCF22  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFCCF26  81 E1 00 00 00 01           and     ecx, 1000000h
00007FF91DFCCF2C  C7 83 C0 2A 00 00 00 00 00 00  mov     dword ptr [rbx+2AC0h], 0
00007FF91DFCCF36  F3 0F 11 9B F0 29 00 00     movss   dword ptr [rbx+29F0h], xmm3
00007FF91DFCCF3E  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFCCF42  0F 44 D0                    cmovz   edx, eax
00007FF91DFCCF45  F3 0F 11 B3 D0 29 00 00     movss   dword ptr [rbx+29D0h], xmm6
00007FF91DFCCF4D  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
00007FF91DFCCF53  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
00007FF91DFCCF59  8B 83 00 2B 00 00           mov     eax, [rbx+2B00h]
00007FF91DFCCF5F  66 0F 6E C2                 movd    xmm0, edx
00007FF91DFCCF63  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFCCF66  89 83 10 2B 00 00           mov     [rbx+2B10h], eax
00007FF91DFCCF6C  F3 0F 11 A3 70 2A 00 00     movss   dword ptr [rbx+2A70h], xmm4
00007FF91DFCCF74  F3 0F 59 05 F4 DC 61 00     mulss   xmm0, cs:dword_7FF91E5EAC70
00007FF91DFCCF7C  F3 44 0F 11 83 A0 2A 00 00  movss   dword ptr [rbx+2AA0h], xmm8
00007FF91DFCCF85  F3 0F 11 BB B0 2A 00 00     movss   dword ptr [rbx+2AB0h], xmm7
00007FF91DFCCF8D  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
00007FF91DFCCF95  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
00007FF91DFCCF9D  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
00007FF91DFCCFA5  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFCCFA9  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
00007FF91DFCCFB1  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFCCFB5  F3 0F 10 93 20 2A 00 00     movss   xmm2, dword ptr [rbx+2A20h]
00007FF91DFCCFBD  F3 0F 11 93 30 2A 00 00     movss   dword ptr [rbx+2A30h], xmm2
00007FF91DFCCFC5  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCCFC9  F3 0F 10 83 00 2A 00 00     movss   xmm0, dword ptr [rbx+2A00h]
00007FF91DFCCFD1  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFCCFD5  F3 0F 11 83 10 2A 00 00     movss   dword ptr [rbx+2A10h], xmm0
00007FF91DFCCFDD  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFCCFE1  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCCFE4  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
00007FF91DFCCFEC  F3 0F 10 8B 40 2A 00 00     movss   xmm1, dword ptr [rbx+2A40h]
00007FF91DFCCFF4  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCCFF8  F3 0F 59 F2                 mulss   xmm6, xmm2
00007FF91DFCCFFC  F3 0F 11 8B 60 2A 00 00     movss   dword ptr [rbx+2A60h], xmm1
00007FF91DFCD004  F3 0F 11 93 D0 2A 00 00     movss   dword ptr [rbx+2AD0h], xmm2
00007FF91DFCD00C  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFCD010  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFCD013  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCD017  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCD01B  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFCD01F  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFCD023  F3 0F 11 B3 E0 2A 00 00     movss   dword ptr [rbx+2AE0h], xmm6
00007FF91DFCD02B  F3 0F 11 9B F0 2A 00 00     movss   dword ptr [rbx+2AF0h], xmm3
00007FF91DFCD033  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCD036  F3 0F 58 9B 30 2B 00 00     addss   xmm3, dword ptr [rbx+2B30h]
00007FF91DFCD03E  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFCD042  72 05                       jb      short loc_7FF91DFCD049
00007FF91DFCD044  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCD047  EB 03                       jmp     short loc_7FF91DFCD04C
00007FF91DFCD049  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFCD04C  41 0F 2E CE                 ucomiss xmm1, xmm14
00007FF91DFCD050  F3 44 0F 10 3D 8B 84 77 00  movss   xmm15, cs:dword_7FF91E7454E4
00007FF91DFCD059  75 06                       jnz     short loc_7FF91DFCD061
00007FF91DFCD05B  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCD05F  EB 04                       jmp     short loc_7FF91DFCD065
00007FF91DFCD061  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFCD065  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFCD069  F3 0F 11 AB 00 2B 00 00     movss   dword ptr [rbx+2B00h], xmm5
00007FF91DFCD071  73 06                       jnb     short loc_7FF91DFCD079
00007FF91DFCD073  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCD077  EB 06                       jmp     short loc_7FF91DFCD07F
00007FF91DFCD079  76 04                       jbe     short loc_7FF91DFCD07F
00007FF91DFCD07B  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFCD07F  F3 0F 10 83 70 2B 00 00     movss   xmm0, dword ptr [rbx+2B70h]
00007FF91DFCD087  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFCD08C  F3 0F 10 93 10 2C 00 00     movss   xmm2, dword ptr [rbx+2C10h]
00007FF91DFCD094  F3 0F 10 8B 80 2B 00 00     movss   xmm1, dword ptr [rbx+2B80h]
00007FF91DFCD09C  8B 83 40 2B 00 00           mov     eax, [rbx+2B40h]
00007FF91DFCD0A2  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFCD0A5  F3 0F 10 A3 D0 2B 00 00     movss   xmm4, dword ptr [rbx+2BD0h]
00007FF91DFCD0AD  F3 0F 58 9B 20 2C 00 00     addss   xmm3, dword ptr [rbx+2C20h]
00007FF91DFCD0B5  F2 44 0F 10 25 E2 80 77 00  movsd   xmm12, cs:dbl_7FF91E7451A0
00007FF91DFCD0BE  F3 0F 11 AB 20 2B 00 00     movss   dword ptr [rbx+2B20h], xmm5
00007FF91DFCD0C6  F3 0F 11 AB 40 2B 00 00     movss   dword ptr [rbx+2B40h], xmm5
00007FF91DFCD0CE  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFCD0D2  89 83 50 2B 00 00           mov     [rbx+2B50h], eax
00007FF91DFCD0D8  F3 0F 11 A3 E0 2B 00 00     movss   dword ptr [rbx+2BE0h], xmm4
00007FF91DFCD0E0  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFCD0E4  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCD0E7  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCD0EB  F3 0F 10 8B B0 2B 00 00     movss   xmm1, dword ptr [rbx+2BB0h]
00007FF91DFCD0F3  F3 0F 58 83 30 2C 00 00     addss   xmm0, dword ptr [rbx+2C30h]
00007FF91DFCD0FB  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFCD100  F3 0F 5E C8                 divss   xmm1, xmm0
00007FF91DFCD104  F3 0F 10 83 40 2C 00 00     movss   xmm0, dword ptr [rbx+2C40h]
00007FF91DFCD10C  F3 0F 59 AB 60 2B 00 00     mulss   xmm5, dword ptr [rbx+2B60h]
00007FF91DFCD114  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFCD118  F3 0F 10 93 A0 2B 00 00     movss   xmm2, dword ptr [rbx+2BA0h]
00007FF91DFCD120  F3 0F 11 AB F0 2B 00 00     movss   dword ptr [rbx+2BF0h], xmm5
00007FF91DFCD128  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFCD12C  F3 0F 10 8B C0 2B 00 00     movss   xmm1, dword ptr [rbx+2BC0h]
00007FF91DFCD134  F3 0F 58 D6                 addss   xmm2, xmm6
00007FF91DFCD138  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFCD13C  F3 0F 11 93 A0 2B 00 00     movss   dword ptr [rbx+2BA0h], xmm2
00007FF91DFCD144  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCD148  F3 0F 11 93 B0 2B 00 00     movss   dword ptr [rbx+2BB0h], xmm2
00007FF91DFCD150  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFCD154  F3 0F 5C E6                 subss   xmm4, xmm6
00007FF91DFCD158  0F 54 25 31 86 77 00        andps   xmm4, cs:xmmword_7FF91E745790
00007FF91DFCD15F  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFCD163  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCD167  0F 83 E8 00 00 00           jnb     loc_7FF91DFCD255
00007FF91DFCD16D  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFCD170  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFCD173  41 0F 2E EE                 ucomiss xmm5, xmm14
00007FF91DFCD177  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFCD17B  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFCD17E  F3 0F 11 83 C0 2B 00 00     movss   dword ptr [rbx+2BC0h], xmm0
00007FF91DFCD186  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFCD18A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCD18E  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFCD192  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCD196  75 03                       jnz     short loc_7FF91DFCD19B
00007FF91DFCD198  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFCD19B  8B 83 80 2C 00 00           mov     eax, [rbx+2C80h]
00007FF91DFCD1A1  48 8D 0D 58 2E C9 FF        lea     rcx, cs:7FF91DC60000h
00007FF91DFCD1A8  F3 0F 59 BB 70 2C 00 00     mulss   xmm7, dword ptr [rbx+2C70h]
00007FF91DFCD1B0  89 83 90 2C 00 00           mov     [rbx+2C90h], eax
00007FF91DFCD1B6  F3 44 0F 59 83 60 2C 00 00  mulss   xmm8, dword ptr [rbx+2C60h]
00007FF91DFCD1BF  F3 0F 10 83 A0 2D 00 00     movss   xmm0, dword ptr [rbx+2DA0h]
00007FF91DFCD1C7  F3 0F 10 93 A0 2C 00 00     movss   xmm2, dword ptr [rbx+2CA0h]
00007FF91DFCD1CF  F3 44 0F 10 8B 00 2D 00 00  movss   xmm9, dword ptr [rbx+2D00h]
00007FF91DFCD1D8  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFCD1DD  F3 44 0F 10 83 E0 2C 00 00  movss   xmm8, dword ptr [rbx+2CE0h]
00007FF91DFCD1E6  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFCD1EA  F3 0F 11 BB 80 2C 00 00     movss   dword ptr [rbx+2C80h], xmm7
00007FF91DFCD1F2  F3 0F 10 BB C0 2C 00 00     movss   xmm7, dword ptr [rbx+2CC0h]
00007FF91DFCD1FA  F3 0F 11 8B D0 2B 00 00     movss   dword ptr [rbx+2BD0h], xmm1
00007FF91DFCD202  F3 0F 11 8B 00 2C 00 00     movss   dword ptr [rbx+2C00h], xmm1
00007FF91DFCD20A  F3 0F 10 8B 60 2D 00 00     movss   xmm1, dword ptr [rbx+2D60h]
00007FF91DFCD212  F3 0F 11 BB D0 2C 00 00     movss   dword ptr [rbx+2CD0h], xmm7
00007FF91DFCD21A  F3 0F 11 93 B0 2C 00 00     movss   dword ptr [rbx+2CB0h], xmm2
00007FF91DFCD222  F3 44 0F 11 83 F0 2C 00 00  movss   dword ptr [rbx+2CF0h], xmm8
00007FF91DFCD22B  F3 44 0F 11 8B 10 2D 00 00  movss   dword ptr [rbx+2D10h], xmm9
00007FF91DFCD234  F3 0F 11 8B 70 2D 00 00     movss   dword ptr [rbx+2D70h], xmm1
00007FF91DFCD23C  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFCD23F  7D 2F                       jge     short loc_7FF91DFCD270
00007FF91DFCD241  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFCD246  F7 D0                       not     eax
00007FF91DFCD248  48 98                       cdqe
00007FF91DFCD24A  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFCD253  EB 47                       jmp     short loc_7FF91DFCD29C
00007FF91DFCD255  F3 0F 58 8B 50 2C 00 00     addss   xmm1, dword ptr [rbx+2C50h]
00007FF91DFCD25D  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFCD261  0F 82 09 FF FF FF           jb      loc_7FF91DFCD170
00007FF91DFCD267  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFCD26B  E9 03 FF FF FF              jmp     loc_7FF91DFCD173
00007FF91DFCD270  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFCD273  7E 07                       jle     short loc_7FF91DFCD27C
00007FF91DFCD275  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFCD27A  EB 15                       jmp     short loc_7FF91DFCD291
00007FF91DFCD27C  85 C0                       test    eax, eax
00007FF91DFCD27E  79 0F                       jns     short loc_7FF91DFCD28F
00007FF91DFCD280  F7 D0                       not     eax
00007FF91DFCD282  48 98                       cdqe
00007FF91DFCD284  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFCD28D  EB 0D                       jmp     short loc_7FF91DFCD29C
00007FF91DFCD28F  7E 0B                       jle     short loc_7FF91DFCD29C
00007FF91DFCD291  48 98                       cdqe
00007FF91DFCD293  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFCD29C  0F 57 05 1D 85 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFCD2A3  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFCD2A7  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFCD2AA  7D 14                       jge     short loc_7FF91DFCD2C0
00007FF91DFCD2AC  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFCD2B1  F7 D0                       not     eax
00007FF91DFCD2B3  48 98                       cdqe
00007FF91DFCD2B5  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFCD2BE  EB 2C                       jmp     short loc_7FF91DFCD2EC
00007FF91DFCD2C0  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFCD2C3  7E 07                       jle     short loc_7FF91DFCD2CC
00007FF91DFCD2C5  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFCD2CA  EB 15                       jmp     short loc_7FF91DFCD2E1
00007FF91DFCD2CC  85 C0                       test    eax, eax
00007FF91DFCD2CE  79 0F                       jns     short loc_7FF91DFCD2DF
00007FF91DFCD2D0  F7 D0                       not     eax
00007FF91DFCD2D2  48 98                       cdqe
00007FF91DFCD2D4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFCD2DD  EB 0D                       jmp     short loc_7FF91DFCD2EC
00007FF91DFCD2DF  7E 0B                       jle     short loc_7FF91DFCD2EC
00007FF91DFCD2E1  48 98                       cdqe
00007FF91DFCD2E3  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFCD2EC  F3 0F 10 83 20 2D 00 00     movss   xmm0, dword ptr [rbx+2D20h]
00007FF91DFCD2F4  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFCD2F8  F3 0F 59 93 90 2D 00 00     mulss   xmm2, dword ptr [rbx+2D90h]
00007FF91DFCD300  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCD304  F3 0F 10 8B 50 2D 00 00     movss   xmm1, dword ptr [rbx+2D50h]
00007FF91DFCD30C  F3 0F 11 93 60 2D 00 00     movss   dword ptr [rbx+2D60h], xmm2
00007FF91DFCD314  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFCD318  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCD31C  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFCD320  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCD324  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFCD328  76 05                       jbe     short loc_7FF91DFCD32F
00007FF91DFCD32A  0F 5A C2                    cvtps2pd xmm0, xmm2
00007FF91DFCD32D  EB 03                       jmp     short loc_7FF91DFCD332
00007FF91DFCD32F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCD332  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFCD336  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFCD33A  72 06                       jb      short loc_7FF91DFCD342
00007FF91DFCD33C  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFCD340  EB 03                       jmp     short loc_7FF91DFCD345
00007FF91DFCD342  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFCD345  F3 0F 10 B3 30 2D 00 00     movss   xmm6, dword ptr [rbx+2D30h]
00007FF91DFCD34D  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFCD351  F3 0F 59 83 C0 2D 00 00     mulss   xmm0, dword ptr [rbx+2DC0h]; X
00007FF91DFCD359  E8 E2 23 38 00              call    expf
00007FF91DFCD35E  F3 0F 59 83 B0 2D 00 00     mulss   xmm0, dword ptr [rbx+2DB0h]
00007FF91DFCD366  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFCD369  8B 83 30 2F 00 00           mov     eax, [rbx+2F30h]
00007FF91DFCD36F  F3 0F 59 8B 40 2D 00 00     mulss   xmm1, dword ptr [rbx+2D40h]
00007FF91DFCD377  89 83 40 2F 00 00           mov     [rbx+2F40h], eax
00007FF91DFCD37D  F3 0F 58 83 D0 2D 00 00     addss   xmm0, dword ptr [rbx+2DD0h]
00007FF91DFCD385  8B 83 50 2F 00 00           mov     eax, [rbx+2F50h]
00007FF91DFCD38B  F3 0F 10 9B F0 2E 00 00     movss   xmm3, dword ptr [rbx+2EF0h]
00007FF91DFCD393  F3 0F 59 BB 80 30 00 00     mulss   xmm7, dword ptr [rbx+3080h]
00007FF91DFCD39B  89 83 60 2F 00 00           mov     [rbx+2F60h], eax
00007FF91DFCD3A1  8B 83 70 2F 00 00           mov     eax, [rbx+2F70h]
00007FF91DFCD3A7  F3 0F 10 93 E0 2E 00 00     movss   xmm2, dword ptr [rbx+2EE0h]
00007FF91DFCD3AF  F3 0F 10 A3 10 2F 00 00     movss   xmm4, dword ptr [rbx+2F10h]
00007FF91DFCD3B7  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFCD3BB  89 83 80 2F 00 00           mov     [rbx+2F80h], eax
00007FF91DFCD3C1  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
00007FF91DFCD3C7  F3 0F 11 9B 00 2F 00 00     movss   dword ptr [rbx+2F00h], xmm3
00007FF91DFCD3CF  F3 0F 5C CE                 subss   xmm1, xmm6
00007FF91DFCD3D3  F3 0F 11 93 F0 2E 00 00     movss   dword ptr [rbx+2EF0h], xmm2
00007FF91DFCD3DB  F3 0F 11 A3 20 2F 00 00     movss   dword ptr [rbx+2F20h], xmm4
00007FF91DFCD3E3  F3 44 0F 11 83 B0 2E 00 00  movss   dword ptr [rbx+2EB0h], xmm8
00007FF91DFCD3EC  F3 44 0F 11 8B C0 2E 00 00  movss   dword ptr [rbx+2EC0h], xmm9
00007FF91DFCD3F5  89 83 A0 2E 00 00           mov     [rbx+2EA0h], eax
00007FF91DFCD3FB  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCD3FF  F3 0F 10 83 50 30 00 00     movss   xmm0, dword ptr [rbx+3050h]
00007FF91DFCD407  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFCD40B  F3 0F 11 83 40 30 00 00     movss   dword ptr [rbx+3040h], xmm0
00007FF91DFCD413  F3 0F 11 8B 80 2D 00 00     movss   dword ptr [rbx+2D80h], xmm1
00007FF91DFCD41B  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFCD41F  73 06                       jnb     short loc_7FF91DFCD427
00007FF91DFCD421  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFCD425  EB 05                       jmp     short loc_7FF91DFCD42C
00007FF91DFCD427  F3 41 0F 5D FD              minss   xmm7, xmm13
00007FF91DFCD42C  F3 0F 59 0D 8C D9 61 00     mulss   xmm1, cs:dword_7FF91E5EADC0
00007FF91DFCD434  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFCD438  F3 0F 10 B3 60 31 00 00     movss   xmm6, dword ptr [rbx+3160h]
00007FF91DFCD440  F3 0F 5C C3                 subss   xmm0, xmm3
00007FF91DFCD444  F3 0F 11 BB E0 2E 00 00     movss   dword ptr [rbx+2EE0h], xmm7
00007FF91DFCD44C  F3 0F 5D F1                 minss   xmm6, xmm1
00007FF91DFCD450  F3 0F 59 83 90 30 00 00     mulss   xmm0, dword ptr [rbx+3090h]
00007FF91DFCD458  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFCD45C  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFCD460  73 06                       jnb     short loc_7FF91DFCD468
00007FF91DFCD462  41 0F 28 C7                 movaps  xmm0, xmm15
00007FF91DFCD466  EB 05                       jmp     short loc_7FF91DFCD46D
00007FF91DFCD468  F3 41 0F 5D C5              minss   xmm0, xmm13
00007FF91DFCD46D  F3 0F 59 B3 70 31 00 00     mulss   xmm6, dword ptr [rbx+3170h]
00007FF91DFCD475  F3 0F 5C D7                 subss   xmm2, xmm7
00007FF91DFCD479  F3 0F 11 B3 90 2F 00 00     movss   dword ptr [rbx+2F90h], xmm6
00007FF91DFCD481  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFCD485  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFCD489  73 03                       jnb     short loc_7FF91DFCD48E
00007FF91DFCD48B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCD48E  F3 0F 10 8B 60 30 00 00     movss   xmm1, dword ptr [rbx+3060h]
00007FF91DFCD496  F3 44 0F 10 9B A0 2E 00 00  movss   xmm11, dword ptr [rbx+2EA0h]
00007FF91DFCD49F  F3 0F 11 83 F0 2E 00 00     movss   dword ptr [rbx+2EF0h], xmm0
00007FF91DFCD4A7  F3 0F 58 83 F0 31 00 00     addss   xmm0, dword ptr [rbx+31F0h]
00007FF91DFCD4AF  72 04                       jb      short loc_7FF91DFCD4B5
00007FF91DFCD4B1  41 0F 28 CD                 movaps  xmm1, xmm13
00007FF91DFCD4B5  F3 0F 59 83 E0 31 00 00     mulss   xmm0, dword ptr [rbx+31E0h]
00007FF91DFCD4BD  41 0F 28 FB                 movaps  xmm7, xmm11
00007FF91DFCD4C1  F3 0F 10 93 40 2F 00 00     movss   xmm2, dword ptr [rbx+2F40h]
00007FF91DFCD4C9  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFCD4CD  F3 0F 5C FA                 subss   xmm7, xmm2
00007FF91DFCD4D1  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCD4D5  F3 0F 59 B3 70 30 00 00     mulss   xmm6, dword ptr [rbx+3070h]
00007FF91DFCD4DD  76 05                       jbe     short loc_7FF91DFCD4E4
00007FF91DFCD4DF  0F 5A C8                    cvtps2pd xmm1, xmm0
00007FF91DFCD4E2  EB 03                       jmp     short loc_7FF91DFCD4E7
00007FF91DFCD4E4  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFCD4E7  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFCD4EB  F3 0F 59 BB B0 32 00 00     mulss   xmm7, dword ptr [rbx+32B0h]
00007FF91DFCD4F3  F3 44 0F 10 0D EC 7C 77 00  movss   xmm9, cs:flt_7FF91E7451E8
00007FF91DFCD4FC  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
00007FF91DFCD500  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFCD504  F3 0F 11 BB 30 2F 00 00     movss   dword ptr [rbx+2F30h], xmm7
00007FF91DFCD50C  F3 0F 11 83 D0 2E 00 00     movss   dword ptr [rbx+2ED0h], xmm0
00007FF91DFCD514  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFCD518  F3 0F 59 BB A0 32 00 00     mulss   xmm7, dword ptr [rbx+32A0h]
00007FF91DFCD520  F3 0F 10 8B 20 31 00 00     movss   xmm1, dword ptr [rbx+3120h]
00007FF91DFCD528  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCD52C  F3 0F 59 F9                 mulss   xmm7, xmm1
00007FF91DFCD530  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFCD534  F3 0F 10 83 20 2F 00 00     movss   xmm0, dword ptr [rbx+2F20h]
00007FF91DFCD53C  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
00007FF91DFCD545  F3 41 0F 58 FB              addss   xmm7, xmm11
00007FF91DFCD54A  76 1B                       jbe     short loc_7FF91DFCD567
00007FF91DFCD54C  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCD551  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFCD555  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCD558  E8 7B 1F 38 00              call    fmodf
00007FF91DFCD55D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCD560  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCD565  EB 1F                       jmp     short loc_7FF91DFCD586
00007FF91DFCD567  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFCD56B  73 19                       jnb     short loc_7FF91DFCD586
00007FF91DFCD56D  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCD572  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFCD576  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCD579  E8 5A 1F 38 00              call    fmodf
00007FF91DFCD57E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCD581  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCD586  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
00007FF91DFCD58F  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCD592  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFCD596  F3 44 0F 10 83 60 2F 00 00  movss   xmm8, dword ptr [rbx+2F60h]
00007FF91DFCD59F  F3 0F 11 B3 10 2F 00 00     movss   dword ptr [rbx+2F10h], xmm6
00007FF91DFCD5A7  F3 0F 59 BB 90 32 00 00     mulss   xmm7, dword ptr [rbx+3290h]
00007FF91DFCD5AF  F3 0F 58 83 00 32 00 00     addss   xmm0, dword ptr [rbx+3200h]
00007FF91DFCD5B7  F3 0F 11 BB 90 2E 00 00     movss   dword ptr [rbx+2E90h], xmm7
00007FF91DFCD5BF  73 0A                       jnb     short loc_7FF91DFCD5CB
00007FF91DFCD5C1  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFCD5C5  76 04                       jbe     short loc_7FF91DFCD5CB
00007FF91DFCD5C7  45 0F 28 C3                 movaps  xmm8, xmm11
00007FF91DFCD5CB  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFCD5CF  76 15                       jbe     short loc_7FF91DFCD5E6
00007FF91DFCD5D1  F3 41 0F 58 C5              addss   xmm0, xmm13; X
00007FF91DFCD5D6  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFCD5DA  E8 F9 1E 38 00              call    fmodf
00007FF91DFCD5DF  F3 41 0F 5C C5              subss   xmm0, xmm13
00007FF91DFCD5E4  EB 19                       jmp     short loc_7FF91DFCD5FF
00007FF91DFCD5E6  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFCD5EA  73 13                       jnb     short loc_7FF91DFCD5FF
00007FF91DFCD5EC  F3 41 0F 5C C5              subss   xmm0, xmm13; X
00007FF91DFCD5F1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFCD5F5  E8 DE 1E 38 00              call    fmodf
00007FF91DFCD5FA  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCD5FF  F3 44 0F 10 1D B8 81 77 00  movss   xmm11, dword ptr cs:xmmword_7FF91E7457C0
00007FF91DFCD608  F3 44 0F 11 83 50 2F 00 00  movss   dword ptr [rbx+2F50h], xmm8
00007FF91DFCD611  F3 0F 59 83 40 32 00 00     mulss   xmm0, dword ptr [rbx+3240h]
00007FF91DFCD619  F3 44 0F 59 83 80 32 00 00  mulss   xmm8, dword ptr [rbx+3280h]
00007FF91DFCD622  F3 0F 58 83 C0 32 00 00     addss   xmm0, dword ptr [rbx+32C0h]
00007FF91DFCD62A  F3 0F 11 83 A0 2F 00 00     movss   dword ptr [rbx+2FA0h], xmm0
00007FF91DFCD632  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFCD636  F3 44 0F 11 83 F0 2F 00 00  movss   dword ptr [rbx+2FF0h], xmm8
00007FF91DFCD63F  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFCD643  F3 44 0F 58 83 20 32 00 00  addss   xmm8, dword ptr [rbx+3220h]
00007FF91DFCD64C  F3 0F 11 83 B0 2F 00 00     movss   dword ptr [rbx+2FB0h], xmm0
00007FF91DFCD654  45 0F 2F C5                 comiss  xmm8, xmm13
00007FF91DFCD658  76 1D                       jbe     short loc_7FF91DFCD677
00007FF91DFCD65A  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFCD65F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFCD663  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFCD667  E8 6C 1E 38 00              call    fmodf
00007FF91DFCD66C  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFCD670  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFCD675  EB 21                       jmp     short loc_7FF91DFCD698
00007FF91DFCD677  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFCD67B  73 1B                       jnb     short loc_7FF91DFCD698
00007FF91DFCD67D  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFCD682  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFCD686  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFCD68A  E8 49 1E 38 00              call    fmodf
00007FF91DFCD68F  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFCD693  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFCD698  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFCD69B  F3 0F 58 BB 10 32 00 00     addss   xmm7, dword ptr [rbx+3210h]
00007FF91DFCD6A3  41 0F 2F FD                 comiss  xmm7, xmm13
00007FF91DFCD6A7  76 1B                       jbe     short loc_7FF91DFCD6C4
00007FF91DFCD6A9  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFCD6AE  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFCD6B2  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFCD6B5  E8 1E 1E 38 00              call    fmodf
00007FF91DFCD6BA  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFCD6BD  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFCD6C2  EB 1F                       jmp     short loc_7FF91DFCD6E3
00007FF91DFCD6C4  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFCD6C8  73 19                       jnb     short loc_7FF91DFCD6E3
00007FF91DFCD6CA  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFCD6CF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFCD6D3  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFCD6D6  E8 FD 1D 38 00              call    fmodf
00007FF91DFCD6DB  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFCD6DE  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFCD6E3  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFCD6E7  E8 D4 B8 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCD6EC  F3 0F 58 BB D0 32 00 00     addss   xmm7, dword ptr [rbx+32D0h]
00007FF91DFCD6F4  F3 0F 59 83 60 32 00 00     mulss   xmm0, dword ptr [rbx+3260h]
00007FF91DFCD6FC  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFCD700  73 06                       jnb     short loc_7FF91DFCD708
00007FF91DFCD702  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFCD706  EB 06                       jmp     short loc_7FF91DFCD70E
00007FF91DFCD708  76 04                       jbe     short loc_7FF91DFCD70E
00007FF91DFCD70A  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFCD70E  F3 0F 58 B3 30 32 00 00     addss   xmm6, dword ptr [rbx+3230h]
00007FF91DFCD716  F3 0F 11 83 D0 2F 00 00     movss   dword ptr [rbx+2FD0h], xmm0
00007FF91DFCD71E  F3 0F 11 BB 30 30 00 00     movss   dword ptr [rbx+3030h], xmm7
00007FF91DFCD726  F3 0F 59 BB 50 32 00 00     mulss   xmm7, dword ptr [rbx+3250h]
00007FF91DFCD72E  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFCD732  F3 0F 58 BB E0 32 00 00     addss   xmm7, dword ptr [rbx+32E0h]
00007FF91DFCD73A  76 1B                       jbe     short loc_7FF91DFCD757
00007FF91DFCD73C  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCD741  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFCD745  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCD748  E8 8B 1D 38 00              call    fmodf
00007FF91DFCD74D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCD750  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCD755  EB 1F                       jmp     short loc_7FF91DFCD776
00007FF91DFCD757  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFCD75B  73 19                       jnb     short loc_7FF91DFCD776
00007FF91DFCD75D  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCD762  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFCD766  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCD769  E8 6A 1D 38 00              call    fmodf
00007FF91DFCD76E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCD771  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCD776  0F 54 35 13 80 77 00        andps   xmm6, cs:xmmword_7FF91E745790
00007FF91DFCD77D  F3 0F 11 BB C0 2F 00 00     movss   dword ptr [rbx+2FC0h], xmm7
00007FF91DFCD785  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFCD788  F3 0F 10 9B 00 31 00 00     movss   xmm3, dword ptr [rbx+3100h]
00007FF91DFCD790  0F 28 D6                    movaps  xmm2, xmm6
00007FF91DFCD793  F3 0F 59 93 90 31 00 00     mulss   xmm2, dword ptr [rbx+3190h]
00007FF91DFCD79B  F3 0F 59 9B F0 2F 00 00     mulss   xmm3, dword ptr [rbx+2FF0h]
00007FF91DFCD7A3  F3 0F 58 93 80 31 00 00     addss   xmm2, dword ptr [rbx+3180h]
00007FF91DFCD7AB  F3 0F 10 8B F0 30 00 00     movss   xmm1, dword ptr [rbx+30F0h]
00007FF91DFCD7B3  F3 0F 59 8B B0 2F 00 00     mulss   xmm1, dword ptr [rbx+2FB0h]
00007FF91DFCD7BB  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFCD7BF  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFCD7C2  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFCD7C6  F3 0F 59 83 A0 31 00 00     mulss   xmm0, dword ptr [rbx+31A0h]
00007FF91DFCD7CE  F3 0F 59 F4                 mulss   xmm6, xmm4
00007FF91DFCD7D2  F3 0F 59 A3 B0 31 00 00     mulss   xmm4, dword ptr [rbx+31B0h]
00007FF91DFCD7DA  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCD7DE  F3 0F 59 B3 C0 31 00 00     mulss   xmm6, dword ptr [rbx+31C0h]
00007FF91DFCD7E6  F3 0F 10 83 E0 30 00 00     movss   xmm0, dword ptr [rbx+30E0h]
00007FF91DFCD7EE  F3 0F 59 83 A0 2F 00 00     mulss   xmm0, dword ptr [rbx+2FA0h]
00007FF91DFCD7F6  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFCD7FA  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCD7FE  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFCD802  F3 0F 10 A3 C0 30 00 00     movss   xmm4, dword ptr [rbx+30C0h]
00007FF91DFCD80A  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCD80E  F3 0F 58 B3 D0 31 00 00     addss   xmm6, dword ptr [rbx+31D0h]
00007FF91DFCD816  F3 0F 59 B3 70 32 00 00     mulss   xmm6, dword ptr [rbx+3270h]
00007FF91DFCD81E  F3 0F 11 B3 E0 2F 00 00     movss   dword ptr [rbx+2FE0h], xmm6
00007FF91DFCD826  F3 0F 59 A3 D0 2F 00 00     mulss   xmm4, dword ptr [rbx+2FD0h]
00007FF91DFCD82E  F3 0F 10 8B A0 30 00 00     movss   xmm1, dword ptr [rbx+30A0h]
00007FF91DFCD836  F3 0F 10 83 D0 30 00 00     movss   xmm0, dword ptr [rbx+30D0h]
00007FF91DFCD83E  F3 0F 59 83 C0 2F 00 00     mulss   xmm0, dword ptr [rbx+2FC0h]
00007FF91DFCD846  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCD84A  F3 0F 10 93 30 31 00 00     movss   xmm2, dword ptr [rbx+3130h]
00007FF91DFCD852  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFCD855  F3 0F 59 9B D0 2E 00 00     mulss   xmm3, dword ptr [rbx+2ED0h]
00007FF91DFCD85D  F3 0F 59 B3 B0 30 00 00     mulss   xmm6, dword ptr [rbx+30B0h]
00007FF91DFCD865  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCD869  F3 0F 10 83 10 31 00 00     movss   xmm0, dword ptr [rbx+3110h]
00007FF91DFCD871  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFCD875  F3 0F 59 83 90 2E 00 00     mulss   xmm0, dword ptr [rbx+2E90h]
00007FF91DFCD87D  F3 0F 58 E6                 addss   xmm4, xmm6
00007FF91DFCD881  F3 41 0F 58 DD              addss   xmm3, xmm13
00007FF91DFCD886  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCD88A  F3 0F 11 9B 00 30 00 00     movss   dword ptr [rbx+3000h], xmm3
00007FF91DFCD892  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCD896  F3 0F 11 A3 20 30 00 00     movss   dword ptr [rbx+3020h], xmm4
00007FF91DFCD89E  F3 0F 10 8B 40 31 00 00     movss   xmm1, dword ptr [rbx+3140h]
00007FF91DFCD8A6  F3 0F 59 8B B0 2E 00 00     mulss   xmm1, dword ptr [rbx+2EB0h]
00007FF91DFCD8AE  F3 0F 10 83 50 31 00 00     movss   xmm0, dword ptr [rbx+3150h]
00007FF91DFCD8B6  F3 0F 59 83 C0 2E 00 00     mulss   xmm0, dword ptr [rbx+2EC0h]
00007FF91DFCD8BE  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFCD8C2  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCD8C6  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCD8CA  F3 0F 11 8B 10 30 00 00     movss   dword ptr [rbx+3010h], xmm1
00007FF91DFCD8D2  F3 0F 10 83 20 30 00 00     movss   xmm0, dword ptr [rbx+3020h]
00007FF91DFCD8DA  8B 83 30 30 00 00           mov     eax, [rbx+3030h]
00007FF91DFCD8E0  89 83 F0 32 00 00           mov     [rbx+32F0h], eax
00007FF91DFCD8E6  F3 0F 11 83 00 33 00 00     movss   dword ptr [rbx+3300h], xmm0
00007FF91DFCD8EE  44 0F 2F B3 30 30 00 00     comiss  xmm14, dword ptr [rbx+3030h]
00007FF91DFCD8F6  F3 0F 10 8B 40 2B 00 00     movss   xmm1, dword ptr [rbx+2B40h]
00007FF91DFCD8FE  F3 0F 10 93 10 33 00 00     movss   xmm2, dword ptr [rbx+3310h]
00007FF91DFCD906  73 06                       jnb     short loc_7FF91DFCD90E
00007FF91DFCD908  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFCD90C  EB 03                       jmp     short loc_7FF91DFCD911
00007FF91DFCD90E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCD911  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFCD915  75 04                       jnz     short loc_7FF91DFCD91B
00007FF91DFCD917  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFCD91B  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFCD91F  F3 0F 11 8B 20 33 00 00     movss   dword ptr [rbx+3320h], xmm1
00007FF91DFCD927  8B 83 30 33 00 00           mov     eax, [rbx+3330h]
00007FF91DFCD92D  89 83 40 33 00 00           mov     [rbx+3340h], eax
00007FF91DFCD933  8B 83 60 33 00 00           mov     eax, [rbx+3360h]
00007FF91DFCD939  89 83 70 33 00 00           mov     [rbx+3370h], eax
00007FF91DFCD93F  8B 83 50 33 00 00           mov     eax, [rbx+3350h]
00007FF91DFCD945  89 83 60 33 00 00           mov     [rbx+3360h], eax
00007FF91DFCD94B  8B 83 80 33 00 00           mov     eax, [rbx+3380h]
00007FF91DFCD951  89 83 90 33 00 00           mov     [rbx+3390h], eax
00007FF91DFCD957  8B 83 B0 33 00 00           mov     eax, [rbx+33B0h]
00007FF91DFCD95D  89 83 C0 33 00 00           mov     [rbx+33C0h], eax
00007FF91DFCD963  F3 0F 10 83 60 34 00 00     movss   xmm0, dword ptr [rbx+3460h]
00007FF91DFCD96B  F3 0F 58 8B 40 34 00 00     addss   xmm1, dword ptr [rbx+3440h]
00007FF91DFCD973  F3 0F 59 83 70 33 00 00     mulss   xmm0, dword ptr [rbx+3370h]
00007FF91DFCD97B  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFCD97F  F3 0F 58 83 40 33 00 00     addss   xmm0, dword ptr [rbx+3340h]
00007FF91DFCD987  73 06                       jnb     short loc_7FF91DFCD98F
00007FF91DFCD989  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFCD98D  EB 04                       jmp     short loc_7FF91DFCD993
00007FF91DFCD98F  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFCD993  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFCD997  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFCD99C  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFCD99F  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFCD9A3  F3 0F 11 BB 50 33 00 00     movss   dword ptr [rbx+3350h], xmm7
00007FF91DFCD9AB  0F 28 E7                    movaps  xmm4, xmm7
00007FF91DFCD9AE  F3 0F 10 9B 30 34 00 00     movss   xmm3, dword ptr [rbx+3430h]
00007FF91DFCD9B6  F3 0F 10 93 80 34 00 00     movss   xmm2, dword ptr [rbx+3480h]
00007FF91DFCD9BE  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCD9C1  F3 0F 59 8B A0 34 00 00     mulss   xmm1, dword ptr [rbx+34A0h]
00007FF91DFCD9C9  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCD9CC  F3 0F 58 A3 50 34 00 00     addss   xmm4, dword ptr [rbx+3450h]
00007FF91DFCD9D4  F3 0F 5C BB 60 33 00 00     subss   xmm7, dword ptr [rbx+3360h]
00007FF91DFCD9DC  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCD9E0  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFCD9E4  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFCD9E8  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCD9EC  F3 0F 11 8B A0 33 00 00     movss   dword ptr [rbx+33A0h], xmm1
00007FF91DFCD9F4  72 06                       jb      short loc_7FF91DFCD9FC
00007FF91DFCD9F6  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFCD9FA  EB 03                       jmp     short loc_7FF91DFCD9FF
00007FF91DFCD9FC  0F 57 F6                    xorps   xmm6, xmm6
00007FF91DFCD9FF  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFCDA03  F3 0F 10 83 00 34 00 00     movss   xmm0, dword ptr [rbx+3400h]
00007FF91DFCDA0B  73 03                       jnb     short loc_7FF91DFCDA10
00007FF91DFCDA0D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFCDA10  F3 0F 59 83 80 34 00 00     mulss   xmm0, dword ptr [rbx+3480h]
00007FF91DFCDA18  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFCDA1B  F3 0F 10 93 F0 33 00 00     movss   xmm2, dword ptr [rbx+33F0h]
00007FF91DFCDA23  F3 44 0F 10 0D 30 75 77 00  movss   xmm9, cs:dword_7FF91E744F5C
00007FF91DFCDA2C  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFCDA30  F3 0F 11 B3 60 33 00 00     movss   dword ptr [rbx+3360h], xmm6
00007FF91DFCDA38  F3 0F 10 8B 90 34 00 00     movss   xmm1, dword ptr [rbx+3490h]
00007FF91DFCDA40  F3 0F 10 BB 10 34 00 00     movss   xmm7, dword ptr [rbx+3410h]
00007FF91DFCDA48  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCDA4B  F3 0F 10 A3 90 33 00 00     movss   xmm4, dword ptr [rbx+3390h]
00007FF91DFCDA53  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFCDA57  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFCDA5C  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCDA60  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFCDA65  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFCDA69  F3 0F 59 FE                 mulss   xmm7, xmm6
00007FF91DFCDA6D  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFCDA71  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCDA75  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFCDA79  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCDA7C  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFCDA80  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFCDA84  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFCDA88  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFCDA8C  76 0B                       jbe     short loc_7FF91DFCDA99
00007FF91DFCDA8E  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFCDA91  F3 0F 58 9B A0 33 00 00     addss   xmm3, dword ptr [rbx+33A0h]
00007FF91DFCDA99  F3 0F 10 83 80 34 00 00     movss   xmm0, dword ptr [rbx+3480h]
00007FF91DFCDAA1  F3 0F 10 A3 40 33 00 00     movss   xmm4, dword ptr [rbx+3340h]
00007FF91DFCDAA9  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFCDAAD  F3 0F 11 83 80 33 00 00     movss   dword ptr [rbx+3380h], xmm0
00007FF91DFCDAB5  F3 0F 10 8B C0 33 00 00     movss   xmm1, dword ptr [rbx+33C0h]
00007FF91DFCDABD  F3 0F 10 9B 20 34 00 00     movss   xmm3, dword ptr [rbx+3420h]
00007FF91DFCDAC5  F3 0F 59 AB 70 34 00 00     mulss   xmm5, dword ptr [rbx+3470h]
00007FF91DFCDACD  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFCDAD2  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFCDAD6  F3 0F 10 83 B0 34 00 00     movss   xmm0, dword ptr [rbx+34B0h]
00007FF91DFCDADE  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFCDAE3  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFCDAE6  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCDAEA  F3 0F 58 EE                 addss   xmm5, xmm6
00007FF91DFCDAEE  F3 0F 59 D7                 mulss   xmm2, xmm7
00007FF91DFCDAF2  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFCDAF6  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFCDAFA  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCDAFE  F3 0F 11 93 B0 33 00 00     movss   dword ptr [rbx+33B0h], xmm2
00007FF91DFCDB06  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFCDB0B  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFCDB10  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFCDB14  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFCDB18  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFCDB1C  F3 0F 11 9B 30 33 00 00     movss   dword ptr [rbx+3330h], xmm3
00007FF91DFCDB24  F3 0F 59 9B C0 34 00 00     mulss   xmm3, dword ptr [rbx+34C0h]
00007FF91DFCDB2C  F3 0F 59 9B D0 34 00 00     mulss   xmm3, dword ptr [rbx+34D0h]
00007FF91DFCDB34  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCDB37  F3 0F 59 83 E0 34 00 00     mulss   xmm0, dword ptr [rbx+34E0h]
00007FF91DFCDB3F  F3 0F 11 9B D0 33 00 00     movss   dword ptr [rbx+33D0h], xmm3
00007FF91DFCDB47  F3 0F 11 83 E0 33 00 00     movss   dword ptr [rbx+33E0h], xmm0
00007FF91DFCDB4F  44 0F 2F B3 30 30 00 00     comiss  xmm14, dword ptr [rbx+3030h]
00007FF91DFCDB57  F3 0F 10 8B 40 2B 00 00     movss   xmm1, dword ptr [rbx+2B40h]
00007FF91DFCDB5F  F3 0F 10 93 F0 34 00 00     movss   xmm2, dword ptr [rbx+34F0h]
00007FF91DFCDB67  73 06                       jnb     short loc_7FF91DFCDB6F
00007FF91DFCDB69  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFCDB6D  EB 03                       jmp     short loc_7FF91DFCDB72
00007FF91DFCDB6F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCDB72  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFCDB76  75 04                       jnz     short loc_7FF91DFCDB7C
00007FF91DFCDB78  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFCDB7C  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFCDB80  F3 0F 11 8B 00 35 00 00     movss   dword ptr [rbx+3500h], xmm1
00007FF91DFCDB88  8B 83 10 35 00 00           mov     eax, [rbx+3510h]
00007FF91DFCDB8E  89 83 20 35 00 00           mov     [rbx+3520h], eax
00007FF91DFCDB94  8B 83 40 35 00 00           mov     eax, [rbx+3540h]
00007FF91DFCDB9A  89 83 50 35 00 00           mov     [rbx+3550h], eax
00007FF91DFCDBA0  8B 83 30 35 00 00           mov     eax, [rbx+3530h]
00007FF91DFCDBA6  89 83 40 35 00 00           mov     [rbx+3540h], eax
00007FF91DFCDBAC  8B 83 60 35 00 00           mov     eax, [rbx+3560h]
00007FF91DFCDBB2  89 83 70 35 00 00           mov     [rbx+3570h], eax
00007FF91DFCDBB8  8B 83 90 35 00 00           mov     eax, [rbx+3590h]
00007FF91DFCDBBE  89 83 A0 35 00 00           mov     [rbx+35A0h], eax
00007FF91DFCDBC4  F3 0F 10 83 40 36 00 00     movss   xmm0, dword ptr [rbx+3640h]
00007FF91DFCDBCC  F3 0F 58 8B 20 36 00 00     addss   xmm1, dword ptr [rbx+3620h]
00007FF91DFCDBD4  F3 0F 59 83 50 35 00 00     mulss   xmm0, dword ptr [rbx+3550h]
00007FF91DFCDBDC  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFCDBE0  F3 0F 58 83 20 35 00 00     addss   xmm0, dword ptr [rbx+3520h]
00007FF91DFCDBE8  73 06                       jnb     short loc_7FF91DFCDBF0
00007FF91DFCDBEA  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFCDBEE  EB 04                       jmp     short loc_7FF91DFCDBF4
00007FF91DFCDBF0  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFCDBF4  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFCDBF8  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFCDBFD  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFCDC00  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFCDC04  F3 0F 11 B3 30 35 00 00     movss   dword ptr [rbx+3530h], xmm6
00007FF91DFCDC0C  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFCDC0F  F3 0F 10 9B 10 36 00 00     movss   xmm3, dword ptr [rbx+3610h]
00007FF91DFCDC17  F3 0F 10 93 60 36 00 00     movss   xmm2, dword ptr [rbx+3660h]
00007FF91DFCDC1F  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCDC22  F3 0F 59 8B 80 36 00 00     mulss   xmm1, dword ptr [rbx+3680h]
00007FF91DFCDC2A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCDC2D  F3 0F 58 A3 30 36 00 00     addss   xmm4, dword ptr [rbx+3630h]
00007FF91DFCDC35  F3 0F 5C B3 40 35 00 00     subss   xmm6, dword ptr [rbx+3540h]
00007FF91DFCDC3D  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCDC41  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFCDC45  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFCDC49  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCDC4D  F3 0F 11 8B 80 35 00 00     movss   dword ptr [rbx+3580h], xmm1
00007FF91DFCDC55  72 06                       jb      short loc_7FF91DFCDC5D
00007FF91DFCDC57  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFCDC5B  EB 03                       jmp     short loc_7FF91DFCDC60
00007FF91DFCDC5D  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFCDC60  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFCDC64  F3 0F 10 83 E0 35 00 00     movss   xmm0, dword ptr [rbx+35E0h]
00007FF91DFCDC6C  73 03                       jnb     short loc_7FF91DFCDC71
00007FF91DFCDC6E  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFCDC71  F3 0F 59 83 60 36 00 00     mulss   xmm0, dword ptr [rbx+3660h]
00007FF91DFCDC79  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFCDC7C  F3 0F 10 93 D0 35 00 00     movss   xmm2, dword ptr [rbx+35D0h]
00007FF91DFCDC84  F3 0F 11 BB 40 35 00 00     movss   dword ptr [rbx+3540h], xmm7
00007FF91DFCDC8C  F3 0F 10 8B 70 36 00 00     movss   xmm1, dword ptr [rbx+3670h]
00007FF91DFCDC94  F3 0F 10 B3 F0 35 00 00     movss   xmm6, dword ptr [rbx+35F0h]
00007FF91DFCDC9C  F3 0F 10 A3 70 35 00 00     movss   xmm4, dword ptr [rbx+3570h]
00007FF91DFCDCA4  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFCDCA8  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCDCAB  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFCDCAF  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFCDCB4  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCDCB8  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFCDCBD  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFCDCC1  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFCDCC5  F3 0F 5C C7                 subss   xmm0, xmm7
00007FF91DFCDCC9  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCDCCD  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFCDCD1  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCDCD4  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFCDCD8  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFCDCDC  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFCDCE0  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFCDCE4  76 0B                       jbe     short loc_7FF91DFCDCF1
00007FF91DFCDCE6  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFCDCE9  F3 0F 58 9B 80 35 00 00     addss   xmm3, dword ptr [rbx+3580h]
00007FF91DFCDCF1  F3 0F 10 A3 20 35 00 00     movss   xmm4, dword ptr [rbx+3520h]
00007FF91DFCDCF9  F3 0F 10 83 60 36 00 00     movss   xmm0, dword ptr [rbx+3660h]
00007FF91DFCDD01  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFCDD05  F3 0F 11 83 60 35 00 00     movss   dword ptr [rbx+3560h], xmm0
00007FF91DFCDD0D  F3 0F 59 AB 50 36 00 00     mulss   xmm5, dword ptr [rbx+3650h]
00007FF91DFCDD15  F3 0F 10 8B A0 35 00 00     movss   xmm1, dword ptr [rbx+35A0h]
00007FF91DFCDD1D  F3 0F 10 9B 00 36 00 00     movss   xmm3, dword ptr [rbx+3600h]
00007FF91DFCDD25  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFCDD29  F3 0F 10 83 90 36 00 00     movss   xmm0, dword ptr [rbx+3690h]
00007FF91DFCDD31  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFCDD34  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFCDD39  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCDD3D  F3 0F 58 EF                 addss   xmm5, xmm7
00007FF91DFCDD41  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFCDD46  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCDD4A  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFCDD4E  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFCDD52  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCDD56  F3 0F 11 93 90 35 00 00     movss   dword ptr [rbx+3590h], xmm2
00007FF91DFCDD5E  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFCDD63  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFCDD68  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFCDD6C  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFCDD70  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFCDD74  F3 0F 11 9B 10 35 00 00     movss   dword ptr [rbx+3510h], xmm3
00007FF91DFCDD7C  F3 0F 59 9B A0 36 00 00     mulss   xmm3, dword ptr [rbx+36A0h]
00007FF91DFCDD84  F3 0F 59 9B B0 36 00 00     mulss   xmm3, dword ptr [rbx+36B0h]
00007FF91DFCDD8C  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCDD8F  F3 0F 59 83 C0 36 00 00     mulss   xmm0, dword ptr [rbx+36C0h]
00007FF91DFCDD97  F3 0F 11 9B B0 35 00 00     movss   dword ptr [rbx+35B0h], xmm3
00007FF91DFCDD9F  F3 0F 11 83 C0 35 00 00     movss   dword ptr [rbx+35C0h], xmm0
00007FF91DFCDDA7  8B 83 D0 36 00 00           mov     eax, [rbx+36D0h]
00007FF91DFCDDAD  89 83 E0 36 00 00           mov     [rbx+36E0h], eax
00007FF91DFCDDB3  8B 83 F0 36 00 00           mov     eax, [rbx+36F0h]
00007FF91DFCDDB9  89 83 00 37 00 00           mov     [rbx+3700h], eax
00007FF91DFCDDBF  F3 0F 10 83 00 2C 00 00     movss   xmm0, dword ptr [rbx+2C00h]
00007FF91DFCDDC7  F3 44 0F 10 83 80 2C 00 00  movss   xmm8, dword ptr [rbx+2C80h]
00007FF91DFCDDD0  8B 83 30 37 00 00           mov     eax, [rbx+3730h]
00007FF91DFCDDD6  89 83 40 37 00 00           mov     [rbx+3740h], eax
00007FF91DFCDDDC  F3 0F 59 83 10 37 00 00     mulss   xmm0, dword ptr [rbx+3710h]
00007FF91DFCDDE4  F3 44 0F 59 83 20 37 00 00  mulss   xmm8, dword ptr [rbx+3720h]
00007FF91DFCDDED  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFCDDF2  F3 44 0F 11 83 30 37 00 00  movss   dword ptr [rbx+3730h], xmm8
00007FF91DFCDDFB  F3 0F 10 BB 10 30 00 00     movss   xmm7, dword ptr [rbx+3010h]
00007FF91DFCDE03  F3 0F 10 8B D0 33 00 00     movss   xmm1, dword ptr [rbx+33D0h]
00007FF91DFCDE0B  F3 0F 10 93 B0 35 00 00     movss   xmm2, dword ptr [rbx+35B0h]
00007FF91DFCDE13  F3 0F 10 83 00 2C 00 00     movss   xmm0, dword ptr [rbx+2C00h]
00007FF91DFCDE1B  8B 83 F0 36 00 00           mov     eax, [rbx+36F0h]
00007FF91DFCDE21  89 83 70 37 00 00           mov     [rbx+3770h], eax
00007FF91DFCDE27  F3 0F 11 83 80 37 00 00     movss   dword ptr [rbx+3780h], xmm0
00007FF91DFCDE2F  F3 0F 10 A3 C0 38 00 00     movss   xmm4, dword ptr [rbx+38C0h]
00007FF91DFCDE37  F3 0F 11 8B 50 37 00 00     movss   dword ptr [rbx+3750h], xmm1
00007FF91DFCDE3F  F3 0F 11 93 60 37 00 00     movss   dword ptr [rbx+3760h], xmm2
00007FF91DFCDE47  F3 0F 10 AB A0 38 00 00     movss   xmm5, dword ptr [rbx+38A0h]
00007FF91DFCDE4F  F3 0F 59 FC                 mulss   xmm7, xmm4
00007FF91DFCDE53  F3 0F 59 A3 20 30 00 00     mulss   xmm4, dword ptr [rbx+3020h]
00007FF91DFCDE5B  F3 0F 11 A3 90 37 00 00     movss   dword ptr [rbx+3790h], xmm4
00007FF91DFCDE63  F3 0F 10 8B 20 38 00 00     movss   xmm1, dword ptr [rbx+3820h]
00007FF91DFCDE6B  F3 0F 10 93 20 39 00 00     movss   xmm2, dword ptr [rbx+3920h]
00007FF91DFCDE73  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFCDE76  F3 0F 59 BB D0 38 00 00     mulss   xmm7, dword ptr [rbx+38D0h]
00007FF91DFCDE7E  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCDE81  F3 0F 10 B3 E0 38 00 00     movss   xmm6, dword ptr [rbx+38E0h]
00007FF91DFCDE89  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCDE8D  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFCDE91  F3 0F 59 EC                 mulss   xmm5, xmm4
00007FF91DFCDE95  F3 0F 59 AB B0 38 00 00     mulss   xmm5, dword ptr [rbx+38B0h]
00007FF91DFCDE9D  F3 0F 11 AB B0 37 00 00     movss   dword ptr [rbx+37B0h], xmm5
00007FF91DFCDEA5  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFCDEA9  F3 0F 59 9B 70 37 00 00     mulss   xmm3, dword ptr [rbx+3770h]
00007FF91DFCDEB1  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCDEB5  F3 0F 10 83 30 38 00 00     movss   xmm0, dword ptr [rbx+3830h]
00007FF91DFCDEBD  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFCDEC1  F3 0F 59 9B 30 39 00 00     mulss   xmm3, dword ptr [rbx+3930h]
00007FF91DFCDEC9  F3 0F 11 9B C0 37 00 00     movss   dword ptr [rbx+37C0h], xmm3
00007FF91DFCDED1  F3 0F 10 8B 00 39 00 00     movss   xmm1, dword ptr [rbx+3900h]
00007FF91DFCDED9  F3 0F 59 8B 60 37 00 00     mulss   xmm1, dword ptr [rbx+3760h]
00007FF91DFCDEE1  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCDEE5  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFCDEE9  F3 0F 10 83 F0 38 00 00     movss   xmm0, dword ptr [rbx+38F0h]
00007FF91DFCDEF1  F3 0F 59 83 50 37 00 00     mulss   xmm0, dword ptr [rbx+3750h]
00007FF91DFCDEF9  F3 0F 10 9B 90 37 00 00     movss   xmm3, dword ptr [rbx+3790h]
00007FF91DFCDF01  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCDF05  F3 0F 10 83 10 38 00 00     movss   xmm0, dword ptr [rbx+3810h]
00007FF91DFCDF0D  F3 0F 59 8B 10 39 00 00     mulss   xmm1, dword ptr [rbx+3910h]
00007FF91DFCDF15  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFCDF19  F3 41 0F 58 C8              addss   xmm1, xmm8
00007FF91DFCDF1E  F3 0F 58 8B 80 38 00 00     addss   xmm1, dword ptr [rbx+3880h]
00007FF91DFCDF26  F3 0F 58 8B 90 38 00 00     addss   xmm1, dword ptr [rbx+3890h]
00007FF91DFCDF2E  F3 0F 11 8B D0 37 00 00     movss   dword ptr [rbx+37D0h], xmm1
00007FF91DFCDF36  F3 0F 11 83 E0 37 00 00     movss   dword ptr [rbx+37E0h], xmm0
00007FF91DFCDF3E  F3 0F 59 9B 50 39 00 00     mulss   xmm3, dword ptr [rbx+3950h]
00007FF91DFCDF46  F3 0F 10 83 50 38 00 00     movss   xmm0, dword ptr [rbx+3850h]
00007FF91DFCDF4E  F3 0F 59 83 50 37 00 00     mulss   xmm0, dword ptr [rbx+3750h]
00007FF91DFCDF56  F3 0F 58 9B 60 39 00 00     addss   xmm3, dword ptr [rbx+3960h]
00007FF91DFCDF5E  F3 0F 10 8B 60 38 00 00     movss   xmm1, dword ptr [rbx+3860h]
00007FF91DFCDF66  F3 0F 59 8B 60 37 00 00     mulss   xmm1, dword ptr [rbx+3760h]
00007FF91DFCDF6E  F3 0F 10 93 B0 37 00 00     movss   xmm2, dword ptr [rbx+37B0h]
00007FF91DFCDF76  F3 0F 59 9B 40 38 00 00     mulss   xmm3, dword ptr [rbx+3840h]
00007FF91DFCDF7E  F3 0F 58 93 80 37 00 00     addss   xmm2, dword ptr [rbx+3780h]
00007FF91DFCDF86  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCDF8A  F3 0F 58 93 C0 37 00 00     addss   xmm2, dword ptr [rbx+37C0h]
00007FF91DFCDF92  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCDF96  F3 0F 58 9B 70 38 00 00     addss   xmm3, dword ptr [rbx+3870h]
00007FF91DFCDF9E  F3 0F 59 9B 40 39 00 00     mulss   xmm3, dword ptr [rbx+3940h]
00007FF91DFCDFA6  F3 0F 11 9B F0 37 00 00     movss   dword ptr [rbx+37F0h], xmm3
00007FF91DFCDFAE  F3 0F 11 93 00 38 00 00     movss   dword ptr [rbx+3800h], xmm2
00007FF91DFCDFB6  F3 0F 10 83 80 39 00 00     movss   xmm0, dword ptr [rbx+3980h]
00007FF91DFCDFBE  8B 83 70 39 00 00           mov     eax, [rbx+3970h]
00007FF91DFCDFC4  89 83 A0 39 00 00           mov     [rbx+39A0h], eax
00007FF91DFCDFCA  F3 0F 11 83 B0 39 00 00     movss   dword ptr [rbx+39B0h], xmm0
00007FF91DFCDFD2  8B 83 90 39 00 00           mov     eax, [rbx+3990h]
00007FF91DFCDFD8  89 83 C0 39 00 00           mov     [rbx+39C0h], eax
00007FF91DFCDFDE  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
00007FF91DFCDFE6  8B 83 E0 39 00 00           mov     eax, [rbx+39E0h]
00007FF91DFCDFEC  89 83 F0 39 00 00           mov     [rbx+39F0h], eax
00007FF91DFCDFF2  F3 0F 10 93 D0 39 00 00     movss   xmm2, dword ptr [rbx+39D0h]
00007FF91DFCDFFA  F3 0F 11 93 E0 39 00 00     movss   dword ptr [rbx+39E0h], xmm2
00007FF91DFCE002  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCE005  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCE008  F3 0F 59 9B 00 3A 00 00     mulss   xmm3, dword ptr [rbx+3A00h]
00007FF91DFCE010  F3 0F 58 9B F0 39 00 00     addss   xmm3, dword ptr [rbx+39F0h]
00007FF91DFCE018  F3 0F 11 9B E0 39 00 00     movss   dword ptr [rbx+39E0h], xmm3
00007FF91DFCE020  F3 0F 59 83 10 3A 00 00     mulss   xmm0, dword ptr [rbx+3A10h]
00007FF91DFCE028  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFCE02C  F3 0F 59 9B 40 3A 00 00     mulss   xmm3, dword ptr [rbx+3A40h]
00007FF91DFCE034  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFCE038  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFCE03B  F3 0F 59 8B 00 3A 00 00     mulss   xmm1, dword ptr [rbx+3A00h]
00007FF91DFCE043  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCE047  F3 0F 11 8B D0 39 00 00     movss   dword ptr [rbx+39D0h], xmm1
00007FF91DFCE04F  F3 0F 59 8B 30 3A 00 00     mulss   xmm1, dword ptr [rbx+3A30h]
00007FF91DFCE057  F3 0F 59 A3 20 3A 00 00     mulss   xmm4, dword ptr [rbx+3A20h]
00007FF91DFCE05F  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCE063  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCE067  F3 0F 11 A3 F0 39 00 00     movss   dword ptr [rbx+39F0h], xmm4
00007FF91DFCE06F  8B 83 20 42 00 00           mov     eax, [rbx+4220h]
00007FF91DFCE075  89 83 30 42 00 00           mov     [rbx+4230h], eax
00007FF91DFCE07B  F3 0F 10 8B 40 42 00 00     movss   xmm1, dword ptr [rbx+4240h]
00007FF91DFCE083  F3 0F 11 8B 50 42 00 00     movss   dword ptr [rbx+4250h], xmm1
00007FF91DFCE08B  F3 0F 59 8B E0 36 00 00     mulss   xmm1, dword ptr [rbx+36E0h]
00007FF91DFCE093  F3 0F 10 83 30 42 00 00     movss   xmm0, dword ptr [rbx+4230h]
00007FF91DFCE09B  F3 0F 59 83 F0 39 00 00     mulss   xmm0, dword ptr [rbx+39F0h]
00007FF91DFCE0A3  F3 0F 11 8B 60 42 00 00     movss   dword ptr [rbx+4260h], xmm1
00007FF91DFCE0AB  F3 0F 11 83 70 42 00 00     movss   dword ptr [rbx+4270h], xmm0
00007FF91DFCE0B3  8B 83 A0 42 00 00           mov     eax, [rbx+42A0h]
00007FF91DFCE0B9  89 83 B0 42 00 00           mov     [rbx+42B0h], eax
00007FF91DFCE0BF  F3 0F 59 8B 80 42 00 00     mulss   xmm1, dword ptr [rbx+4280h]
00007FF91DFCE0C7  F3 0F 59 83 90 42 00 00     mulss   xmm0, dword ptr [rbx+4290h]
00007FF91DFCE0CF  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFCE0D3  F3 0F 11 83 A0 42 00 00     movss   dword ptr [rbx+42A0h], xmm0
00007FF91DFCE0DB  8B 83 C0 42 00 00           mov     eax, [rbx+42C0h]
00007FF91DFCE0E1  89 83 D0 42 00 00           mov     [rbx+42D0h], eax
00007FF91DFCE0E7  8B 83 E0 42 00 00           mov     eax, [rbx+42E0h]
00007FF91DFCE0ED  89 83 F0 42 00 00           mov     [rbx+42F0h], eax
00007FF91DFCE0F3  8B 83 00 43 00 00           mov     eax, [rbx+4300h]
00007FF91DFCE0F9  89 83 10 43 00 00           mov     [rbx+4310h], eax
00007FF91DFCE0FF  8B 83 20 43 00 00           mov     eax, [rbx+4320h]
00007FF91DFCE105  89 83 30 43 00 00           mov     [rbx+4330h], eax
00007FF91DFCE10B  F3 0F 10 8B 50 43 00 00     movss   xmm1, dword ptr [rbx+4350h]
00007FF91DFCE113  F3 0F 10 93 60 43 00 00     movss   xmm2, dword ptr [rbx+4360h]
00007FF91DFCE11B  0F 28 E1                    movaps  xmm4, xmm1
00007FF91DFCE11E  F3 0F 59 A3 C0 42 00 00     mulss   xmm4, dword ptr [rbx+42C0h]
00007FF91DFCE126  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCE129  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCE12D  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFCE131  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFCE135  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFCE138  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFCE13B  F3 0F 59 8B 80 43 00 00     mulss   xmm1, dword ptr [rbx+4380h]
00007FF91DFCE143  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCE147  F3 0F 58 8B 70 43 00 00     addss   xmm1, dword ptr [rbx+4370h]
00007FF91DFCE14F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCE152  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCE156  F3 0F 59 83 90 43 00 00     mulss   xmm0, dword ptr [rbx+4390h]
00007FF91DFCE15E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCE162  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCE165  F3 0F 59 9B A0 43 00 00     mulss   xmm3, dword ptr [rbx+43A0h]
00007FF91DFCE16D  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCE171  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCE175  F3 0F 59 83 B0 43 00 00     mulss   xmm0, dword ptr [rbx+43B0h]
00007FF91DFCE17D  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFCE181  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCE185  76 05                       jbe     short loc_7FF91DFCE18C
00007FF91DFCE187  0F 5A C0                    cvtps2pd xmm0, xmm0
00007FF91DFCE18A  EB 03                       jmp     short loc_7FF91DFCE18F
00007FF91DFCE18C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCE18F  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFCE193  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFCE197  73 04                       jnb     short loc_7FF91DFCE19D
00007FF91DFCE199  44 0F 5A E1                 cvtps2pd xmm12, xmm1
00007FF91DFCE19D  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
00007FF91DFCE1A2  F3 0F 11 83 40 43 00 00     movss   dword ptr [rbx+4340h], xmm0
00007FF91DFCE1AA  8B 83 C0 43 00 00           mov     eax, [rbx+43C0h]
00007FF91DFCE1B0  89 83 D0 43 00 00           mov     [rbx+43D0h], eax
00007FF91DFCE1B6  F3 0F 10 8B E0 43 00 00     movss   xmm1, dword ptr [rbx+43E0h]
00007FF91DFCE1BE  F3 0F 11 8B F0 43 00 00     movss   dword ptr [rbx+43F0h], xmm1
00007FF91DFCE1C6  F3 0F 10 83 00 44 00 00     movss   xmm0, dword ptr [rbx+4400h]
00007FF91DFCE1CE  F3 0F 11 83 10 44 00 00     movss   dword ptr [rbx+4410h], xmm0
00007FF91DFCE1D6  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFCE1DA  F3 0F 59 8B 20 44 00 00     mulss   xmm1, dword ptr [rbx+4420h]
00007FF91DFCE1E2  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCE1E6  F3 0F 11 8B 00 44 00 00     movss   dword ptr [rbx+4400h], xmm1
00007FF91DFCE1EE  F3 0F 10 8B 00 2C 00 00     movss   xmm1, dword ptr [rbx+2C00h]
00007FF91DFCE1F6  F3 0F 10 83 80 2C 00 00     movss   xmm0, dword ptr [rbx+2C80h]
00007FF91DFCE1FE  8B 83 50 44 00 00           mov     eax, [rbx+4450h]
00007FF91DFCE204  89 83 60 44 00 00           mov     [rbx+4460h], eax
00007FF91DFCE20A  F3 0F 59 83 40 44 00 00     mulss   xmm0, dword ptr [rbx+4440h]
00007FF91DFCE212  F3 0F 59 8B 30 44 00 00     mulss   xmm1, dword ptr [rbx+4430h]
00007FF91DFCE21A  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFCE21E  F3 0F 11 83 50 44 00 00     movss   dword ptr [rbx+4450h], xmm0
00007FF91DFCE226  8B 83 70 44 00 00           mov     eax, [rbx+4470h]
00007FF91DFCE22C  89 83 90 44 00 00           mov     [rbx+4490h], eax
00007FF91DFCE232  F3 0F 10 9B 80 44 00 00     movss   xmm3, dword ptr [rbx+4480h]
00007FF91DFCE23A  F3 0F 11 9B A0 44 00 00     movss   dword ptr [rbx+44A0h], xmm3
00007FF91DFCE242  F3 0F 10 8B 90 44 00 00     movss   xmm1, dword ptr [rbx+4490h]
00007FF91DFCE24A  F3 0F 10 93 D0 33 00 00     movss   xmm2, dword ptr [rbx+33D0h]
00007FF91DFCE252  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCE255  F3 0F 59 83 B0 35 00 00     mulss   xmm0, dword ptr [rbx+35B0h]
00007FF91DFCE25D  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFCE261  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFCE265  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCE268  F3 0F 59 8B 00 43 00 00     mulss   xmm1, dword ptr [rbx+4300h]
00007FF91DFCE270  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCE274  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFCE278  F3 0F 5C CB                 subss   xmm1, xmm3
00007FF91DFCE27C  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCE280  F3 0F 11 8B B0 44 00 00     movss   dword ptr [rbx+44B0h], xmm1
00007FF91DFCE288  F3 0F 10 9B 10 30 00 00     movss   xmm3, dword ptr [rbx+3010h]
00007FF91DFCE290  F3 0F 10 83 C0 44 00 00     movss   xmm0, dword ptr [rbx+44C0h]
00007FF91DFCE298  F3 0F 11 83 D0 44 00 00     movss   dword ptr [rbx+44D0h], xmm0
00007FF91DFCE2A0  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCE2A4  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCE2A7  F3 0F 59 8B E0 44 00 00     mulss   xmm1, dword ptr [rbx+44E0h]
00007FF91DFCE2AF  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCE2B3  F3 0F 10 83 00 45 00 00     movss   xmm0, dword ptr [rbx+4500h]
00007FF91DFCE2BB  F3 0F 11 8B C0 44 00 00     movss   dword ptr [rbx+44C0h], xmm1
00007FF91DFCE2C3  F3 0F 59 9B F0 44 00 00     mulss   xmm3, dword ptr [rbx+44F0h]
00007FF91DFCE2CB  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCE2CF  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCE2D3  F3 0F 11 9B D0 44 00 00     movss   dword ptr [rbx+44D0h], xmm3
00007FF91DFCE2DB  F3 0F 10 83 10 45 00 00     movss   xmm0, dword ptr [rbx+4510h]
00007FF91DFCE2E3  F3 0F 10 BB 20 30 00 00     movss   xmm7, dword ptr [rbx+3020h]
00007FF91DFCE2EB  F3 0F 11 83 20 45 00 00     movss   dword ptr [rbx+4520h], xmm0
00007FF91DFCE2F3  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFCE2F7  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFCE2FA  F3 0F 59 8B 30 45 00 00     mulss   xmm1, dword ptr [rbx+4530h]
00007FF91DFCE302  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCE306  F3 0F 10 83 50 45 00 00     movss   xmm0, dword ptr [rbx+4550h]
00007FF91DFCE30E  F3 0F 11 8B 10 45 00 00     movss   dword ptr [rbx+4510h], xmm1
00007FF91DFCE316  F3 0F 59 BB 40 45 00 00     mulss   xmm7, dword ptr [rbx+4540h]
00007FF91DFCE31E  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCE322  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFCE326  F3 0F 11 BB 20 45 00 00     movss   dword ptr [rbx+4520h], xmm7
00007FF91DFCE32E  F3 0F 10 A3 D0 44 00 00     movss   xmm4, dword ptr [rbx+44D0h]
00007FF91DFCE336  F3 0F 10 AB B0 44 00 00     movss   xmm5, dword ptr [rbx+44B0h]
00007FF91DFCE33E  F3 0F 10 B3 50 44 00 00     movss   xmm6, dword ptr [rbx+4450h]
00007FF91DFCE346  F3 44 0F 10 8B E0 42 00 00  movss   xmm9, dword ptr [rbx+42E0h]
00007FF91DFCE34F  8B 83 00 44 00 00           mov     eax, [rbx+4400h]
00007FF91DFCE355  89 83 60 45 00 00           mov     [rbx+4560h], eax
00007FF91DFCE35B  F3 44 0F 11 8B 70 45 00 00  movss   dword ptr [rbx+4570h], xmm9
00007FF91DFCE364  F3 0F 10 83 90 45 00 00     movss   xmm0, dword ptr [rbx+4590h]
00007FF91DFCE36C  F3 0F 10 93 A0 45 00 00     movss   xmm2, dword ptr [rbx+45A0h]
00007FF91DFCE374  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFCE378  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCE37B  F3 0F 59 9B 20 43 00 00     mulss   xmm3, dword ptr [rbx+4320h]
00007FF91DFCE383  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCE387  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCE38A  F3 0F 59 C7                 mulss   xmm0, xmm7
00007FF91DFCE38E  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFCE392  F3 44 0F 5C C0              subss   xmm8, xmm0
00007FF91DFCE397  F3 44 0F 58 C7              addss   xmm8, xmm7
00007FF91DFCE39C  F3 44 0F 59 83 D0 45 00 00  mulss   xmm8, dword ptr [rbx+45D0h]
00007FF91DFCE3A5  F3 0F 10 8B B0 45 00 00     movss   xmm1, dword ptr [rbx+45B0h]
00007FF91DFCE3AD  F3 0F 58 B3 50 46 00 00     addss   xmm6, dword ptr [rbx+4650h]
00007FF91DFCE3B5  F3 44 0F 59 83 E0 45 00 00  mulss   xmm8, dword ptr [rbx+45E0h]
00007FF91DFCE3BE  F3 0F 59 AB F0 45 00 00     mulss   xmm5, dword ptr [rbx+45F0h]
00007FF91DFCE3C6  F3 0F 59 B3 00 46 00 00     mulss   xmm6, dword ptr [rbx+4600h]
00007FF91DFCE3CE  F3 44 0F 59 C9              mulss   xmm9, xmm1
00007FF91DFCE3D3  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFCE3D7  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFCE3DB  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFCE3DF  F3 0F 10 93 30 46 00 00     movss   xmm2, dword ptr [rbx+4630h]
00007FF91DFCE3E7  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCE3EA  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCE3EE  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFCE3F2  F3 44 0F 5C C8              subss   xmm9, xmm0
00007FF91DFCE3F7  F3 0F 10 83 20 46 00 00     movss   xmm0, dword ptr [rbx+4620h]
00007FF91DFCE3FF  F3 0F 58 83 60 45 00 00     addss   xmm0, dword ptr [rbx+4560h]
00007FF91DFCE407  F3 0F 59 9B C0 45 00 00     mulss   xmm3, dword ptr [rbx+45C0h]
00007FF91DFCE40F  F3 0F 59 83 60 46 00 00     mulss   xmm0, dword ptr [rbx+4660h]
00007FF91DFCE417  F3 44 0F 58 CA              addss   xmm9, xmm2
00007FF91DFCE41C  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFCE421  F3 0F 59 83 10 46 00 00     mulss   xmm0, dword ptr [rbx+4610h]
00007FF91DFCE429  F3 44 0F 59 8B 40 46 00 00  mulss   xmm9, dword ptr [rbx+4640h]
00007FF91DFCE432  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFCE437  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFCE43C  F3 45 0F 58 C8              addss   xmm9, xmm8
00007FF91DFCE441  F3 44 0F 11 8B 80 45 00 00  movss   dword ptr [rbx+4580h], xmm9
00007FF91DFCE44A  F3 0F 10 BB 40 43 00 00     movss   xmm7, dword ptr [rbx+4340h]
00007FF91DFCE452  F3 44 0F 10 83 D0 43 00 00  movss   xmm8, dword ptr [rbx+43D0h]
00007FF91DFCE45B  8B 83 A0 46 00 00           mov     eax, [rbx+46A0h]
00007FF91DFCE461  89 83 B0 46 00 00           mov     [rbx+46B0h], eax
00007FF91DFCE467  F3 0F 10 83 90 46 00 00     movss   xmm0, dword ptr [rbx+4690h]
00007FF91DFCE46F  F3 0F 11 83 A0 46 00 00     movss   dword ptr [rbx+46A0h], xmm0
00007FF91DFCE477  44 0F 2E AB E0 46 00 00     ucomiss xmm13, dword ptr [rbx+46E0h]
00007FF91DFCE47F  0F 85 8F 02 00 00           jnz     loc_7FF91DFCE714
00007FF91DFCE485  F3 0F 10 8B 30 47 00 00     movss   xmm1, dword ptr [rbx+4730h]
00007FF91DFCE48D  F3 0F 10 B3 B0 46 00 00     movss   xmm6, dword ptr [rbx+46B0h]
00007FF91DFCE495  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFCE498  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFCE49C  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFCE4A0  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFCE4A4  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFCE4A8  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFCE4AC  F3 0F 11 B3 A0 46 00 00     movss   dword ptr [rbx+46A0h], xmm6
00007FF91DFCE4B4  F3 0F 59 B3 20 47 00 00     mulss   xmm6, dword ptr [rbx+4720h]
00007FF91DFCE4BC  F3 0F 58 B3 C0 46 00 00     addss   xmm6, dword ptr [rbx+46C0h]
00007FF91DFCE4C4  E8 97 A8 FF FF              call    sub_7FF91DFC8D60
00007FF91DFCE4C9  F3 0F 11 83 90 46 00 00     movss   dword ptr [rbx+4690h], xmm0
00007FF91DFCE4D1  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFCE4D5  F3 0F 59 8B 80 47 00 00     mulss   xmm1, dword ptr [rbx+4780h]
00007FF91DFCE4DD  41 0F 28 D5                 movaps  xmm2, xmm13
00007FF91DFCE4E1  F3 41 0F 5C D0              subss   xmm2, xmm8
00007FF91DFCE4E6  F3 0F 58 8B D0 46 00 00     addss   xmm1, dword ptr [rbx+46D0h]
00007FF91DFCE4EE  F3 0F 59 93 40 47 00 00     mulss   xmm2, dword ptr [rbx+4740h]
00007FF91DFCE4F6  F3 0F 11 8B 80 46 00 00     movss   dword ptr [rbx+4680h], xmm1
00007FF91DFCE4FE  F3 44 0F 59 8B 10 47 00 00  mulss   xmm9, dword ptr [rbx+4710h]
00007FF91DFCE507  F3 0F 59 BB F0 46 00 00     mulss   xmm7, dword ptr [rbx+46F0h]
00007FF91DFCE50F  F3 0F 10 83 50 47 00 00     movss   xmm0, dword ptr [rbx+4750h]
00007FF91DFCE517  F3 0F 5D C2                 minss   xmm0, xmm2
00007FF91DFCE51B  F3 44 0F 58 CF              addss   xmm9, xmm7
00007FF91DFCE520  F3 44 0F 58 CE              addss   xmm9, xmm6
00007FF91DFCE525  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFCE52A  F3 44 0F 58 8B 00 47 00 00  addss   xmm9, dword ptr [rbx+4700h]
00007FF91DFCE533  F3 44 0F 5D 8B 60 47 00 00  minss   xmm9, dword ptr [rbx+4760h]
00007FF91DFCE53C  F3 44 0F 5F 8B 70 47 00 00  maxss   xmm9, dword ptr [rbx+4770h]
00007FF91DFCE545  F3 44 0F 59 8B A0 47 00 00  mulss   xmm9, dword ptr [rbx+47A0h]
00007FF91DFCE54E  F3 44 0F 58 8B B0 47 00 00  addss   xmm9, dword ptr [rbx+47B0h]
00007FF91DFCE557  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFCE55B  F3 0F 2C C9                 cvttss2si ecx, xmm1
00007FF91DFCE55F  81 F9 00 00 00 80           cmp     ecx, 80000000h
00007FF91DFCE565  74 1E                       jz      short loc_7FF91DFCE585
00007FF91DFCE567  66 0F 6E C1                 movd    xmm0, ecx
00007FF91DFCE56B  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFCE56E  0F 2E C1                    ucomiss xmm0, xmm1
00007FF91DFCE571  74 12                       jz      short loc_7FF91DFCE585
00007FF91DFCE573  0F 14 C9                    unpcklps xmm1, xmm1
00007FF91DFCE576  0F 50 C1                    movmskps eax, xmm1
00007FF91DFCE579  83 E0 01                    and     eax, 1
00007FF91DFCE57C  2B C8                       sub     ecx, eax
00007FF91DFCE57E  66 0F 6E C9                 movd    xmm1, ecx
00007FF91DFCE582  0F 5B C9                    cvtdq2ps xmm1, xmm1
00007FF91DFCE585  F3 44 0F 5C C9              subss   xmm9, xmm1
00007FF91DFCE58A  0F 28 C1                    movaps  xmm0, xmm1; X
00007FF91DFCE58D  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFCE591  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFCE596  F3 0F 59 35 32 6A 77 00     mulss   xmm6, cs:dword_7FF91E744FD0
00007FF91DFCE59E  E8 9D 11 38 00              call    expf
00007FF91DFCE5A3  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFCE5A6  41 0F 28 D1                 movaps  xmm2, xmm9
00007FF91DFCE5AA  F3 0F 59 93 70 48 00 00     mulss   xmm2, dword ptr [rbx+4870h]
00007FF91DFCE5B2  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFCE5B6  F3 0F 59 8B 50 48 00 00     mulss   xmm1, dword ptr [rbx+4850h]
00007FF91DFCE5BE  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFCE5C2  F3 0F 58 93 60 48 00 00     addss   xmm2, dword ptr [rbx+4860h]
00007FF91DFCE5CA  F3 0F 59 83 30 48 00 00     mulss   xmm0, dword ptr [rbx+4830h]
00007FF91DFCE5D2  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCE5D6  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCE5DA  F3 0F 58 93 40 48 00 00     addss   xmm2, dword ptr [rbx+4840h]
00007FF91DFCE5E2  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCE5E6  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCE5EA  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFCE5EE  F3 0F 59 83 10 48 00 00     mulss   xmm0, dword ptr [rbx+4810h]
00007FF91DFCE5F6  F3 0F 58 93 20 48 00 00     addss   xmm2, dword ptr [rbx+4820h]
00007FF91DFCE5FE  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCE602  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCE606  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFCE60A  F3 0F 59 83 F0 47 00 00     mulss   xmm0, dword ptr [rbx+47F0h]
00007FF91DFCE612  F3 44 0F 59 8B D0 47 00 00  mulss   xmm9, dword ptr [rbx+47D0h]
00007FF91DFCE61B  F3 0F 58 93 00 48 00 00     addss   xmm2, dword ptr [rbx+4800h]
00007FF91DFCE623  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCE627  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCE62B  F3 0F 58 93 E0 47 00 00     addss   xmm2, dword ptr [rbx+47E0h]
00007FF91DFCE633  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCE637  F3 41 0F 58 D1              addss   xmm2, xmm9
00007FF91DFCE63C  F3 41 0F 58 D5              addss   xmm2, xmm13
00007FF91DFCE641  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFCE645  F3 0F 59 A3 C0 47 00 00     mulss   xmm4, dword ptr [rbx+47C0h]
00007FF91DFCE64D  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFCE650  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCE654  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCE657  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFCE65B  F3 44 0F 59 83 10 49 00 00  mulss   xmm8, dword ptr [rbx+4910h]
00007FF91DFCE664  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCE667  F3 0F 59 83 D0 48 00 00     mulss   xmm0, dword ptr [rbx+48D0h]
00007FF91DFCE66F  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFCE672  F3 44 0F 58 83 F0 48 00 00  addss   xmm8, dword ptr [rbx+48F0h]
00007FF91DFCE67B  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCE67F  F3 0F 58 83 B0 48 00 00     addss   xmm0, dword ptr [rbx+48B0h]
00007FF91DFCE687  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCE68B  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFCE690  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFCE695  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCE698  F3 0F 59 8B 90 48 00 00     mulss   xmm1, dword ptr [rbx+4890h]
00007FF91DFCE6A0  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCE6A4  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFCE6A9  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCE6AC  F3 0F 59 83 C0 48 00 00     mulss   xmm0, dword ptr [rbx+48C0h]
00007FF91DFCE6B4  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFCE6B9  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCE6BC  F3 0F 59 8B 00 49 00 00     mulss   xmm1, dword ptr [rbx+4900h]
00007FF91DFCE6C4  F3 0F 59 9B 80 48 00 00     mulss   xmm3, dword ptr [rbx+4880h]
00007FF91DFCE6CC  F3 0F 58 8B E0 48 00 00     addss   xmm1, dword ptr [rbx+48E0h]
00007FF91DFCE6D4  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFCE6D9  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFCE6DD  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCE6E1  F3 0F 58 8B A0 48 00 00     addss   xmm1, dword ptr [rbx+48A0h]
00007FF91DFCE6E9  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFCE6ED  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFCE6F1  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFCE6F6  F3 44 0F 5E C1              divss   xmm8, xmm1
00007FF91DFCE6FB  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFCE6FF  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCE704  F3 44 0F 5E C0              divss   xmm8, xmm0
00007FF91DFCE709  F3 44 0F 11 83 70 46 00 00  movss   dword ptr [rbx+4670h], xmm8
00007FF91DFCE712  EB 09                       jmp     short loc_7FF91DFCE71D
00007FF91DFCE714  F3 44 0F 10 83 70 46 00 00  movss   xmm8, dword ptr [rbx+4670h]
00007FF91DFCE71D  8B 83 80 49 00 00           mov     eax, [rbx+4980h]
00007FF91DFCE723  F3 0F 10 8B A0 42 00 00     movss   xmm1, dword ptr [rbx+42A0h]
00007FF91DFCE72B  F3 44 0F 10 8B 80 46 00 00  movss   xmm9, dword ptr [rbx+4680h]
00007FF91DFCE734  89 83 90 49 00 00           mov     [rbx+4990h], eax
00007FF91DFCE73A  8B 83 70 49 00 00           mov     eax, [rbx+4970h]
00007FF91DFCE740  89 83 80 49 00 00           mov     [rbx+4980h], eax
00007FF91DFCE746  8B 83 60 49 00 00           mov     eax, [rbx+4960h]
00007FF91DFCE74C  89 83 70 49 00 00           mov     [rbx+4970h], eax
00007FF91DFCE752  8B 83 50 49 00 00           mov     eax, [rbx+4950h]
00007FF91DFCE758  89 83 60 49 00 00           mov     [rbx+4960h], eax
00007FF91DFCE75E  8B 83 40 49 00 00           mov     eax, [rbx+4940h]
00007FF91DFCE764  89 83 50 49 00 00           mov     [rbx+4950h], eax
00007FF91DFCE76A  8B 83 30 49 00 00           mov     eax, [rbx+4930h]
00007FF91DFCE770  89 83 40 49 00 00           mov     [rbx+4940h], eax
00007FF91DFCE776  8B 83 20 49 00 00           mov     eax, [rbx+4920h]
00007FF91DFCE77C  89 83 30 49 00 00           mov     [rbx+4930h], eax
00007FF91DFCE782  8B 83 60 4A 00 00           mov     eax, [rbx+4A60h]
00007FF91DFCE788  89 83 70 4A 00 00           mov     [rbx+4A70h], eax
00007FF91DFCE78E  8B 83 50 4A 00 00           mov     eax, [rbx+4A50h]
00007FF91DFCE794  89 83 60 4A 00 00           mov     [rbx+4A60h], eax
00007FF91DFCE79A  8B 83 40 4A 00 00           mov     eax, [rbx+4A40h]
00007FF91DFCE7A0  89 83 50 4A 00 00           mov     [rbx+4A50h], eax
00007FF91DFCE7A6  8B 83 30 4A 00 00           mov     eax, [rbx+4A30h]
00007FF91DFCE7AC  89 83 40 4A 00 00           mov     [rbx+4A40h], eax
00007FF91DFCE7B2  8B 83 20 4A 00 00           mov     eax, [rbx+4A20h]
00007FF91DFCE7B8  89 83 30 4A 00 00           mov     [rbx+4A30h], eax
00007FF91DFCE7BE  8B 83 10 4A 00 00           mov     eax, [rbx+4A10h]
00007FF91DFCE7C4  89 83 20 4A 00 00           mov     [rbx+4A20h], eax
00007FF91DFCE7CA  8B 83 00 4A 00 00           mov     eax, [rbx+4A00h]
00007FF91DFCE7D0  89 83 10 4A 00 00           mov     [rbx+4A10h], eax
00007FF91DFCE7D6  8B 83 E0 4A 00 00           mov     eax, [rbx+4AE0h]
00007FF91DFCE7DC  89 83 F0 4A 00 00           mov     [rbx+4AF0h], eax
00007FF91DFCE7E2  8B 83 D0 4A 00 00           mov     eax, [rbx+4AD0h]
00007FF91DFCE7E8  89 83 E0 4A 00 00           mov     [rbx+4AE0h], eax
00007FF91DFCE7EE  8B 83 C0 4A 00 00           mov     eax, [rbx+4AC0h]
00007FF91DFCE7F4  89 83 D0 4A 00 00           mov     [rbx+4AD0h], eax
00007FF91DFCE7FA  8B 83 B0 4A 00 00           mov     eax, [rbx+4AB0h]
00007FF91DFCE800  89 83 C0 4A 00 00           mov     [rbx+4AC0h], eax
00007FF91DFCE806  8B 83 A0 4A 00 00           mov     eax, [rbx+4AA0h]
00007FF91DFCE80C  89 83 B0 4A 00 00           mov     [rbx+4AB0h], eax
00007FF91DFCE812  8B 83 90 4A 00 00           mov     eax, [rbx+4A90h]
00007FF91DFCE818  89 83 A0 4A 00 00           mov     [rbx+4AA0h], eax
00007FF91DFCE81E  8B 83 80 4A 00 00           mov     eax, [rbx+4A80h]
00007FF91DFCE824  89 83 90 4A 00 00           mov     [rbx+4A90h], eax
00007FF91DFCE82A  8B 83 60 4B 00 00           mov     eax, [rbx+4B60h]
00007FF91DFCE830  89 83 70 4B 00 00           mov     [rbx+4B70h], eax
00007FF91DFCE836  8B 83 50 4B 00 00           mov     eax, [rbx+4B50h]
00007FF91DFCE83C  89 83 60 4B 00 00           mov     [rbx+4B60h], eax
00007FF91DFCE842  8B 83 40 4B 00 00           mov     eax, [rbx+4B40h]
00007FF91DFCE848  89 83 50 4B 00 00           mov     [rbx+4B50h], eax
00007FF91DFCE84E  8B 83 30 4B 00 00           mov     eax, [rbx+4B30h]
00007FF91DFCE854  89 83 40 4B 00 00           mov     [rbx+4B40h], eax
00007FF91DFCE85A  8B 83 20 4B 00 00           mov     eax, [rbx+4B20h]
00007FF91DFCE860  89 83 30 4B 00 00           mov     [rbx+4B30h], eax
00007FF91DFCE866  8B 83 10 4B 00 00           mov     eax, [rbx+4B10h]
00007FF91DFCE86C  89 83 20 4B 00 00           mov     [rbx+4B20h], eax
00007FF91DFCE872  8B 83 00 4B 00 00           mov     eax, [rbx+4B00h]
00007FF91DFCE878  89 83 10 4B 00 00           mov     [rbx+4B10h], eax
00007FF91DFCE87E  8B 83 E0 4B 00 00           mov     eax, [rbx+4BE0h]
00007FF91DFCE884  89 83 F0 4B 00 00           mov     [rbx+4BF0h], eax
00007FF91DFCE88A  8B 83 D0 4B 00 00           mov     eax, [rbx+4BD0h]
00007FF91DFCE890  89 83 E0 4B 00 00           mov     [rbx+4BE0h], eax
00007FF91DFCE896  8B 83 C0 4B 00 00           mov     eax, [rbx+4BC0h]
00007FF91DFCE89C  89 83 D0 4B 00 00           mov     [rbx+4BD0h], eax
00007FF91DFCE8A2  8B 83 B0 4B 00 00           mov     eax, [rbx+4BB0h]
00007FF91DFCE8A8  89 83 C0 4B 00 00           mov     [rbx+4BC0h], eax
00007FF91DFCE8AE  8B 83 A0 4B 00 00           mov     eax, [rbx+4BA0h]
00007FF91DFCE8B4  89 83 B0 4B 00 00           mov     [rbx+4BB0h], eax
00007FF91DFCE8BA  8B 83 90 4B 00 00           mov     eax, [rbx+4B90h]
00007FF91DFCE8C0  89 83 A0 4B 00 00           mov     [rbx+4BA0h], eax
00007FF91DFCE8C6  8B 83 80 4B 00 00           mov     eax, [rbx+4B80h]
00007FF91DFCE8CC  89 83 90 4B 00 00           mov     [rbx+4B90h], eax
00007FF91DFCE8D2  8B 83 00 4C 00 00           mov     eax, [rbx+4C00h]
00007FF91DFCE8D8  89 83 10 4C 00 00           mov     [rbx+4C10h], eax
00007FF91DFCE8DE  F3 0F 10 83 20 4C 00 00     movss   xmm0, dword ptr [rbx+4C20h]
00007FF91DFCE8E6  F3 0F 11 83 30 4C 00 00     movss   dword ptr [rbx+4C30h], xmm0
00007FF91DFCE8EE  44 0F 2E AB 70 4C 00 00     ucomiss xmm13, dword ptr [rbx+4C70h]
00007FF91DFCE8F6  0F 85 49 09 00 00           jnz     loc_7FF91DFCF245
00007FF91DFCE8FC  F3 0F 59 8B C0 4C 00 00     mulss   xmm1, dword ptr [rbx+4CC0h]
00007FF91DFCE904  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFCE908  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFCE90C  41 0F 28 F8                 movaps  xmm7, xmm8
00007FF91DFCE910  F3 0F 59 B3 E0 4C 00 00     mulss   xmm6, dword ptr [rbx+4CE0h]
00007FF91DFCE918  F3 41 0F 59 F8              mulss   xmm7, xmm8
00007FF91DFCE91D  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCE922  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFCE926  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFCE929  F3 0F 59 8B B0 4C 00 00     mulss   xmm1, dword ptr [rbx+4CB0h]
00007FF91DFCE931  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFCE935  E8 26 A4 FF FF              call    sub_7FF91DFC8D60
00007FF91DFCE93A  F3 0F 11 83 20 4C 00 00     movss   dword ptr [rbx+4C20h], xmm0
00007FF91DFCE942  41 0F 28 DD                 movaps  xmm3, xmm13
00007FF91DFCE946  F3 0F 11 B3 00 4C 00 00     movss   dword ptr [rbx+4C00h], xmm6
00007FF91DFCE94E  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFCE952  F3 0F 59 FF                 mulss   xmm7, xmm7
00007FF91DFCE956  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFCE95B  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFCE95F  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFCE964  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFCE968  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFCE96D  F3 0F 5E DF                 divss   xmm3, xmm7
00007FF91DFCE971  F3 0F 11 9B 50 4C 00 00     movss   dword ptr [rbx+4C50h], xmm3
00007FF91DFCE979  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFCE97C  F3 0F 10 8B 00 4C 00 00     movss   xmm1, dword ptr [rbx+4C00h]
00007FF91DFCE984  F3 0F 10 AB 10 4C 00 00     movss   xmm5, dword ptr [rbx+4C10h]
00007FF91DFCE98C  F3 41 0F 59 E1              mulss   xmm4, xmm9
00007FF91DFCE991  F3 0F 11 A3 40 4C 00 00     movss   dword ptr [rbx+4C40h], xmm4
00007FF91DFCE999  F3 0F 59 AB 10 4D 00 00     mulss   xmm5, dword ptr [rbx+4D10h]
00007FF91DFCE9A1  F3 0F 10 93 80 49 00 00     movss   xmm2, dword ptr [rbx+4980h]
00007FF91DFCE9A9  F3 0F 59 8B 20 4D 00 00     mulss   xmm1, dword ptr [rbx+4D20h]
00007FF91DFCE9B1  F3 0F 10 83 90 49 00 00     movss   xmm0, dword ptr [rbx+4990h]
00007FF91DFCE9B9  F3 0F 11 93 F0 49 00 00     movss   dword ptr [rbx+49F0h], xmm2
00007FF91DFCE9C1  F3 0F 59 93 40 4E 00 00     mulss   xmm2, dword ptr [rbx+4E40h]
00007FF91DFCE9C9  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCE9CD  F3 0F 59 83 50 4E 00 00     mulss   xmm0, dword ptr [rbx+4E50h]
00007FF91DFCE9D5  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFCE9D9  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCE9DD  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFCE9E1  F3 0F 5C EA                 subss   xmm5, xmm2
00007FF91DFCE9E5  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCE9E9  73 06                       jnb     short loc_7FF91DFCE9F1
00007FF91DFCE9EB  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCE9EF  EB 05                       jmp     short loc_7FF91DFCE9F6
00007FF91DFCE9F1  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCE9F6  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFCE9F9  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCE9FC  F3 0F 59 83 F0 4C 00 00     mulss   xmm0, dword ptr [rbx+4CF0h]
00007FF91DFCEA04  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCEA08  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCEA0C  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCEA10  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCEA14  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFCEA18  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCEA1C  F3 0F 11 AB A0 49 00 00     movss   dword ptr [rbx+49A0h], xmm5
00007FF91DFCEA24  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCEA27  F3 0F 58 AB 30 49 00 00     addss   xmm5, dword ptr [rbx+4930h]
00007FF91DFCEA2F  F3 0F 10 9B 40 49 00 00     movss   xmm3, dword ptr [rbx+4940h]
00007FF91DFCEA37  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCEA3A  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEA3E  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCEA42  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFCEA46  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFCEA4A  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCEA4E  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCEA52  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEA55  F3 0F 11 A3 B0 49 00 00     movss   dword ptr [rbx+49B0h], xmm4
00007FF91DFCEA5D  F3 0F 10 8B 50 49 00 00     movss   xmm1, dword ptr [rbx+4950h]
00007FF91DFCEA65  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCEA69  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCEA6D  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCEA70  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEA74  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFCEA78  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCEA7C  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFCEA80  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCEA84  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCEA88  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCEA8C  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCEA90  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEA93  F3 0F 11 9B C0 49 00 00     movss   dword ptr [rbx+49C0h], xmm3
00007FF91DFCEA9B  F3 0F 10 AB 60 49 00 00     movss   xmm5, dword ptr [rbx+4960h]
00007FF91DFCEAA3  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCEAA7  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCEAAB  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCEAAE  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEAB2  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCEAB6  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCEABA  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFCEABE  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCEAC2  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCEAC6  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCEACA  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCEACE  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEAD1  F3 0F 11 93 D0 49 00 00     movss   dword ptr [rbx+49D0h], xmm2
00007FF91DFCEAD9  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFCEADD  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCEAE1  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCEAE5  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFCEAEA  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEAED  F3 0F 59 83 70 49 00 00     mulss   xmm0, dword ptr [rbx+4970h]
00007FF91DFCEAF5  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCEAF9  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCEAFD  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEB00  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFCEB04  F3 0F 11 AB E0 49 00 00     movss   dword ptr [rbx+49E0h], xmm5
00007FF91DFCEB0C  F3 0F 10 93 D0 49 00 00     movss   xmm2, dword ptr [rbx+49D0h]
00007FF91DFCEB14  F3 0F 59 93 90 4C 00 00     mulss   xmm2, dword ptr [rbx+4C90h]
00007FF91DFCEB1C  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFCEB20  F3 0F 59 AB A0 4C 00 00     mulss   xmm5, dword ptr [rbx+4CA0h]
00007FF91DFCEB28  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCEB2C  F3 0F 10 83 80 4C 00 00     movss   xmm0, dword ptr [rbx+4C80h]
00007FF91DFCEB34  F3 0F 59 83 C0 49 00 00     mulss   xmm0, dword ptr [rbx+49C0h]
00007FF91DFCEB3C  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFCEB40  F3 0F 10 AB 10 4C 00 00     movss   xmm5, dword ptr [rbx+4C10h]
00007FF91DFCEB48  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCEB4C  F3 0F 11 93 80 4B 00 00     movss   dword ptr [rbx+4B80h], xmm2
00007FF91DFCEB54  F3 0F 58 AB 00 4C 00 00     addss   xmm5, dword ptr [rbx+4C00h]
00007FF91DFCEB5C  F3 0F 10 83 F0 49 00 00     movss   xmm0, dword ptr [rbx+49F0h]
00007FF91DFCEB64  F3 0F 59 AB 30 4D 00 00     mulss   xmm5, dword ptr [rbx+4D30h]
00007FF91DFCEB6C  F3 0F 59 AB 50 4C 00 00     mulss   xmm5, dword ptr [rbx+4C50h]
00007FF91DFCEB74  F3 0F 11 A3 F0 49 00 00     movss   dword ptr [rbx+49F0h], xmm4
00007FF91DFCEB7C  F3 0F 59 A3 40 4E 00 00     mulss   xmm4, dword ptr [rbx+4E40h]
00007FF91DFCEB84  F3 0F 59 83 50 4E 00 00     mulss   xmm0, dword ptr [rbx+4E50h]
00007FF91DFCEB8C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCEB90  F3 0F 59 A3 40 4C 00 00     mulss   xmm4, dword ptr [rbx+4C40h]
00007FF91DFCEB98  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFCEB9C  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCEBA0  73 06                       jnb     short loc_7FF91DFCEBA8
00007FF91DFCEBA2  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCEBA6  EB 05                       jmp     short loc_7FF91DFCEBAD
00007FF91DFCEBA8  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCEBAD  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFCEBB0  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCEBB3  F3 0F 59 83 F0 4C 00 00     mulss   xmm0, dword ptr [rbx+4CF0h]
00007FF91DFCEBBB  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCEBBF  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCEBC3  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCEBC7  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCEBCB  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFCEBCF  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCEBD3  F3 0F 10 8B A0 49 00 00     movss   xmm1, dword ptr [rbx+49A0h]
00007FF91DFCEBDB  F3 0F 11 AB A0 49 00 00     movss   dword ptr [rbx+49A0h], xmm5
00007FF91DFCEBE3  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCEBE6  F3 0F 10 9B B0 49 00 00     movss   xmm3, dword ptr [rbx+49B0h]
00007FF91DFCEBEE  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCEBF2  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCEBF5  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEBF9  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCEBFD  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFCEC01  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFCEC05  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCEC09  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCEC0D  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEC10  F3 0F 11 A3 B0 49 00 00     movss   dword ptr [rbx+49B0h], xmm4
00007FF91DFCEC18  F3 0F 10 8B C0 49 00 00     movss   xmm1, dword ptr [rbx+49C0h]
00007FF91DFCEC20  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCEC24  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCEC28  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCEC2B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEC2F  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFCEC33  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCEC37  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFCEC3B  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCEC3F  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCEC43  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCEC47  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCEC4B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEC4E  F3 0F 11 9B C0 49 00 00     movss   dword ptr [rbx+49C0h], xmm3
00007FF91DFCEC56  F3 0F 10 AB D0 49 00 00     movss   xmm5, dword ptr [rbx+49D0h]
00007FF91DFCEC5E  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCEC62  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCEC66  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCEC69  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEC6D  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCEC71  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCEC75  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFCEC79  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCEC7D  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCEC81  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCEC85  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCEC89  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEC8C  F3 0F 11 93 D0 49 00 00     movss   dword ptr [rbx+49D0h], xmm2
00007FF91DFCEC94  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFCEC98  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCEC9C  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCECA0  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFCECA5  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCECA8  F3 0F 59 83 E0 49 00 00     mulss   xmm0, dword ptr [rbx+49E0h]
00007FF91DFCECB0  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCECB4  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCECB8  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCECBB  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFCECBF  F3 0F 11 AB E0 49 00 00     movss   dword ptr [rbx+49E0h], xmm5
00007FF91DFCECC7  F3 0F 10 93 D0 49 00 00     movss   xmm2, dword ptr [rbx+49D0h]
00007FF91DFCECCF  F3 0F 59 93 90 4C 00 00     mulss   xmm2, dword ptr [rbx+4C90h]
00007FF91DFCECD7  F3 0F 10 8B 00 4C 00 00     movss   xmm1, dword ptr [rbx+4C00h]
00007FF91DFCECDF  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFCECE3  F3 0F 59 AB A0 4C 00 00     mulss   xmm5, dword ptr [rbx+4CA0h]
00007FF91DFCECEB  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCECEF  F3 0F 10 83 80 4C 00 00     movss   xmm0, dword ptr [rbx+4C80h]
00007FF91DFCECF7  F3 0F 59 83 C0 49 00 00     mulss   xmm0, dword ptr [rbx+49C0h]
00007FF91DFCECFF  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFCED03  F3 0F 10 AB 10 4C 00 00     movss   xmm5, dword ptr [rbx+4C10h]
00007FF91DFCED0B  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCED0F  F3 0F 11 93 00 4B 00 00     movss   dword ptr [rbx+4B00h], xmm2
00007FF91DFCED17  F3 0F 59 AB 20 4D 00 00     mulss   xmm5, dword ptr [rbx+4D20h]
00007FF91DFCED1F  F3 0F 59 8B 10 4D 00 00     mulss   xmm1, dword ptr [rbx+4D10h]
00007FF91DFCED27  F3 0F 10 83 F0 49 00 00     movss   xmm0, dword ptr [rbx+49F0h]
00007FF91DFCED2F  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCED33  F3 0F 59 AB 50 4C 00 00     mulss   xmm5, dword ptr [rbx+4C50h]
00007FF91DFCED3B  F3 0F 11 A3 F0 49 00 00     movss   dword ptr [rbx+49F0h], xmm4
00007FF91DFCED43  F3 0F 59 A3 40 4E 00 00     mulss   xmm4, dword ptr [rbx+4E40h]
00007FF91DFCED4B  F3 0F 59 83 50 4E 00 00     mulss   xmm0, dword ptr [rbx+4E50h]
00007FF91DFCED53  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCED57  F3 0F 59 A3 40 4C 00 00     mulss   xmm4, dword ptr [rbx+4C40h]
00007FF91DFCED5F  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFCED63  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCED67  73 06                       jnb     short loc_7FF91DFCED6F
00007FF91DFCED69  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCED6D  EB 05                       jmp     short loc_7FF91DFCED74
00007FF91DFCED6F  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCED74  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFCED77  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCED7A  F3 0F 59 83 F0 4C 00 00     mulss   xmm0, dword ptr [rbx+4CF0h]
00007FF91DFCED82  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCED86  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCED8A  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCED8E  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCED92  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFCED96  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCED9A  F3 0F 10 8B A0 49 00 00     movss   xmm1, dword ptr [rbx+49A0h]
00007FF91DFCEDA2  F3 0F 11 AB A0 49 00 00     movss   dword ptr [rbx+49A0h], xmm5
00007FF91DFCEDAA  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCEDAD  F3 0F 10 9B B0 49 00 00     movss   xmm3, dword ptr [rbx+49B0h]
00007FF91DFCEDB5  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCEDB9  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCEDBC  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEDC0  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCEDC4  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFCEDC8  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFCEDCC  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCEDD0  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCEDD4  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEDD7  F3 0F 11 A3 B0 49 00 00     movss   dword ptr [rbx+49B0h], xmm4
00007FF91DFCEDDF  F3 0F 10 8B C0 49 00 00     movss   xmm1, dword ptr [rbx+49C0h]
00007FF91DFCEDE7  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCEDEB  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCEDEF  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCEDF2  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEDF6  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFCEDFA  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCEDFE  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFCEE02  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCEE06  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCEE0A  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCEE0E  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCEE12  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEE15  F3 0F 11 9B C0 49 00 00     movss   dword ptr [rbx+49C0h], xmm3
00007FF91DFCEE1D  F3 0F 10 AB D0 49 00 00     movss   xmm5, dword ptr [rbx+49D0h]
00007FF91DFCEE25  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCEE29  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCEE2D  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCEE30  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEE34  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCEE38  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCEE3C  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFCEE40  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCEE44  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCEE48  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFCEE4C  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCEE50  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEE53  F3 0F 11 93 D0 49 00 00     movss   dword ptr [rbx+49D0h], xmm2
00007FF91DFCEE5B  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFCEE5F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCEE63  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCEE67  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFCEE6C  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEE6F  F3 0F 59 83 E0 49 00 00     mulss   xmm0, dword ptr [rbx+49E0h]
00007FF91DFCEE77  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCEE7B  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCEE7F  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEE82  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFCEE86  F3 0F 11 AB E0 49 00 00     movss   dword ptr [rbx+49E0h], xmm5
00007FF91DFCEE8E  F3 0F 10 8B D0 49 00 00     movss   xmm1, dword ptr [rbx+49D0h]
00007FF91DFCEE96  F3 0F 59 8B 90 4C 00 00     mulss   xmm1, dword ptr [rbx+4C90h]
00007FF91DFCEE9E  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFCEEA2  F3 0F 59 AB A0 4C 00 00     mulss   xmm5, dword ptr [rbx+4CA0h]
00007FF91DFCEEAA  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCEEAE  F3 0F 10 83 80 4C 00 00     movss   xmm0, dword ptr [rbx+4C80h]
00007FF91DFCEEB6  F3 0F 59 83 C0 49 00 00     mulss   xmm0, dword ptr [rbx+49C0h]
00007FF91DFCEEBE  F3 0F 58 CD                 addss   xmm1, xmm5
00007FF91DFCEEC2  F3 0F 10 AB 00 4C 00 00     movss   xmm5, dword ptr [rbx+4C00h]
00007FF91DFCEECA  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCEECE  F3 0F 11 8B 80 4A 00 00     movss   dword ptr [rbx+4A80h], xmm1
00007FF91DFCEED6  F3 0F 59 AB 00 4D 00 00     mulss   xmm5, dword ptr [rbx+4D00h]
00007FF91DFCEEDE  F3 0F 10 83 F0 49 00 00     movss   xmm0, dword ptr [rbx+49F0h]
00007FF91DFCEEE6  F3 0F 59 AB 50 4C 00 00     mulss   xmm5, dword ptr [rbx+4C50h]
00007FF91DFCEEEE  F3 0F 11 9B 80 49 00 00     movss   dword ptr [rbx+4980h], xmm3
00007FF91DFCEEF6  F3 0F 59 9B 40 4E 00 00     mulss   xmm3, dword ptr [rbx+4E40h]
00007FF91DFCEEFE  F3 0F 59 83 50 4E 00 00     mulss   xmm0, dword ptr [rbx+4E50h]
00007FF91DFCEF06  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCEF0A  F3 0F 59 9B 40 4C 00 00     mulss   xmm3, dword ptr [rbx+4C40h]
00007FF91DFCEF12  F3 0F 5C EB                 subss   xmm5, xmm3
00007FF91DFCEF16  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCEF1A  73 06                       jnb     short loc_7FF91DFCEF22
00007FF91DFCEF1C  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCEF20  EB 05                       jmp     short loc_7FF91DFCEF27
00007FF91DFCEF22  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCEF27  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFCEF2A  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCEF2D  F3 0F 59 83 F0 4C 00 00     mulss   xmm0, dword ptr [rbx+4CF0h]
00007FF91DFCEF35  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCEF39  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCEF3D  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCEF41  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCEF45  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFCEF49  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCEF4D  F3 0F 11 AB 20 49 00 00     movss   dword ptr [rbx+4920h], xmm5
00007FF91DFCEF55  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCEF58  F3 0F 58 AB A0 49 00 00     addss   xmm5, dword ptr [rbx+49A0h]
00007FF91DFCEF60  F3 0F 10 9B B0 49 00 00     movss   xmm3, dword ptr [rbx+49B0h]
00007FF91DFCEF68  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCEF6B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEF6F  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCEF73  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFCEF77  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFCEF7B  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCEF7F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCEF83  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEF86  F3 0F 11 A3 30 49 00 00     movss   dword ptr [rbx+4930h], xmm4
00007FF91DFCEF8E  F3 0F 10 8B C0 49 00 00     movss   xmm1, dword ptr [rbx+49C0h]
00007FF91DFCEF96  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCEF9A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCEF9E  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCEFA1  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEFA5  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFCEFA9  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCEFAD  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFCEFB1  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCEFB5  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCEFB9  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCEFBD  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCEFC1  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEFC4  F3 0F 11 9B 40 49 00 00     movss   dword ptr [rbx+4940h], xmm3
00007FF91DFCEFCC  F3 0F 10 AB D0 49 00 00     movss   xmm5, dword ptr [rbx+49D0h]
00007FF91DFCEFD4  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCEFD8  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCEFDC  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCEFDF  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCEFE3  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCEFE7  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCEFEB  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFCEFEF  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCEFF3  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCEFF7  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCEFFB  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCEFFE  F3 0F 11 93 50 49 00 00     movss   dword ptr [rbx+4950h], xmm2
00007FF91DFCF006  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFCF00A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCF00E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCF012  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFCF017  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCF01A  F3 0F 59 83 E0 49 00 00     mulss   xmm0, dword ptr [rbx+49E0h]
00007FF91DFCF022  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCF026  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCF02A  F3 44 0F 59 C1              mulss   xmm8, xmm1
00007FF91DFCF02F  F3 0F 11 AB 60 49 00 00     movss   dword ptr [rbx+4960h], xmm5
00007FF91DFCF037  F3 0F 10 9B 40 49 00 00     movss   xmm3, dword ptr [rbx+4940h]
00007FF91DFCF03F  F3 0F 59 F5                 mulss   xmm6, xmm5
00007FF91DFCF043  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFCF048  F3 44 0F 11 83 70 49 00 00  movss   dword ptr [rbx+4970h], xmm8
00007FF91DFCF051  F3 0F 10 83 90 4C 00 00     movss   xmm0, dword ptr [rbx+4C90h]
00007FF91DFCF059  F3 0F 59 83 50 49 00 00     mulss   xmm0, dword ptr [rbx+4950h]
00007FF91DFCF061  F3 0F 59 AB A0 4C 00 00     mulss   xmm5, dword ptr [rbx+4CA0h]
00007FF91DFCF069  F3 0F 59 9B 80 4C 00 00     mulss   xmm3, dword ptr [rbx+4C80h]
00007FF91DFCF071  F3 0F 10 A3 40 4A 00 00     movss   xmm4, dword ptr [rbx+4A40h]
00007FF91DFCF079  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCF07D  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFCF081  F3 0F 11 AB 00 4A 00 00     movss   dword ptr [rbx+4A00h], xmm5
00007FF91DFCF089  F3 0F 58 A3 B0 4B 00 00     addss   xmm4, dword ptr [rbx+4BB0h]
00007FF91DFCF091  F3 0F 10 83 C0 4A 00 00     movss   xmm0, dword ptr [rbx+4AC0h]
00007FF91DFCF099  F3 0F 58 83 30 4B 00 00     addss   xmm0, dword ptr [rbx+4B30h]
00007FF91DFCF0A1  F3 0F 10 8B 40 4B 00 00     movss   xmm1, dword ptr [rbx+4B40h]
00007FF91DFCF0A9  F3 0F 58 8B B0 4A 00 00     addss   xmm1, dword ptr [rbx+4AB0h]
00007FF91DFCF0B1  F3 0F 59 A3 30 4E 00 00     mulss   xmm4, dword ptr [rbx+4E30h]
00007FF91DFCF0B9  F3 0F 59 83 20 4E 00 00     mulss   xmm0, dword ptr [rbx+4E20h]
00007FF91DFCF0C1  F3 0F 59 8B 10 4E 00 00     mulss   xmm1, dword ptr [rbx+4E10h]
00007FF91DFCF0C9  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCF0CD  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCF0D1  F3 0F 10 83 30 4A 00 00     movss   xmm0, dword ptr [rbx+4A30h]
00007FF91DFCF0D9  F3 0F 58 83 C0 4B 00 00     addss   xmm0, dword ptr [rbx+4BC0h]
00007FF91DFCF0E1  F3 0F 10 8B A0 4B 00 00     movss   xmm1, dword ptr [rbx+4BA0h]
00007FF91DFCF0E9  F3 0F 58 8B 50 4A 00 00     addss   xmm1, dword ptr [rbx+4A50h]
00007FF91DFCF0F1  F3 0F 58 AB F0 4B 00 00     addss   xmm5, dword ptr [rbx+4BF0h]
00007FF91DFCF0F9  F3 0F 59 83 00 4E 00 00     mulss   xmm0, dword ptr [rbx+4E00h]
00007FF91DFCF101  F3 0F 59 8B F0 4D 00 00     mulss   xmm1, dword ptr [rbx+4DF0h]
00007FF91DFCF109  F3 0F 59 AB 40 4D 00 00     mulss   xmm5, dword ptr [rbx+4D40h]
00007FF91DFCF111  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCF115  F3 0F 10 83 20 4B 00 00     movss   xmm0, dword ptr [rbx+4B20h]
00007FF91DFCF11D  F3 0F 58 83 D0 4A 00 00     addss   xmm0, dword ptr [rbx+4AD0h]
00007FF91DFCF125  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCF129  F3 0F 10 8B 50 4B 00 00     movss   xmm1, dword ptr [rbx+4B50h]
00007FF91DFCF131  F3 0F 58 8B A0 4A 00 00     addss   xmm1, dword ptr [rbx+4AA0h]
00007FF91DFCF139  F3 0F 59 83 E0 4D 00 00     mulss   xmm0, dword ptr [rbx+4DE0h]
00007FF91DFCF141  F3 0F 59 8B D0 4D 00 00     mulss   xmm1, dword ptr [rbx+4DD0h]
00007FF91DFCF149  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCF14D  F3 0F 10 83 D0 4B 00 00     movss   xmm0, dword ptr [rbx+4BD0h]
00007FF91DFCF155  F3 0F 58 83 20 4A 00 00     addss   xmm0, dword ptr [rbx+4A20h]
00007FF91DFCF15D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCF161  F3 0F 10 8B 90 4B 00 00     movss   xmm1, dword ptr [rbx+4B90h]
00007FF91DFCF169  F3 0F 59 83 C0 4D 00 00     mulss   xmm0, dword ptr [rbx+4DC0h]
00007FF91DFCF171  F3 0F 58 8B 60 4A 00 00     addss   xmm1, dword ptr [rbx+4A60h]
00007FF91DFCF179  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCF17D  F3 0F 10 83 10 4B 00 00     movss   xmm0, dword ptr [rbx+4B10h]
00007FF91DFCF185  F3 0F 58 83 E0 4A 00 00     addss   xmm0, dword ptr [rbx+4AE0h]
00007FF91DFCF18D  F3 0F 59 8B B0 4D 00 00     mulss   xmm1, dword ptr [rbx+4DB0h]
00007FF91DFCF195  F3 0F 59 83 A0 4D 00 00     mulss   xmm0, dword ptr [rbx+4DA0h]
00007FF91DFCF19D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCF1A1  F3 0F 10 8B 60 4B 00 00     movss   xmm1, dword ptr [rbx+4B60h]
00007FF91DFCF1A9  F3 0F 58 8B 90 4A 00 00     addss   xmm1, dword ptr [rbx+4A90h]
00007FF91DFCF1B1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCF1B5  F3 0F 10 83 E0 4B 00 00     movss   xmm0, dword ptr [rbx+4BE0h]
00007FF91DFCF1BD  F3 0F 59 8B 90 4D 00 00     mulss   xmm1, dword ptr [rbx+4D90h]
00007FF91DFCF1C5  F3 0F 58 83 10 4A 00 00     addss   xmm0, dword ptr [rbx+4A10h]
00007FF91DFCF1CD  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCF1D1  F3 0F 10 8B 80 4B 00 00     movss   xmm1, dword ptr [rbx+4B80h]
00007FF91DFCF1D9  F3 0F 58 8B 70 4A 00 00     addss   xmm1, dword ptr [rbx+4A70h]
00007FF91DFCF1E1  F3 0F 59 83 80 4D 00 00     mulss   xmm0, dword ptr [rbx+4D80h]
00007FF91DFCF1E9  F3 0F 59 8B 70 4D 00 00     mulss   xmm1, dword ptr [rbx+4D70h]
00007FF91DFCF1F1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCF1F5  F3 0F 10 83 00 4B 00 00     movss   xmm0, dword ptr [rbx+4B00h]
00007FF91DFCF1FD  F3 0F 58 83 F0 4A 00 00     addss   xmm0, dword ptr [rbx+4AF0h]
00007FF91DFCF205  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCF209  F3 0F 10 8B 70 4B 00 00     movss   xmm1, dword ptr [rbx+4B70h]
00007FF91DFCF211  F3 0F 59 83 60 4D 00 00     mulss   xmm0, dword ptr [rbx+4D60h]
00007FF91DFCF219  F3 0F 58 8B 80 4A 00 00     addss   xmm1, dword ptr [rbx+4A80h]
00007FF91DFCF221  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCF225  F3 0F 59 8B 50 4D 00 00     mulss   xmm1, dword ptr [rbx+4D50h]
00007FF91DFCF22D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCF231  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFCF235  F3 0F 59 A3 D0 4C 00 00     mulss   xmm4, dword ptr [rbx+4CD0h]
00007FF91DFCF23D  F3 0F 11 A3 60 4C 00 00     movss   dword ptr [rbx+4C60h], xmm4
00007FF91DFCF245  8B 83 60 4E 00 00           mov     eax, [rbx+4E60h]
00007FF91DFCF24B  89 83 70 4E 00 00           mov     [rbx+4E70h], eax
00007FF91DFCF251  F3 0F 10 83 90 4E 00 00     movss   xmm0, dword ptr [rbx+4E90h]
00007FF91DFCF259  8B 83 80 4E 00 00           mov     eax, [rbx+4E80h]
00007FF91DFCF25F  89 83 B0 4E 00 00           mov     [rbx+4EB0h], eax
00007FF91DFCF265  F3 0F 11 83 C0 4E 00 00     movss   dword ptr [rbx+4EC0h], xmm0
00007FF91DFCF26D  8B 83 A0 4E 00 00           mov     eax, [rbx+4EA0h]
00007FF91DFCF273  89 83 D0 4E 00 00           mov     [rbx+4ED0h], eax
00007FF91DFCF279  F3 0F 10 93 E0 4E 00 00     movss   xmm2, dword ptr [rbx+4EE0h]
00007FF91DFCF281  F3 0F 11 93 F0 4E 00 00     movss   dword ptr [rbx+4EF0h], xmm2
00007FF91DFCF289  F3 0F 10 83 00 4F 00 00     movss   xmm0, dword ptr [rbx+4F00h]
00007FF91DFCF291  F3 0F 11 83 10 4F 00 00     movss   dword ptr [rbx+4F10h], xmm0
00007FF91DFCF299  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFCF29D  F3 0F 59 93 20 4F 00 00     mulss   xmm2, dword ptr [rbx+4F20h]
00007FF91DFCF2A5  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCF2A9  F3 0F 11 93 00 4F 00 00     movss   dword ptr [rbx+4F00h], xmm2
00007FF91DFCF2B1  F3 0F 10 83 C0 4E 00 00     movss   xmm0, dword ptr [rbx+4EC0h]
00007FF91DFCF2B9  F3 0F 10 8B D0 4E 00 00     movss   xmm1, dword ptr [rbx+4ED0h]
00007FF91DFCF2C1  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFCF2C5  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCF2C9  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFCF2CD  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCF2D1  F3 0F 11 93 30 4F 00 00     movss   dword ptr [rbx+4F30h], xmm2
00007FF91DFCF2D9  F3 0F 10 8B 40 4F 00 00     movss   xmm1, dword ptr [rbx+4F40h]
00007FF91DFCF2E1  F3 0F 11 8B 50 4F 00 00     movss   dword ptr [rbx+4F50h], xmm1
00007FF91DFCF2E9  F3 0F 10 83 60 4F 00 00     movss   xmm0, dword ptr [rbx+4F60h]
00007FF91DFCF2F1  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFCF2F4  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCF2F8  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFCF2FC  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCF300  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCF304  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFCF308  76 05                       jbe     short loc_7FF91DFCF30F
00007FF91DFCF30A  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFCF30D  EB 03                       jmp     short loc_7FF91DFCF312
00007FF91DFCF30F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCF312  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFCF316  F3 0F 11 83 40 4F 00 00     movss   dword ptr [rbx+4F40h], xmm0
00007FF91DFCF31E  F3 0F 10 8B 70 4F 00 00     movss   xmm1, dword ptr [rbx+4F70h]
00007FF91DFCF326  F3 0F 11 8B 80 4F 00 00     movss   dword ptr [rbx+4F80h], xmm1
00007FF91DFCF32E  F3 0F 10 93 90 4F 00 00     movss   xmm2, dword ptr [rbx+4F90h]
00007FF91DFCF336  F3 0F 11 93 A0 4F 00 00     movss   dword ptr [rbx+4FA0h], xmm2
00007FF91DFCF33E  F3 0F 10 83 B0 4F 00 00     movss   xmm0, dword ptr [rbx+4FB0h]
00007FF91DFCF346  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFCF349  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCF34D  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFCF351  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCF355  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFCF359  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFCF35D  76 05                       jbe     short loc_7FF91DFCF364
00007FF91DFCF35F  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFCF362  EB 03                       jmp     short loc_7FF91DFCF367
00007FF91DFCF364  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCF367  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFCF36B  F3 0F 11 83 90 4F 00 00     movss   dword ptr [rbx+4F90h], xmm0
00007FF91DFCF373  F3 0F 10 AB C0 4F 00 00     movss   xmm5, dword ptr [rbx+4FC0h]
00007FF91DFCF37B  F3 0F 10 B3 40 2B 00 00     movss   xmm6, dword ptr [rbx+2B40h]
00007FF91DFCF383  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFCF386  F3 0F 11 AB D0 4F 00 00     movss   dword ptr [rbx+4FD0h], xmm5
00007FF91DFCF38E  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCF391  F3 0F 59 A3 20 50 00 00     mulss   xmm4, dword ptr [rbx+5020h]
00007FF91DFCF399  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFCF39C  F3 0F 58 83 F0 4F 00 00     addss   xmm0, dword ptr [rbx+4FF0h]
00007FF91DFCF3A4  F3 0F 58 9B 10 50 00 00     addss   xmm3, dword ptr [rbx+5010h]
00007FF91DFCF3AC  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFCF3B0  73 06                       jnb     short loc_7FF91DFCF3B8
00007FF91DFCF3B2  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFCF3B6  EB 05                       jmp     short loc_7FF91DFCF3BD
00007FF91DFCF3B8  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFCF3BD  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCF3C1  72 1B                       jb      short loc_7FF91DFCF3DE
00007FF91DFCF3C3  F3 0F 10 83 00 50 00 00     movss   xmm0, dword ptr [rbx+5000h]
00007FF91DFCF3CB  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFCF3CE  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFCF3D2  F3 0F 59 DE                 mulss   xmm3, xmm6
00007FF91DFCF3D6  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCF3DA  F3 0F 58 DD                 addss   xmm3, xmm5
00007FF91DFCF3DE  41 0F 2E F6                 ucomiss xmm6, xmm14
00007FF91DFCF3E2  F3 0F 10 8B 40 50 00 00     movss   xmm1, dword ptr [rbx+5040h]
00007FF91DFCF3EA  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFCF3ED  F3 0F 59 93 30 50 00 00     mulss   xmm2, dword ptr [rbx+5030h]
00007FF91DFCF3F5  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCF3F8  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCF3FC  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFCF400  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCF404  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCF407  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFCF40B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCF40F  F3 0F 5C C2                 subss   xmm0, xmm2
00007FF91DFCF413  F3 0F 58 C5                 addss   xmm0, xmm5
00007FF91DFCF417  74 03                       jz      short loc_7FF91DFCF41C
00007FF91DFCF419  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCF41C  F3 0F 11 83 E0 4F 00 00     movss   dword ptr [rbx+4FE0h], xmm0
00007FF91DFCF424  F3 0F 11 83 C0 4F 00 00     movss   dword ptr [rbx+4FC0h], xmm0
00007FF91DFCF42C  F3 0F 10 BB 60 4C 00 00     movss   xmm7, dword ptr [rbx+4C60h]
00007FF91DFCF434  F3 0F 10 B3 D0 33 00 00     movss   xmm6, dword ptr [rbx+33D0h]
00007FF91DFCF43C  F3 0F 10 9B D0 43 00 00     movss   xmm3, dword ptr [rbx+43D0h]
00007FF91DFCF444  F3 0F 10 83 B0 35 00 00     movss   xmm0, dword ptr [rbx+35B0h]
00007FF91DFCF44C  F3 0F 10 8B 60 4E 00 00     movss   xmm1, dword ptr [rbx+4E60h]
00007FF91DFCF454  8B 83 80 50 00 00           mov     eax, [rbx+5080h]
00007FF91DFCF45A  89 83 90 50 00 00           mov     [rbx+5090h], eax
00007FF91DFCF460  8B 83 A0 50 00 00           mov     eax, [rbx+50A0h]
00007FF91DFCF466  89 83 B0 50 00 00           mov     [rbx+50B0h], eax
00007FF91DFCF46C  F3 0F 11 83 50 50 00 00     movss   dword ptr [rbx+5050h], xmm0
00007FF91DFCF474  F3 0F 11 8B 60 50 00 00     movss   dword ptr [rbx+5060h], xmm1
00007FF91DFCF47C  F3 0F 59 9B 70 51 00 00     mulss   xmm3, dword ptr [rbx+5170h]
00007FF91DFCF484  F3 0F 10 A3 90 50 00 00     movss   xmm4, dword ptr [rbx+5090h]
00007FF91DFCF48C  F3 0F 10 93 D0 50 00 00     movss   xmm2, dword ptr [rbx+50D0h]
00007FF91DFCF494  F3 0F 11 9B 70 50 00 00     movss   dword ptr [rbx+5070h], xmm3
00007FF91DFCF49C  0F 28 DF                    movaps  xmm3, xmm7
00007FF91DFCF49F  F3 0F 59 B3 E0 50 00 00     mulss   xmm6, dword ptr [rbx+50E0h]
00007FF91DFCF4A7  F3 0F 5C DC                 subss   xmm3, xmm4
00007FF91DFCF4AB  F3 0F 59 93 E0 4F 00 00     mulss   xmm2, dword ptr [rbx+4FE0h]
00007FF91DFCF4B3  F3 0F 10 8B F0 50 00 00     movss   xmm1, dword ptr [rbx+50F0h]
00007FF91DFCF4BB  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCF4BE  F3 0F 59 83 10 51 00 00     mulss   xmm0, dword ptr [rbx+5110h]
00007FF91DFCF4C6  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFCF4CA  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCF4CE  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFCF4D2  F3 0F 11 A3 80 50 00 00     movss   dword ptr [rbx+5080h], xmm4
00007FF91DFCF4DA  F3 0F 59 8B 50 50 00 00     mulss   xmm1, dword ptr [rbx+5050h]
00007FF91DFCF4E2  F3 0F 10 93 00 51 00 00     movss   xmm2, dword ptr [rbx+5100h]
00007FF91DFCF4EA  F3 0F 59 9B 80 51 00 00     mulss   xmm3, dword ptr [rbx+5180h]
00007FF91DFCF4F2  F3 0F 59 A3 90 51 00 00     mulss   xmm4, dword ptr [rbx+5190h]
00007FF91DFCF4FA  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFCF4FE  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCF501  F3 0F 59 8B 60 50 00 00     mulss   xmm1, dword ptr [rbx+5060h]
00007FF91DFCF509  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCF50D  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFCF511  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFCF515  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFCF519  F3 0F 10 B3 20 51 00 00     movss   xmm6, dword ptr [rbx+5120h]
00007FF91DFCF521  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFCF525  F3 0F 59 8B 50 51 00 00     mulss   xmm1, dword ptr [rbx+5150h]
00007FF91DFCF52D  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFCF531  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFCF535  76 05                       jbe     short loc_7FF91DFCF53C
00007FF91DFCF537  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFCF53A  EB 03                       jmp     short loc_7FF91DFCF53F
00007FF91DFCF53C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCF53F  F3 0F 10 93 40 51 00 00     movss   xmm2, dword ptr [rbx+5140h]
00007FF91DFCF547  F3 0F 10 A3 30 51 00 00     movss   xmm4, dword ptr [rbx+5130h]
00007FF91DFCF54F  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFCF553  F3 0F 10 83 70 50 00 00     movss   xmm0, dword ptr [rbx+5070h]
00007FF91DFCF55B  F3 0F 59 AB 60 51 00 00     mulss   xmm5, dword ptr [rbx+5160h]
00007FF91DFCF563  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCF568  F3 0F 59 F3                 mulss   xmm6, xmm3
00007FF91DFCF56C  F3 0F 10 9B B0 50 00 00     movss   xmm3, dword ptr [rbx+50B0h]
00007FF91DFCF574  F3 0F 58 F7                 addss   xmm6, xmm7
00007FF91DFCF578  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFCF57C  F3 0F 10 83 A0 51 00 00     movss   xmm0, dword ptr [rbx+51A0h]
00007FF91DFCF584  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFCF587  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCF58B  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFCF58F  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCF593  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFCF597  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCF59B  F3 0F 11 9B A0 50 00 00     movss   dword ptr [rbx+50A0h], xmm3
00007FF91DFCF5A3  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFCF5A7  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFCF5AB  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCF5AF  F3 0F 59 A3 B0 51 00 00     mulss   xmm4, dword ptr [rbx+51B0h]
00007FF91DFCF5B7  F3 0F 11 A3 C0 50 00 00     movss   dword ptr [rbx+50C0h], xmm4
00007FF91DFCF5BF  8B 83 D0 51 00 00           mov     eax, [rbx+51D0h]
00007FF91DFCF5C5  89 83 E0 51 00 00           mov     [rbx+51E0h], eax
00007FF91DFCF5CB  8B 83 C0 51 00 00           mov     eax, [rbx+51C0h]
00007FF91DFCF5D1  89 83 D0 51 00 00           mov     [rbx+51D0h], eax
00007FF91DFCF5D7  F3 0F 10 83 E0 51 00 00     movss   xmm0, dword ptr [rbx+51E0h]
00007FF91DFCF5DF  F3 0F 10 8B F0 51 00 00     movss   xmm1, dword ptr [rbx+51F0h]
00007FF91DFCF5E7  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFCF5EB  F3 0F 11 A3 C0 51 00 00     movss   dword ptr [rbx+51C0h], xmm4
00007FF91DFCF5F3  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCF5F7  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCF5FB  F3 0F 11 8B D0 51 00 00     movss   dword ptr [rbx+51D0h], xmm1
00007FF91DFCF603  F3 0F 10 93 C0 51 00 00     movss   xmm2, dword ptr [rbx+51C0h]
00007FF91DFCF60B  F3 0F 10 B3 B0 4E 00 00     movss   xmm6, dword ptr [rbx+4EB0h]
00007FF91DFCF613  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCF616  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFCF61A  8B 83 20 52 00 00           mov     eax, [rbx+5220h]
00007FF91DFCF620  89 83 30 52 00 00           mov     [rbx+5230h], eax
00007FF91DFCF626  8B 83 10 52 00 00           mov     eax, [rbx+5210h]
00007FF91DFCF62C  89 83 20 52 00 00           mov     [rbx+5220h], eax
00007FF91DFCF632  8B 83 00 52 00 00           mov     eax, [rbx+5200h]
00007FF91DFCF638  89 83 10 52 00 00           mov     [rbx+5210h], eax
00007FF91DFCF63E  F3 0F 11 93 00 52 00 00     movss   dword ptr [rbx+5200h], xmm2
00007FF91DFCF646  F3 0F 59 83 50 52 00 00     mulss   xmm0, dword ptr [rbx+5250h]
00007FF91DFCF64E  F3 0F 10 A3 10 52 00 00     movss   xmm4, dword ptr [rbx+5210h]
00007FF91DFCF656  F3 0F 10 8B 70 52 00 00     movss   xmm1, dword ptr [rbx+5270h]
00007FF91DFCF65E  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFCF661  F3 0F 59 8B 20 52 00 00     mulss   xmm1, dword ptr [rbx+5220h]
00007FF91DFCF669  F3 0F 59 AB 60 52 00 00     mulss   xmm5, dword ptr [rbx+5260h]
00007FF91DFCF671  F3 0F 59 A3 90 52 00 00     mulss   xmm4, dword ptr [rbx+5290h]
00007FF91DFCF679  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCF67D  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCF680  F3 0F 59 83 80 52 00 00     mulss   xmm0, dword ptr [rbx+5280h]
00007FF91DFCF688  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCF68C  F3 0F 10 8B A0 52 00 00     movss   xmm1, dword ptr [rbx+52A0h]
00007FF91DFCF694  F3 0F 59 8B 30 52 00 00     mulss   xmm1, dword ptr [rbx+5230h]
00007FF91DFCF69C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCF6A0  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCF6A4  76 05                       jbe     short loc_7FF91DFCF6AB
00007FF91DFCF6A6  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFCF6A9  EB 03                       jmp     short loc_7FF91DFCF6AE
00007FF91DFCF6AB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCF6AE  0F 2F 35 0B 5E 77 00        comiss  xmm6, cs:dword_7FF91E7454C0
00007FF91DFCF6B5  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFCF6B9  F3 0F 11 AB 10 52 00 00     movss   dword ptr [rbx+5210h], xmm5
00007FF91DFCF6C1  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFCF6C4  F3 0F 11 A3 20 52 00 00     movss   dword ptr [rbx+5220h], xmm4
00007FF91DFCF6CC  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCF6D0  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFCF6D4  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCF6D8  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCF6DB  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFCF6DF  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFCF6E3  73 09                       jnb     short loc_7FF91DFCF6EE
00007FF91DFCF6E5  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFCF6E9  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
00007FF91DFCF6EE  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFCF6F2  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
00007FF91DFCF6F7  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFCF6FA  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCF6FE  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCF702  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFCF706  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCF70A  72 03                       jb      short loc_7FF91DFCF70F
00007FF91DFCF70C  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFCF70F  F3 0F 11 93 40 52 00 00     movss   dword ptr [rbx+5240h], xmm2
00007FF91DFCF717  F3 0F 59 93 40 4F 00 00     mulss   xmm2, dword ptr [rbx+4F40h]
00007FF91DFCF71F  F3 0F 11 93 B0 52 00 00     movss   dword ptr [rbx+52B0h], xmm2
00007FF91DFCF727  F3 0F 59 93 90 4F 00 00     mulss   xmm2, dword ptr [rbx+4F90h]
00007FF91DFCF72F  F3 0F 11 93 C0 52 00 00     movss   dword ptr [rbx+52C0h], xmm2
00007FF91DFCF737  F3 0F 10 83 70 3A 00 00     movss   xmm0, dword ptr [rbx+3A70h]
00007FF91DFCF73F  F3 0F 58 83 D0 37 00 00     addss   xmm0, dword ptr [rbx+37D0h]
00007FF91DFCF747  44 0F 5A E0                 cvtps2pd xmm12, xmm0
00007FF91DFCF74B  F2 44 0F 5F 25 54 B5 61 00  maxsd   xmm12, cs:qword_7FF91E5EACA8
00007FF91DFCF754  F2 44 0F 5D 25 33 B5 61 00  minsd   xmm12, cs:qword_7FF91E5EAC90
00007FF91DFCF75D  41 0F 28 CC                 movaps  xmm1, xmm12
00007FF91DFCF761  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFCF765  F2 0F 58 05 FB 5A 77 00     addsd   xmm0, cs:qword_7FF91E745268
00007FF91DFCF76D  F2 41 0F 59 CC              mulsd   xmm1, xmm12
00007FF91DFCF772  41 0F 28 FC                 movaps  xmm7, xmm12
00007FF91DFCF776  F2 0F 2C C0                 cvttsd2si eax, xmm0
00007FF91DFCF77A  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFCF77D  48 63 C8                    movsxd  rcx, eax
00007FF91DFCF780  F2 41 0F 59 D4              mulsd   xmm2, xmm12
00007FF91DFCF785  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
00007FF91DFCF78C  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCF78F  F2 41 0F 59 DC              mulsd   xmm3, xmm12
00007FF91DFCF794  48 8D 0D 45 9D 61 00        lea     rcx, unk_7FF91E5E94E0
00007FF91DFCF79B  48 03 C1                    add     rax, rcx
00007FF91DFCF79E  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFCF7A1  F2 41 0F 59 E4              mulsd   xmm4, xmm12
00007FF91DFCF7A6  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
00007FF91DFCF7AB  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
00007FF91DFCF7B0  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
00007FF91DFCF7B5  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFCF7B8  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
00007FF91DFCF7BC  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
00007FF91DFCF7C1  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
00007FF91DFCF7C6  F2 0F 58 F9                 addsd   xmm7, xmm1
00007FF91DFCF7CA  F2 41 0F 59 EC              mulsd   xmm5, xmm12
00007FF91DFCF7CF  F2 0F 58 FA                 addsd   xmm7, xmm2
00007FF91DFCF7D3  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFCF7D6  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
00007FF91DFCF7DB  F2 41 0F 59 F4              mulsd   xmm6, xmm12
00007FF91DFCF7E0  F2 0F 58 FB                 addsd   xmm7, xmm3
00007FF91DFCF7E4  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFCF7E8  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
00007FF91DFCF7ED  F2 0F 58 FC                 addsd   xmm7, xmm4
00007FF91DFCF7F1  F2 45 0F 59 C4              mulsd   xmm8, xmm12
00007FF91DFCF7F6  F2 0F 58 FD                 addsd   xmm7, xmm5
00007FF91DFCF7FA  45 0F 28 C8                 movaps  xmm9, xmm8
00007FF91DFCF7FE  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
00007FF91DFCF807  F2 45 0F 59 CC              mulsd   xmm9, xmm12
00007FF91DFCF80C  F2 0F 58 FE                 addsd   xmm7, xmm6
00007FF91DFCF810  45 0F 28 D1                 movaps  xmm10, xmm9
00007FF91DFCF814  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
00007FF91DFCF81D  F2 41 0F 58 F8              addsd   xmm7, xmm8
00007FF91DFCF822  F2 45 0F 59 D4              mulsd   xmm10, xmm12
00007FF91DFCF827  F2 41 0F 58 F9              addsd   xmm7, xmm9
00007FF91DFCF82C  45 0F 28 DA                 movaps  xmm11, xmm10
00007FF91DFCF830  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
00007FF91DFCF839  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFCF83E  F2 41 0F 58 FA              addsd   xmm7, xmm10
00007FF91DFCF843  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFCF847  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFCF84C  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
00007FF91DFCF854  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
00007FF91DFCF85D  F2 0F 58 F8                 addsd   xmm7, xmm0
00007FF91DFCF861  F2 41 0F 58 FB              addsd   xmm7, xmm11
00007FF91DFCF866  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
00007FF91DFCF86A  F3 0F 5D 1D 26 B4 61 00     minss   xmm3, cs:dword_7FF91E5EAC98
00007FF91DFCF872  F3 0F 5F 1D 36 B4 61 00     maxss   xmm3, cs:dword_7FF91E5EACB0
00007FF91DFCF87A  F3 0F 59 9B E0 37 00 00     mulss   xmm3, dword ptr [rbx+37E0h]
00007FF91DFCF882  F3 0F 11 9B 50 3A 00 00     movss   dword ptr [rbx+3A50h], xmm3
00007FF91DFCF88A  8B 83 F0 3B 00 00           mov     eax, [rbx+3BF0h]
00007FF91DFCF890  F3 0F 10 AB D0 37 00 00     movss   xmm5, dword ptr [rbx+37D0h]
00007FF91DFCF898  F3 0F 10 83 A0 39 00 00     movss   xmm0, dword ptr [rbx+39A0h]
00007FF91DFCF8A0  F3 0F 10 8B B0 39 00 00     movss   xmm1, dword ptr [rbx+39B0h]
00007FF91DFCF8A8  F3 0F 10 93 C0 39 00 00     movss   xmm2, dword ptr [rbx+39C0h]
00007FF91DFCF8B0  89 83 00 3C 00 00           mov     [rbx+3C00h], eax
00007FF91DFCF8B6  8B 83 10 3C 00 00           mov     eax, [rbx+3C10h]
00007FF91DFCF8BC  89 83 20 3C 00 00           mov     [rbx+3C20h], eax
00007FF91DFCF8C2  8B 83 C0 3C 00 00           mov     eax, [rbx+3CC0h]
00007FF91DFCF8C8  89 83 D0 3C 00 00           mov     [rbx+3CD0h], eax
00007FF91DFCF8CE  8B 83 B0 3C 00 00           mov     eax, [rbx+3CB0h]
00007FF91DFCF8D4  89 83 C0 3C 00 00           mov     [rbx+3CC0h], eax
00007FF91DFCF8DA  8B 83 A0 3C 00 00           mov     eax, [rbx+3CA0h]
00007FF91DFCF8E0  89 83 B0 3C 00 00           mov     [rbx+3CB0h], eax
00007FF91DFCF8E6  8B 83 90 3C 00 00           mov     eax, [rbx+3C90h]
00007FF91DFCF8EC  89 83 A0 3C 00 00           mov     [rbx+3CA0h], eax
00007FF91DFCF8F2  8B 83 80 3C 00 00           mov     eax, [rbx+3C80h]
00007FF91DFCF8F8  89 83 90 3C 00 00           mov     [rbx+3C90h], eax
00007FF91DFCF8FE  8B 83 70 3C 00 00           mov     eax, [rbx+3C70h]
00007FF91DFCF904  89 83 80 3C 00 00           mov     [rbx+3C80h], eax
00007FF91DFCF90A  8B 83 60 3C 00 00           mov     eax, [rbx+3C60h]
00007FF91DFCF910  89 83 70 3C 00 00           mov     [rbx+3C70h], eax
00007FF91DFCF916  8B 83 40 3D 00 00           mov     eax, [rbx+3D40h]
00007FF91DFCF91C  89 83 50 3D 00 00           mov     [rbx+3D50h], eax
00007FF91DFCF922  8B 83 30 3D 00 00           mov     eax, [rbx+3D30h]
00007FF91DFCF928  89 83 40 3D 00 00           mov     [rbx+3D40h], eax
00007FF91DFCF92E  8B 83 20 3D 00 00           mov     eax, [rbx+3D20h]
00007FF91DFCF934  89 83 30 3D 00 00           mov     [rbx+3D30h], eax
00007FF91DFCF93A  8B 83 10 3D 00 00           mov     eax, [rbx+3D10h]
00007FF91DFCF940  89 83 20 3D 00 00           mov     [rbx+3D20h], eax
00007FF91DFCF946  8B 83 00 3D 00 00           mov     eax, [rbx+3D00h]
00007FF91DFCF94C  89 83 10 3D 00 00           mov     [rbx+3D10h], eax
00007FF91DFCF952  8B 83 F0 3C 00 00           mov     eax, [rbx+3CF0h]
00007FF91DFCF958  89 83 00 3D 00 00           mov     [rbx+3D00h], eax
00007FF91DFCF95E  8B 83 E0 3C 00 00           mov     eax, [rbx+3CE0h]
00007FF91DFCF964  89 83 F0 3C 00 00           mov     [rbx+3CF0h], eax
00007FF91DFCF96A  8B 83 C0 3D 00 00           mov     eax, [rbx+3DC0h]
00007FF91DFCF970  89 83 D0 3D 00 00           mov     [rbx+3DD0h], eax
00007FF91DFCF976  8B 83 B0 3D 00 00           mov     eax, [rbx+3DB0h]
00007FF91DFCF97C  89 83 C0 3D 00 00           mov     [rbx+3DC0h], eax
00007FF91DFCF982  8B 83 A0 3D 00 00           mov     eax, [rbx+3DA0h]
00007FF91DFCF988  89 83 B0 3D 00 00           mov     [rbx+3DB0h], eax
00007FF91DFCF98E  8B 83 90 3D 00 00           mov     eax, [rbx+3D90h]
00007FF91DFCF994  89 83 A0 3D 00 00           mov     [rbx+3DA0h], eax
00007FF91DFCF99A  8B 83 80 3D 00 00           mov     eax, [rbx+3D80h]
00007FF91DFCF9A0  89 83 90 3D 00 00           mov     [rbx+3D90h], eax
00007FF91DFCF9A6  8B 83 70 3D 00 00           mov     eax, [rbx+3D70h]
00007FF91DFCF9AC  89 83 80 3D 00 00           mov     [rbx+3D80h], eax
00007FF91DFCF9B2  8B 83 60 3D 00 00           mov     eax, [rbx+3D60h]
00007FF91DFCF9B8  89 83 70 3D 00 00           mov     [rbx+3D70h], eax
00007FF91DFCF9BE  8B 83 40 3E 00 00           mov     eax, [rbx+3E40h]
00007FF91DFCF9C4  89 83 50 3E 00 00           mov     [rbx+3E50h], eax
00007FF91DFCF9CA  8B 83 30 3E 00 00           mov     eax, [rbx+3E30h]
00007FF91DFCF9D0  89 83 40 3E 00 00           mov     [rbx+3E40h], eax
00007FF91DFCF9D6  8B 83 20 3E 00 00           mov     eax, [rbx+3E20h]
00007FF91DFCF9DC  89 83 30 3E 00 00           mov     [rbx+3E30h], eax
00007FF91DFCF9E2  8B 83 10 3E 00 00           mov     eax, [rbx+3E10h]
00007FF91DFCF9E8  89 83 20 3E 00 00           mov     [rbx+3E20h], eax
00007FF91DFCF9EE  8B 83 00 3E 00 00           mov     eax, [rbx+3E00h]
00007FF91DFCF9F4  89 83 10 3E 00 00           mov     [rbx+3E10h], eax
00007FF91DFCF9FA  8B 83 F0 3D 00 00           mov     eax, [rbx+3DF0h]
00007FF91DFCFA00  89 83 00 3E 00 00           mov     [rbx+3E00h], eax
00007FF91DFCFA06  8B 83 E0 3D 00 00           mov     eax, [rbx+3DE0h]
00007FF91DFCFA0C  89 83 F0 3D 00 00           mov     [rbx+3DF0h], eax
00007FF91DFCFA12  8B 83 80 3E 00 00           mov     eax, [rbx+3E80h]
00007FF91DFCFA18  89 83 90 3E 00 00           mov     [rbx+3E90h], eax
00007FF91DFCFA1E  8B 83 70 3E 00 00           mov     eax, [rbx+3E70h]
00007FF91DFCFA24  89 83 80 3E 00 00           mov     [rbx+3E80h], eax
00007FF91DFCFA2A  F3 0F 11 83 90 3B 00 00     movss   dword ptr [rbx+3B90h], xmm0
00007FF91DFCFA32  F3 0F 11 8B A0 3B 00 00     movss   dword ptr [rbx+3BA0h], xmm1
00007FF91DFCFA3A  F3 0F 58 AB B0 41 00 00     addss   xmm5, dword ptr [rbx+41B0h]
00007FF91DFCFA42  F3 0F 59 9B B0 3E 00 00     mulss   xmm3, dword ptr [rbx+3EB0h]
00007FF91DFCFA4A  F3 0F 10 83 A0 3E 00 00     movss   xmm0, dword ptr [rbx+3EA0h]
00007FF91DFCFA52  F3 0F 11 93 B0 3B 00 00     movss   dword ptr [rbx+3BB0h], xmm2
00007FF91DFCFA5A  F3 0F 10 93 D0 3E 00 00     movss   xmm2, dword ptr [rbx+3ED0h]
00007FF91DFCFA62  F3 0F 59 AB C0 41 00 00     mulss   xmm5, dword ptr [rbx+41C0h]
00007FF91DFCFA6A  F3 0F 5F D3                 maxss   xmm2, xmm3
00007FF91DFCFA6E  F3 0F 58 AB A0 41 00 00     addss   xmm5, dword ptr [rbx+41A0h]
00007FF91DFCFA76  F3 0F 11 93 C0 3B 00 00     movss   dword ptr [rbx+3BC0h], xmm2
00007FF91DFCFA7E  F3 0F 58 83 F0 37 00 00     addss   xmm0, dword ptr [rbx+37F0h]
00007FF91DFCFA86  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFCFA8A  F3 0F 11 83 E0 3B 00 00     movss   dword ptr [rbx+3BE0h], xmm0
00007FF91DFCFA92  76 05                       jbe     short loc_7FF91DFCFA99
00007FF91DFCFA94  0F 5A C5                    cvtps2pd xmm0, xmm5
00007FF91DFCFA97  EB 03                       jmp     short loc_7FF91DFCFA9C
00007FF91DFCFA99  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCFA9C  F3 0F 10 0D B8 54 77 00     movss   xmm1, cs:dword_7FF91E744F5C
00007FF91DFCFAA4  F3 44 0F 10 15 3B 57 77 00  movss   xmm10, cs:flt_7FF91E7451E8
00007FF91DFCFAAD  F3 0F 5E CA                 divss   xmm1, xmm2
00007FF91DFCFAB1  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFCFAB5  F3 0F 11 8B D0 3B 00 00     movss   dword ptr [rbx+3BD0h], xmm1
00007FF91DFCFABD  F3 0F 11 83 60 3E 00 00     movss   dword ptr [rbx+3E60h], xmm0
00007FF91DFCFAC5  F3 0F 10 B3 20 3C 00 00     movss   xmm6, dword ptr [rbx+3C20h]
00007FF91DFCFACD  F3 0F 10 8B 00 3C 00 00     movss   xmm1, dword ptr [rbx+3C00h]
00007FF91DFCFAD5  F3 0F 11 B3 40 3B 00 00     movss   dword ptr [rbx+3B40h], xmm6
00007FF91DFCFADD  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFCFAE1  F3 0F 11 8B 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm1
00007FF91DFCFAE9  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFCFAED  76 1B                       jbe     short loc_7FF91DFCFB0A
00007FF91DFCFAEF  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCFAF4  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCFAF8  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCFAFB  E8 D8 F9 37 00              call    fmodf
00007FF91DFCFB00  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCFB03  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCFB08  EB 1F                       jmp     short loc_7FF91DFCFB29
00007FF91DFCFB0A  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFCFB0E  73 19                       jnb     short loc_7FF91DFCFB29
00007FF91DFCFB10  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCFB15  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCFB19  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCFB1C  E8 B7 F9 37 00              call    fmodf
00007FF91DFCFB21  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCFB24  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCFB29  F3 44 0F 10 25 DA 54 77 00  movss   xmm12, cs:dword_7FF91E74500C
00007FF91DFCFB32  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCFB35  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCFB3A  F3 0F 11 B3 30 3B 00 00     movss   dword ptr [rbx+3B30h], xmm6
00007FF91DFCFB42  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFCFB45  F3 0F 59 BB 20 3F 00 00     mulss   xmm7, dword ptr [rbx+3F20h]
00007FF91DFCFB4D  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFCFB52  E8 69 94 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCFB57  F3 44 0F 10 1D E4 58 77 00  movss   xmm11, cs:dword_7FF91E745444
00007FF91DFCFB60  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFCFB63  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFCFB68  F3 0F 59 AB D0 3B 00 00     mulss   xmm5, dword ptr [rbx+3BD0h]
00007FF91DFCFB70  F3 0F 59 AB F0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EF0h]
00007FF91DFCFB78  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCFB7C  73 06                       jnb     short loc_7FF91DFCFB84
00007FF91DFCFB7E  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCFB82  EB 05                       jmp     short loc_7FF91DFCFB89
00007FF91DFCFB84  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCFB89  F3 0F 59 AB C0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EC0h]
00007FF91DFCFB91  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCFB94  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFCFB98  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCFB9B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCFB9E  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFCFBA6  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCFBA9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCFBAD  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCFBB0  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
00007FF91DFCFBB8  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFCFBC0  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFCFBC4  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
00007FF91DFCFBCC  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCFBD0  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCFBD3  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFCFBDB  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCFBDF  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCFBE3  F3 0F 10 8B E0 3B 00 00     movss   xmm1, dword ptr [rbx+3BE0h]
00007FF91DFCFBEB  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCFBEF  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCFBF2  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFCFBF6  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCFBFA  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCFBFE  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFCFC02  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFCFC06  F3 0F 11 A3 30 3C 00 00     movss   dword ptr [rbx+3C30h], xmm4
00007FF91DFCFC0E  72 07                       jb      short loc_7FF91DFCFC17
00007FF91DFCFC10  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFCFC15  EB 05                       jmp     short loc_7FF91DFCFC1C
00007FF91DFCFC17  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFCFC1C  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCFC1F  73 06                       jnb     short loc_7FF91DFCFC27
00007FF91DFCFC21  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFCFC25  EB 06                       jmp     short loc_7FF91DFCFC2D
00007FF91DFCFC27  76 04                       jbe     short loc_7FF91DFCFC2D
00007FF91DFCFC29  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFCFC2D  F3 44 0F 10 83 30 3B 00 00  movss   xmm8, dword ptr [rbx+3B30h]
00007FF91DFCFC36  F3 0F 59 B3 30 3F 00 00     mulss   xmm6, dword ptr [rbx+3F30h]
00007FF91DFCFC3E  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFCFC42  E8 79 93 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCFC47  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFCFC4A  F3 0F 10 83 E0 3E 00 00     movss   xmm0, dword ptr [rbx+3EE0h]
00007FF91DFCFC52  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFCFC56  72 18                       jb      short loc_7FF91DFCFC70
00007FF91DFCFC58  0F 2F 83 40 3B 00 00        comiss  xmm0, dword ptr [rbx+3B40h]
00007FF91DFCFC5F  76 0F                       jbe     short loc_7FF91DFCFC70
00007FF91DFCFC61  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
00007FF91DFCFC69  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFCFC6E  EB 08                       jmp     short loc_7FF91DFCFC78
00007FF91DFCFC70  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
00007FF91DFCFC78  0F 2F 3D 51 56 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFCFC7F  F3 0F 59 A3 D0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BD0h]
00007FF91DFCFC87  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFCFC8C  F3 0F 59 A3 00 3F 00 00     mulss   xmm4, dword ptr [rbx+3F00h]
00007FF91DFCFC94  72 03                       jb      short loc_7FF91DFCFC99
00007FF91DFCFC96  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFCFC99  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFCFC9D  73 06                       jnb     short loc_7FF91DFCFCA5
00007FF91DFCFC9F  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFCFCA3  EB 05                       jmp     short loc_7FF91DFCFCAA
00007FF91DFCFCA5  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFCFCAA  F3 0F 11 BB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm7
00007FF91DFCFCB2  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFCFCB7  F3 0F 59 A3 C0 3E 00 00     mulss   xmm4, dword ptr [rbx+3EC0h]
00007FF91DFCFCBF  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFCFCC2  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFCFCC7  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFCFCCB  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCFCCE  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFCFCD3  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCFCD7  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCFCDA  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCFCDE  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFCFCE2  F3 44 0F 59 8B 90 40 00 00  mulss   xmm9, dword ptr [rbx+4090h]
00007FF91DFCFCEB  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFCFCF0  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCFCF3  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFCFCFB  F3 44 0F 58 8B 80 40 00 00  addss   xmm9, dword ptr [rbx+4080h]
00007FF91DFCFD04  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFCFD0C  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFCFD11  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCFD14  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFCFD1C  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFCFD21  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCFD25  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFCFD2A  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFCFD2D  0F 54 05 5C 5A 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFCFD34  0F 57 05 85 5A 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFCFD3B  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFCFD40  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFCFD45  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFCFD4A  F3 44 0F 11 8B 40 3C 00 00  movss   dword ptr [rbx+3C40h], xmm9
00007FF91DFCFD53  E8 68 92 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCFD58  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFCFD5C  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFCFD60  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFCFD65  73 06                       jnb     short loc_7FF91DFCFD6D
00007FF91DFCFD67  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFCFD6B  EB 06                       jmp     short loc_7FF91DFCFD73
00007FF91DFCFD6D  76 04                       jbe     short loc_7FF91DFCFD73
00007FF91DFCFD6F  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFCFD73  F3 44 0F 59 83 D0 3B 00 00  mulss   xmm8, dword ptr [rbx+3BD0h]
00007FF91DFCFD7C  F3 0F 59 BB 40 3F 00 00     mulss   xmm7, dword ptr [rbx+3F40h]
00007FF91DFCFD84  F3 44 0F 59 05 0B AF 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFCFD8D  F3 44 0F 59 83 10 3F 00 00  mulss   xmm8, dword ptr [rbx+3F10h]
00007FF91DFCFD96  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFCFD9A  73 06                       jnb     short loc_7FF91DFCFDA2
00007FF91DFCFD9C  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFCFDA0  EB 05                       jmp     short loc_7FF91DFCFDA7
00007FF91DFCFDA2  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFCFDA7  F3 44 0F 59 83 C0 3E 00 00  mulss   xmm8, dword ptr [rbx+3EC0h]
00007FF91DFCFDB0  F3 44 0F 59 8B A0 3B 00 00  mulss   xmm9, dword ptr [rbx+3BA0h]
00007FF91DFCFDB9  F3 0F 10 B3 30 3B 00 00     movss   xmm6, dword ptr [rbx+3B30h]
00007FF91DFCFDC1  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCFDC5  F3 0F 10 AB 50 3B 00 00     movss   xmm5, dword ptr [rbx+3B50h]
00007FF91DFCFDCD  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFCFDD2  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCFDD5  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCFDD8  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCFDDC  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCFDDF  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
00007FF91DFCFDE7  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCFDEA  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFCFDF2  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
00007FF91DFCFDFA  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFCFDFF  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFCFE07  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCFE0B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCFE0E  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFCFE16  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCFE1A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCFE1E  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCFE22  F3 0F 10 83 30 3C 00 00     movss   xmm0, dword ptr [rbx+3C30h]
00007FF91DFCFE2A  F3 0F 59 83 90 3B 00 00     mulss   xmm0, dword ptr [rbx+3B90h]
00007FF91DFCFE32  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCFE36  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFCFE3B  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFCFE40  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFCFE44  F3 0F 59 A3 B0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BB0h]
00007FF91DFCFE4C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCFE50  F3 0F 11 A3 60 3C 00 00     movss   dword ptr [rbx+3C60h], xmm4
00007FF91DFCFE58  F3 0F 11 B3 40 3B 00 00     movss   dword ptr [rbx+3B40h], xmm6
00007FF91DFCFE60  F3 0F 11 AB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm5
00007FF91DFCFE68  F3 0F 58 B3 C0 3B 00 00     addss   xmm6, dword ptr [rbx+3BC0h]
00007FF91DFCFE70  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFCFE74  76 1B                       jbe     short loc_7FF91DFCFE91
00007FF91DFCFE76  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCFE7B  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCFE7F  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCFE82  E8 51 F6 37 00              call    fmodf
00007FF91DFCFE87  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCFE8A  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCFE8F  EB 1F                       jmp     short loc_7FF91DFCFEB0
00007FF91DFCFE91  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFCFE95  73 19                       jnb     short loc_7FF91DFCFEB0
00007FF91DFCFE97  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCFE9C  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCFEA0  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCFEA3  E8 30 F6 37 00              call    fmodf
00007FF91DFCFEA8  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCFEAB  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCFEB0  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCFEB3  F3 0F 11 B3 30 3B 00 00     movss   dword ptr [rbx+3B30h], xmm6
00007FF91DFCFEBB  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCFEC0  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFCFEC3  F3 0F 59 BB 20 3F 00 00     mulss   xmm7, dword ptr [rbx+3F20h]
00007FF91DFCFECB  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFCFED0  E8 EB 90 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCFED5  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFCFED8  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFCFEDD  F3 0F 59 AB D0 3B 00 00     mulss   xmm5, dword ptr [rbx+3BD0h]
00007FF91DFCFEE5  F3 0F 59 AB F0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EF0h]
00007FF91DFCFEED  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCFEF1  73 06                       jnb     short loc_7FF91DFCFEF9
00007FF91DFCFEF3  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCFEF7  EB 05                       jmp     short loc_7FF91DFCFEFE
00007FF91DFCFEF9  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCFEFE  F3 0F 59 AB C0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EC0h]
00007FF91DFCFF06  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCFF09  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFCFF0D  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCFF10  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCFF13  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFCFF1B  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCFF1E  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCFF22  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCFF25  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
00007FF91DFCFF2D  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFCFF35  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFCFF39  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
00007FF91DFCFF41  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCFF45  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCFF48  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFCFF50  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCFF54  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCFF58  F3 0F 10 8B E0 3B 00 00     movss   xmm1, dword ptr [rbx+3BE0h]
00007FF91DFCFF60  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCFF64  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCFF67  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFCFF6B  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCFF6F  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCFF73  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFCFF77  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFCFF7B  F3 0F 11 A3 30 3C 00 00     movss   dword ptr [rbx+3C30h], xmm4
00007FF91DFCFF83  72 07                       jb      short loc_7FF91DFCFF8C
00007FF91DFCFF85  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFCFF8A  EB 05                       jmp     short loc_7FF91DFCFF91
00007FF91DFCFF8C  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFCFF91  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCFF94  73 06                       jnb     short loc_7FF91DFCFF9C
00007FF91DFCFF96  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFCFF9A  EB 06                       jmp     short loc_7FF91DFCFFA2
00007FF91DFCFF9C  76 04                       jbe     short loc_7FF91DFCFFA2
00007FF91DFCFF9E  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFCFFA2  F3 44 0F 10 83 30 3B 00 00  movss   xmm8, dword ptr [rbx+3B30h]
00007FF91DFCFFAB  F3 0F 59 B3 30 3F 00 00     mulss   xmm6, dword ptr [rbx+3F30h]
00007FF91DFCFFB3  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFCFFB7  E8 04 90 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCFFBC  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFCFFBF  F3 0F 10 83 E0 3E 00 00     movss   xmm0, dword ptr [rbx+3EE0h]
00007FF91DFCFFC7  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFCFFCB  72 18                       jb      short loc_7FF91DFCFFE5
00007FF91DFCFFCD  0F 2F 83 40 3B 00 00        comiss  xmm0, dword ptr [rbx+3B40h]
00007FF91DFCFFD4  76 0F                       jbe     short loc_7FF91DFCFFE5
00007FF91DFCFFD6  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
00007FF91DFCFFDE  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFCFFE3  EB 08                       jmp     short loc_7FF91DFCFFED
00007FF91DFCFFE5  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
00007FF91DFCFFED  0F 2F 3D DC 52 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFCFFF4  F3 0F 59 A3 D0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BD0h]
00007FF91DFCFFFC  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFD0001  F3 0F 59 A3 00 3F 00 00     mulss   xmm4, dword ptr [rbx+3F00h]
00007FF91DFD0009  72 03                       jb      short loc_7FF91DFD000E
00007FF91DFD000B  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD000E  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD0012  73 06                       jnb     short loc_7FF91DFD001A
00007FF91DFD0014  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD0018  EB 05                       jmp     short loc_7FF91DFD001F
00007FF91DFD001A  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD001F  F3 0F 11 BB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm7
00007FF91DFD0027  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD002C  F3 0F 59 A3 C0 3E 00 00     mulss   xmm4, dword ptr [rbx+3EC0h]
00007FF91DFD0034  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD0037  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD003C  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD0040  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD0043  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFD0048  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD004C  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD004F  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD0053  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFD0057  F3 44 0F 59 8B 90 40 00 00  mulss   xmm9, dword ptr [rbx+4090h]
00007FF91DFD0060  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD0065  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD0068  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFD0070  F3 44 0F 58 8B 80 40 00 00  addss   xmm9, dword ptr [rbx+4080h]
00007FF91DFD0079  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFD0081  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD0086  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD0089  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFD0091  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFD0096  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD009A  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD009F  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD00A2  0F 54 05 E7 56 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFD00A9  0F 57 05 10 57 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD00B0  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFD00B5  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFD00BA  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFD00BF  F3 44 0F 11 8B 40 3C 00 00  movss   dword ptr [rbx+3C40h], xmm9
00007FF91DFD00C8  E8 F3 8E FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD00CD  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD00D1  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD00D5  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD00DA  73 06                       jnb     short loc_7FF91DFD00E2
00007FF91DFD00DC  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD00E0  EB 06                       jmp     short loc_7FF91DFD00E8
00007FF91DFD00E2  76 04                       jbe     short loc_7FF91DFD00E8
00007FF91DFD00E4  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD00E8  F3 44 0F 59 83 D0 3B 00 00  mulss   xmm8, dword ptr [rbx+3BD0h]
00007FF91DFD00F1  F3 0F 59 BB 40 3F 00 00     mulss   xmm7, dword ptr [rbx+3F40h]
00007FF91DFD00F9  F3 44 0F 59 05 96 AB 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFD0102  F3 44 0F 59 83 10 3F 00 00  mulss   xmm8, dword ptr [rbx+3F10h]
00007FF91DFD010B  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFD010F  73 06                       jnb     short loc_7FF91DFD0117
00007FF91DFD0111  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFD0115  EB 05                       jmp     short loc_7FF91DFD011C
00007FF91DFD0117  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFD011C  F3 44 0F 59 83 C0 3E 00 00  mulss   xmm8, dword ptr [rbx+3EC0h]
00007FF91DFD0125  F3 44 0F 59 8B A0 3B 00 00  mulss   xmm9, dword ptr [rbx+3BA0h]
00007FF91DFD012E  F3 0F 10 B3 30 3B 00 00     movss   xmm6, dword ptr [rbx+3B30h]
00007FF91DFD0136  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD013A  F3 0F 10 AB 50 3B 00 00     movss   xmm5, dword ptr [rbx+3B50h]
00007FF91DFD0142  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFD0147  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD014A  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD014D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD0151  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD0154  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
00007FF91DFD015C  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD015F  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFD0167  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
00007FF91DFD016F  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD0174  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFD017C  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD0180  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD0183  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFD018B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD018F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD0193  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD0197  F3 0F 10 83 30 3C 00 00     movss   xmm0, dword ptr [rbx+3C30h]
00007FF91DFD019F  F3 0F 59 83 90 3B 00 00     mulss   xmm0, dword ptr [rbx+3B90h]
00007FF91DFD01A7  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD01AB  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFD01B0  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFD01B5  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD01B9  F3 0F 59 A3 B0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BB0h]
00007FF91DFD01C1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD01C5  F3 0F 11 A3 E0 3C 00 00     movss   dword ptr [rbx+3CE0h], xmm4
00007FF91DFD01CD  F3 0F 11 B3 40 3B 00 00     movss   dword ptr [rbx+3B40h], xmm6
00007FF91DFD01D5  F3 0F 11 AB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm5
00007FF91DFD01DD  F3 0F 58 B3 C0 3B 00 00     addss   xmm6, dword ptr [rbx+3BC0h]
00007FF91DFD01E5  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD01E9  76 1B                       jbe     short loc_7FF91DFD0206
00007FF91DFD01EB  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD01F0  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD01F4  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD01F7  E8 DC F2 37 00              call    fmodf
00007FF91DFD01FC  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD01FF  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD0204  EB 1F                       jmp     short loc_7FF91DFD0225
00007FF91DFD0206  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD020A  73 19                       jnb     short loc_7FF91DFD0225
00007FF91DFD020C  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD0211  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD0215  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD0218  E8 BB F2 37 00              call    fmodf
00007FF91DFD021D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD0220  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD0225  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD0228  F3 0F 11 B3 30 3B 00 00     movss   dword ptr [rbx+3B30h], xmm6
00007FF91DFD0230  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD0235  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD0238  F3 0F 59 BB 20 3F 00 00     mulss   xmm7, dword ptr [rbx+3F20h]
00007FF91DFD0240  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFD0245  E8 76 8D FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD024A  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFD024D  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFD0252  F3 0F 59 AB D0 3B 00 00     mulss   xmm5, dword ptr [rbx+3BD0h]
00007FF91DFD025A  F3 0F 59 AB F0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EF0h]
00007FF91DFD0262  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD0266  73 06                       jnb     short loc_7FF91DFD026E
00007FF91DFD0268  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD026C  EB 05                       jmp     short loc_7FF91DFD0273
00007FF91DFD026E  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD0273  F3 0F 59 AB C0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EC0h]
00007FF91DFD027B  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD027E  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD0282  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD0285  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD0288  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFD0290  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD0293  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD0297  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD029A  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
00007FF91DFD02A2  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFD02AA  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD02AE  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
00007FF91DFD02B6  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD02BA  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD02BD  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFD02C5  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD02C9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD02CD  F3 0F 10 8B E0 3B 00 00     movss   xmm1, dword ptr [rbx+3BE0h]
00007FF91DFD02D5  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD02D9  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD02DC  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFD02E0  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD02E4  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD02E8  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD02EC  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD02F0  F3 0F 11 A3 30 3C 00 00     movss   dword ptr [rbx+3C30h], xmm4
00007FF91DFD02F8  72 07                       jb      short loc_7FF91DFD0301
00007FF91DFD02FA  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD02FF  EB 05                       jmp     short loc_7FF91DFD0306
00007FF91DFD0301  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFD0306  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD0309  73 06                       jnb     short loc_7FF91DFD0311
00007FF91DFD030B  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFD030F  EB 06                       jmp     short loc_7FF91DFD0317
00007FF91DFD0311  76 04                       jbe     short loc_7FF91DFD0317
00007FF91DFD0313  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD0317  F3 44 0F 10 83 30 3B 00 00  movss   xmm8, dword ptr [rbx+3B30h]
00007FF91DFD0320  F3 0F 59 B3 30 3F 00 00     mulss   xmm6, dword ptr [rbx+3F30h]
00007FF91DFD0328  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFD032C  E8 8F 8C FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD0331  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD0334  F3 0F 10 83 E0 3E 00 00     movss   xmm0, dword ptr [rbx+3EE0h]
00007FF91DFD033C  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFD0340  72 18                       jb      short loc_7FF91DFD035A
00007FF91DFD0342  0F 2F 83 40 3B 00 00        comiss  xmm0, dword ptr [rbx+3B40h]
00007FF91DFD0349  76 0F                       jbe     short loc_7FF91DFD035A
00007FF91DFD034B  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
00007FF91DFD0353  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFD0358  EB 08                       jmp     short loc_7FF91DFD0362
00007FF91DFD035A  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
00007FF91DFD0362  0F 2F 3D 67 4F 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFD0369  F3 0F 59 A3 D0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BD0h]
00007FF91DFD0371  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFD0376  F3 0F 59 A3 00 3F 00 00     mulss   xmm4, dword ptr [rbx+3F00h]
00007FF91DFD037E  72 03                       jb      short loc_7FF91DFD0383
00007FF91DFD0380  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD0383  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD0387  73 06                       jnb     short loc_7FF91DFD038F
00007FF91DFD0389  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD038D  EB 05                       jmp     short loc_7FF91DFD0394
00007FF91DFD038F  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD0394  F3 0F 11 BB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm7
00007FF91DFD039C  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD03A1  F3 0F 59 A3 C0 3E 00 00     mulss   xmm4, dword ptr [rbx+3EC0h]
00007FF91DFD03A9  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD03AC  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD03B1  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD03B5  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD03B8  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFD03BD  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD03C1  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD03C4  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD03C8  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFD03CC  F3 44 0F 59 8B 90 40 00 00  mulss   xmm9, dword ptr [rbx+4090h]
00007FF91DFD03D5  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD03DA  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD03DD  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFD03E5  F3 44 0F 58 8B 80 40 00 00  addss   xmm9, dword ptr [rbx+4080h]
00007FF91DFD03EE  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFD03F6  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD03FB  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD03FE  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFD0406  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFD040B  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD040F  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFD0414  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD0417  0F 54 05 72 53 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFD041E  0F 57 05 9B 53 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD0425  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFD042A  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFD042F  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFD0434  F3 44 0F 11 8B 40 3C 00 00  movss   dword ptr [rbx+3C40h], xmm9
00007FF91DFD043D  E8 7E 8B FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD0442  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD0446  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD044A  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD044F  73 06                       jnb     short loc_7FF91DFD0457
00007FF91DFD0451  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD0455  EB 06                       jmp     short loc_7FF91DFD045D
00007FF91DFD0457  76 04                       jbe     short loc_7FF91DFD045D
00007FF91DFD0459  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD045D  F3 44 0F 59 83 D0 3B 00 00  mulss   xmm8, dword ptr [rbx+3BD0h]
00007FF91DFD0466  F3 0F 59 BB 40 3F 00 00     mulss   xmm7, dword ptr [rbx+3F40h]
00007FF91DFD046E  F3 44 0F 59 05 21 A8 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFD0477  F3 44 0F 59 83 10 3F 00 00  mulss   xmm8, dword ptr [rbx+3F10h]
00007FF91DFD0480  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFD0484  73 06                       jnb     short loc_7FF91DFD048C
00007FF91DFD0486  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFD048A  EB 05                       jmp     short loc_7FF91DFD0491
00007FF91DFD048C  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFD0491  F3 44 0F 59 83 C0 3E 00 00  mulss   xmm8, dword ptr [rbx+3EC0h]
00007FF91DFD049A  F3 44 0F 59 8B A0 3B 00 00  mulss   xmm9, dword ptr [rbx+3BA0h]
00007FF91DFD04A3  F3 0F 10 B3 30 3B 00 00     movss   xmm6, dword ptr [rbx+3B30h]
00007FF91DFD04AB  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFD04AF  F3 0F 10 AB 50 3B 00 00     movss   xmm5, dword ptr [rbx+3B50h]
00007FF91DFD04B7  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFD04BC  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD04BF  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD04C2  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD04C6  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD04C9  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
00007FF91DFD04D1  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD04D4  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFD04DC  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
00007FF91DFD04E4  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD04E9  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFD04F1  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD04F5  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD04F8  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFD0500  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD0504  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD0508  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD050C  F3 0F 10 83 30 3C 00 00     movss   xmm0, dword ptr [rbx+3C30h]
00007FF91DFD0514  F3 0F 59 83 90 3B 00 00     mulss   xmm0, dword ptr [rbx+3B90h]
00007FF91DFD051C  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD0520  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFD0525  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFD052A  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD052E  F3 0F 59 A3 B0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BB0h]
00007FF91DFD0536  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD053A  F3 0F 11 A3 60 3D 00 00     movss   dword ptr [rbx+3D60h], xmm4
00007FF91DFD0542  F3 0F 11 B3 40 3B 00 00     movss   dword ptr [rbx+3B40h], xmm6
00007FF91DFD054A  F3 0F 11 AB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm5
00007FF91DFD0552  F3 0F 58 B3 C0 3B 00 00     addss   xmm6, dword ptr [rbx+3BC0h]
00007FF91DFD055A  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD055E  76 1B                       jbe     short loc_7FF91DFD057B
00007FF91DFD0560  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD0565  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD0569  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD056C  E8 67 EF 37 00              call    fmodf
00007FF91DFD0571  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD0574  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD0579  EB 1F                       jmp     short loc_7FF91DFD059A
00007FF91DFD057B  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD057F  73 19                       jnb     short loc_7FF91DFD059A
00007FF91DFD0581  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD0586  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFD058A  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD058D  E8 46 EF 37 00              call    fmodf
00007FF91DFD0592  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD0595  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD059A  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD059D  F3 0F 11 B3 30 3B 00 00     movss   dword ptr [rbx+3B30h], xmm6
00007FF91DFD05A5  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD05AA  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD05AD  F3 0F 59 BB 20 3F 00 00     mulss   xmm7, dword ptr [rbx+3F20h]
00007FF91DFD05B5  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFD05BA  E8 01 8A FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD05BF  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFD05C2  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFD05C7  F3 0F 59 AB D0 3B 00 00     mulss   xmm5, dword ptr [rbx+3BD0h]
00007FF91DFD05CF  F3 0F 59 AB F0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EF0h]
00007FF91DFD05D7  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFD05DB  73 06                       jnb     short loc_7FF91DFD05E3
00007FF91DFD05DD  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD05E1  EB 05                       jmp     short loc_7FF91DFD05E8
00007FF91DFD05E3  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFD05E8  F3 0F 59 AB C0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EC0h]
00007FF91DFD05F0  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFD05F3  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD05F7  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD05FA  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD05FD  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFD0605  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD0608  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD060C  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD060F  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
00007FF91DFD0617  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFD061F  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD0623  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
00007FF91DFD062B  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD062F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD0632  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFD063A  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD063E  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD0642  F3 0F 10 8B E0 3B 00 00     movss   xmm1, dword ptr [rbx+3BE0h]
00007FF91DFD064A  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD064E  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD0651  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFD0655  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD0659  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD065D  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD0661  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD0665  F3 0F 11 A3 30 3C 00 00     movss   dword ptr [rbx+3C30h], xmm4
00007FF91DFD066D  72 07                       jb      short loc_7FF91DFD0676
00007FF91DFD066F  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD0674  EB 05                       jmp     short loc_7FF91DFD067B
00007FF91DFD0676  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFD067B  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD067E  73 06                       jnb     short loc_7FF91DFD0686
00007FF91DFD0680  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFD0684  EB 06                       jmp     short loc_7FF91DFD068C
00007FF91DFD0686  76 04                       jbe     short loc_7FF91DFD068C
00007FF91DFD0688  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD068C  F3 44 0F 10 83 30 3B 00 00  movss   xmm8, dword ptr [rbx+3B30h]
00007FF91DFD0695  F3 0F 59 B3 30 3F 00 00     mulss   xmm6, dword ptr [rbx+3F30h]
00007FF91DFD069D  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFD06A1  E8 1A 89 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD06A6  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD06A9  F3 0F 10 83 E0 3E 00 00     movss   xmm0, dword ptr [rbx+3EE0h]
00007FF91DFD06B1  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFD06B5  72 18                       jb      short loc_7FF91DFD06CF
00007FF91DFD06B7  0F 2F 83 40 3B 00 00        comiss  xmm0, dword ptr [rbx+3B40h]
00007FF91DFD06BE  76 0F                       jbe     short loc_7FF91DFD06CF
00007FF91DFD06C0  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
00007FF91DFD06C8  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFD06CD  EB 08                       jmp     short loc_7FF91DFD06D7
00007FF91DFD06CF  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
00007FF91DFD06D7  0F 2F 3D F2 4B 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFD06DE  F3 0F 59 A3 D0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BD0h]
00007FF91DFD06E6  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFD06EB  F3 0F 59 A3 00 3F 00 00     mulss   xmm4, dword ptr [rbx+3F00h]
00007FF91DFD06F3  72 03                       jb      short loc_7FF91DFD06F8
00007FF91DFD06F5  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD06F8  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFD06FC  73 06                       jnb     short loc_7FF91DFD0704
00007FF91DFD06FE  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFD0702  EB 05                       jmp     short loc_7FF91DFD0709
00007FF91DFD0704  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFD0709  F3 0F 11 BB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm7
00007FF91DFD0711  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD0716  F3 0F 59 A3 C0 3E 00 00     mulss   xmm4, dword ptr [rbx+3EC0h]
00007FF91DFD071E  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFD0721  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD0726  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD072A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD072D  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFD0732  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD0736  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD0739  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD073D  44 0F 28 C2                 movaps  xmm8, xmm2
00007FF91DFD0741  F3 44 0F 59 83 90 40 00 00  mulss   xmm8, dword ptr [rbx+4090h]
00007FF91DFD074A  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD074F  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD0752  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFD075A  F3 44 0F 58 83 80 40 00 00  addss   xmm8, dword ptr [rbx+4080h]
00007FF91DFD0763  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFD076B  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFD0770  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD0773  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFD077B  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFD0780  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD0784  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFD0789  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFD078C  0F 54 05 FD 4F 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFD0793  0F 57 05 26 50 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD079A  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFD079F  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFD07A4  F3 44 0F 59 C6              mulss   xmm8, xmm6
00007FF91DFD07A9  F3 44 0F 11 83 40 3C 00 00  movss   dword ptr [rbx+3C40h], xmm8
00007FF91DFD07B2  E8 09 88 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD07B7  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD07BB  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD07C0  73 06                       jnb     short loc_7FF91DFD07C8
00007FF91DFD07C2  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD07C6  EB 06                       jmp     short loc_7FF91DFD07CE
00007FF91DFD07C8  76 04                       jbe     short loc_7FF91DFD07CE
00007FF91DFD07CA  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD07CE  F3 0F 59 83 D0 3B 00 00     mulss   xmm0, dword ptr [rbx+3BD0h]
00007FF91DFD07D6  F3 0F 59 BB 40 3F 00 00     mulss   xmm7, dword ptr [rbx+3F40h]
00007FF91DFD07DE  F3 0F 59 05 B2 A4 61 00     mulss   xmm0, cs:dword_7FF91E5EAC98
00007FF91DFD07E6  F3 0F 59 83 10 3F 00 00     mulss   xmm0, dword ptr [rbx+3F10h]
00007FF91DFD07EE  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFD07F2  72 09                       jb      short loc_7FF91DFD07FD
00007FF91DFD07F4  44 0F 28 F8                 movaps  xmm15, xmm0
00007FF91DFD07F8  F3 45 0F 5D FD              minss   xmm15, xmm13
00007FF91DFD07FD  F3 44 0F 59 BB C0 3E 00 00  mulss   xmm15, dword ptr [rbx+3EC0h]
00007FF91DFD0806  F3 44 0F 59 83 A0 3B 00 00  mulss   xmm8, dword ptr [rbx+3BA0h]
00007FF91DFD080F  F3 0F 10 AB 30 3B 00 00     movss   xmm5, dword ptr [rbx+3B30h]
00007FF91DFD0817  41 0F 28 D7                 movaps  xmm2, xmm15
00007FF91DFD081B  F3 0F 10 B3 50 3B 00 00     movss   xmm6, dword ptr [rbx+3B50h]
00007FF91DFD0823  F3 41 0F 59 D7              mulss   xmm2, xmm15
00007FF91DFD0828  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFD082B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD082E  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00007FF91DFD0836  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD0839  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD083D  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD0840  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00007FF91DFD0848  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
00007FF91DFD0850  F3 41 0F 59 DF              mulss   xmm3, xmm15
00007FF91DFD0855  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
00007FF91DFD085D  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD0861  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD0864  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00007FF91DFD086C  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD0870  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD0874  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD0878  F3 0F 10 83 30 3C 00 00     movss   xmm0, dword ptr [rbx+3C30h]
00007FF91DFD0880  F3 0F 59 83 90 3B 00 00     mulss   xmm0, dword ptr [rbx+3B90h]
00007FF91DFD0888  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD088C  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFD0891  F3 41 0F 58 E7              addss   xmm4, xmm15
00007FF91DFD0896  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFD089A  F3 0F 59 A3 B0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BB0h]
00007FF91DFD08A2  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD08A6  F3 0F 11 A3 E0 3D 00 00     movss   dword ptr [rbx+3DE0h], xmm4
00007FF91DFD08AE  F3 0F 10 93 50 3E 00 00     movss   xmm2, dword ptr [rbx+3E50h]
00007FF91DFD08B6  F3 0F 11 AB 10 3C 00 00     movss   dword ptr [rbx+3C10h], xmm5
00007FF91DFD08BE  F3 0F 11 B3 F0 3B 00 00     movss   dword ptr [rbx+3BF0h], xmm6
00007FF91DFD08C6  F3 0F 10 83 60 3D 00 00     movss   xmm0, dword ptr [rbx+3D60h]
00007FF91DFD08CE  F3 0F 58 83 50 3D 00 00     addss   xmm0, dword ptr [rbx+3D50h]
00007FF91DFD08D6  F3 0F 10 8B E0 3D 00 00     movss   xmm1, dword ptr [rbx+3DE0h]
00007FF91DFD08DE  F3 0F 58 8B D0 3C 00 00     addss   xmm1, dword ptr [rbx+3CD0h]
00007FF91DFD08E6  F3 0F 10 AB D0 3D 00 00     movss   xmm5, dword ptr [rbx+3DD0h]
00007FF91DFD08EE  F3 0F 58 AB E0 3C 00 00     addss   xmm5, dword ptr [rbx+3CE0h]
00007FF91DFD08F6  F3 0F 59 83 70 3F 00 00     mulss   xmm0, dword ptr [rbx+3F70h]
00007FF91DFD08FE  F3 0F 59 8B 80 3F 00 00     mulss   xmm1, dword ptr [rbx+3F80h]
00007FF91DFD0906  F3 0F 59 AB 60 3F 00 00     mulss   xmm5, dword ptr [rbx+3F60h]
00007FF91DFD090E  F3 0F 58 93 60 3C 00 00     addss   xmm2, dword ptr [rbx+3C60h]
00007FF91DFD0916  F3 0F 59 93 50 3F 00 00     mulss   xmm2, dword ptr [rbx+3F50h]
00007FF91DFD091E  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFD0922  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD0926  F3 0F 10 83 40 3E 00 00     movss   xmm0, dword ptr [rbx+3E40h]
00007FF91DFD092E  F3 0F 58 83 70 3C 00 00     addss   xmm0, dword ptr [rbx+3C70h]
00007FF91DFD0936  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD093A  F3 0F 10 8B C0 3D 00 00     movss   xmm1, dword ptr [rbx+3DC0h]
00007FF91DFD0942  F3 0F 59 83 90 3F 00 00     mulss   xmm0, dword ptr [rbx+3F90h]
00007FF91DFD094A  F3 0F 58 8B F0 3C 00 00     addss   xmm1, dword ptr [rbx+3CF0h]
00007FF91DFD0952  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD0956  F3 0F 10 83 70 3D 00 00     movss   xmm0, dword ptr [rbx+3D70h]
00007FF91DFD095E  F3 0F 58 83 40 3D 00 00     addss   xmm0, dword ptr [rbx+3D40h]
00007FF91DFD0966  F3 0F 59 8B A0 3F 00 00     mulss   xmm1, dword ptr [rbx+3FA0h]
00007FF91DFD096E  F3 0F 59 83 B0 3F 00 00     mulss   xmm0, dword ptr [rbx+3FB0h]
00007FF91DFD0976  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD097A  F3 0F 10 8B F0 3D 00 00     movss   xmm1, dword ptr [rbx+3DF0h]
00007FF91DFD0982  F3 0F 58 8B C0 3C 00 00     addss   xmm1, dword ptr [rbx+3CC0h]
00007FF91DFD098A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD098E  F3 0F 10 83 30 3E 00 00     movss   xmm0, dword ptr [rbx+3E30h]
00007FF91DFD0996  F3 0F 59 8B C0 3F 00 00     mulss   xmm1, dword ptr [rbx+3FC0h]
00007FF91DFD099E  F3 0F 58 83 80 3C 00 00     addss   xmm0, dword ptr [rbx+3C80h]
00007FF91DFD09A6  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD09AA  F3 0F 10 8B 00 3D 00 00     movss   xmm1, dword ptr [rbx+3D00h]
00007FF91DFD09B2  F3 0F 58 8B B0 3D 00 00     addss   xmm1, dword ptr [rbx+3DB0h]
00007FF91DFD09BA  F3 0F 59 83 D0 3F 00 00     mulss   xmm0, dword ptr [rbx+3FD0h]
00007FF91DFD09C2  F3 0F 59 8B E0 3F 00 00     mulss   xmm1, dword ptr [rbx+3FE0h]
00007FF91DFD09CA  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD09CE  F3 0F 10 83 80 3D 00 00     movss   xmm0, dword ptr [rbx+3D80h]
00007FF91DFD09D6  F3 0F 58 83 30 3D 00 00     addss   xmm0, dword ptr [rbx+3D30h]
00007FF91DFD09DE  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD09E2  F3 0F 10 8B B0 3C 00 00     movss   xmm1, dword ptr [rbx+3CB0h]
00007FF91DFD09EA  F3 0F 59 83 F0 3F 00 00     mulss   xmm0, dword ptr [rbx+3FF0h]
00007FF91DFD09F2  F3 0F 58 8B 00 3E 00 00     addss   xmm1, dword ptr [rbx+3E00h]
00007FF91DFD09FA  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD09FE  F3 0F 10 83 20 3E 00 00     movss   xmm0, dword ptr [rbx+3E20h]
00007FF91DFD0A06  F3 0F 59 8B 00 40 00 00     mulss   xmm1, dword ptr [rbx+4000h]
00007FF91DFD0A0E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD0A12  F3 0F 58 83 90 3C 00 00     addss   xmm0, dword ptr [rbx+3C90h]
00007FF91DFD0A1A  F3 0F 10 93 80 3E 00 00     movss   xmm2, dword ptr [rbx+3E80h]
00007FF91DFD0A22  F3 0F 10 8B A0 3D 00 00     movss   xmm1, dword ptr [rbx+3DA0h]
00007FF91DFD0A2A  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFD0A2D  F3 0F 59 A3 80 41 00 00     mulss   xmm4, dword ptr [rbx+4180h]
00007FF91DFD0A35  F3 0F 59 83 10 40 00 00     mulss   xmm0, dword ptr [rbx+4010h]
00007FF91DFD0A3D  F3 0F 58 A3 90 3E 00 00     addss   xmm4, dword ptr [rbx+3E90h]
00007FF91DFD0A45  F3 0F 58 8B 10 3D 00 00     addss   xmm1, dword ptr [rbx+3D10h]
00007FF91DFD0A4D  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD0A51  F3 0F 10 83 90 3D 00 00     movss   xmm0, dword ptr [rbx+3D90h]
00007FF91DFD0A59  F3 0F 58 83 20 3D 00 00     addss   xmm0, dword ptr [rbx+3D20h]
00007FF91DFD0A61  F3 0F 59 8B 20 40 00 00     mulss   xmm1, dword ptr [rbx+4020h]
00007FF91DFD0A69  F3 0F 59 83 30 40 00 00     mulss   xmm0, dword ptr [rbx+4030h]
00007FF91DFD0A71  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD0A75  F3 0F 10 8B 10 3E 00 00     movss   xmm1, dword ptr [rbx+3E10h]
00007FF91DFD0A7D  F3 0F 58 8B A0 3C 00 00     addss   xmm1, dword ptr [rbx+3CA0h]
00007FF91DFD0A85  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFD0A89  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD0A8C  F3 0F 59 8B 40 40 00 00     mulss   xmm1, dword ptr [rbx+4040h]
00007FF91DFD0A94  F3 0F 11 A3 80 3E 00 00     movss   dword ptr [rbx+3E80h], xmm4
00007FF91DFD0A9C  F3 0F 59 83 90 41 00 00     mulss   xmm0, dword ptr [rbx+4190h]
00007FF91DFD0AA4  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFD0AA8  F3 0F 58 C4                 addss   xmm0, xmm4
00007FF91DFD0AAC  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFD0AAF  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD0AB3  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD0AB6  F3 0F 59 83 80 41 00 00     mulss   xmm0, dword ptr [rbx+4180h]
00007FF91DFD0ABE  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFD0AC2  F3 0F 11 83 70 3E 00 00     movss   dword ptr [rbx+3E70h], xmm0
00007FF91DFD0ACA  F3 0F 10 93 D0 41 00 00     movss   xmm2, dword ptr [rbx+41D0h]
00007FF91DFD0AD2  F3 0F 59 9B 60 3E 00 00     mulss   xmm3, dword ptr [rbx+3E60h]
00007FF91DFD0ADA  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFD0ADE  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFD0AE2  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD0AE6  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFD0AEA  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFD0AEE  F3 0F 11 A3 50 3C 00 00     movss   dword ptr [rbx+3C50h], xmm4
00007FF91DFD0AF6  F3 0F 11 A3 D0 36 00 00     movss   dword ptr [rbx+36D0h], xmm4
00007FF91DFD0AFE  44 0F 2E AB A0 8C 01 00     ucomiss xmm13, dword ptr [rbx+18CA0h]
00007FF91DFD0B06  75 28                       jnz     short loc_7FF91DFD0B30
00007FF91DFD0B08  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
00007FF91DFD0B11  F3 0F 11 83 50 2A 00 00     movss   dword ptr [rbx+2A50h], xmm0
00007FF91DFD0B19  C7 83 A0 8C 01 00 00 00 00 00  mov     dword ptr [rbx+18CA0h], 0
00007FF91DFD0B23  0F 1F 40 00                 nop     dword ptr [rax+00h]
00007FF91DFD0B27  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00007FF91DFD0B30  8B 83 C0 52 00 00           mov     eax, [rbx+52C0h]
00007FF91DFD0B36  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
00007FF91DFD0B3E  48 8B 0F                    mov     rcx, [rdi]
00007FF91DFD0B41  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
00007FF91DFD0B46  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
00007FF91DFD0B4B  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
00007FF91DFD0B50  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
00007FF91DFD0B55  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
00007FF91DFD0B5A  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
00007FF91DFD0B5F  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
00007FF91DFD0B64  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
00007FF91DFD0B69  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
00007FF91DFD0B6F  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
00007FF91DFD0B75  89 01                       mov     [rcx], eax
00007FF91DFD0B77  8B 83 C0 52 00 00           mov     eax, [rbx+52C0h]
00007FF91DFD0B7D  48 8B 4F 08                 mov     rcx, [rdi+8]
00007FF91DFD0B81  49 8B 5B 18                 mov     rbx, [r11+18h]
00007FF91DFD0B85  89 01                       mov     [rcx], eax
00007FF91DFD0B87  49 8B E3                    mov     rsp, r11
00007FF91DFD0B8A  5F                          pop     rdi
00007FF91DFD0B8B  C3                          retn
