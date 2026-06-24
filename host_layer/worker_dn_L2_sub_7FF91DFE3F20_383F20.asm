; sub_7FF91DFE3F20 @ rva 0x383F20

00007FF91DFE3F20  48 8B C4                    mov     rax, rsp
00007FF91DFE3F23  48 89 58 10                 mov     [rax+10h], rbx
00007FF91DFE3F27  57                          push    rdi
00007FF91DFE3F28  48 81 EC C0 00 00 00        sub     rsp, 0C0h
00007FF91DFE3F2F  F3 0F 10 A1 B0 20 01 00     movss   xmm4, dword ptr [rcx+120B0h]
00007FF91DFE3F37  48 8B FA                    mov     rdi, rdx
00007FF91DFE3F3A  0F 29 70 E8                 movaps  xmmword ptr [rax-18h], xmm6
00007FF91DFE3F3E  48 8B D9                    mov     rbx, rcx
00007FF91DFE3F41  0F 29 78 D8                 movaps  xmmword ptr [rax-28h], xmm7
00007FF91DFE3F45  44 0F 29 40 C8              movaps  xmmword ptr [rax-38h], xmm8
00007FF91DFE3F4A  44 0F 29 48 B8              movaps  xmmword ptr [rax-48h], xmm9
00007FF91DFE3F4F  44 0F 29 50 A8              movaps  xmmword ptr [rax-58h], xmm10
00007FF91DFE3F54  44 0F 29 58 98              movaps  xmmword ptr [rax-68h], xmm11
00007FF91DFE3F59  44 0F 29 60 88              movaps  xmmword ptr [rax-78h], xmm12
00007FF91DFE3F5E  44 0F 29 6C 24 40           movaps  [rsp+0C8h+var_88], xmm13
00007FF91DFE3F64  F3 44 0F 10 2D 47 11 76 00  movss   xmm13, cs:dword_7FF91E7450B4
00007FF91DFE3F6D  44 0F 2E A9 60 8D 01 00     ucomiss xmm13, dword ptr [rcx+18D60h]
00007FF91DFE3F75  44 0F 29 74 24 30           movaps  [rsp+0C8h+var_98], xmm14
00007FF91DFE3F7B  45 0F 57 F6                 xorps   xmm14, xmm14
00007FF91DFE3F7F  F3 44 0F 11 B4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm14
00007FF91DFE3F89  44 0F 29 7C 24 20           movaps  [rsp+0C8h+var_A8], xmm15
00007FF91DFE3F8F  75 16                       jnz     short loc_7FF91DFE3FA7
00007FF91DFE3F91  F3 0F 11 A4 24 D0 00 00 00  movss   [rsp+0C8h+arg_0], xmm4
00007FF91DFE3F9A  0F 57 E4                    xorps   xmm4, xmm4
00007FF91DFE3F9D  C7 81 B0 20 01 00 00 00 00 00  mov     dword ptr [rcx+120B0h], 0
00007FF91DFE3FA7  F3 0F 10 81 70 49 01 00     movss   xmm0, dword ptr [rcx+14970h]
00007FF91DFE3FAF  F3 0F 10 89 30 49 01 00     movss   xmm1, dword ptr [rcx+14930h]
00007FF91DFE3FB7  F3 0F 10 91 50 49 01 00     movss   xmm2, dword ptr [rcx+14950h]
00007FF91DFE3FBF  F3 0F 11 81 80 49 01 00     movss   dword ptr [rcx+14980h], xmm0
00007FF91DFE3FC7  F3 0F 59 05 F5 6D 60 00     mulss   xmm0, cs:dword_7FF91E5EADC4
00007FF91DFE3FCF  F3 0F 11 89 40 49 01 00     movss   dword ptr [rcx+14940h], xmm1
00007FF91DFE3FD7  F3 0F 11 91 60 49 01 00     movss   dword ptr [rcx+14960h], xmm2
00007FF91DFE3FDF  F3 0F 2C D0                 cvttss2si edx, xmm0
00007FF91DFE3FE3  85 D2                       test    edx, edx
00007FF91DFE3FE5  75 07                       jnz     short loc_7FF91DFE3FEE
00007FF91DFE3FE7  BA 01 00 00 00              mov     edx, 1
00007FF91DFE3FEC  EB 24                       jmp     short loc_7FF91DFE4012
00007FF91DFE3FEE  8B C2                       mov     eax, edx
00007FF91DFE3FF0  25 00 00 20 00              and     eax, 200000h
00007FF91DFE3FF5  0F BA E2 17                 bt      edx, 17h
00007FF91DFE3FF9  73 08                       jnb     short loc_7FF91DFE4003
00007FF91DFE3FFB  85 C0                       test    eax, eax
00007FF91DFE3FFD  75 0C                       jnz     short loc_7FF91DFE400B
00007FF91DFE3FFF  03 D2                       add     edx, edx
00007FF91DFE4001  EB 0F                       jmp     short loc_7FF91DFE4012
00007FF91DFE4003  85 C0                       test    eax, eax
00007FF91DFE4005  74 04                       jz      short loc_7FF91DFE400B
00007FF91DFE4007  03 D2                       add     edx, edx
00007FF91DFE4009  EB 07                       jmp     short loc_7FF91DFE4012
00007FF91DFE400B  8D 14 55 01 00 00 00        lea     edx, ds:1[rdx*2]
00007FF91DFE4012  F3 0F 10 9B 40 20 01 00     movss   xmm3, dword ptr [rbx+12040h]
00007FF91DFE401A  8B C2                       mov     eax, edx
00007FF91DFE401C  F3 0F 10 B3 20 20 01 00     movss   xmm6, dword ptr [rbx+12020h]
00007FF91DFE4024  25 FF FF FF 00              and     eax, 0FFFFFFh
00007FF91DFE4029  F3 44 0F 10 83 E0 20 01 00  movss   xmm8, dword ptr [rbx+120E0h]
00007FF91DFE4032  8B CA                       mov     ecx, edx
00007FF91DFE4034  F3 0F 10 BB F0 20 01 00     movss   xmm7, dword ptr [rbx+120F0h]
00007FF91DFE403C  81 CA 00 00 00 FF           or      edx, 0FF000000h
00007FF91DFE4042  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFE4046  81 E1 00 00 00 01           and     ecx, 1000000h
00007FF91DFE404C  C7 83 20 21 01 00 00 00 00 00  mov     dword ptr [rbx+12120h], 0
00007FF91DFE4056  F3 0F 11 9B 50 20 01 00     movss   dword ptr [rbx+12050h], xmm3
00007FF91DFE405E  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFE4062  0F 44 D0                    cmovz   edx, eax
00007FF91DFE4065  F3 0F 11 B3 30 20 01 00     movss   dword ptr [rbx+12030h], xmm6
00007FF91DFE406D  8B 83 90 49 01 00           mov     eax, [rbx+14990h]
00007FF91DFE4073  89 83 A0 49 01 00           mov     [rbx+149A0h], eax
00007FF91DFE4079  8B 83 60 21 01 00           mov     eax, [rbx+12160h]
00007FF91DFE407F  66 0F 6E C2                 movd    xmm0, edx
00007FF91DFE4083  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFE4086  89 83 70 21 01 00           mov     [rbx+12170h], eax
00007FF91DFE408C  F3 0F 11 A3 D0 20 01 00     movss   dword ptr [rbx+120D0h], xmm4
00007FF91DFE4094  F3 0F 59 05 D4 6B 60 00     mulss   xmm0, cs:dword_7FF91E5EAC70
00007FF91DFE409C  F3 44 0F 11 83 00 21 01 00  movss   dword ptr [rbx+12100h], xmm8
00007FF91DFE40A5  F3 0F 11 BB 10 21 01 00     movss   dword ptr [rbx+12110h], xmm7
00007FF91DFE40AD  F3 0F 11 83 70 49 01 00     movss   dword ptr [rbx+14970h], xmm0
00007FF91DFE40B5  F3 0F 59 83 B0 49 01 00     mulss   xmm0, dword ptr [rbx+149B0h]
00007FF91DFE40BD  F3 0F 58 83 C0 49 01 00     addss   xmm0, dword ptr [rbx+149C0h]
00007FF91DFE40C5  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFE40C9  F3 0F 11 83 90 49 01 00     movss   dword ptr [rbx+14990h], xmm0
00007FF91DFE40D1  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFE40D5  F3 0F 10 93 80 20 01 00     movss   xmm2, dword ptr [rbx+12080h]
00007FF91DFE40DD  F3 0F 11 93 90 20 01 00     movss   dword ptr [rbx+12090h], xmm2
00007FF91DFE40E5  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE40E9  F3 0F 10 83 60 20 01 00     movss   xmm0, dword ptr [rbx+12060h]
00007FF91DFE40F1  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFE40F5  F3 0F 11 83 70 20 01 00     movss   dword ptr [rbx+12070h], xmm0
00007FF91DFE40FD  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFE4101  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE4104  F3 0F 11 8B D0 49 01 00     movss   dword ptr [rbx+149D0h], xmm1
00007FF91DFE410C  F3 0F 10 8B A0 20 01 00     movss   xmm1, dword ptr [rbx+120A0h]
00007FF91DFE4114  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE4118  F3 0F 59 F2                 mulss   xmm6, xmm2
00007FF91DFE411C  F3 0F 11 8B C0 20 01 00     movss   dword ptr [rbx+120C0h], xmm1
00007FF91DFE4124  F3 0F 11 93 30 21 01 00     movss   dword ptr [rbx+12130h], xmm2
00007FF91DFE412C  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFE4130  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFE4133  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE4137  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE413B  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFE413F  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFE4143  F3 0F 11 B3 40 21 01 00     movss   dword ptr [rbx+12140h], xmm6
00007FF91DFE414B  F3 0F 11 9B 50 21 01 00     movss   dword ptr [rbx+12150h], xmm3
00007FF91DFE4153  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE4156  F3 0F 58 9B 90 21 01 00     addss   xmm3, dword ptr [rbx+12190h]
00007FF91DFE415E  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFE4162  72 05                       jb      short loc_7FF91DFE4169
00007FF91DFE4164  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE4167  EB 03                       jmp     short loc_7FF91DFE416C
00007FF91DFE4169  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFE416C  41 0F 2E CE                 ucomiss xmm1, xmm14
00007FF91DFE4170  F3 44 0F 10 3D 6B 13 76 00  movss   xmm15, cs:dword_7FF91E7454E4
00007FF91DFE4179  75 06                       jnz     short loc_7FF91DFE4181
00007FF91DFE417B  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE417F  EB 04                       jmp     short loc_7FF91DFE4185
00007FF91DFE4181  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFE4185  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFE4189  F3 0F 11 AB 60 21 01 00     movss   dword ptr [rbx+12160h], xmm5
00007FF91DFE4191  73 06                       jnb     short loc_7FF91DFE4199
00007FF91DFE4193  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE4197  EB 06                       jmp     short loc_7FF91DFE419F
00007FF91DFE4199  76 04                       jbe     short loc_7FF91DFE419F
00007FF91DFE419B  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFE419F  F3 0F 10 83 D0 21 01 00     movss   xmm0, dword ptr [rbx+121D0h]
00007FF91DFE41A7  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFE41AC  F3 0F 10 93 70 22 01 00     movss   xmm2, dword ptr [rbx+12270h]
00007FF91DFE41B4  F3 0F 10 8B E0 21 01 00     movss   xmm1, dword ptr [rbx+121E0h]
00007FF91DFE41BC  8B 83 A0 21 01 00           mov     eax, [rbx+121A0h]
00007FF91DFE41C2  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFE41C5  F3 0F 10 A3 30 22 01 00     movss   xmm4, dword ptr [rbx+12230h]
00007FF91DFE41CD  F3 0F 58 9B 80 22 01 00     addss   xmm3, dword ptr [rbx+12280h]
00007FF91DFE41D5  F2 44 0F 10 25 C2 0F 76 00  movsd   xmm12, cs:dbl_7FF91E7451A0
00007FF91DFE41DE  F3 0F 11 AB 80 21 01 00     movss   dword ptr [rbx+12180h], xmm5
00007FF91DFE41E6  F3 0F 11 AB A0 21 01 00     movss   dword ptr [rbx+121A0h], xmm5
00007FF91DFE41EE  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFE41F2  89 83 B0 21 01 00           mov     [rbx+121B0h], eax
00007FF91DFE41F8  F3 0F 11 A3 40 22 01 00     movss   dword ptr [rbx+12240h], xmm4
00007FF91DFE4200  F3 0F 5C E8                 subss   xmm5, xmm0
00007FF91DFE4204  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE4207  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE420B  F3 0F 10 8B 10 22 01 00     movss   xmm1, dword ptr [rbx+12210h]
00007FF91DFE4213  F3 0F 58 83 90 22 01 00     addss   xmm0, dword ptr [rbx+12290h]
00007FF91DFE421B  F3 41 0F 58 ED              addss   xmm5, xmm13
00007FF91DFE4220  F3 0F 5E C8                 divss   xmm1, xmm0
00007FF91DFE4224  F3 0F 10 83 A0 22 01 00     movss   xmm0, dword ptr [rbx+122A0h]
00007FF91DFE422C  F3 0F 59 AB C0 21 01 00     mulss   xmm5, dword ptr [rbx+121C0h]
00007FF91DFE4234  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFE4238  F3 0F 10 93 00 22 01 00     movss   xmm2, dword ptr [rbx+12200h]
00007FF91DFE4240  F3 0F 11 AB 50 22 01 00     movss   dword ptr [rbx+12250h], xmm5
00007FF91DFE4248  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFE424C  F3 0F 10 8B 20 22 01 00     movss   xmm1, dword ptr [rbx+12220h]
00007FF91DFE4254  F3 0F 58 D6                 addss   xmm2, xmm6
00007FF91DFE4258  F3 0F 5C D4                 subss   xmm2, xmm4
00007FF91DFE425C  F3 0F 11 93 00 22 01 00     movss   dword ptr [rbx+12200h], xmm2
00007FF91DFE4264  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE4268  F3 0F 11 93 10 22 01 00     movss   dword ptr [rbx+12210h], xmm2
00007FF91DFE4270  F3 0F 58 D4                 addss   xmm2, xmm4
00007FF91DFE4274  F3 0F 5C E6                 subss   xmm4, xmm6
00007FF91DFE4278  0F 54 25 11 15 76 00        andps   xmm4, cs:xmmword_7FF91E745790
00007FF91DFE427F  F3 0F 5C C4                 subss   xmm0, xmm4
00007FF91DFE4283  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE4287  0F 83 E8 00 00 00           jnb     loc_7FF91DFE4375
00007FF91DFE428D  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFE4290  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFE4293  41 0F 2E EE                 ucomiss xmm5, xmm14
00007FF91DFE4297  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE429B  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFE429E  F3 0F 11 83 20 22 01 00     movss   dword ptr [rbx+12220h], xmm0
00007FF91DFE42A6  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFE42AA  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE42AE  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE42B2  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE42B6  75 03                       jnz     short loc_7FF91DFE42BB
00007FF91DFE42B8  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFE42BB  8B 83 E0 22 01 00           mov     eax, [rbx+122E0h]
00007FF91DFE42C1  48 8D 0D 38 BD C7 FF        lea     rcx, cs:7FF91DC60000h
00007FF91DFE42C8  F3 0F 59 BB D0 22 01 00     mulss   xmm7, dword ptr [rbx+122D0h]
00007FF91DFE42D0  89 83 F0 22 01 00           mov     [rbx+122F0h], eax
00007FF91DFE42D6  F3 44 0F 59 83 C0 22 01 00  mulss   xmm8, dword ptr [rbx+122C0h]
00007FF91DFE42DF  F3 0F 10 83 00 24 01 00     movss   xmm0, dword ptr [rbx+12400h]
00007FF91DFE42E7  F3 0F 10 93 00 23 01 00     movss   xmm2, dword ptr [rbx+12300h]
00007FF91DFE42EF  F3 44 0F 10 8B 60 23 01 00  movss   xmm9, dword ptr [rbx+12360h]
00007FF91DFE42F8  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFE42FD  F3 44 0F 10 83 40 23 01 00  movss   xmm8, dword ptr [rbx+12340h]
00007FF91DFE4306  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFE430A  F3 0F 11 BB E0 22 01 00     movss   dword ptr [rbx+122E0h], xmm7
00007FF91DFE4312  F3 0F 10 BB 20 23 01 00     movss   xmm7, dword ptr [rbx+12320h]
00007FF91DFE431A  F3 0F 11 8B 30 22 01 00     movss   dword ptr [rbx+12230h], xmm1
00007FF91DFE4322  F3 0F 11 8B 60 22 01 00     movss   dword ptr [rbx+12260h], xmm1
00007FF91DFE432A  F3 0F 10 8B C0 23 01 00     movss   xmm1, dword ptr [rbx+123C0h]
00007FF91DFE4332  F3 0F 11 BB 30 23 01 00     movss   dword ptr [rbx+12330h], xmm7
00007FF91DFE433A  F3 0F 11 93 10 23 01 00     movss   dword ptr [rbx+12310h], xmm2
00007FF91DFE4342  F3 44 0F 11 83 50 23 01 00  movss   dword ptr [rbx+12350h], xmm8
00007FF91DFE434B  F3 44 0F 11 8B 70 23 01 00  movss   dword ptr [rbx+12370h], xmm9
00007FF91DFE4354  F3 0F 11 8B D0 23 01 00     movss   dword ptr [rbx+123D0h], xmm1
00007FF91DFE435C  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFE435F  7D 2F                       jge     short loc_7FF91DFE4390
00007FF91DFE4361  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFE4366  F7 D0                       not     eax
00007FF91DFE4368  48 98                       cdqe
00007FF91DFE436A  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFE4373  EB 47                       jmp     short loc_7FF91DFE43BC
00007FF91DFE4375  F3 0F 58 8B B0 22 01 00     addss   xmm1, dword ptr [rbx+122B0h]
00007FF91DFE437D  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFE4381  0F 82 09 FF FF FF           jb      loc_7FF91DFE4290
00007FF91DFE4387  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFE438B  E9 03 FF FF FF              jmp     loc_7FF91DFE4293
00007FF91DFE4390  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFE4393  7E 07                       jle     short loc_7FF91DFE439C
00007FF91DFE4395  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFE439A  EB 15                       jmp     short loc_7FF91DFE43B1
00007FF91DFE439C  85 C0                       test    eax, eax
00007FF91DFE439E  79 0F                       jns     short loc_7FF91DFE43AF
00007FF91DFE43A0  F7 D0                       not     eax
00007FF91DFE43A2  48 98                       cdqe
00007FF91DFE43A4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFE43AD  EB 0D                       jmp     short loc_7FF91DFE43BC
00007FF91DFE43AF  7E 0B                       jle     short loc_7FF91DFE43BC
00007FF91DFE43B1  48 98                       cdqe
00007FF91DFE43B3  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFE43BC  0F 57 05 FD 13 76 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFE43C3  F3 0F 2C C0                 cvttss2si eax, xmm0
00007FF91DFE43C7  83 F8 E0                    cmp     eax, 0FFFFFFE0h
00007FF91DFE43CA  7D 14                       jge     short loc_7FF91DFE43E0
00007FF91DFE43CC  B8 E0 FF FF FF              mov     eax, 0FFFFFFE0h
00007FF91DFE43D1  F7 D0                       not     eax
00007FF91DFE43D3  48 98                       cdqe
00007FF91DFE43D5  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFE43DE  EB 2C                       jmp     short loc_7FF91DFE440C
00007FF91DFE43E0  83 F8 20                    cmp     eax, 20h ; ' '
00007FF91DFE43E3  7E 07                       jle     short loc_7FF91DFE43EC
00007FF91DFE43E5  B8 20 00 00 00              mov     eax, 20h ; ' '
00007FF91DFE43EA  EB 15                       jmp     short loc_7FF91DFE4401
00007FF91DFE43EC  85 C0                       test    eax, eax
00007FF91DFE43EE  79 0F                       jns     short loc_7FF91DFE43FF
00007FF91DFE43F0  F7 D0                       not     eax
00007FF91DFE43F2  48 98                       cdqe
00007FF91DFE43F4  F3 0F 59 94 81 C0 AC 98 00  mulss   xmm2, ds:rva dword_7FF91E5EACC0[rcx+rax*4]
00007FF91DFE43FD  EB 0D                       jmp     short loc_7FF91DFE440C
00007FF91DFE43FF  7E 0B                       jle     short loc_7FF91DFE440C
00007FF91DFE4401  48 98                       cdqe
00007FF91DFE4403  F3 0F 59 94 81 3C AD 98 00  mulss   xmm2, ds:rva dword_7FF91E5EAD3C[rcx+rax*4]
00007FF91DFE440C  F3 0F 10 83 80 23 01 00     movss   xmm0, dword ptr [rbx+12380h]
00007FF91DFE4414  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFE4418  F3 0F 59 93 F0 23 01 00     mulss   xmm2, dword ptr [rbx+123F0h]
00007FF91DFE4420  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE4424  F3 0F 10 8B B0 23 01 00     movss   xmm1, dword ptr [rbx+123B0h]
00007FF91DFE442C  F3 0F 11 93 C0 23 01 00     movss   dword ptr [rbx+123C0h], xmm2
00007FF91DFE4434  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFE4438  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE443C  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE4440  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE4444  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFE4448  76 05                       jbe     short loc_7FF91DFE444F
00007FF91DFE444A  0F 5A C2                    cvtps2pd xmm0, xmm2
00007FF91DFE444D  EB 03                       jmp     short loc_7FF91DFE4452
00007FF91DFE444F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE4452  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFE4456  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFE445A  72 06                       jb      short loc_7FF91DFE4462
00007FF91DFE445C  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFE4460  EB 03                       jmp     short loc_7FF91DFE4465
00007FF91DFE4462  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFE4465  F3 0F 10 B3 90 23 01 00     movss   xmm6, dword ptr [rbx+12390h]
00007FF91DFE446D  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE4471  F3 0F 59 83 20 24 01 00     mulss   xmm0, dword ptr [rbx+12420h]; X
00007FF91DFE4479  E8 C2 B2 36 00              call    expf
00007FF91DFE447E  F3 0F 59 83 10 24 01 00     mulss   xmm0, dword ptr [rbx+12410h]
00007FF91DFE4486  0F 28 CE                    movaps  xmm1, xmm6
00007FF91DFE4489  8B 83 90 25 01 00           mov     eax, [rbx+12590h]
00007FF91DFE448F  F3 0F 59 8B A0 23 01 00     mulss   xmm1, dword ptr [rbx+123A0h]
00007FF91DFE4497  89 83 A0 25 01 00           mov     [rbx+125A0h], eax
00007FF91DFE449D  F3 0F 58 83 30 24 01 00     addss   xmm0, dword ptr [rbx+12430h]
00007FF91DFE44A5  8B 83 B0 25 01 00           mov     eax, [rbx+125B0h]
00007FF91DFE44AB  F3 0F 10 9B 50 25 01 00     movss   xmm3, dword ptr [rbx+12550h]
00007FF91DFE44B3  F3 0F 59 BB E0 26 01 00     mulss   xmm7, dword ptr [rbx+126E0h]
00007FF91DFE44BB  89 83 C0 25 01 00           mov     [rbx+125C0h], eax
00007FF91DFE44C1  8B 83 D0 25 01 00           mov     eax, [rbx+125D0h]
00007FF91DFE44C7  F3 0F 10 93 40 25 01 00     movss   xmm2, dword ptr [rbx+12540h]
00007FF91DFE44CF  F3 0F 10 A3 70 25 01 00     movss   xmm4, dword ptr [rbx+12570h]
00007FF91DFE44D7  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFE44DB  89 83 E0 25 01 00           mov     [rbx+125E0h], eax
00007FF91DFE44E1  8B 83 D0 49 01 00           mov     eax, [rbx+149D0h]
00007FF91DFE44E7  F3 0F 11 9B 60 25 01 00     movss   dword ptr [rbx+12560h], xmm3
00007FF91DFE44EF  F3 0F 5C CE                 subss   xmm1, xmm6
00007FF91DFE44F3  F3 0F 11 93 50 25 01 00     movss   dword ptr [rbx+12550h], xmm2
00007FF91DFE44FB  F3 0F 11 A3 80 25 01 00     movss   dword ptr [rbx+12580h], xmm4
00007FF91DFE4503  F3 44 0F 11 83 10 25 01 00  movss   dword ptr [rbx+12510h], xmm8
00007FF91DFE450C  F3 44 0F 11 8B 20 25 01 00  movss   dword ptr [rbx+12520h], xmm9
00007FF91DFE4515  89 83 00 25 01 00           mov     [rbx+12500h], eax
00007FF91DFE451B  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE451F  F3 0F 10 83 B0 26 01 00     movss   xmm0, dword ptr [rbx+126B0h]
00007FF91DFE4527  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFE452B  F3 0F 11 83 A0 26 01 00     movss   dword ptr [rbx+126A0h], xmm0
00007FF91DFE4533  F3 0F 11 8B E0 23 01 00     movss   dword ptr [rbx+123E0h], xmm1
00007FF91DFE453B  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFE453F  73 06                       jnb     short loc_7FF91DFE4547
00007FF91DFE4541  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE4545  EB 05                       jmp     short loc_7FF91DFE454C
00007FF91DFE4547  F3 41 0F 5D FD              minss   xmm7, xmm13
00007FF91DFE454C  F3 0F 59 0D 6C 68 60 00     mulss   xmm1, cs:dword_7FF91E5EADC0
00007FF91DFE4554  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE4558  F3 0F 10 B3 C0 27 01 00     movss   xmm6, dword ptr [rbx+127C0h]
00007FF91DFE4560  F3 0F 5C C3                 subss   xmm0, xmm3
00007FF91DFE4564  F3 0F 11 BB 40 25 01 00     movss   dword ptr [rbx+12540h], xmm7
00007FF91DFE456C  F3 0F 5D F1                 minss   xmm6, xmm1
00007FF91DFE4570  F3 0F 59 83 F0 26 01 00     mulss   xmm0, dword ptr [rbx+126F0h]
00007FF91DFE4578  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFE457C  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFE4580  73 06                       jnb     short loc_7FF91DFE4588
00007FF91DFE4582  41 0F 28 C7                 movaps  xmm0, xmm15
00007FF91DFE4586  EB 05                       jmp     short loc_7FF91DFE458D
00007FF91DFE4588  F3 41 0F 5D C5              minss   xmm0, xmm13
00007FF91DFE458D  F3 0F 59 B3 D0 27 01 00     mulss   xmm6, dword ptr [rbx+127D0h]
00007FF91DFE4595  F3 0F 5C D7                 subss   xmm2, xmm7
00007FF91DFE4599  F3 0F 11 B3 F0 25 01 00     movss   dword ptr [rbx+125F0h], xmm6
00007FF91DFE45A1  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFE45A5  41 0F 2F D6                 comiss  xmm2, xmm14
00007FF91DFE45A9  73 03                       jnb     short loc_7FF91DFE45AE
00007FF91DFE45AB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE45AE  F3 0F 10 8B C0 26 01 00     movss   xmm1, dword ptr [rbx+126C0h]
00007FF91DFE45B6  F3 44 0F 10 9B 00 25 01 00  movss   xmm11, dword ptr [rbx+12500h]
00007FF91DFE45BF  F3 0F 11 83 50 25 01 00     movss   dword ptr [rbx+12550h], xmm0
00007FF91DFE45C7  F3 0F 58 83 50 28 01 00     addss   xmm0, dword ptr [rbx+12850h]
00007FF91DFE45CF  72 04                       jb      short loc_7FF91DFE45D5
00007FF91DFE45D1  41 0F 28 CD                 movaps  xmm1, xmm13
00007FF91DFE45D5  F3 0F 59 83 40 28 01 00     mulss   xmm0, dword ptr [rbx+12840h]
00007FF91DFE45DD  41 0F 28 FB                 movaps  xmm7, xmm11
00007FF91DFE45E1  F3 0F 10 93 A0 25 01 00     movss   xmm2, dword ptr [rbx+125A0h]
00007FF91DFE45E9  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFE45ED  F3 0F 5C FA                 subss   xmm7, xmm2
00007FF91DFE45F1  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE45F5  F3 0F 59 B3 D0 26 01 00     mulss   xmm6, dword ptr [rbx+126D0h]
00007FF91DFE45FD  76 05                       jbe     short loc_7FF91DFE4604
00007FF91DFE45FF  0F 5A C8                    cvtps2pd xmm1, xmm0
00007FF91DFE4602  EB 03                       jmp     short loc_7FF91DFE4607
00007FF91DFE4604  0F 57 C9                    xorps   xmm1, xmm1
00007FF91DFE4607  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE460B  F3 0F 59 BB 10 29 01 00     mulss   xmm7, dword ptr [rbx+12910h]
00007FF91DFE4613  F3 44 0F 10 0D CC 0B 76 00  movss   xmm9, cs:flt_7FF91E7451E8
00007FF91DFE461C  66 0F 5A C1                 cvtpd2ps xmm0, xmm1
00007FF91DFE4620  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFE4624  F3 0F 11 BB 90 25 01 00     movss   dword ptr [rbx+12590h], xmm7
00007FF91DFE462C  F3 0F 11 83 30 25 01 00     movss   dword ptr [rbx+12530h], xmm0
00007FF91DFE4634  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFE4638  F3 0F 59 BB 00 29 01 00     mulss   xmm7, dword ptr [rbx+12900h]
00007FF91DFE4640  F3 0F 10 8B 80 27 01 00     movss   xmm1, dword ptr [rbx+12780h]
00007FF91DFE4648  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE464C  F3 0F 59 F9                 mulss   xmm7, xmm1
00007FF91DFE4650  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFE4654  F3 0F 10 83 80 25 01 00     movss   xmm0, dword ptr [rbx+12580h]
00007FF91DFE465C  F3 0F 11 84 24 E0 00 00 00  movss   [rsp+0C8h+arg_10], xmm0
00007FF91DFE4665  F3 41 0F 58 FB              addss   xmm7, xmm11
00007FF91DFE466A  76 1B                       jbe     short loc_7FF91DFE4687
00007FF91DFE466C  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE4671  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE4675  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE4678  E8 5B AE 36 00              call    fmodf
00007FF91DFE467D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE4680  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE4685  EB 1F                       jmp     short loc_7FF91DFE46A6
00007FF91DFE4687  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE468B  73 19                       jnb     short loc_7FF91DFE46A6
00007FF91DFE468D  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE4692  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE4696  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE4699  E8 3A AE 36 00              call    fmodf
00007FF91DFE469E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE46A1  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE46A6  F3 0F 10 8C 24 E0 00 00 00  movss   xmm1, [rsp+0C8h+arg_10]
00007FF91DFE46AF  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE46B2  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE46B6  F3 44 0F 10 83 C0 25 01 00  movss   xmm8, dword ptr [rbx+125C0h]
00007FF91DFE46BF  F3 0F 11 B3 70 25 01 00     movss   dword ptr [rbx+12570h], xmm6
00007FF91DFE46C7  F3 0F 59 BB F0 28 01 00     mulss   xmm7, dword ptr [rbx+128F0h]
00007FF91DFE46CF  F3 0F 58 83 60 28 01 00     addss   xmm0, dword ptr [rbx+12860h]
00007FF91DFE46D7  F3 0F 11 BB F0 24 01 00     movss   dword ptr [rbx+124F0h], xmm7
00007FF91DFE46DF  73 0A                       jnb     short loc_7FF91DFE46EB
00007FF91DFE46E1  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFE46E5  76 04                       jbe     short loc_7FF91DFE46EB
00007FF91DFE46E7  45 0F 28 C3                 movaps  xmm8, xmm11
00007FF91DFE46EB  41 0F 2F C5                 comiss  xmm0, xmm13
00007FF91DFE46EF  76 15                       jbe     short loc_7FF91DFE4706
00007FF91DFE46F1  F3 41 0F 58 C5              addss   xmm0, xmm13; X
00007FF91DFE46F6  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE46FA  E8 D9 AD 36 00              call    fmodf
00007FF91DFE46FF  F3 41 0F 5C C5              subss   xmm0, xmm13
00007FF91DFE4704  EB 19                       jmp     short loc_7FF91DFE471F
00007FF91DFE4706  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFE470A  73 13                       jnb     short loc_7FF91DFE471F
00007FF91DFE470C  F3 41 0F 5C C5              subss   xmm0, xmm13; X
00007FF91DFE4711  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE4715  E8 BE AD 36 00              call    fmodf
00007FF91DFE471A  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE471F  F3 44 0F 10 1D 98 10 76 00  movss   xmm11, dword ptr cs:xmmword_7FF91E7457C0
00007FF91DFE4728  F3 44 0F 11 83 B0 25 01 00  movss   dword ptr [rbx+125B0h], xmm8
00007FF91DFE4731  F3 0F 59 83 A0 28 01 00     mulss   xmm0, dword ptr [rbx+128A0h]
00007FF91DFE4739  F3 44 0F 59 83 E0 28 01 00  mulss   xmm8, dword ptr [rbx+128E0h]
00007FF91DFE4742  F3 0F 58 83 20 29 01 00     addss   xmm0, dword ptr [rbx+12920h]
00007FF91DFE474A  F3 0F 11 83 00 26 01 00     movss   dword ptr [rbx+12600h], xmm0
00007FF91DFE4752  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFE4756  F3 44 0F 11 83 50 26 01 00  movss   dword ptr [rbx+12650h], xmm8
00007FF91DFE475F  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFE4763  F3 44 0F 58 83 80 28 01 00  addss   xmm8, dword ptr [rbx+12880h]
00007FF91DFE476C  F3 0F 11 83 10 26 01 00     movss   dword ptr [rbx+12610h], xmm0
00007FF91DFE4774  45 0F 2F C5                 comiss  xmm8, xmm13
00007FF91DFE4778  76 1D                       jbe     short loc_7FF91DFE4797
00007FF91DFE477A  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFE477F  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE4783  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFE4787  E8 4C AD 36 00              call    fmodf
00007FF91DFE478C  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFE4790  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFE4795  EB 21                       jmp     short loc_7FF91DFE47B8
00007FF91DFE4797  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFE479B  73 1B                       jnb     short loc_7FF91DFE47B8
00007FF91DFE479D  F3 45 0F 5C C5              subss   xmm8, xmm13
00007FF91DFE47A2  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE47A6  41 0F 28 C0                 movaps  xmm0, xmm8; X
00007FF91DFE47AA  E8 29 AD 36 00              call    fmodf
00007FF91DFE47AF  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFE47B3  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFE47B8  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFE47BB  F3 0F 58 BB 70 28 01 00     addss   xmm7, dword ptr [rbx+12870h]
00007FF91DFE47C3  41 0F 2F FD                 comiss  xmm7, xmm13
00007FF91DFE47C7  76 1B                       jbe     short loc_7FF91DFE47E4
00007FF91DFE47C9  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE47CE  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE47D2  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFE47D5  E8 FE AC 36 00              call    fmodf
00007FF91DFE47DA  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFE47DD  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE47E2  EB 1F                       jmp     short loc_7FF91DFE4803
00007FF91DFE47E4  41 0F 2F FF                 comiss  xmm7, xmm15
00007FF91DFE47E8  73 19                       jnb     short loc_7FF91DFE4803
00007FF91DFE47EA  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE47EF  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE47F3  0F 28 C7                    movaps  xmm0, xmm7; X
00007FF91DFE47F6  E8 DD AC 36 00              call    fmodf
00007FF91DFE47FB  0F 28 F8                    movaps  xmm7, xmm0
00007FF91DFE47FE  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE4803  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFE4807  E8 B4 47 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE480C  F3 0F 58 BB 30 29 01 00     addss   xmm7, dword ptr [rbx+12930h]
00007FF91DFE4814  F3 0F 59 83 C0 28 01 00     mulss   xmm0, dword ptr [rbx+128C0h]
00007FF91DFE481C  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE4820  73 06                       jnb     short loc_7FF91DFE4828
00007FF91DFE4822  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE4826  EB 06                       jmp     short loc_7FF91DFE482E
00007FF91DFE4828  76 04                       jbe     short loc_7FF91DFE482E
00007FF91DFE482A  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE482E  F3 0F 58 B3 90 28 01 00     addss   xmm6, dword ptr [rbx+12890h]
00007FF91DFE4836  F3 0F 11 83 30 26 01 00     movss   dword ptr [rbx+12630h], xmm0
00007FF91DFE483E  F3 0F 11 BB 90 26 01 00     movss   dword ptr [rbx+12690h], xmm7
00007FF91DFE4846  F3 0F 59 BB B0 28 01 00     mulss   xmm7, dword ptr [rbx+128B0h]
00007FF91DFE484E  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE4852  F3 0F 58 BB 40 29 01 00     addss   xmm7, dword ptr [rbx+12940h]
00007FF91DFE485A  76 1B                       jbe     short loc_7FF91DFE4877
00007FF91DFE485C  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE4861  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE4865  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE4868  E8 6B AC 36 00              call    fmodf
00007FF91DFE486D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE4870  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE4875  EB 1F                       jmp     short loc_7FF91DFE4896
00007FF91DFE4877  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE487B  73 19                       jnb     short loc_7FF91DFE4896
00007FF91DFE487D  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE4882  41 0F 28 C9                 movaps  xmm1, xmm9; Y
00007FF91DFE4886  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE4889  E8 4A AC 36 00              call    fmodf
00007FF91DFE488E  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE4891  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE4896  0F 54 35 F3 0E 76 00        andps   xmm6, cs:xmmword_7FF91E745790
00007FF91DFE489D  F3 0F 11 BB 20 26 01 00     movss   dword ptr [rbx+12620h], xmm7
00007FF91DFE48A5  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFE48A8  F3 0F 10 9B 60 27 01 00     movss   xmm3, dword ptr [rbx+12760h]
00007FF91DFE48B0  0F 28 D6                    movaps  xmm2, xmm6
00007FF91DFE48B3  F3 0F 59 93 F0 27 01 00     mulss   xmm2, dword ptr [rbx+127F0h]
00007FF91DFE48BB  F3 0F 59 9B 50 26 01 00     mulss   xmm3, dword ptr [rbx+12650h]
00007FF91DFE48C3  F3 0F 58 93 E0 27 01 00     addss   xmm2, dword ptr [rbx+127E0h]
00007FF91DFE48CB  F3 0F 10 8B 50 27 01 00     movss   xmm1, dword ptr [rbx+12750h]
00007FF91DFE48D3  F3 0F 59 8B 10 26 01 00     mulss   xmm1, dword ptr [rbx+12610h]
00007FF91DFE48DB  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFE48DF  0F 28 C4                    movaps  xmm0, xmm4
00007FF91DFE48E2  F3 0F 59 E6                 mulss   xmm4, xmm6
00007FF91DFE48E6  F3 0F 59 83 00 28 01 00     mulss   xmm0, dword ptr [rbx+12800h]
00007FF91DFE48EE  F3 0F 59 F4                 mulss   xmm6, xmm4
00007FF91DFE48F2  F3 0F 59 A3 10 28 01 00     mulss   xmm4, dword ptr [rbx+12810h]
00007FF91DFE48FA  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE48FE  F3 0F 59 B3 20 28 01 00     mulss   xmm6, dword ptr [rbx+12820h]
00007FF91DFE4906  F3 0F 10 83 40 27 01 00     movss   xmm0, dword ptr [rbx+12740h]
00007FF91DFE490E  F3 0F 59 83 00 26 01 00     mulss   xmm0, dword ptr [rbx+12600h]
00007FF91DFE4916  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFE491A  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE491E  F3 0F 58 F4                 addss   xmm6, xmm4
00007FF91DFE4922  F3 0F 10 A3 20 27 01 00     movss   xmm4, dword ptr [rbx+12720h]
00007FF91DFE492A  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE492E  F3 0F 58 B3 30 28 01 00     addss   xmm6, dword ptr [rbx+12830h]
00007FF91DFE4936  F3 0F 59 B3 D0 28 01 00     mulss   xmm6, dword ptr [rbx+128D0h]
00007FF91DFE493E  F3 0F 11 B3 40 26 01 00     movss   dword ptr [rbx+12640h], xmm6
00007FF91DFE4946  F3 0F 59 A3 30 26 01 00     mulss   xmm4, dword ptr [rbx+12630h]
00007FF91DFE494E  F3 0F 10 8B 00 27 01 00     movss   xmm1, dword ptr [rbx+12700h]
00007FF91DFE4956  F3 0F 10 83 30 27 01 00     movss   xmm0, dword ptr [rbx+12730h]
00007FF91DFE495E  F3 0F 59 83 20 26 01 00     mulss   xmm0, dword ptr [rbx+12620h]
00007FF91DFE4966  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE496A  F3 0F 10 93 90 27 01 00     movss   xmm2, dword ptr [rbx+12790h]
00007FF91DFE4972  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFE4975  F3 0F 59 9B 30 25 01 00     mulss   xmm3, dword ptr [rbx+12530h]
00007FF91DFE497D  F3 0F 59 B3 10 27 01 00     mulss   xmm6, dword ptr [rbx+12710h]
00007FF91DFE4985  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE4989  F3 0F 10 83 70 27 01 00     movss   xmm0, dword ptr [rbx+12770h]
00007FF91DFE4991  F3 0F 5C D9                 subss   xmm3, xmm1
00007FF91DFE4995  F3 0F 59 83 F0 24 01 00     mulss   xmm0, dword ptr [rbx+124F0h]
00007FF91DFE499D  F3 0F 58 E6                 addss   xmm4, xmm6
00007FF91DFE49A1  F3 41 0F 58 DD              addss   xmm3, xmm13
00007FF91DFE49A6  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE49AA  F3 0F 11 9B 60 26 01 00     movss   dword ptr [rbx+12660h], xmm3
00007FF91DFE49B2  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE49B6  F3 0F 11 A3 80 26 01 00     movss   dword ptr [rbx+12680h], xmm4
00007FF91DFE49BE  F3 0F 10 8B A0 27 01 00     movss   xmm1, dword ptr [rbx+127A0h]
00007FF91DFE49C6  F3 0F 59 8B 10 25 01 00     mulss   xmm1, dword ptr [rbx+12510h]
00007FF91DFE49CE  F3 0F 10 83 B0 27 01 00     movss   xmm0, dword ptr [rbx+127B0h]
00007FF91DFE49D6  F3 0F 59 83 20 25 01 00     mulss   xmm0, dword ptr [rbx+12520h]
00007FF91DFE49DE  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE49E2  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE49E6  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE49EA  F3 0F 11 8B 70 26 01 00     movss   dword ptr [rbx+12670h], xmm1
00007FF91DFE49F2  F3 0F 10 83 80 26 01 00     movss   xmm0, dword ptr [rbx+12680h]
00007FF91DFE49FA  8B 83 90 26 01 00           mov     eax, [rbx+12690h]
00007FF91DFE4A00  89 83 50 29 01 00           mov     [rbx+12950h], eax
00007FF91DFE4A06  F3 0F 11 83 60 29 01 00     movss   dword ptr [rbx+12960h], xmm0
00007FF91DFE4A0E  44 0F 2F B3 90 26 01 00     comiss  xmm14, dword ptr [rbx+12690h]
00007FF91DFE4A16  F3 0F 10 8B A0 21 01 00     movss   xmm1, dword ptr [rbx+121A0h]
00007FF91DFE4A1E  F3 0F 10 93 70 29 01 00     movss   xmm2, dword ptr [rbx+12970h]
00007FF91DFE4A26  73 06                       jnb     short loc_7FF91DFE4A2E
00007FF91DFE4A28  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE4A2C  EB 03                       jmp     short loc_7FF91DFE4A31
00007FF91DFE4A2E  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE4A31  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFE4A35  75 04                       jnz     short loc_7FF91DFE4A3B
00007FF91DFE4A37  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE4A3B  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE4A3F  F3 0F 11 8B 80 29 01 00     movss   dword ptr [rbx+12980h], xmm1
00007FF91DFE4A47  8B 83 90 29 01 00           mov     eax, [rbx+12990h]
00007FF91DFE4A4D  89 83 A0 29 01 00           mov     [rbx+129A0h], eax
00007FF91DFE4A53  8B 83 C0 29 01 00           mov     eax, [rbx+129C0h]
00007FF91DFE4A59  89 83 D0 29 01 00           mov     [rbx+129D0h], eax
00007FF91DFE4A5F  8B 83 B0 29 01 00           mov     eax, [rbx+129B0h]
00007FF91DFE4A65  89 83 C0 29 01 00           mov     [rbx+129C0h], eax
00007FF91DFE4A6B  8B 83 E0 29 01 00           mov     eax, [rbx+129E0h]
00007FF91DFE4A71  89 83 F0 29 01 00           mov     [rbx+129F0h], eax
00007FF91DFE4A77  8B 83 10 2A 01 00           mov     eax, [rbx+12A10h]
00007FF91DFE4A7D  89 83 20 2A 01 00           mov     [rbx+12A20h], eax
00007FF91DFE4A83  F3 0F 10 83 C0 2A 01 00     movss   xmm0, dword ptr [rbx+12AC0h]
00007FF91DFE4A8B  F3 0F 58 8B A0 2A 01 00     addss   xmm1, dword ptr [rbx+12AA0h]
00007FF91DFE4A93  F3 0F 59 83 D0 29 01 00     mulss   xmm0, dword ptr [rbx+129D0h]
00007FF91DFE4A9B  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE4A9F  F3 0F 58 83 A0 29 01 00     addss   xmm0, dword ptr [rbx+129A0h]
00007FF91DFE4AA7  73 06                       jnb     short loc_7FF91DFE4AAF
00007FF91DFE4AA9  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFE4AAD  EB 04                       jmp     short loc_7FF91DFE4AB3
00007FF91DFE4AAF  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFE4AB3  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFE4AB7  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFE4ABC  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFE4ABF  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFE4AC3  F3 0F 11 BB B0 29 01 00     movss   dword ptr [rbx+129B0h], xmm7
00007FF91DFE4ACB  0F 28 E7                    movaps  xmm4, xmm7
00007FF91DFE4ACE  F3 0F 10 9B 90 2A 01 00     movss   xmm3, dword ptr [rbx+12A90h]
00007FF91DFE4AD6  F3 0F 10 93 E0 2A 01 00     movss   xmm2, dword ptr [rbx+12AE0h]
00007FF91DFE4ADE  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE4AE1  F3 0F 59 8B 00 2B 01 00     mulss   xmm1, dword ptr [rbx+12B00h]
00007FF91DFE4AE9  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE4AEC  F3 0F 58 A3 B0 2A 01 00     addss   xmm4, dword ptr [rbx+12AB0h]
00007FF91DFE4AF4  F3 0F 5C BB C0 29 01 00     subss   xmm7, dword ptr [rbx+129C0h]
00007FF91DFE4AFC  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE4B00  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFE4B04  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE4B08  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE4B0C  F3 0F 11 8B 00 2A 01 00     movss   dword ptr [rbx+12A00h], xmm1
00007FF91DFE4B14  72 06                       jb      short loc_7FF91DFE4B1C
00007FF91DFE4B16  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE4B1A  EB 03                       jmp     short loc_7FF91DFE4B1F
00007FF91DFE4B1C  0F 57 F6                    xorps   xmm6, xmm6
00007FF91DFE4B1F  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE4B23  F3 0F 10 83 60 2A 01 00     movss   xmm0, dword ptr [rbx+12A60h]
00007FF91DFE4B2B  73 03                       jnb     short loc_7FF91DFE4B30
00007FF91DFE4B2D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFE4B30  F3 0F 59 83 E0 2A 01 00     mulss   xmm0, dword ptr [rbx+12AE0h]
00007FF91DFE4B38  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFE4B3B  F3 0F 10 93 50 2A 01 00     movss   xmm2, dword ptr [rbx+12A50h]
00007FF91DFE4B43  F3 44 0F 10 0D 10 04 76 00  movss   xmm9, cs:dword_7FF91E744F5C
00007FF91DFE4B4C  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFE4B50  F3 0F 11 B3 C0 29 01 00     movss   dword ptr [rbx+129C0h], xmm6
00007FF91DFE4B58  F3 0F 10 8B F0 2A 01 00     movss   xmm1, dword ptr [rbx+12AF0h]
00007FF91DFE4B60  F3 0F 10 BB 70 2A 01 00     movss   xmm7, dword ptr [rbx+12A70h]
00007FF91DFE4B68  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE4B6B  F3 0F 10 A3 F0 29 01 00     movss   xmm4, dword ptr [rbx+129F0h]
00007FF91DFE4B73  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE4B77  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFE4B7C  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE4B80  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFE4B85  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE4B89  F3 0F 59 FE                 mulss   xmm7, xmm6
00007FF91DFE4B8D  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFE4B91  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE4B95  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFE4B99  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE4B9C  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFE4BA0  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE4BA4  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE4BA8  F3 0F 58 FA                 addss   xmm7, xmm2
00007FF91DFE4BAC  76 0B                       jbe     short loc_7FF91DFE4BB9
00007FF91DFE4BAE  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFE4BB1  F3 0F 58 9B 00 2A 01 00     addss   xmm3, dword ptr [rbx+12A00h]
00007FF91DFE4BB9  F3 0F 10 83 E0 2A 01 00     movss   xmm0, dword ptr [rbx+12AE0h]
00007FF91DFE4BC1  F3 0F 10 A3 A0 29 01 00     movss   xmm4, dword ptr [rbx+129A0h]
00007FF91DFE4BC9  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFE4BCD  F3 0F 11 83 E0 29 01 00     movss   dword ptr [rbx+129E0h], xmm0
00007FF91DFE4BD5  F3 0F 10 8B 20 2A 01 00     movss   xmm1, dword ptr [rbx+12A20h]
00007FF91DFE4BDD  F3 0F 10 9B 80 2A 01 00     movss   xmm3, dword ptr [rbx+12A80h]
00007FF91DFE4BE5  F3 0F 59 AB D0 2A 01 00     mulss   xmm5, dword ptr [rbx+12AD0h]
00007FF91DFE4BED  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFE4BF2  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFE4BF6  F3 0F 10 83 10 2B 01 00     movss   xmm0, dword ptr [rbx+12B10h]
00007FF91DFE4BFE  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFE4C03  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFE4C06  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE4C0A  F3 0F 58 EE                 addss   xmm5, xmm6
00007FF91DFE4C0E  F3 0F 59 D7                 mulss   xmm2, xmm7
00007FF91DFE4C12  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFE4C16  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE4C1A  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE4C1E  F3 0F 11 93 10 2A 01 00     movss   dword ptr [rbx+12A10h], xmm2
00007FF91DFE4C26  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFE4C2B  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFE4C30  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFE4C34  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE4C38  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFE4C3C  F3 0F 11 9B 90 29 01 00     movss   dword ptr [rbx+12990h], xmm3
00007FF91DFE4C44  F3 0F 59 9B 20 2B 01 00     mulss   xmm3, dword ptr [rbx+12B20h]
00007FF91DFE4C4C  F3 0F 59 9B 30 2B 01 00     mulss   xmm3, dword ptr [rbx+12B30h]
00007FF91DFE4C54  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE4C57  F3 0F 59 83 40 2B 01 00     mulss   xmm0, dword ptr [rbx+12B40h]
00007FF91DFE4C5F  F3 0F 11 9B 30 2A 01 00     movss   dword ptr [rbx+12A30h], xmm3
00007FF91DFE4C67  F3 0F 11 83 40 2A 01 00     movss   dword ptr [rbx+12A40h], xmm0
00007FF91DFE4C6F  44 0F 2F B3 90 26 01 00     comiss  xmm14, dword ptr [rbx+12690h]
00007FF91DFE4C77  F3 0F 10 8B A0 21 01 00     movss   xmm1, dword ptr [rbx+121A0h]
00007FF91DFE4C7F  F3 0F 10 93 50 2B 01 00     movss   xmm2, dword ptr [rbx+12B50h]
00007FF91DFE4C87  73 06                       jnb     short loc_7FF91DFE4C8F
00007FF91DFE4C89  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE4C8D  EB 03                       jmp     short loc_7FF91DFE4C92
00007FF91DFE4C8F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE4C92  41 0F 2E D6                 ucomiss xmm2, xmm14
00007FF91DFE4C96  75 04                       jnz     short loc_7FF91DFE4C9C
00007FF91DFE4C98  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE4C9C  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE4CA0  F3 0F 11 8B 60 2B 01 00     movss   dword ptr [rbx+12B60h], xmm1
00007FF91DFE4CA8  8B 83 70 2B 01 00           mov     eax, [rbx+12B70h]
00007FF91DFE4CAE  89 83 80 2B 01 00           mov     [rbx+12B80h], eax
00007FF91DFE4CB4  8B 83 A0 2B 01 00           mov     eax, [rbx+12BA0h]
00007FF91DFE4CBA  89 83 B0 2B 01 00           mov     [rbx+12BB0h], eax
00007FF91DFE4CC0  8B 83 90 2B 01 00           mov     eax, [rbx+12B90h]
00007FF91DFE4CC6  89 83 A0 2B 01 00           mov     [rbx+12BA0h], eax
00007FF91DFE4CCC  8B 83 C0 2B 01 00           mov     eax, [rbx+12BC0h]
00007FF91DFE4CD2  89 83 D0 2B 01 00           mov     [rbx+12BD0h], eax
00007FF91DFE4CD8  8B 83 F0 2B 01 00           mov     eax, [rbx+12BF0h]
00007FF91DFE4CDE  89 83 00 2C 01 00           mov     [rbx+12C00h], eax
00007FF91DFE4CE4  F3 0F 10 83 A0 2C 01 00     movss   xmm0, dword ptr [rbx+12CA0h]
00007FF91DFE4CEC  F3 0F 58 8B 80 2C 01 00     addss   xmm1, dword ptr [rbx+12C80h]
00007FF91DFE4CF4  F3 0F 59 83 B0 2B 01 00     mulss   xmm0, dword ptr [rbx+12BB0h]
00007FF91DFE4CFC  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE4D00  F3 0F 58 83 80 2B 01 00     addss   xmm0, dword ptr [rbx+12B80h]
00007FF91DFE4D08  73 06                       jnb     short loc_7FF91DFE4D10
00007FF91DFE4D0A  45 0F 28 C5                 movaps  xmm8, xmm13
00007FF91DFE4D0E  EB 04                       jmp     short loc_7FF91DFE4D14
00007FF91DFE4D10  45 0F 57 C0                 xorps   xmm8, xmm8
00007FF91DFE4D14  41 0F 28 ED                 movaps  xmm5, xmm13
00007FF91DFE4D18  F3 41 0F 5C E8              subss   xmm5, xmm8
00007FF91DFE4D1D  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFE4D20  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFE4D24  F3 0F 11 B3 90 2B 01 00     movss   dword ptr [rbx+12B90h], xmm6
00007FF91DFE4D2C  0F 28 E6                    movaps  xmm4, xmm6
00007FF91DFE4D2F  F3 0F 10 9B 70 2C 01 00     movss   xmm3, dword ptr [rbx+12C70h]
00007FF91DFE4D37  F3 0F 10 93 C0 2C 01 00     movss   xmm2, dword ptr [rbx+12CC0h]
00007FF91DFE4D3F  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE4D42  F3 0F 59 8B E0 2C 01 00     mulss   xmm1, dword ptr [rbx+12CE0h]
00007FF91DFE4D4A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE4D4D  F3 0F 58 A3 90 2C 01 00     addss   xmm4, dword ptr [rbx+12C90h]
00007FF91DFE4D55  F3 0F 5C B3 A0 2B 01 00     subss   xmm6, dword ptr [rbx+12BA0h]
00007FF91DFE4D5D  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE4D61  41 0F 2F E6                 comiss  xmm4, xmm14
00007FF91DFE4D65  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE4D69  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE4D6D  F3 0F 11 8B E0 2B 01 00     movss   dword ptr [rbx+12BE0h], xmm1
00007FF91DFE4D75  72 06                       jb      short loc_7FF91DFE4D7D
00007FF91DFE4D77  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE4D7B  EB 03                       jmp     short loc_7FF91DFE4D80
00007FF91DFE4D7D  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFE4D80  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFE4D84  F3 0F 10 83 40 2C 01 00     movss   xmm0, dword ptr [rbx+12C40h]
00007FF91DFE4D8C  73 03                       jnb     short loc_7FF91DFE4D91
00007FF91DFE4D8E  0F 28 FD                    movaps  xmm7, xmm5
00007FF91DFE4D91  F3 0F 59 83 C0 2C 01 00     mulss   xmm0, dword ptr [rbx+12CC0h]
00007FF91DFE4D99  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFE4D9C  F3 0F 10 93 30 2C 01 00     movss   xmm2, dword ptr [rbx+12C30h]
00007FF91DFE4DA4  F3 0F 11 BB A0 2B 01 00     movss   dword ptr [rbx+12BA0h], xmm7
00007FF91DFE4DAC  F3 0F 10 8B D0 2C 01 00     movss   xmm1, dword ptr [rbx+12CD0h]
00007FF91DFE4DB4  F3 0F 10 B3 50 2C 01 00     movss   xmm6, dword ptr [rbx+12C50h]
00007FF91DFE4DBC  F3 0F 10 A3 D0 2B 01 00     movss   xmm4, dword ptr [rbx+12BD0h]
00007FF91DFE4DC4  F3 0F 59 D8                 mulss   xmm3, xmm0
00007FF91DFE4DC8  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE4DCB  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE4DCF  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFE4DD4  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE4DD8  F3 41 0F 59 D1              mulss   xmm2, xmm9
00007FF91DFE4DDD  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE4DE1  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFE4DE5  F3 0F 5C C7                 subss   xmm0, xmm7
00007FF91DFE4DE9  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE4DED  F3 0F 59 E8                 mulss   xmm5, xmm0
00007FF91DFE4DF1  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE4DF4  F3 0F 5C CC                 subss   xmm1, xmm4
00007FF91DFE4DF8  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE4DFC  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE4E00  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFE4E04  76 0B                       jbe     short loc_7FF91DFE4E11
00007FF91DFE4E06  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFE4E09  F3 0F 58 9B E0 2B 01 00     addss   xmm3, dword ptr [rbx+12BE0h]
00007FF91DFE4E11  F3 0F 10 A3 80 2B 01 00     movss   xmm4, dword ptr [rbx+12B80h]
00007FF91DFE4E19  F3 0F 10 83 C0 2C 01 00     movss   xmm0, dword ptr [rbx+12CC0h]
00007FF91DFE4E21  F3 0F 5D C3                 minss   xmm0, xmm3
00007FF91DFE4E25  F3 0F 11 83 C0 2B 01 00     movss   dword ptr [rbx+12BC0h], xmm0
00007FF91DFE4E2D  F3 0F 59 AB B0 2C 01 00     mulss   xmm5, dword ptr [rbx+12CB0h]
00007FF91DFE4E35  F3 0F 10 8B 00 2C 01 00     movss   xmm1, dword ptr [rbx+12C00h]
00007FF91DFE4E3D  F3 0F 10 9B 60 2C 01 00     movss   xmm3, dword ptr [rbx+12C60h]
00007FF91DFE4E45  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFE4E49  F3 0F 10 83 F0 2C 01 00     movss   xmm0, dword ptr [rbx+12CF0h]
00007FF91DFE4E51  0F 28 D0                    movaps  xmm2, xmm0
00007FF91DFE4E54  F3 41 0F 59 D9              mulss   xmm3, xmm9
00007FF91DFE4E59  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE4E5D  F3 0F 58 EF                 addss   xmm5, xmm7
00007FF91DFE4E61  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFE4E66  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE4E6A  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFE4E6E  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE4E72  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE4E76  F3 0F 11 93 F0 2B 01 00     movss   dword ptr [rbx+12BF0h], xmm2
00007FF91DFE4E7E  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFE4E83  F3 41 0F 5C D8              subss   xmm3, xmm8
00007FF91DFE4E88  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFE4E8C  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE4E90  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFE4E94  F3 0F 11 9B 70 2B 01 00     movss   dword ptr [rbx+12B70h], xmm3
00007FF91DFE4E9C  F3 0F 59 9B 00 2D 01 00     mulss   xmm3, dword ptr [rbx+12D00h]
00007FF91DFE4EA4  F3 0F 59 9B 10 2D 01 00     mulss   xmm3, dword ptr [rbx+12D10h]
00007FF91DFE4EAC  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE4EAF  F3 0F 59 83 20 2D 01 00     mulss   xmm0, dword ptr [rbx+12D20h]
00007FF91DFE4EB7  F3 0F 11 9B 10 2C 01 00     movss   dword ptr [rbx+12C10h], xmm3
00007FF91DFE4EBF  F3 0F 11 83 20 2C 01 00     movss   dword ptr [rbx+12C20h], xmm0
00007FF91DFE4EC7  8B 83 30 2D 01 00           mov     eax, [rbx+12D30h]
00007FF91DFE4ECD  89 83 40 2D 01 00           mov     [rbx+12D40h], eax
00007FF91DFE4ED3  8B 83 50 2D 01 00           mov     eax, [rbx+12D50h]
00007FF91DFE4ED9  89 83 60 2D 01 00           mov     [rbx+12D60h], eax
00007FF91DFE4EDF  F3 0F 10 83 60 22 01 00     movss   xmm0, dword ptr [rbx+12260h]
00007FF91DFE4EE7  F3 44 0F 10 83 E0 22 01 00  movss   xmm8, dword ptr [rbx+122E0h]
00007FF91DFE4EF0  8B 83 90 2D 01 00           mov     eax, [rbx+12D90h]
00007FF91DFE4EF6  89 83 A0 2D 01 00           mov     [rbx+12DA0h], eax
00007FF91DFE4EFC  F3 0F 59 83 70 2D 01 00     mulss   xmm0, dword ptr [rbx+12D70h]
00007FF91DFE4F04  F3 44 0F 59 83 80 2D 01 00  mulss   xmm8, dword ptr [rbx+12D80h]
00007FF91DFE4F0D  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFE4F12  F3 44 0F 11 83 90 2D 01 00  movss   dword ptr [rbx+12D90h], xmm8
00007FF91DFE4F1B  F3 0F 10 BB 70 26 01 00     movss   xmm7, dword ptr [rbx+12670h]
00007FF91DFE4F23  F3 0F 10 8B 30 2A 01 00     movss   xmm1, dword ptr [rbx+12A30h]
00007FF91DFE4F2B  F3 0F 10 93 10 2C 01 00     movss   xmm2, dword ptr [rbx+12C10h]
00007FF91DFE4F33  F3 0F 10 83 60 22 01 00     movss   xmm0, dword ptr [rbx+12260h]
00007FF91DFE4F3B  8B 83 50 2D 01 00           mov     eax, [rbx+12D50h]
00007FF91DFE4F41  89 83 D0 2D 01 00           mov     [rbx+12DD0h], eax
00007FF91DFE4F47  F3 0F 11 83 E0 2D 01 00     movss   dword ptr [rbx+12DE0h], xmm0
00007FF91DFE4F4F  F3 0F 10 A3 20 2F 01 00     movss   xmm4, dword ptr [rbx+12F20h]
00007FF91DFE4F57  F3 0F 11 8B B0 2D 01 00     movss   dword ptr [rbx+12DB0h], xmm1
00007FF91DFE4F5F  F3 0F 11 93 C0 2D 01 00     movss   dword ptr [rbx+12DC0h], xmm2
00007FF91DFE4F67  F3 0F 10 AB 00 2F 01 00     movss   xmm5, dword ptr [rbx+12F00h]
00007FF91DFE4F6F  F3 0F 59 FC                 mulss   xmm7, xmm4
00007FF91DFE4F73  F3 0F 59 A3 80 26 01 00     mulss   xmm4, dword ptr [rbx+12680h]
00007FF91DFE4F7B  F3 0F 11 A3 F0 2D 01 00     movss   dword ptr [rbx+12DF0h], xmm4
00007FF91DFE4F83  F3 0F 10 8B 80 2E 01 00     movss   xmm1, dword ptr [rbx+12E80h]
00007FF91DFE4F8B  F3 0F 10 93 80 2F 01 00     movss   xmm2, dword ptr [rbx+12F80h]
00007FF91DFE4F93  0F 28 D9                    movaps  xmm3, xmm1
00007FF91DFE4F96  F3 0F 59 BB 30 2F 01 00     mulss   xmm7, dword ptr [rbx+12F30h]
00007FF91DFE4F9E  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE4FA1  F3 0F 10 B3 40 2F 01 00     movss   xmm6, dword ptr [rbx+12F40h]
00007FF91DFE4FA9  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE4FAD  F3 0F 59 F7                 mulss   xmm6, xmm7
00007FF91DFE4FB1  F3 0F 59 EC                 mulss   xmm5, xmm4
00007FF91DFE4FB5  F3 0F 59 AB 10 2F 01 00     mulss   xmm5, dword ptr [rbx+12F10h]
00007FF91DFE4FBD  F3 0F 11 AB 10 2E 01 00     movss   dword ptr [rbx+12E10h], xmm5
00007FF91DFE4FC5  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFE4FC9  F3 0F 59 9B D0 2D 01 00     mulss   xmm3, dword ptr [rbx+12DD0h]
00007FF91DFE4FD1  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE4FD5  F3 0F 10 83 90 2E 01 00     movss   xmm0, dword ptr [rbx+12E90h]
00007FF91DFE4FDD  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFE4FE1  F3 0F 59 9B 90 2F 01 00     mulss   xmm3, dword ptr [rbx+12F90h]
00007FF91DFE4FE9  F3 0F 11 9B 20 2E 01 00     movss   dword ptr [rbx+12E20h], xmm3
00007FF91DFE4FF1  F3 0F 10 8B 60 2F 01 00     movss   xmm1, dword ptr [rbx+12F60h]
00007FF91DFE4FF9  F3 0F 59 8B C0 2D 01 00     mulss   xmm1, dword ptr [rbx+12DC0h]
00007FF91DFE5001  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE5005  F3 0F 58 F0                 addss   xmm6, xmm0
00007FF91DFE5009  F3 0F 10 83 50 2F 01 00     movss   xmm0, dword ptr [rbx+12F50h]
00007FF91DFE5011  F3 0F 59 83 B0 2D 01 00     mulss   xmm0, dword ptr [rbx+12DB0h]
00007FF91DFE5019  F3 0F 10 9B F0 2D 01 00     movss   xmm3, dword ptr [rbx+12DF0h]
00007FF91DFE5021  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE5025  F3 0F 10 83 70 2E 01 00     movss   xmm0, dword ptr [rbx+12E70h]
00007FF91DFE502D  F3 0F 59 8B 70 2F 01 00     mulss   xmm1, dword ptr [rbx+12F70h]
00007FF91DFE5035  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFE5039  F3 41 0F 58 C8              addss   xmm1, xmm8
00007FF91DFE503E  F3 0F 58 8B E0 2E 01 00     addss   xmm1, dword ptr [rbx+12EE0h]
00007FF91DFE5046  F3 0F 58 8B F0 2E 01 00     addss   xmm1, dword ptr [rbx+12EF0h]
00007FF91DFE504E  F3 0F 11 8B 30 2E 01 00     movss   dword ptr [rbx+12E30h], xmm1
00007FF91DFE5056  F3 0F 11 83 40 2E 01 00     movss   dword ptr [rbx+12E40h], xmm0
00007FF91DFE505E  F3 0F 59 9B B0 2F 01 00     mulss   xmm3, dword ptr [rbx+12FB0h]
00007FF91DFE5066  F3 0F 10 83 B0 2E 01 00     movss   xmm0, dword ptr [rbx+12EB0h]
00007FF91DFE506E  F3 0F 59 83 B0 2D 01 00     mulss   xmm0, dword ptr [rbx+12DB0h]
00007FF91DFE5076  F3 0F 58 9B C0 2F 01 00     addss   xmm3, dword ptr [rbx+12FC0h]
00007FF91DFE507E  F3 0F 10 8B C0 2E 01 00     movss   xmm1, dword ptr [rbx+12EC0h]
00007FF91DFE5086  F3 0F 59 8B C0 2D 01 00     mulss   xmm1, dword ptr [rbx+12DC0h]
00007FF91DFE508E  F3 0F 10 93 10 2E 01 00     movss   xmm2, dword ptr [rbx+12E10h]
00007FF91DFE5096  F3 0F 59 9B A0 2E 01 00     mulss   xmm3, dword ptr [rbx+12EA0h]
00007FF91DFE509E  F3 0F 58 93 E0 2D 01 00     addss   xmm2, dword ptr [rbx+12DE0h]
00007FF91DFE50A6  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE50AA  F3 0F 58 93 20 2E 01 00     addss   xmm2, dword ptr [rbx+12E20h]
00007FF91DFE50B2  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE50B6  F3 0F 58 9B D0 2E 01 00     addss   xmm3, dword ptr [rbx+12ED0h]
00007FF91DFE50BE  F3 0F 59 9B A0 2F 01 00     mulss   xmm3, dword ptr [rbx+12FA0h]
00007FF91DFE50C6  F3 0F 11 9B 50 2E 01 00     movss   dword ptr [rbx+12E50h], xmm3
00007FF91DFE50CE  F3 0F 11 93 60 2E 01 00     movss   dword ptr [rbx+12E60h], xmm2
00007FF91DFE50D6  F3 0F 10 83 E0 2F 01 00     movss   xmm0, dword ptr [rbx+12FE0h]
00007FF91DFE50DE  8B 83 D0 2F 01 00           mov     eax, [rbx+12FD0h]
00007FF91DFE50E4  89 83 00 30 01 00           mov     [rbx+13000h], eax
00007FF91DFE50EA  F3 0F 11 83 10 30 01 00     movss   dword ptr [rbx+13010h], xmm0
00007FF91DFE50F2  8B 83 F0 2F 01 00           mov     eax, [rbx+12FF0h]
00007FF91DFE50F8  89 83 20 30 01 00           mov     [rbx+13020h], eax
00007FF91DFE50FE  F3 0F 10 A3 D0 49 01 00     movss   xmm4, dword ptr [rbx+149D0h]
00007FF91DFE5106  8B 83 40 30 01 00           mov     eax, [rbx+13040h]
00007FF91DFE510C  89 83 50 30 01 00           mov     [rbx+13050h], eax
00007FF91DFE5112  F3 0F 10 93 30 30 01 00     movss   xmm2, dword ptr [rbx+13030h]
00007FF91DFE511A  F3 0F 11 93 40 30 01 00     movss   dword ptr [rbx+13040h], xmm2
00007FF91DFE5122  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE5125  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE5128  F3 0F 59 9B 60 30 01 00     mulss   xmm3, dword ptr [rbx+13060h]
00007FF91DFE5130  F3 0F 58 9B 50 30 01 00     addss   xmm3, dword ptr [rbx+13050h]
00007FF91DFE5138  F3 0F 11 9B 40 30 01 00     movss   dword ptr [rbx+13040h], xmm3
00007FF91DFE5140  F3 0F 59 83 70 30 01 00     mulss   xmm0, dword ptr [rbx+13070h]
00007FF91DFE5148  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFE514C  F3 0F 59 9B A0 30 01 00     mulss   xmm3, dword ptr [rbx+130A0h]
00007FF91DFE5154  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFE5158  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFE515B  F3 0F 59 8B 60 30 01 00     mulss   xmm1, dword ptr [rbx+13060h]
00007FF91DFE5163  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE5167  F3 0F 11 8B 30 30 01 00     movss   dword ptr [rbx+13030h], xmm1
00007FF91DFE516F  F3 0F 59 8B 90 30 01 00     mulss   xmm1, dword ptr [rbx+13090h]
00007FF91DFE5177  F3 0F 59 A3 80 30 01 00     mulss   xmm4, dword ptr [rbx+13080h]
00007FF91DFE517F  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE5183  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE5187  F3 0F 11 A3 50 30 01 00     movss   dword ptr [rbx+13050h], xmm4
00007FF91DFE518F  8B 83 80 38 01 00           mov     eax, [rbx+13880h]
00007FF91DFE5195  89 83 90 38 01 00           mov     [rbx+13890h], eax
00007FF91DFE519B  F3 0F 10 8B A0 38 01 00     movss   xmm1, dword ptr [rbx+138A0h]
00007FF91DFE51A3  F3 0F 11 8B B0 38 01 00     movss   dword ptr [rbx+138B0h], xmm1
00007FF91DFE51AB  F3 0F 59 8B 40 2D 01 00     mulss   xmm1, dword ptr [rbx+12D40h]
00007FF91DFE51B3  F3 0F 10 83 90 38 01 00     movss   xmm0, dword ptr [rbx+13890h]
00007FF91DFE51BB  F3 0F 59 83 50 30 01 00     mulss   xmm0, dword ptr [rbx+13050h]
00007FF91DFE51C3  F3 0F 11 8B C0 38 01 00     movss   dword ptr [rbx+138C0h], xmm1
00007FF91DFE51CB  F3 0F 11 83 D0 38 01 00     movss   dword ptr [rbx+138D0h], xmm0
00007FF91DFE51D3  8B 83 00 39 01 00           mov     eax, [rbx+13900h]
00007FF91DFE51D9  89 83 10 39 01 00           mov     [rbx+13910h], eax
00007FF91DFE51DF  F3 0F 59 8B E0 38 01 00     mulss   xmm1, dword ptr [rbx+138E0h]
00007FF91DFE51E7  F3 0F 59 83 F0 38 01 00     mulss   xmm0, dword ptr [rbx+138F0h]
00007FF91DFE51EF  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFE51F3  F3 0F 11 83 00 39 01 00     movss   dword ptr [rbx+13900h], xmm0
00007FF91DFE51FB  8B 83 20 39 01 00           mov     eax, [rbx+13920h]
00007FF91DFE5201  89 83 30 39 01 00           mov     [rbx+13930h], eax
00007FF91DFE5207  8B 83 40 39 01 00           mov     eax, [rbx+13940h]
00007FF91DFE520D  89 83 50 39 01 00           mov     [rbx+13950h], eax
00007FF91DFE5213  8B 83 60 39 01 00           mov     eax, [rbx+13960h]
00007FF91DFE5219  89 83 70 39 01 00           mov     [rbx+13970h], eax
00007FF91DFE521F  8B 83 80 39 01 00           mov     eax, [rbx+13980h]
00007FF91DFE5225  89 83 90 39 01 00           mov     [rbx+13990h], eax
00007FF91DFE522B  F3 0F 10 8B B0 39 01 00     movss   xmm1, dword ptr [rbx+139B0h]
00007FF91DFE5233  F3 0F 10 93 C0 39 01 00     movss   xmm2, dword ptr [rbx+139C0h]
00007FF91DFE523B  0F 28 E1                    movaps  xmm4, xmm1
00007FF91DFE523E  F3 0F 59 A3 20 39 01 00     mulss   xmm4, dword ptr [rbx+13920h]
00007FF91DFE5246  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE5249  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE524D  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFE5251  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFE5255  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFE5258  0F 28 CC                    movaps  xmm1, xmm4
00007FF91DFE525B  F3 0F 59 8B E0 39 01 00     mulss   xmm1, dword ptr [rbx+139E0h]
00007FF91DFE5263  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE5267  F3 0F 58 8B D0 39 01 00     addss   xmm1, dword ptr [rbx+139D0h]
00007FF91DFE526F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE5272  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE5276  F3 0F 59 83 F0 39 01 00     mulss   xmm0, dword ptr [rbx+139F0h]
00007FF91DFE527E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE5282  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE5285  F3 0F 59 9B 00 3A 01 00     mulss   xmm3, dword ptr [rbx+13A00h]
00007FF91DFE528D  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE5291  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE5295  F3 0F 59 83 10 3A 01 00     mulss   xmm0, dword ptr [rbx+13A10h]
00007FF91DFE529D  F3 0F 58 C3                 addss   xmm0, xmm3
00007FF91DFE52A1  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE52A5  76 05                       jbe     short loc_7FF91DFE52AC
00007FF91DFE52A7  0F 5A C0                    cvtps2pd xmm0, xmm0
00007FF91DFE52AA  EB 03                       jmp     short loc_7FF91DFE52AF
00007FF91DFE52AC  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE52AF  66 0F 5A C8                 cvtpd2ps xmm1, xmm0
00007FF91DFE52B3  41 0F 2F CD                 comiss  xmm1, xmm13
00007FF91DFE52B7  73 04                       jnb     short loc_7FF91DFE52BD
00007FF91DFE52B9  44 0F 5A E1                 cvtps2pd xmm12, xmm1
00007FF91DFE52BD  66 41 0F 5A C4              cvtpd2ps xmm0, xmm12
00007FF91DFE52C2  F3 0F 11 83 A0 39 01 00     movss   dword ptr [rbx+139A0h], xmm0
00007FF91DFE52CA  8B 83 20 3A 01 00           mov     eax, [rbx+13A20h]
00007FF91DFE52D0  89 83 30 3A 01 00           mov     [rbx+13A30h], eax
00007FF91DFE52D6  F3 0F 10 8B 40 3A 01 00     movss   xmm1, dword ptr [rbx+13A40h]
00007FF91DFE52DE  F3 0F 11 8B 50 3A 01 00     movss   dword ptr [rbx+13A50h], xmm1
00007FF91DFE52E6  F3 0F 10 83 60 3A 01 00     movss   xmm0, dword ptr [rbx+13A60h]
00007FF91DFE52EE  F3 0F 11 83 70 3A 01 00     movss   dword ptr [rbx+13A70h], xmm0
00007FF91DFE52F6  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE52FA  F3 0F 59 8B 80 3A 01 00     mulss   xmm1, dword ptr [rbx+13A80h]
00007FF91DFE5302  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE5306  F3 0F 11 8B 60 3A 01 00     movss   dword ptr [rbx+13A60h], xmm1
00007FF91DFE530E  F3 0F 10 8B 60 22 01 00     movss   xmm1, dword ptr [rbx+12260h]
00007FF91DFE5316  F3 0F 10 83 E0 22 01 00     movss   xmm0, dword ptr [rbx+122E0h]
00007FF91DFE531E  8B 83 B0 3A 01 00           mov     eax, [rbx+13AB0h]
00007FF91DFE5324  89 83 C0 3A 01 00           mov     [rbx+13AC0h], eax
00007FF91DFE532A  F3 0F 59 83 A0 3A 01 00     mulss   xmm0, dword ptr [rbx+13AA0h]
00007FF91DFE5332  F3 0F 59 8B 90 3A 01 00     mulss   xmm1, dword ptr [rbx+13A90h]
00007FF91DFE533A  F3 0F 58 C1                 addss   xmm0, xmm1
00007FF91DFE533E  F3 0F 11 83 B0 3A 01 00     movss   dword ptr [rbx+13AB0h], xmm0
00007FF91DFE5346  8B 83 D0 3A 01 00           mov     eax, [rbx+13AD0h]
00007FF91DFE534C  89 83 F0 3A 01 00           mov     [rbx+13AF0h], eax
00007FF91DFE5352  F3 0F 10 9B E0 3A 01 00     movss   xmm3, dword ptr [rbx+13AE0h]
00007FF91DFE535A  F3 0F 11 9B 00 3B 01 00     movss   dword ptr [rbx+13B00h], xmm3
00007FF91DFE5362  F3 0F 10 8B F0 3A 01 00     movss   xmm1, dword ptr [rbx+13AF0h]
00007FF91DFE536A  F3 0F 10 93 30 2A 01 00     movss   xmm2, dword ptr [rbx+12A30h]
00007FF91DFE5372  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE5375  F3 0F 59 83 10 2C 01 00     mulss   xmm0, dword ptr [rbx+12C10h]
00007FF91DFE537D  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFE5381  F3 0F 5C C1                 subss   xmm0, xmm1
00007FF91DFE5385  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE5388  F3 0F 59 8B 60 39 01 00     mulss   xmm1, dword ptr [rbx+13960h]
00007FF91DFE5390  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE5394  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFE5398  F3 0F 5C CB                 subss   xmm1, xmm3
00007FF91DFE539C  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE53A0  F3 0F 11 8B 10 3B 01 00     movss   dword ptr [rbx+13B10h], xmm1
00007FF91DFE53A8  F3 0F 10 9B 70 26 01 00     movss   xmm3, dword ptr [rbx+12670h]
00007FF91DFE53B0  F3 0F 10 83 20 3B 01 00     movss   xmm0, dword ptr [rbx+13B20h]
00007FF91DFE53B8  F3 0F 11 83 30 3B 01 00     movss   dword ptr [rbx+13B30h], xmm0
00007FF91DFE53C0  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE53C4  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE53C7  F3 0F 59 8B 40 3B 01 00     mulss   xmm1, dword ptr [rbx+13B40h]
00007FF91DFE53CF  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE53D3  F3 0F 10 83 60 3B 01 00     movss   xmm0, dword ptr [rbx+13B60h]
00007FF91DFE53DB  F3 0F 11 8B 20 3B 01 00     movss   dword ptr [rbx+13B20h], xmm1
00007FF91DFE53E3  F3 0F 59 9B 50 3B 01 00     mulss   xmm3, dword ptr [rbx+13B50h]
00007FF91DFE53EB  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE53EF  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE53F3  F3 0F 11 9B 30 3B 01 00     movss   dword ptr [rbx+13B30h], xmm3
00007FF91DFE53FB  F3 0F 10 83 70 3B 01 00     movss   xmm0, dword ptr [rbx+13B70h]
00007FF91DFE5403  F3 0F 10 BB 80 26 01 00     movss   xmm7, dword ptr [rbx+12680h]
00007FF91DFE540B  F3 0F 11 83 80 3B 01 00     movss   dword ptr [rbx+13B80h], xmm0
00007FF91DFE5413  F3 0F 5C F8                 subss   xmm7, xmm0
00007FF91DFE5417  0F 28 CF                    movaps  xmm1, xmm7
00007FF91DFE541A  F3 0F 59 8B 90 3B 01 00     mulss   xmm1, dword ptr [rbx+13B90h]
00007FF91DFE5422  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE5426  F3 0F 10 83 B0 3B 01 00     movss   xmm0, dword ptr [rbx+13BB0h]
00007FF91DFE542E  F3 0F 11 8B 70 3B 01 00     movss   dword ptr [rbx+13B70h], xmm1
00007FF91DFE5436  F3 0F 59 BB A0 3B 01 00     mulss   xmm7, dword ptr [rbx+13BA0h]
00007FF91DFE543E  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE5442  F3 0F 58 F8                 addss   xmm7, xmm0
00007FF91DFE5446  F3 0F 11 BB 80 3B 01 00     movss   dword ptr [rbx+13B80h], xmm7
00007FF91DFE544E  F3 0F 10 A3 30 3B 01 00     movss   xmm4, dword ptr [rbx+13B30h]
00007FF91DFE5456  F3 0F 10 AB 10 3B 01 00     movss   xmm5, dword ptr [rbx+13B10h]
00007FF91DFE545E  F3 0F 10 B3 B0 3A 01 00     movss   xmm6, dword ptr [rbx+13AB0h]
00007FF91DFE5466  F3 44 0F 10 8B 40 39 01 00  movss   xmm9, dword ptr [rbx+13940h]
00007FF91DFE546F  8B 83 60 3A 01 00           mov     eax, [rbx+13A60h]
00007FF91DFE5475  89 83 C0 3B 01 00           mov     [rbx+13BC0h], eax
00007FF91DFE547B  F3 44 0F 11 8B D0 3B 01 00  movss   dword ptr [rbx+13BD0h], xmm9
00007FF91DFE5484  F3 0F 10 83 F0 3B 01 00     movss   xmm0, dword ptr [rbx+13BF0h]
00007FF91DFE548C  F3 0F 10 93 00 3C 01 00     movss   xmm2, dword ptr [rbx+13C00h]
00007FF91DFE5494  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFE5498  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE549B  F3 0F 59 9B 80 39 01 00     mulss   xmm3, dword ptr [rbx+13980h]
00007FF91DFE54A3  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE54A7  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE54AA  F3 0F 59 C7                 mulss   xmm0, xmm7
00007FF91DFE54AE  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFE54B2  F3 44 0F 5C C0              subss   xmm8, xmm0
00007FF91DFE54B7  F3 44 0F 58 C7              addss   xmm8, xmm7
00007FF91DFE54BC  F3 44 0F 59 83 30 3C 01 00  mulss   xmm8, dword ptr [rbx+13C30h]
00007FF91DFE54C5  F3 0F 10 8B 10 3C 01 00     movss   xmm1, dword ptr [rbx+13C10h]
00007FF91DFE54CD  F3 0F 58 B3 B0 3C 01 00     addss   xmm6, dword ptr [rbx+13CB0h]
00007FF91DFE54D5  F3 44 0F 59 83 40 3C 01 00  mulss   xmm8, dword ptr [rbx+13C40h]
00007FF91DFE54DE  F3 0F 59 AB 50 3C 01 00     mulss   xmm5, dword ptr [rbx+13C50h]
00007FF91DFE54E6  F3 0F 59 B3 60 3C 01 00     mulss   xmm6, dword ptr [rbx+13C60h]
00007FF91DFE54EE  F3 44 0F 59 C9              mulss   xmm9, xmm1
00007FF91DFE54F3  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE54F7  F3 0F 58 F5                 addss   xmm6, xmm5
00007FF91DFE54FB  F3 0F 5C DA                 subss   xmm3, xmm2
00007FF91DFE54FF  F3 0F 10 93 90 3C 01 00     movss   xmm2, dword ptr [rbx+13C90h]
00007FF91DFE5507  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE550A  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE550E  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFE5512  F3 44 0F 5C C8              subss   xmm9, xmm0
00007FF91DFE5517  F3 0F 10 83 80 3C 01 00     movss   xmm0, dword ptr [rbx+13C80h]
00007FF91DFE551F  F3 0F 58 83 C0 3B 01 00     addss   xmm0, dword ptr [rbx+13BC0h]
00007FF91DFE5527  F3 0F 59 9B 20 3C 01 00     mulss   xmm3, dword ptr [rbx+13C20h]
00007FF91DFE552F  F3 0F 59 83 C0 3C 01 00     mulss   xmm0, dword ptr [rbx+13CC0h]
00007FF91DFE5537  F3 44 0F 58 CA              addss   xmm9, xmm2
00007FF91DFE553C  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFE5541  F3 0F 59 83 70 3C 01 00     mulss   xmm0, dword ptr [rbx+13C70h]
00007FF91DFE5549  F3 44 0F 59 8B A0 3C 01 00  mulss   xmm9, dword ptr [rbx+13CA0h]
00007FF91DFE5552  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFE5557  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFE555C  F3 45 0F 58 C8              addss   xmm9, xmm8
00007FF91DFE5561  F3 44 0F 11 8B E0 3B 01 00  movss   dword ptr [rbx+13BE0h], xmm9
00007FF91DFE556A  F3 0F 10 BB A0 39 01 00     movss   xmm7, dword ptr [rbx+139A0h]
00007FF91DFE5572  F3 44 0F 10 83 30 3A 01 00  movss   xmm8, dword ptr [rbx+13A30h]
00007FF91DFE557B  8B 83 00 3D 01 00           mov     eax, [rbx+13D00h]
00007FF91DFE5581  89 83 10 3D 01 00           mov     [rbx+13D10h], eax
00007FF91DFE5587  F3 0F 10 83 F0 3C 01 00     movss   xmm0, dword ptr [rbx+13CF0h]
00007FF91DFE558F  F3 0F 11 83 00 3D 01 00     movss   dword ptr [rbx+13D00h], xmm0
00007FF91DFE5597  44 0F 2E AB 40 3D 01 00     ucomiss xmm13, dword ptr [rbx+13D40h]
00007FF91DFE559F  0F 85 8F 02 00 00           jnz     loc_7FF91DFE5834
00007FF91DFE55A5  F3 0F 10 8B 90 3D 01 00     movss   xmm1, dword ptr [rbx+13D90h]
00007FF91DFE55AD  F3 0F 10 B3 10 3D 01 00     movss   xmm6, dword ptr [rbx+13D10h]
00007FF91DFE55B5  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFE55B8  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFE55BC  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFE55C0  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFE55C4  F3 0F 5C D1                 subss   xmm2, xmm1
00007FF91DFE55C8  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFE55CC  F3 0F 11 B3 00 3D 01 00     movss   dword ptr [rbx+13D00h], xmm6
00007FF91DFE55D4  F3 0F 59 B3 80 3D 01 00     mulss   xmm6, dword ptr [rbx+13D80h]
00007FF91DFE55DC  F3 0F 58 B3 20 3D 01 00     addss   xmm6, dword ptr [rbx+13D20h]
00007FF91DFE55E4  E8 77 37 FE FF              call    sub_7FF91DFC8D60
00007FF91DFE55E9  F3 0F 11 83 F0 3C 01 00     movss   dword ptr [rbx+13CF0h], xmm0
00007FF91DFE55F1  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFE55F5  F3 0F 59 8B E0 3D 01 00     mulss   xmm1, dword ptr [rbx+13DE0h]
00007FF91DFE55FD  41 0F 28 D5                 movaps  xmm2, xmm13
00007FF91DFE5601  F3 41 0F 5C D0              subss   xmm2, xmm8
00007FF91DFE5606  F3 0F 58 8B 30 3D 01 00     addss   xmm1, dword ptr [rbx+13D30h]
00007FF91DFE560E  F3 0F 59 93 A0 3D 01 00     mulss   xmm2, dword ptr [rbx+13DA0h]
00007FF91DFE5616  F3 0F 11 8B E0 3C 01 00     movss   dword ptr [rbx+13CE0h], xmm1
00007FF91DFE561E  F3 44 0F 59 8B 70 3D 01 00  mulss   xmm9, dword ptr [rbx+13D70h]
00007FF91DFE5627  F3 0F 59 BB 50 3D 01 00     mulss   xmm7, dword ptr [rbx+13D50h]
00007FF91DFE562F  F3 0F 10 83 B0 3D 01 00     movss   xmm0, dword ptr [rbx+13DB0h]
00007FF91DFE5637  F3 0F 5D C2                 minss   xmm0, xmm2
00007FF91DFE563B  F3 44 0F 58 CF              addss   xmm9, xmm7
00007FF91DFE5640  F3 44 0F 58 CE              addss   xmm9, xmm6
00007FF91DFE5645  F3 44 0F 58 C8              addss   xmm9, xmm0
00007FF91DFE564A  F3 44 0F 58 8B 60 3D 01 00  addss   xmm9, dword ptr [rbx+13D60h]
00007FF91DFE5653  F3 44 0F 5D 8B C0 3D 01 00  minss   xmm9, dword ptr [rbx+13DC0h]
00007FF91DFE565C  F3 44 0F 5F 8B D0 3D 01 00  maxss   xmm9, dword ptr [rbx+13DD0h]
00007FF91DFE5665  F3 44 0F 59 8B 00 3E 01 00  mulss   xmm9, dword ptr [rbx+13E00h]
00007FF91DFE566E  F3 44 0F 58 8B 10 3E 01 00  addss   xmm9, dword ptr [rbx+13E10h]
00007FF91DFE5677  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFE567B  F3 0F 2C C9                 cvttss2si ecx, xmm1
00007FF91DFE567F  81 F9 00 00 00 80           cmp     ecx, 80000000h
00007FF91DFE5685  74 1E                       jz      short loc_7FF91DFE56A5
00007FF91DFE5687  66 0F 6E C1                 movd    xmm0, ecx
00007FF91DFE568B  0F 5B C0                    cvtdq2ps xmm0, xmm0
00007FF91DFE568E  0F 2E C1                    ucomiss xmm0, xmm1
00007FF91DFE5691  74 12                       jz      short loc_7FF91DFE56A5
00007FF91DFE5693  0F 14 C9                    unpcklps xmm1, xmm1
00007FF91DFE5696  0F 50 C1                    movmskps eax, xmm1
00007FF91DFE5699  83 E0 01                    and     eax, 1
00007FF91DFE569C  2B C8                       sub     ecx, eax
00007FF91DFE569E  66 0F 6E C9                 movd    xmm1, ecx
00007FF91DFE56A2  0F 5B C9                    cvtdq2ps xmm1, xmm1
00007FF91DFE56A5  F3 44 0F 5C C9              subss   xmm9, xmm1
00007FF91DFE56AA  0F 28 C1                    movaps  xmm0, xmm1; X
00007FF91DFE56AD  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFE56B1  F3 41 0F 59 F1              mulss   xmm6, xmm9
00007FF91DFE56B6  F3 0F 59 35 12 F9 75 00     mulss   xmm6, cs:dword_7FF91E744FD0
00007FF91DFE56BE  E8 7D A0 36 00              call    expf
00007FF91DFE56C3  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFE56C6  41 0F 28 D1                 movaps  xmm2, xmm9
00007FF91DFE56CA  F3 0F 59 93 D0 3E 01 00     mulss   xmm2, dword ptr [rbx+13ED0h]
00007FF91DFE56D2  41 0F 28 C9                 movaps  xmm1, xmm9
00007FF91DFE56D6  F3 0F 59 8B B0 3E 01 00     mulss   xmm1, dword ptr [rbx+13EB0h]
00007FF91DFE56DE  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFE56E2  F3 0F 58 93 C0 3E 01 00     addss   xmm2, dword ptr [rbx+13EC0h]
00007FF91DFE56EA  F3 0F 59 83 90 3E 01 00     mulss   xmm0, dword ptr [rbx+13E90h]
00007FF91DFE56F2  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE56F6  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE56FA  F3 0F 58 93 A0 3E 01 00     addss   xmm2, dword ptr [rbx+13EA0h]
00007FF91DFE5702  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE5706  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE570A  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFE570E  F3 0F 59 83 70 3E 01 00     mulss   xmm0, dword ptr [rbx+13E70h]
00007FF91DFE5716  F3 0F 58 93 80 3E 01 00     addss   xmm2, dword ptr [rbx+13E80h]
00007FF91DFE571E  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE5722  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE5726  41 0F 28 C1                 movaps  xmm0, xmm9
00007FF91DFE572A  F3 0F 59 83 50 3E 01 00     mulss   xmm0, dword ptr [rbx+13E50h]
00007FF91DFE5732  F3 44 0F 59 8B 30 3E 01 00  mulss   xmm9, dword ptr [rbx+13E30h]
00007FF91DFE573B  F3 0F 58 93 60 3E 01 00     addss   xmm2, dword ptr [rbx+13E60h]
00007FF91DFE5743  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE5747  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE574B  F3 0F 58 93 40 3E 01 00     addss   xmm2, dword ptr [rbx+13E40h]
00007FF91DFE5753  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE5757  F3 41 0F 58 D1              addss   xmm2, xmm9
00007FF91DFE575C  F3 41 0F 58 D5              addss   xmm2, xmm13
00007FF91DFE5761  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFE5765  F3 0F 59 A3 20 3E 01 00     mulss   xmm4, dword ptr [rbx+13E20h]
00007FF91DFE576D  0F 28 DC                    movaps  xmm3, xmm4
00007FF91DFE5770  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE5774  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE5777  44 0F 28 C3                 movaps  xmm8, xmm3
00007FF91DFE577B  F3 44 0F 59 83 70 3F 01 00  mulss   xmm8, dword ptr [rbx+13F70h]
00007FF91DFE5784  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE5787  F3 0F 59 83 30 3F 01 00     mulss   xmm0, dword ptr [rbx+13F30h]
00007FF91DFE578F  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFE5792  F3 44 0F 58 83 50 3F 01 00  addss   xmm8, dword ptr [rbx+13F50h]
00007FF91DFE579B  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE579F  F3 0F 58 83 10 3F 01 00     addss   xmm0, dword ptr [rbx+13F10h]
00007FF91DFE57A7  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE57AB  F3 44 0F 59 C2              mulss   xmm8, xmm2
00007FF91DFE57B0  F3 44 0F 58 C0              addss   xmm8, xmm0
00007FF91DFE57B5  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE57B8  F3 0F 59 8B F0 3E 01 00     mulss   xmm1, dword ptr [rbx+13EF0h]
00007FF91DFE57C0  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE57C4  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFE57C9  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE57CC  F3 0F 59 83 20 3F 01 00     mulss   xmm0, dword ptr [rbx+13F20h]
00007FF91DFE57D4  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFE57D9  0F 28 CB                    movaps  xmm1, xmm3
00007FF91DFE57DC  F3 0F 59 8B 60 3F 01 00     mulss   xmm1, dword ptr [rbx+13F60h]
00007FF91DFE57E4  F3 0F 59 9B E0 3E 01 00     mulss   xmm3, dword ptr [rbx+13EE0h]
00007FF91DFE57EC  F3 0F 58 8B 40 3F 01 00     addss   xmm1, dword ptr [rbx+13F40h]
00007FF91DFE57F4  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFE57F9  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFE57FD  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE5801  F3 0F 58 8B 00 3F 01 00     addss   xmm1, dword ptr [rbx+13F00h]
00007FF91DFE5809  F3 0F 59 CA                 mulss   xmm1, xmm2
00007FF91DFE580D  F3 0F 58 CB                 addss   xmm1, xmm3
00007FF91DFE5811  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFE5816  F3 44 0F 5E C1              divss   xmm8, xmm1
00007FF91DFE581B  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFE581F  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE5824  F3 44 0F 5E C0              divss   xmm8, xmm0
00007FF91DFE5829  F3 44 0F 11 83 D0 3C 01 00  movss   dword ptr [rbx+13CD0h], xmm8
00007FF91DFE5832  EB 09                       jmp     short loc_7FF91DFE583D
00007FF91DFE5834  F3 44 0F 10 83 D0 3C 01 00  movss   xmm8, dword ptr [rbx+13CD0h]
00007FF91DFE583D  8B 83 E0 3F 01 00           mov     eax, [rbx+13FE0h]
00007FF91DFE5843  F3 0F 10 8B 00 39 01 00     movss   xmm1, dword ptr [rbx+13900h]
00007FF91DFE584B  F3 44 0F 10 8B E0 3C 01 00  movss   xmm9, dword ptr [rbx+13CE0h]
00007FF91DFE5854  89 83 F0 3F 01 00           mov     [rbx+13FF0h], eax
00007FF91DFE585A  8B 83 D0 3F 01 00           mov     eax, [rbx+13FD0h]
00007FF91DFE5860  89 83 E0 3F 01 00           mov     [rbx+13FE0h], eax
00007FF91DFE5866  8B 83 C0 3F 01 00           mov     eax, [rbx+13FC0h]
00007FF91DFE586C  89 83 D0 3F 01 00           mov     [rbx+13FD0h], eax
00007FF91DFE5872  8B 83 B0 3F 01 00           mov     eax, [rbx+13FB0h]
00007FF91DFE5878  89 83 C0 3F 01 00           mov     [rbx+13FC0h], eax
00007FF91DFE587E  8B 83 A0 3F 01 00           mov     eax, [rbx+13FA0h]
00007FF91DFE5884  89 83 B0 3F 01 00           mov     [rbx+13FB0h], eax
00007FF91DFE588A  8B 83 90 3F 01 00           mov     eax, [rbx+13F90h]
00007FF91DFE5890  89 83 A0 3F 01 00           mov     [rbx+13FA0h], eax
00007FF91DFE5896  8B 83 80 3F 01 00           mov     eax, [rbx+13F80h]
00007FF91DFE589C  89 83 90 3F 01 00           mov     [rbx+13F90h], eax
00007FF91DFE58A2  8B 83 C0 40 01 00           mov     eax, [rbx+140C0h]
00007FF91DFE58A8  89 83 D0 40 01 00           mov     [rbx+140D0h], eax
00007FF91DFE58AE  8B 83 B0 40 01 00           mov     eax, [rbx+140B0h]
00007FF91DFE58B4  89 83 C0 40 01 00           mov     [rbx+140C0h], eax
00007FF91DFE58BA  8B 83 A0 40 01 00           mov     eax, [rbx+140A0h]
00007FF91DFE58C0  89 83 B0 40 01 00           mov     [rbx+140B0h], eax
00007FF91DFE58C6  8B 83 90 40 01 00           mov     eax, [rbx+14090h]
00007FF91DFE58CC  89 83 A0 40 01 00           mov     [rbx+140A0h], eax
00007FF91DFE58D2  8B 83 80 40 01 00           mov     eax, [rbx+14080h]
00007FF91DFE58D8  89 83 90 40 01 00           mov     [rbx+14090h], eax
00007FF91DFE58DE  8B 83 70 40 01 00           mov     eax, [rbx+14070h]
00007FF91DFE58E4  89 83 80 40 01 00           mov     [rbx+14080h], eax
00007FF91DFE58EA  8B 83 60 40 01 00           mov     eax, [rbx+14060h]
00007FF91DFE58F0  89 83 70 40 01 00           mov     [rbx+14070h], eax
00007FF91DFE58F6  8B 83 40 41 01 00           mov     eax, [rbx+14140h]
00007FF91DFE58FC  89 83 50 41 01 00           mov     [rbx+14150h], eax
00007FF91DFE5902  8B 83 30 41 01 00           mov     eax, [rbx+14130h]
00007FF91DFE5908  89 83 40 41 01 00           mov     [rbx+14140h], eax
00007FF91DFE590E  8B 83 20 41 01 00           mov     eax, [rbx+14120h]
00007FF91DFE5914  89 83 30 41 01 00           mov     [rbx+14130h], eax
00007FF91DFE591A  8B 83 10 41 01 00           mov     eax, [rbx+14110h]
00007FF91DFE5920  89 83 20 41 01 00           mov     [rbx+14120h], eax
00007FF91DFE5926  8B 83 00 41 01 00           mov     eax, [rbx+14100h]
00007FF91DFE592C  89 83 10 41 01 00           mov     [rbx+14110h], eax
00007FF91DFE5932  8B 83 F0 40 01 00           mov     eax, [rbx+140F0h]
00007FF91DFE5938  89 83 00 41 01 00           mov     [rbx+14100h], eax
00007FF91DFE593E  8B 83 E0 40 01 00           mov     eax, [rbx+140E0h]
00007FF91DFE5944  89 83 F0 40 01 00           mov     [rbx+140F0h], eax
00007FF91DFE594A  8B 83 C0 41 01 00           mov     eax, [rbx+141C0h]
00007FF91DFE5950  89 83 D0 41 01 00           mov     [rbx+141D0h], eax
00007FF91DFE5956  8B 83 B0 41 01 00           mov     eax, [rbx+141B0h]
00007FF91DFE595C  89 83 C0 41 01 00           mov     [rbx+141C0h], eax
00007FF91DFE5962  8B 83 A0 41 01 00           mov     eax, [rbx+141A0h]
00007FF91DFE5968  89 83 B0 41 01 00           mov     [rbx+141B0h], eax
00007FF91DFE596E  8B 83 90 41 01 00           mov     eax, [rbx+14190h]
00007FF91DFE5974  89 83 A0 41 01 00           mov     [rbx+141A0h], eax
00007FF91DFE597A  8B 83 80 41 01 00           mov     eax, [rbx+14180h]
00007FF91DFE5980  89 83 90 41 01 00           mov     [rbx+14190h], eax
00007FF91DFE5986  8B 83 70 41 01 00           mov     eax, [rbx+14170h]
00007FF91DFE598C  89 83 80 41 01 00           mov     [rbx+14180h], eax
00007FF91DFE5992  8B 83 60 41 01 00           mov     eax, [rbx+14160h]
00007FF91DFE5998  89 83 70 41 01 00           mov     [rbx+14170h], eax
00007FF91DFE599E  8B 83 40 42 01 00           mov     eax, [rbx+14240h]
00007FF91DFE59A4  89 83 50 42 01 00           mov     [rbx+14250h], eax
00007FF91DFE59AA  8B 83 30 42 01 00           mov     eax, [rbx+14230h]
00007FF91DFE59B0  89 83 40 42 01 00           mov     [rbx+14240h], eax
00007FF91DFE59B6  8B 83 20 42 01 00           mov     eax, [rbx+14220h]
00007FF91DFE59BC  89 83 30 42 01 00           mov     [rbx+14230h], eax
00007FF91DFE59C2  8B 83 10 42 01 00           mov     eax, [rbx+14210h]
00007FF91DFE59C8  89 83 20 42 01 00           mov     [rbx+14220h], eax
00007FF91DFE59CE  8B 83 00 42 01 00           mov     eax, [rbx+14200h]
00007FF91DFE59D4  89 83 10 42 01 00           mov     [rbx+14210h], eax
00007FF91DFE59DA  8B 83 F0 41 01 00           mov     eax, [rbx+141F0h]
00007FF91DFE59E0  89 83 00 42 01 00           mov     [rbx+14200h], eax
00007FF91DFE59E6  8B 83 E0 41 01 00           mov     eax, [rbx+141E0h]
00007FF91DFE59EC  89 83 F0 41 01 00           mov     [rbx+141F0h], eax
00007FF91DFE59F2  8B 83 60 42 01 00           mov     eax, [rbx+14260h]
00007FF91DFE59F8  89 83 70 42 01 00           mov     [rbx+14270h], eax
00007FF91DFE59FE  F3 0F 10 83 80 42 01 00     movss   xmm0, dword ptr [rbx+14280h]
00007FF91DFE5A06  F3 0F 11 83 90 42 01 00     movss   dword ptr [rbx+14290h], xmm0
00007FF91DFE5A0E  44 0F 2E AB D0 42 01 00     ucomiss xmm13, dword ptr [rbx+142D0h]
00007FF91DFE5A16  0F 85 49 09 00 00           jnz     loc_7FF91DFE6365
00007FF91DFE5A1C  F3 0F 59 8B 20 43 01 00     mulss   xmm1, dword ptr [rbx+14320h]
00007FF91DFE5A24  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFE5A28  41 0F 28 F1                 movaps  xmm6, xmm9
00007FF91DFE5A2C  41 0F 28 F8                 movaps  xmm7, xmm8
00007FF91DFE5A30  F3 0F 59 B3 40 43 01 00     mulss   xmm6, dword ptr [rbx+14340h]
00007FF91DFE5A38  F3 41 0F 59 F8              mulss   xmm7, xmm8
00007FF91DFE5A3D  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE5A42  F3 0F 59 F1                 mulss   xmm6, xmm1
00007FF91DFE5A46  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFE5A49  F3 0F 59 8B 10 43 01 00     mulss   xmm1, dword ptr [rbx+14310h]
00007FF91DFE5A51  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFE5A55  E8 06 33 FE FF              call    sub_7FF91DFC8D60
00007FF91DFE5A5A  F3 0F 11 83 80 42 01 00     movss   dword ptr [rbx+14280h], xmm0
00007FF91DFE5A62  41 0F 28 DD                 movaps  xmm3, xmm13
00007FF91DFE5A66  F3 0F 11 B3 60 42 01 00     movss   dword ptr [rbx+14260h], xmm6
00007FF91DFE5A6E  41 0F 28 C0                 movaps  xmm0, xmm8
00007FF91DFE5A72  F3 0F 59 FF                 mulss   xmm7, xmm7
00007FF91DFE5A76  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFE5A7B  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE5A7F  F3 41 0F 59 F9              mulss   xmm7, xmm9
00007FF91DFE5A84  F3 0F 5C F0                 subss   xmm6, xmm0
00007FF91DFE5A88  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE5A8D  F3 0F 5E DF                 divss   xmm3, xmm7
00007FF91DFE5A91  F3 0F 11 9B B0 42 01 00     movss   dword ptr [rbx+142B0h], xmm3
00007FF91DFE5A99  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFE5A9C  F3 0F 10 8B 60 42 01 00     movss   xmm1, dword ptr [rbx+14260h]
00007FF91DFE5AA4  F3 0F 10 AB 70 42 01 00     movss   xmm5, dword ptr [rbx+14270h]
00007FF91DFE5AAC  F3 41 0F 59 E1              mulss   xmm4, xmm9
00007FF91DFE5AB1  F3 0F 11 A3 A0 42 01 00     movss   dword ptr [rbx+142A0h], xmm4
00007FF91DFE5AB9  F3 0F 59 AB 70 43 01 00     mulss   xmm5, dword ptr [rbx+14370h]
00007FF91DFE5AC1  F3 0F 10 93 E0 3F 01 00     movss   xmm2, dword ptr [rbx+13FE0h]
00007FF91DFE5AC9  F3 0F 59 8B 80 43 01 00     mulss   xmm1, dword ptr [rbx+14380h]
00007FF91DFE5AD1  F3 0F 10 83 F0 3F 01 00     movss   xmm0, dword ptr [rbx+13FF0h]
00007FF91DFE5AD9  F3 0F 11 93 50 40 01 00     movss   dword ptr [rbx+14050h], xmm2
00007FF91DFE5AE1  F3 0F 59 93 A0 44 01 00     mulss   xmm2, dword ptr [rbx+144A0h]
00007FF91DFE5AE9  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE5AED  F3 0F 59 83 B0 44 01 00     mulss   xmm0, dword ptr [rbx+144B0h]
00007FF91DFE5AF5  F3 0F 59 EB                 mulss   xmm5, xmm3
00007FF91DFE5AF9  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE5AFD  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE5B01  F3 0F 5C EA                 subss   xmm5, xmm2
00007FF91DFE5B05  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE5B09  73 06                       jnb     short loc_7FF91DFE5B11
00007FF91DFE5B0B  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE5B0F  EB 05                       jmp     short loc_7FF91DFE5B16
00007FF91DFE5B11  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE5B16  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFE5B19  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE5B1C  F3 0F 59 83 50 43 01 00     mulss   xmm0, dword ptr [rbx+14350h]
00007FF91DFE5B24  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE5B28  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE5B2C  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE5B30  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE5B34  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE5B38  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE5B3C  F3 0F 11 AB 00 40 01 00     movss   dword ptr [rbx+14000h], xmm5
00007FF91DFE5B44  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE5B47  F3 0F 58 AB 90 3F 01 00     addss   xmm5, dword ptr [rbx+13F90h]
00007FF91DFE5B4F  F3 0F 10 9B A0 3F 01 00     movss   xmm3, dword ptr [rbx+13FA0h]
00007FF91DFE5B57  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE5B5A  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE5B5E  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE5B62  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFE5B66  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFE5B6A  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE5B6E  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE5B72  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5B75  F3 0F 11 A3 10 40 01 00     movss   dword ptr [rbx+14010h], xmm4
00007FF91DFE5B7D  F3 0F 10 8B B0 3F 01 00     movss   xmm1, dword ptr [rbx+13FB0h]
00007FF91DFE5B85  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE5B89  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE5B8D  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE5B90  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE5B94  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFE5B98  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE5B9C  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFE5BA0  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE5BA4  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE5BA8  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE5BAC  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE5BB0  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5BB3  F3 0F 11 9B 20 40 01 00     movss   dword ptr [rbx+14020h], xmm3
00007FF91DFE5BBB  F3 0F 10 AB C0 3F 01 00     movss   xmm5, dword ptr [rbx+13FC0h]
00007FF91DFE5BC3  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE5BC7  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE5BCB  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE5BCE  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE5BD2  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE5BD6  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE5BDA  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFE5BDE  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE5BE2  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE5BE6  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE5BEA  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE5BEE  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5BF1  F3 0F 11 93 30 40 01 00     movss   dword ptr [rbx+14030h], xmm2
00007FF91DFE5BF9  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFE5BFD  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE5C01  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE5C05  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFE5C0A  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5C0D  F3 0F 59 83 D0 3F 01 00     mulss   xmm0, dword ptr [rbx+13FD0h]
00007FF91DFE5C15  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE5C19  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE5C1D  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5C20  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFE5C24  F3 0F 11 AB 40 40 01 00     movss   dword ptr [rbx+14040h], xmm5
00007FF91DFE5C2C  F3 0F 10 93 30 40 01 00     movss   xmm2, dword ptr [rbx+14030h]
00007FF91DFE5C34  F3 0F 59 93 F0 42 01 00     mulss   xmm2, dword ptr [rbx+142F0h]
00007FF91DFE5C3C  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE5C40  F3 0F 59 AB 00 43 01 00     mulss   xmm5, dword ptr [rbx+14300h]
00007FF91DFE5C48  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE5C4C  F3 0F 10 83 E0 42 01 00     movss   xmm0, dword ptr [rbx+142E0h]
00007FF91DFE5C54  F3 0F 59 83 20 40 01 00     mulss   xmm0, dword ptr [rbx+14020h]
00007FF91DFE5C5C  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFE5C60  F3 0F 10 AB 70 42 01 00     movss   xmm5, dword ptr [rbx+14270h]
00007FF91DFE5C68  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE5C6C  F3 0F 11 93 E0 41 01 00     movss   dword ptr [rbx+141E0h], xmm2
00007FF91DFE5C74  F3 0F 58 AB 60 42 01 00     addss   xmm5, dword ptr [rbx+14260h]
00007FF91DFE5C7C  F3 0F 10 83 50 40 01 00     movss   xmm0, dword ptr [rbx+14050h]
00007FF91DFE5C84  F3 0F 59 AB 90 43 01 00     mulss   xmm5, dword ptr [rbx+14390h]
00007FF91DFE5C8C  F3 0F 59 AB B0 42 01 00     mulss   xmm5, dword ptr [rbx+142B0h]
00007FF91DFE5C94  F3 0F 11 A3 50 40 01 00     movss   dword ptr [rbx+14050h], xmm4
00007FF91DFE5C9C  F3 0F 59 A3 A0 44 01 00     mulss   xmm4, dword ptr [rbx+144A0h]
00007FF91DFE5CA4  F3 0F 59 83 B0 44 01 00     mulss   xmm0, dword ptr [rbx+144B0h]
00007FF91DFE5CAC  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE5CB0  F3 0F 59 A3 A0 42 01 00     mulss   xmm4, dword ptr [rbx+142A0h]
00007FF91DFE5CB8  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFE5CBC  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE5CC0  73 06                       jnb     short loc_7FF91DFE5CC8
00007FF91DFE5CC2  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE5CC6  EB 05                       jmp     short loc_7FF91DFE5CCD
00007FF91DFE5CC8  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE5CCD  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFE5CD0  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE5CD3  F3 0F 59 83 50 43 01 00     mulss   xmm0, dword ptr [rbx+14350h]
00007FF91DFE5CDB  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE5CDF  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE5CE3  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE5CE7  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE5CEB  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE5CEF  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE5CF3  F3 0F 10 8B 00 40 01 00     movss   xmm1, dword ptr [rbx+14000h]
00007FF91DFE5CFB  F3 0F 11 AB 00 40 01 00     movss   dword ptr [rbx+14000h], xmm5
00007FF91DFE5D03  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE5D06  F3 0F 10 9B 10 40 01 00     movss   xmm3, dword ptr [rbx+14010h]
00007FF91DFE5D0E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE5D12  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE5D15  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE5D19  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE5D1D  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFE5D21  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFE5D25  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE5D29  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE5D2D  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5D30  F3 0F 11 A3 10 40 01 00     movss   dword ptr [rbx+14010h], xmm4
00007FF91DFE5D38  F3 0F 10 8B 20 40 01 00     movss   xmm1, dword ptr [rbx+14020h]
00007FF91DFE5D40  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE5D44  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE5D48  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE5D4B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE5D4F  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFE5D53  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE5D57  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFE5D5B  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE5D5F  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE5D63  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE5D67  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE5D6B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5D6E  F3 0F 11 9B 20 40 01 00     movss   dword ptr [rbx+14020h], xmm3
00007FF91DFE5D76  F3 0F 10 AB 30 40 01 00     movss   xmm5, dword ptr [rbx+14030h]
00007FF91DFE5D7E  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE5D82  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE5D86  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE5D89  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE5D8D  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE5D91  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE5D95  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFE5D99  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE5D9D  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE5DA1  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE5DA5  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE5DA9  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5DAC  F3 0F 11 93 30 40 01 00     movss   dword ptr [rbx+14030h], xmm2
00007FF91DFE5DB4  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFE5DB8  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE5DBC  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE5DC0  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFE5DC5  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5DC8  F3 0F 59 83 40 40 01 00     mulss   xmm0, dword ptr [rbx+14040h]
00007FF91DFE5DD0  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE5DD4  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE5DD8  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5DDB  F3 0F 59 E1                 mulss   xmm4, xmm1
00007FF91DFE5DDF  F3 0F 11 AB 40 40 01 00     movss   dword ptr [rbx+14040h], xmm5
00007FF91DFE5DE7  F3 0F 10 93 30 40 01 00     movss   xmm2, dword ptr [rbx+14030h]
00007FF91DFE5DEF  F3 0F 59 93 F0 42 01 00     mulss   xmm2, dword ptr [rbx+142F0h]
00007FF91DFE5DF7  F3 0F 10 8B 60 42 01 00     movss   xmm1, dword ptr [rbx+14260h]
00007FF91DFE5DFF  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE5E03  F3 0F 59 AB 00 43 01 00     mulss   xmm5, dword ptr [rbx+14300h]
00007FF91DFE5E0B  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE5E0F  F3 0F 10 83 E0 42 01 00     movss   xmm0, dword ptr [rbx+142E0h]
00007FF91DFE5E17  F3 0F 59 83 20 40 01 00     mulss   xmm0, dword ptr [rbx+14020h]
00007FF91DFE5E1F  F3 0F 58 D5                 addss   xmm2, xmm5
00007FF91DFE5E23  F3 0F 10 AB 70 42 01 00     movss   xmm5, dword ptr [rbx+14270h]
00007FF91DFE5E2B  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE5E2F  F3 0F 11 93 60 41 01 00     movss   dword ptr [rbx+14160h], xmm2
00007FF91DFE5E37  F3 0F 59 AB 80 43 01 00     mulss   xmm5, dword ptr [rbx+14380h]
00007FF91DFE5E3F  F3 0F 59 8B 70 43 01 00     mulss   xmm1, dword ptr [rbx+14370h]
00007FF91DFE5E47  F3 0F 10 83 50 40 01 00     movss   xmm0, dword ptr [rbx+14050h]
00007FF91DFE5E4F  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE5E53  F3 0F 59 AB B0 42 01 00     mulss   xmm5, dword ptr [rbx+142B0h]
00007FF91DFE5E5B  F3 0F 11 A3 50 40 01 00     movss   dword ptr [rbx+14050h], xmm4
00007FF91DFE5E63  F3 0F 59 A3 A0 44 01 00     mulss   xmm4, dword ptr [rbx+144A0h]
00007FF91DFE5E6B  F3 0F 59 83 B0 44 01 00     mulss   xmm0, dword ptr [rbx+144B0h]
00007FF91DFE5E73  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE5E77  F3 0F 59 A3 A0 42 01 00     mulss   xmm4, dword ptr [rbx+142A0h]
00007FF91DFE5E7F  F3 0F 5C EC                 subss   xmm5, xmm4
00007FF91DFE5E83  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE5E87  73 06                       jnb     short loc_7FF91DFE5E8F
00007FF91DFE5E89  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE5E8D  EB 05                       jmp     short loc_7FF91DFE5E94
00007FF91DFE5E8F  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE5E94  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFE5E97  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE5E9A  F3 0F 59 83 50 43 01 00     mulss   xmm0, dword ptr [rbx+14350h]
00007FF91DFE5EA2  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE5EA6  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE5EAA  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE5EAE  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE5EB2  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE5EB6  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE5EBA  F3 0F 10 8B 00 40 01 00     movss   xmm1, dword ptr [rbx+14000h]
00007FF91DFE5EC2  F3 0F 11 AB 00 40 01 00     movss   dword ptr [rbx+14000h], xmm5
00007FF91DFE5ECA  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE5ECD  F3 0F 10 9B 10 40 01 00     movss   xmm3, dword ptr [rbx+14010h]
00007FF91DFE5ED5  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE5ED9  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE5EDC  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE5EE0  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE5EE4  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFE5EE8  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFE5EEC  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE5EF0  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE5EF4  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5EF7  F3 0F 11 A3 10 40 01 00     movss   dword ptr [rbx+14010h], xmm4
00007FF91DFE5EFF  F3 0F 10 8B 20 40 01 00     movss   xmm1, dword ptr [rbx+14020h]
00007FF91DFE5F07  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE5F0B  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE5F0F  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE5F12  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE5F16  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFE5F1A  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE5F1E  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFE5F22  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE5F26  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE5F2A  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE5F2E  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE5F32  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5F35  F3 0F 11 9B 20 40 01 00     movss   dword ptr [rbx+14020h], xmm3
00007FF91DFE5F3D  F3 0F 10 AB 30 40 01 00     movss   xmm5, dword ptr [rbx+14030h]
00007FF91DFE5F45  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE5F49  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE5F4D  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE5F50  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE5F54  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE5F58  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE5F5C  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFE5F60  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE5F64  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE5F68  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFE5F6C  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE5F70  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5F73  F3 0F 11 93 30 40 01 00     movss   dword ptr [rbx+14030h], xmm2
00007FF91DFE5F7B  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFE5F7F  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE5F83  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE5F87  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFE5F8C  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5F8F  F3 0F 59 83 40 40 01 00     mulss   xmm0, dword ptr [rbx+14040h]
00007FF91DFE5F97  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE5F9B  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE5F9F  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE5FA2  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFE5FA6  F3 0F 11 AB 40 40 01 00     movss   dword ptr [rbx+14040h], xmm5
00007FF91DFE5FAE  F3 0F 10 8B 30 40 01 00     movss   xmm1, dword ptr [rbx+14030h]
00007FF91DFE5FB6  F3 0F 59 8B F0 42 01 00     mulss   xmm1, dword ptr [rbx+142F0h]
00007FF91DFE5FBE  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE5FC2  F3 0F 59 AB 00 43 01 00     mulss   xmm5, dword ptr [rbx+14300h]
00007FF91DFE5FCA  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE5FCE  F3 0F 10 83 E0 42 01 00     movss   xmm0, dword ptr [rbx+142E0h]
00007FF91DFE5FD6  F3 0F 59 83 20 40 01 00     mulss   xmm0, dword ptr [rbx+14020h]
00007FF91DFE5FDE  F3 0F 58 CD                 addss   xmm1, xmm5
00007FF91DFE5FE2  F3 0F 10 AB 60 42 01 00     movss   xmm5, dword ptr [rbx+14260h]
00007FF91DFE5FEA  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE5FEE  F3 0F 11 8B E0 40 01 00     movss   dword ptr [rbx+140E0h], xmm1
00007FF91DFE5FF6  F3 0F 59 AB 60 43 01 00     mulss   xmm5, dword ptr [rbx+14360h]
00007FF91DFE5FFE  F3 0F 10 83 50 40 01 00     movss   xmm0, dword ptr [rbx+14050h]
00007FF91DFE6006  F3 0F 59 AB B0 42 01 00     mulss   xmm5, dword ptr [rbx+142B0h]
00007FF91DFE600E  F3 0F 11 9B E0 3F 01 00     movss   dword ptr [rbx+13FE0h], xmm3
00007FF91DFE6016  F3 0F 59 9B A0 44 01 00     mulss   xmm3, dword ptr [rbx+144A0h]
00007FF91DFE601E  F3 0F 59 83 B0 44 01 00     mulss   xmm0, dword ptr [rbx+144B0h]
00007FF91DFE6026  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE602A  F3 0F 59 9B A0 42 01 00     mulss   xmm3, dword ptr [rbx+142A0h]
00007FF91DFE6032  F3 0F 5C EB                 subss   xmm5, xmm3
00007FF91DFE6036  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE603A  73 06                       jnb     short loc_7FF91DFE6042
00007FF91DFE603C  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE6040  EB 05                       jmp     short loc_7FF91DFE6047
00007FF91DFE6042  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE6047  0F 28 CD                    movaps  xmm1, xmm5
00007FF91DFE604A  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE604D  F3 0F 59 83 50 43 01 00     mulss   xmm0, dword ptr [rbx+14350h]
00007FF91DFE6055  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE6059  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE605D  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE6061  F3 0F 59 CD                 mulss   xmm1, xmm5
00007FF91DFE6065  F3 0F 59 C8                 mulss   xmm1, xmm0
00007FF91DFE6069  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE606D  F3 0F 11 AB 80 3F 01 00     movss   dword ptr [rbx+13F80h], xmm5
00007FF91DFE6075  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE6078  F3 0F 58 AB 00 40 01 00     addss   xmm5, dword ptr [rbx+14000h]
00007FF91DFE6080  F3 0F 10 9B 10 40 01 00     movss   xmm3, dword ptr [rbx+14010h]
00007FF91DFE6088  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE608B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE608F  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE6093  41 0F 28 E8                 movaps  xmm5, xmm8
00007FF91DFE6097  F3 0F 59 EA                 mulss   xmm5, xmm2
00007FF91DFE609B  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE609F  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE60A3  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE60A6  F3 0F 11 A3 90 3F 01 00     movss   dword ptr [rbx+13F90h], xmm4
00007FF91DFE60AE  F3 0F 10 8B 20 40 01 00     movss   xmm1, dword ptr [rbx+14020h]
00007FF91DFE60B6  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE60BA  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE60BE  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE60C1  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE60C5  F3 0F 58 EC                 addss   xmm5, xmm4
00007FF91DFE60C9  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE60CD  41 0F 28 D8                 movaps  xmm3, xmm8
00007FF91DFE60D1  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE60D5  41 0F 28 E0                 movaps  xmm4, xmm8
00007FF91DFE60D9  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE60DD  F3 0F 58 D8                 addss   xmm3, xmm0
00007FF91DFE60E1  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE60E4  F3 0F 11 9B A0 3F 01 00     movss   dword ptr [rbx+13FA0h], xmm3
00007FF91DFE60EC  F3 0F 10 AB 30 40 01 00     movss   xmm5, dword ptr [rbx+14030h]
00007FF91DFE60F4  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE60F8  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE60FC  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE60FF  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE6103  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE6107  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE610B  41 0F 28 C8                 movaps  xmm1, xmm8
00007FF91DFE610F  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE6113  F3 0F 59 D3                 mulss   xmm2, xmm3
00007FF91DFE6117  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE611B  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE611E  F3 0F 11 93 B0 3F 01 00     movss   dword ptr [rbx+13FB0h], xmm2
00007FF91DFE6126  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFE612A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE612E  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE6132  F3 41 0F 59 E8              mulss   xmm5, xmm8
00007FF91DFE6137  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE613A  F3 0F 59 83 40 40 01 00     mulss   xmm0, dword ptr [rbx+14040h]
00007FF91DFE6142  F3 0F 58 CA                 addss   xmm1, xmm2
00007FF91DFE6146  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE614A  F3 44 0F 59 C1              mulss   xmm8, xmm1
00007FF91DFE614F  F3 0F 11 AB C0 3F 01 00     movss   dword ptr [rbx+13FC0h], xmm5
00007FF91DFE6157  F3 0F 10 9B A0 3F 01 00     movss   xmm3, dword ptr [rbx+13FA0h]
00007FF91DFE615F  F3 0F 59 F5                 mulss   xmm6, xmm5
00007FF91DFE6163  F3 44 0F 58 C6              addss   xmm8, xmm6
00007FF91DFE6168  F3 44 0F 11 83 D0 3F 01 00  movss   dword ptr [rbx+13FD0h], xmm8
00007FF91DFE6171  F3 0F 10 83 F0 42 01 00     movss   xmm0, dword ptr [rbx+142F0h]
00007FF91DFE6179  F3 0F 59 83 B0 3F 01 00     mulss   xmm0, dword ptr [rbx+13FB0h]
00007FF91DFE6181  F3 0F 59 AB 00 43 01 00     mulss   xmm5, dword ptr [rbx+14300h]
00007FF91DFE6189  F3 0F 59 9B E0 42 01 00     mulss   xmm3, dword ptr [rbx+142E0h]
00007FF91DFE6191  F3 0F 10 A3 A0 40 01 00     movss   xmm4, dword ptr [rbx+140A0h]
00007FF91DFE6199  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE619D  F3 0F 58 EB                 addss   xmm5, xmm3
00007FF91DFE61A1  F3 0F 11 AB 60 40 01 00     movss   dword ptr [rbx+14060h], xmm5
00007FF91DFE61A9  F3 0F 58 A3 10 42 01 00     addss   xmm4, dword ptr [rbx+14210h]
00007FF91DFE61B1  F3 0F 10 83 20 41 01 00     movss   xmm0, dword ptr [rbx+14120h]
00007FF91DFE61B9  F3 0F 58 83 90 41 01 00     addss   xmm0, dword ptr [rbx+14190h]
00007FF91DFE61C1  F3 0F 10 8B A0 41 01 00     movss   xmm1, dword ptr [rbx+141A0h]
00007FF91DFE61C9  F3 0F 58 8B 10 41 01 00     addss   xmm1, dword ptr [rbx+14110h]
00007FF91DFE61D1  F3 0F 59 A3 90 44 01 00     mulss   xmm4, dword ptr [rbx+14490h]
00007FF91DFE61D9  F3 0F 59 83 80 44 01 00     mulss   xmm0, dword ptr [rbx+14480h]
00007FF91DFE61E1  F3 0F 59 8B 70 44 01 00     mulss   xmm1, dword ptr [rbx+14470h]
00007FF91DFE61E9  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE61ED  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE61F1  F3 0F 10 83 90 40 01 00     movss   xmm0, dword ptr [rbx+14090h]
00007FF91DFE61F9  F3 0F 58 83 20 42 01 00     addss   xmm0, dword ptr [rbx+14220h]
00007FF91DFE6201  F3 0F 10 8B 00 42 01 00     movss   xmm1, dword ptr [rbx+14200h]
00007FF91DFE6209  F3 0F 58 8B B0 40 01 00     addss   xmm1, dword ptr [rbx+140B0h]
00007FF91DFE6211  F3 0F 58 AB 50 42 01 00     addss   xmm5, dword ptr [rbx+14250h]
00007FF91DFE6219  F3 0F 59 83 60 44 01 00     mulss   xmm0, dword ptr [rbx+14460h]
00007FF91DFE6221  F3 0F 59 8B 50 44 01 00     mulss   xmm1, dword ptr [rbx+14450h]
00007FF91DFE6229  F3 0F 59 AB A0 43 01 00     mulss   xmm5, dword ptr [rbx+143A0h]
00007FF91DFE6231  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE6235  F3 0F 10 83 80 41 01 00     movss   xmm0, dword ptr [rbx+14180h]
00007FF91DFE623D  F3 0F 58 83 30 41 01 00     addss   xmm0, dword ptr [rbx+14130h]
00007FF91DFE6245  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE6249  F3 0F 10 8B B0 41 01 00     movss   xmm1, dword ptr [rbx+141B0h]
00007FF91DFE6251  F3 0F 58 8B 00 41 01 00     addss   xmm1, dword ptr [rbx+14100h]
00007FF91DFE6259  F3 0F 59 83 40 44 01 00     mulss   xmm0, dword ptr [rbx+14440h]
00007FF91DFE6261  F3 0F 59 8B 30 44 01 00     mulss   xmm1, dword ptr [rbx+14430h]
00007FF91DFE6269  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE626D  F3 0F 10 83 30 42 01 00     movss   xmm0, dword ptr [rbx+14230h]
00007FF91DFE6275  F3 0F 58 83 80 40 01 00     addss   xmm0, dword ptr [rbx+14080h]
00007FF91DFE627D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE6281  F3 0F 10 8B F0 41 01 00     movss   xmm1, dword ptr [rbx+141F0h]
00007FF91DFE6289  F3 0F 59 83 20 44 01 00     mulss   xmm0, dword ptr [rbx+14420h]
00007FF91DFE6291  F3 0F 58 8B C0 40 01 00     addss   xmm1, dword ptr [rbx+140C0h]
00007FF91DFE6299  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE629D  F3 0F 10 83 70 41 01 00     movss   xmm0, dword ptr [rbx+14170h]
00007FF91DFE62A5  F3 0F 58 83 40 41 01 00     addss   xmm0, dword ptr [rbx+14140h]
00007FF91DFE62AD  F3 0F 59 8B 10 44 01 00     mulss   xmm1, dword ptr [rbx+14410h]
00007FF91DFE62B5  F3 0F 59 83 00 44 01 00     mulss   xmm0, dword ptr [rbx+14400h]
00007FF91DFE62BD  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE62C1  F3 0F 10 8B C0 41 01 00     movss   xmm1, dword ptr [rbx+141C0h]
00007FF91DFE62C9  F3 0F 58 8B F0 40 01 00     addss   xmm1, dword ptr [rbx+140F0h]
00007FF91DFE62D1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE62D5  F3 0F 10 83 40 42 01 00     movss   xmm0, dword ptr [rbx+14240h]
00007FF91DFE62DD  F3 0F 59 8B F0 43 01 00     mulss   xmm1, dword ptr [rbx+143F0h]
00007FF91DFE62E5  F3 0F 58 83 70 40 01 00     addss   xmm0, dword ptr [rbx+14070h]
00007FF91DFE62ED  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE62F1  F3 0F 10 8B E0 41 01 00     movss   xmm1, dword ptr [rbx+141E0h]
00007FF91DFE62F9  F3 0F 58 8B D0 40 01 00     addss   xmm1, dword ptr [rbx+140D0h]
00007FF91DFE6301  F3 0F 59 83 E0 43 01 00     mulss   xmm0, dword ptr [rbx+143E0h]
00007FF91DFE6309  F3 0F 59 8B D0 43 01 00     mulss   xmm1, dword ptr [rbx+143D0h]
00007FF91DFE6311  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE6315  F3 0F 10 83 60 41 01 00     movss   xmm0, dword ptr [rbx+14160h]
00007FF91DFE631D  F3 0F 58 83 50 41 01 00     addss   xmm0, dword ptr [rbx+14150h]
00007FF91DFE6325  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE6329  F3 0F 10 8B D0 41 01 00     movss   xmm1, dword ptr [rbx+141D0h]
00007FF91DFE6331  F3 0F 59 83 C0 43 01 00     mulss   xmm0, dword ptr [rbx+143C0h]
00007FF91DFE6339  F3 0F 58 8B E0 40 01 00     addss   xmm1, dword ptr [rbx+140E0h]
00007FF91DFE6341  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE6345  F3 0F 59 8B B0 43 01 00     mulss   xmm1, dword ptr [rbx+143B0h]
00007FF91DFE634D  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE6351  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE6355  F3 0F 59 A3 30 43 01 00     mulss   xmm4, dword ptr [rbx+14330h]
00007FF91DFE635D  F3 0F 11 A3 C0 42 01 00     movss   dword ptr [rbx+142C0h], xmm4
00007FF91DFE6365  8B 83 C0 44 01 00           mov     eax, [rbx+144C0h]
00007FF91DFE636B  89 83 D0 44 01 00           mov     [rbx+144D0h], eax
00007FF91DFE6371  F3 0F 10 83 F0 44 01 00     movss   xmm0, dword ptr [rbx+144F0h]
00007FF91DFE6379  8B 83 E0 44 01 00           mov     eax, [rbx+144E0h]
00007FF91DFE637F  89 83 10 45 01 00           mov     [rbx+14510h], eax
00007FF91DFE6385  F3 0F 11 83 20 45 01 00     movss   dword ptr [rbx+14520h], xmm0
00007FF91DFE638D  8B 83 00 45 01 00           mov     eax, [rbx+14500h]
00007FF91DFE6393  89 83 30 45 01 00           mov     [rbx+14530h], eax
00007FF91DFE6399  F3 0F 10 93 40 45 01 00     movss   xmm2, dword ptr [rbx+14540h]
00007FF91DFE63A1  F3 0F 11 93 50 45 01 00     movss   dword ptr [rbx+14550h], xmm2
00007FF91DFE63A9  F3 0F 10 83 60 45 01 00     movss   xmm0, dword ptr [rbx+14560h]
00007FF91DFE63B1  F3 0F 11 83 70 45 01 00     movss   dword ptr [rbx+14570h], xmm0
00007FF91DFE63B9  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE63BD  F3 0F 59 93 80 45 01 00     mulss   xmm2, dword ptr [rbx+14580h]
00007FF91DFE63C5  F3 0F 58 D0                 addss   xmm2, xmm0
00007FF91DFE63C9  F3 0F 11 93 60 45 01 00     movss   dword ptr [rbx+14560h], xmm2
00007FF91DFE63D1  F3 0F 10 83 20 45 01 00     movss   xmm0, dword ptr [rbx+14520h]
00007FF91DFE63D9  F3 0F 10 8B 30 45 01 00     movss   xmm1, dword ptr [rbx+14530h]
00007FF91DFE63E1  F3 0F 59 D0                 mulss   xmm2, xmm0
00007FF91DFE63E5  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE63E9  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE63ED  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE63F1  F3 0F 11 93 90 45 01 00     movss   dword ptr [rbx+14590h], xmm2
00007FF91DFE63F9  F3 0F 10 8B A0 45 01 00     movss   xmm1, dword ptr [rbx+145A0h]
00007FF91DFE6401  F3 0F 11 8B B0 45 01 00     movss   dword ptr [rbx+145B0h], xmm1
00007FF91DFE6409  F3 0F 10 83 C0 45 01 00     movss   xmm0, dword ptr [rbx+145C0h]
00007FF91DFE6411  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFE6414  F3 0F 59 C1                 mulss   xmm0, xmm1
00007FF91DFE6418  F3 0F 59 DA                 mulss   xmm3, xmm2
00007FF91DFE641C  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE6420  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE6424  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFE6428  76 05                       jbe     short loc_7FF91DFE642F
00007FF91DFE642A  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFE642D  EB 03                       jmp     short loc_7FF91DFE6432
00007FF91DFE642F  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE6432  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE6436  F3 0F 11 83 A0 45 01 00     movss   dword ptr [rbx+145A0h], xmm0
00007FF91DFE643E  F3 0F 10 8B D0 45 01 00     movss   xmm1, dword ptr [rbx+145D0h]
00007FF91DFE6446  F3 0F 11 8B E0 45 01 00     movss   dword ptr [rbx+145E0h], xmm1
00007FF91DFE644E  F3 0F 10 93 F0 45 01 00     movss   xmm2, dword ptr [rbx+145F0h]
00007FF91DFE6456  F3 0F 11 93 00 46 01 00     movss   dword ptr [rbx+14600h], xmm2
00007FF91DFE645E  F3 0F 10 83 10 46 01 00     movss   xmm0, dword ptr [rbx+14610h]
00007FF91DFE6466  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFE6469  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE646D  F3 0F 59 D9                 mulss   xmm3, xmm1
00007FF91DFE6471  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE6475  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFE6479  41 0F 2F DE                 comiss  xmm3, xmm14
00007FF91DFE647D  76 05                       jbe     short loc_7FF91DFE6484
00007FF91DFE647F  0F 5A C3                    cvtps2pd xmm0, xmm3
00007FF91DFE6482  EB 03                       jmp     short loc_7FF91DFE6487
00007FF91DFE6484  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE6487  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE648B  F3 0F 11 83 F0 45 01 00     movss   dword ptr [rbx+145F0h], xmm0
00007FF91DFE6493  F3 0F 10 AB 20 46 01 00     movss   xmm5, dword ptr [rbx+14620h]
00007FF91DFE649B  F3 0F 10 B3 A0 21 01 00     movss   xmm6, dword ptr [rbx+121A0h]
00007FF91DFE64A3  0F 28 E5                    movaps  xmm4, xmm5
00007FF91DFE64A6  F3 0F 11 AB 30 46 01 00     movss   dword ptr [rbx+14630h], xmm5
00007FF91DFE64AE  0F 28 C5                    movaps  xmm0, xmm5
00007FF91DFE64B1  F3 0F 59 A3 80 46 01 00     mulss   xmm4, dword ptr [rbx+14680h]
00007FF91DFE64B9  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFE64BC  F3 0F 58 83 50 46 01 00     addss   xmm0, dword ptr [rbx+14650h]
00007FF91DFE64C4  F3 0F 58 9B 70 46 01 00     addss   xmm3, dword ptr [rbx+14670h]
00007FF91DFE64CC  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFE64D0  73 06                       jnb     short loc_7FF91DFE64D8
00007FF91DFE64D2  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFE64D6  EB 05                       jmp     short loc_7FF91DFE64DD
00007FF91DFE64D8  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFE64DD  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE64E1  72 1B                       jb      short loc_7FF91DFE64FE
00007FF91DFE64E3  F3 0F 10 83 60 46 01 00     movss   xmm0, dword ptr [rbx+14660h]
00007FF91DFE64EB  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFE64EE  F3 0F 59 C5                 mulss   xmm0, xmm5
00007FF91DFE64F2  F3 0F 59 DE                 mulss   xmm3, xmm6
00007FF91DFE64F6  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE64FA  F3 0F 58 DD                 addss   xmm3, xmm5
00007FF91DFE64FE  41 0F 2E F6                 ucomiss xmm6, xmm14
00007FF91DFE6502  F3 0F 10 8B A0 46 01 00     movss   xmm1, dword ptr [rbx+146A0h]
00007FF91DFE650A  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFE650D  F3 0F 59 93 90 46 01 00     mulss   xmm2, dword ptr [rbx+14690h]
00007FF91DFE6515  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE6518  F3 0F 59 C4                 mulss   xmm0, xmm4
00007FF91DFE651C  F3 0F 5C D0                 subss   xmm2, xmm0
00007FF91DFE6520  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE6524  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE6527  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE652B  F3 0F 59 C6                 mulss   xmm0, xmm6
00007FF91DFE652F  F3 0F 5C C2                 subss   xmm0, xmm2
00007FF91DFE6533  F3 0F 58 C5                 addss   xmm0, xmm5
00007FF91DFE6537  74 03                       jz      short loc_7FF91DFE653C
00007FF91DFE6539  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE653C  F3 0F 11 83 40 46 01 00     movss   dword ptr [rbx+14640h], xmm0
00007FF91DFE6544  F3 0F 11 83 20 46 01 00     movss   dword ptr [rbx+14620h], xmm0
00007FF91DFE654C  F3 0F 10 BB C0 42 01 00     movss   xmm7, dword ptr [rbx+142C0h]
00007FF91DFE6554  F3 0F 10 B3 30 2A 01 00     movss   xmm6, dword ptr [rbx+12A30h]
00007FF91DFE655C  F3 0F 10 9B 30 3A 01 00     movss   xmm3, dword ptr [rbx+13A30h]
00007FF91DFE6564  F3 0F 10 83 10 2C 01 00     movss   xmm0, dword ptr [rbx+12C10h]
00007FF91DFE656C  F3 0F 10 8B C0 44 01 00     movss   xmm1, dword ptr [rbx+144C0h]
00007FF91DFE6574  8B 83 E0 46 01 00           mov     eax, [rbx+146E0h]
00007FF91DFE657A  89 83 F0 46 01 00           mov     [rbx+146F0h], eax
00007FF91DFE6580  8B 83 00 47 01 00           mov     eax, [rbx+14700h]
00007FF91DFE6586  89 83 10 47 01 00           mov     [rbx+14710h], eax
00007FF91DFE658C  F3 0F 11 83 B0 46 01 00     movss   dword ptr [rbx+146B0h], xmm0
00007FF91DFE6594  F3 0F 11 8B C0 46 01 00     movss   dword ptr [rbx+146C0h], xmm1
00007FF91DFE659C  F3 0F 59 9B D0 47 01 00     mulss   xmm3, dword ptr [rbx+147D0h]
00007FF91DFE65A4  F3 0F 10 A3 F0 46 01 00     movss   xmm4, dword ptr [rbx+146F0h]
00007FF91DFE65AC  F3 0F 10 93 30 47 01 00     movss   xmm2, dword ptr [rbx+14730h]
00007FF91DFE65B4  F3 0F 11 9B D0 46 01 00     movss   dword ptr [rbx+146D0h], xmm3
00007FF91DFE65BC  0F 28 DF                    movaps  xmm3, xmm7
00007FF91DFE65BF  F3 0F 59 B3 40 47 01 00     mulss   xmm6, dword ptr [rbx+14740h]
00007FF91DFE65C7  F3 0F 5C DC                 subss   xmm3, xmm4
00007FF91DFE65CB  F3 0F 59 93 40 46 01 00     mulss   xmm2, dword ptr [rbx+14640h]
00007FF91DFE65D3  F3 0F 10 8B 50 47 01 00     movss   xmm1, dword ptr [rbx+14750h]
00007FF91DFE65DB  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE65DE  F3 0F 59 83 70 47 01 00     mulss   xmm0, dword ptr [rbx+14770h]
00007FF91DFE65E6  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFE65EA  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE65EE  41 0F 28 C5                 movaps  xmm0, xmm13
00007FF91DFE65F2  F3 0F 11 A3 E0 46 01 00     movss   dword ptr [rbx+146E0h], xmm4
00007FF91DFE65FA  F3 0F 59 8B B0 46 01 00     mulss   xmm1, dword ptr [rbx+146B0h]
00007FF91DFE6602  F3 0F 10 93 60 47 01 00     movss   xmm2, dword ptr [rbx+14760h]
00007FF91DFE660A  F3 0F 59 9B E0 47 01 00     mulss   xmm3, dword ptr [rbx+147E0h]
00007FF91DFE6612  F3 0F 59 A3 F0 47 01 00     mulss   xmm4, dword ptr [rbx+147F0h]
00007FF91DFE661A  F3 0F 58 F1                 addss   xmm6, xmm1
00007FF91DFE661E  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE6621  F3 0F 59 8B C0 46 01 00     mulss   xmm1, dword ptr [rbx+146C0h]
00007FF91DFE6629  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE662D  F3 0F 58 DC                 addss   xmm3, xmm4
00007FF91DFE6631  F3 0F 5C CA                 subss   xmm1, xmm2
00007FF91DFE6635  F3 0F 58 CE                 addss   xmm1, xmm6
00007FF91DFE6639  F3 0F 10 B3 80 47 01 00     movss   xmm6, dword ptr [rbx+14780h]
00007FF91DFE6641  F3 0F 5C C6                 subss   xmm0, xmm6
00007FF91DFE6645  F3 0F 59 8B B0 47 01 00     mulss   xmm1, dword ptr [rbx+147B0h]
00007FF91DFE664D  F3 0F 59 F8                 mulss   xmm7, xmm0
00007FF91DFE6651  41 0F 2F CE                 comiss  xmm1, xmm14
00007FF91DFE6655  76 05                       jbe     short loc_7FF91DFE665C
00007FF91DFE6657  0F 5A C1                    cvtps2pd xmm0, xmm1
00007FF91DFE665A  EB 03                       jmp     short loc_7FF91DFE665F
00007FF91DFE665C  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE665F  F3 0F 10 93 A0 47 01 00     movss   xmm2, dword ptr [rbx+147A0h]
00007FF91DFE6667  F3 0F 10 A3 90 47 01 00     movss   xmm4, dword ptr [rbx+14790h]
00007FF91DFE666F  66 0F 5A E8                 cvtpd2ps xmm5, xmm0
00007FF91DFE6673  F3 0F 10 83 D0 46 01 00     movss   xmm0, dword ptr [rbx+146D0h]
00007FF91DFE667B  F3 0F 59 AB C0 47 01 00     mulss   xmm5, dword ptr [rbx+147C0h]
00007FF91DFE6683  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE6688  F3 0F 59 F3                 mulss   xmm6, xmm3
00007FF91DFE668C  F3 0F 10 9B 10 47 01 00     movss   xmm3, dword ptr [rbx+14710h]
00007FF91DFE6694  F3 0F 58 F7                 addss   xmm6, xmm7
00007FF91DFE6698  F3 0F 59 F0                 mulss   xmm6, xmm0
00007FF91DFE669C  F3 0F 10 83 00 48 01 00     movss   xmm0, dword ptr [rbx+14800h]
00007FF91DFE66A4  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFE66A7  F3 0F 59 C3                 mulss   xmm0, xmm3
00007FF91DFE66AB  F3 0F 59 CE                 mulss   xmm1, xmm6
00007FF91DFE66AF  F3 0F 59 D6                 mulss   xmm2, xmm6
00007FF91DFE66B3  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE66B7  F3 0F 58 D9                 addss   xmm3, xmm1
00007FF91DFE66BB  F3 0F 11 9B 00 47 01 00     movss   dword ptr [rbx+14700h], xmm3
00007FF91DFE66C3  F3 0F 59 E3                 mulss   xmm4, xmm3
00007FF91DFE66C7  F3 0F 58 E2                 addss   xmm4, xmm2
00007FF91DFE66CB  F3 0F 59 E5                 mulss   xmm4, xmm5
00007FF91DFE66CF  F3 0F 59 A3 10 48 01 00     mulss   xmm4, dword ptr [rbx+14810h]
00007FF91DFE66D7  F3 0F 11 A3 20 47 01 00     movss   dword ptr [rbx+14720h], xmm4
00007FF91DFE66DF  8B 83 30 48 01 00           mov     eax, [rbx+14830h]
00007FF91DFE66E5  89 83 40 48 01 00           mov     [rbx+14840h], eax
00007FF91DFE66EB  8B 83 20 48 01 00           mov     eax, [rbx+14820h]
00007FF91DFE66F1  89 83 30 48 01 00           mov     [rbx+14830h], eax
00007FF91DFE66F7  F3 0F 10 83 40 48 01 00     movss   xmm0, dword ptr [rbx+14840h]
00007FF91DFE66FF  F3 0F 10 8B 50 48 01 00     movss   xmm1, dword ptr [rbx+14850h]
00007FF91DFE6707  F3 0F 5C E0                 subss   xmm4, xmm0
00007FF91DFE670B  F3 0F 11 A3 20 48 01 00     movss   dword ptr [rbx+14820h], xmm4
00007FF91DFE6713  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE6717  F3 0F 58 C8                 addss   xmm1, xmm0
00007FF91DFE671B  F3 0F 11 8B 30 48 01 00     movss   dword ptr [rbx+14830h], xmm1
00007FF91DFE6723  F3 0F 10 93 20 48 01 00     movss   xmm2, dword ptr [rbx+14820h]
00007FF91DFE672B  F3 0F 10 B3 10 45 01 00     movss   xmm6, dword ptr [rbx+14510h]
00007FF91DFE6733  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE6736  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFE673A  8B 83 80 48 01 00           mov     eax, [rbx+14880h]
00007FF91DFE6740  89 83 90 48 01 00           mov     [rbx+14890h], eax
00007FF91DFE6746  8B 83 70 48 01 00           mov     eax, [rbx+14870h]
00007FF91DFE674C  89 83 80 48 01 00           mov     [rbx+14880h], eax
00007FF91DFE6752  8B 83 60 48 01 00           mov     eax, [rbx+14860h]
00007FF91DFE6758  89 83 70 48 01 00           mov     [rbx+14870h], eax
00007FF91DFE675E  F3 0F 11 93 60 48 01 00     movss   dword ptr [rbx+14860h], xmm2
00007FF91DFE6766  F3 0F 59 83 B0 48 01 00     mulss   xmm0, dword ptr [rbx+148B0h]
00007FF91DFE676E  F3 0F 10 A3 70 48 01 00     movss   xmm4, dword ptr [rbx+14870h]
00007FF91DFE6776  F3 0F 10 8B D0 48 01 00     movss   xmm1, dword ptr [rbx+148D0h]
00007FF91DFE677E  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFE6781  F3 0F 59 8B 80 48 01 00     mulss   xmm1, dword ptr [rbx+14880h]
00007FF91DFE6789  F3 0F 59 AB C0 48 01 00     mulss   xmm5, dword ptr [rbx+148C0h]
00007FF91DFE6791  F3 0F 59 A3 F0 48 01 00     mulss   xmm4, dword ptr [rbx+148F0h]
00007FF91DFE6799  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE679D  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE67A0  F3 0F 59 83 E0 48 01 00     mulss   xmm0, dword ptr [rbx+148E0h]
00007FF91DFE67A8  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE67AC  F3 0F 10 8B 00 49 01 00     movss   xmm1, dword ptr [rbx+14900h]
00007FF91DFE67B4  F3 0F 59 8B 90 48 01 00     mulss   xmm1, dword ptr [rbx+14890h]
00007FF91DFE67BC  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE67C0  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE67C4  76 05                       jbe     short loc_7FF91DFE67CB
00007FF91DFE67C6  0F 5A C6                    cvtps2pd xmm0, xmm6
00007FF91DFE67C9  EB 03                       jmp     short loc_7FF91DFE67CE
00007FF91DFE67CB  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE67CE  0F 2F 35 EB EC 75 00        comiss  xmm6, cs:dword_7FF91E7454C0
00007FF91DFE67D5  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE67D9  F3 0F 11 AB 70 48 01 00     movss   dword ptr [rbx+14870h], xmm5
00007FF91DFE67E1  0F 28 D8                    movaps  xmm3, xmm0
00007FF91DFE67E4  F3 0F 11 A3 80 48 01 00     movss   dword ptr [rbx+14880h], xmm4
00007FF91DFE67EC  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE67F0  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE67F4  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE67F8  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE67FB  41 0F 57 C3                 xorps   xmm0, xmm11
00007FF91DFE67FF  F3 0F 58 DA                 addss   xmm3, xmm2
00007FF91DFE6803  73 09                       jnb     short loc_7FF91DFE680E
00007FF91DFE6805  45 0F 57 D2                 xorps   xmm10, xmm10
00007FF91DFE6809  F3 44 0F 5A D0              cvtss2sd xmm10, xmm0
00007FF91DFE680E  41 0F 2F F6                 comiss  xmm6, xmm14
00007FF91DFE6812  66 41 0F 5A C2              cvtpd2ps xmm0, xmm10
00007FF91DFE6817  0F 28 C8                    movaps  xmm1, xmm0
00007FF91DFE681A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE681E  F3 0F 59 CC                 mulss   xmm1, xmm4
00007FF91DFE6822  F3 0F 5C C8                 subss   xmm1, xmm0
00007FF91DFE6826  F3 0F 58 D1                 addss   xmm2, xmm1
00007FF91DFE682A  72 03                       jb      short loc_7FF91DFE682F
00007FF91DFE682C  0F 28 D3                    movaps  xmm2, xmm3
00007FF91DFE682F  F3 0F 11 93 A0 48 01 00     movss   dword ptr [rbx+148A0h], xmm2
00007FF91DFE6837  F3 0F 59 93 A0 45 01 00     mulss   xmm2, dword ptr [rbx+145A0h]
00007FF91DFE683F  F3 0F 11 93 10 49 01 00     movss   dword ptr [rbx+14910h], xmm2
00007FF91DFE6847  F3 0F 59 93 F0 45 01 00     mulss   xmm2, dword ptr [rbx+145F0h]
00007FF91DFE684F  F3 0F 11 93 20 49 01 00     movss   dword ptr [rbx+14920h], xmm2
00007FF91DFE6857  F3 0F 10 83 D0 30 01 00     movss   xmm0, dword ptr [rbx+130D0h]
00007FF91DFE685F  F3 0F 58 83 30 2E 01 00     addss   xmm0, dword ptr [rbx+12E30h]
00007FF91DFE6867  44 0F 5A E0                 cvtps2pd xmm12, xmm0
00007FF91DFE686B  F2 44 0F 5F 25 34 44 60 00  maxsd   xmm12, cs:qword_7FF91E5EACA8
00007FF91DFE6874  F2 44 0F 5D 25 13 44 60 00  minsd   xmm12, cs:qword_7FF91E5EAC90
00007FF91DFE687D  41 0F 28 CC                 movaps  xmm1, xmm12
00007FF91DFE6881  41 0F 28 C4                 movaps  xmm0, xmm12
00007FF91DFE6885  F2 0F 58 05 DB E9 75 00     addsd   xmm0, cs:qword_7FF91E745268
00007FF91DFE688D  F2 41 0F 59 CC              mulsd   xmm1, xmm12
00007FF91DFE6892  41 0F 28 FC                 movaps  xmm7, xmm12
00007FF91DFE6896  F2 0F 2C C0                 cvttsd2si eax, xmm0
00007FF91DFE689A  0F 28 D1                    movaps  xmm2, xmm1
00007FF91DFE689D  48 63 C8                    movsxd  rcx, eax
00007FF91DFE68A0  F2 41 0F 59 D4              mulsd   xmm2, xmm12
00007FF91DFE68A5  48 69 C1 D0 00 00 00        imul    rax, rcx, 0D0h
00007FF91DFE68AC  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE68AF  F2 41 0F 59 DC              mulsd   xmm3, xmm12
00007FF91DFE68B4  48 8D 0D 25 2C 60 00        lea     rcx, unk_7FF91E5E94E0
00007FF91DFE68BB  48 03 C1                    add     rax, rcx
00007FF91DFE68BE  0F 28 E3                    movaps  xmm4, xmm3
00007FF91DFE68C1  F2 41 0F 59 E4              mulsd   xmm4, xmm12
00007FF91DFE68C6  F2 0F 59 78 10              mulsd   xmm7, qword ptr [rax+10h]
00007FF91DFE68CB  F2 0F 59 58 40              mulsd   xmm3, qword ptr [rax+40h]
00007FF91DFE68D0  F2 0F 59 48 20              mulsd   xmm1, qword ptr [rax+20h]
00007FF91DFE68D5  0F 28 EC                    movaps  xmm5, xmm4
00007FF91DFE68D8  F2 0F 58 38                 addsd   xmm7, qword ptr [rax]
00007FF91DFE68DC  F2 0F 59 50 30              mulsd   xmm2, qword ptr [rax+30h]
00007FF91DFE68E1  F2 0F 59 60 50              mulsd   xmm4, qword ptr [rax+50h]
00007FF91DFE68E6  F2 0F 58 F9                 addsd   xmm7, xmm1
00007FF91DFE68EA  F2 41 0F 59 EC              mulsd   xmm5, xmm12
00007FF91DFE68EF  F2 0F 58 FA                 addsd   xmm7, xmm2
00007FF91DFE68F3  0F 28 F5                    movaps  xmm6, xmm5
00007FF91DFE68F6  F2 0F 59 68 60              mulsd   xmm5, qword ptr [rax+60h]
00007FF91DFE68FB  F2 41 0F 59 F4              mulsd   xmm6, xmm12
00007FF91DFE6900  F2 0F 58 FB                 addsd   xmm7, xmm3
00007FF91DFE6904  44 0F 28 C6                 movaps  xmm8, xmm6
00007FF91DFE6908  F2 0F 59 70 70              mulsd   xmm6, qword ptr [rax+70h]
00007FF91DFE690D  F2 0F 58 FC                 addsd   xmm7, xmm4
00007FF91DFE6911  F2 45 0F 59 C4              mulsd   xmm8, xmm12
00007FF91DFE6916  F2 0F 58 FD                 addsd   xmm7, xmm5
00007FF91DFE691A  45 0F 28 C8                 movaps  xmm9, xmm8
00007FF91DFE691E  F2 44 0F 59 80 80 00 00 00  mulsd   xmm8, qword ptr [rax+80h]
00007FF91DFE6927  F2 45 0F 59 CC              mulsd   xmm9, xmm12
00007FF91DFE692C  F2 0F 58 FE                 addsd   xmm7, xmm6
00007FF91DFE6930  45 0F 28 D1                 movaps  xmm10, xmm9
00007FF91DFE6934  F2 44 0F 59 88 90 00 00 00  mulsd   xmm9, qword ptr [rax+90h]
00007FF91DFE693D  F2 41 0F 58 F8              addsd   xmm7, xmm8
00007FF91DFE6942  F2 45 0F 59 D4              mulsd   xmm10, xmm12
00007FF91DFE6947  F2 41 0F 58 F9              addsd   xmm7, xmm9
00007FF91DFE694C  45 0F 28 DA                 movaps  xmm11, xmm10
00007FF91DFE6950  F2 44 0F 59 90 A0 00 00 00  mulsd   xmm10, qword ptr [rax+0A0h]
00007FF91DFE6959  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFE695E  F2 41 0F 58 FA              addsd   xmm7, xmm10
00007FF91DFE6963  41 0F 28 C3                 movaps  xmm0, xmm11
00007FF91DFE6967  F2 45 0F 59 DC              mulsd   xmm11, xmm12
00007FF91DFE696C  F2 0F 59 80 B0 00 00 00     mulsd   xmm0, qword ptr [rax+0B0h]
00007FF91DFE6974  F2 44 0F 59 98 C0 00 00 00  mulsd   xmm11, qword ptr [rax+0C0h]
00007FF91DFE697D  F2 0F 58 F8                 addsd   xmm7, xmm0
00007FF91DFE6981  F2 41 0F 58 FB              addsd   xmm7, xmm11
00007FF91DFE6986  66 0F 5A DF                 cvtpd2ps xmm3, xmm7
00007FF91DFE698A  F3 0F 5D 1D 06 43 60 00     minss   xmm3, cs:dword_7FF91E5EAC98
00007FF91DFE6992  F3 0F 5F 1D 16 43 60 00     maxss   xmm3, cs:dword_7FF91E5EACB0
00007FF91DFE699A  F3 0F 59 9B 40 2E 01 00     mulss   xmm3, dword ptr [rbx+12E40h]
00007FF91DFE69A2  F3 0F 11 9B B0 30 01 00     movss   dword ptr [rbx+130B0h], xmm3
00007FF91DFE69AA  8B 83 50 32 01 00           mov     eax, [rbx+13250h]
00007FF91DFE69B0  F3 0F 10 AB 30 2E 01 00     movss   xmm5, dword ptr [rbx+12E30h]
00007FF91DFE69B8  F3 0F 10 83 00 30 01 00     movss   xmm0, dword ptr [rbx+13000h]
00007FF91DFE69C0  F3 0F 10 8B 10 30 01 00     movss   xmm1, dword ptr [rbx+13010h]
00007FF91DFE69C8  F3 0F 10 93 20 30 01 00     movss   xmm2, dword ptr [rbx+13020h]
00007FF91DFE69D0  89 83 60 32 01 00           mov     [rbx+13260h], eax
00007FF91DFE69D6  8B 83 70 32 01 00           mov     eax, [rbx+13270h]
00007FF91DFE69DC  89 83 80 32 01 00           mov     [rbx+13280h], eax
00007FF91DFE69E2  8B 83 20 33 01 00           mov     eax, [rbx+13320h]
00007FF91DFE69E8  89 83 30 33 01 00           mov     [rbx+13330h], eax
00007FF91DFE69EE  8B 83 10 33 01 00           mov     eax, [rbx+13310h]
00007FF91DFE69F4  89 83 20 33 01 00           mov     [rbx+13320h], eax
00007FF91DFE69FA  8B 83 00 33 01 00           mov     eax, [rbx+13300h]
00007FF91DFE6A00  89 83 10 33 01 00           mov     [rbx+13310h], eax
00007FF91DFE6A06  8B 83 F0 32 01 00           mov     eax, [rbx+132F0h]
00007FF91DFE6A0C  89 83 00 33 01 00           mov     [rbx+13300h], eax
00007FF91DFE6A12  8B 83 E0 32 01 00           mov     eax, [rbx+132E0h]
00007FF91DFE6A18  89 83 F0 32 01 00           mov     [rbx+132F0h], eax
00007FF91DFE6A1E  8B 83 D0 32 01 00           mov     eax, [rbx+132D0h]
00007FF91DFE6A24  89 83 E0 32 01 00           mov     [rbx+132E0h], eax
00007FF91DFE6A2A  8B 83 C0 32 01 00           mov     eax, [rbx+132C0h]
00007FF91DFE6A30  89 83 D0 32 01 00           mov     [rbx+132D0h], eax
00007FF91DFE6A36  8B 83 A0 33 01 00           mov     eax, [rbx+133A0h]
00007FF91DFE6A3C  89 83 B0 33 01 00           mov     [rbx+133B0h], eax
00007FF91DFE6A42  8B 83 90 33 01 00           mov     eax, [rbx+13390h]
00007FF91DFE6A48  89 83 A0 33 01 00           mov     [rbx+133A0h], eax
00007FF91DFE6A4E  8B 83 80 33 01 00           mov     eax, [rbx+13380h]
00007FF91DFE6A54  89 83 90 33 01 00           mov     [rbx+13390h], eax
00007FF91DFE6A5A  8B 83 70 33 01 00           mov     eax, [rbx+13370h]
00007FF91DFE6A60  89 83 80 33 01 00           mov     [rbx+13380h], eax
00007FF91DFE6A66  8B 83 60 33 01 00           mov     eax, [rbx+13360h]
00007FF91DFE6A6C  89 83 70 33 01 00           mov     [rbx+13370h], eax
00007FF91DFE6A72  8B 83 50 33 01 00           mov     eax, [rbx+13350h]
00007FF91DFE6A78  89 83 60 33 01 00           mov     [rbx+13360h], eax
00007FF91DFE6A7E  8B 83 40 33 01 00           mov     eax, [rbx+13340h]
00007FF91DFE6A84  89 83 50 33 01 00           mov     [rbx+13350h], eax
00007FF91DFE6A8A  8B 83 20 34 01 00           mov     eax, [rbx+13420h]
00007FF91DFE6A90  89 83 30 34 01 00           mov     [rbx+13430h], eax
00007FF91DFE6A96  8B 83 10 34 01 00           mov     eax, [rbx+13410h]
00007FF91DFE6A9C  89 83 20 34 01 00           mov     [rbx+13420h], eax
00007FF91DFE6AA2  8B 83 00 34 01 00           mov     eax, [rbx+13400h]
00007FF91DFE6AA8  89 83 10 34 01 00           mov     [rbx+13410h], eax
00007FF91DFE6AAE  8B 83 F0 33 01 00           mov     eax, [rbx+133F0h]
00007FF91DFE6AB4  89 83 00 34 01 00           mov     [rbx+13400h], eax
00007FF91DFE6ABA  8B 83 E0 33 01 00           mov     eax, [rbx+133E0h]
00007FF91DFE6AC0  89 83 F0 33 01 00           mov     [rbx+133F0h], eax
00007FF91DFE6AC6  8B 83 D0 33 01 00           mov     eax, [rbx+133D0h]
00007FF91DFE6ACC  89 83 E0 33 01 00           mov     [rbx+133E0h], eax
00007FF91DFE6AD2  8B 83 C0 33 01 00           mov     eax, [rbx+133C0h]
00007FF91DFE6AD8  89 83 D0 33 01 00           mov     [rbx+133D0h], eax
00007FF91DFE6ADE  8B 83 A0 34 01 00           mov     eax, [rbx+134A0h]
00007FF91DFE6AE4  89 83 B0 34 01 00           mov     [rbx+134B0h], eax
00007FF91DFE6AEA  8B 83 90 34 01 00           mov     eax, [rbx+13490h]
00007FF91DFE6AF0  89 83 A0 34 01 00           mov     [rbx+134A0h], eax
00007FF91DFE6AF6  8B 83 80 34 01 00           mov     eax, [rbx+13480h]
00007FF91DFE6AFC  89 83 90 34 01 00           mov     [rbx+13490h], eax
00007FF91DFE6B02  8B 83 70 34 01 00           mov     eax, [rbx+13470h]
00007FF91DFE6B08  89 83 80 34 01 00           mov     [rbx+13480h], eax
00007FF91DFE6B0E  8B 83 60 34 01 00           mov     eax, [rbx+13460h]
00007FF91DFE6B14  89 83 70 34 01 00           mov     [rbx+13470h], eax
00007FF91DFE6B1A  8B 83 50 34 01 00           mov     eax, [rbx+13450h]
00007FF91DFE6B20  89 83 60 34 01 00           mov     [rbx+13460h], eax
00007FF91DFE6B26  8B 83 40 34 01 00           mov     eax, [rbx+13440h]
00007FF91DFE6B2C  89 83 50 34 01 00           mov     [rbx+13450h], eax
00007FF91DFE6B32  8B 83 E0 34 01 00           mov     eax, [rbx+134E0h]
00007FF91DFE6B38  89 83 F0 34 01 00           mov     [rbx+134F0h], eax
00007FF91DFE6B3E  8B 83 D0 34 01 00           mov     eax, [rbx+134D0h]
00007FF91DFE6B44  89 83 E0 34 01 00           mov     [rbx+134E0h], eax
00007FF91DFE6B4A  F3 0F 11 83 F0 31 01 00     movss   dword ptr [rbx+131F0h], xmm0
00007FF91DFE6B52  F3 0F 11 8B 00 32 01 00     movss   dword ptr [rbx+13200h], xmm1
00007FF91DFE6B5A  F3 0F 58 AB 10 38 01 00     addss   xmm5, dword ptr [rbx+13810h]
00007FF91DFE6B62  F3 0F 59 9B 10 35 01 00     mulss   xmm3, dword ptr [rbx+13510h]
00007FF91DFE6B6A  F3 0F 10 83 00 35 01 00     movss   xmm0, dword ptr [rbx+13500h]
00007FF91DFE6B72  F3 0F 11 93 10 32 01 00     movss   dword ptr [rbx+13210h], xmm2
00007FF91DFE6B7A  F3 0F 10 93 30 35 01 00     movss   xmm2, dword ptr [rbx+13530h]
00007FF91DFE6B82  F3 0F 59 AB 20 38 01 00     mulss   xmm5, dword ptr [rbx+13820h]
00007FF91DFE6B8A  F3 0F 5F D3                 maxss   xmm2, xmm3
00007FF91DFE6B8E  F3 0F 58 AB 00 38 01 00     addss   xmm5, dword ptr [rbx+13800h]
00007FF91DFE6B96  F3 0F 11 93 20 32 01 00     movss   dword ptr [rbx+13220h], xmm2
00007FF91DFE6B9E  F3 0F 58 83 50 2E 01 00     addss   xmm0, dword ptr [rbx+12E50h]
00007FF91DFE6BA6  41 0F 2F EE                 comiss  xmm5, xmm14
00007FF91DFE6BAA  F3 0F 11 83 40 32 01 00     movss   dword ptr [rbx+13240h], xmm0
00007FF91DFE6BB2  76 05                       jbe     short loc_7FF91DFE6BB9
00007FF91DFE6BB4  0F 5A C5                    cvtps2pd xmm0, xmm5
00007FF91DFE6BB7  EB 03                       jmp     short loc_7FF91DFE6BBC
00007FF91DFE6BB9  0F 57 C0                    xorps   xmm0, xmm0
00007FF91DFE6BBC  F3 0F 10 0D 98 E3 75 00     movss   xmm1, cs:dword_7FF91E744F5C
00007FF91DFE6BC4  F3 44 0F 10 15 1B E6 75 00  movss   xmm10, cs:flt_7FF91E7451E8
00007FF91DFE6BCD  F3 0F 5E CA                 divss   xmm1, xmm2
00007FF91DFE6BD1  66 0F 5A C0                 cvtpd2ps xmm0, xmm0
00007FF91DFE6BD5  F3 0F 11 8B 30 32 01 00     movss   dword ptr [rbx+13230h], xmm1
00007FF91DFE6BDD  F3 0F 11 83 C0 34 01 00     movss   dword ptr [rbx+134C0h], xmm0
00007FF91DFE6BE5  F3 0F 10 B3 80 32 01 00     movss   xmm6, dword ptr [rbx+13280h]
00007FF91DFE6BED  F3 0F 10 8B 60 32 01 00     movss   xmm1, dword ptr [rbx+13260h]
00007FF91DFE6BF5  F3 0F 11 B3 A0 31 01 00     movss   dword ptr [rbx+131A0h], xmm6
00007FF91DFE6BFD  F3 0F 58 F2                 addss   xmm6, xmm2
00007FF91DFE6C01  F3 0F 11 8B B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm1
00007FF91DFE6C09  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE6C0D  76 1B                       jbe     short loc_7FF91DFE6C2A
00007FF91DFE6C0F  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE6C14  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE6C18  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE6C1B  E8 B8 88 36 00              call    fmodf
00007FF91DFE6C20  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE6C23  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE6C28  EB 1F                       jmp     short loc_7FF91DFE6C49
00007FF91DFE6C2A  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE6C2E  73 19                       jnb     short loc_7FF91DFE6C49
00007FF91DFE6C30  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE6C35  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE6C39  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE6C3C  E8 97 88 36 00              call    fmodf
00007FF91DFE6C41  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE6C44  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE6C49  F3 44 0F 10 25 BA E3 75 00  movss   xmm12, cs:dword_7FF91E74500C
00007FF91DFE6C52  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE6C55  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE6C5A  F3 0F 11 B3 90 31 01 00     movss   dword ptr [rbx+13190h], xmm6
00007FF91DFE6C62  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFE6C65  F3 0F 59 BB 80 35 01 00     mulss   xmm7, dword ptr [rbx+13580h]
00007FF91DFE6C6D  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFE6C72  E8 49 23 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE6C77  F3 44 0F 10 1D C4 E7 75 00  movss   xmm11, cs:dword_7FF91E745444
00007FF91DFE6C80  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFE6C83  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFE6C88  F3 0F 59 AB 30 32 01 00     mulss   xmm5, dword ptr [rbx+13230h]
00007FF91DFE6C90  F3 0F 59 AB 50 35 01 00     mulss   xmm5, dword ptr [rbx+13550h]
00007FF91DFE6C98  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE6C9C  73 06                       jnb     short loc_7FF91DFE6CA4
00007FF91DFE6C9E  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE6CA2  EB 05                       jmp     short loc_7FF91DFE6CA9
00007FF91DFE6CA4  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE6CA9  F3 0F 59 AB 20 35 01 00     mulss   xmm5, dword ptr [rbx+13520h]
00007FF91DFE6CB1  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE6CB4  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE6CB8  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE6CBB  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE6CBE  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE6CC6  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE6CC9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE6CCD  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE6CD0  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
00007FF91DFE6CD8  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE6CE0  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE6CE4  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
00007FF91DFE6CEC  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE6CF0  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE6CF3  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE6CFB  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE6CFF  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE6D03  F3 0F 10 8B 40 32 01 00     movss   xmm1, dword ptr [rbx+13240h]
00007FF91DFE6D0B  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE6D0F  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE6D12  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFE6D16  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE6D1A  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE6D1E  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE6D22  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE6D26  F3 0F 11 A3 90 32 01 00     movss   dword ptr [rbx+13290h], xmm4
00007FF91DFE6D2E  72 07                       jb      short loc_7FF91DFE6D37
00007FF91DFE6D30  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFE6D35  EB 05                       jmp     short loc_7FF91DFE6D3C
00007FF91DFE6D37  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFE6D3C  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE6D3F  73 06                       jnb     short loc_7FF91DFE6D47
00007FF91DFE6D41  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFE6D45  EB 06                       jmp     short loc_7FF91DFE6D4D
00007FF91DFE6D47  76 04                       jbe     short loc_7FF91DFE6D4D
00007FF91DFE6D49  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE6D4D  F3 44 0F 10 83 90 31 01 00  movss   xmm8, dword ptr [rbx+13190h]
00007FF91DFE6D56  F3 0F 59 B3 90 35 01 00     mulss   xmm6, dword ptr [rbx+13590h]
00007FF91DFE6D5E  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFE6D62  E8 59 22 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE6D67  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFE6D6A  F3 0F 10 83 40 35 01 00     movss   xmm0, dword ptr [rbx+13540h]
00007FF91DFE6D72  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFE6D76  72 18                       jb      short loc_7FF91DFE6D90
00007FF91DFE6D78  0F 2F 83 A0 31 01 00        comiss  xmm0, dword ptr [rbx+131A0h]
00007FF91DFE6D7F  76 0F                       jbe     short loc_7FF91DFE6D90
00007FF91DFE6D81  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
00007FF91DFE6D89  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFE6D8E  EB 08                       jmp     short loc_7FF91DFE6D98
00007FF91DFE6D90  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
00007FF91DFE6D98  0F 2F 3D 31 E5 75 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFE6D9F  F3 0F 59 A3 30 32 01 00     mulss   xmm4, dword ptr [rbx+13230h]
00007FF91DFE6DA7  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFE6DAC  F3 0F 59 A3 60 35 01 00     mulss   xmm4, dword ptr [rbx+13560h]
00007FF91DFE6DB4  72 03                       jb      short loc_7FF91DFE6DB9
00007FF91DFE6DB6  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFE6DB9  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFE6DBD  73 06                       jnb     short loc_7FF91DFE6DC5
00007FF91DFE6DBF  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFE6DC3  EB 05                       jmp     short loc_7FF91DFE6DCA
00007FF91DFE6DC5  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFE6DCA  F3 0F 11 BB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm7
00007FF91DFE6DD2  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFE6DD7  F3 0F 59 A3 20 35 01 00     mulss   xmm4, dword ptr [rbx+13520h]
00007FF91DFE6DDF  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFE6DE2  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE6DE7  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE6DEB  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE6DEE  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFE6DF3  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE6DF7  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE6DFA  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE6DFE  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFE6E02  F3 44 0F 59 8B F0 36 01 00  mulss   xmm9, dword ptr [rbx+136F0h]
00007FF91DFE6E0B  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE6E10  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE6E13  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE6E1B  F3 44 0F 58 8B E0 36 01 00  addss   xmm9, dword ptr [rbx+136E0h]
00007FF91DFE6E24  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE6E2C  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE6E31  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE6E34  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE6E3C  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFE6E41  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE6E45  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE6E4A  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFE6E4D  0F 54 05 3C E9 75 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFE6E54  0F 57 05 65 E9 75 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFE6E5B  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFE6E60  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFE6E65  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFE6E6A  F3 44 0F 11 8B A0 32 01 00  movss   dword ptr [rbx+132A0h], xmm9
00007FF91DFE6E73  E8 48 21 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE6E78  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE6E7C  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFE6E80  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFE6E85  73 06                       jnb     short loc_7FF91DFE6E8D
00007FF91DFE6E87  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE6E8B  EB 06                       jmp     short loc_7FF91DFE6E93
00007FF91DFE6E8D  76 04                       jbe     short loc_7FF91DFE6E93
00007FF91DFE6E8F  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE6E93  F3 44 0F 59 83 30 32 01 00  mulss   xmm8, dword ptr [rbx+13230h]
00007FF91DFE6E9C  F3 0F 59 BB A0 35 01 00     mulss   xmm7, dword ptr [rbx+135A0h]
00007FF91DFE6EA4  F3 44 0F 59 05 EB 3D 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFE6EAD  F3 44 0F 59 83 70 35 01 00  mulss   xmm8, dword ptr [rbx+13570h]
00007FF91DFE6EB6  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFE6EBA  73 06                       jnb     short loc_7FF91DFE6EC2
00007FF91DFE6EBC  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFE6EC0  EB 05                       jmp     short loc_7FF91DFE6EC7
00007FF91DFE6EC2  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFE6EC7  F3 44 0F 59 83 20 35 01 00  mulss   xmm8, dword ptr [rbx+13520h]
00007FF91DFE6ED0  F3 44 0F 59 8B 00 32 01 00  mulss   xmm9, dword ptr [rbx+13200h]
00007FF91DFE6ED9  F3 0F 10 B3 90 31 01 00     movss   xmm6, dword ptr [rbx+13190h]
00007FF91DFE6EE1  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE6EE5  F3 0F 10 AB B0 31 01 00     movss   xmm5, dword ptr [rbx+131B0h]
00007FF91DFE6EED  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFE6EF2  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE6EF5  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE6EF8  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE6EFC  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE6EFF  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
00007FF91DFE6F07  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE6F0A  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE6F12  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
00007FF91DFE6F1A  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFE6F1F  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE6F27  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE6F2B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE6F2E  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE6F36  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE6F3A  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE6F3E  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE6F42  F3 0F 10 83 90 32 01 00     movss   xmm0, dword ptr [rbx+13290h]
00007FF91DFE6F4A  F3 0F 59 83 F0 31 01 00     mulss   xmm0, dword ptr [rbx+131F0h]
00007FF91DFE6F52  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE6F56  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFE6F5B  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFE6F60  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE6F64  F3 0F 59 A3 10 32 01 00     mulss   xmm4, dword ptr [rbx+13210h]
00007FF91DFE6F6C  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE6F70  F3 0F 11 A3 C0 32 01 00     movss   dword ptr [rbx+132C0h], xmm4
00007FF91DFE6F78  F3 0F 11 B3 A0 31 01 00     movss   dword ptr [rbx+131A0h], xmm6
00007FF91DFE6F80  F3 0F 11 AB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm5
00007FF91DFE6F88  F3 0F 58 B3 20 32 01 00     addss   xmm6, dword ptr [rbx+13220h]
00007FF91DFE6F90  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE6F94  76 1B                       jbe     short loc_7FF91DFE6FB1
00007FF91DFE6F96  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE6F9B  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE6F9F  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE6FA2  E8 31 85 36 00              call    fmodf
00007FF91DFE6FA7  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE6FAA  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE6FAF  EB 1F                       jmp     short loc_7FF91DFE6FD0
00007FF91DFE6FB1  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE6FB5  73 19                       jnb     short loc_7FF91DFE6FD0
00007FF91DFE6FB7  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE6FBC  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE6FC0  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE6FC3  E8 10 85 36 00              call    fmodf
00007FF91DFE6FC8  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE6FCB  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE6FD0  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE6FD3  F3 0F 11 B3 90 31 01 00     movss   dword ptr [rbx+13190h], xmm6
00007FF91DFE6FDB  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE6FE0  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFE6FE3  F3 0F 59 BB 80 35 01 00     mulss   xmm7, dword ptr [rbx+13580h]
00007FF91DFE6FEB  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFE6FF0  E8 CB 1F FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE6FF5  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFE6FF8  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFE6FFD  F3 0F 59 AB 30 32 01 00     mulss   xmm5, dword ptr [rbx+13230h]
00007FF91DFE7005  F3 0F 59 AB 50 35 01 00     mulss   xmm5, dword ptr [rbx+13550h]
00007FF91DFE700D  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE7011  73 06                       jnb     short loc_7FF91DFE7019
00007FF91DFE7013  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE7017  EB 05                       jmp     short loc_7FF91DFE701E
00007FF91DFE7019  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE701E  F3 0F 59 AB 20 35 01 00     mulss   xmm5, dword ptr [rbx+13520h]
00007FF91DFE7026  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE7029  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE702D  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE7030  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE7033  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE703B  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE703E  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE7042  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE7045  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
00007FF91DFE704D  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE7055  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE7059  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
00007FF91DFE7061  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE7065  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE7068  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE7070  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE7074  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE7078  F3 0F 10 8B 40 32 01 00     movss   xmm1, dword ptr [rbx+13240h]
00007FF91DFE7080  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE7084  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE7087  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFE708B  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE708F  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE7093  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE7097  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE709B  F3 0F 11 A3 90 32 01 00     movss   dword ptr [rbx+13290h], xmm4
00007FF91DFE70A3  72 07                       jb      short loc_7FF91DFE70AC
00007FF91DFE70A5  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFE70AA  EB 05                       jmp     short loc_7FF91DFE70B1
00007FF91DFE70AC  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFE70B1  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE70B4  73 06                       jnb     short loc_7FF91DFE70BC
00007FF91DFE70B6  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFE70BA  EB 06                       jmp     short loc_7FF91DFE70C2
00007FF91DFE70BC  76 04                       jbe     short loc_7FF91DFE70C2
00007FF91DFE70BE  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE70C2  F3 44 0F 10 83 90 31 01 00  movss   xmm8, dword ptr [rbx+13190h]
00007FF91DFE70CB  F3 0F 59 B3 90 35 01 00     mulss   xmm6, dword ptr [rbx+13590h]
00007FF91DFE70D3  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFE70D7  E8 E4 1E FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE70DC  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFE70DF  F3 0F 10 83 40 35 01 00     movss   xmm0, dword ptr [rbx+13540h]
00007FF91DFE70E7  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFE70EB  72 18                       jb      short loc_7FF91DFE7105
00007FF91DFE70ED  0F 2F 83 A0 31 01 00        comiss  xmm0, dword ptr [rbx+131A0h]
00007FF91DFE70F4  76 0F                       jbe     short loc_7FF91DFE7105
00007FF91DFE70F6  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
00007FF91DFE70FE  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFE7103  EB 08                       jmp     short loc_7FF91DFE710D
00007FF91DFE7105  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
00007FF91DFE710D  0F 2F 3D BC E1 75 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFE7114  F3 0F 59 A3 30 32 01 00     mulss   xmm4, dword ptr [rbx+13230h]
00007FF91DFE711C  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFE7121  F3 0F 59 A3 60 35 01 00     mulss   xmm4, dword ptr [rbx+13560h]
00007FF91DFE7129  72 03                       jb      short loc_7FF91DFE712E
00007FF91DFE712B  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFE712E  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFE7132  73 06                       jnb     short loc_7FF91DFE713A
00007FF91DFE7134  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFE7138  EB 05                       jmp     short loc_7FF91DFE713F
00007FF91DFE713A  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFE713F  F3 0F 11 BB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm7
00007FF91DFE7147  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFE714C  F3 0F 59 A3 20 35 01 00     mulss   xmm4, dword ptr [rbx+13520h]
00007FF91DFE7154  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFE7157  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE715C  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE7160  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE7163  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFE7168  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE716C  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE716F  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE7173  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFE7177  F3 44 0F 59 8B F0 36 01 00  mulss   xmm9, dword ptr [rbx+136F0h]
00007FF91DFE7180  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE7185  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE7188  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE7190  F3 44 0F 58 8B E0 36 01 00  addss   xmm9, dword ptr [rbx+136E0h]
00007FF91DFE7199  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE71A1  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE71A6  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE71A9  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE71B1  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFE71B6  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE71BA  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE71BF  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFE71C2  0F 54 05 C7 E5 75 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFE71C9  0F 57 05 F0 E5 75 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFE71D0  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFE71D5  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFE71DA  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFE71DF  F3 44 0F 11 8B A0 32 01 00  movss   dword ptr [rbx+132A0h], xmm9
00007FF91DFE71E8  E8 D3 1D FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE71ED  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE71F1  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFE71F5  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFE71FA  73 06                       jnb     short loc_7FF91DFE7202
00007FF91DFE71FC  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE7200  EB 06                       jmp     short loc_7FF91DFE7208
00007FF91DFE7202  76 04                       jbe     short loc_7FF91DFE7208
00007FF91DFE7204  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE7208  F3 44 0F 59 83 30 32 01 00  mulss   xmm8, dword ptr [rbx+13230h]
00007FF91DFE7211  F3 0F 59 BB A0 35 01 00     mulss   xmm7, dword ptr [rbx+135A0h]
00007FF91DFE7219  F3 44 0F 59 05 76 3A 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFE7222  F3 44 0F 59 83 70 35 01 00  mulss   xmm8, dword ptr [rbx+13570h]
00007FF91DFE722B  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFE722F  73 06                       jnb     short loc_7FF91DFE7237
00007FF91DFE7231  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFE7235  EB 05                       jmp     short loc_7FF91DFE723C
00007FF91DFE7237  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFE723C  F3 44 0F 59 83 20 35 01 00  mulss   xmm8, dword ptr [rbx+13520h]
00007FF91DFE7245  F3 44 0F 59 8B 00 32 01 00  mulss   xmm9, dword ptr [rbx+13200h]
00007FF91DFE724E  F3 0F 10 B3 90 31 01 00     movss   xmm6, dword ptr [rbx+13190h]
00007FF91DFE7256  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE725A  F3 0F 10 AB B0 31 01 00     movss   xmm5, dword ptr [rbx+131B0h]
00007FF91DFE7262  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFE7267  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE726A  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE726D  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE7271  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE7274  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
00007FF91DFE727C  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE727F  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE7287  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
00007FF91DFE728F  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFE7294  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE729C  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE72A0  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE72A3  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE72AB  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE72AF  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE72B3  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE72B7  F3 0F 10 83 90 32 01 00     movss   xmm0, dword ptr [rbx+13290h]
00007FF91DFE72BF  F3 0F 59 83 F0 31 01 00     mulss   xmm0, dword ptr [rbx+131F0h]
00007FF91DFE72C7  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE72CB  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFE72D0  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFE72D5  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE72D9  F3 0F 59 A3 10 32 01 00     mulss   xmm4, dword ptr [rbx+13210h]
00007FF91DFE72E1  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE72E5  F3 0F 11 A3 40 33 01 00     movss   dword ptr [rbx+13340h], xmm4
00007FF91DFE72ED  F3 0F 11 B3 A0 31 01 00     movss   dword ptr [rbx+131A0h], xmm6
00007FF91DFE72F5  F3 0F 11 AB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm5
00007FF91DFE72FD  F3 0F 58 B3 20 32 01 00     addss   xmm6, dword ptr [rbx+13220h]
00007FF91DFE7305  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE7309  76 1B                       jbe     short loc_7FF91DFE7326
00007FF91DFE730B  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE7310  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE7314  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE7317  E8 BC 81 36 00              call    fmodf
00007FF91DFE731C  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE731F  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE7324  EB 1F                       jmp     short loc_7FF91DFE7345
00007FF91DFE7326  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE732A  73 19                       jnb     short loc_7FF91DFE7345
00007FF91DFE732C  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE7331  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE7335  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE7338  E8 9B 81 36 00              call    fmodf
00007FF91DFE733D  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE7340  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE7345  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE7348  F3 0F 11 B3 90 31 01 00     movss   dword ptr [rbx+13190h], xmm6
00007FF91DFE7350  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE7355  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFE7358  F3 0F 59 BB 80 35 01 00     mulss   xmm7, dword ptr [rbx+13580h]
00007FF91DFE7360  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFE7365  E8 56 1C FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE736A  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFE736D  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFE7372  F3 0F 59 AB 30 32 01 00     mulss   xmm5, dword ptr [rbx+13230h]
00007FF91DFE737A  F3 0F 59 AB 50 35 01 00     mulss   xmm5, dword ptr [rbx+13550h]
00007FF91DFE7382  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE7386  73 06                       jnb     short loc_7FF91DFE738E
00007FF91DFE7388  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE738C  EB 05                       jmp     short loc_7FF91DFE7393
00007FF91DFE738E  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE7393  F3 0F 59 AB 20 35 01 00     mulss   xmm5, dword ptr [rbx+13520h]
00007FF91DFE739B  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE739E  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE73A2  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE73A5  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE73A8  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE73B0  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE73B3  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE73B7  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE73BA  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
00007FF91DFE73C2  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE73CA  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE73CE  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
00007FF91DFE73D6  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE73DA  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE73DD  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE73E5  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE73E9  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE73ED  F3 0F 10 8B 40 32 01 00     movss   xmm1, dword ptr [rbx+13240h]
00007FF91DFE73F5  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE73F9  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE73FC  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFE7400  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE7404  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE7408  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE740C  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE7410  F3 0F 11 A3 90 32 01 00     movss   dword ptr [rbx+13290h], xmm4
00007FF91DFE7418  72 07                       jb      short loc_7FF91DFE7421
00007FF91DFE741A  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFE741F  EB 05                       jmp     short loc_7FF91DFE7426
00007FF91DFE7421  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFE7426  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE7429  73 06                       jnb     short loc_7FF91DFE7431
00007FF91DFE742B  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFE742F  EB 06                       jmp     short loc_7FF91DFE7437
00007FF91DFE7431  76 04                       jbe     short loc_7FF91DFE7437
00007FF91DFE7433  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE7437  F3 44 0F 10 83 90 31 01 00  movss   xmm8, dword ptr [rbx+13190h]
00007FF91DFE7440  F3 0F 59 B3 90 35 01 00     mulss   xmm6, dword ptr [rbx+13590h]
00007FF91DFE7448  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFE744C  E8 6F 1B FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE7451  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFE7454  F3 0F 10 83 40 35 01 00     movss   xmm0, dword ptr [rbx+13540h]
00007FF91DFE745C  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFE7460  72 18                       jb      short loc_7FF91DFE747A
00007FF91DFE7462  0F 2F 83 A0 31 01 00        comiss  xmm0, dword ptr [rbx+131A0h]
00007FF91DFE7469  76 0F                       jbe     short loc_7FF91DFE747A
00007FF91DFE746B  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
00007FF91DFE7473  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFE7478  EB 08                       jmp     short loc_7FF91DFE7482
00007FF91DFE747A  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
00007FF91DFE7482  0F 2F 3D 47 DE 75 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFE7489  F3 0F 59 A3 30 32 01 00     mulss   xmm4, dword ptr [rbx+13230h]
00007FF91DFE7491  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFE7496  F3 0F 59 A3 60 35 01 00     mulss   xmm4, dword ptr [rbx+13560h]
00007FF91DFE749E  72 03                       jb      short loc_7FF91DFE74A3
00007FF91DFE74A0  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFE74A3  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFE74A7  73 06                       jnb     short loc_7FF91DFE74AF
00007FF91DFE74A9  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFE74AD  EB 05                       jmp     short loc_7FF91DFE74B4
00007FF91DFE74AF  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFE74B4  F3 0F 11 BB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm7
00007FF91DFE74BC  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFE74C1  F3 0F 59 A3 20 35 01 00     mulss   xmm4, dword ptr [rbx+13520h]
00007FF91DFE74C9  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFE74CC  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE74D1  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE74D5  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE74D8  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFE74DD  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE74E1  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE74E4  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE74E8  44 0F 28 CA                 movaps  xmm9, xmm2
00007FF91DFE74EC  F3 44 0F 59 8B F0 36 01 00  mulss   xmm9, dword ptr [rbx+136F0h]
00007FF91DFE74F5  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE74FA  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE74FD  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE7505  F3 44 0F 58 8B E0 36 01 00  addss   xmm9, dword ptr [rbx+136E0h]
00007FF91DFE750E  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE7516  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE751B  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE751E  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE7526  F3 44 0F 58 C9              addss   xmm9, xmm1
00007FF91DFE752B  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE752F  F3 44 0F 59 C8              mulss   xmm9, xmm0
00007FF91DFE7534  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFE7537  0F 54 05 52 E2 75 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFE753E  0F 57 05 7B E2 75 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFE7545  F3 44 0F 58 CB              addss   xmm9, xmm3
00007FF91DFE754A  F3 44 0F 58 CC              addss   xmm9, xmm4
00007FF91DFE754F  F3 44 0F 59 CE              mulss   xmm9, xmm6
00007FF91DFE7554  F3 44 0F 11 8B A0 32 01 00  movss   dword ptr [rbx+132A0h], xmm9
00007FF91DFE755D  E8 5E 1A FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE7562  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE7566  44 0F 28 C0                 movaps  xmm8, xmm0
00007FF91DFE756A  F3 45 0F 58 C5              addss   xmm8, xmm13
00007FF91DFE756F  73 06                       jnb     short loc_7FF91DFE7577
00007FF91DFE7571  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE7575  EB 06                       jmp     short loc_7FF91DFE757D
00007FF91DFE7577  76 04                       jbe     short loc_7FF91DFE757D
00007FF91DFE7579  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE757D  F3 44 0F 59 83 30 32 01 00  mulss   xmm8, dword ptr [rbx+13230h]
00007FF91DFE7586  F3 0F 59 BB A0 35 01 00     mulss   xmm7, dword ptr [rbx+135A0h]
00007FF91DFE758E  F3 44 0F 59 05 01 37 60 00  mulss   xmm8, cs:dword_7FF91E5EAC98
00007FF91DFE7597  F3 44 0F 59 83 70 35 01 00  mulss   xmm8, dword ptr [rbx+13570h]
00007FF91DFE75A0  45 0F 2F C7                 comiss  xmm8, xmm15
00007FF91DFE75A4  73 06                       jnb     short loc_7FF91DFE75AC
00007FF91DFE75A6  45 0F 28 C7                 movaps  xmm8, xmm15
00007FF91DFE75AA  EB 05                       jmp     short loc_7FF91DFE75B1
00007FF91DFE75AC  F3 45 0F 5D C5              minss   xmm8, xmm13
00007FF91DFE75B1  F3 44 0F 59 83 20 35 01 00  mulss   xmm8, dword ptr [rbx+13520h]
00007FF91DFE75BA  F3 44 0F 59 8B 00 32 01 00  mulss   xmm9, dword ptr [rbx+13200h]
00007FF91DFE75C3  F3 0F 10 B3 90 31 01 00     movss   xmm6, dword ptr [rbx+13190h]
00007FF91DFE75CB  41 0F 28 D0                 movaps  xmm2, xmm8
00007FF91DFE75CF  F3 0F 10 AB B0 31 01 00     movss   xmm5, dword ptr [rbx+131B0h]
00007FF91DFE75D7  F3 41 0F 59 D0              mulss   xmm2, xmm8
00007FF91DFE75DC  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE75DF  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE75E2  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE75E6  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE75E9  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
00007FF91DFE75F1  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE75F4  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE75FC  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
00007FF91DFE7604  F3 41 0F 59 D8              mulss   xmm3, xmm8
00007FF91DFE7609  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE7611  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE7615  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE7618  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE7620  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE7624  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE7628  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE762C  F3 0F 10 83 90 32 01 00     movss   xmm0, dword ptr [rbx+13290h]
00007FF91DFE7634  F3 0F 59 83 F0 31 01 00     mulss   xmm0, dword ptr [rbx+131F0h]
00007FF91DFE763C  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE7640  F3 41 0F 58 C1              addss   xmm0, xmm9
00007FF91DFE7645  F3 41 0F 58 E0              addss   xmm4, xmm8
00007FF91DFE764A  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE764E  F3 0F 59 A3 10 32 01 00     mulss   xmm4, dword ptr [rbx+13210h]
00007FF91DFE7656  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE765A  F3 0F 11 A3 C0 33 01 00     movss   dword ptr [rbx+133C0h], xmm4
00007FF91DFE7662  F3 0F 11 B3 A0 31 01 00     movss   dword ptr [rbx+131A0h], xmm6
00007FF91DFE766A  F3 0F 11 AB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm5
00007FF91DFE7672  F3 0F 58 B3 20 32 01 00     addss   xmm6, dword ptr [rbx+13220h]
00007FF91DFE767A  41 0F 2F F5                 comiss  xmm6, xmm13
00007FF91DFE767E  76 1B                       jbe     short loc_7FF91DFE769B
00007FF91DFE7680  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE7685  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE7689  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE768C  E8 47 7E 36 00              call    fmodf
00007FF91DFE7691  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE7694  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE7699  EB 1F                       jmp     short loc_7FF91DFE76BA
00007FF91DFE769B  41 0F 2F F7                 comiss  xmm6, xmm15
00007FF91DFE769F  73 19                       jnb     short loc_7FF91DFE76BA
00007FF91DFE76A1  F3 41 0F 5C F5              subss   xmm6, xmm13
00007FF91DFE76A6  41 0F 28 CA                 movaps  xmm1, xmm10; Y
00007FF91DFE76AA  0F 28 C6                    movaps  xmm0, xmm6; X
00007FF91DFE76AD  E8 26 7E 36 00              call    fmodf
00007FF91DFE76B2  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE76B5  F3 41 0F 58 F5              addss   xmm6, xmm13
00007FF91DFE76BA  0F 28 C6                    movaps  xmm0, xmm6
00007FF91DFE76BD  F3 0F 11 B3 90 31 01 00     movss   dword ptr [rbx+13190h], xmm6
00007FF91DFE76C5  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE76CA  0F 28 FE                    movaps  xmm7, xmm6
00007FF91DFE76CD  F3 0F 59 BB 80 35 01 00     mulss   xmm7, dword ptr [rbx+13580h]
00007FF91DFE76D5  F3 41 0F 59 C4              mulss   xmm0, xmm12
00007FF91DFE76DA  E8 E1 18 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE76DF  0F 28 E8                    movaps  xmm5, xmm0
00007FF91DFE76E2  F3 41 0F 59 EB              mulss   xmm5, xmm11
00007FF91DFE76E7  F3 0F 59 AB 30 32 01 00     mulss   xmm5, dword ptr [rbx+13230h]
00007FF91DFE76EF  F3 0F 59 AB 50 35 01 00     mulss   xmm5, dword ptr [rbx+13550h]
00007FF91DFE76F7  41 0F 2F EF                 comiss  xmm5, xmm15
00007FF91DFE76FB  73 06                       jnb     short loc_7FF91DFE7703
00007FF91DFE76FD  41 0F 28 EF                 movaps  xmm5, xmm15
00007FF91DFE7701  EB 05                       jmp     short loc_7FF91DFE7708
00007FF91DFE7703  F3 41 0F 5D ED              minss   xmm5, xmm13
00007FF91DFE7708  F3 0F 59 AB 20 35 01 00     mulss   xmm5, dword ptr [rbx+13520h]
00007FF91DFE7710  0F 28 D5                    movaps  xmm2, xmm5
00007FF91DFE7713  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE7717  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE771A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE771D  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE7725  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE7728  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE772C  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE772F  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
00007FF91DFE7737  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE773F  F3 0F 59 DD                 mulss   xmm3, xmm5
00007FF91DFE7743  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
00007FF91DFE774B  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE774F  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE7752  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE775A  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE775E  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE7762  F3 0F 10 8B 40 32 01 00     movss   xmm1, dword ptr [rbx+13240h]
00007FF91DFE776A  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE776E  0F 28 C1                    movaps  xmm0, xmm1
00007FF91DFE7771  F3 0F 58 C6                 addss   xmm0, xmm6
00007FF91DFE7775  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE7779  41 0F 2F C6                 comiss  xmm0, xmm14
00007FF91DFE777D  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE7781  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE7785  F3 0F 11 A3 90 32 01 00     movss   dword ptr [rbx+13290h], xmm4
00007FF91DFE778D  72 07                       jb      short loc_7FF91DFE7796
00007FF91DFE778F  F3 41 0F 58 CD              addss   xmm1, xmm13
00007FF91DFE7794  EB 05                       jmp     short loc_7FF91DFE779B
00007FF91DFE7796  F3 41 0F 5C CD              subss   xmm1, xmm13
00007FF91DFE779B  0F 28 F0                    movaps  xmm6, xmm0
00007FF91DFE779E  73 06                       jnb     short loc_7FF91DFE77A6
00007FF91DFE77A0  41 0F 28 F7                 movaps  xmm6, xmm15
00007FF91DFE77A4  EB 06                       jmp     short loc_7FF91DFE77AC
00007FF91DFE77A6  76 04                       jbe     short loc_7FF91DFE77AC
00007FF91DFE77A8  41 0F 28 F5                 movaps  xmm6, xmm13
00007FF91DFE77AC  F3 44 0F 10 83 90 31 01 00  movss   xmm8, dword ptr [rbx+13190h]
00007FF91DFE77B5  F3 0F 59 B3 90 35 01 00     mulss   xmm6, dword ptr [rbx+13590h]
00007FF91DFE77BD  F3 0F 5E C1                 divss   xmm0, xmm1
00007FF91DFE77C1  E8 FA 17 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE77C6  0F 28 E0                    movaps  xmm4, xmm0
00007FF91DFE77C9  F3 0F 10 83 40 35 01 00     movss   xmm0, dword ptr [rbx+13540h]
00007FF91DFE77D1  44 0F 2F C0                 comiss  xmm8, xmm0
00007FF91DFE77D5  72 18                       jb      short loc_7FF91DFE77EF
00007FF91DFE77D7  0F 2F 83 A0 31 01 00        comiss  xmm0, dword ptr [rbx+131A0h]
00007FF91DFE77DE  76 0F                       jbe     short loc_7FF91DFE77EF
00007FF91DFE77E0  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
00007FF91DFE77E8  F3 41 0F 58 FA              addss   xmm7, xmm10
00007FF91DFE77ED  EB 08                       jmp     short loc_7FF91DFE77F7
00007FF91DFE77EF  F3 0F 10 BB B0 31 01 00     movss   xmm7, dword ptr [rbx+131B0h]
00007FF91DFE77F7  0F 2F 3D D2 DA 75 00        comiss  xmm7, cs:dword_7FF91E7452D0
00007FF91DFE77FE  F3 0F 59 A3 30 32 01 00     mulss   xmm4, dword ptr [rbx+13230h]
00007FF91DFE7806  F3 41 0F 59 E3              mulss   xmm4, xmm11
00007FF91DFE780B  F3 0F 59 A3 60 35 01 00     mulss   xmm4, dword ptr [rbx+13560h]
00007FF91DFE7813  72 03                       jb      short loc_7FF91DFE7818
00007FF91DFE7815  0F 57 FF                    xorps   xmm7, xmm7
00007FF91DFE7818  41 0F 2F E7                 comiss  xmm4, xmm15
00007FF91DFE781C  73 06                       jnb     short loc_7FF91DFE7824
00007FF91DFE781E  41 0F 28 E7                 movaps  xmm4, xmm15
00007FF91DFE7822  EB 05                       jmp     short loc_7FF91DFE7829
00007FF91DFE7824  F3 41 0F 5D E5              minss   xmm4, xmm13
00007FF91DFE7829  F3 0F 11 BB B0 31 01 00     movss   dword ptr [rbx+131B0h], xmm7
00007FF91DFE7831  F3 41 0F 58 F8              addss   xmm7, xmm8
00007FF91DFE7836  F3 0F 59 A3 20 35 01 00     mulss   xmm4, dword ptr [rbx+13520h]
00007FF91DFE783E  0F 28 D4                    movaps  xmm2, xmm4
00007FF91DFE7841  F3 41 0F 58 FD              addss   xmm7, xmm13
00007FF91DFE7846  F3 0F 59 D4                 mulss   xmm2, xmm4
00007FF91DFE784A  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE784D  F3 41 0F 59 FC              mulss   xmm7, xmm12
00007FF91DFE7852  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE7856  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE7859  F3 0F 59 DC                 mulss   xmm3, xmm4
00007FF91DFE785D  44 0F 28 C2                 movaps  xmm8, xmm2
00007FF91DFE7861  F3 44 0F 59 83 F0 36 01 00  mulss   xmm8, dword ptr [rbx+136F0h]
00007FF91DFE786A  F3 41 0F 5C FD              subss   xmm7, xmm13
00007FF91DFE786F  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE7872  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE787A  F3 44 0F 58 83 E0 36 01 00  addss   xmm8, dword ptr [rbx+136E0h]
00007FF91DFE7883  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE788B  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFE7890  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE7893  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE789B  F3 44 0F 58 C1              addss   xmm8, xmm1
00007FF91DFE78A0  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE78A4  F3 44 0F 59 C0              mulss   xmm8, xmm0
00007FF91DFE78A9  0F 28 C7                    movaps  xmm0, xmm7
00007FF91DFE78AC  0F 54 05 DD DE 75 00        andps   xmm0, cs:xmmword_7FF91E745790
00007FF91DFE78B3  0F 57 05 06 DF 75 00        xorps   xmm0, cs:xmmword_7FF91E7457C0
00007FF91DFE78BA  F3 44 0F 58 C3              addss   xmm8, xmm3
00007FF91DFE78BF  F3 44 0F 58 C4              addss   xmm8, xmm4
00007FF91DFE78C4  F3 44 0F 59 C6              mulss   xmm8, xmm6
00007FF91DFE78C9  F3 44 0F 11 83 A0 32 01 00  movss   dword ptr [rbx+132A0h], xmm8
00007FF91DFE78D2  E8 E9 16 FE FF              call    sub_7FF91DFC8FC0
00007FF91DFE78D7  41 0F 2F FE                 comiss  xmm7, xmm14
00007FF91DFE78DB  F3 41 0F 58 C5              addss   xmm0, xmm13
00007FF91DFE78E0  73 06                       jnb     short loc_7FF91DFE78E8
00007FF91DFE78E2  41 0F 28 FF                 movaps  xmm7, xmm15
00007FF91DFE78E6  EB 06                       jmp     short loc_7FF91DFE78EE
00007FF91DFE78E8  76 04                       jbe     short loc_7FF91DFE78EE
00007FF91DFE78EA  41 0F 28 FD                 movaps  xmm7, xmm13
00007FF91DFE78EE  F3 0F 59 83 30 32 01 00     mulss   xmm0, dword ptr [rbx+13230h]
00007FF91DFE78F6  F3 0F 59 BB A0 35 01 00     mulss   xmm7, dword ptr [rbx+135A0h]
00007FF91DFE78FE  F3 0F 59 05 92 33 60 00     mulss   xmm0, cs:dword_7FF91E5EAC98
00007FF91DFE7906  F3 0F 59 83 70 35 01 00     mulss   xmm0, dword ptr [rbx+13570h]
00007FF91DFE790E  41 0F 2F C7                 comiss  xmm0, xmm15
00007FF91DFE7912  72 09                       jb      short loc_7FF91DFE791D
00007FF91DFE7914  44 0F 28 F8                 movaps  xmm15, xmm0
00007FF91DFE7918  F3 45 0F 5D FD              minss   xmm15, xmm13
00007FF91DFE791D  F3 44 0F 59 BB 20 35 01 00  mulss   xmm15, dword ptr [rbx+13520h]
00007FF91DFE7926  F3 44 0F 59 83 00 32 01 00  mulss   xmm8, dword ptr [rbx+13200h]
00007FF91DFE792F  F3 0F 10 AB 90 31 01 00     movss   xmm5, dword ptr [rbx+13190h]
00007FF91DFE7937  41 0F 28 D7                 movaps  xmm2, xmm15
00007FF91DFE793B  F3 0F 10 B3 B0 31 01 00     movss   xmm6, dword ptr [rbx+131B0h]
00007FF91DFE7943  F3 41 0F 59 D7              mulss   xmm2, xmm15
00007FF91DFE7948  0F 28 CA                    movaps  xmm1, xmm2
00007FF91DFE794B  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE794E  F3 0F 59 8B D0 36 01 00     mulss   xmm1, dword ptr [rbx+136D0h]
00007FF91DFE7956  0F 28 DA                    movaps  xmm3, xmm2
00007FF91DFE7959  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE795D  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE7960  F3 0F 58 8B C0 36 01 00     addss   xmm1, dword ptr [rbx+136C0h]
00007FF91DFE7968  F3 0F 59 A3 F0 36 01 00     mulss   xmm4, dword ptr [rbx+136F0h]
00007FF91DFE7970  F3 41 0F 59 DF              mulss   xmm3, xmm15
00007FF91DFE7975  F3 0F 58 A3 E0 36 01 00     addss   xmm4, dword ptr [rbx+136E0h]
00007FF91DFE797D  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE7981  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE7984  F3 0F 59 9B B0 36 01 00     mulss   xmm3, dword ptr [rbx+136B0h]
00007FF91DFE798C  F3 0F 59 C2                 mulss   xmm0, xmm2
00007FF91DFE7990  F3 0F 58 E1                 addss   xmm4, xmm1
00007FF91DFE7994  F3 0F 59 E0                 mulss   xmm4, xmm0
00007FF91DFE7998  F3 0F 10 83 90 32 01 00     movss   xmm0, dword ptr [rbx+13290h]
00007FF91DFE79A0  F3 0F 59 83 F0 31 01 00     mulss   xmm0, dword ptr [rbx+131F0h]
00007FF91DFE79A8  F3 0F 58 E3                 addss   xmm4, xmm3
00007FF91DFE79AC  F3 41 0F 58 C0              addss   xmm0, xmm8
00007FF91DFE79B1  F3 41 0F 58 E7              addss   xmm4, xmm15
00007FF91DFE79B6  F3 0F 59 E7                 mulss   xmm4, xmm7
00007FF91DFE79BA  F3 0F 59 A3 10 32 01 00     mulss   xmm4, dword ptr [rbx+13210h]
00007FF91DFE79C2  F3 0F 58 E0                 addss   xmm4, xmm0
00007FF91DFE79C6  F3 0F 11 A3 40 34 01 00     movss   dword ptr [rbx+13440h], xmm4
00007FF91DFE79CE  F3 0F 10 93 B0 34 01 00     movss   xmm2, dword ptr [rbx+134B0h]
00007FF91DFE79D6  F3 0F 11 AB 70 32 01 00     movss   dword ptr [rbx+13270h], xmm5
00007FF91DFE79DE  F3 0F 11 B3 50 32 01 00     movss   dword ptr [rbx+13250h], xmm6
00007FF91DFE79E6  F3 0F 10 83 C0 33 01 00     movss   xmm0, dword ptr [rbx+133C0h]
00007FF91DFE79EE  F3 0F 58 83 B0 33 01 00     addss   xmm0, dword ptr [rbx+133B0h]
00007FF91DFE79F6  F3 0F 10 8B 40 34 01 00     movss   xmm1, dword ptr [rbx+13440h]
00007FF91DFE79FE  F3 0F 58 8B 30 33 01 00     addss   xmm1, dword ptr [rbx+13330h]
00007FF91DFE7A06  F3 0F 10 AB 30 34 01 00     movss   xmm5, dword ptr [rbx+13430h]
00007FF91DFE7A0E  F3 0F 58 AB 40 33 01 00     addss   xmm5, dword ptr [rbx+13340h]
00007FF91DFE7A16  F3 0F 59 83 D0 35 01 00     mulss   xmm0, dword ptr [rbx+135D0h]
00007FF91DFE7A1E  F3 0F 59 8B E0 35 01 00     mulss   xmm1, dword ptr [rbx+135E0h]
00007FF91DFE7A26  F3 0F 59 AB C0 35 01 00     mulss   xmm5, dword ptr [rbx+135C0h]
00007FF91DFE7A2E  F3 0F 58 93 C0 32 01 00     addss   xmm2, dword ptr [rbx+132C0h]
00007FF91DFE7A36  F3 0F 59 93 B0 35 01 00     mulss   xmm2, dword ptr [rbx+135B0h]
00007FF91DFE7A3E  F3 0F 58 EA                 addss   xmm5, xmm2
00007FF91DFE7A42  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE7A46  F3 0F 10 83 A0 34 01 00     movss   xmm0, dword ptr [rbx+134A0h]
00007FF91DFE7A4E  F3 0F 58 83 D0 32 01 00     addss   xmm0, dword ptr [rbx+132D0h]
00007FF91DFE7A56  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE7A5A  F3 0F 10 8B 20 34 01 00     movss   xmm1, dword ptr [rbx+13420h]
00007FF91DFE7A62  F3 0F 59 83 F0 35 01 00     mulss   xmm0, dword ptr [rbx+135F0h]
00007FF91DFE7A6A  F3 0F 58 8B 50 33 01 00     addss   xmm1, dword ptr [rbx+13350h]
00007FF91DFE7A72  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE7A76  F3 0F 10 83 D0 33 01 00     movss   xmm0, dword ptr [rbx+133D0h]
00007FF91DFE7A7E  F3 0F 58 83 A0 33 01 00     addss   xmm0, dword ptr [rbx+133A0h]
00007FF91DFE7A86  F3 0F 59 8B 00 36 01 00     mulss   xmm1, dword ptr [rbx+13600h]
00007FF91DFE7A8E  F3 0F 59 83 10 36 01 00     mulss   xmm0, dword ptr [rbx+13610h]
00007FF91DFE7A96  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE7A9A  F3 0F 10 8B 50 34 01 00     movss   xmm1, dword ptr [rbx+13450h]
00007FF91DFE7AA2  F3 0F 58 8B 20 33 01 00     addss   xmm1, dword ptr [rbx+13320h]
00007FF91DFE7AAA  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE7AAE  F3 0F 10 83 90 34 01 00     movss   xmm0, dword ptr [rbx+13490h]
00007FF91DFE7AB6  F3 0F 59 8B 20 36 01 00     mulss   xmm1, dword ptr [rbx+13620h]
00007FF91DFE7ABE  F3 0F 58 83 E0 32 01 00     addss   xmm0, dword ptr [rbx+132E0h]
00007FF91DFE7AC6  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE7ACA  F3 0F 10 8B 60 33 01 00     movss   xmm1, dword ptr [rbx+13360h]
00007FF91DFE7AD2  F3 0F 58 8B 10 34 01 00     addss   xmm1, dword ptr [rbx+13410h]
00007FF91DFE7ADA  F3 0F 59 83 30 36 01 00     mulss   xmm0, dword ptr [rbx+13630h]
00007FF91DFE7AE2  F3 0F 59 8B 40 36 01 00     mulss   xmm1, dword ptr [rbx+13640h]
00007FF91DFE7AEA  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE7AEE  F3 0F 10 83 E0 33 01 00     movss   xmm0, dword ptr [rbx+133E0h]
00007FF91DFE7AF6  F3 0F 58 83 90 33 01 00     addss   xmm0, dword ptr [rbx+13390h]
00007FF91DFE7AFE  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE7B02  F3 0F 10 8B 10 33 01 00     movss   xmm1, dword ptr [rbx+13310h]
00007FF91DFE7B0A  F3 0F 59 83 50 36 01 00     mulss   xmm0, dword ptr [rbx+13650h]
00007FF91DFE7B12  F3 0F 58 8B 60 34 01 00     addss   xmm1, dword ptr [rbx+13460h]
00007FF91DFE7B1A  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE7B1E  F3 0F 10 83 80 34 01 00     movss   xmm0, dword ptr [rbx+13480h]
00007FF91DFE7B26  F3 0F 59 8B 60 36 01 00     mulss   xmm1, dword ptr [rbx+13660h]
00007FF91DFE7B2E  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE7B32  F3 0F 58 83 F0 32 01 00     addss   xmm0, dword ptr [rbx+132F0h]
00007FF91DFE7B3A  F3 0F 10 93 E0 34 01 00     movss   xmm2, dword ptr [rbx+134E0h]
00007FF91DFE7B42  F3 0F 10 8B 00 34 01 00     movss   xmm1, dword ptr [rbx+13400h]
00007FF91DFE7B4A  0F 28 E2                    movaps  xmm4, xmm2
00007FF91DFE7B4D  F3 0F 59 A3 E0 37 01 00     mulss   xmm4, dword ptr [rbx+137E0h]
00007FF91DFE7B55  F3 0F 59 83 70 36 01 00     mulss   xmm0, dword ptr [rbx+13670h]
00007FF91DFE7B5D  F3 0F 58 A3 F0 34 01 00     addss   xmm4, dword ptr [rbx+134F0h]
00007FF91DFE7B65  F3 0F 58 8B 70 33 01 00     addss   xmm1, dword ptr [rbx+13370h]
00007FF91DFE7B6D  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE7B71  F3 0F 10 83 F0 33 01 00     movss   xmm0, dword ptr [rbx+133F0h]
00007FF91DFE7B79  F3 0F 58 83 80 33 01 00     addss   xmm0, dword ptr [rbx+13380h]
00007FF91DFE7B81  F3 0F 59 8B 80 36 01 00     mulss   xmm1, dword ptr [rbx+13680h]
00007FF91DFE7B89  F3 0F 59 83 90 36 01 00     mulss   xmm0, dword ptr [rbx+13690h]
00007FF91DFE7B91  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE7B95  F3 0F 10 8B 70 34 01 00     movss   xmm1, dword ptr [rbx+13470h]
00007FF91DFE7B9D  F3 0F 58 8B 00 33 01 00     addss   xmm1, dword ptr [rbx+13300h]
00007FF91DFE7BA5  F3 0F 58 E8                 addss   xmm5, xmm0
00007FF91DFE7BA9  0F 28 C2                    movaps  xmm0, xmm2
00007FF91DFE7BAC  F3 0F 59 8B A0 36 01 00     mulss   xmm1, dword ptr [rbx+136A0h]
00007FF91DFE7BB4  F3 0F 11 A3 E0 34 01 00     movss   dword ptr [rbx+134E0h], xmm4
00007FF91DFE7BBC  F3 0F 59 83 F0 37 01 00     mulss   xmm0, dword ptr [rbx+137F0h]
00007FF91DFE7BC4  F3 0F 58 E9                 addss   xmm5, xmm1
00007FF91DFE7BC8  F3 0F 58 C4                 addss   xmm0, xmm4
00007FF91DFE7BCC  0F 28 DD                    movaps  xmm3, xmm5
00007FF91DFE7BCF  F3 0F 5C D8                 subss   xmm3, xmm0
00007FF91DFE7BD3  0F 28 C3                    movaps  xmm0, xmm3
00007FF91DFE7BD6  F3 0F 59 83 E0 37 01 00     mulss   xmm0, dword ptr [rbx+137E0h]
00007FF91DFE7BDE  F3 0F 58 C2                 addss   xmm0, xmm2
00007FF91DFE7BE2  F3 0F 11 83 D0 34 01 00     movss   dword ptr [rbx+134D0h], xmm0
00007FF91DFE7BEA  F3 0F 10 93 30 38 01 00     movss   xmm2, dword ptr [rbx+13830h]
00007FF91DFE7BF2  F3 0F 59 9B C0 34 01 00     mulss   xmm3, dword ptr [rbx+134C0h]
00007FF91DFE7BFA  F3 0F 5C E3                 subss   xmm4, xmm3
00007FF91DFE7BFE  F3 0F 59 E2                 mulss   xmm4, xmm2
00007FF91DFE7C02  F3 0F 59 D5                 mulss   xmm2, xmm5
00007FF91DFE7C06  F3 0F 5C E2                 subss   xmm4, xmm2
00007FF91DFE7C0A  F3 0F 58 E5                 addss   xmm4, xmm5
00007FF91DFE7C0E  F3 0F 11 A3 B0 32 01 00     movss   dword ptr [rbx+132B0h], xmm4
00007FF91DFE7C16  F3 0F 11 A3 30 2D 01 00     movss   dword ptr [rbx+12D30h], xmm4
00007FF91DFE7C1E  44 0F 2E AB 60 8D 01 00     ucomiss xmm13, dword ptr [rbx+18D60h]
00007FF91DFE7C26  75 28                       jnz     short loc_7FF91DFE7C50
00007FF91DFE7C28  F3 0F 10 84 24 D0 00 00 00  movss   xmm0, [rsp+0C8h+arg_0]
00007FF91DFE7C31  F3 0F 11 83 B0 20 01 00     movss   dword ptr [rbx+120B0h], xmm0
00007FF91DFE7C39  C7 83 60 8D 01 00 00 00 00 00  mov     dword ptr [rbx+18D60h], 0
00007FF91DFE7C43  0F 1F 40 00                 nop     dword ptr [rax+00h]
00007FF91DFE7C47  66 0F 1F 84 00 00 00 00 00  nop     word ptr [rax+rax+00000000h]
00007FF91DFE7C50  8B 83 20 49 01 00           mov     eax, [rbx+14920h]
00007FF91DFE7C56  4C 8D 9C 24 C0 00 00 00     lea     r11, [rsp+0C8h+var_8]
00007FF91DFE7C5E  48 8B 0F                    mov     rcx, [rdi]
00007FF91DFE7C61  41 0F 28 73 F0              movaps  xmm6, xmmword ptr [r11-10h]
00007FF91DFE7C66  41 0F 28 7B E0              movaps  xmm7, xmmword ptr [r11-20h]
00007FF91DFE7C6B  45 0F 28 43 D0              movaps  xmm8, xmmword ptr [r11-30h]
00007FF91DFE7C70  45 0F 28 4B C0              movaps  xmm9, xmmword ptr [r11-40h]
00007FF91DFE7C75  45 0F 28 53 B0              movaps  xmm10, xmmword ptr [r11-50h]
00007FF91DFE7C7A  45 0F 28 5B A0              movaps  xmm11, xmmword ptr [r11-60h]
00007FF91DFE7C7F  45 0F 28 63 90              movaps  xmm12, xmmword ptr [r11-70h]
00007FF91DFE7C84  45 0F 28 6B 80              movaps  xmm13, xmmword ptr [r11-80h]
00007FF91DFE7C89  44 0F 28 74 24 30           movaps  xmm14, [rsp+0C8h+var_98]
00007FF91DFE7C8F  44 0F 28 7C 24 20           movaps  xmm15, [rsp+0C8h+var_A8]
00007FF91DFE7C95  89 01                       mov     [rcx], eax
00007FF91DFE7C97  8B 83 20 49 01 00           mov     eax, [rbx+14920h]
00007FF91DFE7C9D  48 8B 4F 08                 mov     rcx, [rdi+8]
00007FF91DFE7CA1  49 8B 5B 18                 mov     rbx, [r11+18h]
00007FF91DFE7CA5  89 01                       mov     [rcx], eax
00007FF91DFE7CA7  49 8B E3                    mov     rsp, r11
00007FF91DFE7CAA  5F                          pop     rdi
00007FF91DFE7CAB  C3                          retn
