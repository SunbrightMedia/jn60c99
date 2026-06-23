; sub_18036CE00 @ 0x18036CE00 (RVA 0x36CE00) size=0x3D8C

000000018036CE00  48 8B C4                    mov     rax, rsp
000000018036CE03  48 89 58 10                 mov     [rax+10h], rbx
000000018036CE07  57                          push    rdi
000000018036CE08  48 81 EC C0 00 00 00        sub     rsp, 0C0h
000000018036CE0F  F3 0F 10 A1 50 2A 00 00     movss   xmm4, dword ptr [rcx+2A50h]
000000018036CE17  48 8B FA                    mov     rdi, rdx
000000018036CE1A  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
000000018036CE1E  48 8B D9                    mov     rbx, rcx
000000018036CE21  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
000000018036CE25  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
000000018036CE2A  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
000000018036CE2F  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
000000018036CE34  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
000000018036CE39  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
000000018036CE3E  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
000000018036CE44  F3 44 0F 10 2D 67 82 77 00  movss   xmm13, cs:dword_180AE50B4
000000018036CE4D  44 0F 2E A9 A0 8C 01 00     ucomiss xmm13, dword ptr [rcx+18CA0h]
000000018036CE55  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
000000018036CE5B  45 0F 57 F6                 xorps   xmm14, xmm14
000000018036CE5F  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
000000018036CE69  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
000000018036CE6F  75 16                       jnz     short loc_18036CE87
000000018036CE71  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
000000018036CE7A  0F 57 E4                    xorps   xmm4, xmm4
000000018036CE7D  C7 81 50 2A 00 00 00 00 00 00  mov     dword ptr [rcx+2A50h], 0
000000018036CE87  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
000000018036CE8F  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
000000018036CE97  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
000000018036CE9F  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
000000018036CEA7  F3 0F 59 05 15 DF 61 00     mulss   xmm0, cs:dword_18098ADC4
000000018036CEAF  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
000000018036CEB7  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
000000018036CEBF  F3 0F 2C D0                 cvttss2si edx, xmm0
000000018036CEC3  85 D2                       test    edx, edx
000000018036CEC5  75 07                       jnz     short loc_18036CECE
000000018036CEC7  BA 01 00 00 00              mov     edx, 1
000000018036CECC  EB 24                       jmp     short loc_18036CEF2
000000018036CECE  8B C2                       mov     eax, edx
000000018036CED0  25 00 00 20 00              and     eax, 200000h
000000018036CED5  0F BA E2 17                 bt      edx, 17h
000000018036CED9  73 08                       jnb     short loc_18036CEE3
000000018036CEDB  85 C0                       test    eax, eax
000000018036CEDD  75 0C                       jnz     short loc_18036CEEB
000000018036CEDF  03 D2                       add     edx, edx
000000018036CEE1  EB 0F                       jmp     short loc_18036CEF2
000000018036CEE3  85 C0                       test    eax, eax
000000018036CEE5  74 04                       jz      short loc_18036CEEB
000000018036CEE7  03 D2                       add     edx, edx
000000018036CEE9  EB 07                       jmp     short loc_18036CEF2
000000018036CEEB  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
000000018036CEF2  F3 0F 10 9B E0 29 00 00     movss   xmm3, dword ptr [rbx+29E0h]
000000018036CEFA  8B C2                       mov     eax, edx
000000018036CEFC  F3 0F 10 B3 C0 29 00 00     movss   xmm6, dword ptr [rbx+29C0h]
000000018036CF04  25 FF FF FF 00              and     eax, 0FFFFFFh
000000018036CF09  F3 44 0F 10 83 80 2A 00 00  movss   xmm8, dword ptr [rbx+2A80h]
000000018036CF12  8B CA                       mov     ecx, edx
000000018036CF14  F3 0F 10 BB 90 2A 00 00     movss   xmm7, dword ptr [rbx+2A90h]
000000018036CF1C  81 CA 00 00 00 FF           or      edx, 0FF000000h
000000018036CF22  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018036CF26  81 E1 00 00 00 01           and     ecx, 1000000h
000000018036CF2C  C7 83 C0 2A 00 00 00 00 00 00  mov     dword ptr [rbx+2AC0h], 0
000000018036CF36  F3 0F 11 9B F0 29 00 00     movss   dword ptr [rbx+29F0h], xmm3
000000018036CF3E  45 0F 57 D2                 xorps   xmm10, xmm10
000000018036CF42  0F 44 D0                    cmovz   edx, eax
000000018036CF45  F3 0F 11 B3 D0 29 00 00     movss   dword ptr [rbx+29D0h], xmm6
000000018036CF4D  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
000000018036CF53  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
000000018036CF59  8B 83 00 2B 00 00           mov     eax, [rbx+2B00h]
000000018036CF5F  66 0F 6E C2                 movd    xmm0, edx
000000018036CF63  0F 5B C0                    cvtdq2ps xmm0, xmm0
000000018036CF66  89 83 10 2B 00 00           mov     [rbx+2B10h], eax
000000018036CF6C  F3 0F 11 A3 70 2A 00 00     movss   dword ptr [rbx+2A70h], xmm4
000000018036CF74  F3 0F 59 05 F4 DC 61 00     mulss   xmm0, cs:dword_18098AC70
000000018036CF7C  F3 44 0F 11 83 A0 2A 00 00  movss   dword ptr [rbx+2AA0h], xmm8
000000018036CF85  F3 0F 11 BB B0 2A 00 00     movss   dword ptr [rbx+2AB0h], xmm7
000000018036CF8D  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
000000018036CF95  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
000000018036CF9D  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
000000018036CFA5  F3 0F 59 D0                 mulss   xmm2, xmm0
000000018036CFA9  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
000000018036CFB1  F3 0F 5C CA                 subss   xmm1, xmm2
000000018036CFB5  F3 0F 10 93 20 2A 00 00     movss   xmm2, dword ptr [rbx+2A20h]
000000018036CFBD  F3 0F 11 93 30 2A 00 00     movss   dword ptr [rbx+2A30h], xmm2
000000018036CFC5  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036CFC9  F3 0F 10 83 00 2A 00 00     movss   xmm0, dword ptr [rbx+2A00h]
000000018036CFD1  F3 0F 59 D0                 mulss   xmm2, xmm0
000000018036CFD5  F3 0F 11 83 10 2A 00 00     movss   dword ptr [rbx+2A10h], xmm0
000000018036CFDD  F3 0F 59 DA                 mulss   xmm3, xmm2
000000018036CFE1  0F 28 C2                    movaps  xmm0, xmm2
000000018036CFE4  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
000000018036CFEC  F3 0F 10 8B 40 2A 00 00     movss   xmm1, dword ptr [rbx+2A40h]
000000018036CFF4  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036CFF8  F3 0F 59 F2                 mulss   xmm6, xmm2
000000018036CFFC  F3 0F 11 8B 60 2A 00 00     movss   dword ptr [rbx+2A60h], xmm1
000000018036D004  F3 0F 11 93 D0 2A 00 00     movss   dword ptr [rbx+2AD0h], xmm2
000000018036D00C  F3 0F 5C F0                 subss   xmm6, xmm0
000000018036D010  0F 28 C4                    movaps  xmm0, xmm4
000000018036D013  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036D017  F3 0F 5C D8                 subss   xmm3, xmm0
000000018036D01B  F3 0F 58 F1                 addss   xmm6, xmm1
000000018036D01F  F3 0F 58 DC                 addss   xmm3, xmm4
000000018036D023  F3 0F 11 B3 E0 2A 00 00     movss   dword ptr [rbx+2AE0h], xmm6
000000018036D02B  F3 0F 11 9B F0 2A 00 00     movss   dword ptr [rbx+2AF0h], xmm3
000000018036D033  0F 28 CB                    movaps  xmm1, xmm3
000000018036D036  F3 0F 58 9B 30 2B 00 00     addss   xmm3, dword ptr [rbx+2B30h]
000000018036D03E  41 0F 2F DE                 comiss  xmm3, xmm14
000000018036D042  72 05                       jb      short loc_18036D049
000000018036D044  0F 57 C0                    xorps   xmm0, xmm0
000000018036D047  EB 03                       jmp     short loc_18036D04C
000000018036D049  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018036D04C  41 0F 2E CE                 ucomiss xmm1, xmm14
000000018036D050  F3 44 0F 10 3D 8B 84 77 00  movss   xmm15, cs:dword_180AE54E4
000000018036D059  75 06                       jnz     short loc_18036D061
000000018036D05B  41 0F 28 EF                 movaps  xmm5, xmm15
000000018036D05F  EB 04                       jmp     short loc_18036D065
000000018036D061  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
000000018036D065  41 0F 2F EE                 comiss  xmm5, xmm14
000000018036D069  F3 0F 11 AB 00 2B 00 00     movss   dword ptr [rbx+2B00h], xmm5
000000018036D071  73 06                       jnb     short loc_18036D079
000000018036D073  41 0F 28 EF                 movaps  xmm5, xmm15
000000018036D077  EB 06                       jmp     short loc_18036D07F
000000018036D079  76 04                       jbe     short loc_18036D07F
000000018036D07B  41 0F 28 ED                 movaps  xmm5, xmm13
000000018036D07F  F3 0F 10 83 70 2B 00 00     movss   xmm0, dword ptr [rbx+2B70h]
000000018036D087  F3 41 0F 58 ED              addss   xmm5, xmm13
000000018036D08C  F3 0F 10 93 10 2C 00 00     movss   xmm2, dword ptr [rbx+2C10h]
000000018036D094  F3 0F 10 8B 80 2B 00 00     movss   xmm1, dword ptr [rbx+2B80h]
000000018036D09C  8B 83 40 2B 00 00           mov     eax, [rbx+2B40h]
000000018036D0A2  0F 28 D9                    movaps  xmm3, xmm1
000000018036D0A5  F3 0F 10 A3 D0 2B 00 00     movss   xmm4, dword ptr [rbx+2BD0h]
000000018036D0AD  F3 0F 58 9B 20 2C 00 00     addss   xmm3, dword ptr [rbx+2C20h]
000000018036D0B5  F2 44 0F 10 25 E2 80 77 00  movsd   xmm12, cs:dbl_180AE51A0
000000018036D0BE  F3 0F 11 AB 20 2B 00 00     movss   dword ptr [rbx+2B20h], xmm5
000000018036D0C6  F3 0F 11 AB 40 2B 00 00     movss   dword ptr [rbx+2B40h], xmm5
000000018036D0CE  F3 0F 59 E8                 mulss   xmm5, xmm0
000000018036D0D2  89 83 50 2B 00 00           mov     [rbx+2B50h], eax
000000018036D0D8  F3 0F 11 A3 E0 2B 00 00     movss   dword ptr [rbx+2BE0h], xmm4
000000018036D0E0  F3 0F 5C E8                 subss   xmm5, xmm0
000000018036D0E4  0F 28 C2                    movaps  xmm0, xmm2
000000018036D0E7  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036D0EB  F3 0F 10 8B B0 2B 00 00     movss   xmm1, dword ptr [rbx+2BB0h]
000000018036D0F3  F3 0F 58 83 30 2C 00 00     addss   xmm0, dword ptr [rbx+2C30h]
000000018036D0FB  F3 41 0F 58 ED              addss   xmm5, xmm13
000000018036D100  F3 0F 5E C8                 divss   xmm1, xmm0
000000018036D104  F3 0F 10 83 40 2C 00 00     movss   xmm0, dword ptr [rbx+2C40h]
000000018036D10C  F3 0F 59 AB 60 2B 00 00     mulss   xmm5, dword ptr [rbx+2B60h]
000000018036D114  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018036D118  F3 0F 10 93 A0 2B 00 00     movss   xmm2, dword ptr [rbx+2BA0h]
000000018036D120  F3 0F 11 AB F0 2B 00 00     movss   dword ptr [rbx+2BF0h], xmm5
000000018036D128  F3 0F 5C D1                 subss   xmm2, xmm1
000000018036D12C  F3 0F 10 8B C0 2B 00 00     movss   xmm1, dword ptr [rbx+2BC0h]
000000018036D134  F3 0F 58 D6                 addss   xmm2, xmm6
000000018036D138  F3 0F 5C D4                 subss   xmm2, xmm4
000000018036D13C  F3 0F 11 93 A0 2B 00 00     movss   dword ptr [rbx+2BA0h], xmm2
000000018036D144  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018036D148  F3 0F 11 93 B0 2B 00 00     movss   dword ptr [rbx+2BB0h], xmm2
000000018036D150  F3 0F 58 D4                 addss   xmm2, xmm4
000000018036D154  F3 0F 5C E6                 subss   xmm4, xmm6
000000018036D158  0F 54 25 31 86 77 00        andps   xmm4, cs:xmmword_180AE5790
000000018036D15F  F3 0F 5C C4                 subss   xmm0, xmm4
000000018036D163  41 0F 2F C6                 comiss  xmm0, xmm14
000000018036D167  0F 83 E8 00 00 00           jnb     loc_18036D255
000000018036D16D  0F 57 C9                    xorps   xmm1, xmm1
000000018036D170  0F 5A C1                    cvtps2pd xmm0, xmm1
000000018036D173  41 0F 2E EE                 ucomiss xmm5, xmm14
000000018036D177  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018036D17B  0F 28 C8                    movaps  xmm1, xmm0
000000018036D17E  F3 0F 11 83 C0 2B 00 00     movss   dword ptr [rbx+2BC0h], xmm0
000000018036D186  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018036D18A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036D18E  F3 0F 5C C8                 subss   xmm1, xmm0
000000018036D192  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036D196  75 03                       jnz     short loc_18036D19B
000000018036D198  0F 28 CE                    movaps  xmm1, xmm6
000000018036D19B  8B 83 80 2C 00 00           mov     eax, [rbx+2C80h]
000000018036D1A1  48 8D 0D 58 2E C9 FF        lea     rcx, cs:180000000h
000000018036D1A8  F3 0F 59 BB 70 2C 00 00     mulss   xmm7, dword ptr [rbx+2C70h]
000000018036D1B0  89 83 90 2C 00 00           mov     [rbx+2C90h], eax
000000018036D1B6  F3 44 0F 59 83 60 2C 00 00  mulss   xmm8, dword ptr [rbx+2C60h]
000000018036D1BF  F3 0F 10 83 A0 2D 00 00     movss   xmm0, dword ptr [rbx+2DA0h]
000000018036D1C7  F3 0F 10 93 A0 2C 00 00     movss   xmm2, dword ptr [rbx+2CA0h]
000000018036D1CF  F3 44 0F 10 8B 00 2D 00 00  movss   xmm9, dword ptr [rbx+2D00h]
000000018036D1D8  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018036D1DD  F3 44 0F 10 83 E0 2C 00 00  movss   xmm8, dword ptr [rbx+2CE0h]
000000018036D1E6  F3 0F 2C C0                 cvttss2si eax, xmm0
000000018036D1EA  F3 0F 11 BB 80 2C 00 00     movss   dword ptr [rbx+2C80h], xmm7
000000018036D1F2  F3 0F 10 BB C0 2C 00 00     movss   xmm7, dword ptr [rbx+2CC0h]
000000018036D1FA  F3 0F 11 8B D0 2B 00 00     movss   dword ptr [rbx+2BD0h], xmm1
000000018036D202  F3 0F 11 8B 00 2C 00 00     movss   dword ptr [rbx+2C00h], xmm1
000000018036D20A  F3 0F 10 8B 60 2D 00 00     movss   xmm1, dword ptr [rbx+2D60h]
000000018036D212  F3 0F 11 BB D0 2C 00 00     movss   dword ptr [rbx+2CD0h], xmm7
000000018036D21A  F3 0F 11 93 B0 2C 00 00     movss   dword ptr [rbx+2CB0h], xmm2
000000018036D222  F3 44 0F 11 83 F0 2C 00 00  movss   dword ptr [rbx+2CF0h], xmm8
000000018036D22B  F3 44 0F 11 8B 10 2D 00 00  movss   dword ptr [rbx+2D10h], xmm9
000000018036D234  F3 0F 11 8B 70 2D 00 00     movss   dword ptr [rbx+2D70h], xmm1
000000018036D23C  83 F8 E0                    cmp     eax, 0FFFFFFE0h
000000018036D23F  7D 2F                       jge     short loc_18036D270
000000018036D241  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
000000018036D246  F7 D0                       not     eax
000000018036D248  48 98                       cdqe
000000018036D24A  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018036D253  EB 47                       jmp     short loc_18036D29C
000000018036D255  F3 0F 58 8B 50 2C 00 00     addss   xmm1, dword ptr [rbx+2C50h]
000000018036D25D  41 0F 2F CD                 comiss  xmm1, xmm13
000000018036D261  0F 82 09 FF FF FF           jb      loc_18036D170
000000018036D267  41 0F 28 C4                 movaps  xmm0, xmm12
000000018036D26B  E9 03 FF FF FF              jmp     loc_18036D173
000000018036D270  83 F8 20                    cmp     eax, 20h ; ' '
000000018036D273  7E 07                       jle     short loc_18036D27C
000000018036D275  B8 20 00 00 00              mov     eax, 20h ; ' '
000000018036D27A  EB 15                       jmp     short loc_18036D291
000000018036D27C  85 C0                       test    eax, eax
000000018036D27E  79 0F                       jns     short loc_18036D28F
000000018036D280  F7 D0                       not     eax
000000018036D282  48 98                       cdqe
000000018036D284  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018036D28D  EB 0D                       jmp     short loc_18036D29C
000000018036D28F  7E 0B                       jle     short loc_18036D29C
000000018036D291  48 98                       cdqe
000000018036D293  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
000000018036D29C  0F 57 05 1D 85 77 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018036D2A3  F3 0F 2C C0                 cvttss2si eax, xmm0
000000018036D2A7  83 F8 E0                    cmp     eax, 0FFFFFFE0h
000000018036D2AA  7D 14                       jge     short loc_18036D2C0
000000018036D2AC  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
000000018036D2B1  F7 D0                       not     eax
000000018036D2B3  48 98                       cdqe
000000018036D2B5  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018036D2BE  EB 2C                       jmp     short loc_18036D2EC
000000018036D2C0  83 F8 20                    cmp     eax, 20h ; ' '
000000018036D2C3  7E 07                       jle     short loc_18036D2CC
000000018036D2C5  B8 20 00 00 00              mov     eax, 20h ; ' '
000000018036D2CA  EB 15                       jmp     short loc_18036D2E1
000000018036D2CC  85 C0                       test    eax, eax
000000018036D2CE  79 0F                       jns     short loc_18036D2DF
000000018036D2D0  F7 D0                       not     eax
000000018036D2D2  48 98                       cdqe
000000018036D2D4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018036D2DD  EB 0D                       jmp     short loc_18036D2EC
000000018036D2DF  7E 0B                       jle     short loc_18036D2EC
000000018036D2E1  48 98                       cdqe
000000018036D2E3  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
000000018036D2EC  F3 0F 10 83 20 2D 00 00     movss   xmm0, dword ptr [rbx+2D20h]
000000018036D2F4  F3 0F 5C D1                 subss   xmm2, xmm1
000000018036D2F8  F3 0F 59 93 90 2D 00 00     mulss   xmm2, dword ptr [rbx+2D90h]
000000018036D300  F3 0F 58 D1                 addss   xmm2, xmm1
000000018036D304  F3 0F 10 8B 50 2D 00 00     movss   xmm1, dword ptr [rbx+2D50h]
000000018036D30C  F3 0F 11 93 60 2D 00 00     movss   dword ptr [rbx+2D60h], xmm2
000000018036D314  F3 0F 59 D0                 mulss   xmm2, xmm0
000000018036D318  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036D31C  F3 0F 5C D0                 subss   xmm2, xmm0
000000018036D320  F3 0F 58 D1                 addss   xmm2, xmm1
000000018036D324  41 0F 2F D6                 comiss  xmm2, xmm14
000000018036D328  76 05                       jbe     short loc_18036D32F
000000018036D32A  0F 5A C2                    cvtps2pd xmm0, xmm2
000000018036D32D  EB 03                       jmp     short loc_18036D332
000000018036D32F  0F 57 C0                    xorps   xmm0, xmm0
000000018036D332  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
000000018036D336  41 0F 2F CD                 comiss  xmm1, xmm13
000000018036D33A  72 06                       jb      short loc_18036D342
000000018036D33C  41 0F 28 C4                 movaps  xmm0, xmm12
000000018036D340  EB 03                       jmp     short loc_18036D345
000000018036D342  0F 5A C1                    cvtps2pd xmm0, xmm1
000000018036D345  F3 0F 10 B3 30 2D 00 00     movss   xmm6, dword ptr [rbx+2D30h]
000000018036D34D  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018036D351  F3 0F 59 83 C0 2D 00 00     mulss   xmm0, dword ptr [rbx+2DC0h]; X
000000018036D359  E8 E2 23 38 00              call    expf
000000018036D35E  F3 0F 59 83 B0 2D 00 00     mulss   xmm0, dword ptr [rbx+2DB0h]
000000018036D366  0F 28 CE                    movaps  xmm1, xmm6
000000018036D369  8B 83 30 2F 00 00           mov     eax, [rbx+2F30h]
000000018036D36F  F3 0F 59 8B 40 2D 00 00     mulss   xmm1, dword ptr [rbx+2D40h]
000000018036D377  89 83 40 2F 00 00           mov     [rbx+2F40h], eax
000000018036D37D  F3 0F 58 83 D0 2D 00 00     addss   xmm0, dword ptr [rbx+2DD0h]
000000018036D385  8B 83 50 2F 00 00           mov     eax, [rbx+2F50h]
000000018036D38B  F3 0F 10 9B F0 2E 00 00     movss   xmm3, dword ptr [rbx+2EF0h]
000000018036D393  F3 0F 59 BB 80 30 00 00     mulss   xmm7, dword ptr [rbx+3080h]
000000018036D39B  89 83 60 2F 00 00           mov     [rbx+2F60h], eax
000000018036D3A1  8B 83 70 2F 00 00           mov     eax, [rbx+2F70h]
000000018036D3A7  F3 0F 10 93 E0 2E 00 00     movss   xmm2, dword ptr [rbx+2EE0h]
000000018036D3AF  F3 0F 10 A3 10 2F 00 00     movss   xmm4, dword ptr [rbx+2F10h]
000000018036D3B7  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018036D3BB  89 83 80 2F 00 00           mov     [rbx+2F80h], eax
000000018036D3C1  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
000000018036D3C7  F3 0F 11 9B 00 2F 00 00     movss   dword ptr [rbx+2F00h], xmm3
000000018036D3CF  F3 0F 5C CE                 subss   xmm1, xmm6
000000018036D3D3  F3 0F 11 93 F0 2E 00 00     movss   dword ptr [rbx+2EF0h], xmm2
000000018036D3DB  F3 0F 11 A3 20 2F 00 00     movss   dword ptr [rbx+2F20h], xmm4
000000018036D3E3  F3 44 0F 11 83 B0 2E 00 00  movss   dword ptr [rbx+2EB0h], xmm8
000000018036D3EC  F3 44 0F 11 8B C0 2E 00 00  movss   dword ptr [rbx+2EC0h], xmm9
000000018036D3F5  89 83 A0 2E 00 00           mov     [rbx+2EA0h], eax
000000018036D3FB  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036D3FF  F3 0F 10 83 50 30 00 00     movss   xmm0, dword ptr [rbx+3050h]
000000018036D407  F3 0F 58 F8                 addss   xmm7, xmm0
000000018036D40B  F3 0F 11 83 40 30 00 00     movss   dword ptr [rbx+3040h], xmm0
000000018036D413  F3 0F 11 8B 80 2D 00 00     movss   dword ptr [rbx+2D80h], xmm1
000000018036D41B  41 0F 2F FF                 comiss  xmm7, xmm15
000000018036D41F  73 06                       jnb     short loc_18036D427
000000018036D421  41 0F 28 FF                 movaps  xmm7, xmm15
000000018036D425  EB 05                       jmp     short loc_18036D42C
000000018036D427  F3 41 0F 5D FD              minss   xmm7, xmm13
000000018036D42C  F3 0F 59 0D 8C D9 61 00     mulss   xmm1, cs:dword_18098ADC0
000000018036D434  41 0F 28 C5                 movaps  xmm0, xmm13
000000018036D438  F3 0F 10 B3 60 31 00 00     movss   xmm6, dword ptr [rbx+3160h]
000000018036D440  F3 0F 5C C3                 subss   xmm0, xmm3
000000018036D444  F3 0F 11 BB E0 2E 00 00     movss   dword ptr [rbx+2EE0h], xmm7
000000018036D44C  F3 0F 5D F1                 minss   xmm6, xmm1
000000018036D450  F3 0F 59 83 90 30 00 00     mulss   xmm0, dword ptr [rbx+3090h]
000000018036D458  F3 0F 58 C3                 addss   xmm0, xmm3
000000018036D45C  41 0F 2F C7                 comiss  xmm0, xmm15
000000018036D460  73 06                       jnb     short loc_18036D468
000000018036D462  41 0F 28 C7                 movaps  xmm0, xmm15
000000018036D466  EB 05                       jmp     short loc_18036D46D
000000018036D468  F3 41 0F 5D C5              minss   xmm0, xmm13
000000018036D46D  F3 0F 59 B3 70 31 00 00     mulss   xmm6, dword ptr [rbx+3170h]
000000018036D475  F3 0F 5C D7                 subss   xmm2, xmm7
000000018036D479  F3 0F 11 B3 90 2F 00 00     movss   dword ptr [rbx+2F90h], xmm6
000000018036D481  F3 0F 58 F4                 addss   xmm6, xmm4
000000018036D485  41 0F 2F D6                 comiss  xmm2, xmm14
000000018036D489  73 03                       jnb     short loc_18036D48E
000000018036D48B  0F 57 C0                    xorps   xmm0, xmm0
000000018036D48E  F3 0F 10 8B 60 30 00 00     movss   xmm1, dword ptr [rbx+3060h]
000000018036D496  F3 44 0F 10 9B A0 2E 00 00  movss   xmm11, dword ptr [rbx+2EA0h]
000000018036D49F  F3 0F 11 83 F0 2E 00 00     movss   dword ptr [rbx+2EF0h], xmm0
000000018036D4A7  F3 0F 58 83 F0 31 00 00     addss   xmm0, dword ptr [rbx+31F0h]
000000018036D4AF  72 04                       jb      short loc_18036D4B5
000000018036D4B1  41 0F 28 CD                 movaps  xmm1, xmm13
000000018036D4B5  F3 0F 59 83 E0 31 00 00     mulss   xmm0, dword ptr [rbx+31E0h]
000000018036D4BD  41 0F 28 FB                 movaps  xmm7, xmm11
000000018036D4C1  F3 0F 10 93 40 2F 00 00     movss   xmm2, dword ptr [rbx+2F40h]
000000018036D4C9  F3 0F 59 F1                 mulss   xmm6, xmm1
000000018036D4CD  F3 0F 5C FA                 subss   xmm7, xmm2
000000018036D4D1  41 0F 2F C6                 comiss  xmm0, xmm14
000000018036D4D5  F3 0F 59 B3 70 30 00 00     mulss   xmm6, dword ptr [rbx+3070h]
000000018036D4DD  76 05                       jbe     short loc_18036D4E4
000000018036D4DF  0F 5A C8                    cvtps2pd xmm1, xmm0
000000018036D4E2  EB 03                       jmp     short loc_18036D4E7
000000018036D4E4  0F 57 C9                    xorps   xmm1, xmm1
000000018036D4E7  41 0F 2F F5                 comiss  xmm6, xmm13
000000018036D4EB  F3 0F 59 BB B0 32 00 00     mulss   xmm7, dword ptr [rbx+32B0h]
000000018036D4F3  F3 44 0F 10 0D EC 7C 77 00  movss   xmm9, cs:flt_180AE51E8
000000018036D4FC  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
000000018036D500  F3 0F 58 FA                 addss   xmm7, xmm2
000000018036D504  F3 0F 11 BB 30 2F 00 00     movss   dword ptr [rbx+2F30h], xmm7
000000018036D50C  F3 0F 11 83 D0 2E 00 00     movss   dword ptr [rbx+2ED0h], xmm0
000000018036D514  41 0F 28 C3                 movaps  xmm0, xmm11
000000018036D518  F3 0F 59 BB A0 32 00 00     mulss   xmm7, dword ptr [rbx+32A0h]
000000018036D520  F3 0F 10 8B 20 31 00 00     movss   xmm1, dword ptr [rbx+3120h]
000000018036D528  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036D52C  F3 0F 59 F9                 mulss   xmm7, xmm1
000000018036D530  F3 0F 5C F8                 subss   xmm7, xmm0
000000018036D534  F3 0F 10 83 20 2F 00 00     movss   xmm0, dword ptr [rbx+2F20h]
000000018036D53C  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
000000018036D545  F3 41 0F 58 FB              addss   xmm7, xmm11
000000018036D54A  76 1B                       jbe     short loc_18036D567
000000018036D54C  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018036D551  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018036D555  0F 28 C6                    movaps  xmm0, xmm6; X
000000018036D558  E8 7B 1F 38 00              call    fmodf
000000018036D55D  0F 28 F0                    movaps  xmm6, xmm0
000000018036D560  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018036D565  EB 1F                       jmp     short loc_18036D586
000000018036D567  41 0F 2F F7                 comiss  xmm6, xmm15
000000018036D56B  73 19                       jnb     short loc_18036D586
000000018036D56D  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018036D572  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018036D576  0F 28 C6                    movaps  xmm0, xmm6; X
000000018036D579  E8 5A 1F 38 00              call    fmodf
000000018036D57E  0F 28 F0                    movaps  xmm6, xmm0
000000018036D581  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018036D586  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
000000018036D58F  0F 28 C6                    movaps  xmm0, xmm6
000000018036D592  41 0F 2F CE                 comiss  xmm1, xmm14
000000018036D596  F3 44 0F 10 83 60 2F 00 00  movss   xmm8, dword ptr [rbx+2F60h]
000000018036D59F  F3 0F 11 B3 10 2F 00 00     movss   dword ptr [rbx+2F10h], xmm6
000000018036D5A7  F3 0F 59 BB 90 32 00 00     mulss   xmm7, dword ptr [rbx+3290h]
000000018036D5AF  F3 0F 58 83 00 32 00 00     addss   xmm0, dword ptr [rbx+3200h]
000000018036D5B7  F3 0F 11 BB 90 2E 00 00     movss   dword ptr [rbx+2E90h], xmm7
000000018036D5BF  73 0A                       jnb     short loc_18036D5CB
000000018036D5C1  41 0F 2F F6                 comiss  xmm6, xmm14
000000018036D5C5  76 04                       jbe     short loc_18036D5CB
000000018036D5C7  45 0F 28 C3                 movaps  xmm8, xmm11
000000018036D5CB  41 0F 2F C5                 comiss  xmm0, xmm13
000000018036D5CF  76 15                       jbe     short loc_18036D5E6
000000018036D5D1  F3 41 0F 58 C5              addss   xmm0, xmm13; X
000000018036D5D6  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018036D5DA  E8 F9 1E 38 00              call    fmodf
000000018036D5DF  F3 41 0F 5C C5              subss   xmm0, xmm13
000000018036D5E4  EB 19                       jmp     short loc_18036D5FF
000000018036D5E6  41 0F 2F C7                 comiss  xmm0, xmm15
000000018036D5EA  73 13                       jnb     short loc_18036D5FF
000000018036D5EC  F3 41 0F 5C C5              subss   xmm0, xmm13; X
000000018036D5F1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018036D5F5  E8 DE 1E 38 00              call    fmodf
000000018036D5FA  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018036D5FF  F3 44 0F 10 1D B8 81 77 00  movss   xmm11, dword ptr cs:xmmword_180AE57C0
000000018036D608  F3 44 0F 11 83 50 2F 00 00  movss   dword ptr [rbx+2F50h], xmm8
000000018036D611  F3 0F 59 83 40 32 00 00     mulss   xmm0, dword ptr [rbx+3240h]
000000018036D619  F3 44 0F 59 83 80 32 00 00  mulss   xmm8, dword ptr [rbx+3280h]
000000018036D622  F3 0F 58 83 C0 32 00 00     addss   xmm0, dword ptr [rbx+32C0h]
000000018036D62A  F3 0F 11 83 A0 2F 00 00     movss   dword ptr [rbx+2FA0h], xmm0
000000018036D632  41 0F 57 C3                 xorps   xmm0, xmm11
000000018036D636  F3 44 0F 11 83 F0 2F 00 00  movss   dword ptr [rbx+2FF0h], xmm8
000000018036D63F  44 0F 28 C6                 movaps  xmm8, xmm6
000000018036D643  F3 44 0F 58 83 20 32 00 00  addss   xmm8, dword ptr [rbx+3220h]
000000018036D64C  F3 0F 11 83 B0 2F 00 00     movss   dword ptr [rbx+2FB0h], xmm0
000000018036D654  45 0F 2F C5                 comiss  xmm8, xmm13
000000018036D658  76 1D                       jbe     short loc_18036D677
000000018036D65A  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018036D65F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018036D663  41 0F 28 C0                 movaps  xmm0, xmm8; X
000000018036D667  E8 6C 1E 38 00              call    fmodf
000000018036D66C  44 0F 28 C0                 movaps  xmm8, xmm0
000000018036D670  F3 45 0F 5C C5              subss   xmm8, xmm13
000000018036D675  EB 21                       jmp     short loc_18036D698
000000018036D677  45 0F 2F C7                 comiss  xmm8, xmm15
000000018036D67B  73 1B                       jnb     short loc_18036D698
000000018036D67D  F3 45 0F 5C C5              subss   xmm8, xmm13
000000018036D682  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018036D686  41 0F 28 C0                 movaps  xmm0, xmm8; X
000000018036D68A  E8 49 1E 38 00              call    fmodf
000000018036D68F  44 0F 28 C0                 movaps  xmm8, xmm0
000000018036D693  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018036D698  0F 28 FE                    movaps  xmm7, xmm6
000000018036D69B  F3 0F 58 BB 10 32 00 00     addss   xmm7, dword ptr [rbx+3210h]
000000018036D6A3  41 0F 2F FD                 comiss  xmm7, xmm13
000000018036D6A7  76 1B                       jbe     short loc_18036D6C4
000000018036D6A9  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018036D6AE  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018036D6B2  0F 28 C7                    movaps  xmm0, xmm7; X
000000018036D6B5  E8 1E 1E 38 00              call    fmodf
000000018036D6BA  0F 28 F8                    movaps  xmm7, xmm0
000000018036D6BD  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018036D6C2  EB 1F                       jmp     short loc_18036D6E3
000000018036D6C4  41 0F 2F FF                 comiss  xmm7, xmm15
000000018036D6C8  73 19                       jnb     short loc_18036D6E3
000000018036D6CA  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018036D6CF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018036D6D3  0F 28 C7                    movaps  xmm0, xmm7; X
000000018036D6D6  E8 FD 1D 38 00              call    fmodf
000000018036D6DB  0F 28 F8                    movaps  xmm7, xmm0
000000018036D6DE  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018036D6E3  41 0F 28 C0                 movaps  xmm0, xmm8
000000018036D6E7  E8 D4 B8 FF FF              call    sub_180368FC0
000000018036D6EC  F3 0F 58 BB D0 32 00 00     addss   xmm7, dword ptr [rbx+32D0h]
000000018036D6F4  F3 0F 59 83 60 32 00 00     mulss   xmm0, dword ptr [rbx+3260h]
000000018036D6FC  41 0F 2F FE                 comiss  xmm7, xmm14
000000018036D700  73 06                       jnb     short loc_18036D708
000000018036D702  41 0F 28 FF                 movaps  xmm7, xmm15
000000018036D706  EB 06                       jmp     short loc_18036D70E
000000018036D708  76 04                       jbe     short loc_18036D70E
000000018036D70A  41 0F 28 FD                 movaps  xmm7, xmm13
000000018036D70E  F3 0F 58 B3 30 32 00 00     addss   xmm6, dword ptr [rbx+3230h]
000000018036D716  F3 0F 11 83 D0 2F 00 00     movss   dword ptr [rbx+2FD0h], xmm0
000000018036D71E  F3 0F 11 BB 30 30 00 00     movss   dword ptr [rbx+3030h], xmm7
000000018036D726  F3 0F 59 BB 50 32 00 00     mulss   xmm7, dword ptr [rbx+3250h]
000000018036D72E  41 0F 2F F5                 comiss  xmm6, xmm13
000000018036D732  F3 0F 58 BB E0 32 00 00     addss   xmm7, dword ptr [rbx+32E0h]
000000018036D73A  76 1B                       jbe     short loc_18036D757
000000018036D73C  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018036D741  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018036D745  0F 28 C6                    movaps  xmm0, xmm6; X
000000018036D748  E8 8B 1D 38 00              call    fmodf
000000018036D74D  0F 28 F0                    movaps  xmm6, xmm0
000000018036D750  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018036D755  EB 1F                       jmp     short loc_18036D776
000000018036D757  41 0F 2F F7                 comiss  xmm6, xmm15
000000018036D75B  73 19                       jnb     short loc_18036D776
000000018036D75D  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018036D762  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018036D766  0F 28 C6                    movaps  xmm0, xmm6; X
000000018036D769  E8 6A 1D 38 00              call    fmodf
000000018036D76E  0F 28 F0                    movaps  xmm6, xmm0
000000018036D771  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018036D776  0F 54 35 13 80 77 00        andps   xmm6, cs:xmmword_180AE5790
000000018036D77D  F3 0F 11 BB C0 2F 00 00     movss   dword ptr [rbx+2FC0h], xmm7
000000018036D785  0F 28 E6                    movaps  xmm4, xmm6
000000018036D788  F3 0F 10 9B 00 31 00 00     movss   xmm3, dword ptr [rbx+3100h]
000000018036D790  0F 28 D6                    movaps  xmm2, xmm6
000000018036D793  F3 0F 59 93 90 31 00 00     mulss   xmm2, dword ptr [rbx+3190h]
000000018036D79B  F3 0F 59 9B F0 2F 00 00     mulss   xmm3, dword ptr [rbx+2FF0h]
000000018036D7A3  F3 0F 58 93 80 31 00 00     addss   xmm2, dword ptr [rbx+3180h]
000000018036D7AB  F3 0F 10 8B F0 30 00 00     movss   xmm1, dword ptr [rbx+30F0h]
000000018036D7B3  F3 0F 59 8B B0 2F 00 00     mulss   xmm1, dword ptr [rbx+2FB0h]
000000018036D7BB  F3 0F 59 E6                 mulss   xmm4, xmm6
000000018036D7BF  0F 28 C4                    movaps  xmm0, xmm4
000000018036D7C2  F3 0F 59 E6                 mulss   xmm4, xmm6
000000018036D7C6  F3 0F 59 83 A0 31 00 00     mulss   xmm0, dword ptr [rbx+31A0h]
000000018036D7CE  F3 0F 59 F4                 mulss   xmm6, xmm4
000000018036D7D2  F3 0F 59 A3 B0 31 00 00     mulss   xmm4, dword ptr [rbx+31B0h]
000000018036D7DA  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036D7DE  F3 0F 59 B3 C0 31 00 00     mulss   xmm6, dword ptr [rbx+31C0h]
000000018036D7E6  F3 0F 10 83 E0 30 00 00     movss   xmm0, dword ptr [rbx+30E0h]
000000018036D7EE  F3 0F 59 83 A0 2F 00 00     mulss   xmm0, dword ptr [rbx+2FA0h]
000000018036D7F6  F3 0F 58 E2                 addss   xmm4, xmm2
000000018036D7FA  F3 0F 58 D8                 addss   xmm3, xmm0
000000018036D7FE  F3 0F 58 F4                 addss   xmm6, xmm4
000000018036D802  F3 0F 10 A3 C0 30 00 00     movss   xmm4, dword ptr [rbx+30C0h]
000000018036D80A  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036D80E  F3 0F 58 B3 D0 31 00 00     addss   xmm6, dword ptr [rbx+31D0h]
000000018036D816  F3 0F 59 B3 70 32 00 00     mulss   xmm6, dword ptr [rbx+3270h]
000000018036D81E  F3 0F 11 B3 E0 2F 00 00     movss   dword ptr [rbx+2FE0h], xmm6
000000018036D826  F3 0F 59 A3 D0 2F 00 00     mulss   xmm4, dword ptr [rbx+2FD0h]
000000018036D82E  F3 0F 10 8B A0 30 00 00     movss   xmm1, dword ptr [rbx+30A0h]
000000018036D836  F3 0F 10 83 D0 30 00 00     movss   xmm0, dword ptr [rbx+30D0h]
000000018036D83E  F3 0F 59 83 C0 2F 00 00     mulss   xmm0, dword ptr [rbx+2FC0h]
000000018036D846  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036D84A  F3 0F 10 93 30 31 00 00     movss   xmm2, dword ptr [rbx+3130h]
000000018036D852  0F 28 D9                    movaps  xmm3, xmm1
000000018036D855  F3 0F 59 9B D0 2E 00 00     mulss   xmm3, dword ptr [rbx+2ED0h]
000000018036D85D  F3 0F 59 B3 B0 30 00 00     mulss   xmm6, dword ptr [rbx+30B0h]
000000018036D865  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036D869  F3 0F 10 83 10 31 00 00     movss   xmm0, dword ptr [rbx+3110h]
000000018036D871  F3 0F 5C D9                 subss   xmm3, xmm1
000000018036D875  F3 0F 59 83 90 2E 00 00     mulss   xmm0, dword ptr [rbx+2E90h]
000000018036D87D  F3 0F 58 E6                 addss   xmm4, xmm6
000000018036D881  F3 41 0F 58 DD              addss   xmm3, xmm13
000000018036D886  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036D88A  F3 0F 11 9B 00 30 00 00     movss   dword ptr [rbx+3000h], xmm3
000000018036D892  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018036D896  F3 0F 11 A3 20 30 00 00     movss   dword ptr [rbx+3020h], xmm4
000000018036D89E  F3 0F 10 8B 40 31 00 00     movss   xmm1, dword ptr [rbx+3140h]
000000018036D8A6  F3 0F 59 8B B0 2E 00 00     mulss   xmm1, dword ptr [rbx+2EB0h]
000000018036D8AE  F3 0F 10 83 50 31 00 00     movss   xmm0, dword ptr [rbx+3150h]
000000018036D8B6  F3 0F 59 83 C0 2E 00 00     mulss   xmm0, dword ptr [rbx+2EC0h]
000000018036D8BE  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018036D8C2  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036D8C6  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036D8CA  F3 0F 11 8B 10 30 00 00     movss   dword ptr [rbx+3010h], xmm1
000000018036D8D2  F3 0F 10 83 20 30 00 00     movss   xmm0, dword ptr [rbx+3020h]
000000018036D8DA  8B 83 30 30 00 00           mov     eax, [rbx+3030h]
000000018036D8E0  89 83 F0 32 00 00           mov     [rbx+32F0h], eax
000000018036D8E6  F3 0F 11 83 00 33 00 00     movss   dword ptr [rbx+3300h], xmm0
000000018036D8EE  44 0F 2F B3 30 30 00 00     comiss  xmm14, dword ptr [rbx+3030h]
000000018036D8F6  F3 0F 10 8B 40 2B 00 00     movss   xmm1, dword ptr [rbx+2B40h]
000000018036D8FE  F3 0F 10 93 10 33 00 00     movss   xmm2, dword ptr [rbx+3310h]
000000018036D906  73 06                       jnb     short loc_18036D90E
000000018036D908  41 0F 28 C5                 movaps  xmm0, xmm13
000000018036D90C  EB 03                       jmp     short loc_18036D911
000000018036D90E  0F 57 C0                    xorps   xmm0, xmm0
000000018036D911  41 0F 2E D6                 ucomiss xmm2, xmm14
000000018036D915  75 04                       jnz     short loc_18036D91B
000000018036D917  41 0F 28 C5                 movaps  xmm0, xmm13
000000018036D91B  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018036D91F  F3 0F 11 8B 20 33 00 00     movss   dword ptr [rbx+3320h], xmm1
000000018036D927  8B 83 30 33 00 00           mov     eax, [rbx+3330h]
000000018036D92D  89 83 40 33 00 00           mov     [rbx+3340h], eax
000000018036D933  8B 83 60 33 00 00           mov     eax, [rbx+3360h]
000000018036D939  89 83 70 33 00 00           mov     [rbx+3370h], eax
000000018036D93F  8B 83 50 33 00 00           mov     eax, [rbx+3350h]
000000018036D945  89 83 60 33 00 00           mov     [rbx+3360h], eax
000000018036D94B  8B 83 80 33 00 00           mov     eax, [rbx+3380h]
000000018036D951  89 83 90 33 00 00           mov     [rbx+3390h], eax
000000018036D957  8B 83 B0 33 00 00           mov     eax, [rbx+33B0h]
000000018036D95D  89 83 C0 33 00 00           mov     [rbx+33C0h], eax
000000018036D963  F3 0F 10 83 60 34 00 00     movss   xmm0, dword ptr [rbx+3460h]
000000018036D96B  F3 0F 58 8B 40 34 00 00     addss   xmm1, dword ptr [rbx+3440h]
000000018036D973  F3 0F 59 83 70 33 00 00     mulss   xmm0, dword ptr [rbx+3370h]
000000018036D97B  41 0F 2F CE                 comiss  xmm1, xmm14
000000018036D97F  F3 0F 58 83 40 33 00 00     addss   xmm0, dword ptr [rbx+3340h]
000000018036D987  73 06                       jnb     short loc_18036D98F
000000018036D989  45 0F 28 C5                 movaps  xmm8, xmm13
000000018036D98D  EB 04                       jmp     short loc_18036D993
000000018036D98F  45 0F 57 C0                 xorps   xmm8, xmm8
000000018036D993  41 0F 28 ED                 movaps  xmm5, xmm13
000000018036D997  F3 41 0F 5C E8              subss   xmm5, xmm8
000000018036D99C  0F 28 FD                    movaps  xmm7, xmm5
000000018036D99F  F3 0F 59 F8                 mulss   xmm7, xmm0
000000018036D9A3  F3 0F 11 BB 50 33 00 00     movss   dword ptr [rbx+3350h], xmm7
000000018036D9AB  0F 28 E7                    movaps  xmm4, xmm7
000000018036D9AE  F3 0F 10 9B 30 34 00 00     movss   xmm3, dword ptr [rbx+3430h]
000000018036D9B6  F3 0F 10 93 80 34 00 00     movss   xmm2, dword ptr [rbx+3480h]
000000018036D9BE  0F 28 CB                    movaps  xmm1, xmm3
000000018036D9C1  F3 0F 59 8B A0 34 00 00     mulss   xmm1, dword ptr [rbx+34A0h]
000000018036D9C9  0F 28 C2                    movaps  xmm0, xmm2
000000018036D9CC  F3 0F 58 A3 50 34 00 00     addss   xmm4, dword ptr [rbx+3450h]
000000018036D9D4  F3 0F 5C BB 60 33 00 00     subss   xmm7, dword ptr [rbx+3360h]
000000018036D9DC  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018036D9E0  41 0F 2F E6                 comiss  xmm4, xmm14
000000018036D9E4  F3 0F 5C C8                 subss   xmm1, xmm0
000000018036D9E8  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036D9EC  F3 0F 11 8B A0 33 00 00     movss   dword ptr [rbx+33A0h], xmm1
000000018036D9F4  72 06                       jb      short loc_18036D9FC
000000018036D9F6  41 0F 28 F5                 movaps  xmm6, xmm13
000000018036D9FA  EB 03                       jmp     short loc_18036D9FF
000000018036D9FC  0F 57 F6                    xorps   xmm6, xmm6
000000018036D9FF  41 0F 2F FE                 comiss  xmm7, xmm14
000000018036DA03  F3 0F 10 83 00 34 00 00     movss   xmm0, dword ptr [rbx+3400h]
000000018036DA0B  73 03                       jnb     short loc_18036DA10
000000018036DA0D  0F 28 F5                    movaps  xmm6, xmm5
000000018036DA10  F3 0F 59 83 80 34 00 00     mulss   xmm0, dword ptr [rbx+3480h]
000000018036DA18  0F 28 DD                    movaps  xmm3, xmm5
000000018036DA1B  F3 0F 10 93 F0 33 00 00     movss   xmm2, dword ptr [rbx+33F0h]
000000018036DA23  F3 44 0F 10 0D 30 75 77 00  movss   xmm9, cs:dword_180AE4F5C
000000018036DA2C  F3 0F 59 D8                 mulss   xmm3, xmm0
000000018036DA30  F3 0F 11 B3 60 33 00 00     movss   dword ptr [rbx+3360h], xmm6
000000018036DA38  F3 0F 10 8B 90 34 00 00     movss   xmm1, dword ptr [rbx+3490h]
000000018036DA40  F3 0F 10 BB 10 34 00 00     movss   xmm7, dword ptr [rbx+3410h]
000000018036DA48  0F 28 C1                    movaps  xmm0, xmm1
000000018036DA4B  F3 0F 10 A3 90 33 00 00     movss   xmm4, dword ptr [rbx+3390h]
000000018036DA53  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018036DA57  F3 41 0F 59 F9              mulss   xmm7, xmm9
000000018036DA5C  F3 0F 5C D8                 subss   xmm3, xmm0
000000018036DA60  F3 41 0F 59 D1              mulss   xmm2, xmm9
000000018036DA65  41 0F 28 C5                 movaps  xmm0, xmm13
000000018036DA69  F3 0F 59 FE                 mulss   xmm7, xmm6
000000018036DA6D  F3 0F 5C C6                 subss   xmm0, xmm6
000000018036DA71  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036DA75  F3 0F 59 E8                 mulss   xmm5, xmm0
000000018036DA79  0F 28 CB                    movaps  xmm1, xmm3
000000018036DA7C  F3 0F 5C CC                 subss   xmm1, xmm4
000000018036DA80  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018036DA84  41 0F 2F CE                 comiss  xmm1, xmm14
000000018036DA88  F3 0F 58 FA                 addss   xmm7, xmm2
000000018036DA8C  76 0B                       jbe     short loc_18036DA99
000000018036DA8E  0F 28 DC                    movaps  xmm3, xmm4
000000018036DA91  F3 0F 58 9B A0 33 00 00     addss   xmm3, dword ptr [rbx+33A0h]
000000018036DA99  F3 0F 10 83 80 34 00 00     movss   xmm0, dword ptr [rbx+3480h]
000000018036DAA1  F3 0F 10 A3 40 33 00 00     movss   xmm4, dword ptr [rbx+3340h]
000000018036DAA9  F3 0F 5D C3                 minss   xmm0, xmm3
000000018036DAAD  F3 0F 11 83 80 33 00 00     movss   dword ptr [rbx+3380h], xmm0
000000018036DAB5  F3 0F 10 8B C0 33 00 00     movss   xmm1, dword ptr [rbx+33C0h]
000000018036DABD  F3 0F 10 9B 20 34 00 00     movss   xmm3, dword ptr [rbx+3420h]
000000018036DAC5  F3 0F 59 AB 70 34 00 00     mulss   xmm5, dword ptr [rbx+3470h]
000000018036DACD  F3 41 0F 59 D9              mulss   xmm3, xmm9
000000018036DAD2  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018036DAD6  F3 0F 10 83 B0 34 00 00     movss   xmm0, dword ptr [rbx+34B0h]
000000018036DADE  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018036DAE3  0F 28 D0                    movaps  xmm2, xmm0
000000018036DAE6  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036DAEA  F3 0F 58 EE                 addss   xmm5, xmm6
000000018036DAEE  F3 0F 59 D7                 mulss   xmm2, xmm7
000000018036DAF2  F3 0F 5C EC                 subss   xmm5, xmm4
000000018036DAF6  F3 0F 5C D0                 subss   xmm2, xmm0
000000018036DAFA  F3 0F 58 D1                 addss   xmm2, xmm1
000000018036DAFE  F3 0F 11 93 B0 33 00 00     movss   dword ptr [rbx+33B0h], xmm2
000000018036DB06  F3 44 0F 59 C2              mulss   xmm8, xmm2
000000018036DB0B  F3 41 0F 5C D8              subss   xmm3, xmm8
000000018036DB10  F3 0F 58 DA                 addss   xmm3, xmm2
000000018036DB14  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018036DB18  F3 0F 58 DC                 addss   xmm3, xmm4
000000018036DB1C  F3 0F 11 9B 30 33 00 00     movss   dword ptr [rbx+3330h], xmm3
000000018036DB24  F3 0F 59 9B C0 34 00 00     mulss   xmm3, dword ptr [rbx+34C0h]
000000018036DB2C  F3 0F 59 9B D0 34 00 00     mulss   xmm3, dword ptr [rbx+34D0h]
000000018036DB34  0F 28 C3                    movaps  xmm0, xmm3
000000018036DB37  F3 0F 59 83 E0 34 00 00     mulss   xmm0, dword ptr [rbx+34E0h]
000000018036DB3F  F3 0F 11 9B D0 33 00 00     movss   dword ptr [rbx+33D0h], xmm3
000000018036DB47  F3 0F 11 83 E0 33 00 00     movss   dword ptr [rbx+33E0h], xmm0
000000018036DB4F  44 0F 2F B3 30 30 00 00     comiss  xmm14, dword ptr [rbx+3030h]
000000018036DB57  F3 0F 10 8B 40 2B 00 00     movss   xmm1, dword ptr [rbx+2B40h]
000000018036DB5F  F3 0F 10 93 F0 34 00 00     movss   xmm2, dword ptr [rbx+34F0h]
000000018036DB67  73 06                       jnb     short loc_18036DB6F
000000018036DB69  41 0F 28 C5                 movaps  xmm0, xmm13
000000018036DB6D  EB 03                       jmp     short loc_18036DB72
000000018036DB6F  0F 57 C0                    xorps   xmm0, xmm0
000000018036DB72  41 0F 2E D6                 ucomiss xmm2, xmm14
000000018036DB76  75 04                       jnz     short loc_18036DB7C
000000018036DB78  41 0F 28 C5                 movaps  xmm0, xmm13
000000018036DB7C  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018036DB80  F3 0F 11 8B 00 35 00 00     movss   dword ptr [rbx+3500h], xmm1
000000018036DB88  8B 83 10 35 00 00           mov     eax, [rbx+3510h]
000000018036DB8E  89 83 20 35 00 00           mov     [rbx+3520h], eax
000000018036DB94  8B 83 40 35 00 00           mov     eax, [rbx+3540h]
000000018036DB9A  89 83 50 35 00 00           mov     [rbx+3550h], eax
000000018036DBA0  8B 83 30 35 00 00           mov     eax, [rbx+3530h]
000000018036DBA6  89 83 40 35 00 00           mov     [rbx+3540h], eax
000000018036DBAC  8B 83 60 35 00 00           mov     eax, [rbx+3560h]
000000018036DBB2  89 83 70 35 00 00           mov     [rbx+3570h], eax
000000018036DBB8  8B 83 90 35 00 00           mov     eax, [rbx+3590h]
000000018036DBBE  89 83 A0 35 00 00           mov     [rbx+35A0h], eax
000000018036DBC4  F3 0F 10 83 40 36 00 00     movss   xmm0, dword ptr [rbx+3640h]
000000018036DBCC  F3 0F 58 8B 20 36 00 00     addss   xmm1, dword ptr [rbx+3620h]
000000018036DBD4  F3 0F 59 83 50 35 00 00     mulss   xmm0, dword ptr [rbx+3550h]
000000018036DBDC  41 0F 2F CE                 comiss  xmm1, xmm14
000000018036DBE0  F3 0F 58 83 20 35 00 00     addss   xmm0, dword ptr [rbx+3520h]
000000018036DBE8  73 06                       jnb     short loc_18036DBF0
000000018036DBEA  45 0F 28 C5                 movaps  xmm8, xmm13
000000018036DBEE  EB 04                       jmp     short loc_18036DBF4
000000018036DBF0  45 0F 57 C0                 xorps   xmm8, xmm8
000000018036DBF4  41 0F 28 ED                 movaps  xmm5, xmm13
000000018036DBF8  F3 41 0F 5C E8              subss   xmm5, xmm8
000000018036DBFD  0F 28 F5                    movaps  xmm6, xmm5
000000018036DC00  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018036DC04  F3 0F 11 B3 30 35 00 00     movss   dword ptr [rbx+3530h], xmm6
000000018036DC0C  0F 28 E6                    movaps  xmm4, xmm6
000000018036DC0F  F3 0F 10 9B 10 36 00 00     movss   xmm3, dword ptr [rbx+3610h]
000000018036DC17  F3 0F 10 93 60 36 00 00     movss   xmm2, dword ptr [rbx+3660h]
000000018036DC1F  0F 28 CB                    movaps  xmm1, xmm3
000000018036DC22  F3 0F 59 8B 80 36 00 00     mulss   xmm1, dword ptr [rbx+3680h]
000000018036DC2A  0F 28 C2                    movaps  xmm0, xmm2
000000018036DC2D  F3 0F 58 A3 30 36 00 00     addss   xmm4, dword ptr [rbx+3630h]
000000018036DC35  F3 0F 5C B3 40 35 00 00     subss   xmm6, dword ptr [rbx+3540h]
000000018036DC3D  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018036DC41  41 0F 2F E6                 comiss  xmm4, xmm14
000000018036DC45  F3 0F 5C C8                 subss   xmm1, xmm0
000000018036DC49  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036DC4D  F3 0F 11 8B 80 35 00 00     movss   dword ptr [rbx+3580h], xmm1
000000018036DC55  72 06                       jb      short loc_18036DC5D
000000018036DC57  41 0F 28 FD                 movaps  xmm7, xmm13
000000018036DC5B  EB 03                       jmp     short loc_18036DC60
000000018036DC5D  0F 57 FF                    xorps   xmm7, xmm7
000000018036DC60  41 0F 2F F6                 comiss  xmm6, xmm14
000000018036DC64  F3 0F 10 83 E0 35 00 00     movss   xmm0, dword ptr [rbx+35E0h]
000000018036DC6C  73 03                       jnb     short loc_18036DC71
000000018036DC6E  0F 28 FD                    movaps  xmm7, xmm5
000000018036DC71  F3 0F 59 83 60 36 00 00     mulss   xmm0, dword ptr [rbx+3660h]
000000018036DC79  0F 28 DD                    movaps  xmm3, xmm5
000000018036DC7C  F3 0F 10 93 D0 35 00 00     movss   xmm2, dword ptr [rbx+35D0h]
000000018036DC84  F3 0F 11 BB 40 35 00 00     movss   dword ptr [rbx+3540h], xmm7
000000018036DC8C  F3 0F 10 8B 70 36 00 00     movss   xmm1, dword ptr [rbx+3670h]
000000018036DC94  F3 0F 10 B3 F0 35 00 00     movss   xmm6, dword ptr [rbx+35F0h]
000000018036DC9C  F3 0F 10 A3 70 35 00 00     movss   xmm4, dword ptr [rbx+3570h]
000000018036DCA4  F3 0F 59 D8                 mulss   xmm3, xmm0
000000018036DCA8  0F 28 C1                    movaps  xmm0, xmm1
000000018036DCAB  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018036DCAF  F3 41 0F 59 F1              mulss   xmm6, xmm9
000000018036DCB4  F3 0F 5C D8                 subss   xmm3, xmm0
000000018036DCB8  F3 41 0F 59 D1              mulss   xmm2, xmm9
000000018036DCBD  41 0F 28 C5                 movaps  xmm0, xmm13
000000018036DCC1  F3 0F 59 F7                 mulss   xmm6, xmm7
000000018036DCC5  F3 0F 5C C7                 subss   xmm0, xmm7
000000018036DCC9  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036DCCD  F3 0F 59 E8                 mulss   xmm5, xmm0
000000018036DCD1  0F 28 CB                    movaps  xmm1, xmm3
000000018036DCD4  F3 0F 5C CC                 subss   xmm1, xmm4
000000018036DCD8  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018036DCDC  41 0F 2F CE                 comiss  xmm1, xmm14
000000018036DCE0  F3 0F 58 F2                 addss   xmm6, xmm2
000000018036DCE4  76 0B                       jbe     short loc_18036DCF1
000000018036DCE6  0F 28 DC                    movaps  xmm3, xmm4
000000018036DCE9  F3 0F 58 9B 80 35 00 00     addss   xmm3, dword ptr [rbx+3580h]
000000018036DCF1  F3 0F 10 A3 20 35 00 00     movss   xmm4, dword ptr [rbx+3520h]
000000018036DCF9  F3 0F 10 83 60 36 00 00     movss   xmm0, dword ptr [rbx+3660h]
000000018036DD01  F3 0F 5D C3                 minss   xmm0, xmm3
000000018036DD05  F3 0F 11 83 60 35 00 00     movss   dword ptr [rbx+3560h], xmm0
000000018036DD0D  F3 0F 59 AB 50 36 00 00     mulss   xmm5, dword ptr [rbx+3650h]
000000018036DD15  F3 0F 10 8B A0 35 00 00     movss   xmm1, dword ptr [rbx+35A0h]
000000018036DD1D  F3 0F 10 9B 00 36 00 00     movss   xmm3, dword ptr [rbx+3600h]
000000018036DD25  F3 0F 59 F8                 mulss   xmm7, xmm0
000000018036DD29  F3 0F 10 83 90 36 00 00     movss   xmm0, dword ptr [rbx+3690h]
000000018036DD31  0F 28 D0                    movaps  xmm2, xmm0
000000018036DD34  F3 41 0F 59 D9              mulss   xmm3, xmm9
000000018036DD39  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036DD3D  F3 0F 58 EF                 addss   xmm5, xmm7
000000018036DD41  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018036DD46  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018036DD4A  F3 0F 5C EC                 subss   xmm5, xmm4
000000018036DD4E  F3 0F 5C D0                 subss   xmm2, xmm0
000000018036DD52  F3 0F 58 D1                 addss   xmm2, xmm1
000000018036DD56  F3 0F 11 93 90 35 00 00     movss   dword ptr [rbx+3590h], xmm2
000000018036DD5E  F3 44 0F 59 C2              mulss   xmm8, xmm2
000000018036DD63  F3 41 0F 5C D8              subss   xmm3, xmm8
000000018036DD68  F3 0F 58 DA                 addss   xmm3, xmm2
000000018036DD6C  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018036DD70  F3 0F 58 DC                 addss   xmm3, xmm4
000000018036DD74  F3 0F 11 9B 10 35 00 00     movss   dword ptr [rbx+3510h], xmm3
000000018036DD7C  F3 0F 59 9B A0 36 00 00     mulss   xmm3, dword ptr [rbx+36A0h]
000000018036DD84  F3 0F 59 9B B0 36 00 00     mulss   xmm3, dword ptr [rbx+36B0h]
000000018036DD8C  0F 28 C3                    movaps  xmm0, xmm3
000000018036DD8F  F3 0F 59 83 C0 36 00 00     mulss   xmm0, dword ptr [rbx+36C0h]
000000018036DD97  F3 0F 11 9B B0 35 00 00     movss   dword ptr [rbx+35B0h], xmm3
000000018036DD9F  F3 0F 11 83 C0 35 00 00     movss   dword ptr [rbx+35C0h], xmm0
000000018036DDA7  8B 83 D0 36 00 00           mov     eax, [rbx+36D0h]
000000018036DDAD  89 83 E0 36 00 00           mov     [rbx+36E0h], eax
000000018036DDB3  8B 83 F0 36 00 00           mov     eax, [rbx+36F0h]
000000018036DDB9  89 83 00 37 00 00           mov     [rbx+3700h], eax
000000018036DDBF  F3 0F 10 83 00 2C 00 00     movss   xmm0, dword ptr [rbx+2C00h]
000000018036DDC7  F3 44 0F 10 83 80 2C 00 00  movss   xmm8, dword ptr [rbx+2C80h]
000000018036DDD0  8B 83 30 37 00 00           mov     eax, [rbx+3730h]
000000018036DDD6  89 83 40 37 00 00           mov     [rbx+3740h], eax
000000018036DDDC  F3 0F 59 83 10 37 00 00     mulss   xmm0, dword ptr [rbx+3710h]
000000018036DDE4  F3 44 0F 59 83 20 37 00 00  mulss   xmm8, dword ptr [rbx+3720h]
000000018036DDED  F3 44 0F 58 C0              addss   xmm8, xmm0
000000018036DDF2  F3 44 0F 11 83 30 37 00 00  movss   dword ptr [rbx+3730h], xmm8
000000018036DDFB  F3 0F 10 BB 10 30 00 00     movss   xmm7, dword ptr [rbx+3010h]
000000018036DE03  F3 0F 10 8B D0 33 00 00     movss   xmm1, dword ptr [rbx+33D0h]
000000018036DE0B  F3 0F 10 93 B0 35 00 00     movss   xmm2, dword ptr [rbx+35B0h]
000000018036DE13  F3 0F 10 83 00 2C 00 00     movss   xmm0, dword ptr [rbx+2C00h]
000000018036DE1B  8B 83 F0 36 00 00           mov     eax, [rbx+36F0h]
000000018036DE21  89 83 70 37 00 00           mov     [rbx+3770h], eax
000000018036DE27  F3 0F 11 83 80 37 00 00     movss   dword ptr [rbx+3780h], xmm0
000000018036DE2F  F3 0F 10 A3 C0 38 00 00     movss   xmm4, dword ptr [rbx+38C0h]
000000018036DE37  F3 0F 11 8B 50 37 00 00     movss   dword ptr [rbx+3750h], xmm1
000000018036DE3F  F3 0F 11 93 60 37 00 00     movss   dword ptr [rbx+3760h], xmm2
000000018036DE47  F3 0F 10 AB A0 38 00 00     movss   xmm5, dword ptr [rbx+38A0h]
000000018036DE4F  F3 0F 59 FC                 mulss   xmm7, xmm4
000000018036DE53  F3 0F 59 A3 20 30 00 00     mulss   xmm4, dword ptr [rbx+3020h]
000000018036DE5B  F3 0F 11 A3 90 37 00 00     movss   dword ptr [rbx+3790h], xmm4
000000018036DE63  F3 0F 10 8B 20 38 00 00     movss   xmm1, dword ptr [rbx+3820h]
000000018036DE6B  F3 0F 10 93 20 39 00 00     movss   xmm2, dword ptr [rbx+3920h]
000000018036DE73  0F 28 D9                    movaps  xmm3, xmm1
000000018036DE76  F3 0F 59 BB D0 38 00 00     mulss   xmm7, dword ptr [rbx+38D0h]
000000018036DE7E  0F 28 C2                    movaps  xmm0, xmm2
000000018036DE81  F3 0F 10 B3 E0 38 00 00     movss   xmm6, dword ptr [rbx+38E0h]
000000018036DE89  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036DE8D  F3 0F 59 F7                 mulss   xmm6, xmm7
000000018036DE91  F3 0F 59 EC                 mulss   xmm5, xmm4
000000018036DE95  F3 0F 59 AB B0 38 00 00     mulss   xmm5, dword ptr [rbx+38B0h]
000000018036DE9D  F3 0F 11 AB B0 37 00 00     movss   dword ptr [rbx+37B0h], xmm5
000000018036DEA5  F3 0F 58 F5                 addss   xmm6, xmm5
000000018036DEA9  F3 0F 59 9B 70 37 00 00     mulss   xmm3, dword ptr [rbx+3770h]
000000018036DEB1  F3 0F 5C D8                 subss   xmm3, xmm0
000000018036DEB5  F3 0F 10 83 30 38 00 00     movss   xmm0, dword ptr [rbx+3830h]
000000018036DEBD  F3 0F 58 DA                 addss   xmm3, xmm2
000000018036DEC1  F3 0F 59 9B 30 39 00 00     mulss   xmm3, dword ptr [rbx+3930h]
000000018036DEC9  F3 0F 11 9B C0 37 00 00     movss   dword ptr [rbx+37C0h], xmm3
000000018036DED1  F3 0F 10 8B 00 39 00 00     movss   xmm1, dword ptr [rbx+3900h]
000000018036DED9  F3 0F 59 8B 60 37 00 00     mulss   xmm1, dword ptr [rbx+3760h]
000000018036DEE1  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018036DEE5  F3 0F 58 F0                 addss   xmm6, xmm0
000000018036DEE9  F3 0F 10 83 F0 38 00 00     movss   xmm0, dword ptr [rbx+38F0h]
000000018036DEF1  F3 0F 59 83 50 37 00 00     mulss   xmm0, dword ptr [rbx+3750h]
000000018036DEF9  F3 0F 10 9B 90 37 00 00     movss   xmm3, dword ptr [rbx+3790h]
000000018036DF01  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036DF05  F3 0F 10 83 10 38 00 00     movss   xmm0, dword ptr [rbx+3810h]
000000018036DF0D  F3 0F 59 8B 10 39 00 00     mulss   xmm1, dword ptr [rbx+3910h]
000000018036DF15  F3 0F 58 CE                 addss   xmm1, xmm6
000000018036DF19  F3 41 0F 58 C8              addss   xmm1, xmm8
000000018036DF1E  F3 0F 58 8B 80 38 00 00     addss   xmm1, dword ptr [rbx+3880h]
000000018036DF26  F3 0F 58 8B 90 38 00 00     addss   xmm1, dword ptr [rbx+3890h]
000000018036DF2E  F3 0F 11 8B D0 37 00 00     movss   dword ptr [rbx+37D0h], xmm1
000000018036DF36  F3 0F 11 83 E0 37 00 00     movss   dword ptr [rbx+37E0h], xmm0
000000018036DF3E  F3 0F 59 9B 50 39 00 00     mulss   xmm3, dword ptr [rbx+3950h]
000000018036DF46  F3 0F 10 83 50 38 00 00     movss   xmm0, dword ptr [rbx+3850h]
000000018036DF4E  F3 0F 59 83 50 37 00 00     mulss   xmm0, dword ptr [rbx+3750h]
000000018036DF56  F3 0F 58 9B 60 39 00 00     addss   xmm3, dword ptr [rbx+3960h]
000000018036DF5E  F3 0F 10 8B 60 38 00 00     movss   xmm1, dword ptr [rbx+3860h]
000000018036DF66  F3 0F 59 8B 60 37 00 00     mulss   xmm1, dword ptr [rbx+3760h]
000000018036DF6E  F3 0F 10 93 B0 37 00 00     movss   xmm2, dword ptr [rbx+37B0h]
000000018036DF76  F3 0F 59 9B 40 38 00 00     mulss   xmm3, dword ptr [rbx+3840h]
000000018036DF7E  F3 0F 58 93 80 37 00 00     addss   xmm2, dword ptr [rbx+3780h]
000000018036DF86  F3 0F 58 D8                 addss   xmm3, xmm0
000000018036DF8A  F3 0F 58 93 C0 37 00 00     addss   xmm2, dword ptr [rbx+37C0h]
000000018036DF92  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036DF96  F3 0F 58 9B 70 38 00 00     addss   xmm3, dword ptr [rbx+3870h]
000000018036DF9E  F3 0F 59 9B 40 39 00 00     mulss   xmm3, dword ptr [rbx+3940h]
000000018036DFA6  F3 0F 11 9B F0 37 00 00     movss   dword ptr [rbx+37F0h], xmm3
000000018036DFAE  F3 0F 11 93 00 38 00 00     movss   dword ptr [rbx+3800h], xmm2
000000018036DFB6  F3 0F 10 83 80 39 00 00     movss   xmm0, dword ptr [rbx+3980h]
000000018036DFBE  8B 83 70 39 00 00           mov     eax, [rbx+3970h]
000000018036DFC4  89 83 A0 39 00 00           mov     [rbx+39A0h], eax
000000018036DFCA  F3 0F 11 83 B0 39 00 00     movss   dword ptr [rbx+39B0h], xmm0
000000018036DFD2  8B 83 90 39 00 00           mov     eax, [rbx+3990h]
000000018036DFD8  89 83 C0 39 00 00           mov     [rbx+39C0h], eax
000000018036DFDE  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
000000018036DFE6  8B 83 E0 39 00 00           mov     eax, [rbx+39E0h]
000000018036DFEC  89 83 F0 39 00 00           mov     [rbx+39F0h], eax
000000018036DFF2  F3 0F 10 93 D0 39 00 00     movss   xmm2, dword ptr [rbx+39D0h]
000000018036DFFA  F3 0F 11 93 E0 39 00 00     movss   dword ptr [rbx+39E0h], xmm2
000000018036E002  0F 28 C2                    movaps  xmm0, xmm2
000000018036E005  0F 28 DA                    movaps  xmm3, xmm2
000000018036E008  F3 0F 59 9B 00 3A 00 00     mulss   xmm3, dword ptr [rbx+3A00h]
000000018036E010  F3 0F 58 9B F0 39 00 00     addss   xmm3, dword ptr [rbx+39F0h]
000000018036E018  F3 0F 11 9B E0 39 00 00     movss   dword ptr [rbx+39E0h], xmm3
000000018036E020  F3 0F 59 83 10 3A 00 00     mulss   xmm0, dword ptr [rbx+3A10h]
000000018036E028  F3 0F 58 C3                 addss   xmm0, xmm3
000000018036E02C  F3 0F 59 9B 40 3A 00 00     mulss   xmm3, dword ptr [rbx+3A40h]
000000018036E034  F3 0F 5C E0                 subss   xmm4, xmm0
000000018036E038  0F 28 CC                    movaps  xmm1, xmm4
000000018036E03B  F3 0F 59 8B 00 3A 00 00     mulss   xmm1, dword ptr [rbx+3A00h]
000000018036E043  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036E047  F3 0F 11 8B D0 39 00 00     movss   dword ptr [rbx+39D0h], xmm1
000000018036E04F  F3 0F 59 8B 30 3A 00 00     mulss   xmm1, dword ptr [rbx+3A30h]
000000018036E057  F3 0F 59 A3 20 3A 00 00     mulss   xmm4, dword ptr [rbx+3A20h]
000000018036E05F  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036E063  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036E067  F3 0F 11 A3 F0 39 00 00     movss   dword ptr [rbx+39F0h], xmm4
000000018036E06F  8B 83 20 42 00 00           mov     eax, [rbx+4220h]
000000018036E075  89 83 30 42 00 00           mov     [rbx+4230h], eax
000000018036E07B  F3 0F 10 8B 40 42 00 00     movss   xmm1, dword ptr [rbx+4240h]
000000018036E083  F3 0F 11 8B 50 42 00 00     movss   dword ptr [rbx+4250h], xmm1
000000018036E08B  F3 0F 59 8B E0 36 00 00     mulss   xmm1, dword ptr [rbx+36E0h]
000000018036E093  F3 0F 10 83 30 42 00 00     movss   xmm0, dword ptr [rbx+4230h]
000000018036E09B  F3 0F 59 83 F0 39 00 00     mulss   xmm0, dword ptr [rbx+39F0h]
000000018036E0A3  F3 0F 11 8B 60 42 00 00     movss   dword ptr [rbx+4260h], xmm1
000000018036E0AB  F3 0F 11 83 70 42 00 00     movss   dword ptr [rbx+4270h], xmm0
000000018036E0B3  8B 83 A0 42 00 00           mov     eax, [rbx+42A0h]
000000018036E0B9  89 83 B0 42 00 00           mov     [rbx+42B0h], eax
000000018036E0BF  F3 0F 59 8B 80 42 00 00     mulss   xmm1, dword ptr [rbx+4280h]
000000018036E0C7  F3 0F 59 83 90 42 00 00     mulss   xmm0, dword ptr [rbx+4290h]
000000018036E0CF  F3 0F 58 C1                 addss   xmm0, xmm1
000000018036E0D3  F3 0F 11 83 A0 42 00 00     movss   dword ptr [rbx+42A0h], xmm0
000000018036E0DB  8B 83 C0 42 00 00           mov     eax, [rbx+42C0h]
000000018036E0E1  89 83 D0 42 00 00           mov     [rbx+42D0h], eax
000000018036E0E7  8B 83 E0 42 00 00           mov     eax, [rbx+42E0h]
000000018036E0ED  89 83 F0 42 00 00           mov     [rbx+42F0h], eax
000000018036E0F3  8B 83 00 43 00 00           mov     eax, [rbx+4300h]
000000018036E0F9  89 83 10 43 00 00           mov     [rbx+4310h], eax
000000018036E0FF  8B 83 20 43 00 00           mov     eax, [rbx+4320h]
000000018036E105  89 83 30 43 00 00           mov     [rbx+4330h], eax
000000018036E10B  F3 0F 10 8B 50 43 00 00     movss   xmm1, dword ptr [rbx+4350h]
000000018036E113  F3 0F 10 93 60 43 00 00     movss   xmm2, dword ptr [rbx+4360h]
000000018036E11B  0F 28 E1                    movaps  xmm4, xmm1
000000018036E11E  F3 0F 59 A3 C0 42 00 00     mulss   xmm4, dword ptr [rbx+42C0h]
000000018036E126  0F 28 C2                    movaps  xmm0, xmm2
000000018036E129  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036E12D  F3 0F 5C E0                 subss   xmm4, xmm0
000000018036E131  F3 0F 58 E2                 addss   xmm4, xmm2
000000018036E135  0F 28 DC                    movaps  xmm3, xmm4
000000018036E138  0F 28 CC                    movaps  xmm1, xmm4
000000018036E13B  F3 0F 59 8B 80 43 00 00     mulss   xmm1, dword ptr [rbx+4380h]
000000018036E143  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018036E147  F3 0F 58 8B 70 43 00 00     addss   xmm1, dword ptr [rbx+4370h]
000000018036E14F  0F 28 C3                    movaps  xmm0, xmm3
000000018036E152  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018036E156  F3 0F 59 83 90 43 00 00     mulss   xmm0, dword ptr [rbx+4390h]
000000018036E15E  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036E162  0F 28 C3                    movaps  xmm0, xmm3
000000018036E165  F3 0F 59 9B A0 43 00 00     mulss   xmm3, dword ptr [rbx+43A0h]
000000018036E16D  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018036E171  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036E175  F3 0F 59 83 B0 43 00 00     mulss   xmm0, dword ptr [rbx+43B0h]
000000018036E17D  F3 0F 58 C3                 addss   xmm0, xmm3
000000018036E181  41 0F 2F C6                 comiss  xmm0, xmm14
000000018036E185  76 05                       jbe     short loc_18036E18C
000000018036E187  0F 5A C0                    cvtps2pd xmm0, xmm0
000000018036E18A  EB 03                       jmp     short loc_18036E18F
000000018036E18C  0F 57 C0                    xorps   xmm0, xmm0
000000018036E18F  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
000000018036E193  41 0F 2F CD                 comiss  xmm1, xmm13
000000018036E197  73 04                       jnb     short loc_18036E19D
000000018036E199  44 0F 5A E1                 cvtps2pd xmm12, xmm1
000000018036E19D  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
000000018036E1A2  F3 0F 11 83 40 43 00 00     movss   dword ptr [rbx+4340h], xmm0
000000018036E1AA  8B 83 C0 43 00 00           mov     eax, [rbx+43C0h]
000000018036E1B0  89 83 D0 43 00 00           mov     [rbx+43D0h], eax
000000018036E1B6  F3 0F 10 8B E0 43 00 00     movss   xmm1, dword ptr [rbx+43E0h]
000000018036E1BE  F3 0F 11 8B F0 43 00 00     movss   dword ptr [rbx+43F0h], xmm1
000000018036E1C6  F3 0F 10 83 00 44 00 00     movss   xmm0, dword ptr [rbx+4400h]
000000018036E1CE  F3 0F 11 83 10 44 00 00     movss   dword ptr [rbx+4410h], xmm0
000000018036E1D6  F3 0F 5C C8                 subss   xmm1, xmm0
000000018036E1DA  F3 0F 59 8B 20 44 00 00     mulss   xmm1, dword ptr [rbx+4420h]
000000018036E1E2  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036E1E6  F3 0F 11 8B 00 44 00 00     movss   dword ptr [rbx+4400h], xmm1
000000018036E1EE  F3 0F 10 8B 00 2C 00 00     movss   xmm1, dword ptr [rbx+2C00h]
000000018036E1F6  F3 0F 10 83 80 2C 00 00     movss   xmm0, dword ptr [rbx+2C80h]
000000018036E1FE  8B 83 50 44 00 00           mov     eax, [rbx+4450h]
000000018036E204  89 83 60 44 00 00           mov     [rbx+4460h], eax
000000018036E20A  F3 0F 59 83 40 44 00 00     mulss   xmm0, dword ptr [rbx+4440h]
000000018036E212  F3 0F 59 8B 30 44 00 00     mulss   xmm1, dword ptr [rbx+4430h]
000000018036E21A  F3 0F 58 C1                 addss   xmm0, xmm1
000000018036E21E  F3 0F 11 83 50 44 00 00     movss   dword ptr [rbx+4450h], xmm0
000000018036E226  8B 83 70 44 00 00           mov     eax, [rbx+4470h]
000000018036E22C  89 83 90 44 00 00           mov     [rbx+4490h], eax
000000018036E232  F3 0F 10 9B 80 44 00 00     movss   xmm3, dword ptr [rbx+4480h]
000000018036E23A  F3 0F 11 9B A0 44 00 00     movss   dword ptr [rbx+44A0h], xmm3
000000018036E242  F3 0F 10 8B 90 44 00 00     movss   xmm1, dword ptr [rbx+4490h]
000000018036E24A  F3 0F 10 93 D0 33 00 00     movss   xmm2, dword ptr [rbx+33D0h]
000000018036E252  0F 28 C1                    movaps  xmm0, xmm1
000000018036E255  F3 0F 59 83 B0 35 00 00     mulss   xmm0, dword ptr [rbx+35B0h]
000000018036E25D  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018036E261  F3 0F 5C C1                 subss   xmm0, xmm1
000000018036E265  0F 28 CB                    movaps  xmm1, xmm3
000000018036E268  F3 0F 59 8B 00 43 00 00     mulss   xmm1, dword ptr [rbx+4300h]
000000018036E270  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036E274  F3 0F 59 DA                 mulss   xmm3, xmm2
000000018036E278  F3 0F 5C CB                 subss   xmm1, xmm3
000000018036E27C  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036E280  F3 0F 11 8B B0 44 00 00     movss   dword ptr [rbx+44B0h], xmm1
000000018036E288  F3 0F 10 9B 10 30 00 00     movss   xmm3, dword ptr [rbx+3010h]
000000018036E290  F3 0F 10 83 C0 44 00 00     movss   xmm0, dword ptr [rbx+44C0h]
000000018036E298  F3 0F 11 83 D0 44 00 00     movss   dword ptr [rbx+44D0h], xmm0
000000018036E2A0  F3 0F 5C D8                 subss   xmm3, xmm0
000000018036E2A4  0F 28 CB                    movaps  xmm1, xmm3
000000018036E2A7  F3 0F 59 8B E0 44 00 00     mulss   xmm1, dword ptr [rbx+44E0h]
000000018036E2AF  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036E2B3  F3 0F 10 83 00 45 00 00     movss   xmm0, dword ptr [rbx+4500h]
000000018036E2BB  F3 0F 11 8B C0 44 00 00     movss   dword ptr [rbx+44C0h], xmm1
000000018036E2C3  F3 0F 59 9B F0 44 00 00     mulss   xmm3, dword ptr [rbx+44F0h]
000000018036E2CB  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036E2CF  F3 0F 58 D8                 addss   xmm3, xmm0
000000018036E2D3  F3 0F 11 9B D0 44 00 00     movss   dword ptr [rbx+44D0h], xmm3
000000018036E2DB  F3 0F 10 83 10 45 00 00     movss   xmm0, dword ptr [rbx+4510h]
000000018036E2E3  F3 0F 10 BB 20 30 00 00     movss   xmm7, dword ptr [rbx+3020h]
000000018036E2EB  F3 0F 11 83 20 45 00 00     movss   dword ptr [rbx+4520h], xmm0
000000018036E2F3  F3 0F 5C F8                 subss   xmm7, xmm0
000000018036E2F7  0F 28 CF                    movaps  xmm1, xmm7
000000018036E2FA  F3 0F 59 8B 30 45 00 00     mulss   xmm1, dword ptr [rbx+4530h]
000000018036E302  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036E306  F3 0F 10 83 50 45 00 00     movss   xmm0, dword ptr [rbx+4550h]
000000018036E30E  F3 0F 11 8B 10 45 00 00     movss   dword ptr [rbx+4510h], xmm1
000000018036E316  F3 0F 59 BB 40 45 00 00     mulss   xmm7, dword ptr [rbx+4540h]
000000018036E31E  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036E322  F3 0F 58 F8                 addss   xmm7, xmm0
000000018036E326  F3 0F 11 BB 20 45 00 00     movss   dword ptr [rbx+4520h], xmm7
000000018036E32E  F3 0F 10 A3 D0 44 00 00     movss   xmm4, dword ptr [rbx+44D0h]
000000018036E336  F3 0F 10 AB B0 44 00 00     movss   xmm5, dword ptr [rbx+44B0h]
000000018036E33E  F3 0F 10 B3 50 44 00 00     movss   xmm6, dword ptr [rbx+4450h]
000000018036E346  F3 44 0F 10 8B E0 42 00 00  movss   xmm9, dword ptr [rbx+42E0h]
000000018036E34F  8B 83 00 44 00 00           mov     eax, [rbx+4400h]
000000018036E355  89 83 60 45 00 00           mov     [rbx+4560h], eax
000000018036E35B  F3 44 0F 11 8B 70 45 00 00  movss   dword ptr [rbx+4570h], xmm9
000000018036E364  F3 0F 10 83 90 45 00 00     movss   xmm0, dword ptr [rbx+4590h]
000000018036E36C  F3 0F 10 93 A0 45 00 00     movss   xmm2, dword ptr [rbx+45A0h]
000000018036E374  F3 0F 59 F8                 mulss   xmm7, xmm0
000000018036E378  0F 28 DA                    movaps  xmm3, xmm2
000000018036E37B  F3 0F 59 9B 20 43 00 00     mulss   xmm3, dword ptr [rbx+4320h]
000000018036E383  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018036E387  0F 28 C2                    movaps  xmm0, xmm2
000000018036E38A  F3 0F 59 C7                 mulss   xmm0, xmm7
000000018036E38E  44 0F 28 C3                 movaps  xmm8, xmm3
000000018036E392  F3 44 0F 5C C0              subss   xmm8, xmm0
000000018036E397  F3 44 0F 58 C7              addss   xmm8, xmm7
000000018036E39C  F3 44 0F 59 83 D0 45 00 00  mulss   xmm8, dword ptr [rbx+45D0h]
000000018036E3A5  F3 0F 10 8B B0 45 00 00     movss   xmm1, dword ptr [rbx+45B0h]
000000018036E3AD  F3 0F 58 B3 50 46 00 00     addss   xmm6, dword ptr [rbx+4650h]
000000018036E3B5  F3 44 0F 59 83 E0 45 00 00  mulss   xmm8, dword ptr [rbx+45E0h]
000000018036E3BE  F3 0F 59 AB F0 45 00 00     mulss   xmm5, dword ptr [rbx+45F0h]
000000018036E3C6  F3 0F 59 B3 00 46 00 00     mulss   xmm6, dword ptr [rbx+4600h]
000000018036E3CE  F3 44 0F 59 C9              mulss   xmm9, xmm1
000000018036E3D3  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018036E3D7  F3 0F 58 F5                 addss   xmm6, xmm5
000000018036E3DB  F3 0F 5C DA                 subss   xmm3, xmm2
000000018036E3DF  F3 0F 10 93 30 46 00 00     movss   xmm2, dword ptr [rbx+4630h]
000000018036E3E7  0F 28 C2                    movaps  xmm0, xmm2
000000018036E3EA  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036E3EE  F3 0F 58 DC                 addss   xmm3, xmm4
000000018036E3F2  F3 44 0F 5C C8              subss   xmm9, xmm0
000000018036E3F7  F3 0F 10 83 20 46 00 00     movss   xmm0, dword ptr [rbx+4620h]
000000018036E3FF  F3 0F 58 83 60 45 00 00     addss   xmm0, dword ptr [rbx+4560h]
000000018036E407  F3 0F 59 9B C0 45 00 00     mulss   xmm3, dword ptr [rbx+45C0h]
000000018036E40F  F3 0F 59 83 60 46 00 00     mulss   xmm0, dword ptr [rbx+4660h]
000000018036E417  F3 44 0F 58 CA              addss   xmm9, xmm2
000000018036E41C  F3 44 0F 58 C3              addss   xmm8, xmm3
000000018036E421  F3 0F 59 83 10 46 00 00     mulss   xmm0, dword ptr [rbx+4610h]
000000018036E429  F3 44 0F 59 8B 40 46 00 00  mulss   xmm9, dword ptr [rbx+4640h]
000000018036E432  F3 44 0F 58 C6              addss   xmm8, xmm6
000000018036E437  F3 44 0F 58 C8              addss   xmm9, xmm0
000000018036E43C  F3 45 0F 58 C8              addss   xmm9, xmm8
000000018036E441  F3 44 0F 11 8B 80 45 00 00  movss   dword ptr [rbx+4580h], xmm9
000000018036E44A  F3 0F 10 BB 40 43 00 00     movss   xmm7, dword ptr [rbx+4340h]
000000018036E452  F3 44 0F 10 83 D0 43 00 00  movss   xmm8, dword ptr [rbx+43D0h]
000000018036E45B  8B 83 A0 46 00 00           mov     eax, [rbx+46A0h]
000000018036E461  89 83 B0 46 00 00           mov     [rbx+46B0h], eax
000000018036E467  F3 0F 10 83 90 46 00 00     movss   xmm0, dword ptr [rbx+4690h]
000000018036E46F  F3 0F 11 83 A0 46 00 00     movss   dword ptr [rbx+46A0h], xmm0
000000018036E477  44 0F 2E AB E0 46 00 00     ucomiss xmm13, dword ptr [rbx+46E0h]
000000018036E47F  0F 85 8F 02 00 00           jnz     loc_18036E714
000000018036E485  F3 0F 10 8B 30 47 00 00     movss   xmm1, dword ptr [rbx+4730h]
000000018036E48D  F3 0F 10 B3 B0 46 00 00     movss   xmm6, dword ptr [rbx+46B0h]
000000018036E495  0F 28 D1                    movaps  xmm2, xmm1
000000018036E498  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018036E49C  F3 0F 59 D0                 mulss   xmm2, xmm0
000000018036E4A0  41 0F 57 C3                 xorps   xmm0, xmm11
000000018036E4A4  F3 0F 5C D1                 subss   xmm2, xmm1
000000018036E4A8  F3 0F 58 F2                 addss   xmm6, xmm2
000000018036E4AC  F3 0F 11 B3 A0 46 00 00     movss   dword ptr [rbx+46A0h], xmm6
000000018036E4B4  F3 0F 59 B3 20 47 00 00     mulss   xmm6, dword ptr [rbx+4720h]
000000018036E4BC  F3 0F 58 B3 C0 46 00 00     addss   xmm6, dword ptr [rbx+46C0h]
000000018036E4C4  E8 97 A8 FF FF              call    sub_180368D60
000000018036E4C9  F3 0F 11 83 90 46 00 00     movss   dword ptr [rbx+4690h], xmm0
000000018036E4D1  41 0F 28 C8                 movaps  xmm1, xmm8
000000018036E4D5  F3 0F 59 8B 80 47 00 00     mulss   xmm1, dword ptr [rbx+4780h]
000000018036E4DD  41 0F 28 D5                 movaps  xmm2, xmm13
000000018036E4E1  F3 41 0F 5C D0              subss   xmm2, xmm8
000000018036E4E6  F3 0F 58 8B D0 46 00 00     addss   xmm1, dword ptr [rbx+46D0h]
000000018036E4EE  F3 0F 59 93 40 47 00 00     mulss   xmm2, dword ptr [rbx+4740h]
000000018036E4F6  F3 0F 11 8B 80 46 00 00     movss   dword ptr [rbx+4680h], xmm1
000000018036E4FE  F3 44 0F 59 8B 10 47 00 00  mulss   xmm9, dword ptr [rbx+4710h]
000000018036E507  F3 0F 59 BB F0 46 00 00     mulss   xmm7, dword ptr [rbx+46F0h]
000000018036E50F  F3 0F 10 83 50 47 00 00     movss   xmm0, dword ptr [rbx+4750h]
000000018036E517  F3 0F 5D C2                 minss   xmm0, xmm2
000000018036E51B  F3 44 0F 58 CF              addss   xmm9, xmm7
000000018036E520  F3 44 0F 58 CE              addss   xmm9, xmm6
000000018036E525  F3 44 0F 58 C8              addss   xmm9, xmm0
000000018036E52A  F3 44 0F 58 8B 00 47 00 00  addss   xmm9, dword ptr [rbx+4700h]
000000018036E533  F3 44 0F 5D 8B 60 47 00 00  minss   xmm9, dword ptr [rbx+4760h]
000000018036E53C  F3 44 0F 5F 8B 70 47 00 00  maxss   xmm9, dword ptr [rbx+4770h]
000000018036E545  F3 44 0F 59 8B A0 47 00 00  mulss   xmm9, dword ptr [rbx+47A0h]
000000018036E54E  F3 44 0F 58 8B B0 47 00 00  addss   xmm9, dword ptr [rbx+47B0h]
000000018036E557  41 0F 28 C9                 movaps  xmm1, xmm9
000000018036E55B  F3 0F 2C C9                 cvttss2si ecx, xmm1
000000018036E55F  81 F9 00 00 00 80           cmp     ecx, 80000000h
000000018036E565  74 1E                       jz      short loc_18036E585
000000018036E567  66 0F 6E C1                 movd    xmm0, ecx
000000018036E56B  0F 5B C0                    cvtdq2ps xmm0, xmm0
000000018036E56E  0F 2E C1                    ucomiss xmm0, xmm1
000000018036E571  74 12                       jz      short loc_18036E585
000000018036E573  0F 14 C9                    unpcklps xmm1, xmm1
000000018036E576  0F 50 C1                    movmskps eax, xmm1
000000018036E579  83 E0 01                    and     eax, 1
000000018036E57C  2B C8                       sub     ecx, eax
000000018036E57E  66 0F 6E C9                 movd    xmm1, ecx
000000018036E582  0F 5B C9                    cvtdq2ps xmm1, xmm1
000000018036E585  F3 44 0F 5C C9              subss   xmm9, xmm1
000000018036E58A  0F 28 C1                    movaps  xmm0, xmm1; X
000000018036E58D  41 0F 28 F1                 movaps  xmm6, xmm9
000000018036E591  F3 41 0F 59 F1              mulss   xmm6, xmm9
000000018036E596  F3 0F 59 35 32 6A 77 00     mulss   xmm6, cs:dword_180AE4FD0
000000018036E59E  E8 9D 11 38 00              call    expf
000000018036E5A3  0F 28 E0                    movaps  xmm4, xmm0
000000018036E5A6  41 0F 28 D1                 movaps  xmm2, xmm9
000000018036E5AA  F3 0F 59 93 70 48 00 00     mulss   xmm2, dword ptr [rbx+4870h]
000000018036E5B2  41 0F 28 C9                 movaps  xmm1, xmm9
000000018036E5B6  F3 0F 59 8B 50 48 00 00     mulss   xmm1, dword ptr [rbx+4850h]
000000018036E5BE  41 0F 28 C1                 movaps  xmm0, xmm9
000000018036E5C2  F3 0F 58 93 60 48 00 00     addss   xmm2, dword ptr [rbx+4860h]
000000018036E5CA  F3 0F 59 83 30 48 00 00     mulss   xmm0, dword ptr [rbx+4830h]
000000018036E5D2  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018036E5D6  F3 0F 58 D1                 addss   xmm2, xmm1
000000018036E5DA  F3 0F 58 93 40 48 00 00     addss   xmm2, dword ptr [rbx+4840h]
000000018036E5E2  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018036E5E6  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036E5EA  41 0F 28 C1                 movaps  xmm0, xmm9
000000018036E5EE  F3 0F 59 83 10 48 00 00     mulss   xmm0, dword ptr [rbx+4810h]
000000018036E5F6  F3 0F 58 93 20 48 00 00     addss   xmm2, dword ptr [rbx+4820h]
000000018036E5FE  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018036E602  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036E606  41 0F 28 C1                 movaps  xmm0, xmm9
000000018036E60A  F3 0F 59 83 F0 47 00 00     mulss   xmm0, dword ptr [rbx+47F0h]
000000018036E612  F3 44 0F 59 8B D0 47 00 00  mulss   xmm9, dword ptr [rbx+47D0h]
000000018036E61B  F3 0F 58 93 00 48 00 00     addss   xmm2, dword ptr [rbx+4800h]
000000018036E623  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018036E627  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036E62B  F3 0F 58 93 E0 47 00 00     addss   xmm2, dword ptr [rbx+47E0h]
000000018036E633  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018036E637  F3 41 0F 58 D1              addss   xmm2, xmm9
000000018036E63C  F3 41 0F 58 D5              addss   xmm2, xmm13
000000018036E641  F3 0F 59 E2                 mulss   xmm4, xmm2
000000018036E645  F3 0F 59 A3 C0 47 00 00     mulss   xmm4, dword ptr [rbx+47C0h]
000000018036E64D  0F 28 DC                    movaps  xmm3, xmm4
000000018036E650  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018036E654  0F 28 CB                    movaps  xmm1, xmm3
000000018036E657  44 0F 28 C3                 movaps  xmm8, xmm3
000000018036E65B  F3 44 0F 59 83 10 49 00 00  mulss   xmm8, dword ptr [rbx+4910h]
000000018036E664  0F 28 C3                    movaps  xmm0, xmm3
000000018036E667  F3 0F 59 83 D0 48 00 00     mulss   xmm0, dword ptr [rbx+48D0h]
000000018036E66F  0F 28 D3                    movaps  xmm2, xmm3
000000018036E672  F3 44 0F 58 83 F0 48 00 00  addss   xmm8, dword ptr [rbx+48F0h]
000000018036E67B  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018036E67F  F3 0F 58 83 B0 48 00 00     addss   xmm0, dword ptr [rbx+48B0h]
000000018036E687  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018036E68B  F3 44 0F 59 C2              mulss   xmm8, xmm2
000000018036E690  F3 44 0F 58 C0              addss   xmm8, xmm0
000000018036E695  0F 28 C1                    movaps  xmm0, xmm1
000000018036E698  F3 0F 59 8B 90 48 00 00     mulss   xmm1, dword ptr [rbx+4890h]
000000018036E6A0  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018036E6A4  F3 44 0F 59 C0              mulss   xmm8, xmm0
000000018036E6A9  0F 28 C3                    movaps  xmm0, xmm3
000000018036E6AC  F3 0F 59 83 C0 48 00 00     mulss   xmm0, dword ptr [rbx+48C0h]
000000018036E6B4  F3 44 0F 58 C1              addss   xmm8, xmm1
000000018036E6B9  0F 28 CB                    movaps  xmm1, xmm3
000000018036E6BC  F3 0F 59 8B 00 49 00 00     mulss   xmm1, dword ptr [rbx+4900h]
000000018036E6C4  F3 0F 59 9B 80 48 00 00     mulss   xmm3, dword ptr [rbx+4880h]
000000018036E6CC  F3 0F 58 8B E0 48 00 00     addss   xmm1, dword ptr [rbx+48E0h]
000000018036E6D4  F3 44 0F 58 C4              addss   xmm8, xmm4
000000018036E6D9  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018036E6DD  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036E6E1  F3 0F 58 8B A0 48 00 00     addss   xmm1, dword ptr [rbx+48A0h]
000000018036E6E9  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018036E6ED  F3 0F 58 CB                 addss   xmm1, xmm3
000000018036E6F1  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018036E6F6  F3 44 0F 5E C1              divss   xmm8, xmm1
000000018036E6FB  41 0F 28 C0                 movaps  xmm0, xmm8
000000018036E6FF  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018036E704  F3 44 0F 5E C0              divss   xmm8, xmm0
000000018036E709  F3 44 0F 11 83 70 46 00 00  movss   dword ptr [rbx+4670h], xmm8
000000018036E712  EB 09                       jmp     short loc_18036E71D
000000018036E714  F3 44 0F 10 83 70 46 00 00  movss   xmm8, dword ptr [rbx+4670h]
000000018036E71D  8B 83 80 49 00 00           mov     eax, [rbx+4980h]
000000018036E723  F3 0F 10 8B A0 42 00 00     movss   xmm1, dword ptr [rbx+42A0h]
000000018036E72B  F3 44 0F 10 8B 80 46 00 00  movss   xmm9, dword ptr [rbx+4680h]
000000018036E734  89 83 90 49 00 00           mov     [rbx+4990h], eax
000000018036E73A  8B 83 70 49 00 00           mov     eax, [rbx+4970h]
000000018036E740  89 83 80 49 00 00           mov     [rbx+4980h], eax
000000018036E746  8B 83 60 49 00 00           mov     eax, [rbx+4960h]
000000018036E74C  89 83 70 49 00 00           mov     [rbx+4970h], eax
000000018036E752  8B 83 50 49 00 00           mov     eax, [rbx+4950h]
000000018036E758  89 83 60 49 00 00           mov     [rbx+4960h], eax
000000018036E75E  8B 83 40 49 00 00           mov     eax, [rbx+4940h]
000000018036E764  89 83 50 49 00 00           mov     [rbx+4950h], eax
000000018036E76A  8B 83 30 49 00 00           mov     eax, [rbx+4930h]
000000018036E770  89 83 40 49 00 00           mov     [rbx+4940h], eax
000000018036E776  8B 83 20 49 00 00           mov     eax, [rbx+4920h]
000000018036E77C  89 83 30 49 00 00           mov     [rbx+4930h], eax
000000018036E782  8B 83 60 4A 00 00           mov     eax, [rbx+4A60h]
000000018036E788  89 83 70 4A 00 00           mov     [rbx+4A70h], eax
000000018036E78E  8B 83 50 4A 00 00           mov     eax, [rbx+4A50h]
000000018036E794  89 83 60 4A 00 00           mov     [rbx+4A60h], eax
000000018036E79A  8B 83 40 4A 00 00           mov     eax, [rbx+4A40h]
000000018036E7A0  89 83 50 4A 00 00           mov     [rbx+4A50h], eax
000000018036E7A6  8B 83 30 4A 00 00           mov     eax, [rbx+4A30h]
000000018036E7AC  89 83 40 4A 00 00           mov     [rbx+4A40h], eax
000000018036E7B2  8B 83 20 4A 00 00           mov     eax, [rbx+4A20h]
000000018036E7B8  89 83 30 4A 00 00           mov     [rbx+4A30h], eax
000000018036E7BE  8B 83 10 4A 00 00           mov     eax, [rbx+4A10h]
000000018036E7C4  89 83 20 4A 00 00           mov     [rbx+4A20h], eax
000000018036E7CA  8B 83 00 4A 00 00           mov     eax, [rbx+4A00h]
000000018036E7D0  89 83 10 4A 00 00           mov     [rbx+4A10h], eax
000000018036E7D6  8B 83 E0 4A 00 00           mov     eax, [rbx+4AE0h]
000000018036E7DC  89 83 F0 4A 00 00           mov     [rbx+4AF0h], eax
000000018036E7E2  8B 83 D0 4A 00 00           mov     eax, [rbx+4AD0h]
000000018036E7E8  89 83 E0 4A 00 00           mov     [rbx+4AE0h], eax
000000018036E7EE  8B 83 C0 4A 00 00           mov     eax, [rbx+4AC0h]
000000018036E7F4  89 83 D0 4A 00 00           mov     [rbx+4AD0h], eax
000000018036E7FA  8B 83 B0 4A 00 00           mov     eax, [rbx+4AB0h]
000000018036E800  89 83 C0 4A 00 00           mov     [rbx+4AC0h], eax
000000018036E806  8B 83 A0 4A 00 00           mov     eax, [rbx+4AA0h]
000000018036E80C  89 83 B0 4A 00 00           mov     [rbx+4AB0h], eax
000000018036E812  8B 83 90 4A 00 00           mov     eax, [rbx+4A90h]
000000018036E818  89 83 A0 4A 00 00           mov     [rbx+4AA0h], eax
000000018036E81E  8B 83 80 4A 00 00           mov     eax, [rbx+4A80h]
000000018036E824  89 83 90 4A 00 00           mov     [rbx+4A90h], eax
000000018036E82A  8B 83 60 4B 00 00           mov     eax, [rbx+4B60h]
000000018036E830  89 83 70 4B 00 00           mov     [rbx+4B70h], eax
000000018036E836  8B 83 50 4B 00 00           mov     eax, [rbx+4B50h]
000000018036E83C  89 83 60 4B 00 00           mov     [rbx+4B60h], eax
000000018036E842  8B 83 40 4B 00 00           mov     eax, [rbx+4B40h]
000000018036E848  89 83 50 4B 00 00           mov     [rbx+4B50h], eax
000000018036E84E  8B 83 30 4B 00 00           mov     eax, [rbx+4B30h]
000000018036E854  89 83 40 4B 00 00           mov     [rbx+4B40h], eax
000000018036E85A  8B 83 20 4B 00 00           mov     eax, [rbx+4B20h]
000000018036E860  89 83 30 4B 00 00           mov     [rbx+4B30h], eax
000000018036E866  8B 83 10 4B 00 00           mov     eax, [rbx+4B10h]
000000018036E86C  89 83 20 4B 00 00           mov     [rbx+4B20h], eax
000000018036E872  8B 83 00 4B 00 00           mov     eax, [rbx+4B00h]
000000018036E878  89 83 10 4B 00 00           mov     [rbx+4B10h], eax
000000018036E87E  8B 83 E0 4B 00 00           mov     eax, [rbx+4BE0h]
000000018036E884  89 83 F0 4B 00 00           mov     [rbx+4BF0h], eax
000000018036E88A  8B 83 D0 4B 00 00           mov     eax, [rbx+4BD0h]
000000018036E890  89 83 E0 4B 00 00           mov     [rbx+4BE0h], eax
000000018036E896  8B 83 C0 4B 00 00           mov     eax, [rbx+4BC0h]
000000018036E89C  89 83 D0 4B 00 00           mov     [rbx+4BD0h], eax
000000018036E8A2  8B 83 B0 4B 00 00           mov     eax, [rbx+4BB0h]
000000018036E8A8  89 83 C0 4B 00 00           mov     [rbx+4BC0h], eax
000000018036E8AE  8B 83 A0 4B 00 00           mov     eax, [rbx+4BA0h]
000000018036E8B4  89 83 B0 4B 00 00           mov     [rbx+4BB0h], eax
000000018036E8BA  8B 83 90 4B 00 00           mov     eax, [rbx+4B90h]
000000018036E8C0  89 83 A0 4B 00 00           mov     [rbx+4BA0h], eax
000000018036E8C6  8B 83 80 4B 00 00           mov     eax, [rbx+4B80h]
000000018036E8CC  89 83 90 4B 00 00           mov     [rbx+4B90h], eax
000000018036E8D2  8B 83 00 4C 00 00           mov     eax, [rbx+4C00h]
000000018036E8D8  89 83 10 4C 00 00           mov     [rbx+4C10h], eax
000000018036E8DE  F3 0F 10 83 20 4C 00 00     movss   xmm0, dword ptr [rbx+4C20h]
000000018036E8E6  F3 0F 11 83 30 4C 00 00     movss   dword ptr [rbx+4C30h], xmm0
000000018036E8EE  44 0F 2E AB 70 4C 00 00     ucomiss xmm13, dword ptr [rbx+4C70h]
000000018036E8F6  0F 85 49 09 00 00           jnz     loc_18036F245
000000018036E8FC  F3 0F 59 8B C0 4C 00 00     mulss   xmm1, dword ptr [rbx+4CC0h]
000000018036E904  41 0F 57 C3                 xorps   xmm0, xmm11
000000018036E908  41 0F 28 F1                 movaps  xmm6, xmm9
000000018036E90C  41 0F 28 F8                 movaps  xmm7, xmm8
000000018036E910  F3 0F 59 B3 E0 4C 00 00     mulss   xmm6, dword ptr [rbx+4CE0h]
000000018036E918  F3 41 0F 59 F8              mulss   xmm7, xmm8
000000018036E91D  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018036E922  F3 0F 59 F1                 mulss   xmm6, xmm1
000000018036E926  0F 28 C8                    movaps  xmm1, xmm0
000000018036E929  F3 0F 59 8B B0 4C 00 00     mulss   xmm1, dword ptr [rbx+4CB0h]
000000018036E931  F3 0F 58 F1                 addss   xmm6, xmm1
000000018036E935  E8 26 A4 FF FF              call    sub_180368D60
000000018036E93A  F3 0F 11 83 20 4C 00 00     movss   dword ptr [rbx+4C20h], xmm0
000000018036E942  41 0F 28 DD                 movaps  xmm3, xmm13
000000018036E946  F3 0F 11 B3 00 4C 00 00     movss   dword ptr [rbx+4C00h], xmm6
000000018036E94E  41 0F 28 C0                 movaps  xmm0, xmm8
000000018036E952  F3 0F 59 FF                 mulss   xmm7, xmm7
000000018036E956  F3 41 0F 58 C0              addss   xmm0, xmm8
000000018036E95B  41 0F 28 F5                 movaps  xmm6, xmm13
000000018036E95F  F3 41 0F 59 F9              mulss   xmm7, xmm9
000000018036E964  F3 0F 5C F0                 subss   xmm6, xmm0
000000018036E968  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018036E96D  F3 0F 5E DF                 divss   xmm3, xmm7
000000018036E971  F3 0F 11 9B 50 4C 00 00     movss   dword ptr [rbx+4C50h], xmm3
000000018036E979  0F 28 E3                    movaps  xmm4, xmm3
000000018036E97C  F3 0F 10 8B 00 4C 00 00     movss   xmm1, dword ptr [rbx+4C00h]
000000018036E984  F3 0F 10 AB 10 4C 00 00     movss   xmm5, dword ptr [rbx+4C10h]
000000018036E98C  F3 41 0F 59 E1              mulss   xmm4, xmm9
000000018036E991  F3 0F 11 A3 40 4C 00 00     movss   dword ptr [rbx+4C40h], xmm4
000000018036E999  F3 0F 59 AB 10 4D 00 00     mulss   xmm5, dword ptr [rbx+4D10h]
000000018036E9A1  F3 0F 10 93 80 49 00 00     movss   xmm2, dword ptr [rbx+4980h]
000000018036E9A9  F3 0F 59 8B 20 4D 00 00     mulss   xmm1, dword ptr [rbx+4D20h]
000000018036E9B1  F3 0F 10 83 90 49 00 00     movss   xmm0, dword ptr [rbx+4990h]
000000018036E9B9  F3 0F 11 93 F0 49 00 00     movss   dword ptr [rbx+49F0h], xmm2
000000018036E9C1  F3 0F 59 93 40 4E 00 00     mulss   xmm2, dword ptr [rbx+4E40h]
000000018036E9C9  F3 0F 58 E9                 addss   xmm5, xmm1
000000018036E9CD  F3 0F 59 83 50 4E 00 00     mulss   xmm0, dword ptr [rbx+4E50h]
000000018036E9D5  F3 0F 59 EB                 mulss   xmm5, xmm3
000000018036E9D9  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036E9DD  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018036E9E1  F3 0F 5C EA                 subss   xmm5, xmm2
000000018036E9E5  41 0F 2F EF                 comiss  xmm5, xmm15
000000018036E9E9  73 06                       jnb     short loc_18036E9F1
000000018036E9EB  41 0F 28 EF                 movaps  xmm5, xmm15
000000018036E9EF  EB 05                       jmp     short loc_18036E9F6
000000018036E9F1  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018036E9F6  0F 28 CD                    movaps  xmm1, xmm5
000000018036E9F9  0F 28 C5                    movaps  xmm0, xmm5
000000018036E9FC  F3 0F 59 83 F0 4C 00 00     mulss   xmm0, dword ptr [rbx+4CF0h]
000000018036EA04  41 0F 28 E0                 movaps  xmm4, xmm8
000000018036EA08  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036EA0C  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036EA10  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036EA14  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018036EA18  F3 0F 58 E9                 addss   xmm5, xmm1
000000018036EA1C  F3 0F 11 AB A0 49 00 00     movss   dword ptr [rbx+49A0h], xmm5
000000018036EA24  0F 28 D5                    movaps  xmm2, xmm5
000000018036EA27  F3 0F 58 AB 30 49 00 00     addss   xmm5, dword ptr [rbx+4930h]
000000018036EA2F  F3 0F 10 9B 40 49 00 00     movss   xmm3, dword ptr [rbx+4940h]
000000018036EA37  0F 28 C3                    movaps  xmm0, xmm3
000000018036EA3A  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EA3E  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018036EA42  41 0F 28 E8                 movaps  xmm5, xmm8
000000018036EA46  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018036EA4A  41 0F 28 D0                 movaps  xmm2, xmm8
000000018036EA4E  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036EA52  0F 28 C6                    movaps  xmm0, xmm6
000000018036EA55  F3 0F 11 A3 B0 49 00 00     movss   dword ptr [rbx+49B0h], xmm4
000000018036EA5D  F3 0F 10 8B 50 49 00 00     movss   xmm1, dword ptr [rbx+4950h]
000000018036EA65  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018036EA69  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036EA6D  0F 28 C1                    movaps  xmm0, xmm1
000000018036EA70  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EA74  F3 0F 58 EC                 addss   xmm5, xmm4
000000018036EA78  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036EA7C  41 0F 28 D8                 movaps  xmm3, xmm8
000000018036EA80  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018036EA84  41 0F 28 E0                 movaps  xmm4, xmm8
000000018036EA88  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018036EA8C  F3 0F 58 D8                 addss   xmm3, xmm0
000000018036EA90  0F 28 C6                    movaps  xmm0, xmm6
000000018036EA93  F3 0F 11 9B C0 49 00 00     movss   dword ptr [rbx+49C0h], xmm3
000000018036EA9B  F3 0F 10 AB 60 49 00 00     movss   xmm5, dword ptr [rbx+4960h]
000000018036EAA3  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018036EAA7  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036EAAB  0F 28 C5                    movaps  xmm0, xmm5
000000018036EAAE  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EAB2  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036EAB6  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036EABA  41 0F 28 C8                 movaps  xmm1, xmm8
000000018036EABE  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018036EAC2  41 0F 28 E0                 movaps  xmm4, xmm8
000000018036EAC6  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018036EACA  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036EACE  0F 28 C6                    movaps  xmm0, xmm6
000000018036EAD1  F3 0F 11 93 D0 49 00 00     movss   dword ptr [rbx+49D0h], xmm2
000000018036EAD9  F3 0F 58 EA                 addss   xmm5, xmm2
000000018036EADD  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036EAE1  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036EAE5  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018036EAEA  0F 28 C6                    movaps  xmm0, xmm6
000000018036EAED  F3 0F 59 83 70 49 00 00     mulss   xmm0, dword ptr [rbx+4970h]
000000018036EAF5  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036EAF9  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036EAFD  0F 28 C6                    movaps  xmm0, xmm6
000000018036EB00  F3 0F 59 E1                 mulss   xmm4, xmm1
000000018036EB04  F3 0F 11 AB E0 49 00 00     movss   dword ptr [rbx+49E0h], xmm5
000000018036EB0C  F3 0F 10 93 D0 49 00 00     movss   xmm2, dword ptr [rbx+49D0h]
000000018036EB14  F3 0F 59 93 90 4C 00 00     mulss   xmm2, dword ptr [rbx+4C90h]
000000018036EB1C  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018036EB20  F3 0F 59 AB A0 4C 00 00     mulss   xmm5, dword ptr [rbx+4CA0h]
000000018036EB28  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036EB2C  F3 0F 10 83 80 4C 00 00     movss   xmm0, dword ptr [rbx+4C80h]
000000018036EB34  F3 0F 59 83 C0 49 00 00     mulss   xmm0, dword ptr [rbx+49C0h]
000000018036EB3C  F3 0F 58 D5                 addss   xmm2, xmm5
000000018036EB40  F3 0F 10 AB 10 4C 00 00     movss   xmm5, dword ptr [rbx+4C10h]
000000018036EB48  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036EB4C  F3 0F 11 93 80 4B 00 00     movss   dword ptr [rbx+4B80h], xmm2
000000018036EB54  F3 0F 58 AB 00 4C 00 00     addss   xmm5, dword ptr [rbx+4C00h]
000000018036EB5C  F3 0F 10 83 F0 49 00 00     movss   xmm0, dword ptr [rbx+49F0h]
000000018036EB64  F3 0F 59 AB 30 4D 00 00     mulss   xmm5, dword ptr [rbx+4D30h]
000000018036EB6C  F3 0F 59 AB 50 4C 00 00     mulss   xmm5, dword ptr [rbx+4C50h]
000000018036EB74  F3 0F 11 A3 F0 49 00 00     movss   dword ptr [rbx+49F0h], xmm4
000000018036EB7C  F3 0F 59 A3 40 4E 00 00     mulss   xmm4, dword ptr [rbx+4E40h]
000000018036EB84  F3 0F 59 83 50 4E 00 00     mulss   xmm0, dword ptr [rbx+4E50h]
000000018036EB8C  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036EB90  F3 0F 59 A3 40 4C 00 00     mulss   xmm4, dword ptr [rbx+4C40h]
000000018036EB98  F3 0F 5C EC                 subss   xmm5, xmm4
000000018036EB9C  41 0F 2F EF                 comiss  xmm5, xmm15
000000018036EBA0  73 06                       jnb     short loc_18036EBA8
000000018036EBA2  41 0F 28 EF                 movaps  xmm5, xmm15
000000018036EBA6  EB 05                       jmp     short loc_18036EBAD
000000018036EBA8  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018036EBAD  0F 28 CD                    movaps  xmm1, xmm5
000000018036EBB0  0F 28 C5                    movaps  xmm0, xmm5
000000018036EBB3  F3 0F 59 83 F0 4C 00 00     mulss   xmm0, dword ptr [rbx+4CF0h]
000000018036EBBB  41 0F 28 E0                 movaps  xmm4, xmm8
000000018036EBBF  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036EBC3  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036EBC7  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036EBCB  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018036EBCF  F3 0F 58 E9                 addss   xmm5, xmm1
000000018036EBD3  F3 0F 10 8B A0 49 00 00     movss   xmm1, dword ptr [rbx+49A0h]
000000018036EBDB  F3 0F 11 AB A0 49 00 00     movss   dword ptr [rbx+49A0h], xmm5
000000018036EBE3  0F 28 D5                    movaps  xmm2, xmm5
000000018036EBE6  F3 0F 10 9B B0 49 00 00     movss   xmm3, dword ptr [rbx+49B0h]
000000018036EBEE  F3 0F 58 E9                 addss   xmm5, xmm1
000000018036EBF2  0F 28 C3                    movaps  xmm0, xmm3
000000018036EBF5  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EBF9  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018036EBFD  41 0F 28 E8                 movaps  xmm5, xmm8
000000018036EC01  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018036EC05  41 0F 28 D0                 movaps  xmm2, xmm8
000000018036EC09  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036EC0D  0F 28 C6                    movaps  xmm0, xmm6
000000018036EC10  F3 0F 11 A3 B0 49 00 00     movss   dword ptr [rbx+49B0h], xmm4
000000018036EC18  F3 0F 10 8B C0 49 00 00     movss   xmm1, dword ptr [rbx+49C0h]
000000018036EC20  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018036EC24  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036EC28  0F 28 C1                    movaps  xmm0, xmm1
000000018036EC2B  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EC2F  F3 0F 58 EC                 addss   xmm5, xmm4
000000018036EC33  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036EC37  41 0F 28 D8                 movaps  xmm3, xmm8
000000018036EC3B  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018036EC3F  41 0F 28 E0                 movaps  xmm4, xmm8
000000018036EC43  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018036EC47  F3 0F 58 D8                 addss   xmm3, xmm0
000000018036EC4B  0F 28 C6                    movaps  xmm0, xmm6
000000018036EC4E  F3 0F 11 9B C0 49 00 00     movss   dword ptr [rbx+49C0h], xmm3
000000018036EC56  F3 0F 10 AB D0 49 00 00     movss   xmm5, dword ptr [rbx+49D0h]
000000018036EC5E  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018036EC62  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036EC66  0F 28 C5                    movaps  xmm0, xmm5
000000018036EC69  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EC6D  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036EC71  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036EC75  41 0F 28 C8                 movaps  xmm1, xmm8
000000018036EC79  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018036EC7D  41 0F 28 E0                 movaps  xmm4, xmm8
000000018036EC81  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018036EC85  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036EC89  0F 28 C6                    movaps  xmm0, xmm6
000000018036EC8C  F3 0F 11 93 D0 49 00 00     movss   dword ptr [rbx+49D0h], xmm2
000000018036EC94  F3 0F 58 EA                 addss   xmm5, xmm2
000000018036EC98  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036EC9C  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036ECA0  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018036ECA5  0F 28 C6                    movaps  xmm0, xmm6
000000018036ECA8  F3 0F 59 83 E0 49 00 00     mulss   xmm0, dword ptr [rbx+49E0h]
000000018036ECB0  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036ECB4  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036ECB8  0F 28 C6                    movaps  xmm0, xmm6
000000018036ECBB  F3 0F 59 E1                 mulss   xmm4, xmm1
000000018036ECBF  F3 0F 11 AB E0 49 00 00     movss   dword ptr [rbx+49E0h], xmm5
000000018036ECC7  F3 0F 10 93 D0 49 00 00     movss   xmm2, dword ptr [rbx+49D0h]
000000018036ECCF  F3 0F 59 93 90 4C 00 00     mulss   xmm2, dword ptr [rbx+4C90h]
000000018036ECD7  F3 0F 10 8B 00 4C 00 00     movss   xmm1, dword ptr [rbx+4C00h]
000000018036ECDF  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018036ECE3  F3 0F 59 AB A0 4C 00 00     mulss   xmm5, dword ptr [rbx+4CA0h]
000000018036ECEB  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036ECEF  F3 0F 10 83 80 4C 00 00     movss   xmm0, dword ptr [rbx+4C80h]
000000018036ECF7  F3 0F 59 83 C0 49 00 00     mulss   xmm0, dword ptr [rbx+49C0h]
000000018036ECFF  F3 0F 58 D5                 addss   xmm2, xmm5
000000018036ED03  F3 0F 10 AB 10 4C 00 00     movss   xmm5, dword ptr [rbx+4C10h]
000000018036ED0B  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036ED0F  F3 0F 11 93 00 4B 00 00     movss   dword ptr [rbx+4B00h], xmm2
000000018036ED17  F3 0F 59 AB 20 4D 00 00     mulss   xmm5, dword ptr [rbx+4D20h]
000000018036ED1F  F3 0F 59 8B 10 4D 00 00     mulss   xmm1, dword ptr [rbx+4D10h]
000000018036ED27  F3 0F 10 83 F0 49 00 00     movss   xmm0, dword ptr [rbx+49F0h]
000000018036ED2F  F3 0F 58 E9                 addss   xmm5, xmm1
000000018036ED33  F3 0F 59 AB 50 4C 00 00     mulss   xmm5, dword ptr [rbx+4C50h]
000000018036ED3B  F3 0F 11 A3 F0 49 00 00     movss   dword ptr [rbx+49F0h], xmm4
000000018036ED43  F3 0F 59 A3 40 4E 00 00     mulss   xmm4, dword ptr [rbx+4E40h]
000000018036ED4B  F3 0F 59 83 50 4E 00 00     mulss   xmm0, dword ptr [rbx+4E50h]
000000018036ED53  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036ED57  F3 0F 59 A3 40 4C 00 00     mulss   xmm4, dword ptr [rbx+4C40h]
000000018036ED5F  F3 0F 5C EC                 subss   xmm5, xmm4
000000018036ED63  41 0F 2F EF                 comiss  xmm5, xmm15
000000018036ED67  73 06                       jnb     short loc_18036ED6F
000000018036ED69  41 0F 28 EF                 movaps  xmm5, xmm15
000000018036ED6D  EB 05                       jmp     short loc_18036ED74
000000018036ED6F  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018036ED74  0F 28 CD                    movaps  xmm1, xmm5
000000018036ED77  0F 28 C5                    movaps  xmm0, xmm5
000000018036ED7A  F3 0F 59 83 F0 4C 00 00     mulss   xmm0, dword ptr [rbx+4CF0h]
000000018036ED82  41 0F 28 E0                 movaps  xmm4, xmm8
000000018036ED86  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036ED8A  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036ED8E  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036ED92  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018036ED96  F3 0F 58 E9                 addss   xmm5, xmm1
000000018036ED9A  F3 0F 10 8B A0 49 00 00     movss   xmm1, dword ptr [rbx+49A0h]
000000018036EDA2  F3 0F 11 AB A0 49 00 00     movss   dword ptr [rbx+49A0h], xmm5
000000018036EDAA  0F 28 D5                    movaps  xmm2, xmm5
000000018036EDAD  F3 0F 10 9B B0 49 00 00     movss   xmm3, dword ptr [rbx+49B0h]
000000018036EDB5  F3 0F 58 E9                 addss   xmm5, xmm1
000000018036EDB9  0F 28 C3                    movaps  xmm0, xmm3
000000018036EDBC  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EDC0  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018036EDC4  41 0F 28 E8                 movaps  xmm5, xmm8
000000018036EDC8  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018036EDCC  41 0F 28 D0                 movaps  xmm2, xmm8
000000018036EDD0  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036EDD4  0F 28 C6                    movaps  xmm0, xmm6
000000018036EDD7  F3 0F 11 A3 B0 49 00 00     movss   dword ptr [rbx+49B0h], xmm4
000000018036EDDF  F3 0F 10 8B C0 49 00 00     movss   xmm1, dword ptr [rbx+49C0h]
000000018036EDE7  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018036EDEB  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036EDEF  0F 28 C1                    movaps  xmm0, xmm1
000000018036EDF2  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EDF6  F3 0F 58 EC                 addss   xmm5, xmm4
000000018036EDFA  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036EDFE  41 0F 28 D8                 movaps  xmm3, xmm8
000000018036EE02  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018036EE06  41 0F 28 E0                 movaps  xmm4, xmm8
000000018036EE0A  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018036EE0E  F3 0F 58 D8                 addss   xmm3, xmm0
000000018036EE12  0F 28 C6                    movaps  xmm0, xmm6
000000018036EE15  F3 0F 11 9B C0 49 00 00     movss   dword ptr [rbx+49C0h], xmm3
000000018036EE1D  F3 0F 10 AB D0 49 00 00     movss   xmm5, dword ptr [rbx+49D0h]
000000018036EE25  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018036EE29  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036EE2D  0F 28 C5                    movaps  xmm0, xmm5
000000018036EE30  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EE34  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036EE38  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036EE3C  41 0F 28 C8                 movaps  xmm1, xmm8
000000018036EE40  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018036EE44  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018036EE48  41 0F 28 D8                 movaps  xmm3, xmm8
000000018036EE4C  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036EE50  0F 28 C6                    movaps  xmm0, xmm6
000000018036EE53  F3 0F 11 93 D0 49 00 00     movss   dword ptr [rbx+49D0h], xmm2
000000018036EE5B  F3 0F 58 EA                 addss   xmm5, xmm2
000000018036EE5F  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036EE63  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036EE67  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018036EE6C  0F 28 C6                    movaps  xmm0, xmm6
000000018036EE6F  F3 0F 59 83 E0 49 00 00     mulss   xmm0, dword ptr [rbx+49E0h]
000000018036EE77  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036EE7B  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036EE7F  0F 28 C6                    movaps  xmm0, xmm6
000000018036EE82  F3 0F 59 D9                 mulss   xmm3, xmm1
000000018036EE86  F3 0F 11 AB E0 49 00 00     movss   dword ptr [rbx+49E0h], xmm5
000000018036EE8E  F3 0F 10 8B D0 49 00 00     movss   xmm1, dword ptr [rbx+49D0h]
000000018036EE96  F3 0F 59 8B 90 4C 00 00     mulss   xmm1, dword ptr [rbx+4C90h]
000000018036EE9E  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018036EEA2  F3 0F 59 AB A0 4C 00 00     mulss   xmm5, dword ptr [rbx+4CA0h]
000000018036EEAA  F3 0F 58 D8                 addss   xmm3, xmm0
000000018036EEAE  F3 0F 10 83 80 4C 00 00     movss   xmm0, dword ptr [rbx+4C80h]
000000018036EEB6  F3 0F 59 83 C0 49 00 00     mulss   xmm0, dword ptr [rbx+49C0h]
000000018036EEBE  F3 0F 58 CD                 addss   xmm1, xmm5
000000018036EEC2  F3 0F 10 AB 00 4C 00 00     movss   xmm5, dword ptr [rbx+4C00h]
000000018036EECA  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036EECE  F3 0F 11 8B 80 4A 00 00     movss   dword ptr [rbx+4A80h], xmm1
000000018036EED6  F3 0F 59 AB 00 4D 00 00     mulss   xmm5, dword ptr [rbx+4D00h]
000000018036EEDE  F3 0F 10 83 F0 49 00 00     movss   xmm0, dword ptr [rbx+49F0h]
000000018036EEE6  F3 0F 59 AB 50 4C 00 00     mulss   xmm5, dword ptr [rbx+4C50h]
000000018036EEEE  F3 0F 11 9B 80 49 00 00     movss   dword ptr [rbx+4980h], xmm3
000000018036EEF6  F3 0F 59 9B 40 4E 00 00     mulss   xmm3, dword ptr [rbx+4E40h]
000000018036EEFE  F3 0F 59 83 50 4E 00 00     mulss   xmm0, dword ptr [rbx+4E50h]
000000018036EF06  F3 0F 58 D8                 addss   xmm3, xmm0
000000018036EF0A  F3 0F 59 9B 40 4C 00 00     mulss   xmm3, dword ptr [rbx+4C40h]
000000018036EF12  F3 0F 5C EB                 subss   xmm5, xmm3
000000018036EF16  41 0F 2F EF                 comiss  xmm5, xmm15
000000018036EF1A  73 06                       jnb     short loc_18036EF22
000000018036EF1C  41 0F 28 EF                 movaps  xmm5, xmm15
000000018036EF20  EB 05                       jmp     short loc_18036EF27
000000018036EF22  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018036EF27  0F 28 CD                    movaps  xmm1, xmm5
000000018036EF2A  0F 28 C5                    movaps  xmm0, xmm5
000000018036EF2D  F3 0F 59 83 F0 4C 00 00     mulss   xmm0, dword ptr [rbx+4CF0h]
000000018036EF35  41 0F 28 E0                 movaps  xmm4, xmm8
000000018036EF39  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036EF3D  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036EF41  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018036EF45  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018036EF49  F3 0F 58 E9                 addss   xmm5, xmm1
000000018036EF4D  F3 0F 11 AB 20 49 00 00     movss   dword ptr [rbx+4920h], xmm5
000000018036EF55  0F 28 D5                    movaps  xmm2, xmm5
000000018036EF58  F3 0F 58 AB A0 49 00 00     addss   xmm5, dword ptr [rbx+49A0h]
000000018036EF60  F3 0F 10 9B B0 49 00 00     movss   xmm3, dword ptr [rbx+49B0h]
000000018036EF68  0F 28 C3                    movaps  xmm0, xmm3
000000018036EF6B  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EF6F  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018036EF73  41 0F 28 E8                 movaps  xmm5, xmm8
000000018036EF77  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018036EF7B  41 0F 28 D0                 movaps  xmm2, xmm8
000000018036EF7F  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036EF83  0F 28 C6                    movaps  xmm0, xmm6
000000018036EF86  F3 0F 11 A3 30 49 00 00     movss   dword ptr [rbx+4930h], xmm4
000000018036EF8E  F3 0F 10 8B C0 49 00 00     movss   xmm1, dword ptr [rbx+49C0h]
000000018036EF96  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018036EF9A  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036EF9E  0F 28 C1                    movaps  xmm0, xmm1
000000018036EFA1  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EFA5  F3 0F 58 EC                 addss   xmm5, xmm4
000000018036EFA9  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036EFAD  41 0F 28 D8                 movaps  xmm3, xmm8
000000018036EFB1  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018036EFB5  41 0F 28 E0                 movaps  xmm4, xmm8
000000018036EFB9  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018036EFBD  F3 0F 58 D8                 addss   xmm3, xmm0
000000018036EFC1  0F 28 C6                    movaps  xmm0, xmm6
000000018036EFC4  F3 0F 11 9B 40 49 00 00     movss   dword ptr [rbx+4940h], xmm3
000000018036EFCC  F3 0F 10 AB D0 49 00 00     movss   xmm5, dword ptr [rbx+49D0h]
000000018036EFD4  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018036EFD8  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036EFDC  0F 28 C5                    movaps  xmm0, xmm5
000000018036EFDF  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036EFE3  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036EFE7  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036EFEB  41 0F 28 C8                 movaps  xmm1, xmm8
000000018036EFEF  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018036EFF3  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018036EFF7  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036EFFB  0F 28 C6                    movaps  xmm0, xmm6
000000018036EFFE  F3 0F 11 93 50 49 00 00     movss   dword ptr [rbx+4950h], xmm2
000000018036F006  F3 0F 58 EA                 addss   xmm5, xmm2
000000018036F00A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036F00E  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036F012  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018036F017  0F 28 C6                    movaps  xmm0, xmm6
000000018036F01A  F3 0F 59 83 E0 49 00 00     mulss   xmm0, dword ptr [rbx+49E0h]
000000018036F022  F3 0F 58 CA                 addss   xmm1, xmm2
000000018036F026  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036F02A  F3 44 0F 59 C1              mulss   xmm8, xmm1
000000018036F02F  F3 0F 11 AB 60 49 00 00     movss   dword ptr [rbx+4960h], xmm5
000000018036F037  F3 0F 10 9B 40 49 00 00     movss   xmm3, dword ptr [rbx+4940h]
000000018036F03F  F3 0F 59 F5                 mulss   xmm6, xmm5
000000018036F043  F3 44 0F 58 C6              addss   xmm8, xmm6
000000018036F048  F3 44 0F 11 83 70 49 00 00  movss   dword ptr [rbx+4970h], xmm8
000000018036F051  F3 0F 10 83 90 4C 00 00     movss   xmm0, dword ptr [rbx+4C90h]
000000018036F059  F3 0F 59 83 50 49 00 00     mulss   xmm0, dword ptr [rbx+4950h]
000000018036F061  F3 0F 59 AB A0 4C 00 00     mulss   xmm5, dword ptr [rbx+4CA0h]
000000018036F069  F3 0F 59 9B 80 4C 00 00     mulss   xmm3, dword ptr [rbx+4C80h]
000000018036F071  F3 0F 10 A3 40 4A 00 00     movss   xmm4, dword ptr [rbx+4A40h]
000000018036F079  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036F07D  F3 0F 58 EB                 addss   xmm5, xmm3
000000018036F081  F3 0F 11 AB 00 4A 00 00     movss   dword ptr [rbx+4A00h], xmm5
000000018036F089  F3 0F 58 A3 B0 4B 00 00     addss   xmm4, dword ptr [rbx+4BB0h]
000000018036F091  F3 0F 10 83 C0 4A 00 00     movss   xmm0, dword ptr [rbx+4AC0h]
000000018036F099  F3 0F 58 83 30 4B 00 00     addss   xmm0, dword ptr [rbx+4B30h]
000000018036F0A1  F3 0F 10 8B 40 4B 00 00     movss   xmm1, dword ptr [rbx+4B40h]
000000018036F0A9  F3 0F 58 8B B0 4A 00 00     addss   xmm1, dword ptr [rbx+4AB0h]
000000018036F0B1  F3 0F 59 A3 30 4E 00 00     mulss   xmm4, dword ptr [rbx+4E30h]
000000018036F0B9  F3 0F 59 83 20 4E 00 00     mulss   xmm0, dword ptr [rbx+4E20h]
000000018036F0C1  F3 0F 59 8B 10 4E 00 00     mulss   xmm1, dword ptr [rbx+4E10h]
000000018036F0C9  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036F0CD  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036F0D1  F3 0F 10 83 30 4A 00 00     movss   xmm0, dword ptr [rbx+4A30h]
000000018036F0D9  F3 0F 58 83 C0 4B 00 00     addss   xmm0, dword ptr [rbx+4BC0h]
000000018036F0E1  F3 0F 10 8B A0 4B 00 00     movss   xmm1, dword ptr [rbx+4BA0h]
000000018036F0E9  F3 0F 58 8B 50 4A 00 00     addss   xmm1, dword ptr [rbx+4A50h]
000000018036F0F1  F3 0F 58 AB F0 4B 00 00     addss   xmm5, dword ptr [rbx+4BF0h]
000000018036F0F9  F3 0F 59 83 00 4E 00 00     mulss   xmm0, dword ptr [rbx+4E00h]
000000018036F101  F3 0F 59 8B F0 4D 00 00     mulss   xmm1, dword ptr [rbx+4DF0h]
000000018036F109  F3 0F 59 AB 40 4D 00 00     mulss   xmm5, dword ptr [rbx+4D40h]
000000018036F111  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036F115  F3 0F 10 83 20 4B 00 00     movss   xmm0, dword ptr [rbx+4B20h]
000000018036F11D  F3 0F 58 83 D0 4A 00 00     addss   xmm0, dword ptr [rbx+4AD0h]
000000018036F125  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036F129  F3 0F 10 8B 50 4B 00 00     movss   xmm1, dword ptr [rbx+4B50h]
000000018036F131  F3 0F 58 8B A0 4A 00 00     addss   xmm1, dword ptr [rbx+4AA0h]
000000018036F139  F3 0F 59 83 E0 4D 00 00     mulss   xmm0, dword ptr [rbx+4DE0h]
000000018036F141  F3 0F 59 8B D0 4D 00 00     mulss   xmm1, dword ptr [rbx+4DD0h]
000000018036F149  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036F14D  F3 0F 10 83 D0 4B 00 00     movss   xmm0, dword ptr [rbx+4BD0h]
000000018036F155  F3 0F 58 83 20 4A 00 00     addss   xmm0, dword ptr [rbx+4A20h]
000000018036F15D  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036F161  F3 0F 10 8B 90 4B 00 00     movss   xmm1, dword ptr [rbx+4B90h]
000000018036F169  F3 0F 59 83 C0 4D 00 00     mulss   xmm0, dword ptr [rbx+4DC0h]
000000018036F171  F3 0F 58 8B 60 4A 00 00     addss   xmm1, dword ptr [rbx+4A60h]
000000018036F179  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036F17D  F3 0F 10 83 10 4B 00 00     movss   xmm0, dword ptr [rbx+4B10h]
000000018036F185  F3 0F 58 83 E0 4A 00 00     addss   xmm0, dword ptr [rbx+4AE0h]
000000018036F18D  F3 0F 59 8B B0 4D 00 00     mulss   xmm1, dword ptr [rbx+4DB0h]
000000018036F195  F3 0F 59 83 A0 4D 00 00     mulss   xmm0, dword ptr [rbx+4DA0h]
000000018036F19D  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036F1A1  F3 0F 10 8B 60 4B 00 00     movss   xmm1, dword ptr [rbx+4B60h]
000000018036F1A9  F3 0F 58 8B 90 4A 00 00     addss   xmm1, dword ptr [rbx+4A90h]
000000018036F1B1  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036F1B5  F3 0F 10 83 E0 4B 00 00     movss   xmm0, dword ptr [rbx+4BE0h]
000000018036F1BD  F3 0F 59 8B 90 4D 00 00     mulss   xmm1, dword ptr [rbx+4D90h]
000000018036F1C5  F3 0F 58 83 10 4A 00 00     addss   xmm0, dword ptr [rbx+4A10h]
000000018036F1CD  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036F1D1  F3 0F 10 8B 80 4B 00 00     movss   xmm1, dword ptr [rbx+4B80h]
000000018036F1D9  F3 0F 58 8B 70 4A 00 00     addss   xmm1, dword ptr [rbx+4A70h]
000000018036F1E1  F3 0F 59 83 80 4D 00 00     mulss   xmm0, dword ptr [rbx+4D80h]
000000018036F1E9  F3 0F 59 8B 70 4D 00 00     mulss   xmm1, dword ptr [rbx+4D70h]
000000018036F1F1  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036F1F5  F3 0F 10 83 00 4B 00 00     movss   xmm0, dword ptr [rbx+4B00h]
000000018036F1FD  F3 0F 58 83 F0 4A 00 00     addss   xmm0, dword ptr [rbx+4AF0h]
000000018036F205  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036F209  F3 0F 10 8B 70 4B 00 00     movss   xmm1, dword ptr [rbx+4B70h]
000000018036F211  F3 0F 59 83 60 4D 00 00     mulss   xmm0, dword ptr [rbx+4D60h]
000000018036F219  F3 0F 58 8B 80 4A 00 00     addss   xmm1, dword ptr [rbx+4A80h]
000000018036F221  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036F225  F3 0F 59 8B 50 4D 00 00     mulss   xmm1, dword ptr [rbx+4D50h]
000000018036F22D  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036F231  F3 0F 58 E5                 addss   xmm4, xmm5
000000018036F235  F3 0F 59 A3 D0 4C 00 00     mulss   xmm4, dword ptr [rbx+4CD0h]
000000018036F23D  F3 0F 11 A3 60 4C 00 00     movss   dword ptr [rbx+4C60h], xmm4
000000018036F245  8B 83 60 4E 00 00           mov     eax, [rbx+4E60h]
000000018036F24B  89 83 70 4E 00 00           mov     [rbx+4E70h], eax
000000018036F251  F3 0F 10 83 90 4E 00 00     movss   xmm0, dword ptr [rbx+4E90h]
000000018036F259  8B 83 80 4E 00 00           mov     eax, [rbx+4E80h]
000000018036F25F  89 83 B0 4E 00 00           mov     [rbx+4EB0h], eax
000000018036F265  F3 0F 11 83 C0 4E 00 00     movss   dword ptr [rbx+4EC0h], xmm0
000000018036F26D  8B 83 A0 4E 00 00           mov     eax, [rbx+4EA0h]
000000018036F273  89 83 D0 4E 00 00           mov     [rbx+4ED0h], eax
000000018036F279  F3 0F 10 93 E0 4E 00 00     movss   xmm2, dword ptr [rbx+4EE0h]
000000018036F281  F3 0F 11 93 F0 4E 00 00     movss   dword ptr [rbx+4EF0h], xmm2
000000018036F289  F3 0F 10 83 00 4F 00 00     movss   xmm0, dword ptr [rbx+4F00h]
000000018036F291  F3 0F 11 83 10 4F 00 00     movss   dword ptr [rbx+4F10h], xmm0
000000018036F299  F3 0F 5C D0                 subss   xmm2, xmm0
000000018036F29D  F3 0F 59 93 20 4F 00 00     mulss   xmm2, dword ptr [rbx+4F20h]
000000018036F2A5  F3 0F 58 D0                 addss   xmm2, xmm0
000000018036F2A9  F3 0F 11 93 00 4F 00 00     movss   dword ptr [rbx+4F00h], xmm2
000000018036F2B1  F3 0F 10 83 C0 4E 00 00     movss   xmm0, dword ptr [rbx+4EC0h]
000000018036F2B9  F3 0F 10 8B D0 4E 00 00     movss   xmm1, dword ptr [rbx+4ED0h]
000000018036F2C1  F3 0F 59 D0                 mulss   xmm2, xmm0
000000018036F2C5  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036F2C9  F3 0F 5C D0                 subss   xmm2, xmm0
000000018036F2CD  F3 0F 58 D1                 addss   xmm2, xmm1
000000018036F2D1  F3 0F 11 93 30 4F 00 00     movss   dword ptr [rbx+4F30h], xmm2
000000018036F2D9  F3 0F 10 8B 40 4F 00 00     movss   xmm1, dword ptr [rbx+4F40h]
000000018036F2E1  F3 0F 11 8B 50 4F 00 00     movss   dword ptr [rbx+4F50h], xmm1
000000018036F2E9  F3 0F 10 83 60 4F 00 00     movss   xmm0, dword ptr [rbx+4F60h]
000000018036F2F1  0F 28 D8                    movaps  xmm3, xmm0
000000018036F2F4  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018036F2F8  F3 0F 59 DA                 mulss   xmm3, xmm2
000000018036F2FC  F3 0F 5C D8                 subss   xmm3, xmm0
000000018036F300  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036F304  41 0F 2F DE                 comiss  xmm3, xmm14
000000018036F308  76 05                       jbe     short loc_18036F30F
000000018036F30A  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018036F30D  EB 03                       jmp     short loc_18036F312
000000018036F30F  0F 57 C0                    xorps   xmm0, xmm0
000000018036F312  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018036F316  F3 0F 11 83 40 4F 00 00     movss   dword ptr [rbx+4F40h], xmm0
000000018036F31E  F3 0F 10 8B 70 4F 00 00     movss   xmm1, dword ptr [rbx+4F70h]
000000018036F326  F3 0F 11 8B 80 4F 00 00     movss   dword ptr [rbx+4F80h], xmm1
000000018036F32E  F3 0F 10 93 90 4F 00 00     movss   xmm2, dword ptr [rbx+4F90h]
000000018036F336  F3 0F 11 93 A0 4F 00 00     movss   dword ptr [rbx+4FA0h], xmm2
000000018036F33E  F3 0F 10 83 B0 4F 00 00     movss   xmm0, dword ptr [rbx+4FB0h]
000000018036F346  0F 28 D8                    movaps  xmm3, xmm0
000000018036F349  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036F34D  F3 0F 59 D9                 mulss   xmm3, xmm1
000000018036F351  F3 0F 5C D8                 subss   xmm3, xmm0
000000018036F355  F3 0F 58 DA                 addss   xmm3, xmm2
000000018036F359  41 0F 2F DE                 comiss  xmm3, xmm14
000000018036F35D  76 05                       jbe     short loc_18036F364
000000018036F35F  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018036F362  EB 03                       jmp     short loc_18036F367
000000018036F364  0F 57 C0                    xorps   xmm0, xmm0
000000018036F367  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018036F36B  F3 0F 11 83 90 4F 00 00     movss   dword ptr [rbx+4F90h], xmm0
000000018036F373  F3 0F 10 AB C0 4F 00 00     movss   xmm5, dword ptr [rbx+4FC0h]
000000018036F37B  F3 0F 10 B3 40 2B 00 00     movss   xmm6, dword ptr [rbx+2B40h]
000000018036F383  0F 28 E5                    movaps  xmm4, xmm5
000000018036F386  F3 0F 11 AB D0 4F 00 00     movss   dword ptr [rbx+4FD0h], xmm5
000000018036F38E  0F 28 C5                    movaps  xmm0, xmm5
000000018036F391  F3 0F 59 A3 20 50 00 00     mulss   xmm4, dword ptr [rbx+5020h]
000000018036F399  0F 28 DD                    movaps  xmm3, xmm5
000000018036F39C  F3 0F 58 83 F0 4F 00 00     addss   xmm0, dword ptr [rbx+4FF0h]
000000018036F3A4  F3 0F 58 9B 10 50 00 00     addss   xmm3, dword ptr [rbx+5010h]
000000018036F3AC  41 0F 2F E7                 comiss  xmm4, xmm15
000000018036F3B0  73 06                       jnb     short loc_18036F3B8
000000018036F3B2  41 0F 28 E7                 movaps  xmm4, xmm15
000000018036F3B6  EB 05                       jmp     short loc_18036F3BD
000000018036F3B8  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018036F3BD  41 0F 2F C6                 comiss  xmm0, xmm14
000000018036F3C1  72 1B                       jb      short loc_18036F3DE
000000018036F3C3  F3 0F 10 83 00 50 00 00     movss   xmm0, dword ptr [rbx+5000h]
000000018036F3CB  0F 28 D8                    movaps  xmm3, xmm0
000000018036F3CE  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018036F3D2  F3 0F 59 DE                 mulss   xmm3, xmm6
000000018036F3D6  F3 0F 5C D8                 subss   xmm3, xmm0
000000018036F3DA  F3 0F 58 DD                 addss   xmm3, xmm5
000000018036F3DE  41 0F 2E F6                 ucomiss xmm6, xmm14
000000018036F3E2  F3 0F 10 8B 40 50 00 00     movss   xmm1, dword ptr [rbx+5040h]
000000018036F3EA  0F 28 D4                    movaps  xmm2, xmm4
000000018036F3ED  F3 0F 59 93 30 50 00 00     mulss   xmm2, dword ptr [rbx+5030h]
000000018036F3F5  0F 28 C1                    movaps  xmm0, xmm1
000000018036F3F8  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018036F3FC  F3 0F 5C D0                 subss   xmm2, xmm0
000000018036F400  F3 0F 58 D1                 addss   xmm2, xmm1
000000018036F404  0F 28 C2                    movaps  xmm0, xmm2
000000018036F407  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018036F40B  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018036F40F  F3 0F 5C C2                 subss   xmm0, xmm2
000000018036F413  F3 0F 58 C5                 addss   xmm0, xmm5
000000018036F417  74 03                       jz      short loc_18036F41C
000000018036F419  0F 28 C3                    movaps  xmm0, xmm3
000000018036F41C  F3 0F 11 83 E0 4F 00 00     movss   dword ptr [rbx+4FE0h], xmm0
000000018036F424  F3 0F 11 83 C0 4F 00 00     movss   dword ptr [rbx+4FC0h], xmm0
000000018036F42C  F3 0F 10 BB 60 4C 00 00     movss   xmm7, dword ptr [rbx+4C60h]
000000018036F434  F3 0F 10 B3 D0 33 00 00     movss   xmm6, dword ptr [rbx+33D0h]
000000018036F43C  F3 0F 10 9B D0 43 00 00     movss   xmm3, dword ptr [rbx+43D0h]
000000018036F444  F3 0F 10 83 B0 35 00 00     movss   xmm0, dword ptr [rbx+35B0h]
000000018036F44C  F3 0F 10 8B 60 4E 00 00     movss   xmm1, dword ptr [rbx+4E60h]
000000018036F454  8B 83 80 50 00 00           mov     eax, [rbx+5080h]
000000018036F45A  89 83 90 50 00 00           mov     [rbx+5090h], eax
000000018036F460  8B 83 A0 50 00 00           mov     eax, [rbx+50A0h]
000000018036F466  89 83 B0 50 00 00           mov     [rbx+50B0h], eax
000000018036F46C  F3 0F 11 83 50 50 00 00     movss   dword ptr [rbx+5050h], xmm0
000000018036F474  F3 0F 11 8B 60 50 00 00     movss   dword ptr [rbx+5060h], xmm1
000000018036F47C  F3 0F 59 9B 70 51 00 00     mulss   xmm3, dword ptr [rbx+5170h]
000000018036F484  F3 0F 10 A3 90 50 00 00     movss   xmm4, dword ptr [rbx+5090h]
000000018036F48C  F3 0F 10 93 D0 50 00 00     movss   xmm2, dword ptr [rbx+50D0h]
000000018036F494  F3 0F 11 9B 70 50 00 00     movss   dword ptr [rbx+5070h], xmm3
000000018036F49C  0F 28 DF                    movaps  xmm3, xmm7
000000018036F49F  F3 0F 59 B3 E0 50 00 00     mulss   xmm6, dword ptr [rbx+50E0h]
000000018036F4A7  F3 0F 5C DC                 subss   xmm3, xmm4
000000018036F4AB  F3 0F 59 93 E0 4F 00 00     mulss   xmm2, dword ptr [rbx+4FE0h]
000000018036F4B3  F3 0F 10 8B F0 50 00 00     movss   xmm1, dword ptr [rbx+50F0h]
000000018036F4BB  0F 28 C3                    movaps  xmm0, xmm3
000000018036F4BE  F3 0F 59 83 10 51 00 00     mulss   xmm0, dword ptr [rbx+5110h]
000000018036F4C6  F3 0F 58 F2                 addss   xmm6, xmm2
000000018036F4CA  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036F4CE  41 0F 28 C5                 movaps  xmm0, xmm13
000000018036F4D2  F3 0F 11 A3 80 50 00 00     movss   dword ptr [rbx+5080h], xmm4
000000018036F4DA  F3 0F 59 8B 50 50 00 00     mulss   xmm1, dword ptr [rbx+5050h]
000000018036F4E2  F3 0F 10 93 00 51 00 00     movss   xmm2, dword ptr [rbx+5100h]
000000018036F4EA  F3 0F 59 9B 80 51 00 00     mulss   xmm3, dword ptr [rbx+5180h]
000000018036F4F2  F3 0F 59 A3 90 51 00 00     mulss   xmm4, dword ptr [rbx+5190h]
000000018036F4FA  F3 0F 58 F1                 addss   xmm6, xmm1
000000018036F4FE  0F 28 CA                    movaps  xmm1, xmm2
000000018036F501  F3 0F 59 8B 60 50 00 00     mulss   xmm1, dword ptr [rbx+5060h]
000000018036F509  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018036F50D  F3 0F 58 DC                 addss   xmm3, xmm4
000000018036F511  F3 0F 5C CA                 subss   xmm1, xmm2
000000018036F515  F3 0F 58 CE                 addss   xmm1, xmm6
000000018036F519  F3 0F 10 B3 20 51 00 00     movss   xmm6, dword ptr [rbx+5120h]
000000018036F521  F3 0F 5C C6                 subss   xmm0, xmm6
000000018036F525  F3 0F 59 8B 50 51 00 00     mulss   xmm1, dword ptr [rbx+5150h]
000000018036F52D  F3 0F 59 F8                 mulss   xmm7, xmm0
000000018036F531  41 0F 2F CE                 comiss  xmm1, xmm14
000000018036F535  76 05                       jbe     short loc_18036F53C
000000018036F537  0F 5A C1                    cvtps2pd xmm0, xmm1
000000018036F53A  EB 03                       jmp     short loc_18036F53F
000000018036F53C  0F 57 C0                    xorps   xmm0, xmm0
000000018036F53F  F3 0F 10 93 40 51 00 00     movss   xmm2, dword ptr [rbx+5140h]
000000018036F547  F3 0F 10 A3 30 51 00 00     movss   xmm4, dword ptr [rbx+5130h]
000000018036F54F  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
000000018036F553  F3 0F 10 83 70 50 00 00     movss   xmm0, dword ptr [rbx+5070h]
000000018036F55B  F3 0F 59 AB 60 51 00 00     mulss   xmm5, dword ptr [rbx+5160h]
000000018036F563  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018036F568  F3 0F 59 F3                 mulss   xmm6, xmm3
000000018036F56C  F3 0F 10 9B B0 50 00 00     movss   xmm3, dword ptr [rbx+50B0h]
000000018036F574  F3 0F 58 F7                 addss   xmm6, xmm7
000000018036F578  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018036F57C  F3 0F 10 83 A0 51 00 00     movss   xmm0, dword ptr [rbx+51A0h]
000000018036F584  0F 28 C8                    movaps  xmm1, xmm0
000000018036F587  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018036F58B  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018036F58F  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018036F593  F3 0F 5C C8                 subss   xmm1, xmm0
000000018036F597  F3 0F 58 D9                 addss   xmm3, xmm1
000000018036F59B  F3 0F 11 9B A0 50 00 00     movss   dword ptr [rbx+50A0h], xmm3
000000018036F5A3  F3 0F 59 E3                 mulss   xmm4, xmm3
000000018036F5A7  F3 0F 58 E2                 addss   xmm4, xmm2
000000018036F5AB  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018036F5AF  F3 0F 59 A3 B0 51 00 00     mulss   xmm4, dword ptr [rbx+51B0h]
000000018036F5B7  F3 0F 11 A3 C0 50 00 00     movss   dword ptr [rbx+50C0h], xmm4
000000018036F5BF  8B 83 D0 51 00 00           mov     eax, [rbx+51D0h]
000000018036F5C5  89 83 E0 51 00 00           mov     [rbx+51E0h], eax
000000018036F5CB  8B 83 C0 51 00 00           mov     eax, [rbx+51C0h]
000000018036F5D1  89 83 D0 51 00 00           mov     [rbx+51D0h], eax
000000018036F5D7  F3 0F 10 83 E0 51 00 00     movss   xmm0, dword ptr [rbx+51E0h]
000000018036F5DF  F3 0F 10 8B F0 51 00 00     movss   xmm1, dword ptr [rbx+51F0h]
000000018036F5E7  F3 0F 5C E0                 subss   xmm4, xmm0
000000018036F5EB  F3 0F 11 A3 C0 51 00 00     movss   dword ptr [rbx+51C0h], xmm4
000000018036F5F3  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018036F5F7  F3 0F 58 C8                 addss   xmm1, xmm0
000000018036F5FB  F3 0F 11 8B D0 51 00 00     movss   dword ptr [rbx+51D0h], xmm1
000000018036F603  F3 0F 10 93 C0 51 00 00     movss   xmm2, dword ptr [rbx+51C0h]
000000018036F60B  F3 0F 10 B3 B0 4E 00 00     movss   xmm6, dword ptr [rbx+4EB0h]
000000018036F613  0F 28 C2                    movaps  xmm0, xmm2
000000018036F616  41 0F 2F F6                 comiss  xmm6, xmm14
000000018036F61A  8B 83 20 52 00 00           mov     eax, [rbx+5220h]
000000018036F620  89 83 30 52 00 00           mov     [rbx+5230h], eax
000000018036F626  8B 83 10 52 00 00           mov     eax, [rbx+5210h]
000000018036F62C  89 83 20 52 00 00           mov     [rbx+5220h], eax
000000018036F632  8B 83 00 52 00 00           mov     eax, [rbx+5200h]
000000018036F638  89 83 10 52 00 00           mov     [rbx+5210h], eax
000000018036F63E  F3 0F 11 93 00 52 00 00     movss   dword ptr [rbx+5200h], xmm2
000000018036F646  F3 0F 59 83 50 52 00 00     mulss   xmm0, dword ptr [rbx+5250h]
000000018036F64E  F3 0F 10 A3 10 52 00 00     movss   xmm4, dword ptr [rbx+5210h]
000000018036F656  F3 0F 10 8B 70 52 00 00     movss   xmm1, dword ptr [rbx+5270h]
000000018036F65E  0F 28 EC                    movaps  xmm5, xmm4
000000018036F661  F3 0F 59 8B 20 52 00 00     mulss   xmm1, dword ptr [rbx+5220h]
000000018036F669  F3 0F 59 AB 60 52 00 00     mulss   xmm5, dword ptr [rbx+5260h]
000000018036F671  F3 0F 59 A3 90 52 00 00     mulss   xmm4, dword ptr [rbx+5290h]
000000018036F679  F3 0F 58 E8                 addss   xmm5, xmm0
000000018036F67D  0F 28 C2                    movaps  xmm0, xmm2
000000018036F680  F3 0F 59 83 80 52 00 00     mulss   xmm0, dword ptr [rbx+5280h]
000000018036F688  F3 0F 58 E9                 addss   xmm5, xmm1
000000018036F68C  F3 0F 10 8B A0 52 00 00     movss   xmm1, dword ptr [rbx+52A0h]
000000018036F694  F3 0F 59 8B 30 52 00 00     mulss   xmm1, dword ptr [rbx+5230h]
000000018036F69C  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036F6A0  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036F6A4  76 05                       jbe     short loc_18036F6AB
000000018036F6A6  0F 5A C6                    cvtps2pd xmm0, xmm6
000000018036F6A9  EB 03                       jmp     short loc_18036F6AE
000000018036F6AB  0F 57 C0                    xorps   xmm0, xmm0
000000018036F6AE  0F 2F 35 0B 5E 77 00        comiss  xmm6, cs:dword_180AE54C0
000000018036F6B5  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018036F6B9  F3 0F 11 AB 10 52 00 00     movss   dword ptr [rbx+5210h], xmm5
000000018036F6C1  0F 28 D8                    movaps  xmm3, xmm0
000000018036F6C4  F3 0F 11 A3 20 52 00 00     movss   dword ptr [rbx+5220h], xmm4
000000018036F6CC  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036F6D0  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018036F6D4  F3 0F 5C D8                 subss   xmm3, xmm0
000000018036F6D8  0F 28 C6                    movaps  xmm0, xmm6
000000018036F6DB  41 0F 57 C3                 xorps   xmm0, xmm11
000000018036F6DF  F3 0F 58 DA                 addss   xmm3, xmm2
000000018036F6E3  73 09                       jnb     short loc_18036F6EE
000000018036F6E5  45 0F 57 D2                 xorps   xmm10, xmm10
000000018036F6E9  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
000000018036F6EE  41 0F 2F F6                 comiss  xmm6, xmm14
000000018036F6F2  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
000000018036F6F7  0F 28 C8                    movaps  xmm1, xmm0
000000018036F6FA  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036F6FE  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018036F702  F3 0F 5C C8                 subss   xmm1, xmm0
000000018036F706  F3 0F 58 D1                 addss   xmm2, xmm1
000000018036F70A  72 03                       jb      short loc_18036F70F
000000018036F70C  0F 28 D3                    movaps  xmm2, xmm3
000000018036F70F  F3 0F 11 93 40 52 00 00     movss   dword ptr [rbx+5240h], xmm2
000000018036F717  F3 0F 59 93 40 4F 00 00     mulss   xmm2, dword ptr [rbx+4F40h]
000000018036F71F  F3 0F 11 93 B0 52 00 00     movss   dword ptr [rbx+52B0h], xmm2
000000018036F727  F3 0F 59 93 90 4F 00 00     mulss   xmm2, dword ptr [rbx+4F90h]
000000018036F72F  F3 0F 11 93 C0 52 00 00     movss   dword ptr [rbx+52C0h], xmm2
000000018036F737  F3 0F 10 83 70 3A 00 00     movss   xmm0, dword ptr [rbx+3A70h]
000000018036F73F  F3 0F 58 83 D0 37 00 00     addss   xmm0, dword ptr [rbx+37D0h]
000000018036F747  44 0F 5A E0                 cvtps2pd xmm12, xmm0
000000018036F74B  F2 44 0F 5F 25 54 B5 61 00  maxsd   xmm12, cs:qword_18098ACA8
000000018036F754  F2 44 0F 5D 25 33 B5 61 00  minsd   xmm12, cs:qword_18098AC90
000000018036F75D  41 0F 28 CC                 movaps  xmm1, xmm12
000000018036F761  41 0F 28 C4                 movaps  xmm0, xmm12
000000018036F765  F2 0F 58 05 FB 5A 77 00     addsd   xmm0, cs:qword_180AE5268
000000018036F76D  F2 41 0F 59 CC              mulsd   xmm1, xmm12
000000018036F772  41 0F 28 FC                 movaps  xmm7, xmm12
000000018036F776  F2 0F 2C C0                 cvttsd2si eax, xmm0
000000018036F77A  0F 28 D1                    movaps  xmm2, xmm1
000000018036F77D  48 63 C8                    movsxd  rcx, eax
000000018036F780  F2 41 0F 59 D4              mulsd   xmm2, xmm12
000000018036F785  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
000000018036F78C  0F 28 DA                    movaps  xmm3, xmm2
000000018036F78F  F2 41 0F 59 DC              mulsd   xmm3, xmm12
000000018036F794  48 8D 0D 45 9D 61 00        lea     rcx, unk_1809894E0
000000018036F79B  48 03 C1                    add     rax, rcx
000000018036F79E  0F 28 E3                    movaps  xmm4, xmm3
000000018036F7A1  F2 41 0F 59 E4              mulsd   xmm4, xmm12
000000018036F7A6  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
000000018036F7AB  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
000000018036F7B0  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
000000018036F7B5  0F 28 EC                    movaps  xmm5, xmm4
000000018036F7B8  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
000000018036F7BC  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
000000018036F7C1  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
000000018036F7C6  F2 0F 58 F9                 addsd   xmm7, xmm1
000000018036F7CA  F2 41 0F 59 EC              mulsd   xmm5, xmm12
000000018036F7CF  F2 0F 58 FA                 addsd   xmm7, xmm2
000000018036F7D3  0F 28 F5                    movaps  xmm6, xmm5
000000018036F7D6  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
000000018036F7DB  F2 41 0F 59 F4              mulsd   xmm6, xmm12
000000018036F7E0  F2 0F 58 FB                 addsd   xmm7, xmm3
000000018036F7E4  44 0F 28 C6                 movaps  xmm8, xmm6
000000018036F7E8  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
000000018036F7ED  F2 0F 58 FC                 addsd   xmm7, xmm4
000000018036F7F1  F2 45 0F 59 C4              mulsd   xmm8, xmm12
000000018036F7F6  F2 0F 58 FD                 addsd   xmm7, xmm5
000000018036F7FA  45 0F 28 C8                 movaps  xmm9, xmm8
000000018036F7FE  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
000000018036F807  F2 45 0F 59 CC              mulsd   xmm9, xmm12
000000018036F80C  F2 0F 58 FE                 addsd   xmm7, xmm6
000000018036F810  45 0F 28 D1                 movaps  xmm10, xmm9
000000018036F814  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
000000018036F81D  F2 41 0F 58 F8              addsd   xmm7, xmm8
000000018036F822  F2 45 0F 59 D4              mulsd   xmm10, xmm12
000000018036F827  F2 41 0F 58 F9              addsd   xmm7, xmm9
000000018036F82C  45 0F 28 DA                 movaps  xmm11, xmm10
000000018036F830  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
000000018036F839  F2 45 0F 59 DC              mulsd   xmm11, xmm12
000000018036F83E  F2 41 0F 58 FA              addsd   xmm7, xmm10
000000018036F843  41 0F 28 C3                 movaps  xmm0, xmm11
000000018036F847  F2 45 0F 59 DC              mulsd   xmm11, xmm12
000000018036F84C  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
000000018036F854  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
000000018036F85D  F2 0F 58 F8                 addsd   xmm7, xmm0
000000018036F861  F2 41 0F 58 FB              addsd   xmm7, xmm11
000000018036F866  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
000000018036F86A  F3 0F 5D 1D 26 B4 61 00     minss   xmm3, cs:dword_18098AC98
000000018036F872  F3 0F 5F 1D 36 B4 61 00     maxss   xmm3, cs:dword_18098ACB0
000000018036F87A  F3 0F 59 9B E0 37 00 00     mulss   xmm3, dword ptr [rbx+37E0h]
000000018036F882  F3 0F 11 9B 50 3A 00 00     movss   dword ptr [rbx+3A50h], xmm3
000000018036F88A  8B 83 F0 3B 00 00           mov     eax, [rbx+3BF0h]
000000018036F890  F3 0F 10 AB D0 37 00 00     movss   xmm5, dword ptr [rbx+37D0h]
000000018036F898  F3 0F 10 83 A0 39 00 00     movss   xmm0, dword ptr [rbx+39A0h]
000000018036F8A0  F3 0F 10 8B B0 39 00 00     movss   xmm1, dword ptr [rbx+39B0h]
000000018036F8A8  F3 0F 10 93 C0 39 00 00     movss   xmm2, dword ptr [rbx+39C0h]
000000018036F8B0  89 83 00 3C 00 00           mov     [rbx+3C00h], eax
000000018036F8B6  8B 83 10 3C 00 00           mov     eax, [rbx+3C10h]
000000018036F8BC  89 83 20 3C 00 00           mov     [rbx+3C20h], eax
000000018036F8C2  8B 83 C0 3C 00 00           mov     eax, [rbx+3CC0h]
000000018036F8C8  89 83 D0 3C 00 00           mov     [rbx+3CD0h], eax
000000018036F8CE  8B 83 B0 3C 00 00           mov     eax, [rbx+3CB0h]
000000018036F8D4  89 83 C0 3C 00 00           mov     [rbx+3CC0h], eax
000000018036F8DA  8B 83 A0 3C 00 00           mov     eax, [rbx+3CA0h]
000000018036F8E0  89 83 B0 3C 00 00           mov     [rbx+3CB0h], eax
000000018036F8E6  8B 83 90 3C 00 00           mov     eax, [rbx+3C90h]
000000018036F8EC  89 83 A0 3C 00 00           mov     [rbx+3CA0h], eax
000000018036F8F2  8B 83 80 3C 00 00           mov     eax, [rbx+3C80h]
000000018036F8F8  89 83 90 3C 00 00           mov     [rbx+3C90h], eax
000000018036F8FE  8B 83 70 3C 00 00           mov     eax, [rbx+3C70h]
000000018036F904  89 83 80 3C 00 00           mov     [rbx+3C80h], eax
000000018036F90A  8B 83 60 3C 00 00           mov     eax, [rbx+3C60h]
000000018036F910  89 83 70 3C 00 00           mov     [rbx+3C70h], eax
000000018036F916  8B 83 40 3D 00 00           mov     eax, [rbx+3D40h]
000000018036F91C  89 83 50 3D 00 00           mov     [rbx+3D50h], eax
000000018036F922  8B 83 30 3D 00 00           mov     eax, [rbx+3D30h]
000000018036F928  89 83 40 3D 00 00           mov     [rbx+3D40h], eax
000000018036F92E  8B 83 20 3D 00 00           mov     eax, [rbx+3D20h]
000000018036F934  89 83 30 3D 00 00           mov     [rbx+3D30h], eax
000000018036F93A  8B 83 10 3D 00 00           mov     eax, [rbx+3D10h]
000000018036F940  89 83 20 3D 00 00           mov     [rbx+3D20h], eax
000000018036F946  8B 83 00 3D 00 00           mov     eax, [rbx+3D00h]
000000018036F94C  89 83 10 3D 00 00           mov     [rbx+3D10h], eax
000000018036F952  8B 83 F0 3C 00 00           mov     eax, [rbx+3CF0h]
000000018036F958  89 83 00 3D 00 00           mov     [rbx+3D00h], eax
000000018036F95E  8B 83 E0 3C 00 00           mov     eax, [rbx+3CE0h]
000000018036F964  89 83 F0 3C 00 00           mov     [rbx+3CF0h], eax
000000018036F96A  8B 83 C0 3D 00 00           mov     eax, [rbx+3DC0h]
000000018036F970  89 83 D0 3D 00 00           mov     [rbx+3DD0h], eax
000000018036F976  8B 83 B0 3D 00 00           mov     eax, [rbx+3DB0h]
000000018036F97C  89 83 C0 3D 00 00           mov     [rbx+3DC0h], eax
000000018036F982  8B 83 A0 3D 00 00           mov     eax, [rbx+3DA0h]
000000018036F988  89 83 B0 3D 00 00           mov     [rbx+3DB0h], eax
000000018036F98E  8B 83 90 3D 00 00           mov     eax, [rbx+3D90h]
000000018036F994  89 83 A0 3D 00 00           mov     [rbx+3DA0h], eax
000000018036F99A  8B 83 80 3D 00 00           mov     eax, [rbx+3D80h]
000000018036F9A0  89 83 90 3D 00 00           mov     [rbx+3D90h], eax
000000018036F9A6  8B 83 70 3D 00 00           mov     eax, [rbx+3D70h]
000000018036F9AC  89 83 80 3D 00 00           mov     [rbx+3D80h], eax
000000018036F9B2  8B 83 60 3D 00 00           mov     eax, [rbx+3D60h]
000000018036F9B8  89 83 70 3D 00 00           mov     [rbx+3D70h], eax
000000018036F9BE  8B 83 40 3E 00 00           mov     eax, [rbx+3E40h]
000000018036F9C4  89 83 50 3E 00 00           mov     [rbx+3E50h], eax
000000018036F9CA  8B 83 30 3E 00 00           mov     eax, [rbx+3E30h]
000000018036F9D0  89 83 40 3E 00 00           mov     [rbx+3E40h], eax
000000018036F9D6  8B 83 20 3E 00 00           mov     eax, [rbx+3E20h]
000000018036F9DC  89 83 30 3E 00 00           mov     [rbx+3E30h], eax
000000018036F9E2  8B 83 10 3E 00 00           mov     eax, [rbx+3E10h]
000000018036F9E8  89 83 20 3E 00 00           mov     [rbx+3E20h], eax
000000018036F9EE  8B 83 00 3E 00 00           mov     eax, [rbx+3E00h]
000000018036F9F4  89 83 10 3E 00 00           mov     [rbx+3E10h], eax
000000018036F9FA  8B 83 F0 3D 00 00           mov     eax, [rbx+3DF0h]
000000018036FA00  89 83 00 3E 00 00           mov     [rbx+3E00h], eax
000000018036FA06  8B 83 E0 3D 00 00           mov     eax, [rbx+3DE0h]
000000018036FA0C  89 83 F0 3D 00 00           mov     [rbx+3DF0h], eax
000000018036FA12  8B 83 80 3E 00 00           mov     eax, [rbx+3E80h]
000000018036FA18  89 83 90 3E 00 00           mov     [rbx+3E90h], eax
000000018036FA1E  8B 83 70 3E 00 00           mov     eax, [rbx+3E70h]
000000018036FA24  89 83 80 3E 00 00           mov     [rbx+3E80h], eax
000000018036FA2A  F3 0F 11 83 90 3B 00 00     movss   dword ptr [rbx+3B90h], xmm0
000000018036FA32  F3 0F 11 8B A0 3B 00 00     movss   dword ptr [rbx+3BA0h], xmm1
000000018036FA3A  F3 0F 58 AB B0 41 00 00     addss   xmm5, dword ptr [rbx+41B0h]
000000018036FA42  F3 0F 59 9B B0 3E 00 00     mulss   xmm3, dword ptr [rbx+3EB0h]
000000018036FA4A  F3 0F 10 83 A0 3E 00 00     movss   xmm0, dword ptr [rbx+3EA0h]
000000018036FA52  F3 0F 11 93 B0 3B 00 00     movss   dword ptr [rbx+3BB0h], xmm2
000000018036FA5A  F3 0F 10 93 D0 3E 00 00     movss   xmm2, dword ptr [rbx+3ED0h]
000000018036FA62  F3 0F 59 AB C0 41 00 00     mulss   xmm5, dword ptr [rbx+41C0h]
000000018036FA6A  F3 0F 5F D3                 maxss   xmm2, xmm3
000000018036FA6E  F3 0F 58 AB A0 41 00 00     addss   xmm5, dword ptr [rbx+41A0h]
000000018036FA76  F3 0F 11 93 C0 3B 00 00     movss   dword ptr [rbx+3BC0h], xmm2
000000018036FA7E  F3 0F 58 83 F0 37 00 00     addss   xmm0, dword ptr [rbx+37F0h]
000000018036FA86  41 0F 2F EE                 comiss  xmm5, xmm14
000000018036FA8A  F3 0F 11 83 E0 3B 00 00     movss   dword ptr [rbx+3BE0h], xmm0
000000018036FA92  76 05                       jbe     short loc_18036FA99
000000018036FA94  0F 5A C5                    cvtps2pd xmm0, xmm5
000000018036FA97  EB 03                       jmp     short loc_18036FA9C
000000018036FA99  0F 57 C0                    xorps   xmm0, xmm0
000000018036FA9C  F3 0F 10 0D B8 54 77 00     movss   xmm1, cs:dword_180AE4F5C
000000018036FAA4  F3 44 0F 10 15 3B 57 77 00  movss   xmm10, cs:flt_180AE51E8
000000018036FAAD  F3 0F 5E CA                 divss   xmm1, xmm2
000000018036FAB1  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018036FAB5  F3 0F 11 8B D0 3B 00 00     movss   dword ptr [rbx+3BD0h], xmm1
000000018036FABD  F3 0F 11 83 60 3E 00 00     movss   dword ptr [rbx+3E60h], xmm0
000000018036FAC5  F3 0F 10 B3 20 3C 00 00     movss   xmm6, dword ptr [rbx+3C20h]
000000018036FACD  F3 0F 10 8B 00 3C 00 00     movss   xmm1, dword ptr [rbx+3C00h]
000000018036FAD5  F3 0F 11 B3 40 3B 00 00     movss   dword ptr [rbx+3B40h], xmm6
000000018036FADD  F3 0F 58 F2                 addss   xmm6, xmm2
000000018036FAE1  F3 0F 11 8B 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm1
000000018036FAE9  41 0F 2F F5                 comiss  xmm6, xmm13
000000018036FAED  76 1B                       jbe     short loc_18036FB0A
000000018036FAEF  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018036FAF4  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018036FAF8  0F 28 C6                    movaps  xmm0, xmm6; X
000000018036FAFB  E8 D8 F9 37 00              call    fmodf
000000018036FB00  0F 28 F0                    movaps  xmm6, xmm0
000000018036FB03  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018036FB08  EB 1F                       jmp     short loc_18036FB29
000000018036FB0A  41 0F 2F F7                 comiss  xmm6, xmm15
000000018036FB0E  73 19                       jnb     short loc_18036FB29
000000018036FB10  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018036FB15  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018036FB19  0F 28 C6                    movaps  xmm0, xmm6; X
000000018036FB1C  E8 B7 F9 37 00              call    fmodf
000000018036FB21  0F 28 F0                    movaps  xmm6, xmm0
000000018036FB24  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018036FB29  F3 44 0F 10 25 DA 54 77 00  movss   xmm12, cs:dword_180AE500C
000000018036FB32  0F 28 C6                    movaps  xmm0, xmm6
000000018036FB35  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018036FB3A  F3 0F 11 B3 30 3B 00 00     movss   dword ptr [rbx+3B30h], xmm6
000000018036FB42  0F 28 FE                    movaps  xmm7, xmm6
000000018036FB45  F3 0F 59 BB 20 3F 00 00     mulss   xmm7, dword ptr [rbx+3F20h]
000000018036FB4D  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018036FB52  E8 69 94 FF FF              call    sub_180368FC0
000000018036FB57  F3 44 0F 10 1D E4 58 77 00  movss   xmm11, cs:dword_180AE5444
000000018036FB60  0F 28 E8                    movaps  xmm5, xmm0
000000018036FB63  F3 41 0F 59 EB              mulss   xmm5, xmm11
000000018036FB68  F3 0F 59 AB D0 3B 00 00     mulss   xmm5, dword ptr [rbx+3BD0h]
000000018036FB70  F3 0F 59 AB F0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EF0h]
000000018036FB78  41 0F 2F EF                 comiss  xmm5, xmm15
000000018036FB7C  73 06                       jnb     short loc_18036FB84
000000018036FB7E  41 0F 28 EF                 movaps  xmm5, xmm15
000000018036FB82  EB 05                       jmp     short loc_18036FB89
000000018036FB84  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018036FB89  F3 0F 59 AB C0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EC0h]
000000018036FB91  0F 28 D5                    movaps  xmm2, xmm5
000000018036FB94  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018036FB98  0F 28 CA                    movaps  xmm1, xmm2
000000018036FB9B  0F 28 C2                    movaps  xmm0, xmm2
000000018036FB9E  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
000000018036FBA6  0F 28 DA                    movaps  xmm3, xmm2
000000018036FBA9  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036FBAD  0F 28 E2                    movaps  xmm4, xmm2
000000018036FBB0  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
000000018036FBB8  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
000000018036FBC0  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018036FBC4  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
000000018036FBCC  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018036FBD0  0F 28 C3                    movaps  xmm0, xmm3
000000018036FBD3  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
000000018036FBDB  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036FBDF  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036FBE3  F3 0F 10 8B E0 3B 00 00     movss   xmm1, dword ptr [rbx+3BE0h]
000000018036FBEB  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018036FBEF  0F 28 C1                    movaps  xmm0, xmm1
000000018036FBF2  F3 0F 58 C6                 addss   xmm0, xmm6
000000018036FBF6  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036FBFA  41 0F 2F C6                 comiss  xmm0, xmm14
000000018036FBFE  F3 0F 58 E5                 addss   xmm4, xmm5
000000018036FC02  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018036FC06  F3 0F 11 A3 30 3C 00 00     movss   dword ptr [rbx+3C30h], xmm4
000000018036FC0E  72 07                       jb      short loc_18036FC17
000000018036FC10  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018036FC15  EB 05                       jmp     short loc_18036FC1C
000000018036FC17  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018036FC1C  0F 28 F0                    movaps  xmm6, xmm0
000000018036FC1F  73 06                       jnb     short loc_18036FC27
000000018036FC21  41 0F 28 F7                 movaps  xmm6, xmm15
000000018036FC25  EB 06                       jmp     short loc_18036FC2D
000000018036FC27  76 04                       jbe     short loc_18036FC2D
000000018036FC29  41 0F 28 F5                 movaps  xmm6, xmm13
000000018036FC2D  F3 44 0F 10 83 30 3B 00 00  movss   xmm8, dword ptr [rbx+3B30h]
000000018036FC36  F3 0F 59 B3 30 3F 00 00     mulss   xmm6, dword ptr [rbx+3F30h]
000000018036FC3E  F3 0F 5E C1                 divss   xmm0, xmm1
000000018036FC42  E8 79 93 FF FF              call    sub_180368FC0
000000018036FC47  0F 28 E0                    movaps  xmm4, xmm0
000000018036FC4A  F3 0F 10 83 E0 3E 00 00     movss   xmm0, dword ptr [rbx+3EE0h]
000000018036FC52  44 0F 2F C0                 comiss  xmm8, xmm0
000000018036FC56  72 18                       jb      short loc_18036FC70
000000018036FC58  0F 2F 83 40 3B 00 00        comiss  xmm0, dword ptr [rbx+3B40h]
000000018036FC5F  76 0F                       jbe     short loc_18036FC70
000000018036FC61  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
000000018036FC69  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018036FC6E  EB 08                       jmp     short loc_18036FC78
000000018036FC70  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
000000018036FC78  0F 2F 3D 51 56 77 00        comiss  xmm7, cs:dword_180AE52D0
000000018036FC7F  F3 0F 59 A3 D0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BD0h]
000000018036FC87  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018036FC8C  F3 0F 59 A3 00 3F 00 00     mulss   xmm4, dword ptr [rbx+3F00h]
000000018036FC94  72 03                       jb      short loc_18036FC99
000000018036FC96  0F 57 FF                    xorps   xmm7, xmm7
000000018036FC99  41 0F 2F E7                 comiss  xmm4, xmm15
000000018036FC9D  73 06                       jnb     short loc_18036FCA5
000000018036FC9F  41 0F 28 E7                 movaps  xmm4, xmm15
000000018036FCA3  EB 05                       jmp     short loc_18036FCAA
000000018036FCA5  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018036FCAA  F3 0F 11 BB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm7
000000018036FCB2  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018036FCB7  F3 0F 59 A3 C0 3E 00 00     mulss   xmm4, dword ptr [rbx+3EC0h]
000000018036FCBF  0F 28 D4                    movaps  xmm2, xmm4
000000018036FCC2  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018036FCC7  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018036FCCB  0F 28 C2                    movaps  xmm0, xmm2
000000018036FCCE  F3 41 0F 59 FC              mulss   xmm7, xmm12
000000018036FCD3  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036FCD7  0F 28 DA                    movaps  xmm3, xmm2
000000018036FCDA  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018036FCDE  44 0F 28 CA                 movaps  xmm9, xmm2
000000018036FCE2  F3 44 0F 59 8B 90 40 00 00  mulss   xmm9, dword ptr [rbx+4090h]
000000018036FCEB  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018036FCF0  0F 28 CA                    movaps  xmm1, xmm2
000000018036FCF3  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
000000018036FCFB  F3 44 0F 58 8B 80 40 00 00  addss   xmm9, dword ptr [rbx+4080h]
000000018036FD04  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
000000018036FD0C  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018036FD11  0F 28 C3                    movaps  xmm0, xmm3
000000018036FD14  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
000000018036FD1C  F3 44 0F 58 C9              addss   xmm9, xmm1
000000018036FD21  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036FD25  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018036FD2A  0F 28 C7                    movaps  xmm0, xmm7
000000018036FD2D  0F 54 05 5C 5A 77 00        andps   xmm0, cs:xmmword_180AE5790
000000018036FD34  0F 57 05 85 5A 77 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018036FD3B  F3 44 0F 58 CB              addss   xmm9, xmm3
000000018036FD40  F3 44 0F 58 CC              addss   xmm9, xmm4
000000018036FD45  F3 44 0F 59 CE              mulss   xmm9, xmm6
000000018036FD4A  F3 44 0F 11 8B 40 3C 00 00  movss   dword ptr [rbx+3C40h], xmm9
000000018036FD53  E8 68 92 FF FF              call    sub_180368FC0
000000018036FD58  41 0F 2F FE                 comiss  xmm7, xmm14
000000018036FD5C  44 0F 28 C0                 movaps  xmm8, xmm0
000000018036FD60  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018036FD65  73 06                       jnb     short loc_18036FD6D
000000018036FD67  41 0F 28 FF                 movaps  xmm7, xmm15
000000018036FD6B  EB 06                       jmp     short loc_18036FD73
000000018036FD6D  76 04                       jbe     short loc_18036FD73
000000018036FD6F  41 0F 28 FD                 movaps  xmm7, xmm13
000000018036FD73  F3 44 0F 59 83 D0 3B 00 00  mulss   xmm8, dword ptr [rbx+3BD0h]
000000018036FD7C  F3 0F 59 BB 40 3F 00 00     mulss   xmm7, dword ptr [rbx+3F40h]
000000018036FD84  F3 44 0F 59 05 0B AF 61 00  mulss   xmm8, cs:dword_18098AC98
000000018036FD8D  F3 44 0F 59 83 10 3F 00 00  mulss   xmm8, dword ptr [rbx+3F10h]
000000018036FD96  45 0F 2F C7                 comiss  xmm8, xmm15
000000018036FD9A  73 06                       jnb     short loc_18036FDA2
000000018036FD9C  45 0F 28 C7                 movaps  xmm8, xmm15
000000018036FDA0  EB 05                       jmp     short loc_18036FDA7
000000018036FDA2  F3 45 0F 5D C5              minss   xmm8, xmm13
000000018036FDA7  F3 44 0F 59 83 C0 3E 00 00  mulss   xmm8, dword ptr [rbx+3EC0h]
000000018036FDB0  F3 44 0F 59 8B A0 3B 00 00  mulss   xmm9, dword ptr [rbx+3BA0h]
000000018036FDB9  F3 0F 10 B3 30 3B 00 00     movss   xmm6, dword ptr [rbx+3B30h]
000000018036FDC1  41 0F 28 D0                 movaps  xmm2, xmm8
000000018036FDC5  F3 0F 10 AB 50 3B 00 00     movss   xmm5, dword ptr [rbx+3B50h]
000000018036FDCD  F3 41 0F 59 D0              mulss   xmm2, xmm8
000000018036FDD2  0F 28 C2                    movaps  xmm0, xmm2
000000018036FDD5  0F 28 DA                    movaps  xmm3, xmm2
000000018036FDD8  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036FDDC  0F 28 E2                    movaps  xmm4, xmm2
000000018036FDDF  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
000000018036FDE7  0F 28 CA                    movaps  xmm1, xmm2
000000018036FDEA  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
000000018036FDF2  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
000000018036FDFA  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018036FDFF  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
000000018036FE07  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018036FE0B  0F 28 C3                    movaps  xmm0, xmm3
000000018036FE0E  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
000000018036FE16  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036FE1A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036FE1E  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018036FE22  F3 0F 10 83 30 3C 00 00     movss   xmm0, dword ptr [rbx+3C30h]
000000018036FE2A  F3 0F 59 83 90 3B 00 00     mulss   xmm0, dword ptr [rbx+3B90h]
000000018036FE32  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036FE36  F3 41 0F 58 C1              addss   xmm0, xmm9
000000018036FE3B  F3 41 0F 58 E0              addss   xmm4, xmm8
000000018036FE40  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018036FE44  F3 0F 59 A3 B0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BB0h]
000000018036FE4C  F3 0F 58 E0                 addss   xmm4, xmm0
000000018036FE50  F3 0F 11 A3 60 3C 00 00     movss   dword ptr [rbx+3C60h], xmm4
000000018036FE58  F3 0F 11 B3 40 3B 00 00     movss   dword ptr [rbx+3B40h], xmm6
000000018036FE60  F3 0F 11 AB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm5
000000018036FE68  F3 0F 58 B3 C0 3B 00 00     addss   xmm6, dword ptr [rbx+3BC0h]
000000018036FE70  41 0F 2F F5                 comiss  xmm6, xmm13
000000018036FE74  76 1B                       jbe     short loc_18036FE91
000000018036FE76  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018036FE7B  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018036FE7F  0F 28 C6                    movaps  xmm0, xmm6; X
000000018036FE82  E8 51 F6 37 00              call    fmodf
000000018036FE87  0F 28 F0                    movaps  xmm6, xmm0
000000018036FE8A  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018036FE8F  EB 1F                       jmp     short loc_18036FEB0
000000018036FE91  41 0F 2F F7                 comiss  xmm6, xmm15
000000018036FE95  73 19                       jnb     short loc_18036FEB0
000000018036FE97  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018036FE9C  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018036FEA0  0F 28 C6                    movaps  xmm0, xmm6; X
000000018036FEA3  E8 30 F6 37 00              call    fmodf
000000018036FEA8  0F 28 F0                    movaps  xmm6, xmm0
000000018036FEAB  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018036FEB0  0F 28 C6                    movaps  xmm0, xmm6
000000018036FEB3  F3 0F 11 B3 30 3B 00 00     movss   dword ptr [rbx+3B30h], xmm6
000000018036FEBB  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018036FEC0  0F 28 FE                    movaps  xmm7, xmm6
000000018036FEC3  F3 0F 59 BB 20 3F 00 00     mulss   xmm7, dword ptr [rbx+3F20h]
000000018036FECB  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018036FED0  E8 EB 90 FF FF              call    sub_180368FC0
000000018036FED5  0F 28 E8                    movaps  xmm5, xmm0
000000018036FED8  F3 41 0F 59 EB              mulss   xmm5, xmm11
000000018036FEDD  F3 0F 59 AB D0 3B 00 00     mulss   xmm5, dword ptr [rbx+3BD0h]
000000018036FEE5  F3 0F 59 AB F0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EF0h]
000000018036FEED  41 0F 2F EF                 comiss  xmm5, xmm15
000000018036FEF1  73 06                       jnb     short loc_18036FEF9
000000018036FEF3  41 0F 28 EF                 movaps  xmm5, xmm15
000000018036FEF7  EB 05                       jmp     short loc_18036FEFE
000000018036FEF9  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018036FEFE  F3 0F 59 AB C0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EC0h]
000000018036FF06  0F 28 D5                    movaps  xmm2, xmm5
000000018036FF09  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018036FF0D  0F 28 CA                    movaps  xmm1, xmm2
000000018036FF10  0F 28 C2                    movaps  xmm0, xmm2
000000018036FF13  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
000000018036FF1B  0F 28 DA                    movaps  xmm3, xmm2
000000018036FF1E  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036FF22  0F 28 E2                    movaps  xmm4, xmm2
000000018036FF25  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
000000018036FF2D  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
000000018036FF35  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018036FF39  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
000000018036FF41  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018036FF45  0F 28 C3                    movaps  xmm0, xmm3
000000018036FF48  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
000000018036FF50  F3 0F 58 E1                 addss   xmm4, xmm1
000000018036FF54  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018036FF58  F3 0F 10 8B E0 3B 00 00     movss   xmm1, dword ptr [rbx+3BE0h]
000000018036FF60  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018036FF64  0F 28 C1                    movaps  xmm0, xmm1
000000018036FF67  F3 0F 58 C6                 addss   xmm0, xmm6
000000018036FF6B  F3 0F 58 E3                 addss   xmm4, xmm3
000000018036FF6F  41 0F 2F C6                 comiss  xmm0, xmm14
000000018036FF73  F3 0F 58 E5                 addss   xmm4, xmm5
000000018036FF77  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018036FF7B  F3 0F 11 A3 30 3C 00 00     movss   dword ptr [rbx+3C30h], xmm4
000000018036FF83  72 07                       jb      short loc_18036FF8C
000000018036FF85  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018036FF8A  EB 05                       jmp     short loc_18036FF91
000000018036FF8C  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018036FF91  0F 28 F0                    movaps  xmm6, xmm0
000000018036FF94  73 06                       jnb     short loc_18036FF9C
000000018036FF96  41 0F 28 F7                 movaps  xmm6, xmm15
000000018036FF9A  EB 06                       jmp     short loc_18036FFA2
000000018036FF9C  76 04                       jbe     short loc_18036FFA2
000000018036FF9E  41 0F 28 F5                 movaps  xmm6, xmm13
000000018036FFA2  F3 44 0F 10 83 30 3B 00 00  movss   xmm8, dword ptr [rbx+3B30h]
000000018036FFAB  F3 0F 59 B3 30 3F 00 00     mulss   xmm6, dword ptr [rbx+3F30h]
000000018036FFB3  F3 0F 5E C1                 divss   xmm0, xmm1
000000018036FFB7  E8 04 90 FF FF              call    sub_180368FC0
000000018036FFBC  0F 28 E0                    movaps  xmm4, xmm0
000000018036FFBF  F3 0F 10 83 E0 3E 00 00     movss   xmm0, dword ptr [rbx+3EE0h]
000000018036FFC7  44 0F 2F C0                 comiss  xmm8, xmm0
000000018036FFCB  72 18                       jb      short loc_18036FFE5
000000018036FFCD  0F 2F 83 40 3B 00 00        comiss  xmm0, dword ptr [rbx+3B40h]
000000018036FFD4  76 0F                       jbe     short loc_18036FFE5
000000018036FFD6  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
000000018036FFDE  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018036FFE3  EB 08                       jmp     short loc_18036FFED
000000018036FFE5  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
000000018036FFED  0F 2F 3D DC 52 77 00        comiss  xmm7, cs:dword_180AE52D0
000000018036FFF4  F3 0F 59 A3 D0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BD0h]
000000018036FFFC  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180370001  F3 0F 59 A3 00 3F 00 00     mulss   xmm4, dword ptr [rbx+3F00h]
0000000180370009  72 03                       jb      short loc_18037000E
000000018037000B  0F 57 FF                    xorps   xmm7, xmm7
000000018037000E  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180370012  73 06                       jnb     short loc_18037001A
0000000180370014  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180370018  EB 05                       jmp     short loc_18037001F
000000018037001A  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037001F  F3 0F 11 BB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm7
0000000180370027  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018037002C  F3 0F 59 A3 C0 3E 00 00     mulss   xmm4, dword ptr [rbx+3EC0h]
0000000180370034  0F 28 D4                    movaps  xmm2, xmm4
0000000180370037  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037003C  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180370040  0F 28 C2                    movaps  xmm0, xmm2
0000000180370043  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180370048  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037004C  0F 28 DA                    movaps  xmm3, xmm2
000000018037004F  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180370053  44 0F 28 CA                 movaps  xmm9, xmm2
0000000180370057  F3 44 0F 59 8B 90 40 00 00  mulss   xmm9, dword ptr [rbx+4090h]
0000000180370060  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180370065  0F 28 CA                    movaps  xmm1, xmm2
0000000180370068  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
0000000180370070  F3 44 0F 58 8B 80 40 00 00  addss   xmm9, dword ptr [rbx+4080h]
0000000180370079  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
0000000180370081  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180370086  0F 28 C3                    movaps  xmm0, xmm3
0000000180370089  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
0000000180370091  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180370096  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037009A  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037009F  0F 28 C7                    movaps  xmm0, xmm7
00000001803700A2  0F 54 05 E7 56 77 00        andps   xmm0, cs:xmmword_180AE5790
00000001803700A9  0F 57 05 10 57 77 00        xorps   xmm0, cs:xmmword_180AE57C0
00000001803700B0  F3 44 0F 58 CB              addss   xmm9, xmm3
00000001803700B5  F3 44 0F 58 CC              addss   xmm9, xmm4
00000001803700BA  F3 44 0F 59 CE              mulss   xmm9, xmm6
00000001803700BF  F3 44 0F 11 8B 40 3C 00 00  movss   dword ptr [rbx+3C40h], xmm9
00000001803700C8  E8 F3 8E FF FF              call    sub_180368FC0
00000001803700CD  41 0F 2F FE                 comiss  xmm7, xmm14
00000001803700D1  44 0F 28 C0                 movaps  xmm8, xmm0
00000001803700D5  F3 45 0F 58 C5              addss   xmm8, xmm13
00000001803700DA  73 06                       jnb     short loc_1803700E2
00000001803700DC  41 0F 28 FF                 movaps  xmm7, xmm15
00000001803700E0  EB 06                       jmp     short loc_1803700E8
00000001803700E2  76 04                       jbe     short loc_1803700E8
00000001803700E4  41 0F 28 FD                 movaps  xmm7, xmm13
00000001803700E8  F3 44 0F 59 83 D0 3B 00 00  mulss   xmm8, dword ptr [rbx+3BD0h]
00000001803700F1  F3 0F 59 BB 40 3F 00 00     mulss   xmm7, dword ptr [rbx+3F40h]
00000001803700F9  F3 44 0F 59 05 96 AB 61 00  mulss   xmm8, cs:dword_18098AC98
0000000180370102  F3 44 0F 59 83 10 3F 00 00  mulss   xmm8, dword ptr [rbx+3F10h]
000000018037010B  45 0F 2F C7                 comiss  xmm8, xmm15
000000018037010F  73 06                       jnb     short loc_180370117
0000000180370111  45 0F 28 C7                 movaps  xmm8, xmm15
0000000180370115  EB 05                       jmp     short loc_18037011C
0000000180370117  F3 45 0F 5D C5              minss   xmm8, xmm13
000000018037011C  F3 44 0F 59 83 C0 3E 00 00  mulss   xmm8, dword ptr [rbx+3EC0h]
0000000180370125  F3 44 0F 59 8B A0 3B 00 00  mulss   xmm9, dword ptr [rbx+3BA0h]
000000018037012E  F3 0F 10 B3 30 3B 00 00     movss   xmm6, dword ptr [rbx+3B30h]
0000000180370136  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037013A  F3 0F 10 AB 50 3B 00 00     movss   xmm5, dword ptr [rbx+3B50h]
0000000180370142  F3 41 0F 59 D0              mulss   xmm2, xmm8
0000000180370147  0F 28 C2                    movaps  xmm0, xmm2
000000018037014A  0F 28 DA                    movaps  xmm3, xmm2
000000018037014D  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180370151  0F 28 E2                    movaps  xmm4, xmm2
0000000180370154  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
000000018037015C  0F 28 CA                    movaps  xmm1, xmm2
000000018037015F  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
0000000180370167  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
000000018037016F  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180370174  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
000000018037017C  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180370180  0F 28 C3                    movaps  xmm0, xmm3
0000000180370183  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
000000018037018B  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037018F  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180370193  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180370197  F3 0F 10 83 30 3C 00 00     movss   xmm0, dword ptr [rbx+3C30h]
000000018037019F  F3 0F 59 83 90 3B 00 00     mulss   xmm0, dword ptr [rbx+3B90h]
00000001803701A7  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803701AB  F3 41 0F 58 C1              addss   xmm0, xmm9
00000001803701B0  F3 41 0F 58 E0              addss   xmm4, xmm8
00000001803701B5  F3 0F 59 E7                 mulss   xmm4, xmm7
00000001803701B9  F3 0F 59 A3 B0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BB0h]
00000001803701C1  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803701C5  F3 0F 11 A3 E0 3C 00 00     movss   dword ptr [rbx+3CE0h], xmm4
00000001803701CD  F3 0F 11 B3 40 3B 00 00     movss   dword ptr [rbx+3B40h], xmm6
00000001803701D5  F3 0F 11 AB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm5
00000001803701DD  F3 0F 58 B3 C0 3B 00 00     addss   xmm6, dword ptr [rbx+3BC0h]
00000001803701E5  41 0F 2F F5                 comiss  xmm6, xmm13
00000001803701E9  76 1B                       jbe     short loc_180370206
00000001803701EB  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803701F0  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00000001803701F4  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803701F7  E8 DC F2 37 00              call    fmodf
00000001803701FC  0F 28 F0                    movaps  xmm6, xmm0
00000001803701FF  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180370204  EB 1F                       jmp     short loc_180370225
0000000180370206  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037020A  73 19                       jnb     short loc_180370225
000000018037020C  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180370211  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180370215  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180370218  E8 BB F2 37 00              call    fmodf
000000018037021D  0F 28 F0                    movaps  xmm6, xmm0
0000000180370220  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180370225  0F 28 C6                    movaps  xmm0, xmm6
0000000180370228  F3 0F 11 B3 30 3B 00 00     movss   dword ptr [rbx+3B30h], xmm6
0000000180370230  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180370235  0F 28 FE                    movaps  xmm7, xmm6
0000000180370238  F3 0F 59 BB 20 3F 00 00     mulss   xmm7, dword ptr [rbx+3F20h]
0000000180370240  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180370245  E8 76 8D FF FF              call    sub_180368FC0
000000018037024A  0F 28 E8                    movaps  xmm5, xmm0
000000018037024D  F3 41 0F 59 EB              mulss   xmm5, xmm11
0000000180370252  F3 0F 59 AB D0 3B 00 00     mulss   xmm5, dword ptr [rbx+3BD0h]
000000018037025A  F3 0F 59 AB F0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EF0h]
0000000180370262  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180370266  73 06                       jnb     short loc_18037026E
0000000180370268  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037026C  EB 05                       jmp     short loc_180370273
000000018037026E  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180370273  F3 0F 59 AB C0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EC0h]
000000018037027B  0F 28 D5                    movaps  xmm2, xmm5
000000018037027E  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180370282  0F 28 CA                    movaps  xmm1, xmm2
0000000180370285  0F 28 C2                    movaps  xmm0, xmm2
0000000180370288  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
0000000180370290  0F 28 DA                    movaps  xmm3, xmm2
0000000180370293  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180370297  0F 28 E2                    movaps  xmm4, xmm2
000000018037029A  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
00000001803702A2  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00000001803702AA  F3 0F 59 DD                 mulss   xmm3, xmm5
00000001803702AE  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
00000001803702B6  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803702BA  0F 28 C3                    movaps  xmm0, xmm3
00000001803702BD  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
00000001803702C5  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803702C9  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803702CD  F3 0F 10 8B E0 3B 00 00     movss   xmm1, dword ptr [rbx+3BE0h]
00000001803702D5  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803702D9  0F 28 C1                    movaps  xmm0, xmm1
00000001803702DC  F3 0F 58 C6                 addss   xmm0, xmm6
00000001803702E0  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803702E4  41 0F 2F C6                 comiss  xmm0, xmm14
00000001803702E8  F3 0F 58 E5                 addss   xmm4, xmm5
00000001803702EC  F3 0F 59 E7                 mulss   xmm4, xmm7
00000001803702F0  F3 0F 11 A3 30 3C 00 00     movss   dword ptr [rbx+3C30h], xmm4
00000001803702F8  72 07                       jb      short loc_180370301
00000001803702FA  F3 41 0F 58 CD              addss   xmm1, xmm13
00000001803702FF  EB 05                       jmp     short loc_180370306
0000000180370301  F3 41 0F 5C CD              subss   xmm1, xmm13
0000000180370306  0F 28 F0                    movaps  xmm6, xmm0
0000000180370309  73 06                       jnb     short loc_180370311
000000018037030B  41 0F 28 F7                 movaps  xmm6, xmm15
000000018037030F  EB 06                       jmp     short loc_180370317
0000000180370311  76 04                       jbe     short loc_180370317
0000000180370313  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180370317  F3 44 0F 10 83 30 3B 00 00  movss   xmm8, dword ptr [rbx+3B30h]
0000000180370320  F3 0F 59 B3 30 3F 00 00     mulss   xmm6, dword ptr [rbx+3F30h]
0000000180370328  F3 0F 5E C1                 divss   xmm0, xmm1
000000018037032C  E8 8F 8C FF FF              call    sub_180368FC0
0000000180370331  0F 28 E0                    movaps  xmm4, xmm0
0000000180370334  F3 0F 10 83 E0 3E 00 00     movss   xmm0, dword ptr [rbx+3EE0h]
000000018037033C  44 0F 2F C0                 comiss  xmm8, xmm0
0000000180370340  72 18                       jb      short loc_18037035A
0000000180370342  0F 2F 83 40 3B 00 00        comiss  xmm0, dword ptr [rbx+3B40h]
0000000180370349  76 0F                       jbe     short loc_18037035A
000000018037034B  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
0000000180370353  F3 41 0F 58 FA              addss   xmm7, xmm10
0000000180370358  EB 08                       jmp     short loc_180370362
000000018037035A  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
0000000180370362  0F 2F 3D 67 4F 77 00        comiss  xmm7, cs:dword_180AE52D0
0000000180370369  F3 0F 59 A3 D0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BD0h]
0000000180370371  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180370376  F3 0F 59 A3 00 3F 00 00     mulss   xmm4, dword ptr [rbx+3F00h]
000000018037037E  72 03                       jb      short loc_180370383
0000000180370380  0F 57 FF                    xorps   xmm7, xmm7
0000000180370383  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180370387  73 06                       jnb     short loc_18037038F
0000000180370389  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037038D  EB 05                       jmp     short loc_180370394
000000018037038F  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180370394  F3 0F 11 BB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm7
000000018037039C  F3 41 0F 58 F8              addss   xmm7, xmm8
00000001803703A1  F3 0F 59 A3 C0 3E 00 00     mulss   xmm4, dword ptr [rbx+3EC0h]
00000001803703A9  0F 28 D4                    movaps  xmm2, xmm4
00000001803703AC  F3 41 0F 58 FD              addss   xmm7, xmm13
00000001803703B1  F3 0F 59 D4                 mulss   xmm2, xmm4
00000001803703B5  0F 28 C2                    movaps  xmm0, xmm2
00000001803703B8  F3 41 0F 59 FC              mulss   xmm7, xmm12
00000001803703BD  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803703C1  0F 28 DA                    movaps  xmm3, xmm2
00000001803703C4  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803703C8  44 0F 28 CA                 movaps  xmm9, xmm2
00000001803703CC  F3 44 0F 59 8B 90 40 00 00  mulss   xmm9, dword ptr [rbx+4090h]
00000001803703D5  F3 41 0F 5C FD              subss   xmm7, xmm13
00000001803703DA  0F 28 CA                    movaps  xmm1, xmm2
00000001803703DD  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00000001803703E5  F3 44 0F 58 8B 80 40 00 00  addss   xmm9, dword ptr [rbx+4080h]
00000001803703EE  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00000001803703F6  F3 44 0F 59 C8              mulss   xmm9, xmm0
00000001803703FB  0F 28 C3                    movaps  xmm0, xmm3
00000001803703FE  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
0000000180370406  F3 44 0F 58 C9              addss   xmm9, xmm1
000000018037040B  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037040F  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180370414  0F 28 C7                    movaps  xmm0, xmm7
0000000180370417  0F 54 05 72 53 77 00        andps   xmm0, cs:xmmword_180AE5790
000000018037041E  0F 57 05 9B 53 77 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180370425  F3 44 0F 58 CB              addss   xmm9, xmm3
000000018037042A  F3 44 0F 58 CC              addss   xmm9, xmm4
000000018037042F  F3 44 0F 59 CE              mulss   xmm9, xmm6
0000000180370434  F3 44 0F 11 8B 40 3C 00 00  movss   dword ptr [rbx+3C40h], xmm9
000000018037043D  E8 7E 8B FF FF              call    sub_180368FC0
0000000180370442  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180370446  44 0F 28 C0                 movaps  xmm8, xmm0
000000018037044A  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018037044F  73 06                       jnb     short loc_180370457
0000000180370451  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180370455  EB 06                       jmp     short loc_18037045D
0000000180370457  76 04                       jbe     short loc_18037045D
0000000180370459  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037045D  F3 44 0F 59 83 D0 3B 00 00  mulss   xmm8, dword ptr [rbx+3BD0h]
0000000180370466  F3 0F 59 BB 40 3F 00 00     mulss   xmm7, dword ptr [rbx+3F40h]
000000018037046E  F3 44 0F 59 05 21 A8 61 00  mulss   xmm8, cs:dword_18098AC98
0000000180370477  F3 44 0F 59 83 10 3F 00 00  mulss   xmm8, dword ptr [rbx+3F10h]
0000000180370480  45 0F 2F C7                 comiss  xmm8, xmm15
0000000180370484  73 06                       jnb     short loc_18037048C
0000000180370486  45 0F 28 C7                 movaps  xmm8, xmm15
000000018037048A  EB 05                       jmp     short loc_180370491
000000018037048C  F3 45 0F 5D C5              minss   xmm8, xmm13
0000000180370491  F3 44 0F 59 83 C0 3E 00 00  mulss   xmm8, dword ptr [rbx+3EC0h]
000000018037049A  F3 44 0F 59 8B A0 3B 00 00  mulss   xmm9, dword ptr [rbx+3BA0h]
00000001803704A3  F3 0F 10 B3 30 3B 00 00     movss   xmm6, dword ptr [rbx+3B30h]
00000001803704AB  41 0F 28 D0                 movaps  xmm2, xmm8
00000001803704AF  F3 0F 10 AB 50 3B 00 00     movss   xmm5, dword ptr [rbx+3B50h]
00000001803704B7  F3 41 0F 59 D0              mulss   xmm2, xmm8
00000001803704BC  0F 28 C2                    movaps  xmm0, xmm2
00000001803704BF  0F 28 DA                    movaps  xmm3, xmm2
00000001803704C2  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803704C6  0F 28 E2                    movaps  xmm4, xmm2
00000001803704C9  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
00000001803704D1  0F 28 CA                    movaps  xmm1, xmm2
00000001803704D4  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
00000001803704DC  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
00000001803704E4  F3 41 0F 59 D8              mulss   xmm3, xmm8
00000001803704E9  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
00000001803704F1  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803704F5  0F 28 C3                    movaps  xmm0, xmm3
00000001803704F8  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
0000000180370500  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180370504  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180370508  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037050C  F3 0F 10 83 30 3C 00 00     movss   xmm0, dword ptr [rbx+3C30h]
0000000180370514  F3 0F 59 83 90 3B 00 00     mulss   xmm0, dword ptr [rbx+3B90h]
000000018037051C  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180370520  F3 41 0F 58 C1              addss   xmm0, xmm9
0000000180370525  F3 41 0F 58 E0              addss   xmm4, xmm8
000000018037052A  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037052E  F3 0F 59 A3 B0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BB0h]
0000000180370536  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037053A  F3 0F 11 A3 60 3D 00 00     movss   dword ptr [rbx+3D60h], xmm4
0000000180370542  F3 0F 11 B3 40 3B 00 00     movss   dword ptr [rbx+3B40h], xmm6
000000018037054A  F3 0F 11 AB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm5
0000000180370552  F3 0F 58 B3 C0 3B 00 00     addss   xmm6, dword ptr [rbx+3BC0h]
000000018037055A  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037055E  76 1B                       jbe     short loc_18037057B
0000000180370560  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180370565  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180370569  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037056C  E8 67 EF 37 00              call    fmodf
0000000180370571  0F 28 F0                    movaps  xmm6, xmm0
0000000180370574  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180370579  EB 1F                       jmp     short loc_18037059A
000000018037057B  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037057F  73 19                       jnb     short loc_18037059A
0000000180370581  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180370586  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037058A  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037058D  E8 46 EF 37 00              call    fmodf
0000000180370592  0F 28 F0                    movaps  xmm6, xmm0
0000000180370595  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037059A  0F 28 C6                    movaps  xmm0, xmm6
000000018037059D  F3 0F 11 B3 30 3B 00 00     movss   dword ptr [rbx+3B30h], xmm6
00000001803705A5  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803705AA  0F 28 FE                    movaps  xmm7, xmm6
00000001803705AD  F3 0F 59 BB 20 3F 00 00     mulss   xmm7, dword ptr [rbx+3F20h]
00000001803705B5  F3 41 0F 59 C4              mulss   xmm0, xmm12
00000001803705BA  E8 01 8A FF FF              call    sub_180368FC0
00000001803705BF  0F 28 E8                    movaps  xmm5, xmm0
00000001803705C2  F3 41 0F 59 EB              mulss   xmm5, xmm11
00000001803705C7  F3 0F 59 AB D0 3B 00 00     mulss   xmm5, dword ptr [rbx+3BD0h]
00000001803705CF  F3 0F 59 AB F0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EF0h]
00000001803705D7  41 0F 2F EF                 comiss  xmm5, xmm15
00000001803705DB  73 06                       jnb     short loc_1803705E3
00000001803705DD  41 0F 28 EF                 movaps  xmm5, xmm15
00000001803705E1  EB 05                       jmp     short loc_1803705E8
00000001803705E3  F3 41 0F 5D ED              minss   xmm5, xmm13
00000001803705E8  F3 0F 59 AB C0 3E 00 00     mulss   xmm5, dword ptr [rbx+3EC0h]
00000001803705F0  0F 28 D5                    movaps  xmm2, xmm5
00000001803705F3  F3 0F 59 D5                 mulss   xmm2, xmm5
00000001803705F7  0F 28 CA                    movaps  xmm1, xmm2
00000001803705FA  0F 28 C2                    movaps  xmm0, xmm2
00000001803705FD  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
0000000180370605  0F 28 DA                    movaps  xmm3, xmm2
0000000180370608  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037060C  0F 28 E2                    movaps  xmm4, xmm2
000000018037060F  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
0000000180370617  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
000000018037061F  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180370623  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
000000018037062B  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037062F  0F 28 C3                    movaps  xmm0, xmm3
0000000180370632  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
000000018037063A  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037063E  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180370642  F3 0F 10 8B E0 3B 00 00     movss   xmm1, dword ptr [rbx+3BE0h]
000000018037064A  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037064E  0F 28 C1                    movaps  xmm0, xmm1
0000000180370651  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180370655  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180370659  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037065D  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180370661  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180370665  F3 0F 11 A3 30 3C 00 00     movss   dword ptr [rbx+3C30h], xmm4
000000018037066D  72 07                       jb      short loc_180370676
000000018037066F  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180370674  EB 05                       jmp     short loc_18037067B
0000000180370676  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037067B  0F 28 F0                    movaps  xmm6, xmm0
000000018037067E  73 06                       jnb     short loc_180370686
0000000180370680  41 0F 28 F7                 movaps  xmm6, xmm15
0000000180370684  EB 06                       jmp     short loc_18037068C
0000000180370686  76 04                       jbe     short loc_18037068C
0000000180370688  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037068C  F3 44 0F 10 83 30 3B 00 00  movss   xmm8, dword ptr [rbx+3B30h]
0000000180370695  F3 0F 59 B3 30 3F 00 00     mulss   xmm6, dword ptr [rbx+3F30h]
000000018037069D  F3 0F 5E C1                 divss   xmm0, xmm1
00000001803706A1  E8 1A 89 FF FF              call    sub_180368FC0
00000001803706A6  0F 28 E0                    movaps  xmm4, xmm0
00000001803706A9  F3 0F 10 83 E0 3E 00 00     movss   xmm0, dword ptr [rbx+3EE0h]
00000001803706B1  44 0F 2F C0                 comiss  xmm8, xmm0
00000001803706B5  72 18                       jb      short loc_1803706CF
00000001803706B7  0F 2F 83 40 3B 00 00        comiss  xmm0, dword ptr [rbx+3B40h]
00000001803706BE  76 0F                       jbe     short loc_1803706CF
00000001803706C0  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
00000001803706C8  F3 41 0F 58 FA              addss   xmm7, xmm10
00000001803706CD  EB 08                       jmp     short loc_1803706D7
00000001803706CF  F3 0F 10 BB 50 3B 00 00     movss   xmm7, dword ptr [rbx+3B50h]
00000001803706D7  0F 2F 3D F2 4B 77 00        comiss  xmm7, cs:dword_180AE52D0
00000001803706DE  F3 0F 59 A3 D0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BD0h]
00000001803706E6  F3 41 0F 59 E3              mulss   xmm4, xmm11
00000001803706EB  F3 0F 59 A3 00 3F 00 00     mulss   xmm4, dword ptr [rbx+3F00h]
00000001803706F3  72 03                       jb      short loc_1803706F8
00000001803706F5  0F 57 FF                    xorps   xmm7, xmm7
00000001803706F8  41 0F 2F E7                 comiss  xmm4, xmm15
00000001803706FC  73 06                       jnb     short loc_180370704
00000001803706FE  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180370702  EB 05                       jmp     short loc_180370709
0000000180370704  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180370709  F3 0F 11 BB 50 3B 00 00     movss   dword ptr [rbx+3B50h], xmm7
0000000180370711  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180370716  F3 0F 59 A3 C0 3E 00 00     mulss   xmm4, dword ptr [rbx+3EC0h]
000000018037071E  0F 28 D4                    movaps  xmm2, xmm4
0000000180370721  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180370726  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037072A  0F 28 C2                    movaps  xmm0, xmm2
000000018037072D  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180370732  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180370736  0F 28 DA                    movaps  xmm3, xmm2
0000000180370739  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037073D  44 0F 28 C2                 movaps  xmm8, xmm2
0000000180370741  F3 44 0F 59 83 90 40 00 00  mulss   xmm8, dword ptr [rbx+4090h]
000000018037074A  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037074F  0F 28 CA                    movaps  xmm1, xmm2
0000000180370752  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
000000018037075A  F3 44 0F 58 83 80 40 00 00  addss   xmm8, dword ptr [rbx+4080h]
0000000180370763  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
000000018037076B  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180370770  0F 28 C3                    movaps  xmm0, xmm3
0000000180370773  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
000000018037077B  F3 44 0F 58 C1              addss   xmm8, xmm1
0000000180370780  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180370784  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180370789  0F 28 C7                    movaps  xmm0, xmm7
000000018037078C  0F 54 05 FD 4F 77 00        andps   xmm0, cs:xmmword_180AE5790
0000000180370793  0F 57 05 26 50 77 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037079A  F3 44 0F 58 C3              addss   xmm8, xmm3
000000018037079F  F3 44 0F 58 C4              addss   xmm8, xmm4
00000001803707A4  F3 44 0F 59 C6              mulss   xmm8, xmm6
00000001803707A9  F3 44 0F 11 83 40 3C 00 00  movss   dword ptr [rbx+3C40h], xmm8
00000001803707B2  E8 09 88 FF FF              call    sub_180368FC0
00000001803707B7  41 0F 2F FE                 comiss  xmm7, xmm14
00000001803707BB  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803707C0  73 06                       jnb     short loc_1803707C8
00000001803707C2  41 0F 28 FF                 movaps  xmm7, xmm15
00000001803707C6  EB 06                       jmp     short loc_1803707CE
00000001803707C8  76 04                       jbe     short loc_1803707CE
00000001803707CA  41 0F 28 FD                 movaps  xmm7, xmm13
00000001803707CE  F3 0F 59 83 D0 3B 00 00     mulss   xmm0, dword ptr [rbx+3BD0h]
00000001803707D6  F3 0F 59 BB 40 3F 00 00     mulss   xmm7, dword ptr [rbx+3F40h]
00000001803707DE  F3 0F 59 05 B2 A4 61 00     mulss   xmm0, cs:dword_18098AC98
00000001803707E6  F3 0F 59 83 10 3F 00 00     mulss   xmm0, dword ptr [rbx+3F10h]
00000001803707EE  41 0F 2F C7                 comiss  xmm0, xmm15
00000001803707F2  72 09                       jb      short loc_1803707FD
00000001803707F4  44 0F 28 F8                 movaps  xmm15, xmm0
00000001803707F8  F3 45 0F 5D FD              minss   xmm15, xmm13
00000001803707FD  F3 44 0F 59 BB C0 3E 00 00  mulss   xmm15, dword ptr [rbx+3EC0h]
0000000180370806  F3 44 0F 59 83 A0 3B 00 00  mulss   xmm8, dword ptr [rbx+3BA0h]
000000018037080F  F3 0F 10 AB 30 3B 00 00     movss   xmm5, dword ptr [rbx+3B30h]
0000000180370817  41 0F 28 D7                 movaps  xmm2, xmm15
000000018037081B  F3 0F 10 B3 50 3B 00 00     movss   xmm6, dword ptr [rbx+3B50h]
0000000180370823  F3 41 0F 59 D7              mulss   xmm2, xmm15
0000000180370828  0F 28 CA                    movaps  xmm1, xmm2
000000018037082B  0F 28 C2                    movaps  xmm0, xmm2
000000018037082E  F3 0F 59 8B 70 40 00 00     mulss   xmm1, dword ptr [rbx+4070h]
0000000180370836  0F 28 DA                    movaps  xmm3, xmm2
0000000180370839  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037083D  0F 28 E2                    movaps  xmm4, xmm2
0000000180370840  F3 0F 58 8B 60 40 00 00     addss   xmm1, dword ptr [rbx+4060h]
0000000180370848  F3 0F 59 A3 90 40 00 00     mulss   xmm4, dword ptr [rbx+4090h]
0000000180370850  F3 41 0F 59 DF              mulss   xmm3, xmm15
0000000180370855  F3 0F 58 A3 80 40 00 00     addss   xmm4, dword ptr [rbx+4080h]
000000018037085D  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180370861  0F 28 C3                    movaps  xmm0, xmm3
0000000180370864  F3 0F 59 9B 50 40 00 00     mulss   xmm3, dword ptr [rbx+4050h]
000000018037086C  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180370870  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180370874  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180370878  F3 0F 10 83 30 3C 00 00     movss   xmm0, dword ptr [rbx+3C30h]
0000000180370880  F3 0F 59 83 90 3B 00 00     mulss   xmm0, dword ptr [rbx+3B90h]
0000000180370888  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037088C  F3 41 0F 58 C0              addss   xmm0, xmm8
0000000180370891  F3 41 0F 58 E7              addss   xmm4, xmm15
0000000180370896  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037089A  F3 0F 59 A3 B0 3B 00 00     mulss   xmm4, dword ptr [rbx+3BB0h]
00000001803708A2  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803708A6  F3 0F 11 A3 E0 3D 00 00     movss   dword ptr [rbx+3DE0h], xmm4
00000001803708AE  F3 0F 10 93 50 3E 00 00     movss   xmm2, dword ptr [rbx+3E50h]
00000001803708B6  F3 0F 11 AB 10 3C 00 00     movss   dword ptr [rbx+3C10h], xmm5
00000001803708BE  F3 0F 11 B3 F0 3B 00 00     movss   dword ptr [rbx+3BF0h], xmm6
00000001803708C6  F3 0F 10 83 60 3D 00 00     movss   xmm0, dword ptr [rbx+3D60h]
00000001803708CE  F3 0F 58 83 50 3D 00 00     addss   xmm0, dword ptr [rbx+3D50h]
00000001803708D6  F3 0F 10 8B E0 3D 00 00     movss   xmm1, dword ptr [rbx+3DE0h]
00000001803708DE  F3 0F 58 8B D0 3C 00 00     addss   xmm1, dword ptr [rbx+3CD0h]
00000001803708E6  F3 0F 10 AB D0 3D 00 00     movss   xmm5, dword ptr [rbx+3DD0h]
00000001803708EE  F3 0F 58 AB E0 3C 00 00     addss   xmm5, dword ptr [rbx+3CE0h]
00000001803708F6  F3 0F 59 83 70 3F 00 00     mulss   xmm0, dword ptr [rbx+3F70h]
00000001803708FE  F3 0F 59 8B 80 3F 00 00     mulss   xmm1, dword ptr [rbx+3F80h]
0000000180370906  F3 0F 59 AB 60 3F 00 00     mulss   xmm5, dword ptr [rbx+3F60h]
000000018037090E  F3 0F 58 93 60 3C 00 00     addss   xmm2, dword ptr [rbx+3C60h]
0000000180370916  F3 0F 59 93 50 3F 00 00     mulss   xmm2, dword ptr [rbx+3F50h]
000000018037091E  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180370922  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180370926  F3 0F 10 83 40 3E 00 00     movss   xmm0, dword ptr [rbx+3E40h]
000000018037092E  F3 0F 58 83 70 3C 00 00     addss   xmm0, dword ptr [rbx+3C70h]
0000000180370936  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037093A  F3 0F 10 8B C0 3D 00 00     movss   xmm1, dword ptr [rbx+3DC0h]
0000000180370942  F3 0F 59 83 90 3F 00 00     mulss   xmm0, dword ptr [rbx+3F90h]
000000018037094A  F3 0F 58 8B F0 3C 00 00     addss   xmm1, dword ptr [rbx+3CF0h]
0000000180370952  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180370956  F3 0F 10 83 70 3D 00 00     movss   xmm0, dword ptr [rbx+3D70h]
000000018037095E  F3 0F 58 83 40 3D 00 00     addss   xmm0, dword ptr [rbx+3D40h]
0000000180370966  F3 0F 59 8B A0 3F 00 00     mulss   xmm1, dword ptr [rbx+3FA0h]
000000018037096E  F3 0F 59 83 B0 3F 00 00     mulss   xmm0, dword ptr [rbx+3FB0h]
0000000180370976  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037097A  F3 0F 10 8B F0 3D 00 00     movss   xmm1, dword ptr [rbx+3DF0h]
0000000180370982  F3 0F 58 8B C0 3C 00 00     addss   xmm1, dword ptr [rbx+3CC0h]
000000018037098A  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037098E  F3 0F 10 83 30 3E 00 00     movss   xmm0, dword ptr [rbx+3E30h]
0000000180370996  F3 0F 59 8B C0 3F 00 00     mulss   xmm1, dword ptr [rbx+3FC0h]
000000018037099E  F3 0F 58 83 80 3C 00 00     addss   xmm0, dword ptr [rbx+3C80h]
00000001803709A6  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803709AA  F3 0F 10 8B 00 3D 00 00     movss   xmm1, dword ptr [rbx+3D00h]
00000001803709B2  F3 0F 58 8B B0 3D 00 00     addss   xmm1, dword ptr [rbx+3DB0h]
00000001803709BA  F3 0F 59 83 D0 3F 00 00     mulss   xmm0, dword ptr [rbx+3FD0h]
00000001803709C2  F3 0F 59 8B E0 3F 00 00     mulss   xmm1, dword ptr [rbx+3FE0h]
00000001803709CA  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803709CE  F3 0F 10 83 80 3D 00 00     movss   xmm0, dword ptr [rbx+3D80h]
00000001803709D6  F3 0F 58 83 30 3D 00 00     addss   xmm0, dword ptr [rbx+3D30h]
00000001803709DE  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803709E2  F3 0F 10 8B B0 3C 00 00     movss   xmm1, dword ptr [rbx+3CB0h]
00000001803709EA  F3 0F 59 83 F0 3F 00 00     mulss   xmm0, dword ptr [rbx+3FF0h]
00000001803709F2  F3 0F 58 8B 00 3E 00 00     addss   xmm1, dword ptr [rbx+3E00h]
00000001803709FA  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803709FE  F3 0F 10 83 20 3E 00 00     movss   xmm0, dword ptr [rbx+3E20h]
0000000180370A06  F3 0F 59 8B 00 40 00 00     mulss   xmm1, dword ptr [rbx+4000h]
0000000180370A0E  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180370A12  F3 0F 58 83 90 3C 00 00     addss   xmm0, dword ptr [rbx+3C90h]
0000000180370A1A  F3 0F 10 93 80 3E 00 00     movss   xmm2, dword ptr [rbx+3E80h]
0000000180370A22  F3 0F 10 8B A0 3D 00 00     movss   xmm1, dword ptr [rbx+3DA0h]
0000000180370A2A  0F 28 E2                    movaps  xmm4, xmm2
0000000180370A2D  F3 0F 59 A3 80 41 00 00     mulss   xmm4, dword ptr [rbx+4180h]
0000000180370A35  F3 0F 59 83 10 40 00 00     mulss   xmm0, dword ptr [rbx+4010h]
0000000180370A3D  F3 0F 58 A3 90 3E 00 00     addss   xmm4, dword ptr [rbx+3E90h]
0000000180370A45  F3 0F 58 8B 10 3D 00 00     addss   xmm1, dword ptr [rbx+3D10h]
0000000180370A4D  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180370A51  F3 0F 10 83 90 3D 00 00     movss   xmm0, dword ptr [rbx+3D90h]
0000000180370A59  F3 0F 58 83 20 3D 00 00     addss   xmm0, dword ptr [rbx+3D20h]
0000000180370A61  F3 0F 59 8B 20 40 00 00     mulss   xmm1, dword ptr [rbx+4020h]
0000000180370A69  F3 0F 59 83 30 40 00 00     mulss   xmm0, dword ptr [rbx+4030h]
0000000180370A71  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180370A75  F3 0F 10 8B 10 3E 00 00     movss   xmm1, dword ptr [rbx+3E10h]
0000000180370A7D  F3 0F 58 8B A0 3C 00 00     addss   xmm1, dword ptr [rbx+3CA0h]
0000000180370A85  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180370A89  0F 28 C2                    movaps  xmm0, xmm2
0000000180370A8C  F3 0F 59 8B 40 40 00 00     mulss   xmm1, dword ptr [rbx+4040h]
0000000180370A94  F3 0F 11 A3 80 3E 00 00     movss   dword ptr [rbx+3E80h], xmm4
0000000180370A9C  F3 0F 59 83 90 41 00 00     mulss   xmm0, dword ptr [rbx+4190h]
0000000180370AA4  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180370AA8  F3 0F 58 C4                 addss   xmm0, xmm4
0000000180370AAC  0F 28 DD                    movaps  xmm3, xmm5
0000000180370AAF  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180370AB3  0F 28 C3                    movaps  xmm0, xmm3
0000000180370AB6  F3 0F 59 83 80 41 00 00     mulss   xmm0, dword ptr [rbx+4180h]
0000000180370ABE  F3 0F 58 C2                 addss   xmm0, xmm2
0000000180370AC2  F3 0F 11 83 70 3E 00 00     movss   dword ptr [rbx+3E70h], xmm0
0000000180370ACA  F3 0F 10 93 D0 41 00 00     movss   xmm2, dword ptr [rbx+41D0h]
0000000180370AD2  F3 0F 59 9B 60 3E 00 00     mulss   xmm3, dword ptr [rbx+3E60h]
0000000180370ADA  F3 0F 5C E3                 subss   xmm4, xmm3
0000000180370ADE  F3 0F 59 E2                 mulss   xmm4, xmm2
0000000180370AE2  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180370AE6  F3 0F 5C E2                 subss   xmm4, xmm2
0000000180370AEA  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180370AEE  F3 0F 11 A3 50 3C 00 00     movss   dword ptr [rbx+3C50h], xmm4
0000000180370AF6  F3 0F 11 A3 D0 36 00 00     movss   dword ptr [rbx+36D0h], xmm4
0000000180370AFE  44 0F 2E AB A0 8C 01 00     ucomiss xmm13, dword ptr [rbx+18CA0h]
0000000180370B06  75 28                       jnz     short loc_180370B30
0000000180370B08  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
0000000180370B11  F3 0F 11 83 50 2A 00 00     movss   dword ptr [rbx+2A50h], xmm0
0000000180370B19  C7 83 A0 8C 01 00 00 00 00 00  mov     dword ptr [rbx+18CA0h], 0
0000000180370B23  0F 1F 40 00                 nop     dword ptr [rax+00h]
0000000180370B27  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
0000000180370B30  8B 83 C0 52 00 00           mov     eax, [rbx+52C0h]
0000000180370B36  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
0000000180370B3E  48 8B 0F                    mov     rcx, [rdi]
0000000180370B41  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
0000000180370B46  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
0000000180370B4B  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
0000000180370B50  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
0000000180370B55  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
0000000180370B5A  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
0000000180370B5F  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
0000000180370B64  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
0000000180370B69  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
0000000180370B6F  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
0000000180370B75  89 01                       mov     [rcx], eax
0000000180370B77  8B 83 C0 52 00 00           mov     eax, [rbx+52C0h]
0000000180370B7D  48 8B 4F 08                 mov     rcx, [rdi+8]
0000000180370B81  49 8B 5B 18                 mov     rbx, [r11+18h]
0000000180370B85  89 01                       mov     [rcx], eax
0000000180370B87  49 8B E3                    mov     rsp, r11
0000000180370B8A  5F                          pop     rdi
0000000180370B8B  C3                          retn
