; sub_180369070  @ 0x180369070  (RVA 0x369070)
; prototype: __int64 __fastcall(__int64, _DWORD **)

0000000180369070  48 8B C4                        mov     rax, rsp
0000000180369073  48 89 58 10                     mov     [rax+10h], rbx
0000000180369077  57                              push    rdi
0000000180369078  48 81 EC C0 00 00 00            sub     rsp, 0C0h
000000018036907F  F3 0F 10 A1 40 01 00 00         movss   xmm4, dword ptr [rcx+140h]
0000000180369087  48 8B FA                        mov     rdi, rdx
000000018036908A  0F 29 70 E8                     movaps  xmmword ptr [rax-18h], xmm6
000000018036908E  48 8B D9                        mov     rbx, rcx
0000000180369091  0F 29 78 D8                     movaps  xmmword ptr [rax-28h], xmm7
0000000180369095  44 0F 29 40 C8                  movaps  xmmword ptr [rax-38h], xmm8
000000018036909A  44 0F 29 48 B8                  movaps  xmmword ptr [rax-48h], xmm9
000000018036909F  44 0F 29 50 A8                  movaps  xmmword ptr [rax-58h], xmm10
00000001803690A4  44 0F 29 58 98                  movaps  xmmword ptr [rax-68h], xmm11
00000001803690A9  44 0F 29 60 88                  movaps  xmmword ptr [rax-78h], xmm12
00000001803690AE  44 0F 29 6C 24 40               movaps  [rsp+0C8h+var_88], xmm13
00000001803690B4  F3 44 0F 10 2D F7 BF 77 00      movss   xmm13, cs:dword_180AE50B4
00000001803690BD  44 0F 2E A9 80 8C 01 00         ucomiss xmm13, dword ptr [rcx+18C80h]
00000001803690C5  44 0F 29 74 24 30               movaps  [rsp+0C8h+var_98], xmm14
00000001803690CB  45 0F 57 F6                     xorps   xmm14, xmm14
00000001803690CF  F3 44 0F 11 B4 24 D0 00 00 00   movss   [rsp+0C8h+arg_0], xmm14
00000001803690D9  44 0F 29 7C 24 20               movaps  [rsp+0C8h+var_A8], xmm15
00000001803690DF  75 16                           jnz     short loc_1803690F7
00000001803690E1  F3 0F 11 A4 24 D0 00 00 00      movss   [rsp+0C8h+arg_0], xmm4
00000001803690EA  0F 57 E4                        xorps   xmm4, xmm4
00000001803690ED  C7 81 40 01 00 00 00 00 00 00   mov     dword ptr [rcx+140h], 0
00000001803690F7  F3 0F 10 81 70 49 01 00         movss   xmm0, dword ptr [rcx+14970h]
00000001803690FF  F3 0F 10 89 30 49 01 00         movss   xmm1, dword ptr [rcx+14930h]
0000000180369107  F3 0F 10 91 50 49 01 00         movss   xmm2, dword ptr [rcx+14950h]
000000018036910F  F3 0F 11 81 80 49 01 00         movss   dword ptr [rcx+14980h], xmm0
0000000180369117  F3 0F 59 05 A5 1C 62 00         mulss   xmm0, cs:dword_18098ADC4
000000018036911F  F3 0F 11 89 40 49 01 00         movss   dword ptr [rcx+14940h], xmm1
0000000180369127  F3 0F 11 91 60 49 01 00         movss   dword ptr [rcx+14960h], xmm2
000000018036912F  F3 0F 2C D0                     cvttss2si edx, xmm0
0000000180369133  85 D2                           test    edx, edx
0000000180369135  75 07                           jnz     short loc_18036913E
0000000180369137  BA 01 00 00 00                  mov     edx, 1
000000018036913C  EB 24                           jmp     short loc_180369162
000000018036913E  8B C2                           mov     eax, edx
0000000180369140  25 00 00 20 00                  and     eax, 200000h
0000000180369145  0F BA E2 17                     bt      edx, 17h
0000000180369149  73 08                           jnb     short loc_180369153
000000018036914B  85 C0                           test    eax, eax
000000018036914D  75 0C                           jnz     short loc_18036915B
000000018036914F  03 D2                           add     edx, edx
0000000180369151  EB 0F                           jmp     short loc_180369162
0000000180369153  85 C0                           test    eax, eax
0000000180369155  74 04                           jz      short loc_18036915B
0000000180369157  03 D2                           add     edx, edx
0000000180369159  EB 07                           jmp     short loc_180369162
000000018036915B  8D 14 55 01 00 00 00            lea     edx, ds:1[rdx*2]
0000000180369162  F3 0F 10 9B D0 00 00 00         movss   xmm3, dword ptr [rbx+0D0h]
000000018036916A  8B C2                           mov     eax, edx
000000018036916C  F3 0F 10 B3 B0 00 00 00         movss   xmm6, dword ptr [rbx+0B0h]
0000000180369174  25 FF FF FF 00                  and     eax, 0FFFFFFh
0000000180369179  F3 44 0F 10 83 70 01 00 00      movss   xmm8, dword ptr [rbx+170h]
0000000180369182  8B CA                           mov     ecx, edx
0000000180369184  F3 0F 10 BB 80 01 00 00         movss   xmm7, dword ptr [rbx+180h]
000000018036918C  81 CA 00 00 00 FF               or      edx, 0FF000000h
0000000180369192  F3 0F 59 CA                     mulss   xmm1, xmm2
0000000180369196  81 E1 00 00 00 01               and     ecx, 1000000h
000000018036919C  C7 83 B0 01 00 00 00 00 00 00   mov     dword ptr [rbx+1B0h], 0
00000001803691A6  F3 0F 11 9B E0 00 00 00         movss   dword ptr [rbx+0E0h], xmm3
00000001803691AE  45 0F 57 D2                     xorps   xmm10, xmm10
00000001803691B2  0F 44 D0                        cmovz   edx, eax
00000001803691B5  F3 0F 11 B3 C0 00 00 00         movss   dword ptr [rbx+0C0h], xmm6
00000001803691BD  8B 83 90 49 01 00               mov     eax, [rbx+14990h]
00000001803691C3  89 83 A0 49 01 00               mov     [rbx+149A0h], eax
00000001803691C9  8B 83 F0 01 00 00               mov     eax, [rbx+1F0h]
00000001803691CF  66 0F 6E C2                     movd    xmm0, edx
00000001803691D3  0F 5B C0                        cvtdq2ps xmm0, xmm0
00000001803691D6  89 83 00 02 00 00               mov     [rbx+200h], eax
00000001803691DC  F3 0F 11 A3 60 01 00 00         movss   dword ptr [rbx+160h], xmm4
00000001803691E4  F3 0F 59 05 84 1A 62 00         mulss   xmm0, cs:dword_18098AC70
00000001803691EC  F3 44 0F 11 83 90 01 00 00      movss   dword ptr [rbx+190h], xmm8
00000001803691F5  F3 0F 11 BB A0 01 00 00         movss   dword ptr [rbx+1A0h], xmm7
00000001803691FD  F3 0F 11 83 70 49 01 00         movss   dword ptr [rbx+14970h], xmm0
0000000180369205  F3 0F 59 83 B0 49 01 00         mulss   xmm0, dword ptr [rbx+149B0h]
000000018036920D  F3 0F 58 83 C0 49 01 00         addss   xmm0, dword ptr [rbx+149C0h]
0000000180369215  F3 0F 59 D0                     mulss   xmm2, xmm0
0000000180369219  F3 0F 11 83 90 49 01 00         movss   dword ptr [rbx+14990h], xmm0
0000000180369221  F3 0F 5C CA                     subss   xmm1, xmm2
0000000180369225  F3 0F 10 93 10 01 00 00         movss   xmm2, dword ptr [rbx+110h]
000000018036922D  F3 0F 11 93 20 01 00 00         movss   dword ptr [rbx+120h], xmm2
0000000180369235  F3 0F 58 C8                     addss   xmm1, xmm0
0000000180369239  F3 0F 10 83 F0 00 00 00         movss   xmm0, dword ptr [rbx+0F0h]
0000000180369241  F3 0F 59 D0                     mulss   xmm2, xmm0
0000000180369245  F3 0F 11 83 00 01 00 00         movss   dword ptr [rbx+100h], xmm0
000000018036924D  F3 0F 59 DA                     mulss   xmm3, xmm2
0000000180369251  0F 28 C2                        movaps  xmm0, xmm2
0000000180369254  F3 0F 11 8B D0 49 01 00         movss   dword ptr [rbx+149D0h], xmm1
000000018036925C  F3 0F 10 8B 30 01 00 00         movss   xmm1, dword ptr [rbx+130h]
0000000180369264  F3 0F 59 C1                     mulss   xmm0, xmm1
0000000180369268  F3 0F 59 F2                     mulss   xmm6, xmm2
000000018036926C  F3 0F 11 8B 50 01 00 00         movss   dword ptr [rbx+150h], xmm1
0000000180369274  F3 0F 11 93 C0 01 00 00         movss   dword ptr [rbx+1C0h], xmm2
000000018036927C  F3 0F 5C F0                     subss   xmm6, xmm0
0000000180369280  0F 28 C4                        movaps  xmm0, xmm4
0000000180369283  F3 0F 59 C2                     mulss   xmm0, xmm2
0000000180369287  F3 0F 5C D8                     subss   xmm3, xmm0
000000018036928B  F3 0F 58 F1                     addss   xmm6, xmm1
000000018036928F  F3 0F 58 DC                     addss   xmm3, xmm4
0000000180369293  F3 0F 11 B3 D0 01 00 00         movss   dword ptr [rbx+1D0h], xmm6
000000018036929B  F3 0F 11 9B E0 01 00 00         movss   dword ptr [rbx+1E0h], xmm3
00000001803692A3  0F 28 CB                        movaps  xmm1, xmm3
00000001803692A6  F3 0F 58 9B 20 02 00 00         addss   xmm3, dword ptr [rbx+220h]
00000001803692AE  41 0F 2F DE                     comiss  xmm3, xmm14
00000001803692B2  72 05                           jb      short loc_1803692B9
00000001803692B4  0F 57 C0                        xorps   xmm0, xmm0
00000001803692B7  EB 03                           jmp     short loc_1803692BC
00000001803692B9  0F 5A C3                        cvtps2pd xmm0, xmm3
00000001803692BC  41 0F 2E CE                     ucomiss xmm1, xmm14
00000001803692C0  F3 44 0F 10 3D 1B C2 77 00      movss   xmm15, cs:dword_180AE54E4
00000001803692C9  75 06                           jnz     short loc_1803692D1
00000001803692CB  41 0F 28 EF                     movaps  xmm5, xmm15
00000001803692CF  EB 04                           jmp     short loc_1803692D5
00000001803692D1  66 0F 5A E8                     cvtpd2ps xmm5, xmm0
00000001803692D5  41 0F 2F EE                     comiss  xmm5, xmm14
00000001803692D9  F3 0F 11 AB F0 01 00 00         movss   dword ptr [rbx+1F0h], xmm5
00000001803692E1  73 06                           jnb     short loc_1803692E9
00000001803692E3  41 0F 28 EF                     movaps  xmm5, xmm15
00000001803692E7  EB 06                           jmp     short loc_1803692EF
00000001803692E9  76 04                           jbe     short loc_1803692EF
00000001803692EB  41 0F 28 ED                     movaps  xmm5, xmm13
00000001803692EF  F3 0F 10 83 60 02 00 00         movss   xmm0, dword ptr [rbx+260h]
00000001803692F7  F3 41 0F 58 ED                  addss   xmm5, xmm13
00000001803692FC  F3 0F 10 93 00 03 00 00         movss   xmm2, dword ptr [rbx+300h]
0000000180369304  F3 0F 10 8B 70 02 00 00         movss   xmm1, dword ptr [rbx+270h]
000000018036930C  8B 83 30 02 00 00               mov     eax, [rbx+230h]
0000000180369312  0F 28 D9                        movaps  xmm3, xmm1
0000000180369315  F3 0F 10 A3 C0 02 00 00         movss   xmm4, dword ptr [rbx+2C0h]
000000018036931D  F3 0F 58 9B 10 03 00 00         addss   xmm3, dword ptr [rbx+310h]
0000000180369325  F2 44 0F 10 25 72 BE 77 00      movsd   xmm12, cs:dbl_180AE51A0
000000018036932E  F3 0F 11 AB 10 02 00 00         movss   dword ptr [rbx+210h], xmm5
0000000180369336  F3 0F 11 AB 30 02 00 00         movss   dword ptr [rbx+230h], xmm5
000000018036933E  F3 0F 59 E8                     mulss   xmm5, xmm0
0000000180369342  89 83 40 02 00 00               mov     [rbx+240h], eax
0000000180369348  F3 0F 11 A3 D0 02 00 00         movss   dword ptr [rbx+2D0h], xmm4
0000000180369350  F3 0F 5C E8                     subss   xmm5, xmm0
0000000180369354  0F 28 C2                        movaps  xmm0, xmm2
0000000180369357  F3 0F 59 C1                     mulss   xmm0, xmm1
000000018036935B  F3 0F 10 8B A0 02 00 00         movss   xmm1, dword ptr [rbx+2A0h]
0000000180369363  F3 0F 58 83 20 03 00 00         addss   xmm0, dword ptr [rbx+320h]
000000018036936B  F3 41 0F 58 ED                  addss   xmm5, xmm13
0000000180369370  F3 0F 5E C8                     divss   xmm1, xmm0
0000000180369374  F3 0F 10 83 30 03 00 00         movss   xmm0, dword ptr [rbx+330h]
000000018036937C  F3 0F 59 AB 50 02 00 00         mulss   xmm5, dword ptr [rbx+250h]
0000000180369384  F3 0F 59 CA                     mulss   xmm1, xmm2
0000000180369388  F3 0F 10 93 90 02 00 00         movss   xmm2, dword ptr [rbx+290h]
0000000180369390  F3 0F 11 AB E0 02 00 00         movss   dword ptr [rbx+2E0h], xmm5
0000000180369398  F3 0F 5C D1                     subss   xmm2, xmm1
000000018036939C  F3 0F 10 8B B0 02 00 00         movss   xmm1, dword ptr [rbx+2B0h]
00000001803693A4  F3 0F 58 D6                     addss   xmm2, xmm6
00000001803693A8  F3 0F 5C D4                     subss   xmm2, xmm4
00000001803693AC  F3 0F 11 93 90 02 00 00         movss   dword ptr [rbx+290h], xmm2
00000001803693B4  F3 0F 59 D3                     mulss   xmm2, xmm3
00000001803693B8  F3 0F 11 93 A0 02 00 00         movss   dword ptr [rbx+2A0h], xmm2
00000001803693C0  F3 0F 58 D4                     addss   xmm2, xmm4
00000001803693C4  F3 0F 5C E6                     subss   xmm4, xmm6
00000001803693C8  0F 54 25 C1 C3 77 00            andps   xmm4, cs:xmmword_180AE5790
00000001803693CF  F3 0F 5C C4                     subss   xmm0, xmm4
00000001803693D3  41 0F 2F C6                     comiss  xmm0, xmm14
00000001803693D7  0F 83 E8 00 00 00               jnb     loc_1803694C5
00000001803693DD  0F 57 C9                        xorps   xmm1, xmm1
00000001803693E0  0F 5A C1                        cvtps2pd xmm0, xmm1
00000001803693E3  41 0F 2E EE                     ucomiss xmm5, xmm14
00000001803693E7  66 0F 5A C0                     cvtpd2ps xmm0, xmm0
00000001803693EB  0F 28 C8                        movaps  xmm1, xmm0
00000001803693EE  F3 0F 11 83 B0 02 00 00         movss   dword ptr [rbx+2B0h], xmm0
00000001803693F6  F3 0F 59 CE                     mulss   xmm1, xmm6
00000001803693FA  F3 0F 59 C2                     mulss   xmm0, xmm2
00000001803693FE  F3 0F 5C C8                     subss   xmm1, xmm0
0000000180369402  F3 0F 58 CA                     addss   xmm1, xmm2
0000000180369406  75 03                           jnz     short loc_18036940B
0000000180369408  0F 28 CE                        movaps  xmm1, xmm6
000000018036940B  8B 83 70 03 00 00               mov     eax, [rbx+370h]
0000000180369411  48 8D 0D E8 6B C9 FF            lea     rcx, cs:180000000h
0000000180369418  F3 0F 59 BB 60 03 00 00         mulss   xmm7, dword ptr [rbx+360h]
0000000180369420  89 83 80 03 00 00               mov     [rbx+380h], eax
0000000180369426  F3 44 0F 59 83 50 03 00 00      mulss   xmm8, dword ptr [rbx+350h]
000000018036942F  F3 0F 10 83 90 04 00 00         movss   xmm0, dword ptr [rbx+490h]
0000000180369437  F3 0F 10 93 90 03 00 00         movss   xmm2, dword ptr [rbx+390h]
000000018036943F  F3 44 0F 10 8B F0 03 00 00      movss   xmm9, dword ptr [rbx+3F0h]
0000000180369448  F3 41 0F 58 F8                  addss   xmm7, xmm8
000000018036944D  F3 44 0F 10 83 D0 03 00 00      movss   xmm8, dword ptr [rbx+3D0h]
0000000180369456  F3 0F 2C C0                     cvttss2si eax, xmm0
000000018036945A  F3 0F 11 BB 70 03 00 00         movss   dword ptr [rbx+370h], xmm7
0000000180369462  F3 0F 10 BB B0 03 00 00         movss   xmm7, dword ptr [rbx+3B0h]
000000018036946A  F3 0F 11 8B C0 02 00 00         movss   dword ptr [rbx+2C0h], xmm1
0000000180369472  F3 0F 11 8B F0 02 00 00         movss   dword ptr [rbx+2F0h], xmm1
000000018036947A  F3 0F 10 8B 50 04 00 00         movss   xmm1, dword ptr [rbx+450h]
0000000180369482  F3 0F 11 BB C0 03 00 00         movss   dword ptr [rbx+3C0h], xmm7
000000018036948A  F3 0F 11 93 A0 03 00 00         movss   dword ptr [rbx+3A0h], xmm2
0000000180369492  F3 44 0F 11 83 E0 03 00 00      movss   dword ptr [rbx+3E0h], xmm8
000000018036949B  F3 44 0F 11 8B 00 04 00 00      movss   dword ptr [rbx+400h], xmm9
00000001803694A4  F3 0F 11 8B 60 04 00 00         movss   dword ptr [rbx+460h], xmm1
00000001803694AC  83 F8 E0                        cmp     eax, 0FFFFFFE0h
00000001803694AF  7D 2F                           jge     short loc_1803694E0
00000001803694B1  B8 E0 FF FF FF                  mov     eax, 0FFFFFFE0h
00000001803694B6  F7 D0                           not     eax
00000001803694B8  48 98                           cdqe
00000001803694BA  F3 0F 59 94 81 C0 AC 98 00      mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
00000001803694C3  EB 47                           jmp     short loc_18036950C
00000001803694C5  F3 0F 58 8B 40 03 00 00         addss   xmm1, dword ptr [rbx+340h]
00000001803694CD  41 0F 2F CD                     comiss  xmm1, xmm13
00000001803694D1  0F 82 09 FF FF FF               jb      loc_1803693E0
00000001803694D7  41 0F 28 C4                     movaps  xmm0, xmm12
00000001803694DB  E9 03 FF FF FF                  jmp     loc_1803693E3
00000001803694E0  83 F8 20                        cmp     eax, 20h ; ' '
00000001803694E3  7E 07                           jle     short loc_1803694EC
00000001803694E5  B8 20 00 00 00                  mov     eax, 20h ; ' '
00000001803694EA  EB 15                           jmp     short loc_180369501
00000001803694EC  85 C0                           test    eax, eax
00000001803694EE  79 0F                           jns     short loc_1803694FF
00000001803694F0  F7 D0                           not     eax
00000001803694F2  48 98                           cdqe
00000001803694F4  F3 0F 59 94 81 C0 AC 98 00      mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
00000001803694FD  EB 0D                           jmp     short loc_18036950C
00000001803694FF  7E 0B                           jle     short loc_18036950C
0000000180369501  48 98                           cdqe
0000000180369503  F3 0F 59 94 81 3C AD 98 00      mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
000000018036950C  0F 57 05 AD C2 77 00            xorps   xmm0, cs:xmmword_180AE57C0
0000000180369513  F3 0F 2C C0                     cvttss2si eax, xmm0
0000000180369517  83 F8 E0                        cmp     eax, 0FFFFFFE0h
000000018036951A  7D 14                           jge     short loc_180369530
000000018036951C  B8 E0 FF FF FF                  mov     eax, 0FFFFFFE0h
0000000180369521  F7 D0                           not     eax
0000000180369523  48 98                           cdqe
0000000180369525  F3 0F 59 94 81 C0 AC 98 00      mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018036952E  EB 2C                           jmp     short loc_18036955C
0000000180369530  83 F8 20                        cmp     eax, 20h ; ' '
0000000180369533  7E 07                           jle     short loc_18036953C
0000000180369535  B8 20 00 00 00                  mov     eax, 20h ; ' '
000000018036953A  EB 15                           jmp     short loc_180369551
000000018036953C  85 C0                           test    eax, eax
000000018036953E  79 0F                           jns     short loc_18036954F
0000000180369540  F7 D0                           not     eax
0000000180369542  48 98                           cdqe
0000000180369544  F3 0F 59 94 81 C0 AC 98 00      mulss   xmm2, ds:rva dword_18098ACC0[rcx+rax*4]
000000018036954D  EB 0D                           jmp     short loc_18036955C
000000018036954F  7E 0B                           jle     short loc_18036955C
0000000180369551  48 98                           cdqe
0000000180369553  F3 0F 59 94 81 3C AD 98 00      mulss   xmm2, ds:rva dword_18098AD3C[rcx+rax*4]
000000018036955C  F3 0F 10 83 10 04 00 00         movss   xmm0, dword ptr [rbx+410h]
0000000180369564  F3 0F 5C D1                     subss   xmm2, xmm1
0000000180369568  F3 0F 59 93 80 04 00 00         mulss   xmm2, dword ptr [rbx+480h]
0000000180369570  F3 0F 58 D1                     addss   xmm2, xmm1
0000000180369574  F3 0F 10 8B 40 04 00 00         movss   xmm1, dword ptr [rbx+440h]
000000018036957C  F3 0F 11 93 50 04 00 00         movss   dword ptr [rbx+450h], xmm2
0000000180369584  F3 0F 59 D0                     mulss   xmm2, xmm0
0000000180369588  F3 0F 59 C1                     mulss   xmm0, xmm1
000000018036958C  F3 0F 5C D0                     subss   xmm2, xmm0
0000000180369590  F3 0F 58 D1                     addss   xmm2, xmm1
0000000180369594  41 0F 2F D6                     comiss  xmm2, xmm14
0000000180369598  76 05                           jbe     short loc_18036959F
000000018036959A  0F 5A C2                        cvtps2pd xmm0, xmm2
000000018036959D  EB 03                           jmp     short loc_1803695A2
000000018036959F  0F 57 C0                        xorps   xmm0, xmm0
00000001803695A2  66 0F 5A C8                     cvtpd2ps xmm1, xmm0
00000001803695A6  41 0F 2F CD                     comiss  xmm1, xmm13
00000001803695AA  72 06                           jb      short loc_1803695B2
00000001803695AC  41 0F 28 C4                     movaps  xmm0, xmm12
00000001803695B0  EB 03                           jmp     short loc_1803695B5
00000001803695B2  0F 5A C1                        cvtps2pd xmm0, xmm1
00000001803695B5  F3 0F 10 B3 20 04 00 00         movss   xmm6, dword ptr [rbx+420h]
00000001803695BD  66 0F 5A C0                     cvtpd2ps xmm0, xmm0
00000001803695C1  F3 0F 59 83 B0 04 00 00         mulss   xmm0, dword ptr [rbx+4B0h]; X
00000001803695C9  E8 72 61 38 00                  call    expf
00000001803695CE  F3 0F 59 83 A0 04 00 00         mulss   xmm0, dword ptr [rbx+4A0h]
00000001803695D6  0F 28 CE                        movaps  xmm1, xmm6
00000001803695D9  8B 83 20 06 00 00               mov     eax, [rbx+620h]
00000001803695DF  F3 0F 59 8B 30 04 00 00         mulss   xmm1, dword ptr [rbx+430h]
00000001803695E7  89 83 30 06 00 00               mov     [rbx+630h], eax
00000001803695ED  F3 0F 58 83 C0 04 00 00         addss   xmm0, dword ptr [rbx+4C0h]
00000001803695F5  8B 83 40 06 00 00               mov     eax, [rbx+640h]
00000001803695FB  F3 0F 10 9B E0 05 00 00         movss   xmm3, dword ptr [rbx+5E0h]
0000000180369603  F3 0F 59 BB 70 07 00 00         mulss   xmm7, dword ptr [rbx+770h]
000000018036960B  89 83 50 06 00 00               mov     [rbx+650h], eax
0000000180369611  8B 83 60 06 00 00               mov     eax, [rbx+660h]
0000000180369617  F3 0F 10 93 D0 05 00 00         movss   xmm2, dword ptr [rbx+5D0h]
000000018036961F  F3 0F 10 A3 00 06 00 00         movss   xmm4, dword ptr [rbx+600h]
0000000180369627  F3 0F 59 F0                     mulss   xmm6, xmm0
000000018036962B  89 83 70 06 00 00               mov     [rbx+670h], eax
0000000180369631  8B 83 D0 49 01 00               mov     eax, [rbx+149D0h]
0000000180369637  F3 0F 11 9B F0 05 00 00         movss   dword ptr [rbx+5F0h], xmm3
000000018036963F  F3 0F 5C CE                     subss   xmm1, xmm6
0000000180369643  F3 0F 11 93 E0 05 00 00         movss   dword ptr [rbx+5E0h], xmm2
000000018036964B  F3 0F 11 A3 10 06 00 00         movss   dword ptr [rbx+610h], xmm4
0000000180369653  F3 44 0F 11 83 A0 05 00 00      movss   dword ptr [rbx+5A0h], xmm8
000000018036965C  F3 44 0F 11 8B B0 05 00 00      movss   dword ptr [rbx+5B0h], xmm9
0000000180369665  89 83 90 05 00 00               mov     [rbx+590h], eax
000000018036966B  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036966F  F3 0F 10 83 40 07 00 00         movss   xmm0, dword ptr [rbx+740h]
0000000180369677  F3 0F 58 F8                     addss   xmm7, xmm0
000000018036967B  F3 0F 11 83 30 07 00 00         movss   dword ptr [rbx+730h], xmm0
0000000180369683  F3 0F 11 8B 70 04 00 00         movss   dword ptr [rbx+470h], xmm1
000000018036968B  41 0F 2F FF                     comiss  xmm7, xmm15
000000018036968F  73 06                           jnb     short loc_180369697
0000000180369691  41 0F 28 FF                     movaps  xmm7, xmm15
0000000180369695  EB 05                           jmp     short loc_18036969C
0000000180369697  F3 41 0F 5D FD                  minss   xmm7, xmm13
000000018036969C  F3 0F 59 0D 1C 17 62 00         mulss   xmm1, cs:dword_18098ADC0
00000001803696A4  41 0F 28 C5                     movaps  xmm0, xmm13
00000001803696A8  F3 0F 10 B3 50 08 00 00         movss   xmm6, dword ptr [rbx+850h]
00000001803696B0  F3 0F 5C C3                     subss   xmm0, xmm3
00000001803696B4  F3 0F 11 BB D0 05 00 00         movss   dword ptr [rbx+5D0h], xmm7
00000001803696BC  F3 0F 5D F1                     minss   xmm6, xmm1
00000001803696C0  F3 0F 59 83 80 07 00 00         mulss   xmm0, dword ptr [rbx+780h]
00000001803696C8  F3 0F 58 C3                     addss   xmm0, xmm3
00000001803696CC  41 0F 2F C7                     comiss  xmm0, xmm15
00000001803696D0  73 06                           jnb     short loc_1803696D8
00000001803696D2  41 0F 28 C7                     movaps  xmm0, xmm15
00000001803696D6  EB 05                           jmp     short loc_1803696DD
00000001803696D8  F3 41 0F 5D C5                  minss   xmm0, xmm13
00000001803696DD  F3 0F 59 B3 60 08 00 00         mulss   xmm6, dword ptr [rbx+860h]
00000001803696E5  F3 0F 5C D7                     subss   xmm2, xmm7
00000001803696E9  F3 0F 11 B3 80 06 00 00         movss   dword ptr [rbx+680h], xmm6
00000001803696F1  F3 0F 58 F4                     addss   xmm6, xmm4
00000001803696F5  41 0F 2F D6                     comiss  xmm2, xmm14
00000001803696F9  73 03                           jnb     short loc_1803696FE
00000001803696FB  0F 57 C0                        xorps   xmm0, xmm0
00000001803696FE  F3 0F 10 8B 50 07 00 00         movss   xmm1, dword ptr [rbx+750h]
0000000180369706  F3 44 0F 10 9B 90 05 00 00      movss   xmm11, dword ptr [rbx+590h]
000000018036970F  F3 0F 11 83 E0 05 00 00         movss   dword ptr [rbx+5E0h], xmm0
0000000180369717  F3 0F 58 83 E0 08 00 00         addss   xmm0, dword ptr [rbx+8E0h]
000000018036971F  72 04                           jb      short loc_180369725
0000000180369721  41 0F 28 CD                     movaps  xmm1, xmm13
0000000180369725  F3 0F 59 83 D0 08 00 00         mulss   xmm0, dword ptr [rbx+8D0h]
000000018036972D  41 0F 28 FB                     movaps  xmm7, xmm11
0000000180369731  F3 0F 10 93 30 06 00 00         movss   xmm2, dword ptr [rbx+630h]
0000000180369739  F3 0F 59 F1                     mulss   xmm6, xmm1
000000018036973D  F3 0F 5C FA                     subss   xmm7, xmm2
0000000180369741  41 0F 2F C6                     comiss  xmm0, xmm14
0000000180369745  F3 0F 59 B3 60 07 00 00         mulss   xmm6, dword ptr [rbx+760h]
000000018036974D  76 05                           jbe     short loc_180369754
000000018036974F  0F 5A C8                        cvtps2pd xmm1, xmm0
0000000180369752  EB 03                           jmp     short loc_180369757
0000000180369754  0F 57 C9                        xorps   xmm1, xmm1
0000000180369757  41 0F 2F F5                     comiss  xmm6, xmm13
000000018036975B  F3 0F 59 BB A0 09 00 00         mulss   xmm7, dword ptr [rbx+9A0h]
0000000180369763  F3 44 0F 10 0D 7C BA 77 00      movss   xmm9, cs:flt_180AE51E8
000000018036976C  66 0F 5A C1                     cvtpd2ps xmm0, xmm1
0000000180369770  F3 0F 58 FA                     addss   xmm7, xmm2
0000000180369774  F3 0F 11 BB 20 06 00 00         movss   dword ptr [rbx+620h], xmm7
000000018036977C  F3 0F 11 83 C0 05 00 00         movss   dword ptr [rbx+5C0h], xmm0
0000000180369784  41 0F 28 C3                     movaps  xmm0, xmm11
0000000180369788  F3 0F 59 BB 90 09 00 00         mulss   xmm7, dword ptr [rbx+990h]
0000000180369790  F3 0F 10 8B 10 08 00 00         movss   xmm1, dword ptr [rbx+810h]
0000000180369798  F3 0F 59 C1                     mulss   xmm0, xmm1
000000018036979C  F3 0F 59 F9                     mulss   xmm7, xmm1
00000001803697A0  F3 0F 5C F8                     subss   xmm7, xmm0
00000001803697A4  F3 0F 10 83 10 06 00 00         movss   xmm0, dword ptr [rbx+610h]
00000001803697AC  F3 0F 11 84 24 E0 00 00 00      movss   [rsp+0C8h+arg_10], xmm0
00000001803697B5  F3 41 0F 58 FB                  addss   xmm7, xmm11
00000001803697BA  76 1B                           jbe     short loc_1803697D7
00000001803697BC  F3 41 0F 58 F5                  addss   xmm6, xmm13
00000001803697C1  41 0F 28 C9                     movaps  xmm1, xmm9; Y
00000001803697C5  0F 28 C6                        movaps  xmm0, xmm6; X
00000001803697C8  E8 0B 5D 38 00                  call    fmodf
00000001803697CD  0F 28 F0                        movaps  xmm6, xmm0
00000001803697D0  F3 41 0F 5C F5                  subss   xmm6, xmm13
00000001803697D5  EB 1F                           jmp     short loc_1803697F6
00000001803697D7  41 0F 2F F7                     comiss  xmm6, xmm15
00000001803697DB  73 19                           jnb     short loc_1803697F6
00000001803697DD  F3 41 0F 5C F5                  subss   xmm6, xmm13
00000001803697E2  41 0F 28 C9                     movaps  xmm1, xmm9; Y
00000001803697E6  0F 28 C6                        movaps  xmm0, xmm6; X
00000001803697E9  E8 EA 5C 38 00                  call    fmodf
00000001803697EE  0F 28 F0                        movaps  xmm6, xmm0
00000001803697F1  F3 41 0F 58 F5                  addss   xmm6, xmm13
00000001803697F6  F3 0F 10 8C 24 E0 00 00 00      movss   xmm1, [rsp+0C8h+arg_10]
00000001803697FF  0F 28 C6                        movaps  xmm0, xmm6
0000000180369802  41 0F 2F CE                     comiss  xmm1, xmm14
0000000180369806  F3 44 0F 10 83 50 06 00 00      movss   xmm8, dword ptr [rbx+650h]
000000018036980F  F3 0F 11 B3 00 06 00 00         movss   dword ptr [rbx+600h], xmm6
0000000180369817  F3 0F 59 BB 80 09 00 00         mulss   xmm7, dword ptr [rbx+980h]
000000018036981F  F3 0F 58 83 F0 08 00 00         addss   xmm0, dword ptr [rbx+8F0h]
0000000180369827  F3 0F 11 BB 80 05 00 00         movss   dword ptr [rbx+580h], xmm7
000000018036982F  73 0A                           jnb     short loc_18036983B
0000000180369831  41 0F 2F F6                     comiss  xmm6, xmm14
0000000180369835  76 04                           jbe     short loc_18036983B
0000000180369837  45 0F 28 C3                     movaps  xmm8, xmm11
000000018036983B  41 0F 2F C5                     comiss  xmm0, xmm13
000000018036983F  76 15                           jbe     short loc_180369856
0000000180369841  F3 41 0F 58 C5                  addss   xmm0, xmm13; X
0000000180369846  41 0F 28 C9                     movaps  xmm1, xmm9; Y
000000018036984A  E8 89 5C 38 00                  call    fmodf
000000018036984F  F3 41 0F 5C C5                  subss   xmm0, xmm13
0000000180369854  EB 19                           jmp     short loc_18036986F
0000000180369856  41 0F 2F C7                     comiss  xmm0, xmm15
000000018036985A  73 13                           jnb     short loc_18036986F
000000018036985C  F3 41 0F 5C C5                  subss   xmm0, xmm13; X
0000000180369861  41 0F 28 C9                     movaps  xmm1, xmm9; Y
0000000180369865  E8 6E 5C 38 00                  call    fmodf
000000018036986A  F3 41 0F 58 C5                  addss   xmm0, xmm13
000000018036986F  F3 44 0F 10 1D 48 BF 77 00      movss   xmm11, dword ptr cs:xmmword_180AE57C0
0000000180369878  F3 44 0F 11 83 40 06 00 00      movss   dword ptr [rbx+640h], xmm8
0000000180369881  F3 0F 59 83 30 09 00 00         mulss   xmm0, dword ptr [rbx+930h]
0000000180369889  F3 44 0F 59 83 70 09 00 00      mulss   xmm8, dword ptr [rbx+970h]
0000000180369892  F3 0F 58 83 B0 09 00 00         addss   xmm0, dword ptr [rbx+9B0h]
000000018036989A  F3 0F 11 83 90 06 00 00         movss   dword ptr [rbx+690h], xmm0
00000001803698A2  41 0F 57 C3                     xorps   xmm0, xmm11
00000001803698A6  F3 44 0F 11 83 E0 06 00 00      movss   dword ptr [rbx+6E0h], xmm8
00000001803698AF  44 0F 28 C6                     movaps  xmm8, xmm6
00000001803698B3  F3 44 0F 58 83 10 09 00 00      addss   xmm8, dword ptr [rbx+910h]
00000001803698BC  F3 0F 11 83 A0 06 00 00         movss   dword ptr [rbx+6A0h], xmm0
00000001803698C4  45 0F 2F C5                     comiss  xmm8, xmm13
00000001803698C8  76 1D                           jbe     short loc_1803698E7
00000001803698CA  F3 45 0F 58 C5                  addss   xmm8, xmm13
00000001803698CF  41 0F 28 C9                     movaps  xmm1, xmm9; Y
00000001803698D3  41 0F 28 C0                     movaps  xmm0, xmm8; X
00000001803698D7  E8 FC 5B 38 00                  call    fmodf
00000001803698DC  44 0F 28 C0                     movaps  xmm8, xmm0
00000001803698E0  F3 45 0F 5C C5                  subss   xmm8, xmm13
00000001803698E5  EB 21                           jmp     short loc_180369908
00000001803698E7  45 0F 2F C7                     comiss  xmm8, xmm15
00000001803698EB  73 1B                           jnb     short loc_180369908
00000001803698ED  F3 45 0F 5C C5                  subss   xmm8, xmm13
00000001803698F2  41 0F 28 C9                     movaps  xmm1, xmm9; Y
00000001803698F6  41 0F 28 C0                     movaps  xmm0, xmm8; X
00000001803698FA  E8 D9 5B 38 00                  call    fmodf
00000001803698FF  44 0F 28 C0                     movaps  xmm8, xmm0
0000000180369903  F3 45 0F 58 C5                  addss   xmm8, xmm13
0000000180369908  0F 28 FE                        movaps  xmm7, xmm6
000000018036990B  F3 0F 58 BB 00 09 00 00         addss   xmm7, dword ptr [rbx+900h]
0000000180369913  41 0F 2F FD                     comiss  xmm7, xmm13
0000000180369917  76 1B                           jbe     short loc_180369934
0000000180369919  F3 41 0F 58 FD                  addss   xmm7, xmm13
000000018036991E  41 0F 28 C9                     movaps  xmm1, xmm9; Y
0000000180369922  0F 28 C7                        movaps  xmm0, xmm7; X
0000000180369925  E8 AE 5B 38 00                  call    fmodf
000000018036992A  0F 28 F8                        movaps  xmm7, xmm0
000000018036992D  F3 41 0F 5C FD                  subss   xmm7, xmm13
0000000180369932  EB 1F                           jmp     short loc_180369953
0000000180369934  41 0F 2F FF                     comiss  xmm7, xmm15
0000000180369938  73 19                           jnb     short loc_180369953
000000018036993A  F3 41 0F 5C FD                  subss   xmm7, xmm13
000000018036993F  41 0F 28 C9                     movaps  xmm1, xmm9; Y
0000000180369943  0F 28 C7                        movaps  xmm0, xmm7; X
0000000180369946  E8 8D 5B 38 00                  call    fmodf
000000018036994B  0F 28 F8                        movaps  xmm7, xmm0
000000018036994E  F3 41 0F 58 FD                  addss   xmm7, xmm13
0000000180369953  41 0F 28 C0                     movaps  xmm0, xmm8
0000000180369957  E8 64 F6 FF FF                  call    sub_180368FC0
000000018036995C  F3 0F 58 BB C0 09 00 00         addss   xmm7, dword ptr [rbx+9C0h]
0000000180369964  F3 0F 59 83 50 09 00 00         mulss   xmm0, dword ptr [rbx+950h]
000000018036996C  41 0F 2F FE                     comiss  xmm7, xmm14
0000000180369970  73 06                           jnb     short loc_180369978
0000000180369972  41 0F 28 FF                     movaps  xmm7, xmm15
0000000180369976  EB 06                           jmp     short loc_18036997E
0000000180369978  76 04                           jbe     short loc_18036997E
000000018036997A  41 0F 28 FD                     movaps  xmm7, xmm13
000000018036997E  F3 0F 58 B3 20 09 00 00         addss   xmm6, dword ptr [rbx+920h]
0000000180369986  F3 0F 11 83 C0 06 00 00         movss   dword ptr [rbx+6C0h], xmm0
000000018036998E  F3 0F 11 BB 20 07 00 00         movss   dword ptr [rbx+720h], xmm7
0000000180369996  F3 0F 59 BB 40 09 00 00         mulss   xmm7, dword ptr [rbx+940h]
000000018036999E  41 0F 2F F5                     comiss  xmm6, xmm13
00000001803699A2  F3 0F 58 BB D0 09 00 00         addss   xmm7, dword ptr [rbx+9D0h]
00000001803699AA  76 1B                           jbe     short loc_1803699C7
00000001803699AC  F3 41 0F 58 F5                  addss   xmm6, xmm13
00000001803699B1  41 0F 28 C9                     movaps  xmm1, xmm9; Y
00000001803699B5  0F 28 C6                        movaps  xmm0, xmm6; X
00000001803699B8  E8 1B 5B 38 00                  call    fmodf
00000001803699BD  0F 28 F0                        movaps  xmm6, xmm0
00000001803699C0  F3 41 0F 5C F5                  subss   xmm6, xmm13
00000001803699C5  EB 1F                           jmp     short loc_1803699E6
00000001803699C7  41 0F 2F F7                     comiss  xmm6, xmm15
00000001803699CB  73 19                           jnb     short loc_1803699E6
00000001803699CD  F3 41 0F 5C F5                  subss   xmm6, xmm13
00000001803699D2  41 0F 28 C9                     movaps  xmm1, xmm9; Y
00000001803699D6  0F 28 C6                        movaps  xmm0, xmm6; X
00000001803699D9  E8 FA 5A 38 00                  call    fmodf
00000001803699DE  0F 28 F0                        movaps  xmm6, xmm0
00000001803699E1  F3 41 0F 58 F5                  addss   xmm6, xmm13
00000001803699E6  0F 54 35 A3 BD 77 00            andps   xmm6, cs:xmmword_180AE5790
00000001803699ED  F3 0F 11 BB B0 06 00 00         movss   dword ptr [rbx+6B0h], xmm7
00000001803699F5  0F 28 E6                        movaps  xmm4, xmm6
00000001803699F8  F3 0F 10 9B F0 07 00 00         movss   xmm3, dword ptr [rbx+7F0h]
0000000180369A00  0F 28 D6                        movaps  xmm2, xmm6
0000000180369A03  F3 0F 59 93 80 08 00 00         mulss   xmm2, dword ptr [rbx+880h]
0000000180369A0B  F3 0F 59 9B E0 06 00 00         mulss   xmm3, dword ptr [rbx+6E0h]
0000000180369A13  F3 0F 58 93 70 08 00 00         addss   xmm2, dword ptr [rbx+870h]
0000000180369A1B  F3 0F 10 8B E0 07 00 00         movss   xmm1, dword ptr [rbx+7E0h]
0000000180369A23  F3 0F 59 8B A0 06 00 00         mulss   xmm1, dword ptr [rbx+6A0h]
0000000180369A2B  F3 0F 59 E6                     mulss   xmm4, xmm6
0000000180369A2F  0F 28 C4                        movaps  xmm0, xmm4
0000000180369A32  F3 0F 59 E6                     mulss   xmm4, xmm6
0000000180369A36  F3 0F 59 83 90 08 00 00         mulss   xmm0, dword ptr [rbx+890h]
0000000180369A3E  F3 0F 59 F4                     mulss   xmm6, xmm4
0000000180369A42  F3 0F 59 A3 A0 08 00 00         mulss   xmm4, dword ptr [rbx+8A0h]
0000000180369A4A  F3 0F 58 D0                     addss   xmm2, xmm0
0000000180369A4E  F3 0F 59 B3 B0 08 00 00         mulss   xmm6, dword ptr [rbx+8B0h]
0000000180369A56  F3 0F 10 83 D0 07 00 00         movss   xmm0, dword ptr [rbx+7D0h]
0000000180369A5E  F3 0F 59 83 90 06 00 00         mulss   xmm0, dword ptr [rbx+690h]
0000000180369A66  F3 0F 58 E2                     addss   xmm4, xmm2
0000000180369A6A  F3 0F 58 D8                     addss   xmm3, xmm0
0000000180369A6E  F3 0F 58 F4                     addss   xmm6, xmm4
0000000180369A72  F3 0F 10 A3 B0 07 00 00         movss   xmm4, dword ptr [rbx+7B0h]
0000000180369A7A  F3 0F 58 D9                     addss   xmm3, xmm1
0000000180369A7E  F3 0F 58 B3 C0 08 00 00         addss   xmm6, dword ptr [rbx+8C0h]
0000000180369A86  F3 0F 59 B3 60 09 00 00         mulss   xmm6, dword ptr [rbx+960h]
0000000180369A8E  F3 0F 11 B3 D0 06 00 00         movss   dword ptr [rbx+6D0h], xmm6
0000000180369A96  F3 0F 59 A3 C0 06 00 00         mulss   xmm4, dword ptr [rbx+6C0h]
0000000180369A9E  F3 0F 10 8B 90 07 00 00         movss   xmm1, dword ptr [rbx+790h]
0000000180369AA6  F3 0F 10 83 C0 07 00 00         movss   xmm0, dword ptr [rbx+7C0h]
0000000180369AAE  F3 0F 59 83 B0 06 00 00         mulss   xmm0, dword ptr [rbx+6B0h]
0000000180369AB6  F3 0F 58 E3                     addss   xmm4, xmm3
0000000180369ABA  F3 0F 10 93 20 08 00 00         movss   xmm2, dword ptr [rbx+820h]
0000000180369AC2  0F 28 D9                        movaps  xmm3, xmm1
0000000180369AC5  F3 0F 59 9B C0 05 00 00         mulss   xmm3, dword ptr [rbx+5C0h]
0000000180369ACD  F3 0F 59 B3 A0 07 00 00         mulss   xmm6, dword ptr [rbx+7A0h]
0000000180369AD5  F3 0F 58 E0                     addss   xmm4, xmm0
0000000180369AD9  F3 0F 10 83 00 08 00 00         movss   xmm0, dword ptr [rbx+800h]
0000000180369AE1  F3 0F 5C D9                     subss   xmm3, xmm1
0000000180369AE5  F3 0F 59 83 80 05 00 00         mulss   xmm0, dword ptr [rbx+580h]
0000000180369AED  F3 0F 58 E6                     addss   xmm4, xmm6
0000000180369AF1  F3 41 0F 58 DD                  addss   xmm3, xmm13
0000000180369AF6  F3 0F 58 E0                     addss   xmm4, xmm0
0000000180369AFA  F3 0F 11 9B F0 06 00 00         movss   dword ptr [rbx+6F0h], xmm3
0000000180369B02  F3 0F 59 D3                     mulss   xmm2, xmm3
0000000180369B06  F3 0F 11 A3 10 07 00 00         movss   dword ptr [rbx+710h], xmm4
0000000180369B0E  F3 0F 10 8B 30 08 00 00         movss   xmm1, dword ptr [rbx+830h]
0000000180369B16  F3 0F 59 8B A0 05 00 00         mulss   xmm1, dword ptr [rbx+5A0h]
0000000180369B1E  F3 0F 10 83 40 08 00 00         movss   xmm0, dword ptr [rbx+840h]
0000000180369B26  F3 0F 59 83 B0 05 00 00         mulss   xmm0, dword ptr [rbx+5B0h]
0000000180369B2E  F3 0F 59 D4                     mulss   xmm2, xmm4
0000000180369B32  F3 0F 58 C8                     addss   xmm1, xmm0
0000000180369B36  F3 0F 58 CA                     addss   xmm1, xmm2
0000000180369B3A  F3 0F 11 8B 00 07 00 00         movss   dword ptr [rbx+700h], xmm1
0000000180369B42  F3 0F 10 83 10 07 00 00         movss   xmm0, dword ptr [rbx+710h]
0000000180369B4A  8B 83 20 07 00 00               mov     eax, [rbx+720h]
0000000180369B50  89 83 E0 09 00 00               mov     [rbx+9E0h], eax
0000000180369B56  F3 0F 11 83 F0 09 00 00         movss   dword ptr [rbx+9F0h], xmm0
0000000180369B5E  44 0F 2F B3 20 07 00 00         comiss  xmm14, dword ptr [rbx+720h]
0000000180369B66  F3 0F 10 8B 30 02 00 00         movss   xmm1, dword ptr [rbx+230h]
0000000180369B6E  F3 0F 10 93 00 0A 00 00         movss   xmm2, dword ptr [rbx+0A00h]
0000000180369B76  73 06                           jnb     short loc_180369B7E
0000000180369B78  41 0F 28 C5                     movaps  xmm0, xmm13
0000000180369B7C  EB 03                           jmp     short loc_180369B81
0000000180369B7E  0F 57 C0                        xorps   xmm0, xmm0
0000000180369B81  41 0F 2E D6                     ucomiss xmm2, xmm14
0000000180369B85  75 04                           jnz     short loc_180369B8B
0000000180369B87  41 0F 28 C5                     movaps  xmm0, xmm13
0000000180369B8B  F3 0F 59 C8                     mulss   xmm1, xmm0
0000000180369B8F  F3 0F 11 8B 10 0A 00 00         movss   dword ptr [rbx+0A10h], xmm1
0000000180369B97  8B 83 20 0A 00 00               mov     eax, [rbx+0A20h]
0000000180369B9D  89 83 30 0A 00 00               mov     [rbx+0A30h], eax
0000000180369BA3  8B 83 50 0A 00 00               mov     eax, [rbx+0A50h]
0000000180369BA9  89 83 60 0A 00 00               mov     [rbx+0A60h], eax
0000000180369BAF  8B 83 40 0A 00 00               mov     eax, [rbx+0A40h]
0000000180369BB5  89 83 50 0A 00 00               mov     [rbx+0A50h], eax
0000000180369BBB  8B 83 70 0A 00 00               mov     eax, [rbx+0A70h]
0000000180369BC1  89 83 80 0A 00 00               mov     [rbx+0A80h], eax
0000000180369BC7  8B 83 A0 0A 00 00               mov     eax, [rbx+0AA0h]
0000000180369BCD  89 83 B0 0A 00 00               mov     [rbx+0AB0h], eax
0000000180369BD3  F3 0F 10 83 50 0B 00 00         movss   xmm0, dword ptr [rbx+0B50h]
0000000180369BDB  F3 0F 58 8B 30 0B 00 00         addss   xmm1, dword ptr [rbx+0B30h]
0000000180369BE3  F3 0F 59 83 60 0A 00 00         mulss   xmm0, dword ptr [rbx+0A60h]
0000000180369BEB  41 0F 2F CE                     comiss  xmm1, xmm14
0000000180369BEF  F3 0F 58 83 30 0A 00 00         addss   xmm0, dword ptr [rbx+0A30h]
0000000180369BF7  73 06                           jnb     short loc_180369BFF
0000000180369BF9  45 0F 28 C5                     movaps  xmm8, xmm13
0000000180369BFD  EB 04                           jmp     short loc_180369C03
0000000180369BFF  45 0F 57 C0                     xorps   xmm8, xmm8
0000000180369C03  41 0F 28 ED                     movaps  xmm5, xmm13
0000000180369C07  F3 41 0F 5C E8                  subss   xmm5, xmm8
0000000180369C0C  0F 28 FD                        movaps  xmm7, xmm5
0000000180369C0F  F3 0F 59 F8                     mulss   xmm7, xmm0
0000000180369C13  F3 0F 11 BB 40 0A 00 00         movss   dword ptr [rbx+0A40h], xmm7
0000000180369C1B  0F 28 E7                        movaps  xmm4, xmm7
0000000180369C1E  F3 0F 10 9B 20 0B 00 00         movss   xmm3, dword ptr [rbx+0B20h]
0000000180369C26  F3 0F 10 93 70 0B 00 00         movss   xmm2, dword ptr [rbx+0B70h]
0000000180369C2E  0F 28 CB                        movaps  xmm1, xmm3
0000000180369C31  F3 0F 59 8B 90 0B 00 00         mulss   xmm1, dword ptr [rbx+0B90h]
0000000180369C39  0F 28 C2                        movaps  xmm0, xmm2
0000000180369C3C  F3 0F 58 A3 40 0B 00 00         addss   xmm4, dword ptr [rbx+0B40h]
0000000180369C44  F3 0F 5C BB 50 0A 00 00         subss   xmm7, dword ptr [rbx+0A50h]
0000000180369C4C  F3 0F 59 C3                     mulss   xmm0, xmm3
0000000180369C50  41 0F 2F E6                     comiss  xmm4, xmm14
0000000180369C54  F3 0F 5C C8                     subss   xmm1, xmm0
0000000180369C58  F3 0F 58 CA                     addss   xmm1, xmm2
0000000180369C5C  F3 0F 11 8B 90 0A 00 00         movss   dword ptr [rbx+0A90h], xmm1
0000000180369C64  72 06                           jb      short loc_180369C6C
0000000180369C66  41 0F 28 F5                     movaps  xmm6, xmm13
0000000180369C6A  EB 03                           jmp     short loc_180369C6F
0000000180369C6C  0F 57 F6                        xorps   xmm6, xmm6
0000000180369C6F  41 0F 2F FE                     comiss  xmm7, xmm14
0000000180369C73  F3 0F 10 83 F0 0A 00 00         movss   xmm0, dword ptr [rbx+0AF0h]
0000000180369C7B  73 03                           jnb     short loc_180369C80
0000000180369C7D  0F 28 F5                        movaps  xmm6, xmm5
0000000180369C80  F3 0F 59 83 70 0B 00 00         mulss   xmm0, dword ptr [rbx+0B70h]
0000000180369C88  0F 28 DD                        movaps  xmm3, xmm5
0000000180369C8B  F3 0F 10 93 E0 0A 00 00         movss   xmm2, dword ptr [rbx+0AE0h]
0000000180369C93  F3 44 0F 10 0D C0 B2 77 00      movss   xmm9, cs:dword_180AE4F5C
0000000180369C9C  F3 0F 59 D8                     mulss   xmm3, xmm0
0000000180369CA0  F3 0F 11 B3 50 0A 00 00         movss   dword ptr [rbx+0A50h], xmm6
0000000180369CA8  F3 0F 10 8B 80 0B 00 00         movss   xmm1, dword ptr [rbx+0B80h]
0000000180369CB0  F3 0F 10 BB 00 0B 00 00         movss   xmm7, dword ptr [rbx+0B00h]
0000000180369CB8  0F 28 C1                        movaps  xmm0, xmm1
0000000180369CBB  F3 0F 10 A3 80 0A 00 00         movss   xmm4, dword ptr [rbx+0A80h]
0000000180369CC3  F3 0F 59 C5                     mulss   xmm0, xmm5
0000000180369CC7  F3 41 0F 59 F9                  mulss   xmm7, xmm9
0000000180369CCC  F3 0F 5C D8                     subss   xmm3, xmm0
0000000180369CD0  F3 41 0F 59 D1                  mulss   xmm2, xmm9
0000000180369CD5  41 0F 28 C5                     movaps  xmm0, xmm13
0000000180369CD9  F3 0F 59 FE                     mulss   xmm7, xmm6
0000000180369CDD  F3 0F 5C C6                     subss   xmm0, xmm6
0000000180369CE1  F3 0F 58 D9                     addss   xmm3, xmm1
0000000180369CE5  F3 0F 59 E8                     mulss   xmm5, xmm0
0000000180369CE9  0F 28 CB                        movaps  xmm1, xmm3
0000000180369CEC  F3 0F 5C CC                     subss   xmm1, xmm4
0000000180369CF0  F3 0F 59 D5                     mulss   xmm2, xmm5
0000000180369CF4  41 0F 2F CE                     comiss  xmm1, xmm14
0000000180369CF8  F3 0F 58 FA                     addss   xmm7, xmm2
0000000180369CFC  76 0B                           jbe     short loc_180369D09
0000000180369CFE  0F 28 DC                        movaps  xmm3, xmm4
0000000180369D01  F3 0F 58 9B 90 0A 00 00         addss   xmm3, dword ptr [rbx+0A90h]
0000000180369D09  F3 0F 10 83 70 0B 00 00         movss   xmm0, dword ptr [rbx+0B70h]
0000000180369D11  F3 0F 10 A3 30 0A 00 00         movss   xmm4, dword ptr [rbx+0A30h]
0000000180369D19  F3 0F 5D C3                     minss   xmm0, xmm3
0000000180369D1D  F3 0F 11 83 70 0A 00 00         movss   dword ptr [rbx+0A70h], xmm0
0000000180369D25  F3 0F 10 8B B0 0A 00 00         movss   xmm1, dword ptr [rbx+0AB0h]
0000000180369D2D  F3 0F 10 9B 10 0B 00 00         movss   xmm3, dword ptr [rbx+0B10h]
0000000180369D35  F3 0F 59 AB 60 0B 00 00         mulss   xmm5, dword ptr [rbx+0B60h]
0000000180369D3D  F3 41 0F 59 D9                  mulss   xmm3, xmm9
0000000180369D42  F3 0F 59 F0                     mulss   xmm6, xmm0
0000000180369D46  F3 0F 10 83 A0 0B 00 00         movss   xmm0, dword ptr [rbx+0BA0h]
0000000180369D4E  F3 41 0F 59 D8                  mulss   xmm3, xmm8
0000000180369D53  0F 28 D0                        movaps  xmm2, xmm0
0000000180369D56  F3 0F 59 C1                     mulss   xmm0, xmm1
0000000180369D5A  F3 0F 58 EE                     addss   xmm5, xmm6
0000000180369D5E  F3 0F 59 D7                     mulss   xmm2, xmm7
0000000180369D62  F3 0F 5C EC                     subss   xmm5, xmm4
0000000180369D66  F3 0F 5C D0                     subss   xmm2, xmm0
0000000180369D6A  F3 0F 58 D1                     addss   xmm2, xmm1
0000000180369D6E  F3 0F 11 93 A0 0A 00 00         movss   dword ptr [rbx+0AA0h], xmm2
0000000180369D76  F3 44 0F 59 C2                  mulss   xmm8, xmm2
0000000180369D7B  F3 41 0F 5C D8                  subss   xmm3, xmm8
0000000180369D80  F3 0F 58 DA                     addss   xmm3, xmm2
0000000180369D84  F3 0F 59 DD                     mulss   xmm3, xmm5
0000000180369D88  F3 0F 58 DC                     addss   xmm3, xmm4
0000000180369D8C  F3 0F 11 9B 20 0A 00 00         movss   dword ptr [rbx+0A20h], xmm3
0000000180369D94  F3 0F 59 9B B0 0B 00 00         mulss   xmm3, dword ptr [rbx+0BB0h]
0000000180369D9C  F3 0F 59 9B C0 0B 00 00         mulss   xmm3, dword ptr [rbx+0BC0h]
0000000180369DA4  0F 28 C3                        movaps  xmm0, xmm3
0000000180369DA7  F3 0F 59 83 D0 0B 00 00         mulss   xmm0, dword ptr [rbx+0BD0h]
0000000180369DAF  F3 0F 11 9B C0 0A 00 00         movss   dword ptr [rbx+0AC0h], xmm3
0000000180369DB7  F3 0F 11 83 D0 0A 00 00         movss   dword ptr [rbx+0AD0h], xmm0
0000000180369DBF  44 0F 2F B3 20 07 00 00         comiss  xmm14, dword ptr [rbx+720h]
0000000180369DC7  F3 0F 10 8B 30 02 00 00         movss   xmm1, dword ptr [rbx+230h]
0000000180369DCF  F3 0F 10 93 E0 0B 00 00         movss   xmm2, dword ptr [rbx+0BE0h]
0000000180369DD7  73 06                           jnb     short loc_180369DDF
0000000180369DD9  41 0F 28 C5                     movaps  xmm0, xmm13
0000000180369DDD  EB 03                           jmp     short loc_180369DE2
0000000180369DDF  0F 57 C0                        xorps   xmm0, xmm0
0000000180369DE2  41 0F 2E D6                     ucomiss xmm2, xmm14
0000000180369DE6  75 04                           jnz     short loc_180369DEC
0000000180369DE8  41 0F 28 C5                     movaps  xmm0, xmm13
0000000180369DEC  F3 0F 59 C8                     mulss   xmm1, xmm0
0000000180369DF0  F3 0F 11 8B F0 0B 00 00         movss   dword ptr [rbx+0BF0h], xmm1
0000000180369DF8  8B 83 00 0C 00 00               mov     eax, [rbx+0C00h]
0000000180369DFE  89 83 10 0C 00 00               mov     [rbx+0C10h], eax
0000000180369E04  8B 83 30 0C 00 00               mov     eax, [rbx+0C30h]
0000000180369E0A  89 83 40 0C 00 00               mov     [rbx+0C40h], eax
0000000180369E10  8B 83 20 0C 00 00               mov     eax, [rbx+0C20h]
0000000180369E16  89 83 30 0C 00 00               mov     [rbx+0C30h], eax
0000000180369E1C  8B 83 50 0C 00 00               mov     eax, [rbx+0C50h]
0000000180369E22  89 83 60 0C 00 00               mov     [rbx+0C60h], eax
0000000180369E28  8B 83 80 0C 00 00               mov     eax, [rbx+0C80h]
0000000180369E2E  89 83 90 0C 00 00               mov     [rbx+0C90h], eax
0000000180369E34  F3 0F 10 83 30 0D 00 00         movss   xmm0, dword ptr [rbx+0D30h]
0000000180369E3C  F3 0F 58 8B 10 0D 00 00         addss   xmm1, dword ptr [rbx+0D10h]
0000000180369E44  F3 0F 59 83 40 0C 00 00         mulss   xmm0, dword ptr [rbx+0C40h]
0000000180369E4C  41 0F 2F CE                     comiss  xmm1, xmm14
0000000180369E50  F3 0F 58 83 10 0C 00 00         addss   xmm0, dword ptr [rbx+0C10h]
0000000180369E58  73 06                           jnb     short loc_180369E60
0000000180369E5A  45 0F 28 C5                     movaps  xmm8, xmm13
0000000180369E5E  EB 04                           jmp     short loc_180369E64
0000000180369E60  45 0F 57 C0                     xorps   xmm8, xmm8
0000000180369E64  41 0F 28 ED                     movaps  xmm5, xmm13
0000000180369E68  F3 41 0F 5C E8                  subss   xmm5, xmm8
0000000180369E6D  0F 28 F5                        movaps  xmm6, xmm5
0000000180369E70  F3 0F 59 F0                     mulss   xmm6, xmm0
0000000180369E74  F3 0F 11 B3 20 0C 00 00         movss   dword ptr [rbx+0C20h], xmm6
0000000180369E7C  0F 28 E6                        movaps  xmm4, xmm6
0000000180369E7F  F3 0F 10 9B 00 0D 00 00         movss   xmm3, dword ptr [rbx+0D00h]
0000000180369E87  F3 0F 10 93 50 0D 00 00         movss   xmm2, dword ptr [rbx+0D50h]
0000000180369E8F  0F 28 CB                        movaps  xmm1, xmm3
0000000180369E92  F3 0F 59 8B 70 0D 00 00         mulss   xmm1, dword ptr [rbx+0D70h]
0000000180369E9A  0F 28 C2                        movaps  xmm0, xmm2
0000000180369E9D  F3 0F 58 A3 20 0D 00 00         addss   xmm4, dword ptr [rbx+0D20h]
0000000180369EA5  F3 0F 5C B3 30 0C 00 00         subss   xmm6, dword ptr [rbx+0C30h]
0000000180369EAD  F3 0F 59 C3                     mulss   xmm0, xmm3
0000000180369EB1  41 0F 2F E6                     comiss  xmm4, xmm14
0000000180369EB5  F3 0F 5C C8                     subss   xmm1, xmm0
0000000180369EB9  F3 0F 58 CA                     addss   xmm1, xmm2
0000000180369EBD  F3 0F 11 8B 70 0C 00 00         movss   dword ptr [rbx+0C70h], xmm1
0000000180369EC5  72 06                           jb      short loc_180369ECD
0000000180369EC7  41 0F 28 FD                     movaps  xmm7, xmm13
0000000180369ECB  EB 03                           jmp     short loc_180369ED0
0000000180369ECD  0F 57 FF                        xorps   xmm7, xmm7
0000000180369ED0  41 0F 2F F6                     comiss  xmm6, xmm14
0000000180369ED4  F3 0F 10 83 D0 0C 00 00         movss   xmm0, dword ptr [rbx+0CD0h]
0000000180369EDC  73 03                           jnb     short loc_180369EE1
0000000180369EDE  0F 28 FD                        movaps  xmm7, xmm5
0000000180369EE1  F3 0F 59 83 50 0D 00 00         mulss   xmm0, dword ptr [rbx+0D50h]
0000000180369EE9  0F 28 DD                        movaps  xmm3, xmm5
0000000180369EEC  F3 0F 10 93 C0 0C 00 00         movss   xmm2, dword ptr [rbx+0CC0h]
0000000180369EF4  F3 0F 11 BB 30 0C 00 00         movss   dword ptr [rbx+0C30h], xmm7
0000000180369EFC  F3 0F 10 8B 60 0D 00 00         movss   xmm1, dword ptr [rbx+0D60h]
0000000180369F04  F3 0F 10 B3 E0 0C 00 00         movss   xmm6, dword ptr [rbx+0CE0h]
0000000180369F0C  F3 0F 10 A3 60 0C 00 00         movss   xmm4, dword ptr [rbx+0C60h]
0000000180369F14  F3 0F 59 D8                     mulss   xmm3, xmm0
0000000180369F18  0F 28 C1                        movaps  xmm0, xmm1
0000000180369F1B  F3 0F 59 C5                     mulss   xmm0, xmm5
0000000180369F1F  F3 41 0F 59 F1                  mulss   xmm6, xmm9
0000000180369F24  F3 0F 5C D8                     subss   xmm3, xmm0
0000000180369F28  F3 41 0F 59 D1                  mulss   xmm2, xmm9
0000000180369F2D  41 0F 28 C5                     movaps  xmm0, xmm13
0000000180369F31  F3 0F 59 F7                     mulss   xmm6, xmm7
0000000180369F35  F3 0F 5C C7                     subss   xmm0, xmm7
0000000180369F39  F3 0F 58 D9                     addss   xmm3, xmm1
0000000180369F3D  F3 0F 59 E8                     mulss   xmm5, xmm0
0000000180369F41  0F 28 CB                        movaps  xmm1, xmm3
0000000180369F44  F3 0F 5C CC                     subss   xmm1, xmm4
0000000180369F48  F3 0F 59 D5                     mulss   xmm2, xmm5
0000000180369F4C  41 0F 2F CE                     comiss  xmm1, xmm14
0000000180369F50  F3 0F 58 F2                     addss   xmm6, xmm2
0000000180369F54  76 0B                           jbe     short loc_180369F61
0000000180369F56  0F 28 DC                        movaps  xmm3, xmm4
0000000180369F59  F3 0F 58 9B 70 0C 00 00         addss   xmm3, dword ptr [rbx+0C70h]
0000000180369F61  F3 0F 10 A3 10 0C 00 00         movss   xmm4, dword ptr [rbx+0C10h]
0000000180369F69  F3 0F 10 83 50 0D 00 00         movss   xmm0, dword ptr [rbx+0D50h]
0000000180369F71  F3 0F 5D C3                     minss   xmm0, xmm3
0000000180369F75  F3 0F 11 83 50 0C 00 00         movss   dword ptr [rbx+0C50h], xmm0
0000000180369F7D  F3 0F 59 AB 40 0D 00 00         mulss   xmm5, dword ptr [rbx+0D40h]
0000000180369F85  F3 0F 10 8B 90 0C 00 00         movss   xmm1, dword ptr [rbx+0C90h]
0000000180369F8D  F3 0F 10 9B F0 0C 00 00         movss   xmm3, dword ptr [rbx+0CF0h]
0000000180369F95  F3 0F 59 F8                     mulss   xmm7, xmm0
0000000180369F99  F3 0F 10 83 80 0D 00 00         movss   xmm0, dword ptr [rbx+0D80h]
0000000180369FA1  0F 28 D0                        movaps  xmm2, xmm0
0000000180369FA4  F3 41 0F 59 D9                  mulss   xmm3, xmm9
0000000180369FA9  F3 0F 59 C1                     mulss   xmm0, xmm1
0000000180369FAD  F3 0F 58 EF                     addss   xmm5, xmm7
0000000180369FB1  F3 41 0F 59 D8                  mulss   xmm3, xmm8
0000000180369FB6  F3 0F 59 D6                     mulss   xmm2, xmm6
0000000180369FBA  F3 0F 5C EC                     subss   xmm5, xmm4
0000000180369FBE  F3 0F 5C D0                     subss   xmm2, xmm0
0000000180369FC2  F3 0F 58 D1                     addss   xmm2, xmm1
0000000180369FC6  F3 0F 11 93 80 0C 00 00         movss   dword ptr [rbx+0C80h], xmm2
0000000180369FCE  F3 44 0F 59 C2                  mulss   xmm8, xmm2
0000000180369FD3  F3 41 0F 5C D8                  subss   xmm3, xmm8
0000000180369FD8  F3 0F 58 DA                     addss   xmm3, xmm2
0000000180369FDC  F3 0F 59 DD                     mulss   xmm3, xmm5
0000000180369FE0  F3 0F 58 DC                     addss   xmm3, xmm4
0000000180369FE4  F3 0F 11 9B 00 0C 00 00         movss   dword ptr [rbx+0C00h], xmm3
0000000180369FEC  F3 0F 59 9B 90 0D 00 00         mulss   xmm3, dword ptr [rbx+0D90h]
0000000180369FF4  F3 0F 59 9B A0 0D 00 00         mulss   xmm3, dword ptr [rbx+0DA0h]
0000000180369FFC  0F 28 C3                        movaps  xmm0, xmm3
0000000180369FFF  F3 0F 59 83 B0 0D 00 00         mulss   xmm0, dword ptr [rbx+0DB0h]
000000018036A007  F3 0F 11 9B A0 0C 00 00         movss   dword ptr [rbx+0CA0h], xmm3
000000018036A00F  F3 0F 11 83 B0 0C 00 00         movss   dword ptr [rbx+0CB0h], xmm0
000000018036A017  8B 83 C0 0D 00 00               mov     eax, [rbx+0DC0h]
000000018036A01D  89 83 D0 0D 00 00               mov     [rbx+0DD0h], eax
000000018036A023  8B 83 E0 0D 00 00               mov     eax, [rbx+0DE0h]
000000018036A029  89 83 F0 0D 00 00               mov     [rbx+0DF0h], eax
000000018036A02F  F3 0F 10 83 F0 02 00 00         movss   xmm0, dword ptr [rbx+2F0h]
000000018036A037  F3 44 0F 10 83 70 03 00 00      movss   xmm8, dword ptr [rbx+370h]
000000018036A040  8B 83 20 0E 00 00               mov     eax, [rbx+0E20h]
000000018036A046  89 83 30 0E 00 00               mov     [rbx+0E30h], eax
000000018036A04C  F3 0F 59 83 00 0E 00 00         mulss   xmm0, dword ptr [rbx+0E00h]
000000018036A054  F3 44 0F 59 83 10 0E 00 00      mulss   xmm8, dword ptr [rbx+0E10h]
000000018036A05D  F3 44 0F 58 C0                  addss   xmm8, xmm0
000000018036A062  F3 44 0F 11 83 20 0E 00 00      movss   dword ptr [rbx+0E20h], xmm8
000000018036A06B  F3 0F 10 BB 00 07 00 00         movss   xmm7, dword ptr [rbx+700h]
000000018036A073  F3 0F 10 8B C0 0A 00 00         movss   xmm1, dword ptr [rbx+0AC0h]
000000018036A07B  F3 0F 10 93 A0 0C 00 00         movss   xmm2, dword ptr [rbx+0CA0h]
000000018036A083  F3 0F 10 83 F0 02 00 00         movss   xmm0, dword ptr [rbx+2F0h]
000000018036A08B  8B 83 E0 0D 00 00               mov     eax, [rbx+0DE0h]
000000018036A091  89 83 60 0E 00 00               mov     [rbx+0E60h], eax
000000018036A097  F3 0F 11 83 70 0E 00 00         movss   dword ptr [rbx+0E70h], xmm0
000000018036A09F  F3 0F 10 A3 B0 0F 00 00         movss   xmm4, dword ptr [rbx+0FB0h]
000000018036A0A7  F3 0F 11 8B 40 0E 00 00         movss   dword ptr [rbx+0E40h], xmm1
000000018036A0AF  F3 0F 11 93 50 0E 00 00         movss   dword ptr [rbx+0E50h], xmm2
000000018036A0B7  F3 0F 10 AB 90 0F 00 00         movss   xmm5, dword ptr [rbx+0F90h]
000000018036A0BF  F3 0F 59 FC                     mulss   xmm7, xmm4
000000018036A0C3  F3 0F 59 A3 10 07 00 00         mulss   xmm4, dword ptr [rbx+710h]
000000018036A0CB  F3 0F 11 A3 80 0E 00 00         movss   dword ptr [rbx+0E80h], xmm4
000000018036A0D3  F3 0F 10 8B 10 0F 00 00         movss   xmm1, dword ptr [rbx+0F10h]
000000018036A0DB  F3 0F 10 93 10 10 00 00         movss   xmm2, dword ptr [rbx+1010h]
000000018036A0E3  0F 28 D9                        movaps  xmm3, xmm1
000000018036A0E6  F3 0F 59 BB C0 0F 00 00         mulss   xmm7, dword ptr [rbx+0FC0h]
000000018036A0EE  0F 28 C2                        movaps  xmm0, xmm2
000000018036A0F1  F3 0F 10 B3 D0 0F 00 00         movss   xmm6, dword ptr [rbx+0FD0h]
000000018036A0F9  F3 0F 59 C1                     mulss   xmm0, xmm1
000000018036A0FD  F3 0F 59 F7                     mulss   xmm6, xmm7
000000018036A101  F3 0F 59 EC                     mulss   xmm5, xmm4
000000018036A105  F3 0F 59 AB A0 0F 00 00         mulss   xmm5, dword ptr [rbx+0FA0h]
000000018036A10D  F3 0F 11 AB A0 0E 00 00         movss   dword ptr [rbx+0EA0h], xmm5
000000018036A115  F3 0F 58 F5                     addss   xmm6, xmm5
000000018036A119  F3 0F 59 9B 60 0E 00 00         mulss   xmm3, dword ptr [rbx+0E60h]
000000018036A121  F3 0F 5C D8                     subss   xmm3, xmm0
000000018036A125  F3 0F 10 83 20 0F 00 00         movss   xmm0, dword ptr [rbx+0F20h]
000000018036A12D  F3 0F 58 DA                     addss   xmm3, xmm2
000000018036A131  F3 0F 59 9B 20 10 00 00         mulss   xmm3, dword ptr [rbx+1020h]
000000018036A139  F3 0F 11 9B B0 0E 00 00         movss   dword ptr [rbx+0EB0h], xmm3
000000018036A141  F3 0F 10 8B F0 0F 00 00         movss   xmm1, dword ptr [rbx+0FF0h]
000000018036A149  F3 0F 59 8B 50 0E 00 00         mulss   xmm1, dword ptr [rbx+0E50h]
000000018036A151  F3 0F 59 C3                     mulss   xmm0, xmm3
000000018036A155  F3 0F 58 F0                     addss   xmm6, xmm0
000000018036A159  F3 0F 10 83 E0 0F 00 00         movss   xmm0, dword ptr [rbx+0FE0h]
000000018036A161  F3 0F 59 83 40 0E 00 00         mulss   xmm0, dword ptr [rbx+0E40h]
000000018036A169  F3 0F 10 9B 80 0E 00 00         movss   xmm3, dword ptr [rbx+0E80h]
000000018036A171  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036A175  F3 0F 10 83 00 0F 00 00         movss   xmm0, dword ptr [rbx+0F00h]
000000018036A17D  F3 0F 59 8B 00 10 00 00         mulss   xmm1, dword ptr [rbx+1000h]
000000018036A185  F3 0F 58 CE                     addss   xmm1, xmm6
000000018036A189  F3 41 0F 58 C8                  addss   xmm1, xmm8
000000018036A18E  F3 0F 58 8B 70 0F 00 00         addss   xmm1, dword ptr [rbx+0F70h]
000000018036A196  F3 0F 58 8B 80 0F 00 00         addss   xmm1, dword ptr [rbx+0F80h]
000000018036A19E  F3 0F 11 8B C0 0E 00 00         movss   dword ptr [rbx+0EC0h], xmm1
000000018036A1A6  F3 0F 11 83 D0 0E 00 00         movss   dword ptr [rbx+0ED0h], xmm0
000000018036A1AE  F3 0F 59 9B 40 10 00 00         mulss   xmm3, dword ptr [rbx+1040h]
000000018036A1B6  F3 0F 10 83 40 0F 00 00         movss   xmm0, dword ptr [rbx+0F40h]
000000018036A1BE  F3 0F 59 83 40 0E 00 00         mulss   xmm0, dword ptr [rbx+0E40h]
000000018036A1C6  F3 0F 58 9B 50 10 00 00         addss   xmm3, dword ptr [rbx+1050h]
000000018036A1CE  F3 0F 10 8B 50 0F 00 00         movss   xmm1, dword ptr [rbx+0F50h]
000000018036A1D6  F3 0F 59 8B 50 0E 00 00         mulss   xmm1, dword ptr [rbx+0E50h]
000000018036A1DE  F3 0F 10 93 A0 0E 00 00         movss   xmm2, dword ptr [rbx+0EA0h]
000000018036A1E6  F3 0F 59 9B 30 0F 00 00         mulss   xmm3, dword ptr [rbx+0F30h]
000000018036A1EE  F3 0F 58 93 70 0E 00 00         addss   xmm2, dword ptr [rbx+0E70h]
000000018036A1F6  F3 0F 58 D8                     addss   xmm3, xmm0
000000018036A1FA  F3 0F 58 93 B0 0E 00 00         addss   xmm2, dword ptr [rbx+0EB0h]
000000018036A202  F3 0F 58 D9                     addss   xmm3, xmm1
000000018036A206  F3 0F 58 9B 60 0F 00 00         addss   xmm3, dword ptr [rbx+0F60h]
000000018036A20E  F3 0F 59 9B 30 10 00 00         mulss   xmm3, dword ptr [rbx+1030h]
000000018036A216  F3 0F 11 9B E0 0E 00 00         movss   dword ptr [rbx+0EE0h], xmm3
000000018036A21E  F3 0F 11 93 F0 0E 00 00         movss   dword ptr [rbx+0EF0h], xmm2
000000018036A226  F3 0F 10 83 70 10 00 00         movss   xmm0, dword ptr [rbx+1070h]
000000018036A22E  8B 83 60 10 00 00               mov     eax, [rbx+1060h]
000000018036A234  89 83 90 10 00 00               mov     [rbx+1090h], eax
000000018036A23A  F3 0F 11 83 A0 10 00 00         movss   dword ptr [rbx+10A0h], xmm0
000000018036A242  8B 83 80 10 00 00               mov     eax, [rbx+1080h]
000000018036A248  89 83 B0 10 00 00               mov     [rbx+10B0h], eax
000000018036A24E  F3 0F 10 A3 D0 49 01 00         movss   xmm4, dword ptr [rbx+149D0h]
000000018036A256  8B 83 D0 10 00 00               mov     eax, [rbx+10D0h]
000000018036A25C  89 83 E0 10 00 00               mov     [rbx+10E0h], eax
000000018036A262  F3 0F 10 93 C0 10 00 00         movss   xmm2, dword ptr [rbx+10C0h]
000000018036A26A  F3 0F 11 93 D0 10 00 00         movss   dword ptr [rbx+10D0h], xmm2
000000018036A272  0F 28 C2                        movaps  xmm0, xmm2
000000018036A275  0F 28 DA                        movaps  xmm3, xmm2
000000018036A278  F3 0F 59 9B F0 10 00 00         mulss   xmm3, dword ptr [rbx+10F0h]
000000018036A280  F3 0F 58 9B E0 10 00 00         addss   xmm3, dword ptr [rbx+10E0h]
000000018036A288  F3 0F 11 9B D0 10 00 00         movss   dword ptr [rbx+10D0h], xmm3
000000018036A290  F3 0F 59 83 00 11 00 00         mulss   xmm0, dword ptr [rbx+1100h]
000000018036A298  F3 0F 58 C3                     addss   xmm0, xmm3
000000018036A29C  F3 0F 59 9B 30 11 00 00         mulss   xmm3, dword ptr [rbx+1130h]
000000018036A2A4  F3 0F 5C E0                     subss   xmm4, xmm0
000000018036A2A8  0F 28 CC                        movaps  xmm1, xmm4
000000018036A2AB  F3 0F 59 8B F0 10 00 00         mulss   xmm1, dword ptr [rbx+10F0h]
000000018036A2B3  F3 0F 58 CA                     addss   xmm1, xmm2
000000018036A2B7  F3 0F 11 8B C0 10 00 00         movss   dword ptr [rbx+10C0h], xmm1
000000018036A2BF  F3 0F 59 8B 20 11 00 00         mulss   xmm1, dword ptr [rbx+1120h]
000000018036A2C7  F3 0F 59 A3 10 11 00 00         mulss   xmm4, dword ptr [rbx+1110h]
000000018036A2CF  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036A2D3  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036A2D7  F3 0F 11 A3 E0 10 00 00         movss   dword ptr [rbx+10E0h], xmm4
000000018036A2DF  8B 83 10 19 00 00               mov     eax, [rbx+1910h]
000000018036A2E5  89 83 20 19 00 00               mov     [rbx+1920h], eax
000000018036A2EB  F3 0F 10 8B 30 19 00 00         movss   xmm1, dword ptr [rbx+1930h]
000000018036A2F3  F3 0F 11 8B 40 19 00 00         movss   dword ptr [rbx+1940h], xmm1
000000018036A2FB  F3 0F 59 8B D0 0D 00 00         mulss   xmm1, dword ptr [rbx+0DD0h]
000000018036A303  F3 0F 10 83 20 19 00 00         movss   xmm0, dword ptr [rbx+1920h]
000000018036A30B  F3 0F 59 83 E0 10 00 00         mulss   xmm0, dword ptr [rbx+10E0h]
000000018036A313  F3 0F 11 8B 50 19 00 00         movss   dword ptr [rbx+1950h], xmm1
000000018036A31B  F3 0F 11 83 60 19 00 00         movss   dword ptr [rbx+1960h], xmm0
000000018036A323  8B 83 90 19 00 00               mov     eax, [rbx+1990h]
000000018036A329  89 83 A0 19 00 00               mov     [rbx+19A0h], eax
000000018036A32F  F3 0F 59 8B 70 19 00 00         mulss   xmm1, dword ptr [rbx+1970h]
000000018036A337  F3 0F 59 83 80 19 00 00         mulss   xmm0, dword ptr [rbx+1980h]
000000018036A33F  F3 0F 58 C1                     addss   xmm0, xmm1
000000018036A343  F3 0F 11 83 90 19 00 00         movss   dword ptr [rbx+1990h], xmm0
000000018036A34B  8B 83 B0 19 00 00               mov     eax, [rbx+19B0h]
000000018036A351  89 83 C0 19 00 00               mov     [rbx+19C0h], eax
000000018036A357  8B 83 D0 19 00 00               mov     eax, [rbx+19D0h]
000000018036A35D  89 83 E0 19 00 00               mov     [rbx+19E0h], eax
000000018036A363  8B 83 F0 19 00 00               mov     eax, [rbx+19F0h]
000000018036A369  89 83 00 1A 00 00               mov     [rbx+1A00h], eax
000000018036A36F  8B 83 10 1A 00 00               mov     eax, [rbx+1A10h]
000000018036A375  89 83 20 1A 00 00               mov     [rbx+1A20h], eax
000000018036A37B  F3 0F 10 8B 40 1A 00 00         movss   xmm1, dword ptr [rbx+1A40h]
000000018036A383  F3 0F 10 93 50 1A 00 00         movss   xmm2, dword ptr [rbx+1A50h]
000000018036A38B  0F 28 E1                        movaps  xmm4, xmm1
000000018036A38E  F3 0F 59 A3 B0 19 00 00         mulss   xmm4, dword ptr [rbx+19B0h]
000000018036A396  0F 28 C2                        movaps  xmm0, xmm2
000000018036A399  F3 0F 59 C1                     mulss   xmm0, xmm1
000000018036A39D  F3 0F 5C E0                     subss   xmm4, xmm0
000000018036A3A1  F3 0F 58 E2                     addss   xmm4, xmm2
000000018036A3A5  0F 28 DC                        movaps  xmm3, xmm4
000000018036A3A8  0F 28 CC                        movaps  xmm1, xmm4
000000018036A3AB  F3 0F 59 8B 70 1A 00 00         mulss   xmm1, dword ptr [rbx+1A70h]
000000018036A3B3  F3 0F 59 DC                     mulss   xmm3, xmm4
000000018036A3B7  F3 0F 58 8B 60 1A 00 00         addss   xmm1, dword ptr [rbx+1A60h]
000000018036A3BF  0F 28 C3                        movaps  xmm0, xmm3
000000018036A3C2  F3 0F 59 DC                     mulss   xmm3, xmm4
000000018036A3C6  F3 0F 59 83 80 1A 00 00         mulss   xmm0, dword ptr [rbx+1A80h]
000000018036A3CE  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036A3D2  0F 28 C3                        movaps  xmm0, xmm3
000000018036A3D5  F3 0F 59 9B 90 1A 00 00         mulss   xmm3, dword ptr [rbx+1A90h]
000000018036A3DD  F3 0F 59 C4                     mulss   xmm0, xmm4
000000018036A3E1  F3 0F 58 D9                     addss   xmm3, xmm1
000000018036A3E5  F3 0F 59 83 A0 1A 00 00         mulss   xmm0, dword ptr [rbx+1AA0h]
000000018036A3ED  F3 0F 58 C3                     addss   xmm0, xmm3
000000018036A3F1  41 0F 2F C6                     comiss  xmm0, xmm14
000000018036A3F5  76 05                           jbe     short loc_18036A3FC
000000018036A3F7  0F 5A C0                        cvtps2pd xmm0, xmm0
000000018036A3FA  EB 03                           jmp     short loc_18036A3FF
000000018036A3FC  0F 57 C0                        xorps   xmm0, xmm0
000000018036A3FF  66 0F 5A C8                     cvtpd2ps xmm1, xmm0
000000018036A403  41 0F 2F CD                     comiss  xmm1, xmm13
000000018036A407  73 04                           jnb     short loc_18036A40D
000000018036A409  44 0F 5A E1                     cvtps2pd xmm12, xmm1
000000018036A40D  66 41 0F 5A C4                  cvtpd2ps xmm0, xmm12
000000018036A412  F3 0F 11 83 30 1A 00 00         movss   dword ptr [rbx+1A30h], xmm0
000000018036A41A  8B 83 B0 1A 00 00               mov     eax, [rbx+1AB0h]
000000018036A420  89 83 C0 1A 00 00               mov     [rbx+1AC0h], eax
000000018036A426  F3 0F 10 8B D0 1A 00 00         movss   xmm1, dword ptr [rbx+1AD0h]
000000018036A42E  F3 0F 11 8B E0 1A 00 00         movss   dword ptr [rbx+1AE0h], xmm1
000000018036A436  F3 0F 10 83 F0 1A 00 00         movss   xmm0, dword ptr [rbx+1AF0h]
000000018036A43E  F3 0F 11 83 00 1B 00 00         movss   dword ptr [rbx+1B00h], xmm0
000000018036A446  F3 0F 5C C8                     subss   xmm1, xmm0
000000018036A44A  F3 0F 59 8B 10 1B 00 00         mulss   xmm1, dword ptr [rbx+1B10h]
000000018036A452  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036A456  F3 0F 11 8B F0 1A 00 00         movss   dword ptr [rbx+1AF0h], xmm1
000000018036A45E  F3 0F 10 8B F0 02 00 00         movss   xmm1, dword ptr [rbx+2F0h]
000000018036A466  F3 0F 10 83 70 03 00 00         movss   xmm0, dword ptr [rbx+370h]
000000018036A46E  8B 83 40 1B 00 00               mov     eax, [rbx+1B40h]
000000018036A474  89 83 50 1B 00 00               mov     [rbx+1B50h], eax
000000018036A47A  F3 0F 59 83 30 1B 00 00         mulss   xmm0, dword ptr [rbx+1B30h]
000000018036A482  F3 0F 59 8B 20 1B 00 00         mulss   xmm1, dword ptr [rbx+1B20h]
000000018036A48A  F3 0F 58 C1                     addss   xmm0, xmm1
000000018036A48E  F3 0F 11 83 40 1B 00 00         movss   dword ptr [rbx+1B40h], xmm0
000000018036A496  8B 83 60 1B 00 00               mov     eax, [rbx+1B60h]
000000018036A49C  89 83 80 1B 00 00               mov     [rbx+1B80h], eax
000000018036A4A2  F3 0F 10 9B 70 1B 00 00         movss   xmm3, dword ptr [rbx+1B70h]
000000018036A4AA  F3 0F 11 9B 90 1B 00 00         movss   dword ptr [rbx+1B90h], xmm3
000000018036A4B2  F3 0F 10 8B 80 1B 00 00         movss   xmm1, dword ptr [rbx+1B80h]
000000018036A4BA  F3 0F 10 93 C0 0A 00 00         movss   xmm2, dword ptr [rbx+0AC0h]
000000018036A4C2  0F 28 C1                        movaps  xmm0, xmm1
000000018036A4C5  F3 0F 59 83 A0 0C 00 00         mulss   xmm0, dword ptr [rbx+0CA0h]
000000018036A4CD  F3 0F 59 CA                     mulss   xmm1, xmm2
000000018036A4D1  F3 0F 5C C1                     subss   xmm0, xmm1
000000018036A4D5  0F 28 CB                        movaps  xmm1, xmm3
000000018036A4D8  F3 0F 59 8B F0 19 00 00         mulss   xmm1, dword ptr [rbx+19F0h]
000000018036A4E0  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036A4E4  F3 0F 59 DA                     mulss   xmm3, xmm2
000000018036A4E8  F3 0F 5C CB                     subss   xmm1, xmm3
000000018036A4EC  F3 0F 58 CA                     addss   xmm1, xmm2
000000018036A4F0  F3 0F 11 8B A0 1B 00 00         movss   dword ptr [rbx+1BA0h], xmm1
000000018036A4F8  F3 0F 10 9B 00 07 00 00         movss   xmm3, dword ptr [rbx+700h]
000000018036A500  F3 0F 10 83 B0 1B 00 00         movss   xmm0, dword ptr [rbx+1BB0h]
000000018036A508  F3 0F 11 83 C0 1B 00 00         movss   dword ptr [rbx+1BC0h], xmm0
000000018036A510  F3 0F 5C D8                     subss   xmm3, xmm0
000000018036A514  0F 28 CB                        movaps  xmm1, xmm3
000000018036A517  F3 0F 59 8B D0 1B 00 00         mulss   xmm1, dword ptr [rbx+1BD0h]
000000018036A51F  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036A523  F3 0F 10 83 F0 1B 00 00         movss   xmm0, dword ptr [rbx+1BF0h]
000000018036A52B  F3 0F 11 8B B0 1B 00 00         movss   dword ptr [rbx+1BB0h], xmm1
000000018036A533  F3 0F 59 9B E0 1B 00 00         mulss   xmm3, dword ptr [rbx+1BE0h]
000000018036A53B  F3 0F 59 C1                     mulss   xmm0, xmm1
000000018036A53F  F3 0F 58 D8                     addss   xmm3, xmm0
000000018036A543  F3 0F 11 9B C0 1B 00 00         movss   dword ptr [rbx+1BC0h], xmm3
000000018036A54B  F3 0F 10 83 00 1C 00 00         movss   xmm0, dword ptr [rbx+1C00h]
000000018036A553  F3 0F 10 BB 10 07 00 00         movss   xmm7, dword ptr [rbx+710h]
000000018036A55B  F3 0F 11 83 10 1C 00 00         movss   dword ptr [rbx+1C10h], xmm0
000000018036A563  F3 0F 5C F8                     subss   xmm7, xmm0
000000018036A567  0F 28 CF                        movaps  xmm1, xmm7
000000018036A56A  F3 0F 59 8B 20 1C 00 00         mulss   xmm1, dword ptr [rbx+1C20h]
000000018036A572  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036A576  F3 0F 10 83 40 1C 00 00         movss   xmm0, dword ptr [rbx+1C40h]
000000018036A57E  F3 0F 11 8B 00 1C 00 00         movss   dword ptr [rbx+1C00h], xmm1
000000018036A586  F3 0F 59 BB 30 1C 00 00         mulss   xmm7, dword ptr [rbx+1C30h]
000000018036A58E  F3 0F 59 C1                     mulss   xmm0, xmm1
000000018036A592  F3 0F 58 F8                     addss   xmm7, xmm0
000000018036A596  F3 0F 11 BB 10 1C 00 00         movss   dword ptr [rbx+1C10h], xmm7
000000018036A59E  F3 0F 10 A3 C0 1B 00 00         movss   xmm4, dword ptr [rbx+1BC0h]
000000018036A5A6  F3 0F 10 AB A0 1B 00 00         movss   xmm5, dword ptr [rbx+1BA0h]
000000018036A5AE  F3 0F 10 B3 40 1B 00 00         movss   xmm6, dword ptr [rbx+1B40h]
000000018036A5B6  F3 44 0F 10 8B D0 19 00 00      movss   xmm9, dword ptr [rbx+19D0h]
000000018036A5BF  8B 83 F0 1A 00 00               mov     eax, [rbx+1AF0h]
000000018036A5C5  89 83 50 1C 00 00               mov     [rbx+1C50h], eax
000000018036A5CB  F3 44 0F 11 8B 60 1C 00 00      movss   dword ptr [rbx+1C60h], xmm9
000000018036A5D4  F3 0F 10 83 80 1C 00 00         movss   xmm0, dword ptr [rbx+1C80h]
000000018036A5DC  F3 0F 10 93 90 1C 00 00         movss   xmm2, dword ptr [rbx+1C90h]
000000018036A5E4  F3 0F 59 F8                     mulss   xmm7, xmm0
000000018036A5E8  0F 28 DA                        movaps  xmm3, xmm2
000000018036A5EB  F3 0F 59 9B 10 1A 00 00         mulss   xmm3, dword ptr [rbx+1A10h]
000000018036A5F3  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036A5F7  0F 28 C2                        movaps  xmm0, xmm2
000000018036A5FA  F3 0F 59 C7                     mulss   xmm0, xmm7
000000018036A5FE  44 0F 28 C3                     movaps  xmm8, xmm3
000000018036A602  F3 44 0F 5C C0                  subss   xmm8, xmm0
000000018036A607  F3 44 0F 58 C7                  addss   xmm8, xmm7
000000018036A60C  F3 44 0F 59 83 C0 1C 00 00      mulss   xmm8, dword ptr [rbx+1CC0h]
000000018036A615  F3 0F 10 8B A0 1C 00 00         movss   xmm1, dword ptr [rbx+1CA0h]
000000018036A61D  F3 0F 58 B3 40 1D 00 00         addss   xmm6, dword ptr [rbx+1D40h]
000000018036A625  F3 44 0F 59 83 D0 1C 00 00      mulss   xmm8, dword ptr [rbx+1CD0h]
000000018036A62E  F3 0F 59 AB E0 1C 00 00         mulss   xmm5, dword ptr [rbx+1CE0h]
000000018036A636  F3 0F 59 B3 F0 1C 00 00         mulss   xmm6, dword ptr [rbx+1CF0h]
000000018036A63E  F3 44 0F 59 C9                  mulss   xmm9, xmm1
000000018036A643  F3 0F 59 D4                     mulss   xmm2, xmm4
000000018036A647  F3 0F 58 F5                     addss   xmm6, xmm5
000000018036A64B  F3 0F 5C DA                     subss   xmm3, xmm2
000000018036A64F  F3 0F 10 93 20 1D 00 00         movss   xmm2, dword ptr [rbx+1D20h]
000000018036A657  0F 28 C2                        movaps  xmm0, xmm2
000000018036A65A  F3 0F 59 C1                     mulss   xmm0, xmm1
000000018036A65E  F3 0F 58 DC                     addss   xmm3, xmm4
000000018036A662  F3 44 0F 5C C8                  subss   xmm9, xmm0
000000018036A667  F3 0F 10 83 10 1D 00 00         movss   xmm0, dword ptr [rbx+1D10h]
000000018036A66F  F3 0F 58 83 50 1C 00 00         addss   xmm0, dword ptr [rbx+1C50h]
000000018036A677  F3 0F 59 9B B0 1C 00 00         mulss   xmm3, dword ptr [rbx+1CB0h]
000000018036A67F  F3 0F 59 83 50 1D 00 00         mulss   xmm0, dword ptr [rbx+1D50h]
000000018036A687  F3 44 0F 58 CA                  addss   xmm9, xmm2
000000018036A68C  F3 44 0F 58 C3                  addss   xmm8, xmm3
000000018036A691  F3 0F 59 83 00 1D 00 00         mulss   xmm0, dword ptr [rbx+1D00h]
000000018036A699  F3 44 0F 59 8B 30 1D 00 00      mulss   xmm9, dword ptr [rbx+1D30h]
000000018036A6A2  F3 44 0F 58 C6                  addss   xmm8, xmm6
000000018036A6A7  F3 44 0F 58 C8                  addss   xmm9, xmm0
000000018036A6AC  F3 45 0F 58 C8                  addss   xmm9, xmm8
000000018036A6B1  F3 44 0F 11 8B 70 1C 00 00      movss   dword ptr [rbx+1C70h], xmm9
000000018036A6BA  F3 0F 10 BB 30 1A 00 00         movss   xmm7, dword ptr [rbx+1A30h]
000000018036A6C2  F3 44 0F 10 83 C0 1A 00 00      movss   xmm8, dword ptr [rbx+1AC0h]
000000018036A6CB  8B 83 90 1D 00 00               mov     eax, [rbx+1D90h]
000000018036A6D1  89 83 A0 1D 00 00               mov     [rbx+1DA0h], eax
000000018036A6D7  F3 0F 10 83 80 1D 00 00         movss   xmm0, dword ptr [rbx+1D80h]
000000018036A6DF  F3 0F 11 83 90 1D 00 00         movss   dword ptr [rbx+1D90h], xmm0
000000018036A6E7  44 0F 2E AB D0 1D 00 00         ucomiss xmm13, dword ptr [rbx+1DD0h]
000000018036A6EF  0F 85 8F 02 00 00               jnz     loc_18036A984
000000018036A6F5  F3 0F 10 8B 20 1E 00 00         movss   xmm1, dword ptr [rbx+1E20h]
000000018036A6FD  F3 0F 10 B3 A0 1D 00 00         movss   xmm6, dword ptr [rbx+1DA0h]
000000018036A705  0F 28 D1                        movaps  xmm2, xmm1
000000018036A708  F3 0F 59 CE                     mulss   xmm1, xmm6
000000018036A70C  F3 0F 59 D0                     mulss   xmm2, xmm0
000000018036A710  41 0F 57 C3                     xorps   xmm0, xmm11
000000018036A714  F3 0F 5C D1                     subss   xmm2, xmm1
000000018036A718  F3 0F 58 F2                     addss   xmm6, xmm2
000000018036A71C  F3 0F 11 B3 90 1D 00 00         movss   dword ptr [rbx+1D90h], xmm6
000000018036A724  F3 0F 59 B3 10 1E 00 00         mulss   xmm6, dword ptr [rbx+1E10h]
000000018036A72C  F3 0F 58 B3 B0 1D 00 00         addss   xmm6, dword ptr [rbx+1DB0h]
000000018036A734  E8 27 E6 FF FF                  call    sub_180368D60
000000018036A739  F3 0F 11 83 80 1D 00 00         movss   dword ptr [rbx+1D80h], xmm0
000000018036A741  41 0F 28 C8                     movaps  xmm1, xmm8
000000018036A745  F3 0F 59 8B 70 1E 00 00         mulss   xmm1, dword ptr [rbx+1E70h]
000000018036A74D  41 0F 28 D5                     movaps  xmm2, xmm13
000000018036A751  F3 41 0F 5C D0                  subss   xmm2, xmm8
000000018036A756  F3 0F 58 8B C0 1D 00 00         addss   xmm1, dword ptr [rbx+1DC0h]
000000018036A75E  F3 0F 59 93 30 1E 00 00         mulss   xmm2, dword ptr [rbx+1E30h]
000000018036A766  F3 0F 11 8B 70 1D 00 00         movss   dword ptr [rbx+1D70h], xmm1
000000018036A76E  F3 44 0F 59 8B 00 1E 00 00      mulss   xmm9, dword ptr [rbx+1E00h]
000000018036A777  F3 0F 59 BB E0 1D 00 00         mulss   xmm7, dword ptr [rbx+1DE0h]
000000018036A77F  F3 0F 10 83 40 1E 00 00         movss   xmm0, dword ptr [rbx+1E40h]
000000018036A787  F3 0F 5D C2                     minss   xmm0, xmm2
000000018036A78B  F3 44 0F 58 CF                  addss   xmm9, xmm7
000000018036A790  F3 44 0F 58 CE                  addss   xmm9, xmm6
000000018036A795  F3 44 0F 58 C8                  addss   xmm9, xmm0
000000018036A79A  F3 44 0F 58 8B F0 1D 00 00      addss   xmm9, dword ptr [rbx+1DF0h]
000000018036A7A3  F3 44 0F 5D 8B 50 1E 00 00      minss   xmm9, dword ptr [rbx+1E50h]
000000018036A7AC  F3 44 0F 5F 8B 60 1E 00 00      maxss   xmm9, dword ptr [rbx+1E60h]
000000018036A7B5  F3 44 0F 59 8B 90 1E 00 00      mulss   xmm9, dword ptr [rbx+1E90h]
000000018036A7BE  F3 44 0F 58 8B A0 1E 00 00      addss   xmm9, dword ptr [rbx+1EA0h]
000000018036A7C7  41 0F 28 C9                     movaps  xmm1, xmm9
000000018036A7CB  F3 0F 2C C9                     cvttss2si ecx, xmm1
000000018036A7CF  81 F9 00 00 00 80               cmp     ecx, 80000000h
000000018036A7D5  74 1E                           jz      short loc_18036A7F5
000000018036A7D7  66 0F 6E C1                     movd    xmm0, ecx
000000018036A7DB  0F 5B C0                        cvtdq2ps xmm0, xmm0
000000018036A7DE  0F 2E C1                        ucomiss xmm0, xmm1
000000018036A7E1  74 12                           jz      short loc_18036A7F5
000000018036A7E3  0F 14 C9                        unpcklps xmm1, xmm1
000000018036A7E6  0F 50 C1                        movmskps eax, xmm1
000000018036A7E9  83 E0 01                        and     eax, 1
000000018036A7EC  2B C8                           sub     ecx, eax
000000018036A7EE  66 0F 6E C9                     movd    xmm1, ecx
000000018036A7F2  0F 5B C9                        cvtdq2ps xmm1, xmm1
000000018036A7F5  F3 44 0F 5C C9                  subss   xmm9, xmm1
000000018036A7FA  0F 28 C1                        movaps  xmm0, xmm1; X
000000018036A7FD  41 0F 28 F1                     movaps  xmm6, xmm9
000000018036A801  F3 41 0F 59 F1                  mulss   xmm6, xmm9
000000018036A806  F3 0F 59 35 C2 A7 77 00         mulss   xmm6, cs:dword_180AE4FD0
000000018036A80E  E8 2D 4F 38 00                  call    expf
000000018036A813  0F 28 E0                        movaps  xmm4, xmm0
000000018036A816  41 0F 28 D1                     movaps  xmm2, xmm9
000000018036A81A  F3 0F 59 93 60 1F 00 00         mulss   xmm2, dword ptr [rbx+1F60h]
000000018036A822  41 0F 28 C9                     movaps  xmm1, xmm9
000000018036A826  F3 0F 59 8B 40 1F 00 00         mulss   xmm1, dword ptr [rbx+1F40h]
000000018036A82E  41 0F 28 C1                     movaps  xmm0, xmm9
000000018036A832  F3 0F 58 93 50 1F 00 00         addss   xmm2, dword ptr [rbx+1F50h]
000000018036A83A  F3 0F 59 83 20 1F 00 00         mulss   xmm0, dword ptr [rbx+1F20h]
000000018036A842  F3 0F 59 D6                     mulss   xmm2, xmm6
000000018036A846  F3 0F 58 D1                     addss   xmm2, xmm1
000000018036A84A  F3 0F 58 93 30 1F 00 00         addss   xmm2, dword ptr [rbx+1F30h]
000000018036A852  F3 0F 59 D6                     mulss   xmm2, xmm6
000000018036A856  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036A85A  41 0F 28 C1                     movaps  xmm0, xmm9
000000018036A85E  F3 0F 59 83 00 1F 00 00         mulss   xmm0, dword ptr [rbx+1F00h]
000000018036A866  F3 0F 58 93 10 1F 00 00         addss   xmm2, dword ptr [rbx+1F10h]
000000018036A86E  F3 0F 59 D6                     mulss   xmm2, xmm6
000000018036A872  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036A876  41 0F 28 C1                     movaps  xmm0, xmm9
000000018036A87A  F3 0F 59 83 E0 1E 00 00         mulss   xmm0, dword ptr [rbx+1EE0h]
000000018036A882  F3 44 0F 59 8B C0 1E 00 00      mulss   xmm9, dword ptr [rbx+1EC0h]
000000018036A88B  F3 0F 58 93 F0 1E 00 00         addss   xmm2, dword ptr [rbx+1EF0h]
000000018036A893  F3 0F 59 D6                     mulss   xmm2, xmm6
000000018036A897  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036A89B  F3 0F 58 93 D0 1E 00 00         addss   xmm2, dword ptr [rbx+1ED0h]
000000018036A8A3  F3 0F 59 D6                     mulss   xmm2, xmm6
000000018036A8A7  F3 41 0F 58 D1                  addss   xmm2, xmm9
000000018036A8AC  F3 41 0F 58 D5                  addss   xmm2, xmm13
000000018036A8B1  F3 0F 59 E2                     mulss   xmm4, xmm2
000000018036A8B5  F3 0F 59 A3 B0 1E 00 00         mulss   xmm4, dword ptr [rbx+1EB0h]
000000018036A8BD  0F 28 DC                        movaps  xmm3, xmm4
000000018036A8C0  F3 0F 59 DC                     mulss   xmm3, xmm4
000000018036A8C4  0F 28 CB                        movaps  xmm1, xmm3
000000018036A8C7  44 0F 28 C3                     movaps  xmm8, xmm3
000000018036A8CB  F3 44 0F 59 83 00 20 00 00      mulss   xmm8, dword ptr [rbx+2000h]
000000018036A8D4  0F 28 C3                        movaps  xmm0, xmm3
000000018036A8D7  F3 0F 59 83 C0 1F 00 00         mulss   xmm0, dword ptr [rbx+1FC0h]
000000018036A8DF  0F 28 D3                        movaps  xmm2, xmm3
000000018036A8E2  F3 44 0F 58 83 E0 1F 00 00      addss   xmm8, dword ptr [rbx+1FE0h]
000000018036A8EB  F3 0F 59 CC                     mulss   xmm1, xmm4
000000018036A8EF  F3 0F 58 83 A0 1F 00 00         addss   xmm0, dword ptr [rbx+1FA0h]
000000018036A8F7  F3 0F 59 D3                     mulss   xmm2, xmm3
000000018036A8FB  F3 44 0F 59 C2                  mulss   xmm8, xmm2
000000018036A900  F3 44 0F 58 C0                  addss   xmm8, xmm0
000000018036A905  0F 28 C1                        movaps  xmm0, xmm1
000000018036A908  F3 0F 59 8B 80 1F 00 00         mulss   xmm1, dword ptr [rbx+1F80h]
000000018036A910  F3 0F 59 C3                     mulss   xmm0, xmm3
000000018036A914  F3 44 0F 59 C0                  mulss   xmm8, xmm0
000000018036A919  0F 28 C3                        movaps  xmm0, xmm3
000000018036A91C  F3 0F 59 83 B0 1F 00 00         mulss   xmm0, dword ptr [rbx+1FB0h]
000000018036A924  F3 44 0F 58 C1                  addss   xmm8, xmm1
000000018036A929  0F 28 CB                        movaps  xmm1, xmm3
000000018036A92C  F3 0F 59 8B F0 1F 00 00         mulss   xmm1, dword ptr [rbx+1FF0h]
000000018036A934  F3 0F 59 9B 70 1F 00 00         mulss   xmm3, dword ptr [rbx+1F70h]
000000018036A93C  F3 0F 58 8B D0 1F 00 00         addss   xmm1, dword ptr [rbx+1FD0h]
000000018036A944  F3 44 0F 58 C4                  addss   xmm8, xmm4
000000018036A949  F3 0F 59 CA                     mulss   xmm1, xmm2
000000018036A94D  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036A951  F3 0F 58 8B 90 1F 00 00         addss   xmm1, dword ptr [rbx+1F90h]
000000018036A959  F3 0F 59 CA                     mulss   xmm1, xmm2
000000018036A95D  F3 0F 58 CB                     addss   xmm1, xmm3
000000018036A961  F3 41 0F 58 CD                  addss   xmm1, xmm13
000000018036A966  F3 44 0F 5E C1                  divss   xmm8, xmm1
000000018036A96B  41 0F 28 C0                     movaps  xmm0, xmm8
000000018036A96F  F3 41 0F 58 C5                  addss   xmm0, xmm13
000000018036A974  F3 44 0F 5E C0                  divss   xmm8, xmm0
000000018036A979  F3 44 0F 11 83 60 1D 00 00      movss   dword ptr [rbx+1D60h], xmm8
000000018036A982  EB 09                           jmp     short loc_18036A98D
000000018036A984  F3 44 0F 10 83 60 1D 00 00      movss   xmm8, dword ptr [rbx+1D60h]
000000018036A98D  8B 83 70 20 00 00               mov     eax, [rbx+2070h]
000000018036A993  F3 0F 10 8B 90 19 00 00         movss   xmm1, dword ptr [rbx+1990h]
000000018036A99B  F3 44 0F 10 8B 70 1D 00 00      movss   xmm9, dword ptr [rbx+1D70h]
000000018036A9A4  89 83 80 20 00 00               mov     [rbx+2080h], eax
000000018036A9AA  8B 83 60 20 00 00               mov     eax, [rbx+2060h]
000000018036A9B0  89 83 70 20 00 00               mov     [rbx+2070h], eax
000000018036A9B6  8B 83 50 20 00 00               mov     eax, [rbx+2050h]
000000018036A9BC  89 83 60 20 00 00               mov     [rbx+2060h], eax
000000018036A9C2  8B 83 40 20 00 00               mov     eax, [rbx+2040h]
000000018036A9C8  89 83 50 20 00 00               mov     [rbx+2050h], eax
000000018036A9CE  8B 83 30 20 00 00               mov     eax, [rbx+2030h]
000000018036A9D4  89 83 40 20 00 00               mov     [rbx+2040h], eax
000000018036A9DA  8B 83 20 20 00 00               mov     eax, [rbx+2020h]
000000018036A9E0  89 83 30 20 00 00               mov     [rbx+2030h], eax
000000018036A9E6  8B 83 10 20 00 00               mov     eax, [rbx+2010h]
000000018036A9EC  89 83 20 20 00 00               mov     [rbx+2020h], eax
000000018036A9F2  8B 83 50 21 00 00               mov     eax, [rbx+2150h]
000000018036A9F8  89 83 60 21 00 00               mov     [rbx+2160h], eax
000000018036A9FE  8B 83 40 21 00 00               mov     eax, [rbx+2140h]
000000018036AA04  89 83 50 21 00 00               mov     [rbx+2150h], eax
000000018036AA0A  8B 83 30 21 00 00               mov     eax, [rbx+2130h]
000000018036AA10  89 83 40 21 00 00               mov     [rbx+2140h], eax
000000018036AA16  8B 83 20 21 00 00               mov     eax, [rbx+2120h]
000000018036AA1C  89 83 30 21 00 00               mov     [rbx+2130h], eax
000000018036AA22  8B 83 10 21 00 00               mov     eax, [rbx+2110h]
000000018036AA28  89 83 20 21 00 00               mov     [rbx+2120h], eax
000000018036AA2E  8B 83 00 21 00 00               mov     eax, [rbx+2100h]
000000018036AA34  89 83 10 21 00 00               mov     [rbx+2110h], eax
000000018036AA3A  8B 83 F0 20 00 00               mov     eax, [rbx+20F0h]
000000018036AA40  89 83 00 21 00 00               mov     [rbx+2100h], eax
000000018036AA46  8B 83 D0 21 00 00               mov     eax, [rbx+21D0h]
000000018036AA4C  89 83 E0 21 00 00               mov     [rbx+21E0h], eax
000000018036AA52  8B 83 C0 21 00 00               mov     eax, [rbx+21C0h]
000000018036AA58  89 83 D0 21 00 00               mov     [rbx+21D0h], eax
000000018036AA5E  8B 83 B0 21 00 00               mov     eax, [rbx+21B0h]
000000018036AA64  89 83 C0 21 00 00               mov     [rbx+21C0h], eax
000000018036AA6A  8B 83 A0 21 00 00               mov     eax, [rbx+21A0h]
000000018036AA70  89 83 B0 21 00 00               mov     [rbx+21B0h], eax
000000018036AA76  8B 83 90 21 00 00               mov     eax, [rbx+2190h]
000000018036AA7C  89 83 A0 21 00 00               mov     [rbx+21A0h], eax
000000018036AA82  8B 83 80 21 00 00               mov     eax, [rbx+2180h]
000000018036AA88  89 83 90 21 00 00               mov     [rbx+2190h], eax
000000018036AA8E  8B 83 70 21 00 00               mov     eax, [rbx+2170h]
000000018036AA94  89 83 80 21 00 00               mov     [rbx+2180h], eax
000000018036AA9A  8B 83 50 22 00 00               mov     eax, [rbx+2250h]
000000018036AAA0  89 83 60 22 00 00               mov     [rbx+2260h], eax
000000018036AAA6  8B 83 40 22 00 00               mov     eax, [rbx+2240h]
000000018036AAAC  89 83 50 22 00 00               mov     [rbx+2250h], eax
000000018036AAB2  8B 83 30 22 00 00               mov     eax, [rbx+2230h]
000000018036AAB8  89 83 40 22 00 00               mov     [rbx+2240h], eax
000000018036AABE  8B 83 20 22 00 00               mov     eax, [rbx+2220h]
000000018036AAC4  89 83 30 22 00 00               mov     [rbx+2230h], eax
000000018036AACA  8B 83 10 22 00 00               mov     eax, [rbx+2210h]
000000018036AAD0  89 83 20 22 00 00               mov     [rbx+2220h], eax
000000018036AAD6  8B 83 00 22 00 00               mov     eax, [rbx+2200h]
000000018036AADC  89 83 10 22 00 00               mov     [rbx+2210h], eax
000000018036AAE2  8B 83 F0 21 00 00               mov     eax, [rbx+21F0h]
000000018036AAE8  89 83 00 22 00 00               mov     [rbx+2200h], eax
000000018036AAEE  8B 83 D0 22 00 00               mov     eax, [rbx+22D0h]
000000018036AAF4  89 83 E0 22 00 00               mov     [rbx+22E0h], eax
000000018036AAFA  8B 83 C0 22 00 00               mov     eax, [rbx+22C0h]
000000018036AB00  89 83 D0 22 00 00               mov     [rbx+22D0h], eax
000000018036AB06  8B 83 B0 22 00 00               mov     eax, [rbx+22B0h]
000000018036AB0C  89 83 C0 22 00 00               mov     [rbx+22C0h], eax
000000018036AB12  8B 83 A0 22 00 00               mov     eax, [rbx+22A0h]
000000018036AB18  89 83 B0 22 00 00               mov     [rbx+22B0h], eax
000000018036AB1E  8B 83 90 22 00 00               mov     eax, [rbx+2290h]
000000018036AB24  89 83 A0 22 00 00               mov     [rbx+22A0h], eax
000000018036AB2A  8B 83 80 22 00 00               mov     eax, [rbx+2280h]
000000018036AB30  89 83 90 22 00 00               mov     [rbx+2290h], eax
000000018036AB36  8B 83 70 22 00 00               mov     eax, [rbx+2270h]
000000018036AB3C  89 83 80 22 00 00               mov     [rbx+2280h], eax
000000018036AB42  8B 83 F0 22 00 00               mov     eax, [rbx+22F0h]
000000018036AB48  89 83 00 23 00 00               mov     [rbx+2300h], eax
000000018036AB4E  F3 0F 10 83 10 23 00 00         movss   xmm0, dword ptr [rbx+2310h]
000000018036AB56  F3 0F 11 83 20 23 00 00         movss   dword ptr [rbx+2320h], xmm0
000000018036AB5E  44 0F 2E AB 60 23 00 00         ucomiss xmm13, dword ptr [rbx+2360h]
000000018036AB66  0F 85 49 09 00 00               jnz     loc_18036B4B5
000000018036AB6C  F3 0F 59 8B B0 23 00 00         mulss   xmm1, dword ptr [rbx+23B0h]
000000018036AB74  41 0F 57 C3                     xorps   xmm0, xmm11
000000018036AB78  41 0F 28 F1                     movaps  xmm6, xmm9
000000018036AB7C  41 0F 28 F8                     movaps  xmm7, xmm8
000000018036AB80  F3 0F 59 B3 D0 23 00 00         mulss   xmm6, dword ptr [rbx+23D0h]
000000018036AB88  F3 41 0F 59 F8                  mulss   xmm7, xmm8
000000018036AB8D  F3 41 0F 58 F5                  addss   xmm6, xmm13
000000018036AB92  F3 0F 59 F1                     mulss   xmm6, xmm1
000000018036AB96  0F 28 C8                        movaps  xmm1, xmm0
000000018036AB99  F3 0F 59 8B A0 23 00 00         mulss   xmm1, dword ptr [rbx+23A0h]
000000018036ABA1  F3 0F 58 F1                     addss   xmm6, xmm1
000000018036ABA5  E8 B6 E1 FF FF                  call    sub_180368D60
000000018036ABAA  F3 0F 11 83 10 23 00 00         movss   dword ptr [rbx+2310h], xmm0
000000018036ABB2  41 0F 28 DD                     movaps  xmm3, xmm13
000000018036ABB6  F3 0F 11 B3 F0 22 00 00         movss   dword ptr [rbx+22F0h], xmm6
000000018036ABBE  41 0F 28 C0                     movaps  xmm0, xmm8
000000018036ABC2  F3 0F 59 FF                     mulss   xmm7, xmm7
000000018036ABC6  F3 41 0F 58 C0                  addss   xmm0, xmm8
000000018036ABCB  41 0F 28 F5                     movaps  xmm6, xmm13
000000018036ABCF  F3 41 0F 59 F9                  mulss   xmm7, xmm9
000000018036ABD4  F3 0F 5C F0                     subss   xmm6, xmm0
000000018036ABD8  F3 41 0F 58 FD                  addss   xmm7, xmm13
000000018036ABDD  F3 0F 5E DF                     divss   xmm3, xmm7
000000018036ABE1  F3 0F 11 9B 40 23 00 00         movss   dword ptr [rbx+2340h], xmm3
000000018036ABE9  0F 28 E3                        movaps  xmm4, xmm3
000000018036ABEC  F3 0F 10 8B F0 22 00 00         movss   xmm1, dword ptr [rbx+22F0h]
000000018036ABF4  F3 0F 10 AB 00 23 00 00         movss   xmm5, dword ptr [rbx+2300h]
000000018036ABFC  F3 41 0F 59 E1                  mulss   xmm4, xmm9
000000018036AC01  F3 0F 11 A3 30 23 00 00         movss   dword ptr [rbx+2330h], xmm4
000000018036AC09  F3 0F 59 AB 00 24 00 00         mulss   xmm5, dword ptr [rbx+2400h]
000000018036AC11  F3 0F 10 93 70 20 00 00         movss   xmm2, dword ptr [rbx+2070h]
000000018036AC19  F3 0F 59 8B 10 24 00 00         mulss   xmm1, dword ptr [rbx+2410h]
000000018036AC21  F3 0F 10 83 80 20 00 00         movss   xmm0, dword ptr [rbx+2080h]
000000018036AC29  F3 0F 11 93 E0 20 00 00         movss   dword ptr [rbx+20E0h], xmm2
000000018036AC31  F3 0F 59 93 30 25 00 00         mulss   xmm2, dword ptr [rbx+2530h]
000000018036AC39  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036AC3D  F3 0F 59 83 40 25 00 00         mulss   xmm0, dword ptr [rbx+2540h]
000000018036AC45  F3 0F 59 EB                     mulss   xmm5, xmm3
000000018036AC49  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036AC4D  F3 0F 59 D4                     mulss   xmm2, xmm4
000000018036AC51  F3 0F 5C EA                     subss   xmm5, xmm2
000000018036AC55  41 0F 2F EF                     comiss  xmm5, xmm15
000000018036AC59  73 06                           jnb     short loc_18036AC61
000000018036AC5B  41 0F 28 EF                     movaps  xmm5, xmm15
000000018036AC5F  EB 05                           jmp     short loc_18036AC66
000000018036AC61  F3 41 0F 5D ED                  minss   xmm5, xmm13
000000018036AC66  0F 28 CD                        movaps  xmm1, xmm5
000000018036AC69  0F 28 C5                        movaps  xmm0, xmm5
000000018036AC6C  F3 0F 59 83 E0 23 00 00         mulss   xmm0, dword ptr [rbx+23E0h]
000000018036AC74  41 0F 28 E0                     movaps  xmm4, xmm8
000000018036AC78  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036AC7C  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036AC80  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036AC84  F3 0F 59 C8                     mulss   xmm1, xmm0
000000018036AC88  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036AC8C  F3 0F 11 AB 90 20 00 00         movss   dword ptr [rbx+2090h], xmm5
000000018036AC94  0F 28 D5                        movaps  xmm2, xmm5
000000018036AC97  F3 0F 58 AB 20 20 00 00         addss   xmm5, dword ptr [rbx+2020h]
000000018036AC9F  F3 0F 10 9B 30 20 00 00         movss   xmm3, dword ptr [rbx+2030h]
000000018036ACA7  0F 28 C3                        movaps  xmm0, xmm3
000000018036ACAA  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036ACAE  F3 0F 59 E5                     mulss   xmm4, xmm5
000000018036ACB2  41 0F 28 E8                     movaps  xmm5, xmm8
000000018036ACB6  F3 0F 59 EA                     mulss   xmm5, xmm2
000000018036ACBA  41 0F 28 D0                     movaps  xmm2, xmm8
000000018036ACBE  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036ACC2  0F 28 C6                        movaps  xmm0, xmm6
000000018036ACC5  F3 0F 11 A3 A0 20 00 00         movss   dword ptr [rbx+20A0h], xmm4
000000018036ACCD  F3 0F 10 8B 40 20 00 00         movss   xmm1, dword ptr [rbx+2040h]
000000018036ACD5  F3 0F 59 C4                     mulss   xmm0, xmm4
000000018036ACD9  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036ACDD  0F 28 C1                        movaps  xmm0, xmm1
000000018036ACE0  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036ACE4  F3 0F 58 EC                     addss   xmm5, xmm4
000000018036ACE8  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036ACEC  41 0F 28 D8                     movaps  xmm3, xmm8
000000018036ACF0  F3 0F 59 DC                     mulss   xmm3, xmm4
000000018036ACF4  41 0F 28 E0                     movaps  xmm4, xmm8
000000018036ACF8  F3 0F 59 E5                     mulss   xmm4, xmm5
000000018036ACFC  F3 0F 58 D8                     addss   xmm3, xmm0
000000018036AD00  0F 28 C6                        movaps  xmm0, xmm6
000000018036AD03  F3 0F 11 9B B0 20 00 00         movss   dword ptr [rbx+20B0h], xmm3
000000018036AD0B  F3 0F 10 AB 50 20 00 00         movss   xmm5, dword ptr [rbx+2050h]
000000018036AD13  F3 0F 59 C3                     mulss   xmm0, xmm3
000000018036AD17  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036AD1B  0F 28 C5                        movaps  xmm0, xmm5
000000018036AD1E  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036AD22  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036AD26  F3 0F 58 D9                     addss   xmm3, xmm1
000000018036AD2A  41 0F 28 C8                     movaps  xmm1, xmm8
000000018036AD2E  F3 0F 59 CC                     mulss   xmm1, xmm4
000000018036AD32  41 0F 28 E0                     movaps  xmm4, xmm8
000000018036AD36  F3 0F 59 D3                     mulss   xmm2, xmm3
000000018036AD3A  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036AD3E  0F 28 C6                        movaps  xmm0, xmm6
000000018036AD41  F3 0F 11 93 C0 20 00 00         movss   dword ptr [rbx+20C0h], xmm2
000000018036AD49  F3 0F 58 EA                     addss   xmm5, xmm2
000000018036AD4D  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036AD51  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036AD55  F3 41 0F 59 E8                  mulss   xmm5, xmm8
000000018036AD5A  0F 28 C6                        movaps  xmm0, xmm6
000000018036AD5D  F3 0F 59 83 60 20 00 00         mulss   xmm0, dword ptr [rbx+2060h]
000000018036AD65  F3 0F 58 CA                     addss   xmm1, xmm2
000000018036AD69  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036AD6D  0F 28 C6                        movaps  xmm0, xmm6
000000018036AD70  F3 0F 59 E1                     mulss   xmm4, xmm1
000000018036AD74  F3 0F 11 AB D0 20 00 00         movss   dword ptr [rbx+20D0h], xmm5
000000018036AD7C  F3 0F 10 93 C0 20 00 00         movss   xmm2, dword ptr [rbx+20C0h]
000000018036AD84  F3 0F 59 93 80 23 00 00         mulss   xmm2, dword ptr [rbx+2380h]
000000018036AD8C  F3 0F 59 C5                     mulss   xmm0, xmm5
000000018036AD90  F3 0F 59 AB 90 23 00 00         mulss   xmm5, dword ptr [rbx+2390h]
000000018036AD98  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036AD9C  F3 0F 10 83 70 23 00 00         movss   xmm0, dword ptr [rbx+2370h]
000000018036ADA4  F3 0F 59 83 B0 20 00 00         mulss   xmm0, dword ptr [rbx+20B0h]
000000018036ADAC  F3 0F 58 D5                     addss   xmm2, xmm5
000000018036ADB0  F3 0F 10 AB 00 23 00 00         movss   xmm5, dword ptr [rbx+2300h]
000000018036ADB8  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036ADBC  F3 0F 11 93 70 22 00 00         movss   dword ptr [rbx+2270h], xmm2
000000018036ADC4  F3 0F 58 AB F0 22 00 00         addss   xmm5, dword ptr [rbx+22F0h]
000000018036ADCC  F3 0F 10 83 E0 20 00 00         movss   xmm0, dword ptr [rbx+20E0h]
000000018036ADD4  F3 0F 59 AB 20 24 00 00         mulss   xmm5, dword ptr [rbx+2420h]
000000018036ADDC  F3 0F 59 AB 40 23 00 00         mulss   xmm5, dword ptr [rbx+2340h]
000000018036ADE4  F3 0F 11 A3 E0 20 00 00         movss   dword ptr [rbx+20E0h], xmm4
000000018036ADEC  F3 0F 59 A3 30 25 00 00         mulss   xmm4, dword ptr [rbx+2530h]
000000018036ADF4  F3 0F 59 83 40 25 00 00         mulss   xmm0, dword ptr [rbx+2540h]
000000018036ADFC  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036AE00  F3 0F 59 A3 30 23 00 00         mulss   xmm4, dword ptr [rbx+2330h]
000000018036AE08  F3 0F 5C EC                     subss   xmm5, xmm4
000000018036AE0C  41 0F 2F EF                     comiss  xmm5, xmm15
000000018036AE10  73 06                           jnb     short loc_18036AE18
000000018036AE12  41 0F 28 EF                     movaps  xmm5, xmm15
000000018036AE16  EB 05                           jmp     short loc_18036AE1D
000000018036AE18  F3 41 0F 5D ED                  minss   xmm5, xmm13
000000018036AE1D  0F 28 CD                        movaps  xmm1, xmm5
000000018036AE20  0F 28 C5                        movaps  xmm0, xmm5
000000018036AE23  F3 0F 59 83 E0 23 00 00         mulss   xmm0, dword ptr [rbx+23E0h]
000000018036AE2B  41 0F 28 E0                     movaps  xmm4, xmm8
000000018036AE2F  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036AE33  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036AE37  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036AE3B  F3 0F 59 C8                     mulss   xmm1, xmm0
000000018036AE3F  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036AE43  F3 0F 10 8B 90 20 00 00         movss   xmm1, dword ptr [rbx+2090h]
000000018036AE4B  F3 0F 11 AB 90 20 00 00         movss   dword ptr [rbx+2090h], xmm5
000000018036AE53  0F 28 D5                        movaps  xmm2, xmm5
000000018036AE56  F3 0F 10 9B A0 20 00 00         movss   xmm3, dword ptr [rbx+20A0h]
000000018036AE5E  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036AE62  0F 28 C3                        movaps  xmm0, xmm3
000000018036AE65  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036AE69  F3 0F 59 E5                     mulss   xmm4, xmm5
000000018036AE6D  41 0F 28 E8                     movaps  xmm5, xmm8
000000018036AE71  F3 0F 59 EA                     mulss   xmm5, xmm2
000000018036AE75  41 0F 28 D0                     movaps  xmm2, xmm8
000000018036AE79  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036AE7D  0F 28 C6                        movaps  xmm0, xmm6
000000018036AE80  F3 0F 11 A3 A0 20 00 00         movss   dword ptr [rbx+20A0h], xmm4
000000018036AE88  F3 0F 10 8B B0 20 00 00         movss   xmm1, dword ptr [rbx+20B0h]
000000018036AE90  F3 0F 59 C4                     mulss   xmm0, xmm4
000000018036AE94  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036AE98  0F 28 C1                        movaps  xmm0, xmm1
000000018036AE9B  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036AE9F  F3 0F 58 EC                     addss   xmm5, xmm4
000000018036AEA3  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036AEA7  41 0F 28 D8                     movaps  xmm3, xmm8
000000018036AEAB  F3 0F 59 DC                     mulss   xmm3, xmm4
000000018036AEAF  41 0F 28 E0                     movaps  xmm4, xmm8
000000018036AEB3  F3 0F 59 E5                     mulss   xmm4, xmm5
000000018036AEB7  F3 0F 58 D8                     addss   xmm3, xmm0
000000018036AEBB  0F 28 C6                        movaps  xmm0, xmm6
000000018036AEBE  F3 0F 11 9B B0 20 00 00         movss   dword ptr [rbx+20B0h], xmm3
000000018036AEC6  F3 0F 10 AB C0 20 00 00         movss   xmm5, dword ptr [rbx+20C0h]
000000018036AECE  F3 0F 59 C3                     mulss   xmm0, xmm3
000000018036AED2  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036AED6  0F 28 C5                        movaps  xmm0, xmm5
000000018036AED9  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036AEDD  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036AEE1  F3 0F 58 D9                     addss   xmm3, xmm1
000000018036AEE5  41 0F 28 C8                     movaps  xmm1, xmm8
000000018036AEE9  F3 0F 59 CC                     mulss   xmm1, xmm4
000000018036AEED  41 0F 28 E0                     movaps  xmm4, xmm8
000000018036AEF1  F3 0F 59 D3                     mulss   xmm2, xmm3
000000018036AEF5  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036AEF9  0F 28 C6                        movaps  xmm0, xmm6
000000018036AEFC  F3 0F 11 93 C0 20 00 00         movss   dword ptr [rbx+20C0h], xmm2
000000018036AF04  F3 0F 58 EA                     addss   xmm5, xmm2
000000018036AF08  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036AF0C  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036AF10  F3 41 0F 59 E8                  mulss   xmm5, xmm8
000000018036AF15  0F 28 C6                        movaps  xmm0, xmm6
000000018036AF18  F3 0F 59 83 D0 20 00 00         mulss   xmm0, dword ptr [rbx+20D0h]
000000018036AF20  F3 0F 58 CA                     addss   xmm1, xmm2
000000018036AF24  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036AF28  0F 28 C6                        movaps  xmm0, xmm6
000000018036AF2B  F3 0F 59 E1                     mulss   xmm4, xmm1
000000018036AF2F  F3 0F 11 AB D0 20 00 00         movss   dword ptr [rbx+20D0h], xmm5
000000018036AF37  F3 0F 10 93 C0 20 00 00         movss   xmm2, dword ptr [rbx+20C0h]
000000018036AF3F  F3 0F 59 93 80 23 00 00         mulss   xmm2, dword ptr [rbx+2380h]
000000018036AF47  F3 0F 10 8B F0 22 00 00         movss   xmm1, dword ptr [rbx+22F0h]
000000018036AF4F  F3 0F 59 C5                     mulss   xmm0, xmm5
000000018036AF53  F3 0F 59 AB 90 23 00 00         mulss   xmm5, dword ptr [rbx+2390h]
000000018036AF5B  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036AF5F  F3 0F 10 83 70 23 00 00         movss   xmm0, dword ptr [rbx+2370h]
000000018036AF67  F3 0F 59 83 B0 20 00 00         mulss   xmm0, dword ptr [rbx+20B0h]
000000018036AF6F  F3 0F 58 D5                     addss   xmm2, xmm5
000000018036AF73  F3 0F 10 AB 00 23 00 00         movss   xmm5, dword ptr [rbx+2300h]
000000018036AF7B  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036AF7F  F3 0F 11 93 F0 21 00 00         movss   dword ptr [rbx+21F0h], xmm2
000000018036AF87  F3 0F 59 AB 10 24 00 00         mulss   xmm5, dword ptr [rbx+2410h]
000000018036AF8F  F3 0F 59 8B 00 24 00 00         mulss   xmm1, dword ptr [rbx+2400h]
000000018036AF97  F3 0F 10 83 E0 20 00 00         movss   xmm0, dword ptr [rbx+20E0h]
000000018036AF9F  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036AFA3  F3 0F 59 AB 40 23 00 00         mulss   xmm5, dword ptr [rbx+2340h]
000000018036AFAB  F3 0F 11 A3 E0 20 00 00         movss   dword ptr [rbx+20E0h], xmm4
000000018036AFB3  F3 0F 59 A3 30 25 00 00         mulss   xmm4, dword ptr [rbx+2530h]
000000018036AFBB  F3 0F 59 83 40 25 00 00         mulss   xmm0, dword ptr [rbx+2540h]
000000018036AFC3  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036AFC7  F3 0F 59 A3 30 23 00 00         mulss   xmm4, dword ptr [rbx+2330h]
000000018036AFCF  F3 0F 5C EC                     subss   xmm5, xmm4
000000018036AFD3  41 0F 2F EF                     comiss  xmm5, xmm15
000000018036AFD7  73 06                           jnb     short loc_18036AFDF
000000018036AFD9  41 0F 28 EF                     movaps  xmm5, xmm15
000000018036AFDD  EB 05                           jmp     short loc_18036AFE4
000000018036AFDF  F3 41 0F 5D ED                  minss   xmm5, xmm13
000000018036AFE4  0F 28 CD                        movaps  xmm1, xmm5
000000018036AFE7  0F 28 C5                        movaps  xmm0, xmm5
000000018036AFEA  F3 0F 59 83 E0 23 00 00         mulss   xmm0, dword ptr [rbx+23E0h]
000000018036AFF2  41 0F 28 E0                     movaps  xmm4, xmm8
000000018036AFF6  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036AFFA  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036AFFE  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036B002  F3 0F 59 C8                     mulss   xmm1, xmm0
000000018036B006  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036B00A  F3 0F 10 8B 90 20 00 00         movss   xmm1, dword ptr [rbx+2090h]
000000018036B012  F3 0F 11 AB 90 20 00 00         movss   dword ptr [rbx+2090h], xmm5
000000018036B01A  0F 28 D5                        movaps  xmm2, xmm5
000000018036B01D  F3 0F 10 9B A0 20 00 00         movss   xmm3, dword ptr [rbx+20A0h]
000000018036B025  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036B029  0F 28 C3                        movaps  xmm0, xmm3
000000018036B02C  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036B030  F3 0F 59 E5                     mulss   xmm4, xmm5
000000018036B034  41 0F 28 E8                     movaps  xmm5, xmm8
000000018036B038  F3 0F 59 EA                     mulss   xmm5, xmm2
000000018036B03C  41 0F 28 D0                     movaps  xmm2, xmm8
000000018036B040  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B044  0F 28 C6                        movaps  xmm0, xmm6
000000018036B047  F3 0F 11 A3 A0 20 00 00         movss   dword ptr [rbx+20A0h], xmm4
000000018036B04F  F3 0F 10 8B B0 20 00 00         movss   xmm1, dword ptr [rbx+20B0h]
000000018036B057  F3 0F 59 C4                     mulss   xmm0, xmm4
000000018036B05B  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036B05F  0F 28 C1                        movaps  xmm0, xmm1
000000018036B062  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036B066  F3 0F 58 EC                     addss   xmm5, xmm4
000000018036B06A  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036B06E  41 0F 28 D8                     movaps  xmm3, xmm8
000000018036B072  F3 0F 59 DC                     mulss   xmm3, xmm4
000000018036B076  41 0F 28 E0                     movaps  xmm4, xmm8
000000018036B07A  F3 0F 59 E5                     mulss   xmm4, xmm5
000000018036B07E  F3 0F 58 D8                     addss   xmm3, xmm0
000000018036B082  0F 28 C6                        movaps  xmm0, xmm6
000000018036B085  F3 0F 11 9B B0 20 00 00         movss   dword ptr [rbx+20B0h], xmm3
000000018036B08D  F3 0F 10 AB C0 20 00 00         movss   xmm5, dword ptr [rbx+20C0h]
000000018036B095  F3 0F 59 C3                     mulss   xmm0, xmm3
000000018036B099  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B09D  0F 28 C5                        movaps  xmm0, xmm5
000000018036B0A0  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036B0A4  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036B0A8  F3 0F 58 D9                     addss   xmm3, xmm1
000000018036B0AC  41 0F 28 C8                     movaps  xmm1, xmm8
000000018036B0B0  F3 0F 59 CC                     mulss   xmm1, xmm4
000000018036B0B4  F3 0F 59 D3                     mulss   xmm2, xmm3
000000018036B0B8  41 0F 28 D8                     movaps  xmm3, xmm8
000000018036B0BC  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036B0C0  0F 28 C6                        movaps  xmm0, xmm6
000000018036B0C3  F3 0F 11 93 C0 20 00 00         movss   dword ptr [rbx+20C0h], xmm2
000000018036B0CB  F3 0F 58 EA                     addss   xmm5, xmm2
000000018036B0CF  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036B0D3  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036B0D7  F3 41 0F 59 E8                  mulss   xmm5, xmm8
000000018036B0DC  0F 28 C6                        movaps  xmm0, xmm6
000000018036B0DF  F3 0F 59 83 D0 20 00 00         mulss   xmm0, dword ptr [rbx+20D0h]
000000018036B0E7  F3 0F 58 CA                     addss   xmm1, xmm2
000000018036B0EB  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036B0EF  0F 28 C6                        movaps  xmm0, xmm6
000000018036B0F2  F3 0F 59 D9                     mulss   xmm3, xmm1
000000018036B0F6  F3 0F 11 AB D0 20 00 00         movss   dword ptr [rbx+20D0h], xmm5
000000018036B0FE  F3 0F 10 8B C0 20 00 00         movss   xmm1, dword ptr [rbx+20C0h]
000000018036B106  F3 0F 59 8B 80 23 00 00         mulss   xmm1, dword ptr [rbx+2380h]
000000018036B10E  F3 0F 59 C5                     mulss   xmm0, xmm5
000000018036B112  F3 0F 59 AB 90 23 00 00         mulss   xmm5, dword ptr [rbx+2390h]
000000018036B11A  F3 0F 58 D8                     addss   xmm3, xmm0
000000018036B11E  F3 0F 10 83 70 23 00 00         movss   xmm0, dword ptr [rbx+2370h]
000000018036B126  F3 0F 59 83 B0 20 00 00         mulss   xmm0, dword ptr [rbx+20B0h]
000000018036B12E  F3 0F 58 CD                     addss   xmm1, xmm5
000000018036B132  F3 0F 10 AB F0 22 00 00         movss   xmm5, dword ptr [rbx+22F0h]
000000018036B13A  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036B13E  F3 0F 11 8B 70 21 00 00         movss   dword ptr [rbx+2170h], xmm1
000000018036B146  F3 0F 59 AB F0 23 00 00         mulss   xmm5, dword ptr [rbx+23F0h]
000000018036B14E  F3 0F 10 83 E0 20 00 00         movss   xmm0, dword ptr [rbx+20E0h]
000000018036B156  F3 0F 59 AB 40 23 00 00         mulss   xmm5, dword ptr [rbx+2340h]
000000018036B15E  F3 0F 11 9B 70 20 00 00         movss   dword ptr [rbx+2070h], xmm3
000000018036B166  F3 0F 59 9B 30 25 00 00         mulss   xmm3, dword ptr [rbx+2530h]
000000018036B16E  F3 0F 59 83 40 25 00 00         mulss   xmm0, dword ptr [rbx+2540h]
000000018036B176  F3 0F 58 D8                     addss   xmm3, xmm0
000000018036B17A  F3 0F 59 9B 30 23 00 00         mulss   xmm3, dword ptr [rbx+2330h]
000000018036B182  F3 0F 5C EB                     subss   xmm5, xmm3
000000018036B186  41 0F 2F EF                     comiss  xmm5, xmm15
000000018036B18A  73 06                           jnb     short loc_18036B192
000000018036B18C  41 0F 28 EF                     movaps  xmm5, xmm15
000000018036B190  EB 05                           jmp     short loc_18036B197
000000018036B192  F3 41 0F 5D ED                  minss   xmm5, xmm13
000000018036B197  0F 28 CD                        movaps  xmm1, xmm5
000000018036B19A  0F 28 C5                        movaps  xmm0, xmm5
000000018036B19D  F3 0F 59 83 E0 23 00 00         mulss   xmm0, dword ptr [rbx+23E0h]
000000018036B1A5  41 0F 28 E0                     movaps  xmm4, xmm8
000000018036B1A9  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036B1AD  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036B1B1  F3 0F 59 CD                     mulss   xmm1, xmm5
000000018036B1B5  F3 0F 59 C8                     mulss   xmm1, xmm0
000000018036B1B9  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036B1BD  F3 0F 11 AB 10 20 00 00         movss   dword ptr [rbx+2010h], xmm5
000000018036B1C5  0F 28 D5                        movaps  xmm2, xmm5
000000018036B1C8  F3 0F 58 AB 90 20 00 00         addss   xmm5, dword ptr [rbx+2090h]
000000018036B1D0  F3 0F 10 9B A0 20 00 00         movss   xmm3, dword ptr [rbx+20A0h]
000000018036B1D8  0F 28 C3                        movaps  xmm0, xmm3
000000018036B1DB  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036B1DF  F3 0F 59 E5                     mulss   xmm4, xmm5
000000018036B1E3  41 0F 28 E8                     movaps  xmm5, xmm8
000000018036B1E7  F3 0F 59 EA                     mulss   xmm5, xmm2
000000018036B1EB  41 0F 28 D0                     movaps  xmm2, xmm8
000000018036B1EF  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B1F3  0F 28 C6                        movaps  xmm0, xmm6
000000018036B1F6  F3 0F 11 A3 20 20 00 00         movss   dword ptr [rbx+2020h], xmm4
000000018036B1FE  F3 0F 10 8B B0 20 00 00         movss   xmm1, dword ptr [rbx+20B0h]
000000018036B206  F3 0F 59 C4                     mulss   xmm0, xmm4
000000018036B20A  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036B20E  0F 28 C1                        movaps  xmm0, xmm1
000000018036B211  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036B215  F3 0F 58 EC                     addss   xmm5, xmm4
000000018036B219  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036B21D  41 0F 28 D8                     movaps  xmm3, xmm8
000000018036B221  F3 0F 59 DC                     mulss   xmm3, xmm4
000000018036B225  41 0F 28 E0                     movaps  xmm4, xmm8
000000018036B229  F3 0F 59 E5                     mulss   xmm4, xmm5
000000018036B22D  F3 0F 58 D8                     addss   xmm3, xmm0
000000018036B231  0F 28 C6                        movaps  xmm0, xmm6
000000018036B234  F3 0F 11 9B 30 20 00 00         movss   dword ptr [rbx+2030h], xmm3
000000018036B23C  F3 0F 10 AB C0 20 00 00         movss   xmm5, dword ptr [rbx+20C0h]
000000018036B244  F3 0F 59 C3                     mulss   xmm0, xmm3
000000018036B248  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B24C  0F 28 C5                        movaps  xmm0, xmm5
000000018036B24F  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036B253  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036B257  F3 0F 58 D9                     addss   xmm3, xmm1
000000018036B25B  41 0F 28 C8                     movaps  xmm1, xmm8
000000018036B25F  F3 0F 59 CC                     mulss   xmm1, xmm4
000000018036B263  F3 0F 59 D3                     mulss   xmm2, xmm3
000000018036B267  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036B26B  0F 28 C6                        movaps  xmm0, xmm6
000000018036B26E  F3 0F 11 93 40 20 00 00         movss   dword ptr [rbx+2040h], xmm2
000000018036B276  F3 0F 58 EA                     addss   xmm5, xmm2
000000018036B27A  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036B27E  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036B282  F3 41 0F 59 E8                  mulss   xmm5, xmm8
000000018036B287  0F 28 C6                        movaps  xmm0, xmm6
000000018036B28A  F3 0F 59 83 D0 20 00 00         mulss   xmm0, dword ptr [rbx+20D0h]
000000018036B292  F3 0F 58 CA                     addss   xmm1, xmm2
000000018036B296  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036B29A  F3 44 0F 59 C1                  mulss   xmm8, xmm1
000000018036B29F  F3 0F 11 AB 50 20 00 00         movss   dword ptr [rbx+2050h], xmm5
000000018036B2A7  F3 0F 10 9B 30 20 00 00         movss   xmm3, dword ptr [rbx+2030h]
000000018036B2AF  F3 0F 59 F5                     mulss   xmm6, xmm5
000000018036B2B3  F3 44 0F 58 C6                  addss   xmm8, xmm6
000000018036B2B8  F3 44 0F 11 83 60 20 00 00      movss   dword ptr [rbx+2060h], xmm8
000000018036B2C1  F3 0F 10 83 80 23 00 00         movss   xmm0, dword ptr [rbx+2380h]
000000018036B2C9  F3 0F 59 83 40 20 00 00         mulss   xmm0, dword ptr [rbx+2040h]
000000018036B2D1  F3 0F 59 AB 90 23 00 00         mulss   xmm5, dword ptr [rbx+2390h]
000000018036B2D9  F3 0F 59 9B 70 23 00 00         mulss   xmm3, dword ptr [rbx+2370h]
000000018036B2E1  F3 0F 10 A3 30 21 00 00         movss   xmm4, dword ptr [rbx+2130h]
000000018036B2E9  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036B2ED  F3 0F 58 EB                     addss   xmm5, xmm3
000000018036B2F1  F3 0F 11 AB F0 20 00 00         movss   dword ptr [rbx+20F0h], xmm5
000000018036B2F9  F3 0F 58 A3 A0 22 00 00         addss   xmm4, dword ptr [rbx+22A0h]
000000018036B301  F3 0F 10 83 B0 21 00 00         movss   xmm0, dword ptr [rbx+21B0h]
000000018036B309  F3 0F 58 83 20 22 00 00         addss   xmm0, dword ptr [rbx+2220h]
000000018036B311  F3 0F 10 8B 30 22 00 00         movss   xmm1, dword ptr [rbx+2230h]
000000018036B319  F3 0F 58 8B A0 21 00 00         addss   xmm1, dword ptr [rbx+21A0h]
000000018036B321  F3 0F 59 A3 20 25 00 00         mulss   xmm4, dword ptr [rbx+2520h]
000000018036B329  F3 0F 59 83 10 25 00 00         mulss   xmm0, dword ptr [rbx+2510h]
000000018036B331  F3 0F 59 8B 00 25 00 00         mulss   xmm1, dword ptr [rbx+2500h]
000000018036B339  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B33D  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036B341  F3 0F 10 83 20 21 00 00         movss   xmm0, dword ptr [rbx+2120h]
000000018036B349  F3 0F 58 83 B0 22 00 00         addss   xmm0, dword ptr [rbx+22B0h]
000000018036B351  F3 0F 10 8B 90 22 00 00         movss   xmm1, dword ptr [rbx+2290h]
000000018036B359  F3 0F 58 8B 40 21 00 00         addss   xmm1, dword ptr [rbx+2140h]
000000018036B361  F3 0F 58 AB E0 22 00 00         addss   xmm5, dword ptr [rbx+22E0h]
000000018036B369  F3 0F 59 83 F0 24 00 00         mulss   xmm0, dword ptr [rbx+24F0h]
000000018036B371  F3 0F 59 8B E0 24 00 00         mulss   xmm1, dword ptr [rbx+24E0h]
000000018036B379  F3 0F 59 AB 30 24 00 00         mulss   xmm5, dword ptr [rbx+2430h]
000000018036B381  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B385  F3 0F 10 83 10 22 00 00         movss   xmm0, dword ptr [rbx+2210h]
000000018036B38D  F3 0F 58 83 C0 21 00 00         addss   xmm0, dword ptr [rbx+21C0h]
000000018036B395  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036B399  F3 0F 10 8B 40 22 00 00         movss   xmm1, dword ptr [rbx+2240h]
000000018036B3A1  F3 0F 58 8B 90 21 00 00         addss   xmm1, dword ptr [rbx+2190h]
000000018036B3A9  F3 0F 59 83 D0 24 00 00         mulss   xmm0, dword ptr [rbx+24D0h]
000000018036B3B1  F3 0F 59 8B C0 24 00 00         mulss   xmm1, dword ptr [rbx+24C0h]
000000018036B3B9  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B3BD  F3 0F 10 83 C0 22 00 00         movss   xmm0, dword ptr [rbx+22C0h]
000000018036B3C5  F3 0F 58 83 10 21 00 00         addss   xmm0, dword ptr [rbx+2110h]
000000018036B3CD  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036B3D1  F3 0F 10 8B 80 22 00 00         movss   xmm1, dword ptr [rbx+2280h]
000000018036B3D9  F3 0F 59 83 B0 24 00 00         mulss   xmm0, dword ptr [rbx+24B0h]
000000018036B3E1  F3 0F 58 8B 50 21 00 00         addss   xmm1, dword ptr [rbx+2150h]
000000018036B3E9  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B3ED  F3 0F 10 83 00 22 00 00         movss   xmm0, dword ptr [rbx+2200h]
000000018036B3F5  F3 0F 58 83 D0 21 00 00         addss   xmm0, dword ptr [rbx+21D0h]
000000018036B3FD  F3 0F 59 8B A0 24 00 00         mulss   xmm1, dword ptr [rbx+24A0h]
000000018036B405  F3 0F 59 83 90 24 00 00         mulss   xmm0, dword ptr [rbx+2490h]
000000018036B40D  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036B411  F3 0F 10 8B 50 22 00 00         movss   xmm1, dword ptr [rbx+2250h]
000000018036B419  F3 0F 58 8B 80 21 00 00         addss   xmm1, dword ptr [rbx+2180h]
000000018036B421  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B425  F3 0F 10 83 D0 22 00 00         movss   xmm0, dword ptr [rbx+22D0h]
000000018036B42D  F3 0F 59 8B 80 24 00 00         mulss   xmm1, dword ptr [rbx+2480h]
000000018036B435  F3 0F 58 83 00 21 00 00         addss   xmm0, dword ptr [rbx+2100h]
000000018036B43D  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036B441  F3 0F 10 8B 70 22 00 00         movss   xmm1, dword ptr [rbx+2270h]
000000018036B449  F3 0F 58 8B 60 21 00 00         addss   xmm1, dword ptr [rbx+2160h]
000000018036B451  F3 0F 59 83 70 24 00 00         mulss   xmm0, dword ptr [rbx+2470h]
000000018036B459  F3 0F 59 8B 60 24 00 00         mulss   xmm1, dword ptr [rbx+2460h]
000000018036B461  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B465  F3 0F 10 83 F0 21 00 00         movss   xmm0, dword ptr [rbx+21F0h]
000000018036B46D  F3 0F 58 83 E0 21 00 00         addss   xmm0, dword ptr [rbx+21E0h]
000000018036B475  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036B479  F3 0F 10 8B 60 22 00 00         movss   xmm1, dword ptr [rbx+2260h]
000000018036B481  F3 0F 59 83 50 24 00 00         mulss   xmm0, dword ptr [rbx+2450h]
000000018036B489  F3 0F 58 8B 70 21 00 00         addss   xmm1, dword ptr [rbx+2170h]
000000018036B491  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B495  F3 0F 59 8B 40 24 00 00         mulss   xmm1, dword ptr [rbx+2440h]
000000018036B49D  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036B4A1  F3 0F 58 E5                     addss   xmm4, xmm5
000000018036B4A5  F3 0F 59 A3 C0 23 00 00         mulss   xmm4, dword ptr [rbx+23C0h]
000000018036B4AD  F3 0F 11 A3 50 23 00 00         movss   dword ptr [rbx+2350h], xmm4
000000018036B4B5  8B 83 50 25 00 00               mov     eax, [rbx+2550h]
000000018036B4BB  89 83 60 25 00 00               mov     [rbx+2560h], eax
000000018036B4C1  F3 0F 10 83 80 25 00 00         movss   xmm0, dword ptr [rbx+2580h]
000000018036B4C9  8B 83 70 25 00 00               mov     eax, [rbx+2570h]
000000018036B4CF  89 83 A0 25 00 00               mov     [rbx+25A0h], eax
000000018036B4D5  F3 0F 11 83 B0 25 00 00         movss   dword ptr [rbx+25B0h], xmm0
000000018036B4DD  8B 83 90 25 00 00               mov     eax, [rbx+2590h]
000000018036B4E3  89 83 C0 25 00 00               mov     [rbx+25C0h], eax
000000018036B4E9  F3 0F 10 93 D0 25 00 00         movss   xmm2, dword ptr [rbx+25D0h]
000000018036B4F1  F3 0F 11 93 E0 25 00 00         movss   dword ptr [rbx+25E0h], xmm2
000000018036B4F9  F3 0F 10 83 F0 25 00 00         movss   xmm0, dword ptr [rbx+25F0h]
000000018036B501  F3 0F 11 83 00 26 00 00         movss   dword ptr [rbx+2600h], xmm0
000000018036B509  F3 0F 5C D0                     subss   xmm2, xmm0
000000018036B50D  F3 0F 59 93 10 26 00 00         mulss   xmm2, dword ptr [rbx+2610h]
000000018036B515  F3 0F 58 D0                     addss   xmm2, xmm0
000000018036B519  F3 0F 11 93 F0 25 00 00         movss   dword ptr [rbx+25F0h], xmm2
000000018036B521  F3 0F 10 83 B0 25 00 00         movss   xmm0, dword ptr [rbx+25B0h]
000000018036B529  F3 0F 10 8B C0 25 00 00         movss   xmm1, dword ptr [rbx+25C0h]
000000018036B531  F3 0F 59 D0                     mulss   xmm2, xmm0
000000018036B535  F3 0F 59 C1                     mulss   xmm0, xmm1
000000018036B539  F3 0F 5C D0                     subss   xmm2, xmm0
000000018036B53D  F3 0F 58 D1                     addss   xmm2, xmm1
000000018036B541  F3 0F 11 93 20 26 00 00         movss   dword ptr [rbx+2620h], xmm2
000000018036B549  F3 0F 10 8B 30 26 00 00         movss   xmm1, dword ptr [rbx+2630h]
000000018036B551  F3 0F 11 8B 40 26 00 00         movss   dword ptr [rbx+2640h], xmm1
000000018036B559  F3 0F 10 83 50 26 00 00         movss   xmm0, dword ptr [rbx+2650h]
000000018036B561  0F 28 D8                        movaps  xmm3, xmm0
000000018036B564  F3 0F 59 C1                     mulss   xmm0, xmm1
000000018036B568  F3 0F 59 DA                     mulss   xmm3, xmm2
000000018036B56C  F3 0F 5C D8                     subss   xmm3, xmm0
000000018036B570  F3 0F 58 D9                     addss   xmm3, xmm1
000000018036B574  41 0F 2F DE                     comiss  xmm3, xmm14
000000018036B578  76 05                           jbe     short loc_18036B57F
000000018036B57A  0F 5A C3                        cvtps2pd xmm0, xmm3
000000018036B57D  EB 03                           jmp     short loc_18036B582
000000018036B57F  0F 57 C0                        xorps   xmm0, xmm0
000000018036B582  66 0F 5A C0                     cvtpd2ps xmm0, xmm0
000000018036B586  F3 0F 11 83 30 26 00 00         movss   dword ptr [rbx+2630h], xmm0
000000018036B58E  F3 0F 10 8B 60 26 00 00         movss   xmm1, dword ptr [rbx+2660h]
000000018036B596  F3 0F 11 8B 70 26 00 00         movss   dword ptr [rbx+2670h], xmm1
000000018036B59E  F3 0F 10 93 80 26 00 00         movss   xmm2, dword ptr [rbx+2680h]
000000018036B5A6  F3 0F 11 93 90 26 00 00         movss   dword ptr [rbx+2690h], xmm2
000000018036B5AE  F3 0F 10 83 A0 26 00 00         movss   xmm0, dword ptr [rbx+26A0h]
000000018036B5B6  0F 28 D8                        movaps  xmm3, xmm0
000000018036B5B9  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036B5BD  F3 0F 59 D9                     mulss   xmm3, xmm1
000000018036B5C1  F3 0F 5C D8                     subss   xmm3, xmm0
000000018036B5C5  F3 0F 58 DA                     addss   xmm3, xmm2
000000018036B5C9  41 0F 2F DE                     comiss  xmm3, xmm14
000000018036B5CD  76 05                           jbe     short loc_18036B5D4
000000018036B5CF  0F 5A C3                        cvtps2pd xmm0, xmm3
000000018036B5D2  EB 03                           jmp     short loc_18036B5D7
000000018036B5D4  0F 57 C0                        xorps   xmm0, xmm0
000000018036B5D7  66 0F 5A C0                     cvtpd2ps xmm0, xmm0
000000018036B5DB  F3 0F 11 83 80 26 00 00         movss   dword ptr [rbx+2680h], xmm0
000000018036B5E3  F3 0F 10 AB B0 26 00 00         movss   xmm5, dword ptr [rbx+26B0h]
000000018036B5EB  F3 0F 10 B3 30 02 00 00         movss   xmm6, dword ptr [rbx+230h]
000000018036B5F3  0F 28 E5                        movaps  xmm4, xmm5
000000018036B5F6  F3 0F 11 AB C0 26 00 00         movss   dword ptr [rbx+26C0h], xmm5
000000018036B5FE  0F 28 C5                        movaps  xmm0, xmm5
000000018036B601  F3 0F 59 A3 10 27 00 00         mulss   xmm4, dword ptr [rbx+2710h]
000000018036B609  0F 28 DD                        movaps  xmm3, xmm5
000000018036B60C  F3 0F 58 83 E0 26 00 00         addss   xmm0, dword ptr [rbx+26E0h]
000000018036B614  F3 0F 58 9B 00 27 00 00         addss   xmm3, dword ptr [rbx+2700h]
000000018036B61C  41 0F 2F E7                     comiss  xmm4, xmm15
000000018036B620  73 06                           jnb     short loc_18036B628
000000018036B622  41 0F 28 E7                     movaps  xmm4, xmm15
000000018036B626  EB 05                           jmp     short loc_18036B62D
000000018036B628  F3 41 0F 5D E5                  minss   xmm4, xmm13
000000018036B62D  41 0F 2F C6                     comiss  xmm0, xmm14
000000018036B631  72 1B                           jb      short loc_18036B64E
000000018036B633  F3 0F 10 83 F0 26 00 00         movss   xmm0, dword ptr [rbx+26F0h]
000000018036B63B  0F 28 D8                        movaps  xmm3, xmm0
000000018036B63E  F3 0F 59 C5                     mulss   xmm0, xmm5
000000018036B642  F3 0F 59 DE                     mulss   xmm3, xmm6
000000018036B646  F3 0F 5C D8                     subss   xmm3, xmm0
000000018036B64A  F3 0F 58 DD                     addss   xmm3, xmm5
000000018036B64E  41 0F 2E F6                     ucomiss xmm6, xmm14
000000018036B652  F3 0F 10 8B 30 27 00 00         movss   xmm1, dword ptr [rbx+2730h]
000000018036B65A  0F 28 D4                        movaps  xmm2, xmm4
000000018036B65D  F3 0F 59 93 20 27 00 00         mulss   xmm2, dword ptr [rbx+2720h]
000000018036B665  0F 28 C1                        movaps  xmm0, xmm1
000000018036B668  F3 0F 59 C4                     mulss   xmm0, xmm4
000000018036B66C  F3 0F 5C D0                     subss   xmm2, xmm0
000000018036B670  F3 0F 58 D1                     addss   xmm2, xmm1
000000018036B674  0F 28 C2                        movaps  xmm0, xmm2
000000018036B677  F3 0F 59 D5                     mulss   xmm2, xmm5
000000018036B67B  F3 0F 59 C6                     mulss   xmm0, xmm6
000000018036B67F  F3 0F 5C C2                     subss   xmm0, xmm2
000000018036B683  F3 0F 58 C5                     addss   xmm0, xmm5
000000018036B687  74 03                           jz      short loc_18036B68C
000000018036B689  0F 28 C3                        movaps  xmm0, xmm3
000000018036B68C  F3 0F 11 83 D0 26 00 00         movss   dword ptr [rbx+26D0h], xmm0
000000018036B694  F3 0F 11 83 B0 26 00 00         movss   dword ptr [rbx+26B0h], xmm0
000000018036B69C  F3 0F 10 BB 50 23 00 00         movss   xmm7, dword ptr [rbx+2350h]
000000018036B6A4  F3 0F 10 B3 C0 0A 00 00         movss   xmm6, dword ptr [rbx+0AC0h]
000000018036B6AC  F3 0F 10 9B C0 1A 00 00         movss   xmm3, dword ptr [rbx+1AC0h]
000000018036B6B4  F3 0F 10 83 A0 0C 00 00         movss   xmm0, dword ptr [rbx+0CA0h]
000000018036B6BC  F3 0F 10 8B 50 25 00 00         movss   xmm1, dword ptr [rbx+2550h]
000000018036B6C4  8B 83 70 27 00 00               mov     eax, [rbx+2770h]
000000018036B6CA  89 83 80 27 00 00               mov     [rbx+2780h], eax
000000018036B6D0  8B 83 90 27 00 00               mov     eax, [rbx+2790h]
000000018036B6D6  89 83 A0 27 00 00               mov     [rbx+27A0h], eax
000000018036B6DC  F3 0F 11 83 40 27 00 00         movss   dword ptr [rbx+2740h], xmm0
000000018036B6E4  F3 0F 11 8B 50 27 00 00         movss   dword ptr [rbx+2750h], xmm1
000000018036B6EC  F3 0F 59 9B 60 28 00 00         mulss   xmm3, dword ptr [rbx+2860h]
000000018036B6F4  F3 0F 10 A3 80 27 00 00         movss   xmm4, dword ptr [rbx+2780h]
000000018036B6FC  F3 0F 10 93 C0 27 00 00         movss   xmm2, dword ptr [rbx+27C0h]
000000018036B704  F3 0F 11 9B 60 27 00 00         movss   dword ptr [rbx+2760h], xmm3
000000018036B70C  0F 28 DF                        movaps  xmm3, xmm7
000000018036B70F  F3 0F 59 B3 D0 27 00 00         mulss   xmm6, dword ptr [rbx+27D0h]
000000018036B717  F3 0F 5C DC                     subss   xmm3, xmm4
000000018036B71B  F3 0F 59 93 D0 26 00 00         mulss   xmm2, dword ptr [rbx+26D0h]
000000018036B723  F3 0F 10 8B E0 27 00 00         movss   xmm1, dword ptr [rbx+27E0h]
000000018036B72B  0F 28 C3                        movaps  xmm0, xmm3
000000018036B72E  F3 0F 59 83 00 28 00 00         mulss   xmm0, dword ptr [rbx+2800h]
000000018036B736  F3 0F 58 F2                     addss   xmm6, xmm2
000000018036B73A  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B73E  41 0F 28 C5                     movaps  xmm0, xmm13
000000018036B742  F3 0F 11 A3 70 27 00 00         movss   dword ptr [rbx+2770h], xmm4
000000018036B74A  F3 0F 59 8B 40 27 00 00         mulss   xmm1, dword ptr [rbx+2740h]
000000018036B752  F3 0F 10 93 F0 27 00 00         movss   xmm2, dword ptr [rbx+27F0h]
000000018036B75A  F3 0F 59 9B 70 28 00 00         mulss   xmm3, dword ptr [rbx+2870h]
000000018036B762  F3 0F 59 A3 80 28 00 00         mulss   xmm4, dword ptr [rbx+2880h]
000000018036B76A  F3 0F 58 F1                     addss   xmm6, xmm1
000000018036B76E  0F 28 CA                        movaps  xmm1, xmm2
000000018036B771  F3 0F 59 8B 50 27 00 00         mulss   xmm1, dword ptr [rbx+2750h]
000000018036B779  F3 0F 59 D6                     mulss   xmm2, xmm6
000000018036B77D  F3 0F 58 DC                     addss   xmm3, xmm4
000000018036B781  F3 0F 5C CA                     subss   xmm1, xmm2
000000018036B785  F3 0F 58 CE                     addss   xmm1, xmm6
000000018036B789  F3 0F 10 B3 10 28 00 00         movss   xmm6, dword ptr [rbx+2810h]
000000018036B791  F3 0F 5C C6                     subss   xmm0, xmm6
000000018036B795  F3 0F 59 8B 40 28 00 00         mulss   xmm1, dword ptr [rbx+2840h]
000000018036B79D  F3 0F 59 F8                     mulss   xmm7, xmm0
000000018036B7A1  41 0F 2F CE                     comiss  xmm1, xmm14
000000018036B7A5  76 05                           jbe     short loc_18036B7AC
000000018036B7A7  0F 5A C1                        cvtps2pd xmm0, xmm1
000000018036B7AA  EB 03                           jmp     short loc_18036B7AF
000000018036B7AC  0F 57 C0                        xorps   xmm0, xmm0
000000018036B7AF  F3 0F 10 93 30 28 00 00         movss   xmm2, dword ptr [rbx+2830h]
000000018036B7B7  F3 0F 10 A3 20 28 00 00         movss   xmm4, dword ptr [rbx+2820h]
000000018036B7BF  66 0F 5A E8                     cvtpd2ps xmm5, xmm0
000000018036B7C3  F3 0F 10 83 60 27 00 00         movss   xmm0, dword ptr [rbx+2760h]
000000018036B7CB  F3 0F 59 AB 50 28 00 00         mulss   xmm5, dword ptr [rbx+2850h]
000000018036B7D3  F3 41 0F 58 C5                  addss   xmm0, xmm13
000000018036B7D8  F3 0F 59 F3                     mulss   xmm6, xmm3
000000018036B7DC  F3 0F 10 9B A0 27 00 00         movss   xmm3, dword ptr [rbx+27A0h]
000000018036B7E4  F3 0F 58 F7                     addss   xmm6, xmm7
000000018036B7E8  F3 0F 59 F0                     mulss   xmm6, xmm0
000000018036B7EC  F3 0F 10 83 90 28 00 00         movss   xmm0, dword ptr [rbx+2890h]
000000018036B7F4  0F 28 C8                        movaps  xmm1, xmm0
000000018036B7F7  F3 0F 59 C3                     mulss   xmm0, xmm3
000000018036B7FB  F3 0F 59 CE                     mulss   xmm1, xmm6
000000018036B7FF  F3 0F 59 D6                     mulss   xmm2, xmm6
000000018036B803  F3 0F 5C C8                     subss   xmm1, xmm0
000000018036B807  F3 0F 58 D9                     addss   xmm3, xmm1
000000018036B80B  F3 0F 11 9B 90 27 00 00         movss   dword ptr [rbx+2790h], xmm3
000000018036B813  F3 0F 59 E3                     mulss   xmm4, xmm3
000000018036B817  F3 0F 58 E2                     addss   xmm4, xmm2
000000018036B81B  F3 0F 59 E5                     mulss   xmm4, xmm5
000000018036B81F  F3 0F 59 A3 A0 28 00 00         mulss   xmm4, dword ptr [rbx+28A0h]
000000018036B827  F3 0F 11 A3 B0 27 00 00         movss   dword ptr [rbx+27B0h], xmm4
000000018036B82F  8B 83 C0 28 00 00               mov     eax, [rbx+28C0h]
000000018036B835  89 83 D0 28 00 00               mov     [rbx+28D0h], eax
000000018036B83B  8B 83 B0 28 00 00               mov     eax, [rbx+28B0h]
000000018036B841  89 83 C0 28 00 00               mov     [rbx+28C0h], eax
000000018036B847  F3 0F 10 83 D0 28 00 00         movss   xmm0, dword ptr [rbx+28D0h]
000000018036B84F  F3 0F 10 8B E0 28 00 00         movss   xmm1, dword ptr [rbx+28E0h]
000000018036B857  F3 0F 5C E0                     subss   xmm4, xmm0
000000018036B85B  F3 0F 11 A3 B0 28 00 00         movss   dword ptr [rbx+28B0h], xmm4
000000018036B863  F3 0F 59 CC                     mulss   xmm1, xmm4
000000018036B867  F3 0F 58 C8                     addss   xmm1, xmm0
000000018036B86B  F3 0F 11 8B C0 28 00 00         movss   dword ptr [rbx+28C0h], xmm1
000000018036B873  F3 0F 10 93 B0 28 00 00         movss   xmm2, dword ptr [rbx+28B0h]
000000018036B87B  F3 0F 10 B3 A0 25 00 00         movss   xmm6, dword ptr [rbx+25A0h]
000000018036B883  0F 28 C2                        movaps  xmm0, xmm2
000000018036B886  41 0F 2F F6                     comiss  xmm6, xmm14
000000018036B88A  8B 83 10 29 00 00               mov     eax, [rbx+2910h]
000000018036B890  89 83 20 29 00 00               mov     [rbx+2920h], eax
000000018036B896  8B 83 00 29 00 00               mov     eax, [rbx+2900h]
000000018036B89C  89 83 10 29 00 00               mov     [rbx+2910h], eax
000000018036B8A2  8B 83 F0 28 00 00               mov     eax, [rbx+28F0h]
000000018036B8A8  89 83 00 29 00 00               mov     [rbx+2900h], eax
000000018036B8AE  F3 0F 11 93 F0 28 00 00         movss   dword ptr [rbx+28F0h], xmm2
000000018036B8B6  F3 0F 59 83 40 29 00 00         mulss   xmm0, dword ptr [rbx+2940h]
000000018036B8BE  F3 0F 10 A3 00 29 00 00         movss   xmm4, dword ptr [rbx+2900h]
000000018036B8C6  F3 0F 10 8B 60 29 00 00         movss   xmm1, dword ptr [rbx+2960h]
000000018036B8CE  0F 28 EC                        movaps  xmm5, xmm4
000000018036B8D1  F3 0F 59 8B 10 29 00 00         mulss   xmm1, dword ptr [rbx+2910h]
000000018036B8D9  F3 0F 59 AB 50 29 00 00         mulss   xmm5, dword ptr [rbx+2950h]
000000018036B8E1  F3 0F 59 A3 80 29 00 00         mulss   xmm4, dword ptr [rbx+2980h]
000000018036B8E9  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036B8ED  0F 28 C2                        movaps  xmm0, xmm2
000000018036B8F0  F3 0F 59 83 70 29 00 00         mulss   xmm0, dword ptr [rbx+2970h]
000000018036B8F8  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036B8FC  F3 0F 10 8B 90 29 00 00         movss   xmm1, dword ptr [rbx+2990h]
000000018036B904  F3 0F 59 8B 20 29 00 00         mulss   xmm1, dword ptr [rbx+2920h]
000000018036B90C  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036B910  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036B914  76 05                           jbe     short loc_18036B91B
000000018036B916  0F 5A C6                        cvtps2pd xmm0, xmm6
000000018036B919  EB 03                           jmp     short loc_18036B91E
000000018036B91B  0F 57 C0                        xorps   xmm0, xmm0
000000018036B91E  0F 2F 35 9B 9B 77 00            comiss  xmm6, cs:dword_180AE54C0
000000018036B925  66 0F 5A C0                     cvtpd2ps xmm0, xmm0
000000018036B929  F3 0F 11 AB 00 29 00 00         movss   dword ptr [rbx+2900h], xmm5
000000018036B931  0F 28 D8                        movaps  xmm3, xmm0
000000018036B934  F3 0F 11 A3 10 29 00 00         movss   dword ptr [rbx+2910h], xmm4
000000018036B93C  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036B940  F3 0F 59 DD                     mulss   xmm3, xmm5
000000018036B944  F3 0F 5C D8                     subss   xmm3, xmm0
000000018036B948  0F 28 C6                        movaps  xmm0, xmm6
000000018036B94B  41 0F 57 C3                     xorps   xmm0, xmm11
000000018036B94F  F3 0F 58 DA                     addss   xmm3, xmm2
000000018036B953  73 09                           jnb     short loc_18036B95E
000000018036B955  45 0F 57 D2                     xorps   xmm10, xmm10
000000018036B959  F3 44 0F 5A D0                  cvtss2sd xmm10, xmm0
000000018036B95E  41 0F 2F F6                     comiss  xmm6, xmm14
000000018036B962  66 41 0F 5A C2                  cvtpd2ps xmm0, xmm10
000000018036B967  0F 28 C8                        movaps  xmm1, xmm0
000000018036B96A  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036B96E  F3 0F 59 CC                     mulss   xmm1, xmm4
000000018036B972  F3 0F 5C C8                     subss   xmm1, xmm0
000000018036B976  F3 0F 58 D1                     addss   xmm2, xmm1
000000018036B97A  72 03                           jb      short loc_18036B97F
000000018036B97C  0F 28 D3                        movaps  xmm2, xmm3
000000018036B97F  F3 0F 11 93 30 29 00 00         movss   dword ptr [rbx+2930h], xmm2
000000018036B987  F3 0F 59 93 30 26 00 00         mulss   xmm2, dword ptr [rbx+2630h]
000000018036B98F  F3 0F 11 93 A0 29 00 00         movss   dword ptr [rbx+29A0h], xmm2
000000018036B997  F3 0F 59 93 80 26 00 00         mulss   xmm2, dword ptr [rbx+2680h]
000000018036B99F  F3 0F 11 93 B0 29 00 00         movss   dword ptr [rbx+29B0h], xmm2
000000018036B9A7  F3 0F 10 83 60 11 00 00         movss   xmm0, dword ptr [rbx+1160h]
000000018036B9AF  F3 0F 58 83 C0 0E 00 00         addss   xmm0, dword ptr [rbx+0EC0h]
000000018036B9B7  44 0F 5A E0                     cvtps2pd xmm12, xmm0
000000018036B9BB  F2 44 0F 5F 25 E4 F2 61 00      maxsd   xmm12, cs:qword_18098ACA8
000000018036B9C4  F2 44 0F 5D 25 C3 F2 61 00      minsd   xmm12, cs:qword_18098AC90
000000018036B9CD  41 0F 28 CC                     movaps  xmm1, xmm12
000000018036B9D1  41 0F 28 C4                     movaps  xmm0, xmm12
000000018036B9D5  F2 0F 58 05 8B 98 77 00         addsd   xmm0, cs:qword_180AE5268
000000018036B9DD  F2 41 0F 59 CC                  mulsd   xmm1, xmm12
000000018036B9E2  41 0F 28 FC                     movaps  xmm7, xmm12
000000018036B9E6  F2 0F 2C C0                     cvttsd2si eax, xmm0
000000018036B9EA  0F 28 D1                        movaps  xmm2, xmm1
000000018036B9ED  48 63 C8                        movsxd  rcx, eax
000000018036B9F0  F2 41 0F 59 D4                  mulsd   xmm2, xmm12
000000018036B9F5  48 69 C1 D0 00 00 00            imul    rax, rcx, 0D0h
000000018036B9FC  0F 28 DA                        movaps  xmm3, xmm2
000000018036B9FF  F2 41 0F 59 DC                  mulsd   xmm3, xmm12
000000018036BA04  48 8D 0D D5 DA 61 00            lea     rcx, unk_1809894E0
000000018036BA0B  48 03 C1                        add     rax, rcx
000000018036BA0E  0F 28 E3                        movaps  xmm4, xmm3
000000018036BA11  F2 41 0F 59 E4                  mulsd   xmm4, xmm12
000000018036BA16  F2 0F 59 78 10                  mulsd   xmm7, qword ptr [rax+10h]
000000018036BA1B  F2 0F 59 58 40                  mulsd   xmm3, qword ptr [rax+40h]
000000018036BA20  F2 0F 59 48 20                  mulsd   xmm1, qword ptr [rax+20h]
000000018036BA25  0F 28 EC                        movaps  xmm5, xmm4
000000018036BA28  F2 0F 58 38                     addsd   xmm7, qword ptr [rax]
000000018036BA2C  F2 0F 59 50 30                  mulsd   xmm2, qword ptr [rax+30h]
000000018036BA31  F2 0F 59 60 50                  mulsd   xmm4, qword ptr [rax+50h]
000000018036BA36  F2 0F 58 F9                     addsd   xmm7, xmm1
000000018036BA3A  F2 41 0F 59 EC                  mulsd   xmm5, xmm12
000000018036BA3F  F2 0F 58 FA                     addsd   xmm7, xmm2
000000018036BA43  0F 28 F5                        movaps  xmm6, xmm5
000000018036BA46  F2 0F 59 68 60                  mulsd   xmm5, qword ptr [rax+60h]
000000018036BA4B  F2 41 0F 59 F4                  mulsd   xmm6, xmm12
000000018036BA50  F2 0F 58 FB                     addsd   xmm7, xmm3
000000018036BA54  44 0F 28 C6                     movaps  xmm8, xmm6
000000018036BA58  F2 0F 59 70 70                  mulsd   xmm6, qword ptr [rax+70h]
000000018036BA5D  F2 0F 58 FC                     addsd   xmm7, xmm4
000000018036BA61  F2 45 0F 59 C4                  mulsd   xmm8, xmm12
000000018036BA66  F2 0F 58 FD                     addsd   xmm7, xmm5
000000018036BA6A  45 0F 28 C8                     movaps  xmm9, xmm8
000000018036BA6E  F2 44 0F 59 80 80 00 00 00      mulsd   xmm8, qword ptr [rax+80h]
000000018036BA77  F2 45 0F 59 CC                  mulsd   xmm9, xmm12
000000018036BA7C  F2 0F 58 FE                     addsd   xmm7, xmm6
000000018036BA80  45 0F 28 D1                     movaps  xmm10, xmm9
000000018036BA84  F2 44 0F 59 88 90 00 00 00      mulsd   xmm9, qword ptr [rax+90h]
000000018036BA8D  F2 41 0F 58 F8                  addsd   xmm7, xmm8
000000018036BA92  F2 45 0F 59 D4                  mulsd   xmm10, xmm12
000000018036BA97  F2 41 0F 58 F9                  addsd   xmm7, xmm9
000000018036BA9C  45 0F 28 DA                     movaps  xmm11, xmm10
000000018036BAA0  F2 44 0F 59 90 A0 00 00 00      mulsd   xmm10, qword ptr [rax+0A0h]
000000018036BAA9  F2 45 0F 59 DC                  mulsd   xmm11, xmm12
000000018036BAAE  F2 41 0F 58 FA                  addsd   xmm7, xmm10
000000018036BAB3  41 0F 28 C3                     movaps  xmm0, xmm11
000000018036BAB7  F2 45 0F 59 DC                  mulsd   xmm11, xmm12
000000018036BABC  F2 0F 59 80 B0 00 00 00         mulsd   xmm0, qword ptr [rax+0B0h]
000000018036BAC4  F2 44 0F 59 98 C0 00 00 00      mulsd   xmm11, qword ptr [rax+0C0h]
000000018036BACD  F2 0F 58 F8                     addsd   xmm7, xmm0
000000018036BAD1  F2 41 0F 58 FB                  addsd   xmm7, xmm11
000000018036BAD6  66 0F 5A DF                     cvtpd2ps xmm3, xmm7
000000018036BADA  F3 0F 5D 1D B6 F1 61 00         minss   xmm3, cs:dword_18098AC98
000000018036BAE2  F3 0F 5F 1D C6 F1 61 00         maxss   xmm3, cs:dword_18098ACB0
000000018036BAEA  F3 0F 59 9B D0 0E 00 00         mulss   xmm3, dword ptr [rbx+0ED0h]
000000018036BAF2  F3 0F 11 9B 40 11 00 00         movss   dword ptr [rbx+1140h], xmm3
000000018036BAFA  8B 83 E0 12 00 00               mov     eax, [rbx+12E0h]
000000018036BB00  F3 0F 10 AB C0 0E 00 00         movss   xmm5, dword ptr [rbx+0EC0h]
000000018036BB08  F3 0F 10 83 90 10 00 00         movss   xmm0, dword ptr [rbx+1090h]
000000018036BB10  F3 0F 10 8B A0 10 00 00         movss   xmm1, dword ptr [rbx+10A0h]
000000018036BB18  F3 0F 10 93 B0 10 00 00         movss   xmm2, dword ptr [rbx+10B0h]
000000018036BB20  89 83 F0 12 00 00               mov     [rbx+12F0h], eax
000000018036BB26  8B 83 00 13 00 00               mov     eax, [rbx+1300h]
000000018036BB2C  89 83 10 13 00 00               mov     [rbx+1310h], eax
000000018036BB32  8B 83 B0 13 00 00               mov     eax, [rbx+13B0h]
000000018036BB38  89 83 C0 13 00 00               mov     [rbx+13C0h], eax
000000018036BB3E  8B 83 A0 13 00 00               mov     eax, [rbx+13A0h]
000000018036BB44  89 83 B0 13 00 00               mov     [rbx+13B0h], eax
000000018036BB4A  8B 83 90 13 00 00               mov     eax, [rbx+1390h]
000000018036BB50  89 83 A0 13 00 00               mov     [rbx+13A0h], eax
000000018036BB56  8B 83 80 13 00 00               mov     eax, [rbx+1380h]
000000018036BB5C  89 83 90 13 00 00               mov     [rbx+1390h], eax
000000018036BB62  8B 83 70 13 00 00               mov     eax, [rbx+1370h]
000000018036BB68  89 83 80 13 00 00               mov     [rbx+1380h], eax
000000018036BB6E  8B 83 60 13 00 00               mov     eax, [rbx+1360h]
000000018036BB74  89 83 70 13 00 00               mov     [rbx+1370h], eax
000000018036BB7A  8B 83 50 13 00 00               mov     eax, [rbx+1350h]
000000018036BB80  89 83 60 13 00 00               mov     [rbx+1360h], eax
000000018036BB86  8B 83 30 14 00 00               mov     eax, [rbx+1430h]
000000018036BB8C  89 83 40 14 00 00               mov     [rbx+1440h], eax
000000018036BB92  8B 83 20 14 00 00               mov     eax, [rbx+1420h]
000000018036BB98  89 83 30 14 00 00               mov     [rbx+1430h], eax
000000018036BB9E  8B 83 10 14 00 00               mov     eax, [rbx+1410h]
000000018036BBA4  89 83 20 14 00 00               mov     [rbx+1420h], eax
000000018036BBAA  8B 83 00 14 00 00               mov     eax, [rbx+1400h]
000000018036BBB0  89 83 10 14 00 00               mov     [rbx+1410h], eax
000000018036BBB6  8B 83 F0 13 00 00               mov     eax, [rbx+13F0h]
000000018036BBBC  89 83 00 14 00 00               mov     [rbx+1400h], eax
000000018036BBC2  8B 83 E0 13 00 00               mov     eax, [rbx+13E0h]
000000018036BBC8  89 83 F0 13 00 00               mov     [rbx+13F0h], eax
000000018036BBCE  8B 83 D0 13 00 00               mov     eax, [rbx+13D0h]
000000018036BBD4  89 83 E0 13 00 00               mov     [rbx+13E0h], eax
000000018036BBDA  8B 83 B0 14 00 00               mov     eax, [rbx+14B0h]
000000018036BBE0  89 83 C0 14 00 00               mov     [rbx+14C0h], eax
000000018036BBE6  8B 83 A0 14 00 00               mov     eax, [rbx+14A0h]
000000018036BBEC  89 83 B0 14 00 00               mov     [rbx+14B0h], eax
000000018036BBF2  8B 83 90 14 00 00               mov     eax, [rbx+1490h]
000000018036BBF8  89 83 A0 14 00 00               mov     [rbx+14A0h], eax
000000018036BBFE  8B 83 80 14 00 00               mov     eax, [rbx+1480h]
000000018036BC04  89 83 90 14 00 00               mov     [rbx+1490h], eax
000000018036BC0A  8B 83 70 14 00 00               mov     eax, [rbx+1470h]
000000018036BC10  89 83 80 14 00 00               mov     [rbx+1480h], eax
000000018036BC16  8B 83 60 14 00 00               mov     eax, [rbx+1460h]
000000018036BC1C  89 83 70 14 00 00               mov     [rbx+1470h], eax
000000018036BC22  8B 83 50 14 00 00               mov     eax, [rbx+1450h]
000000018036BC28  89 83 60 14 00 00               mov     [rbx+1460h], eax
000000018036BC2E  8B 83 30 15 00 00               mov     eax, [rbx+1530h]
000000018036BC34  89 83 40 15 00 00               mov     [rbx+1540h], eax
000000018036BC3A  8B 83 20 15 00 00               mov     eax, [rbx+1520h]
000000018036BC40  89 83 30 15 00 00               mov     [rbx+1530h], eax
000000018036BC46  8B 83 10 15 00 00               mov     eax, [rbx+1510h]
000000018036BC4C  89 83 20 15 00 00               mov     [rbx+1520h], eax
000000018036BC52  8B 83 00 15 00 00               mov     eax, [rbx+1500h]
000000018036BC58  89 83 10 15 00 00               mov     [rbx+1510h], eax
000000018036BC5E  8B 83 F0 14 00 00               mov     eax, [rbx+14F0h]
000000018036BC64  89 83 00 15 00 00               mov     [rbx+1500h], eax
000000018036BC6A  8B 83 E0 14 00 00               mov     eax, [rbx+14E0h]
000000018036BC70  89 83 F0 14 00 00               mov     [rbx+14F0h], eax
000000018036BC76  8B 83 D0 14 00 00               mov     eax, [rbx+14D0h]
000000018036BC7C  89 83 E0 14 00 00               mov     [rbx+14E0h], eax
000000018036BC82  8B 83 70 15 00 00               mov     eax, [rbx+1570h]
000000018036BC88  89 83 80 15 00 00               mov     [rbx+1580h], eax
000000018036BC8E  8B 83 60 15 00 00               mov     eax, [rbx+1560h]
000000018036BC94  89 83 70 15 00 00               mov     [rbx+1570h], eax
000000018036BC9A  F3 0F 11 83 80 12 00 00         movss   dword ptr [rbx+1280h], xmm0
000000018036BCA2  F3 0F 11 8B 90 12 00 00         movss   dword ptr [rbx+1290h], xmm1
000000018036BCAA  F3 0F 58 AB A0 18 00 00         addss   xmm5, dword ptr [rbx+18A0h]
000000018036BCB2  F3 0F 59 9B A0 15 00 00         mulss   xmm3, dword ptr [rbx+15A0h]
000000018036BCBA  F3 0F 10 83 90 15 00 00         movss   xmm0, dword ptr [rbx+1590h]
000000018036BCC2  F3 0F 11 93 A0 12 00 00         movss   dword ptr [rbx+12A0h], xmm2
000000018036BCCA  F3 0F 10 93 C0 15 00 00         movss   xmm2, dword ptr [rbx+15C0h]
000000018036BCD2  F3 0F 59 AB B0 18 00 00         mulss   xmm5, dword ptr [rbx+18B0h]
000000018036BCDA  F3 0F 5F D3                     maxss   xmm2, xmm3
000000018036BCDE  F3 0F 58 AB 90 18 00 00         addss   xmm5, dword ptr [rbx+1890h]
000000018036BCE6  F3 0F 11 93 B0 12 00 00         movss   dword ptr [rbx+12B0h], xmm2
000000018036BCEE  F3 0F 58 83 E0 0E 00 00         addss   xmm0, dword ptr [rbx+0EE0h]
000000018036BCF6  41 0F 2F EE                     comiss  xmm5, xmm14
000000018036BCFA  F3 0F 11 83 D0 12 00 00         movss   dword ptr [rbx+12D0h], xmm0
000000018036BD02  76 05                           jbe     short loc_18036BD09
000000018036BD04  0F 5A C5                        cvtps2pd xmm0, xmm5
000000018036BD07  EB 03                           jmp     short loc_18036BD0C
000000018036BD09  0F 57 C0                        xorps   xmm0, xmm0
000000018036BD0C  F3 0F 10 0D 48 92 77 00         movss   xmm1, cs:dword_180AE4F5C
000000018036BD14  F3 44 0F 10 15 CB 94 77 00      movss   xmm10, cs:flt_180AE51E8
000000018036BD1D  F3 0F 5E CA                     divss   xmm1, xmm2
000000018036BD21  66 0F 5A C0                     cvtpd2ps xmm0, xmm0
000000018036BD25  F3 0F 11 8B C0 12 00 00         movss   dword ptr [rbx+12C0h], xmm1
000000018036BD2D  F3 0F 11 83 50 15 00 00         movss   dword ptr [rbx+1550h], xmm0
000000018036BD35  F3 0F 10 B3 10 13 00 00         movss   xmm6, dword ptr [rbx+1310h]
000000018036BD3D  F3 0F 10 8B F0 12 00 00         movss   xmm1, dword ptr [rbx+12F0h]
000000018036BD45  F3 0F 11 B3 30 12 00 00         movss   dword ptr [rbx+1230h], xmm6
000000018036BD4D  F3 0F 58 F2                     addss   xmm6, xmm2
000000018036BD51  F3 0F 11 8B 40 12 00 00         movss   dword ptr [rbx+1240h], xmm1
000000018036BD59  41 0F 2F F5                     comiss  xmm6, xmm13
000000018036BD5D  76 1B                           jbe     short loc_18036BD7A
000000018036BD5F  F3 41 0F 58 F5                  addss   xmm6, xmm13
000000018036BD64  41 0F 28 CA                     movaps  xmm1, xmm10; Y
000000018036BD68  0F 28 C6                        movaps  xmm0, xmm6; X
000000018036BD6B  E8 68 37 38 00                  call    fmodf
000000018036BD70  0F 28 F0                        movaps  xmm6, xmm0
000000018036BD73  F3 41 0F 5C F5                  subss   xmm6, xmm13
000000018036BD78  EB 1F                           jmp     short loc_18036BD99
000000018036BD7A  41 0F 2F F7                     comiss  xmm6, xmm15
000000018036BD7E  73 19                           jnb     short loc_18036BD99
000000018036BD80  F3 41 0F 5C F5                  subss   xmm6, xmm13
000000018036BD85  41 0F 28 CA                     movaps  xmm1, xmm10; Y
000000018036BD89  0F 28 C6                        movaps  xmm0, xmm6; X
000000018036BD8C  E8 47 37 38 00                  call    fmodf
000000018036BD91  0F 28 F0                        movaps  xmm6, xmm0
000000018036BD94  F3 41 0F 58 F5                  addss   xmm6, xmm13
000000018036BD99  F3 44 0F 10 25 6A 92 77 00      movss   xmm12, cs:dword_180AE500C
000000018036BDA2  0F 28 C6                        movaps  xmm0, xmm6
000000018036BDA5  F3 41 0F 58 C5                  addss   xmm0, xmm13
000000018036BDAA  F3 0F 11 B3 20 12 00 00         movss   dword ptr [rbx+1220h], xmm6
000000018036BDB2  0F 28 FE                        movaps  xmm7, xmm6
000000018036BDB5  F3 0F 59 BB 10 16 00 00         mulss   xmm7, dword ptr [rbx+1610h]
000000018036BDBD  F3 41 0F 59 C4                  mulss   xmm0, xmm12
000000018036BDC2  E8 F9 D1 FF FF                  call    sub_180368FC0
000000018036BDC7  F3 44 0F 10 1D 74 96 77 00      movss   xmm11, cs:dword_180AE5444
000000018036BDD0  0F 28 E8                        movaps  xmm5, xmm0
000000018036BDD3  F3 41 0F 59 EB                  mulss   xmm5, xmm11
000000018036BDD8  F3 0F 59 AB C0 12 00 00         mulss   xmm5, dword ptr [rbx+12C0h]
000000018036BDE0  F3 0F 59 AB E0 15 00 00         mulss   xmm5, dword ptr [rbx+15E0h]
000000018036BDE8  41 0F 2F EF                     comiss  xmm5, xmm15
000000018036BDEC  73 06                           jnb     short loc_18036BDF4
000000018036BDEE  41 0F 28 EF                     movaps  xmm5, xmm15
000000018036BDF2  EB 05                           jmp     short loc_18036BDF9
000000018036BDF4  F3 41 0F 5D ED                  minss   xmm5, xmm13
000000018036BDF9  F3 0F 59 AB B0 15 00 00         mulss   xmm5, dword ptr [rbx+15B0h]
000000018036BE01  0F 28 D5                        movaps  xmm2, xmm5
000000018036BE04  F3 0F 59 D5                     mulss   xmm2, xmm5
000000018036BE08  0F 28 CA                        movaps  xmm1, xmm2
000000018036BE0B  0F 28 C2                        movaps  xmm0, xmm2
000000018036BE0E  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036BE16  0F 28 DA                        movaps  xmm3, xmm2
000000018036BE19  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036BE1D  0F 28 E2                        movaps  xmm4, xmm2
000000018036BE20  F3 0F 59 A3 80 17 00 00         mulss   xmm4, dword ptr [rbx+1780h]
000000018036BE28  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036BE30  F3 0F 59 DD                     mulss   xmm3, xmm5
000000018036BE34  F3 0F 58 A3 70 17 00 00         addss   xmm4, dword ptr [rbx+1770h]
000000018036BE3C  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036BE40  0F 28 C3                        movaps  xmm0, xmm3
000000018036BE43  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036BE4B  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036BE4F  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036BE53  F3 0F 10 8B D0 12 00 00         movss   xmm1, dword ptr [rbx+12D0h]
000000018036BE5B  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036BE5F  0F 28 C1                        movaps  xmm0, xmm1
000000018036BE62  F3 0F 58 C6                     addss   xmm0, xmm6
000000018036BE66  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036BE6A  41 0F 2F C6                     comiss  xmm0, xmm14
000000018036BE6E  F3 0F 58 E5                     addss   xmm4, xmm5
000000018036BE72  F3 0F 59 E7                     mulss   xmm4, xmm7
000000018036BE76  F3 0F 11 A3 20 13 00 00         movss   dword ptr [rbx+1320h], xmm4
000000018036BE7E  72 07                           jb      short loc_18036BE87
000000018036BE80  F3 41 0F 58 CD                  addss   xmm1, xmm13
000000018036BE85  EB 05                           jmp     short loc_18036BE8C
000000018036BE87  F3 41 0F 5C CD                  subss   xmm1, xmm13
000000018036BE8C  0F 28 F0                        movaps  xmm6, xmm0
000000018036BE8F  73 06                           jnb     short loc_18036BE97
000000018036BE91  41 0F 28 F7                     movaps  xmm6, xmm15
000000018036BE95  EB 06                           jmp     short loc_18036BE9D
000000018036BE97  76 04                           jbe     short loc_18036BE9D
000000018036BE99  41 0F 28 F5                     movaps  xmm6, xmm13
000000018036BE9D  F3 44 0F 10 83 20 12 00 00      movss   xmm8, dword ptr [rbx+1220h]
000000018036BEA6  F3 0F 59 B3 20 16 00 00         mulss   xmm6, dword ptr [rbx+1620h]
000000018036BEAE  F3 0F 5E C1                     divss   xmm0, xmm1
000000018036BEB2  E8 09 D1 FF FF                  call    sub_180368FC0
000000018036BEB7  0F 28 E0                        movaps  xmm4, xmm0
000000018036BEBA  F3 0F 10 83 D0 15 00 00         movss   xmm0, dword ptr [rbx+15D0h]
000000018036BEC2  44 0F 2F C0                     comiss  xmm8, xmm0
000000018036BEC6  72 18                           jb      short loc_18036BEE0
000000018036BEC8  0F 2F 83 30 12 00 00            comiss  xmm0, dword ptr [rbx+1230h]
000000018036BECF  76 0F                           jbe     short loc_18036BEE0
000000018036BED1  F3 0F 10 BB 40 12 00 00         movss   xmm7, dword ptr [rbx+1240h]
000000018036BED9  F3 41 0F 58 FA                  addss   xmm7, xmm10
000000018036BEDE  EB 08                           jmp     short loc_18036BEE8
000000018036BEE0  F3 0F 10 BB 40 12 00 00         movss   xmm7, dword ptr [rbx+1240h]
000000018036BEE8  0F 2F 3D E1 93 77 00            comiss  xmm7, cs:dword_180AE52D0
000000018036BEEF  F3 0F 59 A3 C0 12 00 00         mulss   xmm4, dword ptr [rbx+12C0h]
000000018036BEF7  F3 41 0F 59 E3                  mulss   xmm4, xmm11
000000018036BEFC  F3 0F 59 A3 F0 15 00 00         mulss   xmm4, dword ptr [rbx+15F0h]
000000018036BF04  72 03                           jb      short loc_18036BF09
000000018036BF06  0F 57 FF                        xorps   xmm7, xmm7
000000018036BF09  41 0F 2F E7                     comiss  xmm4, xmm15
000000018036BF0D  73 06                           jnb     short loc_18036BF15
000000018036BF0F  41 0F 28 E7                     movaps  xmm4, xmm15
000000018036BF13  EB 05                           jmp     short loc_18036BF1A
000000018036BF15  F3 41 0F 5D E5                  minss   xmm4, xmm13
000000018036BF1A  F3 0F 11 BB 40 12 00 00         movss   dword ptr [rbx+1240h], xmm7
000000018036BF22  F3 41 0F 58 F8                  addss   xmm7, xmm8
000000018036BF27  F3 0F 59 A3 B0 15 00 00         mulss   xmm4, dword ptr [rbx+15B0h]
000000018036BF2F  0F 28 D4                        movaps  xmm2, xmm4
000000018036BF32  F3 41 0F 58 FD                  addss   xmm7, xmm13
000000018036BF37  F3 0F 59 D4                     mulss   xmm2, xmm4
000000018036BF3B  0F 28 C2                        movaps  xmm0, xmm2
000000018036BF3E  F3 41 0F 59 FC                  mulss   xmm7, xmm12
000000018036BF43  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036BF47  0F 28 DA                        movaps  xmm3, xmm2
000000018036BF4A  F3 0F 59 DC                     mulss   xmm3, xmm4
000000018036BF4E  44 0F 28 CA                     movaps  xmm9, xmm2
000000018036BF52  F3 44 0F 59 8B 80 17 00 00      mulss   xmm9, dword ptr [rbx+1780h]
000000018036BF5B  F3 41 0F 5C FD                  subss   xmm7, xmm13
000000018036BF60  0F 28 CA                        movaps  xmm1, xmm2
000000018036BF63  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036BF6B  F3 44 0F 58 8B 70 17 00 00      addss   xmm9, dword ptr [rbx+1770h]
000000018036BF74  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036BF7C  F3 44 0F 59 C8                  mulss   xmm9, xmm0
000000018036BF81  0F 28 C3                        movaps  xmm0, xmm3
000000018036BF84  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036BF8C  F3 44 0F 58 C9                  addss   xmm9, xmm1
000000018036BF91  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036BF95  F3 44 0F 59 C8                  mulss   xmm9, xmm0
000000018036BF9A  0F 28 C7                        movaps  xmm0, xmm7
000000018036BF9D  0F 54 05 EC 97 77 00            andps   xmm0, cs:xmmword_180AE5790
000000018036BFA4  0F 57 05 15 98 77 00            xorps   xmm0, cs:xmmword_180AE57C0
000000018036BFAB  F3 44 0F 58 CB                  addss   xmm9, xmm3
000000018036BFB0  F3 44 0F 58 CC                  addss   xmm9, xmm4
000000018036BFB5  F3 44 0F 59 CE                  mulss   xmm9, xmm6
000000018036BFBA  F3 44 0F 11 8B 30 13 00 00      movss   dword ptr [rbx+1330h], xmm9
000000018036BFC3  E8 F8 CF FF FF                  call    sub_180368FC0
000000018036BFC8  41 0F 2F FE                     comiss  xmm7, xmm14
000000018036BFCC  44 0F 28 C0                     movaps  xmm8, xmm0
000000018036BFD0  F3 45 0F 58 C5                  addss   xmm8, xmm13
000000018036BFD5  73 06                           jnb     short loc_18036BFDD
000000018036BFD7  41 0F 28 FF                     movaps  xmm7, xmm15
000000018036BFDB  EB 06                           jmp     short loc_18036BFE3
000000018036BFDD  76 04                           jbe     short loc_18036BFE3
000000018036BFDF  41 0F 28 FD                     movaps  xmm7, xmm13
000000018036BFE3  F3 44 0F 59 83 C0 12 00 00      mulss   xmm8, dword ptr [rbx+12C0h]
000000018036BFEC  F3 0F 59 BB 30 16 00 00         mulss   xmm7, dword ptr [rbx+1630h]
000000018036BFF4  F3 44 0F 59 05 9B EC 61 00      mulss   xmm8, cs:dword_18098AC98
000000018036BFFD  F3 44 0F 59 83 00 16 00 00      mulss   xmm8, dword ptr [rbx+1600h]
000000018036C006  45 0F 2F C7                     comiss  xmm8, xmm15
000000018036C00A  73 06                           jnb     short loc_18036C012
000000018036C00C  45 0F 28 C7                     movaps  xmm8, xmm15
000000018036C010  EB 05                           jmp     short loc_18036C017
000000018036C012  F3 45 0F 5D C5                  minss   xmm8, xmm13
000000018036C017  F3 44 0F 59 83 B0 15 00 00      mulss   xmm8, dword ptr [rbx+15B0h]
000000018036C020  F3 44 0F 59 8B 90 12 00 00      mulss   xmm9, dword ptr [rbx+1290h]
000000018036C029  F3 0F 10 B3 20 12 00 00         movss   xmm6, dword ptr [rbx+1220h]
000000018036C031  41 0F 28 D0                     movaps  xmm2, xmm8
000000018036C035  F3 0F 10 AB 40 12 00 00         movss   xmm5, dword ptr [rbx+1240h]
000000018036C03D  F3 41 0F 59 D0                  mulss   xmm2, xmm8
000000018036C042  0F 28 C2                        movaps  xmm0, xmm2
000000018036C045  0F 28 DA                        movaps  xmm3, xmm2
000000018036C048  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C04C  0F 28 E2                        movaps  xmm4, xmm2
000000018036C04F  F3 0F 59 A3 80 17 00 00         mulss   xmm4, dword ptr [rbx+1780h]
000000018036C057  0F 28 CA                        movaps  xmm1, xmm2
000000018036C05A  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036C062  F3 0F 58 A3 70 17 00 00         addss   xmm4, dword ptr [rbx+1770h]
000000018036C06A  F3 41 0F 59 D8                  mulss   xmm3, xmm8
000000018036C06F  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036C077  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C07B  0F 28 C3                        movaps  xmm0, xmm3
000000018036C07E  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036C086  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036C08A  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C08E  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C092  F3 0F 10 83 20 13 00 00         movss   xmm0, dword ptr [rbx+1320h]
000000018036C09A  F3 0F 59 83 80 12 00 00         mulss   xmm0, dword ptr [rbx+1280h]
000000018036C0A2  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036C0A6  F3 41 0F 58 C1                  addss   xmm0, xmm9
000000018036C0AB  F3 41 0F 58 E0                  addss   xmm4, xmm8
000000018036C0B0  F3 0F 59 E7                     mulss   xmm4, xmm7
000000018036C0B4  F3 0F 59 A3 A0 12 00 00         mulss   xmm4, dword ptr [rbx+12A0h]
000000018036C0BC  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036C0C0  F3 0F 11 A3 50 13 00 00         movss   dword ptr [rbx+1350h], xmm4
000000018036C0C8  F3 0F 11 B3 30 12 00 00         movss   dword ptr [rbx+1230h], xmm6
000000018036C0D0  F3 0F 11 AB 40 12 00 00         movss   dword ptr [rbx+1240h], xmm5
000000018036C0D8  F3 0F 58 B3 B0 12 00 00         addss   xmm6, dword ptr [rbx+12B0h]
000000018036C0E0  41 0F 2F F5                     comiss  xmm6, xmm13
000000018036C0E4  76 1B                           jbe     short loc_18036C101
000000018036C0E6  F3 41 0F 58 F5                  addss   xmm6, xmm13
000000018036C0EB  41 0F 28 CA                     movaps  xmm1, xmm10; Y
000000018036C0EF  0F 28 C6                        movaps  xmm0, xmm6; X
000000018036C0F2  E8 E1 33 38 00                  call    fmodf
000000018036C0F7  0F 28 F0                        movaps  xmm6, xmm0
000000018036C0FA  F3 41 0F 5C F5                  subss   xmm6, xmm13
000000018036C0FF  EB 1F                           jmp     short loc_18036C120
000000018036C101  41 0F 2F F7                     comiss  xmm6, xmm15
000000018036C105  73 19                           jnb     short loc_18036C120
000000018036C107  F3 41 0F 5C F5                  subss   xmm6, xmm13
000000018036C10C  41 0F 28 CA                     movaps  xmm1, xmm10; Y
000000018036C110  0F 28 C6                        movaps  xmm0, xmm6; X
000000018036C113  E8 C0 33 38 00                  call    fmodf
000000018036C118  0F 28 F0                        movaps  xmm6, xmm0
000000018036C11B  F3 41 0F 58 F5                  addss   xmm6, xmm13
000000018036C120  0F 28 C6                        movaps  xmm0, xmm6
000000018036C123  F3 0F 11 B3 20 12 00 00         movss   dword ptr [rbx+1220h], xmm6
000000018036C12B  F3 41 0F 58 C5                  addss   xmm0, xmm13
000000018036C130  0F 28 FE                        movaps  xmm7, xmm6
000000018036C133  F3 0F 59 BB 10 16 00 00         mulss   xmm7, dword ptr [rbx+1610h]
000000018036C13B  F3 41 0F 59 C4                  mulss   xmm0, xmm12
000000018036C140  E8 7B CE FF FF                  call    sub_180368FC0
000000018036C145  0F 28 E8                        movaps  xmm5, xmm0
000000018036C148  F3 41 0F 59 EB                  mulss   xmm5, xmm11
000000018036C14D  F3 0F 59 AB C0 12 00 00         mulss   xmm5, dword ptr [rbx+12C0h]
000000018036C155  F3 0F 59 AB E0 15 00 00         mulss   xmm5, dword ptr [rbx+15E0h]
000000018036C15D  41 0F 2F EF                     comiss  xmm5, xmm15
000000018036C161  73 06                           jnb     short loc_18036C169
000000018036C163  41 0F 28 EF                     movaps  xmm5, xmm15
000000018036C167  EB 05                           jmp     short loc_18036C16E
000000018036C169  F3 41 0F 5D ED                  minss   xmm5, xmm13
000000018036C16E  F3 0F 59 AB B0 15 00 00         mulss   xmm5, dword ptr [rbx+15B0h]
000000018036C176  0F 28 D5                        movaps  xmm2, xmm5
000000018036C179  F3 0F 59 D5                     mulss   xmm2, xmm5
000000018036C17D  0F 28 CA                        movaps  xmm1, xmm2
000000018036C180  0F 28 C2                        movaps  xmm0, xmm2
000000018036C183  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036C18B  0F 28 DA                        movaps  xmm3, xmm2
000000018036C18E  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C192  0F 28 E2                        movaps  xmm4, xmm2
000000018036C195  F3 0F 59 A3 80 17 00 00         mulss   xmm4, dword ptr [rbx+1780h]
000000018036C19D  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036C1A5  F3 0F 59 DD                     mulss   xmm3, xmm5
000000018036C1A9  F3 0F 58 A3 70 17 00 00         addss   xmm4, dword ptr [rbx+1770h]
000000018036C1B1  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C1B5  0F 28 C3                        movaps  xmm0, xmm3
000000018036C1B8  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036C1C0  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036C1C4  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C1C8  F3 0F 10 8B D0 12 00 00         movss   xmm1, dword ptr [rbx+12D0h]
000000018036C1D0  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C1D4  0F 28 C1                        movaps  xmm0, xmm1
000000018036C1D7  F3 0F 58 C6                     addss   xmm0, xmm6
000000018036C1DB  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036C1DF  41 0F 2F C6                     comiss  xmm0, xmm14
000000018036C1E3  F3 0F 58 E5                     addss   xmm4, xmm5
000000018036C1E7  F3 0F 59 E7                     mulss   xmm4, xmm7
000000018036C1EB  F3 0F 11 A3 20 13 00 00         movss   dword ptr [rbx+1320h], xmm4
000000018036C1F3  72 07                           jb      short loc_18036C1FC
000000018036C1F5  F3 41 0F 58 CD                  addss   xmm1, xmm13
000000018036C1FA  EB 05                           jmp     short loc_18036C201
000000018036C1FC  F3 41 0F 5C CD                  subss   xmm1, xmm13
000000018036C201  0F 28 F0                        movaps  xmm6, xmm0
000000018036C204  73 06                           jnb     short loc_18036C20C
000000018036C206  41 0F 28 F7                     movaps  xmm6, xmm15
000000018036C20A  EB 06                           jmp     short loc_18036C212
000000018036C20C  76 04                           jbe     short loc_18036C212
000000018036C20E  41 0F 28 F5                     movaps  xmm6, xmm13
000000018036C212  F3 44 0F 10 83 20 12 00 00      movss   xmm8, dword ptr [rbx+1220h]
000000018036C21B  F3 0F 59 B3 20 16 00 00         mulss   xmm6, dword ptr [rbx+1620h]
000000018036C223  F3 0F 5E C1                     divss   xmm0, xmm1
000000018036C227  E8 94 CD FF FF                  call    sub_180368FC0
000000018036C22C  0F 28 E0                        movaps  xmm4, xmm0
000000018036C22F  F3 0F 10 83 D0 15 00 00         movss   xmm0, dword ptr [rbx+15D0h]
000000018036C237  44 0F 2F C0                     comiss  xmm8, xmm0
000000018036C23B  72 18                           jb      short loc_18036C255
000000018036C23D  0F 2F 83 30 12 00 00            comiss  xmm0, dword ptr [rbx+1230h]
000000018036C244  76 0F                           jbe     short loc_18036C255
000000018036C246  F3 0F 10 BB 40 12 00 00         movss   xmm7, dword ptr [rbx+1240h]
000000018036C24E  F3 41 0F 58 FA                  addss   xmm7, xmm10
000000018036C253  EB 08                           jmp     short loc_18036C25D
000000018036C255  F3 0F 10 BB 40 12 00 00         movss   xmm7, dword ptr [rbx+1240h]
000000018036C25D  0F 2F 3D 6C 90 77 00            comiss  xmm7, cs:dword_180AE52D0
000000018036C264  F3 0F 59 A3 C0 12 00 00         mulss   xmm4, dword ptr [rbx+12C0h]
000000018036C26C  F3 41 0F 59 E3                  mulss   xmm4, xmm11
000000018036C271  F3 0F 59 A3 F0 15 00 00         mulss   xmm4, dword ptr [rbx+15F0h]
000000018036C279  72 03                           jb      short loc_18036C27E
000000018036C27B  0F 57 FF                        xorps   xmm7, xmm7
000000018036C27E  41 0F 2F E7                     comiss  xmm4, xmm15
000000018036C282  73 06                           jnb     short loc_18036C28A
000000018036C284  41 0F 28 E7                     movaps  xmm4, xmm15
000000018036C288  EB 05                           jmp     short loc_18036C28F
000000018036C28A  F3 41 0F 5D E5                  minss   xmm4, xmm13
000000018036C28F  F3 0F 11 BB 40 12 00 00         movss   dword ptr [rbx+1240h], xmm7
000000018036C297  F3 41 0F 58 F8                  addss   xmm7, xmm8
000000018036C29C  F3 0F 59 A3 B0 15 00 00         mulss   xmm4, dword ptr [rbx+15B0h]
000000018036C2A4  0F 28 D4                        movaps  xmm2, xmm4
000000018036C2A7  F3 41 0F 58 FD                  addss   xmm7, xmm13
000000018036C2AC  F3 0F 59 D4                     mulss   xmm2, xmm4
000000018036C2B0  0F 28 C2                        movaps  xmm0, xmm2
000000018036C2B3  F3 41 0F 59 FC                  mulss   xmm7, xmm12
000000018036C2B8  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C2BC  0F 28 DA                        movaps  xmm3, xmm2
000000018036C2BF  F3 0F 59 DC                     mulss   xmm3, xmm4
000000018036C2C3  44 0F 28 CA                     movaps  xmm9, xmm2
000000018036C2C7  F3 44 0F 59 8B 80 17 00 00      mulss   xmm9, dword ptr [rbx+1780h]
000000018036C2D0  F3 41 0F 5C FD                  subss   xmm7, xmm13
000000018036C2D5  0F 28 CA                        movaps  xmm1, xmm2
000000018036C2D8  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036C2E0  F3 44 0F 58 8B 70 17 00 00      addss   xmm9, dword ptr [rbx+1770h]
000000018036C2E9  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036C2F1  F3 44 0F 59 C8                  mulss   xmm9, xmm0
000000018036C2F6  0F 28 C3                        movaps  xmm0, xmm3
000000018036C2F9  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036C301  F3 44 0F 58 C9                  addss   xmm9, xmm1
000000018036C306  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C30A  F3 44 0F 59 C8                  mulss   xmm9, xmm0
000000018036C30F  0F 28 C7                        movaps  xmm0, xmm7
000000018036C312  0F 54 05 77 94 77 00            andps   xmm0, cs:xmmword_180AE5790
000000018036C319  0F 57 05 A0 94 77 00            xorps   xmm0, cs:xmmword_180AE57C0
000000018036C320  F3 44 0F 58 CB                  addss   xmm9, xmm3
000000018036C325  F3 44 0F 58 CC                  addss   xmm9, xmm4
000000018036C32A  F3 44 0F 59 CE                  mulss   xmm9, xmm6
000000018036C32F  F3 44 0F 11 8B 30 13 00 00      movss   dword ptr [rbx+1330h], xmm9
000000018036C338  E8 83 CC FF FF                  call    sub_180368FC0
000000018036C33D  41 0F 2F FE                     comiss  xmm7, xmm14
000000018036C341  44 0F 28 C0                     movaps  xmm8, xmm0
000000018036C345  F3 45 0F 58 C5                  addss   xmm8, xmm13
000000018036C34A  73 06                           jnb     short loc_18036C352
000000018036C34C  41 0F 28 FF                     movaps  xmm7, xmm15
000000018036C350  EB 06                           jmp     short loc_18036C358
000000018036C352  76 04                           jbe     short loc_18036C358
000000018036C354  41 0F 28 FD                     movaps  xmm7, xmm13
000000018036C358  F3 44 0F 59 83 C0 12 00 00      mulss   xmm8, dword ptr [rbx+12C0h]
000000018036C361  F3 0F 59 BB 30 16 00 00         mulss   xmm7, dword ptr [rbx+1630h]
000000018036C369  F3 44 0F 59 05 26 E9 61 00      mulss   xmm8, cs:dword_18098AC98
000000018036C372  F3 44 0F 59 83 00 16 00 00      mulss   xmm8, dword ptr [rbx+1600h]
000000018036C37B  45 0F 2F C7                     comiss  xmm8, xmm15
000000018036C37F  73 06                           jnb     short loc_18036C387
000000018036C381  45 0F 28 C7                     movaps  xmm8, xmm15
000000018036C385  EB 05                           jmp     short loc_18036C38C
000000018036C387  F3 45 0F 5D C5                  minss   xmm8, xmm13
000000018036C38C  F3 44 0F 59 83 B0 15 00 00      mulss   xmm8, dword ptr [rbx+15B0h]
000000018036C395  F3 44 0F 59 8B 90 12 00 00      mulss   xmm9, dword ptr [rbx+1290h]
000000018036C39E  F3 0F 10 B3 20 12 00 00         movss   xmm6, dword ptr [rbx+1220h]
000000018036C3A6  41 0F 28 D0                     movaps  xmm2, xmm8
000000018036C3AA  F3 0F 10 AB 40 12 00 00         movss   xmm5, dword ptr [rbx+1240h]
000000018036C3B2  F3 41 0F 59 D0                  mulss   xmm2, xmm8
000000018036C3B7  0F 28 C2                        movaps  xmm0, xmm2
000000018036C3BA  0F 28 DA                        movaps  xmm3, xmm2
000000018036C3BD  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C3C1  0F 28 E2                        movaps  xmm4, xmm2
000000018036C3C4  F3 0F 59 A3 80 17 00 00         mulss   xmm4, dword ptr [rbx+1780h]
000000018036C3CC  0F 28 CA                        movaps  xmm1, xmm2
000000018036C3CF  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036C3D7  F3 0F 58 A3 70 17 00 00         addss   xmm4, dword ptr [rbx+1770h]
000000018036C3DF  F3 41 0F 59 D8                  mulss   xmm3, xmm8
000000018036C3E4  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036C3EC  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C3F0  0F 28 C3                        movaps  xmm0, xmm3
000000018036C3F3  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036C3FB  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036C3FF  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C403  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C407  F3 0F 10 83 20 13 00 00         movss   xmm0, dword ptr [rbx+1320h]
000000018036C40F  F3 0F 59 83 80 12 00 00         mulss   xmm0, dword ptr [rbx+1280h]
000000018036C417  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036C41B  F3 41 0F 58 C1                  addss   xmm0, xmm9
000000018036C420  F3 41 0F 58 E0                  addss   xmm4, xmm8
000000018036C425  F3 0F 59 E7                     mulss   xmm4, xmm7
000000018036C429  F3 0F 59 A3 A0 12 00 00         mulss   xmm4, dword ptr [rbx+12A0h]
000000018036C431  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036C435  F3 0F 11 A3 D0 13 00 00         movss   dword ptr [rbx+13D0h], xmm4
000000018036C43D  F3 0F 11 B3 30 12 00 00         movss   dword ptr [rbx+1230h], xmm6
000000018036C445  F3 0F 11 AB 40 12 00 00         movss   dword ptr [rbx+1240h], xmm5
000000018036C44D  F3 0F 58 B3 B0 12 00 00         addss   xmm6, dword ptr [rbx+12B0h]
000000018036C455  41 0F 2F F5                     comiss  xmm6, xmm13
000000018036C459  76 1B                           jbe     short loc_18036C476
000000018036C45B  F3 41 0F 58 F5                  addss   xmm6, xmm13
000000018036C460  41 0F 28 CA                     movaps  xmm1, xmm10; Y
000000018036C464  0F 28 C6                        movaps  xmm0, xmm6; X
000000018036C467  E8 6C 30 38 00                  call    fmodf
000000018036C46C  0F 28 F0                        movaps  xmm6, xmm0
000000018036C46F  F3 41 0F 5C F5                  subss   xmm6, xmm13
000000018036C474  EB 1F                           jmp     short loc_18036C495
000000018036C476  41 0F 2F F7                     comiss  xmm6, xmm15
000000018036C47A  73 19                           jnb     short loc_18036C495
000000018036C47C  F3 41 0F 5C F5                  subss   xmm6, xmm13
000000018036C481  41 0F 28 CA                     movaps  xmm1, xmm10; Y
000000018036C485  0F 28 C6                        movaps  xmm0, xmm6; X
000000018036C488  E8 4B 30 38 00                  call    fmodf
000000018036C48D  0F 28 F0                        movaps  xmm6, xmm0
000000018036C490  F3 41 0F 58 F5                  addss   xmm6, xmm13
000000018036C495  0F 28 C6                        movaps  xmm0, xmm6
000000018036C498  F3 0F 11 B3 20 12 00 00         movss   dword ptr [rbx+1220h], xmm6
000000018036C4A0  F3 41 0F 58 C5                  addss   xmm0, xmm13
000000018036C4A5  0F 28 FE                        movaps  xmm7, xmm6
000000018036C4A8  F3 0F 59 BB 10 16 00 00         mulss   xmm7, dword ptr [rbx+1610h]
000000018036C4B0  F3 41 0F 59 C4                  mulss   xmm0, xmm12
000000018036C4B5  E8 06 CB FF FF                  call    sub_180368FC0
000000018036C4BA  0F 28 E8                        movaps  xmm5, xmm0
000000018036C4BD  F3 41 0F 59 EB                  mulss   xmm5, xmm11
000000018036C4C2  F3 0F 59 AB C0 12 00 00         mulss   xmm5, dword ptr [rbx+12C0h]
000000018036C4CA  F3 0F 59 AB E0 15 00 00         mulss   xmm5, dword ptr [rbx+15E0h]
000000018036C4D2  41 0F 2F EF                     comiss  xmm5, xmm15
000000018036C4D6  73 06                           jnb     short loc_18036C4DE
000000018036C4D8  41 0F 28 EF                     movaps  xmm5, xmm15
000000018036C4DC  EB 05                           jmp     short loc_18036C4E3
000000018036C4DE  F3 41 0F 5D ED                  minss   xmm5, xmm13
000000018036C4E3  F3 0F 59 AB B0 15 00 00         mulss   xmm5, dword ptr [rbx+15B0h]
000000018036C4EB  0F 28 D5                        movaps  xmm2, xmm5
000000018036C4EE  F3 0F 59 D5                     mulss   xmm2, xmm5
000000018036C4F2  0F 28 CA                        movaps  xmm1, xmm2
000000018036C4F5  0F 28 C2                        movaps  xmm0, xmm2
000000018036C4F8  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036C500  0F 28 DA                        movaps  xmm3, xmm2
000000018036C503  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C507  0F 28 E2                        movaps  xmm4, xmm2
000000018036C50A  F3 0F 59 A3 80 17 00 00         mulss   xmm4, dword ptr [rbx+1780h]
000000018036C512  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036C51A  F3 0F 59 DD                     mulss   xmm3, xmm5
000000018036C51E  F3 0F 58 A3 70 17 00 00         addss   xmm4, dword ptr [rbx+1770h]
000000018036C526  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C52A  0F 28 C3                        movaps  xmm0, xmm3
000000018036C52D  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036C535  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036C539  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C53D  F3 0F 10 8B D0 12 00 00         movss   xmm1, dword ptr [rbx+12D0h]
000000018036C545  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C549  0F 28 C1                        movaps  xmm0, xmm1
000000018036C54C  F3 0F 58 C6                     addss   xmm0, xmm6
000000018036C550  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036C554  41 0F 2F C6                     comiss  xmm0, xmm14
000000018036C558  F3 0F 58 E5                     addss   xmm4, xmm5
000000018036C55C  F3 0F 59 E7                     mulss   xmm4, xmm7
000000018036C560  F3 0F 11 A3 20 13 00 00         movss   dword ptr [rbx+1320h], xmm4
000000018036C568  72 07                           jb      short loc_18036C571
000000018036C56A  F3 41 0F 58 CD                  addss   xmm1, xmm13
000000018036C56F  EB 05                           jmp     short loc_18036C576
000000018036C571  F3 41 0F 5C CD                  subss   xmm1, xmm13
000000018036C576  0F 28 F0                        movaps  xmm6, xmm0
000000018036C579  73 06                           jnb     short loc_18036C581
000000018036C57B  41 0F 28 F7                     movaps  xmm6, xmm15
000000018036C57F  EB 06                           jmp     short loc_18036C587
000000018036C581  76 04                           jbe     short loc_18036C587
000000018036C583  41 0F 28 F5                     movaps  xmm6, xmm13
000000018036C587  F3 44 0F 10 83 20 12 00 00      movss   xmm8, dword ptr [rbx+1220h]
000000018036C590  F3 0F 59 B3 20 16 00 00         mulss   xmm6, dword ptr [rbx+1620h]
000000018036C598  F3 0F 5E C1                     divss   xmm0, xmm1
000000018036C59C  E8 1F CA FF FF                  call    sub_180368FC0
000000018036C5A1  0F 28 E0                        movaps  xmm4, xmm0
000000018036C5A4  F3 0F 10 83 D0 15 00 00         movss   xmm0, dword ptr [rbx+15D0h]
000000018036C5AC  44 0F 2F C0                     comiss  xmm8, xmm0
000000018036C5B0  72 18                           jb      short loc_18036C5CA
000000018036C5B2  0F 2F 83 30 12 00 00            comiss  xmm0, dword ptr [rbx+1230h]
000000018036C5B9  76 0F                           jbe     short loc_18036C5CA
000000018036C5BB  F3 0F 10 BB 40 12 00 00         movss   xmm7, dword ptr [rbx+1240h]
000000018036C5C3  F3 41 0F 58 FA                  addss   xmm7, xmm10
000000018036C5C8  EB 08                           jmp     short loc_18036C5D2
000000018036C5CA  F3 0F 10 BB 40 12 00 00         movss   xmm7, dword ptr [rbx+1240h]
000000018036C5D2  0F 2F 3D F7 8C 77 00            comiss  xmm7, cs:dword_180AE52D0
000000018036C5D9  F3 0F 59 A3 C0 12 00 00         mulss   xmm4, dword ptr [rbx+12C0h]
000000018036C5E1  F3 41 0F 59 E3                  mulss   xmm4, xmm11
000000018036C5E6  F3 0F 59 A3 F0 15 00 00         mulss   xmm4, dword ptr [rbx+15F0h]
000000018036C5EE  72 03                           jb      short loc_18036C5F3
000000018036C5F0  0F 57 FF                        xorps   xmm7, xmm7
000000018036C5F3  41 0F 2F E7                     comiss  xmm4, xmm15
000000018036C5F7  73 06                           jnb     short loc_18036C5FF
000000018036C5F9  41 0F 28 E7                     movaps  xmm4, xmm15
000000018036C5FD  EB 05                           jmp     short loc_18036C604
000000018036C5FF  F3 41 0F 5D E5                  minss   xmm4, xmm13
000000018036C604  F3 0F 11 BB 40 12 00 00         movss   dword ptr [rbx+1240h], xmm7
000000018036C60C  F3 41 0F 58 F8                  addss   xmm7, xmm8
000000018036C611  F3 0F 59 A3 B0 15 00 00         mulss   xmm4, dword ptr [rbx+15B0h]
000000018036C619  0F 28 D4                        movaps  xmm2, xmm4
000000018036C61C  F3 41 0F 58 FD                  addss   xmm7, xmm13
000000018036C621  F3 0F 59 D4                     mulss   xmm2, xmm4
000000018036C625  0F 28 C2                        movaps  xmm0, xmm2
000000018036C628  F3 41 0F 59 FC                  mulss   xmm7, xmm12
000000018036C62D  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C631  0F 28 DA                        movaps  xmm3, xmm2
000000018036C634  F3 0F 59 DC                     mulss   xmm3, xmm4
000000018036C638  44 0F 28 CA                     movaps  xmm9, xmm2
000000018036C63C  F3 44 0F 59 8B 80 17 00 00      mulss   xmm9, dword ptr [rbx+1780h]
000000018036C645  F3 41 0F 5C FD                  subss   xmm7, xmm13
000000018036C64A  0F 28 CA                        movaps  xmm1, xmm2
000000018036C64D  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036C655  F3 44 0F 58 8B 70 17 00 00      addss   xmm9, dword ptr [rbx+1770h]
000000018036C65E  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036C666  F3 44 0F 59 C8                  mulss   xmm9, xmm0
000000018036C66B  0F 28 C3                        movaps  xmm0, xmm3
000000018036C66E  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036C676  F3 44 0F 58 C9                  addss   xmm9, xmm1
000000018036C67B  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C67F  F3 44 0F 59 C8                  mulss   xmm9, xmm0
000000018036C684  0F 28 C7                        movaps  xmm0, xmm7
000000018036C687  0F 54 05 02 91 77 00            andps   xmm0, cs:xmmword_180AE5790
000000018036C68E  0F 57 05 2B 91 77 00            xorps   xmm0, cs:xmmword_180AE57C0
000000018036C695  F3 44 0F 58 CB                  addss   xmm9, xmm3
000000018036C69A  F3 44 0F 58 CC                  addss   xmm9, xmm4
000000018036C69F  F3 44 0F 59 CE                  mulss   xmm9, xmm6
000000018036C6A4  F3 44 0F 11 8B 30 13 00 00      movss   dword ptr [rbx+1330h], xmm9
000000018036C6AD  E8 0E C9 FF FF                  call    sub_180368FC0
000000018036C6B2  41 0F 2F FE                     comiss  xmm7, xmm14
000000018036C6B6  44 0F 28 C0                     movaps  xmm8, xmm0
000000018036C6BA  F3 45 0F 58 C5                  addss   xmm8, xmm13
000000018036C6BF  73 06                           jnb     short loc_18036C6C7
000000018036C6C1  41 0F 28 FF                     movaps  xmm7, xmm15
000000018036C6C5  EB 06                           jmp     short loc_18036C6CD
000000018036C6C7  76 04                           jbe     short loc_18036C6CD
000000018036C6C9  41 0F 28 FD                     movaps  xmm7, xmm13
000000018036C6CD  F3 44 0F 59 83 C0 12 00 00      mulss   xmm8, dword ptr [rbx+12C0h]
000000018036C6D6  F3 0F 59 BB 30 16 00 00         mulss   xmm7, dword ptr [rbx+1630h]
000000018036C6DE  F3 44 0F 59 05 B1 E5 61 00      mulss   xmm8, cs:dword_18098AC98
000000018036C6E7  F3 44 0F 59 83 00 16 00 00      mulss   xmm8, dword ptr [rbx+1600h]
000000018036C6F0  45 0F 2F C7                     comiss  xmm8, xmm15
000000018036C6F4  73 06                           jnb     short loc_18036C6FC
000000018036C6F6  45 0F 28 C7                     movaps  xmm8, xmm15
000000018036C6FA  EB 05                           jmp     short loc_18036C701
000000018036C6FC  F3 45 0F 5D C5                  minss   xmm8, xmm13
000000018036C701  F3 44 0F 59 83 B0 15 00 00      mulss   xmm8, dword ptr [rbx+15B0h]
000000018036C70A  F3 44 0F 59 8B 90 12 00 00      mulss   xmm9, dword ptr [rbx+1290h]
000000018036C713  F3 0F 10 B3 20 12 00 00         movss   xmm6, dword ptr [rbx+1220h]
000000018036C71B  41 0F 28 D0                     movaps  xmm2, xmm8
000000018036C71F  F3 0F 10 AB 40 12 00 00         movss   xmm5, dword ptr [rbx+1240h]
000000018036C727  F3 41 0F 59 D0                  mulss   xmm2, xmm8
000000018036C72C  0F 28 C2                        movaps  xmm0, xmm2
000000018036C72F  0F 28 DA                        movaps  xmm3, xmm2
000000018036C732  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C736  0F 28 E2                        movaps  xmm4, xmm2
000000018036C739  F3 0F 59 A3 80 17 00 00         mulss   xmm4, dword ptr [rbx+1780h]
000000018036C741  0F 28 CA                        movaps  xmm1, xmm2
000000018036C744  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036C74C  F3 0F 58 A3 70 17 00 00         addss   xmm4, dword ptr [rbx+1770h]
000000018036C754  F3 41 0F 59 D8                  mulss   xmm3, xmm8
000000018036C759  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036C761  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C765  0F 28 C3                        movaps  xmm0, xmm3
000000018036C768  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036C770  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036C774  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C778  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C77C  F3 0F 10 83 20 13 00 00         movss   xmm0, dword ptr [rbx+1320h]
000000018036C784  F3 0F 59 83 80 12 00 00         mulss   xmm0, dword ptr [rbx+1280h]
000000018036C78C  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036C790  F3 41 0F 58 C1                  addss   xmm0, xmm9
000000018036C795  F3 41 0F 58 E0                  addss   xmm4, xmm8
000000018036C79A  F3 0F 59 E7                     mulss   xmm4, xmm7
000000018036C79E  F3 0F 59 A3 A0 12 00 00         mulss   xmm4, dword ptr [rbx+12A0h]
000000018036C7A6  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036C7AA  F3 0F 11 A3 50 14 00 00         movss   dword ptr [rbx+1450h], xmm4
000000018036C7B2  F3 0F 11 B3 30 12 00 00         movss   dword ptr [rbx+1230h], xmm6
000000018036C7BA  F3 0F 11 AB 40 12 00 00         movss   dword ptr [rbx+1240h], xmm5
000000018036C7C2  F3 0F 58 B3 B0 12 00 00         addss   xmm6, dword ptr [rbx+12B0h]
000000018036C7CA  41 0F 2F F5                     comiss  xmm6, xmm13
000000018036C7CE  76 1B                           jbe     short loc_18036C7EB
000000018036C7D0  F3 41 0F 58 F5                  addss   xmm6, xmm13
000000018036C7D5  41 0F 28 CA                     movaps  xmm1, xmm10; Y
000000018036C7D9  0F 28 C6                        movaps  xmm0, xmm6; X
000000018036C7DC  E8 F7 2C 38 00                  call    fmodf
000000018036C7E1  0F 28 F0                        movaps  xmm6, xmm0
000000018036C7E4  F3 41 0F 5C F5                  subss   xmm6, xmm13
000000018036C7E9  EB 1F                           jmp     short loc_18036C80A
000000018036C7EB  41 0F 2F F7                     comiss  xmm6, xmm15
000000018036C7EF  73 19                           jnb     short loc_18036C80A
000000018036C7F1  F3 41 0F 5C F5                  subss   xmm6, xmm13
000000018036C7F6  41 0F 28 CA                     movaps  xmm1, xmm10; Y
000000018036C7FA  0F 28 C6                        movaps  xmm0, xmm6; X
000000018036C7FD  E8 D6 2C 38 00                  call    fmodf
000000018036C802  0F 28 F0                        movaps  xmm6, xmm0
000000018036C805  F3 41 0F 58 F5                  addss   xmm6, xmm13
000000018036C80A  0F 28 C6                        movaps  xmm0, xmm6
000000018036C80D  F3 0F 11 B3 20 12 00 00         movss   dword ptr [rbx+1220h], xmm6
000000018036C815  F3 41 0F 58 C5                  addss   xmm0, xmm13
000000018036C81A  0F 28 FE                        movaps  xmm7, xmm6
000000018036C81D  F3 0F 59 BB 10 16 00 00         mulss   xmm7, dword ptr [rbx+1610h]
000000018036C825  F3 41 0F 59 C4                  mulss   xmm0, xmm12
000000018036C82A  E8 91 C7 FF FF                  call    sub_180368FC0
000000018036C82F  0F 28 E8                        movaps  xmm5, xmm0
000000018036C832  F3 41 0F 59 EB                  mulss   xmm5, xmm11
000000018036C837  F3 0F 59 AB C0 12 00 00         mulss   xmm5, dword ptr [rbx+12C0h]
000000018036C83F  F3 0F 59 AB E0 15 00 00         mulss   xmm5, dword ptr [rbx+15E0h]
000000018036C847  41 0F 2F EF                     comiss  xmm5, xmm15
000000018036C84B  73 06                           jnb     short loc_18036C853
000000018036C84D  41 0F 28 EF                     movaps  xmm5, xmm15
000000018036C851  EB 05                           jmp     short loc_18036C858
000000018036C853  F3 41 0F 5D ED                  minss   xmm5, xmm13
000000018036C858  F3 0F 59 AB B0 15 00 00         mulss   xmm5, dword ptr [rbx+15B0h]
000000018036C860  0F 28 D5                        movaps  xmm2, xmm5
000000018036C863  F3 0F 59 D5                     mulss   xmm2, xmm5
000000018036C867  0F 28 CA                        movaps  xmm1, xmm2
000000018036C86A  0F 28 C2                        movaps  xmm0, xmm2
000000018036C86D  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036C875  0F 28 DA                        movaps  xmm3, xmm2
000000018036C878  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C87C  0F 28 E2                        movaps  xmm4, xmm2
000000018036C87F  F3 0F 59 A3 80 17 00 00         mulss   xmm4, dword ptr [rbx+1780h]
000000018036C887  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036C88F  F3 0F 59 DD                     mulss   xmm3, xmm5
000000018036C893  F3 0F 58 A3 70 17 00 00         addss   xmm4, dword ptr [rbx+1770h]
000000018036C89B  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C89F  0F 28 C3                        movaps  xmm0, xmm3
000000018036C8A2  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036C8AA  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036C8AE  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C8B2  F3 0F 10 8B D0 12 00 00         movss   xmm1, dword ptr [rbx+12D0h]
000000018036C8BA  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036C8BE  0F 28 C1                        movaps  xmm0, xmm1
000000018036C8C1  F3 0F 58 C6                     addss   xmm0, xmm6
000000018036C8C5  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036C8C9  41 0F 2F C6                     comiss  xmm0, xmm14
000000018036C8CD  F3 0F 58 E5                     addss   xmm4, xmm5
000000018036C8D1  F3 0F 59 E7                     mulss   xmm4, xmm7
000000018036C8D5  F3 0F 11 A3 20 13 00 00         movss   dword ptr [rbx+1320h], xmm4
000000018036C8DD  72 07                           jb      short loc_18036C8E6
000000018036C8DF  F3 41 0F 58 CD                  addss   xmm1, xmm13
000000018036C8E4  EB 05                           jmp     short loc_18036C8EB
000000018036C8E6  F3 41 0F 5C CD                  subss   xmm1, xmm13
000000018036C8EB  0F 28 F0                        movaps  xmm6, xmm0
000000018036C8EE  73 06                           jnb     short loc_18036C8F6
000000018036C8F0  41 0F 28 F7                     movaps  xmm6, xmm15
000000018036C8F4  EB 06                           jmp     short loc_18036C8FC
000000018036C8F6  76 04                           jbe     short loc_18036C8FC
000000018036C8F8  41 0F 28 F5                     movaps  xmm6, xmm13
000000018036C8FC  F3 44 0F 10 83 20 12 00 00      movss   xmm8, dword ptr [rbx+1220h]
000000018036C905  F3 0F 59 B3 20 16 00 00         mulss   xmm6, dword ptr [rbx+1620h]
000000018036C90D  F3 0F 5E C1                     divss   xmm0, xmm1
000000018036C911  E8 AA C6 FF FF                  call    sub_180368FC0
000000018036C916  0F 28 E0                        movaps  xmm4, xmm0
000000018036C919  F3 0F 10 83 D0 15 00 00         movss   xmm0, dword ptr [rbx+15D0h]
000000018036C921  44 0F 2F C0                     comiss  xmm8, xmm0
000000018036C925  72 18                           jb      short loc_18036C93F
000000018036C927  0F 2F 83 30 12 00 00            comiss  xmm0, dword ptr [rbx+1230h]
000000018036C92E  76 0F                           jbe     short loc_18036C93F
000000018036C930  F3 0F 10 BB 40 12 00 00         movss   xmm7, dword ptr [rbx+1240h]
000000018036C938  F3 41 0F 58 FA                  addss   xmm7, xmm10
000000018036C93D  EB 08                           jmp     short loc_18036C947
000000018036C93F  F3 0F 10 BB 40 12 00 00         movss   xmm7, dword ptr [rbx+1240h]
000000018036C947  0F 2F 3D 82 89 77 00            comiss  xmm7, cs:dword_180AE52D0
000000018036C94E  F3 0F 59 A3 C0 12 00 00         mulss   xmm4, dword ptr [rbx+12C0h]
000000018036C956  F3 41 0F 59 E3                  mulss   xmm4, xmm11
000000018036C95B  F3 0F 59 A3 F0 15 00 00         mulss   xmm4, dword ptr [rbx+15F0h]
000000018036C963  72 03                           jb      short loc_18036C968
000000018036C965  0F 57 FF                        xorps   xmm7, xmm7
000000018036C968  41 0F 2F E7                     comiss  xmm4, xmm15
000000018036C96C  73 06                           jnb     short loc_18036C974
000000018036C96E  41 0F 28 E7                     movaps  xmm4, xmm15
000000018036C972  EB 05                           jmp     short loc_18036C979
000000018036C974  F3 41 0F 5D E5                  minss   xmm4, xmm13
000000018036C979  F3 0F 11 BB 40 12 00 00         movss   dword ptr [rbx+1240h], xmm7
000000018036C981  F3 41 0F 58 F8                  addss   xmm7, xmm8
000000018036C986  F3 0F 59 A3 B0 15 00 00         mulss   xmm4, dword ptr [rbx+15B0h]
000000018036C98E  0F 28 D4                        movaps  xmm2, xmm4
000000018036C991  F3 41 0F 58 FD                  addss   xmm7, xmm13
000000018036C996  F3 0F 59 D4                     mulss   xmm2, xmm4
000000018036C99A  0F 28 C2                        movaps  xmm0, xmm2
000000018036C99D  F3 41 0F 59 FC                  mulss   xmm7, xmm12
000000018036C9A2  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C9A6  0F 28 DA                        movaps  xmm3, xmm2
000000018036C9A9  F3 0F 59 DC                     mulss   xmm3, xmm4
000000018036C9AD  44 0F 28 C2                     movaps  xmm8, xmm2
000000018036C9B1  F3 44 0F 59 83 80 17 00 00      mulss   xmm8, dword ptr [rbx+1780h]
000000018036C9BA  F3 41 0F 5C FD                  subss   xmm7, xmm13
000000018036C9BF  0F 28 CA                        movaps  xmm1, xmm2
000000018036C9C2  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036C9CA  F3 44 0F 58 83 70 17 00 00      addss   xmm8, dword ptr [rbx+1770h]
000000018036C9D3  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036C9DB  F3 44 0F 59 C0                  mulss   xmm8, xmm0
000000018036C9E0  0F 28 C3                        movaps  xmm0, xmm3
000000018036C9E3  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036C9EB  F3 44 0F 58 C1                  addss   xmm8, xmm1
000000018036C9F0  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036C9F4  F3 44 0F 59 C0                  mulss   xmm8, xmm0
000000018036C9F9  0F 28 C7                        movaps  xmm0, xmm7
000000018036C9FC  0F 54 05 8D 8D 77 00            andps   xmm0, cs:xmmword_180AE5790
000000018036CA03  0F 57 05 B6 8D 77 00            xorps   xmm0, cs:xmmword_180AE57C0
000000018036CA0A  F3 44 0F 58 C3                  addss   xmm8, xmm3
000000018036CA0F  F3 44 0F 58 C4                  addss   xmm8, xmm4
000000018036CA14  F3 44 0F 59 C6                  mulss   xmm8, xmm6
000000018036CA19  F3 44 0F 11 83 30 13 00 00      movss   dword ptr [rbx+1330h], xmm8
000000018036CA22  E8 99 C5 FF FF                  call    sub_180368FC0
000000018036CA27  41 0F 2F FE                     comiss  xmm7, xmm14
000000018036CA2B  F3 41 0F 58 C5                  addss   xmm0, xmm13
000000018036CA30  73 06                           jnb     short loc_18036CA38
000000018036CA32  41 0F 28 FF                     movaps  xmm7, xmm15
000000018036CA36  EB 06                           jmp     short loc_18036CA3E
000000018036CA38  76 04                           jbe     short loc_18036CA3E
000000018036CA3A  41 0F 28 FD                     movaps  xmm7, xmm13
000000018036CA3E  F3 0F 59 83 C0 12 00 00         mulss   xmm0, dword ptr [rbx+12C0h]
000000018036CA46  F3 0F 59 BB 30 16 00 00         mulss   xmm7, dword ptr [rbx+1630h]
000000018036CA4E  F3 0F 59 05 42 E2 61 00         mulss   xmm0, cs:dword_18098AC98
000000018036CA56  F3 0F 59 83 00 16 00 00         mulss   xmm0, dword ptr [rbx+1600h]
000000018036CA5E  41 0F 2F C7                     comiss  xmm0, xmm15
000000018036CA62  72 09                           jb      short loc_18036CA6D
000000018036CA64  44 0F 28 F8                     movaps  xmm15, xmm0
000000018036CA68  F3 45 0F 5D FD                  minss   xmm15, xmm13
000000018036CA6D  F3 44 0F 59 BB B0 15 00 00      mulss   xmm15, dword ptr [rbx+15B0h]
000000018036CA76  F3 44 0F 59 83 90 12 00 00      mulss   xmm8, dword ptr [rbx+1290h]
000000018036CA7F  F3 0F 10 AB 20 12 00 00         movss   xmm5, dword ptr [rbx+1220h]
000000018036CA87  41 0F 28 D7                     movaps  xmm2, xmm15
000000018036CA8B  F3 0F 10 B3 40 12 00 00         movss   xmm6, dword ptr [rbx+1240h]
000000018036CA93  F3 41 0F 59 D7                  mulss   xmm2, xmm15
000000018036CA98  0F 28 CA                        movaps  xmm1, xmm2
000000018036CA9B  0F 28 C2                        movaps  xmm0, xmm2
000000018036CA9E  F3 0F 59 8B 60 17 00 00         mulss   xmm1, dword ptr [rbx+1760h]
000000018036CAA6  0F 28 DA                        movaps  xmm3, xmm2
000000018036CAA9  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036CAAD  0F 28 E2                        movaps  xmm4, xmm2
000000018036CAB0  F3 0F 58 8B 50 17 00 00         addss   xmm1, dword ptr [rbx+1750h]
000000018036CAB8  F3 0F 59 A3 80 17 00 00         mulss   xmm4, dword ptr [rbx+1780h]
000000018036CAC0  F3 41 0F 59 DF                  mulss   xmm3, xmm15
000000018036CAC5  F3 0F 58 A3 70 17 00 00         addss   xmm4, dword ptr [rbx+1770h]
000000018036CACD  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036CAD1  0F 28 C3                        movaps  xmm0, xmm3
000000018036CAD4  F3 0F 59 9B 40 17 00 00         mulss   xmm3, dword ptr [rbx+1740h]
000000018036CADC  F3 0F 59 C2                     mulss   xmm0, xmm2
000000018036CAE0  F3 0F 58 E1                     addss   xmm4, xmm1
000000018036CAE4  F3 0F 59 E0                     mulss   xmm4, xmm0
000000018036CAE8  F3 0F 10 83 20 13 00 00         movss   xmm0, dword ptr [rbx+1320h]
000000018036CAF0  F3 0F 59 83 80 12 00 00         mulss   xmm0, dword ptr [rbx+1280h]
000000018036CAF8  F3 0F 58 E3                     addss   xmm4, xmm3
000000018036CAFC  F3 41 0F 58 C0                  addss   xmm0, xmm8
000000018036CB01  F3 41 0F 58 E7                  addss   xmm4, xmm15
000000018036CB06  F3 0F 59 E7                     mulss   xmm4, xmm7
000000018036CB0A  F3 0F 59 A3 A0 12 00 00         mulss   xmm4, dword ptr [rbx+12A0h]
000000018036CB12  F3 0F 58 E0                     addss   xmm4, xmm0
000000018036CB16  F3 0F 11 A3 D0 14 00 00         movss   dword ptr [rbx+14D0h], xmm4
000000018036CB1E  F3 0F 10 93 40 15 00 00         movss   xmm2, dword ptr [rbx+1540h]
000000018036CB26  F3 0F 11 AB 00 13 00 00         movss   dword ptr [rbx+1300h], xmm5
000000018036CB2E  F3 0F 11 B3 E0 12 00 00         movss   dword ptr [rbx+12E0h], xmm6
000000018036CB36  F3 0F 10 83 50 14 00 00         movss   xmm0, dword ptr [rbx+1450h]
000000018036CB3E  F3 0F 58 83 40 14 00 00         addss   xmm0, dword ptr [rbx+1440h]
000000018036CB46  F3 0F 10 8B D0 14 00 00         movss   xmm1, dword ptr [rbx+14D0h]
000000018036CB4E  F3 0F 58 8B C0 13 00 00         addss   xmm1, dword ptr [rbx+13C0h]
000000018036CB56  F3 0F 10 AB C0 14 00 00         movss   xmm5, dword ptr [rbx+14C0h]
000000018036CB5E  F3 0F 58 AB D0 13 00 00         addss   xmm5, dword ptr [rbx+13D0h]
000000018036CB66  F3 0F 59 83 60 16 00 00         mulss   xmm0, dword ptr [rbx+1660h]
000000018036CB6E  F3 0F 59 8B 70 16 00 00         mulss   xmm1, dword ptr [rbx+1670h]
000000018036CB76  F3 0F 59 AB 50 16 00 00         mulss   xmm5, dword ptr [rbx+1650h]
000000018036CB7E  F3 0F 58 93 50 13 00 00         addss   xmm2, dword ptr [rbx+1350h]
000000018036CB86  F3 0F 59 93 40 16 00 00         mulss   xmm2, dword ptr [rbx+1640h]
000000018036CB8E  F3 0F 58 EA                     addss   xmm5, xmm2
000000018036CB92  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036CB96  F3 0F 10 83 30 15 00 00         movss   xmm0, dword ptr [rbx+1530h]
000000018036CB9E  F3 0F 58 83 60 13 00 00         addss   xmm0, dword ptr [rbx+1360h]
000000018036CBA6  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036CBAA  F3 0F 10 8B B0 14 00 00         movss   xmm1, dword ptr [rbx+14B0h]
000000018036CBB2  F3 0F 59 83 80 16 00 00         mulss   xmm0, dword ptr [rbx+1680h]
000000018036CBBA  F3 0F 58 8B E0 13 00 00         addss   xmm1, dword ptr [rbx+13E0h]
000000018036CBC2  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036CBC6  F3 0F 10 83 60 14 00 00         movss   xmm0, dword ptr [rbx+1460h]
000000018036CBCE  F3 0F 58 83 30 14 00 00         addss   xmm0, dword ptr [rbx+1430h]
000000018036CBD6  F3 0F 59 8B 90 16 00 00         mulss   xmm1, dword ptr [rbx+1690h]
000000018036CBDE  F3 0F 59 83 A0 16 00 00         mulss   xmm0, dword ptr [rbx+16A0h]
000000018036CBE6  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036CBEA  F3 0F 10 8B E0 14 00 00         movss   xmm1, dword ptr [rbx+14E0h]
000000018036CBF2  F3 0F 58 8B B0 13 00 00         addss   xmm1, dword ptr [rbx+13B0h]
000000018036CBFA  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036CBFE  F3 0F 10 83 20 15 00 00         movss   xmm0, dword ptr [rbx+1520h]
000000018036CC06  F3 0F 59 8B B0 16 00 00         mulss   xmm1, dword ptr [rbx+16B0h]
000000018036CC0E  F3 0F 58 83 70 13 00 00         addss   xmm0, dword ptr [rbx+1370h]
000000018036CC16  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036CC1A  F3 0F 10 8B F0 13 00 00         movss   xmm1, dword ptr [rbx+13F0h]
000000018036CC22  F3 0F 58 8B A0 14 00 00         addss   xmm1, dword ptr [rbx+14A0h]
000000018036CC2A  F3 0F 59 83 C0 16 00 00         mulss   xmm0, dword ptr [rbx+16C0h]
000000018036CC32  F3 0F 59 8B D0 16 00 00         mulss   xmm1, dword ptr [rbx+16D0h]
000000018036CC3A  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036CC3E  F3 0F 10 83 70 14 00 00         movss   xmm0, dword ptr [rbx+1470h]
000000018036CC46  F3 0F 58 83 20 14 00 00         addss   xmm0, dword ptr [rbx+1420h]
000000018036CC4E  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036CC52  F3 0F 10 8B A0 13 00 00         movss   xmm1, dword ptr [rbx+13A0h]
000000018036CC5A  F3 0F 59 83 E0 16 00 00         mulss   xmm0, dword ptr [rbx+16E0h]
000000018036CC62  F3 0F 58 8B F0 14 00 00         addss   xmm1, dword ptr [rbx+14F0h]
000000018036CC6A  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036CC6E  F3 0F 10 83 10 15 00 00         movss   xmm0, dword ptr [rbx+1510h]
000000018036CC76  F3 0F 59 8B F0 16 00 00         mulss   xmm1, dword ptr [rbx+16F0h]
000000018036CC7E  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036CC82  F3 0F 58 83 80 13 00 00         addss   xmm0, dword ptr [rbx+1380h]
000000018036CC8A  F3 0F 10 93 70 15 00 00         movss   xmm2, dword ptr [rbx+1570h]
000000018036CC92  F3 0F 10 8B 90 14 00 00         movss   xmm1, dword ptr [rbx+1490h]
000000018036CC9A  0F 28 E2                        movaps  xmm4, xmm2
000000018036CC9D  F3 0F 59 A3 70 18 00 00         mulss   xmm4, dword ptr [rbx+1870h]
000000018036CCA5  F3 0F 59 83 00 17 00 00         mulss   xmm0, dword ptr [rbx+1700h]
000000018036CCAD  F3 0F 58 A3 80 15 00 00         addss   xmm4, dword ptr [rbx+1580h]
000000018036CCB5  F3 0F 58 8B 00 14 00 00         addss   xmm1, dword ptr [rbx+1400h]
000000018036CCBD  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036CCC1  F3 0F 10 83 80 14 00 00         movss   xmm0, dword ptr [rbx+1480h]
000000018036CCC9  F3 0F 58 83 10 14 00 00         addss   xmm0, dword ptr [rbx+1410h]
000000018036CCD1  F3 0F 59 8B 10 17 00 00         mulss   xmm1, dword ptr [rbx+1710h]
000000018036CCD9  F3 0F 59 83 20 17 00 00         mulss   xmm0, dword ptr [rbx+1720h]
000000018036CCE1  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036CCE5  F3 0F 10 8B 00 15 00 00         movss   xmm1, dword ptr [rbx+1500h]
000000018036CCED  F3 0F 58 8B 90 13 00 00         addss   xmm1, dword ptr [rbx+1390h]
000000018036CCF5  F3 0F 58 E8                     addss   xmm5, xmm0
000000018036CCF9  0F 28 C2                        movaps  xmm0, xmm2
000000018036CCFC  F3 0F 59 8B 30 17 00 00         mulss   xmm1, dword ptr [rbx+1730h]
000000018036CD04  F3 0F 11 A3 70 15 00 00         movss   dword ptr [rbx+1570h], xmm4
000000018036CD0C  F3 0F 59 83 80 18 00 00         mulss   xmm0, dword ptr [rbx+1880h]
000000018036CD14  F3 0F 58 E9                     addss   xmm5, xmm1
000000018036CD18  F3 0F 58 C4                     addss   xmm0, xmm4
000000018036CD1C  0F 28 DD                        movaps  xmm3, xmm5
000000018036CD1F  F3 0F 5C D8                     subss   xmm3, xmm0
000000018036CD23  0F 28 C3                        movaps  xmm0, xmm3
000000018036CD26  F3 0F 59 83 70 18 00 00         mulss   xmm0, dword ptr [rbx+1870h]
000000018036CD2E  F3 0F 58 C2                     addss   xmm0, xmm2
000000018036CD32  F3 0F 11 83 60 15 00 00         movss   dword ptr [rbx+1560h], xmm0
000000018036CD3A  F3 0F 10 93 C0 18 00 00         movss   xmm2, dword ptr [rbx+18C0h]
000000018036CD42  F3 0F 59 9B 50 15 00 00         mulss   xmm3, dword ptr [rbx+1550h]
000000018036CD4A  F3 0F 5C E3                     subss   xmm4, xmm3
000000018036CD4E  F3 0F 59 E2                     mulss   xmm4, xmm2
000000018036CD52  F3 0F 59 D5                     mulss   xmm2, xmm5
000000018036CD56  F3 0F 5C E2                     subss   xmm4, xmm2
000000018036CD5A  F3 0F 58 E5                     addss   xmm4, xmm5
000000018036CD5E  F3 0F 11 A3 40 13 00 00         movss   dword ptr [rbx+1340h], xmm4
000000018036CD66  F3 0F 11 A3 C0 0D 00 00         movss   dword ptr [rbx+0DC0h], xmm4
000000018036CD6E  44 0F 2E AB 80 8C 01 00         ucomiss xmm13, dword ptr [rbx+18C80h]
000000018036CD76  75 28                           jnz     short loc_18036CDA0
000000018036CD78  F3 0F 10 84 24 D0 00 00 00      movss   xmm0, [rsp+0C8h+arg_0]
000000018036CD81  F3 0F 11 83 40 01 00 00         movss   dword ptr [rbx+140h], xmm0
000000018036CD89  C7 83 80 8C 01 00 00 00 00 00   mov     dword ptr [rbx+18C80h], 0
000000018036CD93  0F 1F 40 00                     nop     dword ptr [rax+00h]
000000018036CD97  66 0F 1F 84 00 00 00 00 00      nop     word ptr [rax+rax+00000000h]
000000018036CDA0  8B 83 B0 29 00 00               mov     eax, [rbx+29B0h]
000000018036CDA6  4C 8D 9C 24 C0 00 00 00         lea     r11, [rsp+0C8h+var_8]
000000018036CDAE  48 8B 0F                        mov     rcx, [rdi]
000000018036CDB1  41 0F 28 73 F0                  movaps  xmm6, xmmword ptr [r11-10h]
000000018036CDB6  41 0F 28 7B E0                  movaps  xmm7, xmmword ptr [r11-20h]
000000018036CDBB  45 0F 28 43 D0                  movaps  xmm8, xmmword ptr [r11-30h]
000000018036CDC0  45 0F 28 4B C0                  movaps  xmm9, xmmword ptr [r11-40h]
000000018036CDC5  45 0F 28 53 B0                  movaps  xmm10, xmmword ptr [r11-50h]
000000018036CDCA  45 0F 28 5B A0                  movaps  xmm11, xmmword ptr [r11-60h]
000000018036CDCF  45 0F 28 63 90                  movaps  xmm12, xmmword ptr [r11-70h]
000000018036CDD4  45 0F 28 6B 80                  movaps  xmm13, xmmword ptr [r11-80h]
000000018036CDD9  44 0F 28 74 24 30               movaps  xmm14, [rsp+0C8h+var_98]
000000018036CDDF  44 0F 28 7C 24 20               movaps  xmm15, [rsp+0C8h+var_A8]
000000018036CDE5  89 01                           mov     [rcx], eax
000000018036CDE7  8B 83 B0 29 00 00               mov     eax, [rbx+29B0h]
000000018036CDED  48 8B 4F 08                     mov     rcx, [rdi+8]
000000018036CDF1  49 8B 5B 18                     mov     rbx, [r11+18h]
000000018036CDF5  89 01                           mov     [rcx], eax
000000018036CDF7  49 8B E3                        mov     rsp, r11
000000018036CDFA  5F                              pop     rdi
000000018036CDFB  C3                              retn
