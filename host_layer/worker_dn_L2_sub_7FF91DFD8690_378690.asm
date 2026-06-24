; sub_7FF91DFD8690 @ rva 0x378690

00007FF91DFD8690  48 8B C4                    mov     rax, rsp
00007FF91DFD8693  48 89 58 10                 mov     [rax+10h], rbx
00007FF91DFD8697  57                          push    rdi
00007FF91DFD8698  48 81 EC C0 00 00 00        sub     rsp, 0C0h
00007FF91DFD869F  F3 0F 10 A1 80 A5 00 00     movss   xmm4, dword ptr [rcx+0A580h]
00007FF91DFD86A7  48 8B FA                    mov     rdi, rdx
00007FF91DFD86AA  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
00007FF91DFD86AE  48 8B D9                    mov     rbx, rcx
00007FF91DFD86B1  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
00007FF91DFD86B5  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00007FF91DFD86BA  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00007FF91DFD86BF  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00007FF91DFD86C4  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00007FF91DFD86C9  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00007FF91DFD86CE  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00007FF91DFD86D4  F3 44 0F 10 2D D7 C9 76 00  movss   xmm13, cs:dword_7FF91E7450B4
00007FF91DFD86DD  44 0F 2E A9 00 8D 01 00     ucomiss xmm13, dword ptr [rcx+18D00h]
00007FF91DFD86E5  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00007FF91DFD86EB  45 0F 57 F6                 xorps   xmm14, xmm14
00007FF91DFD86EF  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
00007FF91DFD86F9  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00007FF91DFD86FF  75 16                       jnz     short loc_7FF91DFD8717
00007FF91DFD8701  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
00007FF91DFD870A  0F 57 E4                    xorps   xmm4, xmm4
00007FF91DFD870D  C7 81 80 A5 00 00 00 00 00 00  mov     dword ptr [rcx+0A580h], 0
00007FF91DFD8717  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
00007FF91DFD871F  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
00007FF91DFD8727  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
00007FF91DFD872F  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
00007FF91DFD8737  F3 0F 59 05 85 26 61 00     mulss   xmm0, cs:dword_7FF91E5EADC4
00007FF91DFD873F  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
00007FF91DFD8747  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
00007FF91DFD874F  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFD8753  85 D2                       test    edx, edx
00007FF91DFD8755  75 07                       jnz     short loc_7FF91DFD875E
00007FF91DFD8757  BA 01 00 00 00              mov     edx, 1
00007FF91DFD875C  EB 24                       jmp     short loc_7FF91DFD8782
00007FF91DFD875E  8B C2                       mov     eax, edx
00007FF91DFD8760  25 00 00 20 00              and     eax, 200000h
00007FF91DFD8765  0F BA E2 17                 bt      edx, 17h
00007FF91DFD8769  73 08                       jnb     short loc_7FF91DFD8773
00007FF91DFD876B  85 C0                       test    eax, eax
00007FF91DFD876D  75 0C                       jnz     short loc_7FF91DFD877B
00007FF91DFD876F  03 D2                       add     edx, edx
00007FF91DFD8771  EB 0F                       jmp     short loc_7FF91DFD8782
00007FF91DFD8773  85 C0                       test    eax, eax
00007FF91DFD8775  74 04                       jz      short loc_7FF91DFD877B
00007FF91DFD8777  03 D2                       add     edx, edx
00007FF91DFD8779  EB 07                       jmp     short loc_7FF91DFD8782
00007FF91DFD877B  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
00007FF91DFD8782  F3 0F 10 9B 10 A5 00 00     movss   xmm3, dword ptr [rbx+0A510h]
00007FF91DFD878A  8B C2                       mov     eax, edx
00007FF91DFD878C  F3 0F 10 B3 F0 A4 00 00     movss   xmm6, dword ptr [rbx+0A4F0h]
00007FF91DFD8794  25 FF FF FF 00              and     eax, 0FFFFFFh
00007FF91DFD8799  F3 44 0F 10 83 B0 A5 00 00  movss   xmm8, dword ptr [rbx+0A5B0h]
00007FF91DFD87A2  8B CA                       mov     ecx, edx
00007FF91DFD87A4  F3 0F 10 BB C0 A5 00 00     movss   xmm7, dword ptr [rbx+0A5C0h]
00007FF91DFD87AC  81 CA 00 00 00 FF           or      edx, 0FF000000h
00007FF91DFD87B2  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD87B6  81 E1 00 00 00 01           and     ecx, 1000000h
00007FF91DFD87BC  C7 83 F0 A5 00 00 00 00 00 00  mov     dword ptr [rbx+0A5F0h], 0
00007FF91DFD87C6  F3 0F 11 9B 20 A5 00 00     movss   dword ptr [rbx+0A520h], xmm3
00007FF91DFD87CE  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFD87D2  0F 44 D0                    cmovz   edx, eax
00007FF91DFD87D5  F3 0F 11 B3 00 A5 00 00     movss   dword ptr [rbx+0A500h], xmm6
00007FF91DFD87DD  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
00007FF91DFD87E3  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
00007FF91DFD87E9  8B 83 30 A6 00 00           mov     eax, [rbx+0A630h]
00007FF91DFD87EF  66 0F 6E C2                 movd    xmm0, edx
00007FF91DFD87F3  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFD87F6  89 83 40 A6 00 00           mov     [rbx+0A640h], eax
00007FF91DFD87FC  F3 0F 11 A3 A0 A5 00 00     movss   dword ptr [rbx+0A5A0h], xmm4
00007FF91DFD8804  F3 0F 59 05 64 24 61 00     mulss   xmm0, cs:dword_7FF91E5EAC70
00007FF91DFD880C  F3 44 0F 11 83 D0 A5 00 00  movss   dword ptr [rbx+0A5D0h], xmm8
00007FF91DFD8815  F3 0F 11 BB E0 A5 00 00     movss   dword ptr [rbx+0A5E0h], xmm7
00007FF91DFD881D  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
00007FF91DFD8825  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
00007FF91DFD882D  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
00007FF91DFD8835  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD8839  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
00007FF91DFD8841  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFD8845  F3 0F 10 93 50 A5 00 00     movss   xmm2, dword ptr [rbx+0A550h]
00007FF91DFD884D  F3 0F 11 93 60 A5 00 00     movss   dword ptr [rbx+0A560h], xmm2
00007FF91DFD8855  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD8859  F3 0F 10 83 30 A5 00 00     movss   xmm0, dword ptr [rbx+0A530h]
00007FF91DFD8861  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD8865  F3 0F 11 83 40 A5 00 00     movss   dword ptr [rbx+0A540h], xmm0
00007FF91DFD886D  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFD8871  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD8874  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
00007FF91DFD887C  F3 0F 10 8B 70 A5 00 00     movss   xmm1, dword ptr [rbx+0A570h]
00007FF91DFD8884  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD8888  F3 0F 59 F2                 mulss   xmm6, xmm2
00007FF91DFD888C  F3 0F 11 8B 90 A5 00 00     movss   dword ptr [rbx+0A590h], xmm1
00007FF91DFD8894  F3 0F 11 93 00 A6 00 00     movss   dword ptr [rbx+0A600h], xmm2
00007FF91DFD889C  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFD88A0  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFD88A3  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD88A7  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD88AB  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFD88AF  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD88B3  F3 0F 11 B3 10 A6 00 00     movss   dword ptr [rbx+0A610h], xmm6
00007FF91DFD88BB  F3 0F 11 9B 20 A6 00 00     movss   dword ptr [rbx+0A620h], xmm3
00007FF91DFD88C3  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD88C6  F3 0F 58 9B 60 A6 00 00     addss   xmm3, dword ptr [rbx+0A660h]
00007FF91DFD88CE  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFD88D2  72 05                       jb      short loc_7FF91DFD88D9
00007FF91DFD88D4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD88D7  EB 03                       jmp     short loc_7FF91DFD88DC
00007FF91DFD88D9  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFD88DC  41 0F 2E CE                 ucomiss xmm1, xmm14
00007FF91DFD88E0  F3 44 0F 10 3D FB CB 76 00  movss   xmm15, cs:dword_7FF91E7454E4
00007FF91DFD88E9  75 06                       jnz     short loc_7FF91DFD88F1
00007FF91DFD88EB  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD88EF  EB 04                       jmp     short loc_7FF91DFD88F5
00007FF91DFD88F1  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFD88F5  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFD88F9  F3 0F 11 AB 30 A6 00 00     movss   dword ptr [rbx+0A630h], xmm5
00007FF91DFD8901  73 06                       jnb     short loc_7FF91DFD8909
00007FF91DFD8903  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFD8907  EB 06                       jmp     short loc_7FF91DFD890F
00007FF91DFD8909  76 04                       jbe     short loc_7FF91DFD890F
00007FF91DFD890B  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFD890F  F3 0F 10 83 A0 A6 00 00     movss   xmm0, dword ptr [rbx+0A6A0h]
00007FF91DFD8917  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFD891C  F3 0F 10 93 40 A7 00 00     movss   xmm2, dword ptr [rbx+0A740h]
00007FF91DFD8924  F3 0F 10 8B B0 A6 00 00     movss   xmm1, dword ptr [rbx+0A6B0h]
00007FF91DFD892C  8B 83 70 A6 00 00           mov     eax, [rbx+0A670h]
00007FF91DFD8932  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFD8935  F3 0F 10 A3 00 A7 00 00     movss   xmm4, dword ptr [rbx+0A700h]
00007FF91DFD893D  F3 0F 58 9B 50 A7 00 00     addss   xmm3, dword ptr [rbx+0A750h]
00007FF91DFD8945  F2 44 0F 10 25 52 C8 76 00  movsd   xmm12, cs:dbl_7FF91E7451A0
00007FF91DFD894E  F3 0F 11 AB 50 A6 00 00     movss   dword ptr [rbx+0A650h], xmm5
00007FF91DFD8956  F3 0F 11 AB 70 A6 00 00     movss   dword ptr [rbx+0A670h], xmm5
00007FF91DFD895E  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFD8962  89 83 80 A6 00 00           mov     [rbx+0A680h], eax
00007FF91DFD8968  F3 0F 11 A3 10 A7 00 00     movss   dword ptr [rbx+0A710h], xmm4
00007FF91DFD8970  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFD8974  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD8977  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD897B  F3 0F 10 8B E0 A6 00 00     movss   xmm1, dword ptr [rbx+0A6E0h]
00007FF91DFD8983  F3 0F 58 83 60 A7 00 00     addss   xmm0, dword ptr [rbx+0A760h]
00007FF91DFD898B  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFD8990  F3 0F 5E C8                 divss   xmm1, xmm0
00007FF91DFD8994  F3 0F 10 83 70 A7 00 00     movss   xmm0, dword ptr [rbx+0A770h]
00007FF91DFD899C  F3 0F 59 AB 90 A6 00 00     mulss   xmm5, dword ptr [rbx+0A690h]
00007FF91DFD89A4  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD89A8  F3 0F 10 93 D0 A6 00 00     movss   xmm2, dword ptr [rbx+0A6D0h]
00007FF91DFD89B0  F3 0F 11 AB 20 A7 00 00     movss   dword ptr [rbx+0A720h], xmm5
00007FF91DFD89B8  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFD89BC  F3 0F 10 8B F0 A6 00 00     movss   xmm1, dword ptr [rbx+0A6F0h]
00007FF91DFD89C4  F3 0F 58 D6                 addss   xmm2, xmm6
00007FF91DFD89C8  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFD89CC  F3 0F 11 93 D0 A6 00 00     movss   dword ptr [rbx+0A6D0h], xmm2
00007FF91DFD89D4  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD89D8  F3 0F 11 93 E0 A6 00 00     movss   dword ptr [rbx+0A6E0h], xmm2
00007FF91DFD89E0  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFD89E4  F3 0F 5C E6                 subss   xmm4, xmm6
00007FF91DFD89E8  0F 54 25 A1 CD 76 00        andps   xmm4, cs:xmmword_7FF91E745790
00007FF91DFD89EF  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFD89F3  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD89F7  0F 83 E8 00 00 00           jnb     loc_7FF91DFD8AE5
00007FF91DFD89FD  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFD8A00  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFD8A03  41 0F 2E EE                 ucomiss xmm5, xmm14
00007FF91DFD8A07  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD8A0B  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFD8A0E  F3 0F 11 83 F0 A6 00 00     movss   dword ptr [rbx+0A6F0h], xmm0
00007FF91DFD8A16  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFD8A1A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFD8A1E  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD8A22  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD8A26  75 03                       jnz     short loc_7FF91DFD8A2B
00007FF91DFD8A28  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFD8A2B  8B 83 B0 A7 00 00           mov     eax, [rbx+0A7B0h]
00007FF91DFD8A31  48 8D 0D C8 75 C8 FF        lea     rcx, cs:7FF91DC60000h
00007FF91DFD8A38  F3 0F 59 BB A0 A7 00 00     mulss   xmm7, dword ptr [rbx+0A7A0h]
00007FF91DFD8A40  89 83 C0 A7 00 00           mov     [rbx+0A7C0h], eax
00007FF91DFD8A46  F3 44 0F 59 83 90 A7 00 00  mulss   xmm8, dword ptr [rbx+0A790h]
00007FF91DFD8A4F  F3 0F 10 83 D0 A8 00 00     movss   xmm0, dword ptr [rbx+0A8D0h]
00007FF91DFD8A57  F3 0F 10 93 D0 A7 00 00     movss   xmm2, dword ptr [rbx+0A7D0h]
00007FF91DFD8A5F  F3 44 0F 10 8B 30 A8 00 00  movss   xmm9, dword ptr [rbx+0A830h]
00007FF91DFD8A68  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFD8A6D  F3 44 0F 10 83 10 A8 00 00  movss   xmm8, dword ptr [rbx+0A810h]
00007FF91DFD8A76  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFD8A7A  F3 0F 11 BB B0 A7 00 00     movss   dword ptr [rbx+0A7B0h], xmm7
00007FF91DFD8A82  F3 0F 10 BB F0 A7 00 00     movss   xmm7, dword ptr [rbx+0A7F0h]
00007FF91DFD8A8A  F3 0F 11 8B 00 A7 00 00     movss   dword ptr [rbx+0A700h], xmm1
00007FF91DFD8A92  F3 0F 11 8B 30 A7 00 00     movss   dword ptr [rbx+0A730h], xmm1
00007FF91DFD8A9A  F3 0F 10 8B 90 A8 00 00     movss   xmm1, dword ptr [rbx+0A890h]
00007FF91DFD8AA2  F3 0F 11 BB 00 A8 00 00     movss   dword ptr [rbx+0A800h], xmm7
00007FF91DFD8AAA  F3 0F 11 93 E0 A7 00 00     movss   dword ptr [rbx+0A7E0h], xmm2
00007FF91DFD8AB2  F3 44 0F 11 83 20 A8 00 00  movss   dword ptr [rbx+0A820h], xmm8
00007FF91DFD8ABB  F3 44 0F 11 8B 40 A8 00 00  movss   dword ptr [rbx+0A840h], xmm9
00007FF91DFD8AC4  F3 0F 11 8B A0 A8 00 00     movss   dword ptr [rbx+0A8A0h], xmm1
00007FF91DFD8ACC  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFD8ACF  7D 2F                       jge     short loc_7FF91DFD8B00
00007FF91DFD8AD1  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFD8AD6  F7 D0                       not     eax
00007FF91DFD8AD8  48 98                       cdqe
00007FF91DFD8ADA  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD8AE3  EB 47                       jmp     short loc_7FF91DFD8B2C
00007FF91DFD8AE5  F3 0F 58 8B 80 A7 00 00     addss   xmm1, dword ptr [rbx+0A780h]
00007FF91DFD8AED  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFD8AF1  0F 82 09 FF FF FF           jb      loc_7FF91DFD8A00
00007FF91DFD8AF7  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFD8AFB  E9 03 FF FF FF              jmp     loc_7FF91DFD8A03
00007FF91DFD8B00  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFD8B03  7E 07                       jle     short loc_7FF91DFD8B0C
00007FF91DFD8B05  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFD8B0A  EB 15                       jmp     short loc_7FF91DFD8B21
00007FF91DFD8B0C  85 C0                       test    eax, eax
00007FF91DFD8B0E  79 0F                       jns     short loc_7FF91DFD8B1F
00007FF91DFD8B10  F7 D0                       not     eax
00007FF91DFD8B12  48 98                       cdqe
00007FF91DFD8B14  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD8B1D  EB 0D                       jmp     short loc_7FF91DFD8B2C
00007FF91DFD8B1F  7E 0B                       jle     short loc_7FF91DFD8B2C
00007FF91DFD8B21  48 98                       cdqe
00007FF91DFD8B23  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFD8B2C  0F 57 05 8D CC 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFD8B33  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFD8B37  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFD8B3A  7D 14                       jge     short loc_7FF91DFD8B50
00007FF91DFD8B3C  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFD8B41  F7 D0                       not     eax
00007FF91DFD8B43  48 98                       cdqe
00007FF91DFD8B45  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD8B4E  EB 2C                       jmp     short loc_7FF91DFD8B7C
00007FF91DFD8B50  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFD8B53  7E 07                       jle     short loc_7FF91DFD8B5C
00007FF91DFD8B55  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFD8B5A  EB 15                       jmp     short loc_7FF91DFD8B71
00007FF91DFD8B5C  85 C0                       test    eax, eax
00007FF91DFD8B5E  79 0F                       jns     short loc_7FF91DFD8B6F
00007FF91DFD8B60  F7 D0                       not     eax
00007FF91DFD8B62  48 98                       cdqe
00007FF91DFD8B64  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFD8B6D  EB 0D                       jmp     short loc_7FF91DFD8B7C
00007FF91DFD8B6F  7E 0B                       jle     short loc_7FF91DFD8B7C
00007FF91DFD8B71  48 98                       cdqe
00007FF91DFD8B73  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFD8B7C  F3 0F 10 83 50 A8 00 00     movss   xmm0, dword ptr [rbx+0A850h]
00007FF91DFD8B84  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFD8B88  F3 0F 59 93 C0 A8 00 00     mulss   xmm2, dword ptr [rbx+0A8C0h]
00007FF91DFD8B90  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD8B94  F3 0F 10 8B 80 A8 00 00     movss   xmm1, dword ptr [rbx+0A880h]
00007FF91DFD8B9C  F3 0F 11 93 90 A8 00 00     movss   dword ptr [rbx+0A890h], xmm2
00007FF91DFD8BA4  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD8BA8  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD8BAC  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD8BB0  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD8BB4  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFD8BB8  76 05                       jbe     short loc_7FF91DFD8BBF
00007FF91DFD8BBA  0F 5A C2                    cvtps2pd xmm0, xmm2
00007FF91DFD8BBD  EB 03                       jmp     short loc_7FF91DFD8BC2
00007FF91DFD8BBF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD8BC2  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFD8BC6  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFD8BCA  72 06                       jb      short loc_7FF91DFD8BD2
00007FF91DFD8BCC  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFD8BD0  EB 03                       jmp     short loc_7FF91DFD8BD5
00007FF91DFD8BD2  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFD8BD5  F3 0F 10 B3 60 A8 00 00     movss   xmm6, dword ptr [rbx+0A860h]
00007FF91DFD8BDD  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFD8BE1  F3 0F 59 83 F0 A8 00 00     mulss   xmm0, dword ptr [rbx+0A8F0h]; X
00007FF91DFD8BE9  E8 52 6B 37 00              call    expf
00007FF91DFD8BEE  F3 0F 59 83 E0 A8 00 00     mulss   xmm0, dword ptr [rbx+0A8E0h]
00007FF91DFD8BF6  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFD8BF9  8B 83 60 AA 00 00           mov     eax, [rbx+0AA60h]
00007FF91DFD8BFF  F3 0F 59 8B 70 A8 00 00     mulss   xmm1, dword ptr [rbx+0A870h]
00007FF91DFD8C07  89 83 70 AA 00 00           mov     [rbx+0AA70h], eax
00007FF91DFD8C0D  F3 0F 58 83 00 A9 00 00     addss   xmm0, dword ptr [rbx+0A900h]
00007FF91DFD8C15  8B 83 80 AA 00 00           mov     eax, [rbx+0AA80h]
00007FF91DFD8C1B  F3 0F 10 9B 20 AA 00 00     movss   xmm3, dword ptr [rbx+0AA20h]
00007FF91DFD8C23  F3 0F 59 BB B0 AB 00 00     mulss   xmm7, dword ptr [rbx+0ABB0h]
00007FF91DFD8C2B  89 83 90 AA 00 00           mov     [rbx+0AA90h], eax
00007FF91DFD8C31  8B 83 A0 AA 00 00           mov     eax, [rbx+0AAA0h]
00007FF91DFD8C37  F3 0F 10 93 10 AA 00 00     movss   xmm2, dword ptr [rbx+0AA10h]
00007FF91DFD8C3F  F3 0F 10 A3 40 AA 00 00     movss   xmm4, dword ptr [rbx+0AA40h]
00007FF91DFD8C47  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFD8C4B  89 83 B0 AA 00 00           mov     [rbx+0AAB0h], eax
00007FF91DFD8C51  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
00007FF91DFD8C57  F3 0F 11 9B 30 AA 00 00     movss   dword ptr [rbx+0AA30h], xmm3
00007FF91DFD8C5F  F3 0F 5C CE                 subss   xmm1, xmm6
00007FF91DFD8C63  F3 0F 11 93 20 AA 00 00     movss   dword ptr [rbx+0AA20h], xmm2
00007FF91DFD8C6B  F3 0F 11 A3 50 AA 00 00     movss   dword ptr [rbx+0AA50h], xmm4
00007FF91DFD8C73  F3 44 0F 11 83 E0 A9 00 00  movss   dword ptr [rbx+0A9E0h], xmm8
00007FF91DFD8C7C  F3 44 0F 11 8B F0 A9 00 00  movss   dword ptr [rbx+0A9F0h], xmm9
00007FF91DFD8C85  89 83 D0 A9 00 00           mov     [rbx+0A9D0h], eax
00007FF91DFD8C8B  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD8C8F  F3 0F 10 83 80 AB 00 00     movss   xmm0, dword ptr [rbx+0AB80h]
00007FF91DFD8C97  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFD8C9B  F3 0F 11 83 70 AB 00 00     movss   dword ptr [rbx+0AB70h], xmm0
00007FF91DFD8CA3  F3 0F 11 8B B0 A8 00 00     movss   dword ptr [rbx+0A8B0h], xmm1
00007FF91DFD8CAB  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFD8CAF  73 06                       jnb     short loc_7FF91DFD8CB7
00007FF91DFD8CB1  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD8CB5  EB 05                       jmp     short loc_7FF91DFD8CBC
00007FF91DFD8CB7  F3 41 0F 5D FD              minss   xmm7, xmm13
00007FF91DFD8CBC  F3 0F 59 0D FC 20 61 00     mulss   xmm1, cs:dword_7FF91E5EADC0
00007FF91DFD8CC4  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD8CC8  F3 0F 10 B3 90 AC 00 00     movss   xmm6, dword ptr [rbx+0AC90h]
00007FF91DFD8CD0  F3 0F 5C C3                 subss   xmm0, xmm3
00007FF91DFD8CD4  F3 0F 11 BB 10 AA 00 00     movss   dword ptr [rbx+0AA10h], xmm7
00007FF91DFD8CDC  F3 0F 5D F1                 minss   xmm6, xmm1
00007FF91DFD8CE0  F3 0F 59 83 C0 AB 00 00     mulss   xmm0, dword ptr [rbx+0ABC0h]
00007FF91DFD8CE8  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFD8CEC  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFD8CF0  73 06                       jnb     short loc_7FF91DFD8CF8
00007FF91DFD8CF2  41 0F 28 C7                 movaps  xmm0, xmm15
00007FF91DFD8CF6  EB 05                       jmp     short loc_7FF91DFD8CFD
00007FF91DFD8CF8  F3 41 0F 5D C5              minss   xmm0, xmm13
00007FF91DFD8CFD  F3 0F 59 B3 A0 AC 00 00     mulss   xmm6, dword ptr [rbx+0ACA0h]
00007FF91DFD8D05  F3 0F 5C D7                 subss   xmm2, xmm7
00007FF91DFD8D09  F3 0F 11 B3 C0 AA 00 00     movss   dword ptr [rbx+0AAC0h], xmm6
00007FF91DFD8D11  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFD8D15  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFD8D19  73 03                       jnb     short loc_7FF91DFD8D1E
00007FF91DFD8D1B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD8D1E  F3 0F 10 8B 90 AB 00 00     movss   xmm1, dword ptr [rbx+0AB90h]
00007FF91DFD8D26  F3 44 0F 10 9B D0 A9 00 00  movss   xmm11, dword ptr [rbx+0A9D0h]
00007FF91DFD8D2F  F3 0F 11 83 20 AA 00 00     movss   dword ptr [rbx+0AA20h], xmm0
00007FF91DFD8D37  F3 0F 58 83 20 AD 00 00     addss   xmm0, dword ptr [rbx+0AD20h]
00007FF91DFD8D3F  72 04                       jb      short loc_7FF91DFD8D45
00007FF91DFD8D41  41 0F 28 CD                 movaps  xmm1, xmm13
00007FF91DFD8D45  F3 0F 59 83 10 AD 00 00     mulss   xmm0, dword ptr [rbx+0AD10h]
00007FF91DFD8D4D  41 0F 28 FB                 movaps  xmm7, xmm11
00007FF91DFD8D51  F3 0F 10 93 70 AA 00 00     movss   xmm2, dword ptr [rbx+0AA70h]
00007FF91DFD8D59  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFD8D5D  F3 0F 5C FA                 subss   xmm7, xmm2
00007FF91DFD8D61  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD8D65  F3 0F 59 B3 A0 AB 00 00     mulss   xmm6, dword ptr [rbx+0ABA0h]
00007FF91DFD8D6D  76 05                       jbe     short loc_7FF91DFD8D74
00007FF91DFD8D6F  0F 5A C8                    cvtps2pd xmm1, xmm0
00007FF91DFD8D72  EB 03                       jmp     short loc_7FF91DFD8D77
00007FF91DFD8D74  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFD8D77  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD8D7B  F3 0F 59 BB E0 AD 00 00     mulss   xmm7, dword ptr [rbx+0ADE0h]
00007FF91DFD8D83  F3 44 0F 10 0D 5C C4 76 00  movss   xmm9, cs:flt_7FF91E7451E8
00007FF91DFD8D8C  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
00007FF91DFD8D90  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFD8D94  F3 0F 11 BB 60 AA 00 00     movss   dword ptr [rbx+0AA60h], xmm7
00007FF91DFD8D9C  F3 0F 11 83 00 AA 00 00     movss   dword ptr [rbx+0AA00h], xmm0
00007FF91DFD8DA4  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFD8DA8  F3 0F 59 BB D0 AD 00 00     mulss   xmm7, dword ptr [rbx+0ADD0h]
00007FF91DFD8DB0  F3 0F 10 8B 50 AC 00 00     movss   xmm1, dword ptr [rbx+0AC50h]
00007FF91DFD8DB8  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD8DBC  F3 0F 59 F9                 mulss   xmm7, xmm1
00007FF91DFD8DC0  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFD8DC4  F3 0F 10 83 50 AA 00 00     movss   xmm0, dword ptr [rbx+0AA50h]
00007FF91DFD8DCC  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
00007FF91DFD8DD5  F3 41 0F 58 FB              addss   xmm7, xmm11
00007FF91DFD8DDA  76 1B                       jbe     short loc_7FF91DFD8DF7
00007FF91DFD8DDC  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD8DE1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD8DE5  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD8DE8  E8 EB 66 37 00              call    fmodf
00007FF91DFD8DED  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD8DF0  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD8DF5  EB 1F                       jmp     short loc_7FF91DFD8E16
00007FF91DFD8DF7  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD8DFB  73 19                       jnb     short loc_7FF91DFD8E16
00007FF91DFD8DFD  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD8E02  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD8E06  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD8E09  E8 CA 66 37 00              call    fmodf
00007FF91DFD8E0E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD8E11  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD8E16  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
00007FF91DFD8E1F  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFD8E22  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD8E26  F3 44 0F 10 83 90 AA 00 00  movss   xmm8, dword ptr [rbx+0AA90h]
00007FF91DFD8E2F  F3 0F 11 B3 40 AA 00 00     movss   dword ptr [rbx+0AA40h], xmm6
00007FF91DFD8E37  F3 0F 59 BB C0 AD 00 00     mulss   xmm7, dword ptr [rbx+0ADC0h]
00007FF91DFD8E3F  F3 0F 58 83 30 AD 00 00     addss   xmm0, dword ptr [rbx+0AD30h]
00007FF91DFD8E47  F3 0F 11 BB C0 A9 00 00     movss   dword ptr [rbx+0A9C0h], xmm7
00007FF91DFD8E4F  73 0A                       jnb     short loc_7FF91DFD8E5B
00007FF91DFD8E51  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFD8E55  76 04                       jbe     short loc_7FF91DFD8E5B
00007FF91DFD8E57  45 0F 28 C3                 movaps  xmm8, xmm11
00007FF91DFD8E5B  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFD8E5F  76 15                       jbe     short loc_7FF91DFD8E76
00007FF91DFD8E61  F3 41 0F 58 C5              addss   xmm0, xmm13; X
00007FF91DFD8E66  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD8E6A  E8 69 66 37 00              call    fmodf
00007FF91DFD8E6F  F3 41 0F 5C C5              subss   xmm0, xmm13
00007FF91DFD8E74  EB 19                       jmp     short loc_7FF91DFD8E8F
00007FF91DFD8E76  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFD8E7A  73 13                       jnb     short loc_7FF91DFD8E8F
00007FF91DFD8E7C  F3 41 0F 5C C5              subss   xmm0, xmm13; X
00007FF91DFD8E81  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD8E85  E8 4E 66 37 00              call    fmodf
00007FF91DFD8E8A  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD8E8F  F3 44 0F 10 1D 28 C9 76 00  movss   xmm11, dword ptr cs:xmmword_7FF91E7457C0
00007FF91DFD8E98  F3 44 0F 11 83 80 AA 00 00  movss   dword ptr [rbx+0AA80h], xmm8
00007FF91DFD8EA1  F3 0F 59 83 70 AD 00 00     mulss   xmm0, dword ptr [rbx+0AD70h]
00007FF91DFD8EA9  F3 44 0F 59 83 B0 AD 00 00  mulss   xmm8, dword ptr [rbx+0ADB0h]
00007FF91DFD8EB2  F3 0F 58 83 F0 AD 00 00     addss   xmm0, dword ptr [rbx+0ADF0h]
00007FF91DFD8EBA  F3 0F 11 83 D0 AA 00 00     movss   dword ptr [rbx+0AAD0h], xmm0
00007FF91DFD8EC2  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFD8EC6  F3 44 0F 11 83 20 AB 00 00  movss   dword ptr [rbx+0AB20h], xmm8
00007FF91DFD8ECF  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFD8ED3  F3 44 0F 58 83 50 AD 00 00  addss   xmm8, dword ptr [rbx+0AD50h]
00007FF91DFD8EDC  F3 0F 11 83 E0 AA 00 00     movss   dword ptr [rbx+0AAE0h], xmm0
00007FF91DFD8EE4  45 0F 2F C5                 comiss  xmm8, xmm13
00007FF91DFD8EE8  76 1D                       jbe     short loc_7FF91DFD8F07
00007FF91DFD8EEA  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD8EEF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD8EF3  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFD8EF7  E8 DC 65 37 00              call    fmodf
00007FF91DFD8EFC  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD8F00  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFD8F05  EB 21                       jmp     short loc_7FF91DFD8F28
00007FF91DFD8F07  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFD8F0B  73 1B                       jnb     short loc_7FF91DFD8F28
00007FF91DFD8F0D  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFD8F12  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD8F16  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFD8F1A  E8 B9 65 37 00              call    fmodf
00007FF91DFD8F1F  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFD8F23  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFD8F28  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFD8F2B  F3 0F 58 BB 40 AD 00 00     addss   xmm7, dword ptr [rbx+0AD40h]
00007FF91DFD8F33  41 0F 2F FD                 comiss  xmm7, xmm13
00007FF91DFD8F37  76 1B                       jbe     short loc_7FF91DFD8F54
00007FF91DFD8F39  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD8F3E  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD8F42  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFD8F45  E8 8E 65 37 00              call    fmodf
00007FF91DFD8F4A  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFD8F4D  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD8F52  EB 1F                       jmp     short loc_7FF91DFD8F73
00007FF91DFD8F54  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFD8F58  73 19                       jnb     short loc_7FF91DFD8F73
00007FF91DFD8F5A  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFD8F5F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD8F63  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFD8F66  E8 6D 65 37 00              call    fmodf
00007FF91DFD8F6B  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFD8F6E  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFD8F73  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFD8F77  E8 44 00 FF FF              call    sub_7FF91DFC8FC0
00007FF91DFD8F7C  F3 0F 58 BB 00 AE 00 00     addss   xmm7, dword ptr [rbx+0AE00h]
00007FF91DFD8F84  F3 0F 59 83 90 AD 00 00     mulss   xmm0, dword ptr [rbx+0AD90h]
00007FF91DFD8F8C  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD8F90  73 06                       jnb     short loc_7FF91DFD8F98
00007FF91DFD8F92  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFD8F96  EB 06                       jmp     short loc_7FF91DFD8F9E
00007FF91DFD8F98  76 04                       jbe     short loc_7FF91DFD8F9E
00007FF91DFD8F9A  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD8F9E  F3 0F 58 B3 60 AD 00 00     addss   xmm6, dword ptr [rbx+0AD60h]
00007FF91DFD8FA6  F3 0F 11 83 00 AB 00 00     movss   dword ptr [rbx+0AB00h], xmm0
00007FF91DFD8FAE  F3 0F 11 BB 60 AB 00 00     movss   dword ptr [rbx+0AB60h], xmm7
00007FF91DFD8FB6  F3 0F 59 BB 80 AD 00 00     mulss   xmm7, dword ptr [rbx+0AD80h]
00007FF91DFD8FBE  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFD8FC2  F3 0F 58 BB 10 AE 00 00     addss   xmm7, dword ptr [rbx+0AE10h]
00007FF91DFD8FCA  76 1B                       jbe     short loc_7FF91DFD8FE7
00007FF91DFD8FCC  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD8FD1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD8FD5  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD8FD8  E8 FB 64 37 00              call    fmodf
00007FF91DFD8FDD  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD8FE0  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD8FE5  EB 1F                       jmp     short loc_7FF91DFD9006
00007FF91DFD8FE7  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFD8FEB  73 19                       jnb     short loc_7FF91DFD9006
00007FF91DFD8FED  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFD8FF2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFD8FF6  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFD8FF9  E8 DA 64 37 00              call    fmodf
00007FF91DFD8FFE  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFD9001  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFD9006  0F 54 35 83 C7 76 00        andps   xmm6, cs:xmmword_7FF91E745790
00007FF91DFD900D  F3 0F 11 BB F0 AA 00 00     movss   dword ptr [rbx+0AAF0h], xmm7
00007FF91DFD9015  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFD9018  F3 0F 10 9B 30 AC 00 00     movss   xmm3, dword ptr [rbx+0AC30h]
00007FF91DFD9020  0F 28 D6                    movaps  xmm2, xmm6
00007FF91DFD9023  F3 0F 59 93 C0 AC 00 00     mulss   xmm2, dword ptr [rbx+0ACC0h]
00007FF91DFD902B  F3 0F 59 9B 20 AB 00 00     mulss   xmm3, dword ptr [rbx+0AB20h]
00007FF91DFD9033  F3 0F 58 93 B0 AC 00 00     addss   xmm2, dword ptr [rbx+0ACB0h]
00007FF91DFD903B  F3 0F 10 8B 20 AC 00 00     movss   xmm1, dword ptr [rbx+0AC20h]
00007FF91DFD9043  F3 0F 59 8B E0 AA 00 00     mulss   xmm1, dword ptr [rbx+0AAE0h]
00007FF91DFD904B  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFD904F  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFD9052  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFD9056  F3 0F 59 83 D0 AC 00 00     mulss   xmm0, dword ptr [rbx+0ACD0h]
00007FF91DFD905E  F3 0F 59 F4                 mulss   xmm6, xmm4
00007FF91DFD9062  F3 0F 59 A3 E0 AC 00 00     mulss   xmm4, dword ptr [rbx+0ACE0h]
00007FF91DFD906A  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD906E  F3 0F 59 B3 F0 AC 00 00     mulss   xmm6, dword ptr [rbx+0ACF0h]
00007FF91DFD9076  F3 0F 10 83 10 AC 00 00     movss   xmm0, dword ptr [rbx+0AC10h]
00007FF91DFD907E  F3 0F 59 83 D0 AA 00 00     mulss   xmm0, dword ptr [rbx+0AAD0h]
00007FF91DFD9086  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFD908A  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD908E  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFD9092  F3 0F 10 A3 F0 AB 00 00     movss   xmm4, dword ptr [rbx+0ABF0h]
00007FF91DFD909A  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD909E  F3 0F 58 B3 00 AD 00 00     addss   xmm6, dword ptr [rbx+0AD00h]
00007FF91DFD90A6  F3 0F 59 B3 A0 AD 00 00     mulss   xmm6, dword ptr [rbx+0ADA0h]
00007FF91DFD90AE  F3 0F 11 B3 10 AB 00 00     movss   dword ptr [rbx+0AB10h], xmm6
00007FF91DFD90B6  F3 0F 59 A3 00 AB 00 00     mulss   xmm4, dword ptr [rbx+0AB00h]
00007FF91DFD90BE  F3 0F 10 8B D0 AB 00 00     movss   xmm1, dword ptr [rbx+0ABD0h]
00007FF91DFD90C6  F3 0F 10 83 00 AC 00 00     movss   xmm0, dword ptr [rbx+0AC00h]
00007FF91DFD90CE  F3 0F 59 83 F0 AA 00 00     mulss   xmm0, dword ptr [rbx+0AAF0h]
00007FF91DFD90D6  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD90DA  F3 0F 10 93 60 AC 00 00     movss   xmm2, dword ptr [rbx+0AC60h]
00007FF91DFD90E2  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFD90E5  F3 0F 59 9B 00 AA 00 00     mulss   xmm3, dword ptr [rbx+0AA00h]
00007FF91DFD90ED  F3 0F 59 B3 E0 AB 00 00     mulss   xmm6, dword ptr [rbx+0ABE0h]
00007FF91DFD90F5  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD90F9  F3 0F 10 83 40 AC 00 00     movss   xmm0, dword ptr [rbx+0AC40h]
00007FF91DFD9101  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFD9105  F3 0F 59 83 C0 A9 00 00     mulss   xmm0, dword ptr [rbx+0A9C0h]
00007FF91DFD910D  F3 0F 58 E6                 addss   xmm4, xmm6
00007FF91DFD9111  F3 41 0F 58 DD              addss   xmm3, xmm13
00007FF91DFD9116  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFD911A  F3 0F 11 9B 30 AB 00 00     movss   dword ptr [rbx+0AB30h], xmm3
00007FF91DFD9122  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD9126  F3 0F 11 A3 50 AB 00 00     movss   dword ptr [rbx+0AB50h], xmm4
00007FF91DFD912E  F3 0F 10 8B 70 AC 00 00     movss   xmm1, dword ptr [rbx+0AC70h]
00007FF91DFD9136  F3 0F 59 8B E0 A9 00 00     mulss   xmm1, dword ptr [rbx+0A9E0h]
00007FF91DFD913E  F3 0F 10 83 80 AC 00 00     movss   xmm0, dword ptr [rbx+0AC80h]
00007FF91DFD9146  F3 0F 59 83 F0 A9 00 00     mulss   xmm0, dword ptr [rbx+0A9F0h]
00007FF91DFD914E  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD9152  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD9156  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD915A  F3 0F 11 8B 40 AB 00 00     movss   dword ptr [rbx+0AB40h], xmm1
00007FF91DFD9162  F3 0F 10 83 50 AB 00 00     movss   xmm0, dword ptr [rbx+0AB50h]
00007FF91DFD916A  8B 83 60 AB 00 00           mov     eax, [rbx+0AB60h]
00007FF91DFD9170  89 83 20 AE 00 00           mov     [rbx+0AE20h], eax
00007FF91DFD9176  F3 0F 11 83 30 AE 00 00     movss   dword ptr [rbx+0AE30h], xmm0
00007FF91DFD917E  44 0F 2F B3 60 AB 00 00     comiss  xmm14, dword ptr [rbx+0AB60h]
00007FF91DFD9186  F3 0F 10 8B 70 A6 00 00     movss   xmm1, dword ptr [rbx+0A670h]
00007FF91DFD918E  F3 0F 10 93 40 AE 00 00     movss   xmm2, dword ptr [rbx+0AE40h]
00007FF91DFD9196  73 06                       jnb     short loc_7FF91DFD919E
00007FF91DFD9198  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD919C  EB 03                       jmp     short loc_7FF91DFD91A1
00007FF91DFD919E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD91A1  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFD91A5  75 04                       jnz     short loc_7FF91DFD91AB
00007FF91DFD91A7  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD91AB  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD91AF  F3 0F 11 8B 50 AE 00 00     movss   dword ptr [rbx+0AE50h], xmm1
00007FF91DFD91B7  8B 83 60 AE 00 00           mov     eax, [rbx+0AE60h]
00007FF91DFD91BD  89 83 70 AE 00 00           mov     [rbx+0AE70h], eax
00007FF91DFD91C3  8B 83 90 AE 00 00           mov     eax, [rbx+0AE90h]
00007FF91DFD91C9  89 83 A0 AE 00 00           mov     [rbx+0AEA0h], eax
00007FF91DFD91CF  8B 83 80 AE 00 00           mov     eax, [rbx+0AE80h]
00007FF91DFD91D5  89 83 90 AE 00 00           mov     [rbx+0AE90h], eax
00007FF91DFD91DB  8B 83 B0 AE 00 00           mov     eax, [rbx+0AEB0h]
00007FF91DFD91E1  89 83 C0 AE 00 00           mov     [rbx+0AEC0h], eax
00007FF91DFD91E7  8B 83 E0 AE 00 00           mov     eax, [rbx+0AEE0h]
00007FF91DFD91ED  89 83 F0 AE 00 00           mov     [rbx+0AEF0h], eax
00007FF91DFD91F3  F3 0F 10 83 90 AF 00 00     movss   xmm0, dword ptr [rbx+0AF90h]
00007FF91DFD91FB  F3 0F 58 8B 70 AF 00 00     addss   xmm1, dword ptr [rbx+0AF70h]
00007FF91DFD9203  F3 0F 59 83 A0 AE 00 00     mulss   xmm0, dword ptr [rbx+0AEA0h]
00007FF91DFD920B  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD920F  F3 0F 58 83 70 AE 00 00     addss   xmm0, dword ptr [rbx+0AE70h]
00007FF91DFD9217  73 06                       jnb     short loc_7FF91DFD921F
00007FF91DFD9219  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFD921D  EB 04                       jmp     short loc_7FF91DFD9223
00007FF91DFD921F  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFD9223  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFD9227  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFD922C  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFD922F  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFD9233  F3 0F 11 BB 80 AE 00 00     movss   dword ptr [rbx+0AE80h], xmm7
00007FF91DFD923B  0F 28 E7                    movaps  xmm4, xmm7
00007FF91DFD923E  F3 0F 10 9B 60 AF 00 00     movss   xmm3, dword ptr [rbx+0AF60h]
00007FF91DFD9246  F3 0F 10 93 B0 AF 00 00     movss   xmm2, dword ptr [rbx+0AFB0h]
00007FF91DFD924E  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD9251  F3 0F 59 8B D0 AF 00 00     mulss   xmm1, dword ptr [rbx+0AFD0h]
00007FF91DFD9259  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD925C  F3 0F 58 A3 80 AF 00 00     addss   xmm4, dword ptr [rbx+0AF80h]
00007FF91DFD9264  F3 0F 5C BB 90 AE 00 00     subss   xmm7, dword ptr [rbx+0AE90h]
00007FF91DFD926C  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD9270  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFD9274  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD9278  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD927C  F3 0F 11 8B D0 AE 00 00     movss   dword ptr [rbx+0AED0h], xmm1
00007FF91DFD9284  72 06                       jb      short loc_7FF91DFD928C
00007FF91DFD9286  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFD928A  EB 03                       jmp     short loc_7FF91DFD928F
00007FF91DFD928C  0F 57 F6                    xorps   xmm6, xmm6
00007FF91DFD928F  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFD9293  F3 0F 10 83 30 AF 00 00     movss   xmm0, dword ptr [rbx+0AF30h]
00007FF91DFD929B  73 03                       jnb     short loc_7FF91DFD92A0
00007FF91DFD929D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFD92A0  F3 0F 59 83 B0 AF 00 00     mulss   xmm0, dword ptr [rbx+0AFB0h]
00007FF91DFD92A8  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFD92AB  F3 0F 10 93 20 AF 00 00     movss   xmm2, dword ptr [rbx+0AF20h]
00007FF91DFD92B3  F3 44 0F 10 0D A0 BC 76 00  movss   xmm9, cs:dword_7FF91E744F5C
00007FF91DFD92BC  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFD92C0  F3 0F 11 B3 90 AE 00 00     movss   dword ptr [rbx+0AE90h], xmm6
00007FF91DFD92C8  F3 0F 10 8B C0 AF 00 00     movss   xmm1, dword ptr [rbx+0AFC0h]
00007FF91DFD92D0  F3 0F 10 BB 40 AF 00 00     movss   xmm7, dword ptr [rbx+0AF40h]
00007FF91DFD92D8  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD92DB  F3 0F 10 A3 C0 AE 00 00     movss   xmm4, dword ptr [rbx+0AEC0h]
00007FF91DFD92E3  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD92E7  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFD92EC  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD92F0  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFD92F5  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD92F9  F3 0F 59 FE                 mulss   xmm7, xmm6
00007FF91DFD92FD  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFD9301  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD9305  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFD9309  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD930C  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFD9310  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD9314  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD9318  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFD931C  76 0B                       jbe     short loc_7FF91DFD9329
00007FF91DFD931E  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD9321  F3 0F 58 9B D0 AE 00 00     addss   xmm3, dword ptr [rbx+0AED0h]
00007FF91DFD9329  F3 0F 10 83 B0 AF 00 00     movss   xmm0, dword ptr [rbx+0AFB0h]
00007FF91DFD9331  F3 0F 10 A3 70 AE 00 00     movss   xmm4, dword ptr [rbx+0AE70h]
00007FF91DFD9339  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFD933D  F3 0F 11 83 B0 AE 00 00     movss   dword ptr [rbx+0AEB0h], xmm0
00007FF91DFD9345  F3 0F 10 8B F0 AE 00 00     movss   xmm1, dword ptr [rbx+0AEF0h]
00007FF91DFD934D  F3 0F 10 9B 50 AF 00 00     movss   xmm3, dword ptr [rbx+0AF50h]
00007FF91DFD9355  F3 0F 59 AB A0 AF 00 00     mulss   xmm5, dword ptr [rbx+0AFA0h]
00007FF91DFD935D  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFD9362  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFD9366  F3 0F 10 83 E0 AF 00 00     movss   xmm0, dword ptr [rbx+0AFE0h]
00007FF91DFD936E  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD9373  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFD9376  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD937A  F3 0F 58 EE                 addss   xmm5, xmm6
00007FF91DFD937E  F3 0F 59 D7                 mulss   xmm2, xmm7
00007FF91DFD9382  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFD9386  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD938A  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD938E  F3 0F 11 93 E0 AE 00 00     movss   dword ptr [rbx+0AEE0h], xmm2
00007FF91DFD9396  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFD939B  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFD93A0  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD93A4  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD93A8  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD93AC  F3 0F 11 9B 60 AE 00 00     movss   dword ptr [rbx+0AE60h], xmm3
00007FF91DFD93B4  F3 0F 59 9B F0 AF 00 00     mulss   xmm3, dword ptr [rbx+0AFF0h]
00007FF91DFD93BC  F3 0F 59 9B 00 B0 00 00     mulss   xmm3, dword ptr [rbx+0B000h]
00007FF91DFD93C4  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD93C7  F3 0F 59 83 10 B0 00 00     mulss   xmm0, dword ptr [rbx+0B010h]
00007FF91DFD93CF  F3 0F 11 9B 00 AF 00 00     movss   dword ptr [rbx+0AF00h], xmm3
00007FF91DFD93D7  F3 0F 11 83 10 AF 00 00     movss   dword ptr [rbx+0AF10h], xmm0
00007FF91DFD93DF  44 0F 2F B3 60 AB 00 00     comiss  xmm14, dword ptr [rbx+0AB60h]
00007FF91DFD93E7  F3 0F 10 8B 70 A6 00 00     movss   xmm1, dword ptr [rbx+0A670h]
00007FF91DFD93EF  F3 0F 10 93 20 B0 00 00     movss   xmm2, dword ptr [rbx+0B020h]
00007FF91DFD93F7  73 06                       jnb     short loc_7FF91DFD93FF
00007FF91DFD93F9  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD93FD  EB 03                       jmp     short loc_7FF91DFD9402
00007FF91DFD93FF  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD9402  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFD9406  75 04                       jnz     short loc_7FF91DFD940C
00007FF91DFD9408  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD940C  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFD9410  F3 0F 11 8B 30 B0 00 00     movss   dword ptr [rbx+0B030h], xmm1
00007FF91DFD9418  8B 83 40 B0 00 00           mov     eax, [rbx+0B040h]
00007FF91DFD941E  89 83 50 B0 00 00           mov     [rbx+0B050h], eax
00007FF91DFD9424  8B 83 70 B0 00 00           mov     eax, [rbx+0B070h]
00007FF91DFD942A  89 83 80 B0 00 00           mov     [rbx+0B080h], eax
00007FF91DFD9430  8B 83 60 B0 00 00           mov     eax, [rbx+0B060h]
00007FF91DFD9436  89 83 70 B0 00 00           mov     [rbx+0B070h], eax
00007FF91DFD943C  8B 83 90 B0 00 00           mov     eax, [rbx+0B090h]
00007FF91DFD9442  89 83 A0 B0 00 00           mov     [rbx+0B0A0h], eax
00007FF91DFD9448  8B 83 C0 B0 00 00           mov     eax, [rbx+0B0C0h]
00007FF91DFD944E  89 83 D0 B0 00 00           mov     [rbx+0B0D0h], eax
00007FF91DFD9454  F3 0F 10 83 70 B1 00 00     movss   xmm0, dword ptr [rbx+0B170h]
00007FF91DFD945C  F3 0F 58 8B 50 B1 00 00     addss   xmm1, dword ptr [rbx+0B150h]
00007FF91DFD9464  F3 0F 59 83 80 B0 00 00     mulss   xmm0, dword ptr [rbx+0B080h]
00007FF91DFD946C  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD9470  F3 0F 58 83 50 B0 00 00     addss   xmm0, dword ptr [rbx+0B050h]
00007FF91DFD9478  73 06                       jnb     short loc_7FF91DFD9480
00007FF91DFD947A  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFD947E  EB 04                       jmp     short loc_7FF91DFD9484
00007FF91DFD9480  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFD9484  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFD9488  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFD948D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFD9490  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFD9494  F3 0F 11 B3 60 B0 00 00     movss   dword ptr [rbx+0B060h], xmm6
00007FF91DFD949C  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFD949F  F3 0F 10 9B 40 B1 00 00     movss   xmm3, dword ptr [rbx+0B140h]
00007FF91DFD94A7  F3 0F 10 93 90 B1 00 00     movss   xmm2, dword ptr [rbx+0B190h]
00007FF91DFD94AF  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD94B2  F3 0F 59 8B B0 B1 00 00     mulss   xmm1, dword ptr [rbx+0B1B0h]
00007FF91DFD94BA  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD94BD  F3 0F 58 A3 60 B1 00 00     addss   xmm4, dword ptr [rbx+0B160h]
00007FF91DFD94C5  F3 0F 5C B3 70 B0 00 00     subss   xmm6, dword ptr [rbx+0B070h]
00007FF91DFD94CD  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD94D1  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFD94D5  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD94D9  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD94DD  F3 0F 11 8B B0 B0 00 00     movss   dword ptr [rbx+0B0B0h], xmm1
00007FF91DFD94E5  72 06                       jb      short loc_7FF91DFD94ED
00007FF91DFD94E7  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFD94EB  EB 03                       jmp     short loc_7FF91DFD94F0
00007FF91DFD94ED  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFD94F0  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFD94F4  F3 0F 10 83 10 B1 00 00     movss   xmm0, dword ptr [rbx+0B110h]
00007FF91DFD94FC  73 03                       jnb     short loc_7FF91DFD9501
00007FF91DFD94FE  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFD9501  F3 0F 59 83 90 B1 00 00     mulss   xmm0, dword ptr [rbx+0B190h]
00007FF91DFD9509  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFD950C  F3 0F 10 93 00 B1 00 00     movss   xmm2, dword ptr [rbx+0B100h]
00007FF91DFD9514  F3 0F 11 BB 70 B0 00 00     movss   dword ptr [rbx+0B070h], xmm7
00007FF91DFD951C  F3 0F 10 8B A0 B1 00 00     movss   xmm1, dword ptr [rbx+0B1A0h]
00007FF91DFD9524  F3 0F 10 B3 20 B1 00 00     movss   xmm6, dword ptr [rbx+0B120h]
00007FF91DFD952C  F3 0F 10 A3 A0 B0 00 00     movss   xmm4, dword ptr [rbx+0B0A0h]
00007FF91DFD9534  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFD9538  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD953B  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFD953F  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFD9544  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD9548  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFD954D  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFD9551  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFD9555  F3 0F 5C C7                 subss   xmm0, xmm7
00007FF91DFD9559  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD955D  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFD9561  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD9564  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFD9568  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFD956C  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFD9570  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFD9574  76 0B                       jbe     short loc_7FF91DFD9581
00007FF91DFD9576  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD9579  F3 0F 58 9B B0 B0 00 00     addss   xmm3, dword ptr [rbx+0B0B0h]
00007FF91DFD9581  F3 0F 10 A3 50 B0 00 00     movss   xmm4, dword ptr [rbx+0B050h]
00007FF91DFD9589  F3 0F 10 83 90 B1 00 00     movss   xmm0, dword ptr [rbx+0B190h]
00007FF91DFD9591  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFD9595  F3 0F 11 83 90 B0 00 00     movss   dword ptr [rbx+0B090h], xmm0
00007FF91DFD959D  F3 0F 59 AB 80 B1 00 00     mulss   xmm5, dword ptr [rbx+0B180h]
00007FF91DFD95A5  F3 0F 10 8B D0 B0 00 00     movss   xmm1, dword ptr [rbx+0B0D0h]
00007FF91DFD95AD  F3 0F 10 9B 30 B1 00 00     movss   xmm3, dword ptr [rbx+0B130h]
00007FF91DFD95B5  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFD95B9  F3 0F 10 83 C0 B1 00 00     movss   xmm0, dword ptr [rbx+0B1C0h]
00007FF91DFD95C1  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFD95C4  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFD95C9  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD95CD  F3 0F 58 EF                 addss   xmm5, xmm7
00007FF91DFD95D1  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFD95D6  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD95DA  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFD95DE  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFD95E2  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD95E6  F3 0F 11 93 C0 B0 00 00     movss   dword ptr [rbx+0B0C0h], xmm2
00007FF91DFD95EE  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFD95F3  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFD95F8  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD95FC  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFD9600  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD9604  F3 0F 11 9B 40 B0 00 00     movss   dword ptr [rbx+0B040h], xmm3
00007FF91DFD960C  F3 0F 59 9B D0 B1 00 00     mulss   xmm3, dword ptr [rbx+0B1D0h]
00007FF91DFD9614  F3 0F 59 9B E0 B1 00 00     mulss   xmm3, dword ptr [rbx+0B1E0h]
00007FF91DFD961C  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD961F  F3 0F 59 83 F0 B1 00 00     mulss   xmm0, dword ptr [rbx+0B1F0h]
00007FF91DFD9627  F3 0F 11 9B E0 B0 00 00     movss   dword ptr [rbx+0B0E0h], xmm3
00007FF91DFD962F  F3 0F 11 83 F0 B0 00 00     movss   dword ptr [rbx+0B0F0h], xmm0
00007FF91DFD9637  8B 83 00 B2 00 00           mov     eax, [rbx+0B200h]
00007FF91DFD963D  89 83 10 B2 00 00           mov     [rbx+0B210h], eax
00007FF91DFD9643  8B 83 20 B2 00 00           mov     eax, [rbx+0B220h]
00007FF91DFD9649  89 83 30 B2 00 00           mov     [rbx+0B230h], eax
00007FF91DFD964F  F3 0F 10 83 30 A7 00 00     movss   xmm0, dword ptr [rbx+0A730h]
00007FF91DFD9657  F3 44 0F 10 83 B0 A7 00 00  movss   xmm8, dword ptr [rbx+0A7B0h]
00007FF91DFD9660  8B 83 60 B2 00 00           mov     eax, [rbx+0B260h]
00007FF91DFD9666  89 83 70 B2 00 00           mov     [rbx+0B270h], eax
00007FF91DFD966C  F3 0F 59 83 40 B2 00 00     mulss   xmm0, dword ptr [rbx+0B240h]
00007FF91DFD9674  F3 44 0F 59 83 50 B2 00 00  mulss   xmm8, dword ptr [rbx+0B250h]
00007FF91DFD967D  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFD9682  F3 44 0F 11 83 60 B2 00 00  movss   dword ptr [rbx+0B260h], xmm8
00007FF91DFD968B  F3 0F 10 BB 40 AB 00 00     movss   xmm7, dword ptr [rbx+0AB40h]
00007FF91DFD9693  F3 0F 10 8B 00 AF 00 00     movss   xmm1, dword ptr [rbx+0AF00h]
00007FF91DFD969B  F3 0F 10 93 E0 B0 00 00     movss   xmm2, dword ptr [rbx+0B0E0h]
00007FF91DFD96A3  F3 0F 10 83 30 A7 00 00     movss   xmm0, dword ptr [rbx+0A730h]
00007FF91DFD96AB  8B 83 20 B2 00 00           mov     eax, [rbx+0B220h]
00007FF91DFD96B1  89 83 A0 B2 00 00           mov     [rbx+0B2A0h], eax
00007FF91DFD96B7  F3 0F 11 83 B0 B2 00 00     movss   dword ptr [rbx+0B2B0h], xmm0
00007FF91DFD96BF  F3 0F 10 A3 F0 B3 00 00     movss   xmm4, dword ptr [rbx+0B3F0h]
00007FF91DFD96C7  F3 0F 11 8B 80 B2 00 00     movss   dword ptr [rbx+0B280h], xmm1
00007FF91DFD96CF  F3 0F 11 93 90 B2 00 00     movss   dword ptr [rbx+0B290h], xmm2
00007FF91DFD96D7  F3 0F 10 AB D0 B3 00 00     movss   xmm5, dword ptr [rbx+0B3D0h]
00007FF91DFD96DF  F3 0F 59 FC                 mulss   xmm7, xmm4
00007FF91DFD96E3  F3 0F 59 A3 50 AB 00 00     mulss   xmm4, dword ptr [rbx+0AB50h]
00007FF91DFD96EB  F3 0F 11 A3 C0 B2 00 00     movss   dword ptr [rbx+0B2C0h], xmm4
00007FF91DFD96F3  F3 0F 10 8B 50 B3 00 00     movss   xmm1, dword ptr [rbx+0B350h]
00007FF91DFD96FB  F3 0F 10 93 50 B4 00 00     movss   xmm2, dword ptr [rbx+0B450h]
00007FF91DFD9703  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFD9706  F3 0F 59 BB 00 B4 00 00     mulss   xmm7, dword ptr [rbx+0B400h]
00007FF91DFD970E  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD9711  F3 0F 10 B3 10 B4 00 00     movss   xmm6, dword ptr [rbx+0B410h]
00007FF91DFD9719  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD971D  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFD9721  F3 0F 59 EC                 mulss   xmm5, xmm4
00007FF91DFD9725  F3 0F 59 AB E0 B3 00 00     mulss   xmm5, dword ptr [rbx+0B3E0h]
00007FF91DFD972D  F3 0F 11 AB E0 B2 00 00     movss   dword ptr [rbx+0B2E0h], xmm5
00007FF91DFD9735  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFD9739  F3 0F 59 9B A0 B2 00 00     mulss   xmm3, dword ptr [rbx+0B2A0h]
00007FF91DFD9741  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD9745  F3 0F 10 83 60 B3 00 00     movss   xmm0, dword ptr [rbx+0B360h]
00007FF91DFD974D  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFD9751  F3 0F 59 9B 60 B4 00 00     mulss   xmm3, dword ptr [rbx+0B460h]
00007FF91DFD9759  F3 0F 11 9B F0 B2 00 00     movss   dword ptr [rbx+0B2F0h], xmm3
00007FF91DFD9761  F3 0F 10 8B 30 B4 00 00     movss   xmm1, dword ptr [rbx+0B430h]
00007FF91DFD9769  F3 0F 59 8B 90 B2 00 00     mulss   xmm1, dword ptr [rbx+0B290h]
00007FF91DFD9771  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD9775  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFD9779  F3 0F 10 83 20 B4 00 00     movss   xmm0, dword ptr [rbx+0B420h]
00007FF91DFD9781  F3 0F 59 83 80 B2 00 00     mulss   xmm0, dword ptr [rbx+0B280h]
00007FF91DFD9789  F3 0F 10 9B C0 B2 00 00     movss   xmm3, dword ptr [rbx+0B2C0h]
00007FF91DFD9791  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD9795  F3 0F 10 83 40 B3 00 00     movss   xmm0, dword ptr [rbx+0B340h]
00007FF91DFD979D  F3 0F 59 8B 40 B4 00 00     mulss   xmm1, dword ptr [rbx+0B440h]
00007FF91DFD97A5  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFD97A9  F3 41 0F 58 C8              addss   xmm1, xmm8
00007FF91DFD97AE  F3 0F 58 8B B0 B3 00 00     addss   xmm1, dword ptr [rbx+0B3B0h]
00007FF91DFD97B6  F3 0F 58 8B C0 B3 00 00     addss   xmm1, dword ptr [rbx+0B3C0h]
00007FF91DFD97BE  F3 0F 11 8B 00 B3 00 00     movss   dword ptr [rbx+0B300h], xmm1
00007FF91DFD97C6  F3 0F 11 83 10 B3 00 00     movss   dword ptr [rbx+0B310h], xmm0
00007FF91DFD97CE  F3 0F 59 9B 80 B4 00 00     mulss   xmm3, dword ptr [rbx+0B480h]
00007FF91DFD97D6  F3 0F 10 83 80 B3 00 00     movss   xmm0, dword ptr [rbx+0B380h]
00007FF91DFD97DE  F3 0F 59 83 80 B2 00 00     mulss   xmm0, dword ptr [rbx+0B280h]
00007FF91DFD97E6  F3 0F 58 9B 90 B4 00 00     addss   xmm3, dword ptr [rbx+0B490h]
00007FF91DFD97EE  F3 0F 10 8B 90 B3 00 00     movss   xmm1, dword ptr [rbx+0B390h]
00007FF91DFD97F6  F3 0F 59 8B 90 B2 00 00     mulss   xmm1, dword ptr [rbx+0B290h]
00007FF91DFD97FE  F3 0F 10 93 E0 B2 00 00     movss   xmm2, dword ptr [rbx+0B2E0h]
00007FF91DFD9806  F3 0F 59 9B 70 B3 00 00     mulss   xmm3, dword ptr [rbx+0B370h]
00007FF91DFD980E  F3 0F 58 93 B0 B2 00 00     addss   xmm2, dword ptr [rbx+0B2B0h]
00007FF91DFD9816  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD981A  F3 0F 58 93 F0 B2 00 00     addss   xmm2, dword ptr [rbx+0B2F0h]
00007FF91DFD9822  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD9826  F3 0F 58 9B A0 B3 00 00     addss   xmm3, dword ptr [rbx+0B3A0h]
00007FF91DFD982E  F3 0F 59 9B 70 B4 00 00     mulss   xmm3, dword ptr [rbx+0B470h]
00007FF91DFD9836  F3 0F 11 9B 20 B3 00 00     movss   dword ptr [rbx+0B320h], xmm3
00007FF91DFD983E  F3 0F 11 93 30 B3 00 00     movss   dword ptr [rbx+0B330h], xmm2
00007FF91DFD9846  F3 0F 10 83 B0 B4 00 00     movss   xmm0, dword ptr [rbx+0B4B0h]
00007FF91DFD984E  8B 83 A0 B4 00 00           mov     eax, [rbx+0B4A0h]
00007FF91DFD9854  89 83 D0 B4 00 00           mov     [rbx+0B4D0h], eax
00007FF91DFD985A  F3 0F 11 83 E0 B4 00 00     movss   dword ptr [rbx+0B4E0h], xmm0
00007FF91DFD9862  8B 83 C0 B4 00 00           mov     eax, [rbx+0B4C0h]
00007FF91DFD9868  89 83 F0 B4 00 00           mov     [rbx+0B4F0h], eax
00007FF91DFD986E  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
00007FF91DFD9876  8B 83 10 B5 00 00           mov     eax, [rbx+0B510h]
00007FF91DFD987C  89 83 20 B5 00 00           mov     [rbx+0B520h], eax
00007FF91DFD9882  F3 0F 10 93 00 B5 00 00     movss   xmm2, dword ptr [rbx+0B500h]
00007FF91DFD988A  F3 0F 11 93 10 B5 00 00     movss   dword ptr [rbx+0B510h], xmm2
00007FF91DFD9892  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD9895  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD9898  F3 0F 59 9B 30 B5 00 00     mulss   xmm3, dword ptr [rbx+0B530h]
00007FF91DFD98A0  F3 0F 58 9B 20 B5 00 00     addss   xmm3, dword ptr [rbx+0B520h]
00007FF91DFD98A8  F3 0F 11 9B 10 B5 00 00     movss   dword ptr [rbx+0B510h], xmm3
00007FF91DFD98B0  F3 0F 59 83 40 B5 00 00     mulss   xmm0, dword ptr [rbx+0B540h]
00007FF91DFD98B8  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFD98BC  F3 0F 59 9B 70 B5 00 00     mulss   xmm3, dword ptr [rbx+0B570h]
00007FF91DFD98C4  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFD98C8  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFD98CB  F3 0F 59 8B 30 B5 00 00     mulss   xmm1, dword ptr [rbx+0B530h]
00007FF91DFD98D3  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD98D7  F3 0F 11 8B 00 B5 00 00     movss   dword ptr [rbx+0B500h], xmm1
00007FF91DFD98DF  F3 0F 59 8B 60 B5 00 00     mulss   xmm1, dword ptr [rbx+0B560h]
00007FF91DFD98E7  F3 0F 59 A3 50 B5 00 00     mulss   xmm4, dword ptr [rbx+0B550h]
00007FF91DFD98EF  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFD98F3  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFD98F7  F3 0F 11 A3 20 B5 00 00     movss   dword ptr [rbx+0B520h], xmm4
00007FF91DFD98FF  8B 83 50 BD 00 00           mov     eax, [rbx+0BD50h]
00007FF91DFD9905  89 83 60 BD 00 00           mov     [rbx+0BD60h], eax
00007FF91DFD990B  F3 0F 10 8B 70 BD 00 00     movss   xmm1, dword ptr [rbx+0BD70h]
00007FF91DFD9913  F3 0F 11 8B 80 BD 00 00     movss   dword ptr [rbx+0BD80h], xmm1
00007FF91DFD991B  F3 0F 59 8B 10 B2 00 00     mulss   xmm1, dword ptr [rbx+0B210h]
00007FF91DFD9923  F3 0F 10 83 60 BD 00 00     movss   xmm0, dword ptr [rbx+0BD60h]
00007FF91DFD992B  F3 0F 59 83 20 B5 00 00     mulss   xmm0, dword ptr [rbx+0B520h]
00007FF91DFD9933  F3 0F 11 8B 90 BD 00 00     movss   dword ptr [rbx+0BD90h], xmm1
00007FF91DFD993B  F3 0F 11 83 A0 BD 00 00     movss   dword ptr [rbx+0BDA0h], xmm0
00007FF91DFD9943  8B 83 D0 BD 00 00           mov     eax, [rbx+0BDD0h]
00007FF91DFD9949  89 83 E0 BD 00 00           mov     [rbx+0BDE0h], eax
00007FF91DFD994F  F3 0F 59 8B B0 BD 00 00     mulss   xmm1, dword ptr [rbx+0BDB0h]
00007FF91DFD9957  F3 0F 59 83 C0 BD 00 00     mulss   xmm0, dword ptr [rbx+0BDC0h]
00007FF91DFD995F  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFD9963  F3 0F 11 83 D0 BD 00 00     movss   dword ptr [rbx+0BDD0h], xmm0
00007FF91DFD996B  8B 83 F0 BD 00 00           mov     eax, [rbx+0BDF0h]
00007FF91DFD9971  89 83 00 BE 00 00           mov     [rbx+0BE00h], eax
00007FF91DFD9977  8B 83 10 BE 00 00           mov     eax, [rbx+0BE10h]
00007FF91DFD997D  89 83 20 BE 00 00           mov     [rbx+0BE20h], eax
00007FF91DFD9983  8B 83 30 BE 00 00           mov     eax, [rbx+0BE30h]
00007FF91DFD9989  89 83 40 BE 00 00           mov     [rbx+0BE40h], eax
00007FF91DFD998F  8B 83 50 BE 00 00           mov     eax, [rbx+0BE50h]
00007FF91DFD9995  89 83 60 BE 00 00           mov     [rbx+0BE60h], eax
00007FF91DFD999B  F3 0F 10 8B 80 BE 00 00     movss   xmm1, dword ptr [rbx+0BE80h]
00007FF91DFD99A3  F3 0F 10 93 90 BE 00 00     movss   xmm2, dword ptr [rbx+0BE90h]
00007FF91DFD99AB  0F 28 E1                    movaps  xmm4, xmm1
00007FF91DFD99AE  F3 0F 59 A3 F0 BD 00 00     mulss   xmm4, dword ptr [rbx+0BDF0h]
00007FF91DFD99B6  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD99B9  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD99BD  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFD99C1  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFD99C5  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD99C8  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFD99CB  F3 0F 59 8B B0 BE 00 00     mulss   xmm1, dword ptr [rbx+0BEB0h]
00007FF91DFD99D3  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD99D7  F3 0F 58 8B A0 BE 00 00     addss   xmm1, dword ptr [rbx+0BEA0h]
00007FF91DFD99DF  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD99E2  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD99E6  F3 0F 59 83 C0 BE 00 00     mulss   xmm0, dword ptr [rbx+0BEC0h]
00007FF91DFD99EE  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD99F2  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD99F5  F3 0F 59 9B D0 BE 00 00     mulss   xmm3, dword ptr [rbx+0BED0h]
00007FF91DFD99FD  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFD9A01  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFD9A05  F3 0F 59 83 E0 BE 00 00     mulss   xmm0, dword ptr [rbx+0BEE0h]
00007FF91DFD9A0D  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFD9A11  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFD9A15  76 05                       jbe     short loc_7FF91DFD9A1C
00007FF91DFD9A17  0F 5A C0                    cvtps2pd xmm0, xmm0
00007FF91DFD9A1A  EB 03                       jmp     short loc_7FF91DFD9A1F
00007FF91DFD9A1C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFD9A1F  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFD9A23  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFD9A27  73 04                       jnb     short loc_7FF91DFD9A2D
00007FF91DFD9A29  44 0F 5A E1                 cvtps2pd xmm12, xmm1
00007FF91DFD9A2D  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
00007FF91DFD9A32  F3 0F 11 83 70 BE 00 00     movss   dword ptr [rbx+0BE70h], xmm0
00007FF91DFD9A3A  8B 83 F0 BE 00 00           mov     eax, [rbx+0BEF0h]
00007FF91DFD9A40  89 83 00 BF 00 00           mov     [rbx+0BF00h], eax
00007FF91DFD9A46  F3 0F 10 8B 10 BF 00 00     movss   xmm1, dword ptr [rbx+0BF10h]
00007FF91DFD9A4E  F3 0F 11 8B 20 BF 00 00     movss   dword ptr [rbx+0BF20h], xmm1
00007FF91DFD9A56  F3 0F 10 83 30 BF 00 00     movss   xmm0, dword ptr [rbx+0BF30h]
00007FF91DFD9A5E  F3 0F 11 83 40 BF 00 00     movss   dword ptr [rbx+0BF40h], xmm0
00007FF91DFD9A66  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFD9A6A  F3 0F 59 8B 50 BF 00 00     mulss   xmm1, dword ptr [rbx+0BF50h]
00007FF91DFD9A72  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD9A76  F3 0F 11 8B 30 BF 00 00     movss   dword ptr [rbx+0BF30h], xmm1
00007FF91DFD9A7E  F3 0F 10 8B 30 A7 00 00     movss   xmm1, dword ptr [rbx+0A730h]
00007FF91DFD9A86  F3 0F 10 83 B0 A7 00 00     movss   xmm0, dword ptr [rbx+0A7B0h]
00007FF91DFD9A8E  8B 83 80 BF 00 00           mov     eax, [rbx+0BF80h]
00007FF91DFD9A94  89 83 90 BF 00 00           mov     [rbx+0BF90h], eax
00007FF91DFD9A9A  F3 0F 59 83 70 BF 00 00     mulss   xmm0, dword ptr [rbx+0BF70h]
00007FF91DFD9AA2  F3 0F 59 8B 60 BF 00 00     mulss   xmm1, dword ptr [rbx+0BF60h]
00007FF91DFD9AAA  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFD9AAE  F3 0F 11 83 80 BF 00 00     movss   dword ptr [rbx+0BF80h], xmm0
00007FF91DFD9AB6  8B 83 A0 BF 00 00           mov     eax, [rbx+0BFA0h]
00007FF91DFD9ABC  89 83 C0 BF 00 00           mov     [rbx+0BFC0h], eax
00007FF91DFD9AC2  F3 0F 10 9B B0 BF 00 00     movss   xmm3, dword ptr [rbx+0BFB0h]
00007FF91DFD9ACA  F3 0F 11 9B D0 BF 00 00     movss   dword ptr [rbx+0BFD0h], xmm3
00007FF91DFD9AD2  F3 0F 10 8B C0 BF 00 00     movss   xmm1, dword ptr [rbx+0BFC0h]
00007FF91DFD9ADA  F3 0F 10 93 00 AF 00 00     movss   xmm2, dword ptr [rbx+0AF00h]
00007FF91DFD9AE2  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD9AE5  F3 0F 59 83 E0 B0 00 00     mulss   xmm0, dword ptr [rbx+0B0E0h]
00007FF91DFD9AED  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD9AF1  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFD9AF5  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD9AF8  F3 0F 59 8B 30 BE 00 00     mulss   xmm1, dword ptr [rbx+0BE30h]
00007FF91DFD9B00  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD9B04  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFD9B08  F3 0F 5C CB                 subss   xmm1, xmm3
00007FF91DFD9B0C  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFD9B10  F3 0F 11 8B E0 BF 00 00     movss   dword ptr [rbx+0BFE0h], xmm1
00007FF91DFD9B18  F3 0F 10 9B 40 AB 00 00     movss   xmm3, dword ptr [rbx+0AB40h]
00007FF91DFD9B20  F3 0F 10 83 F0 BF 00 00     movss   xmm0, dword ptr [rbx+0BFF0h]
00007FF91DFD9B28  F3 0F 11 83 00 C0 00 00     movss   dword ptr [rbx+0C000h], xmm0
00007FF91DFD9B30  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFD9B34  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD9B37  F3 0F 59 8B 10 C0 00 00     mulss   xmm1, dword ptr [rbx+0C010h]
00007FF91DFD9B3F  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD9B43  F3 0F 10 83 30 C0 00 00     movss   xmm0, dword ptr [rbx+0C030h]
00007FF91DFD9B4B  F3 0F 11 8B F0 BF 00 00     movss   dword ptr [rbx+0BFF0h], xmm1
00007FF91DFD9B53  F3 0F 59 9B 20 C0 00 00     mulss   xmm3, dword ptr [rbx+0C020h]
00007FF91DFD9B5B  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD9B5F  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFD9B63  F3 0F 11 9B 00 C0 00 00     movss   dword ptr [rbx+0C000h], xmm3
00007FF91DFD9B6B  F3 0F 10 83 40 C0 00 00     movss   xmm0, dword ptr [rbx+0C040h]
00007FF91DFD9B73  F3 0F 10 BB 50 AB 00 00     movss   xmm7, dword ptr [rbx+0AB50h]
00007FF91DFD9B7B  F3 0F 11 83 50 C0 00 00     movss   dword ptr [rbx+0C050h], xmm0
00007FF91DFD9B83  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFD9B87  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFD9B8A  F3 0F 59 8B 60 C0 00 00     mulss   xmm1, dword ptr [rbx+0C060h]
00007FF91DFD9B92  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD9B96  F3 0F 10 83 80 C0 00 00     movss   xmm0, dword ptr [rbx+0C080h]
00007FF91DFD9B9E  F3 0F 11 8B 40 C0 00 00     movss   dword ptr [rbx+0C040h], xmm1
00007FF91DFD9BA6  F3 0F 59 BB 70 C0 00 00     mulss   xmm7, dword ptr [rbx+0C070h]
00007FF91DFD9BAE  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD9BB2  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFD9BB6  F3 0F 11 BB 50 C0 00 00     movss   dword ptr [rbx+0C050h], xmm7
00007FF91DFD9BBE  F3 0F 10 A3 00 C0 00 00     movss   xmm4, dword ptr [rbx+0C000h]
00007FF91DFD9BC6  F3 0F 10 AB E0 BF 00 00     movss   xmm5, dword ptr [rbx+0BFE0h]
00007FF91DFD9BCE  F3 0F 10 B3 80 BF 00 00     movss   xmm6, dword ptr [rbx+0BF80h]
00007FF91DFD9BD6  F3 44 0F 10 8B 10 BE 00 00  movss   xmm9, dword ptr [rbx+0BE10h]
00007FF91DFD9BDF  8B 83 30 BF 00 00           mov     eax, [rbx+0BF30h]
00007FF91DFD9BE5  89 83 90 C0 00 00           mov     [rbx+0C090h], eax
00007FF91DFD9BEB  F3 44 0F 11 8B A0 C0 00 00  movss   dword ptr [rbx+0C0A0h], xmm9
00007FF91DFD9BF4  F3 0F 10 83 C0 C0 00 00     movss   xmm0, dword ptr [rbx+0C0C0h]
00007FF91DFD9BFC  F3 0F 10 93 D0 C0 00 00     movss   xmm2, dword ptr [rbx+0C0D0h]
00007FF91DFD9C04  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFD9C08  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFD9C0B  F3 0F 59 9B 50 BE 00 00     mulss   xmm3, dword ptr [rbx+0BE50h]
00007FF91DFD9C13  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFD9C17  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD9C1A  F3 0F 59 C7                 mulss   xmm0, xmm7
00007FF91DFD9C1E  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFD9C22  F3 44 0F 5C C0              subss   xmm8, xmm0
00007FF91DFD9C27  F3 44 0F 58 C7              addss   xmm8, xmm7
00007FF91DFD9C2C  F3 44 0F 59 83 00 C1 00 00  mulss   xmm8, dword ptr [rbx+0C100h]
00007FF91DFD9C35  F3 0F 10 8B E0 C0 00 00     movss   xmm1, dword ptr [rbx+0C0E0h]
00007FF91DFD9C3D  F3 0F 58 B3 80 C1 00 00     addss   xmm6, dword ptr [rbx+0C180h]
00007FF91DFD9C45  F3 44 0F 59 83 10 C1 00 00  mulss   xmm8, dword ptr [rbx+0C110h]
00007FF91DFD9C4E  F3 0F 59 AB 20 C1 00 00     mulss   xmm5, dword ptr [rbx+0C120h]
00007FF91DFD9C56  F3 0F 59 B3 30 C1 00 00     mulss   xmm6, dword ptr [rbx+0C130h]
00007FF91DFD9C5E  F3 44 0F 59 C9              mulss   xmm9, xmm1
00007FF91DFD9C63  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFD9C67  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFD9C6B  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFD9C6F  F3 0F 10 93 60 C1 00 00     movss   xmm2, dword ptr [rbx+0C160h]
00007FF91DFD9C77  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFD9C7A  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFD9C7E  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFD9C82  F3 44 0F 5C C8              subss   xmm9, xmm0
00007FF91DFD9C87  F3 0F 10 83 50 C1 00 00     movss   xmm0, dword ptr [rbx+0C150h]
00007FF91DFD9C8F  F3 0F 58 83 90 C0 00 00     addss   xmm0, dword ptr [rbx+0C090h]
00007FF91DFD9C97  F3 0F 59 9B F0 C0 00 00     mulss   xmm3, dword ptr [rbx+0C0F0h]
00007FF91DFD9C9F  F3 0F 59 83 90 C1 00 00     mulss   xmm0, dword ptr [rbx+0C190h]
00007FF91DFD9CA7  F3 44 0F 58 CA              addss   xmm9, xmm2
00007FF91DFD9CAC  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFD9CB1  F3 0F 59 83 40 C1 00 00     mulss   xmm0, dword ptr [rbx+0C140h]
00007FF91DFD9CB9  F3 44 0F 59 8B 70 C1 00 00  mulss   xmm9, dword ptr [rbx+0C170h]
00007FF91DFD9CC2  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFD9CC7  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFD9CCC  F3 45 0F 58 C8              addss   xmm9, xmm8
00007FF91DFD9CD1  F3 44 0F 11 8B B0 C0 00 00  movss   dword ptr [rbx+0C0B0h], xmm9
00007FF91DFD9CDA  F3 0F 10 BB 70 BE 00 00     movss   xmm7, dword ptr [rbx+0BE70h]
00007FF91DFD9CE2  F3 44 0F 10 83 00 BF 00 00  movss   xmm8, dword ptr [rbx+0BF00h]
00007FF91DFD9CEB  8B 83 D0 C1 00 00           mov     eax, [rbx+0C1D0h]
00007FF91DFD9CF1  89 83 E0 C1 00 00           mov     [rbx+0C1E0h], eax
00007FF91DFD9CF7  F3 0F 10 83 C0 C1 00 00     movss   xmm0, dword ptr [rbx+0C1C0h]
00007FF91DFD9CFF  F3 0F 11 83 D0 C1 00 00     movss   dword ptr [rbx+0C1D0h], xmm0
00007FF91DFD9D07  44 0F 2E AB 10 C2 00 00     ucomiss xmm13, dword ptr [rbx+0C210h]
00007FF91DFD9D0F  0F 85 8F 02 00 00           jnz     loc_7FF91DFD9FA4
00007FF91DFD9D15  F3 0F 10 8B 60 C2 00 00     movss   xmm1, dword ptr [rbx+0C260h]
00007FF91DFD9D1D  F3 0F 10 B3 E0 C1 00 00     movss   xmm6, dword ptr [rbx+0C1E0h]
00007FF91DFD9D25  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFD9D28  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFD9D2C  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFD9D30  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFD9D34  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFD9D38  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFD9D3C  F3 0F 11 B3 D0 C1 00 00     movss   dword ptr [rbx+0C1D0h], xmm6
00007FF91DFD9D44  F3 0F 59 B3 50 C2 00 00     mulss   xmm6, dword ptr [rbx+0C250h]
00007FF91DFD9D4C  F3 0F 58 B3 F0 C1 00 00     addss   xmm6, dword ptr [rbx+0C1F0h]
00007FF91DFD9D54  E8 07 F0 FE FF              call    sub_7FF91DFC8D60
00007FF91DFD9D59  F3 0F 11 83 C0 C1 00 00     movss   dword ptr [rbx+0C1C0h], xmm0
00007FF91DFD9D61  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFD9D65  F3 0F 59 8B B0 C2 00 00     mulss   xmm1, dword ptr [rbx+0C2B0h]
00007FF91DFD9D6D  41 0F 28 D5                 movaps  xmm2, xmm13
00007FF91DFD9D71  F3 41 0F 5C D0              subss   xmm2, xmm8
00007FF91DFD9D76  F3 0F 58 8B 00 C2 00 00     addss   xmm1, dword ptr [rbx+0C200h]
00007FF91DFD9D7E  F3 0F 59 93 70 C2 00 00     mulss   xmm2, dword ptr [rbx+0C270h]
00007FF91DFD9D86  F3 0F 11 8B B0 C1 00 00     movss   dword ptr [rbx+0C1B0h], xmm1
00007FF91DFD9D8E  F3 44 0F 59 8B 40 C2 00 00  mulss   xmm9, dword ptr [rbx+0C240h]
00007FF91DFD9D97  F3 0F 59 BB 20 C2 00 00     mulss   xmm7, dword ptr [rbx+0C220h]
00007FF91DFD9D9F  F3 0F 10 83 80 C2 00 00     movss   xmm0, dword ptr [rbx+0C280h]
00007FF91DFD9DA7  F3 0F 5D C2                 minss   xmm0, xmm2
00007FF91DFD9DAB  F3 44 0F 58 CF              addss   xmm9, xmm7
00007FF91DFD9DB0  F3 44 0F 58 CE              addss   xmm9, xmm6
00007FF91DFD9DB5  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFD9DBA  F3 44 0F 58 8B 30 C2 00 00  addss   xmm9, dword ptr [rbx+0C230h]
00007FF91DFD9DC3  F3 44 0F 5D 8B 90 C2 00 00  minss   xmm9, dword ptr [rbx+0C290h]
00007FF91DFD9DCC  F3 44 0F 5F 8B A0 C2 00 00  maxss   xmm9, dword ptr [rbx+0C2A0h]
00007FF91DFD9DD5  F3 44 0F 59 8B D0 C2 00 00  mulss   xmm9, dword ptr [rbx+0C2D0h]
00007FF91DFD9DDE  F3 44 0F 58 8B E0 C2 00 00  addss   xmm9, dword ptr [rbx+0C2E0h]
00007FF91DFD9DE7  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFD9DEB  F3 0F 2C C9                 cvttss2si ecx, xmm1
00007FF91DFD9DEF  81 F9 00 00 00 80           cmp     ecx, 80000000h
00007FF91DFD9DF5  74 1E                       jz      short loc_7FF91DFD9E15
00007FF91DFD9DF7  66 0F 6E C1                 movd    xmm0, ecx
00007FF91DFD9DFB  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFD9DFE  0F 2E C1                    ucomiss xmm0, xmm1
00007FF91DFD9E01  74 12                       jz      short loc_7FF91DFD9E15
00007FF91DFD9E03  0F 14 C9                    unpcklps xmm1, xmm1
00007FF91DFD9E06  0F 50 C1                    movmskps eax, xmm1
00007FF91DFD9E09  83 E0 01                    and     eax, 1
00007FF91DFD9E0C  2B C8                       sub     ecx, eax
00007FF91DFD9E0E  66 0F 6E C9                 movd    xmm1, ecx
00007FF91DFD9E12  0F 5B C9                    cvtdq2ps xmm1, xmm1
00007FF91DFD9E15  F3 44 0F 5C C9              subss   xmm9, xmm1
00007FF91DFD9E1A  0F 28 C1                    movaps  xmm0, xmm1; X
00007FF91DFD9E1D  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFD9E21  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFD9E26  F3 0F 59 35 A2 B1 76 00     mulss   xmm6, cs:dword_7FF91E744FD0
00007FF91DFD9E2E  E8 0D 59 37 00              call    expf
00007FF91DFD9E33  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFD9E36  41 0F 28 D1                 movaps  xmm2, xmm9
00007FF91DFD9E3A  F3 0F 59 93 A0 C3 00 00     mulss   xmm2, dword ptr [rbx+0C3A0h]
00007FF91DFD9E42  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFD9E46  F3 0F 59 8B 80 C3 00 00     mulss   xmm1, dword ptr [rbx+0C380h]
00007FF91DFD9E4E  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFD9E52  F3 0F 58 93 90 C3 00 00     addss   xmm2, dword ptr [rbx+0C390h]
00007FF91DFD9E5A  F3 0F 59 83 60 C3 00 00     mulss   xmm0, dword ptr [rbx+0C360h]
00007FF91DFD9E62  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD9E66  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFD9E6A  F3 0F 58 93 70 C3 00 00     addss   xmm2, dword ptr [rbx+0C370h]
00007FF91DFD9E72  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD9E76  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD9E7A  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFD9E7E  F3 0F 59 83 40 C3 00 00     mulss   xmm0, dword ptr [rbx+0C340h]
00007FF91DFD9E86  F3 0F 58 93 50 C3 00 00     addss   xmm2, dword ptr [rbx+0C350h]
00007FF91DFD9E8E  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD9E92  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD9E96  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFD9E9A  F3 0F 59 83 20 C3 00 00     mulss   xmm0, dword ptr [rbx+0C320h]
00007FF91DFD9EA2  F3 44 0F 59 8B 00 C3 00 00  mulss   xmm9, dword ptr [rbx+0C300h]
00007FF91DFD9EAB  F3 0F 58 93 30 C3 00 00     addss   xmm2, dword ptr [rbx+0C330h]
00007FF91DFD9EB3  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD9EB7  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFD9EBB  F3 0F 58 93 10 C3 00 00     addss   xmm2, dword ptr [rbx+0C310h]
00007FF91DFD9EC3  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFD9EC7  F3 41 0F 58 D1              addss   xmm2, xmm9
00007FF91DFD9ECC  F3 41 0F 58 D5              addss   xmm2, xmm13
00007FF91DFD9ED1  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFD9ED5  F3 0F 59 A3 F0 C2 00 00     mulss   xmm4, dword ptr [rbx+0C2F0h]
00007FF91DFD9EDD  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFD9EE0  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFD9EE4  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD9EE7  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFD9EEB  F3 44 0F 59 83 40 C4 00 00  mulss   xmm8, dword ptr [rbx+0C440h]
00007FF91DFD9EF4  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD9EF7  F3 0F 59 83 00 C4 00 00     mulss   xmm0, dword ptr [rbx+0C400h]
00007FF91DFD9EFF  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFD9F02  F3 44 0F 58 83 20 C4 00 00  addss   xmm8, dword ptr [rbx+0C420h]
00007FF91DFD9F0B  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFD9F0F  F3 0F 58 83 E0 C3 00 00     addss   xmm0, dword ptr [rbx+0C3E0h]
00007FF91DFD9F17  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFD9F1B  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFD9F20  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFD9F25  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFD9F28  F3 0F 59 8B C0 C3 00 00     mulss   xmm1, dword ptr [rbx+0C3C0h]
00007FF91DFD9F30  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFD9F34  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFD9F39  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFD9F3C  F3 0F 59 83 F0 C3 00 00     mulss   xmm0, dword ptr [rbx+0C3F0h]
00007FF91DFD9F44  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFD9F49  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFD9F4C  F3 0F 59 8B 30 C4 00 00     mulss   xmm1, dword ptr [rbx+0C430h]
00007FF91DFD9F54  F3 0F 59 9B B0 C3 00 00     mulss   xmm3, dword ptr [rbx+0C3B0h]
00007FF91DFD9F5C  F3 0F 58 8B 10 C4 00 00     addss   xmm1, dword ptr [rbx+0C410h]
00007FF91DFD9F64  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFD9F69  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD9F6D  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFD9F71  F3 0F 58 8B D0 C3 00 00     addss   xmm1, dword ptr [rbx+0C3D0h]
00007FF91DFD9F79  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFD9F7D  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFD9F81  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFD9F86  F3 44 0F 5E C1              divss   xmm8, xmm1
00007FF91DFD9F8B  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFD9F8F  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFD9F94  F3 44 0F 5E C0              divss   xmm8, xmm0
00007FF91DFD9F99  F3 44 0F 11 83 A0 C1 00 00  movss   dword ptr [rbx+0C1A0h], xmm8
00007FF91DFD9FA2  EB 09                       jmp     short loc_7FF91DFD9FAD
00007FF91DFD9FA4  F3 44 0F 10 83 A0 C1 00 00  movss   xmm8, dword ptr [rbx+0C1A0h]
00007FF91DFD9FAD  8B 83 B0 C4 00 00           mov     eax, [rbx+0C4B0h]
00007FF91DFD9FB3  F3 0F 10 8B D0 BD 00 00     movss   xmm1, dword ptr [rbx+0BDD0h]
00007FF91DFD9FBB  F3 44 0F 10 8B B0 C1 00 00  movss   xmm9, dword ptr [rbx+0C1B0h]
00007FF91DFD9FC4  89 83 C0 C4 00 00           mov     [rbx+0C4C0h], eax
00007FF91DFD9FCA  8B 83 A0 C4 00 00           mov     eax, [rbx+0C4A0h]
00007FF91DFD9FD0  89 83 B0 C4 00 00           mov     [rbx+0C4B0h], eax
00007FF91DFD9FD6  8B 83 90 C4 00 00           mov     eax, [rbx+0C490h]
00007FF91DFD9FDC  89 83 A0 C4 00 00           mov     [rbx+0C4A0h], eax
00007FF91DFD9FE2  8B 83 80 C4 00 00           mov     eax, [rbx+0C480h]
00007FF91DFD9FE8  89 83 90 C4 00 00           mov     [rbx+0C490h], eax
00007FF91DFD9FEE  8B 83 70 C4 00 00           mov     eax, [rbx+0C470h]
00007FF91DFD9FF4  89 83 80 C4 00 00           mov     [rbx+0C480h], eax
00007FF91DFD9FFA  8B 83 60 C4 00 00           mov     eax, [rbx+0C460h]
00007FF91DFDA000  89 83 70 C4 00 00           mov     [rbx+0C470h], eax
00007FF91DFDA006  8B 83 50 C4 00 00           mov     eax, [rbx+0C450h]
00007FF91DFDA00C  89 83 60 C4 00 00           mov     [rbx+0C460h], eax
00007FF91DFDA012  8B 83 90 C5 00 00           mov     eax, [rbx+0C590h]
00007FF91DFDA018  89 83 A0 C5 00 00           mov     [rbx+0C5A0h], eax
00007FF91DFDA01E  8B 83 80 C5 00 00           mov     eax, [rbx+0C580h]
00007FF91DFDA024  89 83 90 C5 00 00           mov     [rbx+0C590h], eax
00007FF91DFDA02A  8B 83 70 C5 00 00           mov     eax, [rbx+0C570h]
00007FF91DFDA030  89 83 80 C5 00 00           mov     [rbx+0C580h], eax
00007FF91DFDA036  8B 83 60 C5 00 00           mov     eax, [rbx+0C560h]
00007FF91DFDA03C  89 83 70 C5 00 00           mov     [rbx+0C570h], eax
00007FF91DFDA042  8B 83 50 C5 00 00           mov     eax, [rbx+0C550h]
00007FF91DFDA048  89 83 60 C5 00 00           mov     [rbx+0C560h], eax
00007FF91DFDA04E  8B 83 40 C5 00 00           mov     eax, [rbx+0C540h]
00007FF91DFDA054  89 83 50 C5 00 00           mov     [rbx+0C550h], eax
00007FF91DFDA05A  8B 83 30 C5 00 00           mov     eax, [rbx+0C530h]
00007FF91DFDA060  89 83 40 C5 00 00           mov     [rbx+0C540h], eax
00007FF91DFDA066  8B 83 10 C6 00 00           mov     eax, [rbx+0C610h]
00007FF91DFDA06C  89 83 20 C6 00 00           mov     [rbx+0C620h], eax
00007FF91DFDA072  8B 83 00 C6 00 00           mov     eax, [rbx+0C600h]
00007FF91DFDA078  89 83 10 C6 00 00           mov     [rbx+0C610h], eax
00007FF91DFDA07E  8B 83 F0 C5 00 00           mov     eax, [rbx+0C5F0h]
00007FF91DFDA084  89 83 00 C6 00 00           mov     [rbx+0C600h], eax
00007FF91DFDA08A  8B 83 E0 C5 00 00           mov     eax, [rbx+0C5E0h]
00007FF91DFDA090  89 83 F0 C5 00 00           mov     [rbx+0C5F0h], eax
00007FF91DFDA096  8B 83 D0 C5 00 00           mov     eax, [rbx+0C5D0h]
00007FF91DFDA09C  89 83 E0 C5 00 00           mov     [rbx+0C5E0h], eax
00007FF91DFDA0A2  8B 83 C0 C5 00 00           mov     eax, [rbx+0C5C0h]
00007FF91DFDA0A8  89 83 D0 C5 00 00           mov     [rbx+0C5D0h], eax
00007FF91DFDA0AE  8B 83 B0 C5 00 00           mov     eax, [rbx+0C5B0h]
00007FF91DFDA0B4  89 83 C0 C5 00 00           mov     [rbx+0C5C0h], eax
00007FF91DFDA0BA  8B 83 90 C6 00 00           mov     eax, [rbx+0C690h]
00007FF91DFDA0C0  89 83 A0 C6 00 00           mov     [rbx+0C6A0h], eax
00007FF91DFDA0C6  8B 83 80 C6 00 00           mov     eax, [rbx+0C680h]
00007FF91DFDA0CC  89 83 90 C6 00 00           mov     [rbx+0C690h], eax
00007FF91DFDA0D2  8B 83 70 C6 00 00           mov     eax, [rbx+0C670h]
00007FF91DFDA0D8  89 83 80 C6 00 00           mov     [rbx+0C680h], eax
00007FF91DFDA0DE  8B 83 60 C6 00 00           mov     eax, [rbx+0C660h]
00007FF91DFDA0E4  89 83 70 C6 00 00           mov     [rbx+0C670h], eax
00007FF91DFDA0EA  8B 83 50 C6 00 00           mov     eax, [rbx+0C650h]
00007FF91DFDA0F0  89 83 60 C6 00 00           mov     [rbx+0C660h], eax
00007FF91DFDA0F6  8B 83 40 C6 00 00           mov     eax, [rbx+0C640h]
00007FF91DFDA0FC  89 83 50 C6 00 00           mov     [rbx+0C650h], eax
00007FF91DFDA102  8B 83 30 C6 00 00           mov     eax, [rbx+0C630h]
00007FF91DFDA108  89 83 40 C6 00 00           mov     [rbx+0C640h], eax
00007FF91DFDA10E  8B 83 10 C7 00 00           mov     eax, [rbx+0C710h]
00007FF91DFDA114  89 83 20 C7 00 00           mov     [rbx+0C720h], eax
00007FF91DFDA11A  8B 83 00 C7 00 00           mov     eax, [rbx+0C700h]
00007FF91DFDA120  89 83 10 C7 00 00           mov     [rbx+0C710h], eax
00007FF91DFDA126  8B 83 F0 C6 00 00           mov     eax, [rbx+0C6F0h]
00007FF91DFDA12C  89 83 00 C7 00 00           mov     [rbx+0C700h], eax
00007FF91DFDA132  8B 83 E0 C6 00 00           mov     eax, [rbx+0C6E0h]
00007FF91DFDA138  89 83 F0 C6 00 00           mov     [rbx+0C6F0h], eax
00007FF91DFDA13E  8B 83 D0 C6 00 00           mov     eax, [rbx+0C6D0h]
00007FF91DFDA144  89 83 E0 C6 00 00           mov     [rbx+0C6E0h], eax
00007FF91DFDA14A  8B 83 C0 C6 00 00           mov     eax, [rbx+0C6C0h]
00007FF91DFDA150  89 83 D0 C6 00 00           mov     [rbx+0C6D0h], eax
00007FF91DFDA156  8B 83 B0 C6 00 00           mov     eax, [rbx+0C6B0h]
00007FF91DFDA15C  89 83 C0 C6 00 00           mov     [rbx+0C6C0h], eax
00007FF91DFDA162  8B 83 30 C7 00 00           mov     eax, [rbx+0C730h]
00007FF91DFDA168  89 83 40 C7 00 00           mov     [rbx+0C740h], eax
00007FF91DFDA16E  F3 0F 10 83 50 C7 00 00     movss   xmm0, dword ptr [rbx+0C750h]
00007FF91DFDA176  F3 0F 11 83 60 C7 00 00     movss   dword ptr [rbx+0C760h], xmm0
00007FF91DFDA17E  44 0F 2E AB A0 C7 00 00     ucomiss xmm13, dword ptr [rbx+0C7A0h]
00007FF91DFDA186  0F 85 49 09 00 00           jnz     loc_7FF91DFDAAD5
00007FF91DFDA18C  F3 0F 59 8B F0 C7 00 00     mulss   xmm1, dword ptr [rbx+0C7F0h]
00007FF91DFDA194  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFDA198  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFDA19C  41 0F 28 F8                 movaps  xmm7, xmm8
00007FF91DFDA1A0  F3 0F 59 B3 10 C8 00 00     mulss   xmm6, dword ptr [rbx+0C810h]
00007FF91DFDA1A8  F3 41 0F 59 F8              mulss   xmm7, xmm8
00007FF91DFDA1AD  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDA1B2  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFDA1B6  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFDA1B9  F3 0F 59 8B E0 C7 00 00     mulss   xmm1, dword ptr [rbx+0C7E0h]
00007FF91DFDA1C1  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFDA1C5  E8 96 EB FE FF              call    sub_7FF91DFC8D60
00007FF91DFDA1CA  F3 0F 11 83 50 C7 00 00     movss   dword ptr [rbx+0C750h], xmm0
00007FF91DFDA1D2  41 0F 28 DD                 movaps  xmm3, xmm13
00007FF91DFDA1D6  F3 0F 11 B3 30 C7 00 00     movss   dword ptr [rbx+0C730h], xmm6
00007FF91DFDA1DE  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFDA1E2  F3 0F 59 FF                 mulss   xmm7, xmm7
00007FF91DFDA1E6  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFDA1EB  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFDA1EF  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFDA1F4  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFDA1F8  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDA1FD  F3 0F 5E DF                 divss   xmm3, xmm7
00007FF91DFDA201  F3 0F 11 9B 80 C7 00 00     movss   dword ptr [rbx+0C780h], xmm3
00007FF91DFDA209  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFDA20C  F3 0F 10 8B 30 C7 00 00     movss   xmm1, dword ptr [rbx+0C730h]
00007FF91DFDA214  F3 0F 10 AB 40 C7 00 00     movss   xmm5, dword ptr [rbx+0C740h]
00007FF91DFDA21C  F3 41 0F 59 E1              mulss   xmm4, xmm9
00007FF91DFDA221  F3 0F 11 A3 70 C7 00 00     movss   dword ptr [rbx+0C770h], xmm4
00007FF91DFDA229  F3 0F 59 AB 40 C8 00 00     mulss   xmm5, dword ptr [rbx+0C840h]
00007FF91DFDA231  F3 0F 10 93 B0 C4 00 00     movss   xmm2, dword ptr [rbx+0C4B0h]
00007FF91DFDA239  F3 0F 59 8B 50 C8 00 00     mulss   xmm1, dword ptr [rbx+0C850h]
00007FF91DFDA241  F3 0F 10 83 C0 C4 00 00     movss   xmm0, dword ptr [rbx+0C4C0h]
00007FF91DFDA249  F3 0F 11 93 20 C5 00 00     movss   dword ptr [rbx+0C520h], xmm2
00007FF91DFDA251  F3 0F 59 93 70 C9 00 00     mulss   xmm2, dword ptr [rbx+0C970h]
00007FF91DFDA259  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDA25D  F3 0F 59 83 80 C9 00 00     mulss   xmm0, dword ptr [rbx+0C980h]
00007FF91DFDA265  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFDA269  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDA26D  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDA271  F3 0F 5C EA                 subss   xmm5, xmm2
00007FF91DFDA275  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDA279  73 06                       jnb     short loc_7FF91DFDA281
00007FF91DFDA27B  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDA27F  EB 05                       jmp     short loc_7FF91DFDA286
00007FF91DFDA281  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDA286  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFDA289  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDA28C  F3 0F 59 83 20 C8 00 00     mulss   xmm0, dword ptr [rbx+0C820h]
00007FF91DFDA294  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDA298  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA29C  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA2A0  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA2A4  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFDA2A8  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDA2AC  F3 0F 11 AB D0 C4 00 00     movss   dword ptr [rbx+0C4D0h], xmm5
00007FF91DFDA2B4  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDA2B7  F3 0F 58 AB 60 C4 00 00     addss   xmm5, dword ptr [rbx+0C460h]
00007FF91DFDA2BF  F3 0F 10 9B 70 C4 00 00     movss   xmm3, dword ptr [rbx+0C470h]
00007FF91DFDA2C7  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDA2CA  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA2CE  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDA2D2  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFDA2D6  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFDA2DA  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDA2DE  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA2E2  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA2E5  F3 0F 11 A3 E0 C4 00 00     movss   dword ptr [rbx+0C4E0h], xmm4
00007FF91DFDA2ED  F3 0F 10 8B 80 C4 00 00     movss   xmm1, dword ptr [rbx+0C480h]
00007FF91DFDA2F5  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFDA2F9  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDA2FD  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDA300  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA304  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFDA308  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDA30C  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFDA310  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDA314  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDA318  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDA31C  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDA320  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA323  F3 0F 11 9B F0 C4 00 00     movss   dword ptr [rbx+0C4F0h], xmm3
00007FF91DFDA32B  F3 0F 10 AB 90 C4 00 00     movss   xmm5, dword ptr [rbx+0C490h]
00007FF91DFDA333  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDA337  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA33B  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDA33E  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA342  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDA346  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDA34A  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFDA34E  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDA352  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDA356  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFDA35A  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDA35E  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA361  F3 0F 11 93 00 C5 00 00     movss   dword ptr [rbx+0C500h], xmm2
00007FF91DFDA369  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFDA36D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDA371  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDA375  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFDA37A  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA37D  F3 0F 59 83 A0 C4 00 00     mulss   xmm0, dword ptr [rbx+0C4A0h]
00007FF91DFDA385  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDA389  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDA38D  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA390  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFDA394  F3 0F 11 AB 10 C5 00 00     movss   dword ptr [rbx+0C510h], xmm5
00007FF91DFDA39C  F3 0F 10 93 00 C5 00 00     movss   xmm2, dword ptr [rbx+0C500h]
00007FF91DFDA3A4  F3 0F 59 93 C0 C7 00 00     mulss   xmm2, dword ptr [rbx+0C7C0h]
00007FF91DFDA3AC  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFDA3B0  F3 0F 59 AB D0 C7 00 00     mulss   xmm5, dword ptr [rbx+0C7D0h]
00007FF91DFDA3B8  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA3BC  F3 0F 10 83 B0 C7 00 00     movss   xmm0, dword ptr [rbx+0C7B0h]
00007FF91DFDA3C4  F3 0F 59 83 F0 C4 00 00     mulss   xmm0, dword ptr [rbx+0C4F0h]
00007FF91DFDA3CC  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFDA3D0  F3 0F 10 AB 40 C7 00 00     movss   xmm5, dword ptr [rbx+0C740h]
00007FF91DFDA3D8  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDA3DC  F3 0F 11 93 B0 C6 00 00     movss   dword ptr [rbx+0C6B0h], xmm2
00007FF91DFDA3E4  F3 0F 58 AB 30 C7 00 00     addss   xmm5, dword ptr [rbx+0C730h]
00007FF91DFDA3EC  F3 0F 10 83 20 C5 00 00     movss   xmm0, dword ptr [rbx+0C520h]
00007FF91DFDA3F4  F3 0F 59 AB 60 C8 00 00     mulss   xmm5, dword ptr [rbx+0C860h]
00007FF91DFDA3FC  F3 0F 59 AB 80 C7 00 00     mulss   xmm5, dword ptr [rbx+0C780h]
00007FF91DFDA404  F3 0F 11 A3 20 C5 00 00     movss   dword ptr [rbx+0C520h], xmm4
00007FF91DFDA40C  F3 0F 59 A3 70 C9 00 00     mulss   xmm4, dword ptr [rbx+0C970h]
00007FF91DFDA414  F3 0F 59 83 80 C9 00 00     mulss   xmm0, dword ptr [rbx+0C980h]
00007FF91DFDA41C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA420  F3 0F 59 A3 70 C7 00 00     mulss   xmm4, dword ptr [rbx+0C770h]
00007FF91DFDA428  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFDA42C  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDA430  73 06                       jnb     short loc_7FF91DFDA438
00007FF91DFDA432  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDA436  EB 05                       jmp     short loc_7FF91DFDA43D
00007FF91DFDA438  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDA43D  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFDA440  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDA443  F3 0F 59 83 20 C8 00 00     mulss   xmm0, dword ptr [rbx+0C820h]
00007FF91DFDA44B  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDA44F  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA453  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA457  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA45B  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFDA45F  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDA463  F3 0F 10 8B D0 C4 00 00     movss   xmm1, dword ptr [rbx+0C4D0h]
00007FF91DFDA46B  F3 0F 11 AB D0 C4 00 00     movss   dword ptr [rbx+0C4D0h], xmm5
00007FF91DFDA473  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDA476  F3 0F 10 9B E0 C4 00 00     movss   xmm3, dword ptr [rbx+0C4E0h]
00007FF91DFDA47E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDA482  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDA485  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA489  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDA48D  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFDA491  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFDA495  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDA499  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA49D  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA4A0  F3 0F 11 A3 E0 C4 00 00     movss   dword ptr [rbx+0C4E0h], xmm4
00007FF91DFDA4A8  F3 0F 10 8B F0 C4 00 00     movss   xmm1, dword ptr [rbx+0C4F0h]
00007FF91DFDA4B0  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFDA4B4  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDA4B8  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDA4BB  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA4BF  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFDA4C3  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDA4C7  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFDA4CB  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDA4CF  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDA4D3  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDA4D7  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDA4DB  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA4DE  F3 0F 11 9B F0 C4 00 00     movss   dword ptr [rbx+0C4F0h], xmm3
00007FF91DFDA4E6  F3 0F 10 AB 00 C5 00 00     movss   xmm5, dword ptr [rbx+0C500h]
00007FF91DFDA4EE  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDA4F2  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA4F6  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDA4F9  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA4FD  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDA501  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDA505  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFDA509  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDA50D  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDA511  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFDA515  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDA519  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA51C  F3 0F 11 93 00 C5 00 00     movss   dword ptr [rbx+0C500h], xmm2
00007FF91DFDA524  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFDA528  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDA52C  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDA530  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFDA535  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA538  F3 0F 59 83 10 C5 00 00     mulss   xmm0, dword ptr [rbx+0C510h]
00007FF91DFDA540  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDA544  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDA548  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA54B  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFDA54F  F3 0F 11 AB 10 C5 00 00     movss   dword ptr [rbx+0C510h], xmm5
00007FF91DFDA557  F3 0F 10 93 00 C5 00 00     movss   xmm2, dword ptr [rbx+0C500h]
00007FF91DFDA55F  F3 0F 59 93 C0 C7 00 00     mulss   xmm2, dword ptr [rbx+0C7C0h]
00007FF91DFDA567  F3 0F 10 8B 30 C7 00 00     movss   xmm1, dword ptr [rbx+0C730h]
00007FF91DFDA56F  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFDA573  F3 0F 59 AB D0 C7 00 00     mulss   xmm5, dword ptr [rbx+0C7D0h]
00007FF91DFDA57B  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA57F  F3 0F 10 83 B0 C7 00 00     movss   xmm0, dword ptr [rbx+0C7B0h]
00007FF91DFDA587  F3 0F 59 83 F0 C4 00 00     mulss   xmm0, dword ptr [rbx+0C4F0h]
00007FF91DFDA58F  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFDA593  F3 0F 10 AB 40 C7 00 00     movss   xmm5, dword ptr [rbx+0C740h]
00007FF91DFDA59B  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDA59F  F3 0F 11 93 30 C6 00 00     movss   dword ptr [rbx+0C630h], xmm2
00007FF91DFDA5A7  F3 0F 59 AB 50 C8 00 00     mulss   xmm5, dword ptr [rbx+0C850h]
00007FF91DFDA5AF  F3 0F 59 8B 40 C8 00 00     mulss   xmm1, dword ptr [rbx+0C840h]
00007FF91DFDA5B7  F3 0F 10 83 20 C5 00 00     movss   xmm0, dword ptr [rbx+0C520h]
00007FF91DFDA5BF  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDA5C3  F3 0F 59 AB 80 C7 00 00     mulss   xmm5, dword ptr [rbx+0C780h]
00007FF91DFDA5CB  F3 0F 11 A3 20 C5 00 00     movss   dword ptr [rbx+0C520h], xmm4
00007FF91DFDA5D3  F3 0F 59 A3 70 C9 00 00     mulss   xmm4, dword ptr [rbx+0C970h]
00007FF91DFDA5DB  F3 0F 59 83 80 C9 00 00     mulss   xmm0, dword ptr [rbx+0C980h]
00007FF91DFDA5E3  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA5E7  F3 0F 59 A3 70 C7 00 00     mulss   xmm4, dword ptr [rbx+0C770h]
00007FF91DFDA5EF  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFDA5F3  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDA5F7  73 06                       jnb     short loc_7FF91DFDA5FF
00007FF91DFDA5F9  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDA5FD  EB 05                       jmp     short loc_7FF91DFDA604
00007FF91DFDA5FF  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDA604  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFDA607  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDA60A  F3 0F 59 83 20 C8 00 00     mulss   xmm0, dword ptr [rbx+0C820h]
00007FF91DFDA612  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDA616  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA61A  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA61E  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA622  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFDA626  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDA62A  F3 0F 10 8B D0 C4 00 00     movss   xmm1, dword ptr [rbx+0C4D0h]
00007FF91DFDA632  F3 0F 11 AB D0 C4 00 00     movss   dword ptr [rbx+0C4D0h], xmm5
00007FF91DFDA63A  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDA63D  F3 0F 10 9B E0 C4 00 00     movss   xmm3, dword ptr [rbx+0C4E0h]
00007FF91DFDA645  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDA649  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDA64C  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA650  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDA654  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFDA658  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFDA65C  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDA660  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA664  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA667  F3 0F 11 A3 E0 C4 00 00     movss   dword ptr [rbx+0C4E0h], xmm4
00007FF91DFDA66F  F3 0F 10 8B F0 C4 00 00     movss   xmm1, dword ptr [rbx+0C4F0h]
00007FF91DFDA677  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFDA67B  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDA67F  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDA682  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA686  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFDA68A  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDA68E  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFDA692  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDA696  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDA69A  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDA69E  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDA6A2  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA6A5  F3 0F 11 9B F0 C4 00 00     movss   dword ptr [rbx+0C4F0h], xmm3
00007FF91DFDA6AD  F3 0F 10 AB 00 C5 00 00     movss   xmm5, dword ptr [rbx+0C500h]
00007FF91DFDA6B5  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDA6B9  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA6BD  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDA6C0  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA6C4  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDA6C8  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDA6CC  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFDA6D0  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDA6D4  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFDA6D8  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFDA6DC  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDA6E0  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA6E3  F3 0F 11 93 00 C5 00 00     movss   dword ptr [rbx+0C500h], xmm2
00007FF91DFDA6EB  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFDA6EF  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDA6F3  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDA6F7  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFDA6FC  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA6FF  F3 0F 59 83 10 C5 00 00     mulss   xmm0, dword ptr [rbx+0C510h]
00007FF91DFDA707  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDA70B  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDA70F  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA712  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFDA716  F3 0F 11 AB 10 C5 00 00     movss   dword ptr [rbx+0C510h], xmm5
00007FF91DFDA71E  F3 0F 10 8B 00 C5 00 00     movss   xmm1, dword ptr [rbx+0C500h]
00007FF91DFDA726  F3 0F 59 8B C0 C7 00 00     mulss   xmm1, dword ptr [rbx+0C7C0h]
00007FF91DFDA72E  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFDA732  F3 0F 59 AB D0 C7 00 00     mulss   xmm5, dword ptr [rbx+0C7D0h]
00007FF91DFDA73A  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDA73E  F3 0F 10 83 B0 C7 00 00     movss   xmm0, dword ptr [rbx+0C7B0h]
00007FF91DFDA746  F3 0F 59 83 F0 C4 00 00     mulss   xmm0, dword ptr [rbx+0C4F0h]
00007FF91DFDA74E  F3 0F 58 CD                 addss   xmm1, xmm5
00007FF91DFDA752  F3 0F 10 AB 30 C7 00 00     movss   xmm5, dword ptr [rbx+0C730h]
00007FF91DFDA75A  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDA75E  F3 0F 11 8B B0 C5 00 00     movss   dword ptr [rbx+0C5B0h], xmm1
00007FF91DFDA766  F3 0F 59 AB 30 C8 00 00     mulss   xmm5, dword ptr [rbx+0C830h]
00007FF91DFDA76E  F3 0F 10 83 20 C5 00 00     movss   xmm0, dword ptr [rbx+0C520h]
00007FF91DFDA776  F3 0F 59 AB 80 C7 00 00     mulss   xmm5, dword ptr [rbx+0C780h]
00007FF91DFDA77E  F3 0F 11 9B B0 C4 00 00     movss   dword ptr [rbx+0C4B0h], xmm3
00007FF91DFDA786  F3 0F 59 9B 70 C9 00 00     mulss   xmm3, dword ptr [rbx+0C970h]
00007FF91DFDA78E  F3 0F 59 83 80 C9 00 00     mulss   xmm0, dword ptr [rbx+0C980h]
00007FF91DFDA796  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDA79A  F3 0F 59 9B 70 C7 00 00     mulss   xmm3, dword ptr [rbx+0C770h]
00007FF91DFDA7A2  F3 0F 5C EB                 subss   xmm5, xmm3
00007FF91DFDA7A6  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDA7AA  73 06                       jnb     short loc_7FF91DFDA7B2
00007FF91DFDA7AC  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDA7B0  EB 05                       jmp     short loc_7FF91DFDA7B7
00007FF91DFDA7B2  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDA7B7  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFDA7BA  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDA7BD  F3 0F 59 83 20 C8 00 00     mulss   xmm0, dword ptr [rbx+0C820h]
00007FF91DFDA7C5  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDA7C9  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA7CD  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA7D1  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFDA7D5  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFDA7D9  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDA7DD  F3 0F 11 AB 50 C4 00 00     movss   dword ptr [rbx+0C450h], xmm5
00007FF91DFDA7E5  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDA7E8  F3 0F 58 AB D0 C4 00 00     addss   xmm5, dword ptr [rbx+0C4D0h]
00007FF91DFDA7F0  F3 0F 10 9B E0 C4 00 00     movss   xmm3, dword ptr [rbx+0C4E0h]
00007FF91DFDA7F8  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDA7FB  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA7FF  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDA803  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFDA807  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFDA80B  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDA80F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA813  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA816  F3 0F 11 A3 60 C4 00 00     movss   dword ptr [rbx+0C460h], xmm4
00007FF91DFDA81E  F3 0F 10 8B F0 C4 00 00     movss   xmm1, dword ptr [rbx+0C4F0h]
00007FF91DFDA826  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFDA82A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDA82E  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDA831  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA835  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFDA839  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDA83D  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFDA841  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDA845  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFDA849  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDA84D  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFDA851  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA854  F3 0F 11 9B 70 C4 00 00     movss   dword ptr [rbx+0C470h], xmm3
00007FF91DFDA85C  F3 0F 10 AB 00 C5 00 00     movss   xmm5, dword ptr [rbx+0C500h]
00007FF91DFDA864  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDA868  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA86C  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDA86F  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDA873  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDA877  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDA87B  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFDA87F  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDA883  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFDA887  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDA88B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA88E  F3 0F 11 93 80 C4 00 00     movss   dword ptr [rbx+0C480h], xmm2
00007FF91DFDA896  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFDA89A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDA89E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDA8A2  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFDA8A7  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDA8AA  F3 0F 59 83 10 C5 00 00     mulss   xmm0, dword ptr [rbx+0C510h]
00007FF91DFDA8B2  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFDA8B6  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDA8BA  F3 44 0F 59 C1              mulss   xmm8, xmm1
00007FF91DFDA8BF  F3 0F 11 AB 90 C4 00 00     movss   dword ptr [rbx+0C490h], xmm5
00007FF91DFDA8C7  F3 0F 10 9B 70 C4 00 00     movss   xmm3, dword ptr [rbx+0C470h]
00007FF91DFDA8CF  F3 0F 59 F5                 mulss   xmm6, xmm5
00007FF91DFDA8D3  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFDA8D8  F3 44 0F 11 83 A0 C4 00 00  movss   dword ptr [rbx+0C4A0h], xmm8
00007FF91DFDA8E1  F3 0F 10 83 C0 C7 00 00     movss   xmm0, dword ptr [rbx+0C7C0h]
00007FF91DFDA8E9  F3 0F 59 83 80 C4 00 00     mulss   xmm0, dword ptr [rbx+0C480h]
00007FF91DFDA8F1  F3 0F 59 AB D0 C7 00 00     mulss   xmm5, dword ptr [rbx+0C7D0h]
00007FF91DFDA8F9  F3 0F 59 9B B0 C7 00 00     mulss   xmm3, dword ptr [rbx+0C7B0h]
00007FF91DFDA901  F3 0F 10 A3 70 C5 00 00     movss   xmm4, dword ptr [rbx+0C570h]
00007FF91DFDA909  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDA90D  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFDA911  F3 0F 11 AB 30 C5 00 00     movss   dword ptr [rbx+0C530h], xmm5
00007FF91DFDA919  F3 0F 58 A3 E0 C6 00 00     addss   xmm4, dword ptr [rbx+0C6E0h]
00007FF91DFDA921  F3 0F 10 83 F0 C5 00 00     movss   xmm0, dword ptr [rbx+0C5F0h]
00007FF91DFDA929  F3 0F 58 83 60 C6 00 00     addss   xmm0, dword ptr [rbx+0C660h]
00007FF91DFDA931  F3 0F 10 8B 70 C6 00 00     movss   xmm1, dword ptr [rbx+0C670h]
00007FF91DFDA939  F3 0F 58 8B E0 C5 00 00     addss   xmm1, dword ptr [rbx+0C5E0h]
00007FF91DFDA941  F3 0F 59 A3 60 C9 00 00     mulss   xmm4, dword ptr [rbx+0C960h]
00007FF91DFDA949  F3 0F 59 83 50 C9 00 00     mulss   xmm0, dword ptr [rbx+0C950h]
00007FF91DFDA951  F3 0F 59 8B 40 C9 00 00     mulss   xmm1, dword ptr [rbx+0C940h]
00007FF91DFDA959  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA95D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDA961  F3 0F 10 83 60 C5 00 00     movss   xmm0, dword ptr [rbx+0C560h]
00007FF91DFDA969  F3 0F 58 83 F0 C6 00 00     addss   xmm0, dword ptr [rbx+0C6F0h]
00007FF91DFDA971  F3 0F 10 8B D0 C6 00 00     movss   xmm1, dword ptr [rbx+0C6D0h]
00007FF91DFDA979  F3 0F 58 8B 80 C5 00 00     addss   xmm1, dword ptr [rbx+0C580h]
00007FF91DFDA981  F3 0F 58 AB 20 C7 00 00     addss   xmm5, dword ptr [rbx+0C720h]
00007FF91DFDA989  F3 0F 59 83 30 C9 00 00     mulss   xmm0, dword ptr [rbx+0C930h]
00007FF91DFDA991  F3 0F 59 8B 20 C9 00 00     mulss   xmm1, dword ptr [rbx+0C920h]
00007FF91DFDA999  F3 0F 59 AB 70 C8 00 00     mulss   xmm5, dword ptr [rbx+0C870h]
00007FF91DFDA9A1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA9A5  F3 0F 10 83 50 C6 00 00     movss   xmm0, dword ptr [rbx+0C650h]
00007FF91DFDA9AD  F3 0F 58 83 00 C6 00 00     addss   xmm0, dword ptr [rbx+0C600h]
00007FF91DFDA9B5  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDA9B9  F3 0F 10 8B 80 C6 00 00     movss   xmm1, dword ptr [rbx+0C680h]
00007FF91DFDA9C1  F3 0F 58 8B D0 C5 00 00     addss   xmm1, dword ptr [rbx+0C5D0h]
00007FF91DFDA9C9  F3 0F 59 83 10 C9 00 00     mulss   xmm0, dword ptr [rbx+0C910h]
00007FF91DFDA9D1  F3 0F 59 8B 00 C9 00 00     mulss   xmm1, dword ptr [rbx+0C900h]
00007FF91DFDA9D9  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDA9DD  F3 0F 10 83 00 C7 00 00     movss   xmm0, dword ptr [rbx+0C700h]
00007FF91DFDA9E5  F3 0F 58 83 50 C5 00 00     addss   xmm0, dword ptr [rbx+0C550h]
00007FF91DFDA9ED  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDA9F1  F3 0F 10 8B C0 C6 00 00     movss   xmm1, dword ptr [rbx+0C6C0h]
00007FF91DFDA9F9  F3 0F 59 83 F0 C8 00 00     mulss   xmm0, dword ptr [rbx+0C8F0h]
00007FF91DFDAA01  F3 0F 58 8B 90 C5 00 00     addss   xmm1, dword ptr [rbx+0C590h]
00007FF91DFDAA09  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDAA0D  F3 0F 10 83 40 C6 00 00     movss   xmm0, dword ptr [rbx+0C640h]
00007FF91DFDAA15  F3 0F 58 83 10 C6 00 00     addss   xmm0, dword ptr [rbx+0C610h]
00007FF91DFDAA1D  F3 0F 59 8B E0 C8 00 00     mulss   xmm1, dword ptr [rbx+0C8E0h]
00007FF91DFDAA25  F3 0F 59 83 D0 C8 00 00     mulss   xmm0, dword ptr [rbx+0C8D0h]
00007FF91DFDAA2D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDAA31  F3 0F 10 8B 90 C6 00 00     movss   xmm1, dword ptr [rbx+0C690h]
00007FF91DFDAA39  F3 0F 58 8B C0 C5 00 00     addss   xmm1, dword ptr [rbx+0C5C0h]
00007FF91DFDAA41  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDAA45  F3 0F 10 83 10 C7 00 00     movss   xmm0, dword ptr [rbx+0C710h]
00007FF91DFDAA4D  F3 0F 59 8B C0 C8 00 00     mulss   xmm1, dword ptr [rbx+0C8C0h]
00007FF91DFDAA55  F3 0F 58 83 40 C5 00 00     addss   xmm0, dword ptr [rbx+0C540h]
00007FF91DFDAA5D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDAA61  F3 0F 10 8B B0 C6 00 00     movss   xmm1, dword ptr [rbx+0C6B0h]
00007FF91DFDAA69  F3 0F 58 8B A0 C5 00 00     addss   xmm1, dword ptr [rbx+0C5A0h]
00007FF91DFDAA71  F3 0F 59 83 B0 C8 00 00     mulss   xmm0, dword ptr [rbx+0C8B0h]
00007FF91DFDAA79  F3 0F 59 8B A0 C8 00 00     mulss   xmm1, dword ptr [rbx+0C8A0h]
00007FF91DFDAA81  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDAA85  F3 0F 10 83 30 C6 00 00     movss   xmm0, dword ptr [rbx+0C630h]
00007FF91DFDAA8D  F3 0F 58 83 20 C6 00 00     addss   xmm0, dword ptr [rbx+0C620h]
00007FF91DFDAA95  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDAA99  F3 0F 10 8B A0 C6 00 00     movss   xmm1, dword ptr [rbx+0C6A0h]
00007FF91DFDAAA1  F3 0F 59 83 90 C8 00 00     mulss   xmm0, dword ptr [rbx+0C890h]
00007FF91DFDAAA9  F3 0F 58 8B B0 C5 00 00     addss   xmm1, dword ptr [rbx+0C5B0h]
00007FF91DFDAAB1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDAAB5  F3 0F 59 8B 80 C8 00 00     mulss   xmm1, dword ptr [rbx+0C880h]
00007FF91DFDAABD  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDAAC1  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFDAAC5  F3 0F 59 A3 00 C8 00 00     mulss   xmm4, dword ptr [rbx+0C800h]
00007FF91DFDAACD  F3 0F 11 A3 90 C7 00 00     movss   dword ptr [rbx+0C790h], xmm4
00007FF91DFDAAD5  8B 83 90 C9 00 00           mov     eax, [rbx+0C990h]
00007FF91DFDAADB  89 83 A0 C9 00 00           mov     [rbx+0C9A0h], eax
00007FF91DFDAAE1  F3 0F 10 83 C0 C9 00 00     movss   xmm0, dword ptr [rbx+0C9C0h]
00007FF91DFDAAE9  8B 83 B0 C9 00 00           mov     eax, [rbx+0C9B0h]
00007FF91DFDAAEF  89 83 E0 C9 00 00           mov     [rbx+0C9E0h], eax
00007FF91DFDAAF5  F3 0F 11 83 F0 C9 00 00     movss   dword ptr [rbx+0C9F0h], xmm0
00007FF91DFDAAFD  8B 83 D0 C9 00 00           mov     eax, [rbx+0C9D0h]
00007FF91DFDAB03  89 83 00 CA 00 00           mov     [rbx+0CA00h], eax
00007FF91DFDAB09  F3 0F 10 93 10 CA 00 00     movss   xmm2, dword ptr [rbx+0CA10h]
00007FF91DFDAB11  F3 0F 11 93 20 CA 00 00     movss   dword ptr [rbx+0CA20h], xmm2
00007FF91DFDAB19  F3 0F 10 83 30 CA 00 00     movss   xmm0, dword ptr [rbx+0CA30h]
00007FF91DFDAB21  F3 0F 11 83 40 CA 00 00     movss   dword ptr [rbx+0CA40h], xmm0
00007FF91DFDAB29  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFDAB2D  F3 0F 59 93 50 CA 00 00     mulss   xmm2, dword ptr [rbx+0CA50h]
00007FF91DFDAB35  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFDAB39  F3 0F 11 93 30 CA 00 00     movss   dword ptr [rbx+0CA30h], xmm2
00007FF91DFDAB41  F3 0F 10 83 F0 C9 00 00     movss   xmm0, dword ptr [rbx+0C9F0h]
00007FF91DFDAB49  F3 0F 10 8B 00 CA 00 00     movss   xmm1, dword ptr [rbx+0CA00h]
00007FF91DFDAB51  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFDAB55  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDAB59  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFDAB5D  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFDAB61  F3 0F 11 93 60 CA 00 00     movss   dword ptr [rbx+0CA60h], xmm2
00007FF91DFDAB69  F3 0F 10 8B 70 CA 00 00     movss   xmm1, dword ptr [rbx+0CA70h]
00007FF91DFDAB71  F3 0F 11 8B 80 CA 00 00     movss   dword ptr [rbx+0CA80h], xmm1
00007FF91DFDAB79  F3 0F 10 83 90 CA 00 00     movss   xmm0, dword ptr [rbx+0CA90h]
00007FF91DFDAB81  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFDAB84  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFDAB88  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFDAB8C  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDAB90  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDAB94  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFDAB98  76 05                       jbe     short loc_7FF91DFDAB9F
00007FF91DFDAB9A  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFDAB9D  EB 03                       jmp     short loc_7FF91DFDABA2
00007FF91DFDAB9F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDABA2  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFDABA6  F3 0F 11 83 70 CA 00 00     movss   dword ptr [rbx+0CA70h], xmm0
00007FF91DFDABAE  F3 0F 10 8B A0 CA 00 00     movss   xmm1, dword ptr [rbx+0CAA0h]
00007FF91DFDABB6  F3 0F 11 8B B0 CA 00 00     movss   dword ptr [rbx+0CAB0h], xmm1
00007FF91DFDABBE  F3 0F 10 93 C0 CA 00 00     movss   xmm2, dword ptr [rbx+0CAC0h]
00007FF91DFDABC6  F3 0F 11 93 D0 CA 00 00     movss   dword ptr [rbx+0CAD0h], xmm2
00007FF91DFDABCE  F3 0F 10 83 E0 CA 00 00     movss   xmm0, dword ptr [rbx+0CAE0h]
00007FF91DFDABD6  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFDABD9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDABDD  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFDABE1  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDABE5  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFDABE9  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFDABED  76 05                       jbe     short loc_7FF91DFDABF4
00007FF91DFDABEF  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFDABF2  EB 03                       jmp     short loc_7FF91DFDABF7
00007FF91DFDABF4  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDABF7  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFDABFB  F3 0F 11 83 C0 CA 00 00     movss   dword ptr [rbx+0CAC0h], xmm0
00007FF91DFDAC03  F3 0F 10 AB F0 CA 00 00     movss   xmm5, dword ptr [rbx+0CAF0h]
00007FF91DFDAC0B  F3 0F 10 B3 70 A6 00 00     movss   xmm6, dword ptr [rbx+0A670h]
00007FF91DFDAC13  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFDAC16  F3 0F 11 AB 00 CB 00 00     movss   dword ptr [rbx+0CB00h], xmm5
00007FF91DFDAC1E  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFDAC21  F3 0F 59 A3 50 CB 00 00     mulss   xmm4, dword ptr [rbx+0CB50h]
00007FF91DFDAC29  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFDAC2C  F3 0F 58 83 20 CB 00 00     addss   xmm0, dword ptr [rbx+0CB20h]
00007FF91DFDAC34  F3 0F 58 9B 40 CB 00 00     addss   xmm3, dword ptr [rbx+0CB40h]
00007FF91DFDAC3C  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFDAC40  73 06                       jnb     short loc_7FF91DFDAC48
00007FF91DFDAC42  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFDAC46  EB 05                       jmp     short loc_7FF91DFDAC4D
00007FF91DFDAC48  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFDAC4D  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDAC51  72 1B                       jb      short loc_7FF91DFDAC6E
00007FF91DFDAC53  F3 0F 10 83 30 CB 00 00     movss   xmm0, dword ptr [rbx+0CB30h]
00007FF91DFDAC5B  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFDAC5E  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFDAC62  F3 0F 59 DE                 mulss   xmm3, xmm6
00007FF91DFDAC66  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDAC6A  F3 0F 58 DD                 addss   xmm3, xmm5
00007FF91DFDAC6E  41 0F 2E F6                 ucomiss xmm6, xmm14
00007FF91DFDAC72  F3 0F 10 8B 70 CB 00 00     movss   xmm1, dword ptr [rbx+0CB70h]
00007FF91DFDAC7A  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFDAC7D  F3 0F 59 93 60 CB 00 00     mulss   xmm2, dword ptr [rbx+0CB60h]
00007FF91DFDAC85  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDAC88  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFDAC8C  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFDAC90  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFDAC94  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDAC97  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDAC9B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFDAC9F  F3 0F 5C C2                 subss   xmm0, xmm2
00007FF91DFDACA3  F3 0F 58 C5                 addss   xmm0, xmm5
00007FF91DFDACA7  74 03                       jz      short loc_7FF91DFDACAC
00007FF91DFDACA9  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDACAC  F3 0F 11 83 10 CB 00 00     movss   dword ptr [rbx+0CB10h], xmm0
00007FF91DFDACB4  F3 0F 11 83 F0 CA 00 00     movss   dword ptr [rbx+0CAF0h], xmm0
00007FF91DFDACBC  F3 0F 10 BB 90 C7 00 00     movss   xmm7, dword ptr [rbx+0C790h]
00007FF91DFDACC4  F3 0F 10 B3 00 AF 00 00     movss   xmm6, dword ptr [rbx+0AF00h]
00007FF91DFDACCC  F3 0F 10 9B 00 BF 00 00     movss   xmm3, dword ptr [rbx+0BF00h]
00007FF91DFDACD4  F3 0F 10 83 E0 B0 00 00     movss   xmm0, dword ptr [rbx+0B0E0h]
00007FF91DFDACDC  F3 0F 10 8B 90 C9 00 00     movss   xmm1, dword ptr [rbx+0C990h]
00007FF91DFDACE4  8B 83 B0 CB 00 00           mov     eax, [rbx+0CBB0h]
00007FF91DFDACEA  89 83 C0 CB 00 00           mov     [rbx+0CBC0h], eax
00007FF91DFDACF0  8B 83 D0 CB 00 00           mov     eax, [rbx+0CBD0h]
00007FF91DFDACF6  89 83 E0 CB 00 00           mov     [rbx+0CBE0h], eax
00007FF91DFDACFC  F3 0F 11 83 80 CB 00 00     movss   dword ptr [rbx+0CB80h], xmm0
00007FF91DFDAD04  F3 0F 11 8B 90 CB 00 00     movss   dword ptr [rbx+0CB90h], xmm1
00007FF91DFDAD0C  F3 0F 59 9B A0 CC 00 00     mulss   xmm3, dword ptr [rbx+0CCA0h]
00007FF91DFDAD14  F3 0F 10 A3 C0 CB 00 00     movss   xmm4, dword ptr [rbx+0CBC0h]
00007FF91DFDAD1C  F3 0F 10 93 00 CC 00 00     movss   xmm2, dword ptr [rbx+0CC00h]
00007FF91DFDAD24  F3 0F 11 9B A0 CB 00 00     movss   dword ptr [rbx+0CBA0h], xmm3
00007FF91DFDAD2C  0F 28 DF                    movaps  xmm3, xmm7
00007FF91DFDAD2F  F3 0F 59 B3 10 CC 00 00     mulss   xmm6, dword ptr [rbx+0CC10h]
00007FF91DFDAD37  F3 0F 5C DC                 subss   xmm3, xmm4
00007FF91DFDAD3B  F3 0F 59 93 10 CB 00 00     mulss   xmm2, dword ptr [rbx+0CB10h]
00007FF91DFDAD43  F3 0F 10 8B 20 CC 00 00     movss   xmm1, dword ptr [rbx+0CC20h]
00007FF91DFDAD4B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDAD4E  F3 0F 59 83 40 CC 00 00     mulss   xmm0, dword ptr [rbx+0CC40h]
00007FF91DFDAD56  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFDAD5A  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDAD5E  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFDAD62  F3 0F 11 A3 B0 CB 00 00     movss   dword ptr [rbx+0CBB0h], xmm4
00007FF91DFDAD6A  F3 0F 59 8B 80 CB 00 00     mulss   xmm1, dword ptr [rbx+0CB80h]
00007FF91DFDAD72  F3 0F 10 93 30 CC 00 00     movss   xmm2, dword ptr [rbx+0CC30h]
00007FF91DFDAD7A  F3 0F 59 9B B0 CC 00 00     mulss   xmm3, dword ptr [rbx+0CCB0h]
00007FF91DFDAD82  F3 0F 59 A3 C0 CC 00 00     mulss   xmm4, dword ptr [rbx+0CCC0h]
00007FF91DFDAD8A  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFDAD8E  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDAD91  F3 0F 59 8B 90 CB 00 00     mulss   xmm1, dword ptr [rbx+0CB90h]
00007FF91DFDAD99  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFDAD9D  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFDADA1  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFDADA5  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFDADA9  F3 0F 10 B3 50 CC 00 00     movss   xmm6, dword ptr [rbx+0CC50h]
00007FF91DFDADB1  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFDADB5  F3 0F 59 8B 80 CC 00 00     mulss   xmm1, dword ptr [rbx+0CC80h]
00007FF91DFDADBD  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFDADC1  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFDADC5  76 05                       jbe     short loc_7FF91DFDADCC
00007FF91DFDADC7  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFDADCA  EB 03                       jmp     short loc_7FF91DFDADCF
00007FF91DFDADCC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDADCF  F3 0F 10 93 70 CC 00 00     movss   xmm2, dword ptr [rbx+0CC70h]
00007FF91DFDADD7  F3 0F 10 A3 60 CC 00 00     movss   xmm4, dword ptr [rbx+0CC60h]
00007FF91DFDADDF  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFDADE3  F3 0F 10 83 A0 CB 00 00     movss   xmm0, dword ptr [rbx+0CBA0h]
00007FF91DFDADEB  F3 0F 59 AB 90 CC 00 00     mulss   xmm5, dword ptr [rbx+0CC90h]
00007FF91DFDADF3  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDADF8  F3 0F 59 F3                 mulss   xmm6, xmm3
00007FF91DFDADFC  F3 0F 10 9B E0 CB 00 00     movss   xmm3, dword ptr [rbx+0CBE0h]
00007FF91DFDAE04  F3 0F 58 F7                 addss   xmm6, xmm7
00007FF91DFDAE08  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFDAE0C  F3 0F 10 83 D0 CC 00 00     movss   xmm0, dword ptr [rbx+0CCD0h]
00007FF91DFDAE14  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFDAE17  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFDAE1B  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFDAE1F  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFDAE23  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFDAE27  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFDAE2B  F3 0F 11 9B D0 CB 00 00     movss   dword ptr [rbx+0CBD0h], xmm3
00007FF91DFDAE33  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFDAE37  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFDAE3B  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFDAE3F  F3 0F 59 A3 E0 CC 00 00     mulss   xmm4, dword ptr [rbx+0CCE0h]
00007FF91DFDAE47  F3 0F 11 A3 F0 CB 00 00     movss   dword ptr [rbx+0CBF0h], xmm4
00007FF91DFDAE4F  8B 83 00 CD 00 00           mov     eax, [rbx+0CD00h]
00007FF91DFDAE55  89 83 10 CD 00 00           mov     [rbx+0CD10h], eax
00007FF91DFDAE5B  8B 83 F0 CC 00 00           mov     eax, [rbx+0CCF0h]
00007FF91DFDAE61  89 83 00 CD 00 00           mov     [rbx+0CD00h], eax
00007FF91DFDAE67  F3 0F 10 83 10 CD 00 00     movss   xmm0, dword ptr [rbx+0CD10h]
00007FF91DFDAE6F  F3 0F 10 8B 20 CD 00 00     movss   xmm1, dword ptr [rbx+0CD20h]
00007FF91DFDAE77  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFDAE7B  F3 0F 11 A3 F0 CC 00 00     movss   dword ptr [rbx+0CCF0h], xmm4
00007FF91DFDAE83  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDAE87  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFDAE8B  F3 0F 11 8B 00 CD 00 00     movss   dword ptr [rbx+0CD00h], xmm1
00007FF91DFDAE93  F3 0F 10 93 F0 CC 00 00     movss   xmm2, dword ptr [rbx+0CCF0h]
00007FF91DFDAE9B  F3 0F 10 B3 E0 C9 00 00     movss   xmm6, dword ptr [rbx+0C9E0h]
00007FF91DFDAEA3  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDAEA6  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFDAEAA  8B 83 50 CD 00 00           mov     eax, [rbx+0CD50h]
00007FF91DFDAEB0  89 83 60 CD 00 00           mov     [rbx+0CD60h], eax
00007FF91DFDAEB6  8B 83 40 CD 00 00           mov     eax, [rbx+0CD40h]
00007FF91DFDAEBC  89 83 50 CD 00 00           mov     [rbx+0CD50h], eax
00007FF91DFDAEC2  8B 83 30 CD 00 00           mov     eax, [rbx+0CD30h]
00007FF91DFDAEC8  89 83 40 CD 00 00           mov     [rbx+0CD40h], eax
00007FF91DFDAECE  F3 0F 11 93 30 CD 00 00     movss   dword ptr [rbx+0CD30h], xmm2
00007FF91DFDAED6  F3 0F 59 83 80 CD 00 00     mulss   xmm0, dword ptr [rbx+0CD80h]
00007FF91DFDAEDE  F3 0F 10 A3 40 CD 00 00     movss   xmm4, dword ptr [rbx+0CD40h]
00007FF91DFDAEE6  F3 0F 10 8B A0 CD 00 00     movss   xmm1, dword ptr [rbx+0CDA0h]
00007FF91DFDAEEE  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFDAEF1  F3 0F 59 8B 50 CD 00 00     mulss   xmm1, dword ptr [rbx+0CD50h]
00007FF91DFDAEF9  F3 0F 59 AB 90 CD 00 00     mulss   xmm5, dword ptr [rbx+0CD90h]
00007FF91DFDAF01  F3 0F 59 A3 C0 CD 00 00     mulss   xmm4, dword ptr [rbx+0CDC0h]
00007FF91DFDAF09  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDAF0D  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDAF10  F3 0F 59 83 B0 CD 00 00     mulss   xmm0, dword ptr [rbx+0CDB0h]
00007FF91DFDAF18  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDAF1C  F3 0F 10 8B D0 CD 00 00     movss   xmm1, dword ptr [rbx+0CDD0h]
00007FF91DFDAF24  F3 0F 59 8B 60 CD 00 00     mulss   xmm1, dword ptr [rbx+0CD60h]
00007FF91DFDAF2C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDAF30  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDAF34  76 05                       jbe     short loc_7FF91DFDAF3B
00007FF91DFDAF36  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFDAF39  EB 03                       jmp     short loc_7FF91DFDAF3E
00007FF91DFDAF3B  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDAF3E  0F 2F 35 7B A5 76 00        comiss  xmm6, cs:dword_7FF91E7454C0
00007FF91DFDAF45  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFDAF49  F3 0F 11 AB 40 CD 00 00     movss   dword ptr [rbx+0CD40h], xmm5
00007FF91DFDAF51  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFDAF54  F3 0F 11 A3 50 CD 00 00     movss   dword ptr [rbx+0CD50h], xmm4
00007FF91DFDAF5C  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDAF60  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDAF64  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDAF68  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDAF6B  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFDAF6F  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFDAF73  73 09                       jnb     short loc_7FF91DFDAF7E
00007FF91DFDAF75  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFDAF79  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
00007FF91DFDAF7E  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFDAF82  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
00007FF91DFDAF87  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFDAF8A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDAF8E  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFDAF92  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFDAF96  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFDAF9A  72 03                       jb      short loc_7FF91DFDAF9F
00007FF91DFDAF9C  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFDAF9F  F3 0F 11 93 70 CD 00 00     movss   dword ptr [rbx+0CD70h], xmm2
00007FF91DFDAFA7  F3 0F 59 93 70 CA 00 00     mulss   xmm2, dword ptr [rbx+0CA70h]
00007FF91DFDAFAF  F3 0F 11 93 E0 CD 00 00     movss   dword ptr [rbx+0CDE0h], xmm2
00007FF91DFDAFB7  F3 0F 59 93 C0 CA 00 00     mulss   xmm2, dword ptr [rbx+0CAC0h]
00007FF91DFDAFBF  F3 0F 11 93 F0 CD 00 00     movss   dword ptr [rbx+0CDF0h], xmm2
00007FF91DFDAFC7  F3 0F 10 83 A0 B5 00 00     movss   xmm0, dword ptr [rbx+0B5A0h]
00007FF91DFDAFCF  F3 0F 58 83 00 B3 00 00     addss   xmm0, dword ptr [rbx+0B300h]
00007FF91DFDAFD7  44 0F 5A E0                 cvtps2pd xmm12, xmm0
00007FF91DFDAFDB  F2 44 0F 5F 25 C4 FC 60 00  maxsd   xmm12, cs:qword_7FF91E5EACA8
00007FF91DFDAFE4  F2 44 0F 5D 25 A3 FC 60 00  minsd   xmm12, cs:qword_7FF91E5EAC90
00007FF91DFDAFED  41 0F 28 CC                 movaps  xmm1, xmm12
00007FF91DFDAFF1  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFDAFF5  F2 0F 58 05 6B A2 76 00     addsd   xmm0, cs:qword_7FF91E745268
00007FF91DFDAFFD  F2 41 0F 59 CC              mulsd   xmm1, xmm12
00007FF91DFDB002  41 0F 28 FC                 movaps  xmm7, xmm12
00007FF91DFDB006  F2 0F 2C C0                 cvttsd2si eax, xmm0
00007FF91DFDB00A  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFDB00D  48 63 C8                    movsxd  rcx, eax
00007FF91DFDB010  F2 41 0F 59 D4              mulsd   xmm2, xmm12
00007FF91DFDB015  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
00007FF91DFDB01C  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDB01F  F2 41 0F 59 DC              mulsd   xmm3, xmm12
00007FF91DFDB024  48 8D 0D B5 E4 60 00        lea     rcx, unk_7FF91E5E94E0
00007FF91DFDB02B  48 03 C1                    add     rax, rcx
00007FF91DFDB02E  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFDB031  F2 41 0F 59 E4              mulsd   xmm4, xmm12
00007FF91DFDB036  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
00007FF91DFDB03B  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
00007FF91DFDB040  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
00007FF91DFDB045  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFDB048  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
00007FF91DFDB04C  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
00007FF91DFDB051  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
00007FF91DFDB056  F2 0F 58 F9                 addsd   xmm7, xmm1
00007FF91DFDB05A  F2 41 0F 59 EC              mulsd   xmm5, xmm12
00007FF91DFDB05F  F2 0F 58 FA                 addsd   xmm7, xmm2
00007FF91DFDB063  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFDB066  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
00007FF91DFDB06B  F2 41 0F 59 F4              mulsd   xmm6, xmm12
00007FF91DFDB070  F2 0F 58 FB                 addsd   xmm7, xmm3
00007FF91DFDB074  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFDB078  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
00007FF91DFDB07D  F2 0F 58 FC                 addsd   xmm7, xmm4
00007FF91DFDB081  F2 45 0F 59 C4              mulsd   xmm8, xmm12
00007FF91DFDB086  F2 0F 58 FD                 addsd   xmm7, xmm5
00007FF91DFDB08A  45 0F 28 C8                 movaps  xmm9, xmm8
00007FF91DFDB08E  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
00007FF91DFDB097  F2 45 0F 59 CC              mulsd   xmm9, xmm12
00007FF91DFDB09C  F2 0F 58 FE                 addsd   xmm7, xmm6
00007FF91DFDB0A0  45 0F 28 D1                 movaps  xmm10, xmm9
00007FF91DFDB0A4  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
00007FF91DFDB0AD  F2 41 0F 58 F8              addsd   xmm7, xmm8
00007FF91DFDB0B2  F2 45 0F 59 D4              mulsd   xmm10, xmm12
00007FF91DFDB0B7  F2 41 0F 58 F9              addsd   xmm7, xmm9
00007FF91DFDB0BC  45 0F 28 DA                 movaps  xmm11, xmm10
00007FF91DFDB0C0  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
00007FF91DFDB0C9  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFDB0CE  F2 41 0F 58 FA              addsd   xmm7, xmm10
00007FF91DFDB0D3  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFDB0D7  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFDB0DC  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
00007FF91DFDB0E4  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
00007FF91DFDB0ED  F2 0F 58 F8                 addsd   xmm7, xmm0
00007FF91DFDB0F1  F2 41 0F 58 FB              addsd   xmm7, xmm11
00007FF91DFDB0F6  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
00007FF91DFDB0FA  F3 0F 5D 1D 96 FB 60 00     minss   xmm3, cs:dword_7FF91E5EAC98
00007FF91DFDB102  F3 0F 5F 1D A6 FB 60 00     maxss   xmm3, cs:dword_7FF91E5EACB0
00007FF91DFDB10A  F3 0F 59 9B 10 B3 00 00     mulss   xmm3, dword ptr [rbx+0B310h]
00007FF91DFDB112  F3 0F 11 9B 80 B5 00 00     movss   dword ptr [rbx+0B580h], xmm3
00007FF91DFDB11A  8B 83 20 B7 00 00           mov     eax, [rbx+0B720h]
00007FF91DFDB120  F3 0F 10 AB 00 B3 00 00     movss   xmm5, dword ptr [rbx+0B300h]
00007FF91DFDB128  F3 0F 10 83 D0 B4 00 00     movss   xmm0, dword ptr [rbx+0B4D0h]
00007FF91DFDB130  F3 0F 10 8B E0 B4 00 00     movss   xmm1, dword ptr [rbx+0B4E0h]
00007FF91DFDB138  F3 0F 10 93 F0 B4 00 00     movss   xmm2, dword ptr [rbx+0B4F0h]
00007FF91DFDB140  89 83 30 B7 00 00           mov     [rbx+0B730h], eax
00007FF91DFDB146  8B 83 40 B7 00 00           mov     eax, [rbx+0B740h]
00007FF91DFDB14C  89 83 50 B7 00 00           mov     [rbx+0B750h], eax
00007FF91DFDB152  8B 83 F0 B7 00 00           mov     eax, [rbx+0B7F0h]
00007FF91DFDB158  89 83 00 B8 00 00           mov     [rbx+0B800h], eax
00007FF91DFDB15E  8B 83 E0 B7 00 00           mov     eax, [rbx+0B7E0h]
00007FF91DFDB164  89 83 F0 B7 00 00           mov     [rbx+0B7F0h], eax
00007FF91DFDB16A  8B 83 D0 B7 00 00           mov     eax, [rbx+0B7D0h]
00007FF91DFDB170  89 83 E0 B7 00 00           mov     [rbx+0B7E0h], eax
00007FF91DFDB176  8B 83 C0 B7 00 00           mov     eax, [rbx+0B7C0h]
00007FF91DFDB17C  89 83 D0 B7 00 00           mov     [rbx+0B7D0h], eax
00007FF91DFDB182  8B 83 B0 B7 00 00           mov     eax, [rbx+0B7B0h]
00007FF91DFDB188  89 83 C0 B7 00 00           mov     [rbx+0B7C0h], eax
00007FF91DFDB18E  8B 83 A0 B7 00 00           mov     eax, [rbx+0B7A0h]
00007FF91DFDB194  89 83 B0 B7 00 00           mov     [rbx+0B7B0h], eax
00007FF91DFDB19A  8B 83 90 B7 00 00           mov     eax, [rbx+0B790h]
00007FF91DFDB1A0  89 83 A0 B7 00 00           mov     [rbx+0B7A0h], eax
00007FF91DFDB1A6  8B 83 70 B8 00 00           mov     eax, [rbx+0B870h]
00007FF91DFDB1AC  89 83 80 B8 00 00           mov     [rbx+0B880h], eax
00007FF91DFDB1B2  8B 83 60 B8 00 00           mov     eax, [rbx+0B860h]
00007FF91DFDB1B8  89 83 70 B8 00 00           mov     [rbx+0B870h], eax
00007FF91DFDB1BE  8B 83 50 B8 00 00           mov     eax, [rbx+0B850h]
00007FF91DFDB1C4  89 83 60 B8 00 00           mov     [rbx+0B860h], eax
00007FF91DFDB1CA  8B 83 40 B8 00 00           mov     eax, [rbx+0B840h]
00007FF91DFDB1D0  89 83 50 B8 00 00           mov     [rbx+0B850h], eax
00007FF91DFDB1D6  8B 83 30 B8 00 00           mov     eax, [rbx+0B830h]
00007FF91DFDB1DC  89 83 40 B8 00 00           mov     [rbx+0B840h], eax
00007FF91DFDB1E2  8B 83 20 B8 00 00           mov     eax, [rbx+0B820h]
00007FF91DFDB1E8  89 83 30 B8 00 00           mov     [rbx+0B830h], eax
00007FF91DFDB1EE  8B 83 10 B8 00 00           mov     eax, [rbx+0B810h]
00007FF91DFDB1F4  89 83 20 B8 00 00           mov     [rbx+0B820h], eax
00007FF91DFDB1FA  8B 83 F0 B8 00 00           mov     eax, [rbx+0B8F0h]
00007FF91DFDB200  89 83 00 B9 00 00           mov     [rbx+0B900h], eax
00007FF91DFDB206  8B 83 E0 B8 00 00           mov     eax, [rbx+0B8E0h]
00007FF91DFDB20C  89 83 F0 B8 00 00           mov     [rbx+0B8F0h], eax
00007FF91DFDB212  8B 83 D0 B8 00 00           mov     eax, [rbx+0B8D0h]
00007FF91DFDB218  89 83 E0 B8 00 00           mov     [rbx+0B8E0h], eax
00007FF91DFDB21E  8B 83 C0 B8 00 00           mov     eax, [rbx+0B8C0h]
00007FF91DFDB224  89 83 D0 B8 00 00           mov     [rbx+0B8D0h], eax
00007FF91DFDB22A  8B 83 B0 B8 00 00           mov     eax, [rbx+0B8B0h]
00007FF91DFDB230  89 83 C0 B8 00 00           mov     [rbx+0B8C0h], eax
00007FF91DFDB236  8B 83 A0 B8 00 00           mov     eax, [rbx+0B8A0h]
00007FF91DFDB23C  89 83 B0 B8 00 00           mov     [rbx+0B8B0h], eax
00007FF91DFDB242  8B 83 90 B8 00 00           mov     eax, [rbx+0B890h]
00007FF91DFDB248  89 83 A0 B8 00 00           mov     [rbx+0B8A0h], eax
00007FF91DFDB24E  8B 83 70 B9 00 00           mov     eax, [rbx+0B970h]
00007FF91DFDB254  89 83 80 B9 00 00           mov     [rbx+0B980h], eax
00007FF91DFDB25A  8B 83 60 B9 00 00           mov     eax, [rbx+0B960h]
00007FF91DFDB260  89 83 70 B9 00 00           mov     [rbx+0B970h], eax
00007FF91DFDB266  8B 83 50 B9 00 00           mov     eax, [rbx+0B950h]
00007FF91DFDB26C  89 83 60 B9 00 00           mov     [rbx+0B960h], eax
00007FF91DFDB272  8B 83 40 B9 00 00           mov     eax, [rbx+0B940h]
00007FF91DFDB278  89 83 50 B9 00 00           mov     [rbx+0B950h], eax
00007FF91DFDB27E  8B 83 30 B9 00 00           mov     eax, [rbx+0B930h]
00007FF91DFDB284  89 83 40 B9 00 00           mov     [rbx+0B940h], eax
00007FF91DFDB28A  8B 83 20 B9 00 00           mov     eax, [rbx+0B920h]
00007FF91DFDB290  89 83 30 B9 00 00           mov     [rbx+0B930h], eax
00007FF91DFDB296  8B 83 10 B9 00 00           mov     eax, [rbx+0B910h]
00007FF91DFDB29C  89 83 20 B9 00 00           mov     [rbx+0B920h], eax
00007FF91DFDB2A2  8B 83 B0 B9 00 00           mov     eax, [rbx+0B9B0h]
00007FF91DFDB2A8  89 83 C0 B9 00 00           mov     [rbx+0B9C0h], eax
00007FF91DFDB2AE  8B 83 A0 B9 00 00           mov     eax, [rbx+0B9A0h]
00007FF91DFDB2B4  89 83 B0 B9 00 00           mov     [rbx+0B9B0h], eax
00007FF91DFDB2BA  F3 0F 11 83 C0 B6 00 00     movss   dword ptr [rbx+0B6C0h], xmm0
00007FF91DFDB2C2  F3 0F 11 8B D0 B6 00 00     movss   dword ptr [rbx+0B6D0h], xmm1
00007FF91DFDB2CA  F3 0F 58 AB E0 BC 00 00     addss   xmm5, dword ptr [rbx+0BCE0h]
00007FF91DFDB2D2  F3 0F 59 9B E0 B9 00 00     mulss   xmm3, dword ptr [rbx+0B9E0h]
00007FF91DFDB2DA  F3 0F 10 83 D0 B9 00 00     movss   xmm0, dword ptr [rbx+0B9D0h]
00007FF91DFDB2E2  F3 0F 11 93 E0 B6 00 00     movss   dword ptr [rbx+0B6E0h], xmm2
00007FF91DFDB2EA  F3 0F 10 93 00 BA 00 00     movss   xmm2, dword ptr [rbx+0BA00h]
00007FF91DFDB2F2  F3 0F 59 AB F0 BC 00 00     mulss   xmm5, dword ptr [rbx+0BCF0h]
00007FF91DFDB2FA  F3 0F 5F D3                 maxss   xmm2, xmm3
00007FF91DFDB2FE  F3 0F 58 AB D0 BC 00 00     addss   xmm5, dword ptr [rbx+0BCD0h]
00007FF91DFDB306  F3 0F 11 93 F0 B6 00 00     movss   dword ptr [rbx+0B6F0h], xmm2
00007FF91DFDB30E  F3 0F 58 83 20 B3 00 00     addss   xmm0, dword ptr [rbx+0B320h]
00007FF91DFDB316  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFDB31A  F3 0F 11 83 10 B7 00 00     movss   dword ptr [rbx+0B710h], xmm0
00007FF91DFDB322  76 05                       jbe     short loc_7FF91DFDB329
00007FF91DFDB324  0F 5A C5                    cvtps2pd xmm0, xmm5
00007FF91DFDB327  EB 03                       jmp     short loc_7FF91DFDB32C
00007FF91DFDB329  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFDB32C  F3 0F 10 0D 28 9C 76 00     movss   xmm1, cs:dword_7FF91E744F5C
00007FF91DFDB334  F3 44 0F 10 15 AB 9E 76 00  movss   xmm10, cs:flt_7FF91E7451E8
00007FF91DFDB33D  F3 0F 5E CA                 divss   xmm1, xmm2
00007FF91DFDB341  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFDB345  F3 0F 11 8B 00 B7 00 00     movss   dword ptr [rbx+0B700h], xmm1
00007FF91DFDB34D  F3 0F 11 83 90 B9 00 00     movss   dword ptr [rbx+0B990h], xmm0
00007FF91DFDB355  F3 0F 10 B3 50 B7 00 00     movss   xmm6, dword ptr [rbx+0B750h]
00007FF91DFDB35D  F3 0F 10 8B 30 B7 00 00     movss   xmm1, dword ptr [rbx+0B730h]
00007FF91DFDB365  F3 0F 11 B3 70 B6 00 00     movss   dword ptr [rbx+0B670h], xmm6
00007FF91DFDB36D  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFDB371  F3 0F 11 8B 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm1
00007FF91DFDB379  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFDB37D  76 1B                       jbe     short loc_7FF91DFDB39A
00007FF91DFDB37F  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDB384  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDB388  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDB38B  E8 48 41 37 00              call    fmodf
00007FF91DFDB390  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDB393  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDB398  EB 1F                       jmp     short loc_7FF91DFDB3B9
00007FF91DFDB39A  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFDB39E  73 19                       jnb     short loc_7FF91DFDB3B9
00007FF91DFDB3A0  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDB3A5  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDB3A9  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDB3AC  E8 27 41 37 00              call    fmodf
00007FF91DFDB3B1  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDB3B4  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDB3B9  F3 44 0F 10 25 4A 9C 76 00  movss   xmm12, cs:dword_7FF91E74500C
00007FF91DFDB3C2  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDB3C5  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDB3CA  F3 0F 11 B3 60 B6 00 00     movss   dword ptr [rbx+0B660h], xmm6
00007FF91DFDB3D2  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFDB3D5  F3 0F 59 BB 50 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA50h]
00007FF91DFDB3DD  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFDB3E2  E8 D9 DB FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDB3E7  F3 44 0F 10 1D 54 A0 76 00  movss   xmm11, cs:dword_7FF91E745444
00007FF91DFDB3F0  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFDB3F3  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFDB3F8  F3 0F 59 AB 00 B7 00 00     mulss   xmm5, dword ptr [rbx+0B700h]
00007FF91DFDB400  F3 0F 59 AB 20 BA 00 00     mulss   xmm5, dword ptr [rbx+0BA20h]
00007FF91DFDB408  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDB40C  73 06                       jnb     short loc_7FF91DFDB414
00007FF91DFDB40E  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDB412  EB 05                       jmp     short loc_7FF91DFDB419
00007FF91DFDB414  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDB419  F3 0F 59 AB F0 B9 00 00     mulss   xmm5, dword ptr [rbx+0B9F0h]
00007FF91DFDB421  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDB424  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDB428  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDB42B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDB42E  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDB436  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDB439  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDB43D  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDB440  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
00007FF91DFDB448  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDB450  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDB454  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
00007FF91DFDB45C  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDB460  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDB463  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDB46B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDB46F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDB473  F3 0F 10 8B 10 B7 00 00     movss   xmm1, dword ptr [rbx+0B710h]
00007FF91DFDB47B  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDB47F  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDB482  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFDB486  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDB48A  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDB48E  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFDB492  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDB496  F3 0F 11 A3 60 B7 00 00     movss   dword ptr [rbx+0B760h], xmm4
00007FF91DFDB49E  72 07                       jb      short loc_7FF91DFDB4A7
00007FF91DFDB4A0  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFDB4A5  EB 05                       jmp     short loc_7FF91DFDB4AC
00007FF91DFDB4A7  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFDB4AC  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDB4AF  73 06                       jnb     short loc_7FF91DFDB4B7
00007FF91DFDB4B1  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFDB4B5  EB 06                       jmp     short loc_7FF91DFDB4BD
00007FF91DFDB4B7  76 04                       jbe     short loc_7FF91DFDB4BD
00007FF91DFDB4B9  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFDB4BD  F3 44 0F 10 83 60 B6 00 00  movss   xmm8, dword ptr [rbx+0B660h]
00007FF91DFDB4C6  F3 0F 59 B3 60 BA 00 00     mulss   xmm6, dword ptr [rbx+0BA60h]
00007FF91DFDB4CE  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFDB4D2  E8 E9 DA FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDB4D7  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFDB4DA  F3 0F 10 83 10 BA 00 00     movss   xmm0, dword ptr [rbx+0BA10h]
00007FF91DFDB4E2  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFDB4E6  72 18                       jb      short loc_7FF91DFDB500
00007FF91DFDB4E8  0F 2F 83 70 B6 00 00        comiss  xmm0, dword ptr [rbx+0B670h]
00007FF91DFDB4EF  76 0F                       jbe     short loc_7FF91DFDB500
00007FF91DFDB4F1  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
00007FF91DFDB4F9  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFDB4FE  EB 08                       jmp     short loc_7FF91DFDB508
00007FF91DFDB500  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
00007FF91DFDB508  0F 2F 3D C1 9D 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFDB50F  F3 0F 59 A3 00 B7 00 00     mulss   xmm4, dword ptr [rbx+0B700h]
00007FF91DFDB517  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFDB51C  F3 0F 59 A3 30 BA 00 00     mulss   xmm4, dword ptr [rbx+0BA30h]
00007FF91DFDB524  72 03                       jb      short loc_7FF91DFDB529
00007FF91DFDB526  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFDB529  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFDB52D  73 06                       jnb     short loc_7FF91DFDB535
00007FF91DFDB52F  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFDB533  EB 05                       jmp     short loc_7FF91DFDB53A
00007FF91DFDB535  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFDB53A  F3 0F 11 BB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm7
00007FF91DFDB542  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFDB547  F3 0F 59 A3 F0 B9 00 00     mulss   xmm4, dword ptr [rbx+0B9F0h]
00007FF91DFDB54F  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFDB552  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDB557  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDB55B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDB55E  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFDB563  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDB567  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDB56A  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDB56E  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFDB572  F3 44 0F 59 8B C0 BB 00 00  mulss   xmm9, dword ptr [rbx+0BBC0h]
00007FF91DFDB57B  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFDB580  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDB583  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDB58B  F3 44 0F 58 8B B0 BB 00 00  addss   xmm9, dword ptr [rbx+0BBB0h]
00007FF91DFDB594  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDB59C  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDB5A1  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDB5A4  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDB5AC  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFDB5B1  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDB5B5  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDB5BA  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFDB5BD  0F 54 05 CC A1 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFDB5C4  0F 57 05 F5 A1 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFDB5CB  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFDB5D0  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFDB5D5  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFDB5DA  F3 44 0F 11 8B 70 B7 00 00  movss   dword ptr [rbx+0B770h], xmm9
00007FF91DFDB5E3  E8 D8 D9 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDB5E8  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFDB5EC  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFDB5F0  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFDB5F5  73 06                       jnb     short loc_7FF91DFDB5FD
00007FF91DFDB5F7  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFDB5FB  EB 06                       jmp     short loc_7FF91DFDB603
00007FF91DFDB5FD  76 04                       jbe     short loc_7FF91DFDB603
00007FF91DFDB5FF  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFDB603  F3 44 0F 59 83 00 B7 00 00  mulss   xmm8, dword ptr [rbx+0B700h]
00007FF91DFDB60C  F3 0F 59 BB 70 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA70h]
00007FF91DFDB614  F3 44 0F 59 05 7B F6 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFDB61D  F3 44 0F 59 83 40 BA 00 00  mulss   xmm8, dword ptr [rbx+0BA40h]
00007FF91DFDB626  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFDB62A  73 06                       jnb     short loc_7FF91DFDB632
00007FF91DFDB62C  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFDB630  EB 05                       jmp     short loc_7FF91DFDB637
00007FF91DFDB632  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFDB637  F3 44 0F 59 83 F0 B9 00 00  mulss   xmm8, dword ptr [rbx+0B9F0h]
00007FF91DFDB640  F3 44 0F 59 8B D0 B6 00 00  mulss   xmm9, dword ptr [rbx+0B6D0h]
00007FF91DFDB649  F3 0F 10 B3 60 B6 00 00     movss   xmm6, dword ptr [rbx+0B660h]
00007FF91DFDB651  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDB655  F3 0F 10 AB 80 B6 00 00     movss   xmm5, dword ptr [rbx+0B680h]
00007FF91DFDB65D  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFDB662  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDB665  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDB668  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDB66C  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDB66F  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
00007FF91DFDB677  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDB67A  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDB682  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
00007FF91DFDB68A  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFDB68F  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDB697  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDB69B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDB69E  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDB6A6  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDB6AA  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDB6AE  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDB6B2  F3 0F 10 83 60 B7 00 00     movss   xmm0, dword ptr [rbx+0B760h]
00007FF91DFDB6BA  F3 0F 59 83 C0 B6 00 00     mulss   xmm0, dword ptr [rbx+0B6C0h]
00007FF91DFDB6C2  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDB6C6  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFDB6CB  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFDB6D0  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDB6D4  F3 0F 59 A3 E0 B6 00 00     mulss   xmm4, dword ptr [rbx+0B6E0h]
00007FF91DFDB6DC  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDB6E0  F3 0F 11 A3 90 B7 00 00     movss   dword ptr [rbx+0B790h], xmm4
00007FF91DFDB6E8  F3 0F 11 B3 70 B6 00 00     movss   dword ptr [rbx+0B670h], xmm6
00007FF91DFDB6F0  F3 0F 11 AB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm5
00007FF91DFDB6F8  F3 0F 58 B3 F0 B6 00 00     addss   xmm6, dword ptr [rbx+0B6F0h]
00007FF91DFDB700  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFDB704  76 1B                       jbe     short loc_7FF91DFDB721
00007FF91DFDB706  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDB70B  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDB70F  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDB712  E8 C1 3D 37 00              call    fmodf
00007FF91DFDB717  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDB71A  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDB71F  EB 1F                       jmp     short loc_7FF91DFDB740
00007FF91DFDB721  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFDB725  73 19                       jnb     short loc_7FF91DFDB740
00007FF91DFDB727  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDB72C  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDB730  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDB733  E8 A0 3D 37 00              call    fmodf
00007FF91DFDB738  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDB73B  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDB740  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDB743  F3 0F 11 B3 60 B6 00 00     movss   dword ptr [rbx+0B660h], xmm6
00007FF91DFDB74B  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDB750  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFDB753  F3 0F 59 BB 50 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA50h]
00007FF91DFDB75B  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFDB760  E8 5B D8 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDB765  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFDB768  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFDB76D  F3 0F 59 AB 00 B7 00 00     mulss   xmm5, dword ptr [rbx+0B700h]
00007FF91DFDB775  F3 0F 59 AB 20 BA 00 00     mulss   xmm5, dword ptr [rbx+0BA20h]
00007FF91DFDB77D  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDB781  73 06                       jnb     short loc_7FF91DFDB789
00007FF91DFDB783  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDB787  EB 05                       jmp     short loc_7FF91DFDB78E
00007FF91DFDB789  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDB78E  F3 0F 59 AB F0 B9 00 00     mulss   xmm5, dword ptr [rbx+0B9F0h]
00007FF91DFDB796  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDB799  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDB79D  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDB7A0  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDB7A3  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDB7AB  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDB7AE  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDB7B2  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDB7B5  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
00007FF91DFDB7BD  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDB7C5  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDB7C9  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
00007FF91DFDB7D1  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDB7D5  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDB7D8  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDB7E0  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDB7E4  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDB7E8  F3 0F 10 8B 10 B7 00 00     movss   xmm1, dword ptr [rbx+0B710h]
00007FF91DFDB7F0  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDB7F4  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDB7F7  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFDB7FB  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDB7FF  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDB803  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFDB807  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDB80B  F3 0F 11 A3 60 B7 00 00     movss   dword ptr [rbx+0B760h], xmm4
00007FF91DFDB813  72 07                       jb      short loc_7FF91DFDB81C
00007FF91DFDB815  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFDB81A  EB 05                       jmp     short loc_7FF91DFDB821
00007FF91DFDB81C  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFDB821  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDB824  73 06                       jnb     short loc_7FF91DFDB82C
00007FF91DFDB826  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFDB82A  EB 06                       jmp     short loc_7FF91DFDB832
00007FF91DFDB82C  76 04                       jbe     short loc_7FF91DFDB832
00007FF91DFDB82E  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFDB832  F3 44 0F 10 83 60 B6 00 00  movss   xmm8, dword ptr [rbx+0B660h]
00007FF91DFDB83B  F3 0F 59 B3 60 BA 00 00     mulss   xmm6, dword ptr [rbx+0BA60h]
00007FF91DFDB843  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFDB847  E8 74 D7 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDB84C  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFDB84F  F3 0F 10 83 10 BA 00 00     movss   xmm0, dword ptr [rbx+0BA10h]
00007FF91DFDB857  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFDB85B  72 18                       jb      short loc_7FF91DFDB875
00007FF91DFDB85D  0F 2F 83 70 B6 00 00        comiss  xmm0, dword ptr [rbx+0B670h]
00007FF91DFDB864  76 0F                       jbe     short loc_7FF91DFDB875
00007FF91DFDB866  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
00007FF91DFDB86E  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFDB873  EB 08                       jmp     short loc_7FF91DFDB87D
00007FF91DFDB875  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
00007FF91DFDB87D  0F 2F 3D 4C 9A 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFDB884  F3 0F 59 A3 00 B7 00 00     mulss   xmm4, dword ptr [rbx+0B700h]
00007FF91DFDB88C  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFDB891  F3 0F 59 A3 30 BA 00 00     mulss   xmm4, dword ptr [rbx+0BA30h]
00007FF91DFDB899  72 03                       jb      short loc_7FF91DFDB89E
00007FF91DFDB89B  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFDB89E  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFDB8A2  73 06                       jnb     short loc_7FF91DFDB8AA
00007FF91DFDB8A4  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFDB8A8  EB 05                       jmp     short loc_7FF91DFDB8AF
00007FF91DFDB8AA  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFDB8AF  F3 0F 11 BB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm7
00007FF91DFDB8B7  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFDB8BC  F3 0F 59 A3 F0 B9 00 00     mulss   xmm4, dword ptr [rbx+0B9F0h]
00007FF91DFDB8C4  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFDB8C7  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDB8CC  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDB8D0  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDB8D3  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFDB8D8  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDB8DC  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDB8DF  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDB8E3  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFDB8E7  F3 44 0F 59 8B C0 BB 00 00  mulss   xmm9, dword ptr [rbx+0BBC0h]
00007FF91DFDB8F0  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFDB8F5  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDB8F8  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDB900  F3 44 0F 58 8B B0 BB 00 00  addss   xmm9, dword ptr [rbx+0BBB0h]
00007FF91DFDB909  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDB911  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDB916  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDB919  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDB921  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFDB926  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDB92A  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDB92F  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFDB932  0F 54 05 57 9E 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFDB939  0F 57 05 80 9E 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFDB940  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFDB945  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFDB94A  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFDB94F  F3 44 0F 11 8B 70 B7 00 00  movss   dword ptr [rbx+0B770h], xmm9
00007FF91DFDB958  E8 63 D6 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDB95D  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFDB961  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFDB965  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFDB96A  73 06                       jnb     short loc_7FF91DFDB972
00007FF91DFDB96C  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFDB970  EB 06                       jmp     short loc_7FF91DFDB978
00007FF91DFDB972  76 04                       jbe     short loc_7FF91DFDB978
00007FF91DFDB974  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFDB978  F3 44 0F 59 83 00 B7 00 00  mulss   xmm8, dword ptr [rbx+0B700h]
00007FF91DFDB981  F3 0F 59 BB 70 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA70h]
00007FF91DFDB989  F3 44 0F 59 05 06 F3 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFDB992  F3 44 0F 59 83 40 BA 00 00  mulss   xmm8, dword ptr [rbx+0BA40h]
00007FF91DFDB99B  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFDB99F  73 06                       jnb     short loc_7FF91DFDB9A7
00007FF91DFDB9A1  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFDB9A5  EB 05                       jmp     short loc_7FF91DFDB9AC
00007FF91DFDB9A7  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFDB9AC  F3 44 0F 59 83 F0 B9 00 00  mulss   xmm8, dword ptr [rbx+0B9F0h]
00007FF91DFDB9B5  F3 44 0F 59 8B D0 B6 00 00  mulss   xmm9, dword ptr [rbx+0B6D0h]
00007FF91DFDB9BE  F3 0F 10 B3 60 B6 00 00     movss   xmm6, dword ptr [rbx+0B660h]
00007FF91DFDB9C6  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDB9CA  F3 0F 10 AB 80 B6 00 00     movss   xmm5, dword ptr [rbx+0B680h]
00007FF91DFDB9D2  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFDB9D7  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDB9DA  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDB9DD  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDB9E1  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDB9E4  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
00007FF91DFDB9EC  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDB9EF  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDB9F7  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
00007FF91DFDB9FF  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFDBA04  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDBA0C  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDBA10  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDBA13  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDBA1B  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDBA1F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDBA23  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDBA27  F3 0F 10 83 60 B7 00 00     movss   xmm0, dword ptr [rbx+0B760h]
00007FF91DFDBA2F  F3 0F 59 83 C0 B6 00 00     mulss   xmm0, dword ptr [rbx+0B6C0h]
00007FF91DFDBA37  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDBA3B  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFDBA40  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFDBA45  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDBA49  F3 0F 59 A3 E0 B6 00 00     mulss   xmm4, dword ptr [rbx+0B6E0h]
00007FF91DFDBA51  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDBA55  F3 0F 11 A3 10 B8 00 00     movss   dword ptr [rbx+0B810h], xmm4
00007FF91DFDBA5D  F3 0F 11 B3 70 B6 00 00     movss   dword ptr [rbx+0B670h], xmm6
00007FF91DFDBA65  F3 0F 11 AB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm5
00007FF91DFDBA6D  F3 0F 58 B3 F0 B6 00 00     addss   xmm6, dword ptr [rbx+0B6F0h]
00007FF91DFDBA75  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFDBA79  76 1B                       jbe     short loc_7FF91DFDBA96
00007FF91DFDBA7B  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDBA80  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDBA84  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDBA87  E8 4C 3A 37 00              call    fmodf
00007FF91DFDBA8C  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDBA8F  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDBA94  EB 1F                       jmp     short loc_7FF91DFDBAB5
00007FF91DFDBA96  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFDBA9A  73 19                       jnb     short loc_7FF91DFDBAB5
00007FF91DFDBA9C  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDBAA1  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDBAA5  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDBAA8  E8 2B 3A 37 00              call    fmodf
00007FF91DFDBAAD  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDBAB0  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDBAB5  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDBAB8  F3 0F 11 B3 60 B6 00 00     movss   dword ptr [rbx+0B660h], xmm6
00007FF91DFDBAC0  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDBAC5  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFDBAC8  F3 0F 59 BB 50 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA50h]
00007FF91DFDBAD0  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFDBAD5  E8 E6 D4 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDBADA  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFDBADD  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFDBAE2  F3 0F 59 AB 00 B7 00 00     mulss   xmm5, dword ptr [rbx+0B700h]
00007FF91DFDBAEA  F3 0F 59 AB 20 BA 00 00     mulss   xmm5, dword ptr [rbx+0BA20h]
00007FF91DFDBAF2  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDBAF6  73 06                       jnb     short loc_7FF91DFDBAFE
00007FF91DFDBAF8  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDBAFC  EB 05                       jmp     short loc_7FF91DFDBB03
00007FF91DFDBAFE  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDBB03  F3 0F 59 AB F0 B9 00 00     mulss   xmm5, dword ptr [rbx+0B9F0h]
00007FF91DFDBB0B  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDBB0E  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDBB12  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDBB15  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDBB18  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDBB20  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDBB23  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDBB27  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDBB2A  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
00007FF91DFDBB32  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDBB3A  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDBB3E  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
00007FF91DFDBB46  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDBB4A  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDBB4D  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDBB55  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDBB59  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDBB5D  F3 0F 10 8B 10 B7 00 00     movss   xmm1, dword ptr [rbx+0B710h]
00007FF91DFDBB65  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDBB69  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDBB6C  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFDBB70  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDBB74  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDBB78  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFDBB7C  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDBB80  F3 0F 11 A3 60 B7 00 00     movss   dword ptr [rbx+0B760h], xmm4
00007FF91DFDBB88  72 07                       jb      short loc_7FF91DFDBB91
00007FF91DFDBB8A  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFDBB8F  EB 05                       jmp     short loc_7FF91DFDBB96
00007FF91DFDBB91  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFDBB96  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDBB99  73 06                       jnb     short loc_7FF91DFDBBA1
00007FF91DFDBB9B  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFDBB9F  EB 06                       jmp     short loc_7FF91DFDBBA7
00007FF91DFDBBA1  76 04                       jbe     short loc_7FF91DFDBBA7
00007FF91DFDBBA3  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFDBBA7  F3 44 0F 10 83 60 B6 00 00  movss   xmm8, dword ptr [rbx+0B660h]
00007FF91DFDBBB0  F3 0F 59 B3 60 BA 00 00     mulss   xmm6, dword ptr [rbx+0BA60h]
00007FF91DFDBBB8  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFDBBBC  E8 FF D3 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDBBC1  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFDBBC4  F3 0F 10 83 10 BA 00 00     movss   xmm0, dword ptr [rbx+0BA10h]
00007FF91DFDBBCC  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFDBBD0  72 18                       jb      short loc_7FF91DFDBBEA
00007FF91DFDBBD2  0F 2F 83 70 B6 00 00        comiss  xmm0, dword ptr [rbx+0B670h]
00007FF91DFDBBD9  76 0F                       jbe     short loc_7FF91DFDBBEA
00007FF91DFDBBDB  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
00007FF91DFDBBE3  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFDBBE8  EB 08                       jmp     short loc_7FF91DFDBBF2
00007FF91DFDBBEA  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
00007FF91DFDBBF2  0F 2F 3D D7 96 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFDBBF9  F3 0F 59 A3 00 B7 00 00     mulss   xmm4, dword ptr [rbx+0B700h]
00007FF91DFDBC01  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFDBC06  F3 0F 59 A3 30 BA 00 00     mulss   xmm4, dword ptr [rbx+0BA30h]
00007FF91DFDBC0E  72 03                       jb      short loc_7FF91DFDBC13
00007FF91DFDBC10  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFDBC13  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFDBC17  73 06                       jnb     short loc_7FF91DFDBC1F
00007FF91DFDBC19  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFDBC1D  EB 05                       jmp     short loc_7FF91DFDBC24
00007FF91DFDBC1F  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFDBC24  F3 0F 11 BB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm7
00007FF91DFDBC2C  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFDBC31  F3 0F 59 A3 F0 B9 00 00     mulss   xmm4, dword ptr [rbx+0B9F0h]
00007FF91DFDBC39  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFDBC3C  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDBC41  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDBC45  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDBC48  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFDBC4D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDBC51  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDBC54  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDBC58  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFDBC5C  F3 44 0F 59 8B C0 BB 00 00  mulss   xmm9, dword ptr [rbx+0BBC0h]
00007FF91DFDBC65  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFDBC6A  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDBC6D  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDBC75  F3 44 0F 58 8B B0 BB 00 00  addss   xmm9, dword ptr [rbx+0BBB0h]
00007FF91DFDBC7E  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDBC86  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDBC8B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDBC8E  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDBC96  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFDBC9B  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDBC9F  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFDBCA4  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFDBCA7  0F 54 05 E2 9A 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFDBCAE  0F 57 05 0B 9B 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFDBCB5  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFDBCBA  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFDBCBF  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFDBCC4  F3 44 0F 11 8B 70 B7 00 00  movss   dword ptr [rbx+0B770h], xmm9
00007FF91DFDBCCD  E8 EE D2 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDBCD2  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFDBCD6  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFDBCDA  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFDBCDF  73 06                       jnb     short loc_7FF91DFDBCE7
00007FF91DFDBCE1  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFDBCE5  EB 06                       jmp     short loc_7FF91DFDBCED
00007FF91DFDBCE7  76 04                       jbe     short loc_7FF91DFDBCED
00007FF91DFDBCE9  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFDBCED  F3 44 0F 59 83 00 B7 00 00  mulss   xmm8, dword ptr [rbx+0B700h]
00007FF91DFDBCF6  F3 0F 59 BB 70 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA70h]
00007FF91DFDBCFE  F3 44 0F 59 05 91 EF 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFDBD07  F3 44 0F 59 83 40 BA 00 00  mulss   xmm8, dword ptr [rbx+0BA40h]
00007FF91DFDBD10  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFDBD14  73 06                       jnb     short loc_7FF91DFDBD1C
00007FF91DFDBD16  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFDBD1A  EB 05                       jmp     short loc_7FF91DFDBD21
00007FF91DFDBD1C  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFDBD21  F3 44 0F 59 83 F0 B9 00 00  mulss   xmm8, dword ptr [rbx+0B9F0h]
00007FF91DFDBD2A  F3 44 0F 59 8B D0 B6 00 00  mulss   xmm9, dword ptr [rbx+0B6D0h]
00007FF91DFDBD33  F3 0F 10 B3 60 B6 00 00     movss   xmm6, dword ptr [rbx+0B660h]
00007FF91DFDBD3B  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFDBD3F  F3 0F 10 AB 80 B6 00 00     movss   xmm5, dword ptr [rbx+0B680h]
00007FF91DFDBD47  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFDBD4C  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDBD4F  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDBD52  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDBD56  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDBD59  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
00007FF91DFDBD61  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDBD64  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDBD6C  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
00007FF91DFDBD74  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFDBD79  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDBD81  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDBD85  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDBD88  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDBD90  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDBD94  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDBD98  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDBD9C  F3 0F 10 83 60 B7 00 00     movss   xmm0, dword ptr [rbx+0B760h]
00007FF91DFDBDA4  F3 0F 59 83 C0 B6 00 00     mulss   xmm0, dword ptr [rbx+0B6C0h]
00007FF91DFDBDAC  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDBDB0  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFDBDB5  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFDBDBA  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDBDBE  F3 0F 59 A3 E0 B6 00 00     mulss   xmm4, dword ptr [rbx+0B6E0h]
00007FF91DFDBDC6  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDBDCA  F3 0F 11 A3 90 B8 00 00     movss   dword ptr [rbx+0B890h], xmm4
00007FF91DFDBDD2  F3 0F 11 B3 70 B6 00 00     movss   dword ptr [rbx+0B670h], xmm6
00007FF91DFDBDDA  F3 0F 11 AB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm5
00007FF91DFDBDE2  F3 0F 58 B3 F0 B6 00 00     addss   xmm6, dword ptr [rbx+0B6F0h]
00007FF91DFDBDEA  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFDBDEE  76 1B                       jbe     short loc_7FF91DFDBE0B
00007FF91DFDBDF0  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDBDF5  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDBDF9  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDBDFC  E8 D7 36 37 00              call    fmodf
00007FF91DFDBE01  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDBE04  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDBE09  EB 1F                       jmp     short loc_7FF91DFDBE2A
00007FF91DFDBE0B  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFDBE0F  73 19                       jnb     short loc_7FF91DFDBE2A
00007FF91DFDBE11  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFDBE16  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFDBE1A  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFDBE1D  E8 B6 36 37 00              call    fmodf
00007FF91DFDBE22  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDBE25  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFDBE2A  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFDBE2D  F3 0F 11 B3 60 B6 00 00     movss   dword ptr [rbx+0B660h], xmm6
00007FF91DFDBE35  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDBE3A  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFDBE3D  F3 0F 59 BB 50 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA50h]
00007FF91DFDBE45  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFDBE4A  E8 71 D1 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDBE4F  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFDBE52  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFDBE57  F3 0F 59 AB 00 B7 00 00     mulss   xmm5, dword ptr [rbx+0B700h]
00007FF91DFDBE5F  F3 0F 59 AB 20 BA 00 00     mulss   xmm5, dword ptr [rbx+0BA20h]
00007FF91DFDBE67  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFDBE6B  73 06                       jnb     short loc_7FF91DFDBE73
00007FF91DFDBE6D  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFDBE71  EB 05                       jmp     short loc_7FF91DFDBE78
00007FF91DFDBE73  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFDBE78  F3 0F 59 AB F0 B9 00 00     mulss   xmm5, dword ptr [rbx+0B9F0h]
00007FF91DFDBE80  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFDBE83  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDBE87  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDBE8A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDBE8D  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDBE95  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDBE98  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDBE9C  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDBE9F  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
00007FF91DFDBEA7  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDBEAF  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFDBEB3  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
00007FF91DFDBEBB  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDBEBF  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDBEC2  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDBECA  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDBECE  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDBED2  F3 0F 10 8B 10 B7 00 00     movss   xmm1, dword ptr [rbx+0B710h]
00007FF91DFDBEDA  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDBEDE  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFDBEE1  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFDBEE5  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDBEE9  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFDBEED  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFDBEF1  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDBEF5  F3 0F 11 A3 60 B7 00 00     movss   dword ptr [rbx+0B760h], xmm4
00007FF91DFDBEFD  72 07                       jb      short loc_7FF91DFDBF06
00007FF91DFDBEFF  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFDBF04  EB 05                       jmp     short loc_7FF91DFDBF0B
00007FF91DFDBF06  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFDBF0B  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFDBF0E  73 06                       jnb     short loc_7FF91DFDBF16
00007FF91DFDBF10  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFDBF14  EB 06                       jmp     short loc_7FF91DFDBF1C
00007FF91DFDBF16  76 04                       jbe     short loc_7FF91DFDBF1C
00007FF91DFDBF18  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFDBF1C  F3 44 0F 10 83 60 B6 00 00  movss   xmm8, dword ptr [rbx+0B660h]
00007FF91DFDBF25  F3 0F 59 B3 60 BA 00 00     mulss   xmm6, dword ptr [rbx+0BA60h]
00007FF91DFDBF2D  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFDBF31  E8 8A D0 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDBF36  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFDBF39  F3 0F 10 83 10 BA 00 00     movss   xmm0, dword ptr [rbx+0BA10h]
00007FF91DFDBF41  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFDBF45  72 18                       jb      short loc_7FF91DFDBF5F
00007FF91DFDBF47  0F 2F 83 70 B6 00 00        comiss  xmm0, dword ptr [rbx+0B670h]
00007FF91DFDBF4E  76 0F                       jbe     short loc_7FF91DFDBF5F
00007FF91DFDBF50  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
00007FF91DFDBF58  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFDBF5D  EB 08                       jmp     short loc_7FF91DFDBF67
00007FF91DFDBF5F  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
00007FF91DFDBF67  0F 2F 3D 62 93 76 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFDBF6E  F3 0F 59 A3 00 B7 00 00     mulss   xmm4, dword ptr [rbx+0B700h]
00007FF91DFDBF76  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFDBF7B  F3 0F 59 A3 30 BA 00 00     mulss   xmm4, dword ptr [rbx+0BA30h]
00007FF91DFDBF83  72 03                       jb      short loc_7FF91DFDBF88
00007FF91DFDBF85  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFDBF88  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFDBF8C  73 06                       jnb     short loc_7FF91DFDBF94
00007FF91DFDBF8E  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFDBF92  EB 05                       jmp     short loc_7FF91DFDBF99
00007FF91DFDBF94  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFDBF99  F3 0F 11 BB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm7
00007FF91DFDBFA1  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFDBFA6  F3 0F 59 A3 F0 B9 00 00     mulss   xmm4, dword ptr [rbx+0B9F0h]
00007FF91DFDBFAE  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFDBFB1  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFDBFB6  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFDBFBA  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDBFBD  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFDBFC2  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDBFC6  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDBFC9  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFDBFCD  44 0F 28 C2                 movaps  xmm8, xmm2
00007FF91DFDBFD1  F3 44 0F 59 83 C0 BB 00 00  mulss   xmm8, dword ptr [rbx+0BBC0h]
00007FF91DFDBFDA  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFDBFDF  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDBFE2  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDBFEA  F3 44 0F 58 83 B0 BB 00 00  addss   xmm8, dword ptr [rbx+0BBB0h]
00007FF91DFDBFF3  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDBFFB  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFDC000  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDC003  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDC00B  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFDC010  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDC014  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFDC019  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFDC01C  0F 54 05 6D 97 76 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFDC023  0F 57 05 96 97 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFDC02A  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFDC02F  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFDC034  F3 44 0F 59 C6              mulss   xmm8, xmm6
00007FF91DFDC039  F3 44 0F 11 83 70 B7 00 00  movss   dword ptr [rbx+0B770h], xmm8
00007FF91DFDC042  E8 79 CF FE FF              call    sub_7FF91DFC8FC0
00007FF91DFDC047  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFDC04B  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFDC050  73 06                       jnb     short loc_7FF91DFDC058
00007FF91DFDC052  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFDC056  EB 06                       jmp     short loc_7FF91DFDC05E
00007FF91DFDC058  76 04                       jbe     short loc_7FF91DFDC05E
00007FF91DFDC05A  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFDC05E  F3 0F 59 83 00 B7 00 00     mulss   xmm0, dword ptr [rbx+0B700h]
00007FF91DFDC066  F3 0F 59 BB 70 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA70h]
00007FF91DFDC06E  F3 0F 59 05 22 EC 60 00     mulss   xmm0, cs:dword_7FF91E5EAC98
00007FF91DFDC076  F3 0F 59 83 40 BA 00 00     mulss   xmm0, dword ptr [rbx+0BA40h]
00007FF91DFDC07E  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFDC082  72 09                       jb      short loc_7FF91DFDC08D
00007FF91DFDC084  44 0F 28 F8                 movaps  xmm15, xmm0
00007FF91DFDC088  F3 45 0F 5D FD              minss   xmm15, xmm13
00007FF91DFDC08D  F3 44 0F 59 BB F0 B9 00 00  mulss   xmm15, dword ptr [rbx+0B9F0h]
00007FF91DFDC096  F3 44 0F 59 83 D0 B6 00 00  mulss   xmm8, dword ptr [rbx+0B6D0h]
00007FF91DFDC09F  F3 0F 10 AB 60 B6 00 00     movss   xmm5, dword ptr [rbx+0B660h]
00007FF91DFDC0A7  41 0F 28 D7                 movaps  xmm2, xmm15
00007FF91DFDC0AB  F3 0F 10 B3 80 B6 00 00     movss   xmm6, dword ptr [rbx+0B680h]
00007FF91DFDC0B3  F3 41 0F 59 D7              mulss   xmm2, xmm15
00007FF91DFDC0B8  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFDC0BB  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDC0BE  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
00007FF91DFDC0C6  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFDC0C9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDC0CD  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDC0D0  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
00007FF91DFDC0D8  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
00007FF91DFDC0E0  F3 41 0F 59 DF              mulss   xmm3, xmm15
00007FF91DFDC0E5  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
00007FF91DFDC0ED  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDC0F1  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDC0F4  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
00007FF91DFDC0FC  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFDC100  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFDC104  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFDC108  F3 0F 10 83 60 B7 00 00     movss   xmm0, dword ptr [rbx+0B760h]
00007FF91DFDC110  F3 0F 59 83 C0 B6 00 00     mulss   xmm0, dword ptr [rbx+0B6C0h]
00007FF91DFDC118  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFDC11C  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFDC121  F3 41 0F 58 E7              addss   xmm4, xmm15
00007FF91DFDC126  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFDC12A  F3 0F 59 A3 E0 B6 00 00     mulss   xmm4, dword ptr [rbx+0B6E0h]
00007FF91DFDC132  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFDC136  F3 0F 11 A3 10 B9 00 00     movss   dword ptr [rbx+0B910h], xmm4
00007FF91DFDC13E  F3 0F 10 93 80 B9 00 00     movss   xmm2, dword ptr [rbx+0B980h]
00007FF91DFDC146  F3 0F 11 AB 40 B7 00 00     movss   dword ptr [rbx+0B740h], xmm5
00007FF91DFDC14E  F3 0F 11 B3 20 B7 00 00     movss   dword ptr [rbx+0B720h], xmm6
00007FF91DFDC156  F3 0F 10 83 90 B8 00 00     movss   xmm0, dword ptr [rbx+0B890h]
00007FF91DFDC15E  F3 0F 58 83 80 B8 00 00     addss   xmm0, dword ptr [rbx+0B880h]
00007FF91DFDC166  F3 0F 10 8B 10 B9 00 00     movss   xmm1, dword ptr [rbx+0B910h]
00007FF91DFDC16E  F3 0F 58 8B 00 B8 00 00     addss   xmm1, dword ptr [rbx+0B800h]
00007FF91DFDC176  F3 0F 10 AB 00 B9 00 00     movss   xmm5, dword ptr [rbx+0B900h]
00007FF91DFDC17E  F3 0F 58 AB 10 B8 00 00     addss   xmm5, dword ptr [rbx+0B810h]
00007FF91DFDC186  F3 0F 59 83 A0 BA 00 00     mulss   xmm0, dword ptr [rbx+0BAA0h]
00007FF91DFDC18E  F3 0F 59 8B B0 BA 00 00     mulss   xmm1, dword ptr [rbx+0BAB0h]
00007FF91DFDC196  F3 0F 59 AB 90 BA 00 00     mulss   xmm5, dword ptr [rbx+0BA90h]
00007FF91DFDC19E  F3 0F 58 93 90 B7 00 00     addss   xmm2, dword ptr [rbx+0B790h]
00007FF91DFDC1A6  F3 0F 59 93 80 BA 00 00     mulss   xmm2, dword ptr [rbx+0BA80h]
00007FF91DFDC1AE  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFDC1B2  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDC1B6  F3 0F 10 83 70 B9 00 00     movss   xmm0, dword ptr [rbx+0B970h]
00007FF91DFDC1BE  F3 0F 58 83 A0 B7 00 00     addss   xmm0, dword ptr [rbx+0B7A0h]
00007FF91DFDC1C6  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDC1CA  F3 0F 10 8B F0 B8 00 00     movss   xmm1, dword ptr [rbx+0B8F0h]
00007FF91DFDC1D2  F3 0F 59 83 C0 BA 00 00     mulss   xmm0, dword ptr [rbx+0BAC0h]
00007FF91DFDC1DA  F3 0F 58 8B 20 B8 00 00     addss   xmm1, dword ptr [rbx+0B820h]
00007FF91DFDC1E2  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDC1E6  F3 0F 10 83 A0 B8 00 00     movss   xmm0, dword ptr [rbx+0B8A0h]
00007FF91DFDC1EE  F3 0F 58 83 70 B8 00 00     addss   xmm0, dword ptr [rbx+0B870h]
00007FF91DFDC1F6  F3 0F 59 8B D0 BA 00 00     mulss   xmm1, dword ptr [rbx+0BAD0h]
00007FF91DFDC1FE  F3 0F 59 83 E0 BA 00 00     mulss   xmm0, dword ptr [rbx+0BAE0h]
00007FF91DFDC206  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDC20A  F3 0F 10 8B 20 B9 00 00     movss   xmm1, dword ptr [rbx+0B920h]
00007FF91DFDC212  F3 0F 58 8B F0 B7 00 00     addss   xmm1, dword ptr [rbx+0B7F0h]
00007FF91DFDC21A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDC21E  F3 0F 10 83 60 B9 00 00     movss   xmm0, dword ptr [rbx+0B960h]
00007FF91DFDC226  F3 0F 59 8B F0 BA 00 00     mulss   xmm1, dword ptr [rbx+0BAF0h]
00007FF91DFDC22E  F3 0F 58 83 B0 B7 00 00     addss   xmm0, dword ptr [rbx+0B7B0h]
00007FF91DFDC236  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDC23A  F3 0F 10 8B 30 B8 00 00     movss   xmm1, dword ptr [rbx+0B830h]
00007FF91DFDC242  F3 0F 58 8B E0 B8 00 00     addss   xmm1, dword ptr [rbx+0B8E0h]
00007FF91DFDC24A  F3 0F 59 83 00 BB 00 00     mulss   xmm0, dword ptr [rbx+0BB00h]
00007FF91DFDC252  F3 0F 59 8B 10 BB 00 00     mulss   xmm1, dword ptr [rbx+0BB10h]
00007FF91DFDC25A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDC25E  F3 0F 10 83 B0 B8 00 00     movss   xmm0, dword ptr [rbx+0B8B0h]
00007FF91DFDC266  F3 0F 58 83 60 B8 00 00     addss   xmm0, dword ptr [rbx+0B860h]
00007FF91DFDC26E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDC272  F3 0F 10 8B E0 B7 00 00     movss   xmm1, dword ptr [rbx+0B7E0h]
00007FF91DFDC27A  F3 0F 59 83 20 BB 00 00     mulss   xmm0, dword ptr [rbx+0BB20h]
00007FF91DFDC282  F3 0F 58 8B 30 B9 00 00     addss   xmm1, dword ptr [rbx+0B930h]
00007FF91DFDC28A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDC28E  F3 0F 10 83 50 B9 00 00     movss   xmm0, dword ptr [rbx+0B950h]
00007FF91DFDC296  F3 0F 59 8B 30 BB 00 00     mulss   xmm1, dword ptr [rbx+0BB30h]
00007FF91DFDC29E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDC2A2  F3 0F 58 83 C0 B7 00 00     addss   xmm0, dword ptr [rbx+0B7C0h]
00007FF91DFDC2AA  F3 0F 10 93 B0 B9 00 00     movss   xmm2, dword ptr [rbx+0B9B0h]
00007FF91DFDC2B2  F3 0F 10 8B D0 B8 00 00     movss   xmm1, dword ptr [rbx+0B8D0h]
00007FF91DFDC2BA  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFDC2BD  F3 0F 59 A3 B0 BC 00 00     mulss   xmm4, dword ptr [rbx+0BCB0h]
00007FF91DFDC2C5  F3 0F 59 83 40 BB 00 00     mulss   xmm0, dword ptr [rbx+0BB40h]
00007FF91DFDC2CD  F3 0F 58 A3 C0 B9 00 00     addss   xmm4, dword ptr [rbx+0B9C0h]
00007FF91DFDC2D5  F3 0F 58 8B 40 B8 00 00     addss   xmm1, dword ptr [rbx+0B840h]
00007FF91DFDC2DD  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDC2E1  F3 0F 10 83 C0 B8 00 00     movss   xmm0, dword ptr [rbx+0B8C0h]
00007FF91DFDC2E9  F3 0F 58 83 50 B8 00 00     addss   xmm0, dword ptr [rbx+0B850h]
00007FF91DFDC2F1  F3 0F 59 8B 50 BB 00 00     mulss   xmm1, dword ptr [rbx+0BB50h]
00007FF91DFDC2F9  F3 0F 59 83 60 BB 00 00     mulss   xmm0, dword ptr [rbx+0BB60h]
00007FF91DFDC301  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDC305  F3 0F 10 8B 40 B9 00 00     movss   xmm1, dword ptr [rbx+0B940h]
00007FF91DFDC30D  F3 0F 58 8B D0 B7 00 00     addss   xmm1, dword ptr [rbx+0B7D0h]
00007FF91DFDC315  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFDC319  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFDC31C  F3 0F 59 8B 70 BB 00 00     mulss   xmm1, dword ptr [rbx+0BB70h]
00007FF91DFDC324  F3 0F 11 A3 B0 B9 00 00     movss   dword ptr [rbx+0B9B0h], xmm4
00007FF91DFDC32C  F3 0F 59 83 C0 BC 00 00     mulss   xmm0, dword ptr [rbx+0BCC0h]
00007FF91DFDC334  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFDC338  F3 0F 58 C4                 addss   xmm0, xmm4
00007FF91DFDC33C  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFDC33F  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFDC343  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFDC346  F3 0F 59 83 B0 BC 00 00     mulss   xmm0, dword ptr [rbx+0BCB0h]
00007FF91DFDC34E  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFDC352  F3 0F 11 83 A0 B9 00 00     movss   dword ptr [rbx+0B9A0h], xmm0
00007FF91DFDC35A  F3 0F 10 93 00 BD 00 00     movss   xmm2, dword ptr [rbx+0BD00h]
00007FF91DFDC362  F3 0F 59 9B 90 B9 00 00     mulss   xmm3, dword ptr [rbx+0B990h]
00007FF91DFDC36A  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFDC36E  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFDC372  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFDC376  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFDC37A  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFDC37E  F3 0F 11 A3 80 B7 00 00     movss   dword ptr [rbx+0B780h], xmm4
00007FF91DFDC386  F3 0F 11 A3 00 B2 00 00     movss   dword ptr [rbx+0B200h], xmm4
00007FF91DFDC38E  44 0F 2E AB 00 8D 01 00     ucomiss xmm13, dword ptr [rbx+18D00h]
00007FF91DFDC396  75 28                       jnz     short loc_7FF91DFDC3C0
00007FF91DFDC398  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
00007FF91DFDC3A1  F3 0F 11 83 80 A5 00 00     movss   dword ptr [rbx+0A580h], xmm0
00007FF91DFDC3A9  C7 83 00 8D 01 00 00 00 00 00  mov     dword ptr [rbx+18D00h], 0
00007FF91DFDC3B3  0F 1F 40 00                 nop     dword ptr [rax+00h]
00007FF91DFDC3B7  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00007FF91DFDC3C0  8B 83 F0 CD 00 00           mov     eax, [rbx+0CDF0h]
00007FF91DFDC3C6  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
00007FF91DFDC3CE  48 8B 0F                    mov     rcx, [rdi]
00007FF91DFDC3D1  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
00007FF91DFDC3D6  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
00007FF91DFDC3DB  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
00007FF91DFDC3E0  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
00007FF91DFDC3E5  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
00007FF91DFDC3EA  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
00007FF91DFDC3EF  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
00007FF91DFDC3F4  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
00007FF91DFDC3F9  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
00007FF91DFDC3FF  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
00007FF91DFDC405  89 01                       mov     [rcx], eax
00007FF91DFDC407  8B 83 F0 CD 00 00           mov     eax, [rbx+0CDF0h]
00007FF91DFDC40D  48 8B 4F 08                 mov     rcx, [rdi+8]
00007FF91DFDC411  49 8B 5B 18                 mov     rbx, [r11+18h]
00007FF91DFDC415  89 01                       mov     [rcx], eax
00007FF91DFDC417  49 8B E3                    mov     rsp, r11
00007FF91DFDC41A  5F                          pop     rdi
00007FF91DFDC41B  C3                          retn
