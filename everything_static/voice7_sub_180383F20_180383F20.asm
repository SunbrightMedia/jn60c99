; sub_180383F20 @ 0x180383F20 (RVA 0x383F20) size=0x3D8C

0000000180383F20  48 8B C4                    mov     rax, rsp
0000000180383F23  48 89 58 10                 mov     [rax+10h], rbx
0000000180383F27  57                          push    rdi
0000000180383F28  48 81 EC C0 00 00 00        sub     rsp, 0C0h
0000000180383F2F  F3 0F 10 A1 B0 20 01 00     movss   xmm4, dword ptr [rcx+120B0h]
0000000180383F37  48 8B FA                    mov     rdi, rdx
0000000180383F3A  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
0000000180383F3E  48 8B D9                    mov     rbx, rcx
0000000180383F41  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
0000000180383F45  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
0000000180383F4A  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
0000000180383F4F  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
0000000180383F54  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
0000000180383F59  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
0000000180383F5E  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
0000000180383F64  F3 44 0F 10 2D 47 11 76 00  movss   xmm13, cs:dword_180AE50B4
0000000180383F6D  44 0F 2E A9 60 8D 01 00     ucomiss xmm13, dword ptr [rcx+18D60h]
0000000180383F75  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
0000000180383F7B  45 0F 57 F6                 xorps   xmm14, xmm14
0000000180383F7F  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
0000000180383F89  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
0000000180383F8F  75 16                       jnz     short loc_180383FA7
0000000180383F91  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
0000000180383F9A  0F 57 E4                    xorps   xmm4, xmm4
0000000180383F9D  C7 81 B0 20 01 00 00 00 00 00  mov     dword ptr [rcx+120B0h], 0
0000000180383FA7  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
0000000180383FAF  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
0000000180383FB7  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
0000000180383FBF  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
0000000180383FC7  F3 0F 59 05 F5 6D 60 00     mulss   xmm0, cs:dword_18098ADC4
0000000180383FCF  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
0000000180383FD7  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
0000000180383FDF  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180383FE3  85 D2                       test    edx, edx
0000000180383FE5  75 07                       jnz     short loc_180383FEE
0000000180383FE7  BA 01 00 00 00              mov     edx, 1
0000000180383FEC  EB 24                       jmp     short loc_180384012
0000000180383FEE  8B C2                       mov     eax, edx
0000000180383FF0  25 00 00 20 00              and     eax, 200000h
0000000180383FF5  0F BA E2 17                 bt      edx, 17h
0000000180383FF9  73 08                       jnb     short loc_180384003
0000000180383FFB  85 C0                       test    eax, eax
0000000180383FFD  75 0C                       jnz     short loc_18038400B
0000000180383FFF  03 D2                       add     edx, edx
0000000180384001  EB 0F                       jmp     short loc_180384012
0000000180384003  85 C0                       test    eax, eax
0000000180384005  74 04                       jz      short loc_18038400B
0000000180384007  03 D2                       add     edx, edx
0000000180384009  EB 07                       jmp     short loc_180384012
000000018038400B  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
0000000180384012  F3 0F 10 9B 40 20 01 00     movss   xmm3, dword ptr [rbx+12040h]
000000018038401A  8B C2                       mov     eax, edx
000000018038401C  F3 0F 10 B3 20 20 01 00     movss   xmm6, dword ptr [rbx+12020h]
0000000180384024  25 FF FF FF 00              and     eax, 0FFFFFFh
0000000180384029  F3 44 0F 10 83 E0 20 01 00  movss   xmm8, dword ptr [rbx+120E0h]
0000000180384032  8B CA                       mov     ecx, edx
0000000180384034  F3 0F 10 BB F0 20 01 00     movss   xmm7, dword ptr [rbx+120F0h]
000000018038403C  81 CA 00 00 00 FF           or      edx, 0FF000000h
0000000180384042  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180384046  81 E1 00 00 00 01           and     ecx, 1000000h
000000018038404C  C7 83 20 21 01 00 00 00 00 00  mov     dword ptr [rbx+12120h], 0
0000000180384056  F3 0F 11 9B 50 20 01 00     movss   dword ptr [rbx+12050h], xmm3
000000018038405E  45 0F 57 D2                 xorps   xmm10, xmm10
0000000180384062  0F 44 D0                    cmovz   edx, eax
0000000180384065  F3 0F 11 B3 30 20 01 00     movss   dword ptr [rbx+12030h], xmm6
000000018038406D  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
0000000180384073  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
0000000180384079  8B 83 60 21 01 00           mov     eax, [rbx+12160h]
000000018038407F  66 0F 6E C2                 movd    xmm0, edx
0000000180384083  0F 5B C0                    cvtdq2ps xmm0, xmm0
0000000180384086  89 83 70 21 01 00           mov     [rbx+12170h], eax
000000018038408C  F3 0F 11 A3 D0 20 01 00     movss   dword ptr [rbx+120D0h], xmm4
0000000180384094  F3 0F 59 05 D4 6B 60 00     mulss   xmm0, cs:dword_18098AC70
000000018038409C  F3 44 0F 11 83 00 21 01 00  movss   dword ptr [rbx+12100h], xmm8
00000001803840A5  F3 0F 11 BB 10 21 01 00     movss   dword ptr [rbx+12110h], xmm7
00000001803840AD  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
00000001803840B5  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
00000001803840BD  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
00000001803840C5  F3 0F 59 D0                 mulss   xmm2, xmm0
00000001803840C9  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
00000001803840D1  F3 0F 5C CA                 subss   xmm1, xmm2
00000001803840D5  F3 0F 10 93 80 20 01 00     movss   xmm2, dword ptr [rbx+12080h]
00000001803840DD  F3 0F 11 93 90 20 01 00     movss   dword ptr [rbx+12090h], xmm2
00000001803840E5  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803840E9  F3 0F 10 83 60 20 01 00     movss   xmm0, dword ptr [rbx+12060h]
00000001803840F1  F3 0F 59 D0                 mulss   xmm2, xmm0
00000001803840F5  F3 0F 11 83 70 20 01 00     movss   dword ptr [rbx+12070h], xmm0
00000001803840FD  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180384101  0F 28 C2                    movaps  xmm0, xmm2
0000000180384104  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
000000018038410C  F3 0F 10 8B A0 20 01 00     movss   xmm1, dword ptr [rbx+120A0h]
0000000180384114  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180384118  F3 0F 59 F2                 mulss   xmm6, xmm2
000000018038411C  F3 0F 11 8B C0 20 01 00     movss   dword ptr [rbx+120C0h], xmm1
0000000180384124  F3 0F 11 93 30 21 01 00     movss   dword ptr [rbx+12130h], xmm2
000000018038412C  F3 0F 5C F0                 subss   xmm6, xmm0
0000000180384130  0F 28 C4                    movaps  xmm0, xmm4
0000000180384133  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180384137  F3 0F 5C D8                 subss   xmm3, xmm0
000000018038413B  F3 0F 58 F1                 addss   xmm6, xmm1
000000018038413F  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180384143  F3 0F 11 B3 40 21 01 00     movss   dword ptr [rbx+12140h], xmm6
000000018038414B  F3 0F 11 9B 50 21 01 00     movss   dword ptr [rbx+12150h], xmm3
0000000180384153  0F 28 CB                    movaps  xmm1, xmm3
0000000180384156  F3 0F 58 9B 90 21 01 00     addss   xmm3, dword ptr [rbx+12190h]
000000018038415E  41 0F 2F DE                 comiss  xmm3, xmm14
0000000180384162  72 05                       jb      short loc_180384169
0000000180384164  0F 57 C0                    xorps   xmm0, xmm0
0000000180384167  EB 03                       jmp     short loc_18038416C
0000000180384169  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018038416C  41 0F 2E CE                 ucomiss xmm1, xmm14
0000000180384170  F3 44 0F 10 3D 6B 13 76 00  movss   xmm15, cs:dword_180AE54E4
0000000180384179  75 06                       jnz     short loc_180384181
000000018038417B  41 0F 28 EF                 movaps  xmm5, xmm15
000000018038417F  EB 04                       jmp     short loc_180384185
0000000180384181  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
0000000180384185  41 0F 2F EE                 comiss  xmm5, xmm14
0000000180384189  F3 0F 11 AB 60 21 01 00     movss   dword ptr [rbx+12160h], xmm5
0000000180384191  73 06                       jnb     short loc_180384199
0000000180384193  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180384197  EB 06                       jmp     short loc_18038419F
0000000180384199  76 04                       jbe     short loc_18038419F
000000018038419B  41 0F 28 ED                 movaps  xmm5, xmm13
000000018038419F  F3 0F 10 83 D0 21 01 00     movss   xmm0, dword ptr [rbx+121D0h]
00000001803841A7  F3 41 0F 58 ED              addss   xmm5, xmm13
00000001803841AC  F3 0F 10 93 70 22 01 00     movss   xmm2, dword ptr [rbx+12270h]
00000001803841B4  F3 0F 10 8B E0 21 01 00     movss   xmm1, dword ptr [rbx+121E0h]
00000001803841BC  8B 83 A0 21 01 00           mov     eax, [rbx+121A0h]
00000001803841C2  0F 28 D9                    movaps  xmm3, xmm1
00000001803841C5  F3 0F 10 A3 30 22 01 00     movss   xmm4, dword ptr [rbx+12230h]
00000001803841CD  F3 0F 58 9B 80 22 01 00     addss   xmm3, dword ptr [rbx+12280h]
00000001803841D5  F2 44 0F 10 25 C2 0F 76 00  movsd   xmm12, cs:dbl_180AE51A0
00000001803841DE  F3 0F 11 AB 80 21 01 00     movss   dword ptr [rbx+12180h], xmm5
00000001803841E6  F3 0F 11 AB A0 21 01 00     movss   dword ptr [rbx+121A0h], xmm5
00000001803841EE  F3 0F 59 E8                 mulss   xmm5, xmm0
00000001803841F2  89 83 B0 21 01 00           mov     [rbx+121B0h], eax
00000001803841F8  F3 0F 11 A3 40 22 01 00     movss   dword ptr [rbx+12240h], xmm4
0000000180384200  F3 0F 5C E8                 subss   xmm5, xmm0
0000000180384204  0F 28 C2                    movaps  xmm0, xmm2
0000000180384207  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018038420B  F3 0F 10 8B 10 22 01 00     movss   xmm1, dword ptr [rbx+12210h]
0000000180384213  F3 0F 58 83 90 22 01 00     addss   xmm0, dword ptr [rbx+12290h]
000000018038421B  F3 41 0F 58 ED              addss   xmm5, xmm13
0000000180384220  F3 0F 5E C8                 divss   xmm1, xmm0
0000000180384224  F3 0F 10 83 A0 22 01 00     movss   xmm0, dword ptr [rbx+122A0h]
000000018038422C  F3 0F 59 AB C0 21 01 00     mulss   xmm5, dword ptr [rbx+121C0h]
0000000180384234  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180384238  F3 0F 10 93 00 22 01 00     movss   xmm2, dword ptr [rbx+12200h]
0000000180384240  F3 0F 11 AB 50 22 01 00     movss   dword ptr [rbx+12250h], xmm5
0000000180384248  F3 0F 5C D1                 subss   xmm2, xmm1
000000018038424C  F3 0F 10 8B 20 22 01 00     movss   xmm1, dword ptr [rbx+12220h]
0000000180384254  F3 0F 58 D6                 addss   xmm2, xmm6
0000000180384258  F3 0F 5C D4                 subss   xmm2, xmm4
000000018038425C  F3 0F 11 93 00 22 01 00     movss   dword ptr [rbx+12200h], xmm2
0000000180384264  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180384268  F3 0F 11 93 10 22 01 00     movss   dword ptr [rbx+12210h], xmm2
0000000180384270  F3 0F 58 D4                 addss   xmm2, xmm4
0000000180384274  F3 0F 5C E6                 subss   xmm4, xmm6
0000000180384278  0F 54 25 11 15 76 00        andps   xmm4, cs:xmmword_180AE5790
000000018038427F  F3 0F 5C C4                 subss   xmm0, xmm4
0000000180384283  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180384287  0F 83 E8 00 00 00           jnb     loc_180384375
000000018038428D  0F 57 C9                    xorps   xmm1, xmm1
0000000180384290  0F 5A C1                    cvtps2pd xmm0, xmm1
0000000180384293  41 0F 2E EE                 ucomiss xmm5, xmm14
0000000180384297  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018038429B  0F 28 C8                    movaps  xmm1, xmm0
000000018038429E  F3 0F 11 83 20 22 01 00     movss   dword ptr [rbx+12220h], xmm0
00000001803842A6  F3 0F 59 CE                 mulss   xmm1, xmm6
00000001803842AA  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803842AE  F3 0F 5C C8                 subss   xmm1, xmm0
00000001803842B2  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803842B6  75 03                       jnz     short loc_1803842BB
00000001803842B8  0F 28 CE                    movaps  xmm1, xmm6
00000001803842BB  8B 83 E0 22 01 00           mov     eax, [rbx+122E0h]
00000001803842C1  48 8D 0D 38 BD C7 FF        lea     rcx, cs:180000000h
00000001803842C8  F3 0F 59 BB D0 22 01 00     mulss   xmm7, dword ptr [rbx+122D0h]
00000001803842D0  89 83 F0 22 01 00           mov     [rbx+122F0h], eax
00000001803842D6  F3 44 0F 59 83 C0 22 01 00  mulss   xmm8, dword ptr [rbx+122C0h]
00000001803842DF  F3 0F 10 83 00 24 01 00     movss   xmm0, dword ptr [rbx+12400h]
00000001803842E7  F3 0F 10 93 00 23 01 00     movss   xmm2, dword ptr [rbx+12300h]
00000001803842EF  F3 44 0F 10 8B 60 23 01 00  movss   xmm9, dword ptr [rbx+12360h]
00000001803842F8  F3 41 0F 58 F8              addss   xmm7, xmm8
00000001803842FD  F3 44 0F 10 83 40 23 01 00  movss   xmm8, dword ptr [rbx+12340h]
0000000180384306  F3 0F 2C C0                 cvttss2si eax, xmm0
000000018038430A  F3 0F 11 BB E0 22 01 00     movss   dword ptr [rbx+122E0h], xmm7
0000000180384312  F3 0F 10 BB 20 23 01 00     movss   xmm7, dword ptr [rbx+12320h]
000000018038431A  F3 0F 11 8B 30 22 01 00     movss   dword ptr [rbx+12230h], xmm1
0000000180384322  F3 0F 11 8B 60 22 01 00     movss   dword ptr [rbx+12260h], xmm1
000000018038432A  F3 0F 10 8B C0 23 01 00     movss   xmm1, dword ptr [rbx+123C0h]
0000000180384332  F3 0F 11 BB 30 23 01 00     movss   dword ptr [rbx+12330h], xmm7
000000018038433A  F3 0F 11 93 10 23 01 00     movss   dword ptr [rbx+12310h], xmm2
0000000180384342  F3 44 0F 11 83 50 23 01 00  movss   dword ptr [rbx+12350h], xmm8
000000018038434B  F3 44 0F 11 8B 70 23 01 00  movss   dword ptr [rbx+12370h], xmm9
0000000180384354  F3 0F 11 8B D0 23 01 00     movss   dword ptr [rbx+123D0h], xmm1
000000018038435C  83 F8 E0                    cmp     eax, 0FFFFFFE0h
000000018038435F  7D 2F                       jge     short loc_180384390
0000000180384361  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
0000000180384366  F7 D0                       not     eax
0000000180384368  48 98                       cdqe
000000018038436A  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
0000000180384373  EB 47                       jmp     short loc_1803843BC
0000000180384375  F3 0F 58 8B B0 22 01 00     addss   xmm1, dword ptr [rbx+122B0h]
000000018038437D  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180384381  0F 82 09 FF FF FF           jb      loc_180384290
0000000180384387  41 0F 28 C4                 movaps  xmm0, xmm12
000000018038438B  E9 03 FF FF FF              jmp     loc_180384293
0000000180384390  83 F8 20                    cmp     eax, 20h ; ' '
0000000180384393  7E 07                       jle     short loc_18038439C
0000000180384395  B8 20 00 00 00              mov     eax, 20h ; ' '
000000018038439A  EB 15                       jmp     short loc_1803843B1
000000018038439C  85 C0                       test    eax, eax
000000018038439E  79 0F                       jns     short loc_1803843AF
00000001803843A0  F7 D0                       not     eax
00000001803843A2  48 98                       cdqe
00000001803843A4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
00000001803843AD  EB 0D                       jmp     short loc_1803843BC
00000001803843AF  7E 0B                       jle     short loc_1803843BC
00000001803843B1  48 98                       cdqe
00000001803843B3  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
00000001803843BC  0F 57 05 FD 13 76 00        xorps   xmm0, cs:xmmword_180AE57C0
00000001803843C3  F3 0F 2C C0                 cvttss2si eax, xmm0
00000001803843C7  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00000001803843CA  7D 14                       jge     short loc_1803843E0
00000001803843CC  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00000001803843D1  F7 D0                       not     eax
00000001803843D3  48 98                       cdqe
00000001803843D5  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
00000001803843DE  EB 2C                       jmp     short loc_18038440C
00000001803843E0  83 F8 20                    cmp     eax, 20h ; ' '
00000001803843E3  7E 07                       jle     short loc_1803843EC
00000001803843E5  B8 20 00 00 00              mov     eax, 20h ; ' '
00000001803843EA  EB 15                       jmp     short loc_180384401
00000001803843EC  85 C0                       test    eax, eax
00000001803843EE  79 0F                       jns     short loc_1803843FF
00000001803843F0  F7 D0                       not     eax
00000001803843F2  48 98                       cdqe
00000001803843F4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
00000001803843FD  EB 0D                       jmp     short loc_18038440C
00000001803843FF  7E 0B                       jle     short loc_18038440C
0000000180384401  48 98                       cdqe
0000000180384403  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
000000018038440C  F3 0F 10 83 80 23 01 00     movss   xmm0, dword ptr [rbx+12380h]
0000000180384414  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180384418  F3 0F 59 93 F0 23 01 00     mulss   xmm2, dword ptr [rbx+123F0h]
0000000180384420  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180384424  F3 0F 10 8B B0 23 01 00     movss   xmm1, dword ptr [rbx+123B0h]
000000018038442C  F3 0F 11 93 C0 23 01 00     movss   dword ptr [rbx+123C0h], xmm2
0000000180384434  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180384438  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018038443C  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180384440  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180384444  41 0F 2F D6                 comiss  xmm2, xmm14
0000000180384448  76 05                       jbe     short loc_18038444F
000000018038444A  0F 5A C2                    cvtps2pd xmm0, xmm2
000000018038444D  EB 03                       jmp     short loc_180384452
000000018038444F  0F 57 C0                    xorps   xmm0, xmm0
0000000180384452  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
0000000180384456  41 0F 2F CD                 comiss  xmm1, xmm13
000000018038445A  72 06                       jb      short loc_180384462
000000018038445C  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180384460  EB 03                       jmp     short loc_180384465
0000000180384462  0F 5A C1                    cvtps2pd xmm0, xmm1
0000000180384465  F3 0F 10 B3 90 23 01 00     movss   xmm6, dword ptr [rbx+12390h]
000000018038446D  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180384471  F3 0F 59 83 20 24 01 00     mulss   xmm0, dword ptr [rbx+12420h]; X
0000000180384479  E8 C2 B2 36 00              call    expf
000000018038447E  F3 0F 59 83 10 24 01 00     mulss   xmm0, dword ptr [rbx+12410h]
0000000180384486  0F 28 CE                    movaps  xmm1, xmm6
0000000180384489  8B 83 90 25 01 00           mov     eax, [rbx+12590h]
000000018038448F  F3 0F 59 8B A0 23 01 00     mulss   xmm1, dword ptr [rbx+123A0h]
0000000180384497  89 83 A0 25 01 00           mov     [rbx+125A0h], eax
000000018038449D  F3 0F 58 83 30 24 01 00     addss   xmm0, dword ptr [rbx+12430h]
00000001803844A5  8B 83 B0 25 01 00           mov     eax, [rbx+125B0h]
00000001803844AB  F3 0F 10 9B 50 25 01 00     movss   xmm3, dword ptr [rbx+12550h]
00000001803844B3  F3 0F 59 BB E0 26 01 00     mulss   xmm7, dword ptr [rbx+126E0h]
00000001803844BB  89 83 C0 25 01 00           mov     [rbx+125C0h], eax
00000001803844C1  8B 83 D0 25 01 00           mov     eax, [rbx+125D0h]
00000001803844C7  F3 0F 10 93 40 25 01 00     movss   xmm2, dword ptr [rbx+12540h]
00000001803844CF  F3 0F 10 A3 70 25 01 00     movss   xmm4, dword ptr [rbx+12570h]
00000001803844D7  F3 0F 59 F0                 mulss   xmm6, xmm0
00000001803844DB  89 83 E0 25 01 00           mov     [rbx+125E0h], eax
00000001803844E1  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
00000001803844E7  F3 0F 11 9B 60 25 01 00     movss   dword ptr [rbx+12560h], xmm3
00000001803844EF  F3 0F 5C CE                 subss   xmm1, xmm6
00000001803844F3  F3 0F 11 93 50 25 01 00     movss   dword ptr [rbx+12550h], xmm2
00000001803844FB  F3 0F 11 A3 80 25 01 00     movss   dword ptr [rbx+12580h], xmm4
0000000180384503  F3 44 0F 11 83 10 25 01 00  movss   dword ptr [rbx+12510h], xmm8
000000018038450C  F3 44 0F 11 8B 20 25 01 00  movss   dword ptr [rbx+12520h], xmm9
0000000180384515  89 83 00 25 01 00           mov     [rbx+12500h], eax
000000018038451B  F3 0F 58 C8                 addss   xmm1, xmm0
000000018038451F  F3 0F 10 83 B0 26 01 00     movss   xmm0, dword ptr [rbx+126B0h]
0000000180384527  F3 0F 58 F8                 addss   xmm7, xmm0
000000018038452B  F3 0F 11 83 A0 26 01 00     movss   dword ptr [rbx+126A0h], xmm0
0000000180384533  F3 0F 11 8B E0 23 01 00     movss   dword ptr [rbx+123E0h], xmm1
000000018038453B  41 0F 2F FF                 comiss  xmm7, xmm15
000000018038453F  73 06                       jnb     short loc_180384547
0000000180384541  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180384545  EB 05                       jmp     short loc_18038454C
0000000180384547  F3 41 0F 5D FD              minss   xmm7, xmm13
000000018038454C  F3 0F 59 0D 6C 68 60 00     mulss   xmm1, cs:dword_18098ADC0
0000000180384554  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180384558  F3 0F 10 B3 C0 27 01 00     movss   xmm6, dword ptr [rbx+127C0h]
0000000180384560  F3 0F 5C C3                 subss   xmm0, xmm3
0000000180384564  F3 0F 11 BB 40 25 01 00     movss   dword ptr [rbx+12540h], xmm7
000000018038456C  F3 0F 5D F1                 minss   xmm6, xmm1
0000000180384570  F3 0F 59 83 F0 26 01 00     mulss   xmm0, dword ptr [rbx+126F0h]
0000000180384578  F3 0F 58 C3                 addss   xmm0, xmm3
000000018038457C  41 0F 2F C7                 comiss  xmm0, xmm15
0000000180384580  73 06                       jnb     short loc_180384588
0000000180384582  41 0F 28 C7                 movaps  xmm0, xmm15
0000000180384586  EB 05                       jmp     short loc_18038458D
0000000180384588  F3 41 0F 5D C5              minss   xmm0, xmm13
000000018038458D  F3 0F 59 B3 D0 27 01 00     mulss   xmm6, dword ptr [rbx+127D0h]
0000000180384595  F3 0F 5C D7                 subss   xmm2, xmm7
0000000180384599  F3 0F 11 B3 F0 25 01 00     movss   dword ptr [rbx+125F0h], xmm6
00000001803845A1  F3 0F 58 F4                 addss   xmm6, xmm4
00000001803845A5  41 0F 2F D6                 comiss  xmm2, xmm14
00000001803845A9  73 03                       jnb     short loc_1803845AE
00000001803845AB  0F 57 C0                    xorps   xmm0, xmm0
00000001803845AE  F3 0F 10 8B C0 26 01 00     movss   xmm1, dword ptr [rbx+126C0h]
00000001803845B6  F3 44 0F 10 9B 00 25 01 00  movss   xmm11, dword ptr [rbx+12500h]
00000001803845BF  F3 0F 11 83 50 25 01 00     movss   dword ptr [rbx+12550h], xmm0
00000001803845C7  F3 0F 58 83 50 28 01 00     addss   xmm0, dword ptr [rbx+12850h]
00000001803845CF  72 04                       jb      short loc_1803845D5
00000001803845D1  41 0F 28 CD                 movaps  xmm1, xmm13
00000001803845D5  F3 0F 59 83 40 28 01 00     mulss   xmm0, dword ptr [rbx+12840h]
00000001803845DD  41 0F 28 FB                 movaps  xmm7, xmm11
00000001803845E1  F3 0F 10 93 A0 25 01 00     movss   xmm2, dword ptr [rbx+125A0h]
00000001803845E9  F3 0F 59 F1                 mulss   xmm6, xmm1
00000001803845ED  F3 0F 5C FA                 subss   xmm7, xmm2
00000001803845F1  41 0F 2F C6                 comiss  xmm0, xmm14
00000001803845F5  F3 0F 59 B3 D0 26 01 00     mulss   xmm6, dword ptr [rbx+126D0h]
00000001803845FD  76 05                       jbe     short loc_180384604
00000001803845FF  0F 5A C8                    cvtps2pd xmm1, xmm0
0000000180384602  EB 03                       jmp     short loc_180384607
0000000180384604  0F 57 C9                    xorps   xmm1, xmm1
0000000180384607  41 0F 2F F5                 comiss  xmm6, xmm13
000000018038460B  F3 0F 59 BB 10 29 01 00     mulss   xmm7, dword ptr [rbx+12910h]
0000000180384613  F3 44 0F 10 0D CC 0B 76 00  movss   xmm9, cs:flt_180AE51E8
000000018038461C  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
0000000180384620  F3 0F 58 FA                 addss   xmm7, xmm2
0000000180384624  F3 0F 11 BB 90 25 01 00     movss   dword ptr [rbx+12590h], xmm7
000000018038462C  F3 0F 11 83 30 25 01 00     movss   dword ptr [rbx+12530h], xmm0
0000000180384634  41 0F 28 C3                 movaps  xmm0, xmm11
0000000180384638  F3 0F 59 BB 00 29 01 00     mulss   xmm7, dword ptr [rbx+12900h]
0000000180384640  F3 0F 10 8B 80 27 01 00     movss   xmm1, dword ptr [rbx+12780h]
0000000180384648  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018038464C  F3 0F 59 F9                 mulss   xmm7, xmm1
0000000180384650  F3 0F 5C F8                 subss   xmm7, xmm0
0000000180384654  F3 0F 10 83 80 25 01 00     movss   xmm0, dword ptr [rbx+12580h]
000000018038465C  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
0000000180384665  F3 41 0F 58 FB              addss   xmm7, xmm11
000000018038466A  76 1B                       jbe     short loc_180384687
000000018038466C  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180384671  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180384675  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180384678  E8 5B AE 36 00              call    fmodf
000000018038467D  0F 28 F0                    movaps  xmm6, xmm0
0000000180384680  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180384685  EB 1F                       jmp     short loc_1803846A6
0000000180384687  41 0F 2F F7                 comiss  xmm6, xmm15
000000018038468B  73 19                       jnb     short loc_1803846A6
000000018038468D  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180384692  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180384696  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180384699  E8 3A AE 36 00              call    fmodf
000000018038469E  0F 28 F0                    movaps  xmm6, xmm0
00000001803846A1  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803846A6  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
00000001803846AF  0F 28 C6                    movaps  xmm0, xmm6
00000001803846B2  41 0F 2F CE                 comiss  xmm1, xmm14
00000001803846B6  F3 44 0F 10 83 C0 25 01 00  movss   xmm8, dword ptr [rbx+125C0h]
00000001803846BF  F3 0F 11 B3 70 25 01 00     movss   dword ptr [rbx+12570h], xmm6
00000001803846C7  F3 0F 59 BB F0 28 01 00     mulss   xmm7, dword ptr [rbx+128F0h]
00000001803846CF  F3 0F 58 83 60 28 01 00     addss   xmm0, dword ptr [rbx+12860h]
00000001803846D7  F3 0F 11 BB F0 24 01 00     movss   dword ptr [rbx+124F0h], xmm7
00000001803846DF  73 0A                       jnb     short loc_1803846EB
00000001803846E1  41 0F 2F F6                 comiss  xmm6, xmm14
00000001803846E5  76 04                       jbe     short loc_1803846EB
00000001803846E7  45 0F 28 C3                 movaps  xmm8, xmm11
00000001803846EB  41 0F 2F C5                 comiss  xmm0, xmm13
00000001803846EF  76 15                       jbe     short loc_180384706
00000001803846F1  F3 41 0F 58 C5              addss   xmm0, xmm13; X
00000001803846F6  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803846FA  E8 D9 AD 36 00              call    fmodf
00000001803846FF  F3 41 0F 5C C5              subss   xmm0, xmm13
0000000180384704  EB 19                       jmp     short loc_18038471F
0000000180384706  41 0F 2F C7                 comiss  xmm0, xmm15
000000018038470A  73 13                       jnb     short loc_18038471F
000000018038470C  F3 41 0F 5C C5              subss   xmm0, xmm13; X
0000000180384711  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180384715  E8 BE AD 36 00              call    fmodf
000000018038471A  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018038471F  F3 44 0F 10 1D 98 10 76 00  movss   xmm11, dword ptr cs:xmmword_180AE57C0
0000000180384728  F3 44 0F 11 83 B0 25 01 00  movss   dword ptr [rbx+125B0h], xmm8
0000000180384731  F3 0F 59 83 A0 28 01 00     mulss   xmm0, dword ptr [rbx+128A0h]
0000000180384739  F3 44 0F 59 83 E0 28 01 00  mulss   xmm8, dword ptr [rbx+128E0h]
0000000180384742  F3 0F 58 83 20 29 01 00     addss   xmm0, dword ptr [rbx+12920h]
000000018038474A  F3 0F 11 83 00 26 01 00     movss   dword ptr [rbx+12600h], xmm0
0000000180384752  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180384756  F3 44 0F 11 83 50 26 01 00  movss   dword ptr [rbx+12650h], xmm8
000000018038475F  44 0F 28 C6                 movaps  xmm8, xmm6
0000000180384763  F3 44 0F 58 83 80 28 01 00  addss   xmm8, dword ptr [rbx+12880h]
000000018038476C  F3 0F 11 83 10 26 01 00     movss   dword ptr [rbx+12610h], xmm0
0000000180384774  45 0F 2F C5                 comiss  xmm8, xmm13
0000000180384778  76 1D                       jbe     short loc_180384797
000000018038477A  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018038477F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180384783  41 0F 28 C0                 movaps  xmm0, xmm8; X
0000000180384787  E8 4C AD 36 00              call    fmodf
000000018038478C  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180384790  F3 45 0F 5C C5              subss   xmm8, xmm13
0000000180384795  EB 21                       jmp     short loc_1803847B8
0000000180384797  45 0F 2F C7                 comiss  xmm8, xmm15
000000018038479B  73 1B                       jnb     short loc_1803847B8
000000018038479D  F3 45 0F 5C C5              subss   xmm8, xmm13
00000001803847A2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803847A6  41 0F 28 C0                 movaps  xmm0, xmm8; X
00000001803847AA  E8 29 AD 36 00              call    fmodf
00000001803847AF  44 0F 28 C0                 movaps  xmm8, xmm0
00000001803847B3  F3 45 0F 58 C5              addss   xmm8, xmm13
00000001803847B8  0F 28 FE                    movaps  xmm7, xmm6
00000001803847BB  F3 0F 58 BB 70 28 01 00     addss   xmm7, dword ptr [rbx+12870h]
00000001803847C3  41 0F 2F FD                 comiss  xmm7, xmm13
00000001803847C7  76 1B                       jbe     short loc_1803847E4
00000001803847C9  F3 41 0F 58 FD              addss   xmm7, xmm13
00000001803847CE  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803847D2  0F 28 C7                    movaps  xmm0, xmm7; X
00000001803847D5  E8 FE AC 36 00              call    fmodf
00000001803847DA  0F 28 F8                    movaps  xmm7, xmm0
00000001803847DD  F3 41 0F 5C FD              subss   xmm7, xmm13
00000001803847E2  EB 1F                       jmp     short loc_180384803
00000001803847E4  41 0F 2F FF                 comiss  xmm7, xmm15
00000001803847E8  73 19                       jnb     short loc_180384803
00000001803847EA  F3 41 0F 5C FD              subss   xmm7, xmm13
00000001803847EF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803847F3  0F 28 C7                    movaps  xmm0, xmm7; X
00000001803847F6  E8 DD AC 36 00              call    fmodf
00000001803847FB  0F 28 F8                    movaps  xmm7, xmm0
00000001803847FE  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180384803  41 0F 28 C0                 movaps  xmm0, xmm8
0000000180384807  E8 B4 47 FE FF              call    sub_180368FC0
000000018038480C  F3 0F 58 BB 30 29 01 00     addss   xmm7, dword ptr [rbx+12930h]
0000000180384814  F3 0F 59 83 C0 28 01 00     mulss   xmm0, dword ptr [rbx+128C0h]
000000018038481C  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180384820  73 06                       jnb     short loc_180384828
0000000180384822  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180384826  EB 06                       jmp     short loc_18038482E
0000000180384828  76 04                       jbe     short loc_18038482E
000000018038482A  41 0F 28 FD                 movaps  xmm7, xmm13
000000018038482E  F3 0F 58 B3 90 28 01 00     addss   xmm6, dword ptr [rbx+12890h]
0000000180384836  F3 0F 11 83 30 26 01 00     movss   dword ptr [rbx+12630h], xmm0
000000018038483E  F3 0F 11 BB 90 26 01 00     movss   dword ptr [rbx+12690h], xmm7
0000000180384846  F3 0F 59 BB B0 28 01 00     mulss   xmm7, dword ptr [rbx+128B0h]
000000018038484E  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180384852  F3 0F 58 BB 40 29 01 00     addss   xmm7, dword ptr [rbx+12940h]
000000018038485A  76 1B                       jbe     short loc_180384877
000000018038485C  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180384861  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180384865  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180384868  E8 6B AC 36 00              call    fmodf
000000018038486D  0F 28 F0                    movaps  xmm6, xmm0
0000000180384870  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180384875  EB 1F                       jmp     short loc_180384896
0000000180384877  41 0F 2F F7                 comiss  xmm6, xmm15
000000018038487B  73 19                       jnb     short loc_180384896
000000018038487D  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180384882  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180384886  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180384889  E8 4A AC 36 00              call    fmodf
000000018038488E  0F 28 F0                    movaps  xmm6, xmm0
0000000180384891  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180384896  0F 54 35 F3 0E 76 00        andps   xmm6, cs:xmmword_180AE5790
000000018038489D  F3 0F 11 BB 20 26 01 00     movss   dword ptr [rbx+12620h], xmm7
00000001803848A5  0F 28 E6                    movaps  xmm4, xmm6
00000001803848A8  F3 0F 10 9B 60 27 01 00     movss   xmm3, dword ptr [rbx+12760h]
00000001803848B0  0F 28 D6                    movaps  xmm2, xmm6
00000001803848B3  F3 0F 59 93 F0 27 01 00     mulss   xmm2, dword ptr [rbx+127F0h]
00000001803848BB  F3 0F 59 9B 50 26 01 00     mulss   xmm3, dword ptr [rbx+12650h]
00000001803848C3  F3 0F 58 93 E0 27 01 00     addss   xmm2, dword ptr [rbx+127E0h]
00000001803848CB  F3 0F 10 8B 50 27 01 00     movss   xmm1, dword ptr [rbx+12750h]
00000001803848D3  F3 0F 59 8B 10 26 01 00     mulss   xmm1, dword ptr [rbx+12610h]
00000001803848DB  F3 0F 59 E6                 mulss   xmm4, xmm6
00000001803848DF  0F 28 C4                    movaps  xmm0, xmm4
00000001803848E2  F3 0F 59 E6                 mulss   xmm4, xmm6
00000001803848E6  F3 0F 59 83 00 28 01 00     mulss   xmm0, dword ptr [rbx+12800h]
00000001803848EE  F3 0F 59 F4                 mulss   xmm6, xmm4
00000001803848F2  F3 0F 59 A3 10 28 01 00     mulss   xmm4, dword ptr [rbx+12810h]
00000001803848FA  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803848FE  F3 0F 59 B3 20 28 01 00     mulss   xmm6, dword ptr [rbx+12820h]
0000000180384906  F3 0F 10 83 40 27 01 00     movss   xmm0, dword ptr [rbx+12740h]
000000018038490E  F3 0F 59 83 00 26 01 00     mulss   xmm0, dword ptr [rbx+12600h]
0000000180384916  F3 0F 58 E2                 addss   xmm4, xmm2
000000018038491A  F3 0F 58 D8                 addss   xmm3, xmm0
000000018038491E  F3 0F 58 F4                 addss   xmm6, xmm4
0000000180384922  F3 0F 10 A3 20 27 01 00     movss   xmm4, dword ptr [rbx+12720h]
000000018038492A  F3 0F 58 D9                 addss   xmm3, xmm1
000000018038492E  F3 0F 58 B3 30 28 01 00     addss   xmm6, dword ptr [rbx+12830h]
0000000180384936  F3 0F 59 B3 D0 28 01 00     mulss   xmm6, dword ptr [rbx+128D0h]
000000018038493E  F3 0F 11 B3 40 26 01 00     movss   dword ptr [rbx+12640h], xmm6
0000000180384946  F3 0F 59 A3 30 26 01 00     mulss   xmm4, dword ptr [rbx+12630h]
000000018038494E  F3 0F 10 8B 00 27 01 00     movss   xmm1, dword ptr [rbx+12700h]
0000000180384956  F3 0F 10 83 30 27 01 00     movss   xmm0, dword ptr [rbx+12730h]
000000018038495E  F3 0F 59 83 20 26 01 00     mulss   xmm0, dword ptr [rbx+12620h]
0000000180384966  F3 0F 58 E3                 addss   xmm4, xmm3
000000018038496A  F3 0F 10 93 90 27 01 00     movss   xmm2, dword ptr [rbx+12790h]
0000000180384972  0F 28 D9                    movaps  xmm3, xmm1
0000000180384975  F3 0F 59 9B 30 25 01 00     mulss   xmm3, dword ptr [rbx+12530h]
000000018038497D  F3 0F 59 B3 10 27 01 00     mulss   xmm6, dword ptr [rbx+12710h]
0000000180384985  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180384989  F3 0F 10 83 70 27 01 00     movss   xmm0, dword ptr [rbx+12770h]
0000000180384991  F3 0F 5C D9                 subss   xmm3, xmm1
0000000180384995  F3 0F 59 83 F0 24 01 00     mulss   xmm0, dword ptr [rbx+124F0h]
000000018038499D  F3 0F 58 E6                 addss   xmm4, xmm6
00000001803849A1  F3 41 0F 58 DD              addss   xmm3, xmm13
00000001803849A6  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803849AA  F3 0F 11 9B 60 26 01 00     movss   dword ptr [rbx+12660h], xmm3
00000001803849B2  F3 0F 59 D3                 mulss   xmm2, xmm3
00000001803849B6  F3 0F 11 A3 80 26 01 00     movss   dword ptr [rbx+12680h], xmm4
00000001803849BE  F3 0F 10 8B A0 27 01 00     movss   xmm1, dword ptr [rbx+127A0h]
00000001803849C6  F3 0F 59 8B 10 25 01 00     mulss   xmm1, dword ptr [rbx+12510h]
00000001803849CE  F3 0F 10 83 B0 27 01 00     movss   xmm0, dword ptr [rbx+127B0h]
00000001803849D6  F3 0F 59 83 20 25 01 00     mulss   xmm0, dword ptr [rbx+12520h]
00000001803849DE  F3 0F 59 D4                 mulss   xmm2, xmm4
00000001803849E2  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803849E6  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803849EA  F3 0F 11 8B 70 26 01 00     movss   dword ptr [rbx+12670h], xmm1
00000001803849F2  F3 0F 10 83 80 26 01 00     movss   xmm0, dword ptr [rbx+12680h]
00000001803849FA  8B 83 90 26 01 00           mov     eax, [rbx+12690h]
0000000180384A00  89 83 50 29 01 00           mov     [rbx+12950h], eax
0000000180384A06  F3 0F 11 83 60 29 01 00     movss   dword ptr [rbx+12960h], xmm0
0000000180384A0E  44 0F 2F B3 90 26 01 00     comiss  xmm14, dword ptr [rbx+12690h]
0000000180384A16  F3 0F 10 8B A0 21 01 00     movss   xmm1, dword ptr [rbx+121A0h]
0000000180384A1E  F3 0F 10 93 70 29 01 00     movss   xmm2, dword ptr [rbx+12970h]
0000000180384A26  73 06                       jnb     short loc_180384A2E
0000000180384A28  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180384A2C  EB 03                       jmp     short loc_180384A31
0000000180384A2E  0F 57 C0                    xorps   xmm0, xmm0
0000000180384A31  41 0F 2E D6                 ucomiss xmm2, xmm14
0000000180384A35  75 04                       jnz     short loc_180384A3B
0000000180384A37  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180384A3B  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180384A3F  F3 0F 11 8B 80 29 01 00     movss   dword ptr [rbx+12980h], xmm1
0000000180384A47  8B 83 90 29 01 00           mov     eax, [rbx+12990h]
0000000180384A4D  89 83 A0 29 01 00           mov     [rbx+129A0h], eax
0000000180384A53  8B 83 C0 29 01 00           mov     eax, [rbx+129C0h]
0000000180384A59  89 83 D0 29 01 00           mov     [rbx+129D0h], eax
0000000180384A5F  8B 83 B0 29 01 00           mov     eax, [rbx+129B0h]
0000000180384A65  89 83 C0 29 01 00           mov     [rbx+129C0h], eax
0000000180384A6B  8B 83 E0 29 01 00           mov     eax, [rbx+129E0h]
0000000180384A71  89 83 F0 29 01 00           mov     [rbx+129F0h], eax
0000000180384A77  8B 83 10 2A 01 00           mov     eax, [rbx+12A10h]
0000000180384A7D  89 83 20 2A 01 00           mov     [rbx+12A20h], eax
0000000180384A83  F3 0F 10 83 C0 2A 01 00     movss   xmm0, dword ptr [rbx+12AC0h]
0000000180384A8B  F3 0F 58 8B A0 2A 01 00     addss   xmm1, dword ptr [rbx+12AA0h]
0000000180384A93  F3 0F 59 83 D0 29 01 00     mulss   xmm0, dword ptr [rbx+129D0h]
0000000180384A9B  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180384A9F  F3 0F 58 83 A0 29 01 00     addss   xmm0, dword ptr [rbx+129A0h]
0000000180384AA7  73 06                       jnb     short loc_180384AAF
0000000180384AA9  45 0F 28 C5                 movaps  xmm8, xmm13
0000000180384AAD  EB 04                       jmp     short loc_180384AB3
0000000180384AAF  45 0F 57 C0                 xorps   xmm8, xmm8
0000000180384AB3  41 0F 28 ED                 movaps  xmm5, xmm13
0000000180384AB7  F3 41 0F 5C E8              subss   xmm5, xmm8
0000000180384ABC  0F 28 FD                    movaps  xmm7, xmm5
0000000180384ABF  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180384AC3  F3 0F 11 BB B0 29 01 00     movss   dword ptr [rbx+129B0h], xmm7
0000000180384ACB  0F 28 E7                    movaps  xmm4, xmm7
0000000180384ACE  F3 0F 10 9B 90 2A 01 00     movss   xmm3, dword ptr [rbx+12A90h]
0000000180384AD6  F3 0F 10 93 E0 2A 01 00     movss   xmm2, dword ptr [rbx+12AE0h]
0000000180384ADE  0F 28 CB                    movaps  xmm1, xmm3
0000000180384AE1  F3 0F 59 8B 00 2B 01 00     mulss   xmm1, dword ptr [rbx+12B00h]
0000000180384AE9  0F 28 C2                    movaps  xmm0, xmm2
0000000180384AEC  F3 0F 58 A3 B0 2A 01 00     addss   xmm4, dword ptr [rbx+12AB0h]
0000000180384AF4  F3 0F 5C BB C0 29 01 00     subss   xmm7, dword ptr [rbx+129C0h]
0000000180384AFC  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180384B00  41 0F 2F E6                 comiss  xmm4, xmm14
0000000180384B04  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180384B08  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180384B0C  F3 0F 11 8B 00 2A 01 00     movss   dword ptr [rbx+12A00h], xmm1
0000000180384B14  72 06                       jb      short loc_180384B1C
0000000180384B16  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180384B1A  EB 03                       jmp     short loc_180384B1F
0000000180384B1C  0F 57 F6                    xorps   xmm6, xmm6
0000000180384B1F  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180384B23  F3 0F 10 83 60 2A 01 00     movss   xmm0, dword ptr [rbx+12A60h]
0000000180384B2B  73 03                       jnb     short loc_180384B30
0000000180384B2D  0F 28 F5                    movaps  xmm6, xmm5
0000000180384B30  F3 0F 59 83 E0 2A 01 00     mulss   xmm0, dword ptr [rbx+12AE0h]
0000000180384B38  0F 28 DD                    movaps  xmm3, xmm5
0000000180384B3B  F3 0F 10 93 50 2A 01 00     movss   xmm2, dword ptr [rbx+12A50h]
0000000180384B43  F3 44 0F 10 0D 10 04 76 00  movss   xmm9, cs:dword_180AE4F5C
0000000180384B4C  F3 0F 59 D8                 mulss   xmm3, xmm0
0000000180384B50  F3 0F 11 B3 C0 29 01 00     movss   dword ptr [rbx+129C0h], xmm6
0000000180384B58  F3 0F 10 8B F0 2A 01 00     movss   xmm1, dword ptr [rbx+12AF0h]
0000000180384B60  F3 0F 10 BB 70 2A 01 00     movss   xmm7, dword ptr [rbx+12A70h]
0000000180384B68  0F 28 C1                    movaps  xmm0, xmm1
0000000180384B6B  F3 0F 10 A3 F0 29 01 00     movss   xmm4, dword ptr [rbx+129F0h]
0000000180384B73  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180384B77  F3 41 0F 59 F9              mulss   xmm7, xmm9
0000000180384B7C  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180384B80  F3 41 0F 59 D1              mulss   xmm2, xmm9
0000000180384B85  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180384B89  F3 0F 59 FE                 mulss   xmm7, xmm6
0000000180384B8D  F3 0F 5C C6                 subss   xmm0, xmm6
0000000180384B91  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180384B95  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180384B99  0F 28 CB                    movaps  xmm1, xmm3
0000000180384B9C  F3 0F 5C CC                 subss   xmm1, xmm4
0000000180384BA0  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180384BA4  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180384BA8  F3 0F 58 FA                 addss   xmm7, xmm2
0000000180384BAC  76 0B                       jbe     short loc_180384BB9
0000000180384BAE  0F 28 DC                    movaps  xmm3, xmm4
0000000180384BB1  F3 0F 58 9B 00 2A 01 00     addss   xmm3, dword ptr [rbx+12A00h]
0000000180384BB9  F3 0F 10 83 E0 2A 01 00     movss   xmm0, dword ptr [rbx+12AE0h]
0000000180384BC1  F3 0F 10 A3 A0 29 01 00     movss   xmm4, dword ptr [rbx+129A0h]
0000000180384BC9  F3 0F 5D C3                 minss   xmm0, xmm3
0000000180384BCD  F3 0F 11 83 E0 29 01 00     movss   dword ptr [rbx+129E0h], xmm0
0000000180384BD5  F3 0F 10 8B 20 2A 01 00     movss   xmm1, dword ptr [rbx+12A20h]
0000000180384BDD  F3 0F 10 9B 80 2A 01 00     movss   xmm3, dword ptr [rbx+12A80h]
0000000180384BE5  F3 0F 59 AB D0 2A 01 00     mulss   xmm5, dword ptr [rbx+12AD0h]
0000000180384BED  F3 41 0F 59 D9              mulss   xmm3, xmm9
0000000180384BF2  F3 0F 59 F0                 mulss   xmm6, xmm0
0000000180384BF6  F3 0F 10 83 10 2B 01 00     movss   xmm0, dword ptr [rbx+12B10h]
0000000180384BFE  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180384C03  0F 28 D0                    movaps  xmm2, xmm0
0000000180384C06  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180384C0A  F3 0F 58 EE                 addss   xmm5, xmm6
0000000180384C0E  F3 0F 59 D7                 mulss   xmm2, xmm7
0000000180384C12  F3 0F 5C EC                 subss   xmm5, xmm4
0000000180384C16  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180384C1A  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180384C1E  F3 0F 11 93 10 2A 01 00     movss   dword ptr [rbx+12A10h], xmm2
0000000180384C26  F3 44 0F 59 C2              mulss   xmm8, xmm2
0000000180384C2B  F3 41 0F 5C D8              subss   xmm3, xmm8
0000000180384C30  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180384C34  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180384C38  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180384C3C  F3 0F 11 9B 90 29 01 00     movss   dword ptr [rbx+12990h], xmm3
0000000180384C44  F3 0F 59 9B 20 2B 01 00     mulss   xmm3, dword ptr [rbx+12B20h]
0000000180384C4C  F3 0F 59 9B 30 2B 01 00     mulss   xmm3, dword ptr [rbx+12B30h]
0000000180384C54  0F 28 C3                    movaps  xmm0, xmm3
0000000180384C57  F3 0F 59 83 40 2B 01 00     mulss   xmm0, dword ptr [rbx+12B40h]
0000000180384C5F  F3 0F 11 9B 30 2A 01 00     movss   dword ptr [rbx+12A30h], xmm3
0000000180384C67  F3 0F 11 83 40 2A 01 00     movss   dword ptr [rbx+12A40h], xmm0
0000000180384C6F  44 0F 2F B3 90 26 01 00     comiss  xmm14, dword ptr [rbx+12690h]
0000000180384C77  F3 0F 10 8B A0 21 01 00     movss   xmm1, dword ptr [rbx+121A0h]
0000000180384C7F  F3 0F 10 93 50 2B 01 00     movss   xmm2, dword ptr [rbx+12B50h]
0000000180384C87  73 06                       jnb     short loc_180384C8F
0000000180384C89  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180384C8D  EB 03                       jmp     short loc_180384C92
0000000180384C8F  0F 57 C0                    xorps   xmm0, xmm0
0000000180384C92  41 0F 2E D6                 ucomiss xmm2, xmm14
0000000180384C96  75 04                       jnz     short loc_180384C9C
0000000180384C98  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180384C9C  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180384CA0  F3 0F 11 8B 60 2B 01 00     movss   dword ptr [rbx+12B60h], xmm1
0000000180384CA8  8B 83 70 2B 01 00           mov     eax, [rbx+12B70h]
0000000180384CAE  89 83 80 2B 01 00           mov     [rbx+12B80h], eax
0000000180384CB4  8B 83 A0 2B 01 00           mov     eax, [rbx+12BA0h]
0000000180384CBA  89 83 B0 2B 01 00           mov     [rbx+12BB0h], eax
0000000180384CC0  8B 83 90 2B 01 00           mov     eax, [rbx+12B90h]
0000000180384CC6  89 83 A0 2B 01 00           mov     [rbx+12BA0h], eax
0000000180384CCC  8B 83 C0 2B 01 00           mov     eax, [rbx+12BC0h]
0000000180384CD2  89 83 D0 2B 01 00           mov     [rbx+12BD0h], eax
0000000180384CD8  8B 83 F0 2B 01 00           mov     eax, [rbx+12BF0h]
0000000180384CDE  89 83 00 2C 01 00           mov     [rbx+12C00h], eax
0000000180384CE4  F3 0F 10 83 A0 2C 01 00     movss   xmm0, dword ptr [rbx+12CA0h]
0000000180384CEC  F3 0F 58 8B 80 2C 01 00     addss   xmm1, dword ptr [rbx+12C80h]
0000000180384CF4  F3 0F 59 83 B0 2B 01 00     mulss   xmm0, dword ptr [rbx+12BB0h]
0000000180384CFC  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180384D00  F3 0F 58 83 80 2B 01 00     addss   xmm0, dword ptr [rbx+12B80h]
0000000180384D08  73 06                       jnb     short loc_180384D10
0000000180384D0A  45 0F 28 C5                 movaps  xmm8, xmm13
0000000180384D0E  EB 04                       jmp     short loc_180384D14
0000000180384D10  45 0F 57 C0                 xorps   xmm8, xmm8
0000000180384D14  41 0F 28 ED                 movaps  xmm5, xmm13
0000000180384D18  F3 41 0F 5C E8              subss   xmm5, xmm8
0000000180384D1D  0F 28 F5                    movaps  xmm6, xmm5
0000000180384D20  F3 0F 59 F0                 mulss   xmm6, xmm0
0000000180384D24  F3 0F 11 B3 90 2B 01 00     movss   dword ptr [rbx+12B90h], xmm6
0000000180384D2C  0F 28 E6                    movaps  xmm4, xmm6
0000000180384D2F  F3 0F 10 9B 70 2C 01 00     movss   xmm3, dword ptr [rbx+12C70h]
0000000180384D37  F3 0F 10 93 C0 2C 01 00     movss   xmm2, dword ptr [rbx+12CC0h]
0000000180384D3F  0F 28 CB                    movaps  xmm1, xmm3
0000000180384D42  F3 0F 59 8B E0 2C 01 00     mulss   xmm1, dword ptr [rbx+12CE0h]
0000000180384D4A  0F 28 C2                    movaps  xmm0, xmm2
0000000180384D4D  F3 0F 58 A3 90 2C 01 00     addss   xmm4, dword ptr [rbx+12C90h]
0000000180384D55  F3 0F 5C B3 A0 2B 01 00     subss   xmm6, dword ptr [rbx+12BA0h]
0000000180384D5D  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180384D61  41 0F 2F E6                 comiss  xmm4, xmm14
0000000180384D65  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180384D69  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180384D6D  F3 0F 11 8B E0 2B 01 00     movss   dword ptr [rbx+12BE0h], xmm1
0000000180384D75  72 06                       jb      short loc_180384D7D
0000000180384D77  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180384D7B  EB 03                       jmp     short loc_180384D80
0000000180384D7D  0F 57 FF                    xorps   xmm7, xmm7
0000000180384D80  41 0F 2F F6                 comiss  xmm6, xmm14
0000000180384D84  F3 0F 10 83 40 2C 01 00     movss   xmm0, dword ptr [rbx+12C40h]
0000000180384D8C  73 03                       jnb     short loc_180384D91
0000000180384D8E  0F 28 FD                    movaps  xmm7, xmm5
0000000180384D91  F3 0F 59 83 C0 2C 01 00     mulss   xmm0, dword ptr [rbx+12CC0h]
0000000180384D99  0F 28 DD                    movaps  xmm3, xmm5
0000000180384D9C  F3 0F 10 93 30 2C 01 00     movss   xmm2, dword ptr [rbx+12C30h]
0000000180384DA4  F3 0F 11 BB A0 2B 01 00     movss   dword ptr [rbx+12BA0h], xmm7
0000000180384DAC  F3 0F 10 8B D0 2C 01 00     movss   xmm1, dword ptr [rbx+12CD0h]
0000000180384DB4  F3 0F 10 B3 50 2C 01 00     movss   xmm6, dword ptr [rbx+12C50h]
0000000180384DBC  F3 0F 10 A3 D0 2B 01 00     movss   xmm4, dword ptr [rbx+12BD0h]
0000000180384DC4  F3 0F 59 D8                 mulss   xmm3, xmm0
0000000180384DC8  0F 28 C1                    movaps  xmm0, xmm1
0000000180384DCB  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180384DCF  F3 41 0F 59 F1              mulss   xmm6, xmm9
0000000180384DD4  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180384DD8  F3 41 0F 59 D1              mulss   xmm2, xmm9
0000000180384DDD  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180384DE1  F3 0F 59 F7                 mulss   xmm6, xmm7
0000000180384DE5  F3 0F 5C C7                 subss   xmm0, xmm7
0000000180384DE9  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180384DED  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180384DF1  0F 28 CB                    movaps  xmm1, xmm3
0000000180384DF4  F3 0F 5C CC                 subss   xmm1, xmm4
0000000180384DF8  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180384DFC  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180384E00  F3 0F 58 F2                 addss   xmm6, xmm2
0000000180384E04  76 0B                       jbe     short loc_180384E11
0000000180384E06  0F 28 DC                    movaps  xmm3, xmm4
0000000180384E09  F3 0F 58 9B E0 2B 01 00     addss   xmm3, dword ptr [rbx+12BE0h]
0000000180384E11  F3 0F 10 A3 80 2B 01 00     movss   xmm4, dword ptr [rbx+12B80h]
0000000180384E19  F3 0F 10 83 C0 2C 01 00     movss   xmm0, dword ptr [rbx+12CC0h]
0000000180384E21  F3 0F 5D C3                 minss   xmm0, xmm3
0000000180384E25  F3 0F 11 83 C0 2B 01 00     movss   dword ptr [rbx+12BC0h], xmm0
0000000180384E2D  F3 0F 59 AB B0 2C 01 00     mulss   xmm5, dword ptr [rbx+12CB0h]
0000000180384E35  F3 0F 10 8B 00 2C 01 00     movss   xmm1, dword ptr [rbx+12C00h]
0000000180384E3D  F3 0F 10 9B 60 2C 01 00     movss   xmm3, dword ptr [rbx+12C60h]
0000000180384E45  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180384E49  F3 0F 10 83 F0 2C 01 00     movss   xmm0, dword ptr [rbx+12CF0h]
0000000180384E51  0F 28 D0                    movaps  xmm2, xmm0
0000000180384E54  F3 41 0F 59 D9              mulss   xmm3, xmm9
0000000180384E59  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180384E5D  F3 0F 58 EF                 addss   xmm5, xmm7
0000000180384E61  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180384E66  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180384E6A  F3 0F 5C EC                 subss   xmm5, xmm4
0000000180384E6E  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180384E72  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180384E76  F3 0F 11 93 F0 2B 01 00     movss   dword ptr [rbx+12BF0h], xmm2
0000000180384E7E  F3 44 0F 59 C2              mulss   xmm8, xmm2
0000000180384E83  F3 41 0F 5C D8              subss   xmm3, xmm8
0000000180384E88  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180384E8C  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180384E90  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180384E94  F3 0F 11 9B 70 2B 01 00     movss   dword ptr [rbx+12B70h], xmm3
0000000180384E9C  F3 0F 59 9B 00 2D 01 00     mulss   xmm3, dword ptr [rbx+12D00h]
0000000180384EA4  F3 0F 59 9B 10 2D 01 00     mulss   xmm3, dword ptr [rbx+12D10h]
0000000180384EAC  0F 28 C3                    movaps  xmm0, xmm3
0000000180384EAF  F3 0F 59 83 20 2D 01 00     mulss   xmm0, dword ptr [rbx+12D20h]
0000000180384EB7  F3 0F 11 9B 10 2C 01 00     movss   dword ptr [rbx+12C10h], xmm3
0000000180384EBF  F3 0F 11 83 20 2C 01 00     movss   dword ptr [rbx+12C20h], xmm0
0000000180384EC7  8B 83 30 2D 01 00           mov     eax, [rbx+12D30h]
0000000180384ECD  89 83 40 2D 01 00           mov     [rbx+12D40h], eax
0000000180384ED3  8B 83 50 2D 01 00           mov     eax, [rbx+12D50h]
0000000180384ED9  89 83 60 2D 01 00           mov     [rbx+12D60h], eax
0000000180384EDF  F3 0F 10 83 60 22 01 00     movss   xmm0, dword ptr [rbx+12260h]
0000000180384EE7  F3 44 0F 10 83 E0 22 01 00  movss   xmm8, dword ptr [rbx+122E0h]
0000000180384EF0  8B 83 90 2D 01 00           mov     eax, [rbx+12D90h]
0000000180384EF6  89 83 A0 2D 01 00           mov     [rbx+12DA0h], eax
0000000180384EFC  F3 0F 59 83 70 2D 01 00     mulss   xmm0, dword ptr [rbx+12D70h]
0000000180384F04  F3 44 0F 59 83 80 2D 01 00  mulss   xmm8, dword ptr [rbx+12D80h]
0000000180384F0D  F3 44 0F 58 C0              addss   xmm8, xmm0
0000000180384F12  F3 44 0F 11 83 90 2D 01 00  movss   dword ptr [rbx+12D90h], xmm8
0000000180384F1B  F3 0F 10 BB 70 26 01 00     movss   xmm7, dword ptr [rbx+12670h]
0000000180384F23  F3 0F 10 8B 30 2A 01 00     movss   xmm1, dword ptr [rbx+12A30h]
0000000180384F2B  F3 0F 10 93 10 2C 01 00     movss   xmm2, dword ptr [rbx+12C10h]
0000000180384F33  F3 0F 10 83 60 22 01 00     movss   xmm0, dword ptr [rbx+12260h]
0000000180384F3B  8B 83 50 2D 01 00           mov     eax, [rbx+12D50h]
0000000180384F41  89 83 D0 2D 01 00           mov     [rbx+12DD0h], eax
0000000180384F47  F3 0F 11 83 E0 2D 01 00     movss   dword ptr [rbx+12DE0h], xmm0
0000000180384F4F  F3 0F 10 A3 20 2F 01 00     movss   xmm4, dword ptr [rbx+12F20h]
0000000180384F57  F3 0F 11 8B B0 2D 01 00     movss   dword ptr [rbx+12DB0h], xmm1
0000000180384F5F  F3 0F 11 93 C0 2D 01 00     movss   dword ptr [rbx+12DC0h], xmm2
0000000180384F67  F3 0F 10 AB 00 2F 01 00     movss   xmm5, dword ptr [rbx+12F00h]
0000000180384F6F  F3 0F 59 FC                 mulss   xmm7, xmm4
0000000180384F73  F3 0F 59 A3 80 26 01 00     mulss   xmm4, dword ptr [rbx+12680h]
0000000180384F7B  F3 0F 11 A3 F0 2D 01 00     movss   dword ptr [rbx+12DF0h], xmm4
0000000180384F83  F3 0F 10 8B 80 2E 01 00     movss   xmm1, dword ptr [rbx+12E80h]
0000000180384F8B  F3 0F 10 93 80 2F 01 00     movss   xmm2, dword ptr [rbx+12F80h]
0000000180384F93  0F 28 D9                    movaps  xmm3, xmm1
0000000180384F96  F3 0F 59 BB 30 2F 01 00     mulss   xmm7, dword ptr [rbx+12F30h]
0000000180384F9E  0F 28 C2                    movaps  xmm0, xmm2
0000000180384FA1  F3 0F 10 B3 40 2F 01 00     movss   xmm6, dword ptr [rbx+12F40h]
0000000180384FA9  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180384FAD  F3 0F 59 F7                 mulss   xmm6, xmm7
0000000180384FB1  F3 0F 59 EC                 mulss   xmm5, xmm4
0000000180384FB5  F3 0F 59 AB 10 2F 01 00     mulss   xmm5, dword ptr [rbx+12F10h]
0000000180384FBD  F3 0F 11 AB 10 2E 01 00     movss   dword ptr [rbx+12E10h], xmm5
0000000180384FC5  F3 0F 58 F5                 addss   xmm6, xmm5
0000000180384FC9  F3 0F 59 9B D0 2D 01 00     mulss   xmm3, dword ptr [rbx+12DD0h]
0000000180384FD1  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180384FD5  F3 0F 10 83 90 2E 01 00     movss   xmm0, dword ptr [rbx+12E90h]
0000000180384FDD  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180384FE1  F3 0F 59 9B 90 2F 01 00     mulss   xmm3, dword ptr [rbx+12F90h]
0000000180384FE9  F3 0F 11 9B 20 2E 01 00     movss   dword ptr [rbx+12E20h], xmm3
0000000180384FF1  F3 0F 10 8B 60 2F 01 00     movss   xmm1, dword ptr [rbx+12F60h]
0000000180384FF9  F3 0F 59 8B C0 2D 01 00     mulss   xmm1, dword ptr [rbx+12DC0h]
0000000180385001  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180385005  F3 0F 58 F0                 addss   xmm6, xmm0
0000000180385009  F3 0F 10 83 50 2F 01 00     movss   xmm0, dword ptr [rbx+12F50h]
0000000180385011  F3 0F 59 83 B0 2D 01 00     mulss   xmm0, dword ptr [rbx+12DB0h]
0000000180385019  F3 0F 10 9B F0 2D 01 00     movss   xmm3, dword ptr [rbx+12DF0h]
0000000180385021  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180385025  F3 0F 10 83 70 2E 01 00     movss   xmm0, dword ptr [rbx+12E70h]
000000018038502D  F3 0F 59 8B 70 2F 01 00     mulss   xmm1, dword ptr [rbx+12F70h]
0000000180385035  F3 0F 58 CE                 addss   xmm1, xmm6
0000000180385039  F3 41 0F 58 C8              addss   xmm1, xmm8
000000018038503E  F3 0F 58 8B E0 2E 01 00     addss   xmm1, dword ptr [rbx+12EE0h]
0000000180385046  F3 0F 58 8B F0 2E 01 00     addss   xmm1, dword ptr [rbx+12EF0h]
000000018038504E  F3 0F 11 8B 30 2E 01 00     movss   dword ptr [rbx+12E30h], xmm1
0000000180385056  F3 0F 11 83 40 2E 01 00     movss   dword ptr [rbx+12E40h], xmm0
000000018038505E  F3 0F 59 9B B0 2F 01 00     mulss   xmm3, dword ptr [rbx+12FB0h]
0000000180385066  F3 0F 10 83 B0 2E 01 00     movss   xmm0, dword ptr [rbx+12EB0h]
000000018038506E  F3 0F 59 83 B0 2D 01 00     mulss   xmm0, dword ptr [rbx+12DB0h]
0000000180385076  F3 0F 58 9B C0 2F 01 00     addss   xmm3, dword ptr [rbx+12FC0h]
000000018038507E  F3 0F 10 8B C0 2E 01 00     movss   xmm1, dword ptr [rbx+12EC0h]
0000000180385086  F3 0F 59 8B C0 2D 01 00     mulss   xmm1, dword ptr [rbx+12DC0h]
000000018038508E  F3 0F 10 93 10 2E 01 00     movss   xmm2, dword ptr [rbx+12E10h]
0000000180385096  F3 0F 59 9B A0 2E 01 00     mulss   xmm3, dword ptr [rbx+12EA0h]
000000018038509E  F3 0F 58 93 E0 2D 01 00     addss   xmm2, dword ptr [rbx+12DE0h]
00000001803850A6  F3 0F 58 D8                 addss   xmm3, xmm0
00000001803850AA  F3 0F 58 93 20 2E 01 00     addss   xmm2, dword ptr [rbx+12E20h]
00000001803850B2  F3 0F 58 D9                 addss   xmm3, xmm1
00000001803850B6  F3 0F 58 9B D0 2E 01 00     addss   xmm3, dword ptr [rbx+12ED0h]
00000001803850BE  F3 0F 59 9B A0 2F 01 00     mulss   xmm3, dword ptr [rbx+12FA0h]
00000001803850C6  F3 0F 11 9B 50 2E 01 00     movss   dword ptr [rbx+12E50h], xmm3
00000001803850CE  F3 0F 11 93 60 2E 01 00     movss   dword ptr [rbx+12E60h], xmm2
00000001803850D6  F3 0F 10 83 E0 2F 01 00     movss   xmm0, dword ptr [rbx+12FE0h]
00000001803850DE  8B 83 D0 2F 01 00           mov     eax, [rbx+12FD0h]
00000001803850E4  89 83 00 30 01 00           mov     [rbx+13000h], eax
00000001803850EA  F3 0F 11 83 10 30 01 00     movss   dword ptr [rbx+13010h], xmm0
00000001803850F2  8B 83 F0 2F 01 00           mov     eax, [rbx+12FF0h]
00000001803850F8  89 83 20 30 01 00           mov     [rbx+13020h], eax
00000001803850FE  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
0000000180385106  8B 83 40 30 01 00           mov     eax, [rbx+13040h]
000000018038510C  89 83 50 30 01 00           mov     [rbx+13050h], eax
0000000180385112  F3 0F 10 93 30 30 01 00     movss   xmm2, dword ptr [rbx+13030h]
000000018038511A  F3 0F 11 93 40 30 01 00     movss   dword ptr [rbx+13040h], xmm2
0000000180385122  0F 28 C2                    movaps  xmm0, xmm2
0000000180385125  0F 28 DA                    movaps  xmm3, xmm2
0000000180385128  F3 0F 59 9B 60 30 01 00     mulss   xmm3, dword ptr [rbx+13060h]
0000000180385130  F3 0F 58 9B 50 30 01 00     addss   xmm3, dword ptr [rbx+13050h]
0000000180385138  F3 0F 11 9B 40 30 01 00     movss   dword ptr [rbx+13040h], xmm3
0000000180385140  F3 0F 59 83 70 30 01 00     mulss   xmm0, dword ptr [rbx+13070h]
0000000180385148  F3 0F 58 C3                 addss   xmm0, xmm3
000000018038514C  F3 0F 59 9B A0 30 01 00     mulss   xmm3, dword ptr [rbx+130A0h]
0000000180385154  F3 0F 5C E0                 subss   xmm4, xmm0
0000000180385158  0F 28 CC                    movaps  xmm1, xmm4
000000018038515B  F3 0F 59 8B 60 30 01 00     mulss   xmm1, dword ptr [rbx+13060h]
0000000180385163  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180385167  F3 0F 11 8B 30 30 01 00     movss   dword ptr [rbx+13030h], xmm1
000000018038516F  F3 0F 59 8B 90 30 01 00     mulss   xmm1, dword ptr [rbx+13090h]
0000000180385177  F3 0F 59 A3 80 30 01 00     mulss   xmm4, dword ptr [rbx+13080h]
000000018038517F  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180385183  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180385187  F3 0F 11 A3 50 30 01 00     movss   dword ptr [rbx+13050h], xmm4
000000018038518F  8B 83 80 38 01 00           mov     eax, [rbx+13880h]
0000000180385195  89 83 90 38 01 00           mov     [rbx+13890h], eax
000000018038519B  F3 0F 10 8B A0 38 01 00     movss   xmm1, dword ptr [rbx+138A0h]
00000001803851A3  F3 0F 11 8B B0 38 01 00     movss   dword ptr [rbx+138B0h], xmm1
00000001803851AB  F3 0F 59 8B 40 2D 01 00     mulss   xmm1, dword ptr [rbx+12D40h]
00000001803851B3  F3 0F 10 83 90 38 01 00     movss   xmm0, dword ptr [rbx+13890h]
00000001803851BB  F3 0F 59 83 50 30 01 00     mulss   xmm0, dword ptr [rbx+13050h]
00000001803851C3  F3 0F 11 8B C0 38 01 00     movss   dword ptr [rbx+138C0h], xmm1
00000001803851CB  F3 0F 11 83 D0 38 01 00     movss   dword ptr [rbx+138D0h], xmm0
00000001803851D3  8B 83 00 39 01 00           mov     eax, [rbx+13900h]
00000001803851D9  89 83 10 39 01 00           mov     [rbx+13910h], eax
00000001803851DF  F3 0F 59 8B E0 38 01 00     mulss   xmm1, dword ptr [rbx+138E0h]
00000001803851E7  F3 0F 59 83 F0 38 01 00     mulss   xmm0, dword ptr [rbx+138F0h]
00000001803851EF  F3 0F 58 C1                 addss   xmm0, xmm1
00000001803851F3  F3 0F 11 83 00 39 01 00     movss   dword ptr [rbx+13900h], xmm0
00000001803851FB  8B 83 20 39 01 00           mov     eax, [rbx+13920h]
0000000180385201  89 83 30 39 01 00           mov     [rbx+13930h], eax
0000000180385207  8B 83 40 39 01 00           mov     eax, [rbx+13940h]
000000018038520D  89 83 50 39 01 00           mov     [rbx+13950h], eax
0000000180385213  8B 83 60 39 01 00           mov     eax, [rbx+13960h]
0000000180385219  89 83 70 39 01 00           mov     [rbx+13970h], eax
000000018038521F  8B 83 80 39 01 00           mov     eax, [rbx+13980h]
0000000180385225  89 83 90 39 01 00           mov     [rbx+13990h], eax
000000018038522B  F3 0F 10 8B B0 39 01 00     movss   xmm1, dword ptr [rbx+139B0h]
0000000180385233  F3 0F 10 93 C0 39 01 00     movss   xmm2, dword ptr [rbx+139C0h]
000000018038523B  0F 28 E1                    movaps  xmm4, xmm1
000000018038523E  F3 0F 59 A3 20 39 01 00     mulss   xmm4, dword ptr [rbx+13920h]
0000000180385246  0F 28 C2                    movaps  xmm0, xmm2
0000000180385249  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018038524D  F3 0F 5C E0                 subss   xmm4, xmm0
0000000180385251  F3 0F 58 E2                 addss   xmm4, xmm2
0000000180385255  0F 28 DC                    movaps  xmm3, xmm4
0000000180385258  0F 28 CC                    movaps  xmm1, xmm4
000000018038525B  F3 0F 59 8B E0 39 01 00     mulss   xmm1, dword ptr [rbx+139E0h]
0000000180385263  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180385267  F3 0F 58 8B D0 39 01 00     addss   xmm1, dword ptr [rbx+139D0h]
000000018038526F  0F 28 C3                    movaps  xmm0, xmm3
0000000180385272  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180385276  F3 0F 59 83 F0 39 01 00     mulss   xmm0, dword ptr [rbx+139F0h]
000000018038527E  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180385282  0F 28 C3                    movaps  xmm0, xmm3
0000000180385285  F3 0F 59 9B 00 3A 01 00     mulss   xmm3, dword ptr [rbx+13A00h]
000000018038528D  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180385291  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180385295  F3 0F 59 83 10 3A 01 00     mulss   xmm0, dword ptr [rbx+13A10h]
000000018038529D  F3 0F 58 C3                 addss   xmm0, xmm3
00000001803852A1  41 0F 2F C6                 comiss  xmm0, xmm14
00000001803852A5  76 05                       jbe     short loc_1803852AC
00000001803852A7  0F 5A C0                    cvtps2pd xmm0, xmm0
00000001803852AA  EB 03                       jmp     short loc_1803852AF
00000001803852AC  0F 57 C0                    xorps   xmm0, xmm0
00000001803852AF  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00000001803852B3  41 0F 2F CD                 comiss  xmm1, xmm13
00000001803852B7  73 04                       jnb     short loc_1803852BD
00000001803852B9  44 0F 5A E1                 cvtps2pd xmm12, xmm1
00000001803852BD  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
00000001803852C2  F3 0F 11 83 A0 39 01 00     movss   dword ptr [rbx+139A0h], xmm0
00000001803852CA  8B 83 20 3A 01 00           mov     eax, [rbx+13A20h]
00000001803852D0  89 83 30 3A 01 00           mov     [rbx+13A30h], eax
00000001803852D6  F3 0F 10 8B 40 3A 01 00     movss   xmm1, dword ptr [rbx+13A40h]
00000001803852DE  F3 0F 11 8B 50 3A 01 00     movss   dword ptr [rbx+13A50h], xmm1
00000001803852E6  F3 0F 10 83 60 3A 01 00     movss   xmm0, dword ptr [rbx+13A60h]
00000001803852EE  F3 0F 11 83 70 3A 01 00     movss   dword ptr [rbx+13A70h], xmm0
00000001803852F6  F3 0F 5C C8                 subss   xmm1, xmm0
00000001803852FA  F3 0F 59 8B 80 3A 01 00     mulss   xmm1, dword ptr [rbx+13A80h]
0000000180385302  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180385306  F3 0F 11 8B 60 3A 01 00     movss   dword ptr [rbx+13A60h], xmm1
000000018038530E  F3 0F 10 8B 60 22 01 00     movss   xmm1, dword ptr [rbx+12260h]
0000000180385316  F3 0F 10 83 E0 22 01 00     movss   xmm0, dword ptr [rbx+122E0h]
000000018038531E  8B 83 B0 3A 01 00           mov     eax, [rbx+13AB0h]
0000000180385324  89 83 C0 3A 01 00           mov     [rbx+13AC0h], eax
000000018038532A  F3 0F 59 83 A0 3A 01 00     mulss   xmm0, dword ptr [rbx+13AA0h]
0000000180385332  F3 0F 59 8B 90 3A 01 00     mulss   xmm1, dword ptr [rbx+13A90h]
000000018038533A  F3 0F 58 C1                 addss   xmm0, xmm1
000000018038533E  F3 0F 11 83 B0 3A 01 00     movss   dword ptr [rbx+13AB0h], xmm0
0000000180385346  8B 83 D0 3A 01 00           mov     eax, [rbx+13AD0h]
000000018038534C  89 83 F0 3A 01 00           mov     [rbx+13AF0h], eax
0000000180385352  F3 0F 10 9B E0 3A 01 00     movss   xmm3, dword ptr [rbx+13AE0h]
000000018038535A  F3 0F 11 9B 00 3B 01 00     movss   dword ptr [rbx+13B00h], xmm3
0000000180385362  F3 0F 10 8B F0 3A 01 00     movss   xmm1, dword ptr [rbx+13AF0h]
000000018038536A  F3 0F 10 93 30 2A 01 00     movss   xmm2, dword ptr [rbx+12A30h]
0000000180385372  0F 28 C1                    movaps  xmm0, xmm1
0000000180385375  F3 0F 59 83 10 2C 01 00     mulss   xmm0, dword ptr [rbx+12C10h]
000000018038537D  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180385381  F3 0F 5C C1                 subss   xmm0, xmm1
0000000180385385  0F 28 CB                    movaps  xmm1, xmm3
0000000180385388  F3 0F 59 8B 60 39 01 00     mulss   xmm1, dword ptr [rbx+13960h]
0000000180385390  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180385394  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180385398  F3 0F 5C CB                 subss   xmm1, xmm3
000000018038539C  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803853A0  F3 0F 11 8B 10 3B 01 00     movss   dword ptr [rbx+13B10h], xmm1
00000001803853A8  F3 0F 10 9B 70 26 01 00     movss   xmm3, dword ptr [rbx+12670h]
00000001803853B0  F3 0F 10 83 20 3B 01 00     movss   xmm0, dword ptr [rbx+13B20h]
00000001803853B8  F3 0F 11 83 30 3B 01 00     movss   dword ptr [rbx+13B30h], xmm0
00000001803853C0  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803853C4  0F 28 CB                    movaps  xmm1, xmm3
00000001803853C7  F3 0F 59 8B 40 3B 01 00     mulss   xmm1, dword ptr [rbx+13B40h]
00000001803853CF  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803853D3  F3 0F 10 83 60 3B 01 00     movss   xmm0, dword ptr [rbx+13B60h]
00000001803853DB  F3 0F 11 8B 20 3B 01 00     movss   dword ptr [rbx+13B20h], xmm1
00000001803853E3  F3 0F 59 9B 50 3B 01 00     mulss   xmm3, dword ptr [rbx+13B50h]
00000001803853EB  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803853EF  F3 0F 58 D8                 addss   xmm3, xmm0
00000001803853F3  F3 0F 11 9B 30 3B 01 00     movss   dword ptr [rbx+13B30h], xmm3
00000001803853FB  F3 0F 10 83 70 3B 01 00     movss   xmm0, dword ptr [rbx+13B70h]
0000000180385403  F3 0F 10 BB 80 26 01 00     movss   xmm7, dword ptr [rbx+12680h]
000000018038540B  F3 0F 11 83 80 3B 01 00     movss   dword ptr [rbx+13B80h], xmm0
0000000180385413  F3 0F 5C F8                 subss   xmm7, xmm0
0000000180385417  0F 28 CF                    movaps  xmm1, xmm7
000000018038541A  F3 0F 59 8B 90 3B 01 00     mulss   xmm1, dword ptr [rbx+13B90h]
0000000180385422  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180385426  F3 0F 10 83 B0 3B 01 00     movss   xmm0, dword ptr [rbx+13BB0h]
000000018038542E  F3 0F 11 8B 70 3B 01 00     movss   dword ptr [rbx+13B70h], xmm1
0000000180385436  F3 0F 59 BB A0 3B 01 00     mulss   xmm7, dword ptr [rbx+13BA0h]
000000018038543E  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180385442  F3 0F 58 F8                 addss   xmm7, xmm0
0000000180385446  F3 0F 11 BB 80 3B 01 00     movss   dword ptr [rbx+13B80h], xmm7
000000018038544E  F3 0F 10 A3 30 3B 01 00     movss   xmm4, dword ptr [rbx+13B30h]
0000000180385456  F3 0F 10 AB 10 3B 01 00     movss   xmm5, dword ptr [rbx+13B10h]
000000018038545E  F3 0F 10 B3 B0 3A 01 00     movss   xmm6, dword ptr [rbx+13AB0h]
0000000180385466  F3 44 0F 10 8B 40 39 01 00  movss   xmm9, dword ptr [rbx+13940h]
000000018038546F  8B 83 60 3A 01 00           mov     eax, [rbx+13A60h]
0000000180385475  89 83 C0 3B 01 00           mov     [rbx+13BC0h], eax
000000018038547B  F3 44 0F 11 8B D0 3B 01 00  movss   dword ptr [rbx+13BD0h], xmm9
0000000180385484  F3 0F 10 83 F0 3B 01 00     movss   xmm0, dword ptr [rbx+13BF0h]
000000018038548C  F3 0F 10 93 00 3C 01 00     movss   xmm2, dword ptr [rbx+13C00h]
0000000180385494  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180385498  0F 28 DA                    movaps  xmm3, xmm2
000000018038549B  F3 0F 59 9B 80 39 01 00     mulss   xmm3, dword ptr [rbx+13980h]
00000001803854A3  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803854A7  0F 28 C2                    movaps  xmm0, xmm2
00000001803854AA  F3 0F 59 C7                 mulss   xmm0, xmm7
00000001803854AE  44 0F 28 C3                 movaps  xmm8, xmm3
00000001803854B2  F3 44 0F 5C C0              subss   xmm8, xmm0
00000001803854B7  F3 44 0F 58 C7              addss   xmm8, xmm7
00000001803854BC  F3 44 0F 59 83 30 3C 01 00  mulss   xmm8, dword ptr [rbx+13C30h]
00000001803854C5  F3 0F 10 8B 10 3C 01 00     movss   xmm1, dword ptr [rbx+13C10h]
00000001803854CD  F3 0F 58 B3 B0 3C 01 00     addss   xmm6, dword ptr [rbx+13CB0h]
00000001803854D5  F3 44 0F 59 83 40 3C 01 00  mulss   xmm8, dword ptr [rbx+13C40h]
00000001803854DE  F3 0F 59 AB 50 3C 01 00     mulss   xmm5, dword ptr [rbx+13C50h]
00000001803854E6  F3 0F 59 B3 60 3C 01 00     mulss   xmm6, dword ptr [rbx+13C60h]
00000001803854EE  F3 44 0F 59 C9              mulss   xmm9, xmm1
00000001803854F3  F3 0F 59 D4                 mulss   xmm2, xmm4
00000001803854F7  F3 0F 58 F5                 addss   xmm6, xmm5
00000001803854FB  F3 0F 5C DA                 subss   xmm3, xmm2
00000001803854FF  F3 0F 10 93 90 3C 01 00     movss   xmm2, dword ptr [rbx+13C90h]
0000000180385507  0F 28 C2                    movaps  xmm0, xmm2
000000018038550A  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018038550E  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180385512  F3 44 0F 5C C8              subss   xmm9, xmm0
0000000180385517  F3 0F 10 83 80 3C 01 00     movss   xmm0, dword ptr [rbx+13C80h]
000000018038551F  F3 0F 58 83 C0 3B 01 00     addss   xmm0, dword ptr [rbx+13BC0h]
0000000180385527  F3 0F 59 9B 20 3C 01 00     mulss   xmm3, dword ptr [rbx+13C20h]
000000018038552F  F3 0F 59 83 C0 3C 01 00     mulss   xmm0, dword ptr [rbx+13CC0h]
0000000180385537  F3 44 0F 58 CA              addss   xmm9, xmm2
000000018038553C  F3 44 0F 58 C3              addss   xmm8, xmm3
0000000180385541  F3 0F 59 83 70 3C 01 00     mulss   xmm0, dword ptr [rbx+13C70h]
0000000180385549  F3 44 0F 59 8B A0 3C 01 00  mulss   xmm9, dword ptr [rbx+13CA0h]
0000000180385552  F3 44 0F 58 C6              addss   xmm8, xmm6
0000000180385557  F3 44 0F 58 C8              addss   xmm9, xmm0
000000018038555C  F3 45 0F 58 C8              addss   xmm9, xmm8
0000000180385561  F3 44 0F 11 8B E0 3B 01 00  movss   dword ptr [rbx+13BE0h], xmm9
000000018038556A  F3 0F 10 BB A0 39 01 00     movss   xmm7, dword ptr [rbx+139A0h]
0000000180385572  F3 44 0F 10 83 30 3A 01 00  movss   xmm8, dword ptr [rbx+13A30h]
000000018038557B  8B 83 00 3D 01 00           mov     eax, [rbx+13D00h]
0000000180385581  89 83 10 3D 01 00           mov     [rbx+13D10h], eax
0000000180385587  F3 0F 10 83 F0 3C 01 00     movss   xmm0, dword ptr [rbx+13CF0h]
000000018038558F  F3 0F 11 83 00 3D 01 00     movss   dword ptr [rbx+13D00h], xmm0
0000000180385597  44 0F 2E AB 40 3D 01 00     ucomiss xmm13, dword ptr [rbx+13D40h]
000000018038559F  0F 85 8F 02 00 00           jnz     loc_180385834
00000001803855A5  F3 0F 10 8B 90 3D 01 00     movss   xmm1, dword ptr [rbx+13D90h]
00000001803855AD  F3 0F 10 B3 10 3D 01 00     movss   xmm6, dword ptr [rbx+13D10h]
00000001803855B5  0F 28 D1                    movaps  xmm2, xmm1
00000001803855B8  F3 0F 59 CE                 mulss   xmm1, xmm6
00000001803855BC  F3 0F 59 D0                 mulss   xmm2, xmm0
00000001803855C0  41 0F 57 C3                 xorps   xmm0, xmm11
00000001803855C4  F3 0F 5C D1                 subss   xmm2, xmm1
00000001803855C8  F3 0F 58 F2                 addss   xmm6, xmm2
00000001803855CC  F3 0F 11 B3 00 3D 01 00     movss   dword ptr [rbx+13D00h], xmm6
00000001803855D4  F3 0F 59 B3 80 3D 01 00     mulss   xmm6, dword ptr [rbx+13D80h]
00000001803855DC  F3 0F 58 B3 20 3D 01 00     addss   xmm6, dword ptr [rbx+13D20h]
00000001803855E4  E8 77 37 FE FF              call    sub_180368D60
00000001803855E9  F3 0F 11 83 F0 3C 01 00     movss   dword ptr [rbx+13CF0h], xmm0
00000001803855F1  41 0F 28 C8                 movaps  xmm1, xmm8
00000001803855F5  F3 0F 59 8B E0 3D 01 00     mulss   xmm1, dword ptr [rbx+13DE0h]
00000001803855FD  41 0F 28 D5                 movaps  xmm2, xmm13
0000000180385601  F3 41 0F 5C D0              subss   xmm2, xmm8
0000000180385606  F3 0F 58 8B 30 3D 01 00     addss   xmm1, dword ptr [rbx+13D30h]
000000018038560E  F3 0F 59 93 A0 3D 01 00     mulss   xmm2, dword ptr [rbx+13DA0h]
0000000180385616  F3 0F 11 8B E0 3C 01 00     movss   dword ptr [rbx+13CE0h], xmm1
000000018038561E  F3 44 0F 59 8B 70 3D 01 00  mulss   xmm9, dword ptr [rbx+13D70h]
0000000180385627  F3 0F 59 BB 50 3D 01 00     mulss   xmm7, dword ptr [rbx+13D50h]
000000018038562F  F3 0F 10 83 B0 3D 01 00     movss   xmm0, dword ptr [rbx+13DB0h]
0000000180385637  F3 0F 5D C2                 minss   xmm0, xmm2
000000018038563B  F3 44 0F 58 CF              addss   xmm9, xmm7
0000000180385640  F3 44 0F 58 CE              addss   xmm9, xmm6
0000000180385645  F3 44 0F 58 C8              addss   xmm9, xmm0
000000018038564A  F3 44 0F 58 8B 60 3D 01 00  addss   xmm9, dword ptr [rbx+13D60h]
0000000180385653  F3 44 0F 5D 8B C0 3D 01 00  minss   xmm9, dword ptr [rbx+13DC0h]
000000018038565C  F3 44 0F 5F 8B D0 3D 01 00  maxss   xmm9, dword ptr [rbx+13DD0h]
0000000180385665  F3 44 0F 59 8B 00 3E 01 00  mulss   xmm9, dword ptr [rbx+13E00h]
000000018038566E  F3 44 0F 58 8B 10 3E 01 00  addss   xmm9, dword ptr [rbx+13E10h]
0000000180385677  41 0F 28 C9                 movaps  xmm1, xmm9
000000018038567B  F3 0F 2C C9                 cvttss2si ecx, xmm1
000000018038567F  81 F9 00 00 00 80           cmp     ecx, 80000000h
0000000180385685  74 1E                       jz      short loc_1803856A5
0000000180385687  66 0F 6E C1                 movd    xmm0, ecx
000000018038568B  0F 5B C0                    cvtdq2ps xmm0, xmm0
000000018038568E  0F 2E C1                    ucomiss xmm0, xmm1
0000000180385691  74 12                       jz      short loc_1803856A5
0000000180385693  0F 14 C9                    unpcklps xmm1, xmm1
0000000180385696  0F 50 C1                    movmskps eax, xmm1
0000000180385699  83 E0 01                    and     eax, 1
000000018038569C  2B C8                       sub     ecx, eax
000000018038569E  66 0F 6E C9                 movd    xmm1, ecx
00000001803856A2  0F 5B C9                    cvtdq2ps xmm1, xmm1
00000001803856A5  F3 44 0F 5C C9              subss   xmm9, xmm1
00000001803856AA  0F 28 C1                    movaps  xmm0, xmm1; X
00000001803856AD  41 0F 28 F1                 movaps  xmm6, xmm9
00000001803856B1  F3 41 0F 59 F1              mulss   xmm6, xmm9
00000001803856B6  F3 0F 59 35 12 F9 75 00     mulss   xmm6, cs:dword_180AE4FD0
00000001803856BE  E8 7D A0 36 00              call    expf
00000001803856C3  0F 28 E0                    movaps  xmm4, xmm0
00000001803856C6  41 0F 28 D1                 movaps  xmm2, xmm9
00000001803856CA  F3 0F 59 93 D0 3E 01 00     mulss   xmm2, dword ptr [rbx+13ED0h]
00000001803856D2  41 0F 28 C9                 movaps  xmm1, xmm9
00000001803856D6  F3 0F 59 8B B0 3E 01 00     mulss   xmm1, dword ptr [rbx+13EB0h]
00000001803856DE  41 0F 28 C1                 movaps  xmm0, xmm9
00000001803856E2  F3 0F 58 93 C0 3E 01 00     addss   xmm2, dword ptr [rbx+13EC0h]
00000001803856EA  F3 0F 59 83 90 3E 01 00     mulss   xmm0, dword ptr [rbx+13E90h]
00000001803856F2  F3 0F 59 D6                 mulss   xmm2, xmm6
00000001803856F6  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803856FA  F3 0F 58 93 A0 3E 01 00     addss   xmm2, dword ptr [rbx+13EA0h]
0000000180385702  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180385706  F3 0F 58 D0                 addss   xmm2, xmm0
000000018038570A  41 0F 28 C1                 movaps  xmm0, xmm9
000000018038570E  F3 0F 59 83 70 3E 01 00     mulss   xmm0, dword ptr [rbx+13E70h]
0000000180385716  F3 0F 58 93 80 3E 01 00     addss   xmm2, dword ptr [rbx+13E80h]
000000018038571E  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180385722  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180385726  41 0F 28 C1                 movaps  xmm0, xmm9
000000018038572A  F3 0F 59 83 50 3E 01 00     mulss   xmm0, dword ptr [rbx+13E50h]
0000000180385732  F3 44 0F 59 8B 30 3E 01 00  mulss   xmm9, dword ptr [rbx+13E30h]
000000018038573B  F3 0F 58 93 60 3E 01 00     addss   xmm2, dword ptr [rbx+13E60h]
0000000180385743  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180385747  F3 0F 58 D0                 addss   xmm2, xmm0
000000018038574B  F3 0F 58 93 40 3E 01 00     addss   xmm2, dword ptr [rbx+13E40h]
0000000180385753  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180385757  F3 41 0F 58 D1              addss   xmm2, xmm9
000000018038575C  F3 41 0F 58 D5              addss   xmm2, xmm13
0000000180385761  F3 0F 59 E2                 mulss   xmm4, xmm2
0000000180385765  F3 0F 59 A3 20 3E 01 00     mulss   xmm4, dword ptr [rbx+13E20h]
000000018038576D  0F 28 DC                    movaps  xmm3, xmm4
0000000180385770  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180385774  0F 28 CB                    movaps  xmm1, xmm3
0000000180385777  44 0F 28 C3                 movaps  xmm8, xmm3
000000018038577B  F3 44 0F 59 83 70 3F 01 00  mulss   xmm8, dword ptr [rbx+13F70h]
0000000180385784  0F 28 C3                    movaps  xmm0, xmm3
0000000180385787  F3 0F 59 83 30 3F 01 00     mulss   xmm0, dword ptr [rbx+13F30h]
000000018038578F  0F 28 D3                    movaps  xmm2, xmm3
0000000180385792  F3 44 0F 58 83 50 3F 01 00  addss   xmm8, dword ptr [rbx+13F50h]
000000018038579B  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018038579F  F3 0F 58 83 10 3F 01 00     addss   xmm0, dword ptr [rbx+13F10h]
00000001803857A7  F3 0F 59 D3                 mulss   xmm2, xmm3
00000001803857AB  F3 44 0F 59 C2              mulss   xmm8, xmm2
00000001803857B0  F3 44 0F 58 C0              addss   xmm8, xmm0
00000001803857B5  0F 28 C1                    movaps  xmm0, xmm1
00000001803857B8  F3 0F 59 8B F0 3E 01 00     mulss   xmm1, dword ptr [rbx+13EF0h]
00000001803857C0  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803857C4  F3 44 0F 59 C0              mulss   xmm8, xmm0
00000001803857C9  0F 28 C3                    movaps  xmm0, xmm3
00000001803857CC  F3 0F 59 83 20 3F 01 00     mulss   xmm0, dword ptr [rbx+13F20h]
00000001803857D4  F3 44 0F 58 C1              addss   xmm8, xmm1
00000001803857D9  0F 28 CB                    movaps  xmm1, xmm3
00000001803857DC  F3 0F 59 8B 60 3F 01 00     mulss   xmm1, dword ptr [rbx+13F60h]
00000001803857E4  F3 0F 59 9B E0 3E 01 00     mulss   xmm3, dword ptr [rbx+13EE0h]
00000001803857EC  F3 0F 58 8B 40 3F 01 00     addss   xmm1, dword ptr [rbx+13F40h]
00000001803857F4  F3 44 0F 58 C4              addss   xmm8, xmm4
00000001803857F9  F3 0F 59 CA                 mulss   xmm1, xmm2
00000001803857FD  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180385801  F3 0F 58 8B 00 3F 01 00     addss   xmm1, dword ptr [rbx+13F00h]
0000000180385809  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018038580D  F3 0F 58 CB                 addss   xmm1, xmm3
0000000180385811  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180385816  F3 44 0F 5E C1              divss   xmm8, xmm1
000000018038581B  41 0F 28 C0                 movaps  xmm0, xmm8
000000018038581F  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180385824  F3 44 0F 5E C0              divss   xmm8, xmm0
0000000180385829  F3 44 0F 11 83 D0 3C 01 00  movss   dword ptr [rbx+13CD0h], xmm8
0000000180385832  EB 09                       jmp     short loc_18038583D
0000000180385834  F3 44 0F 10 83 D0 3C 01 00  movss   xmm8, dword ptr [rbx+13CD0h]
000000018038583D  8B 83 E0 3F 01 00           mov     eax, [rbx+13FE0h]
0000000180385843  F3 0F 10 8B 00 39 01 00     movss   xmm1, dword ptr [rbx+13900h]
000000018038584B  F3 44 0F 10 8B E0 3C 01 00  movss   xmm9, dword ptr [rbx+13CE0h]
0000000180385854  89 83 F0 3F 01 00           mov     [rbx+13FF0h], eax
000000018038585A  8B 83 D0 3F 01 00           mov     eax, [rbx+13FD0h]
0000000180385860  89 83 E0 3F 01 00           mov     [rbx+13FE0h], eax
0000000180385866  8B 83 C0 3F 01 00           mov     eax, [rbx+13FC0h]
000000018038586C  89 83 D0 3F 01 00           mov     [rbx+13FD0h], eax
0000000180385872  8B 83 B0 3F 01 00           mov     eax, [rbx+13FB0h]
0000000180385878  89 83 C0 3F 01 00           mov     [rbx+13FC0h], eax
000000018038587E  8B 83 A0 3F 01 00           mov     eax, [rbx+13FA0h]
0000000180385884  89 83 B0 3F 01 00           mov     [rbx+13FB0h], eax
000000018038588A  8B 83 90 3F 01 00           mov     eax, [rbx+13F90h]
0000000180385890  89 83 A0 3F 01 00           mov     [rbx+13FA0h], eax
0000000180385896  8B 83 80 3F 01 00           mov     eax, [rbx+13F80h]
000000018038589C  89 83 90 3F 01 00           mov     [rbx+13F90h], eax
00000001803858A2  8B 83 C0 40 01 00           mov     eax, [rbx+140C0h]
00000001803858A8  89 83 D0 40 01 00           mov     [rbx+140D0h], eax
00000001803858AE  8B 83 B0 40 01 00           mov     eax, [rbx+140B0h]
00000001803858B4  89 83 C0 40 01 00           mov     [rbx+140C0h], eax
00000001803858BA  8B 83 A0 40 01 00           mov     eax, [rbx+140A0h]
00000001803858C0  89 83 B0 40 01 00           mov     [rbx+140B0h], eax
00000001803858C6  8B 83 90 40 01 00           mov     eax, [rbx+14090h]
00000001803858CC  89 83 A0 40 01 00           mov     [rbx+140A0h], eax
00000001803858D2  8B 83 80 40 01 00           mov     eax, [rbx+14080h]
00000001803858D8  89 83 90 40 01 00           mov     [rbx+14090h], eax
00000001803858DE  8B 83 70 40 01 00           mov     eax, [rbx+14070h]
00000001803858E4  89 83 80 40 01 00           mov     [rbx+14080h], eax
00000001803858EA  8B 83 60 40 01 00           mov     eax, [rbx+14060h]
00000001803858F0  89 83 70 40 01 00           mov     [rbx+14070h], eax
00000001803858F6  8B 83 40 41 01 00           mov     eax, [rbx+14140h]
00000001803858FC  89 83 50 41 01 00           mov     [rbx+14150h], eax
0000000180385902  8B 83 30 41 01 00           mov     eax, [rbx+14130h]
0000000180385908  89 83 40 41 01 00           mov     [rbx+14140h], eax
000000018038590E  8B 83 20 41 01 00           mov     eax, [rbx+14120h]
0000000180385914  89 83 30 41 01 00           mov     [rbx+14130h], eax
000000018038591A  8B 83 10 41 01 00           mov     eax, [rbx+14110h]
0000000180385920  89 83 20 41 01 00           mov     [rbx+14120h], eax
0000000180385926  8B 83 00 41 01 00           mov     eax, [rbx+14100h]
000000018038592C  89 83 10 41 01 00           mov     [rbx+14110h], eax
0000000180385932  8B 83 F0 40 01 00           mov     eax, [rbx+140F0h]
0000000180385938  89 83 00 41 01 00           mov     [rbx+14100h], eax
000000018038593E  8B 83 E0 40 01 00           mov     eax, [rbx+140E0h]
0000000180385944  89 83 F0 40 01 00           mov     [rbx+140F0h], eax
000000018038594A  8B 83 C0 41 01 00           mov     eax, [rbx+141C0h]
0000000180385950  89 83 D0 41 01 00           mov     [rbx+141D0h], eax
0000000180385956  8B 83 B0 41 01 00           mov     eax, [rbx+141B0h]
000000018038595C  89 83 C0 41 01 00           mov     [rbx+141C0h], eax
0000000180385962  8B 83 A0 41 01 00           mov     eax, [rbx+141A0h]
0000000180385968  89 83 B0 41 01 00           mov     [rbx+141B0h], eax
000000018038596E  8B 83 90 41 01 00           mov     eax, [rbx+14190h]
0000000180385974  89 83 A0 41 01 00           mov     [rbx+141A0h], eax
000000018038597A  8B 83 80 41 01 00           mov     eax, [rbx+14180h]
0000000180385980  89 83 90 41 01 00           mov     [rbx+14190h], eax
0000000180385986  8B 83 70 41 01 00           mov     eax, [rbx+14170h]
000000018038598C  89 83 80 41 01 00           mov     [rbx+14180h], eax
0000000180385992  8B 83 60 41 01 00           mov     eax, [rbx+14160h]
0000000180385998  89 83 70 41 01 00           mov     [rbx+14170h], eax
000000018038599E  8B 83 40 42 01 00           mov     eax, [rbx+14240h]
00000001803859A4  89 83 50 42 01 00           mov     [rbx+14250h], eax
00000001803859AA  8B 83 30 42 01 00           mov     eax, [rbx+14230h]
00000001803859B0  89 83 40 42 01 00           mov     [rbx+14240h], eax
00000001803859B6  8B 83 20 42 01 00           mov     eax, [rbx+14220h]
00000001803859BC  89 83 30 42 01 00           mov     [rbx+14230h], eax
00000001803859C2  8B 83 10 42 01 00           mov     eax, [rbx+14210h]
00000001803859C8  89 83 20 42 01 00           mov     [rbx+14220h], eax
00000001803859CE  8B 83 00 42 01 00           mov     eax, [rbx+14200h]
00000001803859D4  89 83 10 42 01 00           mov     [rbx+14210h], eax
00000001803859DA  8B 83 F0 41 01 00           mov     eax, [rbx+141F0h]
00000001803859E0  89 83 00 42 01 00           mov     [rbx+14200h], eax
00000001803859E6  8B 83 E0 41 01 00           mov     eax, [rbx+141E0h]
00000001803859EC  89 83 F0 41 01 00           mov     [rbx+141F0h], eax
00000001803859F2  8B 83 60 42 01 00           mov     eax, [rbx+14260h]
00000001803859F8  89 83 70 42 01 00           mov     [rbx+14270h], eax
00000001803859FE  F3 0F 10 83 80 42 01 00     movss   xmm0, dword ptr [rbx+14280h]
0000000180385A06  F3 0F 11 83 90 42 01 00     movss   dword ptr [rbx+14290h], xmm0
0000000180385A0E  44 0F 2E AB D0 42 01 00     ucomiss xmm13, dword ptr [rbx+142D0h]
0000000180385A16  0F 85 49 09 00 00           jnz     loc_180386365
0000000180385A1C  F3 0F 59 8B 20 43 01 00     mulss   xmm1, dword ptr [rbx+14320h]
0000000180385A24  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180385A28  41 0F 28 F1                 movaps  xmm6, xmm9
0000000180385A2C  41 0F 28 F8                 movaps  xmm7, xmm8
0000000180385A30  F3 0F 59 B3 40 43 01 00     mulss   xmm6, dword ptr [rbx+14340h]
0000000180385A38  F3 41 0F 59 F8              mulss   xmm7, xmm8
0000000180385A3D  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180385A42  F3 0F 59 F1                 mulss   xmm6, xmm1
0000000180385A46  0F 28 C8                    movaps  xmm1, xmm0
0000000180385A49  F3 0F 59 8B 10 43 01 00     mulss   xmm1, dword ptr [rbx+14310h]
0000000180385A51  F3 0F 58 F1                 addss   xmm6, xmm1
0000000180385A55  E8 06 33 FE FF              call    sub_180368D60
0000000180385A5A  F3 0F 11 83 80 42 01 00     movss   dword ptr [rbx+14280h], xmm0
0000000180385A62  41 0F 28 DD                 movaps  xmm3, xmm13
0000000180385A66  F3 0F 11 B3 60 42 01 00     movss   dword ptr [rbx+14260h], xmm6
0000000180385A6E  41 0F 28 C0                 movaps  xmm0, xmm8
0000000180385A72  F3 0F 59 FF                 mulss   xmm7, xmm7
0000000180385A76  F3 41 0F 58 C0              addss   xmm0, xmm8
0000000180385A7B  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180385A7F  F3 41 0F 59 F9              mulss   xmm7, xmm9
0000000180385A84  F3 0F 5C F0                 subss   xmm6, xmm0
0000000180385A88  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180385A8D  F3 0F 5E DF                 divss   xmm3, xmm7
0000000180385A91  F3 0F 11 9B B0 42 01 00     movss   dword ptr [rbx+142B0h], xmm3
0000000180385A99  0F 28 E3                    movaps  xmm4, xmm3
0000000180385A9C  F3 0F 10 8B 60 42 01 00     movss   xmm1, dword ptr [rbx+14260h]
0000000180385AA4  F3 0F 10 AB 70 42 01 00     movss   xmm5, dword ptr [rbx+14270h]
0000000180385AAC  F3 41 0F 59 E1              mulss   xmm4, xmm9
0000000180385AB1  F3 0F 11 A3 A0 42 01 00     movss   dword ptr [rbx+142A0h], xmm4
0000000180385AB9  F3 0F 59 AB 70 43 01 00     mulss   xmm5, dword ptr [rbx+14370h]
0000000180385AC1  F3 0F 10 93 E0 3F 01 00     movss   xmm2, dword ptr [rbx+13FE0h]
0000000180385AC9  F3 0F 59 8B 80 43 01 00     mulss   xmm1, dword ptr [rbx+14380h]
0000000180385AD1  F3 0F 10 83 F0 3F 01 00     movss   xmm0, dword ptr [rbx+13FF0h]
0000000180385AD9  F3 0F 11 93 50 40 01 00     movss   dword ptr [rbx+14050h], xmm2
0000000180385AE1  F3 0F 59 93 A0 44 01 00     mulss   xmm2, dword ptr [rbx+144A0h]
0000000180385AE9  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180385AED  F3 0F 59 83 B0 44 01 00     mulss   xmm0, dword ptr [rbx+144B0h]
0000000180385AF5  F3 0F 59 EB                 mulss   xmm5, xmm3
0000000180385AF9  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180385AFD  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180385B01  F3 0F 5C EA                 subss   xmm5, xmm2
0000000180385B05  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180385B09  73 06                       jnb     short loc_180385B11
0000000180385B0B  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180385B0F  EB 05                       jmp     short loc_180385B16
0000000180385B11  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180385B16  0F 28 CD                    movaps  xmm1, xmm5
0000000180385B19  0F 28 C5                    movaps  xmm0, xmm5
0000000180385B1C  F3 0F 59 83 50 43 01 00     mulss   xmm0, dword ptr [rbx+14350h]
0000000180385B24  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180385B28  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180385B2C  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180385B30  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180385B34  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180385B38  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180385B3C  F3 0F 11 AB 00 40 01 00     movss   dword ptr [rbx+14000h], xmm5
0000000180385B44  0F 28 D5                    movaps  xmm2, xmm5
0000000180385B47  F3 0F 58 AB 90 3F 01 00     addss   xmm5, dword ptr [rbx+13F90h]
0000000180385B4F  F3 0F 10 9B A0 3F 01 00     movss   xmm3, dword ptr [rbx+13FA0h]
0000000180385B57  0F 28 C3                    movaps  xmm0, xmm3
0000000180385B5A  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180385B5E  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180385B62  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180385B66  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180385B6A  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180385B6E  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180385B72  0F 28 C6                    movaps  xmm0, xmm6
0000000180385B75  F3 0F 11 A3 10 40 01 00     movss   dword ptr [rbx+14010h], xmm4
0000000180385B7D  F3 0F 10 8B B0 3F 01 00     movss   xmm1, dword ptr [rbx+13FB0h]
0000000180385B85  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180385B89  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180385B8D  0F 28 C1                    movaps  xmm0, xmm1
0000000180385B90  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180385B94  F3 0F 58 EC                 addss   xmm5, xmm4
0000000180385B98  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180385B9C  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180385BA0  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180385BA4  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180385BA8  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180385BAC  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180385BB0  0F 28 C6                    movaps  xmm0, xmm6
0000000180385BB3  F3 0F 11 9B 20 40 01 00     movss   dword ptr [rbx+14020h], xmm3
0000000180385BBB  F3 0F 10 AB C0 3F 01 00     movss   xmm5, dword ptr [rbx+13FC0h]
0000000180385BC3  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180385BC7  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180385BCB  0F 28 C5                    movaps  xmm0, xmm5
0000000180385BCE  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180385BD2  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180385BD6  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180385BDA  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180385BDE  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180385BE2  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180385BE6  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180385BEA  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180385BEE  0F 28 C6                    movaps  xmm0, xmm6
0000000180385BF1  F3 0F 11 93 30 40 01 00     movss   dword ptr [rbx+14030h], xmm2
0000000180385BF9  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180385BFD  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180385C01  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180385C05  F3 41 0F 59 E8              mulss   xmm5, xmm8
0000000180385C0A  0F 28 C6                    movaps  xmm0, xmm6
0000000180385C0D  F3 0F 59 83 D0 3F 01 00     mulss   xmm0, dword ptr [rbx+13FD0h]
0000000180385C15  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180385C19  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180385C1D  0F 28 C6                    movaps  xmm0, xmm6
0000000180385C20  F3 0F 59 E1                 mulss   xmm4, xmm1
0000000180385C24  F3 0F 11 AB 40 40 01 00     movss   dword ptr [rbx+14040h], xmm5
0000000180385C2C  F3 0F 10 93 30 40 01 00     movss   xmm2, dword ptr [rbx+14030h]
0000000180385C34  F3 0F 59 93 F0 42 01 00     mulss   xmm2, dword ptr [rbx+142F0h]
0000000180385C3C  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180385C40  F3 0F 59 AB 00 43 01 00     mulss   xmm5, dword ptr [rbx+14300h]
0000000180385C48  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180385C4C  F3 0F 10 83 E0 42 01 00     movss   xmm0, dword ptr [rbx+142E0h]
0000000180385C54  F3 0F 59 83 20 40 01 00     mulss   xmm0, dword ptr [rbx+14020h]
0000000180385C5C  F3 0F 58 D5                 addss   xmm2, xmm5
0000000180385C60  F3 0F 10 AB 70 42 01 00     movss   xmm5, dword ptr [rbx+14270h]
0000000180385C68  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180385C6C  F3 0F 11 93 E0 41 01 00     movss   dword ptr [rbx+141E0h], xmm2
0000000180385C74  F3 0F 58 AB 60 42 01 00     addss   xmm5, dword ptr [rbx+14260h]
0000000180385C7C  F3 0F 10 83 50 40 01 00     movss   xmm0, dword ptr [rbx+14050h]
0000000180385C84  F3 0F 59 AB 90 43 01 00     mulss   xmm5, dword ptr [rbx+14390h]
0000000180385C8C  F3 0F 59 AB B0 42 01 00     mulss   xmm5, dword ptr [rbx+142B0h]
0000000180385C94  F3 0F 11 A3 50 40 01 00     movss   dword ptr [rbx+14050h], xmm4
0000000180385C9C  F3 0F 59 A3 A0 44 01 00     mulss   xmm4, dword ptr [rbx+144A0h]
0000000180385CA4  F3 0F 59 83 B0 44 01 00     mulss   xmm0, dword ptr [rbx+144B0h]
0000000180385CAC  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180385CB0  F3 0F 59 A3 A0 42 01 00     mulss   xmm4, dword ptr [rbx+142A0h]
0000000180385CB8  F3 0F 5C EC                 subss   xmm5, xmm4
0000000180385CBC  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180385CC0  73 06                       jnb     short loc_180385CC8
0000000180385CC2  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180385CC6  EB 05                       jmp     short loc_180385CCD
0000000180385CC8  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180385CCD  0F 28 CD                    movaps  xmm1, xmm5
0000000180385CD0  0F 28 C5                    movaps  xmm0, xmm5
0000000180385CD3  F3 0F 59 83 50 43 01 00     mulss   xmm0, dword ptr [rbx+14350h]
0000000180385CDB  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180385CDF  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180385CE3  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180385CE7  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180385CEB  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180385CEF  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180385CF3  F3 0F 10 8B 00 40 01 00     movss   xmm1, dword ptr [rbx+14000h]
0000000180385CFB  F3 0F 11 AB 00 40 01 00     movss   dword ptr [rbx+14000h], xmm5
0000000180385D03  0F 28 D5                    movaps  xmm2, xmm5
0000000180385D06  F3 0F 10 9B 10 40 01 00     movss   xmm3, dword ptr [rbx+14010h]
0000000180385D0E  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180385D12  0F 28 C3                    movaps  xmm0, xmm3
0000000180385D15  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180385D19  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180385D1D  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180385D21  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180385D25  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180385D29  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180385D2D  0F 28 C6                    movaps  xmm0, xmm6
0000000180385D30  F3 0F 11 A3 10 40 01 00     movss   dword ptr [rbx+14010h], xmm4
0000000180385D38  F3 0F 10 8B 20 40 01 00     movss   xmm1, dword ptr [rbx+14020h]
0000000180385D40  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180385D44  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180385D48  0F 28 C1                    movaps  xmm0, xmm1
0000000180385D4B  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180385D4F  F3 0F 58 EC                 addss   xmm5, xmm4
0000000180385D53  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180385D57  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180385D5B  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180385D5F  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180385D63  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180385D67  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180385D6B  0F 28 C6                    movaps  xmm0, xmm6
0000000180385D6E  F3 0F 11 9B 20 40 01 00     movss   dword ptr [rbx+14020h], xmm3
0000000180385D76  F3 0F 10 AB 30 40 01 00     movss   xmm5, dword ptr [rbx+14030h]
0000000180385D7E  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180385D82  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180385D86  0F 28 C5                    movaps  xmm0, xmm5
0000000180385D89  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180385D8D  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180385D91  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180385D95  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180385D99  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180385D9D  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180385DA1  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180385DA5  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180385DA9  0F 28 C6                    movaps  xmm0, xmm6
0000000180385DAC  F3 0F 11 93 30 40 01 00     movss   dword ptr [rbx+14030h], xmm2
0000000180385DB4  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180385DB8  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180385DBC  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180385DC0  F3 41 0F 59 E8              mulss   xmm5, xmm8
0000000180385DC5  0F 28 C6                    movaps  xmm0, xmm6
0000000180385DC8  F3 0F 59 83 40 40 01 00     mulss   xmm0, dword ptr [rbx+14040h]
0000000180385DD0  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180385DD4  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180385DD8  0F 28 C6                    movaps  xmm0, xmm6
0000000180385DDB  F3 0F 59 E1                 mulss   xmm4, xmm1
0000000180385DDF  F3 0F 11 AB 40 40 01 00     movss   dword ptr [rbx+14040h], xmm5
0000000180385DE7  F3 0F 10 93 30 40 01 00     movss   xmm2, dword ptr [rbx+14030h]
0000000180385DEF  F3 0F 59 93 F0 42 01 00     mulss   xmm2, dword ptr [rbx+142F0h]
0000000180385DF7  F3 0F 10 8B 60 42 01 00     movss   xmm1, dword ptr [rbx+14260h]
0000000180385DFF  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180385E03  F3 0F 59 AB 00 43 01 00     mulss   xmm5, dword ptr [rbx+14300h]
0000000180385E0B  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180385E0F  F3 0F 10 83 E0 42 01 00     movss   xmm0, dword ptr [rbx+142E0h]
0000000180385E17  F3 0F 59 83 20 40 01 00     mulss   xmm0, dword ptr [rbx+14020h]
0000000180385E1F  F3 0F 58 D5                 addss   xmm2, xmm5
0000000180385E23  F3 0F 10 AB 70 42 01 00     movss   xmm5, dword ptr [rbx+14270h]
0000000180385E2B  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180385E2F  F3 0F 11 93 60 41 01 00     movss   dword ptr [rbx+14160h], xmm2
0000000180385E37  F3 0F 59 AB 80 43 01 00     mulss   xmm5, dword ptr [rbx+14380h]
0000000180385E3F  F3 0F 59 8B 70 43 01 00     mulss   xmm1, dword ptr [rbx+14370h]
0000000180385E47  F3 0F 10 83 50 40 01 00     movss   xmm0, dword ptr [rbx+14050h]
0000000180385E4F  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180385E53  F3 0F 59 AB B0 42 01 00     mulss   xmm5, dword ptr [rbx+142B0h]
0000000180385E5B  F3 0F 11 A3 50 40 01 00     movss   dword ptr [rbx+14050h], xmm4
0000000180385E63  F3 0F 59 A3 A0 44 01 00     mulss   xmm4, dword ptr [rbx+144A0h]
0000000180385E6B  F3 0F 59 83 B0 44 01 00     mulss   xmm0, dword ptr [rbx+144B0h]
0000000180385E73  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180385E77  F3 0F 59 A3 A0 42 01 00     mulss   xmm4, dword ptr [rbx+142A0h]
0000000180385E7F  F3 0F 5C EC                 subss   xmm5, xmm4
0000000180385E83  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180385E87  73 06                       jnb     short loc_180385E8F
0000000180385E89  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180385E8D  EB 05                       jmp     short loc_180385E94
0000000180385E8F  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180385E94  0F 28 CD                    movaps  xmm1, xmm5
0000000180385E97  0F 28 C5                    movaps  xmm0, xmm5
0000000180385E9A  F3 0F 59 83 50 43 01 00     mulss   xmm0, dword ptr [rbx+14350h]
0000000180385EA2  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180385EA6  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180385EAA  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180385EAE  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180385EB2  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180385EB6  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180385EBA  F3 0F 10 8B 00 40 01 00     movss   xmm1, dword ptr [rbx+14000h]
0000000180385EC2  F3 0F 11 AB 00 40 01 00     movss   dword ptr [rbx+14000h], xmm5
0000000180385ECA  0F 28 D5                    movaps  xmm2, xmm5
0000000180385ECD  F3 0F 10 9B 10 40 01 00     movss   xmm3, dword ptr [rbx+14010h]
0000000180385ED5  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180385ED9  0F 28 C3                    movaps  xmm0, xmm3
0000000180385EDC  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180385EE0  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180385EE4  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180385EE8  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180385EEC  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180385EF0  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180385EF4  0F 28 C6                    movaps  xmm0, xmm6
0000000180385EF7  F3 0F 11 A3 10 40 01 00     movss   dword ptr [rbx+14010h], xmm4
0000000180385EFF  F3 0F 10 8B 20 40 01 00     movss   xmm1, dword ptr [rbx+14020h]
0000000180385F07  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180385F0B  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180385F0F  0F 28 C1                    movaps  xmm0, xmm1
0000000180385F12  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180385F16  F3 0F 58 EC                 addss   xmm5, xmm4
0000000180385F1A  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180385F1E  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180385F22  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180385F26  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180385F2A  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180385F2E  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180385F32  0F 28 C6                    movaps  xmm0, xmm6
0000000180385F35  F3 0F 11 9B 20 40 01 00     movss   dword ptr [rbx+14020h], xmm3
0000000180385F3D  F3 0F 10 AB 30 40 01 00     movss   xmm5, dword ptr [rbx+14030h]
0000000180385F45  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180385F49  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180385F4D  0F 28 C5                    movaps  xmm0, xmm5
0000000180385F50  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180385F54  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180385F58  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180385F5C  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180385F60  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180385F64  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180385F68  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180385F6C  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180385F70  0F 28 C6                    movaps  xmm0, xmm6
0000000180385F73  F3 0F 11 93 30 40 01 00     movss   dword ptr [rbx+14030h], xmm2
0000000180385F7B  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180385F7F  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180385F83  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180385F87  F3 41 0F 59 E8              mulss   xmm5, xmm8
0000000180385F8C  0F 28 C6                    movaps  xmm0, xmm6
0000000180385F8F  F3 0F 59 83 40 40 01 00     mulss   xmm0, dword ptr [rbx+14040h]
0000000180385F97  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180385F9B  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180385F9F  0F 28 C6                    movaps  xmm0, xmm6
0000000180385FA2  F3 0F 59 D9                 mulss   xmm3, xmm1
0000000180385FA6  F3 0F 11 AB 40 40 01 00     movss   dword ptr [rbx+14040h], xmm5
0000000180385FAE  F3 0F 10 8B 30 40 01 00     movss   xmm1, dword ptr [rbx+14030h]
0000000180385FB6  F3 0F 59 8B F0 42 01 00     mulss   xmm1, dword ptr [rbx+142F0h]
0000000180385FBE  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180385FC2  F3 0F 59 AB 00 43 01 00     mulss   xmm5, dword ptr [rbx+14300h]
0000000180385FCA  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180385FCE  F3 0F 10 83 E0 42 01 00     movss   xmm0, dword ptr [rbx+142E0h]
0000000180385FD6  F3 0F 59 83 20 40 01 00     mulss   xmm0, dword ptr [rbx+14020h]
0000000180385FDE  F3 0F 58 CD                 addss   xmm1, xmm5
0000000180385FE2  F3 0F 10 AB 60 42 01 00     movss   xmm5, dword ptr [rbx+14260h]
0000000180385FEA  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180385FEE  F3 0F 11 8B E0 40 01 00     movss   dword ptr [rbx+140E0h], xmm1
0000000180385FF6  F3 0F 59 AB 60 43 01 00     mulss   xmm5, dword ptr [rbx+14360h]
0000000180385FFE  F3 0F 10 83 50 40 01 00     movss   xmm0, dword ptr [rbx+14050h]
0000000180386006  F3 0F 59 AB B0 42 01 00     mulss   xmm5, dword ptr [rbx+142B0h]
000000018038600E  F3 0F 11 9B E0 3F 01 00     movss   dword ptr [rbx+13FE0h], xmm3
0000000180386016  F3 0F 59 9B A0 44 01 00     mulss   xmm3, dword ptr [rbx+144A0h]
000000018038601E  F3 0F 59 83 B0 44 01 00     mulss   xmm0, dword ptr [rbx+144B0h]
0000000180386026  F3 0F 58 D8                 addss   xmm3, xmm0
000000018038602A  F3 0F 59 9B A0 42 01 00     mulss   xmm3, dword ptr [rbx+142A0h]
0000000180386032  F3 0F 5C EB                 subss   xmm5, xmm3
0000000180386036  41 0F 2F EF                 comiss  xmm5, xmm15
000000018038603A  73 06                       jnb     short loc_180386042
000000018038603C  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180386040  EB 05                       jmp     short loc_180386047
0000000180386042  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180386047  0F 28 CD                    movaps  xmm1, xmm5
000000018038604A  0F 28 C5                    movaps  xmm0, xmm5
000000018038604D  F3 0F 59 83 50 43 01 00     mulss   xmm0, dword ptr [rbx+14350h]
0000000180386055  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180386059  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018038605D  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180386061  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180386065  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180386069  F3 0F 58 E9                 addss   xmm5, xmm1
000000018038606D  F3 0F 11 AB 80 3F 01 00     movss   dword ptr [rbx+13F80h], xmm5
0000000180386075  0F 28 D5                    movaps  xmm2, xmm5
0000000180386078  F3 0F 58 AB 00 40 01 00     addss   xmm5, dword ptr [rbx+14000h]
0000000180386080  F3 0F 10 9B 10 40 01 00     movss   xmm3, dword ptr [rbx+14010h]
0000000180386088  0F 28 C3                    movaps  xmm0, xmm3
000000018038608B  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018038608F  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180386093  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180386097  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018038609B  41 0F 28 D0                 movaps  xmm2, xmm8
000000018038609F  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803860A3  0F 28 C6                    movaps  xmm0, xmm6
00000001803860A6  F3 0F 11 A3 90 3F 01 00     movss   dword ptr [rbx+13F90h], xmm4
00000001803860AE  F3 0F 10 8B 20 40 01 00     movss   xmm1, dword ptr [rbx+14020h]
00000001803860B6  F3 0F 59 C4                 mulss   xmm0, xmm4
00000001803860BA  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803860BE  0F 28 C1                    movaps  xmm0, xmm1
00000001803860C1  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803860C5  F3 0F 58 EC                 addss   xmm5, xmm4
00000001803860C9  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803860CD  41 0F 28 D8                 movaps  xmm3, xmm8
00000001803860D1  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803860D5  41 0F 28 E0                 movaps  xmm4, xmm8
00000001803860D9  F3 0F 59 E5                 mulss   xmm4, xmm5
00000001803860DD  F3 0F 58 D8                 addss   xmm3, xmm0
00000001803860E1  0F 28 C6                    movaps  xmm0, xmm6
00000001803860E4  F3 0F 11 9B A0 3F 01 00     movss   dword ptr [rbx+13FA0h], xmm3
00000001803860EC  F3 0F 10 AB 30 40 01 00     movss   xmm5, dword ptr [rbx+14030h]
00000001803860F4  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803860F8  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803860FC  0F 28 C5                    movaps  xmm0, xmm5
00000001803860FF  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180386103  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180386107  F3 0F 58 D9                 addss   xmm3, xmm1
000000018038610B  41 0F 28 C8                 movaps  xmm1, xmm8
000000018038610F  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180386113  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180386117  F3 0F 58 D0                 addss   xmm2, xmm0
000000018038611B  0F 28 C6                    movaps  xmm0, xmm6
000000018038611E  F3 0F 11 93 B0 3F 01 00     movss   dword ptr [rbx+13FB0h], xmm2
0000000180386126  F3 0F 58 EA                 addss   xmm5, xmm2
000000018038612A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038612E  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180386132  F3 41 0F 59 E8              mulss   xmm5, xmm8
0000000180386137  0F 28 C6                    movaps  xmm0, xmm6
000000018038613A  F3 0F 59 83 40 40 01 00     mulss   xmm0, dword ptr [rbx+14040h]
0000000180386142  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180386146  F3 0F 58 E8                 addss   xmm5, xmm0
000000018038614A  F3 44 0F 59 C1              mulss   xmm8, xmm1
000000018038614F  F3 0F 11 AB C0 3F 01 00     movss   dword ptr [rbx+13FC0h], xmm5
0000000180386157  F3 0F 10 9B A0 3F 01 00     movss   xmm3, dword ptr [rbx+13FA0h]
000000018038615F  F3 0F 59 F5                 mulss   xmm6, xmm5
0000000180386163  F3 44 0F 58 C6              addss   xmm8, xmm6
0000000180386168  F3 44 0F 11 83 D0 3F 01 00  movss   dword ptr [rbx+13FD0h], xmm8
0000000180386171  F3 0F 10 83 F0 42 01 00     movss   xmm0, dword ptr [rbx+142F0h]
0000000180386179  F3 0F 59 83 B0 3F 01 00     mulss   xmm0, dword ptr [rbx+13FB0h]
0000000180386181  F3 0F 59 AB 00 43 01 00     mulss   xmm5, dword ptr [rbx+14300h]
0000000180386189  F3 0F 59 9B E0 42 01 00     mulss   xmm3, dword ptr [rbx+142E0h]
0000000180386191  F3 0F 10 A3 A0 40 01 00     movss   xmm4, dword ptr [rbx+140A0h]
0000000180386199  F3 0F 58 E8                 addss   xmm5, xmm0
000000018038619D  F3 0F 58 EB                 addss   xmm5, xmm3
00000001803861A1  F3 0F 11 AB 60 40 01 00     movss   dword ptr [rbx+14060h], xmm5
00000001803861A9  F3 0F 58 A3 10 42 01 00     addss   xmm4, dword ptr [rbx+14210h]
00000001803861B1  F3 0F 10 83 20 41 01 00     movss   xmm0, dword ptr [rbx+14120h]
00000001803861B9  F3 0F 58 83 90 41 01 00     addss   xmm0, dword ptr [rbx+14190h]
00000001803861C1  F3 0F 10 8B A0 41 01 00     movss   xmm1, dword ptr [rbx+141A0h]
00000001803861C9  F3 0F 58 8B 10 41 01 00     addss   xmm1, dword ptr [rbx+14110h]
00000001803861D1  F3 0F 59 A3 90 44 01 00     mulss   xmm4, dword ptr [rbx+14490h]
00000001803861D9  F3 0F 59 83 80 44 01 00     mulss   xmm0, dword ptr [rbx+14480h]
00000001803861E1  F3 0F 59 8B 70 44 01 00     mulss   xmm1, dword ptr [rbx+14470h]
00000001803861E9  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803861ED  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803861F1  F3 0F 10 83 90 40 01 00     movss   xmm0, dword ptr [rbx+14090h]
00000001803861F9  F3 0F 58 83 20 42 01 00     addss   xmm0, dword ptr [rbx+14220h]
0000000180386201  F3 0F 10 8B 00 42 01 00     movss   xmm1, dword ptr [rbx+14200h]
0000000180386209  F3 0F 58 8B B0 40 01 00     addss   xmm1, dword ptr [rbx+140B0h]
0000000180386211  F3 0F 58 AB 50 42 01 00     addss   xmm5, dword ptr [rbx+14250h]
0000000180386219  F3 0F 59 83 60 44 01 00     mulss   xmm0, dword ptr [rbx+14460h]
0000000180386221  F3 0F 59 8B 50 44 01 00     mulss   xmm1, dword ptr [rbx+14450h]
0000000180386229  F3 0F 59 AB A0 43 01 00     mulss   xmm5, dword ptr [rbx+143A0h]
0000000180386231  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180386235  F3 0F 10 83 80 41 01 00     movss   xmm0, dword ptr [rbx+14180h]
000000018038623D  F3 0F 58 83 30 41 01 00     addss   xmm0, dword ptr [rbx+14130h]
0000000180386245  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180386249  F3 0F 10 8B B0 41 01 00     movss   xmm1, dword ptr [rbx+141B0h]
0000000180386251  F3 0F 58 8B 00 41 01 00     addss   xmm1, dword ptr [rbx+14100h]
0000000180386259  F3 0F 59 83 40 44 01 00     mulss   xmm0, dword ptr [rbx+14440h]
0000000180386261  F3 0F 59 8B 30 44 01 00     mulss   xmm1, dword ptr [rbx+14430h]
0000000180386269  F3 0F 58 E0                 addss   xmm4, xmm0
000000018038626D  F3 0F 10 83 30 42 01 00     movss   xmm0, dword ptr [rbx+14230h]
0000000180386275  F3 0F 58 83 80 40 01 00     addss   xmm0, dword ptr [rbx+14080h]
000000018038627D  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180386281  F3 0F 10 8B F0 41 01 00     movss   xmm1, dword ptr [rbx+141F0h]
0000000180386289  F3 0F 59 83 20 44 01 00     mulss   xmm0, dword ptr [rbx+14420h]
0000000180386291  F3 0F 58 8B C0 40 01 00     addss   xmm1, dword ptr [rbx+140C0h]
0000000180386299  F3 0F 58 E0                 addss   xmm4, xmm0
000000018038629D  F3 0F 10 83 70 41 01 00     movss   xmm0, dword ptr [rbx+14170h]
00000001803862A5  F3 0F 58 83 40 41 01 00     addss   xmm0, dword ptr [rbx+14140h]
00000001803862AD  F3 0F 59 8B 10 44 01 00     mulss   xmm1, dword ptr [rbx+14410h]
00000001803862B5  F3 0F 59 83 00 44 01 00     mulss   xmm0, dword ptr [rbx+14400h]
00000001803862BD  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803862C1  F3 0F 10 8B C0 41 01 00     movss   xmm1, dword ptr [rbx+141C0h]
00000001803862C9  F3 0F 58 8B F0 40 01 00     addss   xmm1, dword ptr [rbx+140F0h]
00000001803862D1  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803862D5  F3 0F 10 83 40 42 01 00     movss   xmm0, dword ptr [rbx+14240h]
00000001803862DD  F3 0F 59 8B F0 43 01 00     mulss   xmm1, dword ptr [rbx+143F0h]
00000001803862E5  F3 0F 58 83 70 40 01 00     addss   xmm0, dword ptr [rbx+14070h]
00000001803862ED  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803862F1  F3 0F 10 8B E0 41 01 00     movss   xmm1, dword ptr [rbx+141E0h]
00000001803862F9  F3 0F 58 8B D0 40 01 00     addss   xmm1, dword ptr [rbx+140D0h]
0000000180386301  F3 0F 59 83 E0 43 01 00     mulss   xmm0, dword ptr [rbx+143E0h]
0000000180386309  F3 0F 59 8B D0 43 01 00     mulss   xmm1, dword ptr [rbx+143D0h]
0000000180386311  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180386315  F3 0F 10 83 60 41 01 00     movss   xmm0, dword ptr [rbx+14160h]
000000018038631D  F3 0F 58 83 50 41 01 00     addss   xmm0, dword ptr [rbx+14150h]
0000000180386325  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180386329  F3 0F 10 8B D0 41 01 00     movss   xmm1, dword ptr [rbx+141D0h]
0000000180386331  F3 0F 59 83 C0 43 01 00     mulss   xmm0, dword ptr [rbx+143C0h]
0000000180386339  F3 0F 58 8B E0 40 01 00     addss   xmm1, dword ptr [rbx+140E0h]
0000000180386341  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180386345  F3 0F 59 8B B0 43 01 00     mulss   xmm1, dword ptr [rbx+143B0h]
000000018038634D  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180386351  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180386355  F3 0F 59 A3 30 43 01 00     mulss   xmm4, dword ptr [rbx+14330h]
000000018038635D  F3 0F 11 A3 C0 42 01 00     movss   dword ptr [rbx+142C0h], xmm4
0000000180386365  8B 83 C0 44 01 00           mov     eax, [rbx+144C0h]
000000018038636B  89 83 D0 44 01 00           mov     [rbx+144D0h], eax
0000000180386371  F3 0F 10 83 F0 44 01 00     movss   xmm0, dword ptr [rbx+144F0h]
0000000180386379  8B 83 E0 44 01 00           mov     eax, [rbx+144E0h]
000000018038637F  89 83 10 45 01 00           mov     [rbx+14510h], eax
0000000180386385  F3 0F 11 83 20 45 01 00     movss   dword ptr [rbx+14520h], xmm0
000000018038638D  8B 83 00 45 01 00           mov     eax, [rbx+14500h]
0000000180386393  89 83 30 45 01 00           mov     [rbx+14530h], eax
0000000180386399  F3 0F 10 93 40 45 01 00     movss   xmm2, dword ptr [rbx+14540h]
00000001803863A1  F3 0F 11 93 50 45 01 00     movss   dword ptr [rbx+14550h], xmm2
00000001803863A9  F3 0F 10 83 60 45 01 00     movss   xmm0, dword ptr [rbx+14560h]
00000001803863B1  F3 0F 11 83 70 45 01 00     movss   dword ptr [rbx+14570h], xmm0
00000001803863B9  F3 0F 5C D0                 subss   xmm2, xmm0
00000001803863BD  F3 0F 59 93 80 45 01 00     mulss   xmm2, dword ptr [rbx+14580h]
00000001803863C5  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803863C9  F3 0F 11 93 60 45 01 00     movss   dword ptr [rbx+14560h], xmm2
00000001803863D1  F3 0F 10 83 20 45 01 00     movss   xmm0, dword ptr [rbx+14520h]
00000001803863D9  F3 0F 10 8B 30 45 01 00     movss   xmm1, dword ptr [rbx+14530h]
00000001803863E1  F3 0F 59 D0                 mulss   xmm2, xmm0
00000001803863E5  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803863E9  F3 0F 5C D0                 subss   xmm2, xmm0
00000001803863ED  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803863F1  F3 0F 11 93 90 45 01 00     movss   dword ptr [rbx+14590h], xmm2
00000001803863F9  F3 0F 10 8B A0 45 01 00     movss   xmm1, dword ptr [rbx+145A0h]
0000000180386401  F3 0F 11 8B B0 45 01 00     movss   dword ptr [rbx+145B0h], xmm1
0000000180386409  F3 0F 10 83 C0 45 01 00     movss   xmm0, dword ptr [rbx+145C0h]
0000000180386411  0F 28 D8                    movaps  xmm3, xmm0
0000000180386414  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180386418  F3 0F 59 DA                 mulss   xmm3, xmm2
000000018038641C  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180386420  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180386424  41 0F 2F DE                 comiss  xmm3, xmm14
0000000180386428  76 05                       jbe     short loc_18038642F
000000018038642A  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018038642D  EB 03                       jmp     short loc_180386432
000000018038642F  0F 57 C0                    xorps   xmm0, xmm0
0000000180386432  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180386436  F3 0F 11 83 A0 45 01 00     movss   dword ptr [rbx+145A0h], xmm0
000000018038643E  F3 0F 10 8B D0 45 01 00     movss   xmm1, dword ptr [rbx+145D0h]
0000000180386446  F3 0F 11 8B E0 45 01 00     movss   dword ptr [rbx+145E0h], xmm1
000000018038644E  F3 0F 10 93 F0 45 01 00     movss   xmm2, dword ptr [rbx+145F0h]
0000000180386456  F3 0F 11 93 00 46 01 00     movss   dword ptr [rbx+14600h], xmm2
000000018038645E  F3 0F 10 83 10 46 01 00     movss   xmm0, dword ptr [rbx+14610h]
0000000180386466  0F 28 D8                    movaps  xmm3, xmm0
0000000180386469  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038646D  F3 0F 59 D9                 mulss   xmm3, xmm1
0000000180386471  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180386475  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180386479  41 0F 2F DE                 comiss  xmm3, xmm14
000000018038647D  76 05                       jbe     short loc_180386484
000000018038647F  0F 5A C3                    cvtps2pd xmm0, xmm3
0000000180386482  EB 03                       jmp     short loc_180386487
0000000180386484  0F 57 C0                    xorps   xmm0, xmm0
0000000180386487  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018038648B  F3 0F 11 83 F0 45 01 00     movss   dword ptr [rbx+145F0h], xmm0
0000000180386493  F3 0F 10 AB 20 46 01 00     movss   xmm5, dword ptr [rbx+14620h]
000000018038649B  F3 0F 10 B3 A0 21 01 00     movss   xmm6, dword ptr [rbx+121A0h]
00000001803864A3  0F 28 E5                    movaps  xmm4, xmm5
00000001803864A6  F3 0F 11 AB 30 46 01 00     movss   dword ptr [rbx+14630h], xmm5
00000001803864AE  0F 28 C5                    movaps  xmm0, xmm5
00000001803864B1  F3 0F 59 A3 80 46 01 00     mulss   xmm4, dword ptr [rbx+14680h]
00000001803864B9  0F 28 DD                    movaps  xmm3, xmm5
00000001803864BC  F3 0F 58 83 50 46 01 00     addss   xmm0, dword ptr [rbx+14650h]
00000001803864C4  F3 0F 58 9B 70 46 01 00     addss   xmm3, dword ptr [rbx+14670h]
00000001803864CC  41 0F 2F E7                 comiss  xmm4, xmm15
00000001803864D0  73 06                       jnb     short loc_1803864D8
00000001803864D2  41 0F 28 E7                 movaps  xmm4, xmm15
00000001803864D6  EB 05                       jmp     short loc_1803864DD
00000001803864D8  F3 41 0F 5D E5              minss   xmm4, xmm13
00000001803864DD  41 0F 2F C6                 comiss  xmm0, xmm14
00000001803864E1  72 1B                       jb      short loc_1803864FE
00000001803864E3  F3 0F 10 83 60 46 01 00     movss   xmm0, dword ptr [rbx+14660h]
00000001803864EB  0F 28 D8                    movaps  xmm3, xmm0
00000001803864EE  F3 0F 59 C5                 mulss   xmm0, xmm5
00000001803864F2  F3 0F 59 DE                 mulss   xmm3, xmm6
00000001803864F6  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803864FA  F3 0F 58 DD                 addss   xmm3, xmm5
00000001803864FE  41 0F 2E F6                 ucomiss xmm6, xmm14
0000000180386502  F3 0F 10 8B A0 46 01 00     movss   xmm1, dword ptr [rbx+146A0h]
000000018038650A  0F 28 D4                    movaps  xmm2, xmm4
000000018038650D  F3 0F 59 93 90 46 01 00     mulss   xmm2, dword ptr [rbx+14690h]
0000000180386515  0F 28 C1                    movaps  xmm0, xmm1
0000000180386518  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018038651C  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180386520  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180386524  0F 28 C2                    movaps  xmm0, xmm2
0000000180386527  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018038652B  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018038652F  F3 0F 5C C2                 subss   xmm0, xmm2
0000000180386533  F3 0F 58 C5                 addss   xmm0, xmm5
0000000180386537  74 03                       jz      short loc_18038653C
0000000180386539  0F 28 C3                    movaps  xmm0, xmm3
000000018038653C  F3 0F 11 83 40 46 01 00     movss   dword ptr [rbx+14640h], xmm0
0000000180386544  F3 0F 11 83 20 46 01 00     movss   dword ptr [rbx+14620h], xmm0
000000018038654C  F3 0F 10 BB C0 42 01 00     movss   xmm7, dword ptr [rbx+142C0h]
0000000180386554  F3 0F 10 B3 30 2A 01 00     movss   xmm6, dword ptr [rbx+12A30h]
000000018038655C  F3 0F 10 9B 30 3A 01 00     movss   xmm3, dword ptr [rbx+13A30h]
0000000180386564  F3 0F 10 83 10 2C 01 00     movss   xmm0, dword ptr [rbx+12C10h]
000000018038656C  F3 0F 10 8B C0 44 01 00     movss   xmm1, dword ptr [rbx+144C0h]
0000000180386574  8B 83 E0 46 01 00           mov     eax, [rbx+146E0h]
000000018038657A  89 83 F0 46 01 00           mov     [rbx+146F0h], eax
0000000180386580  8B 83 00 47 01 00           mov     eax, [rbx+14700h]
0000000180386586  89 83 10 47 01 00           mov     [rbx+14710h], eax
000000018038658C  F3 0F 11 83 B0 46 01 00     movss   dword ptr [rbx+146B0h], xmm0
0000000180386594  F3 0F 11 8B C0 46 01 00     movss   dword ptr [rbx+146C0h], xmm1
000000018038659C  F3 0F 59 9B D0 47 01 00     mulss   xmm3, dword ptr [rbx+147D0h]
00000001803865A4  F3 0F 10 A3 F0 46 01 00     movss   xmm4, dword ptr [rbx+146F0h]
00000001803865AC  F3 0F 10 93 30 47 01 00     movss   xmm2, dword ptr [rbx+14730h]
00000001803865B4  F3 0F 11 9B D0 46 01 00     movss   dword ptr [rbx+146D0h], xmm3
00000001803865BC  0F 28 DF                    movaps  xmm3, xmm7
00000001803865BF  F3 0F 59 B3 40 47 01 00     mulss   xmm6, dword ptr [rbx+14740h]
00000001803865C7  F3 0F 5C DC                 subss   xmm3, xmm4
00000001803865CB  F3 0F 59 93 40 46 01 00     mulss   xmm2, dword ptr [rbx+14640h]
00000001803865D3  F3 0F 10 8B 50 47 01 00     movss   xmm1, dword ptr [rbx+14750h]
00000001803865DB  0F 28 C3                    movaps  xmm0, xmm3
00000001803865DE  F3 0F 59 83 70 47 01 00     mulss   xmm0, dword ptr [rbx+14770h]
00000001803865E6  F3 0F 58 F2                 addss   xmm6, xmm2
00000001803865EA  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803865EE  41 0F 28 C5                 movaps  xmm0, xmm13
00000001803865F2  F3 0F 11 A3 E0 46 01 00     movss   dword ptr [rbx+146E0h], xmm4
00000001803865FA  F3 0F 59 8B B0 46 01 00     mulss   xmm1, dword ptr [rbx+146B0h]
0000000180386602  F3 0F 10 93 60 47 01 00     movss   xmm2, dword ptr [rbx+14760h]
000000018038660A  F3 0F 59 9B E0 47 01 00     mulss   xmm3, dword ptr [rbx+147E0h]
0000000180386612  F3 0F 59 A3 F0 47 01 00     mulss   xmm4, dword ptr [rbx+147F0h]
000000018038661A  F3 0F 58 F1                 addss   xmm6, xmm1
000000018038661E  0F 28 CA                    movaps  xmm1, xmm2
0000000180386621  F3 0F 59 8B C0 46 01 00     mulss   xmm1, dword ptr [rbx+146C0h]
0000000180386629  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018038662D  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180386631  F3 0F 5C CA                 subss   xmm1, xmm2
0000000180386635  F3 0F 58 CE                 addss   xmm1, xmm6
0000000180386639  F3 0F 10 B3 80 47 01 00     movss   xmm6, dword ptr [rbx+14780h]
0000000180386641  F3 0F 5C C6                 subss   xmm0, xmm6
0000000180386645  F3 0F 59 8B B0 47 01 00     mulss   xmm1, dword ptr [rbx+147B0h]
000000018038664D  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180386651  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180386655  76 05                       jbe     short loc_18038665C
0000000180386657  0F 5A C1                    cvtps2pd xmm0, xmm1
000000018038665A  EB 03                       jmp     short loc_18038665F
000000018038665C  0F 57 C0                    xorps   xmm0, xmm0
000000018038665F  F3 0F 10 93 A0 47 01 00     movss   xmm2, dword ptr [rbx+147A0h]
0000000180386667  F3 0F 10 A3 90 47 01 00     movss   xmm4, dword ptr [rbx+14790h]
000000018038666F  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
0000000180386673  F3 0F 10 83 D0 46 01 00     movss   xmm0, dword ptr [rbx+146D0h]
000000018038667B  F3 0F 59 AB C0 47 01 00     mulss   xmm5, dword ptr [rbx+147C0h]
0000000180386683  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180386688  F3 0F 59 F3                 mulss   xmm6, xmm3
000000018038668C  F3 0F 10 9B 10 47 01 00     movss   xmm3, dword ptr [rbx+14710h]
0000000180386694  F3 0F 58 F7                 addss   xmm6, xmm7
0000000180386698  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018038669C  F3 0F 10 83 00 48 01 00     movss   xmm0, dword ptr [rbx+14800h]
00000001803866A4  0F 28 C8                    movaps  xmm1, xmm0
00000001803866A7  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803866AB  F3 0F 59 CE                 mulss   xmm1, xmm6
00000001803866AF  F3 0F 59 D6                 mulss   xmm2, xmm6
00000001803866B3  F3 0F 5C C8                 subss   xmm1, xmm0
00000001803866B7  F3 0F 58 D9                 addss   xmm3, xmm1
00000001803866BB  F3 0F 11 9B 00 47 01 00     movss   dword ptr [rbx+14700h], xmm3
00000001803866C3  F3 0F 59 E3                 mulss   xmm4, xmm3
00000001803866C7  F3 0F 58 E2                 addss   xmm4, xmm2
00000001803866CB  F3 0F 59 E5                 mulss   xmm4, xmm5
00000001803866CF  F3 0F 59 A3 10 48 01 00     mulss   xmm4, dword ptr [rbx+14810h]
00000001803866D7  F3 0F 11 A3 20 47 01 00     movss   dword ptr [rbx+14720h], xmm4
00000001803866DF  8B 83 30 48 01 00           mov     eax, [rbx+14830h]
00000001803866E5  89 83 40 48 01 00           mov     [rbx+14840h], eax
00000001803866EB  8B 83 20 48 01 00           mov     eax, [rbx+14820h]
00000001803866F1  89 83 30 48 01 00           mov     [rbx+14830h], eax
00000001803866F7  F3 0F 10 83 40 48 01 00     movss   xmm0, dword ptr [rbx+14840h]
00000001803866FF  F3 0F 10 8B 50 48 01 00     movss   xmm1, dword ptr [rbx+14850h]
0000000180386707  F3 0F 5C E0                 subss   xmm4, xmm0
000000018038670B  F3 0F 11 A3 20 48 01 00     movss   dword ptr [rbx+14820h], xmm4
0000000180386713  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180386717  F3 0F 58 C8                 addss   xmm1, xmm0
000000018038671B  F3 0F 11 8B 30 48 01 00     movss   dword ptr [rbx+14830h], xmm1
0000000180386723  F3 0F 10 93 20 48 01 00     movss   xmm2, dword ptr [rbx+14820h]
000000018038672B  F3 0F 10 B3 10 45 01 00     movss   xmm6, dword ptr [rbx+14510h]
0000000180386733  0F 28 C2                    movaps  xmm0, xmm2
0000000180386736  41 0F 2F F6                 comiss  xmm6, xmm14
000000018038673A  8B 83 80 48 01 00           mov     eax, [rbx+14880h]
0000000180386740  89 83 90 48 01 00           mov     [rbx+14890h], eax
0000000180386746  8B 83 70 48 01 00           mov     eax, [rbx+14870h]
000000018038674C  89 83 80 48 01 00           mov     [rbx+14880h], eax
0000000180386752  8B 83 60 48 01 00           mov     eax, [rbx+14860h]
0000000180386758  89 83 70 48 01 00           mov     [rbx+14870h], eax
000000018038675E  F3 0F 11 93 60 48 01 00     movss   dword ptr [rbx+14860h], xmm2
0000000180386766  F3 0F 59 83 B0 48 01 00     mulss   xmm0, dword ptr [rbx+148B0h]
000000018038676E  F3 0F 10 A3 70 48 01 00     movss   xmm4, dword ptr [rbx+14870h]
0000000180386776  F3 0F 10 8B D0 48 01 00     movss   xmm1, dword ptr [rbx+148D0h]
000000018038677E  0F 28 EC                    movaps  xmm5, xmm4
0000000180386781  F3 0F 59 8B 80 48 01 00     mulss   xmm1, dword ptr [rbx+14880h]
0000000180386789  F3 0F 59 AB C0 48 01 00     mulss   xmm5, dword ptr [rbx+148C0h]
0000000180386791  F3 0F 59 A3 F0 48 01 00     mulss   xmm4, dword ptr [rbx+148F0h]
0000000180386799  F3 0F 58 E8                 addss   xmm5, xmm0
000000018038679D  0F 28 C2                    movaps  xmm0, xmm2
00000001803867A0  F3 0F 59 83 E0 48 01 00     mulss   xmm0, dword ptr [rbx+148E0h]
00000001803867A8  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803867AC  F3 0F 10 8B 00 49 01 00     movss   xmm1, dword ptr [rbx+14900h]
00000001803867B4  F3 0F 59 8B 90 48 01 00     mulss   xmm1, dword ptr [rbx+14890h]
00000001803867BC  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803867C0  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803867C4  76 05                       jbe     short loc_1803867CB
00000001803867C6  0F 5A C6                    cvtps2pd xmm0, xmm6
00000001803867C9  EB 03                       jmp     short loc_1803867CE
00000001803867CB  0F 57 C0                    xorps   xmm0, xmm0
00000001803867CE  0F 2F 35 EB EC 75 00        comiss  xmm6, cs:dword_180AE54C0
00000001803867D5  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00000001803867D9  F3 0F 11 AB 70 48 01 00     movss   dword ptr [rbx+14870h], xmm5
00000001803867E1  0F 28 D8                    movaps  xmm3, xmm0
00000001803867E4  F3 0F 11 A3 80 48 01 00     movss   dword ptr [rbx+14880h], xmm4
00000001803867EC  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803867F0  F3 0F 59 DD                 mulss   xmm3, xmm5
00000001803867F4  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803867F8  0F 28 C6                    movaps  xmm0, xmm6
00000001803867FB  41 0F 57 C3                 xorps   xmm0, xmm11
00000001803867FF  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180386803  73 09                       jnb     short loc_18038680E
0000000180386805  45 0F 57 D2                 xorps   xmm10, xmm10
0000000180386809  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
000000018038680E  41 0F 2F F6                 comiss  xmm6, xmm14
0000000180386812  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
0000000180386817  0F 28 C8                    movaps  xmm1, xmm0
000000018038681A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038681E  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180386822  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180386826  F3 0F 58 D1                 addss   xmm2, xmm1
000000018038682A  72 03                       jb      short loc_18038682F
000000018038682C  0F 28 D3                    movaps  xmm2, xmm3
000000018038682F  F3 0F 11 93 A0 48 01 00     movss   dword ptr [rbx+148A0h], xmm2
0000000180386837  F3 0F 59 93 A0 45 01 00     mulss   xmm2, dword ptr [rbx+145A0h]
000000018038683F  F3 0F 11 93 10 49 01 00     movss   dword ptr [rbx+14910h], xmm2
0000000180386847  F3 0F 59 93 F0 45 01 00     mulss   xmm2, dword ptr [rbx+145F0h]
000000018038684F  F3 0F 11 93 20 49 01 00     movss   dword ptr [rbx+14920h], xmm2
0000000180386857  F3 0F 10 83 D0 30 01 00     movss   xmm0, dword ptr [rbx+130D0h]
000000018038685F  F3 0F 58 83 30 2E 01 00     addss   xmm0, dword ptr [rbx+12E30h]
0000000180386867  44 0F 5A E0                 cvtps2pd xmm12, xmm0
000000018038686B  F2 44 0F 5F 25 34 44 60 00  maxsd   xmm12, cs:qword_18098ACA8
0000000180386874  F2 44 0F 5D 25 13 44 60 00  minsd   xmm12, cs:qword_18098AC90
000000018038687D  41 0F 28 CC                 movaps  xmm1, xmm12
0000000180386881  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180386885  F2 0F 58 05 DB E9 75 00     addsd   xmm0, cs:qword_180AE5268
000000018038688D  F2 41 0F 59 CC              mulsd   xmm1, xmm12
0000000180386892  41 0F 28 FC                 movaps  xmm7, xmm12
0000000180386896  F2 0F 2C C0                 cvttsd2si eax, xmm0
000000018038689A  0F 28 D1                    movaps  xmm2, xmm1
000000018038689D  48 63 C8                    movsxd  rcx, eax
00000001803868A0  F2 41 0F 59 D4              mulsd   xmm2, xmm12
00000001803868A5  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
00000001803868AC  0F 28 DA                    movaps  xmm3, xmm2
00000001803868AF  F2 41 0F 59 DC              mulsd   xmm3, xmm12
00000001803868B4  48 8D 0D 25 2C 60 00        lea     rcx, unk_1809894E0
00000001803868BB  48 03 C1                    add     rax, rcx
00000001803868BE  0F 28 E3                    movaps  xmm4, xmm3
00000001803868C1  F2 41 0F 59 E4              mulsd   xmm4, xmm12
00000001803868C6  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
00000001803868CB  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
00000001803868D0  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
00000001803868D5  0F 28 EC                    movaps  xmm5, xmm4
00000001803868D8  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
00000001803868DC  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
00000001803868E1  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
00000001803868E6  F2 0F 58 F9                 addsd   xmm7, xmm1
00000001803868EA  F2 41 0F 59 EC              mulsd   xmm5, xmm12
00000001803868EF  F2 0F 58 FA                 addsd   xmm7, xmm2
00000001803868F3  0F 28 F5                    movaps  xmm6, xmm5
00000001803868F6  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
00000001803868FB  F2 41 0F 59 F4              mulsd   xmm6, xmm12
0000000180386900  F2 0F 58 FB                 addsd   xmm7, xmm3
0000000180386904  44 0F 28 C6                 movaps  xmm8, xmm6
0000000180386908  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
000000018038690D  F2 0F 58 FC                 addsd   xmm7, xmm4
0000000180386911  F2 45 0F 59 C4              mulsd   xmm8, xmm12
0000000180386916  F2 0F 58 FD                 addsd   xmm7, xmm5
000000018038691A  45 0F 28 C8                 movaps  xmm9, xmm8
000000018038691E  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
0000000180386927  F2 45 0F 59 CC              mulsd   xmm9, xmm12
000000018038692C  F2 0F 58 FE                 addsd   xmm7, xmm6
0000000180386930  45 0F 28 D1                 movaps  xmm10, xmm9
0000000180386934  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
000000018038693D  F2 41 0F 58 F8              addsd   xmm7, xmm8
0000000180386942  F2 45 0F 59 D4              mulsd   xmm10, xmm12
0000000180386947  F2 41 0F 58 F9              addsd   xmm7, xmm9
000000018038694C  45 0F 28 DA                 movaps  xmm11, xmm10
0000000180386950  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
0000000180386959  F2 45 0F 59 DC              mulsd   xmm11, xmm12
000000018038695E  F2 41 0F 58 FA              addsd   xmm7, xmm10
0000000180386963  41 0F 28 C3                 movaps  xmm0, xmm11
0000000180386967  F2 45 0F 59 DC              mulsd   xmm11, xmm12
000000018038696C  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
0000000180386974  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
000000018038697D  F2 0F 58 F8                 addsd   xmm7, xmm0
0000000180386981  F2 41 0F 58 FB              addsd   xmm7, xmm11
0000000180386986  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
000000018038698A  F3 0F 5D 1D 06 43 60 00     minss   xmm3, cs:dword_18098AC98
0000000180386992  F3 0F 5F 1D 16 43 60 00     maxss   xmm3, cs:dword_18098ACB0
000000018038699A  F3 0F 59 9B 40 2E 01 00     mulss   xmm3, dword ptr [rbx+12E40h]
00000001803869A2  F3 0F 11 9B B0 30 01 00     movss   dword ptr [rbx+130B0h], xmm3
00000001803869AA  8B 83 50 32 01 00           mov     eax, [rbx+13250h]
00000001803869B0  F3 0F 10 AB 30 2E 01 00     movss   xmm5, dword ptr [rbx+12E30h]
00000001803869B8  F3 0F 10 83 00 30 01 00     movss   xmm0, dword ptr [rbx+13000h]
00000001803869C0  F3 0F 10 8B 10 30 01 00     movss   xmm1, dword ptr [rbx+13010h]
00000001803869C8  F3 0F 10 93 20 30 01 00     movss   xmm2, dword ptr [rbx+13020h]
00000001803869D0  89 83 60 32 01 00           mov     [rbx+13260h], eax
00000001803869D6  8B 83 70 32 01 00           mov     eax, [rbx+13270h]
00000001803869DC  89 83 80 32 01 00           mov     [rbx+13280h], eax
00000001803869E2  8B 83 20 33 01 00           mov     eax, [rbx+13320h]
00000001803869E8  89 83 30 33 01 00           mov     [rbx+13330h], eax
00000001803869EE  8B 83 10 33 01 00           mov     eax, [rbx+13310h]
00000001803869F4  89 83 20 33 01 00           mov     [rbx+13320h], eax
00000001803869FA  8B 83 00 33 01 00           mov     eax, [rbx+13300h]
0000000180386A00  89 83 10 33 01 00           mov     [rbx+13310h], eax
0000000180386A06  8B 83 F0 32 01 00           mov     eax, [rbx+132F0h]
0000000180386A0C  89 83 00 33 01 00           mov     [rbx+13300h], eax
0000000180386A12  8B 83 E0 32 01 00           mov     eax, [rbx+132E0h]
0000000180386A18  89 83 F0 32 01 00           mov     [rbx+132F0h], eax
0000000180386A1E  8B 83 D0 32 01 00           mov     eax, [rbx+132D0h]
0000000180386A24  89 83 E0 32 01 00           mov     [rbx+132E0h], eax
0000000180386A2A  8B 83 C0 32 01 00           mov     eax, [rbx+132C0h]
0000000180386A30  89 83 D0 32 01 00           mov     [rbx+132D0h], eax
0000000180386A36  8B 83 A0 33 01 00           mov     eax, [rbx+133A0h]
0000000180386A3C  89 83 B0 33 01 00           mov     [rbx+133B0h], eax
0000000180386A42  8B 83 90 33 01 00           mov     eax, [rbx+13390h]
0000000180386A48  89 83 A0 33 01 00           mov     [rbx+133A0h], eax
0000000180386A4E  8B 83 80 33 01 00           mov     eax, [rbx+13380h]
0000000180386A54  89 83 90 33 01 00           mov     [rbx+13390h], eax
0000000180386A5A  8B 83 70 33 01 00           mov     eax, [rbx+13370h]
0000000180386A60  89 83 80 33 01 00           mov     [rbx+13380h], eax
0000000180386A66  8B 83 60 33 01 00           mov     eax, [rbx+13360h]
0000000180386A6C  89 83 70 33 01 00           mov     [rbx+13370h], eax
0000000180386A72  8B 83 50 33 01 00           mov     eax, [rbx+13350h]
0000000180386A78  89 83 60 33 01 00           mov     [rbx+13360h], eax
0000000180386A7E  8B 83 40 33 01 00           mov     eax, [rbx+13340h]
0000000180386A84  89 83 50 33 01 00           mov     [rbx+13350h], eax
0000000180386A8A  8B 83 20 34 01 00           mov     eax, [rbx+13420h]
0000000180386A90  89 83 30 34 01 00           mov     [rbx+13430h], eax
0000000180386A96  8B 83 10 34 01 00           mov     eax, [rbx+13410h]
0000000180386A9C  89 83 20 34 01 00           mov     [rbx+13420h], eax
0000000180386AA2  8B 83 00 34 01 00           mov     eax, [rbx+13400h]
0000000180386AA8  89 83 10 34 01 00           mov     [rbx+13410h], eax
0000000180386AAE  8B 83 F0 33 01 00           mov     eax, [rbx+133F0h]
0000000180386AB4  89 83 00 34 01 00           mov     [rbx+13400h], eax
0000000180386ABA  8B 83 E0 33 01 00           mov     eax, [rbx+133E0h]
0000000180386AC0  89 83 F0 33 01 00           mov     [rbx+133F0h], eax
0000000180386AC6  8B 83 D0 33 01 00           mov     eax, [rbx+133D0h]
0000000180386ACC  89 83 E0 33 01 00           mov     [rbx+133E0h], eax
0000000180386AD2  8B 83 C0 33 01 00           mov     eax, [rbx+133C0h]
0000000180386AD8  89 83 D0 33 01 00           mov     [rbx+133D0h], eax
0000000180386ADE  8B 83 A0 34 01 00           mov     eax, [rbx+134A0h]
0000000180386AE4  89 83 B0 34 01 00           mov     [rbx+134B0h], eax
0000000180386AEA  8B 83 90 34 01 00           mov     eax, [rbx+13490h]
0000000180386AF0  89 83 A0 34 01 00           mov     [rbx+134A0h], eax
0000000180386AF6  8B 83 80 34 01 00           mov     eax, [rbx+13480h]
0000000180386AFC  89 83 90 34 01 00           mov     [rbx+13490h], eax
0000000180386B02  8B 83 70 34 01 00           mov     eax, [rbx+13470h]
0000000180386B08  89 83 80 34 01 00           mov     [rbx+13480h], eax
0000000180386B0E  8B 83 60 34 01 00           mov     eax, [rbx+13460h]
0000000180386B14  89 83 70 34 01 00           mov     [rbx+13470h], eax
0000000180386B1A  8B 83 50 34 01 00           mov     eax, [rbx+13450h]
0000000180386B20  89 83 60 34 01 00           mov     [rbx+13460h], eax
0000000180386B26  8B 83 40 34 01 00           mov     eax, [rbx+13440h]
0000000180386B2C  89 83 50 34 01 00           mov     [rbx+13450h], eax
0000000180386B32  8B 83 E0 34 01 00           mov     eax, [rbx+134E0h]
0000000180386B38  89 83 F0 34 01 00           mov     [rbx+134F0h], eax
0000000180386B3E  8B 83 D0 34 01 00           mov     eax, [rbx+134D0h]
0000000180386B44  89 83 E0 34 01 00           mov     [rbx+134E0h], eax
0000000180386B4A  F3 0F 11 83 F0 31 01 00     movss   dword ptr [rbx+131F0h], xmm0
0000000180386B52  F3 0F 11 8B 00 32 01 00     movss   dword ptr [rbx+13200h], xmm1
0000000180386B5A  F3 0F 58 AB 10 38 01 00     addss   xmm5, dword ptr [rbx+13810h]
0000000180386B62  F3 0F 59 9B 10 35 01 00     mulss   xmm3, dword ptr [rbx+13510h]
0000000180386B6A  F3 0F 10 83 00 35 01 00     movss   xmm0, dword ptr [rbx+13500h]
0000000180386B72  F3 0F 11 93 10 32 01 00     movss   dword ptr [rbx+13210h], xmm2
0000000180386B7A  F3 0F 10 93 30 35 01 00     movss   xmm2, dword ptr [rbx+13530h]
0000000180386B82  F3 0F 59 AB 20 38 01 00     mulss   xmm5, dword ptr [rbx+13820h]
0000000180386B8A  F3 0F 5F D3                 maxss   xmm2, xmm3
0000000180386B8E  F3 0F 58 AB 00 38 01 00     addss   xmm5, dword ptr [rbx+13800h]
0000000180386B96  F3 0F 11 93 20 32 01 00     movss   dword ptr [rbx+13220h], xmm2
0000000180386B9E  F3 0F 58 83 50 2E 01 00     addss   xmm0, dword ptr [rbx+12E50h]
0000000180386BA6  41 0F 2F EE                 comiss  xmm5, xmm14
0000000180386BAA  F3 0F 11 83 40 32 01 00     movss   dword ptr [rbx+13240h], xmm0
0000000180386BB2  76 05                       jbe     short loc_180386BB9
0000000180386BB4  0F 5A C5                    cvtps2pd xmm0, xmm5
0000000180386BB7  EB 03                       jmp     short loc_180386BBC
0000000180386BB9  0F 57 C0                    xorps   xmm0, xmm0
0000000180386BBC  F3 0F 10 0D 98 E3 75 00     movss   xmm1, cs:dword_180AE4F5C
0000000180386BC4  F3 44 0F 10 15 1B E6 75 00  movss   xmm10, cs:flt_180AE51E8
0000000180386BCD  F3 0F 5E CA                 divss   xmm1, xmm2
0000000180386BD1  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180386BD5  F3 0F 11 8B 30 32 01 00     movss   dword ptr [rbx+13230h], xmm1
0000000180386BDD  F3 0F 11 83 C0 34 01 00     movss   dword ptr [rbx+134C0h], xmm0
0000000180386BE5  F3 0F 10 B3 80 32 01 00     movss   xmm6, dword ptr [rbx+13280h]
0000000180386BED  F3 0F 10 8B 60 32 01 00     movss   xmm1, dword ptr [rbx+13260h]
0000000180386BF5  F3 0F 11 B3 A0 31 01 00     movss   dword ptr [rbx+131A0h], xmm6
0000000180386BFD  F3 0F 58 F2                 addss   xmm6, xmm2
0000000180386C01  F3 0F 11 8B B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm1
0000000180386C09  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180386C0D  76 1B                       jbe     short loc_180386C2A
0000000180386C0F  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180386C14  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180386C18  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180386C1B  E8 B8 88 36 00              call    fmodf
0000000180386C20  0F 28 F0                    movaps  xmm6, xmm0
0000000180386C23  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180386C28  EB 1F                       jmp     short loc_180386C49
0000000180386C2A  41 0F 2F F7                 comiss  xmm6, xmm15
0000000180386C2E  73 19                       jnb     short loc_180386C49
0000000180386C30  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180386C35  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180386C39  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180386C3C  E8 97 88 36 00              call    fmodf
0000000180386C41  0F 28 F0                    movaps  xmm6, xmm0
0000000180386C44  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180386C49  F3 44 0F 10 25 BA E3 75 00  movss   xmm12, cs:dword_180AE500C
0000000180386C52  0F 28 C6                    movaps  xmm0, xmm6
0000000180386C55  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180386C5A  F3 0F 11 B3 90 31 01 00     movss   dword ptr [rbx+13190h], xmm6
0000000180386C62  0F 28 FE                    movaps  xmm7, xmm6
0000000180386C65  F3 0F 59 BB 80 35 01 00     mulss   xmm7, dword ptr [rbx+13580h]
0000000180386C6D  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180386C72  E8 49 23 FE FF              call    sub_180368FC0
0000000180386C77  F3 44 0F 10 1D C4 E7 75 00  movss   xmm11, cs:dword_180AE5444
0000000180386C80  0F 28 E8                    movaps  xmm5, xmm0
0000000180386C83  F3 41 0F 59 EB              mulss   xmm5, xmm11
0000000180386C88  F3 0F 59 AB 30 32 01 00     mulss   xmm5, dword ptr [rbx+13230h]
0000000180386C90  F3 0F 59 AB 50 35 01 00     mulss   xmm5, dword ptr [rbx+13550h]
0000000180386C98  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180386C9C  73 06                       jnb     short loc_180386CA4
0000000180386C9E  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180386CA2  EB 05                       jmp     short loc_180386CA9
0000000180386CA4  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180386CA9  F3 0F 59 AB 20 35 01 00     mulss   xmm5, dword ptr [rbx+13520h]
0000000180386CB1  0F 28 D5                    movaps  xmm2, xmm5
0000000180386CB4  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180386CB8  0F 28 CA                    movaps  xmm1, xmm2
0000000180386CBB  0F 28 C2                    movaps  xmm0, xmm2
0000000180386CBE  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
0000000180386CC6  0F 28 DA                    movaps  xmm3, xmm2
0000000180386CC9  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180386CCD  0F 28 E2                    movaps  xmm4, xmm2
0000000180386CD0  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
0000000180386CD8  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
0000000180386CE0  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180386CE4  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
0000000180386CEC  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180386CF0  0F 28 C3                    movaps  xmm0, xmm3
0000000180386CF3  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
0000000180386CFB  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180386CFF  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180386D03  F3 0F 10 8B 40 32 01 00     movss   xmm1, dword ptr [rbx+13240h]
0000000180386D0B  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180386D0F  0F 28 C1                    movaps  xmm0, xmm1
0000000180386D12  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180386D16  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180386D1A  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180386D1E  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180386D22  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180386D26  F3 0F 11 A3 90 32 01 00     movss   dword ptr [rbx+13290h], xmm4
0000000180386D2E  72 07                       jb      short loc_180386D37
0000000180386D30  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180386D35  EB 05                       jmp     short loc_180386D3C
0000000180386D37  F3 41 0F 5C CD              subss   xmm1, xmm13
0000000180386D3C  0F 28 F0                    movaps  xmm6, xmm0
0000000180386D3F  73 06                       jnb     short loc_180386D47
0000000180386D41  41 0F 28 F7                 movaps  xmm6, xmm15
0000000180386D45  EB 06                       jmp     short loc_180386D4D
0000000180386D47  76 04                       jbe     short loc_180386D4D
0000000180386D49  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180386D4D  F3 44 0F 10 83 90 31 01 00  movss   xmm8, dword ptr [rbx+13190h]
0000000180386D56  F3 0F 59 B3 90 35 01 00     mulss   xmm6, dword ptr [rbx+13590h]
0000000180386D5E  F3 0F 5E C1                 divss   xmm0, xmm1
0000000180386D62  E8 59 22 FE FF              call    sub_180368FC0
0000000180386D67  0F 28 E0                    movaps  xmm4, xmm0
0000000180386D6A  F3 0F 10 83 40 35 01 00     movss   xmm0, dword ptr [rbx+13540h]
0000000180386D72  44 0F 2F C0                 comiss  xmm8, xmm0
0000000180386D76  72 18                       jb      short loc_180386D90
0000000180386D78  0F 2F 83 A0 31 01 00        comiss  xmm0, dword ptr [rbx+131A0h]
0000000180386D7F  76 0F                       jbe     short loc_180386D90
0000000180386D81  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
0000000180386D89  F3 41 0F 58 FA              addss   xmm7, xmm10
0000000180386D8E  EB 08                       jmp     short loc_180386D98
0000000180386D90  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
0000000180386D98  0F 2F 3D 31 E5 75 00        comiss  xmm7, cs:dword_180AE52D0
0000000180386D9F  F3 0F 59 A3 30 32 01 00     mulss   xmm4, dword ptr [rbx+13230h]
0000000180386DA7  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180386DAC  F3 0F 59 A3 60 35 01 00     mulss   xmm4, dword ptr [rbx+13560h]
0000000180386DB4  72 03                       jb      short loc_180386DB9
0000000180386DB6  0F 57 FF                    xorps   xmm7, xmm7
0000000180386DB9  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180386DBD  73 06                       jnb     short loc_180386DC5
0000000180386DBF  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180386DC3  EB 05                       jmp     short loc_180386DCA
0000000180386DC5  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180386DCA  F3 0F 11 BB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm7
0000000180386DD2  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180386DD7  F3 0F 59 A3 20 35 01 00     mulss   xmm4, dword ptr [rbx+13520h]
0000000180386DDF  0F 28 D4                    movaps  xmm2, xmm4
0000000180386DE2  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180386DE7  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180386DEB  0F 28 C2                    movaps  xmm0, xmm2
0000000180386DEE  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180386DF3  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180386DF7  0F 28 DA                    movaps  xmm3, xmm2
0000000180386DFA  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180386DFE  44 0F 28 CA                 movaps  xmm9, xmm2
0000000180386E02  F3 44 0F 59 8B F0 36 01 00  mulss   xmm9, dword ptr [rbx+136F0h]
0000000180386E0B  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180386E10  0F 28 CA                    movaps  xmm1, xmm2
0000000180386E13  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
0000000180386E1B  F3 44 0F 58 8B E0 36 01 00  addss   xmm9, dword ptr [rbx+136E0h]
0000000180386E24  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
0000000180386E2C  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180386E31  0F 28 C3                    movaps  xmm0, xmm3
0000000180386E34  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
0000000180386E3C  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180386E41  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180386E45  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180386E4A  0F 28 C7                    movaps  xmm0, xmm7
0000000180386E4D  0F 54 05 3C E9 75 00        andps   xmm0, cs:xmmword_180AE5790
0000000180386E54  0F 57 05 65 E9 75 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180386E5B  F3 44 0F 58 CB              addss   xmm9, xmm3
0000000180386E60  F3 44 0F 58 CC              addss   xmm9, xmm4
0000000180386E65  F3 44 0F 59 CE              mulss   xmm9, xmm6
0000000180386E6A  F3 44 0F 11 8B A0 32 01 00  movss   dword ptr [rbx+132A0h], xmm9
0000000180386E73  E8 48 21 FE FF              call    sub_180368FC0
0000000180386E78  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180386E7C  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180386E80  F3 45 0F 58 C5              addss   xmm8, xmm13
0000000180386E85  73 06                       jnb     short loc_180386E8D
0000000180386E87  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180386E8B  EB 06                       jmp     short loc_180386E93
0000000180386E8D  76 04                       jbe     short loc_180386E93
0000000180386E8F  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180386E93  F3 44 0F 59 83 30 32 01 00  mulss   xmm8, dword ptr [rbx+13230h]
0000000180386E9C  F3 0F 59 BB A0 35 01 00     mulss   xmm7, dword ptr [rbx+135A0h]
0000000180386EA4  F3 44 0F 59 05 EB 3D 60 00  mulss   xmm8, cs:dword_18098AC98
0000000180386EAD  F3 44 0F 59 83 70 35 01 00  mulss   xmm8, dword ptr [rbx+13570h]
0000000180386EB6  45 0F 2F C7                 comiss  xmm8, xmm15
0000000180386EBA  73 06                       jnb     short loc_180386EC2
0000000180386EBC  45 0F 28 C7                 movaps  xmm8, xmm15
0000000180386EC0  EB 05                       jmp     short loc_180386EC7
0000000180386EC2  F3 45 0F 5D C5              minss   xmm8, xmm13
0000000180386EC7  F3 44 0F 59 83 20 35 01 00  mulss   xmm8, dword ptr [rbx+13520h]
0000000180386ED0  F3 44 0F 59 8B 00 32 01 00  mulss   xmm9, dword ptr [rbx+13200h]
0000000180386ED9  F3 0F 10 B3 90 31 01 00     movss   xmm6, dword ptr [rbx+13190h]
0000000180386EE1  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180386EE5  F3 0F 10 AB B0 31 01 00     movss   xmm5, dword ptr [rbx+131B0h]
0000000180386EED  F3 41 0F 59 D0              mulss   xmm2, xmm8
0000000180386EF2  0F 28 C2                    movaps  xmm0, xmm2
0000000180386EF5  0F 28 DA                    movaps  xmm3, xmm2
0000000180386EF8  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180386EFC  0F 28 E2                    movaps  xmm4, xmm2
0000000180386EFF  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
0000000180386F07  0F 28 CA                    movaps  xmm1, xmm2
0000000180386F0A  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
0000000180386F12  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
0000000180386F1A  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180386F1F  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
0000000180386F27  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180386F2B  0F 28 C3                    movaps  xmm0, xmm3
0000000180386F2E  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
0000000180386F36  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180386F3A  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180386F3E  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180386F42  F3 0F 10 83 90 32 01 00     movss   xmm0, dword ptr [rbx+13290h]
0000000180386F4A  F3 0F 59 83 F0 31 01 00     mulss   xmm0, dword ptr [rbx+131F0h]
0000000180386F52  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180386F56  F3 41 0F 58 C1              addss   xmm0, xmm9
0000000180386F5B  F3 41 0F 58 E0              addss   xmm4, xmm8
0000000180386F60  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180386F64  F3 0F 59 A3 10 32 01 00     mulss   xmm4, dword ptr [rbx+13210h]
0000000180386F6C  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180386F70  F3 0F 11 A3 C0 32 01 00     movss   dword ptr [rbx+132C0h], xmm4
0000000180386F78  F3 0F 11 B3 A0 31 01 00     movss   dword ptr [rbx+131A0h], xmm6
0000000180386F80  F3 0F 11 AB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm5
0000000180386F88  F3 0F 58 B3 20 32 01 00     addss   xmm6, dword ptr [rbx+13220h]
0000000180386F90  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180386F94  76 1B                       jbe     short loc_180386FB1
0000000180386F96  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180386F9B  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180386F9F  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180386FA2  E8 31 85 36 00              call    fmodf
0000000180386FA7  0F 28 F0                    movaps  xmm6, xmm0
0000000180386FAA  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180386FAF  EB 1F                       jmp     short loc_180386FD0
0000000180386FB1  41 0F 2F F7                 comiss  xmm6, xmm15
0000000180386FB5  73 19                       jnb     short loc_180386FD0
0000000180386FB7  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180386FBC  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180386FC0  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180386FC3  E8 10 85 36 00              call    fmodf
0000000180386FC8  0F 28 F0                    movaps  xmm6, xmm0
0000000180386FCB  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180386FD0  0F 28 C6                    movaps  xmm0, xmm6
0000000180386FD3  F3 0F 11 B3 90 31 01 00     movss   dword ptr [rbx+13190h], xmm6
0000000180386FDB  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180386FE0  0F 28 FE                    movaps  xmm7, xmm6
0000000180386FE3  F3 0F 59 BB 80 35 01 00     mulss   xmm7, dword ptr [rbx+13580h]
0000000180386FEB  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180386FF0  E8 CB 1F FE FF              call    sub_180368FC0
0000000180386FF5  0F 28 E8                    movaps  xmm5, xmm0
0000000180386FF8  F3 41 0F 59 EB              mulss   xmm5, xmm11
0000000180386FFD  F3 0F 59 AB 30 32 01 00     mulss   xmm5, dword ptr [rbx+13230h]
0000000180387005  F3 0F 59 AB 50 35 01 00     mulss   xmm5, dword ptr [rbx+13550h]
000000018038700D  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180387011  73 06                       jnb     short loc_180387019
0000000180387013  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180387017  EB 05                       jmp     short loc_18038701E
0000000180387019  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018038701E  F3 0F 59 AB 20 35 01 00     mulss   xmm5, dword ptr [rbx+13520h]
0000000180387026  0F 28 D5                    movaps  xmm2, xmm5
0000000180387029  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018038702D  0F 28 CA                    movaps  xmm1, xmm2
0000000180387030  0F 28 C2                    movaps  xmm0, xmm2
0000000180387033  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
000000018038703B  0F 28 DA                    movaps  xmm3, xmm2
000000018038703E  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180387042  0F 28 E2                    movaps  xmm4, xmm2
0000000180387045  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
000000018038704D  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
0000000180387055  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180387059  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
0000000180387061  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180387065  0F 28 C3                    movaps  xmm0, xmm3
0000000180387068  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
0000000180387070  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180387074  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180387078  F3 0F 10 8B 40 32 01 00     movss   xmm1, dword ptr [rbx+13240h]
0000000180387080  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180387084  0F 28 C1                    movaps  xmm0, xmm1
0000000180387087  F3 0F 58 C6                 addss   xmm0, xmm6
000000018038708B  F3 0F 58 E3                 addss   xmm4, xmm3
000000018038708F  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180387093  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180387097  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018038709B  F3 0F 11 A3 90 32 01 00     movss   dword ptr [rbx+13290h], xmm4
00000001803870A3  72 07                       jb      short loc_1803870AC
00000001803870A5  F3 41 0F 58 CD              addss   xmm1, xmm13
00000001803870AA  EB 05                       jmp     short loc_1803870B1
00000001803870AC  F3 41 0F 5C CD              subss   xmm1, xmm13
00000001803870B1  0F 28 F0                    movaps  xmm6, xmm0
00000001803870B4  73 06                       jnb     short loc_1803870BC
00000001803870B6  41 0F 28 F7                 movaps  xmm6, xmm15
00000001803870BA  EB 06                       jmp     short loc_1803870C2
00000001803870BC  76 04                       jbe     short loc_1803870C2
00000001803870BE  41 0F 28 F5                 movaps  xmm6, xmm13
00000001803870C2  F3 44 0F 10 83 90 31 01 00  movss   xmm8, dword ptr [rbx+13190h]
00000001803870CB  F3 0F 59 B3 90 35 01 00     mulss   xmm6, dword ptr [rbx+13590h]
00000001803870D3  F3 0F 5E C1                 divss   xmm0, xmm1
00000001803870D7  E8 E4 1E FE FF              call    sub_180368FC0
00000001803870DC  0F 28 E0                    movaps  xmm4, xmm0
00000001803870DF  F3 0F 10 83 40 35 01 00     movss   xmm0, dword ptr [rbx+13540h]
00000001803870E7  44 0F 2F C0                 comiss  xmm8, xmm0
00000001803870EB  72 18                       jb      short loc_180387105
00000001803870ED  0F 2F 83 A0 31 01 00        comiss  xmm0, dword ptr [rbx+131A0h]
00000001803870F4  76 0F                       jbe     short loc_180387105
00000001803870F6  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
00000001803870FE  F3 41 0F 58 FA              addss   xmm7, xmm10
0000000180387103  EB 08                       jmp     short loc_18038710D
0000000180387105  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
000000018038710D  0F 2F 3D BC E1 75 00        comiss  xmm7, cs:dword_180AE52D0
0000000180387114  F3 0F 59 A3 30 32 01 00     mulss   xmm4, dword ptr [rbx+13230h]
000000018038711C  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180387121  F3 0F 59 A3 60 35 01 00     mulss   xmm4, dword ptr [rbx+13560h]
0000000180387129  72 03                       jb      short loc_18038712E
000000018038712B  0F 57 FF                    xorps   xmm7, xmm7
000000018038712E  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180387132  73 06                       jnb     short loc_18038713A
0000000180387134  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180387138  EB 05                       jmp     short loc_18038713F
000000018038713A  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018038713F  F3 0F 11 BB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm7
0000000180387147  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018038714C  F3 0F 59 A3 20 35 01 00     mulss   xmm4, dword ptr [rbx+13520h]
0000000180387154  0F 28 D4                    movaps  xmm2, xmm4
0000000180387157  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018038715C  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180387160  0F 28 C2                    movaps  xmm0, xmm2
0000000180387163  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180387168  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038716C  0F 28 DA                    movaps  xmm3, xmm2
000000018038716F  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180387173  44 0F 28 CA                 movaps  xmm9, xmm2
0000000180387177  F3 44 0F 59 8B F0 36 01 00  mulss   xmm9, dword ptr [rbx+136F0h]
0000000180387180  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180387185  0F 28 CA                    movaps  xmm1, xmm2
0000000180387188  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
0000000180387190  F3 44 0F 58 8B E0 36 01 00  addss   xmm9, dword ptr [rbx+136E0h]
0000000180387199  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00000001803871A1  F3 44 0F 59 C8              mulss   xmm9, xmm0
00000001803871A6  0F 28 C3                    movaps  xmm0, xmm3
00000001803871A9  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00000001803871B1  F3 44 0F 58 C9              addss   xmm9, xmm1
00000001803871B6  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803871BA  F3 44 0F 59 C8              mulss   xmm9, xmm0
00000001803871BF  0F 28 C7                    movaps  xmm0, xmm7
00000001803871C2  0F 54 05 C7 E5 75 00        andps   xmm0, cs:xmmword_180AE5790
00000001803871C9  0F 57 05 F0 E5 75 00        xorps   xmm0, cs:xmmword_180AE57C0
00000001803871D0  F3 44 0F 58 CB              addss   xmm9, xmm3
00000001803871D5  F3 44 0F 58 CC              addss   xmm9, xmm4
00000001803871DA  F3 44 0F 59 CE              mulss   xmm9, xmm6
00000001803871DF  F3 44 0F 11 8B A0 32 01 00  movss   dword ptr [rbx+132A0h], xmm9
00000001803871E8  E8 D3 1D FE FF              call    sub_180368FC0
00000001803871ED  41 0F 2F FE                 comiss  xmm7, xmm14
00000001803871F1  44 0F 28 C0                 movaps  xmm8, xmm0
00000001803871F5  F3 45 0F 58 C5              addss   xmm8, xmm13
00000001803871FA  73 06                       jnb     short loc_180387202
00000001803871FC  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180387200  EB 06                       jmp     short loc_180387208
0000000180387202  76 04                       jbe     short loc_180387208
0000000180387204  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180387208  F3 44 0F 59 83 30 32 01 00  mulss   xmm8, dword ptr [rbx+13230h]
0000000180387211  F3 0F 59 BB A0 35 01 00     mulss   xmm7, dword ptr [rbx+135A0h]
0000000180387219  F3 44 0F 59 05 76 3A 60 00  mulss   xmm8, cs:dword_18098AC98
0000000180387222  F3 44 0F 59 83 70 35 01 00  mulss   xmm8, dword ptr [rbx+13570h]
000000018038722B  45 0F 2F C7                 comiss  xmm8, xmm15
000000018038722F  73 06                       jnb     short loc_180387237
0000000180387231  45 0F 28 C7                 movaps  xmm8, xmm15
0000000180387235  EB 05                       jmp     short loc_18038723C
0000000180387237  F3 45 0F 5D C5              minss   xmm8, xmm13
000000018038723C  F3 44 0F 59 83 20 35 01 00  mulss   xmm8, dword ptr [rbx+13520h]
0000000180387245  F3 44 0F 59 8B 00 32 01 00  mulss   xmm9, dword ptr [rbx+13200h]
000000018038724E  F3 0F 10 B3 90 31 01 00     movss   xmm6, dword ptr [rbx+13190h]
0000000180387256  41 0F 28 D0                 movaps  xmm2, xmm8
000000018038725A  F3 0F 10 AB B0 31 01 00     movss   xmm5, dword ptr [rbx+131B0h]
0000000180387262  F3 41 0F 59 D0              mulss   xmm2, xmm8
0000000180387267  0F 28 C2                    movaps  xmm0, xmm2
000000018038726A  0F 28 DA                    movaps  xmm3, xmm2
000000018038726D  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180387271  0F 28 E2                    movaps  xmm4, xmm2
0000000180387274  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
000000018038727C  0F 28 CA                    movaps  xmm1, xmm2
000000018038727F  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
0000000180387287  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
000000018038728F  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180387294  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
000000018038729C  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803872A0  0F 28 C3                    movaps  xmm0, xmm3
00000001803872A3  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00000001803872AB  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803872AF  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803872B3  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803872B7  F3 0F 10 83 90 32 01 00     movss   xmm0, dword ptr [rbx+13290h]
00000001803872BF  F3 0F 59 83 F0 31 01 00     mulss   xmm0, dword ptr [rbx+131F0h]
00000001803872C7  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803872CB  F3 41 0F 58 C1              addss   xmm0, xmm9
00000001803872D0  F3 41 0F 58 E0              addss   xmm4, xmm8
00000001803872D5  F3 0F 59 E7                 mulss   xmm4, xmm7
00000001803872D9  F3 0F 59 A3 10 32 01 00     mulss   xmm4, dword ptr [rbx+13210h]
00000001803872E1  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803872E5  F3 0F 11 A3 40 33 01 00     movss   dword ptr [rbx+13340h], xmm4
00000001803872ED  F3 0F 11 B3 A0 31 01 00     movss   dword ptr [rbx+131A0h], xmm6
00000001803872F5  F3 0F 11 AB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm5
00000001803872FD  F3 0F 58 B3 20 32 01 00     addss   xmm6, dword ptr [rbx+13220h]
0000000180387305  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180387309  76 1B                       jbe     short loc_180387326
000000018038730B  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180387310  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180387314  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180387317  E8 BC 81 36 00              call    fmodf
000000018038731C  0F 28 F0                    movaps  xmm6, xmm0
000000018038731F  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180387324  EB 1F                       jmp     short loc_180387345
0000000180387326  41 0F 2F F7                 comiss  xmm6, xmm15
000000018038732A  73 19                       jnb     short loc_180387345
000000018038732C  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180387331  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180387335  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180387338  E8 9B 81 36 00              call    fmodf
000000018038733D  0F 28 F0                    movaps  xmm6, xmm0
0000000180387340  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180387345  0F 28 C6                    movaps  xmm0, xmm6
0000000180387348  F3 0F 11 B3 90 31 01 00     movss   dword ptr [rbx+13190h], xmm6
0000000180387350  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180387355  0F 28 FE                    movaps  xmm7, xmm6
0000000180387358  F3 0F 59 BB 80 35 01 00     mulss   xmm7, dword ptr [rbx+13580h]
0000000180387360  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180387365  E8 56 1C FE FF              call    sub_180368FC0
000000018038736A  0F 28 E8                    movaps  xmm5, xmm0
000000018038736D  F3 41 0F 59 EB              mulss   xmm5, xmm11
0000000180387372  F3 0F 59 AB 30 32 01 00     mulss   xmm5, dword ptr [rbx+13230h]
000000018038737A  F3 0F 59 AB 50 35 01 00     mulss   xmm5, dword ptr [rbx+13550h]
0000000180387382  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180387386  73 06                       jnb     short loc_18038738E
0000000180387388  41 0F 28 EF                 movaps  xmm5, xmm15
000000018038738C  EB 05                       jmp     short loc_180387393
000000018038738E  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180387393  F3 0F 59 AB 20 35 01 00     mulss   xmm5, dword ptr [rbx+13520h]
000000018038739B  0F 28 D5                    movaps  xmm2, xmm5
000000018038739E  F3 0F 59 D5                 mulss   xmm2, xmm5
00000001803873A2  0F 28 CA                    movaps  xmm1, xmm2
00000001803873A5  0F 28 C2                    movaps  xmm0, xmm2
00000001803873A8  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00000001803873B0  0F 28 DA                    movaps  xmm3, xmm2
00000001803873B3  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803873B7  0F 28 E2                    movaps  xmm4, xmm2
00000001803873BA  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
00000001803873C2  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00000001803873CA  F3 0F 59 DD                 mulss   xmm3, xmm5
00000001803873CE  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
00000001803873D6  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803873DA  0F 28 C3                    movaps  xmm0, xmm3
00000001803873DD  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00000001803873E5  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803873E9  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803873ED  F3 0F 10 8B 40 32 01 00     movss   xmm1, dword ptr [rbx+13240h]
00000001803873F5  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803873F9  0F 28 C1                    movaps  xmm0, xmm1
00000001803873FC  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180387400  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180387404  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180387408  F3 0F 58 E5                 addss   xmm4, xmm5
000000018038740C  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180387410  F3 0F 11 A3 90 32 01 00     movss   dword ptr [rbx+13290h], xmm4
0000000180387418  72 07                       jb      short loc_180387421
000000018038741A  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018038741F  EB 05                       jmp     short loc_180387426
0000000180387421  F3 41 0F 5C CD              subss   xmm1, xmm13
0000000180387426  0F 28 F0                    movaps  xmm6, xmm0
0000000180387429  73 06                       jnb     short loc_180387431
000000018038742B  41 0F 28 F7                 movaps  xmm6, xmm15
000000018038742F  EB 06                       jmp     short loc_180387437
0000000180387431  76 04                       jbe     short loc_180387437
0000000180387433  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180387437  F3 44 0F 10 83 90 31 01 00  movss   xmm8, dword ptr [rbx+13190h]
0000000180387440  F3 0F 59 B3 90 35 01 00     mulss   xmm6, dword ptr [rbx+13590h]
0000000180387448  F3 0F 5E C1                 divss   xmm0, xmm1
000000018038744C  E8 6F 1B FE FF              call    sub_180368FC0
0000000180387451  0F 28 E0                    movaps  xmm4, xmm0
0000000180387454  F3 0F 10 83 40 35 01 00     movss   xmm0, dword ptr [rbx+13540h]
000000018038745C  44 0F 2F C0                 comiss  xmm8, xmm0
0000000180387460  72 18                       jb      short loc_18038747A
0000000180387462  0F 2F 83 A0 31 01 00        comiss  xmm0, dword ptr [rbx+131A0h]
0000000180387469  76 0F                       jbe     short loc_18038747A
000000018038746B  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
0000000180387473  F3 41 0F 58 FA              addss   xmm7, xmm10
0000000180387478  EB 08                       jmp     short loc_180387482
000000018038747A  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
0000000180387482  0F 2F 3D 47 DE 75 00        comiss  xmm7, cs:dword_180AE52D0
0000000180387489  F3 0F 59 A3 30 32 01 00     mulss   xmm4, dword ptr [rbx+13230h]
0000000180387491  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180387496  F3 0F 59 A3 60 35 01 00     mulss   xmm4, dword ptr [rbx+13560h]
000000018038749E  72 03                       jb      short loc_1803874A3
00000001803874A0  0F 57 FF                    xorps   xmm7, xmm7
00000001803874A3  41 0F 2F E7                 comiss  xmm4, xmm15
00000001803874A7  73 06                       jnb     short loc_1803874AF
00000001803874A9  41 0F 28 E7                 movaps  xmm4, xmm15
00000001803874AD  EB 05                       jmp     short loc_1803874B4
00000001803874AF  F3 41 0F 5D E5              minss   xmm4, xmm13
00000001803874B4  F3 0F 11 BB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm7
00000001803874BC  F3 41 0F 58 F8              addss   xmm7, xmm8
00000001803874C1  F3 0F 59 A3 20 35 01 00     mulss   xmm4, dword ptr [rbx+13520h]
00000001803874C9  0F 28 D4                    movaps  xmm2, xmm4
00000001803874CC  F3 41 0F 58 FD              addss   xmm7, xmm13
00000001803874D1  F3 0F 59 D4                 mulss   xmm2, xmm4
00000001803874D5  0F 28 C2                    movaps  xmm0, xmm2
00000001803874D8  F3 41 0F 59 FC              mulss   xmm7, xmm12
00000001803874DD  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803874E1  0F 28 DA                    movaps  xmm3, xmm2
00000001803874E4  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803874E8  44 0F 28 CA                 movaps  xmm9, xmm2
00000001803874EC  F3 44 0F 59 8B F0 36 01 00  mulss   xmm9, dword ptr [rbx+136F0h]
00000001803874F5  F3 41 0F 5C FD              subss   xmm7, xmm13
00000001803874FA  0F 28 CA                    movaps  xmm1, xmm2
00000001803874FD  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
0000000180387505  F3 44 0F 58 8B E0 36 01 00  addss   xmm9, dword ptr [rbx+136E0h]
000000018038750E  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
0000000180387516  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018038751B  0F 28 C3                    movaps  xmm0, xmm3
000000018038751E  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
0000000180387526  F3 44 0F 58 C9              addss   xmm9, xmm1
000000018038752B  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038752F  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180387534  0F 28 C7                    movaps  xmm0, xmm7
0000000180387537  0F 54 05 52 E2 75 00        andps   xmm0, cs:xmmword_180AE5790
000000018038753E  0F 57 05 7B E2 75 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180387545  F3 44 0F 58 CB              addss   xmm9, xmm3
000000018038754A  F3 44 0F 58 CC              addss   xmm9, xmm4
000000018038754F  F3 44 0F 59 CE              mulss   xmm9, xmm6
0000000180387554  F3 44 0F 11 8B A0 32 01 00  movss   dword ptr [rbx+132A0h], xmm9
000000018038755D  E8 5E 1A FE FF              call    sub_180368FC0
0000000180387562  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180387566  44 0F 28 C0                 movaps  xmm8, xmm0
000000018038756A  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018038756F  73 06                       jnb     short loc_180387577
0000000180387571  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180387575  EB 06                       jmp     short loc_18038757D
0000000180387577  76 04                       jbe     short loc_18038757D
0000000180387579  41 0F 28 FD                 movaps  xmm7, xmm13
000000018038757D  F3 44 0F 59 83 30 32 01 00  mulss   xmm8, dword ptr [rbx+13230h]
0000000180387586  F3 0F 59 BB A0 35 01 00     mulss   xmm7, dword ptr [rbx+135A0h]
000000018038758E  F3 44 0F 59 05 01 37 60 00  mulss   xmm8, cs:dword_18098AC98
0000000180387597  F3 44 0F 59 83 70 35 01 00  mulss   xmm8, dword ptr [rbx+13570h]
00000001803875A0  45 0F 2F C7                 comiss  xmm8, xmm15
00000001803875A4  73 06                       jnb     short loc_1803875AC
00000001803875A6  45 0F 28 C7                 movaps  xmm8, xmm15
00000001803875AA  EB 05                       jmp     short loc_1803875B1
00000001803875AC  F3 45 0F 5D C5              minss   xmm8, xmm13
00000001803875B1  F3 44 0F 59 83 20 35 01 00  mulss   xmm8, dword ptr [rbx+13520h]
00000001803875BA  F3 44 0F 59 8B 00 32 01 00  mulss   xmm9, dword ptr [rbx+13200h]
00000001803875C3  F3 0F 10 B3 90 31 01 00     movss   xmm6, dword ptr [rbx+13190h]
00000001803875CB  41 0F 28 D0                 movaps  xmm2, xmm8
00000001803875CF  F3 0F 10 AB B0 31 01 00     movss   xmm5, dword ptr [rbx+131B0h]
00000001803875D7  F3 41 0F 59 D0              mulss   xmm2, xmm8
00000001803875DC  0F 28 C2                    movaps  xmm0, xmm2
00000001803875DF  0F 28 DA                    movaps  xmm3, xmm2
00000001803875E2  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803875E6  0F 28 E2                    movaps  xmm4, xmm2
00000001803875E9  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
00000001803875F1  0F 28 CA                    movaps  xmm1, xmm2
00000001803875F4  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00000001803875FC  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
0000000180387604  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180387609  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
0000000180387611  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180387615  0F 28 C3                    movaps  xmm0, xmm3
0000000180387618  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
0000000180387620  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180387624  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180387628  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018038762C  F3 0F 10 83 90 32 01 00     movss   xmm0, dword ptr [rbx+13290h]
0000000180387634  F3 0F 59 83 F0 31 01 00     mulss   xmm0, dword ptr [rbx+131F0h]
000000018038763C  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180387640  F3 41 0F 58 C1              addss   xmm0, xmm9
0000000180387645  F3 41 0F 58 E0              addss   xmm4, xmm8
000000018038764A  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018038764E  F3 0F 59 A3 10 32 01 00     mulss   xmm4, dword ptr [rbx+13210h]
0000000180387656  F3 0F 58 E0                 addss   xmm4, xmm0
000000018038765A  F3 0F 11 A3 C0 33 01 00     movss   dword ptr [rbx+133C0h], xmm4
0000000180387662  F3 0F 11 B3 A0 31 01 00     movss   dword ptr [rbx+131A0h], xmm6
000000018038766A  F3 0F 11 AB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm5
0000000180387672  F3 0F 58 B3 20 32 01 00     addss   xmm6, dword ptr [rbx+13220h]
000000018038767A  41 0F 2F F5                 comiss  xmm6, xmm13
000000018038767E  76 1B                       jbe     short loc_18038769B
0000000180387680  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180387685  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180387689  0F 28 C6                    movaps  xmm0, xmm6; X
000000018038768C  E8 47 7E 36 00              call    fmodf
0000000180387691  0F 28 F0                    movaps  xmm6, xmm0
0000000180387694  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180387699  EB 1F                       jmp     short loc_1803876BA
000000018038769B  41 0F 2F F7                 comiss  xmm6, xmm15
000000018038769F  73 19                       jnb     short loc_1803876BA
00000001803876A1  F3 41 0F 5C F5              subss   xmm6, xmm13
00000001803876A6  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00000001803876AA  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803876AD  E8 26 7E 36 00              call    fmodf
00000001803876B2  0F 28 F0                    movaps  xmm6, xmm0
00000001803876B5  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803876BA  0F 28 C6                    movaps  xmm0, xmm6
00000001803876BD  F3 0F 11 B3 90 31 01 00     movss   dword ptr [rbx+13190h], xmm6
00000001803876C5  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803876CA  0F 28 FE                    movaps  xmm7, xmm6
00000001803876CD  F3 0F 59 BB 80 35 01 00     mulss   xmm7, dword ptr [rbx+13580h]
00000001803876D5  F3 41 0F 59 C4              mulss   xmm0, xmm12
00000001803876DA  E8 E1 18 FE FF              call    sub_180368FC0
00000001803876DF  0F 28 E8                    movaps  xmm5, xmm0
00000001803876E2  F3 41 0F 59 EB              mulss   xmm5, xmm11
00000001803876E7  F3 0F 59 AB 30 32 01 00     mulss   xmm5, dword ptr [rbx+13230h]
00000001803876EF  F3 0F 59 AB 50 35 01 00     mulss   xmm5, dword ptr [rbx+13550h]
00000001803876F7  41 0F 2F EF                 comiss  xmm5, xmm15
00000001803876FB  73 06                       jnb     short loc_180387703
00000001803876FD  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180387701  EB 05                       jmp     short loc_180387708
0000000180387703  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180387708  F3 0F 59 AB 20 35 01 00     mulss   xmm5, dword ptr [rbx+13520h]
0000000180387710  0F 28 D5                    movaps  xmm2, xmm5
0000000180387713  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180387717  0F 28 CA                    movaps  xmm1, xmm2
000000018038771A  0F 28 C2                    movaps  xmm0, xmm2
000000018038771D  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
0000000180387725  0F 28 DA                    movaps  xmm3, xmm2
0000000180387728  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038772C  0F 28 E2                    movaps  xmm4, xmm2
000000018038772F  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
0000000180387737  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
000000018038773F  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180387743  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
000000018038774B  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018038774F  0F 28 C3                    movaps  xmm0, xmm3
0000000180387752  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
000000018038775A  F3 0F 58 E1                 addss   xmm4, xmm1
000000018038775E  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180387762  F3 0F 10 8B 40 32 01 00     movss   xmm1, dword ptr [rbx+13240h]
000000018038776A  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018038776E  0F 28 C1                    movaps  xmm0, xmm1
0000000180387771  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180387775  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180387779  41 0F 2F C6                 comiss  xmm0, xmm14
000000018038777D  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180387781  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180387785  F3 0F 11 A3 90 32 01 00     movss   dword ptr [rbx+13290h], xmm4
000000018038778D  72 07                       jb      short loc_180387796
000000018038778F  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180387794  EB 05                       jmp     short loc_18038779B
0000000180387796  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018038779B  0F 28 F0                    movaps  xmm6, xmm0
000000018038779E  73 06                       jnb     short loc_1803877A6
00000001803877A0  41 0F 28 F7                 movaps  xmm6, xmm15
00000001803877A4  EB 06                       jmp     short loc_1803877AC
00000001803877A6  76 04                       jbe     short loc_1803877AC
00000001803877A8  41 0F 28 F5                 movaps  xmm6, xmm13
00000001803877AC  F3 44 0F 10 83 90 31 01 00  movss   xmm8, dword ptr [rbx+13190h]
00000001803877B5  F3 0F 59 B3 90 35 01 00     mulss   xmm6, dword ptr [rbx+13590h]
00000001803877BD  F3 0F 5E C1                 divss   xmm0, xmm1
00000001803877C1  E8 FA 17 FE FF              call    sub_180368FC0
00000001803877C6  0F 28 E0                    movaps  xmm4, xmm0
00000001803877C9  F3 0F 10 83 40 35 01 00     movss   xmm0, dword ptr [rbx+13540h]
00000001803877D1  44 0F 2F C0                 comiss  xmm8, xmm0
00000001803877D5  72 18                       jb      short loc_1803877EF
00000001803877D7  0F 2F 83 A0 31 01 00        comiss  xmm0, dword ptr [rbx+131A0h]
00000001803877DE  76 0F                       jbe     short loc_1803877EF
00000001803877E0  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
00000001803877E8  F3 41 0F 58 FA              addss   xmm7, xmm10
00000001803877ED  EB 08                       jmp     short loc_1803877F7
00000001803877EF  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
00000001803877F7  0F 2F 3D D2 DA 75 00        comiss  xmm7, cs:dword_180AE52D0
00000001803877FE  F3 0F 59 A3 30 32 01 00     mulss   xmm4, dword ptr [rbx+13230h]
0000000180387806  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018038780B  F3 0F 59 A3 60 35 01 00     mulss   xmm4, dword ptr [rbx+13560h]
0000000180387813  72 03                       jb      short loc_180387818
0000000180387815  0F 57 FF                    xorps   xmm7, xmm7
0000000180387818  41 0F 2F E7                 comiss  xmm4, xmm15
000000018038781C  73 06                       jnb     short loc_180387824
000000018038781E  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180387822  EB 05                       jmp     short loc_180387829
0000000180387824  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180387829  F3 0F 11 BB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm7
0000000180387831  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180387836  F3 0F 59 A3 20 35 01 00     mulss   xmm4, dword ptr [rbx+13520h]
000000018038783E  0F 28 D4                    movaps  xmm2, xmm4
0000000180387841  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180387846  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018038784A  0F 28 C2                    movaps  xmm0, xmm2
000000018038784D  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180387852  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180387856  0F 28 DA                    movaps  xmm3, xmm2
0000000180387859  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018038785D  44 0F 28 C2                 movaps  xmm8, xmm2
0000000180387861  F3 44 0F 59 83 F0 36 01 00  mulss   xmm8, dword ptr [rbx+136F0h]
000000018038786A  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018038786F  0F 28 CA                    movaps  xmm1, xmm2
0000000180387872  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
000000018038787A  F3 44 0F 58 83 E0 36 01 00  addss   xmm8, dword ptr [rbx+136E0h]
0000000180387883  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
000000018038788B  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180387890  0F 28 C3                    movaps  xmm0, xmm3
0000000180387893  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
000000018038789B  F3 44 0F 58 C1              addss   xmm8, xmm1
00000001803878A0  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803878A4  F3 44 0F 59 C0              mulss   xmm8, xmm0
00000001803878A9  0F 28 C7                    movaps  xmm0, xmm7
00000001803878AC  0F 54 05 DD DE 75 00        andps   xmm0, cs:xmmword_180AE5790
00000001803878B3  0F 57 05 06 DF 75 00        xorps   xmm0, cs:xmmword_180AE57C0
00000001803878BA  F3 44 0F 58 C3              addss   xmm8, xmm3
00000001803878BF  F3 44 0F 58 C4              addss   xmm8, xmm4
00000001803878C4  F3 44 0F 59 C6              mulss   xmm8, xmm6
00000001803878C9  F3 44 0F 11 83 A0 32 01 00  movss   dword ptr [rbx+132A0h], xmm8
00000001803878D2  E8 E9 16 FE FF              call    sub_180368FC0
00000001803878D7  41 0F 2F FE                 comiss  xmm7, xmm14
00000001803878DB  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803878E0  73 06                       jnb     short loc_1803878E8
00000001803878E2  41 0F 28 FF                 movaps  xmm7, xmm15
00000001803878E6  EB 06                       jmp     short loc_1803878EE
00000001803878E8  76 04                       jbe     short loc_1803878EE
00000001803878EA  41 0F 28 FD                 movaps  xmm7, xmm13
00000001803878EE  F3 0F 59 83 30 32 01 00     mulss   xmm0, dword ptr [rbx+13230h]
00000001803878F6  F3 0F 59 BB A0 35 01 00     mulss   xmm7, dword ptr [rbx+135A0h]
00000001803878FE  F3 0F 59 05 92 33 60 00     mulss   xmm0, cs:dword_18098AC98
0000000180387906  F3 0F 59 83 70 35 01 00     mulss   xmm0, dword ptr [rbx+13570h]
000000018038790E  41 0F 2F C7                 comiss  xmm0, xmm15
0000000180387912  72 09                       jb      short loc_18038791D
0000000180387914  44 0F 28 F8                 movaps  xmm15, xmm0
0000000180387918  F3 45 0F 5D FD              minss   xmm15, xmm13
000000018038791D  F3 44 0F 59 BB 20 35 01 00  mulss   xmm15, dword ptr [rbx+13520h]
0000000180387926  F3 44 0F 59 83 00 32 01 00  mulss   xmm8, dword ptr [rbx+13200h]
000000018038792F  F3 0F 10 AB 90 31 01 00     movss   xmm5, dword ptr [rbx+13190h]
0000000180387937  41 0F 28 D7                 movaps  xmm2, xmm15
000000018038793B  F3 0F 10 B3 B0 31 01 00     movss   xmm6, dword ptr [rbx+131B0h]
0000000180387943  F3 41 0F 59 D7              mulss   xmm2, xmm15
0000000180387948  0F 28 CA                    movaps  xmm1, xmm2
000000018038794B  0F 28 C2                    movaps  xmm0, xmm2
000000018038794E  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
0000000180387956  0F 28 DA                    movaps  xmm3, xmm2
0000000180387959  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038795D  0F 28 E2                    movaps  xmm4, xmm2
0000000180387960  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
0000000180387968  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
0000000180387970  F3 41 0F 59 DF              mulss   xmm3, xmm15
0000000180387975  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
000000018038797D  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180387981  0F 28 C3                    movaps  xmm0, xmm3
0000000180387984  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
000000018038798C  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180387990  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180387994  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180387998  F3 0F 10 83 90 32 01 00     movss   xmm0, dword ptr [rbx+13290h]
00000001803879A0  F3 0F 59 83 F0 31 01 00     mulss   xmm0, dword ptr [rbx+131F0h]
00000001803879A8  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803879AC  F3 41 0F 58 C0              addss   xmm0, xmm8
00000001803879B1  F3 41 0F 58 E7              addss   xmm4, xmm15
00000001803879B6  F3 0F 59 E7                 mulss   xmm4, xmm7
00000001803879BA  F3 0F 59 A3 10 32 01 00     mulss   xmm4, dword ptr [rbx+13210h]
00000001803879C2  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803879C6  F3 0F 11 A3 40 34 01 00     movss   dword ptr [rbx+13440h], xmm4
00000001803879CE  F3 0F 10 93 B0 34 01 00     movss   xmm2, dword ptr [rbx+134B0h]
00000001803879D6  F3 0F 11 AB 70 32 01 00     movss   dword ptr [rbx+13270h], xmm5
00000001803879DE  F3 0F 11 B3 50 32 01 00     movss   dword ptr [rbx+13250h], xmm6
00000001803879E6  F3 0F 10 83 C0 33 01 00     movss   xmm0, dword ptr [rbx+133C0h]
00000001803879EE  F3 0F 58 83 B0 33 01 00     addss   xmm0, dword ptr [rbx+133B0h]
00000001803879F6  F3 0F 10 8B 40 34 01 00     movss   xmm1, dword ptr [rbx+13440h]
00000001803879FE  F3 0F 58 8B 30 33 01 00     addss   xmm1, dword ptr [rbx+13330h]
0000000180387A06  F3 0F 10 AB 30 34 01 00     movss   xmm5, dword ptr [rbx+13430h]
0000000180387A0E  F3 0F 58 AB 40 33 01 00     addss   xmm5, dword ptr [rbx+13340h]
0000000180387A16  F3 0F 59 83 D0 35 01 00     mulss   xmm0, dword ptr [rbx+135D0h]
0000000180387A1E  F3 0F 59 8B E0 35 01 00     mulss   xmm1, dword ptr [rbx+135E0h]
0000000180387A26  F3 0F 59 AB C0 35 01 00     mulss   xmm5, dword ptr [rbx+135C0h]
0000000180387A2E  F3 0F 58 93 C0 32 01 00     addss   xmm2, dword ptr [rbx+132C0h]
0000000180387A36  F3 0F 59 93 B0 35 01 00     mulss   xmm2, dword ptr [rbx+135B0h]
0000000180387A3E  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180387A42  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180387A46  F3 0F 10 83 A0 34 01 00     movss   xmm0, dword ptr [rbx+134A0h]
0000000180387A4E  F3 0F 58 83 D0 32 01 00     addss   xmm0, dword ptr [rbx+132D0h]
0000000180387A56  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180387A5A  F3 0F 10 8B 20 34 01 00     movss   xmm1, dword ptr [rbx+13420h]
0000000180387A62  F3 0F 59 83 F0 35 01 00     mulss   xmm0, dword ptr [rbx+135F0h]
0000000180387A6A  F3 0F 58 8B 50 33 01 00     addss   xmm1, dword ptr [rbx+13350h]
0000000180387A72  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180387A76  F3 0F 10 83 D0 33 01 00     movss   xmm0, dword ptr [rbx+133D0h]
0000000180387A7E  F3 0F 58 83 A0 33 01 00     addss   xmm0, dword ptr [rbx+133A0h]
0000000180387A86  F3 0F 59 8B 00 36 01 00     mulss   xmm1, dword ptr [rbx+13600h]
0000000180387A8E  F3 0F 59 83 10 36 01 00     mulss   xmm0, dword ptr [rbx+13610h]
0000000180387A96  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180387A9A  F3 0F 10 8B 50 34 01 00     movss   xmm1, dword ptr [rbx+13450h]
0000000180387AA2  F3 0F 58 8B 20 33 01 00     addss   xmm1, dword ptr [rbx+13320h]
0000000180387AAA  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180387AAE  F3 0F 10 83 90 34 01 00     movss   xmm0, dword ptr [rbx+13490h]
0000000180387AB6  F3 0F 59 8B 20 36 01 00     mulss   xmm1, dword ptr [rbx+13620h]
0000000180387ABE  F3 0F 58 83 E0 32 01 00     addss   xmm0, dword ptr [rbx+132E0h]
0000000180387AC6  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180387ACA  F3 0F 10 8B 60 33 01 00     movss   xmm1, dword ptr [rbx+13360h]
0000000180387AD2  F3 0F 58 8B 10 34 01 00     addss   xmm1, dword ptr [rbx+13410h]
0000000180387ADA  F3 0F 59 83 30 36 01 00     mulss   xmm0, dword ptr [rbx+13630h]
0000000180387AE2  F3 0F 59 8B 40 36 01 00     mulss   xmm1, dword ptr [rbx+13640h]
0000000180387AEA  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180387AEE  F3 0F 10 83 E0 33 01 00     movss   xmm0, dword ptr [rbx+133E0h]
0000000180387AF6  F3 0F 58 83 90 33 01 00     addss   xmm0, dword ptr [rbx+13390h]
0000000180387AFE  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180387B02  F3 0F 10 8B 10 33 01 00     movss   xmm1, dword ptr [rbx+13310h]
0000000180387B0A  F3 0F 59 83 50 36 01 00     mulss   xmm0, dword ptr [rbx+13650h]
0000000180387B12  F3 0F 58 8B 60 34 01 00     addss   xmm1, dword ptr [rbx+13460h]
0000000180387B1A  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180387B1E  F3 0F 10 83 80 34 01 00     movss   xmm0, dword ptr [rbx+13480h]
0000000180387B26  F3 0F 59 8B 60 36 01 00     mulss   xmm1, dword ptr [rbx+13660h]
0000000180387B2E  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180387B32  F3 0F 58 83 F0 32 01 00     addss   xmm0, dword ptr [rbx+132F0h]
0000000180387B3A  F3 0F 10 93 E0 34 01 00     movss   xmm2, dword ptr [rbx+134E0h]
0000000180387B42  F3 0F 10 8B 00 34 01 00     movss   xmm1, dword ptr [rbx+13400h]
0000000180387B4A  0F 28 E2                    movaps  xmm4, xmm2
0000000180387B4D  F3 0F 59 A3 E0 37 01 00     mulss   xmm4, dword ptr [rbx+137E0h]
0000000180387B55  F3 0F 59 83 70 36 01 00     mulss   xmm0, dword ptr [rbx+13670h]
0000000180387B5D  F3 0F 58 A3 F0 34 01 00     addss   xmm4, dword ptr [rbx+134F0h]
0000000180387B65  F3 0F 58 8B 70 33 01 00     addss   xmm1, dword ptr [rbx+13370h]
0000000180387B6D  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180387B71  F3 0F 10 83 F0 33 01 00     movss   xmm0, dword ptr [rbx+133F0h]
0000000180387B79  F3 0F 58 83 80 33 01 00     addss   xmm0, dword ptr [rbx+13380h]
0000000180387B81  F3 0F 59 8B 80 36 01 00     mulss   xmm1, dword ptr [rbx+13680h]
0000000180387B89  F3 0F 59 83 90 36 01 00     mulss   xmm0, dword ptr [rbx+13690h]
0000000180387B91  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180387B95  F3 0F 10 8B 70 34 01 00     movss   xmm1, dword ptr [rbx+13470h]
0000000180387B9D  F3 0F 58 8B 00 33 01 00     addss   xmm1, dword ptr [rbx+13300h]
0000000180387BA5  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180387BA9  0F 28 C2                    movaps  xmm0, xmm2
0000000180387BAC  F3 0F 59 8B A0 36 01 00     mulss   xmm1, dword ptr [rbx+136A0h]
0000000180387BB4  F3 0F 11 A3 E0 34 01 00     movss   dword ptr [rbx+134E0h], xmm4
0000000180387BBC  F3 0F 59 83 F0 37 01 00     mulss   xmm0, dword ptr [rbx+137F0h]
0000000180387BC4  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180387BC8  F3 0F 58 C4                 addss   xmm0, xmm4
0000000180387BCC  0F 28 DD                    movaps  xmm3, xmm5
0000000180387BCF  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180387BD3  0F 28 C3                    movaps  xmm0, xmm3
0000000180387BD6  F3 0F 59 83 E0 37 01 00     mulss   xmm0, dword ptr [rbx+137E0h]
0000000180387BDE  F3 0F 58 C2                 addss   xmm0, xmm2
0000000180387BE2  F3 0F 11 83 D0 34 01 00     movss   dword ptr [rbx+134D0h], xmm0
0000000180387BEA  F3 0F 10 93 30 38 01 00     movss   xmm2, dword ptr [rbx+13830h]
0000000180387BF2  F3 0F 59 9B C0 34 01 00     mulss   xmm3, dword ptr [rbx+134C0h]
0000000180387BFA  F3 0F 5C E3                 subss   xmm4, xmm3
0000000180387BFE  F3 0F 59 E2                 mulss   xmm4, xmm2
0000000180387C02  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180387C06  F3 0F 5C E2                 subss   xmm4, xmm2
0000000180387C0A  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180387C0E  F3 0F 11 A3 B0 32 01 00     movss   dword ptr [rbx+132B0h], xmm4
0000000180387C16  F3 0F 11 A3 30 2D 01 00     movss   dword ptr [rbx+12D30h], xmm4
0000000180387C1E  44 0F 2E AB 60 8D 01 00     ucomiss xmm13, dword ptr [rbx+18D60h]
0000000180387C26  75 28                       jnz     short loc_180387C50
0000000180387C28  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
0000000180387C31  F3 0F 11 83 B0 20 01 00     movss   dword ptr [rbx+120B0h], xmm0
0000000180387C39  C7 83 60 8D 01 00 00 00 00 00  mov     dword ptr [rbx+18D60h], 0
0000000180387C43  0F 1F 40 00                 nop     dword ptr [rax+00h]
0000000180387C47  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
0000000180387C50  8B 83 20 49 01 00           mov     eax, [rbx+14920h]
0000000180387C56  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
0000000180387C5E  48 8B 0F                    mov     rcx, [rdi]
0000000180387C61  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
0000000180387C66  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
0000000180387C6B  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
0000000180387C70  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
0000000180387C75  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
0000000180387C7A  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
0000000180387C7F  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
0000000180387C84  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
0000000180387C89  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
0000000180387C8F  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
0000000180387C95  89 01                       mov     [rcx], eax
0000000180387C97  8B 83 20 49 01 00           mov     eax, [rbx+14920h]
0000000180387C9D  48 8B 4F 08                 mov     rcx, [rdi+8]
0000000180387CA1  49 8B 5B 18                 mov     rbx, [r11+18h]
0000000180387CA5  89 01                       mov     [rcx], eax
0000000180387CA7  49 8B E3                    mov     rsp, r11
0000000180387CAA  5F                          pop     rdi
0000000180387CAB  C3                          retn
