; sub_7FF91DFE0190 @ rva 0x380190

00007FF91DFE0190  48 8B C4                    mov     rax, rsp
00007FF91DFE0193  48 89 58 10                 mov     [rax+10h], rbx
00007FF91DFE0197  57                          push    rdi
00007FF91DFE0198  48 81 EC C0 00 00 00        sub     rsp, 0C0h
00007FF91DFE019F  F3 0F 10 A1 A0 F7 00 00     movss   xmm4, dword ptr [rcx+0F7A0h]
00007FF91DFE01A7  48 8B FA                    mov     rdi, rdx
00007FF91DFE01AA  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
00007FF91DFE01AE  48 8B D9                    mov     rbx, rcx
00007FF91DFE01B1  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
00007FF91DFE01B5  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00007FF91DFE01BA  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00007FF91DFE01BF  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00007FF91DFE01C4  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00007FF91DFE01C9  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00007FF91DFE01CE  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00007FF91DFE01D4  F3 44 0F 10 2D D7 4E 76 00  movss   xmm13, cs:dword_7FF91E7450B4
00007FF91DFE01DD  44 0F 2E A9 40 8D 01 00     ucomiss xmm13, dword ptr [rcx+18D40h]
00007FF91DFE01E5  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00007FF91DFE01EB  45 0F 57 F6                 xorps   xmm14, xmm14
00007FF91DFE01EF  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
00007FF91DFE01F9  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00007FF91DFE01FF  75 16                       jnz     short loc_7FF91DFE0217
00007FF91DFE0201  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
00007FF91DFE020A  0F 57 E4                    xorps   xmm4, xmm4
00007FF91DFE020D  C7 81 A0 F7 00 00 00 00 00 00  mov     dword ptr [rcx+0F7A0h], 0
00007FF91DFE0217  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
00007FF91DFE021F  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
00007FF91DFE0227  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
00007FF91DFE022F  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
00007FF91DFE0237  F3 0F 59 05 85 AB 60 00     mulss   xmm0, cs:dword_7FF91E5EADC4
00007FF91DFE023F  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
00007FF91DFE0247  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
00007FF91DFE024F  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFE0253  85 D2                       test    edx, edx
00007FF91DFE0255  75 07                       jnz     short loc_7FF91DFE025E
00007FF91DFE0257  BA 01 00 00 00              mov     edx, 1
00007FF91DFE025C  EB 24                       jmp     short loc_7FF91DFE0282
00007FF91DFE025E  8B C2                       mov     eax, edx
00007FF91DFE0260  25 00 00 20 00              and     eax, 200000h
00007FF91DFE0265  0F BA E2 17                 bt      edx, 17h
00007FF91DFE0269  73 08                       jnb     short loc_7FF91DFE0273
00007FF91DFE026B  85 C0                       test    eax, eax
00007FF91DFE026D  75 0C                       jnz     short loc_7FF91DFE027B
00007FF91DFE026F  03 D2                       add     edx, edx
00007FF91DFE0271  EB 0F                       jmp     short loc_7FF91DFE0282
00007FF91DFE0273  85 C0                       test    eax, eax
00007FF91DFE0275  74 04                       jz      short loc_7FF91DFE027B
00007FF91DFE0277  03 D2                       add     edx, edx
00007FF91DFE0279  EB 07                       jmp     short loc_7FF91DFE0282
00007FF91DFE027B  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
00007FF91DFE0282  F3 0F 10 9B 30 F7 00 00     movss   xmm3, dword ptr [rbx+0F730h]
00007FF91DFE028A  8B C2                       mov     eax, edx
00007FF91DFE028C  F3 0F 10 B3 10 F7 00 00     movss   xmm6, dword ptr [rbx+0F710h]
00007FF91DFE0294  25 FF FF FF 00              and     eax, 0FFFFFFh
00007FF91DFE0299  F3 44 0F 10 83 D0 F7 00 00  movss   xmm8, dword ptr [rbx+0F7D0h]
00007FF91DFE02A2  8B CA                       mov     ecx, edx
00007FF91DFE02A4  F3 0F 10 BB E0 F7 00 00     movss   xmm7, dword ptr [rbx+0F7E0h]
00007FF91DFE02AC  81 CA 00 00 00 FF           or      edx, 0FF000000h
00007FF91DFE02B2  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFE02B6  81 E1 00 00 00 01           and     ecx, 1000000h
00007FF91DFE02BC  C7 83 10 F8 00 00 00 00 00 00  mov     dword ptr [rbx+0F810h], 0
00007FF91DFE02C6  F3 0F 11 9B 40 F7 00 00     movss   dword ptr [rbx+0F740h], xmm3
00007FF91DFE02CE  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFE02D2  0F 44 D0                    cmovz   edx, eax
00007FF91DFE02D5  F3 0F 11 B3 20 F7 00 00     movss   dword ptr [rbx+0F720h], xmm6
00007FF91DFE02DD  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
00007FF91DFE02E3  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
00007FF91DFE02E9  8B 83 50 F8 00 00           mov     eax, [rbx+0F850h]
00007FF91DFE02EF  66 0F 6E C2                 movd    xmm0, edx
00007FF91DFE02F3  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFE02F6  89 83 60 F8 00 00           mov     [rbx+0F860h], eax
00007FF91DFE02FC  F3 0F 11 A3 C0 F7 00 00     movss   dword ptr [rbx+0F7C0h], xmm4
00007FF91DFE0304  F3 0F 59 05 64 A9 60 00     mulss   xmm0, cs:dword_7FF91E5EAC70
00007FF91DFE030C  F3 44 0F 11 83 F0 F7 00 00  movss   dword ptr [rbx+0F7F0h], xmm8
00007FF91DFE0315  F3 0F 11 BB 00 F8 00 00     movss   dword ptr [rbx+0F800h], xmm7
00007FF91DFE031D  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
00007FF91DFE0325  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
00007FF91DFE032D  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
00007FF91DFE0335  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFE0339  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
00007FF91DFE0341  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFE0345  F3 0F 10 93 70 F7 00 00     movss   xmm2, dword ptr [rbx+0F770h]
00007FF91DFE034D  F3 0F 11 93 80 F7 00 00     movss   dword ptr [rbx+0F780h], xmm2
00007FF91DFE0355  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE0359  F3 0F 10 83 50 F7 00 00     movss   xmm0, dword ptr [rbx+0F750h]
00007FF91DFE0361  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFE0365  F3 0F 11 83 60 F7 00 00     movss   dword ptr [rbx+0F760h], xmm0
00007FF91DFE036D  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFE0371  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE0374  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
00007FF91DFE037C  F3 0F 10 8B 90 F7 00 00     movss   xmm1, dword ptr [rbx+0F790h]
00007FF91DFE0384  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE0388  F3 0F 59 F2                 mulss   xmm6, xmm2
00007FF91DFE038C  F3 0F 11 8B B0 F7 00 00     movss   dword ptr [rbx+0F7B0h], xmm1
00007FF91DFE0394  F3 0F 11 93 20 F8 00 00     movss   dword ptr [rbx+0F820h], xmm2
00007FF91DFE039C  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFE03A0  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFE03A3  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE03A7  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE03AB  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFE03AF  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFE03B3  F3 0F 11 B3 30 F8 00 00     movss   dword ptr [rbx+0F830h], xmm6
00007FF91DFE03BB  F3 0F 11 9B 40 F8 00 00     movss   dword ptr [rbx+0F840h], xmm3
00007FF91DFE03C3  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE03C6  F3 0F 58 9B 80 F8 00 00     addss   xmm3, dword ptr [rbx+0F880h]
00007FF91DFE03CE  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFE03D2  72 05                       jb      short loc_7FF91DFE03D9
00007FF91DFE03D4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE03D7  EB 03                       jmp     short loc_7FF91DFE03DC
00007FF91DFE03D9  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFE03DC  41 0F 2E CE                 ucomiss xmm1, xmm14
00007FF91DFE03E0  F3 44 0F 10 3D FB 50 76 00  movss   xmm15, cs:dword_7FF91E7454E4
00007FF91DFE03E9  75 06                       jnz     short loc_7FF91DFE03F1
00007FF91DFE03EB  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE03EF  EB 04                       jmp     short loc_7FF91DFE03F5
00007FF91DFE03F1  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFE03F5  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFE03F9  F3 0F 11 AB 50 F8 00 00     movss   dword ptr [rbx+0F850h], xmm5
00007FF91DFE0401  73 06                       jnb     short loc_7FF91DFE0409
00007FF91DFE0403  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE0407  EB 06                       jmp     short loc_7FF91DFE040F
00007FF91DFE0409  76 04                       jbe     short loc_7FF91DFE040F
00007FF91DFE040B  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFE040F  F3 0F 10 83 C0 F8 00 00     movss   xmm0, dword ptr [rbx+0F8C0h]
00007FF91DFE0417  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFE041C  F3 0F 10 93 60 F9 00 00     movss   xmm2, dword ptr [rbx+0F960h]
00007FF91DFE0424  F3 0F 10 8B D0 F8 00 00     movss   xmm1, dword ptr [rbx+0F8D0h]
00007FF91DFE042C  8B 83 90 F8 00 00           mov     eax, [rbx+0F890h]
00007FF91DFE0432  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFE0435  F3 0F 10 A3 20 F9 00 00     movss   xmm4, dword ptr [rbx+0F920h]
00007FF91DFE043D  F3 0F 58 9B 70 F9 00 00     addss   xmm3, dword ptr [rbx+0F970h]
00007FF91DFE0445  F2 44 0F 10 25 52 4D 76 00  movsd   xmm12, cs:dbl_7FF91E7451A0
00007FF91DFE044E  F3 0F 11 AB 70 F8 00 00     movss   dword ptr [rbx+0F870h], xmm5
00007FF91DFE0456  F3 0F 11 AB 90 F8 00 00     movss   dword ptr [rbx+0F890h], xmm5
00007FF91DFE045E  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFE0462  89 83 A0 F8 00 00           mov     [rbx+0F8A0h], eax
00007FF91DFE0468  F3 0F 11 A3 30 F9 00 00     movss   dword ptr [rbx+0F930h], xmm4
00007FF91DFE0470  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFE0474  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE0477  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE047B  F3 0F 10 8B 00 F9 00 00     movss   xmm1, dword ptr [rbx+0F900h]
00007FF91DFE0483  F3 0F 58 83 80 F9 00 00     addss   xmm0, dword ptr [rbx+0F980h]
00007FF91DFE048B  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFE0490  F3 0F 5E C8                 divss   xmm1, xmm0
00007FF91DFE0494  F3 0F 10 83 90 F9 00 00     movss   xmm0, dword ptr [rbx+0F990h]
00007FF91DFE049C  F3 0F 59 AB B0 F8 00 00     mulss   xmm5, dword ptr [rbx+0F8B0h]
00007FF91DFE04A4  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFE04A8  F3 0F 10 93 F0 F8 00 00     movss   xmm2, dword ptr [rbx+0F8F0h]
00007FF91DFE04B0  F3 0F 11 AB 40 F9 00 00     movss   dword ptr [rbx+0F940h], xmm5
00007FF91DFE04B8  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFE04BC  F3 0F 10 8B 10 F9 00 00     movss   xmm1, dword ptr [rbx+0F910h]
00007FF91DFE04C4  F3 0F 58 D6                 addss   xmm2, xmm6
00007FF91DFE04C8  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFE04CC  F3 0F 11 93 F0 F8 00 00     movss   dword ptr [rbx+0F8F0h], xmm2
00007FF91DFE04D4  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE04D8  F3 0F 11 93 00 F9 00 00     movss   dword ptr [rbx+0F900h], xmm2
00007FF91DFE04E0  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFE04E4  F3 0F 5C E6                 subss   xmm4, xmm6
00007FF91DFE04E8  0F 54 25 A1 52 76 00        andps   xmm4, cs:xmmword_7FF91E745790
00007FF91DFE04EF  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFE04F3  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE04F7  0F 83 E8 00 00 00           jnb     loc_7FF91DFE05E5
00007FF91DFE04FD  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFE0500  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFE0503  41 0F 2E EE                 ucomiss xmm5, xmm14
00007FF91DFE0507  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE050B  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFE050E  F3 0F 11 83 10 F9 00 00     movss   dword ptr [rbx+0F910h], xmm0
00007FF91DFE0516  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFE051A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE051E  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE0522  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE0526  75 03                       jnz     short loc_7FF91DFE052B
00007FF91DFE0528  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFE052B  8B 83 D0 F9 00 00           mov     eax, [rbx+0F9D0h]
00007FF91DFE0531  48 8D 0D C8 FA C7 FF        lea     rcx, cs:7FF91DC60000h
00007FF91DFE0538  F3 0F 59 BB C0 F9 00 00     mulss   xmm7, dword ptr [rbx+0F9C0h]
00007FF91DFE0540  89 83 E0 F9 00 00           mov     [rbx+0F9E0h], eax
00007FF91DFE0546  F3 44 0F 59 83 B0 F9 00 00  mulss   xmm8, dword ptr [rbx+0F9B0h]
00007FF91DFE054F  F3 0F 10 83 F0 FA 00 00     movss   xmm0, dword ptr [rbx+0FAF0h]
00007FF91DFE0557  F3 0F 10 93 F0 F9 00 00     movss   xmm2, dword ptr [rbx+0F9F0h]
00007FF91DFE055F  F3 44 0F 10 8B 50 FA 00 00  movss   xmm9, dword ptr [rbx+0FA50h]
00007FF91DFE0568  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFE056D  F3 44 0F 10 83 30 FA 00 00  movss   xmm8, dword ptr [rbx+0FA30h]
00007FF91DFE0576  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFE057A  F3 0F 11 BB D0 F9 00 00     movss   dword ptr [rbx+0F9D0h], xmm7
00007FF91DFE0582  F3 0F 10 BB 10 FA 00 00     movss   xmm7, dword ptr [rbx+0FA10h]
00007FF91DFE058A  F3 0F 11 8B 20 F9 00 00     movss   dword ptr [rbx+0F920h], xmm1
00007FF91DFE0592  F3 0F 11 8B 50 F9 00 00     movss   dword ptr [rbx+0F950h], xmm1
00007FF91DFE059A  F3 0F 10 8B B0 FA 00 00     movss   xmm1, dword ptr [rbx+0FAB0h]
00007FF91DFE05A2  F3 0F 11 BB 20 FA 00 00     movss   dword ptr [rbx+0FA20h], xmm7
00007FF91DFE05AA  F3 0F 11 93 00 FA 00 00     movss   dword ptr [rbx+0FA00h], xmm2
00007FF91DFE05B2  F3 44 0F 11 83 40 FA 00 00  movss   dword ptr [rbx+0FA40h], xmm8
00007FF91DFE05BB  F3 44 0F 11 8B 60 FA 00 00  movss   dword ptr [rbx+0FA60h], xmm9
00007FF91DFE05C4  F3 0F 11 8B C0 FA 00 00     movss   dword ptr [rbx+0FAC0h], xmm1
00007FF91DFE05CC  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFE05CF  7D 2F                       jge     short loc_7FF91DFE0600
00007FF91DFE05D1  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFE05D6  F7 D0                       not     eax
00007FF91DFE05D8  48 98                       cdqe
00007FF91DFE05DA  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFE05E3  EB 47                       jmp     short loc_7FF91DFE062C
00007FF91DFE05E5  F3 0F 58 8B A0 F9 00 00     addss   xmm1, dword ptr [rbx+0F9A0h]
00007FF91DFE05ED  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFE05F1  0F 82 09 FF FF FF           jb      loc_7FF91DFE0500
00007FF91DFE05F7  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFE05FB  E9 03 FF FF FF              jmp     loc_7FF91DFE0503
00007FF91DFE0600  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFE0603  7E 07                       jle     short loc_7FF91DFE060C
00007FF91DFE0605  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFE060A  EB 15                       jmp     short loc_7FF91DFE0621
00007FF91DFE060C  85 C0                       test    eax, eax
00007FF91DFE060E  79 0F                       jns     short loc_7FF91DFE061F
00007FF91DFE0610  F7 D0                       not     eax
00007FF91DFE0612  48 98                       cdqe
00007FF91DFE0614  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFE061D  EB 0D                       jmp     short loc_7FF91DFE062C
00007FF91DFE061F  7E 0B                       jle     short loc_7FF91DFE062C
00007FF91DFE0621  48 98                       cdqe
00007FF91DFE0623  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFE062C  0F 57 05 8D 51 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFE0633  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFE0637  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFE063A  7D 14                       jge     short loc_7FF91DFE0650
00007FF91DFE063C  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFE0641  F7 D0                       not     eax
00007FF91DFE0643  48 98                       cdqe
00007FF91DFE0645  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFE064E  EB 2C                       jmp     short loc_7FF91DFE067C
00007FF91DFE0650  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFE0653  7E 07                       jle     short loc_7FF91DFE065C
00007FF91DFE0655  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFE065A  EB 15                       jmp     short loc_7FF91DFE0671
00007FF91DFE065C  85 C0                       test    eax, eax
00007FF91DFE065E  79 0F                       jns     short loc_7FF91DFE066F
00007FF91DFE0660  F7 D0                       not     eax
00007FF91DFE0662  48 98                       cdqe
00007FF91DFE0664  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFE066D  EB 0D                       jmp     short loc_7FF91DFE067C
00007FF91DFE066F  7E 0B                       jle     short loc_7FF91DFE067C
00007FF91DFE0671  48 98                       cdqe
00007FF91DFE0673  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFE067C  F3 0F 10 83 70 FA 00 00     movss   xmm0, dword ptr [rbx+0FA70h]
00007FF91DFE0684  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFE0688  F3 0F 59 93 E0 FA 00 00     mulss   xmm2, dword ptr [rbx+0FAE0h]
00007FF91DFE0690  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE0694  F3 0F 10 8B A0 FA 00 00     movss   xmm1, dword ptr [rbx+0FAA0h]
00007FF91DFE069C  F3 0F 11 93 B0 FA 00 00     movss   dword ptr [rbx+0FAB0h], xmm2
00007FF91DFE06A4  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFE06A8  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE06AC  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE06B0  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE06B4  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFE06B8  76 05                       jbe     short loc_7FF91DFE06BF
00007FF91DFE06BA  0F 5A C2                    cvtps2pd xmm0, xmm2
00007FF91DFE06BD  EB 03                       jmp     short loc_7FF91DFE06C2
00007FF91DFE06BF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE06C2  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFE06C6  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFE06CA  72 06                       jb      short loc_7FF91DFE06D2
00007FF91DFE06CC  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFE06D0  EB 03                       jmp     short loc_7FF91DFE06D5
00007FF91DFE06D2  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFE06D5  F3 0F 10 B3 80 FA 00 00     movss   xmm6, dword ptr [rbx+0FA80h]
00007FF91DFE06DD  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE06E1  F3 0F 59 83 10 FB 00 00     mulss   xmm0, dword ptr [rbx+0FB10h]; X
00007FF91DFE06E9  E8 52 F0 36 00              call    expf
00007FF91DFE06EE  F3 0F 59 83 00 FB 00 00     mulss   xmm0, dword ptr [rbx+0FB00h]
00007FF91DFE06F6  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFE06F9  8B 83 80 FC 00 00           mov     eax, [rbx+0FC80h]
00007FF91DFE06FF  F3 0F 59 8B 90 FA 00 00     mulss   xmm1, dword ptr [rbx+0FA90h]
00007FF91DFE0707  89 83 90 FC 00 00           mov     [rbx+0FC90h], eax
00007FF91DFE070D  F3 0F 58 83 20 FB 00 00     addss   xmm0, dword ptr [rbx+0FB20h]
00007FF91DFE0715  8B 83 A0 FC 00 00           mov     eax, [rbx+0FCA0h]
00007FF91DFE071B  F3 0F 10 9B 40 FC 00 00     movss   xmm3, dword ptr [rbx+0FC40h]
00007FF91DFE0723  F3 0F 59 BB D0 FD 00 00     mulss   xmm7, dword ptr [rbx+0FDD0h]
00007FF91DFE072B  89 83 B0 FC 00 00           mov     [rbx+0FCB0h], eax
00007FF91DFE0731  8B 83 C0 FC 00 00           mov     eax, [rbx+0FCC0h]
00007FF91DFE0737  F3 0F 10 93 30 FC 00 00     movss   xmm2, dword ptr [rbx+0FC30h]
00007FF91DFE073F  F3 0F 10 A3 60 FC 00 00     movss   xmm4, dword ptr [rbx+0FC60h]
00007FF91DFE0747  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFE074B  89 83 D0 FC 00 00           mov     [rbx+0FCD0h], eax
00007FF91DFE0751  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
00007FF91DFE0757  F3 0F 11 9B 50 FC 00 00     movss   dword ptr [rbx+0FC50h], xmm3
00007FF91DFE075F  F3 0F 5C CE                 subss   xmm1, xmm6
00007FF91DFE0763  F3 0F 11 93 40 FC 00 00     movss   dword ptr [rbx+0FC40h], xmm2
00007FF91DFE076B  F3 0F 11 A3 70 FC 00 00     movss   dword ptr [rbx+0FC70h], xmm4
00007FF91DFE0773  F3 44 0F 11 83 00 FC 00 00  movss   dword ptr [rbx+0FC00h], xmm8
00007FF91DFE077C  F3 44 0F 11 8B 10 FC 00 00  movss   dword ptr [rbx+0FC10h], xmm9
00007FF91DFE0785  89 83 F0 FB 00 00           mov     [rbx+0FBF0h], eax
00007FF91DFE078B  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE078F  F3 0F 10 83 A0 FD 00 00     movss   xmm0, dword ptr [rbx+0FDA0h]
00007FF91DFE0797  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFE079B  F3 0F 11 83 90 FD 00 00     movss   dword ptr [rbx+0FD90h], xmm0
00007FF91DFE07A3  F3 0F 11 8B D0 FA 00 00     movss   dword ptr [rbx+0FAD0h], xmm1
00007FF91DFE07AB  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFE07AF  73 06                       jnb     short loc_7FF91DFE07B7
00007FF91DFE07B1  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE07B5  EB 05                       jmp     short loc_7FF91DFE07BC
00007FF91DFE07B7  F3 41 0F 5D FD              minss   xmm7, xmm13
00007FF91DFE07BC  F3 0F 59 0D FC A5 60 00     mulss   xmm1, cs:dword_7FF91E5EADC0
00007FF91DFE07C4  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE07C8  F3 0F 10 B3 B0 FE 00 00     movss   xmm6, dword ptr [rbx+0FEB0h]
00007FF91DFE07D0  F3 0F 5C C3                 subss   xmm0, xmm3
00007FF91DFE07D4  F3 0F 11 BB 30 FC 00 00     movss   dword ptr [rbx+0FC30h], xmm7
00007FF91DFE07DC  F3 0F 5D F1                 minss   xmm6, xmm1
00007FF91DFE07E0  F3 0F 59 83 E0 FD 00 00     mulss   xmm0, dword ptr [rbx+0FDE0h]
00007FF91DFE07E8  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFE07EC  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFE07F0  73 06                       jnb     short loc_7FF91DFE07F8
00007FF91DFE07F2  41 0F 28 C7                 movaps  xmm0, xmm15
00007FF91DFE07F6  EB 05                       jmp     short loc_7FF91DFE07FD
00007FF91DFE07F8  F3 41 0F 5D C5              minss   xmm0, xmm13
00007FF91DFE07FD  F3 0F 59 B3 C0 FE 00 00     mulss   xmm6, dword ptr [rbx+0FEC0h]
00007FF91DFE0805  F3 0F 5C D7                 subss   xmm2, xmm7
00007FF91DFE0809  F3 0F 11 B3 E0 FC 00 00     movss   dword ptr [rbx+0FCE0h], xmm6
00007FF91DFE0811  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFE0815  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFE0819  73 03                       jnb     short loc_7FF91DFE081E
00007FF91DFE081B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE081E  F3 0F 10 8B B0 FD 00 00     movss   xmm1, dword ptr [rbx+0FDB0h]
00007FF91DFE0826  F3 44 0F 10 9B F0 FB 00 00  movss   xmm11, dword ptr [rbx+0FBF0h]
00007FF91DFE082F  F3 0F 11 83 40 FC 00 00     movss   dword ptr [rbx+0FC40h], xmm0
00007FF91DFE0837  F3 0F 58 83 40 FF 00 00     addss   xmm0, dword ptr [rbx+0FF40h]
00007FF91DFE083F  72 04                       jb      short loc_7FF91DFE0845
00007FF91DFE0841  41 0F 28 CD                 movaps  xmm1, xmm13
00007FF91DFE0845  F3 0F 59 83 30 FF 00 00     mulss   xmm0, dword ptr [rbx+0FF30h]
00007FF91DFE084D  41 0F 28 FB                 movaps  xmm7, xmm11
00007FF91DFE0851  F3 0F 10 93 90 FC 00 00     movss   xmm2, dword ptr [rbx+0FC90h]
00007FF91DFE0859  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFE085D  F3 0F 5C FA                 subss   xmm7, xmm2
00007FF91DFE0861  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE0865  F3 0F 59 B3 C0 FD 00 00     mulss   xmm6, dword ptr [rbx+0FDC0h]
00007FF91DFE086D  76 05                       jbe     short loc_7FF91DFE0874
00007FF91DFE086F  0F 5A C8                    cvtps2pd xmm1, xmm0
00007FF91DFE0872  EB 03                       jmp     short loc_7FF91DFE0877
00007FF91DFE0874  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFE0877  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE087B  F3 0F 59 BB 00 00 01 00     mulss   xmm7, dword ptr [rbx+10000h]
00007FF91DFE0883  F3 44 0F 10 0D 5C 49 76 00  movss   xmm9, cs:flt_7FF91E7451E8
00007FF91DFE088C  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
00007FF91DFE0890  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFE0894  F3 0F 11 BB 80 FC 00 00     movss   dword ptr [rbx+0FC80h], xmm7
00007FF91DFE089C  F3 0F 11 83 20 FC 00 00     movss   dword ptr [rbx+0FC20h], xmm0
00007FF91DFE08A4  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFE08A8  F3 0F 59 BB F0 FF 00 00     mulss   xmm7, dword ptr [rbx+0FFF0h]
00007FF91DFE08B0  F3 0F 10 8B 70 FE 00 00     movss   xmm1, dword ptr [rbx+0FE70h]
00007FF91DFE08B8  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE08BC  F3 0F 59 F9                 mulss   xmm7, xmm1
00007FF91DFE08C0  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFE08C4  F3 0F 10 83 70 FC 00 00     movss   xmm0, dword ptr [rbx+0FC70h]
00007FF91DFE08CC  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
00007FF91DFE08D5  F3 41 0F 58 FB              addss   xmm7, xmm11
00007FF91DFE08DA  76 1B                       jbe     short loc_7FF91DFE08F7
00007FF91DFE08DC  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE08E1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE08E5  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE08E8  E8 EB EB 36 00              call    fmodf
00007FF91DFE08ED  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE08F0  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE08F5  EB 1F                       jmp     short loc_7FF91DFE0916
00007FF91DFE08F7  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE08FB  73 19                       jnb     short loc_7FF91DFE0916
00007FF91DFE08FD  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE0902  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE0906  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE0909  E8 CA EB 36 00              call    fmodf
00007FF91DFE090E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE0911  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE0916  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
00007FF91DFE091F  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE0922  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE0926  F3 44 0F 10 83 B0 FC 00 00  movss   xmm8, dword ptr [rbx+0FCB0h]
00007FF91DFE092F  F3 0F 11 B3 60 FC 00 00     movss   dword ptr [rbx+0FC60h], xmm6
00007FF91DFE0937  F3 0F 59 BB E0 FF 00 00     mulss   xmm7, dword ptr [rbx+0FFE0h]
00007FF91DFE093F  F3 0F 58 83 50 FF 00 00     addss   xmm0, dword ptr [rbx+0FF50h]
00007FF91DFE0947  F3 0F 11 BB E0 FB 00 00     movss   dword ptr [rbx+0FBE0h], xmm7
00007FF91DFE094F  73 0A                       jnb     short loc_7FF91DFE095B
00007FF91DFE0951  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFE0955  76 04                       jbe     short loc_7FF91DFE095B
00007FF91DFE0957  45 0F 28 C3                 movaps  xmm8, xmm11
00007FF91DFE095B  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFE095F  76 15                       jbe     short loc_7FF91DFE0976
00007FF91DFE0961  F3 41 0F 58 C5              addss   xmm0, xmm13; X
00007FF91DFE0966  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE096A  E8 69 EB 36 00              call    fmodf
00007FF91DFE096F  F3 41 0F 5C C5              subss   xmm0, xmm13
00007FF91DFE0974  EB 19                       jmp     short loc_7FF91DFE098F
00007FF91DFE0976  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFE097A  73 13                       jnb     short loc_7FF91DFE098F
00007FF91DFE097C  F3 41 0F 5C C5              subss   xmm0, xmm13; X
00007FF91DFE0981  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE0985  E8 4E EB 36 00              call    fmodf
00007FF91DFE098A  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE098F  F3 44 0F 10 1D 28 4E 76 00  movss   xmm11, dword ptr cs:xmmword_7FF91E7457C0
00007FF91DFE0998  F3 44 0F 11 83 A0 FC 00 00  movss   dword ptr [rbx+0FCA0h], xmm8
00007FF91DFE09A1  F3 0F 59 83 90 FF 00 00     mulss   xmm0, dword ptr [rbx+0FF90h]
00007FF91DFE09A9  F3 44 0F 59 83 D0 FF 00 00  mulss   xmm8, dword ptr [rbx+0FFD0h]
00007FF91DFE09B2  F3 0F 58 83 10 00 01 00     addss   xmm0, dword ptr [rbx+10010h]
00007FF91DFE09BA  F3 0F 11 83 F0 FC 00 00     movss   dword ptr [rbx+0FCF0h], xmm0
00007FF91DFE09C2  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFE09C6  F3 44 0F 11 83 40 FD 00 00  movss   dword ptr [rbx+0FD40h], xmm8
00007FF91DFE09CF  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFE09D3  F3 44 0F 58 83 70 FF 00 00  addss   xmm8, dword ptr [rbx+0FF70h]
00007FF91DFE09DC  F3 0F 11 83 00 FD 00 00     movss   dword ptr [rbx+0FD00h], xmm0
00007FF91DFE09E4  45 0F 2F C5                 comiss  xmm8, xmm13
00007FF91DFE09E8  76 1D                       jbe     short loc_7FF91DFE0A07
00007FF91DFE09EA  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFE09EF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE09F3  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFE09F7  E8 DC EA 36 00              call    fmodf
00007FF91DFE09FC  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFE0A00  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFE0A05  EB 21                       jmp     short loc_7FF91DFE0A28
00007FF91DFE0A07  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFE0A0B  73 1B                       jnb     short loc_7FF91DFE0A28
00007FF91DFE0A0D  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFE0A12  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE0A16  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFE0A1A  E8 B9 EA 36 00              call    fmodf
00007FF91DFE0A1F  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFE0A23  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFE0A28  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFE0A2B  F3 0F 58 BB 60 FF 00 00     addss   xmm7, dword ptr [rbx+0FF60h]
00007FF91DFE0A33  41 0F 2F FD                 comiss  xmm7, xmm13
00007FF91DFE0A37  76 1B                       jbe     short loc_7FF91DFE0A54
00007FF91DFE0A39  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE0A3E  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE0A42  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFE0A45  E8 8E EA 36 00              call    fmodf
00007FF91DFE0A4A  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFE0A4D  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE0A52  EB 1F                       jmp     short loc_7FF91DFE0A73
00007FF91DFE0A54  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFE0A58  73 19                       jnb     short loc_7FF91DFE0A73
00007FF91DFE0A5A  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE0A5F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE0A63  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFE0A66  E8 6D EA 36 00              call    fmodf
00007FF91DFE0A6B  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFE0A6E  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE0A73  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFE0A77  E8 44 85 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE0A7C  F3 0F 58 BB 20 00 01 00     addss   xmm7, dword ptr [rbx+10020h]
00007FF91DFE0A84  F3 0F 59 83 B0 FF 00 00     mulss   xmm0, dword ptr [rbx+0FFB0h]
00007FF91DFE0A8C  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE0A90  73 06                       jnb     short loc_7FF91DFE0A98
00007FF91DFE0A92  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE0A96  EB 06                       jmp     short loc_7FF91DFE0A9E
00007FF91DFE0A98  76 04                       jbe     short loc_7FF91DFE0A9E
00007FF91DFE0A9A  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE0A9E  F3 0F 58 B3 80 FF 00 00     addss   xmm6, dword ptr [rbx+0FF80h]
00007FF91DFE0AA6  F3 0F 11 83 20 FD 00 00     movss   dword ptr [rbx+0FD20h], xmm0
00007FF91DFE0AAE  F3 0F 11 BB 80 FD 00 00     movss   dword ptr [rbx+0FD80h], xmm7
00007FF91DFE0AB6  F3 0F 59 BB A0 FF 00 00     mulss   xmm7, dword ptr [rbx+0FFA0h]
00007FF91DFE0ABE  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE0AC2  F3 0F 58 BB 30 00 01 00     addss   xmm7, dword ptr [rbx+10030h]
00007FF91DFE0ACA  76 1B                       jbe     short loc_7FF91DFE0AE7
00007FF91DFE0ACC  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE0AD1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE0AD5  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE0AD8  E8 FB E9 36 00              call    fmodf
00007FF91DFE0ADD  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE0AE0  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE0AE5  EB 1F                       jmp     short loc_7FF91DFE0B06
00007FF91DFE0AE7  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE0AEB  73 19                       jnb     short loc_7FF91DFE0B06
00007FF91DFE0AED  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE0AF2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE0AF6  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE0AF9  E8 DA E9 36 00              call    fmodf
00007FF91DFE0AFE  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE0B01  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE0B06  0F 54 35 83 4C 76 00        andps   xmm6, cs:xmmword_7FF91E745790
00007FF91DFE0B0D  F3 0F 11 BB 10 FD 00 00     movss   dword ptr [rbx+0FD10h], xmm7
00007FF91DFE0B15  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFE0B18  F3 0F 10 9B 50 FE 00 00     movss   xmm3, dword ptr [rbx+0FE50h]
00007FF91DFE0B20  0F 28 D6                    movaps  xmm2, xmm6
00007FF91DFE0B23  F3 0F 59 93 E0 FE 00 00     mulss   xmm2, dword ptr [rbx+0FEE0h]
00007FF91DFE0B2B  F3 0F 59 9B 40 FD 00 00     mulss   xmm3, dword ptr [rbx+0FD40h]
00007FF91DFE0B33  F3 0F 58 93 D0 FE 00 00     addss   xmm2, dword ptr [rbx+0FED0h]
00007FF91DFE0B3B  F3 0F 10 8B 40 FE 00 00     movss   xmm1, dword ptr [rbx+0FE40h]
00007FF91DFE0B43  F3 0F 59 8B 00 FD 00 00     mulss   xmm1, dword ptr [rbx+0FD00h]
00007FF91DFE0B4B  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFE0B4F  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFE0B52  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFE0B56  F3 0F 59 83 F0 FE 00 00     mulss   xmm0, dword ptr [rbx+0FEF0h]
00007FF91DFE0B5E  F3 0F 59 F4                 mulss   xmm6, xmm4
00007FF91DFE0B62  F3 0F 59 A3 00 FF 00 00     mulss   xmm4, dword ptr [rbx+0FF00h]
00007FF91DFE0B6A  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE0B6E  F3 0F 59 B3 10 FF 00 00     mulss   xmm6, dword ptr [rbx+0FF10h]
00007FF91DFE0B76  F3 0F 10 83 30 FE 00 00     movss   xmm0, dword ptr [rbx+0FE30h]
00007FF91DFE0B7E  F3 0F 59 83 F0 FC 00 00     mulss   xmm0, dword ptr [rbx+0FCF0h]
00007FF91DFE0B86  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFE0B8A  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE0B8E  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFE0B92  F3 0F 10 A3 10 FE 00 00     movss   xmm4, dword ptr [rbx+0FE10h]
00007FF91DFE0B9A  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE0B9E  F3 0F 58 B3 20 FF 00 00     addss   xmm6, dword ptr [rbx+0FF20h]
00007FF91DFE0BA6  F3 0F 59 B3 C0 FF 00 00     mulss   xmm6, dword ptr [rbx+0FFC0h]
00007FF91DFE0BAE  F3 0F 11 B3 30 FD 00 00     movss   dword ptr [rbx+0FD30h], xmm6
00007FF91DFE0BB6  F3 0F 59 A3 20 FD 00 00     mulss   xmm4, dword ptr [rbx+0FD20h]
00007FF91DFE0BBE  F3 0F 10 8B F0 FD 00 00     movss   xmm1, dword ptr [rbx+0FDF0h]
00007FF91DFE0BC6  F3 0F 10 83 20 FE 00 00     movss   xmm0, dword ptr [rbx+0FE20h]
00007FF91DFE0BCE  F3 0F 59 83 10 FD 00 00     mulss   xmm0, dword ptr [rbx+0FD10h]
00007FF91DFE0BD6  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE0BDA  F3 0F 10 93 80 FE 00 00     movss   xmm2, dword ptr [rbx+0FE80h]
00007FF91DFE0BE2  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFE0BE5  F3 0F 59 9B 20 FC 00 00     mulss   xmm3, dword ptr [rbx+0FC20h]
00007FF91DFE0BED  F3 0F 59 B3 00 FE 00 00     mulss   xmm6, dword ptr [rbx+0FE00h]
00007FF91DFE0BF5  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE0BF9  F3 0F 10 83 60 FE 00 00     movss   xmm0, dword ptr [rbx+0FE60h]
00007FF91DFE0C01  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFE0C05  F3 0F 59 83 E0 FB 00 00     mulss   xmm0, dword ptr [rbx+0FBE0h]
00007FF91DFE0C0D  F3 0F 58 E6                 addss   xmm4, xmm6
00007FF91DFE0C11  F3 41 0F 58 DD              addss   xmm3, xmm13
00007FF91DFE0C16  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE0C1A  F3 0F 11 9B 50 FD 00 00     movss   dword ptr [rbx+0FD50h], xmm3
00007FF91DFE0C22  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE0C26  F3 0F 11 A3 70 FD 00 00     movss   dword ptr [rbx+0FD70h], xmm4
00007FF91DFE0C2E  F3 0F 10 8B A0 FE 00 00     movss   xmm1, dword ptr [rbx+0FEA0h]
00007FF91DFE0C36  F3 0F 59 8B 10 FC 00 00     mulss   xmm1, dword ptr [rbx+0FC10h]
00007FF91DFE0C3E  F3 0F 10 83 90 FE 00 00     movss   xmm0, dword ptr [rbx+0FE90h]
00007FF91DFE0C46  F3 0F 59 83 00 FC 00 00     mulss   xmm0, dword ptr [rbx+0FC00h]
00007FF91DFE0C4E  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE0C52  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE0C56  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE0C5A  F3 0F 11 8B 60 FD 00 00     movss   dword ptr [rbx+0FD60h], xmm1
00007FF91DFE0C62  F3 0F 10 83 70 FD 00 00     movss   xmm0, dword ptr [rbx+0FD70h]
00007FF91DFE0C6A  8B 83 80 FD 00 00           mov     eax, [rbx+0FD80h]
00007FF91DFE0C70  89 83 40 00 01 00           mov     [rbx+10040h], eax
00007FF91DFE0C76  F3 0F 11 83 50 00 01 00     movss   dword ptr [rbx+10050h], xmm0
00007FF91DFE0C7E  44 0F 2F B3 80 FD 00 00     comiss  xmm14, dword ptr [rbx+0FD80h]
00007FF91DFE0C86  F3 0F 10 8B 90 F8 00 00     movss   xmm1, dword ptr [rbx+0F890h]
00007FF91DFE0C8E  F3 0F 10 93 60 00 01 00     movss   xmm2, dword ptr [rbx+10060h]
00007FF91DFE0C96  73 06                       jnb     short loc_7FF91DFE0C9E
00007FF91DFE0C98  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE0C9C  EB 03                       jmp     short loc_7FF91DFE0CA1
00007FF91DFE0C9E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE0CA1  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFE0CA5  75 04                       jnz     short loc_7FF91DFE0CAB
00007FF91DFE0CA7  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE0CAB  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE0CAF  F3 0F 11 8B 70 00 01 00     movss   dword ptr [rbx+10070h], xmm1
00007FF91DFE0CB7  8B 83 80 00 01 00           mov     eax, [rbx+10080h]
00007FF91DFE0CBD  89 83 90 00 01 00           mov     [rbx+10090h], eax
00007FF91DFE0CC3  8B 83 B0 00 01 00           mov     eax, [rbx+100B0h]
00007FF91DFE0CC9  89 83 C0 00 01 00           mov     [rbx+100C0h], eax
00007FF91DFE0CCF  8B 83 A0 00 01 00           mov     eax, [rbx+100A0h]
00007FF91DFE0CD5  89 83 B0 00 01 00           mov     [rbx+100B0h], eax
00007FF91DFE0CDB  8B 83 D0 00 01 00           mov     eax, [rbx+100D0h]
00007FF91DFE0CE1  89 83 E0 00 01 00           mov     [rbx+100E0h], eax
00007FF91DFE0CE7  8B 83 00 01 01 00           mov     eax, [rbx+10100h]
00007FF91DFE0CED  89 83 10 01 01 00           mov     [rbx+10110h], eax
00007FF91DFE0CF3  F3 0F 10 83 B0 01 01 00     movss   xmm0, dword ptr [rbx+101B0h]
00007FF91DFE0CFB  F3 0F 58 8B 90 01 01 00     addss   xmm1, dword ptr [rbx+10190h]
00007FF91DFE0D03  F3 0F 59 83 C0 00 01 00     mulss   xmm0, dword ptr [rbx+100C0h]
00007FF91DFE0D0B  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE0D0F  F3 0F 58 83 90 00 01 00     addss   xmm0, dword ptr [rbx+10090h]
00007FF91DFE0D17  73 06                       jnb     short loc_7FF91DFE0D1F
00007FF91DFE0D19  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFE0D1D  EB 04                       jmp     short loc_7FF91DFE0D23
00007FF91DFE0D1F  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFE0D23  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFE0D27  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFE0D2C  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFE0D2F  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFE0D33  F3 0F 11 BB A0 00 01 00     movss   dword ptr [rbx+100A0h], xmm7
00007FF91DFE0D3B  0F 28 E7                    movaps  xmm4, xmm7
00007FF91DFE0D3E  F3 0F 10 9B 80 01 01 00     movss   xmm3, dword ptr [rbx+10180h]
00007FF91DFE0D46  F3 0F 10 93 D0 01 01 00     movss   xmm2, dword ptr [rbx+101D0h]
00007FF91DFE0D4E  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE0D51  F3 0F 59 8B F0 01 01 00     mulss   xmm1, dword ptr [rbx+101F0h]
00007FF91DFE0D59  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE0D5C  F3 0F 58 A3 A0 01 01 00     addss   xmm4, dword ptr [rbx+101A0h]
00007FF91DFE0D64  F3 0F 5C BB B0 00 01 00     subss   xmm7, dword ptr [rbx+100B0h]
00007FF91DFE0D6C  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE0D70  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFE0D74  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE0D78  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE0D7C  F3 0F 11 8B F0 00 01 00     movss   dword ptr [rbx+100F0h], xmm1
00007FF91DFE0D84  72 06                       jb      short loc_7FF91DFE0D8C
00007FF91DFE0D86  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE0D8A  EB 03                       jmp     short loc_7FF91DFE0D8F
00007FF91DFE0D8C  0F 57 F6                    xorps   xmm6, xmm6
00007FF91DFE0D8F  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE0D93  F3 0F 10 83 50 01 01 00     movss   xmm0, dword ptr [rbx+10150h]
00007FF91DFE0D9B  73 03                       jnb     short loc_7FF91DFE0DA0
00007FF91DFE0D9D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFE0DA0  F3 0F 59 83 D0 01 01 00     mulss   xmm0, dword ptr [rbx+101D0h]
00007FF91DFE0DA8  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFE0DAB  F3 0F 10 93 40 01 01 00     movss   xmm2, dword ptr [rbx+10140h]
00007FF91DFE0DB3  F3 44 0F 10 0D A0 41 76 00  movss   xmm9, cs:dword_7FF91E744F5C
00007FF91DFE0DBC  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFE0DC0  F3 0F 11 B3 B0 00 01 00     movss   dword ptr [rbx+100B0h], xmm6
00007FF91DFE0DC8  F3 0F 10 8B E0 01 01 00     movss   xmm1, dword ptr [rbx+101E0h]
00007FF91DFE0DD0  F3 0F 10 BB 60 01 01 00     movss   xmm7, dword ptr [rbx+10160h]
00007FF91DFE0DD8  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE0DDB  F3 0F 10 A3 E0 00 01 00     movss   xmm4, dword ptr [rbx+100E0h]
00007FF91DFE0DE3  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE0DE7  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFE0DEC  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE0DF0  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFE0DF5  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE0DF9  F3 0F 59 FE                 mulss   xmm7, xmm6
00007FF91DFE0DFD  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFE0E01  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE0E05  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFE0E09  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE0E0C  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFE0E10  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE0E14  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE0E18  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFE0E1C  76 0B                       jbe     short loc_7FF91DFE0E29
00007FF91DFE0E1E  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFE0E21  F3 0F 58 9B F0 00 01 00     addss   xmm3, dword ptr [rbx+100F0h]
00007FF91DFE0E29  F3 0F 10 83 D0 01 01 00     movss   xmm0, dword ptr [rbx+101D0h]
00007FF91DFE0E31  F3 0F 10 A3 90 00 01 00     movss   xmm4, dword ptr [rbx+10090h]
00007FF91DFE0E39  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFE0E3D  F3 0F 11 83 D0 00 01 00     movss   dword ptr [rbx+100D0h], xmm0
00007FF91DFE0E45  F3 0F 10 8B 10 01 01 00     movss   xmm1, dword ptr [rbx+10110h]
00007FF91DFE0E4D  F3 0F 10 9B 70 01 01 00     movss   xmm3, dword ptr [rbx+10170h]
00007FF91DFE0E55  F3 0F 59 AB C0 01 01 00     mulss   xmm5, dword ptr [rbx+101C0h]
00007FF91DFE0E5D  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFE0E62  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFE0E66  F3 0F 10 83 00 02 01 00     movss   xmm0, dword ptr [rbx+10200h]
00007FF91DFE0E6E  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFE0E73  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFE0E76  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE0E7A  F3 0F 58 EE                 addss   xmm5, xmm6
00007FF91DFE0E7E  F3 0F 59 D7                 mulss   xmm2, xmm7
00007FF91DFE0E82  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFE0E86  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE0E8A  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE0E8E  F3 0F 11 93 00 01 01 00     movss   dword ptr [rbx+10100h], xmm2
00007FF91DFE0E96  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFE0E9B  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFE0EA0  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFE0EA4  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE0EA8  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFE0EAC  F3 0F 11 9B 80 00 01 00     movss   dword ptr [rbx+10080h], xmm3
00007FF91DFE0EB4  F3 0F 59 9B 10 02 01 00     mulss   xmm3, dword ptr [rbx+10210h]
00007FF91DFE0EBC  F3 0F 59 9B 20 02 01 00     mulss   xmm3, dword ptr [rbx+10220h]
00007FF91DFE0EC4  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE0EC7  F3 0F 59 83 30 02 01 00     mulss   xmm0, dword ptr [rbx+10230h]
00007FF91DFE0ECF  F3 0F 11 9B 20 01 01 00     movss   dword ptr [rbx+10120h], xmm3
00007FF91DFE0ED7  F3 0F 11 83 30 01 01 00     movss   dword ptr [rbx+10130h], xmm0
00007FF91DFE0EDF  44 0F 2F B3 80 FD 00 00     comiss  xmm14, dword ptr [rbx+0FD80h]
00007FF91DFE0EE7  F3 0F 10 8B 90 F8 00 00     movss   xmm1, dword ptr [rbx+0F890h]
00007FF91DFE0EEF  F3 0F 10 93 40 02 01 00     movss   xmm2, dword ptr [rbx+10240h]
00007FF91DFE0EF7  73 06                       jnb     short loc_7FF91DFE0EFF
00007FF91DFE0EF9  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE0EFD  EB 03                       jmp     short loc_7FF91DFE0F02
00007FF91DFE0EFF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE0F02  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFE0F06  75 04                       jnz     short loc_7FF91DFE0F0C
00007FF91DFE0F08  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE0F0C  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE0F10  F3 0F 11 8B 50 02 01 00     movss   dword ptr [rbx+10250h], xmm1
00007FF91DFE0F18  8B 83 60 02 01 00           mov     eax, [rbx+10260h]
00007FF91DFE0F1E  89 83 70 02 01 00           mov     [rbx+10270h], eax
00007FF91DFE0F24  8B 83 90 02 01 00           mov     eax, [rbx+10290h]
00007FF91DFE0F2A  89 83 A0 02 01 00           mov     [rbx+102A0h], eax
00007FF91DFE0F30  8B 83 80 02 01 00           mov     eax, [rbx+10280h]
00007FF91DFE0F36  89 83 90 02 01 00           mov     [rbx+10290h], eax
00007FF91DFE0F3C  8B 83 B0 02 01 00           mov     eax, [rbx+102B0h]
00007FF91DFE0F42  89 83 C0 02 01 00           mov     [rbx+102C0h], eax
00007FF91DFE0F48  8B 83 E0 02 01 00           mov     eax, [rbx+102E0h]
00007FF91DFE0F4E  89 83 F0 02 01 00           mov     [rbx+102F0h], eax
00007FF91DFE0F54  F3 0F 10 83 90 03 01 00     movss   xmm0, dword ptr [rbx+10390h]
00007FF91DFE0F5C  F3 0F 58 8B 70 03 01 00     addss   xmm1, dword ptr [rbx+10370h]
00007FF91DFE0F64  F3 0F 59 83 A0 02 01 00     mulss   xmm0, dword ptr [rbx+102A0h]
00007FF91DFE0F6C  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE0F70  F3 0F 58 83 70 02 01 00     addss   xmm0, dword ptr [rbx+10270h]
00007FF91DFE0F78  73 06                       jnb     short loc_7FF91DFE0F80
00007FF91DFE0F7A  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFE0F7E  EB 04                       jmp     short loc_7FF91DFE0F84
00007FF91DFE0F80  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFE0F84  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFE0F88  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFE0F8D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFE0F90  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFE0F94  F3 0F 11 B3 80 02 01 00     movss   dword ptr [rbx+10280h], xmm6
00007FF91DFE0F9C  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFE0F9F  F3 0F 10 9B 60 03 01 00     movss   xmm3, dword ptr [rbx+10360h]
00007FF91DFE0FA7  F3 0F 10 93 B0 03 01 00     movss   xmm2, dword ptr [rbx+103B0h]
00007FF91DFE0FAF  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE0FB2  F3 0F 59 8B D0 03 01 00     mulss   xmm1, dword ptr [rbx+103D0h]
00007FF91DFE0FBA  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE0FBD  F3 0F 58 A3 80 03 01 00     addss   xmm4, dword ptr [rbx+10380h]
00007FF91DFE0FC5  F3 0F 5C B3 90 02 01 00     subss   xmm6, dword ptr [rbx+10290h]
00007FF91DFE0FCD  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE0FD1  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFE0FD5  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE0FD9  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE0FDD  F3 0F 11 8B D0 02 01 00     movss   dword ptr [rbx+102D0h], xmm1
00007FF91DFE0FE5  72 06                       jb      short loc_7FF91DFE0FED
00007FF91DFE0FE7  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE0FEB  EB 03                       jmp     short loc_7FF91DFE0FF0
00007FF91DFE0FED  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFE0FF0  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFE0FF4  F3 0F 10 83 30 03 01 00     movss   xmm0, dword ptr [rbx+10330h]
00007FF91DFE0FFC  73 03                       jnb     short loc_7FF91DFE1001
00007FF91DFE0FFE  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFE1001  F3 0F 59 83 B0 03 01 00     mulss   xmm0, dword ptr [rbx+103B0h]
00007FF91DFE1009  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFE100C  F3 0F 10 93 20 03 01 00     movss   xmm2, dword ptr [rbx+10320h]
00007FF91DFE1014  F3 0F 11 BB 90 02 01 00     movss   dword ptr [rbx+10290h], xmm7
00007FF91DFE101C  F3 0F 10 8B C0 03 01 00     movss   xmm1, dword ptr [rbx+103C0h]
00007FF91DFE1024  F3 0F 10 B3 40 03 01 00     movss   xmm6, dword ptr [rbx+10340h]
00007FF91DFE102C  F3 0F 10 A3 C0 02 01 00     movss   xmm4, dword ptr [rbx+102C0h]
00007FF91DFE1034  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFE1038  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE103B  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE103F  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFE1044  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE1048  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFE104D  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE1051  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFE1055  F3 0F 5C C7                 subss   xmm0, xmm7
00007FF91DFE1059  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE105D  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFE1061  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE1064  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFE1068  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE106C  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE1070  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFE1074  76 0B                       jbe     short loc_7FF91DFE1081
00007FF91DFE1076  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFE1079  F3 0F 58 9B D0 02 01 00     addss   xmm3, dword ptr [rbx+102D0h]
00007FF91DFE1081  F3 0F 10 A3 70 02 01 00     movss   xmm4, dword ptr [rbx+10270h]
00007FF91DFE1089  F3 0F 10 83 B0 03 01 00     movss   xmm0, dword ptr [rbx+103B0h]
00007FF91DFE1091  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFE1095  F3 0F 11 83 B0 02 01 00     movss   dword ptr [rbx+102B0h], xmm0
00007FF91DFE109D  F3 0F 59 AB A0 03 01 00     mulss   xmm5, dword ptr [rbx+103A0h]
00007FF91DFE10A5  F3 0F 10 8B F0 02 01 00     movss   xmm1, dword ptr [rbx+102F0h]
00007FF91DFE10AD  F3 0F 10 9B 50 03 01 00     movss   xmm3, dword ptr [rbx+10350h]
00007FF91DFE10B5  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFE10B9  F3 0F 10 83 E0 03 01 00     movss   xmm0, dword ptr [rbx+103E0h]
00007FF91DFE10C1  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFE10C4  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFE10C9  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE10CD  F3 0F 58 EF                 addss   xmm5, xmm7
00007FF91DFE10D1  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFE10D6  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE10DA  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFE10DE  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE10E2  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE10E6  F3 0F 11 93 E0 02 01 00     movss   dword ptr [rbx+102E0h], xmm2
00007FF91DFE10EE  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFE10F3  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFE10F8  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFE10FC  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE1100  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFE1104  F3 0F 11 9B 60 02 01 00     movss   dword ptr [rbx+10260h], xmm3
00007FF91DFE110C  F3 0F 59 9B F0 03 01 00     mulss   xmm3, dword ptr [rbx+103F0h]
00007FF91DFE1114  F3 0F 59 9B 00 04 01 00     mulss   xmm3, dword ptr [rbx+10400h]
00007FF91DFE111C  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE111F  F3 0F 59 83 10 04 01 00     mulss   xmm0, dword ptr [rbx+10410h]
00007FF91DFE1127  F3 0F 11 9B 00 03 01 00     movss   dword ptr [rbx+10300h], xmm3
00007FF91DFE112F  F3 0F 11 83 10 03 01 00     movss   dword ptr [rbx+10310h], xmm0
00007FF91DFE1137  8B 83 20 04 01 00           mov     eax, [rbx+10420h]
00007FF91DFE113D  89 83 30 04 01 00           mov     [rbx+10430h], eax
00007FF91DFE1143  8B 83 40 04 01 00           mov     eax, [rbx+10440h]
00007FF91DFE1149  89 83 50 04 01 00           mov     [rbx+10450h], eax
00007FF91DFE114F  F3 0F 10 83 50 F9 00 00     movss   xmm0, dword ptr [rbx+0F950h]
00007FF91DFE1157  F3 44 0F 10 83 D0 F9 00 00  movss   xmm8, dword ptr [rbx+0F9D0h]
00007FF91DFE1160  8B 83 80 04 01 00           mov     eax, [rbx+10480h]
00007FF91DFE1166  89 83 90 04 01 00           mov     [rbx+10490h], eax
00007FF91DFE116C  F3 0F 59 83 60 04 01 00     mulss   xmm0, dword ptr [rbx+10460h]
00007FF91DFE1174  F3 44 0F 59 83 70 04 01 00  mulss   xmm8, dword ptr [rbx+10470h]
00007FF91DFE117D  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFE1182  F3 44 0F 11 83 80 04 01 00  movss   dword ptr [rbx+10480h], xmm8
00007FF91DFE118B  F3 0F 10 BB 60 FD 00 00     movss   xmm7, dword ptr [rbx+0FD60h]
00007FF91DFE1193  F3 0F 10 8B 20 01 01 00     movss   xmm1, dword ptr [rbx+10120h]
00007FF91DFE119B  F3 0F 10 93 00 03 01 00     movss   xmm2, dword ptr [rbx+10300h]
00007FF91DFE11A3  F3 0F 10 83 50 F9 00 00     movss   xmm0, dword ptr [rbx+0F950h]
00007FF91DFE11AB  8B 83 40 04 01 00           mov     eax, [rbx+10440h]
00007FF91DFE11B1  89 83 C0 04 01 00           mov     [rbx+104C0h], eax
00007FF91DFE11B7  F3 0F 11 83 D0 04 01 00     movss   dword ptr [rbx+104D0h], xmm0
00007FF91DFE11BF  F3 0F 10 A3 10 06 01 00     movss   xmm4, dword ptr [rbx+10610h]
00007FF91DFE11C7  F3 0F 11 8B A0 04 01 00     movss   dword ptr [rbx+104A0h], xmm1
00007FF91DFE11CF  F3 0F 11 93 B0 04 01 00     movss   dword ptr [rbx+104B0h], xmm2
00007FF91DFE11D7  F3 0F 10 AB F0 05 01 00     movss   xmm5, dword ptr [rbx+105F0h]
00007FF91DFE11DF  F3 0F 59 FC                 mulss   xmm7, xmm4
00007FF91DFE11E3  F3 0F 59 A3 70 FD 00 00     mulss   xmm4, dword ptr [rbx+0FD70h]
00007FF91DFE11EB  F3 0F 11 A3 E0 04 01 00     movss   dword ptr [rbx+104E0h], xmm4
00007FF91DFE11F3  F3 0F 10 8B 70 05 01 00     movss   xmm1, dword ptr [rbx+10570h]
00007FF91DFE11FB  F3 0F 10 93 70 06 01 00     movss   xmm2, dword ptr [rbx+10670h]
00007FF91DFE1203  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFE1206  F3 0F 59 BB 20 06 01 00     mulss   xmm7, dword ptr [rbx+10620h]
00007FF91DFE120E  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE1211  F3 0F 10 B3 30 06 01 00     movss   xmm6, dword ptr [rbx+10630h]
00007FF91DFE1219  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE121D  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFE1221  F3 0F 59 EC                 mulss   xmm5, xmm4
00007FF91DFE1225  F3 0F 59 AB 00 06 01 00     mulss   xmm5, dword ptr [rbx+10600h]
00007FF91DFE122D  F3 0F 11 AB 00 05 01 00     movss   dword ptr [rbx+10500h], xmm5
00007FF91DFE1235  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFE1239  F3 0F 59 9B C0 04 01 00     mulss   xmm3, dword ptr [rbx+104C0h]
00007FF91DFE1241  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE1245  F3 0F 10 83 80 05 01 00     movss   xmm0, dword ptr [rbx+10580h]
00007FF91DFE124D  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFE1251  F3 0F 59 9B 80 06 01 00     mulss   xmm3, dword ptr [rbx+10680h]
00007FF91DFE1259  F3 0F 11 9B 10 05 01 00     movss   dword ptr [rbx+10510h], xmm3
00007FF91DFE1261  F3 0F 10 8B 50 06 01 00     movss   xmm1, dword ptr [rbx+10650h]
00007FF91DFE1269  F3 0F 59 8B B0 04 01 00     mulss   xmm1, dword ptr [rbx+104B0h]
00007FF91DFE1271  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE1275  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFE1279  F3 0F 10 83 40 06 01 00     movss   xmm0, dword ptr [rbx+10640h]
00007FF91DFE1281  F3 0F 59 83 A0 04 01 00     mulss   xmm0, dword ptr [rbx+104A0h]
00007FF91DFE1289  F3 0F 10 9B E0 04 01 00     movss   xmm3, dword ptr [rbx+104E0h]
00007FF91DFE1291  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE1295  F3 0F 10 83 60 05 01 00     movss   xmm0, dword ptr [rbx+10560h]
00007FF91DFE129D  F3 0F 59 8B 60 06 01 00     mulss   xmm1, dword ptr [rbx+10660h]
00007FF91DFE12A5  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFE12A9  F3 41 0F 58 C8              addss   xmm1, xmm8
00007FF91DFE12AE  F3 0F 58 8B D0 05 01 00     addss   xmm1, dword ptr [rbx+105D0h]
00007FF91DFE12B6  F3 0F 58 8B E0 05 01 00     addss   xmm1, dword ptr [rbx+105E0h]
00007FF91DFE12BE  F3 0F 11 8B 20 05 01 00     movss   dword ptr [rbx+10520h], xmm1
00007FF91DFE12C6  F3 0F 11 83 30 05 01 00     movss   dword ptr [rbx+10530h], xmm0
00007FF91DFE12CE  F3 0F 59 9B A0 06 01 00     mulss   xmm3, dword ptr [rbx+106A0h]
00007FF91DFE12D6  F3 0F 10 83 A0 05 01 00     movss   xmm0, dword ptr [rbx+105A0h]
00007FF91DFE12DE  F3 0F 59 83 A0 04 01 00     mulss   xmm0, dword ptr [rbx+104A0h]
00007FF91DFE12E6  F3 0F 58 9B B0 06 01 00     addss   xmm3, dword ptr [rbx+106B0h]
00007FF91DFE12EE  F3 0F 10 8B B0 05 01 00     movss   xmm1, dword ptr [rbx+105B0h]
00007FF91DFE12F6  F3 0F 59 8B B0 04 01 00     mulss   xmm1, dword ptr [rbx+104B0h]
00007FF91DFE12FE  F3 0F 10 93 00 05 01 00     movss   xmm2, dword ptr [rbx+10500h]
00007FF91DFE1306  F3 0F 59 9B 90 05 01 00     mulss   xmm3, dword ptr [rbx+10590h]
00007FF91DFE130E  F3 0F 58 93 D0 04 01 00     addss   xmm2, dword ptr [rbx+104D0h]
00007FF91DFE1316  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE131A  F3 0F 58 93 10 05 01 00     addss   xmm2, dword ptr [rbx+10510h]
00007FF91DFE1322  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE1326  F3 0F 58 9B C0 05 01 00     addss   xmm3, dword ptr [rbx+105C0h]
00007FF91DFE132E  F3 0F 59 9B 90 06 01 00     mulss   xmm3, dword ptr [rbx+10690h]
00007FF91DFE1336  F3 0F 11 9B 40 05 01 00     movss   dword ptr [rbx+10540h], xmm3
00007FF91DFE133E  F3 0F 11 93 50 05 01 00     movss   dword ptr [rbx+10550h], xmm2
00007FF91DFE1346  F3 0F 10 83 D0 06 01 00     movss   xmm0, dword ptr [rbx+106D0h]
00007FF91DFE134E  8B 83 C0 06 01 00           mov     eax, [rbx+106C0h]
00007FF91DFE1354  89 83 F0 06 01 00           mov     [rbx+106F0h], eax
00007FF91DFE135A  F3 0F 11 83 00 07 01 00     movss   dword ptr [rbx+10700h], xmm0
00007FF91DFE1362  8B 83 E0 06 01 00           mov     eax, [rbx+106E0h]
00007FF91DFE1368  89 83 10 07 01 00           mov     [rbx+10710h], eax
00007FF91DFE136E  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
00007FF91DFE1376  8B 83 30 07 01 00           mov     eax, [rbx+10730h]
00007FF91DFE137C  89 83 40 07 01 00           mov     [rbx+10740h], eax
00007FF91DFE1382  F3 0F 10 93 20 07 01 00     movss   xmm2, dword ptr [rbx+10720h]
00007FF91DFE138A  F3 0F 11 93 30 07 01 00     movss   dword ptr [rbx+10730h], xmm2
00007FF91DFE1392  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE1395  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE1398  F3 0F 59 9B 50 07 01 00     mulss   xmm3, dword ptr [rbx+10750h]
00007FF91DFE13A0  F3 0F 58 9B 40 07 01 00     addss   xmm3, dword ptr [rbx+10740h]
00007FF91DFE13A8  F3 0F 11 9B 30 07 01 00     movss   dword ptr [rbx+10730h], xmm3
00007FF91DFE13B0  F3 0F 59 83 60 07 01 00     mulss   xmm0, dword ptr [rbx+10760h]
00007FF91DFE13B8  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFE13BC  F3 0F 59 9B 90 07 01 00     mulss   xmm3, dword ptr [rbx+10790h]
00007FF91DFE13C4  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFE13C8  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFE13CB  F3 0F 59 8B 50 07 01 00     mulss   xmm1, dword ptr [rbx+10750h]
00007FF91DFE13D3  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE13D7  F3 0F 11 8B 20 07 01 00     movss   dword ptr [rbx+10720h], xmm1
00007FF91DFE13DF  F3 0F 59 8B 80 07 01 00     mulss   xmm1, dword ptr [rbx+10780h]
00007FF91DFE13E7  F3 0F 59 A3 70 07 01 00     mulss   xmm4, dword ptr [rbx+10770h]
00007FF91DFE13EF  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE13F3  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE13F7  F3 0F 11 A3 40 07 01 00     movss   dword ptr [rbx+10740h], xmm4
00007FF91DFE13FF  8B 83 70 0F 01 00           mov     eax, [rbx+10F70h]
00007FF91DFE1405  89 83 80 0F 01 00           mov     [rbx+10F80h], eax
00007FF91DFE140B  F3 0F 10 8B 90 0F 01 00     movss   xmm1, dword ptr [rbx+10F90h]
00007FF91DFE1413  F3 0F 11 8B A0 0F 01 00     movss   dword ptr [rbx+10FA0h], xmm1
00007FF91DFE141B  F3 0F 59 8B 30 04 01 00     mulss   xmm1, dword ptr [rbx+10430h]
00007FF91DFE1423  F3 0F 10 83 80 0F 01 00     movss   xmm0, dword ptr [rbx+10F80h]
00007FF91DFE142B  F3 0F 59 83 40 07 01 00     mulss   xmm0, dword ptr [rbx+10740h]
00007FF91DFE1433  F3 0F 11 8B B0 0F 01 00     movss   dword ptr [rbx+10FB0h], xmm1
00007FF91DFE143B  F3 0F 11 83 C0 0F 01 00     movss   dword ptr [rbx+10FC0h], xmm0
00007FF91DFE1443  8B 83 F0 0F 01 00           mov     eax, [rbx+10FF0h]
00007FF91DFE1449  89 83 00 10 01 00           mov     [rbx+11000h], eax
00007FF91DFE144F  F3 0F 59 8B D0 0F 01 00     mulss   xmm1, dword ptr [rbx+10FD0h]
00007FF91DFE1457  F3 0F 59 83 E0 0F 01 00     mulss   xmm0, dword ptr [rbx+10FE0h]
00007FF91DFE145F  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFE1463  F3 0F 11 83 F0 0F 01 00     movss   dword ptr [rbx+10FF0h], xmm0
00007FF91DFE146B  8B 83 10 10 01 00           mov     eax, [rbx+11010h]
00007FF91DFE1471  89 83 20 10 01 00           mov     [rbx+11020h], eax
00007FF91DFE1477  8B 83 30 10 01 00           mov     eax, [rbx+11030h]
00007FF91DFE147D  89 83 40 10 01 00           mov     [rbx+11040h], eax
00007FF91DFE1483  8B 83 50 10 01 00           mov     eax, [rbx+11050h]
00007FF91DFE1489  89 83 60 10 01 00           mov     [rbx+11060h], eax
00007FF91DFE148F  8B 83 70 10 01 00           mov     eax, [rbx+11070h]
00007FF91DFE1495  89 83 80 10 01 00           mov     [rbx+11080h], eax
00007FF91DFE149B  F3 0F 10 8B A0 10 01 00     movss   xmm1, dword ptr [rbx+110A0h]
00007FF91DFE14A3  F3 0F 10 93 B0 10 01 00     movss   xmm2, dword ptr [rbx+110B0h]
00007FF91DFE14AB  0F 28 E1                    movaps  xmm4, xmm1
00007FF91DFE14AE  F3 0F 59 A3 10 10 01 00     mulss   xmm4, dword ptr [rbx+11010h]
00007FF91DFE14B6  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE14B9  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE14BD  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFE14C1  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFE14C5  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFE14C8  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFE14CB  F3 0F 59 8B D0 10 01 00     mulss   xmm1, dword ptr [rbx+110D0h]
00007FF91DFE14D3  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE14D7  F3 0F 58 8B C0 10 01 00     addss   xmm1, dword ptr [rbx+110C0h]
00007FF91DFE14DF  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE14E2  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE14E6  F3 0F 59 83 E0 10 01 00     mulss   xmm0, dword ptr [rbx+110E0h]
00007FF91DFE14EE  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE14F2  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE14F5  F3 0F 59 9B F0 10 01 00     mulss   xmm3, dword ptr [rbx+110F0h]
00007FF91DFE14FD  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE1501  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE1505  F3 0F 59 83 00 11 01 00     mulss   xmm0, dword ptr [rbx+11100h]
00007FF91DFE150D  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFE1511  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE1515  76 05                       jbe     short loc_7FF91DFE151C
00007FF91DFE1517  0F 5A C0                    cvtps2pd xmm0, xmm0
00007FF91DFE151A  EB 03                       jmp     short loc_7FF91DFE151F
00007FF91DFE151C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE151F  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFE1523  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFE1527  73 04                       jnb     short loc_7FF91DFE152D
00007FF91DFE1529  44 0F 5A E1                 cvtps2pd xmm12, xmm1
00007FF91DFE152D  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
00007FF91DFE1532  F3 0F 11 83 90 10 01 00     movss   dword ptr [rbx+11090h], xmm0
00007FF91DFE153A  8B 83 10 11 01 00           mov     eax, [rbx+11110h]
00007FF91DFE1540  89 83 20 11 01 00           mov     [rbx+11120h], eax
00007FF91DFE1546  F3 0F 10 8B 30 11 01 00     movss   xmm1, dword ptr [rbx+11130h]
00007FF91DFE154E  F3 0F 11 8B 40 11 01 00     movss   dword ptr [rbx+11140h], xmm1
00007FF91DFE1556  F3 0F 10 83 50 11 01 00     movss   xmm0, dword ptr [rbx+11150h]
00007FF91DFE155E  F3 0F 11 83 60 11 01 00     movss   dword ptr [rbx+11160h], xmm0
00007FF91DFE1566  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE156A  F3 0F 59 8B 70 11 01 00     mulss   xmm1, dword ptr [rbx+11170h]
00007FF91DFE1572  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE1576  F3 0F 11 8B 50 11 01 00     movss   dword ptr [rbx+11150h], xmm1
00007FF91DFE157E  F3 0F 10 8B 50 F9 00 00     movss   xmm1, dword ptr [rbx+0F950h]
00007FF91DFE1586  F3 0F 10 83 D0 F9 00 00     movss   xmm0, dword ptr [rbx+0F9D0h]
00007FF91DFE158E  8B 83 A0 11 01 00           mov     eax, [rbx+111A0h]
00007FF91DFE1594  89 83 B0 11 01 00           mov     [rbx+111B0h], eax
00007FF91DFE159A  F3 0F 59 83 90 11 01 00     mulss   xmm0, dword ptr [rbx+11190h]
00007FF91DFE15A2  F3 0F 59 8B 80 11 01 00     mulss   xmm1, dword ptr [rbx+11180h]
00007FF91DFE15AA  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFE15AE  F3 0F 11 83 A0 11 01 00     movss   dword ptr [rbx+111A0h], xmm0
00007FF91DFE15B6  8B 83 C0 11 01 00           mov     eax, [rbx+111C0h]
00007FF91DFE15BC  89 83 E0 11 01 00           mov     [rbx+111E0h], eax
00007FF91DFE15C2  F3 0F 10 9B D0 11 01 00     movss   xmm3, dword ptr [rbx+111D0h]
00007FF91DFE15CA  F3 0F 11 9B F0 11 01 00     movss   dword ptr [rbx+111F0h], xmm3
00007FF91DFE15D2  F3 0F 10 8B E0 11 01 00     movss   xmm1, dword ptr [rbx+111E0h]
00007FF91DFE15DA  F3 0F 10 93 20 01 01 00     movss   xmm2, dword ptr [rbx+10120h]
00007FF91DFE15E2  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE15E5  F3 0F 59 83 00 03 01 00     mulss   xmm0, dword ptr [rbx+10300h]
00007FF91DFE15ED  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFE15F1  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFE15F5  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE15F8  F3 0F 59 8B 50 10 01 00     mulss   xmm1, dword ptr [rbx+11050h]
00007FF91DFE1600  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE1604  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFE1608  F3 0F 5C CB                 subss   xmm1, xmm3
00007FF91DFE160C  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE1610  F3 0F 11 8B 00 12 01 00     movss   dword ptr [rbx+11200h], xmm1
00007FF91DFE1618  F3 0F 10 9B 60 FD 00 00     movss   xmm3, dword ptr [rbx+0FD60h]
00007FF91DFE1620  F3 0F 10 83 10 12 01 00     movss   xmm0, dword ptr [rbx+11210h]
00007FF91DFE1628  F3 0F 11 83 20 12 01 00     movss   dword ptr [rbx+11220h], xmm0
00007FF91DFE1630  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE1634  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE1637  F3 0F 59 8B 30 12 01 00     mulss   xmm1, dword ptr [rbx+11230h]
00007FF91DFE163F  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE1643  F3 0F 10 83 50 12 01 00     movss   xmm0, dword ptr [rbx+11250h]
00007FF91DFE164B  F3 0F 11 8B 10 12 01 00     movss   dword ptr [rbx+11210h], xmm1
00007FF91DFE1653  F3 0F 59 9B 40 12 01 00     mulss   xmm3, dword ptr [rbx+11240h]
00007FF91DFE165B  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE165F  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE1663  F3 0F 11 9B 20 12 01 00     movss   dword ptr [rbx+11220h], xmm3
00007FF91DFE166B  F3 0F 10 83 60 12 01 00     movss   xmm0, dword ptr [rbx+11260h]
00007FF91DFE1673  F3 0F 10 BB 70 FD 00 00     movss   xmm7, dword ptr [rbx+0FD70h]
00007FF91DFE167B  F3 0F 11 83 70 12 01 00     movss   dword ptr [rbx+11270h], xmm0
00007FF91DFE1683  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFE1687  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFE168A  F3 0F 59 8B 80 12 01 00     mulss   xmm1, dword ptr [rbx+11280h]
00007FF91DFE1692  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE1696  F3 0F 10 83 A0 12 01 00     movss   xmm0, dword ptr [rbx+112A0h]
00007FF91DFE169E  F3 0F 11 8B 60 12 01 00     movss   dword ptr [rbx+11260h], xmm1
00007FF91DFE16A6  F3 0F 59 BB 90 12 01 00     mulss   xmm7, dword ptr [rbx+11290h]
00007FF91DFE16AE  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE16B2  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFE16B6  F3 0F 11 BB 70 12 01 00     movss   dword ptr [rbx+11270h], xmm7
00007FF91DFE16BE  F3 0F 10 A3 20 12 01 00     movss   xmm4, dword ptr [rbx+11220h]
00007FF91DFE16C6  F3 0F 10 AB 00 12 01 00     movss   xmm5, dword ptr [rbx+11200h]
00007FF91DFE16CE  F3 0F 10 B3 A0 11 01 00     movss   xmm6, dword ptr [rbx+111A0h]
00007FF91DFE16D6  F3 44 0F 10 8B 30 10 01 00  movss   xmm9, dword ptr [rbx+11030h]
00007FF91DFE16DF  8B 83 50 11 01 00           mov     eax, [rbx+11150h]
00007FF91DFE16E5  89 83 B0 12 01 00           mov     [rbx+112B0h], eax
00007FF91DFE16EB  F3 44 0F 11 8B C0 12 01 00  movss   dword ptr [rbx+112C0h], xmm9
00007FF91DFE16F4  F3 0F 10 83 E0 12 01 00     movss   xmm0, dword ptr [rbx+112E0h]
00007FF91DFE16FC  F3 0F 10 93 F0 12 01 00     movss   xmm2, dword ptr [rbx+112F0h]
00007FF91DFE1704  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFE1708  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE170B  F3 0F 59 9B 70 10 01 00     mulss   xmm3, dword ptr [rbx+11070h]
00007FF91DFE1713  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE1717  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE171A  F3 0F 59 C7                 mulss   xmm0, xmm7
00007FF91DFE171E  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFE1722  F3 44 0F 5C C0              subss   xmm8, xmm0
00007FF91DFE1727  F3 44 0F 58 C7              addss   xmm8, xmm7
00007FF91DFE172C  F3 44 0F 59 83 20 13 01 00  mulss   xmm8, dword ptr [rbx+11320h]
00007FF91DFE1735  F3 0F 10 8B 00 13 01 00     movss   xmm1, dword ptr [rbx+11300h]
00007FF91DFE173D  F3 0F 58 B3 A0 13 01 00     addss   xmm6, dword ptr [rbx+113A0h]
00007FF91DFE1745  F3 44 0F 59 83 30 13 01 00  mulss   xmm8, dword ptr [rbx+11330h]
00007FF91DFE174E  F3 0F 59 AB 40 13 01 00     mulss   xmm5, dword ptr [rbx+11340h]
00007FF91DFE1756  F3 0F 59 B3 50 13 01 00     mulss   xmm6, dword ptr [rbx+11350h]
00007FF91DFE175E  F3 44 0F 59 C9              mulss   xmm9, xmm1
00007FF91DFE1763  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE1767  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFE176B  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFE176F  F3 0F 10 93 80 13 01 00     movss   xmm2, dword ptr [rbx+11380h]
00007FF91DFE1777  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE177A  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE177E  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFE1782  F3 44 0F 5C C8              subss   xmm9, xmm0
00007FF91DFE1787  F3 0F 10 83 70 13 01 00     movss   xmm0, dword ptr [rbx+11370h]
00007FF91DFE178F  F3 0F 58 83 B0 12 01 00     addss   xmm0, dword ptr [rbx+112B0h]
00007FF91DFE1797  F3 0F 59 9B 10 13 01 00     mulss   xmm3, dword ptr [rbx+11310h]
00007FF91DFE179F  F3 0F 59 83 B0 13 01 00     mulss   xmm0, dword ptr [rbx+113B0h]
00007FF91DFE17A7  F3 44 0F 58 CA              addss   xmm9, xmm2
00007FF91DFE17AC  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFE17B1  F3 0F 59 83 60 13 01 00     mulss   xmm0, dword ptr [rbx+11360h]
00007FF91DFE17B9  F3 44 0F 59 8B 90 13 01 00  mulss   xmm9, dword ptr [rbx+11390h]
00007FF91DFE17C2  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFE17C7  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFE17CC  F3 45 0F 58 C8              addss   xmm9, xmm8
00007FF91DFE17D1  F3 44 0F 11 8B D0 12 01 00  movss   dword ptr [rbx+112D0h], xmm9
00007FF91DFE17DA  F3 0F 10 BB 90 10 01 00     movss   xmm7, dword ptr [rbx+11090h]
00007FF91DFE17E2  F3 44 0F 10 83 20 11 01 00  movss   xmm8, dword ptr [rbx+11120h]
00007FF91DFE17EB  8B 83 F0 13 01 00           mov     eax, [rbx+113F0h]
00007FF91DFE17F1  89 83 00 14 01 00           mov     [rbx+11400h], eax
00007FF91DFE17F7  F3 0F 10 83 E0 13 01 00     movss   xmm0, dword ptr [rbx+113E0h]
00007FF91DFE17FF  F3 0F 11 83 F0 13 01 00     movss   dword ptr [rbx+113F0h], xmm0
00007FF91DFE1807  44 0F 2E AB 30 14 01 00     ucomiss xmm13, dword ptr [rbx+11430h]
00007FF91DFE180F  0F 85 8F 02 00 00           jnz     loc_7FF91DFE1AA4
00007FF91DFE1815  F3 0F 10 8B 80 14 01 00     movss   xmm1, dword ptr [rbx+11480h]
00007FF91DFE181D  F3 0F 10 B3 00 14 01 00     movss   xmm6, dword ptr [rbx+11400h]
00007FF91DFE1825  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFE1828  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFE182C  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFE1830  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFE1834  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFE1838  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFE183C  F3 0F 11 B3 F0 13 01 00     movss   dword ptr [rbx+113F0h], xmm6
00007FF91DFE1844  F3 0F 59 B3 70 14 01 00     mulss   xmm6, dword ptr [rbx+11470h]
00007FF91DFE184C  F3 0F 58 B3 10 14 01 00     addss   xmm6, dword ptr [rbx+11410h]
00007FF91DFE1854  E8 07 75 FE FF              call    sub_7FF91DFC8D60
00007FF91DFE1859  F3 0F 11 83 E0 13 01 00     movss   dword ptr [rbx+113E0h], xmm0
00007FF91DFE1861  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFE1865  F3 0F 59 8B D0 14 01 00     mulss   xmm1, dword ptr [rbx+114D0h]
00007FF91DFE186D  41 0F 28 D5                 movaps  xmm2, xmm13
00007FF91DFE1871  F3 41 0F 5C D0              subss   xmm2, xmm8
00007FF91DFE1876  F3 0F 58 8B 20 14 01 00     addss   xmm1, dword ptr [rbx+11420h]
00007FF91DFE187E  F3 0F 59 93 90 14 01 00     mulss   xmm2, dword ptr [rbx+11490h]
00007FF91DFE1886  F3 0F 11 8B D0 13 01 00     movss   dword ptr [rbx+113D0h], xmm1
00007FF91DFE188E  F3 44 0F 59 8B 60 14 01 00  mulss   xmm9, dword ptr [rbx+11460h]
00007FF91DFE1897  F3 0F 59 BB 40 14 01 00     mulss   xmm7, dword ptr [rbx+11440h]
00007FF91DFE189F  F3 0F 10 83 A0 14 01 00     movss   xmm0, dword ptr [rbx+114A0h]
00007FF91DFE18A7  F3 0F 5D C2                 minss   xmm0, xmm2
00007FF91DFE18AB  F3 44 0F 58 CF              addss   xmm9, xmm7
00007FF91DFE18B0  F3 44 0F 58 CE              addss   xmm9, xmm6
00007FF91DFE18B5  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFE18BA  F3 44 0F 58 8B 50 14 01 00  addss   xmm9, dword ptr [rbx+11450h]
00007FF91DFE18C3  F3 44 0F 5D 8B B0 14 01 00  minss   xmm9, dword ptr [rbx+114B0h]
00007FF91DFE18CC  F3 44 0F 5F 8B C0 14 01 00  maxss   xmm9, dword ptr [rbx+114C0h]
00007FF91DFE18D5  F3 44 0F 59 8B F0 14 01 00  mulss   xmm9, dword ptr [rbx+114F0h]
00007FF91DFE18DE  F3 44 0F 58 8B 00 15 01 00  addss   xmm9, dword ptr [rbx+11500h]
00007FF91DFE18E7  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFE18EB  F3 0F 2C C9                 cvttss2si ecx, xmm1
00007FF91DFE18EF  81 F9 00 00 00 80           cmp     ecx, 80000000h
00007FF91DFE18F5  74 1E                       jz      short loc_7FF91DFE1915
00007FF91DFE18F7  66 0F 6E C1                 movd    xmm0, ecx
00007FF91DFE18FB  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFE18FE  0F 2E C1                    ucomiss xmm0, xmm1
00007FF91DFE1901  74 12                       jz      short loc_7FF91DFE1915
00007FF91DFE1903  0F 14 C9                    unpcklps xmm1, xmm1
00007FF91DFE1906  0F 50 C1                    movmskps eax, xmm1
00007FF91DFE1909  83 E0 01                    and     eax, 1
00007FF91DFE190C  2B C8                       sub     ecx, eax
00007FF91DFE190E  66 0F 6E C9                 movd    xmm1, ecx
00007FF91DFE1912  0F 5B C9                    cvtdq2ps xmm1, xmm1
00007FF91DFE1915  F3 44 0F 5C C9              subss   xmm9, xmm1
00007FF91DFE191A  0F 28 C1                    movaps  xmm0, xmm1; X
00007FF91DFE191D  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFE1921  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFE1926  F3 0F 59 35 A2 36 76 00     mulss   xmm6, cs:dword_7FF91E744FD0
00007FF91DFE192E  E8 0D DE 36 00              call    expf
00007FF91DFE1933  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFE1936  41 0F 28 D1                 movaps  xmm2, xmm9
00007FF91DFE193A  F3 0F 59 93 C0 15 01 00     mulss   xmm2, dword ptr [rbx+115C0h]
00007FF91DFE1942  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFE1946  F3 0F 59 8B A0 15 01 00     mulss   xmm1, dword ptr [rbx+115A0h]
00007FF91DFE194E  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFE1952  F3 0F 58 93 B0 15 01 00     addss   xmm2, dword ptr [rbx+115B0h]
00007FF91DFE195A  F3 0F 59 83 80 15 01 00     mulss   xmm0, dword ptr [rbx+11580h]
00007FF91DFE1962  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE1966  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE196A  F3 0F 58 93 90 15 01 00     addss   xmm2, dword ptr [rbx+11590h]
00007FF91DFE1972  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE1976  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE197A  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFE197E  F3 0F 59 83 60 15 01 00     mulss   xmm0, dword ptr [rbx+11560h]
00007FF91DFE1986  F3 0F 58 93 70 15 01 00     addss   xmm2, dword ptr [rbx+11570h]
00007FF91DFE198E  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE1992  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE1996  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFE199A  F3 0F 59 83 40 15 01 00     mulss   xmm0, dword ptr [rbx+11540h]
00007FF91DFE19A2  F3 44 0F 59 8B 20 15 01 00  mulss   xmm9, dword ptr [rbx+11520h]
00007FF91DFE19AB  F3 0F 58 93 50 15 01 00     addss   xmm2, dword ptr [rbx+11550h]
00007FF91DFE19B3  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE19B7  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE19BB  F3 0F 58 93 30 15 01 00     addss   xmm2, dword ptr [rbx+11530h]
00007FF91DFE19C3  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE19C7  F3 41 0F 58 D1              addss   xmm2, xmm9
00007FF91DFE19CC  F3 41 0F 58 D5              addss   xmm2, xmm13
00007FF91DFE19D1  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFE19D5  F3 0F 59 A3 10 15 01 00     mulss   xmm4, dword ptr [rbx+11510h]
00007FF91DFE19DD  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFE19E0  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE19E4  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE19E7  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFE19EB  F3 44 0F 59 83 60 16 01 00  mulss   xmm8, dword ptr [rbx+11660h]
00007FF91DFE19F4  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE19F7  F3 0F 59 83 20 16 01 00     mulss   xmm0, dword ptr [rbx+11620h]
00007FF91DFE19FF  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFE1A02  F3 44 0F 58 83 40 16 01 00  addss   xmm8, dword ptr [rbx+11640h]
00007FF91DFE1A0B  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE1A0F  F3 0F 58 83 00 16 01 00     addss   xmm0, dword ptr [rbx+11600h]
00007FF91DFE1A17  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE1A1B  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFE1A20  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFE1A25  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE1A28  F3 0F 59 8B E0 15 01 00     mulss   xmm1, dword ptr [rbx+115E0h]
00007FF91DFE1A30  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE1A34  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFE1A39  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE1A3C  F3 0F 59 83 10 16 01 00     mulss   xmm0, dword ptr [rbx+11610h]
00007FF91DFE1A44  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFE1A49  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE1A4C  F3 0F 59 8B 50 16 01 00     mulss   xmm1, dword ptr [rbx+11650h]
00007FF91DFE1A54  F3 0F 59 9B D0 15 01 00     mulss   xmm3, dword ptr [rbx+115D0h]
00007FF91DFE1A5C  F3 0F 58 8B 30 16 01 00     addss   xmm1, dword ptr [rbx+11630h]
00007FF91DFE1A64  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFE1A69  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFE1A6D  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE1A71  F3 0F 58 8B F0 15 01 00     addss   xmm1, dword ptr [rbx+115F0h]
00007FF91DFE1A79  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFE1A7D  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFE1A81  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFE1A86  F3 44 0F 5E C1              divss   xmm8, xmm1
00007FF91DFE1A8B  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFE1A8F  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE1A94  F3 44 0F 5E C0              divss   xmm8, xmm0
00007FF91DFE1A99  F3 44 0F 11 83 C0 13 01 00  movss   dword ptr [rbx+113C0h], xmm8
00007FF91DFE1AA2  EB 09                       jmp     short loc_7FF91DFE1AAD
00007FF91DFE1AA4  F3 44 0F 10 83 C0 13 01 00  movss   xmm8, dword ptr [rbx+113C0h]
00007FF91DFE1AAD  8B 83 D0 16 01 00           mov     eax, [rbx+116D0h]
00007FF91DFE1AB3  F3 0F 10 8B F0 0F 01 00     movss   xmm1, dword ptr [rbx+10FF0h]
00007FF91DFE1ABB  F3 44 0F 10 8B D0 13 01 00  movss   xmm9, dword ptr [rbx+113D0h]
00007FF91DFE1AC4  89 83 E0 16 01 00           mov     [rbx+116E0h], eax
00007FF91DFE1ACA  8B 83 C0 16 01 00           mov     eax, [rbx+116C0h]
00007FF91DFE1AD0  89 83 D0 16 01 00           mov     [rbx+116D0h], eax
00007FF91DFE1AD6  8B 83 B0 16 01 00           mov     eax, [rbx+116B0h]
00007FF91DFE1ADC  89 83 C0 16 01 00           mov     [rbx+116C0h], eax
00007FF91DFE1AE2  8B 83 A0 16 01 00           mov     eax, [rbx+116A0h]
00007FF91DFE1AE8  89 83 B0 16 01 00           mov     [rbx+116B0h], eax
00007FF91DFE1AEE  8B 83 90 16 01 00           mov     eax, [rbx+11690h]
00007FF91DFE1AF4  89 83 A0 16 01 00           mov     [rbx+116A0h], eax
00007FF91DFE1AFA  8B 83 80 16 01 00           mov     eax, [rbx+11680h]
00007FF91DFE1B00  89 83 90 16 01 00           mov     [rbx+11690h], eax
00007FF91DFE1B06  8B 83 70 16 01 00           mov     eax, [rbx+11670h]
00007FF91DFE1B0C  89 83 80 16 01 00           mov     [rbx+11680h], eax
00007FF91DFE1B12  8B 83 B0 17 01 00           mov     eax, [rbx+117B0h]
00007FF91DFE1B18  89 83 C0 17 01 00           mov     [rbx+117C0h], eax
00007FF91DFE1B1E  8B 83 A0 17 01 00           mov     eax, [rbx+117A0h]
00007FF91DFE1B24  89 83 B0 17 01 00           mov     [rbx+117B0h], eax
00007FF91DFE1B2A  8B 83 90 17 01 00           mov     eax, [rbx+11790h]
00007FF91DFE1B30  89 83 A0 17 01 00           mov     [rbx+117A0h], eax
00007FF91DFE1B36  8B 83 80 17 01 00           mov     eax, [rbx+11780h]
00007FF91DFE1B3C  89 83 90 17 01 00           mov     [rbx+11790h], eax
00007FF91DFE1B42  8B 83 70 17 01 00           mov     eax, [rbx+11770h]
00007FF91DFE1B48  89 83 80 17 01 00           mov     [rbx+11780h], eax
00007FF91DFE1B4E  8B 83 60 17 01 00           mov     eax, [rbx+11760h]
00007FF91DFE1B54  89 83 70 17 01 00           mov     [rbx+11770h], eax
00007FF91DFE1B5A  8B 83 50 17 01 00           mov     eax, [rbx+11750h]
00007FF91DFE1B60  89 83 60 17 01 00           mov     [rbx+11760h], eax
00007FF91DFE1B66  8B 83 30 18 01 00           mov     eax, [rbx+11830h]
00007FF91DFE1B6C  89 83 40 18 01 00           mov     [rbx+11840h], eax
00007FF91DFE1B72  8B 83 20 18 01 00           mov     eax, [rbx+11820h]
00007FF91DFE1B78  89 83 30 18 01 00           mov     [rbx+11830h], eax
00007FF91DFE1B7E  8B 83 10 18 01 00           mov     eax, [rbx+11810h]
00007FF91DFE1B84  89 83 20 18 01 00           mov     [rbx+11820h], eax
00007FF91DFE1B8A  8B 83 00 18 01 00           mov     eax, [rbx+11800h]
00007FF91DFE1B90  89 83 10 18 01 00           mov     [rbx+11810h], eax
00007FF91DFE1B96  8B 83 F0 17 01 00           mov     eax, [rbx+117F0h]
00007FF91DFE1B9C  89 83 00 18 01 00           mov     [rbx+11800h], eax
00007FF91DFE1BA2  8B 83 E0 17 01 00           mov     eax, [rbx+117E0h]
00007FF91DFE1BA8  89 83 F0 17 01 00           mov     [rbx+117F0h], eax
00007FF91DFE1BAE  8B 83 D0 17 01 00           mov     eax, [rbx+117D0h]
00007FF91DFE1BB4  89 83 E0 17 01 00           mov     [rbx+117E0h], eax
00007FF91DFE1BBA  8B 83 B0 18 01 00           mov     eax, [rbx+118B0h]
00007FF91DFE1BC0  89 83 C0 18 01 00           mov     [rbx+118C0h], eax
00007FF91DFE1BC6  8B 83 A0 18 01 00           mov     eax, [rbx+118A0h]
00007FF91DFE1BCC  89 83 B0 18 01 00           mov     [rbx+118B0h], eax
00007FF91DFE1BD2  8B 83 90 18 01 00           mov     eax, [rbx+11890h]
00007FF91DFE1BD8  89 83 A0 18 01 00           mov     [rbx+118A0h], eax
00007FF91DFE1BDE  8B 83 80 18 01 00           mov     eax, [rbx+11880h]
00007FF91DFE1BE4  89 83 90 18 01 00           mov     [rbx+11890h], eax
00007FF91DFE1BEA  8B 83 70 18 01 00           mov     eax, [rbx+11870h]
00007FF91DFE1BF0  89 83 80 18 01 00           mov     [rbx+11880h], eax
00007FF91DFE1BF6  8B 83 60 18 01 00           mov     eax, [rbx+11860h]
00007FF91DFE1BFC  89 83 70 18 01 00           mov     [rbx+11870h], eax
00007FF91DFE1C02  8B 83 50 18 01 00           mov     eax, [rbx+11850h]
00007FF91DFE1C08  89 83 60 18 01 00           mov     [rbx+11860h], eax
00007FF91DFE1C0E  8B 83 30 19 01 00           mov     eax, [rbx+11930h]
00007FF91DFE1C14  89 83 40 19 01 00           mov     [rbx+11940h], eax
00007FF91DFE1C1A  8B 83 20 19 01 00           mov     eax, [rbx+11920h]
00007FF91DFE1C20  89 83 30 19 01 00           mov     [rbx+11930h], eax
00007FF91DFE1C26  8B 83 10 19 01 00           mov     eax, [rbx+11910h]
00007FF91DFE1C2C  89 83 20 19 01 00           mov     [rbx+11920h], eax
00007FF91DFE1C32  8B 83 00 19 01 00           mov     eax, [rbx+11900h]
00007FF91DFE1C38  89 83 10 19 01 00           mov     [rbx+11910h], eax
00007FF91DFE1C3E  8B 83 F0 18 01 00           mov     eax, [rbx+118F0h]
00007FF91DFE1C44  89 83 00 19 01 00           mov     [rbx+11900h], eax
00007FF91DFE1C4A  8B 83 E0 18 01 00           mov     eax, [rbx+118E0h]
00007FF91DFE1C50  89 83 F0 18 01 00           mov     [rbx+118F0h], eax
00007FF91DFE1C56  8B 83 D0 18 01 00           mov     eax, [rbx+118D0h]
00007FF91DFE1C5C  89 83 E0 18 01 00           mov     [rbx+118E0h], eax
00007FF91DFE1C62  8B 83 50 19 01 00           mov     eax, [rbx+11950h]
00007FF91DFE1C68  89 83 60 19 01 00           mov     [rbx+11960h], eax
00007FF91DFE1C6E  F3 0F 10 83 70 19 01 00     movss   xmm0, dword ptr [rbx+11970h]
00007FF91DFE1C76  F3 0F 11 83 80 19 01 00     movss   dword ptr [rbx+11980h], xmm0
00007FF91DFE1C7E  44 0F 2E AB C0 19 01 00     ucomiss xmm13, dword ptr [rbx+119C0h]
00007FF91DFE1C86  0F 85 49 09 00 00           jnz     loc_7FF91DFE25D5
00007FF91DFE1C8C  F3 0F 59 8B 10 1A 01 00     mulss   xmm1, dword ptr [rbx+11A10h]
00007FF91DFE1C94  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFE1C98  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFE1C9C  41 0F 28 F8                 movaps  xmm7, xmm8
00007FF91DFE1CA0  F3 0F 59 B3 30 1A 01 00     mulss   xmm6, dword ptr [rbx+11A30h]
00007FF91DFE1CA8  F3 41 0F 59 F8              mulss   xmm7, xmm8
00007FF91DFE1CAD  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE1CB2  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFE1CB6  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFE1CB9  F3 0F 59 8B 00 1A 01 00     mulss   xmm1, dword ptr [rbx+11A00h]
00007FF91DFE1CC1  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFE1CC5  E8 96 70 FE FF              call    sub_7FF91DFC8D60
00007FF91DFE1CCA  F3 0F 11 83 70 19 01 00     movss   dword ptr [rbx+11970h], xmm0
00007FF91DFE1CD2  41 0F 28 DD                 movaps  xmm3, xmm13
00007FF91DFE1CD6  F3 0F 11 B3 50 19 01 00     movss   dword ptr [rbx+11950h], xmm6
00007FF91DFE1CDE  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFE1CE2  F3 0F 59 FF                 mulss   xmm7, xmm7
00007FF91DFE1CE6  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFE1CEB  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE1CEF  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFE1CF4  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFE1CF8  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE1CFD  F3 0F 5E DF                 divss   xmm3, xmm7
00007FF91DFE1D01  F3 0F 11 9B A0 19 01 00     movss   dword ptr [rbx+119A0h], xmm3
00007FF91DFE1D09  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFE1D0C  F3 0F 10 8B 50 19 01 00     movss   xmm1, dword ptr [rbx+11950h]
00007FF91DFE1D14  F3 0F 10 AB 60 19 01 00     movss   xmm5, dword ptr [rbx+11960h]
00007FF91DFE1D1C  F3 41 0F 59 E1              mulss   xmm4, xmm9
00007FF91DFE1D21  F3 0F 11 A3 90 19 01 00     movss   dword ptr [rbx+11990h], xmm4
00007FF91DFE1D29  F3 0F 59 AB 60 1A 01 00     mulss   xmm5, dword ptr [rbx+11A60h]
00007FF91DFE1D31  F3 0F 10 93 D0 16 01 00     movss   xmm2, dword ptr [rbx+116D0h]
00007FF91DFE1D39  F3 0F 59 8B 70 1A 01 00     mulss   xmm1, dword ptr [rbx+11A70h]
00007FF91DFE1D41  F3 0F 10 83 E0 16 01 00     movss   xmm0, dword ptr [rbx+116E0h]
00007FF91DFE1D49  F3 0F 11 93 40 17 01 00     movss   dword ptr [rbx+11740h], xmm2
00007FF91DFE1D51  F3 0F 59 93 90 1B 01 00     mulss   xmm2, dword ptr [rbx+11B90h]
00007FF91DFE1D59  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE1D5D  F3 0F 59 83 A0 1B 01 00     mulss   xmm0, dword ptr [rbx+11BA0h]
00007FF91DFE1D65  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFE1D69  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE1D6D  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE1D71  F3 0F 5C EA                 subss   xmm5, xmm2
00007FF91DFE1D75  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE1D79  73 06                       jnb     short loc_7FF91DFE1D81
00007FF91DFE1D7B  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE1D7F  EB 05                       jmp     short loc_7FF91DFE1D86
00007FF91DFE1D81  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE1D86  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFE1D89  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE1D8C  F3 0F 59 83 40 1A 01 00     mulss   xmm0, dword ptr [rbx+11A40h]
00007FF91DFE1D94  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE1D98  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE1D9C  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE1DA0  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE1DA4  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE1DA8  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE1DAC  F3 0F 11 AB F0 16 01 00     movss   dword ptr [rbx+116F0h], xmm5
00007FF91DFE1DB4  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE1DB7  F3 0F 58 AB 80 16 01 00     addss   xmm5, dword ptr [rbx+11680h]
00007FF91DFE1DBF  F3 0F 10 9B 90 16 01 00     movss   xmm3, dword ptr [rbx+11690h]
00007FF91DFE1DC7  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE1DCA  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE1DCE  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE1DD2  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFE1DD6  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFE1DDA  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE1DDE  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE1DE2  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE1DE5  F3 0F 11 A3 00 17 01 00     movss   dword ptr [rbx+11700h], xmm4
00007FF91DFE1DED  F3 0F 10 8B A0 16 01 00     movss   xmm1, dword ptr [rbx+116A0h]
00007FF91DFE1DF5  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE1DF9  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE1DFD  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE1E00  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE1E04  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFE1E08  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE1E0C  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFE1E10  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE1E14  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE1E18  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE1E1C  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE1E20  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE1E23  F3 0F 11 9B 10 17 01 00     movss   dword ptr [rbx+11710h], xmm3
00007FF91DFE1E2B  F3 0F 10 AB B0 16 01 00     movss   xmm5, dword ptr [rbx+116B0h]
00007FF91DFE1E33  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE1E37  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE1E3B  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE1E3E  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE1E42  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE1E46  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE1E4A  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFE1E4E  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE1E52  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE1E56  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE1E5A  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE1E5E  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE1E61  F3 0F 11 93 20 17 01 00     movss   dword ptr [rbx+11720h], xmm2
00007FF91DFE1E69  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFE1E6D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE1E71  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE1E75  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFE1E7A  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE1E7D  F3 0F 59 83 C0 16 01 00     mulss   xmm0, dword ptr [rbx+116C0h]
00007FF91DFE1E85  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE1E89  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE1E8D  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE1E90  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFE1E94  F3 0F 11 AB 30 17 01 00     movss   dword ptr [rbx+11730h], xmm5
00007FF91DFE1E9C  F3 0F 10 93 20 17 01 00     movss   xmm2, dword ptr [rbx+11720h]
00007FF91DFE1EA4  F3 0F 59 93 E0 19 01 00     mulss   xmm2, dword ptr [rbx+119E0h]
00007FF91DFE1EAC  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE1EB0  F3 0F 59 AB F0 19 01 00     mulss   xmm5, dword ptr [rbx+119F0h]
00007FF91DFE1EB8  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE1EBC  F3 0F 10 83 D0 19 01 00     movss   xmm0, dword ptr [rbx+119D0h]
00007FF91DFE1EC4  F3 0F 59 83 10 17 01 00     mulss   xmm0, dword ptr [rbx+11710h]
00007FF91DFE1ECC  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFE1ED0  F3 0F 10 AB 60 19 01 00     movss   xmm5, dword ptr [rbx+11960h]
00007FF91DFE1ED8  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE1EDC  F3 0F 11 93 D0 18 01 00     movss   dword ptr [rbx+118D0h], xmm2
00007FF91DFE1EE4  F3 0F 58 AB 50 19 01 00     addss   xmm5, dword ptr [rbx+11950h]
00007FF91DFE1EEC  F3 0F 10 83 40 17 01 00     movss   xmm0, dword ptr [rbx+11740h]
00007FF91DFE1EF4  F3 0F 59 AB 80 1A 01 00     mulss   xmm5, dword ptr [rbx+11A80h]
00007FF91DFE1EFC  F3 0F 59 AB A0 19 01 00     mulss   xmm5, dword ptr [rbx+119A0h]
00007FF91DFE1F04  F3 0F 11 A3 40 17 01 00     movss   dword ptr [rbx+11740h], xmm4
00007FF91DFE1F0C  F3 0F 59 A3 90 1B 01 00     mulss   xmm4, dword ptr [rbx+11B90h]
00007FF91DFE1F14  F3 0F 59 83 A0 1B 01 00     mulss   xmm0, dword ptr [rbx+11BA0h]
00007FF91DFE1F1C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE1F20  F3 0F 59 A3 90 19 01 00     mulss   xmm4, dword ptr [rbx+11990h]
00007FF91DFE1F28  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFE1F2C  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE1F30  73 06                       jnb     short loc_7FF91DFE1F38
00007FF91DFE1F32  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE1F36  EB 05                       jmp     short loc_7FF91DFE1F3D
00007FF91DFE1F38  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE1F3D  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFE1F40  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE1F43  F3 0F 59 83 40 1A 01 00     mulss   xmm0, dword ptr [rbx+11A40h]
00007FF91DFE1F4B  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE1F4F  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE1F53  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE1F57  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE1F5B  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE1F5F  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE1F63  F3 0F 10 8B F0 16 01 00     movss   xmm1, dword ptr [rbx+116F0h]
00007FF91DFE1F6B  F3 0F 11 AB F0 16 01 00     movss   dword ptr [rbx+116F0h], xmm5
00007FF91DFE1F73  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE1F76  F3 0F 10 9B 00 17 01 00     movss   xmm3, dword ptr [rbx+11700h]
00007FF91DFE1F7E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE1F82  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE1F85  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE1F89  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE1F8D  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFE1F91  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFE1F95  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE1F99  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE1F9D  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE1FA0  F3 0F 11 A3 00 17 01 00     movss   dword ptr [rbx+11700h], xmm4
00007FF91DFE1FA8  F3 0F 10 8B 10 17 01 00     movss   xmm1, dword ptr [rbx+11710h]
00007FF91DFE1FB0  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE1FB4  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE1FB8  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE1FBB  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE1FBF  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFE1FC3  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE1FC7  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFE1FCB  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE1FCF  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE1FD3  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE1FD7  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE1FDB  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE1FDE  F3 0F 11 9B 10 17 01 00     movss   dword ptr [rbx+11710h], xmm3
00007FF91DFE1FE6  F3 0F 10 AB 20 17 01 00     movss   xmm5, dword ptr [rbx+11720h]
00007FF91DFE1FEE  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE1FF2  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE1FF6  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE1FF9  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE1FFD  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE2001  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE2005  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFE2009  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE200D  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE2011  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE2015  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE2019  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE201C  F3 0F 11 93 20 17 01 00     movss   dword ptr [rbx+11720h], xmm2
00007FF91DFE2024  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFE2028  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE202C  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE2030  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFE2035  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE2038  F3 0F 59 83 30 17 01 00     mulss   xmm0, dword ptr [rbx+11730h]
00007FF91DFE2040  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE2044  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE2048  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE204B  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFE204F  F3 0F 11 AB 30 17 01 00     movss   dword ptr [rbx+11730h], xmm5
00007FF91DFE2057  F3 0F 10 93 20 17 01 00     movss   xmm2, dword ptr [rbx+11720h]
00007FF91DFE205F  F3 0F 59 93 E0 19 01 00     mulss   xmm2, dword ptr [rbx+119E0h]
00007FF91DFE2067  F3 0F 10 8B 50 19 01 00     movss   xmm1, dword ptr [rbx+11950h]
00007FF91DFE206F  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE2073  F3 0F 59 AB F0 19 01 00     mulss   xmm5, dword ptr [rbx+119F0h]
00007FF91DFE207B  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE207F  F3 0F 10 83 D0 19 01 00     movss   xmm0, dword ptr [rbx+119D0h]
00007FF91DFE2087  F3 0F 59 83 10 17 01 00     mulss   xmm0, dword ptr [rbx+11710h]
00007FF91DFE208F  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFE2093  F3 0F 10 AB 60 19 01 00     movss   xmm5, dword ptr [rbx+11960h]
00007FF91DFE209B  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE209F  F3 0F 11 93 50 18 01 00     movss   dword ptr [rbx+11850h], xmm2
00007FF91DFE20A7  F3 0F 59 AB 70 1A 01 00     mulss   xmm5, dword ptr [rbx+11A70h]
00007FF91DFE20AF  F3 0F 59 8B 60 1A 01 00     mulss   xmm1, dword ptr [rbx+11A60h]
00007FF91DFE20B7  F3 0F 10 83 40 17 01 00     movss   xmm0, dword ptr [rbx+11740h]
00007FF91DFE20BF  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE20C3  F3 0F 59 AB A0 19 01 00     mulss   xmm5, dword ptr [rbx+119A0h]
00007FF91DFE20CB  F3 0F 11 A3 40 17 01 00     movss   dword ptr [rbx+11740h], xmm4
00007FF91DFE20D3  F3 0F 59 A3 90 1B 01 00     mulss   xmm4, dword ptr [rbx+11B90h]
00007FF91DFE20DB  F3 0F 59 83 A0 1B 01 00     mulss   xmm0, dword ptr [rbx+11BA0h]
00007FF91DFE20E3  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE20E7  F3 0F 59 A3 90 19 01 00     mulss   xmm4, dword ptr [rbx+11990h]
00007FF91DFE20EF  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFE20F3  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE20F7  73 06                       jnb     short loc_7FF91DFE20FF
00007FF91DFE20F9  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE20FD  EB 05                       jmp     short loc_7FF91DFE2104
00007FF91DFE20FF  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE2104  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFE2107  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE210A  F3 0F 59 83 40 1A 01 00     mulss   xmm0, dword ptr [rbx+11A40h]
00007FF91DFE2112  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE2116  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE211A  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE211E  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE2122  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE2126  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE212A  F3 0F 10 8B F0 16 01 00     movss   xmm1, dword ptr [rbx+116F0h]
00007FF91DFE2132  F3 0F 11 AB F0 16 01 00     movss   dword ptr [rbx+116F0h], xmm5
00007FF91DFE213A  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE213D  F3 0F 10 9B 00 17 01 00     movss   xmm3, dword ptr [rbx+11700h]
00007FF91DFE2145  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE2149  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE214C  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE2150  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE2154  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFE2158  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFE215C  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE2160  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE2164  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE2167  F3 0F 11 A3 00 17 01 00     movss   dword ptr [rbx+11700h], xmm4
00007FF91DFE216F  F3 0F 10 8B 10 17 01 00     movss   xmm1, dword ptr [rbx+11710h]
00007FF91DFE2177  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE217B  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE217F  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE2182  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE2186  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFE218A  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE218E  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFE2192  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE2196  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE219A  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE219E  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE21A2  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE21A5  F3 0F 11 9B 10 17 01 00     movss   dword ptr [rbx+11710h], xmm3
00007FF91DFE21AD  F3 0F 10 AB 20 17 01 00     movss   xmm5, dword ptr [rbx+11720h]
00007FF91DFE21B5  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE21B9  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE21BD  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE21C0  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE21C4  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE21C8  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE21CC  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFE21D0  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE21D4  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE21D8  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFE21DC  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE21E0  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE21E3  F3 0F 11 93 20 17 01 00     movss   dword ptr [rbx+11720h], xmm2
00007FF91DFE21EB  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFE21EF  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE21F3  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE21F7  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFE21FC  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE21FF  F3 0F 59 83 30 17 01 00     mulss   xmm0, dword ptr [rbx+11730h]
00007FF91DFE2207  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE220B  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE220F  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE2212  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFE2216  F3 0F 11 AB 30 17 01 00     movss   dword ptr [rbx+11730h], xmm5
00007FF91DFE221E  F3 0F 10 8B 20 17 01 00     movss   xmm1, dword ptr [rbx+11720h]
00007FF91DFE2226  F3 0F 59 8B E0 19 01 00     mulss   xmm1, dword ptr [rbx+119E0h]
00007FF91DFE222E  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE2232  F3 0F 59 AB F0 19 01 00     mulss   xmm5, dword ptr [rbx+119F0h]
00007FF91DFE223A  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE223E  F3 0F 10 83 D0 19 01 00     movss   xmm0, dword ptr [rbx+119D0h]
00007FF91DFE2246  F3 0F 59 83 10 17 01 00     mulss   xmm0, dword ptr [rbx+11710h]
00007FF91DFE224E  F3 0F 58 CD                 addss   xmm1, xmm5
00007FF91DFE2252  F3 0F 10 AB 50 19 01 00     movss   xmm5, dword ptr [rbx+11950h]
00007FF91DFE225A  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE225E  F3 0F 11 8B D0 17 01 00     movss   dword ptr [rbx+117D0h], xmm1
00007FF91DFE2266  F3 0F 59 AB 50 1A 01 00     mulss   xmm5, dword ptr [rbx+11A50h]
00007FF91DFE226E  F3 0F 10 83 40 17 01 00     movss   xmm0, dword ptr [rbx+11740h]
00007FF91DFE2276  F3 0F 59 AB A0 19 01 00     mulss   xmm5, dword ptr [rbx+119A0h]
00007FF91DFE227E  F3 0F 11 9B D0 16 01 00     movss   dword ptr [rbx+116D0h], xmm3
00007FF91DFE2286  F3 0F 59 9B 90 1B 01 00     mulss   xmm3, dword ptr [rbx+11B90h]
00007FF91DFE228E  F3 0F 59 83 A0 1B 01 00     mulss   xmm0, dword ptr [rbx+11BA0h]
00007FF91DFE2296  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE229A  F3 0F 59 9B 90 19 01 00     mulss   xmm3, dword ptr [rbx+11990h]
00007FF91DFE22A2  F3 0F 5C EB                 subss   xmm5, xmm3
00007FF91DFE22A6  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE22AA  73 06                       jnb     short loc_7FF91DFE22B2
00007FF91DFE22AC  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE22B0  EB 05                       jmp     short loc_7FF91DFE22B7
00007FF91DFE22B2  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE22B7  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFE22BA  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE22BD  F3 0F 59 83 40 1A 01 00     mulss   xmm0, dword ptr [rbx+11A40h]
00007FF91DFE22C5  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE22C9  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE22CD  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE22D1  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE22D5  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE22D9  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE22DD  F3 0F 11 AB 70 16 01 00     movss   dword ptr [rbx+11670h], xmm5
00007FF91DFE22E5  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE22E8  F3 0F 58 AB F0 16 01 00     addss   xmm5, dword ptr [rbx+116F0h]
00007FF91DFE22F0  F3 0F 10 9B 00 17 01 00     movss   xmm3, dword ptr [rbx+11700h]
00007FF91DFE22F8  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE22FB  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE22FF  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE2303  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFE2307  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFE230B  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE230F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE2313  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE2316  F3 0F 11 A3 80 16 01 00     movss   dword ptr [rbx+11680h], xmm4
00007FF91DFE231E  F3 0F 10 8B 10 17 01 00     movss   xmm1, dword ptr [rbx+11710h]
00007FF91DFE2326  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE232A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE232E  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE2331  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE2335  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFE2339  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE233D  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFE2341  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE2345  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE2349  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE234D  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE2351  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE2354  F3 0F 11 9B 90 16 01 00     movss   dword ptr [rbx+11690h], xmm3
00007FF91DFE235C  F3 0F 10 AB 20 17 01 00     movss   xmm5, dword ptr [rbx+11720h]
00007FF91DFE2364  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE2368  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE236C  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE236F  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE2373  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE2377  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE237B  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFE237F  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE2383  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE2387  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE238B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE238E  F3 0F 11 93 A0 16 01 00     movss   dword ptr [rbx+116A0h], xmm2
00007FF91DFE2396  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFE239A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE239E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE23A2  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFE23A7  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE23AA  F3 0F 59 83 30 17 01 00     mulss   xmm0, dword ptr [rbx+11730h]
00007FF91DFE23B2  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE23B6  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE23BA  F3 44 0F 59 C1              mulss   xmm8, xmm1
00007FF91DFE23BF  F3 0F 11 AB B0 16 01 00     movss   dword ptr [rbx+116B0h], xmm5
00007FF91DFE23C7  F3 0F 10 9B 90 16 01 00     movss   xmm3, dword ptr [rbx+11690h]
00007FF91DFE23CF  F3 0F 59 F5                 mulss   xmm6, xmm5
00007FF91DFE23D3  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFE23D8  F3 44 0F 11 83 C0 16 01 00  movss   dword ptr [rbx+116C0h], xmm8
00007FF91DFE23E1  F3 0F 10 83 E0 19 01 00     movss   xmm0, dword ptr [rbx+119E0h]
00007FF91DFE23E9  F3 0F 59 83 A0 16 01 00     mulss   xmm0, dword ptr [rbx+116A0h]
00007FF91DFE23F1  F3 0F 59 AB F0 19 01 00     mulss   xmm5, dword ptr [rbx+119F0h]
00007FF91DFE23F9  F3 0F 59 9B D0 19 01 00     mulss   xmm3, dword ptr [rbx+119D0h]
00007FF91DFE2401  F3 0F 10 A3 90 17 01 00     movss   xmm4, dword ptr [rbx+11790h]
00007FF91DFE2409  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE240D  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFE2411  F3 0F 11 AB 50 17 01 00     movss   dword ptr [rbx+11750h], xmm5
00007FF91DFE2419  F3 0F 58 A3 00 19 01 00     addss   xmm4, dword ptr [rbx+11900h]
00007FF91DFE2421  F3 0F 10 83 10 18 01 00     movss   xmm0, dword ptr [rbx+11810h]
00007FF91DFE2429  F3 0F 58 83 80 18 01 00     addss   xmm0, dword ptr [rbx+11880h]
00007FF91DFE2431  F3 0F 10 8B 90 18 01 00     movss   xmm1, dword ptr [rbx+11890h]
00007FF91DFE2439  F3 0F 58 8B 00 18 01 00     addss   xmm1, dword ptr [rbx+11800h]
00007FF91DFE2441  F3 0F 59 A3 80 1B 01 00     mulss   xmm4, dword ptr [rbx+11B80h]
00007FF91DFE2449  F3 0F 59 83 70 1B 01 00     mulss   xmm0, dword ptr [rbx+11B70h]
00007FF91DFE2451  F3 0F 59 8B 60 1B 01 00     mulss   xmm1, dword ptr [rbx+11B60h]
00007FF91DFE2459  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE245D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE2461  F3 0F 10 83 80 17 01 00     movss   xmm0, dword ptr [rbx+11780h]
00007FF91DFE2469  F3 0F 58 83 10 19 01 00     addss   xmm0, dword ptr [rbx+11910h]
00007FF91DFE2471  F3 0F 10 8B F0 18 01 00     movss   xmm1, dword ptr [rbx+118F0h]
00007FF91DFE2479  F3 0F 58 8B A0 17 01 00     addss   xmm1, dword ptr [rbx+117A0h]
00007FF91DFE2481  F3 0F 58 AB 40 19 01 00     addss   xmm5, dword ptr [rbx+11940h]
00007FF91DFE2489  F3 0F 59 83 50 1B 01 00     mulss   xmm0, dword ptr [rbx+11B50h]
00007FF91DFE2491  F3 0F 59 8B 40 1B 01 00     mulss   xmm1, dword ptr [rbx+11B40h]
00007FF91DFE2499  F3 0F 59 AB 90 1A 01 00     mulss   xmm5, dword ptr [rbx+11A90h]
00007FF91DFE24A1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE24A5  F3 0F 10 83 70 18 01 00     movss   xmm0, dword ptr [rbx+11870h]
00007FF91DFE24AD  F3 0F 58 83 20 18 01 00     addss   xmm0, dword ptr [rbx+11820h]
00007FF91DFE24B5  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE24B9  F3 0F 10 8B A0 18 01 00     movss   xmm1, dword ptr [rbx+118A0h]
00007FF91DFE24C1  F3 0F 58 8B F0 17 01 00     addss   xmm1, dword ptr [rbx+117F0h]
00007FF91DFE24C9  F3 0F 59 83 30 1B 01 00     mulss   xmm0, dword ptr [rbx+11B30h]
00007FF91DFE24D1  F3 0F 59 8B 20 1B 01 00     mulss   xmm1, dword ptr [rbx+11B20h]
00007FF91DFE24D9  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE24DD  F3 0F 10 83 20 19 01 00     movss   xmm0, dword ptr [rbx+11920h]
00007FF91DFE24E5  F3 0F 58 83 70 17 01 00     addss   xmm0, dword ptr [rbx+11770h]
00007FF91DFE24ED  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE24F1  F3 0F 10 8B E0 18 01 00     movss   xmm1, dword ptr [rbx+118E0h]
00007FF91DFE24F9  F3 0F 59 83 10 1B 01 00     mulss   xmm0, dword ptr [rbx+11B10h]
00007FF91DFE2501  F3 0F 58 8B B0 17 01 00     addss   xmm1, dword ptr [rbx+117B0h]
00007FF91DFE2509  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE250D  F3 0F 10 83 60 18 01 00     movss   xmm0, dword ptr [rbx+11860h]
00007FF91DFE2515  F3 0F 58 83 30 18 01 00     addss   xmm0, dword ptr [rbx+11830h]
00007FF91DFE251D  F3 0F 59 8B 00 1B 01 00     mulss   xmm1, dword ptr [rbx+11B00h]
00007FF91DFE2525  F3 0F 59 83 F0 1A 01 00     mulss   xmm0, dword ptr [rbx+11AF0h]
00007FF91DFE252D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE2531  F3 0F 10 8B B0 18 01 00     movss   xmm1, dword ptr [rbx+118B0h]
00007FF91DFE2539  F3 0F 58 8B E0 17 01 00     addss   xmm1, dword ptr [rbx+117E0h]
00007FF91DFE2541  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE2545  F3 0F 10 83 30 19 01 00     movss   xmm0, dword ptr [rbx+11930h]
00007FF91DFE254D  F3 0F 59 8B E0 1A 01 00     mulss   xmm1, dword ptr [rbx+11AE0h]
00007FF91DFE2555  F3 0F 58 83 60 17 01 00     addss   xmm0, dword ptr [rbx+11760h]
00007FF91DFE255D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE2561  F3 0F 10 8B D0 18 01 00     movss   xmm1, dword ptr [rbx+118D0h]
00007FF91DFE2569  F3 0F 58 8B C0 17 01 00     addss   xmm1, dword ptr [rbx+117C0h]
00007FF91DFE2571  F3 0F 59 83 D0 1A 01 00     mulss   xmm0, dword ptr [rbx+11AD0h]
00007FF91DFE2579  F3 0F 59 8B C0 1A 01 00     mulss   xmm1, dword ptr [rbx+11AC0h]
00007FF91DFE2581  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE2585  F3 0F 10 83 50 18 01 00     movss   xmm0, dword ptr [rbx+11850h]
00007FF91DFE258D  F3 0F 58 83 40 18 01 00     addss   xmm0, dword ptr [rbx+11840h]
00007FF91DFE2595  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE2599  F3 0F 10 8B C0 18 01 00     movss   xmm1, dword ptr [rbx+118C0h]
00007FF91DFE25A1  F3 0F 59 83 B0 1A 01 00     mulss   xmm0, dword ptr [rbx+11AB0h]
00007FF91DFE25A9  F3 0F 58 8B D0 17 01 00     addss   xmm1, dword ptr [rbx+117D0h]
00007FF91DFE25B1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE25B5  F3 0F 59 8B A0 1A 01 00     mulss   xmm1, dword ptr [rbx+11AA0h]
00007FF91DFE25BD  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE25C1  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE25C5  F3 0F 59 A3 20 1A 01 00     mulss   xmm4, dword ptr [rbx+11A20h]
00007FF91DFE25CD  F3 0F 11 A3 B0 19 01 00     movss   dword ptr [rbx+119B0h], xmm4
00007FF91DFE25D5  8B 83 B0 1B 01 00           mov     eax, [rbx+11BB0h]
00007FF91DFE25DB  89 83 C0 1B 01 00           mov     [rbx+11BC0h], eax
00007FF91DFE25E1  F3 0F 10 83 E0 1B 01 00     movss   xmm0, dword ptr [rbx+11BE0h]
00007FF91DFE25E9  8B 83 D0 1B 01 00           mov     eax, [rbx+11BD0h]
00007FF91DFE25EF  89 83 00 1C 01 00           mov     [rbx+11C00h], eax
00007FF91DFE25F5  F3 0F 11 83 10 1C 01 00     movss   dword ptr [rbx+11C10h], xmm0
00007FF91DFE25FD  8B 83 F0 1B 01 00           mov     eax, [rbx+11BF0h]
00007FF91DFE2603  89 83 20 1C 01 00           mov     [rbx+11C20h], eax
00007FF91DFE2609  F3 0F 10 93 30 1C 01 00     movss   xmm2, dword ptr [rbx+11C30h]
00007FF91DFE2611  F3 0F 11 93 40 1C 01 00     movss   dword ptr [rbx+11C40h], xmm2
00007FF91DFE2619  F3 0F 10 83 50 1C 01 00     movss   xmm0, dword ptr [rbx+11C50h]
00007FF91DFE2621  F3 0F 11 83 60 1C 01 00     movss   dword ptr [rbx+11C60h], xmm0
00007FF91DFE2629  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE262D  F3 0F 59 93 70 1C 01 00     mulss   xmm2, dword ptr [rbx+11C70h]
00007FF91DFE2635  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE2639  F3 0F 11 93 50 1C 01 00     movss   dword ptr [rbx+11C50h], xmm2
00007FF91DFE2641  F3 0F 10 83 10 1C 01 00     movss   xmm0, dword ptr [rbx+11C10h]
00007FF91DFE2649  F3 0F 10 8B 20 1C 01 00     movss   xmm1, dword ptr [rbx+11C20h]
00007FF91DFE2651  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFE2655  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE2659  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE265D  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE2661  F3 0F 11 93 80 1C 01 00     movss   dword ptr [rbx+11C80h], xmm2
00007FF91DFE2669  F3 0F 10 8B 90 1C 01 00     movss   xmm1, dword ptr [rbx+11C90h]
00007FF91DFE2671  F3 0F 11 8B A0 1C 01 00     movss   dword ptr [rbx+11CA0h], xmm1
00007FF91DFE2679  F3 0F 10 83 B0 1C 01 00     movss   xmm0, dword ptr [rbx+11CB0h]
00007FF91DFE2681  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFE2684  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE2688  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFE268C  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE2690  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE2694  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFE2698  76 05                       jbe     short loc_7FF91DFE269F
00007FF91DFE269A  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFE269D  EB 03                       jmp     short loc_7FF91DFE26A2
00007FF91DFE269F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE26A2  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE26A6  F3 0F 11 83 90 1C 01 00     movss   dword ptr [rbx+11C90h], xmm0
00007FF91DFE26AE  F3 0F 10 8B C0 1C 01 00     movss   xmm1, dword ptr [rbx+11CC0h]
00007FF91DFE26B6  F3 0F 11 8B D0 1C 01 00     movss   dword ptr [rbx+11CD0h], xmm1
00007FF91DFE26BE  F3 0F 10 93 E0 1C 01 00     movss   xmm2, dword ptr [rbx+11CE0h]
00007FF91DFE26C6  F3 0F 11 93 F0 1C 01 00     movss   dword ptr [rbx+11CF0h], xmm2
00007FF91DFE26CE  F3 0F 10 83 00 1D 01 00     movss   xmm0, dword ptr [rbx+11D00h]
00007FF91DFE26D6  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFE26D9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE26DD  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFE26E1  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE26E5  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFE26E9  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFE26ED  76 05                       jbe     short loc_7FF91DFE26F4
00007FF91DFE26EF  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFE26F2  EB 03                       jmp     short loc_7FF91DFE26F7
00007FF91DFE26F4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE26F7  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE26FB  F3 0F 11 83 E0 1C 01 00     movss   dword ptr [rbx+11CE0h], xmm0
00007FF91DFE2703  F3 0F 10 AB 10 1D 01 00     movss   xmm5, dword ptr [rbx+11D10h]
00007FF91DFE270B  F3 0F 10 B3 90 F8 00 00     movss   xmm6, dword ptr [rbx+0F890h]
00007FF91DFE2713  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFE2716  F3 0F 11 AB 20 1D 01 00     movss   dword ptr [rbx+11D20h], xmm5
00007FF91DFE271E  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE2721  F3 0F 59 A3 70 1D 01 00     mulss   xmm4, dword ptr [rbx+11D70h]
00007FF91DFE2729  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFE272C  F3 0F 58 83 40 1D 01 00     addss   xmm0, dword ptr [rbx+11D40h]
00007FF91DFE2734  F3 0F 58 9B 60 1D 01 00     addss   xmm3, dword ptr [rbx+11D60h]
00007FF91DFE273C  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFE2740  73 06                       jnb     short loc_7FF91DFE2748
00007FF91DFE2742  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFE2746  EB 05                       jmp     short loc_7FF91DFE274D
00007FF91DFE2748  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFE274D  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE2751  72 1B                       jb      short loc_7FF91DFE276E
00007FF91DFE2753  F3 0F 10 83 50 1D 01 00     movss   xmm0, dword ptr [rbx+11D50h]
00007FF91DFE275B  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFE275E  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE2762  F3 0F 59 DE                 mulss   xmm3, xmm6
00007FF91DFE2766  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE276A  F3 0F 58 DD                 addss   xmm3, xmm5
00007FF91DFE276E  41 0F 2E F6                 ucomiss xmm6, xmm14
00007FF91DFE2772  F3 0F 10 8B 90 1D 01 00     movss   xmm1, dword ptr [rbx+11D90h]
00007FF91DFE277A  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFE277D  F3 0F 59 93 80 1D 01 00     mulss   xmm2, dword ptr [rbx+11D80h]
00007FF91DFE2785  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE2788  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE278C  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE2790  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE2794  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE2797  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE279B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE279F  F3 0F 5C C2                 subss   xmm0, xmm2
00007FF91DFE27A3  F3 0F 58 C5                 addss   xmm0, xmm5
00007FF91DFE27A7  74 03                       jz      short loc_7FF91DFE27AC
00007FF91DFE27A9  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE27AC  F3 0F 11 83 30 1D 01 00     movss   dword ptr [rbx+11D30h], xmm0
00007FF91DFE27B4  F3 0F 11 83 10 1D 01 00     movss   dword ptr [rbx+11D10h], xmm0
00007FF91DFE27BC  F3 0F 10 BB B0 19 01 00     movss   xmm7, dword ptr [rbx+119B0h]
00007FF91DFE27C4  F3 0F 10 B3 20 01 01 00     movss   xmm6, dword ptr [rbx+10120h]
00007FF91DFE27CC  F3 0F 10 9B 20 11 01 00     movss   xmm3, dword ptr [rbx+11120h]
00007FF91DFE27D4  F3 0F 10 83 00 03 01 00     movss   xmm0, dword ptr [rbx+10300h]
00007FF91DFE27DC  F3 0F 10 8B B0 1B 01 00     movss   xmm1, dword ptr [rbx+11BB0h]
00007FF91DFE27E4  8B 83 D0 1D 01 00           mov     eax, [rbx+11DD0h]
00007FF91DFE27EA  89 83 E0 1D 01 00           mov     [rbx+11DE0h], eax
00007FF91DFE27F0  8B 83 F0 1D 01 00           mov     eax, [rbx+11DF0h]
00007FF91DFE27F6  89 83 00 1E 01 00           mov     [rbx+11E00h], eax
00007FF91DFE27FC  F3 0F 11 83 A0 1D 01 00     movss   dword ptr [rbx+11DA0h], xmm0
00007FF91DFE2804  F3 0F 11 8B B0 1D 01 00     movss   dword ptr [rbx+11DB0h], xmm1
00007FF91DFE280C  F3 0F 59 9B C0 1E 01 00     mulss   xmm3, dword ptr [rbx+11EC0h]
00007FF91DFE2814  F3 0F 10 A3 E0 1D 01 00     movss   xmm4, dword ptr [rbx+11DE0h]
00007FF91DFE281C  F3 0F 10 93 20 1E 01 00     movss   xmm2, dword ptr [rbx+11E20h]
00007FF91DFE2824  F3 0F 11 9B C0 1D 01 00     movss   dword ptr [rbx+11DC0h], xmm3
00007FF91DFE282C  0F 28 DF                    movaps  xmm3, xmm7
00007FF91DFE282F  F3 0F 59 B3 30 1E 01 00     mulss   xmm6, dword ptr [rbx+11E30h]
00007FF91DFE2837  F3 0F 5C DC                 subss   xmm3, xmm4
00007FF91DFE283B  F3 0F 59 93 30 1D 01 00     mulss   xmm2, dword ptr [rbx+11D30h]
00007FF91DFE2843  F3 0F 10 8B 40 1E 01 00     movss   xmm1, dword ptr [rbx+11E40h]
00007FF91DFE284B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE284E  F3 0F 59 83 60 1E 01 00     mulss   xmm0, dword ptr [rbx+11E60h]
00007FF91DFE2856  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFE285A  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE285E  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE2862  F3 0F 11 A3 D0 1D 01 00     movss   dword ptr [rbx+11DD0h], xmm4
00007FF91DFE286A  F3 0F 59 8B A0 1D 01 00     mulss   xmm1, dword ptr [rbx+11DA0h]
00007FF91DFE2872  F3 0F 10 93 50 1E 01 00     movss   xmm2, dword ptr [rbx+11E50h]
00007FF91DFE287A  F3 0F 59 9B D0 1E 01 00     mulss   xmm3, dword ptr [rbx+11ED0h]
00007FF91DFE2882  F3 0F 59 A3 E0 1E 01 00     mulss   xmm4, dword ptr [rbx+11EE0h]
00007FF91DFE288A  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFE288E  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE2891  F3 0F 59 8B B0 1D 01 00     mulss   xmm1, dword ptr [rbx+11DB0h]
00007FF91DFE2899  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE289D  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFE28A1  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFE28A5  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFE28A9  F3 0F 10 B3 70 1E 01 00     movss   xmm6, dword ptr [rbx+11E70h]
00007FF91DFE28B1  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFE28B5  F3 0F 59 8B A0 1E 01 00     mulss   xmm1, dword ptr [rbx+11EA0h]
00007FF91DFE28BD  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFE28C1  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE28C5  76 05                       jbe     short loc_7FF91DFE28CC
00007FF91DFE28C7  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFE28CA  EB 03                       jmp     short loc_7FF91DFE28CF
00007FF91DFE28CC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE28CF  F3 0F 10 93 90 1E 01 00     movss   xmm2, dword ptr [rbx+11E90h]
00007FF91DFE28D7  F3 0F 10 A3 80 1E 01 00     movss   xmm4, dword ptr [rbx+11E80h]
00007FF91DFE28DF  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFE28E3  F3 0F 10 83 C0 1D 01 00     movss   xmm0, dword ptr [rbx+11DC0h]
00007FF91DFE28EB  F3 0F 59 AB B0 1E 01 00     mulss   xmm5, dword ptr [rbx+11EB0h]
00007FF91DFE28F3  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE28F8  F3 0F 59 F3                 mulss   xmm6, xmm3
00007FF91DFE28FC  F3 0F 10 9B 00 1E 01 00     movss   xmm3, dword ptr [rbx+11E00h]
00007FF91DFE2904  F3 0F 58 F7                 addss   xmm6, xmm7
00007FF91DFE2908  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFE290C  F3 0F 10 83 F0 1E 01 00     movss   xmm0, dword ptr [rbx+11EF0h]
00007FF91DFE2914  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFE2917  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE291B  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFE291F  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE2923  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE2927  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE292B  F3 0F 11 9B F0 1D 01 00     movss   dword ptr [rbx+11DF0h], xmm3
00007FF91DFE2933  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFE2937  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFE293B  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE293F  F3 0F 59 A3 00 1F 01 00     mulss   xmm4, dword ptr [rbx+11F00h]
00007FF91DFE2947  F3 0F 11 A3 10 1E 01 00     movss   dword ptr [rbx+11E10h], xmm4
00007FF91DFE294F  8B 83 20 1F 01 00           mov     eax, [rbx+11F20h]
00007FF91DFE2955  89 83 30 1F 01 00           mov     [rbx+11F30h], eax
00007FF91DFE295B  8B 83 10 1F 01 00           mov     eax, [rbx+11F10h]
00007FF91DFE2961  89 83 20 1F 01 00           mov     [rbx+11F20h], eax
00007FF91DFE2967  F3 0F 10 83 30 1F 01 00     movss   xmm0, dword ptr [rbx+11F30h]
00007FF91DFE296F  F3 0F 10 8B 40 1F 01 00     movss   xmm1, dword ptr [rbx+11F40h]
00007FF91DFE2977  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFE297B  F3 0F 11 A3 10 1F 01 00     movss   dword ptr [rbx+11F10h], xmm4
00007FF91DFE2983  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE2987  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE298B  F3 0F 11 8B 20 1F 01 00     movss   dword ptr [rbx+11F20h], xmm1
00007FF91DFE2993  F3 0F 10 93 10 1F 01 00     movss   xmm2, dword ptr [rbx+11F10h]
00007FF91DFE299B  F3 0F 10 B3 00 1C 01 00     movss   xmm6, dword ptr [rbx+11C00h]
00007FF91DFE29A3  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE29A6  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFE29AA  8B 83 70 1F 01 00           mov     eax, [rbx+11F70h]
00007FF91DFE29B0  89 83 80 1F 01 00           mov     [rbx+11F80h], eax
00007FF91DFE29B6  8B 83 60 1F 01 00           mov     eax, [rbx+11F60h]
00007FF91DFE29BC  89 83 70 1F 01 00           mov     [rbx+11F70h], eax
00007FF91DFE29C2  8B 83 50 1F 01 00           mov     eax, [rbx+11F50h]
00007FF91DFE29C8  89 83 60 1F 01 00           mov     [rbx+11F60h], eax
00007FF91DFE29CE  F3 0F 11 93 50 1F 01 00     movss   dword ptr [rbx+11F50h], xmm2
00007FF91DFE29D6  F3 0F 59 83 A0 1F 01 00     mulss   xmm0, dword ptr [rbx+11FA0h]
00007FF91DFE29DE  F3 0F 10 A3 60 1F 01 00     movss   xmm4, dword ptr [rbx+11F60h]
00007FF91DFE29E6  F3 0F 10 8B C0 1F 01 00     movss   xmm1, dword ptr [rbx+11FC0h]
00007FF91DFE29EE  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFE29F1  F3 0F 59 8B 70 1F 01 00     mulss   xmm1, dword ptr [rbx+11F70h]
00007FF91DFE29F9  F3 0F 59 AB B0 1F 01 00     mulss   xmm5, dword ptr [rbx+11FB0h]
00007FF91DFE2A01  F3 0F 59 A3 E0 1F 01 00     mulss   xmm4, dword ptr [rbx+11FE0h]
00007FF91DFE2A09  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE2A0D  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE2A10  F3 0F 59 83 D0 1F 01 00     mulss   xmm0, dword ptr [rbx+11FD0h]
00007FF91DFE2A18  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE2A1C  F3 0F 10 8B F0 1F 01 00     movss   xmm1, dword ptr [rbx+11FF0h]
00007FF91DFE2A24  F3 0F 59 8B 80 1F 01 00     mulss   xmm1, dword ptr [rbx+11F80h]
00007FF91DFE2A2C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE2A30  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE2A34  76 05                       jbe     short loc_7FF91DFE2A3B
00007FF91DFE2A36  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFE2A39  EB 03                       jmp     short loc_7FF91DFE2A3E
00007FF91DFE2A3B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE2A3E  0F 2F 35 7B 2A 76 00        comiss  xmm6, cs:dword_7FF91E7454C0
00007FF91DFE2A45  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE2A49  F3 0F 11 AB 60 1F 01 00     movss   dword ptr [rbx+11F60h], xmm5
00007FF91DFE2A51  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFE2A54  F3 0F 11 A3 70 1F 01 00     movss   dword ptr [rbx+11F70h], xmm4
00007FF91DFE2A5C  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE2A60  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE2A64  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE2A68  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE2A6B  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFE2A6F  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFE2A73  73 09                       jnb     short loc_7FF91DFE2A7E
00007FF91DFE2A75  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFE2A79  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
00007FF91DFE2A7E  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFE2A82  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
00007FF91DFE2A87  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFE2A8A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE2A8E  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE2A92  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE2A96  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE2A9A  72 03                       jb      short loc_7FF91DFE2A9F
00007FF91DFE2A9C  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFE2A9F  F3 0F 11 93 90 1F 01 00     movss   dword ptr [rbx+11F90h], xmm2
00007FF91DFE2AA7  F3 0F 59 93 90 1C 01 00     mulss   xmm2, dword ptr [rbx+11C90h]
00007FF91DFE2AAF  F3 0F 11 93 00 20 01 00     movss   dword ptr [rbx+12000h], xmm2
00007FF91DFE2AB7  F3 0F 59 93 E0 1C 01 00     mulss   xmm2, dword ptr [rbx+11CE0h]
00007FF91DFE2ABF  F3 0F 11 93 10 20 01 00     movss   dword ptr [rbx+12010h], xmm2
00007FF91DFE2AC7  F3 0F 10 83 C0 07 01 00     movss   xmm0, dword ptr [rbx+107C0h]
00007FF91DFE2ACF  F3 0F 58 83 20 05 01 00     addss   xmm0, dword ptr [rbx+10520h]
00007FF91DFE2AD7  44 0F 5A E0                 cvtps2pd xmm12, xmm0
00007FF91DFE2ADB  F2 44 0F 5F 25 C4 81 60 00  maxsd   xmm12, cs:qword_7FF91E5EACA8
00007FF91DFE2AE4  F2 44 0F 5D 25 A3 81 60 00  minsd   xmm12, cs:qword_7FF91E5EAC90
00007FF91DFE2AED  41 0F 28 CC                 movaps  xmm1, xmm12
00007FF91DFE2AF1  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFE2AF5  F2 0F 58 05 6B 27 76 00     addsd   xmm0, cs:qword_7FF91E745268
00007FF91DFE2AFD  F2 41 0F 59 CC              mulsd   xmm1, xmm12
00007FF91DFE2B02  41 0F 28 FC                 movaps  xmm7, xmm12
00007FF91DFE2B06  F2 0F 2C C0                 cvttsd2si eax, xmm0
00007FF91DFE2B0A  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFE2B0D  48 63 C8                    movsxd  rcx, eax
00007FF91DFE2B10  F2 41 0F 59 D4              mulsd   xmm2, xmm12
00007FF91DFE2B15  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
00007FF91DFE2B1C  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE2B1F  F2 41 0F 59 DC              mulsd   xmm3, xmm12
00007FF91DFE2B24  48 8D 0D B5 69 60 00        lea     rcx, unk_7FF91E5E94E0
00007FF91DFE2B2B  48 03 C1                    add     rax, rcx
00007FF91DFE2B2E  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFE2B31  F2 41 0F 59 E4              mulsd   xmm4, xmm12
00007FF91DFE2B36  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
00007FF91DFE2B3B  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
00007FF91DFE2B40  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
00007FF91DFE2B45  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFE2B48  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
00007FF91DFE2B4C  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
00007FF91DFE2B51  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
00007FF91DFE2B56  F2 0F 58 F9                 addsd   xmm7, xmm1
00007FF91DFE2B5A  F2 41 0F 59 EC              mulsd   xmm5, xmm12
00007FF91DFE2B5F  F2 0F 58 FA                 addsd   xmm7, xmm2
00007FF91DFE2B63  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFE2B66  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
00007FF91DFE2B6B  F2 41 0F 59 F4              mulsd   xmm6, xmm12
00007FF91DFE2B70  F2 0F 58 FB                 addsd   xmm7, xmm3
00007FF91DFE2B74  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFE2B78  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
00007FF91DFE2B7D  F2 0F 58 FC                 addsd   xmm7, xmm4
00007FF91DFE2B81  F2 45 0F 59 C4              mulsd   xmm8, xmm12
00007FF91DFE2B86  F2 0F 58 FD                 addsd   xmm7, xmm5
00007FF91DFE2B8A  45 0F 28 C8                 movaps  xmm9, xmm8
00007FF91DFE2B8E  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
00007FF91DFE2B97  F2 45 0F 59 CC              mulsd   xmm9, xmm12
00007FF91DFE2B9C  F2 0F 58 FE                 addsd   xmm7, xmm6
00007FF91DFE2BA0  45 0F 28 D1                 movaps  xmm10, xmm9
00007FF91DFE2BA4  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
00007FF91DFE2BAD  F2 41 0F 58 F8              addsd   xmm7, xmm8
00007FF91DFE2BB2  F2 45 0F 59 D4              mulsd   xmm10, xmm12
00007FF91DFE2BB7  F2 41 0F 58 F9              addsd   xmm7, xmm9
00007FF91DFE2BBC  45 0F 28 DA                 movaps  xmm11, xmm10
00007FF91DFE2BC0  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
00007FF91DFE2BC9  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFE2BCE  F2 41 0F 58 FA              addsd   xmm7, xmm10
00007FF91DFE2BD3  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFE2BD7  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFE2BDC  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
00007FF91DFE2BE4  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
00007FF91DFE2BED  F2 0F 58 F8                 addsd   xmm7, xmm0
00007FF91DFE2BF1  F2 41 0F 58 FB              addsd   xmm7, xmm11
00007FF91DFE2BF6  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
00007FF91DFE2BFA  F3 0F 5D 1D 96 80 60 00     minss   xmm3, cs:dword_7FF91E5EAC98
00007FF91DFE2C02  F3 0F 5F 1D A6 80 60 00     maxss   xmm3, cs:dword_7FF91E5EACB0
00007FF91DFE2C0A  F3 0F 59 9B 30 05 01 00     mulss   xmm3, dword ptr [rbx+10530h]
00007FF91DFE2C12  F3 0F 11 9B A0 07 01 00     movss   dword ptr [rbx+107A0h], xmm3
00007FF91DFE2C1A  8B 83 40 09 01 00           mov     eax, [rbx+10940h]
00007FF91DFE2C20  F3 0F 10 AB 20 05 01 00     movss   xmm5, dword ptr [rbx+10520h]
00007FF91DFE2C28  F3 0F 10 83 F0 06 01 00     movss   xmm0, dword ptr [rbx+106F0h]
00007FF91DFE2C30  F3 0F 10 8B 00 07 01 00     movss   xmm1, dword ptr [rbx+10700h]
00007FF91DFE2C38  F3 0F 10 93 10 07 01 00     movss   xmm2, dword ptr [rbx+10710h]
00007FF91DFE2C40  89 83 50 09 01 00           mov     [rbx+10950h], eax
00007FF91DFE2C46  8B 83 60 09 01 00           mov     eax, [rbx+10960h]
00007FF91DFE2C4C  89 83 70 09 01 00           mov     [rbx+10970h], eax
00007FF91DFE2C52  8B 83 10 0A 01 00           mov     eax, [rbx+10A10h]
00007FF91DFE2C58  89 83 20 0A 01 00           mov     [rbx+10A20h], eax
00007FF91DFE2C5E  8B 83 00 0A 01 00           mov     eax, [rbx+10A00h]
00007FF91DFE2C64  89 83 10 0A 01 00           mov     [rbx+10A10h], eax
00007FF91DFE2C6A  8B 83 F0 09 01 00           mov     eax, [rbx+109F0h]
00007FF91DFE2C70  89 83 00 0A 01 00           mov     [rbx+10A00h], eax
00007FF91DFE2C76  8B 83 E0 09 01 00           mov     eax, [rbx+109E0h]
00007FF91DFE2C7C  89 83 F0 09 01 00           mov     [rbx+109F0h], eax
00007FF91DFE2C82  8B 83 D0 09 01 00           mov     eax, [rbx+109D0h]
00007FF91DFE2C88  89 83 E0 09 01 00           mov     [rbx+109E0h], eax
00007FF91DFE2C8E  8B 83 C0 09 01 00           mov     eax, [rbx+109C0h]
00007FF91DFE2C94  89 83 D0 09 01 00           mov     [rbx+109D0h], eax
00007FF91DFE2C9A  8B 83 B0 09 01 00           mov     eax, [rbx+109B0h]
00007FF91DFE2CA0  89 83 C0 09 01 00           mov     [rbx+109C0h], eax
00007FF91DFE2CA6  8B 83 90 0A 01 00           mov     eax, [rbx+10A90h]
00007FF91DFE2CAC  89 83 A0 0A 01 00           mov     [rbx+10AA0h], eax
00007FF91DFE2CB2  8B 83 80 0A 01 00           mov     eax, [rbx+10A80h]
00007FF91DFE2CB8  89 83 90 0A 01 00           mov     [rbx+10A90h], eax
00007FF91DFE2CBE  8B 83 70 0A 01 00           mov     eax, [rbx+10A70h]
00007FF91DFE2CC4  89 83 80 0A 01 00           mov     [rbx+10A80h], eax
00007FF91DFE2CCA  8B 83 60 0A 01 00           mov     eax, [rbx+10A60h]
00007FF91DFE2CD0  89 83 70 0A 01 00           mov     [rbx+10A70h], eax
00007FF91DFE2CD6  8B 83 50 0A 01 00           mov     eax, [rbx+10A50h]
00007FF91DFE2CDC  89 83 60 0A 01 00           mov     [rbx+10A60h], eax
00007FF91DFE2CE2  8B 83 40 0A 01 00           mov     eax, [rbx+10A40h]
00007FF91DFE2CE8  89 83 50 0A 01 00           mov     [rbx+10A50h], eax
00007FF91DFE2CEE  8B 83 30 0A 01 00           mov     eax, [rbx+10A30h]
00007FF91DFE2CF4  89 83 40 0A 01 00           mov     [rbx+10A40h], eax
00007FF91DFE2CFA  8B 83 10 0B 01 00           mov     eax, [rbx+10B10h]
00007FF91DFE2D00  89 83 20 0B 01 00           mov     [rbx+10B20h], eax
00007FF91DFE2D06  8B 83 00 0B 01 00           mov     eax, [rbx+10B00h]
00007FF91DFE2D0C  89 83 10 0B 01 00           mov     [rbx+10B10h], eax
00007FF91DFE2D12  8B 83 F0 0A 01 00           mov     eax, [rbx+10AF0h]
00007FF91DFE2D18  89 83 00 0B 01 00           mov     [rbx+10B00h], eax
00007FF91DFE2D1E  8B 83 E0 0A 01 00           mov     eax, [rbx+10AE0h]
00007FF91DFE2D24  89 83 F0 0A 01 00           mov     [rbx+10AF0h], eax
00007FF91DFE2D2A  8B 83 D0 0A 01 00           mov     eax, [rbx+10AD0h]
00007FF91DFE2D30  89 83 E0 0A 01 00           mov     [rbx+10AE0h], eax
00007FF91DFE2D36  8B 83 C0 0A 01 00           mov     eax, [rbx+10AC0h]
00007FF91DFE2D3C  89 83 D0 0A 01 00           mov     [rbx+10AD0h], eax
00007FF91DFE2D42  8B 83 B0 0A 01 00           mov     eax, [rbx+10AB0h]
00007FF91DFE2D48  89 83 C0 0A 01 00           mov     [rbx+10AC0h], eax
00007FF91DFE2D4E  8B 83 90 0B 01 00           mov     eax, [rbx+10B90h]
00007FF91DFE2D54  89 83 A0 0B 01 00           mov     [rbx+10BA0h], eax
00007FF91DFE2D5A  8B 83 80 0B 01 00           mov     eax, [rbx+10B80h]
00007FF91DFE2D60  89 83 90 0B 01 00           mov     [rbx+10B90h], eax
00007FF91DFE2D66  8B 83 70 0B 01 00           mov     eax, [rbx+10B70h]
00007FF91DFE2D6C  89 83 80 0B 01 00           mov     [rbx+10B80h], eax
00007FF91DFE2D72  8B 83 60 0B 01 00           mov     eax, [rbx+10B60h]
00007FF91DFE2D78  89 83 70 0B 01 00           mov     [rbx+10B70h], eax
00007FF91DFE2D7E  8B 83 50 0B 01 00           mov     eax, [rbx+10B50h]
00007FF91DFE2D84  89 83 60 0B 01 00           mov     [rbx+10B60h], eax
00007FF91DFE2D8A  8B 83 40 0B 01 00           mov     eax, [rbx+10B40h]
00007FF91DFE2D90  89 83 50 0B 01 00           mov     [rbx+10B50h], eax
00007FF91DFE2D96  8B 83 30 0B 01 00           mov     eax, [rbx+10B30h]
00007FF91DFE2D9C  89 83 40 0B 01 00           mov     [rbx+10B40h], eax
00007FF91DFE2DA2  8B 83 D0 0B 01 00           mov     eax, [rbx+10BD0h]
00007FF91DFE2DA8  89 83 E0 0B 01 00           mov     [rbx+10BE0h], eax
00007FF91DFE2DAE  8B 83 C0 0B 01 00           mov     eax, [rbx+10BC0h]
00007FF91DFE2DB4  89 83 D0 0B 01 00           mov     [rbx+10BD0h], eax
00007FF91DFE2DBA  F3 0F 11 83 E0 08 01 00     movss   dword ptr [rbx+108E0h], xmm0
00007FF91DFE2DC2  F3 0F 11 8B F0 08 01 00     movss   dword ptr [rbx+108F0h], xmm1
00007FF91DFE2DCA  F3 0F 58 AB 00 0F 01 00     addss   xmm5, dword ptr [rbx+10F00h]
00007FF91DFE2DD2  F3 0F 59 9B 00 0C 01 00     mulss   xmm3, dword ptr [rbx+10C00h]
00007FF91DFE2DDA  F3 0F 10 83 F0 0B 01 00     movss   xmm0, dword ptr [rbx+10BF0h]
00007FF91DFE2DE2  F3 0F 11 93 00 09 01 00     movss   dword ptr [rbx+10900h], xmm2
00007FF91DFE2DEA  F3 0F 10 93 20 0C 01 00     movss   xmm2, dword ptr [rbx+10C20h]
00007FF91DFE2DF2  F3 0F 59 AB 10 0F 01 00     mulss   xmm5, dword ptr [rbx+10F10h]
00007FF91DFE2DFA  F3 0F 5F D3                 maxss   xmm2, xmm3
00007FF91DFE2DFE  F3 0F 58 AB F0 0E 01 00     addss   xmm5, dword ptr [rbx+10EF0h]
00007FF91DFE2E06  F3 0F 11 93 10 09 01 00     movss   dword ptr [rbx+10910h], xmm2
00007FF91DFE2E0E  F3 0F 58 83 40 05 01 00     addss   xmm0, dword ptr [rbx+10540h]
00007FF91DFE2E16  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFE2E1A  F3 0F 11 83 30 09 01 00     movss   dword ptr [rbx+10930h], xmm0
00007FF91DFE2E22  76 05                       jbe     short loc_7FF91DFE2E29
00007FF91DFE2E24  0F 5A C5                    cvtps2pd xmm0, xmm5
00007FF91DFE2E27  EB 03                       jmp     short loc_7FF91DFE2E2C
00007FF91DFE2E29  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE2E2C  F3 0F 10 0D 28 21 76 00     movss   xmm1, cs:dword_7FF91E744F5C
00007FF91DFE2E34  F3 44 0F 10 15 AB 23 76 00  movss   xmm10, cs:flt_7FF91E7451E8
00007FF91DFE2E3D  F3 0F 5E CA                 divss   xmm1, xmm2
00007FF91DFE2E41  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE2E45  F3 0F 11 8B 20 09 01 00     movss   dword ptr [rbx+10920h], xmm1
00007FF91DFE2E4D  F3 0F 11 83 B0 0B 01 00     movss   dword ptr [rbx+10BB0h], xmm0
00007FF91DFE2E55  F3 0F 10 B3 70 09 01 00     movss   xmm6, dword ptr [rbx+10970h]
00007FF91DFE2E5D  F3 0F 10 8B 50 09 01 00     movss   xmm1, dword ptr [rbx+10950h]
00007FF91DFE2E65  F3 0F 11 B3 90 08 01 00     movss   dword ptr [rbx+10890h], xmm6
00007FF91DFE2E6D  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFE2E71  F3 0F 11 8B A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm1
00007FF91DFE2E79  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE2E7D  76 1B                       jbe     short loc_7FF91DFE2E9A
00007FF91DFE2E7F  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE2E84  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE2E88  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE2E8B  E8 48 C6 36 00              call    fmodf
00007FF91DFE2E90  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE2E93  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE2E98  EB 1F                       jmp     short loc_7FF91DFE2EB9
00007FF91DFE2E9A  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE2E9E  73 19                       jnb     short loc_7FF91DFE2EB9
00007FF91DFE2EA0  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE2EA5  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE2EA9  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE2EAC  E8 27 C6 36 00              call    fmodf
00007FF91DFE2EB1  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE2EB4  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE2EB9  F3 44 0F 10 25 4A 21 76 00  movss   xmm12, cs:dword_7FF91E74500C
00007FF91DFE2EC2  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE2EC5  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE2ECA  F3 0F 11 B3 80 08 01 00     movss   dword ptr [rbx+10880h], xmm6
00007FF91DFE2ED2  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFE2ED5  F3 0F 59 BB 70 0C 01 00     mulss   xmm7, dword ptr [rbx+10C70h]
00007FF91DFE2EDD  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFE2EE2  E8 D9 60 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE2EE7  F3 44 0F 10 1D 54 25 76 00  movss   xmm11, cs:dword_7FF91E745444
00007FF91DFE2EF0  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFE2EF3  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFE2EF8  F3 0F 59 AB 20 09 01 00     mulss   xmm5, dword ptr [rbx+10920h]
00007FF91DFE2F00  F3 0F 59 AB 40 0C 01 00     mulss   xmm5, dword ptr [rbx+10C40h]
00007FF91DFE2F08  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE2F0C  73 06                       jnb     short loc_7FF91DFE2F14
00007FF91DFE2F0E  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE2F12  EB 05                       jmp     short loc_7FF91DFE2F19
00007FF91DFE2F14  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE2F19  F3 0F 59 AB 10 0C 01 00     mulss   xmm5, dword ptr [rbx+10C10h]
00007FF91DFE2F21  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE2F24  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE2F28  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE2F2B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE2F2E  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE2F36  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE2F39  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE2F3D  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE2F40  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
00007FF91DFE2F48  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE2F50  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE2F54  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
00007FF91DFE2F5C  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE2F60  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE2F63  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE2F6B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE2F6F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE2F73  F3 0F 10 8B 30 09 01 00     movss   xmm1, dword ptr [rbx+10930h]
00007FF91DFE2F7B  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE2F7F  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE2F82  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFE2F86  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE2F8A  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE2F8E  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE2F92  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE2F96  F3 0F 11 A3 80 09 01 00     movss   dword ptr [rbx+10980h], xmm4
00007FF91DFE2F9E  72 07                       jb      short loc_7FF91DFE2FA7
00007FF91DFE2FA0  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFE2FA5  EB 05                       jmp     short loc_7FF91DFE2FAC
00007FF91DFE2FA7  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFE2FAC  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE2FAF  73 06                       jnb     short loc_7FF91DFE2FB7
00007FF91DFE2FB1  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFE2FB5  EB 06                       jmp     short loc_7FF91DFE2FBD
00007FF91DFE2FB7  76 04                       jbe     short loc_7FF91DFE2FBD
00007FF91DFE2FB9  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE2FBD  F3 44 0F 10 83 80 08 01 00  movss   xmm8, dword ptr [rbx+10880h]
00007FF91DFE2FC6  F3 0F 59 B3 80 0C 01 00     mulss   xmm6, dword ptr [rbx+10C80h]
00007FF91DFE2FCE  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFE2FD2  E8 E9 5F FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE2FD7  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFE2FDA  F3 0F 10 83 30 0C 01 00     movss   xmm0, dword ptr [rbx+10C30h]
00007FF91DFE2FE2  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFE2FE6  72 18                       jb      short loc_7FF91DFE3000
00007FF91DFE2FE8  0F 2F 83 90 08 01 00        comiss  xmm0, dword ptr [rbx+10890h]
00007FF91DFE2FEF  76 0F                       jbe     short loc_7FF91DFE3000
00007FF91DFE2FF1  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
00007FF91DFE2FF9  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFE2FFE  EB 08                       jmp     short loc_7FF91DFE3008
00007FF91DFE3000  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
00007FF91DFE3008  0F 2F 3D C1 22 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFE300F  F3 0F 59 A3 20 09 01 00     mulss   xmm4, dword ptr [rbx+10920h]
00007FF91DFE3017  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFE301C  F3 0F 59 A3 50 0C 01 00     mulss   xmm4, dword ptr [rbx+10C50h]
00007FF91DFE3024  72 03                       jb      short loc_7FF91DFE3029
00007FF91DFE3026  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFE3029  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFE302D  73 06                       jnb     short loc_7FF91DFE3035
00007FF91DFE302F  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFE3033  EB 05                       jmp     short loc_7FF91DFE303A
00007FF91DFE3035  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFE303A  F3 0F 11 BB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm7
00007FF91DFE3042  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFE3047  F3 0F 59 A3 10 0C 01 00     mulss   xmm4, dword ptr [rbx+10C10h]
00007FF91DFE304F  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFE3052  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE3057  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE305B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE305E  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFE3063  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE3067  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE306A  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE306E  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFE3072  F3 44 0F 59 8B E0 0D 01 00  mulss   xmm9, dword ptr [rbx+10DE0h]
00007FF91DFE307B  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE3080  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE3083  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE308B  F3 44 0F 58 8B D0 0D 01 00  addss   xmm9, dword ptr [rbx+10DD0h]
00007FF91DFE3094  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE309C  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE30A1  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE30A4  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE30AC  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFE30B1  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE30B5  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE30BA  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFE30BD  0F 54 05 CC 26 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFE30C4  0F 57 05 F5 26 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFE30CB  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFE30D0  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFE30D5  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFE30DA  F3 44 0F 11 8B 90 09 01 00  movss   dword ptr [rbx+10990h], xmm9
00007FF91DFE30E3  E8 D8 5E FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE30E8  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE30EC  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFE30F0  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFE30F5  73 06                       jnb     short loc_7FF91DFE30FD
00007FF91DFE30F7  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE30FB  EB 06                       jmp     short loc_7FF91DFE3103
00007FF91DFE30FD  76 04                       jbe     short loc_7FF91DFE3103
00007FF91DFE30FF  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE3103  F3 44 0F 59 83 20 09 01 00  mulss   xmm8, dword ptr [rbx+10920h]
00007FF91DFE310C  F3 0F 59 BB 90 0C 01 00     mulss   xmm7, dword ptr [rbx+10C90h]
00007FF91DFE3114  F3 44 0F 59 05 7B 7B 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFE311D  F3 44 0F 59 83 60 0C 01 00  mulss   xmm8, dword ptr [rbx+10C60h]
00007FF91DFE3126  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFE312A  73 06                       jnb     short loc_7FF91DFE3132
00007FF91DFE312C  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFE3130  EB 05                       jmp     short loc_7FF91DFE3137
00007FF91DFE3132  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFE3137  F3 44 0F 59 83 10 0C 01 00  mulss   xmm8, dword ptr [rbx+10C10h]
00007FF91DFE3140  F3 44 0F 59 8B F0 08 01 00  mulss   xmm9, dword ptr [rbx+108F0h]
00007FF91DFE3149  F3 0F 10 B3 80 08 01 00     movss   xmm6, dword ptr [rbx+10880h]
00007FF91DFE3151  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE3155  F3 0F 10 AB A0 08 01 00     movss   xmm5, dword ptr [rbx+108A0h]
00007FF91DFE315D  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFE3162  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE3165  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE3168  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE316C  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE316F  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
00007FF91DFE3177  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE317A  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE3182  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
00007FF91DFE318A  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFE318F  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE3197  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE319B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE319E  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE31A6  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE31AA  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE31AE  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE31B2  F3 0F 10 83 80 09 01 00     movss   xmm0, dword ptr [rbx+10980h]
00007FF91DFE31BA  F3 0F 59 83 E0 08 01 00     mulss   xmm0, dword ptr [rbx+108E0h]
00007FF91DFE31C2  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE31C6  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFE31CB  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFE31D0  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE31D4  F3 0F 59 A3 00 09 01 00     mulss   xmm4, dword ptr [rbx+10900h]
00007FF91DFE31DC  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE31E0  F3 0F 11 A3 B0 09 01 00     movss   dword ptr [rbx+109B0h], xmm4
00007FF91DFE31E8  F3 0F 11 B3 90 08 01 00     movss   dword ptr [rbx+10890h], xmm6
00007FF91DFE31F0  F3 0F 11 AB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm5
00007FF91DFE31F8  F3 0F 58 B3 10 09 01 00     addss   xmm6, dword ptr [rbx+10910h]
00007FF91DFE3200  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE3204  76 1B                       jbe     short loc_7FF91DFE3221
00007FF91DFE3206  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE320B  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE320F  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE3212  E8 C1 C2 36 00              call    fmodf
00007FF91DFE3217  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE321A  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE321F  EB 1F                       jmp     short loc_7FF91DFE3240
00007FF91DFE3221  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE3225  73 19                       jnb     short loc_7FF91DFE3240
00007FF91DFE3227  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE322C  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE3230  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE3233  E8 A0 C2 36 00              call    fmodf
00007FF91DFE3238  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE323B  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE3240  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE3243  F3 0F 11 B3 80 08 01 00     movss   dword ptr [rbx+10880h], xmm6
00007FF91DFE324B  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE3250  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFE3253  F3 0F 59 BB 70 0C 01 00     mulss   xmm7, dword ptr [rbx+10C70h]
00007FF91DFE325B  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFE3260  E8 5B 5D FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE3265  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFE3268  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFE326D  F3 0F 59 AB 20 09 01 00     mulss   xmm5, dword ptr [rbx+10920h]
00007FF91DFE3275  F3 0F 59 AB 40 0C 01 00     mulss   xmm5, dword ptr [rbx+10C40h]
00007FF91DFE327D  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE3281  73 06                       jnb     short loc_7FF91DFE3289
00007FF91DFE3283  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE3287  EB 05                       jmp     short loc_7FF91DFE328E
00007FF91DFE3289  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE328E  F3 0F 59 AB 10 0C 01 00     mulss   xmm5, dword ptr [rbx+10C10h]
00007FF91DFE3296  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE3299  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE329D  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE32A0  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE32A3  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE32AB  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE32AE  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE32B2  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE32B5  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
00007FF91DFE32BD  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE32C5  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE32C9  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
00007FF91DFE32D1  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE32D5  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE32D8  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE32E0  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE32E4  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE32E8  F3 0F 10 8B 30 09 01 00     movss   xmm1, dword ptr [rbx+10930h]
00007FF91DFE32F0  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE32F4  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE32F7  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFE32FB  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE32FF  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE3303  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE3307  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE330B  F3 0F 11 A3 80 09 01 00     movss   dword ptr [rbx+10980h], xmm4
00007FF91DFE3313  72 07                       jb      short loc_7FF91DFE331C
00007FF91DFE3315  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFE331A  EB 05                       jmp     short loc_7FF91DFE3321
00007FF91DFE331C  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFE3321  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE3324  73 06                       jnb     short loc_7FF91DFE332C
00007FF91DFE3326  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFE332A  EB 06                       jmp     short loc_7FF91DFE3332
00007FF91DFE332C  76 04                       jbe     short loc_7FF91DFE3332
00007FF91DFE332E  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE3332  F3 44 0F 10 83 80 08 01 00  movss   xmm8, dword ptr [rbx+10880h]
00007FF91DFE333B  F3 0F 59 B3 80 0C 01 00     mulss   xmm6, dword ptr [rbx+10C80h]
00007FF91DFE3343  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFE3347  E8 74 5C FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE334C  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFE334F  F3 0F 10 83 30 0C 01 00     movss   xmm0, dword ptr [rbx+10C30h]
00007FF91DFE3357  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFE335B  72 18                       jb      short loc_7FF91DFE3375
00007FF91DFE335D  0F 2F 83 90 08 01 00        comiss  xmm0, dword ptr [rbx+10890h]
00007FF91DFE3364  76 0F                       jbe     short loc_7FF91DFE3375
00007FF91DFE3366  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
00007FF91DFE336E  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFE3373  EB 08                       jmp     short loc_7FF91DFE337D
00007FF91DFE3375  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
00007FF91DFE337D  0F 2F 3D 4C 1F 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFE3384  F3 0F 59 A3 20 09 01 00     mulss   xmm4, dword ptr [rbx+10920h]
00007FF91DFE338C  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFE3391  F3 0F 59 A3 50 0C 01 00     mulss   xmm4, dword ptr [rbx+10C50h]
00007FF91DFE3399  72 03                       jb      short loc_7FF91DFE339E
00007FF91DFE339B  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFE339E  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFE33A2  73 06                       jnb     short loc_7FF91DFE33AA
00007FF91DFE33A4  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFE33A8  EB 05                       jmp     short loc_7FF91DFE33AF
00007FF91DFE33AA  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFE33AF  F3 0F 11 BB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm7
00007FF91DFE33B7  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFE33BC  F3 0F 59 A3 10 0C 01 00     mulss   xmm4, dword ptr [rbx+10C10h]
00007FF91DFE33C4  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFE33C7  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE33CC  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE33D0  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE33D3  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFE33D8  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE33DC  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE33DF  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE33E3  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFE33E7  F3 44 0F 59 8B E0 0D 01 00  mulss   xmm9, dword ptr [rbx+10DE0h]
00007FF91DFE33F0  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE33F5  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE33F8  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE3400  F3 44 0F 58 8B D0 0D 01 00  addss   xmm9, dword ptr [rbx+10DD0h]
00007FF91DFE3409  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE3411  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE3416  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE3419  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE3421  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFE3426  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE342A  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE342F  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFE3432  0F 54 05 57 23 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFE3439  0F 57 05 80 23 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFE3440  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFE3445  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFE344A  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFE344F  F3 44 0F 11 8B 90 09 01 00  movss   dword ptr [rbx+10990h], xmm9
00007FF91DFE3458  E8 63 5B FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE345D  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE3461  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFE3465  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFE346A  73 06                       jnb     short loc_7FF91DFE3472
00007FF91DFE346C  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE3470  EB 06                       jmp     short loc_7FF91DFE3478
00007FF91DFE3472  76 04                       jbe     short loc_7FF91DFE3478
00007FF91DFE3474  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE3478  F3 44 0F 59 83 20 09 01 00  mulss   xmm8, dword ptr [rbx+10920h]
00007FF91DFE3481  F3 0F 59 BB 90 0C 01 00     mulss   xmm7, dword ptr [rbx+10C90h]
00007FF91DFE3489  F3 44 0F 59 05 06 78 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFE3492  F3 44 0F 59 83 60 0C 01 00  mulss   xmm8, dword ptr [rbx+10C60h]
00007FF91DFE349B  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFE349F  73 06                       jnb     short loc_7FF91DFE34A7
00007FF91DFE34A1  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFE34A5  EB 05                       jmp     short loc_7FF91DFE34AC
00007FF91DFE34A7  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFE34AC  F3 44 0F 59 83 10 0C 01 00  mulss   xmm8, dword ptr [rbx+10C10h]
00007FF91DFE34B5  F3 44 0F 59 8B F0 08 01 00  mulss   xmm9, dword ptr [rbx+108F0h]
00007FF91DFE34BE  F3 0F 10 B3 80 08 01 00     movss   xmm6, dword ptr [rbx+10880h]
00007FF91DFE34C6  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE34CA  F3 0F 10 AB A0 08 01 00     movss   xmm5, dword ptr [rbx+108A0h]
00007FF91DFE34D2  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFE34D7  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE34DA  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE34DD  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE34E1  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE34E4  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
00007FF91DFE34EC  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE34EF  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE34F7  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
00007FF91DFE34FF  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFE3504  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE350C  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE3510  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE3513  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE351B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE351F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE3523  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE3527  F3 0F 10 83 80 09 01 00     movss   xmm0, dword ptr [rbx+10980h]
00007FF91DFE352F  F3 0F 59 83 E0 08 01 00     mulss   xmm0, dword ptr [rbx+108E0h]
00007FF91DFE3537  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE353B  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFE3540  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFE3545  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE3549  F3 0F 59 A3 00 09 01 00     mulss   xmm4, dword ptr [rbx+10900h]
00007FF91DFE3551  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE3555  F3 0F 11 A3 30 0A 01 00     movss   dword ptr [rbx+10A30h], xmm4
00007FF91DFE355D  F3 0F 11 B3 90 08 01 00     movss   dword ptr [rbx+10890h], xmm6
00007FF91DFE3565  F3 0F 11 AB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm5
00007FF91DFE356D  F3 0F 58 B3 10 09 01 00     addss   xmm6, dword ptr [rbx+10910h]
00007FF91DFE3575  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE3579  76 1B                       jbe     short loc_7FF91DFE3596
00007FF91DFE357B  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE3580  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE3584  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE3587  E8 4C BF 36 00              call    fmodf
00007FF91DFE358C  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE358F  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE3594  EB 1F                       jmp     short loc_7FF91DFE35B5
00007FF91DFE3596  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE359A  73 19                       jnb     short loc_7FF91DFE35B5
00007FF91DFE359C  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE35A1  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE35A5  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE35A8  E8 2B BF 36 00              call    fmodf
00007FF91DFE35AD  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE35B0  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE35B5  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE35B8  F3 0F 11 B3 80 08 01 00     movss   dword ptr [rbx+10880h], xmm6
00007FF91DFE35C0  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE35C5  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFE35C8  F3 0F 59 BB 70 0C 01 00     mulss   xmm7, dword ptr [rbx+10C70h]
00007FF91DFE35D0  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFE35D5  E8 E6 59 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE35DA  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFE35DD  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFE35E2  F3 0F 59 AB 20 09 01 00     mulss   xmm5, dword ptr [rbx+10920h]
00007FF91DFE35EA  F3 0F 59 AB 40 0C 01 00     mulss   xmm5, dword ptr [rbx+10C40h]
00007FF91DFE35F2  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE35F6  73 06                       jnb     short loc_7FF91DFE35FE
00007FF91DFE35F8  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE35FC  EB 05                       jmp     short loc_7FF91DFE3603
00007FF91DFE35FE  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE3603  F3 0F 59 AB 10 0C 01 00     mulss   xmm5, dword ptr [rbx+10C10h]
00007FF91DFE360B  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE360E  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE3612  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE3615  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE3618  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE3620  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE3623  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE3627  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE362A  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
00007FF91DFE3632  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE363A  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE363E  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
00007FF91DFE3646  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE364A  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE364D  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE3655  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE3659  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE365D  F3 0F 10 8B 30 09 01 00     movss   xmm1, dword ptr [rbx+10930h]
00007FF91DFE3665  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE3669  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE366C  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFE3670  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE3674  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE3678  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE367C  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE3680  F3 0F 11 A3 80 09 01 00     movss   dword ptr [rbx+10980h], xmm4
00007FF91DFE3688  72 07                       jb      short loc_7FF91DFE3691
00007FF91DFE368A  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFE368F  EB 05                       jmp     short loc_7FF91DFE3696
00007FF91DFE3691  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFE3696  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE3699  73 06                       jnb     short loc_7FF91DFE36A1
00007FF91DFE369B  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFE369F  EB 06                       jmp     short loc_7FF91DFE36A7
00007FF91DFE36A1  76 04                       jbe     short loc_7FF91DFE36A7
00007FF91DFE36A3  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE36A7  F3 44 0F 10 83 80 08 01 00  movss   xmm8, dword ptr [rbx+10880h]
00007FF91DFE36B0  F3 0F 59 B3 80 0C 01 00     mulss   xmm6, dword ptr [rbx+10C80h]
00007FF91DFE36B8  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFE36BC  E8 FF 58 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE36C1  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFE36C4  F3 0F 10 83 30 0C 01 00     movss   xmm0, dword ptr [rbx+10C30h]
00007FF91DFE36CC  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFE36D0  72 18                       jb      short loc_7FF91DFE36EA
00007FF91DFE36D2  0F 2F 83 90 08 01 00        comiss  xmm0, dword ptr [rbx+10890h]
00007FF91DFE36D9  76 0F                       jbe     short loc_7FF91DFE36EA
00007FF91DFE36DB  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
00007FF91DFE36E3  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFE36E8  EB 08                       jmp     short loc_7FF91DFE36F2
00007FF91DFE36EA  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
00007FF91DFE36F2  0F 2F 3D D7 1B 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFE36F9  F3 0F 59 A3 20 09 01 00     mulss   xmm4, dword ptr [rbx+10920h]
00007FF91DFE3701  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFE3706  F3 0F 59 A3 50 0C 01 00     mulss   xmm4, dword ptr [rbx+10C50h]
00007FF91DFE370E  72 03                       jb      short loc_7FF91DFE3713
00007FF91DFE3710  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFE3713  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFE3717  73 06                       jnb     short loc_7FF91DFE371F
00007FF91DFE3719  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFE371D  EB 05                       jmp     short loc_7FF91DFE3724
00007FF91DFE371F  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFE3724  F3 0F 11 BB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm7
00007FF91DFE372C  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFE3731  F3 0F 59 A3 10 0C 01 00     mulss   xmm4, dword ptr [rbx+10C10h]
00007FF91DFE3739  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFE373C  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE3741  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE3745  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE3748  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFE374D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE3751  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE3754  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE3758  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFE375C  F3 44 0F 59 8B E0 0D 01 00  mulss   xmm9, dword ptr [rbx+10DE0h]
00007FF91DFE3765  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE376A  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE376D  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE3775  F3 44 0F 58 8B D0 0D 01 00  addss   xmm9, dword ptr [rbx+10DD0h]
00007FF91DFE377E  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE3786  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE378B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE378E  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE3796  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFE379B  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE379F  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE37A4  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFE37A7  0F 54 05 E2 1F 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFE37AE  0F 57 05 0B 20 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFE37B5  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFE37BA  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFE37BF  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFE37C4  F3 44 0F 11 8B 90 09 01 00  movss   dword ptr [rbx+10990h], xmm9
00007FF91DFE37CD  E8 EE 57 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE37D2  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE37D6  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFE37DA  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFE37DF  73 06                       jnb     short loc_7FF91DFE37E7
00007FF91DFE37E1  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE37E5  EB 06                       jmp     short loc_7FF91DFE37ED
00007FF91DFE37E7  76 04                       jbe     short loc_7FF91DFE37ED
00007FF91DFE37E9  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE37ED  F3 44 0F 59 83 20 09 01 00  mulss   xmm8, dword ptr [rbx+10920h]
00007FF91DFE37F6  F3 0F 59 BB 90 0C 01 00     mulss   xmm7, dword ptr [rbx+10C90h]
00007FF91DFE37FE  F3 44 0F 59 05 91 74 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFE3807  F3 44 0F 59 83 60 0C 01 00  mulss   xmm8, dword ptr [rbx+10C60h]
00007FF91DFE3810  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFE3814  73 06                       jnb     short loc_7FF91DFE381C
00007FF91DFE3816  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFE381A  EB 05                       jmp     short loc_7FF91DFE3821
00007FF91DFE381C  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFE3821  F3 44 0F 59 83 10 0C 01 00  mulss   xmm8, dword ptr [rbx+10C10h]
00007FF91DFE382A  F3 44 0F 59 8B F0 08 01 00  mulss   xmm9, dword ptr [rbx+108F0h]
00007FF91DFE3833  F3 0F 10 B3 80 08 01 00     movss   xmm6, dword ptr [rbx+10880h]
00007FF91DFE383B  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE383F  F3 0F 10 AB A0 08 01 00     movss   xmm5, dword ptr [rbx+108A0h]
00007FF91DFE3847  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFE384C  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE384F  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE3852  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE3856  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE3859  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
00007FF91DFE3861  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE3864  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE386C  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
00007FF91DFE3874  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFE3879  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE3881  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE3885  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE3888  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE3890  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE3894  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE3898  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE389C  F3 0F 10 83 80 09 01 00     movss   xmm0, dword ptr [rbx+10980h]
00007FF91DFE38A4  F3 0F 59 83 E0 08 01 00     mulss   xmm0, dword ptr [rbx+108E0h]
00007FF91DFE38AC  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE38B0  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFE38B5  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFE38BA  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE38BE  F3 0F 59 A3 00 09 01 00     mulss   xmm4, dword ptr [rbx+10900h]
00007FF91DFE38C6  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE38CA  F3 0F 11 A3 B0 0A 01 00     movss   dword ptr [rbx+10AB0h], xmm4
00007FF91DFE38D2  F3 0F 11 B3 90 08 01 00     movss   dword ptr [rbx+10890h], xmm6
00007FF91DFE38DA  F3 0F 11 AB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm5
00007FF91DFE38E2  F3 0F 58 B3 10 09 01 00     addss   xmm6, dword ptr [rbx+10910h]
00007FF91DFE38EA  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE38EE  76 1B                       jbe     short loc_7FF91DFE390B
00007FF91DFE38F0  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE38F5  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE38F9  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE38FC  E8 D7 BB 36 00              call    fmodf
00007FF91DFE3901  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE3904  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE3909  EB 1F                       jmp     short loc_7FF91DFE392A
00007FF91DFE390B  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE390F  73 19                       jnb     short loc_7FF91DFE392A
00007FF91DFE3911  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE3916  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE391A  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE391D  E8 B6 BB 36 00              call    fmodf
00007FF91DFE3922  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE3925  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE392A  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE392D  F3 0F 11 B3 80 08 01 00     movss   dword ptr [rbx+10880h], xmm6
00007FF91DFE3935  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE393A  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFE393D  F3 0F 59 BB 70 0C 01 00     mulss   xmm7, dword ptr [rbx+10C70h]
00007FF91DFE3945  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFE394A  E8 71 56 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE394F  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFE3952  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFE3957  F3 0F 59 AB 20 09 01 00     mulss   xmm5, dword ptr [rbx+10920h]
00007FF91DFE395F  F3 0F 59 AB 40 0C 01 00     mulss   xmm5, dword ptr [rbx+10C40h]
00007FF91DFE3967  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE396B  73 06                       jnb     short loc_7FF91DFE3973
00007FF91DFE396D  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE3971  EB 05                       jmp     short loc_7FF91DFE3978
00007FF91DFE3973  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE3978  F3 0F 59 AB 10 0C 01 00     mulss   xmm5, dword ptr [rbx+10C10h]
00007FF91DFE3980  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE3983  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE3987  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE398A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE398D  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE3995  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE3998  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE399C  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE399F  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
00007FF91DFE39A7  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE39AF  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE39B3  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
00007FF91DFE39BB  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE39BF  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE39C2  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE39CA  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE39CE  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE39D2  F3 0F 10 8B 30 09 01 00     movss   xmm1, dword ptr [rbx+10930h]
00007FF91DFE39DA  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE39DE  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE39E1  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFE39E5  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE39E9  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE39ED  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE39F1  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE39F5  F3 0F 11 A3 80 09 01 00     movss   dword ptr [rbx+10980h], xmm4
00007FF91DFE39FD  72 07                       jb      short loc_7FF91DFE3A06
00007FF91DFE39FF  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFE3A04  EB 05                       jmp     short loc_7FF91DFE3A0B
00007FF91DFE3A06  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFE3A0B  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE3A0E  73 06                       jnb     short loc_7FF91DFE3A16
00007FF91DFE3A10  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFE3A14  EB 06                       jmp     short loc_7FF91DFE3A1C
00007FF91DFE3A16  76 04                       jbe     short loc_7FF91DFE3A1C
00007FF91DFE3A18  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE3A1C  F3 44 0F 10 83 80 08 01 00  movss   xmm8, dword ptr [rbx+10880h]
00007FF91DFE3A25  F3 0F 59 B3 80 0C 01 00     mulss   xmm6, dword ptr [rbx+10C80h]
00007FF91DFE3A2D  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFE3A31  E8 8A 55 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE3A36  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFE3A39  F3 0F 10 83 30 0C 01 00     movss   xmm0, dword ptr [rbx+10C30h]
00007FF91DFE3A41  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFE3A45  72 18                       jb      short loc_7FF91DFE3A5F
00007FF91DFE3A47  0F 2F 83 90 08 01 00        comiss  xmm0, dword ptr [rbx+10890h]
00007FF91DFE3A4E  76 0F                       jbe     short loc_7FF91DFE3A5F
00007FF91DFE3A50  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
00007FF91DFE3A58  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFE3A5D  EB 08                       jmp     short loc_7FF91DFE3A67
00007FF91DFE3A5F  F3 0F 10 BB A0 08 01 00     movss   xmm7, dword ptr [rbx+108A0h]
00007FF91DFE3A67  0F 2F 3D 62 18 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFE3A6E  F3 0F 59 A3 20 09 01 00     mulss   xmm4, dword ptr [rbx+10920h]
00007FF91DFE3A76  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFE3A7B  F3 0F 59 A3 50 0C 01 00     mulss   xmm4, dword ptr [rbx+10C50h]
00007FF91DFE3A83  72 03                       jb      short loc_7FF91DFE3A88
00007FF91DFE3A85  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFE3A88  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFE3A8C  73 06                       jnb     short loc_7FF91DFE3A94
00007FF91DFE3A8E  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFE3A92  EB 05                       jmp     short loc_7FF91DFE3A99
00007FF91DFE3A94  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFE3A99  F3 0F 11 BB A0 08 01 00     movss   dword ptr [rbx+108A0h], xmm7
00007FF91DFE3AA1  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFE3AA6  F3 0F 59 A3 10 0C 01 00     mulss   xmm4, dword ptr [rbx+10C10h]
00007FF91DFE3AAE  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFE3AB1  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE3AB6  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE3ABA  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE3ABD  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFE3AC2  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE3AC6  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE3AC9  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE3ACD  44 0F 28 C2                 movaps  xmm8, xmm2
00007FF91DFE3AD1  F3 44 0F 59 83 E0 0D 01 00  mulss   xmm8, dword ptr [rbx+10DE0h]
00007FF91DFE3ADA  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE3ADF  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE3AE2  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE3AEA  F3 44 0F 58 83 D0 0D 01 00  addss   xmm8, dword ptr [rbx+10DD0h]
00007FF91DFE3AF3  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE3AFB  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFE3B00  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE3B03  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE3B0B  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFE3B10  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE3B14  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFE3B19  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFE3B1C  0F 54 05 6D 1C 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFE3B23  0F 57 05 96 1C 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFE3B2A  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFE3B2F  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFE3B34  F3 44 0F 59 C6              mulss   xmm8, xmm6
00007FF91DFE3B39  F3 44 0F 11 83 90 09 01 00  movss   dword ptr [rbx+10990h], xmm8
00007FF91DFE3B42  E8 79 54 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE3B47  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE3B4B  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE3B50  73 06                       jnb     short loc_7FF91DFE3B58
00007FF91DFE3B52  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE3B56  EB 06                       jmp     short loc_7FF91DFE3B5E
00007FF91DFE3B58  76 04                       jbe     short loc_7FF91DFE3B5E
00007FF91DFE3B5A  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE3B5E  F3 0F 59 83 20 09 01 00     mulss   xmm0, dword ptr [rbx+10920h]
00007FF91DFE3B66  F3 0F 59 BB 90 0C 01 00     mulss   xmm7, dword ptr [rbx+10C90h]
00007FF91DFE3B6E  F3 0F 59 05 22 71 60 00     mulss   xmm0, cs:dword_7FF91E5EAC98
00007FF91DFE3B76  F3 0F 59 83 60 0C 01 00     mulss   xmm0, dword ptr [rbx+10C60h]
00007FF91DFE3B7E  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFE3B82  72 09                       jb      short loc_7FF91DFE3B8D
00007FF91DFE3B84  44 0F 28 F8                 movaps  xmm15, xmm0
00007FF91DFE3B88  F3 45 0F 5D FD              minss   xmm15, xmm13
00007FF91DFE3B8D  F3 44 0F 59 BB 10 0C 01 00  mulss   xmm15, dword ptr [rbx+10C10h]
00007FF91DFE3B96  F3 44 0F 59 83 F0 08 01 00  mulss   xmm8, dword ptr [rbx+108F0h]
00007FF91DFE3B9F  F3 0F 10 AB 80 08 01 00     movss   xmm5, dword ptr [rbx+10880h]
00007FF91DFE3BA7  41 0F 28 D7                 movaps  xmm2, xmm15
00007FF91DFE3BAB  F3 0F 10 B3 A0 08 01 00     movss   xmm6, dword ptr [rbx+108A0h]
00007FF91DFE3BB3  F3 41 0F 59 D7              mulss   xmm2, xmm15
00007FF91DFE3BB8  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE3BBB  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE3BBE  F3 0F 59 8B C0 0D 01 00     mulss   xmm1, dword ptr [rbx+10DC0h]
00007FF91DFE3BC6  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE3BC9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE3BCD  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE3BD0  F3 0F 58 8B B0 0D 01 00     addss   xmm1, dword ptr [rbx+10DB0h]
00007FF91DFE3BD8  F3 0F 59 A3 E0 0D 01 00     mulss   xmm4, dword ptr [rbx+10DE0h]
00007FF91DFE3BE0  F3 41 0F 59 DF              mulss   xmm3, xmm15
00007FF91DFE3BE5  F3 0F 58 A3 D0 0D 01 00     addss   xmm4, dword ptr [rbx+10DD0h]
00007FF91DFE3BED  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE3BF1  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE3BF4  F3 0F 59 9B A0 0D 01 00     mulss   xmm3, dword ptr [rbx+10DA0h]
00007FF91DFE3BFC  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE3C00  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE3C04  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE3C08  F3 0F 10 83 80 09 01 00     movss   xmm0, dword ptr [rbx+10980h]
00007FF91DFE3C10  F3 0F 59 83 E0 08 01 00     mulss   xmm0, dword ptr [rbx+108E0h]
00007FF91DFE3C18  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE3C1C  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFE3C21  F3 41 0F 58 E7              addss   xmm4, xmm15
00007FF91DFE3C26  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE3C2A  F3 0F 59 A3 00 09 01 00     mulss   xmm4, dword ptr [rbx+10900h]
00007FF91DFE3C32  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE3C36  F3 0F 11 A3 30 0B 01 00     movss   dword ptr [rbx+10B30h], xmm4
00007FF91DFE3C3E  F3 0F 10 93 A0 0B 01 00     movss   xmm2, dword ptr [rbx+10BA0h]
00007FF91DFE3C46  F3 0F 11 AB 60 09 01 00     movss   dword ptr [rbx+10960h], xmm5
00007FF91DFE3C4E  F3 0F 11 B3 40 09 01 00     movss   dword ptr [rbx+10940h], xmm6
00007FF91DFE3C56  F3 0F 10 83 B0 0A 01 00     movss   xmm0, dword ptr [rbx+10AB0h]
00007FF91DFE3C5E  F3 0F 58 83 A0 0A 01 00     addss   xmm0, dword ptr [rbx+10AA0h]
00007FF91DFE3C66  F3 0F 10 8B 30 0B 01 00     movss   xmm1, dword ptr [rbx+10B30h]
00007FF91DFE3C6E  F3 0F 58 8B 20 0A 01 00     addss   xmm1, dword ptr [rbx+10A20h]
00007FF91DFE3C76  F3 0F 10 AB 20 0B 01 00     movss   xmm5, dword ptr [rbx+10B20h]
00007FF91DFE3C7E  F3 0F 58 AB 30 0A 01 00     addss   xmm5, dword ptr [rbx+10A30h]
00007FF91DFE3C86  F3 0F 59 83 C0 0C 01 00     mulss   xmm0, dword ptr [rbx+10CC0h]
00007FF91DFE3C8E  F3 0F 59 8B D0 0C 01 00     mulss   xmm1, dword ptr [rbx+10CD0h]
00007FF91DFE3C96  F3 0F 59 AB B0 0C 01 00     mulss   xmm5, dword ptr [rbx+10CB0h]
00007FF91DFE3C9E  F3 0F 58 93 B0 09 01 00     addss   xmm2, dword ptr [rbx+109B0h]
00007FF91DFE3CA6  F3 0F 59 93 A0 0C 01 00     mulss   xmm2, dword ptr [rbx+10CA0h]
00007FF91DFE3CAE  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFE3CB2  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE3CB6  F3 0F 10 83 90 0B 01 00     movss   xmm0, dword ptr [rbx+10B90h]
00007FF91DFE3CBE  F3 0F 58 83 C0 09 01 00     addss   xmm0, dword ptr [rbx+109C0h]
00007FF91DFE3CC6  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE3CCA  F3 0F 10 8B 10 0B 01 00     movss   xmm1, dword ptr [rbx+10B10h]
00007FF91DFE3CD2  F3 0F 59 83 E0 0C 01 00     mulss   xmm0, dword ptr [rbx+10CE0h]
00007FF91DFE3CDA  F3 0F 58 8B 40 0A 01 00     addss   xmm1, dword ptr [rbx+10A40h]
00007FF91DFE3CE2  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE3CE6  F3 0F 10 83 C0 0A 01 00     movss   xmm0, dword ptr [rbx+10AC0h]
00007FF91DFE3CEE  F3 0F 58 83 90 0A 01 00     addss   xmm0, dword ptr [rbx+10A90h]
00007FF91DFE3CF6  F3 0F 59 8B F0 0C 01 00     mulss   xmm1, dword ptr [rbx+10CF0h]
00007FF91DFE3CFE  F3 0F 59 83 00 0D 01 00     mulss   xmm0, dword ptr [rbx+10D00h]
00007FF91DFE3D06  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE3D0A  F3 0F 10 8B 40 0B 01 00     movss   xmm1, dword ptr [rbx+10B40h]
00007FF91DFE3D12  F3 0F 58 8B 10 0A 01 00     addss   xmm1, dword ptr [rbx+10A10h]
00007FF91DFE3D1A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE3D1E  F3 0F 10 83 80 0B 01 00     movss   xmm0, dword ptr [rbx+10B80h]
00007FF91DFE3D26  F3 0F 59 8B 10 0D 01 00     mulss   xmm1, dword ptr [rbx+10D10h]
00007FF91DFE3D2E  F3 0F 58 83 D0 09 01 00     addss   xmm0, dword ptr [rbx+109D0h]
00007FF91DFE3D36  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE3D3A  F3 0F 10 8B 50 0A 01 00     movss   xmm1, dword ptr [rbx+10A50h]
00007FF91DFE3D42  F3 0F 58 8B 00 0B 01 00     addss   xmm1, dword ptr [rbx+10B00h]
00007FF91DFE3D4A  F3 0F 59 83 20 0D 01 00     mulss   xmm0, dword ptr [rbx+10D20h]
00007FF91DFE3D52  F3 0F 59 8B 30 0D 01 00     mulss   xmm1, dword ptr [rbx+10D30h]
00007FF91DFE3D5A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE3D5E  F3 0F 10 83 D0 0A 01 00     movss   xmm0, dword ptr [rbx+10AD0h]
00007FF91DFE3D66  F3 0F 58 83 80 0A 01 00     addss   xmm0, dword ptr [rbx+10A80h]
00007FF91DFE3D6E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE3D72  F3 0F 10 8B 00 0A 01 00     movss   xmm1, dword ptr [rbx+10A00h]
00007FF91DFE3D7A  F3 0F 59 83 40 0D 01 00     mulss   xmm0, dword ptr [rbx+10D40h]
00007FF91DFE3D82  F3 0F 58 8B 50 0B 01 00     addss   xmm1, dword ptr [rbx+10B50h]
00007FF91DFE3D8A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE3D8E  F3 0F 10 83 70 0B 01 00     movss   xmm0, dword ptr [rbx+10B70h]
00007FF91DFE3D96  F3 0F 59 8B 50 0D 01 00     mulss   xmm1, dword ptr [rbx+10D50h]
00007FF91DFE3D9E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE3DA2  F3 0F 58 83 E0 09 01 00     addss   xmm0, dword ptr [rbx+109E0h]
00007FF91DFE3DAA  F3 0F 10 93 D0 0B 01 00     movss   xmm2, dword ptr [rbx+10BD0h]
00007FF91DFE3DB2  F3 0F 10 8B F0 0A 01 00     movss   xmm1, dword ptr [rbx+10AF0h]
00007FF91DFE3DBA  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE3DBD  F3 0F 59 A3 D0 0E 01 00     mulss   xmm4, dword ptr [rbx+10ED0h]
00007FF91DFE3DC5  F3 0F 59 83 60 0D 01 00     mulss   xmm0, dword ptr [rbx+10D60h]
00007FF91DFE3DCD  F3 0F 58 A3 E0 0B 01 00     addss   xmm4, dword ptr [rbx+10BE0h]
00007FF91DFE3DD5  F3 0F 58 8B 60 0A 01 00     addss   xmm1, dword ptr [rbx+10A60h]
00007FF91DFE3DDD  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE3DE1  F3 0F 10 83 E0 0A 01 00     movss   xmm0, dword ptr [rbx+10AE0h]
00007FF91DFE3DE9  F3 0F 58 83 70 0A 01 00     addss   xmm0, dword ptr [rbx+10A70h]
00007FF91DFE3DF1  F3 0F 59 8B 70 0D 01 00     mulss   xmm1, dword ptr [rbx+10D70h]
00007FF91DFE3DF9  F3 0F 59 83 80 0D 01 00     mulss   xmm0, dword ptr [rbx+10D80h]
00007FF91DFE3E01  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE3E05  F3 0F 10 8B 60 0B 01 00     movss   xmm1, dword ptr [rbx+10B60h]
00007FF91DFE3E0D  F3 0F 58 8B F0 09 01 00     addss   xmm1, dword ptr [rbx+109F0h]
00007FF91DFE3E15  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE3E19  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE3E1C  F3 0F 59 8B 90 0D 01 00     mulss   xmm1, dword ptr [rbx+10D90h]
00007FF91DFE3E24  F3 0F 11 A3 D0 0B 01 00     movss   dword ptr [rbx+10BD0h], xmm4
00007FF91DFE3E2C  F3 0F 59 83 E0 0E 01 00     mulss   xmm0, dword ptr [rbx+10EE0h]
00007FF91DFE3E34  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE3E38  F3 0F 58 C4                 addss   xmm0, xmm4
00007FF91DFE3E3C  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFE3E3F  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE3E43  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE3E46  F3 0F 59 83 D0 0E 01 00     mulss   xmm0, dword ptr [rbx+10ED0h]
00007FF91DFE3E4E  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFE3E52  F3 0F 11 83 C0 0B 01 00     movss   dword ptr [rbx+10BC0h], xmm0
00007FF91DFE3E5A  F3 0F 10 93 20 0F 01 00     movss   xmm2, dword ptr [rbx+10F20h]
00007FF91DFE3E62  F3 0F 59 9B B0 0B 01 00     mulss   xmm3, dword ptr [rbx+10BB0h]
00007FF91DFE3E6A  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFE3E6E  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFE3E72  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE3E76  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFE3E7A  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE3E7E  F3 0F 11 A3 A0 09 01 00     movss   dword ptr [rbx+109A0h], xmm4
00007FF91DFE3E86  F3 0F 11 A3 20 04 01 00     movss   dword ptr [rbx+10420h], xmm4
00007FF91DFE3E8E  44 0F 2E AB 40 8D 01 00     ucomiss xmm13, dword ptr [rbx+18D40h]
00007FF91DFE3E96  75 28                       jnz     short loc_7FF91DFE3EC0
00007FF91DFE3E98  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
00007FF91DFE3EA1  F3 0F 11 83 A0 F7 00 00     movss   dword ptr [rbx+0F7A0h], xmm0
00007FF91DFE3EA9  C7 83 40 8D 01 00 00 00 00 00  mov     dword ptr [rbx+18D40h], 0
00007FF91DFE3EB3  0F 1F 40 00                 nop     dword ptr [rax+00h]
00007FF91DFE3EB7  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00007FF91DFE3EC0  8B 83 10 20 01 00           mov     eax, [rbx+12010h]
00007FF91DFE3EC6  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
00007FF91DFE3ECE  48 8B 0F                    mov     rcx, [rdi]
00007FF91DFE3ED1  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
00007FF91DFE3ED6  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
00007FF91DFE3EDB  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
00007FF91DFE3EE0  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
00007FF91DFE3EE5  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
00007FF91DFE3EEA  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
00007FF91DFE3EEF  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
00007FF91DFE3EF4  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
00007FF91DFE3EF9  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
00007FF91DFE3EFF  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
00007FF91DFE3F05  89 01                       mov     [rcx], eax
00007FF91DFE3F07  8B 83 10 20 01 00           mov     eax, [rbx+12010h]
00007FF91DFE3F0D  48 8B 4F 08                 mov     rcx, [rdi+8]
00007FF91DFE3F11  49 8B 5B 18                 mov     rbx, [r11+18h]
00007FF91DFE3F15  89 01                       mov     [rcx], eax
00007FF91DFE3F17  49 8B E3                    mov     rsp, r11
00007FF91DFE3F1A  5F                          pop     rdi
00007FF91DFE3F1B  C3                          retn
