; sub_180380190 @ 0x180380190 (RVA 0x380190) size=0x3D8C

0000000180380190  48 8B C4                    mov     rax, rsp
0000000180380193  48 89 58 10                 mov     [rax+10h], rbx
0000000180380197  57                          push    rdi
0000000180380198  48 81 EC C0 00 00 00        sub     rsp, 0C0h
000000018038019F  F3 0F 10 A1 A0 F7 00 00     movss   xmm4, dword ptr [rcx+0F7A0h]
00000001803801A7  48 8B FA                    mov     rdi, rdx
00000001803801AA  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
00000001803801AE  48 8B D9                    mov     rbx, rcx
00000001803801B1  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
00000001803801B5  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00000001803801BA  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00000001803801BF  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00000001803801C4  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00000001803801C9  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00000001803801CE  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00000001803801D4  F3 44 0F 10 2D D7 4E 76 00  movss   xmm13, cs:dword_180AE50B4
00000001803801DD  44 0F 2E A9 40 8D 01 00     ucomiss xmm13, dword ptr [rcx+18D40h]
00000001803801E5  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00000001803801EB  45 0F 57 F6                 xorps   xmm14, xmm14
00000001803801EF  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
00000001803801F9  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00000001803801FF  75 16                       jnz     short loc_180380217
0000000180380201  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
000000018038020A  0F 57 E4                    xorps   xmm4, xmm4
000000018038020D  C7 81 A0 F7 00 00 00 00 00 00  mov     dword ptr [rcx+0F7A0h], 0
0000000180380217  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
000000018038021F  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
0000000180380227  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
000000018038022F  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
0000000180380237  F3 0F 59 05 85 AB 60 00     mulss   xmm0, cs:dword_18098ADC4
000000018038023F  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
0000000180380247  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
000000018038024F  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180380253  85 D2                       test    edx, edx
0000000180380255  75 07                       jnz     short loc_18038025E
0000000180380257  BA 01 00 00 00              mov     edx, 1
000000018038025C  EB 24                       jmp     short loc_180380282
000000018038025E  8B C2                       mov     eax, edx
0000000180380260  25 00 00 20 00              and     eax, 200000h
0000000180380265  0F BA E2 17                 bt      edx, 17h
0000000180380269  73 08                       jnb     short loc_180380273
000000018038026B  85 C0                       test    eax, eax
000000018038026D  75 0C                       jnz     short loc_18038027B
000000018038026F  03 D2                       add     edx, edx
0000000180380271  EB 0F                       jmp     short loc_180380282
0000000180380273  85 C0                       test    eax, eax
0000000180380275  74 04                       jz      short loc_18038027B
0000000180380277  03 D2                       add     edx, edx
0000000180380279  EB 07                       jmp     short loc_180380282
000000018038027B  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
0000000180380282  F3 0F 10 9B 30 F7 00 00     movss   xmm3, dword ptr [rbx+0F730h]
000000018038028A  8B C2                       mov     eax, edx
000000018038028C  F3 0F 10 B3 10 F7 00 00     movss   xmm6, dword ptr [rbx+0F710h]
0000000180380294  25 FF FF FF 00              and     eax, 0FFFFFFh
0000000180380299  F3 44 0F 10 83 D0 F7 00 00  movss   xmm8, dword ptr [rbx+0F7D0h]
00000001803802A2  8B CA                       mov     ecx, edx
00000001803802A4  F3 0F 10 BB E0 F7 00 00     movss   xmm7, dword ptr [rbx+0F7E0h]
00000001803802AC  81 CA 00 00 00 FF           or      edx, 0FF000000h
00000001803802B2  F3 0F 59 CA                 mulss   xmm1, xmm2
00000001803802B6  81 E1 00 00 00 01           and     ecx, 1000000h
00000001803802BC  C7 83 10 F8 00 00 00 00 00 00  mov     dword ptr [rbx+0F810h], 0
00000001803802C6  F3 0F 11 9B 40 F7 00 00     movss   dword ptr [rbx+0F740h], xmm3
00000001803802CE  45 0F 57 D2                 xorps   xmm10, xmm10
00000001803802D2  0F 44 D0                    cmovz   edx, eax
00000001803802D5  F3 0F 11 B3 20 F7 00 00     movss   dword ptr [rbx+0F720h], xmm6
00000001803802DD  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
00000001803802E3  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
00000001803802E9  8B 83 50 F8 00 00           mov     eax, [rbx+0F850h]
00000001803802EF  66 0F 6E C2                 movd    xmm0, edx
00000001803802F3  0F 5B C0                    cvtdq2ps xmm0, xmm0
00000001803802F6  89 83 60 F8 00 00           mov     [rbx+0F860h], eax
00000001803802FC  F3 0F 11 A3 C0 F7 00 00     movss   dword ptr [rbx+0F7C0h], xmm4
0000000180380304  F3 0F 59 05 64 A9 60 00     mulss   xmm0, cs:dword_18098AC70
000000018038030C  F3 44 0F 11 83 F0 F7 00 00  movss   dword ptr [rbx+0F7F0h], xmm8
0000000180380315  F3 0F 11 BB 00 F8 00 00     movss   dword ptr [rbx+0F800h], xmm7
000000018038031D  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
0000000180380325  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
000000018038032D  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
0000000180380335  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180380339  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
0000000180380341  F3 0F 5C CA                 subss   xmm1, xmm2
0000000180380345  F3 0F 10 93 70 F7 00 00     movss   xmm2, dword ptr [rbx+0F770h]
000000018038034D  F3 0F 11 93 80 F7 00 00     movss   dword ptr [rbx+0F780h], xmm2
0000000180380355  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180380359  F3 0F 10 83 50 F7 00 00     movss   xmm0, dword ptr [rbx+0F750h]
0000000180380361  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180380365  F3 0F 11 83 60 F7 00 00     movss   dword ptr [rbx+0F760h], xmm0
000000018038036D  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180380371  0F 28 C2                    movaps  xmm0, xmm2
0000000180380374  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
000000018038037C  F3 0F 10 8B 90 F7 00 00     movss   xmm1, dword ptr [rbx+0F790h]
0000000180380384  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180380388  F3 0F 59 F2                 mulss   xmm6, xmm2
000000018038038C  F3 0F 11 8B B0 F7 00 00     movss   dword ptr [rbx+0F7B0h], xmm1
0000000180380394  F3 0F 11 93 20 F8 00 00     movss   dword ptr [rbx+0F820h], xmm2
000000018038039C  F3 0F 5C F0                 subss   xmm6, xmm0
00000001803803A0  0F 28 C4                    movaps  xmm0, xmm4
00000001803803A3  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803803A7  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803803AB  F3 0F 58 F1                 addss   xmm6, xmm1
00000001803803AF  F3 0F 58 DC                 addss   xmm3, xmm4
00000001803803B3  F3 0F 11 B3 30 F8 00 00     movss   dword ptr [rbx+0F830h], xmm6
00000001803803BB  F3 0F 11 9B 40 F8 00 00     movss   dword ptr [rbx+0F840h], xmm3
00000001803803C3  0F 28 CB                    movaps  xmm1, xmm3
00000001803803C6  F3 0F 58 9B 80 F8 00 00     addss   xmm3, dword ptr [rbx+0F880h]
00000001803803CE  41 0F 2F DE                 comiss  xmm3, xmm14
00000001803803D2  72 05                       jb      short loc_1803803D9
00000001803803D4  0F 57 C0                    xorps   xmm0, xmm0
00000001803803D7  EB 03                       jmp     short loc_1803803DC
00000001803803D9  0F 5A C3                    cvtps2pd xmm0, xmm3
00000001803803DC  41 0F 2E CE                 ucomiss xmm1, xmm14
00000001803803E0  F3 44 0F 10 3D FB 50 76 00  movss   xmm15, cs:dword_180AE54E4
00000001803803E9  75 06                       jnz     short loc_1803803F1
00000001803803EB  41 0F 28 EF                 movaps  xmm5, xmm15
00000001803803EF  EB 04                       jmp     short loc_1803803F5
00000001803803F1  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00000001803803F5  41 0F 2F EE                 comiss  xmm5, xmm14
00000001803803F9  F3 0F 11 AB 50 F8 00 00     movss   dword ptr [rbx+0F850h], xmm5
0000000180380401  73 06                       jnb     short loc_180380409
0000000180380403  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180380407  EB 06                       jmp     short loc_18038040F
0000000180380409  76 04                       jbe     short loc_18038040F
000000018038040B  41 0F 28 ED                 movaps  xmm5, xmm13
000000018038040F  F3 0F 10 83 C0 F8 00 00     movss   xmm0, dword ptr [rbx+0F8C0h]
0000000180380417  F3 41 0F 58 ED              addss   xmm5, xmm13
000000018038041C  F3 0F 10 93 60 F9 00 00     movss   xmm2, dword ptr [rbx+0F960h]
0000000180380424  F3 0F 10 8B D0 F8 00 00     movss   xmm1, dword ptr [rbx+0F8D0h]
000000018038042C  8B 83 90 F8 00 00           mov     eax, [rbx+0F890h]
0000000180380432  0F 28 D9                    movaps  xmm3, xmm1
0000000180380435  F3 0F 10 A3 20 F9 00 00     movss   xmm4, dword ptr [rbx+0F920h]
000000018038043D  F3 0F 58 9B 70 F9 00 00     addss   xmm3, dword ptr [rbx+0F970h]
0000000180380445  F2 44 0F 10 25 52 4D 76 00  movsd   xmm12, cs:dbl_180AE51A0
000000018038044E  F3 0F 11 AB 70 F8 00 00     movss   dword ptr [rbx+0F870h], xmm5
0000000180380456  F3 0F 11 AB 90 F8 00 00     movss   dword ptr [rbx+0F890h], xmm5
000000018038045E  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180380462  89 83 A0 F8 00 00           mov     [rbx+0F8A0h], eax
0000000180380468  F3 0F 11 A3 30 F9 00 00     movss   dword ptr [rbx+0F930h], xmm4
0000000180380470  F3 0F 5C E8                 subss   xmm5, xmm0
0000000180380474  0F 28 C2                    movaps  xmm0, xmm2
0000000180380477  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018038047B  F3 0F 10 8B 00 F9 00 00     movss   xmm1, dword ptr [rbx+0F900h]
0000000180380483  F3 0F 58 83 80 F9 00 00     addss   xmm0, dword ptr [rbx+0F980h]
000000018038048B  F3 41 0F 58 ED              addss   xmm5, xmm13
0000000180380490  F3 0F 5E C8                 divss   xmm1, xmm0
0000000180380494  F3 0F 10 83 90 F9 00 00     movss   xmm0, dword ptr [rbx+0F990h]
000000018038049C  F3 0F 59 AB B0 F8 00 00     mulss   xmm5, dword ptr [rbx+0F8B0h]
00000001803804A4  F3 0F 59 CA                 mulss   xmm1, xmm2
00000001803804A8  F3 0F 10 93 F0 F8 00 00     movss   xmm2, dword ptr [rbx+0F8F0h]
00000001803804B0  F3 0F 11 AB 40 F9 00 00     movss   dword ptr [rbx+0F940h], xmm5
00000001803804B8  F3 0F 5C D1                 subss   xmm2, xmm1
00000001803804BC  F3 0F 10 8B 10 F9 00 00     movss   xmm1, dword ptr [rbx+0F910h]
00000001803804C4  F3 0F 58 D6                 addss   xmm2, xmm6
00000001803804C8  F3 0F 5C D4                 subss   xmm2, xmm4
00000001803804CC  F3 0F 11 93 F0 F8 00 00     movss   dword ptr [rbx+0F8F0h], xmm2
00000001803804D4  F3 0F 59 D3                 mulss   xmm2, xmm3
00000001803804D8  F3 0F 11 93 00 F9 00 00     movss   dword ptr [rbx+0F900h], xmm2
00000001803804E0  F3 0F 58 D4                 addss   xmm2, xmm4
00000001803804E4  F3 0F 5C E6                 subss   xmm4, xmm6
00000001803804E8  0F 54 25 A1 52 76 00        andps   xmm4, cs:xmmword_180AE5790
00000001803804EF  F3 0F 5C C4                 subss   xmm0, xmm4
00000001803804F3  41 0F 2F C6                 comiss  xmm0, xmm14
00000001803804F7  0F 83 E8 00 00 00           jnb     loc_1803805E5
00000001803804FD  0F 57 C9                    xorps   xmm1, xmm1
0000000180380500  0F 5A C1                    cvtps2pd xmm0, xmm1
0000000180380503  41 0F 2E EE                 ucomiss xmm5, xmm14
0000000180380507  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018038050B  0F 28 C8                    movaps  xmm1, xmm0
000000018038050E  F3 0F 11 83 10 F9 00 00     movss   dword ptr [rbx+0F910h], xmm0
0000000180380516  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018038051A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038051E  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180380522  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180380526  75 03                       jnz     short loc_18038052B
0000000180380528  0F 28 CE                    movaps  xmm1, xmm6
000000018038052B  8B 83 D0 F9 00 00           mov     eax, [rbx+0F9D0h]
0000000180380531  48 8D 0D C8 FA C7 FF        lea     rcx, cs:180000000h
0000000180380538  F3 0F 59 BB C0 F9 00 00     mulss   xmm7, dword ptr [rbx+0F9C0h]
0000000180380540  89 83 E0 F9 00 00           mov     [rbx+0F9E0h], eax
0000000180380546  F3 44 0F 59 83 B0 F9 00 00  mulss   xmm8, dword ptr [rbx+0F9B0h]
000000018038054F  F3 0F 10 83 F0 FA 00 00     movss   xmm0, dword ptr [rbx+0FAF0h]
0000000180380557  F3 0F 10 93 F0 F9 00 00     movss   xmm2, dword ptr [rbx+0F9F0h]
000000018038055F  F3 44 0F 10 8B 50 FA 00 00  movss   xmm9, dword ptr [rbx+0FA50h]
0000000180380568  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018038056D  F3 44 0F 10 83 30 FA 00 00  movss   xmm8, dword ptr [rbx+0FA30h]
0000000180380576  F3 0F 2C C0                 cvttss2si eax, xmm0
000000018038057A  F3 0F 11 BB D0 F9 00 00     movss   dword ptr [rbx+0F9D0h], xmm7
0000000180380582  F3 0F 10 BB 10 FA 00 00     movss   xmm7, dword ptr [rbx+0FA10h]
000000018038058A  F3 0F 11 8B 20 F9 00 00     movss   dword ptr [rbx+0F920h], xmm1
0000000180380592  F3 0F 11 8B 50 F9 00 00     movss   dword ptr [rbx+0F950h], xmm1
000000018038059A  F3 0F 10 8B B0 FA 00 00     movss   xmm1, dword ptr [rbx+0FAB0h]
00000001803805A2  F3 0F 11 BB 20 FA 00 00     movss   dword ptr [rbx+0FA20h], xmm7
00000001803805AA  F3 0F 11 93 00 FA 00 00     movss   dword ptr [rbx+0FA00h], xmm2
00000001803805B2  F3 44 0F 11 83 40 FA 00 00  movss   dword ptr [rbx+0FA40h], xmm8
00000001803805BB  F3 44 0F 11 8B 60 FA 00 00  movss   dword ptr [rbx+0FA60h], xmm9
00000001803805C4  F3 0F 11 8B C0 FA 00 00     movss   dword ptr [rbx+0FAC0h], xmm1
00000001803805CC  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00000001803805CF  7D 2F                       jge     short loc_180380600
00000001803805D1  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00000001803805D6  F7 D0                       not     eax
00000001803805D8  48 98                       cdqe
00000001803805DA  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
00000001803805E3  EB 47                       jmp     short loc_18038062C
00000001803805E5  F3 0F 58 8B A0 F9 00 00     addss   xmm1, dword ptr [rbx+0F9A0h]
00000001803805ED  41 0F 2F CD                 comiss  xmm1, xmm13
00000001803805F1  0F 82 09 FF FF FF           jb      loc_180380500
00000001803805F7  41 0F 28 C4                 movaps  xmm0, xmm12
00000001803805FB  E9 03 FF FF FF              jmp     loc_180380503
0000000180380600  83 F8 20                    cmp     eax, 20h ; ' '
0000000180380603  7E 07                       jle     short loc_18038060C
0000000180380605  B8 20 00 00 00              mov     eax, 20h ; ' '
000000018038060A  EB 15                       jmp     short loc_180380621
000000018038060C  85 C0                       test    eax, eax
000000018038060E  79 0F                       jns     short loc_18038061F
0000000180380610  F7 D0                       not     eax
0000000180380612  48 98                       cdqe
0000000180380614  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018038061D  EB 0D                       jmp     short loc_18038062C
000000018038061F  7E 0B                       jle     short loc_18038062C
0000000180380621  48 98                       cdqe
0000000180380623  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
000000018038062C  0F 57 05 8D 51 76 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180380633  F3 0F 2C C0                 cvttss2si eax, xmm0
0000000180380637  83 F8 E0                    cmp     eax, 0FFFFFFE0h
000000018038063A  7D 14                       jge     short loc_180380650
000000018038063C  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
0000000180380641  F7 D0                       not     eax
0000000180380643  48 98                       cdqe
0000000180380645  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018038064E  EB 2C                       jmp     short loc_18038067C
0000000180380650  83 F8 20                    cmp     eax, 20h ; ' '
0000000180380653  7E 07                       jle     short loc_18038065C
0000000180380655  B8 20 00 00 00              mov     eax, 20h ; ' '
000000018038065A  EB 15                       jmp     short loc_180380671
000000018038065C  85 C0                       test    eax, eax
000000018038065E  79 0F                       jns     short loc_18038066F
0000000180380660  F7 D0                       not     eax
0000000180380662  48 98                       cdqe
0000000180380664  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018038066D  EB 0D                       jmp     short loc_18038067C
000000018038066F  7E 0B                       jle     short loc_18038067C
0000000180380671  48 98                       cdqe
0000000180380673  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
000000018038067C  F3 0F 10 83 70 FA 00 00     movss   xmm0, dword ptr [rbx+0FA70h]
0000000180380684  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180380688  F3 0F 59 93 E0 FA 00 00     mulss   xmm2, dword ptr [rbx+0FAE0h]
0000000180380690  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180380694  F3 0F 10 8B A0 FA 00 00     movss   xmm1, dword ptr [rbx+0FAA0h]
000000018038069C  F3 0F 11 93 B0 FA 00 00     movss   dword ptr [rbx+0FAB0h], xmm2
00000001803806A4  F3 0F 59 D0                 mulss   xmm2, xmm0
00000001803806A8  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803806AC  F3 0F 5C D0                 subss   xmm2, xmm0
00000001803806B0  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803806B4  41 0F 2F D6                 comiss  xmm2, xmm14
00000001803806B8  76 05                       jbe     short loc_1803806BF
00000001803806BA  0F 5A C2                    cvtps2pd xmm0, xmm2
00000001803806BD  EB 03                       jmp     short loc_1803806C2
00000001803806BF  0F 57 C0                    xorps   xmm0, xmm0
00000001803806C2  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00000001803806C6  41 0F 2F CD                 comiss  xmm1, xmm13
00000001803806CA  72 06                       jb      short loc_1803806D2
00000001803806CC  41 0F 28 C4                 movaps  xmm0, xmm12
00000001803806D0  EB 03                       jmp     short loc_1803806D5
00000001803806D2  0F 5A C1                    cvtps2pd xmm0, xmm1
00000001803806D5  F3 0F 10 B3 80 FA 00 00     movss   xmm6, dword ptr [rbx+0FA80h]
00000001803806DD  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00000001803806E1  F3 0F 59 83 10 FB 00 00     mulss   xmm0, dword ptr [rbx+0FB10h]; X
00000001803806E9  E8 52 F0 36 00              call    expf
00000001803806EE  F3 0F 59 83 00 FB 00 00     mulss   xmm0, dword ptr [rbx+0FB00h]
00000001803806F6  0F 28 CE                    movaps  xmm1, xmm6
00000001803806F9  8B 83 80 FC 00 00           mov     eax, [rbx+0FC80h]
00000001803806FF  F3 0F 59 8B 90 FA 00 00     mulss   xmm1, dword ptr [rbx+0FA90h]
0000000180380707  89 83 90 FC 00 00           mov     [rbx+0FC90h], eax
000000018038070D  F3 0F 58 83 20 FB 00 00     addss   xmm0, dword ptr [rbx+0FB20h]
0000000180380715  8B 83 A0 FC 00 00           mov     eax, [rbx+0FCA0h]
000000018038071B  F3 0F 10 9B 40 FC 00 00     movss   xmm3, dword ptr [rbx+0FC40h]
0000000180380723  F3 0F 59 BB D0 FD 00 00     mulss   xmm7, dword ptr [rbx+0FDD0h]
000000018038072B  89 83 B0 FC 00 00           mov     [rbx+0FCB0h], eax
0000000180380731  8B 83 C0 FC 00 00           mov     eax, [rbx+0FCC0h]
0000000180380737  F3 0F 10 93 30 FC 00 00     movss   xmm2, dword ptr [rbx+0FC30h]
000000018038073F  F3 0F 10 A3 60 FC 00 00     movss   xmm4, dword ptr [rbx+0FC60h]
0000000180380747  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018038074B  89 83 D0 FC 00 00           mov     [rbx+0FCD0h], eax
0000000180380751  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
0000000180380757  F3 0F 11 9B 50 FC 00 00     movss   dword ptr [rbx+0FC50h], xmm3
000000018038075F  F3 0F 5C CE                 subss   xmm1, xmm6
0000000180380763  F3 0F 11 93 40 FC 00 00     movss   dword ptr [rbx+0FC40h], xmm2
000000018038076B  F3 0F 11 A3 70 FC 00 00     movss   dword ptr [rbx+0FC70h], xmm4
0000000180380773  F3 44 0F 11 83 00 FC 00 00  movss   dword ptr [rbx+0FC00h], xmm8
000000018038077C  F3 44 0F 11 8B 10 FC 00 00  movss   dword ptr [rbx+0FC10h], xmm9
0000000180380785  89 83 F0 FB 00 00           mov     [rbx+0FBF0h], eax
000000018038078B  F3 0F 58 C8                 addss   xmm1, xmm0
000000018038078F  F3 0F 10 83 A0 FD 00 00     movss   xmm0, dword ptr [rbx+0FDA0h]
0000000180380797  F3 0F 58 F8                 addss   xmm7, xmm0
000000018038079B  F3 0F 11 83 90 FD 00 00     movss   dword ptr [rbx+0FD90h], xmm0
00000001803807A3  F3 0F 11 8B D0 FA 00 00     movss   dword ptr [rbx+0FAD0h], xmm1
00000001803807AB  41 0F 2F FF                 comiss  xmm7, xmm15
00000001803807AF  73 06                       jnb     short loc_1803807B7
00000001803807B1  41 0F 28 FF                 movaps  xmm7, xmm15
00000001803807B5  EB 05                       jmp     short loc_1803807BC
00000001803807B7  F3 41 0F 5D FD              minss   xmm7, xmm13
00000001803807BC  F3 0F 59 0D FC A5 60 00     mulss   xmm1, cs:dword_18098ADC0
00000001803807C4  41 0F 28 C5                 movaps  xmm0, xmm13
00000001803807C8  F3 0F 10 B3 B0 FE 00 00     movss   xmm6, dword ptr [rbx+0FEB0h]
00000001803807D0  F3 0F 5C C3                 subss   xmm0, xmm3
00000001803807D4  F3 0F 11 BB 30 FC 00 00     movss   dword ptr [rbx+0FC30h], xmm7
00000001803807DC  F3 0F 5D F1                 minss   xmm6, xmm1
00000001803807E0  F3 0F 59 83 E0 FD 00 00     mulss   xmm0, dword ptr [rbx+0FDE0h]
00000001803807E8  F3 0F 58 C3                 addss   xmm0, xmm3
00000001803807EC  41 0F 2F C7                 comiss  xmm0, xmm15
00000001803807F0  73 06                       jnb     short loc_1803807F8
00000001803807F2  41 0F 28 C7                 movaps  xmm0, xmm15
00000001803807F6  EB 05                       jmp     short loc_1803807FD
00000001803807F8  F3 41 0F 5D C5              minss   xmm0, xmm13
00000001803807FD  F3 0F 59 B3 C0 FE 00 00     mulss   xmm6, dword ptr [rbx+0FEC0h]
0000000180380805  F3 0F 5C D7                 subss   xmm2, xmm7
0000000180380809  F3 0F 11 B3 E0 FC 00 00     movss   dword ptr [rbx+0FCE0h], xmm6
0000000180380811  F3 0F 58 F4                 addss   xmm6, xmm4
0000000180380815  41 0F 2F D6                 comiss  xmm2, xmm14
0000000180380819  73 03                       jnb     short loc_18038081E
000000018038081B  0F 57 C0                    xorps   xmm0, xmm0
000000018038081E  F3 0F 10 8B B0 FD 00 00     movss   xmm1, dword ptr [rbx+0FDB0h]
0000000180380826  F3 44 0F 10 9B F0 FB 00 00  movss   xmm11, dword ptr [rbx+0FBF0h]
000000018038082F  F3 0F 11 83 40 FC 00 00     movss   dword ptr [rbx+0FC40h], xmm0
0000000180380837  F3 0F 58 83 40 FF 00 00     addss   xmm0, dword ptr [rbx+0FF40h]
000000018038083F  72 04                       jb      short loc_180380845
0000000180380841  41 0F 28 CD                 movaps  xmm1, xmm13
0000000180380845  F3 0F 59 83 30 FF 00 00     mulss   xmm0, dword ptr [rbx+0FF30h]
000000018038084D  41 0F 28 FB                 movaps  xmm7, xmm11
0000000180380851  F3 0F 10 93 90 FC 00 00     movss   xmm2, dword ptr [rbx+0FC90h]
0000000180380859  F3 0F 59 F1                 mulss   xmm6, xmm1
000000018038085D  F3 0F 5C FA                 subss   xmm7, xmm2
0000000180380861  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180380865  F3 0F 59 B3 C0 FD 00 00     mulss   xmm6, dword ptr [rbx+0FDC0h]
000000018038086D  76 05                       jbe     short loc_180380874
000000018038086F  0F 5A C8                    cvtps2pd xmm1, xmm0
0000000180380872  EB 03                       jmp     short loc_180380877
0000000180380874  0F 57 C9                    xorps   xmm1, xmm1
0000000180380877  41 0F 2F F5                 comiss  xmm6, xmm13
000000018038087B  F3 0F 59 BB 00 00 01 00     mulss   xmm7, dword ptr [rbx+10000h]
0000000180380883  F3 44 0F 10 0D 5C 49 76 00  movss   xmm9, cs:flt_180AE51E8
000000018038088C  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
0000000180380890  F3 0F 58 FA                 addss   xmm7, xmm2
0000000180380894  F3 0F 11 BB 80 FC 00 00     movss   dword ptr [rbx+0FC80h], xmm7
000000018038089C  F3 0F 11 83 20 FC 00 00     movss   dword ptr [rbx+0FC20h], xmm0
00000001803808A4  41 0F 28 C3                 movaps  xmm0, xmm11
00000001803808A8  F3 0F 59 BB F0 FF 00 00     mulss   xmm7, dword ptr [rbx+0FFF0h]
00000001803808B0  F3 0F 10 8B 70 FE 00 00     movss   xmm1, dword ptr [rbx+0FE70h]
00000001803808B8  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803808BC  F3 0F 59 F9                 mulss   xmm7, xmm1
00000001803808C0  F3 0F 5C F8                 subss   xmm7, xmm0
00000001803808C4  F3 0F 10 83 70 FC 00 00     movss   xmm0, dword ptr [rbx+0FC70h]
00000001803808CC  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
00000001803808D5  F3 41 0F 58 FB              addss   xmm7, xmm11
00000001803808DA  76 1B                       jbe     short loc_1803808F7
00000001803808DC  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803808E1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803808E5  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803808E8  E8 EB EB 36 00              call    fmodf
00000001803808ED  0F 28 F0                    movaps  xmm6, xmm0
00000001803808F0  F3 41 0F 5C F5              subss   xmm6, xmm13
00000001803808F5  EB 1F                       jmp     short loc_180380916
00000001803808F7  41 0F 2F F7                 comiss  xmm6, xmm15
00000001803808FB  73 19                       jnb     short loc_180380916
00000001803808FD  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180380902  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180380906  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180380909  E8 CA EB 36 00              call    fmodf
000000018038090E  0F 28 F0                    movaps  xmm6, xmm0
0000000180380911  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180380916  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
000000018038091F  0F 28 C6                    movaps  xmm0, xmm6
0000000180380922  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180380926  F3 44 0F 10 83 B0 FC 00 00  movss   xmm8, dword ptr [rbx+0FCB0h]
000000018038092F  F3 0F 11 B3 60 FC 00 00     movss   dword ptr [rbx+0FC60h], xmm6
0000000180380937  F3 0F 59 BB E0 FF 00 00     mulss   xmm7, dword ptr [rbx+0FFE0h]
000000018038093F  F3 0F 58 83 50 FF 00 00     addss   xmm0, dword ptr [rbx+0FF50h]
0000000180380947  F3 0F 11 BB E0 FB 00 00     movss   dword ptr [rbx+0FBE0h], xmm7
000000018038094F  73 0A                       jnb     short loc_18038095B
0000000180380951  41 0F 2F F6                 comiss  xmm6, xmm14
0000000180380955  76 04                       jbe     short loc_18038095B
0000000180380957  45 0F 28 C3                 movaps  xmm8, xmm11
000000018038095B  41 0F 2F C5                 comiss  xmm0, xmm13
000000018038095F  76 15                       jbe     short loc_180380976
0000000180380961  F3 41 0F 58 C5              addss   xmm0, xmm13; X
0000000180380966  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018038096A  E8 69 EB 36 00              call    fmodf
000000018038096F  F3 41 0F 5C C5              subss   xmm0, xmm13
0000000180380974  EB 19                       jmp     short loc_18038098F
0000000180380976  41 0F 2F C7                 comiss  xmm0, xmm15
000000018038097A  73 13                       jnb     short loc_18038098F
000000018038097C  F3 41 0F 5C C5              subss   xmm0, xmm13; X
0000000180380981  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180380985  E8 4E EB 36 00              call    fmodf
000000018038098A  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018038098F  F3 44 0F 10 1D 28 4E 76 00  movss   xmm11, dword ptr cs:xmmword_180AE57C0
0000000180380998  F3 44 0F 11 83 A0 FC 00 00  movss   dword ptr [rbx+0FCA0h], xmm8
00000001803809A1  F3 0F 59 83 90 FF 00 00     mulss   xmm0, dword ptr [rbx+0FF90h]
00000001803809A9  F3 44 0F 59 83 D0 FF 00 00  mulss   xmm8, dword ptr [rbx+0FFD0h]
00000001803809B2  F3 0F 58 83 10 00 01 00     addss   xmm0, dword ptr [rbx+10010h]
00000001803809BA  F3 0F 11 83 F0 FC 00 00     movss   dword ptr [rbx+0FCF0h], xmm0
00000001803809C2  41 0F 57 C3                 xorps   xmm0, xmm11
00000001803809C6  F3 44 0F 11 83 40 FD 00 00  movss   dword ptr [rbx+0FD40h], xmm8
00000001803809CF  44 0F 28 C6                 movaps  xmm8, xmm6
00000001803809D3  F3 44 0F 58 83 70 FF 00 00  addss   xmm8, dword ptr [rbx+0FF70h]
00000001803809DC  F3 0F 11 83 00 FD 00 00     movss   dword ptr [rbx+0FD00h], xmm0
00000001803809E4  45 0F 2F C5                 comiss  xmm8, xmm13
00000001803809E8  76 1D                       jbe     short loc_180380A07
00000001803809EA  F3 45 0F 58 C5              addss   xmm8, xmm13
00000001803809EF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00000001803809F3  41 0F 28 C0                 movaps  xmm0, xmm8; X
00000001803809F7  E8 DC EA 36 00              call    fmodf
00000001803809FC  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180380A00  F3 45 0F 5C C5              subss   xmm8, xmm13
0000000180380A05  EB 21                       jmp     short loc_180380A28
0000000180380A07  45 0F 2F C7                 comiss  xmm8, xmm15
0000000180380A0B  73 1B                       jnb     short loc_180380A28
0000000180380A0D  F3 45 0F 5C C5              subss   xmm8, xmm13
0000000180380A12  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180380A16  41 0F 28 C0                 movaps  xmm0, xmm8; X
0000000180380A1A  E8 B9 EA 36 00              call    fmodf
0000000180380A1F  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180380A23  F3 45 0F 58 C5              addss   xmm8, xmm13
0000000180380A28  0F 28 FE                    movaps  xmm7, xmm6
0000000180380A2B  F3 0F 58 BB 60 FF 00 00     addss   xmm7, dword ptr [rbx+0FF60h]
0000000180380A33  41 0F 2F FD                 comiss  xmm7, xmm13
0000000180380A37  76 1B                       jbe     short loc_180380A54
0000000180380A39  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180380A3E  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180380A42  0F 28 C7                    movaps  xmm0, xmm7; X
0000000180380A45  E8 8E EA 36 00              call    fmodf
0000000180380A4A  0F 28 F8                    movaps  xmm7, xmm0
0000000180380A4D  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180380A52  EB 1F                       jmp     short loc_180380A73
0000000180380A54  41 0F 2F FF                 comiss  xmm7, xmm15
0000000180380A58  73 19                       jnb     short loc_180380A73
0000000180380A5A  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180380A5F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180380A63  0F 28 C7                    movaps  xmm0, xmm7; X
0000000180380A66  E8 6D EA 36 00              call    fmodf
0000000180380A6B  0F 28 F8                    movaps  xmm7, xmm0
0000000180380A6E  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180380A73  41 0F 28 C0                 movaps  xmm0, xmm8
0000000180380A77  E8 44 85 FE FF              call    sub_180368FC0
0000000180380A7C  F3 0F 58 BB 20 00 01 00     addss   xmm7, dword ptr [rbx+10020h]
0000000180380A84  F3 0F 59 83 B0 FF 00 00     mulss   xmm0, dword ptr [rbx+0FFB0h]
0000000180380A8C  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180380A90  73 06                       jnb     short loc_180380A98
0000000180380A92  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180380A96  EB 06                       jmp     short loc_180380A9E
0000000180380A98  76 04                       jbe     short loc_180380A9E
0000000180380A9A  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180380A9E  F3 0F 58 B3 80 FF 00 00     addss   xmm6, dword ptr [rbx+0FF80h]
0000000180380AA6  F3 0F 11 83 20 FD 00 00     movss   dword ptr [rbx+0FD20h], xmm0
0000000180380AAE  F3 0F 11 BB 80 FD 00 00     movss   dword ptr [rbx+0FD80h], xmm7
0000000180380AB6  F3 0F 59 BB A0 FF 00 00     mulss   xmm7, dword ptr [rbx+0FFA0h]
0000000180380ABE  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180380AC2  F3 0F 58 BB 30 00 01 00     addss   xmm7, dword ptr [rbx+10030h]
0000000180380ACA  76 1B                       jbe     short loc_180380AE7
0000000180380ACC  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180380AD1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180380AD5  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180380AD8  E8 FB E9 36 00              call    fmodf
0000000180380ADD  0F 28 F0                    movaps  xmm6, xmm0
0000000180380AE0  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180380AE5  EB 1F                       jmp     short loc_180380B06
0000000180380AE7  41 0F 2F F7                 comiss  xmm6, xmm15
0000000180380AEB  73 19                       jnb     short loc_180380B06
0000000180380AED  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180380AF2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180380AF6  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180380AF9  E8 DA E9 36 00              call    fmodf
0000000180380AFE  0F 28 F0                    movaps  xmm6, xmm0
0000000180380B01  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180380B06  0F 54 35 83 4C 76 00        andps   xmm6, cs:xmmword_180AE5790
0000000180380B0D  F3 0F 11 BB 10 FD 00 00     movss   dword ptr [rbx+0FD10h], xmm7
0000000180380B15  0F 28 E6                    movaps  xmm4, xmm6
0000000180380B18  F3 0F 10 9B 50 FE 00 00     movss   xmm3, dword ptr [rbx+0FE50h]
0000000180380B20  0F 28 D6                    movaps  xmm2, xmm6
0000000180380B23  F3 0F 59 93 E0 FE 00 00     mulss   xmm2, dword ptr [rbx+0FEE0h]
0000000180380B2B  F3 0F 59 9B 40 FD 00 00     mulss   xmm3, dword ptr [rbx+0FD40h]
0000000180380B33  F3 0F 58 93 D0 FE 00 00     addss   xmm2, dword ptr [rbx+0FED0h]
0000000180380B3B  F3 0F 10 8B 40 FE 00 00     movss   xmm1, dword ptr [rbx+0FE40h]
0000000180380B43  F3 0F 59 8B 00 FD 00 00     mulss   xmm1, dword ptr [rbx+0FD00h]
0000000180380B4B  F3 0F 59 E6                 mulss   xmm4, xmm6
0000000180380B4F  0F 28 C4                    movaps  xmm0, xmm4
0000000180380B52  F3 0F 59 E6                 mulss   xmm4, xmm6
0000000180380B56  F3 0F 59 83 F0 FE 00 00     mulss   xmm0, dword ptr [rbx+0FEF0h]
0000000180380B5E  F3 0F 59 F4                 mulss   xmm6, xmm4
0000000180380B62  F3 0F 59 A3 00 FF 00 00     mulss   xmm4, dword ptr [rbx+0FF00h]
0000000180380B6A  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180380B6E  F3 0F 59 B3 10 FF 00 00     mulss   xmm6, dword ptr [rbx+0FF10h]
0000000180380B76  F3 0F 10 83 30 FE 00 00     movss   xmm0, dword ptr [rbx+0FE30h]
0000000180380B7E  F3 0F 59 83 F0 FC 00 00     mulss   xmm0, dword ptr [rbx+0FCF0h]
0000000180380B86  F3 0F 58 E2                 addss   xmm4, xmm2
0000000180380B8A  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180380B8E  F3 0F 58 F4                 addss   xmm6, xmm4
0000000180380B92  F3 0F 10 A3 10 FE 00 00     movss   xmm4, dword ptr [rbx+0FE10h]
0000000180380B9A  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180380B9E  F3 0F 58 B3 20 FF 00 00     addss   xmm6, dword ptr [rbx+0FF20h]
0000000180380BA6  F3 0F 59 B3 C0 FF 00 00     mulss   xmm6, dword ptr [rbx+0FFC0h]
0000000180380BAE  F3 0F 11 B3 30 FD 00 00     movss   dword ptr [rbx+0FD30h], xmm6
0000000180380BB6  F3 0F 59 A3 20 FD 00 00     mulss   xmm4, dword ptr [rbx+0FD20h]
0000000180380BBE  F3 0F 10 8B F0 FD 00 00     movss   xmm1, dword ptr [rbx+0FDF0h]
0000000180380BC6  F3 0F 10 83 20 FE 00 00     movss   xmm0, dword ptr [rbx+0FE20h]
0000000180380BCE  F3 0F 59 83 10 FD 00 00     mulss   xmm0, dword ptr [rbx+0FD10h]
0000000180380BD6  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180380BDA  F3 0F 10 93 80 FE 00 00     movss   xmm2, dword ptr [rbx+0FE80h]
0000000180380BE2  0F 28 D9                    movaps  xmm3, xmm1
0000000180380BE5  F3 0F 59 9B 20 FC 00 00     mulss   xmm3, dword ptr [rbx+0FC20h]
0000000180380BED  F3 0F 59 B3 00 FE 00 00     mulss   xmm6, dword ptr [rbx+0FE00h]
0000000180380BF5  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180380BF9  F3 0F 10 83 60 FE 00 00     movss   xmm0, dword ptr [rbx+0FE60h]
0000000180380C01  F3 0F 5C D9                 subss   xmm3, xmm1
0000000180380C05  F3 0F 59 83 E0 FB 00 00     mulss   xmm0, dword ptr [rbx+0FBE0h]
0000000180380C0D  F3 0F 58 E6                 addss   xmm4, xmm6
0000000180380C11  F3 41 0F 58 DD              addss   xmm3, xmm13
0000000180380C16  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180380C1A  F3 0F 11 9B 50 FD 00 00     movss   dword ptr [rbx+0FD50h], xmm3
0000000180380C22  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180380C26  F3 0F 11 A3 70 FD 00 00     movss   dword ptr [rbx+0FD70h], xmm4
0000000180380C2E  F3 0F 10 8B A0 FE 00 00     movss   xmm1, dword ptr [rbx+0FEA0h]
0000000180380C36  F3 0F 59 8B 10 FC 00 00     mulss   xmm1, dword ptr [rbx+0FC10h]
0000000180380C3E  F3 0F 10 83 90 FE 00 00     movss   xmm0, dword ptr [rbx+0FE90h]
0000000180380C46  F3 0F 59 83 00 FC 00 00     mulss   xmm0, dword ptr [rbx+0FC00h]
0000000180380C4E  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180380C52  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180380C56  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180380C5A  F3 0F 11 8B 60 FD 00 00     movss   dword ptr [rbx+0FD60h], xmm1
0000000180380C62  F3 0F 10 83 70 FD 00 00     movss   xmm0, dword ptr [rbx+0FD70h]
0000000180380C6A  8B 83 80 FD 00 00           mov     eax, [rbx+0FD80h]
0000000180380C70  89 83 40 00 01 00           mov     [rbx+10040h], eax
0000000180380C76  F3 0F 11 83 50 00 01 00     movss   dword ptr [rbx+10050h], xmm0
0000000180380C7E  44 0F 2F B3 80 FD 00 00     comiss  xmm14, dword ptr [rbx+0FD80h]
0000000180380C86  F3 0F 10 8B 90 F8 00 00     movss   xmm1, dword ptr [rbx+0F890h]
0000000180380C8E  F3 0F 10 93 60 00 01 00     movss   xmm2, dword ptr [rbx+10060h]
0000000180380C96  73 06                       jnb     short loc_180380C9E
0000000180380C98  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180380C9C  EB 03                       jmp     short loc_180380CA1
0000000180380C9E  0F 57 C0                    xorps   xmm0, xmm0
0000000180380CA1  41 0F 2E D6                 ucomiss xmm2, xmm14
0000000180380CA5  75 04                       jnz     short loc_180380CAB
0000000180380CA7  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180380CAB  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180380CAF  F3 0F 11 8B 70 00 01 00     movss   dword ptr [rbx+10070h], xmm1
0000000180380CB7  8B 83 80 00 01 00           mov     eax, [rbx+10080h]
0000000180380CBD  89 83 90 00 01 00           mov     [rbx+10090h], eax
0000000180380CC3  8B 83 B0 00 01 00           mov     eax, [rbx+100B0h]
0000000180380CC9  89 83 C0 00 01 00           mov     [rbx+100C0h], eax
0000000180380CCF  8B 83 A0 00 01 00           mov     eax, [rbx+100A0h]
0000000180380CD5  89 83 B0 00 01 00           mov     [rbx+100B0h], eax
0000000180380CDB  8B 83 D0 00 01 00           mov     eax, [rbx+100D0h]
0000000180380CE1  89 83 E0 00 01 00           mov     [rbx+100E0h], eax
0000000180380CE7  8B 83 00 01 01 00           mov     eax, [rbx+10100h]
0000000180380CED  89 83 10 01 01 00           mov     [rbx+10110h], eax
0000000180380CF3  F3 0F 10 83 B0 01 01 00     movss   xmm0, dword ptr [rbx+101B0h]
0000000180380CFB  F3 0F 58 8B 90 01 01 00     addss   xmm1, dword ptr [rbx+10190h]
0000000180380D03  F3 0F 59 83 C0 00 01 00     mulss   xmm0, dword ptr [rbx+100C0h]
0000000180380D0B  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180380D0F  F3 0F 58 83 90 00 01 00     addss   xmm0, dword ptr [rbx+10090h]
0000000180380D17  73 06                       jnb     short loc_180380D1F
0000000180380D19  45 0F 28 C5                 movaps  xmm8, xmm13
0000000180380D1D  EB 04                       jmp     short loc_180380D23
0000000180380D1F  45 0F 57 C0                 xorps   xmm8, xmm8
0000000180380D23  41 0F 28 ED                 movaps  xmm5, xmm13
0000000180380D27  F3 41 0F 5C E8              subss   xmm5, xmm8
0000000180380D2C  0F 28 FD                    movaps  xmm7, xmm5
0000000180380D2F  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180380D33  F3 0F 11 BB A0 00 01 00     movss   dword ptr [rbx+100A0h], xmm7
0000000180380D3B  0F 28 E7                    movaps  xmm4, xmm7
0000000180380D3E  F3 0F 10 9B 80 01 01 00     movss   xmm3, dword ptr [rbx+10180h]
0000000180380D46  F3 0F 10 93 D0 01 01 00     movss   xmm2, dword ptr [rbx+101D0h]
0000000180380D4E  0F 28 CB                    movaps  xmm1, xmm3
0000000180380D51  F3 0F 59 8B F0 01 01 00     mulss   xmm1, dword ptr [rbx+101F0h]
0000000180380D59  0F 28 C2                    movaps  xmm0, xmm2
0000000180380D5C  F3 0F 58 A3 A0 01 01 00     addss   xmm4, dword ptr [rbx+101A0h]
0000000180380D64  F3 0F 5C BB B0 00 01 00     subss   xmm7, dword ptr [rbx+100B0h]
0000000180380D6C  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180380D70  41 0F 2F E6                 comiss  xmm4, xmm14
0000000180380D74  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180380D78  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180380D7C  F3 0F 11 8B F0 00 01 00     movss   dword ptr [rbx+100F0h], xmm1
0000000180380D84  72 06                       jb      short loc_180380D8C
0000000180380D86  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180380D8A  EB 03                       jmp     short loc_180380D8F
0000000180380D8C  0F 57 F6                    xorps   xmm6, xmm6
0000000180380D8F  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180380D93  F3 0F 10 83 50 01 01 00     movss   xmm0, dword ptr [rbx+10150h]
0000000180380D9B  73 03                       jnb     short loc_180380DA0
0000000180380D9D  0F 28 F5                    movaps  xmm6, xmm5
0000000180380DA0  F3 0F 59 83 D0 01 01 00     mulss   xmm0, dword ptr [rbx+101D0h]
0000000180380DA8  0F 28 DD                    movaps  xmm3, xmm5
0000000180380DAB  F3 0F 10 93 40 01 01 00     movss   xmm2, dword ptr [rbx+10140h]
0000000180380DB3  F3 44 0F 10 0D A0 41 76 00  movss   xmm9, cs:dword_180AE4F5C
0000000180380DBC  F3 0F 59 D8                 mulss   xmm3, xmm0
0000000180380DC0  F3 0F 11 B3 B0 00 01 00     movss   dword ptr [rbx+100B0h], xmm6
0000000180380DC8  F3 0F 10 8B E0 01 01 00     movss   xmm1, dword ptr [rbx+101E0h]
0000000180380DD0  F3 0F 10 BB 60 01 01 00     movss   xmm7, dword ptr [rbx+10160h]
0000000180380DD8  0F 28 C1                    movaps  xmm0, xmm1
0000000180380DDB  F3 0F 10 A3 E0 00 01 00     movss   xmm4, dword ptr [rbx+100E0h]
0000000180380DE3  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180380DE7  F3 41 0F 59 F9              mulss   xmm7, xmm9
0000000180380DEC  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180380DF0  F3 41 0F 59 D1              mulss   xmm2, xmm9
0000000180380DF5  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180380DF9  F3 0F 59 FE                 mulss   xmm7, xmm6
0000000180380DFD  F3 0F 5C C6                 subss   xmm0, xmm6
0000000180380E01  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180380E05  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180380E09  0F 28 CB                    movaps  xmm1, xmm3
0000000180380E0C  F3 0F 5C CC                 subss   xmm1, xmm4
0000000180380E10  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180380E14  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180380E18  F3 0F 58 FA                 addss   xmm7, xmm2
0000000180380E1C  76 0B                       jbe     short loc_180380E29
0000000180380E1E  0F 28 DC                    movaps  xmm3, xmm4
0000000180380E21  F3 0F 58 9B F0 00 01 00     addss   xmm3, dword ptr [rbx+100F0h]
0000000180380E29  F3 0F 10 83 D0 01 01 00     movss   xmm0, dword ptr [rbx+101D0h]
0000000180380E31  F3 0F 10 A3 90 00 01 00     movss   xmm4, dword ptr [rbx+10090h]
0000000180380E39  F3 0F 5D C3                 minss   xmm0, xmm3
0000000180380E3D  F3 0F 11 83 D0 00 01 00     movss   dword ptr [rbx+100D0h], xmm0
0000000180380E45  F3 0F 10 8B 10 01 01 00     movss   xmm1, dword ptr [rbx+10110h]
0000000180380E4D  F3 0F 10 9B 70 01 01 00     movss   xmm3, dword ptr [rbx+10170h]
0000000180380E55  F3 0F 59 AB C0 01 01 00     mulss   xmm5, dword ptr [rbx+101C0h]
0000000180380E5D  F3 41 0F 59 D9              mulss   xmm3, xmm9
0000000180380E62  F3 0F 59 F0                 mulss   xmm6, xmm0
0000000180380E66  F3 0F 10 83 00 02 01 00     movss   xmm0, dword ptr [rbx+10200h]
0000000180380E6E  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180380E73  0F 28 D0                    movaps  xmm2, xmm0
0000000180380E76  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180380E7A  F3 0F 58 EE                 addss   xmm5, xmm6
0000000180380E7E  F3 0F 59 D7                 mulss   xmm2, xmm7
0000000180380E82  F3 0F 5C EC                 subss   xmm5, xmm4
0000000180380E86  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180380E8A  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180380E8E  F3 0F 11 93 00 01 01 00     movss   dword ptr [rbx+10100h], xmm2
0000000180380E96  F3 44 0F 59 C2              mulss   xmm8, xmm2
0000000180380E9B  F3 41 0F 5C D8              subss   xmm3, xmm8
0000000180380EA0  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180380EA4  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180380EA8  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180380EAC  F3 0F 11 9B 80 00 01 00     movss   dword ptr [rbx+10080h], xmm3
0000000180380EB4  F3 0F 59 9B 10 02 01 00     mulss   xmm3, dword ptr [rbx+10210h]
0000000180380EBC  F3 0F 59 9B 20 02 01 00     mulss   xmm3, dword ptr [rbx+10220h]
0000000180380EC4  0F 28 C3                    movaps  xmm0, xmm3
0000000180380EC7  F3 0F 59 83 30 02 01 00     mulss   xmm0, dword ptr [rbx+10230h]
0000000180380ECF  F3 0F 11 9B 20 01 01 00     movss   dword ptr [rbx+10120h], xmm3
0000000180380ED7  F3 0F 11 83 30 01 01 00     movss   dword ptr [rbx+10130h], xmm0
0000000180380EDF  44 0F 2F B3 80 FD 00 00     comiss  xmm14, dword ptr [rbx+0FD80h]
0000000180380EE7  F3 0F 10 8B 90 F8 00 00     movss   xmm1, dword ptr [rbx+0F890h]
0000000180380EEF  F3 0F 10 93 40 02 01 00     movss   xmm2, dword ptr [rbx+10240h]
0000000180380EF7  73 06                       jnb     short loc_180380EFF
0000000180380EF9  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180380EFD  EB 03                       jmp     short loc_180380F02
0000000180380EFF  0F 57 C0                    xorps   xmm0, xmm0
0000000180380F02  41 0F 2E D6                 ucomiss xmm2, xmm14
0000000180380F06  75 04                       jnz     short loc_180380F0C
0000000180380F08  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180380F0C  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180380F10  F3 0F 11 8B 50 02 01 00     movss   dword ptr [rbx+10250h], xmm1
0000000180380F18  8B 83 60 02 01 00           mov     eax, [rbx+10260h]
0000000180380F1E  89 83 70 02 01 00           mov     [rbx+10270h], eax
0000000180380F24  8B 83 90 02 01 00           mov     eax, [rbx+10290h]
0000000180380F2A  89 83 A0 02 01 00           mov     [rbx+102A0h], eax
0000000180380F30  8B 83 80 02 01 00           mov     eax, [rbx+10280h]
0000000180380F36  89 83 90 02 01 00           mov     [rbx+10290h], eax
0000000180380F3C  8B 83 B0 02 01 00           mov     eax, [rbx+102B0h]
0000000180380F42  89 83 C0 02 01 00           mov     [rbx+102C0h], eax
0000000180380F48  8B 83 E0 02 01 00           mov     eax, [rbx+102E0h]
0000000180380F4E  89 83 F0 02 01 00           mov     [rbx+102F0h], eax
0000000180380F54  F3 0F 10 83 90 03 01 00     movss   xmm0, dword ptr [rbx+10390h]
0000000180380F5C  F3 0F 58 8B 70 03 01 00     addss   xmm1, dword ptr [rbx+10370h]
0000000180380F64  F3 0F 59 83 A0 02 01 00     mulss   xmm0, dword ptr [rbx+102A0h]
0000000180380F6C  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180380F70  F3 0F 58 83 70 02 01 00     addss   xmm0, dword ptr [rbx+10270h]
0000000180380F78  73 06                       jnb     short loc_180380F80
0000000180380F7A  45 0F 28 C5                 movaps  xmm8, xmm13
0000000180380F7E  EB 04                       jmp     short loc_180380F84
0000000180380F80  45 0F 57 C0                 xorps   xmm8, xmm8
0000000180380F84  41 0F 28 ED                 movaps  xmm5, xmm13
0000000180380F88  F3 41 0F 5C E8              subss   xmm5, xmm8
0000000180380F8D  0F 28 F5                    movaps  xmm6, xmm5
0000000180380F90  F3 0F 59 F0                 mulss   xmm6, xmm0
0000000180380F94  F3 0F 11 B3 80 02 01 00     movss   dword ptr [rbx+10280h], xmm6
0000000180380F9C  0F 28 E6                    movaps  xmm4, xmm6
0000000180380F9F  F3 0F 10 9B 60 03 01 00     movss   xmm3, dword ptr [rbx+10360h]
0000000180380FA7  F3 0F 10 93 B0 03 01 00     movss   xmm2, dword ptr [rbx+103B0h]
0000000180380FAF  0F 28 CB                    movaps  xmm1, xmm3
0000000180380FB2  F3 0F 59 8B D0 03 01 00     mulss   xmm1, dword ptr [rbx+103D0h]
0000000180380FBA  0F 28 C2                    movaps  xmm0, xmm2
0000000180380FBD  F3 0F 58 A3 80 03 01 00     addss   xmm4, dword ptr [rbx+10380h]
0000000180380FC5  F3 0F 5C B3 90 02 01 00     subss   xmm6, dword ptr [rbx+10290h]
0000000180380FCD  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180380FD1  41 0F 2F E6                 comiss  xmm4, xmm14
0000000180380FD5  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180380FD9  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180380FDD  F3 0F 11 8B D0 02 01 00     movss   dword ptr [rbx+102D0h], xmm1
0000000180380FE5  72 06                       jb      short loc_180380FED
0000000180380FE7  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180380FEB  EB 03                       jmp     short loc_180380FF0
0000000180380FED  0F 57 FF                    xorps   xmm7, xmm7
0000000180380FF0  41 0F 2F F6                 comiss  xmm6, xmm14
0000000180380FF4  F3 0F 10 83 30 03 01 00     movss   xmm0, dword ptr [rbx+10330h]
0000000180380FFC  73 03                       jnb     short loc_180381001
0000000180380FFE  0F 28 FD                    movaps  xmm7, xmm5
0000000180381001  F3 0F 59 83 B0 03 01 00     mulss   xmm0, dword ptr [rbx+103B0h]
0000000180381009  0F 28 DD                    movaps  xmm3, xmm5
000000018038100C  F3 0F 10 93 20 03 01 00     movss   xmm2, dword ptr [rbx+10320h]
0000000180381014  F3 0F 11 BB 90 02 01 00     movss   dword ptr [rbx+10290h], xmm7
000000018038101C  F3 0F 10 8B C0 03 01 00     movss   xmm1, dword ptr [rbx+103C0h]
0000000180381024  F3 0F 10 B3 40 03 01 00     movss   xmm6, dword ptr [rbx+10340h]
000000018038102C  F3 0F 10 A3 C0 02 01 00     movss   xmm4, dword ptr [rbx+102C0h]
0000000180381034  F3 0F 59 D8                 mulss   xmm3, xmm0
0000000180381038  0F 28 C1                    movaps  xmm0, xmm1
000000018038103B  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018038103F  F3 41 0F 59 F1              mulss   xmm6, xmm9
0000000180381044  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180381048  F3 41 0F 59 D1              mulss   xmm2, xmm9
000000018038104D  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180381051  F3 0F 59 F7                 mulss   xmm6, xmm7
0000000180381055  F3 0F 5C C7                 subss   xmm0, xmm7
0000000180381059  F3 0F 58 D9                 addss   xmm3, xmm1
000000018038105D  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180381061  0F 28 CB                    movaps  xmm1, xmm3
0000000180381064  F3 0F 5C CC                 subss   xmm1, xmm4
0000000180381068  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018038106C  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180381070  F3 0F 58 F2                 addss   xmm6, xmm2
0000000180381074  76 0B                       jbe     short loc_180381081
0000000180381076  0F 28 DC                    movaps  xmm3, xmm4
0000000180381079  F3 0F 58 9B D0 02 01 00     addss   xmm3, dword ptr [rbx+102D0h]
0000000180381081  F3 0F 10 A3 70 02 01 00     movss   xmm4, dword ptr [rbx+10270h]
0000000180381089  F3 0F 10 83 B0 03 01 00     movss   xmm0, dword ptr [rbx+103B0h]
0000000180381091  F3 0F 5D C3                 minss   xmm0, xmm3
0000000180381095  F3 0F 11 83 B0 02 01 00     movss   dword ptr [rbx+102B0h], xmm0
000000018038109D  F3 0F 59 AB A0 03 01 00     mulss   xmm5, dword ptr [rbx+103A0h]
00000001803810A5  F3 0F 10 8B F0 02 01 00     movss   xmm1, dword ptr [rbx+102F0h]
00000001803810AD  F3 0F 10 9B 50 03 01 00     movss   xmm3, dword ptr [rbx+10350h]
00000001803810B5  F3 0F 59 F8                 mulss   xmm7, xmm0
00000001803810B9  F3 0F 10 83 E0 03 01 00     movss   xmm0, dword ptr [rbx+103E0h]
00000001803810C1  0F 28 D0                    movaps  xmm2, xmm0
00000001803810C4  F3 41 0F 59 D9              mulss   xmm3, xmm9
00000001803810C9  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803810CD  F3 0F 58 EF                 addss   xmm5, xmm7
00000001803810D1  F3 41 0F 59 D8              mulss   xmm3, xmm8
00000001803810D6  F3 0F 59 D6                 mulss   xmm2, xmm6
00000001803810DA  F3 0F 5C EC                 subss   xmm5, xmm4
00000001803810DE  F3 0F 5C D0                 subss   xmm2, xmm0
00000001803810E2  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803810E6  F3 0F 11 93 E0 02 01 00     movss   dword ptr [rbx+102E0h], xmm2
00000001803810EE  F3 44 0F 59 C2              mulss   xmm8, xmm2
00000001803810F3  F3 41 0F 5C D8              subss   xmm3, xmm8
00000001803810F8  F3 0F 58 DA                 addss   xmm3, xmm2
00000001803810FC  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180381100  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180381104  F3 0F 11 9B 60 02 01 00     movss   dword ptr [rbx+10260h], xmm3
000000018038110C  F3 0F 59 9B F0 03 01 00     mulss   xmm3, dword ptr [rbx+103F0h]
0000000180381114  F3 0F 59 9B 00 04 01 00     mulss   xmm3, dword ptr [rbx+10400h]
000000018038111C  0F 28 C3                    movaps  xmm0, xmm3
000000018038111F  F3 0F 59 83 10 04 01 00     mulss   xmm0, dword ptr [rbx+10410h]
0000000180381127  F3 0F 11 9B 00 03 01 00     movss   dword ptr [rbx+10300h], xmm3
000000018038112F  F3 0F 11 83 10 03 01 00     movss   dword ptr [rbx+10310h], xmm0
0000000180381137  8B 83 20 04 01 00           mov     eax, [rbx+10420h]
000000018038113D  89 83 30 04 01 00           mov     [rbx+10430h], eax
0000000180381143  8B 83 40 04 01 00           mov     eax, [rbx+10440h]
0000000180381149  89 83 50 04 01 00           mov     [rbx+10450h], eax
000000018038114F  F3 0F 10 83 50 F9 00 00     movss   xmm0, dword ptr [rbx+0F950h]
0000000180381157  F3 44 0F 10 83 D0 F9 00 00  movss   xmm8, dword ptr [rbx+0F9D0h]
0000000180381160  8B 83 80 04 01 00           mov     eax, [rbx+10480h]
0000000180381166  89 83 90 04 01 00           mov     [rbx+10490h], eax
000000018038116C  F3 0F 59 83 60 04 01 00     mulss   xmm0, dword ptr [rbx+10460h]
0000000180381174  F3 44 0F 59 83 70 04 01 00  mulss   xmm8, dword ptr [rbx+10470h]
000000018038117D  F3 44 0F 58 C0              addss   xmm8, xmm0
0000000180381182  F3 44 0F 11 83 80 04 01 00  movss   dword ptr [rbx+10480h], xmm8
000000018038118B  F3 0F 10 BB 60 FD 00 00     movss   xmm7, dword ptr [rbx+0FD60h]
0000000180381193  F3 0F 10 8B 20 01 01 00     movss   xmm1, dword ptr [rbx+10120h]
000000018038119B  F3 0F 10 93 00 03 01 00     movss   xmm2, dword ptr [rbx+10300h]
00000001803811A3  F3 0F 10 83 50 F9 00 00     movss   xmm0, dword ptr [rbx+0F950h]
00000001803811AB  8B 83 40 04 01 00           mov     eax, [rbx+10440h]
00000001803811B1  89 83 C0 04 01 00           mov     [rbx+104C0h], eax
00000001803811B7  F3 0F 11 83 D0 04 01 00     movss   dword ptr [rbx+104D0h], xmm0
00000001803811BF  F3 0F 10 A3 10 06 01 00     movss   xmm4, dword ptr [rbx+10610h]
00000001803811C7  F3 0F 11 8B A0 04 01 00     movss   dword ptr [rbx+104A0h], xmm1
00000001803811CF  F3 0F 11 93 B0 04 01 00     movss   dword ptr [rbx+104B0h], xmm2
00000001803811D7  F3 0F 10 AB F0 05 01 00     movss   xmm5, dword ptr [rbx+105F0h]
00000001803811DF  F3 0F 59 FC                 mulss   xmm7, xmm4
00000001803811E3  F3 0F 59 A3 70 FD 00 00     mulss   xmm4, dword ptr [rbx+0FD70h]
00000001803811EB  F3 0F 11 A3 E0 04 01 00     movss   dword ptr [rbx+104E0h], xmm4
00000001803811F3  F3 0F 10 8B 70 05 01 00     movss   xmm1, dword ptr [rbx+10570h]
00000001803811FB  F3 0F 10 93 70 06 01 00     movss   xmm2, dword ptr [rbx+10670h]
0000000180381203  0F 28 D9                    movaps  xmm3, xmm1
0000000180381206  F3 0F 59 BB 20 06 01 00     mulss   xmm7, dword ptr [rbx+10620h]
000000018038120E  0F 28 C2                    movaps  xmm0, xmm2
0000000180381211  F3 0F 10 B3 30 06 01 00     movss   xmm6, dword ptr [rbx+10630h]
0000000180381219  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018038121D  F3 0F 59 F7                 mulss   xmm6, xmm7
0000000180381221  F3 0F 59 EC                 mulss   xmm5, xmm4
0000000180381225  F3 0F 59 AB 00 06 01 00     mulss   xmm5, dword ptr [rbx+10600h]
000000018038122D  F3 0F 11 AB 00 05 01 00     movss   dword ptr [rbx+10500h], xmm5
0000000180381235  F3 0F 58 F5                 addss   xmm6, xmm5
0000000180381239  F3 0F 59 9B C0 04 01 00     mulss   xmm3, dword ptr [rbx+104C0h]
0000000180381241  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180381245  F3 0F 10 83 80 05 01 00     movss   xmm0, dword ptr [rbx+10580h]
000000018038124D  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180381251  F3 0F 59 9B 80 06 01 00     mulss   xmm3, dword ptr [rbx+10680h]
0000000180381259  F3 0F 11 9B 10 05 01 00     movss   dword ptr [rbx+10510h], xmm3
0000000180381261  F3 0F 10 8B 50 06 01 00     movss   xmm1, dword ptr [rbx+10650h]
0000000180381269  F3 0F 59 8B B0 04 01 00     mulss   xmm1, dword ptr [rbx+104B0h]
0000000180381271  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180381275  F3 0F 58 F0                 addss   xmm6, xmm0
0000000180381279  F3 0F 10 83 40 06 01 00     movss   xmm0, dword ptr [rbx+10640h]
0000000180381281  F3 0F 59 83 A0 04 01 00     mulss   xmm0, dword ptr [rbx+104A0h]
0000000180381289  F3 0F 10 9B E0 04 01 00     movss   xmm3, dword ptr [rbx+104E0h]
0000000180381291  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180381295  F3 0F 10 83 60 05 01 00     movss   xmm0, dword ptr [rbx+10560h]
000000018038129D  F3 0F 59 8B 60 06 01 00     mulss   xmm1, dword ptr [rbx+10660h]
00000001803812A5  F3 0F 58 CE                 addss   xmm1, xmm6
00000001803812A9  F3 41 0F 58 C8              addss   xmm1, xmm8
00000001803812AE  F3 0F 58 8B D0 05 01 00     addss   xmm1, dword ptr [rbx+105D0h]
00000001803812B6  F3 0F 58 8B E0 05 01 00     addss   xmm1, dword ptr [rbx+105E0h]
00000001803812BE  F3 0F 11 8B 20 05 01 00     movss   dword ptr [rbx+10520h], xmm1
00000001803812C6  F3 0F 11 83 30 05 01 00     movss   dword ptr [rbx+10530h], xmm0
00000001803812CE  F3 0F 59 9B A0 06 01 00     mulss   xmm3, dword ptr [rbx+106A0h]
00000001803812D6  F3 0F 10 83 A0 05 01 00     movss   xmm0, dword ptr [rbx+105A0h]
00000001803812DE  F3 0F 59 83 A0 04 01 00     mulss   xmm0, dword ptr [rbx+104A0h]
00000001803812E6  F3 0F 58 9B B0 06 01 00     addss   xmm3, dword ptr [rbx+106B0h]
00000001803812EE  F3 0F 10 8B B0 05 01 00     movss   xmm1, dword ptr [rbx+105B0h]
00000001803812F6  F3 0F 59 8B B0 04 01 00     mulss   xmm1, dword ptr [rbx+104B0h]
00000001803812FE  F3 0F 10 93 00 05 01 00     movss   xmm2, dword ptr [rbx+10500h]
0000000180381306  F3 0F 59 9B 90 05 01 00     mulss   xmm3, dword ptr [rbx+10590h]
000000018038130E  F3 0F 58 93 D0 04 01 00     addss   xmm2, dword ptr [rbx+104D0h]
0000000180381316  F3 0F 58 D8                 addss   xmm3, xmm0
000000018038131A  F3 0F 58 93 10 05 01 00     addss   xmm2, dword ptr [rbx+10510h]
0000000180381322  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180381326  F3 0F 58 9B C0 05 01 00     addss   xmm3, dword ptr [rbx+105C0h]
000000018038132E  F3 0F 59 9B 90 06 01 00     mulss   xmm3, dword ptr [rbx+10690h]
0000000180381336  F3 0F 11 9B 40 05 01 00     movss   dword ptr [rbx+10540h], xmm3
000000018038133E  F3 0F 11 93 50 05 01 00     movss   dword ptr [rbx+10550h], xmm2
0000000180381346  F3 0F 10 83 D0 06 01 00     movss   xmm0, dword ptr [rbx+106D0h]
000000018038134E  8B 83 C0 06 01 00           mov     eax, [rbx+106C0h]
0000000180381354  89 83 F0 06 01 00           mov     [rbx+106F0h], eax
000000018038135A  F3 0F 11 83 00 07 01 00     movss   dword ptr [rbx+10700h], xmm0
0000000180381362  8B 83 E0 06 01 00           mov     eax, [rbx+106E0h]
0000000180381368  89 83 10 07 01 00           mov     [rbx+10710h], eax
000000018038136E  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
0000000180381376  8B 83 30 07 01 00           mov     eax, [rbx+10730h]
000000018038137C  89 83 40 07 01 00           mov     [rbx+10740h], eax
0000000180381382  F3 0F 10 93 20 07 01 00     movss   xmm2, dword ptr [rbx+10720h]
000000018038138A  F3 0F 11 93 30 07 01 00     movss   dword ptr [rbx+10730h], xmm2
0000000180381392  0F 28 C2                    movaps  xmm0, xmm2
0000000180381395  0F 28 DA                    movaps  xmm3, xmm2
0000000180381398  F3 0F 59 9B 50 07 01 00     mulss   xmm3, dword ptr [rbx+10750h]
00000001803813A0  F3 0F 58 9B 40 07 01 00     addss   xmm3, dword ptr [rbx+10740h]
00000001803813A8  F3 0F 11 9B 30 07 01 00     movss   dword ptr [rbx+10730h], xmm3
00000001803813B0  F3 0F 59 83 60 07 01 00     mulss   xmm0, dword ptr [rbx+10760h]
00000001803813B8  F3 0F 58 C3                 addss   xmm0, xmm3
00000001803813BC  F3 0F 59 9B 90 07 01 00     mulss   xmm3, dword ptr [rbx+10790h]
00000001803813C4  F3 0F 5C E0                 subss   xmm4, xmm0
00000001803813C8  0F 28 CC                    movaps  xmm1, xmm4
00000001803813CB  F3 0F 59 8B 50 07 01 00     mulss   xmm1, dword ptr [rbx+10750h]
00000001803813D3  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803813D7  F3 0F 11 8B 20 07 01 00     movss   dword ptr [rbx+10720h], xmm1
00000001803813DF  F3 0F 59 8B 80 07 01 00     mulss   xmm1, dword ptr [rbx+10780h]
00000001803813E7  F3 0F 59 A3 70 07 01 00     mulss   xmm4, dword ptr [rbx+10770h]
00000001803813EF  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803813F3  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803813F7  F3 0F 11 A3 40 07 01 00     movss   dword ptr [rbx+10740h], xmm4
00000001803813FF  8B 83 70 0F 01 00           mov     eax, [rbx+10F70h]
0000000180381405  89 83 80 0F 01 00           mov     [rbx+10F80h], eax
000000018038140B  F3 0F 10 8B 90 0F 01 00     movss   xmm1, dword ptr [rbx+10F90h]
0000000180381413  F3 0F 11 8B A0 0F 01 00     movss   dword ptr [rbx+10FA0h], xmm1
000000018038141B  F3 0F 59 8B 30 04 01 00     mulss   xmm1, dword ptr [rbx+10430h]
0000000180381423  F3 0F 10 83 80 0F 01 00     movss   xmm0, dword ptr [rbx+10F80h]
000000018038142B  F3 0F 59 83 40 07 01 00     mulss   xmm0, dword ptr [rbx+10740h]
0000000180381433  F3 0F 11 8B B0 0F 01 00     movss   dword ptr [rbx+10FB0h], xmm1
000000018038143B  F3 0F 11 83 C0 0F 01 00     movss   dword ptr [rbx+10FC0h], xmm0
0000000180381443  8B 83 F0 0F 01 00           mov     eax, [rbx+10FF0h]
0000000180381449  89 83 00 10 01 00           mov     [rbx+11000h], eax
000000018038144F  F3 0F 59 8B D0 0F 01 00     mulss   xmm1, dword ptr [rbx+10FD0h]
0000000180381457  F3 0F 59 83 E0 0F 01 00     mulss   xmm0, dword ptr [rbx+10FE0h]
000000018038145F  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180381463  F3 0F 11 83 F0 0F 01 00     movss   dword ptr [rbx+10FF0h], xmm0
000000018038146B  8B 83 10 10 01 00           mov     eax, [rbx+11010h]
0000000180381471  89 83 20 10 01 00           mov     [rbx+11020h], eax
0000000180381477  8B 83 30 10 01 00           mov     eax, [rbx+11030h]
000000018038147D  89 83 40 10 01 00           mov     [rbx+11040h], eax
0000000180381483  8B 83 50 10 01 00           mov     eax, [rbx+11050h]
0000000180381489  89 83 60 10 01 00           mov     [rbx+11060h], eax
000000018038148F  8B 83 70 10 01 00           mov     eax, [rbx+11070h]
0000000180381495  89 83 80 10 01 00           mov     [rbx+11080h], eax
000000018038149B  F3 0F 10 8B A0 10 01 00     movss   xmm1, dword ptr [rbx+110A0h]
00000001803814A3  F3 0F 10 93 B0 10 01 00     movss   xmm2, dword ptr [rbx+110B0h]
00000001803814AB  0F 28 E1                    movaps  xmm4, xmm1
00000001803814AE  F3 0F 59 A3 10 10 01 00     mulss   xmm4, dword ptr [rbx+11010h]
00000001803814B6  0F 28 C2                    movaps  xmm0, xmm2
00000001803814B9  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803814BD  F3 0F 5C E0                 subss   xmm4, xmm0
00000001803814C1  F3 0F 58 E2                 addss   xmm4, xmm2
00000001803814C5  0F 28 DC                    movaps  xmm3, xmm4
00000001803814C8  0F 28 CC                    movaps  xmm1, xmm4
00000001803814CB  F3 0F 59 8B D0 10 01 00     mulss   xmm1, dword ptr [rbx+110D0h]
00000001803814D3  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803814D7  F3 0F 58 8B C0 10 01 00     addss   xmm1, dword ptr [rbx+110C0h]
00000001803814DF  0F 28 C3                    movaps  xmm0, xmm3
00000001803814E2  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803814E6  F3 0F 59 83 E0 10 01 00     mulss   xmm0, dword ptr [rbx+110E0h]
00000001803814EE  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803814F2  0F 28 C3                    movaps  xmm0, xmm3
00000001803814F5  F3 0F 59 9B F0 10 01 00     mulss   xmm3, dword ptr [rbx+110F0h]
00000001803814FD  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180381501  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180381505  F3 0F 59 83 00 11 01 00     mulss   xmm0, dword ptr [rbx+11100h]
000000018038150D  F3 0F 58 C3                 addss   xmm0, xmm3
0000000180381511  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180381515  76 05                       jbe     short loc_18038151C
0000000180381517  0F 5A C0                    cvtps2pd xmm0, xmm0
000000018038151A  EB 03                       jmp     short loc_18038151F
000000018038151C  0F 57 C0                    xorps   xmm0, xmm0
000000018038151F  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
0000000180381523  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180381527  73 04                       jnb     short loc_18038152D
0000000180381529  44 0F 5A E1                 cvtps2pd xmm12, xmm1
000000018038152D  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
0000000180381532  F3 0F 11 83 90 10 01 00     movss   dword ptr [rbx+11090h], xmm0
000000018038153A  8B 83 10 11 01 00           mov     eax, [rbx+11110h]
0000000180381540  89 83 20 11 01 00           mov     [rbx+11120h], eax
0000000180381546  F3 0F 10 8B 30 11 01 00     movss   xmm1, dword ptr [rbx+11130h]
000000018038154E  F3 0F 11 8B 40 11 01 00     movss   dword ptr [rbx+11140h], xmm1
0000000180381556  F3 0F 10 83 50 11 01 00     movss   xmm0, dword ptr [rbx+11150h]
000000018038155E  F3 0F 11 83 60 11 01 00     movss   dword ptr [rbx+11160h], xmm0
0000000180381566  F3 0F 5C C8                 subss   xmm1, xmm0
000000018038156A  F3 0F 59 8B 70 11 01 00     mulss   xmm1, dword ptr [rbx+11170h]
0000000180381572  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180381576  F3 0F 11 8B 50 11 01 00     movss   dword ptr [rbx+11150h], xmm1
000000018038157E  F3 0F 10 8B 50 F9 00 00     movss   xmm1, dword ptr [rbx+0F950h]
0000000180381586  F3 0F 10 83 D0 F9 00 00     movss   xmm0, dword ptr [rbx+0F9D0h]
000000018038158E  8B 83 A0 11 01 00           mov     eax, [rbx+111A0h]
0000000180381594  89 83 B0 11 01 00           mov     [rbx+111B0h], eax
000000018038159A  F3 0F 59 83 90 11 01 00     mulss   xmm0, dword ptr [rbx+11190h]
00000001803815A2  F3 0F 59 8B 80 11 01 00     mulss   xmm1, dword ptr [rbx+11180h]
00000001803815AA  F3 0F 58 C1                 addss   xmm0, xmm1
00000001803815AE  F3 0F 11 83 A0 11 01 00     movss   dword ptr [rbx+111A0h], xmm0
00000001803815B6  8B 83 C0 11 01 00           mov     eax, [rbx+111C0h]
00000001803815BC  89 83 E0 11 01 00           mov     [rbx+111E0h], eax
00000001803815C2  F3 0F 10 9B D0 11 01 00     movss   xmm3, dword ptr [rbx+111D0h]
00000001803815CA  F3 0F 11 9B F0 11 01 00     movss   dword ptr [rbx+111F0h], xmm3
00000001803815D2  F3 0F 10 8B E0 11 01 00     movss   xmm1, dword ptr [rbx+111E0h]
00000001803815DA  F3 0F 10 93 20 01 01 00     movss   xmm2, dword ptr [rbx+10120h]
00000001803815E2  0F 28 C1                    movaps  xmm0, xmm1
00000001803815E5  F3 0F 59 83 00 03 01 00     mulss   xmm0, dword ptr [rbx+10300h]
00000001803815ED  F3 0F 59 CA                 mulss   xmm1, xmm2
00000001803815F1  F3 0F 5C C1                 subss   xmm0, xmm1
00000001803815F5  0F 28 CB                    movaps  xmm1, xmm3
00000001803815F8  F3 0F 59 8B 50 10 01 00     mulss   xmm1, dword ptr [rbx+11050h]
0000000180381600  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180381604  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180381608  F3 0F 5C CB                 subss   xmm1, xmm3
000000018038160C  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180381610  F3 0F 11 8B 00 12 01 00     movss   dword ptr [rbx+11200h], xmm1
0000000180381618  F3 0F 10 9B 60 FD 00 00     movss   xmm3, dword ptr [rbx+0FD60h]
0000000180381620  F3 0F 10 83 10 12 01 00     movss   xmm0, dword ptr [rbx+11210h]
0000000180381628  F3 0F 11 83 20 12 01 00     movss   dword ptr [rbx+11220h], xmm0
0000000180381630  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180381634  0F 28 CB                    movaps  xmm1, xmm3
0000000180381637  F3 0F 59 8B 30 12 01 00     mulss   xmm1, dword ptr [rbx+11230h]
000000018038163F  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180381643  F3 0F 10 83 50 12 01 00     movss   xmm0, dword ptr [rbx+11250h]
000000018038164B  F3 0F 11 8B 10 12 01 00     movss   dword ptr [rbx+11210h], xmm1
0000000180381653  F3 0F 59 9B 40 12 01 00     mulss   xmm3, dword ptr [rbx+11240h]
000000018038165B  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018038165F  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180381663  F3 0F 11 9B 20 12 01 00     movss   dword ptr [rbx+11220h], xmm3
000000018038166B  F3 0F 10 83 60 12 01 00     movss   xmm0, dword ptr [rbx+11260h]
0000000180381673  F3 0F 10 BB 70 FD 00 00     movss   xmm7, dword ptr [rbx+0FD70h]
000000018038167B  F3 0F 11 83 70 12 01 00     movss   dword ptr [rbx+11270h], xmm0
0000000180381683  F3 0F 5C F8                 subss   xmm7, xmm0
0000000180381687  0F 28 CF                    movaps  xmm1, xmm7
000000018038168A  F3 0F 59 8B 80 12 01 00     mulss   xmm1, dword ptr [rbx+11280h]
0000000180381692  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180381696  F3 0F 10 83 A0 12 01 00     movss   xmm0, dword ptr [rbx+112A0h]
000000018038169E  F3 0F 11 8B 60 12 01 00     movss   dword ptr [rbx+11260h], xmm1
00000001803816A6  F3 0F 59 BB 90 12 01 00     mulss   xmm7, dword ptr [rbx+11290h]
00000001803816AE  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803816B2  F3 0F 58 F8                 addss   xmm7, xmm0
00000001803816B6  F3 0F 11 BB 70 12 01 00     movss   dword ptr [rbx+11270h], xmm7
00000001803816BE  F3 0F 10 A3 20 12 01 00     movss   xmm4, dword ptr [rbx+11220h]
00000001803816C6  F3 0F 10 AB 00 12 01 00     movss   xmm5, dword ptr [rbx+11200h]
00000001803816CE  F3 0F 10 B3 A0 11 01 00     movss   xmm6, dword ptr [rbx+111A0h]
00000001803816D6  F3 44 0F 10 8B 30 10 01 00  movss   xmm9, dword ptr [rbx+11030h]
00000001803816DF  8B 83 50 11 01 00           mov     eax, [rbx+11150h]
00000001803816E5  89 83 B0 12 01 00           mov     [rbx+112B0h], eax
00000001803816EB  F3 44 0F 11 8B C0 12 01 00  movss   dword ptr [rbx+112C0h], xmm9
00000001803816F4  F3 0F 10 83 E0 12 01 00     movss   xmm0, dword ptr [rbx+112E0h]
00000001803816FC  F3 0F 10 93 F0 12 01 00     movss   xmm2, dword ptr [rbx+112F0h]
0000000180381704  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180381708  0F 28 DA                    movaps  xmm3, xmm2
000000018038170B  F3 0F 59 9B 70 10 01 00     mulss   xmm3, dword ptr [rbx+11070h]
0000000180381713  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180381717  0F 28 C2                    movaps  xmm0, xmm2
000000018038171A  F3 0F 59 C7                 mulss   xmm0, xmm7
000000018038171E  44 0F 28 C3                 movaps  xmm8, xmm3
0000000180381722  F3 44 0F 5C C0              subss   xmm8, xmm0
0000000180381727  F3 44 0F 58 C7              addss   xmm8, xmm7
000000018038172C  F3 44 0F 59 83 20 13 01 00  mulss   xmm8, dword ptr [rbx+11320h]
0000000180381735  F3 0F 10 8B 00 13 01 00     movss   xmm1, dword ptr [rbx+11300h]
000000018038173D  F3 0F 58 B3 A0 13 01 00     addss   xmm6, dword ptr [rbx+113A0h]
0000000180381745  F3 44 0F 59 83 30 13 01 00  mulss   xmm8, dword ptr [rbx+11330h]
000000018038174E  F3 0F 59 AB 40 13 01 00     mulss   xmm5, dword ptr [rbx+11340h]
0000000180381756  F3 0F 59 B3 50 13 01 00     mulss   xmm6, dword ptr [rbx+11350h]
000000018038175E  F3 44 0F 59 C9              mulss   xmm9, xmm1
0000000180381763  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180381767  F3 0F 58 F5                 addss   xmm6, xmm5
000000018038176B  F3 0F 5C DA                 subss   xmm3, xmm2
000000018038176F  F3 0F 10 93 80 13 01 00     movss   xmm2, dword ptr [rbx+11380h]
0000000180381777  0F 28 C2                    movaps  xmm0, xmm2
000000018038177A  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018038177E  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180381782  F3 44 0F 5C C8              subss   xmm9, xmm0
0000000180381787  F3 0F 10 83 70 13 01 00     movss   xmm0, dword ptr [rbx+11370h]
000000018038178F  F3 0F 58 83 B0 12 01 00     addss   xmm0, dword ptr [rbx+112B0h]
0000000180381797  F3 0F 59 9B 10 13 01 00     mulss   xmm3, dword ptr [rbx+11310h]
000000018038179F  F3 0F 59 83 B0 13 01 00     mulss   xmm0, dword ptr [rbx+113B0h]
00000001803817A7  F3 44 0F 58 CA              addss   xmm9, xmm2
00000001803817AC  F3 44 0F 58 C3              addss   xmm8, xmm3
00000001803817B1  F3 0F 59 83 60 13 01 00     mulss   xmm0, dword ptr [rbx+11360h]
00000001803817B9  F3 44 0F 59 8B 90 13 01 00  mulss   xmm9, dword ptr [rbx+11390h]
00000001803817C2  F3 44 0F 58 C6              addss   xmm8, xmm6
00000001803817C7  F3 44 0F 58 C8              addss   xmm9, xmm0
00000001803817CC  F3 45 0F 58 C8              addss   xmm9, xmm8
00000001803817D1  F3 44 0F 11 8B D0 12 01 00  movss   dword ptr [rbx+112D0h], xmm9
00000001803817DA  F3 0F 10 BB 90 10 01 00     movss   xmm7, dword ptr [rbx+11090h]
00000001803817E2  F3 44 0F 10 83 20 11 01 00  movss   xmm8, dword ptr [rbx+11120h]
00000001803817EB  8B 83 F0 13 01 00           mov     eax, [rbx+113F0h]
00000001803817F1  89 83 00 14 01 00           mov     [rbx+11400h], eax
00000001803817F7  F3 0F 10 83 E0 13 01 00     movss   xmm0, dword ptr [rbx+113E0h]
00000001803817FF  F3 0F 11 83 F0 13 01 00     movss   dword ptr [rbx+113F0h], xmm0
0000000180381807  44 0F 2E AB 30 14 01 00     ucomiss xmm13, dword ptr [rbx+11430h]
000000018038180F  0F 85 8F 02 00 00           jnz     loc_180381AA4
0000000180381815  F3 0F 10 8B 80 14 01 00     movss   xmm1, dword ptr [rbx+11480h]
000000018038181D  F3 0F 10 B3 00 14 01 00     movss   xmm6, dword ptr [rbx+11400h]
0000000180381825  0F 28 D1                    movaps  xmm2, xmm1
0000000180381828  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018038182C  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180381830  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180381834  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180381838  F3 0F 58 F2                 addss   xmm6, xmm2
000000018038183C  F3 0F 11 B3 F0 13 01 00     movss   dword ptr [rbx+113F0h], xmm6
0000000180381844  F3 0F 59 B3 70 14 01 00     mulss   xmm6, dword ptr [rbx+11470h]
000000018038184C  F3 0F 58 B3 10 14 01 00     addss   xmm6, dword ptr [rbx+11410h]
0000000180381854  E8 07 75 FE FF              call    sub_180368D60
0000000180381859  F3 0F 11 83 E0 13 01 00     movss   dword ptr [rbx+113E0h], xmm0
0000000180381861  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180381865  F3 0F 59 8B D0 14 01 00     mulss   xmm1, dword ptr [rbx+114D0h]
000000018038186D  41 0F 28 D5                 movaps  xmm2, xmm13
0000000180381871  F3 41 0F 5C D0              subss   xmm2, xmm8
0000000180381876  F3 0F 58 8B 20 14 01 00     addss   xmm1, dword ptr [rbx+11420h]
000000018038187E  F3 0F 59 93 90 14 01 00     mulss   xmm2, dword ptr [rbx+11490h]
0000000180381886  F3 0F 11 8B D0 13 01 00     movss   dword ptr [rbx+113D0h], xmm1
000000018038188E  F3 44 0F 59 8B 60 14 01 00  mulss   xmm9, dword ptr [rbx+11460h]
0000000180381897  F3 0F 59 BB 40 14 01 00     mulss   xmm7, dword ptr [rbx+11440h]
000000018038189F  F3 0F 10 83 A0 14 01 00     movss   xmm0, dword ptr [rbx+114A0h]
00000001803818A7  F3 0F 5D C2                 minss   xmm0, xmm2
00000001803818AB  F3 44 0F 58 CF              addss   xmm9, xmm7
00000001803818B0  F3 44 0F 58 CE              addss   xmm9, xmm6
00000001803818B5  F3 44 0F 58 C8              addss   xmm9, xmm0
00000001803818BA  F3 44 0F 58 8B 50 14 01 00  addss   xmm9, dword ptr [rbx+11450h]
00000001803818C3  F3 44 0F 5D 8B B0 14 01 00  minss   xmm9, dword ptr [rbx+114B0h]
00000001803818CC  F3 44 0F 5F 8B C0 14 01 00  maxss   xmm9, dword ptr [rbx+114C0h]
00000001803818D5  F3 44 0F 59 8B F0 14 01 00  mulss   xmm9, dword ptr [rbx+114F0h]
00000001803818DE  F3 44 0F 58 8B 00 15 01 00  addss   xmm9, dword ptr [rbx+11500h]
00000001803818E7  41 0F 28 C9                 movaps  xmm1, xmm9
00000001803818EB  F3 0F 2C C9                 cvttss2si ecx, xmm1
00000001803818EF  81 F9 00 00 00 80           cmp     ecx, 80000000h
00000001803818F5  74 1E                       jz      short loc_180381915
00000001803818F7  66 0F 6E C1                 movd    xmm0, ecx
00000001803818FB  0F 5B C0                    cvtdq2ps xmm0, xmm0
00000001803818FE  0F 2E C1                    ucomiss xmm0, xmm1
0000000180381901  74 12                       jz      short loc_180381915
0000000180381903  0F 14 C9                    unpcklps xmm1, xmm1
0000000180381906  0F 50 C1                    movmskps eax, xmm1
0000000180381909  83 E0 01                    and     eax, 1
000000018038190C  2B C8                       sub     ecx, eax
000000018038190E  66 0F 6E C9                 movd    xmm1, ecx
0000000180381912  0F 5B C9                    cvtdq2ps xmm1, xmm1
0000000180381915  F3 44 0F 5C C9              subss   xmm9, xmm1
000000018038191A  0F 28 C1                    movaps  xmm0, xmm1; X
000000018038191D  41 0F 28 F1                 movaps  xmm6, xmm9
0000000180381921  F3 41 0F 59 F1              mulss   xmm6, xmm9
0000000180381926  F3 0F 59 35 A2 36 76 00     mulss   xmm6, cs:dword_180AE4FD0
000000018038192E  E8 0D DE 36 00              call    expf
0000000180381933  0F 28 E0                    movaps  xmm4, xmm0
0000000180381936  41 0F 28 D1                 movaps  xmm2, xmm9
000000018038193A  F3 0F 59 93 C0 15 01 00     mulss   xmm2, dword ptr [rbx+115C0h]
0000000180381942  41 0F 28 C9                 movaps  xmm1, xmm9
0000000180381946  F3 0F 59 8B A0 15 01 00     mulss   xmm1, dword ptr [rbx+115A0h]
000000018038194E  41 0F 28 C1                 movaps  xmm0, xmm9
0000000180381952  F3 0F 58 93 B0 15 01 00     addss   xmm2, dword ptr [rbx+115B0h]
000000018038195A  F3 0F 59 83 80 15 01 00     mulss   xmm0, dword ptr [rbx+11580h]
0000000180381962  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180381966  F3 0F 58 D1                 addss   xmm2, xmm1
000000018038196A  F3 0F 58 93 90 15 01 00     addss   xmm2, dword ptr [rbx+11590h]
0000000180381972  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180381976  F3 0F 58 D0                 addss   xmm2, xmm0
000000018038197A  41 0F 28 C1                 movaps  xmm0, xmm9
000000018038197E  F3 0F 59 83 60 15 01 00     mulss   xmm0, dword ptr [rbx+11560h]
0000000180381986  F3 0F 58 93 70 15 01 00     addss   xmm2, dword ptr [rbx+11570h]
000000018038198E  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180381992  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180381996  41 0F 28 C1                 movaps  xmm0, xmm9
000000018038199A  F3 0F 59 83 40 15 01 00     mulss   xmm0, dword ptr [rbx+11540h]
00000001803819A2  F3 44 0F 59 8B 20 15 01 00  mulss   xmm9, dword ptr [rbx+11520h]
00000001803819AB  F3 0F 58 93 50 15 01 00     addss   xmm2, dword ptr [rbx+11550h]
00000001803819B3  F3 0F 59 D6                 mulss   xmm2, xmm6
00000001803819B7  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803819BB  F3 0F 58 93 30 15 01 00     addss   xmm2, dword ptr [rbx+11530h]
00000001803819C3  F3 0F 59 D6                 mulss   xmm2, xmm6
00000001803819C7  F3 41 0F 58 D1              addss   xmm2, xmm9
00000001803819CC  F3 41 0F 58 D5              addss   xmm2, xmm13
00000001803819D1  F3 0F 59 E2                 mulss   xmm4, xmm2
00000001803819D5  F3 0F 59 A3 10 15 01 00     mulss   xmm4, dword ptr [rbx+11510h]
00000001803819DD  0F 28 DC                    movaps  xmm3, xmm4
00000001803819E0  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803819E4  0F 28 CB                    movaps  xmm1, xmm3
00000001803819E7  44 0F 28 C3                 movaps  xmm8, xmm3
00000001803819EB  F3 44 0F 59 83 60 16 01 00  mulss   xmm8, dword ptr [rbx+11660h]
00000001803819F4  0F 28 C3                    movaps  xmm0, xmm3
00000001803819F7  F3 0F 59 83 20 16 01 00     mulss   xmm0, dword ptr [rbx+11620h]
00000001803819FF  0F 28 D3                    movaps  xmm2, xmm3
0000000180381A02  F3 44 0F 58 83 40 16 01 00  addss   xmm8, dword ptr [rbx+11640h]
0000000180381A0B  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180381A0F  F3 0F 58 83 00 16 01 00     addss   xmm0, dword ptr [rbx+11600h]
0000000180381A17  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180381A1B  F3 44 0F 59 C2              mulss   xmm8, xmm2
0000000180381A20  F3 44 0F 58 C0              addss   xmm8, xmm0
0000000180381A25  0F 28 C1                    movaps  xmm0, xmm1
0000000180381A28  F3 0F 59 8B E0 15 01 00     mulss   xmm1, dword ptr [rbx+115E0h]
0000000180381A30  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180381A34  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180381A39  0F 28 C3                    movaps  xmm0, xmm3
0000000180381A3C  F3 0F 59 83 10 16 01 00     mulss   xmm0, dword ptr [rbx+11610h]
0000000180381A44  F3 44 0F 58 C1              addss   xmm8, xmm1
0000000180381A49  0F 28 CB                    movaps  xmm1, xmm3
0000000180381A4C  F3 0F 59 8B 50 16 01 00     mulss   xmm1, dword ptr [rbx+11650h]
0000000180381A54  F3 0F 59 9B D0 15 01 00     mulss   xmm3, dword ptr [rbx+115D0h]
0000000180381A5C  F3 0F 58 8B 30 16 01 00     addss   xmm1, dword ptr [rbx+11630h]
0000000180381A64  F3 44 0F 58 C4              addss   xmm8, xmm4
0000000180381A69  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180381A6D  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180381A71  F3 0F 58 8B F0 15 01 00     addss   xmm1, dword ptr [rbx+115F0h]
0000000180381A79  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180381A7D  F3 0F 58 CB                 addss   xmm1, xmm3
0000000180381A81  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180381A86  F3 44 0F 5E C1              divss   xmm8, xmm1
0000000180381A8B  41 0F 28 C0                 movaps  xmm0, xmm8
0000000180381A8F  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180381A94  F3 44 0F 5E C0              divss   xmm8, xmm0
0000000180381A99  F3 44 0F 11 83 C0 13 01 00  movss   dword ptr [rbx+113C0h], xmm8
0000000180381AA2  EB 09                       jmp     short loc_180381AAD
0000000180381AA4  F3 44 0F 10 83 C0 13 01 00  movss   xmm8, dword ptr [rbx+113C0h]
0000000180381AAD  8B 83 D0 16 01 00           mov     eax, [rbx+116D0h]
0000000180381AB3  F3 0F 10 8B F0 0F 01 00     movss   xmm1, dword ptr [rbx+10FF0h]
0000000180381ABB  F3 44 0F 10 8B D0 13 01 00  movss   xmm9, dword ptr [rbx+113D0h]
0000000180381AC4  89 83 E0 16 01 00           mov     [rbx+116E0h], eax
0000000180381ACA  8B 83 C0 16 01 00           mov     eax, [rbx+116C0h]
0000000180381AD0  89 83 D0 16 01 00           mov     [rbx+116D0h], eax
0000000180381AD6  8B 83 B0 16 01 00           mov     eax, [rbx+116B0h]
0000000180381ADC  89 83 C0 16 01 00           mov     [rbx+116C0h], eax
0000000180381AE2  8B 83 A0 16 01 00           mov     eax, [rbx+116A0h]
0000000180381AE8  89 83 B0 16 01 00           mov     [rbx+116B0h], eax
0000000180381AEE  8B 83 90 16 01 00           mov     eax, [rbx+11690h]
0000000180381AF4  89 83 A0 16 01 00           mov     [rbx+116A0h], eax
0000000180381AFA  8B 83 80 16 01 00           mov     eax, [rbx+11680h]
0000000180381B00  89 83 90 16 01 00           mov     [rbx+11690h], eax
0000000180381B06  8B 83 70 16 01 00           mov     eax, [rbx+11670h]
0000000180381B0C  89 83 80 16 01 00           mov     [rbx+11680h], eax
0000000180381B12  8B 83 B0 17 01 00           mov     eax, [rbx+117B0h]
0000000180381B18  89 83 C0 17 01 00           mov     [rbx+117C0h], eax
0000000180381B1E  8B 83 A0 17 01 00           mov     eax, [rbx+117A0h]
0000000180381B24  89 83 B0 17 01 00           mov     [rbx+117B0h], eax
0000000180381B2A  8B 83 90 17 01 00           mov     eax, [rbx+11790h]
0000000180381B30  89 83 A0 17 01 00           mov     [rbx+117A0h], eax
0000000180381B36  8B 83 80 17 01 00           mov     eax, [rbx+11780h]
0000000180381B3C  89 83 90 17 01 00           mov     [rbx+11790h], eax
0000000180381B42  8B 83 70 17 01 00           mov     eax, [rbx+11770h]
0000000180381B48  89 83 80 17 01 00           mov     [rbx+11780h], eax
0000000180381B4E  8B 83 60 17 01 00           mov     eax, [rbx+11760h]
0000000180381B54  89 83 70 17 01 00           mov     [rbx+11770h], eax
0000000180381B5A  8B 83 50 17 01 00           mov     eax, [rbx+11750h]
0000000180381B60  89 83 60 17 01 00           mov     [rbx+11760h], eax
0000000180381B66  8B 83 30 18 01 00           mov     eax, [rbx+11830h]
0000000180381B6C  89 83 40 18 01 00           mov     [rbx+11840h], eax
0000000180381B72  8B 83 20 18 01 00           mov     eax, [rbx+11820h]
0000000180381B78  89 83 30 18 01 00           mov     [rbx+11830h], eax
0000000180381B7E  8B 83 10 18 01 00           mov     eax, [rbx+11810h]
0000000180381B84  89 83 20 18 01 00           mov     [rbx+11820h], eax
0000000180381B8A  8B 83 00 18 01 00           mov     eax, [rbx+11800h]
0000000180381B90  89 83 10 18 01 00           mov     [rbx+11810h], eax
0000000180381B96  8B 83 F0 17 01 00           mov     eax, [rbx+117F0h]
0000000180381B9C  89 83 00 18 01 00           mov     [rbx+11800h], eax
0000000180381BA2  8B 83 E0 17 01 00           mov     eax, [rbx+117E0h]
0000000180381BA8  89 83 F0 17 01 00           mov     [rbx+117F0h], eax
0000000180381BAE  8B 83 D0 17 01 00           mov     eax, [rbx+117D0h]
0000000180381BB4  89 83 E0 17 01 00           mov     [rbx+117E0h], eax
0000000180381BBA  8B 83 B0 18 01 00           mov     eax, [rbx+118B0h]
0000000180381BC0  89 83 C0 18 01 00           mov     [rbx+118C0h], eax
0000000180381BC6  8B 83 A0 18 01 00           mov     eax, [rbx+118A0h]
0000000180381BCC  89 83 B0 18 01 00           mov     [rbx+118B0h], eax
0000000180381BD2  8B 83 90 18 01 00           mov     eax, [rbx+11890h]
0000000180381BD8  89 83 A0 18 01 00           mov     [rbx+118A0h], eax
0000000180381BDE  8B 83 80 18 01 00           mov     eax, [rbx+11880h]
0000000180381BE4  89 83 90 18 01 00           mov     [rbx+11890h], eax
0000000180381BEA  8B 83 70 18 01 00           mov     eax, [rbx+11870h]
0000000180381BF0  89 83 80 18 01 00           mov     [rbx+11880h], eax
0000000180381BF6  8B 83 60 18 01 00           mov     eax, [rbx+11860h]
0000000180381BFC  89 83 70 18 01 00           mov     [rbx+11870h], eax
0000000180381C02  8B 83 50 18 01 00           mov     eax, [rbx+11850h]
0000000180381C08  89 83 60 18 01 00           mov     [rbx+11860h], eax
0000000180381C0E  8B 83 30 19 01 00           mov     eax, [rbx+11930h]
0000000180381C14  89 83 40 19 01 00           mov     [rbx+11940h], eax
0000000180381C1A  8B 83 20 19 01 00           mov     eax, [rbx+11920h]
0000000180381C20  89 83 30 19 01 00           mov     [rbx+11930h], eax
0000000180381C26  8B 83 10 19 01 00           mov     eax, [rbx+11910h]
0000000180381C2C  89 83 20 19 01 00           mov     [rbx+11920h], eax
0000000180381C32  8B 83 00 19 01 00           mov     eax, [rbx+11900h]
0000000180381C38  89 83 10 19 01 00           mov     [rbx+11910h], eax
0000000180381C3E  8B 83 F0 18 01 00           mov     eax, [rbx+118F0h]
0000000180381C44  89 83 00 19 01 00           mov     [rbx+11900h], eax
0000000180381C4A  8B 83 E0 18 01 00           mov     eax, [rbx+118E0h]
0000000180381C50  89 83 F0 18 01 00           mov     [rbx+118F0h], eax
0000000180381C56  8B 83 D0 18 01 00           mov     eax, [rbx+118D0h]
0000000180381C5C  89 83 E0 18 01 00           mov     [rbx+118E0h], eax
0000000180381C62  8B 83 50 19 01 00           mov     eax, [rbx+11950h]
0000000180381C68  89 83 60 19 01 00           mov     [rbx+11960h], eax
0000000180381C6E  F3 0F 10 83 70 19 01 00     movss   xmm0, dword ptr [rbx+11970h]
0000000180381C76  F3 0F 11 83 80 19 01 00     movss   dword ptr [rbx+11980h], xmm0
0000000180381C7E  44 0F 2E AB C0 19 01 00     ucomiss xmm13, dword ptr [rbx+119C0h]
0000000180381C86  0F 85 49 09 00 00           jnz     loc_1803825D5
0000000180381C8C  F3 0F 59 8B 10 1A 01 00     mulss   xmm1, dword ptr [rbx+11A10h]
0000000180381C94  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180381C98  41 0F 28 F1                 movaps  xmm6, xmm9
0000000180381C9C  41 0F 28 F8                 movaps  xmm7, xmm8
0000000180381CA0  F3 0F 59 B3 30 1A 01 00     mulss   xmm6, dword ptr [rbx+11A30h]
0000000180381CA8  F3 41 0F 59 F8              mulss   xmm7, xmm8
0000000180381CAD  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180381CB2  F3 0F 59 F1                 mulss   xmm6, xmm1
0000000180381CB6  0F 28 C8                    movaps  xmm1, xmm0
0000000180381CB9  F3 0F 59 8B 00 1A 01 00     mulss   xmm1, dword ptr [rbx+11A00h]
0000000180381CC1  F3 0F 58 F1                 addss   xmm6, xmm1
0000000180381CC5  E8 96 70 FE FF              call    sub_180368D60
0000000180381CCA  F3 0F 11 83 70 19 01 00     movss   dword ptr [rbx+11970h], xmm0
0000000180381CD2  41 0F 28 DD                 movaps  xmm3, xmm13
0000000180381CD6  F3 0F 11 B3 50 19 01 00     movss   dword ptr [rbx+11950h], xmm6
0000000180381CDE  41 0F 28 C0                 movaps  xmm0, xmm8
0000000180381CE2  F3 0F 59 FF                 mulss   xmm7, xmm7
0000000180381CE6  F3 41 0F 58 C0              addss   xmm0, xmm8
0000000180381CEB  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180381CEF  F3 41 0F 59 F9              mulss   xmm7, xmm9
0000000180381CF4  F3 0F 5C F0                 subss   xmm6, xmm0
0000000180381CF8  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180381CFD  F3 0F 5E DF                 divss   xmm3, xmm7
0000000180381D01  F3 0F 11 9B A0 19 01 00     movss   dword ptr [rbx+119A0h], xmm3
0000000180381D09  0F 28 E3                    movaps  xmm4, xmm3
0000000180381D0C  F3 0F 10 8B 50 19 01 00     movss   xmm1, dword ptr [rbx+11950h]
0000000180381D14  F3 0F 10 AB 60 19 01 00     movss   xmm5, dword ptr [rbx+11960h]
0000000180381D1C  F3 41 0F 59 E1              mulss   xmm4, xmm9
0000000180381D21  F3 0F 11 A3 90 19 01 00     movss   dword ptr [rbx+11990h], xmm4
0000000180381D29  F3 0F 59 AB 60 1A 01 00     mulss   xmm5, dword ptr [rbx+11A60h]
0000000180381D31  F3 0F 10 93 D0 16 01 00     movss   xmm2, dword ptr [rbx+116D0h]
0000000180381D39  F3 0F 59 8B 70 1A 01 00     mulss   xmm1, dword ptr [rbx+11A70h]
0000000180381D41  F3 0F 10 83 E0 16 01 00     movss   xmm0, dword ptr [rbx+116E0h]
0000000180381D49  F3 0F 11 93 40 17 01 00     movss   dword ptr [rbx+11740h], xmm2
0000000180381D51  F3 0F 59 93 90 1B 01 00     mulss   xmm2, dword ptr [rbx+11B90h]
0000000180381D59  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180381D5D  F3 0F 59 83 A0 1B 01 00     mulss   xmm0, dword ptr [rbx+11BA0h]
0000000180381D65  F3 0F 59 EB                 mulss   xmm5, xmm3
0000000180381D69  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180381D6D  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180381D71  F3 0F 5C EA                 subss   xmm5, xmm2
0000000180381D75  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180381D79  73 06                       jnb     short loc_180381D81
0000000180381D7B  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180381D7F  EB 05                       jmp     short loc_180381D86
0000000180381D81  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180381D86  0F 28 CD                    movaps  xmm1, xmm5
0000000180381D89  0F 28 C5                    movaps  xmm0, xmm5
0000000180381D8C  F3 0F 59 83 40 1A 01 00     mulss   xmm0, dword ptr [rbx+11A40h]
0000000180381D94  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180381D98  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180381D9C  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180381DA0  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180381DA4  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180381DA8  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180381DAC  F3 0F 11 AB F0 16 01 00     movss   dword ptr [rbx+116F0h], xmm5
0000000180381DB4  0F 28 D5                    movaps  xmm2, xmm5
0000000180381DB7  F3 0F 58 AB 80 16 01 00     addss   xmm5, dword ptr [rbx+11680h]
0000000180381DBF  F3 0F 10 9B 90 16 01 00     movss   xmm3, dword ptr [rbx+11690h]
0000000180381DC7  0F 28 C3                    movaps  xmm0, xmm3
0000000180381DCA  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180381DCE  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180381DD2  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180381DD6  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180381DDA  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180381DDE  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180381DE2  0F 28 C6                    movaps  xmm0, xmm6
0000000180381DE5  F3 0F 11 A3 00 17 01 00     movss   dword ptr [rbx+11700h], xmm4
0000000180381DED  F3 0F 10 8B A0 16 01 00     movss   xmm1, dword ptr [rbx+116A0h]
0000000180381DF5  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180381DF9  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180381DFD  0F 28 C1                    movaps  xmm0, xmm1
0000000180381E00  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180381E04  F3 0F 58 EC                 addss   xmm5, xmm4
0000000180381E08  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180381E0C  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180381E10  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180381E14  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180381E18  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180381E1C  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180381E20  0F 28 C6                    movaps  xmm0, xmm6
0000000180381E23  F3 0F 11 9B 10 17 01 00     movss   dword ptr [rbx+11710h], xmm3
0000000180381E2B  F3 0F 10 AB B0 16 01 00     movss   xmm5, dword ptr [rbx+116B0h]
0000000180381E33  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180381E37  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180381E3B  0F 28 C5                    movaps  xmm0, xmm5
0000000180381E3E  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180381E42  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180381E46  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180381E4A  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180381E4E  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180381E52  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180381E56  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180381E5A  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180381E5E  0F 28 C6                    movaps  xmm0, xmm6
0000000180381E61  F3 0F 11 93 20 17 01 00     movss   dword ptr [rbx+11720h], xmm2
0000000180381E69  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180381E6D  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180381E71  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180381E75  F3 41 0F 59 E8              mulss   xmm5, xmm8
0000000180381E7A  0F 28 C6                    movaps  xmm0, xmm6
0000000180381E7D  F3 0F 59 83 C0 16 01 00     mulss   xmm0, dword ptr [rbx+116C0h]
0000000180381E85  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180381E89  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180381E8D  0F 28 C6                    movaps  xmm0, xmm6
0000000180381E90  F3 0F 59 E1                 mulss   xmm4, xmm1
0000000180381E94  F3 0F 11 AB 30 17 01 00     movss   dword ptr [rbx+11730h], xmm5
0000000180381E9C  F3 0F 10 93 20 17 01 00     movss   xmm2, dword ptr [rbx+11720h]
0000000180381EA4  F3 0F 59 93 E0 19 01 00     mulss   xmm2, dword ptr [rbx+119E0h]
0000000180381EAC  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180381EB0  F3 0F 59 AB F0 19 01 00     mulss   xmm5, dword ptr [rbx+119F0h]
0000000180381EB8  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180381EBC  F3 0F 10 83 D0 19 01 00     movss   xmm0, dword ptr [rbx+119D0h]
0000000180381EC4  F3 0F 59 83 10 17 01 00     mulss   xmm0, dword ptr [rbx+11710h]
0000000180381ECC  F3 0F 58 D5                 addss   xmm2, xmm5
0000000180381ED0  F3 0F 10 AB 60 19 01 00     movss   xmm5, dword ptr [rbx+11960h]
0000000180381ED8  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180381EDC  F3 0F 11 93 D0 18 01 00     movss   dword ptr [rbx+118D0h], xmm2
0000000180381EE4  F3 0F 58 AB 50 19 01 00     addss   xmm5, dword ptr [rbx+11950h]
0000000180381EEC  F3 0F 10 83 40 17 01 00     movss   xmm0, dword ptr [rbx+11740h]
0000000180381EF4  F3 0F 59 AB 80 1A 01 00     mulss   xmm5, dword ptr [rbx+11A80h]
0000000180381EFC  F3 0F 59 AB A0 19 01 00     mulss   xmm5, dword ptr [rbx+119A0h]
0000000180381F04  F3 0F 11 A3 40 17 01 00     movss   dword ptr [rbx+11740h], xmm4
0000000180381F0C  F3 0F 59 A3 90 1B 01 00     mulss   xmm4, dword ptr [rbx+11B90h]
0000000180381F14  F3 0F 59 83 A0 1B 01 00     mulss   xmm0, dword ptr [rbx+11BA0h]
0000000180381F1C  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180381F20  F3 0F 59 A3 90 19 01 00     mulss   xmm4, dword ptr [rbx+11990h]
0000000180381F28  F3 0F 5C EC                 subss   xmm5, xmm4
0000000180381F2C  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180381F30  73 06                       jnb     short loc_180381F38
0000000180381F32  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180381F36  EB 05                       jmp     short loc_180381F3D
0000000180381F38  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180381F3D  0F 28 CD                    movaps  xmm1, xmm5
0000000180381F40  0F 28 C5                    movaps  xmm0, xmm5
0000000180381F43  F3 0F 59 83 40 1A 01 00     mulss   xmm0, dword ptr [rbx+11A40h]
0000000180381F4B  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180381F4F  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180381F53  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180381F57  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180381F5B  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180381F5F  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180381F63  F3 0F 10 8B F0 16 01 00     movss   xmm1, dword ptr [rbx+116F0h]
0000000180381F6B  F3 0F 11 AB F0 16 01 00     movss   dword ptr [rbx+116F0h], xmm5
0000000180381F73  0F 28 D5                    movaps  xmm2, xmm5
0000000180381F76  F3 0F 10 9B 00 17 01 00     movss   xmm3, dword ptr [rbx+11700h]
0000000180381F7E  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180381F82  0F 28 C3                    movaps  xmm0, xmm3
0000000180381F85  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180381F89  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180381F8D  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180381F91  F3 0F 59 EA                 mulss   xmm5, xmm2
0000000180381F95  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180381F99  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180381F9D  0F 28 C6                    movaps  xmm0, xmm6
0000000180381FA0  F3 0F 11 A3 00 17 01 00     movss   dword ptr [rbx+11700h], xmm4
0000000180381FA8  F3 0F 10 8B 10 17 01 00     movss   xmm1, dword ptr [rbx+11710h]
0000000180381FB0  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180381FB4  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180381FB8  0F 28 C1                    movaps  xmm0, xmm1
0000000180381FBB  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180381FBF  F3 0F 58 EC                 addss   xmm5, xmm4
0000000180381FC3  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180381FC7  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180381FCB  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180381FCF  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180381FD3  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180381FD7  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180381FDB  0F 28 C6                    movaps  xmm0, xmm6
0000000180381FDE  F3 0F 11 9B 10 17 01 00     movss   dword ptr [rbx+11710h], xmm3
0000000180381FE6  F3 0F 10 AB 20 17 01 00     movss   xmm5, dword ptr [rbx+11720h]
0000000180381FEE  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180381FF2  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180381FF6  0F 28 C5                    movaps  xmm0, xmm5
0000000180381FF9  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180381FFD  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180382001  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180382005  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180382009  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018038200D  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180382011  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180382015  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180382019  0F 28 C6                    movaps  xmm0, xmm6
000000018038201C  F3 0F 11 93 20 17 01 00     movss   dword ptr [rbx+11720h], xmm2
0000000180382024  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180382028  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038202C  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180382030  F3 41 0F 59 E8              mulss   xmm5, xmm8
0000000180382035  0F 28 C6                    movaps  xmm0, xmm6
0000000180382038  F3 0F 59 83 30 17 01 00     mulss   xmm0, dword ptr [rbx+11730h]
0000000180382040  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180382044  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180382048  0F 28 C6                    movaps  xmm0, xmm6
000000018038204B  F3 0F 59 E1                 mulss   xmm4, xmm1
000000018038204F  F3 0F 11 AB 30 17 01 00     movss   dword ptr [rbx+11730h], xmm5
0000000180382057  F3 0F 10 93 20 17 01 00     movss   xmm2, dword ptr [rbx+11720h]
000000018038205F  F3 0F 59 93 E0 19 01 00     mulss   xmm2, dword ptr [rbx+119E0h]
0000000180382067  F3 0F 10 8B 50 19 01 00     movss   xmm1, dword ptr [rbx+11950h]
000000018038206F  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180382073  F3 0F 59 AB F0 19 01 00     mulss   xmm5, dword ptr [rbx+119F0h]
000000018038207B  F3 0F 58 E0                 addss   xmm4, xmm0
000000018038207F  F3 0F 10 83 D0 19 01 00     movss   xmm0, dword ptr [rbx+119D0h]
0000000180382087  F3 0F 59 83 10 17 01 00     mulss   xmm0, dword ptr [rbx+11710h]
000000018038208F  F3 0F 58 D5                 addss   xmm2, xmm5
0000000180382093  F3 0F 10 AB 60 19 01 00     movss   xmm5, dword ptr [rbx+11960h]
000000018038209B  F3 0F 58 D0                 addss   xmm2, xmm0
000000018038209F  F3 0F 11 93 50 18 01 00     movss   dword ptr [rbx+11850h], xmm2
00000001803820A7  F3 0F 59 AB 70 1A 01 00     mulss   xmm5, dword ptr [rbx+11A70h]
00000001803820AF  F3 0F 59 8B 60 1A 01 00     mulss   xmm1, dword ptr [rbx+11A60h]
00000001803820B7  F3 0F 10 83 40 17 01 00     movss   xmm0, dword ptr [rbx+11740h]
00000001803820BF  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803820C3  F3 0F 59 AB A0 19 01 00     mulss   xmm5, dword ptr [rbx+119A0h]
00000001803820CB  F3 0F 11 A3 40 17 01 00     movss   dword ptr [rbx+11740h], xmm4
00000001803820D3  F3 0F 59 A3 90 1B 01 00     mulss   xmm4, dword ptr [rbx+11B90h]
00000001803820DB  F3 0F 59 83 A0 1B 01 00     mulss   xmm0, dword ptr [rbx+11BA0h]
00000001803820E3  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803820E7  F3 0F 59 A3 90 19 01 00     mulss   xmm4, dword ptr [rbx+11990h]
00000001803820EF  F3 0F 5C EC                 subss   xmm5, xmm4
00000001803820F3  41 0F 2F EF                 comiss  xmm5, xmm15
00000001803820F7  73 06                       jnb     short loc_1803820FF
00000001803820F9  41 0F 28 EF                 movaps  xmm5, xmm15
00000001803820FD  EB 05                       jmp     short loc_180382104
00000001803820FF  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180382104  0F 28 CD                    movaps  xmm1, xmm5
0000000180382107  0F 28 C5                    movaps  xmm0, xmm5
000000018038210A  F3 0F 59 83 40 1A 01 00     mulss   xmm0, dword ptr [rbx+11A40h]
0000000180382112  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180382116  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018038211A  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018038211E  F3 0F 59 CD                 mulss   xmm1, xmm5
0000000180382122  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180382126  F3 0F 58 E9                 addss   xmm5, xmm1
000000018038212A  F3 0F 10 8B F0 16 01 00     movss   xmm1, dword ptr [rbx+116F0h]
0000000180382132  F3 0F 11 AB F0 16 01 00     movss   dword ptr [rbx+116F0h], xmm5
000000018038213A  0F 28 D5                    movaps  xmm2, xmm5
000000018038213D  F3 0F 10 9B 00 17 01 00     movss   xmm3, dword ptr [rbx+11700h]
0000000180382145  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180382149  0F 28 C3                    movaps  xmm0, xmm3
000000018038214C  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180382150  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180382154  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180382158  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018038215C  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180382160  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180382164  0F 28 C6                    movaps  xmm0, xmm6
0000000180382167  F3 0F 11 A3 00 17 01 00     movss   dword ptr [rbx+11700h], xmm4
000000018038216F  F3 0F 10 8B 10 17 01 00     movss   xmm1, dword ptr [rbx+11710h]
0000000180382177  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018038217B  F3 0F 58 E8                 addss   xmm5, xmm0
000000018038217F  0F 28 C1                    movaps  xmm0, xmm1
0000000180382182  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180382186  F3 0F 58 EC                 addss   xmm5, xmm4
000000018038218A  F3 0F 58 E3                 addss   xmm4, xmm3
000000018038218E  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180382192  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180382196  41 0F 28 E0                 movaps  xmm4, xmm8
000000018038219A  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018038219E  F3 0F 58 D8                 addss   xmm3, xmm0
00000001803821A2  0F 28 C6                    movaps  xmm0, xmm6
00000001803821A5  F3 0F 11 9B 10 17 01 00     movss   dword ptr [rbx+11710h], xmm3
00000001803821AD  F3 0F 10 AB 20 17 01 00     movss   xmm5, dword ptr [rbx+11720h]
00000001803821B5  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803821B9  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803821BD  0F 28 C5                    movaps  xmm0, xmm5
00000001803821C0  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803821C4  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803821C8  F3 0F 58 D9                 addss   xmm3, xmm1
00000001803821CC  41 0F 28 C8                 movaps  xmm1, xmm8
00000001803821D0  F3 0F 59 CC                 mulss   xmm1, xmm4
00000001803821D4  F3 0F 59 D3                 mulss   xmm2, xmm3
00000001803821D8  41 0F 28 D8                 movaps  xmm3, xmm8
00000001803821DC  F3 0F 58 D0                 addss   xmm2, xmm0
00000001803821E0  0F 28 C6                    movaps  xmm0, xmm6
00000001803821E3  F3 0F 11 93 20 17 01 00     movss   dword ptr [rbx+11720h], xmm2
00000001803821EB  F3 0F 58 EA                 addss   xmm5, xmm2
00000001803821EF  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803821F3  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803821F7  F3 41 0F 59 E8              mulss   xmm5, xmm8
00000001803821FC  0F 28 C6                    movaps  xmm0, xmm6
00000001803821FF  F3 0F 59 83 30 17 01 00     mulss   xmm0, dword ptr [rbx+11730h]
0000000180382207  F3 0F 58 CA                 addss   xmm1, xmm2
000000018038220B  F3 0F 58 E8                 addss   xmm5, xmm0
000000018038220F  0F 28 C6                    movaps  xmm0, xmm6
0000000180382212  F3 0F 59 D9                 mulss   xmm3, xmm1
0000000180382216  F3 0F 11 AB 30 17 01 00     movss   dword ptr [rbx+11730h], xmm5
000000018038221E  F3 0F 10 8B 20 17 01 00     movss   xmm1, dword ptr [rbx+11720h]
0000000180382226  F3 0F 59 8B E0 19 01 00     mulss   xmm1, dword ptr [rbx+119E0h]
000000018038222E  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180382232  F3 0F 59 AB F0 19 01 00     mulss   xmm5, dword ptr [rbx+119F0h]
000000018038223A  F3 0F 58 D8                 addss   xmm3, xmm0
000000018038223E  F3 0F 10 83 D0 19 01 00     movss   xmm0, dword ptr [rbx+119D0h]
0000000180382246  F3 0F 59 83 10 17 01 00     mulss   xmm0, dword ptr [rbx+11710h]
000000018038224E  F3 0F 58 CD                 addss   xmm1, xmm5
0000000180382252  F3 0F 10 AB 50 19 01 00     movss   xmm5, dword ptr [rbx+11950h]
000000018038225A  F3 0F 58 C8                 addss   xmm1, xmm0
000000018038225E  F3 0F 11 8B D0 17 01 00     movss   dword ptr [rbx+117D0h], xmm1
0000000180382266  F3 0F 59 AB 50 1A 01 00     mulss   xmm5, dword ptr [rbx+11A50h]
000000018038226E  F3 0F 10 83 40 17 01 00     movss   xmm0, dword ptr [rbx+11740h]
0000000180382276  F3 0F 59 AB A0 19 01 00     mulss   xmm5, dword ptr [rbx+119A0h]
000000018038227E  F3 0F 11 9B D0 16 01 00     movss   dword ptr [rbx+116D0h], xmm3
0000000180382286  F3 0F 59 9B 90 1B 01 00     mulss   xmm3, dword ptr [rbx+11B90h]
000000018038228E  F3 0F 59 83 A0 1B 01 00     mulss   xmm0, dword ptr [rbx+11BA0h]
0000000180382296  F3 0F 58 D8                 addss   xmm3, xmm0
000000018038229A  F3 0F 59 9B 90 19 01 00     mulss   xmm3, dword ptr [rbx+11990h]
00000001803822A2  F3 0F 5C EB                 subss   xmm5, xmm3
00000001803822A6  41 0F 2F EF                 comiss  xmm5, xmm15
00000001803822AA  73 06                       jnb     short loc_1803822B2
00000001803822AC  41 0F 28 EF                 movaps  xmm5, xmm15
00000001803822B0  EB 05                       jmp     short loc_1803822B7
00000001803822B2  F3 41 0F 5D ED              minss   xmm5, xmm13
00000001803822B7  0F 28 CD                    movaps  xmm1, xmm5
00000001803822BA  0F 28 C5                    movaps  xmm0, xmm5
00000001803822BD  F3 0F 59 83 40 1A 01 00     mulss   xmm0, dword ptr [rbx+11A40h]
00000001803822C5  41 0F 28 E0                 movaps  xmm4, xmm8
00000001803822C9  F3 0F 59 CD                 mulss   xmm1, xmm5
00000001803822CD  F3 0F 59 CD                 mulss   xmm1, xmm5
00000001803822D1  F3 0F 59 CD                 mulss   xmm1, xmm5
00000001803822D5  F3 0F 59 C8                 mulss   xmm1, xmm0
00000001803822D9  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803822DD  F3 0F 11 AB 70 16 01 00     movss   dword ptr [rbx+11670h], xmm5
00000001803822E5  0F 28 D5                    movaps  xmm2, xmm5
00000001803822E8  F3 0F 58 AB F0 16 01 00     addss   xmm5, dword ptr [rbx+116F0h]
00000001803822F0  F3 0F 10 9B 00 17 01 00     movss   xmm3, dword ptr [rbx+11700h]
00000001803822F8  0F 28 C3                    movaps  xmm0, xmm3
00000001803822FB  F3 0F 59 C6                 mulss   xmm0, xmm6
00000001803822FF  F3 0F 59 E5                 mulss   xmm4, xmm5
0000000180382303  41 0F 28 E8                 movaps  xmm5, xmm8
0000000180382307  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018038230B  41 0F 28 D0                 movaps  xmm2, xmm8
000000018038230F  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180382313  0F 28 C6                    movaps  xmm0, xmm6
0000000180382316  F3 0F 11 A3 80 16 01 00     movss   dword ptr [rbx+11680h], xmm4
000000018038231E  F3 0F 10 8B 10 17 01 00     movss   xmm1, dword ptr [rbx+11710h]
0000000180382326  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018038232A  F3 0F 58 E8                 addss   xmm5, xmm0
000000018038232E  0F 28 C1                    movaps  xmm0, xmm1
0000000180382331  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180382335  F3 0F 58 EC                 addss   xmm5, xmm4
0000000180382339  F3 0F 58 E3                 addss   xmm4, xmm3
000000018038233D  41 0F 28 D8                 movaps  xmm3, xmm8
0000000180382341  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180382345  41 0F 28 E0                 movaps  xmm4, xmm8
0000000180382349  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018038234D  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180382351  0F 28 C6                    movaps  xmm0, xmm6
0000000180382354  F3 0F 11 9B 90 16 01 00     movss   dword ptr [rbx+11690h], xmm3
000000018038235C  F3 0F 10 AB 20 17 01 00     movss   xmm5, dword ptr [rbx+11720h]
0000000180382364  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180382368  F3 0F 58 E0                 addss   xmm4, xmm0
000000018038236C  0F 28 C5                    movaps  xmm0, xmm5
000000018038236F  F3 0F 59 C6                 mulss   xmm0, xmm6
0000000180382373  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180382377  F3 0F 58 D9                 addss   xmm3, xmm1
000000018038237B  41 0F 28 C8                 movaps  xmm1, xmm8
000000018038237F  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180382383  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180382387  F3 0F 58 D0                 addss   xmm2, xmm0
000000018038238B  0F 28 C6                    movaps  xmm0, xmm6
000000018038238E  F3 0F 11 93 A0 16 01 00     movss   dword ptr [rbx+116A0h], xmm2
0000000180382396  F3 0F 58 EA                 addss   xmm5, xmm2
000000018038239A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038239E  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803823A2  F3 41 0F 59 E8              mulss   xmm5, xmm8
00000001803823A7  0F 28 C6                    movaps  xmm0, xmm6
00000001803823AA  F3 0F 59 83 30 17 01 00     mulss   xmm0, dword ptr [rbx+11730h]
00000001803823B2  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803823B6  F3 0F 58 E8                 addss   xmm5, xmm0
00000001803823BA  F3 44 0F 59 C1              mulss   xmm8, xmm1
00000001803823BF  F3 0F 11 AB B0 16 01 00     movss   dword ptr [rbx+116B0h], xmm5
00000001803823C7  F3 0F 10 9B 90 16 01 00     movss   xmm3, dword ptr [rbx+11690h]
00000001803823CF  F3 0F 59 F5                 mulss   xmm6, xmm5
00000001803823D3  F3 44 0F 58 C6              addss   xmm8, xmm6
00000001803823D8  F3 44 0F 11 83 C0 16 01 00  movss   dword ptr [rbx+116C0h], xmm8
00000001803823E1  F3 0F 10 83 E0 19 01 00     movss   xmm0, dword ptr [rbx+119E0h]
00000001803823E9  F3 0F 59 83 A0 16 01 00     mulss   xmm0, dword ptr [rbx+116A0h]
00000001803823F1  F3 0F 59 AB F0 19 01 00     mulss   xmm5, dword ptr [rbx+119F0h]
00000001803823F9  F3 0F 59 9B D0 19 01 00     mulss   xmm3, dword ptr [rbx+119D0h]
0000000180382401  F3 0F 10 A3 90 17 01 00     movss   xmm4, dword ptr [rbx+11790h]
0000000180382409  F3 0F 58 E8                 addss   xmm5, xmm0
000000018038240D  F3 0F 58 EB                 addss   xmm5, xmm3
0000000180382411  F3 0F 11 AB 50 17 01 00     movss   dword ptr [rbx+11750h], xmm5
0000000180382419  F3 0F 58 A3 00 19 01 00     addss   xmm4, dword ptr [rbx+11900h]
0000000180382421  F3 0F 10 83 10 18 01 00     movss   xmm0, dword ptr [rbx+11810h]
0000000180382429  F3 0F 58 83 80 18 01 00     addss   xmm0, dword ptr [rbx+11880h]
0000000180382431  F3 0F 10 8B 90 18 01 00     movss   xmm1, dword ptr [rbx+11890h]
0000000180382439  F3 0F 58 8B 00 18 01 00     addss   xmm1, dword ptr [rbx+11800h]
0000000180382441  F3 0F 59 A3 80 1B 01 00     mulss   xmm4, dword ptr [rbx+11B80h]
0000000180382449  F3 0F 59 83 70 1B 01 00     mulss   xmm0, dword ptr [rbx+11B70h]
0000000180382451  F3 0F 59 8B 60 1B 01 00     mulss   xmm1, dword ptr [rbx+11B60h]
0000000180382459  F3 0F 58 E0                 addss   xmm4, xmm0
000000018038245D  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180382461  F3 0F 10 83 80 17 01 00     movss   xmm0, dword ptr [rbx+11780h]
0000000180382469  F3 0F 58 83 10 19 01 00     addss   xmm0, dword ptr [rbx+11910h]
0000000180382471  F3 0F 10 8B F0 18 01 00     movss   xmm1, dword ptr [rbx+118F0h]
0000000180382479  F3 0F 58 8B A0 17 01 00     addss   xmm1, dword ptr [rbx+117A0h]
0000000180382481  F3 0F 58 AB 40 19 01 00     addss   xmm5, dword ptr [rbx+11940h]
0000000180382489  F3 0F 59 83 50 1B 01 00     mulss   xmm0, dword ptr [rbx+11B50h]
0000000180382491  F3 0F 59 8B 40 1B 01 00     mulss   xmm1, dword ptr [rbx+11B40h]
0000000180382499  F3 0F 59 AB 90 1A 01 00     mulss   xmm5, dword ptr [rbx+11A90h]
00000001803824A1  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803824A5  F3 0F 10 83 70 18 01 00     movss   xmm0, dword ptr [rbx+11870h]
00000001803824AD  F3 0F 58 83 20 18 01 00     addss   xmm0, dword ptr [rbx+11820h]
00000001803824B5  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803824B9  F3 0F 10 8B A0 18 01 00     movss   xmm1, dword ptr [rbx+118A0h]
00000001803824C1  F3 0F 58 8B F0 17 01 00     addss   xmm1, dword ptr [rbx+117F0h]
00000001803824C9  F3 0F 59 83 30 1B 01 00     mulss   xmm0, dword ptr [rbx+11B30h]
00000001803824D1  F3 0F 59 8B 20 1B 01 00     mulss   xmm1, dword ptr [rbx+11B20h]
00000001803824D9  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803824DD  F3 0F 10 83 20 19 01 00     movss   xmm0, dword ptr [rbx+11920h]
00000001803824E5  F3 0F 58 83 70 17 01 00     addss   xmm0, dword ptr [rbx+11770h]
00000001803824ED  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803824F1  F3 0F 10 8B E0 18 01 00     movss   xmm1, dword ptr [rbx+118E0h]
00000001803824F9  F3 0F 59 83 10 1B 01 00     mulss   xmm0, dword ptr [rbx+11B10h]
0000000180382501  F3 0F 58 8B B0 17 01 00     addss   xmm1, dword ptr [rbx+117B0h]
0000000180382509  F3 0F 58 E0                 addss   xmm4, xmm0
000000018038250D  F3 0F 10 83 60 18 01 00     movss   xmm0, dword ptr [rbx+11860h]
0000000180382515  F3 0F 58 83 30 18 01 00     addss   xmm0, dword ptr [rbx+11830h]
000000018038251D  F3 0F 59 8B 00 1B 01 00     mulss   xmm1, dword ptr [rbx+11B00h]
0000000180382525  F3 0F 59 83 F0 1A 01 00     mulss   xmm0, dword ptr [rbx+11AF0h]
000000018038252D  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180382531  F3 0F 10 8B B0 18 01 00     movss   xmm1, dword ptr [rbx+118B0h]
0000000180382539  F3 0F 58 8B E0 17 01 00     addss   xmm1, dword ptr [rbx+117E0h]
0000000180382541  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180382545  F3 0F 10 83 30 19 01 00     movss   xmm0, dword ptr [rbx+11930h]
000000018038254D  F3 0F 59 8B E0 1A 01 00     mulss   xmm1, dword ptr [rbx+11AE0h]
0000000180382555  F3 0F 58 83 60 17 01 00     addss   xmm0, dword ptr [rbx+11760h]
000000018038255D  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180382561  F3 0F 10 8B D0 18 01 00     movss   xmm1, dword ptr [rbx+118D0h]
0000000180382569  F3 0F 58 8B C0 17 01 00     addss   xmm1, dword ptr [rbx+117C0h]
0000000180382571  F3 0F 59 83 D0 1A 01 00     mulss   xmm0, dword ptr [rbx+11AD0h]
0000000180382579  F3 0F 59 8B C0 1A 01 00     mulss   xmm1, dword ptr [rbx+11AC0h]
0000000180382581  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180382585  F3 0F 10 83 50 18 01 00     movss   xmm0, dword ptr [rbx+11850h]
000000018038258D  F3 0F 58 83 40 18 01 00     addss   xmm0, dword ptr [rbx+11840h]
0000000180382595  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180382599  F3 0F 10 8B C0 18 01 00     movss   xmm1, dword ptr [rbx+118C0h]
00000001803825A1  F3 0F 59 83 B0 1A 01 00     mulss   xmm0, dword ptr [rbx+11AB0h]
00000001803825A9  F3 0F 58 8B D0 17 01 00     addss   xmm1, dword ptr [rbx+117D0h]
00000001803825B1  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803825B5  F3 0F 59 8B A0 1A 01 00     mulss   xmm1, dword ptr [rbx+11AA0h]
00000001803825BD  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803825C1  F3 0F 58 E5                 addss   xmm4, xmm5
00000001803825C5  F3 0F 59 A3 20 1A 01 00     mulss   xmm4, dword ptr [rbx+11A20h]
00000001803825CD  F3 0F 11 A3 B0 19 01 00     movss   dword ptr [rbx+119B0h], xmm4
00000001803825D5  8B 83 B0 1B 01 00           mov     eax, [rbx+11BB0h]
00000001803825DB  89 83 C0 1B 01 00           mov     [rbx+11BC0h], eax
00000001803825E1  F3 0F 10 83 E0 1B 01 00     movss   xmm0, dword ptr [rbx+11BE0h]
00000001803825E9  8B 83 D0 1B 01 00           mov     eax, [rbx+11BD0h]
00000001803825EF  89 83 00 1C 01 00           mov     [rbx+11C00h], eax
00000001803825F5  F3 0F 11 83 10 1C 01 00     movss   dword ptr [rbx+11C10h], xmm0
00000001803825FD  8B 83 F0 1B 01 00           mov     eax, [rbx+11BF0h]
0000000180382603  89 83 20 1C 01 00           mov     [rbx+11C20h], eax
0000000180382609  F3 0F 10 93 30 1C 01 00     movss   xmm2, dword ptr [rbx+11C30h]
0000000180382611  F3 0F 11 93 40 1C 01 00     movss   dword ptr [rbx+11C40h], xmm2
0000000180382619  F3 0F 10 83 50 1C 01 00     movss   xmm0, dword ptr [rbx+11C50h]
0000000180382621  F3 0F 11 83 60 1C 01 00     movss   dword ptr [rbx+11C60h], xmm0
0000000180382629  F3 0F 5C D0                 subss   xmm2, xmm0
000000018038262D  F3 0F 59 93 70 1C 01 00     mulss   xmm2, dword ptr [rbx+11C70h]
0000000180382635  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180382639  F3 0F 11 93 50 1C 01 00     movss   dword ptr [rbx+11C50h], xmm2
0000000180382641  F3 0F 10 83 10 1C 01 00     movss   xmm0, dword ptr [rbx+11C10h]
0000000180382649  F3 0F 10 8B 20 1C 01 00     movss   xmm1, dword ptr [rbx+11C20h]
0000000180382651  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180382655  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180382659  F3 0F 5C D0                 subss   xmm2, xmm0
000000018038265D  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180382661  F3 0F 11 93 80 1C 01 00     movss   dword ptr [rbx+11C80h], xmm2
0000000180382669  F3 0F 10 8B 90 1C 01 00     movss   xmm1, dword ptr [rbx+11C90h]
0000000180382671  F3 0F 11 8B A0 1C 01 00     movss   dword ptr [rbx+11CA0h], xmm1
0000000180382679  F3 0F 10 83 B0 1C 01 00     movss   xmm0, dword ptr [rbx+11CB0h]
0000000180382681  0F 28 D8                    movaps  xmm3, xmm0
0000000180382684  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180382688  F3 0F 59 DA                 mulss   xmm3, xmm2
000000018038268C  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180382690  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180382694  41 0F 2F DE                 comiss  xmm3, xmm14
0000000180382698  76 05                       jbe     short loc_18038269F
000000018038269A  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018038269D  EB 03                       jmp     short loc_1803826A2
000000018038269F  0F 57 C0                    xorps   xmm0, xmm0
00000001803826A2  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00000001803826A6  F3 0F 11 83 90 1C 01 00     movss   dword ptr [rbx+11C90h], xmm0
00000001803826AE  F3 0F 10 8B C0 1C 01 00     movss   xmm1, dword ptr [rbx+11CC0h]
00000001803826B6  F3 0F 11 8B D0 1C 01 00     movss   dword ptr [rbx+11CD0h], xmm1
00000001803826BE  F3 0F 10 93 E0 1C 01 00     movss   xmm2, dword ptr [rbx+11CE0h]
00000001803826C6  F3 0F 11 93 F0 1C 01 00     movss   dword ptr [rbx+11CF0h], xmm2
00000001803826CE  F3 0F 10 83 00 1D 01 00     movss   xmm0, dword ptr [rbx+11D00h]
00000001803826D6  0F 28 D8                    movaps  xmm3, xmm0
00000001803826D9  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803826DD  F3 0F 59 D9                 mulss   xmm3, xmm1
00000001803826E1  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803826E5  F3 0F 58 DA                 addss   xmm3, xmm2
00000001803826E9  41 0F 2F DE                 comiss  xmm3, xmm14
00000001803826ED  76 05                       jbe     short loc_1803826F4
00000001803826EF  0F 5A C3                    cvtps2pd xmm0, xmm3
00000001803826F2  EB 03                       jmp     short loc_1803826F7
00000001803826F4  0F 57 C0                    xorps   xmm0, xmm0
00000001803826F7  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00000001803826FB  F3 0F 11 83 E0 1C 01 00     movss   dword ptr [rbx+11CE0h], xmm0
0000000180382703  F3 0F 10 AB 10 1D 01 00     movss   xmm5, dword ptr [rbx+11D10h]
000000018038270B  F3 0F 10 B3 90 F8 00 00     movss   xmm6, dword ptr [rbx+0F890h]
0000000180382713  0F 28 E5                    movaps  xmm4, xmm5
0000000180382716  F3 0F 11 AB 20 1D 01 00     movss   dword ptr [rbx+11D20h], xmm5
000000018038271E  0F 28 C5                    movaps  xmm0, xmm5
0000000180382721  F3 0F 59 A3 70 1D 01 00     mulss   xmm4, dword ptr [rbx+11D70h]
0000000180382729  0F 28 DD                    movaps  xmm3, xmm5
000000018038272C  F3 0F 58 83 40 1D 01 00     addss   xmm0, dword ptr [rbx+11D40h]
0000000180382734  F3 0F 58 9B 60 1D 01 00     addss   xmm3, dword ptr [rbx+11D60h]
000000018038273C  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180382740  73 06                       jnb     short loc_180382748
0000000180382742  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180382746  EB 05                       jmp     short loc_18038274D
0000000180382748  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018038274D  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180382751  72 1B                       jb      short loc_18038276E
0000000180382753  F3 0F 10 83 50 1D 01 00     movss   xmm0, dword ptr [rbx+11D50h]
000000018038275B  0F 28 D8                    movaps  xmm3, xmm0
000000018038275E  F3 0F 59 C5                 mulss   xmm0, xmm5
0000000180382762  F3 0F 59 DE                 mulss   xmm3, xmm6
0000000180382766  F3 0F 5C D8                 subss   xmm3, xmm0
000000018038276A  F3 0F 58 DD                 addss   xmm3, xmm5
000000018038276E  41 0F 2E F6                 ucomiss xmm6, xmm14
0000000180382772  F3 0F 10 8B 90 1D 01 00     movss   xmm1, dword ptr [rbx+11D90h]
000000018038277A  0F 28 D4                    movaps  xmm2, xmm4
000000018038277D  F3 0F 59 93 80 1D 01 00     mulss   xmm2, dword ptr [rbx+11D80h]
0000000180382785  0F 28 C1                    movaps  xmm0, xmm1
0000000180382788  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018038278C  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180382790  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180382794  0F 28 C2                    movaps  xmm0, xmm2
0000000180382797  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018038279B  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018038279F  F3 0F 5C C2                 subss   xmm0, xmm2
00000001803827A3  F3 0F 58 C5                 addss   xmm0, xmm5
00000001803827A7  74 03                       jz      short loc_1803827AC
00000001803827A9  0F 28 C3                    movaps  xmm0, xmm3
00000001803827AC  F3 0F 11 83 30 1D 01 00     movss   dword ptr [rbx+11D30h], xmm0
00000001803827B4  F3 0F 11 83 10 1D 01 00     movss   dword ptr [rbx+11D10h], xmm0
00000001803827BC  F3 0F 10 BB B0 19 01 00     movss   xmm7, dword ptr [rbx+119B0h]
00000001803827C4  F3 0F 10 B3 20 01 01 00     movss   xmm6, dword ptr [rbx+10120h]
00000001803827CC  F3 0F 10 9B 20 11 01 00     movss   xmm3, dword ptr [rbx+11120h]
00000001803827D4  F3 0F 10 83 00 03 01 00     movss   xmm0, dword ptr [rbx+10300h]
00000001803827DC  F3 0F 10 8B B0 1B 01 00     movss   xmm1, dword ptr [rbx+11BB0h]
00000001803827E4  8B 83 D0 1D 01 00           mov     eax, [rbx+11DD0h]
00000001803827EA  89 83 E0 1D 01 00           mov     [rbx+11DE0h], eax
00000001803827F0  8B 83 F0 1D 01 00           mov     eax, [rbx+11DF0h]
00000001803827F6  89 83 00 1E 01 00           mov     [rbx+11E00h], eax
00000001803827FC  F3 0F 11 83 A0 1D 01 00     movss   dword ptr [rbx+11DA0h], xmm0
0000000180382804  F3 0F 11 8B B0 1D 01 00     movss   dword ptr [rbx+11DB0h], xmm1
000000018038280C  F3 0F 59 9B C0 1E 01 00     mulss   xmm3, dword ptr [rbx+11EC0h]
0000000180382814  F3 0F 10 A3 E0 1D 01 00     movss   xmm4, dword ptr [rbx+11DE0h]
000000018038281C  F3 0F 10 93 20 1E 01 00     movss   xmm2, dword ptr [rbx+11E20h]
0000000180382824  F3 0F 11 9B C0 1D 01 00     movss   dword ptr [rbx+11DC0h], xmm3
000000018038282C  0F 28 DF                    movaps  xmm3, xmm7
000000018038282F  F3 0F 59 B3 30 1E 01 00     mulss   xmm6, dword ptr [rbx+11E30h]
0000000180382837  F3 0F 5C DC                 subss   xmm3, xmm4
000000018038283B  F3 0F 59 93 30 1D 01 00     mulss   xmm2, dword ptr [rbx+11D30h]
0000000180382843  F3 0F 10 8B 40 1E 01 00     movss   xmm1, dword ptr [rbx+11E40h]
000000018038284B  0F 28 C3                    movaps  xmm0, xmm3
000000018038284E  F3 0F 59 83 60 1E 01 00     mulss   xmm0, dword ptr [rbx+11E60h]
0000000180382856  F3 0F 58 F2                 addss   xmm6, xmm2
000000018038285A  F3 0F 58 E0                 addss   xmm4, xmm0
000000018038285E  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180382862  F3 0F 11 A3 D0 1D 01 00     movss   dword ptr [rbx+11DD0h], xmm4
000000018038286A  F3 0F 59 8B A0 1D 01 00     mulss   xmm1, dword ptr [rbx+11DA0h]
0000000180382872  F3 0F 10 93 50 1E 01 00     movss   xmm2, dword ptr [rbx+11E50h]
000000018038287A  F3 0F 59 9B D0 1E 01 00     mulss   xmm3, dword ptr [rbx+11ED0h]
0000000180382882  F3 0F 59 A3 E0 1E 01 00     mulss   xmm4, dword ptr [rbx+11EE0h]
000000018038288A  F3 0F 58 F1                 addss   xmm6, xmm1
000000018038288E  0F 28 CA                    movaps  xmm1, xmm2
0000000180382891  F3 0F 59 8B B0 1D 01 00     mulss   xmm1, dword ptr [rbx+11DB0h]
0000000180382899  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018038289D  F3 0F 58 DC                 addss   xmm3, xmm4
00000001803828A1  F3 0F 5C CA                 subss   xmm1, xmm2
00000001803828A5  F3 0F 58 CE                 addss   xmm1, xmm6
00000001803828A9  F3 0F 10 B3 70 1E 01 00     movss   xmm6, dword ptr [rbx+11E70h]
00000001803828B1  F3 0F 5C C6                 subss   xmm0, xmm6
00000001803828B5  F3 0F 59 8B A0 1E 01 00     mulss   xmm1, dword ptr [rbx+11EA0h]
00000001803828BD  F3 0F 59 F8                 mulss   xmm7, xmm0
00000001803828C1  41 0F 2F CE                 comiss  xmm1, xmm14
00000001803828C5  76 05                       jbe     short loc_1803828CC
00000001803828C7  0F 5A C1                    cvtps2pd xmm0, xmm1
00000001803828CA  EB 03                       jmp     short loc_1803828CF
00000001803828CC  0F 57 C0                    xorps   xmm0, xmm0
00000001803828CF  F3 0F 10 93 90 1E 01 00     movss   xmm2, dword ptr [rbx+11E90h]
00000001803828D7  F3 0F 10 A3 80 1E 01 00     movss   xmm4, dword ptr [rbx+11E80h]
00000001803828DF  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00000001803828E3  F3 0F 10 83 C0 1D 01 00     movss   xmm0, dword ptr [rbx+11DC0h]
00000001803828EB  F3 0F 59 AB B0 1E 01 00     mulss   xmm5, dword ptr [rbx+11EB0h]
00000001803828F3  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803828F8  F3 0F 59 F3                 mulss   xmm6, xmm3
00000001803828FC  F3 0F 10 9B 00 1E 01 00     movss   xmm3, dword ptr [rbx+11E00h]
0000000180382904  F3 0F 58 F7                 addss   xmm6, xmm7
0000000180382908  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018038290C  F3 0F 10 83 F0 1E 01 00     movss   xmm0, dword ptr [rbx+11EF0h]
0000000180382914  0F 28 C8                    movaps  xmm1, xmm0
0000000180382917  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018038291B  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018038291F  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180382923  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180382927  F3 0F 58 D9                 addss   xmm3, xmm1
000000018038292B  F3 0F 11 9B F0 1D 01 00     movss   dword ptr [rbx+11DF0h], xmm3
0000000180382933  F3 0F 59 E3                 mulss   xmm4, xmm3
0000000180382937  F3 0F 58 E2                 addss   xmm4, xmm2
000000018038293B  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018038293F  F3 0F 59 A3 00 1F 01 00     mulss   xmm4, dword ptr [rbx+11F00h]
0000000180382947  F3 0F 11 A3 10 1E 01 00     movss   dword ptr [rbx+11E10h], xmm4
000000018038294F  8B 83 20 1F 01 00           mov     eax, [rbx+11F20h]
0000000180382955  89 83 30 1F 01 00           mov     [rbx+11F30h], eax
000000018038295B  8B 83 10 1F 01 00           mov     eax, [rbx+11F10h]
0000000180382961  89 83 20 1F 01 00           mov     [rbx+11F20h], eax
0000000180382967  F3 0F 10 83 30 1F 01 00     movss   xmm0, dword ptr [rbx+11F30h]
000000018038296F  F3 0F 10 8B 40 1F 01 00     movss   xmm1, dword ptr [rbx+11F40h]
0000000180382977  F3 0F 5C E0                 subss   xmm4, xmm0
000000018038297B  F3 0F 11 A3 10 1F 01 00     movss   dword ptr [rbx+11F10h], xmm4
0000000180382983  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180382987  F3 0F 58 C8                 addss   xmm1, xmm0
000000018038298B  F3 0F 11 8B 20 1F 01 00     movss   dword ptr [rbx+11F20h], xmm1
0000000180382993  F3 0F 10 93 10 1F 01 00     movss   xmm2, dword ptr [rbx+11F10h]
000000018038299B  F3 0F 10 B3 00 1C 01 00     movss   xmm6, dword ptr [rbx+11C00h]
00000001803829A3  0F 28 C2                    movaps  xmm0, xmm2
00000001803829A6  41 0F 2F F6                 comiss  xmm6, xmm14
00000001803829AA  8B 83 70 1F 01 00           mov     eax, [rbx+11F70h]
00000001803829B0  89 83 80 1F 01 00           mov     [rbx+11F80h], eax
00000001803829B6  8B 83 60 1F 01 00           mov     eax, [rbx+11F60h]
00000001803829BC  89 83 70 1F 01 00           mov     [rbx+11F70h], eax
00000001803829C2  8B 83 50 1F 01 00           mov     eax, [rbx+11F50h]
00000001803829C8  89 83 60 1F 01 00           mov     [rbx+11F60h], eax
00000001803829CE  F3 0F 11 93 50 1F 01 00     movss   dword ptr [rbx+11F50h], xmm2
00000001803829D6  F3 0F 59 83 A0 1F 01 00     mulss   xmm0, dword ptr [rbx+11FA0h]
00000001803829DE  F3 0F 10 A3 60 1F 01 00     movss   xmm4, dword ptr [rbx+11F60h]
00000001803829E6  F3 0F 10 8B C0 1F 01 00     movss   xmm1, dword ptr [rbx+11FC0h]
00000001803829EE  0F 28 EC                    movaps  xmm5, xmm4
00000001803829F1  F3 0F 59 8B 70 1F 01 00     mulss   xmm1, dword ptr [rbx+11F70h]
00000001803829F9  F3 0F 59 AB B0 1F 01 00     mulss   xmm5, dword ptr [rbx+11FB0h]
0000000180382A01  F3 0F 59 A3 E0 1F 01 00     mulss   xmm4, dword ptr [rbx+11FE0h]
0000000180382A09  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180382A0D  0F 28 C2                    movaps  xmm0, xmm2
0000000180382A10  F3 0F 59 83 D0 1F 01 00     mulss   xmm0, dword ptr [rbx+11FD0h]
0000000180382A18  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180382A1C  F3 0F 10 8B F0 1F 01 00     movss   xmm1, dword ptr [rbx+11FF0h]
0000000180382A24  F3 0F 59 8B 80 1F 01 00     mulss   xmm1, dword ptr [rbx+11F80h]
0000000180382A2C  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180382A30  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180382A34  76 05                       jbe     short loc_180382A3B
0000000180382A36  0F 5A C6                    cvtps2pd xmm0, xmm6
0000000180382A39  EB 03                       jmp     short loc_180382A3E
0000000180382A3B  0F 57 C0                    xorps   xmm0, xmm0
0000000180382A3E  0F 2F 35 7B 2A 76 00        comiss  xmm6, cs:dword_180AE54C0
0000000180382A45  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180382A49  F3 0F 11 AB 60 1F 01 00     movss   dword ptr [rbx+11F60h], xmm5
0000000180382A51  0F 28 D8                    movaps  xmm3, xmm0
0000000180382A54  F3 0F 11 A3 70 1F 01 00     movss   dword ptr [rbx+11F70h], xmm4
0000000180382A5C  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180382A60  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180382A64  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180382A68  0F 28 C6                    movaps  xmm0, xmm6
0000000180382A6B  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180382A6F  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180382A73  73 09                       jnb     short loc_180382A7E
0000000180382A75  45 0F 57 D2                 xorps   xmm10, xmm10
0000000180382A79  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
0000000180382A7E  41 0F 2F F6                 comiss  xmm6, xmm14
0000000180382A82  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
0000000180382A87  0F 28 C8                    movaps  xmm1, xmm0
0000000180382A8A  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180382A8E  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180382A92  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180382A96  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180382A9A  72 03                       jb      short loc_180382A9F
0000000180382A9C  0F 28 D3                    movaps  xmm2, xmm3
0000000180382A9F  F3 0F 11 93 90 1F 01 00     movss   dword ptr [rbx+11F90h], xmm2
0000000180382AA7  F3 0F 59 93 90 1C 01 00     mulss   xmm2, dword ptr [rbx+11C90h]
0000000180382AAF  F3 0F 11 93 00 20 01 00     movss   dword ptr [rbx+12000h], xmm2
0000000180382AB7  F3 0F 59 93 E0 1C 01 00     mulss   xmm2, dword ptr [rbx+11CE0h]
0000000180382ABF  F3 0F 11 93 10 20 01 00     movss   dword ptr [rbx+12010h], xmm2
0000000180382AC7  F3 0F 10 83 C0 07 01 00     movss   xmm0, dword ptr [rbx+107C0h]
0000000180382ACF  F3 0F 58 83 20 05 01 00     addss   xmm0, dword ptr [rbx+10520h]
0000000180382AD7  44 0F 5A E0                 cvtps2pd xmm12, xmm0
0000000180382ADB  F2 44 0F 5F 25 C4 81 60 00  maxsd   xmm12, cs:qword_18098ACA8
0000000180382AE4  F2 44 0F 5D 25 A3 81 60 00  minsd   xmm12, cs:qword_18098AC90
0000000180382AED  41 0F 28 CC                 movaps  xmm1, xmm12
0000000180382AF1  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180382AF5  F2 0F 58 05 6B 27 76 00     addsd   xmm0, cs:qword_180AE5268
0000000180382AFD  F2 41 0F 59 CC              mulsd   xmm1, xmm12
0000000180382B02  41 0F 28 FC                 movaps  xmm7, xmm12
0000000180382B06  F2 0F 2C C0                 cvttsd2si eax, xmm0
0000000180382B0A  0F 28 D1                    movaps  xmm2, xmm1
0000000180382B0D  48 63 C8                    movsxd  rcx, eax
0000000180382B10  F2 41 0F 59 D4              mulsd   xmm2, xmm12
0000000180382B15  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
0000000180382B1C  0F 28 DA                    movaps  xmm3, xmm2
0000000180382B1F  F2 41 0F 59 DC              mulsd   xmm3, xmm12
0000000180382B24  48 8D 0D B5 69 60 00        lea     rcx, unk_1809894E0
0000000180382B2B  48 03 C1                    add     rax, rcx
0000000180382B2E  0F 28 E3                    movaps  xmm4, xmm3
0000000180382B31  F2 41 0F 59 E4              mulsd   xmm4, xmm12
0000000180382B36  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
0000000180382B3B  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
0000000180382B40  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
0000000180382B45  0F 28 EC                    movaps  xmm5, xmm4
0000000180382B48  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
0000000180382B4C  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
0000000180382B51  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
0000000180382B56  F2 0F 58 F9                 addsd   xmm7, xmm1
0000000180382B5A  F2 41 0F 59 EC              mulsd   xmm5, xmm12
0000000180382B5F  F2 0F 58 FA                 addsd   xmm7, xmm2
0000000180382B63  0F 28 F5                    movaps  xmm6, xmm5
0000000180382B66  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
0000000180382B6B  F2 41 0F 59 F4              mulsd   xmm6, xmm12
0000000180382B70  F2 0F 58 FB                 addsd   xmm7, xmm3
0000000180382B74  44 0F 28 C6                 movaps  xmm8, xmm6
0000000180382B78  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
0000000180382B7D  F2 0F 58 FC                 addsd   xmm7, xmm4
0000000180382B81  F2 45 0F 59 C4              mulsd   xmm8, xmm12
0000000180382B86  F2 0F 58 FD                 addsd   xmm7, xmm5
0000000180382B8A  45 0F 28 C8                 movaps  xmm9, xmm8
0000000180382B8E  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
0000000180382B97  F2 45 0F 59 CC              mulsd   xmm9, xmm12
0000000180382B9C  F2 0F 58 FE                 addsd   xmm7, xmm6
0000000180382BA0  45 0F 28 D1                 movaps  xmm10, xmm9
0000000180382BA4  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
0000000180382BAD  F2 41 0F 58 F8              addsd   xmm7, xmm8
0000000180382BB2  F2 45 0F 59 D4              mulsd   xmm10, xmm12
0000000180382BB7  F2 41 0F 58 F9              addsd   xmm7, xmm9
0000000180382BBC  45 0F 28 DA                 movaps  xmm11, xmm10
0000000180382BC0  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
0000000180382BC9  F2 45 0F 59 DC              mulsd   xmm11, xmm12
0000000180382BCE  F2 41 0F 58 FA              addsd   xmm7, xmm10
0000000180382BD3  41 0F 28 C3                 movaps  xmm0, xmm11
0000000180382BD7  F2 45 0F 59 DC              mulsd   xmm11, xmm12
0000000180382BDC  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
0000000180382BE4  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
0000000180382BED  F2 0F 58 F8                 addsd   xmm7, xmm0
0000000180382BF1  F2 41 0F 58 FB              addsd   xmm7, xmm11
0000000180382BF6  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
0000000180382BFA  F3 0F 5D 1D 96 80 60 00     minss   xmm3, cs:dword_18098AC98
0000000180382C02  F3 0F 5F 1D A6 80 60 00     maxss   xmm3, cs:dword_18098ACB0
0000000180382C0A  F3 0F 59 9B 30 05 01 00     mulss   xmm3, dword ptr [rbx+10530h]
0000000180382C12  F3 0F 11 9B A0 07 01 00     movss   dword ptr [rbx+107A0h], xmm3
0000000180382C1A  8B 83 40 09 01 00           mov     eax, [rbx+10940h]
0000000180382C20  F3 0F 10 AB 20 05 01 00     movss   xmm5, dword ptr [rbx+10520h]
0000000180382C28  F3 0F 10 83 F0 06 01 00     movss   xmm0, dword ptr [rbx+106F0h]
0000000180382C30  F3 0F 10 8B 00 07 01 00     movss   xmm1, dword ptr [rbx+10700h]
0000000180382C38  F3 0F 10 93 10 07 01 00     movss   xmm2, dword ptr [rbx+10710h]
0000000180382C40  89 83 50 09 01 00           mov     [rbx+10950h], eax
0000000180382C46  8B 83 60 09 01 00           mov     eax, [rbx+10960h]
0000000180382C4C  89 83 70 09 01 00           mov     [rbx+10970h], eax
0000000180382C52  8B 83 10 0A 01 00           mov     eax, [rbx+10A10h]
0000000180382C58  89 83 20 0A 01 00           mov     [rbx+10A20h], eax
0000000180382C5E  8B 83 00 0A 01 00           mov     eax, [rbx+10A00h]
0000000180382C64  89 83 10 0A 01 00           mov     [rbx+10A10h], eax
0000000180382C6A  8B 83 F0 09 01 00           mov     eax, [rbx+109F0h]
0000000180382C70  89 83 00 0A 01 00           mov     [rbx+10A00h], eax
0000000180382C76  8B 83 E0 09 01 00           mov     eax, [rbx+109E0h]
0000000180382C7C  89 83 F0 09 01 00           mov     [rbx+109F0h], eax
0000000180382C82  8B 83 D0 09 01 00           mov     eax, [rbx+109D0h]
0000000180382C88  89 83 E0 09 01 00           mov     [rbx+109E0h], eax
0000000180382C8E  8B 83 C0 09 01 00           mov     eax, [rbx+109C0h]
0000000180382C94  89 83 D0 09 01 00           mov     [rbx+109D0h], eax
0000000180382C9A  8B 83 B0 09 01 00           mov     eax, [rbx+109B0h]
0000000180382CA0  89 83 C0 09 01 00           mov     [rbx+109C0h], eax
0000000180382CA6  8B 83 90 0A 01 00           mov     eax, [rbx+10A90h]
0000000180382CAC  89 83 A0 0A 01 00           mov     [rbx+10AA0h], eax
0000000180382CB2  8B 83 80 0A 01 00           mov     eax, [rbx+10A80h]
0000000180382CB8  89 83 90 0A 01 00           mov     [rbx+10A90h], eax
0000000180382CBE  8B 83 70 0A 01 00           mov     eax, [rbx+10A70h]
0000000180382CC4  89 83 80 0A 01 00           mov     [rbx+10A80h], eax
0000000180382CCA  8B 83 60 0A 01 00           mov     eax, [rbx+10A60h]
0000000180382CD0  89 83 70 0A 01 00           mov     [rbx+10A70h], eax
0000000180382CD6  8B 83 50 0A 01 00           mov     eax, [rbx+10A50h]
0000000180382CDC  89 83 60 0A 01 00           mov     [rbx+10A60h], eax
0000000180382CE2  8B 83 40 0A 01 00           mov     eax, [rbx+10A40h]
0000000180382CE8  89 83 50 0A 01 00           mov     [rbx+10A50h], eax
0000000180382CEE  8B 83 30 0A 01 00           mov     eax, [rbx+10A30h]
0000000180382CF4  89 83 40 0A 01 00           mov     [rbx+10A40h], eax
0000000180382CFA  8B 83 10 0B 01 00           mov     eax, [rbx+10B10h]
0000000180382D00  89 83 20 0B 01 00           mov     [rbx+10B20h], eax
0000000180382D06  8B 83 00 0B 01 00           mov     eax, [rbx+10B00h]
0000000180382D0C  89 83 10 0B 01 00           mov     [rbx+10B10h], eax
0000000180382D12  8B 83 F0 0A 01 00           mov     eax, [rbx+10AF0h]
0000000180382D18  89 83 00 0B 01 00           mov     [rbx+10B00h], eax
0000000180382D1E  8B 83 E0 0A 01 00           mov     eax, [rbx+10AE0h]
0000000180382D24  89 83 F0 0A 01 00           mov     [rbx+10AF0h], eax
0000000180382D2A  8B 83 D0 0A 01 00           mov     eax, [rbx+10AD0h]
0000000180382D30  89 83 E0 0A 01 00           mov     [rbx+10AE0h], eax
0000000180382D36  8B 83 C0 0A 01 00           mov     eax, [rbx+10AC0h]
0000000180382D3C  89 83 D0 0A 01 00           mov     [rbx+10AD0h], eax
0000000180382D42  8B 83 B0 0A 01 00           mov     eax, [rbx+10AB0h]
0000000180382D48  89 83 C0 0A 01 00           mov     [rbx+10AC0h], eax
0000000180382D4E  8B 83 90 0B 01 00           mov     eax, [rbx+10B90h]
0000000180382D54  89 83 A0 0B 01 00           mov     [rbx+10BA0h], eax
0000000180382D5A  8B 83 80 0B 01 00           mov     eax, [rbx+10B80h]
0000000180382D60  89 83 90 0B 01 00           mov     [rbx+10B90h], eax
0000000180382D66  8B 83 70 0B 01 00           mov     eax, [rbx+10B70h]
0000000180382D6C  89 83 80 0B 01 00           mov     [rbx+10B80h], eax
0000000180382D72  8B 83 60 0B 01 00           mov     eax, [rbx+10B60h]
0000000180382D78  89 83 70 0B 01 00           mov     [rbx+10B70h], eax
0000000180382D7E  8B 83 50 0B 01 00           mov     eax, [rbx+10B50h]
0000000180382D84  89 83 60 0B 01 00           mov     [rbx+10B60h], eax
0000000180382D8A  8B 83 40 0B 01 00           mov     eax, [rbx+10B40h]
0000000180382D90  89 83 50 0B 01 00           mov     [rbx+10B50h], eax
0000000180382D96  8B 83 30 0B 01 00           mov     eax, [rbx+10B30h]
0000000180382D9C  89 83 40 0B 01 00           mov     [rbx+10B40h], eax
0000000180382DA2  8B 83 D0 0B 01 00           mov     eax, [rbx+10BD0h]
0000000180382DA8  89 83 E0 0B 01 00           mov     [rbx+10BE0h], eax
0000000180382DAE  8B 83 C0 0B 01 00           mov     eax, [rbx+10BC0h]
0000000180382DB4  89 83 D0 0B 01 00           mov     [rbx+10BD0h], eax
0000000180382DBA  F3 0F 11 83 E0 08 01 00     movss   dword ptr [rbx+108E0h], xmm0
0000000180382DC2  F3 0F 11 8B F0 08 01 00     movss   dword ptr [rbx+108F0h], xmm1
0000000180382DCA  F3 0F 58 AB 00 0F 01 00     addss   xmm5, dword ptr [rbx+10F00h]
0000000180382DD2  F3 0F 59 9B 00 0C 01 00     mulss   xmm3, dword ptr [rbx+10C00h]
0000000180382DDA  F3 0F 10 83 F0 0B 01 00     movss   xmm0, dword ptr [rbx+10BF0h]
0000000180382DE2  F3 0F 11 93 00 09 01 00     movss   dword ptr [rbx+10900h], xmm2
0000000180382DEA  F3 0F 10 93 20 0C 01 00     movss   xmm2, dword ptr [rbx+10C20h]
0000000180382DF2  F3 0F 59 AB 10 0F 01 00     mulss   xmm5, dword ptr [rbx+10F10h]
0000000180382DFA  F3 0F 5F D3                 maxss   xmm2, xmm3
0000000180382DFE  F3 0F 58 AB F0 0E 01 00     addss   xmm5, dword ptr [rbx+10EF0h]
0000000180382E06  F3 0F 11 93 10 09 01 00     movss   dword ptr [rbx+10910h], xmm2
0000000180382E0E  F3 0F 58 83 40 05 01 00     addss   xmm0, dword ptr [rbx+10540h]
0000000180382E16  41 0F 2F EE                 comiss  xmm5, xmm14
0000000180382E1A  F3 0F 11 83 30 09 01 00     movss   dword ptr [rbx+10930h], xmm0
0000000180382E22  76 05                       jbe     short loc_180382E29
0000000180382E24  0F 5A C5                    cvtps2pd xmm0, xmm5
0000000180382E27  EB 03                       jmp     short loc_180382E2C
0000000180382E29  0F 57 C0                    xorps   xmm0, xmm0
0000000180382E2C  F3 0F 10 0D 28 21 76 00     movss   xmm1, cs:dword_180AE4F5C
0000000180382E34  F3 44 0F 10 15 AB 23 76 00  movss   xmm10, cs:flt_180AE51E8
0000000180382E3D  F3 0F 5E CA                 divss   xmm1, xmm2
0000000180382E41  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180382E45  F3 0F 11 8B 20 09 01 00     movss   dword ptr [rbx+10920h], xmm1
0000000180382E4D  F3 0F 11 83 B0 0B 01 00     movss   dword ptr [rbx+10BB0h], xmm0
0000000180382E55  F3 0F 10 B3 70 09 01 00     movss   xmm6, dword ptr [rbx+10970h]
0000000180382E5D  F3 0F 10 8B 50 09 01 00     movss   xmm1, dword ptr [rbx+10950h]
0000000180382E65  F3 0F 11 B3 90 08 01 00     movss   dword ptr [rbx+10890h], xmm6
0000000180382E6D  F3 0F 58 F2                 addss   xmm6, xmm2
0000000180382E71  F3 0F 11 8B A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm1
0000000180382E79  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180382E7D  76 1B                       jbe     short loc_180382E9A
0000000180382E7F  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180382E84  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180382E88  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180382E8B  E8 48 C6 36 00              call    fmodf
0000000180382E90  0F 28 F0                    movaps  xmm6, xmm0
0000000180382E93  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180382E98  EB 1F                       jmp     short loc_180382EB9
0000000180382E9A  41 0F 2F F7                 comiss  xmm6, xmm15
0000000180382E9E  73 19                       jnb     short loc_180382EB9
0000000180382EA0  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180382EA5  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180382EA9  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180382EAC  E8 27 C6 36 00              call    fmodf
0000000180382EB1  0F 28 F0                    movaps  xmm6, xmm0
0000000180382EB4  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180382EB9  F3 44 0F 10 25 4A 21 76 00  movss   xmm12, cs:dword_180AE500C
0000000180382EC2  0F 28 C6                    movaps  xmm0, xmm6
0000000180382EC5  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180382ECA  F3 0F 11 B3 80 08 01 00     movss   dword ptr [rbx+10880h], xmm6
0000000180382ED2  0F 28 FE                    movaps  xmm7, xmm6
0000000180382ED5  F3 0F 59 BB 70 0C 01 00     mulss   xmm7, dword ptr [rbx+10C70h]
0000000180382EDD  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180382EE2  E8 D9 60 FE FF              call    sub_180368FC0
0000000180382EE7  F3 44 0F 10 1D 54 25 76 00  movss   xmm11, cs:dword_180AE5444
0000000180382EF0  0F 28 E8                    movaps  xmm5, xmm0
0000000180382EF3  F3 41 0F 59 EB              mulss   xmm5, xmm11
0000000180382EF8  F3 0F 59 AB 20 09 01 00     mulss   xmm5, dword ptr [rbx+10920h]
0000000180382F00  F3 0F 59 AB 40 0C 01 00     mulss   xmm5, dword ptr [rbx+10C40h]
0000000180382F08  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180382F0C  73 06                       jnb     short loc_180382F14
0000000180382F0E  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180382F12  EB 05                       jmp     short loc_180382F19
0000000180382F14  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180382F19  F3 0F 59 AB 10 0C 01 00     mulss   xmm5, dword ptr [rbx+10C10h]
0000000180382F21  0F 28 D5                    movaps  xmm2, xmm5
0000000180382F24  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180382F28  0F 28 CA                    movaps  xmm1, xmm2
0000000180382F2B  0F 28 C2                    movaps  xmm0, xmm2
0000000180382F2E  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
0000000180382F36  0F 28 DA                    movaps  xmm3, xmm2
0000000180382F39  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180382F3D  0F 28 E2                    movaps  xmm4, xmm2
0000000180382F40  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
0000000180382F48  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
0000000180382F50  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180382F54  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
0000000180382F5C  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180382F60  0F 28 C3                    movaps  xmm0, xmm3
0000000180382F63  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
0000000180382F6B  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180382F6F  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180382F73  F3 0F 10 8B 30 09 01 00     movss   xmm1, dword ptr [rbx+10930h]
0000000180382F7B  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180382F7F  0F 28 C1                    movaps  xmm0, xmm1
0000000180382F82  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180382F86  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180382F8A  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180382F8E  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180382F92  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180382F96  F3 0F 11 A3 80 09 01 00     movss   dword ptr [rbx+10980h], xmm4
0000000180382F9E  72 07                       jb      short loc_180382FA7
0000000180382FA0  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180382FA5  EB 05                       jmp     short loc_180382FAC
0000000180382FA7  F3 41 0F 5C CD              subss   xmm1, xmm13
0000000180382FAC  0F 28 F0                    movaps  xmm6, xmm0
0000000180382FAF  73 06                       jnb     short loc_180382FB7
0000000180382FB1  41 0F 28 F7                 movaps  xmm6, xmm15
0000000180382FB5  EB 06                       jmp     short loc_180382FBD
0000000180382FB7  76 04                       jbe     short loc_180382FBD
0000000180382FB9  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180382FBD  F3 44 0F 10 83 80 08 01 00  movss   xmm8, dword ptr [rbx+10880h]
0000000180382FC6  F3 0F 59 B3 80 0C 01 00     mulss   xmm6, dword ptr [rbx+10C80h]
0000000180382FCE  F3 0F 5E C1                 divss   xmm0, xmm1
0000000180382FD2  E8 E9 5F FE FF              call    sub_180368FC0
0000000180382FD7  0F 28 E0                    movaps  xmm4, xmm0
0000000180382FDA  F3 0F 10 83 30 0C 01 00     movss   xmm0, dword ptr [rbx+10C30h]
0000000180382FE2  44 0F 2F C0                 comiss  xmm8, xmm0
0000000180382FE6  72 18                       jb      short loc_180383000
0000000180382FE8  0F 2F 83 90 08 01 00        comiss  xmm0, dword ptr [rbx+10890h]
0000000180382FEF  76 0F                       jbe     short loc_180383000
0000000180382FF1  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
0000000180382FF9  F3 41 0F 58 FA              addss   xmm7, xmm10
0000000180382FFE  EB 08                       jmp     short loc_180383008
0000000180383000  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
0000000180383008  0F 2F 3D C1 22 76 00        comiss  xmm7, cs:dword_180AE52D0
000000018038300F  F3 0F 59 A3 20 09 01 00     mulss   xmm4, dword ptr [rbx+10920h]
0000000180383017  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018038301C  F3 0F 59 A3 50 0C 01 00     mulss   xmm4, dword ptr [rbx+10C50h]
0000000180383024  72 03                       jb      short loc_180383029
0000000180383026  0F 57 FF                    xorps   xmm7, xmm7
0000000180383029  41 0F 2F E7                 comiss  xmm4, xmm15
000000018038302D  73 06                       jnb     short loc_180383035
000000018038302F  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180383033  EB 05                       jmp     short loc_18038303A
0000000180383035  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018038303A  F3 0F 11 BB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm7
0000000180383042  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180383047  F3 0F 59 A3 10 0C 01 00     mulss   xmm4, dword ptr [rbx+10C10h]
000000018038304F  0F 28 D4                    movaps  xmm2, xmm4
0000000180383052  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180383057  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018038305B  0F 28 C2                    movaps  xmm0, xmm2
000000018038305E  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180383063  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180383067  0F 28 DA                    movaps  xmm3, xmm2
000000018038306A  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018038306E  44 0F 28 CA                 movaps  xmm9, xmm2
0000000180383072  F3 44 0F 59 8B E0 0D 01 00  mulss   xmm9, dword ptr [rbx+10DE0h]
000000018038307B  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180383080  0F 28 CA                    movaps  xmm1, xmm2
0000000180383083  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
000000018038308B  F3 44 0F 58 8B D0 0D 01 00  addss   xmm9, dword ptr [rbx+10DD0h]
0000000180383094  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
000000018038309C  F3 44 0F 59 C8              mulss   xmm9, xmm0
00000001803830A1  0F 28 C3                    movaps  xmm0, xmm3
00000001803830A4  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00000001803830AC  F3 44 0F 58 C9              addss   xmm9, xmm1
00000001803830B1  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803830B5  F3 44 0F 59 C8              mulss   xmm9, xmm0
00000001803830BA  0F 28 C7                    movaps  xmm0, xmm7
00000001803830BD  0F 54 05 CC 26 76 00        andps   xmm0, cs:xmmword_180AE5790
00000001803830C4  0F 57 05 F5 26 76 00        xorps   xmm0, cs:xmmword_180AE57C0
00000001803830CB  F3 44 0F 58 CB              addss   xmm9, xmm3
00000001803830D0  F3 44 0F 58 CC              addss   xmm9, xmm4
00000001803830D5  F3 44 0F 59 CE              mulss   xmm9, xmm6
00000001803830DA  F3 44 0F 11 8B 90 09 01 00  movss   dword ptr [rbx+10990h], xmm9
00000001803830E3  E8 D8 5E FE FF              call    sub_180368FC0
00000001803830E8  41 0F 2F FE                 comiss  xmm7, xmm14
00000001803830EC  44 0F 28 C0                 movaps  xmm8, xmm0
00000001803830F0  F3 45 0F 58 C5              addss   xmm8, xmm13
00000001803830F5  73 06                       jnb     short loc_1803830FD
00000001803830F7  41 0F 28 FF                 movaps  xmm7, xmm15
00000001803830FB  EB 06                       jmp     short loc_180383103
00000001803830FD  76 04                       jbe     short loc_180383103
00000001803830FF  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180383103  F3 44 0F 59 83 20 09 01 00  mulss   xmm8, dword ptr [rbx+10920h]
000000018038310C  F3 0F 59 BB 90 0C 01 00     mulss   xmm7, dword ptr [rbx+10C90h]
0000000180383114  F3 44 0F 59 05 7B 7B 60 00  mulss   xmm8, cs:dword_18098AC98
000000018038311D  F3 44 0F 59 83 60 0C 01 00  mulss   xmm8, dword ptr [rbx+10C60h]
0000000180383126  45 0F 2F C7                 comiss  xmm8, xmm15
000000018038312A  73 06                       jnb     short loc_180383132
000000018038312C  45 0F 28 C7                 movaps  xmm8, xmm15
0000000180383130  EB 05                       jmp     short loc_180383137
0000000180383132  F3 45 0F 5D C5              minss   xmm8, xmm13
0000000180383137  F3 44 0F 59 83 10 0C 01 00  mulss   xmm8, dword ptr [rbx+10C10h]
0000000180383140  F3 44 0F 59 8B F0 08 01 00  mulss   xmm9, dword ptr [rbx+108F0h]
0000000180383149  F3 0F 10 B3 80 08 01 00     movss   xmm6, dword ptr [rbx+10880h]
0000000180383151  41 0F 28 D0                 movaps  xmm2, xmm8
0000000180383155  F3 0F 10 AB A0 08 01 00     movss   xmm5, dword ptr [rbx+108A0h]
000000018038315D  F3 41 0F 59 D0              mulss   xmm2, xmm8
0000000180383162  0F 28 C2                    movaps  xmm0, xmm2
0000000180383165  0F 28 DA                    movaps  xmm3, xmm2
0000000180383168  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038316C  0F 28 E2                    movaps  xmm4, xmm2
000000018038316F  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
0000000180383177  0F 28 CA                    movaps  xmm1, xmm2
000000018038317A  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
0000000180383182  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
000000018038318A  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018038318F  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
0000000180383197  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018038319B  0F 28 C3                    movaps  xmm0, xmm3
000000018038319E  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00000001803831A6  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803831AA  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803831AE  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803831B2  F3 0F 10 83 80 09 01 00     movss   xmm0, dword ptr [rbx+10980h]
00000001803831BA  F3 0F 59 83 E0 08 01 00     mulss   xmm0, dword ptr [rbx+108E0h]
00000001803831C2  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803831C6  F3 41 0F 58 C1              addss   xmm0, xmm9
00000001803831CB  F3 41 0F 58 E0              addss   xmm4, xmm8
00000001803831D0  F3 0F 59 E7                 mulss   xmm4, xmm7
00000001803831D4  F3 0F 59 A3 00 09 01 00     mulss   xmm4, dword ptr [rbx+10900h]
00000001803831DC  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803831E0  F3 0F 11 A3 B0 09 01 00     movss   dword ptr [rbx+109B0h], xmm4
00000001803831E8  F3 0F 11 B3 90 08 01 00     movss   dword ptr [rbx+10890h], xmm6
00000001803831F0  F3 0F 11 AB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm5
00000001803831F8  F3 0F 58 B3 10 09 01 00     addss   xmm6, dword ptr [rbx+10910h]
0000000180383200  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180383204  76 1B                       jbe     short loc_180383221
0000000180383206  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018038320B  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018038320F  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180383212  E8 C1 C2 36 00              call    fmodf
0000000180383217  0F 28 F0                    movaps  xmm6, xmm0
000000018038321A  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018038321F  EB 1F                       jmp     short loc_180383240
0000000180383221  41 0F 2F F7                 comiss  xmm6, xmm15
0000000180383225  73 19                       jnb     short loc_180383240
0000000180383227  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018038322C  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180383230  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180383233  E8 A0 C2 36 00              call    fmodf
0000000180383238  0F 28 F0                    movaps  xmm6, xmm0
000000018038323B  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180383240  0F 28 C6                    movaps  xmm0, xmm6
0000000180383243  F3 0F 11 B3 80 08 01 00     movss   dword ptr [rbx+10880h], xmm6
000000018038324B  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180383250  0F 28 FE                    movaps  xmm7, xmm6
0000000180383253  F3 0F 59 BB 70 0C 01 00     mulss   xmm7, dword ptr [rbx+10C70h]
000000018038325B  F3 41 0F 59 C4              mulss   xmm0, xmm12
0000000180383260  E8 5B 5D FE FF              call    sub_180368FC0
0000000180383265  0F 28 E8                    movaps  xmm5, xmm0
0000000180383268  F3 41 0F 59 EB              mulss   xmm5, xmm11
000000018038326D  F3 0F 59 AB 20 09 01 00     mulss   xmm5, dword ptr [rbx+10920h]
0000000180383275  F3 0F 59 AB 40 0C 01 00     mulss   xmm5, dword ptr [rbx+10C40h]
000000018038327D  41 0F 2F EF                 comiss  xmm5, xmm15
0000000180383281  73 06                       jnb     short loc_180383289
0000000180383283  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180383287  EB 05                       jmp     short loc_18038328E
0000000180383289  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018038328E  F3 0F 59 AB 10 0C 01 00     mulss   xmm5, dword ptr [rbx+10C10h]
0000000180383296  0F 28 D5                    movaps  xmm2, xmm5
0000000180383299  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018038329D  0F 28 CA                    movaps  xmm1, xmm2
00000001803832A0  0F 28 C2                    movaps  xmm0, xmm2
00000001803832A3  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00000001803832AB  0F 28 DA                    movaps  xmm3, xmm2
00000001803832AE  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803832B2  0F 28 E2                    movaps  xmm4, xmm2
00000001803832B5  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
00000001803832BD  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00000001803832C5  F3 0F 59 DD                 mulss   xmm3, xmm5
00000001803832C9  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
00000001803832D1  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803832D5  0F 28 C3                    movaps  xmm0, xmm3
00000001803832D8  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00000001803832E0  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803832E4  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803832E8  F3 0F 10 8B 30 09 01 00     movss   xmm1, dword ptr [rbx+10930h]
00000001803832F0  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803832F4  0F 28 C1                    movaps  xmm0, xmm1
00000001803832F7  F3 0F 58 C6                 addss   xmm0, xmm6
00000001803832FB  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803832FF  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180383303  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180383307  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018038330B  F3 0F 11 A3 80 09 01 00     movss   dword ptr [rbx+10980h], xmm4
0000000180383313  72 07                       jb      short loc_18038331C
0000000180383315  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018038331A  EB 05                       jmp     short loc_180383321
000000018038331C  F3 41 0F 5C CD              subss   xmm1, xmm13
0000000180383321  0F 28 F0                    movaps  xmm6, xmm0
0000000180383324  73 06                       jnb     short loc_18038332C
0000000180383326  41 0F 28 F7                 movaps  xmm6, xmm15
000000018038332A  EB 06                       jmp     short loc_180383332
000000018038332C  76 04                       jbe     short loc_180383332
000000018038332E  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180383332  F3 44 0F 10 83 80 08 01 00  movss   xmm8, dword ptr [rbx+10880h]
000000018038333B  F3 0F 59 B3 80 0C 01 00     mulss   xmm6, dword ptr [rbx+10C80h]
0000000180383343  F3 0F 5E C1                 divss   xmm0, xmm1
0000000180383347  E8 74 5C FE FF              call    sub_180368FC0
000000018038334C  0F 28 E0                    movaps  xmm4, xmm0
000000018038334F  F3 0F 10 83 30 0C 01 00     movss   xmm0, dword ptr [rbx+10C30h]
0000000180383357  44 0F 2F C0                 comiss  xmm8, xmm0
000000018038335B  72 18                       jb      short loc_180383375
000000018038335D  0F 2F 83 90 08 01 00        comiss  xmm0, dword ptr [rbx+10890h]
0000000180383364  76 0F                       jbe     short loc_180383375
0000000180383366  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
000000018038336E  F3 41 0F 58 FA              addss   xmm7, xmm10
0000000180383373  EB 08                       jmp     short loc_18038337D
0000000180383375  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
000000018038337D  0F 2F 3D 4C 1F 76 00        comiss  xmm7, cs:dword_180AE52D0
0000000180383384  F3 0F 59 A3 20 09 01 00     mulss   xmm4, dword ptr [rbx+10920h]
000000018038338C  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180383391  F3 0F 59 A3 50 0C 01 00     mulss   xmm4, dword ptr [rbx+10C50h]
0000000180383399  72 03                       jb      short loc_18038339E
000000018038339B  0F 57 FF                    xorps   xmm7, xmm7
000000018038339E  41 0F 2F E7                 comiss  xmm4, xmm15
00000001803833A2  73 06                       jnb     short loc_1803833AA
00000001803833A4  41 0F 28 E7                 movaps  xmm4, xmm15
00000001803833A8  EB 05                       jmp     short loc_1803833AF
00000001803833AA  F3 41 0F 5D E5              minss   xmm4, xmm13
00000001803833AF  F3 0F 11 BB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm7
00000001803833B7  F3 41 0F 58 F8              addss   xmm7, xmm8
00000001803833BC  F3 0F 59 A3 10 0C 01 00     mulss   xmm4, dword ptr [rbx+10C10h]
00000001803833C4  0F 28 D4                    movaps  xmm2, xmm4
00000001803833C7  F3 41 0F 58 FD              addss   xmm7, xmm13
00000001803833CC  F3 0F 59 D4                 mulss   xmm2, xmm4
00000001803833D0  0F 28 C2                    movaps  xmm0, xmm2
00000001803833D3  F3 41 0F 59 FC              mulss   xmm7, xmm12
00000001803833D8  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803833DC  0F 28 DA                    movaps  xmm3, xmm2
00000001803833DF  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803833E3  44 0F 28 CA                 movaps  xmm9, xmm2
00000001803833E7  F3 44 0F 59 8B E0 0D 01 00  mulss   xmm9, dword ptr [rbx+10DE0h]
00000001803833F0  F3 41 0F 5C FD              subss   xmm7, xmm13
00000001803833F5  0F 28 CA                    movaps  xmm1, xmm2
00000001803833F8  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
0000000180383400  F3 44 0F 58 8B D0 0D 01 00  addss   xmm9, dword ptr [rbx+10DD0h]
0000000180383409  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
0000000180383411  F3 44 0F 59 C8              mulss   xmm9, xmm0
0000000180383416  0F 28 C3                    movaps  xmm0, xmm3
0000000180383419  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
0000000180383421  F3 44 0F 58 C9              addss   xmm9, xmm1
0000000180383426  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038342A  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018038342F  0F 28 C7                    movaps  xmm0, xmm7
0000000180383432  0F 54 05 57 23 76 00        andps   xmm0, cs:xmmword_180AE5790
0000000180383439  0F 57 05 80 23 76 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180383440  F3 44 0F 58 CB              addss   xmm9, xmm3
0000000180383445  F3 44 0F 58 CC              addss   xmm9, xmm4
000000018038344A  F3 44 0F 59 CE              mulss   xmm9, xmm6
000000018038344F  F3 44 0F 11 8B 90 09 01 00  movss   dword ptr [rbx+10990h], xmm9
0000000180383458  E8 63 5B FE FF              call    sub_180368FC0
000000018038345D  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180383461  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180383465  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018038346A  73 06                       jnb     short loc_180383472
000000018038346C  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180383470  EB 06                       jmp     short loc_180383478
0000000180383472  76 04                       jbe     short loc_180383478
0000000180383474  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180383478  F3 44 0F 59 83 20 09 01 00  mulss   xmm8, dword ptr [rbx+10920h]
0000000180383481  F3 0F 59 BB 90 0C 01 00     mulss   xmm7, dword ptr [rbx+10C90h]
0000000180383489  F3 44 0F 59 05 06 78 60 00  mulss   xmm8, cs:dword_18098AC98
0000000180383492  F3 44 0F 59 83 60 0C 01 00  mulss   xmm8, dword ptr [rbx+10C60h]
000000018038349B  45 0F 2F C7                 comiss  xmm8, xmm15
000000018038349F  73 06                       jnb     short loc_1803834A7
00000001803834A1  45 0F 28 C7                 movaps  xmm8, xmm15
00000001803834A5  EB 05                       jmp     short loc_1803834AC
00000001803834A7  F3 45 0F 5D C5              minss   xmm8, xmm13
00000001803834AC  F3 44 0F 59 83 10 0C 01 00  mulss   xmm8, dword ptr [rbx+10C10h]
00000001803834B5  F3 44 0F 59 8B F0 08 01 00  mulss   xmm9, dword ptr [rbx+108F0h]
00000001803834BE  F3 0F 10 B3 80 08 01 00     movss   xmm6, dword ptr [rbx+10880h]
00000001803834C6  41 0F 28 D0                 movaps  xmm2, xmm8
00000001803834CA  F3 0F 10 AB A0 08 01 00     movss   xmm5, dword ptr [rbx+108A0h]
00000001803834D2  F3 41 0F 59 D0              mulss   xmm2, xmm8
00000001803834D7  0F 28 C2                    movaps  xmm0, xmm2
00000001803834DA  0F 28 DA                    movaps  xmm3, xmm2
00000001803834DD  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803834E1  0F 28 E2                    movaps  xmm4, xmm2
00000001803834E4  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
00000001803834EC  0F 28 CA                    movaps  xmm1, xmm2
00000001803834EF  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00000001803834F7  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
00000001803834FF  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180383504  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
000000018038350C  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180383510  0F 28 C3                    movaps  xmm0, xmm3
0000000180383513  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
000000018038351B  F3 0F 58 E1                 addss   xmm4, xmm1
000000018038351F  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180383523  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180383527  F3 0F 10 83 80 09 01 00     movss   xmm0, dword ptr [rbx+10980h]
000000018038352F  F3 0F 59 83 E0 08 01 00     mulss   xmm0, dword ptr [rbx+108E0h]
0000000180383537  F3 0F 58 E3                 addss   xmm4, xmm3
000000018038353B  F3 41 0F 58 C1              addss   xmm0, xmm9
0000000180383540  F3 41 0F 58 E0              addss   xmm4, xmm8
0000000180383545  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180383549  F3 0F 59 A3 00 09 01 00     mulss   xmm4, dword ptr [rbx+10900h]
0000000180383551  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180383555  F3 0F 11 A3 30 0A 01 00     movss   dword ptr [rbx+10A30h], xmm4
000000018038355D  F3 0F 11 B3 90 08 01 00     movss   dword ptr [rbx+10890h], xmm6
0000000180383565  F3 0F 11 AB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm5
000000018038356D  F3 0F 58 B3 10 09 01 00     addss   xmm6, dword ptr [rbx+10910h]
0000000180383575  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180383579  76 1B                       jbe     short loc_180383596
000000018038357B  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180383580  41 0F 28 CA                 movaps  xmm1, xmm10; Y
0000000180383584  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180383587  E8 4C BF 36 00              call    fmodf
000000018038358C  0F 28 F0                    movaps  xmm6, xmm0
000000018038358F  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180383594  EB 1F                       jmp     short loc_1803835B5
0000000180383596  41 0F 2F F7                 comiss  xmm6, xmm15
000000018038359A  73 19                       jnb     short loc_1803835B5
000000018038359C  F3 41 0F 5C F5              subss   xmm6, xmm13
00000001803835A1  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00000001803835A5  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803835A8  E8 2B BF 36 00              call    fmodf
00000001803835AD  0F 28 F0                    movaps  xmm6, xmm0
00000001803835B0  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803835B5  0F 28 C6                    movaps  xmm0, xmm6
00000001803835B8  F3 0F 11 B3 80 08 01 00     movss   dword ptr [rbx+10880h], xmm6
00000001803835C0  F3 41 0F 58 C5              addss   xmm0, xmm13
00000001803835C5  0F 28 FE                    movaps  xmm7, xmm6
00000001803835C8  F3 0F 59 BB 70 0C 01 00     mulss   xmm7, dword ptr [rbx+10C70h]
00000001803835D0  F3 41 0F 59 C4              mulss   xmm0, xmm12
00000001803835D5  E8 E6 59 FE FF              call    sub_180368FC0
00000001803835DA  0F 28 E8                    movaps  xmm5, xmm0
00000001803835DD  F3 41 0F 59 EB              mulss   xmm5, xmm11
00000001803835E2  F3 0F 59 AB 20 09 01 00     mulss   xmm5, dword ptr [rbx+10920h]
00000001803835EA  F3 0F 59 AB 40 0C 01 00     mulss   xmm5, dword ptr [rbx+10C40h]
00000001803835F2  41 0F 2F EF                 comiss  xmm5, xmm15
00000001803835F6  73 06                       jnb     short loc_1803835FE
00000001803835F8  41 0F 28 EF                 movaps  xmm5, xmm15
00000001803835FC  EB 05                       jmp     short loc_180383603
00000001803835FE  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180383603  F3 0F 59 AB 10 0C 01 00     mulss   xmm5, dword ptr [rbx+10C10h]
000000018038360B  0F 28 D5                    movaps  xmm2, xmm5
000000018038360E  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180383612  0F 28 CA                    movaps  xmm1, xmm2
0000000180383615  0F 28 C2                    movaps  xmm0, xmm2
0000000180383618  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
0000000180383620  0F 28 DA                    movaps  xmm3, xmm2
0000000180383623  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180383627  0F 28 E2                    movaps  xmm4, xmm2
000000018038362A  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
0000000180383632  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
000000018038363A  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018038363E  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
0000000180383646  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018038364A  0F 28 C3                    movaps  xmm0, xmm3
000000018038364D  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
0000000180383655  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180383659  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038365D  F3 0F 10 8B 30 09 01 00     movss   xmm1, dword ptr [rbx+10930h]
0000000180383665  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180383669  0F 28 C1                    movaps  xmm0, xmm1
000000018038366C  F3 0F 58 C6                 addss   xmm0, xmm6
0000000180383670  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180383674  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180383678  F3 0F 58 E5                 addss   xmm4, xmm5
000000018038367C  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180383680  F3 0F 11 A3 80 09 01 00     movss   dword ptr [rbx+10980h], xmm4
0000000180383688  72 07                       jb      short loc_180383691
000000018038368A  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018038368F  EB 05                       jmp     short loc_180383696
0000000180383691  F3 41 0F 5C CD              subss   xmm1, xmm13
0000000180383696  0F 28 F0                    movaps  xmm6, xmm0
0000000180383699  73 06                       jnb     short loc_1803836A1
000000018038369B  41 0F 28 F7                 movaps  xmm6, xmm15
000000018038369F  EB 06                       jmp     short loc_1803836A7
00000001803836A1  76 04                       jbe     short loc_1803836A7
00000001803836A3  41 0F 28 F5                 movaps  xmm6, xmm13
00000001803836A7  F3 44 0F 10 83 80 08 01 00  movss   xmm8, dword ptr [rbx+10880h]
00000001803836B0  F3 0F 59 B3 80 0C 01 00     mulss   xmm6, dword ptr [rbx+10C80h]
00000001803836B8  F3 0F 5E C1                 divss   xmm0, xmm1
00000001803836BC  E8 FF 58 FE FF              call    sub_180368FC0
00000001803836C1  0F 28 E0                    movaps  xmm4, xmm0
00000001803836C4  F3 0F 10 83 30 0C 01 00     movss   xmm0, dword ptr [rbx+10C30h]
00000001803836CC  44 0F 2F C0                 comiss  xmm8, xmm0
00000001803836D0  72 18                       jb      short loc_1803836EA
00000001803836D2  0F 2F 83 90 08 01 00        comiss  xmm0, dword ptr [rbx+10890h]
00000001803836D9  76 0F                       jbe     short loc_1803836EA
00000001803836DB  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
00000001803836E3  F3 41 0F 58 FA              addss   xmm7, xmm10
00000001803836E8  EB 08                       jmp     short loc_1803836F2
00000001803836EA  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
00000001803836F2  0F 2F 3D D7 1B 76 00        comiss  xmm7, cs:dword_180AE52D0
00000001803836F9  F3 0F 59 A3 20 09 01 00     mulss   xmm4, dword ptr [rbx+10920h]
0000000180383701  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180383706  F3 0F 59 A3 50 0C 01 00     mulss   xmm4, dword ptr [rbx+10C50h]
000000018038370E  72 03                       jb      short loc_180383713
0000000180383710  0F 57 FF                    xorps   xmm7, xmm7
0000000180383713  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180383717  73 06                       jnb     short loc_18038371F
0000000180383719  41 0F 28 E7                 movaps  xmm4, xmm15
000000018038371D  EB 05                       jmp     short loc_180383724
000000018038371F  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180383724  F3 0F 11 BB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm7
000000018038372C  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180383731  F3 0F 59 A3 10 0C 01 00     mulss   xmm4, dword ptr [rbx+10C10h]
0000000180383739  0F 28 D4                    movaps  xmm2, xmm4
000000018038373C  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180383741  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180383745  0F 28 C2                    movaps  xmm0, xmm2
0000000180383748  F3 41 0F 59 FC              mulss   xmm7, xmm12
000000018038374D  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180383751  0F 28 DA                    movaps  xmm3, xmm2
0000000180383754  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180383758  44 0F 28 CA                 movaps  xmm9, xmm2
000000018038375C  F3 44 0F 59 8B E0 0D 01 00  mulss   xmm9, dword ptr [rbx+10DE0h]
0000000180383765  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018038376A  0F 28 CA                    movaps  xmm1, xmm2
000000018038376D  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
0000000180383775  F3 44 0F 58 8B D0 0D 01 00  addss   xmm9, dword ptr [rbx+10DD0h]
000000018038377E  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
0000000180383786  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018038378B  0F 28 C3                    movaps  xmm0, xmm3
000000018038378E  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
0000000180383796  F3 44 0F 58 C9              addss   xmm9, xmm1
000000018038379B  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038379F  F3 44 0F 59 C8              mulss   xmm9, xmm0
00000001803837A4  0F 28 C7                    movaps  xmm0, xmm7
00000001803837A7  0F 54 05 E2 1F 76 00        andps   xmm0, cs:xmmword_180AE5790
00000001803837AE  0F 57 05 0B 20 76 00        xorps   xmm0, cs:xmmword_180AE57C0
00000001803837B5  F3 44 0F 58 CB              addss   xmm9, xmm3
00000001803837BA  F3 44 0F 58 CC              addss   xmm9, xmm4
00000001803837BF  F3 44 0F 59 CE              mulss   xmm9, xmm6
00000001803837C4  F3 44 0F 11 8B 90 09 01 00  movss   dword ptr [rbx+10990h], xmm9
00000001803837CD  E8 EE 57 FE FF              call    sub_180368FC0
00000001803837D2  41 0F 2F FE                 comiss  xmm7, xmm14
00000001803837D6  44 0F 28 C0                 movaps  xmm8, xmm0
00000001803837DA  F3 45 0F 58 C5              addss   xmm8, xmm13
00000001803837DF  73 06                       jnb     short loc_1803837E7
00000001803837E1  41 0F 28 FF                 movaps  xmm7, xmm15
00000001803837E5  EB 06                       jmp     short loc_1803837ED
00000001803837E7  76 04                       jbe     short loc_1803837ED
00000001803837E9  41 0F 28 FD                 movaps  xmm7, xmm13
00000001803837ED  F3 44 0F 59 83 20 09 01 00  mulss   xmm8, dword ptr [rbx+10920h]
00000001803837F6  F3 0F 59 BB 90 0C 01 00     mulss   xmm7, dword ptr [rbx+10C90h]
00000001803837FE  F3 44 0F 59 05 91 74 60 00  mulss   xmm8, cs:dword_18098AC98
0000000180383807  F3 44 0F 59 83 60 0C 01 00  mulss   xmm8, dword ptr [rbx+10C60h]
0000000180383810  45 0F 2F C7                 comiss  xmm8, xmm15
0000000180383814  73 06                       jnb     short loc_18038381C
0000000180383816  45 0F 28 C7                 movaps  xmm8, xmm15
000000018038381A  EB 05                       jmp     short loc_180383821
000000018038381C  F3 45 0F 5D C5              minss   xmm8, xmm13
0000000180383821  F3 44 0F 59 83 10 0C 01 00  mulss   xmm8, dword ptr [rbx+10C10h]
000000018038382A  F3 44 0F 59 8B F0 08 01 00  mulss   xmm9, dword ptr [rbx+108F0h]
0000000180383833  F3 0F 10 B3 80 08 01 00     movss   xmm6, dword ptr [rbx+10880h]
000000018038383B  41 0F 28 D0                 movaps  xmm2, xmm8
000000018038383F  F3 0F 10 AB A0 08 01 00     movss   xmm5, dword ptr [rbx+108A0h]
0000000180383847  F3 41 0F 59 D0              mulss   xmm2, xmm8
000000018038384C  0F 28 C2                    movaps  xmm0, xmm2
000000018038384F  0F 28 DA                    movaps  xmm3, xmm2
0000000180383852  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180383856  0F 28 E2                    movaps  xmm4, xmm2
0000000180383859  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
0000000180383861  0F 28 CA                    movaps  xmm1, xmm2
0000000180383864  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
000000018038386C  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
0000000180383874  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180383879  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
0000000180383881  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180383885  0F 28 C3                    movaps  xmm0, xmm3
0000000180383888  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
0000000180383890  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180383894  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180383898  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018038389C  F3 0F 10 83 80 09 01 00     movss   xmm0, dword ptr [rbx+10980h]
00000001803838A4  F3 0F 59 83 E0 08 01 00     mulss   xmm0, dword ptr [rbx+108E0h]
00000001803838AC  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803838B0  F3 41 0F 58 C1              addss   xmm0, xmm9
00000001803838B5  F3 41 0F 58 E0              addss   xmm4, xmm8
00000001803838BA  F3 0F 59 E7                 mulss   xmm4, xmm7
00000001803838BE  F3 0F 59 A3 00 09 01 00     mulss   xmm4, dword ptr [rbx+10900h]
00000001803838C6  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803838CA  F3 0F 11 A3 B0 0A 01 00     movss   dword ptr [rbx+10AB0h], xmm4
00000001803838D2  F3 0F 11 B3 90 08 01 00     movss   dword ptr [rbx+10890h], xmm6
00000001803838DA  F3 0F 11 AB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm5
00000001803838E2  F3 0F 58 B3 10 09 01 00     addss   xmm6, dword ptr [rbx+10910h]
00000001803838EA  41 0F 2F F5                 comiss  xmm6, xmm13
00000001803838EE  76 1B                       jbe     short loc_18038390B
00000001803838F0  F3 41 0F 58 F5              addss   xmm6, xmm13
00000001803838F5  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00000001803838F9  0F 28 C6                    movaps  xmm0, xmm6; X
00000001803838FC  E8 D7 BB 36 00              call    fmodf
0000000180383901  0F 28 F0                    movaps  xmm6, xmm0
0000000180383904  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180383909  EB 1F                       jmp     short loc_18038392A
000000018038390B  41 0F 2F F7                 comiss  xmm6, xmm15
000000018038390F  73 19                       jnb     short loc_18038392A
0000000180383911  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180383916  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018038391A  0F 28 C6                    movaps  xmm0, xmm6; X
000000018038391D  E8 B6 BB 36 00              call    fmodf
0000000180383922  0F 28 F0                    movaps  xmm6, xmm0
0000000180383925  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018038392A  0F 28 C6                    movaps  xmm0, xmm6
000000018038392D  F3 0F 11 B3 80 08 01 00     movss   dword ptr [rbx+10880h], xmm6
0000000180383935  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018038393A  0F 28 FE                    movaps  xmm7, xmm6
000000018038393D  F3 0F 59 BB 70 0C 01 00     mulss   xmm7, dword ptr [rbx+10C70h]
0000000180383945  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018038394A  E8 71 56 FE FF              call    sub_180368FC0
000000018038394F  0F 28 E8                    movaps  xmm5, xmm0
0000000180383952  F3 41 0F 59 EB              mulss   xmm5, xmm11
0000000180383957  F3 0F 59 AB 20 09 01 00     mulss   xmm5, dword ptr [rbx+10920h]
000000018038395F  F3 0F 59 AB 40 0C 01 00     mulss   xmm5, dword ptr [rbx+10C40h]
0000000180383967  41 0F 2F EF                 comiss  xmm5, xmm15
000000018038396B  73 06                       jnb     short loc_180383973
000000018038396D  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180383971  EB 05                       jmp     short loc_180383978
0000000180383973  F3 41 0F 5D ED              minss   xmm5, xmm13
0000000180383978  F3 0F 59 AB 10 0C 01 00     mulss   xmm5, dword ptr [rbx+10C10h]
0000000180383980  0F 28 D5                    movaps  xmm2, xmm5
0000000180383983  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180383987  0F 28 CA                    movaps  xmm1, xmm2
000000018038398A  0F 28 C2                    movaps  xmm0, xmm2
000000018038398D  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
0000000180383995  0F 28 DA                    movaps  xmm3, xmm2
0000000180383998  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018038399C  0F 28 E2                    movaps  xmm4, xmm2
000000018038399F  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
00000001803839A7  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00000001803839AF  F3 0F 59 DD                 mulss   xmm3, xmm5
00000001803839B3  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
00000001803839BB  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803839BF  0F 28 C3                    movaps  xmm0, xmm3
00000001803839C2  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00000001803839CA  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803839CE  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803839D2  F3 0F 10 8B 30 09 01 00     movss   xmm1, dword ptr [rbx+10930h]
00000001803839DA  F3 0F 59 E0                 mulss   xmm4, xmm0
00000001803839DE  0F 28 C1                    movaps  xmm0, xmm1
00000001803839E1  F3 0F 58 C6                 addss   xmm0, xmm6
00000001803839E5  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803839E9  41 0F 2F C6                 comiss  xmm0, xmm14
00000001803839ED  F3 0F 58 E5                 addss   xmm4, xmm5
00000001803839F1  F3 0F 59 E7                 mulss   xmm4, xmm7
00000001803839F5  F3 0F 11 A3 80 09 01 00     movss   dword ptr [rbx+10980h], xmm4
00000001803839FD  72 07                       jb      short loc_180383A06
00000001803839FF  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180383A04  EB 05                       jmp     short loc_180383A0B
0000000180383A06  F3 41 0F 5C CD              subss   xmm1, xmm13
0000000180383A0B  0F 28 F0                    movaps  xmm6, xmm0
0000000180383A0E  73 06                       jnb     short loc_180383A16
0000000180383A10  41 0F 28 F7                 movaps  xmm6, xmm15
0000000180383A14  EB 06                       jmp     short loc_180383A1C
0000000180383A16  76 04                       jbe     short loc_180383A1C
0000000180383A18  41 0F 28 F5                 movaps  xmm6, xmm13
0000000180383A1C  F3 44 0F 10 83 80 08 01 00  movss   xmm8, dword ptr [rbx+10880h]
0000000180383A25  F3 0F 59 B3 80 0C 01 00     mulss   xmm6, dword ptr [rbx+10C80h]
0000000180383A2D  F3 0F 5E C1                 divss   xmm0, xmm1
0000000180383A31  E8 8A 55 FE FF              call    sub_180368FC0
0000000180383A36  0F 28 E0                    movaps  xmm4, xmm0
0000000180383A39  F3 0F 10 83 30 0C 01 00     movss   xmm0, dword ptr [rbx+10C30h]
0000000180383A41  44 0F 2F C0                 comiss  xmm8, xmm0
0000000180383A45  72 18                       jb      short loc_180383A5F
0000000180383A47  0F 2F 83 90 08 01 00        comiss  xmm0, dword ptr [rbx+10890h]
0000000180383A4E  76 0F                       jbe     short loc_180383A5F
0000000180383A50  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
0000000180383A58  F3 41 0F 58 FA              addss   xmm7, xmm10
0000000180383A5D  EB 08                       jmp     short loc_180383A67
0000000180383A5F  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
0000000180383A67  0F 2F 3D 62 18 76 00        comiss  xmm7, cs:dword_180AE52D0
0000000180383A6E  F3 0F 59 A3 20 09 01 00     mulss   xmm4, dword ptr [rbx+10920h]
0000000180383A76  F3 41 0F 59 E3              mulss   xmm4, xmm11
0000000180383A7B  F3 0F 59 A3 50 0C 01 00     mulss   xmm4, dword ptr [rbx+10C50h]
0000000180383A83  72 03                       jb      short loc_180383A88
0000000180383A85  0F 57 FF                    xorps   xmm7, xmm7
0000000180383A88  41 0F 2F E7                 comiss  xmm4, xmm15
0000000180383A8C  73 06                       jnb     short loc_180383A94
0000000180383A8E  41 0F 28 E7                 movaps  xmm4, xmm15
0000000180383A92  EB 05                       jmp     short loc_180383A99
0000000180383A94  F3 41 0F 5D E5              minss   xmm4, xmm13
0000000180383A99  F3 0F 11 BB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm7
0000000180383AA1  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180383AA6  F3 0F 59 A3 10 0C 01 00     mulss   xmm4, dword ptr [rbx+10C10h]
0000000180383AAE  0F 28 D4                    movaps  xmm2, xmm4
0000000180383AB1  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180383AB6  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180383ABA  0F 28 C2                    movaps  xmm0, xmm2
0000000180383ABD  F3 41 0F 59 FC              mulss   xmm7, xmm12
0000000180383AC2  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180383AC6  0F 28 DA                    movaps  xmm3, xmm2
0000000180383AC9  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180383ACD  44 0F 28 C2                 movaps  xmm8, xmm2
0000000180383AD1  F3 44 0F 59 83 E0 0D 01 00  mulss   xmm8, dword ptr [rbx+10DE0h]
0000000180383ADA  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180383ADF  0F 28 CA                    movaps  xmm1, xmm2
0000000180383AE2  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
0000000180383AEA  F3 44 0F 58 83 D0 0D 01 00  addss   xmm8, dword ptr [rbx+10DD0h]
0000000180383AF3  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
0000000180383AFB  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180383B00  0F 28 C3                    movaps  xmm0, xmm3
0000000180383B03  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
0000000180383B0B  F3 44 0F 58 C1              addss   xmm8, xmm1
0000000180383B10  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180383B14  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180383B19  0F 28 C7                    movaps  xmm0, xmm7
0000000180383B1C  0F 54 05 6D 1C 76 00        andps   xmm0, cs:xmmword_180AE5790
0000000180383B23  0F 57 05 96 1C 76 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180383B2A  F3 44 0F 58 C3              addss   xmm8, xmm3
0000000180383B2F  F3 44 0F 58 C4              addss   xmm8, xmm4
0000000180383B34  F3 44 0F 59 C6              mulss   xmm8, xmm6
0000000180383B39  F3 44 0F 11 83 90 09 01 00  movss   dword ptr [rbx+10990h], xmm8
0000000180383B42  E8 79 54 FE FF              call    sub_180368FC0
0000000180383B47  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180383B4B  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180383B50  73 06                       jnb     short loc_180383B58
0000000180383B52  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180383B56  EB 06                       jmp     short loc_180383B5E
0000000180383B58  76 04                       jbe     short loc_180383B5E
0000000180383B5A  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180383B5E  F3 0F 59 83 20 09 01 00     mulss   xmm0, dword ptr [rbx+10920h]
0000000180383B66  F3 0F 59 BB 90 0C 01 00     mulss   xmm7, dword ptr [rbx+10C90h]
0000000180383B6E  F3 0F 59 05 22 71 60 00     mulss   xmm0, cs:dword_18098AC98
0000000180383B76  F3 0F 59 83 60 0C 01 00     mulss   xmm0, dword ptr [rbx+10C60h]
0000000180383B7E  41 0F 2F C7                 comiss  xmm0, xmm15
0000000180383B82  72 09                       jb      short loc_180383B8D
0000000180383B84  44 0F 28 F8                 movaps  xmm15, xmm0
0000000180383B88  F3 45 0F 5D FD              minss   xmm15, xmm13
0000000180383B8D  F3 44 0F 59 BB 10 0C 01 00  mulss   xmm15, dword ptr [rbx+10C10h]
0000000180383B96  F3 44 0F 59 83 F0 08 01 00  mulss   xmm8, dword ptr [rbx+108F0h]
0000000180383B9F  F3 0F 10 AB 80 08 01 00     movss   xmm5, dword ptr [rbx+10880h]
0000000180383BA7  41 0F 28 D7                 movaps  xmm2, xmm15
0000000180383BAB  F3 0F 10 B3 A0 08 01 00     movss   xmm6, dword ptr [rbx+108A0h]
0000000180383BB3  F3 41 0F 59 D7              mulss   xmm2, xmm15
0000000180383BB8  0F 28 CA                    movaps  xmm1, xmm2
0000000180383BBB  0F 28 C2                    movaps  xmm0, xmm2
0000000180383BBE  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
0000000180383BC6  0F 28 DA                    movaps  xmm3, xmm2
0000000180383BC9  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180383BCD  0F 28 E2                    movaps  xmm4, xmm2
0000000180383BD0  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
0000000180383BD8  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
0000000180383BE0  F3 41 0F 59 DF              mulss   xmm3, xmm15
0000000180383BE5  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
0000000180383BED  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180383BF1  0F 28 C3                    movaps  xmm0, xmm3
0000000180383BF4  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
0000000180383BFC  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180383C00  F3 0F 58 E1                 addss   xmm4, xmm1
0000000180383C04  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180383C08  F3 0F 10 83 80 09 01 00     movss   xmm0, dword ptr [rbx+10980h]
0000000180383C10  F3 0F 59 83 E0 08 01 00     mulss   xmm0, dword ptr [rbx+108E0h]
0000000180383C18  F3 0F 58 E3                 addss   xmm4, xmm3
0000000180383C1C  F3 41 0F 58 C0              addss   xmm0, xmm8
0000000180383C21  F3 41 0F 58 E7              addss   xmm4, xmm15
0000000180383C26  F3 0F 59 E7                 mulss   xmm4, xmm7
0000000180383C2A  F3 0F 59 A3 00 09 01 00     mulss   xmm4, dword ptr [rbx+10900h]
0000000180383C32  F3 0F 58 E0                 addss   xmm4, xmm0
0000000180383C36  F3 0F 11 A3 30 0B 01 00     movss   dword ptr [rbx+10B30h], xmm4
0000000180383C3E  F3 0F 10 93 A0 0B 01 00     movss   xmm2, dword ptr [rbx+10BA0h]
0000000180383C46  F3 0F 11 AB 60 09 01 00     movss   dword ptr [rbx+10960h], xmm5
0000000180383C4E  F3 0F 11 B3 40 09 01 00     movss   dword ptr [rbx+10940h], xmm6
0000000180383C56  F3 0F 10 83 B0 0A 01 00     movss   xmm0, dword ptr [rbx+10AB0h]
0000000180383C5E  F3 0F 58 83 A0 0A 01 00     addss   xmm0, dword ptr [rbx+10AA0h]
0000000180383C66  F3 0F 10 8B 30 0B 01 00     movss   xmm1, dword ptr [rbx+10B30h]
0000000180383C6E  F3 0F 58 8B 20 0A 01 00     addss   xmm1, dword ptr [rbx+10A20h]
0000000180383C76  F3 0F 10 AB 20 0B 01 00     movss   xmm5, dword ptr [rbx+10B20h]
0000000180383C7E  F3 0F 58 AB 30 0A 01 00     addss   xmm5, dword ptr [rbx+10A30h]
0000000180383C86  F3 0F 59 83 C0 0C 01 00     mulss   xmm0, dword ptr [rbx+10CC0h]
0000000180383C8E  F3 0F 59 8B D0 0C 01 00     mulss   xmm1, dword ptr [rbx+10CD0h]
0000000180383C96  F3 0F 59 AB B0 0C 01 00     mulss   xmm5, dword ptr [rbx+10CB0h]
0000000180383C9E  F3 0F 58 93 B0 09 01 00     addss   xmm2, dword ptr [rbx+109B0h]
0000000180383CA6  F3 0F 59 93 A0 0C 01 00     mulss   xmm2, dword ptr [rbx+10CA0h]
0000000180383CAE  F3 0F 58 EA                 addss   xmm5, xmm2
0000000180383CB2  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180383CB6  F3 0F 10 83 90 0B 01 00     movss   xmm0, dword ptr [rbx+10B90h]
0000000180383CBE  F3 0F 58 83 C0 09 01 00     addss   xmm0, dword ptr [rbx+109C0h]
0000000180383CC6  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180383CCA  F3 0F 10 8B 10 0B 01 00     movss   xmm1, dword ptr [rbx+10B10h]
0000000180383CD2  F3 0F 59 83 E0 0C 01 00     mulss   xmm0, dword ptr [rbx+10CE0h]
0000000180383CDA  F3 0F 58 8B 40 0A 01 00     addss   xmm1, dword ptr [rbx+10A40h]
0000000180383CE2  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180383CE6  F3 0F 10 83 C0 0A 01 00     movss   xmm0, dword ptr [rbx+10AC0h]
0000000180383CEE  F3 0F 58 83 90 0A 01 00     addss   xmm0, dword ptr [rbx+10A90h]
0000000180383CF6  F3 0F 59 8B F0 0C 01 00     mulss   xmm1, dword ptr [rbx+10CF0h]
0000000180383CFE  F3 0F 59 83 00 0D 01 00     mulss   xmm0, dword ptr [rbx+10D00h]
0000000180383D06  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180383D0A  F3 0F 10 8B 40 0B 01 00     movss   xmm1, dword ptr [rbx+10B40h]
0000000180383D12  F3 0F 58 8B 10 0A 01 00     addss   xmm1, dword ptr [rbx+10A10h]
0000000180383D1A  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180383D1E  F3 0F 10 83 80 0B 01 00     movss   xmm0, dword ptr [rbx+10B80h]
0000000180383D26  F3 0F 59 8B 10 0D 01 00     mulss   xmm1, dword ptr [rbx+10D10h]
0000000180383D2E  F3 0F 58 83 D0 09 01 00     addss   xmm0, dword ptr [rbx+109D0h]
0000000180383D36  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180383D3A  F3 0F 10 8B 50 0A 01 00     movss   xmm1, dword ptr [rbx+10A50h]
0000000180383D42  F3 0F 58 8B 00 0B 01 00     addss   xmm1, dword ptr [rbx+10B00h]
0000000180383D4A  F3 0F 59 83 20 0D 01 00     mulss   xmm0, dword ptr [rbx+10D20h]
0000000180383D52  F3 0F 59 8B 30 0D 01 00     mulss   xmm1, dword ptr [rbx+10D30h]
0000000180383D5A  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180383D5E  F3 0F 10 83 D0 0A 01 00     movss   xmm0, dword ptr [rbx+10AD0h]
0000000180383D66  F3 0F 58 83 80 0A 01 00     addss   xmm0, dword ptr [rbx+10A80h]
0000000180383D6E  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180383D72  F3 0F 10 8B 00 0A 01 00     movss   xmm1, dword ptr [rbx+10A00h]
0000000180383D7A  F3 0F 59 83 40 0D 01 00     mulss   xmm0, dword ptr [rbx+10D40h]
0000000180383D82  F3 0F 58 8B 50 0B 01 00     addss   xmm1, dword ptr [rbx+10B50h]
0000000180383D8A  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180383D8E  F3 0F 10 83 70 0B 01 00     movss   xmm0, dword ptr [rbx+10B70h]
0000000180383D96  F3 0F 59 8B 50 0D 01 00     mulss   xmm1, dword ptr [rbx+10D50h]
0000000180383D9E  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180383DA2  F3 0F 58 83 E0 09 01 00     addss   xmm0, dword ptr [rbx+109E0h]
0000000180383DAA  F3 0F 10 93 D0 0B 01 00     movss   xmm2, dword ptr [rbx+10BD0h]
0000000180383DB2  F3 0F 10 8B F0 0A 01 00     movss   xmm1, dword ptr [rbx+10AF0h]
0000000180383DBA  0F 28 E2                    movaps  xmm4, xmm2
0000000180383DBD  F3 0F 59 A3 D0 0E 01 00     mulss   xmm4, dword ptr [rbx+10ED0h]
0000000180383DC5  F3 0F 59 83 60 0D 01 00     mulss   xmm0, dword ptr [rbx+10D60h]
0000000180383DCD  F3 0F 58 A3 E0 0B 01 00     addss   xmm4, dword ptr [rbx+10BE0h]
0000000180383DD5  F3 0F 58 8B 60 0A 01 00     addss   xmm1, dword ptr [rbx+10A60h]
0000000180383DDD  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180383DE1  F3 0F 10 83 E0 0A 01 00     movss   xmm0, dword ptr [rbx+10AE0h]
0000000180383DE9  F3 0F 58 83 70 0A 01 00     addss   xmm0, dword ptr [rbx+10A70h]
0000000180383DF1  F3 0F 59 8B 70 0D 01 00     mulss   xmm1, dword ptr [rbx+10D70h]
0000000180383DF9  F3 0F 59 83 80 0D 01 00     mulss   xmm0, dword ptr [rbx+10D80h]
0000000180383E01  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180383E05  F3 0F 10 8B 60 0B 01 00     movss   xmm1, dword ptr [rbx+10B60h]
0000000180383E0D  F3 0F 58 8B F0 09 01 00     addss   xmm1, dword ptr [rbx+109F0h]
0000000180383E15  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180383E19  0F 28 C2                    movaps  xmm0, xmm2
0000000180383E1C  F3 0F 59 8B 90 0D 01 00     mulss   xmm1, dword ptr [rbx+10D90h]
0000000180383E24  F3 0F 11 A3 D0 0B 01 00     movss   dword ptr [rbx+10BD0h], xmm4
0000000180383E2C  F3 0F 59 83 E0 0E 01 00     mulss   xmm0, dword ptr [rbx+10EE0h]
0000000180383E34  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180383E38  F3 0F 58 C4                 addss   xmm0, xmm4
0000000180383E3C  0F 28 DD                    movaps  xmm3, xmm5
0000000180383E3F  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180383E43  0F 28 C3                    movaps  xmm0, xmm3
0000000180383E46  F3 0F 59 83 D0 0E 01 00     mulss   xmm0, dword ptr [rbx+10ED0h]
0000000180383E4E  F3 0F 58 C2                 addss   xmm0, xmm2
0000000180383E52  F3 0F 11 83 C0 0B 01 00     movss   dword ptr [rbx+10BC0h], xmm0
0000000180383E5A  F3 0F 10 93 20 0F 01 00     movss   xmm2, dword ptr [rbx+10F20h]
0000000180383E62  F3 0F 59 9B B0 0B 01 00     mulss   xmm3, dword ptr [rbx+10BB0h]
0000000180383E6A  F3 0F 5C E3                 subss   xmm4, xmm3
0000000180383E6E  F3 0F 59 E2                 mulss   xmm4, xmm2
0000000180383E72  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180383E76  F3 0F 5C E2                 subss   xmm4, xmm2
0000000180383E7A  F3 0F 58 E5                 addss   xmm4, xmm5
0000000180383E7E  F3 0F 11 A3 A0 09 01 00     movss   dword ptr [rbx+109A0h], xmm4
0000000180383E86  F3 0F 11 A3 20 04 01 00     movss   dword ptr [rbx+10420h], xmm4
0000000180383E8E  44 0F 2E AB 40 8D 01 00     ucomiss xmm13, dword ptr [rbx+18D40h]
0000000180383E96  75 28                       jnz     short loc_180383EC0
0000000180383E98  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
0000000180383EA1  F3 0F 11 83 A0 F7 00 00     movss   dword ptr [rbx+0F7A0h], xmm0
0000000180383EA9  C7 83 40 8D 01 00 00 00 00 00  mov     dword ptr [rbx+18D40h], 0
0000000180383EB3  0F 1F 40 00                 nop     dword ptr [rax+00h]
0000000180383EB7  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
0000000180383EC0  8B 83 10 20 01 00           mov     eax, [rbx+12010h]
0000000180383EC6  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
0000000180383ECE  48 8B 0F                    mov     rcx, [rdi]
0000000180383ED1  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
0000000180383ED6  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
0000000180383EDB  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
0000000180383EE0  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
0000000180383EE5  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
0000000180383EEA  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
0000000180383EEF  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
0000000180383EF4  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
0000000180383EF9  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
0000000180383EFF  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
0000000180383F05  89 01                       mov     [rcx], eax
0000000180383F07  8B 83 10 20 01 00           mov     eax, [rbx+12010h]
0000000180383F0D  48 8B 4F 08                 mov     rcx, [rdi+8]
0000000180383F11  49 8B 5B 18                 mov     rbx, [r11+18h]
0000000180383F15  89 01                       mov     [rcx], eax
0000000180383F17  49 8B E3                    mov     rsp, r11
0000000180383F1A  5F                          pop     rdi
0000000180383F1B  C3                          retn
