; sub_180378690 @ 0x180378690 (RVA 0x378690) size=0x3D8C

0000000180378690  48 8B C4                    mov     rax, rsp
0000000180378693  48 89 58 10                 mov     [rax+10h], rbx
0000000180378697  57                          push    rdi
0000000180378698  48 81 EC C0 00 00 00        sub     rsp, 0C0h
000000018037869F  F3 0F 10 A1 80 A5 00 00     movss   xmm4, dword ptr [rcx+0A580h]
00000001803786A7  48 8B FA                    mov     rdi, rdx
00000001803786AA  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
00000001803786AE  48 8B D9                    mov     rbx, rcx
00000001803786B1  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
00000001803786B5  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00000001803786BA  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00000001803786BF  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00000001803786C4  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00000001803786C9  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00000001803786CE  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00000001803786D4  F3 44 0F 10 2D D7 C9 76 00  movss   xmm13, cs:dword_180AE50B4
00000001803786DD  44 0F 2E A9 00 8D 01 00     ucomiss xmm13, dword ptr [rcx+18D00h]
00000001803786E5  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00000001803786EB  45 0F 57 F6                 xorps   xmm14, xmm14
00000001803786EF  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
00000001803786F9  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00000001803786FF  75 16                       jnz     short loc_180378717
0000000180378701  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
000000018037870A  0F 57 E4                    xorps   xmm4, xmm4
000000018037870D  C7 81 80 A5 00 00 00 00 00 00  mov     dword ptr [rcx+0A580h], 0
0000000180378717  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
000000018037871F  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
0000000180378727  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
000000018037872F  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
0000000180378737  F3 0F 59 05 85 26 61 00     mulss   xmm0, cs:dword_18098ADC4
000000018037873F  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
0000000180378747  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
000000018037874F  F3 0F 2C D0                 cvttss2si edx, xmm0
0000000180378753  85 D2                       test    edx, edx
0000000180378755  75 07                       jnz     short loc_18037875E
0000000180378757  BA 01 00 00 00              mov     edx, 1
000000018037875C  EB 24                       jmp     short loc_180378782
000000018037875E  8B C2                       mov     eax, edx
0000000180378760  25 00 00 20 00              and     eax, 200000h
0000000180378765  0F BA E2 17                 bt      edx, 17h
0000000180378769  73 08                       jnb     short loc_180378773
000000018037876B  85 C0                       test    eax, eax
000000018037876D  75 0C                       jnz     short loc_18037877B
000000018037876F  03 D2                       add     edx, edx
0000000180378771  EB 0F                       jmp     short loc_180378782
0000000180378773  85 C0                       test    eax, eax
0000000180378775  74 04                       jz      short loc_18037877B
0000000180378777  03 D2                       add     edx, edx
0000000180378779  EB 07                       jmp     short loc_180378782
000000018037877B  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
0000000180378782  F3 0F 10 9B 10 A5 00 00     movss   xmm3, dword ptr [rbx+0A510h]
000000018037878A  8B C2                       mov     eax, edx
000000018037878C  F3 0F 10 B3 F0 A4 00 00     movss   xmm6, dword ptr [rbx+0A4F0h]
0000000180378794  25 FF FF FF 00              and     eax, 0FFFFFFh
0000000180378799  F3 44 0F 10 83 B0 A5 00 00  movss   xmm8, dword ptr [rbx+0A5B0h]
00000001803787A2  8B CA                       mov     ecx, edx
00000001803787A4  F3 0F 10 BB C0 A5 00 00     movss   xmm7, dword ptr [rbx+0A5C0h]
00000001803787AC  81 CA 00 00 00 FF           or      edx, 0FF000000h
00000001803787B2  F3 0F 59 CA                 mulss   xmm1, xmm2
00000001803787B6  81 E1 00 00 00 01           and     ecx, 1000000h
00000001803787BC  C7 83 F0 A5 00 00 00 00 00 00  mov     dword ptr [rbx+0A5F0h], 0
00000001803787C6  F3 0F 11 9B 20 A5 00 00     movss   dword ptr [rbx+0A520h], xmm3
00000001803787CE  45 0F 57 D2                 xorps   xmm10, xmm10
00000001803787D2  0F 44 D0                    cmovz   edx, eax
00000001803787D5  F3 0F 11 B3 00 A5 00 00     movss   dword ptr [rbx+0A500h], xmm6
00000001803787DD  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
00000001803787E3  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
00000001803787E9  8B 83 30 A6 00 00           mov     eax, [rbx+0A630h]
00000001803787EF  66 0F 6E C2                 movd    xmm0, edx
00000001803787F3  0F 5B C0                    cvtdq2ps xmm0, xmm0
00000001803787F6  89 83 40 A6 00 00           mov     [rbx+0A640h], eax
00000001803787FC  F3 0F 11 A3 A0 A5 00 00     movss   dword ptr [rbx+0A5A0h], xmm4
0000000180378804  F3 0F 59 05 64 24 61 00     mulss   xmm0, cs:dword_18098AC70
000000018037880C  F3 44 0F 11 83 D0 A5 00 00  movss   dword ptr [rbx+0A5D0h], xmm8
0000000180378815  F3 0F 11 BB E0 A5 00 00     movss   dword ptr [rbx+0A5E0h], xmm7
000000018037881D  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
0000000180378825  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
000000018037882D  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
0000000180378835  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180378839  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
0000000180378841  F3 0F 5C CA                 subss   xmm1, xmm2
0000000180378845  F3 0F 10 93 50 A5 00 00     movss   xmm2, dword ptr [rbx+0A550h]
000000018037884D  F3 0F 11 93 60 A5 00 00     movss   dword ptr [rbx+0A560h], xmm2
0000000180378855  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180378859  F3 0F 10 83 30 A5 00 00     movss   xmm0, dword ptr [rbx+0A530h]
0000000180378861  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180378865  F3 0F 11 83 40 A5 00 00     movss   dword ptr [rbx+0A540h], xmm0
000000018037886D  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180378871  0F 28 C2                    movaps  xmm0, xmm2
0000000180378874  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
000000018037887C  F3 0F 10 8B 70 A5 00 00     movss   xmm1, dword ptr [rbx+0A570h]
0000000180378884  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180378888  F3 0F 59 F2                 mulss   xmm6, xmm2
000000018037888C  F3 0F 11 8B 90 A5 00 00     movss   dword ptr [rbx+0A590h], xmm1
0000000180378894  F3 0F 11 93 00 A6 00 00     movss   dword ptr [rbx+0A600h], xmm2
000000018037889C  F3 0F 5C F0                 subss   xmm6, xmm0
00000001803788A0  0F 28 C4                    movaps  xmm0, xmm4
00000001803788A3  F3 0F 59 C2                 mulss   xmm0, xmm2
00000001803788A7  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803788AB  F3 0F 58 F1                 addss   xmm6, xmm1
00000001803788AF  F3 0F 58 DC                 addss   xmm3, xmm4
00000001803788B3  F3 0F 11 B3 10 A6 00 00     movss   dword ptr [rbx+0A610h], xmm6
00000001803788BB  F3 0F 11 9B 20 A6 00 00     movss   dword ptr [rbx+0A620h], xmm3
00000001803788C3  0F 28 CB                    movaps  xmm1, xmm3
00000001803788C6  F3 0F 58 9B 60 A6 00 00     addss   xmm3, dword ptr [rbx+0A660h]
00000001803788CE  41 0F 2F DE                 comiss  xmm3, xmm14
00000001803788D2  72 05                       jb      short loc_1803788D9
00000001803788D4  0F 57 C0                    xorps   xmm0, xmm0
00000001803788D7  EB 03                       jmp     short loc_1803788DC
00000001803788D9  0F 5A C3                    cvtps2pd xmm0, xmm3
00000001803788DC  41 0F 2E CE                 ucomiss xmm1, xmm14
00000001803788E0  F3 44 0F 10 3D FB CB 76 00  movss   xmm15, cs:dword_180AE54E4
00000001803788E9  75 06                       jnz     short loc_1803788F1
00000001803788EB  41 0F 28 EF                 movaps  xmm5, xmm15
00000001803788EF  EB 04                       jmp     short loc_1803788F5
00000001803788F1  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00000001803788F5  41 0F 2F EE                 comiss  xmm5, xmm14
00000001803788F9  F3 0F 11 AB 30 A6 00 00     movss   dword ptr [rbx+0A630h], xmm5
0000000180378901  73 06                       jnb     short loc_180378909
0000000180378903  41 0F 28 EF                 movaps  xmm5, xmm15
0000000180378907  EB 06                       jmp     short loc_18037890F
0000000180378909  76 04                       jbe     short loc_18037890F
000000018037890B  41 0F 28 ED                 movaps  xmm5, xmm13
000000018037890F  F3 0F 10 83 A0 A6 00 00     movss   xmm0, dword ptr [rbx+0A6A0h]
0000000180378917  F3 41 0F 58 ED              addss   xmm5, xmm13
000000018037891C  F3 0F 10 93 40 A7 00 00     movss   xmm2, dword ptr [rbx+0A740h]
0000000180378924  F3 0F 10 8B B0 A6 00 00     movss   xmm1, dword ptr [rbx+0A6B0h]
000000018037892C  8B 83 70 A6 00 00           mov     eax, [rbx+0A670h]
0000000180378932  0F 28 D9                    movaps  xmm3, xmm1
0000000180378935  F3 0F 10 A3 00 A7 00 00     movss   xmm4, dword ptr [rbx+0A700h]
000000018037893D  F3 0F 58 9B 50 A7 00 00     addss   xmm3, dword ptr [rbx+0A750h]
0000000180378945  F2 44 0F 10 25 52 C8 76 00  movsd   xmm12, cs:dbl_180AE51A0
000000018037894E  F3 0F 11 AB 50 A6 00 00     movss   dword ptr [rbx+0A650h], xmm5
0000000180378956  F3 0F 11 AB 70 A6 00 00     movss   dword ptr [rbx+0A670h], xmm5
000000018037895E  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180378962  89 83 80 A6 00 00           mov     [rbx+0A680h], eax
0000000180378968  F3 0F 11 A3 10 A7 00 00     movss   dword ptr [rbx+0A710h], xmm4
0000000180378970  F3 0F 5C E8                 subss   xmm5, xmm0
0000000180378974  0F 28 C2                    movaps  xmm0, xmm2
0000000180378977  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037897B  F3 0F 10 8B E0 A6 00 00     movss   xmm1, dword ptr [rbx+0A6E0h]
0000000180378983  F3 0F 58 83 60 A7 00 00     addss   xmm0, dword ptr [rbx+0A760h]
000000018037898B  F3 41 0F 58 ED              addss   xmm5, xmm13
0000000180378990  F3 0F 5E C8                 divss   xmm1, xmm0
0000000180378994  F3 0F 10 83 70 A7 00 00     movss   xmm0, dword ptr [rbx+0A770h]
000000018037899C  F3 0F 59 AB 90 A6 00 00     mulss   xmm5, dword ptr [rbx+0A690h]
00000001803789A4  F3 0F 59 CA                 mulss   xmm1, xmm2
00000001803789A8  F3 0F 10 93 D0 A6 00 00     movss   xmm2, dword ptr [rbx+0A6D0h]
00000001803789B0  F3 0F 11 AB 20 A7 00 00     movss   dword ptr [rbx+0A720h], xmm5
00000001803789B8  F3 0F 5C D1                 subss   xmm2, xmm1
00000001803789BC  F3 0F 10 8B F0 A6 00 00     movss   xmm1, dword ptr [rbx+0A6F0h]
00000001803789C4  F3 0F 58 D6                 addss   xmm2, xmm6
00000001803789C8  F3 0F 5C D4                 subss   xmm2, xmm4
00000001803789CC  F3 0F 11 93 D0 A6 00 00     movss   dword ptr [rbx+0A6D0h], xmm2
00000001803789D4  F3 0F 59 D3                 mulss   xmm2, xmm3
00000001803789D8  F3 0F 11 93 E0 A6 00 00     movss   dword ptr [rbx+0A6E0h], xmm2
00000001803789E0  F3 0F 58 D4                 addss   xmm2, xmm4
00000001803789E4  F3 0F 5C E6                 subss   xmm4, xmm6
00000001803789E8  0F 54 25 A1 CD 76 00        andps   xmm4, cs:xmmword_180AE5790
00000001803789EF  F3 0F 5C C4                 subss   xmm0, xmm4
00000001803789F3  41 0F 2F C6                 comiss  xmm0, xmm14
00000001803789F7  0F 83 E8 00 00 00           jnb     loc_180378AE5
00000001803789FD  0F 57 C9                    xorps   xmm1, xmm1
0000000180378A00  0F 5A C1                    cvtps2pd xmm0, xmm1
0000000180378A03  41 0F 2E EE                 ucomiss xmm5, xmm14
0000000180378A07  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180378A0B  0F 28 C8                    movaps  xmm1, xmm0
0000000180378A0E  F3 0F 11 83 F0 A6 00 00     movss   dword ptr [rbx+0A6F0h], xmm0
0000000180378A16  F3 0F 59 CE                 mulss   xmm1, xmm6
0000000180378A1A  F3 0F 59 C2                 mulss   xmm0, xmm2
0000000180378A1E  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180378A22  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180378A26  75 03                       jnz     short loc_180378A2B
0000000180378A28  0F 28 CE                    movaps  xmm1, xmm6
0000000180378A2B  8B 83 B0 A7 00 00           mov     eax, [rbx+0A7B0h]
0000000180378A31  48 8D 0D C8 75 C8 FF        lea     rcx, cs:180000000h
0000000180378A38  F3 0F 59 BB A0 A7 00 00     mulss   xmm7, dword ptr [rbx+0A7A0h]
0000000180378A40  89 83 C0 A7 00 00           mov     [rbx+0A7C0h], eax
0000000180378A46  F3 44 0F 59 83 90 A7 00 00  mulss   xmm8, dword ptr [rbx+0A790h]
0000000180378A4F  F3 0F 10 83 D0 A8 00 00     movss   xmm0, dword ptr [rbx+0A8D0h]
0000000180378A57  F3 0F 10 93 D0 A7 00 00     movss   xmm2, dword ptr [rbx+0A7D0h]
0000000180378A5F  F3 44 0F 10 8B 30 A8 00 00  movss   xmm9, dword ptr [rbx+0A830h]
0000000180378A68  F3 41 0F 58 F8              addss   xmm7, xmm8
0000000180378A6D  F3 44 0F 10 83 10 A8 00 00  movss   xmm8, dword ptr [rbx+0A810h]
0000000180378A76  F3 0F 2C C0                 cvttss2si eax, xmm0
0000000180378A7A  F3 0F 11 BB B0 A7 00 00     movss   dword ptr [rbx+0A7B0h], xmm7
0000000180378A82  F3 0F 10 BB F0 A7 00 00     movss   xmm7, dword ptr [rbx+0A7F0h]
0000000180378A8A  F3 0F 11 8B 00 A7 00 00     movss   dword ptr [rbx+0A700h], xmm1
0000000180378A92  F3 0F 11 8B 30 A7 00 00     movss   dword ptr [rbx+0A730h], xmm1
0000000180378A9A  F3 0F 10 8B 90 A8 00 00     movss   xmm1, dword ptr [rbx+0A890h]
0000000180378AA2  F3 0F 11 BB 00 A8 00 00     movss   dword ptr [rbx+0A800h], xmm7
0000000180378AAA  F3 0F 11 93 E0 A7 00 00     movss   dword ptr [rbx+0A7E0h], xmm2
0000000180378AB2  F3 44 0F 11 83 20 A8 00 00  movss   dword ptr [rbx+0A820h], xmm8
0000000180378ABB  F3 44 0F 11 8B 40 A8 00 00  movss   dword ptr [rbx+0A840h], xmm9
0000000180378AC4  F3 0F 11 8B A0 A8 00 00     movss   dword ptr [rbx+0A8A0h], xmm1
0000000180378ACC  83 F8 E0                    cmp     eax, 0FFFFFFE0h
0000000180378ACF  7D 2F                       jge     short loc_180378B00
0000000180378AD1  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
0000000180378AD6  F7 D0                       not     eax
0000000180378AD8  48 98                       cdqe
0000000180378ADA  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
0000000180378AE3  EB 47                       jmp     short loc_180378B2C
0000000180378AE5  F3 0F 58 8B 80 A7 00 00     addss   xmm1, dword ptr [rbx+0A780h]
0000000180378AED  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180378AF1  0F 82 09 FF FF FF           jb      loc_180378A00
0000000180378AF7  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180378AFB  E9 03 FF FF FF              jmp     loc_180378A03
0000000180378B00  83 F8 20                    cmp     eax, 20h ; ' '
0000000180378B03  7E 07                       jle     short loc_180378B0C
0000000180378B05  B8 20 00 00 00              mov     eax, 20h ; ' '
0000000180378B0A  EB 15                       jmp     short loc_180378B21
0000000180378B0C  85 C0                       test    eax, eax
0000000180378B0E  79 0F                       jns     short loc_180378B1F
0000000180378B10  F7 D0                       not     eax
0000000180378B12  48 98                       cdqe
0000000180378B14  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
0000000180378B1D  EB 0D                       jmp     short loc_180378B2C
0000000180378B1F  7E 0B                       jle     short loc_180378B2C
0000000180378B21  48 98                       cdqe
0000000180378B23  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
0000000180378B2C  0F 57 05 8D CC 76 00        xorps   xmm0, cs:xmmword_180AE57C0
0000000180378B33  F3 0F 2C C0                 cvttss2si eax, xmm0
0000000180378B37  83 F8 E0                    cmp     eax, 0FFFFFFE0h
0000000180378B3A  7D 14                       jge     short loc_180378B50
0000000180378B3C  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
0000000180378B41  F7 D0                       not     eax
0000000180378B43  48 98                       cdqe
0000000180378B45  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
0000000180378B4E  EB 2C                       jmp     short loc_180378B7C
0000000180378B50  83 F8 20                    cmp     eax, 20h ; ' '
0000000180378B53  7E 07                       jle     short loc_180378B5C
0000000180378B55  B8 20 00 00 00              mov     eax, 20h ; ' '
0000000180378B5A  EB 15                       jmp     short loc_180378B71
0000000180378B5C  85 C0                       test    eax, eax
0000000180378B5E  79 0F                       jns     short loc_180378B6F
0000000180378B60  F7 D0                       not     eax
0000000180378B62  48 98                       cdqe
0000000180378B64  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
0000000180378B6D  EB 0D                       jmp     short loc_180378B7C
0000000180378B6F  7E 0B                       jle     short loc_180378B7C
0000000180378B71  48 98                       cdqe
0000000180378B73  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
0000000180378B7C  F3 0F 10 83 50 A8 00 00     movss   xmm0, dword ptr [rbx+0A850h]
0000000180378B84  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180378B88  F3 0F 59 93 C0 A8 00 00     mulss   xmm2, dword ptr [rbx+0A8C0h]
0000000180378B90  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180378B94  F3 0F 10 8B 80 A8 00 00     movss   xmm1, dword ptr [rbx+0A880h]
0000000180378B9C  F3 0F 11 93 90 A8 00 00     movss   dword ptr [rbx+0A890h], xmm2
0000000180378BA4  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180378BA8  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180378BAC  F3 0F 5C D0                 subss   xmm2, xmm0
0000000180378BB0  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180378BB4  41 0F 2F D6                 comiss  xmm2, xmm14
0000000180378BB8  76 05                       jbe     short loc_180378BBF
0000000180378BBA  0F 5A C2                    cvtps2pd xmm0, xmm2
0000000180378BBD  EB 03                       jmp     short loc_180378BC2
0000000180378BBF  0F 57 C0                    xorps   xmm0, xmm0
0000000180378BC2  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
0000000180378BC6  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180378BCA  72 06                       jb      short loc_180378BD2
0000000180378BCC  41 0F 28 C4                 movaps  xmm0, xmm12
0000000180378BD0  EB 03                       jmp     short loc_180378BD5
0000000180378BD2  0F 5A C1                    cvtps2pd xmm0, xmm1
0000000180378BD5  F3 0F 10 B3 60 A8 00 00     movss   xmm6, dword ptr [rbx+0A860h]
0000000180378BDD  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
0000000180378BE1  F3 0F 59 83 F0 A8 00 00     mulss   xmm0, dword ptr [rbx+0A8F0h]; X
0000000180378BE9  E8 52 6B 37 00              call    expf
0000000180378BEE  F3 0F 59 83 E0 A8 00 00     mulss   xmm0, dword ptr [rbx+0A8E0h]
0000000180378BF6  0F 28 CE                    movaps  xmm1, xmm6
0000000180378BF9  8B 83 60 AA 00 00           mov     eax, [rbx+0AA60h]
0000000180378BFF  F3 0F 59 8B 70 A8 00 00     mulss   xmm1, dword ptr [rbx+0A870h]
0000000180378C07  89 83 70 AA 00 00           mov     [rbx+0AA70h], eax
0000000180378C0D  F3 0F 58 83 00 A9 00 00     addss   xmm0, dword ptr [rbx+0A900h]
0000000180378C15  8B 83 80 AA 00 00           mov     eax, [rbx+0AA80h]
0000000180378C1B  F3 0F 10 9B 20 AA 00 00     movss   xmm3, dword ptr [rbx+0AA20h]
0000000180378C23  F3 0F 59 BB B0 AB 00 00     mulss   xmm7, dword ptr [rbx+0ABB0h]
0000000180378C2B  89 83 90 AA 00 00           mov     [rbx+0AA90h], eax
0000000180378C31  8B 83 A0 AA 00 00           mov     eax, [rbx+0AAA0h]
0000000180378C37  F3 0F 10 93 10 AA 00 00     movss   xmm2, dword ptr [rbx+0AA10h]
0000000180378C3F  F3 0F 10 A3 40 AA 00 00     movss   xmm4, dword ptr [rbx+0AA40h]
0000000180378C47  F3 0F 59 F0                 mulss   xmm6, xmm0
0000000180378C4B  89 83 B0 AA 00 00           mov     [rbx+0AAB0h], eax
0000000180378C51  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
0000000180378C57  F3 0F 11 9B 30 AA 00 00     movss   dword ptr [rbx+0AA30h], xmm3
0000000180378C5F  F3 0F 5C CE                 subss   xmm1, xmm6
0000000180378C63  F3 0F 11 93 20 AA 00 00     movss   dword ptr [rbx+0AA20h], xmm2
0000000180378C6B  F3 0F 11 A3 50 AA 00 00     movss   dword ptr [rbx+0AA50h], xmm4
0000000180378C73  F3 44 0F 11 83 E0 A9 00 00  movss   dword ptr [rbx+0A9E0h], xmm8
0000000180378C7C  F3 44 0F 11 8B F0 A9 00 00  movss   dword ptr [rbx+0A9F0h], xmm9
0000000180378C85  89 83 D0 A9 00 00           mov     [rbx+0A9D0h], eax
0000000180378C8B  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180378C8F  F3 0F 10 83 80 AB 00 00     movss   xmm0, dword ptr [rbx+0AB80h]
0000000180378C97  F3 0F 58 F8                 addss   xmm7, xmm0
0000000180378C9B  F3 0F 11 83 70 AB 00 00     movss   dword ptr [rbx+0AB70h], xmm0
0000000180378CA3  F3 0F 11 8B B0 A8 00 00     movss   dword ptr [rbx+0A8B0h], xmm1
0000000180378CAB  41 0F 2F FF                 comiss  xmm7, xmm15
0000000180378CAF  73 06                       jnb     short loc_180378CB7
0000000180378CB1  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180378CB5  EB 05                       jmp     short loc_180378CBC
0000000180378CB7  F3 41 0F 5D FD              minss   xmm7, xmm13
0000000180378CBC  F3 0F 59 0D FC 20 61 00     mulss   xmm1, cs:dword_18098ADC0
0000000180378CC4  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180378CC8  F3 0F 10 B3 90 AC 00 00     movss   xmm6, dword ptr [rbx+0AC90h]
0000000180378CD0  F3 0F 5C C3                 subss   xmm0, xmm3
0000000180378CD4  F3 0F 11 BB 10 AA 00 00     movss   dword ptr [rbx+0AA10h], xmm7
0000000180378CDC  F3 0F 5D F1                 minss   xmm6, xmm1
0000000180378CE0  F3 0F 59 83 C0 AB 00 00     mulss   xmm0, dword ptr [rbx+0ABC0h]
0000000180378CE8  F3 0F 58 C3                 addss   xmm0, xmm3
0000000180378CEC  41 0F 2F C7                 comiss  xmm0, xmm15
0000000180378CF0  73 06                       jnb     short loc_180378CF8
0000000180378CF2  41 0F 28 C7                 movaps  xmm0, xmm15
0000000180378CF6  EB 05                       jmp     short loc_180378CFD
0000000180378CF8  F3 41 0F 5D C5              minss   xmm0, xmm13
0000000180378CFD  F3 0F 59 B3 A0 AC 00 00     mulss   xmm6, dword ptr [rbx+0ACA0h]
0000000180378D05  F3 0F 5C D7                 subss   xmm2, xmm7
0000000180378D09  F3 0F 11 B3 C0 AA 00 00     movss   dword ptr [rbx+0AAC0h], xmm6
0000000180378D11  F3 0F 58 F4                 addss   xmm6, xmm4
0000000180378D15  41 0F 2F D6                 comiss  xmm2, xmm14
0000000180378D19  73 03                       jnb     short loc_180378D1E
0000000180378D1B  0F 57 C0                    xorps   xmm0, xmm0
0000000180378D1E  F3 0F 10 8B 90 AB 00 00     movss   xmm1, dword ptr [rbx+0AB90h]
0000000180378D26  F3 44 0F 10 9B D0 A9 00 00  movss   xmm11, dword ptr [rbx+0A9D0h]
0000000180378D2F  F3 0F 11 83 20 AA 00 00     movss   dword ptr [rbx+0AA20h], xmm0
0000000180378D37  F3 0F 58 83 20 AD 00 00     addss   xmm0, dword ptr [rbx+0AD20h]
0000000180378D3F  72 04                       jb      short loc_180378D45
0000000180378D41  41 0F 28 CD                 movaps  xmm1, xmm13
0000000180378D45  F3 0F 59 83 10 AD 00 00     mulss   xmm0, dword ptr [rbx+0AD10h]
0000000180378D4D  41 0F 28 FB                 movaps  xmm7, xmm11
0000000180378D51  F3 0F 10 93 70 AA 00 00     movss   xmm2, dword ptr [rbx+0AA70h]
0000000180378D59  F3 0F 59 F1                 mulss   xmm6, xmm1
0000000180378D5D  F3 0F 5C FA                 subss   xmm7, xmm2
0000000180378D61  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180378D65  F3 0F 59 B3 A0 AB 00 00     mulss   xmm6, dword ptr [rbx+0ABA0h]
0000000180378D6D  76 05                       jbe     short loc_180378D74
0000000180378D6F  0F 5A C8                    cvtps2pd xmm1, xmm0
0000000180378D72  EB 03                       jmp     short loc_180378D77
0000000180378D74  0F 57 C9                    xorps   xmm1, xmm1
0000000180378D77  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180378D7B  F3 0F 59 BB E0 AD 00 00     mulss   xmm7, dword ptr [rbx+0ADE0h]
0000000180378D83  F3 44 0F 10 0D 5C C4 76 00  movss   xmm9, cs:flt_180AE51E8
0000000180378D8C  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
0000000180378D90  F3 0F 58 FA                 addss   xmm7, xmm2
0000000180378D94  F3 0F 11 BB 60 AA 00 00     movss   dword ptr [rbx+0AA60h], xmm7
0000000180378D9C  F3 0F 11 83 00 AA 00 00     movss   dword ptr [rbx+0AA00h], xmm0
0000000180378DA4  41 0F 28 C3                 movaps  xmm0, xmm11
0000000180378DA8  F3 0F 59 BB D0 AD 00 00     mulss   xmm7, dword ptr [rbx+0ADD0h]
0000000180378DB0  F3 0F 10 8B 50 AC 00 00     movss   xmm1, dword ptr [rbx+0AC50h]
0000000180378DB8  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180378DBC  F3 0F 59 F9                 mulss   xmm7, xmm1
0000000180378DC0  F3 0F 5C F8                 subss   xmm7, xmm0
0000000180378DC4  F3 0F 10 83 50 AA 00 00     movss   xmm0, dword ptr [rbx+0AA50h]
0000000180378DCC  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
0000000180378DD5  F3 41 0F 58 FB              addss   xmm7, xmm11
0000000180378DDA  76 1B                       jbe     short loc_180378DF7
0000000180378DDC  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180378DE1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180378DE5  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180378DE8  E8 EB 66 37 00              call    fmodf
0000000180378DED  0F 28 F0                    movaps  xmm6, xmm0
0000000180378DF0  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180378DF5  EB 1F                       jmp     short loc_180378E16
0000000180378DF7  41 0F 2F F7                 comiss  xmm6, xmm15
0000000180378DFB  73 19                       jnb     short loc_180378E16
0000000180378DFD  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180378E02  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180378E06  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180378E09  E8 CA 66 37 00              call    fmodf
0000000180378E0E  0F 28 F0                    movaps  xmm6, xmm0
0000000180378E11  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180378E16  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
0000000180378E1F  0F 28 C6                    movaps  xmm0, xmm6
0000000180378E22  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180378E26  F3 44 0F 10 83 90 AA 00 00  movss   xmm8, dword ptr [rbx+0AA90h]
0000000180378E2F  F3 0F 11 B3 40 AA 00 00     movss   dword ptr [rbx+0AA40h], xmm6
0000000180378E37  F3 0F 59 BB C0 AD 00 00     mulss   xmm7, dword ptr [rbx+0ADC0h]
0000000180378E3F  F3 0F 58 83 30 AD 00 00     addss   xmm0, dword ptr [rbx+0AD30h]
0000000180378E47  F3 0F 11 BB C0 A9 00 00     movss   dword ptr [rbx+0A9C0h], xmm7
0000000180378E4F  73 0A                       jnb     short loc_180378E5B
0000000180378E51  41 0F 2F F6                 comiss  xmm6, xmm14
0000000180378E55  76 04                       jbe     short loc_180378E5B
0000000180378E57  45 0F 28 C3                 movaps  xmm8, xmm11
0000000180378E5B  41 0F 2F C5                 comiss  xmm0, xmm13
0000000180378E5F  76 15                       jbe     short loc_180378E76
0000000180378E61  F3 41 0F 58 C5              addss   xmm0, xmm13; X
0000000180378E66  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180378E6A  E8 69 66 37 00              call    fmodf
0000000180378E6F  F3 41 0F 5C C5              subss   xmm0, xmm13
0000000180378E74  EB 19                       jmp     short loc_180378E8F
0000000180378E76  41 0F 2F C7                 comiss  xmm0, xmm15
0000000180378E7A  73 13                       jnb     short loc_180378E8F
0000000180378E7C  F3 41 0F 5C C5              subss   xmm0, xmm13; X
0000000180378E81  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180378E85  E8 4E 66 37 00              call    fmodf
0000000180378E8A  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180378E8F  F3 44 0F 10 1D 28 C9 76 00  movss   xmm11, dword ptr cs:xmmword_180AE57C0
0000000180378E98  F3 44 0F 11 83 80 AA 00 00  movss   dword ptr [rbx+0AA80h], xmm8
0000000180378EA1  F3 0F 59 83 70 AD 00 00     mulss   xmm0, dword ptr [rbx+0AD70h]
0000000180378EA9  F3 44 0F 59 83 B0 AD 00 00  mulss   xmm8, dword ptr [rbx+0ADB0h]
0000000180378EB2  F3 0F 58 83 F0 AD 00 00     addss   xmm0, dword ptr [rbx+0ADF0h]
0000000180378EBA  F3 0F 11 83 D0 AA 00 00     movss   dword ptr [rbx+0AAD0h], xmm0
0000000180378EC2  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180378EC6  F3 44 0F 11 83 20 AB 00 00  movss   dword ptr [rbx+0AB20h], xmm8
0000000180378ECF  44 0F 28 C6                 movaps  xmm8, xmm6
0000000180378ED3  F3 44 0F 58 83 50 AD 00 00  addss   xmm8, dword ptr [rbx+0AD50h]
0000000180378EDC  F3 0F 11 83 E0 AA 00 00     movss   dword ptr [rbx+0AAE0h], xmm0
0000000180378EE4  45 0F 2F C5                 comiss  xmm8, xmm13
0000000180378EE8  76 1D                       jbe     short loc_180378F07
0000000180378EEA  F3 45 0F 58 C5              addss   xmm8, xmm13
0000000180378EEF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180378EF3  41 0F 28 C0                 movaps  xmm0, xmm8; X
0000000180378EF7  E8 DC 65 37 00              call    fmodf
0000000180378EFC  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180378F00  F3 45 0F 5C C5              subss   xmm8, xmm13
0000000180378F05  EB 21                       jmp     short loc_180378F28
0000000180378F07  45 0F 2F C7                 comiss  xmm8, xmm15
0000000180378F0B  73 1B                       jnb     short loc_180378F28
0000000180378F0D  F3 45 0F 5C C5              subss   xmm8, xmm13
0000000180378F12  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180378F16  41 0F 28 C0                 movaps  xmm0, xmm8; X
0000000180378F1A  E8 B9 65 37 00              call    fmodf
0000000180378F1F  44 0F 28 C0                 movaps  xmm8, xmm0
0000000180378F23  F3 45 0F 58 C5              addss   xmm8, xmm13
0000000180378F28  0F 28 FE                    movaps  xmm7, xmm6
0000000180378F2B  F3 0F 58 BB 40 AD 00 00     addss   xmm7, dword ptr [rbx+0AD40h]
0000000180378F33  41 0F 2F FD                 comiss  xmm7, xmm13
0000000180378F37  76 1B                       jbe     short loc_180378F54
0000000180378F39  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180378F3E  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180378F42  0F 28 C7                    movaps  xmm0, xmm7; X
0000000180378F45  E8 8E 65 37 00              call    fmodf
0000000180378F4A  0F 28 F8                    movaps  xmm7, xmm0
0000000180378F4D  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180378F52  EB 1F                       jmp     short loc_180378F73
0000000180378F54  41 0F 2F FF                 comiss  xmm7, xmm15
0000000180378F58  73 19                       jnb     short loc_180378F73
0000000180378F5A  F3 41 0F 5C FD              subss   xmm7, xmm13
0000000180378F5F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180378F63  0F 28 C7                    movaps  xmm0, xmm7; X
0000000180378F66  E8 6D 65 37 00              call    fmodf
0000000180378F6B  0F 28 F8                    movaps  xmm7, xmm0
0000000180378F6E  F3 41 0F 58 FD              addss   xmm7, xmm13
0000000180378F73  41 0F 28 C0                 movaps  xmm0, xmm8
0000000180378F77  E8 44 00 FF FF              call    sub_180368FC0
0000000180378F7C  F3 0F 58 BB 00 AE 00 00     addss   xmm7, dword ptr [rbx+0AE00h]
0000000180378F84  F3 0F 59 83 90 AD 00 00     mulss   xmm0, dword ptr [rbx+0AD90h]
0000000180378F8C  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180378F90  73 06                       jnb     short loc_180378F98
0000000180378F92  41 0F 28 FF                 movaps  xmm7, xmm15
0000000180378F96  EB 06                       jmp     short loc_180378F9E
0000000180378F98  76 04                       jbe     short loc_180378F9E
0000000180378F9A  41 0F 28 FD                 movaps  xmm7, xmm13
0000000180378F9E  F3 0F 58 B3 60 AD 00 00     addss   xmm6, dword ptr [rbx+0AD60h]
0000000180378FA6  F3 0F 11 83 00 AB 00 00     movss   dword ptr [rbx+0AB00h], xmm0
0000000180378FAE  F3 0F 11 BB 60 AB 00 00     movss   dword ptr [rbx+0AB60h], xmm7
0000000180378FB6  F3 0F 59 BB 80 AD 00 00     mulss   xmm7, dword ptr [rbx+0AD80h]
0000000180378FBE  41 0F 2F F5                 comiss  xmm6, xmm13
0000000180378FC2  F3 0F 58 BB 10 AE 00 00     addss   xmm7, dword ptr [rbx+0AE10h]
0000000180378FCA  76 1B                       jbe     short loc_180378FE7
0000000180378FCC  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180378FD1  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180378FD5  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180378FD8  E8 FB 64 37 00              call    fmodf
0000000180378FDD  0F 28 F0                    movaps  xmm6, xmm0
0000000180378FE0  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180378FE5  EB 1F                       jmp     short loc_180379006
0000000180378FE7  41 0F 2F F7                 comiss  xmm6, xmm15
0000000180378FEB  73 19                       jnb     short loc_180379006
0000000180378FED  F3 41 0F 5C F5              subss   xmm6, xmm13
0000000180378FF2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
0000000180378FF6  0F 28 C6                    movaps  xmm0, xmm6; X
0000000180378FF9  E8 DA 64 37 00              call    fmodf
0000000180378FFE  0F 28 F0                    movaps  xmm6, xmm0
0000000180379001  F3 41 0F 58 F5              addss   xmm6, xmm13
0000000180379006  0F 54 35 83 C7 76 00        andps   xmm6, cs:xmmword_180AE5790
000000018037900D  F3 0F 11 BB F0 AA 00 00     movss   dword ptr [rbx+0AAF0h], xmm7
0000000180379015  0F 28 E6                    movaps  xmm4, xmm6
0000000180379018  F3 0F 10 9B 30 AC 00 00     movss   xmm3, dword ptr [rbx+0AC30h]
0000000180379020  0F 28 D6                    movaps  xmm2, xmm6
0000000180379023  F3 0F 59 93 C0 AC 00 00     mulss   xmm2, dword ptr [rbx+0ACC0h]
000000018037902B  F3 0F 59 9B 20 AB 00 00     mulss   xmm3, dword ptr [rbx+0AB20h]
0000000180379033  F3 0F 58 93 B0 AC 00 00     addss   xmm2, dword ptr [rbx+0ACB0h]
000000018037903B  F3 0F 10 8B 20 AC 00 00     movss   xmm1, dword ptr [rbx+0AC20h]
0000000180379043  F3 0F 59 8B E0 AA 00 00     mulss   xmm1, dword ptr [rbx+0AAE0h]
000000018037904B  F3 0F 59 E6                 mulss   xmm4, xmm6
000000018037904F  0F 28 C4                    movaps  xmm0, xmm4
0000000180379052  F3 0F 59 E6                 mulss   xmm4, xmm6
0000000180379056  F3 0F 59 83 D0 AC 00 00     mulss   xmm0, dword ptr [rbx+0ACD0h]
000000018037905E  F3 0F 59 F4                 mulss   xmm6, xmm4
0000000180379062  F3 0F 59 A3 E0 AC 00 00     mulss   xmm4, dword ptr [rbx+0ACE0h]
000000018037906A  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037906E  F3 0F 59 B3 F0 AC 00 00     mulss   xmm6, dword ptr [rbx+0ACF0h]
0000000180379076  F3 0F 10 83 10 AC 00 00     movss   xmm0, dword ptr [rbx+0AC10h]
000000018037907E  F3 0F 59 83 D0 AA 00 00     mulss   xmm0, dword ptr [rbx+0AAD0h]
0000000180379086  F3 0F 58 E2                 addss   xmm4, xmm2
000000018037908A  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037908E  F3 0F 58 F4                 addss   xmm6, xmm4
0000000180379092  F3 0F 10 A3 F0 AB 00 00     movss   xmm4, dword ptr [rbx+0ABF0h]
000000018037909A  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037909E  F3 0F 58 B3 00 AD 00 00     addss   xmm6, dword ptr [rbx+0AD00h]
00000001803790A6  F3 0F 59 B3 A0 AD 00 00     mulss   xmm6, dword ptr [rbx+0ADA0h]
00000001803790AE  F3 0F 11 B3 10 AB 00 00     movss   dword ptr [rbx+0AB10h], xmm6
00000001803790B6  F3 0F 59 A3 00 AB 00 00     mulss   xmm4, dword ptr [rbx+0AB00h]
00000001803790BE  F3 0F 10 8B D0 AB 00 00     movss   xmm1, dword ptr [rbx+0ABD0h]
00000001803790C6  F3 0F 10 83 00 AC 00 00     movss   xmm0, dword ptr [rbx+0AC00h]
00000001803790CE  F3 0F 59 83 F0 AA 00 00     mulss   xmm0, dword ptr [rbx+0AAF0h]
00000001803790D6  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803790DA  F3 0F 10 93 60 AC 00 00     movss   xmm2, dword ptr [rbx+0AC60h]
00000001803790E2  0F 28 D9                    movaps  xmm3, xmm1
00000001803790E5  F3 0F 59 9B 00 AA 00 00     mulss   xmm3, dword ptr [rbx+0AA00h]
00000001803790ED  F3 0F 59 B3 E0 AB 00 00     mulss   xmm6, dword ptr [rbx+0ABE0h]
00000001803790F5  F3 0F 58 E0                 addss   xmm4, xmm0
00000001803790F9  F3 0F 10 83 40 AC 00 00     movss   xmm0, dword ptr [rbx+0AC40h]
0000000180379101  F3 0F 5C D9                 subss   xmm3, xmm1
0000000180379105  F3 0F 59 83 C0 A9 00 00     mulss   xmm0, dword ptr [rbx+0A9C0h]
000000018037910D  F3 0F 58 E6                 addss   xmm4, xmm6
0000000180379111  F3 41 0F 58 DD              addss   xmm3, xmm13
0000000180379116  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037911A  F3 0F 11 9B 30 AB 00 00     movss   dword ptr [rbx+0AB30h], xmm3
0000000180379122  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180379126  F3 0F 11 A3 50 AB 00 00     movss   dword ptr [rbx+0AB50h], xmm4
000000018037912E  F3 0F 10 8B 70 AC 00 00     movss   xmm1, dword ptr [rbx+0AC70h]
0000000180379136  F3 0F 59 8B E0 A9 00 00     mulss   xmm1, dword ptr [rbx+0A9E0h]
000000018037913E  F3 0F 10 83 80 AC 00 00     movss   xmm0, dword ptr [rbx+0AC80h]
0000000180379146  F3 0F 59 83 F0 A9 00 00     mulss   xmm0, dword ptr [rbx+0A9F0h]
000000018037914E  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180379152  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180379156  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037915A  F3 0F 11 8B 40 AB 00 00     movss   dword ptr [rbx+0AB40h], xmm1
0000000180379162  F3 0F 10 83 50 AB 00 00     movss   xmm0, dword ptr [rbx+0AB50h]
000000018037916A  8B 83 60 AB 00 00           mov     eax, [rbx+0AB60h]
0000000180379170  89 83 20 AE 00 00           mov     [rbx+0AE20h], eax
0000000180379176  F3 0F 11 83 30 AE 00 00     movss   dword ptr [rbx+0AE30h], xmm0
000000018037917E  44 0F 2F B3 60 AB 00 00     comiss  xmm14, dword ptr [rbx+0AB60h]
0000000180379186  F3 0F 10 8B 70 A6 00 00     movss   xmm1, dword ptr [rbx+0A670h]
000000018037918E  F3 0F 10 93 40 AE 00 00     movss   xmm2, dword ptr [rbx+0AE40h]
0000000180379196  73 06                       jnb     short loc_18037919E
0000000180379198  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037919C  EB 03                       jmp     short loc_1803791A1
000000018037919E  0F 57 C0                    xorps   xmm0, xmm0
00000001803791A1  41 0F 2E D6                 ucomiss xmm2, xmm14
00000001803791A5  75 04                       jnz     short loc_1803791AB
00000001803791A7  41 0F 28 C5                 movaps  xmm0, xmm13
00000001803791AB  F3 0F 59 C8                 mulss   xmm1, xmm0
00000001803791AF  F3 0F 11 8B 50 AE 00 00     movss   dword ptr [rbx+0AE50h], xmm1
00000001803791B7  8B 83 60 AE 00 00           mov     eax, [rbx+0AE60h]
00000001803791BD  89 83 70 AE 00 00           mov     [rbx+0AE70h], eax
00000001803791C3  8B 83 90 AE 00 00           mov     eax, [rbx+0AE90h]
00000001803791C9  89 83 A0 AE 00 00           mov     [rbx+0AEA0h], eax
00000001803791CF  8B 83 80 AE 00 00           mov     eax, [rbx+0AE80h]
00000001803791D5  89 83 90 AE 00 00           mov     [rbx+0AE90h], eax
00000001803791DB  8B 83 B0 AE 00 00           mov     eax, [rbx+0AEB0h]
00000001803791E1  89 83 C0 AE 00 00           mov     [rbx+0AEC0h], eax
00000001803791E7  8B 83 E0 AE 00 00           mov     eax, [rbx+0AEE0h]
00000001803791ED  89 83 F0 AE 00 00           mov     [rbx+0AEF0h], eax
00000001803791F3  F3 0F 10 83 90 AF 00 00     movss   xmm0, dword ptr [rbx+0AF90h]
00000001803791FB  F3 0F 58 8B 70 AF 00 00     addss   xmm1, dword ptr [rbx+0AF70h]
0000000180379203  F3 0F 59 83 A0 AE 00 00     mulss   xmm0, dword ptr [rbx+0AEA0h]
000000018037920B  41 0F 2F CE                 comiss  xmm1, xmm14
000000018037920F  F3 0F 58 83 70 AE 00 00     addss   xmm0, dword ptr [rbx+0AE70h]
0000000180379217  73 06                       jnb     short loc_18037921F
0000000180379219  45 0F 28 C5                 movaps  xmm8, xmm13
000000018037921D  EB 04                       jmp     short loc_180379223
000000018037921F  45 0F 57 C0                 xorps   xmm8, xmm8
0000000180379223  41 0F 28 ED                 movaps  xmm5, xmm13
0000000180379227  F3 41 0F 5C E8              subss   xmm5, xmm8
000000018037922C  0F 28 FD                    movaps  xmm7, xmm5
000000018037922F  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180379233  F3 0F 11 BB 80 AE 00 00     movss   dword ptr [rbx+0AE80h], xmm7
000000018037923B  0F 28 E7                    movaps  xmm4, xmm7
000000018037923E  F3 0F 10 9B 60 AF 00 00     movss   xmm3, dword ptr [rbx+0AF60h]
0000000180379246  F3 0F 10 93 B0 AF 00 00     movss   xmm2, dword ptr [rbx+0AFB0h]
000000018037924E  0F 28 CB                    movaps  xmm1, xmm3
0000000180379251  F3 0F 59 8B D0 AF 00 00     mulss   xmm1, dword ptr [rbx+0AFD0h]
0000000180379259  0F 28 C2                    movaps  xmm0, xmm2
000000018037925C  F3 0F 58 A3 80 AF 00 00     addss   xmm4, dword ptr [rbx+0AF80h]
0000000180379264  F3 0F 5C BB 90 AE 00 00     subss   xmm7, dword ptr [rbx+0AE90h]
000000018037926C  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180379270  41 0F 2F E6                 comiss  xmm4, xmm14
0000000180379274  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180379278  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037927C  F3 0F 11 8B D0 AE 00 00     movss   dword ptr [rbx+0AED0h], xmm1
0000000180379284  72 06                       jb      short loc_18037928C
0000000180379286  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037928A  EB 03                       jmp     short loc_18037928F
000000018037928C  0F 57 F6                    xorps   xmm6, xmm6
000000018037928F  41 0F 2F FE                 comiss  xmm7, xmm14
0000000180379293  F3 0F 10 83 30 AF 00 00     movss   xmm0, dword ptr [rbx+0AF30h]
000000018037929B  73 03                       jnb     short loc_1803792A0
000000018037929D  0F 28 F5                    movaps  xmm6, xmm5
00000001803792A0  F3 0F 59 83 B0 AF 00 00     mulss   xmm0, dword ptr [rbx+0AFB0h]
00000001803792A8  0F 28 DD                    movaps  xmm3, xmm5
00000001803792AB  F3 0F 10 93 20 AF 00 00     movss   xmm2, dword ptr [rbx+0AF20h]
00000001803792B3  F3 44 0F 10 0D A0 BC 76 00  movss   xmm9, cs:dword_180AE4F5C
00000001803792BC  F3 0F 59 D8                 mulss   xmm3, xmm0
00000001803792C0  F3 0F 11 B3 90 AE 00 00     movss   dword ptr [rbx+0AE90h], xmm6
00000001803792C8  F3 0F 10 8B C0 AF 00 00     movss   xmm1, dword ptr [rbx+0AFC0h]
00000001803792D0  F3 0F 10 BB 40 AF 00 00     movss   xmm7, dword ptr [rbx+0AF40h]
00000001803792D8  0F 28 C1                    movaps  xmm0, xmm1
00000001803792DB  F3 0F 10 A3 C0 AE 00 00     movss   xmm4, dword ptr [rbx+0AEC0h]
00000001803792E3  F3 0F 59 C5                 mulss   xmm0, xmm5
00000001803792E7  F3 41 0F 59 F9              mulss   xmm7, xmm9
00000001803792EC  F3 0F 5C D8                 subss   xmm3, xmm0
00000001803792F0  F3 41 0F 59 D1              mulss   xmm2, xmm9
00000001803792F5  41 0F 28 C5                 movaps  xmm0, xmm13
00000001803792F9  F3 0F 59 FE                 mulss   xmm7, xmm6
00000001803792FD  F3 0F 5C C6                 subss   xmm0, xmm6
0000000180379301  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180379305  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180379309  0F 28 CB                    movaps  xmm1, xmm3
000000018037930C  F3 0F 5C CC                 subss   xmm1, xmm4
0000000180379310  F3 0F 59 D5                 mulss   xmm2, xmm5
0000000180379314  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180379318  F3 0F 58 FA                 addss   xmm7, xmm2
000000018037931C  76 0B                       jbe     short loc_180379329
000000018037931E  0F 28 DC                    movaps  xmm3, xmm4
0000000180379321  F3 0F 58 9B D0 AE 00 00     addss   xmm3, dword ptr [rbx+0AED0h]
0000000180379329  F3 0F 10 83 B0 AF 00 00     movss   xmm0, dword ptr [rbx+0AFB0h]
0000000180379331  F3 0F 10 A3 70 AE 00 00     movss   xmm4, dword ptr [rbx+0AE70h]
0000000180379339  F3 0F 5D C3                 minss   xmm0, xmm3
000000018037933D  F3 0F 11 83 B0 AE 00 00     movss   dword ptr [rbx+0AEB0h], xmm0
0000000180379345  F3 0F 10 8B F0 AE 00 00     movss   xmm1, dword ptr [rbx+0AEF0h]
000000018037934D  F3 0F 10 9B 50 AF 00 00     movss   xmm3, dword ptr [rbx+0AF50h]
0000000180379355  F3 0F 59 AB A0 AF 00 00     mulss   xmm5, dword ptr [rbx+0AFA0h]
000000018037935D  F3 41 0F 59 D9              mulss   xmm3, xmm9
0000000180379362  F3 0F 59 F0                 mulss   xmm6, xmm0
0000000180379366  F3 0F 10 83 E0 AF 00 00     movss   xmm0, dword ptr [rbx+0AFE0h]
000000018037936E  F3 41 0F 59 D8              mulss   xmm3, xmm8
0000000180379373  0F 28 D0                    movaps  xmm2, xmm0
0000000180379376  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037937A  F3 0F 58 EE                 addss   xmm5, xmm6
000000018037937E  F3 0F 59 D7                 mulss   xmm2, xmm7
0000000180379382  F3 0F 5C EC                 subss   xmm5, xmm4
0000000180379386  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037938A  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037938E  F3 0F 11 93 E0 AE 00 00     movss   dword ptr [rbx+0AEE0h], xmm2
0000000180379396  F3 44 0F 59 C2              mulss   xmm8, xmm2
000000018037939B  F3 41 0F 5C D8              subss   xmm3, xmm8
00000001803793A0  F3 0F 58 DA                 addss   xmm3, xmm2
00000001803793A4  F3 0F 59 DD                 mulss   xmm3, xmm5
00000001803793A8  F3 0F 58 DC                 addss   xmm3, xmm4
00000001803793AC  F3 0F 11 9B 60 AE 00 00     movss   dword ptr [rbx+0AE60h], xmm3
00000001803793B4  F3 0F 59 9B F0 AF 00 00     mulss   xmm3, dword ptr [rbx+0AFF0h]
00000001803793BC  F3 0F 59 9B 00 B0 00 00     mulss   xmm3, dword ptr [rbx+0B000h]
00000001803793C4  0F 28 C3                    movaps  xmm0, xmm3
00000001803793C7  F3 0F 59 83 10 B0 00 00     mulss   xmm0, dword ptr [rbx+0B010h]
00000001803793CF  F3 0F 11 9B 00 AF 00 00     movss   dword ptr [rbx+0AF00h], xmm3
00000001803793D7  F3 0F 11 83 10 AF 00 00     movss   dword ptr [rbx+0AF10h], xmm0
00000001803793DF  44 0F 2F B3 60 AB 00 00     comiss  xmm14, dword ptr [rbx+0AB60h]
00000001803793E7  F3 0F 10 8B 70 A6 00 00     movss   xmm1, dword ptr [rbx+0A670h]
00000001803793EF  F3 0F 10 93 20 B0 00 00     movss   xmm2, dword ptr [rbx+0B020h]
00000001803793F7  73 06                       jnb     short loc_1803793FF
00000001803793F9  41 0F 28 C5                 movaps  xmm0, xmm13
00000001803793FD  EB 03                       jmp     short loc_180379402
00000001803793FF  0F 57 C0                    xorps   xmm0, xmm0
0000000180379402  41 0F 2E D6                 ucomiss xmm2, xmm14
0000000180379406  75 04                       jnz     short loc_18037940C
0000000180379408  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037940C  F3 0F 59 C8                 mulss   xmm1, xmm0
0000000180379410  F3 0F 11 8B 30 B0 00 00     movss   dword ptr [rbx+0B030h], xmm1
0000000180379418  8B 83 40 B0 00 00           mov     eax, [rbx+0B040h]
000000018037941E  89 83 50 B0 00 00           mov     [rbx+0B050h], eax
0000000180379424  8B 83 70 B0 00 00           mov     eax, [rbx+0B070h]
000000018037942A  89 83 80 B0 00 00           mov     [rbx+0B080h], eax
0000000180379430  8B 83 60 B0 00 00           mov     eax, [rbx+0B060h]
0000000180379436  89 83 70 B0 00 00           mov     [rbx+0B070h], eax
000000018037943C  8B 83 90 B0 00 00           mov     eax, [rbx+0B090h]
0000000180379442  89 83 A0 B0 00 00           mov     [rbx+0B0A0h], eax
0000000180379448  8B 83 C0 B0 00 00           mov     eax, [rbx+0B0C0h]
000000018037944E  89 83 D0 B0 00 00           mov     [rbx+0B0D0h], eax
0000000180379454  F3 0F 10 83 70 B1 00 00     movss   xmm0, dword ptr [rbx+0B170h]
000000018037945C  F3 0F 58 8B 50 B1 00 00     addss   xmm1, dword ptr [rbx+0B150h]
0000000180379464  F3 0F 59 83 80 B0 00 00     mulss   xmm0, dword ptr [rbx+0B080h]
000000018037946C  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180379470  F3 0F 58 83 50 B0 00 00     addss   xmm0, dword ptr [rbx+0B050h]
0000000180379478  73 06                       jnb     short loc_180379480
000000018037947A  45 0F 28 C5                 movaps  xmm8, xmm13
000000018037947E  EB 04                       jmp     short loc_180379484
0000000180379480  45 0F 57 C0                 xorps   xmm8, xmm8
0000000180379484  41 0F 28 ED                 movaps  xmm5, xmm13
0000000180379488  F3 41 0F 5C E8              subss   xmm5, xmm8
000000018037948D  0F 28 F5                    movaps  xmm6, xmm5
0000000180379490  F3 0F 59 F0                 mulss   xmm6, xmm0
0000000180379494  F3 0F 11 B3 60 B0 00 00     movss   dword ptr [rbx+0B060h], xmm6
000000018037949C  0F 28 E6                    movaps  xmm4, xmm6
000000018037949F  F3 0F 10 9B 40 B1 00 00     movss   xmm3, dword ptr [rbx+0B140h]
00000001803794A7  F3 0F 10 93 90 B1 00 00     movss   xmm2, dword ptr [rbx+0B190h]
00000001803794AF  0F 28 CB                    movaps  xmm1, xmm3
00000001803794B2  F3 0F 59 8B B0 B1 00 00     mulss   xmm1, dword ptr [rbx+0B1B0h]
00000001803794BA  0F 28 C2                    movaps  xmm0, xmm2
00000001803794BD  F3 0F 58 A3 60 B1 00 00     addss   xmm4, dword ptr [rbx+0B160h]
00000001803794C5  F3 0F 5C B3 70 B0 00 00     subss   xmm6, dword ptr [rbx+0B070h]
00000001803794CD  F3 0F 59 C3                 mulss   xmm0, xmm3
00000001803794D1  41 0F 2F E6                 comiss  xmm4, xmm14
00000001803794D5  F3 0F 5C C8                 subss   xmm1, xmm0
00000001803794D9  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803794DD  F3 0F 11 8B B0 B0 00 00     movss   dword ptr [rbx+0B0B0h], xmm1
00000001803794E5  72 06                       jb      short loc_1803794ED
00000001803794E7  41 0F 28 FD                 movaps  xmm7, xmm13
00000001803794EB  EB 03                       jmp     short loc_1803794F0
00000001803794ED  0F 57 FF                    xorps   xmm7, xmm7
00000001803794F0  41 0F 2F F6                 comiss  xmm6, xmm14
00000001803794F4  F3 0F 10 83 10 B1 00 00     movss   xmm0, dword ptr [rbx+0B110h]
00000001803794FC  73 03                       jnb     short loc_180379501
00000001803794FE  0F 28 FD                    movaps  xmm7, xmm5
0000000180379501  F3 0F 59 83 90 B1 00 00     mulss   xmm0, dword ptr [rbx+0B190h]
0000000180379509  0F 28 DD                    movaps  xmm3, xmm5
000000018037950C  F3 0F 10 93 00 B1 00 00     movss   xmm2, dword ptr [rbx+0B100h]
0000000180379514  F3 0F 11 BB 70 B0 00 00     movss   dword ptr [rbx+0B070h], xmm7
000000018037951C  F3 0F 10 8B A0 B1 00 00     movss   xmm1, dword ptr [rbx+0B1A0h]
0000000180379524  F3 0F 10 B3 20 B1 00 00     movss   xmm6, dword ptr [rbx+0B120h]
000000018037952C  F3 0F 10 A3 A0 B0 00 00     movss   xmm4, dword ptr [rbx+0B0A0h]
0000000180379534  F3 0F 59 D8                 mulss   xmm3, xmm0
0000000180379538  0F 28 C1                    movaps  xmm0, xmm1
000000018037953B  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037953F  F3 41 0F 59 F1              mulss   xmm6, xmm9
0000000180379544  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180379548  F3 41 0F 59 D1              mulss   xmm2, xmm9
000000018037954D  41 0F 28 C5                 movaps  xmm0, xmm13
0000000180379551  F3 0F 59 F7                 mulss   xmm6, xmm7
0000000180379555  F3 0F 5C C7                 subss   xmm0, xmm7
0000000180379559  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037955D  F3 0F 59 E8                 mulss   xmm5, xmm0
0000000180379561  0F 28 CB                    movaps  xmm1, xmm3
0000000180379564  F3 0F 5C CC                 subss   xmm1, xmm4
0000000180379568  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037956C  41 0F 2F CE                 comiss  xmm1, xmm14
0000000180379570  F3 0F 58 F2                 addss   xmm6, xmm2
0000000180379574  76 0B                       jbe     short loc_180379581
0000000180379576  0F 28 DC                    movaps  xmm3, xmm4
0000000180379579  F3 0F 58 9B B0 B0 00 00     addss   xmm3, dword ptr [rbx+0B0B0h]
0000000180379581  F3 0F 10 A3 50 B0 00 00     movss   xmm4, dword ptr [rbx+0B050h]
0000000180379589  F3 0F 10 83 90 B1 00 00     movss   xmm0, dword ptr [rbx+0B190h]
0000000180379591  F3 0F 5D C3                 minss   xmm0, xmm3
0000000180379595  F3 0F 11 83 90 B0 00 00     movss   dword ptr [rbx+0B090h], xmm0
000000018037959D  F3 0F 59 AB 80 B1 00 00     mulss   xmm5, dword ptr [rbx+0B180h]
00000001803795A5  F3 0F 10 8B D0 B0 00 00     movss   xmm1, dword ptr [rbx+0B0D0h]
00000001803795AD  F3 0F 10 9B 30 B1 00 00     movss   xmm3, dword ptr [rbx+0B130h]
00000001803795B5  F3 0F 59 F8                 mulss   xmm7, xmm0
00000001803795B9  F3 0F 10 83 C0 B1 00 00     movss   xmm0, dword ptr [rbx+0B1C0h]
00000001803795C1  0F 28 D0                    movaps  xmm2, xmm0
00000001803795C4  F3 41 0F 59 D9              mulss   xmm3, xmm9
00000001803795C9  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803795CD  F3 0F 58 EF                 addss   xmm5, xmm7
00000001803795D1  F3 41 0F 59 D8              mulss   xmm3, xmm8
00000001803795D6  F3 0F 59 D6                 mulss   xmm2, xmm6
00000001803795DA  F3 0F 5C EC                 subss   xmm5, xmm4
00000001803795DE  F3 0F 5C D0                 subss   xmm2, xmm0
00000001803795E2  F3 0F 58 D1                 addss   xmm2, xmm1
00000001803795E6  F3 0F 11 93 C0 B0 00 00     movss   dword ptr [rbx+0B0C0h], xmm2
00000001803795EE  F3 44 0F 59 C2              mulss   xmm8, xmm2
00000001803795F3  F3 41 0F 5C D8              subss   xmm3, xmm8
00000001803795F8  F3 0F 58 DA                 addss   xmm3, xmm2
00000001803795FC  F3 0F 59 DD                 mulss   xmm3, xmm5
0000000180379600  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180379604  F3 0F 11 9B 40 B0 00 00     movss   dword ptr [rbx+0B040h], xmm3
000000018037960C  F3 0F 59 9B D0 B1 00 00     mulss   xmm3, dword ptr [rbx+0B1D0h]
0000000180379614  F3 0F 59 9B E0 B1 00 00     mulss   xmm3, dword ptr [rbx+0B1E0h]
000000018037961C  0F 28 C3                    movaps  xmm0, xmm3
000000018037961F  F3 0F 59 83 F0 B1 00 00     mulss   xmm0, dword ptr [rbx+0B1F0h]
0000000180379627  F3 0F 11 9B E0 B0 00 00     movss   dword ptr [rbx+0B0E0h], xmm3
000000018037962F  F3 0F 11 83 F0 B0 00 00     movss   dword ptr [rbx+0B0F0h], xmm0
0000000180379637  8B 83 00 B2 00 00           mov     eax, [rbx+0B200h]
000000018037963D  89 83 10 B2 00 00           mov     [rbx+0B210h], eax
0000000180379643  8B 83 20 B2 00 00           mov     eax, [rbx+0B220h]
0000000180379649  89 83 30 B2 00 00           mov     [rbx+0B230h], eax
000000018037964F  F3 0F 10 83 30 A7 00 00     movss   xmm0, dword ptr [rbx+0A730h]
0000000180379657  F3 44 0F 10 83 B0 A7 00 00  movss   xmm8, dword ptr [rbx+0A7B0h]
0000000180379660  8B 83 60 B2 00 00           mov     eax, [rbx+0B260h]
0000000180379666  89 83 70 B2 00 00           mov     [rbx+0B270h], eax
000000018037966C  F3 0F 59 83 40 B2 00 00     mulss   xmm0, dword ptr [rbx+0B240h]
0000000180379674  F3 44 0F 59 83 50 B2 00 00  mulss   xmm8, dword ptr [rbx+0B250h]
000000018037967D  F3 44 0F 58 C0              addss   xmm8, xmm0
0000000180379682  F3 44 0F 11 83 60 B2 00 00  movss   dword ptr [rbx+0B260h], xmm8
000000018037968B  F3 0F 10 BB 40 AB 00 00     movss   xmm7, dword ptr [rbx+0AB40h]
0000000180379693  F3 0F 10 8B 00 AF 00 00     movss   xmm1, dword ptr [rbx+0AF00h]
000000018037969B  F3 0F 10 93 E0 B0 00 00     movss   xmm2, dword ptr [rbx+0B0E0h]
00000001803796A3  F3 0F 10 83 30 A7 00 00     movss   xmm0, dword ptr [rbx+0A730h]
00000001803796AB  8B 83 20 B2 00 00           mov     eax, [rbx+0B220h]
00000001803796B1  89 83 A0 B2 00 00           mov     [rbx+0B2A0h], eax
00000001803796B7  F3 0F 11 83 B0 B2 00 00     movss   dword ptr [rbx+0B2B0h], xmm0
00000001803796BF  F3 0F 10 A3 F0 B3 00 00     movss   xmm4, dword ptr [rbx+0B3F0h]
00000001803796C7  F3 0F 11 8B 80 B2 00 00     movss   dword ptr [rbx+0B280h], xmm1
00000001803796CF  F3 0F 11 93 90 B2 00 00     movss   dword ptr [rbx+0B290h], xmm2
00000001803796D7  F3 0F 10 AB D0 B3 00 00     movss   xmm5, dword ptr [rbx+0B3D0h]
00000001803796DF  F3 0F 59 FC                 mulss   xmm7, xmm4
00000001803796E3  F3 0F 59 A3 50 AB 00 00     mulss   xmm4, dword ptr [rbx+0AB50h]
00000001803796EB  F3 0F 11 A3 C0 B2 00 00     movss   dword ptr [rbx+0B2C0h], xmm4
00000001803796F3  F3 0F 10 8B 50 B3 00 00     movss   xmm1, dword ptr [rbx+0B350h]
00000001803796FB  F3 0F 10 93 50 B4 00 00     movss   xmm2, dword ptr [rbx+0B450h]
0000000180379703  0F 28 D9                    movaps  xmm3, xmm1
0000000180379706  F3 0F 59 BB 00 B4 00 00     mulss   xmm7, dword ptr [rbx+0B400h]
000000018037970E  0F 28 C2                    movaps  xmm0, xmm2
0000000180379711  F3 0F 10 B3 10 B4 00 00     movss   xmm6, dword ptr [rbx+0B410h]
0000000180379719  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037971D  F3 0F 59 F7                 mulss   xmm6, xmm7
0000000180379721  F3 0F 59 EC                 mulss   xmm5, xmm4
0000000180379725  F3 0F 59 AB E0 B3 00 00     mulss   xmm5, dword ptr [rbx+0B3E0h]
000000018037972D  F3 0F 11 AB E0 B2 00 00     movss   dword ptr [rbx+0B2E0h], xmm5
0000000180379735  F3 0F 58 F5                 addss   xmm6, xmm5
0000000180379739  F3 0F 59 9B A0 B2 00 00     mulss   xmm3, dword ptr [rbx+0B2A0h]
0000000180379741  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180379745  F3 0F 10 83 60 B3 00 00     movss   xmm0, dword ptr [rbx+0B360h]
000000018037974D  F3 0F 58 DA                 addss   xmm3, xmm2
0000000180379751  F3 0F 59 9B 60 B4 00 00     mulss   xmm3, dword ptr [rbx+0B460h]
0000000180379759  F3 0F 11 9B F0 B2 00 00     movss   dword ptr [rbx+0B2F0h], xmm3
0000000180379761  F3 0F 10 8B 30 B4 00 00     movss   xmm1, dword ptr [rbx+0B430h]
0000000180379769  F3 0F 59 8B 90 B2 00 00     mulss   xmm1, dword ptr [rbx+0B290h]
0000000180379771  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180379775  F3 0F 58 F0                 addss   xmm6, xmm0
0000000180379779  F3 0F 10 83 20 B4 00 00     movss   xmm0, dword ptr [rbx+0B420h]
0000000180379781  F3 0F 59 83 80 B2 00 00     mulss   xmm0, dword ptr [rbx+0B280h]
0000000180379789  F3 0F 10 9B C0 B2 00 00     movss   xmm3, dword ptr [rbx+0B2C0h]
0000000180379791  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180379795  F3 0F 10 83 40 B3 00 00     movss   xmm0, dword ptr [rbx+0B340h]
000000018037979D  F3 0F 59 8B 40 B4 00 00     mulss   xmm1, dword ptr [rbx+0B440h]
00000001803797A5  F3 0F 58 CE                 addss   xmm1, xmm6
00000001803797A9  F3 41 0F 58 C8              addss   xmm1, xmm8
00000001803797AE  F3 0F 58 8B B0 B3 00 00     addss   xmm1, dword ptr [rbx+0B3B0h]
00000001803797B6  F3 0F 58 8B C0 B3 00 00     addss   xmm1, dword ptr [rbx+0B3C0h]
00000001803797BE  F3 0F 11 8B 00 B3 00 00     movss   dword ptr [rbx+0B300h], xmm1
00000001803797C6  F3 0F 11 83 10 B3 00 00     movss   dword ptr [rbx+0B310h], xmm0
00000001803797CE  F3 0F 59 9B 80 B4 00 00     mulss   xmm3, dword ptr [rbx+0B480h]
00000001803797D6  F3 0F 10 83 80 B3 00 00     movss   xmm0, dword ptr [rbx+0B380h]
00000001803797DE  F3 0F 59 83 80 B2 00 00     mulss   xmm0, dword ptr [rbx+0B280h]
00000001803797E6  F3 0F 58 9B 90 B4 00 00     addss   xmm3, dword ptr [rbx+0B490h]
00000001803797EE  F3 0F 10 8B 90 B3 00 00     movss   xmm1, dword ptr [rbx+0B390h]
00000001803797F6  F3 0F 59 8B 90 B2 00 00     mulss   xmm1, dword ptr [rbx+0B290h]
00000001803797FE  F3 0F 10 93 E0 B2 00 00     movss   xmm2, dword ptr [rbx+0B2E0h]
0000000180379806  F3 0F 59 9B 70 B3 00 00     mulss   xmm3, dword ptr [rbx+0B370h]
000000018037980E  F3 0F 58 93 B0 B2 00 00     addss   xmm2, dword ptr [rbx+0B2B0h]
0000000180379816  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037981A  F3 0F 58 93 F0 B2 00 00     addss   xmm2, dword ptr [rbx+0B2F0h]
0000000180379822  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180379826  F3 0F 58 9B A0 B3 00 00     addss   xmm3, dword ptr [rbx+0B3A0h]
000000018037982E  F3 0F 59 9B 70 B4 00 00     mulss   xmm3, dword ptr [rbx+0B470h]
0000000180379836  F3 0F 11 9B 20 B3 00 00     movss   dword ptr [rbx+0B320h], xmm3
000000018037983E  F3 0F 11 93 30 B3 00 00     movss   dword ptr [rbx+0B330h], xmm2
0000000180379846  F3 0F 10 83 B0 B4 00 00     movss   xmm0, dword ptr [rbx+0B4B0h]
000000018037984E  8B 83 A0 B4 00 00           mov     eax, [rbx+0B4A0h]
0000000180379854  89 83 D0 B4 00 00           mov     [rbx+0B4D0h], eax
000000018037985A  F3 0F 11 83 E0 B4 00 00     movss   dword ptr [rbx+0B4E0h], xmm0
0000000180379862  8B 83 C0 B4 00 00           mov     eax, [rbx+0B4C0h]
0000000180379868  89 83 F0 B4 00 00           mov     [rbx+0B4F0h], eax
000000018037986E  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
0000000180379876  8B 83 10 B5 00 00           mov     eax, [rbx+0B510h]
000000018037987C  89 83 20 B5 00 00           mov     [rbx+0B520h], eax
0000000180379882  F3 0F 10 93 00 B5 00 00     movss   xmm2, dword ptr [rbx+0B500h]
000000018037988A  F3 0F 11 93 10 B5 00 00     movss   dword ptr [rbx+0B510h], xmm2
0000000180379892  0F 28 C2                    movaps  xmm0, xmm2
0000000180379895  0F 28 DA                    movaps  xmm3, xmm2
0000000180379898  F3 0F 59 9B 30 B5 00 00     mulss   xmm3, dword ptr [rbx+0B530h]
00000001803798A0  F3 0F 58 9B 20 B5 00 00     addss   xmm3, dword ptr [rbx+0B520h]
00000001803798A8  F3 0F 11 9B 10 B5 00 00     movss   dword ptr [rbx+0B510h], xmm3
00000001803798B0  F3 0F 59 83 40 B5 00 00     mulss   xmm0, dword ptr [rbx+0B540h]
00000001803798B8  F3 0F 58 C3                 addss   xmm0, xmm3
00000001803798BC  F3 0F 59 9B 70 B5 00 00     mulss   xmm3, dword ptr [rbx+0B570h]
00000001803798C4  F3 0F 5C E0                 subss   xmm4, xmm0
00000001803798C8  0F 28 CC                    movaps  xmm1, xmm4
00000001803798CB  F3 0F 59 8B 30 B5 00 00     mulss   xmm1, dword ptr [rbx+0B530h]
00000001803798D3  F3 0F 58 CA                 addss   xmm1, xmm2
00000001803798D7  F3 0F 11 8B 00 B5 00 00     movss   dword ptr [rbx+0B500h], xmm1
00000001803798DF  F3 0F 59 8B 60 B5 00 00     mulss   xmm1, dword ptr [rbx+0B560h]
00000001803798E7  F3 0F 59 A3 50 B5 00 00     mulss   xmm4, dword ptr [rbx+0B550h]
00000001803798EF  F3 0F 58 E3                 addss   xmm4, xmm3
00000001803798F3  F3 0F 58 E1                 addss   xmm4, xmm1
00000001803798F7  F3 0F 11 A3 20 B5 00 00     movss   dword ptr [rbx+0B520h], xmm4
00000001803798FF  8B 83 50 BD 00 00           mov     eax, [rbx+0BD50h]
0000000180379905  89 83 60 BD 00 00           mov     [rbx+0BD60h], eax
000000018037990B  F3 0F 10 8B 70 BD 00 00     movss   xmm1, dword ptr [rbx+0BD70h]
0000000180379913  F3 0F 11 8B 80 BD 00 00     movss   dword ptr [rbx+0BD80h], xmm1
000000018037991B  F3 0F 59 8B 10 B2 00 00     mulss   xmm1, dword ptr [rbx+0B210h]
0000000180379923  F3 0F 10 83 60 BD 00 00     movss   xmm0, dword ptr [rbx+0BD60h]
000000018037992B  F3 0F 59 83 20 B5 00 00     mulss   xmm0, dword ptr [rbx+0B520h]
0000000180379933  F3 0F 11 8B 90 BD 00 00     movss   dword ptr [rbx+0BD90h], xmm1
000000018037993B  F3 0F 11 83 A0 BD 00 00     movss   dword ptr [rbx+0BDA0h], xmm0
0000000180379943  8B 83 D0 BD 00 00           mov     eax, [rbx+0BDD0h]
0000000180379949  89 83 E0 BD 00 00           mov     [rbx+0BDE0h], eax
000000018037994F  F3 0F 59 8B B0 BD 00 00     mulss   xmm1, dword ptr [rbx+0BDB0h]
0000000180379957  F3 0F 59 83 C0 BD 00 00     mulss   xmm0, dword ptr [rbx+0BDC0h]
000000018037995F  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180379963  F3 0F 11 83 D0 BD 00 00     movss   dword ptr [rbx+0BDD0h], xmm0
000000018037996B  8B 83 F0 BD 00 00           mov     eax, [rbx+0BDF0h]
0000000180379971  89 83 00 BE 00 00           mov     [rbx+0BE00h], eax
0000000180379977  8B 83 10 BE 00 00           mov     eax, [rbx+0BE10h]
000000018037997D  89 83 20 BE 00 00           mov     [rbx+0BE20h], eax
0000000180379983  8B 83 30 BE 00 00           mov     eax, [rbx+0BE30h]
0000000180379989  89 83 40 BE 00 00           mov     [rbx+0BE40h], eax
000000018037998F  8B 83 50 BE 00 00           mov     eax, [rbx+0BE50h]
0000000180379995  89 83 60 BE 00 00           mov     [rbx+0BE60h], eax
000000018037999B  F3 0F 10 8B 80 BE 00 00     movss   xmm1, dword ptr [rbx+0BE80h]
00000001803799A3  F3 0F 10 93 90 BE 00 00     movss   xmm2, dword ptr [rbx+0BE90h]
00000001803799AB  0F 28 E1                    movaps  xmm4, xmm1
00000001803799AE  F3 0F 59 A3 F0 BD 00 00     mulss   xmm4, dword ptr [rbx+0BDF0h]
00000001803799B6  0F 28 C2                    movaps  xmm0, xmm2
00000001803799B9  F3 0F 59 C1                 mulss   xmm0, xmm1
00000001803799BD  F3 0F 5C E0                 subss   xmm4, xmm0
00000001803799C1  F3 0F 58 E2                 addss   xmm4, xmm2
00000001803799C5  0F 28 DC                    movaps  xmm3, xmm4
00000001803799C8  0F 28 CC                    movaps  xmm1, xmm4
00000001803799CB  F3 0F 59 8B B0 BE 00 00     mulss   xmm1, dword ptr [rbx+0BEB0h]
00000001803799D3  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803799D7  F3 0F 58 8B A0 BE 00 00     addss   xmm1, dword ptr [rbx+0BEA0h]
00000001803799DF  0F 28 C3                    movaps  xmm0, xmm3
00000001803799E2  F3 0F 59 DC                 mulss   xmm3, xmm4
00000001803799E6  F3 0F 59 83 C0 BE 00 00     mulss   xmm0, dword ptr [rbx+0BEC0h]
00000001803799EE  F3 0F 58 C8                 addss   xmm1, xmm0
00000001803799F2  0F 28 C3                    movaps  xmm0, xmm3
00000001803799F5  F3 0F 59 9B D0 BE 00 00     mulss   xmm3, dword ptr [rbx+0BED0h]
00000001803799FD  F3 0F 59 C4                 mulss   xmm0, xmm4
0000000180379A01  F3 0F 58 D9                 addss   xmm3, xmm1
0000000180379A05  F3 0F 59 83 E0 BE 00 00     mulss   xmm0, dword ptr [rbx+0BEE0h]
0000000180379A0D  F3 0F 58 C3                 addss   xmm0, xmm3
0000000180379A11  41 0F 2F C6                 comiss  xmm0, xmm14
0000000180379A15  76 05                       jbe     short loc_180379A1C
0000000180379A17  0F 5A C0                    cvtps2pd xmm0, xmm0
0000000180379A1A  EB 03                       jmp     short loc_180379A1F
0000000180379A1C  0F 57 C0                    xorps   xmm0, xmm0
0000000180379A1F  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
0000000180379A23  41 0F 2F CD                 comiss  xmm1, xmm13
0000000180379A27  73 04                       jnb     short loc_180379A2D
0000000180379A29  44 0F 5A E1                 cvtps2pd xmm12, xmm1
0000000180379A2D  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
0000000180379A32  F3 0F 11 83 70 BE 00 00     movss   dword ptr [rbx+0BE70h], xmm0
0000000180379A3A  8B 83 F0 BE 00 00           mov     eax, [rbx+0BEF0h]
0000000180379A40  89 83 00 BF 00 00           mov     [rbx+0BF00h], eax
0000000180379A46  F3 0F 10 8B 10 BF 00 00     movss   xmm1, dword ptr [rbx+0BF10h]
0000000180379A4E  F3 0F 11 8B 20 BF 00 00     movss   dword ptr [rbx+0BF20h], xmm1
0000000180379A56  F3 0F 10 83 30 BF 00 00     movss   xmm0, dword ptr [rbx+0BF30h]
0000000180379A5E  F3 0F 11 83 40 BF 00 00     movss   dword ptr [rbx+0BF40h], xmm0
0000000180379A66  F3 0F 5C C8                 subss   xmm1, xmm0
0000000180379A6A  F3 0F 59 8B 50 BF 00 00     mulss   xmm1, dword ptr [rbx+0BF50h]
0000000180379A72  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180379A76  F3 0F 11 8B 30 BF 00 00     movss   dword ptr [rbx+0BF30h], xmm1
0000000180379A7E  F3 0F 10 8B 30 A7 00 00     movss   xmm1, dword ptr [rbx+0A730h]
0000000180379A86  F3 0F 10 83 B0 A7 00 00     movss   xmm0, dword ptr [rbx+0A7B0h]
0000000180379A8E  8B 83 80 BF 00 00           mov     eax, [rbx+0BF80h]
0000000180379A94  89 83 90 BF 00 00           mov     [rbx+0BF90h], eax
0000000180379A9A  F3 0F 59 83 70 BF 00 00     mulss   xmm0, dword ptr [rbx+0BF70h]
0000000180379AA2  F3 0F 59 8B 60 BF 00 00     mulss   xmm1, dword ptr [rbx+0BF60h]
0000000180379AAA  F3 0F 58 C1                 addss   xmm0, xmm1
0000000180379AAE  F3 0F 11 83 80 BF 00 00     movss   dword ptr [rbx+0BF80h], xmm0
0000000180379AB6  8B 83 A0 BF 00 00           mov     eax, [rbx+0BFA0h]
0000000180379ABC  89 83 C0 BF 00 00           mov     [rbx+0BFC0h], eax
0000000180379AC2  F3 0F 10 9B B0 BF 00 00     movss   xmm3, dword ptr [rbx+0BFB0h]
0000000180379ACA  F3 0F 11 9B D0 BF 00 00     movss   dword ptr [rbx+0BFD0h], xmm3
0000000180379AD2  F3 0F 10 8B C0 BF 00 00     movss   xmm1, dword ptr [rbx+0BFC0h]
0000000180379ADA  F3 0F 10 93 00 AF 00 00     movss   xmm2, dword ptr [rbx+0AF00h]
0000000180379AE2  0F 28 C1                    movaps  xmm0, xmm1
0000000180379AE5  F3 0F 59 83 E0 B0 00 00     mulss   xmm0, dword ptr [rbx+0B0E0h]
0000000180379AED  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180379AF1  F3 0F 5C C1                 subss   xmm0, xmm1
0000000180379AF5  0F 28 CB                    movaps  xmm1, xmm3
0000000180379AF8  F3 0F 59 8B 30 BE 00 00     mulss   xmm1, dword ptr [rbx+0BE30h]
0000000180379B00  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180379B04  F3 0F 59 DA                 mulss   xmm3, xmm2
0000000180379B08  F3 0F 5C CB                 subss   xmm1, xmm3
0000000180379B0C  F3 0F 58 CA                 addss   xmm1, xmm2
0000000180379B10  F3 0F 11 8B E0 BF 00 00     movss   dword ptr [rbx+0BFE0h], xmm1
0000000180379B18  F3 0F 10 9B 40 AB 00 00     movss   xmm3, dword ptr [rbx+0AB40h]
0000000180379B20  F3 0F 10 83 F0 BF 00 00     movss   xmm0, dword ptr [rbx+0BFF0h]
0000000180379B28  F3 0F 11 83 00 C0 00 00     movss   dword ptr [rbx+0C000h], xmm0
0000000180379B30  F3 0F 5C D8                 subss   xmm3, xmm0
0000000180379B34  0F 28 CB                    movaps  xmm1, xmm3
0000000180379B37  F3 0F 59 8B 10 C0 00 00     mulss   xmm1, dword ptr [rbx+0C010h]
0000000180379B3F  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180379B43  F3 0F 10 83 30 C0 00 00     movss   xmm0, dword ptr [rbx+0C030h]
0000000180379B4B  F3 0F 11 8B F0 BF 00 00     movss   dword ptr [rbx+0BFF0h], xmm1
0000000180379B53  F3 0F 59 9B 20 C0 00 00     mulss   xmm3, dword ptr [rbx+0C020h]
0000000180379B5B  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180379B5F  F3 0F 58 D8                 addss   xmm3, xmm0
0000000180379B63  F3 0F 11 9B 00 C0 00 00     movss   dword ptr [rbx+0C000h], xmm3
0000000180379B6B  F3 0F 10 83 40 C0 00 00     movss   xmm0, dword ptr [rbx+0C040h]
0000000180379B73  F3 0F 10 BB 50 AB 00 00     movss   xmm7, dword ptr [rbx+0AB50h]
0000000180379B7B  F3 0F 11 83 50 C0 00 00     movss   dword ptr [rbx+0C050h], xmm0
0000000180379B83  F3 0F 5C F8                 subss   xmm7, xmm0
0000000180379B87  0F 28 CF                    movaps  xmm1, xmm7
0000000180379B8A  F3 0F 59 8B 60 C0 00 00     mulss   xmm1, dword ptr [rbx+0C060h]
0000000180379B92  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180379B96  F3 0F 10 83 80 C0 00 00     movss   xmm0, dword ptr [rbx+0C080h]
0000000180379B9E  F3 0F 11 8B 40 C0 00 00     movss   dword ptr [rbx+0C040h], xmm1
0000000180379BA6  F3 0F 59 BB 70 C0 00 00     mulss   xmm7, dword ptr [rbx+0C070h]
0000000180379BAE  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180379BB2  F3 0F 58 F8                 addss   xmm7, xmm0
0000000180379BB6  F3 0F 11 BB 50 C0 00 00     movss   dword ptr [rbx+0C050h], xmm7
0000000180379BBE  F3 0F 10 A3 00 C0 00 00     movss   xmm4, dword ptr [rbx+0C000h]
0000000180379BC6  F3 0F 10 AB E0 BF 00 00     movss   xmm5, dword ptr [rbx+0BFE0h]
0000000180379BCE  F3 0F 10 B3 80 BF 00 00     movss   xmm6, dword ptr [rbx+0BF80h]
0000000180379BD6  F3 44 0F 10 8B 10 BE 00 00  movss   xmm9, dword ptr [rbx+0BE10h]
0000000180379BDF  8B 83 30 BF 00 00           mov     eax, [rbx+0BF30h]
0000000180379BE5  89 83 90 C0 00 00           mov     [rbx+0C090h], eax
0000000180379BEB  F3 44 0F 11 8B A0 C0 00 00  movss   dword ptr [rbx+0C0A0h], xmm9
0000000180379BF4  F3 0F 10 83 C0 C0 00 00     movss   xmm0, dword ptr [rbx+0C0C0h]
0000000180379BFC  F3 0F 10 93 D0 C0 00 00     movss   xmm2, dword ptr [rbx+0C0D0h]
0000000180379C04  F3 0F 59 F8                 mulss   xmm7, xmm0
0000000180379C08  0F 28 DA                    movaps  xmm3, xmm2
0000000180379C0B  F3 0F 59 9B 50 BE 00 00     mulss   xmm3, dword ptr [rbx+0BE50h]
0000000180379C13  F3 0F 59 E0                 mulss   xmm4, xmm0
0000000180379C17  0F 28 C2                    movaps  xmm0, xmm2
0000000180379C1A  F3 0F 59 C7                 mulss   xmm0, xmm7
0000000180379C1E  44 0F 28 C3                 movaps  xmm8, xmm3
0000000180379C22  F3 44 0F 5C C0              subss   xmm8, xmm0
0000000180379C27  F3 44 0F 58 C7              addss   xmm8, xmm7
0000000180379C2C  F3 44 0F 59 83 00 C1 00 00  mulss   xmm8, dword ptr [rbx+0C100h]
0000000180379C35  F3 0F 10 8B E0 C0 00 00     movss   xmm1, dword ptr [rbx+0C0E0h]
0000000180379C3D  F3 0F 58 B3 80 C1 00 00     addss   xmm6, dword ptr [rbx+0C180h]
0000000180379C45  F3 44 0F 59 83 10 C1 00 00  mulss   xmm8, dword ptr [rbx+0C110h]
0000000180379C4E  F3 0F 59 AB 20 C1 00 00     mulss   xmm5, dword ptr [rbx+0C120h]
0000000180379C56  F3 0F 59 B3 30 C1 00 00     mulss   xmm6, dword ptr [rbx+0C130h]
0000000180379C5E  F3 44 0F 59 C9              mulss   xmm9, xmm1
0000000180379C63  F3 0F 59 D4                 mulss   xmm2, xmm4
0000000180379C67  F3 0F 58 F5                 addss   xmm6, xmm5
0000000180379C6B  F3 0F 5C DA                 subss   xmm3, xmm2
0000000180379C6F  F3 0F 10 93 60 C1 00 00     movss   xmm2, dword ptr [rbx+0C160h]
0000000180379C77  0F 28 C2                    movaps  xmm0, xmm2
0000000180379C7A  F3 0F 59 C1                 mulss   xmm0, xmm1
0000000180379C7E  F3 0F 58 DC                 addss   xmm3, xmm4
0000000180379C82  F3 44 0F 5C C8              subss   xmm9, xmm0
0000000180379C87  F3 0F 10 83 50 C1 00 00     movss   xmm0, dword ptr [rbx+0C150h]
0000000180379C8F  F3 0F 58 83 90 C0 00 00     addss   xmm0, dword ptr [rbx+0C090h]
0000000180379C97  F3 0F 59 9B F0 C0 00 00     mulss   xmm3, dword ptr [rbx+0C0F0h]
0000000180379C9F  F3 0F 59 83 90 C1 00 00     mulss   xmm0, dword ptr [rbx+0C190h]
0000000180379CA7  F3 44 0F 58 CA              addss   xmm9, xmm2
0000000180379CAC  F3 44 0F 58 C3              addss   xmm8, xmm3
0000000180379CB1  F3 0F 59 83 40 C1 00 00     mulss   xmm0, dword ptr [rbx+0C140h]
0000000180379CB9  F3 44 0F 59 8B 70 C1 00 00  mulss   xmm9, dword ptr [rbx+0C170h]
0000000180379CC2  F3 44 0F 58 C6              addss   xmm8, xmm6
0000000180379CC7  F3 44 0F 58 C8              addss   xmm9, xmm0
0000000180379CCC  F3 45 0F 58 C8              addss   xmm9, xmm8
0000000180379CD1  F3 44 0F 11 8B B0 C0 00 00  movss   dword ptr [rbx+0C0B0h], xmm9
0000000180379CDA  F3 0F 10 BB 70 BE 00 00     movss   xmm7, dword ptr [rbx+0BE70h]
0000000180379CE2  F3 44 0F 10 83 00 BF 00 00  movss   xmm8, dword ptr [rbx+0BF00h]
0000000180379CEB  8B 83 D0 C1 00 00           mov     eax, [rbx+0C1D0h]
0000000180379CF1  89 83 E0 C1 00 00           mov     [rbx+0C1E0h], eax
0000000180379CF7  F3 0F 10 83 C0 C1 00 00     movss   xmm0, dword ptr [rbx+0C1C0h]
0000000180379CFF  F3 0F 11 83 D0 C1 00 00     movss   dword ptr [rbx+0C1D0h], xmm0
0000000180379D07  44 0F 2E AB 10 C2 00 00     ucomiss xmm13, dword ptr [rbx+0C210h]
0000000180379D0F  0F 85 8F 02 00 00           jnz     loc_180379FA4
0000000180379D15  F3 0F 10 8B 60 C2 00 00     movss   xmm1, dword ptr [rbx+0C260h]
0000000180379D1D  F3 0F 10 B3 E0 C1 00 00     movss   xmm6, dword ptr [rbx+0C1E0h]
0000000180379D25  0F 28 D1                    movaps  xmm2, xmm1
0000000180379D28  F3 0F 59 CE                 mulss   xmm1, xmm6
0000000180379D2C  F3 0F 59 D0                 mulss   xmm2, xmm0
0000000180379D30  41 0F 57 C3                 xorps   xmm0, xmm11
0000000180379D34  F3 0F 5C D1                 subss   xmm2, xmm1
0000000180379D38  F3 0F 58 F2                 addss   xmm6, xmm2
0000000180379D3C  F3 0F 11 B3 D0 C1 00 00     movss   dword ptr [rbx+0C1D0h], xmm6
0000000180379D44  F3 0F 59 B3 50 C2 00 00     mulss   xmm6, dword ptr [rbx+0C250h]
0000000180379D4C  F3 0F 58 B3 F0 C1 00 00     addss   xmm6, dword ptr [rbx+0C1F0h]
0000000180379D54  E8 07 F0 FE FF              call    sub_180368D60
0000000180379D59  F3 0F 11 83 C0 C1 00 00     movss   dword ptr [rbx+0C1C0h], xmm0
0000000180379D61  41 0F 28 C8                 movaps  xmm1, xmm8
0000000180379D65  F3 0F 59 8B B0 C2 00 00     mulss   xmm1, dword ptr [rbx+0C2B0h]
0000000180379D6D  41 0F 28 D5                 movaps  xmm2, xmm13
0000000180379D71  F3 41 0F 5C D0              subss   xmm2, xmm8
0000000180379D76  F3 0F 58 8B 00 C2 00 00     addss   xmm1, dword ptr [rbx+0C200h]
0000000180379D7E  F3 0F 59 93 70 C2 00 00     mulss   xmm2, dword ptr [rbx+0C270h]
0000000180379D86  F3 0F 11 8B B0 C1 00 00     movss   dword ptr [rbx+0C1B0h], xmm1
0000000180379D8E  F3 44 0F 59 8B 40 C2 00 00  mulss   xmm9, dword ptr [rbx+0C240h]
0000000180379D97  F3 0F 59 BB 20 C2 00 00     mulss   xmm7, dword ptr [rbx+0C220h]
0000000180379D9F  F3 0F 10 83 80 C2 00 00     movss   xmm0, dword ptr [rbx+0C280h]
0000000180379DA7  F3 0F 5D C2                 minss   xmm0, xmm2
0000000180379DAB  F3 44 0F 58 CF              addss   xmm9, xmm7
0000000180379DB0  F3 44 0F 58 CE              addss   xmm9, xmm6
0000000180379DB5  F3 44 0F 58 C8              addss   xmm9, xmm0
0000000180379DBA  F3 44 0F 58 8B 30 C2 00 00  addss   xmm9, dword ptr [rbx+0C230h]
0000000180379DC3  F3 44 0F 5D 8B 90 C2 00 00  minss   xmm9, dword ptr [rbx+0C290h]
0000000180379DCC  F3 44 0F 5F 8B A0 C2 00 00  maxss   xmm9, dword ptr [rbx+0C2A0h]
0000000180379DD5  F3 44 0F 59 8B D0 C2 00 00  mulss   xmm9, dword ptr [rbx+0C2D0h]
0000000180379DDE  F3 44 0F 58 8B E0 C2 00 00  addss   xmm9, dword ptr [rbx+0C2E0h]
0000000180379DE7  41 0F 28 C9                 movaps  xmm1, xmm9
0000000180379DEB  F3 0F 2C C9                 cvttss2si ecx, xmm1
0000000180379DEF  81 F9 00 00 00 80           cmp     ecx, 80000000h
0000000180379DF5  74 1E                       jz      short loc_180379E15
0000000180379DF7  66 0F 6E C1                 movd    xmm0, ecx
0000000180379DFB  0F 5B C0                    cvtdq2ps xmm0, xmm0
0000000180379DFE  0F 2E C1                    ucomiss xmm0, xmm1
0000000180379E01  74 12                       jz      short loc_180379E15
0000000180379E03  0F 14 C9                    unpcklps xmm1, xmm1
0000000180379E06  0F 50 C1                    movmskps eax, xmm1
0000000180379E09  83 E0 01                    and     eax, 1
0000000180379E0C  2B C8                       sub     ecx, eax
0000000180379E0E  66 0F 6E C9                 movd    xmm1, ecx
0000000180379E12  0F 5B C9                    cvtdq2ps xmm1, xmm1
0000000180379E15  F3 44 0F 5C C9              subss   xmm9, xmm1
0000000180379E1A  0F 28 C1                    movaps  xmm0, xmm1; X
0000000180379E1D  41 0F 28 F1                 movaps  xmm6, xmm9
0000000180379E21  F3 41 0F 59 F1              mulss   xmm6, xmm9
0000000180379E26  F3 0F 59 35 A2 B1 76 00     mulss   xmm6, cs:dword_180AE4FD0
0000000180379E2E  E8 0D 59 37 00              call    expf
0000000180379E33  0F 28 E0                    movaps  xmm4, xmm0
0000000180379E36  41 0F 28 D1                 movaps  xmm2, xmm9
0000000180379E3A  F3 0F 59 93 A0 C3 00 00     mulss   xmm2, dword ptr [rbx+0C3A0h]
0000000180379E42  41 0F 28 C9                 movaps  xmm1, xmm9
0000000180379E46  F3 0F 59 8B 80 C3 00 00     mulss   xmm1, dword ptr [rbx+0C380h]
0000000180379E4E  41 0F 28 C1                 movaps  xmm0, xmm9
0000000180379E52  F3 0F 58 93 90 C3 00 00     addss   xmm2, dword ptr [rbx+0C390h]
0000000180379E5A  F3 0F 59 83 60 C3 00 00     mulss   xmm0, dword ptr [rbx+0C360h]
0000000180379E62  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180379E66  F3 0F 58 D1                 addss   xmm2, xmm1
0000000180379E6A  F3 0F 58 93 70 C3 00 00     addss   xmm2, dword ptr [rbx+0C370h]
0000000180379E72  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180379E76  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180379E7A  41 0F 28 C1                 movaps  xmm0, xmm9
0000000180379E7E  F3 0F 59 83 40 C3 00 00     mulss   xmm0, dword ptr [rbx+0C340h]
0000000180379E86  F3 0F 58 93 50 C3 00 00     addss   xmm2, dword ptr [rbx+0C350h]
0000000180379E8E  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180379E92  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180379E96  41 0F 28 C1                 movaps  xmm0, xmm9
0000000180379E9A  F3 0F 59 83 20 C3 00 00     mulss   xmm0, dword ptr [rbx+0C320h]
0000000180379EA2  F3 44 0F 59 8B 00 C3 00 00  mulss   xmm9, dword ptr [rbx+0C300h]
0000000180379EAB  F3 0F 58 93 30 C3 00 00     addss   xmm2, dword ptr [rbx+0C330h]
0000000180379EB3  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180379EB7  F3 0F 58 D0                 addss   xmm2, xmm0
0000000180379EBB  F3 0F 58 93 10 C3 00 00     addss   xmm2, dword ptr [rbx+0C310h]
0000000180379EC3  F3 0F 59 D6                 mulss   xmm2, xmm6
0000000180379EC7  F3 41 0F 58 D1              addss   xmm2, xmm9
0000000180379ECC  F3 41 0F 58 D5              addss   xmm2, xmm13
0000000180379ED1  F3 0F 59 E2                 mulss   xmm4, xmm2
0000000180379ED5  F3 0F 59 A3 F0 C2 00 00     mulss   xmm4, dword ptr [rbx+0C2F0h]
0000000180379EDD  0F 28 DC                    movaps  xmm3, xmm4
0000000180379EE0  F3 0F 59 DC                 mulss   xmm3, xmm4
0000000180379EE4  0F 28 CB                    movaps  xmm1, xmm3
0000000180379EE7  44 0F 28 C3                 movaps  xmm8, xmm3
0000000180379EEB  F3 44 0F 59 83 40 C4 00 00  mulss   xmm8, dword ptr [rbx+0C440h]
0000000180379EF4  0F 28 C3                    movaps  xmm0, xmm3
0000000180379EF7  F3 0F 59 83 00 C4 00 00     mulss   xmm0, dword ptr [rbx+0C400h]
0000000180379EFF  0F 28 D3                    movaps  xmm2, xmm3
0000000180379F02  F3 44 0F 58 83 20 C4 00 00  addss   xmm8, dword ptr [rbx+0C420h]
0000000180379F0B  F3 0F 59 CC                 mulss   xmm1, xmm4
0000000180379F0F  F3 0F 58 83 E0 C3 00 00     addss   xmm0, dword ptr [rbx+0C3E0h]
0000000180379F17  F3 0F 59 D3                 mulss   xmm2, xmm3
0000000180379F1B  F3 44 0F 59 C2              mulss   xmm8, xmm2
0000000180379F20  F3 44 0F 58 C0              addss   xmm8, xmm0
0000000180379F25  0F 28 C1                    movaps  xmm0, xmm1
0000000180379F28  F3 0F 59 8B C0 C3 00 00     mulss   xmm1, dword ptr [rbx+0C3C0h]
0000000180379F30  F3 0F 59 C3                 mulss   xmm0, xmm3
0000000180379F34  F3 44 0F 59 C0              mulss   xmm8, xmm0
0000000180379F39  0F 28 C3                    movaps  xmm0, xmm3
0000000180379F3C  F3 0F 59 83 F0 C3 00 00     mulss   xmm0, dword ptr [rbx+0C3F0h]
0000000180379F44  F3 44 0F 58 C1              addss   xmm8, xmm1
0000000180379F49  0F 28 CB                    movaps  xmm1, xmm3
0000000180379F4C  F3 0F 59 8B 30 C4 00 00     mulss   xmm1, dword ptr [rbx+0C430h]
0000000180379F54  F3 0F 59 9B B0 C3 00 00     mulss   xmm3, dword ptr [rbx+0C3B0h]
0000000180379F5C  F3 0F 58 8B 10 C4 00 00     addss   xmm1, dword ptr [rbx+0C410h]
0000000180379F64  F3 44 0F 58 C4              addss   xmm8, xmm4
0000000180379F69  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180379F6D  F3 0F 58 C8                 addss   xmm1, xmm0
0000000180379F71  F3 0F 58 8B D0 C3 00 00     addss   xmm1, dword ptr [rbx+0C3D0h]
0000000180379F79  F3 0F 59 CA                 mulss   xmm1, xmm2
0000000180379F7D  F3 0F 58 CB                 addss   xmm1, xmm3
0000000180379F81  F3 41 0F 58 CD              addss   xmm1, xmm13
0000000180379F86  F3 44 0F 5E C1              divss   xmm8, xmm1
0000000180379F8B  41 0F 28 C0                 movaps  xmm0, xmm8
0000000180379F8F  F3 41 0F 58 C5              addss   xmm0, xmm13
0000000180379F94  F3 44 0F 5E C0              divss   xmm8, xmm0
0000000180379F99  F3 44 0F 11 83 A0 C1 00 00  movss   dword ptr [rbx+0C1A0h], xmm8
0000000180379FA2  EB 09                       jmp     short loc_180379FAD
0000000180379FA4  F3 44 0F 10 83 A0 C1 00 00  movss   xmm8, dword ptr [rbx+0C1A0h]
0000000180379FAD  8B 83 B0 C4 00 00           mov     eax, [rbx+0C4B0h]
0000000180379FB3  F3 0F 10 8B D0 BD 00 00     movss   xmm1, dword ptr [rbx+0BDD0h]
0000000180379FBB  F3 44 0F 10 8B B0 C1 00 00  movss   xmm9, dword ptr [rbx+0C1B0h]
0000000180379FC4  89 83 C0 C4 00 00           mov     [rbx+0C4C0h], eax
0000000180379FCA  8B 83 A0 C4 00 00           mov     eax, [rbx+0C4A0h]
0000000180379FD0  89 83 B0 C4 00 00           mov     [rbx+0C4B0h], eax
0000000180379FD6  8B 83 90 C4 00 00           mov     eax, [rbx+0C490h]
0000000180379FDC  89 83 A0 C4 00 00           mov     [rbx+0C4A0h], eax
0000000180379FE2  8B 83 80 C4 00 00           mov     eax, [rbx+0C480h]
0000000180379FE8  89 83 90 C4 00 00           mov     [rbx+0C490h], eax
0000000180379FEE  8B 83 70 C4 00 00           mov     eax, [rbx+0C470h]
0000000180379FF4  89 83 80 C4 00 00           mov     [rbx+0C480h], eax
0000000180379FFA  8B 83 60 C4 00 00           mov     eax, [rbx+0C460h]
000000018037A000  89 83 70 C4 00 00           mov     [rbx+0C470h], eax
000000018037A006  8B 83 50 C4 00 00           mov     eax, [rbx+0C450h]
000000018037A00C  89 83 60 C4 00 00           mov     [rbx+0C460h], eax
000000018037A012  8B 83 90 C5 00 00           mov     eax, [rbx+0C590h]
000000018037A018  89 83 A0 C5 00 00           mov     [rbx+0C5A0h], eax
000000018037A01E  8B 83 80 C5 00 00           mov     eax, [rbx+0C580h]
000000018037A024  89 83 90 C5 00 00           mov     [rbx+0C590h], eax
000000018037A02A  8B 83 70 C5 00 00           mov     eax, [rbx+0C570h]
000000018037A030  89 83 80 C5 00 00           mov     [rbx+0C580h], eax
000000018037A036  8B 83 60 C5 00 00           mov     eax, [rbx+0C560h]
000000018037A03C  89 83 70 C5 00 00           mov     [rbx+0C570h], eax
000000018037A042  8B 83 50 C5 00 00           mov     eax, [rbx+0C550h]
000000018037A048  89 83 60 C5 00 00           mov     [rbx+0C560h], eax
000000018037A04E  8B 83 40 C5 00 00           mov     eax, [rbx+0C540h]
000000018037A054  89 83 50 C5 00 00           mov     [rbx+0C550h], eax
000000018037A05A  8B 83 30 C5 00 00           mov     eax, [rbx+0C530h]
000000018037A060  89 83 40 C5 00 00           mov     [rbx+0C540h], eax
000000018037A066  8B 83 10 C6 00 00           mov     eax, [rbx+0C610h]
000000018037A06C  89 83 20 C6 00 00           mov     [rbx+0C620h], eax
000000018037A072  8B 83 00 C6 00 00           mov     eax, [rbx+0C600h]
000000018037A078  89 83 10 C6 00 00           mov     [rbx+0C610h], eax
000000018037A07E  8B 83 F0 C5 00 00           mov     eax, [rbx+0C5F0h]
000000018037A084  89 83 00 C6 00 00           mov     [rbx+0C600h], eax
000000018037A08A  8B 83 E0 C5 00 00           mov     eax, [rbx+0C5E0h]
000000018037A090  89 83 F0 C5 00 00           mov     [rbx+0C5F0h], eax
000000018037A096  8B 83 D0 C5 00 00           mov     eax, [rbx+0C5D0h]
000000018037A09C  89 83 E0 C5 00 00           mov     [rbx+0C5E0h], eax
000000018037A0A2  8B 83 C0 C5 00 00           mov     eax, [rbx+0C5C0h]
000000018037A0A8  89 83 D0 C5 00 00           mov     [rbx+0C5D0h], eax
000000018037A0AE  8B 83 B0 C5 00 00           mov     eax, [rbx+0C5B0h]
000000018037A0B4  89 83 C0 C5 00 00           mov     [rbx+0C5C0h], eax
000000018037A0BA  8B 83 90 C6 00 00           mov     eax, [rbx+0C690h]
000000018037A0C0  89 83 A0 C6 00 00           mov     [rbx+0C6A0h], eax
000000018037A0C6  8B 83 80 C6 00 00           mov     eax, [rbx+0C680h]
000000018037A0CC  89 83 90 C6 00 00           mov     [rbx+0C690h], eax
000000018037A0D2  8B 83 70 C6 00 00           mov     eax, [rbx+0C670h]
000000018037A0D8  89 83 80 C6 00 00           mov     [rbx+0C680h], eax
000000018037A0DE  8B 83 60 C6 00 00           mov     eax, [rbx+0C660h]
000000018037A0E4  89 83 70 C6 00 00           mov     [rbx+0C670h], eax
000000018037A0EA  8B 83 50 C6 00 00           mov     eax, [rbx+0C650h]
000000018037A0F0  89 83 60 C6 00 00           mov     [rbx+0C660h], eax
000000018037A0F6  8B 83 40 C6 00 00           mov     eax, [rbx+0C640h]
000000018037A0FC  89 83 50 C6 00 00           mov     [rbx+0C650h], eax
000000018037A102  8B 83 30 C6 00 00           mov     eax, [rbx+0C630h]
000000018037A108  89 83 40 C6 00 00           mov     [rbx+0C640h], eax
000000018037A10E  8B 83 10 C7 00 00           mov     eax, [rbx+0C710h]
000000018037A114  89 83 20 C7 00 00           mov     [rbx+0C720h], eax
000000018037A11A  8B 83 00 C7 00 00           mov     eax, [rbx+0C700h]
000000018037A120  89 83 10 C7 00 00           mov     [rbx+0C710h], eax
000000018037A126  8B 83 F0 C6 00 00           mov     eax, [rbx+0C6F0h]
000000018037A12C  89 83 00 C7 00 00           mov     [rbx+0C700h], eax
000000018037A132  8B 83 E0 C6 00 00           mov     eax, [rbx+0C6E0h]
000000018037A138  89 83 F0 C6 00 00           mov     [rbx+0C6F0h], eax
000000018037A13E  8B 83 D0 C6 00 00           mov     eax, [rbx+0C6D0h]
000000018037A144  89 83 E0 C6 00 00           mov     [rbx+0C6E0h], eax
000000018037A14A  8B 83 C0 C6 00 00           mov     eax, [rbx+0C6C0h]
000000018037A150  89 83 D0 C6 00 00           mov     [rbx+0C6D0h], eax
000000018037A156  8B 83 B0 C6 00 00           mov     eax, [rbx+0C6B0h]
000000018037A15C  89 83 C0 C6 00 00           mov     [rbx+0C6C0h], eax
000000018037A162  8B 83 30 C7 00 00           mov     eax, [rbx+0C730h]
000000018037A168  89 83 40 C7 00 00           mov     [rbx+0C740h], eax
000000018037A16E  F3 0F 10 83 50 C7 00 00     movss   xmm0, dword ptr [rbx+0C750h]
000000018037A176  F3 0F 11 83 60 C7 00 00     movss   dword ptr [rbx+0C760h], xmm0
000000018037A17E  44 0F 2E AB A0 C7 00 00     ucomiss xmm13, dword ptr [rbx+0C7A0h]
000000018037A186  0F 85 49 09 00 00           jnz     loc_18037AAD5
000000018037A18C  F3 0F 59 8B F0 C7 00 00     mulss   xmm1, dword ptr [rbx+0C7F0h]
000000018037A194  41 0F 57 C3                 xorps   xmm0, xmm11
000000018037A198  41 0F 28 F1                 movaps  xmm6, xmm9
000000018037A19C  41 0F 28 F8                 movaps  xmm7, xmm8
000000018037A1A0  F3 0F 59 B3 10 C8 00 00     mulss   xmm6, dword ptr [rbx+0C810h]
000000018037A1A8  F3 41 0F 59 F8              mulss   xmm7, xmm8
000000018037A1AD  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037A1B2  F3 0F 59 F1                 mulss   xmm6, xmm1
000000018037A1B6  0F 28 C8                    movaps  xmm1, xmm0
000000018037A1B9  F3 0F 59 8B E0 C7 00 00     mulss   xmm1, dword ptr [rbx+0C7E0h]
000000018037A1C1  F3 0F 58 F1                 addss   xmm6, xmm1
000000018037A1C5  E8 96 EB FE FF              call    sub_180368D60
000000018037A1CA  F3 0F 11 83 50 C7 00 00     movss   dword ptr [rbx+0C750h], xmm0
000000018037A1D2  41 0F 28 DD                 movaps  xmm3, xmm13
000000018037A1D6  F3 0F 11 B3 30 C7 00 00     movss   dword ptr [rbx+0C730h], xmm6
000000018037A1DE  41 0F 28 C0                 movaps  xmm0, xmm8
000000018037A1E2  F3 0F 59 FF                 mulss   xmm7, xmm7
000000018037A1E6  F3 41 0F 58 C0              addss   xmm0, xmm8
000000018037A1EB  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037A1EF  F3 41 0F 59 F9              mulss   xmm7, xmm9
000000018037A1F4  F3 0F 5C F0                 subss   xmm6, xmm0
000000018037A1F8  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037A1FD  F3 0F 5E DF                 divss   xmm3, xmm7
000000018037A201  F3 0F 11 9B 80 C7 00 00     movss   dword ptr [rbx+0C780h], xmm3
000000018037A209  0F 28 E3                    movaps  xmm4, xmm3
000000018037A20C  F3 0F 10 8B 30 C7 00 00     movss   xmm1, dword ptr [rbx+0C730h]
000000018037A214  F3 0F 10 AB 40 C7 00 00     movss   xmm5, dword ptr [rbx+0C740h]
000000018037A21C  F3 41 0F 59 E1              mulss   xmm4, xmm9
000000018037A221  F3 0F 11 A3 70 C7 00 00     movss   dword ptr [rbx+0C770h], xmm4
000000018037A229  F3 0F 59 AB 40 C8 00 00     mulss   xmm5, dword ptr [rbx+0C840h]
000000018037A231  F3 0F 10 93 B0 C4 00 00     movss   xmm2, dword ptr [rbx+0C4B0h]
000000018037A239  F3 0F 59 8B 50 C8 00 00     mulss   xmm1, dword ptr [rbx+0C850h]
000000018037A241  F3 0F 10 83 C0 C4 00 00     movss   xmm0, dword ptr [rbx+0C4C0h]
000000018037A249  F3 0F 11 93 20 C5 00 00     movss   dword ptr [rbx+0C520h], xmm2
000000018037A251  F3 0F 59 93 70 C9 00 00     mulss   xmm2, dword ptr [rbx+0C970h]
000000018037A259  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037A25D  F3 0F 59 83 80 C9 00 00     mulss   xmm0, dword ptr [rbx+0C980h]
000000018037A265  F3 0F 59 EB                 mulss   xmm5, xmm3
000000018037A269  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037A26D  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037A271  F3 0F 5C EA                 subss   xmm5, xmm2
000000018037A275  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037A279  73 06                       jnb     short loc_18037A281
000000018037A27B  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037A27F  EB 05                       jmp     short loc_18037A286
000000018037A281  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037A286  0F 28 CD                    movaps  xmm1, xmm5
000000018037A289  0F 28 C5                    movaps  xmm0, xmm5
000000018037A28C  F3 0F 59 83 20 C8 00 00     mulss   xmm0, dword ptr [rbx+0C820h]
000000018037A294  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037A298  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A29C  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A2A0  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A2A4  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037A2A8  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037A2AC  F3 0F 11 AB D0 C4 00 00     movss   dword ptr [rbx+0C4D0h], xmm5
000000018037A2B4  0F 28 D5                    movaps  xmm2, xmm5
000000018037A2B7  F3 0F 58 AB 60 C4 00 00     addss   xmm5, dword ptr [rbx+0C460h]
000000018037A2BF  F3 0F 10 9B 70 C4 00 00     movss   xmm3, dword ptr [rbx+0C470h]
000000018037A2C7  0F 28 C3                    movaps  xmm0, xmm3
000000018037A2CA  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A2CE  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037A2D2  41 0F 28 E8                 movaps  xmm5, xmm8
000000018037A2D6  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018037A2DA  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037A2DE  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A2E2  0F 28 C6                    movaps  xmm0, xmm6
000000018037A2E5  F3 0F 11 A3 E0 C4 00 00     movss   dword ptr [rbx+0C4E0h], xmm4
000000018037A2ED  F3 0F 10 8B 80 C4 00 00     movss   xmm1, dword ptr [rbx+0C480h]
000000018037A2F5  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037A2F9  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037A2FD  0F 28 C1                    movaps  xmm0, xmm1
000000018037A300  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A304  F3 0F 58 EC                 addss   xmm5, xmm4
000000018037A308  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037A30C  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037A310  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037A314  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037A318  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037A31C  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037A320  0F 28 C6                    movaps  xmm0, xmm6
000000018037A323  F3 0F 11 9B F0 C4 00 00     movss   dword ptr [rbx+0C4F0h], xmm3
000000018037A32B  F3 0F 10 AB 90 C4 00 00     movss   xmm5, dword ptr [rbx+0C490h]
000000018037A333  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037A337  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A33B  0F 28 C5                    movaps  xmm0, xmm5
000000018037A33E  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A342  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037A346  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037A34A  41 0F 28 C8                 movaps  xmm1, xmm8
000000018037A34E  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037A352  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037A356  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037A35A  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037A35E  0F 28 C6                    movaps  xmm0, xmm6
000000018037A361  F3 0F 11 93 00 C5 00 00     movss   dword ptr [rbx+0C500h], xmm2
000000018037A369  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037A36D  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037A371  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037A375  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018037A37A  0F 28 C6                    movaps  xmm0, xmm6
000000018037A37D  F3 0F 59 83 A0 C4 00 00     mulss   xmm0, dword ptr [rbx+0C4A0h]
000000018037A385  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037A389  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037A38D  0F 28 C6                    movaps  xmm0, xmm6
000000018037A390  F3 0F 59 E1                 mulss   xmm4, xmm1
000000018037A394  F3 0F 11 AB 10 C5 00 00     movss   dword ptr [rbx+0C510h], xmm5
000000018037A39C  F3 0F 10 93 00 C5 00 00     movss   xmm2, dword ptr [rbx+0C500h]
000000018037A3A4  F3 0F 59 93 C0 C7 00 00     mulss   xmm2, dword ptr [rbx+0C7C0h]
000000018037A3AC  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037A3B0  F3 0F 59 AB D0 C7 00 00     mulss   xmm5, dword ptr [rbx+0C7D0h]
000000018037A3B8  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A3BC  F3 0F 10 83 B0 C7 00 00     movss   xmm0, dword ptr [rbx+0C7B0h]
000000018037A3C4  F3 0F 59 83 F0 C4 00 00     mulss   xmm0, dword ptr [rbx+0C4F0h]
000000018037A3CC  F3 0F 58 D5                 addss   xmm2, xmm5
000000018037A3D0  F3 0F 10 AB 40 C7 00 00     movss   xmm5, dword ptr [rbx+0C740h]
000000018037A3D8  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037A3DC  F3 0F 11 93 B0 C6 00 00     movss   dword ptr [rbx+0C6B0h], xmm2
000000018037A3E4  F3 0F 58 AB 30 C7 00 00     addss   xmm5, dword ptr [rbx+0C730h]
000000018037A3EC  F3 0F 10 83 20 C5 00 00     movss   xmm0, dword ptr [rbx+0C520h]
000000018037A3F4  F3 0F 59 AB 60 C8 00 00     mulss   xmm5, dword ptr [rbx+0C860h]
000000018037A3FC  F3 0F 59 AB 80 C7 00 00     mulss   xmm5, dword ptr [rbx+0C780h]
000000018037A404  F3 0F 11 A3 20 C5 00 00     movss   dword ptr [rbx+0C520h], xmm4
000000018037A40C  F3 0F 59 A3 70 C9 00 00     mulss   xmm4, dword ptr [rbx+0C970h]
000000018037A414  F3 0F 59 83 80 C9 00 00     mulss   xmm0, dword ptr [rbx+0C980h]
000000018037A41C  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A420  F3 0F 59 A3 70 C7 00 00     mulss   xmm4, dword ptr [rbx+0C770h]
000000018037A428  F3 0F 5C EC                 subss   xmm5, xmm4
000000018037A42C  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037A430  73 06                       jnb     short loc_18037A438
000000018037A432  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037A436  EB 05                       jmp     short loc_18037A43D
000000018037A438  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037A43D  0F 28 CD                    movaps  xmm1, xmm5
000000018037A440  0F 28 C5                    movaps  xmm0, xmm5
000000018037A443  F3 0F 59 83 20 C8 00 00     mulss   xmm0, dword ptr [rbx+0C820h]
000000018037A44B  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037A44F  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A453  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A457  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A45B  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037A45F  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037A463  F3 0F 10 8B D0 C4 00 00     movss   xmm1, dword ptr [rbx+0C4D0h]
000000018037A46B  F3 0F 11 AB D0 C4 00 00     movss   dword ptr [rbx+0C4D0h], xmm5
000000018037A473  0F 28 D5                    movaps  xmm2, xmm5
000000018037A476  F3 0F 10 9B E0 C4 00 00     movss   xmm3, dword ptr [rbx+0C4E0h]
000000018037A47E  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037A482  0F 28 C3                    movaps  xmm0, xmm3
000000018037A485  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A489  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037A48D  41 0F 28 E8                 movaps  xmm5, xmm8
000000018037A491  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018037A495  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037A499  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A49D  0F 28 C6                    movaps  xmm0, xmm6
000000018037A4A0  F3 0F 11 A3 E0 C4 00 00     movss   dword ptr [rbx+0C4E0h], xmm4
000000018037A4A8  F3 0F 10 8B F0 C4 00 00     movss   xmm1, dword ptr [rbx+0C4F0h]
000000018037A4B0  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037A4B4  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037A4B8  0F 28 C1                    movaps  xmm0, xmm1
000000018037A4BB  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A4BF  F3 0F 58 EC                 addss   xmm5, xmm4
000000018037A4C3  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037A4C7  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037A4CB  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037A4CF  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037A4D3  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037A4D7  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037A4DB  0F 28 C6                    movaps  xmm0, xmm6
000000018037A4DE  F3 0F 11 9B F0 C4 00 00     movss   dword ptr [rbx+0C4F0h], xmm3
000000018037A4E6  F3 0F 10 AB 00 C5 00 00     movss   xmm5, dword ptr [rbx+0C500h]
000000018037A4EE  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037A4F2  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A4F6  0F 28 C5                    movaps  xmm0, xmm5
000000018037A4F9  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A4FD  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037A501  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037A505  41 0F 28 C8                 movaps  xmm1, xmm8
000000018037A509  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037A50D  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037A511  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037A515  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037A519  0F 28 C6                    movaps  xmm0, xmm6
000000018037A51C  F3 0F 11 93 00 C5 00 00     movss   dword ptr [rbx+0C500h], xmm2
000000018037A524  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037A528  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037A52C  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037A530  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018037A535  0F 28 C6                    movaps  xmm0, xmm6
000000018037A538  F3 0F 59 83 10 C5 00 00     mulss   xmm0, dword ptr [rbx+0C510h]
000000018037A540  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037A544  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037A548  0F 28 C6                    movaps  xmm0, xmm6
000000018037A54B  F3 0F 59 E1                 mulss   xmm4, xmm1
000000018037A54F  F3 0F 11 AB 10 C5 00 00     movss   dword ptr [rbx+0C510h], xmm5
000000018037A557  F3 0F 10 93 00 C5 00 00     movss   xmm2, dword ptr [rbx+0C500h]
000000018037A55F  F3 0F 59 93 C0 C7 00 00     mulss   xmm2, dword ptr [rbx+0C7C0h]
000000018037A567  F3 0F 10 8B 30 C7 00 00     movss   xmm1, dword ptr [rbx+0C730h]
000000018037A56F  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037A573  F3 0F 59 AB D0 C7 00 00     mulss   xmm5, dword ptr [rbx+0C7D0h]
000000018037A57B  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A57F  F3 0F 10 83 B0 C7 00 00     movss   xmm0, dword ptr [rbx+0C7B0h]
000000018037A587  F3 0F 59 83 F0 C4 00 00     mulss   xmm0, dword ptr [rbx+0C4F0h]
000000018037A58F  F3 0F 58 D5                 addss   xmm2, xmm5
000000018037A593  F3 0F 10 AB 40 C7 00 00     movss   xmm5, dword ptr [rbx+0C740h]
000000018037A59B  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037A59F  F3 0F 11 93 30 C6 00 00     movss   dword ptr [rbx+0C630h], xmm2
000000018037A5A7  F3 0F 59 AB 50 C8 00 00     mulss   xmm5, dword ptr [rbx+0C850h]
000000018037A5AF  F3 0F 59 8B 40 C8 00 00     mulss   xmm1, dword ptr [rbx+0C840h]
000000018037A5B7  F3 0F 10 83 20 C5 00 00     movss   xmm0, dword ptr [rbx+0C520h]
000000018037A5BF  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037A5C3  F3 0F 59 AB 80 C7 00 00     mulss   xmm5, dword ptr [rbx+0C780h]
000000018037A5CB  F3 0F 11 A3 20 C5 00 00     movss   dword ptr [rbx+0C520h], xmm4
000000018037A5D3  F3 0F 59 A3 70 C9 00 00     mulss   xmm4, dword ptr [rbx+0C970h]
000000018037A5DB  F3 0F 59 83 80 C9 00 00     mulss   xmm0, dword ptr [rbx+0C980h]
000000018037A5E3  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A5E7  F3 0F 59 A3 70 C7 00 00     mulss   xmm4, dword ptr [rbx+0C770h]
000000018037A5EF  F3 0F 5C EC                 subss   xmm5, xmm4
000000018037A5F3  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037A5F7  73 06                       jnb     short loc_18037A5FF
000000018037A5F9  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037A5FD  EB 05                       jmp     short loc_18037A604
000000018037A5FF  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037A604  0F 28 CD                    movaps  xmm1, xmm5
000000018037A607  0F 28 C5                    movaps  xmm0, xmm5
000000018037A60A  F3 0F 59 83 20 C8 00 00     mulss   xmm0, dword ptr [rbx+0C820h]
000000018037A612  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037A616  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A61A  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A61E  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A622  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037A626  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037A62A  F3 0F 10 8B D0 C4 00 00     movss   xmm1, dword ptr [rbx+0C4D0h]
000000018037A632  F3 0F 11 AB D0 C4 00 00     movss   dword ptr [rbx+0C4D0h], xmm5
000000018037A63A  0F 28 D5                    movaps  xmm2, xmm5
000000018037A63D  F3 0F 10 9B E0 C4 00 00     movss   xmm3, dword ptr [rbx+0C4E0h]
000000018037A645  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037A649  0F 28 C3                    movaps  xmm0, xmm3
000000018037A64C  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A650  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037A654  41 0F 28 E8                 movaps  xmm5, xmm8
000000018037A658  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018037A65C  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037A660  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A664  0F 28 C6                    movaps  xmm0, xmm6
000000018037A667  F3 0F 11 A3 E0 C4 00 00     movss   dword ptr [rbx+0C4E0h], xmm4
000000018037A66F  F3 0F 10 8B F0 C4 00 00     movss   xmm1, dword ptr [rbx+0C4F0h]
000000018037A677  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037A67B  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037A67F  0F 28 C1                    movaps  xmm0, xmm1
000000018037A682  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A686  F3 0F 58 EC                 addss   xmm5, xmm4
000000018037A68A  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037A68E  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037A692  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037A696  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037A69A  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037A69E  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037A6A2  0F 28 C6                    movaps  xmm0, xmm6
000000018037A6A5  F3 0F 11 9B F0 C4 00 00     movss   dword ptr [rbx+0C4F0h], xmm3
000000018037A6AD  F3 0F 10 AB 00 C5 00 00     movss   xmm5, dword ptr [rbx+0C500h]
000000018037A6B5  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037A6B9  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A6BD  0F 28 C5                    movaps  xmm0, xmm5
000000018037A6C0  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A6C4  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037A6C8  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037A6CC  41 0F 28 C8                 movaps  xmm1, xmm8
000000018037A6D0  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037A6D4  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037A6D8  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037A6DC  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037A6E0  0F 28 C6                    movaps  xmm0, xmm6
000000018037A6E3  F3 0F 11 93 00 C5 00 00     movss   dword ptr [rbx+0C500h], xmm2
000000018037A6EB  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037A6EF  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037A6F3  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037A6F7  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018037A6FC  0F 28 C6                    movaps  xmm0, xmm6
000000018037A6FF  F3 0F 59 83 10 C5 00 00     mulss   xmm0, dword ptr [rbx+0C510h]
000000018037A707  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037A70B  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037A70F  0F 28 C6                    movaps  xmm0, xmm6
000000018037A712  F3 0F 59 D9                 mulss   xmm3, xmm1
000000018037A716  F3 0F 11 AB 10 C5 00 00     movss   dword ptr [rbx+0C510h], xmm5
000000018037A71E  F3 0F 10 8B 00 C5 00 00     movss   xmm1, dword ptr [rbx+0C500h]
000000018037A726  F3 0F 59 8B C0 C7 00 00     mulss   xmm1, dword ptr [rbx+0C7C0h]
000000018037A72E  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037A732  F3 0F 59 AB D0 C7 00 00     mulss   xmm5, dword ptr [rbx+0C7D0h]
000000018037A73A  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037A73E  F3 0F 10 83 B0 C7 00 00     movss   xmm0, dword ptr [rbx+0C7B0h]
000000018037A746  F3 0F 59 83 F0 C4 00 00     mulss   xmm0, dword ptr [rbx+0C4F0h]
000000018037A74E  F3 0F 58 CD                 addss   xmm1, xmm5
000000018037A752  F3 0F 10 AB 30 C7 00 00     movss   xmm5, dword ptr [rbx+0C730h]
000000018037A75A  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037A75E  F3 0F 11 8B B0 C5 00 00     movss   dword ptr [rbx+0C5B0h], xmm1
000000018037A766  F3 0F 59 AB 30 C8 00 00     mulss   xmm5, dword ptr [rbx+0C830h]
000000018037A76E  F3 0F 10 83 20 C5 00 00     movss   xmm0, dword ptr [rbx+0C520h]
000000018037A776  F3 0F 59 AB 80 C7 00 00     mulss   xmm5, dword ptr [rbx+0C780h]
000000018037A77E  F3 0F 11 9B B0 C4 00 00     movss   dword ptr [rbx+0C4B0h], xmm3
000000018037A786  F3 0F 59 9B 70 C9 00 00     mulss   xmm3, dword ptr [rbx+0C970h]
000000018037A78E  F3 0F 59 83 80 C9 00 00     mulss   xmm0, dword ptr [rbx+0C980h]
000000018037A796  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037A79A  F3 0F 59 9B 70 C7 00 00     mulss   xmm3, dword ptr [rbx+0C770h]
000000018037A7A2  F3 0F 5C EB                 subss   xmm5, xmm3
000000018037A7A6  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037A7AA  73 06                       jnb     short loc_18037A7B2
000000018037A7AC  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037A7B0  EB 05                       jmp     short loc_18037A7B7
000000018037A7B2  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037A7B7  0F 28 CD                    movaps  xmm1, xmm5
000000018037A7BA  0F 28 C5                    movaps  xmm0, xmm5
000000018037A7BD  F3 0F 59 83 20 C8 00 00     mulss   xmm0, dword ptr [rbx+0C820h]
000000018037A7C5  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037A7C9  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A7CD  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A7D1  F3 0F 59 CD                 mulss   xmm1, xmm5
000000018037A7D5  F3 0F 59 C8                 mulss   xmm1, xmm0
000000018037A7D9  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037A7DD  F3 0F 11 AB 50 C4 00 00     movss   dword ptr [rbx+0C450h], xmm5
000000018037A7E5  0F 28 D5                    movaps  xmm2, xmm5
000000018037A7E8  F3 0F 58 AB D0 C4 00 00     addss   xmm5, dword ptr [rbx+0C4D0h]
000000018037A7F0  F3 0F 10 9B E0 C4 00 00     movss   xmm3, dword ptr [rbx+0C4E0h]
000000018037A7F8  0F 28 C3                    movaps  xmm0, xmm3
000000018037A7FB  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A7FF  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037A803  41 0F 28 E8                 movaps  xmm5, xmm8
000000018037A807  F3 0F 59 EA                 mulss   xmm5, xmm2
000000018037A80B  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037A80F  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A813  0F 28 C6                    movaps  xmm0, xmm6
000000018037A816  F3 0F 11 A3 60 C4 00 00     movss   dword ptr [rbx+0C460h], xmm4
000000018037A81E  F3 0F 10 8B F0 C4 00 00     movss   xmm1, dword ptr [rbx+0C4F0h]
000000018037A826  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037A82A  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037A82E  0F 28 C1                    movaps  xmm0, xmm1
000000018037A831  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A835  F3 0F 58 EC                 addss   xmm5, xmm4
000000018037A839  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037A83D  41 0F 28 D8                 movaps  xmm3, xmm8
000000018037A841  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037A845  41 0F 28 E0                 movaps  xmm4, xmm8
000000018037A849  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037A84D  F3 0F 58 D8                 addss   xmm3, xmm0
000000018037A851  0F 28 C6                    movaps  xmm0, xmm6
000000018037A854  F3 0F 11 9B 70 C4 00 00     movss   dword ptr [rbx+0C470h], xmm3
000000018037A85C  F3 0F 10 AB 00 C5 00 00     movss   xmm5, dword ptr [rbx+0C500h]
000000018037A864  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037A868  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A86C  0F 28 C5                    movaps  xmm0, xmm5
000000018037A86F  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037A873  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037A877  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037A87B  41 0F 28 C8                 movaps  xmm1, xmm8
000000018037A87F  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037A883  F3 0F 59 D3                 mulss   xmm2, xmm3
000000018037A887  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037A88B  0F 28 C6                    movaps  xmm0, xmm6
000000018037A88E  F3 0F 11 93 80 C4 00 00     movss   dword ptr [rbx+0C480h], xmm2
000000018037A896  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037A89A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037A89E  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037A8A2  F3 41 0F 59 E8              mulss   xmm5, xmm8
000000018037A8A7  0F 28 C6                    movaps  xmm0, xmm6
000000018037A8AA  F3 0F 59 83 10 C5 00 00     mulss   xmm0, dword ptr [rbx+0C510h]
000000018037A8B2  F3 0F 58 CA                 addss   xmm1, xmm2
000000018037A8B6  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037A8BA  F3 44 0F 59 C1              mulss   xmm8, xmm1
000000018037A8BF  F3 0F 11 AB 90 C4 00 00     movss   dword ptr [rbx+0C490h], xmm5
000000018037A8C7  F3 0F 10 9B 70 C4 00 00     movss   xmm3, dword ptr [rbx+0C470h]
000000018037A8CF  F3 0F 59 F5                 mulss   xmm6, xmm5
000000018037A8D3  F3 44 0F 58 C6              addss   xmm8, xmm6
000000018037A8D8  F3 44 0F 11 83 A0 C4 00 00  movss   dword ptr [rbx+0C4A0h], xmm8
000000018037A8E1  F3 0F 10 83 C0 C7 00 00     movss   xmm0, dword ptr [rbx+0C7C0h]
000000018037A8E9  F3 0F 59 83 80 C4 00 00     mulss   xmm0, dword ptr [rbx+0C480h]
000000018037A8F1  F3 0F 59 AB D0 C7 00 00     mulss   xmm5, dword ptr [rbx+0C7D0h]
000000018037A8F9  F3 0F 59 9B B0 C7 00 00     mulss   xmm3, dword ptr [rbx+0C7B0h]
000000018037A901  F3 0F 10 A3 70 C5 00 00     movss   xmm4, dword ptr [rbx+0C570h]
000000018037A909  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037A90D  F3 0F 58 EB                 addss   xmm5, xmm3
000000018037A911  F3 0F 11 AB 30 C5 00 00     movss   dword ptr [rbx+0C530h], xmm5
000000018037A919  F3 0F 58 A3 E0 C6 00 00     addss   xmm4, dword ptr [rbx+0C6E0h]
000000018037A921  F3 0F 10 83 F0 C5 00 00     movss   xmm0, dword ptr [rbx+0C5F0h]
000000018037A929  F3 0F 58 83 60 C6 00 00     addss   xmm0, dword ptr [rbx+0C660h]
000000018037A931  F3 0F 10 8B 70 C6 00 00     movss   xmm1, dword ptr [rbx+0C670h]
000000018037A939  F3 0F 58 8B E0 C5 00 00     addss   xmm1, dword ptr [rbx+0C5E0h]
000000018037A941  F3 0F 59 A3 60 C9 00 00     mulss   xmm4, dword ptr [rbx+0C960h]
000000018037A949  F3 0F 59 83 50 C9 00 00     mulss   xmm0, dword ptr [rbx+0C950h]
000000018037A951  F3 0F 59 8B 40 C9 00 00     mulss   xmm1, dword ptr [rbx+0C940h]
000000018037A959  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A95D  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037A961  F3 0F 10 83 60 C5 00 00     movss   xmm0, dword ptr [rbx+0C560h]
000000018037A969  F3 0F 58 83 F0 C6 00 00     addss   xmm0, dword ptr [rbx+0C6F0h]
000000018037A971  F3 0F 10 8B D0 C6 00 00     movss   xmm1, dword ptr [rbx+0C6D0h]
000000018037A979  F3 0F 58 8B 80 C5 00 00     addss   xmm1, dword ptr [rbx+0C580h]
000000018037A981  F3 0F 58 AB 20 C7 00 00     addss   xmm5, dword ptr [rbx+0C720h]
000000018037A989  F3 0F 59 83 30 C9 00 00     mulss   xmm0, dword ptr [rbx+0C930h]
000000018037A991  F3 0F 59 8B 20 C9 00 00     mulss   xmm1, dword ptr [rbx+0C920h]
000000018037A999  F3 0F 59 AB 70 C8 00 00     mulss   xmm5, dword ptr [rbx+0C870h]
000000018037A9A1  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A9A5  F3 0F 10 83 50 C6 00 00     movss   xmm0, dword ptr [rbx+0C650h]
000000018037A9AD  F3 0F 58 83 00 C6 00 00     addss   xmm0, dword ptr [rbx+0C600h]
000000018037A9B5  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037A9B9  F3 0F 10 8B 80 C6 00 00     movss   xmm1, dword ptr [rbx+0C680h]
000000018037A9C1  F3 0F 58 8B D0 C5 00 00     addss   xmm1, dword ptr [rbx+0C5D0h]
000000018037A9C9  F3 0F 59 83 10 C9 00 00     mulss   xmm0, dword ptr [rbx+0C910h]
000000018037A9D1  F3 0F 59 8B 00 C9 00 00     mulss   xmm1, dword ptr [rbx+0C900h]
000000018037A9D9  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037A9DD  F3 0F 10 83 00 C7 00 00     movss   xmm0, dword ptr [rbx+0C700h]
000000018037A9E5  F3 0F 58 83 50 C5 00 00     addss   xmm0, dword ptr [rbx+0C550h]
000000018037A9ED  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037A9F1  F3 0F 10 8B C0 C6 00 00     movss   xmm1, dword ptr [rbx+0C6C0h]
000000018037A9F9  F3 0F 59 83 F0 C8 00 00     mulss   xmm0, dword ptr [rbx+0C8F0h]
000000018037AA01  F3 0F 58 8B 90 C5 00 00     addss   xmm1, dword ptr [rbx+0C590h]
000000018037AA09  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037AA0D  F3 0F 10 83 40 C6 00 00     movss   xmm0, dword ptr [rbx+0C640h]
000000018037AA15  F3 0F 58 83 10 C6 00 00     addss   xmm0, dword ptr [rbx+0C610h]
000000018037AA1D  F3 0F 59 8B E0 C8 00 00     mulss   xmm1, dword ptr [rbx+0C8E0h]
000000018037AA25  F3 0F 59 83 D0 C8 00 00     mulss   xmm0, dword ptr [rbx+0C8D0h]
000000018037AA2D  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037AA31  F3 0F 10 8B 90 C6 00 00     movss   xmm1, dword ptr [rbx+0C690h]
000000018037AA39  F3 0F 58 8B C0 C5 00 00     addss   xmm1, dword ptr [rbx+0C5C0h]
000000018037AA41  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037AA45  F3 0F 10 83 10 C7 00 00     movss   xmm0, dword ptr [rbx+0C710h]
000000018037AA4D  F3 0F 59 8B C0 C8 00 00     mulss   xmm1, dword ptr [rbx+0C8C0h]
000000018037AA55  F3 0F 58 83 40 C5 00 00     addss   xmm0, dword ptr [rbx+0C540h]
000000018037AA5D  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037AA61  F3 0F 10 8B B0 C6 00 00     movss   xmm1, dword ptr [rbx+0C6B0h]
000000018037AA69  F3 0F 58 8B A0 C5 00 00     addss   xmm1, dword ptr [rbx+0C5A0h]
000000018037AA71  F3 0F 59 83 B0 C8 00 00     mulss   xmm0, dword ptr [rbx+0C8B0h]
000000018037AA79  F3 0F 59 8B A0 C8 00 00     mulss   xmm1, dword ptr [rbx+0C8A0h]
000000018037AA81  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037AA85  F3 0F 10 83 30 C6 00 00     movss   xmm0, dword ptr [rbx+0C630h]
000000018037AA8D  F3 0F 58 83 20 C6 00 00     addss   xmm0, dword ptr [rbx+0C620h]
000000018037AA95  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037AA99  F3 0F 10 8B A0 C6 00 00     movss   xmm1, dword ptr [rbx+0C6A0h]
000000018037AAA1  F3 0F 59 83 90 C8 00 00     mulss   xmm0, dword ptr [rbx+0C890h]
000000018037AAA9  F3 0F 58 8B B0 C5 00 00     addss   xmm1, dword ptr [rbx+0C5B0h]
000000018037AAB1  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037AAB5  F3 0F 59 8B 80 C8 00 00     mulss   xmm1, dword ptr [rbx+0C880h]
000000018037AABD  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037AAC1  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037AAC5  F3 0F 59 A3 00 C8 00 00     mulss   xmm4, dword ptr [rbx+0C800h]
000000018037AACD  F3 0F 11 A3 90 C7 00 00     movss   dword ptr [rbx+0C790h], xmm4
000000018037AAD5  8B 83 90 C9 00 00           mov     eax, [rbx+0C990h]
000000018037AADB  89 83 A0 C9 00 00           mov     [rbx+0C9A0h], eax
000000018037AAE1  F3 0F 10 83 C0 C9 00 00     movss   xmm0, dword ptr [rbx+0C9C0h]
000000018037AAE9  8B 83 B0 C9 00 00           mov     eax, [rbx+0C9B0h]
000000018037AAEF  89 83 E0 C9 00 00           mov     [rbx+0C9E0h], eax
000000018037AAF5  F3 0F 11 83 F0 C9 00 00     movss   dword ptr [rbx+0C9F0h], xmm0
000000018037AAFD  8B 83 D0 C9 00 00           mov     eax, [rbx+0C9D0h]
000000018037AB03  89 83 00 CA 00 00           mov     [rbx+0CA00h], eax
000000018037AB09  F3 0F 10 93 10 CA 00 00     movss   xmm2, dword ptr [rbx+0CA10h]
000000018037AB11  F3 0F 11 93 20 CA 00 00     movss   dword ptr [rbx+0CA20h], xmm2
000000018037AB19  F3 0F 10 83 30 CA 00 00     movss   xmm0, dword ptr [rbx+0CA30h]
000000018037AB21  F3 0F 11 83 40 CA 00 00     movss   dword ptr [rbx+0CA40h], xmm0
000000018037AB29  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037AB2D  F3 0F 59 93 50 CA 00 00     mulss   xmm2, dword ptr [rbx+0CA50h]
000000018037AB35  F3 0F 58 D0                 addss   xmm2, xmm0
000000018037AB39  F3 0F 11 93 30 CA 00 00     movss   dword ptr [rbx+0CA30h], xmm2
000000018037AB41  F3 0F 10 83 F0 C9 00 00     movss   xmm0, dword ptr [rbx+0C9F0h]
000000018037AB49  F3 0F 10 8B 00 CA 00 00     movss   xmm1, dword ptr [rbx+0CA00h]
000000018037AB51  F3 0F 59 D0                 mulss   xmm2, xmm0
000000018037AB55  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037AB59  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037AB5D  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037AB61  F3 0F 11 93 60 CA 00 00     movss   dword ptr [rbx+0CA60h], xmm2
000000018037AB69  F3 0F 10 8B 70 CA 00 00     movss   xmm1, dword ptr [rbx+0CA70h]
000000018037AB71  F3 0F 11 8B 80 CA 00 00     movss   dword ptr [rbx+0CA80h], xmm1
000000018037AB79  F3 0F 10 83 90 CA 00 00     movss   xmm0, dword ptr [rbx+0CA90h]
000000018037AB81  0F 28 D8                    movaps  xmm3, xmm0
000000018037AB84  F3 0F 59 C1                 mulss   xmm0, xmm1
000000018037AB88  F3 0F 59 DA                 mulss   xmm3, xmm2
000000018037AB8C  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037AB90  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037AB94  41 0F 2F DE                 comiss  xmm3, xmm14
000000018037AB98  76 05                       jbe     short loc_18037AB9F
000000018037AB9A  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018037AB9D  EB 03                       jmp     short loc_18037ABA2
000000018037AB9F  0F 57 C0                    xorps   xmm0, xmm0
000000018037ABA2  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018037ABA6  F3 0F 11 83 70 CA 00 00     movss   dword ptr [rbx+0CA70h], xmm0
000000018037ABAE  F3 0F 10 8B A0 CA 00 00     movss   xmm1, dword ptr [rbx+0CAA0h]
000000018037ABB6  F3 0F 11 8B B0 CA 00 00     movss   dword ptr [rbx+0CAB0h], xmm1
000000018037ABBE  F3 0F 10 93 C0 CA 00 00     movss   xmm2, dword ptr [rbx+0CAC0h]
000000018037ABC6  F3 0F 11 93 D0 CA 00 00     movss   dword ptr [rbx+0CAD0h], xmm2
000000018037ABCE  F3 0F 10 83 E0 CA 00 00     movss   xmm0, dword ptr [rbx+0CAE0h]
000000018037ABD6  0F 28 D8                    movaps  xmm3, xmm0
000000018037ABD9  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037ABDD  F3 0F 59 D9                 mulss   xmm3, xmm1
000000018037ABE1  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037ABE5  F3 0F 58 DA                 addss   xmm3, xmm2
000000018037ABE9  41 0F 2F DE                 comiss  xmm3, xmm14
000000018037ABED  76 05                       jbe     short loc_18037ABF4
000000018037ABEF  0F 5A C3                    cvtps2pd xmm0, xmm3
000000018037ABF2  EB 03                       jmp     short loc_18037ABF7
000000018037ABF4  0F 57 C0                    xorps   xmm0, xmm0
000000018037ABF7  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018037ABFB  F3 0F 11 83 C0 CA 00 00     movss   dword ptr [rbx+0CAC0h], xmm0
000000018037AC03  F3 0F 10 AB F0 CA 00 00     movss   xmm5, dword ptr [rbx+0CAF0h]
000000018037AC0B  F3 0F 10 B3 70 A6 00 00     movss   xmm6, dword ptr [rbx+0A670h]
000000018037AC13  0F 28 E5                    movaps  xmm4, xmm5
000000018037AC16  F3 0F 11 AB 00 CB 00 00     movss   dword ptr [rbx+0CB00h], xmm5
000000018037AC1E  0F 28 C5                    movaps  xmm0, xmm5
000000018037AC21  F3 0F 59 A3 50 CB 00 00     mulss   xmm4, dword ptr [rbx+0CB50h]
000000018037AC29  0F 28 DD                    movaps  xmm3, xmm5
000000018037AC2C  F3 0F 58 83 20 CB 00 00     addss   xmm0, dword ptr [rbx+0CB20h]
000000018037AC34  F3 0F 58 9B 40 CB 00 00     addss   xmm3, dword ptr [rbx+0CB40h]
000000018037AC3C  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037AC40  73 06                       jnb     short loc_18037AC48
000000018037AC42  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037AC46  EB 05                       jmp     short loc_18037AC4D
000000018037AC48  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037AC4D  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037AC51  72 1B                       jb      short loc_18037AC6E
000000018037AC53  F3 0F 10 83 30 CB 00 00     movss   xmm0, dword ptr [rbx+0CB30h]
000000018037AC5B  0F 28 D8                    movaps  xmm3, xmm0
000000018037AC5E  F3 0F 59 C5                 mulss   xmm0, xmm5
000000018037AC62  F3 0F 59 DE                 mulss   xmm3, xmm6
000000018037AC66  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037AC6A  F3 0F 58 DD                 addss   xmm3, xmm5
000000018037AC6E  41 0F 2E F6                 ucomiss xmm6, xmm14
000000018037AC72  F3 0F 10 8B 70 CB 00 00     movss   xmm1, dword ptr [rbx+0CB70h]
000000018037AC7A  0F 28 D4                    movaps  xmm2, xmm4
000000018037AC7D  F3 0F 59 93 60 CB 00 00     mulss   xmm2, dword ptr [rbx+0CB60h]
000000018037AC85  0F 28 C1                    movaps  xmm0, xmm1
000000018037AC88  F3 0F 59 C4                 mulss   xmm0, xmm4
000000018037AC8C  F3 0F 5C D0                 subss   xmm2, xmm0
000000018037AC90  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037AC94  0F 28 C2                    movaps  xmm0, xmm2
000000018037AC97  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037AC9B  F3 0F 59 C6                 mulss   xmm0, xmm6
000000018037AC9F  F3 0F 5C C2                 subss   xmm0, xmm2
000000018037ACA3  F3 0F 58 C5                 addss   xmm0, xmm5
000000018037ACA7  74 03                       jz      short loc_18037ACAC
000000018037ACA9  0F 28 C3                    movaps  xmm0, xmm3
000000018037ACAC  F3 0F 11 83 10 CB 00 00     movss   dword ptr [rbx+0CB10h], xmm0
000000018037ACB4  F3 0F 11 83 F0 CA 00 00     movss   dword ptr [rbx+0CAF0h], xmm0
000000018037ACBC  F3 0F 10 BB 90 C7 00 00     movss   xmm7, dword ptr [rbx+0C790h]
000000018037ACC4  F3 0F 10 B3 00 AF 00 00     movss   xmm6, dword ptr [rbx+0AF00h]
000000018037ACCC  F3 0F 10 9B 00 BF 00 00     movss   xmm3, dword ptr [rbx+0BF00h]
000000018037ACD4  F3 0F 10 83 E0 B0 00 00     movss   xmm0, dword ptr [rbx+0B0E0h]
000000018037ACDC  F3 0F 10 8B 90 C9 00 00     movss   xmm1, dword ptr [rbx+0C990h]
000000018037ACE4  8B 83 B0 CB 00 00           mov     eax, [rbx+0CBB0h]
000000018037ACEA  89 83 C0 CB 00 00           mov     [rbx+0CBC0h], eax
000000018037ACF0  8B 83 D0 CB 00 00           mov     eax, [rbx+0CBD0h]
000000018037ACF6  89 83 E0 CB 00 00           mov     [rbx+0CBE0h], eax
000000018037ACFC  F3 0F 11 83 80 CB 00 00     movss   dword ptr [rbx+0CB80h], xmm0
000000018037AD04  F3 0F 11 8B 90 CB 00 00     movss   dword ptr [rbx+0CB90h], xmm1
000000018037AD0C  F3 0F 59 9B A0 CC 00 00     mulss   xmm3, dword ptr [rbx+0CCA0h]
000000018037AD14  F3 0F 10 A3 C0 CB 00 00     movss   xmm4, dword ptr [rbx+0CBC0h]
000000018037AD1C  F3 0F 10 93 00 CC 00 00     movss   xmm2, dword ptr [rbx+0CC00h]
000000018037AD24  F3 0F 11 9B A0 CB 00 00     movss   dword ptr [rbx+0CBA0h], xmm3
000000018037AD2C  0F 28 DF                    movaps  xmm3, xmm7
000000018037AD2F  F3 0F 59 B3 10 CC 00 00     mulss   xmm6, dword ptr [rbx+0CC10h]
000000018037AD37  F3 0F 5C DC                 subss   xmm3, xmm4
000000018037AD3B  F3 0F 59 93 10 CB 00 00     mulss   xmm2, dword ptr [rbx+0CB10h]
000000018037AD43  F3 0F 10 8B 20 CC 00 00     movss   xmm1, dword ptr [rbx+0CC20h]
000000018037AD4B  0F 28 C3                    movaps  xmm0, xmm3
000000018037AD4E  F3 0F 59 83 40 CC 00 00     mulss   xmm0, dword ptr [rbx+0CC40h]
000000018037AD56  F3 0F 58 F2                 addss   xmm6, xmm2
000000018037AD5A  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037AD5E  41 0F 28 C5                 movaps  xmm0, xmm13
000000018037AD62  F3 0F 11 A3 B0 CB 00 00     movss   dword ptr [rbx+0CBB0h], xmm4
000000018037AD6A  F3 0F 59 8B 80 CB 00 00     mulss   xmm1, dword ptr [rbx+0CB80h]
000000018037AD72  F3 0F 10 93 30 CC 00 00     movss   xmm2, dword ptr [rbx+0CC30h]
000000018037AD7A  F3 0F 59 9B B0 CC 00 00     mulss   xmm3, dword ptr [rbx+0CCB0h]
000000018037AD82  F3 0F 59 A3 C0 CC 00 00     mulss   xmm4, dword ptr [rbx+0CCC0h]
000000018037AD8A  F3 0F 58 F1                 addss   xmm6, xmm1
000000018037AD8E  0F 28 CA                    movaps  xmm1, xmm2
000000018037AD91  F3 0F 59 8B 90 CB 00 00     mulss   xmm1, dword ptr [rbx+0CB90h]
000000018037AD99  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037AD9D  F3 0F 58 DC                 addss   xmm3, xmm4
000000018037ADA1  F3 0F 5C CA                 subss   xmm1, xmm2
000000018037ADA5  F3 0F 58 CE                 addss   xmm1, xmm6
000000018037ADA9  F3 0F 10 B3 50 CC 00 00     movss   xmm6, dword ptr [rbx+0CC50h]
000000018037ADB1  F3 0F 5C C6                 subss   xmm0, xmm6
000000018037ADB5  F3 0F 59 8B 80 CC 00 00     mulss   xmm1, dword ptr [rbx+0CC80h]
000000018037ADBD  F3 0F 59 F8                 mulss   xmm7, xmm0
000000018037ADC1  41 0F 2F CE                 comiss  xmm1, xmm14
000000018037ADC5  76 05                       jbe     short loc_18037ADCC
000000018037ADC7  0F 5A C1                    cvtps2pd xmm0, xmm1
000000018037ADCA  EB 03                       jmp     short loc_18037ADCF
000000018037ADCC  0F 57 C0                    xorps   xmm0, xmm0
000000018037ADCF  F3 0F 10 93 70 CC 00 00     movss   xmm2, dword ptr [rbx+0CC70h]
000000018037ADD7  F3 0F 10 A3 60 CC 00 00     movss   xmm4, dword ptr [rbx+0CC60h]
000000018037ADDF  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
000000018037ADE3  F3 0F 10 83 A0 CB 00 00     movss   xmm0, dword ptr [rbx+0CBA0h]
000000018037ADEB  F3 0F 59 AB 90 CC 00 00     mulss   xmm5, dword ptr [rbx+0CC90h]
000000018037ADF3  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037ADF8  F3 0F 59 F3                 mulss   xmm6, xmm3
000000018037ADFC  F3 0F 10 9B E0 CB 00 00     movss   xmm3, dword ptr [rbx+0CBE0h]
000000018037AE04  F3 0F 58 F7                 addss   xmm6, xmm7
000000018037AE08  F3 0F 59 F0                 mulss   xmm6, xmm0
000000018037AE0C  F3 0F 10 83 D0 CC 00 00     movss   xmm0, dword ptr [rbx+0CCD0h]
000000018037AE14  0F 28 C8                    movaps  xmm1, xmm0
000000018037AE17  F3 0F 59 C3                 mulss   xmm0, xmm3
000000018037AE1B  F3 0F 59 CE                 mulss   xmm1, xmm6
000000018037AE1F  F3 0F 59 D6                 mulss   xmm2, xmm6
000000018037AE23  F3 0F 5C C8                 subss   xmm1, xmm0
000000018037AE27  F3 0F 58 D9                 addss   xmm3, xmm1
000000018037AE2B  F3 0F 11 9B D0 CB 00 00     movss   dword ptr [rbx+0CBD0h], xmm3
000000018037AE33  F3 0F 59 E3                 mulss   xmm4, xmm3
000000018037AE37  F3 0F 58 E2                 addss   xmm4, xmm2
000000018037AE3B  F3 0F 59 E5                 mulss   xmm4, xmm5
000000018037AE3F  F3 0F 59 A3 E0 CC 00 00     mulss   xmm4, dword ptr [rbx+0CCE0h]
000000018037AE47  F3 0F 11 A3 F0 CB 00 00     movss   dword ptr [rbx+0CBF0h], xmm4
000000018037AE4F  8B 83 00 CD 00 00           mov     eax, [rbx+0CD00h]
000000018037AE55  89 83 10 CD 00 00           mov     [rbx+0CD10h], eax
000000018037AE5B  8B 83 F0 CC 00 00           mov     eax, [rbx+0CCF0h]
000000018037AE61  89 83 00 CD 00 00           mov     [rbx+0CD00h], eax
000000018037AE67  F3 0F 10 83 10 CD 00 00     movss   xmm0, dword ptr [rbx+0CD10h]
000000018037AE6F  F3 0F 10 8B 20 CD 00 00     movss   xmm1, dword ptr [rbx+0CD20h]
000000018037AE77  F3 0F 5C E0                 subss   xmm4, xmm0
000000018037AE7B  F3 0F 11 A3 F0 CC 00 00     movss   dword ptr [rbx+0CCF0h], xmm4
000000018037AE83  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037AE87  F3 0F 58 C8                 addss   xmm1, xmm0
000000018037AE8B  F3 0F 11 8B 00 CD 00 00     movss   dword ptr [rbx+0CD00h], xmm1
000000018037AE93  F3 0F 10 93 F0 CC 00 00     movss   xmm2, dword ptr [rbx+0CCF0h]
000000018037AE9B  F3 0F 10 B3 E0 C9 00 00     movss   xmm6, dword ptr [rbx+0C9E0h]
000000018037AEA3  0F 28 C2                    movaps  xmm0, xmm2
000000018037AEA6  41 0F 2F F6                 comiss  xmm6, xmm14
000000018037AEAA  8B 83 50 CD 00 00           mov     eax, [rbx+0CD50h]
000000018037AEB0  89 83 60 CD 00 00           mov     [rbx+0CD60h], eax
000000018037AEB6  8B 83 40 CD 00 00           mov     eax, [rbx+0CD40h]
000000018037AEBC  89 83 50 CD 00 00           mov     [rbx+0CD50h], eax
000000018037AEC2  8B 83 30 CD 00 00           mov     eax, [rbx+0CD30h]
000000018037AEC8  89 83 40 CD 00 00           mov     [rbx+0CD40h], eax
000000018037AECE  F3 0F 11 93 30 CD 00 00     movss   dword ptr [rbx+0CD30h], xmm2
000000018037AED6  F3 0F 59 83 80 CD 00 00     mulss   xmm0, dword ptr [rbx+0CD80h]
000000018037AEDE  F3 0F 10 A3 40 CD 00 00     movss   xmm4, dword ptr [rbx+0CD40h]
000000018037AEE6  F3 0F 10 8B A0 CD 00 00     movss   xmm1, dword ptr [rbx+0CDA0h]
000000018037AEEE  0F 28 EC                    movaps  xmm5, xmm4
000000018037AEF1  F3 0F 59 8B 50 CD 00 00     mulss   xmm1, dword ptr [rbx+0CD50h]
000000018037AEF9  F3 0F 59 AB 90 CD 00 00     mulss   xmm5, dword ptr [rbx+0CD90h]
000000018037AF01  F3 0F 59 A3 C0 CD 00 00     mulss   xmm4, dword ptr [rbx+0CDC0h]
000000018037AF09  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037AF0D  0F 28 C2                    movaps  xmm0, xmm2
000000018037AF10  F3 0F 59 83 B0 CD 00 00     mulss   xmm0, dword ptr [rbx+0CDB0h]
000000018037AF18  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037AF1C  F3 0F 10 8B D0 CD 00 00     movss   xmm1, dword ptr [rbx+0CDD0h]
000000018037AF24  F3 0F 59 8B 60 CD 00 00     mulss   xmm1, dword ptr [rbx+0CD60h]
000000018037AF2C  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037AF30  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037AF34  76 05                       jbe     short loc_18037AF3B
000000018037AF36  0F 5A C6                    cvtps2pd xmm0, xmm6
000000018037AF39  EB 03                       jmp     short loc_18037AF3E
000000018037AF3B  0F 57 C0                    xorps   xmm0, xmm0
000000018037AF3E  0F 2F 35 7B A5 76 00        comiss  xmm6, cs:dword_180AE54C0
000000018037AF45  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018037AF49  F3 0F 11 AB 40 CD 00 00     movss   dword ptr [rbx+0CD40h], xmm5
000000018037AF51  0F 28 D8                    movaps  xmm3, xmm0
000000018037AF54  F3 0F 11 A3 50 CD 00 00     movss   dword ptr [rbx+0CD50h], xmm4
000000018037AF5C  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037AF60  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037AF64  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037AF68  0F 28 C6                    movaps  xmm0, xmm6
000000018037AF6B  41 0F 57 C3                 xorps   xmm0, xmm11
000000018037AF6F  F3 0F 58 DA                 addss   xmm3, xmm2
000000018037AF73  73 09                       jnb     short loc_18037AF7E
000000018037AF75  45 0F 57 D2                 xorps   xmm10, xmm10
000000018037AF79  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
000000018037AF7E  41 0F 2F F6                 comiss  xmm6, xmm14
000000018037AF82  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
000000018037AF87  0F 28 C8                    movaps  xmm1, xmm0
000000018037AF8A  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037AF8E  F3 0F 59 CC                 mulss   xmm1, xmm4
000000018037AF92  F3 0F 5C C8                 subss   xmm1, xmm0
000000018037AF96  F3 0F 58 D1                 addss   xmm2, xmm1
000000018037AF9A  72 03                       jb      short loc_18037AF9F
000000018037AF9C  0F 28 D3                    movaps  xmm2, xmm3
000000018037AF9F  F3 0F 11 93 70 CD 00 00     movss   dword ptr [rbx+0CD70h], xmm2
000000018037AFA7  F3 0F 59 93 70 CA 00 00     mulss   xmm2, dword ptr [rbx+0CA70h]
000000018037AFAF  F3 0F 11 93 E0 CD 00 00     movss   dword ptr [rbx+0CDE0h], xmm2
000000018037AFB7  F3 0F 59 93 C0 CA 00 00     mulss   xmm2, dword ptr [rbx+0CAC0h]
000000018037AFBF  F3 0F 11 93 F0 CD 00 00     movss   dword ptr [rbx+0CDF0h], xmm2
000000018037AFC7  F3 0F 10 83 A0 B5 00 00     movss   xmm0, dword ptr [rbx+0B5A0h]
000000018037AFCF  F3 0F 58 83 00 B3 00 00     addss   xmm0, dword ptr [rbx+0B300h]
000000018037AFD7  44 0F 5A E0                 cvtps2pd xmm12, xmm0
000000018037AFDB  F2 44 0F 5F 25 C4 FC 60 00  maxsd   xmm12, cs:qword_18098ACA8
000000018037AFE4  F2 44 0F 5D 25 A3 FC 60 00  minsd   xmm12, cs:qword_18098AC90
000000018037AFED  41 0F 28 CC                 movaps  xmm1, xmm12
000000018037AFF1  41 0F 28 C4                 movaps  xmm0, xmm12
000000018037AFF5  F2 0F 58 05 6B A2 76 00     addsd   xmm0, cs:qword_180AE5268
000000018037AFFD  F2 41 0F 59 CC              mulsd   xmm1, xmm12
000000018037B002  41 0F 28 FC                 movaps  xmm7, xmm12
000000018037B006  F2 0F 2C C0                 cvttsd2si eax, xmm0
000000018037B00A  0F 28 D1                    movaps  xmm2, xmm1
000000018037B00D  48 63 C8                    movsxd  rcx, eax
000000018037B010  F2 41 0F 59 D4              mulsd   xmm2, xmm12
000000018037B015  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
000000018037B01C  0F 28 DA                    movaps  xmm3, xmm2
000000018037B01F  F2 41 0F 59 DC              mulsd   xmm3, xmm12
000000018037B024  48 8D 0D B5 E4 60 00        lea     rcx, unk_1809894E0
000000018037B02B  48 03 C1                    add     rax, rcx
000000018037B02E  0F 28 E3                    movaps  xmm4, xmm3
000000018037B031  F2 41 0F 59 E4              mulsd   xmm4, xmm12
000000018037B036  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
000000018037B03B  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
000000018037B040  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
000000018037B045  0F 28 EC                    movaps  xmm5, xmm4
000000018037B048  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
000000018037B04C  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
000000018037B051  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
000000018037B056  F2 0F 58 F9                 addsd   xmm7, xmm1
000000018037B05A  F2 41 0F 59 EC              mulsd   xmm5, xmm12
000000018037B05F  F2 0F 58 FA                 addsd   xmm7, xmm2
000000018037B063  0F 28 F5                    movaps  xmm6, xmm5
000000018037B066  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
000000018037B06B  F2 41 0F 59 F4              mulsd   xmm6, xmm12
000000018037B070  F2 0F 58 FB                 addsd   xmm7, xmm3
000000018037B074  44 0F 28 C6                 movaps  xmm8, xmm6
000000018037B078  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
000000018037B07D  F2 0F 58 FC                 addsd   xmm7, xmm4
000000018037B081  F2 45 0F 59 C4              mulsd   xmm8, xmm12
000000018037B086  F2 0F 58 FD                 addsd   xmm7, xmm5
000000018037B08A  45 0F 28 C8                 movaps  xmm9, xmm8
000000018037B08E  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
000000018037B097  F2 45 0F 59 CC              mulsd   xmm9, xmm12
000000018037B09C  F2 0F 58 FE                 addsd   xmm7, xmm6
000000018037B0A0  45 0F 28 D1                 movaps  xmm10, xmm9
000000018037B0A4  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
000000018037B0AD  F2 41 0F 58 F8              addsd   xmm7, xmm8
000000018037B0B2  F2 45 0F 59 D4              mulsd   xmm10, xmm12
000000018037B0B7  F2 41 0F 58 F9              addsd   xmm7, xmm9
000000018037B0BC  45 0F 28 DA                 movaps  xmm11, xmm10
000000018037B0C0  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
000000018037B0C9  F2 45 0F 59 DC              mulsd   xmm11, xmm12
000000018037B0CE  F2 41 0F 58 FA              addsd   xmm7, xmm10
000000018037B0D3  41 0F 28 C3                 movaps  xmm0, xmm11
000000018037B0D7  F2 45 0F 59 DC              mulsd   xmm11, xmm12
000000018037B0DC  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
000000018037B0E4  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
000000018037B0ED  F2 0F 58 F8                 addsd   xmm7, xmm0
000000018037B0F1  F2 41 0F 58 FB              addsd   xmm7, xmm11
000000018037B0F6  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
000000018037B0FA  F3 0F 5D 1D 96 FB 60 00     minss   xmm3, cs:dword_18098AC98
000000018037B102  F3 0F 5F 1D A6 FB 60 00     maxss   xmm3, cs:dword_18098ACB0
000000018037B10A  F3 0F 59 9B 10 B3 00 00     mulss   xmm3, dword ptr [rbx+0B310h]
000000018037B112  F3 0F 11 9B 80 B5 00 00     movss   dword ptr [rbx+0B580h], xmm3
000000018037B11A  8B 83 20 B7 00 00           mov     eax, [rbx+0B720h]
000000018037B120  F3 0F 10 AB 00 B3 00 00     movss   xmm5, dword ptr [rbx+0B300h]
000000018037B128  F3 0F 10 83 D0 B4 00 00     movss   xmm0, dword ptr [rbx+0B4D0h]
000000018037B130  F3 0F 10 8B E0 B4 00 00     movss   xmm1, dword ptr [rbx+0B4E0h]
000000018037B138  F3 0F 10 93 F0 B4 00 00     movss   xmm2, dword ptr [rbx+0B4F0h]
000000018037B140  89 83 30 B7 00 00           mov     [rbx+0B730h], eax
000000018037B146  8B 83 40 B7 00 00           mov     eax, [rbx+0B740h]
000000018037B14C  89 83 50 B7 00 00           mov     [rbx+0B750h], eax
000000018037B152  8B 83 F0 B7 00 00           mov     eax, [rbx+0B7F0h]
000000018037B158  89 83 00 B8 00 00           mov     [rbx+0B800h], eax
000000018037B15E  8B 83 E0 B7 00 00           mov     eax, [rbx+0B7E0h]
000000018037B164  89 83 F0 B7 00 00           mov     [rbx+0B7F0h], eax
000000018037B16A  8B 83 D0 B7 00 00           mov     eax, [rbx+0B7D0h]
000000018037B170  89 83 E0 B7 00 00           mov     [rbx+0B7E0h], eax
000000018037B176  8B 83 C0 B7 00 00           mov     eax, [rbx+0B7C0h]
000000018037B17C  89 83 D0 B7 00 00           mov     [rbx+0B7D0h], eax
000000018037B182  8B 83 B0 B7 00 00           mov     eax, [rbx+0B7B0h]
000000018037B188  89 83 C0 B7 00 00           mov     [rbx+0B7C0h], eax
000000018037B18E  8B 83 A0 B7 00 00           mov     eax, [rbx+0B7A0h]
000000018037B194  89 83 B0 B7 00 00           mov     [rbx+0B7B0h], eax
000000018037B19A  8B 83 90 B7 00 00           mov     eax, [rbx+0B790h]
000000018037B1A0  89 83 A0 B7 00 00           mov     [rbx+0B7A0h], eax
000000018037B1A6  8B 83 70 B8 00 00           mov     eax, [rbx+0B870h]
000000018037B1AC  89 83 80 B8 00 00           mov     [rbx+0B880h], eax
000000018037B1B2  8B 83 60 B8 00 00           mov     eax, [rbx+0B860h]
000000018037B1B8  89 83 70 B8 00 00           mov     [rbx+0B870h], eax
000000018037B1BE  8B 83 50 B8 00 00           mov     eax, [rbx+0B850h]
000000018037B1C4  89 83 60 B8 00 00           mov     [rbx+0B860h], eax
000000018037B1CA  8B 83 40 B8 00 00           mov     eax, [rbx+0B840h]
000000018037B1D0  89 83 50 B8 00 00           mov     [rbx+0B850h], eax
000000018037B1D6  8B 83 30 B8 00 00           mov     eax, [rbx+0B830h]
000000018037B1DC  89 83 40 B8 00 00           mov     [rbx+0B840h], eax
000000018037B1E2  8B 83 20 B8 00 00           mov     eax, [rbx+0B820h]
000000018037B1E8  89 83 30 B8 00 00           mov     [rbx+0B830h], eax
000000018037B1EE  8B 83 10 B8 00 00           mov     eax, [rbx+0B810h]
000000018037B1F4  89 83 20 B8 00 00           mov     [rbx+0B820h], eax
000000018037B1FA  8B 83 F0 B8 00 00           mov     eax, [rbx+0B8F0h]
000000018037B200  89 83 00 B9 00 00           mov     [rbx+0B900h], eax
000000018037B206  8B 83 E0 B8 00 00           mov     eax, [rbx+0B8E0h]
000000018037B20C  89 83 F0 B8 00 00           mov     [rbx+0B8F0h], eax
000000018037B212  8B 83 D0 B8 00 00           mov     eax, [rbx+0B8D0h]
000000018037B218  89 83 E0 B8 00 00           mov     [rbx+0B8E0h], eax
000000018037B21E  8B 83 C0 B8 00 00           mov     eax, [rbx+0B8C0h]
000000018037B224  89 83 D0 B8 00 00           mov     [rbx+0B8D0h], eax
000000018037B22A  8B 83 B0 B8 00 00           mov     eax, [rbx+0B8B0h]
000000018037B230  89 83 C0 B8 00 00           mov     [rbx+0B8C0h], eax
000000018037B236  8B 83 A0 B8 00 00           mov     eax, [rbx+0B8A0h]
000000018037B23C  89 83 B0 B8 00 00           mov     [rbx+0B8B0h], eax
000000018037B242  8B 83 90 B8 00 00           mov     eax, [rbx+0B890h]
000000018037B248  89 83 A0 B8 00 00           mov     [rbx+0B8A0h], eax
000000018037B24E  8B 83 70 B9 00 00           mov     eax, [rbx+0B970h]
000000018037B254  89 83 80 B9 00 00           mov     [rbx+0B980h], eax
000000018037B25A  8B 83 60 B9 00 00           mov     eax, [rbx+0B960h]
000000018037B260  89 83 70 B9 00 00           mov     [rbx+0B970h], eax
000000018037B266  8B 83 50 B9 00 00           mov     eax, [rbx+0B950h]
000000018037B26C  89 83 60 B9 00 00           mov     [rbx+0B960h], eax
000000018037B272  8B 83 40 B9 00 00           mov     eax, [rbx+0B940h]
000000018037B278  89 83 50 B9 00 00           mov     [rbx+0B950h], eax
000000018037B27E  8B 83 30 B9 00 00           mov     eax, [rbx+0B930h]
000000018037B284  89 83 40 B9 00 00           mov     [rbx+0B940h], eax
000000018037B28A  8B 83 20 B9 00 00           mov     eax, [rbx+0B920h]
000000018037B290  89 83 30 B9 00 00           mov     [rbx+0B930h], eax
000000018037B296  8B 83 10 B9 00 00           mov     eax, [rbx+0B910h]
000000018037B29C  89 83 20 B9 00 00           mov     [rbx+0B920h], eax
000000018037B2A2  8B 83 B0 B9 00 00           mov     eax, [rbx+0B9B0h]
000000018037B2A8  89 83 C0 B9 00 00           mov     [rbx+0B9C0h], eax
000000018037B2AE  8B 83 A0 B9 00 00           mov     eax, [rbx+0B9A0h]
000000018037B2B4  89 83 B0 B9 00 00           mov     [rbx+0B9B0h], eax
000000018037B2BA  F3 0F 11 83 C0 B6 00 00     movss   dword ptr [rbx+0B6C0h], xmm0
000000018037B2C2  F3 0F 11 8B D0 B6 00 00     movss   dword ptr [rbx+0B6D0h], xmm1
000000018037B2CA  F3 0F 58 AB E0 BC 00 00     addss   xmm5, dword ptr [rbx+0BCE0h]
000000018037B2D2  F3 0F 59 9B E0 B9 00 00     mulss   xmm3, dword ptr [rbx+0B9E0h]
000000018037B2DA  F3 0F 10 83 D0 B9 00 00     movss   xmm0, dword ptr [rbx+0B9D0h]
000000018037B2E2  F3 0F 11 93 E0 B6 00 00     movss   dword ptr [rbx+0B6E0h], xmm2
000000018037B2EA  F3 0F 10 93 00 BA 00 00     movss   xmm2, dword ptr [rbx+0BA00h]
000000018037B2F2  F3 0F 59 AB F0 BC 00 00     mulss   xmm5, dword ptr [rbx+0BCF0h]
000000018037B2FA  F3 0F 5F D3                 maxss   xmm2, xmm3
000000018037B2FE  F3 0F 58 AB D0 BC 00 00     addss   xmm5, dword ptr [rbx+0BCD0h]
000000018037B306  F3 0F 11 93 F0 B6 00 00     movss   dword ptr [rbx+0B6F0h], xmm2
000000018037B30E  F3 0F 58 83 20 B3 00 00     addss   xmm0, dword ptr [rbx+0B320h]
000000018037B316  41 0F 2F EE                 comiss  xmm5, xmm14
000000018037B31A  F3 0F 11 83 10 B7 00 00     movss   dword ptr [rbx+0B710h], xmm0
000000018037B322  76 05                       jbe     short loc_18037B329
000000018037B324  0F 5A C5                    cvtps2pd xmm0, xmm5
000000018037B327  EB 03                       jmp     short loc_18037B32C
000000018037B329  0F 57 C0                    xorps   xmm0, xmm0
000000018037B32C  F3 0F 10 0D 28 9C 76 00     movss   xmm1, cs:dword_180AE4F5C
000000018037B334  F3 44 0F 10 15 AB 9E 76 00  movss   xmm10, cs:flt_180AE51E8
000000018037B33D  F3 0F 5E CA                 divss   xmm1, xmm2
000000018037B341  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
000000018037B345  F3 0F 11 8B 00 B7 00 00     movss   dword ptr [rbx+0B700h], xmm1
000000018037B34D  F3 0F 11 83 90 B9 00 00     movss   dword ptr [rbx+0B990h], xmm0
000000018037B355  F3 0F 10 B3 50 B7 00 00     movss   xmm6, dword ptr [rbx+0B750h]
000000018037B35D  F3 0F 10 8B 30 B7 00 00     movss   xmm1, dword ptr [rbx+0B730h]
000000018037B365  F3 0F 11 B3 70 B6 00 00     movss   dword ptr [rbx+0B670h], xmm6
000000018037B36D  F3 0F 58 F2                 addss   xmm6, xmm2
000000018037B371  F3 0F 11 8B 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm1
000000018037B379  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037B37D  76 1B                       jbe     short loc_18037B39A
000000018037B37F  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037B384  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037B388  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037B38B  E8 48 41 37 00              call    fmodf
000000018037B390  0F 28 F0                    movaps  xmm6, xmm0
000000018037B393  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037B398  EB 1F                       jmp     short loc_18037B3B9
000000018037B39A  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037B39E  73 19                       jnb     short loc_18037B3B9
000000018037B3A0  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037B3A5  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037B3A9  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037B3AC  E8 27 41 37 00              call    fmodf
000000018037B3B1  0F 28 F0                    movaps  xmm6, xmm0
000000018037B3B4  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037B3B9  F3 44 0F 10 25 4A 9C 76 00  movss   xmm12, cs:dword_180AE500C
000000018037B3C2  0F 28 C6                    movaps  xmm0, xmm6
000000018037B3C5  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037B3CA  F3 0F 11 B3 60 B6 00 00     movss   dword ptr [rbx+0B660h], xmm6
000000018037B3D2  0F 28 FE                    movaps  xmm7, xmm6
000000018037B3D5  F3 0F 59 BB 50 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA50h]
000000018037B3DD  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018037B3E2  E8 D9 DB FE FF              call    sub_180368FC0
000000018037B3E7  F3 44 0F 10 1D 54 A0 76 00  movss   xmm11, cs:dword_180AE5444
000000018037B3F0  0F 28 E8                    movaps  xmm5, xmm0
000000018037B3F3  F3 41 0F 59 EB              mulss   xmm5, xmm11
000000018037B3F8  F3 0F 59 AB 00 B7 00 00     mulss   xmm5, dword ptr [rbx+0B700h]
000000018037B400  F3 0F 59 AB 20 BA 00 00     mulss   xmm5, dword ptr [rbx+0BA20h]
000000018037B408  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037B40C  73 06                       jnb     short loc_18037B414
000000018037B40E  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037B412  EB 05                       jmp     short loc_18037B419
000000018037B414  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037B419  F3 0F 59 AB F0 B9 00 00     mulss   xmm5, dword ptr [rbx+0B9F0h]
000000018037B421  0F 28 D5                    movaps  xmm2, xmm5
000000018037B424  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037B428  0F 28 CA                    movaps  xmm1, xmm2
000000018037B42B  0F 28 C2                    movaps  xmm0, xmm2
000000018037B42E  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037B436  0F 28 DA                    movaps  xmm3, xmm2
000000018037B439  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037B43D  0F 28 E2                    movaps  xmm4, xmm2
000000018037B440  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
000000018037B448  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037B450  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037B454  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
000000018037B45C  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037B460  0F 28 C3                    movaps  xmm0, xmm3
000000018037B463  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037B46B  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037B46F  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037B473  F3 0F 10 8B 10 B7 00 00     movss   xmm1, dword ptr [rbx+0B710h]
000000018037B47B  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037B47F  0F 28 C1                    movaps  xmm0, xmm1
000000018037B482  F3 0F 58 C6                 addss   xmm0, xmm6
000000018037B486  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037B48A  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037B48E  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037B492  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037B496  F3 0F 11 A3 60 B7 00 00     movss   dword ptr [rbx+0B760h], xmm4
000000018037B49E  72 07                       jb      short loc_18037B4A7
000000018037B4A0  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018037B4A5  EB 05                       jmp     short loc_18037B4AC
000000018037B4A7  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037B4AC  0F 28 F0                    movaps  xmm6, xmm0
000000018037B4AF  73 06                       jnb     short loc_18037B4B7
000000018037B4B1  41 0F 28 F7                 movaps  xmm6, xmm15
000000018037B4B5  EB 06                       jmp     short loc_18037B4BD
000000018037B4B7  76 04                       jbe     short loc_18037B4BD
000000018037B4B9  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037B4BD  F3 44 0F 10 83 60 B6 00 00  movss   xmm8, dword ptr [rbx+0B660h]
000000018037B4C6  F3 0F 59 B3 60 BA 00 00     mulss   xmm6, dword ptr [rbx+0BA60h]
000000018037B4CE  F3 0F 5E C1                 divss   xmm0, xmm1
000000018037B4D2  E8 E9 DA FE FF              call    sub_180368FC0
000000018037B4D7  0F 28 E0                    movaps  xmm4, xmm0
000000018037B4DA  F3 0F 10 83 10 BA 00 00     movss   xmm0, dword ptr [rbx+0BA10h]
000000018037B4E2  44 0F 2F C0                 comiss  xmm8, xmm0
000000018037B4E6  72 18                       jb      short loc_18037B500
000000018037B4E8  0F 2F 83 70 B6 00 00        comiss  xmm0, dword ptr [rbx+0B670h]
000000018037B4EF  76 0F                       jbe     short loc_18037B500
000000018037B4F1  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
000000018037B4F9  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018037B4FE  EB 08                       jmp     short loc_18037B508
000000018037B500  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
000000018037B508  0F 2F 3D C1 9D 76 00        comiss  xmm7, cs:dword_180AE52D0
000000018037B50F  F3 0F 59 A3 00 B7 00 00     mulss   xmm4, dword ptr [rbx+0B700h]
000000018037B517  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018037B51C  F3 0F 59 A3 30 BA 00 00     mulss   xmm4, dword ptr [rbx+0BA30h]
000000018037B524  72 03                       jb      short loc_18037B529
000000018037B526  0F 57 FF                    xorps   xmm7, xmm7
000000018037B529  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037B52D  73 06                       jnb     short loc_18037B535
000000018037B52F  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037B533  EB 05                       jmp     short loc_18037B53A
000000018037B535  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037B53A  F3 0F 11 BB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm7
000000018037B542  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018037B547  F3 0F 59 A3 F0 B9 00 00     mulss   xmm4, dword ptr [rbx+0B9F0h]
000000018037B54F  0F 28 D4                    movaps  xmm2, xmm4
000000018037B552  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037B557  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037B55B  0F 28 C2                    movaps  xmm0, xmm2
000000018037B55E  F3 41 0F 59 FC              mulss   xmm7, xmm12
000000018037B563  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037B567  0F 28 DA                    movaps  xmm3, xmm2
000000018037B56A  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037B56E  44 0F 28 CA                 movaps  xmm9, xmm2
000000018037B572  F3 44 0F 59 8B C0 BB 00 00  mulss   xmm9, dword ptr [rbx+0BBC0h]
000000018037B57B  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037B580  0F 28 CA                    movaps  xmm1, xmm2
000000018037B583  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037B58B  F3 44 0F 58 8B B0 BB 00 00  addss   xmm9, dword ptr [rbx+0BBB0h]
000000018037B594  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037B59C  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037B5A1  0F 28 C3                    movaps  xmm0, xmm3
000000018037B5A4  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037B5AC  F3 44 0F 58 C9              addss   xmm9, xmm1
000000018037B5B1  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037B5B5  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037B5BA  0F 28 C7                    movaps  xmm0, xmm7
000000018037B5BD  0F 54 05 CC A1 76 00        andps   xmm0, cs:xmmword_180AE5790
000000018037B5C4  0F 57 05 F5 A1 76 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037B5CB  F3 44 0F 58 CB              addss   xmm9, xmm3
000000018037B5D0  F3 44 0F 58 CC              addss   xmm9, xmm4
000000018037B5D5  F3 44 0F 59 CE              mulss   xmm9, xmm6
000000018037B5DA  F3 44 0F 11 8B 70 B7 00 00  movss   dword ptr [rbx+0B770h], xmm9
000000018037B5E3  E8 D8 D9 FE FF              call    sub_180368FC0
000000018037B5E8  41 0F 2F FE                 comiss  xmm7, xmm14
000000018037B5EC  44 0F 28 C0                 movaps  xmm8, xmm0
000000018037B5F0  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018037B5F5  73 06                       jnb     short loc_18037B5FD
000000018037B5F7  41 0F 28 FF                 movaps  xmm7, xmm15
000000018037B5FB  EB 06                       jmp     short loc_18037B603
000000018037B5FD  76 04                       jbe     short loc_18037B603
000000018037B5FF  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037B603  F3 44 0F 59 83 00 B7 00 00  mulss   xmm8, dword ptr [rbx+0B700h]
000000018037B60C  F3 0F 59 BB 70 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA70h]
000000018037B614  F3 44 0F 59 05 7B F6 60 00  mulss   xmm8, cs:dword_18098AC98
000000018037B61D  F3 44 0F 59 83 40 BA 00 00  mulss   xmm8, dword ptr [rbx+0BA40h]
000000018037B626  45 0F 2F C7                 comiss  xmm8, xmm15
000000018037B62A  73 06                       jnb     short loc_18037B632
000000018037B62C  45 0F 28 C7                 movaps  xmm8, xmm15
000000018037B630  EB 05                       jmp     short loc_18037B637
000000018037B632  F3 45 0F 5D C5              minss   xmm8, xmm13
000000018037B637  F3 44 0F 59 83 F0 B9 00 00  mulss   xmm8, dword ptr [rbx+0B9F0h]
000000018037B640  F3 44 0F 59 8B D0 B6 00 00  mulss   xmm9, dword ptr [rbx+0B6D0h]
000000018037B649  F3 0F 10 B3 60 B6 00 00     movss   xmm6, dword ptr [rbx+0B660h]
000000018037B651  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037B655  F3 0F 10 AB 80 B6 00 00     movss   xmm5, dword ptr [rbx+0B680h]
000000018037B65D  F3 41 0F 59 D0              mulss   xmm2, xmm8
000000018037B662  0F 28 C2                    movaps  xmm0, xmm2
000000018037B665  0F 28 DA                    movaps  xmm3, xmm2
000000018037B668  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037B66C  0F 28 E2                    movaps  xmm4, xmm2
000000018037B66F  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
000000018037B677  0F 28 CA                    movaps  xmm1, xmm2
000000018037B67A  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037B682  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
000000018037B68A  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018037B68F  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037B697  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037B69B  0F 28 C3                    movaps  xmm0, xmm3
000000018037B69E  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037B6A6  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037B6AA  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037B6AE  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037B6B2  F3 0F 10 83 60 B7 00 00     movss   xmm0, dword ptr [rbx+0B760h]
000000018037B6BA  F3 0F 59 83 C0 B6 00 00     mulss   xmm0, dword ptr [rbx+0B6C0h]
000000018037B6C2  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037B6C6  F3 41 0F 58 C1              addss   xmm0, xmm9
000000018037B6CB  F3 41 0F 58 E0              addss   xmm4, xmm8
000000018037B6D0  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037B6D4  F3 0F 59 A3 E0 B6 00 00     mulss   xmm4, dword ptr [rbx+0B6E0h]
000000018037B6DC  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037B6E0  F3 0F 11 A3 90 B7 00 00     movss   dword ptr [rbx+0B790h], xmm4
000000018037B6E8  F3 0F 11 B3 70 B6 00 00     movss   dword ptr [rbx+0B670h], xmm6
000000018037B6F0  F3 0F 11 AB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm5
000000018037B6F8  F3 0F 58 B3 F0 B6 00 00     addss   xmm6, dword ptr [rbx+0B6F0h]
000000018037B700  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037B704  76 1B                       jbe     short loc_18037B721
000000018037B706  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037B70B  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037B70F  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037B712  E8 C1 3D 37 00              call    fmodf
000000018037B717  0F 28 F0                    movaps  xmm6, xmm0
000000018037B71A  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037B71F  EB 1F                       jmp     short loc_18037B740
000000018037B721  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037B725  73 19                       jnb     short loc_18037B740
000000018037B727  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037B72C  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037B730  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037B733  E8 A0 3D 37 00              call    fmodf
000000018037B738  0F 28 F0                    movaps  xmm6, xmm0
000000018037B73B  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037B740  0F 28 C6                    movaps  xmm0, xmm6
000000018037B743  F3 0F 11 B3 60 B6 00 00     movss   dword ptr [rbx+0B660h], xmm6
000000018037B74B  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037B750  0F 28 FE                    movaps  xmm7, xmm6
000000018037B753  F3 0F 59 BB 50 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA50h]
000000018037B75B  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018037B760  E8 5B D8 FE FF              call    sub_180368FC0
000000018037B765  0F 28 E8                    movaps  xmm5, xmm0
000000018037B768  F3 41 0F 59 EB              mulss   xmm5, xmm11
000000018037B76D  F3 0F 59 AB 00 B7 00 00     mulss   xmm5, dword ptr [rbx+0B700h]
000000018037B775  F3 0F 59 AB 20 BA 00 00     mulss   xmm5, dword ptr [rbx+0BA20h]
000000018037B77D  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037B781  73 06                       jnb     short loc_18037B789
000000018037B783  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037B787  EB 05                       jmp     short loc_18037B78E
000000018037B789  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037B78E  F3 0F 59 AB F0 B9 00 00     mulss   xmm5, dword ptr [rbx+0B9F0h]
000000018037B796  0F 28 D5                    movaps  xmm2, xmm5
000000018037B799  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037B79D  0F 28 CA                    movaps  xmm1, xmm2
000000018037B7A0  0F 28 C2                    movaps  xmm0, xmm2
000000018037B7A3  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037B7AB  0F 28 DA                    movaps  xmm3, xmm2
000000018037B7AE  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037B7B2  0F 28 E2                    movaps  xmm4, xmm2
000000018037B7B5  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
000000018037B7BD  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037B7C5  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037B7C9  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
000000018037B7D1  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037B7D5  0F 28 C3                    movaps  xmm0, xmm3
000000018037B7D8  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037B7E0  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037B7E4  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037B7E8  F3 0F 10 8B 10 B7 00 00     movss   xmm1, dword ptr [rbx+0B710h]
000000018037B7F0  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037B7F4  0F 28 C1                    movaps  xmm0, xmm1
000000018037B7F7  F3 0F 58 C6                 addss   xmm0, xmm6
000000018037B7FB  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037B7FF  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037B803  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037B807  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037B80B  F3 0F 11 A3 60 B7 00 00     movss   dword ptr [rbx+0B760h], xmm4
000000018037B813  72 07                       jb      short loc_18037B81C
000000018037B815  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018037B81A  EB 05                       jmp     short loc_18037B821
000000018037B81C  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037B821  0F 28 F0                    movaps  xmm6, xmm0
000000018037B824  73 06                       jnb     short loc_18037B82C
000000018037B826  41 0F 28 F7                 movaps  xmm6, xmm15
000000018037B82A  EB 06                       jmp     short loc_18037B832
000000018037B82C  76 04                       jbe     short loc_18037B832
000000018037B82E  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037B832  F3 44 0F 10 83 60 B6 00 00  movss   xmm8, dword ptr [rbx+0B660h]
000000018037B83B  F3 0F 59 B3 60 BA 00 00     mulss   xmm6, dword ptr [rbx+0BA60h]
000000018037B843  F3 0F 5E C1                 divss   xmm0, xmm1
000000018037B847  E8 74 D7 FE FF              call    sub_180368FC0
000000018037B84C  0F 28 E0                    movaps  xmm4, xmm0
000000018037B84F  F3 0F 10 83 10 BA 00 00     movss   xmm0, dword ptr [rbx+0BA10h]
000000018037B857  44 0F 2F C0                 comiss  xmm8, xmm0
000000018037B85B  72 18                       jb      short loc_18037B875
000000018037B85D  0F 2F 83 70 B6 00 00        comiss  xmm0, dword ptr [rbx+0B670h]
000000018037B864  76 0F                       jbe     short loc_18037B875
000000018037B866  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
000000018037B86E  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018037B873  EB 08                       jmp     short loc_18037B87D
000000018037B875  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
000000018037B87D  0F 2F 3D 4C 9A 76 00        comiss  xmm7, cs:dword_180AE52D0
000000018037B884  F3 0F 59 A3 00 B7 00 00     mulss   xmm4, dword ptr [rbx+0B700h]
000000018037B88C  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018037B891  F3 0F 59 A3 30 BA 00 00     mulss   xmm4, dword ptr [rbx+0BA30h]
000000018037B899  72 03                       jb      short loc_18037B89E
000000018037B89B  0F 57 FF                    xorps   xmm7, xmm7
000000018037B89E  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037B8A2  73 06                       jnb     short loc_18037B8AA
000000018037B8A4  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037B8A8  EB 05                       jmp     short loc_18037B8AF
000000018037B8AA  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037B8AF  F3 0F 11 BB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm7
000000018037B8B7  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018037B8BC  F3 0F 59 A3 F0 B9 00 00     mulss   xmm4, dword ptr [rbx+0B9F0h]
000000018037B8C4  0F 28 D4                    movaps  xmm2, xmm4
000000018037B8C7  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037B8CC  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037B8D0  0F 28 C2                    movaps  xmm0, xmm2
000000018037B8D3  F3 41 0F 59 FC              mulss   xmm7, xmm12
000000018037B8D8  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037B8DC  0F 28 DA                    movaps  xmm3, xmm2
000000018037B8DF  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037B8E3  44 0F 28 CA                 movaps  xmm9, xmm2
000000018037B8E7  F3 44 0F 59 8B C0 BB 00 00  mulss   xmm9, dword ptr [rbx+0BBC0h]
000000018037B8F0  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037B8F5  0F 28 CA                    movaps  xmm1, xmm2
000000018037B8F8  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037B900  F3 44 0F 58 8B B0 BB 00 00  addss   xmm9, dword ptr [rbx+0BBB0h]
000000018037B909  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037B911  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037B916  0F 28 C3                    movaps  xmm0, xmm3
000000018037B919  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037B921  F3 44 0F 58 C9              addss   xmm9, xmm1
000000018037B926  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037B92A  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037B92F  0F 28 C7                    movaps  xmm0, xmm7
000000018037B932  0F 54 05 57 9E 76 00        andps   xmm0, cs:xmmword_180AE5790
000000018037B939  0F 57 05 80 9E 76 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037B940  F3 44 0F 58 CB              addss   xmm9, xmm3
000000018037B945  F3 44 0F 58 CC              addss   xmm9, xmm4
000000018037B94A  F3 44 0F 59 CE              mulss   xmm9, xmm6
000000018037B94F  F3 44 0F 11 8B 70 B7 00 00  movss   dword ptr [rbx+0B770h], xmm9
000000018037B958  E8 63 D6 FE FF              call    sub_180368FC0
000000018037B95D  41 0F 2F FE                 comiss  xmm7, xmm14
000000018037B961  44 0F 28 C0                 movaps  xmm8, xmm0
000000018037B965  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018037B96A  73 06                       jnb     short loc_18037B972
000000018037B96C  41 0F 28 FF                 movaps  xmm7, xmm15
000000018037B970  EB 06                       jmp     short loc_18037B978
000000018037B972  76 04                       jbe     short loc_18037B978
000000018037B974  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037B978  F3 44 0F 59 83 00 B7 00 00  mulss   xmm8, dword ptr [rbx+0B700h]
000000018037B981  F3 0F 59 BB 70 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA70h]
000000018037B989  F3 44 0F 59 05 06 F3 60 00  mulss   xmm8, cs:dword_18098AC98
000000018037B992  F3 44 0F 59 83 40 BA 00 00  mulss   xmm8, dword ptr [rbx+0BA40h]
000000018037B99B  45 0F 2F C7                 comiss  xmm8, xmm15
000000018037B99F  73 06                       jnb     short loc_18037B9A7
000000018037B9A1  45 0F 28 C7                 movaps  xmm8, xmm15
000000018037B9A5  EB 05                       jmp     short loc_18037B9AC
000000018037B9A7  F3 45 0F 5D C5              minss   xmm8, xmm13
000000018037B9AC  F3 44 0F 59 83 F0 B9 00 00  mulss   xmm8, dword ptr [rbx+0B9F0h]
000000018037B9B5  F3 44 0F 59 8B D0 B6 00 00  mulss   xmm9, dword ptr [rbx+0B6D0h]
000000018037B9BE  F3 0F 10 B3 60 B6 00 00     movss   xmm6, dword ptr [rbx+0B660h]
000000018037B9C6  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037B9CA  F3 0F 10 AB 80 B6 00 00     movss   xmm5, dword ptr [rbx+0B680h]
000000018037B9D2  F3 41 0F 59 D0              mulss   xmm2, xmm8
000000018037B9D7  0F 28 C2                    movaps  xmm0, xmm2
000000018037B9DA  0F 28 DA                    movaps  xmm3, xmm2
000000018037B9DD  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037B9E1  0F 28 E2                    movaps  xmm4, xmm2
000000018037B9E4  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
000000018037B9EC  0F 28 CA                    movaps  xmm1, xmm2
000000018037B9EF  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037B9F7  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
000000018037B9FF  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018037BA04  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037BA0C  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037BA10  0F 28 C3                    movaps  xmm0, xmm3
000000018037BA13  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037BA1B  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037BA1F  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037BA23  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037BA27  F3 0F 10 83 60 B7 00 00     movss   xmm0, dword ptr [rbx+0B760h]
000000018037BA2F  F3 0F 59 83 C0 B6 00 00     mulss   xmm0, dword ptr [rbx+0B6C0h]
000000018037BA37  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037BA3B  F3 41 0F 58 C1              addss   xmm0, xmm9
000000018037BA40  F3 41 0F 58 E0              addss   xmm4, xmm8
000000018037BA45  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037BA49  F3 0F 59 A3 E0 B6 00 00     mulss   xmm4, dword ptr [rbx+0B6E0h]
000000018037BA51  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037BA55  F3 0F 11 A3 10 B8 00 00     movss   dword ptr [rbx+0B810h], xmm4
000000018037BA5D  F3 0F 11 B3 70 B6 00 00     movss   dword ptr [rbx+0B670h], xmm6
000000018037BA65  F3 0F 11 AB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm5
000000018037BA6D  F3 0F 58 B3 F0 B6 00 00     addss   xmm6, dword ptr [rbx+0B6F0h]
000000018037BA75  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037BA79  76 1B                       jbe     short loc_18037BA96
000000018037BA7B  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037BA80  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037BA84  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037BA87  E8 4C 3A 37 00              call    fmodf
000000018037BA8C  0F 28 F0                    movaps  xmm6, xmm0
000000018037BA8F  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037BA94  EB 1F                       jmp     short loc_18037BAB5
000000018037BA96  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037BA9A  73 19                       jnb     short loc_18037BAB5
000000018037BA9C  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037BAA1  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037BAA5  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037BAA8  E8 2B 3A 37 00              call    fmodf
000000018037BAAD  0F 28 F0                    movaps  xmm6, xmm0
000000018037BAB0  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037BAB5  0F 28 C6                    movaps  xmm0, xmm6
000000018037BAB8  F3 0F 11 B3 60 B6 00 00     movss   dword ptr [rbx+0B660h], xmm6
000000018037BAC0  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037BAC5  0F 28 FE                    movaps  xmm7, xmm6
000000018037BAC8  F3 0F 59 BB 50 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA50h]
000000018037BAD0  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018037BAD5  E8 E6 D4 FE FF              call    sub_180368FC0
000000018037BADA  0F 28 E8                    movaps  xmm5, xmm0
000000018037BADD  F3 41 0F 59 EB              mulss   xmm5, xmm11
000000018037BAE2  F3 0F 59 AB 00 B7 00 00     mulss   xmm5, dword ptr [rbx+0B700h]
000000018037BAEA  F3 0F 59 AB 20 BA 00 00     mulss   xmm5, dword ptr [rbx+0BA20h]
000000018037BAF2  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037BAF6  73 06                       jnb     short loc_18037BAFE
000000018037BAF8  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037BAFC  EB 05                       jmp     short loc_18037BB03
000000018037BAFE  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037BB03  F3 0F 59 AB F0 B9 00 00     mulss   xmm5, dword ptr [rbx+0B9F0h]
000000018037BB0B  0F 28 D5                    movaps  xmm2, xmm5
000000018037BB0E  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037BB12  0F 28 CA                    movaps  xmm1, xmm2
000000018037BB15  0F 28 C2                    movaps  xmm0, xmm2
000000018037BB18  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037BB20  0F 28 DA                    movaps  xmm3, xmm2
000000018037BB23  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037BB27  0F 28 E2                    movaps  xmm4, xmm2
000000018037BB2A  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
000000018037BB32  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037BB3A  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037BB3E  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
000000018037BB46  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037BB4A  0F 28 C3                    movaps  xmm0, xmm3
000000018037BB4D  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037BB55  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037BB59  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037BB5D  F3 0F 10 8B 10 B7 00 00     movss   xmm1, dword ptr [rbx+0B710h]
000000018037BB65  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037BB69  0F 28 C1                    movaps  xmm0, xmm1
000000018037BB6C  F3 0F 58 C6                 addss   xmm0, xmm6
000000018037BB70  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037BB74  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037BB78  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037BB7C  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037BB80  F3 0F 11 A3 60 B7 00 00     movss   dword ptr [rbx+0B760h], xmm4
000000018037BB88  72 07                       jb      short loc_18037BB91
000000018037BB8A  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018037BB8F  EB 05                       jmp     short loc_18037BB96
000000018037BB91  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037BB96  0F 28 F0                    movaps  xmm6, xmm0
000000018037BB99  73 06                       jnb     short loc_18037BBA1
000000018037BB9B  41 0F 28 F7                 movaps  xmm6, xmm15
000000018037BB9F  EB 06                       jmp     short loc_18037BBA7
000000018037BBA1  76 04                       jbe     short loc_18037BBA7
000000018037BBA3  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037BBA7  F3 44 0F 10 83 60 B6 00 00  movss   xmm8, dword ptr [rbx+0B660h]
000000018037BBB0  F3 0F 59 B3 60 BA 00 00     mulss   xmm6, dword ptr [rbx+0BA60h]
000000018037BBB8  F3 0F 5E C1                 divss   xmm0, xmm1
000000018037BBBC  E8 FF D3 FE FF              call    sub_180368FC0
000000018037BBC1  0F 28 E0                    movaps  xmm4, xmm0
000000018037BBC4  F3 0F 10 83 10 BA 00 00     movss   xmm0, dword ptr [rbx+0BA10h]
000000018037BBCC  44 0F 2F C0                 comiss  xmm8, xmm0
000000018037BBD0  72 18                       jb      short loc_18037BBEA
000000018037BBD2  0F 2F 83 70 B6 00 00        comiss  xmm0, dword ptr [rbx+0B670h]
000000018037BBD9  76 0F                       jbe     short loc_18037BBEA
000000018037BBDB  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
000000018037BBE3  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018037BBE8  EB 08                       jmp     short loc_18037BBF2
000000018037BBEA  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
000000018037BBF2  0F 2F 3D D7 96 76 00        comiss  xmm7, cs:dword_180AE52D0
000000018037BBF9  F3 0F 59 A3 00 B7 00 00     mulss   xmm4, dword ptr [rbx+0B700h]
000000018037BC01  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018037BC06  F3 0F 59 A3 30 BA 00 00     mulss   xmm4, dword ptr [rbx+0BA30h]
000000018037BC0E  72 03                       jb      short loc_18037BC13
000000018037BC10  0F 57 FF                    xorps   xmm7, xmm7
000000018037BC13  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037BC17  73 06                       jnb     short loc_18037BC1F
000000018037BC19  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037BC1D  EB 05                       jmp     short loc_18037BC24
000000018037BC1F  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037BC24  F3 0F 11 BB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm7
000000018037BC2C  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018037BC31  F3 0F 59 A3 F0 B9 00 00     mulss   xmm4, dword ptr [rbx+0B9F0h]
000000018037BC39  0F 28 D4                    movaps  xmm2, xmm4
000000018037BC3C  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037BC41  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037BC45  0F 28 C2                    movaps  xmm0, xmm2
000000018037BC48  F3 41 0F 59 FC              mulss   xmm7, xmm12
000000018037BC4D  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037BC51  0F 28 DA                    movaps  xmm3, xmm2
000000018037BC54  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037BC58  44 0F 28 CA                 movaps  xmm9, xmm2
000000018037BC5C  F3 44 0F 59 8B C0 BB 00 00  mulss   xmm9, dword ptr [rbx+0BBC0h]
000000018037BC65  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037BC6A  0F 28 CA                    movaps  xmm1, xmm2
000000018037BC6D  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037BC75  F3 44 0F 58 8B B0 BB 00 00  addss   xmm9, dword ptr [rbx+0BBB0h]
000000018037BC7E  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037BC86  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037BC8B  0F 28 C3                    movaps  xmm0, xmm3
000000018037BC8E  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037BC96  F3 44 0F 58 C9              addss   xmm9, xmm1
000000018037BC9B  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037BC9F  F3 44 0F 59 C8              mulss   xmm9, xmm0
000000018037BCA4  0F 28 C7                    movaps  xmm0, xmm7
000000018037BCA7  0F 54 05 E2 9A 76 00        andps   xmm0, cs:xmmword_180AE5790
000000018037BCAE  0F 57 05 0B 9B 76 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037BCB5  F3 44 0F 58 CB              addss   xmm9, xmm3
000000018037BCBA  F3 44 0F 58 CC              addss   xmm9, xmm4
000000018037BCBF  F3 44 0F 59 CE              mulss   xmm9, xmm6
000000018037BCC4  F3 44 0F 11 8B 70 B7 00 00  movss   dword ptr [rbx+0B770h], xmm9
000000018037BCCD  E8 EE D2 FE FF              call    sub_180368FC0
000000018037BCD2  41 0F 2F FE                 comiss  xmm7, xmm14
000000018037BCD6  44 0F 28 C0                 movaps  xmm8, xmm0
000000018037BCDA  F3 45 0F 58 C5              addss   xmm8, xmm13
000000018037BCDF  73 06                       jnb     short loc_18037BCE7
000000018037BCE1  41 0F 28 FF                 movaps  xmm7, xmm15
000000018037BCE5  EB 06                       jmp     short loc_18037BCED
000000018037BCE7  76 04                       jbe     short loc_18037BCED
000000018037BCE9  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037BCED  F3 44 0F 59 83 00 B7 00 00  mulss   xmm8, dword ptr [rbx+0B700h]
000000018037BCF6  F3 0F 59 BB 70 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA70h]
000000018037BCFE  F3 44 0F 59 05 91 EF 60 00  mulss   xmm8, cs:dword_18098AC98
000000018037BD07  F3 44 0F 59 83 40 BA 00 00  mulss   xmm8, dword ptr [rbx+0BA40h]
000000018037BD10  45 0F 2F C7                 comiss  xmm8, xmm15
000000018037BD14  73 06                       jnb     short loc_18037BD1C
000000018037BD16  45 0F 28 C7                 movaps  xmm8, xmm15
000000018037BD1A  EB 05                       jmp     short loc_18037BD21
000000018037BD1C  F3 45 0F 5D C5              minss   xmm8, xmm13
000000018037BD21  F3 44 0F 59 83 F0 B9 00 00  mulss   xmm8, dword ptr [rbx+0B9F0h]
000000018037BD2A  F3 44 0F 59 8B D0 B6 00 00  mulss   xmm9, dword ptr [rbx+0B6D0h]
000000018037BD33  F3 0F 10 B3 60 B6 00 00     movss   xmm6, dword ptr [rbx+0B660h]
000000018037BD3B  41 0F 28 D0                 movaps  xmm2, xmm8
000000018037BD3F  F3 0F 10 AB 80 B6 00 00     movss   xmm5, dword ptr [rbx+0B680h]
000000018037BD47  F3 41 0F 59 D0              mulss   xmm2, xmm8
000000018037BD4C  0F 28 C2                    movaps  xmm0, xmm2
000000018037BD4F  0F 28 DA                    movaps  xmm3, xmm2
000000018037BD52  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037BD56  0F 28 E2                    movaps  xmm4, xmm2
000000018037BD59  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
000000018037BD61  0F 28 CA                    movaps  xmm1, xmm2
000000018037BD64  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037BD6C  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
000000018037BD74  F3 41 0F 59 D8              mulss   xmm3, xmm8
000000018037BD79  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037BD81  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037BD85  0F 28 C3                    movaps  xmm0, xmm3
000000018037BD88  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037BD90  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037BD94  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037BD98  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037BD9C  F3 0F 10 83 60 B7 00 00     movss   xmm0, dword ptr [rbx+0B760h]
000000018037BDA4  F3 0F 59 83 C0 B6 00 00     mulss   xmm0, dword ptr [rbx+0B6C0h]
000000018037BDAC  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037BDB0  F3 41 0F 58 C1              addss   xmm0, xmm9
000000018037BDB5  F3 41 0F 58 E0              addss   xmm4, xmm8
000000018037BDBA  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037BDBE  F3 0F 59 A3 E0 B6 00 00     mulss   xmm4, dword ptr [rbx+0B6E0h]
000000018037BDC6  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037BDCA  F3 0F 11 A3 90 B8 00 00     movss   dword ptr [rbx+0B890h], xmm4
000000018037BDD2  F3 0F 11 B3 70 B6 00 00     movss   dword ptr [rbx+0B670h], xmm6
000000018037BDDA  F3 0F 11 AB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm5
000000018037BDE2  F3 0F 58 B3 F0 B6 00 00     addss   xmm6, dword ptr [rbx+0B6F0h]
000000018037BDEA  41 0F 2F F5                 comiss  xmm6, xmm13
000000018037BDEE  76 1B                       jbe     short loc_18037BE0B
000000018037BDF0  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037BDF5  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037BDF9  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037BDFC  E8 D7 36 37 00              call    fmodf
000000018037BE01  0F 28 F0                    movaps  xmm6, xmm0
000000018037BE04  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037BE09  EB 1F                       jmp     short loc_18037BE2A
000000018037BE0B  41 0F 2F F7                 comiss  xmm6, xmm15
000000018037BE0F  73 19                       jnb     short loc_18037BE2A
000000018037BE11  F3 41 0F 5C F5              subss   xmm6, xmm13
000000018037BE16  41 0F 28 CA                 movaps  xmm1, xmm10; Y
000000018037BE1A  0F 28 C6                    movaps  xmm0, xmm6; X
000000018037BE1D  E8 B6 36 37 00              call    fmodf
000000018037BE22  0F 28 F0                    movaps  xmm6, xmm0
000000018037BE25  F3 41 0F 58 F5              addss   xmm6, xmm13
000000018037BE2A  0F 28 C6                    movaps  xmm0, xmm6
000000018037BE2D  F3 0F 11 B3 60 B6 00 00     movss   dword ptr [rbx+0B660h], xmm6
000000018037BE35  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037BE3A  0F 28 FE                    movaps  xmm7, xmm6
000000018037BE3D  F3 0F 59 BB 50 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA50h]
000000018037BE45  F3 41 0F 59 C4              mulss   xmm0, xmm12
000000018037BE4A  E8 71 D1 FE FF              call    sub_180368FC0
000000018037BE4F  0F 28 E8                    movaps  xmm5, xmm0
000000018037BE52  F3 41 0F 59 EB              mulss   xmm5, xmm11
000000018037BE57  F3 0F 59 AB 00 B7 00 00     mulss   xmm5, dword ptr [rbx+0B700h]
000000018037BE5F  F3 0F 59 AB 20 BA 00 00     mulss   xmm5, dword ptr [rbx+0BA20h]
000000018037BE67  41 0F 2F EF                 comiss  xmm5, xmm15
000000018037BE6B  73 06                       jnb     short loc_18037BE73
000000018037BE6D  41 0F 28 EF                 movaps  xmm5, xmm15
000000018037BE71  EB 05                       jmp     short loc_18037BE78
000000018037BE73  F3 41 0F 5D ED              minss   xmm5, xmm13
000000018037BE78  F3 0F 59 AB F0 B9 00 00     mulss   xmm5, dword ptr [rbx+0B9F0h]
000000018037BE80  0F 28 D5                    movaps  xmm2, xmm5
000000018037BE83  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037BE87  0F 28 CA                    movaps  xmm1, xmm2
000000018037BE8A  0F 28 C2                    movaps  xmm0, xmm2
000000018037BE8D  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037BE95  0F 28 DA                    movaps  xmm3, xmm2
000000018037BE98  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037BE9C  0F 28 E2                    movaps  xmm4, xmm2
000000018037BE9F  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
000000018037BEA7  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037BEAF  F3 0F 59 DD                 mulss   xmm3, xmm5
000000018037BEB3  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
000000018037BEBB  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037BEBF  0F 28 C3                    movaps  xmm0, xmm3
000000018037BEC2  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037BECA  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037BECE  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037BED2  F3 0F 10 8B 10 B7 00 00     movss   xmm1, dword ptr [rbx+0B710h]
000000018037BEDA  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037BEDE  0F 28 C1                    movaps  xmm0, xmm1
000000018037BEE1  F3 0F 58 C6                 addss   xmm0, xmm6
000000018037BEE5  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037BEE9  41 0F 2F C6                 comiss  xmm0, xmm14
000000018037BEED  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037BEF1  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037BEF5  F3 0F 11 A3 60 B7 00 00     movss   dword ptr [rbx+0B760h], xmm4
000000018037BEFD  72 07                       jb      short loc_18037BF06
000000018037BEFF  F3 41 0F 58 CD              addss   xmm1, xmm13
000000018037BF04  EB 05                       jmp     short loc_18037BF0B
000000018037BF06  F3 41 0F 5C CD              subss   xmm1, xmm13
000000018037BF0B  0F 28 F0                    movaps  xmm6, xmm0
000000018037BF0E  73 06                       jnb     short loc_18037BF16
000000018037BF10  41 0F 28 F7                 movaps  xmm6, xmm15
000000018037BF14  EB 06                       jmp     short loc_18037BF1C
000000018037BF16  76 04                       jbe     short loc_18037BF1C
000000018037BF18  41 0F 28 F5                 movaps  xmm6, xmm13
000000018037BF1C  F3 44 0F 10 83 60 B6 00 00  movss   xmm8, dword ptr [rbx+0B660h]
000000018037BF25  F3 0F 59 B3 60 BA 00 00     mulss   xmm6, dword ptr [rbx+0BA60h]
000000018037BF2D  F3 0F 5E C1                 divss   xmm0, xmm1
000000018037BF31  E8 8A D0 FE FF              call    sub_180368FC0
000000018037BF36  0F 28 E0                    movaps  xmm4, xmm0
000000018037BF39  F3 0F 10 83 10 BA 00 00     movss   xmm0, dword ptr [rbx+0BA10h]
000000018037BF41  44 0F 2F C0                 comiss  xmm8, xmm0
000000018037BF45  72 18                       jb      short loc_18037BF5F
000000018037BF47  0F 2F 83 70 B6 00 00        comiss  xmm0, dword ptr [rbx+0B670h]
000000018037BF4E  76 0F                       jbe     short loc_18037BF5F
000000018037BF50  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
000000018037BF58  F3 41 0F 58 FA              addss   xmm7, xmm10
000000018037BF5D  EB 08                       jmp     short loc_18037BF67
000000018037BF5F  F3 0F 10 BB 80 B6 00 00     movss   xmm7, dword ptr [rbx+0B680h]
000000018037BF67  0F 2F 3D 62 93 76 00        comiss  xmm7, cs:dword_180AE52D0
000000018037BF6E  F3 0F 59 A3 00 B7 00 00     mulss   xmm4, dword ptr [rbx+0B700h]
000000018037BF76  F3 41 0F 59 E3              mulss   xmm4, xmm11
000000018037BF7B  F3 0F 59 A3 30 BA 00 00     mulss   xmm4, dword ptr [rbx+0BA30h]
000000018037BF83  72 03                       jb      short loc_18037BF88
000000018037BF85  0F 57 FF                    xorps   xmm7, xmm7
000000018037BF88  41 0F 2F E7                 comiss  xmm4, xmm15
000000018037BF8C  73 06                       jnb     short loc_18037BF94
000000018037BF8E  41 0F 28 E7                 movaps  xmm4, xmm15
000000018037BF92  EB 05                       jmp     short loc_18037BF99
000000018037BF94  F3 41 0F 5D E5              minss   xmm4, xmm13
000000018037BF99  F3 0F 11 BB 80 B6 00 00     movss   dword ptr [rbx+0B680h], xmm7
000000018037BFA1  F3 41 0F 58 F8              addss   xmm7, xmm8
000000018037BFA6  F3 0F 59 A3 F0 B9 00 00     mulss   xmm4, dword ptr [rbx+0B9F0h]
000000018037BFAE  0F 28 D4                    movaps  xmm2, xmm4
000000018037BFB1  F3 41 0F 58 FD              addss   xmm7, xmm13
000000018037BFB6  F3 0F 59 D4                 mulss   xmm2, xmm4
000000018037BFBA  0F 28 C2                    movaps  xmm0, xmm2
000000018037BFBD  F3 41 0F 59 FC              mulss   xmm7, xmm12
000000018037BFC2  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037BFC6  0F 28 DA                    movaps  xmm3, xmm2
000000018037BFC9  F3 0F 59 DC                 mulss   xmm3, xmm4
000000018037BFCD  44 0F 28 C2                 movaps  xmm8, xmm2
000000018037BFD1  F3 44 0F 59 83 C0 BB 00 00  mulss   xmm8, dword ptr [rbx+0BBC0h]
000000018037BFDA  F3 41 0F 5C FD              subss   xmm7, xmm13
000000018037BFDF  0F 28 CA                    movaps  xmm1, xmm2
000000018037BFE2  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037BFEA  F3 44 0F 58 83 B0 BB 00 00  addss   xmm8, dword ptr [rbx+0BBB0h]
000000018037BFF3  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037BFFB  F3 44 0F 59 C0              mulss   xmm8, xmm0
000000018037C000  0F 28 C3                    movaps  xmm0, xmm3
000000018037C003  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037C00B  F3 44 0F 58 C1              addss   xmm8, xmm1
000000018037C010  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037C014  F3 44 0F 59 C0              mulss   xmm8, xmm0
000000018037C019  0F 28 C7                    movaps  xmm0, xmm7
000000018037C01C  0F 54 05 6D 97 76 00        andps   xmm0, cs:xmmword_180AE5790
000000018037C023  0F 57 05 96 97 76 00        xorps   xmm0, cs:xmmword_180AE57C0
000000018037C02A  F3 44 0F 58 C3              addss   xmm8, xmm3
000000018037C02F  F3 44 0F 58 C4              addss   xmm8, xmm4
000000018037C034  F3 44 0F 59 C6              mulss   xmm8, xmm6
000000018037C039  F3 44 0F 11 83 70 B7 00 00  movss   dword ptr [rbx+0B770h], xmm8
000000018037C042  E8 79 CF FE FF              call    sub_180368FC0
000000018037C047  41 0F 2F FE                 comiss  xmm7, xmm14
000000018037C04B  F3 41 0F 58 C5              addss   xmm0, xmm13
000000018037C050  73 06                       jnb     short loc_18037C058
000000018037C052  41 0F 28 FF                 movaps  xmm7, xmm15
000000018037C056  EB 06                       jmp     short loc_18037C05E
000000018037C058  76 04                       jbe     short loc_18037C05E
000000018037C05A  41 0F 28 FD                 movaps  xmm7, xmm13
000000018037C05E  F3 0F 59 83 00 B7 00 00     mulss   xmm0, dword ptr [rbx+0B700h]
000000018037C066  F3 0F 59 BB 70 BA 00 00     mulss   xmm7, dword ptr [rbx+0BA70h]
000000018037C06E  F3 0F 59 05 22 EC 60 00     mulss   xmm0, cs:dword_18098AC98
000000018037C076  F3 0F 59 83 40 BA 00 00     mulss   xmm0, dword ptr [rbx+0BA40h]
000000018037C07E  41 0F 2F C7                 comiss  xmm0, xmm15
000000018037C082  72 09                       jb      short loc_18037C08D
000000018037C084  44 0F 28 F8                 movaps  xmm15, xmm0
000000018037C088  F3 45 0F 5D FD              minss   xmm15, xmm13
000000018037C08D  F3 44 0F 59 BB F0 B9 00 00  mulss   xmm15, dword ptr [rbx+0B9F0h]
000000018037C096  F3 44 0F 59 83 D0 B6 00 00  mulss   xmm8, dword ptr [rbx+0B6D0h]
000000018037C09F  F3 0F 10 AB 60 B6 00 00     movss   xmm5, dword ptr [rbx+0B660h]
000000018037C0A7  41 0F 28 D7                 movaps  xmm2, xmm15
000000018037C0AB  F3 0F 10 B3 80 B6 00 00     movss   xmm6, dword ptr [rbx+0B680h]
000000018037C0B3  F3 41 0F 59 D7              mulss   xmm2, xmm15
000000018037C0B8  0F 28 CA                    movaps  xmm1, xmm2
000000018037C0BB  0F 28 C2                    movaps  xmm0, xmm2
000000018037C0BE  F3 0F 59 8B A0 BB 00 00     mulss   xmm1, dword ptr [rbx+0BBA0h]
000000018037C0C6  0F 28 DA                    movaps  xmm3, xmm2
000000018037C0C9  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037C0CD  0F 28 E2                    movaps  xmm4, xmm2
000000018037C0D0  F3 0F 58 8B 90 BB 00 00     addss   xmm1, dword ptr [rbx+0BB90h]
000000018037C0D8  F3 0F 59 A3 C0 BB 00 00     mulss   xmm4, dword ptr [rbx+0BBC0h]
000000018037C0E0  F3 41 0F 59 DF              mulss   xmm3, xmm15
000000018037C0E5  F3 0F 58 A3 B0 BB 00 00     addss   xmm4, dword ptr [rbx+0BBB0h]
000000018037C0ED  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037C0F1  0F 28 C3                    movaps  xmm0, xmm3
000000018037C0F4  F3 0F 59 9B 80 BB 00 00     mulss   xmm3, dword ptr [rbx+0BB80h]
000000018037C0FC  F3 0F 59 C2                 mulss   xmm0, xmm2
000000018037C100  F3 0F 58 E1                 addss   xmm4, xmm1
000000018037C104  F3 0F 59 E0                 mulss   xmm4, xmm0
000000018037C108  F3 0F 10 83 60 B7 00 00     movss   xmm0, dword ptr [rbx+0B760h]
000000018037C110  F3 0F 59 83 C0 B6 00 00     mulss   xmm0, dword ptr [rbx+0B6C0h]
000000018037C118  F3 0F 58 E3                 addss   xmm4, xmm3
000000018037C11C  F3 41 0F 58 C0              addss   xmm0, xmm8
000000018037C121  F3 41 0F 58 E7              addss   xmm4, xmm15
000000018037C126  F3 0F 59 E7                 mulss   xmm4, xmm7
000000018037C12A  F3 0F 59 A3 E0 B6 00 00     mulss   xmm4, dword ptr [rbx+0B6E0h]
000000018037C132  F3 0F 58 E0                 addss   xmm4, xmm0
000000018037C136  F3 0F 11 A3 10 B9 00 00     movss   dword ptr [rbx+0B910h], xmm4
000000018037C13E  F3 0F 10 93 80 B9 00 00     movss   xmm2, dword ptr [rbx+0B980h]
000000018037C146  F3 0F 11 AB 40 B7 00 00     movss   dword ptr [rbx+0B740h], xmm5
000000018037C14E  F3 0F 11 B3 20 B7 00 00     movss   dword ptr [rbx+0B720h], xmm6
000000018037C156  F3 0F 10 83 90 B8 00 00     movss   xmm0, dword ptr [rbx+0B890h]
000000018037C15E  F3 0F 58 83 80 B8 00 00     addss   xmm0, dword ptr [rbx+0B880h]
000000018037C166  F3 0F 10 8B 10 B9 00 00     movss   xmm1, dword ptr [rbx+0B910h]
000000018037C16E  F3 0F 58 8B 00 B8 00 00     addss   xmm1, dword ptr [rbx+0B800h]
000000018037C176  F3 0F 10 AB 00 B9 00 00     movss   xmm5, dword ptr [rbx+0B900h]
000000018037C17E  F3 0F 58 AB 10 B8 00 00     addss   xmm5, dword ptr [rbx+0B810h]
000000018037C186  F3 0F 59 83 A0 BA 00 00     mulss   xmm0, dword ptr [rbx+0BAA0h]
000000018037C18E  F3 0F 59 8B B0 BA 00 00     mulss   xmm1, dword ptr [rbx+0BAB0h]
000000018037C196  F3 0F 59 AB 90 BA 00 00     mulss   xmm5, dword ptr [rbx+0BA90h]
000000018037C19E  F3 0F 58 93 90 B7 00 00     addss   xmm2, dword ptr [rbx+0B790h]
000000018037C1A6  F3 0F 59 93 80 BA 00 00     mulss   xmm2, dword ptr [rbx+0BA80h]
000000018037C1AE  F3 0F 58 EA                 addss   xmm5, xmm2
000000018037C1B2  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037C1B6  F3 0F 10 83 70 B9 00 00     movss   xmm0, dword ptr [rbx+0B970h]
000000018037C1BE  F3 0F 58 83 A0 B7 00 00     addss   xmm0, dword ptr [rbx+0B7A0h]
000000018037C1C6  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037C1CA  F3 0F 10 8B F0 B8 00 00     movss   xmm1, dword ptr [rbx+0B8F0h]
000000018037C1D2  F3 0F 59 83 C0 BA 00 00     mulss   xmm0, dword ptr [rbx+0BAC0h]
000000018037C1DA  F3 0F 58 8B 20 B8 00 00     addss   xmm1, dword ptr [rbx+0B820h]
000000018037C1E2  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037C1E6  F3 0F 10 83 A0 B8 00 00     movss   xmm0, dword ptr [rbx+0B8A0h]
000000018037C1EE  F3 0F 58 83 70 B8 00 00     addss   xmm0, dword ptr [rbx+0B870h]
000000018037C1F6  F3 0F 59 8B D0 BA 00 00     mulss   xmm1, dword ptr [rbx+0BAD0h]
000000018037C1FE  F3 0F 59 83 E0 BA 00 00     mulss   xmm0, dword ptr [rbx+0BAE0h]
000000018037C206  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037C20A  F3 0F 10 8B 20 B9 00 00     movss   xmm1, dword ptr [rbx+0B920h]
000000018037C212  F3 0F 58 8B F0 B7 00 00     addss   xmm1, dword ptr [rbx+0B7F0h]
000000018037C21A  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037C21E  F3 0F 10 83 60 B9 00 00     movss   xmm0, dword ptr [rbx+0B960h]
000000018037C226  F3 0F 59 8B F0 BA 00 00     mulss   xmm1, dword ptr [rbx+0BAF0h]
000000018037C22E  F3 0F 58 83 B0 B7 00 00     addss   xmm0, dword ptr [rbx+0B7B0h]
000000018037C236  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037C23A  F3 0F 10 8B 30 B8 00 00     movss   xmm1, dword ptr [rbx+0B830h]
000000018037C242  F3 0F 58 8B E0 B8 00 00     addss   xmm1, dword ptr [rbx+0B8E0h]
000000018037C24A  F3 0F 59 83 00 BB 00 00     mulss   xmm0, dword ptr [rbx+0BB00h]
000000018037C252  F3 0F 59 8B 10 BB 00 00     mulss   xmm1, dword ptr [rbx+0BB10h]
000000018037C25A  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037C25E  F3 0F 10 83 B0 B8 00 00     movss   xmm0, dword ptr [rbx+0B8B0h]
000000018037C266  F3 0F 58 83 60 B8 00 00     addss   xmm0, dword ptr [rbx+0B860h]
000000018037C26E  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037C272  F3 0F 10 8B E0 B7 00 00     movss   xmm1, dword ptr [rbx+0B7E0h]
000000018037C27A  F3 0F 59 83 20 BB 00 00     mulss   xmm0, dword ptr [rbx+0BB20h]
000000018037C282  F3 0F 58 8B 30 B9 00 00     addss   xmm1, dword ptr [rbx+0B930h]
000000018037C28A  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037C28E  F3 0F 10 83 50 B9 00 00     movss   xmm0, dword ptr [rbx+0B950h]
000000018037C296  F3 0F 59 8B 30 BB 00 00     mulss   xmm1, dword ptr [rbx+0BB30h]
000000018037C29E  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037C2A2  F3 0F 58 83 C0 B7 00 00     addss   xmm0, dword ptr [rbx+0B7C0h]
000000018037C2AA  F3 0F 10 93 B0 B9 00 00     movss   xmm2, dword ptr [rbx+0B9B0h]
000000018037C2B2  F3 0F 10 8B D0 B8 00 00     movss   xmm1, dword ptr [rbx+0B8D0h]
000000018037C2BA  0F 28 E2                    movaps  xmm4, xmm2
000000018037C2BD  F3 0F 59 A3 B0 BC 00 00     mulss   xmm4, dword ptr [rbx+0BCB0h]
000000018037C2C5  F3 0F 59 83 40 BB 00 00     mulss   xmm0, dword ptr [rbx+0BB40h]
000000018037C2CD  F3 0F 58 A3 C0 B9 00 00     addss   xmm4, dword ptr [rbx+0B9C0h]
000000018037C2D5  F3 0F 58 8B 40 B8 00 00     addss   xmm1, dword ptr [rbx+0B840h]
000000018037C2DD  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037C2E1  F3 0F 10 83 C0 B8 00 00     movss   xmm0, dword ptr [rbx+0B8C0h]
000000018037C2E9  F3 0F 58 83 50 B8 00 00     addss   xmm0, dword ptr [rbx+0B850h]
000000018037C2F1  F3 0F 59 8B 50 BB 00 00     mulss   xmm1, dword ptr [rbx+0BB50h]
000000018037C2F9  F3 0F 59 83 60 BB 00 00     mulss   xmm0, dword ptr [rbx+0BB60h]
000000018037C301  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037C305  F3 0F 10 8B 40 B9 00 00     movss   xmm1, dword ptr [rbx+0B940h]
000000018037C30D  F3 0F 58 8B D0 B7 00 00     addss   xmm1, dword ptr [rbx+0B7D0h]
000000018037C315  F3 0F 58 E8                 addss   xmm5, xmm0
000000018037C319  0F 28 C2                    movaps  xmm0, xmm2
000000018037C31C  F3 0F 59 8B 70 BB 00 00     mulss   xmm1, dword ptr [rbx+0BB70h]
000000018037C324  F3 0F 11 A3 B0 B9 00 00     movss   dword ptr [rbx+0B9B0h], xmm4
000000018037C32C  F3 0F 59 83 C0 BC 00 00     mulss   xmm0, dword ptr [rbx+0BCC0h]
000000018037C334  F3 0F 58 E9                 addss   xmm5, xmm1
000000018037C338  F3 0F 58 C4                 addss   xmm0, xmm4
000000018037C33C  0F 28 DD                    movaps  xmm3, xmm5
000000018037C33F  F3 0F 5C D8                 subss   xmm3, xmm0
000000018037C343  0F 28 C3                    movaps  xmm0, xmm3
000000018037C346  F3 0F 59 83 B0 BC 00 00     mulss   xmm0, dword ptr [rbx+0BCB0h]
000000018037C34E  F3 0F 58 C2                 addss   xmm0, xmm2
000000018037C352  F3 0F 11 83 A0 B9 00 00     movss   dword ptr [rbx+0B9A0h], xmm0
000000018037C35A  F3 0F 10 93 00 BD 00 00     movss   xmm2, dword ptr [rbx+0BD00h]
000000018037C362  F3 0F 59 9B 90 B9 00 00     mulss   xmm3, dword ptr [rbx+0B990h]
000000018037C36A  F3 0F 5C E3                 subss   xmm4, xmm3
000000018037C36E  F3 0F 59 E2                 mulss   xmm4, xmm2
000000018037C372  F3 0F 59 D5                 mulss   xmm2, xmm5
000000018037C376  F3 0F 5C E2                 subss   xmm4, xmm2
000000018037C37A  F3 0F 58 E5                 addss   xmm4, xmm5
000000018037C37E  F3 0F 11 A3 80 B7 00 00     movss   dword ptr [rbx+0B780h], xmm4
000000018037C386  F3 0F 11 A3 00 B2 00 00     movss   dword ptr [rbx+0B200h], xmm4
000000018037C38E  44 0F 2E AB 00 8D 01 00     ucomiss xmm13, dword ptr [rbx+18D00h]
000000018037C396  75 28                       jnz     short loc_18037C3C0
000000018037C398  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
000000018037C3A1  F3 0F 11 83 80 A5 00 00     movss   dword ptr [rbx+0A580h], xmm0
000000018037C3A9  C7 83 00 8D 01 00 00 00 00 00  mov     dword ptr [rbx+18D00h], 0
000000018037C3B3  0F 1F 40 00                 nop     dword ptr [rax+00h]
000000018037C3B7  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
000000018037C3C0  8B 83 F0 CD 00 00           mov     eax, [rbx+0CDF0h]
000000018037C3C6  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
000000018037C3CE  48 8B 0F                    mov     rcx, [rdi]
000000018037C3D1  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
000000018037C3D6  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
000000018037C3DB  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
000000018037C3E0  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
000000018037C3E5  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
000000018037C3EA  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
000000018037C3EF  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
000000018037C3F4  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
000000018037C3F9  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
000000018037C3FF  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
000000018037C405  89 01                       mov     [rcx], eax
000000018037C407  8B 83 F0 CD 00 00           mov     eax, [rbx+0CDF0h]
000000018037C40D  48 8B 4F 08                 mov     rcx, [rdi+8]
000000018037C411  49 8B 5B 18                 mov     rbx, [r11+18h]
000000018037C415  89 01                       mov     [rcx], eax
000000018037C417  49 8B E3                    mov     rsp, r11
000000018037C41A  5F                          pop     rdi
000000018037C41B  C3                          retn
