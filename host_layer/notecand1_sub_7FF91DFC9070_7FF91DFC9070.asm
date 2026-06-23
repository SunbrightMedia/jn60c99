; sub_7FF91DFC9070 @ 0x7FF91DFC9070 (RVA 0x7FF79DFC9070)

00007FF91DFC9070  48 8B C4                    mov     rax, rsp
00007FF91DFC9073  48 89 58 10                 mov     [rax+10h], rbx
00007FF91DFC9077  57                          push    rdi
00007FF91DFC9078  48 81 EC C0 00 00 00        sub     rsp, 0C0h
00007FF91DFC907F  F3 0F 10 A1 40 01 00 00     movss   xmm4, dword ptr [rcx+140h]
00007FF91DFC9087  48 8B FA                    mov     rdi, rdx
00007FF91DFC908A  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
00007FF91DFC908E  48 8B D9                    mov     rbx, rcx
00007FF91DFC9091  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
00007FF91DFC9095  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00007FF91DFC909A  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00007FF91DFC909F  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00007FF91DFC90A4  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00007FF91DFC90A9  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00007FF91DFC90AE  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00007FF91DFC90B4  F3 44 0F 10 2D F7 BF 77 00  movss   xmm13, cs:dword_7FF91E7450B4
00007FF91DFC90BD  44 0F 2E A9 80 8C 01 00     ucomiss xmm13, dword ptr [rcx+18C80h]
00007FF91DFC90C5  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00007FF91DFC90CB  45 0F 57 F6                 xorps   xmm14, xmm14
00007FF91DFC90CF  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
00007FF91DFC90D9  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00007FF91DFC90DF  75 16                       jnz     short loc_7FF91DFC90F7
00007FF91DFC90E1  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
00007FF91DFC90EA  0F 57 E4                    xorps   xmm4, xmm4
00007FF91DFC90ED  C7 81 40 01 00 00 00 00 00 00  mov     dword ptr [rcx+140h], 0
00007FF91DFC90F7  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
00007FF91DFC90FF  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
00007FF91DFC9107  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
00007FF91DFC910F  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
00007FF91DFC9117  F3 0F 59 05 A5 1C 62 00     mulss   xmm0, cs:dword_7FF91E5EADC4
00007FF91DFC911F  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
00007FF91DFC9127  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
00007FF91DFC912F  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFC9133  85 D2                       test    edx, edx
00007FF91DFC9135  75 07                       jnz     short loc_7FF91DFC913E
00007FF91DFC9137  BA 01 00 00 00              mov     edx, 1
00007FF91DFC913C  EB 24                       jmp     short loc_7FF91DFC9162
00007FF91DFC913E  8B C2                       mov     eax, edx
00007FF91DFC9140  25 00 00 20 00              and     eax, 200000h
00007FF91DFC9145  0F BA E2 17                 bt      edx, 17h
00007FF91DFC9149  73 08                       jnb     short loc_7FF91DFC9153
00007FF91DFC914B  85 C0                       test    eax, eax
00007FF91DFC914D  75 0C                       jnz     short loc_7FF91DFC915B
00007FF91DFC914F  03 D2                       add     edx, edx
00007FF91DFC9151  EB 0F                       jmp     short loc_7FF91DFC9162
00007FF91DFC9153  85 C0                       test    eax, eax
00007FF91DFC9155  74 04                       jz      short loc_7FF91DFC915B
00007FF91DFC9157  03 D2                       add     edx, edx
00007FF91DFC9159  EB 07                       jmp     short loc_7FF91DFC9162
00007FF91DFC915B  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
00007FF91DFC9162  F3 0F 10 9B D0 00 00 00     movss   xmm3, dword ptr [rbx+0D0h]
00007FF91DFC916A  8B C2                       mov     eax, edx
00007FF91DFC916C  F3 0F 10 B3 B0 00 00 00     movss   xmm6, dword ptr [rbx+0B0h]
00007FF91DFC9174  25 FF FF FF 00              and     eax, 0FFFFFFh
00007FF91DFC9179  F3 44 0F 10 83 70 01 00 00  movss   xmm8, dword ptr [rbx+170h]
00007FF91DFC9182  8B CA                       mov     ecx, edx
00007FF91DFC9184  F3 0F 10 BB 80 01 00 00     movss   xmm7, dword ptr [rbx+180h]
00007FF91DFC918C  81 CA 00 00 00 FF           or      edx, 0FF000000h
00007FF91DFC9192  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFC9196  81 E1 00 00 00 01           and     ecx, 1000000h
00007FF91DFC919C  C7 83 B0 01 00 00 00 00 00 00  mov     dword ptr [rbx+1B0h], 0
00007FF91DFC91A6  F3 0F 11 9B E0 00 00 00     movss   dword ptr [rbx+0E0h], xmm3
00007FF91DFC91AE  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFC91B2  0F 44 D0                    cmovz   edx, eax
00007FF91DFC91B5  F3 0F 11 B3 C0 00 00 00     movss   dword ptr [rbx+0C0h], xmm6
00007FF91DFC91BD  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
00007FF91DFC91C3  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
00007FF91DFC91C9  8B 83 F0 01 00 00           mov     eax, [rbx+1F0h]
00007FF91DFC91CF  66 0F 6E C2                 movd    xmm0, edx
00007FF91DFC91D3  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFC91D6  89 83 00 02 00 00           mov     [rbx+200h], eax
00007FF91DFC91DC  F3 0F 11 A3 60 01 00 00     movss   dword ptr [rbx+160h], xmm4
00007FF91DFC91E4  F3 0F 59 05 84 1A 62 00     mulss   xmm0, cs:dword_7FF91E5EAC70
00007FF91DFC91EC  F3 44 0F 11 83 90 01 00 00  movss   dword ptr [rbx+190h], xmm8
00007FF91DFC91F5  F3 0F 11 BB A0 01 00 00     movss   dword ptr [rbx+1A0h], xmm7
00007FF91DFC91FD  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
00007FF91DFC9205  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
00007FF91DFC920D  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
00007FF91DFC9215  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFC9219  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
00007FF91DFC9221  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFC9225  F3 0F 10 93 10 01 00 00     movss   xmm2, dword ptr [rbx+110h]
00007FF91DFC922D  F3 0F 11 93 20 01 00 00     movss   dword ptr [rbx+120h], xmm2
00007FF91DFC9235  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC9239  F3 0F 10 83 F0 00 00 00     movss   xmm0, dword ptr [rbx+0F0h]
00007FF91DFC9241  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFC9245  F3 0F 11 83 00 01 00 00     movss   dword ptr [rbx+100h], xmm0
00007FF91DFC924D  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFC9251  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC9254  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
00007FF91DFC925C  F3 0F 10 8B 30 01 00 00     movss   xmm1, dword ptr [rbx+130h]
00007FF91DFC9264  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC9268  F3 0F 59 F2                 mulss   xmm6, xmm2
00007FF91DFC926C  F3 0F 11 8B 50 01 00 00     movss   dword ptr [rbx+150h], xmm1
00007FF91DFC9274  F3 0F 11 93 C0 01 00 00     movss   dword ptr [rbx+1C0h], xmm2
00007FF91DFC927C  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFC9280  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC9283  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC9287  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFC928B  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFC928F  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFC9293  F3 0F 11 B3 D0 01 00 00     movss   dword ptr [rbx+1D0h], xmm6
00007FF91DFC929B  F3 0F 11 9B E0 01 00 00     movss   dword ptr [rbx+1E0h], xmm3
00007FF91DFC92A3  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC92A6  F3 0F 58 9B 20 02 00 00     addss   xmm3, dword ptr [rbx+220h]
00007FF91DFC92AE  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFC92B2  72 05                       jb      short loc_7FF91DFC92B9
00007FF91DFC92B4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC92B7  EB 03                       jmp     short loc_7FF91DFC92BC
00007FF91DFC92B9  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFC92BC  41 0F 2E CE                 ucomiss xmm1, xmm14
00007FF91DFC92C0  F3 44 0F 10 3D 1B C2 77 00  movss   xmm15, cs:dword_7FF91E7454E4
00007FF91DFC92C9  75 06                       jnz     short loc_7FF91DFC92D1
00007FF91DFC92CB  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFC92CF  EB 04                       jmp     short loc_7FF91DFC92D5
00007FF91DFC92D1  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFC92D5  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFC92D9  F3 0F 11 AB F0 01 00 00     movss   dword ptr [rbx+1F0h], xmm5
00007FF91DFC92E1  73 06                       jnb     short loc_7FF91DFC92E9
00007FF91DFC92E3  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFC92E7  EB 06                       jmp     short loc_7FF91DFC92EF
00007FF91DFC92E9  76 04                       jbe     short loc_7FF91DFC92EF
00007FF91DFC92EB  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFC92EF  F3 0F 10 83 60 02 00 00     movss   xmm0, dword ptr [rbx+260h]
00007FF91DFC92F7  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFC92FC  F3 0F 10 93 00 03 00 00     movss   xmm2, dword ptr [rbx+300h]
00007FF91DFC9304  F3 0F 10 8B 70 02 00 00     movss   xmm1, dword ptr [rbx+270h]
00007FF91DFC930C  8B 83 30 02 00 00           mov     eax, [rbx+230h]
00007FF91DFC9312  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFC9315  F3 0F 10 A3 C0 02 00 00     movss   xmm4, dword ptr [rbx+2C0h]
00007FF91DFC931D  F3 0F 58 9B 10 03 00 00     addss   xmm3, dword ptr [rbx+310h]
00007FF91DFC9325  F2 44 0F 10 25 72 BE 77 00  movsd   xmm12, cs:dbl_7FF91E7451A0
00007FF91DFC932E  F3 0F 11 AB 10 02 00 00     movss   dword ptr [rbx+210h], xmm5
00007FF91DFC9336  F3 0F 11 AB 30 02 00 00     movss   dword ptr [rbx+230h], xmm5
00007FF91DFC933E  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFC9342  89 83 40 02 00 00           mov     [rbx+240h], eax
00007FF91DFC9348  F3 0F 11 A3 D0 02 00 00     movss   dword ptr [rbx+2D0h], xmm4
00007FF91DFC9350  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFC9354  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC9357  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC935B  F3 0F 10 8B A0 02 00 00     movss   xmm1, dword ptr [rbx+2A0h]
00007FF91DFC9363  F3 0F 58 83 20 03 00 00     addss   xmm0, dword ptr [rbx+320h]
00007FF91DFC936B  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFC9370  F3 0F 5E C8                 divss   xmm1, xmm0
00007FF91DFC9374  F3 0F 10 83 30 03 00 00     movss   xmm0, dword ptr [rbx+330h]
00007FF91DFC937C  F3 0F 59 AB 50 02 00 00     mulss   xmm5, dword ptr [rbx+250h]
00007FF91DFC9384  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFC9388  F3 0F 10 93 90 02 00 00     movss   xmm2, dword ptr [rbx+290h]
00007FF91DFC9390  F3 0F 11 AB E0 02 00 00     movss   dword ptr [rbx+2E0h], xmm5
00007FF91DFC9398  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFC939C  F3 0F 10 8B B0 02 00 00     movss   xmm1, dword ptr [rbx+2B0h]
00007FF91DFC93A4  F3 0F 58 D6                 addss   xmm2, xmm6
00007FF91DFC93A8  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFC93AC  F3 0F 11 93 90 02 00 00     movss   dword ptr [rbx+290h], xmm2
00007FF91DFC93B4  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFC93B8  F3 0F 11 93 A0 02 00 00     movss   dword ptr [rbx+2A0h], xmm2
00007FF91DFC93C0  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFC93C4  F3 0F 5C E6                 subss   xmm4, xmm6
00007FF91DFC93C8  0F 54 25 C1 C3 77 00        andps   xmm4, cs:xmmword_7FF91E745790
00007FF91DFC93CF  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFC93D3  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFC93D7  0F 83 E8 00 00 00           jnb     loc_7FF91DFC94C5
00007FF91DFC93DD  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFC93E0  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFC93E3  41 0F 2E EE                 ucomiss xmm5, xmm14
00007FF91DFC93E7  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFC93EB  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFC93EE  F3 0F 11 83 B0 02 00 00     movss   dword ptr [rbx+2B0h], xmm0
00007FF91DFC93F6  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFC93FA  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFC93FE  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC9402  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC9406  75 03                       jnz     short loc_7FF91DFC940B
00007FF91DFC9408  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFC940B  8B 83 70 03 00 00           mov     eax, [rbx+370h]
00007FF91DFC9411  48 8D 0D E8 6B C9 FF        lea     rcx, cs:7FF91DC60000h
00007FF91DFC9418  F3 0F 59 BB 60 03 00 00     mulss   xmm7, dword ptr [rbx+360h]
00007FF91DFC9420  89 83 80 03 00 00           mov     [rbx+380h], eax
00007FF91DFC9426  F3 44 0F 59 83 50 03 00 00  mulss   xmm8, dword ptr [rbx+350h]
00007FF91DFC942F  F3 0F 10 83 90 04 00 00     movss   xmm0, dword ptr [rbx+490h]
00007FF91DFC9437  F3 0F 10 93 90 03 00 00     movss   xmm2, dword ptr [rbx+390h]
00007FF91DFC943F  F3 44 0F 10 8B F0 03 00 00  movss   xmm9, dword ptr [rbx+3F0h]
00007FF91DFC9448  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFC944D  F3 44 0F 10 83 D0 03 00 00  movss   xmm8, dword ptr [rbx+3D0h]
00007FF91DFC9456  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFC945A  F3 0F 11 BB 70 03 00 00     movss   dword ptr [rbx+370h], xmm7
00007FF91DFC9462  F3 0F 10 BB B0 03 00 00     movss   xmm7, dword ptr [rbx+3B0h]
00007FF91DFC946A  F3 0F 11 8B C0 02 00 00     movss   dword ptr [rbx+2C0h], xmm1
00007FF91DFC9472  F3 0F 11 8B F0 02 00 00     movss   dword ptr [rbx+2F0h], xmm1
00007FF91DFC947A  F3 0F 10 8B 50 04 00 00     movss   xmm1, dword ptr [rbx+450h]
00007FF91DFC9482  F3 0F 11 BB C0 03 00 00     movss   dword ptr [rbx+3C0h], xmm7
00007FF91DFC948A  F3 0F 11 93 A0 03 00 00     movss   dword ptr [rbx+3A0h], xmm2
00007FF91DFC9492  F3 44 0F 11 83 E0 03 00 00  movss   dword ptr [rbx+3E0h], xmm8
00007FF91DFC949B  F3 44 0F 11 8B 00 04 00 00  movss   dword ptr [rbx+400h], xmm9
00007FF91DFC94A4  F3 0F 11 8B 60 04 00 00     movss   dword ptr [rbx+460h], xmm1
00007FF91DFC94AC  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFC94AF  7D 2F                       jge     short loc_7FF91DFC94E0
00007FF91DFC94B1  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFC94B6  F7 D0                       not     eax
00007FF91DFC94B8  48 98                       cdqe
00007FF91DFC94BA  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFC94C3  EB 47                       jmp     short loc_7FF91DFC950C
00007FF91DFC94C5  F3 0F 58 8B 40 03 00 00     addss   xmm1, dword ptr [rbx+340h]
00007FF91DFC94CD  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFC94D1  0F 82 09 FF FF FF           jb      loc_7FF91DFC93E0
00007FF91DFC94D7  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFC94DB  E9 03 FF FF FF              jmp     loc_7FF91DFC93E3
00007FF91DFC94E0  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFC94E3  7E 07                       jle     short loc_7FF91DFC94EC
00007FF91DFC94E5  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFC94EA  EB 15                       jmp     short loc_7FF91DFC9501
00007FF91DFC94EC  85 C0                       test    eax, eax
00007FF91DFC94EE  79 0F                       jns     short loc_7FF91DFC94FF
00007FF91DFC94F0  F7 D0                       not     eax
00007FF91DFC94F2  48 98                       cdqe
00007FF91DFC94F4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFC94FD  EB 0D                       jmp     short loc_7FF91DFC950C
00007FF91DFC94FF  7E 0B                       jle     short loc_7FF91DFC950C
00007FF91DFC9501  48 98                       cdqe
00007FF91DFC9503  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFC950C  0F 57 05 AD C2 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFC9513  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFC9517  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFC951A  7D 14                       jge     short loc_7FF91DFC9530
00007FF91DFC951C  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFC9521  F7 D0                       not     eax
00007FF91DFC9523  48 98                       cdqe
00007FF91DFC9525  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFC952E  EB 2C                       jmp     short loc_7FF91DFC955C
00007FF91DFC9530  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFC9533  7E 07                       jle     short loc_7FF91DFC953C
00007FF91DFC9535  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFC953A  EB 15                       jmp     short loc_7FF91DFC9551
00007FF91DFC953C  85 C0                       test    eax, eax
00007FF91DFC953E  79 0F                       jns     short loc_7FF91DFC954F
00007FF91DFC9540  F7 D0                       not     eax
00007FF91DFC9542  48 98                       cdqe
00007FF91DFC9544  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFC954D  EB 0D                       jmp     short loc_7FF91DFC955C
00007FF91DFC954F  7E 0B                       jle     short loc_7FF91DFC955C
00007FF91DFC9551  48 98                       cdqe
00007FF91DFC9553  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFC955C  F3 0F 10 83 10 04 00 00     movss   xmm0, dword ptr [rbx+410h]
00007FF91DFC9564  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFC9568  F3 0F 59 93 80 04 00 00     mulss   xmm2, dword ptr [rbx+480h]
00007FF91DFC9570  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC9574  F3 0F 10 8B 40 04 00 00     movss   xmm1, dword ptr [rbx+440h]
00007FF91DFC957C  F3 0F 11 93 50 04 00 00     movss   dword ptr [rbx+450h], xmm2
00007FF91DFC9584  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFC9588  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC958C  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC9590  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC9594  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFC9598  76 05                       jbe     short loc_7FF91DFC959F
00007FF91DFC959A  0F 5A C2                    cvtps2pd xmm0, xmm2
00007FF91DFC959D  EB 03                       jmp     short loc_7FF91DFC95A2
00007FF91DFC959F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC95A2  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFC95A6  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFC95AA  72 06                       jb      short loc_7FF91DFC95B2
00007FF91DFC95AC  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFC95B0  EB 03                       jmp     short loc_7FF91DFC95B5
00007FF91DFC95B2  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFC95B5  F3 0F 10 B3 20 04 00 00     movss   xmm6, dword ptr [rbx+420h]
00007FF91DFC95BD  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFC95C1  F3 0F 59 83 B0 04 00 00     mulss   xmm0, dword ptr [rbx+4B0h]; X
00007FF91DFC95C9  E8 72 61 38 00              call    expf
00007FF91DFC95CE  F3 0F 59 83 A0 04 00 00     mulss   xmm0, dword ptr [rbx+4A0h]
00007FF91DFC95D6  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFC95D9  8B 83 20 06 00 00           mov     eax, [rbx+620h]
00007FF91DFC95DF  F3 0F 59 8B 30 04 00 00     mulss   xmm1, dword ptr [rbx+430h]
00007FF91DFC95E7  89 83 30 06 00 00           mov     [rbx+630h], eax
00007FF91DFC95ED  F3 0F 58 83 C0 04 00 00     addss   xmm0, dword ptr [rbx+4C0h]
00007FF91DFC95F5  8B 83 40 06 00 00           mov     eax, [rbx+640h]
00007FF91DFC95FB  F3 0F 10 9B E0 05 00 00     movss   xmm3, dword ptr [rbx+5E0h]
00007FF91DFC9603  F3 0F 59 BB 70 07 00 00     mulss   xmm7, dword ptr [rbx+770h]
00007FF91DFC960B  89 83 50 06 00 00           mov     [rbx+650h], eax
00007FF91DFC9611  8B 83 60 06 00 00           mov     eax, [rbx+660h]
00007FF91DFC9617  F3 0F 10 93 D0 05 00 00     movss   xmm2, dword ptr [rbx+5D0h]
00007FF91DFC961F  F3 0F 10 A3 00 06 00 00     movss   xmm4, dword ptr [rbx+600h]
00007FF91DFC9627  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFC962B  89 83 70 06 00 00           mov     [rbx+670h], eax
00007FF91DFC9631  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
00007FF91DFC9637  F3 0F 11 9B F0 05 00 00     movss   dword ptr [rbx+5F0h], xmm3
00007FF91DFC963F  F3 0F 5C CE                 subss   xmm1, xmm6
00007FF91DFC9643  F3 0F 11 93 E0 05 00 00     movss   dword ptr [rbx+5E0h], xmm2
00007FF91DFC964B  F3 0F 11 A3 10 06 00 00     movss   dword ptr [rbx+610h], xmm4
00007FF91DFC9653  F3 44 0F 11 83 A0 05 00 00  movss   dword ptr [rbx+5A0h], xmm8
00007FF91DFC965C  F3 44 0F 11 8B B0 05 00 00  movss   dword ptr [rbx+5B0h], xmm9
00007FF91DFC9665  89 83 90 05 00 00           mov     [rbx+590h], eax
00007FF91DFC966B  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC966F  F3 0F 10 83 40 07 00 00     movss   xmm0, dword ptr [rbx+740h]
00007FF91DFC9677  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFC967B  F3 0F 11 83 30 07 00 00     movss   dword ptr [rbx+730h], xmm0
00007FF91DFC9683  F3 0F 11 8B 70 04 00 00     movss   dword ptr [rbx+470h], xmm1
00007FF91DFC968B  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFC968F  73 06                       jnb     short loc_7FF91DFC9697
00007FF91DFC9691  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFC9695  EB 05                       jmp     short loc_7FF91DFC969C
00007FF91DFC9697  F3 41 0F 5D FD              minss   xmm7, xmm13
00007FF91DFC969C  F3 0F 59 0D 1C 17 62 00     mulss   xmm1, cs:dword_7FF91E5EADC0
00007FF91DFC96A4  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFC96A8  F3 0F 10 B3 50 08 00 00     movss   xmm6, dword ptr [rbx+850h]
00007FF91DFC96B0  F3 0F 5C C3                 subss   xmm0, xmm3
00007FF91DFC96B4  F3 0F 11 BB D0 05 00 00     movss   dword ptr [rbx+5D0h], xmm7
00007FF91DFC96BC  F3 0F 5D F1                 minss   xmm6, xmm1
00007FF91DFC96C0  F3 0F 59 83 80 07 00 00     mulss   xmm0, dword ptr [rbx+780h]
00007FF91DFC96C8  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFC96CC  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFC96D0  73 06                       jnb     short loc_7FF91DFC96D8
00007FF91DFC96D2  41 0F 28 C7                 movaps  xmm0, xmm15
00007FF91DFC96D6  EB 05                       jmp     short loc_7FF91DFC96DD
00007FF91DFC96D8  F3 41 0F 5D C5              minss   xmm0, xmm13
00007FF91DFC96DD  F3 0F 59 B3 60 08 00 00     mulss   xmm6, dword ptr [rbx+860h]
00007FF91DFC96E5  F3 0F 5C D7                 subss   xmm2, xmm7
00007FF91DFC96E9  F3 0F 11 B3 80 06 00 00     movss   dword ptr [rbx+680h], xmm6
00007FF91DFC96F1  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFC96F5  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFC96F9  73 03                       jnb     short loc_7FF91DFC96FE
00007FF91DFC96FB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC96FE  F3 0F 10 8B 50 07 00 00     movss   xmm1, dword ptr [rbx+750h]
00007FF91DFC9706  F3 44 0F 10 9B 90 05 00 00  movss   xmm11, dword ptr [rbx+590h]
00007FF91DFC970F  F3 0F 11 83 E0 05 00 00     movss   dword ptr [rbx+5E0h], xmm0
00007FF91DFC9717  F3 0F 58 83 E0 08 00 00     addss   xmm0, dword ptr [rbx+8E0h]
00007FF91DFC971F  72 04                       jb      short loc_7FF91DFC9725
00007FF91DFC9721  41 0F 28 CD                 movaps  xmm1, xmm13
00007FF91DFC9725  F3 0F 59 83 D0 08 00 00     mulss   xmm0, dword ptr [rbx+8D0h]
00007FF91DFC972D  41 0F 28 FB                 movaps  xmm7, xmm11
00007FF91DFC9731  F3 0F 10 93 30 06 00 00     movss   xmm2, dword ptr [rbx+630h]
00007FF91DFC9739  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFC973D  F3 0F 5C FA                 subss   xmm7, xmm2
00007FF91DFC9741  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFC9745  F3 0F 59 B3 60 07 00 00     mulss   xmm6, dword ptr [rbx+760h]
00007FF91DFC974D  76 05                       jbe     short loc_7FF91DFC9754
00007FF91DFC974F  0F 5A C8                    cvtps2pd xmm1, xmm0
00007FF91DFC9752  EB 03                       jmp     short loc_7FF91DFC9757
00007FF91DFC9754  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFC9757  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFC975B  F3 0F 59 BB A0 09 00 00     mulss   xmm7, dword ptr [rbx+9A0h]
00007FF91DFC9763  F3 44 0F 10 0D 7C BA 77 00  movss   xmm9, cs:flt_7FF91E7451E8
00007FF91DFC976C  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
00007FF91DFC9770  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFC9774  F3 0F 11 BB 20 06 00 00     movss   dword ptr [rbx+620h], xmm7
00007FF91DFC977C  F3 0F 11 83 C0 05 00 00     movss   dword ptr [rbx+5C0h], xmm0
00007FF91DFC9784  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFC9788  F3 0F 59 BB 90 09 00 00     mulss   xmm7, dword ptr [rbx+990h]
00007FF91DFC9790  F3 0F 10 8B 10 08 00 00     movss   xmm1, dword ptr [rbx+810h]
00007FF91DFC9798  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC979C  F3 0F 59 F9                 mulss   xmm7, xmm1
00007FF91DFC97A0  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFC97A4  F3 0F 10 83 10 06 00 00     movss   xmm0, dword ptr [rbx+610h]
00007FF91DFC97AC  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
00007FF91DFC97B5  F3 41 0F 58 FB              addss   xmm7, xmm11
00007FF91DFC97BA  76 1B                       jbe     short loc_7FF91DFC97D7
00007FF91DFC97BC  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFC97C1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFC97C5  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFC97C8  E8 0B 5D 38 00              call    fmodf
00007FF91DFC97CD  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFC97D0  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFC97D5  EB 1F                       jmp     short loc_7FF91DFC97F6
00007FF91DFC97D7  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFC97DB  73 19                       jnb     short loc_7FF91DFC97F6
00007FF91DFC97DD  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFC97E2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFC97E6  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFC97E9  E8 EA 5C 38 00              call    fmodf
00007FF91DFC97EE  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFC97F1  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFC97F6  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
00007FF91DFC97FF  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFC9802  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFC9806  F3 44 0F 10 83 50 06 00 00  movss   xmm8, dword ptr [rbx+650h]
00007FF91DFC980F  F3 0F 11 B3 00 06 00 00     movss   dword ptr [rbx+600h], xmm6
00007FF91DFC9817  F3 0F 59 BB 80 09 00 00     mulss   xmm7, dword ptr [rbx+980h]
00007FF91DFC981F  F3 0F 58 83 F0 08 00 00     addss   xmm0, dword ptr [rbx+8F0h]
00007FF91DFC9827  F3 0F 11 BB 80 05 00 00     movss   dword ptr [rbx+580h], xmm7
00007FF91DFC982F  73 0A                       jnb     short loc_7FF91DFC983B
00007FF91DFC9831  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFC9835  76 04                       jbe     short loc_7FF91DFC983B
00007FF91DFC9837  45 0F 28 C3                 movaps  xmm8, xmm11
00007FF91DFC983B  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFC983F  76 15                       jbe     short loc_7FF91DFC9856
00007FF91DFC9841  F3 41 0F 58 C5              addss   xmm0, xmm13; X
00007FF91DFC9846  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFC984A  E8 89 5C 38 00              call    fmodf
00007FF91DFC984F  F3 41 0F 5C C5              subss   xmm0, xmm13
00007FF91DFC9854  EB 19                       jmp     short loc_7FF91DFC986F
00007FF91DFC9856  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFC985A  73 13                       jnb     short loc_7FF91DFC986F
00007FF91DFC985C  F3 41 0F 5C C5              subss   xmm0, xmm13; X
00007FF91DFC9861  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFC9865  E8 6E 5C 38 00              call    fmodf
00007FF91DFC986A  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFC986F  F3 44 0F 10 1D 48 BF 77 00  movss   xmm11, dword ptr cs:xmmword_7FF91E7457C0
00007FF91DFC9878  F3 44 0F 11 83 40 06 00 00  movss   dword ptr [rbx+640h], xmm8
00007FF91DFC9881  F3 0F 59 83 30 09 00 00     mulss   xmm0, dword ptr [rbx+930h]
00007FF91DFC9889  F3 44 0F 59 83 70 09 00 00  mulss   xmm8, dword ptr [rbx+970h]
00007FF91DFC9892  F3 0F 58 83 B0 09 00 00     addss   xmm0, dword ptr [rbx+9B0h]
00007FF91DFC989A  F3 0F 11 83 90 06 00 00     movss   dword ptr [rbx+690h], xmm0
00007FF91DFC98A2  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFC98A6  F3 44 0F 11 83 E0 06 00 00  movss   dword ptr [rbx+6E0h], xmm8
00007FF91DFC98AF  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFC98B3  F3 44 0F 58 83 10 09 00 00  addss   xmm8, dword ptr [rbx+910h]
00007FF91DFC98BC  F3 0F 11 83 A0 06 00 00     movss   dword ptr [rbx+6A0h], xmm0
00007FF91DFC98C4  45 0F 2F C5                 comiss  xmm8, xmm13
00007FF91DFC98C8  76 1D                       jbe     short loc_7FF91DFC98E7
00007FF91DFC98CA  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFC98CF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFC98D3  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFC98D7  E8 FC 5B 38 00              call    fmodf
00007FF91DFC98DC  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFC98E0  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFC98E5  EB 21                       jmp     short loc_7FF91DFC9908
00007FF91DFC98E7  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFC98EB  73 1B                       jnb     short loc_7FF91DFC9908
00007FF91DFC98ED  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFC98F2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFC98F6  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFC98FA  E8 D9 5B 38 00              call    fmodf
00007FF91DFC98FF  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFC9903  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFC9908  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFC990B  F3 0F 58 BB 00 09 00 00     addss   xmm7, dword ptr [rbx+900h]
00007FF91DFC9913  41 0F 2F FD                 comiss  xmm7, xmm13
00007FF91DFC9917  76 1B                       jbe     short loc_7FF91DFC9934
00007FF91DFC9919  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFC991E  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFC9922  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFC9925  E8 AE 5B 38 00              call    fmodf
00007FF91DFC992A  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFC992D  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFC9932  EB 1F                       jmp     short loc_7FF91DFC9953
00007FF91DFC9934  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFC9938  73 19                       jnb     short loc_7FF91DFC9953
00007FF91DFC993A  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFC993F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFC9943  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFC9946  E8 8D 5B 38 00              call    fmodf
00007FF91DFC994B  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFC994E  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFC9953  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFC9957  E8 64 F6 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFC995C  F3 0F 58 BB C0 09 00 00     addss   xmm7, dword ptr [rbx+9C0h]
00007FF91DFC9964  F3 0F 59 83 50 09 00 00     mulss   xmm0, dword ptr [rbx+950h]
00007FF91DFC996C  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFC9970  73 06                       jnb     short loc_7FF91DFC9978
00007FF91DFC9972  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFC9976  EB 06                       jmp     short loc_7FF91DFC997E
00007FF91DFC9978  76 04                       jbe     short loc_7FF91DFC997E
00007FF91DFC997A  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFC997E  F3 0F 58 B3 20 09 00 00     addss   xmm6, dword ptr [rbx+920h]
00007FF91DFC9986  F3 0F 11 83 C0 06 00 00     movss   dword ptr [rbx+6C0h], xmm0
00007FF91DFC998E  F3 0F 11 BB 20 07 00 00     movss   dword ptr [rbx+720h], xmm7
00007FF91DFC9996  F3 0F 59 BB 40 09 00 00     mulss   xmm7, dword ptr [rbx+940h]
00007FF91DFC999E  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFC99A2  F3 0F 58 BB D0 09 00 00     addss   xmm7, dword ptr [rbx+9D0h]
00007FF91DFC99AA  76 1B                       jbe     short loc_7FF91DFC99C7
00007FF91DFC99AC  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFC99B1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFC99B5  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFC99B8  E8 1B 5B 38 00              call    fmodf
00007FF91DFC99BD  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFC99C0  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFC99C5  EB 1F                       jmp     short loc_7FF91DFC99E6
00007FF91DFC99C7  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFC99CB  73 19                       jnb     short loc_7FF91DFC99E6
00007FF91DFC99CD  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFC99D2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFC99D6  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFC99D9  E8 FA 5A 38 00              call    fmodf
00007FF91DFC99DE  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFC99E1  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFC99E6  0F 54 35 A3 BD 77 00        andps   xmm6, cs:xmmword_7FF91E745790
00007FF91DFC99ED  F3 0F 11 BB B0 06 00 00     movss   dword ptr [rbx+6B0h], xmm7
00007FF91DFC99F5  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFC99F8  F3 0F 10 9B F0 07 00 00     movss   xmm3, dword ptr [rbx+7F0h]
00007FF91DFC9A00  0F 28 D6                    movaps  xmm2, xmm6
00007FF91DFC9A03  F3 0F 59 93 80 08 00 00     mulss   xmm2, dword ptr [rbx+880h]
00007FF91DFC9A0B  F3 0F 59 9B E0 06 00 00     mulss   xmm3, dword ptr [rbx+6E0h]
00007FF91DFC9A13  F3 0F 58 93 70 08 00 00     addss   xmm2, dword ptr [rbx+870h]
00007FF91DFC9A1B  F3 0F 10 8B E0 07 00 00     movss   xmm1, dword ptr [rbx+7E0h]
00007FF91DFC9A23  F3 0F 59 8B A0 06 00 00     mulss   xmm1, dword ptr [rbx+6A0h]
00007FF91DFC9A2B  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFC9A2F  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFC9A32  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFC9A36  F3 0F 59 83 90 08 00 00     mulss   xmm0, dword ptr [rbx+890h]
00007FF91DFC9A3E  F3 0F 59 F4                 mulss   xmm6, xmm4
00007FF91DFC9A42  F3 0F 59 A3 A0 08 00 00     mulss   xmm4, dword ptr [rbx+8A0h]
00007FF91DFC9A4A  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFC9A4E  F3 0F 59 B3 B0 08 00 00     mulss   xmm6, dword ptr [rbx+8B0h]
00007FF91DFC9A56  F3 0F 10 83 D0 07 00 00     movss   xmm0, dword ptr [rbx+7D0h]
00007FF91DFC9A5E  F3 0F 59 83 90 06 00 00     mulss   xmm0, dword ptr [rbx+690h]
00007FF91DFC9A66  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFC9A6A  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFC9A6E  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFC9A72  F3 0F 10 A3 B0 07 00 00     movss   xmm4, dword ptr [rbx+7B0h]
00007FF91DFC9A7A  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFC9A7E  F3 0F 58 B3 C0 08 00 00     addss   xmm6, dword ptr [rbx+8C0h]
00007FF91DFC9A86  F3 0F 59 B3 60 09 00 00     mulss   xmm6, dword ptr [rbx+960h]
00007FF91DFC9A8E  F3 0F 11 B3 D0 06 00 00     movss   dword ptr [rbx+6D0h], xmm6
00007FF91DFC9A96  F3 0F 59 A3 C0 06 00 00     mulss   xmm4, dword ptr [rbx+6C0h]
00007FF91DFC9A9E  F3 0F 10 8B 90 07 00 00     movss   xmm1, dword ptr [rbx+790h]
00007FF91DFC9AA6  F3 0F 10 83 C0 07 00 00     movss   xmm0, dword ptr [rbx+7C0h]
00007FF91DFC9AAE  F3 0F 59 83 B0 06 00 00     mulss   xmm0, dword ptr [rbx+6B0h]
00007FF91DFC9AB6  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFC9ABA  F3 0F 10 93 20 08 00 00     movss   xmm2, dword ptr [rbx+820h]
00007FF91DFC9AC2  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFC9AC5  F3 0F 59 9B C0 05 00 00     mulss   xmm3, dword ptr [rbx+5C0h]
00007FF91DFC9ACD  F3 0F 59 B3 A0 07 00 00     mulss   xmm6, dword ptr [rbx+7A0h]
00007FF91DFC9AD5  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC9AD9  F3 0F 10 83 00 08 00 00     movss   xmm0, dword ptr [rbx+800h]
00007FF91DFC9AE1  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFC9AE5  F3 0F 59 83 80 05 00 00     mulss   xmm0, dword ptr [rbx+580h]
00007FF91DFC9AED  F3 0F 58 E6                 addss   xmm4, xmm6
00007FF91DFC9AF1  F3 41 0F 58 DD              addss   xmm3, xmm13
00007FF91DFC9AF6  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFC9AFA  F3 0F 11 9B F0 06 00 00     movss   dword ptr [rbx+6F0h], xmm3
00007FF91DFC9B02  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFC9B06  F3 0F 11 A3 10 07 00 00     movss   dword ptr [rbx+710h], xmm4
00007FF91DFC9B0E  F3 0F 10 8B 30 08 00 00     movss   xmm1, dword ptr [rbx+830h]
00007FF91DFC9B16  F3 0F 59 8B A0 05 00 00     mulss   xmm1, dword ptr [rbx+5A0h]
00007FF91DFC9B1E  F3 0F 10 83 40 08 00 00     movss   xmm0, dword ptr [rbx+840h]
00007FF91DFC9B26  F3 0F 59 83 B0 05 00 00     mulss   xmm0, dword ptr [rbx+5B0h]
00007FF91DFC9B2E  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFC9B32  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFC9B36  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC9B3A  F3 0F 11 8B 00 07 00 00     movss   dword ptr [rbx+700h], xmm1
00007FF91DFC9B42  F3 0F 10 83 10 07 00 00     movss   xmm0, dword ptr [rbx+710h]
00007FF91DFC9B4A  8B 83 20 07 00 00           mov     eax, [rbx+720h]
00007FF91DFC9B50  89 83 E0 09 00 00           mov     [rbx+9E0h], eax
00007FF91DFC9B56  F3 0F 11 83 F0 09 00 00     movss   dword ptr [rbx+9F0h], xmm0
00007FF91DFC9B5E  44 0F 2F B3 20 07 00 00     comiss  xmm14, dword ptr [rbx+720h]
00007FF91DFC9B66  F3 0F 10 8B 30 02 00 00     movss   xmm1, dword ptr [rbx+230h]
00007FF91DFC9B6E  F3 0F 10 93 00 0A 00 00     movss   xmm2, dword ptr [rbx+0A00h]
00007FF91DFC9B76  73 06                       jnb     short loc_7FF91DFC9B7E
00007FF91DFC9B78  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFC9B7C  EB 03                       jmp     short loc_7FF91DFC9B81
00007FF91DFC9B7E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC9B81  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFC9B85  75 04                       jnz     short loc_7FF91DFC9B8B
00007FF91DFC9B87  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFC9B8B  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFC9B8F  F3 0F 11 8B 10 0A 00 00     movss   dword ptr [rbx+0A10h], xmm1
00007FF91DFC9B97  8B 83 20 0A 00 00           mov     eax, [rbx+0A20h]
00007FF91DFC9B9D  89 83 30 0A 00 00           mov     [rbx+0A30h], eax
00007FF91DFC9BA3  8B 83 50 0A 00 00           mov     eax, [rbx+0A50h]
00007FF91DFC9BA9  89 83 60 0A 00 00           mov     [rbx+0A60h], eax
00007FF91DFC9BAF  8B 83 40 0A 00 00           mov     eax, [rbx+0A40h]
00007FF91DFC9BB5  89 83 50 0A 00 00           mov     [rbx+0A50h], eax
00007FF91DFC9BBB  8B 83 70 0A 00 00           mov     eax, [rbx+0A70h]
00007FF91DFC9BC1  89 83 80 0A 00 00           mov     [rbx+0A80h], eax
00007FF91DFC9BC7  8B 83 A0 0A 00 00           mov     eax, [rbx+0AA0h]
00007FF91DFC9BCD  89 83 B0 0A 00 00           mov     [rbx+0AB0h], eax
00007FF91DFC9BD3  F3 0F 10 83 50 0B 00 00     movss   xmm0, dword ptr [rbx+0B50h]
00007FF91DFC9BDB  F3 0F 58 8B 30 0B 00 00     addss   xmm1, dword ptr [rbx+0B30h]
00007FF91DFC9BE3  F3 0F 59 83 60 0A 00 00     mulss   xmm0, dword ptr [rbx+0A60h]
00007FF91DFC9BEB  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFC9BEF  F3 0F 58 83 30 0A 00 00     addss   xmm0, dword ptr [rbx+0A30h]
00007FF91DFC9BF7  73 06                       jnb     short loc_7FF91DFC9BFF
00007FF91DFC9BF9  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFC9BFD  EB 04                       jmp     short loc_7FF91DFC9C03
00007FF91DFC9BFF  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFC9C03  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFC9C07  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFC9C0C  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFC9C0F  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFC9C13  F3 0F 11 BB 40 0A 00 00     movss   dword ptr [rbx+0A40h], xmm7
00007FF91DFC9C1B  0F 28 E7                    movaps  xmm4, xmm7
00007FF91DFC9C1E  F3 0F 10 9B 20 0B 00 00     movss   xmm3, dword ptr [rbx+0B20h]
00007FF91DFC9C26  F3 0F 10 93 70 0B 00 00     movss   xmm2, dword ptr [rbx+0B70h]
00007FF91DFC9C2E  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC9C31  F3 0F 59 8B 90 0B 00 00     mulss   xmm1, dword ptr [rbx+0B90h]
00007FF91DFC9C39  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC9C3C  F3 0F 58 A3 40 0B 00 00     addss   xmm4, dword ptr [rbx+0B40h]
00007FF91DFC9C44  F3 0F 5C BB 50 0A 00 00     subss   xmm7, dword ptr [rbx+0A50h]
00007FF91DFC9C4C  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFC9C50  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFC9C54  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC9C58  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC9C5C  F3 0F 11 8B 90 0A 00 00     movss   dword ptr [rbx+0A90h], xmm1
00007FF91DFC9C64  72 06                       jb      short loc_7FF91DFC9C6C
00007FF91DFC9C66  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFC9C6A  EB 03                       jmp     short loc_7FF91DFC9C6F
00007FF91DFC9C6C  0F 57 F6                    xorps   xmm6, xmm6
00007FF91DFC9C6F  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFC9C73  F3 0F 10 83 F0 0A 00 00     movss   xmm0, dword ptr [rbx+0AF0h]
00007FF91DFC9C7B  73 03                       jnb     short loc_7FF91DFC9C80
00007FF91DFC9C7D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFC9C80  F3 0F 59 83 70 0B 00 00     mulss   xmm0, dword ptr [rbx+0B70h]
00007FF91DFC9C88  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFC9C8B  F3 0F 10 93 E0 0A 00 00     movss   xmm2, dword ptr [rbx+0AE0h]
00007FF91DFC9C93  F3 44 0F 10 0D C0 B2 77 00  movss   xmm9, cs:dword_7FF91E744F5C
00007FF91DFC9C9C  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFC9CA0  F3 0F 11 B3 50 0A 00 00     movss   dword ptr [rbx+0A50h], xmm6
00007FF91DFC9CA8  F3 0F 10 8B 80 0B 00 00     movss   xmm1, dword ptr [rbx+0B80h]
00007FF91DFC9CB0  F3 0F 10 BB 00 0B 00 00     movss   xmm7, dword ptr [rbx+0B00h]
00007FF91DFC9CB8  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC9CBB  F3 0F 10 A3 80 0A 00 00     movss   xmm4, dword ptr [rbx+0A80h]
00007FF91DFC9CC3  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC9CC7  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFC9CCC  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFC9CD0  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFC9CD5  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFC9CD9  F3 0F 59 FE                 mulss   xmm7, xmm6
00007FF91DFC9CDD  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFC9CE1  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFC9CE5  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFC9CE9  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC9CEC  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFC9CF0  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFC9CF4  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFC9CF8  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFC9CFC  76 0B                       jbe     short loc_7FF91DFC9D09
00007FF91DFC9CFE  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFC9D01  F3 0F 58 9B 90 0A 00 00     addss   xmm3, dword ptr [rbx+0A90h]
00007FF91DFC9D09  F3 0F 10 83 70 0B 00 00     movss   xmm0, dword ptr [rbx+0B70h]
00007FF91DFC9D11  F3 0F 10 A3 30 0A 00 00     movss   xmm4, dword ptr [rbx+0A30h]
00007FF91DFC9D19  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFC9D1D  F3 0F 11 83 70 0A 00 00     movss   dword ptr [rbx+0A70h], xmm0
00007FF91DFC9D25  F3 0F 10 8B B0 0A 00 00     movss   xmm1, dword ptr [rbx+0AB0h]
00007FF91DFC9D2D  F3 0F 10 9B 10 0B 00 00     movss   xmm3, dword ptr [rbx+0B10h]
00007FF91DFC9D35  F3 0F 59 AB 60 0B 00 00     mulss   xmm5, dword ptr [rbx+0B60h]
00007FF91DFC9D3D  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFC9D42  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFC9D46  F3 0F 10 83 A0 0B 00 00     movss   xmm0, dword ptr [rbx+0BA0h]
00007FF91DFC9D4E  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFC9D53  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFC9D56  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC9D5A  F3 0F 58 EE                 addss   xmm5, xmm6
00007FF91DFC9D5E  F3 0F 59 D7                 mulss   xmm2, xmm7
00007FF91DFC9D62  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFC9D66  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC9D6A  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC9D6E  F3 0F 11 93 A0 0A 00 00     movss   dword ptr [rbx+0AA0h], xmm2
00007FF91DFC9D76  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFC9D7B  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFC9D80  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFC9D84  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFC9D88  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFC9D8C  F3 0F 11 9B 20 0A 00 00     movss   dword ptr [rbx+0A20h], xmm3
00007FF91DFC9D94  F3 0F 59 9B B0 0B 00 00     mulss   xmm3, dword ptr [rbx+0BB0h]
00007FF91DFC9D9C  F3 0F 59 9B C0 0B 00 00     mulss   xmm3, dword ptr [rbx+0BC0h]
00007FF91DFC9DA4  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC9DA7  F3 0F 59 83 D0 0B 00 00     mulss   xmm0, dword ptr [rbx+0BD0h]
00007FF91DFC9DAF  F3 0F 11 9B C0 0A 00 00     movss   dword ptr [rbx+0AC0h], xmm3
00007FF91DFC9DB7  F3 0F 11 83 D0 0A 00 00     movss   dword ptr [rbx+0AD0h], xmm0
00007FF91DFC9DBF  44 0F 2F B3 20 07 00 00     comiss  xmm14, dword ptr [rbx+720h]
00007FF91DFC9DC7  F3 0F 10 8B 30 02 00 00     movss   xmm1, dword ptr [rbx+230h]
00007FF91DFC9DCF  F3 0F 10 93 E0 0B 00 00     movss   xmm2, dword ptr [rbx+0BE0h]
00007FF91DFC9DD7  73 06                       jnb     short loc_7FF91DFC9DDF
00007FF91DFC9DD9  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFC9DDD  EB 03                       jmp     short loc_7FF91DFC9DE2
00007FF91DFC9DDF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFC9DE2  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFC9DE6  75 04                       jnz     short loc_7FF91DFC9DEC
00007FF91DFC9DE8  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFC9DEC  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFC9DF0  F3 0F 11 8B F0 0B 00 00     movss   dword ptr [rbx+0BF0h], xmm1
00007FF91DFC9DF8  8B 83 00 0C 00 00           mov     eax, [rbx+0C00h]
00007FF91DFC9DFE  89 83 10 0C 00 00           mov     [rbx+0C10h], eax
00007FF91DFC9E04  8B 83 30 0C 00 00           mov     eax, [rbx+0C30h]
00007FF91DFC9E0A  89 83 40 0C 00 00           mov     [rbx+0C40h], eax
00007FF91DFC9E10  8B 83 20 0C 00 00           mov     eax, [rbx+0C20h]
00007FF91DFC9E16  89 83 30 0C 00 00           mov     [rbx+0C30h], eax
00007FF91DFC9E1C  8B 83 50 0C 00 00           mov     eax, [rbx+0C50h]
00007FF91DFC9E22  89 83 60 0C 00 00           mov     [rbx+0C60h], eax
00007FF91DFC9E28  8B 83 80 0C 00 00           mov     eax, [rbx+0C80h]
00007FF91DFC9E2E  89 83 90 0C 00 00           mov     [rbx+0C90h], eax
00007FF91DFC9E34  F3 0F 10 83 30 0D 00 00     movss   xmm0, dword ptr [rbx+0D30h]
00007FF91DFC9E3C  F3 0F 58 8B 10 0D 00 00     addss   xmm1, dword ptr [rbx+0D10h]
00007FF91DFC9E44  F3 0F 59 83 40 0C 00 00     mulss   xmm0, dword ptr [rbx+0C40h]
00007FF91DFC9E4C  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFC9E50  F3 0F 58 83 10 0C 00 00     addss   xmm0, dword ptr [rbx+0C10h]
00007FF91DFC9E58  73 06                       jnb     short loc_7FF91DFC9E60
00007FF91DFC9E5A  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFC9E5E  EB 04                       jmp     short loc_7FF91DFC9E64
00007FF91DFC9E60  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFC9E64  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFC9E68  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFC9E6D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFC9E70  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFC9E74  F3 0F 11 B3 20 0C 00 00     movss   dword ptr [rbx+0C20h], xmm6
00007FF91DFC9E7C  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFC9E7F  F3 0F 10 9B 00 0D 00 00     movss   xmm3, dword ptr [rbx+0D00h]
00007FF91DFC9E87  F3 0F 10 93 50 0D 00 00     movss   xmm2, dword ptr [rbx+0D50h]
00007FF91DFC9E8F  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC9E92  F3 0F 59 8B 70 0D 00 00     mulss   xmm1, dword ptr [rbx+0D70h]
00007FF91DFC9E9A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFC9E9D  F3 0F 58 A3 20 0D 00 00     addss   xmm4, dword ptr [rbx+0D20h]
00007FF91DFC9EA5  F3 0F 5C B3 30 0C 00 00     subss   xmm6, dword ptr [rbx+0C30h]
00007FF91DFC9EAD  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFC9EB1  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFC9EB5  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFC9EB9  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFC9EBD  F3 0F 11 8B 70 0C 00 00     movss   dword ptr [rbx+0C70h], xmm1
00007FF91DFC9EC5  72 06                       jb      short loc_7FF91DFC9ECD
00007FF91DFC9EC7  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFC9ECB  EB 03                       jmp     short loc_7FF91DFC9ED0
00007FF91DFC9ECD  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFC9ED0  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFC9ED4  F3 0F 10 83 D0 0C 00 00     movss   xmm0, dword ptr [rbx+0CD0h]
00007FF91DFC9EDC  73 03                       jnb     short loc_7FF91DFC9EE1
00007FF91DFC9EDE  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFC9EE1  F3 0F 59 83 50 0D 00 00     mulss   xmm0, dword ptr [rbx+0D50h]
00007FF91DFC9EE9  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFC9EEC  F3 0F 10 93 C0 0C 00 00     movss   xmm2, dword ptr [rbx+0CC0h]
00007FF91DFC9EF4  F3 0F 11 BB 30 0C 00 00     movss   dword ptr [rbx+0C30h], xmm7
00007FF91DFC9EFC  F3 0F 10 8B 60 0D 00 00     movss   xmm1, dword ptr [rbx+0D60h]
00007FF91DFC9F04  F3 0F 10 B3 E0 0C 00 00     movss   xmm6, dword ptr [rbx+0CE0h]
00007FF91DFC9F0C  F3 0F 10 A3 60 0C 00 00     movss   xmm4, dword ptr [rbx+0C60h]
00007FF91DFC9F14  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFC9F18  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFC9F1B  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFC9F1F  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFC9F24  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFC9F28  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFC9F2D  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFC9F31  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFC9F35  F3 0F 5C C7                 subss   xmm0, xmm7
00007FF91DFC9F39  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFC9F3D  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFC9F41  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFC9F44  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFC9F48  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFC9F4C  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFC9F50  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFC9F54  76 0B                       jbe     short loc_7FF91DFC9F61
00007FF91DFC9F56  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFC9F59  F3 0F 58 9B 70 0C 00 00     addss   xmm3, dword ptr [rbx+0C70h]
00007FF91DFC9F61  F3 0F 10 A3 10 0C 00 00     movss   xmm4, dword ptr [rbx+0C10h]
00007FF91DFC9F69  F3 0F 10 83 50 0D 00 00     movss   xmm0, dword ptr [rbx+0D50h]
00007FF91DFC9F71  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFC9F75  F3 0F 11 83 50 0C 00 00     movss   dword ptr [rbx+0C50h], xmm0
00007FF91DFC9F7D  F3 0F 59 AB 40 0D 00 00     mulss   xmm5, dword ptr [rbx+0D40h]
00007FF91DFC9F85  F3 0F 10 8B 90 0C 00 00     movss   xmm1, dword ptr [rbx+0C90h]
00007FF91DFC9F8D  F3 0F 10 9B F0 0C 00 00     movss   xmm3, dword ptr [rbx+0CF0h]
00007FF91DFC9F95  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFC9F99  F3 0F 10 83 80 0D 00 00     movss   xmm0, dword ptr [rbx+0D80h]
00007FF91DFC9FA1  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFC9FA4  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFC9FA9  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFC9FAD  F3 0F 58 EF                 addss   xmm5, xmm7
00007FF91DFC9FB1  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFC9FB6  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFC9FBA  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFC9FBE  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFC9FC2  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFC9FC6  F3 0F 11 93 80 0C 00 00     movss   dword ptr [rbx+0C80h], xmm2
00007FF91DFC9FCE  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFC9FD3  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFC9FD8  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFC9FDC  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFC9FE0  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFC9FE4  F3 0F 11 9B 00 0C 00 00     movss   dword ptr [rbx+0C00h], xmm3
00007FF91DFC9FEC  F3 0F 59 9B 90 0D 00 00     mulss   xmm3, dword ptr [rbx+0D90h]
00007FF91DFC9FF4  F3 0F 59 9B A0 0D 00 00     mulss   xmm3, dword ptr [rbx+0DA0h]
00007FF91DFC9FFC  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFC9FFF  F3 0F 59 83 B0 0D 00 00     mulss   xmm0, dword ptr [rbx+0DB0h]
00007FF91DFCA007  F3 0F 11 9B A0 0C 00 00     movss   dword ptr [rbx+0CA0h], xmm3
00007FF91DFCA00F  F3 0F 11 83 B0 0C 00 00     movss   dword ptr [rbx+0CB0h], xmm0
00007FF91DFCA017  8B 83 C0 0D 00 00           mov     eax, [rbx+0DC0h]
00007FF91DFCA01D  89 83 D0 0D 00 00           mov     [rbx+0DD0h], eax
00007FF91DFCA023  8B 83 E0 0D 00 00           mov     eax, [rbx+0DE0h]
00007FF91DFCA029  89 83 F0 0D 00 00           mov     [rbx+0DF0h], eax
00007FF91DFCA02F  F3 0F 10 83 F0 02 00 00     movss   xmm0, dword ptr [rbx+2F0h]
00007FF91DFCA037  F3 44 0F 10 83 70 03 00 00  movss   xmm8, dword ptr [rbx+370h]
00007FF91DFCA040  8B 83 20 0E 00 00           mov     eax, [rbx+0E20h]
00007FF91DFCA046  89 83 30 0E 00 00           mov     [rbx+0E30h], eax
00007FF91DFCA04C  F3 0F 59 83 00 0E 00 00     mulss   xmm0, dword ptr [rbx+0E00h]
00007FF91DFCA054  F3 44 0F 59 83 10 0E 00 00  mulss   xmm8, dword ptr [rbx+0E10h]
00007FF91DFCA05D  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFCA062  F3 44 0F 11 83 20 0E 00 00  movss   dword ptr [rbx+0E20h], xmm8
00007FF91DFCA06B  F3 0F 10 BB 00 07 00 00     movss   xmm7, dword ptr [rbx+700h]
00007FF91DFCA073  F3 0F 10 8B C0 0A 00 00     movss   xmm1, dword ptr [rbx+0AC0h]
00007FF91DFCA07B  F3 0F 10 93 A0 0C 00 00     movss   xmm2, dword ptr [rbx+0CA0h]
00007FF91DFCA083  F3 0F 10 83 F0 02 00 00     movss   xmm0, dword ptr [rbx+2F0h]
00007FF91DFCA08B  8B 83 E0 0D 00 00           mov     eax, [rbx+0DE0h]
00007FF91DFCA091  89 83 60 0E 00 00           mov     [rbx+0E60h], eax
00007FF91DFCA097  F3 0F 11 83 70 0E 00 00     movss   dword ptr [rbx+0E70h], xmm0
00007FF91DFCA09F  F3 0F 10 A3 B0 0F 00 00     movss   xmm4, dword ptr [rbx+0FB0h]
00007FF91DFCA0A7  F3 0F 11 8B 40 0E 00 00     movss   dword ptr [rbx+0E40h], xmm1
00007FF91DFCA0AF  F3 0F 11 93 50 0E 00 00     movss   dword ptr [rbx+0E50h], xmm2
00007FF91DFCA0B7  F3 0F 10 AB 90 0F 00 00     movss   xmm5, dword ptr [rbx+0F90h]
00007FF91DFCA0BF  F3 0F 59 FC                 mulss   xmm7, xmm4
00007FF91DFCA0C3  F3 0F 59 A3 10 07 00 00     mulss   xmm4, dword ptr [rbx+710h]
00007FF91DFCA0CB  F3 0F 11 A3 80 0E 00 00     movss   dword ptr [rbx+0E80h], xmm4
00007FF91DFCA0D3  F3 0F 10 8B 10 0F 00 00     movss   xmm1, dword ptr [rbx+0F10h]
00007FF91DFCA0DB  F3 0F 10 93 10 10 00 00     movss   xmm2, dword ptr [rbx+1010h]
00007FF91DFCA0E3  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFCA0E6  F3 0F 59 BB C0 0F 00 00     mulss   xmm7, dword ptr [rbx+0FC0h]
00007FF91DFCA0EE  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCA0F1  F3 0F 10 B3 D0 0F 00 00     movss   xmm6, dword ptr [rbx+0FD0h]
00007FF91DFCA0F9  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCA0FD  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFCA101  F3 0F 59 EC                 mulss   xmm5, xmm4
00007FF91DFCA105  F3 0F 59 AB A0 0F 00 00     mulss   xmm5, dword ptr [rbx+0FA0h]
00007FF91DFCA10D  F3 0F 11 AB A0 0E 00 00     movss   dword ptr [rbx+0EA0h], xmm5
00007FF91DFCA115  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFCA119  F3 0F 59 9B 60 0E 00 00     mulss   xmm3, dword ptr [rbx+0E60h]
00007FF91DFCA121  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCA125  F3 0F 10 83 20 0F 00 00     movss   xmm0, dword ptr [rbx+0F20h]
00007FF91DFCA12D  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFCA131  F3 0F 59 9B 20 10 00 00     mulss   xmm3, dword ptr [rbx+1020h]
00007FF91DFCA139  F3 0F 11 9B B0 0E 00 00     movss   dword ptr [rbx+0EB0h], xmm3
00007FF91DFCA141  F3 0F 10 8B F0 0F 00 00     movss   xmm1, dword ptr [rbx+0FF0h]
00007FF91DFCA149  F3 0F 59 8B 50 0E 00 00     mulss   xmm1, dword ptr [rbx+0E50h]
00007FF91DFCA151  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCA155  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFCA159  F3 0F 10 83 E0 0F 00 00     movss   xmm0, dword ptr [rbx+0FE0h]
00007FF91DFCA161  F3 0F 59 83 40 0E 00 00     mulss   xmm0, dword ptr [rbx+0E40h]
00007FF91DFCA169  F3 0F 10 9B 80 0E 00 00     movss   xmm3, dword ptr [rbx+0E80h]
00007FF91DFCA171  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCA175  F3 0F 10 83 00 0F 00 00     movss   xmm0, dword ptr [rbx+0F00h]
00007FF91DFCA17D  F3 0F 59 8B 00 10 00 00     mulss   xmm1, dword ptr [rbx+1000h]
00007FF91DFCA185  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFCA189  F3 41 0F 58 C8              addss   xmm1, xmm8
00007FF91DFCA18E  F3 0F 58 8B 70 0F 00 00     addss   xmm1, dword ptr [rbx+0F70h]
00007FF91DFCA196  F3 0F 58 8B 80 0F 00 00     addss   xmm1, dword ptr [rbx+0F80h]
00007FF91DFCA19E  F3 0F 11 8B C0 0E 00 00     movss   dword ptr [rbx+0EC0h], xmm1
00007FF91DFCA1A6  F3 0F 11 83 D0 0E 00 00     movss   dword ptr [rbx+0ED0h], xmm0
00007FF91DFCA1AE  F3 0F 59 9B 40 10 00 00     mulss   xmm3, dword ptr [rbx+1040h]
00007FF91DFCA1B6  F3 0F 10 83 40 0F 00 00     movss   xmm0, dword ptr [rbx+0F40h]
00007FF91DFCA1BE  F3 0F 59 83 40 0E 00 00     mulss   xmm0, dword ptr [rbx+0E40h]
00007FF91DFCA1C6  F3 0F 58 9B 50 10 00 00     addss   xmm3, dword ptr [rbx+1050h]
00007FF91DFCA1CE  F3 0F 10 8B 50 0F 00 00     movss   xmm1, dword ptr [rbx+0F50h]
00007FF91DFCA1D6  F3 0F 59 8B 50 0E 00 00     mulss   xmm1, dword ptr [rbx+0E50h]
00007FF91DFCA1DE  F3 0F 10 93 A0 0E 00 00     movss   xmm2, dword ptr [rbx+0EA0h]
00007FF91DFCA1E6  F3 0F 59 9B 30 0F 00 00     mulss   xmm3, dword ptr [rbx+0F30h]
00007FF91DFCA1EE  F3 0F 58 93 70 0E 00 00     addss   xmm2, dword ptr [rbx+0E70h]
00007FF91DFCA1F6  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCA1FA  F3 0F 58 93 B0 0E 00 00     addss   xmm2, dword ptr [rbx+0EB0h]
00007FF91DFCA202  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCA206  F3 0F 58 9B 60 0F 00 00     addss   xmm3, dword ptr [rbx+0F60h]
00007FF91DFCA20E  F3 0F 59 9B 30 10 00 00     mulss   xmm3, dword ptr [rbx+1030h]
00007FF91DFCA216  F3 0F 11 9B E0 0E 00 00     movss   dword ptr [rbx+0EE0h], xmm3
00007FF91DFCA21E  F3 0F 11 93 F0 0E 00 00     movss   dword ptr [rbx+0EF0h], xmm2
00007FF91DFCA226  F3 0F 10 83 70 10 00 00     movss   xmm0, dword ptr [rbx+1070h]
00007FF91DFCA22E  8B 83 60 10 00 00           mov     eax, [rbx+1060h]
00007FF91DFCA234  89 83 90 10 00 00           mov     [rbx+1090h], eax
00007FF91DFCA23A  F3 0F 11 83 A0 10 00 00     movss   dword ptr [rbx+10A0h], xmm0
00007FF91DFCA242  8B 83 80 10 00 00           mov     eax, [rbx+1080h]
00007FF91DFCA248  89 83 B0 10 00 00           mov     [rbx+10B0h], eax
00007FF91DFCA24E  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
00007FF91DFCA256  8B 83 D0 10 00 00           mov     eax, [rbx+10D0h]
00007FF91DFCA25C  89 83 E0 10 00 00           mov     [rbx+10E0h], eax
00007FF91DFCA262  F3 0F 10 93 C0 10 00 00     movss   xmm2, dword ptr [rbx+10C0h]
00007FF91DFCA26A  F3 0F 11 93 D0 10 00 00     movss   dword ptr [rbx+10D0h], xmm2
00007FF91DFCA272  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCA275  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCA278  F3 0F 59 9B F0 10 00 00     mulss   xmm3, dword ptr [rbx+10F0h]
00007FF91DFCA280  F3 0F 58 9B E0 10 00 00     addss   xmm3, dword ptr [rbx+10E0h]
00007FF91DFCA288  F3 0F 11 9B D0 10 00 00     movss   dword ptr [rbx+10D0h], xmm3
00007FF91DFCA290  F3 0F 59 83 00 11 00 00     mulss   xmm0, dword ptr [rbx+1100h]
00007FF91DFCA298  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFCA29C  F3 0F 59 9B 30 11 00 00     mulss   xmm3, dword ptr [rbx+1130h]
00007FF91DFCA2A4  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFCA2A8  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFCA2AB  F3 0F 59 8B F0 10 00 00     mulss   xmm1, dword ptr [rbx+10F0h]
00007FF91DFCA2B3  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCA2B7  F3 0F 11 8B C0 10 00 00     movss   dword ptr [rbx+10C0h], xmm1
00007FF91DFCA2BF  F3 0F 59 8B 20 11 00 00     mulss   xmm1, dword ptr [rbx+1120h]
00007FF91DFCA2C7  F3 0F 59 A3 10 11 00 00     mulss   xmm4, dword ptr [rbx+1110h]
00007FF91DFCA2CF  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCA2D3  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCA2D7  F3 0F 11 A3 E0 10 00 00     movss   dword ptr [rbx+10E0h], xmm4
00007FF91DFCA2DF  8B 83 10 19 00 00           mov     eax, [rbx+1910h]
00007FF91DFCA2E5  89 83 20 19 00 00           mov     [rbx+1920h], eax
00007FF91DFCA2EB  F3 0F 10 8B 30 19 00 00     movss   xmm1, dword ptr [rbx+1930h]
00007FF91DFCA2F3  F3 0F 11 8B 40 19 00 00     movss   dword ptr [rbx+1940h], xmm1
00007FF91DFCA2FB  F3 0F 59 8B D0 0D 00 00     mulss   xmm1, dword ptr [rbx+0DD0h]
00007FF91DFCA303  F3 0F 10 83 20 19 00 00     movss   xmm0, dword ptr [rbx+1920h]
00007FF91DFCA30B  F3 0F 59 83 E0 10 00 00     mulss   xmm0, dword ptr [rbx+10E0h]
00007FF91DFCA313  F3 0F 11 8B 50 19 00 00     movss   dword ptr [rbx+1950h], xmm1
00007FF91DFCA31B  F3 0F 11 83 60 19 00 00     movss   dword ptr [rbx+1960h], xmm0
00007FF91DFCA323  8B 83 90 19 00 00           mov     eax, [rbx+1990h]
00007FF91DFCA329  89 83 A0 19 00 00           mov     [rbx+19A0h], eax
00007FF91DFCA32F  F3 0F 59 8B 70 19 00 00     mulss   xmm1, dword ptr [rbx+1970h]
00007FF91DFCA337  F3 0F 59 83 80 19 00 00     mulss   xmm0, dword ptr [rbx+1980h]
00007FF91DFCA33F  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFCA343  F3 0F 11 83 90 19 00 00     movss   dword ptr [rbx+1990h], xmm0
00007FF91DFCA34B  8B 83 B0 19 00 00           mov     eax, [rbx+19B0h]
00007FF91DFCA351  89 83 C0 19 00 00           mov     [rbx+19C0h], eax
00007FF91DFCA357  8B 83 D0 19 00 00           mov     eax, [rbx+19D0h]
00007FF91DFCA35D  89 83 E0 19 00 00           mov     [rbx+19E0h], eax
00007FF91DFCA363  8B 83 F0 19 00 00           mov     eax, [rbx+19F0h]
00007FF91DFCA369  89 83 00 1A 00 00           mov     [rbx+1A00h], eax
00007FF91DFCA36F  8B 83 10 1A 00 00           mov     eax, [rbx+1A10h]
00007FF91DFCA375  89 83 20 1A 00 00           mov     [rbx+1A20h], eax
00007FF91DFCA37B  F3 0F 10 8B 40 1A 00 00     movss   xmm1, dword ptr [rbx+1A40h]
00007FF91DFCA383  F3 0F 10 93 50 1A 00 00     movss   xmm2, dword ptr [rbx+1A50h]
00007FF91DFCA38B  0F 28 E1                    movaps  xmm4, xmm1
00007FF91DFCA38E  F3 0F 59 A3 B0 19 00 00     mulss   xmm4, dword ptr [rbx+19B0h]
00007FF91DFCA396  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCA399  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCA39D  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFCA3A1  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFCA3A5  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFCA3A8  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFCA3AB  F3 0F 59 8B 70 1A 00 00     mulss   xmm1, dword ptr [rbx+1A70h]
00007FF91DFCA3B3  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCA3B7  F3 0F 58 8B 60 1A 00 00     addss   xmm1, dword ptr [rbx+1A60h]
00007FF91DFCA3BF  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCA3C2  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCA3C6  F3 0F 59 83 80 1A 00 00     mulss   xmm0, dword ptr [rbx+1A80h]
00007FF91DFCA3CE  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCA3D2  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCA3D5  F3 0F 59 9B 90 1A 00 00     mulss   xmm3, dword ptr [rbx+1A90h]
00007FF91DFCA3DD  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCA3E1  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCA3E5  F3 0F 59 83 A0 1A 00 00     mulss   xmm0, dword ptr [rbx+1AA0h]
00007FF91DFCA3ED  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFCA3F1  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCA3F5  76 05                       jbe     short loc_7FF91DFCA3FC
00007FF91DFCA3F7  0F 5A C0                    cvtps2pd xmm0, xmm0
00007FF91DFCA3FA  EB 03                       jmp     short loc_7FF91DFCA3FF
00007FF91DFCA3FC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCA3FF  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFCA403  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFCA407  73 04                       jnb     short loc_7FF91DFCA40D
00007FF91DFCA409  44 0F 5A E1                 cvtps2pd xmm12, xmm1
00007FF91DFCA40D  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
00007FF91DFCA412  F3 0F 11 83 30 1A 00 00     movss   dword ptr [rbx+1A30h], xmm0
00007FF91DFCA41A  8B 83 B0 1A 00 00           mov     eax, [rbx+1AB0h]
00007FF91DFCA420  89 83 C0 1A 00 00           mov     [rbx+1AC0h], eax
00007FF91DFCA426  F3 0F 10 8B D0 1A 00 00     movss   xmm1, dword ptr [rbx+1AD0h]
00007FF91DFCA42E  F3 0F 11 8B E0 1A 00 00     movss   dword ptr [rbx+1AE0h], xmm1
00007FF91DFCA436  F3 0F 10 83 F0 1A 00 00     movss   xmm0, dword ptr [rbx+1AF0h]
00007FF91DFCA43E  F3 0F 11 83 00 1B 00 00     movss   dword ptr [rbx+1B00h], xmm0
00007FF91DFCA446  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFCA44A  F3 0F 59 8B 10 1B 00 00     mulss   xmm1, dword ptr [rbx+1B10h]
00007FF91DFCA452  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCA456  F3 0F 11 8B F0 1A 00 00     movss   dword ptr [rbx+1AF0h], xmm1
00007FF91DFCA45E  F3 0F 10 8B F0 02 00 00     movss   xmm1, dword ptr [rbx+2F0h]
00007FF91DFCA466  F3 0F 10 83 70 03 00 00     movss   xmm0, dword ptr [rbx+370h]
00007FF91DFCA46E  8B 83 40 1B 00 00           mov     eax, [rbx+1B40h]
00007FF91DFCA474  89 83 50 1B 00 00           mov     [rbx+1B50h], eax
00007FF91DFCA47A  F3 0F 59 83 30 1B 00 00     mulss   xmm0, dword ptr [rbx+1B30h]
00007FF91DFCA482  F3 0F 59 8B 20 1B 00 00     mulss   xmm1, dword ptr [rbx+1B20h]
00007FF91DFCA48A  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFCA48E  F3 0F 11 83 40 1B 00 00     movss   dword ptr [rbx+1B40h], xmm0
00007FF91DFCA496  8B 83 60 1B 00 00           mov     eax, [rbx+1B60h]
00007FF91DFCA49C  89 83 80 1B 00 00           mov     [rbx+1B80h], eax
00007FF91DFCA4A2  F3 0F 10 9B 70 1B 00 00     movss   xmm3, dword ptr [rbx+1B70h]
00007FF91DFCA4AA  F3 0F 11 9B 90 1B 00 00     movss   dword ptr [rbx+1B90h], xmm3
00007FF91DFCA4B2  F3 0F 10 8B 80 1B 00 00     movss   xmm1, dword ptr [rbx+1B80h]
00007FF91DFCA4BA  F3 0F 10 93 C0 0A 00 00     movss   xmm2, dword ptr [rbx+0AC0h]
00007FF91DFCA4C2  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCA4C5  F3 0F 59 83 A0 0C 00 00     mulss   xmm0, dword ptr [rbx+0CA0h]
00007FF91DFCA4CD  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFCA4D1  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFCA4D5  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCA4D8  F3 0F 59 8B F0 19 00 00     mulss   xmm1, dword ptr [rbx+19F0h]
00007FF91DFCA4E0  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCA4E4  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFCA4E8  F3 0F 5C CB                 subss   xmm1, xmm3
00007FF91DFCA4EC  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCA4F0  F3 0F 11 8B A0 1B 00 00     movss   dword ptr [rbx+1BA0h], xmm1
00007FF91DFCA4F8  F3 0F 10 9B 00 07 00 00     movss   xmm3, dword ptr [rbx+700h]
00007FF91DFCA500  F3 0F 10 83 B0 1B 00 00     movss   xmm0, dword ptr [rbx+1BB0h]
00007FF91DFCA508  F3 0F 11 83 C0 1B 00 00     movss   dword ptr [rbx+1BC0h], xmm0
00007FF91DFCA510  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCA514  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCA517  F3 0F 59 8B D0 1B 00 00     mulss   xmm1, dword ptr [rbx+1BD0h]
00007FF91DFCA51F  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCA523  F3 0F 10 83 F0 1B 00 00     movss   xmm0, dword ptr [rbx+1BF0h]
00007FF91DFCA52B  F3 0F 11 8B B0 1B 00 00     movss   dword ptr [rbx+1BB0h], xmm1
00007FF91DFCA533  F3 0F 59 9B E0 1B 00 00     mulss   xmm3, dword ptr [rbx+1BE0h]
00007FF91DFCA53B  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCA53F  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCA543  F3 0F 11 9B C0 1B 00 00     movss   dword ptr [rbx+1BC0h], xmm3
00007FF91DFCA54B  F3 0F 10 83 00 1C 00 00     movss   xmm0, dword ptr [rbx+1C00h]
00007FF91DFCA553  F3 0F 10 BB 10 07 00 00     movss   xmm7, dword ptr [rbx+710h]
00007FF91DFCA55B  F3 0F 11 83 10 1C 00 00     movss   dword ptr [rbx+1C10h], xmm0
00007FF91DFCA563  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFCA567  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFCA56A  F3 0F 59 8B 20 1C 00 00     mulss   xmm1, dword ptr [rbx+1C20h]
00007FF91DFCA572  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCA576  F3 0F 10 83 40 1C 00 00     movss   xmm0, dword ptr [rbx+1C40h]
00007FF91DFCA57E  F3 0F 11 8B 00 1C 00 00     movss   dword ptr [rbx+1C00h], xmm1
00007FF91DFCA586  F3 0F 59 BB 30 1C 00 00     mulss   xmm7, dword ptr [rbx+1C30h]
00007FF91DFCA58E  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCA592  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFCA596  F3 0F 11 BB 10 1C 00 00     movss   dword ptr [rbx+1C10h], xmm7
00007FF91DFCA59E  F3 0F 10 A3 C0 1B 00 00     movss   xmm4, dword ptr [rbx+1BC0h]
00007FF91DFCA5A6  F3 0F 10 AB A0 1B 00 00     movss   xmm5, dword ptr [rbx+1BA0h]
00007FF91DFCA5AE  F3 0F 10 B3 40 1B 00 00     movss   xmm6, dword ptr [rbx+1B40h]
00007FF91DFCA5B6  F3 44 0F 10 8B D0 19 00 00  movss   xmm9, dword ptr [rbx+19D0h]
00007FF91DFCA5BF  8B 83 F0 1A 00 00           mov     eax, [rbx+1AF0h]
00007FF91DFCA5C5  89 83 50 1C 00 00           mov     [rbx+1C50h], eax
00007FF91DFCA5CB  F3 44 0F 11 8B 60 1C 00 00  movss   dword ptr [rbx+1C60h], xmm9
00007FF91DFCA5D4  F3 0F 10 83 80 1C 00 00     movss   xmm0, dword ptr [rbx+1C80h]
00007FF91DFCA5DC  F3 0F 10 93 90 1C 00 00     movss   xmm2, dword ptr [rbx+1C90h]
00007FF91DFCA5E4  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFCA5E8  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCA5EB  F3 0F 59 9B 10 1A 00 00     mulss   xmm3, dword ptr [rbx+1A10h]
00007FF91DFCA5F3  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCA5F7  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCA5FA  F3 0F 59 C7                 mulss   xmm0, xmm7
00007FF91DFCA5FE  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFCA602  F3 44 0F 5C C0              subss   xmm8, xmm0
00007FF91DFCA607  F3 44 0F 58 C7              addss   xmm8, xmm7
00007FF91DFCA60C  F3 44 0F 59 83 C0 1C 00 00  mulss   xmm8, dword ptr [rbx+1CC0h]
00007FF91DFCA615  F3 0F 10 8B A0 1C 00 00     movss   xmm1, dword ptr [rbx+1CA0h]
00007FF91DFCA61D  F3 0F 58 B3 40 1D 00 00     addss   xmm6, dword ptr [rbx+1D40h]
00007FF91DFCA625  F3 44 0F 59 83 D0 1C 00 00  mulss   xmm8, dword ptr [rbx+1CD0h]
00007FF91DFCA62E  F3 0F 59 AB E0 1C 00 00     mulss   xmm5, dword ptr [rbx+1CE0h]
00007FF91DFCA636  F3 0F 59 B3 F0 1C 00 00     mulss   xmm6, dword ptr [rbx+1CF0h]
00007FF91DFCA63E  F3 44 0F 59 C9              mulss   xmm9, xmm1
00007FF91DFCA643  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFCA647  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFCA64B  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFCA64F  F3 0F 10 93 20 1D 00 00     movss   xmm2, dword ptr [rbx+1D20h]
00007FF91DFCA657  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCA65A  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCA65E  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFCA662  F3 44 0F 5C C8              subss   xmm9, xmm0
00007FF91DFCA667  F3 0F 10 83 10 1D 00 00     movss   xmm0, dword ptr [rbx+1D10h]
00007FF91DFCA66F  F3 0F 58 83 50 1C 00 00     addss   xmm0, dword ptr [rbx+1C50h]
00007FF91DFCA677  F3 0F 59 9B B0 1C 00 00     mulss   xmm3, dword ptr [rbx+1CB0h]
00007FF91DFCA67F  F3 0F 59 83 50 1D 00 00     mulss   xmm0, dword ptr [rbx+1D50h]
00007FF91DFCA687  F3 44 0F 58 CA              addss   xmm9, xmm2
00007FF91DFCA68C  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFCA691  F3 0F 59 83 00 1D 00 00     mulss   xmm0, dword ptr [rbx+1D00h]
00007FF91DFCA699  F3 44 0F 59 8B 30 1D 00 00  mulss   xmm9, dword ptr [rbx+1D30h]
00007FF91DFCA6A2  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFCA6A7  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFCA6AC  F3 45 0F 58 C8              addss   xmm9, xmm8
00007FF91DFCA6B1  F3 44 0F 11 8B 70 1C 00 00  movss   dword ptr [rbx+1C70h], xmm9
00007FF91DFCA6BA  F3 0F 10 BB 30 1A 00 00     movss   xmm7, dword ptr [rbx+1A30h]
00007FF91DFCA6C2  F3 44 0F 10 83 C0 1A 00 00  movss   xmm8, dword ptr [rbx+1AC0h]
00007FF91DFCA6CB  8B 83 90 1D 00 00           mov     eax, [rbx+1D90h]
00007FF91DFCA6D1  89 83 A0 1D 00 00           mov     [rbx+1DA0h], eax
00007FF91DFCA6D7  F3 0F 10 83 80 1D 00 00     movss   xmm0, dword ptr [rbx+1D80h]
00007FF91DFCA6DF  F3 0F 11 83 90 1D 00 00     movss   dword ptr [rbx+1D90h], xmm0
00007FF91DFCA6E7  44 0F 2E AB D0 1D 00 00     ucomiss xmm13, dword ptr [rbx+1DD0h]
00007FF91DFCA6EF  0F 85 8F 02 00 00           jnz     loc_7FF91DFCA984
00007FF91DFCA6F5  F3 0F 10 8B 20 1E 00 00     movss   xmm1, dword ptr [rbx+1E20h]
00007FF91DFCA6FD  F3 0F 10 B3 A0 1D 00 00     movss   xmm6, dword ptr [rbx+1DA0h]
00007FF91DFCA705  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFCA708  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFCA70C  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFCA710  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFCA714  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFCA718  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFCA71C  F3 0F 11 B3 90 1D 00 00     movss   dword ptr [rbx+1D90h], xmm6
00007FF91DFCA724  F3 0F 59 B3 10 1E 00 00     mulss   xmm6, dword ptr [rbx+1E10h]
00007FF91DFCA72C  F3 0F 58 B3 B0 1D 00 00     addss   xmm6, dword ptr [rbx+1DB0h]
00007FF91DFCA734  E8 27 E6 FF FF              call    sub_7FF91DFC8D60
00007FF91DFCA739  F3 0F 11 83 80 1D 00 00     movss   dword ptr [rbx+1D80h], xmm0
00007FF91DFCA741  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFCA745  F3 0F 59 8B 70 1E 00 00     mulss   xmm1, dword ptr [rbx+1E70h]
00007FF91DFCA74D  41 0F 28 D5                 movaps  xmm2, xmm13
00007FF91DFCA751  F3 41 0F 5C D0              subss   xmm2, xmm8
00007FF91DFCA756  F3 0F 58 8B C0 1D 00 00     addss   xmm1, dword ptr [rbx+1DC0h]
00007FF91DFCA75E  F3 0F 59 93 30 1E 00 00     mulss   xmm2, dword ptr [rbx+1E30h]
00007FF91DFCA766  F3 0F 11 8B 70 1D 00 00     movss   dword ptr [rbx+1D70h], xmm1
00007FF91DFCA76E  F3 44 0F 59 8B 00 1E 00 00  mulss   xmm9, dword ptr [rbx+1E00h]
00007FF91DFCA777  F3 0F 59 BB E0 1D 00 00     mulss   xmm7, dword ptr [rbx+1DE0h]
00007FF91DFCA77F  F3 0F 10 83 40 1E 00 00     movss   xmm0, dword ptr [rbx+1E40h]
00007FF91DFCA787  F3 0F 5D C2                 minss   xmm0, xmm2
00007FF91DFCA78B  F3 44 0F 58 CF              addss   xmm9, xmm7
00007FF91DFCA790  F3 44 0F 58 CE              addss   xmm9, xmm6
00007FF91DFCA795  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFCA79A  F3 44 0F 58 8B F0 1D 00 00  addss   xmm9, dword ptr [rbx+1DF0h]
00007FF91DFCA7A3  F3 44 0F 5D 8B 50 1E 00 00  minss   xmm9, dword ptr [rbx+1E50h]
00007FF91DFCA7AC  F3 44 0F 5F 8B 60 1E 00 00  maxss   xmm9, dword ptr [rbx+1E60h]
00007FF91DFCA7B5  F3 44 0F 59 8B 90 1E 00 00  mulss   xmm9, dword ptr [rbx+1E90h]
00007FF91DFCA7BE  F3 44 0F 58 8B A0 1E 00 00  addss   xmm9, dword ptr [rbx+1EA0h]
00007FF91DFCA7C7  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFCA7CB  F3 0F 2C C9                 cvttss2si ecx, xmm1
00007FF91DFCA7CF  81 F9 00 00 00 80           cmp     ecx, 80000000h
00007FF91DFCA7D5  74 1E                       jz      short loc_7FF91DFCA7F5
00007FF91DFCA7D7  66 0F 6E C1                 movd    xmm0, ecx
00007FF91DFCA7DB  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFCA7DE  0F 2E C1                    ucomiss xmm0, xmm1
00007FF91DFCA7E1  74 12                       jz      short loc_7FF91DFCA7F5
00007FF91DFCA7E3  0F 14 C9                    unpcklps xmm1, xmm1
00007FF91DFCA7E6  0F 50 C1                    movmskps eax, xmm1
00007FF91DFCA7E9  83 E0 01                    and     eax, 1
00007FF91DFCA7EC  2B C8                       sub     ecx, eax
00007FF91DFCA7EE  66 0F 6E C9                 movd    xmm1, ecx
00007FF91DFCA7F2  0F 5B C9                    cvtdq2ps xmm1, xmm1
00007FF91DFCA7F5  F3 44 0F 5C C9              subss   xmm9, xmm1
00007FF91DFCA7FA  0F 28 C1                    movaps  xmm0, xmm1; X
00007FF91DFCA7FD  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFCA801  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFCA806  F3 0F 59 35 C2 A7 77 00     mulss   xmm6, cs:dword_7FF91E744FD0
00007FF91DFCA80E  E8 2D 4F 38 00              call    expf
00007FF91DFCA813  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFCA816  41 0F 28 D1                 movaps  xmm2, xmm9
00007FF91DFCA81A  F3 0F 59 93 60 1F 00 00     mulss   xmm2, dword ptr [rbx+1F60h]
00007FF91DFCA822  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFCA826  F3 0F 59 8B 40 1F 00 00     mulss   xmm1, dword ptr [rbx+1F40h]
00007FF91DFCA82E  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFCA832  F3 0F 58 93 50 1F 00 00     addss   xmm2, dword ptr [rbx+1F50h]
00007FF91DFCA83A  F3 0F 59 83 20 1F 00 00     mulss   xmm0, dword ptr [rbx+1F20h]
00007FF91DFCA842  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCA846  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCA84A  F3 0F 58 93 30 1F 00 00     addss   xmm2, dword ptr [rbx+1F30h]
00007FF91DFCA852  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCA856  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCA85A  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFCA85E  F3 0F 59 83 00 1F 00 00     mulss   xmm0, dword ptr [rbx+1F00h]
00007FF91DFCA866  F3 0F 58 93 10 1F 00 00     addss   xmm2, dword ptr [rbx+1F10h]
00007FF91DFCA86E  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCA872  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCA876  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFCA87A  F3 0F 59 83 E0 1E 00 00     mulss   xmm0, dword ptr [rbx+1EE0h]
00007FF91DFCA882  F3 44 0F 59 8B C0 1E 00 00  mulss   xmm9, dword ptr [rbx+1EC0h]
00007FF91DFCA88B  F3 0F 58 93 F0 1E 00 00     addss   xmm2, dword ptr [rbx+1EF0h]
00007FF91DFCA893  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCA897  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCA89B  F3 0F 58 93 D0 1E 00 00     addss   xmm2, dword ptr [rbx+1ED0h]
00007FF91DFCA8A3  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCA8A7  F3 41 0F 58 D1              addss   xmm2, xmm9
00007FF91DFCA8AC  F3 41 0F 58 D5              addss   xmm2, xmm13
00007FF91DFCA8B1  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFCA8B5  F3 0F 59 A3 B0 1E 00 00     mulss   xmm4, dword ptr [rbx+1EB0h]
00007FF91DFCA8BD  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFCA8C0  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCA8C4  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCA8C7  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFCA8CB  F3 44 0F 59 83 00 20 00 00  mulss   xmm8, dword ptr [rbx+2000h]
00007FF91DFCA8D4  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCA8D7  F3 0F 59 83 C0 1F 00 00     mulss   xmm0, dword ptr [rbx+1FC0h]
00007FF91DFCA8DF  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFCA8E2  F3 44 0F 58 83 E0 1F 00 00  addss   xmm8, dword ptr [rbx+1FE0h]
00007FF91DFCA8EB  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCA8EF  F3 0F 58 83 A0 1F 00 00     addss   xmm0, dword ptr [rbx+1FA0h]
00007FF91DFCA8F7  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCA8FB  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFCA900  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFCA905  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCA908  F3 0F 59 8B 80 1F 00 00     mulss   xmm1, dword ptr [rbx+1F80h]
00007FF91DFCA910  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCA914  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFCA919  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCA91C  F3 0F 59 83 B0 1F 00 00     mulss   xmm0, dword ptr [rbx+1FB0h]
00007FF91DFCA924  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFCA929  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFCA92C  F3 0F 59 8B F0 1F 00 00     mulss   xmm1, dword ptr [rbx+1FF0h]
00007FF91DFCA934  F3 0F 59 9B 70 1F 00 00     mulss   xmm3, dword ptr [rbx+1F70h]
00007FF91DFCA93C  F3 0F 58 8B D0 1F 00 00     addss   xmm1, dword ptr [rbx+1FD0h]
00007FF91DFCA944  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFCA949  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFCA94D  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCA951  F3 0F 58 8B 90 1F 00 00     addss   xmm1, dword ptr [rbx+1F90h]
00007FF91DFCA959  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFCA95D  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFCA961  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFCA966  F3 44 0F 5E C1              divss   xmm8, xmm1
00007FF91DFCA96B  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFCA96F  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCA974  F3 44 0F 5E C0              divss   xmm8, xmm0
00007FF91DFCA979  F3 44 0F 11 83 60 1D 00 00  movss   dword ptr [rbx+1D60h], xmm8
00007FF91DFCA982  EB 09                       jmp     short loc_7FF91DFCA98D
00007FF91DFCA984  F3 44 0F 10 83 60 1D 00 00  movss   xmm8, dword ptr [rbx+1D60h]
00007FF91DFCA98D  8B 83 70 20 00 00           mov     eax, [rbx+2070h]
00007FF91DFCA993  F3 0F 10 8B 90 19 00 00     movss   xmm1, dword ptr [rbx+1990h]
00007FF91DFCA99B  F3 44 0F 10 8B 70 1D 00 00  movss   xmm9, dword ptr [rbx+1D70h]
00007FF91DFCA9A4  89 83 80 20 00 00           mov     [rbx+2080h], eax
00007FF91DFCA9AA  8B 83 60 20 00 00           mov     eax, [rbx+2060h]
00007FF91DFCA9B0  89 83 70 20 00 00           mov     [rbx+2070h], eax
00007FF91DFCA9B6  8B 83 50 20 00 00           mov     eax, [rbx+2050h]
00007FF91DFCA9BC  89 83 60 20 00 00           mov     [rbx+2060h], eax
00007FF91DFCA9C2  8B 83 40 20 00 00           mov     eax, [rbx+2040h]
00007FF91DFCA9C8  89 83 50 20 00 00           mov     [rbx+2050h], eax
00007FF91DFCA9CE  8B 83 30 20 00 00           mov     eax, [rbx+2030h]
00007FF91DFCA9D4  89 83 40 20 00 00           mov     [rbx+2040h], eax
00007FF91DFCA9DA  8B 83 20 20 00 00           mov     eax, [rbx+2020h]
00007FF91DFCA9E0  89 83 30 20 00 00           mov     [rbx+2030h], eax
00007FF91DFCA9E6  8B 83 10 20 00 00           mov     eax, [rbx+2010h]
00007FF91DFCA9EC  89 83 20 20 00 00           mov     [rbx+2020h], eax
00007FF91DFCA9F2  8B 83 50 21 00 00           mov     eax, [rbx+2150h]
00007FF91DFCA9F8  89 83 60 21 00 00           mov     [rbx+2160h], eax
00007FF91DFCA9FE  8B 83 40 21 00 00           mov     eax, [rbx+2140h]
00007FF91DFCAA04  89 83 50 21 00 00           mov     [rbx+2150h], eax
00007FF91DFCAA0A  8B 83 30 21 00 00           mov     eax, [rbx+2130h]
00007FF91DFCAA10  89 83 40 21 00 00           mov     [rbx+2140h], eax
00007FF91DFCAA16  8B 83 20 21 00 00           mov     eax, [rbx+2120h]
00007FF91DFCAA1C  89 83 30 21 00 00           mov     [rbx+2130h], eax
00007FF91DFCAA22  8B 83 10 21 00 00           mov     eax, [rbx+2110h]
00007FF91DFCAA28  89 83 20 21 00 00           mov     [rbx+2120h], eax
00007FF91DFCAA2E  8B 83 00 21 00 00           mov     eax, [rbx+2100h]
00007FF91DFCAA34  89 83 10 21 00 00           mov     [rbx+2110h], eax
00007FF91DFCAA3A  8B 83 F0 20 00 00           mov     eax, [rbx+20F0h]
00007FF91DFCAA40  89 83 00 21 00 00           mov     [rbx+2100h], eax
00007FF91DFCAA46  8B 83 D0 21 00 00           mov     eax, [rbx+21D0h]
00007FF91DFCAA4C  89 83 E0 21 00 00           mov     [rbx+21E0h], eax
00007FF91DFCAA52  8B 83 C0 21 00 00           mov     eax, [rbx+21C0h]
00007FF91DFCAA58  89 83 D0 21 00 00           mov     [rbx+21D0h], eax
00007FF91DFCAA5E  8B 83 B0 21 00 00           mov     eax, [rbx+21B0h]
00007FF91DFCAA64  89 83 C0 21 00 00           mov     [rbx+21C0h], eax
00007FF91DFCAA6A  8B 83 A0 21 00 00           mov     eax, [rbx+21A0h]
00007FF91DFCAA70  89 83 B0 21 00 00           mov     [rbx+21B0h], eax
00007FF91DFCAA76  8B 83 90 21 00 00           mov     eax, [rbx+2190h]
00007FF91DFCAA7C  89 83 A0 21 00 00           mov     [rbx+21A0h], eax
00007FF91DFCAA82  8B 83 80 21 00 00           mov     eax, [rbx+2180h]
00007FF91DFCAA88  89 83 90 21 00 00           mov     [rbx+2190h], eax
00007FF91DFCAA8E  8B 83 70 21 00 00           mov     eax, [rbx+2170h]
00007FF91DFCAA94  89 83 80 21 00 00           mov     [rbx+2180h], eax
00007FF91DFCAA9A  8B 83 50 22 00 00           mov     eax, [rbx+2250h]
00007FF91DFCAAA0  89 83 60 22 00 00           mov     [rbx+2260h], eax
00007FF91DFCAAA6  8B 83 40 22 00 00           mov     eax, [rbx+2240h]
00007FF91DFCAAAC  89 83 50 22 00 00           mov     [rbx+2250h], eax
00007FF91DFCAAB2  8B 83 30 22 00 00           mov     eax, [rbx+2230h]
00007FF91DFCAAB8  89 83 40 22 00 00           mov     [rbx+2240h], eax
00007FF91DFCAABE  8B 83 20 22 00 00           mov     eax, [rbx+2220h]
00007FF91DFCAAC4  89 83 30 22 00 00           mov     [rbx+2230h], eax
00007FF91DFCAACA  8B 83 10 22 00 00           mov     eax, [rbx+2210h]
00007FF91DFCAAD0  89 83 20 22 00 00           mov     [rbx+2220h], eax
00007FF91DFCAAD6  8B 83 00 22 00 00           mov     eax, [rbx+2200h]
00007FF91DFCAADC  89 83 10 22 00 00           mov     [rbx+2210h], eax
00007FF91DFCAAE2  8B 83 F0 21 00 00           mov     eax, [rbx+21F0h]
00007FF91DFCAAE8  89 83 00 22 00 00           mov     [rbx+2200h], eax
00007FF91DFCAAEE  8B 83 D0 22 00 00           mov     eax, [rbx+22D0h]
00007FF91DFCAAF4  89 83 E0 22 00 00           mov     [rbx+22E0h], eax
00007FF91DFCAAFA  8B 83 C0 22 00 00           mov     eax, [rbx+22C0h]
00007FF91DFCAB00  89 83 D0 22 00 00           mov     [rbx+22D0h], eax
00007FF91DFCAB06  8B 83 B0 22 00 00           mov     eax, [rbx+22B0h]
00007FF91DFCAB0C  89 83 C0 22 00 00           mov     [rbx+22C0h], eax
00007FF91DFCAB12  8B 83 A0 22 00 00           mov     eax, [rbx+22A0h]
00007FF91DFCAB18  89 83 B0 22 00 00           mov     [rbx+22B0h], eax
00007FF91DFCAB1E  8B 83 90 22 00 00           mov     eax, [rbx+2290h]
00007FF91DFCAB24  89 83 A0 22 00 00           mov     [rbx+22A0h], eax
00007FF91DFCAB2A  8B 83 80 22 00 00           mov     eax, [rbx+2280h]
00007FF91DFCAB30  89 83 90 22 00 00           mov     [rbx+2290h], eax
00007FF91DFCAB36  8B 83 70 22 00 00           mov     eax, [rbx+2270h]
00007FF91DFCAB3C  89 83 80 22 00 00           mov     [rbx+2280h], eax
00007FF91DFCAB42  8B 83 F0 22 00 00           mov     eax, [rbx+22F0h]
00007FF91DFCAB48  89 83 00 23 00 00           mov     [rbx+2300h], eax
00007FF91DFCAB4E  F3 0F 10 83 10 23 00 00     movss   xmm0, dword ptr [rbx+2310h]
00007FF91DFCAB56  F3 0F 11 83 20 23 00 00     movss   dword ptr [rbx+2320h], xmm0
00007FF91DFCAB5E  44 0F 2E AB 60 23 00 00     ucomiss xmm13, dword ptr [rbx+2360h]
00007FF91DFCAB66  0F 85 49 09 00 00           jnz     loc_7FF91DFCB4B5
00007FF91DFCAB6C  F3 0F 59 8B B0 23 00 00     mulss   xmm1, dword ptr [rbx+23B0h]
00007FF91DFCAB74  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFCAB78  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFCAB7C  41 0F 28 F8                 movaps  xmm7, xmm8
00007FF91DFCAB80  F3 0F 59 B3 D0 23 00 00     mulss   xmm6, dword ptr [rbx+23D0h]
00007FF91DFCAB88  F3 41 0F 59 F8              mulss   xmm7, xmm8
00007FF91DFCAB8D  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCAB92  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFCAB96  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFCAB99  F3 0F 59 8B A0 23 00 00     mulss   xmm1, dword ptr [rbx+23A0h]
00007FF91DFCABA1  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFCABA5  E8 B6 E1 FF FF              call    sub_7FF91DFC8D60
00007FF91DFCABAA  F3 0F 11 83 10 23 00 00     movss   dword ptr [rbx+2310h], xmm0
00007FF91DFCABB2  41 0F 28 DD                 movaps  xmm3, xmm13
00007FF91DFCABB6  F3 0F 11 B3 F0 22 00 00     movss   dword ptr [rbx+22F0h], xmm6
00007FF91DFCABBE  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFCABC2  F3 0F 59 FF                 mulss   xmm7, xmm7
00007FF91DFCABC6  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFCABCB  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFCABCF  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFCABD4  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFCABD8  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFCABDD  F3 0F 5E DF                 divss   xmm3, xmm7
00007FF91DFCABE1  F3 0F 11 9B 40 23 00 00     movss   dword ptr [rbx+2340h], xmm3
00007FF91DFCABE9  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFCABEC  F3 0F 10 8B F0 22 00 00     movss   xmm1, dword ptr [rbx+22F0h]
00007FF91DFCABF4  F3 0F 10 AB 00 23 00 00     movss   xmm5, dword ptr [rbx+2300h]
00007FF91DFCABFC  F3 41 0F 59 E1              mulss   xmm4, xmm9
00007FF91DFCAC01  F3 0F 11 A3 30 23 00 00     movss   dword ptr [rbx+2330h], xmm4
00007FF91DFCAC09  F3 0F 59 AB 00 24 00 00     mulss   xmm5, dword ptr [rbx+2400h]
00007FF91DFCAC11  F3 0F 10 93 70 20 00 00     movss   xmm2, dword ptr [rbx+2070h]
00007FF91DFCAC19  F3 0F 59 8B 10 24 00 00     mulss   xmm1, dword ptr [rbx+2410h]
00007FF91DFCAC21  F3 0F 10 83 80 20 00 00     movss   xmm0, dword ptr [rbx+2080h]
00007FF91DFCAC29  F3 0F 11 93 E0 20 00 00     movss   dword ptr [rbx+20E0h], xmm2
00007FF91DFCAC31  F3 0F 59 93 30 25 00 00     mulss   xmm2, dword ptr [rbx+2530h]
00007FF91DFCAC39  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCAC3D  F3 0F 59 83 40 25 00 00     mulss   xmm0, dword ptr [rbx+2540h]
00007FF91DFCAC45  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFCAC49  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCAC4D  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFCAC51  F3 0F 5C EA                 subss   xmm5, xmm2
00007FF91DFCAC55  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCAC59  73 06                       jnb     short loc_7FF91DFCAC61
00007FF91DFCAC5B  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCAC5F  EB 05                       jmp     short loc_7FF91DFCAC66
00007FF91DFCAC61  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCAC66  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFCAC69  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCAC6C  F3 0F 59 83 E0 23 00 00     mulss   xmm0, dword ptr [rbx+23E0h]
00007FF91DFCAC74  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCAC78  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCAC7C  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCAC80  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCAC84  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFCAC88  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCAC8C  F3 0F 11 AB 90 20 00 00     movss   dword ptr [rbx+2090h], xmm5
00007FF91DFCAC94  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCAC97  F3 0F 58 AB 20 20 00 00     addss   xmm5, dword ptr [rbx+2020h]
00007FF91DFCAC9F  F3 0F 10 9B 30 20 00 00     movss   xmm3, dword ptr [rbx+2030h]
00007FF91DFCACA7  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCACAA  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCACAE  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCACB2  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFCACB6  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFCACBA  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCACBE  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCACC2  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCACC5  F3 0F 11 A3 A0 20 00 00     movss   dword ptr [rbx+20A0h], xmm4
00007FF91DFCACCD  F3 0F 10 8B 40 20 00 00     movss   xmm1, dword ptr [rbx+2040h]
00007FF91DFCACD5  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCACD9  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCACDD  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCACE0  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCACE4  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFCACE8  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCACEC  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFCACF0  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCACF4  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCACF8  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCACFC  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCAD00  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCAD03  F3 0F 11 9B B0 20 00 00     movss   dword ptr [rbx+20B0h], xmm3
00007FF91DFCAD0B  F3 0F 10 AB 50 20 00 00     movss   xmm5, dword ptr [rbx+2050h]
00007FF91DFCAD13  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCAD17  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCAD1B  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCAD1E  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCAD22  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCAD26  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCAD2A  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFCAD2E  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCAD32  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCAD36  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCAD3A  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCAD3E  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCAD41  F3 0F 11 93 C0 20 00 00     movss   dword ptr [rbx+20C0h], xmm2
00007FF91DFCAD49  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFCAD4D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCAD51  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCAD55  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFCAD5A  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCAD5D  F3 0F 59 83 60 20 00 00     mulss   xmm0, dword ptr [rbx+2060h]
00007FF91DFCAD65  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCAD69  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCAD6D  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCAD70  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFCAD74  F3 0F 11 AB D0 20 00 00     movss   dword ptr [rbx+20D0h], xmm5
00007FF91DFCAD7C  F3 0F 10 93 C0 20 00 00     movss   xmm2, dword ptr [rbx+20C0h]
00007FF91DFCAD84  F3 0F 59 93 80 23 00 00     mulss   xmm2, dword ptr [rbx+2380h]
00007FF91DFCAD8C  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFCAD90  F3 0F 59 AB 90 23 00 00     mulss   xmm5, dword ptr [rbx+2390h]
00007FF91DFCAD98  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCAD9C  F3 0F 10 83 70 23 00 00     movss   xmm0, dword ptr [rbx+2370h]
00007FF91DFCADA4  F3 0F 59 83 B0 20 00 00     mulss   xmm0, dword ptr [rbx+20B0h]
00007FF91DFCADAC  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFCADB0  F3 0F 10 AB 00 23 00 00     movss   xmm5, dword ptr [rbx+2300h]
00007FF91DFCADB8  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCADBC  F3 0F 11 93 70 22 00 00     movss   dword ptr [rbx+2270h], xmm2
00007FF91DFCADC4  F3 0F 58 AB F0 22 00 00     addss   xmm5, dword ptr [rbx+22F0h]
00007FF91DFCADCC  F3 0F 10 83 E0 20 00 00     movss   xmm0, dword ptr [rbx+20E0h]
00007FF91DFCADD4  F3 0F 59 AB 20 24 00 00     mulss   xmm5, dword ptr [rbx+2420h]
00007FF91DFCADDC  F3 0F 59 AB 40 23 00 00     mulss   xmm5, dword ptr [rbx+2340h]
00007FF91DFCADE4  F3 0F 11 A3 E0 20 00 00     movss   dword ptr [rbx+20E0h], xmm4
00007FF91DFCADEC  F3 0F 59 A3 30 25 00 00     mulss   xmm4, dword ptr [rbx+2530h]
00007FF91DFCADF4  F3 0F 59 83 40 25 00 00     mulss   xmm0, dword ptr [rbx+2540h]
00007FF91DFCADFC  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCAE00  F3 0F 59 A3 30 23 00 00     mulss   xmm4, dword ptr [rbx+2330h]
00007FF91DFCAE08  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFCAE0C  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCAE10  73 06                       jnb     short loc_7FF91DFCAE18
00007FF91DFCAE12  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCAE16  EB 05                       jmp     short loc_7FF91DFCAE1D
00007FF91DFCAE18  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCAE1D  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFCAE20  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCAE23  F3 0F 59 83 E0 23 00 00     mulss   xmm0, dword ptr [rbx+23E0h]
00007FF91DFCAE2B  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCAE2F  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCAE33  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCAE37  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCAE3B  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFCAE3F  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCAE43  F3 0F 10 8B 90 20 00 00     movss   xmm1, dword ptr [rbx+2090h]
00007FF91DFCAE4B  F3 0F 11 AB 90 20 00 00     movss   dword ptr [rbx+2090h], xmm5
00007FF91DFCAE53  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCAE56  F3 0F 10 9B A0 20 00 00     movss   xmm3, dword ptr [rbx+20A0h]
00007FF91DFCAE5E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCAE62  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCAE65  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCAE69  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCAE6D  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFCAE71  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFCAE75  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCAE79  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCAE7D  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCAE80  F3 0F 11 A3 A0 20 00 00     movss   dword ptr [rbx+20A0h], xmm4
00007FF91DFCAE88  F3 0F 10 8B B0 20 00 00     movss   xmm1, dword ptr [rbx+20B0h]
00007FF91DFCAE90  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCAE94  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCAE98  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCAE9B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCAE9F  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFCAEA3  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCAEA7  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFCAEAB  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCAEAF  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCAEB3  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCAEB7  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCAEBB  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCAEBE  F3 0F 11 9B B0 20 00 00     movss   dword ptr [rbx+20B0h], xmm3
00007FF91DFCAEC6  F3 0F 10 AB C0 20 00 00     movss   xmm5, dword ptr [rbx+20C0h]
00007FF91DFCAECE  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCAED2  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCAED6  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCAED9  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCAEDD  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCAEE1  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCAEE5  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFCAEE9  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCAEED  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCAEF1  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCAEF5  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCAEF9  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCAEFC  F3 0F 11 93 C0 20 00 00     movss   dword ptr [rbx+20C0h], xmm2
00007FF91DFCAF04  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFCAF08  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCAF0C  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCAF10  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFCAF15  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCAF18  F3 0F 59 83 D0 20 00 00     mulss   xmm0, dword ptr [rbx+20D0h]
00007FF91DFCAF20  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCAF24  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCAF28  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCAF2B  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFCAF2F  F3 0F 11 AB D0 20 00 00     movss   dword ptr [rbx+20D0h], xmm5
00007FF91DFCAF37  F3 0F 10 93 C0 20 00 00     movss   xmm2, dword ptr [rbx+20C0h]
00007FF91DFCAF3F  F3 0F 59 93 80 23 00 00     mulss   xmm2, dword ptr [rbx+2380h]
00007FF91DFCAF47  F3 0F 10 8B F0 22 00 00     movss   xmm1, dword ptr [rbx+22F0h]
00007FF91DFCAF4F  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFCAF53  F3 0F 59 AB 90 23 00 00     mulss   xmm5, dword ptr [rbx+2390h]
00007FF91DFCAF5B  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCAF5F  F3 0F 10 83 70 23 00 00     movss   xmm0, dword ptr [rbx+2370h]
00007FF91DFCAF67  F3 0F 59 83 B0 20 00 00     mulss   xmm0, dword ptr [rbx+20B0h]
00007FF91DFCAF6F  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFCAF73  F3 0F 10 AB 00 23 00 00     movss   xmm5, dword ptr [rbx+2300h]
00007FF91DFCAF7B  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCAF7F  F3 0F 11 93 F0 21 00 00     movss   dword ptr [rbx+21F0h], xmm2
00007FF91DFCAF87  F3 0F 59 AB 10 24 00 00     mulss   xmm5, dword ptr [rbx+2410h]
00007FF91DFCAF8F  F3 0F 59 8B 00 24 00 00     mulss   xmm1, dword ptr [rbx+2400h]
00007FF91DFCAF97  F3 0F 10 83 E0 20 00 00     movss   xmm0, dword ptr [rbx+20E0h]
00007FF91DFCAF9F  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCAFA3  F3 0F 59 AB 40 23 00 00     mulss   xmm5, dword ptr [rbx+2340h]
00007FF91DFCAFAB  F3 0F 11 A3 E0 20 00 00     movss   dword ptr [rbx+20E0h], xmm4
00007FF91DFCAFB3  F3 0F 59 A3 30 25 00 00     mulss   xmm4, dword ptr [rbx+2530h]
00007FF91DFCAFBB  F3 0F 59 83 40 25 00 00     mulss   xmm0, dword ptr [rbx+2540h]
00007FF91DFCAFC3  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCAFC7  F3 0F 59 A3 30 23 00 00     mulss   xmm4, dword ptr [rbx+2330h]
00007FF91DFCAFCF  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFCAFD3  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCAFD7  73 06                       jnb     short loc_7FF91DFCAFDF
00007FF91DFCAFD9  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCAFDD  EB 05                       jmp     short loc_7FF91DFCAFE4
00007FF91DFCAFDF  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCAFE4  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFCAFE7  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCAFEA  F3 0F 59 83 E0 23 00 00     mulss   xmm0, dword ptr [rbx+23E0h]
00007FF91DFCAFF2  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCAFF6  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCAFFA  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCAFFE  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCB002  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFCB006  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCB00A  F3 0F 10 8B 90 20 00 00     movss   xmm1, dword ptr [rbx+2090h]
00007FF91DFCB012  F3 0F 11 AB 90 20 00 00     movss   dword ptr [rbx+2090h], xmm5
00007FF91DFCB01A  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCB01D  F3 0F 10 9B A0 20 00 00     movss   xmm3, dword ptr [rbx+20A0h]
00007FF91DFCB025  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCB029  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCB02C  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCB030  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCB034  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFCB038  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFCB03C  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCB040  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB044  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCB047  F3 0F 11 A3 A0 20 00 00     movss   dword ptr [rbx+20A0h], xmm4
00007FF91DFCB04F  F3 0F 10 8B B0 20 00 00     movss   xmm1, dword ptr [rbx+20B0h]
00007FF91DFCB057  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCB05B  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCB05F  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCB062  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCB066  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFCB06A  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCB06E  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFCB072  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCB076  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCB07A  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCB07E  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCB082  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCB085  F3 0F 11 9B B0 20 00 00     movss   dword ptr [rbx+20B0h], xmm3
00007FF91DFCB08D  F3 0F 10 AB C0 20 00 00     movss   xmm5, dword ptr [rbx+20C0h]
00007FF91DFCB095  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCB099  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB09D  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCB0A0  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCB0A4  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCB0A8  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCB0AC  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFCB0B0  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCB0B4  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCB0B8  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFCB0BC  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCB0C0  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCB0C3  F3 0F 11 93 C0 20 00 00     movss   dword ptr [rbx+20C0h], xmm2
00007FF91DFCB0CB  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFCB0CF  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCB0D3  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCB0D7  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFCB0DC  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCB0DF  F3 0F 59 83 D0 20 00 00     mulss   xmm0, dword ptr [rbx+20D0h]
00007FF91DFCB0E7  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCB0EB  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCB0EF  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCB0F2  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFCB0F6  F3 0F 11 AB D0 20 00 00     movss   dword ptr [rbx+20D0h], xmm5
00007FF91DFCB0FE  F3 0F 10 8B C0 20 00 00     movss   xmm1, dword ptr [rbx+20C0h]
00007FF91DFCB106  F3 0F 59 8B 80 23 00 00     mulss   xmm1, dword ptr [rbx+2380h]
00007FF91DFCB10E  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFCB112  F3 0F 59 AB 90 23 00 00     mulss   xmm5, dword ptr [rbx+2390h]
00007FF91DFCB11A  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCB11E  F3 0F 10 83 70 23 00 00     movss   xmm0, dword ptr [rbx+2370h]
00007FF91DFCB126  F3 0F 59 83 B0 20 00 00     mulss   xmm0, dword ptr [rbx+20B0h]
00007FF91DFCB12E  F3 0F 58 CD                 addss   xmm1, xmm5
00007FF91DFCB132  F3 0F 10 AB F0 22 00 00     movss   xmm5, dword ptr [rbx+22F0h]
00007FF91DFCB13A  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCB13E  F3 0F 11 8B 70 21 00 00     movss   dword ptr [rbx+2170h], xmm1
00007FF91DFCB146  F3 0F 59 AB F0 23 00 00     mulss   xmm5, dword ptr [rbx+23F0h]
00007FF91DFCB14E  F3 0F 10 83 E0 20 00 00     movss   xmm0, dword ptr [rbx+20E0h]
00007FF91DFCB156  F3 0F 59 AB 40 23 00 00     mulss   xmm5, dword ptr [rbx+2340h]
00007FF91DFCB15E  F3 0F 11 9B 70 20 00 00     movss   dword ptr [rbx+2070h], xmm3
00007FF91DFCB166  F3 0F 59 9B 30 25 00 00     mulss   xmm3, dword ptr [rbx+2530h]
00007FF91DFCB16E  F3 0F 59 83 40 25 00 00     mulss   xmm0, dword ptr [rbx+2540h]
00007FF91DFCB176  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCB17A  F3 0F 59 9B 30 23 00 00     mulss   xmm3, dword ptr [rbx+2330h]
00007FF91DFCB182  F3 0F 5C EB                 subss   xmm5, xmm3
00007FF91DFCB186  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCB18A  73 06                       jnb     short loc_7FF91DFCB192
00007FF91DFCB18C  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCB190  EB 05                       jmp     short loc_7FF91DFCB197
00007FF91DFCB192  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCB197  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFCB19A  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCB19D  F3 0F 59 83 E0 23 00 00     mulss   xmm0, dword ptr [rbx+23E0h]
00007FF91DFCB1A5  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCB1A9  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCB1AD  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCB1B1  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFCB1B5  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFCB1B9  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCB1BD  F3 0F 11 AB 10 20 00 00     movss   dword ptr [rbx+2010h], xmm5
00007FF91DFCB1C5  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCB1C8  F3 0F 58 AB 90 20 00 00     addss   xmm5, dword ptr [rbx+2090h]
00007FF91DFCB1D0  F3 0F 10 9B A0 20 00 00     movss   xmm3, dword ptr [rbx+20A0h]
00007FF91DFCB1D8  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCB1DB  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCB1DF  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCB1E3  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFCB1E7  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFCB1EB  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCB1EF  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB1F3  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCB1F6  F3 0F 11 A3 20 20 00 00     movss   dword ptr [rbx+2020h], xmm4
00007FF91DFCB1FE  F3 0F 10 8B B0 20 00 00     movss   xmm1, dword ptr [rbx+20B0h]
00007FF91DFCB206  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCB20A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCB20E  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCB211  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCB215  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFCB219  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCB21D  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFCB221  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCB225  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFCB229  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCB22D  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFCB231  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCB234  F3 0F 11 9B 30 20 00 00     movss   dword ptr [rbx+2030h], xmm3
00007FF91DFCB23C  F3 0F 10 AB C0 20 00 00     movss   xmm5, dword ptr [rbx+20C0h]
00007FF91DFCB244  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCB248  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB24C  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCB24F  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCB253  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCB257  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCB25B  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFCB25F  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCB263  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFCB267  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCB26B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCB26E  F3 0F 11 93 40 20 00 00     movss   dword ptr [rbx+2040h], xmm2
00007FF91DFCB276  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFCB27A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCB27E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCB282  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFCB287  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCB28A  F3 0F 59 83 D0 20 00 00     mulss   xmm0, dword ptr [rbx+20D0h]
00007FF91DFCB292  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFCB296  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCB29A  F3 44 0F 59 C1              mulss   xmm8, xmm1
00007FF91DFCB29F  F3 0F 11 AB 50 20 00 00     movss   dword ptr [rbx+2050h], xmm5
00007FF91DFCB2A7  F3 0F 10 9B 30 20 00 00     movss   xmm3, dword ptr [rbx+2030h]
00007FF91DFCB2AF  F3 0F 59 F5                 mulss   xmm6, xmm5
00007FF91DFCB2B3  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFCB2B8  F3 44 0F 11 83 60 20 00 00  movss   dword ptr [rbx+2060h], xmm8
00007FF91DFCB2C1  F3 0F 10 83 80 23 00 00     movss   xmm0, dword ptr [rbx+2380h]
00007FF91DFCB2C9  F3 0F 59 83 40 20 00 00     mulss   xmm0, dword ptr [rbx+2040h]
00007FF91DFCB2D1  F3 0F 59 AB 90 23 00 00     mulss   xmm5, dword ptr [rbx+2390h]
00007FF91DFCB2D9  F3 0F 59 9B 70 23 00 00     mulss   xmm3, dword ptr [rbx+2370h]
00007FF91DFCB2E1  F3 0F 10 A3 30 21 00 00     movss   xmm4, dword ptr [rbx+2130h]
00007FF91DFCB2E9  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCB2ED  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFCB2F1  F3 0F 11 AB F0 20 00 00     movss   dword ptr [rbx+20F0h], xmm5
00007FF91DFCB2F9  F3 0F 58 A3 A0 22 00 00     addss   xmm4, dword ptr [rbx+22A0h]
00007FF91DFCB301  F3 0F 10 83 B0 21 00 00     movss   xmm0, dword ptr [rbx+21B0h]
00007FF91DFCB309  F3 0F 58 83 20 22 00 00     addss   xmm0, dword ptr [rbx+2220h]
00007FF91DFCB311  F3 0F 10 8B 30 22 00 00     movss   xmm1, dword ptr [rbx+2230h]
00007FF91DFCB319  F3 0F 58 8B A0 21 00 00     addss   xmm1, dword ptr [rbx+21A0h]
00007FF91DFCB321  F3 0F 59 A3 20 25 00 00     mulss   xmm4, dword ptr [rbx+2520h]
00007FF91DFCB329  F3 0F 59 83 10 25 00 00     mulss   xmm0, dword ptr [rbx+2510h]
00007FF91DFCB331  F3 0F 59 8B 00 25 00 00     mulss   xmm1, dword ptr [rbx+2500h]
00007FF91DFCB339  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB33D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCB341  F3 0F 10 83 20 21 00 00     movss   xmm0, dword ptr [rbx+2120h]
00007FF91DFCB349  F3 0F 58 83 B0 22 00 00     addss   xmm0, dword ptr [rbx+22B0h]
00007FF91DFCB351  F3 0F 10 8B 90 22 00 00     movss   xmm1, dword ptr [rbx+2290h]
00007FF91DFCB359  F3 0F 58 8B 40 21 00 00     addss   xmm1, dword ptr [rbx+2140h]
00007FF91DFCB361  F3 0F 58 AB E0 22 00 00     addss   xmm5, dword ptr [rbx+22E0h]
00007FF91DFCB369  F3 0F 59 83 F0 24 00 00     mulss   xmm0, dword ptr [rbx+24F0h]
00007FF91DFCB371  F3 0F 59 8B E0 24 00 00     mulss   xmm1, dword ptr [rbx+24E0h]
00007FF91DFCB379  F3 0F 59 AB 30 24 00 00     mulss   xmm5, dword ptr [rbx+2430h]
00007FF91DFCB381  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB385  F3 0F 10 83 10 22 00 00     movss   xmm0, dword ptr [rbx+2210h]
00007FF91DFCB38D  F3 0F 58 83 C0 21 00 00     addss   xmm0, dword ptr [rbx+21C0h]
00007FF91DFCB395  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCB399  F3 0F 10 8B 40 22 00 00     movss   xmm1, dword ptr [rbx+2240h]
00007FF91DFCB3A1  F3 0F 58 8B 90 21 00 00     addss   xmm1, dword ptr [rbx+2190h]
00007FF91DFCB3A9  F3 0F 59 83 D0 24 00 00     mulss   xmm0, dword ptr [rbx+24D0h]
00007FF91DFCB3B1  F3 0F 59 8B C0 24 00 00     mulss   xmm1, dword ptr [rbx+24C0h]
00007FF91DFCB3B9  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB3BD  F3 0F 10 83 C0 22 00 00     movss   xmm0, dword ptr [rbx+22C0h]
00007FF91DFCB3C5  F3 0F 58 83 10 21 00 00     addss   xmm0, dword ptr [rbx+2110h]
00007FF91DFCB3CD  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCB3D1  F3 0F 10 8B 80 22 00 00     movss   xmm1, dword ptr [rbx+2280h]
00007FF91DFCB3D9  F3 0F 59 83 B0 24 00 00     mulss   xmm0, dword ptr [rbx+24B0h]
00007FF91DFCB3E1  F3 0F 58 8B 50 21 00 00     addss   xmm1, dword ptr [rbx+2150h]
00007FF91DFCB3E9  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB3ED  F3 0F 10 83 00 22 00 00     movss   xmm0, dword ptr [rbx+2200h]
00007FF91DFCB3F5  F3 0F 58 83 D0 21 00 00     addss   xmm0, dword ptr [rbx+21D0h]
00007FF91DFCB3FD  F3 0F 59 8B A0 24 00 00     mulss   xmm1, dword ptr [rbx+24A0h]
00007FF91DFCB405  F3 0F 59 83 90 24 00 00     mulss   xmm0, dword ptr [rbx+2490h]
00007FF91DFCB40D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCB411  F3 0F 10 8B 50 22 00 00     movss   xmm1, dword ptr [rbx+2250h]
00007FF91DFCB419  F3 0F 58 8B 80 21 00 00     addss   xmm1, dword ptr [rbx+2180h]
00007FF91DFCB421  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB425  F3 0F 10 83 D0 22 00 00     movss   xmm0, dword ptr [rbx+22D0h]
00007FF91DFCB42D  F3 0F 59 8B 80 24 00 00     mulss   xmm1, dword ptr [rbx+2480h]
00007FF91DFCB435  F3 0F 58 83 00 21 00 00     addss   xmm0, dword ptr [rbx+2100h]
00007FF91DFCB43D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCB441  F3 0F 10 8B 70 22 00 00     movss   xmm1, dword ptr [rbx+2270h]
00007FF91DFCB449  F3 0F 58 8B 60 21 00 00     addss   xmm1, dword ptr [rbx+2160h]
00007FF91DFCB451  F3 0F 59 83 70 24 00 00     mulss   xmm0, dword ptr [rbx+2470h]
00007FF91DFCB459  F3 0F 59 8B 60 24 00 00     mulss   xmm1, dword ptr [rbx+2460h]
00007FF91DFCB461  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB465  F3 0F 10 83 F0 21 00 00     movss   xmm0, dword ptr [rbx+21F0h]
00007FF91DFCB46D  F3 0F 58 83 E0 21 00 00     addss   xmm0, dword ptr [rbx+21E0h]
00007FF91DFCB475  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCB479  F3 0F 10 8B 60 22 00 00     movss   xmm1, dword ptr [rbx+2260h]
00007FF91DFCB481  F3 0F 59 83 50 24 00 00     mulss   xmm0, dword ptr [rbx+2450h]
00007FF91DFCB489  F3 0F 58 8B 70 21 00 00     addss   xmm1, dword ptr [rbx+2170h]
00007FF91DFCB491  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB495  F3 0F 59 8B 40 24 00 00     mulss   xmm1, dword ptr [rbx+2440h]
00007FF91DFCB49D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCB4A1  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFCB4A5  F3 0F 59 A3 C0 23 00 00     mulss   xmm4, dword ptr [rbx+23C0h]
00007FF91DFCB4AD  F3 0F 11 A3 50 23 00 00     movss   dword ptr [rbx+2350h], xmm4
00007FF91DFCB4B5  8B 83 50 25 00 00           mov     eax, [rbx+2550h]
00007FF91DFCB4BB  89 83 60 25 00 00           mov     [rbx+2560h], eax
00007FF91DFCB4C1  F3 0F 10 83 80 25 00 00     movss   xmm0, dword ptr [rbx+2580h]
00007FF91DFCB4C9  8B 83 70 25 00 00           mov     eax, [rbx+2570h]
00007FF91DFCB4CF  89 83 A0 25 00 00           mov     [rbx+25A0h], eax
00007FF91DFCB4D5  F3 0F 11 83 B0 25 00 00     movss   dword ptr [rbx+25B0h], xmm0
00007FF91DFCB4DD  8B 83 90 25 00 00           mov     eax, [rbx+2590h]
00007FF91DFCB4E3  89 83 C0 25 00 00           mov     [rbx+25C0h], eax
00007FF91DFCB4E9  F3 0F 10 93 D0 25 00 00     movss   xmm2, dword ptr [rbx+25D0h]
00007FF91DFCB4F1  F3 0F 11 93 E0 25 00 00     movss   dword ptr [rbx+25E0h], xmm2
00007FF91DFCB4F9  F3 0F 10 83 F0 25 00 00     movss   xmm0, dword ptr [rbx+25F0h]
00007FF91DFCB501  F3 0F 11 83 00 26 00 00     movss   dword ptr [rbx+2600h], xmm0
00007FF91DFCB509  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFCB50D  F3 0F 59 93 10 26 00 00     mulss   xmm2, dword ptr [rbx+2610h]
00007FF91DFCB515  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFCB519  F3 0F 11 93 F0 25 00 00     movss   dword ptr [rbx+25F0h], xmm2
00007FF91DFCB521  F3 0F 10 83 B0 25 00 00     movss   xmm0, dword ptr [rbx+25B0h]
00007FF91DFCB529  F3 0F 10 8B C0 25 00 00     movss   xmm1, dword ptr [rbx+25C0h]
00007FF91DFCB531  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFCB535  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCB539  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFCB53D  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCB541  F3 0F 11 93 20 26 00 00     movss   dword ptr [rbx+2620h], xmm2
00007FF91DFCB549  F3 0F 10 8B 30 26 00 00     movss   xmm1, dword ptr [rbx+2630h]
00007FF91DFCB551  F3 0F 11 8B 40 26 00 00     movss   dword ptr [rbx+2640h], xmm1
00007FF91DFCB559  F3 0F 10 83 50 26 00 00     movss   xmm0, dword ptr [rbx+2650h]
00007FF91DFCB561  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFCB564  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFCB568  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFCB56C  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCB570  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCB574  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFCB578  76 05                       jbe     short loc_7FF91DFCB57F
00007FF91DFCB57A  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFCB57D  EB 03                       jmp     short loc_7FF91DFCB582
00007FF91DFCB57F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCB582  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFCB586  F3 0F 11 83 30 26 00 00     movss   dword ptr [rbx+2630h], xmm0
00007FF91DFCB58E  F3 0F 10 8B 60 26 00 00     movss   xmm1, dword ptr [rbx+2660h]
00007FF91DFCB596  F3 0F 11 8B 70 26 00 00     movss   dword ptr [rbx+2670h], xmm1
00007FF91DFCB59E  F3 0F 10 93 80 26 00 00     movss   xmm2, dword ptr [rbx+2680h]
00007FF91DFCB5A6  F3 0F 11 93 90 26 00 00     movss   dword ptr [rbx+2690h], xmm2
00007FF91DFCB5AE  F3 0F 10 83 A0 26 00 00     movss   xmm0, dword ptr [rbx+26A0h]
00007FF91DFCB5B6  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFCB5B9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCB5BD  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFCB5C1  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCB5C5  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFCB5C9  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFCB5CD  76 05                       jbe     short loc_7FF91DFCB5D4
00007FF91DFCB5CF  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFCB5D2  EB 03                       jmp     short loc_7FF91DFCB5D7
00007FF91DFCB5D4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCB5D7  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFCB5DB  F3 0F 11 83 80 26 00 00     movss   dword ptr [rbx+2680h], xmm0
00007FF91DFCB5E3  F3 0F 10 AB B0 26 00 00     movss   xmm5, dword ptr [rbx+26B0h]
00007FF91DFCB5EB  F3 0F 10 B3 30 02 00 00     movss   xmm6, dword ptr [rbx+230h]
00007FF91DFCB5F3  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFCB5F6  F3 0F 11 AB C0 26 00 00     movss   dword ptr [rbx+26C0h], xmm5
00007FF91DFCB5FE  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFCB601  F3 0F 59 A3 10 27 00 00     mulss   xmm4, dword ptr [rbx+2710h]
00007FF91DFCB609  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFCB60C  F3 0F 58 83 E0 26 00 00     addss   xmm0, dword ptr [rbx+26E0h]
00007FF91DFCB614  F3 0F 58 9B 00 27 00 00     addss   xmm3, dword ptr [rbx+2700h]
00007FF91DFCB61C  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFCB620  73 06                       jnb     short loc_7FF91DFCB628
00007FF91DFCB622  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFCB626  EB 05                       jmp     short loc_7FF91DFCB62D
00007FF91DFCB628  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFCB62D  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCB631  72 1B                       jb      short loc_7FF91DFCB64E
00007FF91DFCB633  F3 0F 10 83 F0 26 00 00     movss   xmm0, dword ptr [rbx+26F0h]
00007FF91DFCB63B  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFCB63E  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFCB642  F3 0F 59 DE                 mulss   xmm3, xmm6
00007FF91DFCB646  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCB64A  F3 0F 58 DD                 addss   xmm3, xmm5
00007FF91DFCB64E  41 0F 2E F6                 ucomiss xmm6, xmm14
00007FF91DFCB652  F3 0F 10 8B 30 27 00 00     movss   xmm1, dword ptr [rbx+2730h]
00007FF91DFCB65A  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFCB65D  F3 0F 59 93 20 27 00 00     mulss   xmm2, dword ptr [rbx+2720h]
00007FF91DFCB665  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCB668  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFCB66C  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFCB670  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCB674  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCB677  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFCB67B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFCB67F  F3 0F 5C C2                 subss   xmm0, xmm2
00007FF91DFCB683  F3 0F 58 C5                 addss   xmm0, xmm5
00007FF91DFCB687  74 03                       jz      short loc_7FF91DFCB68C
00007FF91DFCB689  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCB68C  F3 0F 11 83 D0 26 00 00     movss   dword ptr [rbx+26D0h], xmm0
00007FF91DFCB694  F3 0F 11 83 B0 26 00 00     movss   dword ptr [rbx+26B0h], xmm0
00007FF91DFCB69C  F3 0F 10 BB 50 23 00 00     movss   xmm7, dword ptr [rbx+2350h]
00007FF91DFCB6A4  F3 0F 10 B3 C0 0A 00 00     movss   xmm6, dword ptr [rbx+0AC0h]
00007FF91DFCB6AC  F3 0F 10 9B C0 1A 00 00     movss   xmm3, dword ptr [rbx+1AC0h]
00007FF91DFCB6B4  F3 0F 10 83 A0 0C 00 00     movss   xmm0, dword ptr [rbx+0CA0h]
00007FF91DFCB6BC  F3 0F 10 8B 50 25 00 00     movss   xmm1, dword ptr [rbx+2550h]
00007FF91DFCB6C4  8B 83 70 27 00 00           mov     eax, [rbx+2770h]
00007FF91DFCB6CA  89 83 80 27 00 00           mov     [rbx+2780h], eax
00007FF91DFCB6D0  8B 83 90 27 00 00           mov     eax, [rbx+2790h]
00007FF91DFCB6D6  89 83 A0 27 00 00           mov     [rbx+27A0h], eax
00007FF91DFCB6DC  F3 0F 11 83 40 27 00 00     movss   dword ptr [rbx+2740h], xmm0
00007FF91DFCB6E4  F3 0F 11 8B 50 27 00 00     movss   dword ptr [rbx+2750h], xmm1
00007FF91DFCB6EC  F3 0F 59 9B 60 28 00 00     mulss   xmm3, dword ptr [rbx+2860h]
00007FF91DFCB6F4  F3 0F 10 A3 80 27 00 00     movss   xmm4, dword ptr [rbx+2780h]
00007FF91DFCB6FC  F3 0F 10 93 C0 27 00 00     movss   xmm2, dword ptr [rbx+27C0h]
00007FF91DFCB704  F3 0F 11 9B 60 27 00 00     movss   dword ptr [rbx+2760h], xmm3
00007FF91DFCB70C  0F 28 DF                    movaps  xmm3, xmm7
00007FF91DFCB70F  F3 0F 59 B3 D0 27 00 00     mulss   xmm6, dword ptr [rbx+27D0h]
00007FF91DFCB717  F3 0F 5C DC                 subss   xmm3, xmm4
00007FF91DFCB71B  F3 0F 59 93 D0 26 00 00     mulss   xmm2, dword ptr [rbx+26D0h]
00007FF91DFCB723  F3 0F 10 8B E0 27 00 00     movss   xmm1, dword ptr [rbx+27E0h]
00007FF91DFCB72B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCB72E  F3 0F 59 83 00 28 00 00     mulss   xmm0, dword ptr [rbx+2800h]
00007FF91DFCB736  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFCB73A  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB73E  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFCB742  F3 0F 11 A3 70 27 00 00     movss   dword ptr [rbx+2770h], xmm4
00007FF91DFCB74A  F3 0F 59 8B 40 27 00 00     mulss   xmm1, dword ptr [rbx+2740h]
00007FF91DFCB752  F3 0F 10 93 F0 27 00 00     movss   xmm2, dword ptr [rbx+27F0h]
00007FF91DFCB75A  F3 0F 59 9B 70 28 00 00     mulss   xmm3, dword ptr [rbx+2870h]
00007FF91DFCB762  F3 0F 59 A3 80 28 00 00     mulss   xmm4, dword ptr [rbx+2880h]
00007FF91DFCB76A  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFCB76E  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCB771  F3 0F 59 8B 50 27 00 00     mulss   xmm1, dword ptr [rbx+2750h]
00007FF91DFCB779  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCB77D  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFCB781  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFCB785  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFCB789  F3 0F 10 B3 10 28 00 00     movss   xmm6, dword ptr [rbx+2810h]
00007FF91DFCB791  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFCB795  F3 0F 59 8B 40 28 00 00     mulss   xmm1, dword ptr [rbx+2840h]
00007FF91DFCB79D  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFCB7A1  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFCB7A5  76 05                       jbe     short loc_7FF91DFCB7AC
00007FF91DFCB7A7  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFCB7AA  EB 03                       jmp     short loc_7FF91DFCB7AF
00007FF91DFCB7AC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCB7AF  F3 0F 10 93 30 28 00 00     movss   xmm2, dword ptr [rbx+2830h]
00007FF91DFCB7B7  F3 0F 10 A3 20 28 00 00     movss   xmm4, dword ptr [rbx+2820h]
00007FF91DFCB7BF  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFCB7C3  F3 0F 10 83 60 27 00 00     movss   xmm0, dword ptr [rbx+2760h]
00007FF91DFCB7CB  F3 0F 59 AB 50 28 00 00     mulss   xmm5, dword ptr [rbx+2850h]
00007FF91DFCB7D3  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCB7D8  F3 0F 59 F3                 mulss   xmm6, xmm3
00007FF91DFCB7DC  F3 0F 10 9B A0 27 00 00     movss   xmm3, dword ptr [rbx+27A0h]
00007FF91DFCB7E4  F3 0F 58 F7                 addss   xmm6, xmm7
00007FF91DFCB7E8  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFCB7EC  F3 0F 10 83 90 28 00 00     movss   xmm0, dword ptr [rbx+2890h]
00007FF91DFCB7F4  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFCB7F7  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFCB7FB  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFCB7FF  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFCB803  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFCB807  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFCB80B  F3 0F 11 9B 90 27 00 00     movss   dword ptr [rbx+2790h], xmm3
00007FF91DFCB813  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFCB817  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFCB81B  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFCB81F  F3 0F 59 A3 A0 28 00 00     mulss   xmm4, dword ptr [rbx+28A0h]
00007FF91DFCB827  F3 0F 11 A3 B0 27 00 00     movss   dword ptr [rbx+27B0h], xmm4
00007FF91DFCB82F  8B 83 C0 28 00 00           mov     eax, [rbx+28C0h]
00007FF91DFCB835  89 83 D0 28 00 00           mov     [rbx+28D0h], eax
00007FF91DFCB83B  8B 83 B0 28 00 00           mov     eax, [rbx+28B0h]
00007FF91DFCB841  89 83 C0 28 00 00           mov     [rbx+28C0h], eax
00007FF91DFCB847  F3 0F 10 83 D0 28 00 00     movss   xmm0, dword ptr [rbx+28D0h]
00007FF91DFCB84F  F3 0F 10 8B E0 28 00 00     movss   xmm1, dword ptr [rbx+28E0h]
00007FF91DFCB857  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFCB85B  F3 0F 11 A3 B0 28 00 00     movss   dword ptr [rbx+28B0h], xmm4
00007FF91DFCB863  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCB867  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFCB86B  F3 0F 11 8B C0 28 00 00     movss   dword ptr [rbx+28C0h], xmm1
00007FF91DFCB873  F3 0F 10 93 B0 28 00 00     movss   xmm2, dword ptr [rbx+28B0h]
00007FF91DFCB87B  F3 0F 10 B3 A0 25 00 00     movss   xmm6, dword ptr [rbx+25A0h]
00007FF91DFCB883  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCB886  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFCB88A  8B 83 10 29 00 00           mov     eax, [rbx+2910h]
00007FF91DFCB890  89 83 20 29 00 00           mov     [rbx+2920h], eax
00007FF91DFCB896  8B 83 00 29 00 00           mov     eax, [rbx+2900h]
00007FF91DFCB89C  89 83 10 29 00 00           mov     [rbx+2910h], eax
00007FF91DFCB8A2  8B 83 F0 28 00 00           mov     eax, [rbx+28F0h]
00007FF91DFCB8A8  89 83 00 29 00 00           mov     [rbx+2900h], eax
00007FF91DFCB8AE  F3 0F 11 93 F0 28 00 00     movss   dword ptr [rbx+28F0h], xmm2
00007FF91DFCB8B6  F3 0F 59 83 40 29 00 00     mulss   xmm0, dword ptr [rbx+2940h]
00007FF91DFCB8BE  F3 0F 10 A3 00 29 00 00     movss   xmm4, dword ptr [rbx+2900h]
00007FF91DFCB8C6  F3 0F 10 8B 60 29 00 00     movss   xmm1, dword ptr [rbx+2960h]
00007FF91DFCB8CE  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFCB8D1  F3 0F 59 8B 10 29 00 00     mulss   xmm1, dword ptr [rbx+2910h]
00007FF91DFCB8D9  F3 0F 59 AB 50 29 00 00     mulss   xmm5, dword ptr [rbx+2950h]
00007FF91DFCB8E1  F3 0F 59 A3 80 29 00 00     mulss   xmm4, dword ptr [rbx+2980h]
00007FF91DFCB8E9  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCB8ED  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCB8F0  F3 0F 59 83 70 29 00 00     mulss   xmm0, dword ptr [rbx+2970h]
00007FF91DFCB8F8  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCB8FC  F3 0F 10 8B 90 29 00 00     movss   xmm1, dword ptr [rbx+2990h]
00007FF91DFCB904  F3 0F 59 8B 20 29 00 00     mulss   xmm1, dword ptr [rbx+2920h]
00007FF91DFCB90C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCB910  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCB914  76 05                       jbe     short loc_7FF91DFCB91B
00007FF91DFCB916  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFCB919  EB 03                       jmp     short loc_7FF91DFCB91E
00007FF91DFCB91B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCB91E  0F 2F 35 9B 9B 77 00        comiss  xmm6, cs:dword_7FF91E7454C0
00007FF91DFCB925  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFCB929  F3 0F 11 AB 00 29 00 00     movss   dword ptr [rbx+2900h], xmm5
00007FF91DFCB931  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFCB934  F3 0F 11 A3 10 29 00 00     movss   dword ptr [rbx+2910h], xmm4
00007FF91DFCB93C  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCB940  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFCB944  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCB948  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCB94B  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFCB94F  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFCB953  73 09                       jnb     short loc_7FF91DFCB95E
00007FF91DFCB955  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFCB959  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
00007FF91DFCB95E  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFCB962  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
00007FF91DFCB967  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFCB96A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCB96E  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFCB972  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFCB976  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFCB97A  72 03                       jb      short loc_7FF91DFCB97F
00007FF91DFCB97C  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFCB97F  F3 0F 11 93 30 29 00 00     movss   dword ptr [rbx+2930h], xmm2
00007FF91DFCB987  F3 0F 59 93 30 26 00 00     mulss   xmm2, dword ptr [rbx+2630h]
00007FF91DFCB98F  F3 0F 11 93 A0 29 00 00     movss   dword ptr [rbx+29A0h], xmm2
00007FF91DFCB997  F3 0F 59 93 80 26 00 00     mulss   xmm2, dword ptr [rbx+2680h]
00007FF91DFCB99F  F3 0F 11 93 B0 29 00 00     movss   dword ptr [rbx+29B0h], xmm2
00007FF91DFCB9A7  F3 0F 10 83 60 11 00 00     movss   xmm0, dword ptr [rbx+1160h]
00007FF91DFCB9AF  F3 0F 58 83 C0 0E 00 00     addss   xmm0, dword ptr [rbx+0EC0h]
00007FF91DFCB9B7  44 0F 5A E0                 cvtps2pd xmm12, xmm0
00007FF91DFCB9BB  F2 44 0F 5F 25 E4 F2 61 00  maxsd   xmm12, cs:qword_7FF91E5EACA8
00007FF91DFCB9C4  F2 44 0F 5D 25 C3 F2 61 00  minsd   xmm12, cs:qword_7FF91E5EAC90
00007FF91DFCB9CD  41 0F 28 CC                 movaps  xmm1, xmm12
00007FF91DFCB9D1  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFCB9D5  F2 0F 58 05 8B 98 77 00     addsd   xmm0, cs:qword_7FF91E745268
00007FF91DFCB9DD  F2 41 0F 59 CC              mulsd   xmm1, xmm12
00007FF91DFCB9E2  41 0F 28 FC                 movaps  xmm7, xmm12
00007FF91DFCB9E6  F2 0F 2C C0                 cvttsd2si eax, xmm0
00007FF91DFCB9EA  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFCB9ED  48 63 C8                    movsxd  rcx, eax
00007FF91DFCB9F0  F2 41 0F 59 D4              mulsd   xmm2, xmm12
00007FF91DFCB9F5  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
00007FF91DFCB9FC  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCB9FF  F2 41 0F 59 DC              mulsd   xmm3, xmm12
00007FF91DFCBA04  48 8D 0D D5 DA 61 00        lea     rcx, unk_7FF91E5E94E0
00007FF91DFCBA0B  48 03 C1                    add     rax, rcx
00007FF91DFCBA0E  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFCBA11  F2 41 0F 59 E4              mulsd   xmm4, xmm12
00007FF91DFCBA16  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
00007FF91DFCBA1B  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
00007FF91DFCBA20  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
00007FF91DFCBA25  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFCBA28  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
00007FF91DFCBA2C  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
00007FF91DFCBA31  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
00007FF91DFCBA36  F2 0F 58 F9                 addsd   xmm7, xmm1
00007FF91DFCBA3A  F2 41 0F 59 EC              mulsd   xmm5, xmm12
00007FF91DFCBA3F  F2 0F 58 FA                 addsd   xmm7, xmm2
00007FF91DFCBA43  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFCBA46  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
00007FF91DFCBA4B  F2 41 0F 59 F4              mulsd   xmm6, xmm12
00007FF91DFCBA50  F2 0F 58 FB                 addsd   xmm7, xmm3
00007FF91DFCBA54  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFCBA58  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
00007FF91DFCBA5D  F2 0F 58 FC                 addsd   xmm7, xmm4
00007FF91DFCBA61  F2 45 0F 59 C4              mulsd   xmm8, xmm12
00007FF91DFCBA66  F2 0F 58 FD                 addsd   xmm7, xmm5
00007FF91DFCBA6A  45 0F 28 C8                 movaps  xmm9, xmm8
00007FF91DFCBA6E  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
00007FF91DFCBA77  F2 45 0F 59 CC              mulsd   xmm9, xmm12
00007FF91DFCBA7C  F2 0F 58 FE                 addsd   xmm7, xmm6
00007FF91DFCBA80  45 0F 28 D1                 movaps  xmm10, xmm9
00007FF91DFCBA84  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
00007FF91DFCBA8D  F2 41 0F 58 F8              addsd   xmm7, xmm8
00007FF91DFCBA92  F2 45 0F 59 D4              mulsd   xmm10, xmm12
00007FF91DFCBA97  F2 41 0F 58 F9              addsd   xmm7, xmm9
00007FF91DFCBA9C  45 0F 28 DA                 movaps  xmm11, xmm10
00007FF91DFCBAA0  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
00007FF91DFCBAA9  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFCBAAE  F2 41 0F 58 FA              addsd   xmm7, xmm10
00007FF91DFCBAB3  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFCBAB7  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFCBABC  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
00007FF91DFCBAC4  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
00007FF91DFCBACD  F2 0F 58 F8                 addsd   xmm7, xmm0
00007FF91DFCBAD1  F2 41 0F 58 FB              addsd   xmm7, xmm11
00007FF91DFCBAD6  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
00007FF91DFCBADA  F3 0F 5D 1D B6 F1 61 00     minss   xmm3, cs:dword_7FF91E5EAC98
00007FF91DFCBAE2  F3 0F 5F 1D C6 F1 61 00     maxss   xmm3, cs:dword_7FF91E5EACB0
00007FF91DFCBAEA  F3 0F 59 9B D0 0E 00 00     mulss   xmm3, dword ptr [rbx+0ED0h]
00007FF91DFCBAF2  F3 0F 11 9B 40 11 00 00     movss   dword ptr [rbx+1140h], xmm3
00007FF91DFCBAFA  8B 83 E0 12 00 00           mov     eax, [rbx+12E0h]
00007FF91DFCBB00  F3 0F 10 AB C0 0E 00 00     movss   xmm5, dword ptr [rbx+0EC0h]
00007FF91DFCBB08  F3 0F 10 83 90 10 00 00     movss   xmm0, dword ptr [rbx+1090h]
00007FF91DFCBB10  F3 0F 10 8B A0 10 00 00     movss   xmm1, dword ptr [rbx+10A0h]
00007FF91DFCBB18  F3 0F 10 93 B0 10 00 00     movss   xmm2, dword ptr [rbx+10B0h]
00007FF91DFCBB20  89 83 F0 12 00 00           mov     [rbx+12F0h], eax
00007FF91DFCBB26  8B 83 00 13 00 00           mov     eax, [rbx+1300h]
00007FF91DFCBB2C  89 83 10 13 00 00           mov     [rbx+1310h], eax
00007FF91DFCBB32  8B 83 B0 13 00 00           mov     eax, [rbx+13B0h]
00007FF91DFCBB38  89 83 C0 13 00 00           mov     [rbx+13C0h], eax
00007FF91DFCBB3E  8B 83 A0 13 00 00           mov     eax, [rbx+13A0h]
00007FF91DFCBB44  89 83 B0 13 00 00           mov     [rbx+13B0h], eax
00007FF91DFCBB4A  8B 83 90 13 00 00           mov     eax, [rbx+1390h]
00007FF91DFCBB50  89 83 A0 13 00 00           mov     [rbx+13A0h], eax
00007FF91DFCBB56  8B 83 80 13 00 00           mov     eax, [rbx+1380h]
00007FF91DFCBB5C  89 83 90 13 00 00           mov     [rbx+1390h], eax
00007FF91DFCBB62  8B 83 70 13 00 00           mov     eax, [rbx+1370h]
00007FF91DFCBB68  89 83 80 13 00 00           mov     [rbx+1380h], eax
00007FF91DFCBB6E  8B 83 60 13 00 00           mov     eax, [rbx+1360h]
00007FF91DFCBB74  89 83 70 13 00 00           mov     [rbx+1370h], eax
00007FF91DFCBB7A  8B 83 50 13 00 00           mov     eax, [rbx+1350h]
00007FF91DFCBB80  89 83 60 13 00 00           mov     [rbx+1360h], eax
00007FF91DFCBB86  8B 83 30 14 00 00           mov     eax, [rbx+1430h]
00007FF91DFCBB8C  89 83 40 14 00 00           mov     [rbx+1440h], eax
00007FF91DFCBB92  8B 83 20 14 00 00           mov     eax, [rbx+1420h]
00007FF91DFCBB98  89 83 30 14 00 00           mov     [rbx+1430h], eax
00007FF91DFCBB9E  8B 83 10 14 00 00           mov     eax, [rbx+1410h]
00007FF91DFCBBA4  89 83 20 14 00 00           mov     [rbx+1420h], eax
00007FF91DFCBBAA  8B 83 00 14 00 00           mov     eax, [rbx+1400h]
00007FF91DFCBBB0  89 83 10 14 00 00           mov     [rbx+1410h], eax
00007FF91DFCBBB6  8B 83 F0 13 00 00           mov     eax, [rbx+13F0h]
00007FF91DFCBBBC  89 83 00 14 00 00           mov     [rbx+1400h], eax
00007FF91DFCBBC2  8B 83 E0 13 00 00           mov     eax, [rbx+13E0h]
00007FF91DFCBBC8  89 83 F0 13 00 00           mov     [rbx+13F0h], eax
00007FF91DFCBBCE  8B 83 D0 13 00 00           mov     eax, [rbx+13D0h]
00007FF91DFCBBD4  89 83 E0 13 00 00           mov     [rbx+13E0h], eax
00007FF91DFCBBDA  8B 83 B0 14 00 00           mov     eax, [rbx+14B0h]
00007FF91DFCBBE0  89 83 C0 14 00 00           mov     [rbx+14C0h], eax
00007FF91DFCBBE6  8B 83 A0 14 00 00           mov     eax, [rbx+14A0h]
00007FF91DFCBBEC  89 83 B0 14 00 00           mov     [rbx+14B0h], eax
00007FF91DFCBBF2  8B 83 90 14 00 00           mov     eax, [rbx+1490h]
00007FF91DFCBBF8  89 83 A0 14 00 00           mov     [rbx+14A0h], eax
00007FF91DFCBBFE  8B 83 80 14 00 00           mov     eax, [rbx+1480h]
00007FF91DFCBC04  89 83 90 14 00 00           mov     [rbx+1490h], eax
00007FF91DFCBC0A  8B 83 70 14 00 00           mov     eax, [rbx+1470h]
00007FF91DFCBC10  89 83 80 14 00 00           mov     [rbx+1480h], eax
00007FF91DFCBC16  8B 83 60 14 00 00           mov     eax, [rbx+1460h]
00007FF91DFCBC1C  89 83 70 14 00 00           mov     [rbx+1470h], eax
00007FF91DFCBC22  8B 83 50 14 00 00           mov     eax, [rbx+1450h]
00007FF91DFCBC28  89 83 60 14 00 00           mov     [rbx+1460h], eax
00007FF91DFCBC2E  8B 83 30 15 00 00           mov     eax, [rbx+1530h]
00007FF91DFCBC34  89 83 40 15 00 00           mov     [rbx+1540h], eax
00007FF91DFCBC3A  8B 83 20 15 00 00           mov     eax, [rbx+1520h]
00007FF91DFCBC40  89 83 30 15 00 00           mov     [rbx+1530h], eax
00007FF91DFCBC46  8B 83 10 15 00 00           mov     eax, [rbx+1510h]
00007FF91DFCBC4C  89 83 20 15 00 00           mov     [rbx+1520h], eax
00007FF91DFCBC52  8B 83 00 15 00 00           mov     eax, [rbx+1500h]
00007FF91DFCBC58  89 83 10 15 00 00           mov     [rbx+1510h], eax
00007FF91DFCBC5E  8B 83 F0 14 00 00           mov     eax, [rbx+14F0h]
00007FF91DFCBC64  89 83 00 15 00 00           mov     [rbx+1500h], eax
00007FF91DFCBC6A  8B 83 E0 14 00 00           mov     eax, [rbx+14E0h]
00007FF91DFCBC70  89 83 F0 14 00 00           mov     [rbx+14F0h], eax
00007FF91DFCBC76  8B 83 D0 14 00 00           mov     eax, [rbx+14D0h]
00007FF91DFCBC7C  89 83 E0 14 00 00           mov     [rbx+14E0h], eax
00007FF91DFCBC82  8B 83 70 15 00 00           mov     eax, [rbx+1570h]
00007FF91DFCBC88  89 83 80 15 00 00           mov     [rbx+1580h], eax
00007FF91DFCBC8E  8B 83 60 15 00 00           mov     eax, [rbx+1560h]
00007FF91DFCBC94  89 83 70 15 00 00           mov     [rbx+1570h], eax
00007FF91DFCBC9A  F3 0F 11 83 80 12 00 00     movss   dword ptr [rbx+1280h], xmm0
00007FF91DFCBCA2  F3 0F 11 8B 90 12 00 00     movss   dword ptr [rbx+1290h], xmm1
00007FF91DFCBCAA  F3 0F 58 AB A0 18 00 00     addss   xmm5, dword ptr [rbx+18A0h]
00007FF91DFCBCB2  F3 0F 59 9B A0 15 00 00     mulss   xmm3, dword ptr [rbx+15A0h]
00007FF91DFCBCBA  F3 0F 10 83 90 15 00 00     movss   xmm0, dword ptr [rbx+1590h]
00007FF91DFCBCC2  F3 0F 11 93 A0 12 00 00     movss   dword ptr [rbx+12A0h], xmm2
00007FF91DFCBCCA  F3 0F 10 93 C0 15 00 00     movss   xmm2, dword ptr [rbx+15C0h]
00007FF91DFCBCD2  F3 0F 59 AB B0 18 00 00     mulss   xmm5, dword ptr [rbx+18B0h]
00007FF91DFCBCDA  F3 0F 5F D3                 maxss   xmm2, xmm3
00007FF91DFCBCDE  F3 0F 58 AB 90 18 00 00     addss   xmm5, dword ptr [rbx+1890h]
00007FF91DFCBCE6  F3 0F 11 93 B0 12 00 00     movss   dword ptr [rbx+12B0h], xmm2
00007FF91DFCBCEE  F3 0F 58 83 E0 0E 00 00     addss   xmm0, dword ptr [rbx+0EE0h]
00007FF91DFCBCF6  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFCBCFA  F3 0F 11 83 D0 12 00 00     movss   dword ptr [rbx+12D0h], xmm0
00007FF91DFCBD02  76 05                       jbe     short loc_7FF91DFCBD09
00007FF91DFCBD04  0F 5A C5                    cvtps2pd xmm0, xmm5
00007FF91DFCBD07  EB 03                       jmp     short loc_7FF91DFCBD0C
00007FF91DFCBD09  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFCBD0C  F3 0F 10 0D 48 92 77 00     movss   xmm1, cs:dword_7FF91E744F5C
00007FF91DFCBD14  F3 44 0F 10 15 CB 94 77 00  movss   xmm10, cs:flt_7FF91E7451E8
00007FF91DFCBD1D  F3 0F 5E CA                 divss   xmm1, xmm2
00007FF91DFCBD21  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFCBD25  F3 0F 11 8B C0 12 00 00     movss   dword ptr [rbx+12C0h], xmm1
00007FF91DFCBD2D  F3 0F 11 83 50 15 00 00     movss   dword ptr [rbx+1550h], xmm0
00007FF91DFCBD35  F3 0F 10 B3 10 13 00 00     movss   xmm6, dword ptr [rbx+1310h]
00007FF91DFCBD3D  F3 0F 10 8B F0 12 00 00     movss   xmm1, dword ptr [rbx+12F0h]
00007FF91DFCBD45  F3 0F 11 B3 30 12 00 00     movss   dword ptr [rbx+1230h], xmm6
00007FF91DFCBD4D  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFCBD51  F3 0F 11 8B 40 12 00 00     movss   dword ptr [rbx+1240h], xmm1
00007FF91DFCBD59  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFCBD5D  76 1B                       jbe     short loc_7FF91DFCBD7A
00007FF91DFCBD5F  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCBD64  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCBD68  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCBD6B  E8 68 37 38 00              call    fmodf
00007FF91DFCBD70  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCBD73  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCBD78  EB 1F                       jmp     short loc_7FF91DFCBD99
00007FF91DFCBD7A  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFCBD7E  73 19                       jnb     short loc_7FF91DFCBD99
00007FF91DFCBD80  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCBD85  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCBD89  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCBD8C  E8 47 37 38 00              call    fmodf
00007FF91DFCBD91  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCBD94  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCBD99  F3 44 0F 10 25 6A 92 77 00  movss   xmm12, cs:dword_7FF91E74500C
00007FF91DFCBDA2  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCBDA5  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCBDAA  F3 0F 11 B3 20 12 00 00     movss   dword ptr [rbx+1220h], xmm6
00007FF91DFCBDB2  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFCBDB5  F3 0F 59 BB 10 16 00 00     mulss   xmm7, dword ptr [rbx+1610h]
00007FF91DFCBDBD  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFCBDC2  E8 F9 D1 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCBDC7  F3 44 0F 10 1D 74 96 77 00  movss   xmm11, cs:dword_7FF91E745444
00007FF91DFCBDD0  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFCBDD3  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFCBDD8  F3 0F 59 AB C0 12 00 00     mulss   xmm5, dword ptr [rbx+12C0h]
00007FF91DFCBDE0  F3 0F 59 AB E0 15 00 00     mulss   xmm5, dword ptr [rbx+15E0h]
00007FF91DFCBDE8  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCBDEC  73 06                       jnb     short loc_7FF91DFCBDF4
00007FF91DFCBDEE  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCBDF2  EB 05                       jmp     short loc_7FF91DFCBDF9
00007FF91DFCBDF4  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCBDF9  F3 0F 59 AB B0 15 00 00     mulss   xmm5, dword ptr [rbx+15B0h]
00007FF91DFCBE01  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCBE04  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFCBE08  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCBE0B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCBE0E  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCBE16  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCBE19  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCBE1D  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCBE20  F3 0F 59 A3 80 17 00 00     mulss   xmm4, dword ptr [rbx+1780h]
00007FF91DFCBE28  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCBE30  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFCBE34  F3 0F 58 A3 70 17 00 00     addss   xmm4, dword ptr [rbx+1770h]
00007FF91DFCBE3C  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCBE40  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCBE43  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCBE4B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCBE4F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCBE53  F3 0F 10 8B D0 12 00 00     movss   xmm1, dword ptr [rbx+12D0h]
00007FF91DFCBE5B  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCBE5F  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCBE62  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFCBE66  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCBE6A  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCBE6E  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFCBE72  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFCBE76  F3 0F 11 A3 20 13 00 00     movss   dword ptr [rbx+1320h], xmm4
00007FF91DFCBE7E  72 07                       jb      short loc_7FF91DFCBE87
00007FF91DFCBE80  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFCBE85  EB 05                       jmp     short loc_7FF91DFCBE8C
00007FF91DFCBE87  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFCBE8C  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCBE8F  73 06                       jnb     short loc_7FF91DFCBE97
00007FF91DFCBE91  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFCBE95  EB 06                       jmp     short loc_7FF91DFCBE9D
00007FF91DFCBE97  76 04                       jbe     short loc_7FF91DFCBE9D
00007FF91DFCBE99  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFCBE9D  F3 44 0F 10 83 20 12 00 00  movss   xmm8, dword ptr [rbx+1220h]
00007FF91DFCBEA6  F3 0F 59 B3 20 16 00 00     mulss   xmm6, dword ptr [rbx+1620h]
00007FF91DFCBEAE  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFCBEB2  E8 09 D1 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCBEB7  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFCBEBA  F3 0F 10 83 D0 15 00 00     movss   xmm0, dword ptr [rbx+15D0h]
00007FF91DFCBEC2  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFCBEC6  72 18                       jb      short loc_7FF91DFCBEE0
00007FF91DFCBEC8  0F 2F 83 30 12 00 00        comiss  xmm0, dword ptr [rbx+1230h]
00007FF91DFCBECF  76 0F                       jbe     short loc_7FF91DFCBEE0
00007FF91DFCBED1  F3 0F 10 BB 40 12 00 00     movss   xmm7, dword ptr [rbx+1240h]
00007FF91DFCBED9  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFCBEDE  EB 08                       jmp     short loc_7FF91DFCBEE8
00007FF91DFCBEE0  F3 0F 10 BB 40 12 00 00     movss   xmm7, dword ptr [rbx+1240h]
00007FF91DFCBEE8  0F 2F 3D E1 93 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFCBEEF  F3 0F 59 A3 C0 12 00 00     mulss   xmm4, dword ptr [rbx+12C0h]
00007FF91DFCBEF7  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFCBEFC  F3 0F 59 A3 F0 15 00 00     mulss   xmm4, dword ptr [rbx+15F0h]
00007FF91DFCBF04  72 03                       jb      short loc_7FF91DFCBF09
00007FF91DFCBF06  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFCBF09  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFCBF0D  73 06                       jnb     short loc_7FF91DFCBF15
00007FF91DFCBF0F  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFCBF13  EB 05                       jmp     short loc_7FF91DFCBF1A
00007FF91DFCBF15  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFCBF1A  F3 0F 11 BB 40 12 00 00     movss   dword ptr [rbx+1240h], xmm7
00007FF91DFCBF22  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFCBF27  F3 0F 59 A3 B0 15 00 00     mulss   xmm4, dword ptr [rbx+15B0h]
00007FF91DFCBF2F  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFCBF32  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFCBF37  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFCBF3B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCBF3E  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFCBF43  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCBF47  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCBF4A  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCBF4E  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFCBF52  F3 44 0F 59 8B 80 17 00 00  mulss   xmm9, dword ptr [rbx+1780h]
00007FF91DFCBF5B  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFCBF60  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCBF63  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCBF6B  F3 44 0F 58 8B 70 17 00 00  addss   xmm9, dword ptr [rbx+1770h]
00007FF91DFCBF74  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCBF7C  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFCBF81  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCBF84  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCBF8C  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFCBF91  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCBF95  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFCBF9A  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFCBF9D  0F 54 05 EC 97 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFCBFA4  0F 57 05 15 98 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFCBFAB  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFCBFB0  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFCBFB5  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFCBFBA  F3 44 0F 11 8B 30 13 00 00  movss   dword ptr [rbx+1330h], xmm9
00007FF91DFCBFC3  E8 F8 CF FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCBFC8  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFCBFCC  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFCBFD0  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFCBFD5  73 06                       jnb     short loc_7FF91DFCBFDD
00007FF91DFCBFD7  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFCBFDB  EB 06                       jmp     short loc_7FF91DFCBFE3
00007FF91DFCBFDD  76 04                       jbe     short loc_7FF91DFCBFE3
00007FF91DFCBFDF  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFCBFE3  F3 44 0F 59 83 C0 12 00 00  mulss   xmm8, dword ptr [rbx+12C0h]
00007FF91DFCBFEC  F3 0F 59 BB 30 16 00 00     mulss   xmm7, dword ptr [rbx+1630h]
00007FF91DFCBFF4  F3 44 0F 59 05 9B EC 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFCBFFD  F3 44 0F 59 83 00 16 00 00  mulss   xmm8, dword ptr [rbx+1600h]
00007FF91DFCC006  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFCC00A  73 06                       jnb     short loc_7FF91DFCC012
00007FF91DFCC00C  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFCC010  EB 05                       jmp     short loc_7FF91DFCC017
00007FF91DFCC012  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFCC017  F3 44 0F 59 83 B0 15 00 00  mulss   xmm8, dword ptr [rbx+15B0h]
00007FF91DFCC020  F3 44 0F 59 8B 90 12 00 00  mulss   xmm9, dword ptr [rbx+1290h]
00007FF91DFCC029  F3 0F 10 B3 20 12 00 00     movss   xmm6, dword ptr [rbx+1220h]
00007FF91DFCC031  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCC035  F3 0F 10 AB 40 12 00 00     movss   xmm5, dword ptr [rbx+1240h]
00007FF91DFCC03D  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFCC042  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCC045  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCC048  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC04C  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCC04F  F3 0F 59 A3 80 17 00 00     mulss   xmm4, dword ptr [rbx+1780h]
00007FF91DFCC057  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCC05A  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCC062  F3 0F 58 A3 70 17 00 00     addss   xmm4, dword ptr [rbx+1770h]
00007FF91DFCC06A  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFCC06F  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCC077  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC07B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCC07E  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCC086  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCC08A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC08E  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC092  F3 0F 10 83 20 13 00 00     movss   xmm0, dword ptr [rbx+1320h]
00007FF91DFCC09A  F3 0F 59 83 80 12 00 00     mulss   xmm0, dword ptr [rbx+1280h]
00007FF91DFCC0A2  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCC0A6  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFCC0AB  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFCC0B0  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFCC0B4  F3 0F 59 A3 A0 12 00 00     mulss   xmm4, dword ptr [rbx+12A0h]
00007FF91DFCC0BC  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCC0C0  F3 0F 11 A3 50 13 00 00     movss   dword ptr [rbx+1350h], xmm4
00007FF91DFCC0C8  F3 0F 11 B3 30 12 00 00     movss   dword ptr [rbx+1230h], xmm6
00007FF91DFCC0D0  F3 0F 11 AB 40 12 00 00     movss   dword ptr [rbx+1240h], xmm5
00007FF91DFCC0D8  F3 0F 58 B3 B0 12 00 00     addss   xmm6, dword ptr [rbx+12B0h]
00007FF91DFCC0E0  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFCC0E4  76 1B                       jbe     short loc_7FF91DFCC101
00007FF91DFCC0E6  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCC0EB  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCC0EF  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCC0F2  E8 E1 33 38 00              call    fmodf
00007FF91DFCC0F7  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCC0FA  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCC0FF  EB 1F                       jmp     short loc_7FF91DFCC120
00007FF91DFCC101  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFCC105  73 19                       jnb     short loc_7FF91DFCC120
00007FF91DFCC107  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCC10C  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCC110  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCC113  E8 C0 33 38 00              call    fmodf
00007FF91DFCC118  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCC11B  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCC120  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCC123  F3 0F 11 B3 20 12 00 00     movss   dword ptr [rbx+1220h], xmm6
00007FF91DFCC12B  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCC130  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFCC133  F3 0F 59 BB 10 16 00 00     mulss   xmm7, dword ptr [rbx+1610h]
00007FF91DFCC13B  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFCC140  E8 7B CE FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCC145  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFCC148  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFCC14D  F3 0F 59 AB C0 12 00 00     mulss   xmm5, dword ptr [rbx+12C0h]
00007FF91DFCC155  F3 0F 59 AB E0 15 00 00     mulss   xmm5, dword ptr [rbx+15E0h]
00007FF91DFCC15D  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCC161  73 06                       jnb     short loc_7FF91DFCC169
00007FF91DFCC163  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCC167  EB 05                       jmp     short loc_7FF91DFCC16E
00007FF91DFCC169  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCC16E  F3 0F 59 AB B0 15 00 00     mulss   xmm5, dword ptr [rbx+15B0h]
00007FF91DFCC176  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCC179  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFCC17D  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCC180  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCC183  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCC18B  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCC18E  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC192  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCC195  F3 0F 59 A3 80 17 00 00     mulss   xmm4, dword ptr [rbx+1780h]
00007FF91DFCC19D  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCC1A5  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFCC1A9  F3 0F 58 A3 70 17 00 00     addss   xmm4, dword ptr [rbx+1770h]
00007FF91DFCC1B1  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC1B5  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCC1B8  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCC1C0  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCC1C4  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC1C8  F3 0F 10 8B D0 12 00 00     movss   xmm1, dword ptr [rbx+12D0h]
00007FF91DFCC1D0  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC1D4  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCC1D7  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFCC1DB  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCC1DF  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCC1E3  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFCC1E7  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFCC1EB  F3 0F 11 A3 20 13 00 00     movss   dword ptr [rbx+1320h], xmm4
00007FF91DFCC1F3  72 07                       jb      short loc_7FF91DFCC1FC
00007FF91DFCC1F5  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFCC1FA  EB 05                       jmp     short loc_7FF91DFCC201
00007FF91DFCC1FC  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFCC201  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCC204  73 06                       jnb     short loc_7FF91DFCC20C
00007FF91DFCC206  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFCC20A  EB 06                       jmp     short loc_7FF91DFCC212
00007FF91DFCC20C  76 04                       jbe     short loc_7FF91DFCC212
00007FF91DFCC20E  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFCC212  F3 44 0F 10 83 20 12 00 00  movss   xmm8, dword ptr [rbx+1220h]
00007FF91DFCC21B  F3 0F 59 B3 20 16 00 00     mulss   xmm6, dword ptr [rbx+1620h]
00007FF91DFCC223  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFCC227  E8 94 CD FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCC22C  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFCC22F  F3 0F 10 83 D0 15 00 00     movss   xmm0, dword ptr [rbx+15D0h]
00007FF91DFCC237  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFCC23B  72 18                       jb      short loc_7FF91DFCC255
00007FF91DFCC23D  0F 2F 83 30 12 00 00        comiss  xmm0, dword ptr [rbx+1230h]
00007FF91DFCC244  76 0F                       jbe     short loc_7FF91DFCC255
00007FF91DFCC246  F3 0F 10 BB 40 12 00 00     movss   xmm7, dword ptr [rbx+1240h]
00007FF91DFCC24E  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFCC253  EB 08                       jmp     short loc_7FF91DFCC25D
00007FF91DFCC255  F3 0F 10 BB 40 12 00 00     movss   xmm7, dword ptr [rbx+1240h]
00007FF91DFCC25D  0F 2F 3D 6C 90 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFCC264  F3 0F 59 A3 C0 12 00 00     mulss   xmm4, dword ptr [rbx+12C0h]
00007FF91DFCC26C  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFCC271  F3 0F 59 A3 F0 15 00 00     mulss   xmm4, dword ptr [rbx+15F0h]
00007FF91DFCC279  72 03                       jb      short loc_7FF91DFCC27E
00007FF91DFCC27B  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFCC27E  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFCC282  73 06                       jnb     short loc_7FF91DFCC28A
00007FF91DFCC284  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFCC288  EB 05                       jmp     short loc_7FF91DFCC28F
00007FF91DFCC28A  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFCC28F  F3 0F 11 BB 40 12 00 00     movss   dword ptr [rbx+1240h], xmm7
00007FF91DFCC297  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFCC29C  F3 0F 59 A3 B0 15 00 00     mulss   xmm4, dword ptr [rbx+15B0h]
00007FF91DFCC2A4  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFCC2A7  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFCC2AC  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFCC2B0  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCC2B3  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFCC2B8  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC2BC  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCC2BF  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCC2C3  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFCC2C7  F3 44 0F 59 8B 80 17 00 00  mulss   xmm9, dword ptr [rbx+1780h]
00007FF91DFCC2D0  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFCC2D5  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCC2D8  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCC2E0  F3 44 0F 58 8B 70 17 00 00  addss   xmm9, dword ptr [rbx+1770h]
00007FF91DFCC2E9  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCC2F1  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFCC2F6  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCC2F9  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCC301  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFCC306  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC30A  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFCC30F  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFCC312  0F 54 05 77 94 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFCC319  0F 57 05 A0 94 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFCC320  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFCC325  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFCC32A  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFCC32F  F3 44 0F 11 8B 30 13 00 00  movss   dword ptr [rbx+1330h], xmm9
00007FF91DFCC338  E8 83 CC FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCC33D  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFCC341  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFCC345  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFCC34A  73 06                       jnb     short loc_7FF91DFCC352
00007FF91DFCC34C  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFCC350  EB 06                       jmp     short loc_7FF91DFCC358
00007FF91DFCC352  76 04                       jbe     short loc_7FF91DFCC358
00007FF91DFCC354  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFCC358  F3 44 0F 59 83 C0 12 00 00  mulss   xmm8, dword ptr [rbx+12C0h]
00007FF91DFCC361  F3 0F 59 BB 30 16 00 00     mulss   xmm7, dword ptr [rbx+1630h]
00007FF91DFCC369  F3 44 0F 59 05 26 E9 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFCC372  F3 44 0F 59 83 00 16 00 00  mulss   xmm8, dword ptr [rbx+1600h]
00007FF91DFCC37B  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFCC37F  73 06                       jnb     short loc_7FF91DFCC387
00007FF91DFCC381  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFCC385  EB 05                       jmp     short loc_7FF91DFCC38C
00007FF91DFCC387  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFCC38C  F3 44 0F 59 83 B0 15 00 00  mulss   xmm8, dword ptr [rbx+15B0h]
00007FF91DFCC395  F3 44 0F 59 8B 90 12 00 00  mulss   xmm9, dword ptr [rbx+1290h]
00007FF91DFCC39E  F3 0F 10 B3 20 12 00 00     movss   xmm6, dword ptr [rbx+1220h]
00007FF91DFCC3A6  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCC3AA  F3 0F 10 AB 40 12 00 00     movss   xmm5, dword ptr [rbx+1240h]
00007FF91DFCC3B2  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFCC3B7  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCC3BA  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCC3BD  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC3C1  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCC3C4  F3 0F 59 A3 80 17 00 00     mulss   xmm4, dword ptr [rbx+1780h]
00007FF91DFCC3CC  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCC3CF  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCC3D7  F3 0F 58 A3 70 17 00 00     addss   xmm4, dword ptr [rbx+1770h]
00007FF91DFCC3DF  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFCC3E4  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCC3EC  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC3F0  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCC3F3  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCC3FB  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCC3FF  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC403  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC407  F3 0F 10 83 20 13 00 00     movss   xmm0, dword ptr [rbx+1320h]
00007FF91DFCC40F  F3 0F 59 83 80 12 00 00     mulss   xmm0, dword ptr [rbx+1280h]
00007FF91DFCC417  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCC41B  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFCC420  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFCC425  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFCC429  F3 0F 59 A3 A0 12 00 00     mulss   xmm4, dword ptr [rbx+12A0h]
00007FF91DFCC431  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCC435  F3 0F 11 A3 D0 13 00 00     movss   dword ptr [rbx+13D0h], xmm4
00007FF91DFCC43D  F3 0F 11 B3 30 12 00 00     movss   dword ptr [rbx+1230h], xmm6
00007FF91DFCC445  F3 0F 11 AB 40 12 00 00     movss   dword ptr [rbx+1240h], xmm5
00007FF91DFCC44D  F3 0F 58 B3 B0 12 00 00     addss   xmm6, dword ptr [rbx+12B0h]
00007FF91DFCC455  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFCC459  76 1B                       jbe     short loc_7FF91DFCC476
00007FF91DFCC45B  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCC460  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCC464  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCC467  E8 6C 30 38 00              call    fmodf
00007FF91DFCC46C  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCC46F  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCC474  EB 1F                       jmp     short loc_7FF91DFCC495
00007FF91DFCC476  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFCC47A  73 19                       jnb     short loc_7FF91DFCC495
00007FF91DFCC47C  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCC481  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCC485  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCC488  E8 4B 30 38 00              call    fmodf
00007FF91DFCC48D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCC490  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCC495  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCC498  F3 0F 11 B3 20 12 00 00     movss   dword ptr [rbx+1220h], xmm6
00007FF91DFCC4A0  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCC4A5  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFCC4A8  F3 0F 59 BB 10 16 00 00     mulss   xmm7, dword ptr [rbx+1610h]
00007FF91DFCC4B0  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFCC4B5  E8 06 CB FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCC4BA  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFCC4BD  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFCC4C2  F3 0F 59 AB C0 12 00 00     mulss   xmm5, dword ptr [rbx+12C0h]
00007FF91DFCC4CA  F3 0F 59 AB E0 15 00 00     mulss   xmm5, dword ptr [rbx+15E0h]
00007FF91DFCC4D2  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCC4D6  73 06                       jnb     short loc_7FF91DFCC4DE
00007FF91DFCC4D8  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCC4DC  EB 05                       jmp     short loc_7FF91DFCC4E3
00007FF91DFCC4DE  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCC4E3  F3 0F 59 AB B0 15 00 00     mulss   xmm5, dword ptr [rbx+15B0h]
00007FF91DFCC4EB  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCC4EE  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFCC4F2  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCC4F5  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCC4F8  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCC500  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCC503  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC507  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCC50A  F3 0F 59 A3 80 17 00 00     mulss   xmm4, dword ptr [rbx+1780h]
00007FF91DFCC512  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCC51A  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFCC51E  F3 0F 58 A3 70 17 00 00     addss   xmm4, dword ptr [rbx+1770h]
00007FF91DFCC526  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC52A  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCC52D  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCC535  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCC539  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC53D  F3 0F 10 8B D0 12 00 00     movss   xmm1, dword ptr [rbx+12D0h]
00007FF91DFCC545  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC549  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCC54C  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFCC550  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCC554  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCC558  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFCC55C  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFCC560  F3 0F 11 A3 20 13 00 00     movss   dword ptr [rbx+1320h], xmm4
00007FF91DFCC568  72 07                       jb      short loc_7FF91DFCC571
00007FF91DFCC56A  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFCC56F  EB 05                       jmp     short loc_7FF91DFCC576
00007FF91DFCC571  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFCC576  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCC579  73 06                       jnb     short loc_7FF91DFCC581
00007FF91DFCC57B  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFCC57F  EB 06                       jmp     short loc_7FF91DFCC587
00007FF91DFCC581  76 04                       jbe     short loc_7FF91DFCC587
00007FF91DFCC583  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFCC587  F3 44 0F 10 83 20 12 00 00  movss   xmm8, dword ptr [rbx+1220h]
00007FF91DFCC590  F3 0F 59 B3 20 16 00 00     mulss   xmm6, dword ptr [rbx+1620h]
00007FF91DFCC598  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFCC59C  E8 1F CA FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCC5A1  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFCC5A4  F3 0F 10 83 D0 15 00 00     movss   xmm0, dword ptr [rbx+15D0h]
00007FF91DFCC5AC  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFCC5B0  72 18                       jb      short loc_7FF91DFCC5CA
00007FF91DFCC5B2  0F 2F 83 30 12 00 00        comiss  xmm0, dword ptr [rbx+1230h]
00007FF91DFCC5B9  76 0F                       jbe     short loc_7FF91DFCC5CA
00007FF91DFCC5BB  F3 0F 10 BB 40 12 00 00     movss   xmm7, dword ptr [rbx+1240h]
00007FF91DFCC5C3  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFCC5C8  EB 08                       jmp     short loc_7FF91DFCC5D2
00007FF91DFCC5CA  F3 0F 10 BB 40 12 00 00     movss   xmm7, dword ptr [rbx+1240h]
00007FF91DFCC5D2  0F 2F 3D F7 8C 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFCC5D9  F3 0F 59 A3 C0 12 00 00     mulss   xmm4, dword ptr [rbx+12C0h]
00007FF91DFCC5E1  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFCC5E6  F3 0F 59 A3 F0 15 00 00     mulss   xmm4, dword ptr [rbx+15F0h]
00007FF91DFCC5EE  72 03                       jb      short loc_7FF91DFCC5F3
00007FF91DFCC5F0  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFCC5F3  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFCC5F7  73 06                       jnb     short loc_7FF91DFCC5FF
00007FF91DFCC5F9  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFCC5FD  EB 05                       jmp     short loc_7FF91DFCC604
00007FF91DFCC5FF  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFCC604  F3 0F 11 BB 40 12 00 00     movss   dword ptr [rbx+1240h], xmm7
00007FF91DFCC60C  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFCC611  F3 0F 59 A3 B0 15 00 00     mulss   xmm4, dword ptr [rbx+15B0h]
00007FF91DFCC619  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFCC61C  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFCC621  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFCC625  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCC628  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFCC62D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC631  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCC634  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCC638  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFCC63C  F3 44 0F 59 8B 80 17 00 00  mulss   xmm9, dword ptr [rbx+1780h]
00007FF91DFCC645  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFCC64A  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCC64D  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCC655  F3 44 0F 58 8B 70 17 00 00  addss   xmm9, dword ptr [rbx+1770h]
00007FF91DFCC65E  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCC666  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFCC66B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCC66E  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCC676  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFCC67B  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC67F  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFCC684  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFCC687  0F 54 05 02 91 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFCC68E  0F 57 05 2B 91 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFCC695  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFCC69A  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFCC69F  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFCC6A4  F3 44 0F 11 8B 30 13 00 00  movss   dword ptr [rbx+1330h], xmm9
00007FF91DFCC6AD  E8 0E C9 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCC6B2  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFCC6B6  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFCC6BA  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFCC6BF  73 06                       jnb     short loc_7FF91DFCC6C7
00007FF91DFCC6C1  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFCC6C5  EB 06                       jmp     short loc_7FF91DFCC6CD
00007FF91DFCC6C7  76 04                       jbe     short loc_7FF91DFCC6CD
00007FF91DFCC6C9  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFCC6CD  F3 44 0F 59 83 C0 12 00 00  mulss   xmm8, dword ptr [rbx+12C0h]
00007FF91DFCC6D6  F3 0F 59 BB 30 16 00 00     mulss   xmm7, dword ptr [rbx+1630h]
00007FF91DFCC6DE  F3 44 0F 59 05 B1 E5 61 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFCC6E7  F3 44 0F 59 83 00 16 00 00  mulss   xmm8, dword ptr [rbx+1600h]
00007FF91DFCC6F0  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFCC6F4  73 06                       jnb     short loc_7FF91DFCC6FC
00007FF91DFCC6F6  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFCC6FA  EB 05                       jmp     short loc_7FF91DFCC701
00007FF91DFCC6FC  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFCC701  F3 44 0F 59 83 B0 15 00 00  mulss   xmm8, dword ptr [rbx+15B0h]
00007FF91DFCC70A  F3 44 0F 59 8B 90 12 00 00  mulss   xmm9, dword ptr [rbx+1290h]
00007FF91DFCC713  F3 0F 10 B3 20 12 00 00     movss   xmm6, dword ptr [rbx+1220h]
00007FF91DFCC71B  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFCC71F  F3 0F 10 AB 40 12 00 00     movss   xmm5, dword ptr [rbx+1240h]
00007FF91DFCC727  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFCC72C  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCC72F  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCC732  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC736  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCC739  F3 0F 59 A3 80 17 00 00     mulss   xmm4, dword ptr [rbx+1780h]
00007FF91DFCC741  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCC744  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCC74C  F3 0F 58 A3 70 17 00 00     addss   xmm4, dword ptr [rbx+1770h]
00007FF91DFCC754  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFCC759  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCC761  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC765  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCC768  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCC770  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCC774  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC778  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC77C  F3 0F 10 83 20 13 00 00     movss   xmm0, dword ptr [rbx+1320h]
00007FF91DFCC784  F3 0F 59 83 80 12 00 00     mulss   xmm0, dword ptr [rbx+1280h]
00007FF91DFCC78C  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCC790  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFCC795  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFCC79A  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFCC79E  F3 0F 59 A3 A0 12 00 00     mulss   xmm4, dword ptr [rbx+12A0h]
00007FF91DFCC7A6  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCC7AA  F3 0F 11 A3 50 14 00 00     movss   dword ptr [rbx+1450h], xmm4
00007FF91DFCC7B2  F3 0F 11 B3 30 12 00 00     movss   dword ptr [rbx+1230h], xmm6
00007FF91DFCC7BA  F3 0F 11 AB 40 12 00 00     movss   dword ptr [rbx+1240h], xmm5
00007FF91DFCC7C2  F3 0F 58 B3 B0 12 00 00     addss   xmm6, dword ptr [rbx+12B0h]
00007FF91DFCC7CA  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFCC7CE  76 1B                       jbe     short loc_7FF91DFCC7EB
00007FF91DFCC7D0  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCC7D5  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCC7D9  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCC7DC  E8 F7 2C 38 00              call    fmodf
00007FF91DFCC7E1  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCC7E4  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCC7E9  EB 1F                       jmp     short loc_7FF91DFCC80A
00007FF91DFCC7EB  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFCC7EF  73 19                       jnb     short loc_7FF91DFCC80A
00007FF91DFCC7F1  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFCC7F6  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFCC7FA  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFCC7FD  E8 D6 2C 38 00              call    fmodf
00007FF91DFCC802  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCC805  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFCC80A  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFCC80D  F3 0F 11 B3 20 12 00 00     movss   dword ptr [rbx+1220h], xmm6
00007FF91DFCC815  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCC81A  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFCC81D  F3 0F 59 BB 10 16 00 00     mulss   xmm7, dword ptr [rbx+1610h]
00007FF91DFCC825  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFCC82A  E8 91 C7 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCC82F  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFCC832  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFCC837  F3 0F 59 AB C0 12 00 00     mulss   xmm5, dword ptr [rbx+12C0h]
00007FF91DFCC83F  F3 0F 59 AB E0 15 00 00     mulss   xmm5, dword ptr [rbx+15E0h]
00007FF91DFCC847  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFCC84B  73 06                       jnb     short loc_7FF91DFCC853
00007FF91DFCC84D  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFCC851  EB 05                       jmp     short loc_7FF91DFCC858
00007FF91DFCC853  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFCC858  F3 0F 59 AB B0 15 00 00     mulss   xmm5, dword ptr [rbx+15B0h]
00007FF91DFCC860  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFCC863  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFCC867  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCC86A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCC86D  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCC875  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCC878  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC87C  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCC87F  F3 0F 59 A3 80 17 00 00     mulss   xmm4, dword ptr [rbx+1780h]
00007FF91DFCC887  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCC88F  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFCC893  F3 0F 58 A3 70 17 00 00     addss   xmm4, dword ptr [rbx+1770h]
00007FF91DFCC89B  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC89F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCC8A2  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCC8AA  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCC8AE  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC8B2  F3 0F 10 8B D0 12 00 00     movss   xmm1, dword ptr [rbx+12D0h]
00007FF91DFCC8BA  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCC8BE  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFCC8C1  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFCC8C5  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCC8C9  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFCC8CD  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFCC8D1  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFCC8D5  F3 0F 11 A3 20 13 00 00     movss   dword ptr [rbx+1320h], xmm4
00007FF91DFCC8DD  72 07                       jb      short loc_7FF91DFCC8E6
00007FF91DFCC8DF  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFCC8E4  EB 05                       jmp     short loc_7FF91DFCC8EB
00007FF91DFCC8E6  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFCC8EB  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFCC8EE  73 06                       jnb     short loc_7FF91DFCC8F6
00007FF91DFCC8F0  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFCC8F4  EB 06                       jmp     short loc_7FF91DFCC8FC
00007FF91DFCC8F6  76 04                       jbe     short loc_7FF91DFCC8FC
00007FF91DFCC8F8  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFCC8FC  F3 44 0F 10 83 20 12 00 00  movss   xmm8, dword ptr [rbx+1220h]
00007FF91DFCC905  F3 0F 59 B3 20 16 00 00     mulss   xmm6, dword ptr [rbx+1620h]
00007FF91DFCC90D  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFCC911  E8 AA C6 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCC916  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFCC919  F3 0F 10 83 D0 15 00 00     movss   xmm0, dword ptr [rbx+15D0h]
00007FF91DFCC921  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFCC925  72 18                       jb      short loc_7FF91DFCC93F
00007FF91DFCC927  0F 2F 83 30 12 00 00        comiss  xmm0, dword ptr [rbx+1230h]
00007FF91DFCC92E  76 0F                       jbe     short loc_7FF91DFCC93F
00007FF91DFCC930  F3 0F 10 BB 40 12 00 00     movss   xmm7, dword ptr [rbx+1240h]
00007FF91DFCC938  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFCC93D  EB 08                       jmp     short loc_7FF91DFCC947
00007FF91DFCC93F  F3 0F 10 BB 40 12 00 00     movss   xmm7, dword ptr [rbx+1240h]
00007FF91DFCC947  0F 2F 3D 82 89 77 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFCC94E  F3 0F 59 A3 C0 12 00 00     mulss   xmm4, dword ptr [rbx+12C0h]
00007FF91DFCC956  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFCC95B  F3 0F 59 A3 F0 15 00 00     mulss   xmm4, dword ptr [rbx+15F0h]
00007FF91DFCC963  72 03                       jb      short loc_7FF91DFCC968
00007FF91DFCC965  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFCC968  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFCC96C  73 06                       jnb     short loc_7FF91DFCC974
00007FF91DFCC96E  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFCC972  EB 05                       jmp     short loc_7FF91DFCC979
00007FF91DFCC974  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFCC979  F3 0F 11 BB 40 12 00 00     movss   dword ptr [rbx+1240h], xmm7
00007FF91DFCC981  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFCC986  F3 0F 59 A3 B0 15 00 00     mulss   xmm4, dword ptr [rbx+15B0h]
00007FF91DFCC98E  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFCC991  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFCC996  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFCC99A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCC99D  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFCC9A2  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC9A6  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCC9A9  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFCC9AD  44 0F 28 C2                 movaps  xmm8, xmm2
00007FF91DFCC9B1  F3 44 0F 59 83 80 17 00 00  mulss   xmm8, dword ptr [rbx+1780h]
00007FF91DFCC9BA  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFCC9BF  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCC9C2  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCC9CA  F3 44 0F 58 83 70 17 00 00  addss   xmm8, dword ptr [rbx+1770h]
00007FF91DFCC9D3  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCC9DB  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFCC9E0  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCC9E3  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCC9EB  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFCC9F0  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCC9F4  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFCC9F9  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFCC9FC  0F 54 05 8D 8D 77 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFCCA03  0F 57 05 B6 8D 77 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFCCA0A  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFCCA0F  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFCCA14  F3 44 0F 59 C6              mulss   xmm8, xmm6
00007FF91DFCCA19  F3 44 0F 11 83 30 13 00 00  movss   dword ptr [rbx+1330h], xmm8
00007FF91DFCCA22  E8 99 C5 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFCCA27  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFCCA2B  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFCCA30  73 06                       jnb     short loc_7FF91DFCCA38
00007FF91DFCCA32  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFCCA36  EB 06                       jmp     short loc_7FF91DFCCA3E
00007FF91DFCCA38  76 04                       jbe     short loc_7FF91DFCCA3E
00007FF91DFCCA3A  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFCCA3E  F3 0F 59 83 C0 12 00 00     mulss   xmm0, dword ptr [rbx+12C0h]
00007FF91DFCCA46  F3 0F 59 BB 30 16 00 00     mulss   xmm7, dword ptr [rbx+1630h]
00007FF91DFCCA4E  F3 0F 59 05 42 E2 61 00     mulss   xmm0, cs:dword_7FF91E5EAC98
00007FF91DFCCA56  F3 0F 59 83 00 16 00 00     mulss   xmm0, dword ptr [rbx+1600h]
00007FF91DFCCA5E  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFCCA62  72 09                       jb      short loc_7FF91DFCCA6D
00007FF91DFCCA64  44 0F 28 F8                 movaps  xmm15, xmm0
00007FF91DFCCA68  F3 45 0F 5D FD              minss   xmm15, xmm13
00007FF91DFCCA6D  F3 44 0F 59 BB B0 15 00 00  mulss   xmm15, dword ptr [rbx+15B0h]
00007FF91DFCCA76  F3 44 0F 59 83 90 12 00 00  mulss   xmm8, dword ptr [rbx+1290h]
00007FF91DFCCA7F  F3 0F 10 AB 20 12 00 00     movss   xmm5, dword ptr [rbx+1220h]
00007FF91DFCCA87  41 0F 28 D7                 movaps  xmm2, xmm15
00007FF91DFCCA8B  F3 0F 10 B3 40 12 00 00     movss   xmm6, dword ptr [rbx+1240h]
00007FF91DFCCA93  F3 41 0F 59 D7              mulss   xmm2, xmm15
00007FF91DFCCA98  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFCCA9B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCCA9E  F3 0F 59 8B 60 17 00 00     mulss   xmm1, dword ptr [rbx+1760h]
00007FF91DFCCAA6  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFCCAA9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCCAAD  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCCAB0  F3 0F 58 8B 50 17 00 00     addss   xmm1, dword ptr [rbx+1750h]
00007FF91DFCCAB8  F3 0F 59 A3 80 17 00 00     mulss   xmm4, dword ptr [rbx+1780h]
00007FF91DFCCAC0  F3 41 0F 59 DF              mulss   xmm3, xmm15
00007FF91DFCCAC5  F3 0F 58 A3 70 17 00 00     addss   xmm4, dword ptr [rbx+1770h]
00007FF91DFCCACD  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCCAD1  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCCAD4  F3 0F 59 9B 40 17 00 00     mulss   xmm3, dword ptr [rbx+1740h]
00007FF91DFCCADC  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFCCAE0  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFCCAE4  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFCCAE8  F3 0F 10 83 20 13 00 00     movss   xmm0, dword ptr [rbx+1320h]
00007FF91DFCCAF0  F3 0F 59 83 80 12 00 00     mulss   xmm0, dword ptr [rbx+1280h]
00007FF91DFCCAF8  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFCCAFC  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFCCB01  F3 41 0F 58 E7              addss   xmm4, xmm15
00007FF91DFCCB06  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFCCB0A  F3 0F 59 A3 A0 12 00 00     mulss   xmm4, dword ptr [rbx+12A0h]
00007FF91DFCCB12  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFCCB16  F3 0F 11 A3 D0 14 00 00     movss   dword ptr [rbx+14D0h], xmm4
00007FF91DFCCB1E  F3 0F 10 93 40 15 00 00     movss   xmm2, dword ptr [rbx+1540h]
00007FF91DFCCB26  F3 0F 11 AB 00 13 00 00     movss   dword ptr [rbx+1300h], xmm5
00007FF91DFCCB2E  F3 0F 11 B3 E0 12 00 00     movss   dword ptr [rbx+12E0h], xmm6
00007FF91DFCCB36  F3 0F 10 83 50 14 00 00     movss   xmm0, dword ptr [rbx+1450h]
00007FF91DFCCB3E  F3 0F 58 83 40 14 00 00     addss   xmm0, dword ptr [rbx+1440h]
00007FF91DFCCB46  F3 0F 10 8B D0 14 00 00     movss   xmm1, dword ptr [rbx+14D0h]
00007FF91DFCCB4E  F3 0F 58 8B C0 13 00 00     addss   xmm1, dword ptr [rbx+13C0h]
00007FF91DFCCB56  F3 0F 10 AB C0 14 00 00     movss   xmm5, dword ptr [rbx+14C0h]
00007FF91DFCCB5E  F3 0F 58 AB D0 13 00 00     addss   xmm5, dword ptr [rbx+13D0h]
00007FF91DFCCB66  F3 0F 59 83 60 16 00 00     mulss   xmm0, dword ptr [rbx+1660h]
00007FF91DFCCB6E  F3 0F 59 8B 70 16 00 00     mulss   xmm1, dword ptr [rbx+1670h]
00007FF91DFCCB76  F3 0F 59 AB 50 16 00 00     mulss   xmm5, dword ptr [rbx+1650h]
00007FF91DFCCB7E  F3 0F 58 93 50 13 00 00     addss   xmm2, dword ptr [rbx+1350h]
00007FF91DFCCB86  F3 0F 59 93 40 16 00 00     mulss   xmm2, dword ptr [rbx+1640h]
00007FF91DFCCB8E  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFCCB92  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCCB96  F3 0F 10 83 30 15 00 00     movss   xmm0, dword ptr [rbx+1530h]
00007FF91DFCCB9E  F3 0F 58 83 60 13 00 00     addss   xmm0, dword ptr [rbx+1360h]
00007FF91DFCCBA6  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCCBAA  F3 0F 10 8B B0 14 00 00     movss   xmm1, dword ptr [rbx+14B0h]
00007FF91DFCCBB2  F3 0F 59 83 80 16 00 00     mulss   xmm0, dword ptr [rbx+1680h]
00007FF91DFCCBBA  F3 0F 58 8B E0 13 00 00     addss   xmm1, dword ptr [rbx+13E0h]
00007FF91DFCCBC2  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCCBC6  F3 0F 10 83 60 14 00 00     movss   xmm0, dword ptr [rbx+1460h]
00007FF91DFCCBCE  F3 0F 58 83 30 14 00 00     addss   xmm0, dword ptr [rbx+1430h]
00007FF91DFCCBD6  F3 0F 59 8B 90 16 00 00     mulss   xmm1, dword ptr [rbx+1690h]
00007FF91DFCCBDE  F3 0F 59 83 A0 16 00 00     mulss   xmm0, dword ptr [rbx+16A0h]
00007FF91DFCCBE6  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCCBEA  F3 0F 10 8B E0 14 00 00     movss   xmm1, dword ptr [rbx+14E0h]
00007FF91DFCCBF2  F3 0F 58 8B B0 13 00 00     addss   xmm1, dword ptr [rbx+13B0h]
00007FF91DFCCBFA  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCCBFE  F3 0F 10 83 20 15 00 00     movss   xmm0, dword ptr [rbx+1520h]
00007FF91DFCCC06  F3 0F 59 8B B0 16 00 00     mulss   xmm1, dword ptr [rbx+16B0h]
00007FF91DFCCC0E  F3 0F 58 83 70 13 00 00     addss   xmm0, dword ptr [rbx+1370h]
00007FF91DFCCC16  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCCC1A  F3 0F 10 8B F0 13 00 00     movss   xmm1, dword ptr [rbx+13F0h]
00007FF91DFCCC22  F3 0F 58 8B A0 14 00 00     addss   xmm1, dword ptr [rbx+14A0h]
00007FF91DFCCC2A  F3 0F 59 83 C0 16 00 00     mulss   xmm0, dword ptr [rbx+16C0h]
00007FF91DFCCC32  F3 0F 59 8B D0 16 00 00     mulss   xmm1, dword ptr [rbx+16D0h]
00007FF91DFCCC3A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCCC3E  F3 0F 10 83 70 14 00 00     movss   xmm0, dword ptr [rbx+1470h]
00007FF91DFCCC46  F3 0F 58 83 20 14 00 00     addss   xmm0, dword ptr [rbx+1420h]
00007FF91DFCCC4E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCCC52  F3 0F 10 8B A0 13 00 00     movss   xmm1, dword ptr [rbx+13A0h]
00007FF91DFCCC5A  F3 0F 59 83 E0 16 00 00     mulss   xmm0, dword ptr [rbx+16E0h]
00007FF91DFCCC62  F3 0F 58 8B F0 14 00 00     addss   xmm1, dword ptr [rbx+14F0h]
00007FF91DFCCC6A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCCC6E  F3 0F 10 83 10 15 00 00     movss   xmm0, dword ptr [rbx+1510h]
00007FF91DFCCC76  F3 0F 59 8B F0 16 00 00     mulss   xmm1, dword ptr [rbx+16F0h]
00007FF91DFCCC7E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCCC82  F3 0F 58 83 80 13 00 00     addss   xmm0, dword ptr [rbx+1380h]
00007FF91DFCCC8A  F3 0F 10 93 70 15 00 00     movss   xmm2, dword ptr [rbx+1570h]
00007FF91DFCCC92  F3 0F 10 8B 90 14 00 00     movss   xmm1, dword ptr [rbx+1490h]
00007FF91DFCCC9A  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFCCC9D  F3 0F 59 A3 70 18 00 00     mulss   xmm4, dword ptr [rbx+1870h]
00007FF91DFCCCA5  F3 0F 59 83 00 17 00 00     mulss   xmm0, dword ptr [rbx+1700h]
00007FF91DFCCCAD  F3 0F 58 A3 80 15 00 00     addss   xmm4, dword ptr [rbx+1580h]
00007FF91DFCCCB5  F3 0F 58 8B 00 14 00 00     addss   xmm1, dword ptr [rbx+1400h]
00007FF91DFCCCBD  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCCCC1  F3 0F 10 83 80 14 00 00     movss   xmm0, dword ptr [rbx+1480h]
00007FF91DFCCCC9  F3 0F 58 83 10 14 00 00     addss   xmm0, dword ptr [rbx+1410h]
00007FF91DFCCCD1  F3 0F 59 8B 10 17 00 00     mulss   xmm1, dword ptr [rbx+1710h]
00007FF91DFCCCD9  F3 0F 59 83 20 17 00 00     mulss   xmm0, dword ptr [rbx+1720h]
00007FF91DFCCCE1  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCCCE5  F3 0F 10 8B 00 15 00 00     movss   xmm1, dword ptr [rbx+1500h]
00007FF91DFCCCED  F3 0F 58 8B 90 13 00 00     addss   xmm1, dword ptr [rbx+1390h]
00007FF91DFCCCF5  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFCCCF9  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFCCCFC  F3 0F 59 8B 30 17 00 00     mulss   xmm1, dword ptr [rbx+1730h]
00007FF91DFCCD04  F3 0F 11 A3 70 15 00 00     movss   dword ptr [rbx+1570h], xmm4
00007FF91DFCCD0C  F3 0F 59 83 80 18 00 00     mulss   xmm0, dword ptr [rbx+1880h]
00007FF91DFCCD14  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFCCD18  F3 0F 58 C4                 addss   xmm0, xmm4
00007FF91DFCCD1C  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFCCD1F  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFCCD23  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFCCD26  F3 0F 59 83 70 18 00 00     mulss   xmm0, dword ptr [rbx+1870h]
00007FF91DFCCD2E  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFCCD32  F3 0F 11 83 60 15 00 00     movss   dword ptr [rbx+1560h], xmm0
00007FF91DFCCD3A  F3 0F 10 93 C0 18 00 00     movss   xmm2, dword ptr [rbx+18C0h]
00007FF91DFCCD42  F3 0F 59 9B 50 15 00 00     mulss   xmm3, dword ptr [rbx+1550h]
00007FF91DFCCD4A  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFCCD4E  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFCCD52  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFCCD56  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFCCD5A  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFCCD5E  F3 0F 11 A3 40 13 00 00     movss   dword ptr [rbx+1340h], xmm4
00007FF91DFCCD66  F3 0F 11 A3 C0 0D 00 00     movss   dword ptr [rbx+0DC0h], xmm4
00007FF91DFCCD6E  44 0F 2E AB 80 8C 01 00     ucomiss xmm13, dword ptr [rbx+18C80h]
00007FF91DFCCD76  75 28                       jnz     short loc_7FF91DFCCDA0
00007FF91DFCCD78  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
00007FF91DFCCD81  F3 0F 11 83 40 01 00 00     movss   dword ptr [rbx+140h], xmm0
00007FF91DFCCD89  C7 83 80 8C 01 00 00 00 00 00  mov     dword ptr [rbx+18C80h], 0
00007FF91DFCCD93  0F 1F 40 00                 nop     dword ptr [rax+00h]
00007FF91DFCCD97  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00007FF91DFCCDA0  8B 83 B0 29 00 00           mov     eax, [rbx+29B0h]
00007FF91DFCCDA6  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
00007FF91DFCCDAE  48 8B 0F                    mov     rcx, [rdi]
00007FF91DFCCDB1  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
00007FF91DFCCDB6  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
00007FF91DFCCDBB  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
00007FF91DFCCDC0  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
00007FF91DFCCDC5  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
00007FF91DFCCDCA  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
00007FF91DFCCDCF  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
00007FF91DFCCDD4  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
00007FF91DFCCDD9  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
00007FF91DFCCDDF  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
00007FF91DFCCDE5  89 01                       mov     [rcx], eax
00007FF91DFCCDE7  8B 83 B0 29 00 00           mov     eax, [rbx+29B0h]
00007FF91DFCCDED  48 8B 4F 08                 mov     rcx, [rdi+8]
00007FF91DFCCDF1  49 8B 5B 18                 mov     rbx, [r11+18h]
00007FF91DFCCDF5  89 01                       mov     [rcx], eax
00007FF91DFCCDF7  49 8B E3                    mov     rsp, r11
00007FF91DFCCDFA  5F                          pop     rdi
00007FF91DFCCDFB  C3                          retn
