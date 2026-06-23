; sub_18037C420 @ 0x18037C420 (RVA 0x37C420) size=0x3D6D

000000018037C420  48 8B C4                    mov     rax, rsp
000000018037C423  48 89 58 10                 mov     [rax+10h], rbx
000000018037C427  57                          push    rdi
000000018037C428  48 81 EC C0 00 00 00        sub     rsp, 0C0h
000000018037C42F  F3 0F 10 A1 90 CE 00 00     movss   xmm4, dword ptr [rcx+0CE90h]
000000018037C437  48 8B FA                    mov     rdi, rdx
000000018037C43A  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
000000018037C43E  48 8B D9                    mov     rbx, rcx
000000018037C441  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
000000018037C445  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
000000018037C44A  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
000000018037C44F  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
000000018037C454  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
000000018037C459  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
000000018037C45E  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
000000018037C464  F3 44 0F 10 2D 47 8C 76 00  movss   xmm13, cs:dword_180AE50B4
000000018037C46D  44 0F 2E A9 20 8D 01 00     ucomiss xmm13, dword ptr [rcx+18D20h]
000000018037C475  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
000000018037C47B  45 0F 57 F6                 xorps   xmm14, xmm14
000000018037C47F  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
000000018037C489  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
000000018037C48F  75 16                       jnz     short loc_18037C4A7
000000018037C491  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
000000018037C49A  0F 57 E4                    xorps   xmm4, xmm4
000000018037C49D  C7 81 90 CE 00 00 00 00 00 00  mov     dword ptr [rcx+0CE90h], 0
000000018037C4A7  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
000000018037C4AF  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
000000018037C4B7  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
000000018037C4BF  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
000000018037C4C7  F3 0F 59 05 F5 E8 60 00     mulss   xmm0, cs:dword_18098ADC4
000000018037C4CF  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
000000018037C4D7  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
000000018037C4DF  F3 0F 2C D0                 cvttss2si edx, xmm0
000000018037C4E3  85 D2                       test    edx, edx
000000018037C4E5  75 07                       jnz     short loc_18037C4EE
000000018037C4E7  BA 01 00 00 00              mov     edx, 1
000000018037C4EC  EB 24                       jmp     short loc_18037C512
000000018037C4EE  8B C2                       mov     eax, edx
000000018037C4F0  25 00 00 20 00              and     eax, 200000h
000000018037C4F5  0F BA E2 17                 bt      edx, 17h
000000018037C4F9  73 08                       jnb     short loc_18037C503
000000018037C4FB  85 C0                       test    eax, eax
000000018037C4FD  75 0C                       jnz     short loc_18037C50B
000000018037C4FF  03 D2                       add     edx, edx
000000018037C501  EB 0F                       jmp     short loc_18037C512
000000018037C503  85 C0                       test    eax, eax
000000018037C505  74 04                       jz      short loc_18037C50B
000000018037C507  03 D2                       add     edx, edx
000000018037C509  EB 07                       jmp     short loc_18037C512
000000018037C50B  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
000000018037C512  F3 0F 10 9B 20 CE 00 00     movss   xmm3, dword ptr [rbx+0CE20h]
000000018037C51A  8B C2                       mov     eax, edx
000000018037C51C  F3 0F 10 B3 00 CE 00 00     movss   xmm6, dword ptr [rbx+0CE00h]
000000018037C524  25 FF FF FF 00              and     eax, 0FFFFFFh
000000018037C529  F3 44 0F 10 83 C0 CE 00 00  movss   xmm8, dword ptr [rbx+0CEC0h]
000000018037C532  8B CA                       mov     ecx, edx
000000018037C534  F3 0F 10 BB D0 CE 00 00     movss   xmm7, dword ptr [rbx+0CED0h]
000000018037C53C  81 CA 00 00 00 FF           or      edx, 0FF000000h
000000018037C542  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018037C546  81 E1 00 00 00 01           and     ecx, 1000000h
000000018037C54C  C7 83 00 CF 00 00 00 00 00 00  mov     dword ptr [rbx+0CF00h], 0
000000018037C556  F3 0F 11 9B 30 CE 00 00     movss   dword ptr [rbx+0CE30h], xmm3
000000018037C55E  45 0F 57 D2                 xorps   xmm10, xmm10
000000018037C562  0F 44 D0                    cmovz   edx, eax
000000018037C565  F3 0F 11 B3 10 CE 00 00     movss   dword ptr [rbx+0CE10h], xmm6
000000018037C56D  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
000000018037C573  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
000000018037C579  8B 83 40 CF 00 00           mov     eax, [rbx+0CF40h]
000000018037C57F  66 0F 6E C2                 movd    xmm0, edx
000000018037C583  0F 5B C0                    cvtdq2ps xmm0, xmm0
000000018037C586  89 83 50 CF 00 00           mov     [rbx+0CF50h], eax
000000018037C58C  F3 0F 11 A3 B0 CE 00 00     movss   dword ptr [rbx+0CEB0h], xmm4
000000018037C594  F3 0F 59 05 D4 E6 60 00     mulss   xmm0, cs:dword_18098AC70
000000018037C59C  F3 44 0F 11 83 E0 CE 00 00  movss   dword ptr [rbx+0CEE0h], xmm8
000000018037C5A5  F3 0F 11 BB F0 CE 00 00     movss   dword ptr [rbx+0CEF0h], xmm7
000000018037C5AD  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
000000018037C5B5  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
000000018037C5BD  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
000000018037C5C5  F3 0F 59 D0                 mulss   xmm2, xmm0
000000018037C5C9  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
000000018037C5D1  F3 0F 5C CA                 subss   xmm1, xmm2
000000018037C5D5  F3 0F 10 93 60 CE 00 00     movss   xmm2, dword ptr [rbx+0CE60h]
000000018037C5DD  F3 0F 11 93 70 CE 00 00     movss   dword ptr [rbx+0CE70h], xmm2
000000018037C5E5  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037C5E9  F3 0F 10 83 40 CE 00 00     movss   xmm0, dword ptr [rbx+0CE40h]
000000018037C5F1  F3 0F 59 D0                 mulss   xmm2, xmm0
000000018037C5F5  F3 0F 11 83 50 CE 00 00     movss   dword ptr [rbx+0CE50h], xmm0
000000018037C5FD  F3 0F 59 DA                 mulss   xmm3, xmm2
000000018037C601  0F 28 C2                    movaps  xmm0, xmm2
000000018037C604  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
000000018037C60C  F3 0F 10 8B 80 CE 00 00     movss   xmm1, dword ptr [rbx+0CE80h]
000000018037C614  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037C618  F3 0F 59 F2                 mulss   xmm6, xmm2
000000018037C61C  F3 0F 11 8B A0 CE 00 00     movss   dword ptr [rbx+0CEA0h], xmm1
000000018037C624  F3 0F 11 93 10 CF 00 00     movss   dword ptr [rbx+0CF10h], xmm2
000000018037C62C  F3 0F 5C F0                 subss   xmm6, xmm0
000000018037C630  0F 28 C4                    movaps  xmm0, xmm4
000000018037C633  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037C637  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037C63B  F3 0F 58 F1                 addss   xmm6, xmm1
000000018037C63F  F3 0F 58 DC                 addss   xmm3, xmm4
000000018037C643  F3 0F 11 B3 20 CF 00 00     movss   dword ptr [rbx+0CF20h], xmm6
000000018037C64B  F3 0F 11 9B 30 CF 00 00     movss   dword ptr [rbx+0CF30h], xmm3
000000018037C653  0F 28 CB                    movaps  xmm1, xmm3
000000018037C656  F3 0F 58 9B 70 CF 00 00     addss   xmm3, dword ptr [rbx+0CF70h]
000000018037C65E  41 0F 2F DE                 comiss  xmm3, xmm14
000000018037C662  72 05                       jb      short loc_18037C669
000000018037C664  0F 57 C0                    xorps   xmm0, xmm0
000000018037C667  EB 03                       jmp     short loc_18037C66C
000000018037C669  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018037C66C  41 0F 2E CE                 ucomiss xmm1, xmm14
000000018037C670  F3 44 0F 10 3D 6B 8E 76 00  movss   xmm15, cs:dword_180AE54E4
000000018037C679  75 06                       jnz     short loc_18037C681
000000018037C67B  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037C67F  EB 04                       jmp     short loc_18037C685
000000018037C681  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
000000018037C685  41 0F 2F EE                 comiss  xmm5, xmm14
000000018037C689  F3 0F 11 AB 40 CF 00 00     movss   dword ptr [rbx+0CF40h], xmm5
000000018037C691  73 06                       jnb     short loc_18037C699
000000018037C693  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037C697  EB 06                       jmp     short loc_18037C69F
000000018037C699  76 04                       jbe     short loc_18037C69F
000000018037C69B  41 0F 28 ED                 movaps  xmm5, xmm13
000000018037C69F  F3 0F 10 83 B0 CF 00 00     movss   xmm0, dword ptr [rbx+0CFB0h]
000000018037C6A7  F3 41 0F 58 ED              addss   xmm5, xmm13
000000018037C6AC  F3 0F 10 93 50 D0 00 00     movss   xmm2, dword ptr [rbx+0D050h]
000000018037C6B4  F3 0F 10 8B C0 CF 00 00     movss   xmm1, dword ptr [rbx+0CFC0h]
000000018037C6BC  8B 83 80 CF 00 00           mov     eax, [rbx+0CF80h]
000000018037C6C2  0F 28 D9                    movaps  xmm3, xmm1
000000018037C6C5  F3 0F 10 A3 10 D0 00 00     movss   xmm4, dword ptr [rbx+0D010h]
000000018037C6CD  F3 0F 58 9B 60 D0 00 00     addss   xmm3, dword ptr [rbx+0D060h]
000000018037C6D5  F2 44 0F 10 25 C2 8A 76 00  movsd   xmm12, cs:dbl_180AE51A0
000000018037C6DE  F3 0F 11 AB 60 CF 00 00     movss   dword ptr [rbx+0CF60h], xmm5
000000018037C6E6  F3 0F 11 AB 80 CF 00 00     movss   dword ptr [rbx+0CF80h], xmm5
000000018037C6EE  F3 0F 59 E8                 mulss   xmm5, xmm0
000000018037C6F2  89 83 90 CF 00 00           mov     [rbx+0CF90h], eax
000000018037C6F8  F3 0F 11 A3 20 D0 00 00     movss   dword ptr [rbx+0D020h], xmm4
000000018037C700  F3 0F 5C E8                 subss   xmm5, xmm0
000000018037C704  0F 28 C2                    movaps  xmm0, xmm2
000000018037C707  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037C70B  F3 0F 10 8B F0 CF 00 00     movss   xmm1, dword ptr [rbx+0CFF0h]
000000018037C713  F3 0F 58 83 70 D0 00 00     addss   xmm0, dword ptr [rbx+0D070h]
000000018037C71B  F3 41 0F 58 ED              addss   xmm5, xmm13
000000018037C720  F3 0F 5E C8                 divss   xmm1, xmm0
000000018037C724  F3 0F 10 83 80 D0 00 00     movss   xmm0, dword ptr [rbx+0D080h]
000000018037C72C  F3 0F 59 AB A0 CF 00 00     mulss   xmm5, dword ptr [rbx+0CFA0h]
000000018037C734  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018037C738  F3 0F 10 93 E0 CF 00 00     movss   xmm2, dword ptr [rbx+0CFE0h]
000000018037C740  F3 0F 11 AB 30 D0 00 00     movss   dword ptr [rbx+0D030h], xmm5
000000018037C748  F3 0F 5C D1                 subss   xmm2, xmm1
000000018037C74C  F3 0F 10 8B 00 D0 00 00     movss   xmm1, dword ptr [rbx+0D000h]
000000018037C754  F3 0F 58 D6                 addss   xmm2, xmm6
000000018037C758  F3 0F 5C D4                 subss   xmm2, xmm4
000000018037C75C  F3 0F 11 93 E0 CF 00 00     movss   dword ptr [rbx+0CFE0h], xmm2
000000018037C764  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037C768  F3 0F 11 93 F0 CF 00 00     movss   dword ptr [rbx+0CFF0h], xmm2
000000018037C770  F3 0F 58 D4                 addss   xmm2, xmm4
000000018037C774  F3 0F 5C E6                 subss   xmm4, xmm6
000000018037C778  0F 54 25 11 90 76 00        andps   xmm4, cs:xmmword_180AE5790
000000018037C77F  F3 0F 5C C4                 subss   xmm0, xmm4
000000018037C783  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037C787  0F 83 E8 00 00 00           jnb     loc_18037C875
000000018037C78D  0F 57 C9                    xorps   xmm1, xmm1
000000018037C790  0F 5A C1                    cvtps2pd xmm0, xmm1
000000018037C793  41 0F 2E EE                 ucomiss xmm5, xmm14
000000018037C797  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018037C79B  0F 28 C8                    movaps  xmm1, xmm0
000000018037C79E  F3 0F 11 83 00 D0 00 00     movss   dword ptr [rbx+0D000h], xmm0
000000018037C7A6  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018037C7AA  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037C7AE  F3 0F 5C C8                 subss   xmm1, xmm0
000000018037C7B2  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037C7B6  75 03                       jnz     short loc_18037C7BB
000000018037C7B8  0F 28 CE                    movaps  xmm1, xmm6
000000018037C7BB  8B 83 C0 D0 00 00           mov     eax, [rbx+0D0C0h]
000000018037C7C1  48 8D 0D 38 38 C8 FF        lea     rcx, cs:180000000h
000000018037C7C8  F3 0F 59 BB B0 D0 00 00     mulss   xmm7, dword ptr [rbx+0D0B0h]
000000018037C7D0  89 83 D0 D0 00 00           mov     [rbx+0D0D0h], eax
000000018037C7D6  F3 44 0F 59 83 A0 D0 00 00  mulss   xmm8, dword ptr [rbx+0D0A0h]
000000018037C7DF  F3 0F 10 83 E0 D1 00 00     movss   xmm0, dword ptr [rbx+0D1E0h]
000000018037C7E7  F3 0F 10 93 E0 D0 00 00     movss   xmm2, dword ptr [rbx+0D0E0h]
000000018037C7EF  F3 44 0F 10 8B 40 D1 00 00  movss   xmm9, dword ptr [rbx+0D140h]
000000018037C7F8  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018037C7FD  F3 44 0F 10 83 20 D1 00 00  movss   xmm8, dword ptr [rbx+0D120h]
000000018037C806  F3 0F 2C C0                 cvttss2si eax, xmm0
000000018037C80A  F3 0F 11 BB C0 D0 00 00     movss   dword ptr [rbx+0D0C0h], xmm7
000000018037C812  F3 0F 10 BB 00 D1 00 00     movss   xmm7, dword ptr [rbx+0D100h]
000000018037C81A  F3 0F 11 8B 10 D0 00 00     movss   dword ptr [rbx+0D010h], xmm1
000000018037C822  F3 0F 11 8B 40 D0 00 00     movss   dword ptr [rbx+0D040h], xmm1
000000018037C82A  F3 0F 10 8B A0 D1 00 00     movss   xmm1, dword ptr [rbx+0D1A0h]
000000018037C832  F3 0F 11 BB 10 D1 00 00     movss   dword ptr [rbx+0D110h], xmm7
000000018037C83A  F3 0F 11 93 F0 D0 00 00     movss   dword ptr [rbx+0D0F0h], xmm2
000000018037C842  F3 44 0F 11 83 30 D1 00 00  movss   dword ptr [rbx+0D130h], xmm8
000000018037C84B  F3 44 0F 11 8B 50 D1 00 00  movss   dword ptr [rbx+0D150h], xmm9
000000018037C854  F3 0F 11 8B B0 D1 00 00     movss   dword ptr [rbx+0D1B0h], xmm1
000000018037C85C  83 F8 E0                    cmp     eax, 0FFFFFFE0h
000000018037C85F  7D 2F                       jge     short loc_18037C890
000000018037C861  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
000000018037C866  F7 D0                       not     eax
000000018037C868  48 98                       cdqe
000000018037C86A  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018037C873  EB 47                       jmp     short loc_18037C8BC
000000018037C875  F3 0F 58 8B 90 D0 00 00     addss   xmm1, dword ptr [rbx+0D090h]
000000018037C87D  41 0F 2F CD                 comiss  xmm1, xmm13
000000018037C881  0F 82 09 FF FF FF           jb      loc_18037C790
000000018037C887  41 0F 28 C4                 movaps  xmm0, xmm12
000000018037C88B  E9 03 FF FF FF              jmp     loc_18037C793
000000018037C890  83 F8 20                    cmp     eax, 20h ; ' '
000000018037C893  7E 07                       jle     short loc_18037C89C
000000018037C895  B8 20 00 00 00              mov     eax, 20h ; ' '
000000018037C89A  EB 15                       jmp     short loc_18037C8B1
000000018037C89C  85 C0                       test    eax, eax
000000018037C89E  79 0F                       jns     short loc_18037C8AF
000000018037C8A0  F7 D0                       not     eax
000000018037C8A2  48 98                       cdqe
000000018037C8A4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018037C8AD  EB 0D                       jmp     short loc_18037C8BC
000000018037C8AF  7E 0B                       jle     short loc_18037C8BC
000000018037C8B1  48 98                       cdqe
000000018037C8B3  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
000000018037C8BC  0F 57 05 FD 8E 76 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037C8C3  F3 0F 2C C0                 cvttss2si eax, xmm0
000000018037C8C7  83 F8 E0                    cmp     eax, 0FFFFFFE0h
000000018037C8CA  7D 14                       jge     short loc_18037C8E0
000000018037C8CC  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
000000018037C8D1  F7 D0                       not     eax
000000018037C8D3  48 98                       cdqe
000000018037C8D5  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018037C8DE  EB 2C                       jmp     short loc_18037C90C
000000018037C8E0  83 F8 20                    cmp     eax, 20h ; ' '
000000018037C8E3  7E 07                       jle     short loc_18037C8EC
000000018037C8E5  B8 20 00 00 00              mov     eax, 20h ; ' '
000000018037C8EA  EB 15                       jmp     short loc_18037C901
000000018037C8EC  85 C0                       test    eax, eax
000000018037C8EE  79 0F                       jns     short loc_18037C8FF
000000018037C8F0  F7 D0                       not     eax
000000018037C8F2  48 98                       cdqe
000000018037C8F4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018037C8FD  EB 0D                       jmp     short loc_18037C90C
000000018037C8FF  7E 0B                       jle     short loc_18037C90C
000000018037C901  48 98                       cdqe
000000018037C903  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
000000018037C90C  F3 0F 10 83 60 D1 00 00     movss   xmm0, dword ptr [rbx+0D160h]
000000018037C914  F3 0F 5C D1                 subss   xmm2, xmm1
000000018037C918  F3 0F 59 93 D0 D1 00 00     mulss   xmm2, dword ptr [rbx+0D1D0h]
000000018037C920  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037C924  F3 0F 10 8B 90 D1 00 00     movss   xmm1, dword ptr [rbx+0D190h]
000000018037C92C  F3 0F 11 93 A0 D1 00 00     movss   dword ptr [rbx+0D1A0h], xmm2
000000018037C934  F3 0F 59 D0                 mulss   xmm2, xmm0
000000018037C938  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037C93C  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037C940  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037C944  41 0F 2F D6                 comiss  xmm2, xmm14
000000018037C948  76 05                       jbe     short loc_18037C94F
000000018037C94A  0F 5A C2                    cvtps2pd xmm0, xmm2
000000018037C94D  EB 03                       jmp     short loc_18037C952
000000018037C94F  0F 57 C0                    xorps   xmm0, xmm0
000000018037C952  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
000000018037C956  41 0F 2F CD                 comiss  xmm1, xmm13
000000018037C95A  72 06                       jb      short loc_18037C962
000000018037C95C  41 0F 28 C4                 movaps  xmm0, xmm12
000000018037C960  EB 03                       jmp     short loc_18037C965
000000018037C962  0F 5A C1                    cvtps2pd xmm0, xmm1
000000018037C965  F3 0F 10 B3 70 D1 00 00     movss   xmm6, dword ptr [rbx+0D170h]
000000018037C96D  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018037C971  F3 0F 59 83 00 D2 00 00     mulss   xmm0, dword ptr [rbx+0D200h]; X
000000018037C979  E8 C2 2D 37 00              call    expf
000000018037C97E  F3 0F 59 83 F0 D1 00 00     mulss   xmm0, dword ptr [rbx+0D1F0h]
000000018037C986  0F 28 CE                    movaps  xmm1, xmm6
000000018037C989  8B 83 70 D3 00 00           mov     eax, [rbx+0D370h]
000000018037C98F  F3 0F 59 8B 80 D1 00 00     mulss   xmm1, dword ptr [rbx+0D180h]
000000018037C997  89 83 80 D3 00 00           mov     [rbx+0D380h], eax
000000018037C99D  F3 0F 58 83 10 D2 00 00     addss   xmm0, dword ptr [rbx+0D210h]
000000018037C9A5  8B 83 90 D3 00 00           mov     eax, [rbx+0D390h]
000000018037C9AB  F3 0F 10 9B 30 D3 00 00     movss   xmm3, dword ptr [rbx+0D330h]
000000018037C9B3  F3 0F 59 BB C0 D4 00 00     mulss   xmm7, dword ptr [rbx+0D4C0h]
000000018037C9BB  89 83 A0 D3 00 00           mov     [rbx+0D3A0h], eax
000000018037C9C1  8B 83 B0 D3 00 00           mov     eax, [rbx+0D3B0h]
000000018037C9C7  F3 0F 10 93 20 D3 00 00     movss   xmm2, dword ptr [rbx+0D320h]
000000018037C9CF  F3 0F 10 A3 50 D3 00 00     movss   xmm4, dword ptr [rbx+0D350h]
000000018037C9D7  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018037C9DB  89 83 C0 D3 00 00           mov     [rbx+0D3C0h], eax
000000018037C9E1  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
000000018037C9E7  F3 0F 11 9B 40 D3 00 00     movss   dword ptr [rbx+0D340h], xmm3
000000018037C9EF  F3 0F 5C CE                 subss   xmm1, xmm6
000000018037C9F3  F3 0F 11 93 30 D3 00 00     movss   dword ptr [rbx+0D330h], xmm2
000000018037C9FB  F3 0F 11 A3 60 D3 00 00     movss   dword ptr [rbx+0D360h], xmm4
000000018037CA03  F3 44 0F 11 83 F0 D2 00 00  movss   dword ptr [rbx+0D2F0h], xmm8
000000018037CA0C  F3 44 0F 11 8B 00 D3 00 00  movss   dword ptr [rbx+0D300h], xmm9
000000018037CA15  89 83 E0 D2 00 00           mov     [rbx+0D2E0h], eax
000000018037CA1B  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037CA1F  F3 0F 10 83 90 D4 00 00     movss   xmm0, dword ptr [rbx+0D490h]
000000018037CA27  F3 0F 58 F8                 addss   xmm7, xmm0
000000018037CA2B  F3 0F 11 83 80 D4 00 00     movss   dword ptr [rbx+0D480h], xmm0
000000018037CA33  F3 0F 11 8B C0 D1 00 00     movss   dword ptr [rbx+0D1C0h], xmm1
000000018037CA3B  41 0F 2F FF                 comiss  xmm7, xmm15
000000018037CA3F  73 06                       jnb     short loc_18037CA47
000000018037CA41  41 0F 28 FF                 movaps  xmm7, xmm15
000000018037CA45  EB 05                       jmp     short loc_18037CA4C
000000018037CA47  F3 41 0F 5D FD              minss   xmm7, xmm13
000000018037CA4C  F3 0F 59 0D 6C E3 60 00     mulss   xmm1, cs:dword_18098ADC0
000000018037CA54  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037CA58  F3 0F 10 B3 A0 D5 00 00     movss   xmm6, dword ptr [rbx+0D5A0h]
000000018037CA60  F3 0F 5C C3                 subss   xmm0, xmm3
000000018037CA64  F3 0F 11 BB 20 D3 00 00     movss   dword ptr [rbx+0D320h], xmm7
000000018037CA6C  F3 0F 5D F1                 minss   xmm6, xmm1
000000018037CA70  F3 0F 59 83 D0 D4 00 00     mulss   xmm0, dword ptr [rbx+0D4D0h]
000000018037CA78  F3 0F 58 C3                 addss   xmm0, xmm3
000000018037CA7C  41 0F 2F C7                 comiss  xmm0, xmm15
000000018037CA80  73 06                       jnb     short loc_18037CA88
000000018037CA82  41 0F 28 C7                 movaps  xmm0, xmm15
000000018037CA86  EB 05                       jmp     short loc_18037CA8D
000000018037CA88  F3 41 0F 5D C5              minss   xmm0, xmm13
000000018037CA8D  F3 0F 59 B3 B0 D5 00 00     mulss   xmm6, dword ptr [rbx+0D5B0h]
000000018037CA95  F3 0F 5C D7                 subss   xmm2, xmm7
000000018037CA99  F3 0F 11 B3 D0 D3 00 00     movss   dword ptr [rbx+0D3D0h], xmm6
000000018037CAA1  F3 0F 58 F4                 addss   xmm6, xmm4
000000018037CAA5  41 0F 2F D6                 comiss  xmm2, xmm14
000000018037CAA9  73 03                       jnb     short loc_18037CAAE
000000018037CAAB  0F 57 C0                    xorps   xmm0, xmm0
000000018037CAAE  F3 0F 10 8B A0 D4 00 00     movss   xmm1, dword ptr [rbx+0D4A0h]
000000018037CAB6  F3 44 0F 10 9B E0 D2 00 00  movss   xmm11, dword ptr [rbx+0D2E0h]
000000018037CABF  F3 0F 11 83 30 D3 00 00     movss   dword ptr [rbx+0D330h], xmm0
000000018037CAC7  F3 0F 58 83 30 D6 00 00     addss   xmm0, dword ptr [rbx+0D630h]
000000018037CACF  72 04                       jb      short loc_18037CAD5
000000018037CAD1  41 0F 28 CD                 movaps  xmm1, xmm13
000000018037CAD5  F3 0F 59 83 20 D6 00 00     mulss   xmm0, dword ptr [rbx+0D620h]
000000018037CADD  41 0F 28 FB                 movaps  xmm7, xmm11
000000018037CAE1  F3 0F 10 93 80 D3 00 00     movss   xmm2, dword ptr [rbx+0D380h]
000000018037CAE9  F3 0F 59 F1                 mulss   xmm6, xmm1
000000018037CAED  F3 0F 5C FA                 subss   xmm7, xmm2
000000018037CAF1  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037CAF5  F3 0F 59 B3 B0 D4 00 00     mulss   xmm6, dword ptr [rbx+0D4B0h]
000000018037CAFD  76 05                       jbe     short loc_18037CB04
000000018037CAFF  0F 5A C8                    cvtps2pd xmm1, xmm0
000000018037CB02  EB 03                       jmp     short loc_18037CB07
000000018037CB04  0F 57 C9                    xorps   xmm1, xmm1
000000018037CB07  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037CB0B  F3 0F 59 BB F0 D6 00 00     mulss   xmm7, dword ptr [rbx+0D6F0h]
000000018037CB13  F3 44 0F 10 0D CC 86 76 00  movss   xmm9, cs:flt_180AE51E8
000000018037CB1C  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
000000018037CB20  F3 0F 58 FA                 addss   xmm7, xmm2
000000018037CB24  F3 0F 11 BB 70 D3 00 00     movss   dword ptr [rbx+0D370h], xmm7
000000018037CB2C  F3 0F 11 83 10 D3 00 00     movss   dword ptr [rbx+0D310h], xmm0
000000018037CB34  41 0F 28 C3                 movaps  xmm0, xmm11
000000018037CB38  F3 0F 59 BB E0 D6 00 00     mulss   xmm7, dword ptr [rbx+0D6E0h]
000000018037CB40  F3 0F 10 8B 60 D5 00 00     movss   xmm1, dword ptr [rbx+0D560h]
000000018037CB48  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037CB4C  F3 0F 59 F9                 mulss   xmm7, xmm1
000000018037CB50  F3 0F 5C F8                 subss   xmm7, xmm0
000000018037CB54  F3 0F 10 83 60 D3 00 00     movss   xmm0, dword ptr [rbx+0D360h]
000000018037CB5C  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
000000018037CB65  F3 41 0F 58 FB              addss   xmm7, xmm11
000000018037CB6A  76 1B                       jbe     short loc_18037CB87
000000018037CB6C  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037CB71  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018037CB75  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037CB78  E8 5B 29 37 00              call    fmodf
000000018037CB7D  0F 28 F0                    movaps  xmm6, xmm0
000000018037CB80  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037CB85  EB 1F                       jmp     short loc_18037CBA6
000000018037CB87  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037CB8B  73 19                       jnb     short loc_18037CBA6
000000018037CB8D  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037CB92  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018037CB96  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037CB99  E8 3A 29 37 00              call    fmodf
000000018037CB9E  0F 28 F0                    movaps  xmm6, xmm0
000000018037CBA1  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037CBA6  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
000000018037CBAF  0F 28 C6                    movaps  xmm0, xmm6
000000018037CBB2  41 0F 2F CE                 comiss  xmm1, xmm14
000000018037CBB6  F3 44 0F 10 83 A0 D3 00 00  movss   xmm8, dword ptr [rbx+0D3A0h]
000000018037CBBF  F3 0F 11 B3 50 D3 00 00     movss   dword ptr [rbx+0D350h], xmm6
000000018037CBC7  F3 0F 59 BB D0 D6 00 00     mulss   xmm7, dword ptr [rbx+0D6D0h]
000000018037CBCF  F3 0F 58 83 40 D6 00 00     addss   xmm0, dword ptr [rbx+0D640h]
000000018037CBD7  F3 0F 11 BB D0 D2 00 00     movss   dword ptr [rbx+0D2D0h], xmm7
000000018037CBDF  73 0A                       jnb     short loc_18037CBEB
000000018037CBE1  41 0F 2F F6                 comiss  xmm6, xmm14
000000018037CBE5  76 04                       jbe     short loc_18037CBEB
000000018037CBE7  45 0F 28 C3                 movaps  xmm8, xmm11
000000018037CBEB  41 0F 2F C5                 comiss  xmm0, xmm13
000000018037CBEF  76 15                       jbe     short loc_18037CC06
000000018037CBF1  F3 41 0F 58 C5              addss   xmm0, xmm13; X
000000018037CBF6  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018037CBFA  E8 D9 28 37 00              call    fmodf
000000018037CBFF  F3 41 0F 5C C5              subss   xmm0, xmm13
000000018037CC04  EB 19                       jmp     short loc_18037CC1F
000000018037CC06  41 0F 2F C7                 comiss  xmm0, xmm15
000000018037CC0A  73 13                       jnb     short loc_18037CC1F
000000018037CC0C  F3 41 0F 5C C5              subss   xmm0, xmm13; X
000000018037CC11  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018037CC15  E8 BE 28 37 00              call    fmodf
000000018037CC1A  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037CC1F  F3 44 0F 10 1D 98 8B 76 00  movss   xmm11, dword ptr cs:xmmword_180AE57C0
000000018037CC28  F3 44 0F 11 83 90 D3 00 00  movss   dword ptr [rbx+0D390h], xmm8
000000018037CC31  F3 0F 59 83 80 D6 00 00     mulss   xmm0, dword ptr [rbx+0D680h]
000000018037CC39  F3 44 0F 59 83 C0 D6 00 00  mulss   xmm8, dword ptr [rbx+0D6C0h]
000000018037CC42  F3 0F 58 83 00 D7 00 00     addss   xmm0, dword ptr [rbx+0D700h]
000000018037CC4A  F3 0F 11 83 E0 D3 00 00     movss   dword ptr [rbx+0D3E0h], xmm0
000000018037CC52  41 0F 57 C3                 xorps   xmm0, xmm11
000000018037CC56  F3 44 0F 11 83 30 D4 00 00  movss   dword ptr [rbx+0D430h], xmm8
000000018037CC5F  44 0F 28 C6                 movaps  xmm8, xmm6
000000018037CC63  F3 44 0F 58 83 60 D6 00 00  addss   xmm8, dword ptr [rbx+0D660h]
000000018037CC6C  F3 0F 11 83 F0 D3 00 00     movss   dword ptr [rbx+0D3F0h], xmm0
000000018037CC74  45 0F 2F C5                 comiss  xmm8, xmm13
000000018037CC78  76 1D                       jbe     short loc_18037CC97
000000018037CC7A  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018037CC7F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018037CC83  41 0F 28 C0                 movaps  xmm0, xmm8; X
000000018037CC87  E8 4C 28 37 00              call    fmodf
000000018037CC8C  44 0F 28 C0                 movaps  xmm8, xmm0
000000018037CC90  F3 45 0F 5C C5              subss   xmm8, xmm13
000000018037CC95  EB 21                       jmp     short loc_18037CCB8
000000018037CC97  45 0F 2F C7                 comiss  xmm8, xmm15
000000018037CC9B  73 1B                       jnb     short loc_18037CCB8
000000018037CC9D  F3 45 0F 5C C5              subss   xmm8, xmm13
000000018037CCA2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018037CCA6  41 0F 28 C0                 movaps  xmm0, xmm8; X
000000018037CCAA  E8 29 28 37 00              call    fmodf
000000018037CCAF  44 0F 28 C0                 movaps  xmm8, xmm0
000000018037CCB3  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018037CCB8  0F 28 FE                    movaps  xmm7, xmm6
000000018037CCBB  F3 0F 58 BB 50 D6 00 00     addss   xmm7, dword ptr [rbx+0D650h]
000000018037CCC3  41 0F 2F FD                 comiss  xmm7, xmm13
000000018037CCC7  76 1B                       jbe     short loc_18037CCE4
000000018037CCC9  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037CCCE  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018037CCD2  0F 28 C7                    movaps  xmm0, xmm7; X
000000018037CCD5  E8 FE 27 37 00              call    fmodf
000000018037CCDA  0F 28 F8                    movaps  xmm7, xmm0
000000018037CCDD  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037CCE2  EB 1F                       jmp     short loc_18037CD03
000000018037CCE4  41 0F 2F FF                 comiss  xmm7, xmm15
000000018037CCE8  73 19                       jnb     short loc_18037CD03
000000018037CCEA  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037CCEF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018037CCF3  0F 28 C7                    movaps  xmm0, xmm7; X
000000018037CCF6  E8 DD 27 37 00              call    fmodf
000000018037CCFB  0F 28 F8                    movaps  xmm7, xmm0
000000018037CCFE  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037CD03  41 0F 28 C0                 movaps  xmm0, xmm8
000000018037CD07  E8 B4 C2 FE FF              call    sub_180368FC0
000000018037CD0C  F3 0F 58 BB 10 D7 00 00     addss   xmm7, dword ptr [rbx+0D710h]
000000018037CD14  F3 0F 59 83 A0 D6 00 00     mulss   xmm0, dword ptr [rbx+0D6A0h]
000000018037CD1C  41 0F 2F FE                 comiss  xmm7, xmm14
000000018037CD20  73 06                       jnb     short loc_18037CD28
000000018037CD22  41 0F 28 FF                 movaps  xmm7, xmm15
000000018037CD26  EB 06                       jmp     short loc_18037CD2E
000000018037CD28  76 04                       jbe     short loc_18037CD2E
000000018037CD2A  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037CD2E  F3 0F 58 B3 70 D6 00 00     addss   xmm6, dword ptr [rbx+0D670h]
000000018037CD36  F3 0F 11 83 10 D4 00 00     movss   dword ptr [rbx+0D410h], xmm0
000000018037CD3E  F3 0F 11 BB 70 D4 00 00     movss   dword ptr [rbx+0D470h], xmm7
000000018037CD46  F3 0F 59 BB 90 D6 00 00     mulss   xmm7, dword ptr [rbx+0D690h]
000000018037CD4E  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037CD52  F3 0F 58 BB 20 D7 00 00     addss   xmm7, dword ptr [rbx+0D720h]
000000018037CD5A  76 1B                       jbe     short loc_18037CD77
000000018037CD5C  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037CD61  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018037CD65  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037CD68  E8 6B 27 37 00              call    fmodf
000000018037CD6D  0F 28 F0                    movaps  xmm6, xmm0
000000018037CD70  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037CD75  EB 1F                       jmp     short loc_18037CD96
000000018037CD77  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037CD7B  73 19                       jnb     short loc_18037CD96
000000018037CD7D  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037CD82  41 0F 28 C9                 movaps  xmm1, xmm9; Y
000000018037CD86  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037CD89  E8 4A 27 37 00              call    fmodf
000000018037CD8E  0F 28 F0                    movaps  xmm6, xmm0
000000018037CD91  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037CD96  0F 54 35 F3 89 76 00        andps   xmm6, cs:xmmword_180AE5790
000000018037CD9D  F3 0F 11 BB 00 D4 00 00     movss   dword ptr [rbx+0D400h], xmm7
000000018037CDA5  0F 28 E6                    movaps  xmm4, xmm6
000000018037CDA8  F3 0F 10 9B 40 D5 00 00     movss   xmm3, dword ptr [rbx+0D540h]
000000018037CDB0  0F 28 D6                    movaps  xmm2, xmm6
000000018037CDB3  F3 0F 59 93 D0 D5 00 00     mulss   xmm2, dword ptr [rbx+0D5D0h]
000000018037CDBB  F3 0F 59 9B 30 D4 00 00     mulss   xmm3, dword ptr [rbx+0D430h]
000000018037CDC3  F3 0F 58 93 C0 D5 00 00     addss   xmm2, dword ptr [rbx+0D5C0h]
000000018037CDCB  F3 0F 10 8B 30 D5 00 00     movss   xmm1, dword ptr [rbx+0D530h]
000000018037CDD3  F3 0F 59 8B F0 D3 00 00     mulss   xmm1, dword ptr [rbx+0D3F0h]
000000018037CDDB  F3 0F 59 E6                 mulss   xmm4, xmm6
000000018037CDDF  0F 28 C4                    movaps  xmm0, xmm4
000000018037CDE2  F3 0F 59 E6                 mulss   xmm4, xmm6
000000018037CDE6  F3 0F 59 83 E0 D5 00 00     mulss   xmm0, dword ptr [rbx+0D5E0h]
000000018037CDEE  F3 0F 59 F4                 mulss   xmm6, xmm4
000000018037CDF2  F3 0F 59 A3 F0 D5 00 00     mulss   xmm4, dword ptr [rbx+0D5F0h]
000000018037CDFA  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037CDFE  F3 0F 59 B3 00 D6 00 00     mulss   xmm6, dword ptr [rbx+0D600h]
000000018037CE06  F3 0F 10 83 20 D5 00 00     movss   xmm0, dword ptr [rbx+0D520h]
000000018037CE0E  F3 0F 59 83 E0 D3 00 00     mulss   xmm0, dword ptr [rbx+0D3E0h]
000000018037CE16  F3 0F 58 E2                 addss   xmm4, xmm2
000000018037CE1A  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037CE1E  F3 0F 58 F4                 addss   xmm6, xmm4
000000018037CE22  F3 0F 10 A3 00 D5 00 00     movss   xmm4, dword ptr [rbx+0D500h]
000000018037CE2A  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037CE2E  F3 0F 58 B3 10 D6 00 00     addss   xmm6, dword ptr [rbx+0D610h]
000000018037CE36  F3 0F 59 B3 B0 D6 00 00     mulss   xmm6, dword ptr [rbx+0D6B0h]
000000018037CE3E  F3 0F 11 B3 20 D4 00 00     movss   dword ptr [rbx+0D420h], xmm6
000000018037CE46  F3 0F 59 A3 10 D4 00 00     mulss   xmm4, dword ptr [rbx+0D410h]
000000018037CE4E  F3 0F 10 8B E0 D4 00 00     movss   xmm1, dword ptr [rbx+0D4E0h]
000000018037CE56  F3 0F 10 83 10 D5 00 00     movss   xmm0, dword ptr [rbx+0D510h]
000000018037CE5E  F3 0F 59 83 00 D4 00 00     mulss   xmm0, dword ptr [rbx+0D400h]
000000018037CE66  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037CE6A  F3 0F 10 93 70 D5 00 00     movss   xmm2, dword ptr [rbx+0D570h]
000000018037CE72  0F 28 D9                    movaps  xmm3, xmm1
000000018037CE75  F3 0F 59 9B 10 D3 00 00     mulss   xmm3, dword ptr [rbx+0D310h]
000000018037CE7D  F3 0F 59 B3 F0 D4 00 00     mulss   xmm6, dword ptr [rbx+0D4F0h]
000000018037CE85  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037CE89  F3 0F 10 83 50 D5 00 00     movss   xmm0, dword ptr [rbx+0D550h]
000000018037CE91  F3 0F 5C D9                 subss   xmm3, xmm1
000000018037CE95  F3 0F 59 83 D0 D2 00 00     mulss   xmm0, dword ptr [rbx+0D2D0h]
000000018037CE9D  F3 0F 58 E6                 addss   xmm4, xmm6
000000018037CEA1  F3 41 0F 58 DD              addss   xmm3, xmm13
000000018037CEA6  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037CEAA  F3 0F 11 9B 40 D4 00 00     movss   dword ptr [rbx+0D440h], xmm3
000000018037CEB2  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037CEB6  F3 0F 11 A3 60 D4 00 00     movss   dword ptr [rbx+0D460h], xmm4
000000018037CEBE  F3 0F 10 8B 90 D5 00 00     movss   xmm1, dword ptr [rbx+0D590h]
000000018037CEC6  F3 0F 59 8B 00 D3 00 00     mulss   xmm1, dword ptr [rbx+0D300h]
000000018037CECE  F3 0F 10 83 80 D5 00 00     movss   xmm0, dword ptr [rbx+0D580h]
000000018037CED6  F3 0F 59 83 F0 D2 00 00     mulss   xmm0, dword ptr [rbx+0D2F0h]
000000018037CEDE  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037CEE2  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037CEE6  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037CEEA  F3 0F 11 8B 50 D4 00 00     movss   dword ptr [rbx+0D450h], xmm1
000000018037CEF2  F3 0F 10 83 60 D4 00 00     movss   xmm0, dword ptr [rbx+0D460h]
000000018037CEFA  8B 83 70 D4 00 00           mov     eax, [rbx+0D470h]
000000018037CF00  89 83 30 D7 00 00           mov     [rbx+0D730h], eax
000000018037CF06  F3 0F 11 83 40 D7 00 00     movss   dword ptr [rbx+0D740h], xmm0
000000018037CF0E  44 0F 2F B3 70 D4 00 00     comiss  xmm14, dword ptr [rbx+0D470h]
000000018037CF16  F3 0F 10 8B 80 CF 00 00     movss   xmm1, dword ptr [rbx+0CF80h]
000000018037CF1E  F3 0F 10 93 50 D7 00 00     movss   xmm2, dword ptr [rbx+0D750h]
000000018037CF26  73 06                       jnb     short loc_18037CF2E
000000018037CF28  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037CF2C  EB 03                       jmp     short loc_18037CF31
000000018037CF2E  0F 57 C0                    xorps   xmm0, xmm0
000000018037CF31  41 0F 2E D6                 ucomiss xmm2, xmm14
000000018037CF35  75 04                       jnz     short loc_18037CF3B
000000018037CF37  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037CF3B  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037CF3F  F3 0F 11 8B 60 D7 00 00     movss   dword ptr [rbx+0D760h], xmm1
000000018037CF47  8B 83 70 D7 00 00           mov     eax, [rbx+0D770h]
000000018037CF4D  89 83 80 D7 00 00           mov     [rbx+0D780h], eax
000000018037CF53  8B 83 A0 D7 00 00           mov     eax, [rbx+0D7A0h]
000000018037CF59  89 83 B0 D7 00 00           mov     [rbx+0D7B0h], eax
000000018037CF5F  8B 83 90 D7 00 00           mov     eax, [rbx+0D790h]
000000018037CF65  89 83 A0 D7 00 00           mov     [rbx+0D7A0h], eax
000000018037CF6B  8B 83 C0 D7 00 00           mov     eax, [rbx+0D7C0h]
000000018037CF71  89 83 D0 D7 00 00           mov     [rbx+0D7D0h], eax
000000018037CF77  8B 83 F0 D7 00 00           mov     eax, [rbx+0D7F0h]
000000018037CF7D  89 83 00 D8 00 00           mov     [rbx+0D800h], eax
000000018037CF83  F3 0F 10 83 A0 D8 00 00     movss   xmm0, dword ptr [rbx+0D8A0h]
000000018037CF8B  F3 0F 58 8B 80 D8 00 00     addss   xmm1, dword ptr [rbx+0D880h]
000000018037CF93  F3 0F 59 83 B0 D7 00 00     mulss   xmm0, dword ptr [rbx+0D7B0h]
000000018037CF9B  41 0F 2F CE                 comiss  xmm1, xmm14
000000018037CF9F  F3 0F 58 83 80 D7 00 00     addss   xmm0, dword ptr [rbx+0D780h]
000000018037CFA7  73 06                       jnb     short loc_18037CFAF
000000018037CFA9  45 0F 28 C5                 movaps  xmm8, xmm13
000000018037CFAD  EB 04                       jmp     short loc_18037CFB3
000000018037CFAF  45 0F 57 C0                 xorps   xmm8, xmm8
000000018037CFB3  41 0F 28 ED                 movaps  xmm5, xmm13
000000018037CFB7  F3 41 0F 5C E8              subss   xmm5, xmm8
000000018037CFBC  0F 28 FD                    movaps  xmm7, xmm5
000000018037CFBF  F3 0F 59 F8                 mulss   xmm7, xmm0
000000018037CFC3  F3 0F 11 BB 90 D7 00 00     movss   dword ptr [rbx+0D790h], xmm7
000000018037CFCB  0F 28 E7                    movaps  xmm4, xmm7
000000018037CFCE  F3 0F 10 9B 70 D8 00 00     movss   xmm3, dword ptr [rbx+0D870h]
000000018037CFD6  F3 0F 10 93 C0 D8 00 00     movss   xmm2, dword ptr [rbx+0D8C0h]
000000018037CFDE  0F 28 CB                    movaps  xmm1, xmm3
000000018037CFE1  F3 0F 59 8B E0 D8 00 00     mulss   xmm1, dword ptr [rbx+0D8E0h]
000000018037CFE9  0F 28 C2                    movaps  xmm0, xmm2
000000018037CFEC  F3 0F 58 A3 90 D8 00 00     addss   xmm4, dword ptr [rbx+0D890h]
000000018037CFF4  F3 0F 5C BB A0 D7 00 00     subss   xmm7, dword ptr [rbx+0D7A0h]
000000018037CFFC  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037D000  41 0F 2F E6                 comiss  xmm4, xmm14
000000018037D004  F3 0F 5C C8                 subss   xmm1, xmm0
000000018037D008  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037D00C  F3 0F 11 8B E0 D7 00 00     movss   dword ptr [rbx+0D7E0h], xmm1
000000018037D014  72 06                       jb      short loc_18037D01C
000000018037D016  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037D01A  EB 03                       jmp     short loc_18037D01F
000000018037D01C  0F 57 F6                    xorps   xmm6, xmm6
000000018037D01F  41 0F 2F FE                 comiss  xmm7, xmm14
000000018037D023  F3 0F 10 83 40 D8 00 00     movss   xmm0, dword ptr [rbx+0D840h]
000000018037D02B  73 03                       jnb     short loc_18037D030
000000018037D02D  0F 28 F5                    movaps  xmm6, xmm5
000000018037D030  F3 0F 59 83 C0 D8 00 00     mulss   xmm0, dword ptr [rbx+0D8C0h]
000000018037D038  0F 28 DD                    movaps  xmm3, xmm5
000000018037D03B  F3 0F 10 93 30 D8 00 00     movss   xmm2, dword ptr [rbx+0D830h]
000000018037D043  F3 44 0F 10 0D 10 7F 76 00  movss   xmm9, cs:dword_180AE4F5C
000000018037D04C  F3 0F 59 D8                 mulss   xmm3, xmm0
000000018037D050  F3 0F 11 B3 A0 D7 00 00     movss   dword ptr [rbx+0D7A0h], xmm6
000000018037D058  F3 0F 10 8B D0 D8 00 00     movss   xmm1, dword ptr [rbx+0D8D0h]
000000018037D060  F3 0F 10 BB 50 D8 00 00     movss   xmm7, dword ptr [rbx+0D850h]
000000018037D068  0F 28 C1                    movaps  xmm0, xmm1
000000018037D06B  F3 0F 10 A3 D0 D7 00 00     movss   xmm4, dword ptr [rbx+0D7D0h]
000000018037D073  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037D077  F3 41 0F 59 F9              mulss   xmm7, xmm9
000000018037D07C  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037D080  F3 41 0F 59 D1              mulss   xmm2, xmm9
000000018037D085  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037D089  F3 0F 59 FE                 mulss   xmm7, xmm6
000000018037D08D  F3 0F 5C C6                 subss   xmm0, xmm6
000000018037D091  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037D095  F3 0F 59 E8                 mulss   xmm5, xmm0
000000018037D099  0F 28 CB                    movaps  xmm1, xmm3
000000018037D09C  F3 0F 5C CC                 subss   xmm1, xmm4
000000018037D0A0  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037D0A4  41 0F 2F CE                 comiss  xmm1, xmm14
000000018037D0A8  F3 0F 58 FA                 addss   xmm7, xmm2
000000018037D0AC  76 0B                       jbe     short loc_18037D0B9
000000018037D0AE  0F 28 DC                    movaps  xmm3, xmm4
000000018037D0B1  F3 0F 58 9B E0 D7 00 00     addss   xmm3, dword ptr [rbx+0D7E0h]
000000018037D0B9  F3 0F 10 83 C0 D8 00 00     movss   xmm0, dword ptr [rbx+0D8C0h]
000000018037D0C1  F3 0F 10 A3 80 D7 00 00     movss   xmm4, dword ptr [rbx+0D780h]
000000018037D0C9  F3 0F 5D C3                 minss   xmm0, xmm3
000000018037D0CD  F3 0F 11 83 C0 D7 00 00     movss   dword ptr [rbx+0D7C0h], xmm0
000000018037D0D5  F3 0F 10 8B 00 D8 00 00     movss   xmm1, dword ptr [rbx+0D800h]
000000018037D0DD  F3 0F 10 9B 60 D8 00 00     movss   xmm3, dword ptr [rbx+0D860h]
000000018037D0E5  F3 0F 59 AB B0 D8 00 00     mulss   xmm5, dword ptr [rbx+0D8B0h]
000000018037D0ED  F3 41 0F 59 D9              mulss   xmm3, xmm9
000000018037D0F2  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018037D0F6  F3 0F 10 83 F0 D8 00 00     movss   xmm0, dword ptr [rbx+0D8F0h]
000000018037D0FE  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018037D103  0F 28 D0                    movaps  xmm2, xmm0
000000018037D106  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037D10A  F3 0F 58 EE                 addss   xmm5, xmm6
000000018037D10E  F3 0F 59 D7                 mulss   xmm2, xmm7
000000018037D112  F3 0F 5C EC                 subss   xmm5, xmm4
000000018037D116  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037D11A  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037D11E  F3 0F 11 93 F0 D7 00 00     movss   dword ptr [rbx+0D7F0h], xmm2
000000018037D126  F3 44 0F 59 C2              mulss   xmm8, xmm2
000000018037D12B  F3 41 0F 5C D8              subss   xmm3, xmm8
000000018037D130  F3 0F 58 DA                 addss   xmm3, xmm2
000000018037D134  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037D138  F3 0F 58 DC                 addss   xmm3, xmm4
000000018037D13C  F3 0F 11 9B 70 D7 00 00     movss   dword ptr [rbx+0D770h], xmm3
000000018037D144  F3 0F 59 9B 00 D9 00 00     mulss   xmm3, dword ptr [rbx+0D900h]
000000018037D14C  F3 0F 59 9B 10 D9 00 00     mulss   xmm3, dword ptr [rbx+0D910h]
000000018037D154  0F 28 C3                    movaps  xmm0, xmm3
000000018037D157  F3 0F 59 83 20 D9 00 00     mulss   xmm0, dword ptr [rbx+0D920h]
000000018037D15F  F3 0F 11 9B 10 D8 00 00     movss   dword ptr [rbx+0D810h], xmm3
000000018037D167  F3 0F 11 83 20 D8 00 00     movss   dword ptr [rbx+0D820h], xmm0
000000018037D16F  44 0F 2F B3 70 D4 00 00     comiss  xmm14, dword ptr [rbx+0D470h]
000000018037D177  F3 0F 10 8B 80 CF 00 00     movss   xmm1, dword ptr [rbx+0CF80h]
000000018037D17F  F3 0F 10 93 30 D9 00 00     movss   xmm2, dword ptr [rbx+0D930h]
000000018037D187  73 06                       jnb     short loc_18037D18F
000000018037D189  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037D18D  EB 03                       jmp     short loc_18037D192
000000018037D18F  0F 57 C0                    xorps   xmm0, xmm0
000000018037D192  41 0F 2E D6                 ucomiss xmm2, xmm14
000000018037D196  75 04                       jnz     short loc_18037D19C
000000018037D198  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037D19C  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037D1A0  F3 0F 11 8B 40 D9 00 00     movss   dword ptr [rbx+0D940h], xmm1
000000018037D1A8  8B 83 50 D9 00 00           mov     eax, [rbx+0D950h]
000000018037D1AE  89 83 60 D9 00 00           mov     [rbx+0D960h], eax
000000018037D1B4  8B 83 80 D9 00 00           mov     eax, [rbx+0D980h]
000000018037D1BA  89 83 90 D9 00 00           mov     [rbx+0D990h], eax
000000018037D1C0  8B 83 70 D9 00 00           mov     eax, [rbx+0D970h]
000000018037D1C6  89 83 80 D9 00 00           mov     [rbx+0D980h], eax
000000018037D1CC  8B 83 A0 D9 00 00           mov     eax, [rbx+0D9A0h]
000000018037D1D2  89 83 B0 D9 00 00           mov     [rbx+0D9B0h], eax
000000018037D1D8  8B 83 D0 D9 00 00           mov     eax, [rbx+0D9D0h]
000000018037D1DE  89 83 E0 D9 00 00           mov     [rbx+0D9E0h], eax
000000018037D1E4  F3 0F 10 83 80 DA 00 00     movss   xmm0, dword ptr [rbx+0DA80h]
000000018037D1EC  F3 0F 58 8B 60 DA 00 00     addss   xmm1, dword ptr [rbx+0DA60h]
000000018037D1F4  F3 0F 59 83 90 D9 00 00     mulss   xmm0, dword ptr [rbx+0D990h]
000000018037D1FC  41 0F 2F CE                 comiss  xmm1, xmm14
000000018037D200  F3 0F 58 83 60 D9 00 00     addss   xmm0, dword ptr [rbx+0D960h]
000000018037D208  73 06                       jnb     short loc_18037D210
000000018037D20A  45 0F 28 C5                 movaps  xmm8, xmm13
000000018037D20E  EB 04                       jmp     short loc_18037D214
000000018037D210  45 0F 57 C0                 xorps   xmm8, xmm8
000000018037D214  41 0F 28 ED                 movaps  xmm5, xmm13
000000018037D218  F3 41 0F 5C E8              subss   xmm5, xmm8
000000018037D21D  0F 28 F5                    movaps  xmm6, xmm5
000000018037D220  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018037D224  F3 0F 11 B3 70 D9 00 00     movss   dword ptr [rbx+0D970h], xmm6
000000018037D22C  0F 28 E6                    movaps  xmm4, xmm6
000000018037D22F  F3 0F 10 9B 50 DA 00 00     movss   xmm3, dword ptr [rbx+0DA50h]
000000018037D237  F3 0F 10 93 A0 DA 00 00     movss   xmm2, dword ptr [rbx+0DAA0h]
000000018037D23F  0F 28 CB                    movaps  xmm1, xmm3
000000018037D242  F3 0F 59 8B C0 DA 00 00     mulss   xmm1, dword ptr [rbx+0DAC0h]
000000018037D24A  0F 28 C2                    movaps  xmm0, xmm2
000000018037D24D  F3 0F 58 A3 70 DA 00 00     addss   xmm4, dword ptr [rbx+0DA70h]
000000018037D255  F3 0F 5C B3 80 D9 00 00     subss   xmm6, dword ptr [rbx+0D980h]
000000018037D25D  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037D261  41 0F 2F E6                 comiss  xmm4, xmm14
000000018037D265  F3 0F 5C C8                 subss   xmm1, xmm0
000000018037D269  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037D26D  F3 0F 11 8B C0 D9 00 00     movss   dword ptr [rbx+0D9C0h], xmm1
000000018037D275  72 06                       jb      short loc_18037D27D
000000018037D277  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037D27B  EB 03                       jmp     short loc_18037D280
000000018037D27D  0F 57 FF                    xorps   xmm7, xmm7
000000018037D280  41 0F 2F F6                 comiss  xmm6, xmm14
000000018037D284  F3 0F 10 83 20 DA 00 00     movss   xmm0, dword ptr [rbx+0DA20h]
000000018037D28C  73 03                       jnb     short loc_18037D291
000000018037D28E  0F 28 FD                    movaps  xmm7, xmm5
000000018037D291  F3 0F 59 83 A0 DA 00 00     mulss   xmm0, dword ptr [rbx+0DAA0h]
000000018037D299  0F 28 DD                    movaps  xmm3, xmm5
000000018037D29C  F3 0F 10 93 10 DA 00 00     movss   xmm2, dword ptr [rbx+0DA10h]
000000018037D2A4  F3 0F 11 BB 80 D9 00 00     movss   dword ptr [rbx+0D980h], xmm7
000000018037D2AC  F3 0F 10 8B B0 DA 00 00     movss   xmm1, dword ptr [rbx+0DAB0h]
000000018037D2B4  F3 0F 10 B3 30 DA 00 00     movss   xmm6, dword ptr [rbx+0DA30h]
000000018037D2BC  F3 0F 10 A3 B0 D9 00 00     movss   xmm4, dword ptr [rbx+0D9B0h]
000000018037D2C4  F3 0F 59 D8                 mulss   xmm3, xmm0
000000018037D2C8  0F 28 C1                    movaps  xmm0, xmm1
000000018037D2CB  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037D2CF  F3 41 0F 59 F1              mulss   xmm6, xmm9
000000018037D2D4  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037D2D8  F3 41 0F 59 D1              mulss   xmm2, xmm9
000000018037D2DD  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037D2E1  F3 0F 59 F7                 mulss   xmm6, xmm7
000000018037D2E5  F3 0F 5C C7                 subss   xmm0, xmm7
000000018037D2E9  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037D2ED  F3 0F 59 E8                 mulss   xmm5, xmm0
000000018037D2F1  0F 28 CB                    movaps  xmm1, xmm3
000000018037D2F4  F3 0F 5C CC                 subss   xmm1, xmm4
000000018037D2F8  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037D2FC  41 0F 2F CE                 comiss  xmm1, xmm14
000000018037D300  F3 0F 58 F2                 addss   xmm6, xmm2
000000018037D304  76 0B                       jbe     short loc_18037D311
000000018037D306  0F 28 DC                    movaps  xmm3, xmm4
000000018037D309  F3 0F 58 9B C0 D9 00 00     addss   xmm3, dword ptr [rbx+0D9C0h]
000000018037D311  F3 0F 10 A3 60 D9 00 00     movss   xmm4, dword ptr [rbx+0D960h]
000000018037D319  F3 0F 10 83 A0 DA 00 00     movss   xmm0, dword ptr [rbx+0DAA0h]
000000018037D321  F3 0F 5D C3                 minss   xmm0, xmm3
000000018037D325  F3 0F 11 83 A0 D9 00 00     movss   dword ptr [rbx+0D9A0h], xmm0
000000018037D32D  F3 0F 59 AB 90 DA 00 00     mulss   xmm5, dword ptr [rbx+0DA90h]
000000018037D335  F3 0F 10 8B E0 D9 00 00     movss   xmm1, dword ptr [rbx+0D9E0h]
000000018037D33D  F3 0F 10 9B 40 DA 00 00     movss   xmm3, dword ptr [rbx+0DA40h]
000000018037D345  F3 0F 59 F8                 mulss   xmm7, xmm0
000000018037D349  F3 0F 10 83 D0 DA 00 00     movss   xmm0, dword ptr [rbx+0DAD0h]
000000018037D351  0F 28 D0                    movaps  xmm2, xmm0
000000018037D354  F3 41 0F 59 D9              mulss   xmm3, xmm9
000000018037D359  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037D35D  F3 0F 58 EF                 addss   xmm5, xmm7
000000018037D361  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018037D366  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037D36A  F3 0F 5C EC                 subss   xmm5, xmm4
000000018037D36E  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037D372  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037D376  F3 0F 11 93 D0 D9 00 00     movss   dword ptr [rbx+0D9D0h], xmm2
000000018037D37E  F3 44 0F 59 C2              mulss   xmm8, xmm2
000000018037D383  F3 41 0F 5C D8              subss   xmm3, xmm8
000000018037D388  F3 0F 58 DA                 addss   xmm3, xmm2
000000018037D38C  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037D390  F3 0F 58 DC                 addss   xmm3, xmm4
000000018037D394  F3 0F 11 9B 50 D9 00 00     movss   dword ptr [rbx+0D950h], xmm3
000000018037D39C  F3 0F 59 9B E0 DA 00 00     mulss   xmm3, dword ptr [rbx+0DAE0h]
000000018037D3A4  F3 0F 59 9B F0 DA 00 00     mulss   xmm3, dword ptr [rbx+0DAF0h]
000000018037D3AC  0F 28 C3                    movaps  xmm0, xmm3
000000018037D3AF  F3 0F 59 83 00 DB 00 00     mulss   xmm0, dword ptr [rbx+0DB00h]
000000018037D3B7  F3 0F 11 9B F0 D9 00 00     movss   dword ptr [rbx+0D9F0h], xmm3
000000018037D3BF  F3 0F 11 83 00 DA 00 00     movss   dword ptr [rbx+0DA00h], xmm0
000000018037D3C7  8B 83 10 DB 00 00           mov     eax, [rbx+0DB10h]
000000018037D3CD  89 83 20 DB 00 00           mov     [rbx+0DB20h], eax
000000018037D3D3  8B 83 30 DB 00 00           mov     eax, [rbx+0DB30h]
000000018037D3D9  89 83 40 DB 00 00           mov     [rbx+0DB40h], eax
000000018037D3DF  F3 0F 10 83 40 D0 00 00     movss   xmm0, dword ptr [rbx+0D040h]
000000018037D3E7  F3 44 0F 10 83 C0 D0 00 00  movss   xmm8, dword ptr [rbx+0D0C0h]
000000018037D3F0  8B 83 70 DB 00 00           mov     eax, [rbx+0DB70h]
000000018037D3F6  89 83 80 DB 00 00           mov     [rbx+0DB80h], eax
000000018037D3FC  F3 0F 59 83 50 DB 00 00     mulss   xmm0, dword ptr [rbx+0DB50h]
000000018037D404  F3 44 0F 59 83 60 DB 00 00  mulss   xmm8, dword ptr [rbx+0DB60h]
000000018037D40D  F3 44 0F 58 C0              addss   xmm8, xmm0
000000018037D412  F3 44 0F 11 83 70 DB 00 00  movss   dword ptr [rbx+0DB70h], xmm8
000000018037D41B  F3 0F 10 BB 50 D4 00 00     movss   xmm7, dword ptr [rbx+0D450h]
000000018037D423  F3 0F 10 8B 10 D8 00 00     movss   xmm1, dword ptr [rbx+0D810h]
000000018037D42B  F3 0F 10 93 F0 D9 00 00     movss   xmm2, dword ptr [rbx+0D9F0h]
000000018037D433  F3 0F 10 83 40 D0 00 00     movss   xmm0, dword ptr [rbx+0D040h]
000000018037D43B  8B 83 30 DB 00 00           mov     eax, [rbx+0DB30h]
000000018037D441  89 83 B0 DB 00 00           mov     [rbx+0DBB0h], eax
000000018037D447  F3 0F 11 83 C0 DB 00 00     movss   dword ptr [rbx+0DBC0h], xmm0
000000018037D44F  F3 0F 10 A3 00 DD 00 00     movss   xmm4, dword ptr [rbx+0DD00h]
000000018037D457  F3 0F 11 8B 90 DB 00 00     movss   dword ptr [rbx+0DB90h], xmm1
000000018037D45F  F3 0F 11 93 A0 DB 00 00     movss   dword ptr [rbx+0DBA0h], xmm2
000000018037D467  F3 0F 10 AB E0 DC 00 00     movss   xmm5, dword ptr [rbx+0DCE0h]
000000018037D46F  F3 0F 59 FC                 mulss   xmm7, xmm4
000000018037D473  F3 0F 59 A3 60 D4 00 00     mulss   xmm4, dword ptr [rbx+0D460h]
000000018037D47B  F3 0F 11 A3 D0 DB 00 00     movss   dword ptr [rbx+0DBD0h], xmm4
000000018037D483  F3 0F 10 8B 60 DC 00 00     movss   xmm1, dword ptr [rbx+0DC60h]
000000018037D48B  F3 0F 10 93 60 DD 00 00     movss   xmm2, dword ptr [rbx+0DD60h]
000000018037D493  0F 28 D9                    movaps  xmm3, xmm1
000000018037D496  F3 0F 59 BB 10 DD 00 00     mulss   xmm7, dword ptr [rbx+0DD10h]
000000018037D49E  0F 28 C2                    movaps  xmm0, xmm2
000000018037D4A1  F3 0F 10 B3 20 DD 00 00     movss   xmm6, dword ptr [rbx+0DD20h]
000000018037D4A9  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037D4AD  F3 0F 59 F7                 mulss   xmm6, xmm7
000000018037D4B1  F3 0F 59 EC                 mulss   xmm5, xmm4
000000018037D4B5  F3 0F 59 AB F0 DC 00 00     mulss   xmm5, dword ptr [rbx+0DCF0h]
000000018037D4BD  F3 0F 11 AB F0 DB 00 00     movss   dword ptr [rbx+0DBF0h], xmm5
000000018037D4C5  F3 0F 58 F5                 addss   xmm6, xmm5
000000018037D4C9  F3 0F 59 9B B0 DB 00 00     mulss   xmm3, dword ptr [rbx+0DBB0h]
000000018037D4D1  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037D4D5  F3 0F 10 83 70 DC 00 00     movss   xmm0, dword ptr [rbx+0DC70h]
000000018037D4DD  F3 0F 58 DA                 addss   xmm3, xmm2
000000018037D4E1  F3 0F 59 9B 70 DD 00 00     mulss   xmm3, dword ptr [rbx+0DD70h]
000000018037D4E9  F3 0F 11 9B 00 DC 00 00     movss   dword ptr [rbx+0DC00h], xmm3
000000018037D4F1  F3 0F 10 8B 40 DD 00 00     movss   xmm1, dword ptr [rbx+0DD40h]
000000018037D4F9  F3 0F 59 8B A0 DB 00 00     mulss   xmm1, dword ptr [rbx+0DBA0h]
000000018037D501  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037D505  F3 0F 58 F0                 addss   xmm6, xmm0
000000018037D509  F3 0F 10 83 30 DD 00 00     movss   xmm0, dword ptr [rbx+0DD30h]
000000018037D511  F3 0F 59 83 90 DB 00 00     mulss   xmm0, dword ptr [rbx+0DB90h]
000000018037D519  F3 0F 10 9B D0 DB 00 00     movss   xmm3, dword ptr [rbx+0DBD0h]
000000018037D521  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037D525  F3 0F 10 83 50 DC 00 00     movss   xmm0, dword ptr [rbx+0DC50h]
000000018037D52D  F3 0F 59 8B 50 DD 00 00     mulss   xmm1, dword ptr [rbx+0DD50h]
000000018037D535  F3 0F 58 CE                 addss   xmm1, xmm6
000000018037D539  F3 41 0F 58 C8              addss   xmm1, xmm8
000000018037D53E  F3 0F 58 8B C0 DC 00 00     addss   xmm1, dword ptr [rbx+0DCC0h]
000000018037D546  F3 0F 58 8B D0 DC 00 00     addss   xmm1, dword ptr [rbx+0DCD0h]
000000018037D54E  F3 0F 11 8B 10 DC 00 00     movss   dword ptr [rbx+0DC10h], xmm1
000000018037D556  F3 0F 11 83 20 DC 00 00     movss   dword ptr [rbx+0DC20h], xmm0
000000018037D55E  F3 0F 59 9B 90 DD 00 00     mulss   xmm3, dword ptr [rbx+0DD90h]
000000018037D566  F3 0F 10 83 90 DC 00 00     movss   xmm0, dword ptr [rbx+0DC90h]
000000018037D56E  F3 0F 59 83 90 DB 00 00     mulss   xmm0, dword ptr [rbx+0DB90h]
000000018037D576  F3 0F 58 9B A0 DD 00 00     addss   xmm3, dword ptr [rbx+0DDA0h]
000000018037D57E  F3 0F 10 8B A0 DC 00 00     movss   xmm1, dword ptr [rbx+0DCA0h]
000000018037D586  F3 0F 59 8B A0 DB 00 00     mulss   xmm1, dword ptr [rbx+0DBA0h]
000000018037D58E  F3 0F 10 93 F0 DB 00 00     movss   xmm2, dword ptr [rbx+0DBF0h]
000000018037D596  F3 0F 59 9B 80 DC 00 00     mulss   xmm3, dword ptr [rbx+0DC80h]
000000018037D59E  F3 0F 58 93 C0 DB 00 00     addss   xmm2, dword ptr [rbx+0DBC0h]
000000018037D5A6  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037D5AA  F3 0F 58 93 00 DC 00 00     addss   xmm2, dword ptr [rbx+0DC00h]
000000018037D5B2  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037D5B6  F3 0F 58 9B B0 DC 00 00     addss   xmm3, dword ptr [rbx+0DCB0h]
000000018037D5BE  F3 0F 59 9B 80 DD 00 00     mulss   xmm3, dword ptr [rbx+0DD80h]
000000018037D5C6  F3 0F 11 9B 30 DC 00 00     movss   dword ptr [rbx+0DC30h], xmm3
000000018037D5CE  F3 0F 11 93 40 DC 00 00     movss   dword ptr [rbx+0DC40h], xmm2
000000018037D5D6  F3 0F 10 83 C0 DD 00 00     movss   xmm0, dword ptr [rbx+0DDC0h]
000000018037D5DE  8B 83 B0 DD 00 00           mov     eax, [rbx+0DDB0h]
000000018037D5E4  89 83 E0 DD 00 00           mov     [rbx+0DDE0h], eax
000000018037D5EA  F3 0F 11 83 F0 DD 00 00     movss   dword ptr [rbx+0DDF0h], xmm0
000000018037D5F2  8B 83 D0 DD 00 00           mov     eax, [rbx+0DDD0h]
000000018037D5F8  89 83 00 DE 00 00           mov     [rbx+0DE00h], eax
000000018037D5FE  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
000000018037D606  8B 83 20 DE 00 00           mov     eax, [rbx+0DE20h]
000000018037D60C  89 83 30 DE 00 00           mov     [rbx+0DE30h], eax
000000018037D612  F3 0F 10 93 10 DE 00 00     movss   xmm2, dword ptr [rbx+0DE10h]
000000018037D61A  F3 0F 11 93 20 DE 00 00     movss   dword ptr [rbx+0DE20h], xmm2
000000018037D622  0F 28 C2                    movaps  xmm0, xmm2
000000018037D625  0F 28 DA                    movaps  xmm3, xmm2
000000018037D628  F3 0F 59 9B 40 DE 00 00     mulss   xmm3, dword ptr [rbx+0DE40h]
000000018037D630  F3 0F 58 9B 30 DE 00 00     addss   xmm3, dword ptr [rbx+0DE30h]
000000018037D638  F3 0F 11 9B 20 DE 00 00     movss   dword ptr [rbx+0DE20h], xmm3
000000018037D640  F3 0F 59 83 50 DE 00 00     mulss   xmm0, dword ptr [rbx+0DE50h]
000000018037D648  F3 0F 58 C3                 addss   xmm0, xmm3
000000018037D64C  F3 0F 59 9B 80 DE 00 00     mulss   xmm3, dword ptr [rbx+0DE80h]
000000018037D654  F3 0F 5C E0                 subss   xmm4, xmm0
000000018037D658  0F 28 CC                    movaps  xmm1, xmm4
000000018037D65B  F3 0F 59 8B 40 DE 00 00     mulss   xmm1, dword ptr [rbx+0DE40h]
000000018037D663  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037D667  F3 0F 11 8B 10 DE 00 00     movss   dword ptr [rbx+0DE10h], xmm1
000000018037D66F  F3 0F 59 8B 70 DE 00 00     mulss   xmm1, dword ptr [rbx+0DE70h]
000000018037D677  F3 0F 59 A3 60 DE 00 00     mulss   xmm4, dword ptr [rbx+0DE60h]
000000018037D67F  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037D683  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037D687  F3 0F 11 A3 30 DE 00 00     movss   dword ptr [rbx+0DE30h], xmm4
000000018037D68F  8B 83 60 E6 00 00           mov     eax, [rbx+0E660h]
000000018037D695  89 83 70 E6 00 00           mov     [rbx+0E670h], eax
000000018037D69B  F3 0F 10 8B 80 E6 00 00     movss   xmm1, dword ptr [rbx+0E680h]
000000018037D6A3  F3 0F 11 8B 90 E6 00 00     movss   dword ptr [rbx+0E690h], xmm1
000000018037D6AB  F3 0F 59 8B 20 DB 00 00     mulss   xmm1, dword ptr [rbx+0DB20h]
000000018037D6B3  F3 0F 10 83 70 E6 00 00     movss   xmm0, dword ptr [rbx+0E670h]
000000018037D6BB  F3 0F 59 83 30 DE 00 00     mulss   xmm0, dword ptr [rbx+0DE30h]
000000018037D6C3  F3 0F 11 8B A0 E6 00 00     movss   dword ptr [rbx+0E6A0h], xmm1
000000018037D6CB  F3 0F 11 83 B0 E6 00 00     movss   dword ptr [rbx+0E6B0h], xmm0
000000018037D6D3  8B 83 E0 E6 00 00           mov     eax, [rbx+0E6E0h]
000000018037D6D9  89 83 F0 E6 00 00           mov     [rbx+0E6F0h], eax
000000018037D6DF  F3 0F 59 8B C0 E6 00 00     mulss   xmm1, dword ptr [rbx+0E6C0h]
000000018037D6E7  F3 0F 59 83 D0 E6 00 00     mulss   xmm0, dword ptr [rbx+0E6D0h]
000000018037D6EF  F3 0F 58 C1                 addss   xmm0, xmm1
000000018037D6F3  F3 0F 11 83 E0 E6 00 00     movss   dword ptr [rbx+0E6E0h], xmm0
000000018037D6FB  8B 83 00 E7 00 00           mov     eax, [rbx+0E700h]
000000018037D701  89 83 10 E7 00 00           mov     [rbx+0E710h], eax
000000018037D707  8B 83 20 E7 00 00           mov     eax, [rbx+0E720h]
000000018037D70D  89 83 30 E7 00 00           mov     [rbx+0E730h], eax
000000018037D713  8B 83 40 E7 00 00           mov     eax, [rbx+0E740h]
000000018037D719  89 83 50 E7 00 00           mov     [rbx+0E750h], eax
000000018037D71F  8B 83 60 E7 00 00           mov     eax, [rbx+0E760h]
000000018037D725  89 83 70 E7 00 00           mov     [rbx+0E770h], eax
000000018037D72B  F3 0F 10 8B 90 E7 00 00     movss   xmm1, dword ptr [rbx+0E790h]
000000018037D733  F3 0F 10 93 A0 E7 00 00     movss   xmm2, dword ptr [rbx+0E7A0h]
000000018037D73B  0F 28 E1                    movaps  xmm4, xmm1
000000018037D73E  F3 0F 59 A3 00 E7 00 00     mulss   xmm4, dword ptr [rbx+0E700h]
000000018037D746  0F 28 C2                    movaps  xmm0, xmm2
000000018037D749  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037D74D  F3 0F 5C E0                 subss   xmm4, xmm0
000000018037D751  F3 0F 58 E2                 addss   xmm4, xmm2
000000018037D755  0F 28 DC                    movaps  xmm3, xmm4
000000018037D758  0F 28 CC                    movaps  xmm1, xmm4
000000018037D75B  F3 0F 59 8B C0 E7 00 00     mulss   xmm1, dword ptr [rbx+0E7C0h]
000000018037D763  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037D767  F3 0F 58 8B B0 E7 00 00     addss   xmm1, dword ptr [rbx+0E7B0h]
000000018037D76F  0F 28 C3                    movaps  xmm0, xmm3
000000018037D772  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037D776  F3 0F 59 83 D0 E7 00 00     mulss   xmm0, dword ptr [rbx+0E7D0h]
000000018037D77E  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037D782  0F 28 C3                    movaps  xmm0, xmm3
000000018037D785  F3 0F 59 9B E0 E7 00 00     mulss   xmm3, dword ptr [rbx+0E7E0h]
000000018037D78D  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037D791  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037D795  F3 0F 59 83 F0 E7 00 00     mulss   xmm0, dword ptr [rbx+0E7F0h]
000000018037D79D  F3 0F 58 C3                 addss   xmm0, xmm3
000000018037D7A1  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037D7A5  76 05                       jbe     short loc_18037D7AC
000000018037D7A7  0F 5A C0                    cvtps2pd xmm0, xmm0
000000018037D7AA  EB 03                       jmp     short loc_18037D7AF
000000018037D7AC  0F 57 C0                    xorps   xmm0, xmm0
000000018037D7AF  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
000000018037D7B3  41 0F 2F CD                 comiss  xmm1, xmm13
000000018037D7B7  73 04                       jnb     short loc_18037D7BD
000000018037D7B9  44 0F 5A E1                 cvtps2pd xmm12, xmm1
000000018037D7BD  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
000000018037D7C2  F3 0F 11 83 80 E7 00 00     movss   dword ptr [rbx+0E780h], xmm0
000000018037D7CA  8B 83 00 E8 00 00           mov     eax, [rbx+0E800h]
000000018037D7D0  89 83 10 E8 00 00           mov     [rbx+0E810h], eax
000000018037D7D6  F3 0F 10 8B 20 E8 00 00     movss   xmm1, dword ptr [rbx+0E820h]
000000018037D7DE  F3 0F 11 8B 30 E8 00 00     movss   dword ptr [rbx+0E830h], xmm1
000000018037D7E6  F3 0F 10 83 40 E8 00 00     movss   xmm0, dword ptr [rbx+0E840h]
000000018037D7EE  F3 0F 11 83 50 E8 00 00     movss   dword ptr [rbx+0E850h], xmm0
000000018037D7F6  F3 0F 5C C8                 subss   xmm1, xmm0
000000018037D7FA  F3 0F 59 8B 60 E8 00 00     mulss   xmm1, dword ptr [rbx+0E860h]
000000018037D802  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037D806  F3 0F 11 8B 40 E8 00 00     movss   dword ptr [rbx+0E840h], xmm1
000000018037D80E  F3 0F 10 8B 40 D0 00 00     movss   xmm1, dword ptr [rbx+0D040h]
000000018037D816  F3 0F 10 83 C0 D0 00 00     movss   xmm0, dword ptr [rbx+0D0C0h]
000000018037D81E  8B 83 90 E8 00 00           mov     eax, [rbx+0E890h]
000000018037D824  89 83 A0 E8 00 00           mov     [rbx+0E8A0h], eax
000000018037D82A  F3 0F 59 83 80 E8 00 00     mulss   xmm0, dword ptr [rbx+0E880h]
000000018037D832  F3 0F 59 8B 70 E8 00 00     mulss   xmm1, dword ptr [rbx+0E870h]
000000018037D83A  F3 0F 58 C1                 addss   xmm0, xmm1
000000018037D83E  F3 0F 11 83 90 E8 00 00     movss   dword ptr [rbx+0E890h], xmm0
000000018037D846  8B 83 B0 E8 00 00           mov     eax, [rbx+0E8B0h]
000000018037D84C  89 83 D0 E8 00 00           mov     [rbx+0E8D0h], eax
000000018037D852  F3 0F 10 9B C0 E8 00 00     movss   xmm3, dword ptr [rbx+0E8C0h]
000000018037D85A  F3 0F 11 9B E0 E8 00 00     movss   dword ptr [rbx+0E8E0h], xmm3
000000018037D862  F3 0F 10 8B D0 E8 00 00     movss   xmm1, dword ptr [rbx+0E8D0h]
000000018037D86A  F3 0F 10 93 10 D8 00 00     movss   xmm2, dword ptr [rbx+0D810h]
000000018037D872  0F 28 C1                    movaps  xmm0, xmm1
000000018037D875  F3 0F 59 83 F0 D9 00 00     mulss   xmm0, dword ptr [rbx+0D9F0h]
000000018037D87D  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018037D881  F3 0F 5C C1                 subss   xmm0, xmm1
000000018037D885  0F 28 CB                    movaps  xmm1, xmm3
000000018037D888  F3 0F 59 8B 40 E7 00 00     mulss   xmm1, dword ptr [rbx+0E740h]
000000018037D890  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037D894  F3 0F 59 DA                 mulss   xmm3, xmm2
000000018037D898  F3 0F 5C CB                 subss   xmm1, xmm3
000000018037D89C  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037D8A0  F3 0F 11 8B F0 E8 00 00     movss   dword ptr [rbx+0E8F0h], xmm1
000000018037D8A8  F3 0F 10 9B 50 D4 00 00     movss   xmm3, dword ptr [rbx+0D450h]
000000018037D8B0  F3 0F 10 83 00 E9 00 00     movss   xmm0, dword ptr [rbx+0E900h]
000000018037D8B8  F3 0F 11 83 10 E9 00 00     movss   dword ptr [rbx+0E910h], xmm0
000000018037D8C0  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037D8C4  0F 28 CB                    movaps  xmm1, xmm3
000000018037D8C7  F3 0F 59 8B 20 E9 00 00     mulss   xmm1, dword ptr [rbx+0E920h]
000000018037D8CF  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037D8D3  F3 0F 10 83 40 E9 00 00     movss   xmm0, dword ptr [rbx+0E940h]
000000018037D8DB  F3 0F 11 8B 00 E9 00 00     movss   dword ptr [rbx+0E900h], xmm1
000000018037D8E3  F3 0F 59 9B 30 E9 00 00     mulss   xmm3, dword ptr [rbx+0E930h]
000000018037D8EB  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037D8EF  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037D8F3  F3 0F 11 9B 10 E9 00 00     movss   dword ptr [rbx+0E910h], xmm3
000000018037D8FB  F3 0F 10 83 50 E9 00 00     movss   xmm0, dword ptr [rbx+0E950h]
000000018037D903  F3 0F 10 BB 60 D4 00 00     movss   xmm7, dword ptr [rbx+0D460h]
000000018037D90B  F3 0F 11 83 60 E9 00 00     movss   dword ptr [rbx+0E960h], xmm0
000000018037D913  F3 0F 5C F8                 subss   xmm7, xmm0
000000018037D917  0F 28 CF                    movaps  xmm1, xmm7
000000018037D91A  F3 0F 59 8B 70 E9 00 00     mulss   xmm1, dword ptr [rbx+0E970h]
000000018037D922  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037D926  F3 0F 10 83 90 E9 00 00     movss   xmm0, dword ptr [rbx+0E990h]
000000018037D92E  F3 0F 11 8B 50 E9 00 00     movss   dword ptr [rbx+0E950h], xmm1
000000018037D936  F3 0F 59 BB 80 E9 00 00     mulss   xmm7, dword ptr [rbx+0E980h]
000000018037D93E  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037D942  F3 0F 58 F8                 addss   xmm7, xmm0
000000018037D946  F3 0F 11 BB 60 E9 00 00     movss   dword ptr [rbx+0E960h], xmm7
000000018037D94E  F3 0F 10 A3 10 E9 00 00     movss   xmm4, dword ptr [rbx+0E910h]
000000018037D956  F3 0F 10 AB F0 E8 00 00     movss   xmm5, dword ptr [rbx+0E8F0h]
000000018037D95E  F3 0F 10 B3 90 E8 00 00     movss   xmm6, dword ptr [rbx+0E890h]
000000018037D966  F3 44 0F 10 8B 20 E7 00 00  movss   xmm9, dword ptr [rbx+0E720h]
000000018037D96F  8B 83 40 E8 00 00           mov     eax, [rbx+0E840h]
000000018037D975  89 83 A0 E9 00 00           mov     [rbx+0E9A0h], eax
000000018037D97B  F3 44 0F 11 8B B0 E9 00 00  movss   dword ptr [rbx+0E9B0h], xmm9
000000018037D984  F3 0F 10 83 D0 E9 00 00     movss   xmm0, dword ptr [rbx+0E9D0h]
000000018037D98C  F3 0F 10 93 E0 E9 00 00     movss   xmm2, dword ptr [rbx+0E9E0h]
000000018037D994  F3 0F 59 F8                 mulss   xmm7, xmm0
000000018037D998  0F 28 DA                    movaps  xmm3, xmm2
000000018037D99B  F3 0F 59 9B 60 E7 00 00     mulss   xmm3, dword ptr [rbx+0E760h]
000000018037D9A3  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037D9A7  0F 28 C2                    movaps  xmm0, xmm2
000000018037D9AA  F3 0F 59 C7                 mulss   xmm0, xmm7
000000018037D9AE  44 0F 28 C3                 movaps  xmm8, xmm3
000000018037D9B2  F3 44 0F 5C C0              subss   xmm8, xmm0
000000018037D9B7  F3 44 0F 58 C7              addss   xmm8, xmm7
000000018037D9BC  F3 44 0F 59 83 10 EA 00 00  mulss   xmm8, dword ptr [rbx+0EA10h]
000000018037D9C5  F3 0F 10 8B F0 E9 00 00     movss   xmm1, dword ptr [rbx+0E9F0h]
000000018037D9CD  F3 0F 58 B3 90 EA 00 00     addss   xmm6, dword ptr [rbx+0EA90h]
000000018037D9D5  F3 44 0F 59 83 20 EA 00 00  mulss   xmm8, dword ptr [rbx+0EA20h]
000000018037D9DE  F3 0F 59 AB 30 EA 00 00     mulss   xmm5, dword ptr [rbx+0EA30h]
000000018037D9E6  F3 0F 59 B3 40 EA 00 00     mulss   xmm6, dword ptr [rbx+0EA40h]
000000018037D9EE  F3 44 0F 59 C9              mulss   xmm9, xmm1
000000018037D9F3  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037D9F7  F3 0F 58 F5                 addss   xmm6, xmm5
000000018037D9FB  F3 0F 5C DA                 subss   xmm3, xmm2
000000018037D9FF  F3 0F 10 93 70 EA 00 00     movss   xmm2, dword ptr [rbx+0EA70h]
000000018037DA07  0F 28 C2                    movaps  xmm0, xmm2
000000018037DA0A  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037DA0E  F3 0F 58 DC                 addss   xmm3, xmm4
000000018037DA12  F3 44 0F 5C C8              subss   xmm9, xmm0
000000018037DA17  F3 0F 10 83 60 EA 00 00     movss   xmm0, dword ptr [rbx+0EA60h]
000000018037DA1F  F3 0F 58 83 A0 E9 00 00     addss   xmm0, dword ptr [rbx+0E9A0h]
000000018037DA27  F3 0F 59 9B 00 EA 00 00     mulss   xmm3, dword ptr [rbx+0EA00h]
000000018037DA2F  F3 0F 59 83 A0 EA 00 00     mulss   xmm0, dword ptr [rbx+0EAA0h]
000000018037DA37  F3 44 0F 58 CA              addss   xmm9, xmm2
000000018037DA3C  F3 44 0F 58 C3              addss   xmm8, xmm3
000000018037DA41  F3 0F 59 83 50 EA 00 00     mulss   xmm0, dword ptr [rbx+0EA50h]
000000018037DA49  F3 44 0F 59 8B 80 EA 00 00  mulss   xmm9, dword ptr [rbx+0EA80h]
000000018037DA52  F3 44 0F 58 C6              addss   xmm8, xmm6
000000018037DA57  F3 44 0F 58 C8              addss   xmm9, xmm0
000000018037DA5C  F3 45 0F 58 C8              addss   xmm9, xmm8
000000018037DA61  F3 44 0F 11 8B C0 E9 00 00  movss   dword ptr [rbx+0E9C0h], xmm9
000000018037DA6A  F3 0F 10 BB 80 E7 00 00     movss   xmm7, dword ptr [rbx+0E780h]
000000018037DA72  F3 44 0F 10 83 10 E8 00 00  movss   xmm8, dword ptr [rbx+0E810h]
000000018037DA7B  8B 83 E0 EA 00 00           mov     eax, [rbx+0EAE0h]
000000018037DA81  89 83 F0 EA 00 00           mov     [rbx+0EAF0h], eax
000000018037DA87  F3 0F 10 83 D0 EA 00 00     movss   xmm0, dword ptr [rbx+0EAD0h]
000000018037DA8F  F3 0F 11 83 E0 EA 00 00     movss   dword ptr [rbx+0EAE0h], xmm0
000000018037DA97  44 0F 2E AB 20 EB 00 00     ucomiss xmm13, dword ptr [rbx+0EB20h]
000000018037DA9F  0F 85 7D 02 00 00           jnz     loc_18037DD22
000000018037DAA5  F3 0F 10 8B 70 EB 00 00     movss   xmm1, dword ptr [rbx+0EB70h]
000000018037DAAD  F3 0F 10 B3 F0 EA 00 00     movss   xmm6, dword ptr [rbx+0EAF0h]
000000018037DAB5  0F 28 D1                    movaps  xmm2, xmm1
000000018037DAB8  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018037DABC  F3 0F 59 D0                 mulss   xmm2, xmm0
000000018037DAC0  41 0F 57 C3                 xorps   xmm0, xmm11
000000018037DAC4  F3 0F 5C D1                 subss   xmm2, xmm1
000000018037DAC8  F3 0F 58 F2                 addss   xmm6, xmm2
000000018037DACC  F3 0F 11 B3 E0 EA 00 00     movss   dword ptr [rbx+0EAE0h], xmm6
000000018037DAD4  F3 0F 59 B3 60 EB 00 00     mulss   xmm6, dword ptr [rbx+0EB60h]
000000018037DADC  F3 0F 58 B3 00 EB 00 00     addss   xmm6, dword ptr [rbx+0EB00h]
000000018037DAE4  E8 77 B2 FE FF              call    sub_180368D60
000000018037DAE9  F3 0F 11 83 D0 EA 00 00     movss   dword ptr [rbx+0EAD0h], xmm0
000000018037DAF1  41 0F 28 C8                 movaps  xmm1, xmm8
000000018037DAF5  F3 0F 59 8B C0 EB 00 00     mulss   xmm1, dword ptr [rbx+0EBC0h]
000000018037DAFD  41 0F 28 D5                 movaps  xmm2, xmm13
000000018037DB01  F3 41 0F 5C D0              subss   xmm2, xmm8
000000018037DB06  F3 0F 58 8B 10 EB 00 00     addss   xmm1, dword ptr [rbx+0EB10h]
000000018037DB0E  F3 0F 59 93 80 EB 00 00     mulss   xmm2, dword ptr [rbx+0EB80h]
000000018037DB16  F3 0F 11 8B C0 EA 00 00     movss   dword ptr [rbx+0EAC0h], xmm1
000000018037DB1E  F3 0F 59 BB 30 EB 00 00     mulss   xmm7, dword ptr [rbx+0EB30h]
000000018037DB26  F3 44 0F 59 8B 50 EB 00 00  mulss   xmm9, dword ptr [rbx+0EB50h]
000000018037DB2F  F3 0F 10 83 90 EB 00 00     movss   xmm0, dword ptr [rbx+0EB90h]
000000018037DB37  F3 0F 5D C2                 minss   xmm0, xmm2
000000018037DB3B  F3 41 0F 58 F9              addss   xmm7, xmm9
000000018037DB40  F3 0F 58 FE                 addss   xmm7, xmm6
000000018037DB44  F3 0F 58 F8                 addss   xmm7, xmm0
000000018037DB48  F3 0F 58 BB 40 EB 00 00     addss   xmm7, dword ptr [rbx+0EB40h]
000000018037DB50  F3 0F 5D BB A0 EB 00 00     minss   xmm7, dword ptr [rbx+0EBA0h]
000000018037DB58  F3 0F 5F BB B0 EB 00 00     maxss   xmm7, dword ptr [rbx+0EBB0h]
000000018037DB60  F3 0F 59 BB E0 EB 00 00     mulss   xmm7, dword ptr [rbx+0EBE0h]
000000018037DB68  F3 0F 58 BB F0 EB 00 00     addss   xmm7, dword ptr [rbx+0EBF0h]
000000018037DB70  0F 28 CF                    movaps  xmm1, xmm7
000000018037DB73  F3 0F 2C C9                 cvttss2si ecx, xmm1
000000018037DB77  81 F9 00 00 00 80           cmp     ecx, 80000000h
000000018037DB7D  74 1E                       jz      short loc_18037DB9D
000000018037DB7F  66 0F 6E C1                 movd    xmm0, ecx
000000018037DB83  0F 5B C0                    cvtdq2ps xmm0, xmm0
000000018037DB86  0F 2E C1                    ucomiss xmm0, xmm1
000000018037DB89  74 12                       jz      short loc_18037DB9D
000000018037DB8B  0F 14 C9                    unpcklps xmm1, xmm1
000000018037DB8E  0F 50 C1                    movmskps eax, xmm1
000000018037DB91  83 E0 01                    and     eax, 1
000000018037DB94  2B C8                       sub     ecx, eax
000000018037DB96  66 0F 6E C9                 movd    xmm1, ecx
000000018037DB9A  0F 5B C9                    cvtdq2ps xmm1, xmm1
000000018037DB9D  F3 0F 5C F9                 subss   xmm7, xmm1
000000018037DBA1  0F 28 C1                    movaps  xmm0, xmm1; X
000000018037DBA4  0F 28 F7                    movaps  xmm6, xmm7
000000018037DBA7  F3 0F 59 F7                 mulss   xmm6, xmm7
000000018037DBAB  F3 0F 59 35 1D 74 76 00     mulss   xmm6, cs:dword_180AE4FD0
000000018037DBB3  E8 88 1B 37 00              call    expf
000000018037DBB8  0F 28 E0                    movaps  xmm4, xmm0
000000018037DBBB  0F 28 D7                    movaps  xmm2, xmm7
000000018037DBBE  F3 0F 59 93 B0 EC 00 00     mulss   xmm2, dword ptr [rbx+0ECB0h]
000000018037DBC6  0F 28 CF                    movaps  xmm1, xmm7
000000018037DBC9  F3 0F 59 8B 90 EC 00 00     mulss   xmm1, dword ptr [rbx+0EC90h]
000000018037DBD1  0F 28 C7                    movaps  xmm0, xmm7
000000018037DBD4  F3 0F 58 93 A0 EC 00 00     addss   xmm2, dword ptr [rbx+0ECA0h]
000000018037DBDC  F3 0F 59 83 70 EC 00 00     mulss   xmm0, dword ptr [rbx+0EC70h]
000000018037DBE4  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037DBE8  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037DBEC  F3 0F 58 93 80 EC 00 00     addss   xmm2, dword ptr [rbx+0EC80h]
000000018037DBF4  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037DBF8  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037DBFC  0F 28 C7                    movaps  xmm0, xmm7
000000018037DBFF  F3 0F 59 83 50 EC 00 00     mulss   xmm0, dword ptr [rbx+0EC50h]
000000018037DC07  F3 0F 58 93 60 EC 00 00     addss   xmm2, dword ptr [rbx+0EC60h]
000000018037DC0F  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037DC13  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037DC17  0F 28 C7                    movaps  xmm0, xmm7
000000018037DC1A  F3 0F 59 83 30 EC 00 00     mulss   xmm0, dword ptr [rbx+0EC30h]
000000018037DC22  F3 0F 59 BB 10 EC 00 00     mulss   xmm7, dword ptr [rbx+0EC10h]
000000018037DC2A  F3 0F 58 93 40 EC 00 00     addss   xmm2, dword ptr [rbx+0EC40h]
000000018037DC32  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037DC36  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037DC3A  F3 0F 58 93 20 EC 00 00     addss   xmm2, dword ptr [rbx+0EC20h]
000000018037DC42  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037DC46  F3 0F 58 D7                 addss   xmm2, xmm7
000000018037DC4A  F3 41 0F 58 D5              addss   xmm2, xmm13
000000018037DC4F  F3 0F 59 E2                 mulss   xmm4, xmm2
000000018037DC53  F3 0F 59 A3 00 EC 00 00     mulss   xmm4, dword ptr [rbx+0EC00h]
000000018037DC5B  0F 28 DC                    movaps  xmm3, xmm4
000000018037DC5E  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037DC62  0F 28 CB                    movaps  xmm1, xmm3
000000018037DC65  44 0F 28 C3                 movaps  xmm8, xmm3
000000018037DC69  F3 44 0F 59 83 50 ED 00 00  mulss   xmm8, dword ptr [rbx+0ED50h]
000000018037DC72  0F 28 C3                    movaps  xmm0, xmm3
000000018037DC75  F3 0F 59 83 10 ED 00 00     mulss   xmm0, dword ptr [rbx+0ED10h]
000000018037DC7D  0F 28 D3                    movaps  xmm2, xmm3
000000018037DC80  F3 44 0F 58 83 30 ED 00 00  addss   xmm8, dword ptr [rbx+0ED30h]
000000018037DC89  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037DC8D  F3 0F 58 83 F0 EC 00 00     addss   xmm0, dword ptr [rbx+0ECF0h]
000000018037DC95  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037DC99  F3 44 0F 59 C2              mulss   xmm8, xmm2
000000018037DC9E  F3 44 0F 58 C0              addss   xmm8, xmm0
000000018037DCA3  0F 28 C1                    movaps  xmm0, xmm1
000000018037DCA6  F3 0F 59 8B D0 EC 00 00     mulss   xmm1, dword ptr [rbx+0ECD0h]
000000018037DCAE  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037DCB2  F3 44 0F 59 C0              mulss   xmm8, xmm0
000000018037DCB7  0F 28 C3                    movaps  xmm0, xmm3
000000018037DCBA  F3 0F 59 83 00 ED 00 00     mulss   xmm0, dword ptr [rbx+0ED00h]
000000018037DCC2  F3 44 0F 58 C1              addss   xmm8, xmm1
000000018037DCC7  0F 28 CB                    movaps  xmm1, xmm3
000000018037DCCA  F3 0F 59 8B 40 ED 00 00     mulss   xmm1, dword ptr [rbx+0ED40h]
000000018037DCD2  F3 0F 59 9B C0 EC 00 00     mulss   xmm3, dword ptr [rbx+0ECC0h]
000000018037DCDA  F3 0F 58 8B 20 ED 00 00     addss   xmm1, dword ptr [rbx+0ED20h]
000000018037DCE2  F3 44 0F 58 C4              addss   xmm8, xmm4
000000018037DCE7  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018037DCEB  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037DCEF  F3 0F 58 8B E0 EC 00 00     addss   xmm1, dword ptr [rbx+0ECE0h]
000000018037DCF7  F3 0F 59 CA                 mulss   xmm1, xmm2
000000018037DCFB  F3 0F 58 CB                 addss   xmm1, xmm3
000000018037DCFF  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018037DD04  F3 44 0F 5E C1              divss   xmm8, xmm1
000000018037DD09  41 0F 28 C0                 movaps  xmm0, xmm8
000000018037DD0D  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037DD12  F3 44 0F 5E C0              divss   xmm8, xmm0
000000018037DD17  F3 44 0F 11 83 B0 EA 00 00  movss   dword ptr [rbx+0EAB0h], xmm8
000000018037DD20  EB 09                       jmp     short loc_18037DD2B
000000018037DD22  F3 44 0F 10 83 B0 EA 00 00  movss   xmm8, dword ptr [rbx+0EAB0h]
000000018037DD2B  8B 83 C0 ED 00 00           mov     eax, [rbx+0EDC0h]
000000018037DD31  F3 0F 10 8B E0 E6 00 00     movss   xmm1, dword ptr [rbx+0E6E0h]
000000018037DD39  F3 44 0F 10 8B C0 EA 00 00  movss   xmm9, dword ptr [rbx+0EAC0h]
000000018037DD42  89 83 D0 ED 00 00           mov     [rbx+0EDD0h], eax
000000018037DD48  8B 83 B0 ED 00 00           mov     eax, [rbx+0EDB0h]
000000018037DD4E  89 83 C0 ED 00 00           mov     [rbx+0EDC0h], eax
000000018037DD54  8B 83 A0 ED 00 00           mov     eax, [rbx+0EDA0h]
000000018037DD5A  89 83 B0 ED 00 00           mov     [rbx+0EDB0h], eax
000000018037DD60  8B 83 90 ED 00 00           mov     eax, [rbx+0ED90h]
000000018037DD66  89 83 A0 ED 00 00           mov     [rbx+0EDA0h], eax
000000018037DD6C  8B 83 80 ED 00 00           mov     eax, [rbx+0ED80h]
000000018037DD72  89 83 90 ED 00 00           mov     [rbx+0ED90h], eax
000000018037DD78  8B 83 70 ED 00 00           mov     eax, [rbx+0ED70h]
000000018037DD7E  89 83 80 ED 00 00           mov     [rbx+0ED80h], eax
000000018037DD84  8B 83 60 ED 00 00           mov     eax, [rbx+0ED60h]
000000018037DD8A  89 83 70 ED 00 00           mov     [rbx+0ED70h], eax
000000018037DD90  8B 83 A0 EE 00 00           mov     eax, [rbx+0EEA0h]
000000018037DD96  89 83 B0 EE 00 00           mov     [rbx+0EEB0h], eax
000000018037DD9C  8B 83 90 EE 00 00           mov     eax, [rbx+0EE90h]
000000018037DDA2  89 83 A0 EE 00 00           mov     [rbx+0EEA0h], eax
000000018037DDA8  8B 83 80 EE 00 00           mov     eax, [rbx+0EE80h]
000000018037DDAE  89 83 90 EE 00 00           mov     [rbx+0EE90h], eax
000000018037DDB4  8B 83 70 EE 00 00           mov     eax, [rbx+0EE70h]
000000018037DDBA  89 83 80 EE 00 00           mov     [rbx+0EE80h], eax
000000018037DDC0  8B 83 60 EE 00 00           mov     eax, [rbx+0EE60h]
000000018037DDC6  89 83 70 EE 00 00           mov     [rbx+0EE70h], eax
000000018037DDCC  8B 83 50 EE 00 00           mov     eax, [rbx+0EE50h]
000000018037DDD2  89 83 60 EE 00 00           mov     [rbx+0EE60h], eax
000000018037DDD8  8B 83 40 EE 00 00           mov     eax, [rbx+0EE40h]
000000018037DDDE  89 83 50 EE 00 00           mov     [rbx+0EE50h], eax
000000018037DDE4  8B 83 20 EF 00 00           mov     eax, [rbx+0EF20h]
000000018037DDEA  89 83 30 EF 00 00           mov     [rbx+0EF30h], eax
000000018037DDF0  8B 83 10 EF 00 00           mov     eax, [rbx+0EF10h]
000000018037DDF6  89 83 20 EF 00 00           mov     [rbx+0EF20h], eax
000000018037DDFC  8B 83 00 EF 00 00           mov     eax, [rbx+0EF00h]
000000018037DE02  89 83 10 EF 00 00           mov     [rbx+0EF10h], eax
000000018037DE08  8B 83 F0 EE 00 00           mov     eax, [rbx+0EEF0h]
000000018037DE0E  89 83 00 EF 00 00           mov     [rbx+0EF00h], eax
000000018037DE14  8B 83 E0 EE 00 00           mov     eax, [rbx+0EEE0h]
000000018037DE1A  89 83 F0 EE 00 00           mov     [rbx+0EEF0h], eax
000000018037DE20  8B 83 D0 EE 00 00           mov     eax, [rbx+0EED0h]
000000018037DE26  89 83 E0 EE 00 00           mov     [rbx+0EEE0h], eax
000000018037DE2C  8B 83 C0 EE 00 00           mov     eax, [rbx+0EEC0h]
000000018037DE32  89 83 D0 EE 00 00           mov     [rbx+0EED0h], eax
000000018037DE38  8B 83 A0 EF 00 00           mov     eax, [rbx+0EFA0h]
000000018037DE3E  89 83 B0 EF 00 00           mov     [rbx+0EFB0h], eax
000000018037DE44  8B 83 90 EF 00 00           mov     eax, [rbx+0EF90h]
000000018037DE4A  89 83 A0 EF 00 00           mov     [rbx+0EFA0h], eax
000000018037DE50  8B 83 80 EF 00 00           mov     eax, [rbx+0EF80h]
000000018037DE56  89 83 90 EF 00 00           mov     [rbx+0EF90h], eax
000000018037DE5C  8B 83 70 EF 00 00           mov     eax, [rbx+0EF70h]
000000018037DE62  89 83 80 EF 00 00           mov     [rbx+0EF80h], eax
000000018037DE68  8B 83 60 EF 00 00           mov     eax, [rbx+0EF60h]
000000018037DE6E  89 83 70 EF 00 00           mov     [rbx+0EF70h], eax
000000018037DE74  8B 83 50 EF 00 00           mov     eax, [rbx+0EF50h]
000000018037DE7A  89 83 60 EF 00 00           mov     [rbx+0EF60h], eax
000000018037DE80  8B 83 40 EF 00 00           mov     eax, [rbx+0EF40h]
000000018037DE86  89 83 50 EF 00 00           mov     [rbx+0EF50h], eax
000000018037DE8C  8B 83 20 F0 00 00           mov     eax, [rbx+0F020h]
000000018037DE92  89 83 30 F0 00 00           mov     [rbx+0F030h], eax
000000018037DE98  8B 83 10 F0 00 00           mov     eax, [rbx+0F010h]
000000018037DE9E  89 83 20 F0 00 00           mov     [rbx+0F020h], eax
000000018037DEA4  8B 83 00 F0 00 00           mov     eax, [rbx+0F000h]
000000018037DEAA  89 83 10 F0 00 00           mov     [rbx+0F010h], eax
000000018037DEB0  8B 83 F0 EF 00 00           mov     eax, [rbx+0EFF0h]
000000018037DEB6  89 83 00 F0 00 00           mov     [rbx+0F000h], eax
000000018037DEBC  8B 83 E0 EF 00 00           mov     eax, [rbx+0EFE0h]
000000018037DEC2  89 83 F0 EF 00 00           mov     [rbx+0EFF0h], eax
000000018037DEC8  8B 83 D0 EF 00 00           mov     eax, [rbx+0EFD0h]
000000018037DECE  89 83 E0 EF 00 00           mov     [rbx+0EFE0h], eax
000000018037DED4  8B 83 C0 EF 00 00           mov     eax, [rbx+0EFC0h]
000000018037DEDA  89 83 D0 EF 00 00           mov     [rbx+0EFD0h], eax
000000018037DEE0  8B 83 40 F0 00 00           mov     eax, [rbx+0F040h]
000000018037DEE6  89 83 50 F0 00 00           mov     [rbx+0F050h], eax
000000018037DEEC  F3 0F 10 83 60 F0 00 00     movss   xmm0, dword ptr [rbx+0F060h]
000000018037DEF4  F3 0F 11 83 70 F0 00 00     movss   dword ptr [rbx+0F070h], xmm0
000000018037DEFC  44 0F 2E AB B0 F0 00 00     ucomiss xmm13, dword ptr [rbx+0F0B0h]
000000018037DF04  0F 85 49 09 00 00           jnz     loc_18037E853
000000018037DF0A  F3 0F 59 8B 00 F1 00 00     mulss   xmm1, dword ptr [rbx+0F100h]
000000018037DF12  41 0F 57 C3                 xorps   xmm0, xmm11
000000018037DF16  41 0F 28 F1                 movaps  xmm6, xmm9
000000018037DF1A  41 0F 28 F8                 movaps  xmm7, xmm8
000000018037DF1E  F3 0F 59 B3 20 F1 00 00     mulss   xmm6, dword ptr [rbx+0F120h]
000000018037DF26  F3 41 0F 59 F8              mulss   xmm7, xmm8
000000018037DF2B  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037DF30  F3 0F 59 F1                 mulss   xmm6, xmm1
000000018037DF34  0F 28 C8                    movaps  xmm1, xmm0
000000018037DF37  F3 0F 59 8B F0 F0 00 00     mulss   xmm1, dword ptr [rbx+0F0F0h]
000000018037DF3F  F3 0F 58 F1                 addss   xmm6, xmm1
000000018037DF43  E8 18 AE FE FF              call    sub_180368D60
000000018037DF48  F3 0F 11 83 60 F0 00 00     movss   dword ptr [rbx+0F060h], xmm0
000000018037DF50  41 0F 28 DD                 movaps  xmm3, xmm13
000000018037DF54  F3 0F 11 B3 40 F0 00 00     movss   dword ptr [rbx+0F040h], xmm6
000000018037DF5C  41 0F 28 C0                 movaps  xmm0, xmm8
000000018037DF60  F3 0F 59 FF                 mulss   xmm7, xmm7
000000018037DF64  F3 41 0F 58 C0              addss   xmm0, xmm8
000000018037DF69  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037DF6D  F3 41 0F 59 F9              mulss   xmm7, xmm9
000000018037DF72  F3 0F 5C F0                 subss   xmm6, xmm0
000000018037DF76  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037DF7B  F3 0F 5E DF                 divss   xmm3, xmm7
000000018037DF7F  F3 0F 11 9B 90 F0 00 00     movss   dword ptr [rbx+0F090h], xmm3
000000018037DF87  0F 28 E3                    movaps  xmm4, xmm3
000000018037DF8A  F3 0F 10 8B 40 F0 00 00     movss   xmm1, dword ptr [rbx+0F040h]
000000018037DF92  F3 0F 10 AB 50 F0 00 00     movss   xmm5, dword ptr [rbx+0F050h]
000000018037DF9A  F3 41 0F 59 E1              mulss   xmm4, xmm9
000000018037DF9F  F3 0F 11 A3 80 F0 00 00     movss   dword ptr [rbx+0F080h], xmm4
000000018037DFA7  F3 0F 59 AB 50 F1 00 00     mulss   xmm5, dword ptr [rbx+0F150h]
000000018037DFAF  F3 0F 10 93 C0 ED 00 00     movss   xmm2, dword ptr [rbx+0EDC0h]
000000018037DFB7  F3 0F 59 8B 60 F1 00 00     mulss   xmm1, dword ptr [rbx+0F160h]
000000018037DFBF  F3 0F 10 83 D0 ED 00 00     movss   xmm0, dword ptr [rbx+0EDD0h]
000000018037DFC7  F3 0F 11 93 30 EE 00 00     movss   dword ptr [rbx+0EE30h], xmm2
000000018037DFCF  F3 0F 59 93 80 F2 00 00     mulss   xmm2, dword ptr [rbx+0F280h]
000000018037DFD7  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037DFDB  F3 0F 59 83 90 F2 00 00     mulss   xmm0, dword ptr [rbx+0F290h]
000000018037DFE3  F3 0F 59 EB                 mulss   xmm5, xmm3
000000018037DFE7  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037DFEB  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037DFEF  F3 0F 5C EA                 subss   xmm5, xmm2
000000018037DFF3  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037DFF7  73 06                       jnb     short loc_18037DFFF
000000018037DFF9  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037DFFD  EB 05                       jmp     short loc_18037E004
000000018037DFFF  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037E004  0F 28 CD                    movaps  xmm1, xmm5
000000018037E007  0F 28 C5                    movaps  xmm0, xmm5
000000018037E00A  F3 0F 59 83 30 F1 00 00     mulss   xmm0, dword ptr [rbx+0F130h]
000000018037E012  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037E016  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E01A  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E01E  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E022  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037E026  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037E02A  F3 0F 11 AB E0 ED 00 00     movss   dword ptr [rbx+0EDE0h], xmm5
000000018037E032  0F 28 D5                    movaps  xmm2, xmm5
000000018037E035  F3 0F 58 AB 70 ED 00 00     addss   xmm5, dword ptr [rbx+0ED70h]
000000018037E03D  F3 0F 10 9B 80 ED 00 00     movss   xmm3, dword ptr [rbx+0ED80h]
000000018037E045  0F 28 C3                    movaps  xmm0, xmm3
000000018037E048  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E04C  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037E050  41 0F 28 E8                 movaps  xmm5, xmm8
000000018037E054  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018037E058  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037E05C  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E060  0F 28 C6                    movaps  xmm0, xmm6
000000018037E063  F3 0F 11 A3 F0 ED 00 00     movss   dword ptr [rbx+0EDF0h], xmm4
000000018037E06B  F3 0F 10 8B 90 ED 00 00     movss   xmm1, dword ptr [rbx+0ED90h]
000000018037E073  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037E077  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037E07B  0F 28 C1                    movaps  xmm0, xmm1
000000018037E07E  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E082  F3 0F 58 EC                 addss   xmm5, xmm4
000000018037E086  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037E08A  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037E08E  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037E092  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037E096  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037E09A  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037E09E  0F 28 C6                    movaps  xmm0, xmm6
000000018037E0A1  F3 0F 11 9B 00 EE 00 00     movss   dword ptr [rbx+0EE00h], xmm3
000000018037E0A9  F3 0F 10 AB A0 ED 00 00     movss   xmm5, dword ptr [rbx+0EDA0h]
000000018037E0B1  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037E0B5  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E0B9  0F 28 C5                    movaps  xmm0, xmm5
000000018037E0BC  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E0C0  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037E0C4  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037E0C8  41 0F 28 C8                 movaps  xmm1, xmm8
000000018037E0CC  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037E0D0  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037E0D4  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037E0D8  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037E0DC  0F 28 C6                    movaps  xmm0, xmm6
000000018037E0DF  F3 0F 11 93 10 EE 00 00     movss   dword ptr [rbx+0EE10h], xmm2
000000018037E0E7  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037E0EB  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037E0EF  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037E0F3  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018037E0F8  0F 28 C6                    movaps  xmm0, xmm6
000000018037E0FB  F3 0F 59 83 B0 ED 00 00     mulss   xmm0, dword ptr [rbx+0EDB0h]
000000018037E103  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037E107  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037E10B  0F 28 C6                    movaps  xmm0, xmm6
000000018037E10E  F3 0F 59 E1                 mulss   xmm4, xmm1
000000018037E112  F3 0F 11 AB 20 EE 00 00     movss   dword ptr [rbx+0EE20h], xmm5
000000018037E11A  F3 0F 10 93 10 EE 00 00     movss   xmm2, dword ptr [rbx+0EE10h]
000000018037E122  F3 0F 59 93 D0 F0 00 00     mulss   xmm2, dword ptr [rbx+0F0D0h]
000000018037E12A  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037E12E  F3 0F 59 AB E0 F0 00 00     mulss   xmm5, dword ptr [rbx+0F0E0h]
000000018037E136  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E13A  F3 0F 10 83 C0 F0 00 00     movss   xmm0, dword ptr [rbx+0F0C0h]
000000018037E142  F3 0F 59 83 00 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE00h]
000000018037E14A  F3 0F 58 D5                 addss   xmm2, xmm5
000000018037E14E  F3 0F 10 AB 50 F0 00 00     movss   xmm5, dword ptr [rbx+0F050h]
000000018037E156  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037E15A  F3 0F 11 93 C0 EF 00 00     movss   dword ptr [rbx+0EFC0h], xmm2
000000018037E162  F3 0F 58 AB 40 F0 00 00     addss   xmm5, dword ptr [rbx+0F040h]
000000018037E16A  F3 0F 10 83 30 EE 00 00     movss   xmm0, dword ptr [rbx+0EE30h]
000000018037E172  F3 0F 59 AB 70 F1 00 00     mulss   xmm5, dword ptr [rbx+0F170h]
000000018037E17A  F3 0F 59 AB 90 F0 00 00     mulss   xmm5, dword ptr [rbx+0F090h]
000000018037E182  F3 0F 11 A3 30 EE 00 00     movss   dword ptr [rbx+0EE30h], xmm4
000000018037E18A  F3 0F 59 A3 80 F2 00 00     mulss   xmm4, dword ptr [rbx+0F280h]
000000018037E192  F3 0F 59 83 90 F2 00 00     mulss   xmm0, dword ptr [rbx+0F290h]
000000018037E19A  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E19E  F3 0F 59 A3 80 F0 00 00     mulss   xmm4, dword ptr [rbx+0F080h]
000000018037E1A6  F3 0F 5C EC                 subss   xmm5, xmm4
000000018037E1AA  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037E1AE  73 06                       jnb     short loc_18037E1B6
000000018037E1B0  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037E1B4  EB 05                       jmp     short loc_18037E1BB
000000018037E1B6  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037E1BB  0F 28 CD                    movaps  xmm1, xmm5
000000018037E1BE  0F 28 C5                    movaps  xmm0, xmm5
000000018037E1C1  F3 0F 59 83 30 F1 00 00     mulss   xmm0, dword ptr [rbx+0F130h]
000000018037E1C9  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037E1CD  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E1D1  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E1D5  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E1D9  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037E1DD  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037E1E1  F3 0F 10 8B E0 ED 00 00     movss   xmm1, dword ptr [rbx+0EDE0h]
000000018037E1E9  F3 0F 11 AB E0 ED 00 00     movss   dword ptr [rbx+0EDE0h], xmm5
000000018037E1F1  0F 28 D5                    movaps  xmm2, xmm5
000000018037E1F4  F3 0F 10 9B F0 ED 00 00     movss   xmm3, dword ptr [rbx+0EDF0h]
000000018037E1FC  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037E200  0F 28 C3                    movaps  xmm0, xmm3
000000018037E203  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E207  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037E20B  41 0F 28 E8                 movaps  xmm5, xmm8
000000018037E20F  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018037E213  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037E217  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E21B  0F 28 C6                    movaps  xmm0, xmm6
000000018037E21E  F3 0F 11 A3 F0 ED 00 00     movss   dword ptr [rbx+0EDF0h], xmm4
000000018037E226  F3 0F 10 8B 00 EE 00 00     movss   xmm1, dword ptr [rbx+0EE00h]
000000018037E22E  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037E232  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037E236  0F 28 C1                    movaps  xmm0, xmm1
000000018037E239  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E23D  F3 0F 58 EC                 addss   xmm5, xmm4
000000018037E241  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037E245  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037E249  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037E24D  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037E251  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037E255  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037E259  0F 28 C6                    movaps  xmm0, xmm6
000000018037E25C  F3 0F 11 9B 00 EE 00 00     movss   dword ptr [rbx+0EE00h], xmm3
000000018037E264  F3 0F 10 AB 10 EE 00 00     movss   xmm5, dword ptr [rbx+0EE10h]
000000018037E26C  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037E270  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E274  0F 28 C5                    movaps  xmm0, xmm5
000000018037E277  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E27B  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037E27F  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037E283  41 0F 28 C8                 movaps  xmm1, xmm8
000000018037E287  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037E28B  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037E28F  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037E293  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037E297  0F 28 C6                    movaps  xmm0, xmm6
000000018037E29A  F3 0F 11 93 10 EE 00 00     movss   dword ptr [rbx+0EE10h], xmm2
000000018037E2A2  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037E2A6  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037E2AA  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037E2AE  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018037E2B3  0F 28 C6                    movaps  xmm0, xmm6
000000018037E2B6  F3 0F 59 83 20 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE20h]
000000018037E2BE  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037E2C2  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037E2C6  0F 28 C6                    movaps  xmm0, xmm6
000000018037E2C9  F3 0F 59 E1                 mulss   xmm4, xmm1
000000018037E2CD  F3 0F 11 AB 20 EE 00 00     movss   dword ptr [rbx+0EE20h], xmm5
000000018037E2D5  F3 0F 10 93 10 EE 00 00     movss   xmm2, dword ptr [rbx+0EE10h]
000000018037E2DD  F3 0F 59 93 D0 F0 00 00     mulss   xmm2, dword ptr [rbx+0F0D0h]
000000018037E2E5  F3 0F 10 8B 40 F0 00 00     movss   xmm1, dword ptr [rbx+0F040h]
000000018037E2ED  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037E2F1  F3 0F 59 AB E0 F0 00 00     mulss   xmm5, dword ptr [rbx+0F0E0h]
000000018037E2F9  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E2FD  F3 0F 10 83 C0 F0 00 00     movss   xmm0, dword ptr [rbx+0F0C0h]
000000018037E305  F3 0F 59 83 00 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE00h]
000000018037E30D  F3 0F 58 D5                 addss   xmm2, xmm5
000000018037E311  F3 0F 10 AB 50 F0 00 00     movss   xmm5, dword ptr [rbx+0F050h]
000000018037E319  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037E31D  F3 0F 11 93 40 EF 00 00     movss   dword ptr [rbx+0EF40h], xmm2
000000018037E325  F3 0F 59 AB 60 F1 00 00     mulss   xmm5, dword ptr [rbx+0F160h]
000000018037E32D  F3 0F 59 8B 50 F1 00 00     mulss   xmm1, dword ptr [rbx+0F150h]
000000018037E335  F3 0F 10 83 30 EE 00 00     movss   xmm0, dword ptr [rbx+0EE30h]
000000018037E33D  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037E341  F3 0F 59 AB 90 F0 00 00     mulss   xmm5, dword ptr [rbx+0F090h]
000000018037E349  F3 0F 11 A3 30 EE 00 00     movss   dword ptr [rbx+0EE30h], xmm4
000000018037E351  F3 0F 59 A3 80 F2 00 00     mulss   xmm4, dword ptr [rbx+0F280h]
000000018037E359  F3 0F 59 83 90 F2 00 00     mulss   xmm0, dword ptr [rbx+0F290h]
000000018037E361  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E365  F3 0F 59 A3 80 F0 00 00     mulss   xmm4, dword ptr [rbx+0F080h]
000000018037E36D  F3 0F 5C EC                 subss   xmm5, xmm4
000000018037E371  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037E375  73 06                       jnb     short loc_18037E37D
000000018037E377  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037E37B  EB 05                       jmp     short loc_18037E382
000000018037E37D  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037E382  0F 28 CD                    movaps  xmm1, xmm5
000000018037E385  0F 28 C5                    movaps  xmm0, xmm5
000000018037E388  F3 0F 59 83 30 F1 00 00     mulss   xmm0, dword ptr [rbx+0F130h]
000000018037E390  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037E394  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E398  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E39C  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E3A0  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037E3A4  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037E3A8  F3 0F 10 8B E0 ED 00 00     movss   xmm1, dword ptr [rbx+0EDE0h]
000000018037E3B0  F3 0F 11 AB E0 ED 00 00     movss   dword ptr [rbx+0EDE0h], xmm5
000000018037E3B8  0F 28 D5                    movaps  xmm2, xmm5
000000018037E3BB  F3 0F 10 9B F0 ED 00 00     movss   xmm3, dword ptr [rbx+0EDF0h]
000000018037E3C3  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037E3C7  0F 28 C3                    movaps  xmm0, xmm3
000000018037E3CA  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E3CE  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037E3D2  41 0F 28 E8                 movaps  xmm5, xmm8
000000018037E3D6  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018037E3DA  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037E3DE  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E3E2  0F 28 C6                    movaps  xmm0, xmm6
000000018037E3E5  F3 0F 11 A3 F0 ED 00 00     movss   dword ptr [rbx+0EDF0h], xmm4
000000018037E3ED  F3 0F 10 8B 00 EE 00 00     movss   xmm1, dword ptr [rbx+0EE00h]
000000018037E3F5  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037E3F9  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037E3FD  0F 28 C1                    movaps  xmm0, xmm1
000000018037E400  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E404  F3 0F 58 EC                 addss   xmm5, xmm4
000000018037E408  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037E40C  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037E410  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037E414  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037E418  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037E41C  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037E420  0F 28 C6                    movaps  xmm0, xmm6
000000018037E423  F3 0F 11 9B 00 EE 00 00     movss   dword ptr [rbx+0EE00h], xmm3
000000018037E42B  F3 0F 10 AB 10 EE 00 00     movss   xmm5, dword ptr [rbx+0EE10h]
000000018037E433  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037E437  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E43B  0F 28 C5                    movaps  xmm0, xmm5
000000018037E43E  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E442  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037E446  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037E44A  41 0F 28 C8                 movaps  xmm1, xmm8
000000018037E44E  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037E452  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037E456  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037E45A  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037E45E  0F 28 C6                    movaps  xmm0, xmm6
000000018037E461  F3 0F 11 93 10 EE 00 00     movss   dword ptr [rbx+0EE10h], xmm2
000000018037E469  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037E46D  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037E471  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037E475  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018037E47A  0F 28 C6                    movaps  xmm0, xmm6
000000018037E47D  F3 0F 59 83 20 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE20h]
000000018037E485  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037E489  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037E48D  0F 28 C6                    movaps  xmm0, xmm6
000000018037E490  F3 0F 59 D9                 mulss   xmm3, xmm1
000000018037E494  F3 0F 11 AB 20 EE 00 00     movss   dword ptr [rbx+0EE20h], xmm5
000000018037E49C  F3 0F 10 8B 10 EE 00 00     movss   xmm1, dword ptr [rbx+0EE10h]
000000018037E4A4  F3 0F 59 8B D0 F0 00 00     mulss   xmm1, dword ptr [rbx+0F0D0h]
000000018037E4AC  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037E4B0  F3 0F 59 AB E0 F0 00 00     mulss   xmm5, dword ptr [rbx+0F0E0h]
000000018037E4B8  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037E4BC  F3 0F 10 83 C0 F0 00 00     movss   xmm0, dword ptr [rbx+0F0C0h]
000000018037E4C4  F3 0F 59 83 00 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE00h]
000000018037E4CC  F3 0F 58 CD                 addss   xmm1, xmm5
000000018037E4D0  F3 0F 10 AB 40 F0 00 00     movss   xmm5, dword ptr [rbx+0F040h]
000000018037E4D8  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037E4DC  F3 0F 11 8B C0 EE 00 00     movss   dword ptr [rbx+0EEC0h], xmm1
000000018037E4E4  F3 0F 59 AB 40 F1 00 00     mulss   xmm5, dword ptr [rbx+0F140h]
000000018037E4EC  F3 0F 10 83 30 EE 00 00     movss   xmm0, dword ptr [rbx+0EE30h]
000000018037E4F4  F3 0F 59 AB 90 F0 00 00     mulss   xmm5, dword ptr [rbx+0F090h]
000000018037E4FC  F3 0F 11 9B C0 ED 00 00     movss   dword ptr [rbx+0EDC0h], xmm3
000000018037E504  F3 0F 59 9B 80 F2 00 00     mulss   xmm3, dword ptr [rbx+0F280h]
000000018037E50C  F3 0F 59 83 90 F2 00 00     mulss   xmm0, dword ptr [rbx+0F290h]
000000018037E514  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037E518  F3 0F 59 9B 80 F0 00 00     mulss   xmm3, dword ptr [rbx+0F080h]
000000018037E520  F3 0F 5C EB                 subss   xmm5, xmm3
000000018037E524  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037E528  73 06                       jnb     short loc_18037E530
000000018037E52A  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037E52E  EB 05                       jmp     short loc_18037E535
000000018037E530  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037E535  0F 28 CD                    movaps  xmm1, xmm5
000000018037E538  0F 28 C5                    movaps  xmm0, xmm5
000000018037E53B  F3 0F 59 83 30 F1 00 00     mulss   xmm0, dword ptr [rbx+0F130h]
000000018037E543  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037E547  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E54B  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E54F  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037E553  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037E557  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037E55B  F3 0F 11 AB 60 ED 00 00     movss   dword ptr [rbx+0ED60h], xmm5
000000018037E563  0F 28 D5                    movaps  xmm2, xmm5
000000018037E566  F3 0F 58 AB E0 ED 00 00     addss   xmm5, dword ptr [rbx+0EDE0h]
000000018037E56E  F3 0F 10 9B F0 ED 00 00     movss   xmm3, dword ptr [rbx+0EDF0h]
000000018037E576  0F 28 C3                    movaps  xmm0, xmm3
000000018037E579  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E57D  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037E581  41 0F 28 E8                 movaps  xmm5, xmm8
000000018037E585  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018037E589  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037E58D  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E591  0F 28 C6                    movaps  xmm0, xmm6
000000018037E594  F3 0F 11 A3 70 ED 00 00     movss   dword ptr [rbx+0ED70h], xmm4
000000018037E59C  F3 0F 10 8B 00 EE 00 00     movss   xmm1, dword ptr [rbx+0EE00h]
000000018037E5A4  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037E5A8  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037E5AC  0F 28 C1                    movaps  xmm0, xmm1
000000018037E5AF  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E5B3  F3 0F 58 EC                 addss   xmm5, xmm4
000000018037E5B7  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037E5BB  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037E5BF  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037E5C3  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037E5C7  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037E5CB  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037E5CF  0F 28 C6                    movaps  xmm0, xmm6
000000018037E5D2  F3 0F 11 9B 80 ED 00 00     movss   dword ptr [rbx+0ED80h], xmm3
000000018037E5DA  F3 0F 10 AB 10 EE 00 00     movss   xmm5, dword ptr [rbx+0EE10h]
000000018037E5E2  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037E5E6  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E5EA  0F 28 C5                    movaps  xmm0, xmm5
000000018037E5ED  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037E5F1  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037E5F5  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037E5F9  41 0F 28 C8                 movaps  xmm1, xmm8
000000018037E5FD  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037E601  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037E605  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037E609  0F 28 C6                    movaps  xmm0, xmm6
000000018037E60C  F3 0F 11 93 90 ED 00 00     movss   dword ptr [rbx+0ED90h], xmm2
000000018037E614  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037E618  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037E61C  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037E620  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018037E625  0F 28 C6                    movaps  xmm0, xmm6
000000018037E628  F3 0F 59 83 20 EE 00 00     mulss   xmm0, dword ptr [rbx+0EE20h]
000000018037E630  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037E634  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037E638  F3 44 0F 59 C1              mulss   xmm8, xmm1
000000018037E63D  F3 0F 11 AB A0 ED 00 00     movss   dword ptr [rbx+0EDA0h], xmm5
000000018037E645  F3 0F 10 9B 80 ED 00 00     movss   xmm3, dword ptr [rbx+0ED80h]
000000018037E64D  F3 0F 59 F5                 mulss   xmm6, xmm5
000000018037E651  F3 44 0F 58 C6              addss   xmm8, xmm6
000000018037E656  F3 44 0F 11 83 B0 ED 00 00  movss   dword ptr [rbx+0EDB0h], xmm8
000000018037E65F  F3 0F 10 83 D0 F0 00 00     movss   xmm0, dword ptr [rbx+0F0D0h]
000000018037E667  F3 0F 59 83 90 ED 00 00     mulss   xmm0, dword ptr [rbx+0ED90h]
000000018037E66F  F3 0F 59 AB E0 F0 00 00     mulss   xmm5, dword ptr [rbx+0F0E0h]
000000018037E677  F3 0F 59 9B C0 F0 00 00     mulss   xmm3, dword ptr [rbx+0F0C0h]
000000018037E67F  F3 0F 10 A3 80 EE 00 00     movss   xmm4, dword ptr [rbx+0EE80h]
000000018037E687  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037E68B  F3 0F 58 EB                 addss   xmm5, xmm3
000000018037E68F  F3 0F 11 AB 40 EE 00 00     movss   dword ptr [rbx+0EE40h], xmm5
000000018037E697  F3 0F 58 A3 F0 EF 00 00     addss   xmm4, dword ptr [rbx+0EFF0h]
000000018037E69F  F3 0F 10 83 00 EF 00 00     movss   xmm0, dword ptr [rbx+0EF00h]
000000018037E6A7  F3 0F 58 83 70 EF 00 00     addss   xmm0, dword ptr [rbx+0EF70h]
000000018037E6AF  F3 0F 10 8B 80 EF 00 00     movss   xmm1, dword ptr [rbx+0EF80h]
000000018037E6B7  F3 0F 58 8B F0 EE 00 00     addss   xmm1, dword ptr [rbx+0EEF0h]
000000018037E6BF  F3 0F 59 A3 70 F2 00 00     mulss   xmm4, dword ptr [rbx+0F270h]
000000018037E6C7  F3 0F 59 83 60 F2 00 00     mulss   xmm0, dword ptr [rbx+0F260h]
000000018037E6CF  F3 0F 59 8B 50 F2 00 00     mulss   xmm1, dword ptr [rbx+0F250h]
000000018037E6D7  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E6DB  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037E6DF  F3 0F 10 83 70 EE 00 00     movss   xmm0, dword ptr [rbx+0EE70h]
000000018037E6E7  F3 0F 58 83 00 F0 00 00     addss   xmm0, dword ptr [rbx+0F000h]
000000018037E6EF  F3 0F 10 8B E0 EF 00 00     movss   xmm1, dword ptr [rbx+0EFE0h]
000000018037E6F7  F3 0F 58 8B 90 EE 00 00     addss   xmm1, dword ptr [rbx+0EE90h]
000000018037E6FF  F3 0F 58 AB 30 F0 00 00     addss   xmm5, dword ptr [rbx+0F030h]
000000018037E707  F3 0F 59 83 40 F2 00 00     mulss   xmm0, dword ptr [rbx+0F240h]
000000018037E70F  F3 0F 59 8B 30 F2 00 00     mulss   xmm1, dword ptr [rbx+0F230h]
000000018037E717  F3 0F 59 AB 80 F1 00 00     mulss   xmm5, dword ptr [rbx+0F180h]
000000018037E71F  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E723  F3 0F 10 83 60 EF 00 00     movss   xmm0, dword ptr [rbx+0EF60h]
000000018037E72B  F3 0F 58 83 10 EF 00 00     addss   xmm0, dword ptr [rbx+0EF10h]
000000018037E733  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037E737  F3 0F 10 8B 90 EF 00 00     movss   xmm1, dword ptr [rbx+0EF90h]
000000018037E73F  F3 0F 58 8B E0 EE 00 00     addss   xmm1, dword ptr [rbx+0EEE0h]
000000018037E747  F3 0F 59 83 20 F2 00 00     mulss   xmm0, dword ptr [rbx+0F220h]
000000018037E74F  F3 0F 59 8B 10 F2 00 00     mulss   xmm1, dword ptr [rbx+0F210h]
000000018037E757  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E75B  F3 0F 10 83 10 F0 00 00     movss   xmm0, dword ptr [rbx+0F010h]
000000018037E763  F3 0F 58 83 60 EE 00 00     addss   xmm0, dword ptr [rbx+0EE60h]
000000018037E76B  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037E76F  F3 0F 10 8B D0 EF 00 00     movss   xmm1, dword ptr [rbx+0EFD0h]
000000018037E777  F3 0F 59 83 00 F2 00 00     mulss   xmm0, dword ptr [rbx+0F200h]
000000018037E77F  F3 0F 58 8B A0 EE 00 00     addss   xmm1, dword ptr [rbx+0EEA0h]
000000018037E787  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E78B  F3 0F 10 83 50 EF 00 00     movss   xmm0, dword ptr [rbx+0EF50h]
000000018037E793  F3 0F 58 83 20 EF 00 00     addss   xmm0, dword ptr [rbx+0EF20h]
000000018037E79B  F3 0F 59 8B F0 F1 00 00     mulss   xmm1, dword ptr [rbx+0F1F0h]
000000018037E7A3  F3 0F 59 83 E0 F1 00 00     mulss   xmm0, dword ptr [rbx+0F1E0h]
000000018037E7AB  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037E7AF  F3 0F 10 8B A0 EF 00 00     movss   xmm1, dword ptr [rbx+0EFA0h]
000000018037E7B7  F3 0F 58 8B D0 EE 00 00     addss   xmm1, dword ptr [rbx+0EED0h]
000000018037E7BF  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E7C3  F3 0F 10 83 20 F0 00 00     movss   xmm0, dword ptr [rbx+0F020h]
000000018037E7CB  F3 0F 59 8B D0 F1 00 00     mulss   xmm1, dword ptr [rbx+0F1D0h]
000000018037E7D3  F3 0F 58 83 50 EE 00 00     addss   xmm0, dword ptr [rbx+0EE50h]
000000018037E7DB  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037E7DF  F3 0F 10 8B C0 EF 00 00     movss   xmm1, dword ptr [rbx+0EFC0h]
000000018037E7E7  F3 0F 58 8B B0 EE 00 00     addss   xmm1, dword ptr [rbx+0EEB0h]
000000018037E7EF  F3 0F 59 83 C0 F1 00 00     mulss   xmm0, dword ptr [rbx+0F1C0h]
000000018037E7F7  F3 0F 59 8B B0 F1 00 00     mulss   xmm1, dword ptr [rbx+0F1B0h]
000000018037E7FF  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E803  F3 0F 10 83 40 EF 00 00     movss   xmm0, dword ptr [rbx+0EF40h]
000000018037E80B  F3 0F 58 83 30 EF 00 00     addss   xmm0, dword ptr [rbx+0EF30h]
000000018037E813  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037E817  F3 0F 10 8B B0 EF 00 00     movss   xmm1, dword ptr [rbx+0EFB0h]
000000018037E81F  F3 0F 59 83 A0 F1 00 00     mulss   xmm0, dword ptr [rbx+0F1A0h]
000000018037E827  F3 0F 58 8B C0 EE 00 00     addss   xmm1, dword ptr [rbx+0EEC0h]
000000018037E82F  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037E833  F3 0F 59 8B 90 F1 00 00     mulss   xmm1, dword ptr [rbx+0F190h]
000000018037E83B  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037E83F  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037E843  F3 0F 59 A3 10 F1 00 00     mulss   xmm4, dword ptr [rbx+0F110h]
000000018037E84B  F3 0F 11 A3 A0 F0 00 00     movss   dword ptr [rbx+0F0A0h], xmm4
000000018037E853  8B 83 A0 F2 00 00           mov     eax, [rbx+0F2A0h]
000000018037E859  89 83 B0 F2 00 00           mov     [rbx+0F2B0h], eax
000000018037E85F  F3 0F 10 83 D0 F2 00 00     movss   xmm0, dword ptr [rbx+0F2D0h]
000000018037E867  8B 83 C0 F2 00 00           mov     eax, [rbx+0F2C0h]
000000018037E86D  89 83 F0 F2 00 00           mov     [rbx+0F2F0h], eax
000000018037E873  F3 0F 11 83 00 F3 00 00     movss   dword ptr [rbx+0F300h], xmm0
000000018037E87B  8B 83 E0 F2 00 00           mov     eax, [rbx+0F2E0h]
000000018037E881  89 83 10 F3 00 00           mov     [rbx+0F310h], eax
000000018037E887  F3 0F 10 93 20 F3 00 00     movss   xmm2, dword ptr [rbx+0F320h]
000000018037E88F  F3 0F 11 93 30 F3 00 00     movss   dword ptr [rbx+0F330h], xmm2
000000018037E897  F3 0F 10 83 40 F3 00 00     movss   xmm0, dword ptr [rbx+0F340h]
000000018037E89F  F3 0F 11 83 50 F3 00 00     movss   dword ptr [rbx+0F350h], xmm0
000000018037E8A7  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037E8AB  F3 0F 59 93 60 F3 00 00     mulss   xmm2, dword ptr [rbx+0F360h]
000000018037E8B3  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037E8B7  F3 0F 11 93 40 F3 00 00     movss   dword ptr [rbx+0F340h], xmm2
000000018037E8BF  F3 0F 10 83 00 F3 00 00     movss   xmm0, dword ptr [rbx+0F300h]
000000018037E8C7  F3 0F 10 8B 10 F3 00 00     movss   xmm1, dword ptr [rbx+0F310h]
000000018037E8CF  F3 0F 59 D0                 mulss   xmm2, xmm0
000000018037E8D3  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037E8D7  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037E8DB  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037E8DF  F3 0F 11 93 70 F3 00 00     movss   dword ptr [rbx+0F370h], xmm2
000000018037E8E7  F3 0F 10 8B 80 F3 00 00     movss   xmm1, dword ptr [rbx+0F380h]
000000018037E8EF  F3 0F 11 8B 90 F3 00 00     movss   dword ptr [rbx+0F390h], xmm1
000000018037E8F7  F3 0F 10 83 A0 F3 00 00     movss   xmm0, dword ptr [rbx+0F3A0h]
000000018037E8FF  0F 28 D8                    movaps  xmm3, xmm0
000000018037E902  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037E906  F3 0F 59 DA                 mulss   xmm3, xmm2
000000018037E90A  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037E90E  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037E912  41 0F 2F DE                 comiss  xmm3, xmm14
000000018037E916  76 05                       jbe     short loc_18037E91D
000000018037E918  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018037E91B  EB 03                       jmp     short loc_18037E920
000000018037E91D  0F 57 C0                    xorps   xmm0, xmm0
000000018037E920  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018037E924  F3 0F 11 83 80 F3 00 00     movss   dword ptr [rbx+0F380h], xmm0
000000018037E92C  F3 0F 10 8B B0 F3 00 00     movss   xmm1, dword ptr [rbx+0F3B0h]
000000018037E934  F3 0F 11 8B C0 F3 00 00     movss   dword ptr [rbx+0F3C0h], xmm1
000000018037E93C  F3 0F 10 93 D0 F3 00 00     movss   xmm2, dword ptr [rbx+0F3D0h]
000000018037E944  F3 0F 11 93 E0 F3 00 00     movss   dword ptr [rbx+0F3E0h], xmm2
000000018037E94C  F3 0F 10 83 F0 F3 00 00     movss   xmm0, dword ptr [rbx+0F3F0h]
000000018037E954  0F 28 D8                    movaps  xmm3, xmm0
000000018037E957  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037E95B  F3 0F 59 D9                 mulss   xmm3, xmm1
000000018037E95F  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037E963  F3 0F 58 DA                 addss   xmm3, xmm2
000000018037E967  41 0F 2F DE                 comiss  xmm3, xmm14
000000018037E96B  76 05                       jbe     short loc_18037E972
000000018037E96D  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018037E970  EB 03                       jmp     short loc_18037E975
000000018037E972  0F 57 C0                    xorps   xmm0, xmm0
000000018037E975  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018037E979  F3 0F 11 83 D0 F3 00 00     movss   dword ptr [rbx+0F3D0h], xmm0
000000018037E981  F3 0F 10 AB 00 F4 00 00     movss   xmm5, dword ptr [rbx+0F400h]
000000018037E989  F3 0F 10 B3 80 CF 00 00     movss   xmm6, dword ptr [rbx+0CF80h]
000000018037E991  0F 28 E5                    movaps  xmm4, xmm5
000000018037E994  F3 0F 11 AB 10 F4 00 00     movss   dword ptr [rbx+0F410h], xmm5
000000018037E99C  0F 28 C5                    movaps  xmm0, xmm5
000000018037E99F  F3 0F 59 A3 60 F4 00 00     mulss   xmm4, dword ptr [rbx+0F460h]
000000018037E9A7  0F 28 DD                    movaps  xmm3, xmm5
000000018037E9AA  F3 0F 58 83 30 F4 00 00     addss   xmm0, dword ptr [rbx+0F430h]
000000018037E9B2  F3 0F 58 9B 50 F4 00 00     addss   xmm3, dword ptr [rbx+0F450h]
000000018037E9BA  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037E9BE  73 06                       jnb     short loc_18037E9C6
000000018037E9C0  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037E9C4  EB 05                       jmp     short loc_18037E9CB
000000018037E9C6  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037E9CB  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037E9CF  72 1B                       jb      short loc_18037E9EC
000000018037E9D1  F3 0F 10 83 40 F4 00 00     movss   xmm0, dword ptr [rbx+0F440h]
000000018037E9D9  0F 28 D8                    movaps  xmm3, xmm0
000000018037E9DC  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037E9E0  F3 0F 59 DE                 mulss   xmm3, xmm6
000000018037E9E4  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037E9E8  F3 0F 58 DD                 addss   xmm3, xmm5
000000018037E9EC  41 0F 2E F6                 ucomiss xmm6, xmm14
000000018037E9F0  F3 0F 10 8B 80 F4 00 00     movss   xmm1, dword ptr [rbx+0F480h]
000000018037E9F8  0F 28 D4                    movaps  xmm2, xmm4
000000018037E9FB  F3 0F 59 93 70 F4 00 00     mulss   xmm2, dword ptr [rbx+0F470h]
000000018037EA03  0F 28 C1                    movaps  xmm0, xmm1
000000018037EA06  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037EA0A  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037EA0E  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037EA12  0F 28 C2                    movaps  xmm0, xmm2
000000018037EA15  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037EA19  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037EA1D  F3 0F 5C C2                 subss   xmm0, xmm2
000000018037EA21  F3 0F 58 C5                 addss   xmm0, xmm5
000000018037EA25  74 03                       jz      short loc_18037EA2A
000000018037EA27  0F 28 C3                    movaps  xmm0, xmm3
000000018037EA2A  F3 0F 11 83 20 F4 00 00     movss   dword ptr [rbx+0F420h], xmm0
000000018037EA32  F3 0F 11 83 00 F4 00 00     movss   dword ptr [rbx+0F400h], xmm0
000000018037EA3A  F3 0F 10 BB A0 F0 00 00     movss   xmm7, dword ptr [rbx+0F0A0h]
000000018037EA42  F3 0F 10 B3 10 D8 00 00     movss   xmm6, dword ptr [rbx+0D810h]
000000018037EA4A  F3 0F 10 9B 10 E8 00 00     movss   xmm3, dword ptr [rbx+0E810h]
000000018037EA52  F3 0F 10 83 F0 D9 00 00     movss   xmm0, dword ptr [rbx+0D9F0h]
000000018037EA5A  F3 0F 10 8B A0 F2 00 00     movss   xmm1, dword ptr [rbx+0F2A0h]
000000018037EA62  8B 83 C0 F4 00 00           mov     eax, [rbx+0F4C0h]
000000018037EA68  89 83 D0 F4 00 00           mov     [rbx+0F4D0h], eax
000000018037EA6E  8B 83 E0 F4 00 00           mov     eax, [rbx+0F4E0h]
000000018037EA74  89 83 F0 F4 00 00           mov     [rbx+0F4F0h], eax
000000018037EA7A  F3 0F 11 83 90 F4 00 00     movss   dword ptr [rbx+0F490h], xmm0
000000018037EA82  F3 0F 11 8B A0 F4 00 00     movss   dword ptr [rbx+0F4A0h], xmm1
000000018037EA8A  F3 0F 59 9B B0 F5 00 00     mulss   xmm3, dword ptr [rbx+0F5B0h]
000000018037EA92  F3 0F 10 A3 D0 F4 00 00     movss   xmm4, dword ptr [rbx+0F4D0h]
000000018037EA9A  F3 0F 10 93 10 F5 00 00     movss   xmm2, dword ptr [rbx+0F510h]
000000018037EAA2  F3 0F 11 9B B0 F4 00 00     movss   dword ptr [rbx+0F4B0h], xmm3
000000018037EAAA  0F 28 DF                    movaps  xmm3, xmm7
000000018037EAAD  F3 0F 59 B3 20 F5 00 00     mulss   xmm6, dword ptr [rbx+0F520h]
000000018037EAB5  F3 0F 5C DC                 subss   xmm3, xmm4
000000018037EAB9  F3 0F 59 93 20 F4 00 00     mulss   xmm2, dword ptr [rbx+0F420h]
000000018037EAC1  F3 0F 10 8B 30 F5 00 00     movss   xmm1, dword ptr [rbx+0F530h]
000000018037EAC9  0F 28 C3                    movaps  xmm0, xmm3
000000018037EACC  F3 0F 59 83 50 F5 00 00     mulss   xmm0, dword ptr [rbx+0F550h]
000000018037EAD4  F3 0F 58 F2                 addss   xmm6, xmm2
000000018037EAD8  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037EADC  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037EAE0  F3 0F 11 A3 C0 F4 00 00     movss   dword ptr [rbx+0F4C0h], xmm4
000000018037EAE8  F3 0F 59 8B 90 F4 00 00     mulss   xmm1, dword ptr [rbx+0F490h]
000000018037EAF0  F3 0F 10 93 40 F5 00 00     movss   xmm2, dword ptr [rbx+0F540h]
000000018037EAF8  F3 0F 59 9B C0 F5 00 00     mulss   xmm3, dword ptr [rbx+0F5C0h]
000000018037EB00  F3 0F 59 A3 D0 F5 00 00     mulss   xmm4, dword ptr [rbx+0F5D0h]
000000018037EB08  F3 0F 58 F1                 addss   xmm6, xmm1
000000018037EB0C  0F 28 CA                    movaps  xmm1, xmm2
000000018037EB0F  F3 0F 59 8B A0 F4 00 00     mulss   xmm1, dword ptr [rbx+0F4A0h]
000000018037EB17  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037EB1B  F3 0F 58 DC                 addss   xmm3, xmm4
000000018037EB1F  F3 0F 5C CA                 subss   xmm1, xmm2
000000018037EB23  F3 0F 58 CE                 addss   xmm1, xmm6
000000018037EB27  F3 0F 10 B3 60 F5 00 00     movss   xmm6, dword ptr [rbx+0F560h]
000000018037EB2F  F3 0F 5C C6                 subss   xmm0, xmm6
000000018037EB33  F3 0F 59 8B 90 F5 00 00     mulss   xmm1, dword ptr [rbx+0F590h]
000000018037EB3B  F3 0F 59 F8                 mulss   xmm7, xmm0
000000018037EB3F  41 0F 2F CE                 comiss  xmm1, xmm14
000000018037EB43  76 05                       jbe     short loc_18037EB4A
000000018037EB45  0F 5A C1                    cvtps2pd xmm0, xmm1
000000018037EB48  EB 03                       jmp     short loc_18037EB4D
000000018037EB4A  0F 57 C0                    xorps   xmm0, xmm0
000000018037EB4D  F3 0F 10 93 80 F5 00 00     movss   xmm2, dword ptr [rbx+0F580h]
000000018037EB55  F3 0F 10 A3 70 F5 00 00     movss   xmm4, dword ptr [rbx+0F570h]
000000018037EB5D  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
000000018037EB61  F3 0F 10 83 B0 F4 00 00     movss   xmm0, dword ptr [rbx+0F4B0h]
000000018037EB69  F3 0F 59 AB A0 F5 00 00     mulss   xmm5, dword ptr [rbx+0F5A0h]
000000018037EB71  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037EB76  F3 0F 59 F3                 mulss   xmm6, xmm3
000000018037EB7A  F3 0F 10 9B F0 F4 00 00     movss   xmm3, dword ptr [rbx+0F4F0h]
000000018037EB82  F3 0F 58 F7                 addss   xmm6, xmm7
000000018037EB86  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018037EB8A  F3 0F 10 83 E0 F5 00 00     movss   xmm0, dword ptr [rbx+0F5E0h]
000000018037EB92  0F 28 C8                    movaps  xmm1, xmm0
000000018037EB95  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037EB99  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018037EB9D  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037EBA1  F3 0F 5C C8                 subss   xmm1, xmm0
000000018037EBA5  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037EBA9  F3 0F 11 9B E0 F4 00 00     movss   dword ptr [rbx+0F4E0h], xmm3
000000018037EBB1  F3 0F 59 E3                 mulss   xmm4, xmm3
000000018037EBB5  F3 0F 58 E2                 addss   xmm4, xmm2
000000018037EBB9  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037EBBD  F3 0F 59 A3 F0 F5 00 00     mulss   xmm4, dword ptr [rbx+0F5F0h]
000000018037EBC5  F3 0F 11 A3 00 F5 00 00     movss   dword ptr [rbx+0F500h], xmm4
000000018037EBCD  8B 83 10 F6 00 00           mov     eax, [rbx+0F610h]
000000018037EBD3  89 83 20 F6 00 00           mov     [rbx+0F620h], eax
000000018037EBD9  8B 83 00 F6 00 00           mov     eax, [rbx+0F600h]
000000018037EBDF  89 83 10 F6 00 00           mov     [rbx+0F610h], eax
000000018037EBE5  F3 0F 10 83 20 F6 00 00     movss   xmm0, dword ptr [rbx+0F620h]
000000018037EBED  F3 0F 10 8B 30 F6 00 00     movss   xmm1, dword ptr [rbx+0F630h]
000000018037EBF5  F3 0F 5C E0                 subss   xmm4, xmm0
000000018037EBF9  F3 0F 11 A3 00 F6 00 00     movss   dword ptr [rbx+0F600h], xmm4
000000018037EC01  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037EC05  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037EC09  F3 0F 11 8B 10 F6 00 00     movss   dword ptr [rbx+0F610h], xmm1
000000018037EC11  F3 0F 10 93 00 F6 00 00     movss   xmm2, dword ptr [rbx+0F600h]
000000018037EC19  F3 0F 10 B3 F0 F2 00 00     movss   xmm6, dword ptr [rbx+0F2F0h]
000000018037EC21  0F 28 C2                    movaps  xmm0, xmm2
000000018037EC24  41 0F 2F F6                 comiss  xmm6, xmm14
000000018037EC28  8B 83 60 F6 00 00           mov     eax, [rbx+0F660h]
000000018037EC2E  89 83 70 F6 00 00           mov     [rbx+0F670h], eax
000000018037EC34  8B 83 50 F6 00 00           mov     eax, [rbx+0F650h]
000000018037EC3A  89 83 60 F6 00 00           mov     [rbx+0F660h], eax
000000018037EC40  8B 83 40 F6 00 00           mov     eax, [rbx+0F640h]
000000018037EC46  89 83 50 F6 00 00           mov     [rbx+0F650h], eax
000000018037EC4C  F3 0F 11 93 40 F6 00 00     movss   dword ptr [rbx+0F640h], xmm2
000000018037EC54  F3 0F 59 83 90 F6 00 00     mulss   xmm0, dword ptr [rbx+0F690h]
000000018037EC5C  F3 0F 10 A3 50 F6 00 00     movss   xmm4, dword ptr [rbx+0F650h]
000000018037EC64  F3 0F 10 8B B0 F6 00 00     movss   xmm1, dword ptr [rbx+0F6B0h]
000000018037EC6C  0F 28 EC                    movaps  xmm5, xmm4
000000018037EC6F  F3 0F 59 8B 60 F6 00 00     mulss   xmm1, dword ptr [rbx+0F660h]
000000018037EC77  F3 0F 59 AB A0 F6 00 00     mulss   xmm5, dword ptr [rbx+0F6A0h]
000000018037EC7F  F3 0F 59 A3 D0 F6 00 00     mulss   xmm4, dword ptr [rbx+0F6D0h]
000000018037EC87  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037EC8B  0F 28 C2                    movaps  xmm0, xmm2
000000018037EC8E  F3 0F 59 83 C0 F6 00 00     mulss   xmm0, dword ptr [rbx+0F6C0h]
000000018037EC96  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037EC9A  F3 0F 10 8B E0 F6 00 00     movss   xmm1, dword ptr [rbx+0F6E0h]
000000018037ECA2  F3 0F 59 8B 70 F6 00 00     mulss   xmm1, dword ptr [rbx+0F670h]
000000018037ECAA  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037ECAE  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037ECB2  76 05                       jbe     short loc_18037ECB9
000000018037ECB4  0F 5A C6                    cvtps2pd xmm0, xmm6
000000018037ECB7  EB 03                       jmp     short loc_18037ECBC
000000018037ECB9  0F 57 C0                    xorps   xmm0, xmm0
000000018037ECBC  0F 2F 35 FD 67 76 00        comiss  xmm6, cs:dword_180AE54C0
000000018037ECC3  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018037ECC7  F3 0F 11 AB 50 F6 00 00     movss   dword ptr [rbx+0F650h], xmm5
000000018037ECCF  0F 28 D8                    movaps  xmm3, xmm0
000000018037ECD2  F3 0F 11 A3 60 F6 00 00     movss   dword ptr [rbx+0F660h], xmm4
000000018037ECDA  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037ECDE  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037ECE2  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037ECE6  0F 28 C6                    movaps  xmm0, xmm6
000000018037ECE9  41 0F 57 C3                 xorps   xmm0, xmm11
000000018037ECED  F3 0F 58 DA                 addss   xmm3, xmm2
000000018037ECF1  73 09                       jnb     short loc_18037ECFC
000000018037ECF3  45 0F 57 D2                 xorps   xmm10, xmm10
000000018037ECF7  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
000000018037ECFC  41 0F 2F F6                 comiss  xmm6, xmm14
000000018037ED00  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
000000018037ED05  0F 28 C8                    movaps  xmm1, xmm0
000000018037ED08  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037ED0C  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037ED10  F3 0F 5C C8                 subss   xmm1, xmm0
000000018037ED14  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037ED18  72 03                       jb      short loc_18037ED1D
000000018037ED1A  0F 28 D3                    movaps  xmm2, xmm3
000000018037ED1D  F3 0F 11 93 80 F6 00 00     movss   dword ptr [rbx+0F680h], xmm2
000000018037ED25  F3 0F 59 93 80 F3 00 00     mulss   xmm2, dword ptr [rbx+0F380h]
000000018037ED2D  F3 0F 11 93 F0 F6 00 00     movss   dword ptr [rbx+0F6F0h], xmm2
000000018037ED35  F3 0F 59 93 D0 F3 00 00     mulss   xmm2, dword ptr [rbx+0F3D0h]
000000018037ED3D  F3 0F 11 93 00 F7 00 00     movss   dword ptr [rbx+0F700h], xmm2
000000018037ED45  F3 0F 10 83 B0 DE 00 00     movss   xmm0, dword ptr [rbx+0DEB0h]
000000018037ED4D  F3 0F 58 83 10 DC 00 00     addss   xmm0, dword ptr [rbx+0DC10h]
000000018037ED55  44 0F 5A E0                 cvtps2pd xmm12, xmm0
000000018037ED59  F2 44 0F 5F 25 46 BF 60 00  maxsd   xmm12, cs:qword_18098ACA8
000000018037ED62  F2 44 0F 5D 25 25 BF 60 00  minsd   xmm12, cs:qword_18098AC90
000000018037ED6B  41 0F 28 CC                 movaps  xmm1, xmm12
000000018037ED6F  41 0F 28 C4                 movaps  xmm0, xmm12
000000018037ED73  F2 0F 58 05 ED 64 76 00     addsd   xmm0, cs:qword_180AE5268
000000018037ED7B  F2 41 0F 59 CC              mulsd   xmm1, xmm12
000000018037ED80  41 0F 28 FC                 movaps  xmm7, xmm12
000000018037ED84  F2 0F 2C C0                 cvttsd2si eax, xmm0
000000018037ED88  0F 28 D1                    movaps  xmm2, xmm1
000000018037ED8B  48 63 C8                    movsxd  rcx, eax
000000018037ED8E  F2 41 0F 59 D4              mulsd   xmm2, xmm12
000000018037ED93  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
000000018037ED9A  0F 28 DA                    movaps  xmm3, xmm2
000000018037ED9D  F2 41 0F 59 DC              mulsd   xmm3, xmm12
000000018037EDA2  48 8D 0D 37 A7 60 00        lea     rcx, unk_1809894E0
000000018037EDA9  48 03 C1                    add     rax, rcx
000000018037EDAC  0F 28 E3                    movaps  xmm4, xmm3
000000018037EDAF  F2 41 0F 59 E4              mulsd   xmm4, xmm12
000000018037EDB4  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
000000018037EDB9  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
000000018037EDBE  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
000000018037EDC3  0F 28 EC                    movaps  xmm5, xmm4
000000018037EDC6  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
000000018037EDCA  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
000000018037EDCF  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
000000018037EDD4  F2 0F 58 F9                 addsd   xmm7, xmm1
000000018037EDD8  F2 41 0F 59 EC              mulsd   xmm5, xmm12
000000018037EDDD  F2 0F 58 FA                 addsd   xmm7, xmm2
000000018037EDE1  0F 28 F5                    movaps  xmm6, xmm5
000000018037EDE4  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
000000018037EDE9  F2 41 0F 59 F4              mulsd   xmm6, xmm12
000000018037EDEE  F2 0F 58 FB                 addsd   xmm7, xmm3
000000018037EDF2  44 0F 28 C6                 movaps  xmm8, xmm6
000000018037EDF6  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
000000018037EDFB  F2 0F 58 FC                 addsd   xmm7, xmm4
000000018037EDFF  F2 45 0F 59 C4              mulsd   xmm8, xmm12
000000018037EE04  F2 0F 58 FD                 addsd   xmm7, xmm5
000000018037EE08  45 0F 28 C8                 movaps  xmm9, xmm8
000000018037EE0C  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
000000018037EE15  F2 45 0F 59 CC              mulsd   xmm9, xmm12
000000018037EE1A  F2 0F 58 FE                 addsd   xmm7, xmm6
000000018037EE1E  45 0F 28 D1                 movaps  xmm10, xmm9
000000018037EE22  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
000000018037EE2B  F2 41 0F 58 F8              addsd   xmm7, xmm8
000000018037EE30  F2 45 0F 59 D4              mulsd   xmm10, xmm12
000000018037EE35  F2 41 0F 58 F9              addsd   xmm7, xmm9
000000018037EE3A  45 0F 28 DA                 movaps  xmm11, xmm10
000000018037EE3E  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
000000018037EE47  F2 45 0F 59 DC              mulsd   xmm11, xmm12
000000018037EE4C  F2 41 0F 58 FA              addsd   xmm7, xmm10
000000018037EE51  41 0F 28 C3                 movaps  xmm0, xmm11
000000018037EE55  F2 45 0F 59 DC              mulsd   xmm11, xmm12
000000018037EE5A  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
000000018037EE62  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
000000018037EE6B  F2 0F 58 F8                 addsd   xmm7, xmm0
000000018037EE6F  F2 41 0F 58 FB              addsd   xmm7, xmm11
000000018037EE74  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
000000018037EE78  F3 0F 5D 1D 18 BE 60 00     minss   xmm3, cs:dword_18098AC98
000000018037EE80  F3 0F 5F 1D 28 BE 60 00     maxss   xmm3, cs:dword_18098ACB0
000000018037EE88  F3 0F 59 9B 20 DC 00 00     mulss   xmm3, dword ptr [rbx+0DC20h]
000000018037EE90  F3 0F 11 9B 90 DE 00 00     movss   dword ptr [rbx+0DE90h], xmm3
000000018037EE98  8B 83 30 E0 00 00           mov     eax, [rbx+0E030h]
000000018037EE9E  F3 0F 10 AB 10 DC 00 00     movss   xmm5, dword ptr [rbx+0DC10h]
000000018037EEA6  F3 0F 10 83 E0 DD 00 00     movss   xmm0, dword ptr [rbx+0DDE0h]
000000018037EEAE  F3 0F 10 8B F0 DD 00 00     movss   xmm1, dword ptr [rbx+0DDF0h]
000000018037EEB6  F3 0F 10 93 00 DE 00 00     movss   xmm2, dword ptr [rbx+0DE00h]
000000018037EEBE  89 83 40 E0 00 00           mov     [rbx+0E040h], eax
000000018037EEC4  8B 83 50 E0 00 00           mov     eax, [rbx+0E050h]
000000018037EECA  89 83 60 E0 00 00           mov     [rbx+0E060h], eax
000000018037EED0  8B 83 00 E1 00 00           mov     eax, [rbx+0E100h]
000000018037EED6  89 83 10 E1 00 00           mov     [rbx+0E110h], eax
000000018037EEDC  8B 83 F0 E0 00 00           mov     eax, [rbx+0E0F0h]
000000018037EEE2  89 83 00 E1 00 00           mov     [rbx+0E100h], eax
000000018037EEE8  8B 83 E0 E0 00 00           mov     eax, [rbx+0E0E0h]
000000018037EEEE  89 83 F0 E0 00 00           mov     [rbx+0E0F0h], eax
000000018037EEF4  8B 83 D0 E0 00 00           mov     eax, [rbx+0E0D0h]
000000018037EEFA  89 83 E0 E0 00 00           mov     [rbx+0E0E0h], eax
000000018037EF00  8B 83 C0 E0 00 00           mov     eax, [rbx+0E0C0h]
000000018037EF06  89 83 D0 E0 00 00           mov     [rbx+0E0D0h], eax
000000018037EF0C  8B 83 B0 E0 00 00           mov     eax, [rbx+0E0B0h]
000000018037EF12  89 83 C0 E0 00 00           mov     [rbx+0E0C0h], eax
000000018037EF18  8B 83 A0 E0 00 00           mov     eax, [rbx+0E0A0h]
000000018037EF1E  89 83 B0 E0 00 00           mov     [rbx+0E0B0h], eax
000000018037EF24  8B 83 80 E1 00 00           mov     eax, [rbx+0E180h]
000000018037EF2A  89 83 90 E1 00 00           mov     [rbx+0E190h], eax
000000018037EF30  8B 83 70 E1 00 00           mov     eax, [rbx+0E170h]
000000018037EF36  89 83 80 E1 00 00           mov     [rbx+0E180h], eax
000000018037EF3C  8B 83 60 E1 00 00           mov     eax, [rbx+0E160h]
000000018037EF42  89 83 70 E1 00 00           mov     [rbx+0E170h], eax
000000018037EF48  8B 83 50 E1 00 00           mov     eax, [rbx+0E150h]
000000018037EF4E  89 83 60 E1 00 00           mov     [rbx+0E160h], eax
000000018037EF54  8B 83 40 E1 00 00           mov     eax, [rbx+0E140h]
000000018037EF5A  89 83 50 E1 00 00           mov     [rbx+0E150h], eax
000000018037EF60  8B 83 30 E1 00 00           mov     eax, [rbx+0E130h]
000000018037EF66  89 83 40 E1 00 00           mov     [rbx+0E140h], eax
000000018037EF6C  8B 83 20 E1 00 00           mov     eax, [rbx+0E120h]
000000018037EF72  89 83 30 E1 00 00           mov     [rbx+0E130h], eax
000000018037EF78  8B 83 00 E2 00 00           mov     eax, [rbx+0E200h]
000000018037EF7E  89 83 10 E2 00 00           mov     [rbx+0E210h], eax
000000018037EF84  8B 83 F0 E1 00 00           mov     eax, [rbx+0E1F0h]
000000018037EF8A  89 83 00 E2 00 00           mov     [rbx+0E200h], eax
000000018037EF90  8B 83 E0 E1 00 00           mov     eax, [rbx+0E1E0h]
000000018037EF96  89 83 F0 E1 00 00           mov     [rbx+0E1F0h], eax
000000018037EF9C  8B 83 D0 E1 00 00           mov     eax, [rbx+0E1D0h]
000000018037EFA2  89 83 E0 E1 00 00           mov     [rbx+0E1E0h], eax
000000018037EFA8  8B 83 C0 E1 00 00           mov     eax, [rbx+0E1C0h]
000000018037EFAE  89 83 D0 E1 00 00           mov     [rbx+0E1D0h], eax
000000018037EFB4  8B 83 B0 E1 00 00           mov     eax, [rbx+0E1B0h]
000000018037EFBA  89 83 C0 E1 00 00           mov     [rbx+0E1C0h], eax
000000018037EFC0  8B 83 A0 E1 00 00           mov     eax, [rbx+0E1A0h]
000000018037EFC6  89 83 B0 E1 00 00           mov     [rbx+0E1B0h], eax
000000018037EFCC  8B 83 80 E2 00 00           mov     eax, [rbx+0E280h]
000000018037EFD2  89 83 90 E2 00 00           mov     [rbx+0E290h], eax
000000018037EFD8  8B 83 70 E2 00 00           mov     eax, [rbx+0E270h]
000000018037EFDE  89 83 80 E2 00 00           mov     [rbx+0E280h], eax
000000018037EFE4  8B 83 60 E2 00 00           mov     eax, [rbx+0E260h]
000000018037EFEA  89 83 70 E2 00 00           mov     [rbx+0E270h], eax
000000018037EFF0  8B 83 50 E2 00 00           mov     eax, [rbx+0E250h]
000000018037EFF6  89 83 60 E2 00 00           mov     [rbx+0E260h], eax
000000018037EFFC  8B 83 40 E2 00 00           mov     eax, [rbx+0E240h]
000000018037F002  89 83 50 E2 00 00           mov     [rbx+0E250h], eax
000000018037F008  8B 83 30 E2 00 00           mov     eax, [rbx+0E230h]
000000018037F00E  89 83 40 E2 00 00           mov     [rbx+0E240h], eax
000000018037F014  8B 83 20 E2 00 00           mov     eax, [rbx+0E220h]
000000018037F01A  89 83 30 E2 00 00           mov     [rbx+0E230h], eax
000000018037F020  8B 83 C0 E2 00 00           mov     eax, [rbx+0E2C0h]
000000018037F026  89 83 D0 E2 00 00           mov     [rbx+0E2D0h], eax
000000018037F02C  8B 83 B0 E2 00 00           mov     eax, [rbx+0E2B0h]
000000018037F032  89 83 C0 E2 00 00           mov     [rbx+0E2C0h], eax
000000018037F038  F3 0F 11 83 D0 DF 00 00     movss   dword ptr [rbx+0DFD0h], xmm0
000000018037F040  F3 0F 11 8B E0 DF 00 00     movss   dword ptr [rbx+0DFE0h], xmm1
000000018037F048  F3 0F 58 AB F0 E5 00 00     addss   xmm5, dword ptr [rbx+0E5F0h]
000000018037F050  F3 0F 59 9B F0 E2 00 00     mulss   xmm3, dword ptr [rbx+0E2F0h]
000000018037F058  F3 0F 10 83 E0 E2 00 00     movss   xmm0, dword ptr [rbx+0E2E0h]
000000018037F060  F3 0F 11 93 F0 DF 00 00     movss   dword ptr [rbx+0DFF0h], xmm2
000000018037F068  F3 0F 10 93 10 E3 00 00     movss   xmm2, dword ptr [rbx+0E310h]
000000018037F070  F3 0F 59 AB 00 E6 00 00     mulss   xmm5, dword ptr [rbx+0E600h]
000000018037F078  F3 0F 5F D3                 maxss   xmm2, xmm3
000000018037F07C  F3 0F 58 AB E0 E5 00 00     addss   xmm5, dword ptr [rbx+0E5E0h]
000000018037F084  F3 0F 11 93 00 E0 00 00     movss   dword ptr [rbx+0E000h], xmm2
000000018037F08C  F3 0F 58 83 30 DC 00 00     addss   xmm0, dword ptr [rbx+0DC30h]
000000018037F094  41 0F 2F EE                 comiss  xmm5, xmm14
000000018037F098  F3 0F 11 83 20 E0 00 00     movss   dword ptr [rbx+0E020h], xmm0
000000018037F0A0  76 05                       jbe     short loc_18037F0A7
000000018037F0A2  0F 5A C5                    cvtps2pd xmm0, xmm5
000000018037F0A5  EB 03                       jmp     short loc_18037F0AA
000000018037F0A7  0F 57 C0                    xorps   xmm0, xmm0
000000018037F0AA  F3 0F 10 0D AA 5E 76 00     movss   xmm1, cs:dword_180AE4F5C
000000018037F0B2  F3 44 0F 10 15 2D 61 76 00  movss   xmm10, cs:flt_180AE51E8
000000018037F0BB  F3 0F 5E CA                 divss   xmm1, xmm2
000000018037F0BF  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018037F0C3  F3 0F 11 8B 10 E0 00 00     movss   dword ptr [rbx+0E010h], xmm1
000000018037F0CB  F3 0F 11 83 A0 E2 00 00     movss   dword ptr [rbx+0E2A0h], xmm0
000000018037F0D3  F3 0F 10 B3 60 E0 00 00     movss   xmm6, dword ptr [rbx+0E060h]
000000018037F0DB  F3 0F 10 8B 40 E0 00 00     movss   xmm1, dword ptr [rbx+0E040h]
000000018037F0E3  F3 0F 11 B3 80 DF 00 00     movss   dword ptr [rbx+0DF80h], xmm6
000000018037F0EB  F3 0F 58 F2                 addss   xmm6, xmm2
000000018037F0EF  F3 0F 11 8B 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm1
000000018037F0F7  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037F0FB  76 1B                       jbe     short loc_18037F118
000000018037F0FD  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037F102  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037F106  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037F109  E8 CA 03 37 00              call    fmodf
000000018037F10E  0F 28 F0                    movaps  xmm6, xmm0
000000018037F111  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037F116  EB 1F                       jmp     short loc_18037F137
000000018037F118  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037F11C  73 19                       jnb     short loc_18037F137
000000018037F11E  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037F123  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037F127  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037F12A  E8 A9 03 37 00              call    fmodf
000000018037F12F  0F 28 F0                    movaps  xmm6, xmm0
000000018037F132  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037F137  F3 44 0F 10 25 CC 5E 76 00  movss   xmm12, cs:dword_180AE500C
000000018037F140  0F 28 C6                    movaps  xmm0, xmm6
000000018037F143  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037F148  F3 0F 11 B3 70 DF 00 00     movss   dword ptr [rbx+0DF70h], xmm6
000000018037F150  0F 28 FE                    movaps  xmm7, xmm6
000000018037F153  F3 0F 59 BB 60 E3 00 00     mulss   xmm7, dword ptr [rbx+0E360h]
000000018037F15B  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018037F160  E8 5B 9E FE FF              call    sub_180368FC0
000000018037F165  F3 44 0F 10 1D D6 62 76 00  movss   xmm11, cs:dword_180AE5444
000000018037F16E  0F 28 E8                    movaps  xmm5, xmm0
000000018037F171  F3 41 0F 59 EB              mulss   xmm5, xmm11
000000018037F176  F3 0F 59 AB 10 E0 00 00     mulss   xmm5, dword ptr [rbx+0E010h]
000000018037F17E  F3 0F 59 AB 30 E3 00 00     mulss   xmm5, dword ptr [rbx+0E330h]
000000018037F186  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037F18A  73 06                       jnb     short loc_18037F192
000000018037F18C  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037F190  EB 05                       jmp     short loc_18037F197
000000018037F192  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037F197  F3 0F 59 AB 00 E3 00 00     mulss   xmm5, dword ptr [rbx+0E300h]
000000018037F19F  0F 28 D5                    movaps  xmm2, xmm5
000000018037F1A2  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037F1A6  0F 28 CA                    movaps  xmm1, xmm2
000000018037F1A9  0F 28 C2                    movaps  xmm0, xmm2
000000018037F1AC  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037F1B4  0F 28 DA                    movaps  xmm3, xmm2
000000018037F1B7  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F1BB  0F 28 E2                    movaps  xmm4, xmm2
000000018037F1BE  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
000000018037F1C6  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037F1CE  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037F1D2  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
000000018037F1DA  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037F1DE  0F 28 C3                    movaps  xmm0, xmm3
000000018037F1E1  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037F1E9  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037F1ED  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F1F1  F3 0F 10 8B 20 E0 00 00     movss   xmm1, dword ptr [rbx+0E020h]
000000018037F1F9  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037F1FD  0F 28 C1                    movaps  xmm0, xmm1
000000018037F200  F3 0F 58 C6                 addss   xmm0, xmm6
000000018037F204  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037F208  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037F20C  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037F210  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037F214  F3 0F 11 A3 70 E0 00 00     movss   dword ptr [rbx+0E070h], xmm4
000000018037F21C  72 07                       jb      short loc_18037F225
000000018037F21E  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018037F223  EB 05                       jmp     short loc_18037F22A
000000018037F225  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037F22A  0F 28 F0                    movaps  xmm6, xmm0
000000018037F22D  73 06                       jnb     short loc_18037F235
000000018037F22F  41 0F 28 F7                 movaps  xmm6, xmm15
000000018037F233  EB 06                       jmp     short loc_18037F23B
000000018037F235  76 04                       jbe     short loc_18037F23B
000000018037F237  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037F23B  F3 44 0F 10 83 70 DF 00 00  movss   xmm8, dword ptr [rbx+0DF70h]
000000018037F244  F3 0F 59 B3 70 E3 00 00     mulss   xmm6, dword ptr [rbx+0E370h]
000000018037F24C  F3 0F 5E C1                 divss   xmm0, xmm1
000000018037F250  E8 6B 9D FE FF              call    sub_180368FC0
000000018037F255  0F 28 E0                    movaps  xmm4, xmm0
000000018037F258  F3 0F 10 83 20 E3 00 00     movss   xmm0, dword ptr [rbx+0E320h]
000000018037F260  44 0F 2F C0                 comiss  xmm8, xmm0
000000018037F264  72 18                       jb      short loc_18037F27E
000000018037F266  0F 2F 83 80 DF 00 00        comiss  xmm0, dword ptr [rbx+0DF80h]
000000018037F26D  76 0F                       jbe     short loc_18037F27E
000000018037F26F  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
000000018037F277  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018037F27C  EB 08                       jmp     short loc_18037F286
000000018037F27E  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
000000018037F286  0F 2F 3D 43 60 76 00        comiss  xmm7, cs:dword_180AE52D0
000000018037F28D  F3 0F 59 A3 10 E0 00 00     mulss   xmm4, dword ptr [rbx+0E010h]
000000018037F295  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018037F29A  F3 0F 59 A3 40 E3 00 00     mulss   xmm4, dword ptr [rbx+0E340h]
000000018037F2A2  72 03                       jb      short loc_18037F2A7
000000018037F2A4  0F 57 FF                    xorps   xmm7, xmm7
000000018037F2A7  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037F2AB  73 06                       jnb     short loc_18037F2B3
000000018037F2AD  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037F2B1  EB 05                       jmp     short loc_18037F2B8
000000018037F2B3  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037F2B8  F3 0F 11 BB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm7
000000018037F2C0  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018037F2C5  F3 0F 59 A3 00 E3 00 00     mulss   xmm4, dword ptr [rbx+0E300h]
000000018037F2CD  0F 28 D4                    movaps  xmm2, xmm4
000000018037F2D0  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037F2D5  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037F2D9  0F 28 C2                    movaps  xmm0, xmm2
000000018037F2DC  F3 41 0F 59 FC              mulss   xmm7, xmm12
000000018037F2E1  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F2E5  0F 28 DA                    movaps  xmm3, xmm2
000000018037F2E8  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037F2EC  44 0F 28 CA                 movaps  xmm9, xmm2
000000018037F2F0  F3 44 0F 59 8B D0 E4 00 00  mulss   xmm9, dword ptr [rbx+0E4D0h]
000000018037F2F9  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037F2FE  0F 28 CA                    movaps  xmm1, xmm2
000000018037F301  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037F309  F3 44 0F 58 8B C0 E4 00 00  addss   xmm9, dword ptr [rbx+0E4C0h]
000000018037F312  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037F31A  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037F31F  0F 28 C3                    movaps  xmm0, xmm3
000000018037F322  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037F32A  F3 44 0F 58 C9              addss   xmm9, xmm1
000000018037F32F  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F333  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037F338  0F 28 C7                    movaps  xmm0, xmm7
000000018037F33B  0F 54 05 4E 64 76 00        andps   xmm0, cs:xmmword_180AE5790
000000018037F342  0F 57 05 77 64 76 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037F349  F3 44 0F 58 CB              addss   xmm9, xmm3
000000018037F34E  F3 44 0F 58 CC              addss   xmm9, xmm4
000000018037F353  F3 44 0F 59 CE              mulss   xmm9, xmm6
000000018037F358  F3 44 0F 11 8B 80 E0 00 00  movss   dword ptr [rbx+0E080h], xmm9
000000018037F361  E8 5A 9C FE FF              call    sub_180368FC0
000000018037F366  41 0F 2F FE                 comiss  xmm7, xmm14
000000018037F36A  44 0F 28 C0                 movaps  xmm8, xmm0
000000018037F36E  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018037F373  73 06                       jnb     short loc_18037F37B
000000018037F375  41 0F 28 FF                 movaps  xmm7, xmm15
000000018037F379  EB 06                       jmp     short loc_18037F381
000000018037F37B  76 04                       jbe     short loc_18037F381
000000018037F37D  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037F381  F3 44 0F 59 83 10 E0 00 00  mulss   xmm8, dword ptr [rbx+0E010h]
000000018037F38A  F3 0F 59 BB 80 E3 00 00     mulss   xmm7, dword ptr [rbx+0E380h]
000000018037F392  F3 44 0F 59 05 FD B8 60 00  mulss   xmm8, cs:dword_18098AC98
000000018037F39B  F3 44 0F 59 83 50 E3 00 00  mulss   xmm8, dword ptr [rbx+0E350h]
000000018037F3A4  45 0F 2F C7                 comiss  xmm8, xmm15
000000018037F3A8  73 06                       jnb     short loc_18037F3B0
000000018037F3AA  45 0F 28 C7                 movaps  xmm8, xmm15
000000018037F3AE  EB 05                       jmp     short loc_18037F3B5
000000018037F3B0  F3 45 0F 5D C5              minss   xmm8, xmm13
000000018037F3B5  F3 44 0F 59 83 00 E3 00 00  mulss   xmm8, dword ptr [rbx+0E300h]
000000018037F3BE  F3 44 0F 59 8B E0 DF 00 00  mulss   xmm9, dword ptr [rbx+0DFE0h]
000000018037F3C7  F3 0F 10 B3 70 DF 00 00     movss   xmm6, dword ptr [rbx+0DF70h]
000000018037F3CF  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037F3D3  F3 0F 10 AB 90 DF 00 00     movss   xmm5, dword ptr [rbx+0DF90h]
000000018037F3DB  F3 41 0F 59 D0              mulss   xmm2, xmm8
000000018037F3E0  0F 28 C2                    movaps  xmm0, xmm2
000000018037F3E3  0F 28 DA                    movaps  xmm3, xmm2
000000018037F3E6  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F3EA  0F 28 E2                    movaps  xmm4, xmm2
000000018037F3ED  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
000000018037F3F5  0F 28 CA                    movaps  xmm1, xmm2
000000018037F3F8  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037F400  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
000000018037F408  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018037F40D  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037F415  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037F419  0F 28 C3                    movaps  xmm0, xmm3
000000018037F41C  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037F424  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037F428  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F42C  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037F430  F3 0F 10 83 70 E0 00 00     movss   xmm0, dword ptr [rbx+0E070h]
000000018037F438  F3 0F 59 83 D0 DF 00 00     mulss   xmm0, dword ptr [rbx+0DFD0h]
000000018037F440  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037F444  F3 41 0F 58 C1              addss   xmm0, xmm9
000000018037F449  F3 41 0F 58 E0              addss   xmm4, xmm8
000000018037F44E  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037F452  F3 0F 59 A3 F0 DF 00 00     mulss   xmm4, dword ptr [rbx+0DFF0h]
000000018037F45A  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037F45E  F3 0F 11 A3 A0 E0 00 00     movss   dword ptr [rbx+0E0A0h], xmm4
000000018037F466  F3 0F 11 B3 80 DF 00 00     movss   dword ptr [rbx+0DF80h], xmm6
000000018037F46E  F3 0F 11 AB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm5
000000018037F476  F3 0F 58 B3 00 E0 00 00     addss   xmm6, dword ptr [rbx+0E000h]
000000018037F47E  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037F482  76 1B                       jbe     short loc_18037F49F
000000018037F484  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037F489  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037F48D  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037F490  E8 43 00 37 00              call    fmodf
000000018037F495  0F 28 F0                    movaps  xmm6, xmm0
000000018037F498  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037F49D  EB 1F                       jmp     short loc_18037F4BE
000000018037F49F  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037F4A3  73 19                       jnb     short loc_18037F4BE
000000018037F4A5  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037F4AA  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037F4AE  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037F4B1  E8 22 00 37 00              call    fmodf
000000018037F4B6  0F 28 F0                    movaps  xmm6, xmm0
000000018037F4B9  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037F4BE  0F 28 C6                    movaps  xmm0, xmm6
000000018037F4C1  F3 0F 11 B3 70 DF 00 00     movss   dword ptr [rbx+0DF70h], xmm6
000000018037F4C9  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037F4CE  0F 28 FE                    movaps  xmm7, xmm6
000000018037F4D1  F3 0F 59 BB 60 E3 00 00     mulss   xmm7, dword ptr [rbx+0E360h]
000000018037F4D9  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018037F4DE  E8 DD 9A FE FF              call    sub_180368FC0
000000018037F4E3  0F 28 E8                    movaps  xmm5, xmm0
000000018037F4E6  F3 41 0F 59 EB              mulss   xmm5, xmm11
000000018037F4EB  F3 0F 59 AB 10 E0 00 00     mulss   xmm5, dword ptr [rbx+0E010h]
000000018037F4F3  F3 0F 59 AB 30 E3 00 00     mulss   xmm5, dword ptr [rbx+0E330h]
000000018037F4FB  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037F4FF  73 06                       jnb     short loc_18037F507
000000018037F501  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037F505  EB 05                       jmp     short loc_18037F50C
000000018037F507  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037F50C  F3 0F 59 AB 00 E3 00 00     mulss   xmm5, dword ptr [rbx+0E300h]
000000018037F514  0F 28 D5                    movaps  xmm2, xmm5
000000018037F517  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037F51B  0F 28 CA                    movaps  xmm1, xmm2
000000018037F51E  0F 28 C2                    movaps  xmm0, xmm2
000000018037F521  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037F529  0F 28 DA                    movaps  xmm3, xmm2
000000018037F52C  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F530  0F 28 E2                    movaps  xmm4, xmm2
000000018037F533  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
000000018037F53B  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037F543  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037F547  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
000000018037F54F  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037F553  0F 28 C3                    movaps  xmm0, xmm3
000000018037F556  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037F55E  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037F562  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F566  F3 0F 10 8B 20 E0 00 00     movss   xmm1, dword ptr [rbx+0E020h]
000000018037F56E  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037F572  0F 28 C1                    movaps  xmm0, xmm1
000000018037F575  F3 0F 58 C6                 addss   xmm0, xmm6
000000018037F579  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037F57D  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037F581  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037F585  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037F589  F3 0F 11 A3 70 E0 00 00     movss   dword ptr [rbx+0E070h], xmm4
000000018037F591  72 07                       jb      short loc_18037F59A
000000018037F593  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018037F598  EB 05                       jmp     short loc_18037F59F
000000018037F59A  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037F59F  0F 28 F0                    movaps  xmm6, xmm0
000000018037F5A2  73 06                       jnb     short loc_18037F5AA
000000018037F5A4  41 0F 28 F7                 movaps  xmm6, xmm15
000000018037F5A8  EB 06                       jmp     short loc_18037F5B0
000000018037F5AA  76 04                       jbe     short loc_18037F5B0
000000018037F5AC  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037F5B0  F3 44 0F 10 83 70 DF 00 00  movss   xmm8, dword ptr [rbx+0DF70h]
000000018037F5B9  F3 0F 59 B3 70 E3 00 00     mulss   xmm6, dword ptr [rbx+0E370h]
000000018037F5C1  F3 0F 5E C1                 divss   xmm0, xmm1
000000018037F5C5  E8 F6 99 FE FF              call    sub_180368FC0
000000018037F5CA  0F 28 E0                    movaps  xmm4, xmm0
000000018037F5CD  F3 0F 10 83 20 E3 00 00     movss   xmm0, dword ptr [rbx+0E320h]
000000018037F5D5  44 0F 2F C0                 comiss  xmm8, xmm0
000000018037F5D9  72 18                       jb      short loc_18037F5F3
000000018037F5DB  0F 2F 83 80 DF 00 00        comiss  xmm0, dword ptr [rbx+0DF80h]
000000018037F5E2  76 0F                       jbe     short loc_18037F5F3
000000018037F5E4  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
000000018037F5EC  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018037F5F1  EB 08                       jmp     short loc_18037F5FB
000000018037F5F3  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
000000018037F5FB  0F 2F 3D CE 5C 76 00        comiss  xmm7, cs:dword_180AE52D0
000000018037F602  F3 0F 59 A3 10 E0 00 00     mulss   xmm4, dword ptr [rbx+0E010h]
000000018037F60A  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018037F60F  F3 0F 59 A3 40 E3 00 00     mulss   xmm4, dword ptr [rbx+0E340h]
000000018037F617  72 03                       jb      short loc_18037F61C
000000018037F619  0F 57 FF                    xorps   xmm7, xmm7
000000018037F61C  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037F620  73 06                       jnb     short loc_18037F628
000000018037F622  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037F626  EB 05                       jmp     short loc_18037F62D
000000018037F628  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037F62D  F3 0F 11 BB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm7
000000018037F635  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018037F63A  F3 0F 59 A3 00 E3 00 00     mulss   xmm4, dword ptr [rbx+0E300h]
000000018037F642  0F 28 D4                    movaps  xmm2, xmm4
000000018037F645  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037F64A  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037F64E  0F 28 C2                    movaps  xmm0, xmm2
000000018037F651  F3 41 0F 59 FC              mulss   xmm7, xmm12
000000018037F656  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F65A  0F 28 DA                    movaps  xmm3, xmm2
000000018037F65D  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037F661  44 0F 28 CA                 movaps  xmm9, xmm2
000000018037F665  F3 44 0F 59 8B D0 E4 00 00  mulss   xmm9, dword ptr [rbx+0E4D0h]
000000018037F66E  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037F673  0F 28 CA                    movaps  xmm1, xmm2
000000018037F676  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037F67E  F3 44 0F 58 8B C0 E4 00 00  addss   xmm9, dword ptr [rbx+0E4C0h]
000000018037F687  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037F68F  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037F694  0F 28 C3                    movaps  xmm0, xmm3
000000018037F697  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037F69F  F3 44 0F 58 C9              addss   xmm9, xmm1
000000018037F6A4  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F6A8  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037F6AD  0F 28 C7                    movaps  xmm0, xmm7
000000018037F6B0  0F 54 05 D9 60 76 00        andps   xmm0, cs:xmmword_180AE5790
000000018037F6B7  0F 57 05 02 61 76 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037F6BE  F3 44 0F 58 CB              addss   xmm9, xmm3
000000018037F6C3  F3 44 0F 58 CC              addss   xmm9, xmm4
000000018037F6C8  F3 44 0F 59 CE              mulss   xmm9, xmm6
000000018037F6CD  F3 44 0F 11 8B 80 E0 00 00  movss   dword ptr [rbx+0E080h], xmm9
000000018037F6D6  E8 E5 98 FE FF              call    sub_180368FC0
000000018037F6DB  41 0F 2F FE                 comiss  xmm7, xmm14
000000018037F6DF  44 0F 28 C0                 movaps  xmm8, xmm0
000000018037F6E3  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018037F6E8  73 06                       jnb     short loc_18037F6F0
000000018037F6EA  41 0F 28 FF                 movaps  xmm7, xmm15
000000018037F6EE  EB 06                       jmp     short loc_18037F6F6
000000018037F6F0  76 04                       jbe     short loc_18037F6F6
000000018037F6F2  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037F6F6  F3 44 0F 59 83 10 E0 00 00  mulss   xmm8, dword ptr [rbx+0E010h]
000000018037F6FF  F3 0F 59 BB 80 E3 00 00     mulss   xmm7, dword ptr [rbx+0E380h]
000000018037F707  F3 44 0F 59 05 88 B5 60 00  mulss   xmm8, cs:dword_18098AC98
000000018037F710  F3 44 0F 59 83 50 E3 00 00  mulss   xmm8, dword ptr [rbx+0E350h]
000000018037F719  45 0F 2F C7                 comiss  xmm8, xmm15
000000018037F71D  73 06                       jnb     short loc_18037F725
000000018037F71F  45 0F 28 C7                 movaps  xmm8, xmm15
000000018037F723  EB 05                       jmp     short loc_18037F72A
000000018037F725  F3 45 0F 5D C5              minss   xmm8, xmm13
000000018037F72A  F3 44 0F 59 83 00 E3 00 00  mulss   xmm8, dword ptr [rbx+0E300h]
000000018037F733  F3 44 0F 59 8B E0 DF 00 00  mulss   xmm9, dword ptr [rbx+0DFE0h]
000000018037F73C  F3 0F 10 B3 70 DF 00 00     movss   xmm6, dword ptr [rbx+0DF70h]
000000018037F744  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037F748  F3 0F 10 AB 90 DF 00 00     movss   xmm5, dword ptr [rbx+0DF90h]
000000018037F750  F3 41 0F 59 D0              mulss   xmm2, xmm8
000000018037F755  0F 28 C2                    movaps  xmm0, xmm2
000000018037F758  0F 28 DA                    movaps  xmm3, xmm2
000000018037F75B  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F75F  0F 28 E2                    movaps  xmm4, xmm2
000000018037F762  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
000000018037F76A  0F 28 CA                    movaps  xmm1, xmm2
000000018037F76D  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037F775  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
000000018037F77D  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018037F782  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037F78A  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037F78E  0F 28 C3                    movaps  xmm0, xmm3
000000018037F791  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037F799  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037F79D  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F7A1  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037F7A5  F3 0F 10 83 70 E0 00 00     movss   xmm0, dword ptr [rbx+0E070h]
000000018037F7AD  F3 0F 59 83 D0 DF 00 00     mulss   xmm0, dword ptr [rbx+0DFD0h]
000000018037F7B5  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037F7B9  F3 41 0F 58 C1              addss   xmm0, xmm9
000000018037F7BE  F3 41 0F 58 E0              addss   xmm4, xmm8
000000018037F7C3  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037F7C7  F3 0F 59 A3 F0 DF 00 00     mulss   xmm4, dword ptr [rbx+0DFF0h]
000000018037F7CF  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037F7D3  F3 0F 11 A3 20 E1 00 00     movss   dword ptr [rbx+0E120h], xmm4
000000018037F7DB  F3 0F 11 B3 80 DF 00 00     movss   dword ptr [rbx+0DF80h], xmm6
000000018037F7E3  F3 0F 11 AB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm5
000000018037F7EB  F3 0F 58 B3 00 E0 00 00     addss   xmm6, dword ptr [rbx+0E000h]
000000018037F7F3  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037F7F7  76 1B                       jbe     short loc_18037F814
000000018037F7F9  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037F7FE  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037F802  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037F805  E8 CE FC 36 00              call    fmodf
000000018037F80A  0F 28 F0                    movaps  xmm6, xmm0
000000018037F80D  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037F812  EB 1F                       jmp     short loc_18037F833
000000018037F814  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037F818  73 19                       jnb     short loc_18037F833
000000018037F81A  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037F81F  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037F823  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037F826  E8 AD FC 36 00              call    fmodf
000000018037F82B  0F 28 F0                    movaps  xmm6, xmm0
000000018037F82E  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037F833  0F 28 C6                    movaps  xmm0, xmm6
000000018037F836  F3 0F 11 B3 70 DF 00 00     movss   dword ptr [rbx+0DF70h], xmm6
000000018037F83E  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037F843  0F 28 FE                    movaps  xmm7, xmm6
000000018037F846  F3 0F 59 BB 60 E3 00 00     mulss   xmm7, dword ptr [rbx+0E360h]
000000018037F84E  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018037F853  E8 68 97 FE FF              call    sub_180368FC0
000000018037F858  0F 28 E8                    movaps  xmm5, xmm0
000000018037F85B  F3 41 0F 59 EB              mulss   xmm5, xmm11
000000018037F860  F3 0F 59 AB 10 E0 00 00     mulss   xmm5, dword ptr [rbx+0E010h]
000000018037F868  F3 0F 59 AB 30 E3 00 00     mulss   xmm5, dword ptr [rbx+0E330h]
000000018037F870  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037F874  73 06                       jnb     short loc_18037F87C
000000018037F876  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037F87A  EB 05                       jmp     short loc_18037F881
000000018037F87C  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037F881  F3 0F 59 AB 00 E3 00 00     mulss   xmm5, dword ptr [rbx+0E300h]
000000018037F889  0F 28 D5                    movaps  xmm2, xmm5
000000018037F88C  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037F890  0F 28 CA                    movaps  xmm1, xmm2
000000018037F893  0F 28 C2                    movaps  xmm0, xmm2
000000018037F896  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037F89E  0F 28 DA                    movaps  xmm3, xmm2
000000018037F8A1  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F8A5  0F 28 E2                    movaps  xmm4, xmm2
000000018037F8A8  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
000000018037F8B0  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037F8B8  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037F8BC  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
000000018037F8C4  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037F8C8  0F 28 C3                    movaps  xmm0, xmm3
000000018037F8CB  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037F8D3  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037F8D7  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F8DB  F3 0F 10 8B 20 E0 00 00     movss   xmm1, dword ptr [rbx+0E020h]
000000018037F8E3  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037F8E7  0F 28 C1                    movaps  xmm0, xmm1
000000018037F8EA  F3 0F 58 C6                 addss   xmm0, xmm6
000000018037F8EE  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037F8F2  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037F8F6  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037F8FA  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037F8FE  F3 0F 11 A3 70 E0 00 00     movss   dword ptr [rbx+0E070h], xmm4
000000018037F906  72 07                       jb      short loc_18037F90F
000000018037F908  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018037F90D  EB 05                       jmp     short loc_18037F914
000000018037F90F  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037F914  0F 28 F0                    movaps  xmm6, xmm0
000000018037F917  73 06                       jnb     short loc_18037F91F
000000018037F919  41 0F 28 F7                 movaps  xmm6, xmm15
000000018037F91D  EB 06                       jmp     short loc_18037F925
000000018037F91F  76 04                       jbe     short loc_18037F925
000000018037F921  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037F925  F3 44 0F 10 83 70 DF 00 00  movss   xmm8, dword ptr [rbx+0DF70h]
000000018037F92E  F3 0F 59 B3 70 E3 00 00     mulss   xmm6, dword ptr [rbx+0E370h]
000000018037F936  F3 0F 5E C1                 divss   xmm0, xmm1
000000018037F93A  E8 81 96 FE FF              call    sub_180368FC0
000000018037F93F  0F 28 E0                    movaps  xmm4, xmm0
000000018037F942  F3 0F 10 83 20 E3 00 00     movss   xmm0, dword ptr [rbx+0E320h]
000000018037F94A  44 0F 2F C0                 comiss  xmm8, xmm0
000000018037F94E  72 18                       jb      short loc_18037F968
000000018037F950  0F 2F 83 80 DF 00 00        comiss  xmm0, dword ptr [rbx+0DF80h]
000000018037F957  76 0F                       jbe     short loc_18037F968
000000018037F959  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
000000018037F961  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018037F966  EB 08                       jmp     short loc_18037F970
000000018037F968  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
000000018037F970  0F 2F 3D 59 59 76 00        comiss  xmm7, cs:dword_180AE52D0
000000018037F977  F3 0F 59 A3 10 E0 00 00     mulss   xmm4, dword ptr [rbx+0E010h]
000000018037F97F  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018037F984  F3 0F 59 A3 40 E3 00 00     mulss   xmm4, dword ptr [rbx+0E340h]
000000018037F98C  72 03                       jb      short loc_18037F991
000000018037F98E  0F 57 FF                    xorps   xmm7, xmm7
000000018037F991  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037F995  73 06                       jnb     short loc_18037F99D
000000018037F997  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037F99B  EB 05                       jmp     short loc_18037F9A2
000000018037F99D  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037F9A2  F3 0F 11 BB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm7
000000018037F9AA  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018037F9AF  F3 0F 59 A3 00 E3 00 00     mulss   xmm4, dword ptr [rbx+0E300h]
000000018037F9B7  0F 28 D4                    movaps  xmm2, xmm4
000000018037F9BA  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037F9BF  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037F9C3  0F 28 C2                    movaps  xmm0, xmm2
000000018037F9C6  F3 41 0F 59 FC              mulss   xmm7, xmm12
000000018037F9CB  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037F9CF  0F 28 DA                    movaps  xmm3, xmm2
000000018037F9D2  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037F9D6  44 0F 28 CA                 movaps  xmm9, xmm2
000000018037F9DA  F3 44 0F 59 8B D0 E4 00 00  mulss   xmm9, dword ptr [rbx+0E4D0h]
000000018037F9E3  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037F9E8  0F 28 CA                    movaps  xmm1, xmm2
000000018037F9EB  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037F9F3  F3 44 0F 58 8B C0 E4 00 00  addss   xmm9, dword ptr [rbx+0E4C0h]
000000018037F9FC  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037FA04  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037FA09  0F 28 C3                    movaps  xmm0, xmm3
000000018037FA0C  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037FA14  F3 44 0F 58 C9              addss   xmm9, xmm1
000000018037FA19  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037FA1D  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037FA22  0F 28 C7                    movaps  xmm0, xmm7
000000018037FA25  0F 54 05 64 5D 76 00        andps   xmm0, cs:xmmword_180AE5790
000000018037FA2C  0F 57 05 8D 5D 76 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037FA33  F3 44 0F 58 CB              addss   xmm9, xmm3
000000018037FA38  F3 44 0F 58 CC              addss   xmm9, xmm4
000000018037FA3D  F3 44 0F 59 CE              mulss   xmm9, xmm6
000000018037FA42  F3 44 0F 11 8B 80 E0 00 00  movss   dword ptr [rbx+0E080h], xmm9
000000018037FA4B  E8 70 95 FE FF              call    sub_180368FC0
000000018037FA50  41 0F 2F FE                 comiss  xmm7, xmm14
000000018037FA54  44 0F 28 C0                 movaps  xmm8, xmm0
000000018037FA58  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018037FA5D  73 06                       jnb     short loc_18037FA65
000000018037FA5F  41 0F 28 FF                 movaps  xmm7, xmm15
000000018037FA63  EB 06                       jmp     short loc_18037FA6B
000000018037FA65  76 04                       jbe     short loc_18037FA6B
000000018037FA67  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037FA6B  F3 44 0F 59 83 10 E0 00 00  mulss   xmm8, dword ptr [rbx+0E010h]
000000018037FA74  F3 0F 59 BB 80 E3 00 00     mulss   xmm7, dword ptr [rbx+0E380h]
000000018037FA7C  F3 44 0F 59 05 13 B2 60 00  mulss   xmm8, cs:dword_18098AC98
000000018037FA85  F3 44 0F 59 83 50 E3 00 00  mulss   xmm8, dword ptr [rbx+0E350h]
000000018037FA8E  45 0F 2F C7                 comiss  xmm8, xmm15
000000018037FA92  73 06                       jnb     short loc_18037FA9A
000000018037FA94  45 0F 28 C7                 movaps  xmm8, xmm15
000000018037FA98  EB 05                       jmp     short loc_18037FA9F
000000018037FA9A  F3 45 0F 5D C5              minss   xmm8, xmm13
000000018037FA9F  F3 44 0F 59 83 00 E3 00 00  mulss   xmm8, dword ptr [rbx+0E300h]
000000018037FAA8  F3 44 0F 59 8B E0 DF 00 00  mulss   xmm9, dword ptr [rbx+0DFE0h]
000000018037FAB1  F3 0F 10 B3 70 DF 00 00     movss   xmm6, dword ptr [rbx+0DF70h]
000000018037FAB9  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037FABD  F3 0F 10 AB 90 DF 00 00     movss   xmm5, dword ptr [rbx+0DF90h]
000000018037FAC5  F3 41 0F 59 D0              mulss   xmm2, xmm8
000000018037FACA  0F 28 C2                    movaps  xmm0, xmm2
000000018037FACD  0F 28 DA                    movaps  xmm3, xmm2
000000018037FAD0  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037FAD4  0F 28 E2                    movaps  xmm4, xmm2
000000018037FAD7  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
000000018037FADF  0F 28 CA                    movaps  xmm1, xmm2
000000018037FAE2  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037FAEA  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
000000018037FAF2  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018037FAF7  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037FAFF  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037FB03  0F 28 C3                    movaps  xmm0, xmm3
000000018037FB06  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037FB0E  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037FB12  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037FB16  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037FB1A  F3 0F 10 83 70 E0 00 00     movss   xmm0, dword ptr [rbx+0E070h]
000000018037FB22  F3 0F 59 83 D0 DF 00 00     mulss   xmm0, dword ptr [rbx+0DFD0h]
000000018037FB2A  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037FB2E  F3 41 0F 58 C1              addss   xmm0, xmm9
000000018037FB33  F3 41 0F 58 E0              addss   xmm4, xmm8
000000018037FB38  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037FB3C  F3 0F 59 A3 F0 DF 00 00     mulss   xmm4, dword ptr [rbx+0DFF0h]
000000018037FB44  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037FB48  F3 0F 11 A3 A0 E1 00 00     movss   dword ptr [rbx+0E1A0h], xmm4
000000018037FB50  F3 0F 11 B3 80 DF 00 00     movss   dword ptr [rbx+0DF80h], xmm6
000000018037FB58  F3 0F 11 AB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm5
000000018037FB60  F3 0F 58 B3 00 E0 00 00     addss   xmm6, dword ptr [rbx+0E000h]
000000018037FB68  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037FB6C  76 1B                       jbe     short loc_18037FB89
000000018037FB6E  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037FB73  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037FB77  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037FB7A  E8 59 F9 36 00              call    fmodf
000000018037FB7F  0F 28 F0                    movaps  xmm6, xmm0
000000018037FB82  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037FB87  EB 1F                       jmp     short loc_18037FBA8
000000018037FB89  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037FB8D  73 19                       jnb     short loc_18037FBA8
000000018037FB8F  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037FB94  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037FB98  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037FB9B  E8 38 F9 36 00              call    fmodf
000000018037FBA0  0F 28 F0                    movaps  xmm6, xmm0
000000018037FBA3  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037FBA8  0F 28 C6                    movaps  xmm0, xmm6
000000018037FBAB  F3 0F 11 B3 70 DF 00 00     movss   dword ptr [rbx+0DF70h], xmm6
000000018037FBB3  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037FBB8  0F 28 FE                    movaps  xmm7, xmm6
000000018037FBBB  F3 0F 59 BB 60 E3 00 00     mulss   xmm7, dword ptr [rbx+0E360h]
000000018037FBC3  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018037FBC8  E8 F3 93 FE FF              call    sub_180368FC0
000000018037FBCD  0F 28 E8                    movaps  xmm5, xmm0
000000018037FBD0  F3 41 0F 59 EB              mulss   xmm5, xmm11
000000018037FBD5  F3 0F 59 AB 10 E0 00 00     mulss   xmm5, dword ptr [rbx+0E010h]
000000018037FBDD  F3 0F 59 AB 30 E3 00 00     mulss   xmm5, dword ptr [rbx+0E330h]
000000018037FBE5  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037FBE9  73 06                       jnb     short loc_18037FBF1
000000018037FBEB  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037FBEF  EB 05                       jmp     short loc_18037FBF6
000000018037FBF1  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037FBF6  F3 0F 59 AB 00 E3 00 00     mulss   xmm5, dword ptr [rbx+0E300h]
000000018037FBFE  0F 28 D5                    movaps  xmm2, xmm5
000000018037FC01  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037FC05  0F 28 CA                    movaps  xmm1, xmm2
000000018037FC08  0F 28 C2                    movaps  xmm0, xmm2
000000018037FC0B  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037FC13  0F 28 DA                    movaps  xmm3, xmm2
000000018037FC16  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037FC1A  0F 28 E2                    movaps  xmm4, xmm2
000000018037FC1D  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
000000018037FC25  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037FC2D  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037FC31  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
000000018037FC39  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037FC3D  0F 28 C3                    movaps  xmm0, xmm3
000000018037FC40  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037FC48  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037FC4C  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037FC50  F3 0F 10 8B 20 E0 00 00     movss   xmm1, dword ptr [rbx+0E020h]
000000018037FC58  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037FC5C  0F 28 C1                    movaps  xmm0, xmm1
000000018037FC5F  F3 0F 58 C6                 addss   xmm0, xmm6
000000018037FC63  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037FC67  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037FC6B  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037FC6F  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037FC73  F3 0F 11 A3 70 E0 00 00     movss   dword ptr [rbx+0E070h], xmm4
000000018037FC7B  72 07                       jb      short loc_18037FC84
000000018037FC7D  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018037FC82  EB 05                       jmp     short loc_18037FC89
000000018037FC84  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037FC89  0F 28 F0                    movaps  xmm6, xmm0
000000018037FC8C  73 06                       jnb     short loc_18037FC94
000000018037FC8E  41 0F 28 F7                 movaps  xmm6, xmm15
000000018037FC92  EB 06                       jmp     short loc_18037FC9A
000000018037FC94  76 04                       jbe     short loc_18037FC9A
000000018037FC96  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037FC9A  F3 44 0F 10 83 70 DF 00 00  movss   xmm8, dword ptr [rbx+0DF70h]
000000018037FCA3  F3 0F 59 B3 70 E3 00 00     mulss   xmm6, dword ptr [rbx+0E370h]
000000018037FCAB  F3 0F 5E C1                 divss   xmm0, xmm1
000000018037FCAF  E8 0C 93 FE FF              call    sub_180368FC0
000000018037FCB4  0F 28 E0                    movaps  xmm4, xmm0
000000018037FCB7  F3 0F 10 83 20 E3 00 00     movss   xmm0, dword ptr [rbx+0E320h]
000000018037FCBF  44 0F 2F C0                 comiss  xmm8, xmm0
000000018037FCC3  72 18                       jb      short loc_18037FCDD
000000018037FCC5  0F 2F 83 80 DF 00 00        comiss  xmm0, dword ptr [rbx+0DF80h]
000000018037FCCC  76 0F                       jbe     short loc_18037FCDD
000000018037FCCE  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
000000018037FCD6  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018037FCDB  EB 08                       jmp     short loc_18037FCE5
000000018037FCDD  F3 0F 10 BB 90 DF 00 00     movss   xmm7, dword ptr [rbx+0DF90h]
000000018037FCE5  0F 2F 3D E4 55 76 00        comiss  xmm7, cs:dword_180AE52D0
000000018037FCEC  F3 0F 59 A3 10 E0 00 00     mulss   xmm4, dword ptr [rbx+0E010h]
000000018037FCF4  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018037FCF9  F3 0F 59 A3 40 E3 00 00     mulss   xmm4, dword ptr [rbx+0E340h]
000000018037FD01  72 03                       jb      short loc_18037FD06
000000018037FD03  0F 57 FF                    xorps   xmm7, xmm7
000000018037FD06  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037FD0A  73 06                       jnb     short loc_18037FD12
000000018037FD0C  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037FD10  EB 05                       jmp     short loc_18037FD17
000000018037FD12  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037FD17  F3 0F 11 BB 90 DF 00 00     movss   dword ptr [rbx+0DF90h], xmm7
000000018037FD1F  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018037FD24  F3 0F 59 A3 00 E3 00 00     mulss   xmm4, dword ptr [rbx+0E300h]
000000018037FD2C  0F 28 D4                    movaps  xmm2, xmm4
000000018037FD2F  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037FD34  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037FD38  0F 28 C2                    movaps  xmm0, xmm2
000000018037FD3B  F3 41 0F 59 FC              mulss   xmm7, xmm12
000000018037FD40  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037FD44  0F 28 DA                    movaps  xmm3, xmm2
000000018037FD47  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037FD4B  44 0F 28 C2                 movaps  xmm8, xmm2
000000018037FD4F  F3 44 0F 59 83 D0 E4 00 00  mulss   xmm8, dword ptr [rbx+0E4D0h]
000000018037FD58  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037FD5D  0F 28 CA                    movaps  xmm1, xmm2
000000018037FD60  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037FD68  F3 44 0F 58 83 C0 E4 00 00  addss   xmm8, dword ptr [rbx+0E4C0h]
000000018037FD71  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037FD79  F3 44 0F 59 C0              mulss   xmm8, xmm0
000000018037FD7E  0F 28 C3                    movaps  xmm0, xmm3
000000018037FD81  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037FD89  F3 44 0F 58 C1              addss   xmm8, xmm1
000000018037FD8E  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037FD92  F3 44 0F 59 C0              mulss   xmm8, xmm0
000000018037FD97  0F 28 C7                    movaps  xmm0, xmm7
000000018037FD9A  0F 54 05 EF 59 76 00        andps   xmm0, cs:xmmword_180AE5790
000000018037FDA1  0F 57 05 18 5A 76 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037FDA8  F3 44 0F 58 C3              addss   xmm8, xmm3
000000018037FDAD  F3 44 0F 58 C4              addss   xmm8, xmm4
000000018037FDB2  F3 44 0F 59 C6              mulss   xmm8, xmm6
000000018037FDB7  F3 44 0F 11 83 80 E0 00 00  movss   dword ptr [rbx+0E080h], xmm8
000000018037FDC0  E8 FB 91 FE FF              call    sub_180368FC0
000000018037FDC5  41 0F 2F FE                 comiss  xmm7, xmm14
000000018037FDC9  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037FDCE  73 06                       jnb     short loc_18037FDD6
000000018037FDD0  41 0F 28 FF                 movaps  xmm7, xmm15
000000018037FDD4  EB 06                       jmp     short loc_18037FDDC
000000018037FDD6  76 04                       jbe     short loc_18037FDDC
000000018037FDD8  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037FDDC  F3 0F 59 83 10 E0 00 00     mulss   xmm0, dword ptr [rbx+0E010h]
000000018037FDE4  F3 0F 59 BB 80 E3 00 00     mulss   xmm7, dword ptr [rbx+0E380h]
000000018037FDEC  F3 0F 59 05 A4 AE 60 00     mulss   xmm0, cs:dword_18098AC98
000000018037FDF4  F3 0F 59 83 50 E3 00 00     mulss   xmm0, dword ptr [rbx+0E350h]
000000018037FDFC  41 0F 2F C7                 comiss  xmm0, xmm15
000000018037FE00  72 09                       jb      short loc_18037FE0B
000000018037FE02  44 0F 28 F8                 movaps  xmm15, xmm0
000000018037FE06  F3 45 0F 5D FD              minss   xmm15, xmm13
000000018037FE0B  F3 44 0F 59 BB 00 E3 00 00  mulss   xmm15, dword ptr [rbx+0E300h]
000000018037FE14  F3 44 0F 59 83 E0 DF 00 00  mulss   xmm8, dword ptr [rbx+0DFE0h]
000000018037FE1D  F3 0F 10 AB 70 DF 00 00     movss   xmm5, dword ptr [rbx+0DF70h]
000000018037FE25  41 0F 28 D7                 movaps  xmm2, xmm15
000000018037FE29  F3 0F 10 B3 90 DF 00 00     movss   xmm6, dword ptr [rbx+0DF90h]
000000018037FE31  F3 41 0F 59 D7              mulss   xmm2, xmm15
000000018037FE36  0F 28 CA                    movaps  xmm1, xmm2
000000018037FE39  0F 28 C2                    movaps  xmm0, xmm2
000000018037FE3C  F3 0F 59 8B B0 E4 00 00     mulss   xmm1, dword ptr [rbx+0E4B0h]
000000018037FE44  0F 28 DA                    movaps  xmm3, xmm2
000000018037FE47  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037FE4B  0F 28 E2                    movaps  xmm4, xmm2
000000018037FE4E  F3 0F 58 8B A0 E4 00 00     addss   xmm1, dword ptr [rbx+0E4A0h]
000000018037FE56  F3 0F 59 A3 D0 E4 00 00     mulss   xmm4, dword ptr [rbx+0E4D0h]
000000018037FE5E  F3 41 0F 59 DF              mulss   xmm3, xmm15
000000018037FE63  F3 0F 58 A3 C0 E4 00 00     addss   xmm4, dword ptr [rbx+0E4C0h]
000000018037FE6B  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037FE6F  0F 28 C3                    movaps  xmm0, xmm3
000000018037FE72  F3 0F 59 9B 90 E4 00 00     mulss   xmm3, dword ptr [rbx+0E490h]
000000018037FE7A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037FE7E  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037FE82  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037FE86  F3 0F 10 83 70 E0 00 00     movss   xmm0, dword ptr [rbx+0E070h]
000000018037FE8E  F3 0F 59 83 D0 DF 00 00     mulss   xmm0, dword ptr [rbx+0DFD0h]
000000018037FE96  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037FE9A  F3 41 0F 58 C0              addss   xmm0, xmm8
000000018037FE9F  F3 41 0F 58 E7              addss   xmm4, xmm15
000000018037FEA4  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037FEA8  F3 0F 59 A3 F0 DF 00 00     mulss   xmm4, dword ptr [rbx+0DFF0h]
000000018037FEB0  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037FEB4  F3 0F 11 A3 20 E2 00 00     movss   dword ptr [rbx+0E220h], xmm4
000000018037FEBC  F3 0F 10 93 90 E2 00 00     movss   xmm2, dword ptr [rbx+0E290h]
000000018037FEC4  F3 0F 11 AB 50 E0 00 00     movss   dword ptr [rbx+0E050h], xmm5
000000018037FECC  F3 0F 11 B3 30 E0 00 00     movss   dword ptr [rbx+0E030h], xmm6
000000018037FED4  F3 0F 10 83 A0 E1 00 00     movss   xmm0, dword ptr [rbx+0E1A0h]
000000018037FEDC  F3 0F 58 83 90 E1 00 00     addss   xmm0, dword ptr [rbx+0E190h]
000000018037FEE4  F3 0F 10 8B 20 E2 00 00     movss   xmm1, dword ptr [rbx+0E220h]
000000018037FEEC  F3 0F 58 8B 10 E1 00 00     addss   xmm1, dword ptr [rbx+0E110h]
000000018037FEF4  F3 0F 10 AB 10 E2 00 00     movss   xmm5, dword ptr [rbx+0E210h]
000000018037FEFC  F3 0F 58 AB 20 E1 00 00     addss   xmm5, dword ptr [rbx+0E120h]
000000018037FF04  F3 0F 59 83 B0 E3 00 00     mulss   xmm0, dword ptr [rbx+0E3B0h]
000000018037FF0C  F3 0F 59 8B C0 E3 00 00     mulss   xmm1, dword ptr [rbx+0E3C0h]
000000018037FF14  F3 0F 59 AB A0 E3 00 00     mulss   xmm5, dword ptr [rbx+0E3A0h]
000000018037FF1C  F3 0F 58 93 A0 E0 00 00     addss   xmm2, dword ptr [rbx+0E0A0h]
000000018037FF24  F3 0F 59 93 90 E3 00 00     mulss   xmm2, dword ptr [rbx+0E390h]
000000018037FF2C  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037FF30  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037FF34  F3 0F 10 83 80 E2 00 00     movss   xmm0, dword ptr [rbx+0E280h]
000000018037FF3C  F3 0F 58 83 B0 E0 00 00     addss   xmm0, dword ptr [rbx+0E0B0h]
000000018037FF44  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037FF48  F3 0F 10 8B 00 E2 00 00     movss   xmm1, dword ptr [rbx+0E200h]
000000018037FF50  F3 0F 59 83 D0 E3 00 00     mulss   xmm0, dword ptr [rbx+0E3D0h]
000000018037FF58  F3 0F 58 8B 30 E1 00 00     addss   xmm1, dword ptr [rbx+0E130h]
000000018037FF60  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037FF64  F3 0F 10 83 B0 E1 00 00     movss   xmm0, dword ptr [rbx+0E1B0h]
000000018037FF6C  F3 0F 58 83 80 E1 00 00     addss   xmm0, dword ptr [rbx+0E180h]
000000018037FF74  F3 0F 59 8B E0 E3 00 00     mulss   xmm1, dword ptr [rbx+0E3E0h]
000000018037FF7C  F3 0F 59 83 F0 E3 00 00     mulss   xmm0, dword ptr [rbx+0E3F0h]
000000018037FF84  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037FF88  F3 0F 10 8B 30 E2 00 00     movss   xmm1, dword ptr [rbx+0E230h]
000000018037FF90  F3 0F 58 8B 00 E1 00 00     addss   xmm1, dword ptr [rbx+0E100h]
000000018037FF98  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037FF9C  F3 0F 10 83 70 E2 00 00     movss   xmm0, dword ptr [rbx+0E270h]
000000018037FFA4  F3 0F 59 8B 00 E4 00 00     mulss   xmm1, dword ptr [rbx+0E400h]
000000018037FFAC  F3 0F 58 83 C0 E0 00 00     addss   xmm0, dword ptr [rbx+0E0C0h]
000000018037FFB4  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037FFB8  F3 0F 10 8B 40 E1 00 00     movss   xmm1, dword ptr [rbx+0E140h]
000000018037FFC0  F3 0F 58 8B F0 E1 00 00     addss   xmm1, dword ptr [rbx+0E1F0h]
000000018037FFC8  F3 0F 59 83 10 E4 00 00     mulss   xmm0, dword ptr [rbx+0E410h]
000000018037FFD0  F3 0F 59 8B 20 E4 00 00     mulss   xmm1, dword ptr [rbx+0E420h]
000000018037FFD8  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037FFDC  F3 0F 10 83 C0 E1 00 00     movss   xmm0, dword ptr [rbx+0E1C0h]
000000018037FFE4  F3 0F 58 83 70 E1 00 00     addss   xmm0, dword ptr [rbx+0E170h]
000000018037FFEC  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037FFF0  F3 0F 10 8B F0 E0 00 00     movss   xmm1, dword ptr [rbx+0E0F0h]
000000018037FFF8  F3 0F 59 83 30 E4 00 00     mulss   xmm0, dword ptr [rbx+0E430h]
0000000180380000  F3 0F 58 8B 40 E2 00 00     addss   xmm1, dword ptr [rbx+0E240h]
0000000180380008  F3 0F 58 E8                 addss   xmm5, xmm0
000000018038000C  F3 0F 10 83 60 E2 00 00     movss   xmm0, dword ptr [rbx+0E260h]
0000000180380014  F3 0F 59 8B 40 E4 00 00     mulss   xmm1, dword ptr [rbx+0E440h]
000000018038001C  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180380020  F3 0F 58 83 D0 E0 00 00     addss   xmm0, dword ptr [rbx+0E0D0h]
0000000180380028  F3 0F 10 93 C0 E2 00 00     movss   xmm2, dword ptr [rbx+0E2C0h]
0000000180380030  F3 0F 10 8B E0 E1 00 00     movss   xmm1, dword ptr [rbx+0E1E0h]
0000000180380038  0F 28 E2                    movaps  xmm4, xmm2
000000018038003B  F3 0F 59 A3 C0 E5 00 00     mulss   xmm4, dword ptr [rbx+0E5C0h]
0000000180380043  F3 0F 59 83 50 E4 00 00     mulss   xmm0, dword ptr [rbx+0E450h]
000000018038004B  F3 0F 58 A3 D0 E2 00 00     addss   xmm4, dword ptr [rbx+0E2D0h]
0000000180380053  F3 0F 58 8B 50 E1 00 00     addss   xmm1, dword ptr [rbx+0E150h]
000000018038005B  F3 0F 58 E8                 addss   xmm5, xmm0
000000018038005F  F3 0F 10 83 D0 E1 00 00     movss   xmm0, dword ptr [rbx+0E1D0h]
0000000180380067  F3 0F 58 83 60 E1 00 00     addss   xmm0, dword ptr [rbx+0E160h]
000000018038006F  F3 0F 59 8B 60 E4 00 00     mulss   xmm1, dword ptr [rbx+0E460h]
0000000180380077  F3 0F 59 83 70 E4 00 00     mulss   xmm0, dword ptr [rbx+0E470h]
000000018038007F  F3 0F 58 E9                 addss   xmm5, xmm1
0000000180380083  F3 0F 10 8B 50 E2 00 00     movss   xmm1, dword ptr [rbx+0E250h]
000000018038008B  F3 0F 58 8B E0 E0 00 00     addss   xmm1, dword ptr [rbx+0E0E0h]
0000000180380093  F3 0F 58 E8                 addss   xmm5, xmm0
0000000180380097  0F 28 C2                    movaps  xmm0, xmm2
000000018038009A  F3 0F 59 8B 80 E4 00 00     mulss   xmm1, dword ptr [rbx+0E480h]
00000001803800A2  F3 0F 11 A3 C0 E2 00 00     movss   dword ptr [rbx+0E2C0h], xmm4
00000001803800AA  F3 0F 59 83 D0 E5 00 00     mulss   xmm0, dword ptr [rbx+0E5D0h]
00000001803800B2  F3 0F 58 E9                 addss   xmm5, xmm1
00000001803800B6  F3 0F 58 C4                 addss   xmm0, xmm4
00000001803800BA  0F 28 DD                    movaps  xmm3, xmm5
00000001803800BD  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803800C1  0F 28 C3                    movaps  xmm0, xmm3
00000001803800C4  F3 0F 59 83 C0 E5 00 00     mulss   xmm0, dword ptr [rbx+0E5C0h]
00000001803800CC  F3 0F 58 C2                 addss   xmm0, xmm2
00000001803800D0  F3 0F 11 83 B0 E2 00 00     movss   dword ptr [rbx+0E2B0h], xmm0
00000001803800D8  F3 0F 10 93 10 E6 00 00     movss   xmm2, dword ptr [rbx+0E610h]
00000001803800E0  F3 0F 59 9B A0 E2 00 00     mulss   xmm3, dword ptr [rbx+0E2A0h]
00000001803800E8  F3 0F 5C E3                 subss   xmm4, xmm3
00000001803800EC  F3 0F 59 E2                 mulss   xmm4, xmm2
00000001803800F0  F3 0F 59 D5                 mulss   xmm2, xmm5
00000001803800F4  F3 0F 5C E2                 subss   xmm4, xmm2
00000001803800F8  F3 0F 58 E5                 addss   xmm4, xmm5
00000001803800FC  F3 0F 11 A3 90 E0 00 00     movss   dword ptr [rbx+0E090h], xmm4
0000000180380104  F3 0F 11 A3 10 DB 00 00     movss   dword ptr [rbx+0DB10h], xmm4
000000018038010C  44 0F 2E AB 20 8D 01 00     ucomiss xmm13, dword ptr [rbx+18D20h]
0000000180380114  75 1B                       jnz     short loc_180380131
0000000180380116  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
000000018038011F  F3 0F 11 83 90 CE 00 00     movss   dword ptr [rbx+0CE90h], xmm0
0000000180380127  C7 83 20 8D 01 00 00 00 00 00  mov     dword ptr [rbx+18D20h], 0
0000000180380131  8B 83 00 F7 00 00           mov     eax, [rbx+0F700h]
0000000180380137  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
000000018038013F  48 8B 0F                    mov     rcx, [rdi]
0000000180380142  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
0000000180380147  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
000000018038014C  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
0000000180380151  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
0000000180380156  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
000000018038015B  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
0000000180380160  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
0000000180380165  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
000000018038016A  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
0000000180380170  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
0000000180380176  89 01                       mov     [rcx], eax
0000000180380178  8B 83 00 F7 00 00           mov     eax, [rbx+0F700h]
000000018038017E  48 8B 4F 08                 mov     rcx, [rdi+8]
0000000180380182  49 8B 5B 18                 mov     rbx, [r11+18h]
0000000180380186  89 01                       mov     [rcx], eax
0000000180380188  49 8B E3                    mov     rsp, r11
000000018038018B  5F                          pop     rdi
000000018038018C  C3                          retn
