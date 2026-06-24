; sub_7FF91DFDC420 @ rva 0x37C420

00007FF91DFDC420  48 8B C4                    mov     rax, rsp
00007FF91DFDC423  48 89 58 10                 mov     [rax+10h], rbx
00007FF91DFDC427  57                          push    rdi
00007FF91DFDC428  48 81 EC C0 00 00 00        sub     rsp, 0C0h
00007FF91DFDC42F  F3 0F 10 A1 90 CE 00 00     movss   xmm4, dword ptr [rcx+0CE90h]
00007FF91DFDC437  48 8B FA                    mov     rdi, rdx
00007FF91DFDC43A  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
00007FF91DFDC43E  48 8B D9                    mov     rbx, rcx
00007FF91DFDC441  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
00007FF91DFDC445  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00007FF91DFDC44A  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00007FF91DFDC44F  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00007FF91DFDC454  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00007FF91DFDC459  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00007FF91DFDC45E  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00007FF91DFDC464  F3 44 0F 10 2D 47 8C 76 00  movss   xmm13, cs:dword_7FF91E7450B4
00007FF91DFDC46D  44 0F 2E A9 20 8D 01 00     ucomiss xmm13, dword ptr [rcx+18D20h]
00007FF91DFDC475  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00007FF91DFDC47B  45 0F 57 F6                 xorps   xmm14, xmm14
00007FF91DFDC47F  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
00007FF91DFDC489  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00007FF91DFDC48F  75 16                       jnz     short loc_7FF91DFDC4A7
00007FF91DFDC491  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
00007FF91DFDC49A  0F 57 E4                    xorps   xmm4, xmm4
00007FF91DFDC49D  C7 81 90 CE 00 00 00 00 00 00  mov     dword ptr [rcx+0CE90h], 0
00007FF91DFDC4A7  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
00007FF91DFDC4AF  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
00007FF91DFDC4B7  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
00007FF91DFDC4BF  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
00007FF91DFDC4C7  F3 0F 59 05 F5 E8 60 00     mulss   xmm0, cs:dword_7FF91E5EADC4
00007FF91DFDC4CF  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
00007FF91DFDC4D7  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
00007FF91DFDC4DF  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFDC4E3  85 D2                       test    edx, edx
00007FF91DFDC4E5  75 07                       jnz     short loc_7FF91DFDC4EE
00007FF91DFDC4E7  BA 01 00 00 00              mov     edx, 1
00007FF91DFDC4EC  EB 24                       jmp     short loc_7FF91DFDC512
00007FF91DFDC4EE  8B C2                       mov     eax, edx
00007FF91DFDC4F0  25 00 00 20 00              and     eax, 200000h
00007FF91DFDC4F5  0F BA E2 17                 bt      edx, 17h
00007FF91DFDC4F9  73 08                       jnb     short loc_7FF91DFDC503
00007FF91DFDC4FB  85 C0                       test    eax, eax
00007FF91DFDC4FD  75 0C                       jnz     short loc_7FF91DFDC50B
00007FF91DFDC4FF  03 D2                       add     edx, edx
00007FF91DFDC501  EB 0F                       jmp     short loc_7FF91DFDC512
00007FF91DFDC503  85 C0                       test    eax, eax
00007FF91DFDC505  74 04                       jz      short loc_7FF91DFDC50B
00007FF91DFDC507  03 D2                       add     edx, edx
00007FF91DFDC509  EB 07                       jmp     short loc_7FF91DFDC512
00007FF91DFDC50B  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
00007FF91DFDC512  F3 0F 10 9B 20 CE 00 00     movss   xmm3, dword ptr [rbx+0CE20h]
00007FF91DFDC51A  8B C2                       mov     eax, edx
00007FF91DFDC51C  F3 0F 10 B3 00 CE 00 00     movss   xmm6, dword ptr [rbx+0CE00h]
00007FF91DFDC524  25 FF FF FF 00              and     eax, 0FFFFFFh
00007FF91DFDC529  F3 44 0F 10 83 C0 CE 00 00  movss   xmm8, dword ptr [rbx+0CEC0h]
00007FF91DFDC532  8B CA                       mov     ecx, edx
00007FF91DFDC534  F3 0F 10 BB D0 CE 00 00     movss   xmm7, dword ptr [rbx+0CED0h]
00007FF91DFDC53C  81 CA 00 00 00 FF           or      edx, 0FF000000h
00007FF91DFDC542  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFDC546  81 E1 00 00 00 01           and     ecx, 1000000h
00007FF91DFDC54C  C7 83 00 CF 00 00 00 00 00 00  mov     dword ptr [rbx+0CF00h], 0
00007FF91DFDC556  F3 0F 11 9B 30 CE 00 00     movss   dword ptr [rbx+0CE30h], xmm3
00007FF91DFDC55E  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFDC562  0F 44 D0                    cmovz   edx, eax
00007FF91DFDC565  F3 0F 11 B3 10 CE 00 00     movss   dword ptr [rbx+0CE10h], xmm6
00007FF91DFDC56D  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
00007FF91DFDC573  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
00007FF91DFDC579  8B 83 40 CF 00 00           mov     eax, [rbx+0CF40h]
00007FF91DFDC57F  66 0F 6E C2                 movd    xmm0, edx
00007FF91DFDC583  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFDC586  89 83 50 CF 00 00           mov     [rbx+0CF50h], eax
00007FF91DFDC58C  F3 0F 11 A3 B0 CE 00 00     movss   dword ptr [rbx+0CEB0h], xmm4
00007FF91DFDC594  F3 0F 59 05 D4 E6 60 00     mulss   xmm0, cs:dword_7FF91E5EAC70
00007FF91DFDC59C  F3 44 0F 11 83 E0 CE 00 00  movss   dword ptr [rbx+0CEE0h], xmm8
00007FF91DFDC5A5  F3 0F 11 BB F0 CE 00 00     movss   dword ptr [rbx+0CEF0h], xmm7
00007FF91DFDC5AD  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
00007FF91DFDC5B5  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
00007FF91DFDC5BD  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
00007FF91DFDC5C5  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFDC5C9  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
00007FF91DFDC5D1  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFDC5D5  F3 0F 10 93 60 CE 00 00     movss   xmm2, dword ptr [rbx+0CE60h]
00007FF91DFDC5DD  F3 0F 11 93 70 CE 00 00     movss   dword ptr [rbx+0CE70h], xmm2
00007FF91DFDC5E5  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDC5E9  F3 0F 10 83 40 CE 00 00     movss   xmm0, dword ptr [rbx+0CE40h]
00007FF91DFDC5F1  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFDC5F5  F3 0F 11 83 50 CE 00 00     movss   dword ptr [rbx+0CE50h], xmm0
00007FF91DFDC5FD  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFDC601  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDC604  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
00007FF91DFDC60C  F3 0F 10 8B 80 CE 00 00     movss   xmm1, dword ptr [rbx+0CE80h]
00007FF91DFDC614  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDC618  F3 0F 59 F2                 mulss   xmm6, xmm2
00007FF91DFDC61C  F3 0F 11 8B A0 CE 00 00     movss   dword ptr [rbx+0CEA0h], xmm1
00007FF91DFDC624  F3 0F 11 93 10 CF 00 00     movss   dword ptr [rbx+0CF10h], xmm2
00007FF91DFDC62C  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFDC630  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFDC633  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDC637  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDC63B  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFDC63F  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFDC643  F3 0F 11 B3 20 CF 00 00     movss   dword ptr [rbx+0CF20h], xmm6
00007FF91DFDC64B  F3 0F 11 9B 30 CF 00 00     movss   dword ptr [rbx+0CF30h], xmm3
00007FF91DFDC653  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFDC656  F3 0F 58 9B 70 CF 00 00     addss   xmm3, dword ptr [rbx+0CF70h]
00007FF91DFDC65E  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFDC662  72 05                       jb      short loc_7FF91DFDC669
00007FF91DFDC664  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDC667  EB 03                       jmp     short loc_7FF91DFDC66C
00007FF91DFDC669  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFDC66C  41 0F 2E CE                 ucomiss xmm1, xmm14
00007FF91DFDC670  F3 44 0F 10 3D 6B 8E 76 00  movss   xmm15, cs:dword_7FF91E7454E4
00007FF91DFDC679  75 06                       jnz     short loc_7FF91DFDC681
00007FF91DFDC67B  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDC67F  EB 04                       jmp     short loc_7FF91DFDC685
00007FF91DFDC681  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFDC685  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFDC689  F3 0F 11 AB 40 CF 00 00     movss   dword ptr [rbx+0CF40h], xmm5
00007FF91DFDC691  73 06                       jnb     short loc_7FF91DFDC699
00007FF91DFDC693  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDC697  EB 06                       jmp     short loc_7FF91DFDC69F
00007FF91DFDC699  76 04                       jbe     short loc_7FF91DFDC69F
00007FF91DFDC69B  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFDC69F  F3 0F 10 83 B0 CF 00 00     movss   xmm0, dword ptr [rbx+0CFB0h]
00007FF91DFDC6A7  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFDC6AC  F3 0F 10 93 50 D0 00 00     movss   xmm2, dword ptr [rbx+0D050h]
00007FF91DFDC6B4  F3 0F 10 8B C0 CF 00 00     movss   xmm1, dword ptr [rbx+0CFC0h]
00007FF91DFDC6BC  8B 83 80 CF 00 00           mov     eax, [rbx+0CF80h]
00007FF91DFDC6C2  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFDC6C5  F3 0F 10 A3 10 D0 00 00     movss   xmm4, dword ptr [rbx+0D010h]
00007FF91DFDC6CD  F3 0F 58 9B 60 D0 00 00     addss   xmm3, dword ptr [rbx+0D060h]
00007FF91DFDC6D5  F2 44 0F 10 25 C2 8A 76 00  movsd   xmm12, cs:dbl_7FF91E7451A0
00007FF91DFDC6DE  F3 0F 11 AB 60 CF 00 00     movss   dword ptr [rbx+0CF60h], xmm5
00007FF91DFDC6E6  F3 0F 11 AB 80 CF 00 00     movss   dword ptr [rbx+0CF80h], xmm5
00007FF91DFDC6EE  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFDC6F2  89 83 90 CF 00 00           mov     [rbx+0CF90h], eax
00007FF91DFDC6F8  F3 0F 11 A3 20 D0 00 00     movss   dword ptr [rbx+0D020h], xmm4
00007FF91DFDC700  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFDC704  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDC707  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDC70B  F3 0F 10 8B F0 CF 00 00     movss   xmm1, dword ptr [rbx+0CFF0h]
00007FF91DFDC713  F3 0F 58 83 70 D0 00 00     addss   xmm0, dword ptr [rbx+0D070h]
00007FF91DFDC71B  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFDC720  F3 0F 5E C8                 divss   xmm1, xmm0
00007FF91DFDC724  F3 0F 10 83 80 D0 00 00     movss   xmm0, dword ptr [rbx+0D080h]
00007FF91DFDC72C  F3 0F 59 AB A0 CF 00 00     mulss   xmm5, dword ptr [rbx+0CFA0h]
00007FF91DFDC734  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFDC738  F3 0F 10 93 E0 CF 00 00     movss   xmm2, dword ptr [rbx+0CFE0h]
00007FF91DFDC740  F3 0F 11 AB 30 D0 00 00     movss   dword ptr [rbx+0D030h], xmm5
00007FF91DFDC748  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFDC74C  F3 0F 10 8B 00 D0 00 00     movss   xmm1, dword ptr [rbx+0D000h]
00007FF91DFDC754  F3 0F 58 D6                 addss   xmm2, xmm6
00007FF91DFDC758  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFDC75C  F3 0F 11 93 E0 CF 00 00     movss   dword ptr [rbx+0CFE0h], xmm2
00007FF91DFDC764  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFDC768  F3 0F 11 93 F0 CF 00 00     movss   dword ptr [rbx+0CFF0h], xmm2
00007FF91DFDC770  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFDC774  F3 0F 5C E6                 subss   xmm4, xmm6
00007FF91DFDC778  0F 54 25 11 90 76 00        andps   xmm4, cs:xmmword_7FF91E745790
00007FF91DFDC77F  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFDC783  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDC787  0F 83 E8 00 00 00           jnb     loc_7FF91DFDC875
00007FF91DFDC78D  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFDC790  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFDC793  41 0F 2E EE                 ucomiss xmm5, xmm14
00007FF91DFDC797  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFDC79B  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFDC79E  F3 0F 11 83 00 D0 00 00     movss   dword ptr [rbx+0D000h], xmm0
00007FF91DFDC7A6  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFDC7AA  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDC7AE  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFDC7B2  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDC7B6  75 03                       jnz     short loc_7FF91DFDC7BB
00007FF91DFDC7B8  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFDC7BB  8B 83 C0 D0 00 00           mov     eax, [rbx+0D0C0h]
00007FF91DFDC7C1  48 8D 0D 38 38 C8 FF        lea     rcx, cs:7FF91DC60000h
00007FF91DFDC7C8  F3 0F 59 BB B0 D0 00 00     mulss   xmm7, dword ptr [rbx+0D0B0h]
00007FF91DFDC7D0  89 83 D0 D0 00 00           mov     [rbx+0D0D0h], eax
00007FF91DFDC7D6  F3 44 0F 59 83 A0 D0 00 00  mulss   xmm8, dword ptr [rbx+0D0A0h]
00007FF91DFDC7DF  F3 0F 10 83 E0 D1 00 00     movss   xmm0, dword ptr [rbx+0D1E0h]
00007FF91DFDC7E7  F3 0F 10 93 E0 D0 00 00     movss   xmm2, dword ptr [rbx+0D0E0h]
00007FF91DFDC7EF  F3 44 0F 10 8B 40 D1 00 00  movss   xmm9, dword ptr [rbx+0D140h]
00007FF91DFDC7F8  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFDC7FD  F3 44 0F 10 83 20 D1 00 00  movss   xmm8, dword ptr [rbx+0D120h]
00007FF91DFDC806  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFDC80A  F3 0F 11 BB C0 D0 00 00     movss   dword ptr [rbx+0D0C0h], xmm7
00007FF91DFDC812  F3 0F 10 BB 00 D1 00 00     movss   xmm7, dword ptr [rbx+0D100h]
00007FF91DFDC81A  F3 0F 11 8B 10 D0 00 00     movss   dword ptr [rbx+0D010h], xmm1
00007FF91DFDC822  F3 0F 11 8B 40 D0 00 00     movss   dword ptr [rbx+0D040h], xmm1
00007FF91DFDC82A  F3 0F 10 8B A0 D1 00 00     movss   xmm1, dword ptr [rbx+0D1A0h]
00007FF91DFDC832  F3 0F 11 BB 10 D1 00 00     movss   dword ptr [rbx+0D110h], xmm7
00007FF91DFDC83A  F3 0F 11 93 F0 D0 00 00     movss   dword ptr [rbx+0D0F0h], xmm2
00007FF91DFDC842  F3 44 0F 11 83 30 D1 00 00  movss   dword ptr [rbx+0D130h], xmm8
00007FF91DFDC84B  F3 44 0F 11 8B 50 D1 00 00  movss   dword ptr [rbx+0D150h], xmm9
00007FF91DFDC854  F3 0F 11 8B B0 D1 00 00     movss   dword ptr [rbx+0D1B0h], xmm1
00007FF91DFDC85C  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFDC85F  7D 2F                       jge     short loc_7FF91DFDC890
00007FF91DFDC861  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFDC866  F7 D0                       not     eax
00007FF91DFDC868  48 98                       cdqe
00007FF91DFDC86A  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFDC873  EB 47                       jmp     short loc_7FF91DFDC8BC
00007FF91DFDC875  F3 0F 58 8B 90 D0 00 00     addss   xmm1, dword ptr [rbx+0D090h]
00007FF91DFDC87D  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFDC881  0F 82 09 FF FF FF           jb      loc_7FF91DFDC790
00007FF91DFDC887  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFDC88B  E9 03 FF FF FF              jmp     loc_7FF91DFDC793
00007FF91DFDC890  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFDC893  7E 07                       jle     short loc_7FF91DFDC89C
00007FF91DFDC895  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFDC89A  EB 15                       jmp     short loc_7FF91DFDC8B1
00007FF91DFDC89C  85 C0                       test    eax, eax
00007FF91DFDC89E  79 0F                       jns     short loc_7FF91DFDC8AF
00007FF91DFDC8A0  F7 D0                       not     eax
00007FF91DFDC8A2  48 98                       cdqe
00007FF91DFDC8A4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFDC8AD  EB 0D                       jmp     short loc_7FF91DFDC8BC
00007FF91DFDC8AF  7E 0B                       jle     short loc_7FF91DFDC8BC
00007FF91DFDC8B1  48 98                       cdqe
00007FF91DFDC8B3  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFDC8BC  0F 57 05 FD 8E 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFDC8C3  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFDC8C7  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFDC8CA  7D 14                       jge     short loc_7FF91DFDC8E0
00007FF91DFDC8CC  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFDC8D1  F7 D0                       not     eax
00007FF91DFDC8D3  48 98                       cdqe
00007FF91DFDC8D5  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFDC8DE  EB 2C                       jmp     short loc_7FF91DFDC90C
00007FF91DFDC8E0  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFDC8E3  7E 07                       jle     short loc_7FF91DFDC8EC
00007FF91DFDC8E5  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFDC8EA  EB 15                       jmp     short loc_7FF91DFDC901
00007FF91DFDC8EC  85 C0                       test    eax, eax
00007FF91DFDC8EE  79 0F                       jns     short loc_7FF91DFDC8FF
00007FF91DFDC8F0  F7 D0                       not     eax
00007FF91DFDC8F2  48 98                       cdqe
00007FF91DFDC8F4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFDC8FD  EB 0D                       jmp     short loc_7FF91DFDC90C
00007FF91DFDC8FF  7E 0B                       jle     short loc_7FF91DFDC90C
00007FF91DFDC901  48 98                       cdqe
00007FF91DFDC903  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFDC90C  F3 0F 10 83 60 D1 00 00     movss   xmm0, dword ptr [rbx+0D160h]
00007FF91DFDC914  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFDC918  F3 0F 59 93 D0 D1 00 00     mulss   xmm2, dword ptr [rbx+0D1D0h]
00007FF91DFDC920  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFDC924  F3 0F 10 8B 90 D1 00 00     movss   xmm1, dword ptr [rbx+0D190h]
00007FF91DFDC92C  F3 0F 11 93 A0 D1 00 00     movss   dword ptr [rbx+0D1A0h], xmm2
00007FF91DFDC934  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFDC938  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDC93C  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFDC940  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFDC944  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFDC948  76 05                       jbe     short loc_7FF91DFDC94F
00007FF91DFDC94A  0F 5A C2                    cvtps2pd xmm0, xmm2
00007FF91DFDC94D  EB 03                       jmp     short loc_7FF91DFDC952
00007FF91DFDC94F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDC952  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFDC956  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFDC95A  72 06                       jb      short loc_7FF91DFDC962
00007FF91DFDC95C  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFDC960  EB 03                       jmp     short loc_7FF91DFDC965
00007FF91DFDC962  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFDC965  F3 0F 10 B3 70 D1 00 00     movss   xmm6, dword ptr [rbx+0D170h]
00007FF91DFDC96D  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFDC971  F3 0F 59 83 00 D2 00 00     mulss   xmm0, dword ptr [rbx+0D200h]; X
00007FF91DFDC979  E8 C2 2D 37 00              call    expf
00007FF91DFDC97E  F3 0F 59 83 F0 D1 00 00     mulss   xmm0, dword ptr [rbx+0D1F0h]
00007FF91DFDC986  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFDC989  8B 83 70 D3 00 00           mov     eax, [rbx+0D370h]
00007FF91DFDC98F  F3 0F 59 8B 80 D1 00 00     mulss   xmm1, dword ptr [rbx+0D180h]
00007FF91DFDC997  89 83 80 D3 00 00           mov     [rbx+0D380h], eax
00007FF91DFDC99D  F3 0F 58 83 10 D2 00 00     addss   xmm0, dword ptr [rbx+0D210h]
00007FF91DFDC9A5  8B 83 90 D3 00 00           mov     eax, [rbx+0D390h]
00007FF91DFDC9AB  F3 0F 10 9B 30 D3 00 00     movss   xmm3, dword ptr [rbx+0D330h]
00007FF91DFDC9B3  F3 0F 59 BB C0 D4 00 00     mulss   xmm7, dword ptr [rbx+0D4C0h]
00007FF91DFDC9BB  89 83 A0 D3 00 00           mov     [rbx+0D3A0h], eax
00007FF91DFDC9C1  8B 83 B0 D3 00 00           mov     eax, [rbx+0D3B0h]
00007FF91DFDC9C7  F3 0F 10 93 20 D3 00 00     movss   xmm2, dword ptr [rbx+0D320h]
00007FF91DFDC9CF  F3 0F 10 A3 50 D3 00 00     movss   xmm4, dword ptr [rbx+0D350h]
00007FF91DFDC9D7  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFDC9DB  89 83 C0 D3 00 00           mov     [rbx+0D3C0h], eax
00007FF91DFDC9E1  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
00007FF91DFDC9E7  F3 0F 11 9B 40 D3 00 00     movss   dword ptr [rbx+0D340h], xmm3
00007FF91DFDC9EF  F3 0F 5C CE                 subss   xmm1, xmm6
00007FF91DFDC9F3  F3 0F 11 93 30 D3 00 00     movss   dword ptr [rbx+0D330h], xmm2
00007FF91DFDC9FB  F3 0F 11 A3 60 D3 00 00     movss   dword ptr [rbx+0D360h], xmm4
00007FF91DFDCA03  F3 44 0F 11 83 F0 D2 00 00  movss   dword ptr [rbx+0D2F0h], xmm8
00007FF91DFDCA0C  F3 44 0F 11 8B 00 D3 00 00  movss   dword ptr [rbx+0D300h], xmm9
00007FF91DFDCA15  89 83 E0 D2 00 00           mov     [rbx+0D2E0h], eax
00007FF91DFDCA1B  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDCA1F  F3 0F 10 83 90 D4 00 00     movss   xmm0, dword ptr [rbx+0D490h]
00007FF91DFDCA27  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFDCA2B  F3 0F 11 83 80 D4 00 00     movss   dword ptr [rbx+0D480h], xmm0
00007FF91DFDCA33  F3 0F 11 8B C0 D1 00 00     movss   dword ptr [rbx+0D1C0h], xmm1
00007FF91DFDCA3B  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFDCA3F  73 06                       jnb     short loc_7FF91DFDCA47
00007FF91DFDCA41  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFDCA45  EB 05                       jmp     short loc_7FF91DFDCA4C
00007FF91DFDCA47  F3 41 0F 5D FD              minss   xmm7, xmm13
00007FF91DFDCA4C  F3 0F 59 0D 6C E3 60 00     mulss   xmm1, cs:dword_7FF91E5EADC0
00007FF91DFDCA54  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFDCA58  F3 0F 10 B3 A0 D5 00 00     movss   xmm6, dword ptr [rbx+0D5A0h]
00007FF91DFDCA60  F3 0F 5C C3                 subss   xmm0, xmm3
00007FF91DFDCA64  F3 0F 11 BB 20 D3 00 00     movss   dword ptr [rbx+0D320h], xmm7
00007FF91DFDCA6C  F3 0F 5D F1                 minss   xmm6, xmm1
00007FF91DFDCA70  F3 0F 59 83 D0 D4 00 00     mulss   xmm0, dword ptr [rbx+0D4D0h]
00007FF91DFDCA78  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFDCA7C  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFDCA80  73 06                       jnb     short loc_7FF91DFDCA88
00007FF91DFDCA82  41 0F 28 C7                 movaps  xmm0, xmm15
00007FF91DFDCA86  EB 05                       jmp     short loc_7FF91DFDCA8D
00007FF91DFDCA88  F3 41 0F 5D C5              minss   xmm0, xmm13
00007FF91DFDCA8D  F3 0F 59 B3 B0 D5 00 00     mulss   xmm6, dword ptr [rbx+0D5B0h]
00007FF91DFDCA95  F3 0F 5C D7                 subss   xmm2, xmm7
00007FF91DFDCA99  F3 0F 11 B3 D0 D3 00 00     movss   dword ptr [rbx+0D3D0h], xmm6
00007FF91DFDCAA1  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFDCAA5  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFDCAA9  73 03                       jnb     short loc_7FF91DFDCAAE
00007FF91DFDCAAB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDCAAE  F3 0F 10 8B A0 D4 00 00     movss   xmm1, dword ptr [rbx+0D4A0h]
00007FF91DFDCAB6  F3 44 0F 10 9B E0 D2 00 00  movss   xmm11, dword ptr [rbx+0D2E0h]
00007FF91DFDCABF  F3 0F 11 83 30 D3 00 00     movss   dword ptr [rbx+0D330h], xmm0
00007FF91DFDCAC7  F3 0F 58 83 30 D6 00 00     addss   xmm0, dword ptr [rbx+0D630h]
00007FF91DFDCACF  72 04                       jb      short loc_7FF91DFDCAD5
00007FF91DFDCAD1  41 0F 28 CD                 movaps  xmm1, xmm13
00007FF91DFDCAD5  F3 0F 59 83 20 D6 00 00     mulss   xmm0, dword ptr [rbx+0D620h]
00007FF91DFDCADD  41 0F 28 FB                 movaps  xmm7, xmm11
00007FF91DFDCAE1  F3 0F 10 93 80 D3 00 00     movss   xmm2, dword ptr [rbx+0D380h]
00007FF91DFDCAE9  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFDCAED  F3 0F 5C FA                 subss   xmm7, xmm2
00007FF91DFDCAF1  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDCAF5  F3 0F 59 B3 B0 D4 00 00     mulss   xmm6, dword ptr [rbx+0D4B0h]
00007FF91DFDCAFD  76 05                       jbe     short loc_7FF91DFDCB04
00007FF91DFDCAFF  0F 5A C8                    cvtps2pd xmm1, xmm0
00007FF91DFDCB02  EB 03                       jmp     short loc_7FF91DFDCB07
00007FF91DFDCB04  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFDCB07  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFDCB0B  F3 0F 59 BB F0 D6 00 00     mulss   xmm7, dword ptr [rbx+0D6F0h]
00007FF91DFDCB13  F3 44 0F 10 0D CC 86 76 00  movss   xmm9, cs:flt_7FF91E7451E8
00007FF91DFDCB1C  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
00007FF91DFDCB20  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFDCB24  F3 0F 11 BB 70 D3 00 00     movss   dword ptr [rbx+0D370h], xmm7
00007FF91DFDCB2C  F3 0F 11 83 10 D3 00 00     movss   dword ptr [rbx+0D310h], xmm0
00007FF91DFDCB34  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFDCB38  F3 0F 59 BB E0 D6 00 00     mulss   xmm7, dword ptr [rbx+0D6E0h]
00007FF91DFDCB40  F3 0F 10 8B 60 D5 00 00     movss   xmm1, dword ptr [rbx+0D560h]
00007FF91DFDCB48  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDCB4C  F3 0F 59 F9                 mulss   xmm7, xmm1
00007FF91DFDCB50  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFDCB54  F3 0F 10 83 60 D3 00 00     movss   xmm0, dword ptr [rbx+0D360h]
00007FF91DFDCB5C  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
00007FF91DFDCB65  F3 41 0F 58 FB              addss   xmm7, xmm11
00007FF91DFDCB6A  76 1B                       jbe     short loc_7FF91DFDCB87
00007FF91DFDCB6C  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDCB71  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFDCB75  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDCB78  E8 5B 29 37 00              call    fmodf
00007FF91DFDCB7D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDCB80  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDCB85  EB 1F                       jmp     short loc_7FF91DFDCBA6
00007FF91DFDCB87  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFDCB8B  73 19                       jnb     short loc_7FF91DFDCBA6
00007FF91DFDCB8D  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDCB92  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFDCB96  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDCB99  E8 3A 29 37 00              call    fmodf
00007FF91DFDCB9E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDCBA1  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDCBA6  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
00007FF91DFDCBAF  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDCBB2  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFDCBB6  F3 44 0F 10 83 A0 D3 00 00  movss   xmm8, dword ptr [rbx+0D3A0h]
00007FF91DFDCBBF  F3 0F 11 B3 50 D3 00 00     movss   dword ptr [rbx+0D350h], xmm6
00007FF91DFDCBC7  F3 0F 59 BB D0 D6 00 00     mulss   xmm7, dword ptr [rbx+0D6D0h]
00007FF91DFDCBCF  F3 0F 58 83 40 D6 00 00     addss   xmm0, dword ptr [rbx+0D640h]
00007FF91DFDCBD7  F3 0F 11 BB D0 D2 00 00     movss   dword ptr [rbx+0D2D0h], xmm7
00007FF91DFDCBDF  73 0A                       jnb     short loc_7FF91DFDCBEB
00007FF91DFDCBE1  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFDCBE5  76 04                       jbe     short loc_7FF91DFDCBEB
00007FF91DFDCBE7  45 0F 28 C3                 movaps  xmm8, xmm11
00007FF91DFDCBEB  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFDCBEF  76 15                       jbe     short loc_7FF91DFDCC06
00007FF91DFDCBF1  F3 41 0F 58 C5              addss   xmm0, xmm13; X
00007FF91DFDCBF6  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFDCBFA  E8 D9 28 37 00              call    fmodf
00007FF91DFDCBFF  F3 41 0F 5C C5              subss   xmm0, xmm13
00007FF91DFDCC04  EB 19                       jmp     short loc_7FF91DFDCC1F
00007FF91DFDCC06  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFDCC0A  73 13                       jnb     short loc_7FF91DFDCC1F
00007FF91DFDCC0C  F3 41 0F 5C C5              subss   xmm0, xmm13; X
00007FF91DFDCC11  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFDCC15  E8 BE 28 37 00              call    fmodf
00007FF91DFDCC1A  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDCC1F  F3 44 0F 10 1D 98 8B 76 00  movss   xmm11, dword ptr cs:xmmword_7FF91E7457C0
00007FF91DFDCC28  F3 44 0F 11 83 90 D3 00 00  movss   dword ptr [rbx+0D390h], xmm8
00007FF91DFDCC31  F3 0F 59 83 80 D6 00 00     mulss   xmm0, dword ptr [rbx+0D680h]
00007FF91DFDCC39  F3 44 0F 59 83 C0 D6 00 00  mulss   xmm8, dword ptr [rbx+0D6C0h]
00007FF91DFDCC42  F3 0F 58 83 00 D7 00 00     addss   xmm0, dword ptr [rbx+0D700h]
00007FF91DFDCC4A  F3 0F 11 83 E0 D3 00 00     movss   dword ptr [rbx+0D3E0h], xmm0
00007FF91DFDCC52  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFDCC56  F3 44 0F 11 83 30 D4 00 00  movss   dword ptr [rbx+0D430h], xmm8
00007FF91DFDCC5F  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFDCC63  F3 44 0F 58 83 60 D6 00 00  addss   xmm8, dword ptr [rbx+0D660h]
00007FF91DFDCC6C  F3 0F 11 83 F0 D3 00 00     movss   dword ptr [rbx+0D3F0h], xmm0
00007FF91DFDCC74  45 0F 2F C5                 comiss  xmm8, xmm13
00007FF91DFDCC78  76 1D                       jbe     short loc_7FF91DFDCC97
00007FF91DFDCC7A  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFDCC7F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFDCC83  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFDCC87  E8 4C 28 37 00              call    fmodf
00007FF91DFDCC8C  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFDCC90  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFDCC95  EB 21                       jmp     short loc_7FF91DFDCCB8
00007FF91DFDCC97  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFDCC9B  73 1B                       jnb     short loc_7FF91DFDCCB8
00007FF91DFDCC9D  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFDCCA2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFDCCA6  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFDCCAA  E8 29 28 37 00              call    fmodf
00007FF91DFDCCAF  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFDCCB3  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFDCCB8  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFDCCBB  F3 0F 58 BB 50 D6 00 00     addss   xmm7, dword ptr [rbx+0D650h]
00007FF91DFDCCC3  41 0F 2F FD                 comiss  xmm7, xmm13
00007FF91DFDCCC7  76 1B                       jbe     short loc_7FF91DFDCCE4
00007FF91DFDCCC9  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDCCCE  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFDCCD2  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFDCCD5  E8 FE 27 37 00              call    fmodf
00007FF91DFDCCDA  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFDCCDD  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFDCCE2  EB 1F                       jmp     short loc_7FF91DFDCD03
00007FF91DFDCCE4  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFDCCE8  73 19                       jnb     short loc_7FF91DFDCD03
00007FF91DFDCCEA  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFDCCEF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFDCCF3  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFDCCF6  E8 DD 27 37 00              call    fmodf
00007FF91DFDCCFB  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFDCCFE  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDCD03  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFDCD07  E8 B4 C2 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDCD0C  F3 0F 58 BB 10 D7 00 00     addss   xmm7, dword ptr [rbx+0D710h]
00007FF91DFDCD14  F3 0F 59 83 A0 D6 00 00     mulss   xmm0, dword ptr [rbx+0D6A0h]
00007FF91DFDCD1C  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFDCD20  73 06                       jnb     short loc_7FF91DFDCD28
00007FF91DFDCD22  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFDCD26  EB 06                       jmp     short loc_7FF91DFDCD2E
00007FF91DFDCD28  76 04                       jbe     short loc_7FF91DFDCD2E
00007FF91DFDCD2A  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFDCD2E  F3 0F 58 B3 70 D6 00 00     addss   xmm6, dword ptr [rbx+0D670h]
00007FF91DFDCD36  F3 0F 11 83 10 D4 00 00     movss   dword ptr [rbx+0D410h], xmm0
00007FF91DFDCD3E  F3 0F 11 BB 70 D4 00 00     movss   dword ptr [rbx+0D470h], xmm7
00007FF91DFDCD46  F3 0F 59 BB 90 D6 00 00     mulss   xmm7, dword ptr [rbx+0D690h]
00007FF91DFDCD4E  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFDCD52  F3 0F 58 BB 20 D7 00 00     addss   xmm7, dword ptr [rbx+0D720h]
00007FF91DFDCD5A  76 1B                       jbe     short loc_7FF91DFDCD77
00007FF91DFDCD5C  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDCD61  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFDCD65  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDCD68  E8 6B 27 37 00              call    fmodf
00007FF91DFDCD6D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDCD70  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDCD75  EB 1F                       jmp     short loc_7FF91DFDCD96
00007FF91DFDCD77  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFDCD7B  73 19                       jnb     short loc_7FF91DFDCD96
00007FF91DFDCD7D  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDCD82  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFDCD86  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDCD89  E8 4A 27 37 00              call    fmodf
00007FF91DFDCD8E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDCD91  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDCD96  0F 54 35 F3 89 76 00        andps   xmm6, cs:xmmword_7FF91E745790
00007FF91DFDCD9D  F3 0F 11 BB 00 D4 00 00     movss   dword ptr [rbx+0D400h], xmm7
00007FF91DFDCDA5  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFDCDA8  F3 0F 10 9B 40 D5 00 00     movss   xmm3, dword ptr [rbx+0D540h]
00007FF91DFDCDB0  0F 28 D6                    movaps  xmm2, xmm6
00007FF91DFDCDB3  F3 0F 59 93 D0 D5 00 00     mulss   xmm2, dword ptr [rbx+0D5D0h]
00007FF91DFDCDBB  F3 0F 59 9B 30 D4 00 00     mulss   xmm3, dword ptr [rbx+0D430h]
00007FF91DFDCDC3  F3 0F 58 93 C0 D5 00 00     addss   xmm2, dword ptr [rbx+0D5C0h]
00007FF91DFDCDCB  F3 0F 10 8B 30 D5 00 00     movss   xmm1, dword ptr [rbx+0D530h]
00007FF91DFDCDD3  F3 0F 59 8B F0 D3 00 00     mulss   xmm1, dword ptr [rbx+0D3F0h]
00007FF91DFDCDDB  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFDCDDF  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFDCDE2  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFDCDE6  F3 0F 59 83 E0 D5 00 00     mulss   xmm0, dword ptr [rbx+0D5E0h]
00007FF91DFDCDEE  F3 0F 59 F4                 mulss   xmm6, xmm4
00007FF91DFDCDF2  F3 0F 59 A3 F0 D5 00 00     mulss   xmm4, dword ptr [rbx+0D5F0h]
00007FF91DFDCDFA  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDCDFE  F3 0F 59 B3 00 D6 00 00     mulss   xmm6, dword ptr [rbx+0D600h]
00007FF91DFDCE06  F3 0F 10 83 20 D5 00 00     movss   xmm0, dword ptr [rbx+0D520h]
00007FF91DFDCE0E  F3 0F 59 83 E0 D3 00 00     mulss   xmm0, dword ptr [rbx+0D3E0h]
00007FF91DFDCE16  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFDCE1A  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDCE1E  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFDCE22  F3 0F 10 A3 00 D5 00 00     movss   xmm4, dword ptr [rbx+0D500h]
00007FF91DFDCE2A  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDCE2E  F3 0F 58 B3 10 D6 00 00     addss   xmm6, dword ptr [rbx+0D610h]
00007FF91DFDCE36  F3 0F 59 B3 B0 D6 00 00     mulss   xmm6, dword ptr [rbx+0D6B0h]
00007FF91DFDCE3E  F3 0F 11 B3 20 D4 00 00     movss   dword ptr [rbx+0D420h], xmm6
00007FF91DFDCE46  F3 0F 59 A3 10 D4 00 00     mulss   xmm4, dword ptr [rbx+0D410h]
00007FF91DFDCE4E  F3 0F 10 8B E0 D4 00 00     movss   xmm1, dword ptr [rbx+0D4E0h]
00007FF91DFDCE56  F3 0F 10 83 10 D5 00 00     movss   xmm0, dword ptr [rbx+0D510h]
00007FF91DFDCE5E  F3 0F 59 83 00 D4 00 00     mulss   xmm0, dword ptr [rbx+0D400h]
00007FF91DFDCE66  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDCE6A  F3 0F 10 93 70 D5 00 00     movss   xmm2, dword ptr [rbx+0D570h]
00007FF91DFDCE72  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFDCE75  F3 0F 59 9B 10 D3 00 00     mulss   xmm3, dword ptr [rbx+0D310h]
00007FF91DFDCE7D  F3 0F 59 B3 F0 D4 00 00     mulss   xmm6, dword ptr [rbx+0D4F0h]
00007FF91DFDCE85  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDCE89  F3 0F 10 83 50 D5 00 00     movss   xmm0, dword ptr [rbx+0D550h]
00007FF91DFDCE91  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFDCE95  F3 0F 59 83 D0 D2 00 00     mulss   xmm0, dword ptr [rbx+0D2D0h]
00007FF91DFDCE9D  F3 0F 58 E6                 addss   xmm4, xmm6
00007FF91DFDCEA1  F3 41 0F 58 DD              addss   xmm3, xmm13
00007FF91DFDCEA6  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDCEAA  F3 0F 11 9B 40 D4 00 00     movss   dword ptr [rbx+0D440h], xmm3
00007FF91DFDCEB2  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFDCEB6  F3 0F 11 A3 60 D4 00 00     movss   dword ptr [rbx+0D460h], xmm4
00007FF91DFDCEBE  F3 0F 10 8B 90 D5 00 00     movss   xmm1, dword ptr [rbx+0D590h]
00007FF91DFDCEC6  F3 0F 59 8B 00 D3 00 00     mulss   xmm1, dword ptr [rbx+0D300h]
00007FF91DFDCECE  F3 0F 10 83 80 D5 00 00     movss   xmm0, dword ptr [rbx+0D580h]
00007FF91DFDCED6  F3 0F 59 83 F0 D2 00 00     mulss   xmm0, dword ptr [rbx+0D2F0h]
00007FF91DFDCEDE  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDCEE2  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDCEE6  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDCEEA  F3 0F 11 8B 50 D4 00 00     movss   dword ptr [rbx+0D450h], xmm1
00007FF91DFDCEF2  F3 0F 10 83 60 D4 00 00     movss   xmm0, dword ptr [rbx+0D460h]
00007FF91DFDCEFA  8B 83 70 D4 00 00           mov     eax, [rbx+0D470h]
00007FF91DFDCF00  89 83 30 D7 00 00           mov     [rbx+0D730h], eax
00007FF91DFDCF06  F3 0F 11 83 40 D7 00 00     movss   dword ptr [rbx+0D740h], xmm0
00007FF91DFDCF0E  44 0F 2F B3 70 D4 00 00     comiss  xmm14, dword ptr [rbx+0D470h]
00007FF91DFDCF16  F3 0F 10 8B 80 CF 00 00     movss   xmm1, dword ptr [rbx+0CF80h]
00007FF91DFDCF1E  F3 0F 10 93 50 D7 00 00     movss   xmm2, dword ptr [rbx+0D750h]
00007FF91DFDCF26  73 06                       jnb     short loc_7FF91DFDCF2E
00007FF91DFDCF28  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFDCF2C  EB 03                       jmp     short loc_7FF91DFDCF31
00007FF91DFDCF2E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDCF31  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFDCF35  75 04                       jnz     short loc_7FF91DFDCF3B
00007FF91DFDCF37  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFDCF3B  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFDCF3F  F3 0F 11 8B 60 D7 00 00     movss   dword ptr [rbx+0D760h], xmm1
00007FF91DFDCF47  8B 83 70 D7 00 00           mov     eax, [rbx+0D770h]
00007FF91DFDCF4D  89 83 80 D7 00 00           mov     [rbx+0D780h], eax
00007FF91DFDCF53  8B 83 A0 D7 00 00           mov     eax, [rbx+0D7A0h]
00007FF91DFDCF59  89 83 B0 D7 00 00           mov     [rbx+0D7B0h], eax
00007FF91DFDCF5F  8B 83 90 D7 00 00           mov     eax, [rbx+0D790h]
00007FF91DFDCF65  89 83 A0 D7 00 00           mov     [rbx+0D7A0h], eax
00007FF91DFDCF6B  8B 83 C0 D7 00 00           mov     eax, [rbx+0D7C0h]
00007FF91DFDCF71  89 83 D0 D7 00 00           mov     [rbx+0D7D0h], eax
00007FF91DFDCF77  8B 83 F0 D7 00 00           mov     eax, [rbx+0D7F0h]
00007FF91DFDCF7D  89 83 00 D8 00 00           mov     [rbx+0D800h], eax
00007FF91DFDCF83  F3 0F 10 83 A0 D8 00 00     movss   xmm0, dword ptr [rbx+0D8A0h]
00007FF91DFDCF8B  F3 0F 58 8B 80 D8 00 00     addss   xmm1, dword ptr [rbx+0D880h]
00007FF91DFDCF93  F3 0F 59 83 B0 D7 00 00     mulss   xmm0, dword ptr [rbx+0D7B0h]
00007FF91DFDCF9B  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFDCF9F  F3 0F 58 83 80 D7 00 00     addss   xmm0, dword ptr [rbx+0D780h]
00007FF91DFDCFA7  73 06                       jnb     short loc_7FF91DFDCFAF
00007FF91DFDCFA9  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFDCFAD  EB 04                       jmp     short loc_7FF91DFDCFB3
00007FF91DFDCFAF  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFDCFB3  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFDCFB7  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFDCFBC  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFDCFBF  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFDCFC3  F3 0F 11 BB 90 D7 00 00     movss   dword ptr [rbx+0D790h], xmm7
00007FF91DFDCFCB  0F 28 E7                    movaps  xmm4, xmm7
00007FF91DFDCFCE  F3 0F 10 9B 70 D8 00 00     movss   xmm3, dword ptr [rbx+0D870h]
00007FF91DFDCFD6  F3 0F 10 93 C0 D8 00 00     movss   xmm2, dword ptr [rbx+0D8C0h]
00007FF91DFDCFDE  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFDCFE1  F3 0F 59 8B E0 D8 00 00     mulss   xmm1, dword ptr [rbx+0D8E0h]
00007FF91DFDCFE9  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDCFEC  F3 0F 58 A3 90 D8 00 00     addss   xmm4, dword ptr [rbx+0D890h]
00007FF91DFDCFF4  F3 0F 5C BB A0 D7 00 00     subss   xmm7, dword ptr [rbx+0D7A0h]
00007FF91DFDCFFC  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDD000  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFDD004  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFDD008  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDD00C  F3 0F 11 8B E0 D7 00 00     movss   dword ptr [rbx+0D7E0h], xmm1
00007FF91DFDD014  72 06                       jb      short loc_7FF91DFDD01C
00007FF91DFDD016  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFDD01A  EB 03                       jmp     short loc_7FF91DFDD01F
00007FF91DFDD01C  0F 57 F6                    xorps   xmm6, xmm6
00007FF91DFDD01F  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFDD023  F3 0F 10 83 40 D8 00 00     movss   xmm0, dword ptr [rbx+0D840h]
00007FF91DFDD02B  73 03                       jnb     short loc_7FF91DFDD030
00007FF91DFDD02D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFDD030  F3 0F 59 83 C0 D8 00 00     mulss   xmm0, dword ptr [rbx+0D8C0h]
00007FF91DFDD038  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFDD03B  F3 0F 10 93 30 D8 00 00     movss   xmm2, dword ptr [rbx+0D830h]
00007FF91DFDD043  F3 44 0F 10 0D 10 7F 76 00  movss   xmm9, cs:dword_7FF91E744F5C
00007FF91DFDD04C  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFDD050  F3 0F 11 B3 A0 D7 00 00     movss   dword ptr [rbx+0D7A0h], xmm6
00007FF91DFDD058  F3 0F 10 8B D0 D8 00 00     movss   xmm1, dword ptr [rbx+0D8D0h]
00007FF91DFDD060  F3 0F 10 BB 50 D8 00 00     movss   xmm7, dword ptr [rbx+0D850h]
00007FF91DFDD068  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDD06B  F3 0F 10 A3 D0 D7 00 00     movss   xmm4, dword ptr [rbx+0D7D0h]
00007FF91DFDD073  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFDD077  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFDD07C  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDD080  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFDD085  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFDD089  F3 0F 59 FE                 mulss   xmm7, xmm6
00007FF91DFDD08D  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFDD091  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDD095  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFDD099  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFDD09C  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFDD0A0  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDD0A4  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFDD0A8  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFDD0AC  76 0B                       jbe     short loc_7FF91DFDD0B9
00007FF91DFDD0AE  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFDD0B1  F3 0F 58 9B E0 D7 00 00     addss   xmm3, dword ptr [rbx+0D7E0h]
00007FF91DFDD0B9  F3 0F 10 83 C0 D8 00 00     movss   xmm0, dword ptr [rbx+0D8C0h]
00007FF91DFDD0C1  F3 0F 10 A3 80 D7 00 00     movss   xmm4, dword ptr [rbx+0D780h]
00007FF91DFDD0C9  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFDD0CD  F3 0F 11 83 C0 D7 00 00     movss   dword ptr [rbx+0D7C0h], xmm0
00007FF91DFDD0D5  F3 0F 10 8B 00 D8 00 00     movss   xmm1, dword ptr [rbx+0D800h]
00007FF91DFDD0DD  F3 0F 10 9B 60 D8 00 00     movss   xmm3, dword ptr [rbx+0D860h]
00007FF91DFDD0E5  F3 0F 59 AB B0 D8 00 00     mulss   xmm5, dword ptr [rbx+0D8B0h]
00007FF91DFDD0ED  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFDD0F2  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFDD0F6  F3 0F 10 83 F0 D8 00 00     movss   xmm0, dword ptr [rbx+0D8F0h]
00007FF91DFDD0FE  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFDD103  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFDD106  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDD10A  F3 0F 58 EE                 addss   xmm5, xmm6
00007FF91DFDD10E  F3 0F 59 D7                 mulss   xmm2, xmm7
00007FF91DFDD112  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFDD116  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFDD11A  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFDD11E  F3 0F 11 93 F0 D7 00 00     movss   dword ptr [rbx+0D7F0h], xmm2
00007FF91DFDD126  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFDD12B  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFDD130  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFDD134  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDD138  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFDD13C  F3 0F 11 9B 70 D7 00 00     movss   dword ptr [rbx+0D770h], xmm3
00007FF91DFDD144  F3 0F 59 9B 00 D9 00 00     mulss   xmm3, dword ptr [rbx+0D900h]
00007FF91DFDD14C  F3 0F 59 9B 10 D9 00 00     mulss   xmm3, dword ptr [rbx+0D910h]
00007FF91DFDD154  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDD157  F3 0F 59 83 20 D9 00 00     mulss   xmm0, dword ptr [rbx+0D920h]
00007FF91DFDD15F  F3 0F 11 9B 10 D8 00 00     movss   dword ptr [rbx+0D810h], xmm3
00007FF91DFDD167  F3 0F 11 83 20 D8 00 00     movss   dword ptr [rbx+0D820h], xmm0
00007FF91DFDD16F  44 0F 2F B3 70 D4 00 00     comiss  xmm14, dword ptr [rbx+0D470h]
00007FF91DFDD177  F3 0F 10 8B 80 CF 00 00     movss   xmm1, dword ptr [rbx+0CF80h]
00007FF91DFDD17F  F3 0F 10 93 30 D9 00 00     movss   xmm2, dword ptr [rbx+0D930h]
00007FF91DFDD187  73 06                       jnb     short loc_7FF91DFDD18F
00007FF91DFDD189  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFDD18D  EB 03                       jmp     short loc_7FF91DFDD192
00007FF91DFDD18F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDD192  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFDD196  75 04                       jnz     short loc_7FF91DFDD19C
00007FF91DFDD198  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFDD19C  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFDD1A0  F3 0F 11 8B 40 D9 00 00     movss   dword ptr [rbx+0D940h], xmm1
00007FF91DFDD1A8  8B 83 50 D9 00 00           mov     eax, [rbx+0D950h]
00007FF91DFDD1AE  89 83 60 D9 00 00           mov     [rbx+0D960h], eax
00007FF91DFDD1B4  8B 83 80 D9 00 00           mov     eax, [rbx+0D980h]
00007FF91DFDD1BA  89 83 90 D9 00 00           mov     [rbx+0D990h], eax
00007FF91DFDD1C0  8B 83 70 D9 00 00           mov     eax, [rbx+0D970h]
00007FF91DFDD1C6  89 83 80 D9 00 00           mov     [rbx+0D980h], eax
00007FF91DFDD1CC  8B 83 A0 D9 00 00           mov     eax, [rbx+0D9A0h]
00007FF91DFDD1D2  89 83 B0 D9 00 00           mov     [rbx+0D9B0h], eax
00007FF91DFDD1D8  8B 83 D0 D9 00 00           mov     eax, [rbx+0D9D0h]
00007FF91DFDD1DE  89 83 E0 D9 00 00           mov     [rbx+0D9E0h], eax
00007FF91DFDD1E4  F3 0F 10 83 80 DA 00 00     movss   xmm0, dword ptr [rbx+0DA80h]
00007FF91DFDD1EC  F3 0F 58 8B 60 DA 00 00     addss   xmm1, dword ptr [rbx+0DA60h]
00007FF91DFDD1F4  F3 0F 59 83 90 D9 00 00     mulss   xmm0, dword ptr [rbx+0D990h]
00007FF91DFDD1FC  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFDD200  F3 0F 58 83 60 D9 00 00     addss   xmm0, dword ptr [rbx+0D960h]
00007FF91DFDD208  73 06                       jnb     short loc_7FF91DFDD210
00007FF91DFDD20A  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFDD20E  EB 04                       jmp     short loc_7FF91DFDD214
00007FF91DFDD210  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFDD214  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFDD218  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFDD21D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFDD220  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFDD224  F3 0F 11 B3 70 D9 00 00     movss   dword ptr [rbx+0D970h], xmm6
00007FF91DFDD22C  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFDD22F  F3 0F 10 9B 50 DA 00 00     movss   xmm3, dword ptr [rbx+0DA50h]
00007FF91DFDD237  F3 0F 10 93 A0 DA 00 00     movss   xmm2, dword ptr [rbx+0DAA0h]
00007FF91DFDD23F  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFDD242  F3 0F 59 8B C0 DA 00 00     mulss   xmm1, dword ptr [rbx+0DAC0h]
00007FF91DFDD24A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDD24D  F3 0F 58 A3 70 DA 00 00     addss   xmm4, dword ptr [rbx+0DA70h]
00007FF91DFDD255  F3 0F 5C B3 80 D9 00 00     subss   xmm6, dword ptr [rbx+0D980h]
00007FF91DFDD25D  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDD261  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFDD265  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFDD269  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDD26D  F3 0F 11 8B C0 D9 00 00     movss   dword ptr [rbx+0D9C0h], xmm1
00007FF91DFDD275  72 06                       jb      short loc_7FF91DFDD27D
00007FF91DFDD277  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFDD27B  EB 03                       jmp     short loc_7FF91DFDD280
00007FF91DFDD27D  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFDD280  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFDD284  F3 0F 10 83 20 DA 00 00     movss   xmm0, dword ptr [rbx+0DA20h]
00007FF91DFDD28C  73 03                       jnb     short loc_7FF91DFDD291
00007FF91DFDD28E  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFDD291  F3 0F 59 83 A0 DA 00 00     mulss   xmm0, dword ptr [rbx+0DAA0h]
00007FF91DFDD299  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFDD29C  F3 0F 10 93 10 DA 00 00     movss   xmm2, dword ptr [rbx+0DA10h]
00007FF91DFDD2A4  F3 0F 11 BB 80 D9 00 00     movss   dword ptr [rbx+0D980h], xmm7
00007FF91DFDD2AC  F3 0F 10 8B B0 DA 00 00     movss   xmm1, dword ptr [rbx+0DAB0h]
00007FF91DFDD2B4  F3 0F 10 B3 30 DA 00 00     movss   xmm6, dword ptr [rbx+0DA30h]
00007FF91DFDD2BC  F3 0F 10 A3 B0 D9 00 00     movss   xmm4, dword ptr [rbx+0D9B0h]
00007FF91DFDD2C4  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFDD2C8  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDD2CB  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFDD2CF  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFDD2D4  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDD2D8  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFDD2DD  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFDD2E1  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFDD2E5  F3 0F 5C C7                 subss   xmm0, xmm7
00007FF91DFDD2E9  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDD2ED  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFDD2F1  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFDD2F4  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFDD2F8  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDD2FC  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFDD300  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFDD304  76 0B                       jbe     short loc_7FF91DFDD311
00007FF91DFDD306  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFDD309  F3 0F 58 9B C0 D9 00 00     addss   xmm3, dword ptr [rbx+0D9C0h]
00007FF91DFDD311  F3 0F 10 A3 60 D9 00 00     movss   xmm4, dword ptr [rbx+0D960h]
00007FF91DFDD319  F3 0F 10 83 A0 DA 00 00     movss   xmm0, dword ptr [rbx+0DAA0h]
00007FF91DFDD321  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFDD325  F3 0F 11 83 A0 D9 00 00     movss   dword ptr [rbx+0D9A0h], xmm0
00007FF91DFDD32D  F3 0F 59 AB 90 DA 00 00     mulss   xmm5, dword ptr [rbx+0DA90h]
00007FF91DFDD335  F3 0F 10 8B E0 D9 00 00     movss   xmm1, dword ptr [rbx+0D9E0h]
00007FF91DFDD33D  F3 0F 10 9B 40 DA 00 00     movss   xmm3, dword ptr [rbx+0DA40h]
00007FF91DFDD345  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFDD349  F3 0F 10 83 D0 DA 00 00     movss   xmm0, dword ptr [rbx+0DAD0h]
00007FF91DFDD351  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFDD354  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFDD359  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDD35D  F3 0F 58 EF                 addss   xmm5, xmm7
00007FF91DFDD361  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFDD366  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFDD36A  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFDD36E  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFDD372  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFDD376  F3 0F 11 93 D0 D9 00 00     movss   dword ptr [rbx+0D9D0h], xmm2
00007FF91DFDD37E  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFDD383  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFDD388  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFDD38C  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDD390  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFDD394  F3 0F 11 9B 50 D9 00 00     movss   dword ptr [rbx+0D950h], xmm3
00007FF91DFDD39C  F3 0F 59 9B E0 DA 00 00     mulss   xmm3, dword ptr [rbx+0DAE0h]
00007FF91DFDD3A4  F3 0F 59 9B F0 DA 00 00     mulss   xmm3, dword ptr [rbx+0DAF0h]
00007FF91DFDD3AC  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDD3AF  F3 0F 59 83 00 DB 00 00     mulss   xmm0, dword ptr [rbx+0DB00h]
00007FF91DFDD3B7  F3 0F 11 9B F0 D9 00 00     movss   dword ptr [rbx+0D9F0h], xmm3
00007FF91DFDD3BF  F3 0F 11 83 00 DA 00 00     movss   dword ptr [rbx+0DA00h], xmm0
00007FF91DFDD3C7  8B 83 10 DB 00 00           mov     eax, [rbx+0DB10h]
00007FF91DFDD3CD  89 83 20 DB 00 00           mov     [rbx+0DB20h], eax
00007FF91DFDD3D3  8B 83 30 DB 00 00           mov     eax, [rbx+0DB30h]
00007FF91DFDD3D9  89 83 40 DB 00 00           mov     [rbx+0DB40h], eax
00007FF91DFDD3DF  F3 0F 10 83 40 D0 00 00     movss   xmm0, dword ptr [rbx+0D040h]
00007FF91DFDD3E7  F3 44 0F 10 83 C0 D0 00 00  movss   xmm8, dword ptr [rbx+0D0C0h]
00007FF91DFDD3F0  8B 83 70 DB 00 00           mov     eax, [rbx+0DB70h]
00007FF91DFDD3F6  89 83 80 DB 00 00           mov     [rbx+0DB80h], eax
00007FF91DFDD3FC  F3 0F 59 83 50 DB 00 00     mulss   xmm0, dword ptr [rbx+0DB50h]
00007FF91DFDD404  F3 44 0F 59 83 60 DB 00 00  mulss   xmm8, dword ptr [rbx+0DB60h]
00007FF91DFDD40D  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFDD412  F3 44 0F 11 83 70 DB 00 00  movss   dword ptr [rbx+0DB70h], xmm8
00007FF91DFDD41B  F3 0F 10 BB 50 D4 00 00     movss   xmm7, dword ptr [rbx+0D450h]
00007FF91DFDD423  F3 0F 10 8B 10 D8 00 00     movss   xmm1, dword ptr [rbx+0D810h]
00007FF91DFDD42B  F3 0F 10 93 F0 D9 00 00     movss   xmm2, dword ptr [rbx+0D9F0h]
00007FF91DFDD433  F3 0F 10 83 40 D0 00 00     movss   xmm0, dword ptr [rbx+0D040h]
00007FF91DFDD43B  8B 83 30 DB 00 00           mov     eax, [rbx+0DB30h]
00007FF91DFDD441  89 83 B0 DB 00 00           mov     [rbx+0DBB0h], eax
00007FF91DFDD447  F3 0F 11 83 C0 DB 00 00     movss   dword ptr [rbx+0DBC0h], xmm0
00007FF91DFDD44F  F3 0F 10 A3 00 DD 00 00     movss   xmm4, dword ptr [rbx+0DD00h]
00007FF91DFDD457  F3 0F 11 8B 90 DB 00 00     movss   dword ptr [rbx+0DB90h], xmm1
00007FF91DFDD45F  F3 0F 11 93 A0 DB 00 00     movss   dword ptr [rbx+0DBA0h], xmm2
00007FF91DFDD467  F3 0F 10 AB E0 DC 00 00     movss   xmm5, dword ptr [rbx+0DCE0h]
00007FF91DFDD46F  F3 0F 59 FC                 mulss   xmm7, xmm4
00007FF91DFDD473  F3 0F 59 A3 60 D4 00 00     mulss   xmm4, dword ptr [rbx+0D460h]
00007FF91DFDD47B  F3 0F 11 A3 D0 DB 00 00     movss   dword ptr [rbx+0DBD0h], xmm4
00007FF91DFDD483  F3 0F 10 8B 60 DC 00 00     movss   xmm1, dword ptr [rbx+0DC60h]
00007FF91DFDD48B  F3 0F 10 93 60 DD 00 00     movss   xmm2, dword ptr [rbx+0DD60h]
00007FF91DFDD493  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFDD496  F3 0F 59 BB 10 DD 00 00     mulss   xmm7, dword ptr [rbx+0DD10h]
00007FF91DFDD49E  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDD4A1  F3 0F 10 B3 20 DD 00 00     movss   xmm6, dword ptr [rbx+0DD20h]
00007FF91DFDD4A9  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDD4AD  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFDD4B1  F3 0F 59 EC                 mulss   xmm5, xmm4
00007FF91DFDD4B5  F3 0F 59 AB F0 DC 00 00     mulss   xmm5, dword ptr [rbx+0DCF0h]
00007FF91DFDD4BD  F3 0F 11 AB F0 DB 00 00     movss   dword ptr [rbx+0DBF0h], xmm5
00007FF91DFDD4C5  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFDD4C9  F3 0F 59 9B B0 DB 00 00     mulss   xmm3, dword ptr [rbx+0DBB0h]
00007FF91DFDD4D1  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDD4D5  F3 0F 10 83 70 DC 00 00     movss   xmm0, dword ptr [rbx+0DC70h]
00007FF91DFDD4DD  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFDD4E1  F3 0F 59 9B 70 DD 00 00     mulss   xmm3, dword ptr [rbx+0DD70h]
00007FF91DFDD4E9  F3 0F 11 9B 00 DC 00 00     movss   dword ptr [rbx+0DC00h], xmm3
00007FF91DFDD4F1  F3 0F 10 8B 40 DD 00 00     movss   xmm1, dword ptr [rbx+0DD40h]
00007FF91DFDD4F9  F3 0F 59 8B A0 DB 00 00     mulss   xmm1, dword ptr [rbx+0DBA0h]
00007FF91DFDD501  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDD505  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFDD509  F3 0F 10 83 30 DD 00 00     movss   xmm0, dword ptr [rbx+0DD30h]
00007FF91DFDD511  F3 0F 59 83 90 DB 00 00     mulss   xmm0, dword ptr [rbx+0DB90h]
00007FF91DFDD519  F3 0F 10 9B D0 DB 00 00     movss   xmm3, dword ptr [rbx+0DBD0h]
00007FF91DFDD521  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDD525  F3 0F 10 83 50 DC 00 00     movss   xmm0, dword ptr [rbx+0DC50h]
00007FF91DFDD52D  F3 0F 59 8B 50 DD 00 00     mulss   xmm1, dword ptr [rbx+0DD50h]
00007FF91DFDD535  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFDD539  F3 41 0F 58 C8              addss   xmm1, xmm8
00007FF91DFDD53E  F3 0F 58 8B C0 DC 00 00     addss   xmm1, dword ptr [rbx+0DCC0h]
00007FF91DFDD546  F3 0F 58 8B D0 DC 00 00     addss   xmm1, dword ptr [rbx+0DCD0h]
00007FF91DFDD54E  F3 0F 11 8B 10 DC 00 00     movss   dword ptr [rbx+0DC10h], xmm1
00007FF91DFDD556  F3 0F 11 83 20 DC 00 00     movss   dword ptr [rbx+0DC20h], xmm0
00007FF91DFDD55E  F3 0F 59 9B 90 DD 00 00     mulss   xmm3, dword ptr [rbx+0DD90h]
00007FF91DFDD566  F3 0F 10 83 90 DC 00 00     movss   xmm0, dword ptr [rbx+0DC90h]
00007FF91DFDD56E  F3 0F 59 83 90 DB 00 00     mulss   xmm0, dword ptr [rbx+0DB90h]
00007FF91DFDD576  F3 0F 58 9B A0 DD 00 00     addss   xmm3, dword ptr [rbx+0DDA0h]
00007FF91DFDD57E  F3 0F 10 8B A0 DC 00 00     movss   xmm1, dword ptr [rbx+0DCA0h]
00007FF91DFDD586  F3 0F 59 8B A0 DB 00 00     mulss   xmm1, dword ptr [rbx+0DBA0h]
00007FF91DFDD58E  F3 0F 10 93 F0 DB 00 00     movss   xmm2, dword ptr [rbx+0DBF0h]
00007FF91DFDD596  F3 0F 59 9B 80 DC 00 00     mulss   xmm3, dword ptr [rbx+0DC80h]
00007FF91DFDD59E  F3 0F 58 93 C0 DB 00 00     addss   xmm2, dword ptr [rbx+0DBC0h]
00007FF91DFDD5A6  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDD5AA  F3 0F 58 93 00 DC 00 00     addss   xmm2, dword ptr [rbx+0DC00h]
00007FF91DFDD5B2  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDD5B6  F3 0F 58 9B B0 DC 00 00     addss   xmm3, dword ptr [rbx+0DCB0h]
00007FF91DFDD5BE  F3 0F 59 9B 80 DD 00 00     mulss   xmm3, dword ptr [rbx+0DD80h]
00007FF91DFDD5C6  F3 0F 11 9B 30 DC 00 00     movss   dword ptr [rbx+0DC30h], xmm3
00007FF91DFDD5CE  F3 0F 11 93 40 DC 00 00     movss   dword ptr [rbx+0DC40h], xmm2
00007FF91DFDD5D6  F3 0F 10 83 C0 DD 00 00     movss   xmm0, dword ptr [rbx+0DDC0h]
00007FF91DFDD5DE  8B 83 B0 DD 00 00           mov     eax, [rbx+0DDB0h]
00007FF91DFDD5E4  89 83 E0 DD 00 00           mov     [rbx+0DDE0h], eax
00007FF91DFDD5EA  F3 0F 11 83 F0 DD 00 00     movss   dword ptr [rbx+0DDF0h], xmm0
00007FF91DFDD5F2  8B 83 D0 DD 00 00           mov     eax, [rbx+0DDD0h]
00007FF91DFDD5F8  89 83 00 DE 00 00           mov     [rbx+0DE00h], eax
00007FF91DFDD5FE  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
00007FF91DFDD606  8B 83 20 DE 00 00           mov     eax, [rbx+0DE20h]
00007FF91DFDD60C  89 83 30 DE 00 00           mov     [rbx+0DE30h], eax
00007FF91DFDD612  F3 0F 10 93 10 DE 00 00     movss   xmm2, dword ptr [rbx+0DE10h]
00007FF91DFDD61A  F3 0F 11 93 20 DE 00 00     movss   dword ptr [rbx+0DE20h], xmm2
00007FF91DFDD622  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDD625  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDD628  F3 0F 59 9B 40 DE 00 00     mulss   xmm3, dword ptr [rbx+0DE40h]
00007FF91DFDD630  F3 0F 58 9B 30 DE 00 00     addss   xmm3, dword ptr [rbx+0DE30h]
00007FF91DFDD638  F3 0F 11 9B 20 DE 00 00     movss   dword ptr [rbx+0DE20h], xmm3
00007FF91DFDD640  F3 0F 59 83 50 DE 00 00     mulss   xmm0, dword ptr [rbx+0DE50h]
00007FF91DFDD648  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFDD64C  F3 0F 59 9B 80 DE 00 00     mulss   xmm3, dword ptr [rbx+0DE80h]
00007FF91DFDD654  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFDD658  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFDD65B  F3 0F 59 8B 40 DE 00 00     mulss   xmm1, dword ptr [rbx+0DE40h]
00007FF91DFDD663  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDD667  F3 0F 11 8B 10 DE 00 00     movss   dword ptr [rbx+0DE10h], xmm1
00007FF91DFDD66F  F3 0F 59 8B 70 DE 00 00     mulss   xmm1, dword ptr [rbx+0DE70h]
00007FF91DFDD677  F3 0F 59 A3 60 DE 00 00     mulss   xmm4, dword ptr [rbx+0DE60h]
00007FF91DFDD67F  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDD683  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDD687  F3 0F 11 A3 30 DE 00 00     movss   dword ptr [rbx+0DE30h], xmm4
00007FF91DFDD68F  8B 83 60 E6 00 00           mov     eax, [rbx+0E660h]
00007FF91DFDD695  89 83 70 E6 00 00           mov     [rbx+0E670h], eax
00007FF91DFDD69B  F3 0F 10 8B 80 E6 00 00     movss   xmm1, dword ptr [rbx+0E680h]
00007FF91DFDD6A3  F3 0F 11 8B 90 E6 00 00     movss   dword ptr [rbx+0E690h], xmm1
00007FF91DFDD6AB  F3 0F 59 8B 20 DB 00 00     mulss   xmm1, dword ptr [rbx+0DB20h]
00007FF91DFDD6B3  F3 0F 10 83 70 E6 00 00     movss   xmm0, dword ptr [rbx+0E670h]
00007FF91DFDD6BB  F3 0F 59 83 30 DE 00 00     mulss   xmm0, dword ptr [rbx+0DE30h]
00007FF91DFDD6C3  F3 0F 11 8B A0 E6 00 00     movss   dword ptr [rbx+0E6A0h], xmm1
00007FF91DFDD6CB  F3 0F 11 83 B0 E6 00 00     movss   dword ptr [rbx+0E6B0h], xmm0
00007FF91DFDD6D3  8B 83 E0 E6 00 00           mov     eax, [rbx+0E6E0h]
00007FF91DFDD6D9  89 83 F0 E6 00 00           mov     [rbx+0E6F0h], eax
00007FF91DFDD6DF  F3 0F 59 8B C0 E6 00 00     mulss   xmm1, dword ptr [rbx+0E6C0h]
00007FF91DFDD6E7  F3 0F 59 83 D0 E6 00 00     mulss   xmm0, dword ptr [rbx+0E6D0h]
00007FF91DFDD6EF  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFDD6F3  F3 0F 11 83 E0 E6 00 00     movss   dword ptr [rbx+0E6E0h], xmm0
00007FF91DFDD6FB  8B 83 00 E7 00 00           mov     eax, [rbx+0E700h]
00007FF91DFDD701  89 83 10 E7 00 00           mov     [rbx+0E710h], eax
00007FF91DFDD707  8B 83 20 E7 00 00           mov     eax, [rbx+0E720h]
00007FF91DFDD70D  89 83 30 E7 00 00           mov     [rbx+0E730h], eax
00007FF91DFDD713  8B 83 40 E7 00 00           mov     eax, [rbx+0E740h]
00007FF91DFDD719  89 83 50 E7 00 00           mov     [rbx+0E750h], eax
00007FF91DFDD71F  8B 83 60 E7 00 00           mov     eax, [rbx+0E760h]
00007FF91DFDD725  89 83 70 E7 00 00           mov     [rbx+0E770h], eax
00007FF91DFDD72B  F3 0F 10 8B 90 E7 00 00     movss   xmm1, dword ptr [rbx+0E790h]
00007FF91DFDD733  F3 0F 10 93 A0 E7 00 00     movss   xmm2, dword ptr [rbx+0E7A0h]
00007FF91DFDD73B  0F 28 E1                    movaps  xmm4, xmm1
00007FF91DFDD73E  F3 0F 59 A3 00 E7 00 00     mulss   xmm4, dword ptr [rbx+0E700h]
00007FF91DFDD746  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDD749  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDD74D  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFDD751  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFDD755  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFDD758  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFDD75B  F3 0F 59 8B C0 E7 00 00     mulss   xmm1, dword ptr [rbx+0E7C0h]
00007FF91DFDD763  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDD767  F3 0F 58 8B B0 E7 00 00     addss   xmm1, dword ptr [rbx+0E7B0h]
00007FF91DFDD76F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDD772  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDD776  F3 0F 59 83 D0 E7 00 00     mulss   xmm0, dword ptr [rbx+0E7D0h]
00007FF91DFDD77E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDD782  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDD785  F3 0F 59 9B E0 E7 00 00     mulss   xmm3, dword ptr [rbx+0E7E0h]
00007FF91DFDD78D  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFDD791  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDD795  F3 0F 59 83 F0 E7 00 00     mulss   xmm0, dword ptr [rbx+0E7F0h]
00007FF91DFDD79D  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFDD7A1  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDD7A5  76 05                       jbe     short loc_7FF91DFDD7AC
00007FF91DFDD7A7  0F 5A C0                    cvtps2pd xmm0, xmm0
00007FF91DFDD7AA  EB 03                       jmp     short loc_7FF91DFDD7AF
00007FF91DFDD7AC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDD7AF  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFDD7B3  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFDD7B7  73 04                       jnb     short loc_7FF91DFDD7BD
00007FF91DFDD7B9  44 0F 5A E1                 cvtps2pd xmm12, xmm1
00007FF91DFDD7BD  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
00007FF91DFDD7C2  F3 0F 11 83 80 E7 00 00     movss   dword ptr [rbx+0E780h], xmm0
00007FF91DFDD7CA  8B 83 00 E8 00 00           mov     eax, [rbx+0E800h]
00007FF91DFDD7D0  89 83 10 E8 00 00           mov     [rbx+0E810h], eax
00007FF91DFDD7D6  F3 0F 10 8B 20 E8 00 00     movss   xmm1, dword ptr [rbx+0E820h]
00007FF91DFDD7DE  F3 0F 11 8B 30 E8 00 00     movss   dword ptr [rbx+0E830h], xmm1
00007FF91DFDD7E6  F3 0F 10 83 40 E8 00 00     movss   xmm0, dword ptr [rbx+0E840h]
00007FF91DFDD7EE  F3 0F 11 83 50 E8 00 00     movss   dword ptr [rbx+0E850h], xmm0
00007FF91DFDD7F6  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFDD7FA  F3 0F 59 8B 60 E8 00 00     mulss   xmm1, dword ptr [rbx+0E860h]
00007FF91DFDD802  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDD806  F3 0F 11 8B 40 E8 00 00     movss   dword ptr [rbx+0E840h], xmm1
00007FF91DFDD80E  F3 0F 10 8B 40 D0 00 00     movss   xmm1, dword ptr [rbx+0D040h]
00007FF91DFDD816  F3 0F 10 83 C0 D0 00 00     movss   xmm0, dword ptr [rbx+0D0C0h]
00007FF91DFDD81E  8B 83 90 E8 00 00           mov     eax, [rbx+0E890h]
00007FF91DFDD824  89 83 A0 E8 00 00           mov     [rbx+0E8A0h], eax
00007FF91DFDD82A  F3 0F 59 83 80 E8 00 00     mulss   xmm0, dword ptr [rbx+0E880h]
00007FF91DFDD832  F3 0F 59 8B 70 E8 00 00     mulss   xmm1, dword ptr [rbx+0E870h]
00007FF91DFDD83A  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFDD83E  F3 0F 11 83 90 E8 00 00     movss   dword ptr [rbx+0E890h], xmm0
00007FF91DFDD846  8B 83 B0 E8 00 00           mov     eax, [rbx+0E8B0h]
00007FF91DFDD84C  89 83 D0 E8 00 00           mov     [rbx+0E8D0h], eax
00007FF91DFDD852  F3 0F 10 9B C0 E8 00 00     movss   xmm3, dword ptr [rbx+0E8C0h]
00007FF91DFDD85A  F3 0F 11 9B E0 E8 00 00     movss   dword ptr [rbx+0E8E0h], xmm3
00007FF91DFDD862  F3 0F 10 8B D0 E8 00 00     movss   xmm1, dword ptr [rbx+0E8D0h]
00007FF91DFDD86A  F3 0F 10 93 10 D8 00 00     movss   xmm2, dword ptr [rbx+0D810h]
00007FF91DFDD872  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDD875  F3 0F 59 83 F0 D9 00 00     mulss   xmm0, dword ptr [rbx+0D9F0h]
00007FF91DFDD87D  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFDD881  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFDD885  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFDD888  F3 0F 59 8B 40 E7 00 00     mulss   xmm1, dword ptr [rbx+0E740h]
00007FF91DFDD890  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDD894  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFDD898  F3 0F 5C CB                 subss   xmm1, xmm3
00007FF91DFDD89C  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDD8A0  F3 0F 11 8B F0 E8 00 00     movss   dword ptr [rbx+0E8F0h], xmm1
00007FF91DFDD8A8  F3 0F 10 9B 50 D4 00 00     movss   xmm3, dword ptr [rbx+0D450h]
00007FF91DFDD8B0  F3 0F 10 83 00 E9 00 00     movss   xmm0, dword ptr [rbx+0E900h]
00007FF91DFDD8B8  F3 0F 11 83 10 E9 00 00     movss   dword ptr [rbx+0E910h], xmm0
00007FF91DFDD8C0  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDD8C4  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFDD8C7  F3 0F 59 8B 20 E9 00 00     mulss   xmm1, dword ptr [rbx+0E920h]
00007FF91DFDD8CF  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDD8D3  F3 0F 10 83 40 E9 00 00     movss   xmm0, dword ptr [rbx+0E940h]
00007FF91DFDD8DB  F3 0F 11 8B 00 E9 00 00     movss   dword ptr [rbx+0E900h], xmm1
00007FF91DFDD8E3  F3 0F 59 9B 30 E9 00 00     mulss   xmm3, dword ptr [rbx+0E930h]
00007FF91DFDD8EB  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDD8EF  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDD8F3  F3 0F 11 9B 10 E9 00 00     movss   dword ptr [rbx+0E910h], xmm3
00007FF91DFDD8FB  F3 0F 10 83 50 E9 00 00     movss   xmm0, dword ptr [rbx+0E950h]
00007FF91DFDD903  F3 0F 10 BB 60 D4 00 00     movss   xmm7, dword ptr [rbx+0D460h]
00007FF91DFDD90B  F3 0F 11 83 60 E9 00 00     movss   dword ptr [rbx+0E960h], xmm0
00007FF91DFDD913  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFDD917  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFDD91A  F3 0F 59 8B 70 E9 00 00     mulss   xmm1, dword ptr [rbx+0E970h]
00007FF91DFDD922  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDD926  F3 0F 10 83 90 E9 00 00     movss   xmm0, dword ptr [rbx+0E990h]
00007FF91DFDD92E  F3 0F 11 8B 50 E9 00 00     movss   dword ptr [rbx+0E950h], xmm1
00007FF91DFDD936  F3 0F 59 BB 80 E9 00 00     mulss   xmm7, dword ptr [rbx+0E980h]
00007FF91DFDD93E  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDD942  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFDD946  F3 0F 11 BB 60 E9 00 00     movss   dword ptr [rbx+0E960h], xmm7
00007FF91DFDD94E  F3 0F 10 A3 10 E9 00 00     movss   xmm4, dword ptr [rbx+0E910h]
00007FF91DFDD956  F3 0F 10 AB F0 E8 00 00     movss   xmm5, dword ptr [rbx+0E8F0h]
00007FF91DFDD95E  F3 0F 10 B3 90 E8 00 00     movss   xmm6, dword ptr [rbx+0E890h]
00007FF91DFDD966  F3 44 0F 10 8B 20 E7 00 00  movss   xmm9, dword ptr [rbx+0E720h]
00007FF91DFDD96F  8B 83 40 E8 00 00           mov     eax, [rbx+0E840h]
00007FF91DFDD975  89 83 A0 E9 00 00           mov     [rbx+0E9A0h], eax
00007FF91DFDD97B  F3 44 0F 11 8B B0 E9 00 00  movss   dword ptr [rbx+0E9B0h], xmm9
00007FF91DFDD984  F3 0F 10 83 D0 E9 00 00     movss   xmm0, dword ptr [rbx+0E9D0h]
00007FF91DFDD98C  F3 0F 10 93 E0 E9 00 00     movss   xmm2, dword ptr [rbx+0E9E0h]
00007FF91DFDD994  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFDD998  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDD99B  F3 0F 59 9B 60 E7 00 00     mulss   xmm3, dword ptr [rbx+0E760h]
00007FF91DFDD9A3  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDD9A7  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDD9AA  F3 0F 59 C7                 mulss   xmm0, xmm7
00007FF91DFDD9AE  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFDD9B2  F3 44 0F 5C C0              subss   xmm8, xmm0
00007FF91DFDD9B7  F3 44 0F 58 C7              addss   xmm8, xmm7
00007FF91DFDD9BC  F3 44 0F 59 83 10 EA 00 00  mulss   xmm8, dword ptr [rbx+0EA10h]
00007FF91DFDD9C5  F3 0F 10 8B F0 E9 00 00     movss   xmm1, dword ptr [rbx+0E9F0h]
00007FF91DFDD9CD  F3 0F 58 B3 90 EA 00 00     addss   xmm6, dword ptr [rbx+0EA90h]
00007FF91DFDD9D5  F3 44 0F 59 83 20 EA 00 00  mulss   xmm8, dword ptr [rbx+0EA20h]
00007FF91DFDD9DE  F3 0F 59 AB 30 EA 00 00     mulss   xmm5, dword ptr [rbx+0EA30h]
00007FF91DFDD9E6  F3 0F 59 B3 40 EA 00 00     mulss   xmm6, dword ptr [rbx+0EA40h]
00007FF91DFDD9EE  F3 44 0F 59 C9              mulss   xmm9, xmm1
00007FF91DFDD9F3  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDD9F7  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFDD9FB  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFDD9FF  F3 0F 10 93 70 EA 00 00     movss   xmm2, dword ptr [rbx+0EA70h]
00007FF91DFDDA07  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDDA0A  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDDA0E  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFDDA12  F3 44 0F 5C C8              subss   xmm9, xmm0
00007FF91DFDDA17  F3 0F 10 83 60 EA 00 00     movss   xmm0, dword ptr [rbx+0EA60h]
00007FF91DFDDA1F  F3 0F 58 83 A0 E9 00 00     addss   xmm0, dword ptr [rbx+0E9A0h]
00007FF91DFDDA27  F3 0F 59 9B 00 EA 00 00     mulss   xmm3, dword ptr [rbx+0EA00h]
00007FF91DFDDA2F  F3 0F 59 83 A0 EA 00 00     mulss   xmm0, dword ptr [rbx+0EAA0h]
00007FF91DFDDA37  F3 44 0F 58 CA              addss   xmm9, xmm2
00007FF91DFDDA3C  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFDDA41  F3 0F 59 83 50 EA 00 00     mulss   xmm0, dword ptr [rbx+0EA50h]
00007FF91DFDDA49  F3 44 0F 59 8B 80 EA 00 00  mulss   xmm9, dword ptr [rbx+0EA80h]
00007FF91DFDDA52  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFDDA57  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFDDA5C  F3 45 0F 58 C8              addss   xmm9, xmm8
00007FF91DFDDA61  F3 44 0F 11 8B C0 E9 00 00  movss   dword ptr [rbx+0E9C0h], xmm9
00007FF91DFDDA6A  F3 0F 10 BB 80 E7 00 00     movss   xmm7, dword ptr [rbx+0E780h]
00007FF91DFDDA72  F3 44 0F 10 83 10 E8 00 00  movss   xmm8, dword ptr [rbx+0E810h]
00007FF91DFDDA7B  8B 83 E0 EA 00 00           mov     eax, [rbx+0EAE0h]
00007FF91DFDDA81  89 83 F0 EA 00 00           mov     [rbx+0EAF0h], eax
00007FF91DFDDA87  F3 0F 10 83 D0 EA 00 00     movss   xmm0, dword ptr [rbx+0EAD0h]
00007FF91DFDDA8F  F3 0F 11 83 E0 EA 00 00     movss   dword ptr [rbx+0EAE0h], xmm0
00007FF91DFDDA97  44 0F 2E AB 20 EB 00 00     ucomiss xmm13, dword ptr [rbx+0EB20h]
00007FF91DFDDA9F  0F 85 7D 02 00 00           jnz     loc_7FF91DFDDD22
00007FF91DFDDAA5  F3 0F 10 8B 70 EB 00 00     movss   xmm1, dword ptr [rbx+0EB70h]
00007FF91DFDDAAD  F3 0F 10 B3 F0 EA 00 00     movss   xmm6, dword ptr [rbx+0EAF0h]
00007FF91DFDDAB5  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFDDAB8  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFDDABC  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFDDAC0  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFDDAC4  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFDDAC8  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFDDACC  F3 0F 11 B3 E0 EA 00 00     movss   dword ptr [rbx+0EAE0h], xmm6
00007FF91DFDDAD4  F3 0F 59 B3 60 EB 00 00     mulss   xmm6, dword ptr [rbx+0EB60h]
00007FF91DFDDADC  F3 0F 58 B3 00 EB 00 00     addss   xmm6, dword ptr [rbx+0EB00h]
00007FF91DFDDAE4  E8 77 B2 FE FF              call    sub_7FF91DFC8D60
00007FF91DFDDAE9  F3 0F 11 83 D0 EA 00 00     movss   dword ptr [rbx+0EAD0h], xmm0
00007FF91DFDDAF1  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFDDAF5  F3 0F 59 8B C0 EB 00 00     mulss   xmm1, dword ptr [rbx+0EBC0h]
00007FF91DFDDAFD  41 0F 28 D5                 movaps  xmm2, xmm13
00007FF91DFDDB01  F3 41 0F 5C D0              subss   xmm2, xmm8
00007FF91DFDDB06  F3 0F 58 8B 10 EB 00 00     addss   xmm1, dword ptr [rbx+0EB10h]
00007FF91DFDDB0E  F3 0F 59 93 80 EB 00 00     mulss   xmm2, dword ptr [rbx+0EB80h]
00007FF91DFDDB16  F3 0F 11 8B C0 EA 00 00     movss   dword ptr [rbx+0EAC0h], xmm1
00007FF91DFDDB1E  F3 0F 59 BB 30 EB 00 00     mulss   xmm7, dword ptr [rbx+0EB30h]
00007FF91DFDDB26  F3 44 0F 59 8B 50 EB 00 00  mulss   xmm9, dword ptr [rbx+0EB50h]
00007FF91DFDDB2F  F3 0F 10 83 90 EB 00 00     movss   xmm0, dword ptr [rbx+0EB90h]
00007FF91DFDDB37  F3 0F 5D C2                 minss   xmm0, xmm2
00007FF91DFDDB3B  F3 41 0F 58 F9              addss   xmm7, xmm9
00007FF91DFDDB40  F3 0F 58 FE                 addss   xmm7, xmm6
00007FF91DFDDB44  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFDDB48  F3 0F 58 BB 40 EB 00 00     addss   xmm7, dword ptr [rbx+0EB40h]
00007FF91DFDDB50  F3 0F 5D BB A0 EB 00 00     minss   xmm7, dword ptr [rbx+0EBA0h]
00007FF91DFDDB58  F3 0F 5F BB B0 EB 00 00     maxss   xmm7, dword ptr [rbx+0EBB0h]
00007FF91DFDDB60  F3 0F 59 BB E0 EB 00 00     mulss   xmm7, dword ptr [rbx+0EBE0h]
00007FF91DFDDB68  F3 0F 58 BB F0 EB 00 00     addss   xmm7, dword ptr [rbx+0EBF0h]
00007FF91DFDDB70  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFDDB73  F3 0F 2C C9                 cvttss2si ecx, xmm1
00007FF91DFDDB77  81 F9 00 00 00 80           cmp     ecx, 80000000h
00007FF91DFDDB7D  74 1E                       jz      short loc_7FF91DFDDB9D
00007FF91DFDDB7F  66 0F 6E C1                 movd    xmm0, ecx
00007FF91DFDDB83  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFDDB86  0F 2E C1                    ucomiss xmm0, xmm1
00007FF91DFDDB89  74 12                       jz      short loc_7FF91DFDDB9D
00007FF91DFDDB8B  0F 14 C9                    unpcklps xmm1, xmm1
00007FF91DFDDB8E  0F 50 C1                    movmskps eax, xmm1
00007FF91DFDDB91  83 E0 01                    and     eax, 1
00007FF91DFDDB94  2B C8                       sub     ecx, eax
00007FF91DFDDB96  66 0F 6E C9                 movd    xmm1, ecx
00007FF91DFDDB9A  0F 5B C9                    cvtdq2ps xmm1, xmm1
00007FF91DFDDB9D  F3 0F 5C F9                 subss   xmm7, xmm1
00007FF91DFDDBA1  0F 28 C1                    movaps  xmm0, xmm1; X
00007FF91DFDDBA4  0F 28 F7                    movaps  xmm6, xmm7
00007FF91DFDDBA7  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFDDBAB  F3 0F 59 35 1D 74 76 00     mulss   xmm6, cs:dword_7FF91E744FD0
00007FF91DFDDBB3  E8 88 1B 37 00              call    expf
00007FF91DFDDBB8  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFDDBBB  0F 28 D7                    movaps  xmm2, xmm7
00007FF91DFDDBBE  F3 0F 59 93 B0 EC 00 00     mulss   xmm2, dword ptr [rbx+0ECB0h]
00007FF91DFDDBC6  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFDDBC9  F3 0F 59 8B 90 EC 00 00     mulss   xmm1, dword ptr [rbx+0EC90h]
00007FF91DFDDBD1  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFDDBD4  F3 0F 58 93 A0 EC 00 00     addss   xmm2, dword ptr [rbx+0ECA0h]
00007FF91DFDDBDC  F3 0F 59 83 70 EC 00 00     mulss   xmm0, dword ptr [rbx+0EC70h]
00007FF91DFDDBE4  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFDDBE8  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFDDBEC  F3 0F 58 93 80 EC 00 00     addss   xmm2, dword ptr [rbx+0EC80h]
00007FF91DFDDBF4  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFDDBF8  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDDBFC  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFDDBFF  F3 0F 59 83 50 EC 00 00     mulss   xmm0, dword ptr [rbx+0EC50h]
00007FF91DFDDC07  F3 0F 58 93 60 EC 00 00     addss   xmm2, dword ptr [rbx+0EC60h]
00007FF91DFDDC0F  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFDDC13  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDDC17  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFDDC1A  F3 0F 59 83 30 EC 00 00     mulss   xmm0, dword ptr [rbx+0EC30h]
00007FF91DFDDC22  F3 0F 59 BB 10 EC 00 00     mulss   xmm7, dword ptr [rbx+0EC10h]
00007FF91DFDDC2A  F3 0F 58 93 40 EC 00 00     addss   xmm2, dword ptr [rbx+0EC40h]
00007FF91DFDDC32  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFDDC36  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDDC3A  F3 0F 58 93 20 EC 00 00     addss   xmm2, dword ptr [rbx+0EC20h]
00007FF91DFDDC42  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFDDC46  F3 0F 58 D7                 addss   xmm2, xmm7
00007FF91DFDDC4A  F3 41 0F 58 D5              addss   xmm2, xmm13
00007FF91DFDDC4F  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFDDC53  F3 0F 59 A3 00 EC 00 00     mulss   xmm4, dword ptr [rbx+0EC00h]
00007FF91DFDDC5B  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFDDC5E  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDDC62  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFDDC65  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFDDC69  F3 44 0F 59 83 50 ED 00 00  mulss   xmm8, dword ptr [rbx+0ED50h]
00007FF91DFDDC72  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDDC75  F3 0F 59 83 10 ED 00 00     mulss   xmm0, dword ptr [rbx+0ED10h]
00007FF91DFDDC7D  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFDDC80  F3 44 0F 58 83 30 ED 00 00  addss   xmm8, dword ptr [rbx+0ED30h]
00007FF91DFDDC89  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDDC8D  F3 0F 58 83 F0 EC 00 00     addss   xmm0, dword ptr [rbx+0ECF0h]
00007FF91DFDDC95  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFDDC99  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFDDC9E  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFDDCA3  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDDCA6  F3 0F 59 8B D0 EC 00 00     mulss   xmm1, dword ptr [rbx+0ECD0h]
00007FF91DFDDCAE  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDDCB2  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFDDCB7  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDDCBA  F3 0F 59 83 00 ED 00 00     mulss   xmm0, dword ptr [rbx+0ED00h]
00007FF91DFDDCC2  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFDDCC7  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFDDCCA  F3 0F 59 8B 40 ED 00 00     mulss   xmm1, dword ptr [rbx+0ED40h]
00007FF91DFDDCD2  F3 0F 59 9B C0 EC 00 00     mulss   xmm3, dword ptr [rbx+0ECC0h]
00007FF91DFDDCDA  F3 0F 58 8B 20 ED 00 00     addss   xmm1, dword ptr [rbx+0ED20h]
00007FF91DFDDCE2  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFDDCE7  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFDDCEB  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDDCEF  F3 0F 58 8B E0 EC 00 00     addss   xmm1, dword ptr [rbx+0ECE0h]
00007FF91DFDDCF7  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFDDCFB  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFDDCFF  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFDDD04  F3 44 0F 5E C1              divss   xmm8, xmm1
00007FF91DFDDD09  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFDDD0D  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDDD12  F3 44 0F 5E C0              divss   xmm8, xmm0
00007FF91DFDDD17  F3 44 0F 11 83 B0 EA 00 00  movss   dword ptr [rbx+0EAB0h], xmm8
00007FF91DFDDD20  EB 09                       jmp     short loc_7FF91DFDDD2B
00007FF91DFDDD22  F3 44 0F 10 83 B0 EA 00 00  movss   xmm8, dword ptr [rbx+0EAB0h]
00007FF91DFDDD2B  8B 83 C0 ED 00 00           mov     eax, [rbx+0EDC0h]
00007FF91DFDDD31  F3 0F 10 8B E0 E6 00 00     movss   xmm1, dword ptr [rbx+0E6E0h]
00007FF91DFDDD39  F3 44 0F 10 8B C0 EA 00 00  movss   xmm9, dword ptr [rbx+0EAC0h]
00007FF91DFDDD42  89 83 D0 ED 00 00           mov     [rbx+0EDD0h], eax
00007FF91DFDDD48  8B 83 B0 ED 00 00           mov     eax, [rbx+0EDB0h]
00007FF91DFDDD4E  89 83 C0 ED 00 00           mov     [rbx+0EDC0h], eax
00007FF91DFDDD54  8B 83 A0 ED 00 00           mov     eax, [rbx+0EDA0h]
00007FF91DFDDD5A  89 83 B0 ED 00 00           mov     [rbx+0EDB0h], eax
00007FF91DFDDD60  8B 83 90 ED 00 00           mov     eax, [rbx+0ED90h]
00007FF91DFDDD66  89 83 A0 ED 00 00           mov     [rbx+0EDA0h], eax
00007FF91DFDDD6C  8B 83 80 ED 00 00           mov     eax, [rbx+0ED80h]
00007FF91DFDDD72  89 83 90 ED 00 00           mov     [rbx+0ED90h], eax
00007FF91DFDDD78  8B 83 70 ED 00 00           mov     eax, [rbx+0ED70h]
00007FF91DFDDD7E  89 83 80 ED 00 00           mov     [rbx+0ED80h], eax
00007FF91DFDDD84  8B 83 60 ED 00 00           mov     eax, [rbx+0ED60h]
00007FF91DFDDD8A  89 83 70 ED 00 00           mov     [rbx+0ED70h], eax
00007FF91DFDDD90  8B 83 A0 EE 00 00           mov     eax, [rbx+0EEA0h]
00007FF91DFDDD96  89 83 B0 EE 00 00           mov     [rbx+0EEB0h], eax
00007FF91DFDDD9C  8B 83 90 EE 00 00           mov     eax, [rbx+0EE90h]
00007FF91DFDDDA2  89 83 A0 EE 00 00           mov     [rbx+0EEA0h], eax
00007FF91DFDDDA8  8B 83 80 EE 00 00           mov     eax, [rbx+0EE80h]
00007FF91DFDDDAE  89 83 90 EE 00 00           mov     [rbx+0EE90h], eax
00007FF91DFDDDB4  8B 83 70 EE 00 00           mov     eax, [rbx+0EE70h]
00007FF91DFDDDBA  89 83 80 EE 00 00           mov     [rbx+0EE80h], eax
00007FF91DFDDDC0  8B 83 60 EE 00 00           mov     eax, [rbx+0EE60h]
00007FF91DFDDDC6  89 83 70 EE 00 00           mov     [rbx+0EE70h], eax
00007FF91DFDDDCC  8B 83 50 EE 00 00           mov     eax, [rbx+0EE50h]
00007FF91DFDDDD2  89 83 60 EE 00 00           mov     [rbx+0EE60h], eax
00007FF91DFDDDD8  8B 83 40 EE 00 00           mov     eax, [rbx+0EE40h]
00007FF91DFDDDDE  89 83 50 EE 00 00           mov     [rbx+0EE50h], eax
00007FF91DFDDDE4  8B 83 20 EF 00 00           mov     eax, [rbx+0EF20h]
00007FF91DFDDDEA  89 83 30 EF 00 00           mov     [rbx+0EF30h], eax
00007FF91DFDDDF0  8B 83 10 EF 00 00           mov     eax, [rbx+0EF10h]
00007FF91DFDDDF6  89 83 20 EF 00 00           mov     [rbx+0EF20h], eax
00007FF91DFDDDFC  8B 83 00 EF 00 00           mov     eax, [rbx+0EF00h]
00007FF91DFDDE02  89 83 10 EF 00 00           mov     [rbx+0EF10h], eax
00007FF91DFDDE08  8B 83 F0 EE 00 00           mov     eax, [rbx+0EEF0h]
00007FF91DFDDE0E  89 83 00 EF 00 00           mov     [rbx+0EF00h], eax
00007FF91DFDDE14  8B 83 E0 EE 00 00           mov     eax, [rbx+0EEE0h]
00007FF91DFDDE1A  89 83 F0 EE 00 00           mov     [rbx+0EEF0h], eax
00007FF91DFDDE20  8B 83 D0 EE 00 00           mov     eax, [rbx+0EED0h]
00007FF91DFDDE26  89 83 E0 EE 00 00           mov     [rbx+0EEE0h], eax
00007FF91DFDDE2C  8B 83 C0 EE 00 00           mov     eax, [rbx+0EEC0h]
00007FF91DFDDE32  89 83 D0 EE 00 00           mov     [rbx+0EED0h], eax
00007FF91DFDDE38  8B 83 A0 EF 00 00           mov     eax, [rbx+0EFA0h]
00007FF91DFDDE3E  89 83 B0 EF 00 00           mov     [rbx+0EFB0h], eax
00007FF91DFDDE44  8B 83 90 EF 00 00           mov     eax, [rbx+0EF90h]
00007FF91DFDDE4A  89 83 A0 EF 00 00           mov     [rbx+0EFA0h], eax
00007FF91DFDDE50  8B 83 80 EF 00 00           mov     eax, [rbx+0EF80h]
00007FF91DFDDE56  89 83 90 EF 00 00           mov     [rbx+0EF90h], eax
00007FF91DFDDE5C  8B 83 70 EF 00 00           mov     eax, [rbx+0EF70h]
00007FF91DFDDE62  89 83 80 EF 00 00           mov     [rbx+0EF80h], eax
00007FF91DFDDE68  8B 83 60 EF 00 00           mov     eax, [rbx+0EF60h]
00007FF91DFDDE6E  89 83 70 EF 00 00           mov     [rbx+0EF70h], eax
00007FF91DFDDE74  8B 83 50 EF 00 00           mov     eax, [rbx+0EF50h]
00007FF91DFDDE7A  89 83 60 EF 00 00           mov     [rbx+0EF60h], eax
00007FF91DFDDE80  8B 83 40 EF 00 00           mov     eax, [rbx+0EF40h]
00007FF91DFDDE86  89 83 50 EF 00 00           mov     [rbx+0EF50h], eax
00007FF91DFDDE8C  8B 83 20 F0 00 00           mov     eax, [rbx+0F020h]
00007FF91DFDDE92  89 83 30 F0 00 00           mov     [rbx+0F030h], eax
00007FF91DFDDE98  8B 83 10 F0 00 00           mov     eax, [rbx+0F010h]
00007FF91DFDDE9E  89 83 20 F0 00 00           mov     [rbx+0F020h], eax
00007FF91DFDDEA4  8B 83 00 F0 00 00           mov     eax, [rbx+0F000h]
00007FF91DFDDEAA  89 83 10 F0 00 00           mov     [rbx+0F010h], eax
00007FF91DFDDEB0  8B 83 F0 EF 00 00           mov     eax, [rbx+0EFF0h]
00007FF91DFDDEB6  89 83 00 F0 00 00           mov     [rbx+0F000h], eax
00007FF91DFDDEBC  8B 83 E0 EF 00 00           mov     eax, [rbx+0EFE0h]
00007FF91DFDDEC2  89 83 F0 EF 00 00           mov     [rbx+0EFF0h], eax
00007FF91DFDDEC8  8B 83 D0 EF 00 00           mov     eax, [rbx+0EFD0h]
00007FF91DFDDECE  89 83 E0 EF 00 00           mov     [rbx+0EFE0h], eax
00007FF91DFDDED4  8B 83 C0 EF 00 00           mov     eax, [rbx+0EFC0h]
00007FF91DFDDEDA  89 83 D0 EF 00 00           mov     [rbx+0EFD0h], eax
00007FF91DFDDEE0  8B 83 40 F0 00 00           mov     eax, [rbx+0F040h]
00007FF91DFDDEE6  89 83 50 F0 00 00           mov     [rbx+0F050h], eax
00007FF91DFDDEEC  F3 0F 10 83 60 F0 00 00     movss   xmm0, dword ptr [rbx+0F060h]
00007FF91DFDDEF4  F3 0F 11 83 70 F0 00 00     movss   dword ptr [rbx+0F070h], xmm0
00007FF91DFDDEFC  44 0F 2E AB B0 F0 00 00     ucomiss xmm13, dword ptr [rbx+0F0B0h]
00007FF91DFDDF04  0F 85 49 09 00 00           jnz     loc_7FF91DFDE853
00007FF91DFDDF0A  F3 0F 59 8B 00 F1 00 00     mulss   xmm1, dword ptr [rbx+0F100h]
00007FF91DFDDF12  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFDDF16  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFDDF1A  41 0F 28 F8                 movaps  xmm7, xmm8
00007FF91DFDDF1E  F3 0F 59 B3 20 F1 00 00     mulss   xmm6, dword ptr [rbx+0F120h]
00007FF91DFDDF26  F3 41 0F 59 F8              mulss   xmm7, xmm8
00007FF91DFDDF2B  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDDF30  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFDDF34  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFDDF37  F3 0F 59 8B F0 F0 00 00     mulss   xmm1, dword ptr [rbx+0F0F0h]
00007FF91DFDDF3F  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFDDF43  E8 18 AE FE FF              call    sub_7FF91DFC8D60
00007FF91DFDDF48  F3 0F 11 83 60 F0 00 00     movss   dword ptr [rbx+0F060h], xmm0
00007FF91DFDDF50  41 0F 28 DD                 movaps  xmm3, xmm13
00007FF91DFDDF54  F3 0F 11 B3 40 F0 00 00     movss   dword ptr [rbx+0F040h], xmm6
00007FF91DFDDF5C  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFDDF60  F3 0F 59 FF                 mulss   xmm7, xmm7
00007FF91DFDDF64  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFDDF69  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFDDF6D  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFDDF72  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFDDF76  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDDF7B  F3 0F 5E DF                 divss   xmm3, xmm7
00007FF91DFDDF7F  F3 0F 11 9B 90 F0 00 00     movss   dword ptr [rbx+0F090h], xmm3
00007FF91DFDDF87  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFDDF8A  F3 0F 10 8B 40 F0 00 00     movss   xmm1, dword ptr [rbx+0F040h]
00007FF91DFDDF92  F3 0F 10 AB 50 F0 00 00     movss   xmm5, dword ptr [rbx+0F050h]
00007FF91DFDDF9A  F3 41 0F 59 E1              mulss   xmm4, xmm9
00007FF91DFDDF9F  F3 0F 11 A3 80 F0 00 00     movss   dword ptr [rbx+0F080h], xmm4
00007FF91DFDDFA7  F3 0F 59 AB 50 F1 00 00     mulss   xmm5, dword ptr [rbx+0F150h]
00007FF91DFDDFAF  F3 0F 10 93 C0 ED 00 00     movss   xmm2, dword ptr [rbx+0EDC0h]
00007FF91DFDDFB7  F3 0F 59 8B 60 F1 00 00     mulss   xmm1, dword ptr [rbx+0F160h]
00007FF91DFDDFBF  F3 0F 10 83 D0 ED 00 00     movss   xmm0, dword ptr [rbx+0EDD0h]
00007FF91DFDDFC7  F3 0F 11 93 30 EE 00 00     movss   dword ptr [rbx+0EE30h], xmm2
00007FF91DFDDFCF  F3 0F 59 93 80 F2 00 00     mulss   xmm2, dword ptr [rbx+0F280h]
00007FF91DFDDFD7  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDDFDB  F3 0F 59 83 90 F2 00 00     mulss   xmm0, dword ptr [rbx+0F290h]
00007FF91DFDDFE3  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFDDFE7  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDDFEB  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDDFEF  F3 0F 5C EA                 subss   xmm5, xmm2
00007FF91DFDDFF3  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDDFF7  73 06                       jnb     short loc_7FF91DFDDFFF
00007FF91DFDDFF9  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDDFFD  EB 05                       jmp     short loc_7FF91DFDE004
00007FF91DFDDFFF  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDE004  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFDE007  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDE00A  F3 0F 59 83 30 F1 00 00     mulss   xmm0, dword ptr [rbx+0F130h]
00007FF91DFDE012  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDE016  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE01A  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE01E  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE022  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFDE026  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDE02A  F3 0F 11 AB E0 ED 00 00     movss   dword ptr [rbx+0EDE0h], xmm5
00007FF91DFDE032  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDE035  F3 0F 58 AB 70 ED 00 00     addss   xmm5, dword ptr [rbx+0ED70h]
00007FF91DFDE03D  F3 0F 10 9B 80 ED 00 00     movss   xmm3, dword ptr [rbx+0ED80h]
00007FF91DFDE045  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDE048  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE04C  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDE050  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFDE054  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFDE058  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDE05C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE060  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE063  F3 0F 11 A3 F0 ED 00 00     movss   dword ptr [rbx+0EDF0h], xmm4
00007FF91DFDE06B  F3 0F 10 8B 90 ED 00 00     movss   xmm1, dword ptr [rbx+0ED90h]
00007FF91DFDE073  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFDE077  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDE07B  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDE07E  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE082  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFDE086  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDE08A  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFDE08E  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDE092  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDE096  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDE09A  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDE09E  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE0A1  F3 0F 11 9B 00 EE 00 00     movss   dword ptr [rbx+0EE00h], xmm3
00007FF91DFDE0A9  F3 0F 10 AB A0 ED 00 00     movss   xmm5, dword ptr [rbx+0EDA0h]
00007FF91DFDE0B1  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDE0B5  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE0B9  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDE0BC  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE0C0  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDE0C4  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDE0C8  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFDE0CC  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDE0D0  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDE0D4  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFDE0D8  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDE0DC  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE0DF  F3 0F 11 93 10 EE 00 00     movss   dword ptr [rbx+0EE10h], xmm2
00007FF91DFDE0E7  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFDE0EB  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDE0EF  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDE0F3  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFDE0F8  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE0FB  F3 0F 59 83 B0 ED 00 00     mulss   xmm0, dword ptr [rbx+0EDB0h]
00007FF91DFDE103  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDE107  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDE10B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE10E  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFDE112  F3 0F 11 AB 20 EE 00 00     movss   dword ptr [rbx+0EE20h], xmm5
00007FF91DFDE11A  F3 0F 10 93 10 EE 00 00     movss   xmm2, dword ptr [rbx+0EE10h]
00007FF91DFDE122  F3 0F 59 93 D0 F0 00 00     mulss   xmm2, dword ptr [rbx+0F0D0h]
00007FF91DFDE12A  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFDE12E  F3 0F 59 AB E0 F0 00 00     mulss   xmm5, dword ptr [rbx+0F0E0h]
00007FF91DFDE136  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE13A  F3 0F 10 83 C0 F0 00 00     movss   xmm0, dword ptr [rbx+0F0C0h]
00007FF91DFDE142  F3 0F 59 83 00 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE00h]
00007FF91DFDE14A  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFDE14E  F3 0F 10 AB 50 F0 00 00     movss   xmm5, dword ptr [rbx+0F050h]
00007FF91DFDE156  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDE15A  F3 0F 11 93 C0 EF 00 00     movss   dword ptr [rbx+0EFC0h], xmm2
00007FF91DFDE162  F3 0F 58 AB 40 F0 00 00     addss   xmm5, dword ptr [rbx+0F040h]
00007FF91DFDE16A  F3 0F 10 83 30 EE 00 00     movss   xmm0, dword ptr [rbx+0EE30h]
00007FF91DFDE172  F3 0F 59 AB 70 F1 00 00     mulss   xmm5, dword ptr [rbx+0F170h]
00007FF91DFDE17A  F3 0F 59 AB 90 F0 00 00     mulss   xmm5, dword ptr [rbx+0F090h]
00007FF91DFDE182  F3 0F 11 A3 30 EE 00 00     movss   dword ptr [rbx+0EE30h], xmm4
00007FF91DFDE18A  F3 0F 59 A3 80 F2 00 00     mulss   xmm4, dword ptr [rbx+0F280h]
00007FF91DFDE192  F3 0F 59 83 90 F2 00 00     mulss   xmm0, dword ptr [rbx+0F290h]
00007FF91DFDE19A  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE19E  F3 0F 59 A3 80 F0 00 00     mulss   xmm4, dword ptr [rbx+0F080h]
00007FF91DFDE1A6  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFDE1AA  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDE1AE  73 06                       jnb     short loc_7FF91DFDE1B6
00007FF91DFDE1B0  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDE1B4  EB 05                       jmp     short loc_7FF91DFDE1BB
00007FF91DFDE1B6  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDE1BB  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFDE1BE  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDE1C1  F3 0F 59 83 30 F1 00 00     mulss   xmm0, dword ptr [rbx+0F130h]
00007FF91DFDE1C9  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDE1CD  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE1D1  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE1D5  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE1D9  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFDE1DD  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDE1E1  F3 0F 10 8B E0 ED 00 00     movss   xmm1, dword ptr [rbx+0EDE0h]
00007FF91DFDE1E9  F3 0F 11 AB E0 ED 00 00     movss   dword ptr [rbx+0EDE0h], xmm5
00007FF91DFDE1F1  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDE1F4  F3 0F 10 9B F0 ED 00 00     movss   xmm3, dword ptr [rbx+0EDF0h]
00007FF91DFDE1FC  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDE200  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDE203  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE207  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDE20B  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFDE20F  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFDE213  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDE217  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE21B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE21E  F3 0F 11 A3 F0 ED 00 00     movss   dword ptr [rbx+0EDF0h], xmm4
00007FF91DFDE226  F3 0F 10 8B 00 EE 00 00     movss   xmm1, dword ptr [rbx+0EE00h]
00007FF91DFDE22E  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFDE232  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDE236  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDE239  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE23D  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFDE241  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDE245  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFDE249  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDE24D  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDE251  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDE255  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDE259  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE25C  F3 0F 11 9B 00 EE 00 00     movss   dword ptr [rbx+0EE00h], xmm3
00007FF91DFDE264  F3 0F 10 AB 10 EE 00 00     movss   xmm5, dword ptr [rbx+0EE10h]
00007FF91DFDE26C  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDE270  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE274  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDE277  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE27B  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDE27F  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDE283  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFDE287  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDE28B  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDE28F  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFDE293  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDE297  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE29A  F3 0F 11 93 10 EE 00 00     movss   dword ptr [rbx+0EE10h], xmm2
00007FF91DFDE2A2  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFDE2A6  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDE2AA  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDE2AE  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFDE2B3  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE2B6  F3 0F 59 83 20 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE20h]
00007FF91DFDE2BE  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDE2C2  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDE2C6  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE2C9  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFDE2CD  F3 0F 11 AB 20 EE 00 00     movss   dword ptr [rbx+0EE20h], xmm5
00007FF91DFDE2D5  F3 0F 10 93 10 EE 00 00     movss   xmm2, dword ptr [rbx+0EE10h]
00007FF91DFDE2DD  F3 0F 59 93 D0 F0 00 00     mulss   xmm2, dword ptr [rbx+0F0D0h]
00007FF91DFDE2E5  F3 0F 10 8B 40 F0 00 00     movss   xmm1, dword ptr [rbx+0F040h]
00007FF91DFDE2ED  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFDE2F1  F3 0F 59 AB E0 F0 00 00     mulss   xmm5, dword ptr [rbx+0F0E0h]
00007FF91DFDE2F9  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE2FD  F3 0F 10 83 C0 F0 00 00     movss   xmm0, dword ptr [rbx+0F0C0h]
00007FF91DFDE305  F3 0F 59 83 00 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE00h]
00007FF91DFDE30D  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFDE311  F3 0F 10 AB 50 F0 00 00     movss   xmm5, dword ptr [rbx+0F050h]
00007FF91DFDE319  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDE31D  F3 0F 11 93 40 EF 00 00     movss   dword ptr [rbx+0EF40h], xmm2
00007FF91DFDE325  F3 0F 59 AB 60 F1 00 00     mulss   xmm5, dword ptr [rbx+0F160h]
00007FF91DFDE32D  F3 0F 59 8B 50 F1 00 00     mulss   xmm1, dword ptr [rbx+0F150h]
00007FF91DFDE335  F3 0F 10 83 30 EE 00 00     movss   xmm0, dword ptr [rbx+0EE30h]
00007FF91DFDE33D  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDE341  F3 0F 59 AB 90 F0 00 00     mulss   xmm5, dword ptr [rbx+0F090h]
00007FF91DFDE349  F3 0F 11 A3 30 EE 00 00     movss   dword ptr [rbx+0EE30h], xmm4
00007FF91DFDE351  F3 0F 59 A3 80 F2 00 00     mulss   xmm4, dword ptr [rbx+0F280h]
00007FF91DFDE359  F3 0F 59 83 90 F2 00 00     mulss   xmm0, dword ptr [rbx+0F290h]
00007FF91DFDE361  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE365  F3 0F 59 A3 80 F0 00 00     mulss   xmm4, dword ptr [rbx+0F080h]
00007FF91DFDE36D  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFDE371  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDE375  73 06                       jnb     short loc_7FF91DFDE37D
00007FF91DFDE377  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDE37B  EB 05                       jmp     short loc_7FF91DFDE382
00007FF91DFDE37D  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDE382  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFDE385  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDE388  F3 0F 59 83 30 F1 00 00     mulss   xmm0, dword ptr [rbx+0F130h]
00007FF91DFDE390  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDE394  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE398  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE39C  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE3A0  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFDE3A4  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDE3A8  F3 0F 10 8B E0 ED 00 00     movss   xmm1, dword ptr [rbx+0EDE0h]
00007FF91DFDE3B0  F3 0F 11 AB E0 ED 00 00     movss   dword ptr [rbx+0EDE0h], xmm5
00007FF91DFDE3B8  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDE3BB  F3 0F 10 9B F0 ED 00 00     movss   xmm3, dword ptr [rbx+0EDF0h]
00007FF91DFDE3C3  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDE3C7  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDE3CA  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE3CE  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDE3D2  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFDE3D6  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFDE3DA  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDE3DE  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE3E2  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE3E5  F3 0F 11 A3 F0 ED 00 00     movss   dword ptr [rbx+0EDF0h], xmm4
00007FF91DFDE3ED  F3 0F 10 8B 00 EE 00 00     movss   xmm1, dword ptr [rbx+0EE00h]
00007FF91DFDE3F5  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFDE3F9  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDE3FD  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDE400  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE404  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFDE408  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDE40C  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFDE410  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDE414  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDE418  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDE41C  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDE420  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE423  F3 0F 11 9B 00 EE 00 00     movss   dword ptr [rbx+0EE00h], xmm3
00007FF91DFDE42B  F3 0F 10 AB 10 EE 00 00     movss   xmm5, dword ptr [rbx+0EE10h]
00007FF91DFDE433  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDE437  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE43B  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDE43E  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE442  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDE446  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDE44A  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFDE44E  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDE452  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFDE456  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFDE45A  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDE45E  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE461  F3 0F 11 93 10 EE 00 00     movss   dword ptr [rbx+0EE10h], xmm2
00007FF91DFDE469  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFDE46D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDE471  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDE475  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFDE47A  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE47D  F3 0F 59 83 20 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE20h]
00007FF91DFDE485  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDE489  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDE48D  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE490  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFDE494  F3 0F 11 AB 20 EE 00 00     movss   dword ptr [rbx+0EE20h], xmm5
00007FF91DFDE49C  F3 0F 10 8B 10 EE 00 00     movss   xmm1, dword ptr [rbx+0EE10h]
00007FF91DFDE4A4  F3 0F 59 8B D0 F0 00 00     mulss   xmm1, dword ptr [rbx+0F0D0h]
00007FF91DFDE4AC  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFDE4B0  F3 0F 59 AB E0 F0 00 00     mulss   xmm5, dword ptr [rbx+0F0E0h]
00007FF91DFDE4B8  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDE4BC  F3 0F 10 83 C0 F0 00 00     movss   xmm0, dword ptr [rbx+0F0C0h]
00007FF91DFDE4C4  F3 0F 59 83 00 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE00h]
00007FF91DFDE4CC  F3 0F 58 CD                 addss   xmm1, xmm5
00007FF91DFDE4D0  F3 0F 10 AB 40 F0 00 00     movss   xmm5, dword ptr [rbx+0F040h]
00007FF91DFDE4D8  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDE4DC  F3 0F 11 8B C0 EE 00 00     movss   dword ptr [rbx+0EEC0h], xmm1
00007FF91DFDE4E4  F3 0F 59 AB 40 F1 00 00     mulss   xmm5, dword ptr [rbx+0F140h]
00007FF91DFDE4EC  F3 0F 10 83 30 EE 00 00     movss   xmm0, dword ptr [rbx+0EE30h]
00007FF91DFDE4F4  F3 0F 59 AB 90 F0 00 00     mulss   xmm5, dword ptr [rbx+0F090h]
00007FF91DFDE4FC  F3 0F 11 9B C0 ED 00 00     movss   dword ptr [rbx+0EDC0h], xmm3
00007FF91DFDE504  F3 0F 59 9B 80 F2 00 00     mulss   xmm3, dword ptr [rbx+0F280h]
00007FF91DFDE50C  F3 0F 59 83 90 F2 00 00     mulss   xmm0, dword ptr [rbx+0F290h]
00007FF91DFDE514  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDE518  F3 0F 59 9B 80 F0 00 00     mulss   xmm3, dword ptr [rbx+0F080h]
00007FF91DFDE520  F3 0F 5C EB                 subss   xmm5, xmm3
00007FF91DFDE524  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDE528  73 06                       jnb     short loc_7FF91DFDE530
00007FF91DFDE52A  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDE52E  EB 05                       jmp     short loc_7FF91DFDE535
00007FF91DFDE530  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDE535  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFDE538  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDE53B  F3 0F 59 83 30 F1 00 00     mulss   xmm0, dword ptr [rbx+0F130h]
00007FF91DFDE543  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDE547  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE54B  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE54F  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDE553  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFDE557  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDE55B  F3 0F 11 AB 60 ED 00 00     movss   dword ptr [rbx+0ED60h], xmm5
00007FF91DFDE563  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDE566  F3 0F 58 AB E0 ED 00 00     addss   xmm5, dword ptr [rbx+0EDE0h]
00007FF91DFDE56E  F3 0F 10 9B F0 ED 00 00     movss   xmm3, dword ptr [rbx+0EDF0h]
00007FF91DFDE576  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDE579  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE57D  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDE581  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFDE585  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFDE589  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDE58D  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE591  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE594  F3 0F 11 A3 70 ED 00 00     movss   dword ptr [rbx+0ED70h], xmm4
00007FF91DFDE59C  F3 0F 10 8B 00 EE 00 00     movss   xmm1, dword ptr [rbx+0EE00h]
00007FF91DFDE5A4  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFDE5A8  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDE5AC  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDE5AF  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE5B3  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFDE5B7  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDE5BB  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFDE5BF  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDE5C3  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDE5C7  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDE5CB  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDE5CF  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE5D2  F3 0F 11 9B 80 ED 00 00     movss   dword ptr [rbx+0ED80h], xmm3
00007FF91DFDE5DA  F3 0F 10 AB 10 EE 00 00     movss   xmm5, dword ptr [rbx+0EE10h]
00007FF91DFDE5E2  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDE5E6  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE5EA  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDE5ED  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDE5F1  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDE5F5  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDE5F9  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFDE5FD  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDE601  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFDE605  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDE609  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE60C  F3 0F 11 93 90 ED 00 00     movss   dword ptr [rbx+0ED90h], xmm2
00007FF91DFDE614  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFDE618  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDE61C  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDE620  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFDE625  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDE628  F3 0F 59 83 20 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE20h]
00007FF91DFDE630  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDE634  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDE638  F3 44 0F 59 C1              mulss   xmm8, xmm1
00007FF91DFDE63D  F3 0F 11 AB A0 ED 00 00     movss   dword ptr [rbx+0EDA0h], xmm5
00007FF91DFDE645  F3 0F 10 9B 80 ED 00 00     movss   xmm3, dword ptr [rbx+0ED80h]
00007FF91DFDE64D  F3 0F 59 F5                 mulss   xmm6, xmm5
00007FF91DFDE651  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFDE656  F3 44 0F 11 83 B0 ED 00 00  movss   dword ptr [rbx+0EDB0h], xmm8
00007FF91DFDE65F  F3 0F 10 83 D0 F0 00 00     movss   xmm0, dword ptr [rbx+0F0D0h]
00007FF91DFDE667  F3 0F 59 83 90 ED 00 00     mulss   xmm0, dword ptr [rbx+0ED90h]
00007FF91DFDE66F  F3 0F 59 AB E0 F0 00 00     mulss   xmm5, dword ptr [rbx+0F0E0h]
00007FF91DFDE677  F3 0F 59 9B C0 F0 00 00     mulss   xmm3, dword ptr [rbx+0F0C0h]
00007FF91DFDE67F  F3 0F 10 A3 80 EE 00 00     movss   xmm4, dword ptr [rbx+0EE80h]
00007FF91DFDE687  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDE68B  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFDE68F  F3 0F 11 AB 40 EE 00 00     movss   dword ptr [rbx+0EE40h], xmm5
00007FF91DFDE697  F3 0F 58 A3 F0 EF 00 00     addss   xmm4, dword ptr [rbx+0EFF0h]
00007FF91DFDE69F  F3 0F 10 83 00 EF 00 00     movss   xmm0, dword ptr [rbx+0EF00h]
00007FF91DFDE6A7  F3 0F 58 83 70 EF 00 00     addss   xmm0, dword ptr [rbx+0EF70h]
00007FF91DFDE6AF  F3 0F 10 8B 80 EF 00 00     movss   xmm1, dword ptr [rbx+0EF80h]
00007FF91DFDE6B7  F3 0F 58 8B F0 EE 00 00     addss   xmm1, dword ptr [rbx+0EEF0h]
00007FF91DFDE6BF  F3 0F 59 A3 70 F2 00 00     mulss   xmm4, dword ptr [rbx+0F270h]
00007FF91DFDE6C7  F3 0F 59 83 60 F2 00 00     mulss   xmm0, dword ptr [rbx+0F260h]
00007FF91DFDE6CF  F3 0F 59 8B 50 F2 00 00     mulss   xmm1, dword ptr [rbx+0F250h]
00007FF91DFDE6D7  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE6DB  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDE6DF  F3 0F 10 83 70 EE 00 00     movss   xmm0, dword ptr [rbx+0EE70h]
00007FF91DFDE6E7  F3 0F 58 83 00 F0 00 00     addss   xmm0, dword ptr [rbx+0F000h]
00007FF91DFDE6EF  F3 0F 10 8B E0 EF 00 00     movss   xmm1, dword ptr [rbx+0EFE0h]
00007FF91DFDE6F7  F3 0F 58 8B 90 EE 00 00     addss   xmm1, dword ptr [rbx+0EE90h]
00007FF91DFDE6FF  F3 0F 58 AB 30 F0 00 00     addss   xmm5, dword ptr [rbx+0F030h]
00007FF91DFDE707  F3 0F 59 83 40 F2 00 00     mulss   xmm0, dword ptr [rbx+0F240h]
00007FF91DFDE70F  F3 0F 59 8B 30 F2 00 00     mulss   xmm1, dword ptr [rbx+0F230h]
00007FF91DFDE717  F3 0F 59 AB 80 F1 00 00     mulss   xmm5, dword ptr [rbx+0F180h]
00007FF91DFDE71F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE723  F3 0F 10 83 60 EF 00 00     movss   xmm0, dword ptr [rbx+0EF60h]
00007FF91DFDE72B  F3 0F 58 83 10 EF 00 00     addss   xmm0, dword ptr [rbx+0EF10h]
00007FF91DFDE733  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDE737  F3 0F 10 8B 90 EF 00 00     movss   xmm1, dword ptr [rbx+0EF90h]
00007FF91DFDE73F  F3 0F 58 8B E0 EE 00 00     addss   xmm1, dword ptr [rbx+0EEE0h]
00007FF91DFDE747  F3 0F 59 83 20 F2 00 00     mulss   xmm0, dword ptr [rbx+0F220h]
00007FF91DFDE74F  F3 0F 59 8B 10 F2 00 00     mulss   xmm1, dword ptr [rbx+0F210h]
00007FF91DFDE757  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE75B  F3 0F 10 83 10 F0 00 00     movss   xmm0, dword ptr [rbx+0F010h]
00007FF91DFDE763  F3 0F 58 83 60 EE 00 00     addss   xmm0, dword ptr [rbx+0EE60h]
00007FF91DFDE76B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDE76F  F3 0F 10 8B D0 EF 00 00     movss   xmm1, dword ptr [rbx+0EFD0h]
00007FF91DFDE777  F3 0F 59 83 00 F2 00 00     mulss   xmm0, dword ptr [rbx+0F200h]
00007FF91DFDE77F  F3 0F 58 8B A0 EE 00 00     addss   xmm1, dword ptr [rbx+0EEA0h]
00007FF91DFDE787  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE78B  F3 0F 10 83 50 EF 00 00     movss   xmm0, dword ptr [rbx+0EF50h]
00007FF91DFDE793  F3 0F 58 83 20 EF 00 00     addss   xmm0, dword ptr [rbx+0EF20h]
00007FF91DFDE79B  F3 0F 59 8B F0 F1 00 00     mulss   xmm1, dword ptr [rbx+0F1F0h]
00007FF91DFDE7A3  F3 0F 59 83 E0 F1 00 00     mulss   xmm0, dword ptr [rbx+0F1E0h]
00007FF91DFDE7AB  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDE7AF  F3 0F 10 8B A0 EF 00 00     movss   xmm1, dword ptr [rbx+0EFA0h]
00007FF91DFDE7B7  F3 0F 58 8B D0 EE 00 00     addss   xmm1, dword ptr [rbx+0EED0h]
00007FF91DFDE7BF  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE7C3  F3 0F 10 83 20 F0 00 00     movss   xmm0, dword ptr [rbx+0F020h]
00007FF91DFDE7CB  F3 0F 59 8B D0 F1 00 00     mulss   xmm1, dword ptr [rbx+0F1D0h]
00007FF91DFDE7D3  F3 0F 58 83 50 EE 00 00     addss   xmm0, dword ptr [rbx+0EE50h]
00007FF91DFDE7DB  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDE7DF  F3 0F 10 8B C0 EF 00 00     movss   xmm1, dword ptr [rbx+0EFC0h]
00007FF91DFDE7E7  F3 0F 58 8B B0 EE 00 00     addss   xmm1, dword ptr [rbx+0EEB0h]
00007FF91DFDE7EF  F3 0F 59 83 C0 F1 00 00     mulss   xmm0, dword ptr [rbx+0F1C0h]
00007FF91DFDE7F7  F3 0F 59 8B B0 F1 00 00     mulss   xmm1, dword ptr [rbx+0F1B0h]
00007FF91DFDE7FF  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE803  F3 0F 10 83 40 EF 00 00     movss   xmm0, dword ptr [rbx+0EF40h]
00007FF91DFDE80B  F3 0F 58 83 30 EF 00 00     addss   xmm0, dword ptr [rbx+0EF30h]
00007FF91DFDE813  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDE817  F3 0F 10 8B B0 EF 00 00     movss   xmm1, dword ptr [rbx+0EFB0h]
00007FF91DFDE81F  F3 0F 59 83 A0 F1 00 00     mulss   xmm0, dword ptr [rbx+0F1A0h]
00007FF91DFDE827  F3 0F 58 8B C0 EE 00 00     addss   xmm1, dword ptr [rbx+0EEC0h]
00007FF91DFDE82F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDE833  F3 0F 59 8B 90 F1 00 00     mulss   xmm1, dword ptr [rbx+0F190h]
00007FF91DFDE83B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDE83F  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFDE843  F3 0F 59 A3 10 F1 00 00     mulss   xmm4, dword ptr [rbx+0F110h]
00007FF91DFDE84B  F3 0F 11 A3 A0 F0 00 00     movss   dword ptr [rbx+0F0A0h], xmm4
00007FF91DFDE853  8B 83 A0 F2 00 00           mov     eax, [rbx+0F2A0h]
00007FF91DFDE859  89 83 B0 F2 00 00           mov     [rbx+0F2B0h], eax
00007FF91DFDE85F  F3 0F 10 83 D0 F2 00 00     movss   xmm0, dword ptr [rbx+0F2D0h]
00007FF91DFDE867  8B 83 C0 F2 00 00           mov     eax, [rbx+0F2C0h]
00007FF91DFDE86D  89 83 F0 F2 00 00           mov     [rbx+0F2F0h], eax
00007FF91DFDE873  F3 0F 11 83 00 F3 00 00     movss   dword ptr [rbx+0F300h], xmm0
00007FF91DFDE87B  8B 83 E0 F2 00 00           mov     eax, [rbx+0F2E0h]
00007FF91DFDE881  89 83 10 F3 00 00           mov     [rbx+0F310h], eax
00007FF91DFDE887  F3 0F 10 93 20 F3 00 00     movss   xmm2, dword ptr [rbx+0F320h]
00007FF91DFDE88F  F3 0F 11 93 30 F3 00 00     movss   dword ptr [rbx+0F330h], xmm2
00007FF91DFDE897  F3 0F 10 83 40 F3 00 00     movss   xmm0, dword ptr [rbx+0F340h]
00007FF91DFDE89F  F3 0F 11 83 50 F3 00 00     movss   dword ptr [rbx+0F350h], xmm0
00007FF91DFDE8A7  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFDE8AB  F3 0F 59 93 60 F3 00 00     mulss   xmm2, dword ptr [rbx+0F360h]
00007FF91DFDE8B3  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDE8B7  F3 0F 11 93 40 F3 00 00     movss   dword ptr [rbx+0F340h], xmm2
00007FF91DFDE8BF  F3 0F 10 83 00 F3 00 00     movss   xmm0, dword ptr [rbx+0F300h]
00007FF91DFDE8C7  F3 0F 10 8B 10 F3 00 00     movss   xmm1, dword ptr [rbx+0F310h]
00007FF91DFDE8CF  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFDE8D3  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDE8D7  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFDE8DB  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFDE8DF  F3 0F 11 93 70 F3 00 00     movss   dword ptr [rbx+0F370h], xmm2
00007FF91DFDE8E7  F3 0F 10 8B 80 F3 00 00     movss   xmm1, dword ptr [rbx+0F380h]
00007FF91DFDE8EF  F3 0F 11 8B 90 F3 00 00     movss   dword ptr [rbx+0F390h], xmm1
00007FF91DFDE8F7  F3 0F 10 83 A0 F3 00 00     movss   xmm0, dword ptr [rbx+0F3A0h]
00007FF91DFDE8FF  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFDE902  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDE906  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFDE90A  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDE90E  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDE912  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFDE916  76 05                       jbe     short loc_7FF91DFDE91D
00007FF91DFDE918  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFDE91B  EB 03                       jmp     short loc_7FF91DFDE920
00007FF91DFDE91D  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDE920  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFDE924  F3 0F 11 83 80 F3 00 00     movss   dword ptr [rbx+0F380h], xmm0
00007FF91DFDE92C  F3 0F 10 8B B0 F3 00 00     movss   xmm1, dword ptr [rbx+0F3B0h]
00007FF91DFDE934  F3 0F 11 8B C0 F3 00 00     movss   dword ptr [rbx+0F3C0h], xmm1
00007FF91DFDE93C  F3 0F 10 93 D0 F3 00 00     movss   xmm2, dword ptr [rbx+0F3D0h]
00007FF91DFDE944  F3 0F 11 93 E0 F3 00 00     movss   dword ptr [rbx+0F3E0h], xmm2
00007FF91DFDE94C  F3 0F 10 83 F0 F3 00 00     movss   xmm0, dword ptr [rbx+0F3F0h]
00007FF91DFDE954  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFDE957  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDE95B  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFDE95F  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDE963  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFDE967  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFDE96B  76 05                       jbe     short loc_7FF91DFDE972
00007FF91DFDE96D  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFDE970  EB 03                       jmp     short loc_7FF91DFDE975
00007FF91DFDE972  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDE975  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFDE979  F3 0F 11 83 D0 F3 00 00     movss   dword ptr [rbx+0F3D0h], xmm0
00007FF91DFDE981  F3 0F 10 AB 00 F4 00 00     movss   xmm5, dword ptr [rbx+0F400h]
00007FF91DFDE989  F3 0F 10 B3 80 CF 00 00     movss   xmm6, dword ptr [rbx+0CF80h]
00007FF91DFDE991  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFDE994  F3 0F 11 AB 10 F4 00 00     movss   dword ptr [rbx+0F410h], xmm5
00007FF91DFDE99C  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDE99F  F3 0F 59 A3 60 F4 00 00     mulss   xmm4, dword ptr [rbx+0F460h]
00007FF91DFDE9A7  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFDE9AA  F3 0F 58 83 30 F4 00 00     addss   xmm0, dword ptr [rbx+0F430h]
00007FF91DFDE9B2  F3 0F 58 9B 50 F4 00 00     addss   xmm3, dword ptr [rbx+0F450h]
00007FF91DFDE9BA  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFDE9BE  73 06                       jnb     short loc_7FF91DFDE9C6
00007FF91DFDE9C0  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFDE9C4  EB 05                       jmp     short loc_7FF91DFDE9CB
00007FF91DFDE9C6  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFDE9CB  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDE9CF  72 1B                       jb      short loc_7FF91DFDE9EC
00007FF91DFDE9D1  F3 0F 10 83 40 F4 00 00     movss   xmm0, dword ptr [rbx+0F440h]
00007FF91DFDE9D9  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFDE9DC  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFDE9E0  F3 0F 59 DE                 mulss   xmm3, xmm6
00007FF91DFDE9E4  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDE9E8  F3 0F 58 DD                 addss   xmm3, xmm5
00007FF91DFDE9EC  41 0F 2E F6                 ucomiss xmm6, xmm14
00007FF91DFDE9F0  F3 0F 10 8B 80 F4 00 00     movss   xmm1, dword ptr [rbx+0F480h]
00007FF91DFDE9F8  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFDE9FB  F3 0F 59 93 70 F4 00 00     mulss   xmm2, dword ptr [rbx+0F470h]
00007FF91DFDEA03  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDEA06  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFDEA0A  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFDEA0E  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFDEA12  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDEA15  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDEA19  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDEA1D  F3 0F 5C C2                 subss   xmm0, xmm2
00007FF91DFDEA21  F3 0F 58 C5                 addss   xmm0, xmm5
00007FF91DFDEA25  74 03                       jz      short loc_7FF91DFDEA2A
00007FF91DFDEA27  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDEA2A  F3 0F 11 83 20 F4 00 00     movss   dword ptr [rbx+0F420h], xmm0
00007FF91DFDEA32  F3 0F 11 83 00 F4 00 00     movss   dword ptr [rbx+0F400h], xmm0
00007FF91DFDEA3A  F3 0F 10 BB A0 F0 00 00     movss   xmm7, dword ptr [rbx+0F0A0h]
00007FF91DFDEA42  F3 0F 10 B3 10 D8 00 00     movss   xmm6, dword ptr [rbx+0D810h]
00007FF91DFDEA4A  F3 0F 10 9B 10 E8 00 00     movss   xmm3, dword ptr [rbx+0E810h]
00007FF91DFDEA52  F3 0F 10 83 F0 D9 00 00     movss   xmm0, dword ptr [rbx+0D9F0h]
00007FF91DFDEA5A  F3 0F 10 8B A0 F2 00 00     movss   xmm1, dword ptr [rbx+0F2A0h]
00007FF91DFDEA62  8B 83 C0 F4 00 00           mov     eax, [rbx+0F4C0h]
00007FF91DFDEA68  89 83 D0 F4 00 00           mov     [rbx+0F4D0h], eax
00007FF91DFDEA6E  8B 83 E0 F4 00 00           mov     eax, [rbx+0F4E0h]
00007FF91DFDEA74  89 83 F0 F4 00 00           mov     [rbx+0F4F0h], eax
00007FF91DFDEA7A  F3 0F 11 83 90 F4 00 00     movss   dword ptr [rbx+0F490h], xmm0
00007FF91DFDEA82  F3 0F 11 8B A0 F4 00 00     movss   dword ptr [rbx+0F4A0h], xmm1
00007FF91DFDEA8A  F3 0F 59 9B B0 F5 00 00     mulss   xmm3, dword ptr [rbx+0F5B0h]
00007FF91DFDEA92  F3 0F 10 A3 D0 F4 00 00     movss   xmm4, dword ptr [rbx+0F4D0h]
00007FF91DFDEA9A  F3 0F 10 93 10 F5 00 00     movss   xmm2, dword ptr [rbx+0F510h]
00007FF91DFDEAA2  F3 0F 11 9B B0 F4 00 00     movss   dword ptr [rbx+0F4B0h], xmm3
00007FF91DFDEAAA  0F 28 DF                    movaps  xmm3, xmm7
00007FF91DFDEAAD  F3 0F 59 B3 20 F5 00 00     mulss   xmm6, dword ptr [rbx+0F520h]
00007FF91DFDEAB5  F3 0F 5C DC                 subss   xmm3, xmm4
00007FF91DFDEAB9  F3 0F 59 93 20 F4 00 00     mulss   xmm2, dword ptr [rbx+0F420h]
00007FF91DFDEAC1  F3 0F 10 8B 30 F5 00 00     movss   xmm1, dword ptr [rbx+0F530h]
00007FF91DFDEAC9  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDEACC  F3 0F 59 83 50 F5 00 00     mulss   xmm0, dword ptr [rbx+0F550h]
00007FF91DFDEAD4  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFDEAD8  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDEADC  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFDEAE0  F3 0F 11 A3 C0 F4 00 00     movss   dword ptr [rbx+0F4C0h], xmm4
00007FF91DFDEAE8  F3 0F 59 8B 90 F4 00 00     mulss   xmm1, dword ptr [rbx+0F490h]
00007FF91DFDEAF0  F3 0F 10 93 40 F5 00 00     movss   xmm2, dword ptr [rbx+0F540h]
00007FF91DFDEAF8  F3 0F 59 9B C0 F5 00 00     mulss   xmm3, dword ptr [rbx+0F5C0h]
00007FF91DFDEB00  F3 0F 59 A3 D0 F5 00 00     mulss   xmm4, dword ptr [rbx+0F5D0h]
00007FF91DFDEB08  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFDEB0C  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDEB0F  F3 0F 59 8B A0 F4 00 00     mulss   xmm1, dword ptr [rbx+0F4A0h]
00007FF91DFDEB17  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFDEB1B  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFDEB1F  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFDEB23  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFDEB27  F3 0F 10 B3 60 F5 00 00     movss   xmm6, dword ptr [rbx+0F560h]
00007FF91DFDEB2F  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFDEB33  F3 0F 59 8B 90 F5 00 00     mulss   xmm1, dword ptr [rbx+0F590h]
00007FF91DFDEB3B  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFDEB3F  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFDEB43  76 05                       jbe     short loc_7FF91DFDEB4A
00007FF91DFDEB45  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFDEB48  EB 03                       jmp     short loc_7FF91DFDEB4D
00007FF91DFDEB4A  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDEB4D  F3 0F 10 93 80 F5 00 00     movss   xmm2, dword ptr [rbx+0F580h]
00007FF91DFDEB55  F3 0F 10 A3 70 F5 00 00     movss   xmm4, dword ptr [rbx+0F570h]
00007FF91DFDEB5D  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFDEB61  F3 0F 10 83 B0 F4 00 00     movss   xmm0, dword ptr [rbx+0F4B0h]
00007FF91DFDEB69  F3 0F 59 AB A0 F5 00 00     mulss   xmm5, dword ptr [rbx+0F5A0h]
00007FF91DFDEB71  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDEB76  F3 0F 59 F3                 mulss   xmm6, xmm3
00007FF91DFDEB7A  F3 0F 10 9B F0 F4 00 00     movss   xmm3, dword ptr [rbx+0F4F0h]
00007FF91DFDEB82  F3 0F 58 F7                 addss   xmm6, xmm7
00007FF91DFDEB86  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFDEB8A  F3 0F 10 83 E0 F5 00 00     movss   xmm0, dword ptr [rbx+0F5E0h]
00007FF91DFDEB92  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFDEB95  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDEB99  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFDEB9D  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFDEBA1  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFDEBA5  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDEBA9  F3 0F 11 9B E0 F4 00 00     movss   dword ptr [rbx+0F4E0h], xmm3
00007FF91DFDEBB1  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFDEBB5  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFDEBB9  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDEBBD  F3 0F 59 A3 F0 F5 00 00     mulss   xmm4, dword ptr [rbx+0F5F0h]
00007FF91DFDEBC5  F3 0F 11 A3 00 F5 00 00     movss   dword ptr [rbx+0F500h], xmm4
00007FF91DFDEBCD  8B 83 10 F6 00 00           mov     eax, [rbx+0F610h]
00007FF91DFDEBD3  89 83 20 F6 00 00           mov     [rbx+0F620h], eax
00007FF91DFDEBD9  8B 83 00 F6 00 00           mov     eax, [rbx+0F600h]
00007FF91DFDEBDF  89 83 10 F6 00 00           mov     [rbx+0F610h], eax
00007FF91DFDEBE5  F3 0F 10 83 20 F6 00 00     movss   xmm0, dword ptr [rbx+0F620h]
00007FF91DFDEBED  F3 0F 10 8B 30 F6 00 00     movss   xmm1, dword ptr [rbx+0F630h]
00007FF91DFDEBF5  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFDEBF9  F3 0F 11 A3 00 F6 00 00     movss   dword ptr [rbx+0F600h], xmm4
00007FF91DFDEC01  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDEC05  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDEC09  F3 0F 11 8B 10 F6 00 00     movss   dword ptr [rbx+0F610h], xmm1
00007FF91DFDEC11  F3 0F 10 93 00 F6 00 00     movss   xmm2, dword ptr [rbx+0F600h]
00007FF91DFDEC19  F3 0F 10 B3 F0 F2 00 00     movss   xmm6, dword ptr [rbx+0F2F0h]
00007FF91DFDEC21  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDEC24  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFDEC28  8B 83 60 F6 00 00           mov     eax, [rbx+0F660h]
00007FF91DFDEC2E  89 83 70 F6 00 00           mov     [rbx+0F670h], eax
00007FF91DFDEC34  8B 83 50 F6 00 00           mov     eax, [rbx+0F650h]
00007FF91DFDEC3A  89 83 60 F6 00 00           mov     [rbx+0F660h], eax
00007FF91DFDEC40  8B 83 40 F6 00 00           mov     eax, [rbx+0F640h]
00007FF91DFDEC46  89 83 50 F6 00 00           mov     [rbx+0F650h], eax
00007FF91DFDEC4C  F3 0F 11 93 40 F6 00 00     movss   dword ptr [rbx+0F640h], xmm2
00007FF91DFDEC54  F3 0F 59 83 90 F6 00 00     mulss   xmm0, dword ptr [rbx+0F690h]
00007FF91DFDEC5C  F3 0F 10 A3 50 F6 00 00     movss   xmm4, dword ptr [rbx+0F650h]
00007FF91DFDEC64  F3 0F 10 8B B0 F6 00 00     movss   xmm1, dword ptr [rbx+0F6B0h]
00007FF91DFDEC6C  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFDEC6F  F3 0F 59 8B 60 F6 00 00     mulss   xmm1, dword ptr [rbx+0F660h]
00007FF91DFDEC77  F3 0F 59 AB A0 F6 00 00     mulss   xmm5, dword ptr [rbx+0F6A0h]
00007FF91DFDEC7F  F3 0F 59 A3 D0 F6 00 00     mulss   xmm4, dword ptr [rbx+0F6D0h]
00007FF91DFDEC87  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDEC8B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDEC8E  F3 0F 59 83 C0 F6 00 00     mulss   xmm0, dword ptr [rbx+0F6C0h]
00007FF91DFDEC96  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDEC9A  F3 0F 10 8B E0 F6 00 00     movss   xmm1, dword ptr [rbx+0F6E0h]
00007FF91DFDECA2  F3 0F 59 8B 70 F6 00 00     mulss   xmm1, dword ptr [rbx+0F670h]
00007FF91DFDECAA  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDECAE  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDECB2  76 05                       jbe     short loc_7FF91DFDECB9
00007FF91DFDECB4  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFDECB7  EB 03                       jmp     short loc_7FF91DFDECBC
00007FF91DFDECB9  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDECBC  0F 2F 35 FD 67 76 00        comiss  xmm6, cs:dword_7FF91E7454C0
00007FF91DFDECC3  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFDECC7  F3 0F 11 AB 50 F6 00 00     movss   dword ptr [rbx+0F650h], xmm5
00007FF91DFDECCF  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFDECD2  F3 0F 11 A3 60 F6 00 00     movss   dword ptr [rbx+0F660h], xmm4
00007FF91DFDECDA  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDECDE  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDECE2  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDECE6  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDECE9  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFDECED  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFDECF1  73 09                       jnb     short loc_7FF91DFDECFC
00007FF91DFDECF3  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFDECF7  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
00007FF91DFDECFC  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFDED00  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
00007FF91DFDED05  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFDED08  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDED0C  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDED10  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFDED14  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFDED18  72 03                       jb      short loc_7FF91DFDED1D
00007FF91DFDED1A  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFDED1D  F3 0F 11 93 80 F6 00 00     movss   dword ptr [rbx+0F680h], xmm2
00007FF91DFDED25  F3 0F 59 93 80 F3 00 00     mulss   xmm2, dword ptr [rbx+0F380h]
00007FF91DFDED2D  F3 0F 11 93 F0 F6 00 00     movss   dword ptr [rbx+0F6F0h], xmm2
00007FF91DFDED35  F3 0F 59 93 D0 F3 00 00     mulss   xmm2, dword ptr [rbx+0F3D0h]
00007FF91DFDED3D  F3 0F 11 93 00 F7 00 00     movss   dword ptr [rbx+0F700h], xmm2
00007FF91DFDED45  F3 0F 10 83 B0 DE 00 00     movss   xmm0, dword ptr [rbx+0DEB0h]
00007FF91DFDED4D  F3 0F 58 83 10 DC 00 00     addss   xmm0, dword ptr [rbx+0DC10h]
00007FF91DFDED55  44 0F 5A E0                 cvtps2pd xmm12, xmm0
00007FF91DFDED59  F2 44 0F 5F 25 46 BF 60 00  maxsd   xmm12, cs:qword_7FF91E5EACA8
00007FF91DFDED62  F2 44 0F 5D 25 25 BF 60 00  minsd   xmm12, cs:qword_7FF91E5EAC90
00007FF91DFDED6B  41 0F 28 CC                 movaps  xmm1, xmm12
00007FF91DFDED6F  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFDED73  F2 0F 58 05 ED 64 76 00     addsd   xmm0, cs:qword_7FF91E745268
00007FF91DFDED7B  F2 41 0F 59 CC              mulsd   xmm1, xmm12
00007FF91DFDED80  41 0F 28 FC                 movaps  xmm7, xmm12
00007FF91DFDED84  F2 0F 2C C0                 cvttsd2si eax, xmm0
00007FF91DFDED88  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFDED8B  48 63 C8                    movsxd  rcx, eax
00007FF91DFDED8E  F2 41 0F 59 D4              mulsd   xmm2, xmm12
00007FF91DFDED93  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
00007FF91DFDED9A  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDED9D  F2 41 0F 59 DC              mulsd   xmm3, xmm12
00007FF91DFDEDA2  48 8D 0D 37 A7 60 00        lea     rcx, unk_7FF91E5E94E0
00007FF91DFDEDA9  48 03 C1                    add     rax, rcx
00007FF91DFDEDAC  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFDEDAF  F2 41 0F 59 E4              mulsd   xmm4, xmm12
00007FF91DFDEDB4  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
00007FF91DFDEDB9  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
00007FF91DFDEDBE  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
00007FF91DFDEDC3  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFDEDC6  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
00007FF91DFDEDCA  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
00007FF91DFDEDCF  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
00007FF91DFDEDD4  F2 0F 58 F9                 addsd   xmm7, xmm1
00007FF91DFDEDD8  F2 41 0F 59 EC              mulsd   xmm5, xmm12
00007FF91DFDEDDD  F2 0F 58 FA                 addsd   xmm7, xmm2
00007FF91DFDEDE1  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFDEDE4  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
00007FF91DFDEDE9  F2 41 0F 59 F4              mulsd   xmm6, xmm12
00007FF91DFDEDEE  F2 0F 58 FB                 addsd   xmm7, xmm3
00007FF91DFDEDF2  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFDEDF6  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
00007FF91DFDEDFB  F2 0F 58 FC                 addsd   xmm7, xmm4
00007FF91DFDEDFF  F2 45 0F 59 C4              mulsd   xmm8, xmm12
00007FF91DFDEE04  F2 0F 58 FD                 addsd   xmm7, xmm5
00007FF91DFDEE08  45 0F 28 C8                 movaps  xmm9, xmm8
00007FF91DFDEE0C  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
00007FF91DFDEE15  F2 45 0F 59 CC              mulsd   xmm9, xmm12
00007FF91DFDEE1A  F2 0F 58 FE                 addsd   xmm7, xmm6
00007FF91DFDEE1E  45 0F 28 D1                 movaps  xmm10, xmm9
00007FF91DFDEE22  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
00007FF91DFDEE2B  F2 41 0F 58 F8              addsd   xmm7, xmm8
00007FF91DFDEE30  F2 45 0F 59 D4              mulsd   xmm10, xmm12
00007FF91DFDEE35  F2 41 0F 58 F9              addsd   xmm7, xmm9
00007FF91DFDEE3A  45 0F 28 DA                 movaps  xmm11, xmm10
00007FF91DFDEE3E  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
00007FF91DFDEE47  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFDEE4C  F2 41 0F 58 FA              addsd   xmm7, xmm10
00007FF91DFDEE51  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFDEE55  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFDEE5A  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
00007FF91DFDEE62  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
00007FF91DFDEE6B  F2 0F 58 F8                 addsd   xmm7, xmm0
00007FF91DFDEE6F  F2 41 0F 58 FB              addsd   xmm7, xmm11
00007FF91DFDEE74  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
00007FF91DFDEE78  F3 0F 5D 1D 18 BE 60 00     minss   xmm3, cs:dword_7FF91E5EAC98
00007FF91DFDEE80  F3 0F 5F 1D 28 BE 60 00     maxss   xmm3, cs:dword_7FF91E5EACB0
00007FF91DFDEE88  F3 0F 59 9B 20 DC 00 00     mulss   xmm3, dword ptr [rbx+0DC20h]
00007FF91DFDEE90  F3 0F 11 9B 90 DE 00 00     movss   dword ptr [rbx+0DE90h], xmm3
00007FF91DFDEE98  8B 83 30 E0 00 00           mov     eax, [rbx+0E030h]
00007FF91DFDEE9E  F3 0F 10 AB 10 DC 00 00     movss   xmm5, dword ptr [rbx+0DC10h]
00007FF91DFDEEA6  F3 0F 10 83 E0 DD 00 00     movss   xmm0, dword ptr [rbx+0DDE0h]
00007FF91DFDEEAE  F3 0F 10 8B F0 DD 00 00     movss   xmm1, dword ptr [rbx+0DDF0h]
00007FF91DFDEEB6  F3 0F 10 93 00 DE 00 00     movss   xmm2, dword ptr [rbx+0DE00h]
00007FF91DFDEEBE  89 83 40 E0 00 00           mov     [rbx+0E040h], eax
00007FF91DFDEEC4  8B 83 50 E0 00 00           mov     eax, [rbx+0E050h]
00007FF91DFDEECA  89 83 60 E0 00 00           mov     [rbx+0E060h], eax
00007FF91DFDEED0  8B 83 00 E1 00 00           mov     eax, [rbx+0E100h]
00007FF91DFDEED6  89 83 10 E1 00 00           mov     [rbx+0E110h], eax
00007FF91DFDEEDC  8B 83 F0 E0 00 00           mov     eax, [rbx+0E0F0h]
00007FF91DFDEEE2  89 83 00 E1 00 00           mov     [rbx+0E100h], eax
00007FF91DFDEEE8  8B 83 E0 E0 00 00           mov     eax, [rbx+0E0E0h]
00007FF91DFDEEEE  89 83 F0 E0 00 00           mov     [rbx+0E0F0h], eax
00007FF91DFDEEF4  8B 83 D0 E0 00 00           mov     eax, [rbx+0E0D0h]
00007FF91DFDEEFA  89 83 E0 E0 00 00           mov     [rbx+0E0E0h], eax
00007FF91DFDEF00  8B 83 C0 E0 00 00           mov     eax, [rbx+0E0C0h]
00007FF91DFDEF06  89 83 D0 E0 00 00           mov     [rbx+0E0D0h], eax
00007FF91DFDEF0C  8B 83 B0 E0 00 00           mov     eax, [rbx+0E0B0h]
00007FF91DFDEF12  89 83 C0 E0 00 00           mov     [rbx+0E0C0h], eax
00007FF91DFDEF18  8B 83 A0 E0 00 00           mov     eax, [rbx+0E0A0h]
00007FF91DFDEF1E  89 83 B0 E0 00 00           mov     [rbx+0E0B0h], eax
00007FF91DFDEF24  8B 83 80 E1 00 00           mov     eax, [rbx+0E180h]
00007FF91DFDEF2A  89 83 90 E1 00 00           mov     [rbx+0E190h], eax
00007FF91DFDEF30  8B 83 70 E1 00 00           mov     eax, [rbx+0E170h]
00007FF91DFDEF36  89 83 80 E1 00 00           mov     [rbx+0E180h], eax
00007FF91DFDEF3C  8B 83 60 E1 00 00           mov     eax, [rbx+0E160h]
00007FF91DFDEF42  89 83 70 E1 00 00           mov     [rbx+0E170h], eax
00007FF91DFDEF48  8B 83 50 E1 00 00           mov     eax, [rbx+0E150h]
00007FF91DFDEF4E  89 83 60 E1 00 00           mov     [rbx+0E160h], eax
00007FF91DFDEF54  8B 83 40 E1 00 00           mov     eax, [rbx+0E140h]
00007FF91DFDEF5A  89 83 50 E1 00 00           mov     [rbx+0E150h], eax
00007FF91DFDEF60  8B 83 30 E1 00 00           mov     eax, [rbx+0E130h]
00007FF91DFDEF66  89 83 40 E1 00 00           mov     [rbx+0E140h], eax
00007FF91DFDEF6C  8B 83 20 E1 00 00           mov     eax, [rbx+0E120h]
00007FF91DFDEF72  89 83 30 E1 00 00           mov     [rbx+0E130h], eax
00007FF91DFDEF78  8B 83 00 E2 00 00           mov     eax, [rbx+0E200h]
00007FF91DFDEF7E  89 83 10 E2 00 00           mov     [rbx+0E210h], eax
00007FF91DFDEF84  8B 83 F0 E1 00 00           mov     eax, [rbx+0E1F0h]
00007FF91DFDEF8A  89 83 00 E2 00 00           mov     [rbx+0E200h], eax
00007FF91DFDEF90  8B 83 E0 E1 00 00           mov     eax, [rbx+0E1E0h]
00007FF91DFDEF96  89 83 F0 E1 00 00           mov     [rbx+0E1F0h], eax
00007FF91DFDEF9C  8B 83 D0 E1 00 00           mov     eax, [rbx+0E1D0h]
00007FF91DFDEFA2  89 83 E0 E1 00 00           mov     [rbx+0E1E0h], eax
00007FF91DFDEFA8  8B 83 C0 E1 00 00           mov     eax, [rbx+0E1C0h]
00007FF91DFDEFAE  89 83 D0 E1 00 00           mov     [rbx+0E1D0h], eax
00007FF91DFDEFB4  8B 83 B0 E1 00 00           mov     eax, [rbx+0E1B0h]
00007FF91DFDEFBA  89 83 C0 E1 00 00           mov     [rbx+0E1C0h], eax
00007FF91DFDEFC0  8B 83 A0 E1 00 00           mov     eax, [rbx+0E1A0h]
00007FF91DFDEFC6  89 83 B0 E1 00 00           mov     [rbx+0E1B0h], eax
00007FF91DFDEFCC  8B 83 80 E2 00 00           mov     eax, [rbx+0E280h]
00007FF91DFDEFD2  89 83 90 E2 00 00           mov     [rbx+0E290h], eax
00007FF91DFDEFD8  8B 83 70 E2 00 00           mov     eax, [rbx+0E270h]
00007FF91DFDEFDE  89 83 80 E2 00 00           mov     [rbx+0E280h], eax
00007FF91DFDEFE4  8B 83 60 E2 00 00           mov     eax, [rbx+0E260h]
00007FF91DFDEFEA  89 83 70 E2 00 00           mov     [rbx+0E270h], eax
00007FF91DFDEFF0  8B 83 50 E2 00 00           mov     eax, [rbx+0E250h]
00007FF91DFDEFF6  89 83 60 E2 00 00           mov     [rbx+0E260h], eax
00007FF91DFDEFFC  8B 83 40 E2 00 00           mov     eax, [rbx+0E240h]
00007FF91DFDF002  89 83 50 E2 00 00           mov     [rbx+0E250h], eax
00007FF91DFDF008  8B 83 30 E2 00 00           mov     eax, [rbx+0E230h]
00007FF91DFDF00E  89 83 40 E2 00 00           mov     [rbx+0E240h], eax
00007FF91DFDF014  8B 83 20 E2 00 00           mov     eax, [rbx+0E220h]
00007FF91DFDF01A  89 83 30 E2 00 00           mov     [rbx+0E230h], eax
00007FF91DFDF020  8B 83 C0 E2 00 00           mov     eax, [rbx+0E2C0h]
00007FF91DFDF026  89 83 D0 E2 00 00           mov     [rbx+0E2D0h], eax
00007FF91DFDF02C  8B 83 B0 E2 00 00           mov     eax, [rbx+0E2B0h]
00007FF91DFDF032  89 83 C0 E2 00 00           mov     [rbx+0E2C0h], eax
00007FF91DFDF038  F3 0F 11 83 D0 DF 00 00     movss   dword ptr [rbx+0DFD0h], xmm0
00007FF91DFDF040  F3 0F 11 8B E0 DF 00 00     movss   dword ptr [rbx+0DFE0h], xmm1
00007FF91DFDF048  F3 0F 58 AB F0 E5 00 00     addss   xmm5, dword ptr [rbx+0E5F0h]
00007FF91DFDF050  F3 0F 59 9B F0 E2 00 00     mulss   xmm3, dword ptr [rbx+0E2F0h]
00007FF91DFDF058  F3 0F 10 83 E0 E2 00 00     movss   xmm0, dword ptr [rbx+0E2E0h]
00007FF91DFDF060  F3 0F 11 93 F0 DF 00 00     movss   dword ptr [rbx+0DFF0h], xmm2
00007FF91DFDF068  F3 0F 10 93 10 E3 00 00     movss   xmm2, dword ptr [rbx+0E310h]
00007FF91DFDF070  F3 0F 59 AB 00 E6 00 00     mulss   xmm5, dword ptr [rbx+0E600h]
00007FF91DFDF078  F3 0F 5F D3                 maxss   xmm2, xmm3
00007FF91DFDF07C  F3 0F 58 AB E0 E5 00 00     addss   xmm5, dword ptr [rbx+0E5E0h]
00007FF91DFDF084  F3 0F 11 93 00 E0 00 00     movss   dword ptr [rbx+0E000h], xmm2
00007FF91DFDF08C  F3 0F 58 83 30 DC 00 00     addss   xmm0, dword ptr [rbx+0DC30h]
00007FF91DFDF094  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFDF098  F3 0F 11 83 20 E0 00 00     movss   dword ptr [rbx+0E020h], xmm0
00007FF91DFDF0A0  76 05                       jbe     short loc_7FF91DFDF0A7
00007FF91DFDF0A2  0F 5A C5                    cvtps2pd xmm0, xmm5
00007FF91DFDF0A5  EB 03                       jmp     short loc_7FF91DFDF0AA
00007FF91DFDF0A7  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDF0AA  F3 0F 10 0D AA 5E 76 00     movss   xmm1, cs:dword_7FF91E744F5C
00007FF91DFDF0B2  F3 44 0F 10 15 2D 61 76 00  movss   xmm10, cs:flt_7FF91E7451E8
00007FF91DFDF0BB  F3 0F 5E CA                 divss   xmm1, xmm2
00007FF91DFDF0BF  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFDF0C3  F3 0F 11 8B 10 E0 00 00     movss   dword ptr [rbx+0E010h], xmm1
00007FF91DFDF0CB  F3 0F 11 83 A0 E2 00 00     movss   dword ptr [rbx+0E2A0h], xmm0
00007FF91DFDF0D3  F3 0F 10 B3 60 E0 00 00     movss   xmm6, dword ptr [rbx+0E060h]
00007FF91DFDF0DB  F3 0F 10 8B 40 E0 00 00     movss   xmm1, dword ptr [rbx+0E040h]
00007FF91DFDF0E3  F3 0F 11 B3 80 DF 00 00     movss   dword ptr [rbx+0DF80h], xmm6
00007FF91DFDF0EB  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFDF0EF  F3 0F 11 8B 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm1
00007FF91DFDF0F7  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFDF0FB  76 1B                       jbe     short loc_7FF91DFDF118
00007FF91DFDF0FD  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDF102  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDF106  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDF109  E8 CA 03 37 00              call    fmodf
00007FF91DFDF10E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDF111  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDF116  EB 1F                       jmp     short loc_7FF91DFDF137
00007FF91DFDF118  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFDF11C  73 19                       jnb     short loc_7FF91DFDF137
00007FF91DFDF11E  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDF123  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDF127  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDF12A  E8 A9 03 37 00              call    fmodf
00007FF91DFDF12F  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDF132  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDF137  F3 44 0F 10 25 CC 5E 76 00  movss   xmm12, cs:dword_7FF91E74500C
00007FF91DFDF140  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDF143  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDF148  F3 0F 11 B3 70 DF 00 00     movss   dword ptr [rbx+0DF70h], xmm6
00007FF91DFDF150  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFDF153  F3 0F 59 BB 60 E3 00 00     mulss   xmm7, dword ptr [rbx+0E360h]
00007FF91DFDF15B  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFDF160  E8 5B 9E FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDF165  F3 44 0F 10 1D D6 62 76 00  movss   xmm11, cs:dword_7FF91E745444
00007FF91DFDF16E  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFDF171  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFDF176  F3 0F 59 AB 10 E0 00 00     mulss   xmm5, dword ptr [rbx+0E010h]
00007FF91DFDF17E  F3 0F 59 AB 30 E3 00 00     mulss   xmm5, dword ptr [rbx+0E330h]
00007FF91DFDF186  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDF18A  73 06                       jnb     short loc_7FF91DFDF192
00007FF91DFDF18C  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDF190  EB 05                       jmp     short loc_7FF91DFDF197
00007FF91DFDF192  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDF197  F3 0F 59 AB 00 E3 00 00     mulss   xmm5, dword ptr [rbx+0E300h]
00007FF91DFDF19F  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDF1A2  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDF1A6  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDF1A9  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDF1AC  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDF1B4  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDF1B7  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF1BB  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDF1BE  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
00007FF91DFDF1C6  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDF1CE  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDF1D2  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
00007FF91DFDF1DA  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDF1DE  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDF1E1  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDF1E9  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDF1ED  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF1F1  F3 0F 10 8B 20 E0 00 00     movss   xmm1, dword ptr [rbx+0E020h]
00007FF91DFDF1F9  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDF1FD  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDF200  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFDF204  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDF208  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDF20C  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFDF210  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDF214  F3 0F 11 A3 70 E0 00 00     movss   dword ptr [rbx+0E070h], xmm4
00007FF91DFDF21C  72 07                       jb      short loc_7FF91DFDF225
00007FF91DFDF21E  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFDF223  EB 05                       jmp     short loc_7FF91DFDF22A
00007FF91DFDF225  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFDF22A  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDF22D  73 06                       jnb     short loc_7FF91DFDF235
00007FF91DFDF22F  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFDF233  EB 06                       jmp     short loc_7FF91DFDF23B
00007FF91DFDF235  76 04                       jbe     short loc_7FF91DFDF23B
00007FF91DFDF237  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFDF23B  F3 44 0F 10 83 70 DF 00 00  movss   xmm8, dword ptr [rbx+0DF70h]
00007FF91DFDF244  F3 0F 59 B3 70 E3 00 00     mulss   xmm6, dword ptr [rbx+0E370h]
00007FF91DFDF24C  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFDF250  E8 6B 9D FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDF255  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFDF258  F3 0F 10 83 20 E3 00 00     movss   xmm0, dword ptr [rbx+0E320h]
00007FF91DFDF260  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFDF264  72 18                       jb      short loc_7FF91DFDF27E
00007FF91DFDF266  0F 2F 83 80 DF 00 00        comiss  xmm0, dword ptr [rbx+0DF80h]
00007FF91DFDF26D  76 0F                       jbe     short loc_7FF91DFDF27E
00007FF91DFDF26F  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
00007FF91DFDF277  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFDF27C  EB 08                       jmp     short loc_7FF91DFDF286
00007FF91DFDF27E  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
00007FF91DFDF286  0F 2F 3D 43 60 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFDF28D  F3 0F 59 A3 10 E0 00 00     mulss   xmm4, dword ptr [rbx+0E010h]
00007FF91DFDF295  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFDF29A  F3 0F 59 A3 40 E3 00 00     mulss   xmm4, dword ptr [rbx+0E340h]
00007FF91DFDF2A2  72 03                       jb      short loc_7FF91DFDF2A7
00007FF91DFDF2A4  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFDF2A7  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFDF2AB  73 06                       jnb     short loc_7FF91DFDF2B3
00007FF91DFDF2AD  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFDF2B1  EB 05                       jmp     short loc_7FF91DFDF2B8
00007FF91DFDF2B3  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFDF2B8  F3 0F 11 BB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm7
00007FF91DFDF2C0  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFDF2C5  F3 0F 59 A3 00 E3 00 00     mulss   xmm4, dword ptr [rbx+0E300h]
00007FF91DFDF2CD  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFDF2D0  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDF2D5  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDF2D9  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDF2DC  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFDF2E1  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF2E5  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDF2E8  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDF2EC  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFDF2F0  F3 44 0F 59 8B D0 E4 00 00  mulss   xmm9, dword ptr [rbx+0E4D0h]
00007FF91DFDF2F9  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFDF2FE  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDF301  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDF309  F3 44 0F 58 8B C0 E4 00 00  addss   xmm9, dword ptr [rbx+0E4C0h]
00007FF91DFDF312  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDF31A  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDF31F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDF322  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDF32A  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFDF32F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF333  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDF338  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFDF33B  0F 54 05 4E 64 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFDF342  0F 57 05 77 64 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFDF349  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFDF34E  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFDF353  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFDF358  F3 44 0F 11 8B 80 E0 00 00  movss   dword ptr [rbx+0E080h], xmm9
00007FF91DFDF361  E8 5A 9C FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDF366  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFDF36A  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFDF36E  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFDF373  73 06                       jnb     short loc_7FF91DFDF37B
00007FF91DFDF375  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFDF379  EB 06                       jmp     short loc_7FF91DFDF381
00007FF91DFDF37B  76 04                       jbe     short loc_7FF91DFDF381
00007FF91DFDF37D  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFDF381  F3 44 0F 59 83 10 E0 00 00  mulss   xmm8, dword ptr [rbx+0E010h]
00007FF91DFDF38A  F3 0F 59 BB 80 E3 00 00     mulss   xmm7, dword ptr [rbx+0E380h]
00007FF91DFDF392  F3 44 0F 59 05 FD B8 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFDF39B  F3 44 0F 59 83 50 E3 00 00  mulss   xmm8, dword ptr [rbx+0E350h]
00007FF91DFDF3A4  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFDF3A8  73 06                       jnb     short loc_7FF91DFDF3B0
00007FF91DFDF3AA  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFDF3AE  EB 05                       jmp     short loc_7FF91DFDF3B5
00007FF91DFDF3B0  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFDF3B5  F3 44 0F 59 83 00 E3 00 00  mulss   xmm8, dword ptr [rbx+0E300h]
00007FF91DFDF3BE  F3 44 0F 59 8B E0 DF 00 00  mulss   xmm9, dword ptr [rbx+0DFE0h]
00007FF91DFDF3C7  F3 0F 10 B3 70 DF 00 00     movss   xmm6, dword ptr [rbx+0DF70h]
00007FF91DFDF3CF  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDF3D3  F3 0F 10 AB 90 DF 00 00     movss   xmm5, dword ptr [rbx+0DF90h]
00007FF91DFDF3DB  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFDF3E0  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDF3E3  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDF3E6  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF3EA  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDF3ED  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
00007FF91DFDF3F5  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDF3F8  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDF400  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
00007FF91DFDF408  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFDF40D  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDF415  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDF419  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDF41C  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDF424  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDF428  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF42C  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDF430  F3 0F 10 83 70 E0 00 00     movss   xmm0, dword ptr [rbx+0E070h]
00007FF91DFDF438  F3 0F 59 83 D0 DF 00 00     mulss   xmm0, dword ptr [rbx+0DFD0h]
00007FF91DFDF440  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDF444  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFDF449  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFDF44E  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDF452  F3 0F 59 A3 F0 DF 00 00     mulss   xmm4, dword ptr [rbx+0DFF0h]
00007FF91DFDF45A  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDF45E  F3 0F 11 A3 A0 E0 00 00     movss   dword ptr [rbx+0E0A0h], xmm4
00007FF91DFDF466  F3 0F 11 B3 80 DF 00 00     movss   dword ptr [rbx+0DF80h], xmm6
00007FF91DFDF46E  F3 0F 11 AB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm5
00007FF91DFDF476  F3 0F 58 B3 00 E0 00 00     addss   xmm6, dword ptr [rbx+0E000h]
00007FF91DFDF47E  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFDF482  76 1B                       jbe     short loc_7FF91DFDF49F
00007FF91DFDF484  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDF489  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDF48D  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDF490  E8 43 00 37 00              call    fmodf
00007FF91DFDF495  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDF498  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDF49D  EB 1F                       jmp     short loc_7FF91DFDF4BE
00007FF91DFDF49F  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFDF4A3  73 19                       jnb     short loc_7FF91DFDF4BE
00007FF91DFDF4A5  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDF4AA  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDF4AE  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDF4B1  E8 22 00 37 00              call    fmodf
00007FF91DFDF4B6  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDF4B9  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDF4BE  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDF4C1  F3 0F 11 B3 70 DF 00 00     movss   dword ptr [rbx+0DF70h], xmm6
00007FF91DFDF4C9  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDF4CE  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFDF4D1  F3 0F 59 BB 60 E3 00 00     mulss   xmm7, dword ptr [rbx+0E360h]
00007FF91DFDF4D9  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFDF4DE  E8 DD 9A FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDF4E3  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFDF4E6  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFDF4EB  F3 0F 59 AB 10 E0 00 00     mulss   xmm5, dword ptr [rbx+0E010h]
00007FF91DFDF4F3  F3 0F 59 AB 30 E3 00 00     mulss   xmm5, dword ptr [rbx+0E330h]
00007FF91DFDF4FB  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDF4FF  73 06                       jnb     short loc_7FF91DFDF507
00007FF91DFDF501  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDF505  EB 05                       jmp     short loc_7FF91DFDF50C
00007FF91DFDF507  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDF50C  F3 0F 59 AB 00 E3 00 00     mulss   xmm5, dword ptr [rbx+0E300h]
00007FF91DFDF514  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDF517  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDF51B  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDF51E  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDF521  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDF529  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDF52C  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF530  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDF533  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
00007FF91DFDF53B  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDF543  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDF547  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
00007FF91DFDF54F  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDF553  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDF556  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDF55E  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDF562  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF566  F3 0F 10 8B 20 E0 00 00     movss   xmm1, dword ptr [rbx+0E020h]
00007FF91DFDF56E  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDF572  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDF575  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFDF579  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDF57D  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDF581  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFDF585  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDF589  F3 0F 11 A3 70 E0 00 00     movss   dword ptr [rbx+0E070h], xmm4
00007FF91DFDF591  72 07                       jb      short loc_7FF91DFDF59A
00007FF91DFDF593  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFDF598  EB 05                       jmp     short loc_7FF91DFDF59F
00007FF91DFDF59A  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFDF59F  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDF5A2  73 06                       jnb     short loc_7FF91DFDF5AA
00007FF91DFDF5A4  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFDF5A8  EB 06                       jmp     short loc_7FF91DFDF5B0
00007FF91DFDF5AA  76 04                       jbe     short loc_7FF91DFDF5B0
00007FF91DFDF5AC  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFDF5B0  F3 44 0F 10 83 70 DF 00 00  movss   xmm8, dword ptr [rbx+0DF70h]
00007FF91DFDF5B9  F3 0F 59 B3 70 E3 00 00     mulss   xmm6, dword ptr [rbx+0E370h]
00007FF91DFDF5C1  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFDF5C5  E8 F6 99 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDF5CA  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFDF5CD  F3 0F 10 83 20 E3 00 00     movss   xmm0, dword ptr [rbx+0E320h]
00007FF91DFDF5D5  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFDF5D9  72 18                       jb      short loc_7FF91DFDF5F3
00007FF91DFDF5DB  0F 2F 83 80 DF 00 00        comiss  xmm0, dword ptr [rbx+0DF80h]
00007FF91DFDF5E2  76 0F                       jbe     short loc_7FF91DFDF5F3
00007FF91DFDF5E4  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
00007FF91DFDF5EC  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFDF5F1  EB 08                       jmp     short loc_7FF91DFDF5FB
00007FF91DFDF5F3  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
00007FF91DFDF5FB  0F 2F 3D CE 5C 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFDF602  F3 0F 59 A3 10 E0 00 00     mulss   xmm4, dword ptr [rbx+0E010h]
00007FF91DFDF60A  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFDF60F  F3 0F 59 A3 40 E3 00 00     mulss   xmm4, dword ptr [rbx+0E340h]
00007FF91DFDF617  72 03                       jb      short loc_7FF91DFDF61C
00007FF91DFDF619  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFDF61C  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFDF620  73 06                       jnb     short loc_7FF91DFDF628
00007FF91DFDF622  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFDF626  EB 05                       jmp     short loc_7FF91DFDF62D
00007FF91DFDF628  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFDF62D  F3 0F 11 BB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm7
00007FF91DFDF635  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFDF63A  F3 0F 59 A3 00 E3 00 00     mulss   xmm4, dword ptr [rbx+0E300h]
00007FF91DFDF642  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFDF645  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDF64A  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDF64E  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDF651  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFDF656  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF65A  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDF65D  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDF661  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFDF665  F3 44 0F 59 8B D0 E4 00 00  mulss   xmm9, dword ptr [rbx+0E4D0h]
00007FF91DFDF66E  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFDF673  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDF676  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDF67E  F3 44 0F 58 8B C0 E4 00 00  addss   xmm9, dword ptr [rbx+0E4C0h]
00007FF91DFDF687  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDF68F  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDF694  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDF697  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDF69F  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFDF6A4  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF6A8  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDF6AD  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFDF6B0  0F 54 05 D9 60 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFDF6B7  0F 57 05 02 61 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFDF6BE  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFDF6C3  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFDF6C8  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFDF6CD  F3 44 0F 11 8B 80 E0 00 00  movss   dword ptr [rbx+0E080h], xmm9
00007FF91DFDF6D6  E8 E5 98 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDF6DB  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFDF6DF  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFDF6E3  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFDF6E8  73 06                       jnb     short loc_7FF91DFDF6F0
00007FF91DFDF6EA  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFDF6EE  EB 06                       jmp     short loc_7FF91DFDF6F6
00007FF91DFDF6F0  76 04                       jbe     short loc_7FF91DFDF6F6
00007FF91DFDF6F2  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFDF6F6  F3 44 0F 59 83 10 E0 00 00  mulss   xmm8, dword ptr [rbx+0E010h]
00007FF91DFDF6FF  F3 0F 59 BB 80 E3 00 00     mulss   xmm7, dword ptr [rbx+0E380h]
00007FF91DFDF707  F3 44 0F 59 05 88 B5 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFDF710  F3 44 0F 59 83 50 E3 00 00  mulss   xmm8, dword ptr [rbx+0E350h]
00007FF91DFDF719  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFDF71D  73 06                       jnb     short loc_7FF91DFDF725
00007FF91DFDF71F  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFDF723  EB 05                       jmp     short loc_7FF91DFDF72A
00007FF91DFDF725  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFDF72A  F3 44 0F 59 83 00 E3 00 00  mulss   xmm8, dword ptr [rbx+0E300h]
00007FF91DFDF733  F3 44 0F 59 8B E0 DF 00 00  mulss   xmm9, dword ptr [rbx+0DFE0h]
00007FF91DFDF73C  F3 0F 10 B3 70 DF 00 00     movss   xmm6, dword ptr [rbx+0DF70h]
00007FF91DFDF744  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDF748  F3 0F 10 AB 90 DF 00 00     movss   xmm5, dword ptr [rbx+0DF90h]
00007FF91DFDF750  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFDF755  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDF758  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDF75B  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF75F  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDF762  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
00007FF91DFDF76A  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDF76D  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDF775  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
00007FF91DFDF77D  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFDF782  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDF78A  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDF78E  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDF791  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDF799  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDF79D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF7A1  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDF7A5  F3 0F 10 83 70 E0 00 00     movss   xmm0, dword ptr [rbx+0E070h]
00007FF91DFDF7AD  F3 0F 59 83 D0 DF 00 00     mulss   xmm0, dword ptr [rbx+0DFD0h]
00007FF91DFDF7B5  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDF7B9  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFDF7BE  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFDF7C3  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDF7C7  F3 0F 59 A3 F0 DF 00 00     mulss   xmm4, dword ptr [rbx+0DFF0h]
00007FF91DFDF7CF  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDF7D3  F3 0F 11 A3 20 E1 00 00     movss   dword ptr [rbx+0E120h], xmm4
00007FF91DFDF7DB  F3 0F 11 B3 80 DF 00 00     movss   dword ptr [rbx+0DF80h], xmm6
00007FF91DFDF7E3  F3 0F 11 AB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm5
00007FF91DFDF7EB  F3 0F 58 B3 00 E0 00 00     addss   xmm6, dword ptr [rbx+0E000h]
00007FF91DFDF7F3  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFDF7F7  76 1B                       jbe     short loc_7FF91DFDF814
00007FF91DFDF7F9  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDF7FE  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDF802  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDF805  E8 CE FC 36 00              call    fmodf
00007FF91DFDF80A  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDF80D  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDF812  EB 1F                       jmp     short loc_7FF91DFDF833
00007FF91DFDF814  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFDF818  73 19                       jnb     short loc_7FF91DFDF833
00007FF91DFDF81A  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDF81F  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDF823  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDF826  E8 AD FC 36 00              call    fmodf
00007FF91DFDF82B  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDF82E  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDF833  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDF836  F3 0F 11 B3 70 DF 00 00     movss   dword ptr [rbx+0DF70h], xmm6
00007FF91DFDF83E  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDF843  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFDF846  F3 0F 59 BB 60 E3 00 00     mulss   xmm7, dword ptr [rbx+0E360h]
00007FF91DFDF84E  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFDF853  E8 68 97 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDF858  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFDF85B  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFDF860  F3 0F 59 AB 10 E0 00 00     mulss   xmm5, dword ptr [rbx+0E010h]
00007FF91DFDF868  F3 0F 59 AB 30 E3 00 00     mulss   xmm5, dword ptr [rbx+0E330h]
00007FF91DFDF870  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDF874  73 06                       jnb     short loc_7FF91DFDF87C
00007FF91DFDF876  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDF87A  EB 05                       jmp     short loc_7FF91DFDF881
00007FF91DFDF87C  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDF881  F3 0F 59 AB 00 E3 00 00     mulss   xmm5, dword ptr [rbx+0E300h]
00007FF91DFDF889  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDF88C  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDF890  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDF893  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDF896  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDF89E  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDF8A1  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF8A5  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDF8A8  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
00007FF91DFDF8B0  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDF8B8  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDF8BC  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
00007FF91DFDF8C4  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDF8C8  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDF8CB  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDF8D3  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDF8D7  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF8DB  F3 0F 10 8B 20 E0 00 00     movss   xmm1, dword ptr [rbx+0E020h]
00007FF91DFDF8E3  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDF8E7  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDF8EA  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFDF8EE  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDF8F2  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDF8F6  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFDF8FA  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDF8FE  F3 0F 11 A3 70 E0 00 00     movss   dword ptr [rbx+0E070h], xmm4
00007FF91DFDF906  72 07                       jb      short loc_7FF91DFDF90F
00007FF91DFDF908  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFDF90D  EB 05                       jmp     short loc_7FF91DFDF914
00007FF91DFDF90F  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFDF914  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDF917  73 06                       jnb     short loc_7FF91DFDF91F
00007FF91DFDF919  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFDF91D  EB 06                       jmp     short loc_7FF91DFDF925
00007FF91DFDF91F  76 04                       jbe     short loc_7FF91DFDF925
00007FF91DFDF921  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFDF925  F3 44 0F 10 83 70 DF 00 00  movss   xmm8, dword ptr [rbx+0DF70h]
00007FF91DFDF92E  F3 0F 59 B3 70 E3 00 00     mulss   xmm6, dword ptr [rbx+0E370h]
00007FF91DFDF936  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFDF93A  E8 81 96 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDF93F  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFDF942  F3 0F 10 83 20 E3 00 00     movss   xmm0, dword ptr [rbx+0E320h]
00007FF91DFDF94A  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFDF94E  72 18                       jb      short loc_7FF91DFDF968
00007FF91DFDF950  0F 2F 83 80 DF 00 00        comiss  xmm0, dword ptr [rbx+0DF80h]
00007FF91DFDF957  76 0F                       jbe     short loc_7FF91DFDF968
00007FF91DFDF959  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
00007FF91DFDF961  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFDF966  EB 08                       jmp     short loc_7FF91DFDF970
00007FF91DFDF968  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
00007FF91DFDF970  0F 2F 3D 59 59 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFDF977  F3 0F 59 A3 10 E0 00 00     mulss   xmm4, dword ptr [rbx+0E010h]
00007FF91DFDF97F  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFDF984  F3 0F 59 A3 40 E3 00 00     mulss   xmm4, dword ptr [rbx+0E340h]
00007FF91DFDF98C  72 03                       jb      short loc_7FF91DFDF991
00007FF91DFDF98E  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFDF991  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFDF995  73 06                       jnb     short loc_7FF91DFDF99D
00007FF91DFDF997  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFDF99B  EB 05                       jmp     short loc_7FF91DFDF9A2
00007FF91DFDF99D  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFDF9A2  F3 0F 11 BB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm7
00007FF91DFDF9AA  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFDF9AF  F3 0F 59 A3 00 E3 00 00     mulss   xmm4, dword ptr [rbx+0E300h]
00007FF91DFDF9B7  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFDF9BA  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDF9BF  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDF9C3  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDF9C6  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFDF9CB  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDF9CF  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDF9D2  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDF9D6  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFDF9DA  F3 44 0F 59 8B D0 E4 00 00  mulss   xmm9, dword ptr [rbx+0E4D0h]
00007FF91DFDF9E3  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFDF9E8  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDF9EB  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDF9F3  F3 44 0F 58 8B C0 E4 00 00  addss   xmm9, dword ptr [rbx+0E4C0h]
00007FF91DFDF9FC  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDFA04  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDFA09  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDFA0C  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDFA14  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFDFA19  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDFA1D  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDFA22  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFDFA25  0F 54 05 64 5D 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFDFA2C  0F 57 05 8D 5D 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFDFA33  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFDFA38  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFDFA3D  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFDFA42  F3 44 0F 11 8B 80 E0 00 00  movss   dword ptr [rbx+0E080h], xmm9
00007FF91DFDFA4B  E8 70 95 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDFA50  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFDFA54  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFDFA58  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFDFA5D  73 06                       jnb     short loc_7FF91DFDFA65
00007FF91DFDFA5F  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFDFA63  EB 06                       jmp     short loc_7FF91DFDFA6B
00007FF91DFDFA65  76 04                       jbe     short loc_7FF91DFDFA6B
00007FF91DFDFA67  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFDFA6B  F3 44 0F 59 83 10 E0 00 00  mulss   xmm8, dword ptr [rbx+0E010h]
00007FF91DFDFA74  F3 0F 59 BB 80 E3 00 00     mulss   xmm7, dword ptr [rbx+0E380h]
00007FF91DFDFA7C  F3 44 0F 59 05 13 B2 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFDFA85  F3 44 0F 59 83 50 E3 00 00  mulss   xmm8, dword ptr [rbx+0E350h]
00007FF91DFDFA8E  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFDFA92  73 06                       jnb     short loc_7FF91DFDFA9A
00007FF91DFDFA94  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFDFA98  EB 05                       jmp     short loc_7FF91DFDFA9F
00007FF91DFDFA9A  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFDFA9F  F3 44 0F 59 83 00 E3 00 00  mulss   xmm8, dword ptr [rbx+0E300h]
00007FF91DFDFAA8  F3 44 0F 59 8B E0 DF 00 00  mulss   xmm9, dword ptr [rbx+0DFE0h]
00007FF91DFDFAB1  F3 0F 10 B3 70 DF 00 00     movss   xmm6, dword ptr [rbx+0DF70h]
00007FF91DFDFAB9  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDFABD  F3 0F 10 AB 90 DF 00 00     movss   xmm5, dword ptr [rbx+0DF90h]
00007FF91DFDFAC5  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFDFACA  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDFACD  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDFAD0  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDFAD4  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDFAD7  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
00007FF91DFDFADF  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDFAE2  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDFAEA  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
00007FF91DFDFAF2  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFDFAF7  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDFAFF  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDFB03  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDFB06  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDFB0E  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDFB12  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDFB16  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDFB1A  F3 0F 10 83 70 E0 00 00     movss   xmm0, dword ptr [rbx+0E070h]
00007FF91DFDFB22  F3 0F 59 83 D0 DF 00 00     mulss   xmm0, dword ptr [rbx+0DFD0h]
00007FF91DFDFB2A  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDFB2E  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFDFB33  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFDFB38  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDFB3C  F3 0F 59 A3 F0 DF 00 00     mulss   xmm4, dword ptr [rbx+0DFF0h]
00007FF91DFDFB44  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDFB48  F3 0F 11 A3 A0 E1 00 00     movss   dword ptr [rbx+0E1A0h], xmm4
00007FF91DFDFB50  F3 0F 11 B3 80 DF 00 00     movss   dword ptr [rbx+0DF80h], xmm6
00007FF91DFDFB58  F3 0F 11 AB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm5
00007FF91DFDFB60  F3 0F 58 B3 00 E0 00 00     addss   xmm6, dword ptr [rbx+0E000h]
00007FF91DFDFB68  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFDFB6C  76 1B                       jbe     short loc_7FF91DFDFB89
00007FF91DFDFB6E  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDFB73  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDFB77  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDFB7A  E8 59 F9 36 00              call    fmodf
00007FF91DFDFB7F  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDFB82  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDFB87  EB 1F                       jmp     short loc_7FF91DFDFBA8
00007FF91DFDFB89  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFDFB8D  73 19                       jnb     short loc_7FF91DFDFBA8
00007FF91DFDFB8F  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDFB94  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDFB98  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDFB9B  E8 38 F9 36 00              call    fmodf
00007FF91DFDFBA0  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDFBA3  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDFBA8  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDFBAB  F3 0F 11 B3 70 DF 00 00     movss   dword ptr [rbx+0DF70h], xmm6
00007FF91DFDFBB3  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDFBB8  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFDFBBB  F3 0F 59 BB 60 E3 00 00     mulss   xmm7, dword ptr [rbx+0E360h]
00007FF91DFDFBC3  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFDFBC8  E8 F3 93 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDFBCD  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFDFBD0  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFDFBD5  F3 0F 59 AB 10 E0 00 00     mulss   xmm5, dword ptr [rbx+0E010h]
00007FF91DFDFBDD  F3 0F 59 AB 30 E3 00 00     mulss   xmm5, dword ptr [rbx+0E330h]
00007FF91DFDFBE5  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDFBE9  73 06                       jnb     short loc_7FF91DFDFBF1
00007FF91DFDFBEB  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDFBEF  EB 05                       jmp     short loc_7FF91DFDFBF6
00007FF91DFDFBF1  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDFBF6  F3 0F 59 AB 00 E3 00 00     mulss   xmm5, dword ptr [rbx+0E300h]
00007FF91DFDFBFE  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDFC01  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDFC05  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDFC08  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDFC0B  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDFC13  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDFC16  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDFC1A  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDFC1D  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
00007FF91DFDFC25  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDFC2D  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDFC31  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
00007FF91DFDFC39  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDFC3D  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDFC40  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDFC48  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDFC4C  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDFC50  F3 0F 10 8B 20 E0 00 00     movss   xmm1, dword ptr [rbx+0E020h]
00007FF91DFDFC58  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDFC5C  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDFC5F  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFDFC63  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDFC67  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDFC6B  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFDFC6F  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDFC73  F3 0F 11 A3 70 E0 00 00     movss   dword ptr [rbx+0E070h], xmm4
00007FF91DFDFC7B  72 07                       jb      short loc_7FF91DFDFC84
00007FF91DFDFC7D  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFDFC82  EB 05                       jmp     short loc_7FF91DFDFC89
00007FF91DFDFC84  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFDFC89  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDFC8C  73 06                       jnb     short loc_7FF91DFDFC94
00007FF91DFDFC8E  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFDFC92  EB 06                       jmp     short loc_7FF91DFDFC9A
00007FF91DFDFC94  76 04                       jbe     short loc_7FF91DFDFC9A
00007FF91DFDFC96  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFDFC9A  F3 44 0F 10 83 70 DF 00 00  movss   xmm8, dword ptr [rbx+0DF70h]
00007FF91DFDFCA3  F3 0F 59 B3 70 E3 00 00     mulss   xmm6, dword ptr [rbx+0E370h]
00007FF91DFDFCAB  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFDFCAF  E8 0C 93 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDFCB4  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFDFCB7  F3 0F 10 83 20 E3 00 00     movss   xmm0, dword ptr [rbx+0E320h]
00007FF91DFDFCBF  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFDFCC3  72 18                       jb      short loc_7FF91DFDFCDD
00007FF91DFDFCC5  0F 2F 83 80 DF 00 00        comiss  xmm0, dword ptr [rbx+0DF80h]
00007FF91DFDFCCC  76 0F                       jbe     short loc_7FF91DFDFCDD
00007FF91DFDFCCE  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
00007FF91DFDFCD6  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFDFCDB  EB 08                       jmp     short loc_7FF91DFDFCE5
00007FF91DFDFCDD  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
00007FF91DFDFCE5  0F 2F 3D E4 55 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFDFCEC  F3 0F 59 A3 10 E0 00 00     mulss   xmm4, dword ptr [rbx+0E010h]
00007FF91DFDFCF4  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFDFCF9  F3 0F 59 A3 40 E3 00 00     mulss   xmm4, dword ptr [rbx+0E340h]
00007FF91DFDFD01  72 03                       jb      short loc_7FF91DFDFD06
00007FF91DFDFD03  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFDFD06  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFDFD0A  73 06                       jnb     short loc_7FF91DFDFD12
00007FF91DFDFD0C  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFDFD10  EB 05                       jmp     short loc_7FF91DFDFD17
00007FF91DFDFD12  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFDFD17  F3 0F 11 BB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm7
00007FF91DFDFD1F  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFDFD24  F3 0F 59 A3 00 E3 00 00     mulss   xmm4, dword ptr [rbx+0E300h]
00007FF91DFDFD2C  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFDFD2F  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDFD34  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDFD38  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDFD3B  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFDFD40  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDFD44  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDFD47  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDFD4B  44 0F 28 C2                 movaps  xmm8, xmm2
00007FF91DFDFD4F  F3 44 0F 59 83 D0 E4 00 00  mulss   xmm8, dword ptr [rbx+0E4D0h]
00007FF91DFDFD58  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFDFD5D  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDFD60  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDFD68  F3 44 0F 58 83 C0 E4 00 00  addss   xmm8, dword ptr [rbx+0E4C0h]
00007FF91DFDFD71  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDFD79  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFDFD7E  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDFD81  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDFD89  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFDFD8E  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDFD92  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFDFD97  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFDFD9A  0F 54 05 EF 59 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFDFDA1  0F 57 05 18 5A 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFDFDA8  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFDFDAD  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFDFDB2  F3 44 0F 59 C6              mulss   xmm8, xmm6
00007FF91DFDFDB7  F3 44 0F 11 83 80 E0 00 00  movss   dword ptr [rbx+0E080h], xmm8
00007FF91DFDFDC0  E8 FB 91 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDFDC5  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFDFDC9  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDFDCE  73 06                       jnb     short loc_7FF91DFDFDD6
00007FF91DFDFDD0  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFDFDD4  EB 06                       jmp     short loc_7FF91DFDFDDC
00007FF91DFDFDD6  76 04                       jbe     short loc_7FF91DFDFDDC
00007FF91DFDFDD8  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFDFDDC  F3 0F 59 83 10 E0 00 00     mulss   xmm0, dword ptr [rbx+0E010h]
00007FF91DFDFDE4  F3 0F 59 BB 80 E3 00 00     mulss   xmm7, dword ptr [rbx+0E380h]
00007FF91DFDFDEC  F3 0F 59 05 A4 AE 60 00     mulss   xmm0, cs:dword_7FF91E5EAC98
00007FF91DFDFDF4  F3 0F 59 83 50 E3 00 00     mulss   xmm0, dword ptr [rbx+0E350h]
00007FF91DFDFDFC  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFDFE00  72 09                       jb      short loc_7FF91DFDFE0B
00007FF91DFDFE02  44 0F 28 F8                 movaps  xmm15, xmm0
00007FF91DFDFE06  F3 45 0F 5D FD              minss   xmm15, xmm13
00007FF91DFDFE0B  F3 44 0F 59 BB 00 E3 00 00  mulss   xmm15, dword ptr [rbx+0E300h]
00007FF91DFDFE14  F3 44 0F 59 83 E0 DF 00 00  mulss   xmm8, dword ptr [rbx+0DFE0h]
00007FF91DFDFE1D  F3 0F 10 AB 70 DF 00 00     movss   xmm5, dword ptr [rbx+0DF70h]
00007FF91DFDFE25  41 0F 28 D7                 movaps  xmm2, xmm15
00007FF91DFDFE29  F3 0F 10 B3 90 DF 00 00     movss   xmm6, dword ptr [rbx+0DF90h]
00007FF91DFDFE31  F3 41 0F 59 D7              mulss   xmm2, xmm15
00007FF91DFDFE36  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDFE39  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDFE3C  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
00007FF91DFDFE44  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDFE47  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDFE4B  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDFE4E  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
00007FF91DFDFE56  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
00007FF91DFDFE5E  F3 41 0F 59 DF              mulss   xmm3, xmm15
00007FF91DFDFE63  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
00007FF91DFDFE6B  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDFE6F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDFE72  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
00007FF91DFDFE7A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDFE7E  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDFE82  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDFE86  F3 0F 10 83 70 E0 00 00     movss   xmm0, dword ptr [rbx+0E070h]
00007FF91DFDFE8E  F3 0F 59 83 D0 DF 00 00     mulss   xmm0, dword ptr [rbx+0DFD0h]
00007FF91DFDFE96  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDFE9A  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFDFE9F  F3 41 0F 58 E7              addss   xmm4, xmm15
00007FF91DFDFEA4  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDFEA8  F3 0F 59 A3 F0 DF 00 00     mulss   xmm4, dword ptr [rbx+0DFF0h]
00007FF91DFDFEB0  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDFEB4  F3 0F 11 A3 20 E2 00 00     movss   dword ptr [rbx+0E220h], xmm4
00007FF91DFDFEBC  F3 0F 10 93 90 E2 00 00     movss   xmm2, dword ptr [rbx+0E290h]
00007FF91DFDFEC4  F3 0F 11 AB 50 E0 00 00     movss   dword ptr [rbx+0E050h], xmm5
00007FF91DFDFECC  F3 0F 11 B3 30 E0 00 00     movss   dword ptr [rbx+0E030h], xmm6
00007FF91DFDFED4  F3 0F 10 83 A0 E1 00 00     movss   xmm0, dword ptr [rbx+0E1A0h]
00007FF91DFDFEDC  F3 0F 58 83 90 E1 00 00     addss   xmm0, dword ptr [rbx+0E190h]
00007FF91DFDFEE4  F3 0F 10 8B 20 E2 00 00     movss   xmm1, dword ptr [rbx+0E220h]
00007FF91DFDFEEC  F3 0F 58 8B 10 E1 00 00     addss   xmm1, dword ptr [rbx+0E110h]
00007FF91DFDFEF4  F3 0F 10 AB 10 E2 00 00     movss   xmm5, dword ptr [rbx+0E210h]
00007FF91DFDFEFC  F3 0F 58 AB 20 E1 00 00     addss   xmm5, dword ptr [rbx+0E120h]
00007FF91DFDFF04  F3 0F 59 83 B0 E3 00 00     mulss   xmm0, dword ptr [rbx+0E3B0h]
00007FF91DFDFF0C  F3 0F 59 8B C0 E3 00 00     mulss   xmm1, dword ptr [rbx+0E3C0h]
00007FF91DFDFF14  F3 0F 59 AB A0 E3 00 00     mulss   xmm5, dword ptr [rbx+0E3A0h]
00007FF91DFDFF1C  F3 0F 58 93 A0 E0 00 00     addss   xmm2, dword ptr [rbx+0E0A0h]
00007FF91DFDFF24  F3 0F 59 93 90 E3 00 00     mulss   xmm2, dword ptr [rbx+0E390h]
00007FF91DFDFF2C  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFDFF30  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDFF34  F3 0F 10 83 80 E2 00 00     movss   xmm0, dword ptr [rbx+0E280h]
00007FF91DFDFF3C  F3 0F 58 83 B0 E0 00 00     addss   xmm0, dword ptr [rbx+0E0B0h]
00007FF91DFDFF44  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDFF48  F3 0F 10 8B 00 E2 00 00     movss   xmm1, dword ptr [rbx+0E200h]
00007FF91DFDFF50  F3 0F 59 83 D0 E3 00 00     mulss   xmm0, dword ptr [rbx+0E3D0h]
00007FF91DFDFF58  F3 0F 58 8B 30 E1 00 00     addss   xmm1, dword ptr [rbx+0E130h]
00007FF91DFDFF60  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDFF64  F3 0F 10 83 B0 E1 00 00     movss   xmm0, dword ptr [rbx+0E1B0h]
00007FF91DFDFF6C  F3 0F 58 83 80 E1 00 00     addss   xmm0, dword ptr [rbx+0E180h]
00007FF91DFDFF74  F3 0F 59 8B E0 E3 00 00     mulss   xmm1, dword ptr [rbx+0E3E0h]
00007FF91DFDFF7C  F3 0F 59 83 F0 E3 00 00     mulss   xmm0, dword ptr [rbx+0E3F0h]
00007FF91DFDFF84  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDFF88  F3 0F 10 8B 30 E2 00 00     movss   xmm1, dword ptr [rbx+0E230h]
00007FF91DFDFF90  F3 0F 58 8B 00 E1 00 00     addss   xmm1, dword ptr [rbx+0E100h]
00007FF91DFDFF98  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDFF9C  F3 0F 10 83 70 E2 00 00     movss   xmm0, dword ptr [rbx+0E270h]
00007FF91DFDFFA4  F3 0F 59 8B 00 E4 00 00     mulss   xmm1, dword ptr [rbx+0E400h]
00007FF91DFDFFAC  F3 0F 58 83 C0 E0 00 00     addss   xmm0, dword ptr [rbx+0E0C0h]
00007FF91DFDFFB4  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDFFB8  F3 0F 10 8B 40 E1 00 00     movss   xmm1, dword ptr [rbx+0E140h]
00007FF91DFDFFC0  F3 0F 58 8B F0 E1 00 00     addss   xmm1, dword ptr [rbx+0E1F0h]
00007FF91DFDFFC8  F3 0F 59 83 10 E4 00 00     mulss   xmm0, dword ptr [rbx+0E410h]
00007FF91DFDFFD0  F3 0F 59 8B 20 E4 00 00     mulss   xmm1, dword ptr [rbx+0E420h]
00007FF91DFDFFD8  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDFFDC  F3 0F 10 83 C0 E1 00 00     movss   xmm0, dword ptr [rbx+0E1C0h]
00007FF91DFDFFE4  F3 0F 58 83 70 E1 00 00     addss   xmm0, dword ptr [rbx+0E170h]
00007FF91DFDFFEC  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDFFF0  F3 0F 10 8B F0 E0 00 00     movss   xmm1, dword ptr [rbx+0E0F0h]
00007FF91DFDFFF8  F3 0F 59 83 30 E4 00 00     mulss   xmm0, dword ptr [rbx+0E430h]
00007FF91DFE0000  F3 0F 58 8B 40 E2 00 00     addss   xmm1, dword ptr [rbx+0E240h]
00007FF91DFE0008  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE000C  F3 0F 10 83 60 E2 00 00     movss   xmm0, dword ptr [rbx+0E260h]
00007FF91DFE0014  F3 0F 59 8B 40 E4 00 00     mulss   xmm1, dword ptr [rbx+0E440h]
00007FF91DFE001C  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE0020  F3 0F 58 83 D0 E0 00 00     addss   xmm0, dword ptr [rbx+0E0D0h]
00007FF91DFE0028  F3 0F 10 93 C0 E2 00 00     movss   xmm2, dword ptr [rbx+0E2C0h]
00007FF91DFE0030  F3 0F 10 8B E0 E1 00 00     movss   xmm1, dword ptr [rbx+0E1E0h]
00007FF91DFE0038  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE003B  F3 0F 59 A3 C0 E5 00 00     mulss   xmm4, dword ptr [rbx+0E5C0h]
00007FF91DFE0043  F3 0F 59 83 50 E4 00 00     mulss   xmm0, dword ptr [rbx+0E450h]
00007FF91DFE004B  F3 0F 58 A3 D0 E2 00 00     addss   xmm4, dword ptr [rbx+0E2D0h]
00007FF91DFE0053  F3 0F 58 8B 50 E1 00 00     addss   xmm1, dword ptr [rbx+0E150h]
00007FF91DFE005B  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE005F  F3 0F 10 83 D0 E1 00 00     movss   xmm0, dword ptr [rbx+0E1D0h]
00007FF91DFE0067  F3 0F 58 83 60 E1 00 00     addss   xmm0, dword ptr [rbx+0E160h]
00007FF91DFE006F  F3 0F 59 8B 60 E4 00 00     mulss   xmm1, dword ptr [rbx+0E460h]
00007FF91DFE0077  F3 0F 59 83 70 E4 00 00     mulss   xmm0, dword ptr [rbx+0E470h]
00007FF91DFE007F  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE0083  F3 0F 10 8B 50 E2 00 00     movss   xmm1, dword ptr [rbx+0E250h]
00007FF91DFE008B  F3 0F 58 8B E0 E0 00 00     addss   xmm1, dword ptr [rbx+0E0E0h]
00007FF91DFE0093  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE0097  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE009A  F3 0F 59 8B 80 E4 00 00     mulss   xmm1, dword ptr [rbx+0E480h]
00007FF91DFE00A2  F3 0F 11 A3 C0 E2 00 00     movss   dword ptr [rbx+0E2C0h], xmm4
00007FF91DFE00AA  F3 0F 59 83 D0 E5 00 00     mulss   xmm0, dword ptr [rbx+0E5D0h]
00007FF91DFE00B2  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE00B6  F3 0F 58 C4                 addss   xmm0, xmm4
00007FF91DFE00BA  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFE00BD  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE00C1  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE00C4  F3 0F 59 83 C0 E5 00 00     mulss   xmm0, dword ptr [rbx+0E5C0h]
00007FF91DFE00CC  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFE00D0  F3 0F 11 83 B0 E2 00 00     movss   dword ptr [rbx+0E2B0h], xmm0
00007FF91DFE00D8  F3 0F 10 93 10 E6 00 00     movss   xmm2, dword ptr [rbx+0E610h]
00007FF91DFE00E0  F3 0F 59 9B A0 E2 00 00     mulss   xmm3, dword ptr [rbx+0E2A0h]
00007FF91DFE00E8  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFE00EC  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFE00F0  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE00F4  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFE00F8  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE00FC  F3 0F 11 A3 90 E0 00 00     movss   dword ptr [rbx+0E090h], xmm4
00007FF91DFE0104  F3 0F 11 A3 10 DB 00 00     movss   dword ptr [rbx+0DB10h], xmm4
00007FF91DFE010C  44 0F 2E AB 20 8D 01 00     ucomiss xmm13, dword ptr [rbx+18D20h]
00007FF91DFE0114  75 1B                       jnz     short loc_7FF91DFE0131
00007FF91DFE0116  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
00007FF91DFE011F  F3 0F 11 83 90 CE 00 00     movss   dword ptr [rbx+0CE90h], xmm0
00007FF91DFE0127  C7 83 20 8D 01 00 00 00 00 00  mov     dword ptr [rbx+18D20h], 0
00007FF91DFE0131  8B 83 00 F7 00 00           mov     eax, [rbx+0F700h]
00007FF91DFE0137  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
00007FF91DFE013F  48 8B 0F                    mov     rcx, [rdi]
00007FF91DFE0142  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
00007FF91DFE0147  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
00007FF91DFE014C  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
00007FF91DFE0151  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
00007FF91DFE0156  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
00007FF91DFE015B  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
00007FF91DFE0160  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
00007FF91DFE0165  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
00007FF91DFE016A  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
00007FF91DFE0170  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
00007FF91DFE0176  89 01                       mov     [rcx], eax
00007FF91DFE0178  8B 83 00 F7 00 00           mov     eax, [rbx+0F700h]
00007FF91DFE017E  48 8B 4F 08                 mov     rcx, [rdi+8]
00007FF91DFE0182  49 8B 5B 18                 mov     rbx, [r11+18h]
00007FF91DFE0186  89 01                       mov     [rcx], eax
00007FF91DFE0188  49 8B E3                    mov     rsp, r11
00007FF91DFE018B  5F                          pop     rdi
00007FF91DFE018C  C3                          retn
